/* ps.c - Shows the available running processes */

#include "types.h"
#include "stat.h"
#include "user.h"
#include "param.h"
#include "continfo.h"

int
main(int argc, char *argv[])
{  
  struct continfo *ci;
  struct cinfo c;
  int i;
  struct pinfo p;
  int k, numstates;
  char* state;

  ci = malloc(sizeof(*ci));

  if (cinfo(ci) != 1) {
	printf(1, "ps: failed to get container info\n");
	exit();
  }

  static char *states[] = {
    [PIUNUSED]    "unused",
    [PIEMBRYO]    "embryo",
    [PISLEEPING]  "sleep ",
    [PIRUNNABLE]  "runble",
    [PIRUNNING]   "run   ",
    [PIZOMBIE]    "zombie"
    };

  numstates = 6;

  ci = malloc(sizeof(*ci));

  if (cinfo(ci) != 1) {
    printf(1, "info: failed to get container info\n");
    exit();
  }

  for (i = 0; i < NCONT; i++) {
    c = ci->conts[i];
    if (c.state == CIUNUSED) 
      continue;

    printf(1, "Container %d (%s) processes:\n", c.cid, c.name);

    for (k = 0; k < c.mproc; k++) {

      p = c.procs[k]; 

      if(p.state == PIUNUSED)
        continue;

      if(p.state >= 0 && p.state < numstates && states[p.state])
        state = states[p.state];      
      else
        state = "???";

      printf(1, "\t%d %s %s\n", p.pid, state, p.name);
    } 
    printf(1, "\n");
  }

	exit();
}
