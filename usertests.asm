
_usertests:     file format elf32-i386


Disassembly of section .text:

00000000 <iputtest>:
int stdout = 1;

// does chdir() call iput(p->cwd) in a transaction?
void
iputtest(void)
{
       0:	55                   	push   %ebp
       1:	89 e5                	mov    %esp,%ebp
       3:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "iput test\n");
       6:	a1 bc 64 00 00       	mov    0x64bc,%eax
       b:	c7 44 24 04 52 45 00 	movl   $0x4552,0x4(%esp)
      12:	00 
      13:	89 04 24             	mov    %eax,(%esp)
      16:	e8 5a 41 00 00       	call   4175 <printf>

  if(mkdir("iputdir") < 0){
      1b:	c7 04 24 5d 45 00 00 	movl   $0x455d,(%esp)
      22:	e8 09 40 00 00       	call   4030 <mkdir>
      27:	85 c0                	test   %eax,%eax
      29:	79 1a                	jns    45 <iputtest+0x45>
    printf(stdout, "mkdir failed\n");
      2b:	a1 bc 64 00 00       	mov    0x64bc,%eax
      30:	c7 44 24 04 65 45 00 	movl   $0x4565,0x4(%esp)
      37:	00 
      38:	89 04 24             	mov    %eax,(%esp)
      3b:	e8 35 41 00 00       	call   4175 <printf>
    exit();
      40:	e8 83 3f 00 00       	call   3fc8 <exit>
  }
  if(chdir("iputdir") < 0){
      45:	c7 04 24 5d 45 00 00 	movl   $0x455d,(%esp)
      4c:	e8 e7 3f 00 00       	call   4038 <chdir>
      51:	85 c0                	test   %eax,%eax
      53:	79 1a                	jns    6f <iputtest+0x6f>
    printf(stdout, "chdir iputdir failed\n");
      55:	a1 bc 64 00 00       	mov    0x64bc,%eax
      5a:	c7 44 24 04 73 45 00 	movl   $0x4573,0x4(%esp)
      61:	00 
      62:	89 04 24             	mov    %eax,(%esp)
      65:	e8 0b 41 00 00       	call   4175 <printf>
    exit();
      6a:	e8 59 3f 00 00       	call   3fc8 <exit>
  }
  if(unlink("../iputdir") < 0){
      6f:	c7 04 24 89 45 00 00 	movl   $0x4589,(%esp)
      76:	e8 9d 3f 00 00       	call   4018 <unlink>
      7b:	85 c0                	test   %eax,%eax
      7d:	79 1a                	jns    99 <iputtest+0x99>
    printf(stdout, "unlink ../iputdir failed\n");
      7f:	a1 bc 64 00 00       	mov    0x64bc,%eax
      84:	c7 44 24 04 94 45 00 	movl   $0x4594,0x4(%esp)
      8b:	00 
      8c:	89 04 24             	mov    %eax,(%esp)
      8f:	e8 e1 40 00 00       	call   4175 <printf>
    exit();
      94:	e8 2f 3f 00 00       	call   3fc8 <exit>
  }
  if(chdir("/") < 0){
      99:	c7 04 24 ae 45 00 00 	movl   $0x45ae,(%esp)
      a0:	e8 93 3f 00 00       	call   4038 <chdir>
      a5:	85 c0                	test   %eax,%eax
      a7:	79 1a                	jns    c3 <iputtest+0xc3>
    printf(stdout, "chdir / failed\n");
      a9:	a1 bc 64 00 00       	mov    0x64bc,%eax
      ae:	c7 44 24 04 b0 45 00 	movl   $0x45b0,0x4(%esp)
      b5:	00 
      b6:	89 04 24             	mov    %eax,(%esp)
      b9:	e8 b7 40 00 00       	call   4175 <printf>
    exit();
      be:	e8 05 3f 00 00       	call   3fc8 <exit>
  }
  printf(stdout, "iput test ok\n");
      c3:	a1 bc 64 00 00       	mov    0x64bc,%eax
      c8:	c7 44 24 04 c0 45 00 	movl   $0x45c0,0x4(%esp)
      cf:	00 
      d0:	89 04 24             	mov    %eax,(%esp)
      d3:	e8 9d 40 00 00       	call   4175 <printf>
}
      d8:	c9                   	leave  
      d9:	c3                   	ret    

000000da <exitiputtest>:

// does exit() call iput(p->cwd) in a transaction?
void
exitiputtest(void)
{
      da:	55                   	push   %ebp
      db:	89 e5                	mov    %esp,%ebp
      dd:	83 ec 28             	sub    $0x28,%esp
  int pid;

  printf(stdout, "exitiput test\n");
      e0:	a1 bc 64 00 00       	mov    0x64bc,%eax
      e5:	c7 44 24 04 ce 45 00 	movl   $0x45ce,0x4(%esp)
      ec:	00 
      ed:	89 04 24             	mov    %eax,(%esp)
      f0:	e8 80 40 00 00       	call   4175 <printf>

  pid = fork();
      f5:	e8 c6 3e 00 00       	call   3fc0 <fork>
      fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid < 0){
      fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     101:	79 1a                	jns    11d <exitiputtest+0x43>
    printf(stdout, "fork failed\n");
     103:	a1 bc 64 00 00       	mov    0x64bc,%eax
     108:	c7 44 24 04 dd 45 00 	movl   $0x45dd,0x4(%esp)
     10f:	00 
     110:	89 04 24             	mov    %eax,(%esp)
     113:	e8 5d 40 00 00       	call   4175 <printf>
    exit();
     118:	e8 ab 3e 00 00       	call   3fc8 <exit>
  }
  if(pid == 0){
     11d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     121:	0f 85 83 00 00 00    	jne    1aa <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
     127:	c7 04 24 5d 45 00 00 	movl   $0x455d,(%esp)
     12e:	e8 fd 3e 00 00       	call   4030 <mkdir>
     133:	85 c0                	test   %eax,%eax
     135:	79 1a                	jns    151 <exitiputtest+0x77>
      printf(stdout, "mkdir failed\n");
     137:	a1 bc 64 00 00       	mov    0x64bc,%eax
     13c:	c7 44 24 04 65 45 00 	movl   $0x4565,0x4(%esp)
     143:	00 
     144:	89 04 24             	mov    %eax,(%esp)
     147:	e8 29 40 00 00       	call   4175 <printf>
      exit();
     14c:	e8 77 3e 00 00       	call   3fc8 <exit>
    }
    if(chdir("iputdir") < 0){
     151:	c7 04 24 5d 45 00 00 	movl   $0x455d,(%esp)
     158:	e8 db 3e 00 00       	call   4038 <chdir>
     15d:	85 c0                	test   %eax,%eax
     15f:	79 1a                	jns    17b <exitiputtest+0xa1>
      printf(stdout, "child chdir failed\n");
     161:	a1 bc 64 00 00       	mov    0x64bc,%eax
     166:	c7 44 24 04 ea 45 00 	movl   $0x45ea,0x4(%esp)
     16d:	00 
     16e:	89 04 24             	mov    %eax,(%esp)
     171:	e8 ff 3f 00 00       	call   4175 <printf>
      exit();
     176:	e8 4d 3e 00 00       	call   3fc8 <exit>
    }
    if(unlink("../iputdir") < 0){
     17b:	c7 04 24 89 45 00 00 	movl   $0x4589,(%esp)
     182:	e8 91 3e 00 00       	call   4018 <unlink>
     187:	85 c0                	test   %eax,%eax
     189:	79 1a                	jns    1a5 <exitiputtest+0xcb>
      printf(stdout, "unlink ../iputdir failed\n");
     18b:	a1 bc 64 00 00       	mov    0x64bc,%eax
     190:	c7 44 24 04 94 45 00 	movl   $0x4594,0x4(%esp)
     197:	00 
     198:	89 04 24             	mov    %eax,(%esp)
     19b:	e8 d5 3f 00 00       	call   4175 <printf>
      exit();
     1a0:	e8 23 3e 00 00       	call   3fc8 <exit>
    }
    exit();
     1a5:	e8 1e 3e 00 00       	call   3fc8 <exit>
  }
  wait();
     1aa:	e8 21 3e 00 00       	call   3fd0 <wait>
  printf(stdout, "exitiput test ok\n");
     1af:	a1 bc 64 00 00       	mov    0x64bc,%eax
     1b4:	c7 44 24 04 fe 45 00 	movl   $0x45fe,0x4(%esp)
     1bb:	00 
     1bc:	89 04 24             	mov    %eax,(%esp)
     1bf:	e8 b1 3f 00 00       	call   4175 <printf>
}
     1c4:	c9                   	leave  
     1c5:	c3                   	ret    

000001c6 <openiputtest>:
//      for(i = 0; i < 10000; i++)
//        yield();
//    }
void
openiputtest(void)
{
     1c6:	55                   	push   %ebp
     1c7:	89 e5                	mov    %esp,%ebp
     1c9:	83 ec 28             	sub    $0x28,%esp
  int pid;

  printf(stdout, "openiput test\n");
     1cc:	a1 bc 64 00 00       	mov    0x64bc,%eax
     1d1:	c7 44 24 04 10 46 00 	movl   $0x4610,0x4(%esp)
     1d8:	00 
     1d9:	89 04 24             	mov    %eax,(%esp)
     1dc:	e8 94 3f 00 00       	call   4175 <printf>
  if(mkdir("oidir") < 0){
     1e1:	c7 04 24 1f 46 00 00 	movl   $0x461f,(%esp)
     1e8:	e8 43 3e 00 00       	call   4030 <mkdir>
     1ed:	85 c0                	test   %eax,%eax
     1ef:	79 1a                	jns    20b <openiputtest+0x45>
    printf(stdout, "mkdir oidir failed\n");
     1f1:	a1 bc 64 00 00       	mov    0x64bc,%eax
     1f6:	c7 44 24 04 25 46 00 	movl   $0x4625,0x4(%esp)
     1fd:	00 
     1fe:	89 04 24             	mov    %eax,(%esp)
     201:	e8 6f 3f 00 00       	call   4175 <printf>
    exit();
     206:	e8 bd 3d 00 00       	call   3fc8 <exit>
  }
  pid = fork();
     20b:	e8 b0 3d 00 00       	call   3fc0 <fork>
     210:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid < 0){
     213:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     217:	79 1a                	jns    233 <openiputtest+0x6d>
    printf(stdout, "fork failed\n");
     219:	a1 bc 64 00 00       	mov    0x64bc,%eax
     21e:	c7 44 24 04 dd 45 00 	movl   $0x45dd,0x4(%esp)
     225:	00 
     226:	89 04 24             	mov    %eax,(%esp)
     229:	e8 47 3f 00 00       	call   4175 <printf>
    exit();
     22e:	e8 95 3d 00 00       	call   3fc8 <exit>
  }
  if(pid == 0){
     233:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     237:	75 3c                	jne    275 <openiputtest+0xaf>
    int fd = open("oidir", O_RDWR);
     239:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
     240:	00 
     241:	c7 04 24 1f 46 00 00 	movl   $0x461f,(%esp)
     248:	e8 bb 3d 00 00       	call   4008 <open>
     24d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0){
     250:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     254:	78 1a                	js     270 <openiputtest+0xaa>
      printf(stdout, "open directory for write succeeded\n");
     256:	a1 bc 64 00 00       	mov    0x64bc,%eax
     25b:	c7 44 24 04 3c 46 00 	movl   $0x463c,0x4(%esp)
     262:	00 
     263:	89 04 24             	mov    %eax,(%esp)
     266:	e8 0a 3f 00 00       	call   4175 <printf>
      exit();
     26b:	e8 58 3d 00 00       	call   3fc8 <exit>
    }
    exit();
     270:	e8 53 3d 00 00       	call   3fc8 <exit>
  }
  sleep(1);
     275:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     27c:	e8 d7 3d 00 00       	call   4058 <sleep>
  if(unlink("oidir") != 0){
     281:	c7 04 24 1f 46 00 00 	movl   $0x461f,(%esp)
     288:	e8 8b 3d 00 00       	call   4018 <unlink>
     28d:	85 c0                	test   %eax,%eax
     28f:	74 1a                	je     2ab <openiputtest+0xe5>
    printf(stdout, "unlink failed\n");
     291:	a1 bc 64 00 00       	mov    0x64bc,%eax
     296:	c7 44 24 04 60 46 00 	movl   $0x4660,0x4(%esp)
     29d:	00 
     29e:	89 04 24             	mov    %eax,(%esp)
     2a1:	e8 cf 3e 00 00       	call   4175 <printf>
    exit();
     2a6:	e8 1d 3d 00 00       	call   3fc8 <exit>
  }
  wait();
     2ab:	e8 20 3d 00 00       	call   3fd0 <wait>
  printf(stdout, "openiput test ok\n");
     2b0:	a1 bc 64 00 00       	mov    0x64bc,%eax
     2b5:	c7 44 24 04 6f 46 00 	movl   $0x466f,0x4(%esp)
     2bc:	00 
     2bd:	89 04 24             	mov    %eax,(%esp)
     2c0:	e8 b0 3e 00 00       	call   4175 <printf>
}
     2c5:	c9                   	leave  
     2c6:	c3                   	ret    

000002c7 <opentest>:

// simple file system tests

void
opentest(void)
{
     2c7:	55                   	push   %ebp
     2c8:	89 e5                	mov    %esp,%ebp
     2ca:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(stdout, "open test\n");
     2cd:	a1 bc 64 00 00       	mov    0x64bc,%eax
     2d2:	c7 44 24 04 81 46 00 	movl   $0x4681,0x4(%esp)
     2d9:	00 
     2da:	89 04 24             	mov    %eax,(%esp)
     2dd:	e8 93 3e 00 00       	call   4175 <printf>
  fd = open("echo", 0);
     2e2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     2e9:	00 
     2ea:	c7 04 24 3c 45 00 00 	movl   $0x453c,(%esp)
     2f1:	e8 12 3d 00 00       	call   4008 <open>
     2f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
     2f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     2fd:	79 1a                	jns    319 <opentest+0x52>
    printf(stdout, "open echo failed!\n");
     2ff:	a1 bc 64 00 00       	mov    0x64bc,%eax
     304:	c7 44 24 04 8c 46 00 	movl   $0x468c,0x4(%esp)
     30b:	00 
     30c:	89 04 24             	mov    %eax,(%esp)
     30f:	e8 61 3e 00 00       	call   4175 <printf>
    exit();
     314:	e8 af 3c 00 00       	call   3fc8 <exit>
  }
  close(fd);
     319:	8b 45 f4             	mov    -0xc(%ebp),%eax
     31c:	89 04 24             	mov    %eax,(%esp)
     31f:	e8 cc 3c 00 00       	call   3ff0 <close>
  fd = open("doesnotexist", 0);
     324:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     32b:	00 
     32c:	c7 04 24 9f 46 00 00 	movl   $0x469f,(%esp)
     333:	e8 d0 3c 00 00       	call   4008 <open>
     338:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
     33b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     33f:	78 1a                	js     35b <opentest+0x94>
    printf(stdout, "open doesnotexist succeeded!\n");
     341:	a1 bc 64 00 00       	mov    0x64bc,%eax
     346:	c7 44 24 04 ac 46 00 	movl   $0x46ac,0x4(%esp)
     34d:	00 
     34e:	89 04 24             	mov    %eax,(%esp)
     351:	e8 1f 3e 00 00       	call   4175 <printf>
    exit();
     356:	e8 6d 3c 00 00       	call   3fc8 <exit>
  }
  printf(stdout, "open test ok\n");
     35b:	a1 bc 64 00 00       	mov    0x64bc,%eax
     360:	c7 44 24 04 ca 46 00 	movl   $0x46ca,0x4(%esp)
     367:	00 
     368:	89 04 24             	mov    %eax,(%esp)
     36b:	e8 05 3e 00 00       	call   4175 <printf>
}
     370:	c9                   	leave  
     371:	c3                   	ret    

00000372 <writetest>:

void
writetest(void)
{
     372:	55                   	push   %ebp
     373:	89 e5                	mov    %esp,%ebp
     375:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int i;

  printf(stdout, "small file test\n");
     378:	a1 bc 64 00 00       	mov    0x64bc,%eax
     37d:	c7 44 24 04 d8 46 00 	movl   $0x46d8,0x4(%esp)
     384:	00 
     385:	89 04 24             	mov    %eax,(%esp)
     388:	e8 e8 3d 00 00       	call   4175 <printf>
  fd = open("small", O_CREATE|O_RDWR);
     38d:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     394:	00 
     395:	c7 04 24 e9 46 00 00 	movl   $0x46e9,(%esp)
     39c:	e8 67 3c 00 00       	call   4008 <open>
     3a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd >= 0){
     3a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     3a8:	78 21                	js     3cb <writetest+0x59>
    printf(stdout, "creat small succeeded; ok\n");
     3aa:	a1 bc 64 00 00       	mov    0x64bc,%eax
     3af:	c7 44 24 04 ef 46 00 	movl   $0x46ef,0x4(%esp)
     3b6:	00 
     3b7:	89 04 24             	mov    %eax,(%esp)
     3ba:	e8 b6 3d 00 00       	call   4175 <printf>
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
     3bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     3c6:	e9 9f 00 00 00       	jmp    46a <writetest+0xf8>
  printf(stdout, "small file test\n");
  fd = open("small", O_CREATE|O_RDWR);
  if(fd >= 0){
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
     3cb:	a1 bc 64 00 00       	mov    0x64bc,%eax
     3d0:	c7 44 24 04 0a 47 00 	movl   $0x470a,0x4(%esp)
     3d7:	00 
     3d8:	89 04 24             	mov    %eax,(%esp)
     3db:	e8 95 3d 00 00       	call   4175 <printf>
    exit();
     3e0:	e8 e3 3b 00 00       	call   3fc8 <exit>
  }
  for(i = 0; i < 100; i++){
    if(write(fd, "aaaaaaaaaa", 10) != 10){
     3e5:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     3ec:	00 
     3ed:	c7 44 24 04 26 47 00 	movl   $0x4726,0x4(%esp)
     3f4:	00 
     3f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
     3f8:	89 04 24             	mov    %eax,(%esp)
     3fb:	e8 e8 3b 00 00       	call   3fe8 <write>
     400:	83 f8 0a             	cmp    $0xa,%eax
     403:	74 21                	je     426 <writetest+0xb4>
      printf(stdout, "error: write aa %d new file failed\n", i);
     405:	a1 bc 64 00 00       	mov    0x64bc,%eax
     40a:	8b 55 f4             	mov    -0xc(%ebp),%edx
     40d:	89 54 24 08          	mov    %edx,0x8(%esp)
     411:	c7 44 24 04 34 47 00 	movl   $0x4734,0x4(%esp)
     418:	00 
     419:	89 04 24             	mov    %eax,(%esp)
     41c:	e8 54 3d 00 00       	call   4175 <printf>
      exit();
     421:	e8 a2 3b 00 00       	call   3fc8 <exit>
    }
    if(write(fd, "bbbbbbbbbb", 10) != 10){
     426:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     42d:	00 
     42e:	c7 44 24 04 58 47 00 	movl   $0x4758,0x4(%esp)
     435:	00 
     436:	8b 45 f0             	mov    -0x10(%ebp),%eax
     439:	89 04 24             	mov    %eax,(%esp)
     43c:	e8 a7 3b 00 00       	call   3fe8 <write>
     441:	83 f8 0a             	cmp    $0xa,%eax
     444:	74 21                	je     467 <writetest+0xf5>
      printf(stdout, "error: write bb %d new file failed\n", i);
     446:	a1 bc 64 00 00       	mov    0x64bc,%eax
     44b:	8b 55 f4             	mov    -0xc(%ebp),%edx
     44e:	89 54 24 08          	mov    %edx,0x8(%esp)
     452:	c7 44 24 04 64 47 00 	movl   $0x4764,0x4(%esp)
     459:	00 
     45a:	89 04 24             	mov    %eax,(%esp)
     45d:	e8 13 3d 00 00       	call   4175 <printf>
      exit();
     462:	e8 61 3b 00 00       	call   3fc8 <exit>
    printf(stdout, "creat small succeeded; ok\n");
  } else {
    printf(stdout, "error: creat small failed!\n");
    exit();
  }
  for(i = 0; i < 100; i++){
     467:	ff 45 f4             	incl   -0xc(%ebp)
     46a:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
     46e:	0f 8e 71 ff ff ff    	jle    3e5 <writetest+0x73>
    if(write(fd, "bbbbbbbbbb", 10) != 10){
      printf(stdout, "error: write bb %d new file failed\n", i);
      exit();
    }
  }
  printf(stdout, "writes ok\n");
     474:	a1 bc 64 00 00       	mov    0x64bc,%eax
     479:	c7 44 24 04 88 47 00 	movl   $0x4788,0x4(%esp)
     480:	00 
     481:	89 04 24             	mov    %eax,(%esp)
     484:	e8 ec 3c 00 00       	call   4175 <printf>
  close(fd);
     489:	8b 45 f0             	mov    -0x10(%ebp),%eax
     48c:	89 04 24             	mov    %eax,(%esp)
     48f:	e8 5c 3b 00 00       	call   3ff0 <close>
  fd = open("small", O_RDONLY);
     494:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     49b:	00 
     49c:	c7 04 24 e9 46 00 00 	movl   $0x46e9,(%esp)
     4a3:	e8 60 3b 00 00       	call   4008 <open>
     4a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd >= 0){
     4ab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     4af:	78 3e                	js     4ef <writetest+0x17d>
    printf(stdout, "open small succeeded ok\n");
     4b1:	a1 bc 64 00 00       	mov    0x64bc,%eax
     4b6:	c7 44 24 04 93 47 00 	movl   $0x4793,0x4(%esp)
     4bd:	00 
     4be:	89 04 24             	mov    %eax,(%esp)
     4c1:	e8 af 3c 00 00       	call   4175 <printf>
  } else {
    printf(stdout, "error: open small failed!\n");
    exit();
  }
  i = read(fd, buf, 2000);
     4c6:	c7 44 24 08 d0 07 00 	movl   $0x7d0,0x8(%esp)
     4cd:	00 
     4ce:	c7 44 24 04 a0 8c 00 	movl   $0x8ca0,0x4(%esp)
     4d5:	00 
     4d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
     4d9:	89 04 24             	mov    %eax,(%esp)
     4dc:	e8 ff 3a 00 00       	call   3fe0 <read>
     4e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(i == 2000){
     4e4:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
     4eb:	75 4e                	jne    53b <writetest+0x1c9>
     4ed:	eb 1a                	jmp    509 <writetest+0x197>
  close(fd);
  fd = open("small", O_RDONLY);
  if(fd >= 0){
    printf(stdout, "open small succeeded ok\n");
  } else {
    printf(stdout, "error: open small failed!\n");
     4ef:	a1 bc 64 00 00       	mov    0x64bc,%eax
     4f4:	c7 44 24 04 ac 47 00 	movl   $0x47ac,0x4(%esp)
     4fb:	00 
     4fc:	89 04 24             	mov    %eax,(%esp)
     4ff:	e8 71 3c 00 00       	call   4175 <printf>
    exit();
     504:	e8 bf 3a 00 00       	call   3fc8 <exit>
  }
  i = read(fd, buf, 2000);
  if(i == 2000){
    printf(stdout, "read succeeded ok\n");
     509:	a1 bc 64 00 00       	mov    0x64bc,%eax
     50e:	c7 44 24 04 c7 47 00 	movl   $0x47c7,0x4(%esp)
     515:	00 
     516:	89 04 24             	mov    %eax,(%esp)
     519:	e8 57 3c 00 00       	call   4175 <printf>
  } else {
    printf(stdout, "read failed\n");
    exit();
  }
  close(fd);
     51e:	8b 45 f0             	mov    -0x10(%ebp),%eax
     521:	89 04 24             	mov    %eax,(%esp)
     524:	e8 c7 3a 00 00       	call   3ff0 <close>

  if(unlink("small") < 0){
     529:	c7 04 24 e9 46 00 00 	movl   $0x46e9,(%esp)
     530:	e8 e3 3a 00 00       	call   4018 <unlink>
     535:	85 c0                	test   %eax,%eax
     537:	79 36                	jns    56f <writetest+0x1fd>
     539:	eb 1a                	jmp    555 <writetest+0x1e3>
  }
  i = read(fd, buf, 2000);
  if(i == 2000){
    printf(stdout, "read succeeded ok\n");
  } else {
    printf(stdout, "read failed\n");
     53b:	a1 bc 64 00 00       	mov    0x64bc,%eax
     540:	c7 44 24 04 da 47 00 	movl   $0x47da,0x4(%esp)
     547:	00 
     548:	89 04 24             	mov    %eax,(%esp)
     54b:	e8 25 3c 00 00       	call   4175 <printf>
    exit();
     550:	e8 73 3a 00 00       	call   3fc8 <exit>
  }
  close(fd);

  if(unlink("small") < 0){
    printf(stdout, "unlink small failed\n");
     555:	a1 bc 64 00 00       	mov    0x64bc,%eax
     55a:	c7 44 24 04 e7 47 00 	movl   $0x47e7,0x4(%esp)
     561:	00 
     562:	89 04 24             	mov    %eax,(%esp)
     565:	e8 0b 3c 00 00       	call   4175 <printf>
    exit();
     56a:	e8 59 3a 00 00       	call   3fc8 <exit>
  }
  printf(stdout, "small file test ok\n");
     56f:	a1 bc 64 00 00       	mov    0x64bc,%eax
     574:	c7 44 24 04 fc 47 00 	movl   $0x47fc,0x4(%esp)
     57b:	00 
     57c:	89 04 24             	mov    %eax,(%esp)
     57f:	e8 f1 3b 00 00       	call   4175 <printf>
}
     584:	c9                   	leave  
     585:	c3                   	ret    

00000586 <writetest1>:

void
writetest1(void)
{
     586:	55                   	push   %ebp
     587:	89 e5                	mov    %esp,%ebp
     589:	83 ec 28             	sub    $0x28,%esp
  int i, fd, n;

  printf(stdout, "big files test\n");
     58c:	a1 bc 64 00 00       	mov    0x64bc,%eax
     591:	c7 44 24 04 10 48 00 	movl   $0x4810,0x4(%esp)
     598:	00 
     599:	89 04 24             	mov    %eax,(%esp)
     59c:	e8 d4 3b 00 00       	call   4175 <printf>

  fd = open("big", O_CREATE|O_RDWR);
     5a1:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     5a8:	00 
     5a9:	c7 04 24 20 48 00 00 	movl   $0x4820,(%esp)
     5b0:	e8 53 3a 00 00       	call   4008 <open>
     5b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
     5b8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     5bc:	79 1a                	jns    5d8 <writetest1+0x52>
    printf(stdout, "error: creat big failed!\n");
     5be:	a1 bc 64 00 00       	mov    0x64bc,%eax
     5c3:	c7 44 24 04 24 48 00 	movl   $0x4824,0x4(%esp)
     5ca:	00 
     5cb:	89 04 24             	mov    %eax,(%esp)
     5ce:	e8 a2 3b 00 00       	call   4175 <printf>
    exit();
     5d3:	e8 f0 39 00 00       	call   3fc8 <exit>
  }

  for(i = 0; i < MAXFILE; i++){
     5d8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     5df:	eb 50                	jmp    631 <writetest1+0xab>
    ((int*)buf)[0] = i;
     5e1:	b8 a0 8c 00 00       	mov    $0x8ca0,%eax
     5e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
     5e9:	89 10                	mov    %edx,(%eax)
    if(write(fd, buf, 512) != 512){
     5eb:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     5f2:	00 
     5f3:	c7 44 24 04 a0 8c 00 	movl   $0x8ca0,0x4(%esp)
     5fa:	00 
     5fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
     5fe:	89 04 24             	mov    %eax,(%esp)
     601:	e8 e2 39 00 00       	call   3fe8 <write>
     606:	3d 00 02 00 00       	cmp    $0x200,%eax
     60b:	74 21                	je     62e <writetest1+0xa8>
      printf(stdout, "error: write big file failed\n", i);
     60d:	a1 bc 64 00 00       	mov    0x64bc,%eax
     612:	8b 55 f4             	mov    -0xc(%ebp),%edx
     615:	89 54 24 08          	mov    %edx,0x8(%esp)
     619:	c7 44 24 04 3e 48 00 	movl   $0x483e,0x4(%esp)
     620:	00 
     621:	89 04 24             	mov    %eax,(%esp)
     624:	e8 4c 3b 00 00       	call   4175 <printf>
      exit();
     629:	e8 9a 39 00 00       	call   3fc8 <exit>
  if(fd < 0){
    printf(stdout, "error: creat big failed!\n");
    exit();
  }

  for(i = 0; i < MAXFILE; i++){
     62e:	ff 45 f4             	incl   -0xc(%ebp)
     631:	8b 45 f4             	mov    -0xc(%ebp),%eax
     634:	3d 8b 00 00 00       	cmp    $0x8b,%eax
     639:	76 a6                	jbe    5e1 <writetest1+0x5b>
      printf(stdout, "error: write big file failed\n", i);
      exit();
    }
  }

  close(fd);
     63b:	8b 45 ec             	mov    -0x14(%ebp),%eax
     63e:	89 04 24             	mov    %eax,(%esp)
     641:	e8 aa 39 00 00       	call   3ff0 <close>

  fd = open("big", O_RDONLY);
     646:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     64d:	00 
     64e:	c7 04 24 20 48 00 00 	movl   $0x4820,(%esp)
     655:	e8 ae 39 00 00       	call   4008 <open>
     65a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
     65d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     661:	79 1a                	jns    67d <writetest1+0xf7>
    printf(stdout, "error: open big failed!\n");
     663:	a1 bc 64 00 00       	mov    0x64bc,%eax
     668:	c7 44 24 04 5c 48 00 	movl   $0x485c,0x4(%esp)
     66f:	00 
     670:	89 04 24             	mov    %eax,(%esp)
     673:	e8 fd 3a 00 00       	call   4175 <printf>
    exit();
     678:	e8 4b 39 00 00       	call   3fc8 <exit>
  }

  n = 0;
     67d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(;;){
    i = read(fd, buf, 512);
     684:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
     68b:	00 
     68c:	c7 44 24 04 a0 8c 00 	movl   $0x8ca0,0x4(%esp)
     693:	00 
     694:	8b 45 ec             	mov    -0x14(%ebp),%eax
     697:	89 04 24             	mov    %eax,(%esp)
     69a:	e8 41 39 00 00       	call   3fe0 <read>
     69f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(i == 0){
     6a2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     6a6:	75 4c                	jne    6f4 <writetest1+0x16e>
      if(n == MAXFILE - 1){
     6a8:	81 7d f0 8b 00 00 00 	cmpl   $0x8b,-0x10(%ebp)
     6af:	75 21                	jne    6d2 <writetest1+0x14c>
        printf(stdout, "read only %d blocks from big", n);
     6b1:	a1 bc 64 00 00       	mov    0x64bc,%eax
     6b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
     6b9:	89 54 24 08          	mov    %edx,0x8(%esp)
     6bd:	c7 44 24 04 75 48 00 	movl   $0x4875,0x4(%esp)
     6c4:	00 
     6c5:	89 04 24             	mov    %eax,(%esp)
     6c8:	e8 a8 3a 00 00       	call   4175 <printf>
        exit();
     6cd:	e8 f6 38 00 00       	call   3fc8 <exit>
      }
      break;
     6d2:	90                   	nop
             n, ((int*)buf)[0]);
      exit();
    }
    n++;
  }
  close(fd);
     6d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
     6d6:	89 04 24             	mov    %eax,(%esp)
     6d9:	e8 12 39 00 00       	call   3ff0 <close>
  if(unlink("big") < 0){
     6de:	c7 04 24 20 48 00 00 	movl   $0x4820,(%esp)
     6e5:	e8 2e 39 00 00       	call   4018 <unlink>
     6ea:	85 c0                	test   %eax,%eax
     6ec:	0f 89 86 00 00 00    	jns    778 <writetest1+0x1f2>
     6f2:	eb 6a                	jmp    75e <writetest1+0x1d8>
      if(n == MAXFILE - 1){
        printf(stdout, "read only %d blocks from big", n);
        exit();
      }
      break;
    } else if(i != 512){
     6f4:	81 7d f4 00 02 00 00 	cmpl   $0x200,-0xc(%ebp)
     6fb:	74 21                	je     71e <writetest1+0x198>
      printf(stdout, "read failed %d\n", i);
     6fd:	a1 bc 64 00 00       	mov    0x64bc,%eax
     702:	8b 55 f4             	mov    -0xc(%ebp),%edx
     705:	89 54 24 08          	mov    %edx,0x8(%esp)
     709:	c7 44 24 04 92 48 00 	movl   $0x4892,0x4(%esp)
     710:	00 
     711:	89 04 24             	mov    %eax,(%esp)
     714:	e8 5c 3a 00 00       	call   4175 <printf>
      exit();
     719:	e8 aa 38 00 00       	call   3fc8 <exit>
    }
    if(((int*)buf)[0] != n){
     71e:	b8 a0 8c 00 00       	mov    $0x8ca0,%eax
     723:	8b 00                	mov    (%eax),%eax
     725:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     728:	74 2c                	je     756 <writetest1+0x1d0>
      printf(stdout, "read content of block %d is %d\n",
             n, ((int*)buf)[0]);
     72a:	b8 a0 8c 00 00       	mov    $0x8ca0,%eax
    } else if(i != 512){
      printf(stdout, "read failed %d\n", i);
      exit();
    }
    if(((int*)buf)[0] != n){
      printf(stdout, "read content of block %d is %d\n",
     72f:	8b 10                	mov    (%eax),%edx
     731:	a1 bc 64 00 00       	mov    0x64bc,%eax
     736:	89 54 24 0c          	mov    %edx,0xc(%esp)
     73a:	8b 55 f0             	mov    -0x10(%ebp),%edx
     73d:	89 54 24 08          	mov    %edx,0x8(%esp)
     741:	c7 44 24 04 a4 48 00 	movl   $0x48a4,0x4(%esp)
     748:	00 
     749:	89 04 24             	mov    %eax,(%esp)
     74c:	e8 24 3a 00 00       	call   4175 <printf>
             n, ((int*)buf)[0]);
      exit();
     751:	e8 72 38 00 00       	call   3fc8 <exit>
    }
    n++;
     756:	ff 45 f0             	incl   -0x10(%ebp)
  }
     759:	e9 26 ff ff ff       	jmp    684 <writetest1+0xfe>
  close(fd);
  if(unlink("big") < 0){
    printf(stdout, "unlink big failed\n");
     75e:	a1 bc 64 00 00       	mov    0x64bc,%eax
     763:	c7 44 24 04 c4 48 00 	movl   $0x48c4,0x4(%esp)
     76a:	00 
     76b:	89 04 24             	mov    %eax,(%esp)
     76e:	e8 02 3a 00 00       	call   4175 <printf>
    exit();
     773:	e8 50 38 00 00       	call   3fc8 <exit>
  }
  printf(stdout, "big files ok\n");
     778:	a1 bc 64 00 00       	mov    0x64bc,%eax
     77d:	c7 44 24 04 d7 48 00 	movl   $0x48d7,0x4(%esp)
     784:	00 
     785:	89 04 24             	mov    %eax,(%esp)
     788:	e8 e8 39 00 00       	call   4175 <printf>
}
     78d:	c9                   	leave  
     78e:	c3                   	ret    

0000078f <createtest>:

void
createtest(void)
{
     78f:	55                   	push   %ebp
     790:	89 e5                	mov    %esp,%ebp
     792:	83 ec 28             	sub    $0x28,%esp
  int i, fd;

  printf(stdout, "many creates, followed by unlink test\n");
     795:	a1 bc 64 00 00       	mov    0x64bc,%eax
     79a:	c7 44 24 04 e8 48 00 	movl   $0x48e8,0x4(%esp)
     7a1:	00 
     7a2:	89 04 24             	mov    %eax,(%esp)
     7a5:	e8 cb 39 00 00       	call   4175 <printf>

  name[0] = 'a';
     7aa:	c6 05 a0 ac 00 00 61 	movb   $0x61,0xaca0
  name[2] = '\0';
     7b1:	c6 05 a2 ac 00 00 00 	movb   $0x0,0xaca2
  for(i = 0; i < 52; i++){
     7b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     7bf:	eb 30                	jmp    7f1 <createtest+0x62>
    name[1] = '0' + i;
     7c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
     7c4:	83 c0 30             	add    $0x30,%eax
     7c7:	a2 a1 ac 00 00       	mov    %al,0xaca1
    fd = open(name, O_CREATE|O_RDWR);
     7cc:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     7d3:	00 
     7d4:	c7 04 24 a0 ac 00 00 	movl   $0xaca0,(%esp)
     7db:	e8 28 38 00 00       	call   4008 <open>
     7e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    close(fd);
     7e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
     7e6:	89 04 24             	mov    %eax,(%esp)
     7e9:	e8 02 38 00 00       	call   3ff0 <close>

  printf(stdout, "many creates, followed by unlink test\n");

  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
     7ee:	ff 45 f4             	incl   -0xc(%ebp)
     7f1:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
     7f5:	7e ca                	jle    7c1 <createtest+0x32>
    name[1] = '0' + i;
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
     7f7:	c6 05 a0 ac 00 00 61 	movb   $0x61,0xaca0
  name[2] = '\0';
     7fe:	c6 05 a2 ac 00 00 00 	movb   $0x0,0xaca2
  for(i = 0; i < 52; i++){
     805:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     80c:	eb 1a                	jmp    828 <createtest+0x99>
    name[1] = '0' + i;
     80e:	8b 45 f4             	mov    -0xc(%ebp),%eax
     811:	83 c0 30             	add    $0x30,%eax
     814:	a2 a1 ac 00 00       	mov    %al,0xaca1
    unlink(name);
     819:	c7 04 24 a0 ac 00 00 	movl   $0xaca0,(%esp)
     820:	e8 f3 37 00 00       	call   4018 <unlink>
    fd = open(name, O_CREATE|O_RDWR);
    close(fd);
  }
  name[0] = 'a';
  name[2] = '\0';
  for(i = 0; i < 52; i++){
     825:	ff 45 f4             	incl   -0xc(%ebp)
     828:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
     82c:	7e e0                	jle    80e <createtest+0x7f>
    name[1] = '0' + i;
    unlink(name);
  }
  printf(stdout, "many creates, followed by unlink; ok\n");
     82e:	a1 bc 64 00 00       	mov    0x64bc,%eax
     833:	c7 44 24 04 10 49 00 	movl   $0x4910,0x4(%esp)
     83a:	00 
     83b:	89 04 24             	mov    %eax,(%esp)
     83e:	e8 32 39 00 00       	call   4175 <printf>
}
     843:	c9                   	leave  
     844:	c3                   	ret    

00000845 <dirtest>:

void dirtest(void)
{
     845:	55                   	push   %ebp
     846:	89 e5                	mov    %esp,%ebp
     848:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "mkdir test\n");
     84b:	a1 bc 64 00 00       	mov    0x64bc,%eax
     850:	c7 44 24 04 36 49 00 	movl   $0x4936,0x4(%esp)
     857:	00 
     858:	89 04 24             	mov    %eax,(%esp)
     85b:	e8 15 39 00 00       	call   4175 <printf>

  if(mkdir("dir0") < 0){
     860:	c7 04 24 42 49 00 00 	movl   $0x4942,(%esp)
     867:	e8 c4 37 00 00       	call   4030 <mkdir>
     86c:	85 c0                	test   %eax,%eax
     86e:	79 1a                	jns    88a <dirtest+0x45>
    printf(stdout, "mkdir failed\n");
     870:	a1 bc 64 00 00       	mov    0x64bc,%eax
     875:	c7 44 24 04 65 45 00 	movl   $0x4565,0x4(%esp)
     87c:	00 
     87d:	89 04 24             	mov    %eax,(%esp)
     880:	e8 f0 38 00 00       	call   4175 <printf>
    exit();
     885:	e8 3e 37 00 00       	call   3fc8 <exit>
  }

  if(chdir("dir0") < 0){
     88a:	c7 04 24 42 49 00 00 	movl   $0x4942,(%esp)
     891:	e8 a2 37 00 00       	call   4038 <chdir>
     896:	85 c0                	test   %eax,%eax
     898:	79 1a                	jns    8b4 <dirtest+0x6f>
    printf(stdout, "chdir dir0 failed\n");
     89a:	a1 bc 64 00 00       	mov    0x64bc,%eax
     89f:	c7 44 24 04 47 49 00 	movl   $0x4947,0x4(%esp)
     8a6:	00 
     8a7:	89 04 24             	mov    %eax,(%esp)
     8aa:	e8 c6 38 00 00       	call   4175 <printf>
    exit();
     8af:	e8 14 37 00 00       	call   3fc8 <exit>
  }

  if(chdir("..") < 0){
     8b4:	c7 04 24 5a 49 00 00 	movl   $0x495a,(%esp)
     8bb:	e8 78 37 00 00       	call   4038 <chdir>
     8c0:	85 c0                	test   %eax,%eax
     8c2:	79 1a                	jns    8de <dirtest+0x99>
    printf(stdout, "chdir .. failed\n");
     8c4:	a1 bc 64 00 00       	mov    0x64bc,%eax
     8c9:	c7 44 24 04 5d 49 00 	movl   $0x495d,0x4(%esp)
     8d0:	00 
     8d1:	89 04 24             	mov    %eax,(%esp)
     8d4:	e8 9c 38 00 00       	call   4175 <printf>
    exit();
     8d9:	e8 ea 36 00 00       	call   3fc8 <exit>
  }

  if(unlink("dir0") < 0){
     8de:	c7 04 24 42 49 00 00 	movl   $0x4942,(%esp)
     8e5:	e8 2e 37 00 00       	call   4018 <unlink>
     8ea:	85 c0                	test   %eax,%eax
     8ec:	79 1a                	jns    908 <dirtest+0xc3>
    printf(stdout, "unlink dir0 failed\n");
     8ee:	a1 bc 64 00 00       	mov    0x64bc,%eax
     8f3:	c7 44 24 04 6e 49 00 	movl   $0x496e,0x4(%esp)
     8fa:	00 
     8fb:	89 04 24             	mov    %eax,(%esp)
     8fe:	e8 72 38 00 00       	call   4175 <printf>
    exit();
     903:	e8 c0 36 00 00       	call   3fc8 <exit>
  }
  printf(stdout, "mkdir test ok\n");
     908:	a1 bc 64 00 00       	mov    0x64bc,%eax
     90d:	c7 44 24 04 82 49 00 	movl   $0x4982,0x4(%esp)
     914:	00 
     915:	89 04 24             	mov    %eax,(%esp)
     918:	e8 58 38 00 00       	call   4175 <printf>
}
     91d:	c9                   	leave  
     91e:	c3                   	ret    

