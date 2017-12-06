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
#include "continfo.h"
#include "fs.h"

static struct cont* alloccont(void);

static int  		cexit(struct cont* c);

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

void acquireptable(void) { acquire(&ptable.lock); }

void releaseptable(void) { release(&ptable.lock); }

struct spinlock*
ptablelock(void)
{
	return &ptable.lock;
}

struct cont*
initcontainer(void)
{
	int i,
		mproc = NPROC,
		msz   = MAX_CONT_MEM,
		mdsk  = MAX_CONT_DSK;
	struct cont *c;
	struct inode *rootdir;

	if ((c = alloccont()) == 0) 
		panic("Can't alloc init container.");

	if ((rootdir = namei("/")) == 0)
		panic("Can't set '/' as root container's rootdir");

	currcont = c;	

	acquire(&ctable.lock);
	c->mproc = mproc;
	c->msz = msz; // SET TO MAXES FOUND IN MAIN.C
	c->mdsk = mdsk;	
	c->state = CRUNNABLE;	
	c->rootdir = idup(rootdir);
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

// Wake up all processes sleeping on chan.
// The ctable lock must be held.
void
wakeup1(void *chan)
{
	struct proc *p;
	struct cont *cont;
	int i, k;
  	// TODO: Wake up may call the wrong channel (chan usually equals min int)  	
	for(i = 0; i < NCONT; i++) {	  
	  cont = &ctable.cont[i];	  
	  for (k = 0; k < cont->mproc; k++) {	  	
	  	p = &cont->ptable[k];       	  
	  	if(p->state == SLEEPING && p->chan == chan) 
      		p->state = RUNNABLE;
	  }
	}
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

  if(!holding(ptablelock()))
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
    acquireptable();
    // TODO: do we need to acquire ctable lock too?

    for(i = 0; i < NCONT; i++) {

      cont = &ctable.cont[i];

      if (cont->state != CRUNNABLE && cont->state != CSTOPPING) // TODO: remove CSTOPPING?
      	continue;                  

      for (k = (cont->nextproc % cont->mproc); k < cont->mproc; k++) {
      	
      	  p = &cont->ptable[k];       	  

      	  cont->nextproc = cont->nextproc + 1;

	      if(p->state != RUNNABLE)
	        continue;

	      // Kill processes
	      if (cont->state == CSTOPPING) {
	        p->killed = 1;
		    // Wake process from sleep if necessary.
		    if(p->state == SLEEPING)
		      p->state = RUNNABLE;
	      }

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
	      
	      // Check if all processes are exited
	      if (cont->uproc == 0)	 
	      	cexit(cont);
	  }
    }
    releaseptable();

  }
}

struct cont*
cid2cont(int cid)
{
	struct cont* c;
	int i;

	for (i = 0; i < NCONT; i++) {
		c = &ctable.cont[i];
		if (c->cid == cid && c->state != CUNUSED)
			return c;
	}
	return 0;
}

struct cont*
name2cont(char* name)
{
	struct cont* c;
	int i;

	for (i = 0; i < NCONT; i++) {
		c = &ctable.cont[i];
		if (strncmp(name, c->name, strlen(name)) == 0 && c->state != CUNUSED)
			return c;
	}
	return 0;
}

int 
ccreate(char* name, int mproc, uint msz, uint mdsk)
{
	struct cont *nc;
	struct inode* rootdir;

	// Check if container name already exists
	if (name2cont(name))
		return -1;

	// Check if wanted resources surpass available
	// TODO: Change with maxmem() etc
	if (mproc > NPROC || msz > MAX_CONT_MEM || mdsk > MAX_CONT_DSK)
		return -1;

	// Allocate container.
	if ((nc = alloccont()) == 0)
		return -1;

	// Check if we are root
	if ((rootdir = namei(name)) == 0) {
		nc->state = CUNUSED;
		return -1;
	}

	// TODO: Do we need this? could cause a "sched
	// locks" problem if we acquire the ctable then
	// something calls Sched() before releasing
	acquire(&ctable.lock);
	nc->mproc = mproc;
	nc->msz = msz;
	nc->mdsk = mdsk;
	nc->rootdir = idup(rootdir);
	strncpy(nc->name, name, 16); // TODO: strlen(name) instead of 16?
	nc->state = CREADY;	
	release(&ctable.lock);	

	return 1;  
}

int
cstart(char* name) 
{		
	struct cont *nc;
	int i;
	struct inode* rootdir;
	uint udsk, mdsk;
	
	acquire(&ctable.lock);

	// Find container
	for (i = 0; i < NCONT; i++) {
		nc = &ctable.cont[i];
		if (strncmp(name, nc->name, strlen(name)) == 0 && nc->state == CREADY)
			goto found;
	}

	release(&ctable.lock);
	return -1;

found: 	

	rootdir = nc->rootdir;
	// TODO: use max mem instead of mdsk
	mdsk = nc->mdsk;

	release(&ctable.lock);	

	// Get current memory used in container folder	
	udsk = dirsize(rootdir, name);
	if((udsk) < 1 || mdsk < udsk)
	    return -1;

	acquire(&ctable.lock);
    nc->udsk = udsk;
	nc->state = CRUNNABLE;	
	release(&ctable.lock);	
	return nc->cid;
}

