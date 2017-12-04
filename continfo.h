enum procinfostate { PIUNUSED, PIEMBRYO, PISLEEPING, PIRUNNABLE, PIRUNNING, PIZOMBIE };
enum continfostate { CIUNUSED, CIEMBRYO, CIREADY, CIRUNNABLE, CIPAUSED, CIRUNNING };

// Information of a process
struct pinfo {
 	enum procinfostate state;        // Process state
 	int pid;                     // Process ID
  	char name[16];               // Process name 
};

// Information of a single container
struct cinfo {
	uint msz;					// Max size of memory (bytes)
	uint mdsk;					// Max amount of disk space (bytes)
	int mproc;					// Max amount of processes	
	int usz;					// Used bytes of memory
	uint udsk;					// Used disk space (bytes)
	int cid;					// Container ID
	enum continfostate state;		// State of container
	char name[16];          	// Container name		
	struct pinfo procs[NPROC];	// Current running processes
};

// Array of container infos
struct continfo {
	struct cinfo conts[NCONT];
	int root;					// 1 if requested cinfo as root
};

