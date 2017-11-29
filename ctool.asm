
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
   d:	c7 44 24 04 a4 0d 00 	movl   $0xda4,0x4(%esp)
  14:	00 
  15:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1c:	e8 bc 09 00 00       	call   9dd <printf>
    exit();
  21:	e8 0a 08 00 00       	call   830 <exit>

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
  int pathsize = sizeof(dst) + sizeof(file) + 2; // dst.len + '\' + src.len + \0
  36:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
  char path[pathsize]; 
  3d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  40:	8d 50 ff             	lea    -0x1(%eax),%edx
  43:	89 55 e0             	mov    %edx,-0x20(%ebp)
  46:	ba 10 00 00 00       	mov    $0x10,%edx
  4b:	4a                   	dec    %edx
  4c:	01 d0                	add    %edx,%eax
  4e:	b9 10 00 00 00       	mov    $0x10,%ecx
  53:	ba 00 00 00 00       	mov    $0x0,%edx
  58:	f7 f1                	div    %ecx
  5a:	6b c0 10             	imul   $0x10,%eax,%eax
  5d:	29 c4                	sub    %eax,%esp
  5f:	8d 44 24 0c          	lea    0xc(%esp),%eax
  63:	83 c0 00             	add    $0x0,%eax
  66:	89 45 dc             	mov    %eax,-0x24(%ebp)

  memmove(path, dst, strlen(file));
  69:	8b 45 0c             	mov    0xc(%ebp),%eax
  6c:	89 04 24             	mov    %eax,(%esp)
  6f:	e8 f3 05 00 00       	call   667 <strlen>
  74:	89 c2                	mov    %eax,%edx
  76:	8b 45 dc             	mov    -0x24(%ebp),%eax
  79:	89 54 24 08          	mov    %edx,0x8(%esp)
  7d:	8b 55 08             	mov    0x8(%ebp),%edx
  80:	89 54 24 04          	mov    %edx,0x4(%esp)
  84:	89 04 24             	mov    %eax,(%esp)
  87:	e8 5d 07 00 00       	call   7e9 <memmove>
  memmove(path + strlen(dst), "/", 1);
  8c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8f:	8b 45 08             	mov    0x8(%ebp),%eax
  92:	89 04 24             	mov    %eax,(%esp)
  95:	e8 cd 05 00 00       	call   667 <strlen>
  9a:	01 d8                	add    %ebx,%eax
  9c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  a3:	00 
  a4:	c7 44 24 04 b5 0d 00 	movl   $0xdb5,0x4(%esp)
  ab:	00 
  ac:	89 04 24             	mov    %eax,(%esp)
  af:	e8 35 07 00 00       	call   7e9 <memmove>
  memmove(path + strlen(dst) + 1, file, strlen(file));
  b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  b7:	89 04 24             	mov    %eax,(%esp)
  ba:	e8 a8 05 00 00       	call   667 <strlen>
  bf:	89 c3                	mov    %eax,%ebx
  c1:	8b 7d dc             	mov    -0x24(%ebp),%edi
  c4:	8b 45 08             	mov    0x8(%ebp),%eax
  c7:	89 04 24             	mov    %eax,(%esp)
  ca:	e8 98 05 00 00       	call   667 <strlen>
  cf:	40                   	inc    %eax
  d0:	8d 14 07             	lea    (%edi,%eax,1),%edx
  d3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  da:	89 44 24 04          	mov    %eax,0x4(%esp)
  de:	89 14 24             	mov    %edx,(%esp)
  e1:	e8 03 07 00 00       	call   7e9 <memmove>
  memmove(path + strlen(dst) + 1 + strlen(file), "\0", 1);
  e6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  e9:	8b 45 08             	mov    0x8(%ebp),%eax
  ec:	89 04 24             	mov    %eax,(%esp)
  ef:	e8 73 05 00 00       	call   667 <strlen>
  f4:	89 c3                	mov    %eax,%ebx
  f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  f9:	89 04 24             	mov    %eax,(%esp)
  fc:	e8 66 05 00 00       	call   667 <strlen>
 101:	01 d8                	add    %ebx,%eax
 103:	40                   	inc    %eax
 104:	01 f8                	add    %edi,%eax
 106:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 10d:	00 
 10e:	c7 44 24 04 b7 0d 00 	movl   $0xdb7,0x4(%esp)
 115:	00 
 116:	89 04 24             	mov    %eax,(%esp)
 119:	e8 cb 06 00 00       	call   7e9 <memmove>

  files[0] = open(file, O_RDONLY);
 11e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 125:	00 
 126:	8b 45 0c             	mov    0xc(%ebp),%eax
 129:	89 04 24             	mov    %eax,(%esp)
 12c:	e8 3f 07 00 00       	call   870 <open>
 131:	89 85 d0 fb ff ff    	mov    %eax,-0x430(%ebp)
  if (files[0] == -1) // Check if file opened 
 137:	8b 85 d0 fb ff ff    	mov    -0x430(%ebp),%eax
 13d:	83 f8 ff             	cmp    $0xffffffff,%eax
 140:	75 0a                	jne    14c <cp+0x126>
      return -1;
 142:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 147:	e9 88 00 00 00       	jmp    1d4 <cp+0x1ae>
  files[1] = open(path, O_WRONLY | O_CREATE);
 14c:	8b 45 dc             	mov    -0x24(%ebp),%eax
 14f:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
 156:	00 
 157:	89 04 24             	mov    %eax,(%esp)
 15a:	e8 11 07 00 00       	call   870 <open>
 15f:	89 85 d4 fb ff ff    	mov    %eax,-0x42c(%ebp)
  if (files[1] == -1) { // Check if file opened (permissions problems ...) 
 165:	8b 85 d4 fb ff ff    	mov    -0x42c(%ebp),%eax
 16b:	83 f8 ff             	cmp    $0xffffffff,%eax
 16e:	75 15                	jne    185 <cp+0x15f>
      close(files[0]);
 170:	8b 85 d0 fb ff ff    	mov    -0x430(%ebp),%eax
 176:	89 04 24             	mov    %eax,(%esp)
 179:	e8 da 06 00 00       	call   858 <close>
      return -1;
 17e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 183:	eb 4f                	jmp    1d4 <cp+0x1ae>
  }

  while ((count = read(files[0], buffer, sizeof(buffer))) != 0)
 185:	eb 1f                	jmp    1a6 <cp+0x180>
      write(files[1], buffer, count);
 187:	8b 85 d4 fb ff ff    	mov    -0x42c(%ebp),%eax
 18d:	8b 55 d8             	mov    -0x28(%ebp),%edx
 190:	89 54 24 08          	mov    %edx,0x8(%esp)
 194:	8d 95 d8 fb ff ff    	lea    -0x428(%ebp),%edx
 19a:	89 54 24 04          	mov    %edx,0x4(%esp)
 19e:	89 04 24             	mov    %eax,(%esp)
 1a1:	e8 aa 06 00 00       	call   850 <write>
  if (files[1] == -1) { // Check if file opened (permissions problems ...) 
      close(files[0]);
      return -1;
  }

  while ((count = read(files[0], buffer, sizeof(buffer))) != 0)
 1a6:	8b 85 d0 fb ff ff    	mov    -0x430(%ebp),%eax
 1ac:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
 1b3:	00 
 1b4:	8d 95 d8 fb ff ff    	lea    -0x428(%ebp),%edx
 1ba:	89 54 24 04          	mov    %edx,0x4(%esp)
 1be:	89 04 24             	mov    %eax,(%esp)
 1c1:	e8 82 06 00 00       	call   848 <read>
 1c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
 1c9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
 1cd:	75 b8                	jne    187 <cp+0x161>
      write(files[1], buffer, count);

  return 1;
 1cf:	b8 01 00 00 00       	mov    $0x1,%eax
 1d4:	89 f4                	mov    %esi,%esp
}
 1d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1d9:	5b                   	pop    %ebx
 1da:	5e                   	pop    %esi
 1db:	5f                   	pop    %edi
 1dc:	5d                   	pop    %ebp
 1dd:	c3                   	ret    

000001de <max>:

