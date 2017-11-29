// Per-CPU state
struct cpu {
  uchar apicid;                // Local APIC ID
  struct context *scheduler;   // swtch() here to enter scheduler
  struct taskstate ts;         // Used by x86 to find stack for interrupt
  struct segdesc gdt[NSEGS];   // x86 global descriptor table
  volatile uint started;       // Has the CPU started?
  int ncli;                    // Depth of pushcli nesting.
  int intena;                  // Were interrupts enabled before pushcli?
  struct proc *proc;           // The process running on this cpu or null
};

extern struct cpu cpus[NCPU];
extern int ncpu;

#define ROOTCONT       1
#define MAX_CONT_MEM   4096
#define MAX_CONT_DSK   4096
#define MAX_CONT_PROC  64

enum contstate { CUNUSED, CEMBRYO, CRUNNABLE, CPAUSED, CRUNNING };

// TODO: maybe remove cid?
struct cont {
	uint msz;					// Max size of memory (bytes)
	uint mdsk;					// Max amount of disk space (bytes)
	int mproc;					// Max amount of processes	
	int cid;					// Container ID
	struct inode *rootdir;		// Root directory
	enum contstate state;		// State of container
	char name[16];          	// Container name
	struct proc *ptable;		// Table of processes owned by container
	int nextproc;				// Next proc to sched TODO: change or make more elegant
};

