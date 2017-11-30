
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
   d:	c7 44 24 04 80 0e 00 	movl   $0xe80,0x4(%esp)
  14:	00 
  15:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1c:	e8 98 0a 00 00       	call   ab9 <printf>
    exit();
  21:	e8 e6 08 00 00       	call   90c <exit>

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
  3c:	e8 02 07 00 00       	call   743 <strlen>
  41:	89 c3                	mov    %eax,%ebx
  43:	8b 45 0c             	mov    0xc(%ebp),%eax
  46:	89 04 24             	mov    %eax,(%esp)
  49:	e8 f5 06 00 00       	call   743 <strlen>
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
  88:	e8 b6 06 00 00       	call   743 <strlen>
  8d:	89 c2                	mov    %eax,%edx
  8f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  92:	89 54 24 08          	mov    %edx,0x8(%esp)
  96:	8b 55 08             	mov    0x8(%ebp),%edx
  99:	89 54 24 04          	mov    %edx,0x4(%esp)
  9d:	89 04 24             	mov    %eax,(%esp)
  a0:	e8 20 08 00 00       	call   8c5 <memmove>
  memmove(path + strlen(dst), "/", 1);
  a5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  a8:	8b 45 08             	mov    0x8(%ebp),%eax
  ab:	89 04 24             	mov    %eax,(%esp)
  ae:	e8 90 06 00 00       	call   743 <strlen>
  b3:	01 d8                	add    %ebx,%eax
  b5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  bc:	00 
  bd:	c7 44 24 04 91 0e 00 	movl   $0xe91,0x4(%esp)
  c4:	00 
  c5:	89 04 24             	mov    %eax,(%esp)
  c8:	e8 f8 07 00 00       	call   8c5 <memmove>
  memmove(path + strlen(dst) + 1, file, strlen(file));
  cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  d0:	89 04 24             	mov    %eax,(%esp)
  d3:	e8 6b 06 00 00       	call   743 <strlen>
  d8:	89 c3                	mov    %eax,%ebx
  da:	8b 7d dc             	mov    -0x24(%ebp),%edi
  dd:	8b 45 08             	mov    0x8(%ebp),%eax
  e0:	89 04 24             	mov    %eax,(%esp)
  e3:	e8 5b 06 00 00       	call   743 <strlen>
  e8:	40                   	inc    %eax
  e9:	8d 14 07             	lea    (%edi,%eax,1),%edx
  ec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  f7:	89 14 24             	mov    %edx,(%esp)
  fa:	e8 c6 07 00 00       	call   8c5 <memmove>
  memmove(path + strlen(dst) + 1 + strlen(file), "\0", 1);
  ff:	8b 7d dc             	mov    -0x24(%ebp),%edi
 102:	8b 45 08             	mov    0x8(%ebp),%eax
 105:	89 04 24             	mov    %eax,(%esp)
 108:	e8 36 06 00 00       	call   743 <strlen>
 10d:	89 c3                	mov    %eax,%ebx
 10f:	8b 45 0c             	mov    0xc(%ebp),%eax
 112:	89 04 24             	mov    %eax,(%esp)
 115:	e8 29 06 00 00       	call   743 <strlen>
 11a:	01 d8                	add    %ebx,%eax
 11c:	40                   	inc    %eax
 11d:	01 f8                	add    %edi,%eax
 11f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 126:	00 
 127:	c7 44 24 04 93 0e 00 	movl   $0xe93,0x4(%esp)
 12e:	00 
 12f:	89 04 24             	mov    %eax,(%esp)
 132:	e8 8e 07 00 00       	call   8c5 <memmove>

  files[0] = open(file, O_RDONLY);
 137:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 13e:	00 
 13f:	8b 45 0c             	mov    0xc(%ebp),%eax
 142:	89 04 24             	mov    %eax,(%esp)
 145:	e8 02 08 00 00       	call   94c <open>
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
 173:	e8 d4 07 00 00       	call   94c <open>
 178:	89 85 d4 fb ff ff    	mov    %eax,-0x42c(%ebp)
  if (files[1] == -1) { // Check if file opened (permissions problems ...) 
 17e:	8b 85 d4 fb ff ff    	mov    -0x42c(%ebp),%eax
 184:	83 f8 ff             	cmp    $0xffffffff,%eax
 187:	75 30                	jne    1b9 <cp+0x193>
    printf(1, "failed to create file |%s|\n", path);
 189:	8b 45 dc             	mov    -0x24(%ebp),%eax
 18c:	89 44 24 08          	mov    %eax,0x8(%esp)
 190:	c7 44 24 04 95 0e 00 	movl   $0xe95,0x4(%esp)
 197:	00 
 198:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 19f:	e8 15 09 00 00       	call   ab9 <printf>
    close(files[0]);
 1a4:	8b 85 d0 fb ff ff    	mov    -0x430(%ebp),%eax
 1aa:	89 04 24             	mov    %eax,(%esp)
 1ad:	e8 82 07 00 00       	call   934 <close>
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
 1d5:	e8 52 07 00 00       	call   92c <write>
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
 1f5:	e8 2a 07 00 00       	call   924 <read>
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
 252:	c7 04 24 b4 0e 00 00 	movl   $0xeb4,(%esp)
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
 27b:	c7 44 24 04 09 0f 00 	movl   $0xf09,0x4(%esp)
 282:	00 
 283:	89 04 24             	mov    %eax,(%esp)
 286:	e8 80 04 00 00       	call   70b <strcmp>
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
 2ba:	e8 bc 05 00 00       	call   87b <atoi>
 2bf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    }
    if (strcmp(argv[i], "-m") == 0) {
 2c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 2cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2cf:	01 d0                	add    %edx,%eax
 2d1:	8b 00                	mov    (%eax),%eax
 2d3:	c7 44 24 04 0c 0f 00 	movl   $0xf0c,0x4(%esp)
 2da:	00 
 2db:	89 04 24             	mov    %eax,(%esp)
 2de:	e8 28 04 00 00       	call   70b <strcmp>
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
 312:	e8 64 05 00 00       	call   87b <atoi>
 317:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    }
    if (strcmp(argv[i], "-d") == 0) {
 31a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 31d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 324:	8b 45 0c             	mov    0xc(%ebp),%eax
 327:	01 d0                	add    %edx,%eax
 329:	8b 00                	mov    (%eax),%eax
 32b:	c7 44 24 04 0f 0f 00 	movl   $0xf0f,0x4(%esp)
 332:	00 
 333:	89 04 24             	mov    %eax,(%esp)
 336:	e8 d0 03 00 00       	call   70b <strcmp>
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
 36a:	e8 0c 05 00 00       	call   87b <atoi>
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


  printf(1, "name: %s\nmproc: %d\nmsz: %d\nmdsk: %d\nprogc: %d\n", argv[2], mproc, msz, mdsk, progc);
 38f:	8b 45 0c             	mov    0xc(%ebp),%eax
 392:	83 c0 08             	add    $0x8,%eax
 395:	8b 00                	mov    (%eax),%eax
 397:	8b 55 dc             	mov    -0x24(%ebp),%edx
 39a:	89 54 24 18          	mov    %edx,0x18(%esp)
 39e:	8b 55 e0             	mov    -0x20(%ebp),%edx
 3a1:	89 54 24 14          	mov    %edx,0x14(%esp)
 3a5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 3a8:	89 54 24 10          	mov    %edx,0x10(%esp)
 3ac:	8b 55 e8             	mov    -0x18(%ebp),%edx
 3af:	89 54 24 0c          	mov    %edx,0xc(%esp)
 3b3:	89 44 24 08          	mov    %eax,0x8(%esp)
 3b7:	c7 44 24 04 14 0f 00 	movl   $0xf14,0x4(%esp)
 3be:	00 
 3bf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3c6:	e8 ee 06 00 00       	call   ab9 <printf>

  if (ccreate(argv[2], progv, progc, mproc, msz, mdsk) == 1) {
 3cb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 3ce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 3d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d4:	83 c0 08             	add    $0x8,%eax
 3d7:	8b 00                	mov    (%eax),%eax
 3d9:	89 4c 24 14          	mov    %ecx,0x14(%esp)
 3dd:	89 54 24 10          	mov    %edx,0x10(%esp)
 3e1:	8b 55 e8             	mov    -0x18(%ebp),%edx
 3e4:	89 54 24 0c          	mov    %edx,0xc(%esp)
 3e8:	8b 55 dc             	mov    -0x24(%ebp),%edx
 3eb:	89 54 24 08          	mov    %edx,0x8(%esp)
 3ef:	8d 95 5c ff ff ff    	lea    -0xa4(%ebp),%edx
 3f5:	89 54 24 04          	mov    %edx,0x4(%esp)
 3f9:	89 04 24             	mov    %eax,(%esp)
 3fc:	e8 b3 05 00 00       	call   9b4 <ccreate>
 401:	83 f8 01             	cmp    $0x1,%eax
 404:	75 22                	jne    428 <create+0x201>
    printf(1, "Created container %s\n", argv[2]); 
 406:	8b 45 0c             	mov    0xc(%ebp),%eax
 409:	83 c0 08             	add    $0x8,%eax
 40c:	8b 00                	mov    (%eax),%eax
 40e:	89 44 24 08          	mov    %eax,0x8(%esp)
 412:	c7 44 24 04 43 0f 00 	movl   $0xf43,0x4(%esp)
 419:	00 
 41a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 421:	e8 93 06 00 00       	call   ab9 <printf>
 426:	eb 20                	jmp    448 <create+0x221>
  } else {
    printf(1, "Failed to create container %s\n", argv[2]); 
 428:	8b 45 0c             	mov    0xc(%ebp),%eax
 42b:	83 c0 08             	add    $0x8,%eax
 42e:	8b 00                	mov    (%eax),%eax
 430:	89 44 24 08          	mov    %eax,0x8(%esp)
 434:	c7 44 24 04 5c 0f 00 	movl   $0xf5c,0x4(%esp)
 43b:	00 
 43c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 443:	e8 71 06 00 00       	call   ab9 <printf>
  }

  for (i = last_flag + 1, k = 0; i < argc; i++, k++) {
 448:	8b 45 ec             	mov    -0x14(%ebp),%eax
 44b:	40                   	inc    %eax
 44c:	89 45 f4             	mov    %eax,-0xc(%ebp)
 44f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 456:	eb 65                	jmp    4bd <create+0x296>

    // TODO: move this into the kernel or the rest of ccreate out of the kernel
    if (cp(argv[2], argv[i]) != 1) 
 458:	8b 45 f4             	mov    -0xc(%ebp),%eax
 45b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 462:	8b 45 0c             	mov    0xc(%ebp),%eax
 465:	01 d0                	add    %edx,%eax
 467:	8b 10                	mov    (%eax),%edx
 469:	8b 45 0c             	mov    0xc(%ebp),%eax
 46c:	83 c0 08             	add    $0x8,%eax
 46f:	8b 00                	mov    (%eax),%eax
 471:	89 54 24 04          	mov    %edx,0x4(%esp)
 475:	89 04 24             	mov    %eax,(%esp)
 478:	e8 a9 fb ff ff       	call   26 <cp>
 47d:	83 f8 01             	cmp    $0x1,%eax
 480:	74 35                	je     4b7 <create+0x290>
      printf(1, "Failed to copy %s into folder %s. Continuing...\n", argv[i], argv[2]);
 482:	8b 45 0c             	mov    0xc(%ebp),%eax
 485:	83 c0 08             	add    $0x8,%eax
 488:	8b 10                	mov    (%eax),%edx
 48a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 48d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
 494:	8b 45 0c             	mov    0xc(%ebp),%eax
 497:	01 c8                	add    %ecx,%eax
 499:	8b 00                	mov    (%eax),%eax
 49b:	89 54 24 0c          	mov    %edx,0xc(%esp)
 49f:	89 44 24 08          	mov    %eax,0x8(%esp)
 4a3:	c7 44 24 04 7c 0f 00 	movl   $0xf7c,0x4(%esp)
 4aa:	00 
 4ab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 4b2:	e8 02 06 00 00       	call   ab9 <printf>
    printf(1, "Created container %s\n", argv[2]); 
  } else {
    printf(1, "Failed to create container %s\n", argv[2]); 
  }

  for (i = last_flag + 1, k = 0; i < argc; i++, k++) {
 4b7:	ff 45 f4             	incl   -0xc(%ebp)
 4ba:	ff 45 f0             	incl   -0x10(%ebp)
 4bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4c0:	3b 45 08             	cmp    0x8(%ebp),%eax
 4c3:	7c 93                	jl     458 <create+0x231>
    
    // If we were using kernel for ccreate sys call
    // Change size of to strlen
    // progv[k] = malloc(sizeof(argv[i])); memmove(progv[k], argv[i], sizeof(argv[i])); memmove(progv[k] + sizeof(argv[i]), "\0", 1); printf(1, "\t%s\n", progv[k]);
  }  
}
 4c5:	c9                   	leave  
 4c6:	c3                   	ret    

