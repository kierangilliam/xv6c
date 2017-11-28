#include "types.h"
#include "stat.h"
#include "user.h"
#include "param.h"
//#include "fcntl.h" // RDOWNLY

#define CONT_MAX_MEM  1024
#define CONT_MAX_PROC 8
#define CONT_MAX_DISK 1024

void 
usage(char* usage) 
{
    printf(1, "usage: ctool %s\n", usage);
    exit();
}

int
max(int a, int b)
{
  if (a > b)
    return a;
  else
    return b;
}

// ctool create ctest1 -p 4 sh ps cat echo
// folder/ container name, what to copy into folder
// mkdir, cp file 1, cp file n  
void
create(int argc, char *argv[])
{
  char *progv[32];
  int i, last_flag, progc, 
  mproc = CONT_MAX_PROC, 
  msz = CONT_MAX_MEM, 
  mdsk = CONT_MAX_DISK;  

  if (argc < 4)
    usage("create <name> [-p <max_processes>] [-m <max_memory>] [-d <max_disk>] prog [prog2.. ]");

  last_flag = 2; // No flags

  for (i = 0; i < argc; i++) {
    if (strcmp(argv[i], "-p") == 0) {
      last_flag = max(last_flag, i + 1);
      mproc = atoi(argv[i + 1]);
    }
    if (strcmp(argv[i], "-m") == 0) {
      last_flag = max(last_flag, i + 1);
      msz = atoi(argv[i + 1]);
    }
    if (strcmp(argv[i], "-d") == 0) {
      last_flag = max(last_flag, i + 1);
      mdsk = atoi(argv[i + 1]);
    }
  }

  printf(1, "argc: %d, last_flag: %d\n", argc, last_flag);
  progc = argc - last_flag - 1;

//  *progv = malloc(progc * sizeof(char*));

  int k;

  //progv = malloc(sizeof(char*) * progc);

  for (i = last_flag + 1, k = 0; i < argc; i++, k++) {
    printf(1, "%s", argv[i]);
    
    progv[k] = malloc(sizeof(argv[i]));
    memmove(progv[k], argv[i], sizeof(argv[i]));
    memmove(progv[k] + sizeof(argv[i]), "\0", 1);
    printf(1, "\t%s\n", progv[k]);
  }

  printf(1, "name: %s\nmproc: %d\nmsz: %d\nmdsk: %d\nprogc: %d\n", argv[2], mproc, msz, mdsk, progc);

  if (ccreate(argv[2], progv, progc, mproc, msz, mdsk) == 1) {
    printf(1, "Created container %s\n", argv[2]); 
  } else {
    printf(1, "Failed to create container %s\n", argv[2]); 
  }
}

void
start(int argc, char *argv[])
{
  // ctool start vc0 c1 sh
                  // (optional) max proc, max mb of memory, max disk space   
  // ctool start vc0 c1 sh 8 10 5  
  // ctool start <name> prog arg1 [arg2 ...]
}

void
pause()
{
  
}

void
resume()
{
  
}

void
stop()
{
  
}

void
info()
{
  
}

int
main(int argc, char *argv[])
{

  if (argc < 3) {
    usage("<tool> <cmd> [<arg> ...]");
    exit();
  }

  if (strcmp(argv[1], "create") == 0)
    create(argc, argv);
  else if (strcmp(argv[1], "start") == 0)
    start(argc, argv);
  else 
    printf(1, "ctool: command not found.\n");   

  exit();
}
