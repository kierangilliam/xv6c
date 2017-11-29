#include "types.h"
#include "defs.h"
#include "container.h"
#include "spinlock.h"
#include "param.h"
#include "stat.h"
//#include "memlayout.h"
//#include "mmu.h"
//#include "x86.h"

struct {
  struct spinlock lock;
  struct cont cont[NCONT];
} ctable;

struct cont currcont;

int nextcid = 1;

// TODO: call this somewhere
void
cinit(void)
{
  initlock(&ctable.lock, "ctable");
}

struct cont*
mycont(void) {
	return &currcont;
}

struct cont* 	
rootcont(void) {
	struct cont *c;
	// TODO: Check to make sure it always inits at first index
  	acquire(&ctable.lock);  
  	c = &ctable.cont[0];
  	release(&ctable.lock);
  	return c;
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

/* Moves file src to folder dst 
TODO: Implement */
int
movefile(char* dst, char* src) {
	
	int pathsize = sizeof(dst) + sizeof(src) + 2; // dst.len + '\' + src.len + \0
	char path[pathsize]; 
	// struct file *f;
	// struct inode *ip;

	memmove(path, dst, strlen(dst));
	memmove(path + strlen(dst), "/", 1);
	memmove(path + strlen(dst) + 1, src, strlen(src));
	memmove(path + strlen(dst) + 1 + strlen(src), "\0", 1);

	cprintf("movefile path: %s\n", path);

	// begin_op();
	
	// ip = create(path, T_FILE, 0, 0);
	// if(ip == 0){
 //  		end_op();
 //  		cprintf("movefile: Error opening file %s\n", path);
 //  		return -1;
	// } 

	// if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
	// 	if(f)
	// 	  fileclose(f);
	// 	iunlockput(ip);
	// 	end_op();
	// 	cprintf("movefile: Error allocating file %s\n", path);
	// 	return -1;
	// }
	// iunlock(ip);
	// end_op();

	// f->type = FD_INODE;
	// f->ip = ip;
	// f->off = 0;
	// f->readable = !(O_CREATE & O_WRONLY);
	// f->writable = (O_CREATE & O_WRONLY) || (O_CREATE & O_RDWR);

	// // Copy contents of src into new file
	// char* source;
	// fileread();	


	return 1;
}

int 
ccreate(char* name, char* progv[MAXARG], int progc, int mproc, uint msz, uint mdsk)
{
	int i;
	struct cont *nc;
	struct inode *rootdir;

	// Allocate container.
	if ((nc = alloccont()) == 0) {
		return -1;
	}

	// Create a directory (same implementation as sys_mkdir)	
	// TODO: check if container exists
	begin_op();
	if((rootdir = create(name, T_DIR, 0, 0)) == 0){
		end_op();
		cprintf("Unable to create container directory %s\n", name);
		return -1;
	}
	iunlockput(rootdir);
	end_op();	

	// Move files into folder
	for (i = 0; i < progc; i++) {
		if (movefile(name, progv[i]) == 0) 
			cprintf("Unable to move file %s\n", progv[i]);
	}

	acquire(&ctable.lock);
	nc->mproc = mproc;
	nc->msz = msz;
	nc->mdsk = mdsk;
	nc->rootdir = rootdir;
	nc->procs = malloc(sizeof(struct proc *) * mproc);
	// TODO: Possibly malloc each proc? and set to unused like normal ptable?
	strncpy(nc->name, name, 16);
	nc->state = CRUNNABLE;	
	release(&ctable.lock);	

	return 1;  
}

void
cstart(char* name, int argc, char** argv) 
{
	// Attach to a vc 
	// argv is program plus arguments
	// Check if RUNNABLE
	// <name> prog arg1 [arg2 ...]
	// acquire(&ctable.lock);
	// nc->state = CRUNNING;		
	// release(&ctable.lock);	
}



