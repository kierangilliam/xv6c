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

enum contstate { CUNUSED, CEMBRYO, CREADY, CRUNNABLE, CRUNNING, CPAUSED, CSTOPPING };
				 // CUNUSED:   Ready to allocate
				 // CEMBRYO:   Allocated, ready to be created
				 // CREADY:    Ready to start
				 // CRUNNABLE: Ready to be scheduled
				 // CRUNNING:  Currently running container
				 // CPAUSED:   Paused, will resume as CRUNNABLE
				 // CSTOPPING: Run processes until all are UNUSED

struct cont {
	uint msz;					// Max size of memory (bytes)
	uint mdsk;					// Max amount of disk space (bytes)
	int mproc;					// Max amount of processes	
	int upg;					// Used pages of memory
	uint udsk;					// Used disk space (blocks)
	int uproc;					// Used processes
	int cid;					// Container ID
	struct inode *rootdir;		// Root directory
	enum contstate state;		// State of container
	char name[16];          	// Container name
	struct proc *ptable;		// Table of processes owned by container
	int nextproc;				// Next proc to sched 	
};
