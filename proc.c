#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"
#include "container.h"

static struct proc *initproc;

extern void forkret(void);
extern void trapret(void);

int nextpid = 1;

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
	struct cpu *c;
	struct proc *p;
	pushcli();
	c = mycpu();
	p = c->proc;
	popcli();
	return p;
}

// Look in the parentcont's process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
struct proc*
allocproc(struct cont *parentcont)
{
	struct proc *p;
	char *sp;
	struct proc *ptable;
	int nproc;

	if (parentcont->state != CRUNNABLE && parentcont->state != CRUNNING) 
		return 0;

	acquireptable();

	ptable = parentcont->ptable;
	nproc = parentcont->mproc;

	for(p = ptable; p < &ptable[nproc]; p++) 
		if(p->state == UNUSED)
			goto found;  

	releaseptable();
	return 0;

found:
	p->state = EMBRYO;
	p->pid = nextpid++;  

	releaseptable();  

	// Allocate kernel stack.
	if((p->kstack = kalloc()) == 0){
		p->state = UNUSED;
		return 0;
	}
	sp = p->kstack + KSTACKSIZE;

	// Leave room for trap frame.
	sp -= sizeof *p->tf;
	p->tf = (struct trapframe*)sp;

	// Set up new context to start executing at forkret,
	// which returns to trapret.
	sp -= 4;
	*(uint*)sp = (uint)trapret;

	sp -= sizeof *p->context;
	p->context = (struct context*)sp;
	memset(p->context, 0, sizeof *p->context);
	p->context->eip = (uint)forkret;

	p->ticks = 0;
	p->cont = parentcont;
	p->cont->uproc++;

	return p;
}

// Set up first user process for initial root container.
struct proc*
initprocess(struct cont* parentcont)
{  
	struct proc *p;
	extern char _binary_initcode_start[], _binary_initcode_size[];

	if ((p = allocproc(parentcont)) == 0) 
		panic("initprocess: failed to alloc initproc");

	if((p->pgdir = setupkvm()) == 0) 
		panic("initprocess: out of memory?");
	
	initproc = p;     
	inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);      
	memset(p->tf, 0, sizeof(*p->tf));
	p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
	p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
	p->tf->es = p->tf->ds;
	p->tf->ss = p->tf->ds;
	p->tf->eflags = FL_IF;
	p->tf->esp = PGSIZE;
	p->tf->eip = 0;  // beginning of initcode.S

	p->sz = PGSIZE;

	safestrcpy(p->name, "initcode", sizeof(p->name));
	p->cwd = idup(parentcont->rootdir);

	// Set initial process's cont to root
	p->cont = parentcont;

	// this assignment to p->state lets other cores
	// run this process. the acquire forces the above
	// writes to be visible, and the lock is also needed
	// because the assignment might not be atomic.
	acquireptable();

	p->state = RUNNABLE;

	releaseptable();

	return p;
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
	uint sz;
	struct proc *curproc = myproc();

	sz = curproc->sz;
	if(n > 0){
		if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
			return -1;
	} else if(n < 0){
		if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
			return -1;
	}
	curproc->sz = sz;
	switchuvm(curproc);
	return 0;
}

