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

	ci = malloc(sizeof(*ci));
	
	if (cinfo(ci) != 1) {
		printf(1, "ps: failed to get container info\n");
		exit();
	}

	// We would have access to more than one container if we were the root
	// Not in root, it should only show the available and used memory within a container
	for (i = 0; i < NCONT; i++) {
		c = ci->conts[i];
		if (c.state == CIUNUSED) 
			continue;

		printf(1, "Container %d: %s\n", c.cid, c.name);
		printf(1, "\tDisk: %dkb/%dkb/%dmb (Used/ Available/ Max)\n", c.udsk/1024, (c.mdsk/1024 - c.udsk/1024), c.mdsk/1024/1024);
	}

	exit();
}
