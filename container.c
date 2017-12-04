#include "types.h"
#include "defs.h"
#include "spinlock.h"
#include "param.h"
#include "stat.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "container.h"
#include "proc.h"
#include "sleeplock.h" // TODO: REmove
#include "fs.h"// TODO: remove
#include "file.h" // TODO: remove


static struct cont* alloccont(void);

// TODO: Check to make sure ALL ctable calls have a lock

// Must be called with interrupts disabled
int
cpuid() {
  return mycpu()-cpus;
}

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
  int apicid, i;
  
  if(readeflags()&FL_IF)
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
}

struct {
  struct spinlock lock;
  struct cont cont[NCONT];
} ctable;

struct {
	struct spinlock lock;
	struct proc proc[NCONT][NPROC];
} ptable; 

struct cont *currcont;

int nextcid = 1;

void
cinit(void)
{
  initlock(&ctable.lock, "ctable");
  initlock(&ptable.lock, "ptable");
}

void
acquirectable(void) 
{
	acquire(&ptable.lock);
}
// TODO: refactor name of ctablelock to ptable
// TODO: replace these aqcuires and releases with normal aqcuire and release using ctablelock()
void 
releasectable(void)
{
	release(&ptable.lock);
	//cprintf("\t\t Released ctable\n");
}

struct spinlock*
ctablelock(void)
{
	return &ptable.lock;
}

struct cont*
initcontainer(void)
{
	int i,
		mproc = MAX_CONT_PROC,
		msz   = MAX_CONT_MEM,
		mdsk  = MAX_CONT_DSK;
	struct cont *c;

	if ((c = alloccont()) == 0) {
		panic("Can't alloc init container.");
	}

	currcont = c;	

	acquire(&ctable.lock);
	c->mproc = mproc;
	c->msz = msz;
	c->mdsk = mdsk;	
	c->state = CRUNNABLE;	
	c->rootdir = namei("/");
	safestrcpy(c->name, "initcont", sizeof(c->name));	

	// Init pointers to each container's process tables
	for (i = 0; i < NCONT; i++)
		ctable.cont[i].ptable = ptable.proc[i];

	release(&ctable.lock);	

	cprintf("Init container\n");

	return c;
}

// Set up first user container and process.
void
userinit(void)
{
	cprintf("userinit\n");
	struct cont* root;
  	root = initcontainer();
  	initprocess(root);    	
}

//TODO: REMOVE!!
struct cont*
mycont(void) {
	return currcont;
}

// struct cont* 	
// rootcont(void) {
// 	struct cont *c;
// 	// TODO: Check to make sure it always inits at first index
//   	acquire(&ctable.lock);  
//   	c = &ctable.cont[0];
//   	release(&ctable.lock);
//   	return c;
// }

// Look in the container table for an CUNUSED cont.
// If found, change state to CEMBRYO
// Otherwise return 0.
static struct cont*
alloccont(void)
{
	struct cont *c;

	acquire(&ctable.lock);

	for(c = ctable.cont; c < &ctable.cont[NCONT]; c++)
		if(c->state == CUNUSED)
		  goto found;

	release(&ctable.lock);
	return 0;

found:
	c->state = CEMBRYO;
	c->cid = nextcid++;

	release(&ctable.lock);

	return c;
}

// Enter scheduler.  Must hold only ctable.lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(ctablelock()))
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1) 
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = mycpu()->intena;
  swtch(&p->context, mycpu()->scheduler);
  mycpu()->intena = intena;
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;
  struct cont *cont;
  struct cpu *c = mycpu();
  int i, k;
  c->proc = 0;
  
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    // TODO: do we need to acquire ctable lock too?

	// TODO: Check that scheulde cycles over ctable equally    
    for(i = 0; i < NCONT; i++) {

      cont = &ctable.cont[i];

      if (cont->state != CRUNNABLE)
      	continue;            

      for (k = (cont->nextproc % cont->mproc); k < cont->mproc; k++) {
      	
      	  p = &cont->ptable[k];       	  

      	  cont->nextproc = cont->nextproc + 1;

	      if(p->state != RUNNABLE)
	        continue;

	      // Switch to chosen process.  It is the process's job
	      // to release ctable.lock and then reacquire it
	      // before jumping back to us.
	      c->proc = p;
	      switchuvm(p);
	      p->state = RUNNING;

	      swtch(&(c->scheduler), p->context); 
	      switchkvm();

	      // Process is done running for now.
	      // It should have changed its p->state before coming back.
	      c->proc = 0;
	  }
    }
    release(&ptable.lock);

  }
}

// TODO: Block processes inside non root containers from ccreating
int 
ccreate(char* name, int mproc, uint msz, uint mdsk)
{
	// TODO: check to make sure there are no containers with the same name
	struct cont *nc;
	struct inode* rootdir;

	// Allocate container.
	if ((nc = alloccont()) == 0)
		return -1;

	if ((rootdir = namei(name)) == 0)
		return -1;

	// TODO: Do we need this? could cause a "sched
	// locks" problem if we acquire the ctable then
	// something calls Sched() before releasing
	acquire(&ctable.lock);
	nc->mproc = mproc;
	nc->msz = msz;
	nc->mdsk = mdsk;
	nc->rootdir = rootdir;
	strncpy(nc->name, name, 16); // TODO: strlen(name) instead of 16?
	nc->state = CREADY;	
	release(&ctable.lock);	

	return 1;  
}

// Allocates a process for the table "name"
// Runs argv[0] (argv is program plus arguments)
int
cstart(char* name) 
{		
	struct cont *nc;
	int i;

	cprintf("Cstart\n");

	// Find container
	acquire(&ctable.lock);

	for (i = 0; i < NCONT; i++) {
		nc = &ctable.cont[i];
		if (strncmp(name, nc->name, strlen(name)) == 0 && nc->state == CREADY)
			goto found;
	}

	cprintf("No free container with name %s\n", name);
	release(&ctable.lock);
	return -1;

found: 	

	cprintf("\tFound container to run (%s)\n", nc->name);

	// TODO: Attach to a vc

	nc->state = CREADY;	
	release(&ctable.lock);
	
	return nc->cid;
}

//PAGEBREAK: 36
// Print a process listing of current container to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
contdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i, k, nextproc;
  struct cont *c;
  struct proc *p;
  char *state;
  uint pc[10];

  cprintf("Contdump()\n");
  cprintf("cont 2 p[0] %s %s\n", ctable.cont[1].ptable[0].name, states[ctable.cont[1].ptable[0].state]);

  acquirectable();

  for(i = 0; i < NCONT; i++) {

      c = &ctable.cont[i];
      nextproc = 0, k = 0;

      if (c->state == CUNUSED)
      	continue;

      for (k = (nextproc % c->mproc); k < c->mproc; k++) {
      
      	p = &c->ptable[k]; 

      	nextproc++;

	    if(p->state == UNUSED)
		    continue;
	    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
	      state = states[p->state];
	    else
	      state = "???";
	    cprintf("container: %s. %d %s %s", p->cont->name, p->pid, state, p->name);
	    if(p->state == SLEEPING){
	      getcallerpcs((uint*)p->context->ebp+2, pc);
	      for(i=0; i<10 && pc[i] != 0; i++)
	        cprintf(" %p", pc[i]);
	    }
	    cprintf("\n");
	  }
  }

  releasectable();
}