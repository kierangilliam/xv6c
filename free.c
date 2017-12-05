/* free.c - Shows the available and used memory */

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

	ci = malloc(sizeof(*ci));
	
	if (cinfo(ci) != 1) {
		printf(1, "free: failed to get container info\n");
		exit();
	}

	// TODO: CHANGE TO ONLY SHOW FIRST CONTAINER (need to set root max mem and dsk to global max mem and disk)
	// We would have access to more than one container if we were the root
	// Not in root, it should only show the available and used memory within a container
	for (i = 0; i < NCONT; i++) {
		c = ci->conts[i];

		if (c.state == CIUNUSED) 
			continue;

		printf(1, "Container %d: %s\n", c.cid, c.name);
		printf(1, "\tMemory: %dkb/%dmb (Used/ Available)\n", c.usz/1024, c.msz/1024/1024);
	}

	exit();
}
