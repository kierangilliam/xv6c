
_ctool:     file format elf32-i386


Disassembly of section .text:

00000000 <usage>:
#define CONT_MAX_PROC 8
#define CONT_MAX_DISK 1024

void 
usage(char* usage) 
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
    printf(1, "usage: ctool %s\n", usage);
   6:	8b 45 08             	mov    0x8(%ebp),%eax
   9:	89 44 24 08          	mov    %eax,0x8(%esp)
   d:	c7 44 24 04 d4 0b 00 	movl   $0xbd4,0x4(%esp)
  14:	00 
  15:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1c:	e8 ec 07 00 00       	call   80d <printf>
    exit();
  21:	e8 3a 06 00 00       	call   660 <exit>

00000026 <max>:
}

int
max(int a, int b)
{
  26:	55                   	push   %ebp
  27:	89 e5                	mov    %esp,%ebp
  if (a > b)
  29:	8b 45 08             	mov    0x8(%ebp),%eax
  2c:	3b 45 0c             	cmp    0xc(%ebp),%eax
  2f:	7e 05                	jle    36 <max+0x10>
    return a;
  31:	8b 45 08             	mov    0x8(%ebp),%eax
  34:	eb 03                	jmp    39 <max+0x13>
  else
    return b;
  36:	8b 45 0c             	mov    0xc(%ebp),%eax
}
  39:	5d                   	pop    %ebp
  3a:	c3                   	ret    