000004c7 <start>:

// ctool start <name> prog arg1 [arg2 ...]
// ctool start ctest1 echoloop ab
void
start(int argc, char *argv[])
{    
 4c7:	55                   	push   %ebp
 4c8:	89 e5                	mov    %esp,%ebp
 4ca:	53                   	push   %ebx
 4cb:	81 ec a4 00 00 00    	sub    $0xa4,%esp

  char *args[MAXARG];
  int i, k;

  if (argc < 4)
 4d1:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
 4d5:	7f 0c                	jg     4e3 <start+0x1c>
    usage("ctool start <name> prog arg1 [arg2 ...]");
 4d7:	c7 04 24 b0 0f 00 00 	movl   $0xfb0,(%esp)
 4de:	e8 1d fb ff ff       	call   0 <usage>

  for (i = 3, k = 0; i < argc; i++, k++) {
 4e3:	c7 45 f4 03 00 00 00 	movl   $0x3,-0xc(%ebp)
 4ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4f1:	e9 b5 00 00 00       	jmp    5ab <start+0xe4>
    args[k] = malloc(strlen(argv[i]) + 1);     
 4f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 500:	8b 45 0c             	mov    0xc(%ebp),%eax
 503:	01 d0                	add    %edx,%eax
 505:	8b 00                	mov    (%eax),%eax
 507:	89 04 24             	mov    %eax,(%esp)
 50a:	e8 34 02 00 00       	call   743 <strlen>
 50f:	40                   	inc    %eax
 510:	89 04 24             	mov    %eax,(%esp)
 513:	e8 89 08 00 00       	call   da1 <malloc>
 518:	8b 55 f0             	mov    -0x10(%ebp),%edx
 51b:	89 84 95 70 ff ff ff 	mov    %eax,-0x90(%ebp,%edx,4)
    memmove(args[k], argv[i], strlen(argv[i])); 
 522:	8b 45 f4             	mov    -0xc(%ebp),%eax
 525:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 52c:	8b 45 0c             	mov    0xc(%ebp),%eax
 52f:	01 d0                	add    %edx,%eax
 531:	8b 00                	mov    (%eax),%eax
 533:	89 04 24             	mov    %eax,(%esp)
 536:	e8 08 02 00 00       	call   743 <strlen>
 53b:	89 c1                	mov    %eax,%ecx
 53d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 540:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 547:	8b 45 0c             	mov    0xc(%ebp),%eax
 54a:	01 d0                	add    %edx,%eax
 54c:	8b 10                	mov    (%eax),%edx
 54e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 551:	8b 84 85 70 ff ff ff 	mov    -0x90(%ebp,%eax,4),%eax
 558:	89 4c 24 08          	mov    %ecx,0x8(%esp)
 55c:	89 54 24 04          	mov    %edx,0x4(%esp)
 560:	89 04 24             	mov    %eax,(%esp)
 563:	e8 5d 03 00 00       	call   8c5 <memmove>
    memmove(args[k] + strlen(argv[i]), "\0", 1);
 568:	8b 45 f0             	mov    -0x10(%ebp),%eax
 56b:	8b 9c 85 70 ff ff ff 	mov    -0x90(%ebp,%eax,4),%ebx
 572:	8b 45 f4             	mov    -0xc(%ebp),%eax
 575:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 57c:	8b 45 0c             	mov    0xc(%ebp),%eax
 57f:	01 d0                	add    %edx,%eax
 581:	8b 00                	mov    (%eax),%eax
 583:	89 04 24             	mov    %eax,(%esp)
 586:	e8 b8 01 00 00       	call   743 <strlen>
 58b:	01 d8                	add    %ebx,%eax
 58d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 594:	00 
 595:	c7 44 24 04 93 0e 00 	movl   $0xe93,0x4(%esp)
 59c:	00 
 59d:	89 04 24             	mov    %eax,(%esp)
 5a0:	e8 20 03 00 00       	call   8c5 <memmove>
  int i, k;

  if (argc < 4)
    usage("ctool start <name> prog arg1 [arg2 ...]");

  for (i = 3, k = 0; i < argc; i++, k++) {
 5a5:	ff 45 f4             	incl   -0xc(%ebp)
 5a8:	ff 45 f0             	incl   -0x10(%ebp)
 5ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ae:	3b 45 08             	cmp    0x8(%ebp),%eax
 5b1:	0f 8c 3f ff ff ff    	jl     4f6 <start+0x2f>
    args[k] = malloc(strlen(argv[i]) + 1);     
    memmove(args[k], argv[i], strlen(argv[i])); 
    memmove(args[k] + strlen(argv[i]), "\0", 1);
  }

  if (cstart(argv[2], args, (argc - 3)) != 1) 
 5b7:	8b 45 08             	mov    0x8(%ebp),%eax
 5ba:	8d 50 fd             	lea    -0x3(%eax),%edx
 5bd:	8b 45 0c             	mov    0xc(%ebp),%eax
 5c0:	83 c0 08             	add    $0x8,%eax
 5c3:	8b 00                	mov    (%eax),%eax
 5c5:	89 54 24 08          	mov    %edx,0x8(%esp)
 5c9:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
 5cf:	89 54 24 04          	mov    %edx,0x4(%esp)
 5d3:	89 04 24             	mov    %eax,(%esp)
 5d6:	e8 e1 03 00 00       	call   9bc <cstart>
 5db:	83 f8 01             	cmp    $0x1,%eax
 5de:	74 20                	je     600 <start+0x139>
    printf(1, "Failed to start container %s\n", argv[2]);     
 5e0:	8b 45 0c             	mov    0xc(%ebp),%eax
 5e3:	83 c0 08             	add    $0x8,%eax
 5e6:	8b 00                	mov    (%eax),%eax
 5e8:	89 44 24 08          	mov    %eax,0x8(%esp)
 5ec:	c7 44 24 04 d8 0f 00 	movl   $0xfd8,0x4(%esp)
 5f3:	00 
 5f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 5fb:	e8 b9 04 00 00       	call   ab9 <printf>
}
 600:	81 c4 a4 00 00 00    	add    $0xa4,%esp
 606:	5b                   	pop    %ebx
 607:	5d                   	pop    %ebp
 608:	c3                   	ret    

00000609 <pause>:

void
pause(int argc, char *argv[])
{
 609:	55                   	push   %ebp
 60a:	89 e5                	mov    %esp,%ebp
  
}
 60c:	5d                   	pop    %ebp
 60d:	c3                   	ret    

0000060e <resume>:

void
resume(int argc, char *argv[])
{
 60e:	55                   	push   %ebp
 60f:	89 e5                	mov    %esp,%ebp
  
}
 611:	5d                   	pop    %ebp
 612:	c3                   	ret    

00000613 <stop>:

void
stop(int argc, char *argv[])
{
 613:	55                   	push   %ebp
 614:	89 e5                	mov    %esp,%ebp
  
}
 616:	5d                   	pop    %ebp
 617:	c3                   	ret    

00000618 <info>:

void
info(int argc, char *argv[])
{
 618:	55                   	push   %ebp
 619:	89 e5                	mov    %esp,%ebp
  
}
 61b:	5d                   	pop    %ebp
 61c:	c3                   	ret    

0000061d <main>:

int
main(int argc, char *argv[])
{
 61d:	55                   	push   %ebp
 61e:	89 e5                	mov    %esp,%ebp
 620:	83 e4 f0             	and    $0xfffffff0,%esp
 623:	83 ec 10             	sub    $0x10,%esp

  if (argc < 3) {
 626:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 62a:	7f 11                	jg     63d <main+0x20>
    usage("<tool> <cmd> [<arg> ...]");
 62c:	c7 04 24 f6 0f 00 00 	movl   $0xff6,(%esp)
 633:	e8 c8 f9 ff ff       	call   0 <usage>
    exit();
 638:	e8 cf 02 00 00       	call   90c <exit>
  }

  if (strcmp(argv[1], "create") == 0)
 63d:	8b 45 0c             	mov    0xc(%ebp),%eax
 640:	83 c0 04             	add    $0x4,%eax
 643:	8b 00                	mov    (%eax),%eax
 645:	c7 44 24 04 0f 10 00 	movl   $0x100f,0x4(%esp)
 64c:	00 
 64d:	89 04 24             	mov    %eax,(%esp)
 650:	e8 b6 00 00 00       	call   70b <strcmp>
 655:	85 c0                	test   %eax,%eax
 657:	75 14                	jne    66d <main+0x50>
    create(argc, argv);
 659:	8b 45 0c             	mov    0xc(%ebp),%eax
 65c:	89 44 24 04          	mov    %eax,0x4(%esp)
 660:	8b 45 08             	mov    0x8(%ebp),%eax
 663:	89 04 24             	mov    %eax,(%esp)
 666:	e8 bc fb ff ff       	call   227 <create>
 66b:	eb 44                	jmp    6b1 <main+0x94>
  else if (strcmp(argv[1], "start") == 0)
 66d:	8b 45 0c             	mov    0xc(%ebp),%eax
 670:	83 c0 04             	add    $0x4,%eax
 673:	8b 00                	mov    (%eax),%eax
 675:	c7 44 24 04 16 10 00 	movl   $0x1016,0x4(%esp)
 67c:	00 
 67d:	89 04 24             	mov    %eax,(%esp)
 680:	e8 86 00 00 00       	call   70b <strcmp>
 685:	85 c0                	test   %eax,%eax
 687:	75 14                	jne    69d <main+0x80>
    start(argc, argv);
 689:	8b 45 0c             	mov    0xc(%ebp),%eax
 68c:	89 44 24 04          	mov    %eax,0x4(%esp)
 690:	8b 45 08             	mov    0x8(%ebp),%eax
 693:	89 04 24             	mov    %eax,(%esp)
 696:	e8 2c fe ff ff       	call   4c7 <start>
 69b:	eb 14                	jmp    6b1 <main+0x94>
  else 
    printf(1, "ctool: command not found.\n");   
 69d:	c7 44 24 04 1c 10 00 	movl   $0x101c,0x4(%esp)
 6a4:	00 
 6a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 6ac:	e8 08 04 00 00       	call   ab9 <printf>

  exit();
 6b1:	e8 56 02 00 00       	call   90c <exit>
 6b6:	90                   	nop
 6b7:	90                   	nop

000006b8 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 6b8:	55                   	push   %ebp
 6b9:	89 e5                	mov    %esp,%ebp
 6bb:	57                   	push   %edi
 6bc:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 6bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
 6c0:	8b 55 10             	mov    0x10(%ebp),%edx
 6c3:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c6:	89 cb                	mov    %ecx,%ebx
 6c8:	89 df                	mov    %ebx,%edi
 6ca:	89 d1                	mov    %edx,%ecx
 6cc:	fc                   	cld    
 6cd:	f3 aa                	rep stos %al,%es:(%edi)
 6cf:	89 ca                	mov    %ecx,%edx
 6d1:	89 fb                	mov    %edi,%ebx
 6d3:	89 5d 08             	mov    %ebx,0x8(%ebp)
 6d6:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 6d9:	5b                   	pop    %ebx
 6da:	5f                   	pop    %edi
 6db:	5d                   	pop    %ebp
 6dc:	c3                   	ret    

000006dd <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 6dd:	55                   	push   %ebp
 6de:	89 e5                	mov    %esp,%ebp
 6e0:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 6e3:	8b 45 08             	mov    0x8(%ebp),%eax
 6e6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 6e9:	90                   	nop
 6ea:	8b 45 08             	mov    0x8(%ebp),%eax
 6ed:	8d 50 01             	lea    0x1(%eax),%edx
 6f0:	89 55 08             	mov    %edx,0x8(%ebp)
 6f3:	8b 55 0c             	mov    0xc(%ebp),%edx
 6f6:	8d 4a 01             	lea    0x1(%edx),%ecx
 6f9:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 6fc:	8a 12                	mov    (%edx),%dl
 6fe:	88 10                	mov    %dl,(%eax)
 700:	8a 00                	mov    (%eax),%al
 702:	84 c0                	test   %al,%al
 704:	75 e4                	jne    6ea <strcpy+0xd>
    ;
  return os;
 706:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 709:	c9                   	leave  
 70a:	c3                   	ret    

0000070b <strcmp>:

int
strcmp(const char *p, const char *q)
{
 70b:	55                   	push   %ebp
 70c:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 70e:	eb 06                	jmp    716 <strcmp+0xb>
    p++, q++;
 710:	ff 45 08             	incl   0x8(%ebp)
 713:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 716:	8b 45 08             	mov    0x8(%ebp),%eax
 719:	8a 00                	mov    (%eax),%al
 71b:	84 c0                	test   %al,%al
 71d:	74 0e                	je     72d <strcmp+0x22>
 71f:	8b 45 08             	mov    0x8(%ebp),%eax
 722:	8a 10                	mov    (%eax),%dl
 724:	8b 45 0c             	mov    0xc(%ebp),%eax
 727:	8a 00                	mov    (%eax),%al
 729:	38 c2                	cmp    %al,%dl
 72b:	74 e3                	je     710 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 72d:	8b 45 08             	mov    0x8(%ebp),%eax
 730:	8a 00                	mov    (%eax),%al
 732:	0f b6 d0             	movzbl %al,%edx
 735:	8b 45 0c             	mov    0xc(%ebp),%eax
 738:	8a 00                	mov    (%eax),%al
 73a:	0f b6 c0             	movzbl %al,%eax
 73d:	29 c2                	sub    %eax,%edx
 73f:	89 d0                	mov    %edx,%eax
}
 741:	5d                   	pop    %ebp
 742:	c3                   	ret    

00000743 <strlen>:

uint
strlen(char *s)
{
 743:	55                   	push   %ebp
 744:	89 e5                	mov    %esp,%ebp
 746:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 749:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 750:	eb 03                	jmp    755 <strlen+0x12>
 752:	ff 45 fc             	incl   -0x4(%ebp)
 755:	8b 55 fc             	mov    -0x4(%ebp),%edx
 758:	8b 45 08             	mov    0x8(%ebp),%eax
 75b:	01 d0                	add    %edx,%eax
 75d:	8a 00                	mov    (%eax),%al
 75f:	84 c0                	test   %al,%al
 761:	75 ef                	jne    752 <strlen+0xf>
    ;
  return n;
 763:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 766:	c9                   	leave  
 767:	c3                   	ret    

00000768 <memset>:

void*
memset(void *dst, int c, uint n)
{
 768:	55                   	push   %ebp
 769:	89 e5                	mov    %esp,%ebp
 76b:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 76e:	8b 45 10             	mov    0x10(%ebp),%eax
 771:	89 44 24 08          	mov    %eax,0x8(%esp)
 775:	8b 45 0c             	mov    0xc(%ebp),%eax
 778:	89 44 24 04          	mov    %eax,0x4(%esp)
 77c:	8b 45 08             	mov    0x8(%ebp),%eax
 77f:	89 04 24             	mov    %eax,(%esp)
 782:	e8 31 ff ff ff       	call   6b8 <stosb>
  return dst;
 787:	8b 45 08             	mov    0x8(%ebp),%eax
}
 78a:	c9                   	leave  
 78b:	c3                   	ret    

0000078c <strchr>:

char*
strchr(const char *s, char c)
{
 78c:	55                   	push   %ebp
 78d:	89 e5                	mov    %esp,%ebp
 78f:	83 ec 04             	sub    $0x4,%esp
 792:	8b 45 0c             	mov    0xc(%ebp),%eax
 795:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 798:	eb 12                	jmp    7ac <strchr+0x20>
    if(*s == c)
 79a:	8b 45 08             	mov    0x8(%ebp),%eax
 79d:	8a 00                	mov    (%eax),%al
 79f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 7a2:	75 05                	jne    7a9 <strchr+0x1d>
      return (char*)s;
 7a4:	8b 45 08             	mov    0x8(%ebp),%eax
 7a7:	eb 11                	jmp    7ba <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 7a9:	ff 45 08             	incl   0x8(%ebp)
 7ac:	8b 45 08             	mov    0x8(%ebp),%eax
 7af:	8a 00                	mov    (%eax),%al
 7b1:	84 c0                	test   %al,%al
 7b3:	75 e5                	jne    79a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 7b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
 7ba:	c9                   	leave  
 7bb:	c3                   	ret    

000007bc <gets>:

char*
gets(char *buf, int max)
{
 7bc:	55                   	push   %ebp
 7bd:	89 e5                	mov    %esp,%ebp
 7bf:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 7c2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 7c9:	eb 49                	jmp    814 <gets+0x58>
    cc = read(0, &c, 1);
 7cb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 7d2:	00 
 7d3:	8d 45 ef             	lea    -0x11(%ebp),%eax
 7d6:	89 44 24 04          	mov    %eax,0x4(%esp)
 7da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 7e1:	e8 3e 01 00 00       	call   924 <read>
 7e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 7e9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 7ed:	7f 02                	jg     7f1 <gets+0x35>
      break;
 7ef:	eb 2c                	jmp    81d <gets+0x61>
    buf[i++] = c;
 7f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f4:	8d 50 01             	lea    0x1(%eax),%edx
 7f7:	89 55 f4             	mov    %edx,-0xc(%ebp)
 7fa:	89 c2                	mov    %eax,%edx
 7fc:	8b 45 08             	mov    0x8(%ebp),%eax
 7ff:	01 c2                	add    %eax,%edx
 801:	8a 45 ef             	mov    -0x11(%ebp),%al
 804:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 806:	8a 45 ef             	mov    -0x11(%ebp),%al
 809:	3c 0a                	cmp    $0xa,%al
 80b:	74 10                	je     81d <gets+0x61>
 80d:	8a 45 ef             	mov    -0x11(%ebp),%al
 810:	3c 0d                	cmp    $0xd,%al
 812:	74 09                	je     81d <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 814:	8b 45 f4             	mov    -0xc(%ebp),%eax
 817:	40                   	inc    %eax
 818:	3b 45 0c             	cmp    0xc(%ebp),%eax
 81b:	7c ae                	jl     7cb <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 81d:	8b 55 f4             	mov    -0xc(%ebp),%edx
 820:	8b 45 08             	mov    0x8(%ebp),%eax
 823:	01 d0                	add    %edx,%eax
 825:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 828:	8b 45 08             	mov    0x8(%ebp),%eax
}
 82b:	c9                   	leave  
 82c:	c3                   	ret    

0000082d <stat>:

int
stat(char *n, struct stat *st)
{
 82d:	55                   	push   %ebp
 82e:	89 e5                	mov    %esp,%ebp
 830:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 833:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 83a:	00 
 83b:	8b 45 08             	mov    0x8(%ebp),%eax
 83e:	89 04 24             	mov    %eax,(%esp)
 841:	e8 06 01 00 00       	call   94c <open>
 846:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 849:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 84d:	79 07                	jns    856 <stat+0x29>
    return -1;
 84f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 854:	eb 23                	jmp    879 <stat+0x4c>
  r = fstat(fd, st);
 856:	8b 45 0c             	mov    0xc(%ebp),%eax
 859:	89 44 24 04          	mov    %eax,0x4(%esp)
 85d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 860:	89 04 24             	mov    %eax,(%esp)
 863:	e8 fc 00 00 00       	call   964 <fstat>
 868:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 86b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86e:	89 04 24             	mov    %eax,(%esp)
 871:	e8 be 00 00 00       	call   934 <close>
  return r;
 876:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 879:	c9                   	leave  
 87a:	c3                   	ret    

0000087b <atoi>:

int
atoi(const char *s)
{
 87b:	55                   	push   %ebp
 87c:	89 e5                	mov    %esp,%ebp
 87e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 881:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 888:	eb 24                	jmp    8ae <atoi+0x33>
    n = n*10 + *s++ - '0';
 88a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 88d:	89 d0                	mov    %edx,%eax
 88f:	c1 e0 02             	shl    $0x2,%eax
 892:	01 d0                	add    %edx,%eax
 894:	01 c0                	add    %eax,%eax
 896:	89 c1                	mov    %eax,%ecx
 898:	8b 45 08             	mov    0x8(%ebp),%eax
 89b:	8d 50 01             	lea    0x1(%eax),%edx
 89e:	89 55 08             	mov    %edx,0x8(%ebp)
 8a1:	8a 00                	mov    (%eax),%al
 8a3:	0f be c0             	movsbl %al,%eax
 8a6:	01 c8                	add    %ecx,%eax
 8a8:	83 e8 30             	sub    $0x30,%eax
 8ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 8ae:	8b 45 08             	mov    0x8(%ebp),%eax
 8b1:	8a 00                	mov    (%eax),%al
 8b3:	3c 2f                	cmp    $0x2f,%al
 8b5:	7e 09                	jle    8c0 <atoi+0x45>
 8b7:	8b 45 08             	mov    0x8(%ebp),%eax
 8ba:	8a 00                	mov    (%eax),%al
 8bc:	3c 39                	cmp    $0x39,%al
 8be:	7e ca                	jle    88a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 8c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 8c3:	c9                   	leave  
 8c4:	c3                   	ret    

000008c5 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 8c5:	55                   	push   %ebp
 8c6:	89 e5                	mov    %esp,%ebp
 8c8:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 8cb:	8b 45 08             	mov    0x8(%ebp),%eax
 8ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 8d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 8d4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 8d7:	eb 16                	jmp    8ef <memmove+0x2a>
    *dst++ = *src++;
 8d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8dc:	8d 50 01             	lea    0x1(%eax),%edx
 8df:	89 55 fc             	mov    %edx,-0x4(%ebp)
 8e2:	8b 55 f8             	mov    -0x8(%ebp),%edx
 8e5:	8d 4a 01             	lea    0x1(%edx),%ecx
 8e8:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 8eb:	8a 12                	mov    (%edx),%dl
 8ed:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 8ef:	8b 45 10             	mov    0x10(%ebp),%eax
 8f2:	8d 50 ff             	lea    -0x1(%eax),%edx
 8f5:	89 55 10             	mov    %edx,0x10(%ebp)
 8f8:	85 c0                	test   %eax,%eax
 8fa:	7f dd                	jg     8d9 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 8fc:	8b 45 08             	mov    0x8(%ebp),%eax
}
 8ff:	c9                   	leave  
 900:	c3                   	ret    
 901:	90                   	nop
 902:	90                   	nop
 903:	90                   	nop

00000904 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 904:	b8 01 00 00 00       	mov    $0x1,%eax
 909:	cd 40                	int    $0x40
 90b:	c3                   	ret    

0000090c <exit>:
SYSCALL(exit)
 90c:	b8 02 00 00 00       	mov    $0x2,%eax
 911:	cd 40                	int    $0x40
 913:	c3                   	ret    

00000914 <wait>:
SYSCALL(wait)
 914:	b8 03 00 00 00       	mov    $0x3,%eax
 919:	cd 40                	int    $0x40
 91b:	c3                   	ret    

0000091c <pipe>:
SYSCALL(pipe)
 91c:	b8 04 00 00 00       	mov    $0x4,%eax
 921:	cd 40                	int    $0x40
 923:	c3                   	ret    

00000924 <read>:
SYSCALL(read)
 924:	b8 05 00 00 00       	mov    $0x5,%eax
 929:	cd 40                	int    $0x40
 92b:	c3                   	ret    

0000092c <write>:
SYSCALL(write)
 92c:	b8 10 00 00 00       	mov    $0x10,%eax
 931:	cd 40                	int    $0x40
 933:	c3                   	ret    

00000934 <close>:
SYSCALL(close)
 934:	b8 15 00 00 00       	mov    $0x15,%eax
 939:	cd 40                	int    $0x40
 93b:	c3                   	ret    

0000093c <kill>:
SYSCALL(kill)
 93c:	b8 06 00 00 00       	mov    $0x6,%eax
 941:	cd 40                	int    $0x40
 943:	c3                   	ret    

00000944 <exec>:
SYSCALL(exec)
 944:	b8 07 00 00 00       	mov    $0x7,%eax
 949:	cd 40                	int    $0x40
 94b:	c3                   	ret    

0000094c <open>:
SYSCALL(open)
 94c:	b8 0f 00 00 00       	mov    $0xf,%eax
 951:	cd 40                	int    $0x40
 953:	c3                   	ret    

00000954 <mknod>:
SYSCALL(mknod)
 954:	b8 11 00 00 00       	mov    $0x11,%eax
 959:	cd 40                	int    $0x40
 95b:	c3                   	ret    

0000095c <unlink>:
SYSCALL(unlink)
 95c:	b8 12 00 00 00       	mov    $0x12,%eax
 961:	cd 40                	int    $0x40
 963:	c3                   	ret    

00000964 <fstat>:
SYSCALL(fstat)
 964:	b8 08 00 00 00       	mov    $0x8,%eax
 969:	cd 40                	int    $0x40
 96b:	c3                   	ret    

0000096c <link>:
SYSCALL(link)
 96c:	b8 13 00 00 00       	mov    $0x13,%eax
 971:	cd 40                	int    $0x40
 973:	c3                   	ret    

00000974 <mkdir>:
SYSCALL(mkdir)
 974:	b8 14 00 00 00       	mov    $0x14,%eax
 979:	cd 40                	int    $0x40
 97b:	c3                   	ret    

0000097c <chdir>:
SYSCALL(chdir)
 97c:	b8 09 00 00 00       	mov    $0x9,%eax
 981:	cd 40                	int    $0x40
 983:	c3                   	ret    

00000984 <dup>:
SYSCALL(dup)
 984:	b8 0a 00 00 00       	mov    $0xa,%eax
 989:	cd 40                	int    $0x40
 98b:	c3                   	ret    

0000098c <getpid>:
SYSCALL(getpid)
 98c:	b8 0b 00 00 00       	mov    $0xb,%eax
 991:	cd 40                	int    $0x40
 993:	c3                   	ret    

00000994 <sbrk>:
SYSCALL(sbrk)
 994:	b8 0c 00 00 00       	mov    $0xc,%eax
 999:	cd 40                	int    $0x40
 99b:	c3                   	ret    

0000099c <sleep>:
SYSCALL(sleep)
 99c:	b8 0d 00 00 00       	mov    $0xd,%eax
 9a1:	cd 40                	int    $0x40
 9a3:	c3                   	ret    

000009a4 <uptime>:
SYSCALL(uptime)
 9a4:	b8 0e 00 00 00       	mov    $0xe,%eax
 9a9:	cd 40                	int    $0x40
 9ab:	c3                   	ret    

000009ac <getticks>:
SYSCALL(getticks)
 9ac:	b8 16 00 00 00       	mov    $0x16,%eax
 9b1:	cd 40                	int    $0x40
 9b3:	c3                   	ret    

000009b4 <ccreate>:
SYSCALL(ccreate)
 9b4:	b8 17 00 00 00       	mov    $0x17,%eax
 9b9:	cd 40                	int    $0x40
 9bb:	c3                   	ret    

000009bc <cstart>:
SYSCALL(cstart)
 9bc:	b8 19 00 00 00       	mov    $0x19,%eax
 9c1:	cd 40                	int    $0x40
 9c3:	c3                   	ret    

000009c4 <cstop>:
SYSCALL(cstop)
 9c4:	b8 18 00 00 00       	mov    $0x18,%eax
 9c9:	cd 40                	int    $0x40
 9cb:	c3                   	ret    

000009cc <cpause>:
SYSCALL(cpause)
 9cc:	b8 1b 00 00 00       	mov    $0x1b,%eax
 9d1:	cd 40                	int    $0x40
 9d3:	c3                   	ret    

000009d4 <cinfo>:
SYSCALL(cinfo)
 9d4:	b8 1a 00 00 00       	mov    $0x1a,%eax
 9d9:	cd 40                	int    $0x40
 9db:	c3                   	ret    

000009dc <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 9dc:	55                   	push   %ebp
 9dd:	89 e5                	mov    %esp,%ebp
 9df:	83 ec 18             	sub    $0x18,%esp
 9e2:	8b 45 0c             	mov    0xc(%ebp),%eax
 9e5:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 9e8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 9ef:	00 
 9f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
 9f3:	89 44 24 04          	mov    %eax,0x4(%esp)
 9f7:	8b 45 08             	mov    0x8(%ebp),%eax
 9fa:	89 04 24             	mov    %eax,(%esp)
 9fd:	e8 2a ff ff ff       	call   92c <write>
}
 a02:	c9                   	leave  
 a03:	c3                   	ret    

00000a04 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 a04:	55                   	push   %ebp
 a05:	89 e5                	mov    %esp,%ebp
 a07:	56                   	push   %esi
 a08:	53                   	push   %ebx
 a09:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 a0c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 a13:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 a17:	74 17                	je     a30 <printint+0x2c>
 a19:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 a1d:	79 11                	jns    a30 <printint+0x2c>
    neg = 1;
 a1f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 a26:	8b 45 0c             	mov    0xc(%ebp),%eax
 a29:	f7 d8                	neg    %eax
 a2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
 a2e:	eb 06                	jmp    a36 <printint+0x32>
  } else {
    x = xx;
 a30:	8b 45 0c             	mov    0xc(%ebp),%eax
 a33:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 a36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 a3d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 a40:	8d 41 01             	lea    0x1(%ecx),%eax
 a43:	89 45 f4             	mov    %eax,-0xc(%ebp)
 a46:	8b 5d 10             	mov    0x10(%ebp),%ebx
 a49:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a4c:	ba 00 00 00 00       	mov    $0x0,%edx
 a51:	f7 f3                	div    %ebx
 a53:	89 d0                	mov    %edx,%eax
 a55:	8a 80 b8 13 00 00    	mov    0x13b8(%eax),%al
 a5b:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 a5f:	8b 75 10             	mov    0x10(%ebp),%esi
 a62:	8b 45 ec             	mov    -0x14(%ebp),%eax
 a65:	ba 00 00 00 00       	mov    $0x0,%edx
 a6a:	f7 f6                	div    %esi
 a6c:	89 45 ec             	mov    %eax,-0x14(%ebp)
 a6f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 a73:	75 c8                	jne    a3d <printint+0x39>
  if(neg)
 a75:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a79:	74 10                	je     a8b <printint+0x87>
    buf[i++] = '-';
 a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a7e:	8d 50 01             	lea    0x1(%eax),%edx
 a81:	89 55 f4             	mov    %edx,-0xc(%ebp)
 a84:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 a89:	eb 1e                	jmp    aa9 <printint+0xa5>
 a8b:	eb 1c                	jmp    aa9 <printint+0xa5>
    putc(fd, buf[i]);
 a8d:	8d 55 dc             	lea    -0x24(%ebp),%edx
 a90:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a93:	01 d0                	add    %edx,%eax
 a95:	8a 00                	mov    (%eax),%al
 a97:	0f be c0             	movsbl %al,%eax
 a9a:	89 44 24 04          	mov    %eax,0x4(%esp)
 a9e:	8b 45 08             	mov    0x8(%ebp),%eax
 aa1:	89 04 24             	mov    %eax,(%esp)
 aa4:	e8 33 ff ff ff       	call   9dc <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 aa9:	ff 4d f4             	decl   -0xc(%ebp)
 aac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ab0:	79 db                	jns    a8d <printint+0x89>
    putc(fd, buf[i]);
}
 ab2:	83 c4 30             	add    $0x30,%esp
 ab5:	5b                   	pop    %ebx
 ab6:	5e                   	pop    %esi
 ab7:	5d                   	pop    %ebp
 ab8:	c3                   	ret    

00000ab9 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 ab9:	55                   	push   %ebp
 aba:	89 e5                	mov    %esp,%ebp
 abc:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 abf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 ac6:	8d 45 0c             	lea    0xc(%ebp),%eax
 ac9:	83 c0 04             	add    $0x4,%eax
 acc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 acf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 ad6:	e9 77 01 00 00       	jmp    c52 <printf+0x199>
    c = fmt[i] & 0xff;
 adb:	8b 55 0c             	mov    0xc(%ebp),%edx
 ade:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ae1:	01 d0                	add    %edx,%eax
 ae3:	8a 00                	mov    (%eax),%al
 ae5:	0f be c0             	movsbl %al,%eax
 ae8:	25 ff 00 00 00       	and    $0xff,%eax
 aed:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 af0:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 af4:	75 2c                	jne    b22 <printf+0x69>
      if(c == '%'){
 af6:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 afa:	75 0c                	jne    b08 <printf+0x4f>
        state = '%';
 afc:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 b03:	e9 47 01 00 00       	jmp    c4f <printf+0x196>
      } else {
        putc(fd, c);
 b08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b0b:	0f be c0             	movsbl %al,%eax
 b0e:	89 44 24 04          	mov    %eax,0x4(%esp)
 b12:	8b 45 08             	mov    0x8(%ebp),%eax
 b15:	89 04 24             	mov    %eax,(%esp)
 b18:	e8 bf fe ff ff       	call   9dc <putc>
 b1d:	e9 2d 01 00 00       	jmp    c4f <printf+0x196>
      }
    } else if(state == '%'){
 b22:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 b26:	0f 85 23 01 00 00    	jne    c4f <printf+0x196>
      if(c == 'd'){
 b2c:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 b30:	75 2d                	jne    b5f <printf+0xa6>
        printint(fd, *ap, 10, 1);
 b32:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b35:	8b 00                	mov    (%eax),%eax
 b37:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 b3e:	00 
 b3f:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 b46:	00 
 b47:	89 44 24 04          	mov    %eax,0x4(%esp)
 b4b:	8b 45 08             	mov    0x8(%ebp),%eax
 b4e:	89 04 24             	mov    %eax,(%esp)
 b51:	e8 ae fe ff ff       	call   a04 <printint>
        ap++;
 b56:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b5a:	e9 e9 00 00 00       	jmp    c48 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 b5f:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 b63:	74 06                	je     b6b <printf+0xb2>
 b65:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 b69:	75 2d                	jne    b98 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 b6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b6e:	8b 00                	mov    (%eax),%eax
 b70:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 b77:	00 
 b78:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 b7f:	00 
 b80:	89 44 24 04          	mov    %eax,0x4(%esp)
 b84:	8b 45 08             	mov    0x8(%ebp),%eax
 b87:	89 04 24             	mov    %eax,(%esp)
 b8a:	e8 75 fe ff ff       	call   a04 <printint>
        ap++;
 b8f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b93:	e9 b0 00 00 00       	jmp    c48 <printf+0x18f>
      } else if(c == 's'){
 b98:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 b9c:	75 42                	jne    be0 <printf+0x127>
        s = (char*)*ap;
 b9e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 ba1:	8b 00                	mov    (%eax),%eax
 ba3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 ba6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 baa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 bae:	75 09                	jne    bb9 <printf+0x100>
          s = "(null)";
 bb0:	c7 45 f4 37 10 00 00 	movl   $0x1037,-0xc(%ebp)
        while(*s != 0){
 bb7:	eb 1c                	jmp    bd5 <printf+0x11c>
 bb9:	eb 1a                	jmp    bd5 <printf+0x11c>
          putc(fd, *s);
 bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bbe:	8a 00                	mov    (%eax),%al
 bc0:	0f be c0             	movsbl %al,%eax
 bc3:	89 44 24 04          	mov    %eax,0x4(%esp)
 bc7:	8b 45 08             	mov    0x8(%ebp),%eax
 bca:	89 04 24             	mov    %eax,(%esp)
 bcd:	e8 0a fe ff ff       	call   9dc <putc>
          s++;
 bd2:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 bd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 bd8:	8a 00                	mov    (%eax),%al
 bda:	84 c0                	test   %al,%al
 bdc:	75 dd                	jne    bbb <printf+0x102>
 bde:	eb 68                	jmp    c48 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 be0:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 be4:	75 1d                	jne    c03 <printf+0x14a>
        putc(fd, *ap);
 be6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 be9:	8b 00                	mov    (%eax),%eax
 beb:	0f be c0             	movsbl %al,%eax
 bee:	89 44 24 04          	mov    %eax,0x4(%esp)
 bf2:	8b 45 08             	mov    0x8(%ebp),%eax
 bf5:	89 04 24             	mov    %eax,(%esp)
 bf8:	e8 df fd ff ff       	call   9dc <putc>
        ap++;
 bfd:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 c01:	eb 45                	jmp    c48 <printf+0x18f>
      } else if(c == '%'){
 c03:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 c07:	75 17                	jne    c20 <printf+0x167>
        putc(fd, c);
 c09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 c0c:	0f be c0             	movsbl %al,%eax
 c0f:	89 44 24 04          	mov    %eax,0x4(%esp)
 c13:	8b 45 08             	mov    0x8(%ebp),%eax
 c16:	89 04 24             	mov    %eax,(%esp)
 c19:	e8 be fd ff ff       	call   9dc <putc>
 c1e:	eb 28                	jmp    c48 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 c20:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 c27:	00 
 c28:	8b 45 08             	mov    0x8(%ebp),%eax
 c2b:	89 04 24             	mov    %eax,(%esp)
 c2e:	e8 a9 fd ff ff       	call   9dc <putc>
        putc(fd, c);
 c33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 c36:	0f be c0             	movsbl %al,%eax
 c39:	89 44 24 04          	mov    %eax,0x4(%esp)
 c3d:	8b 45 08             	mov    0x8(%ebp),%eax
 c40:	89 04 24             	mov    %eax,(%esp)
 c43:	e8 94 fd ff ff       	call   9dc <putc>
      }
      state = 0;
 c48:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 c4f:	ff 45 f0             	incl   -0x10(%ebp)
 c52:	8b 55 0c             	mov    0xc(%ebp),%edx
 c55:	8b 45 f0             	mov    -0x10(%ebp),%eax
 c58:	01 d0                	add    %edx,%eax
 c5a:	8a 00                	mov    (%eax),%al
 c5c:	84 c0                	test   %al,%al
 c5e:	0f 85 77 fe ff ff    	jne    adb <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 c64:	c9                   	leave  
 c65:	c3                   	ret    
 c66:	90                   	nop
 c67:	90                   	nop

00000c68 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 c68:	55                   	push   %ebp
 c69:	89 e5                	mov    %esp,%ebp
 c6b:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 c6e:	8b 45 08             	mov    0x8(%ebp),%eax
 c71:	83 e8 08             	sub    $0x8,%eax
 c74:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c77:	a1 d4 13 00 00       	mov    0x13d4,%eax
 c7c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 c7f:	eb 24                	jmp    ca5 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 c81:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c84:	8b 00                	mov    (%eax),%eax
 c86:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 c89:	77 12                	ja     c9d <free+0x35>
 c8b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c8e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 c91:	77 24                	ja     cb7 <free+0x4f>
 c93:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c96:	8b 00                	mov    (%eax),%eax
 c98:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 c9b:	77 1a                	ja     cb7 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 c9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ca0:	8b 00                	mov    (%eax),%eax
 ca2:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ca5:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ca8:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 cab:	76 d4                	jbe    c81 <free+0x19>
 cad:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cb0:	8b 00                	mov    (%eax),%eax
 cb2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 cb5:	76 ca                	jbe    c81 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 cb7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cba:	8b 40 04             	mov    0x4(%eax),%eax
 cbd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 cc4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cc7:	01 c2                	add    %eax,%edx
 cc9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ccc:	8b 00                	mov    (%eax),%eax
 cce:	39 c2                	cmp    %eax,%edx
 cd0:	75 24                	jne    cf6 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 cd2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cd5:	8b 50 04             	mov    0x4(%eax),%edx
 cd8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cdb:	8b 00                	mov    (%eax),%eax
 cdd:	8b 40 04             	mov    0x4(%eax),%eax
 ce0:	01 c2                	add    %eax,%edx
 ce2:	8b 45 f8             	mov    -0x8(%ebp),%eax
 ce5:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 ce8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ceb:	8b 00                	mov    (%eax),%eax
 ced:	8b 10                	mov    (%eax),%edx
 cef:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cf2:	89 10                	mov    %edx,(%eax)
 cf4:	eb 0a                	jmp    d00 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 cf6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 cf9:	8b 10                	mov    (%eax),%edx
 cfb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 cfe:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 d00:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d03:	8b 40 04             	mov    0x4(%eax),%eax
 d06:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 d0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d10:	01 d0                	add    %edx,%eax
 d12:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 d15:	75 20                	jne    d37 <free+0xcf>
    p->s.size += bp->s.size;
 d17:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d1a:	8b 50 04             	mov    0x4(%eax),%edx
 d1d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d20:	8b 40 04             	mov    0x4(%eax),%eax
 d23:	01 c2                	add    %eax,%edx
 d25:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d28:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 d2b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d2e:	8b 10                	mov    (%eax),%edx
 d30:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d33:	89 10                	mov    %edx,(%eax)
 d35:	eb 08                	jmp    d3f <free+0xd7>
  } else
    p->s.ptr = bp;
 d37:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d3a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 d3d:	89 10                	mov    %edx,(%eax)
  freep = p;
 d3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d42:	a3 d4 13 00 00       	mov    %eax,0x13d4
}
 d47:	c9                   	leave  
 d48:	c3                   	ret    

00000d49 <morecore>:

static Header*
morecore(uint nu)
{
 d49:	55                   	push   %ebp
 d4a:	89 e5                	mov    %esp,%ebp
 d4c:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 d4f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 d56:	77 07                	ja     d5f <morecore+0x16>
    nu = 4096;
 d58:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 d5f:	8b 45 08             	mov    0x8(%ebp),%eax
 d62:	c1 e0 03             	shl    $0x3,%eax
 d65:	89 04 24             	mov    %eax,(%esp)
 d68:	e8 27 fc ff ff       	call   994 <sbrk>
 d6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 d70:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 d74:	75 07                	jne    d7d <morecore+0x34>
    return 0;
 d76:	b8 00 00 00 00       	mov    $0x0,%eax
 d7b:	eb 22                	jmp    d9f <morecore+0x56>
  hp = (Header*)p;
 d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d80:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 d83:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d86:	8b 55 08             	mov    0x8(%ebp),%edx
 d89:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 d8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d8f:	83 c0 08             	add    $0x8,%eax
 d92:	89 04 24             	mov    %eax,(%esp)
 d95:	e8 ce fe ff ff       	call   c68 <free>
  return freep;
 d9a:	a1 d4 13 00 00       	mov    0x13d4,%eax
}
 d9f:	c9                   	leave  
 da0:	c3                   	ret    

00000da1 <malloc>:

void*
malloc(uint nbytes)
{
 da1:	55                   	push   %ebp
 da2:	89 e5                	mov    %esp,%ebp
 da4:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 da7:	8b 45 08             	mov    0x8(%ebp),%eax
 daa:	83 c0 07             	add    $0x7,%eax
 dad:	c1 e8 03             	shr    $0x3,%eax
 db0:	40                   	inc    %eax
 db1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 db4:	a1 d4 13 00 00       	mov    0x13d4,%eax
 db9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 dbc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 dc0:	75 23                	jne    de5 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 dc2:	c7 45 f0 cc 13 00 00 	movl   $0x13cc,-0x10(%ebp)
 dc9:	8b 45 f0             	mov    -0x10(%ebp),%eax
 dcc:	a3 d4 13 00 00       	mov    %eax,0x13d4
 dd1:	a1 d4 13 00 00       	mov    0x13d4,%eax
 dd6:	a3 cc 13 00 00       	mov    %eax,0x13cc
    base.s.size = 0;
 ddb:	c7 05 d0 13 00 00 00 	movl   $0x0,0x13d0
 de2:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 de8:	8b 00                	mov    (%eax),%eax
 dea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 ded:	8b 45 f4             	mov    -0xc(%ebp),%eax
 df0:	8b 40 04             	mov    0x4(%eax),%eax
 df3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 df6:	72 4d                	jb     e45 <malloc+0xa4>
      if(p->s.size == nunits)
 df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dfb:	8b 40 04             	mov    0x4(%eax),%eax
 dfe:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 e01:	75 0c                	jne    e0f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e06:	8b 10                	mov    (%eax),%edx
 e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e0b:	89 10                	mov    %edx,(%eax)
 e0d:	eb 26                	jmp    e35 <malloc+0x94>
      else {
        p->s.size -= nunits;
 e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e12:	8b 40 04             	mov    0x4(%eax),%eax
 e15:	2b 45 ec             	sub    -0x14(%ebp),%eax
 e18:	89 c2                	mov    %eax,%edx
 e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e1d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 e20:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e23:	8b 40 04             	mov    0x4(%eax),%eax
 e26:	c1 e0 03             	shl    $0x3,%eax
 e29:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e2f:	8b 55 ec             	mov    -0x14(%ebp),%edx
 e32:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 e35:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e38:	a3 d4 13 00 00       	mov    %eax,0x13d4
      return (void*)(p + 1);
 e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e40:	83 c0 08             	add    $0x8,%eax
 e43:	eb 38                	jmp    e7d <malloc+0xdc>
    }
    if(p == freep)
 e45:	a1 d4 13 00 00       	mov    0x13d4,%eax
 e4a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 e4d:	75 1b                	jne    e6a <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 e4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 e52:	89 04 24             	mov    %eax,(%esp)
 e55:	e8 ef fe ff ff       	call   d49 <morecore>
 e5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
 e5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 e61:	75 07                	jne    e6a <malloc+0xc9>
        return 0;
 e63:	b8 00 00 00 00       	mov    $0x0,%eax
 e68:	eb 13                	jmp    e7d <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
 e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e73:	8b 00                	mov    (%eax),%eax
 e75:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 e78:	e9 70 ff ff ff       	jmp    ded <malloc+0x4c>
}
 e7d:	c9                   	leave  
 e7e:	c3                   	ret    