int
max(int a, int b)
{
 1de:	55                   	push   %ebp
 1df:	89 e5                	mov    %esp,%ebp
  if (a > b)
 1e1:	8b 45 08             	mov    0x8(%ebp),%eax
 1e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1e7:	7e 05                	jle    1ee <max+0x10>
    return a;
 1e9:	8b 45 08             	mov    0x8(%ebp),%eax
 1ec:	eb 03                	jmp    1f1 <max+0x13>
  else
    return b;
 1ee:	8b 45 0c             	mov    0xc(%ebp),%eax
}
 1f1:	5d                   	pop    %ebp
 1f2:	c3                   	ret    

000001f3 <create>:
// ctool create ctest1 -p 4 sh ps cat echo
// folder/ container name, what to copy into folder
// mkdir, cp file 1, cp file n  
void
create(int argc, char *argv[])
{
 1f3:	55                   	push   %ebp
 1f4:	89 e5                	mov    %esp,%ebp
 1f6:	81 ec c8 00 00 00    	sub    $0xc8,%esp
  char *progv[32];
  int i, k, progc, last_flag = 2, // No flags
 1fc:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  mproc = CONT_MAX_PROC, 
 203:	c7 45 e8 08 00 00 00 	movl   $0x8,-0x18(%ebp)
  msz = CONT_MAX_MEM, 
 20a:	c7 45 e4 00 04 00 00 	movl   $0x400,-0x1c(%ebp)
  mdsk = CONT_MAX_DISK;  
 211:	c7 45 e0 00 04 00 00 	movl   $0x400,-0x20(%ebp)

  if (argc < 4)
 218:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
 21c:	7f 0c                	jg     22a <create+0x37>
    usage("create <name> [-p <max_processes>] [-m <max_memory>] [-d <max_disk>] prog [prog2.. ]");
 21e:	c7 04 24 bc 0d 00 00 	movl   $0xdbc,(%esp)
 225:	e8 d6 fd ff ff       	call   0 <usage>


  for (i = 0; i < argc; i++) {
 22a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 231:	e9 0b 01 00 00       	jmp    341 <create+0x14e>
    if (strcmp(argv[i], "-p") == 0) {
 236:	8b 45 f4             	mov    -0xc(%ebp),%eax
 239:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 240:	8b 45 0c             	mov    0xc(%ebp),%eax
 243:	01 d0                	add    %edx,%eax
 245:	8b 00                	mov    (%eax),%eax
 247:	c7 44 24 04 11 0e 00 	movl   $0xe11,0x4(%esp)
 24e:	00 
 24f:	89 04 24             	mov    %eax,(%esp)
 252:	e8 d8 03 00 00       	call   62f <strcmp>
 257:	85 c0                	test   %eax,%eax
 259:	75 33                	jne    28e <create+0x9b>
      last_flag = max(last_flag, i + 1);
 25b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 25e:	40                   	inc    %eax
 25f:	89 44 24 04          	mov    %eax,0x4(%esp)
 263:	8b 45 ec             	mov    -0x14(%ebp),%eax
 266:	89 04 24             	mov    %eax,(%esp)
 269:	e8 70 ff ff ff       	call   1de <max>
 26e:	89 45 ec             	mov    %eax,-0x14(%ebp)
      mproc = atoi(argv[i + 1]);
 271:	8b 45 f4             	mov    -0xc(%ebp),%eax
 274:	40                   	inc    %eax
 275:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 27c:	8b 45 0c             	mov    0xc(%ebp),%eax
 27f:	01 d0                	add    %edx,%eax
 281:	8b 00                	mov    (%eax),%eax
 283:	89 04 24             	mov    %eax,(%esp)
 286:	e8 14 05 00 00       	call   79f <atoi>
 28b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    }
    if (strcmp(argv[i], "-m") == 0) {
 28e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 291:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 298:	8b 45 0c             	mov    0xc(%ebp),%eax
 29b:	01 d0                	add    %edx,%eax
 29d:	8b 00                	mov    (%eax),%eax
 29f:	c7 44 24 04 14 0e 00 	movl   $0xe14,0x4(%esp)
 2a6:	00 
 2a7:	89 04 24             	mov    %eax,(%esp)
 2aa:	e8 80 03 00 00       	call   62f <strcmp>
 2af:	85 c0                	test   %eax,%eax
 2b1:	75 33                	jne    2e6 <create+0xf3>
      last_flag = max(last_flag, i + 1);
 2b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2b6:	40                   	inc    %eax
 2b7:	89 44 24 04          	mov    %eax,0x4(%esp)
 2bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 2be:	89 04 24             	mov    %eax,(%esp)
 2c1:	e8 18 ff ff ff       	call   1de <max>
 2c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
      msz = atoi(argv[i + 1]);
 2c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2cc:	40                   	inc    %eax
 2cd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 2d4:	8b 45 0c             	mov    0xc(%ebp),%eax
 2d7:	01 d0                	add    %edx,%eax
 2d9:	8b 00                	mov    (%eax),%eax
 2db:	89 04 24             	mov    %eax,(%esp)
 2de:	e8 bc 04 00 00       	call   79f <atoi>
 2e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    }
    if (strcmp(argv[i], "-d") == 0) {
 2e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2e9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 2f0:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f3:	01 d0                	add    %edx,%eax
 2f5:	8b 00                	mov    (%eax),%eax
 2f7:	c7 44 24 04 17 0e 00 	movl   $0xe17,0x4(%esp)
 2fe:	00 
 2ff:	89 04 24             	mov    %eax,(%esp)
 302:	e8 28 03 00 00       	call   62f <strcmp>
 307:	85 c0                	test   %eax,%eax
 309:	75 33                	jne    33e <create+0x14b>
      last_flag = max(last_flag, i + 1);
 30b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 30e:	40                   	inc    %eax
 30f:	89 44 24 04          	mov    %eax,0x4(%esp)
 313:	8b 45 ec             	mov    -0x14(%ebp),%eax
 316:	89 04 24             	mov    %eax,(%esp)
 319:	e8 c0 fe ff ff       	call   1de <max>
 31e:	89 45 ec             	mov    %eax,-0x14(%ebp)
      mdsk = atoi(argv[i + 1]);
 321:	8b 45 f4             	mov    -0xc(%ebp),%eax
 324:	40                   	inc    %eax
 325:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 32c:	8b 45 0c             	mov    0xc(%ebp),%eax
 32f:	01 d0                	add    %edx,%eax
 331:	8b 00                	mov    (%eax),%eax
 333:	89 04 24             	mov    %eax,(%esp)
 336:	e8 64 04 00 00       	call   79f <atoi>
 33b:	89 45 e0             	mov    %eax,-0x20(%ebp)

  if (argc < 4)
    usage("create <name> [-p <max_processes>] [-m <max_memory>] [-d <max_disk>] prog [prog2.. ]");


  for (i = 0; i < argc; i++) {
 33e:	ff 45 f4             	incl   -0xc(%ebp)
 341:	8b 45 f4             	mov    -0xc(%ebp),%eax
 344:	3b 45 08             	cmp    0x8(%ebp),%eax
 347:	0f 8c e9 fe ff ff    	jl     236 <create+0x43>
      last_flag = max(last_flag, i + 1);
      mdsk = atoi(argv[i + 1]);
    }
  }

  progc = argc - last_flag - 1;
 34d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 350:	8b 55 08             	mov    0x8(%ebp),%edx
 353:	29 c2                	sub    %eax,%edx
 355:	89 d0                	mov    %edx,%eax
 357:	48                   	dec    %eax
 358:	89 45 dc             	mov    %eax,-0x24(%ebp)

  for (i = last_flag + 1, k = 0; i < argc; i++, k++) {
 35b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 35e:	40                   	inc    %eax
 35f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 362:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 369:	e9 e0 00 00 00       	jmp    44e <create+0x25b>
    printf(1, "%s", argv[i]);
 36e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 371:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 378:	8b 45 0c             	mov    0xc(%ebp),%eax
 37b:	01 d0                	add    %edx,%eax
 37d:	8b 00                	mov    (%eax),%eax
 37f:	89 44 24 08          	mov    %eax,0x8(%esp)
 383:	c7 44 24 04 1a 0e 00 	movl   $0xe1a,0x4(%esp)
 38a:	00 
 38b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 392:	e8 46 06 00 00       	call   9dd <printf>

    // TODO: move this into the kernel or the rest of ccreate out of the kernel
    cp(argv[2], argv[i]);
 397:	8b 45 f4             	mov    -0xc(%ebp),%eax
 39a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 3a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a4:	01 d0                	add    %edx,%eax
 3a6:	8b 10                	mov    (%eax),%edx
 3a8:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ab:	83 c0 08             	add    $0x8,%eax
 3ae:	8b 00                	mov    (%eax),%eax
 3b0:	89 54 24 04          	mov    %edx,0x4(%esp)
 3b4:	89 04 24             	mov    %eax,(%esp)
 3b7:	e8 6a fc ff ff       	call   26 <cp>
    
    // If we were using kernel for ccreate sys call
    progv[k] = malloc(sizeof(argv[i])); memmove(progv[k], argv[i], sizeof(argv[i])); memmove(progv[k] + sizeof(argv[i]), "\0", 1); printf(1, "\t%s\n", progv[k]);
 3bc:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
 3c3:	e8 fd 08 00 00       	call   cc5 <malloc>
 3c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
 3cb:	89 84 95 5c ff ff ff 	mov    %eax,-0xa4(%ebp,%edx,4)
 3d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3d5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 3dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3df:	01 d0                	add    %edx,%eax
 3e1:	8b 10                	mov    (%eax),%edx
 3e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 3e6:	8b 84 85 5c ff ff ff 	mov    -0xa4(%ebp,%eax,4),%eax
 3ed:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
 3f4:	00 
 3f5:	89 54 24 04          	mov    %edx,0x4(%esp)
 3f9:	89 04 24             	mov    %eax,(%esp)
 3fc:	e8 e8 03 00 00       	call   7e9 <memmove>
 401:	8b 45 f0             	mov    -0x10(%ebp),%eax
 404:	8b 84 85 5c ff ff ff 	mov    -0xa4(%ebp,%eax,4),%eax
 40b:	83 c0 04             	add    $0x4,%eax
 40e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 415:	00 
 416:	c7 44 24 04 b7 0d 00 	movl   $0xdb7,0x4(%esp)
 41d:	00 
 41e:	89 04 24             	mov    %eax,(%esp)
 421:	e8 c3 03 00 00       	call   7e9 <memmove>
 426:	8b 45 f0             	mov    -0x10(%ebp),%eax
 429:	8b 84 85 5c ff ff ff 	mov    -0xa4(%ebp,%eax,4),%eax
 430:	89 44 24 08          	mov    %eax,0x8(%esp)
 434:	c7 44 24 04 1d 0e 00 	movl   $0xe1d,0x4(%esp)
 43b:	00 
 43c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 443:	e8 95 05 00 00       	call   9dd <printf>
    }
  }

  progc = argc - last_flag - 1;

  for (i = last_flag + 1, k = 0; i < argc; i++, k++) {
 448:	ff 45 f4             	incl   -0xc(%ebp)
 44b:	ff 45 f0             	incl   -0x10(%ebp)
 44e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 451:	3b 45 08             	cmp    0x8(%ebp),%eax
 454:	0f 8c 14 ff ff ff    	jl     36e <create+0x17b>
    // If we were using kernel for ccreate sys call
    progv[k] = malloc(sizeof(argv[i])); memmove(progv[k], argv[i], sizeof(argv[i])); memmove(progv[k] + sizeof(argv[i]), "\0", 1); printf(1, "\t%s\n", progv[k]);
  }  


  printf(1, "name: %s\nmproc: %d\nmsz: %d\nmdsk: %d\nprogc: %d\n", argv[2], mproc, msz, mdsk, progc);
 45a:	8b 45 0c             	mov    0xc(%ebp),%eax
 45d:	83 c0 08             	add    $0x8,%eax
 460:	8b 00                	mov    (%eax),%eax
 462:	8b 55 dc             	mov    -0x24(%ebp),%edx
 465:	89 54 24 18          	mov    %edx,0x18(%esp)
 469:	8b 55 e0             	mov    -0x20(%ebp),%edx
 46c:	89 54 24 14          	mov    %edx,0x14(%esp)
 470:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 473:	89 54 24 10          	mov    %edx,0x10(%esp)
 477:	8b 55 e8             	mov    -0x18(%ebp),%edx
 47a:	89 54 24 0c          	mov    %edx,0xc(%esp)
 47e:	89 44 24 08          	mov    %eax,0x8(%esp)
 482:	c7 44 24 04 24 0e 00 	movl   $0xe24,0x4(%esp)
 489:	00 
 48a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 491:	e8 47 05 00 00       	call   9dd <printf>

  if (ccreate(argv[2], progv, progc, mproc, msz, mdsk) == 1) {
 496:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 499:	8b 55 e4             	mov    -0x1c(%ebp),%edx
 49c:	8b 45 0c             	mov    0xc(%ebp),%eax
 49f:	83 c0 08             	add    $0x8,%eax
 4a2:	8b 00                	mov    (%eax),%eax
 4a4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
 4a8:	89 54 24 10          	mov    %edx,0x10(%esp)
 4ac:	8b 55 e8             	mov    -0x18(%ebp),%edx
 4af:	89 54 24 0c          	mov    %edx,0xc(%esp)
 4b3:	8b 55 dc             	mov    -0x24(%ebp),%edx
 4b6:	89 54 24 08          	mov    %edx,0x8(%esp)
 4ba:	8d 95 5c ff ff ff    	lea    -0xa4(%ebp),%edx
 4c0:	89 54 24 04          	mov    %edx,0x4(%esp)
 4c4:	89 04 24             	mov    %eax,(%esp)
 4c7:	e8 0c 04 00 00       	call   8d8 <ccreate>
 4cc:	83 f8 01             	cmp    $0x1,%eax
 4cf:	75 22                	jne    4f3 <create+0x300>
    printf(1, "Created container %s\n", argv[2]); 
 4d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 4d4:	83 c0 08             	add    $0x8,%eax
 4d7:	8b 00                	mov    (%eax),%eax
 4d9:	89 44 24 08          	mov    %eax,0x8(%esp)
 4dd:	c7 44 24 04 53 0e 00 	movl   $0xe53,0x4(%esp)
 4e4:	00 
 4e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 4ec:	e8 ec 04 00 00       	call   9dd <printf>
 4f1:	eb 20                	jmp    513 <create+0x320>
  } else {
    printf(1, "Failed to create container %s\n", argv[2]); 
 4f3:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f6:	83 c0 08             	add    $0x8,%eax
 4f9:	8b 00                	mov    (%eax),%eax
 4fb:	89 44 24 08          	mov    %eax,0x8(%esp)
 4ff:	c7 44 24 04 6c 0e 00 	movl   $0xe6c,0x4(%esp)
 506:	00 
 507:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 50e:	e8 ca 04 00 00       	call   9dd <printf>
  }
}
 513:	c9                   	leave  
 514:	c3                   	ret    