0000003b <create>:
// ctool create ctest1 -p 4 sh ps cat echo
// folder/ container name, what to copy into folder
// mkdir, cp file 1, cp file n  
void
create(int argc, char *argv[])
{
  3b:	55                   	push   %ebp
  3c:	89 e5                	mov    %esp,%ebp
  3e:	81 ec c8 00 00 00    	sub    $0xc8,%esp
  char *progv[32];
  int i, last_flag, progc, 
  mproc = CONT_MAX_PROC, 
  44:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
  msz = CONT_MAX_MEM, 
  4b:	c7 45 e8 00 04 00 00 	movl   $0x400,-0x18(%ebp)
  mdsk = CONT_MAX_DISK;  
  52:	c7 45 e4 00 04 00 00 	movl   $0x400,-0x1c(%ebp)

  if (argc < 4)
  59:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
  5d:	7f 0c                	jg     6b <create+0x30>
    usage("create <name> [-p <max_processes>] [-m <max_memory>] [-d <max_disk>] prog [prog2.. ]");
  5f:	c7 04 24 e8 0b 00 00 	movl   $0xbe8,(%esp)
  66:	e8 95 ff ff ff       	call   0 <usage>

  last_flag = 2; // No flags
  6b:	c7 45 f0 02 00 00 00 	movl   $0x2,-0x10(%ebp)

  for (i = 0; i < argc; i++) {
  72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  79:	e9 0b 01 00 00       	jmp    189 <create+0x14e>
    if (strcmp(argv[i], "-p") == 0) {
  7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  81:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  88:	8b 45 0c             	mov    0xc(%ebp),%eax
  8b:	01 d0                	add    %edx,%eax
  8d:	8b 00                	mov    (%eax),%eax
  8f:	c7 44 24 04 3d 0c 00 	movl   $0xc3d,0x4(%esp)
  96:	00 
  97:	89 04 24             	mov    %eax,(%esp)
  9a:	e8 c0 03 00 00       	call   45f <strcmp>
  9f:	85 c0                	test   %eax,%eax
  a1:	75 33                	jne    d6 <create+0x9b>
      last_flag = max(last_flag, i + 1);
  a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  a6:	40                   	inc    %eax
  a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  ae:	89 04 24             	mov    %eax,(%esp)
  b1:	e8 70 ff ff ff       	call   26 <max>
  b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
      mproc = atoi(argv[i + 1]);
  b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  bc:	40                   	inc    %eax
  bd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  c7:	01 d0                	add    %edx,%eax
  c9:	8b 00                	mov    (%eax),%eax
  cb:	89 04 24             	mov    %eax,(%esp)
  ce:	e8 fc 04 00 00       	call   5cf <atoi>
  d3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    }
    if (strcmp(argv[i], "-m") == 0) {
  d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  d9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  e3:	01 d0                	add    %edx,%eax
  e5:	8b 00                	mov    (%eax),%eax
  e7:	c7 44 24 04 40 0c 00 	movl   $0xc40,0x4(%esp)
  ee:	00 
  ef:	89 04 24             	mov    %eax,(%esp)
  f2:	e8 68 03 00 00       	call   45f <strcmp>
  f7:	85 c0                	test   %eax,%eax
  f9:	75 33                	jne    12e <create+0xf3>
      last_flag = max(last_flag, i + 1);
  fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  fe:	40                   	inc    %eax
  ff:	89 44 24 04          	mov    %eax,0x4(%esp)
 103:	8b 45 f0             	mov    -0x10(%ebp),%eax
 106:	89 04 24             	mov    %eax,(%esp)
 109:	e8 18 ff ff ff       	call   26 <max>
 10e:	89 45 f0             	mov    %eax,-0x10(%ebp)
      msz = atoi(argv[i + 1]);
 111:	8b 45 f4             	mov    -0xc(%ebp),%eax
 114:	40                   	inc    %eax
 115:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 11c:	8b 45 0c             	mov    0xc(%ebp),%eax
 11f:	01 d0                	add    %edx,%eax
 121:	8b 00                	mov    (%eax),%eax
 123:	89 04 24             	mov    %eax,(%esp)
 126:	e8 a4 04 00 00       	call   5cf <atoi>
 12b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    }
    if (strcmp(argv[i], "-d") == 0) {
 12e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 131:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 138:	8b 45 0c             	mov    0xc(%ebp),%eax
 13b:	01 d0                	add    %edx,%eax
 13d:	8b 00                	mov    (%eax),%eax
 13f:	c7 44 24 04 43 0c 00 	movl   $0xc43,0x4(%esp)
 146:	00 
 147:	89 04 24             	mov    %eax,(%esp)
 14a:	e8 10 03 00 00       	call   45f <strcmp>
 14f:	85 c0                	test   %eax,%eax
 151:	75 33                	jne    186 <create+0x14b>
      last_flag = max(last_flag, i + 1);
 153:	8b 45 f4             	mov    -0xc(%ebp),%eax
 156:	40                   	inc    %eax
 157:	89 44 24 04          	mov    %eax,0x4(%esp)
 15b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 15e:	89 04 24             	mov    %eax,(%esp)
 161:	e8 c0 fe ff ff       	call   26 <max>
 166:	89 45 f0             	mov    %eax,-0x10(%ebp)
      mdsk = atoi(argv[i + 1]);
 169:	8b 45 f4             	mov    -0xc(%ebp),%eax
 16c:	40                   	inc    %eax
 16d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 174:	8b 45 0c             	mov    0xc(%ebp),%eax
 177:	01 d0                	add    %edx,%eax
 179:	8b 00                	mov    (%eax),%eax
 17b:	89 04 24             	mov    %eax,(%esp)
 17e:	e8 4c 04 00 00       	call   5cf <atoi>
 183:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if (argc < 4)
    usage("create <name> [-p <max_processes>] [-m <max_memory>] [-d <max_disk>] prog [prog2.. ]");

  last_flag = 2; // No flags

  for (i = 0; i < argc; i++) {
 186:	ff 45 f4             	incl   -0xc(%ebp)
 189:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18c:	3b 45 08             	cmp    0x8(%ebp),%eax
 18f:	0f 8c e9 fe ff ff    	jl     7e <create+0x43>
      last_flag = max(last_flag, i + 1);
      mdsk = atoi(argv[i + 1]);
    }
  }

  printf(1, "argc: %d, last_flag: %d\n", argc, last_flag);
 195:	8b 45 f0             	mov    -0x10(%ebp),%eax
 198:	89 44 24 0c          	mov    %eax,0xc(%esp)
 19c:	8b 45 08             	mov    0x8(%ebp),%eax
 19f:	89 44 24 08          	mov    %eax,0x8(%esp)
 1a3:	c7 44 24 04 46 0c 00 	movl   $0xc46,0x4(%esp)
 1aa:	00 
 1ab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1b2:	e8 56 06 00 00       	call   80d <printf>
  progc = argc - last_flag - 1;
 1b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 1ba:	8b 55 08             	mov    0x8(%ebp),%edx
 1bd:	29 c2                	sub    %eax,%edx
 1bf:	89 d0                	mov    %edx,%eax
 1c1:	48                   	dec    %eax
 1c2:	89 45 dc             	mov    %eax,-0x24(%ebp)

  int k;

  //progv = malloc(sizeof(char*) * progc);

  for (i = last_flag + 1, k = 0; i < argc; i++, k++) {
 1c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 1c8:	40                   	inc    %eax
 1c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
 1cc:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
 1d3:	e9 bb 00 00 00       	jmp    293 <create+0x258>
    printf(1, "%s", argv[i]);
 1d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1db:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 1e2:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e5:	01 d0                	add    %edx,%eax
 1e7:	8b 00                	mov    (%eax),%eax
 1e9:	89 44 24 08          	mov    %eax,0x8(%esp)
 1ed:	c7 44 24 04 5f 0c 00 	movl   $0xc5f,0x4(%esp)
 1f4:	00 
 1f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1fc:	e8 0c 06 00 00       	call   80d <printf>
    
    progv[k] = malloc(sizeof(argv[i]));
 201:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
 208:	e8 e8 08 00 00       	call   af5 <malloc>
 20d:	8b 55 e0             	mov    -0x20(%ebp),%edx
 210:	89 84 95 5c ff ff ff 	mov    %eax,-0xa4(%ebp,%edx,4)
    memmove(progv[k], argv[i], sizeof(argv[i]));
 217:	8b 45 f4             	mov    -0xc(%ebp),%eax
 21a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 221:	8b 45 0c             	mov    0xc(%ebp),%eax
 224:	01 d0                	add    %edx,%eax
 226:	8b 10                	mov    (%eax),%edx
 228:	8b 45 e0             	mov    -0x20(%ebp),%eax
 22b:	8b 84 85 5c ff ff ff 	mov    -0xa4(%ebp,%eax,4),%eax
 232:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
 239:	00 
 23a:	89 54 24 04          	mov    %edx,0x4(%esp)
 23e:	89 04 24             	mov    %eax,(%esp)
 241:	e8 d3 03 00 00       	call   619 <memmove>
    memmove(progv[k] + sizeof(argv[i]), "\0", 1);
 246:	8b 45 e0             	mov    -0x20(%ebp),%eax
 249:	8b 84 85 5c ff ff ff 	mov    -0xa4(%ebp,%eax,4),%eax
 250:	83 c0 04             	add    $0x4,%eax
 253:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 25a:	00 
 25b:	c7 44 24 04 62 0c 00 	movl   $0xc62,0x4(%esp)
 262:	00 
 263:	89 04 24             	mov    %eax,(%esp)
 266:	e8 ae 03 00 00       	call   619 <memmove>
    printf(1, "\t%s\n", progv[k]);
 26b:	8b 45 e0             	mov    -0x20(%ebp),%eax
 26e:	8b 84 85 5c ff ff ff 	mov    -0xa4(%ebp,%eax,4),%eax
 275:	89 44 24 08          	mov    %eax,0x8(%esp)
 279:	c7 44 24 04 64 0c 00 	movl   $0xc64,0x4(%esp)
 280:	00 
 281:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 288:	e8 80 05 00 00       	call   80d <printf>

  int k;

  //progv = malloc(sizeof(char*) * progc);

  for (i = last_flag + 1, k = 0; i < argc; i++, k++) {
 28d:	ff 45 f4             	incl   -0xc(%ebp)
 290:	ff 45 e0             	incl   -0x20(%ebp)
 293:	8b 45 f4             	mov    -0xc(%ebp),%eax
 296:	3b 45 08             	cmp    0x8(%ebp),%eax
 299:	0f 8c 39 ff ff ff    	jl     1d8 <create+0x19d>
    memmove(progv[k], argv[i], sizeof(argv[i]));
    memmove(progv[k] + sizeof(argv[i]), "\0", 1);
    printf(1, "\t%s\n", progv[k]);
  }

  printf(1, "name: %s\nmproc: %d\nmsz: %d\nmdsk: %d\nprogc: %d\n", argv[2], mproc, msz, mdsk, progc);
 29f:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a2:	83 c0 08             	add    $0x8,%eax
 2a5:	8b 00                	mov    (%eax),%eax
 2a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
 2aa:	89 54 24 18          	mov    %edx,0x18(%esp)
 2ae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 2b1:	89 54 24 14          	mov    %edx,0x14(%esp)
 2b5:	8b 55 e8             	mov    -0x18(%ebp),%edx
 2b8:	89 54 24 10          	mov    %edx,0x10(%esp)
 2bc:	8b 55 ec             	mov    -0x14(%ebp),%edx
 2bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
 2c3:	89 44 24 08          	mov    %eax,0x8(%esp)
 2c7:	c7 44 24 04 6c 0c 00 	movl   $0xc6c,0x4(%esp)
 2ce:	00 
 2cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2d6:	e8 32 05 00 00       	call   80d <printf>

  if (ccreate(argv[2], progv, progc, mproc, msz, mdsk) == 1) {
 2db:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
 2de:	8b 55 e8             	mov    -0x18(%ebp),%edx
 2e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 2e4:	83 c0 08             	add    $0x8,%eax
 2e7:	8b 00                	mov    (%eax),%eax
 2e9:	89 4c 24 14          	mov    %ecx,0x14(%esp)
 2ed:	89 54 24 10          	mov    %edx,0x10(%esp)
 2f1:	8b 55 ec             	mov    -0x14(%ebp),%edx
 2f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
 2f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
 2fb:	89 54 24 08          	mov    %edx,0x8(%esp)
 2ff:	8d 95 5c ff ff ff    	lea    -0xa4(%ebp),%edx
 305:	89 54 24 04          	mov    %edx,0x4(%esp)
 309:	89 04 24             	mov    %eax,(%esp)
 30c:	e8 f7 03 00 00       	call   708 <ccreate>
 311:	83 f8 01             	cmp    $0x1,%eax
 314:	75 22                	jne    338 <create+0x2fd>
    printf(1, "Created container %s\n", argv[2]); 
 316:	8b 45 0c             	mov    0xc(%ebp),%eax
 319:	83 c0 08             	add    $0x8,%eax
 31c:	8b 00                	mov    (%eax),%eax
 31e:	89 44 24 08          	mov    %eax,0x8(%esp)
 322:	c7 44 24 04 9b 0c 00 	movl   $0xc9b,0x4(%esp)
 329:	00 
 32a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 331:	e8 d7 04 00 00       	call   80d <printf>
 336:	eb 20                	jmp    358 <create+0x31d>
  } else {
    printf(1, "Failed to create container %s\n", argv[2]); 
 338:	8b 45 0c             	mov    0xc(%ebp),%eax
 33b:	83 c0 08             	add    $0x8,%eax
 33e:	8b 00                	mov    (%eax),%eax
 340:	89 44 24 08          	mov    %eax,0x8(%esp)
 344:	c7 44 24 04 b4 0c 00 	movl   $0xcb4,0x4(%esp)
 34b:	00 
 34c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 353:	e8 b5 04 00 00       	call   80d <printf>
  }
}
 358:	c9                   	leave  
 359:	c3                   	ret    

0000035a <start>:

void
start(int argc, char *argv[])
{
 35a:	55                   	push   %ebp
 35b:	89 e5                	mov    %esp,%ebp
  // ctool start vc0 c1 sh
                  // (optional) max proc, max mb of memory, max disk space   
  // ctool start vc0 c1 sh 8 10 5  
  // ctool start <name> prog arg1 [arg2 ...]
}
 35d:	5d                   	pop    %ebp
 35e:	c3                   	ret    

0000035f <pause>:

void
pause()
{
 35f:	55                   	push   %ebp
 360:	89 e5                	mov    %esp,%ebp
  
}
 362:	5d                   	pop    %ebp
 363:	c3                   	ret    

00000364 <resume>:

void
resume()
{
 364:	55                   	push   %ebp
 365:	89 e5                	mov    %esp,%ebp
  
}
 367:	5d                   	pop    %ebp
 368:	c3                   	ret    

00000369 <stop>:

void
stop()
{
 369:	55                   	push   %ebp
 36a:	89 e5                	mov    %esp,%ebp
  
}
 36c:	5d                   	pop    %ebp
 36d:	c3                   	ret    

0000036e <info>:

void
info()
{
 36e:	55                   	push   %ebp
 36f:	89 e5                	mov    %esp,%ebp
  
}
 371:	5d                   	pop    %ebp
 372:	c3                   	ret    

00000373 <main>:

int
main(int argc, char *argv[])
{
 373:	55                   	push   %ebp
 374:	89 e5                	mov    %esp,%ebp
 376:	83 e4 f0             	and    $0xfffffff0,%esp
 379:	83 ec 10             	sub    $0x10,%esp

  if (argc < 3) {
 37c:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 380:	7f 11                	jg     393 <main+0x20>
    usage("<tool> <cmd> [<arg> ...]");
 382:	c7 04 24 d3 0c 00 00 	movl   $0xcd3,(%esp)
 389:	e8 72 fc ff ff       	call   0 <usage>
    exit();
 38e:	e8 cd 02 00 00       	call   660 <exit>
  }

  if (strcmp(argv[1], "create") == 0)
 393:	8b 45 0c             	mov    0xc(%ebp),%eax
 396:	83 c0 04             	add    $0x4,%eax
 399:	8b 00                	mov    (%eax),%eax
 39b:	c7 44 24 04 ec 0c 00 	movl   $0xcec,0x4(%esp)
 3a2:	00 
 3a3:	89 04 24             	mov    %eax,(%esp)
 3a6:	e8 b4 00 00 00       	call   45f <strcmp>
 3ab:	85 c0                	test   %eax,%eax
 3ad:	75 14                	jne    3c3 <main+0x50>
    create(argc, argv);
 3af:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b2:	89 44 24 04          	mov    %eax,0x4(%esp)
 3b6:	8b 45 08             	mov    0x8(%ebp),%eax
 3b9:	89 04 24             	mov    %eax,(%esp)
 3bc:	e8 7a fc ff ff       	call   3b <create>
 3c1:	eb 44                	jmp    407 <main+0x94>
  else if (strcmp(argv[1], "start") == 0)
 3c3:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c6:	83 c0 04             	add    $0x4,%eax
 3c9:	8b 00                	mov    (%eax),%eax
 3cb:	c7 44 24 04 f3 0c 00 	movl   $0xcf3,0x4(%esp)
 3d2:	00 
 3d3:	89 04 24             	mov    %eax,(%esp)
 3d6:	e8 84 00 00 00       	call   45f <strcmp>
 3db:	85 c0                	test   %eax,%eax
 3dd:	75 14                	jne    3f3 <main+0x80>
    start(argc, argv);
 3df:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e2:	89 44 24 04          	mov    %eax,0x4(%esp)
 3e6:	8b 45 08             	mov    0x8(%ebp),%eax
 3e9:	89 04 24             	mov    %eax,(%esp)
 3ec:	e8 69 ff ff ff       	call   35a <start>
 3f1:	eb 14                	jmp    407 <main+0x94>
  else 
    printf(1, "ctool: command not found.\n");   
 3f3:	c7 44 24 04 f9 0c 00 	movl   $0xcf9,0x4(%esp)
 3fa:	00 
 3fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 402:	e8 06 04 00 00       	call   80d <printf>

  exit();
 407:	e8 54 02 00 00       	call   660 <exit>

0000040c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 40c:	55                   	push   %ebp
 40d:	89 e5                	mov    %esp,%ebp
 40f:	57                   	push   %edi
 410:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 411:	8b 4d 08             	mov    0x8(%ebp),%ecx
 414:	8b 55 10             	mov    0x10(%ebp),%edx
 417:	8b 45 0c             	mov    0xc(%ebp),%eax
 41a:	89 cb                	mov    %ecx,%ebx
 41c:	89 df                	mov    %ebx,%edi
 41e:	89 d1                	mov    %edx,%ecx
 420:	fc                   	cld    
 421:	f3 aa                	rep stos %al,%es:(%edi)
 423:	89 ca                	mov    %ecx,%edx
 425:	89 fb                	mov    %edi,%ebx
 427:	89 5d 08             	mov    %ebx,0x8(%ebp)
 42a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 42d:	5b                   	pop    %ebx
 42e:	5f                   	pop    %edi
 42f:	5d                   	pop    %ebp
 430:	c3                   	ret    

00000431 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 431:	55                   	push   %ebp
 432:	89 e5                	mov    %esp,%ebp
 434:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 437:	8b 45 08             	mov    0x8(%ebp),%eax
 43a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 43d:	90                   	nop
 43e:	8b 45 08             	mov    0x8(%ebp),%eax
 441:	8d 50 01             	lea    0x1(%eax),%edx
 444:	89 55 08             	mov    %edx,0x8(%ebp)
 447:	8b 55 0c             	mov    0xc(%ebp),%edx
 44a:	8d 4a 01             	lea    0x1(%edx),%ecx
 44d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 450:	8a 12                	mov    (%edx),%dl
 452:	88 10                	mov    %dl,(%eax)
 454:	8a 00                	mov    (%eax),%al
 456:	84 c0                	test   %al,%al
 458:	75 e4                	jne    43e <strcpy+0xd>
    ;
  return os;
 45a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 45d:	c9                   	leave  
 45e:	c3                   	ret    

0000045f <strcmp>:

int
strcmp(const char *p, const char *q)
{
 45f:	55                   	push   %ebp
 460:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 462:	eb 06                	jmp    46a <strcmp+0xb>
    p++, q++;
 464:	ff 45 08             	incl   0x8(%ebp)
 467:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 46a:	8b 45 08             	mov    0x8(%ebp),%eax
 46d:	8a 00                	mov    (%eax),%al
 46f:	84 c0                	test   %al,%al
 471:	74 0e                	je     481 <strcmp+0x22>
 473:	8b 45 08             	mov    0x8(%ebp),%eax
 476:	8a 10                	mov    (%eax),%dl
 478:	8b 45 0c             	mov    0xc(%ebp),%eax
 47b:	8a 00                	mov    (%eax),%al
 47d:	38 c2                	cmp    %al,%dl
 47f:	74 e3                	je     464 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 481:	8b 45 08             	mov    0x8(%ebp),%eax
 484:	8a 00                	mov    (%eax),%al
 486:	0f b6 d0             	movzbl %al,%edx
 489:	8b 45 0c             	mov    0xc(%ebp),%eax
 48c:	8a 00                	mov    (%eax),%al
 48e:	0f b6 c0             	movzbl %al,%eax
 491:	29 c2                	sub    %eax,%edx
 493:	89 d0                	mov    %edx,%eax
}
 495:	5d                   	pop    %ebp
 496:	c3                   	ret    

00000497 <strlen>:

uint
strlen(char *s)
{
 497:	55                   	push   %ebp
 498:	89 e5                	mov    %esp,%ebp
 49a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 49d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 4a4:	eb 03                	jmp    4a9 <strlen+0x12>
 4a6:	ff 45 fc             	incl   -0x4(%ebp)
 4a9:	8b 55 fc             	mov    -0x4(%ebp),%edx
 4ac:	8b 45 08             	mov    0x8(%ebp),%eax
 4af:	01 d0                	add    %edx,%eax
 4b1:	8a 00                	mov    (%eax),%al
 4b3:	84 c0                	test   %al,%al
 4b5:	75 ef                	jne    4a6 <strlen+0xf>
    ;
  return n;
 4b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 4ba:	c9                   	leave  
 4bb:	c3                   	ret    

000004bc <memset>:

void*
memset(void *dst, int c, uint n)
{
 4bc:	55                   	push   %ebp
 4bd:	89 e5                	mov    %esp,%ebp
 4bf:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 4c2:	8b 45 10             	mov    0x10(%ebp),%eax
 4c5:	89 44 24 08          	mov    %eax,0x8(%esp)
 4c9:	8b 45 0c             	mov    0xc(%ebp),%eax
 4cc:	89 44 24 04          	mov    %eax,0x4(%esp)
 4d0:	8b 45 08             	mov    0x8(%ebp),%eax
 4d3:	89 04 24             	mov    %eax,(%esp)
 4d6:	e8 31 ff ff ff       	call   40c <stosb>
  return dst;
 4db:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4de:	c9                   	leave  
 4df:	c3                   	ret    

000004e0 <strchr>:

char*
strchr(const char *s, char c)
{
 4e0:	55                   	push   %ebp
 4e1:	89 e5                	mov    %esp,%ebp
 4e3:	83 ec 04             	sub    $0x4,%esp
 4e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 4e9:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 4ec:	eb 12                	jmp    500 <strchr+0x20>
    if(*s == c)
 4ee:	8b 45 08             	mov    0x8(%ebp),%eax
 4f1:	8a 00                	mov    (%eax),%al
 4f3:	3a 45 fc             	cmp    -0x4(%ebp),%al
 4f6:	75 05                	jne    4fd <strchr+0x1d>
      return (char*)s;
 4f8:	8b 45 08             	mov    0x8(%ebp),%eax
 4fb:	eb 11                	jmp    50e <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 4fd:	ff 45 08             	incl   0x8(%ebp)
 500:	8b 45 08             	mov    0x8(%ebp),%eax
 503:	8a 00                	mov    (%eax),%al
 505:	84 c0                	test   %al,%al
 507:	75 e5                	jne    4ee <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 509:	b8 00 00 00 00       	mov    $0x0,%eax
}
 50e:	c9                   	leave  
 50f:	c3                   	ret    

00000510 <gets>:

char*
gets(char *buf, int max)
{
 510:	55                   	push   %ebp
 511:	89 e5                	mov    %esp,%ebp
 513:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 516:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 51d:	eb 49                	jmp    568 <gets+0x58>
    cc = read(0, &c, 1);
 51f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 526:	00 
 527:	8d 45 ef             	lea    -0x11(%ebp),%eax
 52a:	89 44 24 04          	mov    %eax,0x4(%esp)
 52e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 535:	e8 3e 01 00 00       	call   678 <read>
 53a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 53d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 541:	7f 02                	jg     545 <gets+0x35>
      break;
 543:	eb 2c                	jmp    571 <gets+0x61>
    buf[i++] = c;
 545:	8b 45 f4             	mov    -0xc(%ebp),%eax
 548:	8d 50 01             	lea    0x1(%eax),%edx
 54b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 54e:	89 c2                	mov    %eax,%edx
 550:	8b 45 08             	mov    0x8(%ebp),%eax
 553:	01 c2                	add    %eax,%edx
 555:	8a 45 ef             	mov    -0x11(%ebp),%al
 558:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 55a:	8a 45 ef             	mov    -0x11(%ebp),%al
 55d:	3c 0a                	cmp    $0xa,%al
 55f:	74 10                	je     571 <gets+0x61>
 561:	8a 45 ef             	mov    -0x11(%ebp),%al
 564:	3c 0d                	cmp    $0xd,%al
 566:	74 09                	je     571 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 568:	8b 45 f4             	mov    -0xc(%ebp),%eax
 56b:	40                   	inc    %eax
 56c:	3b 45 0c             	cmp    0xc(%ebp),%eax
 56f:	7c ae                	jl     51f <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 571:	8b 55 f4             	mov    -0xc(%ebp),%edx
 574:	8b 45 08             	mov    0x8(%ebp),%eax
 577:	01 d0                	add    %edx,%eax
 579:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 57c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 57f:	c9                   	leave  
 580:	c3                   	ret    

00000581 <stat>:

int
stat(char *n, struct stat *st)
{
 581:	55                   	push   %ebp
 582:	89 e5                	mov    %esp,%ebp
 584:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 587:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 58e:	00 
 58f:	8b 45 08             	mov    0x8(%ebp),%eax
 592:	89 04 24             	mov    %eax,(%esp)
 595:	e8 06 01 00 00       	call   6a0 <open>
 59a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 59d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5a1:	79 07                	jns    5aa <stat+0x29>
    return -1;
 5a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 5a8:	eb 23                	jmp    5cd <stat+0x4c>
  r = fstat(fd, st);
 5aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ad:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5b4:	89 04 24             	mov    %eax,(%esp)
 5b7:	e8 fc 00 00 00       	call   6b8 <fstat>
 5bc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 5bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5c2:	89 04 24             	mov    %eax,(%esp)
 5c5:	e8 be 00 00 00       	call   688 <close>
  return r;
 5ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 5cd:	c9                   	leave  
 5ce:	c3                   	ret    

000005cf <atoi>:

int
atoi(const char *s)
{
 5cf:	55                   	push   %ebp
 5d0:	89 e5                	mov    %esp,%ebp
 5d2:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 5d5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 5dc:	eb 24                	jmp    602 <atoi+0x33>
    n = n*10 + *s++ - '0';
 5de:	8b 55 fc             	mov    -0x4(%ebp),%edx
 5e1:	89 d0                	mov    %edx,%eax
 5e3:	c1 e0 02             	shl    $0x2,%eax
 5e6:	01 d0                	add    %edx,%eax
 5e8:	01 c0                	add    %eax,%eax
 5ea:	89 c1                	mov    %eax,%ecx
 5ec:	8b 45 08             	mov    0x8(%ebp),%eax
 5ef:	8d 50 01             	lea    0x1(%eax),%edx
 5f2:	89 55 08             	mov    %edx,0x8(%ebp)
 5f5:	8a 00                	mov    (%eax),%al
 5f7:	0f be c0             	movsbl %al,%eax
 5fa:	01 c8                	add    %ecx,%eax
 5fc:	83 e8 30             	sub    $0x30,%eax
 5ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 602:	8b 45 08             	mov    0x8(%ebp),%eax
 605:	8a 00                	mov    (%eax),%al
 607:	3c 2f                	cmp    $0x2f,%al
 609:	7e 09                	jle    614 <atoi+0x45>
 60b:	8b 45 08             	mov    0x8(%ebp),%eax
 60e:	8a 00                	mov    (%eax),%al
 610:	3c 39                	cmp    $0x39,%al
 612:	7e ca                	jle    5de <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 614:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 617:	c9                   	leave  
 618:	c3                   	ret    

00000619 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 619:	55                   	push   %ebp
 61a:	89 e5                	mov    %esp,%ebp
 61c:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 61f:	8b 45 08             	mov    0x8(%ebp),%eax
 622:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 625:	8b 45 0c             	mov    0xc(%ebp),%eax
 628:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 62b:	eb 16                	jmp    643 <memmove+0x2a>
    *dst++ = *src++;
 62d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 630:	8d 50 01             	lea    0x1(%eax),%edx
 633:	89 55 fc             	mov    %edx,-0x4(%ebp)
 636:	8b 55 f8             	mov    -0x8(%ebp),%edx
 639:	8d 4a 01             	lea    0x1(%edx),%ecx
 63c:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 63f:	8a 12                	mov    (%edx),%dl
 641:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 643:	8b 45 10             	mov    0x10(%ebp),%eax
 646:	8d 50 ff             	lea    -0x1(%eax),%edx
 649:	89 55 10             	mov    %edx,0x10(%ebp)
 64c:	85 c0                	test   %eax,%eax
 64e:	7f dd                	jg     62d <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 650:	8b 45 08             	mov    0x8(%ebp),%eax
}
 653:	c9                   	leave  
 654:	c3                   	ret    
 655:	90                   	nop
 656:	90                   	nop
 657:	90                   	nop

00000658 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 658:	b8 01 00 00 00       	mov    $0x1,%eax
 65d:	cd 40                	int    $0x40
 65f:	c3                   	ret    

00000660 <exit>:
SYSCALL(exit)
 660:	b8 02 00 00 00       	mov    $0x2,%eax
 665:	cd 40                	int    $0x40
 667:	c3                   	ret    

00000668 <wait>:
SYSCALL(wait)
 668:	b8 03 00 00 00       	mov    $0x3,%eax
 66d:	cd 40                	int    $0x40
 66f:	c3                   	ret    

00000670 <pipe>:
SYSCALL(pipe)
 670:	b8 04 00 00 00       	mov    $0x4,%eax
 675:	cd 40                	int    $0x40
 677:	c3                   	ret    

00000678 <read>:
SYSCALL(read)
 678:	b8 05 00 00 00       	mov    $0x5,%eax
 67d:	cd 40                	int    $0x40
 67f:	c3                   	ret    

00000680 <write>:
SYSCALL(write)
 680:	b8 10 00 00 00       	mov    $0x10,%eax
 685:	cd 40                	int    $0x40
 687:	c3                   	ret    

00000688 <close>:
SYSCALL(close)
 688:	b8 15 00 00 00       	mov    $0x15,%eax
 68d:	cd 40                	int    $0x40
 68f:	c3                   	ret    

00000690 <kill>:
SYSCALL(kill)
 690:	b8 06 00 00 00       	mov    $0x6,%eax
 695:	cd 40                	int    $0x40
 697:	c3                   	ret    

00000698 <exec>:
SYSCALL(exec)
 698:	b8 07 00 00 00       	mov    $0x7,%eax
 69d:	cd 40                	int    $0x40
 69f:	c3                   	ret    

000006a0 <open>:
SYSCALL(open)
 6a0:	b8 0f 00 00 00       	mov    $0xf,%eax
 6a5:	cd 40                	int    $0x40
 6a7:	c3                   	ret    

000006a8 <mknod>:
SYSCALL(mknod)
 6a8:	b8 11 00 00 00       	mov    $0x11,%eax
 6ad:	cd 40                	int    $0x40
 6af:	c3                   	ret    

000006b0 <unlink>:
SYSCALL(unlink)
 6b0:	b8 12 00 00 00       	mov    $0x12,%eax
 6b5:	cd 40                	int    $0x40
 6b7:	c3                   	ret    

000006b8 <fstat>:
SYSCALL(fstat)
 6b8:	b8 08 00 00 00       	mov    $0x8,%eax
 6bd:	cd 40                	int    $0x40
 6bf:	c3                   	ret    

000006c0 <link>:
SYSCALL(link)
 6c0:	b8 13 00 00 00       	mov    $0x13,%eax
 6c5:	cd 40                	int    $0x40
 6c7:	c3                   	ret    

000006c8 <mkdir>:
SYSCALL(mkdir)
 6c8:	b8 14 00 00 00       	mov    $0x14,%eax
 6cd:	cd 40                	int    $0x40
 6cf:	c3                   	ret    

000006d0 <chdir>:
SYSCALL(chdir)
 6d0:	b8 09 00 00 00       	mov    $0x9,%eax
 6d5:	cd 40                	int    $0x40
 6d7:	c3                   	ret    

000006d8 <dup>:
SYSCALL(dup)
 6d8:	b8 0a 00 00 00       	mov    $0xa,%eax
 6dd:	cd 40                	int    $0x40
 6df:	c3                   	ret    

000006e0 <getpid>:
SYSCALL(getpid)
 6e0:	b8 0b 00 00 00       	mov    $0xb,%eax
 6e5:	cd 40                	int    $0x40
 6e7:	c3                   	ret    

000006e8 <sbrk>:
SYSCALL(sbrk)
 6e8:	b8 0c 00 00 00       	mov    $0xc,%eax
 6ed:	cd 40                	int    $0x40
 6ef:	c3                   	ret    

000006f0 <sleep>:
SYSCALL(sleep)
 6f0:	b8 0d 00 00 00       	mov    $0xd,%eax
 6f5:	cd 40                	int    $0x40
 6f7:	c3                   	ret    

000006f8 <uptime>:
SYSCALL(uptime)
 6f8:	b8 0e 00 00 00       	mov    $0xe,%eax
 6fd:	cd 40                	int    $0x40
 6ff:	c3                   	ret    

00000700 <getticks>:
SYSCALL(getticks)
 700:	b8 16 00 00 00       	mov    $0x16,%eax
 705:	cd 40                	int    $0x40
 707:	c3                   	ret    

00000708 <ccreate>:
SYSCALL(ccreate)
 708:	b8 17 00 00 00       	mov    $0x17,%eax
 70d:	cd 40                	int    $0x40
 70f:	c3                   	ret    

00000710 <cstart>:
SYSCALL(cstart)
 710:	b8 19 00 00 00       	mov    $0x19,%eax
 715:	cd 40                	int    $0x40
 717:	c3                   	ret    

00000718 <cstop>:
SYSCALL(cstop)
 718:	b8 18 00 00 00       	mov    $0x18,%eax
 71d:	cd 40                	int    $0x40
 71f:	c3                   	ret    

00000720 <cpause>:
SYSCALL(cpause)
 720:	b8 1b 00 00 00       	mov    $0x1b,%eax
 725:	cd 40                	int    $0x40
 727:	c3                   	ret    

00000728 <cinfo>:
SYSCALL(cinfo)
 728:	b8 1a 00 00 00       	mov    $0x1a,%eax
 72d:	cd 40                	int    $0x40
 72f:	c3                   	ret    

00000730 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 730:	55                   	push   %ebp
 731:	89 e5                	mov    %esp,%ebp
 733:	83 ec 18             	sub    $0x18,%esp
 736:	8b 45 0c             	mov    0xc(%ebp),%eax
 739:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 73c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 743:	00 
 744:	8d 45 f4             	lea    -0xc(%ebp),%eax
 747:	89 44 24 04          	mov    %eax,0x4(%esp)
 74b:	8b 45 08             	mov    0x8(%ebp),%eax
 74e:	89 04 24             	mov    %eax,(%esp)
 751:	e8 2a ff ff ff       	call   680 <write>
}
 756:	c9                   	leave  
 757:	c3                   	ret    

00000758 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 758:	55                   	push   %ebp
 759:	89 e5                	mov    %esp,%ebp
 75b:	56                   	push   %esi
 75c:	53                   	push   %ebx
 75d:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 760:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 767:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 76b:	74 17                	je     784 <printint+0x2c>
 76d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 771:	79 11                	jns    784 <printint+0x2c>
    neg = 1;
 773:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 77a:	8b 45 0c             	mov    0xc(%ebp),%eax
 77d:	f7 d8                	neg    %eax
 77f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 782:	eb 06                	jmp    78a <printint+0x32>
  } else {
    x = xx;
 784:	8b 45 0c             	mov    0xc(%ebp),%eax
 787:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 78a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 791:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 794:	8d 41 01             	lea    0x1(%ecx),%eax
 797:	89 45 f4             	mov    %eax,-0xc(%ebp)
 79a:	8b 5d 10             	mov    0x10(%ebp),%ebx
 79d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7a0:	ba 00 00 00 00       	mov    $0x0,%edx
 7a5:	f7 f3                	div    %ebx
 7a7:	89 d0                	mov    %edx,%eax
 7a9:	8a 80 5c 10 00 00    	mov    0x105c(%eax),%al
 7af:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 7b3:	8b 75 10             	mov    0x10(%ebp),%esi
 7b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 7b9:	ba 00 00 00 00       	mov    $0x0,%edx
 7be:	f7 f6                	div    %esi
 7c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
 7c3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 7c7:	75 c8                	jne    791 <printint+0x39>
  if(neg)
 7c9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7cd:	74 10                	je     7df <printint+0x87>
    buf[i++] = '-';
 7cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d2:	8d 50 01             	lea    0x1(%eax),%edx
 7d5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 7d8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 7dd:	eb 1e                	jmp    7fd <printint+0xa5>
 7df:	eb 1c                	jmp    7fd <printint+0xa5>
    putc(fd, buf[i]);
 7e1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 7e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e7:	01 d0                	add    %edx,%eax
 7e9:	8a 00                	mov    (%eax),%al
 7eb:	0f be c0             	movsbl %al,%eax
 7ee:	89 44 24 04          	mov    %eax,0x4(%esp)
 7f2:	8b 45 08             	mov    0x8(%ebp),%eax
 7f5:	89 04 24             	mov    %eax,(%esp)
 7f8:	e8 33 ff ff ff       	call   730 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 7fd:	ff 4d f4             	decl   -0xc(%ebp)
 800:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 804:	79 db                	jns    7e1 <printint+0x89>
    putc(fd, buf[i]);
}
 806:	83 c4 30             	add    $0x30,%esp
 809:	5b                   	pop    %ebx
 80a:	5e                   	pop    %esi
 80b:	5d                   	pop    %ebp
 80c:	c3                   	ret    

0000080d <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 80d:	55                   	push   %ebp
 80e:	89 e5                	mov    %esp,%ebp
 810:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 813:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 81a:	8d 45 0c             	lea    0xc(%ebp),%eax
 81d:	83 c0 04             	add    $0x4,%eax
 820:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 823:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 82a:	e9 77 01 00 00       	jmp    9a6 <printf+0x199>
    c = fmt[i] & 0xff;
 82f:	8b 55 0c             	mov    0xc(%ebp),%edx
 832:	8b 45 f0             	mov    -0x10(%ebp),%eax
 835:	01 d0                	add    %edx,%eax
 837:	8a 00                	mov    (%eax),%al
 839:	0f be c0             	movsbl %al,%eax
 83c:	25 ff 00 00 00       	and    $0xff,%eax
 841:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 844:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 848:	75 2c                	jne    876 <printf+0x69>
      if(c == '%'){
 84a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 84e:	75 0c                	jne    85c <printf+0x4f>
        state = '%';
 850:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 857:	e9 47 01 00 00       	jmp    9a3 <printf+0x196>
      } else {
        putc(fd, c);
 85c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 85f:	0f be c0             	movsbl %al,%eax
 862:	89 44 24 04          	mov    %eax,0x4(%esp)
 866:	8b 45 08             	mov    0x8(%ebp),%eax
 869:	89 04 24             	mov    %eax,(%esp)
 86c:	e8 bf fe ff ff       	call   730 <putc>
 871:	e9 2d 01 00 00       	jmp    9a3 <printf+0x196>
      }
    } else if(state == '%'){
 876:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 87a:	0f 85 23 01 00 00    	jne    9a3 <printf+0x196>
      if(c == 'd'){
 880:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 884:	75 2d                	jne    8b3 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 886:	8b 45 e8             	mov    -0x18(%ebp),%eax
 889:	8b 00                	mov    (%eax),%eax
 88b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 892:	00 
 893:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 89a:	00 
 89b:	89 44 24 04          	mov    %eax,0x4(%esp)
 89f:	8b 45 08             	mov    0x8(%ebp),%eax
 8a2:	89 04 24             	mov    %eax,(%esp)
 8a5:	e8 ae fe ff ff       	call   758 <printint>
        ap++;
 8aa:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8ae:	e9 e9 00 00 00       	jmp    99c <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 8b3:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 8b7:	74 06                	je     8bf <printf+0xb2>
 8b9:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 8bd:	75 2d                	jne    8ec <printf+0xdf>
        printint(fd, *ap, 16, 0);
 8bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8c2:	8b 00                	mov    (%eax),%eax
 8c4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 8cb:	00 
 8cc:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 8d3:	00 
 8d4:	89 44 24 04          	mov    %eax,0x4(%esp)
 8d8:	8b 45 08             	mov    0x8(%ebp),%eax
 8db:	89 04 24             	mov    %eax,(%esp)
 8de:	e8 75 fe ff ff       	call   758 <printint>
        ap++;
 8e3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 8e7:	e9 b0 00 00 00       	jmp    99c <printf+0x18f>
      } else if(c == 's'){
 8ec:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 8f0:	75 42                	jne    934 <printf+0x127>
        s = (char*)*ap;
 8f2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 8f5:	8b 00                	mov    (%eax),%eax
 8f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 8fa:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 8fe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 902:	75 09                	jne    90d <printf+0x100>
          s = "(null)";
 904:	c7 45 f4 14 0d 00 00 	movl   $0xd14,-0xc(%ebp)
        while(*s != 0){
 90b:	eb 1c                	jmp    929 <printf+0x11c>
 90d:	eb 1a                	jmp    929 <printf+0x11c>
          putc(fd, *s);
 90f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 912:	8a 00                	mov    (%eax),%al
 914:	0f be c0             	movsbl %al,%eax
 917:	89 44 24 04          	mov    %eax,0x4(%esp)
 91b:	8b 45 08             	mov    0x8(%ebp),%eax
 91e:	89 04 24             	mov    %eax,(%esp)
 921:	e8 0a fe ff ff       	call   730 <putc>
          s++;
 926:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 929:	8b 45 f4             	mov    -0xc(%ebp),%eax
 92c:	8a 00                	mov    (%eax),%al
 92e:	84 c0                	test   %al,%al
 930:	75 dd                	jne    90f <printf+0x102>
 932:	eb 68                	jmp    99c <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 934:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 938:	75 1d                	jne    957 <printf+0x14a>
        putc(fd, *ap);
 93a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 93d:	8b 00                	mov    (%eax),%eax
 93f:	0f be c0             	movsbl %al,%eax
 942:	89 44 24 04          	mov    %eax,0x4(%esp)
 946:	8b 45 08             	mov    0x8(%ebp),%eax
 949:	89 04 24             	mov    %eax,(%esp)
 94c:	e8 df fd ff ff       	call   730 <putc>
        ap++;
 951:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 955:	eb 45                	jmp    99c <printf+0x18f>
      } else if(c == '%'){
 957:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 95b:	75 17                	jne    974 <printf+0x167>
        putc(fd, c);
 95d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 960:	0f be c0             	movsbl %al,%eax
 963:	89 44 24 04          	mov    %eax,0x4(%esp)
 967:	8b 45 08             	mov    0x8(%ebp),%eax
 96a:	89 04 24             	mov    %eax,(%esp)
 96d:	e8 be fd ff ff       	call   730 <putc>
 972:	eb 28                	jmp    99c <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 974:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 97b:	00 
 97c:	8b 45 08             	mov    0x8(%ebp),%eax
 97f:	89 04 24             	mov    %eax,(%esp)
 982:	e8 a9 fd ff ff       	call   730 <putc>
        putc(fd, c);
 987:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 98a:	0f be c0             	movsbl %al,%eax
 98d:	89 44 24 04          	mov    %eax,0x4(%esp)
 991:	8b 45 08             	mov    0x8(%ebp),%eax
 994:	89 04 24             	mov    %eax,(%esp)
 997:	e8 94 fd ff ff       	call   730 <putc>
      }
      state = 0;
 99c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 9a3:	ff 45 f0             	incl   -0x10(%ebp)
 9a6:	8b 55 0c             	mov    0xc(%ebp),%edx
 9a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9ac:	01 d0                	add    %edx,%eax
 9ae:	8a 00                	mov    (%eax),%al
 9b0:	84 c0                	test   %al,%al
 9b2:	0f 85 77 fe ff ff    	jne    82f <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 9b8:	c9                   	leave  
 9b9:	c3                   	ret    
 9ba:	90                   	nop
 9bb:	90                   	nop

000009bc <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9bc:	55                   	push   %ebp
 9bd:	89 e5                	mov    %esp,%ebp
 9bf:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9c2:	8b 45 08             	mov    0x8(%ebp),%eax
 9c5:	83 e8 08             	sub    $0x8,%eax
 9c8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9cb:	a1 78 10 00 00       	mov    0x1078,%eax
 9d0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9d3:	eb 24                	jmp    9f9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d8:	8b 00                	mov    (%eax),%eax
 9da:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9dd:	77 12                	ja     9f1 <free+0x35>
 9df:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9e2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9e5:	77 24                	ja     a0b <free+0x4f>
 9e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ea:	8b 00                	mov    (%eax),%eax
 9ec:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9ef:	77 1a                	ja     a0b <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9f4:	8b 00                	mov    (%eax),%eax
 9f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 9f9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9fc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 9ff:	76 d4                	jbe    9d5 <free+0x19>
 a01:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a04:	8b 00                	mov    (%eax),%eax
 a06:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a09:	76 ca                	jbe    9d5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 a0b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a0e:	8b 40 04             	mov    0x4(%eax),%eax
 a11:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a18:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a1b:	01 c2                	add    %eax,%edx
 a1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a20:	8b 00                	mov    (%eax),%eax
 a22:	39 c2                	cmp    %eax,%edx
 a24:	75 24                	jne    a4a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 a26:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a29:	8b 50 04             	mov    0x4(%eax),%edx
 a2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a2f:	8b 00                	mov    (%eax),%eax
 a31:	8b 40 04             	mov    0x4(%eax),%eax
 a34:	01 c2                	add    %eax,%edx
 a36:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a39:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 a3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a3f:	8b 00                	mov    (%eax),%eax
 a41:	8b 10                	mov    (%eax),%edx
 a43:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a46:	89 10                	mov    %edx,(%eax)
 a48:	eb 0a                	jmp    a54 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 a4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a4d:	8b 10                	mov    (%eax),%edx
 a4f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a52:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 a54:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a57:	8b 40 04             	mov    0x4(%eax),%eax
 a5a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 a61:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a64:	01 d0                	add    %edx,%eax
 a66:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 a69:	75 20                	jne    a8b <free+0xcf>
    p->s.size += bp->s.size;
 a6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a6e:	8b 50 04             	mov    0x4(%eax),%edx
 a71:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a74:	8b 40 04             	mov    0x4(%eax),%eax
 a77:	01 c2                	add    %eax,%edx
 a79:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a7c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 a7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 a82:	8b 10                	mov    (%eax),%edx
 a84:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a87:	89 10                	mov    %edx,(%eax)
 a89:	eb 08                	jmp    a93 <free+0xd7>
  } else
    p->s.ptr = bp;
 a8b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a8e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 a91:	89 10                	mov    %edx,(%eax)
  freep = p;
 a93:	8b 45 fc             	mov    -0x4(%ebp),%eax
 a96:	a3 78 10 00 00       	mov    %eax,0x1078
}
 a9b:	c9                   	leave  
 a9c:	c3                   	ret    

00000a9d <morecore>:

static Header*
morecore(uint nu)
{
 a9d:	55                   	push   %ebp
 a9e:	89 e5                	mov    %esp,%ebp
 aa0:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 aa3:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 aaa:	77 07                	ja     ab3 <morecore+0x16>
    nu = 4096;
 aac:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 ab3:	8b 45 08             	mov    0x8(%ebp),%eax
 ab6:	c1 e0 03             	shl    $0x3,%eax
 ab9:	89 04 24             	mov    %eax,(%esp)
 abc:	e8 27 fc ff ff       	call   6e8 <sbrk>
 ac1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 ac4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 ac8:	75 07                	jne    ad1 <morecore+0x34>
    return 0;
 aca:	b8 00 00 00 00       	mov    $0x0,%eax
 acf:	eb 22                	jmp    af3 <morecore+0x56>
  hp = (Header*)p;
 ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ad4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 ad7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ada:	8b 55 08             	mov    0x8(%ebp),%edx
 add:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 ae0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ae3:	83 c0 08             	add    $0x8,%eax
 ae6:	89 04 24             	mov    %eax,(%esp)
 ae9:	e8 ce fe ff ff       	call   9bc <free>
  return freep;
 aee:	a1 78 10 00 00       	mov    0x1078,%eax
}
 af3:	c9                   	leave  
 af4:	c3                   	ret    

00000af5 <malloc>:

void*
malloc(uint nbytes)
{
 af5:	55                   	push   %ebp
 af6:	89 e5                	mov    %esp,%ebp
 af8:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 afb:	8b 45 08             	mov    0x8(%ebp),%eax
 afe:	83 c0 07             	add    $0x7,%eax
 b01:	c1 e8 03             	shr    $0x3,%eax
 b04:	40                   	inc    %eax
 b05:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 b08:	a1 78 10 00 00       	mov    0x1078,%eax
 b0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b10:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 b14:	75 23                	jne    b39 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 b16:	c7 45 f0 70 10 00 00 	movl   $0x1070,-0x10(%ebp)
 b1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b20:	a3 78 10 00 00       	mov    %eax,0x1078
 b25:	a1 78 10 00 00       	mov    0x1078,%eax
 b2a:	a3 70 10 00 00       	mov    %eax,0x1070
    base.s.size = 0;
 b2f:	c7 05 74 10 00 00 00 	movl   $0x0,0x1074
 b36:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b39:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b3c:	8b 00                	mov    (%eax),%eax
 b3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b44:	8b 40 04             	mov    0x4(%eax),%eax
 b47:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b4a:	72 4d                	jb     b99 <malloc+0xa4>
      if(p->s.size == nunits)
 b4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b4f:	8b 40 04             	mov    0x4(%eax),%eax
 b52:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 b55:	75 0c                	jne    b63 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 b57:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b5a:	8b 10                	mov    (%eax),%edx
 b5c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b5f:	89 10                	mov    %edx,(%eax)
 b61:	eb 26                	jmp    b89 <malloc+0x94>
      else {
        p->s.size -= nunits;
 b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b66:	8b 40 04             	mov    0x4(%eax),%eax
 b69:	2b 45 ec             	sub    -0x14(%ebp),%eax
 b6c:	89 c2                	mov    %eax,%edx
 b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b71:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b77:	8b 40 04             	mov    0x4(%eax),%eax
 b7a:	c1 e0 03             	shl    $0x3,%eax
 b7d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 b80:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b83:	8b 55 ec             	mov    -0x14(%ebp),%edx
 b86:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 b89:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b8c:	a3 78 10 00 00       	mov    %eax,0x1078
      return (void*)(p + 1);
 b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b94:	83 c0 08             	add    $0x8,%eax
 b97:	eb 38                	jmp    bd1 <malloc+0xdc>
    }
    if(p == freep)
 b99:	a1 78 10 00 00       	mov    0x1078,%eax
 b9e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ba1:	75 1b                	jne    bbe <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 ba3:	8b 45 ec             	mov    -0x14(%ebp),%eax
 ba6:	89 04 24             	mov    %eax,(%esp)
 ba9:	e8 ef fe ff ff       	call   a9d <morecore>
 bae:	89 45 f4             	mov    %eax,-0xc(%ebp)
 bb1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 bb5:	75 07                	jne    bbe <malloc+0xc9>
        return 0;
 bb7:	b8 00 00 00 00       	mov    $0x0,%eax
 bbc:	eb 13                	jmp    bd1 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 bbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bc7:	8b 00                	mov    (%eax),%eax
 bc9:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 bcc:	e9 70 ff ff ff       	jmp    b41 <malloc+0x4c>
}
 bd1:	c9                   	leave  
 bd2:	c3                   	ret    
