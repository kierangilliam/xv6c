xv6c
===================

xv6c aims to containerize xv6 to provide resource and process isolation. Containers can be manipulated with the administrative user level program `ctool`. Containers ensure that processes not inside the root container can touch other processes (for example, piping and killing). Further, a process running in folder `X` cannot access memory outside of its folder. xv6c also ensures that containers don't exceed their resource limits. If they do, they are killed.

----------
Usage
-------------
####Creating a container:
		ctool create <name> -p <max proc> -d <max disk> -m <max mem> [program 1 ... program N]
The user specifies what they would like to name the container. This name is also the directory in which the container will live. The user also specifies what files will be copied into the directory, the maximum number of processes, disk space, and memory it can use.

####Starting a container:
		ctool start <virtual console> <name> <program> [arg 1 ... arg N]
The user gives a name of a container to run. The user also specifies what virtual console to attach it to (which can be reached with ^T in the shell) and the program to run. 

####Pausing, resuming, and stopping a container:
		ctool (pause || resume || stop) <name>
The user can pause, resume, or stop a given container. Pausing and resuming toggles whether or not a container can run. Stopping kills a container and all of its processes. 

----------

Process and Resource Isolation
-------------------
####Processes
Each container has their own isolated process table. This implementation choice allowed me to leave  `proc.c` largely unaltered. In xv6c, processes are seen as a subclass of containers. Because of this, processes have no way of interacting (i.e. piping to or killing) with other processes. 
>**Note:** Even the root container cannot touch other container's processes. To kill a process, the root must kill an entire container. 

####Memory and Disk
Containers track the amount of memory and disk space used by counting the number of pages or blocks allocated and freed. In `kalloc()`, a container's used pages variable, `upg`, is incremented. In `kfree()`, it is decremented. `balloc()` and `bfree()` do the same but, instead, track the container's used disk variable `udsk`. Containers are killed if they try to allocate more resources than their allowance set in `ccreate()`. 
>**Note:** A more elegant approach may be to sleep the process trying to allocate over the resource limits until resources are freed by a different process in the container.

> **Disk Isolation: Namex()** Disk access is restricted in `fs.c` with the method `namex()`. When traversing the provided path, `namex()` ensures that no non-root containers can access the root `inode`. Any attempts are ignored and default to staying inside of the container's top level directory.

----------

Future Changes
-------------

####Changes to Creating and Starting
I would start off by moving the declaration of max memory, disk space, and processes to starting a container. This way, `ctool create` will be more of a way of creating an image for a container, and `ctool start` will be the first system call made that actually modifies the kernel. 
>**Further Reasoning** 
Imagine a user who creates, starts, then stops a container. If they want to start a different container on that same folder, they can't. Similarly, a user who shuts down their computer while a container cannot run another container on the same folder. In these two scenarios, a user would have to remove the folder from disk and create another container before starting a new one with the same name.	
	
####Better disk space and memory enforcement
The macros `MAX_CONT_MEM` and `MAX_CONT_DSK` in `param.h` can be replaced with the methods `maxmem()` and `maxdsk()`. These would return the current maximum free memory and disk space used. As they are now, the macros permit, for example, a container to start with `MAX_CONT_DSK` despite there being less than `MAX_CONT_DSK` space left. This could lead to a kernel panic if the container tried to allocate the entire max disk limits permitted to them. 
	
####Resource scheduling & sleeping processes on kalloc() and balloc():
As discussed in the resource isolation section, sleeping a process that tries to `kalloc()` or `balloc()` past their containers limits would be a more elegant than killing the container. However, steps would have to be made to ensure that a deadlock does not arise from every process sleeping for memory. 