00000515 <start>:

// ctool start <name> prog arg1 [arg2 ...]
// ctool start c1 echoloop ab
void
start(int argc, char *argv[])
{    
 515:	55                   	push   %ebp
 516:	89 e5                	mov    %esp,%ebp
 518:	83 ec 18             	sub    $0x18,%esp

  if (argc < 4)
 51b:	83 7d 08 03          	cmpl   $0x3,0x8(%ebp)
 51f:	7f 0c                	jg     52d <start+0x18>
    usage("ctool start <name> prog arg1 [arg2 ...]");
 521:	c7 04 24 8c 0e 00 00 	movl   $0xe8c,(%esp)
 528:	e8 d3 fa ff ff       	call   0 <usage>
}
 52d:	c9                   	leave  
 52e:	c3                   	ret    

0000052f <pause>:

void
pause(int argc, char *argv[])
{
 52f:	55                   	push   %ebp
 530:	89 e5                	mov    %esp,%ebp
  
}
 532:	5d                   	pop    %ebp
 533:	c3                   	ret    

00000534 <resume>:

void
resume(int argc, char *argv[])
{
 534:	55                   	push   %ebp
 535:	89 e5                	mov    %esp,%ebp
  
}
 537:	5d                   	pop    %ebp
 538:	c3                   	ret    

