/* membomb.c - allocate memory, 4KB at a time until malloc fails. */

#include "types.h"
#include "stat.h"
#include "user.h"

#define KB 1024
#define MB (KB * KB)
#define ALLOCMB 1
#define ALLOCSIZE (ALLOCMB * MB)

int
main(int argc, char *argv[])
{
  int totalmb = 0;
  char *p;

  printf(1, "membomb: started\n");
  while(1) {
    p = (char *) malloc(ALLOCSIZE);
    if (p == 0) {
      printf(1, "membomb: malloc() failed, exiting\n");
      exit();
    }    
    totalmb += ALLOCMB;

    printf(1, "membomb: total memory allocated: %d MB\n", totalmb);
  }

  exit();
}