
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
   d:	c7 44 24 04 10 0f 00 	movl   $0xf10,0x4(%esp)
  14:	00 
  15:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1c:	e8 28 0b 00 00       	call   b49 <printf>
    exit();
  21:	e8 76 09 00 00       	call   99c <exit>

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
  int pathsize = strlen(dst) + strlen(file) + 2; // './' dst.len + '/' + src.len + \0
  36:	8b 45 08             	mov    0x8(%ebp),%eax
  39:	89 04 24             	mov    %eax,(%esp)
  3c:	e8 92 07 00 00       	call   7d3 <strlen>
  41:	89 c3                	mov    %eax,%ebx
  43:	8b 45 0c             	mov    0xc(%ebp),%eax
  46:	89 04 24             	mov    %eax,(%esp)
  49:	e8 85 07 00 00       	call   7d3 <strlen>
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
  88:	e8 46 07 00 00       	call   7d3 <strlen>
  8d:	89 c2                	mov    %eax,%edx
  8f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  92:	89 54 24 08          	mov    %edx,0x8(%esp)
  96:	8b 55 08             	mov    0x8(%ebp),%edx
  99:	89 54 24 04          	mov    %edx,0x4(%esp)
  9d:	89 04 24             	mov    %eax,(%esp)
  a0:	e8 b0 08 00 00       	call   955 <memmove>
  memmove(path + strlen(dst), "/", 1);
  a5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  a8:	8b 45 08             	mov    0x8(%ebp),%eax
  ab:	89 04 24             	mov    %eax,(%esp)
  ae:	e8 20 07 00 00       	call   7d3 <strlen>
  b3:	01 d8                	add    %ebx,%eax
  b5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  bc:	00 
  bd:	c7 44 24 04 21 0f 00 	movl   $0xf21,0x4(%esp)
  c4:	00 
  c5:	89 04 24             	mov    %eax,(%esp)
  c8:	e8 88 08 00 00       	call   955 <memmove>
  memmove(path + strlen(dst) + 1, file, strlen(file));
  cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  d0:	89 04 24             	mov    %eax,(%esp)
  d3:	e8 fb 06 00 00       	call   7d3 <strlen>
  d8:	89 c3                	mov    %eax,%ebx
  da:	8b 7d dc             	mov    -0x24(%ebp),%edi
  dd:	8b 45 08             	mov    0x8(%ebp),%eax
  e0:	89 04 24             	mov    %eax,(%esp)
  e3:	e8 eb 06 00 00       	call   7d3 <strlen>
  e8:	40                   	inc    %eax
  e9:	8d 14 07             	lea    (%edi,%eax,1),%edx
  ec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  f7:	89 14 24             	mov    %edx,(%esp)
  fa:	e8 56 08 00 00       	call   955 <memmove>
  memmove(path + strlen(dst) + 1 + strlen(file), "\0", 1);
  ff:	8b 7d dc             	mov    -0x24(%ebp),%edi
 102:	8b 45 08             	mov    0x8(%ebp),%eax
 105:	89 04 24             	mov    %eax,(%esp)
 108:	e8 c6 06 00 00       	call   7d3 <strlen>
 10d:	89 c3                	mov    %eax,%ebx
 10f:	8b 45 0c             	mov    0xc(%ebp),%eax
 112:	89 04 24             	mov    %eax,(%esp)
 115:	e8 b9 06 00 00       	call   7d3 <strlen>
 11a:	01 d8                	add    %ebx,%eax
 11c:	40                   	inc    %eax
 11d:	01 f8                	add    %edi,%eax
 11f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 126:	00 
 127:	c7 44 24 04 23 0f 00 	movl   $0xf23,0x4(%esp)
 12e:	00 
 12f:	89 04 24             	mov    %eax,(%esp)
 132:	e8 1e 08 00 00       	call   955 <memmove>

  files[0] = open(file, O_RDONLY);
 137:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 13e:	00 
 13f:	8b 45 0c             	mov    0xc(%ebp),%eax
 142:	89 04 24             	mov    %eax,(%esp)
 145:	e8 92 08 00 00       	call   9dc <open>
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
 173:	e8 64 08 00 00       	call   9dc <open>
 178:	89 85 d4 fb ff ff    	mov    %eax,-0x42c(%ebp)
  if (files[1] == -1) { // Check if file opened (permissions problems ...) 
 17e:	8b 85 d4 fb ff ff    	mov    -0x42c(%ebp),%eax
 184:	83 f8 ff             	cmp    $0xffffffff,%eax
 187:	75 30                	jne    1b9 <cp+0x193>
    printf(1, "failed to create file |%s|\n", path);
 189:	8b 45 dc             	mov    -0x24(%ebp),%eax
 18c:	89 44 24 08          	mov    %eax,0x8(%esp)
 190:	c7 44 24 04 25 0f 00 	movl   $0xf25,0x4(%esp)
 197:	00 
 198:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 19f:	e8 a5 09 00 00       	call   b49 <printf>
      close(files[0]);
 1a4:	8b 85 d0 fb ff ff    	mov    -0x430(%ebp),%eax
 1aa:	89 04 24             	mov    %eax,(%esp)
 1ad:	e8 12 08 00 00       	call   9c4 <close>
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
 1d5:	e8 e2 07 00 00       	call   9bc <write>
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
 1f5:	e8 ba 07 00 00       	call   9b4 <read>
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
 252:	c7 04 24 44 0f 00 00 	movl   $0xf44,(%esp)
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
 27b:	c7 44 24 04 99 0f 00 	movl   $0xf99,0x4(%esp)
 282:	00 
 283:	89 04 24             	mov    %eax,(%esp)
 286:	e8 10 05 00 00       	call   79b <strcmp>
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
 2ba:	e8 4c 06 00 00       	call   90b <atoi>
 2bf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    }
    if (strcmp(argv[i], "-m") == 0) {
 2c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 2cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2cf:	01 d0                	add    %edx,%eax
 2d1:	8b 00                	mov    (%eax),%eax
 2d3:	c7 44 24 04 9c 0f 00 	movl   $0xf9c,0x4(%esp)
 2da:	00 
 2db:	89 04 24             	mov    %eax,(%esp)
 2de:	e8 b8 04 00 00       	call   79b <strcmp>
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
 312:	e8 f4 05 00 00       	call   90b <atoi>
 317:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    }
    if (strcmp(argv[i], "-d") == 0) {
 31a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 31d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 324:	8b 45 0c             	mov    0xc(%ebp),%eax
 327:	01 d0                	add    %edx,%eax
 329:	8b 00                	mov    (%eax),%eax
 32b:	c7 44 24 04 9f 0f 00 	movl   $0xf9f,0x4(%esp)
 332:	00 
 333:	89 04 24             	mov    %eax,(%esp)
 336:	e8 60 04 00 00       	call   79b <strcmp>
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
 36a:	e8 9c 05 00 00       	call   90b <atoi>
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
 3b7:	c7 44 24 04 a4 0f 00 	movl   $0xfa4,0x4(%esp)
 3be:	00 
 3bf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3c6:	e8 7e 07 00 00       	call   b49 <printf>

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
 3fc:	e8 43 06 00 00       	call   a44 <ccreate>
 401:	83 f8 01             	cmp    $0x1,%eax
 404:	75 22                	jne    428 <create+0x201>
    printf(1, "Created container %s\n", argv[2]); 
 406:	8b 45 0c             	mov    0xc(%ebp),%eax
 409:	83 c0 08             	add    $0x8,%eax
 40c:	8b 00                	mov    (%eax),%eax
 40e:	89 44 24 08          	mov    %eax,0x8(%esp)
 412:	c7 44 24 04 d3 0f 00 	movl   $0xfd3,0x4(%esp)
 419:	00 
 41a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 421:	e8 23 07 00 00       	call   b49 <printf>
 426:	eb 20                	jmp    448 <create+0x221>
  } else {
    printf(1, "Failed to create container %s\n", argv[2]); 
 428:	8b 45 0c             	mov    0xc(%ebp),%eax
 42b:	83 c0 08             	add    $0x8,%eax
 42e:	8b 00                	mov    (%eax),%eax
 430:	89 44 24 08          	mov    %eax,0x8(%esp)
 434:	c7 44 24 04 ec 0f 00 	movl   $0xfec,0x4(%esp)
 43b:	00 
 43c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 443:	e8 01 07 00 00       	call   b49 <printf>
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
 4a3:	c7 44 24 04 0c 10 00 	movl   $0x100c,0x4(%esp)
 4aa:	00 
 4ab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 4b2:	e8 92 06 00 00       	call   b49 <printf>
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
 4d7:	c7 04 24 40 10 00 00 	movl   $0x1040,(%esp)
 4de:	e8 1d fb ff ff       	call   0 <usage>

  for (i = 3, k = 0; i < argc; i++, k++) {
 4e3:	c7 45 f4 03 00 00 00 	movl   $0x3,-0xc(%ebp)
 4ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 4f1:	e9 44 01 00 00       	jmp    63a <start+0x173>
    printf(1, "%d\n", strlen(argv[i]));
 4f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4f9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 500:	8b 45 0c             	mov    0xc(%ebp),%eax
 503:	01 d0                	add    %edx,%eax
 505:	8b 00                	mov    (%eax),%eax
 507:	89 04 24             	mov    %eax,(%esp)
 50a:	e8 c4 02 00 00       	call   7d3 <strlen>
 50f:	89 44 24 08          	mov    %eax,0x8(%esp)
 513:	c7 44 24 04 68 10 00 	movl   $0x1068,0x4(%esp)
 51a:	00 
 51b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 522:	e8 22 06 00 00       	call   b49 <printf>
    args[k] = malloc(strlen(argv[i]) + 1);     
 527:	8b 45 f4             	mov    -0xc(%ebp),%eax
 52a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 531:	8b 45 0c             	mov    0xc(%ebp),%eax
 534:	01 d0                	add    %edx,%eax
 536:	8b 00                	mov    (%eax),%eax
 538:	89 04 24             	mov    %eax,(%esp)
 53b:	e8 93 02 00 00       	call   7d3 <strlen>
 540:	40                   	inc    %eax
 541:	89 04 24             	mov    %eax,(%esp)
 544:	e8 e8 08 00 00       	call   e31 <malloc>
 549:	8b 55 f0             	mov    -0x10(%ebp),%edx
 54c:	89 84 95 70 ff ff ff 	mov    %eax,-0x90(%ebp,%edx,4)
    memmove(args[k], argv[i], strlen(argv[i])); 
 553:	8b 45 f4             	mov    -0xc(%ebp),%eax
 556:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 55d:	8b 45 0c             	mov    0xc(%ebp),%eax
 560:	01 d0                	add    %edx,%eax
 562:	8b 00                	mov    (%eax),%eax
 564:	89 04 24             	mov    %eax,(%esp)
 567:	e8 67 02 00 00       	call   7d3 <strlen>
 56c:	89 c1                	mov    %eax,%ecx
 56e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 571:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 578:	8b 45 0c             	mov    0xc(%ebp),%eax
 57b:	01 d0                	add    %edx,%eax
 57d:	8b 10                	mov    (%eax),%edx
 57f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 582:	8b 84 85 70 ff ff ff 	mov    -0x90(%ebp,%eax,4),%eax
 589:	89 4c 24 08          	mov    %ecx,0x8(%esp)
 58d:	89 54 24 04          	mov    %edx,0x4(%esp)
 591:	89 04 24             	mov    %eax,(%esp)
 594:	e8 bc 03 00 00       	call   955 <memmove>
    printf(1, "test\n\n");
 599:	c7 44 24 04 6c 10 00 	movl   $0x106c,0x4(%esp)
 5a0:	00 
 5a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 5a8:	e8 9c 05 00 00       	call   b49 <printf>
    memmove(args[k] + strlen(argv[i]), "\0", 1);
 5ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5b0:	8b 9c 85 70 ff ff ff 	mov    -0x90(%ebp,%eax,4),%ebx
 5b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5ba:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 5c1:	8b 45 0c             	mov    0xc(%ebp),%eax
 5c4:	01 d0                	add    %edx,%eax
 5c6:	8b 00                	mov    (%eax),%eax
 5c8:	89 04 24             	mov    %eax,(%esp)
 5cb:	e8 03 02 00 00       	call   7d3 <strlen>
 5d0:	01 d8                	add    %ebx,%eax
 5d2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 5d9:	00 
 5da:	c7 44 24 04 23 0f 00 	movl   $0xf23,0x4(%esp)
 5e1:	00 
 5e2:	89 04 24             	mov    %eax,(%esp)
 5e5:	e8 6b 03 00 00       	call   955 <memmove>
    printf(1, "test2\n\n");
 5ea:	c7 44 24 04 73 10 00 	movl   $0x1073,0x4(%esp)
 5f1:	00 
 5f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 5f9:	e8 4b 05 00 00       	call   b49 <printf>
    printf(1, "\t%s\n", args[k]);
 5fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
 601:	8b 84 85 70 ff ff ff 	mov    -0x90(%ebp,%eax,4),%eax
 608:	89 44 24 08          	mov    %eax,0x8(%esp)
 60c:	c7 44 24 04 7b 10 00 	movl   $0x107b,0x4(%esp)
 613:	00 
 614:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 61b:	e8 29 05 00 00       	call   b49 <printf>
    printf(1, "test3\n\n");
 620:	c7 44 24 04 80 10 00 	movl   $0x1080,0x4(%esp)
 627:	00 
 628:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 62f:	e8 15 05 00 00       	call   b49 <printf>
  int i, k;

  if (argc < 4)
    usage("ctool start <name> prog arg1 [arg2 ...]");

  for (i = 3, k = 0; i < argc; i++, k++) {
 634:	ff 45 f4             	incl   -0xc(%ebp)
 637:	ff 45 f0             	incl   -0x10(%ebp)
 63a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 63d:	3b 45 08             	cmp    0x8(%ebp),%eax
 640:	0f 8c b0 fe ff ff    	jl     4f6 <start+0x2f>
    printf(1, "test2\n\n");
    printf(1, "\t%s\n", args[k]);
    printf(1, "test3\n\n");
  }

  if (cstart(argv[2], args, (argc - 3)) != 1) {
 646:	8b 45 08             	mov    0x8(%ebp),%eax
 649:	8d 50 fd             	lea    -0x3(%eax),%edx
 64c:	8b 45 0c             	mov    0xc(%ebp),%eax
 64f:	83 c0 08             	add    $0x8,%eax
 652:	8b 00                	mov    (%eax),%eax
 654:	89 54 24 08          	mov    %edx,0x8(%esp)
 658:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
 65e:	89 54 24 04          	mov    %edx,0x4(%esp)
 662:	89 04 24             	mov    %eax,(%esp)
 665:	e8 e2 03 00 00       	call   a4c <cstart>
 66a:	83 f8 01             	cmp    $0x1,%eax
 66d:	74 20                	je     68f <start+0x1c8>
    printf(1, "Failed to start container %s\n", argv[2]);     
 66f:	8b 45 0c             	mov    0xc(%ebp),%eax
 672:	83 c0 08             	add    $0x8,%eax
 675:	8b 00                	mov    (%eax),%eax
 677:	89 44 24 08          	mov    %eax,0x8(%esp)
 67b:	c7 44 24 04 88 10 00 	movl   $0x1088,0x4(%esp)
 682:	00 
 683:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 68a:	e8 ba 04 00 00       	call   b49 <printf>
  }
}
 68f:	81 c4 a4 00 00 00    	add    $0xa4,%esp
 695:	5b                   	pop    %ebx
 696:	5d                   	pop    %ebp
 697:	c3                   	ret    

00000698 <pause>:

void
pause(int argc, char *argv[])
{
 698:	55                   	push   %ebp
 699:	89 e5                	mov    %esp,%ebp
  
}
 69b:	5d                   	pop    %ebp
 69c:	c3                   	ret    

0000069d <resume>:

void
resume(int argc, char *argv[])
{
 69d:	55                   	push   %ebp
 69e:	89 e5                	mov    %esp,%ebp
  
}
 6a0:	5d                   	pop    %ebp
 6a1:	c3                   	ret    

000006a2 <stop>:

void
stop(int argc, char *argv[])
{
 6a2:	55                   	push   %ebp
 6a3:	89 e5                	mov    %esp,%ebp
  
}
 6a5:	5d                   	pop    %ebp
 6a6:	c3                   	ret    

000006a7 <info>:

void
info(int argc, char *argv[])
{
 6a7:	55                   	push   %ebp
 6a8:	89 e5                	mov    %esp,%ebp
  
}
 6aa:	5d                   	pop    %ebp
 6ab:	c3                   	ret    

000006ac <main>:

int
main(int argc, char *argv[])
{
 6ac:	55                   	push   %ebp
 6ad:	89 e5                	mov    %esp,%ebp
 6af:	83 e4 f0             	and    $0xfffffff0,%esp
 6b2:	83 ec 10             	sub    $0x10,%esp

  if (argc < 3) {
 6b5:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 6b9:	7f 11                	jg     6cc <main+0x20>
    usage("<tool> <cmd> [<arg> ...]");
 6bb:	c7 04 24 a6 10 00 00 	movl   $0x10a6,(%esp)
 6c2:	e8 39 f9 ff ff       	call   0 <usage>
    exit();
 6c7:	e8 d0 02 00 00       	call   99c <exit>
  }

  if (strcmp(argv[1], "create") == 0)
 6cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 6cf:	83 c0 04             	add    $0x4,%eax
 6d2:	8b 00                	mov    (%eax),%eax
 6d4:	c7 44 24 04 bf 10 00 	movl   $0x10bf,0x4(%esp)
 6db:	00 
 6dc:	89 04 24             	mov    %eax,(%esp)
 6df:	e8 b7 00 00 00       	call   79b <strcmp>
 6e4:	85 c0                	test   %eax,%eax
 6e6:	75 14                	jne    6fc <main+0x50>
    create(argc, argv);
 6e8:	8b 45 0c             	mov    0xc(%ebp),%eax
 6eb:	89 44 24 04          	mov    %eax,0x4(%esp)
 6ef:	8b 45 08             	mov    0x8(%ebp),%eax
 6f2:	89 04 24             	mov    %eax,(%esp)
 6f5:	e8 2d fb ff ff       	call   227 <create>
 6fa:	eb 44                	jmp    740 <main+0x94>
  else if (strcmp(argv[1], "start") == 0)
 6fc:	8b 45 0c             	mov    0xc(%ebp),%eax
 6ff:	83 c0 04             	add    $0x4,%eax
 702:	8b 00                	mov    (%eax),%eax
 704:	c7 44 24 04 c6 10 00 	movl   $0x10c6,0x4(%esp)
 70b:	00 
 70c:	89 04 24             	mov    %eax,(%esp)
 70f:	e8 87 00 00 00       	call   79b <strcmp>
 714:	85 c0                	test   %eax,%eax
 716:	75 14                	jne    72c <main+0x80>
    start(argc, argv);
 718:	8b 45 0c             	mov    0xc(%ebp),%eax
 71b:	89 44 24 04          	mov    %eax,0x4(%esp)
 71f:	8b 45 08             	mov    0x8(%ebp),%eax
 722:	89 04 24             	mov    %eax,(%esp)
 725:	e8 9d fd ff ff       	call   4c7 <start>
 72a:	eb 14                	jmp    740 <main+0x94>
  else 
    printf(1, "ctool: command not found.\n");   
 72c:	c7 44 24 04 cc 10 00 	movl   $0x10cc,0x4(%esp)
 733:	00 
 734:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 73b:	e8 09 04 00 00       	call   b49 <printf>

  exit();
 740:	e8 57 02 00 00       	call   99c <exit>
 745:	90                   	nop
 746:	90                   	nop
 747:	90                   	nop

00000748 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 748:	55                   	push   %ebp
 749:	89 e5                	mov    %esp,%ebp
 74b:	57                   	push   %edi
 74c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 74d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 750:	8b 55 10             	mov    0x10(%ebp),%edx
 753:	8b 45 0c             	mov    0xc(%ebp),%eax
 756:	89 cb                	mov    %ecx,%ebx
 758:	89 df                	mov    %ebx,%edi
 75a:	89 d1                	mov    %edx,%ecx
 75c:	fc                   	cld    
 75d:	f3 aa                	rep stos %al,%es:(%edi)
 75f:	89 ca                	mov    %ecx,%edx
 761:	89 fb                	mov    %edi,%ebx
 763:	89 5d 08             	mov    %ebx,0x8(%ebp)
 766:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 769:	5b                   	pop    %ebx
 76a:	5f                   	pop    %edi
 76b:	5d                   	pop    %ebp
 76c:	c3                   	ret    

0000076d <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 76d:	55                   	push   %ebp
 76e:	89 e5                	mov    %esp,%ebp
 770:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 773:	8b 45 08             	mov    0x8(%ebp),%eax
 776:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 779:	90                   	nop
 77a:	8b 45 08             	mov    0x8(%ebp),%eax
 77d:	8d 50 01             	lea    0x1(%eax),%edx
 780:	89 55 08             	mov    %edx,0x8(%ebp)
 783:	8b 55 0c             	mov    0xc(%ebp),%edx
 786:	8d 4a 01             	lea    0x1(%edx),%ecx
 789:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 78c:	8a 12                	mov    (%edx),%dl
 78e:	88 10                	mov    %dl,(%eax)
 790:	8a 00                	mov    (%eax),%al
 792:	84 c0                	test   %al,%al
 794:	75 e4                	jne    77a <strcpy+0xd>
    ;
  return os;
 796:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 799:	c9                   	leave  
 79a:	c3                   	ret    

0000079b <strcmp>:

int
strcmp(const char *p, const char *q)
{
 79b:	55                   	push   %ebp
 79c:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 79e:	eb 06                	jmp    7a6 <strcmp+0xb>
    p++, q++;
 7a0:	ff 45 08             	incl   0x8(%ebp)
 7a3:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 7a6:	8b 45 08             	mov    0x8(%ebp),%eax
 7a9:	8a 00                	mov    (%eax),%al
 7ab:	84 c0                	test   %al,%al
 7ad:	74 0e                	je     7bd <strcmp+0x22>
 7af:	8b 45 08             	mov    0x8(%ebp),%eax
 7b2:	8a 10                	mov    (%eax),%dl
 7b4:	8b 45 0c             	mov    0xc(%ebp),%eax
 7b7:	8a 00                	mov    (%eax),%al
 7b9:	38 c2                	cmp    %al,%dl
 7bb:	74 e3                	je     7a0 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 7bd:	8b 45 08             	mov    0x8(%ebp),%eax
 7c0:	8a 00                	mov    (%eax),%al
 7c2:	0f b6 d0             	movzbl %al,%edx
 7c5:	8b 45 0c             	mov    0xc(%ebp),%eax
 7c8:	8a 00                	mov    (%eax),%al
 7ca:	0f b6 c0             	movzbl %al,%eax
 7cd:	29 c2                	sub    %eax,%edx
 7cf:	89 d0                	mov    %edx,%eax
}
 7d1:	5d                   	pop    %ebp
 7d2:	c3                   	ret    

000007d3 <strlen>:

uint
strlen(char *s)
{
 7d3:	55                   	push   %ebp
 7d4:	89 e5                	mov    %esp,%ebp
 7d6:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 7d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 7e0:	eb 03                	jmp    7e5 <strlen+0x12>
 7e2:	ff 45 fc             	incl   -0x4(%ebp)
 7e5:	8b 55 fc             	mov    -0x4(%ebp),%edx
 7e8:	8b 45 08             	mov    0x8(%ebp),%eax
 7eb:	01 d0                	add    %edx,%eax
 7ed:	8a 00                	mov    (%eax),%al
 7ef:	84 c0                	test   %al,%al
 7f1:	75 ef                	jne    7e2 <strlen+0xf>
    ;
  return n;
 7f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 7f6:	c9                   	leave  
 7f7:	c3                   	ret    

000007f8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 7f8:	55                   	push   %ebp
 7f9:	89 e5                	mov    %esp,%ebp
 7fb:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 7fe:	8b 45 10             	mov    0x10(%ebp),%eax
 801:	89 44 24 08          	mov    %eax,0x8(%esp)
 805:	8b 45 0c             	mov    0xc(%ebp),%eax
 808:	89 44 24 04          	mov    %eax,0x4(%esp)
 80c:	8b 45 08             	mov    0x8(%ebp),%eax
 80f:	89 04 24             	mov    %eax,(%esp)
 812:	e8 31 ff ff ff       	call   748 <stosb>
  return dst;
 817:	8b 45 08             	mov    0x8(%ebp),%eax
}
 81a:	c9                   	leave  
 81b:	c3                   	ret    

0000081c <strchr>:

char*
strchr(const char *s, char c)
{
 81c:	55                   	push   %ebp
 81d:	89 e5                	mov    %esp,%ebp
 81f:	83 ec 04             	sub    $0x4,%esp
 822:	8b 45 0c             	mov    0xc(%ebp),%eax
 825:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 828:	eb 12                	jmp    83c <strchr+0x20>
    if(*s == c)
 82a:	8b 45 08             	mov    0x8(%ebp),%eax
 82d:	8a 00                	mov    (%eax),%al
 82f:	3a 45 fc             	cmp    -0x4(%ebp),%al
 832:	75 05                	jne    839 <strchr+0x1d>
      return (char*)s;
 834:	8b 45 08             	mov    0x8(%ebp),%eax
 837:	eb 11                	jmp    84a <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 839:	ff 45 08             	incl   0x8(%ebp)
 83c:	8b 45 08             	mov    0x8(%ebp),%eax
 83f:	8a 00                	mov    (%eax),%al
 841:	84 c0                	test   %al,%al
 843:	75 e5                	jne    82a <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 845:	b8 00 00 00 00       	mov    $0x0,%eax
}
 84a:	c9                   	leave  
 84b:	c3                   	ret    

0000084c <gets>:

char*
gets(char *buf, int max)
{
 84c:	55                   	push   %ebp
 84d:	89 e5                	mov    %esp,%ebp
 84f:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 852:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 859:	eb 49                	jmp    8a4 <gets+0x58>
    cc = read(0, &c, 1);
 85b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 862:	00 
 863:	8d 45 ef             	lea    -0x11(%ebp),%eax
 866:	89 44 24 04          	mov    %eax,0x4(%esp)
 86a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 871:	e8 3e 01 00 00       	call   9b4 <read>
 876:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 879:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 87d:	7f 02                	jg     881 <gets+0x35>
      break;
 87f:	eb 2c                	jmp    8ad <gets+0x61>
    buf[i++] = c;
 881:	8b 45 f4             	mov    -0xc(%ebp),%eax
 884:	8d 50 01             	lea    0x1(%eax),%edx
 887:	89 55 f4             	mov    %edx,-0xc(%ebp)
 88a:	89 c2                	mov    %eax,%edx
 88c:	8b 45 08             	mov    0x8(%ebp),%eax
 88f:	01 c2                	add    %eax,%edx
 891:	8a 45 ef             	mov    -0x11(%ebp),%al
 894:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 896:	8a 45 ef             	mov    -0x11(%ebp),%al
 899:	3c 0a                	cmp    $0xa,%al
 89b:	74 10                	je     8ad <gets+0x61>
 89d:	8a 45 ef             	mov    -0x11(%ebp),%al
 8a0:	3c 0d                	cmp    $0xd,%al
 8a2:	74 09                	je     8ad <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 8a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8a7:	40                   	inc    %eax
 8a8:	3b 45 0c             	cmp    0xc(%ebp),%eax
 8ab:	7c ae                	jl     85b <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 8ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
 8b0:	8b 45 08             	mov    0x8(%ebp),%eax
 8b3:	01 d0                	add    %edx,%eax
 8b5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 8b8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 8bb:	c9                   	leave  
 8bc:	c3                   	ret    

000008bd <stat>:

int
stat(char *n, struct stat *st)
{
 8bd:	55                   	push   %ebp
 8be:	89 e5                	mov    %esp,%ebp
 8c0:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 8c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 8ca:	00 
 8cb:	8b 45 08             	mov    0x8(%ebp),%eax
 8ce:	89 04 24             	mov    %eax,(%esp)
 8d1:	e8 06 01 00 00       	call   9dc <open>
 8d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 8d9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8dd:	79 07                	jns    8e6 <stat+0x29>
    return -1;
 8df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 8e4:	eb 23                	jmp    909 <stat+0x4c>
  r = fstat(fd, st);
 8e6:	8b 45 0c             	mov    0xc(%ebp),%eax
 8e9:	89 44 24 04          	mov    %eax,0x4(%esp)
 8ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8f0:	89 04 24             	mov    %eax,(%esp)
 8f3:	e8 fc 00 00 00       	call   9f4 <fstat>
 8f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 8fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8fe:	89 04 24             	mov    %eax,(%esp)
 901:	e8 be 00 00 00       	call   9c4 <close>
  return r;
 906:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 909:	c9                   	leave  
 90a:	c3                   	ret    

0000090b <atoi>:

int
atoi(const char *s)
{
 90b:	55                   	push   %ebp
 90c:	89 e5                	mov    %esp,%ebp
 90e:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 911:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 918:	eb 24                	jmp    93e <atoi+0x33>
    n = n*10 + *s++ - '0';
 91a:	8b 55 fc             	mov    -0x4(%ebp),%edx
 91d:	89 d0                	mov    %edx,%eax
 91f:	c1 e0 02             	shl    $0x2,%eax
 922:	01 d0                	add    %edx,%eax
 924:	01 c0                	add    %eax,%eax
 926:	89 c1                	mov    %eax,%ecx
 928:	8b 45 08             	mov    0x8(%ebp),%eax
 92b:	8d 50 01             	lea    0x1(%eax),%edx
 92e:	89 55 08             	mov    %edx,0x8(%ebp)
 931:	8a 00                	mov    (%eax),%al
 933:	0f be c0             	movsbl %al,%eax
 936:	01 c8                	add    %ecx,%eax
 938:	83 e8 30             	sub    $0x30,%eax
 93b:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 93e:	8b 45 08             	mov    0x8(%ebp),%eax
 941:	8a 00                	mov    (%eax),%al
 943:	3c 2f                	cmp    $0x2f,%al
 945:	7e 09                	jle    950 <atoi+0x45>
 947:	8b 45 08             	mov    0x8(%ebp),%eax
 94a:	8a 00                	mov    (%eax),%al
 94c:	3c 39                	cmp    $0x39,%al
 94e:	7e ca                	jle    91a <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 950:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 953:	c9                   	leave  
 954:	c3                   	ret    

00000955 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 955:	55                   	push   %ebp
 956:	89 e5                	mov    %esp,%ebp
 958:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 95b:	8b 45 08             	mov    0x8(%ebp),%eax
 95e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 961:	8b 45 0c             	mov    0xc(%ebp),%eax
 964:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 967:	eb 16                	jmp    97f <memmove+0x2a>
    *dst++ = *src++;
 969:	8b 45 fc             	mov    -0x4(%ebp),%eax
 96c:	8d 50 01             	lea    0x1(%eax),%edx
 96f:	89 55 fc             	mov    %edx,-0x4(%ebp)
 972:	8b 55 f8             	mov    -0x8(%ebp),%edx
 975:	8d 4a 01             	lea    0x1(%edx),%ecx
 978:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 97b:	8a 12                	mov    (%edx),%dl
 97d:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 97f:	8b 45 10             	mov    0x10(%ebp),%eax
 982:	8d 50 ff             	lea    -0x1(%eax),%edx
 985:	89 55 10             	mov    %edx,0x10(%ebp)
 988:	85 c0                	test   %eax,%eax
 98a:	7f dd                	jg     969 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 98c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 98f:	c9                   	leave  
 990:	c3                   	ret    
 991:	90                   	nop
 992:	90                   	nop
 993:	90                   	nop

00000994 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 994:	b8 01 00 00 00       	mov    $0x1,%eax
 999:	cd 40                	int    $0x40
 99b:	c3                   	ret    

0000099c <exit>:
SYSCALL(exit)
 99c:	b8 02 00 00 00       	mov    $0x2,%eax
 9a1:	cd 40                	int    $0x40
 9a3:	c3                   	ret    

000009a4 <wait>:
SYSCALL(wait)
 9a4:	b8 03 00 00 00       	mov    $0x3,%eax
 9a9:	cd 40                	int    $0x40
 9ab:	c3                   	ret    

000009ac <pipe>:
SYSCALL(pipe)
 9ac:	b8 04 00 00 00       	mov    $0x4,%eax
 9b1:	cd 40                	int    $0x40
 9b3:	c3                   	ret    

000009b4 <read>:
SYSCALL(read)
 9b4:	b8 05 00 00 00       	mov    $0x5,%eax
 9b9:	cd 40                	int    $0x40
 9bb:	c3                   	ret    

000009bc <write>:
SYSCALL(write)
 9bc:	b8 10 00 00 00       	mov    $0x10,%eax
 9c1:	cd 40                	int    $0x40
 9c3:	c3                   	ret    

000009c4 <close>:
SYSCALL(close)
 9c4:	b8 15 00 00 00       	mov    $0x15,%eax
 9c9:	cd 40                	int    $0x40
 9cb:	c3                   	ret    

000009cc <kill>:
SYSCALL(kill)
 9cc:	b8 06 00 00 00       	mov    $0x6,%eax
 9d1:	cd 40                	int    $0x40
 9d3:	c3                   	ret    

000009d4 <exec>:
SYSCALL(exec)
 9d4:	b8 07 00 00 00       	mov    $0x7,%eax
 9d9:	cd 40                	int    $0x40
 9db:	c3                   	ret    

000009dc <open>:
SYSCALL(open)
 9dc:	b8 0f 00 00 00       	mov    $0xf,%eax
 9e1:	cd 40                	int    $0x40
 9e3:	c3                   	ret    

000009e4 <mknod>:
SYSCALL(mknod)
 9e4:	b8 11 00 00 00       	mov    $0x11,%eax
 9e9:	cd 40                	int    $0x40
 9eb:	c3                   	ret    

000009ec <unlink>:
SYSCALL(unlink)
 9ec:	b8 12 00 00 00       	mov    $0x12,%eax
 9f1:	cd 40                	int    $0x40
 9f3:	c3                   	ret    

000009f4 <fstat>:
SYSCALL(fstat)
 9f4:	b8 08 00 00 00       	mov    $0x8,%eax
 9f9:	cd 40                	int    $0x40
 9fb:	c3                   	ret    

000009fc <link>:
SYSCALL(link)
 9fc:	b8 13 00 00 00       	mov    $0x13,%eax
 a01:	cd 40                	int    $0x40
 a03:	c3                   	ret    

00000a04 <mkdir>:
SYSCALL(mkdir)
 a04:	b8 14 00 00 00       	mov    $0x14,%eax
 a09:	cd 40                	int    $0x40
 a0b:	c3                   	ret    

00000a0c <chdir>:
SYSCALL(chdir)
 a0c:	b8 09 00 00 00       	mov    $0x9,%eax
 a11:	cd 40                	int    $0x40
 a13:	c3                   	ret    

00000a14 <dup>:
SYSCALL(dup)
 a14:	b8 0a 00 00 00       	mov    $0xa,%eax
 a19:	cd 40                	int    $0x40
 a1b:	c3                   	ret    

00000a1c <getpid>:
SYSCALL(getpid)
 a1c:	b8 0b 00 00 00       	mov    $0xb,%eax
 a21:	cd 40                	int    $0x40
 a23:	c3                   	ret    

00000a24 <sbrk>:
SYSCALL(sbrk)
 a24:	b8 0c 00 00 00       	mov    $0xc,%eax
 a29:	cd 40                	int    $0x40
 a2b:	c3                   	ret    

00000a2c <sleep>:
SYSCALL(sleep)
 a2c:	b8 0d 00 00 00       	mov    $0xd,%eax
 a31:	cd 40                	int    $0x40
 a33:	c3                   	ret    

00000a34 <uptime>:
SYSCALL(uptime)
 a34:	b8 0e 00 00 00       	mov    $0xe,%eax
 a39:	cd 40                	int    $0x40
 a3b:	c3                   	ret    

00000a3c <getticks>:
SYSCALL(getticks)
 a3c:	b8 16 00 00 00       	mov    $0x16,%eax
 a41:	cd 40                	int    $0x40
 a43:	c3                   	ret    

00000a44 <ccreate>:
SYSCALL(ccreate)
 a44:	b8 17 00 00 00       	mov    $0x17,%eax
 a49:	cd 40                	int    $0x40
 a4b:	c3                   	ret    

00000a4c <cstart>:
SYSCALL(cstart)
 a4c:	b8 19 00 00 00       	mov    $0x19,%eax
 a51:	cd 40                	int    $0x40
 a53:	c3                   	ret    

00000a54 <cstop>:
SYSCALL(cstop)
 a54:	b8 18 00 00 00       	mov    $0x18,%eax
 a59:	cd 40                	int    $0x40
 a5b:	c3                   	ret    

00000a5c <cpause>:
SYSCALL(cpause)
 a5c:	b8 1b 00 00 00       	mov    $0x1b,%eax
 a61:	cd 40                	int    $0x40
 a63:	c3                   	ret    

00000a64 <cinfo>:
SYSCALL(cinfo)
 a64:	b8 1a 00 00 00       	mov    $0x1a,%eax
 a69:	cd 40                	int    $0x40
 a6b:	c3                   	ret    

00000a6c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 a6c:	55                   	push   %ebp
 a6d:	89 e5                	mov    %esp,%ebp
 a6f:	83 ec 18             	sub    $0x18,%esp
 a72:	8b 45 0c             	mov    0xc(%ebp),%eax
 a75:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 a78:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 a7f:	00 
 a80:	8d 45 f4             	lea    -0xc(%ebp),%eax
 a83:	89 44 24 04          	mov    %eax,0x4(%esp)
 a87:	8b 45 08             	mov    0x8(%ebp),%eax
 a8a:	89 04 24             	mov    %eax,(%esp)
 a8d:	e8 2a ff ff ff       	call   9bc <write>
}
 a92:	c9                   	leave  
 a93:	c3                   	ret    

00000a94 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 a94:	55                   	push   %ebp
 a95:	89 e5                	mov    %esp,%ebp
 a97:	56                   	push   %esi
 a98:	53                   	push   %ebx
 a99:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 a9c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 aa3:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 aa7:	74 17                	je     ac0 <printint+0x2c>
 aa9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 aad:	79 11                	jns    ac0 <printint+0x2c>
    neg = 1;
 aaf:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 ab6:	8b 45 0c             	mov    0xc(%ebp),%eax
 ab9:	f7 d8                	neg    %eax
 abb:	89 45 ec             	mov    %eax,-0x14(%ebp)
 abe:	eb 06                	jmp    ac6 <printint+0x32>
  } else {
    x = xx;
 ac0:	8b 45 0c             	mov    0xc(%ebp),%eax
 ac3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 ac6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 acd:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 ad0:	8d 41 01             	lea    0x1(%ecx),%eax
 ad3:	89 45 f4             	mov    %eax,-0xc(%ebp)
 ad6:	8b 5d 10             	mov    0x10(%ebp),%ebx
 ad9:	8b 45 ec             	mov    -0x14(%ebp),%eax
 adc:	ba 00 00 00 00       	mov    $0x0,%edx
 ae1:	f7 f3                	div    %ebx
 ae3:	89 d0                	mov    %edx,%eax
 ae5:	8a 80 68 14 00 00    	mov    0x1468(%eax),%al
 aeb:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 aef:	8b 75 10             	mov    0x10(%ebp),%esi
 af2:	8b 45 ec             	mov    -0x14(%ebp),%eax
 af5:	ba 00 00 00 00       	mov    $0x0,%edx
 afa:	f7 f6                	div    %esi
 afc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 aff:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 b03:	75 c8                	jne    acd <printint+0x39>
  if(neg)
 b05:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 b09:	74 10                	je     b1b <printint+0x87>
    buf[i++] = '-';
 b0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b0e:	8d 50 01             	lea    0x1(%eax),%edx
 b11:	89 55 f4             	mov    %edx,-0xc(%ebp)
 b14:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 b19:	eb 1e                	jmp    b39 <printint+0xa5>
 b1b:	eb 1c                	jmp    b39 <printint+0xa5>
    putc(fd, buf[i]);
 b1d:	8d 55 dc             	lea    -0x24(%ebp),%edx
 b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b23:	01 d0                	add    %edx,%eax
 b25:	8a 00                	mov    (%eax),%al
 b27:	0f be c0             	movsbl %al,%eax
 b2a:	89 44 24 04          	mov    %eax,0x4(%esp)
 b2e:	8b 45 08             	mov    0x8(%ebp),%eax
 b31:	89 04 24             	mov    %eax,(%esp)
 b34:	e8 33 ff ff ff       	call   a6c <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 b39:	ff 4d f4             	decl   -0xc(%ebp)
 b3c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b40:	79 db                	jns    b1d <printint+0x89>
    putc(fd, buf[i]);
}
 b42:	83 c4 30             	add    $0x30,%esp
 b45:	5b                   	pop    %ebx
 b46:	5e                   	pop    %esi
 b47:	5d                   	pop    %ebp
 b48:	c3                   	ret    

00000b49 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 b49:	55                   	push   %ebp
 b4a:	89 e5                	mov    %esp,%ebp
 b4c:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 b4f:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 b56:	8d 45 0c             	lea    0xc(%ebp),%eax
 b59:	83 c0 04             	add    $0x4,%eax
 b5c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 b5f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 b66:	e9 77 01 00 00       	jmp    ce2 <printf+0x199>
    c = fmt[i] & 0xff;
 b6b:	8b 55 0c             	mov    0xc(%ebp),%edx
 b6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b71:	01 d0                	add    %edx,%eax
 b73:	8a 00                	mov    (%eax),%al
 b75:	0f be c0             	movsbl %al,%eax
 b78:	25 ff 00 00 00       	and    $0xff,%eax
 b7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 b80:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 b84:	75 2c                	jne    bb2 <printf+0x69>
      if(c == '%'){
 b86:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 b8a:	75 0c                	jne    b98 <printf+0x4f>
        state = '%';
 b8c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 b93:	e9 47 01 00 00       	jmp    cdf <printf+0x196>
      } else {
        putc(fd, c);
 b98:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b9b:	0f be c0             	movsbl %al,%eax
 b9e:	89 44 24 04          	mov    %eax,0x4(%esp)
 ba2:	8b 45 08             	mov    0x8(%ebp),%eax
 ba5:	89 04 24             	mov    %eax,(%esp)
 ba8:	e8 bf fe ff ff       	call   a6c <putc>
 bad:	e9 2d 01 00 00       	jmp    cdf <printf+0x196>
      }
    } else if(state == '%'){
 bb2:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 bb6:	0f 85 23 01 00 00    	jne    cdf <printf+0x196>
      if(c == 'd'){
 bbc:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 bc0:	75 2d                	jne    bef <printf+0xa6>
        printint(fd, *ap, 10, 1);
 bc2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 bc5:	8b 00                	mov    (%eax),%eax
 bc7:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 bce:	00 
 bcf:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 bd6:	00 
 bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
 bdb:	8b 45 08             	mov    0x8(%ebp),%eax
 bde:	89 04 24             	mov    %eax,(%esp)
 be1:	e8 ae fe ff ff       	call   a94 <printint>
        ap++;
 be6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 bea:	e9 e9 00 00 00       	jmp    cd8 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 bef:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 bf3:	74 06                	je     bfb <printf+0xb2>
 bf5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 bf9:	75 2d                	jne    c28 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 bfb:	8b 45 e8             	mov    -0x18(%ebp),%eax
 bfe:	8b 00                	mov    (%eax),%eax
 c00:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 c07:	00 
 c08:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 c0f:	00 
 c10:	89 44 24 04          	mov    %eax,0x4(%esp)
 c14:	8b 45 08             	mov    0x8(%ebp),%eax
 c17:	89 04 24             	mov    %eax,(%esp)
 c1a:	e8 75 fe ff ff       	call   a94 <printint>
        ap++;
 c1f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 c23:	e9 b0 00 00 00       	jmp    cd8 <printf+0x18f>
      } else if(c == 's'){
 c28:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 c2c:	75 42                	jne    c70 <printf+0x127>
        s = (char*)*ap;
 c2e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 c31:	8b 00                	mov    (%eax),%eax
 c33:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 c36:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 c3a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 c3e:	75 09                	jne    c49 <printf+0x100>
          s = "(null)";
 c40:	c7 45 f4 e7 10 00 00 	movl   $0x10e7,-0xc(%ebp)
        while(*s != 0){
 c47:	eb 1c                	jmp    c65 <printf+0x11c>
 c49:	eb 1a                	jmp    c65 <printf+0x11c>
          putc(fd, *s);
 c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c4e:	8a 00                	mov    (%eax),%al
 c50:	0f be c0             	movsbl %al,%eax
 c53:	89 44 24 04          	mov    %eax,0x4(%esp)
 c57:	8b 45 08             	mov    0x8(%ebp),%eax
 c5a:	89 04 24             	mov    %eax,(%esp)
 c5d:	e8 0a fe ff ff       	call   a6c <putc>
          s++;
 c62:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 c65:	8b 45 f4             	mov    -0xc(%ebp),%eax
 c68:	8a 00                	mov    (%eax),%al
 c6a:	84 c0                	test   %al,%al
 c6c:	75 dd                	jne    c4b <printf+0x102>
 c6e:	eb 68                	jmp    cd8 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 c70:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 c74:	75 1d                	jne    c93 <printf+0x14a>
        putc(fd, *ap);
 c76:	8b 45 e8             	mov    -0x18(%ebp),%eax
 c79:	8b 00                	mov    (%eax),%eax
 c7b:	0f be c0             	movsbl %al,%eax
 c7e:	89 44 24 04          	mov    %eax,0x4(%esp)
 c82:	8b 45 08             	mov    0x8(%ebp),%eax
 c85:	89 04 24             	mov    %eax,(%esp)
 c88:	e8 df fd ff ff       	call   a6c <putc>
        ap++;
 c8d:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 c91:	eb 45                	jmp    cd8 <printf+0x18f>
      } else if(c == '%'){
 c93:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 c97:	75 17                	jne    cb0 <printf+0x167>
        putc(fd, c);
 c99:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 c9c:	0f be c0             	movsbl %al,%eax
 c9f:	89 44 24 04          	mov    %eax,0x4(%esp)
 ca3:	8b 45 08             	mov    0x8(%ebp),%eax
 ca6:	89 04 24             	mov    %eax,(%esp)
 ca9:	e8 be fd ff ff       	call   a6c <putc>
 cae:	eb 28                	jmp    cd8 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 cb0:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 cb7:	00 
 cb8:	8b 45 08             	mov    0x8(%ebp),%eax
 cbb:	89 04 24             	mov    %eax,(%esp)
 cbe:	e8 a9 fd ff ff       	call   a6c <putc>
        putc(fd, c);
 cc3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 cc6:	0f be c0             	movsbl %al,%eax
 cc9:	89 44 24 04          	mov    %eax,0x4(%esp)
 ccd:	8b 45 08             	mov    0x8(%ebp),%eax
 cd0:	89 04 24             	mov    %eax,(%esp)
 cd3:	e8 94 fd ff ff       	call   a6c <putc>
      }
      state = 0;
 cd8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 cdf:	ff 45 f0             	incl   -0x10(%ebp)
 ce2:	8b 55 0c             	mov    0xc(%ebp),%edx
 ce5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ce8:	01 d0                	add    %edx,%eax
 cea:	8a 00                	mov    (%eax),%al
 cec:	84 c0                	test   %al,%al
 cee:	0f 85 77 fe ff ff    	jne    b6b <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 cf4:	c9                   	leave  
 cf5:	c3                   	ret    
 cf6:	90                   	nop
 cf7:	90                   	nop

00000cf8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 cf8:	55                   	push   %ebp
 cf9:	89 e5                	mov    %esp,%ebp
 cfb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 cfe:	8b 45 08             	mov    0x8(%ebp),%eax
 d01:	83 e8 08             	sub    $0x8,%eax
 d04:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d07:	a1 84 14 00 00       	mov    0x1484,%eax
 d0c:	89 45 fc             	mov    %eax,-0x4(%ebp)
 d0f:	eb 24                	jmp    d35 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d11:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d14:	8b 00                	mov    (%eax),%eax
 d16:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 d19:	77 12                	ja     d2d <free+0x35>
 d1b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d1e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 d21:	77 24                	ja     d47 <free+0x4f>
 d23:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d26:	8b 00                	mov    (%eax),%eax
 d28:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 d2b:	77 1a                	ja     d47 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d30:	8b 00                	mov    (%eax),%eax
 d32:	89 45 fc             	mov    %eax,-0x4(%ebp)
 d35:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d38:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 d3b:	76 d4                	jbe    d11 <free+0x19>
 d3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d40:	8b 00                	mov    (%eax),%eax
 d42:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 d45:	76 ca                	jbe    d11 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 d47:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d4a:	8b 40 04             	mov    0x4(%eax),%eax
 d4d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 d54:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d57:	01 c2                	add    %eax,%edx
 d59:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d5c:	8b 00                	mov    (%eax),%eax
 d5e:	39 c2                	cmp    %eax,%edx
 d60:	75 24                	jne    d86 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 d62:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d65:	8b 50 04             	mov    0x4(%eax),%edx
 d68:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d6b:	8b 00                	mov    (%eax),%eax
 d6d:	8b 40 04             	mov    0x4(%eax),%eax
 d70:	01 c2                	add    %eax,%edx
 d72:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d75:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 d78:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d7b:	8b 00                	mov    (%eax),%eax
 d7d:	8b 10                	mov    (%eax),%edx
 d7f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d82:	89 10                	mov    %edx,(%eax)
 d84:	eb 0a                	jmp    d90 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 d86:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d89:	8b 10                	mov    (%eax),%edx
 d8b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 d8e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 d90:	8b 45 fc             	mov    -0x4(%ebp),%eax
 d93:	8b 40 04             	mov    0x4(%eax),%eax
 d96:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 d9d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 da0:	01 d0                	add    %edx,%eax
 da2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 da5:	75 20                	jne    dc7 <free+0xcf>
    p->s.size += bp->s.size;
 da7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 daa:	8b 50 04             	mov    0x4(%eax),%edx
 dad:	8b 45 f8             	mov    -0x8(%ebp),%eax
 db0:	8b 40 04             	mov    0x4(%eax),%eax
 db3:	01 c2                	add    %eax,%edx
 db5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 db8:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 dbb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 dbe:	8b 10                	mov    (%eax),%edx
 dc0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 dc3:	89 10                	mov    %edx,(%eax)
 dc5:	eb 08                	jmp    dcf <free+0xd7>
  } else
    p->s.ptr = bp;
 dc7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 dca:	8b 55 f8             	mov    -0x8(%ebp),%edx
 dcd:	89 10                	mov    %edx,(%eax)
  freep = p;
 dcf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 dd2:	a3 84 14 00 00       	mov    %eax,0x1484
}
 dd7:	c9                   	leave  
 dd8:	c3                   	ret    

00000dd9 <morecore>:

static Header*
morecore(uint nu)
{
 dd9:	55                   	push   %ebp
 dda:	89 e5                	mov    %esp,%ebp
 ddc:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 ddf:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 de6:	77 07                	ja     def <morecore+0x16>
    nu = 4096;
 de8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 def:	8b 45 08             	mov    0x8(%ebp),%eax
 df2:	c1 e0 03             	shl    $0x3,%eax
 df5:	89 04 24             	mov    %eax,(%esp)
 df8:	e8 27 fc ff ff       	call   a24 <sbrk>
 dfd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 e00:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 e04:	75 07                	jne    e0d <morecore+0x34>
    return 0;
 e06:	b8 00 00 00 00       	mov    $0x0,%eax
 e0b:	eb 22                	jmp    e2f <morecore+0x56>
  hp = (Header*)p;
 e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e10:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 e13:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e16:	8b 55 08             	mov    0x8(%ebp),%edx
 e19:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 e1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e1f:	83 c0 08             	add    $0x8,%eax
 e22:	89 04 24             	mov    %eax,(%esp)
 e25:	e8 ce fe ff ff       	call   cf8 <free>
  return freep;
 e2a:	a1 84 14 00 00       	mov    0x1484,%eax
}
 e2f:	c9                   	leave  
 e30:	c3                   	ret    

00000e31 <malloc>:

void*
malloc(uint nbytes)
{
 e31:	55                   	push   %ebp
 e32:	89 e5                	mov    %esp,%ebp
 e34:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 e37:	8b 45 08             	mov    0x8(%ebp),%eax
 e3a:	83 c0 07             	add    $0x7,%eax
 e3d:	c1 e8 03             	shr    $0x3,%eax
 e40:	40                   	inc    %eax
 e41:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 e44:	a1 84 14 00 00       	mov    0x1484,%eax
 e49:	89 45 f0             	mov    %eax,-0x10(%ebp)
 e4c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 e50:	75 23                	jne    e75 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 e52:	c7 45 f0 7c 14 00 00 	movl   $0x147c,-0x10(%ebp)
 e59:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e5c:	a3 84 14 00 00       	mov    %eax,0x1484
 e61:	a1 84 14 00 00       	mov    0x1484,%eax
 e66:	a3 7c 14 00 00       	mov    %eax,0x147c
    base.s.size = 0;
 e6b:	c7 05 80 14 00 00 00 	movl   $0x0,0x1480
 e72:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e75:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e78:	8b 00                	mov    (%eax),%eax
 e7a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e80:	8b 40 04             	mov    0x4(%eax),%eax
 e83:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 e86:	72 4d                	jb     ed5 <malloc+0xa4>
      if(p->s.size == nunits)
 e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e8b:	8b 40 04             	mov    0x4(%eax),%eax
 e8e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 e91:	75 0c                	jne    e9f <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
 e96:	8b 10                	mov    (%eax),%edx
 e98:	8b 45 f0             	mov    -0x10(%ebp),%eax
 e9b:	89 10                	mov    %edx,(%eax)
 e9d:	eb 26                	jmp    ec5 <malloc+0x94>
      else {
        p->s.size -= nunits;
 e9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ea2:	8b 40 04             	mov    0x4(%eax),%eax
 ea5:	2b 45 ec             	sub    -0x14(%ebp),%eax
 ea8:	89 c2                	mov    %eax,%edx
 eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ead:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 eb3:	8b 40 04             	mov    0x4(%eax),%eax
 eb6:	c1 e0 03             	shl    $0x3,%eax
 eb9:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ebc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ebf:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ec2:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ec8:	a3 84 14 00 00       	mov    %eax,0x1484
      return (void*)(p + 1);
 ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ed0:	83 c0 08             	add    $0x8,%eax
 ed3:	eb 38                	jmp    f0d <malloc+0xdc>
    }
    if(p == freep)
 ed5:	a1 84 14 00 00       	mov    0x1484,%eax
 eda:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 edd:	75 1b                	jne    efa <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 edf:	8b 45 ec             	mov    -0x14(%ebp),%eax
 ee2:	89 04 24             	mov    %eax,(%esp)
 ee5:	e8 ef fe ff ff       	call   dd9 <morecore>
 eea:	89 45 f4             	mov    %eax,-0xc(%ebp)
 eed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ef1:	75 07                	jne    efa <malloc+0xc9>
        return 0;
 ef3:	b8 00 00 00 00       	mov    $0x0,%eax
 ef8:	eb 13                	jmp    f0d <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 efa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 efd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 f00:	8b 45 f4             	mov    -0xc(%ebp),%eax
 f03:	8b 00                	mov    (%eax),%eax
 f05:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 f08:	e9 70 ff ff ff       	jmp    e7d <malloc+0x4c>
}
 f0d:	c9                   	leave  
 f0e:	c3                   	ret    
