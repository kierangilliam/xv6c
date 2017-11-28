
_forktest:     file format elf32-i386


Disassembly of section .text:

00000000 <printf>:

#define N  1000

void
printf(int fd, char *s, ...)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  write(fd, s, strlen(s));
   6:	8b 45 0c             	mov    0xc(%ebp),%eax
   9:	89 04 24             	mov    %eax,(%esp)
   c:	e8 8e 01 00 00       	call   19f <strlen>
  11:	89 44 24 08          	mov    %eax,0x8(%esp)
  15:	8b 45 0c             	mov    0xc(%ebp),%eax
  18:	89 44 24 04          	mov    %eax,0x4(%esp)
  1c:	8b 45 08             	mov    0x8(%ebp),%eax
  1f:	89 04 24             	mov    %eax,(%esp)
  22:	e8 61 03 00 00       	call   388 <write>
}
  27:	c9                   	leave  
  28:	c3                   	ret    

00000029 <forktest>:

void
forktest(void)
{
  29:	55                   	push   %ebp
  2a:	89 e5                	mov    %esp,%ebp
  2c:	83 ec 28             	sub    $0x28,%esp
  int n, pid;

  printf(1, "fork test\n");
  2f:	c7 44 24 04 38 04 00 	movl   $0x438,0x4(%esp)
  36:	00 
  37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  3e:	e8 bd ff ff ff       	call   0 <printf>

  for(n=0; n<N; n++){
  43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  4a:	eb 1e                	jmp    6a <forktest+0x41>
    pid = fork();
  4c:	e8 0f 03 00 00       	call   360 <fork>
  51:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid < 0)
  54:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  58:	79 02                	jns    5c <forktest+0x33>
      break;
  5a:	eb 17                	jmp    73 <forktest+0x4a>
    if(pid == 0)
  5c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  60:	75 05                	jne    67 <forktest+0x3e>
      exit();
  62:	e8 01 03 00 00       	call   368 <exit>
{
  int n, pid;

  printf(1, "fork test\n");

  for(n=0; n<N; n++){
  67:	ff 45 f4             	incl   -0xc(%ebp)
  6a:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
  71:	7e d9                	jle    4c <forktest+0x23>
      break;
    if(pid == 0)
      exit();
  }

  if(n == N){
  73:	81 7d f4 e8 03 00 00 	cmpl   $0x3e8,-0xc(%ebp)
  7a:	75 21                	jne    9d <forktest+0x74>
    printf(1, "fork claimed to work N times!\n", N);
  7c:	c7 44 24 08 e8 03 00 	movl   $0x3e8,0x8(%esp)
  83:	00 
  84:	c7 44 24 04 44 04 00 	movl   $0x444,0x4(%esp)
  8b:	00 
  8c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  93:	e8 68 ff ff ff       	call   0 <printf>
    exit();
  98:	e8 cb 02 00 00       	call   368 <exit>
  }

  for(; n > 0; n--){
  9d:	eb 25                	jmp    c4 <forktest+0x9b>
    if(wait() < 0){
  9f:	e8 cc 02 00 00       	call   370 <wait>
  a4:	85 c0                	test   %eax,%eax
  a6:	79 19                	jns    c1 <forktest+0x98>
      printf(1, "wait stopped early\n");
  a8:	c7 44 24 04 63 04 00 	movl   $0x463,0x4(%esp)
  af:	00 
  b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  b7:	e8 44 ff ff ff       	call   0 <printf>
      exit();
  bc:	e8 a7 02 00 00       	call   368 <exit>
  if(n == N){
    printf(1, "fork claimed to work N times!\n", N);
    exit();
  }

  for(; n > 0; n--){
  c1:	ff 4d f4             	decl   -0xc(%ebp)
  c4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  c8:	7f d5                	jg     9f <forktest+0x76>
      printf(1, "wait stopped early\n");
      exit();
    }
  }

  if(wait() != -1){
  ca:	e8 a1 02 00 00       	call   370 <wait>
  cf:	83 f8 ff             	cmp    $0xffffffff,%eax
  d2:	74 19                	je     ed <forktest+0xc4>
    printf(1, "wait got too many\n");
  d4:	c7 44 24 04 77 04 00 	movl   $0x477,0x4(%esp)
  db:	00 
  dc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  e3:	e8 18 ff ff ff       	call   0 <printf>
    exit();
  e8:	e8 7b 02 00 00       	call   368 <exit>
  }

  printf(1, "fork test OK\n");
  ed:	c7 44 24 04 8a 04 00 	movl   $0x48a,0x4(%esp)
  f4:	00 
  f5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  fc:	e8 ff fe ff ff       	call   0 <printf>
}
 101:	c9                   	leave  
 102:	c3                   	ret    

00000103 <main>:

int
main(void)
{
 103:	55                   	push   %ebp
 104:	89 e5                	mov    %esp,%ebp
 106:	83 e4 f0             	and    $0xfffffff0,%esp
  forktest();
 109:	e8 1b ff ff ff       	call   29 <forktest>
  exit();
 10e:	e8 55 02 00 00       	call   368 <exit>
 113:	90                   	nop

00000114 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 114:	55                   	push   %ebp
 115:	89 e5                	mov    %esp,%ebp
 117:	57                   	push   %edi
 118:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 119:	8b 4d 08             	mov    0x8(%ebp),%ecx
 11c:	8b 55 10             	mov    0x10(%ebp),%edx
 11f:	8b 45 0c             	mov    0xc(%ebp),%eax
 122:	89 cb                	mov    %ecx,%ebx
 124:	89 df                	mov    %ebx,%edi
 126:	89 d1                	mov    %edx,%ecx
 128:	fc                   	cld    
 129:	f3 aa                	rep stos %al,%es:(%edi)
 12b:	89 ca                	mov    %ecx,%edx
 12d:	89 fb                	mov    %edi,%ebx
 12f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 132:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 135:	5b                   	pop    %ebx
 136:	5f                   	pop    %edi
 137:	5d                   	pop    %ebp
 138:	c3                   	ret    

00000139 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 139:	55                   	push   %ebp
 13a:	89 e5                	mov    %esp,%ebp
 13c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 13f:	8b 45 08             	mov    0x8(%ebp),%eax
 142:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 145:	90                   	nop
 146:	8b 45 08             	mov    0x8(%ebp),%eax
 149:	8d 50 01             	lea    0x1(%eax),%edx
 14c:	89 55 08             	mov    %edx,0x8(%ebp)
 14f:	8b 55 0c             	mov    0xc(%ebp),%edx
 152:	8d 4a 01             	lea    0x1(%edx),%ecx
 155:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 158:	8a 12                	mov    (%edx),%dl
 15a:	88 10                	mov    %dl,(%eax)
 15c:	8a 00                	mov    (%eax),%al
 15e:	84 c0                	test   %al,%al
 160:	75 e4                	jne    146 <strcpy+0xd>
    ;
  return os;
 162:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 165:	c9                   	leave  
 166:	c3                   	ret    

00000167 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 167:	55                   	push   %ebp
 168:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 16a:	eb 06                	jmp    172 <strcmp+0xb>
    p++, q++;
 16c:	ff 45 08             	incl   0x8(%ebp)
 16f:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 172:	8b 45 08             	mov    0x8(%ebp),%eax
 175:	8a 00                	mov    (%eax),%al
 177:	84 c0                	test   %al,%al
 179:	74 0e                	je     189 <strcmp+0x22>
 17b:	8b 45 08             	mov    0x8(%ebp),%eax
 17e:	8a 10                	mov    (%eax),%dl
 180:	8b 45 0c             	mov    0xc(%ebp),%eax
 183:	8a 00                	mov    (%eax),%al
 185:	38 c2                	cmp    %al,%dl
 187:	74 e3                	je     16c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 189:	8b 45 08             	mov    0x8(%ebp),%eax
 18c:	8a 00                	mov    (%eax),%al
 18e:	0f b6 d0             	movzbl %al,%edx
 191:	8b 45 0c             	mov    0xc(%ebp),%eax
 194:	8a 00                	mov    (%eax),%al
 196:	0f b6 c0             	movzbl %al,%eax
 199:	29 c2                	sub    %eax,%edx
 19b:	89 d0                	mov    %edx,%eax
}
 19d:	5d                   	pop    %ebp
 19e:	c3                   	ret    

0000019f <strlen>:

uint
strlen(char *s)
{
 19f:	55                   	push   %ebp
 1a0:	89 e5                	mov    %esp,%ebp
 1a2:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 1a5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 1ac:	eb 03                	jmp    1b1 <strlen+0x12>
 1ae:	ff 45 fc             	incl   -0x4(%ebp)
 1b1:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1b4:	8b 45 08             	mov    0x8(%ebp),%eax
 1b7:	01 d0                	add    %edx,%eax
 1b9:	8a 00                	mov    (%eax),%al
 1bb:	84 c0                	test   %al,%al
 1bd:	75 ef                	jne    1ae <strlen+0xf>
    ;
  return n;
 1bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1c2:	c9                   	leave  
 1c3:	c3                   	ret    

000001c4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c4:	55                   	push   %ebp
 1c5:	89 e5                	mov    %esp,%ebp
 1c7:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1ca:	8b 45 10             	mov    0x10(%ebp),%eax
 1cd:	89 44 24 08          	mov    %eax,0x8(%esp)
 1d1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1d4:	89 44 24 04          	mov    %eax,0x4(%esp)
 1d8:	8b 45 08             	mov    0x8(%ebp),%eax
 1db:	89 04 24             	mov    %eax,(%esp)
 1de:	e8 31 ff ff ff       	call   114 <stosb>
  return dst;
 1e3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1e6:	c9                   	leave  
 1e7:	c3                   	ret    

000001e8 <strchr>:

char*
strchr(const char *s, char c)
{
 1e8:	55                   	push   %ebp
 1e9:	89 e5                	mov    %esp,%ebp
 1eb:	83 ec 04             	sub    $0x4,%esp
 1ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 1f1:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1f4:	eb 12                	jmp    208 <strchr+0x20>
    if(*s == c)
 1f6:	8b 45 08             	mov    0x8(%ebp),%eax
 1f9:	8a 00                	mov    (%eax),%al
 1fb:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1fe:	75 05                	jne    205 <strchr+0x1d>
      return (char*)s;
 200:	8b 45 08             	mov    0x8(%ebp),%eax
 203:	eb 11                	jmp    216 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 205:	ff 45 08             	incl   0x8(%ebp)
 208:	8b 45 08             	mov    0x8(%ebp),%eax
 20b:	8a 00                	mov    (%eax),%al
 20d:	84 c0                	test   %al,%al
 20f:	75 e5                	jne    1f6 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 211:	b8 00 00 00 00       	mov    $0x0,%eax
}
 216:	c9                   	leave  
 217:	c3                   	ret    

00000218 <gets>:

char*
gets(char *buf, int max)
{
 218:	55                   	push   %ebp
 219:	89 e5                	mov    %esp,%ebp
 21b:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 21e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 225:	eb 49                	jmp    270 <gets+0x58>
    cc = read(0, &c, 1);
 227:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 22e:	00 
 22f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 232:	89 44 24 04          	mov    %eax,0x4(%esp)
 236:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 23d:	e8 3e 01 00 00       	call   380 <read>
 242:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 245:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 249:	7f 02                	jg     24d <gets+0x35>
      break;
 24b:	eb 2c                	jmp    279 <gets+0x61>
    buf[i++] = c;
 24d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 250:	8d 50 01             	lea    0x1(%eax),%edx
 253:	89 55 f4             	mov    %edx,-0xc(%ebp)
 256:	89 c2                	mov    %eax,%edx
 258:	8b 45 08             	mov    0x8(%ebp),%eax
 25b:	01 c2                	add    %eax,%edx
 25d:	8a 45 ef             	mov    -0x11(%ebp),%al
 260:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 262:	8a 45 ef             	mov    -0x11(%ebp),%al
 265:	3c 0a                	cmp    $0xa,%al
 267:	74 10                	je     279 <gets+0x61>
 269:	8a 45 ef             	mov    -0x11(%ebp),%al
 26c:	3c 0d                	cmp    $0xd,%al
 26e:	74 09                	je     279 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 270:	8b 45 f4             	mov    -0xc(%ebp),%eax
 273:	40                   	inc    %eax
 274:	3b 45 0c             	cmp    0xc(%ebp),%eax
 277:	7c ae                	jl     227 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 279:	8b 55 f4             	mov    -0xc(%ebp),%edx
 27c:	8b 45 08             	mov    0x8(%ebp),%eax
 27f:	01 d0                	add    %edx,%eax
 281:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 284:	8b 45 08             	mov    0x8(%ebp),%eax
}
 287:	c9                   	leave  
 288:	c3                   	ret    

00000289 <stat>:

int
stat(char *n, struct stat *st)
{
 289:	55                   	push   %ebp
 28a:	89 e5                	mov    %esp,%ebp
 28c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 28f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 296:	00 
 297:	8b 45 08             	mov    0x8(%ebp),%eax
 29a:	89 04 24             	mov    %eax,(%esp)
 29d:	e8 06 01 00 00       	call   3a8 <open>
 2a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 2a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 2a9:	79 07                	jns    2b2 <stat+0x29>
    return -1;
 2ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2b0:	eb 23                	jmp    2d5 <stat+0x4c>
  r = fstat(fd, st);
 2b2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b5:	89 44 24 04          	mov    %eax,0x4(%esp)
 2b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2bc:	89 04 24             	mov    %eax,(%esp)
 2bf:	e8 fc 00 00 00       	call   3c0 <fstat>
 2c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ca:	89 04 24             	mov    %eax,(%esp)
 2cd:	e8 be 00 00 00       	call   390 <close>
  return r;
 2d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2d5:	c9                   	leave  
 2d6:	c3                   	ret    

000002d7 <atoi>:

int
atoi(const char *s)
{
 2d7:	55                   	push   %ebp
 2d8:	89 e5                	mov    %esp,%ebp
 2da:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2dd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2e4:	eb 24                	jmp    30a <atoi+0x33>
    n = n*10 + *s++ - '0';
 2e6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2e9:	89 d0                	mov    %edx,%eax
 2eb:	c1 e0 02             	shl    $0x2,%eax
 2ee:	01 d0                	add    %edx,%eax
 2f0:	01 c0                	add    %eax,%eax
 2f2:	89 c1                	mov    %eax,%ecx
 2f4:	8b 45 08             	mov    0x8(%ebp),%eax
 2f7:	8d 50 01             	lea    0x1(%eax),%edx
 2fa:	89 55 08             	mov    %edx,0x8(%ebp)
 2fd:	8a 00                	mov    (%eax),%al
 2ff:	0f be c0             	movsbl %al,%eax
 302:	01 c8                	add    %ecx,%eax
 304:	83 e8 30             	sub    $0x30,%eax
 307:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 30a:	8b 45 08             	mov    0x8(%ebp),%eax
 30d:	8a 00                	mov    (%eax),%al
 30f:	3c 2f                	cmp    $0x2f,%al
 311:	7e 09                	jle    31c <atoi+0x45>
 313:	8b 45 08             	mov    0x8(%ebp),%eax
 316:	8a 00                	mov    (%eax),%al
 318:	3c 39                	cmp    $0x39,%al
 31a:	7e ca                	jle    2e6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 31c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 31f:	c9                   	leave  
 320:	c3                   	ret    

00000321 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 321:	55                   	push   %ebp
 322:	89 e5                	mov    %esp,%ebp
 324:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 327:	8b 45 08             	mov    0x8(%ebp),%eax
 32a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 32d:	8b 45 0c             	mov    0xc(%ebp),%eax
 330:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 333:	eb 16                	jmp    34b <memmove+0x2a>
    *dst++ = *src++;
 335:	8b 45 fc             	mov    -0x4(%ebp),%eax
 338:	8d 50 01             	lea    0x1(%eax),%edx
 33b:	89 55 fc             	mov    %edx,-0x4(%ebp)
 33e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 341:	8d 4a 01             	lea    0x1(%edx),%ecx
 344:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 347:	8a 12                	mov    (%edx),%dl
 349:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 34b:	8b 45 10             	mov    0x10(%ebp),%eax
 34e:	8d 50 ff             	lea    -0x1(%eax),%edx
 351:	89 55 10             	mov    %edx,0x10(%ebp)
 354:	85 c0                	test   %eax,%eax
 356:	7f dd                	jg     335 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 358:	8b 45 08             	mov    0x8(%ebp),%eax
}
 35b:	c9                   	leave  
 35c:	c3                   	ret    
 35d:	90                   	nop
 35e:	90                   	nop
 35f:	90                   	nop

00000360 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 360:	b8 01 00 00 00       	mov    $0x1,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <exit>:
SYSCALL(exit)
 368:	b8 02 00 00 00       	mov    $0x2,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <wait>:
SYSCALL(wait)
 370:	b8 03 00 00 00       	mov    $0x3,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <pipe>:
SYSCALL(pipe)
 378:	b8 04 00 00 00       	mov    $0x4,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <read>:
SYSCALL(read)
 380:	b8 05 00 00 00       	mov    $0x5,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <write>:
SYSCALL(write)
 388:	b8 10 00 00 00       	mov    $0x10,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <close>:
SYSCALL(close)
 390:	b8 15 00 00 00       	mov    $0x15,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <kill>:
SYSCALL(kill)
 398:	b8 06 00 00 00       	mov    $0x6,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <exec>:
SYSCALL(exec)
 3a0:	b8 07 00 00 00       	mov    $0x7,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <open>:
SYSCALL(open)
 3a8:	b8 0f 00 00 00       	mov    $0xf,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <mknod>:
SYSCALL(mknod)
 3b0:	b8 11 00 00 00       	mov    $0x11,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <unlink>:
SYSCALL(unlink)
 3b8:	b8 12 00 00 00       	mov    $0x12,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <fstat>:
SYSCALL(fstat)
 3c0:	b8 08 00 00 00       	mov    $0x8,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <link>:
SYSCALL(link)
 3c8:	b8 13 00 00 00       	mov    $0x13,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <mkdir>:
SYSCALL(mkdir)
 3d0:	b8 14 00 00 00       	mov    $0x14,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <chdir>:
SYSCALL(chdir)
 3d8:	b8 09 00 00 00       	mov    $0x9,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <dup>:
SYSCALL(dup)
 3e0:	b8 0a 00 00 00       	mov    $0xa,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <getpid>:
SYSCALL(getpid)
 3e8:	b8 0b 00 00 00       	mov    $0xb,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <sbrk>:
SYSCALL(sbrk)
 3f0:	b8 0c 00 00 00       	mov    $0xc,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <sleep>:
SYSCALL(sleep)
 3f8:	b8 0d 00 00 00       	mov    $0xd,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <uptime>:
SYSCALL(uptime)
 400:	b8 0e 00 00 00       	mov    $0xe,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <getticks>:
SYSCALL(getticks)
 408:	b8 16 00 00 00       	mov    $0x16,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <ccreate>:
SYSCALL(ccreate)
 410:	b8 17 00 00 00       	mov    $0x17,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <cstart>:
SYSCALL(cstart)
 418:	b8 19 00 00 00       	mov    $0x19,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <cstop>:
SYSCALL(cstop)
 420:	b8 18 00 00 00       	mov    $0x18,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <cpause>:
SYSCALL(cpause)
 428:	b8 1b 00 00 00       	mov    $0x1b,%eax
 42d:	cd 40                	int    $0x40
 42f:	c3                   	ret    

00000430 <cinfo>:
SYSCALL(cinfo)
 430:	b8 1a 00 00 00       	mov    $0x1a,%eax
 435:	cd 40                	int    $0x40
 437:	c3                   	ret    