0000091f <exectest>:

void
exectest(void)
{
     91f:	55                   	push   %ebp
     920:	89 e5                	mov    %esp,%ebp
     922:	83 ec 18             	sub    $0x18,%esp
  printf(stdout, "exec test\n");
     925:	a1 bc 64 00 00       	mov    0x64bc,%eax
     92a:	c7 44 24 04 91 49 00 	movl   $0x4991,0x4(%esp)
     931:	00 
     932:	89 04 24             	mov    %eax,(%esp)
     935:	e8 3b 38 00 00       	call   4175 <printf>
  if(exec("echo", echoargv) < 0){
     93a:	c7 44 24 04 a8 64 00 	movl   $0x64a8,0x4(%esp)
     941:	00 
     942:	c7 04 24 3c 45 00 00 	movl   $0x453c,(%esp)
     949:	e8 b2 36 00 00       	call   4000 <exec>
     94e:	85 c0                	test   %eax,%eax
     950:	79 1a                	jns    96c <exectest+0x4d>
    printf(stdout, "exec echo failed\n");
     952:	a1 bc 64 00 00       	mov    0x64bc,%eax
     957:	c7 44 24 04 9c 49 00 	movl   $0x499c,0x4(%esp)
     95e:	00 
     95f:	89 04 24             	mov    %eax,(%esp)
     962:	e8 0e 38 00 00       	call   4175 <printf>
    exit();
     967:	e8 5c 36 00 00       	call   3fc8 <exit>
  }
}
     96c:	c9                   	leave  
     96d:	c3                   	ret    

0000096e <pipe1>:

// simple fork and pipe read/write

void
pipe1(void)
{
     96e:	55                   	push   %ebp
     96f:	89 e5                	mov    %esp,%ebp
     971:	83 ec 38             	sub    $0x38,%esp
  int fds[2], pid;
  int seq, i, n, cc, total;

  if(pipe(fds) != 0){
     974:	8d 45 d8             	lea    -0x28(%ebp),%eax
     977:	89 04 24             	mov    %eax,(%esp)
     97a:	e8 59 36 00 00       	call   3fd8 <pipe>
     97f:	85 c0                	test   %eax,%eax
     981:	74 19                	je     99c <pipe1+0x2e>
    printf(1, "pipe() failed\n");
     983:	c7 44 24 04 ae 49 00 	movl   $0x49ae,0x4(%esp)
     98a:	00 
     98b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     992:	e8 de 37 00 00       	call   4175 <printf>
    exit();
     997:	e8 2c 36 00 00       	call   3fc8 <exit>
  }
  pid = fork();
     99c:	e8 1f 36 00 00       	call   3fc0 <fork>
     9a1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  seq = 0;
     9a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  if(pid == 0){
     9ab:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     9af:	0f 85 86 00 00 00    	jne    a3b <pipe1+0xcd>
    close(fds[0]);
     9b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
     9b8:	89 04 24             	mov    %eax,(%esp)
     9bb:	e8 30 36 00 00       	call   3ff0 <close>
    for(n = 0; n < 5; n++){
     9c0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
     9c7:	eb 67                	jmp    a30 <pipe1+0xc2>
      for(i = 0; i < 1033; i++)
     9c9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     9d0:	eb 17                	jmp    9e9 <pipe1+0x7b>
        buf[i] = seq++;
     9d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
     9d5:	8d 50 01             	lea    0x1(%eax),%edx
     9d8:	89 55 f4             	mov    %edx,-0xc(%ebp)
     9db:	8b 55 f0             	mov    -0x10(%ebp),%edx
     9de:	81 c2 a0 8c 00 00    	add    $0x8ca0,%edx
     9e4:	88 02                	mov    %al,(%edx)
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
      for(i = 0; i < 1033; i++)
     9e6:	ff 45 f0             	incl   -0x10(%ebp)
     9e9:	81 7d f0 08 04 00 00 	cmpl   $0x408,-0x10(%ebp)
     9f0:	7e e0                	jle    9d2 <pipe1+0x64>
        buf[i] = seq++;
      if(write(fds[1], buf, 1033) != 1033){
     9f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
     9f5:	c7 44 24 08 09 04 00 	movl   $0x409,0x8(%esp)
     9fc:	00 
     9fd:	c7 44 24 04 a0 8c 00 	movl   $0x8ca0,0x4(%esp)
     a04:	00 
     a05:	89 04 24             	mov    %eax,(%esp)
     a08:	e8 db 35 00 00       	call   3fe8 <write>
     a0d:	3d 09 04 00 00       	cmp    $0x409,%eax
     a12:	74 19                	je     a2d <pipe1+0xbf>
        printf(1, "pipe1 oops 1\n");
     a14:	c7 44 24 04 bd 49 00 	movl   $0x49bd,0x4(%esp)
     a1b:	00 
     a1c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a23:	e8 4d 37 00 00       	call   4175 <printf>
        exit();
     a28:	e8 9b 35 00 00       	call   3fc8 <exit>
  }
  pid = fork();
  seq = 0;
  if(pid == 0){
    close(fds[0]);
    for(n = 0; n < 5; n++){
     a2d:	ff 45 ec             	incl   -0x14(%ebp)
     a30:	83 7d ec 04          	cmpl   $0x4,-0x14(%ebp)
     a34:	7e 93                	jle    9c9 <pipe1+0x5b>
      if(write(fds[1], buf, 1033) != 1033){
        printf(1, "pipe1 oops 1\n");
        exit();
      }
    }
    exit();
     a36:	e8 8d 35 00 00       	call   3fc8 <exit>
  } else if(pid > 0){
     a3b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     a3f:	0f 8e fc 00 00 00    	jle    b41 <pipe1+0x1d3>
    close(fds[1]);
     a45:	8b 45 dc             	mov    -0x24(%ebp),%eax
     a48:	89 04 24             	mov    %eax,(%esp)
     a4b:	e8 a0 35 00 00       	call   3ff0 <close>
    total = 0;
     a50:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    cc = 1;
     a57:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
    while((n = read(fds[0], buf, cc)) > 0){
     a5e:	eb 6b                	jmp    acb <pipe1+0x15d>
      for(i = 0; i < n; i++){
     a60:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     a67:	eb 3b                	jmp    aa4 <pipe1+0x136>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
     a69:	8b 45 f0             	mov    -0x10(%ebp),%eax
     a6c:	05 a0 8c 00 00       	add    $0x8ca0,%eax
     a71:	8a 00                	mov    (%eax),%al
     a73:	0f be c8             	movsbl %al,%ecx
     a76:	8b 45 f4             	mov    -0xc(%ebp),%eax
     a79:	8d 50 01             	lea    0x1(%eax),%edx
     a7c:	89 55 f4             	mov    %edx,-0xc(%ebp)
     a7f:	31 c8                	xor    %ecx,%eax
     a81:	0f b6 c0             	movzbl %al,%eax
     a84:	85 c0                	test   %eax,%eax
     a86:	74 19                	je     aa1 <pipe1+0x133>
          printf(1, "pipe1 oops 2\n");
     a88:	c7 44 24 04 cb 49 00 	movl   $0x49cb,0x4(%esp)
     a8f:	00 
     a90:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     a97:	e8 d9 36 00 00       	call   4175 <printf>
     a9c:	e9 b9 00 00 00       	jmp    b5a <pipe1+0x1ec>
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
      for(i = 0; i < n; i++){
     aa1:	ff 45 f0             	incl   -0x10(%ebp)
     aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
     aa7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
     aaa:	7c bd                	jl     a69 <pipe1+0xfb>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
          printf(1, "pipe1 oops 2\n");
          return;
        }
      }
      total += n;
     aac:	8b 45 ec             	mov    -0x14(%ebp),%eax
     aaf:	01 45 e4             	add    %eax,-0x1c(%ebp)
      cc = cc * 2;
     ab2:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ab5:	01 c0                	add    %eax,%eax
     ab7:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(cc > sizeof(buf))
     aba:	8b 45 e8             	mov    -0x18(%ebp),%eax
     abd:	3d 00 20 00 00       	cmp    $0x2000,%eax
     ac2:	76 07                	jbe    acb <pipe1+0x15d>
        cc = sizeof(buf);
     ac4:	c7 45 e8 00 20 00 00 	movl   $0x2000,-0x18(%ebp)
    exit();
  } else if(pid > 0){
    close(fds[1]);
    total = 0;
    cc = 1;
    while((n = read(fds[0], buf, cc)) > 0){
     acb:	8b 45 d8             	mov    -0x28(%ebp),%eax
     ace:	8b 55 e8             	mov    -0x18(%ebp),%edx
     ad1:	89 54 24 08          	mov    %edx,0x8(%esp)
     ad5:	c7 44 24 04 a0 8c 00 	movl   $0x8ca0,0x4(%esp)
     adc:	00 
     add:	89 04 24             	mov    %eax,(%esp)
     ae0:	e8 fb 34 00 00       	call   3fe0 <read>
     ae5:	89 45 ec             	mov    %eax,-0x14(%ebp)
     ae8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     aec:	0f 8f 6e ff ff ff    	jg     a60 <pipe1+0xf2>
      total += n;
      cc = cc * 2;
      if(cc > sizeof(buf))
        cc = sizeof(buf);
    }
    if(total != 5 * 1033){
     af2:	81 7d e4 2d 14 00 00 	cmpl   $0x142d,-0x1c(%ebp)
     af9:	74 20                	je     b1b <pipe1+0x1ad>
      printf(1, "pipe1 oops 3 total %d\n", total);
     afb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     afe:	89 44 24 08          	mov    %eax,0x8(%esp)
     b02:	c7 44 24 04 d9 49 00 	movl   $0x49d9,0x4(%esp)
     b09:	00 
     b0a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b11:	e8 5f 36 00 00       	call   4175 <printf>
      exit();
     b16:	e8 ad 34 00 00       	call   3fc8 <exit>
    }
    close(fds[0]);
     b1b:	8b 45 d8             	mov    -0x28(%ebp),%eax
     b1e:	89 04 24             	mov    %eax,(%esp)
     b21:	e8 ca 34 00 00       	call   3ff0 <close>
    wait();
     b26:	e8 a5 34 00 00       	call   3fd0 <wait>
  } else {
    printf(1, "fork() failed\n");
    exit();
  }
  printf(1, "pipe1 ok\n");
     b2b:	c7 44 24 04 ff 49 00 	movl   $0x49ff,0x4(%esp)
     b32:	00 
     b33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b3a:	e8 36 36 00 00       	call   4175 <printf>
     b3f:	eb 19                	jmp    b5a <pipe1+0x1ec>
      exit();
    }
    close(fds[0]);
    wait();
  } else {
    printf(1, "fork() failed\n");
     b41:	c7 44 24 04 f0 49 00 	movl   $0x49f0,0x4(%esp)
     b48:	00 
     b49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b50:	e8 20 36 00 00       	call   4175 <printf>
    exit();
     b55:	e8 6e 34 00 00       	call   3fc8 <exit>
  }
  printf(1, "pipe1 ok\n");
}
     b5a:	c9                   	leave  
     b5b:	c3                   	ret    

00000b5c <preempt>:

// meant to be run w/ at most two CPUs
void
preempt(void)
{
     b5c:	55                   	push   %ebp
     b5d:	89 e5                	mov    %esp,%ebp
     b5f:	83 ec 38             	sub    $0x38,%esp
  int pid1, pid2, pid3;
  int pfds[2];

  printf(1, "preempt: ");
     b62:	c7 44 24 04 09 4a 00 	movl   $0x4a09,0x4(%esp)
     b69:	00 
     b6a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     b71:	e8 ff 35 00 00       	call   4175 <printf>
  pid1 = fork();
     b76:	e8 45 34 00 00       	call   3fc0 <fork>
     b7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pid1 == 0)
     b7e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     b82:	75 02                	jne    b86 <preempt+0x2a>
    for(;;)
      ;
     b84:	eb fe                	jmp    b84 <preempt+0x28>

  pid2 = fork();
     b86:	e8 35 34 00 00       	call   3fc0 <fork>
     b8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid2 == 0)
     b8e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     b92:	75 02                	jne    b96 <preempt+0x3a>
    for(;;)
      ;
     b94:	eb fe                	jmp    b94 <preempt+0x38>

  pipe(pfds);
     b96:	8d 45 e4             	lea    -0x1c(%ebp),%eax
     b99:	89 04 24             	mov    %eax,(%esp)
     b9c:	e8 37 34 00 00       	call   3fd8 <pipe>
  pid3 = fork();
     ba1:	e8 1a 34 00 00       	call   3fc0 <fork>
     ba6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(pid3 == 0){
     ba9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     bad:	75 4c                	jne    bfb <preempt+0x9f>
    close(pfds[0]);
     baf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     bb2:	89 04 24             	mov    %eax,(%esp)
     bb5:	e8 36 34 00 00       	call   3ff0 <close>
    if(write(pfds[1], "x", 1) != 1)
     bba:	8b 45 e8             	mov    -0x18(%ebp),%eax
     bbd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
     bc4:	00 
     bc5:	c7 44 24 04 13 4a 00 	movl   $0x4a13,0x4(%esp)
     bcc:	00 
     bcd:	89 04 24             	mov    %eax,(%esp)
     bd0:	e8 13 34 00 00       	call   3fe8 <write>
     bd5:	83 f8 01             	cmp    $0x1,%eax
     bd8:	74 14                	je     bee <preempt+0x92>
      printf(1, "preempt write error");
     bda:	c7 44 24 04 15 4a 00 	movl   $0x4a15,0x4(%esp)
     be1:	00 
     be2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     be9:	e8 87 35 00 00       	call   4175 <printf>
    close(pfds[1]);
     bee:	8b 45 e8             	mov    -0x18(%ebp),%eax
     bf1:	89 04 24             	mov    %eax,(%esp)
     bf4:	e8 f7 33 00 00       	call   3ff0 <close>
    for(;;)
      ;
     bf9:	eb fe                	jmp    bf9 <preempt+0x9d>
  }

  close(pfds[1]);
     bfb:	8b 45 e8             	mov    -0x18(%ebp),%eax
     bfe:	89 04 24             	mov    %eax,(%esp)
     c01:	e8 ea 33 00 00       	call   3ff0 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
     c06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c09:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
     c10:	00 
     c11:	c7 44 24 04 a0 8c 00 	movl   $0x8ca0,0x4(%esp)
     c18:	00 
     c19:	89 04 24             	mov    %eax,(%esp)
     c1c:	e8 bf 33 00 00       	call   3fe0 <read>
     c21:	83 f8 01             	cmp    $0x1,%eax
     c24:	74 16                	je     c3c <preempt+0xe0>
    printf(1, "preempt read error");
     c26:	c7 44 24 04 29 4a 00 	movl   $0x4a29,0x4(%esp)
     c2d:	00 
     c2e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c35:	e8 3b 35 00 00       	call   4175 <printf>
     c3a:	eb 77                	jmp    cb3 <preempt+0x157>
    return;
  }
  close(pfds[0]);
     c3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
     c3f:	89 04 24             	mov    %eax,(%esp)
     c42:	e8 a9 33 00 00       	call   3ff0 <close>
  printf(1, "kill... ");
     c47:	c7 44 24 04 3c 4a 00 	movl   $0x4a3c,0x4(%esp)
     c4e:	00 
     c4f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c56:	e8 1a 35 00 00       	call   4175 <printf>
  kill(pid1);
     c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     c5e:	89 04 24             	mov    %eax,(%esp)
     c61:	e8 92 33 00 00       	call   3ff8 <kill>
  kill(pid2);
     c66:	8b 45 f0             	mov    -0x10(%ebp),%eax
     c69:	89 04 24             	mov    %eax,(%esp)
     c6c:	e8 87 33 00 00       	call   3ff8 <kill>
  kill(pid3);
     c71:	8b 45 ec             	mov    -0x14(%ebp),%eax
     c74:	89 04 24             	mov    %eax,(%esp)
     c77:	e8 7c 33 00 00       	call   3ff8 <kill>
  printf(1, "wait... ");
     c7c:	c7 44 24 04 45 4a 00 	movl   $0x4a45,0x4(%esp)
     c83:	00 
     c84:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     c8b:	e8 e5 34 00 00       	call   4175 <printf>
  wait();
     c90:	e8 3b 33 00 00       	call   3fd0 <wait>
  wait();
     c95:	e8 36 33 00 00       	call   3fd0 <wait>
  wait();
     c9a:	e8 31 33 00 00       	call   3fd0 <wait>
  printf(1, "preempt ok\n");
     c9f:	c7 44 24 04 4e 4a 00 	movl   $0x4a4e,0x4(%esp)
     ca6:	00 
     ca7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     cae:	e8 c2 34 00 00       	call   4175 <printf>
}
     cb3:	c9                   	leave  
     cb4:	c3                   	ret    

00000cb5 <exitwait>:

// try to find any races between exit and wait
void
exitwait(void)
{
     cb5:	55                   	push   %ebp
     cb6:	89 e5                	mov    %esp,%ebp
     cb8:	83 ec 28             	sub    $0x28,%esp
  int i, pid;

  for(i = 0; i < 100; i++){
     cbb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     cc2:	eb 52                	jmp    d16 <exitwait+0x61>
    pid = fork();
     cc4:	e8 f7 32 00 00       	call   3fc0 <fork>
     cc9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0){
     ccc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     cd0:	79 16                	jns    ce8 <exitwait+0x33>
      printf(1, "fork failed\n");
     cd2:	c7 44 24 04 dd 45 00 	movl   $0x45dd,0x4(%esp)
     cd9:	00 
     cda:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     ce1:	e8 8f 34 00 00       	call   4175 <printf>
      return;
     ce6:	eb 48                	jmp    d30 <exitwait+0x7b>
    }
    if(pid){
     ce8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
     cec:	74 20                	je     d0e <exitwait+0x59>
      if(wait() != pid){
     cee:	e8 dd 32 00 00       	call   3fd0 <wait>
     cf3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
     cf6:	74 1b                	je     d13 <exitwait+0x5e>
        printf(1, "wait wrong pid\n");
     cf8:	c7 44 24 04 5a 4a 00 	movl   $0x4a5a,0x4(%esp)
     cff:	00 
     d00:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d07:	e8 69 34 00 00       	call   4175 <printf>
        return;
     d0c:	eb 22                	jmp    d30 <exitwait+0x7b>
      }
    } else {
      exit();
     d0e:	e8 b5 32 00 00       	call   3fc8 <exit>
void
exitwait(void)
{
  int i, pid;

  for(i = 0; i < 100; i++){
     d13:	ff 45 f4             	incl   -0xc(%ebp)
     d16:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
     d1a:	7e a8                	jle    cc4 <exitwait+0xf>
      }
    } else {
      exit();
    }
  }
  printf(1, "exitwait ok\n");
     d1c:	c7 44 24 04 6a 4a 00 	movl   $0x4a6a,0x4(%esp)
     d23:	00 
     d24:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d2b:	e8 45 34 00 00       	call   4175 <printf>
}
     d30:	c9                   	leave  
     d31:	c3                   	ret    

00000d32 <mem>:

