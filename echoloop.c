#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
  int i;
  int ticks;

  if (argc < 3) {
  	printf(1, "usage: echoloop ticks arg1 [arg2 ...]\n");
  	exit();
  }

  ticks = atoi(argv[1]);

  while(1){
	  for(i = 2; i < argc; i++)
    	printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
    sleep(ticks);
  }

  exit();
}