// If there is a parent cont
// Set new processes cwd, cont, and parent to be
// parentcont's rootdir, rootdir, and initproc.
// Else, create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
// Pass in 0 to exactly fork current process
int
fork(struct cont* parentcont)
{
	int i, pid;
	struct proc *np, *curproc, *parent;
	struct cont *cont;
	struct inode *cwd;

	curproc = myproc();

	if (parentcont == 0) {
		cwd = curproc->cwd;
		cont = curproc->cont;
		parent = curproc;
	} else {
		cwd = parentcont->rootdir;
		cont = parentcont;
		parent = initproc;
	}

	// Allocate process.
	if((np = allocproc(cont)) == 0){
		return -1;
	}

	// Copy process state from proc.
	if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
		kfree(np->kstack);
		np->kstack = 0;
		np->state = UNUSED;
		return -1;
	}
	np->sz = curproc->sz;
	np->parent = parent;
	*np->tf = *curproc->tf;

	// Clear %eax so that fork returns 0 in the child.
	np->tf->eax = 0;

	for(i = 0; i < NOFILE; i++)
		if(curproc->ofile[i])
			np->ofile[i] = filedup(curproc->ofile[i]);
	np->cwd = idup(cwd);

	safestrcpy(np->name, curproc->name, sizeof(curproc->name));

	pid = np->pid;

	acquireptable();
	np->state = RUNNABLE;
	releaseptable();

	return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
	struct proc *curproc = myproc();
	struct proc *p;
	struct proc *ptable;
	int fd, nproc;

	if(curproc == initproc)
		panic("init exiting");

	// Close all open files.
	for(fd = 0; fd < NOFILE; fd++){
		if(curproc->ofile[fd]){
			fileclose(curproc->ofile[fd]);
			curproc->ofile[fd] = 0;
		}
	}

	begin_op();
	iput(curproc->cwd);
	end_op();
	curproc->cwd = 0;

	acquireptable();

	ptable = curproc->cont->ptable;
	nproc = curproc->cont->mproc;

	// Parent might be sleeping in wait().
	wakeup1(curproc->parent);

	// Pass abandoned children to init.
	for(p = ptable; p < &ptable[nproc]; p++){
		if(p->parent == curproc){
			p->parent = initproc;
			if(p->state == ZOMBIE)
				wakeup1(initproc);
		}
	}

	curproc->cont->uproc--;

	// Jump into the scheduler, never to return.
	curproc->state = ZOMBIE;
	sched();
	panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
	struct proc *p;
	struct proc *ptable;
	int havekids, pid, nproc;
	struct proc *curproc = myproc();
	
	acquireptable();

	ptable = curproc->cont->ptable;
	nproc = curproc->cont->mproc;

	for(;;){
		// Scan through table looking for exited children.
		havekids = 0;
		for(p = ptable; p < &ptable[nproc]; p++){
			if(p->parent != curproc)
				continue;
			havekids = 1;
			if(p->state == ZOMBIE){
				// Found one.
				pid = p->pid;
				kfree(p->kstack);
				p->kstack = 0;
				freevm(p->pgdir);
				p->pid = 0;
				p->parent = 0;
				p->name[0] = 0;
				p->killed = 0;
				p->state = UNUSED;
				releaseptable();
				return pid;
			}
		}

		// No point waiting if we don't have any children.
		if(!havekids || curproc->killed){
			releaseptable();
			return -1;
		}

		// Wait for children to exit.  (See wakeup1 call in proc_exit.)
		sleep(curproc, ptablelock());  //DOC: wait-sleep
	}
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
	acquireptable();  //DOC: yieldlock
	myproc()->state = RUNNABLE;
	sched();
	releaseptable();
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
	static int first = 1;
	// Still holding ctablelock from scheduler.
	releaseptable();

	if (first) {    
		// Some initialization functions must be run in the context
		// of a regular process (e.g., they call sleep), and thus cannot
		// be run from main().
		first = 0;
		iinit(ROOTDEV);
		initlog(ROOTDEV);
	}

	// Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
	struct proc *p = myproc();
	
	if(p == 0)
		panic("sleep");

	if(lk == 0)
		panic("sleep without lk");  

	// Must acquire ctable.lock in order to
	// change p->state and then call sched.
	// Once we hold ctable.lock, we can be
	// guaranteed that we won't miss any wakeup
	// (wakeup runs with ctable.lock locked),
	// so it's okay to release lk.
	if(lk != ptablelock()){  //DOC: sleeplock0
		acquireptable();  //DOC: sleeplock1
		release(lk);
	}
	// Go to sleep.
	p->chan = chan;
	p->state = SLEEPING;

	sched();

	// Tidy up.
	p->chan = 0;

	// Reacquire original lock.
	if(lk != ptablelock()){  //DOC: sleeplock2
		releaseptable();
		acquire(lk);
	}
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
	acquireptable();
	wakeup1(chan);
	releaseptable();
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
	struct proc *p;
	struct proc *ptable;
	int nproc;

	acquireptable();

	ptable = myproc()->cont->ptable;
	nproc = myproc()->cont->mproc;

	for(p = ptable; p < &ptable[nproc]; p++){
		if(p->pid == pid){
			p->killed = 1;
			// Wake process from sleep if necessary.
			if(p->state == SLEEPING)
				p->state = RUNNABLE;
			releaseptable();
			return 0;
		}
	}
	releaseptable();
	return -1;
}