void
mem(void)
{
     d32:	55                   	push   %ebp
     d33:	89 e5                	mov    %esp,%ebp
     d35:	83 ec 28             	sub    $0x28,%esp
  void *m1, *m2;
  int pid, ppid;

  printf(1, "mem test\n");
     d38:	c7 44 24 04 77 4a 00 	movl   $0x4a77,0x4(%esp)
     d3f:	00 
     d40:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     d47:	e8 29 34 00 00       	call   4175 <printf>
  ppid = getpid();
     d4c:	e8 f7 32 00 00       	call   4048 <getpid>
     d51:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if((pid = fork()) == 0){
     d54:	e8 67 32 00 00       	call   3fc0 <fork>
     d59:	89 45 ec             	mov    %eax,-0x14(%ebp)
     d5c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
     d60:	0f 85 aa 00 00 00    	jne    e10 <mem+0xde>
    m1 = 0;
     d66:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while((m2 = malloc(10001)) != 0){
     d6d:	eb 0e                	jmp    d7d <mem+0x4b>
      *(char**)m2 = m1;
     d6f:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d72:	8b 55 f4             	mov    -0xc(%ebp),%edx
     d75:	89 10                	mov    %edx,(%eax)
      m1 = m2;
     d77:	8b 45 e8             	mov    -0x18(%ebp),%eax
     d7a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  printf(1, "mem test\n");
  ppid = getpid();
  if((pid = fork()) == 0){
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
     d7d:	c7 04 24 11 27 00 00 	movl   $0x2711,(%esp)
     d84:	e8 d4 36 00 00       	call   445d <malloc>
     d89:	89 45 e8             	mov    %eax,-0x18(%ebp)
     d8c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     d90:	75 dd                	jne    d6f <mem+0x3d>
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
     d92:	eb 19                	jmp    dad <mem+0x7b>
      m2 = *(char**)m1;
     d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d97:	8b 00                	mov    (%eax),%eax
     d99:	89 45 e8             	mov    %eax,-0x18(%ebp)
      free(m1);
     d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     d9f:	89 04 24             	mov    %eax,(%esp)
     da2:	e8 7d 35 00 00       	call   4324 <free>
      m1 = m2;
     da7:	8b 45 e8             	mov    -0x18(%ebp),%eax
     daa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    m1 = 0;
    while((m2 = malloc(10001)) != 0){
      *(char**)m2 = m1;
      m1 = m2;
    }
    while(m1){
     dad:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     db1:	75 e1                	jne    d94 <mem+0x62>
      m2 = *(char**)m1;
      free(m1);
      m1 = m2;
    }
    m1 = malloc(1024*20);
     db3:	c7 04 24 00 50 00 00 	movl   $0x5000,(%esp)
     dba:	e8 9e 36 00 00       	call   445d <malloc>
     dbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(m1 == 0){
     dc2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
     dc6:	75 24                	jne    dec <mem+0xba>
      printf(1, "couldn't allocate mem?!!\n");
     dc8:	c7 44 24 04 81 4a 00 	movl   $0x4a81,0x4(%esp)
     dcf:	00 
     dd0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     dd7:	e8 99 33 00 00       	call   4175 <printf>
      kill(ppid);
     ddc:	8b 45 f0             	mov    -0x10(%ebp),%eax
     ddf:	89 04 24             	mov    %eax,(%esp)
     de2:	e8 11 32 00 00       	call   3ff8 <kill>
      exit();
     de7:	e8 dc 31 00 00       	call   3fc8 <exit>
    }
    free(m1);
     dec:	8b 45 f4             	mov    -0xc(%ebp),%eax
     def:	89 04 24             	mov    %eax,(%esp)
     df2:	e8 2d 35 00 00       	call   4324 <free>
    printf(1, "mem ok\n");
     df7:	c7 44 24 04 9b 4a 00 	movl   $0x4a9b,0x4(%esp)
     dfe:	00 
     dff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e06:	e8 6a 33 00 00       	call   4175 <printf>
    exit();
     e0b:	e8 b8 31 00 00       	call   3fc8 <exit>
  } else {
    wait();
     e10:	e8 bb 31 00 00       	call   3fd0 <wait>
  }
}
     e15:	c9                   	leave  
     e16:	c3                   	ret    

00000e17 <sharedfd>:

// two processes write to the same file descriptor
// is the offset shared? does inode locking work?
void
sharedfd(void)
{
     e17:	55                   	push   %ebp
     e18:	89 e5                	mov    %esp,%ebp
     e1a:	83 ec 48             	sub    $0x48,%esp
  int fd, pid, i, n, nc, np;
  char buf[10];

  printf(1, "sharedfd test\n");
     e1d:	c7 44 24 04 a3 4a 00 	movl   $0x4aa3,0x4(%esp)
     e24:	00 
     e25:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e2c:	e8 44 33 00 00       	call   4175 <printf>

  unlink("sharedfd");
     e31:	c7 04 24 b2 4a 00 00 	movl   $0x4ab2,(%esp)
     e38:	e8 db 31 00 00       	call   4018 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
     e3d:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
     e44:	00 
     e45:	c7 04 24 b2 4a 00 00 	movl   $0x4ab2,(%esp)
     e4c:	e8 b7 31 00 00       	call   4008 <open>
     e51:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(fd < 0){
     e54:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     e58:	79 19                	jns    e73 <sharedfd+0x5c>
    printf(1, "fstests: cannot open sharedfd for writing");
     e5a:	c7 44 24 04 bc 4a 00 	movl   $0x4abc,0x4(%esp)
     e61:	00 
     e62:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     e69:	e8 07 33 00 00       	call   4175 <printf>
    return;
     e6e:	e9 9a 01 00 00       	jmp    100d <sharedfd+0x1f6>
  }
  pid = fork();
     e73:	e8 48 31 00 00       	call   3fc0 <fork>
     e78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  memset(buf, pid==0?'c':'p', sizeof(buf));
     e7b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     e7f:	75 07                	jne    e88 <sharedfd+0x71>
     e81:	b8 63 00 00 00       	mov    $0x63,%eax
     e86:	eb 05                	jmp    e8d <sharedfd+0x76>
     e88:	b8 70 00 00 00       	mov    $0x70,%eax
     e8d:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     e94:	00 
     e95:	89 44 24 04          	mov    %eax,0x4(%esp)
     e99:	8d 45 d6             	lea    -0x2a(%ebp),%eax
     e9c:	89 04 24             	mov    %eax,(%esp)
     e9f:	e8 80 2f 00 00       	call   3e24 <memset>
  for(i = 0; i < 1000; i++){
     ea4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     eab:	eb 38                	jmp    ee5 <sharedfd+0xce>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
     ead:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     eb4:	00 
     eb5:	8d 45 d6             	lea    -0x2a(%ebp),%eax
     eb8:	89 44 24 04          	mov    %eax,0x4(%esp)
     ebc:	8b 45 e8             	mov    -0x18(%ebp),%eax
     ebf:	89 04 24             	mov    %eax,(%esp)
     ec2:	e8 21 31 00 00       	call   3fe8 <write>
     ec7:	83 f8 0a             	cmp    $0xa,%eax
     eca:	74 16                	je     ee2 <sharedfd+0xcb>
      printf(1, "fstests: write sharedfd failed\n");
     ecc:	c7 44 24 04 e8 4a 00 	movl   $0x4ae8,0x4(%esp)
     ed3:	00 
     ed4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     edb:	e8 95 32 00 00       	call   4175 <printf>
      break;
     ee0:	eb 0c                	jmp    eee <sharedfd+0xd7>
    printf(1, "fstests: cannot open sharedfd for writing");
    return;
  }
  pid = fork();
  memset(buf, pid==0?'c':'p', sizeof(buf));
  for(i = 0; i < 1000; i++){
     ee2:	ff 45 f4             	incl   -0xc(%ebp)
     ee5:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
     eec:	7e bf                	jle    ead <sharedfd+0x96>
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
      printf(1, "fstests: write sharedfd failed\n");
      break;
    }
  }
  if(pid == 0)
     eee:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
     ef2:	75 05                	jne    ef9 <sharedfd+0xe2>
    exit();
     ef4:	e8 cf 30 00 00       	call   3fc8 <exit>
  else
    wait();
     ef9:	e8 d2 30 00 00       	call   3fd0 <wait>
  close(fd);
     efe:	8b 45 e8             	mov    -0x18(%ebp),%eax
     f01:	89 04 24             	mov    %eax,(%esp)
     f04:	e8 e7 30 00 00       	call   3ff0 <close>
  fd = open("sharedfd", 0);
     f09:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
     f10:	00 
     f11:	c7 04 24 b2 4a 00 00 	movl   $0x4ab2,(%esp)
     f18:	e8 eb 30 00 00       	call   4008 <open>
     f1d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(fd < 0){
     f20:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
     f24:	79 19                	jns    f3f <sharedfd+0x128>
    printf(1, "fstests: cannot open sharedfd for reading\n");
     f26:	c7 44 24 04 08 4b 00 	movl   $0x4b08,0x4(%esp)
     f2d:	00 
     f2e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     f35:	e8 3b 32 00 00       	call   4175 <printf>
    return;
     f3a:	e9 ce 00 00 00       	jmp    100d <sharedfd+0x1f6>
  }
  nc = np = 0;
     f3f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
     f46:	8b 45 ec             	mov    -0x14(%ebp),%eax
     f49:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while((n = read(fd, buf, sizeof(buf))) > 0){
     f4c:	eb 36                	jmp    f84 <sharedfd+0x16d>
    for(i = 0; i < sizeof(buf); i++){
     f4e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
     f55:	eb 25                	jmp    f7c <sharedfd+0x165>
      if(buf[i] == 'c')
     f57:	8d 55 d6             	lea    -0x2a(%ebp),%edx
     f5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f5d:	01 d0                	add    %edx,%eax
     f5f:	8a 00                	mov    (%eax),%al
     f61:	3c 63                	cmp    $0x63,%al
     f63:	75 03                	jne    f68 <sharedfd+0x151>
        nc++;
     f65:	ff 45 f0             	incl   -0x10(%ebp)
      if(buf[i] == 'p')
     f68:	8d 55 d6             	lea    -0x2a(%ebp),%edx
     f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f6e:	01 d0                	add    %edx,%eax
     f70:	8a 00                	mov    (%eax),%al
     f72:	3c 70                	cmp    $0x70,%al
     f74:	75 03                	jne    f79 <sharedfd+0x162>
        np++;
     f76:	ff 45 ec             	incl   -0x14(%ebp)
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
    for(i = 0; i < sizeof(buf); i++){
     f79:	ff 45 f4             	incl   -0xc(%ebp)
     f7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
     f7f:	83 f8 09             	cmp    $0x9,%eax
     f82:	76 d3                	jbe    f57 <sharedfd+0x140>
  if(fd < 0){
    printf(1, "fstests: cannot open sharedfd for reading\n");
    return;
  }
  nc = np = 0;
  while((n = read(fd, buf, sizeof(buf))) > 0){
     f84:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
     f8b:	00 
     f8c:	8d 45 d6             	lea    -0x2a(%ebp),%eax
     f8f:	89 44 24 04          	mov    %eax,0x4(%esp)
     f93:	8b 45 e8             	mov    -0x18(%ebp),%eax
     f96:	89 04 24             	mov    %eax,(%esp)
     f99:	e8 42 30 00 00       	call   3fe0 <read>
     f9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
     fa1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
     fa5:	7f a7                	jg     f4e <sharedfd+0x137>
        nc++;
      if(buf[i] == 'p')
        np++;
    }
  }
  close(fd);
     fa7:	8b 45 e8             	mov    -0x18(%ebp),%eax
     faa:	89 04 24             	mov    %eax,(%esp)
     fad:	e8 3e 30 00 00       	call   3ff0 <close>
  unlink("sharedfd");
     fb2:	c7 04 24 b2 4a 00 00 	movl   $0x4ab2,(%esp)
     fb9:	e8 5a 30 00 00       	call   4018 <unlink>
  if(nc == 10000 && np == 10000){
     fbe:	81 7d f0 10 27 00 00 	cmpl   $0x2710,-0x10(%ebp)
     fc5:	75 1f                	jne    fe6 <sharedfd+0x1cf>
     fc7:	81 7d ec 10 27 00 00 	cmpl   $0x2710,-0x14(%ebp)
     fce:	75 16                	jne    fe6 <sharedfd+0x1cf>
    printf(1, "sharedfd ok\n");
     fd0:	c7 44 24 04 33 4b 00 	movl   $0x4b33,0x4(%esp)
     fd7:	00 
     fd8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
     fdf:	e8 91 31 00 00       	call   4175 <printf>
     fe4:	eb 27                	jmp    100d <sharedfd+0x1f6>
  } else {
    printf(1, "sharedfd oops %d %d\n", nc, np);
     fe6:	8b 45 ec             	mov    -0x14(%ebp),%eax
     fe9:	89 44 24 0c          	mov    %eax,0xc(%esp)
     fed:	8b 45 f0             	mov    -0x10(%ebp),%eax
     ff0:	89 44 24 08          	mov    %eax,0x8(%esp)
     ff4:	c7 44 24 04 40 4b 00 	movl   $0x4b40,0x4(%esp)
     ffb:	00 
     ffc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1003:	e8 6d 31 00 00       	call   4175 <printf>
    exit();
    1008:	e8 bb 2f 00 00       	call   3fc8 <exit>
  }
}
    100d:	c9                   	leave  
    100e:	c3                   	ret    

0000100f <fourfiles>:

// four processes write different files at the same
// time, to test block allocation.
void
fourfiles(void)
{
    100f:	55                   	push   %ebp
    1010:	89 e5                	mov    %esp,%ebp
    1012:	57                   	push   %edi
    1013:	56                   	push   %esi
    1014:	53                   	push   %ebx
    1015:	83 ec 4c             	sub    $0x4c,%esp
  int fd, pid, i, j, n, total, pi;
  char *names[] = { "f0", "f1", "f2", "f3" };
    1018:	8d 55 b8             	lea    -0x48(%ebp),%edx
    101b:	bb bc 4b 00 00       	mov    $0x4bbc,%ebx
    1020:	b8 04 00 00 00       	mov    $0x4,%eax
    1025:	89 d7                	mov    %edx,%edi
    1027:	89 de                	mov    %ebx,%esi
    1029:	89 c1                	mov    %eax,%ecx
    102b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  char *fname;

  printf(1, "fourfiles test\n");
    102d:	c7 44 24 04 55 4b 00 	movl   $0x4b55,0x4(%esp)
    1034:	00 
    1035:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    103c:	e8 34 31 00 00       	call   4175 <printf>

  for(pi = 0; pi < 4; pi++){
    1041:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
    1048:	e9 fa 00 00 00       	jmp    1147 <fourfiles+0x138>
    fname = names[pi];
    104d:	8b 45 d8             	mov    -0x28(%ebp),%eax
    1050:	8b 44 85 b8          	mov    -0x48(%ebp,%eax,4),%eax
    1054:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unlink(fname);
    1057:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    105a:	89 04 24             	mov    %eax,(%esp)
    105d:	e8 b6 2f 00 00       	call   4018 <unlink>

    pid = fork();
    1062:	e8 59 2f 00 00       	call   3fc0 <fork>
    1067:	89 45 d0             	mov    %eax,-0x30(%ebp)
    if(pid < 0){
    106a:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
    106e:	79 19                	jns    1089 <fourfiles+0x7a>
      printf(1, "fork failed\n");
    1070:	c7 44 24 04 dd 45 00 	movl   $0x45dd,0x4(%esp)
    1077:	00 
    1078:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    107f:	e8 f1 30 00 00       	call   4175 <printf>
      exit();
    1084:	e8 3f 2f 00 00       	call   3fc8 <exit>
    }

    if(pid == 0){
    1089:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
    108d:	0f 85 b1 00 00 00    	jne    1144 <fourfiles+0x135>
      fd = open(fname, O_CREATE | O_RDWR);
    1093:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    109a:	00 
    109b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    109e:	89 04 24             	mov    %eax,(%esp)
    10a1:	e8 62 2f 00 00       	call   4008 <open>
    10a6:	89 45 cc             	mov    %eax,-0x34(%ebp)
      if(fd < 0){
    10a9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
    10ad:	79 19                	jns    10c8 <fourfiles+0xb9>
        printf(1, "create failed\n");
    10af:	c7 44 24 04 65 4b 00 	movl   $0x4b65,0x4(%esp)
    10b6:	00 
    10b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    10be:	e8 b2 30 00 00       	call   4175 <printf>
        exit();
    10c3:	e8 00 2f 00 00       	call   3fc8 <exit>
      }

      memset(buf, '0'+pi, 512);
    10c8:	8b 45 d8             	mov    -0x28(%ebp),%eax
    10cb:	83 c0 30             	add    $0x30,%eax
    10ce:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    10d5:	00 
    10d6:	89 44 24 04          	mov    %eax,0x4(%esp)
    10da:	c7 04 24 a0 8c 00 00 	movl   $0x8ca0,(%esp)
    10e1:	e8 3e 2d 00 00       	call   3e24 <memset>
      for(i = 0; i < 12; i++){
    10e6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    10ed:	eb 4a                	jmp    1139 <fourfiles+0x12a>
        if((n = write(fd, buf, 500)) != 500){
    10ef:	c7 44 24 08 f4 01 00 	movl   $0x1f4,0x8(%esp)
    10f6:	00 
    10f7:	c7 44 24 04 a0 8c 00 	movl   $0x8ca0,0x4(%esp)
    10fe:	00 
    10ff:	8b 45 cc             	mov    -0x34(%ebp),%eax
    1102:	89 04 24             	mov    %eax,(%esp)
    1105:	e8 de 2e 00 00       	call   3fe8 <write>
    110a:	89 45 c8             	mov    %eax,-0x38(%ebp)
    110d:	81 7d c8 f4 01 00 00 	cmpl   $0x1f4,-0x38(%ebp)
    1114:	74 20                	je     1136 <fourfiles+0x127>
          printf(1, "write failed %d\n", n);
    1116:	8b 45 c8             	mov    -0x38(%ebp),%eax
    1119:	89 44 24 08          	mov    %eax,0x8(%esp)
    111d:	c7 44 24 04 74 4b 00 	movl   $0x4b74,0x4(%esp)
    1124:	00 
    1125:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    112c:	e8 44 30 00 00       	call   4175 <printf>
          exit();
    1131:	e8 92 2e 00 00       	call   3fc8 <exit>
        printf(1, "create failed\n");
        exit();
      }

      memset(buf, '0'+pi, 512);
      for(i = 0; i < 12; i++){
    1136:	ff 45 e4             	incl   -0x1c(%ebp)
    1139:	83 7d e4 0b          	cmpl   $0xb,-0x1c(%ebp)
    113d:	7e b0                	jle    10ef <fourfiles+0xe0>
        if((n = write(fd, buf, 500)) != 500){
          printf(1, "write failed %d\n", n);
          exit();
        }
      }
      exit();
    113f:	e8 84 2e 00 00       	call   3fc8 <exit>
  char *names[] = { "f0", "f1", "f2", "f3" };
  char *fname;

  printf(1, "fourfiles test\n");

  for(pi = 0; pi < 4; pi++){
    1144:	ff 45 d8             	incl   -0x28(%ebp)
    1147:	83 7d d8 03          	cmpl   $0x3,-0x28(%ebp)
    114b:	0f 8e fc fe ff ff    	jle    104d <fourfiles+0x3e>
      }
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    1151:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
    1158:	eb 08                	jmp    1162 <fourfiles+0x153>
    wait();
    115a:	e8 71 2e 00 00       	call   3fd0 <wait>
      }
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    115f:	ff 45 d8             	incl   -0x28(%ebp)
    1162:	83 7d d8 03          	cmpl   $0x3,-0x28(%ebp)
    1166:	7e f2                	jle    115a <fourfiles+0x14b>
    wait();
  }

  for(i = 0; i < 2; i++){
    1168:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    116f:	e9 d9 00 00 00       	jmp    124d <fourfiles+0x23e>
    fname = names[i];
    1174:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    1177:	8b 44 85 b8          	mov    -0x48(%ebp,%eax,4),%eax
    117b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    fd = open(fname, 0);
    117e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1185:	00 
    1186:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    1189:	89 04 24             	mov    %eax,(%esp)
    118c:	e8 77 2e 00 00       	call   4008 <open>
    1191:	89 45 cc             	mov    %eax,-0x34(%ebp)
    total = 0;
    1194:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while((n = read(fd, buf, sizeof(buf))) > 0){
    119b:	eb 4a                	jmp    11e7 <fourfiles+0x1d8>
      for(j = 0; j < n; j++){
    119d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    11a4:	eb 33                	jmp    11d9 <fourfiles+0x1ca>
        if(buf[j] != '0'+i){
    11a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
    11a9:	05 a0 8c 00 00       	add    $0x8ca0,%eax
    11ae:	8a 00                	mov    (%eax),%al
    11b0:	0f be c0             	movsbl %al,%eax
    11b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
    11b6:	83 c2 30             	add    $0x30,%edx
    11b9:	39 d0                	cmp    %edx,%eax
    11bb:	74 19                	je     11d6 <fourfiles+0x1c7>
          printf(1, "wrong char\n");
    11bd:	c7 44 24 04 85 4b 00 	movl   $0x4b85,0x4(%esp)
    11c4:	00 
    11c5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    11cc:	e8 a4 2f 00 00       	call   4175 <printf>
          exit();
    11d1:	e8 f2 2d 00 00       	call   3fc8 <exit>
  for(i = 0; i < 2; i++){
    fname = names[i];
    fd = open(fname, 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
      for(j = 0; j < n; j++){
    11d6:	ff 45 e0             	incl   -0x20(%ebp)
    11d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
    11dc:	3b 45 c8             	cmp    -0x38(%ebp),%eax
    11df:	7c c5                	jl     11a6 <fourfiles+0x197>
        if(buf[j] != '0'+i){
          printf(1, "wrong char\n");
          exit();
        }
      }
      total += n;
    11e1:	8b 45 c8             	mov    -0x38(%ebp),%eax
    11e4:	01 45 dc             	add    %eax,-0x24(%ebp)

  for(i = 0; i < 2; i++){
    fname = names[i];
    fd = open(fname, 0);
    total = 0;
    while((n = read(fd, buf, sizeof(buf))) > 0){
    11e7:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    11ee:	00 
    11ef:	c7 44 24 04 a0 8c 00 	movl   $0x8ca0,0x4(%esp)
    11f6:	00 
    11f7:	8b 45 cc             	mov    -0x34(%ebp),%eax
    11fa:	89 04 24             	mov    %eax,(%esp)
    11fd:	e8 de 2d 00 00       	call   3fe0 <read>
    1202:	89 45 c8             	mov    %eax,-0x38(%ebp)
    1205:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
    1209:	7f 92                	jg     119d <fourfiles+0x18e>
          exit();
        }
      }
      total += n;
    }
    close(fd);
    120b:	8b 45 cc             	mov    -0x34(%ebp),%eax
    120e:	89 04 24             	mov    %eax,(%esp)
    1211:	e8 da 2d 00 00       	call   3ff0 <close>
    if(total != 12*500){
    1216:	81 7d dc 70 17 00 00 	cmpl   $0x1770,-0x24(%ebp)
    121d:	74 20                	je     123f <fourfiles+0x230>
      printf(1, "wrong length %d\n", total);
    121f:	8b 45 dc             	mov    -0x24(%ebp),%eax
    1222:	89 44 24 08          	mov    %eax,0x8(%esp)
    1226:	c7 44 24 04 91 4b 00 	movl   $0x4b91,0x4(%esp)
    122d:	00 
    122e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1235:	e8 3b 2f 00 00       	call   4175 <printf>
      exit();
    123a:	e8 89 2d 00 00       	call   3fc8 <exit>
    }
    unlink(fname);
    123f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    1242:	89 04 24             	mov    %eax,(%esp)
    1245:	e8 ce 2d 00 00       	call   4018 <unlink>

  for(pi = 0; pi < 4; pi++){
    wait();
  }

  for(i = 0; i < 2; i++){
    124a:	ff 45 e4             	incl   -0x1c(%ebp)
    124d:	83 7d e4 01          	cmpl   $0x1,-0x1c(%ebp)
    1251:	0f 8e 1d ff ff ff    	jle    1174 <fourfiles+0x165>
      exit();
    }
    unlink(fname);
  }

  printf(1, "fourfiles ok\n");
    1257:	c7 44 24 04 a2 4b 00 	movl   $0x4ba2,0x4(%esp)
    125e:	00 
    125f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1266:	e8 0a 2f 00 00       	call   4175 <printf>
}
    126b:	83 c4 4c             	add    $0x4c,%esp
    126e:	5b                   	pop    %ebx
    126f:	5e                   	pop    %esi
    1270:	5f                   	pop    %edi
    1271:	5d                   	pop    %ebp
    1272:	c3                   	ret    

00001273 <createdelete>:

// four processes create and delete different files in same directory
void
createdelete(void)
{
    1273:	55                   	push   %ebp
    1274:	89 e5                	mov    %esp,%ebp
    1276:	83 ec 48             	sub    $0x48,%esp
  enum { N = 20 };
  int pid, i, fd, pi;
  char name[32];

  printf(1, "createdelete test\n");
    1279:	c7 44 24 04 cc 4b 00 	movl   $0x4bcc,0x4(%esp)
    1280:	00 
    1281:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1288:	e8 e8 2e 00 00       	call   4175 <printf>

  for(pi = 0; pi < 4; pi++){
    128d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    1294:	e9 f2 00 00 00       	jmp    138b <createdelete+0x118>
    pid = fork();
    1299:	e8 22 2d 00 00       	call   3fc0 <fork>
    129e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid < 0){
    12a1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    12a5:	79 19                	jns    12c0 <createdelete+0x4d>
      printf(1, "fork failed\n");
    12a7:	c7 44 24 04 dd 45 00 	movl   $0x45dd,0x4(%esp)
    12ae:	00 
    12af:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    12b6:	e8 ba 2e 00 00       	call   4175 <printf>
      exit();
    12bb:	e8 08 2d 00 00       	call   3fc8 <exit>
    }

    if(pid == 0){
    12c0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    12c4:	0f 85 be 00 00 00    	jne    1388 <createdelete+0x115>
      name[0] = 'p' + pi;
    12ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
    12cd:	83 c0 70             	add    $0x70,%eax
    12d0:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[2] = '\0';
    12d3:	c6 45 ca 00          	movb   $0x0,-0x36(%ebp)
      for(i = 0; i < N; i++){
    12d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    12de:	e9 96 00 00 00       	jmp    1379 <createdelete+0x106>
        name[1] = '0' + i;
    12e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    12e6:	83 c0 30             	add    $0x30,%eax
    12e9:	88 45 c9             	mov    %al,-0x37(%ebp)
        fd = open(name, O_CREATE | O_RDWR);
    12ec:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    12f3:	00 
    12f4:	8d 45 c8             	lea    -0x38(%ebp),%eax
    12f7:	89 04 24             	mov    %eax,(%esp)
    12fa:	e8 09 2d 00 00       	call   4008 <open>
    12ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if(fd < 0){
    1302:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    1306:	79 19                	jns    1321 <createdelete+0xae>
          printf(1, "create failed\n");
    1308:	c7 44 24 04 65 4b 00 	movl   $0x4b65,0x4(%esp)
    130f:	00 
    1310:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1317:	e8 59 2e 00 00       	call   4175 <printf>
          exit();
    131c:	e8 a7 2c 00 00       	call   3fc8 <exit>
        }
        close(fd);
    1321:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1324:	89 04 24             	mov    %eax,(%esp)
    1327:	e8 c4 2c 00 00       	call   3ff0 <close>
        if(i > 0 && (i % 2 ) == 0){
    132c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1330:	7e 44                	jle    1376 <createdelete+0x103>
    1332:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1335:	83 e0 01             	and    $0x1,%eax
    1338:	85 c0                	test   %eax,%eax
    133a:	75 3a                	jne    1376 <createdelete+0x103>
          name[1] = '0' + (i / 2);
    133c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    133f:	89 c2                	mov    %eax,%edx
    1341:	c1 ea 1f             	shr    $0x1f,%edx
    1344:	01 d0                	add    %edx,%eax
    1346:	d1 f8                	sar    %eax
    1348:	83 c0 30             	add    $0x30,%eax
    134b:	88 45 c9             	mov    %al,-0x37(%ebp)
          if(unlink(name) < 0){
    134e:	8d 45 c8             	lea    -0x38(%ebp),%eax
    1351:	89 04 24             	mov    %eax,(%esp)
    1354:	e8 bf 2c 00 00       	call   4018 <unlink>
    1359:	85 c0                	test   %eax,%eax
    135b:	79 19                	jns    1376 <createdelete+0x103>
            printf(1, "unlink failed\n");
    135d:	c7 44 24 04 60 46 00 	movl   $0x4660,0x4(%esp)
    1364:	00 
    1365:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    136c:	e8 04 2e 00 00       	call   4175 <printf>
            exit();
    1371:	e8 52 2c 00 00       	call   3fc8 <exit>
    }

    if(pid == 0){
      name[0] = 'p' + pi;
      name[2] = '\0';
      for(i = 0; i < N; i++){
    1376:	ff 45 f4             	incl   -0xc(%ebp)
    1379:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    137d:	0f 8e 60 ff ff ff    	jle    12e3 <createdelete+0x70>
            printf(1, "unlink failed\n");
            exit();
          }
        }
      }
      exit();
    1383:	e8 40 2c 00 00       	call   3fc8 <exit>
  int pid, i, fd, pi;
  char name[32];

  printf(1, "createdelete test\n");

  for(pi = 0; pi < 4; pi++){
    1388:	ff 45 f0             	incl   -0x10(%ebp)
    138b:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    138f:	0f 8e 04 ff ff ff    	jle    1299 <createdelete+0x26>
      }
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    1395:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    139c:	eb 08                	jmp    13a6 <createdelete+0x133>
    wait();
    139e:	e8 2d 2c 00 00       	call   3fd0 <wait>
      }
      exit();
    }
  }

  for(pi = 0; pi < 4; pi++){
    13a3:	ff 45 f0             	incl   -0x10(%ebp)
    13a6:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    13aa:	7e f2                	jle    139e <createdelete+0x12b>
    wait();
  }

  name[0] = name[1] = name[2] = 0;
    13ac:	c6 45 ca 00          	movb   $0x0,-0x36(%ebp)
    13b0:	8a 45 ca             	mov    -0x36(%ebp),%al
    13b3:	88 45 c9             	mov    %al,-0x37(%ebp)
    13b6:	8a 45 c9             	mov    -0x37(%ebp),%al
    13b9:	88 45 c8             	mov    %al,-0x38(%ebp)
  for(i = 0; i < N; i++){
    13bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    13c3:	e9 b9 00 00 00       	jmp    1481 <createdelete+0x20e>
    for(pi = 0; pi < 4; pi++){
    13c8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    13cf:	e9 a0 00 00 00       	jmp    1474 <createdelete+0x201>
      name[0] = 'p' + pi;
    13d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
    13d7:	83 c0 70             	add    $0x70,%eax
    13da:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[1] = '0' + i;
    13dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    13e0:	83 c0 30             	add    $0x30,%eax
    13e3:	88 45 c9             	mov    %al,-0x37(%ebp)
      fd = open(name, 0);
    13e6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    13ed:	00 
    13ee:	8d 45 c8             	lea    -0x38(%ebp),%eax
    13f1:	89 04 24             	mov    %eax,(%esp)
    13f4:	e8 0f 2c 00 00       	call   4008 <open>
    13f9:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((i == 0 || i >= N/2) && fd < 0){
    13fc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1400:	74 06                	je     1408 <createdelete+0x195>
    1402:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    1406:	7e 26                	jle    142e <createdelete+0x1bb>
    1408:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    140c:	79 20                	jns    142e <createdelete+0x1bb>
        printf(1, "oops createdelete %s didn't exist\n", name);
    140e:	8d 45 c8             	lea    -0x38(%ebp),%eax
    1411:	89 44 24 08          	mov    %eax,0x8(%esp)
    1415:	c7 44 24 04 e0 4b 00 	movl   $0x4be0,0x4(%esp)
    141c:	00 
    141d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1424:	e8 4c 2d 00 00       	call   4175 <printf>
        exit();
    1429:	e8 9a 2b 00 00       	call   3fc8 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    142e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1432:	7e 2c                	jle    1460 <createdelete+0x1ed>
    1434:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
    1438:	7f 26                	jg     1460 <createdelete+0x1ed>
    143a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    143e:	78 20                	js     1460 <createdelete+0x1ed>
        printf(1, "oops createdelete %s did exist\n", name);
    1440:	8d 45 c8             	lea    -0x38(%ebp),%eax
    1443:	89 44 24 08          	mov    %eax,0x8(%esp)
    1447:	c7 44 24 04 04 4c 00 	movl   $0x4c04,0x4(%esp)
    144e:	00 
    144f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1456:	e8 1a 2d 00 00       	call   4175 <printf>
        exit();
    145b:	e8 68 2b 00 00       	call   3fc8 <exit>
      }
      if(fd >= 0)
    1460:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    1464:	78 0b                	js     1471 <createdelete+0x1fe>
        close(fd);
    1466:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1469:	89 04 24             	mov    %eax,(%esp)
    146c:	e8 7f 2b 00 00       	call   3ff0 <close>
    wait();
  }

  name[0] = name[1] = name[2] = 0;
  for(i = 0; i < N; i++){
    for(pi = 0; pi < 4; pi++){
    1471:	ff 45 f0             	incl   -0x10(%ebp)
    1474:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    1478:	0f 8e 56 ff ff ff    	jle    13d4 <createdelete+0x161>
  for(pi = 0; pi < 4; pi++){
    wait();
  }

  name[0] = name[1] = name[2] = 0;
  for(i = 0; i < N; i++){
    147e:	ff 45 f4             	incl   -0xc(%ebp)
    1481:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    1485:	0f 8e 3d ff ff ff    	jle    13c8 <createdelete+0x155>
      if(fd >= 0)
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    148b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1492:	eb 32                	jmp    14c6 <createdelete+0x253>
    for(pi = 0; pi < 4; pi++){
    1494:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    149b:	eb 20                	jmp    14bd <createdelete+0x24a>
      name[0] = 'p' + i;
    149d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14a0:	83 c0 70             	add    $0x70,%eax
    14a3:	88 45 c8             	mov    %al,-0x38(%ebp)
      name[1] = '0' + i;
    14a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    14a9:	83 c0 30             	add    $0x30,%eax
    14ac:	88 45 c9             	mov    %al,-0x37(%ebp)
      unlink(name);
    14af:	8d 45 c8             	lea    -0x38(%ebp),%eax
    14b2:	89 04 24             	mov    %eax,(%esp)
    14b5:	e8 5e 2b 00 00       	call   4018 <unlink>
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    for(pi = 0; pi < 4; pi++){
    14ba:	ff 45 f0             	incl   -0x10(%ebp)
    14bd:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
    14c1:	7e da                	jle    149d <createdelete+0x22a>
      if(fd >= 0)
        close(fd);
    }
  }

  for(i = 0; i < N; i++){
    14c3:	ff 45 f4             	incl   -0xc(%ebp)
    14c6:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    14ca:	7e c8                	jle    1494 <createdelete+0x221>
      name[1] = '0' + i;
      unlink(name);
    }
  }

  printf(1, "createdelete ok\n");
    14cc:	c7 44 24 04 24 4c 00 	movl   $0x4c24,0x4(%esp)
    14d3:	00 
    14d4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    14db:	e8 95 2c 00 00       	call   4175 <printf>
}
    14e0:	c9                   	leave  
    14e1:	c3                   	ret    

000014e2 <unlinkread>:

// can I unlink a file and still read it?
void
unlinkread(void)
{
    14e2:	55                   	push   %ebp
    14e3:	89 e5                	mov    %esp,%ebp
    14e5:	83 ec 28             	sub    $0x28,%esp
  int fd, fd1;

  printf(1, "unlinkread test\n");
    14e8:	c7 44 24 04 35 4c 00 	movl   $0x4c35,0x4(%esp)
    14ef:	00 
    14f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    14f7:	e8 79 2c 00 00       	call   4175 <printf>
  fd = open("unlinkread", O_CREATE | O_RDWR);
    14fc:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1503:	00 
    1504:	c7 04 24 46 4c 00 00 	movl   $0x4c46,(%esp)
    150b:	e8 f8 2a 00 00       	call   4008 <open>
    1510:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1513:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1517:	79 19                	jns    1532 <unlinkread+0x50>
    printf(1, "create unlinkread failed\n");
    1519:	c7 44 24 04 51 4c 00 	movl   $0x4c51,0x4(%esp)
    1520:	00 
    1521:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1528:	e8 48 2c 00 00       	call   4175 <printf>
    exit();
    152d:	e8 96 2a 00 00       	call   3fc8 <exit>
  }
  write(fd, "hello", 5);
    1532:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    1539:	00 
    153a:	c7 44 24 04 6b 4c 00 	movl   $0x4c6b,0x4(%esp)
    1541:	00 
    1542:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1545:	89 04 24             	mov    %eax,(%esp)
    1548:	e8 9b 2a 00 00       	call   3fe8 <write>
  close(fd);
    154d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1550:	89 04 24             	mov    %eax,(%esp)
    1553:	e8 98 2a 00 00       	call   3ff0 <close>

  fd = open("unlinkread", O_RDWR);
    1558:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    155f:	00 
    1560:	c7 04 24 46 4c 00 00 	movl   $0x4c46,(%esp)
    1567:	e8 9c 2a 00 00       	call   4008 <open>
    156c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    156f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1573:	79 19                	jns    158e <unlinkread+0xac>
    printf(1, "open unlinkread failed\n");
    1575:	c7 44 24 04 71 4c 00 	movl   $0x4c71,0x4(%esp)
    157c:	00 
    157d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1584:	e8 ec 2b 00 00       	call   4175 <printf>
    exit();
    1589:	e8 3a 2a 00 00       	call   3fc8 <exit>
  }
  if(unlink("unlinkread") != 0){
    158e:	c7 04 24 46 4c 00 00 	movl   $0x4c46,(%esp)
    1595:	e8 7e 2a 00 00       	call   4018 <unlink>
    159a:	85 c0                	test   %eax,%eax
    159c:	74 19                	je     15b7 <unlinkread+0xd5>
    printf(1, "unlink unlinkread failed\n");
    159e:	c7 44 24 04 89 4c 00 	movl   $0x4c89,0x4(%esp)
    15a5:	00 
    15a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    15ad:	e8 c3 2b 00 00       	call   4175 <printf>
    exit();
    15b2:	e8 11 2a 00 00       	call   3fc8 <exit>
  }

  fd1 = open("unlinkread", O_CREATE | O_RDWR);
    15b7:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    15be:	00 
    15bf:	c7 04 24 46 4c 00 00 	movl   $0x4c46,(%esp)
    15c6:	e8 3d 2a 00 00       	call   4008 <open>
    15cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  write(fd1, "yyy", 3);
    15ce:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
    15d5:	00 
    15d6:	c7 44 24 04 a3 4c 00 	movl   $0x4ca3,0x4(%esp)
    15dd:	00 
    15de:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15e1:	89 04 24             	mov    %eax,(%esp)
    15e4:	e8 ff 29 00 00       	call   3fe8 <write>
  close(fd1);
    15e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
    15ec:	89 04 24             	mov    %eax,(%esp)
    15ef:	e8 fc 29 00 00       	call   3ff0 <close>

  if(read(fd, buf, sizeof(buf)) != 5){
    15f4:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    15fb:	00 
    15fc:	c7 44 24 04 a0 8c 00 	movl   $0x8ca0,0x4(%esp)
    1603:	00 
    1604:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1607:	89 04 24             	mov    %eax,(%esp)
    160a:	e8 d1 29 00 00       	call   3fe0 <read>
    160f:	83 f8 05             	cmp    $0x5,%eax
    1612:	74 19                	je     162d <unlinkread+0x14b>
    printf(1, "unlinkread read failed");
    1614:	c7 44 24 04 a7 4c 00 	movl   $0x4ca7,0x4(%esp)
    161b:	00 
    161c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1623:	e8 4d 2b 00 00       	call   4175 <printf>
    exit();
    1628:	e8 9b 29 00 00       	call   3fc8 <exit>
  }
  if(buf[0] != 'h'){
    162d:	a0 a0 8c 00 00       	mov    0x8ca0,%al
    1632:	3c 68                	cmp    $0x68,%al
    1634:	74 19                	je     164f <unlinkread+0x16d>
    printf(1, "unlinkread wrong data\n");
    1636:	c7 44 24 04 be 4c 00 	movl   $0x4cbe,0x4(%esp)
    163d:	00 
    163e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1645:	e8 2b 2b 00 00       	call   4175 <printf>
    exit();
    164a:	e8 79 29 00 00       	call   3fc8 <exit>
  }
  if(write(fd, buf, 10) != 10){
    164f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    1656:	00 
    1657:	c7 44 24 04 a0 8c 00 	movl   $0x8ca0,0x4(%esp)
    165e:	00 
    165f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1662:	89 04 24             	mov    %eax,(%esp)
    1665:	e8 7e 29 00 00       	call   3fe8 <write>
    166a:	83 f8 0a             	cmp    $0xa,%eax
    166d:	74 19                	je     1688 <unlinkread+0x1a6>
    printf(1, "unlinkread write failed\n");
    166f:	c7 44 24 04 d5 4c 00 	movl   $0x4cd5,0x4(%esp)
    1676:	00 
    1677:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    167e:	e8 f2 2a 00 00       	call   4175 <printf>
    exit();
    1683:	e8 40 29 00 00       	call   3fc8 <exit>
  }
  close(fd);
    1688:	8b 45 f4             	mov    -0xc(%ebp),%eax
    168b:	89 04 24             	mov    %eax,(%esp)
    168e:	e8 5d 29 00 00       	call   3ff0 <close>
  unlink("unlinkread");
    1693:	c7 04 24 46 4c 00 00 	movl   $0x4c46,(%esp)
    169a:	e8 79 29 00 00       	call   4018 <unlink>
  printf(1, "unlinkread ok\n");
    169f:	c7 44 24 04 ee 4c 00 	movl   $0x4cee,0x4(%esp)
    16a6:	00 
    16a7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    16ae:	e8 c2 2a 00 00       	call   4175 <printf>
}
    16b3:	c9                   	leave  
    16b4:	c3                   	ret    

000016b5 <linktest>:

void
linktest(void)
{
    16b5:	55                   	push   %ebp
    16b6:	89 e5                	mov    %esp,%ebp
    16b8:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(1, "linktest\n");
    16bb:	c7 44 24 04 fd 4c 00 	movl   $0x4cfd,0x4(%esp)
    16c2:	00 
    16c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    16ca:	e8 a6 2a 00 00       	call   4175 <printf>

  unlink("lf1");
    16cf:	c7 04 24 07 4d 00 00 	movl   $0x4d07,(%esp)
    16d6:	e8 3d 29 00 00       	call   4018 <unlink>
  unlink("lf2");
    16db:	c7 04 24 0b 4d 00 00 	movl   $0x4d0b,(%esp)
    16e2:	e8 31 29 00 00       	call   4018 <unlink>

  fd = open("lf1", O_CREATE|O_RDWR);
    16e7:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    16ee:	00 
    16ef:	c7 04 24 07 4d 00 00 	movl   $0x4d07,(%esp)
    16f6:	e8 0d 29 00 00       	call   4008 <open>
    16fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    16fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1702:	79 19                	jns    171d <linktest+0x68>
    printf(1, "create lf1 failed\n");
    1704:	c7 44 24 04 0f 4d 00 	movl   $0x4d0f,0x4(%esp)
    170b:	00 
    170c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1713:	e8 5d 2a 00 00       	call   4175 <printf>
    exit();
    1718:	e8 ab 28 00 00       	call   3fc8 <exit>
  }
  if(write(fd, "hello", 5) != 5){
    171d:	c7 44 24 08 05 00 00 	movl   $0x5,0x8(%esp)
    1724:	00 
    1725:	c7 44 24 04 6b 4c 00 	movl   $0x4c6b,0x4(%esp)
    172c:	00 
    172d:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1730:	89 04 24             	mov    %eax,(%esp)
    1733:	e8 b0 28 00 00       	call   3fe8 <write>
    1738:	83 f8 05             	cmp    $0x5,%eax
    173b:	74 19                	je     1756 <linktest+0xa1>
    printf(1, "write lf1 failed\n");
    173d:	c7 44 24 04 22 4d 00 	movl   $0x4d22,0x4(%esp)
    1744:	00 
    1745:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    174c:	e8 24 2a 00 00       	call   4175 <printf>
    exit();
    1751:	e8 72 28 00 00       	call   3fc8 <exit>
  }
  close(fd);
    1756:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1759:	89 04 24             	mov    %eax,(%esp)
    175c:	e8 8f 28 00 00       	call   3ff0 <close>

  if(link("lf1", "lf2") < 0){
    1761:	c7 44 24 04 0b 4d 00 	movl   $0x4d0b,0x4(%esp)
    1768:	00 
    1769:	c7 04 24 07 4d 00 00 	movl   $0x4d07,(%esp)
    1770:	e8 b3 28 00 00       	call   4028 <link>
    1775:	85 c0                	test   %eax,%eax
    1777:	79 19                	jns    1792 <linktest+0xdd>
    printf(1, "link lf1 lf2 failed\n");
    1779:	c7 44 24 04 34 4d 00 	movl   $0x4d34,0x4(%esp)
    1780:	00 
    1781:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1788:	e8 e8 29 00 00       	call   4175 <printf>
    exit();
    178d:	e8 36 28 00 00       	call   3fc8 <exit>
  }
  unlink("lf1");
    1792:	c7 04 24 07 4d 00 00 	movl   $0x4d07,(%esp)
    1799:	e8 7a 28 00 00       	call   4018 <unlink>

  if(open("lf1", 0) >= 0){
    179e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    17a5:	00 
    17a6:	c7 04 24 07 4d 00 00 	movl   $0x4d07,(%esp)
    17ad:	e8 56 28 00 00       	call   4008 <open>
    17b2:	85 c0                	test   %eax,%eax
    17b4:	78 19                	js     17cf <linktest+0x11a>
    printf(1, "unlinked lf1 but it is still there!\n");
    17b6:	c7 44 24 04 4c 4d 00 	movl   $0x4d4c,0x4(%esp)
    17bd:	00 
    17be:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    17c5:	e8 ab 29 00 00       	call   4175 <printf>
    exit();
    17ca:	e8 f9 27 00 00       	call   3fc8 <exit>
  }

  fd = open("lf2", 0);
    17cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    17d6:	00 
    17d7:	c7 04 24 0b 4d 00 00 	movl   $0x4d0b,(%esp)
    17de:	e8 25 28 00 00       	call   4008 <open>
    17e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    17e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    17ea:	79 19                	jns    1805 <linktest+0x150>
    printf(1, "open lf2 failed\n");
    17ec:	c7 44 24 04 71 4d 00 	movl   $0x4d71,0x4(%esp)
    17f3:	00 
    17f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    17fb:	e8 75 29 00 00       	call   4175 <printf>
    exit();
    1800:	e8 c3 27 00 00       	call   3fc8 <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 5){
    1805:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    180c:	00 
    180d:	c7 44 24 04 a0 8c 00 	movl   $0x8ca0,0x4(%esp)
    1814:	00 
    1815:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1818:	89 04 24             	mov    %eax,(%esp)
    181b:	e8 c0 27 00 00       	call   3fe0 <read>
    1820:	83 f8 05             	cmp    $0x5,%eax
    1823:	74 19                	je     183e <linktest+0x189>
    printf(1, "read lf2 failed\n");
    1825:	c7 44 24 04 82 4d 00 	movl   $0x4d82,0x4(%esp)
    182c:	00 
    182d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1834:	e8 3c 29 00 00       	call   4175 <printf>
    exit();
    1839:	e8 8a 27 00 00       	call   3fc8 <exit>
  }
  close(fd);
    183e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1841:	89 04 24             	mov    %eax,(%esp)
    1844:	e8 a7 27 00 00       	call   3ff0 <close>

  if(link("lf2", "lf2") >= 0){
    1849:	c7 44 24 04 0b 4d 00 	movl   $0x4d0b,0x4(%esp)
    1850:	00 
    1851:	c7 04 24 0b 4d 00 00 	movl   $0x4d0b,(%esp)
    1858:	e8 cb 27 00 00       	call   4028 <link>
    185d:	85 c0                	test   %eax,%eax
    185f:	78 19                	js     187a <linktest+0x1c5>
    printf(1, "link lf2 lf2 succeeded! oops\n");
    1861:	c7 44 24 04 93 4d 00 	movl   $0x4d93,0x4(%esp)
    1868:	00 
    1869:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1870:	e8 00 29 00 00       	call   4175 <printf>
    exit();
    1875:	e8 4e 27 00 00       	call   3fc8 <exit>
  }

  unlink("lf2");
    187a:	c7 04 24 0b 4d 00 00 	movl   $0x4d0b,(%esp)
    1881:	e8 92 27 00 00       	call   4018 <unlink>
  if(link("lf2", "lf1") >= 0){
    1886:	c7 44 24 04 07 4d 00 	movl   $0x4d07,0x4(%esp)
    188d:	00 
    188e:	c7 04 24 0b 4d 00 00 	movl   $0x4d0b,(%esp)
    1895:	e8 8e 27 00 00       	call   4028 <link>
    189a:	85 c0                	test   %eax,%eax
    189c:	78 19                	js     18b7 <linktest+0x202>
    printf(1, "link non-existant succeeded! oops\n");
    189e:	c7 44 24 04 b4 4d 00 	movl   $0x4db4,0x4(%esp)
    18a5:	00 
    18a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    18ad:	e8 c3 28 00 00       	call   4175 <printf>
    exit();
    18b2:	e8 11 27 00 00       	call   3fc8 <exit>
  }

  if(link(".", "lf1") >= 0){
    18b7:	c7 44 24 04 07 4d 00 	movl   $0x4d07,0x4(%esp)
    18be:	00 
    18bf:	c7 04 24 d7 4d 00 00 	movl   $0x4dd7,(%esp)
    18c6:	e8 5d 27 00 00       	call   4028 <link>
    18cb:	85 c0                	test   %eax,%eax
    18cd:	78 19                	js     18e8 <linktest+0x233>
    printf(1, "link . lf1 succeeded! oops\n");
    18cf:	c7 44 24 04 d9 4d 00 	movl   $0x4dd9,0x4(%esp)
    18d6:	00 
    18d7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    18de:	e8 92 28 00 00       	call   4175 <printf>
    exit();
    18e3:	e8 e0 26 00 00       	call   3fc8 <exit>
  }

  printf(1, "linktest ok\n");
    18e8:	c7 44 24 04 f5 4d 00 	movl   $0x4df5,0x4(%esp)
    18ef:	00 
    18f0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    18f7:	e8 79 28 00 00       	call   4175 <printf>
}
    18fc:	c9                   	leave  
    18fd:	c3                   	ret    

000018fe <concreate>:

// test concurrent create/link/unlink of the same file
void
concreate(void)
{
    18fe:	55                   	push   %ebp
    18ff:	89 e5                	mov    %esp,%ebp
    1901:	83 ec 68             	sub    $0x68,%esp
  struct {
    ushort inum;
    char name[14];
  } de;

  printf(1, "concreate test\n");
    1904:	c7 44 24 04 02 4e 00 	movl   $0x4e02,0x4(%esp)
    190b:	00 
    190c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1913:	e8 5d 28 00 00       	call   4175 <printf>
  file[0] = 'C';
    1918:	c6 45 e5 43          	movb   $0x43,-0x1b(%ebp)
  file[2] = '\0';
    191c:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
  for(i = 0; i < 40; i++){
    1920:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1927:	e9 d0 00 00 00       	jmp    19fc <concreate+0xfe>
    file[1] = '0' + i;
    192c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    192f:	83 c0 30             	add    $0x30,%eax
    1932:	88 45 e6             	mov    %al,-0x1a(%ebp)
    unlink(file);
    1935:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1938:	89 04 24             	mov    %eax,(%esp)
    193b:	e8 d8 26 00 00       	call   4018 <unlink>
    pid = fork();
    1940:	e8 7b 26 00 00       	call   3fc0 <fork>
    1945:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid && (i % 3) == 1){
    1948:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    194c:	74 27                	je     1975 <concreate+0x77>
    194e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1951:	b9 03 00 00 00       	mov    $0x3,%ecx
    1956:	99                   	cltd   
    1957:	f7 f9                	idiv   %ecx
    1959:	89 d0                	mov    %edx,%eax
    195b:	83 f8 01             	cmp    $0x1,%eax
    195e:	75 15                	jne    1975 <concreate+0x77>
      link("C0", file);
    1960:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1963:	89 44 24 04          	mov    %eax,0x4(%esp)
    1967:	c7 04 24 12 4e 00 00 	movl   $0x4e12,(%esp)
    196e:	e8 b5 26 00 00       	call   4028 <link>
    1973:	eb 74                	jmp    19e9 <concreate+0xeb>
    } else if(pid == 0 && (i % 5) == 1){
    1975:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1979:	75 27                	jne    19a2 <concreate+0xa4>
    197b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    197e:	b9 05 00 00 00       	mov    $0x5,%ecx
    1983:	99                   	cltd   
    1984:	f7 f9                	idiv   %ecx
    1986:	89 d0                	mov    %edx,%eax
    1988:	83 f8 01             	cmp    $0x1,%eax
    198b:	75 15                	jne    19a2 <concreate+0xa4>
      link("C0", file);
    198d:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1990:	89 44 24 04          	mov    %eax,0x4(%esp)
    1994:	c7 04 24 12 4e 00 00 	movl   $0x4e12,(%esp)
    199b:	e8 88 26 00 00       	call   4028 <link>
    19a0:	eb 47                	jmp    19e9 <concreate+0xeb>
    } else {
      fd = open(file, O_CREATE | O_RDWR);
    19a2:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    19a9:	00 
    19aa:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    19ad:	89 04 24             	mov    %eax,(%esp)
    19b0:	e8 53 26 00 00       	call   4008 <open>
    19b5:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(fd < 0){
    19b8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    19bc:	79 20                	jns    19de <concreate+0xe0>
        printf(1, "concreate create %s failed\n", file);
    19be:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    19c1:	89 44 24 08          	mov    %eax,0x8(%esp)
    19c5:	c7 44 24 04 15 4e 00 	movl   $0x4e15,0x4(%esp)
    19cc:	00 
    19cd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    19d4:	e8 9c 27 00 00       	call   4175 <printf>
        exit();
    19d9:	e8 ea 25 00 00       	call   3fc8 <exit>
      }
      close(fd);
    19de:	8b 45 e8             	mov    -0x18(%ebp),%eax
    19e1:	89 04 24             	mov    %eax,(%esp)
    19e4:	e8 07 26 00 00       	call   3ff0 <close>
    }
    if(pid == 0)
    19e9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    19ed:	75 05                	jne    19f4 <concreate+0xf6>
      exit();
    19ef:	e8 d4 25 00 00       	call   3fc8 <exit>
    else
      wait();
    19f4:	e8 d7 25 00 00       	call   3fd0 <wait>
  } de;

  printf(1, "concreate test\n");
  file[0] = 'C';
  file[2] = '\0';
  for(i = 0; i < 40; i++){
    19f9:	ff 45 f4             	incl   -0xc(%ebp)
    19fc:	83 7d f4 27          	cmpl   $0x27,-0xc(%ebp)
    1a00:	0f 8e 26 ff ff ff    	jle    192c <concreate+0x2e>
      exit();
    else
      wait();
  }

  memset(fa, 0, sizeof(fa));
    1a06:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
    1a0d:	00 
    1a0e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1a15:	00 
    1a16:	8d 45 bd             	lea    -0x43(%ebp),%eax
    1a19:	89 04 24             	mov    %eax,(%esp)
    1a1c:	e8 03 24 00 00       	call   3e24 <memset>
  fd = open(".", 0);
    1a21:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1a28:	00 
    1a29:	c7 04 24 d7 4d 00 00 	movl   $0x4dd7,(%esp)
    1a30:	e8 d3 25 00 00       	call   4008 <open>
    1a35:	89 45 e8             	mov    %eax,-0x18(%ebp)
  n = 0;
    1a38:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  while(read(fd, &de, sizeof(de)) > 0){
    1a3f:	e9 9b 00 00 00       	jmp    1adf <concreate+0x1e1>
    if(de.inum == 0)
    1a44:	8b 45 ac             	mov    -0x54(%ebp),%eax
    1a47:	66 85 c0             	test   %ax,%ax
    1a4a:	75 05                	jne    1a51 <concreate+0x153>
      continue;
    1a4c:	e9 8e 00 00 00       	jmp    1adf <concreate+0x1e1>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    1a51:	8a 45 ae             	mov    -0x52(%ebp),%al
    1a54:	3c 43                	cmp    $0x43,%al
    1a56:	0f 85 83 00 00 00    	jne    1adf <concreate+0x1e1>
    1a5c:	8a 45 b0             	mov    -0x50(%ebp),%al
    1a5f:	84 c0                	test   %al,%al
    1a61:	75 7c                	jne    1adf <concreate+0x1e1>
      i = de.name[1] - '0';
    1a63:	8a 45 af             	mov    -0x51(%ebp),%al
    1a66:	0f be c0             	movsbl %al,%eax
    1a69:	83 e8 30             	sub    $0x30,%eax
    1a6c:	89 45 f4             	mov    %eax,-0xc(%ebp)
      if(i < 0 || i >= sizeof(fa)){
    1a6f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1a73:	78 08                	js     1a7d <concreate+0x17f>
    1a75:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1a78:	83 f8 27             	cmp    $0x27,%eax
    1a7b:	76 23                	jbe    1aa0 <concreate+0x1a2>
        printf(1, "concreate weird file %s\n", de.name);
    1a7d:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1a80:	83 c0 02             	add    $0x2,%eax
    1a83:	89 44 24 08          	mov    %eax,0x8(%esp)
    1a87:	c7 44 24 04 31 4e 00 	movl   $0x4e31,0x4(%esp)
    1a8e:	00 
    1a8f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1a96:	e8 da 26 00 00       	call   4175 <printf>
        exit();
    1a9b:	e8 28 25 00 00       	call   3fc8 <exit>
      }
      if(fa[i]){
    1aa0:	8d 55 bd             	lea    -0x43(%ebp),%edx
    1aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1aa6:	01 d0                	add    %edx,%eax
    1aa8:	8a 00                	mov    (%eax),%al
    1aaa:	84 c0                	test   %al,%al
    1aac:	74 23                	je     1ad1 <concreate+0x1d3>
        printf(1, "concreate duplicate file %s\n", de.name);
    1aae:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1ab1:	83 c0 02             	add    $0x2,%eax
    1ab4:	89 44 24 08          	mov    %eax,0x8(%esp)
    1ab8:	c7 44 24 04 4a 4e 00 	movl   $0x4e4a,0x4(%esp)
    1abf:	00 
    1ac0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ac7:	e8 a9 26 00 00       	call   4175 <printf>
        exit();
    1acc:	e8 f7 24 00 00       	call   3fc8 <exit>
      }
      fa[i] = 1;
    1ad1:	8d 55 bd             	lea    -0x43(%ebp),%edx
    1ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1ad7:	01 d0                	add    %edx,%eax
    1ad9:	c6 00 01             	movb   $0x1,(%eax)
      n++;
    1adc:	ff 45 f0             	incl   -0x10(%ebp)
  }

  memset(fa, 0, sizeof(fa));
  fd = open(".", 0);
  n = 0;
  while(read(fd, &de, sizeof(de)) > 0){
    1adf:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    1ae6:	00 
    1ae7:	8d 45 ac             	lea    -0x54(%ebp),%eax
    1aea:	89 44 24 04          	mov    %eax,0x4(%esp)
    1aee:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1af1:	89 04 24             	mov    %eax,(%esp)
    1af4:	e8 e7 24 00 00       	call   3fe0 <read>
    1af9:	85 c0                	test   %eax,%eax
    1afb:	0f 8f 43 ff ff ff    	jg     1a44 <concreate+0x146>
      }
      fa[i] = 1;
      n++;
    }
  }
  close(fd);
    1b01:	8b 45 e8             	mov    -0x18(%ebp),%eax
    1b04:	89 04 24             	mov    %eax,(%esp)
    1b07:	e8 e4 24 00 00       	call   3ff0 <close>

  if(n != 40){
    1b0c:	83 7d f0 28          	cmpl   $0x28,-0x10(%ebp)
    1b10:	74 19                	je     1b2b <concreate+0x22d>
    printf(1, "concreate not enough files in directory listing\n");
    1b12:	c7 44 24 04 68 4e 00 	movl   $0x4e68,0x4(%esp)
    1b19:	00 
    1b1a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b21:	e8 4f 26 00 00       	call   4175 <printf>
    exit();
    1b26:	e8 9d 24 00 00       	call   3fc8 <exit>
  }

  for(i = 0; i < 40; i++){
    1b2b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1b32:	e9 0c 01 00 00       	jmp    1c43 <concreate+0x345>
    file[1] = '0' + i;
    1b37:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1b3a:	83 c0 30             	add    $0x30,%eax
    1b3d:	88 45 e6             	mov    %al,-0x1a(%ebp)
    pid = fork();
    1b40:	e8 7b 24 00 00       	call   3fc0 <fork>
    1b45:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(pid < 0){
    1b48:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1b4c:	79 19                	jns    1b67 <concreate+0x269>
      printf(1, "fork failed\n");
    1b4e:	c7 44 24 04 dd 45 00 	movl   $0x45dd,0x4(%esp)
    1b55:	00 
    1b56:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1b5d:	e8 13 26 00 00       	call   4175 <printf>
      exit();
    1b62:	e8 61 24 00 00       	call   3fc8 <exit>
    }
    if(((i % 3) == 0 && pid == 0) ||
    1b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1b6a:	b9 03 00 00 00       	mov    $0x3,%ecx
    1b6f:	99                   	cltd   
    1b70:	f7 f9                	idiv   %ecx
    1b72:	89 d0                	mov    %edx,%eax
    1b74:	85 c0                	test   %eax,%eax
    1b76:	75 06                	jne    1b7e <concreate+0x280>
    1b78:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1b7c:	74 18                	je     1b96 <concreate+0x298>
       ((i % 3) == 1 && pid != 0)){
    1b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1b81:	b9 03 00 00 00       	mov    $0x3,%ecx
    1b86:	99                   	cltd   
    1b87:	f7 f9                	idiv   %ecx
    1b89:	89 d0                	mov    %edx,%eax
    pid = fork();
    if(pid < 0){
      printf(1, "fork failed\n");
      exit();
    }
    if(((i % 3) == 0 && pid == 0) ||
    1b8b:	83 f8 01             	cmp    $0x1,%eax
    1b8e:	75 74                	jne    1c04 <concreate+0x306>
       ((i % 3) == 1 && pid != 0)){
    1b90:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1b94:	74 6e                	je     1c04 <concreate+0x306>
      close(open(file, 0));
    1b96:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1b9d:	00 
    1b9e:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1ba1:	89 04 24             	mov    %eax,(%esp)
    1ba4:	e8 5f 24 00 00       	call   4008 <open>
    1ba9:	89 04 24             	mov    %eax,(%esp)
    1bac:	e8 3f 24 00 00       	call   3ff0 <close>
      close(open(file, 0));
    1bb1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1bb8:	00 
    1bb9:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1bbc:	89 04 24             	mov    %eax,(%esp)
    1bbf:	e8 44 24 00 00       	call   4008 <open>
    1bc4:	89 04 24             	mov    %eax,(%esp)
    1bc7:	e8 24 24 00 00       	call   3ff0 <close>
      close(open(file, 0));
    1bcc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1bd3:	00 
    1bd4:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1bd7:	89 04 24             	mov    %eax,(%esp)
    1bda:	e8 29 24 00 00       	call   4008 <open>
    1bdf:	89 04 24             	mov    %eax,(%esp)
    1be2:	e8 09 24 00 00       	call   3ff0 <close>
      close(open(file, 0));
    1be7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    1bee:	00 
    1bef:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1bf2:	89 04 24             	mov    %eax,(%esp)
    1bf5:	e8 0e 24 00 00       	call   4008 <open>
    1bfa:	89 04 24             	mov    %eax,(%esp)
    1bfd:	e8 ee 23 00 00       	call   3ff0 <close>
    1c02:	eb 2c                	jmp    1c30 <concreate+0x332>
    } else {
      unlink(file);
    1c04:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c07:	89 04 24             	mov    %eax,(%esp)
    1c0a:	e8 09 24 00 00       	call   4018 <unlink>
      unlink(file);
    1c0f:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c12:	89 04 24             	mov    %eax,(%esp)
    1c15:	e8 fe 23 00 00       	call   4018 <unlink>
      unlink(file);
    1c1a:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c1d:	89 04 24             	mov    %eax,(%esp)
    1c20:	e8 f3 23 00 00       	call   4018 <unlink>
      unlink(file);
    1c25:	8d 45 e5             	lea    -0x1b(%ebp),%eax
    1c28:	89 04 24             	mov    %eax,(%esp)
    1c2b:	e8 e8 23 00 00       	call   4018 <unlink>
    }
    if(pid == 0)
    1c30:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1c34:	75 05                	jne    1c3b <concreate+0x33d>
      exit();
    1c36:	e8 8d 23 00 00       	call   3fc8 <exit>
    else
      wait();
    1c3b:	e8 90 23 00 00       	call   3fd0 <wait>
  if(n != 40){
    printf(1, "concreate not enough files in directory listing\n");
    exit();
  }

  for(i = 0; i < 40; i++){
    1c40:	ff 45 f4             	incl   -0xc(%ebp)
    1c43:	83 7d f4 27          	cmpl   $0x27,-0xc(%ebp)
    1c47:	0f 8e ea fe ff ff    	jle    1b37 <concreate+0x239>
      exit();
    else
      wait();
  }

  printf(1, "concreate ok\n");
    1c4d:	c7 44 24 04 99 4e 00 	movl   $0x4e99,0x4(%esp)
    1c54:	00 
    1c55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1c5c:	e8 14 25 00 00       	call   4175 <printf>
}
    1c61:	c9                   	leave  
    1c62:	c3                   	ret    

00001c63 <linkunlink>:

// another concurrent link/unlink/create test,
// to look for deadlocks.
void
linkunlink()
{
    1c63:	55                   	push   %ebp
    1c64:	89 e5                	mov    %esp,%ebp
    1c66:	83 ec 28             	sub    $0x28,%esp
  int pid, i;

  printf(1, "linkunlink test\n");
    1c69:	c7 44 24 04 a7 4e 00 	movl   $0x4ea7,0x4(%esp)
    1c70:	00 
    1c71:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1c78:	e8 f8 24 00 00       	call   4175 <printf>

  unlink("x");
    1c7d:	c7 04 24 13 4a 00 00 	movl   $0x4a13,(%esp)
    1c84:	e8 8f 23 00 00       	call   4018 <unlink>
  pid = fork();
    1c89:	e8 32 23 00 00       	call   3fc0 <fork>
    1c8e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(pid < 0){
    1c91:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1c95:	79 19                	jns    1cb0 <linkunlink+0x4d>
    printf(1, "fork failed\n");
    1c97:	c7 44 24 04 dd 45 00 	movl   $0x45dd,0x4(%esp)
    1c9e:	00 
    1c9f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1ca6:	e8 ca 24 00 00       	call   4175 <printf>
    exit();
    1cab:	e8 18 23 00 00       	call   3fc8 <exit>
  }

  unsigned int x = (pid ? 1 : 97);
    1cb0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1cb4:	74 07                	je     1cbd <linkunlink+0x5a>
    1cb6:	b8 01 00 00 00       	mov    $0x1,%eax
    1cbb:	eb 05                	jmp    1cc2 <linkunlink+0x5f>
    1cbd:	b8 61 00 00 00       	mov    $0x61,%eax
    1cc2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; i < 100; i++){
    1cc5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1ccc:	e9 a5 00 00 00       	jmp    1d76 <linkunlink+0x113>
    x = x * 1103515245 + 12345;
    1cd1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
    1cd4:	89 ca                	mov    %ecx,%edx
    1cd6:	89 d0                	mov    %edx,%eax
    1cd8:	c1 e0 09             	shl    $0x9,%eax
    1cdb:	89 c2                	mov    %eax,%edx
    1cdd:	29 ca                	sub    %ecx,%edx
    1cdf:	c1 e2 02             	shl    $0x2,%edx
    1ce2:	01 ca                	add    %ecx,%edx
    1ce4:	89 d0                	mov    %edx,%eax
    1ce6:	c1 e0 09             	shl    $0x9,%eax
    1ce9:	29 d0                	sub    %edx,%eax
    1ceb:	01 c0                	add    %eax,%eax
    1ced:	01 c8                	add    %ecx,%eax
    1cef:	89 c2                	mov    %eax,%edx
    1cf1:	c1 e2 05             	shl    $0x5,%edx
    1cf4:	01 d0                	add    %edx,%eax
    1cf6:	c1 e0 02             	shl    $0x2,%eax
    1cf9:	29 c8                	sub    %ecx,%eax
    1cfb:	c1 e0 02             	shl    $0x2,%eax
    1cfe:	01 c8                	add    %ecx,%eax
    1d00:	05 39 30 00 00       	add    $0x3039,%eax
    1d05:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((x % 3) == 0){
    1d08:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1d0b:	b9 03 00 00 00       	mov    $0x3,%ecx
    1d10:	ba 00 00 00 00       	mov    $0x0,%edx
    1d15:	f7 f1                	div    %ecx
    1d17:	89 d0                	mov    %edx,%eax
    1d19:	85 c0                	test   %eax,%eax
    1d1b:	75 1e                	jne    1d3b <linkunlink+0xd8>
      close(open("x", O_RDWR | O_CREATE));
    1d1d:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1d24:	00 
    1d25:	c7 04 24 13 4a 00 00 	movl   $0x4a13,(%esp)
    1d2c:	e8 d7 22 00 00       	call   4008 <open>
    1d31:	89 04 24             	mov    %eax,(%esp)
    1d34:	e8 b7 22 00 00       	call   3ff0 <close>
    1d39:	eb 38                	jmp    1d73 <linkunlink+0x110>
    } else if((x % 3) == 1){
    1d3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1d3e:	b9 03 00 00 00       	mov    $0x3,%ecx
    1d43:	ba 00 00 00 00       	mov    $0x0,%edx
    1d48:	f7 f1                	div    %ecx
    1d4a:	89 d0                	mov    %edx,%eax
    1d4c:	83 f8 01             	cmp    $0x1,%eax
    1d4f:	75 16                	jne    1d67 <linkunlink+0x104>
      link("cat", "x");
    1d51:	c7 44 24 04 13 4a 00 	movl   $0x4a13,0x4(%esp)
    1d58:	00 
    1d59:	c7 04 24 b8 4e 00 00 	movl   $0x4eb8,(%esp)
    1d60:	e8 c3 22 00 00       	call   4028 <link>
    1d65:	eb 0c                	jmp    1d73 <linkunlink+0x110>
    } else {
      unlink("x");
    1d67:	c7 04 24 13 4a 00 00 	movl   $0x4a13,(%esp)
    1d6e:	e8 a5 22 00 00       	call   4018 <unlink>
    printf(1, "fork failed\n");
    exit();
  }

  unsigned int x = (pid ? 1 : 97);
  for(i = 0; i < 100; i++){
    1d73:	ff 45 f4             	incl   -0xc(%ebp)
    1d76:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
    1d7a:	0f 8e 51 ff ff ff    	jle    1cd1 <linkunlink+0x6e>
    } else {
      unlink("x");
    }
  }

  if(pid)
    1d80:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    1d84:	74 07                	je     1d8d <linkunlink+0x12a>
    wait();
    1d86:	e8 45 22 00 00       	call   3fd0 <wait>
    1d8b:	eb 05                	jmp    1d92 <linkunlink+0x12f>
  else
    exit();
    1d8d:	e8 36 22 00 00       	call   3fc8 <exit>

  printf(1, "linkunlink ok\n");
    1d92:	c7 44 24 04 bc 4e 00 	movl   $0x4ebc,0x4(%esp)
    1d99:	00 
    1d9a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1da1:	e8 cf 23 00 00       	call   4175 <printf>
}
    1da6:	c9                   	leave  
    1da7:	c3                   	ret    

00001da8 <bigdir>:

// directory that uses indirect blocks
void
bigdir(void)
{
    1da8:	55                   	push   %ebp
    1da9:	89 e5                	mov    %esp,%ebp
    1dab:	83 ec 38             	sub    $0x38,%esp
  int i, fd;
  char name[10];

  printf(1, "bigdir test\n");
    1dae:	c7 44 24 04 cb 4e 00 	movl   $0x4ecb,0x4(%esp)
    1db5:	00 
    1db6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1dbd:	e8 b3 23 00 00       	call   4175 <printf>
  unlink("bd");
    1dc2:	c7 04 24 d8 4e 00 00 	movl   $0x4ed8,(%esp)
    1dc9:	e8 4a 22 00 00       	call   4018 <unlink>

  fd = open("bd", O_CREATE);
    1dce:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    1dd5:	00 
    1dd6:	c7 04 24 d8 4e 00 00 	movl   $0x4ed8,(%esp)
    1ddd:	e8 26 22 00 00       	call   4008 <open>
    1de2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(fd < 0){
    1de5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    1de9:	79 19                	jns    1e04 <bigdir+0x5c>
    printf(1, "bigdir create failed\n");
    1deb:	c7 44 24 04 db 4e 00 	movl   $0x4edb,0x4(%esp)
    1df2:	00 
    1df3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1dfa:	e8 76 23 00 00       	call   4175 <printf>
    exit();
    1dff:	e8 c4 21 00 00       	call   3fc8 <exit>
  }
  close(fd);
    1e04:	8b 45 f0             	mov    -0x10(%ebp),%eax
    1e07:	89 04 24             	mov    %eax,(%esp)
    1e0a:	e8 e1 21 00 00       	call   3ff0 <close>

  for(i = 0; i < 500; i++){
    1e0f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1e16:	eb 65                	jmp    1e7d <bigdir+0xd5>
    name[0] = 'x';
    1e18:	c6 45 e6 78          	movb   $0x78,-0x1a(%ebp)
    name[1] = '0' + (i / 64);
    1e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1e1f:	85 c0                	test   %eax,%eax
    1e21:	79 03                	jns    1e26 <bigdir+0x7e>
    1e23:	83 c0 3f             	add    $0x3f,%eax
    1e26:	c1 f8 06             	sar    $0x6,%eax
    1e29:	83 c0 30             	add    $0x30,%eax
    1e2c:	88 45 e7             	mov    %al,-0x19(%ebp)
    name[2] = '0' + (i % 64);
    1e2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1e32:	25 3f 00 00 80       	and    $0x8000003f,%eax
    1e37:	85 c0                	test   %eax,%eax
    1e39:	79 05                	jns    1e40 <bigdir+0x98>
    1e3b:	48                   	dec    %eax
    1e3c:	83 c8 c0             	or     $0xffffffc0,%eax
    1e3f:	40                   	inc    %eax
    1e40:	83 c0 30             	add    $0x30,%eax
    1e43:	88 45 e8             	mov    %al,-0x18(%ebp)
    name[3] = '\0';
    1e46:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
    if(link("bd", name) != 0){
    1e4a:	8d 45 e6             	lea    -0x1a(%ebp),%eax
    1e4d:	89 44 24 04          	mov    %eax,0x4(%esp)
    1e51:	c7 04 24 d8 4e 00 00 	movl   $0x4ed8,(%esp)
    1e58:	e8 cb 21 00 00       	call   4028 <link>
    1e5d:	85 c0                	test   %eax,%eax
    1e5f:	74 19                	je     1e7a <bigdir+0xd2>
      printf(1, "bigdir link failed\n");
    1e61:	c7 44 24 04 f1 4e 00 	movl   $0x4ef1,0x4(%esp)
    1e68:	00 
    1e69:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1e70:	e8 00 23 00 00       	call   4175 <printf>
      exit();
    1e75:	e8 4e 21 00 00       	call   3fc8 <exit>
    printf(1, "bigdir create failed\n");
    exit();
  }
  close(fd);

  for(i = 0; i < 500; i++){
    1e7a:	ff 45 f4             	incl   -0xc(%ebp)
    1e7d:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
    1e84:	7e 92                	jle    1e18 <bigdir+0x70>
      printf(1, "bigdir link failed\n");
      exit();
    }
  }

  unlink("bd");
    1e86:	c7 04 24 d8 4e 00 00 	movl   $0x4ed8,(%esp)
    1e8d:	e8 86 21 00 00       	call   4018 <unlink>
  for(i = 0; i < 500; i++){
    1e92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    1e99:	eb 5d                	jmp    1ef8 <bigdir+0x150>
    name[0] = 'x';
    1e9b:	c6 45 e6 78          	movb   $0x78,-0x1a(%ebp)
    name[1] = '0' + (i / 64);
    1e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1ea2:	85 c0                	test   %eax,%eax
    1ea4:	79 03                	jns    1ea9 <bigdir+0x101>
    1ea6:	83 c0 3f             	add    $0x3f,%eax
    1ea9:	c1 f8 06             	sar    $0x6,%eax
    1eac:	83 c0 30             	add    $0x30,%eax
    1eaf:	88 45 e7             	mov    %al,-0x19(%ebp)
    name[2] = '0' + (i % 64);
    1eb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1eb5:	25 3f 00 00 80       	and    $0x8000003f,%eax
    1eba:	85 c0                	test   %eax,%eax
    1ebc:	79 05                	jns    1ec3 <bigdir+0x11b>
    1ebe:	48                   	dec    %eax
    1ebf:	83 c8 c0             	or     $0xffffffc0,%eax
    1ec2:	40                   	inc    %eax
    1ec3:	83 c0 30             	add    $0x30,%eax
    1ec6:	88 45 e8             	mov    %al,-0x18(%ebp)
    name[3] = '\0';
    1ec9:	c6 45 e9 00          	movb   $0x0,-0x17(%ebp)
    if(unlink(name) != 0){
    1ecd:	8d 45 e6             	lea    -0x1a(%ebp),%eax
    1ed0:	89 04 24             	mov    %eax,(%esp)
    1ed3:	e8 40 21 00 00       	call   4018 <unlink>
    1ed8:	85 c0                	test   %eax,%eax
    1eda:	74 19                	je     1ef5 <bigdir+0x14d>
      printf(1, "bigdir unlink failed");
    1edc:	c7 44 24 04 05 4f 00 	movl   $0x4f05,0x4(%esp)
    1ee3:	00 
    1ee4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1eeb:	e8 85 22 00 00       	call   4175 <printf>
      exit();
    1ef0:	e8 d3 20 00 00       	call   3fc8 <exit>
      exit();
    }
  }

  unlink("bd");
  for(i = 0; i < 500; i++){
    1ef5:	ff 45 f4             	incl   -0xc(%ebp)
    1ef8:	81 7d f4 f3 01 00 00 	cmpl   $0x1f3,-0xc(%ebp)
    1eff:	7e 9a                	jle    1e9b <bigdir+0xf3>
      printf(1, "bigdir unlink failed");
      exit();
    }
  }

  printf(1, "bigdir ok\n");
    1f01:	c7 44 24 04 1a 4f 00 	movl   $0x4f1a,0x4(%esp)
    1f08:	00 
    1f09:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f10:	e8 60 22 00 00       	call   4175 <printf>
}
    1f15:	c9                   	leave  
    1f16:	c3                   	ret    

00001f17 <subdir>:

void
subdir(void)
{
    1f17:	55                   	push   %ebp
    1f18:	89 e5                	mov    %esp,%ebp
    1f1a:	83 ec 28             	sub    $0x28,%esp
  int fd, cc;

  printf(1, "subdir test\n");
    1f1d:	c7 44 24 04 25 4f 00 	movl   $0x4f25,0x4(%esp)
    1f24:	00 
    1f25:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f2c:	e8 44 22 00 00       	call   4175 <printf>

  unlink("ff");
    1f31:	c7 04 24 32 4f 00 00 	movl   $0x4f32,(%esp)
    1f38:	e8 db 20 00 00       	call   4018 <unlink>
  if(mkdir("dd") != 0){
    1f3d:	c7 04 24 35 4f 00 00 	movl   $0x4f35,(%esp)
    1f44:	e8 e7 20 00 00       	call   4030 <mkdir>
    1f49:	85 c0                	test   %eax,%eax
    1f4b:	74 19                	je     1f66 <subdir+0x4f>
    printf(1, "subdir mkdir dd failed\n");
    1f4d:	c7 44 24 04 38 4f 00 	movl   $0x4f38,0x4(%esp)
    1f54:	00 
    1f55:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f5c:	e8 14 22 00 00       	call   4175 <printf>
    exit();
    1f61:	e8 62 20 00 00       	call   3fc8 <exit>
  }

  fd = open("dd/ff", O_CREATE | O_RDWR);
    1f66:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    1f6d:	00 
    1f6e:	c7 04 24 50 4f 00 00 	movl   $0x4f50,(%esp)
    1f75:	e8 8e 20 00 00       	call   4008 <open>
    1f7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    1f7d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    1f81:	79 19                	jns    1f9c <subdir+0x85>
    printf(1, "create dd/ff failed\n");
    1f83:	c7 44 24 04 56 4f 00 	movl   $0x4f56,0x4(%esp)
    1f8a:	00 
    1f8b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1f92:	e8 de 21 00 00       	call   4175 <printf>
    exit();
    1f97:	e8 2c 20 00 00       	call   3fc8 <exit>
  }
  write(fd, "ff", 2);
    1f9c:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    1fa3:	00 
    1fa4:	c7 44 24 04 32 4f 00 	movl   $0x4f32,0x4(%esp)
    1fab:	00 
    1fac:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1faf:	89 04 24             	mov    %eax,(%esp)
    1fb2:	e8 31 20 00 00       	call   3fe8 <write>
  close(fd);
    1fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
    1fba:	89 04 24             	mov    %eax,(%esp)
    1fbd:	e8 2e 20 00 00       	call   3ff0 <close>

  if(unlink("dd") >= 0){
    1fc2:	c7 04 24 35 4f 00 00 	movl   $0x4f35,(%esp)
    1fc9:	e8 4a 20 00 00       	call   4018 <unlink>
    1fce:	85 c0                	test   %eax,%eax
    1fd0:	78 19                	js     1feb <subdir+0xd4>
    printf(1, "unlink dd (non-empty dir) succeeded!\n");
    1fd2:	c7 44 24 04 6c 4f 00 	movl   $0x4f6c,0x4(%esp)
    1fd9:	00 
    1fda:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    1fe1:	e8 8f 21 00 00       	call   4175 <printf>
    exit();
    1fe6:	e8 dd 1f 00 00       	call   3fc8 <exit>
  }

  if(mkdir("/dd/dd") != 0){
    1feb:	c7 04 24 92 4f 00 00 	movl   $0x4f92,(%esp)
    1ff2:	e8 39 20 00 00       	call   4030 <mkdir>
    1ff7:	85 c0                	test   %eax,%eax
    1ff9:	74 19                	je     2014 <subdir+0xfd>
    printf(1, "subdir mkdir dd/dd failed\n");
    1ffb:	c7 44 24 04 99 4f 00 	movl   $0x4f99,0x4(%esp)
    2002:	00 
    2003:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    200a:	e8 66 21 00 00       	call   4175 <printf>
    exit();
    200f:	e8 b4 1f 00 00       	call   3fc8 <exit>
  }

  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2014:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    201b:	00 
    201c:	c7 04 24 b4 4f 00 00 	movl   $0x4fb4,(%esp)
    2023:	e8 e0 1f 00 00       	call   4008 <open>
    2028:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    202b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    202f:	79 19                	jns    204a <subdir+0x133>
    printf(1, "create dd/dd/ff failed\n");
    2031:	c7 44 24 04 bd 4f 00 	movl   $0x4fbd,0x4(%esp)
    2038:	00 
    2039:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2040:	e8 30 21 00 00       	call   4175 <printf>
    exit();
    2045:	e8 7e 1f 00 00       	call   3fc8 <exit>
  }
  write(fd, "FF", 2);
    204a:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
    2051:	00 
    2052:	c7 44 24 04 d5 4f 00 	movl   $0x4fd5,0x4(%esp)
    2059:	00 
    205a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    205d:	89 04 24             	mov    %eax,(%esp)
    2060:	e8 83 1f 00 00       	call   3fe8 <write>
  close(fd);
    2065:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2068:	89 04 24             	mov    %eax,(%esp)
    206b:	e8 80 1f 00 00       	call   3ff0 <close>

  fd = open("dd/dd/../ff", 0);
    2070:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2077:	00 
    2078:	c7 04 24 d8 4f 00 00 	movl   $0x4fd8,(%esp)
    207f:	e8 84 1f 00 00       	call   4008 <open>
    2084:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2087:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    208b:	79 19                	jns    20a6 <subdir+0x18f>
    printf(1, "open dd/dd/../ff failed\n");
    208d:	c7 44 24 04 e4 4f 00 	movl   $0x4fe4,0x4(%esp)
    2094:	00 
    2095:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    209c:	e8 d4 20 00 00       	call   4175 <printf>
    exit();
    20a1:	e8 22 1f 00 00       	call   3fc8 <exit>
  }
  cc = read(fd, buf, sizeof(buf));
    20a6:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    20ad:	00 
    20ae:	c7 44 24 04 a0 8c 00 	movl   $0x8ca0,0x4(%esp)
    20b5:	00 
    20b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    20b9:	89 04 24             	mov    %eax,(%esp)
    20bc:	e8 1f 1f 00 00       	call   3fe0 <read>
    20c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(cc != 2 || buf[0] != 'f'){
    20c4:	83 7d f0 02          	cmpl   $0x2,-0x10(%ebp)
    20c8:	75 09                	jne    20d3 <subdir+0x1bc>
    20ca:	a0 a0 8c 00 00       	mov    0x8ca0,%al
    20cf:	3c 66                	cmp    $0x66,%al
    20d1:	74 19                	je     20ec <subdir+0x1d5>
    printf(1, "dd/dd/../ff wrong content\n");
    20d3:	c7 44 24 04 fd 4f 00 	movl   $0x4ffd,0x4(%esp)
    20da:	00 
    20db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    20e2:	e8 8e 20 00 00       	call   4175 <printf>
    exit();
    20e7:	e8 dc 1e 00 00       	call   3fc8 <exit>
  }
  close(fd);
    20ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
    20ef:	89 04 24             	mov    %eax,(%esp)
    20f2:	e8 f9 1e 00 00       	call   3ff0 <close>

  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    20f7:	c7 44 24 04 18 50 00 	movl   $0x5018,0x4(%esp)
    20fe:	00 
    20ff:	c7 04 24 b4 4f 00 00 	movl   $0x4fb4,(%esp)
    2106:	e8 1d 1f 00 00       	call   4028 <link>
    210b:	85 c0                	test   %eax,%eax
    210d:	74 19                	je     2128 <subdir+0x211>
    printf(1, "link dd/dd/ff dd/dd/ffff failed\n");
    210f:	c7 44 24 04 24 50 00 	movl   $0x5024,0x4(%esp)
    2116:	00 
    2117:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    211e:	e8 52 20 00 00       	call   4175 <printf>
    exit();
    2123:	e8 a0 1e 00 00       	call   3fc8 <exit>
  }

  if(unlink("dd/dd/ff") != 0){
    2128:	c7 04 24 b4 4f 00 00 	movl   $0x4fb4,(%esp)
    212f:	e8 e4 1e 00 00       	call   4018 <unlink>
    2134:	85 c0                	test   %eax,%eax
    2136:	74 19                	je     2151 <subdir+0x23a>
    printf(1, "unlink dd/dd/ff failed\n");
    2138:	c7 44 24 04 45 50 00 	movl   $0x5045,0x4(%esp)
    213f:	00 
    2140:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2147:	e8 29 20 00 00       	call   4175 <printf>
    exit();
    214c:	e8 77 1e 00 00       	call   3fc8 <exit>
  }
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2151:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2158:	00 
    2159:	c7 04 24 b4 4f 00 00 	movl   $0x4fb4,(%esp)
    2160:	e8 a3 1e 00 00       	call   4008 <open>
    2165:	85 c0                	test   %eax,%eax
    2167:	78 19                	js     2182 <subdir+0x26b>
    printf(1, "open (unlinked) dd/dd/ff succeeded\n");
    2169:	c7 44 24 04 60 50 00 	movl   $0x5060,0x4(%esp)
    2170:	00 
    2171:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2178:	e8 f8 1f 00 00       	call   4175 <printf>
    exit();
    217d:	e8 46 1e 00 00       	call   3fc8 <exit>
  }

  if(chdir("dd") != 0){
    2182:	c7 04 24 35 4f 00 00 	movl   $0x4f35,(%esp)
    2189:	e8 aa 1e 00 00       	call   4038 <chdir>
    218e:	85 c0                	test   %eax,%eax
    2190:	74 19                	je     21ab <subdir+0x294>
    printf(1, "chdir dd failed\n");
    2192:	c7 44 24 04 84 50 00 	movl   $0x5084,0x4(%esp)
    2199:	00 
    219a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21a1:	e8 cf 1f 00 00       	call   4175 <printf>
    exit();
    21a6:	e8 1d 1e 00 00       	call   3fc8 <exit>
  }
  if(chdir("dd/../../dd") != 0){
    21ab:	c7 04 24 95 50 00 00 	movl   $0x5095,(%esp)
    21b2:	e8 81 1e 00 00       	call   4038 <chdir>
    21b7:	85 c0                	test   %eax,%eax
    21b9:	74 19                	je     21d4 <subdir+0x2bd>
    printf(1, "chdir dd/../../dd failed\n");
    21bb:	c7 44 24 04 a1 50 00 	movl   $0x50a1,0x4(%esp)
    21c2:	00 
    21c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21ca:	e8 a6 1f 00 00       	call   4175 <printf>
    exit();
    21cf:	e8 f4 1d 00 00       	call   3fc8 <exit>
  }
  if(chdir("dd/../../../dd") != 0){
    21d4:	c7 04 24 bb 50 00 00 	movl   $0x50bb,(%esp)
    21db:	e8 58 1e 00 00       	call   4038 <chdir>
    21e0:	85 c0                	test   %eax,%eax
    21e2:	74 19                	je     21fd <subdir+0x2e6>
    printf(1, "chdir dd/../../dd failed\n");
    21e4:	c7 44 24 04 a1 50 00 	movl   $0x50a1,0x4(%esp)
    21eb:	00 
    21ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    21f3:	e8 7d 1f 00 00       	call   4175 <printf>
    exit();
    21f8:	e8 cb 1d 00 00       	call   3fc8 <exit>
  }
  if(chdir("./..") != 0){
    21fd:	c7 04 24 ca 50 00 00 	movl   $0x50ca,(%esp)
    2204:	e8 2f 1e 00 00       	call   4038 <chdir>
    2209:	85 c0                	test   %eax,%eax
    220b:	74 19                	je     2226 <subdir+0x30f>
    printf(1, "chdir ./.. failed\n");
    220d:	c7 44 24 04 cf 50 00 	movl   $0x50cf,0x4(%esp)
    2214:	00 
    2215:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    221c:	e8 54 1f 00 00       	call   4175 <printf>
    exit();
    2221:	e8 a2 1d 00 00       	call   3fc8 <exit>
  }

  fd = open("dd/dd/ffff", 0);
    2226:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    222d:	00 
    222e:	c7 04 24 18 50 00 00 	movl   $0x5018,(%esp)
    2235:	e8 ce 1d 00 00       	call   4008 <open>
    223a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    223d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2241:	79 19                	jns    225c <subdir+0x345>
    printf(1, "open dd/dd/ffff failed\n");
    2243:	c7 44 24 04 e2 50 00 	movl   $0x50e2,0x4(%esp)
    224a:	00 
    224b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2252:	e8 1e 1f 00 00       	call   4175 <printf>
    exit();
    2257:	e8 6c 1d 00 00       	call   3fc8 <exit>
  }
  if(read(fd, buf, sizeof(buf)) != 2){
    225c:	c7 44 24 08 00 20 00 	movl   $0x2000,0x8(%esp)
    2263:	00 
    2264:	c7 44 24 04 a0 8c 00 	movl   $0x8ca0,0x4(%esp)
    226b:	00 
    226c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    226f:	89 04 24             	mov    %eax,(%esp)
    2272:	e8 69 1d 00 00       	call   3fe0 <read>
    2277:	83 f8 02             	cmp    $0x2,%eax
    227a:	74 19                	je     2295 <subdir+0x37e>
    printf(1, "read dd/dd/ffff wrong len\n");
    227c:	c7 44 24 04 fa 50 00 	movl   $0x50fa,0x4(%esp)
    2283:	00 
    2284:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    228b:	e8 e5 1e 00 00       	call   4175 <printf>
    exit();
    2290:	e8 33 1d 00 00       	call   3fc8 <exit>
  }
  close(fd);
    2295:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2298:	89 04 24             	mov    %eax,(%esp)
    229b:	e8 50 1d 00 00       	call   3ff0 <close>

  if(open("dd/dd/ff", O_RDONLY) >= 0){
    22a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    22a7:	00 
    22a8:	c7 04 24 b4 4f 00 00 	movl   $0x4fb4,(%esp)
    22af:	e8 54 1d 00 00       	call   4008 <open>
    22b4:	85 c0                	test   %eax,%eax
    22b6:	78 19                	js     22d1 <subdir+0x3ba>
    printf(1, "open (unlinked) dd/dd/ff succeeded!\n");
    22b8:	c7 44 24 04 18 51 00 	movl   $0x5118,0x4(%esp)
    22bf:	00 
    22c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22c7:	e8 a9 1e 00 00       	call   4175 <printf>
    exit();
    22cc:	e8 f7 1c 00 00       	call   3fc8 <exit>
  }

  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    22d1:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    22d8:	00 
    22d9:	c7 04 24 3d 51 00 00 	movl   $0x513d,(%esp)
    22e0:	e8 23 1d 00 00       	call   4008 <open>
    22e5:	85 c0                	test   %eax,%eax
    22e7:	78 19                	js     2302 <subdir+0x3eb>
    printf(1, "create dd/ff/ff succeeded!\n");
    22e9:	c7 44 24 04 46 51 00 	movl   $0x5146,0x4(%esp)
    22f0:	00 
    22f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    22f8:	e8 78 1e 00 00       	call   4175 <printf>
    exit();
    22fd:	e8 c6 1c 00 00       	call   3fc8 <exit>
  }
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    2302:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2309:	00 
    230a:	c7 04 24 62 51 00 00 	movl   $0x5162,(%esp)
    2311:	e8 f2 1c 00 00       	call   4008 <open>
    2316:	85 c0                	test   %eax,%eax
    2318:	78 19                	js     2333 <subdir+0x41c>
    printf(1, "create dd/xx/ff succeeded!\n");
    231a:	c7 44 24 04 6b 51 00 	movl   $0x516b,0x4(%esp)
    2321:	00 
    2322:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2329:	e8 47 1e 00 00       	call   4175 <printf>
    exit();
    232e:	e8 95 1c 00 00       	call   3fc8 <exit>
  }
  if(open("dd", O_CREATE) >= 0){
    2333:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    233a:	00 
    233b:	c7 04 24 35 4f 00 00 	movl   $0x4f35,(%esp)
    2342:	e8 c1 1c 00 00       	call   4008 <open>
    2347:	85 c0                	test   %eax,%eax
    2349:	78 19                	js     2364 <subdir+0x44d>
    printf(1, "create dd succeeded!\n");
    234b:	c7 44 24 04 87 51 00 	movl   $0x5187,0x4(%esp)
    2352:	00 
    2353:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    235a:	e8 16 1e 00 00       	call   4175 <printf>
    exit();
    235f:	e8 64 1c 00 00       	call   3fc8 <exit>
  }
  if(open("dd", O_RDWR) >= 0){
    2364:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    236b:	00 
    236c:	c7 04 24 35 4f 00 00 	movl   $0x4f35,(%esp)
    2373:	e8 90 1c 00 00       	call   4008 <open>
    2378:	85 c0                	test   %eax,%eax
    237a:	78 19                	js     2395 <subdir+0x47e>
    printf(1, "open dd rdwr succeeded!\n");
    237c:	c7 44 24 04 9d 51 00 	movl   $0x519d,0x4(%esp)
    2383:	00 
    2384:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    238b:	e8 e5 1d 00 00       	call   4175 <printf>
    exit();
    2390:	e8 33 1c 00 00       	call   3fc8 <exit>
  }
  if(open("dd", O_WRONLY) >= 0){
    2395:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
    239c:	00 
    239d:	c7 04 24 35 4f 00 00 	movl   $0x4f35,(%esp)
    23a4:	e8 5f 1c 00 00       	call   4008 <open>
    23a9:	85 c0                	test   %eax,%eax
    23ab:	78 19                	js     23c6 <subdir+0x4af>
    printf(1, "open dd wronly succeeded!\n");
    23ad:	c7 44 24 04 b6 51 00 	movl   $0x51b6,0x4(%esp)
    23b4:	00 
    23b5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23bc:	e8 b4 1d 00 00       	call   4175 <printf>
    exit();
    23c1:	e8 02 1c 00 00       	call   3fc8 <exit>
  }
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    23c6:	c7 44 24 04 d1 51 00 	movl   $0x51d1,0x4(%esp)
    23cd:	00 
    23ce:	c7 04 24 3d 51 00 00 	movl   $0x513d,(%esp)
    23d5:	e8 4e 1c 00 00       	call   4028 <link>
    23da:	85 c0                	test   %eax,%eax
    23dc:	75 19                	jne    23f7 <subdir+0x4e0>
    printf(1, "link dd/ff/ff dd/dd/xx succeeded!\n");
    23de:	c7 44 24 04 dc 51 00 	movl   $0x51dc,0x4(%esp)
    23e5:	00 
    23e6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    23ed:	e8 83 1d 00 00       	call   4175 <printf>
    exit();
    23f2:	e8 d1 1b 00 00       	call   3fc8 <exit>
  }
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    23f7:	c7 44 24 04 d1 51 00 	movl   $0x51d1,0x4(%esp)
    23fe:	00 
    23ff:	c7 04 24 62 51 00 00 	movl   $0x5162,(%esp)
    2406:	e8 1d 1c 00 00       	call   4028 <link>
    240b:	85 c0                	test   %eax,%eax
    240d:	75 19                	jne    2428 <subdir+0x511>
    printf(1, "link dd/xx/ff dd/dd/xx succeeded!\n");
    240f:	c7 44 24 04 00 52 00 	movl   $0x5200,0x4(%esp)
    2416:	00 
    2417:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    241e:	e8 52 1d 00 00       	call   4175 <printf>
    exit();
    2423:	e8 a0 1b 00 00       	call   3fc8 <exit>
  }
  if(link("dd/ff", "dd/dd/ffff") == 0){
    2428:	c7 44 24 04 18 50 00 	movl   $0x5018,0x4(%esp)
    242f:	00 
    2430:	c7 04 24 50 4f 00 00 	movl   $0x4f50,(%esp)
    2437:	e8 ec 1b 00 00       	call   4028 <link>
    243c:	85 c0                	test   %eax,%eax
    243e:	75 19                	jne    2459 <subdir+0x542>
    printf(1, "link dd/ff dd/dd/ffff succeeded!\n");
    2440:	c7 44 24 04 24 52 00 	movl   $0x5224,0x4(%esp)
    2447:	00 
    2448:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    244f:	e8 21 1d 00 00       	call   4175 <printf>
    exit();
    2454:	e8 6f 1b 00 00       	call   3fc8 <exit>
  }
  if(mkdir("dd/ff/ff") == 0){
    2459:	c7 04 24 3d 51 00 00 	movl   $0x513d,(%esp)
    2460:	e8 cb 1b 00 00       	call   4030 <mkdir>
    2465:	85 c0                	test   %eax,%eax
    2467:	75 19                	jne    2482 <subdir+0x56b>
    printf(1, "mkdir dd/ff/ff succeeded!\n");
    2469:	c7 44 24 04 46 52 00 	movl   $0x5246,0x4(%esp)
    2470:	00 
    2471:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2478:	e8 f8 1c 00 00       	call   4175 <printf>
    exit();
    247d:	e8 46 1b 00 00       	call   3fc8 <exit>
  }
  if(mkdir("dd/xx/ff") == 0){
    2482:	c7 04 24 62 51 00 00 	movl   $0x5162,(%esp)
    2489:	e8 a2 1b 00 00       	call   4030 <mkdir>
    248e:	85 c0                	test   %eax,%eax
    2490:	75 19                	jne    24ab <subdir+0x594>
    printf(1, "mkdir dd/xx/ff succeeded!\n");
    2492:	c7 44 24 04 61 52 00 	movl   $0x5261,0x4(%esp)
    2499:	00 
    249a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24a1:	e8 cf 1c 00 00       	call   4175 <printf>
    exit();
    24a6:	e8 1d 1b 00 00       	call   3fc8 <exit>
  }
  if(mkdir("dd/dd/ffff") == 0){
    24ab:	c7 04 24 18 50 00 00 	movl   $0x5018,(%esp)
    24b2:	e8 79 1b 00 00       	call   4030 <mkdir>
    24b7:	85 c0                	test   %eax,%eax
    24b9:	75 19                	jne    24d4 <subdir+0x5bd>
    printf(1, "mkdir dd/dd/ffff succeeded!\n");
    24bb:	c7 44 24 04 7c 52 00 	movl   $0x527c,0x4(%esp)
    24c2:	00 
    24c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24ca:	e8 a6 1c 00 00       	call   4175 <printf>
    exit();
    24cf:	e8 f4 1a 00 00       	call   3fc8 <exit>
  }
  if(unlink("dd/xx/ff") == 0){
    24d4:	c7 04 24 62 51 00 00 	movl   $0x5162,(%esp)
    24db:	e8 38 1b 00 00       	call   4018 <unlink>
    24e0:	85 c0                	test   %eax,%eax
    24e2:	75 19                	jne    24fd <subdir+0x5e6>
    printf(1, "unlink dd/xx/ff succeeded!\n");
    24e4:	c7 44 24 04 99 52 00 	movl   $0x5299,0x4(%esp)
    24eb:	00 
    24ec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    24f3:	e8 7d 1c 00 00       	call   4175 <printf>
    exit();
    24f8:	e8 cb 1a 00 00       	call   3fc8 <exit>
  }
  if(unlink("dd/ff/ff") == 0){
    24fd:	c7 04 24 3d 51 00 00 	movl   $0x513d,(%esp)
    2504:	e8 0f 1b 00 00       	call   4018 <unlink>
    2509:	85 c0                	test   %eax,%eax
    250b:	75 19                	jne    2526 <subdir+0x60f>
    printf(1, "unlink dd/ff/ff succeeded!\n");
    250d:	c7 44 24 04 b5 52 00 	movl   $0x52b5,0x4(%esp)
    2514:	00 
    2515:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    251c:	e8 54 1c 00 00       	call   4175 <printf>
    exit();
    2521:	e8 a2 1a 00 00       	call   3fc8 <exit>
  }
  if(chdir("dd/ff") == 0){
    2526:	c7 04 24 50 4f 00 00 	movl   $0x4f50,(%esp)
    252d:	e8 06 1b 00 00       	call   4038 <chdir>
    2532:	85 c0                	test   %eax,%eax
    2534:	75 19                	jne    254f <subdir+0x638>
    printf(1, "chdir dd/ff succeeded!\n");
    2536:	c7 44 24 04 d1 52 00 	movl   $0x52d1,0x4(%esp)
    253d:	00 
    253e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2545:	e8 2b 1c 00 00       	call   4175 <printf>
    exit();
    254a:	e8 79 1a 00 00       	call   3fc8 <exit>
  }
  if(chdir("dd/xx") == 0){
    254f:	c7 04 24 e9 52 00 00 	movl   $0x52e9,(%esp)
    2556:	e8 dd 1a 00 00       	call   4038 <chdir>
    255b:	85 c0                	test   %eax,%eax
    255d:	75 19                	jne    2578 <subdir+0x661>
    printf(1, "chdir dd/xx succeeded!\n");
    255f:	c7 44 24 04 ef 52 00 	movl   $0x52ef,0x4(%esp)
    2566:	00 
    2567:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    256e:	e8 02 1c 00 00       	call   4175 <printf>
    exit();
    2573:	e8 50 1a 00 00       	call   3fc8 <exit>
  }

  if(unlink("dd/dd/ffff") != 0){
    2578:	c7 04 24 18 50 00 00 	movl   $0x5018,(%esp)
    257f:	e8 94 1a 00 00       	call   4018 <unlink>
    2584:	85 c0                	test   %eax,%eax
    2586:	74 19                	je     25a1 <subdir+0x68a>
    printf(1, "unlink dd/dd/ff failed\n");
    2588:	c7 44 24 04 45 50 00 	movl   $0x5045,0x4(%esp)
    258f:	00 
    2590:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2597:	e8 d9 1b 00 00       	call   4175 <printf>
    exit();
    259c:	e8 27 1a 00 00       	call   3fc8 <exit>
  }
  if(unlink("dd/ff") != 0){
    25a1:	c7 04 24 50 4f 00 00 	movl   $0x4f50,(%esp)
    25a8:	e8 6b 1a 00 00       	call   4018 <unlink>
    25ad:	85 c0                	test   %eax,%eax
    25af:	74 19                	je     25ca <subdir+0x6b3>
    printf(1, "unlink dd/ff failed\n");
    25b1:	c7 44 24 04 07 53 00 	movl   $0x5307,0x4(%esp)
    25b8:	00 
    25b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    25c0:	e8 b0 1b 00 00       	call   4175 <printf>
    exit();
    25c5:	e8 fe 19 00 00       	call   3fc8 <exit>
  }
  if(unlink("dd") == 0){
    25ca:	c7 04 24 35 4f 00 00 	movl   $0x4f35,(%esp)
    25d1:	e8 42 1a 00 00       	call   4018 <unlink>
    25d6:	85 c0                	test   %eax,%eax
    25d8:	75 19                	jne    25f3 <subdir+0x6dc>
    printf(1, "unlink non-empty dd succeeded!\n");
    25da:	c7 44 24 04 1c 53 00 	movl   $0x531c,0x4(%esp)
    25e1:	00 
    25e2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    25e9:	e8 87 1b 00 00       	call   4175 <printf>
    exit();
    25ee:	e8 d5 19 00 00       	call   3fc8 <exit>
  }
  if(unlink("dd/dd") < 0){
    25f3:	c7 04 24 3c 53 00 00 	movl   $0x533c,(%esp)
    25fa:	e8 19 1a 00 00       	call   4018 <unlink>
    25ff:	85 c0                	test   %eax,%eax
    2601:	79 19                	jns    261c <subdir+0x705>
    printf(1, "unlink dd/dd failed\n");
    2603:	c7 44 24 04 42 53 00 	movl   $0x5342,0x4(%esp)
    260a:	00 
    260b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2612:	e8 5e 1b 00 00       	call   4175 <printf>
    exit();
    2617:	e8 ac 19 00 00       	call   3fc8 <exit>
  }
  if(unlink("dd") < 0){
    261c:	c7 04 24 35 4f 00 00 	movl   $0x4f35,(%esp)
    2623:	e8 f0 19 00 00       	call   4018 <unlink>
    2628:	85 c0                	test   %eax,%eax
    262a:	79 19                	jns    2645 <subdir+0x72e>
    printf(1, "unlink dd failed\n");
    262c:	c7 44 24 04 57 53 00 	movl   $0x5357,0x4(%esp)
    2633:	00 
    2634:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    263b:	e8 35 1b 00 00       	call   4175 <printf>
    exit();
    2640:	e8 83 19 00 00       	call   3fc8 <exit>
  }

  printf(1, "subdir ok\n");
    2645:	c7 44 24 04 69 53 00 	movl   $0x5369,0x4(%esp)
    264c:	00 
    264d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2654:	e8 1c 1b 00 00       	call   4175 <printf>
}
    2659:	c9                   	leave  
    265a:	c3                   	ret    

