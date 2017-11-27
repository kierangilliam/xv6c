/* vctest.c - test virtual consoles */

#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int
main(int argc, char *argv[])
{
  int fd, id;

  if (argc < 3) {
    printf(1, "usage: vctest <vc> <cmd> [<arg> ...]\n");
    exit();
  }

  fd = open(argv[1], O_RDWR);
  printf(1, "fd = %d\n", fd);

  /* fork a child and exec argv[1] */
  id = fork();

  if (id == 0){
    close(0);
    close(1);
    close(2);
    dup(fd);
    dup(fd);
    dup(fd);
    exec(argv[2], &argv[2]);
    exit();
  }

  printf(1, "%s started on vc0\n", argv[1]);

  exit();
}
