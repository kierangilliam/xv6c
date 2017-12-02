
_ctool:     file format elf32-i386


Disassembly of section .text:

00000000 <usage>:
// TODO: Clean up tab space formatting of modified files
// TODO: Rewrite comments on proc.c, comment container.c

void 
usage(char* usage) 
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
    printf(1, "usage: ctool %s\n", usage);
   6:	8b 45 08             	mov    0x8(%ebp),%eax
   9:	89 44 24 08          	mov    %eax,0x8(%esp)
   d:	c7 44 24 04 a8 0e 00 	movl   $0xea8,0x4(%esp)
  14:	00 
  15:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1c:	e8 c0 0a 00 00       	call   ae1 <printf>
    exit();
  21:	e8 0e 09 00 00       	call   934 <exit>

00000026 <cp>:
// https://stackoverflow.com/
// questions/33792754/
// in-c-on-linux-how-would-you-implement-cp
int
cp(char* dst, char* file)
{  
  26:	55                   	push   %ebp
  27:	89 e5                	mov    %esp,%ebp
  29:	57                   	push   %edi
  2a:	56                   	push   %esi
  2b:	53                   	push   %ebx
  2c:	81 ec 3c 04 00 00    	sub    $0x43c,%esp
  32:	89 e0                	mov    %esp,%eax
  34:	89 c6                	mov    %eax,%esi
  char buffer[1024];
  int files[2];
  int count;
  int pathsize = strlen(dst) + strlen(file) + 2; // dst.len + '/' + src.len + \0
  36:	8b 45 08             	mov    0x8(%ebp),%eax
  39:	89 04 24             	mov    %eax,(%esp)
  3c:	e8 2a 07 00 00       	call   76b <strlen>
  41:	89 c3                	mov    %eax,%ebx
  43:	8b 45 0c             	mov    0xc(%ebp),%eax
  46:	89 04 24             	mov    %eax,(%esp)
  49:	e8 1d 07 00 00       	call   76b <strlen>
  4e:	01 d8                	add    %ebx,%eax
  50:	83 c0 02             	add    $0x2,%eax
  53:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  char path[pathsize]; 
  56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  59:	8d 50 ff             	lea    -0x1(%eax),%edx
  5c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  5f:	ba 10 00 00 00       	mov    $0x10,%edx
  64:	4a                   	dec    %edx
  65:	01 d0                	add    %edx,%eax
  67:	b9 10 00 00 00       	mov    $0x10,%ecx
  6c:	ba 00 00 00 00       	mov    $0x0,%edx
  71:	f7 f1                	div    %ecx
  73:	6b c0 10             	imul   $0x10,%eax,%eax
  76:	29 c4                	sub    %eax,%esp
  78:	8d 44 24 0c          	lea    0xc(%esp),%eax
  7c:	83 c0 00             	add    $0x0,%eax
  7f:	89 45 dc             	mov    %eax,-0x24(%ebp)

  memmove(path, dst, strlen(dst));
  82:	8b 45 08             	mov    0x8(%ebp),%eax
  85:	89 04 24             	mov    %eax,(%esp)
  88:	e8 de 06 00 00       	call   76b <strlen>
  8d:	89 c2                	mov    %eax,%edx
  8f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  92:	89 54 24 08          	mov    %edx,0x8(%esp)
  96:	8b 55 08             	mov    0x8(%ebp),%edx
  99:	89 54 24 04          	mov    %edx,0x4(%esp)
  9d:	89 04 24             	mov    %eax,(%esp)
  a0:	e8 48 08 00 00       	call   8ed <memmove>
  memmove(path + strlen(dst), "/", 1);
  a5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  a8:	8b 45 08             	mov    0x8(%ebp),%eax
  ab:	89 04 24             	mov    %eax,(%esp)
  ae:	e8 b8 06 00 00       	call   76b <strlen>
  b3:	01 d8                	add    %ebx,%eax
  b5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  bc:	00 
  bd:	c7 44 24 04 b9 0e 00 	movl   $0xeb9,0x4(%esp)
  c4:	00 
  c5:	89 04 24             	mov    %eax,(%esp)
  c8:	e8 20 08 00 00       	call   8ed <memmove>
  memmove(path + strlen(dst) + 1, file, strlen(file));
  cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  d0:	89 04 24             	mov    %eax,(%esp)
  d3:	e8 93 06 00 00       	call   76b <strlen>
  d8:	89 c3                	mov    %eax,%ebx
  da:	8b 7d dc             	mov    -0x24(%ebp),%edi
  dd:	8b 45 08             	mov    0x8(%ebp),%eax
  e0:	89 04 24             	mov    %eax,(%esp)
  e3:	e8 83 06 00 00       	call   76b <strlen>
  e8:	40                   	inc    %eax
  e9:	8d 14 07             	lea    (%edi,%eax,1),%edx
  ec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  f7:	89 14 24             	mov    %edx,(%esp)
  fa:	e8 ee 07 00 00       	call   8ed <memmove>
  memmove(path + strlen(dst) + 1 + strlen(file), "\0", 1);
  ff:	8b 7d dc             	mov    -0x24(%ebp),%edi
 102:	8b 45 08             	mov    0x8(%ebp),%eax
 105:	89 04 24             	mov    %eax,(%esp)
 108:	e8 5e 06 00 00       	call   76b <strlen>
 10d:	89 c3                	mov    %eax,%ebx
 10f:	8b 45 0c             	mov    0xc(%ebp),%eax
 112:	89 04 24             	mov    %eax,(%esp)
 115:	e8 51 06 00 00       	call   76b <strlen>
 11a:	01 d8                	add    %ebx,%eax
 11c:	40                   	inc    %eax
 11d:	01 f8                	add    %edi,%eax
 11f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 126:	00 
 127:	c7 44 24 04 bb 0e 00 	movl   $0xebb,0x4(%esp)
 12e:	00 
 12f:	89 04 24             	mov    %eax,(%esp)
 132:	e8 b6 07 00 00       	call   8ed <memmove>

  files[0] = open(file, O_RDONLY);
 137:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 13e:	00 
 13f:	8b 45 0c             	mov    0xc(%ebp),%eax
 142:	89 04 24             	mov    %eax,(%esp)
 145:	e8 2a 08 00 00       	call   974 <open>
 14a:	89 85 d0 fb ff ff    	mov    %eax,-0x430(%ebp)
  if (files[0] == -1) // Check if file opened 
 150:	8b 85 d0 fb ff ff    	mov    -0x430(%ebp),%eax
 156:	83 f8 ff             	cmp    $0xffffffff,%eax
 159:	75 0a                	jne    165 <cp+0x13f>
      return -1;
 15b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 160:	e9 a3 00 00 00       	jmp    208 <cp+0x1e2>
  
  files[1] = open(path, O_WRONLY | O_CREATE);
 165:	8b 45 dc             	mov    -0x24(%ebp),%eax
 168:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
 16f:	00 
 170:	89 04 24             	mov    %eax,(%esp)
 173:	e8 fc 07 00 00       	call   974 <open>
 178:	89 85 d4 fb ff ff    	mov    %eax,-0x42c(%ebp)
  if (files[1] == -1) { // Check if file opened (permissions problems ...) 
 17e:	8b 85 d4 fb ff ff    	mov    -0x42c(%ebp),%eax
 184:	83 f8 ff             	cmp    $0xffffffff,%eax
 187:	75 30                	jne    1b9 <cp+0x193>
    printf(1, "failed to create file |%s|\n", path);
 189:	8b 45 dc             	mov    -0x24(%ebp),%eax
 18c:	89 44 24 08          	mov    %eax,0x8(%esp)
 190:	c7 44 24 04 bd 0e 00 	movl   $0xebd,0x4(%esp)
 197:	00 
 198:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 19f:	e8 3d 09 00 00       	call   ae1 <printf>
    close(files[0]);
 1a4:	8b 85 d0 fb ff ff    	mov    -0x430(%ebp),%eax
 1aa:	89 04 24             	mov    %eax,(%esp)
 1ad:	e8 aa 07 00 00       	call   95c <close>
    return -1;
 1b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1b7:	eb 4f                	jmp    208 <cp+0x1e2>
  }

  while ((count = read(files[0], buffer, sizeof(buffer))) != 0)
 1b9:	eb 1f                	jmp    1da <cp+0x1b4>
      write(files[1], buffer, count);
 1bb:	8b 85 d4 fb ff ff    	mov    -0x42c(%ebp),%eax
 1c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
 1c4:	89 54 24 08          	mov    %edx,0x8(%esp)
 1c8:	8d 95 d8 fb ff ff    	lea    -0x428(%ebp),%edx
 1ce:	89 54 24 04          	mov    %edx,0x4(%esp)
 1d2:	89 04 24             	mov    %eax,(%esp)
 1d5:	e8 7a 07 00 00       	call   954 <write>
    printf(1, "failed to create file |%s|\n", path);
    close(files[0]);
    return -1;
  }

  while ((count = read(files[0], buffer, sizeof(buffer))) != 0)
 1da:	8b 85 d0 fb ff ff    	mov    -0x430(%ebp),%eax
 1e0:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
 1e7:	00 
 1e8:	8d 95 d8 fb ff ff    	lea    -0x428(%ebp),%edx
 1ee:	89 54 24 04          	mov    %edx,0x4(%esp)
 1f2:	89 04 24             	mov    %eax,(%esp)
 1f5:	e8 52 07 00 00       	call   94c <read>
 1fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
 1fd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
 201:	75 b8                	jne    1bb <cp+0x195>
      write(files[1], buffer, count);

  return 1;
 203:	b8 01 00 00 00       	mov    $0x1,%eax
 208:	89 f4                	mov    %esi,%esp
}
 20a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 20d:	5b                   	pop    %ebx
 20e:	5e                   	pop    %esi
 20f:	5f                   	pop    %edi
 210:	5d                   	pop    %ebp
 211:	c3                   	ret    