0000265b <bigwrite>:

// test writes that are larger than the log.
void
bigwrite(void)
{
    265b:	55                   	push   %ebp
    265c:	89 e5                	mov    %esp,%ebp
    265e:	83 ec 28             	sub    $0x28,%esp
  int fd, sz;

  printf(1, "bigwrite test\n");
    2661:	c7 44 24 04 74 53 00 	movl   $0x5374,0x4(%esp)
    2668:	00 
    2669:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2670:	e8 00 1b 00 00       	call   4175 <printf>

  unlink("bigwrite");
    2675:	c7 04 24 83 53 00 00 	movl   $0x5383,(%esp)
    267c:	e8 97 19 00 00       	call   4018 <unlink>
  for(sz = 499; sz < 12*512; sz += 471){
    2681:	c7 45 f4 f3 01 00 00 	movl   $0x1f3,-0xc(%ebp)
    2688:	e9 b2 00 00 00       	jmp    273f <bigwrite+0xe4>
    fd = open("bigwrite", O_CREATE | O_RDWR);
    268d:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    2694:	00 
    2695:	c7 04 24 83 53 00 00 	movl   $0x5383,(%esp)
    269c:	e8 67 19 00 00       	call   4008 <open>
    26a1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(fd < 0){
    26a4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    26a8:	79 19                	jns    26c3 <bigwrite+0x68>
      printf(1, "cannot create bigwrite\n");
    26aa:	c7 44 24 04 8c 53 00 	movl   $0x538c,0x4(%esp)
    26b1:	00 
    26b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    26b9:	e8 b7 1a 00 00       	call   4175 <printf>
      exit();
    26be:	e8 05 19 00 00       	call   3fc8 <exit>
    }
    int i;
    for(i = 0; i < 2; i++){
    26c3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    26ca:	eb 4f                	jmp    271b <bigwrite+0xc0>
      int cc = write(fd, buf, sz);
    26cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    26cf:	89 44 24 08          	mov    %eax,0x8(%esp)
    26d3:	c7 44 24 04 a0 8c 00 	movl   $0x8ca0,0x4(%esp)
    26da:	00 
    26db:	8b 45 ec             	mov    -0x14(%ebp),%eax
    26de:	89 04 24             	mov    %eax,(%esp)
    26e1:	e8 02 19 00 00       	call   3fe8 <write>
    26e6:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(cc != sz){
    26e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
    26ec:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    26ef:	74 27                	je     2718 <bigwrite+0xbd>
        printf(1, "write(%d) ret %d\n", sz, cc);
    26f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
    26f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
    26f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    26fb:	89 44 24 08          	mov    %eax,0x8(%esp)
    26ff:	c7 44 24 04 a4 53 00 	movl   $0x53a4,0x4(%esp)
    2706:	00 
    2707:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    270e:	e8 62 1a 00 00       	call   4175 <printf>
        exit();
    2713:	e8 b0 18 00 00       	call   3fc8 <exit>
    if(fd < 0){
      printf(1, "cannot create bigwrite\n");
      exit();
    }
    int i;
    for(i = 0; i < 2; i++){
    2718:	ff 45 f0             	incl   -0x10(%ebp)
    271b:	83 7d f0 01          	cmpl   $0x1,-0x10(%ebp)
    271f:	7e ab                	jle    26cc <bigwrite+0x71>
      if(cc != sz){
        printf(1, "write(%d) ret %d\n", sz, cc);
        exit();
      }
    }
    close(fd);
    2721:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2724:	89 04 24             	mov    %eax,(%esp)
    2727:	e8 c4 18 00 00       	call   3ff0 <close>
    unlink("bigwrite");
    272c:	c7 04 24 83 53 00 00 	movl   $0x5383,(%esp)
    2733:	e8 e0 18 00 00       	call   4018 <unlink>
  int fd, sz;

  printf(1, "bigwrite test\n");

  unlink("bigwrite");
  for(sz = 499; sz < 12*512; sz += 471){
    2738:	81 45 f4 d7 01 00 00 	addl   $0x1d7,-0xc(%ebp)
    273f:	81 7d f4 ff 17 00 00 	cmpl   $0x17ff,-0xc(%ebp)
    2746:	0f 8e 41 ff ff ff    	jle    268d <bigwrite+0x32>
    }
    close(fd);
    unlink("bigwrite");
  }

  printf(1, "bigwrite ok\n");
    274c:	c7 44 24 04 b6 53 00 	movl   $0x53b6,0x4(%esp)
    2753:	00 
    2754:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    275b:	e8 15 1a 00 00       	call   4175 <printf>
}
    2760:	c9                   	leave  
    2761:	c3                   	ret    

00002762 <bigfile>:

void
bigfile(void)
{
    2762:	55                   	push   %ebp
    2763:	89 e5                	mov    %esp,%ebp
    2765:	83 ec 28             	sub    $0x28,%esp
  int fd, i, total, cc;

  printf(1, "bigfile test\n");
    2768:	c7 44 24 04 c3 53 00 	movl   $0x53c3,0x4(%esp)
    276f:	00 
    2770:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2777:	e8 f9 19 00 00       	call   4175 <printf>

  unlink("bigfile");
    277c:	c7 04 24 d1 53 00 00 	movl   $0x53d1,(%esp)
    2783:	e8 90 18 00 00       	call   4018 <unlink>
  fd = open("bigfile", O_CREATE | O_RDWR);
    2788:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    278f:	00 
    2790:	c7 04 24 d1 53 00 00 	movl   $0x53d1,(%esp)
    2797:	e8 6c 18 00 00       	call   4008 <open>
    279c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    279f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    27a3:	79 19                	jns    27be <bigfile+0x5c>
    printf(1, "cannot create bigfile");
    27a5:	c7 44 24 04 d9 53 00 	movl   $0x53d9,0x4(%esp)
    27ac:	00 
    27ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    27b4:	e8 bc 19 00 00       	call   4175 <printf>
    exit();
    27b9:	e8 0a 18 00 00       	call   3fc8 <exit>
  }
  for(i = 0; i < 20; i++){
    27be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    27c5:	eb 59                	jmp    2820 <bigfile+0xbe>
    memset(buf, i, 600);
    27c7:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    27ce:	00 
    27cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
    27d2:	89 44 24 04          	mov    %eax,0x4(%esp)
    27d6:	c7 04 24 a0 8c 00 00 	movl   $0x8ca0,(%esp)
    27dd:	e8 42 16 00 00       	call   3e24 <memset>
    if(write(fd, buf, 600) != 600){
    27e2:	c7 44 24 08 58 02 00 	movl   $0x258,0x8(%esp)
    27e9:	00 
    27ea:	c7 44 24 04 a0 8c 00 	movl   $0x8ca0,0x4(%esp)
    27f1:	00 
    27f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
    27f5:	89 04 24             	mov    %eax,(%esp)
    27f8:	e8 eb 17 00 00       	call   3fe8 <write>
    27fd:	3d 58 02 00 00       	cmp    $0x258,%eax
    2802:	74 19                	je     281d <bigfile+0xbb>
      printf(1, "write bigfile failed\n");
    2804:	c7 44 24 04 ef 53 00 	movl   $0x53ef,0x4(%esp)
    280b:	00 
    280c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2813:	e8 5d 19 00 00       	call   4175 <printf>
      exit();
    2818:	e8 ab 17 00 00       	call   3fc8 <exit>
  fd = open("bigfile", O_CREATE | O_RDWR);
  if(fd < 0){
    printf(1, "cannot create bigfile");
    exit();
  }
  for(i = 0; i < 20; i++){
    281d:	ff 45 f4             	incl   -0xc(%ebp)
    2820:	83 7d f4 13          	cmpl   $0x13,-0xc(%ebp)
    2824:	7e a1                	jle    27c7 <bigfile+0x65>
    if(write(fd, buf, 600) != 600){
      printf(1, "write bigfile failed\n");
      exit();
    }
  }
  close(fd);
    2826:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2829:	89 04 24             	mov    %eax,(%esp)
    282c:	e8 bf 17 00 00       	call   3ff0 <close>

  fd = open("bigfile", 0);
    2831:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2838:	00 
    2839:	c7 04 24 d1 53 00 00 	movl   $0x53d1,(%esp)
    2840:	e8 c3 17 00 00       	call   4008 <open>
    2845:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    2848:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    284c:	79 19                	jns    2867 <bigfile+0x105>
    printf(1, "cannot open bigfile\n");
    284e:	c7 44 24 04 05 54 00 	movl   $0x5405,0x4(%esp)
    2855:	00 
    2856:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    285d:	e8 13 19 00 00       	call   4175 <printf>
    exit();
    2862:	e8 61 17 00 00       	call   3fc8 <exit>
  }
  total = 0;
    2867:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(i = 0; ; i++){
    286e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    cc = read(fd, buf, 300);
    2875:	c7 44 24 08 2c 01 00 	movl   $0x12c,0x8(%esp)
    287c:	00 
    287d:	c7 44 24 04 a0 8c 00 	movl   $0x8ca0,0x4(%esp)
    2884:	00 
    2885:	8b 45 ec             	mov    -0x14(%ebp),%eax
    2888:	89 04 24             	mov    %eax,(%esp)
    288b:	e8 50 17 00 00       	call   3fe0 <read>
    2890:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(cc < 0){
    2893:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    2897:	79 19                	jns    28b2 <bigfile+0x150>
      printf(1, "read bigfile failed\n");
    2899:	c7 44 24 04 1a 54 00 	movl   $0x541a,0x4(%esp)
    28a0:	00 
    28a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28a8:	e8 c8 18 00 00       	call   4175 <printf>
      exit();
    28ad:	e8 16 17 00 00       	call   3fc8 <exit>
    }
    if(cc == 0)
    28b2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    28b6:	75 1b                	jne    28d3 <bigfile+0x171>
      break;
    28b8:	90                   	nop
      printf(1, "read bigfile wrong data\n");
      exit();
    }
    total += cc;
  }
  close(fd);
    28b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
    28bc:	89 04 24             	mov    %eax,(%esp)
    28bf:	e8 2c 17 00 00       	call   3ff0 <close>
  if(total != 20*600){
    28c4:	81 7d f0 e0 2e 00 00 	cmpl   $0x2ee0,-0x10(%ebp)
    28cb:	0f 84 94 00 00 00    	je     2965 <bigfile+0x203>
    28d1:	eb 79                	jmp    294c <bigfile+0x1ea>
      printf(1, "read bigfile failed\n");
      exit();
    }
    if(cc == 0)
      break;
    if(cc != 300){
    28d3:	81 7d e8 2c 01 00 00 	cmpl   $0x12c,-0x18(%ebp)
    28da:	74 19                	je     28f5 <bigfile+0x193>
      printf(1, "short read bigfile\n");
    28dc:	c7 44 24 04 2f 54 00 	movl   $0x542f,0x4(%esp)
    28e3:	00 
    28e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    28eb:	e8 85 18 00 00       	call   4175 <printf>
      exit();
    28f0:	e8 d3 16 00 00       	call   3fc8 <exit>
    }
    if(buf[0] != i/2 || buf[299] != i/2){
    28f5:	a0 a0 8c 00 00       	mov    0x8ca0,%al
    28fa:	0f be d0             	movsbl %al,%edx
    28fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2900:	89 c1                	mov    %eax,%ecx
    2902:	c1 e9 1f             	shr    $0x1f,%ecx
    2905:	01 c8                	add    %ecx,%eax
    2907:	d1 f8                	sar    %eax
    2909:	39 c2                	cmp    %eax,%edx
    290b:	75 18                	jne    2925 <bigfile+0x1c3>
    290d:	a0 cb 8d 00 00       	mov    0x8dcb,%al
    2912:	0f be d0             	movsbl %al,%edx
    2915:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2918:	89 c1                	mov    %eax,%ecx
    291a:	c1 e9 1f             	shr    $0x1f,%ecx
    291d:	01 c8                	add    %ecx,%eax
    291f:	d1 f8                	sar    %eax
    2921:	39 c2                	cmp    %eax,%edx
    2923:	74 19                	je     293e <bigfile+0x1dc>
      printf(1, "read bigfile wrong data\n");
    2925:	c7 44 24 04 43 54 00 	movl   $0x5443,0x4(%esp)
    292c:	00 
    292d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2934:	e8 3c 18 00 00       	call   4175 <printf>
      exit();
    2939:	e8 8a 16 00 00       	call   3fc8 <exit>
    }
    total += cc;
    293e:	8b 45 e8             	mov    -0x18(%ebp),%eax
    2941:	01 45 f0             	add    %eax,-0x10(%ebp)
  if(fd < 0){
    printf(1, "cannot open bigfile\n");
    exit();
  }
  total = 0;
  for(i = 0; ; i++){
    2944:	ff 45 f4             	incl   -0xc(%ebp)
    if(buf[0] != i/2 || buf[299] != i/2){
      printf(1, "read bigfile wrong data\n");
      exit();
    }
    total += cc;
  }
    2947:	e9 29 ff ff ff       	jmp    2875 <bigfile+0x113>
  close(fd);
  if(total != 20*600){
    printf(1, "read bigfile wrong total\n");
    294c:	c7 44 24 04 5c 54 00 	movl   $0x545c,0x4(%esp)
    2953:	00 
    2954:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    295b:	e8 15 18 00 00       	call   4175 <printf>
    exit();
    2960:	e8 63 16 00 00       	call   3fc8 <exit>
  }
  unlink("bigfile");
    2965:	c7 04 24 d1 53 00 00 	movl   $0x53d1,(%esp)
    296c:	e8 a7 16 00 00       	call   4018 <unlink>

  printf(1, "bigfile test ok\n");
    2971:	c7 44 24 04 76 54 00 	movl   $0x5476,0x4(%esp)
    2978:	00 
    2979:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2980:	e8 f0 17 00 00       	call   4175 <printf>
}
    2985:	c9                   	leave  
    2986:	c3                   	ret    

00002987 <fourteen>:

void
fourteen(void)
{
    2987:	55                   	push   %ebp
    2988:	89 e5                	mov    %esp,%ebp
    298a:	83 ec 28             	sub    $0x28,%esp
  int fd;

  // DIRSIZ is 14.
  printf(1, "fourteen test\n");
    298d:	c7 44 24 04 87 54 00 	movl   $0x5487,0x4(%esp)
    2994:	00 
    2995:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    299c:	e8 d4 17 00 00       	call   4175 <printf>

  if(mkdir("12345678901234") != 0){
    29a1:	c7 04 24 96 54 00 00 	movl   $0x5496,(%esp)
    29a8:	e8 83 16 00 00       	call   4030 <mkdir>
    29ad:	85 c0                	test   %eax,%eax
    29af:	74 19                	je     29ca <fourteen+0x43>
    printf(1, "mkdir 12345678901234 failed\n");
    29b1:	c7 44 24 04 a5 54 00 	movl   $0x54a5,0x4(%esp)
    29b8:	00 
    29b9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29c0:	e8 b0 17 00 00       	call   4175 <printf>
    exit();
    29c5:	e8 fe 15 00 00       	call   3fc8 <exit>
  }
  if(mkdir("12345678901234/123456789012345") != 0){
    29ca:	c7 04 24 c4 54 00 00 	movl   $0x54c4,(%esp)
    29d1:	e8 5a 16 00 00       	call   4030 <mkdir>
    29d6:	85 c0                	test   %eax,%eax
    29d8:	74 19                	je     29f3 <fourteen+0x6c>
    printf(1, "mkdir 12345678901234/123456789012345 failed\n");
    29da:	c7 44 24 04 e4 54 00 	movl   $0x54e4,0x4(%esp)
    29e1:	00 
    29e2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    29e9:	e8 87 17 00 00       	call   4175 <printf>
    exit();
    29ee:	e8 d5 15 00 00       	call   3fc8 <exit>
  }
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    29f3:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    29fa:	00 
    29fb:	c7 04 24 14 55 00 00 	movl   $0x5514,(%esp)
    2a02:	e8 01 16 00 00       	call   4008 <open>
    2a07:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2a0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2a0e:	79 19                	jns    2a29 <fourteen+0xa2>
    printf(1, "create 123456789012345/123456789012345/123456789012345 failed\n");
    2a10:	c7 44 24 04 44 55 00 	movl   $0x5544,0x4(%esp)
    2a17:	00 
    2a18:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a1f:	e8 51 17 00 00       	call   4175 <printf>
    exit();
    2a24:	e8 9f 15 00 00       	call   3fc8 <exit>
  }
  close(fd);
    2a29:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2a2c:	89 04 24             	mov    %eax,(%esp)
    2a2f:	e8 bc 15 00 00       	call   3ff0 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2a34:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2a3b:	00 
    2a3c:	c7 04 24 84 55 00 00 	movl   $0x5584,(%esp)
    2a43:	e8 c0 15 00 00       	call   4008 <open>
    2a48:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2a4b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2a4f:	79 19                	jns    2a6a <fourteen+0xe3>
    printf(1, "open 12345678901234/12345678901234/12345678901234 failed\n");
    2a51:	c7 44 24 04 b4 55 00 	movl   $0x55b4,0x4(%esp)
    2a58:	00 
    2a59:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a60:	e8 10 17 00 00       	call   4175 <printf>
    exit();
    2a65:	e8 5e 15 00 00       	call   3fc8 <exit>
  }
  close(fd);
    2a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2a6d:	89 04 24             	mov    %eax,(%esp)
    2a70:	e8 7b 15 00 00       	call   3ff0 <close>

  if(mkdir("12345678901234/12345678901234") == 0){
    2a75:	c7 04 24 ee 55 00 00 	movl   $0x55ee,(%esp)
    2a7c:	e8 af 15 00 00       	call   4030 <mkdir>
    2a81:	85 c0                	test   %eax,%eax
    2a83:	75 19                	jne    2a9e <fourteen+0x117>
    printf(1, "mkdir 12345678901234/12345678901234 succeeded!\n");
    2a85:	c7 44 24 04 0c 56 00 	movl   $0x560c,0x4(%esp)
    2a8c:	00 
    2a8d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2a94:	e8 dc 16 00 00       	call   4175 <printf>
    exit();
    2a99:	e8 2a 15 00 00       	call   3fc8 <exit>
  }
  if(mkdir("123456789012345/12345678901234") == 0){
    2a9e:	c7 04 24 3c 56 00 00 	movl   $0x563c,(%esp)
    2aa5:	e8 86 15 00 00       	call   4030 <mkdir>
    2aaa:	85 c0                	test   %eax,%eax
    2aac:	75 19                	jne    2ac7 <fourteen+0x140>
    printf(1, "mkdir 12345678901234/123456789012345 succeeded!\n");
    2aae:	c7 44 24 04 5c 56 00 	movl   $0x565c,0x4(%esp)
    2ab5:	00 
    2ab6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2abd:	e8 b3 16 00 00       	call   4175 <printf>
    exit();
    2ac2:	e8 01 15 00 00       	call   3fc8 <exit>
  }

  printf(1, "fourteen ok\n");
    2ac7:	c7 44 24 04 8d 56 00 	movl   $0x568d,0x4(%esp)
    2ace:	00 
    2acf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ad6:	e8 9a 16 00 00       	call   4175 <printf>
}
    2adb:	c9                   	leave  
    2adc:	c3                   	ret    

