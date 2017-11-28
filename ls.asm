
_ls:     file format elf32-i386


Disassembly of section .text:

00000000 <fmtname>:
#include "user.h"
#include "fs.h"

char*
fmtname(char *path)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	53                   	push   %ebx
   4:	83 ec 24             	sub    $0x24,%esp
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   7:	8b 45 08             	mov    0x8(%ebp),%eax
   a:	89 04 24             	mov    %eax,(%esp)
   d:	e8 cd 03 00 00       	call   3df <strlen>
  12:	8b 55 08             	mov    0x8(%ebp),%edx
  15:	01 d0                	add    %edx,%eax
  17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1a:	eb 03                	jmp    1f <fmtname+0x1f>
  1c:	ff 4d f4             	decl   -0xc(%ebp)
  1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  22:	3b 45 08             	cmp    0x8(%ebp),%eax
  25:	72 09                	jb     30 <fmtname+0x30>
  27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  2a:	8a 00                	mov    (%eax),%al
  2c:	3c 2f                	cmp    $0x2f,%al
  2e:	75 ec                	jne    1c <fmtname+0x1c>
    ;
  p++;
  30:	ff 45 f4             	incl   -0xc(%ebp)

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  36:	89 04 24             	mov    %eax,(%esp)
  39:	e8 a1 03 00 00       	call   3df <strlen>
  3e:	83 f8 0d             	cmp    $0xd,%eax
  41:	76 05                	jbe    48 <fmtname+0x48>
    return p;
  43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  46:	eb 5f                	jmp    a7 <fmtname+0xa7>
  memmove(buf, p, strlen(p));
  48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  4b:	89 04 24             	mov    %eax,(%esp)
  4e:	e8 8c 03 00 00       	call   3df <strlen>
  53:	89 44 24 08          	mov    %eax,0x8(%esp)
  57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  5e:	c7 04 24 18 0e 00 00 	movl   $0xe18,(%esp)
  65:	e8 f7 04 00 00       	call   561 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  6d:	89 04 24             	mov    %eax,(%esp)
  70:	e8 6a 03 00 00       	call   3df <strlen>
  75:	ba 0e 00 00 00       	mov    $0xe,%edx
  7a:	89 d3                	mov    %edx,%ebx
  7c:	29 c3                	sub    %eax,%ebx
  7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  81:	89 04 24             	mov    %eax,(%esp)
  84:	e8 56 03 00 00       	call   3df <strlen>
  89:	05 18 0e 00 00       	add    $0xe18,%eax
  8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  92:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  99:	00 
  9a:	89 04 24             	mov    %eax,(%esp)
  9d:	e8 62 03 00 00       	call   404 <memset>
  return buf;
  a2:	b8 18 0e 00 00       	mov    $0xe18,%eax
}
  a7:	83 c4 24             	add    $0x24,%esp
  aa:	5b                   	pop    %ebx
  ab:	5d                   	pop    %ebp
  ac:	c3                   	ret    

000000ad <ls>:

void
ls(char *path)
{
  ad:	55                   	push   %ebp
  ae:	89 e5                	mov    %esp,%ebp
  b0:	57                   	push   %edi
  b1:	56                   	push   %esi
  b2:	53                   	push   %ebx
  b3:	81 ec 5c 02 00 00    	sub    $0x25c,%esp
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
  b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  c0:	00 
  c1:	8b 45 08             	mov    0x8(%ebp),%eax
  c4:	89 04 24             	mov    %eax,(%esp)
  c7:	e8 1c 05 00 00       	call   5e8 <open>
  cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  d3:	79 20                	jns    f5 <ls+0x48>
    printf(2, "ls: cannot open %s\n", path);
  d5:	8b 45 08             	mov    0x8(%ebp),%eax
  d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  dc:	c7 44 24 04 1b 0b 00 	movl   $0xb1b,0x4(%esp)
  e3:	00 
  e4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  eb:	e8 65 06 00 00       	call   755 <printf>
    return;
  f0:	e9 fd 01 00 00       	jmp    2f2 <ls+0x245>
  }

  if(fstat(fd, &st) < 0){
  f5:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
  fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 102:	89 04 24             	mov    %eax,(%esp)
 105:	e8 f6 04 00 00       	call   600 <fstat>
 10a:	85 c0                	test   %eax,%eax
 10c:	79 2b                	jns    139 <ls+0x8c>
    printf(2, "ls: cannot stat %s\n", path);
 10e:	8b 45 08             	mov    0x8(%ebp),%eax
 111:	89 44 24 08          	mov    %eax,0x8(%esp)
 115:	c7 44 24 04 2f 0b 00 	movl   $0xb2f,0x4(%esp)
 11c:	00 
 11d:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
 124:	e8 2c 06 00 00       	call   755 <printf>
    close(fd);
 129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 12c:	89 04 24             	mov    %eax,(%esp)
 12f:	e8 9c 04 00 00       	call   5d0 <close>
    return;
 134:	e9 b9 01 00 00       	jmp    2f2 <ls+0x245>
  }

  switch(st.type){
 139:	8b 85 bc fd ff ff    	mov    -0x244(%ebp),%eax
 13f:	98                   	cwtl   
 140:	83 f8 01             	cmp    $0x1,%eax
 143:	74 52                	je     197 <ls+0xea>
 145:	83 f8 02             	cmp    $0x2,%eax
 148:	0f 85 99 01 00 00    	jne    2e7 <ls+0x23a>
  case T_FILE:
    printf(1, "%s %d %d %d\n", fmtname(path), st.type, st.ino, st.size);
 14e:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 154:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 15a:	8b 85 bc fd ff ff    	mov    -0x244(%ebp),%eax
 160:	0f bf d8             	movswl %ax,%ebx
 163:	8b 45 08             	mov    0x8(%ebp),%eax
 166:	89 04 24             	mov    %eax,(%esp)
 169:	e8 92 fe ff ff       	call   0 <fmtname>
 16e:	89 7c 24 14          	mov    %edi,0x14(%esp)
 172:	89 74 24 10          	mov    %esi,0x10(%esp)
 176:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 17a:	89 44 24 08          	mov    %eax,0x8(%esp)
 17e:	c7 44 24 04 43 0b 00 	movl   $0xb43,0x4(%esp)
 185:	00 
 186:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 18d:	e8 c3 05 00 00       	call   755 <printf>
    break;
 192:	e9 50 01 00 00       	jmp    2e7 <ls+0x23a>

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 197:	8b 45 08             	mov    0x8(%ebp),%eax
 19a:	89 04 24             	mov    %eax,(%esp)
 19d:	e8 3d 02 00 00       	call   3df <strlen>
 1a2:	83 c0 10             	add    $0x10,%eax
 1a5:	3d 00 02 00 00       	cmp    $0x200,%eax
 1aa:	76 19                	jbe    1c5 <ls+0x118>
      printf(1, "ls: path too long\n");
 1ac:	c7 44 24 04 50 0b 00 	movl   $0xb50,0x4(%esp)
 1b3:	00 
 1b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 1bb:	e8 95 05 00 00       	call   755 <printf>
      break;
 1c0:	e9 22 01 00 00       	jmp    2e7 <ls+0x23a>
    }
    strcpy(buf, path);
 1c5:	8b 45 08             	mov    0x8(%ebp),%eax
 1c8:	89 44 24 04          	mov    %eax,0x4(%esp)
 1cc:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1d2:	89 04 24             	mov    %eax,(%esp)
 1d5:	e8 9f 01 00 00       	call   379 <strcpy>
    p = buf+strlen(buf);
 1da:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 1e0:	89 04 24             	mov    %eax,(%esp)
 1e3:	e8 f7 01 00 00       	call   3df <strlen>
 1e8:	8d 95 e0 fd ff ff    	lea    -0x220(%ebp),%edx
 1ee:	01 d0                	add    %edx,%eax
 1f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    *p++ = '/';
 1f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
 1f6:	8d 50 01             	lea    0x1(%eax),%edx
 1f9:	89 55 e0             	mov    %edx,-0x20(%ebp)
 1fc:	c6 00 2f             	movb   $0x2f,(%eax)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1ff:	e9 bc 00 00 00       	jmp    2c0 <ls+0x213>
      if(de.inum == 0)
 204:	8b 85 d0 fd ff ff    	mov    -0x230(%ebp),%eax
 20a:	66 85 c0             	test   %ax,%ax
 20d:	75 05                	jne    214 <ls+0x167>
        continue;
 20f:	e9 ac 00 00 00       	jmp    2c0 <ls+0x213>
      memmove(p, de.name, DIRSIZ);
 214:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
 21b:	00 
 21c:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 222:	83 c0 02             	add    $0x2,%eax
 225:	89 44 24 04          	mov    %eax,0x4(%esp)
 229:	8b 45 e0             	mov    -0x20(%ebp),%eax
 22c:	89 04 24             	mov    %eax,(%esp)
 22f:	e8 2d 03 00 00       	call   561 <memmove>
      p[DIRSIZ] = 0;
 234:	8b 45 e0             	mov    -0x20(%ebp),%eax
 237:	83 c0 0e             	add    $0xe,%eax
 23a:	c6 00 00             	movb   $0x0,(%eax)
      if(stat(buf, &st) < 0){
 23d:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
 243:	89 44 24 04          	mov    %eax,0x4(%esp)
 247:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 24d:	89 04 24             	mov    %eax,(%esp)
 250:	e8 74 02 00 00       	call   4c9 <stat>
 255:	85 c0                	test   %eax,%eax
 257:	79 20                	jns    279 <ls+0x1cc>
        printf(1, "ls: cannot stat %s\n", buf);
 259:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 25f:	89 44 24 08          	mov    %eax,0x8(%esp)
 263:	c7 44 24 04 2f 0b 00 	movl   $0xb2f,0x4(%esp)
 26a:	00 
 26b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 272:	e8 de 04 00 00       	call   755 <printf>
        continue;
 277:	eb 47                	jmp    2c0 <ls+0x213>
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
 279:	8b bd cc fd ff ff    	mov    -0x234(%ebp),%edi
 27f:	8b b5 c4 fd ff ff    	mov    -0x23c(%ebp),%esi
 285:	8b 85 bc fd ff ff    	mov    -0x244(%ebp),%eax
 28b:	0f bf d8             	movswl %ax,%ebx
 28e:	8d 85 e0 fd ff ff    	lea    -0x220(%ebp),%eax
 294:	89 04 24             	mov    %eax,(%esp)
 297:	e8 64 fd ff ff       	call   0 <fmtname>
 29c:	89 7c 24 14          	mov    %edi,0x14(%esp)
 2a0:	89 74 24 10          	mov    %esi,0x10(%esp)
 2a4:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
 2a8:	89 44 24 08          	mov    %eax,0x8(%esp)
 2ac:	c7 44 24 04 43 0b 00 	movl   $0xb43,0x4(%esp)
 2b3:	00 
 2b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
 2bb:	e8 95 04 00 00       	call   755 <printf>
      break;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 2c0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 2c7:	00 
 2c8:	8d 85 d0 fd ff ff    	lea    -0x230(%ebp),%eax
 2ce:	89 44 24 04          	mov    %eax,0x4(%esp)
 2d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2d5:	89 04 24             	mov    %eax,(%esp)
 2d8:	e8 e3 02 00 00       	call   5c0 <read>
 2dd:	83 f8 10             	cmp    $0x10,%eax
 2e0:	0f 84 1e ff ff ff    	je     204 <ls+0x157>
        printf(1, "ls: cannot stat %s\n", buf);
        continue;
      }
      printf(1, "%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
    }
    break;
 2e6:	90                   	nop
  }
  close(fd);
 2e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 2ea:	89 04 24             	mov    %eax,(%esp)
 2ed:	e8 de 02 00 00       	call   5d0 <close>
}
 2f2:	81 c4 5c 02 00 00    	add    $0x25c,%esp
 2f8:	5b                   	pop    %ebx
 2f9:	5e                   	pop    %esi
 2fa:	5f                   	pop    %edi
 2fb:	5d                   	pop    %ebp
 2fc:	c3                   	ret    

000002fd <main>:

int
main(int argc, char *argv[])
{
 2fd:	55                   	push   %ebp
 2fe:	89 e5                	mov    %esp,%ebp
 300:	83 e4 f0             	and    $0xfffffff0,%esp
 303:	83 ec 20             	sub    $0x20,%esp
  int i;

  if(argc < 2){
 306:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 30a:	7f 11                	jg     31d <main+0x20>
    ls(".");
 30c:	c7 04 24 63 0b 00 00 	movl   $0xb63,(%esp)
 313:	e8 95 fd ff ff       	call   ad <ls>
    exit();
 318:	e8 8b 02 00 00       	call   5a8 <exit>
  }
  for(i=1; i<argc; i++)
 31d:	c7 44 24 1c 01 00 00 	movl   $0x1,0x1c(%esp)
 324:	00 
 325:	eb 1e                	jmp    345 <main+0x48>
    ls(argv[i]);
 327:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 32b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
 332:	8b 45 0c             	mov    0xc(%ebp),%eax
 335:	01 d0                	add    %edx,%eax
 337:	8b 00                	mov    (%eax),%eax
 339:	89 04 24             	mov    %eax,(%esp)
 33c:	e8 6c fd ff ff       	call   ad <ls>

  if(argc < 2){
    ls(".");
    exit();
  }
  for(i=1; i<argc; i++)
 341:	ff 44 24 1c          	incl   0x1c(%esp)
 345:	8b 44 24 1c          	mov    0x1c(%esp),%eax
 349:	3b 45 08             	cmp    0x8(%ebp),%eax
 34c:	7c d9                	jl     327 <main+0x2a>
    ls(argv[i]);
  exit();
 34e:	e8 55 02 00 00       	call   5a8 <exit>
 353:	90                   	nop

00000354 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 354:	55                   	push   %ebp
 355:	89 e5                	mov    %esp,%ebp
 357:	57                   	push   %edi
 358:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 359:	8b 4d 08             	mov    0x8(%ebp),%ecx
 35c:	8b 55 10             	mov    0x10(%ebp),%edx
 35f:	8b 45 0c             	mov    0xc(%ebp),%eax
 362:	89 cb                	mov    %ecx,%ebx
 364:	89 df                	mov    %ebx,%edi
 366:	89 d1                	mov    %edx,%ecx
 368:	fc                   	cld    
 369:	f3 aa                	rep stos %al,%es:(%edi)
 36b:	89 ca                	mov    %ecx,%edx
 36d:	89 fb                	mov    %edi,%ebx
 36f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 372:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 375:	5b                   	pop    %ebx
 376:	5f                   	pop    %edi
 377:	5d                   	pop    %ebp
 378:	c3                   	ret    

00000379 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 379:	55                   	push   %ebp
 37a:	89 e5                	mov    %esp,%ebp
 37c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 37f:	8b 45 08             	mov    0x8(%ebp),%eax
 382:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 385:	90                   	nop
 386:	8b 45 08             	mov    0x8(%ebp),%eax
 389:	8d 50 01             	lea    0x1(%eax),%edx
 38c:	89 55 08             	mov    %edx,0x8(%ebp)
 38f:	8b 55 0c             	mov    0xc(%ebp),%edx
 392:	8d 4a 01             	lea    0x1(%edx),%ecx
 395:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 398:	8a 12                	mov    (%edx),%dl
 39a:	88 10                	mov    %dl,(%eax)
 39c:	8a 00                	mov    (%eax),%al
 39e:	84 c0                	test   %al,%al
 3a0:	75 e4                	jne    386 <strcpy+0xd>
    ;
  return os;
 3a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 3a5:	c9                   	leave  
 3a6:	c3                   	ret    

000003a7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 3a7:	55                   	push   %ebp
 3a8:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 3aa:	eb 06                	jmp    3b2 <strcmp+0xb>
    p++, q++;
 3ac:	ff 45 08             	incl   0x8(%ebp)
 3af:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 3b2:	8b 45 08             	mov    0x8(%ebp),%eax
 3b5:	8a 00                	mov    (%eax),%al
 3b7:	84 c0                	test   %al,%al
 3b9:	74 0e                	je     3c9 <strcmp+0x22>
 3bb:	8b 45 08             	mov    0x8(%ebp),%eax
 3be:	8a 10                	mov    (%eax),%dl
 3c0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c3:	8a 00                	mov    (%eax),%al
 3c5:	38 c2                	cmp    %al,%dl
 3c7:	74 e3                	je     3ac <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 3c9:	8b 45 08             	mov    0x8(%ebp),%eax
 3cc:	8a 00                	mov    (%eax),%al
 3ce:	0f b6 d0             	movzbl %al,%edx
 3d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d4:	8a 00                	mov    (%eax),%al
 3d6:	0f b6 c0             	movzbl %al,%eax
 3d9:	29 c2                	sub    %eax,%edx
 3db:	89 d0                	mov    %edx,%eax
}
 3dd:	5d                   	pop    %ebp
 3de:	c3                   	ret    

000003df <strlen>:

uint
strlen(char *s)
{
 3df:	55                   	push   %ebp
 3e0:	89 e5                	mov    %esp,%ebp
 3e2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 3e5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 3ec:	eb 03                	jmp    3f1 <strlen+0x12>
 3ee:	ff 45 fc             	incl   -0x4(%ebp)
 3f1:	8b 55 fc             	mov    -0x4(%ebp),%edx
 3f4:	8b 45 08             	mov    0x8(%ebp),%eax
 3f7:	01 d0                	add    %edx,%eax
 3f9:	8a 00                	mov    (%eax),%al
 3fb:	84 c0                	test   %al,%al
 3fd:	75 ef                	jne    3ee <strlen+0xf>
    ;
  return n;
 3ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 402:	c9                   	leave  
 403:	c3                   	ret    

00000404 <memset>:

void*
memset(void *dst, int c, uint n)
{
 404:	55                   	push   %ebp
 405:	89 e5                	mov    %esp,%ebp
 407:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 40a:	8b 45 10             	mov    0x10(%ebp),%eax
 40d:	89 44 24 08          	mov    %eax,0x8(%esp)
 411:	8b 45 0c             	mov    0xc(%ebp),%eax
 414:	89 44 24 04          	mov    %eax,0x4(%esp)
 418:	8b 45 08             	mov    0x8(%ebp),%eax
 41b:	89 04 24             	mov    %eax,(%esp)
 41e:	e8 31 ff ff ff       	call   354 <stosb>
  return dst;
 423:	8b 45 08             	mov    0x8(%ebp),%eax
}
 426:	c9                   	leave  
 427:	c3                   	ret    

00000428 <strchr>:

char*
strchr(const char *s, char c)
{
 428:	55                   	push   %ebp
 429:	89 e5                	mov    %esp,%ebp
 42b:	83 ec 04             	sub    $0x4,%esp
 42e:	8b 45 0c             	mov    0xc(%ebp),%eax
 431:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 434:	eb 12                	jmp    448 <strchr+0x20>
    if(*s == c)
 436:	8b 45 08             	mov    0x8(%ebp),%eax
 439:	8a 00                	mov    (%eax),%al
 43b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 43e:	75 05                	jne    445 <strchr+0x1d>
      return (char*)s;
 440:	8b 45 08             	mov    0x8(%ebp),%eax
 443:	eb 11                	jmp    456 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 445:	ff 45 08             	incl   0x8(%ebp)
 448:	8b 45 08             	mov    0x8(%ebp),%eax
 44b:	8a 00                	mov    (%eax),%al
 44d:	84 c0                	test   %al,%al
 44f:	75 e5                	jne    436 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 451:	b8 00 00 00 00       	mov    $0x0,%eax
}
 456:	c9                   	leave  
 457:	c3                   	ret    

00000458 <gets>:

char*
gets(char *buf, int max)
{
 458:	55                   	push   %ebp
 459:	89 e5                	mov    %esp,%ebp
 45b:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 45e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 465:	eb 49                	jmp    4b0 <gets+0x58>
    cc = read(0, &c, 1);
 467:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 46e:	00 
 46f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 472:	89 44 24 04          	mov    %eax,0x4(%esp)
 476:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 47d:	e8 3e 01 00 00       	call   5c0 <read>
 482:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 485:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 489:	7f 02                	jg     48d <gets+0x35>
      break;
 48b:	eb 2c                	jmp    4b9 <gets+0x61>
    buf[i++] = c;
 48d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 490:	8d 50 01             	lea    0x1(%eax),%edx
 493:	89 55 f4             	mov    %edx,-0xc(%ebp)
 496:	89 c2                	mov    %eax,%edx
 498:	8b 45 08             	mov    0x8(%ebp),%eax
 49b:	01 c2                	add    %eax,%edx
 49d:	8a 45 ef             	mov    -0x11(%ebp),%al
 4a0:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 4a2:	8a 45 ef             	mov    -0x11(%ebp),%al
 4a5:	3c 0a                	cmp    $0xa,%al
 4a7:	74 10                	je     4b9 <gets+0x61>
 4a9:	8a 45 ef             	mov    -0x11(%ebp),%al
 4ac:	3c 0d                	cmp    $0xd,%al
 4ae:	74 09                	je     4b9 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 4b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4b3:	40                   	inc    %eax
 4b4:	3b 45 0c             	cmp    0xc(%ebp),%eax
 4b7:	7c ae                	jl     467 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 4b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
 4bc:	8b 45 08             	mov    0x8(%ebp),%eax
 4bf:	01 d0                	add    %edx,%eax
 4c1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 4c4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4c7:	c9                   	leave  
 4c8:	c3                   	ret    

000004c9 <stat>:

int
stat(char *n, struct stat *st)
{
 4c9:	55                   	push   %ebp
 4ca:	89 e5                	mov    %esp,%ebp
 4cc:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 4cf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 4d6:	00 
 4d7:	8b 45 08             	mov    0x8(%ebp),%eax
 4da:	89 04 24             	mov    %eax,(%esp)
 4dd:	e8 06 01 00 00       	call   5e8 <open>
 4e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 4e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4e9:	79 07                	jns    4f2 <stat+0x29>
    return -1;
 4eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 4f0:	eb 23                	jmp    515 <stat+0x4c>
  r = fstat(fd, st);
 4f2:	8b 45 0c             	mov    0xc(%ebp),%eax
 4f5:	89 44 24 04          	mov    %eax,0x4(%esp)
 4f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4fc:	89 04 24             	mov    %eax,(%esp)
 4ff:	e8 fc 00 00 00       	call   600 <fstat>
 504:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 507:	8b 45 f4             	mov    -0xc(%ebp),%eax
 50a:	89 04 24             	mov    %eax,(%esp)
 50d:	e8 be 00 00 00       	call   5d0 <close>
  return r;
 512:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 515:	c9                   	leave  
 516:	c3                   	ret    

00000517 <atoi>:

int
atoi(const char *s)
{
 517:	55                   	push   %ebp
 518:	89 e5                	mov    %esp,%ebp
 51a:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 51d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 524:	eb 24                	jmp    54a <atoi+0x33>
    n = n*10 + *s++ - '0';
 526:	8b 55 fc             	mov    -0x4(%ebp),%edx
 529:	89 d0                	mov    %edx,%eax
 52b:	c1 e0 02             	shl    $0x2,%eax
 52e:	01 d0                	add    %edx,%eax
 530:	01 c0                	add    %eax,%eax
 532:	89 c1                	mov    %eax,%ecx
 534:	8b 45 08             	mov    0x8(%ebp),%eax
 537:	8d 50 01             	lea    0x1(%eax),%edx
 53a:	89 55 08             	mov    %edx,0x8(%ebp)
 53d:	8a 00                	mov    (%eax),%al
 53f:	0f be c0             	movsbl %al,%eax
 542:	01 c8                	add    %ecx,%eax
 544:	83 e8 30             	sub    $0x30,%eax
 547:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 54a:	8b 45 08             	mov    0x8(%ebp),%eax
 54d:	8a 00                	mov    (%eax),%al
 54f:	3c 2f                	cmp    $0x2f,%al
 551:	7e 09                	jle    55c <atoi+0x45>
 553:	8b 45 08             	mov    0x8(%ebp),%eax
 556:	8a 00                	mov    (%eax),%al
 558:	3c 39                	cmp    $0x39,%al
 55a:	7e ca                	jle    526 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 55c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 55f:	c9                   	leave  
 560:	c3                   	ret    

00000561 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 561:	55                   	push   %ebp
 562:	89 e5                	mov    %esp,%ebp
 564:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 567:	8b 45 08             	mov    0x8(%ebp),%eax
 56a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 56d:	8b 45 0c             	mov    0xc(%ebp),%eax
 570:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 573:	eb 16                	jmp    58b <memmove+0x2a>
    *dst++ = *src++;
 575:	8b 45 fc             	mov    -0x4(%ebp),%eax
 578:	8d 50 01             	lea    0x1(%eax),%edx
 57b:	89 55 fc             	mov    %edx,-0x4(%ebp)
 57e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 581:	8d 4a 01             	lea    0x1(%edx),%ecx
 584:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 587:	8a 12                	mov    (%edx),%dl
 589:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 58b:	8b 45 10             	mov    0x10(%ebp),%eax
 58e:	8d 50 ff             	lea    -0x1(%eax),%edx
 591:	89 55 10             	mov    %edx,0x10(%ebp)
 594:	85 c0                	test   %eax,%eax
 596:	7f dd                	jg     575 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 598:	8b 45 08             	mov    0x8(%ebp),%eax
}
 59b:	c9                   	leave  
 59c:	c3                   	ret    
 59d:	90                   	nop
 59e:	90                   	nop
 59f:	90                   	nop

000005a0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 5a0:	b8 01 00 00 00       	mov    $0x1,%eax
 5a5:	cd 40                	int    $0x40
 5a7:	c3                   	ret    

000005a8 <exit>:
SYSCALL(exit)
 5a8:	b8 02 00 00 00       	mov    $0x2,%eax
 5ad:	cd 40                	int    $0x40
 5af:	c3                   	ret    

000005b0 <wait>:
SYSCALL(wait)
 5b0:	b8 03 00 00 00       	mov    $0x3,%eax
 5b5:	cd 40                	int    $0x40
 5b7:	c3                   	ret    

000005b8 <pipe>:
SYSCALL(pipe)
 5b8:	b8 04 00 00 00       	mov    $0x4,%eax
 5bd:	cd 40                	int    $0x40
 5bf:	c3                   	ret    

000005c0 <read>:
SYSCALL(read)
 5c0:	b8 05 00 00 00       	mov    $0x5,%eax
 5c5:	cd 40                	int    $0x40
 5c7:	c3                   	ret    

000005c8 <write>:
SYSCALL(write)
 5c8:	b8 10 00 00 00       	mov    $0x10,%eax
 5cd:	cd 40                	int    $0x40
 5cf:	c3                   	ret    

000005d0 <close>:
SYSCALL(close)
 5d0:	b8 15 00 00 00       	mov    $0x15,%eax
 5d5:	cd 40                	int    $0x40
 5d7:	c3                   	ret    

000005d8 <kill>:
SYSCALL(kill)
 5d8:	b8 06 00 00 00       	mov    $0x6,%eax
 5dd:	cd 40                	int    $0x40
 5df:	c3                   	ret    

000005e0 <exec>:
SYSCALL(exec)
 5e0:	b8 07 00 00 00       	mov    $0x7,%eax
 5e5:	cd 40                	int    $0x40
 5e7:	c3                   	ret    

000005e8 <open>:
SYSCALL(open)
 5e8:	b8 0f 00 00 00       	mov    $0xf,%eax
 5ed:	cd 40                	int    $0x40
 5ef:	c3                   	ret    

000005f0 <mknod>:
SYSCALL(mknod)
 5f0:	b8 11 00 00 00       	mov    $0x11,%eax
 5f5:	cd 40                	int    $0x40
 5f7:	c3                   	ret    

000005f8 <unlink>:
SYSCALL(unlink)
 5f8:	b8 12 00 00 00       	mov    $0x12,%eax
 5fd:	cd 40                	int    $0x40
 5ff:	c3                   	ret    

00000600 <fstat>:
SYSCALL(fstat)
 600:	b8 08 00 00 00       	mov    $0x8,%eax
 605:	cd 40                	int    $0x40
 607:	c3                   	ret    

00000608 <link>:
SYSCALL(link)
 608:	b8 13 00 00 00       	mov    $0x13,%eax
 60d:	cd 40                	int    $0x40
 60f:	c3                   	ret    

00000610 <mkdir>:
SYSCALL(mkdir)
 610:	b8 14 00 00 00       	mov    $0x14,%eax
 615:	cd 40                	int    $0x40
 617:	c3                   	ret    

00000618 <chdir>:
SYSCALL(chdir)
 618:	b8 09 00 00 00       	mov    $0x9,%eax
 61d:	cd 40                	int    $0x40
 61f:	c3                   	ret    

00000620 <dup>:
SYSCALL(dup)
 620:	b8 0a 00 00 00       	mov    $0xa,%eax
 625:	cd 40                	int    $0x40
 627:	c3                   	ret    

00000628 <getpid>:
SYSCALL(getpid)
 628:	b8 0b 00 00 00       	mov    $0xb,%eax
 62d:	cd 40                	int    $0x40
 62f:	c3                   	ret    

00000630 <sbrk>:
SYSCALL(sbrk)
 630:	b8 0c 00 00 00       	mov    $0xc,%eax
 635:	cd 40                	int    $0x40
 637:	c3                   	ret    

00000638 <sleep>:
SYSCALL(sleep)
 638:	b8 0d 00 00 00       	mov    $0xd,%eax
 63d:	cd 40                	int    $0x40
 63f:	c3                   	ret    

00000640 <uptime>:
SYSCALL(uptime)
 640:	b8 0e 00 00 00       	mov    $0xe,%eax
 645:	cd 40                	int    $0x40
 647:	c3                   	ret    

00000648 <getticks>:
SYSCALL(getticks)
 648:	b8 16 00 00 00       	mov    $0x16,%eax
 64d:	cd 40                	int    $0x40
 64f:	c3                   	ret    

00000650 <ccreate>:
SYSCALL(ccreate)
 650:	b8 17 00 00 00       	mov    $0x17,%eax
 655:	cd 40                	int    $0x40
 657:	c3                   	ret    

00000658 <cstart>:
SYSCALL(cstart)
 658:	b8 19 00 00 00       	mov    $0x19,%eax
 65d:	cd 40                	int    $0x40
 65f:	c3                   	ret    

00000660 <cstop>:
SYSCALL(cstop)
 660:	b8 18 00 00 00       	mov    $0x18,%eax
 665:	cd 40                	int    $0x40
 667:	c3                   	ret    

00000668 <cpause>:
SYSCALL(cpause)
 668:	b8 1b 00 00 00       	mov    $0x1b,%eax
 66d:	cd 40                	int    $0x40
 66f:	c3                   	ret    

00000670 <cinfo>:
SYSCALL(cinfo)
 670:	b8 1a 00 00 00       	mov    $0x1a,%eax
 675:	cd 40                	int    $0x40
 677:	c3                   	ret    

00000678 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 678:	55                   	push   %ebp
 679:	89 e5                	mov    %esp,%ebp
 67b:	83 ec 18             	sub    $0x18,%esp
 67e:	8b 45 0c             	mov    0xc(%ebp),%eax
 681:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 684:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 68b:	00 
 68c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 68f:	89 44 24 04          	mov    %eax,0x4(%esp)
 693:	8b 45 08             	mov    0x8(%ebp),%eax
 696:	89 04 24             	mov    %eax,(%esp)
 699:	e8 2a ff ff ff       	call   5c8 <write>
}
 69e:	c9                   	leave  
 69f:	c3                   	ret    

000006a0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 6a0:	55                   	push   %ebp
 6a1:	89 e5                	mov    %esp,%ebp
 6a3:	56                   	push   %esi
 6a4:	53                   	push   %ebx
 6a5:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 6a8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 6af:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 6b3:	74 17                	je     6cc <printint+0x2c>
 6b5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 6b9:	79 11                	jns    6cc <printint+0x2c>
    neg = 1;
 6bb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 6c2:	8b 45 0c             	mov    0xc(%ebp),%eax
 6c5:	f7 d8                	neg    %eax
 6c7:	89 45 ec             	mov    %eax,-0x14(%ebp)
 6ca:	eb 06                	jmp    6d2 <printint+0x32>
  } else {
    x = xx;
 6cc:	8b 45 0c             	mov    0xc(%ebp),%eax
 6cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 6d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 6d9:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 6dc:	8d 41 01             	lea    0x1(%ecx),%eax
 6df:	89 45 f4             	mov    %eax,-0xc(%ebp)
 6e2:	8b 5d 10             	mov    0x10(%ebp),%ebx
 6e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
 6e8:	ba 00 00 00 00       	mov    $0x0,%edx
 6ed:	f7 f3                	div    %ebx
 6ef:	89 d0                	mov    %edx,%eax
 6f1:	8a 80 04 0e 00 00    	mov    0xe04(%eax),%al
 6f7:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 6fb:	8b 75 10             	mov    0x10(%ebp),%esi
 6fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
 701:	ba 00 00 00 00       	mov    $0x0,%edx
 706:	f7 f6                	div    %esi
 708:	89 45 ec             	mov    %eax,-0x14(%ebp)
 70b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 70f:	75 c8                	jne    6d9 <printint+0x39>
  if(neg)
 711:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 715:	74 10                	je     727 <printint+0x87>
    buf[i++] = '-';
 717:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71a:	8d 50 01             	lea    0x1(%eax),%edx
 71d:	89 55 f4             	mov    %edx,-0xc(%ebp)
 720:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 725:	eb 1e                	jmp    745 <printint+0xa5>
 727:	eb 1c                	jmp    745 <printint+0xa5>
    putc(fd, buf[i]);
 729:	8d 55 dc             	lea    -0x24(%ebp),%edx
 72c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72f:	01 d0                	add    %edx,%eax
 731:	8a 00                	mov    (%eax),%al
 733:	0f be c0             	movsbl %al,%eax
 736:	89 44 24 04          	mov    %eax,0x4(%esp)
 73a:	8b 45 08             	mov    0x8(%ebp),%eax
 73d:	89 04 24             	mov    %eax,(%esp)
 740:	e8 33 ff ff ff       	call   678 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 745:	ff 4d f4             	decl   -0xc(%ebp)
 748:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 74c:	79 db                	jns    729 <printint+0x89>
    putc(fd, buf[i]);
}
 74e:	83 c4 30             	add    $0x30,%esp
 751:	5b                   	pop    %ebx
 752:	5e                   	pop    %esi
 753:	5d                   	pop    %ebp
 754:	c3                   	ret    

00000755 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 755:	55                   	push   %ebp
 756:	89 e5                	mov    %esp,%ebp
 758:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 75b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 762:	8d 45 0c             	lea    0xc(%ebp),%eax
 765:	83 c0 04             	add    $0x4,%eax
 768:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 76b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 772:	e9 77 01 00 00       	jmp    8ee <printf+0x199>
    c = fmt[i] & 0xff;
 777:	8b 55 0c             	mov    0xc(%ebp),%edx
 77a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 77d:	01 d0                	add    %edx,%eax
 77f:	8a 00                	mov    (%eax),%al
 781:	0f be c0             	movsbl %al,%eax
 784:	25 ff 00 00 00       	and    $0xff,%eax
 789:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 78c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 790:	75 2c                	jne    7be <printf+0x69>
      if(c == '%'){
 792:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 796:	75 0c                	jne    7a4 <printf+0x4f>
        state = '%';
 798:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 79f:	e9 47 01 00 00       	jmp    8eb <printf+0x196>
      } else {
        putc(fd, c);
 7a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 7a7:	0f be c0             	movsbl %al,%eax
 7aa:	89 44 24 04          	mov    %eax,0x4(%esp)
 7ae:	8b 45 08             	mov    0x8(%ebp),%eax
 7b1:	89 04 24             	mov    %eax,(%esp)
 7b4:	e8 bf fe ff ff       	call   678 <putc>
 7b9:	e9 2d 01 00 00       	jmp    8eb <printf+0x196>
      }
    } else if(state == '%'){
 7be:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 7c2:	0f 85 23 01 00 00    	jne    8eb <printf+0x196>
      if(c == 'd'){
 7c8:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 7cc:	75 2d                	jne    7fb <printf+0xa6>
        printint(fd, *ap, 10, 1);
 7ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
 7d1:	8b 00                	mov    (%eax),%eax
 7d3:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 7da:	00 
 7db:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 7e2:	00 
 7e3:	89 44 24 04          	mov    %eax,0x4(%esp)
 7e7:	8b 45 08             	mov    0x8(%ebp),%eax
 7ea:	89 04 24             	mov    %eax,(%esp)
 7ed:	e8 ae fe ff ff       	call   6a0 <printint>
        ap++;
 7f2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 7f6:	e9 e9 00 00 00       	jmp    8e4 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 7fb:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 7ff:	74 06                	je     807 <printf+0xb2>
 801:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 805:	75 2d                	jne    834 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 807:	8b 45 e8             	mov    -0x18(%ebp),%eax
 80a:	8b 00                	mov    (%eax),%eax
 80c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 813:	00 
 814:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 81b:	00 
 81c:	89 44 24 04          	mov    %eax,0x4(%esp)
 820:	8b 45 08             	mov    0x8(%ebp),%eax
 823:	89 04 24             	mov    %eax,(%esp)
 826:	e8 75 fe ff ff       	call   6a0 <printint>
        ap++;
 82b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 82f:	e9 b0 00 00 00       	jmp    8e4 <printf+0x18f>
      } else if(c == 's'){
 834:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 838:	75 42                	jne    87c <printf+0x127>
        s = (char*)*ap;
 83a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 83d:	8b 00                	mov    (%eax),%eax
 83f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 842:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 846:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 84a:	75 09                	jne    855 <printf+0x100>
          s = "(null)";
 84c:	c7 45 f4 65 0b 00 00 	movl   $0xb65,-0xc(%ebp)
        while(*s != 0){
 853:	eb 1c                	jmp    871 <printf+0x11c>
 855:	eb 1a                	jmp    871 <printf+0x11c>
          putc(fd, *s);
 857:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85a:	8a 00                	mov    (%eax),%al
 85c:	0f be c0             	movsbl %al,%eax
 85f:	89 44 24 04          	mov    %eax,0x4(%esp)
 863:	8b 45 08             	mov    0x8(%ebp),%eax
 866:	89 04 24             	mov    %eax,(%esp)
 869:	e8 0a fe ff ff       	call   678 <putc>
          s++;
 86e:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 871:	8b 45 f4             	mov    -0xc(%ebp),%eax
 874:	8a 00                	mov    (%eax),%al
 876:	84 c0                	test   %al,%al
 878:	75 dd                	jne    857 <printf+0x102>
 87a:	eb 68                	jmp    8e4 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 87c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 880:	75 1d                	jne    89f <printf+0x14a>
        putc(fd, *ap);
 882:	8b 45 e8             	mov    -0x18(%ebp),%eax
 885:	8b 00                	mov    (%eax),%eax
 887:	0f be c0             	movsbl %al,%eax
 88a:	89 44 24 04          	mov    %eax,0x4(%esp)
 88e:	8b 45 08             	mov    0x8(%ebp),%eax
 891:	89 04 24             	mov    %eax,(%esp)
 894:	e8 df fd ff ff       	call   678 <putc>
        ap++;
 899:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 89d:	eb 45                	jmp    8e4 <printf+0x18f>
      } else if(c == '%'){
 89f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 8a3:	75 17                	jne    8bc <printf+0x167>
        putc(fd, c);
 8a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8a8:	0f be c0             	movsbl %al,%eax
 8ab:	89 44 24 04          	mov    %eax,0x4(%esp)
 8af:	8b 45 08             	mov    0x8(%ebp),%eax
 8b2:	89 04 24             	mov    %eax,(%esp)
 8b5:	e8 be fd ff ff       	call   678 <putc>
 8ba:	eb 28                	jmp    8e4 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 8bc:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 8c3:	00 
 8c4:	8b 45 08             	mov    0x8(%ebp),%eax
 8c7:	89 04 24             	mov    %eax,(%esp)
 8ca:	e8 a9 fd ff ff       	call   678 <putc>
        putc(fd, c);
 8cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 8d2:	0f be c0             	movsbl %al,%eax
 8d5:	89 44 24 04          	mov    %eax,0x4(%esp)
 8d9:	8b 45 08             	mov    0x8(%ebp),%eax
 8dc:	89 04 24             	mov    %eax,(%esp)
 8df:	e8 94 fd ff ff       	call   678 <putc>
      }
      state = 0;
 8e4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 8eb:	ff 45 f0             	incl   -0x10(%ebp)
 8ee:	8b 55 0c             	mov    0xc(%ebp),%edx
 8f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f4:	01 d0                	add    %edx,%eax
 8f6:	8a 00                	mov    (%eax),%al
 8f8:	84 c0                	test   %al,%al
 8fa:	0f 85 77 fe ff ff    	jne    777 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 900:	c9                   	leave  
 901:	c3                   	ret    
 902:	90                   	nop
 903:	90                   	nop

00000904 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 904:	55                   	push   %ebp
 905:	89 e5                	mov    %esp,%ebp
 907:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 90a:	8b 45 08             	mov    0x8(%ebp),%eax
 90d:	83 e8 08             	sub    $0x8,%eax
 910:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 913:	a1 30 0e 00 00       	mov    0xe30,%eax
 918:	89 45 fc             	mov    %eax,-0x4(%ebp)
 91b:	eb 24                	jmp    941 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 91d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 920:	8b 00                	mov    (%eax),%eax
 922:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 925:	77 12                	ja     939 <free+0x35>
 927:	8b 45 f8             	mov    -0x8(%ebp),%eax
 92a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 92d:	77 24                	ja     953 <free+0x4f>
 92f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 932:	8b 00                	mov    (%eax),%eax
 934:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 937:	77 1a                	ja     953 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 939:	8b 45 fc             	mov    -0x4(%ebp),%eax
 93c:	8b 00                	mov    (%eax),%eax
 93e:	89 45 fc             	mov    %eax,-0x4(%ebp)
 941:	8b 45 f8             	mov    -0x8(%ebp),%eax
 944:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 947:	76 d4                	jbe    91d <free+0x19>
 949:	8b 45 fc             	mov    -0x4(%ebp),%eax
 94c:	8b 00                	mov    (%eax),%eax
 94e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 951:	76 ca                	jbe    91d <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 953:	8b 45 f8             	mov    -0x8(%ebp),%eax
 956:	8b 40 04             	mov    0x4(%eax),%eax
 959:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 960:	8b 45 f8             	mov    -0x8(%ebp),%eax
 963:	01 c2                	add    %eax,%edx
 965:	8b 45 fc             	mov    -0x4(%ebp),%eax
 968:	8b 00                	mov    (%eax),%eax
 96a:	39 c2                	cmp    %eax,%edx
 96c:	75 24                	jne    992 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 96e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 971:	8b 50 04             	mov    0x4(%eax),%edx
 974:	8b 45 fc             	mov    -0x4(%ebp),%eax
 977:	8b 00                	mov    (%eax),%eax
 979:	8b 40 04             	mov    0x4(%eax),%eax
 97c:	01 c2                	add    %eax,%edx
 97e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 981:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 984:	8b 45 fc             	mov    -0x4(%ebp),%eax
 987:	8b 00                	mov    (%eax),%eax
 989:	8b 10                	mov    (%eax),%edx
 98b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 98e:	89 10                	mov    %edx,(%eax)
 990:	eb 0a                	jmp    99c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 992:	8b 45 fc             	mov    -0x4(%ebp),%eax
 995:	8b 10                	mov    (%eax),%edx
 997:	8b 45 f8             	mov    -0x8(%ebp),%eax
 99a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 99c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 99f:	8b 40 04             	mov    0x4(%eax),%eax
 9a2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 9a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9ac:	01 d0                	add    %edx,%eax
 9ae:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 9b1:	75 20                	jne    9d3 <free+0xcf>
    p->s.size += bp->s.size;
 9b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9b6:	8b 50 04             	mov    0x4(%eax),%edx
 9b9:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9bc:	8b 40 04             	mov    0x4(%eax),%eax
 9bf:	01 c2                	add    %eax,%edx
 9c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9c4:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 9c7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 9ca:	8b 10                	mov    (%eax),%edx
 9cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9cf:	89 10                	mov    %edx,(%eax)
 9d1:	eb 08                	jmp    9db <free+0xd7>
  } else
    p->s.ptr = bp;
 9d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9d6:	8b 55 f8             	mov    -0x8(%ebp),%edx
 9d9:	89 10                	mov    %edx,(%eax)
  freep = p;
 9db:	8b 45 fc             	mov    -0x4(%ebp),%eax
 9de:	a3 30 0e 00 00       	mov    %eax,0xe30
}
 9e3:	c9                   	leave  
 9e4:	c3                   	ret    

