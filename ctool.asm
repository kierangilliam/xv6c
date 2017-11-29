
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
   d:	c7 44 24 04 d8 0d 00 	movl   $0xdd8,0x4(%esp)
  14:	00 
  15:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1c:	e8 f0 09 00 00       	call   a11 <printf>
    exit();
  21:	e8 3e 08 00 00       	call   864 <exit>

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
  int pathsize = strlen(dst) + strlen(file) + 2; // dst.len + '\' + src.len + \0
  36:	8b 45 08             	mov    0x8(%ebp),%eax
  39:	89 04 24             	mov    %eax,(%esp)
  3c:	e8 5a 06 00 00       	call   69b <strlen>
  41:	89 c3                	mov    %eax,%ebx
  43:	8b 45 0c             	mov    0xc(%ebp),%eax
  46:	89 04 24             	mov    %eax,(%esp)
  49:	e8 4d 06 00 00       	call   69b <strlen>
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
  88:	e8 0e 06 00 00       	call   69b <strlen>
  8d:	89 c2                	mov    %eax,%edx
  8f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  92:	89 54 24 08          	mov    %edx,0x8(%esp)
  96:	8b 55 08             	mov    0x8(%ebp),%edx
  99:	89 54 24 04          	mov    %edx,0x4(%esp)
  9d:	89 04 24             	mov    %eax,(%esp)
  a0:	e8 78 07 00 00       	call   81d <memmove>
  memmove(path + strlen(dst), "/", 1);
  a5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  a8:	8b 45 08             	mov    0x8(%ebp),%eax
  ab:	89 04 24             	mov    %eax,(%esp)
  ae:	e8 e8 05 00 00       	call   69b <strlen>
  b3:	01 d8                	add    %ebx,%eax
  b5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  bc:	00 
  bd:	c7 44 24 04 e9 0d 00 	movl   $0xde9,0x4(%esp)
  c4:	00 
  c5:	89 04 24             	mov    %eax,(%esp)
  c8:	e8 50 07 00 00       	call   81d <memmove>
  memmove(path + strlen(dst) + 1, file, strlen(file));
  cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  d0:	89 04 24             	mov    %eax,(%esp)
  d3:	e8 c3 05 00 00       	call   69b <strlen>
  d8:	89 c3                	mov    %eax,%ebx
  da:	8b 7d dc             	mov    -0x24(%ebp),%edi
  dd:	8b 45 08             	mov    0x8(%ebp),%eax
  e0:	89 04 24             	mov    %eax,(%esp)
  e3:	e8 b3 05 00 00       	call   69b <strlen>
  e8:	40                   	inc    %eax
  e9:	8d 14 07             	lea    (%edi,%eax,1),%edx
  ec:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  f7:	89 14 24             	mov    %edx,(%esp)
  fa:	e8 1e 07 00 00       	call   81d <memmove>
  memmove(path + strlen(dst) + 1 + strlen(file), "\0", 1);
  ff:	8b 7d dc             	mov    -0x24(%ebp),%edi
 102:	8b 45 08             	mov    0x8(%ebp),%eax
 105:	89 04 24             	mov    %eax,(%esp)
 108:	e8 8e 05 00 00       	call   69b <strlen>
 10d:	89 c3                	mov    %eax,%ebx
 10f:	8b 45 0c             	mov    0xc(%ebp),%eax
 112:	89 04 24             	mov    %eax,(%esp)
 115:	e8 81 05 00 00       	call   69b <strlen>
 11a:	01 d8                	add    %ebx,%eax
 11c:	40                   	inc    %eax
 11d:	01 f8                	add    %edi,%eax
 11f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 126:	00 
 127:	c7 44 24 04 eb 0d 00 	movl   $0xdeb,0x4(%esp)
 12e:	00 
 12f:	89 04 24             	mov    %eax,(%esp)
 132:	e8 e6 06 00 00       	call   81d <memmove>

  printf(1, "path created %s\n", path);
 137:	8b 45 dc             	mov    -0x24(%ebp),%eax
 13a:	89 44 24 08          	mov    %eax,0x8(%esp)
 13e:	c7 44 24 04 ed 0d 00 	movl   $0xded,0x4(%esp)
 145:	00 
 146:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 14d:	e8 bf 08 00 00       	call   a11 <printf>

  files[0] = open(file, O_RDONLY);
 152:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 159:	00 
 15a:	8b 45 0c             	mov    0xc(%ebp),%eax
 15d:	89 04 24             	mov    %eax,(%esp)
 160:	e8 3f 07 00 00       	call   8a4 <open>
 165:	89 85 d0 fb ff ff    	mov    %eax,-0x430(%ebp)
  if (files[0] == -1) // Check if file opened 
 16b:	8b 85 d0 fb ff ff    	mov    -0x430(%ebp),%eax
 171:	83 f8 ff             	cmp    $0xffffffff,%eax
 174:	75 0a                	jne    180 <cp+0x15a>
      return -1;
 176:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 17b:	e9 88 00 00 00       	jmp    208 <cp+0x1e2>
  files[1] = open(path, O_WRONLY | O_CREATE);
 180:	8b 45 dc             	mov    -0x24(%ebp),%eax
 183:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
 18a:	00 
 18b:	89 04 24             	mov    %eax,(%esp)
 18e:	e8 11 07 00 00       	call   8a4 <open>
 193:	89 85 d4 fb ff ff    	mov    %eax,-0x42c(%ebp)
  if (files[1] == -1) { // Check if file opened (permissions problems ...) 
 199:	8b 85 d4 fb ff ff    	mov    -0x42c(%ebp),%eax
 19f:	83 f8 ff             	cmp    $0xffffffff,%eax
 1a2:	75 15                	jne    1b9 <cp+0x193>
      close(files[0]);
 1a4:	8b 85 d0 fb ff ff    	mov    -0x430(%ebp),%eax
 1aa:	89 04 24             	mov    %eax,(%esp)
 1ad:	e8 da 06 00 00       	call   88c <close>
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
 1d5:	e8 aa 06 00 00       	call   884 <write>
  if (files[1] == -1) { // Check if file opened (permissions problems ...) 
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
 1f5:	e8 82 06 00 00       	call   87c <read>
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
// ctool create ctest1 -p 4 sh ps cat echo
// folder/ container name, what to copy into folder
// mkdir, cp file 1, cp file n  
void
create(int argc, char *argv[])
{
 227:	55                   	push   %ebp
 228:	89 e5                	mov    %esp,%ebp
 22a:	81 ec c8 00 00 00    	sub    $0xc8,%esp
  char *progv[32];
  int i, k, progc, last_flag = 2, // No flags
 230:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  mproc = CONT_MAX_PROC, 
 237:	c7 45 e8 08 00 00 00 	movl   $0x8,-0x18(%ebp)
  msz = CONT_MAX_MEM, 
 23e:	c7 45 e4 00 04 00 00 	movl   $0x400,-0x1c(%ebp)
  mdsk = CONT_MAX_DISK;  
 245:	c7 45 e0 00 04 00 00 	movl   $0x400,-0x20(%ebp)

  if (argc < 4)
 24c:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
 250:	7f 0c                	jg     25e <create+0x37>
    usage("create <name> [-p <max_processes>] [-m <max_memory>] [-d <max_disk>] prog [prog2.. ]");
 252:	c7 04 24 00 0e 00 00 	movl   $0xe00,(%esp)
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
 27b:	c7 44 24 04 55 0e 00 	movl   $0xe55,0x4(%esp)
 282:	00 
 283:	89 04 24             	mov    %eax,(%esp)
 286:	e8 d8 03 00 00       	call   663 <strcmp>
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
 2ba:	e8 14 05 00 00       	call   7d3 <atoi>
 2bf:	89 45 e8             	mov    %eax,-0x18(%ebp)
    }
    if (strcmp(argv[i], "-m") == 0) {
 2c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2c5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 2cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 2cf:	01 d0                	add    %edx,%eax
 2d1:	8b 00                	mov    (%eax),%eax
 2d3:	c7 44 24 04 58 0e 00 	movl   $0xe58,0x4(%esp)
 2da:	00 
 2db:	89 04 24             	mov    %eax,(%esp)
 2de:	e8 80 03 00 00       	call   663 <strcmp>
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
 312:	e8 bc 04 00 00       	call   7d3 <atoi>
 317:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    }
    if (strcmp(argv[i], "-d") == 0) {
 31a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 31d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 324:	8b 45 0c             	mov    0xc(%ebp),%eax
 327:	01 d0                	add    %edx,%eax
 329:	8b 00                	mov    (%eax),%eax
 32b:	c7 44 24 04 5b 0e 00 	movl   $0xe5b,0x4(%esp)
 332:	00 
 333:	89 04 24             	mov    %eax,(%esp)
 336:	e8 28 03 00 00       	call   663 <strcmp>
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
 36a:	e8 64 04 00 00       	call   7d3 <atoi>
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

  for (i = last_flag + 1, k = 0; i < argc; i++, k++) {
 38f:	8b 45 ec             	mov    -0x14(%ebp),%eax
 392:	40                   	inc    %eax
 393:	89 45 f4             	mov    %eax,-0xc(%ebp)
 396:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 39d:	e9 e0 00 00 00       	jmp    482 <create+0x25b>
    printf(1, "%s", argv[i]);
 3a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3a5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 3ac:	8b 45 0c             	mov    0xc(%ebp),%eax
 3af:	01 d0                	add    %edx,%eax
 3b1:	8b 00                	mov    (%eax),%eax
 3b3:	89 44 24 08          	mov    %eax,0x8(%esp)
 3b7:	c7 44 24 04 5e 0e 00 	movl   $0xe5e,0x4(%esp)
 3be:	00 
 3bf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 3c6:	e8 46 06 00 00       	call   a11 <printf>

    // TODO: move this into the kernel or the rest of ccreate out of the kernel
    cp(argv[2], argv[i]);
 3cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3ce:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 3d5:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d8:	01 d0                	add    %edx,%eax
 3da:	8b 10                	mov    (%eax),%edx
 3dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3df:	83 c0 08             	add    $0x8,%eax
 3e2:	8b 00                	mov    (%eax),%eax
 3e4:	89 54 24 04          	mov    %edx,0x4(%esp)
 3e8:	89 04 24             	mov    %eax,(%esp)
 3eb:	e8 36 fc ff ff       	call   26 <cp>
    
    // If we were using kernel for ccreate sys call
    progv[k] = malloc(sizeof(argv[i])); memmove(progv[k], argv[i], sizeof(argv[i])); memmove(progv[k] + sizeof(argv[i]), "\0", 1); printf(1, "\t%s\n", progv[k]);
 3f0:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
 3f7:	e8 fd 08 00 00       	call   cf9 <malloc>
 3fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
 3ff:	89 84 95 5c ff ff ff 	mov    %eax,-0xa4(%ebp,%edx,4)
 406:	8b 45 f4             	mov    -0xc(%ebp),%eax
 409:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 410:	8b 45 0c             	mov    0xc(%ebp),%eax
 413:	01 d0                	add    %edx,%eax
 415:	8b 10                	mov    (%eax),%edx
 417:	8b 45 f0             	mov    -0x10(%ebp),%eax
 41a:	8b 84 85 5c ff ff ff 	mov    -0xa4(%ebp,%eax,4),%eax
 421:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
 428:	00 
 429:	89 54 24 04          	mov    %edx,0x4(%esp)
 42d:	89 04 24             	mov    %eax,(%esp)
 430:	e8 e8 03 00 00       	call   81d <memmove>
 435:	8b 45 f0             	mov    -0x10(%ebp),%eax
 438:	8b 84 85 5c ff ff ff 	mov    -0xa4(%ebp,%eax,4),%eax
 43f:	83 c0 04             	add    $0x4,%eax
 442:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 449:	00 
 44a:	c7 44 24 04 eb 0d 00 	movl   $0xdeb,0x4(%esp)
 451:	00 
 452:	89 04 24             	mov    %eax,(%esp)
 455:	e8 c3 03 00 00       	call   81d <memmove>
 45a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 45d:	8b 84 85 5c ff ff ff 	mov    -0xa4(%ebp,%eax,4),%eax
 464:	89 44 24 08          	mov    %eax,0x8(%esp)
 468:	c7 44 24 04 61 0e 00 	movl   $0xe61,0x4(%esp)
 46f:	00 
 470:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 477:	e8 95 05 00 00       	call   a11 <printf>
    }
  }

  progc = argc - last_flag - 1;

  for (i = last_flag + 1, k = 0; i < argc; i++, k++) {
 47c:	ff 45 f4             	incl   -0xc(%ebp)
 47f:	ff 45 f0             	incl   -0x10(%ebp)
 482:	8b 45 f4             	mov    -0xc(%ebp),%eax
 485:	3b 45 08             	cmp    0x8(%ebp),%eax
 488:	0f 8c 14 ff ff ff    	jl     3a2 <create+0x17b>
    // If we were using kernel for ccreate sys call
    progv[k] = malloc(sizeof(argv[i])); memmove(progv[k], argv[i], sizeof(argv[i])); memmove(progv[k] + sizeof(argv[i]), "\0", 1); printf(1, "\t%s\n", progv[k]);
  }  


  printf(1, "name: %s\nmproc: %d\nmsz: %d\nmdsk: %d\nprogc: %d\n", argv[2], mproc, msz, mdsk, progc);
 48e:	8b 45 0c             	mov    0xc(%ebp),%eax
 491:	83 c0 08             	add    $0x8,%eax
 494:	8b 00                	mov    (%eax),%eax
 496:	8b 55 dc             	mov    -0x24(%ebp),%edx
 499:	89 54 24 18          	mov    %edx,0x18(%esp)
 49d:	8b 55 e0             	mov    -0x20(%ebp),%edx
 4a0:	89 54 24 14          	mov    %edx,0x14(%esp)
 4a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 4a7:	89 54 24 10          	mov    %edx,0x10(%esp)
 4ab:	8b 55 e8             	mov    -0x18(%ebp),%edx
 4ae:	89 54 24 0c          	mov    %edx,0xc(%esp)
 4b2:	89 44 24 08          	mov    %eax,0x8(%esp)
 4b6:	c7 44 24 04 68 0e 00 	movl   $0xe68,0x4(%esp)
 4bd:	00 
 4be:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 4c5:	e8 47 05 00 00       	call   a11 <printf>

  if (ccreate(argv[2], progv, progc, mproc, msz, mdsk) == 1) {
 4ca:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 4cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 4d0:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d3:	83 c0 08             	add    $0x8,%eax
 4d6:	8b 00                	mov    (%eax),%eax
 4d8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
 4dc:	89 54 24 10          	mov    %edx,0x10(%esp)
 4e0:	8b 55 e8             	mov    -0x18(%ebp),%edx
 4e3:	89 54 24 0c          	mov    %edx,0xc(%esp)
 4e7:	8b 55 dc             	mov    -0x24(%ebp),%edx
 4ea:	89 54 24 08          	mov    %edx,0x8(%esp)
 4ee:	8d 95 5c ff ff ff    	lea    -0xa4(%ebp),%edx
 4f4:	89 54 24 04          	mov    %edx,0x4(%esp)
 4f8:	89 04 24             	mov    %eax,(%esp)
 4fb:	e8 0c 04 00 00       	call   90c <ccreate>
 500:	83 f8 01             	cmp    $0x1,%eax
 503:	75 22                	jne    527 <create+0x300>
    printf(1, "Created container %s\n", argv[2]); 
 505:	8b 45 0c             	mov    0xc(%ebp),%eax
 508:	83 c0 08             	add    $0x8,%eax
 50b:	8b 00                	mov    (%eax),%eax
 50d:	89 44 24 08          	mov    %eax,0x8(%esp)
 511:	c7 44 24 04 97 0e 00 	movl   $0xe97,0x4(%esp)
 518:	00 
 519:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 520:	e8 ec 04 00 00       	call   a11 <printf>
 525:	eb 20                	jmp    547 <create+0x320>
  } else {
    printf(1, "Failed to create container %s\n", argv[2]); 
 527:	8b 45 0c             	mov    0xc(%ebp),%eax
 52a:	83 c0 08             	add    $0x8,%eax
 52d:	8b 00                	mov    (%eax),%eax
 52f:	89 44 24 08          	mov    %eax,0x8(%esp)
 533:	c7 44 24 04 b0 0e 00 	movl   $0xeb0,0x4(%esp)
 53a:	00 
 53b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 542:	e8 ca 04 00 00       	call   a11 <printf>
  }
}
 547:	c9                   	leave  
 548:	c3                   	ret    

00000549 <start>:

// ctool start <name> prog arg1 [arg2 ...]
// ctool start c1 echoloop ab
void
start(int argc, char *argv[])
{    
 549:	55                   	push   %ebp
 54a:	89 e5                	mov    %esp,%ebp
 54c:	83 ec 18             	sub    $0x18,%esp

  if (argc < 4)
 54f:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
 553:	7f 0c                	jg     561 <start+0x18>
    usage("ctool start <name> prog arg1 [arg2 ...]");
 555:	c7 04 24 d0 0e 00 00 	movl   $0xed0,(%esp)
 55c:	e8 9f fa ff ff       	call   0 <usage>
}
 561:	c9                   	leave  
 562:	c3                   	ret    

00000563 <pause>:

void
pause(int argc, char *argv[])
{
 563:	55                   	push   %ebp
 564:	89 e5                	mov    %esp,%ebp
  
}
 566:	5d                   	pop    %ebp
 567:	c3                   	ret    

00000568 <resume>:

void
resume(int argc, char *argv[])
{
 568:	55                   	push   %ebp
 569:	89 e5                	mov    %esp,%ebp
  
}
 56b:	5d                   	pop    %ebp
 56c:	c3                   	ret    

0000056d <stop>:

void
stop(int argc, char *argv[])
{
 56d:	55                   	push   %ebp
 56e:	89 e5                	mov    %esp,%ebp
  
}
 570:	5d                   	pop    %ebp
 571:	c3                   	ret    

00000572 <info>:

void
info(int argc, char *argv[])
{
 572:	55                   	push   %ebp
 573:	89 e5                	mov    %esp,%ebp
  
}
 575:	5d                   	pop    %ebp
 576:	c3                   	ret    

00000577 <main>:

int
main(int argc, char *argv[])
{
 577:	55                   	push   %ebp
 578:	89 e5                	mov    %esp,%ebp
 57a:	83 e4 f0             	and    $0xfffffff0,%esp
 57d:	83 ec 10             	sub    $0x10,%esp

  if (argc < 3) {
 580:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 584:	7f 11                	jg     597 <main+0x20>
    usage("<tool> <cmd> [<arg> ...]");
 586:	c7 04 24 f8 0e 00 00 	movl   $0xef8,(%esp)
 58d:	e8 6e fa ff ff       	call   0 <usage>
    exit();
 592:	e8 cd 02 00 00       	call   864 <exit>
  }

  if (strcmp(argv[1], "create") == 0)
 597:	8b 45 0c             	mov    0xc(%ebp),%eax
 59a:	83 c0 04             	add    $0x4,%eax
 59d:	8b 00                	mov    (%eax),%eax
 59f:	c7 44 24 04 11 0f 00 	movl   $0xf11,0x4(%esp)
 5a6:	00 
 5a7:	89 04 24             	mov    %eax,(%esp)
 5aa:	e8 b4 00 00 00       	call   663 <strcmp>
 5af:	85 c0                	test   %eax,%eax
 5b1:	75 14                	jne    5c7 <main+0x50>
    create(argc, argv);
 5b3:	8b 45 0c             	mov    0xc(%ebp),%eax
 5b6:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ba:	8b 45 08             	mov    0x8(%ebp),%eax
 5bd:	89 04 24             	mov    %eax,(%esp)
 5c0:	e8 62 fc ff ff       	call   227 <create>
 5c5:	eb 44                	jmp    60b <main+0x94>
  else if (strcmp(argv[1], "start") == 0)
 5c7:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ca:	83 c0 04             	add    $0x4,%eax
 5cd:	8b 00                	mov    (%eax),%eax
 5cf:	c7 44 24 04 18 0f 00 	movl   $0xf18,0x4(%esp)
 5d6:	00 
 5d7:	89 04 24             	mov    %eax,(%esp)
 5da:	e8 84 00 00 00       	call   663 <strcmp>
 5df:	85 c0                	test   %eax,%eax
 5e1:	75 14                	jne    5f7 <main+0x80>
    start(argc, argv);
 5e3:	8b 45 0c             	mov    0xc(%ebp),%eax
 5e6:	89 44 24 04          	mov    %eax,0x4(%esp)
 5ea:	8b 45 08             	mov    0x8(%ebp),%eax
 5ed:	89 04 24             	mov    %eax,(%esp)
 5f0:	e8 54 ff ff ff       	call   549 <start>
 5f5:	eb 14                	jmp    60b <main+0x94>
  else 
    printf(1, "ctool: command not found.\n");   
 5f7:	c7 44 24 04 1e 0f 00 	movl   $0xf1e,0x4(%esp)
 5fe:	00 
 5ff:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 606:	e8 06 04 00 00       	call   a11 <printf>

  exit();
 60b:	e8 54 02 00 00       	call   864 <exit>

00000610 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 610:	55                   	push   %ebp
 611:	89 e5                	mov    %esp,%ebp
 613:	57                   	push   %edi
 614:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 615:	8b 4d 08             	mov    0x8(%ebp),%ecx
 618:	8b 55 10             	mov    0x10(%ebp),%edx
 61b:	8b 45 0c             	mov    0xc(%ebp),%eax
 61e:	89 cb                	mov    %ecx,%ebx
 620:	89 df                	mov    %ebx,%edi
 622:	89 d1                	mov    %edx,%ecx
 624:	fc                   	cld    
 625:	f3 aa                	rep stos %al,%es:(%edi)
 627:	89 ca                	mov    %ecx,%edx
 629:	89 fb                	mov    %edi,%ebx
 62b:	89 5d 08             	mov    %ebx,0x8(%ebp)
 62e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 631:	5b                   	pop    %ebx
 632:	5f                   	pop    %edi
 633:	5d                   	pop    %ebp
 634:	c3                   	ret    

00000635 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 635:	55                   	push   %ebp
 636:	89 e5                	mov    %esp,%ebp
 638:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 63b:	8b 45 08             	mov    0x8(%ebp),%eax
 63e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 641:	90                   	nop
 642:	8b 45 08             	mov    0x8(%ebp),%eax
 645:	8d 50 01             	lea    0x1(%eax),%edx
 648:	89 55 08             	mov    %edx,0x8(%ebp)
 64b:	8b 55 0c             	mov    0xc(%ebp),%edx
 64e:	8d 4a 01             	lea    0x1(%edx),%ecx
 651:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 654:	8a 12                	mov    (%edx),%dl
 656:	88 10                	mov    %dl,(%eax)
 658:	8a 00                	mov    (%eax),%al
 65a:	84 c0                	test   %al,%al
 65c:	75 e4                	jne    642 <strcpy+0xd>
    ;
  return os;
 65e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 661:	c9                   	leave  
 662:	c3                   	ret    

00000663 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 663:	55                   	push   %ebp
 664:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 666:	eb 06                	jmp    66e <strcmp+0xb>
    p++, q++;
 668:	ff 45 08             	incl   0x8(%ebp)
 66b:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 66e:	8b 45 08             	mov    0x8(%ebp),%eax
 671:	8a 00                	mov    (%eax),%al
 673:	84 c0                	test   %al,%al
 675:	74 0e                	je     685 <strcmp+0x22>
 677:	8b 45 08             	mov    0x8(%ebp),%eax
 67a:	8a 10                	mov    (%eax),%dl
 67c:	8b 45 0c             	mov    0xc(%ebp),%eax
 67f:	8a 00                	mov    (%eax),%al
 681:	38 c2                	cmp    %al,%dl
 683:	74 e3                	je     668 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 685:	8b 45 08             	mov    0x8(%ebp),%eax
 688:	8a 00                	mov    (%eax),%al
 68a:	0f b6 d0             	movzbl %al,%edx
 68d:	8b 45 0c             	mov    0xc(%ebp),%eax
 690:	8a 00                	mov    (%eax),%al
 692:	0f b6 c0             	movzbl %al,%eax
 695:	29 c2                	sub    %eax,%edx
 697:	89 d0                	mov    %edx,%eax
}
 699:	5d                   	pop    %ebp
 69a:	c3                   	ret    

0000069b <strlen>:

uint
strlen(char *s)
{
 69b:	55                   	push   %ebp
 69c:	89 e5                	mov    %esp,%ebp
 69e:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 6a1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 6a8:	eb 03                	jmp    6ad <strlen+0x12>
 6aa:	ff 45 fc             	incl   -0x4(%ebp)
 6ad:	8b 55 fc             	mov    -0x4(%ebp),%edx
 6b0:	8b 45 08             	mov    0x8(%ebp),%eax
 6b3:	01 d0                	add    %edx,%eax
 6b5:	8a 00                	mov    (%eax),%al
 6b7:	84 c0                	test   %al,%al
 6b9:	75 ef                	jne    6aa <strlen+0xf>
    ;
  return n;
 6bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 6be:	c9                   	leave  
 6bf:	c3                   	ret    

000006c0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 6c0:	55                   	push   %ebp
 6c1:	89 e5                	mov    %esp,%ebp
 6c3:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 6c6:	8b 45 10             	mov    0x10(%ebp),%eax
 6c9:	89 44 24 08          	mov    %eax,0x8(%esp)
 6cd:	8b 45 0c             	mov    0xc(%ebp),%eax
 6d0:	89 44 24 04          	mov    %eax,0x4(%esp)
 6d4:	8b 45 08             	mov    0x8(%ebp),%eax
 6d7:	89 04 24             	mov    %eax,(%esp)
 6da:	e8 31 ff ff ff       	call   610 <stosb>
  return dst;
 6df:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6e2:	c9                   	leave  
 6e3:	c3                   	ret    

000006e4 <strchr>:

char*
strchr(const char *s, char c)
{
 6e4:	55                   	push   %ebp
 6e5:	89 e5                	mov    %esp,%ebp
 6e7:	83 ec 04             	sub    $0x4,%esp
 6ea:	8b 45 0c             	mov    0xc(%ebp),%eax
 6ed:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 6f0:	eb 12                	jmp    704 <strchr+0x20>
    if(*s == c)
 6f2:	8b 45 08             	mov    0x8(%ebp),%eax
 6f5:	8a 00                	mov    (%eax),%al
 6f7:	3a 45 fc             	cmp    -0x4(%ebp),%al
 6fa:	75 05                	jne    701 <strchr+0x1d>
      return (char*)s;
 6fc:	8b 45 08             	mov    0x8(%ebp),%eax
 6ff:	eb 11                	jmp    712 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 701:	ff 45 08             	incl   0x8(%ebp)
 704:	8b 45 08             	mov    0x8(%ebp),%eax
 707:	8a 00                	mov    (%eax),%al
 709:	84 c0                	test   %al,%al
 70b:	75 e5                	jne    6f2 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 70d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 712:	c9                   	leave  
 713:	c3                   	ret    

00000714 <gets>:

char*
gets(char *buf, int max)
{
 714:	55                   	push   %ebp
 715:	89 e5                	mov    %esp,%ebp
 717:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 71a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 721:	eb 49                	jmp    76c <gets+0x58>
    cc = read(0, &c, 1);
 723:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 72a:	00 
 72b:	8d 45 ef             	lea    -0x11(%ebp),%eax
 72e:	89 44 24 04          	mov    %eax,0x4(%esp)
 732:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 739:	e8 3e 01 00 00       	call   87c <read>
 73e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 741:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 745:	7f 02                	jg     749 <gets+0x35>
      break;
 747:	eb 2c                	jmp    775 <gets+0x61>
    buf[i++] = c;
 749:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74c:	8d 50 01             	lea    0x1(%eax),%edx
 74f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 752:	89 c2                	mov    %eax,%edx
 754:	8b 45 08             	mov    0x8(%ebp),%eax
 757:	01 c2                	add    %eax,%edx
 759:	8a 45 ef             	mov    -0x11(%ebp),%al
 75c:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 75e:	8a 45 ef             	mov    -0x11(%ebp),%al
 761:	3c 0a                	cmp    $0xa,%al
 763:	74 10                	je     775 <gets+0x61>
 765:	8a 45 ef             	mov    -0x11(%ebp),%al
 768:	3c 0d                	cmp    $0xd,%al
 76a:	74 09                	je     775 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 76c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76f:	40                   	inc    %eax
 770:	3b 45 0c             	cmp    0xc(%ebp),%eax
 773:	7c ae                	jl     723 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 775:	8b 55 f4             	mov    -0xc(%ebp),%edx
 778:	8b 45 08             	mov    0x8(%ebp),%eax
 77b:	01 d0                	add    %edx,%eax
 77d:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 780:	8b 45 08             	mov    0x8(%ebp),%eax
}
 783:	c9                   	leave  
 784:	c3                   	ret    

00000785 <stat>:

int
stat(char *n, struct stat *st)
{
 785:	55                   	push   %ebp
 786:	89 e5                	mov    %esp,%ebp
 788:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 78b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 792:	00 
 793:	8b 45 08             	mov    0x8(%ebp),%eax
 796:	89 04 24             	mov    %eax,(%esp)
 799:	e8 06 01 00 00       	call   8a4 <open>
 79e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 7a1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7a5:	79 07                	jns    7ae <stat+0x29>
    return -1;
 7a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 7ac:	eb 23                	jmp    7d1 <stat+0x4c>
  r = fstat(fd, st);
 7ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 7b1:	89 44 24 04          	mov    %eax,0x4(%esp)
 7b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b8:	89 04 24             	mov    %eax,(%esp)
 7bb:	e8 fc 00 00 00       	call   8bc <fstat>
 7c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 7c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c6:	89 04 24             	mov    %eax,(%esp)
 7c9:	e8 be 00 00 00       	call   88c <close>
  return r;
 7ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 7d1:	c9                   	leave  
 7d2:	c3                   	ret    

000007d3 <atoi>:

int
atoi(const char *s)
{
 7d3:	55                   	push   %ebp
 7d4:	89 e5                	mov    %esp,%ebp
 7d6:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 7d9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 7e0:	eb 24                	jmp    806 <atoi+0x33>
    n = n*10 + *s++ - '0';
 7e2:	8b 55 fc             	mov    -0x4(%ebp),%edx
 7e5:	89 d0                	mov    %edx,%eax
 7e7:	c1 e0 02             	shl    $0x2,%eax
 7ea:	01 d0                	add    %edx,%eax
 7ec:	01 c0                	add    %eax,%eax
 7ee:	89 c1                	mov    %eax,%ecx
 7f0:	8b 45 08             	mov    0x8(%ebp),%eax
 7f3:	8d 50 01             	lea    0x1(%eax),%edx
 7f6:	89 55 08             	mov    %edx,0x8(%ebp)
 7f9:	8a 00                	mov    (%eax),%al
 7fb:	0f be c0             	movsbl %al,%eax
 7fe:	01 c8                	add    %ecx,%eax
 800:	83 e8 30             	sub    $0x30,%eax
 803:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 806:	8b 45 08             	mov    0x8(%ebp),%eax
 809:	8a 00                	mov    (%eax),%al
 80b:	3c 2f                	cmp    $0x2f,%al
 80d:	7e 09                	jle    818 <atoi+0x45>
 80f:	8b 45 08             	mov    0x8(%ebp),%eax
 812:	8a 00                	mov    (%eax),%al
 814:	3c 39                	cmp    $0x39,%al
 816:	7e ca                	jle    7e2 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 818:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 81b:	c9                   	leave  
 81c:	c3                   	ret    

0000081d <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 81d:	55                   	push   %ebp
 81e:	89 e5                	mov    %esp,%ebp
 820:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 823:	8b 45 08             	mov    0x8(%ebp),%eax
 826:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 829:	8b 45 0c             	mov    0xc(%ebp),%eax
 82c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 82f:	eb 16                	jmp    847 <memmove+0x2a>
    *dst++ = *src++;
 831:	8b 45 fc             	mov    -0x4(%ebp),%eax
 834:	8d 50 01             	lea    0x1(%eax),%edx
 837:	89 55 fc             	mov    %edx,-0x4(%ebp)
 83a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 83d:	8d 4a 01             	lea    0x1(%edx),%ecx
 840:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 843:	8a 12                	mov    (%edx),%dl
 845:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 847:	8b 45 10             	mov    0x10(%ebp),%eax
 84a:	8d 50 ff             	lea    -0x1(%eax),%edx
 84d:	89 55 10             	mov    %edx,0x10(%ebp)
 850:	85 c0                	test   %eax,%eax
 852:	7f dd                	jg     831 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 854:	8b 45 08             	mov    0x8(%ebp),%eax
}
 857:	c9                   	leave  
 858:	c3                   	ret    
 859:	90                   	nop
 85a:	90                   	nop
 85b:	90                   	nop

0000085c <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 85c:	b8 01 00 00 00       	mov    $0x1,%eax
 861:	cd 40                	int    $0x40
 863:	c3                   	ret    

00000864 <exit>:
SYSCALL(exit)
 864:	b8 02 00 00 00       	mov    $0x2,%eax
 869:	cd 40                	int    $0x40
 86b:	c3                   	ret    

0000086c <wait>:
SYSCALL(wait)
 86c:	b8 03 00 00 00       	mov    $0x3,%eax
 871:	cd 40                	int    $0x40
 873:	c3                   	ret    

00000874 <pipe>:
SYSCALL(pipe)
 874:	b8 04 00 00 00       	mov    $0x4,%eax
 879:	cd 40                	int    $0x40
 87b:	c3                   	ret    

0000087c <read>:
SYSCALL(read)
 87c:	b8 05 00 00 00       	mov    $0x5,%eax
 881:	cd 40                	int    $0x40
 883:	c3                   	ret    

00000884 <write>:
SYSCALL(write)
 884:	b8 10 00 00 00       	mov    $0x10,%eax
 889:	cd 40                	int    $0x40
 88b:	c3                   	ret    

0000088c <close>:
SYSCALL(close)
 88c:	b8 15 00 00 00       	mov    $0x15,%eax
 891:	cd 40                	int    $0x40
 893:	c3                   	ret    

00000894 <kill>:
SYSCALL(kill)
 894:	b8 06 00 00 00       	mov    $0x6,%eax
 899:	cd 40                	int    $0x40
 89b:	c3                   	ret    

0000089c <exec>:
SYSCALL(exec)
 89c:	b8 07 00 00 00       	mov    $0x7,%eax
 8a1:	cd 40                	int    $0x40
 8a3:	c3                   	ret    

000008a4 <open>:
SYSCALL(open)
 8a4:	b8 0f 00 00 00       	mov    $0xf,%eax
 8a9:	cd 40                	int    $0x40
 8ab:	c3                   	ret    

000008ac <mknod>:
SYSCALL(mknod)
 8ac:	b8 11 00 00 00       	mov    $0x11,%eax
 8b1:	cd 40                	int    $0x40
 8b3:	c3                   	ret    

000008b4 <unlink>:
SYSCALL(unlink)
 8b4:	b8 12 00 00 00       	mov    $0x12,%eax
 8b9:	cd 40                	int    $0x40
 8bb:	c3                   	ret    

000008bc <fstat>:
SYSCALL(fstat)
 8bc:	b8 08 00 00 00       	mov    $0x8,%eax
 8c1:	cd 40                	int    $0x40
 8c3:	c3                   	ret    

000008c4 <link>:
SYSCALL(link)
 8c4:	b8 13 00 00 00       	mov    $0x13,%eax
 8c9:	cd 40                	int    $0x40
 8cb:	c3                   	ret    

000008cc <mkdir>:
SYSCALL(mkdir)
 8cc:	b8 14 00 00 00       	mov    $0x14,%eax
 8d1:	cd 40                	int    $0x40
 8d3:	c3                   	ret    

000008d4 <chdir>:
SYSCALL(chdir)
 8d4:	b8 09 00 00 00       	mov    $0x9,%eax
 8d9:	cd 40                	int    $0x40
 8db:	c3                   	ret    

000008dc <dup>:
SYSCALL(dup)
 8dc:	b8 0a 00 00 00       	mov    $0xa,%eax
 8e1:	cd 40                	int    $0x40
 8e3:	c3                   	ret    

000008e4 <getpid>:
SYSCALL(getpid)
 8e4:	b8 0b 00 00 00       	mov    $0xb,%eax
 8e9:	cd 40                	int    $0x40
 8eb:	c3                   	ret    

000008ec <sbrk>:
SYSCALL(sbrk)
 8ec:	b8 0c 00 00 00       	mov    $0xc,%eax
 8f1:	cd 40                	int    $0x40
 8f3:	c3                   	ret    

000008f4 <sleep>:
SYSCALL(sleep)
 8f4:	b8 0d 00 00 00       	mov    $0xd,%eax
 8f9:	cd 40                	int    $0x40
 8fb:	c3                   	ret    

000008fc <uptime>:
SYSCALL(uptime)
 8fc:	b8 0e 00 00 00       	mov    $0xe,%eax
 901:	cd 40                	int    $0x40
 903:	c3                   	ret    

00000904 <getticks>:
SYSCALL(getticks)
 904:	b8 16 00 00 00       	mov    $0x16,%eax
 909:	cd 40                	int    $0x40
 90b:	c3                   	ret    

0000090c <ccreate>:
SYSCALL(ccreate)
 90c:	b8 17 00 00 00       	mov    $0x17,%eax
 911:	cd 40                	int    $0x40
 913:	c3                   	ret    

00000914 <cstart>:
SYSCALL(cstart)
 914:	b8 19 00 00 00       	mov    $0x19,%eax
 919:	cd 40                	int    $0x40
 91b:	c3                   	ret    

0000091c <cstop>:
SYSCALL(cstop)
 91c:	b8 18 00 00 00       	mov    $0x18,%eax
 921:	cd 40                	int    $0x40
 923:	c3                   	ret    

00000924 <cpause>:
SYSCALL(cpause)
 924:	b8 1b 00 00 00       	mov    $0x1b,%eax
 929:	cd 40                	int    $0x40
 92b:	c3                   	ret    

0000092c <cinfo>:
SYSCALL(cinfo)
 92c:	b8 1a 00 00 00       	mov    $0x1a,%eax
 931:	cd 40                	int    $0x40
 933:	c3                   	ret    

00000934 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 934:	55                   	push   %ebp
 935:	89 e5                	mov    %esp,%ebp
 937:	83 ec 18             	sub    $0x18,%esp
 93a:	8b 45 0c             	mov    0xc(%ebp),%eax
 93d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 940:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 947:	00 
 948:	8d 45 f4             	lea    -0xc(%ebp),%eax
 94b:	89 44 24 04          	mov    %eax,0x4(%esp)
 94f:	8b 45 08             	mov    0x8(%ebp),%eax
 952:	89 04 24             	mov    %eax,(%esp)
 955:	e8 2a ff ff ff       	call   884 <write>
}
 95a:	c9                   	leave  
 95b:	c3                   	ret    

0000095c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 95c:	55                   	push   %ebp
 95d:	89 e5                	mov    %esp,%ebp
 95f:	56                   	push   %esi
 960:	53                   	push   %ebx
 961:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 964:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 96b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 96f:	74 17                	je     988 <printint+0x2c>
 971:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 975:	79 11                	jns    988 <printint+0x2c>
    neg = 1;
 977:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 97e:	8b 45 0c             	mov    0xc(%ebp),%eax
 981:	f7 d8                	neg    %eax
 983:	89 45 ec             	mov    %eax,-0x14(%ebp)
 986:	eb 06                	jmp    98e <printint+0x32>
  } else {
    x = xx;
 988:	8b 45 0c             	mov    0xc(%ebp),%eax
 98b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 98e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 995:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 998:	8d 41 01             	lea    0x1(%ecx),%eax
 99b:	89 45 f4             	mov    %eax,-0xc(%ebp)
 99e:	8b 5d 10             	mov    0x10(%ebp),%ebx
 9a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9a4:	ba 00 00 00 00       	mov    $0x0,%edx
 9a9:	f7 f3                	div    %ebx
 9ab:	89 d0                	mov    %edx,%eax
 9ad:	8a 80 b0 12 00 00    	mov    0x12b0(%eax),%al
 9b3:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 9b7:	8b 75 10             	mov    0x10(%ebp),%esi
 9ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
 9bd:	ba 00 00 00 00       	mov    $0x0,%edx
 9c2:	f7 f6                	div    %esi
 9c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 9c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 9cb:	75 c8                	jne    995 <printint+0x39>
  if(neg)
 9cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 9d1:	74 10                	je     9e3 <printint+0x87>
    buf[i++] = '-';
 9d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9d6:	8d 50 01             	lea    0x1(%eax),%edx
 9d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
 9dc:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 9e1:	eb 1e                	jmp    a01 <printint+0xa5>
 9e3:	eb 1c                	jmp    a01 <printint+0xa5>
    putc(fd, buf[i]);
 9e5:	8d 55 dc             	lea    -0x24(%ebp),%edx
 9e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9eb:	01 d0                	add    %edx,%eax
 9ed:	8a 00                	mov    (%eax),%al
 9ef:	0f be c0             	movsbl %al,%eax
 9f2:	89 44 24 04          	mov    %eax,0x4(%esp)
 9f6:	8b 45 08             	mov    0x8(%ebp),%eax
 9f9:	89 04 24             	mov    %eax,(%esp)
 9fc:	e8 33 ff ff ff       	call   934 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 a01:	ff 4d f4             	decl   -0xc(%ebp)
 a04:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 a08:	79 db                	jns    9e5 <printint+0x89>
    putc(fd, buf[i]);
}
 a0a:	83 c4 30             	add    $0x30,%esp
 a0d:	5b                   	pop    %ebx
 a0e:	5e                   	pop    %esi
 a0f:	5d                   	pop    %ebp
 a10:	c3                   	ret    

00000a11 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 a11:	55                   	push   %ebp
 a12:	89 e5                	mov    %esp,%ebp
 a14:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 a17:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 a1e:	8d 45 0c             	lea    0xc(%ebp),%eax
 a21:	83 c0 04             	add    $0x4,%eax
 a24:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 a27:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 a2e:	e9 77 01 00 00       	jmp    baa <printf+0x199>
    c = fmt[i] & 0xff;
 a33:	8b 55 0c             	mov    0xc(%ebp),%edx
 a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a39:	01 d0                	add    %edx,%eax
 a3b:	8a 00                	mov    (%eax),%al
 a3d:	0f be c0             	movsbl %al,%eax
 a40:	25 ff 00 00 00       	and    $0xff,%eax
 a45:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 a48:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 a4c:	75 2c                	jne    a7a <printf+0x69>
      if(c == '%'){
 a4e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a52:	75 0c                	jne    a60 <printf+0x4f>
        state = '%';
 a54:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 a5b:	e9 47 01 00 00       	jmp    ba7 <printf+0x196>
      } else {
        putc(fd, c);
 a60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a63:	0f be c0             	movsbl %al,%eax
 a66:	89 44 24 04          	mov    %eax,0x4(%esp)
 a6a:	8b 45 08             	mov    0x8(%ebp),%eax
 a6d:	89 04 24             	mov    %eax,(%esp)
 a70:	e8 bf fe ff ff       	call   934 <putc>
 a75:	e9 2d 01 00 00       	jmp    ba7 <printf+0x196>
      }
    } else if(state == '%'){
 a7a:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 a7e:	0f 85 23 01 00 00    	jne    ba7 <printf+0x196>
      if(c == 'd'){
 a84:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 a88:	75 2d                	jne    ab7 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 a8a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a8d:	8b 00                	mov    (%eax),%eax
 a8f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 a96:	00 
 a97:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 a9e:	00 
 a9f:	89 44 24 04          	mov    %eax,0x4(%esp)
 aa3:	8b 45 08             	mov    0x8(%ebp),%eax
 aa6:	89 04 24             	mov    %eax,(%esp)
 aa9:	e8 ae fe ff ff       	call   95c <printint>
        ap++;
 aae:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 ab2:	e9 e9 00 00 00       	jmp    ba0 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 ab7:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 abb:	74 06                	je     ac3 <printf+0xb2>
 abd:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 ac1:	75 2d                	jne    af0 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 ac3:	8b 45 e8             	mov    -0x18(%ebp),%eax
 ac6:	8b 00                	mov    (%eax),%eax
 ac8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 acf:	00 
 ad0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 ad7:	00 
 ad8:	89 44 24 04          	mov    %eax,0x4(%esp)
 adc:	8b 45 08             	mov    0x8(%ebp),%eax
 adf:	89 04 24             	mov    %eax,(%esp)
 ae2:	e8 75 fe ff ff       	call   95c <printint>
        ap++;
 ae7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 aeb:	e9 b0 00 00 00       	jmp    ba0 <printf+0x18f>
      } else if(c == 's'){
 af0:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 af4:	75 42                	jne    b38 <printf+0x127>
        s = (char*)*ap;
 af6:	8b 45 e8             	mov    -0x18(%ebp),%eax
 af9:	8b 00                	mov    (%eax),%eax
 afb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 afe:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 b02:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 b06:	75 09                	jne    b11 <printf+0x100>
          s = "(null)";
 b08:	c7 45 f4 39 0f 00 00 	movl   $0xf39,-0xc(%ebp)
        while(*s != 0){
 b0f:	eb 1c                	jmp    b2d <printf+0x11c>
 b11:	eb 1a                	jmp    b2d <printf+0x11c>
          putc(fd, *s);
 b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b16:	8a 00                	mov    (%eax),%al
 b18:	0f be c0             	movsbl %al,%eax
 b1b:	89 44 24 04          	mov    %eax,0x4(%esp)
 b1f:	8b 45 08             	mov    0x8(%ebp),%eax
 b22:	89 04 24             	mov    %eax,(%esp)
 b25:	e8 0a fe ff ff       	call   934 <putc>
          s++;
 b2a:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b30:	8a 00                	mov    (%eax),%al
 b32:	84 c0                	test   %al,%al
 b34:	75 dd                	jne    b13 <printf+0x102>
 b36:	eb 68                	jmp    ba0 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 b38:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 b3c:	75 1d                	jne    b5b <printf+0x14a>
        putc(fd, *ap);
 b3e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b41:	8b 00                	mov    (%eax),%eax
 b43:	0f be c0             	movsbl %al,%eax
 b46:	89 44 24 04          	mov    %eax,0x4(%esp)
 b4a:	8b 45 08             	mov    0x8(%ebp),%eax
 b4d:	89 04 24             	mov    %eax,(%esp)
 b50:	e8 df fd ff ff       	call   934 <putc>
        ap++;
 b55:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b59:	eb 45                	jmp    ba0 <printf+0x18f>
      } else if(c == '%'){
 b5b:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 b5f:	75 17                	jne    b78 <printf+0x167>
        putc(fd, c);
 b61:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b64:	0f be c0             	movsbl %al,%eax
 b67:	89 44 24 04          	mov    %eax,0x4(%esp)
 b6b:	8b 45 08             	mov    0x8(%ebp),%eax
 b6e:	89 04 24             	mov    %eax,(%esp)
 b71:	e8 be fd ff ff       	call   934 <putc>
 b76:	eb 28                	jmp    ba0 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 b78:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 b7f:	00 
 b80:	8b 45 08             	mov    0x8(%ebp),%eax
 b83:	89 04 24             	mov    %eax,(%esp)
 b86:	e8 a9 fd ff ff       	call   934 <putc>
        putc(fd, c);
 b8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b8e:	0f be c0             	movsbl %al,%eax
 b91:	89 44 24 04          	mov    %eax,0x4(%esp)
 b95:	8b 45 08             	mov    0x8(%ebp),%eax
 b98:	89 04 24             	mov    %eax,(%esp)
 b9b:	e8 94 fd ff ff       	call   934 <putc>
      }
      state = 0;
 ba0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 ba7:	ff 45 f0             	incl   -0x10(%ebp)
 baa:	8b 55 0c             	mov    0xc(%ebp),%edx
 bad:	8b 45 f0             	mov    -0x10(%ebp),%eax
 bb0:	01 d0                	add    %edx,%eax
 bb2:	8a 00                	mov    (%eax),%al
 bb4:	84 c0                	test   %al,%al
 bb6:	0f 85 77 fe ff ff    	jne    a33 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 bbc:	c9                   	leave  
 bbd:	c3                   	ret    
 bbe:	90                   	nop
 bbf:	90                   	nop

00000bc0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 bc0:	55                   	push   %ebp
 bc1:	89 e5                	mov    %esp,%ebp
 bc3:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 bc6:	8b 45 08             	mov    0x8(%ebp),%eax
 bc9:	83 e8 08             	sub    $0x8,%eax
 bcc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bcf:	a1 cc 12 00 00       	mov    0x12cc,%eax
 bd4:	89 45 fc             	mov    %eax,-0x4(%ebp)
 bd7:	eb 24                	jmp    bfd <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 bd9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bdc:	8b 00                	mov    (%eax),%eax
 bde:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 be1:	77 12                	ja     bf5 <free+0x35>
 be3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 be6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 be9:	77 24                	ja     c0f <free+0x4f>
 beb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bee:	8b 00                	mov    (%eax),%eax
 bf0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 bf3:	77 1a                	ja     c0f <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bf5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bf8:	8b 00                	mov    (%eax),%eax
 bfa:	89 45 fc             	mov    %eax,-0x4(%ebp)
 bfd:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c00:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 c03:	76 d4                	jbe    bd9 <free+0x19>
 c05:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c08:	8b 00                	mov    (%eax),%eax
 c0a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 c0d:	76 ca                	jbe    bd9 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 c0f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c12:	8b 40 04             	mov    0x4(%eax),%eax
 c15:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 c1c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c1f:	01 c2                	add    %eax,%edx
 c21:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c24:	8b 00                	mov    (%eax),%eax
 c26:	39 c2                	cmp    %eax,%edx
 c28:	75 24                	jne    c4e <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 c2a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c2d:	8b 50 04             	mov    0x4(%eax),%edx
 c30:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c33:	8b 00                	mov    (%eax),%eax
 c35:	8b 40 04             	mov    0x4(%eax),%eax
 c38:	01 c2                	add    %eax,%edx
 c3a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c3d:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 c40:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c43:	8b 00                	mov    (%eax),%eax
 c45:	8b 10                	mov    (%eax),%edx
 c47:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c4a:	89 10                	mov    %edx,(%eax)
 c4c:	eb 0a                	jmp    c58 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 c4e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c51:	8b 10                	mov    (%eax),%edx
 c53:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c56:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 c58:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c5b:	8b 40 04             	mov    0x4(%eax),%eax
 c5e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 c65:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c68:	01 d0                	add    %edx,%eax
 c6a:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 c6d:	75 20                	jne    c8f <free+0xcf>
    p->s.size += bp->s.size;
 c6f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c72:	8b 50 04             	mov    0x4(%eax),%edx
 c75:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c78:	8b 40 04             	mov    0x4(%eax),%eax
 c7b:	01 c2                	add    %eax,%edx
 c7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c80:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 c83:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c86:	8b 10                	mov    (%eax),%edx
 c88:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c8b:	89 10                	mov    %edx,(%eax)
 c8d:	eb 08                	jmp    c97 <free+0xd7>
  } else
    p->s.ptr = bp;
 c8f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c92:	8b 55 f8             	mov    -0x8(%ebp),%edx
 c95:	89 10                	mov    %edx,(%eax)
  freep = p;
 c97:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c9a:	a3 cc 12 00 00       	mov    %eax,0x12cc
}
 c9f:	c9                   	leave  
 ca0:	c3                   	ret    

00000ca1 <morecore>:

static Header*
morecore(uint nu)
{
 ca1:	55                   	push   %ebp
 ca2:	89 e5                	mov    %esp,%ebp
 ca4:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 ca7:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 cae:	77 07                	ja     cb7 <morecore+0x16>
    nu = 4096;
 cb0:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 cb7:	8b 45 08             	mov    0x8(%ebp),%eax
 cba:	c1 e0 03             	shl    $0x3,%eax
 cbd:	89 04 24             	mov    %eax,(%esp)
 cc0:	e8 27 fc ff ff       	call   8ec <sbrk>
 cc5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 cc8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 ccc:	75 07                	jne    cd5 <morecore+0x34>
    return 0;
 cce:	b8 00 00 00 00       	mov    $0x0,%eax
 cd3:	eb 22                	jmp    cf7 <morecore+0x56>
  hp = (Header*)p;
 cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 cd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 cdb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cde:	8b 55 08             	mov    0x8(%ebp),%edx
 ce1:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 ce4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ce7:	83 c0 08             	add    $0x8,%eax
 cea:	89 04 24             	mov    %eax,(%esp)
 ced:	e8 ce fe ff ff       	call   bc0 <free>
  return freep;
 cf2:	a1 cc 12 00 00       	mov    0x12cc,%eax
}
 cf7:	c9                   	leave  
 cf8:	c3                   	ret    

00000cf9 <malloc>:

void*
malloc(uint nbytes)
{
 cf9:	55                   	push   %ebp
 cfa:	89 e5                	mov    %esp,%ebp
 cfc:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 cff:	8b 45 08             	mov    0x8(%ebp),%eax
 d02:	83 c0 07             	add    $0x7,%eax
 d05:	c1 e8 03             	shr    $0x3,%eax
 d08:	40                   	inc    %eax
 d09:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 d0c:	a1 cc 12 00 00       	mov    0x12cc,%eax
 d11:	89 45 f0             	mov    %eax,-0x10(%ebp)
 d14:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 d18:	75 23                	jne    d3d <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 d1a:	c7 45 f0 c4 12 00 00 	movl   $0x12c4,-0x10(%ebp)
 d21:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d24:	a3 cc 12 00 00       	mov    %eax,0x12cc
 d29:	a1 cc 12 00 00       	mov    0x12cc,%eax
 d2e:	a3 c4 12 00 00       	mov    %eax,0x12c4
    base.s.size = 0;
 d33:	c7 05 c8 12 00 00 00 	movl   $0x0,0x12c8
 d3a:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d40:	8b 00                	mov    (%eax),%eax
 d42:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 d45:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d48:	8b 40 04             	mov    0x4(%eax),%eax
 d4b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 d4e:	72 4d                	jb     d9d <malloc+0xa4>
      if(p->s.size == nunits)
 d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d53:	8b 40 04             	mov    0x4(%eax),%eax
 d56:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 d59:	75 0c                	jne    d67 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 d5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d5e:	8b 10                	mov    (%eax),%edx
 d60:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d63:	89 10                	mov    %edx,(%eax)
 d65:	eb 26                	jmp    d8d <malloc+0x94>
      else {
        p->s.size -= nunits;
 d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d6a:	8b 40 04             	mov    0x4(%eax),%eax
 d6d:	2b 45 ec             	sub    -0x14(%ebp),%eax
 d70:	89 c2                	mov    %eax,%edx
 d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d75:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 d78:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d7b:	8b 40 04             	mov    0x4(%eax),%eax
 d7e:	c1 e0 03             	shl    $0x3,%eax
 d81:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d87:	8b 55 ec             	mov    -0x14(%ebp),%edx
 d8a:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 d8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d90:	a3 cc 12 00 00       	mov    %eax,0x12cc
      return (void*)(p + 1);
 d95:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d98:	83 c0 08             	add    $0x8,%eax
 d9b:	eb 38                	jmp    dd5 <malloc+0xdc>
    }
    if(p == freep)
 d9d:	a1 cc 12 00 00       	mov    0x12cc,%eax
 da2:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 da5:	75 1b                	jne    dc2 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 da7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 daa:	89 04 24             	mov    %eax,(%esp)
 dad:	e8 ef fe ff ff       	call   ca1 <morecore>
 db2:	89 45 f4             	mov    %eax,-0xc(%ebp)
 db5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 db9:	75 07                	jne    dc2 <malloc+0xc9>
        return 0;
 dbb:	b8 00 00 00 00       	mov    $0x0,%eax
 dc0:	eb 13                	jmp    dd5 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
 dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 dcb:	8b 00                	mov    (%eax),%eax
 dcd:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 dd0:	e9 70 ff ff ff       	jmp    d45 <malloc+0x4c>
}
 dd5:	c9                   	leave  
 dd6:	c3                   	ret    