int 
cinfo(struct continfo* ci) 
{
	int i, k, j, l;
	struct cont *c;
	struct proc *p;

	j = 0;

	ci->root = myproc()->cont->cid == ROOTCONT;

	acquireptable();
	for(i = 0; i < NCONT; i++) {

		c = &ctable.cont[i];

		// If root container, fill all container information	
		// Else, fill only first ci->conts index
		if ((myproc()->cont->cid != ROOTCONT && myproc()->cont->cid != c->cid) || c->state == CUNUSED)
			continue;		 	

		ci->conts[j].msz = c->msz;
		ci->conts[j].mdsk = c->mdsk;
		ci->conts[j].mproc = c->mproc;
		ci->conts[j].usz = c->upg * PGSIZE;
		ci->conts[j].udsk = c->udsk;
		ci->conts[j].cid = c->cid;		
		ci->conts[j].state = c->state;
		safestrcpy(ci->conts[j].name, c->name, sizeof(c->name));			

	  	for (k = 0, l = 0; k < c->mproc; k++) {
	  
	  		p = &c->ptable[k]; 

	    	if(p->state == UNUSED)
		    	continue;

		 	ci->conts[j].procs[l].pid = p->pid;
		 	ci->conts[j].procs[l].ticks = p->ticks;
		 	ci->conts[j].procs[l].state = p->state;		   
		 	safestrcpy(ci->conts[j].procs[l].name, p->name, sizeof(p->name));			
		 	l++;		   
	    }

	    j++;
	}
	releaseptable();

	return 1;
}

int
cfork(int cid)
{
	struct cont* cont;

	if ((cont = cid2cont(cid)) == 0)
		return -1;

	return fork(cont);
}

int 			 
ckill(struct cont* c) 
{
	cprintf("Killing container %s\n", c->name);

	acquire(&ctable.lock);
	c->state = CSTOPPING;
	release(&ctable.lock);
	
	return 1;
}

static int 
cexit(struct cont* c)
{
	cprintf("Exiting container %s\n", c->name);
	acquire(&ctable.lock);
	c->name[0] = 0;
	c->msz = 0;
	c->mdsk = 0;
	c->mproc = 0;
	c->upg = 0;
	c->udsk = 0;
	c->rootdir = 0;
	c->nextproc = 0;
	c->cid = 0;
	c->state = CUNUSED;	
	release(&ctable.lock);

	return 1;
}

int 
cstop(char* name)
{
	struct cont *c;

	// Check if we are root
	if (myproc()->cont->cid != ROOTCONT) 
		return -1;

	// Check if container name already exists
	if ((c = name2cont(name)) == 0)
		return -1;

	if (c->state != CRUNNABLE)
		return -1;	

	return ckill(c);
}

int 
cpause(char* name)
{
	struct cont *c;

	// Check if we are root
	if (myproc()->cont->cid != ROOTCONT) 
		return -1;

	// Check if container name already exists
	if ((c = name2cont(name)) == 0)
		return -1;

	if (c->state != CRUNNABLE)
		return -1;
	
	acquire(&ctable.lock);
	c->state = CPAUSED;
	release(&ctable.lock);

	return 1;
}

int 
cresume(char* name)
{
	struct cont *c;	

	// Check if we are root
	if (myproc()->cont->cid != ROOTCONT) 
		return -1;

	// Check if container name already exists
	if ((c = name2cont(name)) == 0)
		return -1;

	if (c->state != CPAUSED)
		return -1;
	
	acquire(&ctable.lock);
	c->state = CRUNNABLE;
	release(&ctable.lock);

	return 1;
}

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

	int i, k, j;
	struct cont *c;
	struct proc *p;
	char *state;
	uint pc[10];

	acquireptable();

	for(i = 0; i < NCONT; i++) {

	  c = &ctable.cont[i];

	  if (c->state == CUNUSED)
	  	continue;      

	  cprintf("\nContainer %d: %s\n", c->cid, c->name);

	  for (k = 0; k < c->mproc; k++) {
	  
	  	p = &c->ptable[k]; 

	    if(p->state == UNUSED)
		    continue;
	    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
	      state = states[p->state];
	    else
	      state = "???";
	    cprintf("\t%d %s %s", p->pid, state, p->name);
	    if(p->state == SLEEPING){
	      getcallerpcs((uint*)p->context->ebp+2, pc);
	      for(j=0; j<10 && pc[j] != 0; j++)
	        cprintf(" %p", pc[j]);
	    }
	    cprintf("\n");
	  }
	}

	releaseptable();
}