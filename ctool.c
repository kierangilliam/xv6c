#include "types.h"
#include "stat.h"
#include "user.h"
#include "param.h"
#include "fcntl.h" 

/* 
Tests:
ctool create ctest1 -p 4 sh ps cat echoloop
ctool start ctest1 echoloop ab
*/ 

// TODO: do a giant diff on xv6 and xv6c to find all differences
// TODO: Clean up tab space formatting of modified files
// TODO: Rewrite comments on proc.c, comment container.c
// TODO: try tickstest()

void 
usage(char* usage) 
{
    printf(1, "usage: ctool %s\n", usage);
    exit();
}

// Modified implementation of 
// https://stackoverflow.com/questions/33792754/in-c-on-linux-how-would-you-implement-cp
int
cp(char* dst, char* file)
{  
  char buffer[1024];
  int files[2];
  int count;
  int pathsize = strlen(dst) + strlen(file) + 2; // dst.len + '/' + src.len + \0
  char path[pathsize]; 

  memmove(path, dst, strlen(dst));
  memmove(path + strlen(dst), "/", 1);
  memmove(path + strlen(dst) + 1, file, strlen(file));
  memmove(path + strlen(dst) + 1 + strlen(file), "\0", 1);

  files[0] = open(file, O_RDONLY);
  if (files[0] == -1) // Check if file opened 
      return -1;
  
  files[1] = open(path, O_WRONLY | O_CREATE);
  if (files[1] == -1) { // Check if file opened (permissions problems ...) 
    printf(1, "failed to create file |%s|\n", path);
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

// ctool create ctest1 -p 4 sh ps cat echoloop
void
create(int argc, char *argv[])
{
  int i, k, last_flag = 2, // No flags
  mproc = MAX_CONT_PROC, 
  msz = MAX_CONT_MEM, 
  mdsk = MAX_CONT_DSK;  

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

  mkdir(argv[2]);

  for (i = last_flag + 1, k = 0; i < argc; i++, k++) {
    if (cp(argv[2], argv[i]) != 1) 
      printf(1, "Failed to copy %s into folder %s. Continuing...\n", argv[i], argv[2]);
  }  

  if (ccreate(argv[2], mproc, msz, mdsk) == 1) {
    printf(1, "Created container %s\n", argv[2]); 
  } else {
    printf(1, "Failed to create container %s\n", argv[2]); 
  }  
}

// ctool start <name> prog arg1 [arg2 ...]
void
start(int argc, char *argv[])
{    

  char *args[MAXARG];
  int i, k;

  if (argc < 4)
    usage("ctool start <name> prog arg1 [arg2 ...]");

  for (i = 3, k = 0; i < argc; i++, k++) {
    args[k] = malloc(strlen(argv[i]) + 1);     
    memmove(args[k], argv[i], strlen(argv[i])); 
    memmove(args[k] + strlen(argv[i]), "\0", 1);
  }

  if (cstart(argv[2], args, (argc - 3)) != 1) 
    printf(1, "Failed to start container %s\n", argv[2]);     
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