000009e5 <morecore>:

static Header*
morecore(uint nu)
{
 9e5:	55                   	push   %ebp
 9e6:	89 e5                	mov    %esp,%ebp
 9e8:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 9eb:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 9f2:	77 07                	ja     9fb <morecore+0x16>
    nu = 4096;
 9f4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 9fb:	8b 45 08             	mov    0x8(%ebp),%eax
 9fe:	c1 e0 03             	shl    $0x3,%eax
 a01:	89 04 24             	mov    %eax,(%esp)
 a04:	e8 27 fc ff ff       	call   630 <sbrk>
 a09:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 a0c:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 a10:	75 07                	jne    a19 <morecore+0x34>
    return 0;
 a12:	b8 00 00 00 00       	mov    $0x0,%eax
 a17:	eb 22                	jmp    a3b <morecore+0x56>
  hp = (Header*)p;
 a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 a1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a22:	8b 55 08             	mov    0x8(%ebp),%edx
 a25:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 a28:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a2b:	83 c0 08             	add    $0x8,%eax
 a2e:	89 04 24             	mov    %eax,(%esp)
 a31:	e8 ce fe ff ff       	call   904 <free>
  return freep;
 a36:	a1 30 0e 00 00       	mov    0xe30,%eax
}
 a3b:	c9                   	leave  
 a3c:	c3                   	ret    