00000212 <max>:

int
max(int a, int b)
{
 212:	55                   	push   %ebp
 213:	89 e5                	mov    %esp,%ebp
  if (a > b)
 215:	8b 45 08             	mov    0x8(%ebp),%eax
 218:	3b 45 0c             	cmp    0xc(%ebp),%eax
 21b:	7e 05                	jle    222 <max+0x10>
    return a;
 21d:	8b 45 08             	mov    0x8(%ebp),%eax
 220:	eb 03                	jmp    225 <max+0x13>
  else
    return b;
 222:	8b 45 0c             	mov    0xc(%ebp),%eax
}
 225:	5d                   	pop    %ebp
 226:	c3                   	ret    

00000227 <create>:
// ctool create ctest1 -p 4 sh ps cat echoloop
// folder/ container name, what to copy into folder
// mkdir, cp file 1, cp file n  
void
create(int argc, char *argv[])
{
 227:	55                   	push   %ebp
 228:	89 e5                	mov    %esp,%ebp
 22a:	81 ec c8 00 00 00    	sub    $0xc8,%esp
  char *progv[MAXARG];
  int i, k, progc, last_flag = 2, // No flags
 230:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  mproc = MAX_CONT_PROC, 
 237:	c7 45 e8 40 00 00 00 	movl   $0x40,-0x18(%ebp)
  msz = MAX_CONT_MEM, 
 23e:	c7 45 e4 00 10 00 00 	movl   $0x1000,-0x1c(%ebp)
  mdsk = MAX_CONT_DSK;  
 245:	c7 45 e0 00 10 00 00 	movl   $0x1000,-0x20(%ebp)

  if (argc < 4)
 24c:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
 250:	7f 0c                	jg     25e <create+0x37>
    usage("create <name> [-p <max_processes>] [-m <max_memory>] [-d <max_disk>] prog [prog2.. ]");
 252:	c7 04 24 dc 0e 00 00 	movl   $0xedc,(%esp)
 259:	e8 a2 fd ff ff       	call   0 <usage>


  for (i = 0; i < argc; i++) {
 25e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 265:	e9 0b 01 00 00       	jmp    375 <create+0x14e>
    if (strcmp(argv[i], "-p") == 0) {
 26a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 26d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 274:	8b 45 0c             	mov    0xc(%ebp),%eax
 277:	01 d0                	add    %edx,%eax
 279:	8b 00                	mov    (%eax),%eax
 27b:	c7 44 24 04 31 0f 00 	movl   $0xf31,0x4(%esp)
 282:	00 
 283:	89 04 24             	mov    %eax,(%esp)
 286:	e8 a8 04 00 00       	call   733 <strcmp>
 28b:	85 c0                	test   %eax,%eax
 28d:	75 33                	jne    2c2 <create+0x9b>
      last_flag = max(last_flag, i + 1);
 28f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 292:	40                   	inc    %eax
 293:	89 44 24 04          	mov    %eax,0x4(%esp)
 297:	8b 45 ec             	mov    -0x14(%ebp),%eax
 29a:	89 04 24             	mov    %eax,(%esp)
 29d:	e8 70 ff ff ff       	call   212 <max>
 2a2:	89 45 ec             	mov    %eax,-0x14(%ebp)
      mproc = atoi(argv[i + 1]);
 2a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2a8:	40                   	inc    %eax
 2a9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 2b0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b3:	01 d0                	add    %edx,%eax
 2b5:	8b 00                	mov    (%eax),%eax
 2b7:	89 04 24             	mov    %eax,(%esp)
 2ba:	e8 e4 05 00 00       	call   8a3 <atoi>
 2bf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    }
    if (strcmp(argv[i], "-m") == 0) {
 2c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 2cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2cf:	01 d0                	add    %edx,%eax
 2d1:	8b 00                	mov    (%eax),%eax
 2d3:	c7 44 24 04 34 0f 00 	movl   $0xf34,0x4(%esp)
 2da:	00 
 2db:	89 04 24             	mov    %eax,(%esp)
 2de:	e8 50 04 00 00       	call   733 <strcmp>
 2e3:	85 c0                	test   %eax,%eax
 2e5:	75 33                	jne    31a <create+0xf3>
      last_flag = max(last_flag, i + 1);
 2e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ea:	40                   	inc    %eax
 2eb:	89 44 24 04          	mov    %eax,0x4(%esp)
 2ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
 2f2:	89 04 24             	mov    %eax,(%esp)
 2f5:	e8 18 ff ff ff       	call   212 <max>
 2fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
      msz = atoi(argv[i + 1]);
 2fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 300:	40                   	inc    %eax
 301:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 308:	8b 45 0c             	mov    0xc(%ebp),%eax
 30b:	01 d0                	add    %edx,%eax
 30d:	8b 00                	mov    (%eax),%eax
 30f:	89 04 24             	mov    %eax,(%esp)
 312:	e8 8c 05 00 00       	call   8a3 <atoi>
 317:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    }
    if (strcmp(argv[i], "-d") == 0) {
 31a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 31d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 324:	8b 45 0c             	mov    0xc(%ebp),%eax
 327:	01 d0                	add    %edx,%eax
 329:	8b 00                	mov    (%eax),%eax
 32b:	c7 44 24 04 37 0f 00 	movl   $0xf37,0x4(%esp)
 332:	00 
 333:	89 04 24             	mov    %eax,(%esp)
 336:	e8 f8 03 00 00       	call   733 <strcmp>
 33b:	85 c0                	test   %eax,%eax
 33d:	75 33                	jne    372 <create+0x14b>
      last_flag = max(last_flag, i + 1);
 33f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 342:	40                   	inc    %eax
 343:	89 44 24 04          	mov    %eax,0x4(%esp)
 347:	8b 45 ec             	mov    -0x14(%ebp),%eax
 34a:	89 04 24             	mov    %eax,(%esp)
 34d:	e8 c0 fe ff ff       	call   212 <max>
 352:	89 45 ec             	mov    %eax,-0x14(%ebp)
      mdsk = atoi(argv[i + 1]);
 355:	8b 45 f4             	mov    -0xc(%ebp),%eax
 358:	40                   	inc    %eax
 359:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 360:	8b 45 0c             	mov    0xc(%ebp),%eax
 363:	01 d0                	add    %edx,%eax
 365:	8b 00                	mov    (%eax),%eax
 367:	89 04 24             	mov    %eax,(%esp)
 36a:	e8 34 05 00 00       	call   8a3 <atoi>
 36f:	89 45 e0             	mov    %eax,-0x20(%ebp)

  if (argc < 4)
    usage("create <name> [-p <max_processes>] [-m <max_memory>] [-d <max_disk>] prog [prog2.. ]");


  for (i = 0; i < argc; i++) {
 372:	ff 45 f4             	incl   -0xc(%ebp)
 375:	8b 45 f4             	mov    -0xc(%ebp),%eax
 378:	3b 45 08             	cmp    0x8(%ebp),%eax
 37b:	0f 8c e9 fe ff ff    	jl     26a <create+0x43>
      last_flag = max(last_flag, i + 1);
      mdsk = atoi(argv[i + 1]);
    }
  }

  progc = argc - last_flag - 1;
 381:	8b 45 ec             	mov    -0x14(%ebp),%eax
 384:	8b 55 08             	mov    0x8(%ebp),%edx
 387:	29 c2                	sub    %eax,%edx
 389:	89 d0                	mov    %edx,%eax
 38b:	48                   	dec    %eax
 38c:	89 45 dc             	mov    %eax,-0x24(%ebp)

  mkdir(argv[2]);
 38f:	8b 45 0c             	mov    0xc(%ebp),%eax
 392:	83 c0 08             	add    $0x8,%eax
 395:	8b 00                	mov    (%eax),%eax
 397:	89 04 24             	mov    %eax,(%esp)
 39a:	e8 fd 05 00 00       	call   99c <mkdir>

  printf(1, "name: %s\nmproc: %d\nmsz: %d\nmdsk: %d\nprogc: %d\n", argv[2], mproc, msz, mdsk, progc);
 39f:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a2:	83 c0 08             	add    $0x8,%eax
 3a5:	8b 00                	mov    (%eax),%eax
 3a7:	8b 55 dc             	mov    -0x24(%ebp),%edx
 3aa:	89 54 24 18          	mov    %edx,0x18(%esp)
 3ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
 3b1:	89 54 24 14          	mov    %edx,0x14(%esp)
 3b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 3b8:	89 54 24 10          	mov    %edx,0x10(%esp)
 3bc:	8b 55 e8             	mov    -0x18(%ebp),%edx
 3bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
 3c3:	89 44 24 08          	mov    %eax,0x8(%esp)
 3c7:	c7 44 24 04 3c 0f 00 	movl   $0xf3c,0x4(%esp)
 3ce:	00 
 3cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3d6:	e8 06 07 00 00       	call   ae1 <printf>

  if (ccreate(argv[2], progv, progc, mproc, msz, mdsk) == 1) {
 3db:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 3de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 3e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e4:	83 c0 08             	add    $0x8,%eax
 3e7:	8b 00                	mov    (%eax),%eax
 3e9:	89 4c 24 14          	mov    %ecx,0x14(%esp)
 3ed:	89 54 24 10          	mov    %edx,0x10(%esp)
 3f1:	8b 55 e8             	mov    -0x18(%ebp),%edx
 3f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
 3f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
 3fb:	89 54 24 08          	mov    %edx,0x8(%esp)
 3ff:	8d 95 5c ff ff ff    	lea    -0xa4(%ebp),%edx
 405:	89 54 24 04          	mov    %edx,0x4(%esp)
 409:	89 04 24             	mov    %eax,(%esp)
 40c:	e8 cb 05 00 00       	call   9dc <ccreate>
 411:	83 f8 01             	cmp    $0x1,%eax
 414:	75 22                	jne    438 <create+0x211>
    printf(1, "Created container %s\n", argv[2]); 
 416:	8b 45 0c             	mov    0xc(%ebp),%eax
 419:	83 c0 08             	add    $0x8,%eax
 41c:	8b 00                	mov    (%eax),%eax
 41e:	89 44 24 08          	mov    %eax,0x8(%esp)
 422:	c7 44 24 04 6b 0f 00 	movl   $0xf6b,0x4(%esp)
 429:	00 
 42a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 431:	e8 ab 06 00 00       	call   ae1 <printf>
 436:	eb 20                	jmp    458 <create+0x231>
  } else {
    printf(1, "Failed to create container %s\n", argv[2]); 
 438:	8b 45 0c             	mov    0xc(%ebp),%eax
 43b:	83 c0 08             	add    $0x8,%eax
 43e:	8b 00                	mov    (%eax),%eax
 440:	89 44 24 08          	mov    %eax,0x8(%esp)
 444:	c7 44 24 04 84 0f 00 	movl   $0xf84,0x4(%esp)
 44b:	00 
 44c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 453:	e8 89 06 00 00       	call   ae1 <printf>
  }

  // TODO: delete init after cstarting
  cp(argv[2], "init");
 458:	8b 45 0c             	mov    0xc(%ebp),%eax
 45b:	83 c0 08             	add    $0x8,%eax
 45e:	8b 00                	mov    (%eax),%eax
 460:	c7 44 24 04 a3 0f 00 	movl   $0xfa3,0x4(%esp)
 467:	00 
 468:	89 04 24             	mov    %eax,(%esp)
 46b:	e8 b6 fb ff ff       	call   26 <cp>

  for (i = last_flag + 1, k = 0; i < argc; i++, k++) {
 470:	8b 45 ec             	mov    -0x14(%ebp),%eax
 473:	40                   	inc    %eax
 474:	89 45 f4             	mov    %eax,-0xc(%ebp)
 477:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 47e:	eb 65                	jmp    4e5 <create+0x2be>

    // TODO: move this into the kernel or the rest of ccreate out of the kernel
    if (cp(argv[2], argv[i]) != 1) 
 480:	8b 45 f4             	mov    -0xc(%ebp),%eax
 483:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 48a:	8b 45 0c             	mov    0xc(%ebp),%eax
 48d:	01 d0                	add    %edx,%eax
 48f:	8b 10                	mov    (%eax),%edx
 491:	8b 45 0c             	mov    0xc(%ebp),%eax
 494:	83 c0 08             	add    $0x8,%eax
 497:	8b 00                	mov    (%eax),%eax
 499:	89 54 24 04          	mov    %edx,0x4(%esp)
 49d:	89 04 24             	mov    %eax,(%esp)
 4a0:	e8 81 fb ff ff       	call   26 <cp>
 4a5:	83 f8 01             	cmp    $0x1,%eax
 4a8:	74 35                	je     4df <create+0x2b8>
      printf(1, "Failed to copy %s into folder %s. Continuing...\n", argv[i], argv[2]);
 4aa:	8b 45 0c             	mov    0xc(%ebp),%eax
 4ad:	83 c0 08             	add    $0x8,%eax
 4b0:	8b 10                	mov    (%eax),%edx
 4b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b5:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
 4bc:	8b 45 0c             	mov    0xc(%ebp),%eax
 4bf:	01 c8                	add    %ecx,%eax
 4c1:	8b 00                	mov    (%eax),%eax
 4c3:	89 54 24 0c          	mov    %edx,0xc(%esp)
 4c7:	89 44 24 08          	mov    %eax,0x8(%esp)
 4cb:	c7 44 24 04 a8 0f 00 	movl   $0xfa8,0x4(%esp)
 4d2:	00 
 4d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 4da:	e8 02 06 00 00       	call   ae1 <printf>
  }

  // TODO: delete init after cstarting
  cp(argv[2], "init");

  for (i = last_flag + 1, k = 0; i < argc; i++, k++) {
 4df:	ff 45 f4             	incl   -0xc(%ebp)
 4e2:	ff 45 f0             	incl   -0x10(%ebp)
 4e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4e8:	3b 45 08             	cmp    0x8(%ebp),%eax
 4eb:	7c 93                	jl     480 <create+0x259>
    
    // If we were using kernel for ccreate sys call
    // Change size of to strlen
    // progv[k] = malloc(sizeof(argv[i])); memmove(progv[k], argv[i], sizeof(argv[i])); memmove(progv[k] + sizeof(argv[i]), "\0", 1); printf(1, "\t%s\n", progv[k]);
  }  
}
 4ed:	c9                   	leave  
 4ee:	c3                   	ret    

000004ef <start>:

// ctool start <name> prog arg1 [arg2 ...]
// ctool start ctest1 echoloop ab
void
start(int argc, char *argv[])
{    
 4ef:	55                   	push   %ebp
 4f0:	89 e5                	mov    %esp,%ebp
 4f2:	53                   	push   %ebx
 4f3:	81 ec a4 00 00 00    	sub    $0xa4,%esp

  char *args[MAXARG];
  int i, k;

  if (argc < 4)
 4f9:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
 4fd:	7f 0c                	jg     50b <start+0x1c>
    usage("ctool start <name> prog arg1 [arg2 ...]");
 4ff:	c7 04 24 dc 0f 00 00 	movl   $0xfdc,(%esp)
 506:	e8 f5 fa ff ff       	call   0 <usage>

  for (i = 3, k = 0; i < argc; i++, k++) {
 50b:	c7 45 f4 03 00 00 00 	movl   $0x3,-0xc(%ebp)
 512:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 519:	e9 b5 00 00 00       	jmp    5d3 <start+0xe4>
    args[k] = malloc(strlen(argv[i]) + 1);     
 51e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 521:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 528:	8b 45 0c             	mov    0xc(%ebp),%eax
 52b:	01 d0                	add    %edx,%eax
 52d:	8b 00                	mov    (%eax),%eax
 52f:	89 04 24             	mov    %eax,(%esp)
 532:	e8 34 02 00 00       	call   76b <strlen>
 537:	40                   	inc    %eax
 538:	89 04 24             	mov    %eax,(%esp)
 53b:	e8 89 08 00 00       	call   dc9 <malloc>
 540:	8b 55 f0             	mov    -0x10(%ebp),%edx
 543:	89 84 95 70 ff ff ff 	mov    %eax,-0x90(%ebp,%edx,4)
    memmove(args[k], argv[i], strlen(argv[i])); 
 54a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 54d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 554:	8b 45 0c             	mov    0xc(%ebp),%eax
 557:	01 d0                	add    %edx,%eax
 559:	8b 00                	mov    (%eax),%eax
 55b:	89 04 24             	mov    %eax,(%esp)
 55e:	e8 08 02 00 00       	call   76b <strlen>
 563:	89 c1                	mov    %eax,%ecx
 565:	8b 45 f4             	mov    -0xc(%ebp),%eax
 568:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 56f:	8b 45 0c             	mov    0xc(%ebp),%eax
 572:	01 d0                	add    %edx,%eax
 574:	8b 10                	mov    (%eax),%edx
 576:	8b 45 f0             	mov    -0x10(%ebp),%eax
 579:	8b 84 85 70 ff ff ff 	mov    -0x90(%ebp,%eax,4),%eax
 580:	89 4c 24 08          	mov    %ecx,0x8(%esp)
 584:	89 54 24 04          	mov    %edx,0x4(%esp)
 588:	89 04 24             	mov    %eax,(%esp)
 58b:	e8 5d 03 00 00       	call   8ed <memmove>
    memmove(args[k] + strlen(argv[i]), "\0", 1);
 590:	8b 45 f0             	mov    -0x10(%ebp),%eax
 593:	8b 9c 85 70 ff ff ff 	mov    -0x90(%ebp,%eax,4),%ebx
 59a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 59d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 5a4:	8b 45 0c             	mov    0xc(%ebp),%eax
 5a7:	01 d0                	add    %edx,%eax
 5a9:	8b 00                	mov    (%eax),%eax
 5ab:	89 04 24             	mov    %eax,(%esp)
 5ae:	e8 b8 01 00 00       	call   76b <strlen>
 5b3:	01 d8                	add    %ebx,%eax
 5b5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5bc:	00 
 5bd:	c7 44 24 04 bb 0e 00 	movl   $0xebb,0x4(%esp)
 5c4:	00 
 5c5:	89 04 24             	mov    %eax,(%esp)
 5c8:	e8 20 03 00 00       	call   8ed <memmove>
  int i, k;

  if (argc < 4)
    usage("ctool start <name> prog arg1 [arg2 ...]");

  for (i = 3, k = 0; i < argc; i++, k++) {
 5cd:	ff 45 f4             	incl   -0xc(%ebp)
 5d0:	ff 45 f0             	incl   -0x10(%ebp)
 5d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d6:	3b 45 08             	cmp    0x8(%ebp),%eax
 5d9:	0f 8c 3f ff ff ff    	jl     51e <start+0x2f>
    args[k] = malloc(strlen(argv[i]) + 1);     
    memmove(args[k], argv[i], strlen(argv[i])); 
    memmove(args[k] + strlen(argv[i]), "\0", 1);
  }

  if (cstart(argv[2], args, (argc - 3)) != 1) 
 5df:	8b 45 08             	mov    0x8(%ebp),%eax
 5e2:	8d 50 fd             	lea    -0x3(%eax),%edx
 5e5:	8b 45 0c             	mov    0xc(%ebp),%eax
 5e8:	83 c0 08             	add    $0x8,%eax
 5eb:	8b 00                	mov    (%eax),%eax
 5ed:	89 54 24 08          	mov    %edx,0x8(%esp)
 5f1:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
 5f7:	89 54 24 04          	mov    %edx,0x4(%esp)
 5fb:	89 04 24             	mov    %eax,(%esp)
 5fe:	e8 e1 03 00 00       	call   9e4 <cstart>
 603:	83 f8 01             	cmp    $0x1,%eax
 606:	74 20                	je     628 <start+0x139>
    printf(1, "Failed to start container %s\n", argv[2]);     
 608:	8b 45 0c             	mov    0xc(%ebp),%eax
 60b:	83 c0 08             	add    $0x8,%eax
 60e:	8b 00                	mov    (%eax),%eax
 610:	89 44 24 08          	mov    %eax,0x8(%esp)
 614:	c7 44 24 04 04 10 00 	movl   $0x1004,0x4(%esp)
 61b:	00 
 61c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 623:	e8 b9 04 00 00       	call   ae1 <printf>
}
 628:	81 c4 a4 00 00 00    	add    $0xa4,%esp
 62e:	5b                   	pop    %ebx
 62f:	5d                   	pop    %ebp
 630:	c3                   	ret    

00000631 <pause>:

void
pause(int argc, char *argv[])
{
 631:	55                   	push   %ebp
 632:	89 e5                	mov    %esp,%ebp
  
}
 634:	5d                   	pop    %ebp
 635:	c3                   	ret    

00000636 <resume>:

void
resume(int argc, char *argv[])
{
 636:	55                   	push   %ebp
 637:	89 e5                	mov    %esp,%ebp
  
}
 639:	5d                   	pop    %ebp
 63a:	c3                   	ret    

0000063b <stop>:

void
stop(int argc, char *argv[])
{
 63b:	55                   	push   %ebp
 63c:	89 e5                	mov    %esp,%ebp
  
}
 63e:	5d                   	pop    %ebp
 63f:	c3                   	ret    

00000640 <info>:

void
info(int argc, char *argv[])
{
 640:	55                   	push   %ebp
 641:	89 e5                	mov    %esp,%ebp
  
}
 643:	5d                   	pop    %ebp
 644:	c3                   	ret    

00000645 <main>:

int
main(int argc, char *argv[])
{
 645:	55                   	push   %ebp
 646:	89 e5                	mov    %esp,%ebp
 648:	83 e4 f0             	and    $0xfffffff0,%esp
 64b:	83 ec 10             	sub    $0x10,%esp

  if (argc < 3) {
 64e:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 652:	7f 11                	jg     665 <main+0x20>
    usage("<tool> <cmd> [<arg> ...]");
 654:	c7 04 24 22 10 00 00 	movl   $0x1022,(%esp)
 65b:	e8 a0 f9 ff ff       	call   0 <usage>
    exit();
 660:	e8 cf 02 00 00       	call   934 <exit>
  }

  if (strcmp(argv[1], "create") == 0)
 665:	8b 45 0c             	mov    0xc(%ebp),%eax
 668:	83 c0 04             	add    $0x4,%eax
 66b:	8b 00                	mov    (%eax),%eax
 66d:	c7 44 24 04 3b 10 00 	movl   $0x103b,0x4(%esp)
 674:	00 
 675:	89 04 24             	mov    %eax,(%esp)
 678:	e8 b6 00 00 00       	call   733 <strcmp>
 67d:	85 c0                	test   %eax,%eax
 67f:	75 14                	jne    695 <main+0x50>
    create(argc, argv);
 681:	8b 45 0c             	mov    0xc(%ebp),%eax
 684:	89 44 24 04          	mov    %eax,0x4(%esp)
 688:	8b 45 08             	mov    0x8(%ebp),%eax
 68b:	89 04 24             	mov    %eax,(%esp)
 68e:	e8 94 fb ff ff       	call   227 <create>
 693:	eb 44                	jmp    6d9 <main+0x94>
  else if (strcmp(argv[1], "start") == 0)
 695:	8b 45 0c             	mov    0xc(%ebp),%eax
 698:	83 c0 04             	add    $0x4,%eax
 69b:	8b 00                	mov    (%eax),%eax
 69d:	c7 44 24 04 42 10 00 	movl   $0x1042,0x4(%esp)
 6a4:	00 
 6a5:	89 04 24             	mov    %eax,(%esp)
 6a8:	e8 86 00 00 00       	call   733 <strcmp>
 6ad:	85 c0                	test   %eax,%eax
 6af:	75 14                	jne    6c5 <main+0x80>
    start(argc, argv);
 6b1:	8b 45 0c             	mov    0xc(%ebp),%eax
 6b4:	89 44 24 04          	mov    %eax,0x4(%esp)
 6b8:	8b 45 08             	mov    0x8(%ebp),%eax
 6bb:	89 04 24             	mov    %eax,(%esp)
 6be:	e8 2c fe ff ff       	call   4ef <start>
 6c3:	eb 14                	jmp    6d9 <main+0x94>
  else 
    printf(1, "ctool: command not found.\n");   
 6c5:	c7 44 24 04 48 10 00 	movl   $0x1048,0x4(%esp)
 6cc:	00 
 6cd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 6d4:	e8 08 04 00 00       	call   ae1 <printf>

  exit();
 6d9:	e8 56 02 00 00       	call   934 <exit>
 6de:	90                   	nop
 6df:	90                   	nop

000006e0 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 6e0:	55                   	push   %ebp
 6e1:	89 e5                	mov    %esp,%ebp
 6e3:	57                   	push   %edi
 6e4:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 6e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
 6e8:	8b 55 10             	mov    0x10(%ebp),%edx
 6eb:	8b 45 0c             	mov    0xc(%ebp),%eax
 6ee:	89 cb                	mov    %ecx,%ebx
 6f0:	89 df                	mov    %ebx,%edi
 6f2:	89 d1                	mov    %edx,%ecx
 6f4:	fc                   	cld    
 6f5:	f3 aa                	rep stos %al,%es:(%edi)
 6f7:	89 ca                	mov    %ecx,%edx
 6f9:	89 fb                	mov    %edi,%ebx
 6fb:	89 5d 08             	mov    %ebx,0x8(%ebp)
 6fe:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 701:	5b                   	pop    %ebx
 702:	5f                   	pop    %edi
 703:	5d                   	pop    %ebp
 704:	c3                   	ret    

00000705 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 705:	55                   	push   %ebp
 706:	89 e5                	mov    %esp,%ebp
 708:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 70b:	8b 45 08             	mov    0x8(%ebp),%eax
 70e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 711:	90                   	nop
 712:	8b 45 08             	mov    0x8(%ebp),%eax
 715:	8d 50 01             	lea    0x1(%eax),%edx
 718:	89 55 08             	mov    %edx,0x8(%ebp)
 71b:	8b 55 0c             	mov    0xc(%ebp),%edx
 71e:	8d 4a 01             	lea    0x1(%edx),%ecx
 721:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 724:	8a 12                	mov    (%edx),%dl
 726:	88 10                	mov    %dl,(%eax)
 728:	8a 00                	mov    (%eax),%al
 72a:	84 c0                	test   %al,%al
 72c:	75 e4                	jne    712 <strcpy+0xd>
    ;
  return os;
 72e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 731:	c9                   	leave  
 732:	c3                   	ret    

00000733 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 733:	55                   	push   %ebp
 734:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 736:	eb 06                	jmp    73e <strcmp+0xb>
    p++, q++;
 738:	ff 45 08             	incl   0x8(%ebp)
 73b:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 73e:	8b 45 08             	mov    0x8(%ebp),%eax
 741:	8a 00                	mov    (%eax),%al
 743:	84 c0                	test   %al,%al
 745:	74 0e                	je     755 <strcmp+0x22>
 747:	8b 45 08             	mov    0x8(%ebp),%eax
 74a:	8a 10                	mov    (%eax),%dl
 74c:	8b 45 0c             	mov    0xc(%ebp),%eax
 74f:	8a 00                	mov    (%eax),%al
 751:	38 c2                	cmp    %al,%dl
 753:	74 e3                	je     738 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 755:	8b 45 08             	mov    0x8(%ebp),%eax
 758:	8a 00                	mov    (%eax),%al
 75a:	0f b6 d0             	movzbl %al,%edx
 75d:	8b 45 0c             	mov    0xc(%ebp),%eax
 760:	8a 00                	mov    (%eax),%al
 762:	0f b6 c0             	movzbl %al,%eax
 765:	29 c2                	sub    %eax,%edx
 767:	89 d0                	mov    %edx,%eax
}
 769:	5d                   	pop    %ebp
 76a:	c3                   	ret    

0000076b <strlen>:

uint
strlen(char *s)
{
 76b:	55                   	push   %ebp
 76c:	89 e5                	mov    %esp,%ebp
 76e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 771:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 778:	eb 03                	jmp    77d <strlen+0x12>
 77a:	ff 45 fc             	incl   -0x4(%ebp)
 77d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 780:	8b 45 08             	mov    0x8(%ebp),%eax
 783:	01 d0                	add    %edx,%eax
 785:	8a 00                	mov    (%eax),%al
 787:	84 c0                	test   %al,%al
 789:	75 ef                	jne    77a <strlen+0xf>
    ;
  return n;
 78b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 78e:	c9                   	leave  
 78f:	c3                   	ret    

00000790 <memset>:

void*
memset(void *dst, int c, uint n)
{
 790:	55                   	push   %ebp
 791:	89 e5                	mov    %esp,%ebp
 793:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 796:	8b 45 10             	mov    0x10(%ebp),%eax
 799:	89 44 24 08          	mov    %eax,0x8(%esp)
 79d:	8b 45 0c             	mov    0xc(%ebp),%eax
 7a0:	89 44 24 04          	mov    %eax,0x4(%esp)
 7a4:	8b 45 08             	mov    0x8(%ebp),%eax
 7a7:	89 04 24             	mov    %eax,(%esp)
 7aa:	e8 31 ff ff ff       	call   6e0 <stosb>
  return dst;
 7af:	8b 45 08             	mov    0x8(%ebp),%eax
}
 7b2:	c9                   	leave  
 7b3:	c3                   	ret    

000007b4 <strchr>:

char*
strchr(const char *s, char c)
{
 7b4:	55                   	push   %ebp
 7b5:	89 e5                	mov    %esp,%ebp
 7b7:	83 ec 04             	sub    $0x4,%esp
 7ba:	8b 45 0c             	mov    0xc(%ebp),%eax
 7bd:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 7c0:	eb 12                	jmp    7d4 <strchr+0x20>
    if(*s == c)
 7c2:	8b 45 08             	mov    0x8(%ebp),%eax
 7c5:	8a 00                	mov    (%eax),%al
 7c7:	3a 45 fc             	cmp    -0x4(%ebp),%al
 7ca:	75 05                	jne    7d1 <strchr+0x1d>
      return (char*)s;
 7cc:	8b 45 08             	mov    0x8(%ebp),%eax
 7cf:	eb 11                	jmp    7e2 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 7d1:	ff 45 08             	incl   0x8(%ebp)
 7d4:	8b 45 08             	mov    0x8(%ebp),%eax
 7d7:	8a 00                	mov    (%eax),%al
 7d9:	84 c0                	test   %al,%al
 7db:	75 e5                	jne    7c2 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 7dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
 7e2:	c9                   	leave  
 7e3:	c3                   	ret    

000007e4 <gets>:

char*
gets(char *buf, int max)
{
 7e4:	55                   	push   %ebp
 7e5:	89 e5                	mov    %esp,%ebp
 7e7:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 7ea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 7f1:	eb 49                	jmp    83c <gets+0x58>
    cc = read(0, &c, 1);
 7f3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 7fa:	00 
 7fb:	8d 45 ef             	lea    -0x11(%ebp),%eax
 7fe:	89 44 24 04          	mov    %eax,0x4(%esp)
 802:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 809:	e8 3e 01 00 00       	call   94c <read>
 80e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 811:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 815:	7f 02                	jg     819 <gets+0x35>
      break;
 817:	eb 2c                	jmp    845 <gets+0x61>
    buf[i++] = c;
 819:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81c:	8d 50 01             	lea    0x1(%eax),%edx
 81f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 822:	89 c2                	mov    %eax,%edx
 824:	8b 45 08             	mov    0x8(%ebp),%eax
 827:	01 c2                	add    %eax,%edx
 829:	8a 45 ef             	mov    -0x11(%ebp),%al
 82c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 82e:	8a 45 ef             	mov    -0x11(%ebp),%al
 831:	3c 0a                	cmp    $0xa,%al
 833:	74 10                	je     845 <gets+0x61>
 835:	8a 45 ef             	mov    -0x11(%ebp),%al
 838:	3c 0d                	cmp    $0xd,%al
 83a:	74 09                	je     845 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 83c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83f:	40                   	inc    %eax
 840:	3b 45 0c             	cmp    0xc(%ebp),%eax
 843:	7c ae                	jl     7f3 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 845:	8b 55 f4             	mov    -0xc(%ebp),%edx
 848:	8b 45 08             	mov    0x8(%ebp),%eax
 84b:	01 d0                	add    %edx,%eax
 84d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 850:	8b 45 08             	mov    0x8(%ebp),%eax
}
 853:	c9                   	leave  
 854:	c3                   	ret    

00000855 <stat>:

int
stat(char *n, struct stat *st)
{
 855:	55                   	push   %ebp
 856:	89 e5                	mov    %esp,%ebp
 858:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 85b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 862:	00 
 863:	8b 45 08             	mov    0x8(%ebp),%eax
 866:	89 04 24             	mov    %eax,(%esp)
 869:	e8 06 01 00 00       	call   974 <open>
 86e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 871:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 875:	79 07                	jns    87e <stat+0x29>
    return -1;
 877:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 87c:	eb 23                	jmp    8a1 <stat+0x4c>
  r = fstat(fd, st);
 87e:	8b 45 0c             	mov    0xc(%ebp),%eax
 881:	89 44 24 04          	mov    %eax,0x4(%esp)
 885:	8b 45 f4             	mov    -0xc(%ebp),%eax
 888:	89 04 24             	mov    %eax,(%esp)
 88b:	e8 fc 00 00 00       	call   98c <fstat>
 890:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 893:	8b 45 f4             	mov    -0xc(%ebp),%eax
 896:	89 04 24             	mov    %eax,(%esp)
 899:	e8 be 00 00 00       	call   95c <close>
  return r;
 89e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 8a1:	c9                   	leave  
 8a2:	c3                   	ret    

000008a3 <atoi>:

int
atoi(const char *s)
{
 8a3:	55                   	push   %ebp
 8a4:	89 e5                	mov    %esp,%ebp
 8a6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 8a9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 8b0:	eb 24                	jmp    8d6 <atoi+0x33>
    n = n*10 + *s++ - '0';
 8b2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 8b5:	89 d0                	mov    %edx,%eax
 8b7:	c1 e0 02             	shl    $0x2,%eax
 8ba:	01 d0                	add    %edx,%eax
 8bc:	01 c0                	add    %eax,%eax
 8be:	89 c1                	mov    %eax,%ecx
 8c0:	8b 45 08             	mov    0x8(%ebp),%eax
 8c3:	8d 50 01             	lea    0x1(%eax),%edx
 8c6:	89 55 08             	mov    %edx,0x8(%ebp)
 8c9:	8a 00                	mov    (%eax),%al
 8cb:	0f be c0             	movsbl %al,%eax
 8ce:	01 c8                	add    %ecx,%eax
 8d0:	83 e8 30             	sub    $0x30,%eax
 8d3:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 8d6:	8b 45 08             	mov    0x8(%ebp),%eax
 8d9:	8a 00                	mov    (%eax),%al
 8db:	3c 2f                	cmp    $0x2f,%al
 8dd:	7e 09                	jle    8e8 <atoi+0x45>
 8df:	8b 45 08             	mov    0x8(%ebp),%eax
 8e2:	8a 00                	mov    (%eax),%al
 8e4:	3c 39                	cmp    $0x39,%al
 8e6:	7e ca                	jle    8b2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 8e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 8eb:	c9                   	leave  
 8ec:	c3                   	ret    

000008ed <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 8ed:	55                   	push   %ebp
 8ee:	89 e5                	mov    %esp,%ebp
 8f0:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 8f3:	8b 45 08             	mov    0x8(%ebp),%eax
 8f6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 8f9:	8b 45 0c             	mov    0xc(%ebp),%eax
 8fc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 8ff:	eb 16                	jmp    917 <memmove+0x2a>
    *dst++ = *src++;
 901:	8b 45 fc             	mov    -0x4(%ebp),%eax
 904:	8d 50 01             	lea    0x1(%eax),%edx
 907:	89 55 fc             	mov    %edx,-0x4(%ebp)
 90a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 90d:	8d 4a 01             	lea    0x1(%edx),%ecx
 910:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 913:	8a 12                	mov    (%edx),%dl
 915:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 917:	8b 45 10             	mov    0x10(%ebp),%eax
 91a:	8d 50 ff             	lea    -0x1(%eax),%edx
 91d:	89 55 10             	mov    %edx,0x10(%ebp)
 920:	85 c0                	test   %eax,%eax
 922:	7f dd                	jg     901 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 924:	8b 45 08             	mov    0x8(%ebp),%eax
}
 927:	c9                   	leave  
 928:	c3                   	ret    
 929:	90                   	nop
 92a:	90                   	nop
 92b:	90                   	nop

0000092c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 92c:	b8 01 00 00 00       	mov    $0x1,%eax
 931:	cd 40                	int    $0x40
 933:	c3                   	ret    

00000934 <exit>:
SYSCALL(exit)
 934:	b8 02 00 00 00       	mov    $0x2,%eax
 939:	cd 40                	int    $0x40
 93b:	c3                   	ret    

0000093c <wait>:
SYSCALL(wait)
 93c:	b8 03 00 00 00       	mov    $0x3,%eax
 941:	cd 40                	int    $0x40
 943:	c3                   	ret    

00000944 <pipe>:
SYSCALL(pipe)
 944:	b8 04 00 00 00       	mov    $0x4,%eax
 949:	cd 40                	int    $0x40
 94b:	c3                   	ret    

0000094c <read>:
SYSCALL(read)
 94c:	b8 05 00 00 00       	mov    $0x5,%eax
 951:	cd 40                	int    $0x40
 953:	c3                   	ret    

00000954 <write>:
SYSCALL(write)
 954:	b8 10 00 00 00       	mov    $0x10,%eax
 959:	cd 40                	int    $0x40
 95b:	c3                   	ret    

0000095c <close>:
SYSCALL(close)
 95c:	b8 15 00 00 00       	mov    $0x15,%eax
 961:	cd 40                	int    $0x40
 963:	c3                   	ret    

00000964 <kill>:
SYSCALL(kill)
 964:	b8 06 00 00 00       	mov    $0x6,%eax
 969:	cd 40                	int    $0x40
 96b:	c3                   	ret    

0000096c <exec>:
SYSCALL(exec)
 96c:	b8 07 00 00 00       	mov    $0x7,%eax
 971:	cd 40                	int    $0x40
 973:	c3                   	ret    

00000974 <open>:
SYSCALL(open)
 974:	b8 0f 00 00 00       	mov    $0xf,%eax
 979:	cd 40                	int    $0x40
 97b:	c3                   	ret    

0000097c <mknod>:
SYSCALL(mknod)
 97c:	b8 11 00 00 00       	mov    $0x11,%eax
 981:	cd 40                	int    $0x40
 983:	c3                   	ret    

00000984 <unlink>:
SYSCALL(unlink)
 984:	b8 12 00 00 00       	mov    $0x12,%eax
 989:	cd 40                	int    $0x40
 98b:	c3                   	ret    

0000098c <fstat>:
SYSCALL(fstat)
 98c:	b8 08 00 00 00       	mov    $0x8,%eax
 991:	cd 40                	int    $0x40
 993:	c3                   	ret    

00000994 <link>:
SYSCALL(link)
 994:	b8 13 00 00 00       	mov    $0x13,%eax
 999:	cd 40                	int    $0x40
 99b:	c3                   	ret    

0000099c <mkdir>:
SYSCALL(mkdir)
 99c:	b8 14 00 00 00       	mov    $0x14,%eax
 9a1:	cd 40                	int    $0x40
 9a3:	c3                   	ret    

000009a4 <chdir>:
SYSCALL(chdir)
 9a4:	b8 09 00 00 00       	mov    $0x9,%eax
 9a9:	cd 40                	int    $0x40
 9ab:	c3                   	ret    

000009ac <dup>:
SYSCALL(dup)
 9ac:	b8 0a 00 00 00       	mov    $0xa,%eax
 9b1:	cd 40                	int    $0x40
 9b3:	c3                   	ret    

000009b4 <getpid>:
SYSCALL(getpid)
 9b4:	b8 0b 00 00 00       	mov    $0xb,%eax
 9b9:	cd 40                	int    $0x40
 9bb:	c3                   	ret    

000009bc <sbrk>:
SYSCALL(sbrk)
 9bc:	b8 0c 00 00 00       	mov    $0xc,%eax
 9c1:	cd 40                	int    $0x40
 9c3:	c3                   	ret    

000009c4 <sleep>:
SYSCALL(sleep)
 9c4:	b8 0d 00 00 00       	mov    $0xd,%eax
 9c9:	cd 40                	int    $0x40
 9cb:	c3                   	ret    

000009cc <uptime>:
SYSCALL(uptime)
 9cc:	b8 0e 00 00 00       	mov    $0xe,%eax
 9d1:	cd 40                	int    $0x40
 9d3:	c3                   	ret    

000009d4 <getticks>:
SYSCALL(getticks)
 9d4:	b8 16 00 00 00       	mov    $0x16,%eax
 9d9:	cd 40                	int    $0x40
 9db:	c3                   	ret    

000009dc <ccreate>:
SYSCALL(ccreate)
 9dc:	b8 17 00 00 00       	mov    $0x17,%eax
 9e1:	cd 40                	int    $0x40
 9e3:	c3                   	ret    

000009e4 <cstart>:
SYSCALL(cstart)
 9e4:	b8 19 00 00 00       	mov    $0x19,%eax
 9e9:	cd 40                	int    $0x40
 9eb:	c3                   	ret    

000009ec <cstop>:
SYSCALL(cstop)
 9ec:	b8 18 00 00 00       	mov    $0x18,%eax
 9f1:	cd 40                	int    $0x40
 9f3:	c3                   	ret    

000009f4 <cpause>:
SYSCALL(cpause)
 9f4:	b8 1b 00 00 00       	mov    $0x1b,%eax
 9f9:	cd 40                	int    $0x40
 9fb:	c3                   	ret    

000009fc <cinfo>:
SYSCALL(cinfo)
 9fc:	b8 1a 00 00 00       	mov    $0x1a,%eax
 a01:	cd 40                	int    $0x40
 a03:	c3                   	ret    

00000a04 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 a04:	55                   	push   %ebp
 a05:	89 e5                	mov    %esp,%ebp
 a07:	83 ec 18             	sub    $0x18,%esp
 a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
 a0d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 a10:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 a17:	00 
 a18:	8d 45 f4             	lea    -0xc(%ebp),%eax
 a1b:	89 44 24 04          	mov    %eax,0x4(%esp)
 a1f:	8b 45 08             	mov    0x8(%ebp),%eax
 a22:	89 04 24             	mov    %eax,(%esp)
 a25:	e8 2a ff ff ff       	call   954 <write>
}
 a2a:	c9                   	leave  
 a2b:	c3                   	ret    

00000a2c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 a2c:	55                   	push   %ebp
 a2d:	89 e5                	mov    %esp,%ebp
 a2f:	56                   	push   %esi
 a30:	53                   	push   %ebx
 a31:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 a34:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 a3b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 a3f:	74 17                	je     a58 <printint+0x2c>
 a41:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 a45:	79 11                	jns    a58 <printint+0x2c>
    neg = 1;
 a47:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 a4e:	8b 45 0c             	mov    0xc(%ebp),%eax
 a51:	f7 d8                	neg    %eax
 a53:	89 45 ec             	mov    %eax,-0x14(%ebp)
 a56:	eb 06                	jmp    a5e <printint+0x32>
  } else {
    x = xx;
 a58:	8b 45 0c             	mov    0xc(%ebp),%eax
 a5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 a5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 a65:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 a68:	8d 41 01             	lea    0x1(%ecx),%eax
 a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
 a71:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a74:	ba 00 00 00 00       	mov    $0x0,%edx
 a79:	f7 f3                	div    %ebx
 a7b:	89 d0                	mov    %edx,%eax
 a7d:	8a 80 e4 13 00 00    	mov    0x13e4(%eax),%al
 a83:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 a87:	8b 75 10             	mov    0x10(%ebp),%esi
 a8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a8d:	ba 00 00 00 00       	mov    $0x0,%edx
 a92:	f7 f6                	div    %esi
 a94:	89 45 ec             	mov    %eax,-0x14(%ebp)
 a97:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 a9b:	75 c8                	jne    a65 <printint+0x39>
  if(neg)
 a9d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 aa1:	74 10                	je     ab3 <printint+0x87>
    buf[i++] = '-';
 aa3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa6:	8d 50 01             	lea    0x1(%eax),%edx
 aa9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 aac:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 ab1:	eb 1e                	jmp    ad1 <printint+0xa5>
 ab3:	eb 1c                	jmp    ad1 <printint+0xa5>
    putc(fd, buf[i]);
 ab5:	8d 55 dc             	lea    -0x24(%ebp),%edx
 ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abb:	01 d0                	add    %edx,%eax
 abd:	8a 00                	mov    (%eax),%al
 abf:	0f be c0             	movsbl %al,%eax
 ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
 ac6:	8b 45 08             	mov    0x8(%ebp),%eax
 ac9:	89 04 24             	mov    %eax,(%esp)
 acc:	e8 33 ff ff ff       	call   a04 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 ad1:	ff 4d f4             	decl   -0xc(%ebp)
 ad4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ad8:	79 db                	jns    ab5 <printint+0x89>
    putc(fd, buf[i]);
}
 ada:	83 c4 30             	add    $0x30,%esp
 add:	5b                   	pop    %ebx
 ade:	5e                   	pop    %esi
 adf:	5d                   	pop    %ebp
 ae0:	c3                   	ret    

00000ae1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 ae1:	55                   	push   %ebp
 ae2:	89 e5                	mov    %esp,%ebp
 ae4:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 ae7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 aee:	8d 45 0c             	lea    0xc(%ebp),%eax
 af1:	83 c0 04             	add    $0x4,%eax
 af4:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 af7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 afe:	e9 77 01 00 00       	jmp    c7a <printf+0x199>
    c = fmt[i] & 0xff;
 b03:	8b 55 0c             	mov    0xc(%ebp),%edx
 b06:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b09:	01 d0                	add    %edx,%eax
 b0b:	8a 00                	mov    (%eax),%al
 b0d:	0f be c0             	movsbl %al,%eax
 b10:	25 ff 00 00 00       	and    $0xff,%eax
 b15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 b18:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 b1c:	75 2c                	jne    b4a <printf+0x69>
      if(c == '%'){
 b1e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 b22:	75 0c                	jne    b30 <printf+0x4f>
        state = '%';
 b24:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 b2b:	e9 47 01 00 00       	jmp    c77 <printf+0x196>
      } else {
        putc(fd, c);
 b30:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b33:	0f be c0             	movsbl %al,%eax
 b36:	89 44 24 04          	mov    %eax,0x4(%esp)
 b3a:	8b 45 08             	mov    0x8(%ebp),%eax
 b3d:	89 04 24             	mov    %eax,(%esp)
 b40:	e8 bf fe ff ff       	call   a04 <putc>
 b45:	e9 2d 01 00 00       	jmp    c77 <printf+0x196>
      }
    } else if(state == '%'){
 b4a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 b4e:	0f 85 23 01 00 00    	jne    c77 <printf+0x196>
      if(c == 'd'){
 b54:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 b58:	75 2d                	jne    b87 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 b5a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b5d:	8b 00                	mov    (%eax),%eax
 b5f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 b66:	00 
 b67:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 b6e:	00 
 b6f:	89 44 24 04          	mov    %eax,0x4(%esp)
 b73:	8b 45 08             	mov    0x8(%ebp),%eax
 b76:	89 04 24             	mov    %eax,(%esp)
 b79:	e8 ae fe ff ff       	call   a2c <printint>
        ap++;
 b7e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b82:	e9 e9 00 00 00       	jmp    c70 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 b87:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 b8b:	74 06                	je     b93 <printf+0xb2>
 b8d:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 b91:	75 2d                	jne    bc0 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 b93:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b96:	8b 00                	mov    (%eax),%eax
 b98:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 b9f:	00 
 ba0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 ba7:	00 
 ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
 bac:	8b 45 08             	mov    0x8(%ebp),%eax
 baf:	89 04 24             	mov    %eax,(%esp)
 bb2:	e8 75 fe ff ff       	call   a2c <printint>
        ap++;
 bb7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 bbb:	e9 b0 00 00 00       	jmp    c70 <printf+0x18f>
      } else if(c == 's'){
 bc0:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 bc4:	75 42                	jne    c08 <printf+0x127>
        s = (char*)*ap;
 bc6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 bc9:	8b 00                	mov    (%eax),%eax
 bcb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 bce:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 bd2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 bd6:	75 09                	jne    be1 <printf+0x100>
          s = "(null)";
 bd8:	c7 45 f4 63 10 00 00 	movl   $0x1063,-0xc(%ebp)
        while(*s != 0){
 bdf:	eb 1c                	jmp    bfd <printf+0x11c>
 be1:	eb 1a                	jmp    bfd <printf+0x11c>
          putc(fd, *s);
 be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 be6:	8a 00                	mov    (%eax),%al
 be8:	0f be c0             	movsbl %al,%eax
 beb:	89 44 24 04          	mov    %eax,0x4(%esp)
 bef:	8b 45 08             	mov    0x8(%ebp),%eax
 bf2:	89 04 24             	mov    %eax,(%esp)
 bf5:	e8 0a fe ff ff       	call   a04 <putc>
          s++;
 bfa:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 bfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c00:	8a 00                	mov    (%eax),%al
 c02:	84 c0                	test   %al,%al
 c04:	75 dd                	jne    be3 <printf+0x102>
 c06:	eb 68                	jmp    c70 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 c08:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 c0c:	75 1d                	jne    c2b <printf+0x14a>
        putc(fd, *ap);
 c0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 c11:	8b 00                	mov    (%eax),%eax
 c13:	0f be c0             	movsbl %al,%eax
 c16:	89 44 24 04          	mov    %eax,0x4(%esp)
 c1a:	8b 45 08             	mov    0x8(%ebp),%eax
 c1d:	89 04 24             	mov    %eax,(%esp)
 c20:	e8 df fd ff ff       	call   a04 <putc>
        ap++;
 c25:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 c29:	eb 45                	jmp    c70 <printf+0x18f>
      } else if(c == '%'){
 c2b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 c2f:	75 17                	jne    c48 <printf+0x167>
        putc(fd, c);
 c31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 c34:	0f be c0             	movsbl %al,%eax
 c37:	89 44 24 04          	mov    %eax,0x4(%esp)
 c3b:	8b 45 08             	mov    0x8(%ebp),%eax
 c3e:	89 04 24             	mov    %eax,(%esp)
 c41:	e8 be fd ff ff       	call   a04 <putc>
 c46:	eb 28                	jmp    c70 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 c48:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 c4f:	00 
 c50:	8b 45 08             	mov    0x8(%ebp),%eax
 c53:	89 04 24             	mov    %eax,(%esp)
 c56:	e8 a9 fd ff ff       	call   a04 <putc>
        putc(fd, c);
 c5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 c5e:	0f be c0             	movsbl %al,%eax
 c61:	89 44 24 04          	mov    %eax,0x4(%esp)
 c65:	8b 45 08             	mov    0x8(%ebp),%eax
 c68:	89 04 24             	mov    %eax,(%esp)
 c6b:	e8 94 fd ff ff       	call   a04 <putc>
      }
      state = 0;
 c70:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 c77:	ff 45 f0             	incl   -0x10(%ebp)
 c7a:	8b 55 0c             	mov    0xc(%ebp),%edx
 c7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c80:	01 d0                	add    %edx,%eax
 c82:	8a 00                	mov    (%eax),%al
 c84:	84 c0                	test   %al,%al
 c86:	0f 85 77 fe ff ff    	jne    b03 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 c8c:	c9                   	leave  
 c8d:	c3                   	ret    
 c8e:	90                   	nop
 c8f:	90                   	nop

00000c90 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 c90:	55                   	push   %ebp
 c91:	89 e5                	mov    %esp,%ebp
 c93:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 c96:	8b 45 08             	mov    0x8(%ebp),%eax
 c99:	83 e8 08             	sub    $0x8,%eax
 c9c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c9f:	a1 00 14 00 00       	mov    0x1400,%eax
 ca4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ca7:	eb 24                	jmp    ccd <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ca9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cac:	8b 00                	mov    (%eax),%eax
 cae:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 cb1:	77 12                	ja     cc5 <free+0x35>
 cb3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cb6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 cb9:	77 24                	ja     cdf <free+0x4f>
 cbb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cbe:	8b 00                	mov    (%eax),%eax
 cc0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 cc3:	77 1a                	ja     cdf <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 cc5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cc8:	8b 00                	mov    (%eax),%eax
 cca:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ccd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cd0:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 cd3:	76 d4                	jbe    ca9 <free+0x19>
 cd5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cd8:	8b 00                	mov    (%eax),%eax
 cda:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 cdd:	76 ca                	jbe    ca9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 cdf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ce2:	8b 40 04             	mov    0x4(%eax),%eax
 ce5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 cec:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cef:	01 c2                	add    %eax,%edx
 cf1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cf4:	8b 00                	mov    (%eax),%eax
 cf6:	39 c2                	cmp    %eax,%edx
 cf8:	75 24                	jne    d1e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 cfa:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cfd:	8b 50 04             	mov    0x4(%eax),%edx
 d00:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d03:	8b 00                	mov    (%eax),%eax
 d05:	8b 40 04             	mov    0x4(%eax),%eax
 d08:	01 c2                	add    %eax,%edx
 d0a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d0d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 d10:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d13:	8b 00                	mov    (%eax),%eax
 d15:	8b 10                	mov    (%eax),%edx
 d17:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d1a:	89 10                	mov    %edx,(%eax)
 d1c:	eb 0a                	jmp    d28 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 d1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d21:	8b 10                	mov    (%eax),%edx
 d23:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d26:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 d28:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d2b:	8b 40 04             	mov    0x4(%eax),%eax
 d2e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 d35:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d38:	01 d0                	add    %edx,%eax
 d3a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 d3d:	75 20                	jne    d5f <free+0xcf>
    p->s.size += bp->s.size;
 d3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d42:	8b 50 04             	mov    0x4(%eax),%edx
 d45:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d48:	8b 40 04             	mov    0x4(%eax),%eax
 d4b:	01 c2                	add    %eax,%edx
 d4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d50:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 d53:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d56:	8b 10                	mov    (%eax),%edx
 d58:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d5b:	89 10                	mov    %edx,(%eax)
 d5d:	eb 08                	jmp    d67 <free+0xd7>
  } else
    p->s.ptr = bp;
 d5f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d62:	8b 55 f8             	mov    -0x8(%ebp),%edx
 d65:	89 10                	mov    %edx,(%eax)
  freep = p;
 d67:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d6a:	a3 00 14 00 00       	mov    %eax,0x1400
}
 d6f:	c9                   	leave  
 d70:	c3                   	ret    

00000d71 <morecore>:

static Header*
morecore(uint nu)
{
 d71:	55                   	push   %ebp
 d72:	89 e5                	mov    %esp,%ebp
 d74:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 d77:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 d7e:	77 07                	ja     d87 <morecore+0x16>
    nu = 4096;
 d80:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 d87:	8b 45 08             	mov    0x8(%ebp),%eax
 d8a:	c1 e0 03             	shl    $0x3,%eax
 d8d:	89 04 24             	mov    %eax,(%esp)
 d90:	e8 27 fc ff ff       	call   9bc <sbrk>
 d95:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 d98:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 d9c:	75 07                	jne    da5 <morecore+0x34>
    return 0;
 d9e:	b8 00 00 00 00       	mov    $0x0,%eax
 da3:	eb 22                	jmp    dc7 <morecore+0x56>
  hp = (Header*)p;
 da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 da8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 dab:	8b 45 f0             	mov    -0x10(%ebp),%eax
 dae:	8b 55 08             	mov    0x8(%ebp),%edx
 db1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 db4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 db7:	83 c0 08             	add    $0x8,%eax
 dba:	89 04 24             	mov    %eax,(%esp)
 dbd:	e8 ce fe ff ff       	call   c90 <free>
  return freep;
 dc2:	a1 00 14 00 00       	mov    0x1400,%eax
}
 dc7:	c9                   	leave  
 dc8:	c3                   	ret    

00000dc9 <malloc>:

void*
malloc(uint nbytes)
{
 dc9:	55                   	push   %ebp
 dca:	89 e5                	mov    %esp,%ebp
 dcc:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 dcf:	8b 45 08             	mov    0x8(%ebp),%eax
 dd2:	83 c0 07             	add    $0x7,%eax
 dd5:	c1 e8 03             	shr    $0x3,%eax
 dd8:	40                   	inc    %eax
 dd9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 ddc:	a1 00 14 00 00       	mov    0x1400,%eax
 de1:	89 45 f0             	mov    %eax,-0x10(%ebp)
 de4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 de8:	75 23                	jne    e0d <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 dea:	c7 45 f0 f8 13 00 00 	movl   $0x13f8,-0x10(%ebp)
 df1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 df4:	a3 00 14 00 00       	mov    %eax,0x1400
 df9:	a1 00 14 00 00       	mov    0x1400,%eax
 dfe:	a3 f8 13 00 00       	mov    %eax,0x13f8
    base.s.size = 0;
 e03:	c7 05 fc 13 00 00 00 	movl   $0x0,0x13fc
 e0a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e10:	8b 00                	mov    (%eax),%eax
 e12:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e18:	8b 40 04             	mov    0x4(%eax),%eax
 e1b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 e1e:	72 4d                	jb     e6d <malloc+0xa4>
      if(p->s.size == nunits)
 e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e23:	8b 40 04             	mov    0x4(%eax),%eax
 e26:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 e29:	75 0c                	jne    e37 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e2e:	8b 10                	mov    (%eax),%edx
 e30:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e33:	89 10                	mov    %edx,(%eax)
 e35:	eb 26                	jmp    e5d <malloc+0x94>
      else {
        p->s.size -= nunits;
 e37:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e3a:	8b 40 04             	mov    0x4(%eax),%eax
 e3d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 e40:	89 c2                	mov    %eax,%edx
 e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e45:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 e48:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e4b:	8b 40 04             	mov    0x4(%eax),%eax
 e4e:	c1 e0 03             	shl    $0x3,%eax
 e51:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e57:	8b 55 ec             	mov    -0x14(%ebp),%edx
 e5a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 e5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e60:	a3 00 14 00 00       	mov    %eax,0x1400
      return (void*)(p + 1);
 e65:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e68:	83 c0 08             	add    $0x8,%eax
 e6b:	eb 38                	jmp    ea5 <malloc+0xdc>
    }
    if(p == freep)
 e6d:	a1 00 14 00 00       	mov    0x1400,%eax
 e72:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 e75:	75 1b                	jne    e92 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 e77:	8b 45 ec             	mov    -0x14(%ebp),%eax
 e7a:	89 04 24             	mov    %eax,(%esp)
 e7d:	e8 ef fe ff ff       	call   d71 <morecore>
 e82:	89 45 f4             	mov    %eax,-0xc(%ebp)
 e85:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 e89:	75 07                	jne    e92 <malloc+0xc9>
        return 0;
 e8b:	b8 00 00 00 00       	mov    $0x0,%eax
 e90:	eb 13                	jmp    ea5 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e95:	89 45 f0             	mov    %eax,-0x10(%ebp)
 e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e9b:	8b 00                	mov    (%eax),%eax
 e9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 ea0:	e9 70 ff ff ff       	jmp    e15 <malloc+0x4c>
}
 ea5:	c9                   	leave  
 ea6:	c3                   	ret    