00002add <rmdot>:

void
rmdot(void)
{
    2add:	55                   	push   %ebp
    2ade:	89 e5                	mov    %esp,%ebp
    2ae0:	83 ec 18             	sub    $0x18,%esp
  printf(1, "rmdot test\n");
    2ae3:	c7 44 24 04 9a 56 00 	movl   $0x569a,0x4(%esp)
    2aea:	00 
    2aeb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2af2:	e8 7e 16 00 00       	call   4175 <printf>
  if(mkdir("dots") != 0){
    2af7:	c7 04 24 a6 56 00 00 	movl   $0x56a6,(%esp)
    2afe:	e8 2d 15 00 00       	call   4030 <mkdir>
    2b03:	85 c0                	test   %eax,%eax
    2b05:	74 19                	je     2b20 <rmdot+0x43>
    printf(1, "mkdir dots failed\n");
    2b07:	c7 44 24 04 ab 56 00 	movl   $0x56ab,0x4(%esp)
    2b0e:	00 
    2b0f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b16:	e8 5a 16 00 00       	call   4175 <printf>
    exit();
    2b1b:	e8 a8 14 00 00       	call   3fc8 <exit>
  }
  if(chdir("dots") != 0){
    2b20:	c7 04 24 a6 56 00 00 	movl   $0x56a6,(%esp)
    2b27:	e8 0c 15 00 00       	call   4038 <chdir>
    2b2c:	85 c0                	test   %eax,%eax
    2b2e:	74 19                	je     2b49 <rmdot+0x6c>
    printf(1, "chdir dots failed\n");
    2b30:	c7 44 24 04 be 56 00 	movl   $0x56be,0x4(%esp)
    2b37:	00 
    2b38:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b3f:	e8 31 16 00 00       	call   4175 <printf>
    exit();
    2b44:	e8 7f 14 00 00       	call   3fc8 <exit>
  }
  if(unlink(".") == 0){
    2b49:	c7 04 24 d7 4d 00 00 	movl   $0x4dd7,(%esp)
    2b50:	e8 c3 14 00 00       	call   4018 <unlink>
    2b55:	85 c0                	test   %eax,%eax
    2b57:	75 19                	jne    2b72 <rmdot+0x95>
    printf(1, "rm . worked!\n");
    2b59:	c7 44 24 04 d1 56 00 	movl   $0x56d1,0x4(%esp)
    2b60:	00 
    2b61:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b68:	e8 08 16 00 00       	call   4175 <printf>
    exit();
    2b6d:	e8 56 14 00 00       	call   3fc8 <exit>
  }
  if(unlink("..") == 0){
    2b72:	c7 04 24 5a 49 00 00 	movl   $0x495a,(%esp)
    2b79:	e8 9a 14 00 00       	call   4018 <unlink>
    2b7e:	85 c0                	test   %eax,%eax
    2b80:	75 19                	jne    2b9b <rmdot+0xbe>
    printf(1, "rm .. worked!\n");
    2b82:	c7 44 24 04 df 56 00 	movl   $0x56df,0x4(%esp)
    2b89:	00 
    2b8a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2b91:	e8 df 15 00 00       	call   4175 <printf>
    exit();
    2b96:	e8 2d 14 00 00       	call   3fc8 <exit>
  }
  if(chdir("/") != 0){
    2b9b:	c7 04 24 ae 45 00 00 	movl   $0x45ae,(%esp)
    2ba2:	e8 91 14 00 00       	call   4038 <chdir>
    2ba7:	85 c0                	test   %eax,%eax
    2ba9:	74 19                	je     2bc4 <rmdot+0xe7>
    printf(1, "chdir / failed\n");
    2bab:	c7 44 24 04 b0 45 00 	movl   $0x45b0,0x4(%esp)
    2bb2:	00 
    2bb3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2bba:	e8 b6 15 00 00       	call   4175 <printf>
    exit();
    2bbf:	e8 04 14 00 00       	call   3fc8 <exit>
  }
  if(unlink("dots/.") == 0){
    2bc4:	c7 04 24 ee 56 00 00 	movl   $0x56ee,(%esp)
    2bcb:	e8 48 14 00 00       	call   4018 <unlink>
    2bd0:	85 c0                	test   %eax,%eax
    2bd2:	75 19                	jne    2bed <rmdot+0x110>
    printf(1, "unlink dots/. worked!\n");
    2bd4:	c7 44 24 04 f5 56 00 	movl   $0x56f5,0x4(%esp)
    2bdb:	00 
    2bdc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2be3:	e8 8d 15 00 00       	call   4175 <printf>
    exit();
    2be8:	e8 db 13 00 00       	call   3fc8 <exit>
  }
  if(unlink("dots/..") == 0){
    2bed:	c7 04 24 0c 57 00 00 	movl   $0x570c,(%esp)
    2bf4:	e8 1f 14 00 00       	call   4018 <unlink>
    2bf9:	85 c0                	test   %eax,%eax
    2bfb:	75 19                	jne    2c16 <rmdot+0x139>
    printf(1, "unlink dots/.. worked!\n");
    2bfd:	c7 44 24 04 14 57 00 	movl   $0x5714,0x4(%esp)
    2c04:	00 
    2c05:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c0c:	e8 64 15 00 00       	call   4175 <printf>
    exit();
    2c11:	e8 b2 13 00 00       	call   3fc8 <exit>
  }
  if(unlink("dots") != 0){
    2c16:	c7 04 24 a6 56 00 00 	movl   $0x56a6,(%esp)
    2c1d:	e8 f6 13 00 00       	call   4018 <unlink>
    2c22:	85 c0                	test   %eax,%eax
    2c24:	74 19                	je     2c3f <rmdot+0x162>
    printf(1, "unlink dots failed!\n");
    2c26:	c7 44 24 04 2c 57 00 	movl   $0x572c,0x4(%esp)
    2c2d:	00 
    2c2e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c35:	e8 3b 15 00 00       	call   4175 <printf>
    exit();
    2c3a:	e8 89 13 00 00       	call   3fc8 <exit>
  }
  printf(1, "rmdot ok\n");
    2c3f:	c7 44 24 04 41 57 00 	movl   $0x5741,0x4(%esp)
    2c46:	00 
    2c47:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c4e:	e8 22 15 00 00       	call   4175 <printf>
}
    2c53:	c9                   	leave  
    2c54:	c3                   	ret    

00002c55 <dirfile>:

void
dirfile(void)
{
    2c55:	55                   	push   %ebp
    2c56:	89 e5                	mov    %esp,%ebp
    2c58:	83 ec 28             	sub    $0x28,%esp
  int fd;

  printf(1, "dir vs file\n");
    2c5b:	c7 44 24 04 4b 57 00 	movl   $0x574b,0x4(%esp)
    2c62:	00 
    2c63:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c6a:	e8 06 15 00 00       	call   4175 <printf>

  fd = open("dirfile", O_CREATE);
    2c6f:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2c76:	00 
    2c77:	c7 04 24 58 57 00 00 	movl   $0x5758,(%esp)
    2c7e:	e8 85 13 00 00       	call   4008 <open>
    2c83:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0){
    2c86:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2c8a:	79 19                	jns    2ca5 <dirfile+0x50>
    printf(1, "create dirfile failed\n");
    2c8c:	c7 44 24 04 60 57 00 	movl   $0x5760,0x4(%esp)
    2c93:	00 
    2c94:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2c9b:	e8 d5 14 00 00       	call   4175 <printf>
    exit();
    2ca0:	e8 23 13 00 00       	call   3fc8 <exit>
  }
  close(fd);
    2ca5:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2ca8:	89 04 24             	mov    %eax,(%esp)
    2cab:	e8 40 13 00 00       	call   3ff0 <close>
  if(chdir("dirfile") == 0){
    2cb0:	c7 04 24 58 57 00 00 	movl   $0x5758,(%esp)
    2cb7:	e8 7c 13 00 00       	call   4038 <chdir>
    2cbc:	85 c0                	test   %eax,%eax
    2cbe:	75 19                	jne    2cd9 <dirfile+0x84>
    printf(1, "chdir dirfile succeeded!\n");
    2cc0:	c7 44 24 04 77 57 00 	movl   $0x5777,0x4(%esp)
    2cc7:	00 
    2cc8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2ccf:	e8 a1 14 00 00       	call   4175 <printf>
    exit();
    2cd4:	e8 ef 12 00 00       	call   3fc8 <exit>
  }
  fd = open("dirfile/xx", 0);
    2cd9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2ce0:	00 
    2ce1:	c7 04 24 91 57 00 00 	movl   $0x5791,(%esp)
    2ce8:	e8 1b 13 00 00       	call   4008 <open>
    2ced:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    2cf0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2cf4:	78 19                	js     2d0f <dirfile+0xba>
    printf(1, "create dirfile/xx succeeded!\n");
    2cf6:	c7 44 24 04 9c 57 00 	movl   $0x579c,0x4(%esp)
    2cfd:	00 
    2cfe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d05:	e8 6b 14 00 00       	call   4175 <printf>
    exit();
    2d0a:	e8 b9 12 00 00       	call   3fc8 <exit>
  }
  fd = open("dirfile/xx", O_CREATE);
    2d0f:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2d16:	00 
    2d17:	c7 04 24 91 57 00 00 	movl   $0x5791,(%esp)
    2d1e:	e8 e5 12 00 00       	call   4008 <open>
    2d23:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    2d26:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2d2a:	78 19                	js     2d45 <dirfile+0xf0>
    printf(1, "create dirfile/xx succeeded!\n");
    2d2c:	c7 44 24 04 9c 57 00 	movl   $0x579c,0x4(%esp)
    2d33:	00 
    2d34:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d3b:	e8 35 14 00 00       	call   4175 <printf>
    exit();
    2d40:	e8 83 12 00 00       	call   3fc8 <exit>
  }
  if(mkdir("dirfile/xx") == 0){
    2d45:	c7 04 24 91 57 00 00 	movl   $0x5791,(%esp)
    2d4c:	e8 df 12 00 00       	call   4030 <mkdir>
    2d51:	85 c0                	test   %eax,%eax
    2d53:	75 19                	jne    2d6e <dirfile+0x119>
    printf(1, "mkdir dirfile/xx succeeded!\n");
    2d55:	c7 44 24 04 ba 57 00 	movl   $0x57ba,0x4(%esp)
    2d5c:	00 
    2d5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d64:	e8 0c 14 00 00       	call   4175 <printf>
    exit();
    2d69:	e8 5a 12 00 00       	call   3fc8 <exit>
  }
  if(unlink("dirfile/xx") == 0){
    2d6e:	c7 04 24 91 57 00 00 	movl   $0x5791,(%esp)
    2d75:	e8 9e 12 00 00       	call   4018 <unlink>
    2d7a:	85 c0                	test   %eax,%eax
    2d7c:	75 19                	jne    2d97 <dirfile+0x142>
    printf(1, "unlink dirfile/xx succeeded!\n");
    2d7e:	c7 44 24 04 d7 57 00 	movl   $0x57d7,0x4(%esp)
    2d85:	00 
    2d86:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2d8d:	e8 e3 13 00 00       	call   4175 <printf>
    exit();
    2d92:	e8 31 12 00 00       	call   3fc8 <exit>
  }
  if(link("README", "dirfile/xx") == 0){
    2d97:	c7 44 24 04 91 57 00 	movl   $0x5791,0x4(%esp)
    2d9e:	00 
    2d9f:	c7 04 24 f5 57 00 00 	movl   $0x57f5,(%esp)
    2da6:	e8 7d 12 00 00       	call   4028 <link>
    2dab:	85 c0                	test   %eax,%eax
    2dad:	75 19                	jne    2dc8 <dirfile+0x173>
    printf(1, "link to dirfile/xx succeeded!\n");
    2daf:	c7 44 24 04 fc 57 00 	movl   $0x57fc,0x4(%esp)
    2db6:	00 
    2db7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2dbe:	e8 b2 13 00 00       	call   4175 <printf>
    exit();
    2dc3:	e8 00 12 00 00       	call   3fc8 <exit>
  }
  if(unlink("dirfile") != 0){
    2dc8:	c7 04 24 58 57 00 00 	movl   $0x5758,(%esp)
    2dcf:	e8 44 12 00 00       	call   4018 <unlink>
    2dd4:	85 c0                	test   %eax,%eax
    2dd6:	74 19                	je     2df1 <dirfile+0x19c>
    printf(1, "unlink dirfile failed!\n");
    2dd8:	c7 44 24 04 1b 58 00 	movl   $0x581b,0x4(%esp)
    2ddf:	00 
    2de0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2de7:	e8 89 13 00 00       	call   4175 <printf>
    exit();
    2dec:	e8 d7 11 00 00       	call   3fc8 <exit>
  }

  fd = open(".", O_RDWR);
    2df1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
    2df8:	00 
    2df9:	c7 04 24 d7 4d 00 00 	movl   $0x4dd7,(%esp)
    2e00:	e8 03 12 00 00       	call   4008 <open>
    2e05:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd >= 0){
    2e08:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    2e0c:	78 19                	js     2e27 <dirfile+0x1d2>
    printf(1, "open . for writing succeeded!\n");
    2e0e:	c7 44 24 04 34 58 00 	movl   $0x5834,0x4(%esp)
    2e15:	00 
    2e16:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e1d:	e8 53 13 00 00       	call   4175 <printf>
    exit();
    2e22:	e8 a1 11 00 00       	call   3fc8 <exit>
  }
  fd = open(".", 0);
    2e27:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    2e2e:	00 
    2e2f:	c7 04 24 d7 4d 00 00 	movl   $0x4dd7,(%esp)
    2e36:	e8 cd 11 00 00       	call   4008 <open>
    2e3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(write(fd, "x", 1) > 0){
    2e3e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    2e45:	00 
    2e46:	c7 44 24 04 13 4a 00 	movl   $0x4a13,0x4(%esp)
    2e4d:	00 
    2e4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2e51:	89 04 24             	mov    %eax,(%esp)
    2e54:	e8 8f 11 00 00       	call   3fe8 <write>
    2e59:	85 c0                	test   %eax,%eax
    2e5b:	7e 19                	jle    2e76 <dirfile+0x221>
    printf(1, "write . succeeded!\n");
    2e5d:	c7 44 24 04 53 58 00 	movl   $0x5853,0x4(%esp)
    2e64:	00 
    2e65:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e6c:	e8 04 13 00 00       	call   4175 <printf>
    exit();
    2e71:	e8 52 11 00 00       	call   3fc8 <exit>
  }
  close(fd);
    2e76:	8b 45 f4             	mov    -0xc(%ebp),%eax
    2e79:	89 04 24             	mov    %eax,(%esp)
    2e7c:	e8 6f 11 00 00       	call   3ff0 <close>

  printf(1, "dir vs file OK\n");
    2e81:	c7 44 24 04 67 58 00 	movl   $0x5867,0x4(%esp)
    2e88:	00 
    2e89:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2e90:	e8 e0 12 00 00       	call   4175 <printf>
}
    2e95:	c9                   	leave  
    2e96:	c3                   	ret    

00002e97 <iref>:

// test that iput() is called at the end of _namei()
void
iref(void)
{
    2e97:	55                   	push   %ebp
    2e98:	89 e5                	mov    %esp,%ebp
    2e9a:	83 ec 28             	sub    $0x28,%esp
  int i, fd;

  printf(1, "empty file name\n");
    2e9d:	c7 44 24 04 77 58 00 	movl   $0x5877,0x4(%esp)
    2ea4:	00 
    2ea5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2eac:	e8 c4 12 00 00       	call   4175 <printf>

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    2eb1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2eb8:	e9 d1 00 00 00       	jmp    2f8e <iref+0xf7>
    if(mkdir("irefd") != 0){
    2ebd:	c7 04 24 88 58 00 00 	movl   $0x5888,(%esp)
    2ec4:	e8 67 11 00 00       	call   4030 <mkdir>
    2ec9:	85 c0                	test   %eax,%eax
    2ecb:	74 19                	je     2ee6 <iref+0x4f>
      printf(1, "mkdir irefd failed\n");
    2ecd:	c7 44 24 04 8e 58 00 	movl   $0x588e,0x4(%esp)
    2ed4:	00 
    2ed5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2edc:	e8 94 12 00 00       	call   4175 <printf>
      exit();
    2ee1:	e8 e2 10 00 00       	call   3fc8 <exit>
    }
    if(chdir("irefd") != 0){
    2ee6:	c7 04 24 88 58 00 00 	movl   $0x5888,(%esp)
    2eed:	e8 46 11 00 00       	call   4038 <chdir>
    2ef2:	85 c0                	test   %eax,%eax
    2ef4:	74 19                	je     2f0f <iref+0x78>
      printf(1, "chdir irefd failed\n");
    2ef6:	c7 44 24 04 a2 58 00 	movl   $0x58a2,0x4(%esp)
    2efd:	00 
    2efe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2f05:	e8 6b 12 00 00       	call   4175 <printf>
      exit();
    2f0a:	e8 b9 10 00 00       	call   3fc8 <exit>
    }

    mkdir("");
    2f0f:	c7 04 24 b6 58 00 00 	movl   $0x58b6,(%esp)
    2f16:	e8 15 11 00 00       	call   4030 <mkdir>
    link("README", "");
    2f1b:	c7 44 24 04 b6 58 00 	movl   $0x58b6,0x4(%esp)
    2f22:	00 
    2f23:	c7 04 24 f5 57 00 00 	movl   $0x57f5,(%esp)
    2f2a:	e8 f9 10 00 00       	call   4028 <link>
    fd = open("", O_CREATE);
    2f2f:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2f36:	00 
    2f37:	c7 04 24 b6 58 00 00 	movl   $0x58b6,(%esp)
    2f3e:	e8 c5 10 00 00       	call   4008 <open>
    2f43:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0)
    2f46:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    2f4a:	78 0b                	js     2f57 <iref+0xc0>
      close(fd);
    2f4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
    2f4f:	89 04 24             	mov    %eax,(%esp)
    2f52:	e8 99 10 00 00       	call   3ff0 <close>
    fd = open("xx", O_CREATE);
    2f57:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    2f5e:	00 
    2f5f:	c7 04 24 b7 58 00 00 	movl   $0x58b7,(%esp)
    2f66:	e8 9d 10 00 00       	call   4008 <open>
    2f6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(fd >= 0)
    2f6e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    2f72:	78 0b                	js     2f7f <iref+0xe8>
      close(fd);
    2f74:	8b 45 f0             	mov    -0x10(%ebp),%eax
    2f77:	89 04 24             	mov    %eax,(%esp)
    2f7a:	e8 71 10 00 00       	call   3ff0 <close>
    unlink("xx");
    2f7f:	c7 04 24 b7 58 00 00 	movl   $0x58b7,(%esp)
    2f86:	e8 8d 10 00 00       	call   4018 <unlink>
  int i, fd;

  printf(1, "empty file name\n");

  // the 50 is NINODE
  for(i = 0; i < 50 + 1; i++){
    2f8b:	ff 45 f4             	incl   -0xc(%ebp)
    2f8e:	83 7d f4 32          	cmpl   $0x32,-0xc(%ebp)
    2f92:	0f 8e 25 ff ff ff    	jle    2ebd <iref+0x26>
    if(fd >= 0)
      close(fd);
    unlink("xx");
  }

  chdir("/");
    2f98:	c7 04 24 ae 45 00 00 	movl   $0x45ae,(%esp)
    2f9f:	e8 94 10 00 00       	call   4038 <chdir>
  printf(1, "empty file name OK\n");
    2fa4:	c7 44 24 04 ba 58 00 	movl   $0x58ba,0x4(%esp)
    2fab:	00 
    2fac:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2fb3:	e8 bd 11 00 00       	call   4175 <printf>
}
    2fb8:	c9                   	leave  
    2fb9:	c3                   	ret    

00002fba <forktest>:
// test that fork fails gracefully
// the forktest binary also does this, but it runs out of proc entries first.
// inside the bigger usertests binary, we run out of memory first.
void
forktest(void)
{
    2fba:	55                   	push   %ebp
    2fbb:	89 e5                	mov    %esp,%ebp
    2fbd:	83 ec 28             	sub    $0x28,%esp
  int n, pid;

  printf(1, "fork test\n");
    2fc0:	c7 44 24 04 ce 58 00 	movl   $0x58ce,0x4(%esp)
    2fc7:	00 
    2fc8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    2fcf:	e8 a1 11 00 00       	call   4175 <printf>

  for(n=0; n<1000; n++){
    2fd4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    2fdb:	eb 1e                	jmp    2ffb <forktest+0x41>
    pid = fork();
    2fdd:	e8 de 0f 00 00       	call   3fc0 <fork>
    2fe2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0)
    2fe5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    2fe9:	79 02                	jns    2fed <forktest+0x33>
      break;
    2feb:	eb 17                	jmp    3004 <forktest+0x4a>
    if(pid == 0)
    2fed:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    2ff1:	75 05                	jne    2ff8 <forktest+0x3e>
      exit();
    2ff3:	e8 d0 0f 00 00       	call   3fc8 <exit>
{
  int n, pid;

  printf(1, "fork test\n");

  for(n=0; n<1000; n++){
    2ff8:	ff 45 f4             	incl   -0xc(%ebp)
    2ffb:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
    3002:	7e d9                	jle    2fdd <forktest+0x23>
      break;
    if(pid == 0)
      exit();
  }

  if(n == 1000){
    3004:	81 7d f4 e8 03 00 00 	cmpl   $0x3e8,-0xc(%ebp)
    300b:	75 19                	jne    3026 <forktest+0x6c>
    printf(1, "fork claimed to work 1000 times!\n");
    300d:	c7 44 24 04 dc 58 00 	movl   $0x58dc,0x4(%esp)
    3014:	00 
    3015:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    301c:	e8 54 11 00 00       	call   4175 <printf>
    exit();
    3021:	e8 a2 0f 00 00       	call   3fc8 <exit>
  }

  for(; n > 0; n--){
    3026:	eb 25                	jmp    304d <forktest+0x93>
    if(wait() < 0){
    3028:	e8 a3 0f 00 00       	call   3fd0 <wait>
    302d:	85 c0                	test   %eax,%eax
    302f:	79 19                	jns    304a <forktest+0x90>
      printf(1, "wait stopped early\n");
    3031:	c7 44 24 04 fe 58 00 	movl   $0x58fe,0x4(%esp)
    3038:	00 
    3039:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3040:	e8 30 11 00 00       	call   4175 <printf>
      exit();
    3045:	e8 7e 0f 00 00       	call   3fc8 <exit>
  if(n == 1000){
    printf(1, "fork claimed to work 1000 times!\n");
    exit();
  }

  for(; n > 0; n--){
    304a:	ff 4d f4             	decl   -0xc(%ebp)
    304d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3051:	7f d5                	jg     3028 <forktest+0x6e>
      printf(1, "wait stopped early\n");
      exit();
    }
  }

  if(wait() != -1){
    3053:	e8 78 0f 00 00       	call   3fd0 <wait>
    3058:	83 f8 ff             	cmp    $0xffffffff,%eax
    305b:	74 19                	je     3076 <forktest+0xbc>
    printf(1, "wait got too many\n");
    305d:	c7 44 24 04 12 59 00 	movl   $0x5912,0x4(%esp)
    3064:	00 
    3065:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    306c:	e8 04 11 00 00       	call   4175 <printf>
    exit();
    3071:	e8 52 0f 00 00       	call   3fc8 <exit>
  }

  printf(1, "fork test OK\n");
    3076:	c7 44 24 04 25 59 00 	movl   $0x5925,0x4(%esp)
    307d:	00 
    307e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3085:	e8 eb 10 00 00       	call   4175 <printf>
}
    308a:	c9                   	leave  
    308b:	c3                   	ret    

0000308c <sbrktest>:

void
sbrktest(void)
{
    308c:	55                   	push   %ebp
    308d:	89 e5                	mov    %esp,%ebp
    308f:	53                   	push   %ebx
    3090:	81 ec 84 00 00 00    	sub    $0x84,%esp
  int fds[2], pid, pids[10], ppid;
  char *a, *b, *c, *lastaddr, *oldbrk, *p, scratch;
  uint amt;

  printf(stdout, "sbrk test\n");
    3096:	a1 bc 64 00 00       	mov    0x64bc,%eax
    309b:	c7 44 24 04 33 59 00 	movl   $0x5933,0x4(%esp)
    30a2:	00 
    30a3:	89 04 24             	mov    %eax,(%esp)
    30a6:	e8 ca 10 00 00       	call   4175 <printf>
  oldbrk = sbrk(0);
    30ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    30b2:	e8 99 0f 00 00       	call   4050 <sbrk>
    30b7:	89 45 ec             	mov    %eax,-0x14(%ebp)

  // can one sbrk() less than a page?
  a = sbrk(0);
    30ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    30c1:	e8 8a 0f 00 00       	call   4050 <sbrk>
    30c6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  int i;
  for(i = 0; i < 5000; i++){
    30c9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    30d0:	eb 56                	jmp    3128 <sbrktest+0x9c>
    b = sbrk(1);
    30d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    30d9:	e8 72 0f 00 00       	call   4050 <sbrk>
    30de:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(b != a){
    30e1:	8b 45 e8             	mov    -0x18(%ebp),%eax
    30e4:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    30e7:	74 2f                	je     3118 <sbrktest+0x8c>
      printf(stdout, "sbrk test failed %d %x %x\n", i, a, b);
    30e9:	a1 bc 64 00 00       	mov    0x64bc,%eax
    30ee:	8b 55 e8             	mov    -0x18(%ebp),%edx
    30f1:	89 54 24 10          	mov    %edx,0x10(%esp)
    30f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
    30f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
    30fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
    30ff:	89 54 24 08          	mov    %edx,0x8(%esp)
    3103:	c7 44 24 04 3e 59 00 	movl   $0x593e,0x4(%esp)
    310a:	00 
    310b:	89 04 24             	mov    %eax,(%esp)
    310e:	e8 62 10 00 00       	call   4175 <printf>
      exit();
    3113:	e8 b0 0e 00 00       	call   3fc8 <exit>
    }
    *b = 1;
    3118:	8b 45 e8             	mov    -0x18(%ebp),%eax
    311b:	c6 00 01             	movb   $0x1,(%eax)
    a = b + 1;
    311e:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3121:	40                   	inc    %eax
    3122:	89 45 f4             	mov    %eax,-0xc(%ebp)
  oldbrk = sbrk(0);

  // can one sbrk() less than a page?
  a = sbrk(0);
  int i;
  for(i = 0; i < 5000; i++){
    3125:	ff 45 f0             	incl   -0x10(%ebp)
    3128:	81 7d f0 87 13 00 00 	cmpl   $0x1387,-0x10(%ebp)
    312f:	7e a1                	jle    30d2 <sbrktest+0x46>
      exit();
    }
    *b = 1;
    a = b + 1;
  }
  pid = fork();
    3131:	e8 8a 0e 00 00       	call   3fc0 <fork>
    3136:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(pid < 0){
    3139:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    313d:	79 1a                	jns    3159 <sbrktest+0xcd>
    printf(stdout, "sbrk test fork failed\n");
    313f:	a1 bc 64 00 00       	mov    0x64bc,%eax
    3144:	c7 44 24 04 59 59 00 	movl   $0x5959,0x4(%esp)
    314b:	00 
    314c:	89 04 24             	mov    %eax,(%esp)
    314f:	e8 21 10 00 00       	call   4175 <printf>
    exit();
    3154:	e8 6f 0e 00 00       	call   3fc8 <exit>
  }
  c = sbrk(1);
    3159:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3160:	e8 eb 0e 00 00       	call   4050 <sbrk>
    3165:	89 45 e0             	mov    %eax,-0x20(%ebp)
  c = sbrk(1);
    3168:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    316f:	e8 dc 0e 00 00       	call   4050 <sbrk>
    3174:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a + 1){
    3177:	8b 45 f4             	mov    -0xc(%ebp),%eax
    317a:	40                   	inc    %eax
    317b:	3b 45 e0             	cmp    -0x20(%ebp),%eax
    317e:	74 1a                	je     319a <sbrktest+0x10e>
    printf(stdout, "sbrk test failed post-fork\n");
    3180:	a1 bc 64 00 00       	mov    0x64bc,%eax
    3185:	c7 44 24 04 70 59 00 	movl   $0x5970,0x4(%esp)
    318c:	00 
    318d:	89 04 24             	mov    %eax,(%esp)
    3190:	e8 e0 0f 00 00       	call   4175 <printf>
    exit();
    3195:	e8 2e 0e 00 00       	call   3fc8 <exit>
  }
  if(pid == 0)
    319a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    319e:	75 05                	jne    31a5 <sbrktest+0x119>
    exit();
    31a0:	e8 23 0e 00 00       	call   3fc8 <exit>
  wait();
    31a5:	e8 26 0e 00 00       	call   3fd0 <wait>

  // can one grow address space to something big?
#define BIG (100*1024*1024)
  a = sbrk(0);
    31aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    31b1:	e8 9a 0e 00 00       	call   4050 <sbrk>
    31b6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  amt = (BIG) - (uint)a;
    31b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    31bc:	ba 00 00 40 06       	mov    $0x6400000,%edx
    31c1:	29 c2                	sub    %eax,%edx
    31c3:	89 d0                	mov    %edx,%eax
    31c5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  p = sbrk(amt);
    31c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
    31cb:	89 04 24             	mov    %eax,(%esp)
    31ce:	e8 7d 0e 00 00       	call   4050 <sbrk>
    31d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  if (p != a) {
    31d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
    31d9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    31dc:	74 1a                	je     31f8 <sbrktest+0x16c>
    printf(stdout, "sbrk test failed to grow big address space; enough phys mem?\n");
    31de:	a1 bc 64 00 00       	mov    0x64bc,%eax
    31e3:	c7 44 24 04 8c 59 00 	movl   $0x598c,0x4(%esp)
    31ea:	00 
    31eb:	89 04 24             	mov    %eax,(%esp)
    31ee:	e8 82 0f 00 00       	call   4175 <printf>
    exit();
    31f3:	e8 d0 0d 00 00       	call   3fc8 <exit>
  }
  lastaddr = (char*) (BIG-1);
    31f8:	c7 45 d4 ff ff 3f 06 	movl   $0x63fffff,-0x2c(%ebp)
  *lastaddr = 99;
    31ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    3202:	c6 00 63             	movb   $0x63,(%eax)

  // can one de-allocate?
  a = sbrk(0);
    3205:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    320c:	e8 3f 0e 00 00       	call   4050 <sbrk>
    3211:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(-4096);
    3214:	c7 04 24 00 f0 ff ff 	movl   $0xfffff000,(%esp)
    321b:	e8 30 0e 00 00       	call   4050 <sbrk>
    3220:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c == (char*)0xffffffff){
    3223:	83 7d e0 ff          	cmpl   $0xffffffff,-0x20(%ebp)
    3227:	75 1a                	jne    3243 <sbrktest+0x1b7>
    printf(stdout, "sbrk could not deallocate\n");
    3229:	a1 bc 64 00 00       	mov    0x64bc,%eax
    322e:	c7 44 24 04 ca 59 00 	movl   $0x59ca,0x4(%esp)
    3235:	00 
    3236:	89 04 24             	mov    %eax,(%esp)
    3239:	e8 37 0f 00 00       	call   4175 <printf>
    exit();
    323e:	e8 85 0d 00 00       	call   3fc8 <exit>
  }
  c = sbrk(0);
    3243:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    324a:	e8 01 0e 00 00       	call   4050 <sbrk>
    324f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a - 4096){
    3252:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3255:	2d 00 10 00 00       	sub    $0x1000,%eax
    325a:	3b 45 e0             	cmp    -0x20(%ebp),%eax
    325d:	74 28                	je     3287 <sbrktest+0x1fb>
    printf(stdout, "sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    325f:	a1 bc 64 00 00       	mov    0x64bc,%eax
    3264:	8b 55 e0             	mov    -0x20(%ebp),%edx
    3267:	89 54 24 0c          	mov    %edx,0xc(%esp)
    326b:	8b 55 f4             	mov    -0xc(%ebp),%edx
    326e:	89 54 24 08          	mov    %edx,0x8(%esp)
    3272:	c7 44 24 04 e8 59 00 	movl   $0x59e8,0x4(%esp)
    3279:	00 
    327a:	89 04 24             	mov    %eax,(%esp)
    327d:	e8 f3 0e 00 00       	call   4175 <printf>
    exit();
    3282:	e8 41 0d 00 00       	call   3fc8 <exit>
  }

  // can one re-allocate that page?
  a = sbrk(0);
    3287:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    328e:	e8 bd 0d 00 00       	call   4050 <sbrk>
    3293:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(4096);
    3296:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    329d:	e8 ae 0d 00 00       	call   4050 <sbrk>
    32a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a || sbrk(0) != a + 4096){
    32a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
    32a8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    32ab:	75 19                	jne    32c6 <sbrktest+0x23a>
    32ad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    32b4:	e8 97 0d 00 00       	call   4050 <sbrk>
    32b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
    32bc:	81 c2 00 10 00 00    	add    $0x1000,%edx
    32c2:	39 d0                	cmp    %edx,%eax
    32c4:	74 28                	je     32ee <sbrktest+0x262>
    printf(stdout, "sbrk re-allocation failed, a %x c %x\n", a, c);
    32c6:	a1 bc 64 00 00       	mov    0x64bc,%eax
    32cb:	8b 55 e0             	mov    -0x20(%ebp),%edx
    32ce:	89 54 24 0c          	mov    %edx,0xc(%esp)
    32d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
    32d5:	89 54 24 08          	mov    %edx,0x8(%esp)
    32d9:	c7 44 24 04 20 5a 00 	movl   $0x5a20,0x4(%esp)
    32e0:	00 
    32e1:	89 04 24             	mov    %eax,(%esp)
    32e4:	e8 8c 0e 00 00       	call   4175 <printf>
    exit();
    32e9:	e8 da 0c 00 00       	call   3fc8 <exit>
  }
  if(*lastaddr == 99){
    32ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
    32f1:	8a 00                	mov    (%eax),%al
    32f3:	3c 63                	cmp    $0x63,%al
    32f5:	75 1a                	jne    3311 <sbrktest+0x285>
    // should be zero
    printf(stdout, "sbrk de-allocation didn't really deallocate\n");
    32f7:	a1 bc 64 00 00       	mov    0x64bc,%eax
    32fc:	c7 44 24 04 48 5a 00 	movl   $0x5a48,0x4(%esp)
    3303:	00 
    3304:	89 04 24             	mov    %eax,(%esp)
    3307:	e8 69 0e 00 00       	call   4175 <printf>
    exit();
    330c:	e8 b7 0c 00 00       	call   3fc8 <exit>
  }

  a = sbrk(0);
    3311:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3318:	e8 33 0d 00 00       	call   4050 <sbrk>
    331d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c = sbrk(-(sbrk(0) - oldbrk));
    3320:	8b 5d ec             	mov    -0x14(%ebp),%ebx
    3323:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    332a:	e8 21 0d 00 00       	call   4050 <sbrk>
    332f:	29 c3                	sub    %eax,%ebx
    3331:	89 d8                	mov    %ebx,%eax
    3333:	89 04 24             	mov    %eax,(%esp)
    3336:	e8 15 0d 00 00       	call   4050 <sbrk>
    333b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(c != a){
    333e:	8b 45 e0             	mov    -0x20(%ebp),%eax
    3341:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    3344:	74 28                	je     336e <sbrktest+0x2e2>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    3346:	a1 bc 64 00 00       	mov    0x64bc,%eax
    334b:	8b 55 e0             	mov    -0x20(%ebp),%edx
    334e:	89 54 24 0c          	mov    %edx,0xc(%esp)
    3352:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3355:	89 54 24 08          	mov    %edx,0x8(%esp)
    3359:	c7 44 24 04 78 5a 00 	movl   $0x5a78,0x4(%esp)
    3360:	00 
    3361:	89 04 24             	mov    %eax,(%esp)
    3364:	e8 0c 0e 00 00       	call   4175 <printf>
    exit();
    3369:	e8 5a 0c 00 00       	call   3fc8 <exit>
  }

  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    336e:	c7 45 f4 00 00 00 80 	movl   $0x80000000,-0xc(%ebp)
    3375:	eb 7a                	jmp    33f1 <sbrktest+0x365>
    ppid = getpid();
    3377:	e8 cc 0c 00 00       	call   4048 <getpid>
    337c:	89 45 d0             	mov    %eax,-0x30(%ebp)
    pid = fork();
    337f:	e8 3c 0c 00 00       	call   3fc0 <fork>
    3384:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(pid < 0){
    3387:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    338b:	79 1a                	jns    33a7 <sbrktest+0x31b>
      printf(stdout, "fork failed\n");
    338d:	a1 bc 64 00 00       	mov    0x64bc,%eax
    3392:	c7 44 24 04 dd 45 00 	movl   $0x45dd,0x4(%esp)
    3399:	00 
    339a:	89 04 24             	mov    %eax,(%esp)
    339d:	e8 d3 0d 00 00       	call   4175 <printf>
      exit();
    33a2:	e8 21 0c 00 00       	call   3fc8 <exit>
    }
    if(pid == 0){
    33a7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
    33ab:	75 38                	jne    33e5 <sbrktest+0x359>
      printf(stdout, "oops could read %x = %x\n", a, *a);
    33ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
    33b0:	8a 00                	mov    (%eax),%al
    33b2:	0f be d0             	movsbl %al,%edx
    33b5:	a1 bc 64 00 00       	mov    0x64bc,%eax
    33ba:	89 54 24 0c          	mov    %edx,0xc(%esp)
    33be:	8b 55 f4             	mov    -0xc(%ebp),%edx
    33c1:	89 54 24 08          	mov    %edx,0x8(%esp)
    33c5:	c7 44 24 04 99 5a 00 	movl   $0x5a99,0x4(%esp)
    33cc:	00 
    33cd:	89 04 24             	mov    %eax,(%esp)
    33d0:	e8 a0 0d 00 00       	call   4175 <printf>
      kill(ppid);
    33d5:	8b 45 d0             	mov    -0x30(%ebp),%eax
    33d8:	89 04 24             	mov    %eax,(%esp)
    33db:	e8 18 0c 00 00       	call   3ff8 <kill>
      exit();
    33e0:	e8 e3 0b 00 00       	call   3fc8 <exit>
    }
    wait();
    33e5:	e8 e6 0b 00 00       	call   3fd0 <wait>
    printf(stdout, "sbrk downsize failed, a %x c %x\n", a, c);
    exit();
  }

  // can we read the kernel's memory?
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    33ea:	81 45 f4 50 c3 00 00 	addl   $0xc350,-0xc(%ebp)
    33f1:	81 7d f4 7f 84 1e 80 	cmpl   $0x801e847f,-0xc(%ebp)
    33f8:	0f 86 79 ff ff ff    	jbe    3377 <sbrktest+0x2eb>
    wait();
  }

  // if we run the system out of memory, does it clean up the last
  // failed allocation?
  if(pipe(fds) != 0){
    33fe:	8d 45 c8             	lea    -0x38(%ebp),%eax
    3401:	89 04 24             	mov    %eax,(%esp)
    3404:	e8 cf 0b 00 00       	call   3fd8 <pipe>
    3409:	85 c0                	test   %eax,%eax
    340b:	74 19                	je     3426 <sbrktest+0x39a>
    printf(1, "pipe() failed\n");
    340d:	c7 44 24 04 ae 49 00 	movl   $0x49ae,0x4(%esp)
    3414:	00 
    3415:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    341c:	e8 54 0d 00 00       	call   4175 <printf>
    exit();
    3421:	e8 a2 0b 00 00       	call   3fc8 <exit>
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3426:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    342d:	e9 86 00 00 00       	jmp    34b8 <sbrktest+0x42c>
    if((pids[i] = fork()) == 0){
    3432:	e8 89 0b 00 00       	call   3fc0 <fork>
    3437:	8b 55 f0             	mov    -0x10(%ebp),%edx
    343a:	89 44 95 a0          	mov    %eax,-0x60(%ebp,%edx,4)
    343e:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3441:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    3445:	85 c0                	test   %eax,%eax
    3447:	75 46                	jne    348f <sbrktest+0x403>
      // allocate a lot of memory
      sbrk(BIG - (uint)sbrk(0));
    3449:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3450:	e8 fb 0b 00 00       	call   4050 <sbrk>
    3455:	ba 00 00 40 06       	mov    $0x6400000,%edx
    345a:	29 c2                	sub    %eax,%edx
    345c:	89 d0                	mov    %edx,%eax
    345e:	89 04 24             	mov    %eax,(%esp)
    3461:	e8 ea 0b 00 00       	call   4050 <sbrk>
      write(fds[1], "x", 1);
    3466:	8b 45 cc             	mov    -0x34(%ebp),%eax
    3469:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3470:	00 
    3471:	c7 44 24 04 13 4a 00 	movl   $0x4a13,0x4(%esp)
    3478:	00 
    3479:	89 04 24             	mov    %eax,(%esp)
    347c:	e8 67 0b 00 00       	call   3fe8 <write>
      // sit around until killed
      for(;;) sleep(1000);
    3481:	c7 04 24 e8 03 00 00 	movl   $0x3e8,(%esp)
    3488:	e8 cb 0b 00 00       	call   4058 <sleep>
    348d:	eb f2                	jmp    3481 <sbrktest+0x3f5>
    }
    if(pids[i] != -1)
    348f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3492:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    3496:	83 f8 ff             	cmp    $0xffffffff,%eax
    3499:	74 1a                	je     34b5 <sbrktest+0x429>
      read(fds[0], &scratch, 1);
    349b:	8b 45 c8             	mov    -0x38(%ebp),%eax
    349e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    34a5:	00 
    34a6:	8d 55 9f             	lea    -0x61(%ebp),%edx
    34a9:	89 54 24 04          	mov    %edx,0x4(%esp)
    34ad:	89 04 24             	mov    %eax,(%esp)
    34b0:	e8 2b 0b 00 00       	call   3fe0 <read>
  // failed allocation?
  if(pipe(fds) != 0){
    printf(1, "pipe() failed\n");
    exit();
  }
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    34b5:	ff 45 f0             	incl   -0x10(%ebp)
    34b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
    34bb:	83 f8 09             	cmp    $0x9,%eax
    34be:	0f 86 6e ff ff ff    	jbe    3432 <sbrktest+0x3a6>
    if(pids[i] != -1)
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
    34c4:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
    34cb:	e8 80 0b 00 00       	call   4050 <sbrk>
    34d0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    34d3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    34da:	eb 25                	jmp    3501 <sbrktest+0x475>
    if(pids[i] == -1)
    34dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
    34df:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    34e3:	83 f8 ff             	cmp    $0xffffffff,%eax
    34e6:	75 02                	jne    34ea <sbrktest+0x45e>
      continue;
    34e8:	eb 14                	jmp    34fe <sbrktest+0x472>
    kill(pids[i]);
    34ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
    34ed:	8b 44 85 a0          	mov    -0x60(%ebp,%eax,4),%eax
    34f1:	89 04 24             	mov    %eax,(%esp)
    34f4:	e8 ff 0a 00 00       	call   3ff8 <kill>
    wait();
    34f9:	e8 d2 0a 00 00       	call   3fd0 <wait>
      read(fds[0], &scratch, 1);
  }
  // if those failed allocations freed up the pages they did allocate,
  // we'll be able to allocate here
  c = sbrk(4096);
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    34fe:	ff 45 f0             	incl   -0x10(%ebp)
    3501:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3504:	83 f8 09             	cmp    $0x9,%eax
    3507:	76 d3                	jbe    34dc <sbrktest+0x450>
    if(pids[i] == -1)
      continue;
    kill(pids[i]);
    wait();
  }
  if(c == (char*)0xffffffff){
    3509:	83 7d e0 ff          	cmpl   $0xffffffff,-0x20(%ebp)
    350d:	75 1a                	jne    3529 <sbrktest+0x49d>
    printf(stdout, "failed sbrk leaked memory\n");
    350f:	a1 bc 64 00 00       	mov    0x64bc,%eax
    3514:	c7 44 24 04 b2 5a 00 	movl   $0x5ab2,0x4(%esp)
    351b:	00 
    351c:	89 04 24             	mov    %eax,(%esp)
    351f:	e8 51 0c 00 00       	call   4175 <printf>
    exit();
    3524:	e8 9f 0a 00 00       	call   3fc8 <exit>
  }

  if(sbrk(0) > oldbrk)
    3529:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3530:	e8 1b 0b 00 00       	call   4050 <sbrk>
    3535:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    3538:	76 1b                	jbe    3555 <sbrktest+0x4c9>
    sbrk(-(sbrk(0) - oldbrk));
    353a:	8b 5d ec             	mov    -0x14(%ebp),%ebx
    353d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3544:	e8 07 0b 00 00       	call   4050 <sbrk>
    3549:	29 c3                	sub    %eax,%ebx
    354b:	89 d8                	mov    %ebx,%eax
    354d:	89 04 24             	mov    %eax,(%esp)
    3550:	e8 fb 0a 00 00       	call   4050 <sbrk>

  printf(stdout, "sbrk test OK\n");
    3555:	a1 bc 64 00 00       	mov    0x64bc,%eax
    355a:	c7 44 24 04 cd 5a 00 	movl   $0x5acd,0x4(%esp)
    3561:	00 
    3562:	89 04 24             	mov    %eax,(%esp)
    3565:	e8 0b 0c 00 00       	call   4175 <printf>
}
    356a:	81 c4 84 00 00 00    	add    $0x84,%esp
    3570:	5b                   	pop    %ebx
    3571:	5d                   	pop    %ebp
    3572:	c3                   	ret    