00000539 <stop>:

void
stop(int argc, char *argv[])
{
 539:	55                   	push   %ebp
 53a:	89 e5                	mov    %esp,%ebp
  
}
 53c:	5d                   	pop    %ebp
 53d:	c3                   	ret    

0000053e <info>:

void
info(int argc, char *argv[])
{
 53e:	55                   	push   %ebp
 53f:	89 e5                	mov    %esp,%ebp
  
}
 541:	5d                   	pop    %ebp
 542:	c3                   	ret    

00000543 <main>:

int
main(int argc, char *argv[])
{
 543:	55                   	push   %ebp
 544:	89 e5                	mov    %esp,%ebp
 546:	83 e4 f0             	and    $0xfffffff0,%esp
 549:	83 ec 10             	sub    $0x10,%esp

  if (argc < 3) {
 54c:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
 550:	7f 11                	jg     563 <main+0x20>
    usage("<tool> <cmd> [<arg> ...]");
 552:	c7 04 24 b4 0e 00 00 	movl   $0xeb4,(%esp)
 559:	e8 a2 fa ff ff       	call   0 <usage>
    exit();
 55e:	e8 cd 02 00 00       	call   830 <exit>
  }

  if (strcmp(argv[1], "create") == 0)
 563:	8b 45 0c             	mov    0xc(%ebp),%eax
 566:	83 c0 04             	add    $0x4,%eax
 569:	8b 00                	mov    (%eax),%eax
 56b:	c7 44 24 04 cd 0e 00 	movl   $0xecd,0x4(%esp)
 572:	00 
 573:	89 04 24             	mov    %eax,(%esp)
 576:	e8 b4 00 00 00       	call   62f <strcmp>
 57b:	85 c0                	test   %eax,%eax
 57d:	75 14                	jne    593 <main+0x50>
    create(argc, argv);
 57f:	8b 45 0c             	mov    0xc(%ebp),%eax
 582:	89 44 24 04          	mov    %eax,0x4(%esp)
 586:	8b 45 08             	mov    0x8(%ebp),%eax
 589:	89 04 24             	mov    %eax,(%esp)
 58c:	e8 62 fc ff ff       	call   1f3 <create>
 591:	eb 44                	jmp    5d7 <main+0x94>
  else if (strcmp(argv[1], "start") == 0)
 593:	8b 45 0c             	mov    0xc(%ebp),%eax
 596:	83 c0 04             	add    $0x4,%eax
 599:	8b 00                	mov    (%eax),%eax
 59b:	c7 44 24 04 d4 0e 00 	movl   $0xed4,0x4(%esp)
 5a2:	00 
 5a3:	89 04 24             	mov    %eax,(%esp)
 5a6:	e8 84 00 00 00       	call   62f <strcmp>
 5ab:	85 c0                	test   %eax,%eax
 5ad:	75 14                	jne    5c3 <main+0x80>
    start(argc, argv);
 5af:	8b 45 0c             	mov    0xc(%ebp),%eax
 5b2:	89 44 24 04          	mov    %eax,0x4(%esp)
 5b6:	8b 45 08             	mov    0x8(%ebp),%eax
 5b9:	89 04 24             	mov    %eax,(%esp)
 5bc:	e8 54 ff ff ff       	call   515 <start>
 5c1:	eb 14                	jmp    5d7 <main+0x94>
  else 
    printf(1, "ctool: command not found.\n");   
 5c3:	c7 44 24 04 da 0e 00 	movl   $0xeda,0x4(%esp)
 5ca:	00 
 5cb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 5d2:	e8 06 04 00 00       	call   9dd <printf>

  exit();
 5d7:	e8 54 02 00 00       	call   830 <exit>

000005dc <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 5dc:	55                   	push   %ebp
 5dd:	89 e5                	mov    %esp,%ebp
 5df:	57                   	push   %edi
 5e0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 5e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
 5e4:	8b 55 10             	mov    0x10(%ebp),%edx
 5e7:	8b 45 0c             	mov    0xc(%ebp),%eax
 5ea:	89 cb                	mov    %ecx,%ebx
 5ec:	89 df                	mov    %ebx,%edi
 5ee:	89 d1                	mov    %edx,%ecx
 5f0:	fc                   	cld    
 5f1:	f3 aa                	rep stos %al,%es:(%edi)
 5f3:	89 ca                	mov    %ecx,%edx
 5f5:	89 fb                	mov    %edi,%ebx
 5f7:	89 5d 08             	mov    %ebx,0x8(%ebp)
 5fa:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 5fd:	5b                   	pop    %ebx
 5fe:	5f                   	pop    %edi
 5ff:	5d                   	pop    %ebp
 600:	c3                   	ret    

00000601 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 601:	55                   	push   %ebp
 602:	89 e5                	mov    %esp,%ebp
 604:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 607:	8b 45 08             	mov    0x8(%ebp),%eax
 60a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 60d:	90                   	nop
 60e:	8b 45 08             	mov    0x8(%ebp),%eax
 611:	8d 50 01             	lea    0x1(%eax),%edx
 614:	89 55 08             	mov    %edx,0x8(%ebp)
 617:	8b 55 0c             	mov    0xc(%ebp),%edx
 61a:	8d 4a 01             	lea    0x1(%edx),%ecx
 61d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 620:	8a 12                	mov    (%edx),%dl
 622:	88 10                	mov    %dl,(%eax)
 624:	8a 00                	mov    (%eax),%al
 626:	84 c0                	test   %al,%al
 628:	75 e4                	jne    60e <strcpy+0xd>
    ;
  return os;
 62a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 62d:	c9                   	leave  
 62e:	c3                   	ret    

0000062f <strcmp>:

int
strcmp(const char *p, const char *q)
{
 62f:	55                   	push   %ebp
 630:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 632:	eb 06                	jmp    63a <strcmp+0xb>
    p++, q++;
 634:	ff 45 08             	incl   0x8(%ebp)
 637:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 63a:	8b 45 08             	mov    0x8(%ebp),%eax
 63d:	8a 00                	mov    (%eax),%al
 63f:	84 c0                	test   %al,%al
 641:	74 0e                	je     651 <strcmp+0x22>
 643:	8b 45 08             	mov    0x8(%ebp),%eax
 646:	8a 10                	mov    (%eax),%dl
 648:	8b 45 0c             	mov    0xc(%ebp),%eax
 64b:	8a 00                	mov    (%eax),%al
 64d:	38 c2                	cmp    %al,%dl
 64f:	74 e3                	je     634 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 651:	8b 45 08             	mov    0x8(%ebp),%eax
 654:	8a 00                	mov    (%eax),%al
 656:	0f b6 d0             	movzbl %al,%edx
 659:	8b 45 0c             	mov    0xc(%ebp),%eax
 65c:	8a 00                	mov    (%eax),%al
 65e:	0f b6 c0             	movzbl %al,%eax
 661:	29 c2                	sub    %eax,%edx
 663:	89 d0                	mov    %edx,%eax
}
 665:	5d                   	pop    %ebp
 666:	c3                   	ret    

00000667 <strlen>:

uint
strlen(char *s)
{
 667:	55                   	push   %ebp
 668:	89 e5                	mov    %esp,%ebp
 66a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 66d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 674:	eb 03                	jmp    679 <strlen+0x12>
 676:	ff 45 fc             	incl   -0x4(%ebp)
 679:	8b 55 fc             	mov    -0x4(%ebp),%edx
 67c:	8b 45 08             	mov    0x8(%ebp),%eax
 67f:	01 d0                	add    %edx,%eax
 681:	8a 00                	mov    (%eax),%al
 683:	84 c0                	test   %al,%al
 685:	75 ef                	jne    676 <strlen+0xf>
    ;
  return n;
 687:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 68a:	c9                   	leave  
 68b:	c3                   	ret    

0000068c <memset>:

void*
memset(void *dst, int c, uint n)
{
 68c:	55                   	push   %ebp
 68d:	89 e5                	mov    %esp,%ebp
 68f:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 692:	8b 45 10             	mov    0x10(%ebp),%eax
 695:	89 44 24 08          	mov    %eax,0x8(%esp)
 699:	8b 45 0c             	mov    0xc(%ebp),%eax
 69c:	89 44 24 04          	mov    %eax,0x4(%esp)
 6a0:	8b 45 08             	mov    0x8(%ebp),%eax
 6a3:	89 04 24             	mov    %eax,(%esp)
 6a6:	e8 31 ff ff ff       	call   5dc <stosb>
  return dst;
 6ab:	8b 45 08             	mov    0x8(%ebp),%eax
}
 6ae:	c9                   	leave  
 6af:	c3                   	ret    

000006b0 <strchr>:

char*
strchr(const char *s, char c)
{
 6b0:	55                   	push   %ebp
 6b1:	89 e5                	mov    %esp,%ebp
 6b3:	83 ec 04             	sub    $0x4,%esp
 6b6:	8b 45 0c             	mov    0xc(%ebp),%eax
 6b9:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 6bc:	eb 12                	jmp    6d0 <strchr+0x20>
    if(*s == c)
 6be:	8b 45 08             	mov    0x8(%ebp),%eax
 6c1:	8a 00                	mov    (%eax),%al
 6c3:	3a 45 fc             	cmp    -0x4(%ebp),%al
 6c6:	75 05                	jne    6cd <strchr+0x1d>
      return (char*)s;
 6c8:	8b 45 08             	mov    0x8(%ebp),%eax
 6cb:	eb 11                	jmp    6de <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 6cd:	ff 45 08             	incl   0x8(%ebp)
 6d0:	8b 45 08             	mov    0x8(%ebp),%eax
 6d3:	8a 00                	mov    (%eax),%al
 6d5:	84 c0                	test   %al,%al
 6d7:	75 e5                	jne    6be <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 6d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
 6de:	c9                   	leave  
 6df:	c3                   	ret    

000006e0 <gets>:

char*
gets(char *buf, int max)
{
 6e0:	55                   	push   %ebp
 6e1:	89 e5                	mov    %esp,%ebp
 6e3:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 6e6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 6ed:	eb 49                	jmp    738 <gets+0x58>
    cc = read(0, &c, 1);
 6ef:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 6f6:	00 
 6f7:	8d 45 ef             	lea    -0x11(%ebp),%eax
 6fa:	89 44 24 04          	mov    %eax,0x4(%esp)
 6fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 705:	e8 3e 01 00 00       	call   848 <read>
 70a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 70d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 711:	7f 02                	jg     715 <gets+0x35>
      break;
 713:	eb 2c                	jmp    741 <gets+0x61>
    buf[i++] = c;
 715:	8b 45 f4             	mov    -0xc(%ebp),%eax
 718:	8d 50 01             	lea    0x1(%eax),%edx
 71b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 71e:	89 c2                	mov    %eax,%edx
 720:	8b 45 08             	mov    0x8(%ebp),%eax
 723:	01 c2                	add    %eax,%edx
 725:	8a 45 ef             	mov    -0x11(%ebp),%al
 728:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 72a:	8a 45 ef             	mov    -0x11(%ebp),%al
 72d:	3c 0a                	cmp    $0xa,%al
 72f:	74 10                	je     741 <gets+0x61>
 731:	8a 45 ef             	mov    -0x11(%ebp),%al
 734:	3c 0d                	cmp    $0xd,%al
 736:	74 09                	je     741 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 738:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73b:	40                   	inc    %eax
 73c:	3b 45 0c             	cmp    0xc(%ebp),%eax
 73f:	7c ae                	jl     6ef <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 741:	8b 55 f4             	mov    -0xc(%ebp),%edx
 744:	8b 45 08             	mov    0x8(%ebp),%eax
 747:	01 d0                	add    %edx,%eax
 749:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 74c:	8b 45 08             	mov    0x8(%ebp),%eax
}
 74f:	c9                   	leave  
 750:	c3                   	ret    

00000751 <stat>:

int
stat(char *n, struct stat *st)
{
 751:	55                   	push   %ebp
 752:	89 e5                	mov    %esp,%ebp
 754:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 757:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 75e:	00 
 75f:	8b 45 08             	mov    0x8(%ebp),%eax
 762:	89 04 24             	mov    %eax,(%esp)
 765:	e8 06 01 00 00       	call   870 <open>
 76a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 76d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 771:	79 07                	jns    77a <stat+0x29>
    return -1;
 773:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 778:	eb 23                	jmp    79d <stat+0x4c>
  r = fstat(fd, st);
 77a:	8b 45 0c             	mov    0xc(%ebp),%eax
 77d:	89 44 24 04          	mov    %eax,0x4(%esp)
 781:	8b 45 f4             	mov    -0xc(%ebp),%eax
 784:	89 04 24             	mov    %eax,(%esp)
 787:	e8 fc 00 00 00       	call   888 <fstat>
 78c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 78f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 792:	89 04 24             	mov    %eax,(%esp)
 795:	e8 be 00 00 00       	call   858 <close>
  return r;
 79a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 79d:	c9                   	leave  
 79e:	c3                   	ret    

0000079f <atoi>:

int
atoi(const char *s)
{
 79f:	55                   	push   %ebp
 7a0:	89 e5                	mov    %esp,%ebp
 7a2:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 7a5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 7ac:	eb 24                	jmp    7d2 <atoi+0x33>
    n = n*10 + *s++ - '0';
 7ae:	8b 55 fc             	mov    -0x4(%ebp),%edx
 7b1:	89 d0                	mov    %edx,%eax
 7b3:	c1 e0 02             	shl    $0x2,%eax
 7b6:	01 d0                	add    %edx,%eax
 7b8:	01 c0                	add    %eax,%eax
 7ba:	89 c1                	mov    %eax,%ecx
 7bc:	8b 45 08             	mov    0x8(%ebp),%eax
 7bf:	8d 50 01             	lea    0x1(%eax),%edx
 7c2:	89 55 08             	mov    %edx,0x8(%ebp)
 7c5:	8a 00                	mov    (%eax),%al
 7c7:	0f be c0             	movsbl %al,%eax
 7ca:	01 c8                	add    %ecx,%eax
 7cc:	83 e8 30             	sub    $0x30,%eax
 7cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 7d2:	8b 45 08             	mov    0x8(%ebp),%eax
 7d5:	8a 00                	mov    (%eax),%al
 7d7:	3c 2f                	cmp    $0x2f,%al
 7d9:	7e 09                	jle    7e4 <atoi+0x45>
 7db:	8b 45 08             	mov    0x8(%ebp),%eax
 7de:	8a 00                	mov    (%eax),%al
 7e0:	3c 39                	cmp    $0x39,%al
 7e2:	7e ca                	jle    7ae <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 7e4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 7e7:	c9                   	leave  
 7e8:	c3                   	ret    

000007e9 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 7e9:	55                   	push   %ebp
 7ea:	89 e5                	mov    %esp,%ebp
 7ec:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 7ef:	8b 45 08             	mov    0x8(%ebp),%eax
 7f2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 7f5:	8b 45 0c             	mov    0xc(%ebp),%eax
 7f8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 7fb:	eb 16                	jmp    813 <memmove+0x2a>
    *dst++ = *src++;
 7fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 800:	8d 50 01             	lea    0x1(%eax),%edx
 803:	89 55 fc             	mov    %edx,-0x4(%ebp)
 806:	8b 55 f8             	mov    -0x8(%ebp),%edx
 809:	8d 4a 01             	lea    0x1(%edx),%ecx
 80c:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 80f:	8a 12                	mov    (%edx),%dl
 811:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 813:	8b 45 10             	mov    0x10(%ebp),%eax
 816:	8d 50 ff             	lea    -0x1(%eax),%edx
 819:	89 55 10             	mov    %edx,0x10(%ebp)
 81c:	85 c0                	test   %eax,%eax
 81e:	7f dd                	jg     7fd <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 820:	8b 45 08             	mov    0x8(%ebp),%eax
}
 823:	c9                   	leave  
 824:	c3                   	ret    
 825:	90                   	nop
 826:	90                   	nop
 827:	90                   	nop

00000828 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 828:	b8 01 00 00 00       	mov    $0x1,%eax
 82d:	cd 40                	int    $0x40
 82f:	c3                   	ret    

00000830 <exit>:
SYSCALL(exit)
 830:	b8 02 00 00 00       	mov    $0x2,%eax
 835:	cd 40                	int    $0x40
 837:	c3                   	ret    

00000838 <wait>:
SYSCALL(wait)
 838:	b8 03 00 00 00       	mov    $0x3,%eax
 83d:	cd 40                	int    $0x40
 83f:	c3                   	ret    

00000840 <pipe>:
SYSCALL(pipe)
 840:	b8 04 00 00 00       	mov    $0x4,%eax
 845:	cd 40                	int    $0x40
 847:	c3                   	ret    

00000848 <read>:
SYSCALL(read)
 848:	b8 05 00 00 00       	mov    $0x5,%eax
 84d:	cd 40                	int    $0x40
 84f:	c3                   	ret    

00000850 <write>:
SYSCALL(write)
 850:	b8 10 00 00 00       	mov    $0x10,%eax
 855:	cd 40                	int    $0x40
 857:	c3                   	ret    

00000858 <close>:
SYSCALL(close)
 858:	b8 15 00 00 00       	mov    $0x15,%eax
 85d:	cd 40                	int    $0x40
 85f:	c3                   	ret    

00000860 <kill>:
SYSCALL(kill)
 860:	b8 06 00 00 00       	mov    $0x6,%eax
 865:	cd 40                	int    $0x40
 867:	c3                   	ret    

00000868 <exec>:
SYSCALL(exec)
 868:	b8 07 00 00 00       	mov    $0x7,%eax
 86d:	cd 40                	int    $0x40
 86f:	c3                   	ret    

00000870 <open>:
SYSCALL(open)
 870:	b8 0f 00 00 00       	mov    $0xf,%eax
 875:	cd 40                	int    $0x40
 877:	c3                   	ret    

00000878 <mknod>:
SYSCALL(mknod)
 878:	b8 11 00 00 00       	mov    $0x11,%eax
 87d:	cd 40                	int    $0x40
 87f:	c3                   	ret    

00000880 <unlink>:
SYSCALL(unlink)
 880:	b8 12 00 00 00       	mov    $0x12,%eax
 885:	cd 40                	int    $0x40
 887:	c3                   	ret    

00000888 <fstat>:
SYSCALL(fstat)
 888:	b8 08 00 00 00       	mov    $0x8,%eax
 88d:	cd 40                	int    $0x40
 88f:	c3                   	ret    

00000890 <link>:
SYSCALL(link)
 890:	b8 13 00 00 00       	mov    $0x13,%eax
 895:	cd 40                	int    $0x40
 897:	c3                   	ret    

00000898 <mkdir>:
SYSCALL(mkdir)
 898:	b8 14 00 00 00       	mov    $0x14,%eax
 89d:	cd 40                	int    $0x40
 89f:	c3                   	ret    

000008a0 <chdir>:
SYSCALL(chdir)
 8a0:	b8 09 00 00 00       	mov    $0x9,%eax
 8a5:	cd 40                	int    $0x40
 8a7:	c3                   	ret    

000008a8 <dup>:
SYSCALL(dup)
 8a8:	b8 0a 00 00 00       	mov    $0xa,%eax
 8ad:	cd 40                	int    $0x40
 8af:	c3                   	ret    

000008b0 <getpid>:
SYSCALL(getpid)
 8b0:	b8 0b 00 00 00       	mov    $0xb,%eax
 8b5:	cd 40                	int    $0x40
 8b7:	c3                   	ret    

000008b8 <sbrk>:
SYSCALL(sbrk)
 8b8:	b8 0c 00 00 00       	mov    $0xc,%eax
 8bd:	cd 40                	int    $0x40
 8bf:	c3                   	ret    

000008c0 <sleep>:
SYSCALL(sleep)
 8c0:	b8 0d 00 00 00       	mov    $0xd,%eax
 8c5:	cd 40                	int    $0x40
 8c7:	c3                   	ret    

000008c8 <uptime>:
SYSCALL(uptime)
 8c8:	b8 0e 00 00 00       	mov    $0xe,%eax
 8cd:	cd 40                	int    $0x40
 8cf:	c3                   	ret    

000008d0 <getticks>:
SYSCALL(getticks)
 8d0:	b8 16 00 00 00       	mov    $0x16,%eax
 8d5:	cd 40                	int    $0x40
 8d7:	c3                   	ret    

000008d8 <ccreate>:
SYSCALL(ccreate)
 8d8:	b8 17 00 00 00       	mov    $0x17,%eax
 8dd:	cd 40                	int    $0x40
 8df:	c3                   	ret    

000008e0 <cstart>:
SYSCALL(cstart)
 8e0:	b8 19 00 00 00       	mov    $0x19,%eax
 8e5:	cd 40                	int    $0x40
 8e7:	c3                   	ret    

000008e8 <cstop>:
SYSCALL(cstop)
 8e8:	b8 18 00 00 00       	mov    $0x18,%eax
 8ed:	cd 40                	int    $0x40
 8ef:	c3                   	ret    

000008f0 <cpause>:
SYSCALL(cpause)
 8f0:	b8 1b 00 00 00       	mov    $0x1b,%eax
 8f5:	cd 40                	int    $0x40
 8f7:	c3                   	ret    

000008f8 <cinfo>:
SYSCALL(cinfo)
 8f8:	b8 1a 00 00 00       	mov    $0x1a,%eax
 8fd:	cd 40                	int    $0x40
 8ff:	c3                   	ret    

00000900 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 900:	55                   	push   %ebp
 901:	89 e5                	mov    %esp,%ebp
 903:	83 ec 18             	sub    $0x18,%esp
 906:	8b 45 0c             	mov    0xc(%ebp),%eax
 909:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 90c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 913:	00 
 914:	8d 45 f4             	lea    -0xc(%ebp),%eax
 917:	89 44 24 04          	mov    %eax,0x4(%esp)
 91b:	8b 45 08             	mov    0x8(%ebp),%eax
 91e:	89 04 24             	mov    %eax,(%esp)
 921:	e8 2a ff ff ff       	call   850 <write>
}
 926:	c9                   	leave  
 927:	c3                   	ret    

00000928 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 928:	55                   	push   %ebp
 929:	89 e5                	mov    %esp,%ebp
 92b:	56                   	push   %esi
 92c:	53                   	push   %ebx
 92d:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 930:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 937:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 93b:	74 17                	je     954 <printint+0x2c>
 93d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 941:	79 11                	jns    954 <printint+0x2c>
    neg = 1;
 943:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 94a:	8b 45 0c             	mov    0xc(%ebp),%eax
 94d:	f7 d8                	neg    %eax
 94f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 952:	eb 06                	jmp    95a <printint+0x32>
  } else {
    x = xx;
 954:	8b 45 0c             	mov    0xc(%ebp),%eax
 957:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 95a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 961:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 964:	8d 41 01             	lea    0x1(%ecx),%eax
 967:	89 45 f4             	mov    %eax,-0xc(%ebp)
 96a:	8b 5d 10             	mov    0x10(%ebp),%ebx
 96d:	8b 45 ec             	mov    -0x14(%ebp),%eax
 970:	ba 00 00 00 00       	mov    $0x0,%edx
 975:	f7 f3                	div    %ebx
 977:	89 d0                	mov    %edx,%eax
 979:	8a 80 6c 12 00 00    	mov    0x126c(%eax),%al
 97f:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 983:	8b 75 10             	mov    0x10(%ebp),%esi
 986:	8b 45 ec             	mov    -0x14(%ebp),%eax
 989:	ba 00 00 00 00       	mov    $0x0,%edx
 98e:	f7 f6                	div    %esi
 990:	89 45 ec             	mov    %eax,-0x14(%ebp)
 993:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 997:	75 c8                	jne    961 <printint+0x39>
  if(neg)
 999:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 99d:	74 10                	je     9af <printint+0x87>
    buf[i++] = '-';
 99f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9a2:	8d 50 01             	lea    0x1(%eax),%edx
 9a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
 9a8:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 9ad:	eb 1e                	jmp    9cd <printint+0xa5>
 9af:	eb 1c                	jmp    9cd <printint+0xa5>
    putc(fd, buf[i]);
 9b1:	8d 55 dc             	lea    -0x24(%ebp),%edx
 9b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9b7:	01 d0                	add    %edx,%eax
 9b9:	8a 00                	mov    (%eax),%al
 9bb:	0f be c0             	movsbl %al,%eax
 9be:	89 44 24 04          	mov    %eax,0x4(%esp)
 9c2:	8b 45 08             	mov    0x8(%ebp),%eax
 9c5:	89 04 24             	mov    %eax,(%esp)
 9c8:	e8 33 ff ff ff       	call   900 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 9cd:	ff 4d f4             	decl   -0xc(%ebp)
 9d0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9d4:	79 db                	jns    9b1 <printint+0x89>
    putc(fd, buf[i]);
}
 9d6:	83 c4 30             	add    $0x30,%esp
 9d9:	5b                   	pop    %ebx
 9da:	5e                   	pop    %esi
 9db:	5d                   	pop    %ebp
 9dc:	c3                   	ret    

000009dd <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 9dd:	55                   	push   %ebp
 9de:	89 e5                	mov    %esp,%ebp
 9e0:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 9e3:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 9ea:	8d 45 0c             	lea    0xc(%ebp),%eax
 9ed:	83 c0 04             	add    $0x4,%eax
 9f0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 9f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 9fa:	e9 77 01 00 00       	jmp    b76 <printf+0x199>
    c = fmt[i] & 0xff;
 9ff:	8b 55 0c             	mov    0xc(%ebp),%edx
 a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a05:	01 d0                	add    %edx,%eax
 a07:	8a 00                	mov    (%eax),%al
 a09:	0f be c0             	movsbl %al,%eax
 a0c:	25 ff 00 00 00       	and    $0xff,%eax
 a11:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 a14:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 a18:	75 2c                	jne    a46 <printf+0x69>
      if(c == '%'){
 a1a:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 a1e:	75 0c                	jne    a2c <printf+0x4f>
        state = '%';
 a20:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 a27:	e9 47 01 00 00       	jmp    b73 <printf+0x196>
      } else {
        putc(fd, c);
 a2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 a2f:	0f be c0             	movsbl %al,%eax
 a32:	89 44 24 04          	mov    %eax,0x4(%esp)
 a36:	8b 45 08             	mov    0x8(%ebp),%eax
 a39:	89 04 24             	mov    %eax,(%esp)
 a3c:	e8 bf fe ff ff       	call   900 <putc>
 a41:	e9 2d 01 00 00       	jmp    b73 <printf+0x196>
      }
    } else if(state == '%'){
 a46:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 a4a:	0f 85 23 01 00 00    	jne    b73 <printf+0x196>
      if(c == 'd'){
 a50:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 a54:	75 2d                	jne    a83 <printf+0xa6>
        printint(fd, *ap, 10, 1);
 a56:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a59:	8b 00                	mov    (%eax),%eax
 a5b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 a62:	00 
 a63:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 a6a:	00 
 a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
 a6f:	8b 45 08             	mov    0x8(%ebp),%eax
 a72:	89 04 24             	mov    %eax,(%esp)
 a75:	e8 ae fe ff ff       	call   928 <printint>
        ap++;
 a7a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 a7e:	e9 e9 00 00 00       	jmp    b6c <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 a83:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 a87:	74 06                	je     a8f <printf+0xb2>
 a89:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 a8d:	75 2d                	jne    abc <printf+0xdf>
        printint(fd, *ap, 16, 0);
 a8f:	8b 45 e8             	mov    -0x18(%ebp),%eax
 a92:	8b 00                	mov    (%eax),%eax
 a94:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 a9b:	00 
 a9c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 aa3:	00 
 aa4:	89 44 24 04          	mov    %eax,0x4(%esp)
 aa8:	8b 45 08             	mov    0x8(%ebp),%eax
 aab:	89 04 24             	mov    %eax,(%esp)
 aae:	e8 75 fe ff ff       	call   928 <printint>
        ap++;
 ab3:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 ab7:	e9 b0 00 00 00       	jmp    b6c <printf+0x18f>
      } else if(c == 's'){
 abc:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 ac0:	75 42                	jne    b04 <printf+0x127>
        s = (char*)*ap;
 ac2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 ac5:	8b 00                	mov    (%eax),%eax
 ac7:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 aca:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 ace:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 ad2:	75 09                	jne    add <printf+0x100>
          s = "(null)";
 ad4:	c7 45 f4 f5 0e 00 00 	movl   $0xef5,-0xc(%ebp)
        while(*s != 0){
 adb:	eb 1c                	jmp    af9 <printf+0x11c>
 add:	eb 1a                	jmp    af9 <printf+0x11c>
          putc(fd, *s);
 adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ae2:	8a 00                	mov    (%eax),%al
 ae4:	0f be c0             	movsbl %al,%eax
 ae7:	89 44 24 04          	mov    %eax,0x4(%esp)
 aeb:	8b 45 08             	mov    0x8(%ebp),%eax
 aee:	89 04 24             	mov    %eax,(%esp)
 af1:	e8 0a fe ff ff       	call   900 <putc>
          s++;
 af6:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 afc:	8a 00                	mov    (%eax),%al
 afe:	84 c0                	test   %al,%al
 b00:	75 dd                	jne    adf <printf+0x102>
 b02:	eb 68                	jmp    b6c <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 b04:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 b08:	75 1d                	jne    b27 <printf+0x14a>
        putc(fd, *ap);
 b0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 b0d:	8b 00                	mov    (%eax),%eax
 b0f:	0f be c0             	movsbl %al,%eax
 b12:	89 44 24 04          	mov    %eax,0x4(%esp)
 b16:	8b 45 08             	mov    0x8(%ebp),%eax
 b19:	89 04 24             	mov    %eax,(%esp)
 b1c:	e8 df fd ff ff       	call   900 <putc>
        ap++;
 b21:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 b25:	eb 45                	jmp    b6c <printf+0x18f>
      } else if(c == '%'){
 b27:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 b2b:	75 17                	jne    b44 <printf+0x167>
        putc(fd, c);
 b2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b30:	0f be c0             	movsbl %al,%eax
 b33:	89 44 24 04          	mov    %eax,0x4(%esp)
 b37:	8b 45 08             	mov    0x8(%ebp),%eax
 b3a:	89 04 24             	mov    %eax,(%esp)
 b3d:	e8 be fd ff ff       	call   900 <putc>
 b42:	eb 28                	jmp    b6c <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 b44:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 b4b:	00 
 b4c:	8b 45 08             	mov    0x8(%ebp),%eax
 b4f:	89 04 24             	mov    %eax,(%esp)
 b52:	e8 a9 fd ff ff       	call   900 <putc>
        putc(fd, c);
 b57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 b5a:	0f be c0             	movsbl %al,%eax
 b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
 b61:	8b 45 08             	mov    0x8(%ebp),%eax
 b64:	89 04 24             	mov    %eax,(%esp)
 b67:	e8 94 fd ff ff       	call   900 <putc>
      }
      state = 0;
 b6c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 b73:	ff 45 f0             	incl   -0x10(%ebp)
 b76:	8b 55 0c             	mov    0xc(%ebp),%edx
 b79:	8b 45 f0             	mov    -0x10(%ebp),%eax
 b7c:	01 d0                	add    %edx,%eax
 b7e:	8a 00                	mov    (%eax),%al
 b80:	84 c0                	test   %al,%al
 b82:	0f 85 77 fe ff ff    	jne    9ff <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 b88:	c9                   	leave  
 b89:	c3                   	ret    
 b8a:	90                   	nop
 b8b:	90                   	nop

00000b8c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b8c:	55                   	push   %ebp
 b8d:	89 e5                	mov    %esp,%ebp
 b8f:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b92:	8b 45 08             	mov    0x8(%ebp),%eax
 b95:	83 e8 08             	sub    $0x8,%eax
 b98:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b9b:	a1 88 12 00 00       	mov    0x1288,%eax
 ba0:	89 45 fc             	mov    %eax,-0x4(%ebp)
 ba3:	eb 24                	jmp    bc9 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 ba5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 ba8:	8b 00                	mov    (%eax),%eax
 baa:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 bad:	77 12                	ja     bc1 <free+0x35>
 baf:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bb2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 bb5:	77 24                	ja     bdb <free+0x4f>
 bb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bba:	8b 00                	mov    (%eax),%eax
 bbc:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 bbf:	77 1a                	ja     bdb <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 bc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bc4:	8b 00                	mov    (%eax),%eax
 bc6:	89 45 fc             	mov    %eax,-0x4(%ebp)
 bc9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bcc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 bcf:	76 d4                	jbe    ba5 <free+0x19>
 bd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bd4:	8b 00                	mov    (%eax),%eax
 bd6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 bd9:	76 ca                	jbe    ba5 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 bdb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bde:	8b 40 04             	mov    0x4(%eax),%eax
 be1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 be8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 beb:	01 c2                	add    %eax,%edx
 bed:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bf0:	8b 00                	mov    (%eax),%eax
 bf2:	39 c2                	cmp    %eax,%edx
 bf4:	75 24                	jne    c1a <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 bf6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 bf9:	8b 50 04             	mov    0x4(%eax),%edx
 bfc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 bff:	8b 00                	mov    (%eax),%eax
 c01:	8b 40 04             	mov    0x4(%eax),%eax
 c04:	01 c2                	add    %eax,%edx
 c06:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c09:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 c0c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c0f:	8b 00                	mov    (%eax),%eax
 c11:	8b 10                	mov    (%eax),%edx
 c13:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c16:	89 10                	mov    %edx,(%eax)
 c18:	eb 0a                	jmp    c24 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 c1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c1d:	8b 10                	mov    (%eax),%edx
 c1f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c22:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 c24:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c27:	8b 40 04             	mov    0x4(%eax),%eax
 c2a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 c31:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c34:	01 d0                	add    %edx,%eax
 c36:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 c39:	75 20                	jne    c5b <free+0xcf>
    p->s.size += bp->s.size;
 c3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c3e:	8b 50 04             	mov    0x4(%eax),%edx
 c41:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c44:	8b 40 04             	mov    0x4(%eax),%eax
 c47:	01 c2                	add    %eax,%edx
 c49:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c4c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 c4f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 c52:	8b 10                	mov    (%eax),%edx
 c54:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c57:	89 10                	mov    %edx,(%eax)
 c59:	eb 08                	jmp    c63 <free+0xd7>
  } else
    p->s.ptr = bp;
 c5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c5e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 c61:	89 10                	mov    %edx,(%eax)
  freep = p;
 c63:	8b 45 fc             	mov    -0x4(%ebp),%eax
 c66:	a3 88 12 00 00       	mov    %eax,0x1288
}
 c6b:	c9                   	leave  
 c6c:	c3                   	ret    

00000c6d <morecore>:

static Header*
morecore(uint nu)
{
 c6d:	55                   	push   %ebp
 c6e:	89 e5                	mov    %esp,%ebp
 c70:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 c73:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 c7a:	77 07                	ja     c83 <morecore+0x16>
    nu = 4096;
 c7c:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 c83:	8b 45 08             	mov    0x8(%ebp),%eax
 c86:	c1 e0 03             	shl    $0x3,%eax
 c89:	89 04 24             	mov    %eax,(%esp)
 c8c:	e8 27 fc ff ff       	call   8b8 <sbrk>
 c91:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 c94:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 c98:	75 07                	jne    ca1 <morecore+0x34>
    return 0;
 c9a:	b8 00 00 00 00       	mov    $0x0,%eax
 c9f:	eb 22                	jmp    cc3 <morecore+0x56>
  hp = (Header*)p;
 ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ca4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 ca7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 caa:	8b 55 08             	mov    0x8(%ebp),%edx
 cad:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cb3:	83 c0 08             	add    $0x8,%eax
 cb6:	89 04 24             	mov    %eax,(%esp)
 cb9:	e8 ce fe ff ff       	call   b8c <free>
  return freep;
 cbe:	a1 88 12 00 00       	mov    0x1288,%eax
}
 cc3:	c9                   	leave  
 cc4:	c3                   	ret    

00000cc5 <malloc>:

void*
malloc(uint nbytes)
{
 cc5:	55                   	push   %ebp
 cc6:	89 e5                	mov    %esp,%ebp
 cc8:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 ccb:	8b 45 08             	mov    0x8(%ebp),%eax
 cce:	83 c0 07             	add    $0x7,%eax
 cd1:	c1 e8 03             	shr    $0x3,%eax
 cd4:	40                   	inc    %eax
 cd5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 cd8:	a1 88 12 00 00       	mov    0x1288,%eax
 cdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 ce0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 ce4:	75 23                	jne    d09 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 ce6:	c7 45 f0 80 12 00 00 	movl   $0x1280,-0x10(%ebp)
 ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
 cf0:	a3 88 12 00 00       	mov    %eax,0x1288
 cf5:	a1 88 12 00 00       	mov    0x1288,%eax
 cfa:	a3 80 12 00 00       	mov    %eax,0x1280
    base.s.size = 0;
 cff:	c7 05 84 12 00 00 00 	movl   $0x0,0x1284
 d06:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d09:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d0c:	8b 00                	mov    (%eax),%eax
 d0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d14:	8b 40 04             	mov    0x4(%eax),%eax
 d17:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 d1a:	72 4d                	jb     d69 <malloc+0xa4>
      if(p->s.size == nunits)
 d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d1f:	8b 40 04             	mov    0x4(%eax),%eax
 d22:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 d25:	75 0c                	jne    d33 <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 d27:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d2a:	8b 10                	mov    (%eax),%edx
 d2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d2f:	89 10                	mov    %edx,(%eax)
 d31:	eb 26                	jmp    d59 <malloc+0x94>
      else {
        p->s.size -= nunits;
 d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d36:	8b 40 04             	mov    0x4(%eax),%eax
 d39:	2b 45 ec             	sub    -0x14(%ebp),%eax
 d3c:	89 c2                	mov    %eax,%edx
 d3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d41:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d47:	8b 40 04             	mov    0x4(%eax),%eax
 d4a:	c1 e0 03             	shl    $0x3,%eax
 d4d:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 d50:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d53:	8b 55 ec             	mov    -0x14(%ebp),%edx
 d56:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
 d5c:	a3 88 12 00 00       	mov    %eax,0x1288
      return (void*)(p + 1);
 d61:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d64:	83 c0 08             	add    $0x8,%eax
 d67:	eb 38                	jmp    da1 <malloc+0xdc>
    }
    if(p == freep)
 d69:	a1 88 12 00 00       	mov    0x1288,%eax
 d6e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 d71:	75 1b                	jne    d8e <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 d73:	8b 45 ec             	mov    -0x14(%ebp),%eax
 d76:	89 04 24             	mov    %eax,(%esp)
 d79:	e8 ef fe ff ff       	call   c6d <morecore>
 d7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
 d81:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 d85:	75 07                	jne    d8e <malloc+0xc9>
        return 0;
 d87:	b8 00 00 00 00       	mov    $0x0,%eax
 d8c:	eb 13                	jmp    da1 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d91:	89 45 f0             	mov    %eax,-0x10(%ebp)
 d94:	8b 45 f4             	mov    -0xc(%ebp),%eax
 d97:	8b 00                	mov    (%eax),%eax
 d99:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 d9c:	e9 70 ff ff ff       	jmp    d11 <malloc+0x4c>
}
 da1:	c9                   	leave  
 da2:	c3                   	ret    