00000a3d <malloc>:

void*
malloc(uint nbytes)
{
 a3d:	55                   	push   %ebp
 a3e:	89 e5                	mov    %esp,%ebp
 a40:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a43:	8b 45 08             	mov    0x8(%ebp),%eax
 a46:	83 c0 07             	add    $0x7,%eax
 a49:	c1 e8 03             	shr    $0x3,%eax
 a4c:	40                   	inc    %eax
 a4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 a50:	a1 30 0e 00 00       	mov    0xe30,%eax
 a55:	89 45 f0             	mov    %eax,-0x10(%ebp)
 a58:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 a5c:	75 23                	jne    a81 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 a5e:	c7 45 f0 28 0e 00 00 	movl   $0xe28,-0x10(%ebp)
 a65:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a68:	a3 30 0e 00 00       	mov    %eax,0xe30
 a6d:	a1 30 0e 00 00       	mov    0xe30,%eax
 a72:	a3 28 0e 00 00       	mov    %eax,0xe28
    base.s.size = 0;
 a77:	c7 05 2c 0e 00 00 00 	movl   $0x0,0xe2c
 a7e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a81:	8b 45 f0             	mov    -0x10(%ebp),%eax
 a84:	8b 00                	mov    (%eax),%eax
 a86:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a8c:	8b 40 04             	mov    0x4(%eax),%eax
 a8f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a92:	72 4d                	jb     ae1 <malloc+0xa4>
      if(p->s.size == nunits)
 a94:	8b 45 f4             	mov    -0xc(%ebp),%eax
 a97:	8b 40 04             	mov    0x4(%eax),%eax
 a9a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 a9d:	75 0c                	jne    aab <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 a9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aa2:	8b 10                	mov    (%eax),%edx
 aa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 aa7:	89 10                	mov    %edx,(%eax)
 aa9:	eb 26                	jmp    ad1 <malloc+0x94>
      else {
        p->s.size -= nunits;
 aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
 aae:	8b 40 04             	mov    0x4(%eax),%eax
 ab1:	2b 45 ec             	sub    -0x14(%ebp),%eax
 ab4:	89 c2                	mov    %eax,%edx
 ab6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 ab9:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 abc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 abf:	8b 40 04             	mov    0x4(%eax),%eax
 ac2:	c1 e0 03             	shl    $0x3,%eax
 ac5:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 acb:	8b 55 ec             	mov    -0x14(%ebp),%edx
 ace:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 ad4:	a3 30 0e 00 00       	mov    %eax,0xe30
      return (void*)(p + 1);
 ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 adc:	83 c0 08             	add    $0x8,%eax
 adf:	eb 38                	jmp    b19 <malloc+0xdc>
    }
    if(p == freep)
 ae1:	a1 30 0e 00 00       	mov    0xe30,%eax
 ae6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 ae9:	75 1b                	jne    b06 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 aeb:	8b 45 ec             	mov    -0x14(%ebp),%eax
 aee:	89 04 24             	mov    %eax,(%esp)
 af1:	e8 ef fe ff ff       	call   9e5 <morecore>
 af6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 af9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 afd:	75 07                	jne    b06 <malloc+0xc9>
        return 0;
 aff:	b8 00 00 00 00       	mov    $0x0,%eax
 b04:	eb 13                	jmp    b19 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b09:	89 45 f0             	mov    %eax,-0x10(%ebp)
 b0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 b0f:	8b 00                	mov    (%eax),%eax
 b11:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 b14:	e9 70 ff ff ff       	jmp    a89 <malloc+0x4c>
}
 b19:	c9                   	leave  
 b1a:	c3                   	ret    