00003573 <validateint>:

void
validateint(int *p)
{
    3573:	55                   	push   %ebp
    3574:	89 e5                	mov    %esp,%ebp
    3576:	53                   	push   %ebx
    3577:	83 ec 10             	sub    $0x10,%esp
  int res;
  asm("mov %%esp, %%ebx\n\t"
    357a:	b8 0d 00 00 00       	mov    $0xd,%eax
    357f:	8b 55 08             	mov    0x8(%ebp),%edx
    3582:	89 d1                	mov    %edx,%ecx
    3584:	89 e3                	mov    %esp,%ebx
    3586:	89 cc                	mov    %ecx,%esp
    3588:	cd 40                	int    $0x40
    358a:	89 dc                	mov    %ebx,%esp
    358c:	89 45 f8             	mov    %eax,-0x8(%ebp)
      "int %2\n\t"
      "mov %%ebx, %%esp" :
      "=a" (res) :
      "a" (SYS_sleep), "n" (T_SYSCALL), "c" (p) :
      "ebx");
}
    358f:	83 c4 10             	add    $0x10,%esp
    3592:	5b                   	pop    %ebx
    3593:	5d                   	pop    %ebp
    3594:	c3                   	ret    

00003595 <validatetest>:

void
validatetest(void)
{
    3595:	55                   	push   %ebp
    3596:	89 e5                	mov    %esp,%ebp
    3598:	83 ec 28             	sub    $0x28,%esp
  int hi, pid;
  uint p;

  printf(stdout, "validate test\n");
    359b:	a1 bc 64 00 00       	mov    0x64bc,%eax
    35a0:	c7 44 24 04 db 5a 00 	movl   $0x5adb,0x4(%esp)
    35a7:	00 
    35a8:	89 04 24             	mov    %eax,(%esp)
    35ab:	e8 c5 0b 00 00       	call   4175 <printf>
  hi = 1100*1024;
    35b0:	c7 45 f0 00 30 11 00 	movl   $0x113000,-0x10(%ebp)

  for(p = 0; p <= (uint)hi; p += 4096){
    35b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    35be:	eb 7f                	jmp    363f <validatetest+0xaa>
    if((pid = fork()) == 0){
    35c0:	e8 fb 09 00 00       	call   3fc0 <fork>
    35c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    35c8:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    35cc:	75 10                	jne    35de <validatetest+0x49>
      // try to crash the kernel by passing in a badly placed integer
      validateint((int*)p);
    35ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
    35d1:	89 04 24             	mov    %eax,(%esp)
    35d4:	e8 9a ff ff ff       	call   3573 <validateint>
      exit();
    35d9:	e8 ea 09 00 00       	call   3fc8 <exit>
    }
    sleep(0);
    35de:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    35e5:	e8 6e 0a 00 00       	call   4058 <sleep>
    sleep(0);
    35ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    35f1:	e8 62 0a 00 00       	call   4058 <sleep>
    kill(pid);
    35f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
    35f9:	89 04 24             	mov    %eax,(%esp)
    35fc:	e8 f7 09 00 00       	call   3ff8 <kill>
    wait();
    3601:	e8 ca 09 00 00       	call   3fd0 <wait>

    // try to crash the kernel by passing in a bad string pointer
    if(link("nosuchfile", (char*)p) != -1){
    3606:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3609:	89 44 24 04          	mov    %eax,0x4(%esp)
    360d:	c7 04 24 ea 5a 00 00 	movl   $0x5aea,(%esp)
    3614:	e8 0f 0a 00 00       	call   4028 <link>
    3619:	83 f8 ff             	cmp    $0xffffffff,%eax
    361c:	74 1a                	je     3638 <validatetest+0xa3>
      printf(stdout, "link should not succeed\n");
    361e:	a1 bc 64 00 00       	mov    0x64bc,%eax
    3623:	c7 44 24 04 f5 5a 00 	movl   $0x5af5,0x4(%esp)
    362a:	00 
    362b:	89 04 24             	mov    %eax,(%esp)
    362e:	e8 42 0b 00 00       	call   4175 <printf>
      exit();
    3633:	e8 90 09 00 00       	call   3fc8 <exit>
  uint p;

  printf(stdout, "validate test\n");
  hi = 1100*1024;

  for(p = 0; p <= (uint)hi; p += 4096){
    3638:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    363f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    3642:	3b 45 f4             	cmp    -0xc(%ebp),%eax
    3645:	0f 83 75 ff ff ff    	jae    35c0 <validatetest+0x2b>
      printf(stdout, "link should not succeed\n");
      exit();
    }
  }

  printf(stdout, "validate ok\n");
    364b:	a1 bc 64 00 00       	mov    0x64bc,%eax
    3650:	c7 44 24 04 0e 5b 00 	movl   $0x5b0e,0x4(%esp)
    3657:	00 
    3658:	89 04 24             	mov    %eax,(%esp)
    365b:	e8 15 0b 00 00       	call   4175 <printf>
}
    3660:	c9                   	leave  
    3661:	c3                   	ret    

00003662 <bsstest>:

// does unintialized data start out zero?
char uninit[10000];
void
bsstest(void)
{
    3662:	55                   	push   %ebp
    3663:	89 e5                	mov    %esp,%ebp
    3665:	83 ec 28             	sub    $0x28,%esp
  int i;

  printf(stdout, "bss test\n");
    3668:	a1 bc 64 00 00       	mov    0x64bc,%eax
    366d:	c7 44 24 04 1b 5b 00 	movl   $0x5b1b,0x4(%esp)
    3674:	00 
    3675:	89 04 24             	mov    %eax,(%esp)
    3678:	e8 f8 0a 00 00       	call   4175 <printf>
  for(i = 0; i < sizeof(uninit); i++){
    367d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3684:	eb 2b                	jmp    36b1 <bsstest+0x4f>
    if(uninit[i] != '\0'){
    3686:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3689:	05 80 65 00 00       	add    $0x6580,%eax
    368e:	8a 00                	mov    (%eax),%al
    3690:	84 c0                	test   %al,%al
    3692:	74 1a                	je     36ae <bsstest+0x4c>
      printf(stdout, "bss test failed\n");
    3694:	a1 bc 64 00 00       	mov    0x64bc,%eax
    3699:	c7 44 24 04 25 5b 00 	movl   $0x5b25,0x4(%esp)
    36a0:	00 
    36a1:	89 04 24             	mov    %eax,(%esp)
    36a4:	e8 cc 0a 00 00       	call   4175 <printf>
      exit();
    36a9:	e8 1a 09 00 00       	call   3fc8 <exit>
bsstest(void)
{
  int i;

  printf(stdout, "bss test\n");
  for(i = 0; i < sizeof(uninit); i++){
    36ae:	ff 45 f4             	incl   -0xc(%ebp)
    36b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
    36b4:	3d 0f 27 00 00       	cmp    $0x270f,%eax
    36b9:	76 cb                	jbe    3686 <bsstest+0x24>
    if(uninit[i] != '\0'){
      printf(stdout, "bss test failed\n");
      exit();
    }
  }
  printf(stdout, "bss test ok\n");
    36bb:	a1 bc 64 00 00       	mov    0x64bc,%eax
    36c0:	c7 44 24 04 36 5b 00 	movl   $0x5b36,0x4(%esp)
    36c7:	00 
    36c8:	89 04 24             	mov    %eax,(%esp)
    36cb:	e8 a5 0a 00 00       	call   4175 <printf>
}
    36d0:	c9                   	leave  
    36d1:	c3                   	ret    

000036d2 <bigargtest>:
// does exec return an error if the arguments
// are larger than a page? or does it write
// below the stack and wreck the instructions/data?
void
bigargtest(void)
{
    36d2:	55                   	push   %ebp
    36d3:	89 e5                	mov    %esp,%ebp
    36d5:	83 ec 28             	sub    $0x28,%esp
  int pid, fd;

  unlink("bigarg-ok");
    36d8:	c7 04 24 43 5b 00 00 	movl   $0x5b43,(%esp)
    36df:	e8 34 09 00 00       	call   4018 <unlink>
  pid = fork();
    36e4:	e8 d7 08 00 00       	call   3fc0 <fork>
    36e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid == 0){
    36ec:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    36f0:	0f 85 8f 00 00 00    	jne    3785 <bigargtest+0xb3>
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
    36f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    36fd:	eb 11                	jmp    3710 <bigargtest+0x3e>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    36ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3702:	c7 04 85 e0 64 00 00 	movl   $0x5b50,0x64e0(,%eax,4)
    3709:	50 5b 00 00 
  unlink("bigarg-ok");
  pid = fork();
  if(pid == 0){
    static char *args[MAXARG];
    int i;
    for(i = 0; i < MAXARG-1; i++)
    370d:	ff 45 f4             	incl   -0xc(%ebp)
    3710:	83 7d f4 1e          	cmpl   $0x1e,-0xc(%ebp)
    3714:	7e e9                	jle    36ff <bigargtest+0x2d>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    args[MAXARG-1] = 0;
    3716:	c7 05 5c 65 00 00 00 	movl   $0x0,0x655c
    371d:	00 00 00 
    printf(stdout, "bigarg test\n");
    3720:	a1 bc 64 00 00       	mov    0x64bc,%eax
    3725:	c7 44 24 04 2d 5c 00 	movl   $0x5c2d,0x4(%esp)
    372c:	00 
    372d:	89 04 24             	mov    %eax,(%esp)
    3730:	e8 40 0a 00 00       	call   4175 <printf>
    exec("echo", args);
    3735:	c7 44 24 04 e0 64 00 	movl   $0x64e0,0x4(%esp)
    373c:	00 
    373d:	c7 04 24 3c 45 00 00 	movl   $0x453c,(%esp)
    3744:	e8 b7 08 00 00       	call   4000 <exec>
    printf(stdout, "bigarg test ok\n");
    3749:	a1 bc 64 00 00       	mov    0x64bc,%eax
    374e:	c7 44 24 04 3a 5c 00 	movl   $0x5c3a,0x4(%esp)
    3755:	00 
    3756:	89 04 24             	mov    %eax,(%esp)
    3759:	e8 17 0a 00 00       	call   4175 <printf>
    fd = open("bigarg-ok", O_CREATE);
    375e:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    3765:	00 
    3766:	c7 04 24 43 5b 00 00 	movl   $0x5b43,(%esp)
    376d:	e8 96 08 00 00       	call   4008 <open>
    3772:	89 45 ec             	mov    %eax,-0x14(%ebp)
    close(fd);
    3775:	8b 45 ec             	mov    -0x14(%ebp),%eax
    3778:	89 04 24             	mov    %eax,(%esp)
    377b:	e8 70 08 00 00       	call   3ff0 <close>
    exit();
    3780:	e8 43 08 00 00       	call   3fc8 <exit>
  } else if(pid < 0){
    3785:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3789:	79 1a                	jns    37a5 <bigargtest+0xd3>
    printf(stdout, "bigargtest: fork failed\n");
    378b:	a1 bc 64 00 00       	mov    0x64bc,%eax
    3790:	c7 44 24 04 4a 5c 00 	movl   $0x5c4a,0x4(%esp)
    3797:	00 
    3798:	89 04 24             	mov    %eax,(%esp)
    379b:	e8 d5 09 00 00       	call   4175 <printf>
    exit();
    37a0:	e8 23 08 00 00       	call   3fc8 <exit>
  }
  wait();
    37a5:	e8 26 08 00 00       	call   3fd0 <wait>
  fd = open("bigarg-ok", 0);
    37aa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    37b1:	00 
    37b2:	c7 04 24 43 5b 00 00 	movl   $0x5b43,(%esp)
    37b9:	e8 4a 08 00 00       	call   4008 <open>
    37be:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(fd < 0){
    37c1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    37c5:	79 1a                	jns    37e1 <bigargtest+0x10f>
    printf(stdout, "bigarg test failed!\n");
    37c7:	a1 bc 64 00 00       	mov    0x64bc,%eax
    37cc:	c7 44 24 04 63 5c 00 	movl   $0x5c63,0x4(%esp)
    37d3:	00 
    37d4:	89 04 24             	mov    %eax,(%esp)
    37d7:	e8 99 09 00 00       	call   4175 <printf>
    exit();
    37dc:	e8 e7 07 00 00       	call   3fc8 <exit>
  }
  close(fd);
    37e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
    37e4:	89 04 24             	mov    %eax,(%esp)
    37e7:	e8 04 08 00 00       	call   3ff0 <close>
  unlink("bigarg-ok");
    37ec:	c7 04 24 43 5b 00 00 	movl   $0x5b43,(%esp)
    37f3:	e8 20 08 00 00       	call   4018 <unlink>
}
    37f8:	c9                   	leave  
    37f9:	c3                   	ret    

000037fa <fsfull>:

// what happens when the file system runs out of blocks?
// answer: balloc panics, so this test is not useful.
void
fsfull()
{
    37fa:	55                   	push   %ebp
    37fb:	89 e5                	mov    %esp,%ebp
    37fd:	53                   	push   %ebx
    37fe:	83 ec 74             	sub    $0x74,%esp
  int nfiles;
  int fsblocks = 0;
    3801:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  printf(1, "fsfull test\n");
    3808:	c7 44 24 04 78 5c 00 	movl   $0x5c78,0x4(%esp)
    380f:	00 
    3810:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3817:	e8 59 09 00 00       	call   4175 <printf>

  for(nfiles = 0; ; nfiles++){
    381c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    char name[64];
    name[0] = 'f';
    3823:	c6 45 a4 66          	movb   $0x66,-0x5c(%ebp)
    name[1] = '0' + nfiles / 1000;
    3827:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    382a:	b8 d3 4d 62 10       	mov    $0x10624dd3,%eax
    382f:	f7 e9                	imul   %ecx
    3831:	c1 fa 06             	sar    $0x6,%edx
    3834:	89 c8                	mov    %ecx,%eax
    3836:	c1 f8 1f             	sar    $0x1f,%eax
    3839:	29 c2                	sub    %eax,%edx
    383b:	89 d0                	mov    %edx,%eax
    383d:	83 c0 30             	add    $0x30,%eax
    3840:	88 45 a5             	mov    %al,-0x5b(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    3843:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3846:	b8 d3 4d 62 10       	mov    $0x10624dd3,%eax
    384b:	f7 eb                	imul   %ebx
    384d:	c1 fa 06             	sar    $0x6,%edx
    3850:	89 d8                	mov    %ebx,%eax
    3852:	c1 f8 1f             	sar    $0x1f,%eax
    3855:	89 d1                	mov    %edx,%ecx
    3857:	29 c1                	sub    %eax,%ecx
    3859:	89 c8                	mov    %ecx,%eax
    385b:	c1 e0 02             	shl    $0x2,%eax
    385e:	01 c8                	add    %ecx,%eax
    3860:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    3867:	01 d0                	add    %edx,%eax
    3869:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    3870:	01 d0                	add    %edx,%eax
    3872:	c1 e0 03             	shl    $0x3,%eax
    3875:	29 c3                	sub    %eax,%ebx
    3877:	89 d9                	mov    %ebx,%ecx
    3879:	b8 1f 85 eb 51       	mov    $0x51eb851f,%eax
    387e:	f7 e9                	imul   %ecx
    3880:	c1 fa 05             	sar    $0x5,%edx
    3883:	89 c8                	mov    %ecx,%eax
    3885:	c1 f8 1f             	sar    $0x1f,%eax
    3888:	29 c2                	sub    %eax,%edx
    388a:	89 d0                	mov    %edx,%eax
    388c:	83 c0 30             	add    $0x30,%eax
    388f:	88 45 a6             	mov    %al,-0x5a(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    3892:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3895:	b8 1f 85 eb 51       	mov    $0x51eb851f,%eax
    389a:	f7 eb                	imul   %ebx
    389c:	c1 fa 05             	sar    $0x5,%edx
    389f:	89 d8                	mov    %ebx,%eax
    38a1:	c1 f8 1f             	sar    $0x1f,%eax
    38a4:	89 d1                	mov    %edx,%ecx
    38a6:	29 c1                	sub    %eax,%ecx
    38a8:	89 c8                	mov    %ecx,%eax
    38aa:	c1 e0 02             	shl    $0x2,%eax
    38ad:	01 c8                	add    %ecx,%eax
    38af:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    38b6:	01 d0                	add    %edx,%eax
    38b8:	c1 e0 02             	shl    $0x2,%eax
    38bb:	29 c3                	sub    %eax,%ebx
    38bd:	89 d9                	mov    %ebx,%ecx
    38bf:	b8 67 66 66 66       	mov    $0x66666667,%eax
    38c4:	f7 e9                	imul   %ecx
    38c6:	c1 fa 02             	sar    $0x2,%edx
    38c9:	89 c8                	mov    %ecx,%eax
    38cb:	c1 f8 1f             	sar    $0x1f,%eax
    38ce:	29 c2                	sub    %eax,%edx
    38d0:	89 d0                	mov    %edx,%eax
    38d2:	83 c0 30             	add    $0x30,%eax
    38d5:	88 45 a7             	mov    %al,-0x59(%ebp)
    name[4] = '0' + (nfiles % 10);
    38d8:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    38db:	b8 67 66 66 66       	mov    $0x66666667,%eax
    38e0:	f7 e9                	imul   %ecx
    38e2:	c1 fa 02             	sar    $0x2,%edx
    38e5:	89 c8                	mov    %ecx,%eax
    38e7:	c1 f8 1f             	sar    $0x1f,%eax
    38ea:	29 c2                	sub    %eax,%edx
    38ec:	89 d0                	mov    %edx,%eax
    38ee:	c1 e0 02             	shl    $0x2,%eax
    38f1:	01 d0                	add    %edx,%eax
    38f3:	01 c0                	add    %eax,%eax
    38f5:	29 c1                	sub    %eax,%ecx
    38f7:	89 ca                	mov    %ecx,%edx
    38f9:	88 d0                	mov    %dl,%al
    38fb:	83 c0 30             	add    $0x30,%eax
    38fe:	88 45 a8             	mov    %al,-0x58(%ebp)
    name[5] = '\0';
    3901:	c6 45 a9 00          	movb   $0x0,-0x57(%ebp)
    printf(1, "writing %s\n", name);
    3905:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    3908:	89 44 24 08          	mov    %eax,0x8(%esp)
    390c:	c7 44 24 04 85 5c 00 	movl   $0x5c85,0x4(%esp)
    3913:	00 
    3914:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    391b:	e8 55 08 00 00       	call   4175 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    3920:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
    3927:	00 
    3928:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    392b:	89 04 24             	mov    %eax,(%esp)
    392e:	e8 d5 06 00 00       	call   4008 <open>
    3933:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(fd < 0){
    3936:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
    393a:	79 1d                	jns    3959 <fsfull+0x15f>
      printf(1, "open %s failed\n", name);
    393c:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    393f:	89 44 24 08          	mov    %eax,0x8(%esp)
    3943:	c7 44 24 04 91 5c 00 	movl   $0x5c91,0x4(%esp)
    394a:	00 
    394b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3952:	e8 1e 08 00 00       	call   4175 <printf>
      break;
    3957:	eb 72                	jmp    39cb <fsfull+0x1d1>
    }
    int total = 0;
    3959:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    while(1){
      int cc = write(fd, buf, 512);
    3960:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
    3967:	00 
    3968:	c7 44 24 04 a0 8c 00 	movl   $0x8ca0,0x4(%esp)
    396f:	00 
    3970:	8b 45 e8             	mov    -0x18(%ebp),%eax
    3973:	89 04 24             	mov    %eax,(%esp)
    3976:	e8 6d 06 00 00       	call   3fe8 <write>
    397b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(cc < 512)
    397e:	81 7d e4 ff 01 00 00 	cmpl   $0x1ff,-0x1c(%ebp)
    3985:	7f 2f                	jg     39b6 <fsfull+0x1bc>
        break;
    3987:	90                   	nop
      total += cc;
      fsblocks++;
    }
    printf(1, "wrote %d bytes\n", total);
    3988:	8b 45 ec             	mov    -0x14(%ebp),%eax
    398b:	89 44 24 08          	mov    %eax,0x8(%esp)
    398f:	c7 44 24 04 a1 5c 00 	movl   $0x5ca1,0x4(%esp)
    3996:	00 
    3997:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    399e:	e8 d2 07 00 00       	call   4175 <printf>
    close(fd);
    39a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
    39a6:	89 04 24             	mov    %eax,(%esp)
    39a9:	e8 42 06 00 00       	call   3ff0 <close>
    if(total == 0)
    39ae:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    39b2:	75 0f                	jne    39c3 <fsfull+0x1c9>
    39b4:	eb 0b                	jmp    39c1 <fsfull+0x1c7>
    int total = 0;
    while(1){
      int cc = write(fd, buf, 512);
      if(cc < 512)
        break;
      total += cc;
    39b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    39b9:	01 45 ec             	add    %eax,-0x14(%ebp)
      fsblocks++;
    39bc:	ff 45 f0             	incl   -0x10(%ebp)
    }
    39bf:	eb 9f                	jmp    3960 <fsfull+0x166>
    printf(1, "wrote %d bytes\n", total);
    close(fd);
    if(total == 0)
      break;
    39c1:	eb 08                	jmp    39cb <fsfull+0x1d1>
  int nfiles;
  int fsblocks = 0;

  printf(1, "fsfull test\n");

  for(nfiles = 0; ; nfiles++){
    39c3:	ff 45 f4             	incl   -0xc(%ebp)
    }
    printf(1, "wrote %d bytes\n", total);
    close(fd);
    if(total == 0)
      break;
  }
    39c6:	e9 58 fe ff ff       	jmp    3823 <fsfull+0x29>

  while(nfiles >= 0){
    39cb:	e9 f0 00 00 00       	jmp    3ac0 <fsfull+0x2c6>
    char name[64];
    name[0] = 'f';
    39d0:	c6 45 a4 66          	movb   $0x66,-0x5c(%ebp)
    name[1] = '0' + nfiles / 1000;
    39d4:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    39d7:	b8 d3 4d 62 10       	mov    $0x10624dd3,%eax
    39dc:	f7 e9                	imul   %ecx
    39de:	c1 fa 06             	sar    $0x6,%edx
    39e1:	89 c8                	mov    %ecx,%eax
    39e3:	c1 f8 1f             	sar    $0x1f,%eax
    39e6:	29 c2                	sub    %eax,%edx
    39e8:	89 d0                	mov    %edx,%eax
    39ea:	83 c0 30             	add    $0x30,%eax
    39ed:	88 45 a5             	mov    %al,-0x5b(%ebp)
    name[2] = '0' + (nfiles % 1000) / 100;
    39f0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    39f3:	b8 d3 4d 62 10       	mov    $0x10624dd3,%eax
    39f8:	f7 eb                	imul   %ebx
    39fa:	c1 fa 06             	sar    $0x6,%edx
    39fd:	89 d8                	mov    %ebx,%eax
    39ff:	c1 f8 1f             	sar    $0x1f,%eax
    3a02:	89 d1                	mov    %edx,%ecx
    3a04:	29 c1                	sub    %eax,%ecx
    3a06:	89 c8                	mov    %ecx,%eax
    3a08:	c1 e0 02             	shl    $0x2,%eax
    3a0b:	01 c8                	add    %ecx,%eax
    3a0d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    3a14:	01 d0                	add    %edx,%eax
    3a16:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    3a1d:	01 d0                	add    %edx,%eax
    3a1f:	c1 e0 03             	shl    $0x3,%eax
    3a22:	29 c3                	sub    %eax,%ebx
    3a24:	89 d9                	mov    %ebx,%ecx
    3a26:	b8 1f 85 eb 51       	mov    $0x51eb851f,%eax
    3a2b:	f7 e9                	imul   %ecx
    3a2d:	c1 fa 05             	sar    $0x5,%edx
    3a30:	89 c8                	mov    %ecx,%eax
    3a32:	c1 f8 1f             	sar    $0x1f,%eax
    3a35:	29 c2                	sub    %eax,%edx
    3a37:	89 d0                	mov    %edx,%eax
    3a39:	83 c0 30             	add    $0x30,%eax
    3a3c:	88 45 a6             	mov    %al,-0x5a(%ebp)
    name[3] = '0' + (nfiles % 100) / 10;
    3a3f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
    3a42:	b8 1f 85 eb 51       	mov    $0x51eb851f,%eax
    3a47:	f7 eb                	imul   %ebx
    3a49:	c1 fa 05             	sar    $0x5,%edx
    3a4c:	89 d8                	mov    %ebx,%eax
    3a4e:	c1 f8 1f             	sar    $0x1f,%eax
    3a51:	89 d1                	mov    %edx,%ecx
    3a53:	29 c1                	sub    %eax,%ecx
    3a55:	89 c8                	mov    %ecx,%eax
    3a57:	c1 e0 02             	shl    $0x2,%eax
    3a5a:	01 c8                	add    %ecx,%eax
    3a5c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    3a63:	01 d0                	add    %edx,%eax
    3a65:	c1 e0 02             	shl    $0x2,%eax
    3a68:	29 c3                	sub    %eax,%ebx
    3a6a:	89 d9                	mov    %ebx,%ecx
    3a6c:	b8 67 66 66 66       	mov    $0x66666667,%eax
    3a71:	f7 e9                	imul   %ecx
    3a73:	c1 fa 02             	sar    $0x2,%edx
    3a76:	89 c8                	mov    %ecx,%eax
    3a78:	c1 f8 1f             	sar    $0x1f,%eax
    3a7b:	29 c2                	sub    %eax,%edx
    3a7d:	89 d0                	mov    %edx,%eax
    3a7f:	83 c0 30             	add    $0x30,%eax
    3a82:	88 45 a7             	mov    %al,-0x59(%ebp)
    name[4] = '0' + (nfiles % 10);
    3a85:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    3a88:	b8 67 66 66 66       	mov    $0x66666667,%eax
    3a8d:	f7 e9                	imul   %ecx
    3a8f:	c1 fa 02             	sar    $0x2,%edx
    3a92:	89 c8                	mov    %ecx,%eax
    3a94:	c1 f8 1f             	sar    $0x1f,%eax
    3a97:	29 c2                	sub    %eax,%edx
    3a99:	89 d0                	mov    %edx,%eax
    3a9b:	c1 e0 02             	shl    $0x2,%eax
    3a9e:	01 d0                	add    %edx,%eax
    3aa0:	01 c0                	add    %eax,%eax
    3aa2:	29 c1                	sub    %eax,%ecx
    3aa4:	89 ca                	mov    %ecx,%edx
    3aa6:	88 d0                	mov    %dl,%al
    3aa8:	83 c0 30             	add    $0x30,%eax
    3aab:	88 45 a8             	mov    %al,-0x58(%ebp)
    name[5] = '\0';
    3aae:	c6 45 a9 00          	movb   $0x0,-0x57(%ebp)
    unlink(name);
    3ab2:	8d 45 a4             	lea    -0x5c(%ebp),%eax
    3ab5:	89 04 24             	mov    %eax,(%esp)
    3ab8:	e8 5b 05 00 00       	call   4018 <unlink>
    nfiles--;
    3abd:	ff 4d f4             	decl   -0xc(%ebp)
    close(fd);
    if(total == 0)
      break;
  }

  while(nfiles >= 0){
    3ac0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3ac4:	0f 89 06 ff ff ff    	jns    39d0 <fsfull+0x1d6>
    name[5] = '\0';
    unlink(name);
    nfiles--;
  }

  printf(1, "fsfull test finished\n");
    3aca:	c7 44 24 04 b1 5c 00 	movl   $0x5cb1,0x4(%esp)
    3ad1:	00 
    3ad2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3ad9:	e8 97 06 00 00       	call   4175 <printf>
}
    3ade:	83 c4 74             	add    $0x74,%esp
    3ae1:	5b                   	pop    %ebx
    3ae2:	5d                   	pop    %ebp
    3ae3:	c3                   	ret    

00003ae4 <uio>:

void
uio()
{
    3ae4:	55                   	push   %ebp
    3ae5:	89 e5                	mov    %esp,%ebp
    3ae7:	83 ec 28             	sub    $0x28,%esp
  #define RTC_ADDR 0x70
  #define RTC_DATA 0x71

  ushort port = 0;
    3aea:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
  uchar val = 0;
    3af0:	c6 45 f5 00          	movb   $0x0,-0xb(%ebp)
  int pid;

  printf(1, "uio test\n");
    3af4:	c7 44 24 04 c7 5c 00 	movl   $0x5cc7,0x4(%esp)
    3afb:	00 
    3afc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3b03:	e8 6d 06 00 00       	call   4175 <printf>
  pid = fork();
    3b08:	e8 b3 04 00 00       	call   3fc0 <fork>
    3b0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(pid == 0){
    3b10:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3b14:	75 3b                	jne    3b51 <uio+0x6d>
    port = RTC_ADDR;
    3b16:	66 c7 45 f6 70 00    	movw   $0x70,-0xa(%ebp)
    val = 0x09;  /* year */
    3b1c:	c6 45 f5 09          	movb   $0x9,-0xb(%ebp)
    /* http://wiki.osdev.org/Inline_Assembly/Examples */
    asm volatile("outb %0,%1"::"a"(val), "d" (port));
    3b20:	8a 45 f5             	mov    -0xb(%ebp),%al
    3b23:	66 8b 55 f6          	mov    -0xa(%ebp),%dx
    3b27:	ee                   	out    %al,(%dx)
    port = RTC_DATA;
    3b28:	66 c7 45 f6 71 00    	movw   $0x71,-0xa(%ebp)
    asm volatile("inb %1,%0" : "=a" (val) : "d" (port));
    3b2e:	66 8b 45 f6          	mov    -0xa(%ebp),%ax
    3b32:	89 c2                	mov    %eax,%edx
    3b34:	ec                   	in     (%dx),%al
    3b35:	88 45 f5             	mov    %al,-0xb(%ebp)
    printf(1, "uio: uio succeeded; test FAILED\n");
    3b38:	c7 44 24 04 d4 5c 00 	movl   $0x5cd4,0x4(%esp)
    3b3f:	00 
    3b40:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3b47:	e8 29 06 00 00       	call   4175 <printf>
    exit();
    3b4c:	e8 77 04 00 00       	call   3fc8 <exit>
  } else if(pid < 0){
    3b51:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3b55:	79 19                	jns    3b70 <uio+0x8c>
    printf (1, "fork failed\n");
    3b57:	c7 44 24 04 dd 45 00 	movl   $0x45dd,0x4(%esp)
    3b5e:	00 
    3b5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3b66:	e8 0a 06 00 00       	call   4175 <printf>
    exit();
    3b6b:	e8 58 04 00 00       	call   3fc8 <exit>
  }
  wait();
    3b70:	e8 5b 04 00 00       	call   3fd0 <wait>
  printf(1, "uio test done\n");
    3b75:	c7 44 24 04 f5 5c 00 	movl   $0x5cf5,0x4(%esp)
    3b7c:	00 
    3b7d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3b84:	e8 ec 05 00 00       	call   4175 <printf>
}
    3b89:	c9                   	leave  
    3b8a:	c3                   	ret    

00003b8b <argptest>:

void argptest()
{
    3b8b:	55                   	push   %ebp
    3b8c:	89 e5                	mov    %esp,%ebp
    3b8e:	83 ec 28             	sub    $0x28,%esp
  int fd;
  fd = open("init", O_RDONLY);
    3b91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    3b98:	00 
    3b99:	c7 04 24 04 5d 00 00 	movl   $0x5d04,(%esp)
    3ba0:	e8 63 04 00 00       	call   4008 <open>
    3ba5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (fd < 0) {
    3ba8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3bac:	79 19                	jns    3bc7 <argptest+0x3c>
    printf(2, "open failed\n");
    3bae:	c7 44 24 04 09 5d 00 	movl   $0x5d09,0x4(%esp)
    3bb5:	00 
    3bb6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
    3bbd:	e8 b3 05 00 00       	call   4175 <printf>
    exit();
    3bc2:	e8 01 04 00 00       	call   3fc8 <exit>
  }
  read(fd, sbrk(0) - 1, -1);
    3bc7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3bce:	e8 7d 04 00 00       	call   4050 <sbrk>
    3bd3:	48                   	dec    %eax
    3bd4:	c7 44 24 08 ff ff ff 	movl   $0xffffffff,0x8(%esp)
    3bdb:	ff 
    3bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
    3be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3be3:	89 04 24             	mov    %eax,(%esp)
    3be6:	e8 f5 03 00 00       	call   3fe0 <read>
  close(fd);
    3beb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3bee:	89 04 24             	mov    %eax,(%esp)
    3bf1:	e8 fa 03 00 00       	call   3ff0 <close>
  printf(1, "arg test passed\n");
    3bf6:	c7 44 24 04 16 5d 00 	movl   $0x5d16,0x4(%esp)
    3bfd:	00 
    3bfe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3c05:	e8 6b 05 00 00       	call   4175 <printf>
}
    3c0a:	c9                   	leave  
    3c0b:	c3                   	ret    

00003c0c <rand>:

unsigned long randstate = 1;
unsigned int
rand()
{
    3c0c:	55                   	push   %ebp
    3c0d:	89 e5                	mov    %esp,%ebp
  randstate = randstate * 1664525 + 1013904223;
    3c0f:	8b 15 c0 64 00 00    	mov    0x64c0,%edx
    3c15:	89 d0                	mov    %edx,%eax
    3c17:	01 c0                	add    %eax,%eax
    3c19:	01 d0                	add    %edx,%eax
    3c1b:	c1 e0 02             	shl    $0x2,%eax
    3c1e:	01 d0                	add    %edx,%eax
    3c20:	c1 e0 08             	shl    $0x8,%eax
    3c23:	01 d0                	add    %edx,%eax
    3c25:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
    3c2c:	01 c8                	add    %ecx,%eax
    3c2e:	c1 e0 02             	shl    $0x2,%eax
    3c31:	01 d0                	add    %edx,%eax
    3c33:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    3c3a:	01 d0                	add    %edx,%eax
    3c3c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
    3c43:	01 d0                	add    %edx,%eax
    3c45:	05 5f f3 6e 3c       	add    $0x3c6ef35f,%eax
    3c4a:	a3 c0 64 00 00       	mov    %eax,0x64c0
  return randstate;
    3c4f:	a1 c0 64 00 00       	mov    0x64c0,%eax
}
    3c54:	5d                   	pop    %ebp
    3c55:	c3                   	ret    

00003c56 <main>:

int
main(int argc, char *argv[])
{
    3c56:	55                   	push   %ebp
    3c57:	89 e5                	mov    %esp,%ebp
    3c59:	83 e4 f0             	and    $0xfffffff0,%esp
    3c5c:	83 ec 10             	sub    $0x10,%esp
  printf(1, "usertests starting\n");
    3c5f:	c7 44 24 04 27 5d 00 	movl   $0x5d27,0x4(%esp)
    3c66:	00 
    3c67:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3c6e:	e8 02 05 00 00       	call   4175 <printf>

  if(open("usertests.ran", 0) >= 0){
    3c73:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    3c7a:	00 
    3c7b:	c7 04 24 3b 5d 00 00 	movl   $0x5d3b,(%esp)
    3c82:	e8 81 03 00 00       	call   4008 <open>
    3c87:	85 c0                	test   %eax,%eax
    3c89:	78 19                	js     3ca4 <main+0x4e>
    printf(1, "already ran user tests -- rebuild fs.img\n");
    3c8b:	c7 44 24 04 4c 5d 00 	movl   $0x5d4c,0x4(%esp)
    3c92:	00 
    3c93:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
    3c9a:	e8 d6 04 00 00       	call   4175 <printf>
    exit();
    3c9f:	e8 24 03 00 00       	call   3fc8 <exit>
  }
  close(open("usertests.ran", O_CREATE));
    3ca4:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
    3cab:	00 
    3cac:	c7 04 24 3b 5d 00 00 	movl   $0x5d3b,(%esp)
    3cb3:	e8 50 03 00 00       	call   4008 <open>
    3cb8:	89 04 24             	mov    %eax,(%esp)
    3cbb:	e8 30 03 00 00       	call   3ff0 <close>

  argptest();
    3cc0:	e8 c6 fe ff ff       	call   3b8b <argptest>
  createdelete();
    3cc5:	e8 a9 d5 ff ff       	call   1273 <createdelete>
  linkunlink();
    3cca:	e8 94 df ff ff       	call   1c63 <linkunlink>
  concreate();
    3ccf:	e8 2a dc ff ff       	call   18fe <concreate>
  fourfiles();
    3cd4:	e8 36 d3 ff ff       	call   100f <fourfiles>
  sharedfd();
    3cd9:	e8 39 d1 ff ff       	call   e17 <sharedfd>

  bigargtest();
    3cde:	e8 ef f9 ff ff       	call   36d2 <bigargtest>
  bigwrite();
    3ce3:	e8 73 e9 ff ff       	call   265b <bigwrite>
  bigargtest();
    3ce8:	e8 e5 f9 ff ff       	call   36d2 <bigargtest>
  bsstest();
    3ced:	e8 70 f9 ff ff       	call   3662 <bsstest>
  sbrktest();
    3cf2:	e8 95 f3 ff ff       	call   308c <sbrktest>
  validatetest();
    3cf7:	e8 99 f8 ff ff       	call   3595 <validatetest>

  opentest();
    3cfc:	e8 c6 c5 ff ff       	call   2c7 <opentest>
  writetest();
    3d01:	e8 6c c6 ff ff       	call   372 <writetest>
  writetest1();
    3d06:	e8 7b c8 ff ff       	call   586 <writetest1>
  createtest();
    3d0b:	e8 7f ca ff ff       	call   78f <createtest>

  openiputtest();
    3d10:	e8 b1 c4 ff ff       	call   1c6 <openiputtest>
  exitiputtest();
    3d15:	e8 c0 c3 ff ff       	call   da <exitiputtest>
  iputtest();
    3d1a:	e8 e1 c2 ff ff       	call   0 <iputtest>

  mem();
    3d1f:	e8 0e d0 ff ff       	call   d32 <mem>
  pipe1();
    3d24:	e8 45 cc ff ff       	call   96e <pipe1>
  preempt();
    3d29:	e8 2e ce ff ff       	call   b5c <preempt>
  exitwait();
    3d2e:	e8 82 cf ff ff       	call   cb5 <exitwait>

  rmdot();
    3d33:	e8 a5 ed ff ff       	call   2add <rmdot>
  fourteen();
    3d38:	e8 4a ec ff ff       	call   2987 <fourteen>
  bigfile();
    3d3d:	e8 20 ea ff ff       	call   2762 <bigfile>
  subdir();
    3d42:	e8 d0 e1 ff ff       	call   1f17 <subdir>
  linktest();
    3d47:	e8 69 d9 ff ff       	call   16b5 <linktest>
  unlinkread();
    3d4c:	e8 91 d7 ff ff       	call   14e2 <unlinkread>
  dirfile();
    3d51:	e8 ff ee ff ff       	call   2c55 <dirfile>
  iref();
    3d56:	e8 3c f1 ff ff       	call   2e97 <iref>
  forktest();
    3d5b:	e8 5a f2 ff ff       	call   2fba <forktest>
  bigdir(); // slow
    3d60:	e8 43 e0 ff ff       	call   1da8 <bigdir>

  uio();
    3d65:	e8 7a fd ff ff       	call   3ae4 <uio>

  exectest();
    3d6a:	e8 b0 cb ff ff       	call   91f <exectest>

  exit();
    3d6f:	e8 54 02 00 00       	call   3fc8 <exit>

00003d74 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
    3d74:	55                   	push   %ebp
    3d75:	89 e5                	mov    %esp,%ebp
    3d77:	57                   	push   %edi
    3d78:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
    3d79:	8b 4d 08             	mov    0x8(%ebp),%ecx
    3d7c:	8b 55 10             	mov    0x10(%ebp),%edx
    3d7f:	8b 45 0c             	mov    0xc(%ebp),%eax
    3d82:	89 cb                	mov    %ecx,%ebx
    3d84:	89 df                	mov    %ebx,%edi
    3d86:	89 d1                	mov    %edx,%ecx
    3d88:	fc                   	cld    
    3d89:	f3 aa                	rep stos %al,%es:(%edi)
    3d8b:	89 ca                	mov    %ecx,%edx
    3d8d:	89 fb                	mov    %edi,%ebx
    3d8f:	89 5d 08             	mov    %ebx,0x8(%ebp)
    3d92:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
    3d95:	5b                   	pop    %ebx
    3d96:	5f                   	pop    %edi
    3d97:	5d                   	pop    %ebp
    3d98:	c3                   	ret    

00003d99 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
    3d99:	55                   	push   %ebp
    3d9a:	89 e5                	mov    %esp,%ebp
    3d9c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
    3d9f:	8b 45 08             	mov    0x8(%ebp),%eax
    3da2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
    3da5:	90                   	nop
    3da6:	8b 45 08             	mov    0x8(%ebp),%eax
    3da9:	8d 50 01             	lea    0x1(%eax),%edx
    3dac:	89 55 08             	mov    %edx,0x8(%ebp)
    3daf:	8b 55 0c             	mov    0xc(%ebp),%edx
    3db2:	8d 4a 01             	lea    0x1(%edx),%ecx
    3db5:	89 4d 0c             	mov    %ecx,0xc(%ebp)
    3db8:	8a 12                	mov    (%edx),%dl
    3dba:	88 10                	mov    %dl,(%eax)
    3dbc:	8a 00                	mov    (%eax),%al
    3dbe:	84 c0                	test   %al,%al
    3dc0:	75 e4                	jne    3da6 <strcpy+0xd>
    ;
  return os;
    3dc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    3dc5:	c9                   	leave  
    3dc6:	c3                   	ret    

00003dc7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    3dc7:	55                   	push   %ebp
    3dc8:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
    3dca:	eb 06                	jmp    3dd2 <strcmp+0xb>
    p++, q++;
    3dcc:	ff 45 08             	incl   0x8(%ebp)
    3dcf:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
    3dd2:	8b 45 08             	mov    0x8(%ebp),%eax
    3dd5:	8a 00                	mov    (%eax),%al
    3dd7:	84 c0                	test   %al,%al
    3dd9:	74 0e                	je     3de9 <strcmp+0x22>
    3ddb:	8b 45 08             	mov    0x8(%ebp),%eax
    3dde:	8a 10                	mov    (%eax),%dl
    3de0:	8b 45 0c             	mov    0xc(%ebp),%eax
    3de3:	8a 00                	mov    (%eax),%al
    3de5:	38 c2                	cmp    %al,%dl
    3de7:	74 e3                	je     3dcc <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
    3de9:	8b 45 08             	mov    0x8(%ebp),%eax
    3dec:	8a 00                	mov    (%eax),%al
    3dee:	0f b6 d0             	movzbl %al,%edx
    3df1:	8b 45 0c             	mov    0xc(%ebp),%eax
    3df4:	8a 00                	mov    (%eax),%al
    3df6:	0f b6 c0             	movzbl %al,%eax
    3df9:	29 c2                	sub    %eax,%edx
    3dfb:	89 d0                	mov    %edx,%eax
}
    3dfd:	5d                   	pop    %ebp
    3dfe:	c3                   	ret    

00003dff <strlen>:

uint
strlen(char *s)
{
    3dff:	55                   	push   %ebp
    3e00:	89 e5                	mov    %esp,%ebp
    3e02:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
    3e05:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    3e0c:	eb 03                	jmp    3e11 <strlen+0x12>
    3e0e:	ff 45 fc             	incl   -0x4(%ebp)
    3e11:	8b 55 fc             	mov    -0x4(%ebp),%edx
    3e14:	8b 45 08             	mov    0x8(%ebp),%eax
    3e17:	01 d0                	add    %edx,%eax
    3e19:	8a 00                	mov    (%eax),%al
    3e1b:	84 c0                	test   %al,%al
    3e1d:	75 ef                	jne    3e0e <strlen+0xf>
    ;
  return n;
    3e1f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    3e22:	c9                   	leave  
    3e23:	c3                   	ret    

00003e24 <memset>:

void*
memset(void *dst, int c, uint n)
{
    3e24:	55                   	push   %ebp
    3e25:	89 e5                	mov    %esp,%ebp
    3e27:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
    3e2a:	8b 45 10             	mov    0x10(%ebp),%eax
    3e2d:	89 44 24 08          	mov    %eax,0x8(%esp)
    3e31:	8b 45 0c             	mov    0xc(%ebp),%eax
    3e34:	89 44 24 04          	mov    %eax,0x4(%esp)
    3e38:	8b 45 08             	mov    0x8(%ebp),%eax
    3e3b:	89 04 24             	mov    %eax,(%esp)
    3e3e:	e8 31 ff ff ff       	call   3d74 <stosb>
  return dst;
    3e43:	8b 45 08             	mov    0x8(%ebp),%eax
}
    3e46:	c9                   	leave  
    3e47:	c3                   	ret    

00003e48 <strchr>:

char*
strchr(const char *s, char c)
{
    3e48:	55                   	push   %ebp
    3e49:	89 e5                	mov    %esp,%ebp
    3e4b:	83 ec 04             	sub    $0x4,%esp
    3e4e:	8b 45 0c             	mov    0xc(%ebp),%eax
    3e51:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
    3e54:	eb 12                	jmp    3e68 <strchr+0x20>
    if(*s == c)
    3e56:	8b 45 08             	mov    0x8(%ebp),%eax
    3e59:	8a 00                	mov    (%eax),%al
    3e5b:	3a 45 fc             	cmp    -0x4(%ebp),%al
    3e5e:	75 05                	jne    3e65 <strchr+0x1d>
      return (char*)s;
    3e60:	8b 45 08             	mov    0x8(%ebp),%eax
    3e63:	eb 11                	jmp    3e76 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
    3e65:	ff 45 08             	incl   0x8(%ebp)
    3e68:	8b 45 08             	mov    0x8(%ebp),%eax
    3e6b:	8a 00                	mov    (%eax),%al
    3e6d:	84 c0                	test   %al,%al
    3e6f:	75 e5                	jne    3e56 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
    3e71:	b8 00 00 00 00       	mov    $0x0,%eax
}
    3e76:	c9                   	leave  
    3e77:	c3                   	ret    

00003e78 <gets>:

char*
gets(char *buf, int max)
{
    3e78:	55                   	push   %ebp
    3e79:	89 e5                	mov    %esp,%ebp
    3e7b:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    3e7e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    3e85:	eb 49                	jmp    3ed0 <gets+0x58>
    cc = read(0, &c, 1);
    3e87:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    3e8e:	00 
    3e8f:	8d 45 ef             	lea    -0x11(%ebp),%eax
    3e92:	89 44 24 04          	mov    %eax,0x4(%esp)
    3e96:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
    3e9d:	e8 3e 01 00 00       	call   3fe0 <read>
    3ea2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
    3ea5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    3ea9:	7f 02                	jg     3ead <gets+0x35>
      break;
    3eab:	eb 2c                	jmp    3ed9 <gets+0x61>
    buf[i++] = c;
    3ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3eb0:	8d 50 01             	lea    0x1(%eax),%edx
    3eb3:	89 55 f4             	mov    %edx,-0xc(%ebp)
    3eb6:	89 c2                	mov    %eax,%edx
    3eb8:	8b 45 08             	mov    0x8(%ebp),%eax
    3ebb:	01 c2                	add    %eax,%edx
    3ebd:	8a 45 ef             	mov    -0x11(%ebp),%al
    3ec0:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
    3ec2:	8a 45 ef             	mov    -0x11(%ebp),%al
    3ec5:	3c 0a                	cmp    $0xa,%al
    3ec7:	74 10                	je     3ed9 <gets+0x61>
    3ec9:	8a 45 ef             	mov    -0x11(%ebp),%al
    3ecc:	3c 0d                	cmp    $0xd,%al
    3ece:	74 09                	je     3ed9 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    3ed0:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3ed3:	40                   	inc    %eax
    3ed4:	3b 45 0c             	cmp    0xc(%ebp),%eax
    3ed7:	7c ae                	jl     3e87 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
    3ed9:	8b 55 f4             	mov    -0xc(%ebp),%edx
    3edc:	8b 45 08             	mov    0x8(%ebp),%eax
    3edf:	01 d0                	add    %edx,%eax
    3ee1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
    3ee4:	8b 45 08             	mov    0x8(%ebp),%eax
}
    3ee7:	c9                   	leave  
    3ee8:	c3                   	ret    

00003ee9 <stat>:

int
stat(char *n, struct stat *st)
{
    3ee9:	55                   	push   %ebp
    3eea:	89 e5                	mov    %esp,%ebp
    3eec:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    3eef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
    3ef6:	00 
    3ef7:	8b 45 08             	mov    0x8(%ebp),%eax
    3efa:	89 04 24             	mov    %eax,(%esp)
    3efd:	e8 06 01 00 00       	call   4008 <open>
    3f02:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
    3f05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    3f09:	79 07                	jns    3f12 <stat+0x29>
    return -1;
    3f0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    3f10:	eb 23                	jmp    3f35 <stat+0x4c>
  r = fstat(fd, st);
    3f12:	8b 45 0c             	mov    0xc(%ebp),%eax
    3f15:	89 44 24 04          	mov    %eax,0x4(%esp)
    3f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3f1c:	89 04 24             	mov    %eax,(%esp)
    3f1f:	e8 fc 00 00 00       	call   4020 <fstat>
    3f24:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
    3f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
    3f2a:	89 04 24             	mov    %eax,(%esp)
    3f2d:	e8 be 00 00 00       	call   3ff0 <close>
  return r;
    3f32:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
    3f35:	c9                   	leave  
    3f36:	c3                   	ret    

00003f37 <atoi>:

int
atoi(const char *s)
{
    3f37:	55                   	push   %ebp
    3f38:	89 e5                	mov    %esp,%ebp
    3f3a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
    3f3d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
    3f44:	eb 24                	jmp    3f6a <atoi+0x33>
    n = n*10 + *s++ - '0';
    3f46:	8b 55 fc             	mov    -0x4(%ebp),%edx
    3f49:	89 d0                	mov    %edx,%eax
    3f4b:	c1 e0 02             	shl    $0x2,%eax
    3f4e:	01 d0                	add    %edx,%eax
    3f50:	01 c0                	add    %eax,%eax
    3f52:	89 c1                	mov    %eax,%ecx
    3f54:	8b 45 08             	mov    0x8(%ebp),%eax
    3f57:	8d 50 01             	lea    0x1(%eax),%edx
    3f5a:	89 55 08             	mov    %edx,0x8(%ebp)
    3f5d:	8a 00                	mov    (%eax),%al
    3f5f:	0f be c0             	movsbl %al,%eax
    3f62:	01 c8                	add    %ecx,%eax
    3f64:	83 e8 30             	sub    $0x30,%eax
    3f67:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    3f6a:	8b 45 08             	mov    0x8(%ebp),%eax
    3f6d:	8a 00                	mov    (%eax),%al
    3f6f:	3c 2f                	cmp    $0x2f,%al
    3f71:	7e 09                	jle    3f7c <atoi+0x45>
    3f73:	8b 45 08             	mov    0x8(%ebp),%eax
    3f76:	8a 00                	mov    (%eax),%al
    3f78:	3c 39                	cmp    $0x39,%al
    3f7a:	7e ca                	jle    3f46 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
    3f7c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
    3f7f:	c9                   	leave  
    3f80:	c3                   	ret    

00003f81 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
    3f81:	55                   	push   %ebp
    3f82:	89 e5                	mov    %esp,%ebp
    3f84:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
    3f87:	8b 45 08             	mov    0x8(%ebp),%eax
    3f8a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
    3f8d:	8b 45 0c             	mov    0xc(%ebp),%eax
    3f90:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
    3f93:	eb 16                	jmp    3fab <memmove+0x2a>
    *dst++ = *src++;
    3f95:	8b 45 fc             	mov    -0x4(%ebp),%eax
    3f98:	8d 50 01             	lea    0x1(%eax),%edx
    3f9b:	89 55 fc             	mov    %edx,-0x4(%ebp)
    3f9e:	8b 55 f8             	mov    -0x8(%ebp),%edx
    3fa1:	8d 4a 01             	lea    0x1(%edx),%ecx
    3fa4:	89 4d f8             	mov    %ecx,-0x8(%ebp)
    3fa7:	8a 12                	mov    (%edx),%dl
    3fa9:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
    3fab:	8b 45 10             	mov    0x10(%ebp),%eax
    3fae:	8d 50 ff             	lea    -0x1(%eax),%edx
    3fb1:	89 55 10             	mov    %edx,0x10(%ebp)
    3fb4:	85 c0                	test   %eax,%eax
    3fb6:	7f dd                	jg     3f95 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
    3fb8:	8b 45 08             	mov    0x8(%ebp),%eax
}
    3fbb:	c9                   	leave  
    3fbc:	c3                   	ret    
    3fbd:	90                   	nop
    3fbe:	90                   	nop
    3fbf:	90                   	nop

00003fc0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
    3fc0:	b8 01 00 00 00       	mov    $0x1,%eax
    3fc5:	cd 40                	int    $0x40
    3fc7:	c3                   	ret    

00003fc8 <exit>:
SYSCALL(exit)
    3fc8:	b8 02 00 00 00       	mov    $0x2,%eax
    3fcd:	cd 40                	int    $0x40
    3fcf:	c3                   	ret    

00003fd0 <wait>:
SYSCALL(wait)
    3fd0:	b8 03 00 00 00       	mov    $0x3,%eax
    3fd5:	cd 40                	int    $0x40
    3fd7:	c3                   	ret    

00003fd8 <pipe>:
SYSCALL(pipe)
    3fd8:	b8 04 00 00 00       	mov    $0x4,%eax
    3fdd:	cd 40                	int    $0x40
    3fdf:	c3                   	ret    

00003fe0 <read>:
SYSCALL(read)
    3fe0:	b8 05 00 00 00       	mov    $0x5,%eax
    3fe5:	cd 40                	int    $0x40
    3fe7:	c3                   	ret    

00003fe8 <write>:
SYSCALL(write)
    3fe8:	b8 10 00 00 00       	mov    $0x10,%eax
    3fed:	cd 40                	int    $0x40
    3fef:	c3                   	ret    

00003ff0 <close>:
SYSCALL(close)
    3ff0:	b8 15 00 00 00       	mov    $0x15,%eax
    3ff5:	cd 40                	int    $0x40
    3ff7:	c3                   	ret    

00003ff8 <kill>:
SYSCALL(kill)
    3ff8:	b8 06 00 00 00       	mov    $0x6,%eax
    3ffd:	cd 40                	int    $0x40
    3fff:	c3                   	ret    

00004000 <exec>:
SYSCALL(exec)
    4000:	b8 07 00 00 00       	mov    $0x7,%eax
    4005:	cd 40                	int    $0x40
    4007:	c3                   	ret    

00004008 <open>:
SYSCALL(open)
    4008:	b8 0f 00 00 00       	mov    $0xf,%eax
    400d:	cd 40                	int    $0x40
    400f:	c3                   	ret    

00004010 <mknod>:
SYSCALL(mknod)
    4010:	b8 11 00 00 00       	mov    $0x11,%eax
    4015:	cd 40                	int    $0x40
    4017:	c3                   	ret    

00004018 <unlink>:
SYSCALL(unlink)
    4018:	b8 12 00 00 00       	mov    $0x12,%eax
    401d:	cd 40                	int    $0x40
    401f:	c3                   	ret    

00004020 <fstat>:
SYSCALL(fstat)
    4020:	b8 08 00 00 00       	mov    $0x8,%eax
    4025:	cd 40                	int    $0x40
    4027:	c3                   	ret    

00004028 <link>:
SYSCALL(link)
    4028:	b8 13 00 00 00       	mov    $0x13,%eax
    402d:	cd 40                	int    $0x40
    402f:	c3                   	ret    

00004030 <mkdir>:
SYSCALL(mkdir)
    4030:	b8 14 00 00 00       	mov    $0x14,%eax
    4035:	cd 40                	int    $0x40
    4037:	c3                   	ret    

00004038 <chdir>:
SYSCALL(chdir)
    4038:	b8 09 00 00 00       	mov    $0x9,%eax
    403d:	cd 40                	int    $0x40
    403f:	c3                   	ret    

00004040 <dup>:
SYSCALL(dup)
    4040:	b8 0a 00 00 00       	mov    $0xa,%eax
    4045:	cd 40                	int    $0x40
    4047:	c3                   	ret    

00004048 <getpid>:
SYSCALL(getpid)
    4048:	b8 0b 00 00 00       	mov    $0xb,%eax
    404d:	cd 40                	int    $0x40
    404f:	c3                   	ret    

00004050 <sbrk>:
SYSCALL(sbrk)
    4050:	b8 0c 00 00 00       	mov    $0xc,%eax
    4055:	cd 40                	int    $0x40
    4057:	c3                   	ret    

00004058 <sleep>:
SYSCALL(sleep)
    4058:	b8 0d 00 00 00       	mov    $0xd,%eax
    405d:	cd 40                	int    $0x40
    405f:	c3                   	ret    

00004060 <uptime>:
SYSCALL(uptime)
    4060:	b8 0e 00 00 00       	mov    $0xe,%eax
    4065:	cd 40                	int    $0x40
    4067:	c3                   	ret    

00004068 <getticks>:
SYSCALL(getticks)
    4068:	b8 16 00 00 00       	mov    $0x16,%eax
    406d:	cd 40                	int    $0x40
    406f:	c3                   	ret    

00004070 <ccreate>:
SYSCALL(ccreate)
    4070:	b8 17 00 00 00       	mov    $0x17,%eax
    4075:	cd 40                	int    $0x40
    4077:	c3                   	ret    

00004078 <cstart>:
SYSCALL(cstart)
    4078:	b8 19 00 00 00       	mov    $0x19,%eax
    407d:	cd 40                	int    $0x40
    407f:	c3                   	ret    

00004080 <cstop>:
SYSCALL(cstop)
    4080:	b8 18 00 00 00       	mov    $0x18,%eax
    4085:	cd 40                	int    $0x40
    4087:	c3                   	ret    

00004088 <cpause>:
SYSCALL(cpause)
    4088:	b8 1b 00 00 00       	mov    $0x1b,%eax
    408d:	cd 40                	int    $0x40
    408f:	c3                   	ret    

00004090 <cinfo>:
SYSCALL(cinfo)
    4090:	b8 1a 00 00 00       	mov    $0x1a,%eax
    4095:	cd 40                	int    $0x40
    4097:	c3                   	ret    

00004098 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
    4098:	55                   	push   %ebp
    4099:	89 e5                	mov    %esp,%ebp
    409b:	83 ec 18             	sub    $0x18,%esp
    409e:	8b 45 0c             	mov    0xc(%ebp),%eax
    40a1:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
    40a4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
    40ab:	00 
    40ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
    40af:	89 44 24 04          	mov    %eax,0x4(%esp)
    40b3:	8b 45 08             	mov    0x8(%ebp),%eax
    40b6:	89 04 24             	mov    %eax,(%esp)
    40b9:	e8 2a ff ff ff       	call   3fe8 <write>
}
    40be:	c9                   	leave  
    40bf:	c3                   	ret    

000040c0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    40c0:	55                   	push   %ebp
    40c1:	89 e5                	mov    %esp,%ebp
    40c3:	56                   	push   %esi
    40c4:	53                   	push   %ebx
    40c5:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
    40c8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
    40cf:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
    40d3:	74 17                	je     40ec <printint+0x2c>
    40d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
    40d9:	79 11                	jns    40ec <printint+0x2c>
    neg = 1;
    40db:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
    40e2:	8b 45 0c             	mov    0xc(%ebp),%eax
    40e5:	f7 d8                	neg    %eax
    40e7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    40ea:	eb 06                	jmp    40f2 <printint+0x32>
  } else {
    x = xx;
    40ec:	8b 45 0c             	mov    0xc(%ebp),%eax
    40ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
    40f2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
    40f9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
    40fc:	8d 41 01             	lea    0x1(%ecx),%eax
    40ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
    4102:	8b 5d 10             	mov    0x10(%ebp),%ebx
    4105:	8b 45 ec             	mov    -0x14(%ebp),%eax
    4108:	ba 00 00 00 00       	mov    $0x0,%edx
    410d:	f7 f3                	div    %ebx
    410f:	89 d0                	mov    %edx,%eax
    4111:	8a 80 c4 64 00 00    	mov    0x64c4(%eax),%al
    4117:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
    411b:	8b 75 10             	mov    0x10(%ebp),%esi
    411e:	8b 45 ec             	mov    -0x14(%ebp),%eax
    4121:	ba 00 00 00 00       	mov    $0x0,%edx
    4126:	f7 f6                	div    %esi
    4128:	89 45 ec             	mov    %eax,-0x14(%ebp)
    412b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    412f:	75 c8                	jne    40f9 <printint+0x39>
  if(neg)
    4131:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    4135:	74 10                	je     4147 <printint+0x87>
    buf[i++] = '-';
    4137:	8b 45 f4             	mov    -0xc(%ebp),%eax
    413a:	8d 50 01             	lea    0x1(%eax),%edx
    413d:	89 55 f4             	mov    %edx,-0xc(%ebp)
    4140:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
    4145:	eb 1e                	jmp    4165 <printint+0xa5>
    4147:	eb 1c                	jmp    4165 <printint+0xa5>
    putc(fd, buf[i]);
    4149:	8d 55 dc             	lea    -0x24(%ebp),%edx
    414c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    414f:	01 d0                	add    %edx,%eax
    4151:	8a 00                	mov    (%eax),%al
    4153:	0f be c0             	movsbl %al,%eax
    4156:	89 44 24 04          	mov    %eax,0x4(%esp)
    415a:	8b 45 08             	mov    0x8(%ebp),%eax
    415d:	89 04 24             	mov    %eax,(%esp)
    4160:	e8 33 ff ff ff       	call   4098 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
    4165:	ff 4d f4             	decl   -0xc(%ebp)
    4168:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    416c:	79 db                	jns    4149 <printint+0x89>
    putc(fd, buf[i]);
}
    416e:	83 c4 30             	add    $0x30,%esp
    4171:	5b                   	pop    %ebx
    4172:	5e                   	pop    %esi
    4173:	5d                   	pop    %ebp
    4174:	c3                   	ret    

00004175 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
    4175:	55                   	push   %ebp
    4176:	89 e5                	mov    %esp,%ebp
    4178:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
    417b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
    4182:	8d 45 0c             	lea    0xc(%ebp),%eax
    4185:	83 c0 04             	add    $0x4,%eax
    4188:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
    418b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    4192:	e9 77 01 00 00       	jmp    430e <printf+0x199>
    c = fmt[i] & 0xff;
    4197:	8b 55 0c             	mov    0xc(%ebp),%edx
    419a:	8b 45 f0             	mov    -0x10(%ebp),%eax
    419d:	01 d0                	add    %edx,%eax
    419f:	8a 00                	mov    (%eax),%al
    41a1:	0f be c0             	movsbl %al,%eax
    41a4:	25 ff 00 00 00       	and    $0xff,%eax
    41a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
    41ac:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
    41b0:	75 2c                	jne    41de <printf+0x69>
      if(c == '%'){
    41b2:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    41b6:	75 0c                	jne    41c4 <printf+0x4f>
        state = '%';
    41b8:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
    41bf:	e9 47 01 00 00       	jmp    430b <printf+0x196>
      } else {
        putc(fd, c);
    41c4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    41c7:	0f be c0             	movsbl %al,%eax
    41ca:	89 44 24 04          	mov    %eax,0x4(%esp)
    41ce:	8b 45 08             	mov    0x8(%ebp),%eax
    41d1:	89 04 24             	mov    %eax,(%esp)
    41d4:	e8 bf fe ff ff       	call   4098 <putc>
    41d9:	e9 2d 01 00 00       	jmp    430b <printf+0x196>
      }
    } else if(state == '%'){
    41de:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
    41e2:	0f 85 23 01 00 00    	jne    430b <printf+0x196>
      if(c == 'd'){
    41e8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
    41ec:	75 2d                	jne    421b <printf+0xa6>
        printint(fd, *ap, 10, 1);
    41ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
    41f1:	8b 00                	mov    (%eax),%eax
    41f3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
    41fa:	00 
    41fb:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
    4202:	00 
    4203:	89 44 24 04          	mov    %eax,0x4(%esp)
    4207:	8b 45 08             	mov    0x8(%ebp),%eax
    420a:	89 04 24             	mov    %eax,(%esp)
    420d:	e8 ae fe ff ff       	call   40c0 <printint>
        ap++;
    4212:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    4216:	e9 e9 00 00 00       	jmp    4304 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
    421b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
    421f:	74 06                	je     4227 <printf+0xb2>
    4221:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
    4225:	75 2d                	jne    4254 <printf+0xdf>
        printint(fd, *ap, 16, 0);
    4227:	8b 45 e8             	mov    -0x18(%ebp),%eax
    422a:	8b 00                	mov    (%eax),%eax
    422c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
    4233:	00 
    4234:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
    423b:	00 
    423c:	89 44 24 04          	mov    %eax,0x4(%esp)
    4240:	8b 45 08             	mov    0x8(%ebp),%eax
    4243:	89 04 24             	mov    %eax,(%esp)
    4246:	e8 75 fe ff ff       	call   40c0 <printint>
        ap++;
    424b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    424f:	e9 b0 00 00 00       	jmp    4304 <printf+0x18f>
      } else if(c == 's'){
    4254:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
    4258:	75 42                	jne    429c <printf+0x127>
        s = (char*)*ap;
    425a:	8b 45 e8             	mov    -0x18(%ebp),%eax
    425d:	8b 00                	mov    (%eax),%eax
    425f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
    4262:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
    4266:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    426a:	75 09                	jne    4275 <printf+0x100>
          s = "(null)";
    426c:	c7 45 f4 76 5d 00 00 	movl   $0x5d76,-0xc(%ebp)
        while(*s != 0){
    4273:	eb 1c                	jmp    4291 <printf+0x11c>
    4275:	eb 1a                	jmp    4291 <printf+0x11c>
          putc(fd, *s);
    4277:	8b 45 f4             	mov    -0xc(%ebp),%eax
    427a:	8a 00                	mov    (%eax),%al
    427c:	0f be c0             	movsbl %al,%eax
    427f:	89 44 24 04          	mov    %eax,0x4(%esp)
    4283:	8b 45 08             	mov    0x8(%ebp),%eax
    4286:	89 04 24             	mov    %eax,(%esp)
    4289:	e8 0a fe ff ff       	call   4098 <putc>
          s++;
    428e:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
    4291:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4294:	8a 00                	mov    (%eax),%al
    4296:	84 c0                	test   %al,%al
    4298:	75 dd                	jne    4277 <printf+0x102>
    429a:	eb 68                	jmp    4304 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    429c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
    42a0:	75 1d                	jne    42bf <printf+0x14a>
        putc(fd, *ap);
    42a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
    42a5:	8b 00                	mov    (%eax),%eax
    42a7:	0f be c0             	movsbl %al,%eax
    42aa:	89 44 24 04          	mov    %eax,0x4(%esp)
    42ae:	8b 45 08             	mov    0x8(%ebp),%eax
    42b1:	89 04 24             	mov    %eax,(%esp)
    42b4:	e8 df fd ff ff       	call   4098 <putc>
        ap++;
    42b9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
    42bd:	eb 45                	jmp    4304 <printf+0x18f>
      } else if(c == '%'){
    42bf:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
    42c3:	75 17                	jne    42dc <printf+0x167>
        putc(fd, c);
    42c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    42c8:	0f be c0             	movsbl %al,%eax
    42cb:	89 44 24 04          	mov    %eax,0x4(%esp)
    42cf:	8b 45 08             	mov    0x8(%ebp),%eax
    42d2:	89 04 24             	mov    %eax,(%esp)
    42d5:	e8 be fd ff ff       	call   4098 <putc>
    42da:	eb 28                	jmp    4304 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    42dc:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
    42e3:	00 
    42e4:	8b 45 08             	mov    0x8(%ebp),%eax
    42e7:	89 04 24             	mov    %eax,(%esp)
    42ea:	e8 a9 fd ff ff       	call   4098 <putc>
        putc(fd, c);
    42ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    42f2:	0f be c0             	movsbl %al,%eax
    42f5:	89 44 24 04          	mov    %eax,0x4(%esp)
    42f9:	8b 45 08             	mov    0x8(%ebp),%eax
    42fc:	89 04 24             	mov    %eax,(%esp)
    42ff:	e8 94 fd ff ff       	call   4098 <putc>
      }
      state = 0;
    4304:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
    430b:	ff 45 f0             	incl   -0x10(%ebp)
    430e:	8b 55 0c             	mov    0xc(%ebp),%edx
    4311:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4314:	01 d0                	add    %edx,%eax
    4316:	8a 00                	mov    (%eax),%al
    4318:	84 c0                	test   %al,%al
    431a:	0f 85 77 fe ff ff    	jne    4197 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
    4320:	c9                   	leave  
    4321:	c3                   	ret    
    4322:	90                   	nop
    4323:	90                   	nop

00004324 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    4324:	55                   	push   %ebp
    4325:	89 e5                	mov    %esp,%ebp
    4327:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
    432a:	8b 45 08             	mov    0x8(%ebp),%eax
    432d:	83 e8 08             	sub    $0x8,%eax
    4330:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    4333:	a1 68 65 00 00       	mov    0x6568,%eax
    4338:	89 45 fc             	mov    %eax,-0x4(%ebp)
    433b:	eb 24                	jmp    4361 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    433d:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4340:	8b 00                	mov    (%eax),%eax
    4342:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    4345:	77 12                	ja     4359 <free+0x35>
    4347:	8b 45 f8             	mov    -0x8(%ebp),%eax
    434a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    434d:	77 24                	ja     4373 <free+0x4f>
    434f:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4352:	8b 00                	mov    (%eax),%eax
    4354:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    4357:	77 1a                	ja     4373 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    4359:	8b 45 fc             	mov    -0x4(%ebp),%eax
    435c:	8b 00                	mov    (%eax),%eax
    435e:	89 45 fc             	mov    %eax,-0x4(%ebp)
    4361:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4364:	3b 45 fc             	cmp    -0x4(%ebp),%eax
    4367:	76 d4                	jbe    433d <free+0x19>
    4369:	8b 45 fc             	mov    -0x4(%ebp),%eax
    436c:	8b 00                	mov    (%eax),%eax
    436e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    4371:	76 ca                	jbe    433d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    4373:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4376:	8b 40 04             	mov    0x4(%eax),%eax
    4379:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    4380:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4383:	01 c2                	add    %eax,%edx
    4385:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4388:	8b 00                	mov    (%eax),%eax
    438a:	39 c2                	cmp    %eax,%edx
    438c:	75 24                	jne    43b2 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
    438e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    4391:	8b 50 04             	mov    0x4(%eax),%edx
    4394:	8b 45 fc             	mov    -0x4(%ebp),%eax
    4397:	8b 00                	mov    (%eax),%eax
    4399:	8b 40 04             	mov    0x4(%eax),%eax
    439c:	01 c2                	add    %eax,%edx
    439e:	8b 45 f8             	mov    -0x8(%ebp),%eax
    43a1:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
    43a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
    43a7:	8b 00                	mov    (%eax),%eax
    43a9:	8b 10                	mov    (%eax),%edx
    43ab:	8b 45 f8             	mov    -0x8(%ebp),%eax
    43ae:	89 10                	mov    %edx,(%eax)
    43b0:	eb 0a                	jmp    43bc <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
    43b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
    43b5:	8b 10                	mov    (%eax),%edx
    43b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    43ba:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
    43bc:	8b 45 fc             	mov    -0x4(%ebp),%eax
    43bf:	8b 40 04             	mov    0x4(%eax),%eax
    43c2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
    43c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
    43cc:	01 d0                	add    %edx,%eax
    43ce:	3b 45 f8             	cmp    -0x8(%ebp),%eax
    43d1:	75 20                	jne    43f3 <free+0xcf>
    p->s.size += bp->s.size;
    43d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    43d6:	8b 50 04             	mov    0x4(%eax),%edx
    43d9:	8b 45 f8             	mov    -0x8(%ebp),%eax
    43dc:	8b 40 04             	mov    0x4(%eax),%eax
    43df:	01 c2                	add    %eax,%edx
    43e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
    43e4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
    43e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
    43ea:	8b 10                	mov    (%eax),%edx
    43ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
    43ef:	89 10                	mov    %edx,(%eax)
    43f1:	eb 08                	jmp    43fb <free+0xd7>
  } else
    p->s.ptr = bp;
    43f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
    43f6:	8b 55 f8             	mov    -0x8(%ebp),%edx
    43f9:	89 10                	mov    %edx,(%eax)
  freep = p;
    43fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
    43fe:	a3 68 65 00 00       	mov    %eax,0x6568
}
    4403:	c9                   	leave  
    4404:	c3                   	ret    

00004405 <morecore>:

static Header*
morecore(uint nu)
{
    4405:	55                   	push   %ebp
    4406:	89 e5                	mov    %esp,%ebp
    4408:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
    440b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
    4412:	77 07                	ja     441b <morecore+0x16>
    nu = 4096;
    4414:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
    441b:	8b 45 08             	mov    0x8(%ebp),%eax
    441e:	c1 e0 03             	shl    $0x3,%eax
    4421:	89 04 24             	mov    %eax,(%esp)
    4424:	e8 27 fc ff ff       	call   4050 <sbrk>
    4429:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
    442c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
    4430:	75 07                	jne    4439 <morecore+0x34>
    return 0;
    4432:	b8 00 00 00 00       	mov    $0x0,%eax
    4437:	eb 22                	jmp    445b <morecore+0x56>
  hp = (Header*)p;
    4439:	8b 45 f4             	mov    -0xc(%ebp),%eax
    443c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
    443f:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4442:	8b 55 08             	mov    0x8(%ebp),%edx
    4445:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
    4448:	8b 45 f0             	mov    -0x10(%ebp),%eax
    444b:	83 c0 08             	add    $0x8,%eax
    444e:	89 04 24             	mov    %eax,(%esp)
    4451:	e8 ce fe ff ff       	call   4324 <free>
  return freep;
    4456:	a1 68 65 00 00       	mov    0x6568,%eax
}
    445b:	c9                   	leave  
    445c:	c3                   	ret    

0000445d <malloc>:

void*
malloc(uint nbytes)
{
    445d:	55                   	push   %ebp
    445e:	89 e5                	mov    %esp,%ebp
    4460:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    4463:	8b 45 08             	mov    0x8(%ebp),%eax
    4466:	83 c0 07             	add    $0x7,%eax
    4469:	c1 e8 03             	shr    $0x3,%eax
    446c:	40                   	inc    %eax
    446d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
    4470:	a1 68 65 00 00       	mov    0x6568,%eax
    4475:	89 45 f0             	mov    %eax,-0x10(%ebp)
    4478:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
    447c:	75 23                	jne    44a1 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
    447e:	c7 45 f0 60 65 00 00 	movl   $0x6560,-0x10(%ebp)
    4485:	8b 45 f0             	mov    -0x10(%ebp),%eax
    4488:	a3 68 65 00 00       	mov    %eax,0x6568
    448d:	a1 68 65 00 00       	mov    0x6568,%eax
    4492:	a3 60 65 00 00       	mov    %eax,0x6560
    base.s.size = 0;
    4497:	c7 05 64 65 00 00 00 	movl   $0x0,0x6564
    449e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    44a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    44a4:	8b 00                	mov    (%eax),%eax
    44a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
    44a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    44ac:	8b 40 04             	mov    0x4(%eax),%eax
    44af:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    44b2:	72 4d                	jb     4501 <malloc+0xa4>
      if(p->s.size == nunits)
    44b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
    44b7:	8b 40 04             	mov    0x4(%eax),%eax
    44ba:	3b 45 ec             	cmp    -0x14(%ebp),%eax
    44bd:	75 0c                	jne    44cb <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
    44bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
    44c2:	8b 10                	mov    (%eax),%edx
    44c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
    44c7:	89 10                	mov    %edx,(%eax)
    44c9:	eb 26                	jmp    44f1 <malloc+0x94>
      else {
        p->s.size -= nunits;
    44cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
    44ce:	8b 40 04             	mov    0x4(%eax),%eax
    44d1:	2b 45 ec             	sub    -0x14(%ebp),%eax
    44d4:	89 c2                	mov    %eax,%edx
    44d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    44d9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
    44dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    44df:	8b 40 04             	mov    0x4(%eax),%eax
    44e2:	c1 e0 03             	shl    $0x3,%eax
    44e5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
    44e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
    44eb:	8b 55 ec             	mov    -0x14(%ebp),%edx
    44ee:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
    44f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
    44f4:	a3 68 65 00 00       	mov    %eax,0x6568
      return (void*)(p + 1);
    44f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
    44fc:	83 c0 08             	add    $0x8,%eax
    44ff:	eb 38                	jmp    4539 <malloc+0xdc>
    }
    if(p == freep)
    4501:	a1 68 65 00 00       	mov    0x6568,%eax
    4506:	39 45 f4             	cmp    %eax,-0xc(%ebp)
    4509:	75 1b                	jne    4526 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
    450b:	8b 45 ec             	mov    -0x14(%ebp),%eax
    450e:	89 04 24             	mov    %eax,(%esp)
    4511:	e8 ef fe ff ff       	call   4405 <morecore>
    4516:	89 45 f4             	mov    %eax,-0xc(%ebp)
    4519:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
    451d:	75 07                	jne    4526 <malloc+0xc9>
        return 0;
    451f:	b8 00 00 00 00       	mov    $0x0,%eax
    4524:	eb 13                	jmp    4539 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    4526:	8b 45 f4             	mov    -0xc(%ebp),%eax
    4529:	89 45 f0             	mov    %eax,-0x10(%ebp)
    452c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    452f:	8b 00                	mov    (%eax),%eax
    4531:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
    4534:	e9 70 ff ff ff       	jmp    44a9 <malloc+0x4c>
}
    4539:	c9                   	leave  
    453a:	c3                   	ret    
