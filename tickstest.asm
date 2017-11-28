
_tickstest:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 e4 f0             	and    $0xfffffff0,%esp
   6:	83 ec 30             	sub    $0x30,%esp
  int i, j;
  int n;
  uint ticks, t1, t2;


  if (argc != 2) {
   9:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
   d:	74 19                	je     28 <main+0x28>
  	printf(1, "usage: tickstest n\n");
   f:	c7 44 24 04 cb 08 00 	movl   $0x8cb,0x4(%esp)
  16:	00 
  17:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1e:	e8 e2 04 00 00       	call   505 <printf>
  	exit();
  23:	e8 30 03 00 00       	call   358 <exit>
  }

  n = atoi(argv[1]);
  28:	8b 45 0c             	mov    0xc(%ebp),%eax
  2b:	83 c0 04             	add    $0x4,%eax
  2e:	8b 00                	mov    (%eax),%eax
  30:	89 04 24             	mov    %eax,(%esp)
  33:	e8 8f 02 00 00       	call   2c7 <atoi>
  38:	89 44 24 24          	mov    %eax,0x24(%esp)

  t1 = uptime();
  3c:	e8 af 03 00 00       	call   3f0 <uptime>
  41:	89 44 24 20          	mov    %eax,0x20(%esp)

  for (i = 0; i < n; i++) {
  45:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
  4c:	00 
  4d:	eb 1c                	jmp    6b <main+0x6b>
    for (j = 0; j< 100000; j++) {
  4f:	c7 44 24 28 00 00 00 	movl   $0x0,0x28(%esp)
  56:	00 
  57:	eb 04                	jmp    5d <main+0x5d>
  59:	ff 44 24 28          	incl   0x28(%esp)
  5d:	81 7c 24 28 9f 86 01 	cmpl   $0x1869f,0x28(%esp)
  64:	00 
  65:	7e f2                	jle    59 <main+0x59>

  n = atoi(argv[1]);

  t1 = uptime();

  for (i = 0; i < n; i++) {
  67:	ff 44 24 2c          	incl   0x2c(%esp)
  6b:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  6f:	3b 44 24 24          	cmp    0x24(%esp),%eax
  73:	7c da                	jl     4f <main+0x4f>
    for (j = 0; j< 100000; j++) {
      ;
    }
  }

  t2 = uptime();
  75:	e8 76 03 00 00       	call   3f0 <uptime>
  7a:	89 44 24 1c          	mov    %eax,0x1c(%esp)

  ticks = getticks();
  7e:	e8 75 03 00 00       	call   3f8 <getticks>
  83:	89 44 24 18          	mov    %eax,0x18(%esp)
  printf(1, "ticks = %d\n", ticks);
  87:	8b 44 24 18          	mov    0x18(%esp),%eax
  8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  8f:	c7 44 24 04 df 08 00 	movl   $0x8df,0x4(%esp)
  96:	00 
  97:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  9e:	e8 62 04 00 00       	call   505 <printf>
  printf(1, "t1    = %d\n", t1);
  a3:	8b 44 24 20          	mov    0x20(%esp),%eax
  a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  ab:	c7 44 24 04 eb 08 00 	movl   $0x8eb,0x4(%esp)
  b2:	00 
  b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  ba:	e8 46 04 00 00       	call   505 <printf>
  printf(1, "t2    = %d\n", t2);
  bf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  c3:	89 44 24 08          	mov    %eax,0x8(%esp)
  c7:	c7 44 24 04 f7 08 00 	movl   $0x8f7,0x4(%esp)
  ce:	00 
  cf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  d6:	e8 2a 04 00 00       	call   505 <printf>
  printf(1, "t2-t1 = %d\n", t2-t1);    
  db:	8b 44 24 20          	mov    0x20(%esp),%eax
  df:	8b 54 24 1c          	mov    0x1c(%esp),%edx
  e3:	29 c2                	sub    %eax,%edx
  e5:	89 d0                	mov    %edx,%eax
  e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  eb:	c7 44 24 04 03 09 00 	movl   $0x903,0x4(%esp)
  f2:	00 
  f3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  fa:	e8 06 04 00 00       	call   505 <printf>

  exit();
  ff:	e8 54 02 00 00       	call   358 <exit>

00000104 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 104:	55                   	push   %ebp
 105:	89 e5                	mov    %esp,%ebp
 107:	57                   	push   %edi
 108:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 109:	8b 4d 08             	mov    0x8(%ebp),%ecx
 10c:	8b 55 10             	mov    0x10(%ebp),%edx
 10f:	8b 45 0c             	mov    0xc(%ebp),%eax
 112:	89 cb                	mov    %ecx,%ebx
 114:	89 df                	mov    %ebx,%edi
 116:	89 d1                	mov    %edx,%ecx
 118:	fc                   	cld    
 119:	f3 aa                	rep stos %al,%es:(%edi)
 11b:	89 ca                	mov    %ecx,%edx
 11d:	89 fb                	mov    %edi,%ebx
 11f:	89 5d 08             	mov    %ebx,0x8(%ebp)
 122:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 125:	5b                   	pop    %ebx
 126:	5f                   	pop    %edi
 127:	5d                   	pop    %ebp
 128:	c3                   	ret    

00000129 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 129:	55                   	push   %ebp
 12a:	89 e5                	mov    %esp,%ebp
 12c:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 12f:	8b 45 08             	mov    0x8(%ebp),%eax
 132:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 135:	90                   	nop
 136:	8b 45 08             	mov    0x8(%ebp),%eax
 139:	8d 50 01             	lea    0x1(%eax),%edx
 13c:	89 55 08             	mov    %edx,0x8(%ebp)
 13f:	8b 55 0c             	mov    0xc(%ebp),%edx
 142:	8d 4a 01             	lea    0x1(%edx),%ecx
 145:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 148:	8a 12                	mov    (%edx),%dl
 14a:	88 10                	mov    %dl,(%eax)
 14c:	8a 00                	mov    (%eax),%al
 14e:	84 c0                	test   %al,%al
 150:	75 e4                	jne    136 <strcpy+0xd>
    ;
  return os;
 152:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 155:	c9                   	leave  
 156:	c3                   	ret    

00000157 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 157:	55                   	push   %ebp
 158:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 15a:	eb 06                	jmp    162 <strcmp+0xb>
    p++, q++;
 15c:	ff 45 08             	incl   0x8(%ebp)
 15f:	ff 45 0c             	incl   0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 162:	8b 45 08             	mov    0x8(%ebp),%eax
 165:	8a 00                	mov    (%eax),%al
 167:	84 c0                	test   %al,%al
 169:	74 0e                	je     179 <strcmp+0x22>
 16b:	8b 45 08             	mov    0x8(%ebp),%eax
 16e:	8a 10                	mov    (%eax),%dl
 170:	8b 45 0c             	mov    0xc(%ebp),%eax
 173:	8a 00                	mov    (%eax),%al
 175:	38 c2                	cmp    %al,%dl
 177:	74 e3                	je     15c <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 179:	8b 45 08             	mov    0x8(%ebp),%eax
 17c:	8a 00                	mov    (%eax),%al
 17e:	0f b6 d0             	movzbl %al,%edx
 181:	8b 45 0c             	mov    0xc(%ebp),%eax
 184:	8a 00                	mov    (%eax),%al
 186:	0f b6 c0             	movzbl %al,%eax
 189:	29 c2                	sub    %eax,%edx
 18b:	89 d0                	mov    %edx,%eax
}
 18d:	5d                   	pop    %ebp
 18e:	c3                   	ret    

0000018f <strlen>:

uint
strlen(char *s)
{
 18f:	55                   	push   %ebp
 190:	89 e5                	mov    %esp,%ebp
 192:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 195:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 19c:	eb 03                	jmp    1a1 <strlen+0x12>
 19e:	ff 45 fc             	incl   -0x4(%ebp)
 1a1:	8b 55 fc             	mov    -0x4(%ebp),%edx
 1a4:	8b 45 08             	mov    0x8(%ebp),%eax
 1a7:	01 d0                	add    %edx,%eax
 1a9:	8a 00                	mov    (%eax),%al
 1ab:	84 c0                	test   %al,%al
 1ad:	75 ef                	jne    19e <strlen+0xf>
    ;
  return n;
 1af:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 1b2:	c9                   	leave  
 1b3:	c3                   	ret    

000001b4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1b4:	55                   	push   %ebp
 1b5:	89 e5                	mov    %esp,%ebp
 1b7:	83 ec 0c             	sub    $0xc,%esp
  stosb(dst, c, n);
 1ba:	8b 45 10             	mov    0x10(%ebp),%eax
 1bd:	89 44 24 08          	mov    %eax,0x8(%esp)
 1c1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1c4:	89 44 24 04          	mov    %eax,0x4(%esp)
 1c8:	8b 45 08             	mov    0x8(%ebp),%eax
 1cb:	89 04 24             	mov    %eax,(%esp)
 1ce:	e8 31 ff ff ff       	call   104 <stosb>
  return dst;
 1d3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1d6:	c9                   	leave  
 1d7:	c3                   	ret    

000001d8 <strchr>:

char*
strchr(const char *s, char c)
{
 1d8:	55                   	push   %ebp
 1d9:	89 e5                	mov    %esp,%ebp
 1db:	83 ec 04             	sub    $0x4,%esp
 1de:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e1:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 1e4:	eb 12                	jmp    1f8 <strchr+0x20>
    if(*s == c)
 1e6:	8b 45 08             	mov    0x8(%ebp),%eax
 1e9:	8a 00                	mov    (%eax),%al
 1eb:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1ee:	75 05                	jne    1f5 <strchr+0x1d>
      return (char*)s;
 1f0:	8b 45 08             	mov    0x8(%ebp),%eax
 1f3:	eb 11                	jmp    206 <strchr+0x2e>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1f5:	ff 45 08             	incl   0x8(%ebp)
 1f8:	8b 45 08             	mov    0x8(%ebp),%eax
 1fb:	8a 00                	mov    (%eax),%al
 1fd:	84 c0                	test   %al,%al
 1ff:	75 e5                	jne    1e6 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 201:	b8 00 00 00 00       	mov    $0x0,%eax
}
 206:	c9                   	leave  
 207:	c3                   	ret    

00000208 <gets>:

char*
gets(char *buf, int max)
{
 208:	55                   	push   %ebp
 209:	89 e5                	mov    %esp,%ebp
 20b:	83 ec 28             	sub    $0x28,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 215:	eb 49                	jmp    260 <gets+0x58>
    cc = read(0, &c, 1);
 217:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 21e:	00 
 21f:	8d 45 ef             	lea    -0x11(%ebp),%eax
 222:	89 44 24 04          	mov    %eax,0x4(%esp)
 226:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
 22d:	e8 3e 01 00 00       	call   370 <read>
 232:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 235:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 239:	7f 02                	jg     23d <gets+0x35>
      break;
 23b:	eb 2c                	jmp    269 <gets+0x61>
    buf[i++] = c;
 23d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 240:	8d 50 01             	lea    0x1(%eax),%edx
 243:	89 55 f4             	mov    %edx,-0xc(%ebp)
 246:	89 c2                	mov    %eax,%edx
 248:	8b 45 08             	mov    0x8(%ebp),%eax
 24b:	01 c2                	add    %eax,%edx
 24d:	8a 45 ef             	mov    -0x11(%ebp),%al
 250:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 252:	8a 45 ef             	mov    -0x11(%ebp),%al
 255:	3c 0a                	cmp    $0xa,%al
 257:	74 10                	je     269 <gets+0x61>
 259:	8a 45 ef             	mov    -0x11(%ebp),%al
 25c:	3c 0d                	cmp    $0xd,%al
 25e:	74 09                	je     269 <gets+0x61>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 260:	8b 45 f4             	mov    -0xc(%ebp),%eax
 263:	40                   	inc    %eax
 264:	3b 45 0c             	cmp    0xc(%ebp),%eax
 267:	7c ae                	jl     217 <gets+0xf>
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 269:	8b 55 f4             	mov    -0xc(%ebp),%edx
 26c:	8b 45 08             	mov    0x8(%ebp),%eax
 26f:	01 d0                	add    %edx,%eax
 271:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 274:	8b 45 08             	mov    0x8(%ebp),%eax
}
 277:	c9                   	leave  
 278:	c3                   	ret    

00000279 <stat>:

int
stat(char *n, struct stat *st)
{
 279:	55                   	push   %ebp
 27a:	89 e5                	mov    %esp,%ebp
 27c:	83 ec 28             	sub    $0x28,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 27f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
 286:	00 
 287:	8b 45 08             	mov    0x8(%ebp),%eax
 28a:	89 04 24             	mov    %eax,(%esp)
 28d:	e8 06 01 00 00       	call   398 <open>
 292:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 295:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 299:	79 07                	jns    2a2 <stat+0x29>
    return -1;
 29b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 2a0:	eb 23                	jmp    2c5 <stat+0x4c>
  r = fstat(fd, st);
 2a2:	8b 45 0c             	mov    0xc(%ebp),%eax
 2a5:	89 44 24 04          	mov    %eax,0x4(%esp)
 2a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ac:	89 04 24             	mov    %eax,(%esp)
 2af:	e8 fc 00 00 00       	call   3b0 <fstat>
 2b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 2b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 2ba:	89 04 24             	mov    %eax,(%esp)
 2bd:	e8 be 00 00 00       	call   380 <close>
  return r;
 2c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 2c5:	c9                   	leave  
 2c6:	c3                   	ret    

000002c7 <atoi>:

int
atoi(const char *s)
{
 2c7:	55                   	push   %ebp
 2c8:	89 e5                	mov    %esp,%ebp
 2ca:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 2cd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 2d4:	eb 24                	jmp    2fa <atoi+0x33>
    n = n*10 + *s++ - '0';
 2d6:	8b 55 fc             	mov    -0x4(%ebp),%edx
 2d9:	89 d0                	mov    %edx,%eax
 2db:	c1 e0 02             	shl    $0x2,%eax
 2de:	01 d0                	add    %edx,%eax
 2e0:	01 c0                	add    %eax,%eax
 2e2:	89 c1                	mov    %eax,%ecx
 2e4:	8b 45 08             	mov    0x8(%ebp),%eax
 2e7:	8d 50 01             	lea    0x1(%eax),%edx
 2ea:	89 55 08             	mov    %edx,0x8(%ebp)
 2ed:	8a 00                	mov    (%eax),%al
 2ef:	0f be c0             	movsbl %al,%eax
 2f2:	01 c8                	add    %ecx,%eax
 2f4:	83 e8 30             	sub    $0x30,%eax
 2f7:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2fa:	8b 45 08             	mov    0x8(%ebp),%eax
 2fd:	8a 00                	mov    (%eax),%al
 2ff:	3c 2f                	cmp    $0x2f,%al
 301:	7e 09                	jle    30c <atoi+0x45>
 303:	8b 45 08             	mov    0x8(%ebp),%eax
 306:	8a 00                	mov    (%eax),%al
 308:	3c 39                	cmp    $0x39,%al
 30a:	7e ca                	jle    2d6 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 30c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 30f:	c9                   	leave  
 310:	c3                   	ret    

00000311 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 311:	55                   	push   %ebp
 312:	89 e5                	mov    %esp,%ebp
 314:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 317:	8b 45 08             	mov    0x8(%ebp),%eax
 31a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 31d:	8b 45 0c             	mov    0xc(%ebp),%eax
 320:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 323:	eb 16                	jmp    33b <memmove+0x2a>
    *dst++ = *src++;
 325:	8b 45 fc             	mov    -0x4(%ebp),%eax
 328:	8d 50 01             	lea    0x1(%eax),%edx
 32b:	89 55 fc             	mov    %edx,-0x4(%ebp)
 32e:	8b 55 f8             	mov    -0x8(%ebp),%edx
 331:	8d 4a 01             	lea    0x1(%edx),%ecx
 334:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 337:	8a 12                	mov    (%edx),%dl
 339:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 33b:	8b 45 10             	mov    0x10(%ebp),%eax
 33e:	8d 50 ff             	lea    -0x1(%eax),%edx
 341:	89 55 10             	mov    %edx,0x10(%ebp)
 344:	85 c0                	test   %eax,%eax
 346:	7f dd                	jg     325 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 348:	8b 45 08             	mov    0x8(%ebp),%eax
}
 34b:	c9                   	leave  
 34c:	c3                   	ret    
 34d:	90                   	nop
 34e:	90                   	nop
 34f:	90                   	nop

00000350 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 350:	b8 01 00 00 00       	mov    $0x1,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <exit>:
SYSCALL(exit)
 358:	b8 02 00 00 00       	mov    $0x2,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <wait>:
SYSCALL(wait)
 360:	b8 03 00 00 00       	mov    $0x3,%eax
 365:	cd 40                	int    $0x40
 367:	c3                   	ret    

00000368 <pipe>:
SYSCALL(pipe)
 368:	b8 04 00 00 00       	mov    $0x4,%eax
 36d:	cd 40                	int    $0x40
 36f:	c3                   	ret    

00000370 <read>:
SYSCALL(read)
 370:	b8 05 00 00 00       	mov    $0x5,%eax
 375:	cd 40                	int    $0x40
 377:	c3                   	ret    

00000378 <write>:
SYSCALL(write)
 378:	b8 10 00 00 00       	mov    $0x10,%eax
 37d:	cd 40                	int    $0x40
 37f:	c3                   	ret    

00000380 <close>:
SYSCALL(close)
 380:	b8 15 00 00 00       	mov    $0x15,%eax
 385:	cd 40                	int    $0x40
 387:	c3                   	ret    

00000388 <kill>:
SYSCALL(kill)
 388:	b8 06 00 00 00       	mov    $0x6,%eax
 38d:	cd 40                	int    $0x40
 38f:	c3                   	ret    

00000390 <exec>:
SYSCALL(exec)
 390:	b8 07 00 00 00       	mov    $0x7,%eax
 395:	cd 40                	int    $0x40
 397:	c3                   	ret    

00000398 <open>:
SYSCALL(open)
 398:	b8 0f 00 00 00       	mov    $0xf,%eax
 39d:	cd 40                	int    $0x40
 39f:	c3                   	ret    

000003a0 <mknod>:
SYSCALL(mknod)
 3a0:	b8 11 00 00 00       	mov    $0x11,%eax
 3a5:	cd 40                	int    $0x40
 3a7:	c3                   	ret    

000003a8 <unlink>:
SYSCALL(unlink)
 3a8:	b8 12 00 00 00       	mov    $0x12,%eax
 3ad:	cd 40                	int    $0x40
 3af:	c3                   	ret    

000003b0 <fstat>:
SYSCALL(fstat)
 3b0:	b8 08 00 00 00       	mov    $0x8,%eax
 3b5:	cd 40                	int    $0x40
 3b7:	c3                   	ret    

000003b8 <link>:
SYSCALL(link)
 3b8:	b8 13 00 00 00       	mov    $0x13,%eax
 3bd:	cd 40                	int    $0x40
 3bf:	c3                   	ret    

000003c0 <mkdir>:
SYSCALL(mkdir)
 3c0:	b8 14 00 00 00       	mov    $0x14,%eax
 3c5:	cd 40                	int    $0x40
 3c7:	c3                   	ret    

000003c8 <chdir>:
SYSCALL(chdir)
 3c8:	b8 09 00 00 00       	mov    $0x9,%eax
 3cd:	cd 40                	int    $0x40
 3cf:	c3                   	ret    

000003d0 <dup>:
SYSCALL(dup)
 3d0:	b8 0a 00 00 00       	mov    $0xa,%eax
 3d5:	cd 40                	int    $0x40
 3d7:	c3                   	ret    

000003d8 <getpid>:
SYSCALL(getpid)
 3d8:	b8 0b 00 00 00       	mov    $0xb,%eax
 3dd:	cd 40                	int    $0x40
 3df:	c3                   	ret    

000003e0 <sbrk>:
SYSCALL(sbrk)
 3e0:	b8 0c 00 00 00       	mov    $0xc,%eax
 3e5:	cd 40                	int    $0x40
 3e7:	c3                   	ret    

000003e8 <sleep>:
SYSCALL(sleep)
 3e8:	b8 0d 00 00 00       	mov    $0xd,%eax
 3ed:	cd 40                	int    $0x40
 3ef:	c3                   	ret    

000003f0 <uptime>:
SYSCALL(uptime)
 3f0:	b8 0e 00 00 00       	mov    $0xe,%eax
 3f5:	cd 40                	int    $0x40
 3f7:	c3                   	ret    

000003f8 <getticks>:
SYSCALL(getticks)
 3f8:	b8 16 00 00 00       	mov    $0x16,%eax
 3fd:	cd 40                	int    $0x40
 3ff:	c3                   	ret    

00000400 <ccreate>:
SYSCALL(ccreate)
 400:	b8 17 00 00 00       	mov    $0x17,%eax
 405:	cd 40                	int    $0x40
 407:	c3                   	ret    

00000408 <cstart>:
SYSCALL(cstart)
 408:	b8 19 00 00 00       	mov    $0x19,%eax
 40d:	cd 40                	int    $0x40
 40f:	c3                   	ret    

00000410 <cstop>:
SYSCALL(cstop)
 410:	b8 18 00 00 00       	mov    $0x18,%eax
 415:	cd 40                	int    $0x40
 417:	c3                   	ret    

00000418 <cpause>:
SYSCALL(cpause)
 418:	b8 1b 00 00 00       	mov    $0x1b,%eax
 41d:	cd 40                	int    $0x40
 41f:	c3                   	ret    

00000420 <cinfo>:
SYSCALL(cinfo)
 420:	b8 1a 00 00 00       	mov    $0x1a,%eax
 425:	cd 40                	int    $0x40
 427:	c3                   	ret    

00000428 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 428:	55                   	push   %ebp
 429:	89 e5                	mov    %esp,%ebp
 42b:	83 ec 18             	sub    $0x18,%esp
 42e:	8b 45 0c             	mov    0xc(%ebp),%eax
 431:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 434:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
 43b:	00 
 43c:	8d 45 f4             	lea    -0xc(%ebp),%eax
 43f:	89 44 24 04          	mov    %eax,0x4(%esp)
 443:	8b 45 08             	mov    0x8(%ebp),%eax
 446:	89 04 24             	mov    %eax,(%esp)
 449:	e8 2a ff ff ff       	call   378 <write>
}
 44e:	c9                   	leave  
 44f:	c3                   	ret    

00000450 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 450:	55                   	push   %ebp
 451:	89 e5                	mov    %esp,%ebp
 453:	56                   	push   %esi
 454:	53                   	push   %ebx
 455:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 458:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 45f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 463:	74 17                	je     47c <printint+0x2c>
 465:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 469:	79 11                	jns    47c <printint+0x2c>
    neg = 1;
 46b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 472:	8b 45 0c             	mov    0xc(%ebp),%eax
 475:	f7 d8                	neg    %eax
 477:	89 45 ec             	mov    %eax,-0x14(%ebp)
 47a:	eb 06                	jmp    482 <printint+0x32>
  } else {
    x = xx;
 47c:	8b 45 0c             	mov    0xc(%ebp),%eax
 47f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 482:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 489:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 48c:	8d 41 01             	lea    0x1(%ecx),%eax
 48f:	89 45 f4             	mov    %eax,-0xc(%ebp)
 492:	8b 5d 10             	mov    0x10(%ebp),%ebx
 495:	8b 45 ec             	mov    -0x14(%ebp),%eax
 498:	ba 00 00 00 00       	mov    $0x0,%edx
 49d:	f7 f3                	div    %ebx
 49f:	89 d0                	mov    %edx,%eax
 4a1:	8a 80 5c 0b 00 00    	mov    0xb5c(%eax),%al
 4a7:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 4ab:	8b 75 10             	mov    0x10(%ebp),%esi
 4ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
 4b1:	ba 00 00 00 00       	mov    $0x0,%edx
 4b6:	f7 f6                	div    %esi
 4b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 4bb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4bf:	75 c8                	jne    489 <printint+0x39>
  if(neg)
 4c1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 4c5:	74 10                	je     4d7 <printint+0x87>
    buf[i++] = '-';
 4c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ca:	8d 50 01             	lea    0x1(%eax),%edx
 4cd:	89 55 f4             	mov    %edx,-0xc(%ebp)
 4d0:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 4d5:	eb 1e                	jmp    4f5 <printint+0xa5>
 4d7:	eb 1c                	jmp    4f5 <printint+0xa5>
    putc(fd, buf[i]);
 4d9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 4dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4df:	01 d0                	add    %edx,%eax
 4e1:	8a 00                	mov    (%eax),%al
 4e3:	0f be c0             	movsbl %al,%eax
 4e6:	89 44 24 04          	mov    %eax,0x4(%esp)
 4ea:	8b 45 08             	mov    0x8(%ebp),%eax
 4ed:	89 04 24             	mov    %eax,(%esp)
 4f0:	e8 33 ff ff ff       	call   428 <putc>
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 4f5:	ff 4d f4             	decl   -0xc(%ebp)
 4f8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4fc:	79 db                	jns    4d9 <printint+0x89>
    putc(fd, buf[i]);
}
 4fe:	83 c4 30             	add    $0x30,%esp
 501:	5b                   	pop    %ebx
 502:	5e                   	pop    %esi
 503:	5d                   	pop    %ebp
 504:	c3                   	ret    

00000505 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 505:	55                   	push   %ebp
 506:	89 e5                	mov    %esp,%ebp
 508:	83 ec 38             	sub    $0x38,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 50b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 512:	8d 45 0c             	lea    0xc(%ebp),%eax
 515:	83 c0 04             	add    $0x4,%eax
 518:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 51b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 522:	e9 77 01 00 00       	jmp    69e <printf+0x199>
    c = fmt[i] & 0xff;
 527:	8b 55 0c             	mov    0xc(%ebp),%edx
 52a:	8b 45 f0             	mov    -0x10(%ebp),%eax
 52d:	01 d0                	add    %edx,%eax
 52f:	8a 00                	mov    (%eax),%al
 531:	0f be c0             	movsbl %al,%eax
 534:	25 ff 00 00 00       	and    $0xff,%eax
 539:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 53c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 540:	75 2c                	jne    56e <printf+0x69>
      if(c == '%'){
 542:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 546:	75 0c                	jne    554 <printf+0x4f>
        state = '%';
 548:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 54f:	e9 47 01 00 00       	jmp    69b <printf+0x196>
      } else {
        putc(fd, c);
 554:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 557:	0f be c0             	movsbl %al,%eax
 55a:	89 44 24 04          	mov    %eax,0x4(%esp)
 55e:	8b 45 08             	mov    0x8(%ebp),%eax
 561:	89 04 24             	mov    %eax,(%esp)
 564:	e8 bf fe ff ff       	call   428 <putc>
 569:	e9 2d 01 00 00       	jmp    69b <printf+0x196>
      }
    } else if(state == '%'){
 56e:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 572:	0f 85 23 01 00 00    	jne    69b <printf+0x196>
      if(c == 'd'){
 578:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 57c:	75 2d                	jne    5ab <printf+0xa6>
        printint(fd, *ap, 10, 1);
 57e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 581:	8b 00                	mov    (%eax),%eax
 583:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
 58a:	00 
 58b:	c7 44 24 08 0a 00 00 	movl   $0xa,0x8(%esp)
 592:	00 
 593:	89 44 24 04          	mov    %eax,0x4(%esp)
 597:	8b 45 08             	mov    0x8(%ebp),%eax
 59a:	89 04 24             	mov    %eax,(%esp)
 59d:	e8 ae fe ff ff       	call   450 <printint>
        ap++;
 5a2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5a6:	e9 e9 00 00 00       	jmp    694 <printf+0x18f>
      } else if(c == 'x' || c == 'p'){
 5ab:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 5af:	74 06                	je     5b7 <printf+0xb2>
 5b1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 5b5:	75 2d                	jne    5e4 <printf+0xdf>
        printint(fd, *ap, 16, 0);
 5b7:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ba:	8b 00                	mov    (%eax),%eax
 5bc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
 5c3:	00 
 5c4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
 5cb:	00 
 5cc:	89 44 24 04          	mov    %eax,0x4(%esp)
 5d0:	8b 45 08             	mov    0x8(%ebp),%eax
 5d3:	89 04 24             	mov    %eax,(%esp)
 5d6:	e8 75 fe ff ff       	call   450 <printint>
        ap++;
 5db:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 5df:	e9 b0 00 00 00       	jmp    694 <printf+0x18f>
      } else if(c == 's'){
 5e4:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 5e8:	75 42                	jne    62c <printf+0x127>
        s = (char*)*ap;
 5ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
 5ed:	8b 00                	mov    (%eax),%eax
 5ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 5f2:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 5f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 5fa:	75 09                	jne    605 <printf+0x100>
          s = "(null)";
 5fc:	c7 45 f4 0f 09 00 00 	movl   $0x90f,-0xc(%ebp)
        while(*s != 0){
 603:	eb 1c                	jmp    621 <printf+0x11c>
 605:	eb 1a                	jmp    621 <printf+0x11c>
          putc(fd, *s);
 607:	8b 45 f4             	mov    -0xc(%ebp),%eax
 60a:	8a 00                	mov    (%eax),%al
 60c:	0f be c0             	movsbl %al,%eax
 60f:	89 44 24 04          	mov    %eax,0x4(%esp)
 613:	8b 45 08             	mov    0x8(%ebp),%eax
 616:	89 04 24             	mov    %eax,(%esp)
 619:	e8 0a fe ff ff       	call   428 <putc>
          s++;
 61e:	ff 45 f4             	incl   -0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 621:	8b 45 f4             	mov    -0xc(%ebp),%eax
 624:	8a 00                	mov    (%eax),%al
 626:	84 c0                	test   %al,%al
 628:	75 dd                	jne    607 <printf+0x102>
 62a:	eb 68                	jmp    694 <printf+0x18f>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 62c:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 630:	75 1d                	jne    64f <printf+0x14a>
        putc(fd, *ap);
 632:	8b 45 e8             	mov    -0x18(%ebp),%eax
 635:	8b 00                	mov    (%eax),%eax
 637:	0f be c0             	movsbl %al,%eax
 63a:	89 44 24 04          	mov    %eax,0x4(%esp)
 63e:	8b 45 08             	mov    0x8(%ebp),%eax
 641:	89 04 24             	mov    %eax,(%esp)
 644:	e8 df fd ff ff       	call   428 <putc>
        ap++;
 649:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 64d:	eb 45                	jmp    694 <printf+0x18f>
      } else if(c == '%'){
 64f:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 653:	75 17                	jne    66c <printf+0x167>
        putc(fd, c);
 655:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 658:	0f be c0             	movsbl %al,%eax
 65b:	89 44 24 04          	mov    %eax,0x4(%esp)
 65f:	8b 45 08             	mov    0x8(%ebp),%eax
 662:	89 04 24             	mov    %eax,(%esp)
 665:	e8 be fd ff ff       	call   428 <putc>
 66a:	eb 28                	jmp    694 <printf+0x18f>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 66c:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
 673:	00 
 674:	8b 45 08             	mov    0x8(%ebp),%eax
 677:	89 04 24             	mov    %eax,(%esp)
 67a:	e8 a9 fd ff ff       	call   428 <putc>
        putc(fd, c);
 67f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 682:	0f be c0             	movsbl %al,%eax
 685:	89 44 24 04          	mov    %eax,0x4(%esp)
 689:	8b 45 08             	mov    0x8(%ebp),%eax
 68c:	89 04 24             	mov    %eax,(%esp)
 68f:	e8 94 fd ff ff       	call   428 <putc>
      }
      state = 0;
 694:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 69b:	ff 45 f0             	incl   -0x10(%ebp)
 69e:	8b 55 0c             	mov    0xc(%ebp),%edx
 6a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6a4:	01 d0                	add    %edx,%eax
 6a6:	8a 00                	mov    (%eax),%al
 6a8:	84 c0                	test   %al,%al
 6aa:	0f 85 77 fe ff ff    	jne    527 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 6b0:	c9                   	leave  
 6b1:	c3                   	ret    
 6b2:	90                   	nop
 6b3:	90                   	nop

000006b4 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b4:	55                   	push   %ebp
 6b5:	89 e5                	mov    %esp,%ebp
 6b7:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ba:	8b 45 08             	mov    0x8(%ebp),%eax
 6bd:	83 e8 08             	sub    $0x8,%eax
 6c0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6c3:	a1 78 0b 00 00       	mov    0xb78,%eax
 6c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6cb:	eb 24                	jmp    6f1 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d0:	8b 00                	mov    (%eax),%eax
 6d2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6d5:	77 12                	ja     6e9 <free+0x35>
 6d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6da:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6dd:	77 24                	ja     703 <free+0x4f>
 6df:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6e2:	8b 00                	mov    (%eax),%eax
 6e4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6e7:	77 1a                	ja     703 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ec:	8b 00                	mov    (%eax),%eax
 6ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
 6f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6f4:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 6f7:	76 d4                	jbe    6cd <free+0x19>
 6f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6fc:	8b 00                	mov    (%eax),%eax
 6fe:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 701:	76 ca                	jbe    6cd <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 703:	8b 45 f8             	mov    -0x8(%ebp),%eax
 706:	8b 40 04             	mov    0x4(%eax),%eax
 709:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 710:	8b 45 f8             	mov    -0x8(%ebp),%eax
 713:	01 c2                	add    %eax,%edx
 715:	8b 45 fc             	mov    -0x4(%ebp),%eax
 718:	8b 00                	mov    (%eax),%eax
 71a:	39 c2                	cmp    %eax,%edx
 71c:	75 24                	jne    742 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 71e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 721:	8b 50 04             	mov    0x4(%eax),%edx
 724:	8b 45 fc             	mov    -0x4(%ebp),%eax
 727:	8b 00                	mov    (%eax),%eax
 729:	8b 40 04             	mov    0x4(%eax),%eax
 72c:	01 c2                	add    %eax,%edx
 72e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 731:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 734:	8b 45 fc             	mov    -0x4(%ebp),%eax
 737:	8b 00                	mov    (%eax),%eax
 739:	8b 10                	mov    (%eax),%edx
 73b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 73e:	89 10                	mov    %edx,(%eax)
 740:	eb 0a                	jmp    74c <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 742:	8b 45 fc             	mov    -0x4(%ebp),%eax
 745:	8b 10                	mov    (%eax),%edx
 747:	8b 45 f8             	mov    -0x8(%ebp),%eax
 74a:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 74c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 74f:	8b 40 04             	mov    0x4(%eax),%eax
 752:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 759:	8b 45 fc             	mov    -0x4(%ebp),%eax
 75c:	01 d0                	add    %edx,%eax
 75e:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 761:	75 20                	jne    783 <free+0xcf>
    p->s.size += bp->s.size;
 763:	8b 45 fc             	mov    -0x4(%ebp),%eax
 766:	8b 50 04             	mov    0x4(%eax),%edx
 769:	8b 45 f8             	mov    -0x8(%ebp),%eax
 76c:	8b 40 04             	mov    0x4(%eax),%eax
 76f:	01 c2                	add    %eax,%edx
 771:	8b 45 fc             	mov    -0x4(%ebp),%eax
 774:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 777:	8b 45 f8             	mov    -0x8(%ebp),%eax
 77a:	8b 10                	mov    (%eax),%edx
 77c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 77f:	89 10                	mov    %edx,(%eax)
 781:	eb 08                	jmp    78b <free+0xd7>
  } else
    p->s.ptr = bp;
 783:	8b 45 fc             	mov    -0x4(%ebp),%eax
 786:	8b 55 f8             	mov    -0x8(%ebp),%edx
 789:	89 10                	mov    %edx,(%eax)
  freep = p;
 78b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 78e:	a3 78 0b 00 00       	mov    %eax,0xb78
}
 793:	c9                   	leave  
 794:	c3                   	ret    

