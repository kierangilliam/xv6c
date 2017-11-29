#include "types.h"
#include "stat.h"
#include "user.h"
#include "param.h"
#include "fcntl.h" 

#define CONT_MAX_MEM  1024
#define CONT_MAX_PROC 8
#define CONT_MAX_DISK 1024

// TODO: Clean up tab space formatting of modified files
// TODO: Rewrite comments on proc.c, comment container.c

void 
usage(char* usage) 
{
    printf(1, "usage: ctool %s\n", usage);
    exit();
}

// Modified implementation of 
// https://stackoverflow.com/
// questions/33792754/
// in-c-on-linux-how-would-you-implement-cp
int
cp(char* dst, char* file)
{  
  char buffer[1024];
  int files[2];
  int count;
  int pathsize = strlen(dst) + strlen(file) + 2; // dst.len + '\' + src.len + \0
  char path[pathsize]; 

  memmove(path, dst, strlen(dst));
  memmove(path + strlen(dst), "/", 1);
  memmove(path + strlen(dst) + 1, file, strlen(file));
  memmove(path + strlen(dst) + 1 + strlen(file), "\0", 1);

  printf(1, "path created %s\n", path);

  files[0] = open(file, O_RDONLY);
  if (files[0] == -1) // Check if file opened 
      return -1;
  files[1] = open(path, O_WRONLY | O_CREATE);
  if (files[1] == -1) { // Check if file opened (permissions problems ...) 
      close(files[0]);
      return -1;
  }

  while ((count = read(files[0], buffer, sizeof(buffer))) != 0)
      write(files[1], buffer, count);

  return 1;
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
  int i, k, progc, last_flag = 2, // No flags
  mproc = CONT_MAX_PROC, 
  msz = CONT_MAX_MEM, 
  mdsk = CONT_MAX_DISK;  

  if (argc < 4)
    usage("create <name> [-p <max_processes>] [-m <max_memory>] [-d <max_disk>] prog [prog2.. ]");


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

  progc = argc - last_flag - 1;

  for (i = last_flag + 1, k = 0; i < argc; i++, k++) {
    printf(1, "%s", argv[i]);

    // TODO: move this into the kernel or the rest of ccreate out of the kernel
    cp(argv[2], argv[i]);
    
    // If we were using kernel for ccreate sys call
    progv[k] = malloc(sizeof(argv[i])); memmove(progv[k], argv[i], sizeof(argv[i])); memmove(progv[k] + sizeof(argv[i]), "\0", 1); printf(1, "\t%s\n", progv[k]);
  }  


  printf(1, "name: %s\nmproc: %d\nmsz: %d\nmdsk: %d\nprogc: %d\n", argv[2], mproc, msz, mdsk, progc);

  if (ccreate(argv[2], progv, progc, mproc, msz, mdsk) == 1) {
    printf(1, "Created container %s\n", argv[2]); 
  } else {
    printf(1, "Failed to create container %s\n", argv[2]); 
  }
}

// ctool start <name> prog arg1 [arg2 ...]
// ctool start c1 echoloop ab
void
start(int argc, char *argv[])
{    

  if (argc < 4)
    usage("ctool start <name> prog arg1 [arg2 ...]");
}

void
pause(int argc, char *argv[])
{
  
}

void
resume(int argc, char *argv[])
{
  
}

void
stop(int argc, char *argv[])
{
  
}

void
info(int argc, char *argv[])
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
