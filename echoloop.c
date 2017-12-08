#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
  int i;
  int ticks, program_length;

  if (argc < 3) {
  	printf(1, "usage: echoloop sleep_ticks program_length arg1 [arg2 ...]\n");
  	exit();
  }

  ticks = atoi(argv[1]);
  program_length = atoi(argv[2]);  

  while(program_length > 0){
	  for(i = 3; i < argc; i++)
    	printf(1, "%s%s", argv[i], i+1 < argc ? " " : "\n");
    sleep(ticks);
    program_length--;
  }

  exit();
}