00000795 <morecore>:

static Header*
morecore(uint nu)
{
 795:	55                   	push   %ebp
 796:	89 e5                	mov    %esp,%ebp
 798:	83 ec 28             	sub    $0x28,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 79b:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 7a2:	77 07                	ja     7ab <morecore+0x16>
    nu = 4096;
 7a4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 7ab:	8b 45 08             	mov    0x8(%ebp),%eax
 7ae:	c1 e0 03             	shl    $0x3,%eax
 7b1:	89 04 24             	mov    %eax,(%esp)
 7b4:	e8 27 fc ff ff       	call   3e0 <sbrk>
 7b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 7bc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 7c0:	75 07                	jne    7c9 <morecore+0x34>
    return 0;
 7c2:	b8 00 00 00 00       	mov    $0x0,%eax
 7c7:	eb 22                	jmp    7eb <morecore+0x56>
  hp = (Header*)p;
 7c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 7cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d2:	8b 55 08             	mov    0x8(%ebp),%edx
 7d5:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 7d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7db:	83 c0 08             	add    $0x8,%eax
 7de:	89 04 24             	mov    %eax,(%esp)
 7e1:	e8 ce fe ff ff       	call   6b4 <free>
  return freep;
 7e6:	a1 78 0b 00 00       	mov    0xb78,%eax
}
 7eb:	c9                   	leave  
 7ec:	c3                   	ret    

