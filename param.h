#define NCONT         8  // maximum number of containers
#define NPROC        64  // maximum number of processes per container
#define KSTACKSIZE 4096  // size of per-process kernel stack
#define NCPU          8  // maximum number of CPUs
#define NOFILE       16  // open files per process
#define NFILE       100  // open files per system
#define NINODE       50  // maximum number of active i-nodes
#define NDEV         10  // maximum major device number
#define ROOTDEV       1  // device number of file system root disk
#define MAXARG       32  // max exec arguments
#define MAXOPBLOCKS  10  // max # of blocks any FS op writes
#define LOGSIZE      (MAXOPBLOCKS*3)  // max data blocks in on-disk log
#define NBUF         (MAXOPBLOCKS*3)  // size of disk block cache
#define FSSIZE   100000  // size of file system in blocks
#define ROOTCONT	   1
#define MAX_CONT_MEM   NPROC*4096*1024 // max memory a container can use (256 mb)
#define MAX_CONT_DSK   NPROC*1024*4096 // max amount of disk space a container can use (256mb)