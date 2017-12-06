/* forkbomb.c - fork processes until fork fails. */

#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
  int i = 0;
  int id;

  printf(1, "forkbomb: started\n");
  while(1) {
    id = fork();
    if (id < 0) {
      printf(1, "forkbomb: fork() failed, exiting\n");
      exit();
    }

    if (id == 0) {
      /* In child, just loop forever. Use sleep so that we don't consume CPU */
      while (1) {
        sleep(10);
      }
    }

    i += 1;
    printf(1, "forkbomb: fork count = %d\n", i);
  }

  exit();
}