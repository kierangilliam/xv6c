
#define ROOTCONT 0

enum contstate { CUNUSED, CEMBRYO, CRUNNABLE, CPAUSED, CRUNNING };

struct ptable {
  struct spinlock lock;
  struct proc proc[NPROC];
};

struct cont {
	uint msz;				// Max size of memory (bytes)
	uint mdsk;				// Max amount of disk space (bytes)
	int mproc;				// Max amount of processes	
	int cid;				// Container ID
	struct inode *rootdir;	// Root directory
	enum contstate state;	// State of container
	char name[16];          // Container name
	struct ptable *ptable;	// Table of processes owned by container
	int nextproc;			// Next proc to sched TODO: change or make more elegant
};