000007ed <malloc>:

void*
malloc(uint nbytes)
{
 7ed:	55                   	push   %ebp
 7ee:	89 e5                	mov    %esp,%ebp
 7f0:	83 ec 28             	sub    $0x28,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f3:	8b 45 08             	mov    0x8(%ebp),%eax
 7f6:	83 c0 07             	add    $0x7,%eax
 7f9:	c1 e8 03             	shr    $0x3,%eax
 7fc:	40                   	inc    %eax
 7fd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 800:	a1 78 0b 00 00       	mov    0xb78,%eax
 805:	89 45 f0             	mov    %eax,-0x10(%ebp)
 808:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 80c:	75 23                	jne    831 <malloc+0x44>
    base.s.ptr = freep = prevp = &base;
 80e:	c7 45 f0 70 0b 00 00 	movl   $0xb70,-0x10(%ebp)
 815:	8b 45 f0             	mov    -0x10(%ebp),%eax
 818:	a3 78 0b 00 00       	mov    %eax,0xb78
 81d:	a1 78 0b 00 00       	mov    0xb78,%eax
 822:	a3 70 0b 00 00       	mov    %eax,0xb70
    base.s.size = 0;
 827:	c7 05 74 0b 00 00 00 	movl   $0x0,0xb74
 82e:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 831:	8b 45 f0             	mov    -0x10(%ebp),%eax
 834:	8b 00                	mov    (%eax),%eax
 836:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 839:	8b 45 f4             	mov    -0xc(%ebp),%eax
 83c:	8b 40 04             	mov    0x4(%eax),%eax
 83f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 842:	72 4d                	jb     891 <malloc+0xa4>
      if(p->s.size == nunits)
 844:	8b 45 f4             	mov    -0xc(%ebp),%eax
 847:	8b 40 04             	mov    0x4(%eax),%eax
 84a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 84d:	75 0c                	jne    85b <malloc+0x6e>
        prevp->s.ptr = p->s.ptr;
 84f:	8b 45 f4             	mov    -0xc(%ebp),%eax
 852:	8b 10                	mov    (%eax),%edx
 854:	8b 45 f0             	mov    -0x10(%ebp),%eax
 857:	89 10                	mov    %edx,(%eax)
 859:	eb 26                	jmp    881 <malloc+0x94>
      else {
        p->s.size -= nunits;
 85b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 85e:	8b 40 04             	mov    0x4(%eax),%eax
 861:	2b 45 ec             	sub    -0x14(%ebp),%eax
 864:	89 c2                	mov    %eax,%edx
 866:	8b 45 f4             	mov    -0xc(%ebp),%eax
 869:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 86c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 86f:	8b 40 04             	mov    0x4(%eax),%eax
 872:	c1 e0 03             	shl    $0x3,%eax
 875:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 878:	8b 45 f4             	mov    -0xc(%ebp),%eax
 87b:	8b 55 ec             	mov    -0x14(%ebp),%edx
 87e:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 881:	8b 45 f0             	mov    -0x10(%ebp),%eax
 884:	a3 78 0b 00 00       	mov    %eax,0xb78
      return (void*)(p + 1);
 889:	8b 45 f4             	mov    -0xc(%ebp),%eax
 88c:	83 c0 08             	add    $0x8,%eax
 88f:	eb 38                	jmp    8c9 <malloc+0xdc>
    }
    if(p == freep)
 891:	a1 78 0b 00 00       	mov    0xb78,%eax
 896:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 899:	75 1b                	jne    8b6 <malloc+0xc9>
      if((p = morecore(nunits)) == 0)
 89b:	8b 45 ec             	mov    -0x14(%ebp),%eax
 89e:	89 04 24             	mov    %eax,(%esp)
 8a1:	e8 ef fe ff ff       	call   795 <morecore>
 8a6:	89 45 f4             	mov    %eax,-0xc(%ebp)
 8a9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 8ad:	75 07                	jne    8b6 <malloc+0xc9>
        return 0;
 8af:	b8 00 00 00 00       	mov    $0x0,%eax
 8b4:	eb 13                	jmp    8c9 <malloc+0xdc>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
 8bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8bf:	8b 00                	mov    (%eax),%eax
 8c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 8c4:	e9 70 ff ff ff       	jmp    839 <malloc+0x4c>
}
 8c9:	c9                   	leave  
 8ca:	c3                   	ret    
