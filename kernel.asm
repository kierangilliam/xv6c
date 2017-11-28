
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 90 c7 10 80       	mov    $0x8010c790,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 02 38 10 80       	mov    $0x80103802,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	c7 44 24 04 b4 87 10 	movl   $0x801087b4,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 a0 c7 10 80 	movl   $0x8010c7a0,(%esp)
80100049:	e8 fc 50 00 00       	call   8010514a <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 ec 0e 11 80 9c 	movl   $0x80110e9c,0x80110eec
80100055:	0e 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 f0 0e 11 80 9c 	movl   $0x80110e9c,0x80110ef0
8010005f:	0e 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 d4 c7 10 80 	movl   $0x8010c7d4,-0xc(%ebp)
80100069:	eb 46                	jmp    801000b1 <binit+0x7d>
    b->next = bcache.head.next;
8010006b:	8b 15 f0 0e 11 80    	mov    0x80110ef0,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 50 9c 0e 11 80 	movl   $0x80110e9c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	83 c0 0c             	add    $0xc,%eax
80100087:	c7 44 24 04 bb 87 10 	movl   $0x801087bb,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 75 4f 00 00       	call   8010500c <initsleeplock>
    bcache.head.next->prev = b;
80100097:	a1 f0 0e 11 80       	mov    0x80110ef0,%eax
8010009c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010009f:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a5:	a3 f0 0e 11 80       	mov    %eax,0x80110ef0

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000aa:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b1:	81 7d f4 9c 0e 11 80 	cmpl   $0x80110e9c,-0xc(%ebp)
801000b8:	72 b1                	jb     8010006b <binit+0x37>
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ba:	c9                   	leave  
801000bb:	c3                   	ret    

801000bc <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000bc:	55                   	push   %ebp
801000bd:	89 e5                	mov    %esp,%ebp
801000bf:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000c2:	c7 04 24 a0 c7 10 80 	movl   $0x8010c7a0,(%esp)
801000c9:	e8 9d 50 00 00       	call   8010516b <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000ce:	a1 f0 0e 11 80       	mov    0x80110ef0,%eax
801000d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d6:	eb 50                	jmp    80100128 <bget+0x6c>
    if(b->dev == dev && b->blockno == blockno){
801000d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000db:	8b 40 04             	mov    0x4(%eax),%eax
801000de:	3b 45 08             	cmp    0x8(%ebp),%eax
801000e1:	75 3c                	jne    8010011f <bget+0x63>
801000e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e6:	8b 40 08             	mov    0x8(%eax),%eax
801000e9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000ec:	75 31                	jne    8010011f <bget+0x63>
      b->refcnt++;
801000ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f1:	8b 40 4c             	mov    0x4c(%eax),%eax
801000f4:	8d 50 01             	lea    0x1(%eax),%edx
801000f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000fa:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
801000fd:	c7 04 24 a0 c7 10 80 	movl   $0x8010c7a0,(%esp)
80100104:	e8 cc 50 00 00       	call   801051d5 <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 2f 4f 00 00       	call   80105046 <acquiresleep>
      return b;
80100117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010011a:	e9 94 00 00 00       	jmp    801001b3 <bget+0xf7>
  struct buf *b;

  acquire(&bcache.lock);

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010011f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100122:	8b 40 54             	mov    0x54(%eax),%eax
80100125:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100128:	81 7d f4 9c 0e 11 80 	cmpl   $0x80110e9c,-0xc(%ebp)
8010012f:	75 a7                	jne    801000d8 <bget+0x1c>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100131:	a1 ec 0e 11 80       	mov    0x80110eec,%eax
80100136:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100139:	eb 63                	jmp    8010019e <bget+0xe2>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010013b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010013e:	8b 40 4c             	mov    0x4c(%eax),%eax
80100141:	85 c0                	test   %eax,%eax
80100143:	75 50                	jne    80100195 <bget+0xd9>
80100145:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100148:	8b 00                	mov    (%eax),%eax
8010014a:	83 e0 04             	and    $0x4,%eax
8010014d:	85 c0                	test   %eax,%eax
8010014f:	75 44                	jne    80100195 <bget+0xd9>
      b->dev = dev;
80100151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100154:	8b 55 08             	mov    0x8(%ebp),%edx
80100157:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	8b 55 0c             	mov    0xc(%ebp),%edx
80100160:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
80100163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100166:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
8010016c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010016f:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
80100176:	c7 04 24 a0 c7 10 80 	movl   $0x8010c7a0,(%esp)
8010017d:	e8 53 50 00 00       	call   801051d5 <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 b6 4e 00 00       	call   80105046 <acquiresleep>
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1e                	jmp    801001b3 <bget+0xf7>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 50             	mov    0x50(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 9c 0e 11 80 	cmpl   $0x80110e9c,-0xc(%ebp)
801001a5:	75 94                	jne    8010013b <bget+0x7f>
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	c7 04 24 c2 87 10 80 	movl   $0x801087c2,(%esp)
801001ae:	e8 a1 03 00 00       	call   80100554 <panic>
}
801001b3:	c9                   	leave  
801001b4:	c3                   	ret    

801001b5 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b5:	55                   	push   %ebp
801001b6:	89 e5                	mov    %esp,%ebp
801001b8:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801001be:	89 44 24 04          	mov    %eax,0x4(%esp)
801001c2:	8b 45 08             	mov    0x8(%ebp),%eax
801001c5:	89 04 24             	mov    %eax,(%esp)
801001c8:	e8 ef fe ff ff       	call   801000bc <bget>
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0b                	jne    801001e7 <bread+0x32>
    iderw(b);
801001dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001df:	89 04 24             	mov    %eax,(%esp)
801001e2:	e8 52 27 00 00       	call   80102939 <iderw>
  }
  return b;
801001e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ea:	c9                   	leave  
801001eb:	c3                   	ret    

801001ec <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001ec:	55                   	push   %ebp
801001ed:	89 e5                	mov    %esp,%ebp
801001ef:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
801001f2:	8b 45 08             	mov    0x8(%ebp),%eax
801001f5:	83 c0 0c             	add    $0xc,%eax
801001f8:	89 04 24             	mov    %eax,(%esp)
801001fb:	e8 e3 4e 00 00       	call   801050e3 <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 d3 87 10 80 	movl   $0x801087d3,(%esp)
8010020b:	e8 44 03 00 00       	call   80100554 <panic>
  b->flags |= B_DIRTY;
80100210:	8b 45 08             	mov    0x8(%ebp),%eax
80100213:	8b 00                	mov    (%eax),%eax
80100215:	83 c8 04             	or     $0x4,%eax
80100218:	89 c2                	mov    %eax,%edx
8010021a:	8b 45 08             	mov    0x8(%ebp),%eax
8010021d:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021f:	8b 45 08             	mov    0x8(%ebp),%eax
80100222:	89 04 24             	mov    %eax,(%esp)
80100225:	e8 0f 27 00 00       	call   80102939 <iderw>
}
8010022a:	c9                   	leave  
8010022b:	c3                   	ret    

8010022c <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022c:	55                   	push   %ebp
8010022d:	89 e5                	mov    %esp,%ebp
8010022f:	83 ec 18             	sub    $0x18,%esp
  if(!holdingsleep(&b->lock))
80100232:	8b 45 08             	mov    0x8(%ebp),%eax
80100235:	83 c0 0c             	add    $0xc,%eax
80100238:	89 04 24             	mov    %eax,(%esp)
8010023b:	e8 a3 4e 00 00       	call   801050e3 <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 da 87 10 80 	movl   $0x801087da,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 43 4e 00 00       	call   801050a1 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 a0 c7 10 80 	movl   $0x8010c7a0,(%esp)
80100265:	e8 01 4f 00 00       	call   8010516b <acquire>
  b->refcnt--;
8010026a:	8b 45 08             	mov    0x8(%ebp),%eax
8010026d:	8b 40 4c             	mov    0x4c(%eax),%eax
80100270:	8d 50 ff             	lea    -0x1(%eax),%edx
80100273:	8b 45 08             	mov    0x8(%ebp),%eax
80100276:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
80100279:	8b 45 08             	mov    0x8(%ebp),%eax
8010027c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010027f:	85 c0                	test   %eax,%eax
80100281:	75 47                	jne    801002ca <brelse+0x9e>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100283:	8b 45 08             	mov    0x8(%ebp),%eax
80100286:	8b 40 54             	mov    0x54(%eax),%eax
80100289:	8b 55 08             	mov    0x8(%ebp),%edx
8010028c:	8b 52 50             	mov    0x50(%edx),%edx
8010028f:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100292:	8b 45 08             	mov    0x8(%ebp),%eax
80100295:	8b 40 50             	mov    0x50(%eax),%eax
80100298:	8b 55 08             	mov    0x8(%ebp),%edx
8010029b:	8b 52 54             	mov    0x54(%edx),%edx
8010029e:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801002a1:	8b 15 f0 0e 11 80    	mov    0x80110ef0,%edx
801002a7:	8b 45 08             	mov    0x8(%ebp),%eax
801002aa:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002ad:	8b 45 08             	mov    0x8(%ebp),%eax
801002b0:	c7 40 50 9c 0e 11 80 	movl   $0x80110e9c,0x50(%eax)
    bcache.head.next->prev = b;
801002b7:	a1 f0 0e 11 80       	mov    0x80110ef0,%eax
801002bc:	8b 55 08             	mov    0x8(%ebp),%edx
801002bf:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002c2:	8b 45 08             	mov    0x8(%ebp),%eax
801002c5:	a3 f0 0e 11 80       	mov    %eax,0x80110ef0
  }
  
  release(&bcache.lock);
801002ca:	c7 04 24 a0 c7 10 80 	movl   $0x8010c7a0,(%esp)
801002d1:	e8 ff 4e 00 00       	call   801051d5 <release>
}
801002d6:	c9                   	leave  
801002d7:	c3                   	ret    

801002d8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d8:	55                   	push   %ebp
801002d9:	89 e5                	mov    %esp,%ebp
801002db:	83 ec 14             	sub    $0x14,%esp
801002de:	8b 45 08             	mov    0x8(%ebp),%eax
801002e1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801002e8:	89 c2                	mov    %eax,%edx
801002ea:	ec                   	in     (%dx),%al
801002eb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002ee:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801002f1:	c9                   	leave  
801002f2:	c3                   	ret    

801002f3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f3:	55                   	push   %ebp
801002f4:	89 e5                	mov    %esp,%ebp
801002f6:	83 ec 08             	sub    $0x8,%esp
801002f9:	8b 45 08             	mov    0x8(%ebp),%eax
801002fc:	8b 55 0c             	mov    0xc(%ebp),%edx
801002ff:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80100303:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100306:	8a 45 f8             	mov    -0x8(%ebp),%al
80100309:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	c9                   	leave  
8010030e:	c3                   	ret    

8010030f <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010030f:	55                   	push   %ebp
80100310:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100312:	fa                   	cli    
}
80100313:	5d                   	pop    %ebp
80100314:	c3                   	ret    

80100315 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100315:	55                   	push   %ebp
80100316:	89 e5                	mov    %esp,%ebp
80100318:	56                   	push   %esi
80100319:	53                   	push   %ebx
8010031a:	83 ec 30             	sub    $0x30,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100321:	74 1c                	je     8010033f <printint+0x2a>
80100323:	8b 45 08             	mov    0x8(%ebp),%eax
80100326:	c1 e8 1f             	shr    $0x1f,%eax
80100329:	0f b6 c0             	movzbl %al,%eax
8010032c:	89 45 10             	mov    %eax,0x10(%ebp)
8010032f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100333:	74 0a                	je     8010033f <printint+0x2a>
    x = -xx;
80100335:	8b 45 08             	mov    0x8(%ebp),%eax
80100338:	f7 d8                	neg    %eax
8010033a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033d:	eb 06                	jmp    80100345 <printint+0x30>
  else
    x = xx;
8010033f:	8b 45 08             	mov    0x8(%ebp),%eax
80100342:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100345:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034c:	8b 4d f4             	mov    -0xc(%ebp),%ecx
8010034f:	8d 41 01             	lea    0x1(%ecx),%eax
80100352:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100355:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035b:	ba 00 00 00 00       	mov    $0x0,%edx
80100360:	f7 f3                	div    %ebx
80100362:	89 d0                	mov    %edx,%eax
80100364:	8a 80 08 90 10 80    	mov    -0x7fef6ff8(%eax),%al
8010036a:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
8010036e:	8b 75 0c             	mov    0xc(%ebp),%esi
80100371:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100374:	ba 00 00 00 00       	mov    $0x0,%edx
80100379:	f7 f6                	div    %esi
8010037b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010037e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100382:	75 c8                	jne    8010034c <printint+0x37>

  if(sign)
80100384:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100388:	74 10                	je     8010039a <printint+0x85>
    buf[i++] = '-';
8010038a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038d:	8d 50 01             	lea    0x1(%eax),%edx
80100390:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100393:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
80100398:	eb 17                	jmp    801003b1 <printint+0x9c>
8010039a:	eb 15                	jmp    801003b1 <printint+0x9c>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	8a 00                	mov    (%eax),%al
801003a6:	0f be c0             	movsbl %al,%eax
801003a9:	89 04 24             	mov    %eax,(%esp)
801003ac:	e8 b7 03 00 00       	call   80100768 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b1:	ff 4d f4             	decl   -0xc(%ebp)
801003b4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003b8:	79 e2                	jns    8010039c <printint+0x87>
    consputc(buf[i]);
}
801003ba:	83 c4 30             	add    $0x30,%esp
801003bd:	5b                   	pop    %ebx
801003be:	5e                   	pop    %esi
801003bf:	5d                   	pop    %ebp
801003c0:	c3                   	ret    

801003c1 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c1:	55                   	push   %ebp
801003c2:	89 e5                	mov    %esp,%ebp
801003c4:	83 ec 38             	sub    $0x38,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003c7:	a1 34 b7 10 80       	mov    0x8010b734,%eax
801003cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003cf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d3:	74 0c                	je     801003e1 <cprintf+0x20>
    acquire(&cons.lock);
801003d5:	c7 04 24 00 b7 10 80 	movl   $0x8010b700,(%esp)
801003dc:	e8 8a 4d 00 00       	call   8010516b <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 e1 87 10 80 	movl   $0x801087e1,(%esp)
801003ef:	e8 60 01 00 00       	call   80100554 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003f4:	8d 45 0c             	lea    0xc(%ebp),%eax
801003f7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801003fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100401:	e9 1b 01 00 00       	jmp    80100521 <cprintf+0x160>
    if(c != '%'){
80100406:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
8010040a:	74 10                	je     8010041c <cprintf+0x5b>
      consputc(c);
8010040c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010040f:	89 04 24             	mov    %eax,(%esp)
80100412:	e8 51 03 00 00       	call   80100768 <consputc>
      continue;
80100417:	e9 02 01 00 00       	jmp    8010051e <cprintf+0x15d>
    }
    c = fmt[++i] & 0xff;
8010041c:	8b 55 08             	mov    0x8(%ebp),%edx
8010041f:	ff 45 f4             	incl   -0xc(%ebp)
80100422:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100425:	01 d0                	add    %edx,%eax
80100427:	8a 00                	mov    (%eax),%al
80100429:	0f be c0             	movsbl %al,%eax
8010042c:	25 ff 00 00 00       	and    $0xff,%eax
80100431:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100434:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100438:	75 05                	jne    8010043f <cprintf+0x7e>
      break;
8010043a:	e9 01 01 00 00       	jmp    80100540 <cprintf+0x17f>
    switch(c){
8010043f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100442:	83 f8 70             	cmp    $0x70,%eax
80100445:	74 4f                	je     80100496 <cprintf+0xd5>
80100447:	83 f8 70             	cmp    $0x70,%eax
8010044a:	7f 13                	jg     8010045f <cprintf+0x9e>
8010044c:	83 f8 25             	cmp    $0x25,%eax
8010044f:	0f 84 a3 00 00 00    	je     801004f8 <cprintf+0x137>
80100455:	83 f8 64             	cmp    $0x64,%eax
80100458:	74 14                	je     8010046e <cprintf+0xad>
8010045a:	e9 a7 00 00 00       	jmp    80100506 <cprintf+0x145>
8010045f:	83 f8 73             	cmp    $0x73,%eax
80100462:	74 57                	je     801004bb <cprintf+0xfa>
80100464:	83 f8 78             	cmp    $0x78,%eax
80100467:	74 2d                	je     80100496 <cprintf+0xd5>
80100469:	e9 98 00 00 00       	jmp    80100506 <cprintf+0x145>
    case 'd':
      printint(*argp++, 10, 1);
8010046e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100471:	8d 50 04             	lea    0x4(%eax),%edx
80100474:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100477:	8b 00                	mov    (%eax),%eax
80100479:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80100480:	00 
80100481:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80100488:	00 
80100489:	89 04 24             	mov    %eax,(%esp)
8010048c:	e8 84 fe ff ff       	call   80100315 <printint>
      break;
80100491:	e9 88 00 00 00       	jmp    8010051e <cprintf+0x15d>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
80100496:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100499:	8d 50 04             	lea    0x4(%eax),%edx
8010049c:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010049f:	8b 00                	mov    (%eax),%eax
801004a1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801004a8:	00 
801004a9:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
801004b0:	00 
801004b1:	89 04 24             	mov    %eax,(%esp)
801004b4:	e8 5c fe ff ff       	call   80100315 <printint>
      break;
801004b9:	eb 63                	jmp    8010051e <cprintf+0x15d>
    case 's':
      if((s = (char*)*argp++) == 0)
801004bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004be:	8d 50 04             	lea    0x4(%eax),%edx
801004c1:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c4:	8b 00                	mov    (%eax),%eax
801004c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c9:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cd:	75 09                	jne    801004d8 <cprintf+0x117>
        s = "(null)";
801004cf:	c7 45 ec ea 87 10 80 	movl   $0x801087ea,-0x14(%ebp)
      for(; *s; s++)
801004d6:	eb 15                	jmp    801004ed <cprintf+0x12c>
801004d8:	eb 13                	jmp    801004ed <cprintf+0x12c>
        consputc(*s);
801004da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004dd:	8a 00                	mov    (%eax),%al
801004df:	0f be c0             	movsbl %al,%eax
801004e2:	89 04 24             	mov    %eax,(%esp)
801004e5:	e8 7e 02 00 00       	call   80100768 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004ea:	ff 45 ec             	incl   -0x14(%ebp)
801004ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f0:	8a 00                	mov    (%eax),%al
801004f2:	84 c0                	test   %al,%al
801004f4:	75 e4                	jne    801004da <cprintf+0x119>
        consputc(*s);
      break;
801004f6:	eb 26                	jmp    8010051e <cprintf+0x15d>
    case '%':
      consputc('%');
801004f8:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
801004ff:	e8 64 02 00 00       	call   80100768 <consputc>
      break;
80100504:	eb 18                	jmp    8010051e <cprintf+0x15d>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
80100506:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
8010050d:	e8 56 02 00 00       	call   80100768 <consputc>
      consputc(c);
80100512:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100515:	89 04 24             	mov    %eax,(%esp)
80100518:	e8 4b 02 00 00       	call   80100768 <consputc>
      break;
8010051d:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010051e:	ff 45 f4             	incl   -0xc(%ebp)
80100521:	8b 55 08             	mov    0x8(%ebp),%edx
80100524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100527:	01 d0                	add    %edx,%eax
80100529:	8a 00                	mov    (%eax),%al
8010052b:	0f be c0             	movsbl %al,%eax
8010052e:	25 ff 00 00 00       	and    $0xff,%eax
80100533:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100536:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
8010053a:	0f 85 c6 fe ff ff    	jne    80100406 <cprintf+0x45>
      consputc(c);
      break;
    }
  }

  if(locking)
80100540:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100544:	74 0c                	je     80100552 <cprintf+0x191>
    release(&cons.lock);
80100546:	c7 04 24 00 b7 10 80 	movl   $0x8010b700,(%esp)
8010054d:	e8 83 4c 00 00       	call   801051d5 <release>
}
80100552:	c9                   	leave  
80100553:	c3                   	ret    

80100554 <panic>:

void
panic(char *s)
{
80100554:	55                   	push   %ebp
80100555:	89 e5                	mov    %esp,%ebp
80100557:	83 ec 48             	sub    $0x48,%esp
  int i;
  uint pcs[10];

  cli();
8010055a:	e8 b0 fd ff ff       	call   8010030f <cli>
  cons.locking = 0;
8010055f:	c7 05 34 b7 10 80 00 	movl   $0x0,0x8010b734
80100566:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100569:	e8 67 2a 00 00       	call   80102fd5 <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 f1 87 10 80 	movl   $0x801087f1,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 05 88 10 80 	movl   $0x80108805,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 7b 4c 00 00       	call   80105222 <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 07 88 10 80 	movl   $0x80108807,(%esp)
801005c2:	e8 fa fd ff ff       	call   801003c1 <cprintf>
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005c7:	ff 45 f4             	incl   -0xc(%ebp)
801005ca:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005ce:	7e e0                	jle    801005b0 <panic+0x5c>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005d0:	c7 05 ec b6 10 80 01 	movl   $0x1,0x8010b6ec
801005d7:	00 00 00 
  for(;;)
    ;
801005da:	eb fe                	jmp    801005da <panic+0x86>

801005dc <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
801005dc:	55                   	push   %ebp
801005dd:	89 e5                	mov    %esp,%ebp
801005df:	83 ec 28             	sub    $0x28,%esp
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
801005e2:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
801005e9:	00 
801005ea:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
801005f1:	e8 fd fc ff ff       	call   801002f3 <outb>
  pos = inb(CRTPORT+1) << 8;
801005f6:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
801005fd:	e8 d6 fc ff ff       	call   801002d8 <inb>
80100602:	0f b6 c0             	movzbl %al,%eax
80100605:	c1 e0 08             	shl    $0x8,%eax
80100608:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010060b:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100612:	00 
80100613:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010061a:	e8 d4 fc ff ff       	call   801002f3 <outb>
  pos |= inb(CRTPORT+1);
8010061f:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100626:	e8 ad fc ff ff       	call   801002d8 <inb>
8010062b:	0f b6 c0             	movzbl %al,%eax
8010062e:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
80100631:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100635:	75 1b                	jne    80100652 <cgaputc+0x76>
    pos += 80 - pos%80;
80100637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010063a:	b9 50 00 00 00       	mov    $0x50,%ecx
8010063f:	99                   	cltd   
80100640:	f7 f9                	idiv   %ecx
80100642:	89 d0                	mov    %edx,%eax
80100644:	ba 50 00 00 00       	mov    $0x50,%edx
80100649:	29 c2                	sub    %eax,%edx
8010064b:	89 d0                	mov    %edx,%eax
8010064d:	01 45 f4             	add    %eax,-0xc(%ebp)
80100650:	eb 34                	jmp    80100686 <cgaputc+0xaa>
  else if(c == BACKSPACE){
80100652:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100659:	75 0b                	jne    80100666 <cgaputc+0x8a>
    if(pos > 0) --pos;
8010065b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010065f:	7e 25                	jle    80100686 <cgaputc+0xaa>
80100661:	ff 4d f4             	decl   -0xc(%ebp)
80100664:	eb 20                	jmp    80100686 <cgaputc+0xaa>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100666:	8b 0d 04 90 10 80    	mov    0x80109004,%ecx
8010066c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010066f:	8d 50 01             	lea    0x1(%eax),%edx
80100672:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100675:	01 c0                	add    %eax,%eax
80100677:	8d 14 01             	lea    (%ecx,%eax,1),%edx
8010067a:	8b 45 08             	mov    0x8(%ebp),%eax
8010067d:	0f b6 c0             	movzbl %al,%eax
80100680:	80 cc 07             	or     $0x7,%ah
80100683:	66 89 02             	mov    %ax,(%edx)

  if(pos < 0 || pos > 25*80)
80100686:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010068a:	78 09                	js     80100695 <cgaputc+0xb9>
8010068c:	81 7d f4 d0 07 00 00 	cmpl   $0x7d0,-0xc(%ebp)
80100693:	7e 0c                	jle    801006a1 <cgaputc+0xc5>
    panic("pos under/overflow");
80100695:	c7 04 24 0b 88 10 80 	movl   $0x8010880b,(%esp)
8010069c:	e8 b3 fe ff ff       	call   80100554 <panic>

  if((pos/80) >= 24){  // Scroll up.
801006a1:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006a8:	7e 53                	jle    801006fd <cgaputc+0x121>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006aa:	a1 04 90 10 80       	mov    0x80109004,%eax
801006af:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006b5:	a1 04 90 10 80       	mov    0x80109004,%eax
801006ba:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006c1:	00 
801006c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801006c6:	89 04 24             	mov    %eax,(%esp)
801006c9:	e8 c9 4d 00 00       	call   80105497 <memmove>
    pos -= 80;
801006ce:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006d2:	b8 80 07 00 00       	mov    $0x780,%eax
801006d7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006da:	01 c0                	add    %eax,%eax
801006dc:	8b 0d 04 90 10 80    	mov    0x80109004,%ecx
801006e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801006e5:	01 d2                	add    %edx,%edx
801006e7:	01 ca                	add    %ecx,%edx
801006e9:	89 44 24 08          	mov    %eax,0x8(%esp)
801006ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006f4:	00 
801006f5:	89 14 24             	mov    %edx,(%esp)
801006f8:	e8 d1 4c 00 00       	call   801053ce <memset>
  }

  outb(CRTPORT, 14);
801006fd:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
80100704:	00 
80100705:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
8010070c:	e8 e2 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT+1, pos>>8);
80100711:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100714:	c1 f8 08             	sar    $0x8,%eax
80100717:	0f b6 c0             	movzbl %al,%eax
8010071a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010071e:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
80100725:	e8 c9 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT, 15);
8010072a:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80100731:	00 
80100732:	c7 04 24 d4 03 00 00 	movl   $0x3d4,(%esp)
80100739:	e8 b5 fb ff ff       	call   801002f3 <outb>
  outb(CRTPORT+1, pos);
8010073e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100741:	0f b6 c0             	movzbl %al,%eax
80100744:	89 44 24 04          	mov    %eax,0x4(%esp)
80100748:	c7 04 24 d5 03 00 00 	movl   $0x3d5,(%esp)
8010074f:	e8 9f fb ff ff       	call   801002f3 <outb>
  crt[pos] = ' ' | 0x0700;
80100754:	8b 15 04 90 10 80    	mov    0x80109004,%edx
8010075a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010075d:	01 c0                	add    %eax,%eax
8010075f:	01 d0                	add    %edx,%eax
80100761:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100766:	c9                   	leave  
80100767:	c3                   	ret    

80100768 <consputc>:

void
consputc(int c)
{
80100768:	55                   	push   %ebp
80100769:	89 e5                	mov    %esp,%ebp
8010076b:	83 ec 18             	sub    $0x18,%esp
  if(panicked){
8010076e:	a1 ec b6 10 80       	mov    0x8010b6ec,%eax
80100773:	85 c0                	test   %eax,%eax
80100775:	74 07                	je     8010077e <consputc+0x16>
    cli();
80100777:	e8 93 fb ff ff       	call   8010030f <cli>
    for(;;)
      ;
8010077c:	eb fe                	jmp    8010077c <consputc+0x14>
  }

  if(c == BACKSPACE){
8010077e:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100785:	75 26                	jne    801007ad <consputc+0x45>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100787:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010078e:	e8 a1 67 00 00       	call   80106f34 <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 95 67 00 00       	call   80106f34 <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 89 67 00 00       	call   80106f34 <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 7c 67 00 00       	call   80106f34 <uartputc>
  cgaputc(c);
801007b8:	8b 45 08             	mov    0x8(%ebp),%eax
801007bb:	89 04 24             	mov    %eax,(%esp)
801007be:	e8 19 fe ff ff       	call   801005dc <cgaputc>
}
801007c3:	c9                   	leave  
801007c4:	c3                   	ret    

801007c5 <copy_buf>:

#define C(x)  ((x)-'@')  // Control-x


void copy_buf(char *dst, char *src, int len)
{
801007c5:	55                   	push   %ebp
801007c6:	89 e5                	mov    %esp,%ebp
801007c8:	83 ec 10             	sub    $0x10,%esp
  int i;

  for (i = 0; i < len; i++) {
801007cb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801007d2:	eb 17                	jmp    801007eb <copy_buf+0x26>
    dst[i] = src[i];
801007d4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801007d7:	8b 45 08             	mov    0x8(%ebp),%eax
801007da:	01 c2                	add    %eax,%edx
801007dc:	8b 4d fc             	mov    -0x4(%ebp),%ecx
801007df:	8b 45 0c             	mov    0xc(%ebp),%eax
801007e2:	01 c8                	add    %ecx,%eax
801007e4:	8a 00                	mov    (%eax),%al
801007e6:	88 02                	mov    %al,(%edx)

void copy_buf(char *dst, char *src, int len)
{
  int i;

  for (i = 0; i < len; i++) {
801007e8:	ff 45 fc             	incl   -0x4(%ebp)
801007eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
801007ee:	3b 45 10             	cmp    0x10(%ebp),%eax
801007f1:	7c e1                	jl     801007d4 <copy_buf+0xf>
    dst[i] = src[i];
  }
}
801007f3:	c9                   	leave  
801007f4:	c3                   	ret    

801007f5 <consoleintr>:

void
consoleintr(int (*getc)(void))
{
801007f5:	55                   	push   %ebp
801007f6:	89 e5                	mov    %esp,%ebp
801007f8:	57                   	push   %edi
801007f9:	56                   	push   %esi
801007fa:	53                   	push   %ebx
801007fb:	83 ec 2c             	sub    $0x2c,%esp
  int c, doprocdump = 0, doconsoleswitch = 0;
801007fe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100805:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

  acquire(&cons.lock);
8010080c:	c7 04 24 00 b7 10 80 	movl   $0x8010b700,(%esp)
80100813:	e8 53 49 00 00       	call   8010516b <acquire>
  while((c = getc()) >= 0){
80100818:	e9 cb 01 00 00       	jmp    801009e8 <consoleintr+0x1f3>
    switch(c){
8010081d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100820:	83 f8 14             	cmp    $0x14,%eax
80100823:	74 3b                	je     80100860 <consoleintr+0x6b>
80100825:	83 f8 14             	cmp    $0x14,%eax
80100828:	7f 13                	jg     8010083d <consoleintr+0x48>
8010082a:	83 f8 08             	cmp    $0x8,%eax
8010082d:	0f 84 f6 00 00 00    	je     80100929 <consoleintr+0x134>
80100833:	83 f8 10             	cmp    $0x10,%eax
80100836:	74 1c                	je     80100854 <consoleintr+0x5f>
80100838:	e9 1c 01 00 00       	jmp    80100959 <consoleintr+0x164>
8010083d:	83 f8 15             	cmp    $0x15,%eax
80100840:	0f 84 bb 00 00 00    	je     80100901 <consoleintr+0x10c>
80100846:	83 f8 7f             	cmp    $0x7f,%eax
80100849:	0f 84 da 00 00 00    	je     80100929 <consoleintr+0x134>
8010084f:	e9 05 01 00 00       	jmp    80100959 <consoleintr+0x164>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100854:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
      break;
8010085b:	e9 88 01 00 00       	jmp    801009e8 <consoleintr+0x1f3>
    case C('T'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      if (active == 1){
80100860:	a1 00 90 10 80       	mov    0x80109000,%eax
80100865:	83 f8 01             	cmp    $0x1,%eax
80100868:	75 3a                	jne    801008a4 <consoleintr+0xaf>
        active = 2;
8010086a:	c7 05 00 90 10 80 02 	movl   $0x2,0x80109000
80100871:	00 00 00 
        buf1 = input;
80100874:	ba c0 b5 10 80       	mov    $0x8010b5c0,%edx
80100879:	bb 00 11 11 80       	mov    $0x80111100,%ebx
8010087e:	b8 23 00 00 00       	mov    $0x23,%eax
80100883:	89 d7                	mov    %edx,%edi
80100885:	89 de                	mov    %ebx,%esi
80100887:	89 c1                	mov    %eax,%ecx
80100889:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        input = buf2;
8010088b:	ba 00 11 11 80       	mov    $0x80111100,%edx
80100890:	bb 60 b6 10 80       	mov    $0x8010b660,%ebx
80100895:	b8 23 00 00 00       	mov    $0x23,%eax
8010089a:	89 d7                	mov    %edx,%edi
8010089c:	89 de                	mov    %ebx,%esi
8010089e:	89 c1                	mov    %eax,%ecx
801008a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
801008a2:	eb 38                	jmp    801008dc <consoleintr+0xe7>
      }else{
        active = 1;
801008a4:	c7 05 00 90 10 80 01 	movl   $0x1,0x80109000
801008ab:	00 00 00 
        buf2 = input;
801008ae:	ba 60 b6 10 80       	mov    $0x8010b660,%edx
801008b3:	bb 00 11 11 80       	mov    $0x80111100,%ebx
801008b8:	b8 23 00 00 00       	mov    $0x23,%eax
801008bd:	89 d7                	mov    %edx,%edi
801008bf:	89 de                	mov    %ebx,%esi
801008c1:	89 c1                	mov    %eax,%ecx
801008c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        input = buf1;
801008c5:	ba 00 11 11 80       	mov    $0x80111100,%edx
801008ca:	bb c0 b5 10 80       	mov    $0x8010b5c0,%ebx
801008cf:	b8 23 00 00 00       	mov    $0x23,%eax
801008d4:	89 d7                	mov    %edx,%edi
801008d6:	89 de                	mov    %ebx,%esi
801008d8:	89 c1                	mov    %eax,%ecx
801008da:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
      } 
      doconsoleswitch = 1;
801008dc:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
      break;
801008e3:	e9 00 01 00 00       	jmp    801009e8 <consoleintr+0x1f3>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
801008e8:	a1 88 11 11 80       	mov    0x80111188,%eax
801008ed:	48                   	dec    %eax
801008ee:	a3 88 11 11 80       	mov    %eax,0x80111188
        consputc(BACKSPACE);
801008f3:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
801008fa:	e8 69 fe ff ff       	call   80100768 <consputc>
801008ff:	eb 01                	jmp    80100902 <consoleintr+0x10d>
        input = buf1;
      } 
      doconsoleswitch = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100901:	90                   	nop
80100902:	8b 15 88 11 11 80    	mov    0x80111188,%edx
80100908:	a1 84 11 11 80       	mov    0x80111184,%eax
8010090d:	39 c2                	cmp    %eax,%edx
8010090f:	74 13                	je     80100924 <consoleintr+0x12f>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100911:	a1 88 11 11 80       	mov    0x80111188,%eax
80100916:	48                   	dec    %eax
80100917:	83 e0 7f             	and    $0x7f,%eax
8010091a:	8a 80 00 11 11 80    	mov    -0x7feeef00(%eax),%al
        input = buf1;
      } 
      doconsoleswitch = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100920:	3c 0a                	cmp    $0xa,%al
80100922:	75 c4                	jne    801008e8 <consoleintr+0xf3>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
80100924:	e9 bf 00 00 00       	jmp    801009e8 <consoleintr+0x1f3>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100929:	8b 15 88 11 11 80    	mov    0x80111188,%edx
8010092f:	a1 84 11 11 80       	mov    0x80111184,%eax
80100934:	39 c2                	cmp    %eax,%edx
80100936:	74 1c                	je     80100954 <consoleintr+0x15f>
        input.e--;
80100938:	a1 88 11 11 80       	mov    0x80111188,%eax
8010093d:	48                   	dec    %eax
8010093e:	a3 88 11 11 80       	mov    %eax,0x80111188
        consputc(BACKSPACE);
80100943:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
8010094a:	e8 19 fe ff ff       	call   80100768 <consputc>
      }
      break;
8010094f:	e9 94 00 00 00       	jmp    801009e8 <consoleintr+0x1f3>
80100954:	e9 8f 00 00 00       	jmp    801009e8 <consoleintr+0x1f3>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100959:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
8010095d:	0f 84 84 00 00 00    	je     801009e7 <consoleintr+0x1f2>
80100963:	8b 15 88 11 11 80    	mov    0x80111188,%edx
80100969:	a1 80 11 11 80       	mov    0x80111180,%eax
8010096e:	29 c2                	sub    %eax,%edx
80100970:	89 d0                	mov    %edx,%eax
80100972:	83 f8 7f             	cmp    $0x7f,%eax
80100975:	77 70                	ja     801009e7 <consoleintr+0x1f2>
        c = (c == '\r') ? '\n' : c;
80100977:	83 7d dc 0d          	cmpl   $0xd,-0x24(%ebp)
8010097b:	74 05                	je     80100982 <consoleintr+0x18d>
8010097d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100980:	eb 05                	jmp    80100987 <consoleintr+0x192>
80100982:	b8 0a 00 00 00       	mov    $0xa,%eax
80100987:	89 45 dc             	mov    %eax,-0x24(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
8010098a:	a1 88 11 11 80       	mov    0x80111188,%eax
8010098f:	8d 50 01             	lea    0x1(%eax),%edx
80100992:	89 15 88 11 11 80    	mov    %edx,0x80111188
80100998:	83 e0 7f             	and    $0x7f,%eax
8010099b:	89 c2                	mov    %eax,%edx
8010099d:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009a0:	88 82 00 11 11 80    	mov    %al,-0x7feeef00(%edx)
        consputc(c);
801009a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009a9:	89 04 24             	mov    %eax,(%esp)
801009ac:	e8 b7 fd ff ff       	call   80100768 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009b1:	83 7d dc 0a          	cmpl   $0xa,-0x24(%ebp)
801009b5:	74 18                	je     801009cf <consoleintr+0x1da>
801009b7:	83 7d dc 04          	cmpl   $0x4,-0x24(%ebp)
801009bb:	74 12                	je     801009cf <consoleintr+0x1da>
801009bd:	a1 88 11 11 80       	mov    0x80111188,%eax
801009c2:	8b 15 80 11 11 80    	mov    0x80111180,%edx
801009c8:	83 ea 80             	sub    $0xffffff80,%edx
801009cb:	39 d0                	cmp    %edx,%eax
801009cd:	75 18                	jne    801009e7 <consoleintr+0x1f2>
          input.w = input.e;
801009cf:	a1 88 11 11 80       	mov    0x80111188,%eax
801009d4:	a3 84 11 11 80       	mov    %eax,0x80111184
          wakeup(&input.r);
801009d9:	c7 04 24 80 11 11 80 	movl   $0x80111180,(%esp)
801009e0:	e8 8c 41 00 00       	call   80104b71 <wakeup>
        }
      }
      break;
801009e5:	eb 00                	jmp    801009e7 <consoleintr+0x1f2>
801009e7:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0, doconsoleswitch = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
801009e8:	8b 45 08             	mov    0x8(%ebp),%eax
801009eb:	ff d0                	call   *%eax
801009ed:	89 45 dc             	mov    %eax,-0x24(%ebp)
801009f0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801009f4:	0f 89 23 fe ff ff    	jns    8010081d <consoleintr+0x28>
        }
      }
      break;
    }
  }
  release(&cons.lock);
801009fa:	c7 04 24 00 b7 10 80 	movl   $0x8010b700,(%esp)
80100a01:	e8 cf 47 00 00       	call   801051d5 <release>
  if(doprocdump){
80100a06:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a0a:	74 05                	je     80100a11 <consoleintr+0x21c>
    procdump();  // now call procdump() wo. cons.lock held
80100a0c:	e8 06 42 00 00       	call   80104c17 <procdump>
  }
  if(doconsoleswitch){
80100a11:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a15:	74 15                	je     80100a2c <consoleintr+0x237>
    cprintf("\nActive console now: %d\n", active);
80100a17:	a1 00 90 10 80       	mov    0x80109000,%eax
80100a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a20:	c7 04 24 1e 88 10 80 	movl   $0x8010881e,(%esp)
80100a27:	e8 95 f9 ff ff       	call   801003c1 <cprintf>
  }
}
80100a2c:	83 c4 2c             	add    $0x2c,%esp
80100a2f:	5b                   	pop    %ebx
80100a30:	5e                   	pop    %esi
80100a31:	5f                   	pop    %edi
80100a32:	5d                   	pop    %ebp
80100a33:	c3                   	ret    

80100a34 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100a34:	55                   	push   %ebp
80100a35:	89 e5                	mov    %esp,%ebp
80100a37:	83 ec 28             	sub    $0x28,%esp
  uint target;
  int c;

  iunlock(ip);
80100a3a:	8b 45 08             	mov    0x8(%ebp),%eax
80100a3d:	89 04 24             	mov    %eax,(%esp)
80100a40:	e8 eb 10 00 00       	call   80101b30 <iunlock>
  target = n;
80100a45:	8b 45 10             	mov    0x10(%ebp),%eax
80100a48:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a4b:	c7 04 24 00 b7 10 80 	movl   $0x8010b700,(%esp)
80100a52:	e8 14 47 00 00       	call   8010516b <acquire>
  while(n > 0){
80100a57:	e9 b7 00 00 00       	jmp    80100b13 <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a5c:	eb 41                	jmp    80100a9f <consoleread+0x6b>
      if(myproc()->killed){
80100a5e:	e8 bc 37 00 00       	call   8010421f <myproc>
80100a63:	8b 40 24             	mov    0x24(%eax),%eax
80100a66:	85 c0                	test   %eax,%eax
80100a68:	74 21                	je     80100a8b <consoleread+0x57>
        release(&cons.lock);
80100a6a:	c7 04 24 00 b7 10 80 	movl   $0x8010b700,(%esp)
80100a71:	e8 5f 47 00 00       	call   801051d5 <release>
        ilock(ip);
80100a76:	8b 45 08             	mov    0x8(%ebp),%eax
80100a79:	89 04 24             	mov    %eax,(%esp)
80100a7c:	e8 a5 0f 00 00       	call   80101a26 <ilock>
        return -1;
80100a81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a86:	e9 b3 00 00 00       	jmp    80100b3e <consoleread+0x10a>
      }
      sleep(&input.r, &cons.lock);
80100a8b:	c7 44 24 04 00 b7 10 	movl   $0x8010b700,0x4(%esp)
80100a92:	80 
80100a93:	c7 04 24 80 11 11 80 	movl   $0x80111180,(%esp)
80100a9a:	e8 fb 3f 00 00       	call   80104a9a <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while((input.r == input.w) || (active != ip->minor)){
80100a9f:	8b 15 80 11 11 80    	mov    0x80111180,%edx
80100aa5:	a1 84 11 11 80       	mov    0x80111184,%eax
80100aaa:	39 c2                	cmp    %eax,%edx
80100aac:	74 b0                	je     80100a5e <consoleread+0x2a>
80100aae:	8b 45 08             	mov    0x8(%ebp),%eax
80100ab1:	8b 40 54             	mov    0x54(%eax),%eax
80100ab4:	0f bf d0             	movswl %ax,%edx
80100ab7:	a1 00 90 10 80       	mov    0x80109000,%eax
80100abc:	39 c2                	cmp    %eax,%edx
80100abe:	75 9e                	jne    80100a5e <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100ac0:	a1 80 11 11 80       	mov    0x80111180,%eax
80100ac5:	8d 50 01             	lea    0x1(%eax),%edx
80100ac8:	89 15 80 11 11 80    	mov    %edx,0x80111180
80100ace:	83 e0 7f             	and    $0x7f,%eax
80100ad1:	8a 80 00 11 11 80    	mov    -0x7feeef00(%eax),%al
80100ad7:	0f be c0             	movsbl %al,%eax
80100ada:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100add:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100ae1:	75 17                	jne    80100afa <consoleread+0xc6>
      if(n < target){
80100ae3:	8b 45 10             	mov    0x10(%ebp),%eax
80100ae6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100ae9:	73 0d                	jae    80100af8 <consoleread+0xc4>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100aeb:	a1 80 11 11 80       	mov    0x80111180,%eax
80100af0:	48                   	dec    %eax
80100af1:	a3 80 11 11 80       	mov    %eax,0x80111180
      }
      break;
80100af6:	eb 25                	jmp    80100b1d <consoleread+0xe9>
80100af8:	eb 23                	jmp    80100b1d <consoleread+0xe9>
    }
    *dst++ = c;
80100afa:	8b 45 0c             	mov    0xc(%ebp),%eax
80100afd:	8d 50 01             	lea    0x1(%eax),%edx
80100b00:	89 55 0c             	mov    %edx,0xc(%ebp)
80100b03:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100b06:	88 10                	mov    %dl,(%eax)
    --n;
80100b08:	ff 4d 10             	decl   0x10(%ebp)
    if(c == '\n')
80100b0b:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100b0f:	75 02                	jne    80100b13 <consoleread+0xdf>
      break;
80100b11:	eb 0a                	jmp    80100b1d <consoleread+0xe9>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100b13:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100b17:	0f 8f 3f ff ff ff    	jg     80100a5c <consoleread+0x28>
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
80100b1d:	c7 04 24 00 b7 10 80 	movl   $0x8010b700,(%esp)
80100b24:	e8 ac 46 00 00       	call   801051d5 <release>
  ilock(ip);
80100b29:	8b 45 08             	mov    0x8(%ebp),%eax
80100b2c:	89 04 24             	mov    %eax,(%esp)
80100b2f:	e8 f2 0e 00 00       	call   80101a26 <ilock>

  return target - n;
80100b34:	8b 45 10             	mov    0x10(%ebp),%eax
80100b37:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b3a:	29 c2                	sub    %eax,%edx
80100b3c:	89 d0                	mov    %edx,%eax
}
80100b3e:	c9                   	leave  
80100b3f:	c3                   	ret    

80100b40 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100b40:	55                   	push   %ebp
80100b41:	89 e5                	mov    %esp,%ebp
80100b43:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (active == ip->minor){
80100b46:	8b 45 08             	mov    0x8(%ebp),%eax
80100b49:	8b 40 54             	mov    0x54(%eax),%eax
80100b4c:	0f bf d0             	movswl %ax,%edx
80100b4f:	a1 00 90 10 80       	mov    0x80109000,%eax
80100b54:	39 c2                	cmp    %eax,%edx
80100b56:	75 5a                	jne    80100bb2 <consolewrite+0x72>
    iunlock(ip);
80100b58:	8b 45 08             	mov    0x8(%ebp),%eax
80100b5b:	89 04 24             	mov    %eax,(%esp)
80100b5e:	e8 cd 0f 00 00       	call   80101b30 <iunlock>
    acquire(&cons.lock);
80100b63:	c7 04 24 00 b7 10 80 	movl   $0x8010b700,(%esp)
80100b6a:	e8 fc 45 00 00       	call   8010516b <acquire>
    for(i = 0; i < n; i++)
80100b6f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100b76:	eb 1b                	jmp    80100b93 <consolewrite+0x53>
      consputc(buf[i] & 0xff);
80100b78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100b7b:	8b 45 0c             	mov    0xc(%ebp),%eax
80100b7e:	01 d0                	add    %edx,%eax
80100b80:	8a 00                	mov    (%eax),%al
80100b82:	0f be c0             	movsbl %al,%eax
80100b85:	0f b6 c0             	movzbl %al,%eax
80100b88:	89 04 24             	mov    %eax,(%esp)
80100b8b:	e8 d8 fb ff ff       	call   80100768 <consputc>
  int i;

  if (active == ip->minor){
    iunlock(ip);
    acquire(&cons.lock);
    for(i = 0; i < n; i++)
80100b90:	ff 45 f4             	incl   -0xc(%ebp)
80100b93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b96:	3b 45 10             	cmp    0x10(%ebp),%eax
80100b99:	7c dd                	jl     80100b78 <consolewrite+0x38>
      consputc(buf[i] & 0xff);
    release(&cons.lock);
80100b9b:	c7 04 24 00 b7 10 80 	movl   $0x8010b700,(%esp)
80100ba2:	e8 2e 46 00 00       	call   801051d5 <release>
    ilock(ip);
80100ba7:	8b 45 08             	mov    0x8(%ebp),%eax
80100baa:	89 04 24             	mov    %eax,(%esp)
80100bad:	e8 74 0e 00 00       	call   80101a26 <ilock>
  }
  return n;
80100bb2:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100bb5:	c9                   	leave  
80100bb6:	c3                   	ret    

80100bb7 <consoleinit>:

void
consoleinit(void)
{
80100bb7:	55                   	push   %ebp
80100bb8:	89 e5                	mov    %esp,%ebp
80100bba:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
80100bbd:	c7 44 24 04 37 88 10 	movl   $0x80108837,0x4(%esp)
80100bc4:	80 
80100bc5:	c7 04 24 00 b7 10 80 	movl   $0x8010b700,(%esp)
80100bcc:	e8 79 45 00 00       	call   8010514a <initlock>

  devsw[CONSOLE].write = consolewrite;
80100bd1:	c7 05 4c 1b 11 80 40 	movl   $0x80100b40,0x80111b4c
80100bd8:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100bdb:	c7 05 48 1b 11 80 34 	movl   $0x80100a34,0x80111b48
80100be2:	0a 10 80 
  cons.locking = 1;
80100be5:	c7 05 34 b7 10 80 01 	movl   $0x1,0x8010b734
80100bec:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100bef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100bf6:	00 
80100bf7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100bfe:	e8 e8 1e 00 00       	call   80102aeb <ioapicenable>
}
80100c03:	c9                   	leave  
80100c04:	c3                   	ret    
80100c05:	00 00                	add    %al,(%eax)
	...

80100c08 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100c08:	55                   	push   %ebp
80100c09:	89 e5                	mov    %esp,%ebp
80100c0b:	81 ec 38 01 00 00    	sub    $0x138,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100c11:	e8 09 36 00 00       	call   8010421f <myproc>
80100c16:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c19:	e8 01 29 00 00       	call   8010351f <begin_op>

  if((ip = namei(path)) == 0){
80100c1e:	8b 45 08             	mov    0x8(%ebp),%eax
80100c21:	89 04 24             	mov    %eax,(%esp)
80100c24:	e8 22 19 00 00       	call   8010254b <namei>
80100c29:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c2c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c30:	75 1b                	jne    80100c4d <exec+0x45>
    end_op();
80100c32:	e8 6a 29 00 00       	call   801035a1 <end_op>
    cprintf("exec: fail\n");
80100c37:	c7 04 24 3f 88 10 80 	movl   $0x8010883f,(%esp)
80100c3e:	e8 7e f7 ff ff       	call   801003c1 <cprintf>
    return -1;
80100c43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c48:	e9 f6 03 00 00       	jmp    80101043 <exec+0x43b>
  }
  ilock(ip);
80100c4d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c50:	89 04 24             	mov    %eax,(%esp)
80100c53:	e8 ce 0d 00 00       	call   80101a26 <ilock>
  pgdir = 0;
80100c58:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c5f:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100c66:	00 
80100c67:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100c6e:	00 
80100c6f:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100c75:	89 44 24 04          	mov    %eax,0x4(%esp)
80100c79:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c7c:	89 04 24             	mov    %eax,(%esp)
80100c7f:	e8 39 12 00 00       	call   80101ebd <readi>
80100c84:	83 f8 34             	cmp    $0x34,%eax
80100c87:	74 05                	je     80100c8e <exec+0x86>
    goto bad;
80100c89:	e9 89 03 00 00       	jmp    80101017 <exec+0x40f>
  if(elf.magic != ELF_MAGIC)
80100c8e:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c94:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c99:	74 05                	je     80100ca0 <exec+0x98>
    goto bad;
80100c9b:	e9 77 03 00 00       	jmp    80101017 <exec+0x40f>

  if((pgdir = setupkvm()) == 0)
80100ca0:	e8 71 72 00 00       	call   80107f16 <setupkvm>
80100ca5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100ca8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100cac:	75 05                	jne    80100cb3 <exec+0xab>
    goto bad;
80100cae:	e9 64 03 00 00       	jmp    80101017 <exec+0x40f>

  // Load program into memory.
  sz = 0;
80100cb3:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cba:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100cc1:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100cc7:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100cca:	e9 fb 00 00 00       	jmp    80100dca <exec+0x1c2>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100ccf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100cd2:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100cd9:	00 
80100cda:	89 44 24 08          	mov    %eax,0x8(%esp)
80100cde:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100ce4:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ce8:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ceb:	89 04 24             	mov    %eax,(%esp)
80100cee:	e8 ca 11 00 00       	call   80101ebd <readi>
80100cf3:	83 f8 20             	cmp    $0x20,%eax
80100cf6:	74 05                	je     80100cfd <exec+0xf5>
      goto bad;
80100cf8:	e9 1a 03 00 00       	jmp    80101017 <exec+0x40f>
    if(ph.type != ELF_PROG_LOAD)
80100cfd:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100d03:	83 f8 01             	cmp    $0x1,%eax
80100d06:	74 05                	je     80100d0d <exec+0x105>
      continue;
80100d08:	e9 b1 00 00 00       	jmp    80100dbe <exec+0x1b6>
    if(ph.memsz < ph.filesz)
80100d0d:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100d13:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d19:	39 c2                	cmp    %eax,%edx
80100d1b:	73 05                	jae    80100d22 <exec+0x11a>
      goto bad;
80100d1d:	e9 f5 02 00 00       	jmp    80101017 <exec+0x40f>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d22:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d28:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d2e:	01 c2                	add    %eax,%edx
80100d30:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d36:	39 c2                	cmp    %eax,%edx
80100d38:	73 05                	jae    80100d3f <exec+0x137>
      goto bad;
80100d3a:	e9 d8 02 00 00       	jmp    80101017 <exec+0x40f>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d3f:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d45:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d4b:	01 d0                	add    %edx,%eax
80100d4d:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d51:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d54:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d58:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100d5b:	89 04 24             	mov    %eax,(%esp)
80100d5e:	e8 7f 75 00 00       	call   801082e2 <allocuvm>
80100d63:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d66:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d6a:	75 05                	jne    80100d71 <exec+0x169>
      goto bad;
80100d6c:	e9 a6 02 00 00       	jmp    80101017 <exec+0x40f>
    if(ph.vaddr % PGSIZE != 0)
80100d71:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d77:	25 ff 0f 00 00       	and    $0xfff,%eax
80100d7c:	85 c0                	test   %eax,%eax
80100d7e:	74 05                	je     80100d85 <exec+0x17d>
      goto bad;
80100d80:	e9 92 02 00 00       	jmp    80101017 <exec+0x40f>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100d85:	8b 8d f8 fe ff ff    	mov    -0x108(%ebp),%ecx
80100d8b:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100d91:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d97:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100d9b:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100d9f:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100da2:	89 54 24 08          	mov    %edx,0x8(%esp)
80100da6:	89 44 24 04          	mov    %eax,0x4(%esp)
80100daa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100dad:	89 04 24             	mov    %eax,(%esp)
80100db0:	e8 4a 74 00 00       	call   801081ff <loaduvm>
80100db5:	85 c0                	test   %eax,%eax
80100db7:	79 05                	jns    80100dbe <exec+0x1b6>
      goto bad;
80100db9:	e9 59 02 00 00       	jmp    80101017 <exec+0x40f>
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100dbe:	ff 45 ec             	incl   -0x14(%ebp)
80100dc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100dc4:	83 c0 20             	add    $0x20,%eax
80100dc7:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100dca:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
80100dd0:	0f b7 c0             	movzwl %ax,%eax
80100dd3:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100dd6:	0f 8f f3 fe ff ff    	jg     80100ccf <exec+0xc7>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100ddc:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100ddf:	89 04 24             	mov    %eax,(%esp)
80100de2:	e8 3e 0e 00 00       	call   80101c25 <iunlockput>
  end_op();
80100de7:	e8 b5 27 00 00       	call   801035a1 <end_op>
  ip = 0;
80100dec:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100df3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100df6:	05 ff 0f 00 00       	add    $0xfff,%eax
80100dfb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e00:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e03:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e06:	05 00 20 00 00       	add    $0x2000,%eax
80100e0b:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e12:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e19:	89 04 24             	mov    %eax,(%esp)
80100e1c:	e8 c1 74 00 00       	call   801082e2 <allocuvm>
80100e21:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e24:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e28:	75 05                	jne    80100e2f <exec+0x227>
    goto bad;
80100e2a:	e9 e8 01 00 00       	jmp    80101017 <exec+0x40f>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e2f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e32:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e37:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e3b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e3e:	89 04 24             	mov    %eax,(%esp)
80100e41:	e8 0c 77 00 00       	call   80108552 <clearpteu>
  sp = sz;
80100e46:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e49:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100e4c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100e53:	e9 95 00 00 00       	jmp    80100eed <exec+0x2e5>
    if(argc >= MAXARG)
80100e58:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100e5c:	76 05                	jbe    80100e63 <exec+0x25b>
      goto bad;
80100e5e:	e9 b4 01 00 00       	jmp    80101017 <exec+0x40f>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100e63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e66:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e70:	01 d0                	add    %edx,%eax
80100e72:	8b 00                	mov    (%eax),%eax
80100e74:	89 04 24             	mov    %eax,(%esp)
80100e77:	e8 a5 47 00 00       	call   80105621 <strlen>
80100e7c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100e7f:	29 c2                	sub    %eax,%edx
80100e81:	89 d0                	mov    %edx,%eax
80100e83:	48                   	dec    %eax
80100e84:	83 e0 fc             	and    $0xfffffffc,%eax
80100e87:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100e8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e94:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e97:	01 d0                	add    %edx,%eax
80100e99:	8b 00                	mov    (%eax),%eax
80100e9b:	89 04 24             	mov    %eax,(%esp)
80100e9e:	e8 7e 47 00 00       	call   80105621 <strlen>
80100ea3:	40                   	inc    %eax
80100ea4:	89 c2                	mov    %eax,%edx
80100ea6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea9:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100eb0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100eb3:	01 c8                	add    %ecx,%eax
80100eb5:	8b 00                	mov    (%eax),%eax
80100eb7:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100ebb:	89 44 24 08          	mov    %eax,0x8(%esp)
80100ebf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ec2:	89 44 24 04          	mov    %eax,0x4(%esp)
80100ec6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100ec9:	89 04 24             	mov    %eax,(%esp)
80100ecc:	e8 39 78 00 00       	call   8010870a <copyout>
80100ed1:	85 c0                	test   %eax,%eax
80100ed3:	79 05                	jns    80100eda <exec+0x2d2>
      goto bad;
80100ed5:	e9 3d 01 00 00       	jmp    80101017 <exec+0x40f>
    ustack[3+argc] = sp;
80100eda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100edd:	8d 50 03             	lea    0x3(%eax),%edx
80100ee0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ee3:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100eea:	ff 45 e4             	incl   -0x1c(%ebp)
80100eed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ef0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ef7:	8b 45 0c             	mov    0xc(%ebp),%eax
80100efa:	01 d0                	add    %edx,%eax
80100efc:	8b 00                	mov    (%eax),%eax
80100efe:	85 c0                	test   %eax,%eax
80100f00:	0f 85 52 ff ff ff    	jne    80100e58 <exec+0x250>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100f06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f09:	83 c0 03             	add    $0x3,%eax
80100f0c:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100f13:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f17:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100f1e:	ff ff ff 
  ustack[1] = argc;
80100f21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f24:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f2d:	40                   	inc    %eax
80100f2e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f35:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f38:	29 d0                	sub    %edx,%eax
80100f3a:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100f40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f43:	83 c0 04             	add    $0x4,%eax
80100f46:	c1 e0 02             	shl    $0x2,%eax
80100f49:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100f4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f4f:	83 c0 04             	add    $0x4,%eax
80100f52:	c1 e0 02             	shl    $0x2,%eax
80100f55:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100f59:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100f5f:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f63:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f66:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f6a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f6d:	89 04 24             	mov    %eax,(%esp)
80100f70:	e8 95 77 00 00       	call   8010870a <copyout>
80100f75:	85 c0                	test   %eax,%eax
80100f77:	79 05                	jns    80100f7e <exec+0x376>
    goto bad;
80100f79:	e9 99 00 00 00       	jmp    80101017 <exec+0x40f>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f7e:	8b 45 08             	mov    0x8(%ebp),%eax
80100f81:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f87:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100f8a:	eb 13                	jmp    80100f9f <exec+0x397>
    if(*s == '/')
80100f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f8f:	8a 00                	mov    (%eax),%al
80100f91:	3c 2f                	cmp    $0x2f,%al
80100f93:	75 07                	jne    80100f9c <exec+0x394>
      last = s+1;
80100f95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f98:	40                   	inc    %eax
80100f99:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100f9c:	ff 45 f4             	incl   -0xc(%ebp)
80100f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa2:	8a 00                	mov    (%eax),%al
80100fa4:	84 c0                	test   %al,%al
80100fa6:	75 e4                	jne    80100f8c <exec+0x384>
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100fa8:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fab:	8d 50 6c             	lea    0x6c(%eax),%edx
80100fae:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100fb5:	00 
80100fb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100fb9:	89 44 24 04          	mov    %eax,0x4(%esp)
80100fbd:	89 14 24             	mov    %edx,(%esp)
80100fc0:	e8 15 46 00 00       	call   801055da <safestrcpy>

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100fc5:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fc8:	8b 40 04             	mov    0x4(%eax),%eax
80100fcb:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100fce:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fd1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100fd4:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100fd7:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fda:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100fdd:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100fdf:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100fe2:	8b 40 18             	mov    0x18(%eax),%eax
80100fe5:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100feb:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100fee:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ff1:	8b 40 18             	mov    0x18(%eax),%eax
80100ff4:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ff7:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100ffa:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100ffd:	89 04 24             	mov    %eax,(%esp)
80101000:	e8 eb 6f 00 00       	call   80107ff0 <switchuvm>
  freevm(oldpgdir);
80101005:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101008:	89 04 24             	mov    %eax,(%esp)
8010100b:	e8 ac 74 00 00       	call   801084bc <freevm>
  return 0;
80101010:	b8 00 00 00 00       	mov    $0x0,%eax
80101015:	eb 2c                	jmp    80101043 <exec+0x43b>

 bad:
  if(pgdir)
80101017:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
8010101b:	74 0b                	je     80101028 <exec+0x420>
    freevm(pgdir);
8010101d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101020:	89 04 24             	mov    %eax,(%esp)
80101023:	e8 94 74 00 00       	call   801084bc <freevm>
  if(ip){
80101028:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010102c:	74 10                	je     8010103e <exec+0x436>
    iunlockput(ip);
8010102e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101031:	89 04 24             	mov    %eax,(%esp)
80101034:	e8 ec 0b 00 00       	call   80101c25 <iunlockput>
    end_op();
80101039:	e8 63 25 00 00       	call   801035a1 <end_op>
  }
  return -1;
8010103e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101043:	c9                   	leave  
80101044:	c3                   	ret    
80101045:	00 00                	add    %al,(%eax)
	...

80101048 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80101048:	55                   	push   %ebp
80101049:	89 e5                	mov    %esp,%ebp
8010104b:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
8010104e:	c7 44 24 04 4b 88 10 	movl   $0x8010884b,0x4(%esp)
80101055:	80 
80101056:	c7 04 24 a0 11 11 80 	movl   $0x801111a0,(%esp)
8010105d:	e8 e8 40 00 00       	call   8010514a <initlock>
}
80101062:	c9                   	leave  
80101063:	c3                   	ret    

80101064 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80101064:	55                   	push   %ebp
80101065:	89 e5                	mov    %esp,%ebp
80101067:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
8010106a:	c7 04 24 a0 11 11 80 	movl   $0x801111a0,(%esp)
80101071:	e8 f5 40 00 00       	call   8010516b <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101076:	c7 45 f4 d4 11 11 80 	movl   $0x801111d4,-0xc(%ebp)
8010107d:	eb 29                	jmp    801010a8 <filealloc+0x44>
    if(f->ref == 0){
8010107f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101082:	8b 40 04             	mov    0x4(%eax),%eax
80101085:	85 c0                	test   %eax,%eax
80101087:	75 1b                	jne    801010a4 <filealloc+0x40>
      f->ref = 1;
80101089:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010108c:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80101093:	c7 04 24 a0 11 11 80 	movl   $0x801111a0,(%esp)
8010109a:	e8 36 41 00 00       	call   801051d5 <release>
      return f;
8010109f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010a2:	eb 1e                	jmp    801010c2 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010a4:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801010a8:	81 7d f4 34 1b 11 80 	cmpl   $0x80111b34,-0xc(%ebp)
801010af:	72 ce                	jb     8010107f <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
801010b1:	c7 04 24 a0 11 11 80 	movl   $0x801111a0,(%esp)
801010b8:	e8 18 41 00 00       	call   801051d5 <release>
  return 0;
801010bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801010c2:	c9                   	leave  
801010c3:	c3                   	ret    

801010c4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
801010c4:	55                   	push   %ebp
801010c5:	89 e5                	mov    %esp,%ebp
801010c7:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
801010ca:	c7 04 24 a0 11 11 80 	movl   $0x801111a0,(%esp)
801010d1:	e8 95 40 00 00       	call   8010516b <acquire>
  if(f->ref < 1)
801010d6:	8b 45 08             	mov    0x8(%ebp),%eax
801010d9:	8b 40 04             	mov    0x4(%eax),%eax
801010dc:	85 c0                	test   %eax,%eax
801010de:	7f 0c                	jg     801010ec <filedup+0x28>
    panic("filedup");
801010e0:	c7 04 24 52 88 10 80 	movl   $0x80108852,(%esp)
801010e7:	e8 68 f4 ff ff       	call   80100554 <panic>
  f->ref++;
801010ec:	8b 45 08             	mov    0x8(%ebp),%eax
801010ef:	8b 40 04             	mov    0x4(%eax),%eax
801010f2:	8d 50 01             	lea    0x1(%eax),%edx
801010f5:	8b 45 08             	mov    0x8(%ebp),%eax
801010f8:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010fb:	c7 04 24 a0 11 11 80 	movl   $0x801111a0,(%esp)
80101102:	e8 ce 40 00 00       	call   801051d5 <release>
  return f;
80101107:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010110a:	c9                   	leave  
8010110b:	c3                   	ret    

8010110c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
8010110c:	55                   	push   %ebp
8010110d:	89 e5                	mov    %esp,%ebp
8010110f:	57                   	push   %edi
80101110:	56                   	push   %esi
80101111:	53                   	push   %ebx
80101112:	83 ec 3c             	sub    $0x3c,%esp
  struct file ff;

  acquire(&ftable.lock);
80101115:	c7 04 24 a0 11 11 80 	movl   $0x801111a0,(%esp)
8010111c:	e8 4a 40 00 00       	call   8010516b <acquire>
  if(f->ref < 1)
80101121:	8b 45 08             	mov    0x8(%ebp),%eax
80101124:	8b 40 04             	mov    0x4(%eax),%eax
80101127:	85 c0                	test   %eax,%eax
80101129:	7f 0c                	jg     80101137 <fileclose+0x2b>
    panic("fileclose");
8010112b:	c7 04 24 5a 88 10 80 	movl   $0x8010885a,(%esp)
80101132:	e8 1d f4 ff ff       	call   80100554 <panic>
  if(--f->ref > 0){
80101137:	8b 45 08             	mov    0x8(%ebp),%eax
8010113a:	8b 40 04             	mov    0x4(%eax),%eax
8010113d:	8d 50 ff             	lea    -0x1(%eax),%edx
80101140:	8b 45 08             	mov    0x8(%ebp),%eax
80101143:	89 50 04             	mov    %edx,0x4(%eax)
80101146:	8b 45 08             	mov    0x8(%ebp),%eax
80101149:	8b 40 04             	mov    0x4(%eax),%eax
8010114c:	85 c0                	test   %eax,%eax
8010114e:	7e 0e                	jle    8010115e <fileclose+0x52>
    release(&ftable.lock);
80101150:	c7 04 24 a0 11 11 80 	movl   $0x801111a0,(%esp)
80101157:	e8 79 40 00 00       	call   801051d5 <release>
8010115c:	eb 70                	jmp    801011ce <fileclose+0xc2>
    return;
  }
  ff = *f;
8010115e:	8b 45 08             	mov    0x8(%ebp),%eax
80101161:	8d 55 d0             	lea    -0x30(%ebp),%edx
80101164:	89 c3                	mov    %eax,%ebx
80101166:	b8 06 00 00 00       	mov    $0x6,%eax
8010116b:	89 d7                	mov    %edx,%edi
8010116d:	89 de                	mov    %ebx,%esi
8010116f:	89 c1                	mov    %eax,%ecx
80101171:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  f->ref = 0;
80101173:	8b 45 08             	mov    0x8(%ebp),%eax
80101176:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
8010117d:	8b 45 08             	mov    0x8(%ebp),%eax
80101180:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101186:	c7 04 24 a0 11 11 80 	movl   $0x801111a0,(%esp)
8010118d:	e8 43 40 00 00       	call   801051d5 <release>

  if(ff.type == FD_PIPE)
80101192:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101195:	83 f8 01             	cmp    $0x1,%eax
80101198:	75 17                	jne    801011b1 <fileclose+0xa5>
    pipeclose(ff.pipe, ff.writable);
8010119a:	8a 45 d9             	mov    -0x27(%ebp),%al
8010119d:	0f be d0             	movsbl %al,%edx
801011a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801011a3:	89 54 24 04          	mov    %edx,0x4(%esp)
801011a7:	89 04 24             	mov    %eax,(%esp)
801011aa:	e8 08 2d 00 00       	call   80103eb7 <pipeclose>
801011af:	eb 1d                	jmp    801011ce <fileclose+0xc2>
  else if(ff.type == FD_INODE){
801011b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801011b4:	83 f8 02             	cmp    $0x2,%eax
801011b7:	75 15                	jne    801011ce <fileclose+0xc2>
    begin_op();
801011b9:	e8 61 23 00 00       	call   8010351f <begin_op>
    iput(ff.ip);
801011be:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011c1:	89 04 24             	mov    %eax,(%esp)
801011c4:	e8 ab 09 00 00       	call   80101b74 <iput>
    end_op();
801011c9:	e8 d3 23 00 00       	call   801035a1 <end_op>
  }
}
801011ce:	83 c4 3c             	add    $0x3c,%esp
801011d1:	5b                   	pop    %ebx
801011d2:	5e                   	pop    %esi
801011d3:	5f                   	pop    %edi
801011d4:	5d                   	pop    %ebp
801011d5:	c3                   	ret    

801011d6 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801011d6:	55                   	push   %ebp
801011d7:	89 e5                	mov    %esp,%ebp
801011d9:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
801011dc:	8b 45 08             	mov    0x8(%ebp),%eax
801011df:	8b 00                	mov    (%eax),%eax
801011e1:	83 f8 02             	cmp    $0x2,%eax
801011e4:	75 38                	jne    8010121e <filestat+0x48>
    ilock(f->ip);
801011e6:	8b 45 08             	mov    0x8(%ebp),%eax
801011e9:	8b 40 10             	mov    0x10(%eax),%eax
801011ec:	89 04 24             	mov    %eax,(%esp)
801011ef:	e8 32 08 00 00       	call   80101a26 <ilock>
    stati(f->ip, st);
801011f4:	8b 45 08             	mov    0x8(%ebp),%eax
801011f7:	8b 40 10             	mov    0x10(%eax),%eax
801011fa:	8b 55 0c             	mov    0xc(%ebp),%edx
801011fd:	89 54 24 04          	mov    %edx,0x4(%esp)
80101201:	89 04 24             	mov    %eax,(%esp)
80101204:	e8 70 0c 00 00       	call   80101e79 <stati>
    iunlock(f->ip);
80101209:	8b 45 08             	mov    0x8(%ebp),%eax
8010120c:	8b 40 10             	mov    0x10(%eax),%eax
8010120f:	89 04 24             	mov    %eax,(%esp)
80101212:	e8 19 09 00 00       	call   80101b30 <iunlock>
    return 0;
80101217:	b8 00 00 00 00       	mov    $0x0,%eax
8010121c:	eb 05                	jmp    80101223 <filestat+0x4d>
  }
  return -1;
8010121e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101223:	c9                   	leave  
80101224:	c3                   	ret    

80101225 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101225:	55                   	push   %ebp
80101226:	89 e5                	mov    %esp,%ebp
80101228:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
8010122b:	8b 45 08             	mov    0x8(%ebp),%eax
8010122e:	8a 40 08             	mov    0x8(%eax),%al
80101231:	84 c0                	test   %al,%al
80101233:	75 0a                	jne    8010123f <fileread+0x1a>
    return -1;
80101235:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010123a:	e9 9f 00 00 00       	jmp    801012de <fileread+0xb9>
  if(f->type == FD_PIPE)
8010123f:	8b 45 08             	mov    0x8(%ebp),%eax
80101242:	8b 00                	mov    (%eax),%eax
80101244:	83 f8 01             	cmp    $0x1,%eax
80101247:	75 1e                	jne    80101267 <fileread+0x42>
    return piperead(f->pipe, addr, n);
80101249:	8b 45 08             	mov    0x8(%ebp),%eax
8010124c:	8b 40 0c             	mov    0xc(%eax),%eax
8010124f:	8b 55 10             	mov    0x10(%ebp),%edx
80101252:	89 54 24 08          	mov    %edx,0x8(%esp)
80101256:	8b 55 0c             	mov    0xc(%ebp),%edx
80101259:	89 54 24 04          	mov    %edx,0x4(%esp)
8010125d:	89 04 24             	mov    %eax,(%esp)
80101260:	e8 d0 2d 00 00       	call   80104035 <piperead>
80101265:	eb 77                	jmp    801012de <fileread+0xb9>
  if(f->type == FD_INODE){
80101267:	8b 45 08             	mov    0x8(%ebp),%eax
8010126a:	8b 00                	mov    (%eax),%eax
8010126c:	83 f8 02             	cmp    $0x2,%eax
8010126f:	75 61                	jne    801012d2 <fileread+0xad>
    ilock(f->ip);
80101271:	8b 45 08             	mov    0x8(%ebp),%eax
80101274:	8b 40 10             	mov    0x10(%eax),%eax
80101277:	89 04 24             	mov    %eax,(%esp)
8010127a:	e8 a7 07 00 00       	call   80101a26 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010127f:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101282:	8b 45 08             	mov    0x8(%ebp),%eax
80101285:	8b 50 14             	mov    0x14(%eax),%edx
80101288:	8b 45 08             	mov    0x8(%ebp),%eax
8010128b:	8b 40 10             	mov    0x10(%eax),%eax
8010128e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101292:	89 54 24 08          	mov    %edx,0x8(%esp)
80101296:	8b 55 0c             	mov    0xc(%ebp),%edx
80101299:	89 54 24 04          	mov    %edx,0x4(%esp)
8010129d:	89 04 24             	mov    %eax,(%esp)
801012a0:	e8 18 0c 00 00       	call   80101ebd <readi>
801012a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801012a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801012ac:	7e 11                	jle    801012bf <fileread+0x9a>
      f->off += r;
801012ae:	8b 45 08             	mov    0x8(%ebp),%eax
801012b1:	8b 50 14             	mov    0x14(%eax),%edx
801012b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012b7:	01 c2                	add    %eax,%edx
801012b9:	8b 45 08             	mov    0x8(%ebp),%eax
801012bc:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
801012bf:	8b 45 08             	mov    0x8(%ebp),%eax
801012c2:	8b 40 10             	mov    0x10(%eax),%eax
801012c5:	89 04 24             	mov    %eax,(%esp)
801012c8:	e8 63 08 00 00       	call   80101b30 <iunlock>
    return r;
801012cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801012d0:	eb 0c                	jmp    801012de <fileread+0xb9>
  }
  panic("fileread");
801012d2:	c7 04 24 64 88 10 80 	movl   $0x80108864,(%esp)
801012d9:	e8 76 f2 ff ff       	call   80100554 <panic>
}
801012de:	c9                   	leave  
801012df:	c3                   	ret    

801012e0 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801012e0:	55                   	push   %ebp
801012e1:	89 e5                	mov    %esp,%ebp
801012e3:	53                   	push   %ebx
801012e4:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
801012e7:	8b 45 08             	mov    0x8(%ebp),%eax
801012ea:	8a 40 09             	mov    0x9(%eax),%al
801012ed:	84 c0                	test   %al,%al
801012ef:	75 0a                	jne    801012fb <filewrite+0x1b>
    return -1;
801012f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012f6:	e9 20 01 00 00       	jmp    8010141b <filewrite+0x13b>
  if(f->type == FD_PIPE)
801012fb:	8b 45 08             	mov    0x8(%ebp),%eax
801012fe:	8b 00                	mov    (%eax),%eax
80101300:	83 f8 01             	cmp    $0x1,%eax
80101303:	75 21                	jne    80101326 <filewrite+0x46>
    return pipewrite(f->pipe, addr, n);
80101305:	8b 45 08             	mov    0x8(%ebp),%eax
80101308:	8b 40 0c             	mov    0xc(%eax),%eax
8010130b:	8b 55 10             	mov    0x10(%ebp),%edx
8010130e:	89 54 24 08          	mov    %edx,0x8(%esp)
80101312:	8b 55 0c             	mov    0xc(%ebp),%edx
80101315:	89 54 24 04          	mov    %edx,0x4(%esp)
80101319:	89 04 24             	mov    %eax,(%esp)
8010131c:	e8 28 2c 00 00       	call   80103f49 <pipewrite>
80101321:	e9 f5 00 00 00       	jmp    8010141b <filewrite+0x13b>
  if(f->type == FD_INODE){
80101326:	8b 45 08             	mov    0x8(%ebp),%eax
80101329:	8b 00                	mov    (%eax),%eax
8010132b:	83 f8 02             	cmp    $0x2,%eax
8010132e:	0f 85 db 00 00 00    	jne    8010140f <filewrite+0x12f>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
80101334:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
8010133b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
80101342:	e9 a8 00 00 00       	jmp    801013ef <filewrite+0x10f>
      int n1 = n - i;
80101347:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010134a:	8b 55 10             	mov    0x10(%ebp),%edx
8010134d:	29 c2                	sub    %eax,%edx
8010134f:	89 d0                	mov    %edx,%eax
80101351:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101354:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101357:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010135a:	7e 06                	jle    80101362 <filewrite+0x82>
        n1 = max;
8010135c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010135f:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101362:	e8 b8 21 00 00       	call   8010351f <begin_op>
      ilock(f->ip);
80101367:	8b 45 08             	mov    0x8(%ebp),%eax
8010136a:	8b 40 10             	mov    0x10(%eax),%eax
8010136d:	89 04 24             	mov    %eax,(%esp)
80101370:	e8 b1 06 00 00       	call   80101a26 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80101375:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101378:	8b 45 08             	mov    0x8(%ebp),%eax
8010137b:	8b 50 14             	mov    0x14(%eax),%edx
8010137e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80101381:	8b 45 0c             	mov    0xc(%ebp),%eax
80101384:	01 c3                	add    %eax,%ebx
80101386:	8b 45 08             	mov    0x8(%ebp),%eax
80101389:	8b 40 10             	mov    0x10(%eax),%eax
8010138c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101390:	89 54 24 08          	mov    %edx,0x8(%esp)
80101394:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101398:	89 04 24             	mov    %eax,(%esp)
8010139b:	e8 81 0c 00 00       	call   80102021 <writei>
801013a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
801013a3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013a7:	7e 11                	jle    801013ba <filewrite+0xda>
        f->off += r;
801013a9:	8b 45 08             	mov    0x8(%ebp),%eax
801013ac:	8b 50 14             	mov    0x14(%eax),%edx
801013af:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013b2:	01 c2                	add    %eax,%edx
801013b4:	8b 45 08             	mov    0x8(%ebp),%eax
801013b7:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801013ba:	8b 45 08             	mov    0x8(%ebp),%eax
801013bd:	8b 40 10             	mov    0x10(%eax),%eax
801013c0:	89 04 24             	mov    %eax,(%esp)
801013c3:	e8 68 07 00 00       	call   80101b30 <iunlock>
      end_op();
801013c8:	e8 d4 21 00 00       	call   801035a1 <end_op>

      if(r < 0)
801013cd:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801013d1:	79 02                	jns    801013d5 <filewrite+0xf5>
        break;
801013d3:	eb 26                	jmp    801013fb <filewrite+0x11b>
      if(r != n1)
801013d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013d8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801013db:	74 0c                	je     801013e9 <filewrite+0x109>
        panic("short filewrite");
801013dd:	c7 04 24 6d 88 10 80 	movl   $0x8010886d,(%esp)
801013e4:	e8 6b f1 ff ff       	call   80100554 <panic>
      i += r;
801013e9:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013ec:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801013ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f2:	3b 45 10             	cmp    0x10(%ebp),%eax
801013f5:	0f 8c 4c ff ff ff    	jl     80101347 <filewrite+0x67>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
801013fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013fe:	3b 45 10             	cmp    0x10(%ebp),%eax
80101401:	75 05                	jne    80101408 <filewrite+0x128>
80101403:	8b 45 10             	mov    0x10(%ebp),%eax
80101406:	eb 05                	jmp    8010140d <filewrite+0x12d>
80101408:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010140d:	eb 0c                	jmp    8010141b <filewrite+0x13b>
  }
  panic("filewrite");
8010140f:	c7 04 24 7d 88 10 80 	movl   $0x8010887d,(%esp)
80101416:	e8 39 f1 ff ff       	call   80100554 <panic>
}
8010141b:	83 c4 24             	add    $0x24,%esp
8010141e:	5b                   	pop    %ebx
8010141f:	5d                   	pop    %ebp
80101420:	c3                   	ret    
80101421:	00 00                	add    %al,(%eax)
	...

80101424 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101424:	55                   	push   %ebp
80101425:	89 e5                	mov    %esp,%ebp
80101427:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, 1);
8010142a:	8b 45 08             	mov    0x8(%ebp),%eax
8010142d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80101434:	00 
80101435:	89 04 24             	mov    %eax,(%esp)
80101438:	e8 78 ed ff ff       	call   801001b5 <bread>
8010143d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101443:	83 c0 5c             	add    $0x5c,%eax
80101446:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
8010144d:	00 
8010144e:	89 44 24 04          	mov    %eax,0x4(%esp)
80101452:	8b 45 0c             	mov    0xc(%ebp),%eax
80101455:	89 04 24             	mov    %eax,(%esp)
80101458:	e8 3a 40 00 00       	call   80105497 <memmove>
  brelse(bp);
8010145d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101460:	89 04 24             	mov    %eax,(%esp)
80101463:	e8 c4 ed ff ff       	call   8010022c <brelse>
}
80101468:	c9                   	leave  
80101469:	c3                   	ret    

8010146a <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010146a:	55                   	push   %ebp
8010146b:	89 e5                	mov    %esp,%ebp
8010146d:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101470:	8b 55 0c             	mov    0xc(%ebp),%edx
80101473:	8b 45 08             	mov    0x8(%ebp),%eax
80101476:	89 54 24 04          	mov    %edx,0x4(%esp)
8010147a:	89 04 24             	mov    %eax,(%esp)
8010147d:	e8 33 ed ff ff       	call   801001b5 <bread>
80101482:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101485:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101488:	83 c0 5c             	add    $0x5c,%eax
8010148b:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80101492:	00 
80101493:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010149a:	00 
8010149b:	89 04 24             	mov    %eax,(%esp)
8010149e:	e8 2b 3f 00 00       	call   801053ce <memset>
  log_write(bp);
801014a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014a6:	89 04 24             	mov    %eax,(%esp)
801014a9:	e8 75 22 00 00       	call   80103723 <log_write>
  brelse(bp);
801014ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014b1:	89 04 24             	mov    %eax,(%esp)
801014b4:	e8 73 ed ff ff       	call   8010022c <brelse>
}
801014b9:	c9                   	leave  
801014ba:	c3                   	ret    

801014bb <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801014bb:	55                   	push   %ebp
801014bc:	89 e5                	mov    %esp,%ebp
801014be:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
801014c1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
801014c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801014cf:	e9 03 01 00 00       	jmp    801015d7 <balloc+0x11c>
    bp = bread(dev, BBLOCK(b, sb));
801014d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014d7:	85 c0                	test   %eax,%eax
801014d9:	79 05                	jns    801014e0 <balloc+0x25>
801014db:	05 ff 0f 00 00       	add    $0xfff,%eax
801014e0:	c1 f8 0c             	sar    $0xc,%eax
801014e3:	89 c2                	mov    %eax,%edx
801014e5:	a1 b8 1b 11 80       	mov    0x80111bb8,%eax
801014ea:	01 d0                	add    %edx,%eax
801014ec:	89 44 24 04          	mov    %eax,0x4(%esp)
801014f0:	8b 45 08             	mov    0x8(%ebp),%eax
801014f3:	89 04 24             	mov    %eax,(%esp)
801014f6:	e8 ba ec ff ff       	call   801001b5 <bread>
801014fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014fe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101505:	e9 9b 00 00 00       	jmp    801015a5 <balloc+0xea>
      m = 1 << (bi % 8);
8010150a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010150d:	25 07 00 00 80       	and    $0x80000007,%eax
80101512:	85 c0                	test   %eax,%eax
80101514:	79 05                	jns    8010151b <balloc+0x60>
80101516:	48                   	dec    %eax
80101517:	83 c8 f8             	or     $0xfffffff8,%eax
8010151a:	40                   	inc    %eax
8010151b:	ba 01 00 00 00       	mov    $0x1,%edx
80101520:	88 c1                	mov    %al,%cl
80101522:	d3 e2                	shl    %cl,%edx
80101524:	89 d0                	mov    %edx,%eax
80101526:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101529:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010152c:	85 c0                	test   %eax,%eax
8010152e:	79 03                	jns    80101533 <balloc+0x78>
80101530:	83 c0 07             	add    $0x7,%eax
80101533:	c1 f8 03             	sar    $0x3,%eax
80101536:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101539:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
8010153d:	0f b6 c0             	movzbl %al,%eax
80101540:	23 45 e8             	and    -0x18(%ebp),%eax
80101543:	85 c0                	test   %eax,%eax
80101545:	75 5b                	jne    801015a2 <balloc+0xe7>
        bp->data[bi/8] |= m;  // Mark block in use.
80101547:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010154a:	85 c0                	test   %eax,%eax
8010154c:	79 03                	jns    80101551 <balloc+0x96>
8010154e:	83 c0 07             	add    $0x7,%eax
80101551:	c1 f8 03             	sar    $0x3,%eax
80101554:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101557:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
8010155b:	88 d1                	mov    %dl,%cl
8010155d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101560:	09 ca                	or     %ecx,%edx
80101562:	88 d1                	mov    %dl,%cl
80101564:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101567:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010156b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010156e:	89 04 24             	mov    %eax,(%esp)
80101571:	e8 ad 21 00 00       	call   80103723 <log_write>
        brelse(bp);
80101576:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101579:	89 04 24             	mov    %eax,(%esp)
8010157c:	e8 ab ec ff ff       	call   8010022c <brelse>
        bzero(dev, b + bi);
80101581:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101584:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101587:	01 c2                	add    %eax,%edx
80101589:	8b 45 08             	mov    0x8(%ebp),%eax
8010158c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101590:	89 04 24             	mov    %eax,(%esp)
80101593:	e8 d2 fe ff ff       	call   8010146a <bzero>
        return b + bi;
80101598:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010159b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010159e:	01 d0                	add    %edx,%eax
801015a0:	eb 51                	jmp    801015f3 <balloc+0x138>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801015a2:	ff 45 f0             	incl   -0x10(%ebp)
801015a5:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801015ac:	7f 17                	jg     801015c5 <balloc+0x10a>
801015ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015b4:	01 d0                	add    %edx,%eax
801015b6:	89 c2                	mov    %eax,%edx
801015b8:	a1 a0 1b 11 80       	mov    0x80111ba0,%eax
801015bd:	39 c2                	cmp    %eax,%edx
801015bf:	0f 82 45 ff ff ff    	jb     8010150a <balloc+0x4f>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
801015c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015c8:	89 04 24             	mov    %eax,(%esp)
801015cb:	e8 5c ec ff ff       	call   8010022c <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801015d0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801015d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015da:	a1 a0 1b 11 80       	mov    0x80111ba0,%eax
801015df:	39 c2                	cmp    %eax,%edx
801015e1:	0f 82 ed fe ff ff    	jb     801014d4 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801015e7:	c7 04 24 88 88 10 80 	movl   $0x80108888,(%esp)
801015ee:	e8 61 ef ff ff       	call   80100554 <panic>
}
801015f3:	c9                   	leave  
801015f4:	c3                   	ret    

801015f5 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015f5:	55                   	push   %ebp
801015f6:	89 e5                	mov    %esp,%ebp
801015f8:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015fb:	c7 44 24 04 a0 1b 11 	movl   $0x80111ba0,0x4(%esp)
80101602:	80 
80101603:	8b 45 08             	mov    0x8(%ebp),%eax
80101606:	89 04 24             	mov    %eax,(%esp)
80101609:	e8 16 fe ff ff       	call   80101424 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
8010160e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101611:	c1 e8 0c             	shr    $0xc,%eax
80101614:	89 c2                	mov    %eax,%edx
80101616:	a1 b8 1b 11 80       	mov    0x80111bb8,%eax
8010161b:	01 c2                	add    %eax,%edx
8010161d:	8b 45 08             	mov    0x8(%ebp),%eax
80101620:	89 54 24 04          	mov    %edx,0x4(%esp)
80101624:	89 04 24             	mov    %eax,(%esp)
80101627:	e8 89 eb ff ff       	call   801001b5 <bread>
8010162c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010162f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101632:	25 ff 0f 00 00       	and    $0xfff,%eax
80101637:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
8010163a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010163d:	25 07 00 00 80       	and    $0x80000007,%eax
80101642:	85 c0                	test   %eax,%eax
80101644:	79 05                	jns    8010164b <bfree+0x56>
80101646:	48                   	dec    %eax
80101647:	83 c8 f8             	or     $0xfffffff8,%eax
8010164a:	40                   	inc    %eax
8010164b:	ba 01 00 00 00       	mov    $0x1,%edx
80101650:	88 c1                	mov    %al,%cl
80101652:	d3 e2                	shl    %cl,%edx
80101654:	89 d0                	mov    %edx,%eax
80101656:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
80101659:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010165c:	85 c0                	test   %eax,%eax
8010165e:	79 03                	jns    80101663 <bfree+0x6e>
80101660:	83 c0 07             	add    $0x7,%eax
80101663:	c1 f8 03             	sar    $0x3,%eax
80101666:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101669:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
8010166d:	0f b6 c0             	movzbl %al,%eax
80101670:	23 45 ec             	and    -0x14(%ebp),%eax
80101673:	85 c0                	test   %eax,%eax
80101675:	75 0c                	jne    80101683 <bfree+0x8e>
    panic("freeing free block");
80101677:	c7 04 24 9e 88 10 80 	movl   $0x8010889e,(%esp)
8010167e:	e8 d1 ee ff ff       	call   80100554 <panic>
  bp->data[bi/8] &= ~m;
80101683:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101686:	85 c0                	test   %eax,%eax
80101688:	79 03                	jns    8010168d <bfree+0x98>
8010168a:	83 c0 07             	add    $0x7,%eax
8010168d:	c1 f8 03             	sar    $0x3,%eax
80101690:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101693:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
80101697:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010169a:	f7 d1                	not    %ecx
8010169c:	21 ca                	and    %ecx,%edx
8010169e:	88 d1                	mov    %dl,%cl
801016a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016a3:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
801016a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016aa:	89 04 24             	mov    %eax,(%esp)
801016ad:	e8 71 20 00 00       	call   80103723 <log_write>
  brelse(bp);
801016b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016b5:	89 04 24             	mov    %eax,(%esp)
801016b8:	e8 6f eb ff ff       	call   8010022c <brelse>
}
801016bd:	c9                   	leave  
801016be:	c3                   	ret    

801016bf <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801016bf:	55                   	push   %ebp
801016c0:	89 e5                	mov    %esp,%ebp
801016c2:	57                   	push   %edi
801016c3:	56                   	push   %esi
801016c4:	53                   	push   %ebx
801016c5:	83 ec 4c             	sub    $0x4c,%esp
  int i = 0;
801016c8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
801016cf:	c7 44 24 04 b1 88 10 	movl   $0x801088b1,0x4(%esp)
801016d6:	80 
801016d7:	c7 04 24 c0 1b 11 80 	movl   $0x80111bc0,(%esp)
801016de:	e8 67 3a 00 00       	call   8010514a <initlock>
  for(i = 0; i < NINODE; i++) {
801016e3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016ea:	eb 2b                	jmp    80101717 <iinit+0x58>
    initsleeplock(&icache.inode[i].lock, "inode");
801016ec:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016ef:	89 d0                	mov    %edx,%eax
801016f1:	c1 e0 03             	shl    $0x3,%eax
801016f4:	01 d0                	add    %edx,%eax
801016f6:	c1 e0 04             	shl    $0x4,%eax
801016f9:	83 c0 30             	add    $0x30,%eax
801016fc:	05 c0 1b 11 80       	add    $0x80111bc0,%eax
80101701:	83 c0 10             	add    $0x10,%eax
80101704:	c7 44 24 04 b8 88 10 	movl   $0x801088b8,0x4(%esp)
8010170b:	80 
8010170c:	89 04 24             	mov    %eax,(%esp)
8010170f:	e8 f8 38 00 00       	call   8010500c <initsleeplock>
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
80101714:	ff 45 e4             	incl   -0x1c(%ebp)
80101717:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
8010171b:	7e cf                	jle    801016ec <iinit+0x2d>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
8010171d:	c7 44 24 04 a0 1b 11 	movl   $0x80111ba0,0x4(%esp)
80101724:	80 
80101725:	8b 45 08             	mov    0x8(%ebp),%eax
80101728:	89 04 24             	mov    %eax,(%esp)
8010172b:	e8 f4 fc ff ff       	call   80101424 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101730:	a1 b8 1b 11 80       	mov    0x80111bb8,%eax
80101735:	8b 3d b4 1b 11 80    	mov    0x80111bb4,%edi
8010173b:	8b 35 b0 1b 11 80    	mov    0x80111bb0,%esi
80101741:	8b 1d ac 1b 11 80    	mov    0x80111bac,%ebx
80101747:	8b 0d a8 1b 11 80    	mov    0x80111ba8,%ecx
8010174d:	8b 15 a4 1b 11 80    	mov    0x80111ba4,%edx
80101753:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101756:	8b 15 a0 1b 11 80    	mov    0x80111ba0,%edx
8010175c:	89 44 24 1c          	mov    %eax,0x1c(%esp)
80101760:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101764:	89 74 24 14          	mov    %esi,0x14(%esp)
80101768:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010176c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101770:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101773:	89 44 24 08          	mov    %eax,0x8(%esp)
80101777:	89 d0                	mov    %edx,%eax
80101779:	89 44 24 04          	mov    %eax,0x4(%esp)
8010177d:	c7 04 24 c0 88 10 80 	movl   $0x801088c0,(%esp)
80101784:	e8 38 ec ff ff       	call   801003c1 <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101789:	83 c4 4c             	add    $0x4c,%esp
8010178c:	5b                   	pop    %ebx
8010178d:	5e                   	pop    %esi
8010178e:	5f                   	pop    %edi
8010178f:	5d                   	pop    %ebp
80101790:	c3                   	ret    

80101791 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101791:	55                   	push   %ebp
80101792:	89 e5                	mov    %esp,%ebp
80101794:	83 ec 28             	sub    $0x28,%esp
80101797:	8b 45 0c             	mov    0xc(%ebp),%eax
8010179a:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010179e:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801017a5:	e9 9b 00 00 00       	jmp    80101845 <ialloc+0xb4>
    bp = bread(dev, IBLOCK(inum, sb));
801017aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017ad:	c1 e8 03             	shr    $0x3,%eax
801017b0:	89 c2                	mov    %eax,%edx
801017b2:	a1 b4 1b 11 80       	mov    0x80111bb4,%eax
801017b7:	01 d0                	add    %edx,%eax
801017b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801017bd:	8b 45 08             	mov    0x8(%ebp),%eax
801017c0:	89 04 24             	mov    %eax,(%esp)
801017c3:	e8 ed e9 ff ff       	call   801001b5 <bread>
801017c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801017cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017ce:	8d 50 5c             	lea    0x5c(%eax),%edx
801017d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d4:	83 e0 07             	and    $0x7,%eax
801017d7:	c1 e0 06             	shl    $0x6,%eax
801017da:	01 d0                	add    %edx,%eax
801017dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801017df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017e2:	8b 00                	mov    (%eax),%eax
801017e4:	66 85 c0             	test   %ax,%ax
801017e7:	75 4e                	jne    80101837 <ialloc+0xa6>
      memset(dip, 0, sizeof(*dip));
801017e9:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
801017f0:	00 
801017f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801017f8:	00 
801017f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017fc:	89 04 24             	mov    %eax,(%esp)
801017ff:	e8 ca 3b 00 00       	call   801053ce <memset>
      dip->type = type;
80101804:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101807:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010180a:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
8010180d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101810:	89 04 24             	mov    %eax,(%esp)
80101813:	e8 0b 1f 00 00       	call   80103723 <log_write>
      brelse(bp);
80101818:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010181b:	89 04 24             	mov    %eax,(%esp)
8010181e:	e8 09 ea ff ff       	call   8010022c <brelse>
      return iget(dev, inum);
80101823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101826:	89 44 24 04          	mov    %eax,0x4(%esp)
8010182a:	8b 45 08             	mov    0x8(%ebp),%eax
8010182d:	89 04 24             	mov    %eax,(%esp)
80101830:	e8 ea 00 00 00       	call   8010191f <iget>
80101835:	eb 2a                	jmp    80101861 <ialloc+0xd0>
    }
    brelse(bp);
80101837:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010183a:	89 04 24             	mov    %eax,(%esp)
8010183d:	e8 ea e9 ff ff       	call   8010022c <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101842:	ff 45 f4             	incl   -0xc(%ebp)
80101845:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101848:	a1 a8 1b 11 80       	mov    0x80111ba8,%eax
8010184d:	39 c2                	cmp    %eax,%edx
8010184f:	0f 82 55 ff ff ff    	jb     801017aa <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101855:	c7 04 24 13 89 10 80 	movl   $0x80108913,(%esp)
8010185c:	e8 f3 ec ff ff       	call   80100554 <panic>
}
80101861:	c9                   	leave  
80101862:	c3                   	ret    

80101863 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101863:	55                   	push   %ebp
80101864:	89 e5                	mov    %esp,%ebp
80101866:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101869:	8b 45 08             	mov    0x8(%ebp),%eax
8010186c:	8b 40 04             	mov    0x4(%eax),%eax
8010186f:	c1 e8 03             	shr    $0x3,%eax
80101872:	89 c2                	mov    %eax,%edx
80101874:	a1 b4 1b 11 80       	mov    0x80111bb4,%eax
80101879:	01 c2                	add    %eax,%edx
8010187b:	8b 45 08             	mov    0x8(%ebp),%eax
8010187e:	8b 00                	mov    (%eax),%eax
80101880:	89 54 24 04          	mov    %edx,0x4(%esp)
80101884:	89 04 24             	mov    %eax,(%esp)
80101887:	e8 29 e9 ff ff       	call   801001b5 <bread>
8010188c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010188f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101892:	8d 50 5c             	lea    0x5c(%eax),%edx
80101895:	8b 45 08             	mov    0x8(%ebp),%eax
80101898:	8b 40 04             	mov    0x4(%eax),%eax
8010189b:	83 e0 07             	and    $0x7,%eax
8010189e:	c1 e0 06             	shl    $0x6,%eax
801018a1:	01 d0                	add    %edx,%eax
801018a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801018a6:	8b 45 08             	mov    0x8(%ebp),%eax
801018a9:	8b 40 50             	mov    0x50(%eax),%eax
801018ac:	8b 55 f0             	mov    -0x10(%ebp),%edx
801018af:	66 89 02             	mov    %ax,(%edx)
  dip->major = ip->major;
801018b2:	8b 45 08             	mov    0x8(%ebp),%eax
801018b5:	66 8b 40 52          	mov    0x52(%eax),%ax
801018b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801018bc:	66 89 42 02          	mov    %ax,0x2(%edx)
  dip->minor = ip->minor;
801018c0:	8b 45 08             	mov    0x8(%ebp),%eax
801018c3:	8b 40 54             	mov    0x54(%eax),%eax
801018c6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801018c9:	66 89 42 04          	mov    %ax,0x4(%edx)
  dip->nlink = ip->nlink;
801018cd:	8b 45 08             	mov    0x8(%ebp),%eax
801018d0:	66 8b 40 56          	mov    0x56(%eax),%ax
801018d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801018d7:	66 89 42 06          	mov    %ax,0x6(%edx)
  dip->size = ip->size;
801018db:	8b 45 08             	mov    0x8(%ebp),%eax
801018de:	8b 50 58             	mov    0x58(%eax),%edx
801018e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018e4:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801018e7:	8b 45 08             	mov    0x8(%ebp),%eax
801018ea:	8d 50 5c             	lea    0x5c(%eax),%edx
801018ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018f0:	83 c0 0c             	add    $0xc,%eax
801018f3:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
801018fa:	00 
801018fb:	89 54 24 04          	mov    %edx,0x4(%esp)
801018ff:	89 04 24             	mov    %eax,(%esp)
80101902:	e8 90 3b 00 00       	call   80105497 <memmove>
  log_write(bp);
80101907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190a:	89 04 24             	mov    %eax,(%esp)
8010190d:	e8 11 1e 00 00       	call   80103723 <log_write>
  brelse(bp);
80101912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101915:	89 04 24             	mov    %eax,(%esp)
80101918:	e8 0f e9 ff ff       	call   8010022c <brelse>
}
8010191d:	c9                   	leave  
8010191e:	c3                   	ret    

8010191f <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
8010191f:	55                   	push   %ebp
80101920:	89 e5                	mov    %esp,%ebp
80101922:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
80101925:	c7 04 24 c0 1b 11 80 	movl   $0x80111bc0,(%esp)
8010192c:	e8 3a 38 00 00       	call   8010516b <acquire>

  // Is the inode already cached?
  empty = 0;
80101931:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101938:	c7 45 f4 f4 1b 11 80 	movl   $0x80111bf4,-0xc(%ebp)
8010193f:	eb 5c                	jmp    8010199d <iget+0x7e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101941:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101944:	8b 40 08             	mov    0x8(%eax),%eax
80101947:	85 c0                	test   %eax,%eax
80101949:	7e 35                	jle    80101980 <iget+0x61>
8010194b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010194e:	8b 00                	mov    (%eax),%eax
80101950:	3b 45 08             	cmp    0x8(%ebp),%eax
80101953:	75 2b                	jne    80101980 <iget+0x61>
80101955:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101958:	8b 40 04             	mov    0x4(%eax),%eax
8010195b:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010195e:	75 20                	jne    80101980 <iget+0x61>
      ip->ref++;
80101960:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101963:	8b 40 08             	mov    0x8(%eax),%eax
80101966:	8d 50 01             	lea    0x1(%eax),%edx
80101969:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010196c:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010196f:	c7 04 24 c0 1b 11 80 	movl   $0x80111bc0,(%esp)
80101976:	e8 5a 38 00 00       	call   801051d5 <release>
      return ip;
8010197b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010197e:	eb 72                	jmp    801019f2 <iget+0xd3>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101980:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101984:	75 10                	jne    80101996 <iget+0x77>
80101986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101989:	8b 40 08             	mov    0x8(%eax),%eax
8010198c:	85 c0                	test   %eax,%eax
8010198e:	75 06                	jne    80101996 <iget+0x77>
      empty = ip;
80101990:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101993:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101996:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010199d:	81 7d f4 14 38 11 80 	cmpl   $0x80113814,-0xc(%ebp)
801019a4:	72 9b                	jb     80101941 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019aa:	75 0c                	jne    801019b8 <iget+0x99>
    panic("iget: no inodes");
801019ac:	c7 04 24 25 89 10 80 	movl   $0x80108925,(%esp)
801019b3:	e8 9c eb ff ff       	call   80100554 <panic>

  ip = empty;
801019b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801019be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c1:	8b 55 08             	mov    0x8(%ebp),%edx
801019c4:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801019c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c9:	8b 55 0c             	mov    0xc(%ebp),%edx
801019cc:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801019cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
801019d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019dc:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
801019e3:	c7 04 24 c0 1b 11 80 	movl   $0x80111bc0,(%esp)
801019ea:	e8 e6 37 00 00       	call   801051d5 <release>

  return ip;
801019ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019f2:	c9                   	leave  
801019f3:	c3                   	ret    

801019f4 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019f4:	55                   	push   %ebp
801019f5:	89 e5                	mov    %esp,%ebp
801019f7:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
801019fa:	c7 04 24 c0 1b 11 80 	movl   $0x80111bc0,(%esp)
80101a01:	e8 65 37 00 00       	call   8010516b <acquire>
  ip->ref++;
80101a06:	8b 45 08             	mov    0x8(%ebp),%eax
80101a09:	8b 40 08             	mov    0x8(%eax),%eax
80101a0c:	8d 50 01             	lea    0x1(%eax),%edx
80101a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a12:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a15:	c7 04 24 c0 1b 11 80 	movl   $0x80111bc0,(%esp)
80101a1c:	e8 b4 37 00 00       	call   801051d5 <release>
  return ip;
80101a21:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a24:	c9                   	leave  
80101a25:	c3                   	ret    

80101a26 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a26:	55                   	push   %ebp
80101a27:	89 e5                	mov    %esp,%ebp
80101a29:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101a2c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a30:	74 0a                	je     80101a3c <ilock+0x16>
80101a32:	8b 45 08             	mov    0x8(%ebp),%eax
80101a35:	8b 40 08             	mov    0x8(%eax),%eax
80101a38:	85 c0                	test   %eax,%eax
80101a3a:	7f 0c                	jg     80101a48 <ilock+0x22>
    panic("ilock");
80101a3c:	c7 04 24 35 89 10 80 	movl   $0x80108935,(%esp)
80101a43:	e8 0c eb ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101a48:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4b:	83 c0 0c             	add    $0xc,%eax
80101a4e:	89 04 24             	mov    %eax,(%esp)
80101a51:	e8 f0 35 00 00       	call   80105046 <acquiresleep>

  if(ip->valid == 0){
80101a56:	8b 45 08             	mov    0x8(%ebp),%eax
80101a59:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a5c:	85 c0                	test   %eax,%eax
80101a5e:	0f 85 ca 00 00 00    	jne    80101b2e <ilock+0x108>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a64:	8b 45 08             	mov    0x8(%ebp),%eax
80101a67:	8b 40 04             	mov    0x4(%eax),%eax
80101a6a:	c1 e8 03             	shr    $0x3,%eax
80101a6d:	89 c2                	mov    %eax,%edx
80101a6f:	a1 b4 1b 11 80       	mov    0x80111bb4,%eax
80101a74:	01 c2                	add    %eax,%edx
80101a76:	8b 45 08             	mov    0x8(%ebp),%eax
80101a79:	8b 00                	mov    (%eax),%eax
80101a7b:	89 54 24 04          	mov    %edx,0x4(%esp)
80101a7f:	89 04 24             	mov    %eax,(%esp)
80101a82:	e8 2e e7 ff ff       	call   801001b5 <bread>
80101a87:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a8d:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a90:	8b 45 08             	mov    0x8(%ebp),%eax
80101a93:	8b 40 04             	mov    0x4(%eax),%eax
80101a96:	83 e0 07             	and    $0x7,%eax
80101a99:	c1 e0 06             	shl    $0x6,%eax
80101a9c:	01 d0                	add    %edx,%eax
80101a9e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101aa1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aa4:	8b 00                	mov    (%eax),%eax
80101aa6:	8b 55 08             	mov    0x8(%ebp),%edx
80101aa9:	66 89 42 50          	mov    %ax,0x50(%edx)
    ip->major = dip->major;
80101aad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab0:	66 8b 40 02          	mov    0x2(%eax),%ax
80101ab4:	8b 55 08             	mov    0x8(%ebp),%edx
80101ab7:	66 89 42 52          	mov    %ax,0x52(%edx)
    ip->minor = dip->minor;
80101abb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101abe:	8b 40 04             	mov    0x4(%eax),%eax
80101ac1:	8b 55 08             	mov    0x8(%ebp),%edx
80101ac4:	66 89 42 54          	mov    %ax,0x54(%edx)
    ip->nlink = dip->nlink;
80101ac8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101acb:	66 8b 40 06          	mov    0x6(%eax),%ax
80101acf:	8b 55 08             	mov    0x8(%ebp),%edx
80101ad2:	66 89 42 56          	mov    %ax,0x56(%edx)
    ip->size = dip->size;
80101ad6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ad9:	8b 50 08             	mov    0x8(%eax),%edx
80101adc:	8b 45 08             	mov    0x8(%ebp),%eax
80101adf:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101ae2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ae5:	8d 50 0c             	lea    0xc(%eax),%edx
80101ae8:	8b 45 08             	mov    0x8(%ebp),%eax
80101aeb:	83 c0 5c             	add    $0x5c,%eax
80101aee:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101af5:	00 
80101af6:	89 54 24 04          	mov    %edx,0x4(%esp)
80101afa:	89 04 24             	mov    %eax,(%esp)
80101afd:	e8 95 39 00 00       	call   80105497 <memmove>
    brelse(bp);
80101b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b05:	89 04 24             	mov    %eax,(%esp)
80101b08:	e8 1f e7 ff ff       	call   8010022c <brelse>
    ip->valid = 1;
80101b0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101b10:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b17:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1a:	8b 40 50             	mov    0x50(%eax),%eax
80101b1d:	66 85 c0             	test   %ax,%ax
80101b20:	75 0c                	jne    80101b2e <ilock+0x108>
      panic("ilock: no type");
80101b22:	c7 04 24 3b 89 10 80 	movl   $0x8010893b,(%esp)
80101b29:	e8 26 ea ff ff       	call   80100554 <panic>
  }
}
80101b2e:	c9                   	leave  
80101b2f:	c3                   	ret    

80101b30 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b30:	55                   	push   %ebp
80101b31:	89 e5                	mov    %esp,%ebp
80101b33:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b36:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b3a:	74 1c                	je     80101b58 <iunlock+0x28>
80101b3c:	8b 45 08             	mov    0x8(%ebp),%eax
80101b3f:	83 c0 0c             	add    $0xc,%eax
80101b42:	89 04 24             	mov    %eax,(%esp)
80101b45:	e8 99 35 00 00       	call   801050e3 <holdingsleep>
80101b4a:	85 c0                	test   %eax,%eax
80101b4c:	74 0a                	je     80101b58 <iunlock+0x28>
80101b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b51:	8b 40 08             	mov    0x8(%eax),%eax
80101b54:	85 c0                	test   %eax,%eax
80101b56:	7f 0c                	jg     80101b64 <iunlock+0x34>
    panic("iunlock");
80101b58:	c7 04 24 4a 89 10 80 	movl   $0x8010894a,(%esp)
80101b5f:	e8 f0 e9 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101b64:	8b 45 08             	mov    0x8(%ebp),%eax
80101b67:	83 c0 0c             	add    $0xc,%eax
80101b6a:	89 04 24             	mov    %eax,(%esp)
80101b6d:	e8 2f 35 00 00       	call   801050a1 <releasesleep>
}
80101b72:	c9                   	leave  
80101b73:	c3                   	ret    

80101b74 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b74:	55                   	push   %ebp
80101b75:	89 e5                	mov    %esp,%ebp
80101b77:	83 ec 28             	sub    $0x28,%esp
  acquiresleep(&ip->lock);
80101b7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b7d:	83 c0 0c             	add    $0xc,%eax
80101b80:	89 04 24             	mov    %eax,(%esp)
80101b83:	e8 be 34 00 00       	call   80105046 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101b88:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8b:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b8e:	85 c0                	test   %eax,%eax
80101b90:	74 5c                	je     80101bee <iput+0x7a>
80101b92:	8b 45 08             	mov    0x8(%ebp),%eax
80101b95:	66 8b 40 56          	mov    0x56(%eax),%ax
80101b99:	66 85 c0             	test   %ax,%ax
80101b9c:	75 50                	jne    80101bee <iput+0x7a>
    acquire(&icache.lock);
80101b9e:	c7 04 24 c0 1b 11 80 	movl   $0x80111bc0,(%esp)
80101ba5:	e8 c1 35 00 00       	call   8010516b <acquire>
    int r = ip->ref;
80101baa:	8b 45 08             	mov    0x8(%ebp),%eax
80101bad:	8b 40 08             	mov    0x8(%eax),%eax
80101bb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101bb3:	c7 04 24 c0 1b 11 80 	movl   $0x80111bc0,(%esp)
80101bba:	e8 16 36 00 00       	call   801051d5 <release>
    if(r == 1){
80101bbf:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101bc3:	75 29                	jne    80101bee <iput+0x7a>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101bc5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc8:	89 04 24             	mov    %eax,(%esp)
80101bcb:	e8 86 01 00 00       	call   80101d56 <itrunc>
      ip->type = 0;
80101bd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd3:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bd9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bdc:	89 04 24             	mov    %eax,(%esp)
80101bdf:	e8 7f fc ff ff       	call   80101863 <iupdate>
      ip->valid = 0;
80101be4:	8b 45 08             	mov    0x8(%ebp),%eax
80101be7:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bee:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf1:	83 c0 0c             	add    $0xc,%eax
80101bf4:	89 04 24             	mov    %eax,(%esp)
80101bf7:	e8 a5 34 00 00       	call   801050a1 <releasesleep>

  acquire(&icache.lock);
80101bfc:	c7 04 24 c0 1b 11 80 	movl   $0x80111bc0,(%esp)
80101c03:	e8 63 35 00 00       	call   8010516b <acquire>
  ip->ref--;
80101c08:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0b:	8b 40 08             	mov    0x8(%eax),%eax
80101c0e:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c11:	8b 45 08             	mov    0x8(%ebp),%eax
80101c14:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c17:	c7 04 24 c0 1b 11 80 	movl   $0x80111bc0,(%esp)
80101c1e:	e8 b2 35 00 00       	call   801051d5 <release>
}
80101c23:	c9                   	leave  
80101c24:	c3                   	ret    

80101c25 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c25:	55                   	push   %ebp
80101c26:	89 e5                	mov    %esp,%ebp
80101c28:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101c2b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c2e:	89 04 24             	mov    %eax,(%esp)
80101c31:	e8 fa fe ff ff       	call   80101b30 <iunlock>
  iput(ip);
80101c36:	8b 45 08             	mov    0x8(%ebp),%eax
80101c39:	89 04 24             	mov    %eax,(%esp)
80101c3c:	e8 33 ff ff ff       	call   80101b74 <iput>
}
80101c41:	c9                   	leave  
80101c42:	c3                   	ret    

80101c43 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c43:	55                   	push   %ebp
80101c44:	89 e5                	mov    %esp,%ebp
80101c46:	53                   	push   %ebx
80101c47:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c4a:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c4e:	77 3e                	ja     80101c8e <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101c50:	8b 45 08             	mov    0x8(%ebp),%eax
80101c53:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c56:	83 c2 14             	add    $0x14,%edx
80101c59:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c5d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c60:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c64:	75 20                	jne    80101c86 <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c66:	8b 45 08             	mov    0x8(%ebp),%eax
80101c69:	8b 00                	mov    (%eax),%eax
80101c6b:	89 04 24             	mov    %eax,(%esp)
80101c6e:	e8 48 f8 ff ff       	call   801014bb <balloc>
80101c73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c76:	8b 45 08             	mov    0x8(%ebp),%eax
80101c79:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c7c:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c82:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c89:	e9 c2 00 00 00       	jmp    80101d50 <bmap+0x10d>
  }
  bn -= NDIRECT;
80101c8e:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c92:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c96:	0f 87 a8 00 00 00    	ja     80101d44 <bmap+0x101>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c9c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c9f:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101ca5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cac:	75 1c                	jne    80101cca <bmap+0x87>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cae:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb1:	8b 00                	mov    (%eax),%eax
80101cb3:	89 04 24             	mov    %eax,(%esp)
80101cb6:	e8 00 f8 ff ff       	call   801014bb <balloc>
80101cbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cc4:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccd:	8b 00                	mov    (%eax),%eax
80101ccf:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cd2:	89 54 24 04          	mov    %edx,0x4(%esp)
80101cd6:	89 04 24             	mov    %eax,(%esp)
80101cd9:	e8 d7 e4 ff ff       	call   801001b5 <bread>
80101cde:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ce1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ce4:	83 c0 5c             	add    $0x5c,%eax
80101ce7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cea:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ced:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cf4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cf7:	01 d0                	add    %edx,%eax
80101cf9:	8b 00                	mov    (%eax),%eax
80101cfb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cfe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d02:	75 30                	jne    80101d34 <bmap+0xf1>
      a[bn] = addr = balloc(ip->dev);
80101d04:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d07:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d0e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d11:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101d14:	8b 45 08             	mov    0x8(%ebp),%eax
80101d17:	8b 00                	mov    (%eax),%eax
80101d19:	89 04 24             	mov    %eax,(%esp)
80101d1c:	e8 9a f7 ff ff       	call   801014bb <balloc>
80101d21:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d27:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101d29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d2c:	89 04 24             	mov    %eax,(%esp)
80101d2f:	e8 ef 19 00 00       	call   80103723 <log_write>
    }
    brelse(bp);
80101d34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d37:	89 04 24             	mov    %eax,(%esp)
80101d3a:	e8 ed e4 ff ff       	call   8010022c <brelse>
    return addr;
80101d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d42:	eb 0c                	jmp    80101d50 <bmap+0x10d>
  }

  panic("bmap: out of range");
80101d44:	c7 04 24 52 89 10 80 	movl   $0x80108952,(%esp)
80101d4b:	e8 04 e8 ff ff       	call   80100554 <panic>
}
80101d50:	83 c4 24             	add    $0x24,%esp
80101d53:	5b                   	pop    %ebx
80101d54:	5d                   	pop    %ebp
80101d55:	c3                   	ret    

80101d56 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d56:	55                   	push   %ebp
80101d57:	89 e5                	mov    %esp,%ebp
80101d59:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d5c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d63:	eb 43                	jmp    80101da8 <itrunc+0x52>
    if(ip->addrs[i]){
80101d65:	8b 45 08             	mov    0x8(%ebp),%eax
80101d68:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d6b:	83 c2 14             	add    $0x14,%edx
80101d6e:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d72:	85 c0                	test   %eax,%eax
80101d74:	74 2f                	je     80101da5 <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101d76:	8b 45 08             	mov    0x8(%ebp),%eax
80101d79:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d7c:	83 c2 14             	add    $0x14,%edx
80101d7f:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101d83:	8b 45 08             	mov    0x8(%ebp),%eax
80101d86:	8b 00                	mov    (%eax),%eax
80101d88:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d8c:	89 04 24             	mov    %eax,(%esp)
80101d8f:	e8 61 f8 ff ff       	call   801015f5 <bfree>
      ip->addrs[i] = 0;
80101d94:	8b 45 08             	mov    0x8(%ebp),%eax
80101d97:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d9a:	83 c2 14             	add    $0x14,%edx
80101d9d:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101da4:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101da5:	ff 45 f4             	incl   -0xc(%ebp)
80101da8:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dac:	7e b7                	jle    80101d65 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101dae:	8b 45 08             	mov    0x8(%ebp),%eax
80101db1:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101db7:	85 c0                	test   %eax,%eax
80101db9:	0f 84 a3 00 00 00    	je     80101e62 <itrunc+0x10c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dbf:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc2:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101dc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101dcb:	8b 00                	mov    (%eax),%eax
80101dcd:	89 54 24 04          	mov    %edx,0x4(%esp)
80101dd1:	89 04 24             	mov    %eax,(%esp)
80101dd4:	e8 dc e3 ff ff       	call   801001b5 <bread>
80101dd9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101ddc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ddf:	83 c0 5c             	add    $0x5c,%eax
80101de2:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101de5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101dec:	eb 3a                	jmp    80101e28 <itrunc+0xd2>
      if(a[j])
80101dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101df1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101df8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101dfb:	01 d0                	add    %edx,%eax
80101dfd:	8b 00                	mov    (%eax),%eax
80101dff:	85 c0                	test   %eax,%eax
80101e01:	74 22                	je     80101e25 <itrunc+0xcf>
        bfree(ip->dev, a[j]);
80101e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e06:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e10:	01 d0                	add    %edx,%eax
80101e12:	8b 10                	mov    (%eax),%edx
80101e14:	8b 45 08             	mov    0x8(%ebp),%eax
80101e17:	8b 00                	mov    (%eax),%eax
80101e19:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e1d:	89 04 24             	mov    %eax,(%esp)
80101e20:	e8 d0 f7 ff ff       	call   801015f5 <bfree>
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101e25:	ff 45 f0             	incl   -0x10(%ebp)
80101e28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e2b:	83 f8 7f             	cmp    $0x7f,%eax
80101e2e:	76 be                	jbe    80101dee <itrunc+0x98>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101e30:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e33:	89 04 24             	mov    %eax,(%esp)
80101e36:	e8 f1 e3 ff ff       	call   8010022c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3e:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e44:	8b 45 08             	mov    0x8(%ebp),%eax
80101e47:	8b 00                	mov    (%eax),%eax
80101e49:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e4d:	89 04 24             	mov    %eax,(%esp)
80101e50:	e8 a0 f7 ff ff       	call   801015f5 <bfree>
    ip->addrs[NDIRECT] = 0;
80101e55:	8b 45 08             	mov    0x8(%ebp),%eax
80101e58:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e5f:	00 00 00 
  }

  ip->size = 0;
80101e62:	8b 45 08             	mov    0x8(%ebp),%eax
80101e65:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e6c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e6f:	89 04 24             	mov    %eax,(%esp)
80101e72:	e8 ec f9 ff ff       	call   80101863 <iupdate>
}
80101e77:	c9                   	leave  
80101e78:	c3                   	ret    

80101e79 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e79:	55                   	push   %ebp
80101e7a:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7f:	8b 00                	mov    (%eax),%eax
80101e81:	89 c2                	mov    %eax,%edx
80101e83:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e86:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e89:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8c:	8b 50 04             	mov    0x4(%eax),%edx
80101e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e92:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e95:	8b 45 08             	mov    0x8(%ebp),%eax
80101e98:	8b 40 50             	mov    0x50(%eax),%eax
80101e9b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101e9e:	66 89 02             	mov    %ax,(%edx)
  st->nlink = ip->nlink;
80101ea1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea4:	66 8b 40 56          	mov    0x56(%eax),%ax
80101ea8:	8b 55 0c             	mov    0xc(%ebp),%edx
80101eab:	66 89 42 0c          	mov    %ax,0xc(%edx)
  st->size = ip->size;
80101eaf:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb2:	8b 50 58             	mov    0x58(%eax),%edx
80101eb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb8:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ebb:	5d                   	pop    %ebp
80101ebc:	c3                   	ret    

80101ebd <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ebd:	55                   	push   %ebp
80101ebe:	89 e5                	mov    %esp,%ebp
80101ec0:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ec3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec6:	8b 40 50             	mov    0x50(%eax),%eax
80101ec9:	66 83 f8 03          	cmp    $0x3,%ax
80101ecd:	75 60                	jne    80101f2f <readi+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed2:	66 8b 40 52          	mov    0x52(%eax),%ax
80101ed6:	66 85 c0             	test   %ax,%ax
80101ed9:	78 20                	js     80101efb <readi+0x3e>
80101edb:	8b 45 08             	mov    0x8(%ebp),%eax
80101ede:	66 8b 40 52          	mov    0x52(%eax),%ax
80101ee2:	66 83 f8 09          	cmp    $0x9,%ax
80101ee6:	7f 13                	jg     80101efb <readi+0x3e>
80101ee8:	8b 45 08             	mov    0x8(%ebp),%eax
80101eeb:	66 8b 40 52          	mov    0x52(%eax),%ax
80101eef:	98                   	cwtl   
80101ef0:	8b 04 c5 40 1b 11 80 	mov    -0x7feee4c0(,%eax,8),%eax
80101ef7:	85 c0                	test   %eax,%eax
80101ef9:	75 0a                	jne    80101f05 <readi+0x48>
      return -1;
80101efb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f00:	e9 1a 01 00 00       	jmp    8010201f <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101f05:	8b 45 08             	mov    0x8(%ebp),%eax
80101f08:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f0c:	98                   	cwtl   
80101f0d:	8b 04 c5 40 1b 11 80 	mov    -0x7feee4c0(,%eax,8),%eax
80101f14:	8b 55 14             	mov    0x14(%ebp),%edx
80101f17:	89 54 24 08          	mov    %edx,0x8(%esp)
80101f1b:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f1e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f22:	8b 55 08             	mov    0x8(%ebp),%edx
80101f25:	89 14 24             	mov    %edx,(%esp)
80101f28:	ff d0                	call   *%eax
80101f2a:	e9 f0 00 00 00       	jmp    8010201f <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f32:	8b 40 58             	mov    0x58(%eax),%eax
80101f35:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f38:	72 0d                	jb     80101f47 <readi+0x8a>
80101f3a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f3d:	8b 55 10             	mov    0x10(%ebp),%edx
80101f40:	01 d0                	add    %edx,%eax
80101f42:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f45:	73 0a                	jae    80101f51 <readi+0x94>
    return -1;
80101f47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f4c:	e9 ce 00 00 00       	jmp    8010201f <readi+0x162>
  if(off + n > ip->size)
80101f51:	8b 45 14             	mov    0x14(%ebp),%eax
80101f54:	8b 55 10             	mov    0x10(%ebp),%edx
80101f57:	01 c2                	add    %eax,%edx
80101f59:	8b 45 08             	mov    0x8(%ebp),%eax
80101f5c:	8b 40 58             	mov    0x58(%eax),%eax
80101f5f:	39 c2                	cmp    %eax,%edx
80101f61:	76 0c                	jbe    80101f6f <readi+0xb2>
    n = ip->size - off;
80101f63:	8b 45 08             	mov    0x8(%ebp),%eax
80101f66:	8b 40 58             	mov    0x58(%eax),%eax
80101f69:	2b 45 10             	sub    0x10(%ebp),%eax
80101f6c:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f6f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f76:	e9 95 00 00 00       	jmp    80102010 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f7b:	8b 45 10             	mov    0x10(%ebp),%eax
80101f7e:	c1 e8 09             	shr    $0x9,%eax
80101f81:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f85:	8b 45 08             	mov    0x8(%ebp),%eax
80101f88:	89 04 24             	mov    %eax,(%esp)
80101f8b:	e8 b3 fc ff ff       	call   80101c43 <bmap>
80101f90:	8b 55 08             	mov    0x8(%ebp),%edx
80101f93:	8b 12                	mov    (%edx),%edx
80101f95:	89 44 24 04          	mov    %eax,0x4(%esp)
80101f99:	89 14 24             	mov    %edx,(%esp)
80101f9c:	e8 14 e2 ff ff       	call   801001b5 <bread>
80101fa1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fa4:	8b 45 10             	mov    0x10(%ebp),%eax
80101fa7:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fac:	89 c2                	mov    %eax,%edx
80101fae:	b8 00 02 00 00       	mov    $0x200,%eax
80101fb3:	29 d0                	sub    %edx,%eax
80101fb5:	89 c1                	mov    %eax,%ecx
80101fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fba:	8b 55 14             	mov    0x14(%ebp),%edx
80101fbd:	29 c2                	sub    %eax,%edx
80101fbf:	89 c8                	mov    %ecx,%eax
80101fc1:	39 d0                	cmp    %edx,%eax
80101fc3:	76 02                	jbe    80101fc7 <readi+0x10a>
80101fc5:	89 d0                	mov    %edx,%eax
80101fc7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fca:	8b 45 10             	mov    0x10(%ebp),%eax
80101fcd:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fd2:	8d 50 50             	lea    0x50(%eax),%edx
80101fd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fd8:	01 d0                	add    %edx,%eax
80101fda:	8d 50 0c             	lea    0xc(%eax),%edx
80101fdd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fe0:	89 44 24 08          	mov    %eax,0x8(%esp)
80101fe4:	89 54 24 04          	mov    %edx,0x4(%esp)
80101fe8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101feb:	89 04 24             	mov    %eax,(%esp)
80101fee:	e8 a4 34 00 00       	call   80105497 <memmove>
    brelse(bp);
80101ff3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ff6:	89 04 24             	mov    %eax,(%esp)
80101ff9:	e8 2e e2 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ffe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102001:	01 45 f4             	add    %eax,-0xc(%ebp)
80102004:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102007:	01 45 10             	add    %eax,0x10(%ebp)
8010200a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010200d:	01 45 0c             	add    %eax,0xc(%ebp)
80102010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102013:	3b 45 14             	cmp    0x14(%ebp),%eax
80102016:	0f 82 5f ff ff ff    	jb     80101f7b <readi+0xbe>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010201c:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010201f:	c9                   	leave  
80102020:	c3                   	ret    

80102021 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102021:	55                   	push   %ebp
80102022:	89 e5                	mov    %esp,%ebp
80102024:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102027:	8b 45 08             	mov    0x8(%ebp),%eax
8010202a:	8b 40 50             	mov    0x50(%eax),%eax
8010202d:	66 83 f8 03          	cmp    $0x3,%ax
80102031:	75 60                	jne    80102093 <writei+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102033:	8b 45 08             	mov    0x8(%ebp),%eax
80102036:	66 8b 40 52          	mov    0x52(%eax),%ax
8010203a:	66 85 c0             	test   %ax,%ax
8010203d:	78 20                	js     8010205f <writei+0x3e>
8010203f:	8b 45 08             	mov    0x8(%ebp),%eax
80102042:	66 8b 40 52          	mov    0x52(%eax),%ax
80102046:	66 83 f8 09          	cmp    $0x9,%ax
8010204a:	7f 13                	jg     8010205f <writei+0x3e>
8010204c:	8b 45 08             	mov    0x8(%ebp),%eax
8010204f:	66 8b 40 52          	mov    0x52(%eax),%ax
80102053:	98                   	cwtl   
80102054:	8b 04 c5 44 1b 11 80 	mov    -0x7feee4bc(,%eax,8),%eax
8010205b:	85 c0                	test   %eax,%eax
8010205d:	75 0a                	jne    80102069 <writei+0x48>
      return -1;
8010205f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102064:	e9 45 01 00 00       	jmp    801021ae <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80102069:	8b 45 08             	mov    0x8(%ebp),%eax
8010206c:	66 8b 40 52          	mov    0x52(%eax),%ax
80102070:	98                   	cwtl   
80102071:	8b 04 c5 44 1b 11 80 	mov    -0x7feee4bc(,%eax,8),%eax
80102078:	8b 55 14             	mov    0x14(%ebp),%edx
8010207b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010207f:	8b 55 0c             	mov    0xc(%ebp),%edx
80102082:	89 54 24 04          	mov    %edx,0x4(%esp)
80102086:	8b 55 08             	mov    0x8(%ebp),%edx
80102089:	89 14 24             	mov    %edx,(%esp)
8010208c:	ff d0                	call   *%eax
8010208e:	e9 1b 01 00 00       	jmp    801021ae <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
80102093:	8b 45 08             	mov    0x8(%ebp),%eax
80102096:	8b 40 58             	mov    0x58(%eax),%eax
80102099:	3b 45 10             	cmp    0x10(%ebp),%eax
8010209c:	72 0d                	jb     801020ab <writei+0x8a>
8010209e:	8b 45 14             	mov    0x14(%ebp),%eax
801020a1:	8b 55 10             	mov    0x10(%ebp),%edx
801020a4:	01 d0                	add    %edx,%eax
801020a6:	3b 45 10             	cmp    0x10(%ebp),%eax
801020a9:	73 0a                	jae    801020b5 <writei+0x94>
    return -1;
801020ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b0:	e9 f9 00 00 00       	jmp    801021ae <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
801020b5:	8b 45 14             	mov    0x14(%ebp),%eax
801020b8:	8b 55 10             	mov    0x10(%ebp),%edx
801020bb:	01 d0                	add    %edx,%eax
801020bd:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020c2:	76 0a                	jbe    801020ce <writei+0xad>
    return -1;
801020c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020c9:	e9 e0 00 00 00       	jmp    801021ae <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020d5:	e9 a0 00 00 00       	jmp    8010217a <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020da:	8b 45 10             	mov    0x10(%ebp),%eax
801020dd:	c1 e8 09             	shr    $0x9,%eax
801020e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801020e4:	8b 45 08             	mov    0x8(%ebp),%eax
801020e7:	89 04 24             	mov    %eax,(%esp)
801020ea:	e8 54 fb ff ff       	call   80101c43 <bmap>
801020ef:	8b 55 08             	mov    0x8(%ebp),%edx
801020f2:	8b 12                	mov    (%edx),%edx
801020f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801020f8:	89 14 24             	mov    %edx,(%esp)
801020fb:	e8 b5 e0 ff ff       	call   801001b5 <bread>
80102100:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102103:	8b 45 10             	mov    0x10(%ebp),%eax
80102106:	25 ff 01 00 00       	and    $0x1ff,%eax
8010210b:	89 c2                	mov    %eax,%edx
8010210d:	b8 00 02 00 00       	mov    $0x200,%eax
80102112:	29 d0                	sub    %edx,%eax
80102114:	89 c1                	mov    %eax,%ecx
80102116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102119:	8b 55 14             	mov    0x14(%ebp),%edx
8010211c:	29 c2                	sub    %eax,%edx
8010211e:	89 c8                	mov    %ecx,%eax
80102120:	39 d0                	cmp    %edx,%eax
80102122:	76 02                	jbe    80102126 <writei+0x105>
80102124:	89 d0                	mov    %edx,%eax
80102126:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102129:	8b 45 10             	mov    0x10(%ebp),%eax
8010212c:	25 ff 01 00 00       	and    $0x1ff,%eax
80102131:	8d 50 50             	lea    0x50(%eax),%edx
80102134:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102137:	01 d0                	add    %edx,%eax
80102139:	8d 50 0c             	lea    0xc(%eax),%edx
8010213c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010213f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102143:	8b 45 0c             	mov    0xc(%ebp),%eax
80102146:	89 44 24 04          	mov    %eax,0x4(%esp)
8010214a:	89 14 24             	mov    %edx,(%esp)
8010214d:	e8 45 33 00 00       	call   80105497 <memmove>
    log_write(bp);
80102152:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102155:	89 04 24             	mov    %eax,(%esp)
80102158:	e8 c6 15 00 00       	call   80103723 <log_write>
    brelse(bp);
8010215d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102160:	89 04 24             	mov    %eax,(%esp)
80102163:	e8 c4 e0 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102168:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010216b:	01 45 f4             	add    %eax,-0xc(%ebp)
8010216e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102171:	01 45 10             	add    %eax,0x10(%ebp)
80102174:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102177:	01 45 0c             	add    %eax,0xc(%ebp)
8010217a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010217d:	3b 45 14             	cmp    0x14(%ebp),%eax
80102180:	0f 82 54 ff ff ff    	jb     801020da <writei+0xb9>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102186:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010218a:	74 1f                	je     801021ab <writei+0x18a>
8010218c:	8b 45 08             	mov    0x8(%ebp),%eax
8010218f:	8b 40 58             	mov    0x58(%eax),%eax
80102192:	3b 45 10             	cmp    0x10(%ebp),%eax
80102195:	73 14                	jae    801021ab <writei+0x18a>
    ip->size = off;
80102197:	8b 45 08             	mov    0x8(%ebp),%eax
8010219a:	8b 55 10             	mov    0x10(%ebp),%edx
8010219d:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801021a0:	8b 45 08             	mov    0x8(%ebp),%eax
801021a3:	89 04 24             	mov    %eax,(%esp)
801021a6:	e8 b8 f6 ff ff       	call   80101863 <iupdate>
  }
  return n;
801021ab:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021ae:	c9                   	leave  
801021af:	c3                   	ret    

801021b0 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b0:	55                   	push   %ebp
801021b1:	89 e5                	mov    %esp,%ebp
801021b3:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801021b6:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801021bd:	00 
801021be:	8b 45 0c             	mov    0xc(%ebp),%eax
801021c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801021c5:	8b 45 08             	mov    0x8(%ebp),%eax
801021c8:	89 04 24             	mov    %eax,(%esp)
801021cb:	e8 66 33 00 00       	call   80105536 <strncmp>
}
801021d0:	c9                   	leave  
801021d1:	c3                   	ret    

801021d2 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021d2:	55                   	push   %ebp
801021d3:	89 e5                	mov    %esp,%ebp
801021d5:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021d8:	8b 45 08             	mov    0x8(%ebp),%eax
801021db:	8b 40 50             	mov    0x50(%eax),%eax
801021de:	66 83 f8 01          	cmp    $0x1,%ax
801021e2:	74 0c                	je     801021f0 <dirlookup+0x1e>
    panic("dirlookup not DIR");
801021e4:	c7 04 24 65 89 10 80 	movl   $0x80108965,(%esp)
801021eb:	e8 64 e3 ff ff       	call   80100554 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021f7:	e9 86 00 00 00       	jmp    80102282 <dirlookup+0xb0>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021fc:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102203:	00 
80102204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102207:	89 44 24 08          	mov    %eax,0x8(%esp)
8010220b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010220e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102212:	8b 45 08             	mov    0x8(%ebp),%eax
80102215:	89 04 24             	mov    %eax,(%esp)
80102218:	e8 a0 fc ff ff       	call   80101ebd <readi>
8010221d:	83 f8 10             	cmp    $0x10,%eax
80102220:	74 0c                	je     8010222e <dirlookup+0x5c>
      panic("dirlookup read");
80102222:	c7 04 24 77 89 10 80 	movl   $0x80108977,(%esp)
80102229:	e8 26 e3 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
8010222e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102231:	66 85 c0             	test   %ax,%ax
80102234:	75 02                	jne    80102238 <dirlookup+0x66>
      continue;
80102236:	eb 46                	jmp    8010227e <dirlookup+0xac>
    if(namecmp(name, de.name) == 0){
80102238:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010223b:	83 c0 02             	add    $0x2,%eax
8010223e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102242:	8b 45 0c             	mov    0xc(%ebp),%eax
80102245:	89 04 24             	mov    %eax,(%esp)
80102248:	e8 63 ff ff ff       	call   801021b0 <namecmp>
8010224d:	85 c0                	test   %eax,%eax
8010224f:	75 2d                	jne    8010227e <dirlookup+0xac>
      // entry matches path element
      if(poff)
80102251:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102255:	74 08                	je     8010225f <dirlookup+0x8d>
        *poff = off;
80102257:	8b 45 10             	mov    0x10(%ebp),%eax
8010225a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010225d:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
8010225f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102262:	0f b7 c0             	movzwl %ax,%eax
80102265:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102268:	8b 45 08             	mov    0x8(%ebp),%eax
8010226b:	8b 00                	mov    (%eax),%eax
8010226d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102270:	89 54 24 04          	mov    %edx,0x4(%esp)
80102274:	89 04 24             	mov    %eax,(%esp)
80102277:	e8 a3 f6 ff ff       	call   8010191f <iget>
8010227c:	eb 18                	jmp    80102296 <dirlookup+0xc4>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010227e:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102282:	8b 45 08             	mov    0x8(%ebp),%eax
80102285:	8b 40 58             	mov    0x58(%eax),%eax
80102288:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010228b:	0f 87 6b ff ff ff    	ja     801021fc <dirlookup+0x2a>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102291:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102296:	c9                   	leave  
80102297:	c3                   	ret    

80102298 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102298:	55                   	push   %ebp
80102299:	89 e5                	mov    %esp,%ebp
8010229b:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010229e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801022a5:	00 
801022a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801022a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801022ad:	8b 45 08             	mov    0x8(%ebp),%eax
801022b0:	89 04 24             	mov    %eax,(%esp)
801022b3:	e8 1a ff ff ff       	call   801021d2 <dirlookup>
801022b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022bb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022bf:	74 15                	je     801022d6 <dirlink+0x3e>
    iput(ip);
801022c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022c4:	89 04 24             	mov    %eax,(%esp)
801022c7:	e8 a8 f8 ff ff       	call   80101b74 <iput>
    return -1;
801022cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022d1:	e9 b6 00 00 00       	jmp    8010238c <dirlink+0xf4>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022d6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022dd:	eb 45                	jmp    80102324 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e2:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801022e9:	00 
801022ea:	89 44 24 08          	mov    %eax,0x8(%esp)
801022ee:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801022f5:	8b 45 08             	mov    0x8(%ebp),%eax
801022f8:	89 04 24             	mov    %eax,(%esp)
801022fb:	e8 bd fb ff ff       	call   80101ebd <readi>
80102300:	83 f8 10             	cmp    $0x10,%eax
80102303:	74 0c                	je     80102311 <dirlink+0x79>
      panic("dirlink read");
80102305:	c7 04 24 86 89 10 80 	movl   $0x80108986,(%esp)
8010230c:	e8 43 e2 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
80102311:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102314:	66 85 c0             	test   %ax,%ax
80102317:	75 02                	jne    8010231b <dirlink+0x83>
      break;
80102319:	eb 16                	jmp    80102331 <dirlink+0x99>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010231b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010231e:	83 c0 10             	add    $0x10,%eax
80102321:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102324:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102327:	8b 45 08             	mov    0x8(%ebp),%eax
8010232a:	8b 40 58             	mov    0x58(%eax),%eax
8010232d:	39 c2                	cmp    %eax,%edx
8010232f:	72 ae                	jb     801022df <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
80102331:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102338:	00 
80102339:	8b 45 0c             	mov    0xc(%ebp),%eax
8010233c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102340:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102343:	83 c0 02             	add    $0x2,%eax
80102346:	89 04 24             	mov    %eax,(%esp)
80102349:	e8 36 32 00 00       	call   80105584 <strncpy>
  de.inum = inum;
8010234e:	8b 45 10             	mov    0x10(%ebp),%eax
80102351:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102355:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102358:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010235f:	00 
80102360:	89 44 24 08          	mov    %eax,0x8(%esp)
80102364:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102367:	89 44 24 04          	mov    %eax,0x4(%esp)
8010236b:	8b 45 08             	mov    0x8(%ebp),%eax
8010236e:	89 04 24             	mov    %eax,(%esp)
80102371:	e8 ab fc ff ff       	call   80102021 <writei>
80102376:	83 f8 10             	cmp    $0x10,%eax
80102379:	74 0c                	je     80102387 <dirlink+0xef>
    panic("dirlink");
8010237b:	c7 04 24 93 89 10 80 	movl   $0x80108993,(%esp)
80102382:	e8 cd e1 ff ff       	call   80100554 <panic>

  return 0;
80102387:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010238c:	c9                   	leave  
8010238d:	c3                   	ret    

8010238e <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
8010238e:	55                   	push   %ebp
8010238f:	89 e5                	mov    %esp,%ebp
80102391:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
80102394:	eb 03                	jmp    80102399 <skipelem+0xb>
    path++;
80102396:	ff 45 08             	incl   0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102399:	8b 45 08             	mov    0x8(%ebp),%eax
8010239c:	8a 00                	mov    (%eax),%al
8010239e:	3c 2f                	cmp    $0x2f,%al
801023a0:	74 f4                	je     80102396 <skipelem+0x8>
    path++;
  if(*path == 0)
801023a2:	8b 45 08             	mov    0x8(%ebp),%eax
801023a5:	8a 00                	mov    (%eax),%al
801023a7:	84 c0                	test   %al,%al
801023a9:	75 0a                	jne    801023b5 <skipelem+0x27>
    return 0;
801023ab:	b8 00 00 00 00       	mov    $0x0,%eax
801023b0:	e9 81 00 00 00       	jmp    80102436 <skipelem+0xa8>
  s = path;
801023b5:	8b 45 08             	mov    0x8(%ebp),%eax
801023b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801023bb:	eb 03                	jmp    801023c0 <skipelem+0x32>
    path++;
801023bd:	ff 45 08             	incl   0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801023c0:	8b 45 08             	mov    0x8(%ebp),%eax
801023c3:	8a 00                	mov    (%eax),%al
801023c5:	3c 2f                	cmp    $0x2f,%al
801023c7:	74 09                	je     801023d2 <skipelem+0x44>
801023c9:	8b 45 08             	mov    0x8(%ebp),%eax
801023cc:	8a 00                	mov    (%eax),%al
801023ce:	84 c0                	test   %al,%al
801023d0:	75 eb                	jne    801023bd <skipelem+0x2f>
    path++;
  len = path - s;
801023d2:	8b 55 08             	mov    0x8(%ebp),%edx
801023d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023d8:	29 c2                	sub    %eax,%edx
801023da:	89 d0                	mov    %edx,%eax
801023dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023df:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023e3:	7e 1c                	jle    80102401 <skipelem+0x73>
    memmove(name, s, DIRSIZ);
801023e5:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801023ec:	00 
801023ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801023f4:	8b 45 0c             	mov    0xc(%ebp),%eax
801023f7:	89 04 24             	mov    %eax,(%esp)
801023fa:	e8 98 30 00 00       	call   80105497 <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801023ff:	eb 29                	jmp    8010242a <skipelem+0x9c>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102401:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102404:	89 44 24 08          	mov    %eax,0x8(%esp)
80102408:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010240b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010240f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102412:	89 04 24             	mov    %eax,(%esp)
80102415:	e8 7d 30 00 00       	call   80105497 <memmove>
    name[len] = 0;
8010241a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010241d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102420:	01 d0                	add    %edx,%eax
80102422:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102425:	eb 03                	jmp    8010242a <skipelem+0x9c>
    path++;
80102427:	ff 45 08             	incl   0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010242a:	8b 45 08             	mov    0x8(%ebp),%eax
8010242d:	8a 00                	mov    (%eax),%al
8010242f:	3c 2f                	cmp    $0x2f,%al
80102431:	74 f4                	je     80102427 <skipelem+0x99>
    path++;
  return path;
80102433:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102436:	c9                   	leave  
80102437:	c3                   	ret    

80102438 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102438:	55                   	push   %ebp
80102439:	89 e5                	mov    %esp,%ebp
8010243b:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010243e:	8b 45 08             	mov    0x8(%ebp),%eax
80102441:	8a 00                	mov    (%eax),%al
80102443:	3c 2f                	cmp    $0x2f,%al
80102445:	75 1c                	jne    80102463 <namex+0x2b>
    ip = iget(ROOTDEV, ROOTINO);
80102447:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010244e:	00 
8010244f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102456:	e8 c4 f4 ff ff       	call   8010191f <iget>
8010245b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
8010245e:	e9 ac 00 00 00       	jmp    8010250f <namex+0xd7>
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80102463:	e8 b7 1d 00 00       	call   8010421f <myproc>
80102468:	8b 40 68             	mov    0x68(%eax),%eax
8010246b:	89 04 24             	mov    %eax,(%esp)
8010246e:	e8 81 f5 ff ff       	call   801019f4 <idup>
80102473:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102476:	e9 94 00 00 00       	jmp    8010250f <namex+0xd7>
    ilock(ip);
8010247b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010247e:	89 04 24             	mov    %eax,(%esp)
80102481:	e8 a0 f5 ff ff       	call   80101a26 <ilock>
    if(ip->type != T_DIR){
80102486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102489:	8b 40 50             	mov    0x50(%eax),%eax
8010248c:	66 83 f8 01          	cmp    $0x1,%ax
80102490:	74 15                	je     801024a7 <namex+0x6f>
      iunlockput(ip);
80102492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102495:	89 04 24             	mov    %eax,(%esp)
80102498:	e8 88 f7 ff ff       	call   80101c25 <iunlockput>
      return 0;
8010249d:	b8 00 00 00 00       	mov    $0x0,%eax
801024a2:	e9 a2 00 00 00       	jmp    80102549 <namex+0x111>
    }
    if(nameiparent && *path == '\0'){
801024a7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024ab:	74 1c                	je     801024c9 <namex+0x91>
801024ad:	8b 45 08             	mov    0x8(%ebp),%eax
801024b0:	8a 00                	mov    (%eax),%al
801024b2:	84 c0                	test   %al,%al
801024b4:	75 13                	jne    801024c9 <namex+0x91>
      // Stop one level early.
      iunlock(ip);
801024b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024b9:	89 04 24             	mov    %eax,(%esp)
801024bc:	e8 6f f6 ff ff       	call   80101b30 <iunlock>
      return ip;
801024c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024c4:	e9 80 00 00 00       	jmp    80102549 <namex+0x111>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801024d0:	00 
801024d1:	8b 45 10             	mov    0x10(%ebp),%eax
801024d4:	89 44 24 04          	mov    %eax,0x4(%esp)
801024d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024db:	89 04 24             	mov    %eax,(%esp)
801024de:	e8 ef fc ff ff       	call   801021d2 <dirlookup>
801024e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024e6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024ea:	75 12                	jne    801024fe <namex+0xc6>
      iunlockput(ip);
801024ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024ef:	89 04 24             	mov    %eax,(%esp)
801024f2:	e8 2e f7 ff ff       	call   80101c25 <iunlockput>
      return 0;
801024f7:	b8 00 00 00 00       	mov    $0x0,%eax
801024fc:	eb 4b                	jmp    80102549 <namex+0x111>
    }
    iunlockput(ip);
801024fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102501:	89 04 24             	mov    %eax,(%esp)
80102504:	e8 1c f7 ff ff       	call   80101c25 <iunlockput>
    ip = next;
80102509:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010250c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
8010250f:	8b 45 10             	mov    0x10(%ebp),%eax
80102512:	89 44 24 04          	mov    %eax,0x4(%esp)
80102516:	8b 45 08             	mov    0x8(%ebp),%eax
80102519:	89 04 24             	mov    %eax,(%esp)
8010251c:	e8 6d fe ff ff       	call   8010238e <skipelem>
80102521:	89 45 08             	mov    %eax,0x8(%ebp)
80102524:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102528:	0f 85 4d ff ff ff    	jne    8010247b <namex+0x43>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
8010252e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102532:	74 12                	je     80102546 <namex+0x10e>
    iput(ip);
80102534:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102537:	89 04 24             	mov    %eax,(%esp)
8010253a:	e8 35 f6 ff ff       	call   80101b74 <iput>
    return 0;
8010253f:	b8 00 00 00 00       	mov    $0x0,%eax
80102544:	eb 03                	jmp    80102549 <namex+0x111>
  }
  return ip;
80102546:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102549:	c9                   	leave  
8010254a:	c3                   	ret    

8010254b <namei>:

struct inode*
namei(char *path)
{
8010254b:	55                   	push   %ebp
8010254c:	89 e5                	mov    %esp,%ebp
8010254e:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102551:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102554:	89 44 24 08          	mov    %eax,0x8(%esp)
80102558:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010255f:	00 
80102560:	8b 45 08             	mov    0x8(%ebp),%eax
80102563:	89 04 24             	mov    %eax,(%esp)
80102566:	e8 cd fe ff ff       	call   80102438 <namex>
}
8010256b:	c9                   	leave  
8010256c:	c3                   	ret    

8010256d <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010256d:	55                   	push   %ebp
8010256e:	89 e5                	mov    %esp,%ebp
80102570:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102573:	8b 45 0c             	mov    0xc(%ebp),%eax
80102576:	89 44 24 08          	mov    %eax,0x8(%esp)
8010257a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102581:	00 
80102582:	8b 45 08             	mov    0x8(%ebp),%eax
80102585:	89 04 24             	mov    %eax,(%esp)
80102588:	e8 ab fe ff ff       	call   80102438 <namex>
}
8010258d:	c9                   	leave  
8010258e:	c3                   	ret    
	...

80102590 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102590:	55                   	push   %ebp
80102591:	89 e5                	mov    %esp,%ebp
80102593:	83 ec 14             	sub    $0x14,%esp
80102596:	8b 45 08             	mov    0x8(%ebp),%eax
80102599:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010259d:	8b 45 ec             	mov    -0x14(%ebp),%eax
801025a0:	89 c2                	mov    %eax,%edx
801025a2:	ec                   	in     (%dx),%al
801025a3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801025a6:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801025a9:	c9                   	leave  
801025aa:	c3                   	ret    

801025ab <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801025ab:	55                   	push   %ebp
801025ac:	89 e5                	mov    %esp,%ebp
801025ae:	57                   	push   %edi
801025af:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801025b0:	8b 55 08             	mov    0x8(%ebp),%edx
801025b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025b6:	8b 45 10             	mov    0x10(%ebp),%eax
801025b9:	89 cb                	mov    %ecx,%ebx
801025bb:	89 df                	mov    %ebx,%edi
801025bd:	89 c1                	mov    %eax,%ecx
801025bf:	fc                   	cld    
801025c0:	f3 6d                	rep insl (%dx),%es:(%edi)
801025c2:	89 c8                	mov    %ecx,%eax
801025c4:	89 fb                	mov    %edi,%ebx
801025c6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025c9:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801025cc:	5b                   	pop    %ebx
801025cd:	5f                   	pop    %edi
801025ce:	5d                   	pop    %ebp
801025cf:	c3                   	ret    

801025d0 <outb>:

static inline void
outb(ushort port, uchar data)
{
801025d0:	55                   	push   %ebp
801025d1:	89 e5                	mov    %esp,%ebp
801025d3:	83 ec 08             	sub    $0x8,%esp
801025d6:	8b 45 08             	mov    0x8(%ebp),%eax
801025d9:	8b 55 0c             	mov    0xc(%ebp),%edx
801025dc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801025e0:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801025e3:	8a 45 f8             	mov    -0x8(%ebp),%al
801025e6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801025e9:	ee                   	out    %al,(%dx)
}
801025ea:	c9                   	leave  
801025eb:	c3                   	ret    

801025ec <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801025ec:	55                   	push   %ebp
801025ed:	89 e5                	mov    %esp,%ebp
801025ef:	56                   	push   %esi
801025f0:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025f1:	8b 55 08             	mov    0x8(%ebp),%edx
801025f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025f7:	8b 45 10             	mov    0x10(%ebp),%eax
801025fa:	89 cb                	mov    %ecx,%ebx
801025fc:	89 de                	mov    %ebx,%esi
801025fe:	89 c1                	mov    %eax,%ecx
80102600:	fc                   	cld    
80102601:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102603:	89 c8                	mov    %ecx,%eax
80102605:	89 f3                	mov    %esi,%ebx
80102607:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010260a:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010260d:	5b                   	pop    %ebx
8010260e:	5e                   	pop    %esi
8010260f:	5d                   	pop    %ebp
80102610:	c3                   	ret    

80102611 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102611:	55                   	push   %ebp
80102612:	89 e5                	mov    %esp,%ebp
80102614:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102617:	90                   	nop
80102618:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010261f:	e8 6c ff ff ff       	call   80102590 <inb>
80102624:	0f b6 c0             	movzbl %al,%eax
80102627:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010262a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010262d:	25 c0 00 00 00       	and    $0xc0,%eax
80102632:	83 f8 40             	cmp    $0x40,%eax
80102635:	75 e1                	jne    80102618 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102637:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010263b:	74 11                	je     8010264e <idewait+0x3d>
8010263d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102640:	83 e0 21             	and    $0x21,%eax
80102643:	85 c0                	test   %eax,%eax
80102645:	74 07                	je     8010264e <idewait+0x3d>
    return -1;
80102647:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010264c:	eb 05                	jmp    80102653 <idewait+0x42>
  return 0;
8010264e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102653:	c9                   	leave  
80102654:	c3                   	ret    

80102655 <ideinit>:

void
ideinit(void)
{
80102655:	55                   	push   %ebp
80102656:	89 e5                	mov    %esp,%ebp
80102658:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
8010265b:	c7 44 24 04 9b 89 10 	movl   $0x8010899b,0x4(%esp)
80102662:	80 
80102663:	c7 04 24 40 b7 10 80 	movl   $0x8010b740,(%esp)
8010266a:	e8 db 2a 00 00       	call   8010514a <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
8010266f:	a1 e0 3e 11 80       	mov    0x80113ee0,%eax
80102674:	48                   	dec    %eax
80102675:	89 44 24 04          	mov    %eax,0x4(%esp)
80102679:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102680:	e8 66 04 00 00       	call   80102aeb <ioapicenable>
  idewait(0);
80102685:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010268c:	e8 80 ff ff ff       	call   80102611 <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102691:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102698:	00 
80102699:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801026a0:	e8 2b ff ff ff       	call   801025d0 <outb>
  for(i=0; i<1000; i++){
801026a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026ac:	eb 1f                	jmp    801026cd <ideinit+0x78>
    if(inb(0x1f7) != 0){
801026ae:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026b5:	e8 d6 fe ff ff       	call   80102590 <inb>
801026ba:	84 c0                	test   %al,%al
801026bc:	74 0c                	je     801026ca <ideinit+0x75>
      havedisk1 = 1;
801026be:	c7 05 78 b7 10 80 01 	movl   $0x1,0x8010b778
801026c5:	00 00 00 
      break;
801026c8:	eb 0c                	jmp    801026d6 <ideinit+0x81>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801026ca:	ff 45 f4             	incl   -0xc(%ebp)
801026cd:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026d4:	7e d8                	jle    801026ae <ideinit+0x59>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026d6:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801026dd:	00 
801026de:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801026e5:	e8 e6 fe ff ff       	call   801025d0 <outb>
}
801026ea:	c9                   	leave  
801026eb:	c3                   	ret    

801026ec <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026ec:	55                   	push   %ebp
801026ed:	89 e5                	mov    %esp,%ebp
801026ef:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
801026f2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026f6:	75 0c                	jne    80102704 <idestart+0x18>
    panic("idestart");
801026f8:	c7 04 24 9f 89 10 80 	movl   $0x8010899f,(%esp)
801026ff:	e8 50 de ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
80102704:	8b 45 08             	mov    0x8(%ebp),%eax
80102707:	8b 40 08             	mov    0x8(%eax),%eax
8010270a:	3d e7 03 00 00       	cmp    $0x3e7,%eax
8010270f:	76 0c                	jbe    8010271d <idestart+0x31>
    panic("incorrect blockno");
80102711:	c7 04 24 a8 89 10 80 	movl   $0x801089a8,(%esp)
80102718:	e8 37 de ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010271d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102724:	8b 45 08             	mov    0x8(%ebp),%eax
80102727:	8b 50 08             	mov    0x8(%eax),%edx
8010272a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010272d:	0f af c2             	imul   %edx,%eax
80102730:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102733:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102737:	75 07                	jne    80102740 <idestart+0x54>
80102739:	b8 20 00 00 00       	mov    $0x20,%eax
8010273e:	eb 05                	jmp    80102745 <idestart+0x59>
80102740:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102745:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102748:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010274c:	75 07                	jne    80102755 <idestart+0x69>
8010274e:	b8 30 00 00 00       	mov    $0x30,%eax
80102753:	eb 05                	jmp    8010275a <idestart+0x6e>
80102755:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010275a:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
8010275d:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102761:	7e 0c                	jle    8010276f <idestart+0x83>
80102763:	c7 04 24 9f 89 10 80 	movl   $0x8010899f,(%esp)
8010276a:	e8 e5 dd ff ff       	call   80100554 <panic>

  idewait(0);
8010276f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102776:	e8 96 fe ff ff       	call   80102611 <idewait>
  outb(0x3f6, 0);  // generate interrupt
8010277b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102782:	00 
80102783:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
8010278a:	e8 41 fe ff ff       	call   801025d0 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
8010278f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102792:	0f b6 c0             	movzbl %al,%eax
80102795:	89 44 24 04          	mov    %eax,0x4(%esp)
80102799:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
801027a0:	e8 2b fe ff ff       	call   801025d0 <outb>
  outb(0x1f3, sector & 0xff);
801027a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027a8:	0f b6 c0             	movzbl %al,%eax
801027ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801027af:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
801027b6:	e8 15 fe ff ff       	call   801025d0 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
801027bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027be:	c1 f8 08             	sar    $0x8,%eax
801027c1:	0f b6 c0             	movzbl %al,%eax
801027c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801027c8:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801027cf:	e8 fc fd ff ff       	call   801025d0 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
801027d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027d7:	c1 f8 10             	sar    $0x10,%eax
801027da:	0f b6 c0             	movzbl %al,%eax
801027dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801027e1:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801027e8:	e8 e3 fd ff ff       	call   801025d0 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801027ed:	8b 45 08             	mov    0x8(%ebp),%eax
801027f0:	8b 40 04             	mov    0x4(%eax),%eax
801027f3:	83 e0 01             	and    $0x1,%eax
801027f6:	c1 e0 04             	shl    $0x4,%eax
801027f9:	88 c2                	mov    %al,%dl
801027fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027fe:	c1 f8 18             	sar    $0x18,%eax
80102801:	83 e0 0f             	and    $0xf,%eax
80102804:	09 d0                	or     %edx,%eax
80102806:	83 c8 e0             	or     $0xffffffe0,%eax
80102809:	0f b6 c0             	movzbl %al,%eax
8010280c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102810:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102817:	e8 b4 fd ff ff       	call   801025d0 <outb>
  if(b->flags & B_DIRTY){
8010281c:	8b 45 08             	mov    0x8(%ebp),%eax
8010281f:	8b 00                	mov    (%eax),%eax
80102821:	83 e0 04             	and    $0x4,%eax
80102824:	85 c0                	test   %eax,%eax
80102826:	74 36                	je     8010285e <idestart+0x172>
    outb(0x1f7, write_cmd);
80102828:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010282b:	0f b6 c0             	movzbl %al,%eax
8010282e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102832:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102839:	e8 92 fd ff ff       	call   801025d0 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
8010283e:	8b 45 08             	mov    0x8(%ebp),%eax
80102841:	83 c0 5c             	add    $0x5c,%eax
80102844:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010284b:	00 
8010284c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102850:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102857:	e8 90 fd ff ff       	call   801025ec <outsl>
8010285c:	eb 16                	jmp    80102874 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
8010285e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102861:	0f b6 c0             	movzbl %al,%eax
80102864:	89 44 24 04          	mov    %eax,0x4(%esp)
80102868:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010286f:	e8 5c fd ff ff       	call   801025d0 <outb>
  }
}
80102874:	c9                   	leave  
80102875:	c3                   	ret    

80102876 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102876:	55                   	push   %ebp
80102877:	89 e5                	mov    %esp,%ebp
80102879:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010287c:	c7 04 24 40 b7 10 80 	movl   $0x8010b740,(%esp)
80102883:	e8 e3 28 00 00       	call   8010516b <acquire>

  if((b = idequeue) == 0){
80102888:	a1 74 b7 10 80       	mov    0x8010b774,%eax
8010288d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102890:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102894:	75 11                	jne    801028a7 <ideintr+0x31>
    release(&idelock);
80102896:	c7 04 24 40 b7 10 80 	movl   $0x8010b740,(%esp)
8010289d:	e8 33 29 00 00       	call   801051d5 <release>
    return;
801028a2:	e9 90 00 00 00       	jmp    80102937 <ideintr+0xc1>
  }
  idequeue = b->qnext;
801028a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028aa:	8b 40 58             	mov    0x58(%eax),%eax
801028ad:	a3 74 b7 10 80       	mov    %eax,0x8010b774

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801028b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b5:	8b 00                	mov    (%eax),%eax
801028b7:	83 e0 04             	and    $0x4,%eax
801028ba:	85 c0                	test   %eax,%eax
801028bc:	75 2e                	jne    801028ec <ideintr+0x76>
801028be:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801028c5:	e8 47 fd ff ff       	call   80102611 <idewait>
801028ca:	85 c0                	test   %eax,%eax
801028cc:	78 1e                	js     801028ec <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
801028ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028d1:	83 c0 5c             	add    $0x5c,%eax
801028d4:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801028db:	00 
801028dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801028e0:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801028e7:	e8 bf fc ff ff       	call   801025ab <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801028ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ef:	8b 00                	mov    (%eax),%eax
801028f1:	83 c8 02             	or     $0x2,%eax
801028f4:	89 c2                	mov    %eax,%edx
801028f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f9:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028fe:	8b 00                	mov    (%eax),%eax
80102900:	83 e0 fb             	and    $0xfffffffb,%eax
80102903:	89 c2                	mov    %eax,%edx
80102905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102908:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010290a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010290d:	89 04 24             	mov    %eax,(%esp)
80102910:	e8 5c 22 00 00       	call   80104b71 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102915:	a1 74 b7 10 80       	mov    0x8010b774,%eax
8010291a:	85 c0                	test   %eax,%eax
8010291c:	74 0d                	je     8010292b <ideintr+0xb5>
    idestart(idequeue);
8010291e:	a1 74 b7 10 80       	mov    0x8010b774,%eax
80102923:	89 04 24             	mov    %eax,(%esp)
80102926:	e8 c1 fd ff ff       	call   801026ec <idestart>

  release(&idelock);
8010292b:	c7 04 24 40 b7 10 80 	movl   $0x8010b740,(%esp)
80102932:	e8 9e 28 00 00       	call   801051d5 <release>
}
80102937:	c9                   	leave  
80102938:	c3                   	ret    

80102939 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102939:	55                   	push   %ebp
8010293a:	89 e5                	mov    %esp,%ebp
8010293c:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
8010293f:	8b 45 08             	mov    0x8(%ebp),%eax
80102942:	83 c0 0c             	add    $0xc,%eax
80102945:	89 04 24             	mov    %eax,(%esp)
80102948:	e8 96 27 00 00       	call   801050e3 <holdingsleep>
8010294d:	85 c0                	test   %eax,%eax
8010294f:	75 0c                	jne    8010295d <iderw+0x24>
    panic("iderw: buf not locked");
80102951:	c7 04 24 ba 89 10 80 	movl   $0x801089ba,(%esp)
80102958:	e8 f7 db ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010295d:	8b 45 08             	mov    0x8(%ebp),%eax
80102960:	8b 00                	mov    (%eax),%eax
80102962:	83 e0 06             	and    $0x6,%eax
80102965:	83 f8 02             	cmp    $0x2,%eax
80102968:	75 0c                	jne    80102976 <iderw+0x3d>
    panic("iderw: nothing to do");
8010296a:	c7 04 24 d0 89 10 80 	movl   $0x801089d0,(%esp)
80102971:	e8 de db ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
80102976:	8b 45 08             	mov    0x8(%ebp),%eax
80102979:	8b 40 04             	mov    0x4(%eax),%eax
8010297c:	85 c0                	test   %eax,%eax
8010297e:	74 15                	je     80102995 <iderw+0x5c>
80102980:	a1 78 b7 10 80       	mov    0x8010b778,%eax
80102985:	85 c0                	test   %eax,%eax
80102987:	75 0c                	jne    80102995 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
80102989:	c7 04 24 e5 89 10 80 	movl   $0x801089e5,(%esp)
80102990:	e8 bf db ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102995:	c7 04 24 40 b7 10 80 	movl   $0x8010b740,(%esp)
8010299c:	e8 ca 27 00 00       	call   8010516b <acquire>

  // Append b to idequeue.
  b->qnext = 0;
801029a1:	8b 45 08             	mov    0x8(%ebp),%eax
801029a4:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029ab:	c7 45 f4 74 b7 10 80 	movl   $0x8010b774,-0xc(%ebp)
801029b2:	eb 0b                	jmp    801029bf <iderw+0x86>
801029b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029b7:	8b 00                	mov    (%eax),%eax
801029b9:	83 c0 58             	add    $0x58,%eax
801029bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029c2:	8b 00                	mov    (%eax),%eax
801029c4:	85 c0                	test   %eax,%eax
801029c6:	75 ec                	jne    801029b4 <iderw+0x7b>
    ;
  *pp = b;
801029c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029cb:	8b 55 08             	mov    0x8(%ebp),%edx
801029ce:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
801029d0:	a1 74 b7 10 80       	mov    0x8010b774,%eax
801029d5:	3b 45 08             	cmp    0x8(%ebp),%eax
801029d8:	75 0d                	jne    801029e7 <iderw+0xae>
    idestart(b);
801029da:	8b 45 08             	mov    0x8(%ebp),%eax
801029dd:	89 04 24             	mov    %eax,(%esp)
801029e0:	e8 07 fd ff ff       	call   801026ec <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029e5:	eb 15                	jmp    801029fc <iderw+0xc3>
801029e7:	eb 13                	jmp    801029fc <iderw+0xc3>
    sleep(b, &idelock);
801029e9:	c7 44 24 04 40 b7 10 	movl   $0x8010b740,0x4(%esp)
801029f0:	80 
801029f1:	8b 45 08             	mov    0x8(%ebp),%eax
801029f4:	89 04 24             	mov    %eax,(%esp)
801029f7:	e8 9e 20 00 00       	call   80104a9a <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029fc:	8b 45 08             	mov    0x8(%ebp),%eax
801029ff:	8b 00                	mov    (%eax),%eax
80102a01:	83 e0 06             	and    $0x6,%eax
80102a04:	83 f8 02             	cmp    $0x2,%eax
80102a07:	75 e0                	jne    801029e9 <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
80102a09:	c7 04 24 40 b7 10 80 	movl   $0x8010b740,(%esp)
80102a10:	e8 c0 27 00 00       	call   801051d5 <release>
}
80102a15:	c9                   	leave  
80102a16:	c3                   	ret    
	...

80102a18 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a18:	55                   	push   %ebp
80102a19:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a1b:	a1 14 38 11 80       	mov    0x80113814,%eax
80102a20:	8b 55 08             	mov    0x8(%ebp),%edx
80102a23:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a25:	a1 14 38 11 80       	mov    0x80113814,%eax
80102a2a:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a2d:	5d                   	pop    %ebp
80102a2e:	c3                   	ret    

80102a2f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a2f:	55                   	push   %ebp
80102a30:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a32:	a1 14 38 11 80       	mov    0x80113814,%eax
80102a37:	8b 55 08             	mov    0x8(%ebp),%edx
80102a3a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a3c:	a1 14 38 11 80       	mov    0x80113814,%eax
80102a41:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a44:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a47:	5d                   	pop    %ebp
80102a48:	c3                   	ret    

80102a49 <ioapicinit>:

void
ioapicinit(void)
{
80102a49:	55                   	push   %ebp
80102a4a:	89 e5                	mov    %esp,%ebp
80102a4c:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a4f:	c7 05 14 38 11 80 00 	movl   $0xfec00000,0x80113814
80102a56:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a59:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102a60:	e8 b3 ff ff ff       	call   80102a18 <ioapicread>
80102a65:	c1 e8 10             	shr    $0x10,%eax
80102a68:	25 ff 00 00 00       	and    $0xff,%eax
80102a6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102a77:	e8 9c ff ff ff       	call   80102a18 <ioapicread>
80102a7c:	c1 e8 18             	shr    $0x18,%eax
80102a7f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a82:	a0 40 39 11 80       	mov    0x80113940,%al
80102a87:	0f b6 c0             	movzbl %al,%eax
80102a8a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102a8d:	74 0c                	je     80102a9b <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a8f:	c7 04 24 04 8a 10 80 	movl   $0x80108a04,(%esp)
80102a96:	e8 26 d9 ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a9b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102aa2:	eb 3d                	jmp    80102ae1 <ioapicinit+0x98>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aa7:	83 c0 20             	add    $0x20,%eax
80102aaa:	0d 00 00 01 00       	or     $0x10000,%eax
80102aaf:	89 c2                	mov    %eax,%edx
80102ab1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab4:	83 c0 08             	add    $0x8,%eax
80102ab7:	01 c0                	add    %eax,%eax
80102ab9:	89 54 24 04          	mov    %edx,0x4(%esp)
80102abd:	89 04 24             	mov    %eax,(%esp)
80102ac0:	e8 6a ff ff ff       	call   80102a2f <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ac5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ac8:	83 c0 08             	add    $0x8,%eax
80102acb:	01 c0                	add    %eax,%eax
80102acd:	40                   	inc    %eax
80102ace:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102ad5:	00 
80102ad6:	89 04 24             	mov    %eax,(%esp)
80102ad9:	e8 51 ff ff ff       	call   80102a2f <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102ade:	ff 45 f4             	incl   -0xc(%ebp)
80102ae1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ae7:	7e bb                	jle    80102aa4 <ioapicinit+0x5b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102ae9:	c9                   	leave  
80102aea:	c3                   	ret    

80102aeb <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102aeb:	55                   	push   %ebp
80102aec:	89 e5                	mov    %esp,%ebp
80102aee:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102af1:	8b 45 08             	mov    0x8(%ebp),%eax
80102af4:	83 c0 20             	add    $0x20,%eax
80102af7:	89 c2                	mov    %eax,%edx
80102af9:	8b 45 08             	mov    0x8(%ebp),%eax
80102afc:	83 c0 08             	add    $0x8,%eax
80102aff:	01 c0                	add    %eax,%eax
80102b01:	89 54 24 04          	mov    %edx,0x4(%esp)
80102b05:	89 04 24             	mov    %eax,(%esp)
80102b08:	e8 22 ff ff ff       	call   80102a2f <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b0d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b10:	c1 e0 18             	shl    $0x18,%eax
80102b13:	8b 55 08             	mov    0x8(%ebp),%edx
80102b16:	83 c2 08             	add    $0x8,%edx
80102b19:	01 d2                	add    %edx,%edx
80102b1b:	42                   	inc    %edx
80102b1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b20:	89 14 24             	mov    %edx,(%esp)
80102b23:	e8 07 ff ff ff       	call   80102a2f <ioapicwrite>
}
80102b28:	c9                   	leave  
80102b29:	c3                   	ret    
	...

80102b2c <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b2c:	55                   	push   %ebp
80102b2d:	89 e5                	mov    %esp,%ebp
80102b2f:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102b32:	c7 44 24 04 36 8a 10 	movl   $0x80108a36,0x4(%esp)
80102b39:	80 
80102b3a:	c7 04 24 20 38 11 80 	movl   $0x80113820,(%esp)
80102b41:	e8 04 26 00 00       	call   8010514a <initlock>
  kmem.use_lock = 0;
80102b46:	c7 05 54 38 11 80 00 	movl   $0x0,0x80113854
80102b4d:	00 00 00 
  freerange(vstart, vend);
80102b50:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b53:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b57:	8b 45 08             	mov    0x8(%ebp),%eax
80102b5a:	89 04 24             	mov    %eax,(%esp)
80102b5d:	e8 26 00 00 00       	call   80102b88 <freerange>
}
80102b62:	c9                   	leave  
80102b63:	c3                   	ret    

80102b64 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b64:	55                   	push   %ebp
80102b65:	89 e5                	mov    %esp,%ebp
80102b67:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102b6a:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b71:	8b 45 08             	mov    0x8(%ebp),%eax
80102b74:	89 04 24             	mov    %eax,(%esp)
80102b77:	e8 0c 00 00 00       	call   80102b88 <freerange>
  kmem.use_lock = 1;
80102b7c:	c7 05 54 38 11 80 01 	movl   $0x1,0x80113854
80102b83:	00 00 00 
}
80102b86:	c9                   	leave  
80102b87:	c3                   	ret    

80102b88 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102b88:	55                   	push   %ebp
80102b89:	89 e5                	mov    %esp,%ebp
80102b8b:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102b8e:	8b 45 08             	mov    0x8(%ebp),%eax
80102b91:	05 ff 0f 00 00       	add    $0xfff,%eax
80102b96:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102b9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b9e:	eb 12                	jmp    80102bb2 <freerange+0x2a>
    kfree(p);
80102ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ba3:	89 04 24             	mov    %eax,(%esp)
80102ba6:	e8 16 00 00 00       	call   80102bc1 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bab:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bb5:	05 00 10 00 00       	add    $0x1000,%eax
80102bba:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102bbd:	76 e1                	jbe    80102ba0 <freerange+0x18>
    kfree(p);
}
80102bbf:	c9                   	leave  
80102bc0:	c3                   	ret    

80102bc1 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bc1:	55                   	push   %ebp
80102bc2:	89 e5                	mov    %esp,%ebp
80102bc4:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102bc7:	8b 45 08             	mov    0x8(%ebp),%eax
80102bca:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bcf:	85 c0                	test   %eax,%eax
80102bd1:	75 18                	jne    80102beb <kfree+0x2a>
80102bd3:	81 7d 08 48 6a 11 80 	cmpl   $0x80116a48,0x8(%ebp)
80102bda:	72 0f                	jb     80102beb <kfree+0x2a>
80102bdc:	8b 45 08             	mov    0x8(%ebp),%eax
80102bdf:	05 00 00 00 80       	add    $0x80000000,%eax
80102be4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102be9:	76 0c                	jbe    80102bf7 <kfree+0x36>
    panic("kfree");
80102beb:	c7 04 24 3b 8a 10 80 	movl   $0x80108a3b,(%esp)
80102bf2:	e8 5d d9 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102bf7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102bfe:	00 
80102bff:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102c06:	00 
80102c07:	8b 45 08             	mov    0x8(%ebp),%eax
80102c0a:	89 04 24             	mov    %eax,(%esp)
80102c0d:	e8 bc 27 00 00       	call   801053ce <memset>

  if(kmem.use_lock)
80102c12:	a1 54 38 11 80       	mov    0x80113854,%eax
80102c17:	85 c0                	test   %eax,%eax
80102c19:	74 0c                	je     80102c27 <kfree+0x66>
    acquire(&kmem.lock);
80102c1b:	c7 04 24 20 38 11 80 	movl   $0x80113820,(%esp)
80102c22:	e8 44 25 00 00       	call   8010516b <acquire>
  r = (struct run*)v;
80102c27:	8b 45 08             	mov    0x8(%ebp),%eax
80102c2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c2d:	8b 15 58 38 11 80    	mov    0x80113858,%edx
80102c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c36:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c3b:	a3 58 38 11 80       	mov    %eax,0x80113858
  if(kmem.use_lock)
80102c40:	a1 54 38 11 80       	mov    0x80113854,%eax
80102c45:	85 c0                	test   %eax,%eax
80102c47:	74 0c                	je     80102c55 <kfree+0x94>
    release(&kmem.lock);
80102c49:	c7 04 24 20 38 11 80 	movl   $0x80113820,(%esp)
80102c50:	e8 80 25 00 00       	call   801051d5 <release>
}
80102c55:	c9                   	leave  
80102c56:	c3                   	ret    

80102c57 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c57:	55                   	push   %ebp
80102c58:	89 e5                	mov    %esp,%ebp
80102c5a:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102c5d:	a1 54 38 11 80       	mov    0x80113854,%eax
80102c62:	85 c0                	test   %eax,%eax
80102c64:	74 0c                	je     80102c72 <kalloc+0x1b>
    acquire(&kmem.lock);
80102c66:	c7 04 24 20 38 11 80 	movl   $0x80113820,(%esp)
80102c6d:	e8 f9 24 00 00       	call   8010516b <acquire>
  r = kmem.freelist;
80102c72:	a1 58 38 11 80       	mov    0x80113858,%eax
80102c77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102c7a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c7e:	74 0a                	je     80102c8a <kalloc+0x33>
    kmem.freelist = r->next;
80102c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c83:	8b 00                	mov    (%eax),%eax
80102c85:	a3 58 38 11 80       	mov    %eax,0x80113858
  if(kmem.use_lock)
80102c8a:	a1 54 38 11 80       	mov    0x80113854,%eax
80102c8f:	85 c0                	test   %eax,%eax
80102c91:	74 0c                	je     80102c9f <kalloc+0x48>
    release(&kmem.lock);
80102c93:	c7 04 24 20 38 11 80 	movl   $0x80113820,(%esp)
80102c9a:	e8 36 25 00 00       	call   801051d5 <release>
  return (char*)r;
80102c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102ca2:	c9                   	leave  
80102ca3:	c3                   	ret    

80102ca4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102ca4:	55                   	push   %ebp
80102ca5:	89 e5                	mov    %esp,%ebp
80102ca7:	83 ec 14             	sub    $0x14,%esp
80102caa:	8b 45 08             	mov    0x8(%ebp),%eax
80102cad:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cb1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102cb4:	89 c2                	mov    %eax,%edx
80102cb6:	ec                   	in     (%dx),%al
80102cb7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cba:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102cbd:	c9                   	leave  
80102cbe:	c3                   	ret    

80102cbf <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cbf:	55                   	push   %ebp
80102cc0:	89 e5                	mov    %esp,%ebp
80102cc2:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102cc5:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102ccc:	e8 d3 ff ff ff       	call   80102ca4 <inb>
80102cd1:	0f b6 c0             	movzbl %al,%eax
80102cd4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cda:	83 e0 01             	and    $0x1,%eax
80102cdd:	85 c0                	test   %eax,%eax
80102cdf:	75 0a                	jne    80102ceb <kbdgetc+0x2c>
    return -1;
80102ce1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ce6:	e9 21 01 00 00       	jmp    80102e0c <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102ceb:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102cf2:	e8 ad ff ff ff       	call   80102ca4 <inb>
80102cf7:	0f b6 c0             	movzbl %al,%eax
80102cfa:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102cfd:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d04:	75 17                	jne    80102d1d <kbdgetc+0x5e>
    shift |= E0ESC;
80102d06:	a1 7c b7 10 80       	mov    0x8010b77c,%eax
80102d0b:	83 c8 40             	or     $0x40,%eax
80102d0e:	a3 7c b7 10 80       	mov    %eax,0x8010b77c
    return 0;
80102d13:	b8 00 00 00 00       	mov    $0x0,%eax
80102d18:	e9 ef 00 00 00       	jmp    80102e0c <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d1d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d20:	25 80 00 00 00       	and    $0x80,%eax
80102d25:	85 c0                	test   %eax,%eax
80102d27:	74 44                	je     80102d6d <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d29:	a1 7c b7 10 80       	mov    0x8010b77c,%eax
80102d2e:	83 e0 40             	and    $0x40,%eax
80102d31:	85 c0                	test   %eax,%eax
80102d33:	75 08                	jne    80102d3d <kbdgetc+0x7e>
80102d35:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d38:	83 e0 7f             	and    $0x7f,%eax
80102d3b:	eb 03                	jmp    80102d40 <kbdgetc+0x81>
80102d3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d40:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d43:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d46:	05 20 90 10 80       	add    $0x80109020,%eax
80102d4b:	8a 00                	mov    (%eax),%al
80102d4d:	83 c8 40             	or     $0x40,%eax
80102d50:	0f b6 c0             	movzbl %al,%eax
80102d53:	f7 d0                	not    %eax
80102d55:	89 c2                	mov    %eax,%edx
80102d57:	a1 7c b7 10 80       	mov    0x8010b77c,%eax
80102d5c:	21 d0                	and    %edx,%eax
80102d5e:	a3 7c b7 10 80       	mov    %eax,0x8010b77c
    return 0;
80102d63:	b8 00 00 00 00       	mov    $0x0,%eax
80102d68:	e9 9f 00 00 00       	jmp    80102e0c <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102d6d:	a1 7c b7 10 80       	mov    0x8010b77c,%eax
80102d72:	83 e0 40             	and    $0x40,%eax
80102d75:	85 c0                	test   %eax,%eax
80102d77:	74 14                	je     80102d8d <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102d79:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102d80:	a1 7c b7 10 80       	mov    0x8010b77c,%eax
80102d85:	83 e0 bf             	and    $0xffffffbf,%eax
80102d88:	a3 7c b7 10 80       	mov    %eax,0x8010b77c
  }

  shift |= shiftcode[data];
80102d8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d90:	05 20 90 10 80       	add    $0x80109020,%eax
80102d95:	8a 00                	mov    (%eax),%al
80102d97:	0f b6 d0             	movzbl %al,%edx
80102d9a:	a1 7c b7 10 80       	mov    0x8010b77c,%eax
80102d9f:	09 d0                	or     %edx,%eax
80102da1:	a3 7c b7 10 80       	mov    %eax,0x8010b77c
  shift ^= togglecode[data];
80102da6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102da9:	05 20 91 10 80       	add    $0x80109120,%eax
80102dae:	8a 00                	mov    (%eax),%al
80102db0:	0f b6 d0             	movzbl %al,%edx
80102db3:	a1 7c b7 10 80       	mov    0x8010b77c,%eax
80102db8:	31 d0                	xor    %edx,%eax
80102dba:	a3 7c b7 10 80       	mov    %eax,0x8010b77c
  c = charcode[shift & (CTL | SHIFT)][data];
80102dbf:	a1 7c b7 10 80       	mov    0x8010b77c,%eax
80102dc4:	83 e0 03             	and    $0x3,%eax
80102dc7:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102dce:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dd1:	01 d0                	add    %edx,%eax
80102dd3:	8a 00                	mov    (%eax),%al
80102dd5:	0f b6 c0             	movzbl %al,%eax
80102dd8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102ddb:	a1 7c b7 10 80       	mov    0x8010b77c,%eax
80102de0:	83 e0 08             	and    $0x8,%eax
80102de3:	85 c0                	test   %eax,%eax
80102de5:	74 22                	je     80102e09 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102de7:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102deb:	76 0c                	jbe    80102df9 <kbdgetc+0x13a>
80102ded:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102df1:	77 06                	ja     80102df9 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102df3:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102df7:	eb 10                	jmp    80102e09 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102df9:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102dfd:	76 0a                	jbe    80102e09 <kbdgetc+0x14a>
80102dff:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e03:	77 04                	ja     80102e09 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e05:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e09:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e0c:	c9                   	leave  
80102e0d:	c3                   	ret    

80102e0e <kbdintr>:

void
kbdintr(void)
{
80102e0e:	55                   	push   %ebp
80102e0f:	89 e5                	mov    %esp,%ebp
80102e11:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102e14:	c7 04 24 bf 2c 10 80 	movl   $0x80102cbf,(%esp)
80102e1b:	e8 d5 d9 ff ff       	call   801007f5 <consoleintr>
}
80102e20:	c9                   	leave  
80102e21:	c3                   	ret    
	...

80102e24 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e24:	55                   	push   %ebp
80102e25:	89 e5                	mov    %esp,%ebp
80102e27:	83 ec 14             	sub    $0x14,%esp
80102e2a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e2d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e34:	89 c2                	mov    %eax,%edx
80102e36:	ec                   	in     (%dx),%al
80102e37:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e3a:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102e3d:	c9                   	leave  
80102e3e:	c3                   	ret    

80102e3f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102e3f:	55                   	push   %ebp
80102e40:	89 e5                	mov    %esp,%ebp
80102e42:	83 ec 08             	sub    $0x8,%esp
80102e45:	8b 45 08             	mov    0x8(%ebp),%eax
80102e48:	8b 55 0c             	mov    0xc(%ebp),%edx
80102e4b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102e4f:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e52:	8a 45 f8             	mov    -0x8(%ebp),%al
80102e55:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102e58:	ee                   	out    %al,(%dx)
}
80102e59:	c9                   	leave  
80102e5a:	c3                   	ret    

80102e5b <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102e5b:	55                   	push   %ebp
80102e5c:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e5e:	a1 5c 38 11 80       	mov    0x8011385c,%eax
80102e63:	8b 55 08             	mov    0x8(%ebp),%edx
80102e66:	c1 e2 02             	shl    $0x2,%edx
80102e69:	01 c2                	add    %eax,%edx
80102e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e6e:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102e70:	a1 5c 38 11 80       	mov    0x8011385c,%eax
80102e75:	83 c0 20             	add    $0x20,%eax
80102e78:	8b 00                	mov    (%eax),%eax
}
80102e7a:	5d                   	pop    %ebp
80102e7b:	c3                   	ret    

80102e7c <lapicinit>:

void
lapicinit(void)
{
80102e7c:	55                   	push   %ebp
80102e7d:	89 e5                	mov    %esp,%ebp
80102e7f:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80102e82:	a1 5c 38 11 80       	mov    0x8011385c,%eax
80102e87:	85 c0                	test   %eax,%eax
80102e89:	75 05                	jne    80102e90 <lapicinit+0x14>
    return;
80102e8b:	e9 43 01 00 00       	jmp    80102fd3 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102e90:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102e97:	00 
80102e98:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102e9f:	e8 b7 ff ff ff       	call   80102e5b <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ea4:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102eab:	00 
80102eac:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102eb3:	e8 a3 ff ff ff       	call   80102e5b <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102eb8:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102ebf:	00 
80102ec0:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102ec7:	e8 8f ff ff ff       	call   80102e5b <lapicw>
  lapicw(TICR, 10000000);
80102ecc:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102ed3:	00 
80102ed4:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102edb:	e8 7b ff ff ff       	call   80102e5b <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102ee0:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102ee7:	00 
80102ee8:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102eef:	e8 67 ff ff ff       	call   80102e5b <lapicw>
  lapicw(LINT1, MASKED);
80102ef4:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102efb:	00 
80102efc:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102f03:	e8 53 ff ff ff       	call   80102e5b <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f08:	a1 5c 38 11 80       	mov    0x8011385c,%eax
80102f0d:	83 c0 30             	add    $0x30,%eax
80102f10:	8b 00                	mov    (%eax),%eax
80102f12:	c1 e8 10             	shr    $0x10,%eax
80102f15:	0f b6 c0             	movzbl %al,%eax
80102f18:	83 f8 03             	cmp    $0x3,%eax
80102f1b:	76 14                	jbe    80102f31 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102f1d:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102f24:	00 
80102f25:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102f2c:	e8 2a ff ff ff       	call   80102e5b <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f31:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102f38:	00 
80102f39:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102f40:	e8 16 ff ff ff       	call   80102e5b <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f45:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f4c:	00 
80102f4d:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102f54:	e8 02 ff ff ff       	call   80102e5b <lapicw>
  lapicw(ESR, 0);
80102f59:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f60:	00 
80102f61:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102f68:	e8 ee fe ff ff       	call   80102e5b <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f6d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f74:	00 
80102f75:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102f7c:	e8 da fe ff ff       	call   80102e5b <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f81:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f88:	00 
80102f89:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102f90:	e8 c6 fe ff ff       	call   80102e5b <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102f95:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102f9c:	00 
80102f9d:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fa4:	e8 b2 fe ff ff       	call   80102e5b <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102fa9:	90                   	nop
80102faa:	a1 5c 38 11 80       	mov    0x8011385c,%eax
80102faf:	05 00 03 00 00       	add    $0x300,%eax
80102fb4:	8b 00                	mov    (%eax),%eax
80102fb6:	25 00 10 00 00       	and    $0x1000,%eax
80102fbb:	85 c0                	test   %eax,%eax
80102fbd:	75 eb                	jne    80102faa <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fbf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102fc6:	00 
80102fc7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80102fce:	e8 88 fe ff ff       	call   80102e5b <lapicw>
}
80102fd3:	c9                   	leave  
80102fd4:	c3                   	ret    

80102fd5 <lapicid>:

int
lapicid(void)
{
80102fd5:	55                   	push   %ebp
80102fd6:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102fd8:	a1 5c 38 11 80       	mov    0x8011385c,%eax
80102fdd:	85 c0                	test   %eax,%eax
80102fdf:	75 07                	jne    80102fe8 <lapicid+0x13>
    return 0;
80102fe1:	b8 00 00 00 00       	mov    $0x0,%eax
80102fe6:	eb 0d                	jmp    80102ff5 <lapicid+0x20>
  return lapic[ID] >> 24;
80102fe8:	a1 5c 38 11 80       	mov    0x8011385c,%eax
80102fed:	83 c0 20             	add    $0x20,%eax
80102ff0:	8b 00                	mov    (%eax),%eax
80102ff2:	c1 e8 18             	shr    $0x18,%eax
}
80102ff5:	5d                   	pop    %ebp
80102ff6:	c3                   	ret    

80102ff7 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102ff7:	55                   	push   %ebp
80102ff8:	89 e5                	mov    %esp,%ebp
80102ffa:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80102ffd:	a1 5c 38 11 80       	mov    0x8011385c,%eax
80103002:	85 c0                	test   %eax,%eax
80103004:	74 14                	je     8010301a <lapiceoi+0x23>
    lapicw(EOI, 0);
80103006:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010300d:	00 
8010300e:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103015:	e8 41 fe ff ff       	call   80102e5b <lapicw>
}
8010301a:	c9                   	leave  
8010301b:	c3                   	ret    

8010301c <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010301c:	55                   	push   %ebp
8010301d:	89 e5                	mov    %esp,%ebp
}
8010301f:	5d                   	pop    %ebp
80103020:	c3                   	ret    

80103021 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103021:	55                   	push   %ebp
80103022:	89 e5                	mov    %esp,%ebp
80103024:	83 ec 1c             	sub    $0x1c,%esp
80103027:	8b 45 08             	mov    0x8(%ebp),%eax
8010302a:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010302d:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103034:	00 
80103035:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010303c:	e8 fe fd ff ff       	call   80102e3f <outb>
  outb(CMOS_PORT+1, 0x0A);
80103041:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103048:	00 
80103049:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103050:	e8 ea fd ff ff       	call   80102e3f <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103055:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010305c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010305f:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103064:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103067:	8d 50 02             	lea    0x2(%eax),%edx
8010306a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010306d:	c1 e8 04             	shr    $0x4,%eax
80103070:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103073:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103077:	c1 e0 18             	shl    $0x18,%eax
8010307a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010307e:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103085:	e8 d1 fd ff ff       	call   80102e5b <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010308a:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103091:	00 
80103092:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103099:	e8 bd fd ff ff       	call   80102e5b <lapicw>
  microdelay(200);
8010309e:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030a5:	e8 72 ff ff ff       	call   8010301c <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801030aa:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801030b1:	00 
801030b2:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801030b9:	e8 9d fd ff ff       	call   80102e5b <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030be:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801030c5:	e8 52 ff ff ff       	call   8010301c <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030ca:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030d1:	eb 3f                	jmp    80103112 <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
801030d3:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030d7:	c1 e0 18             	shl    $0x18,%eax
801030da:	89 44 24 04          	mov    %eax,0x4(%esp)
801030de:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801030e5:	e8 71 fd ff ff       	call   80102e5b <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801030ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801030ed:	c1 e8 0c             	shr    $0xc,%eax
801030f0:	80 cc 06             	or     $0x6,%ah
801030f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801030f7:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801030fe:	e8 58 fd ff ff       	call   80102e5b <lapicw>
    microdelay(200);
80103103:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010310a:	e8 0d ff ff ff       	call   8010301c <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010310f:	ff 45 fc             	incl   -0x4(%ebp)
80103112:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103116:	7e bb                	jle    801030d3 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103118:	c9                   	leave  
80103119:	c3                   	ret    

8010311a <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010311a:	55                   	push   %ebp
8010311b:	89 e5                	mov    %esp,%ebp
8010311d:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103120:	8b 45 08             	mov    0x8(%ebp),%eax
80103123:	0f b6 c0             	movzbl %al,%eax
80103126:	89 44 24 04          	mov    %eax,0x4(%esp)
8010312a:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103131:	e8 09 fd ff ff       	call   80102e3f <outb>
  microdelay(200);
80103136:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010313d:	e8 da fe ff ff       	call   8010301c <microdelay>

  return inb(CMOS_RETURN);
80103142:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103149:	e8 d6 fc ff ff       	call   80102e24 <inb>
8010314e:	0f b6 c0             	movzbl %al,%eax
}
80103151:	c9                   	leave  
80103152:	c3                   	ret    

80103153 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103153:	55                   	push   %ebp
80103154:	89 e5                	mov    %esp,%ebp
80103156:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
80103159:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103160:	e8 b5 ff ff ff       	call   8010311a <cmos_read>
80103165:	8b 55 08             	mov    0x8(%ebp),%edx
80103168:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010316a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103171:	e8 a4 ff ff ff       	call   8010311a <cmos_read>
80103176:	8b 55 08             	mov    0x8(%ebp),%edx
80103179:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
8010317c:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103183:	e8 92 ff ff ff       	call   8010311a <cmos_read>
80103188:	8b 55 08             	mov    0x8(%ebp),%edx
8010318b:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
8010318e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
80103195:	e8 80 ff ff ff       	call   8010311a <cmos_read>
8010319a:	8b 55 08             	mov    0x8(%ebp),%edx
8010319d:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801031a0:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801031a7:	e8 6e ff ff ff       	call   8010311a <cmos_read>
801031ac:	8b 55 08             	mov    0x8(%ebp),%edx
801031af:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801031b2:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
801031b9:	e8 5c ff ff ff       	call   8010311a <cmos_read>
801031be:	8b 55 08             	mov    0x8(%ebp),%edx
801031c1:	89 42 14             	mov    %eax,0x14(%edx)
}
801031c4:	c9                   	leave  
801031c5:	c3                   	ret    

801031c6 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031c6:	55                   	push   %ebp
801031c7:	89 e5                	mov    %esp,%ebp
801031c9:	57                   	push   %edi
801031ca:	56                   	push   %esi
801031cb:	53                   	push   %ebx
801031cc:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031cf:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
801031d6:	e8 3f ff ff ff       	call   8010311a <cmos_read>
801031db:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801031e1:	83 e0 04             	and    $0x4,%eax
801031e4:	85 c0                	test   %eax,%eax
801031e6:	0f 94 c0             	sete   %al
801031e9:	0f b6 c0             	movzbl %al,%eax
801031ec:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801031ef:	8d 45 c8             	lea    -0x38(%ebp),%eax
801031f2:	89 04 24             	mov    %eax,(%esp)
801031f5:	e8 59 ff ff ff       	call   80103153 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801031fa:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80103201:	e8 14 ff ff ff       	call   8010311a <cmos_read>
80103206:	25 80 00 00 00       	and    $0x80,%eax
8010320b:	85 c0                	test   %eax,%eax
8010320d:	74 02                	je     80103211 <cmostime+0x4b>
        continue;
8010320f:	eb 36                	jmp    80103247 <cmostime+0x81>
    fill_rtcdate(&t2);
80103211:	8d 45 b0             	lea    -0x50(%ebp),%eax
80103214:	89 04 24             	mov    %eax,(%esp)
80103217:	e8 37 ff ff ff       	call   80103153 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010321c:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80103223:	00 
80103224:	8d 45 b0             	lea    -0x50(%ebp),%eax
80103227:	89 44 24 04          	mov    %eax,0x4(%esp)
8010322b:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010322e:	89 04 24             	mov    %eax,(%esp)
80103231:	e8 0f 22 00 00       	call   80105445 <memcmp>
80103236:	85 c0                	test   %eax,%eax
80103238:	75 0d                	jne    80103247 <cmostime+0x81>
      break;
8010323a:	90                   	nop
  }

  // convert
  if(bcd) {
8010323b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010323f:	0f 84 ac 00 00 00    	je     801032f1 <cmostime+0x12b>
80103245:	eb 02                	jmp    80103249 <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103247:	eb a6                	jmp    801031ef <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103249:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010324c:	c1 e8 04             	shr    $0x4,%eax
8010324f:	89 c2                	mov    %eax,%edx
80103251:	89 d0                	mov    %edx,%eax
80103253:	c1 e0 02             	shl    $0x2,%eax
80103256:	01 d0                	add    %edx,%eax
80103258:	01 c0                	add    %eax,%eax
8010325a:	8b 55 c8             	mov    -0x38(%ebp),%edx
8010325d:	83 e2 0f             	and    $0xf,%edx
80103260:	01 d0                	add    %edx,%eax
80103262:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
80103265:	8b 45 cc             	mov    -0x34(%ebp),%eax
80103268:	c1 e8 04             	shr    $0x4,%eax
8010326b:	89 c2                	mov    %eax,%edx
8010326d:	89 d0                	mov    %edx,%eax
8010326f:	c1 e0 02             	shl    $0x2,%eax
80103272:	01 d0                	add    %edx,%eax
80103274:	01 c0                	add    %eax,%eax
80103276:	8b 55 cc             	mov    -0x34(%ebp),%edx
80103279:	83 e2 0f             	and    $0xf,%edx
8010327c:	01 d0                	add    %edx,%eax
8010327e:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
80103281:	8b 45 d0             	mov    -0x30(%ebp),%eax
80103284:	c1 e8 04             	shr    $0x4,%eax
80103287:	89 c2                	mov    %eax,%edx
80103289:	89 d0                	mov    %edx,%eax
8010328b:	c1 e0 02             	shl    $0x2,%eax
8010328e:	01 d0                	add    %edx,%eax
80103290:	01 c0                	add    %eax,%eax
80103292:	8b 55 d0             	mov    -0x30(%ebp),%edx
80103295:	83 e2 0f             	and    $0xf,%edx
80103298:	01 d0                	add    %edx,%eax
8010329a:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
8010329d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801032a0:	c1 e8 04             	shr    $0x4,%eax
801032a3:	89 c2                	mov    %eax,%edx
801032a5:	89 d0                	mov    %edx,%eax
801032a7:	c1 e0 02             	shl    $0x2,%eax
801032aa:	01 d0                	add    %edx,%eax
801032ac:	01 c0                	add    %eax,%eax
801032ae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801032b1:	83 e2 0f             	and    $0xf,%edx
801032b4:	01 d0                	add    %edx,%eax
801032b6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
801032b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801032bc:	c1 e8 04             	shr    $0x4,%eax
801032bf:	89 c2                	mov    %eax,%edx
801032c1:	89 d0                	mov    %edx,%eax
801032c3:	c1 e0 02             	shl    $0x2,%eax
801032c6:	01 d0                	add    %edx,%eax
801032c8:	01 c0                	add    %eax,%eax
801032ca:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032cd:	83 e2 0f             	and    $0xf,%edx
801032d0:	01 d0                	add    %edx,%eax
801032d2:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
801032d5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801032d8:	c1 e8 04             	shr    $0x4,%eax
801032db:	89 c2                	mov    %eax,%edx
801032dd:	89 d0                	mov    %edx,%eax
801032df:	c1 e0 02             	shl    $0x2,%eax
801032e2:	01 d0                	add    %edx,%eax
801032e4:	01 c0                	add    %eax,%eax
801032e6:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032e9:	83 e2 0f             	and    $0xf,%edx
801032ec:	01 d0                	add    %edx,%eax
801032ee:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
801032f1:	8b 45 08             	mov    0x8(%ebp),%eax
801032f4:	89 c2                	mov    %eax,%edx
801032f6:	8d 5d c8             	lea    -0x38(%ebp),%ebx
801032f9:	b8 06 00 00 00       	mov    $0x6,%eax
801032fe:	89 d7                	mov    %edx,%edi
80103300:	89 de                	mov    %ebx,%esi
80103302:	89 c1                	mov    %eax,%ecx
80103304:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
80103306:	8b 45 08             	mov    0x8(%ebp),%eax
80103309:	8b 40 14             	mov    0x14(%eax),%eax
8010330c:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103312:	8b 45 08             	mov    0x8(%ebp),%eax
80103315:	89 50 14             	mov    %edx,0x14(%eax)
}
80103318:	83 c4 5c             	add    $0x5c,%esp
8010331b:	5b                   	pop    %ebx
8010331c:	5e                   	pop    %esi
8010331d:	5f                   	pop    %edi
8010331e:	5d                   	pop    %ebp
8010331f:	c3                   	ret    

80103320 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103320:	55                   	push   %ebp
80103321:	89 e5                	mov    %esp,%ebp
80103323:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103326:	c7 44 24 04 41 8a 10 	movl   $0x80108a41,0x4(%esp)
8010332d:	80 
8010332e:	c7 04 24 60 38 11 80 	movl   $0x80113860,(%esp)
80103335:	e8 10 1e 00 00       	call   8010514a <initlock>
  readsb(dev, &sb);
8010333a:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010333d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103341:	8b 45 08             	mov    0x8(%ebp),%eax
80103344:	89 04 24             	mov    %eax,(%esp)
80103347:	e8 d8 e0 ff ff       	call   80101424 <readsb>
  log.start = sb.logstart;
8010334c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010334f:	a3 94 38 11 80       	mov    %eax,0x80113894
  log.size = sb.nlog;
80103354:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103357:	a3 98 38 11 80       	mov    %eax,0x80113898
  log.dev = dev;
8010335c:	8b 45 08             	mov    0x8(%ebp),%eax
8010335f:	a3 a4 38 11 80       	mov    %eax,0x801138a4
  recover_from_log();
80103364:	e8 95 01 00 00       	call   801034fe <recover_from_log>
}
80103369:	c9                   	leave  
8010336a:	c3                   	ret    

8010336b <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010336b:	55                   	push   %ebp
8010336c:	89 e5                	mov    %esp,%ebp
8010336e:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103371:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103378:	e9 89 00 00 00       	jmp    80103406 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010337d:	8b 15 94 38 11 80    	mov    0x80113894,%edx
80103383:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103386:	01 d0                	add    %edx,%eax
80103388:	40                   	inc    %eax
80103389:	89 c2                	mov    %eax,%edx
8010338b:	a1 a4 38 11 80       	mov    0x801138a4,%eax
80103390:	89 54 24 04          	mov    %edx,0x4(%esp)
80103394:	89 04 24             	mov    %eax,(%esp)
80103397:	e8 19 ce ff ff       	call   801001b5 <bread>
8010339c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010339f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033a2:	83 c0 10             	add    $0x10,%eax
801033a5:	8b 04 85 6c 38 11 80 	mov    -0x7feec794(,%eax,4),%eax
801033ac:	89 c2                	mov    %eax,%edx
801033ae:	a1 a4 38 11 80       	mov    0x801138a4,%eax
801033b3:	89 54 24 04          	mov    %edx,0x4(%esp)
801033b7:	89 04 24             	mov    %eax,(%esp)
801033ba:	e8 f6 cd ff ff       	call   801001b5 <bread>
801033bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033c5:	8d 50 5c             	lea    0x5c(%eax),%edx
801033c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033cb:	83 c0 5c             	add    $0x5c,%eax
801033ce:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801033d5:	00 
801033d6:	89 54 24 04          	mov    %edx,0x4(%esp)
801033da:	89 04 24             	mov    %eax,(%esp)
801033dd:	e8 b5 20 00 00       	call   80105497 <memmove>
    bwrite(dbuf);  // write dst to disk
801033e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033e5:	89 04 24             	mov    %eax,(%esp)
801033e8:	e8 ff cd ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
801033ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033f0:	89 04 24             	mov    %eax,(%esp)
801033f3:	e8 34 ce ff ff       	call   8010022c <brelse>
    brelse(dbuf);
801033f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033fb:	89 04 24             	mov    %eax,(%esp)
801033fe:	e8 29 ce ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103403:	ff 45 f4             	incl   -0xc(%ebp)
80103406:	a1 a8 38 11 80       	mov    0x801138a8,%eax
8010340b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010340e:	0f 8f 69 ff ff ff    	jg     8010337d <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
80103414:	c9                   	leave  
80103415:	c3                   	ret    

80103416 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103416:	55                   	push   %ebp
80103417:	89 e5                	mov    %esp,%ebp
80103419:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010341c:	a1 94 38 11 80       	mov    0x80113894,%eax
80103421:	89 c2                	mov    %eax,%edx
80103423:	a1 a4 38 11 80       	mov    0x801138a4,%eax
80103428:	89 54 24 04          	mov    %edx,0x4(%esp)
8010342c:	89 04 24             	mov    %eax,(%esp)
8010342f:	e8 81 cd ff ff       	call   801001b5 <bread>
80103434:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103437:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010343a:	83 c0 5c             	add    $0x5c,%eax
8010343d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103440:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103443:	8b 00                	mov    (%eax),%eax
80103445:	a3 a8 38 11 80       	mov    %eax,0x801138a8
  for (i = 0; i < log.lh.n; i++) {
8010344a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103451:	eb 1a                	jmp    8010346d <read_head+0x57>
    log.lh.block[i] = lh->block[i];
80103453:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103456:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103459:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010345d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103460:	83 c2 10             	add    $0x10,%edx
80103463:	89 04 95 6c 38 11 80 	mov    %eax,-0x7feec794(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010346a:	ff 45 f4             	incl   -0xc(%ebp)
8010346d:	a1 a8 38 11 80       	mov    0x801138a8,%eax
80103472:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103475:	7f dc                	jg     80103453 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
80103477:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010347a:	89 04 24             	mov    %eax,(%esp)
8010347d:	e8 aa cd ff ff       	call   8010022c <brelse>
}
80103482:	c9                   	leave  
80103483:	c3                   	ret    

80103484 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103484:	55                   	push   %ebp
80103485:	89 e5                	mov    %esp,%ebp
80103487:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010348a:	a1 94 38 11 80       	mov    0x80113894,%eax
8010348f:	89 c2                	mov    %eax,%edx
80103491:	a1 a4 38 11 80       	mov    0x801138a4,%eax
80103496:	89 54 24 04          	mov    %edx,0x4(%esp)
8010349a:	89 04 24             	mov    %eax,(%esp)
8010349d:	e8 13 cd ff ff       	call   801001b5 <bread>
801034a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a8:	83 c0 5c             	add    $0x5c,%eax
801034ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034ae:	8b 15 a8 38 11 80    	mov    0x801138a8,%edx
801034b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034b7:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034c0:	eb 1a                	jmp    801034dc <write_head+0x58>
    hb->block[i] = log.lh.block[i];
801034c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034c5:	83 c0 10             	add    $0x10,%eax
801034c8:	8b 0c 85 6c 38 11 80 	mov    -0x7feec794(,%eax,4),%ecx
801034cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034d5:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801034d9:	ff 45 f4             	incl   -0xc(%ebp)
801034dc:	a1 a8 38 11 80       	mov    0x801138a8,%eax
801034e1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034e4:	7f dc                	jg     801034c2 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801034e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034e9:	89 04 24             	mov    %eax,(%esp)
801034ec:	e8 fb cc ff ff       	call   801001ec <bwrite>
  brelse(buf);
801034f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034f4:	89 04 24             	mov    %eax,(%esp)
801034f7:	e8 30 cd ff ff       	call   8010022c <brelse>
}
801034fc:	c9                   	leave  
801034fd:	c3                   	ret    

801034fe <recover_from_log>:

static void
recover_from_log(void)
{
801034fe:	55                   	push   %ebp
801034ff:	89 e5                	mov    %esp,%ebp
80103501:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103504:	e8 0d ff ff ff       	call   80103416 <read_head>
  install_trans(); // if committed, copy from log to disk
80103509:	e8 5d fe ff ff       	call   8010336b <install_trans>
  log.lh.n = 0;
8010350e:	c7 05 a8 38 11 80 00 	movl   $0x0,0x801138a8
80103515:	00 00 00 
  write_head(); // clear the log
80103518:	e8 67 ff ff ff       	call   80103484 <write_head>
}
8010351d:	c9                   	leave  
8010351e:	c3                   	ret    

8010351f <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010351f:	55                   	push   %ebp
80103520:	89 e5                	mov    %esp,%ebp
80103522:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103525:	c7 04 24 60 38 11 80 	movl   $0x80113860,(%esp)
8010352c:	e8 3a 1c 00 00       	call   8010516b <acquire>
  while(1){
    if(log.committing){
80103531:	a1 a0 38 11 80       	mov    0x801138a0,%eax
80103536:	85 c0                	test   %eax,%eax
80103538:	74 16                	je     80103550 <begin_op+0x31>
      sleep(&log, &log.lock);
8010353a:	c7 44 24 04 60 38 11 	movl   $0x80113860,0x4(%esp)
80103541:	80 
80103542:	c7 04 24 60 38 11 80 	movl   $0x80113860,(%esp)
80103549:	e8 4c 15 00 00       	call   80104a9a <sleep>
8010354e:	eb 4d                	jmp    8010359d <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103550:	8b 15 a8 38 11 80    	mov    0x801138a8,%edx
80103556:	a1 9c 38 11 80       	mov    0x8011389c,%eax
8010355b:	8d 48 01             	lea    0x1(%eax),%ecx
8010355e:	89 c8                	mov    %ecx,%eax
80103560:	c1 e0 02             	shl    $0x2,%eax
80103563:	01 c8                	add    %ecx,%eax
80103565:	01 c0                	add    %eax,%eax
80103567:	01 d0                	add    %edx,%eax
80103569:	83 f8 1e             	cmp    $0x1e,%eax
8010356c:	7e 16                	jle    80103584 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010356e:	c7 44 24 04 60 38 11 	movl   $0x80113860,0x4(%esp)
80103575:	80 
80103576:	c7 04 24 60 38 11 80 	movl   $0x80113860,(%esp)
8010357d:	e8 18 15 00 00       	call   80104a9a <sleep>
80103582:	eb 19                	jmp    8010359d <begin_op+0x7e>
    } else {
      log.outstanding += 1;
80103584:	a1 9c 38 11 80       	mov    0x8011389c,%eax
80103589:	40                   	inc    %eax
8010358a:	a3 9c 38 11 80       	mov    %eax,0x8011389c
      release(&log.lock);
8010358f:	c7 04 24 60 38 11 80 	movl   $0x80113860,(%esp)
80103596:	e8 3a 1c 00 00       	call   801051d5 <release>
      break;
8010359b:	eb 02                	jmp    8010359f <begin_op+0x80>
    }
  }
8010359d:	eb 92                	jmp    80103531 <begin_op+0x12>
}
8010359f:	c9                   	leave  
801035a0:	c3                   	ret    

801035a1 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035a1:	55                   	push   %ebp
801035a2:	89 e5                	mov    %esp,%ebp
801035a4:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
801035a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035ae:	c7 04 24 60 38 11 80 	movl   $0x80113860,(%esp)
801035b5:	e8 b1 1b 00 00       	call   8010516b <acquire>
  log.outstanding -= 1;
801035ba:	a1 9c 38 11 80       	mov    0x8011389c,%eax
801035bf:	48                   	dec    %eax
801035c0:	a3 9c 38 11 80       	mov    %eax,0x8011389c
  if(log.committing)
801035c5:	a1 a0 38 11 80       	mov    0x801138a0,%eax
801035ca:	85 c0                	test   %eax,%eax
801035cc:	74 0c                	je     801035da <end_op+0x39>
    panic("log.committing");
801035ce:	c7 04 24 45 8a 10 80 	movl   $0x80108a45,(%esp)
801035d5:	e8 7a cf ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
801035da:	a1 9c 38 11 80       	mov    0x8011389c,%eax
801035df:	85 c0                	test   %eax,%eax
801035e1:	75 13                	jne    801035f6 <end_op+0x55>
    do_commit = 1;
801035e3:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801035ea:	c7 05 a0 38 11 80 01 	movl   $0x1,0x801138a0
801035f1:	00 00 00 
801035f4:	eb 0c                	jmp    80103602 <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801035f6:	c7 04 24 60 38 11 80 	movl   $0x80113860,(%esp)
801035fd:	e8 6f 15 00 00       	call   80104b71 <wakeup>
  }
  release(&log.lock);
80103602:	c7 04 24 60 38 11 80 	movl   $0x80113860,(%esp)
80103609:	e8 c7 1b 00 00       	call   801051d5 <release>

  if(do_commit){
8010360e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103612:	74 33                	je     80103647 <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103614:	e8 db 00 00 00       	call   801036f4 <commit>
    acquire(&log.lock);
80103619:	c7 04 24 60 38 11 80 	movl   $0x80113860,(%esp)
80103620:	e8 46 1b 00 00       	call   8010516b <acquire>
    log.committing = 0;
80103625:	c7 05 a0 38 11 80 00 	movl   $0x0,0x801138a0
8010362c:	00 00 00 
    wakeup(&log);
8010362f:	c7 04 24 60 38 11 80 	movl   $0x80113860,(%esp)
80103636:	e8 36 15 00 00       	call   80104b71 <wakeup>
    release(&log.lock);
8010363b:	c7 04 24 60 38 11 80 	movl   $0x80113860,(%esp)
80103642:	e8 8e 1b 00 00       	call   801051d5 <release>
  }
}
80103647:	c9                   	leave  
80103648:	c3                   	ret    

80103649 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103649:	55                   	push   %ebp
8010364a:	89 e5                	mov    %esp,%ebp
8010364c:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010364f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103656:	e9 89 00 00 00       	jmp    801036e4 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010365b:	8b 15 94 38 11 80    	mov    0x80113894,%edx
80103661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103664:	01 d0                	add    %edx,%eax
80103666:	40                   	inc    %eax
80103667:	89 c2                	mov    %eax,%edx
80103669:	a1 a4 38 11 80       	mov    0x801138a4,%eax
8010366e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103672:	89 04 24             	mov    %eax,(%esp)
80103675:	e8 3b cb ff ff       	call   801001b5 <bread>
8010367a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010367d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103680:	83 c0 10             	add    $0x10,%eax
80103683:	8b 04 85 6c 38 11 80 	mov    -0x7feec794(,%eax,4),%eax
8010368a:	89 c2                	mov    %eax,%edx
8010368c:	a1 a4 38 11 80       	mov    0x801138a4,%eax
80103691:	89 54 24 04          	mov    %edx,0x4(%esp)
80103695:	89 04 24             	mov    %eax,(%esp)
80103698:	e8 18 cb ff ff       	call   801001b5 <bread>
8010369d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036a3:	8d 50 5c             	lea    0x5c(%eax),%edx
801036a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036a9:	83 c0 5c             	add    $0x5c,%eax
801036ac:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801036b3:	00 
801036b4:	89 54 24 04          	mov    %edx,0x4(%esp)
801036b8:	89 04 24             	mov    %eax,(%esp)
801036bb:	e8 d7 1d 00 00       	call   80105497 <memmove>
    bwrite(to);  // write the log
801036c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036c3:	89 04 24             	mov    %eax,(%esp)
801036c6:	e8 21 cb ff ff       	call   801001ec <bwrite>
    brelse(from);
801036cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036ce:	89 04 24             	mov    %eax,(%esp)
801036d1:	e8 56 cb ff ff       	call   8010022c <brelse>
    brelse(to);
801036d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036d9:	89 04 24             	mov    %eax,(%esp)
801036dc:	e8 4b cb ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036e1:	ff 45 f4             	incl   -0xc(%ebp)
801036e4:	a1 a8 38 11 80       	mov    0x801138a8,%eax
801036e9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036ec:	0f 8f 69 ff ff ff    	jg     8010365b <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
801036f2:	c9                   	leave  
801036f3:	c3                   	ret    

801036f4 <commit>:

static void
commit()
{
801036f4:	55                   	push   %ebp
801036f5:	89 e5                	mov    %esp,%ebp
801036f7:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801036fa:	a1 a8 38 11 80       	mov    0x801138a8,%eax
801036ff:	85 c0                	test   %eax,%eax
80103701:	7e 1e                	jle    80103721 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103703:	e8 41 ff ff ff       	call   80103649 <write_log>
    write_head();    // Write header to disk -- the real commit
80103708:	e8 77 fd ff ff       	call   80103484 <write_head>
    install_trans(); // Now install writes to home locations
8010370d:	e8 59 fc ff ff       	call   8010336b <install_trans>
    log.lh.n = 0;
80103712:	c7 05 a8 38 11 80 00 	movl   $0x0,0x801138a8
80103719:	00 00 00 
    write_head();    // Erase the transaction from the log
8010371c:	e8 63 fd ff ff       	call   80103484 <write_head>
  }
}
80103721:	c9                   	leave  
80103722:	c3                   	ret    

80103723 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103723:	55                   	push   %ebp
80103724:	89 e5                	mov    %esp,%ebp
80103726:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103729:	a1 a8 38 11 80       	mov    0x801138a8,%eax
8010372e:	83 f8 1d             	cmp    $0x1d,%eax
80103731:	7f 10                	jg     80103743 <log_write+0x20>
80103733:	a1 a8 38 11 80       	mov    0x801138a8,%eax
80103738:	8b 15 98 38 11 80    	mov    0x80113898,%edx
8010373e:	4a                   	dec    %edx
8010373f:	39 d0                	cmp    %edx,%eax
80103741:	7c 0c                	jl     8010374f <log_write+0x2c>
    panic("too big a transaction");
80103743:	c7 04 24 54 8a 10 80 	movl   $0x80108a54,(%esp)
8010374a:	e8 05 ce ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
8010374f:	a1 9c 38 11 80       	mov    0x8011389c,%eax
80103754:	85 c0                	test   %eax,%eax
80103756:	7f 0c                	jg     80103764 <log_write+0x41>
    panic("log_write outside of trans");
80103758:	c7 04 24 6a 8a 10 80 	movl   $0x80108a6a,(%esp)
8010375f:	e8 f0 cd ff ff       	call   80100554 <panic>

  acquire(&log.lock);
80103764:	c7 04 24 60 38 11 80 	movl   $0x80113860,(%esp)
8010376b:	e8 fb 19 00 00       	call   8010516b <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103770:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103777:	eb 1e                	jmp    80103797 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010377c:	83 c0 10             	add    $0x10,%eax
8010377f:	8b 04 85 6c 38 11 80 	mov    -0x7feec794(,%eax,4),%eax
80103786:	89 c2                	mov    %eax,%edx
80103788:	8b 45 08             	mov    0x8(%ebp),%eax
8010378b:	8b 40 08             	mov    0x8(%eax),%eax
8010378e:	39 c2                	cmp    %eax,%edx
80103790:	75 02                	jne    80103794 <log_write+0x71>
      break;
80103792:	eb 0d                	jmp    801037a1 <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103794:	ff 45 f4             	incl   -0xc(%ebp)
80103797:	a1 a8 38 11 80       	mov    0x801138a8,%eax
8010379c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010379f:	7f d8                	jg     80103779 <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
801037a1:	8b 45 08             	mov    0x8(%ebp),%eax
801037a4:	8b 40 08             	mov    0x8(%eax),%eax
801037a7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037aa:	83 c2 10             	add    $0x10,%edx
801037ad:	89 04 95 6c 38 11 80 	mov    %eax,-0x7feec794(,%edx,4)
  if (i == log.lh.n)
801037b4:	a1 a8 38 11 80       	mov    0x801138a8,%eax
801037b9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037bc:	75 0b                	jne    801037c9 <log_write+0xa6>
    log.lh.n++;
801037be:	a1 a8 38 11 80       	mov    0x801138a8,%eax
801037c3:	40                   	inc    %eax
801037c4:	a3 a8 38 11 80       	mov    %eax,0x801138a8
  b->flags |= B_DIRTY; // prevent eviction
801037c9:	8b 45 08             	mov    0x8(%ebp),%eax
801037cc:	8b 00                	mov    (%eax),%eax
801037ce:	83 c8 04             	or     $0x4,%eax
801037d1:	89 c2                	mov    %eax,%edx
801037d3:	8b 45 08             	mov    0x8(%ebp),%eax
801037d6:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801037d8:	c7 04 24 60 38 11 80 	movl   $0x80113860,(%esp)
801037df:	e8 f1 19 00 00       	call   801051d5 <release>
}
801037e4:	c9                   	leave  
801037e5:	c3                   	ret    
	...

801037e8 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801037e8:	55                   	push   %ebp
801037e9:	89 e5                	mov    %esp,%ebp
801037eb:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801037ee:	8b 55 08             	mov    0x8(%ebp),%edx
801037f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801037f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
801037f7:	f0 87 02             	lock xchg %eax,(%edx)
801037fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801037fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103800:	c9                   	leave  
80103801:	c3                   	ret    

80103802 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103802:	55                   	push   %ebp
80103803:	89 e5                	mov    %esp,%ebp
80103805:	83 e4 f0             	and    $0xfffffff0,%esp
80103808:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010380b:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103812:	80 
80103813:	c7 04 24 48 6a 11 80 	movl   $0x80116a48,(%esp)
8010381a:	e8 0d f3 ff ff       	call   80102b2c <kinit1>
  kvmalloc();      // kernel page table
8010381f:	e8 9b 47 00 00       	call   80107fbf <kvmalloc>
  mpinit();        // detect other processors
80103824:	e8 cc 03 00 00       	call   80103bf5 <mpinit>
  lapicinit();     // interrupt controller
80103829:	e8 4e f6 ff ff       	call   80102e7c <lapicinit>
  seginit();       // segment descriptors
8010382e:	e8 74 42 00 00       	call   80107aa7 <seginit>
  picinit();       // disable pic
80103833:	e8 0c 05 00 00       	call   80103d44 <picinit>
  ioapicinit();    // another interrupt controller
80103838:	e8 0c f2 ff ff       	call   80102a49 <ioapicinit>
  consoleinit();   // console hardware
8010383d:	e8 75 d3 ff ff       	call   80100bb7 <consoleinit>
  uartinit();      // serial port
80103842:	e8 ec 35 00 00       	call   80106e33 <uartinit>
  cinit();         // container table
80103847:	e8 c4 14 00 00       	call   80104d10 <cinit>
  pinit();         // process table
8010384c:	e8 e9 08 00 00       	call   8010413a <pinit>
  tvinit();        // trap vectors
80103851:	e8 aa 31 00 00       	call   80106a00 <tvinit>
  binit();         // buffer cache
80103856:	e8 d9 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010385b:	e8 e8 d7 ff ff       	call   80101048 <fileinit>
  ideinit();       // disk 
80103860:	e8 f0 ed ff ff       	call   80102655 <ideinit>
  startothers();   // start other processors
80103865:	e8 83 00 00 00       	call   801038ed <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010386a:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103871:	8e 
80103872:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103879:	e8 e6 f2 ff ff       	call   80102b64 <kinit2>
  userinit();      // first user process
8010387e:	e8 e8 0a 00 00       	call   8010436b <userinit>
  mpmain();        // finish this processor's setup
80103883:	e8 1a 00 00 00       	call   801038a2 <mpmain>

80103888 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103888:	55                   	push   %ebp
80103889:	89 e5                	mov    %esp,%ebp
8010388b:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
8010388e:	e8 43 47 00 00       	call   80107fd6 <switchkvm>
  seginit();
80103893:	e8 0f 42 00 00       	call   80107aa7 <seginit>
  lapicinit();
80103898:	e8 df f5 ff ff       	call   80102e7c <lapicinit>
  mpmain();
8010389d:	e8 00 00 00 00       	call   801038a2 <mpmain>

801038a2 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801038a2:	55                   	push   %ebp
801038a3:	89 e5                	mov    %esp,%ebp
801038a5:	53                   	push   %ebx
801038a6:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801038a9:	e8 a8 08 00 00       	call   80104156 <cpuid>
801038ae:	89 c3                	mov    %eax,%ebx
801038b0:	e8 a1 08 00 00       	call   80104156 <cpuid>
801038b5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801038b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801038bd:	c7 04 24 85 8a 10 80 	movl   $0x80108a85,(%esp)
801038c4:	e8 f8 ca ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
801038c9:	e8 8f 32 00 00       	call   80106b5d <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801038ce:	e8 c8 08 00 00       	call   8010419b <mycpu>
801038d3:	05 a0 00 00 00       	add    $0xa0,%eax
801038d8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801038df:	00 
801038e0:	89 04 24             	mov    %eax,(%esp)
801038e3:	e8 00 ff ff ff       	call   801037e8 <xchg>
  scheduler();     // start running processes
801038e8:	e8 e0 0f 00 00       	call   801048cd <scheduler>

801038ed <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801038ed:	55                   	push   %ebp
801038ee:	89 e5                	mov    %esp,%ebp
801038f0:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
801038f3:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801038fa:	b8 8a 00 00 00       	mov    $0x8a,%eax
801038ff:	89 44 24 08          	mov    %eax,0x8(%esp)
80103903:	c7 44 24 04 2c b5 10 	movl   $0x8010b52c,0x4(%esp)
8010390a:	80 
8010390b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010390e:	89 04 24             	mov    %eax,(%esp)
80103911:	e8 81 1b 00 00       	call   80105497 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103916:	c7 45 f4 60 39 11 80 	movl   $0x80113960,-0xc(%ebp)
8010391d:	eb 75                	jmp    80103994 <startothers+0xa7>
    if(c == mycpu())  // We've started already.
8010391f:	e8 77 08 00 00       	call   8010419b <mycpu>
80103924:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103927:	75 02                	jne    8010392b <startothers+0x3e>
      continue;
80103929:	eb 62                	jmp    8010398d <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010392b:	e8 27 f3 ff ff       	call   80102c57 <kalloc>
80103930:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103933:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103936:	83 e8 04             	sub    $0x4,%eax
80103939:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010393c:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103942:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103944:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103947:	83 e8 08             	sub    $0x8,%eax
8010394a:	c7 00 88 38 10 80    	movl   $0x80103888,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103950:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103953:	8d 50 f4             	lea    -0xc(%eax),%edx
80103956:	b8 00 a0 10 80       	mov    $0x8010a000,%eax
8010395b:	05 00 00 00 80       	add    $0x80000000,%eax
80103960:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
80103962:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103965:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010396b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010396e:	8a 00                	mov    (%eax),%al
80103970:	0f b6 c0             	movzbl %al,%eax
80103973:	89 54 24 04          	mov    %edx,0x4(%esp)
80103977:	89 04 24             	mov    %eax,(%esp)
8010397a:	e8 a2 f6 ff ff       	call   80103021 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010397f:	90                   	nop
80103980:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103983:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103989:	85 c0                	test   %eax,%eax
8010398b:	74 f3                	je     80103980 <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
8010398d:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103994:	a1 e0 3e 11 80       	mov    0x80113ee0,%eax
80103999:	89 c2                	mov    %eax,%edx
8010399b:	89 d0                	mov    %edx,%eax
8010399d:	c1 e0 02             	shl    $0x2,%eax
801039a0:	01 d0                	add    %edx,%eax
801039a2:	01 c0                	add    %eax,%eax
801039a4:	01 d0                	add    %edx,%eax
801039a6:	c1 e0 04             	shl    $0x4,%eax
801039a9:	05 60 39 11 80       	add    $0x80113960,%eax
801039ae:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039b1:	0f 87 68 ff ff ff    	ja     8010391f <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801039b7:	c9                   	leave  
801039b8:	c3                   	ret    
801039b9:	00 00                	add    %al,(%eax)
	...

801039bc <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801039bc:	55                   	push   %ebp
801039bd:	89 e5                	mov    %esp,%ebp
801039bf:	83 ec 14             	sub    $0x14,%esp
801039c2:	8b 45 08             	mov    0x8(%ebp),%eax
801039c5:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801039c9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801039cc:	89 c2                	mov    %eax,%edx
801039ce:	ec                   	in     (%dx),%al
801039cf:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801039d2:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801039d5:	c9                   	leave  
801039d6:	c3                   	ret    

801039d7 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801039d7:	55                   	push   %ebp
801039d8:	89 e5                	mov    %esp,%ebp
801039da:	83 ec 08             	sub    $0x8,%esp
801039dd:	8b 45 08             	mov    0x8(%ebp),%eax
801039e0:	8b 55 0c             	mov    0xc(%ebp),%edx
801039e3:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801039e7:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039ea:	8a 45 f8             	mov    -0x8(%ebp),%al
801039ed:	8b 55 fc             	mov    -0x4(%ebp),%edx
801039f0:	ee                   	out    %al,(%dx)
}
801039f1:	c9                   	leave  
801039f2:	c3                   	ret    

801039f3 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
801039f3:	55                   	push   %ebp
801039f4:	89 e5                	mov    %esp,%ebp
801039f6:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
801039f9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a00:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a07:	eb 13                	jmp    80103a1c <sum+0x29>
    sum += addr[i];
80103a09:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a0c:	8b 45 08             	mov    0x8(%ebp),%eax
80103a0f:	01 d0                	add    %edx,%eax
80103a11:	8a 00                	mov    (%eax),%al
80103a13:	0f b6 c0             	movzbl %al,%eax
80103a16:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103a19:	ff 45 fc             	incl   -0x4(%ebp)
80103a1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a1f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a22:	7c e5                	jl     80103a09 <sum+0x16>
    sum += addr[i];
  return sum;
80103a24:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a27:	c9                   	leave  
80103a28:	c3                   	ret    

80103a29 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a29:	55                   	push   %ebp
80103a2a:	89 e5                	mov    %esp,%ebp
80103a2c:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103a2f:	8b 45 08             	mov    0x8(%ebp),%eax
80103a32:	05 00 00 00 80       	add    $0x80000000,%eax
80103a37:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a3a:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a40:	01 d0                	add    %edx,%eax
80103a42:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a48:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a4b:	eb 3f                	jmp    80103a8c <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a4d:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a54:	00 
80103a55:	c7 44 24 04 9c 8a 10 	movl   $0x80108a9c,0x4(%esp)
80103a5c:	80 
80103a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a60:	89 04 24             	mov    %eax,(%esp)
80103a63:	e8 dd 19 00 00       	call   80105445 <memcmp>
80103a68:	85 c0                	test   %eax,%eax
80103a6a:	75 1c                	jne    80103a88 <mpsearch1+0x5f>
80103a6c:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a73:	00 
80103a74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a77:	89 04 24             	mov    %eax,(%esp)
80103a7a:	e8 74 ff ff ff       	call   801039f3 <sum>
80103a7f:	84 c0                	test   %al,%al
80103a81:	75 05                	jne    80103a88 <mpsearch1+0x5f>
      return (struct mp*)p;
80103a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a86:	eb 11                	jmp    80103a99 <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a88:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a8f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a92:	72 b9                	jb     80103a4d <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a94:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a99:	c9                   	leave  
80103a9a:	c3                   	ret    

80103a9b <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a9b:	55                   	push   %ebp
80103a9c:	89 e5                	mov    %esp,%ebp
80103a9e:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103aa1:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aab:	83 c0 0f             	add    $0xf,%eax
80103aae:	8a 00                	mov    (%eax),%al
80103ab0:	0f b6 c0             	movzbl %al,%eax
80103ab3:	c1 e0 08             	shl    $0x8,%eax
80103ab6:	89 c2                	mov    %eax,%edx
80103ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103abb:	83 c0 0e             	add    $0xe,%eax
80103abe:	8a 00                	mov    (%eax),%al
80103ac0:	0f b6 c0             	movzbl %al,%eax
80103ac3:	09 d0                	or     %edx,%eax
80103ac5:	c1 e0 04             	shl    $0x4,%eax
80103ac8:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103acb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103acf:	74 21                	je     80103af2 <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103ad1:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ad8:	00 
80103ad9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103adc:	89 04 24             	mov    %eax,(%esp)
80103adf:	e8 45 ff ff ff       	call   80103a29 <mpsearch1>
80103ae4:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ae7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103aeb:	74 4e                	je     80103b3b <mpsearch+0xa0>
      return mp;
80103aed:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103af0:	eb 5d                	jmp    80103b4f <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af5:	83 c0 14             	add    $0x14,%eax
80103af8:	8a 00                	mov    (%eax),%al
80103afa:	0f b6 c0             	movzbl %al,%eax
80103afd:	c1 e0 08             	shl    $0x8,%eax
80103b00:	89 c2                	mov    %eax,%edx
80103b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b05:	83 c0 13             	add    $0x13,%eax
80103b08:	8a 00                	mov    (%eax),%al
80103b0a:	0f b6 c0             	movzbl %al,%eax
80103b0d:	09 d0                	or     %edx,%eax
80103b0f:	c1 e0 0a             	shl    $0xa,%eax
80103b12:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b18:	2d 00 04 00 00       	sub    $0x400,%eax
80103b1d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b24:	00 
80103b25:	89 04 24             	mov    %eax,(%esp)
80103b28:	e8 fc fe ff ff       	call   80103a29 <mpsearch1>
80103b2d:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b30:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b34:	74 05                	je     80103b3b <mpsearch+0xa0>
      return mp;
80103b36:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b39:	eb 14                	jmp    80103b4f <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b3b:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b42:	00 
80103b43:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b4a:	e8 da fe ff ff       	call   80103a29 <mpsearch1>
}
80103b4f:	c9                   	leave  
80103b50:	c3                   	ret    

80103b51 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b51:	55                   	push   %ebp
80103b52:	89 e5                	mov    %esp,%ebp
80103b54:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b57:	e8 3f ff ff ff       	call   80103a9b <mpsearch>
80103b5c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b5f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b63:	74 0a                	je     80103b6f <mpconfig+0x1e>
80103b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b68:	8b 40 04             	mov    0x4(%eax),%eax
80103b6b:	85 c0                	test   %eax,%eax
80103b6d:	75 07                	jne    80103b76 <mpconfig+0x25>
    return 0;
80103b6f:	b8 00 00 00 00       	mov    $0x0,%eax
80103b74:	eb 7d                	jmp    80103bf3 <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b79:	8b 40 04             	mov    0x4(%eax),%eax
80103b7c:	05 00 00 00 80       	add    $0x80000000,%eax
80103b81:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b84:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b8b:	00 
80103b8c:	c7 44 24 04 a1 8a 10 	movl   $0x80108aa1,0x4(%esp)
80103b93:	80 
80103b94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b97:	89 04 24             	mov    %eax,(%esp)
80103b9a:	e8 a6 18 00 00       	call   80105445 <memcmp>
80103b9f:	85 c0                	test   %eax,%eax
80103ba1:	74 07                	je     80103baa <mpconfig+0x59>
    return 0;
80103ba3:	b8 00 00 00 00       	mov    $0x0,%eax
80103ba8:	eb 49                	jmp    80103bf3 <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103baa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bad:	8a 40 06             	mov    0x6(%eax),%al
80103bb0:	3c 01                	cmp    $0x1,%al
80103bb2:	74 11                	je     80103bc5 <mpconfig+0x74>
80103bb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bb7:	8a 40 06             	mov    0x6(%eax),%al
80103bba:	3c 04                	cmp    $0x4,%al
80103bbc:	74 07                	je     80103bc5 <mpconfig+0x74>
    return 0;
80103bbe:	b8 00 00 00 00       	mov    $0x0,%eax
80103bc3:	eb 2e                	jmp    80103bf3 <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103bc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc8:	8b 40 04             	mov    0x4(%eax),%eax
80103bcb:	0f b7 c0             	movzwl %ax,%eax
80103bce:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bd5:	89 04 24             	mov    %eax,(%esp)
80103bd8:	e8 16 fe ff ff       	call   801039f3 <sum>
80103bdd:	84 c0                	test   %al,%al
80103bdf:	74 07                	je     80103be8 <mpconfig+0x97>
    return 0;
80103be1:	b8 00 00 00 00       	mov    $0x0,%eax
80103be6:	eb 0b                	jmp    80103bf3 <mpconfig+0xa2>
  *pmp = mp;
80103be8:	8b 45 08             	mov    0x8(%ebp),%eax
80103beb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103bee:	89 10                	mov    %edx,(%eax)
  return conf;
80103bf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103bf3:	c9                   	leave  
80103bf4:	c3                   	ret    

80103bf5 <mpinit>:

void
mpinit(void)
{
80103bf5:	55                   	push   %ebp
80103bf6:	89 e5                	mov    %esp,%ebp
80103bf8:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103bfb:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103bfe:	89 04 24             	mov    %eax,(%esp)
80103c01:	e8 4b ff ff ff       	call   80103b51 <mpconfig>
80103c06:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c09:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c0d:	75 0c                	jne    80103c1b <mpinit+0x26>
    panic("Expect to run on an SMP");
80103c0f:	c7 04 24 a6 8a 10 80 	movl   $0x80108aa6,(%esp)
80103c16:	e8 39 c9 ff ff       	call   80100554 <panic>
  ismp = 1;
80103c1b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103c22:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c25:	8b 40 24             	mov    0x24(%eax),%eax
80103c28:	a3 5c 38 11 80       	mov    %eax,0x8011385c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c30:	83 c0 2c             	add    $0x2c,%eax
80103c33:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c36:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c39:	8b 40 04             	mov    0x4(%eax),%eax
80103c3c:	0f b7 d0             	movzwl %ax,%edx
80103c3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c42:	01 d0                	add    %edx,%eax
80103c44:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103c47:	eb 7d                	jmp    80103cc6 <mpinit+0xd1>
    switch(*p){
80103c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c4c:	8a 00                	mov    (%eax),%al
80103c4e:	0f b6 c0             	movzbl %al,%eax
80103c51:	83 f8 04             	cmp    $0x4,%eax
80103c54:	77 68                	ja     80103cbe <mpinit+0xc9>
80103c56:	8b 04 85 e0 8a 10 80 	mov    -0x7fef7520(,%eax,4),%eax
80103c5d:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c62:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103c65:	a1 e0 3e 11 80       	mov    0x80113ee0,%eax
80103c6a:	83 f8 07             	cmp    $0x7,%eax
80103c6d:	7f 2c                	jg     80103c9b <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103c6f:	8b 15 e0 3e 11 80    	mov    0x80113ee0,%edx
80103c75:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103c78:	8a 48 01             	mov    0x1(%eax),%cl
80103c7b:	89 d0                	mov    %edx,%eax
80103c7d:	c1 e0 02             	shl    $0x2,%eax
80103c80:	01 d0                	add    %edx,%eax
80103c82:	01 c0                	add    %eax,%eax
80103c84:	01 d0                	add    %edx,%eax
80103c86:	c1 e0 04             	shl    $0x4,%eax
80103c89:	05 60 39 11 80       	add    $0x80113960,%eax
80103c8e:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103c90:	a1 e0 3e 11 80       	mov    0x80113ee0,%eax
80103c95:	40                   	inc    %eax
80103c96:	a3 e0 3e 11 80       	mov    %eax,0x80113ee0
      }
      p += sizeof(struct mpproc);
80103c9b:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103c9f:	eb 25                	jmp    80103cc6 <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103ca1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca4:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103ca7:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103caa:	8a 40 01             	mov    0x1(%eax),%al
80103cad:	a2 40 39 11 80       	mov    %al,0x80113940
      p += sizeof(struct mpioapic);
80103cb2:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cb6:	eb 0e                	jmp    80103cc6 <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103cb8:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cbc:	eb 08                	jmp    80103cc6 <mpinit+0xd1>
    default:
      ismp = 0;
80103cbe:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103cc5:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc9:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103ccc:	0f 82 77 ff ff ff    	jb     80103c49 <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103cd2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103cd6:	75 0c                	jne    80103ce4 <mpinit+0xef>
    panic("Didn't find a suitable machine");
80103cd8:	c7 04 24 c0 8a 10 80 	movl   $0x80108ac0,(%esp)
80103cdf:	e8 70 c8 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80103ce4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ce7:	8a 40 0c             	mov    0xc(%eax),%al
80103cea:	84 c0                	test   %al,%al
80103cec:	74 36                	je     80103d24 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103cee:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103cf5:	00 
80103cf6:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103cfd:	e8 d5 fc ff ff       	call   801039d7 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d02:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d09:	e8 ae fc ff ff       	call   801039bc <inb>
80103d0e:	83 c8 01             	or     $0x1,%eax
80103d11:	0f b6 c0             	movzbl %al,%eax
80103d14:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d18:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d1f:	e8 b3 fc ff ff       	call   801039d7 <outb>
  }
}
80103d24:	c9                   	leave  
80103d25:	c3                   	ret    
	...

80103d28 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d28:	55                   	push   %ebp
80103d29:	89 e5                	mov    %esp,%ebp
80103d2b:	83 ec 08             	sub    $0x8,%esp
80103d2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103d31:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d34:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103d38:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d3b:	8a 45 f8             	mov    -0x8(%ebp),%al
80103d3e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103d41:	ee                   	out    %al,(%dx)
}
80103d42:	c9                   	leave  
80103d43:	c3                   	ret    

80103d44 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103d44:	55                   	push   %ebp
80103d45:	89 e5                	mov    %esp,%ebp
80103d47:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103d4a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103d51:	00 
80103d52:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103d59:	e8 ca ff ff ff       	call   80103d28 <outb>
  outb(IO_PIC2+1, 0xFF);
80103d5e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103d65:	00 
80103d66:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103d6d:	e8 b6 ff ff ff       	call   80103d28 <outb>
}
80103d72:	c9                   	leave  
80103d73:	c3                   	ret    

80103d74 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103d74:	55                   	push   %ebp
80103d75:	89 e5                	mov    %esp,%ebp
80103d77:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103d7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103d81:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d84:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103d8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d8d:	8b 10                	mov    (%eax),%edx
80103d8f:	8b 45 08             	mov    0x8(%ebp),%eax
80103d92:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103d94:	e8 cb d2 ff ff       	call   80101064 <filealloc>
80103d99:	8b 55 08             	mov    0x8(%ebp),%edx
80103d9c:	89 02                	mov    %eax,(%edx)
80103d9e:	8b 45 08             	mov    0x8(%ebp),%eax
80103da1:	8b 00                	mov    (%eax),%eax
80103da3:	85 c0                	test   %eax,%eax
80103da5:	0f 84 c8 00 00 00    	je     80103e73 <pipealloc+0xff>
80103dab:	e8 b4 d2 ff ff       	call   80101064 <filealloc>
80103db0:	8b 55 0c             	mov    0xc(%ebp),%edx
80103db3:	89 02                	mov    %eax,(%edx)
80103db5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103db8:	8b 00                	mov    (%eax),%eax
80103dba:	85 c0                	test   %eax,%eax
80103dbc:	0f 84 b1 00 00 00    	je     80103e73 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103dc2:	e8 90 ee ff ff       	call   80102c57 <kalloc>
80103dc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103dca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103dce:	75 05                	jne    80103dd5 <pipealloc+0x61>
    goto bad;
80103dd0:	e9 9e 00 00 00       	jmp    80103e73 <pipealloc+0xff>
  p->readopen = 1;
80103dd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dd8:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103ddf:	00 00 00 
  p->writeopen = 1;
80103de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103de5:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103dec:	00 00 00 
  p->nwrite = 0;
80103def:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103df2:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103df9:	00 00 00 
  p->nread = 0;
80103dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dff:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103e06:	00 00 00 
  initlock(&p->lock, "pipe");
80103e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e0c:	c7 44 24 04 f4 8a 10 	movl   $0x80108af4,0x4(%esp)
80103e13:	80 
80103e14:	89 04 24             	mov    %eax,(%esp)
80103e17:	e8 2e 13 00 00       	call   8010514a <initlock>
  (*f0)->type = FD_PIPE;
80103e1c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e1f:	8b 00                	mov    (%eax),%eax
80103e21:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103e27:	8b 45 08             	mov    0x8(%ebp),%eax
80103e2a:	8b 00                	mov    (%eax),%eax
80103e2c:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103e30:	8b 45 08             	mov    0x8(%ebp),%eax
80103e33:	8b 00                	mov    (%eax),%eax
80103e35:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103e39:	8b 45 08             	mov    0x8(%ebp),%eax
80103e3c:	8b 00                	mov    (%eax),%eax
80103e3e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e41:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103e44:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e47:	8b 00                	mov    (%eax),%eax
80103e49:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e52:	8b 00                	mov    (%eax),%eax
80103e54:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103e58:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e5b:	8b 00                	mov    (%eax),%eax
80103e5d:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103e61:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e64:	8b 00                	mov    (%eax),%eax
80103e66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e69:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103e6c:	b8 00 00 00 00       	mov    $0x0,%eax
80103e71:	eb 42                	jmp    80103eb5 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103e73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e77:	74 0b                	je     80103e84 <pipealloc+0x110>
    kfree((char*)p);
80103e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e7c:	89 04 24             	mov    %eax,(%esp)
80103e7f:	e8 3d ed ff ff       	call   80102bc1 <kfree>
  if(*f0)
80103e84:	8b 45 08             	mov    0x8(%ebp),%eax
80103e87:	8b 00                	mov    (%eax),%eax
80103e89:	85 c0                	test   %eax,%eax
80103e8b:	74 0d                	je     80103e9a <pipealloc+0x126>
    fileclose(*f0);
80103e8d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e90:	8b 00                	mov    (%eax),%eax
80103e92:	89 04 24             	mov    %eax,(%esp)
80103e95:	e8 72 d2 ff ff       	call   8010110c <fileclose>
  if(*f1)
80103e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e9d:	8b 00                	mov    (%eax),%eax
80103e9f:	85 c0                	test   %eax,%eax
80103ea1:	74 0d                	je     80103eb0 <pipealloc+0x13c>
    fileclose(*f1);
80103ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ea6:	8b 00                	mov    (%eax),%eax
80103ea8:	89 04 24             	mov    %eax,(%esp)
80103eab:	e8 5c d2 ff ff       	call   8010110c <fileclose>
  return -1;
80103eb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103eb5:	c9                   	leave  
80103eb6:	c3                   	ret    

80103eb7 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103eb7:	55                   	push   %ebp
80103eb8:	89 e5                	mov    %esp,%ebp
80103eba:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103ebd:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec0:	89 04 24             	mov    %eax,(%esp)
80103ec3:	e8 a3 12 00 00       	call   8010516b <acquire>
  if(writable){
80103ec8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103ecc:	74 1f                	je     80103eed <pipeclose+0x36>
    p->writeopen = 0;
80103ece:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed1:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103ed8:	00 00 00 
    wakeup(&p->nread);
80103edb:	8b 45 08             	mov    0x8(%ebp),%eax
80103ede:	05 34 02 00 00       	add    $0x234,%eax
80103ee3:	89 04 24             	mov    %eax,(%esp)
80103ee6:	e8 86 0c 00 00       	call   80104b71 <wakeup>
80103eeb:	eb 1d                	jmp    80103f0a <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103eed:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef0:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103ef7:	00 00 00 
    wakeup(&p->nwrite);
80103efa:	8b 45 08             	mov    0x8(%ebp),%eax
80103efd:	05 38 02 00 00       	add    $0x238,%eax
80103f02:	89 04 24             	mov    %eax,(%esp)
80103f05:	e8 67 0c 00 00       	call   80104b71 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0d:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103f13:	85 c0                	test   %eax,%eax
80103f15:	75 25                	jne    80103f3c <pipeclose+0x85>
80103f17:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1a:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103f20:	85 c0                	test   %eax,%eax
80103f22:	75 18                	jne    80103f3c <pipeclose+0x85>
    release(&p->lock);
80103f24:	8b 45 08             	mov    0x8(%ebp),%eax
80103f27:	89 04 24             	mov    %eax,(%esp)
80103f2a:	e8 a6 12 00 00       	call   801051d5 <release>
    kfree((char*)p);
80103f2f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f32:	89 04 24             	mov    %eax,(%esp)
80103f35:	e8 87 ec ff ff       	call   80102bc1 <kfree>
80103f3a:	eb 0b                	jmp    80103f47 <pipeclose+0x90>
  } else
    release(&p->lock);
80103f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f3f:	89 04 24             	mov    %eax,(%esp)
80103f42:	e8 8e 12 00 00       	call   801051d5 <release>
}
80103f47:	c9                   	leave  
80103f48:	c3                   	ret    

80103f49 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103f49:	55                   	push   %ebp
80103f4a:	89 e5                	mov    %esp,%ebp
80103f4c:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80103f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f52:	89 04 24             	mov    %eax,(%esp)
80103f55:	e8 11 12 00 00       	call   8010516b <acquire>
  for(i = 0; i < n; i++){
80103f5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f61:	e9 a3 00 00 00       	jmp    80104009 <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103f66:	eb 56                	jmp    80103fbe <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
80103f68:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6b:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103f71:	85 c0                	test   %eax,%eax
80103f73:	74 0c                	je     80103f81 <pipewrite+0x38>
80103f75:	e8 a5 02 00 00       	call   8010421f <myproc>
80103f7a:	8b 40 24             	mov    0x24(%eax),%eax
80103f7d:	85 c0                	test   %eax,%eax
80103f7f:	74 15                	je     80103f96 <pipewrite+0x4d>
        release(&p->lock);
80103f81:	8b 45 08             	mov    0x8(%ebp),%eax
80103f84:	89 04 24             	mov    %eax,(%esp)
80103f87:	e8 49 12 00 00       	call   801051d5 <release>
        return -1;
80103f8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f91:	e9 9d 00 00 00       	jmp    80104033 <pipewrite+0xea>
      }
      wakeup(&p->nread);
80103f96:	8b 45 08             	mov    0x8(%ebp),%eax
80103f99:	05 34 02 00 00       	add    $0x234,%eax
80103f9e:	89 04 24             	mov    %eax,(%esp)
80103fa1:	e8 cb 0b 00 00       	call   80104b71 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103fa6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa9:	8b 55 08             	mov    0x8(%ebp),%edx
80103fac:	81 c2 38 02 00 00    	add    $0x238,%edx
80103fb2:	89 44 24 04          	mov    %eax,0x4(%esp)
80103fb6:	89 14 24             	mov    %edx,(%esp)
80103fb9:	e8 dc 0a 00 00       	call   80104a9a <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103fbe:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc1:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103fc7:	8b 45 08             	mov    0x8(%ebp),%eax
80103fca:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103fd0:	05 00 02 00 00       	add    $0x200,%eax
80103fd5:	39 c2                	cmp    %eax,%edx
80103fd7:	74 8f                	je     80103f68 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103fd9:	8b 45 08             	mov    0x8(%ebp),%eax
80103fdc:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103fe2:	8d 48 01             	lea    0x1(%eax),%ecx
80103fe5:	8b 55 08             	mov    0x8(%ebp),%edx
80103fe8:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103fee:	25 ff 01 00 00       	and    $0x1ff,%eax
80103ff3:	89 c1                	mov    %eax,%ecx
80103ff5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ffb:	01 d0                	add    %edx,%eax
80103ffd:	8a 10                	mov    (%eax),%dl
80103fff:	8b 45 08             	mov    0x8(%ebp),%eax
80104002:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104006:	ff 45 f4             	incl   -0xc(%ebp)
80104009:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010400c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010400f:	0f 8c 51 ff ff ff    	jl     80103f66 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104015:	8b 45 08             	mov    0x8(%ebp),%eax
80104018:	05 34 02 00 00       	add    $0x234,%eax
8010401d:	89 04 24             	mov    %eax,(%esp)
80104020:	e8 4c 0b 00 00       	call   80104b71 <wakeup>
  release(&p->lock);
80104025:	8b 45 08             	mov    0x8(%ebp),%eax
80104028:	89 04 24             	mov    %eax,(%esp)
8010402b:	e8 a5 11 00 00       	call   801051d5 <release>
  return n;
80104030:	8b 45 10             	mov    0x10(%ebp),%eax
}
80104033:	c9                   	leave  
80104034:	c3                   	ret    

80104035 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104035:	55                   	push   %ebp
80104036:	89 e5                	mov    %esp,%ebp
80104038:	53                   	push   %ebx
80104039:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
8010403c:	8b 45 08             	mov    0x8(%ebp),%eax
8010403f:	89 04 24             	mov    %eax,(%esp)
80104042:	e8 24 11 00 00       	call   8010516b <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104047:	eb 39                	jmp    80104082 <piperead+0x4d>
    if(myproc()->killed){
80104049:	e8 d1 01 00 00       	call   8010421f <myproc>
8010404e:	8b 40 24             	mov    0x24(%eax),%eax
80104051:	85 c0                	test   %eax,%eax
80104053:	74 15                	je     8010406a <piperead+0x35>
      release(&p->lock);
80104055:	8b 45 08             	mov    0x8(%ebp),%eax
80104058:	89 04 24             	mov    %eax,(%esp)
8010405b:	e8 75 11 00 00       	call   801051d5 <release>
      return -1;
80104060:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104065:	e9 b3 00 00 00       	jmp    8010411d <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010406a:	8b 45 08             	mov    0x8(%ebp),%eax
8010406d:	8b 55 08             	mov    0x8(%ebp),%edx
80104070:	81 c2 34 02 00 00    	add    $0x234,%edx
80104076:	89 44 24 04          	mov    %eax,0x4(%esp)
8010407a:	89 14 24             	mov    %edx,(%esp)
8010407d:	e8 18 0a 00 00       	call   80104a9a <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104082:	8b 45 08             	mov    0x8(%ebp),%eax
80104085:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010408b:	8b 45 08             	mov    0x8(%ebp),%eax
8010408e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104094:	39 c2                	cmp    %eax,%edx
80104096:	75 0d                	jne    801040a5 <piperead+0x70>
80104098:	8b 45 08             	mov    0x8(%ebp),%eax
8010409b:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801040a1:	85 c0                	test   %eax,%eax
801040a3:	75 a4                	jne    80104049 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801040a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801040ac:	eb 49                	jmp    801040f7 <piperead+0xc2>
    if(p->nread == p->nwrite)
801040ae:	8b 45 08             	mov    0x8(%ebp),%eax
801040b1:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801040b7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ba:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801040c0:	39 c2                	cmp    %eax,%edx
801040c2:	75 02                	jne    801040c6 <piperead+0x91>
      break;
801040c4:	eb 39                	jmp    801040ff <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
801040c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801040cc:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801040cf:	8b 45 08             	mov    0x8(%ebp),%eax
801040d2:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801040d8:	8d 48 01             	lea    0x1(%eax),%ecx
801040db:	8b 55 08             	mov    0x8(%ebp),%edx
801040de:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801040e4:	25 ff 01 00 00       	and    $0x1ff,%eax
801040e9:	89 c2                	mov    %eax,%edx
801040eb:	8b 45 08             	mov    0x8(%ebp),%eax
801040ee:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
801040f2:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801040f4:	ff 45 f4             	incl   -0xc(%ebp)
801040f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040fa:	3b 45 10             	cmp    0x10(%ebp),%eax
801040fd:	7c af                	jl     801040ae <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801040ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104102:	05 38 02 00 00       	add    $0x238,%eax
80104107:	89 04 24             	mov    %eax,(%esp)
8010410a:	e8 62 0a 00 00       	call   80104b71 <wakeup>
  release(&p->lock);
8010410f:	8b 45 08             	mov    0x8(%ebp),%eax
80104112:	89 04 24             	mov    %eax,(%esp)
80104115:	e8 bb 10 00 00       	call   801051d5 <release>
  return i;
8010411a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010411d:	83 c4 24             	add    $0x24,%esp
80104120:	5b                   	pop    %ebx
80104121:	5d                   	pop    %ebp
80104122:	c3                   	ret    
	...

80104124 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104124:	55                   	push   %ebp
80104125:	89 e5                	mov    %esp,%ebp
80104127:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010412a:	9c                   	pushf  
8010412b:	58                   	pop    %eax
8010412c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010412f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104132:	c9                   	leave  
80104133:	c3                   	ret    

80104134 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104134:	55                   	push   %ebp
80104135:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104137:	fb                   	sti    
}
80104138:	5d                   	pop    %ebp
80104139:	c3                   	ret    

8010413a <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010413a:	55                   	push   %ebp
8010413b:	89 e5                	mov    %esp,%ebp
8010413d:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
80104140:	c7 44 24 04 fc 8a 10 	movl   $0x80108afc,0x4(%esp)
80104147:	80 
80104148:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
8010414f:	e8 f6 0f 00 00       	call   8010514a <initlock>
}
80104154:	c9                   	leave  
80104155:	c3                   	ret    

80104156 <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
80104156:	55                   	push   %ebp
80104157:	89 e5                	mov    %esp,%ebp
80104159:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010415c:	e8 3a 00 00 00       	call   8010419b <mycpu>
80104161:	89 c2                	mov    %eax,%edx
80104163:	b8 60 39 11 80       	mov    $0x80113960,%eax
80104168:	29 c2                	sub    %eax,%edx
8010416a:	89 d0                	mov    %edx,%eax
8010416c:	c1 f8 04             	sar    $0x4,%eax
8010416f:	89 c1                	mov    %eax,%ecx
80104171:	89 ca                	mov    %ecx,%edx
80104173:	c1 e2 03             	shl    $0x3,%edx
80104176:	01 ca                	add    %ecx,%edx
80104178:	89 d0                	mov    %edx,%eax
8010417a:	c1 e0 05             	shl    $0x5,%eax
8010417d:	29 d0                	sub    %edx,%eax
8010417f:	c1 e0 02             	shl    $0x2,%eax
80104182:	01 c8                	add    %ecx,%eax
80104184:	c1 e0 03             	shl    $0x3,%eax
80104187:	01 c8                	add    %ecx,%eax
80104189:	89 c2                	mov    %eax,%edx
8010418b:	c1 e2 0f             	shl    $0xf,%edx
8010418e:	29 c2                	sub    %eax,%edx
80104190:	c1 e2 02             	shl    $0x2,%edx
80104193:	01 ca                	add    %ecx,%edx
80104195:	89 d0                	mov    %edx,%eax
80104197:	f7 d8                	neg    %eax
}
80104199:	c9                   	leave  
8010419a:	c3                   	ret    

8010419b <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
8010419b:	55                   	push   %ebp
8010419c:	89 e5                	mov    %esp,%ebp
8010419e:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
801041a1:	e8 7e ff ff ff       	call   80104124 <readeflags>
801041a6:	25 00 02 00 00       	and    $0x200,%eax
801041ab:	85 c0                	test   %eax,%eax
801041ad:	74 0c                	je     801041bb <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
801041af:	c7 04 24 04 8b 10 80 	movl   $0x80108b04,(%esp)
801041b6:	e8 99 c3 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
801041bb:	e8 15 ee ff ff       	call   80102fd5 <lapicid>
801041c0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801041c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041ca:	eb 3b                	jmp    80104207 <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
801041cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041cf:	89 d0                	mov    %edx,%eax
801041d1:	c1 e0 02             	shl    $0x2,%eax
801041d4:	01 d0                	add    %edx,%eax
801041d6:	01 c0                	add    %eax,%eax
801041d8:	01 d0                	add    %edx,%eax
801041da:	c1 e0 04             	shl    $0x4,%eax
801041dd:	05 60 39 11 80       	add    $0x80113960,%eax
801041e2:	8a 00                	mov    (%eax),%al
801041e4:	0f b6 c0             	movzbl %al,%eax
801041e7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801041ea:	75 18                	jne    80104204 <mycpu+0x69>
      return &cpus[i];
801041ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041ef:	89 d0                	mov    %edx,%eax
801041f1:	c1 e0 02             	shl    $0x2,%eax
801041f4:	01 d0                	add    %edx,%eax
801041f6:	01 c0                	add    %eax,%eax
801041f8:	01 d0                	add    %edx,%eax
801041fa:	c1 e0 04             	shl    $0x4,%eax
801041fd:	05 60 39 11 80       	add    $0x80113960,%eax
80104202:	eb 19                	jmp    8010421d <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104204:	ff 45 f4             	incl   -0xc(%ebp)
80104207:	a1 e0 3e 11 80       	mov    0x80113ee0,%eax
8010420c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010420f:	7c bb                	jl     801041cc <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104211:	c7 04 24 2a 8b 10 80 	movl   $0x80108b2a,(%esp)
80104218:	e8 37 c3 ff ff       	call   80100554 <panic>
}
8010421d:	c9                   	leave  
8010421e:	c3                   	ret    

8010421f <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
8010421f:	55                   	push   %ebp
80104220:	89 e5                	mov    %esp,%ebp
80104222:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104225:	e8 a0 10 00 00       	call   801052ca <pushcli>
  c = mycpu();
8010422a:	e8 6c ff ff ff       	call   8010419b <mycpu>
8010422f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104232:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104235:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010423b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
8010423e:	e8 d1 10 00 00       	call   80105314 <popcli>
  return p;
80104243:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104246:	c9                   	leave  
80104247:	c3                   	ret    

80104248 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104248:	55                   	push   %ebp
80104249:	89 e5                	mov    %esp,%ebp
8010424b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010424e:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80104255:	e8 11 0f 00 00       	call   8010516b <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010425a:	c7 45 f4 34 3f 11 80 	movl   $0x80113f34,-0xc(%ebp)
80104261:	eb 53                	jmp    801042b6 <allocproc+0x6e>
    if(p->state == UNUSED)
80104263:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104266:	8b 40 0c             	mov    0xc(%eax),%eax
80104269:	85 c0                	test   %eax,%eax
8010426b:	75 42                	jne    801042af <allocproc+0x67>
      goto found;
8010426d:	90                   	nop

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
8010426e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104271:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104278:	a1 00 b0 10 80       	mov    0x8010b000,%eax
8010427d:	8d 50 01             	lea    0x1(%eax),%edx
80104280:	89 15 00 b0 10 80    	mov    %edx,0x8010b000
80104286:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104289:	89 42 10             	mov    %eax,0x10(%edx)

  release(&ptable.lock);
8010428c:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80104293:	e8 3d 0f 00 00       	call   801051d5 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104298:	e8 ba e9 ff ff       	call   80102c57 <kalloc>
8010429d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042a0:	89 42 08             	mov    %eax,0x8(%edx)
801042a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042a6:	8b 40 08             	mov    0x8(%eax),%eax
801042a9:	85 c0                	test   %eax,%eax
801042ab:	75 3c                	jne    801042e9 <allocproc+0xa1>
801042ad:	eb 26                	jmp    801042d5 <allocproc+0x8d>
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801042af:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801042b6:	81 7d f4 34 60 11 80 	cmpl   $0x80116034,-0xc(%ebp)
801042bd:	72 a4                	jb     80104263 <allocproc+0x1b>
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
801042bf:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
801042c6:	e8 0a 0f 00 00       	call   801051d5 <release>
  return 0;
801042cb:	b8 00 00 00 00       	mov    $0x0,%eax
801042d0:	e9 94 00 00 00       	jmp    80104369 <allocproc+0x121>

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801042d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801042df:	b8 00 00 00 00       	mov    $0x0,%eax
801042e4:	e9 80 00 00 00       	jmp    80104369 <allocproc+0x121>
  }
  sp = p->kstack + KSTACKSIZE;
801042e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ec:	8b 40 08             	mov    0x8(%eax),%eax
801042ef:	05 00 10 00 00       	add    $0x1000,%eax
801042f4:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801042f7:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801042fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fe:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104301:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104304:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104308:	ba bc 69 10 80       	mov    $0x801069bc,%edx
8010430d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104310:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104312:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104316:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104319:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010431c:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010431f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104322:	8b 40 1c             	mov    0x1c(%eax),%eax
80104325:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010432c:	00 
8010432d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104334:	00 
80104335:	89 04 24             	mov    %eax,(%esp)
80104338:	e8 91 10 00 00       	call   801053ce <memset>
  p->context->eip = (uint)forkret;
8010433d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104340:	8b 40 1c             	mov    0x1c(%eax),%eax
80104343:	ba 5b 4a 10 80       	mov    $0x80104a5b,%edx
80104348:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
8010434b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434e:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->cid = mycont()->cid;
80104355:	e8 d2 09 00 00       	call   80104d2c <mycont>
8010435a:	8b 50 0c             	mov    0xc(%eax),%edx
8010435d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104360:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  return p;
80104366:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104369:	c9                   	leave  
8010436a:	c3                   	ret    

8010436b <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
8010436b:	55                   	push   %ebp
8010436c:	89 e5                	mov    %esp,%ebp
8010436e:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80104371:	e8 d2 fe ff ff       	call   80104248 <allocproc>
80104376:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437c:	a3 80 b7 10 80       	mov    %eax,0x8010b780
  if((p->pgdir = setupkvm()) == 0)
80104381:	e8 90 3b 00 00       	call   80107f16 <setupkvm>
80104386:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104389:	89 42 04             	mov    %eax,0x4(%edx)
8010438c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010438f:	8b 40 04             	mov    0x4(%eax),%eax
80104392:	85 c0                	test   %eax,%eax
80104394:	75 0c                	jne    801043a2 <userinit+0x37>
    panic("userinit: out of memory?");
80104396:	c7 04 24 3a 8b 10 80 	movl   $0x80108b3a,(%esp)
8010439d:	e8 b2 c1 ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801043a2:	ba 2c 00 00 00       	mov    $0x2c,%edx
801043a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043aa:	8b 40 04             	mov    0x4(%eax),%eax
801043ad:	89 54 24 08          	mov    %edx,0x8(%esp)
801043b1:	c7 44 24 04 00 b5 10 	movl   $0x8010b500,0x4(%esp)
801043b8:	80 
801043b9:	89 04 24             	mov    %eax,(%esp)
801043bc:	e8 b6 3d 00 00       	call   80108177 <inituvm>
  p->sz = PGSIZE;
801043c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c4:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801043ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043cd:	8b 40 18             	mov    0x18(%eax),%eax
801043d0:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801043d7:	00 
801043d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801043df:	00 
801043e0:	89 04 24             	mov    %eax,(%esp)
801043e3:	e8 e6 0f 00 00       	call   801053ce <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801043e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043eb:	8b 40 18             	mov    0x18(%eax),%eax
801043ee:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801043f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f7:	8b 40 18             	mov    0x18(%eax),%eax
801043fa:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104400:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104403:	8b 50 18             	mov    0x18(%eax),%edx
80104406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104409:	8b 40 18             	mov    0x18(%eax),%eax
8010440c:	8b 40 2c             	mov    0x2c(%eax),%eax
8010440f:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
80104413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104416:	8b 50 18             	mov    0x18(%eax),%edx
80104419:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010441c:	8b 40 18             	mov    0x18(%eax),%eax
8010441f:	8b 40 2c             	mov    0x2c(%eax),%eax
80104422:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
80104426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104429:	8b 40 18             	mov    0x18(%eax),%eax
8010442c:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104436:	8b 40 18             	mov    0x18(%eax),%eax
80104439:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104443:	8b 40 18             	mov    0x18(%eax),%eax
80104446:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010444d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104450:	83 c0 6c             	add    $0x6c,%eax
80104453:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010445a:	00 
8010445b:	c7 44 24 04 53 8b 10 	movl   $0x80108b53,0x4(%esp)
80104462:	80 
80104463:	89 04 24             	mov    %eax,(%esp)
80104466:	e8 6f 11 00 00       	call   801055da <safestrcpy>
  p->cwd = namei("/");
8010446b:	c7 04 24 5c 8b 10 80 	movl   $0x80108b5c,(%esp)
80104472:	e8 d4 e0 ff ff       	call   8010254b <namei>
80104477:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010447a:	89 42 68             	mov    %eax,0x68(%edx)

  p->cid = ROOTCONT;
8010447d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104480:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104487:	00 00 00 

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
8010448a:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80104491:	e8 d5 0c 00 00       	call   8010516b <acquire>

  p->state = RUNNABLE;
80104496:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104499:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
801044a0:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
801044a7:	e8 29 0d 00 00       	call   801051d5 <release>
}
801044ac:	c9                   	leave  
801044ad:	c3                   	ret    

801044ae <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801044ae:	55                   	push   %ebp
801044af:	89 e5                	mov    %esp,%ebp
801044b1:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
801044b4:	e8 66 fd ff ff       	call   8010421f <myproc>
801044b9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
801044bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044bf:	8b 00                	mov    (%eax),%eax
801044c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801044c4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801044c8:	7e 31                	jle    801044fb <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801044ca:	8b 55 08             	mov    0x8(%ebp),%edx
801044cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d0:	01 c2                	add    %eax,%edx
801044d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044d5:	8b 40 04             	mov    0x4(%eax),%eax
801044d8:	89 54 24 08          	mov    %edx,0x8(%esp)
801044dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044df:	89 54 24 04          	mov    %edx,0x4(%esp)
801044e3:	89 04 24             	mov    %eax,(%esp)
801044e6:	e8 f7 3d 00 00       	call   801082e2 <allocuvm>
801044eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801044ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801044f2:	75 3e                	jne    80104532 <growproc+0x84>
      return -1;
801044f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044f9:	eb 4f                	jmp    8010454a <growproc+0x9c>
  } else if(n < 0){
801044fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801044ff:	79 31                	jns    80104532 <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104501:	8b 55 08             	mov    0x8(%ebp),%edx
80104504:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104507:	01 c2                	add    %eax,%edx
80104509:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010450c:	8b 40 04             	mov    0x4(%eax),%eax
8010450f:	89 54 24 08          	mov    %edx,0x8(%esp)
80104513:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104516:	89 54 24 04          	mov    %edx,0x4(%esp)
8010451a:	89 04 24             	mov    %eax,(%esp)
8010451d:	e8 d6 3e 00 00       	call   801083f8 <deallocuvm>
80104522:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104525:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104529:	75 07                	jne    80104532 <growproc+0x84>
      return -1;
8010452b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104530:	eb 18                	jmp    8010454a <growproc+0x9c>
  }
  curproc->sz = sz;
80104532:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104535:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104538:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010453a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010453d:	89 04 24             	mov    %eax,(%esp)
80104540:	e8 ab 3a 00 00       	call   80107ff0 <switchuvm>
  return 0;
80104545:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010454a:	c9                   	leave  
8010454b:	c3                   	ret    

8010454c <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010454c:	55                   	push   %ebp
8010454d:	89 e5                	mov    %esp,%ebp
8010454f:	57                   	push   %edi
80104550:	56                   	push   %esi
80104551:	53                   	push   %ebx
80104552:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104555:	e8 c5 fc ff ff       	call   8010421f <myproc>
8010455a:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
8010455d:	e8 e6 fc ff ff       	call   80104248 <allocproc>
80104562:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104565:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104569:	75 0a                	jne    80104575 <fork+0x29>
    return -1;
8010456b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104570:	e9 35 01 00 00       	jmp    801046aa <fork+0x15e>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80104575:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104578:	8b 10                	mov    (%eax),%edx
8010457a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010457d:	8b 40 04             	mov    0x4(%eax),%eax
80104580:	89 54 24 04          	mov    %edx,0x4(%esp)
80104584:	89 04 24             	mov    %eax,(%esp)
80104587:	e8 0c 40 00 00       	call   80108598 <copyuvm>
8010458c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010458f:	89 42 04             	mov    %eax,0x4(%edx)
80104592:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104595:	8b 40 04             	mov    0x4(%eax),%eax
80104598:	85 c0                	test   %eax,%eax
8010459a:	75 2c                	jne    801045c8 <fork+0x7c>
    kfree(np->kstack);
8010459c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010459f:	8b 40 08             	mov    0x8(%eax),%eax
801045a2:	89 04 24             	mov    %eax,(%esp)
801045a5:	e8 17 e6 ff ff       	call   80102bc1 <kfree>
    np->kstack = 0;
801045aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045ad:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801045b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045b7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801045be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045c3:	e9 e2 00 00 00       	jmp    801046aa <fork+0x15e>
  }
  np->sz = curproc->sz;
801045c8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045cb:	8b 10                	mov    (%eax),%edx
801045cd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045d0:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801045d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
801045d8:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801045db:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045de:	8b 50 18             	mov    0x18(%eax),%edx
801045e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045e4:	8b 40 18             	mov    0x18(%eax),%eax
801045e7:	89 c3                	mov    %eax,%ebx
801045e9:	b8 13 00 00 00       	mov    $0x13,%eax
801045ee:	89 d7                	mov    %edx,%edi
801045f0:	89 de                	mov    %ebx,%esi
801045f2:	89 c1                	mov    %eax,%ecx
801045f4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801045f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045f9:	8b 40 18             	mov    0x18(%eax),%eax
801045fc:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104603:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010460a:	eb 36                	jmp    80104642 <fork+0xf6>
    if(curproc->ofile[i])
8010460c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010460f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104612:	83 c2 08             	add    $0x8,%edx
80104615:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104619:	85 c0                	test   %eax,%eax
8010461b:	74 22                	je     8010463f <fork+0xf3>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010461d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104620:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104623:	83 c2 08             	add    $0x8,%edx
80104626:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010462a:	89 04 24             	mov    %eax,(%esp)
8010462d:	e8 92 ca ff ff       	call   801010c4 <filedup>
80104632:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104635:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104638:	83 c1 08             	add    $0x8,%ecx
8010463b:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010463f:	ff 45 e4             	incl   -0x1c(%ebp)
80104642:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104646:	7e c4                	jle    8010460c <fork+0xc0>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80104648:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010464b:	8b 40 68             	mov    0x68(%eax),%eax
8010464e:	89 04 24             	mov    %eax,(%esp)
80104651:	e8 9e d3 ff ff       	call   801019f4 <idup>
80104656:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104659:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010465c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010465f:	8d 50 6c             	lea    0x6c(%eax),%edx
80104662:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104665:	83 c0 6c             	add    $0x6c,%eax
80104668:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010466f:	00 
80104670:	89 54 24 04          	mov    %edx,0x4(%esp)
80104674:	89 04 24             	mov    %eax,(%esp)
80104677:	e8 5e 0f 00 00       	call   801055da <safestrcpy>

  pid = np->pid;
8010467c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010467f:	8b 40 10             	mov    0x10(%eax),%eax
80104682:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80104685:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
8010468c:	e8 da 0a 00 00       	call   8010516b <acquire>

  np->state = RUNNABLE;
80104691:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104694:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
8010469b:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
801046a2:	e8 2e 0b 00 00       	call   801051d5 <release>

  return pid;
801046a7:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801046aa:	83 c4 2c             	add    $0x2c,%esp
801046ad:	5b                   	pop    %ebx
801046ae:	5e                   	pop    %esi
801046af:	5f                   	pop    %edi
801046b0:	5d                   	pop    %ebp
801046b1:	c3                   	ret    

801046b2 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801046b2:	55                   	push   %ebp
801046b3:	89 e5                	mov    %esp,%ebp
801046b5:	83 ec 28             	sub    $0x28,%esp
  struct proc *curproc = myproc();
801046b8:	e8 62 fb ff ff       	call   8010421f <myproc>
801046bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
801046c0:	a1 80 b7 10 80       	mov    0x8010b780,%eax
801046c5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801046c8:	75 0c                	jne    801046d6 <exit+0x24>
    panic("init exiting");
801046ca:	c7 04 24 5e 8b 10 80 	movl   $0x80108b5e,(%esp)
801046d1:	e8 7e be ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801046d6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801046dd:	eb 3a                	jmp    80104719 <exit+0x67>
    if(curproc->ofile[fd]){
801046df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046e5:	83 c2 08             	add    $0x8,%edx
801046e8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046ec:	85 c0                	test   %eax,%eax
801046ee:	74 26                	je     80104716 <exit+0x64>
      fileclose(curproc->ofile[fd]);
801046f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801046f6:	83 c2 08             	add    $0x8,%edx
801046f9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046fd:	89 04 24             	mov    %eax,(%esp)
80104700:	e8 07 ca ff ff       	call   8010110c <fileclose>
      curproc->ofile[fd] = 0;
80104705:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104708:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010470b:	83 c2 08             	add    $0x8,%edx
8010470e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104715:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104716:	ff 45 f0             	incl   -0x10(%ebp)
80104719:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010471d:	7e c0                	jle    801046df <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
8010471f:	e8 fb ed ff ff       	call   8010351f <begin_op>
  iput(curproc->cwd);
80104724:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104727:	8b 40 68             	mov    0x68(%eax),%eax
8010472a:	89 04 24             	mov    %eax,(%esp)
8010472d:	e8 42 d4 ff ff       	call   80101b74 <iput>
  end_op();
80104732:	e8 6a ee ff ff       	call   801035a1 <end_op>
  curproc->cwd = 0;
80104737:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010473a:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104741:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80104748:	e8 1e 0a 00 00       	call   8010516b <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
8010474d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104750:	8b 40 14             	mov    0x14(%eax),%eax
80104753:	89 04 24             	mov    %eax,(%esp)
80104756:	e8 d5 03 00 00       	call   80104b30 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010475b:	c7 45 f4 34 3f 11 80 	movl   $0x80113f34,-0xc(%ebp)
80104762:	eb 36                	jmp    8010479a <exit+0xe8>
    if(p->parent == curproc){
80104764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104767:	8b 40 14             	mov    0x14(%eax),%eax
8010476a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010476d:	75 24                	jne    80104793 <exit+0xe1>
      p->parent = initproc;
8010476f:	8b 15 80 b7 10 80    	mov    0x8010b780,%edx
80104775:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104778:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010477b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010477e:	8b 40 0c             	mov    0xc(%eax),%eax
80104781:	83 f8 05             	cmp    $0x5,%eax
80104784:	75 0d                	jne    80104793 <exit+0xe1>
        wakeup1(initproc);
80104786:	a1 80 b7 10 80       	mov    0x8010b780,%eax
8010478b:	89 04 24             	mov    %eax,(%esp)
8010478e:	e8 9d 03 00 00       	call   80104b30 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104793:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010479a:	81 7d f4 34 60 11 80 	cmpl   $0x80116034,-0xc(%ebp)
801047a1:	72 c1                	jb     80104764 <exit+0xb2>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801047a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047a6:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801047ad:	e8 c9 01 00 00       	call   8010497b <sched>
  panic("zombie exit");
801047b2:	c7 04 24 6b 8b 10 80 	movl   $0x80108b6b,(%esp)
801047b9:	e8 96 bd ff ff       	call   80100554 <panic>

801047be <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801047be:	55                   	push   %ebp
801047bf:	89 e5                	mov    %esp,%ebp
801047c1:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
801047c4:	e8 56 fa ff ff       	call   8010421f <myproc>
801047c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
801047cc:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
801047d3:	e8 93 09 00 00       	call   8010516b <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
801047d8:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047df:	c7 45 f4 34 3f 11 80 	movl   $0x80113f34,-0xc(%ebp)
801047e6:	e9 98 00 00 00       	jmp    80104883 <wait+0xc5>
      if(p->parent != curproc)
801047eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ee:	8b 40 14             	mov    0x14(%eax),%eax
801047f1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801047f4:	74 05                	je     801047fb <wait+0x3d>
        continue;
801047f6:	e9 81 00 00 00       	jmp    8010487c <wait+0xbe>
      havekids = 1;
801047fb:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104802:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104805:	8b 40 0c             	mov    0xc(%eax),%eax
80104808:	83 f8 05             	cmp    $0x5,%eax
8010480b:	75 6f                	jne    8010487c <wait+0xbe>
        // Found one.
        pid = p->pid;
8010480d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104810:	8b 40 10             	mov    0x10(%eax),%eax
80104813:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
80104816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104819:	8b 40 08             	mov    0x8(%eax),%eax
8010481c:	89 04 24             	mov    %eax,(%esp)
8010481f:	e8 9d e3 ff ff       	call   80102bc1 <kfree>
        p->kstack = 0;
80104824:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104827:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
8010482e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104831:	8b 40 04             	mov    0x4(%eax),%eax
80104834:	89 04 24             	mov    %eax,(%esp)
80104837:	e8 80 3c 00 00       	call   801084bc <freevm>
        p->pid = 0;
8010483c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010483f:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104849:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104850:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104853:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010485a:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104864:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010486b:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80104872:	e8 5e 09 00 00       	call   801051d5 <release>
        return pid;
80104877:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010487a:	eb 4f                	jmp    801048cb <wait+0x10d>
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010487c:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104883:	81 7d f4 34 60 11 80 	cmpl   $0x80116034,-0xc(%ebp)
8010488a:	0f 82 5b ff ff ff    	jb     801047eb <wait+0x2d>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104890:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104894:	74 0a                	je     801048a0 <wait+0xe2>
80104896:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104899:	8b 40 24             	mov    0x24(%eax),%eax
8010489c:	85 c0                	test   %eax,%eax
8010489e:	74 13                	je     801048b3 <wait+0xf5>
      release(&ptable.lock);
801048a0:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
801048a7:	e8 29 09 00 00       	call   801051d5 <release>
      return -1;
801048ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048b1:	eb 18                	jmp    801048cb <wait+0x10d>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801048b3:	c7 44 24 04 00 3f 11 	movl   $0x80113f00,0x4(%esp)
801048ba:	80 
801048bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801048be:	89 04 24             	mov    %eax,(%esp)
801048c1:	e8 d4 01 00 00       	call   80104a9a <sleep>
  }
801048c6:	e9 0d ff ff ff       	jmp    801047d8 <wait+0x1a>
}
801048cb:	c9                   	leave  
801048cc:	c3                   	ret    

801048cd <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801048cd:	55                   	push   %ebp
801048ce:	89 e5                	mov    %esp,%ebp
801048d0:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801048d3:	e8 c3 f8 ff ff       	call   8010419b <mycpu>
801048d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
801048db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048de:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801048e5:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801048e8:	e8 47 f8 ff ff       	call   80104134 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801048ed:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
801048f4:	e8 72 08 00 00       	call   8010516b <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801048f9:	c7 45 f4 34 3f 11 80 	movl   $0x80113f34,-0xc(%ebp)
80104900:	eb 5f                	jmp    80104961 <scheduler+0x94>
      if(p->state != RUNNABLE)
80104902:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104905:	8b 40 0c             	mov    0xc(%eax),%eax
80104908:	83 f8 03             	cmp    $0x3,%eax
8010490b:	74 02                	je     8010490f <scheduler+0x42>
        continue;
8010490d:	eb 4b                	jmp    8010495a <scheduler+0x8d>

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
8010490f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104912:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104915:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
8010491b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491e:	89 04 24             	mov    %eax,(%esp)
80104921:	e8 ca 36 00 00       	call   80107ff0 <switchuvm>
      p->state = RUNNING;
80104926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104929:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
80104930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104933:	8b 40 1c             	mov    0x1c(%eax),%eax
80104936:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104939:	83 c2 04             	add    $0x4,%edx
8010493c:	89 44 24 04          	mov    %eax,0x4(%esp)
80104940:	89 14 24             	mov    %edx,(%esp)
80104943:	e8 00 0d 00 00       	call   80105648 <swtch>
      switchkvm();
80104948:	e8 89 36 00 00       	call   80107fd6 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
8010494d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104950:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104957:	00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010495a:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104961:	81 7d f4 34 60 11 80 	cmpl   $0x80116034,-0xc(%ebp)
80104968:	72 98                	jb     80104902 <scheduler+0x35>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
8010496a:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80104971:	e8 5f 08 00 00       	call   801051d5 <release>

  }
80104976:	e9 6d ff ff ff       	jmp    801048e8 <scheduler+0x1b>

8010497b <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
8010497b:	55                   	push   %ebp
8010497c:	89 e5                	mov    %esp,%ebp
8010497e:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
80104981:	e8 99 f8 ff ff       	call   8010421f <myproc>
80104986:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
80104989:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80104990:	e8 04 09 00 00       	call   80105299 <holding>
80104995:	85 c0                	test   %eax,%eax
80104997:	75 0c                	jne    801049a5 <sched+0x2a>
    panic("sched ptable.lock");
80104999:	c7 04 24 77 8b 10 80 	movl   $0x80108b77,(%esp)
801049a0:	e8 af bb ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
801049a5:	e8 f1 f7 ff ff       	call   8010419b <mycpu>
801049aa:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801049b0:	83 f8 01             	cmp    $0x1,%eax
801049b3:	74 0c                	je     801049c1 <sched+0x46>
    panic("sched locks");
801049b5:	c7 04 24 89 8b 10 80 	movl   $0x80108b89,(%esp)
801049bc:	e8 93 bb ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
801049c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c4:	8b 40 0c             	mov    0xc(%eax),%eax
801049c7:	83 f8 04             	cmp    $0x4,%eax
801049ca:	75 0c                	jne    801049d8 <sched+0x5d>
    panic("sched running");
801049cc:	c7 04 24 95 8b 10 80 	movl   $0x80108b95,(%esp)
801049d3:	e8 7c bb ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
801049d8:	e8 47 f7 ff ff       	call   80104124 <readeflags>
801049dd:	25 00 02 00 00       	and    $0x200,%eax
801049e2:	85 c0                	test   %eax,%eax
801049e4:	74 0c                	je     801049f2 <sched+0x77>
    panic("sched interruptible");
801049e6:	c7 04 24 a3 8b 10 80 	movl   $0x80108ba3,(%esp)
801049ed:	e8 62 bb ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
801049f2:	e8 a4 f7 ff ff       	call   8010419b <mycpu>
801049f7:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801049fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104a00:	e8 96 f7 ff ff       	call   8010419b <mycpu>
80104a05:	8b 40 04             	mov    0x4(%eax),%eax
80104a08:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104a0b:	83 c2 1c             	add    $0x1c,%edx
80104a0e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a12:	89 14 24             	mov    %edx,(%esp)
80104a15:	e8 2e 0c 00 00       	call   80105648 <swtch>
  mycpu()->intena = intena;
80104a1a:	e8 7c f7 ff ff       	call   8010419b <mycpu>
80104a1f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104a22:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104a28:	c9                   	leave  
80104a29:	c3                   	ret    

80104a2a <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104a2a:	55                   	push   %ebp
80104a2b:	89 e5                	mov    %esp,%ebp
80104a2d:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104a30:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80104a37:	e8 2f 07 00 00       	call   8010516b <acquire>
  myproc()->state = RUNNABLE;
80104a3c:	e8 de f7 ff ff       	call   8010421f <myproc>
80104a41:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104a48:	e8 2e ff ff ff       	call   8010497b <sched>
  release(&ptable.lock);
80104a4d:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80104a54:	e8 7c 07 00 00       	call   801051d5 <release>
}
80104a59:	c9                   	leave  
80104a5a:	c3                   	ret    

80104a5b <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104a5b:	55                   	push   %ebp
80104a5c:	89 e5                	mov    %esp,%ebp
80104a5e:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104a61:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80104a68:	e8 68 07 00 00       	call   801051d5 <release>

  if (first) {
80104a6d:	a1 04 b0 10 80       	mov    0x8010b004,%eax
80104a72:	85 c0                	test   %eax,%eax
80104a74:	74 22                	je     80104a98 <forkret+0x3d>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104a76:	c7 05 04 b0 10 80 00 	movl   $0x0,0x8010b004
80104a7d:	00 00 00 
    iinit(ROOTDEV);
80104a80:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104a87:	e8 33 cc ff ff       	call   801016bf <iinit>
    initlog(ROOTDEV);
80104a8c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104a93:	e8 88 e8 ff ff       	call   80103320 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104a98:	c9                   	leave  
80104a99:	c3                   	ret    

80104a9a <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104a9a:	55                   	push   %ebp
80104a9b:	89 e5                	mov    %esp,%ebp
80104a9d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104aa0:	e8 7a f7 ff ff       	call   8010421f <myproc>
80104aa5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104aa8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104aac:	75 0c                	jne    80104aba <sleep+0x20>
    panic("sleep");
80104aae:	c7 04 24 b7 8b 10 80 	movl   $0x80108bb7,(%esp)
80104ab5:	e8 9a ba ff ff       	call   80100554 <panic>

  if(lk == 0)
80104aba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104abe:	75 0c                	jne    80104acc <sleep+0x32>
    panic("sleep without lk");
80104ac0:	c7 04 24 bd 8b 10 80 	movl   $0x80108bbd,(%esp)
80104ac7:	e8 88 ba ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104acc:	81 7d 0c 00 3f 11 80 	cmpl   $0x80113f00,0xc(%ebp)
80104ad3:	74 17                	je     80104aec <sleep+0x52>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104ad5:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80104adc:	e8 8a 06 00 00       	call   8010516b <acquire>
    release(lk);
80104ae1:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ae4:	89 04 24             	mov    %eax,(%esp)
80104ae7:	e8 e9 06 00 00       	call   801051d5 <release>
  }
  // Go to sleep.
  p->chan = chan;
80104aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aef:	8b 55 08             	mov    0x8(%ebp),%edx
80104af2:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af8:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104aff:	e8 77 fe ff ff       	call   8010497b <sched>

  // Tidy up.
  p->chan = 0;
80104b04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b07:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104b0e:	81 7d 0c 00 3f 11 80 	cmpl   $0x80113f00,0xc(%ebp)
80104b15:	74 17                	je     80104b2e <sleep+0x94>
    release(&ptable.lock);
80104b17:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80104b1e:	e8 b2 06 00 00       	call   801051d5 <release>
    acquire(lk);
80104b23:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b26:	89 04 24             	mov    %eax,(%esp)
80104b29:	e8 3d 06 00 00       	call   8010516b <acquire>
  }
}
80104b2e:	c9                   	leave  
80104b2f:	c3                   	ret    

80104b30 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104b30:	55                   	push   %ebp
80104b31:	89 e5                	mov    %esp,%ebp
80104b33:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b36:	c7 45 fc 34 3f 11 80 	movl   $0x80113f34,-0x4(%ebp)
80104b3d:	eb 27                	jmp    80104b66 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104b3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b42:	8b 40 0c             	mov    0xc(%eax),%eax
80104b45:	83 f8 02             	cmp    $0x2,%eax
80104b48:	75 15                	jne    80104b5f <wakeup1+0x2f>
80104b4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b4d:	8b 40 20             	mov    0x20(%eax),%eax
80104b50:	3b 45 08             	cmp    0x8(%ebp),%eax
80104b53:	75 0a                	jne    80104b5f <wakeup1+0x2f>
      p->state = RUNNABLE;
80104b55:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104b58:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104b5f:	81 45 fc 84 00 00 00 	addl   $0x84,-0x4(%ebp)
80104b66:	81 7d fc 34 60 11 80 	cmpl   $0x80116034,-0x4(%ebp)
80104b6d:	72 d0                	jb     80104b3f <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104b6f:	c9                   	leave  
80104b70:	c3                   	ret    

80104b71 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104b71:	55                   	push   %ebp
80104b72:	89 e5                	mov    %esp,%ebp
80104b74:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);
80104b77:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80104b7e:	e8 e8 05 00 00       	call   8010516b <acquire>
  wakeup1(chan);
80104b83:	8b 45 08             	mov    0x8(%ebp),%eax
80104b86:	89 04 24             	mov    %eax,(%esp)
80104b89:	e8 a2 ff ff ff       	call   80104b30 <wakeup1>
  release(&ptable.lock);
80104b8e:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80104b95:	e8 3b 06 00 00       	call   801051d5 <release>
}
80104b9a:	c9                   	leave  
80104b9b:	c3                   	ret    

80104b9c <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104b9c:	55                   	push   %ebp
80104b9d:	89 e5                	mov    %esp,%ebp
80104b9f:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104ba2:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80104ba9:	e8 bd 05 00 00       	call   8010516b <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bae:	c7 45 f4 34 3f 11 80 	movl   $0x80113f34,-0xc(%ebp)
80104bb5:	eb 44                	jmp    80104bfb <kill+0x5f>
    if(p->pid == pid){
80104bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bba:	8b 40 10             	mov    0x10(%eax),%eax
80104bbd:	3b 45 08             	cmp    0x8(%ebp),%eax
80104bc0:	75 32                	jne    80104bf4 <kill+0x58>
      p->killed = 1;
80104bc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc5:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bcf:	8b 40 0c             	mov    0xc(%eax),%eax
80104bd2:	83 f8 02             	cmp    $0x2,%eax
80104bd5:	75 0a                	jne    80104be1 <kill+0x45>
        p->state = RUNNABLE;
80104bd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bda:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104be1:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80104be8:	e8 e8 05 00 00       	call   801051d5 <release>
      return 0;
80104bed:	b8 00 00 00 00       	mov    $0x0,%eax
80104bf2:	eb 21                	jmp    80104c15 <kill+0x79>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104bf4:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104bfb:	81 7d f4 34 60 11 80 	cmpl   $0x80116034,-0xc(%ebp)
80104c02:	72 b3                	jb     80104bb7 <kill+0x1b>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80104c04:	c7 04 24 00 3f 11 80 	movl   $0x80113f00,(%esp)
80104c0b:	e8 c5 05 00 00       	call   801051d5 <release>
  return -1;
80104c10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c15:	c9                   	leave  
80104c16:	c3                   	ret    

80104c17 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104c17:	55                   	push   %ebp
80104c18:	89 e5                	mov    %esp,%ebp
80104c1a:	83 ec 58             	sub    $0x58,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c1d:	c7 45 f0 34 3f 11 80 	movl   $0x80113f34,-0x10(%ebp)
80104c24:	e9 d8 00 00 00       	jmp    80104d01 <procdump+0xea>
    if(p->state == UNUSED)
80104c29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c2c:	8b 40 0c             	mov    0xc(%eax),%eax
80104c2f:	85 c0                	test   %eax,%eax
80104c31:	75 05                	jne    80104c38 <procdump+0x21>
      continue;
80104c33:	e9 c2 00 00 00       	jmp    80104cfa <procdump+0xe3>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104c38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c3b:	8b 40 0c             	mov    0xc(%eax),%eax
80104c3e:	83 f8 05             	cmp    $0x5,%eax
80104c41:	77 23                	ja     80104c66 <procdump+0x4f>
80104c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c46:	8b 40 0c             	mov    0xc(%eax),%eax
80104c49:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104c50:	85 c0                	test   %eax,%eax
80104c52:	74 12                	je     80104c66 <procdump+0x4f>
      state = states[p->state];
80104c54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c57:	8b 40 0c             	mov    0xc(%eax),%eax
80104c5a:	8b 04 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%eax
80104c61:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104c64:	eb 07                	jmp    80104c6d <procdump+0x56>
    else
      state = "???";
80104c66:	c7 45 ec ce 8b 10 80 	movl   $0x80108bce,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80104c6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c70:	8d 50 6c             	lea    0x6c(%eax),%edx
80104c73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c76:	8b 40 10             	mov    0x10(%eax),%eax
80104c79:	89 54 24 0c          	mov    %edx,0xc(%esp)
80104c7d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104c80:	89 54 24 08          	mov    %edx,0x8(%esp)
80104c84:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c88:	c7 04 24 d2 8b 10 80 	movl   $0x80108bd2,(%esp)
80104c8f:	e8 2d b7 ff ff       	call   801003c1 <cprintf>
    if(p->state == SLEEPING){
80104c94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c97:	8b 40 0c             	mov    0xc(%eax),%eax
80104c9a:	83 f8 02             	cmp    $0x2,%eax
80104c9d:	75 4f                	jne    80104cee <procdump+0xd7>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104c9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ca2:	8b 40 1c             	mov    0x1c(%eax),%eax
80104ca5:	8b 40 0c             	mov    0xc(%eax),%eax
80104ca8:	83 c0 08             	add    $0x8,%eax
80104cab:	8d 55 c4             	lea    -0x3c(%ebp),%edx
80104cae:	89 54 24 04          	mov    %edx,0x4(%esp)
80104cb2:	89 04 24             	mov    %eax,(%esp)
80104cb5:	e8 68 05 00 00       	call   80105222 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104cba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104cc1:	eb 1a                	jmp    80104cdd <procdump+0xc6>
        cprintf(" %p", pc[i]);
80104cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cc6:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104cca:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cce:	c7 04 24 db 8b 10 80 	movl   $0x80108bdb,(%esp)
80104cd5:	e8 e7 b6 ff ff       	call   801003c1 <cprintf>
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104cda:	ff 45 f4             	incl   -0xc(%ebp)
80104cdd:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104ce1:	7f 0b                	jg     80104cee <procdump+0xd7>
80104ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce6:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104cea:	85 c0                	test   %eax,%eax
80104cec:	75 d5                	jne    80104cc3 <procdump+0xac>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104cee:	c7 04 24 df 8b 10 80 	movl   $0x80108bdf,(%esp)
80104cf5:	e8 c7 b6 ff ff       	call   801003c1 <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cfa:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104d01:	81 7d f0 34 60 11 80 	cmpl   $0x80116034,-0x10(%ebp)
80104d08:	0f 82 1b ff ff ff    	jb     80104c29 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80104d0e:	c9                   	leave  
80104d0f:	c3                   	ret    

80104d10 <cinit>:
int nextcid = 1;

// TODO: call this somewhere
void
cinit(void)
{
80104d10:	55                   	push   %ebp
80104d11:	89 e5                	mov    %esp,%ebp
80104d13:	83 ec 18             	sub    $0x18,%esp
  initlock(&ctable.lock, "ctable");
80104d16:	c7 44 24 04 0c 8c 10 	movl   $0x80108c0c,0x4(%esp)
80104d1d:	80 
80104d1e:	c7 04 24 40 60 11 80 	movl   $0x80116040,(%esp)
80104d25:	e8 20 04 00 00       	call   8010514a <initlock>
}
80104d2a:	c9                   	leave  
80104d2b:	c3                   	ret    

80104d2c <mycont>:

struct cont*
mycont(void) {
80104d2c:	55                   	push   %ebp
80104d2d:	89 e5                	mov    %esp,%ebp
	return &currcont;
80104d2f:	b8 c0 61 11 80       	mov    $0x801161c0,%eax
}
80104d34:	5d                   	pop    %ebp
80104d35:	c3                   	ret    

80104d36 <alloccont>:
// Look in the container table for an CUNUSED cont.
// If found, change state to CEMBRYO
// Otherwise return 0.
static struct cont*
alloccont(void)
{
80104d36:	55                   	push   %ebp
80104d37:	89 e5                	mov    %esp,%ebp
80104d39:	83 ec 28             	sub    $0x28,%esp
	struct cont *c;

	acquire(&ctable.lock);
80104d3c:	c7 04 24 40 60 11 80 	movl   $0x80116040,(%esp)
80104d43:	e8 23 04 00 00       	call   8010516b <acquire>

	for(c = ctable.cont; c < &ctable.cont[NCONT]; c++)
80104d48:	c7 45 f4 74 60 11 80 	movl   $0x80116074,-0xc(%ebp)
80104d4f:	eb 3e                	jmp    80104d8f <alloccont+0x59>
	if(c->state == CUNUSED)
80104d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d54:	8b 40 14             	mov    0x14(%eax),%eax
80104d57:	85 c0                	test   %eax,%eax
80104d59:	75 30                	jne    80104d8b <alloccont+0x55>
	  goto found;
80104d5b:	90                   	nop

	release(&ctable.lock);
	return 0;

found:
	c->state = CEMBRYO;
80104d5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d5f:	c7 40 14 01 00 00 00 	movl   $0x1,0x14(%eax)
	c->cid = nextcid++;
80104d66:	a1 20 b0 10 80       	mov    0x8010b020,%eax
80104d6b:	8d 50 01             	lea    0x1(%eax),%edx
80104d6e:	89 15 20 b0 10 80    	mov    %edx,0x8010b020
80104d74:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d77:	89 42 0c             	mov    %eax,0xc(%edx)

	release(&ctable.lock);
80104d7a:	c7 04 24 40 60 11 80 	movl   $0x80116040,(%esp)
80104d81:	e8 4f 04 00 00       	call   801051d5 <release>

	return c;
80104d86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d89:	eb 1e                	jmp    80104da9 <alloccont+0x73>
{
	struct cont *c;

	acquire(&ctable.lock);

	for(c = ctable.cont; c < &ctable.cont[NCONT]; c++)
80104d8b:	83 45 f4 28          	addl   $0x28,-0xc(%ebp)
80104d8f:	81 7d f4 b4 61 11 80 	cmpl   $0x801161b4,-0xc(%ebp)
80104d96:	72 b9                	jb     80104d51 <alloccont+0x1b>
	if(c->state == CUNUSED)
	  goto found;

	release(&ctable.lock);
80104d98:	c7 04 24 40 60 11 80 	movl   $0x80116040,(%esp)
80104d9f:	e8 31 04 00 00       	call   801051d5 <release>
	return 0;
80104da4:	b8 00 00 00 00       	mov    $0x0,%eax
	c->cid = nextcid++;

	release(&ctable.lock);

	return c;
}
80104da9:	c9                   	leave  
80104daa:	c3                   	ret    

80104dab <movefile>:

/* Moves file src to folder dst 
TODO: Implement */
int
movefile(char* dst, char* src) {
80104dab:	55                   	push   %ebp
80104dac:	89 e5                	mov    %esp,%ebp
80104dae:	57                   	push   %edi
80104daf:	56                   	push   %esi
80104db0:	53                   	push   %ebx
80104db1:	83 ec 2c             	sub    $0x2c,%esp
80104db4:	89 e0                	mov    %esp,%eax
80104db6:	89 c6                	mov    %eax,%esi
	
	int pathsize = sizeof(dst) + sizeof(src) + 2; // dst.len + '\' + src.len + \0
80104db8:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
	char path[pathsize]; 
80104dbf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104dc2:	8d 50 ff             	lea    -0x1(%eax),%edx
80104dc5:	89 55 e0             	mov    %edx,-0x20(%ebp)
80104dc8:	ba 10 00 00 00       	mov    $0x10,%edx
80104dcd:	4a                   	dec    %edx
80104dce:	01 d0                	add    %edx,%eax
80104dd0:	b9 10 00 00 00       	mov    $0x10,%ecx
80104dd5:	ba 00 00 00 00       	mov    $0x0,%edx
80104dda:	f7 f1                	div    %ecx
80104ddc:	6b c0 10             	imul   $0x10,%eax,%eax
80104ddf:	29 c4                	sub    %eax,%esp
80104de1:	8d 44 24 0c          	lea    0xc(%esp),%eax
80104de5:	83 c0 00             	add    $0x0,%eax
80104de8:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// struct file *f;
	// struct inode *ip;

	memmove(path, dst, strlen(dst));
80104deb:	8b 45 08             	mov    0x8(%ebp),%eax
80104dee:	89 04 24             	mov    %eax,(%esp)
80104df1:	e8 2b 08 00 00       	call   80105621 <strlen>
80104df6:	89 c2                	mov    %eax,%edx
80104df8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104dfb:	89 54 24 08          	mov    %edx,0x8(%esp)
80104dff:	8b 55 08             	mov    0x8(%ebp),%edx
80104e02:	89 54 24 04          	mov    %edx,0x4(%esp)
80104e06:	89 04 24             	mov    %eax,(%esp)
80104e09:	e8 89 06 00 00       	call   80105497 <memmove>
	memmove(path + strlen(dst), "/", 1);
80104e0e:	8b 5d dc             	mov    -0x24(%ebp),%ebx
80104e11:	8b 45 08             	mov    0x8(%ebp),%eax
80104e14:	89 04 24             	mov    %eax,(%esp)
80104e17:	e8 05 08 00 00       	call   80105621 <strlen>
80104e1c:	01 d8                	add    %ebx,%eax
80104e1e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80104e25:	00 
80104e26:	c7 44 24 04 13 8c 10 	movl   $0x80108c13,0x4(%esp)
80104e2d:	80 
80104e2e:	89 04 24             	mov    %eax,(%esp)
80104e31:	e8 61 06 00 00       	call   80105497 <memmove>
	memmove(path + strlen(dst) + 1, src, strlen(src));
80104e36:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e39:	89 04 24             	mov    %eax,(%esp)
80104e3c:	e8 e0 07 00 00       	call   80105621 <strlen>
80104e41:	89 c3                	mov    %eax,%ebx
80104e43:	8b 7d dc             	mov    -0x24(%ebp),%edi
80104e46:	8b 45 08             	mov    0x8(%ebp),%eax
80104e49:	89 04 24             	mov    %eax,(%esp)
80104e4c:	e8 d0 07 00 00       	call   80105621 <strlen>
80104e51:	40                   	inc    %eax
80104e52:	8d 14 07             	lea    (%edi,%eax,1),%edx
80104e55:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80104e59:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e5c:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e60:	89 14 24             	mov    %edx,(%esp)
80104e63:	e8 2f 06 00 00       	call   80105497 <memmove>
	memmove(path + strlen(dst) + 1 + strlen(src), "\0", 1);
80104e68:	8b 5d dc             	mov    -0x24(%ebp),%ebx
80104e6b:	8b 45 08             	mov    0x8(%ebp),%eax
80104e6e:	89 04 24             	mov    %eax,(%esp)
80104e71:	e8 ab 07 00 00       	call   80105621 <strlen>
80104e76:	89 c7                	mov    %eax,%edi
80104e78:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e7b:	89 04 24             	mov    %eax,(%esp)
80104e7e:	e8 9e 07 00 00       	call   80105621 <strlen>
80104e83:	01 f8                	add    %edi,%eax
80104e85:	40                   	inc    %eax
80104e86:	01 d8                	add    %ebx,%eax
80104e88:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80104e8f:	00 
80104e90:	c7 44 24 04 15 8c 10 	movl   $0x80108c15,0x4(%esp)
80104e97:	80 
80104e98:	89 04 24             	mov    %eax,(%esp)
80104e9b:	e8 f7 05 00 00       	call   80105497 <memmove>

	cprintf("movefile path: %s\n", path);
80104ea0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104ea3:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ea7:	c7 04 24 17 8c 10 80 	movl   $0x80108c17,(%esp)
80104eae:	e8 0e b5 ff ff       	call   801003c1 <cprintf>
	// // Copy contents of src into new file
	// char* source;
	// fileread();	


	return 1;
80104eb3:	b8 01 00 00 00       	mov    $0x1,%eax
80104eb8:	89 f4                	mov    %esi,%esp
}
80104eba:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104ebd:	5b                   	pop    %ebx
80104ebe:	5e                   	pop    %esi
80104ebf:	5f                   	pop    %edi
80104ec0:	5d                   	pop    %ebp
80104ec1:	c3                   	ret    

80104ec2 <ccreate>:

int 
ccreate(char* name, char* progv[MAXARG], int progc, int mproc, uint msz, uint mdsk)
{
80104ec2:	55                   	push   %ebp
80104ec3:	89 e5                	mov    %esp,%ebp
80104ec5:	83 ec 28             	sub    $0x28,%esp
	int i;
	struct cont *nc;
	struct inode *rootdir;

	// Allocate container.
	if ((nc = alloccont()) == 0) {
80104ec8:	e8 69 fe ff ff       	call   80104d36 <alloccont>
80104ecd:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104ed0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104ed4:	75 0a                	jne    80104ee0 <ccreate+0x1e>
		return -1;
80104ed6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104edb:	e9 23 01 00 00       	jmp    80105003 <ccreate+0x141>
	}

	// Create a directory (same implementation as sys_mkdir)	
	// TODO: check if container exists
	begin_op();
80104ee0:	e8 3a e6 ff ff       	call   8010351f <begin_op>
	if((rootdir = create(name, T_DIR, 0, 0)) == 0){
80104ee5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80104eec:	00 
80104eed:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80104ef4:	00 
80104ef5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80104efc:	00 
80104efd:	8b 45 08             	mov    0x8(%ebp),%eax
80104f00:	89 04 24             	mov    %eax,(%esp)
80104f03:	e8 cb 0f 00 00       	call   80105ed3 <create>
80104f08:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104f0b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80104f0f:	75 22                	jne    80104f33 <ccreate+0x71>
		end_op();
80104f11:	e8 8b e6 ff ff       	call   801035a1 <end_op>
		cprintf("Unable to create container directory %s\n", name);
80104f16:	8b 45 08             	mov    0x8(%ebp),%eax
80104f19:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f1d:	c7 04 24 2c 8c 10 80 	movl   $0x80108c2c,(%esp)
80104f24:	e8 98 b4 ff ff       	call   801003c1 <cprintf>
		return -1;
80104f29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f2e:	e9 d0 00 00 00       	jmp    80105003 <ccreate+0x141>
	}
	iunlockput(rootdir);
80104f33:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104f36:	89 04 24             	mov    %eax,(%esp)
80104f39:	e8 e7 cc ff ff       	call   80101c25 <iunlockput>
	end_op();	
80104f3e:	e8 5e e6 ff ff       	call   801035a1 <end_op>

	// Move files into folder
	for (i = 0; i < progc; i++) {
80104f43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f4a:	eb 48                	jmp    80104f94 <ccreate+0xd2>
		if (movefile(name, progv[i]) == 0) 
80104f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f4f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f56:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f59:	01 d0                	add    %edx,%eax
80104f5b:	8b 00                	mov    (%eax),%eax
80104f5d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f61:	8b 45 08             	mov    0x8(%ebp),%eax
80104f64:	89 04 24             	mov    %eax,(%esp)
80104f67:	e8 3f fe ff ff       	call   80104dab <movefile>
80104f6c:	85 c0                	test   %eax,%eax
80104f6e:	75 21                	jne    80104f91 <ccreate+0xcf>
			cprintf("Unable to move file %s\n", progv[i]);
80104f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f73:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104f7a:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f7d:	01 d0                	add    %edx,%eax
80104f7f:	8b 00                	mov    (%eax),%eax
80104f81:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f85:	c7 04 24 55 8c 10 80 	movl   $0x80108c55,(%esp)
80104f8c:	e8 30 b4 ff ff       	call   801003c1 <cprintf>
	}
	iunlockput(rootdir);
	end_op();	

	// Move files into folder
	for (i = 0; i < progc; i++) {
80104f91:	ff 45 f4             	incl   -0xc(%ebp)
80104f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f97:	3b 45 10             	cmp    0x10(%ebp),%eax
80104f9a:	7c b0                	jl     80104f4c <ccreate+0x8a>
		if (movefile(name, progv[i]) == 0) 
			cprintf("Unable to move file %s\n", progv[i]);
	}

	acquire(&ctable.lock);
80104f9c:	c7 04 24 40 60 11 80 	movl   $0x80116040,(%esp)
80104fa3:	e8 c3 01 00 00       	call   8010516b <acquire>
	nc->mproc = mproc;
80104fa8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fab:	8b 55 14             	mov    0x14(%ebp),%edx
80104fae:	89 50 08             	mov    %edx,0x8(%eax)
	nc->msz = msz;
80104fb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fb4:	8b 55 18             	mov    0x18(%ebp),%edx
80104fb7:	89 10                	mov    %edx,(%eax)
	nc->mdsk = mdsk;
80104fb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fbc:	8b 55 1c             	mov    0x1c(%ebp),%edx
80104fbf:	89 50 04             	mov    %edx,0x4(%eax)
	nc->rootdir = rootdir;
80104fc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fc5:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104fc8:	89 50 10             	mov    %edx,0x10(%eax)
	strncpy(nc->name, name, 16);
80104fcb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fce:	8d 50 18             	lea    0x18(%eax),%edx
80104fd1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104fd8:	00 
80104fd9:	8b 45 08             	mov    0x8(%ebp),%eax
80104fdc:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fe0:	89 14 24             	mov    %edx,(%esp)
80104fe3:	e8 9c 05 00 00       	call   80105584 <strncpy>
	nc->state = CRUNNABLE;	
80104fe8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104feb:	c7 40 14 02 00 00 00 	movl   $0x2,0x14(%eax)
	release(&ctable.lock);	
80104ff2:	c7 04 24 40 60 11 80 	movl   $0x80116040,(%esp)
80104ff9:	e8 d7 01 00 00       	call   801051d5 <release>

	return 1;  
80104ffe:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105003:	c9                   	leave  
80105004:	c3                   	ret    

80105005 <cstart>:

void
cstart(char* name, int argc, char** argv) 
{
80105005:	55                   	push   %ebp
80105006:	89 e5                	mov    %esp,%ebp
	// Check if RUNNABLE
	// <name> prog arg1 [arg2 ...]
	// acquire(&ctable.lock);
	// nc->state = CRUNNING;		
	// release(&ctable.lock);	
}
80105008:	5d                   	pop    %ebp
80105009:	c3                   	ret    
	...

8010500c <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
8010500c:	55                   	push   %ebp
8010500d:	89 e5                	mov    %esp,%ebp
8010500f:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
80105012:	8b 45 08             	mov    0x8(%ebp),%eax
80105015:	83 c0 04             	add    $0x4,%eax
80105018:	c7 44 24 04 6d 8c 10 	movl   $0x80108c6d,0x4(%esp)
8010501f:	80 
80105020:	89 04 24             	mov    %eax,(%esp)
80105023:	e8 22 01 00 00       	call   8010514a <initlock>
  lk->name = name;
80105028:	8b 45 08             	mov    0x8(%ebp),%eax
8010502b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010502e:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105031:	8b 45 08             	mov    0x8(%ebp),%eax
80105034:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010503a:	8b 45 08             	mov    0x8(%ebp),%eax
8010503d:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105044:	c9                   	leave  
80105045:	c3                   	ret    

80105046 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80105046:	55                   	push   %ebp
80105047:	89 e5                	mov    %esp,%ebp
80105049:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
8010504c:	8b 45 08             	mov    0x8(%ebp),%eax
8010504f:	83 c0 04             	add    $0x4,%eax
80105052:	89 04 24             	mov    %eax,(%esp)
80105055:	e8 11 01 00 00       	call   8010516b <acquire>
  while (lk->locked) {
8010505a:	eb 15                	jmp    80105071 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
8010505c:	8b 45 08             	mov    0x8(%ebp),%eax
8010505f:	83 c0 04             	add    $0x4,%eax
80105062:	89 44 24 04          	mov    %eax,0x4(%esp)
80105066:	8b 45 08             	mov    0x8(%ebp),%eax
80105069:	89 04 24             	mov    %eax,(%esp)
8010506c:	e8 29 fa ff ff       	call   80104a9a <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80105071:	8b 45 08             	mov    0x8(%ebp),%eax
80105074:	8b 00                	mov    (%eax),%eax
80105076:	85 c0                	test   %eax,%eax
80105078:	75 e2                	jne    8010505c <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
8010507a:	8b 45 08             	mov    0x8(%ebp),%eax
8010507d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80105083:	e8 97 f1 ff ff       	call   8010421f <myproc>
80105088:	8b 50 10             	mov    0x10(%eax),%edx
8010508b:	8b 45 08             	mov    0x8(%ebp),%eax
8010508e:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105091:	8b 45 08             	mov    0x8(%ebp),%eax
80105094:	83 c0 04             	add    $0x4,%eax
80105097:	89 04 24             	mov    %eax,(%esp)
8010509a:	e8 36 01 00 00       	call   801051d5 <release>
}
8010509f:	c9                   	leave  
801050a0:	c3                   	ret    

801050a1 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801050a1:	55                   	push   %ebp
801050a2:	89 e5                	mov    %esp,%ebp
801050a4:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
801050a7:	8b 45 08             	mov    0x8(%ebp),%eax
801050aa:	83 c0 04             	add    $0x4,%eax
801050ad:	89 04 24             	mov    %eax,(%esp)
801050b0:	e8 b6 00 00 00       	call   8010516b <acquire>
  lk->locked = 0;
801050b5:	8b 45 08             	mov    0x8(%ebp),%eax
801050b8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801050be:	8b 45 08             	mov    0x8(%ebp),%eax
801050c1:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801050c8:	8b 45 08             	mov    0x8(%ebp),%eax
801050cb:	89 04 24             	mov    %eax,(%esp)
801050ce:	e8 9e fa ff ff       	call   80104b71 <wakeup>
  release(&lk->lk);
801050d3:	8b 45 08             	mov    0x8(%ebp),%eax
801050d6:	83 c0 04             	add    $0x4,%eax
801050d9:	89 04 24             	mov    %eax,(%esp)
801050dc:	e8 f4 00 00 00       	call   801051d5 <release>
}
801050e1:	c9                   	leave  
801050e2:	c3                   	ret    

801050e3 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801050e3:	55                   	push   %ebp
801050e4:	89 e5                	mov    %esp,%ebp
801050e6:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
801050e9:	8b 45 08             	mov    0x8(%ebp),%eax
801050ec:	83 c0 04             	add    $0x4,%eax
801050ef:	89 04 24             	mov    %eax,(%esp)
801050f2:	e8 74 00 00 00       	call   8010516b <acquire>
  r = lk->locked;
801050f7:	8b 45 08             	mov    0x8(%ebp),%eax
801050fa:	8b 00                	mov    (%eax),%eax
801050fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801050ff:	8b 45 08             	mov    0x8(%ebp),%eax
80105102:	83 c0 04             	add    $0x4,%eax
80105105:	89 04 24             	mov    %eax,(%esp)
80105108:	e8 c8 00 00 00       	call   801051d5 <release>
  return r;
8010510d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105110:	c9                   	leave  
80105111:	c3                   	ret    
	...

80105114 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105114:	55                   	push   %ebp
80105115:	89 e5                	mov    %esp,%ebp
80105117:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010511a:	9c                   	pushf  
8010511b:	58                   	pop    %eax
8010511c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010511f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105122:	c9                   	leave  
80105123:	c3                   	ret    

80105124 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105124:	55                   	push   %ebp
80105125:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105127:	fa                   	cli    
}
80105128:	5d                   	pop    %ebp
80105129:	c3                   	ret    

8010512a <sti>:

static inline void
sti(void)
{
8010512a:	55                   	push   %ebp
8010512b:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010512d:	fb                   	sti    
}
8010512e:	5d                   	pop    %ebp
8010512f:	c3                   	ret    

80105130 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105130:	55                   	push   %ebp
80105131:	89 e5                	mov    %esp,%ebp
80105133:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105136:	8b 55 08             	mov    0x8(%ebp),%edx
80105139:	8b 45 0c             	mov    0xc(%ebp),%eax
8010513c:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010513f:	f0 87 02             	lock xchg %eax,(%edx)
80105142:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105145:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105148:	c9                   	leave  
80105149:	c3                   	ret    

8010514a <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010514a:	55                   	push   %ebp
8010514b:	89 e5                	mov    %esp,%ebp
  lk->name = name;
8010514d:	8b 45 08             	mov    0x8(%ebp),%eax
80105150:	8b 55 0c             	mov    0xc(%ebp),%edx
80105153:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105156:	8b 45 08             	mov    0x8(%ebp),%eax
80105159:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010515f:	8b 45 08             	mov    0x8(%ebp),%eax
80105162:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105169:	5d                   	pop    %ebp
8010516a:	c3                   	ret    

8010516b <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010516b:	55                   	push   %ebp
8010516c:	89 e5                	mov    %esp,%ebp
8010516e:	53                   	push   %ebx
8010516f:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105172:	e8 53 01 00 00       	call   801052ca <pushcli>
  if(holding(lk))
80105177:	8b 45 08             	mov    0x8(%ebp),%eax
8010517a:	89 04 24             	mov    %eax,(%esp)
8010517d:	e8 17 01 00 00       	call   80105299 <holding>
80105182:	85 c0                	test   %eax,%eax
80105184:	74 0c                	je     80105192 <acquire+0x27>
    panic("acquire");
80105186:	c7 04 24 78 8c 10 80 	movl   $0x80108c78,(%esp)
8010518d:	e8 c2 b3 ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105192:	90                   	nop
80105193:	8b 45 08             	mov    0x8(%ebp),%eax
80105196:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010519d:	00 
8010519e:	89 04 24             	mov    %eax,(%esp)
801051a1:	e8 8a ff ff ff       	call   80105130 <xchg>
801051a6:	85 c0                	test   %eax,%eax
801051a8:	75 e9                	jne    80105193 <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801051aa:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801051af:	8b 5d 08             	mov    0x8(%ebp),%ebx
801051b2:	e8 e4 ef ff ff       	call   8010419b <mycpu>
801051b7:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801051ba:	8b 45 08             	mov    0x8(%ebp),%eax
801051bd:	83 c0 0c             	add    $0xc,%eax
801051c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801051c4:	8d 45 08             	lea    0x8(%ebp),%eax
801051c7:	89 04 24             	mov    %eax,(%esp)
801051ca:	e8 53 00 00 00       	call   80105222 <getcallerpcs>
}
801051cf:	83 c4 14             	add    $0x14,%esp
801051d2:	5b                   	pop    %ebx
801051d3:	5d                   	pop    %ebp
801051d4:	c3                   	ret    

801051d5 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801051d5:	55                   	push   %ebp
801051d6:	89 e5                	mov    %esp,%ebp
801051d8:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
801051db:	8b 45 08             	mov    0x8(%ebp),%eax
801051de:	89 04 24             	mov    %eax,(%esp)
801051e1:	e8 b3 00 00 00       	call   80105299 <holding>
801051e6:	85 c0                	test   %eax,%eax
801051e8:	75 0c                	jne    801051f6 <release+0x21>
    panic("release");
801051ea:	c7 04 24 80 8c 10 80 	movl   $0x80108c80,(%esp)
801051f1:	e8 5e b3 ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
801051f6:	8b 45 08             	mov    0x8(%ebp),%eax
801051f9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105200:	8b 45 08             	mov    0x8(%ebp),%eax
80105203:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
8010520a:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
8010520f:	8b 45 08             	mov    0x8(%ebp),%eax
80105212:	8b 55 08             	mov    0x8(%ebp),%edx
80105215:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
8010521b:	e8 f4 00 00 00       	call   80105314 <popcli>
}
80105220:	c9                   	leave  
80105221:	c3                   	ret    

80105222 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105222:	55                   	push   %ebp
80105223:	89 e5                	mov    %esp,%ebp
80105225:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105228:	8b 45 08             	mov    0x8(%ebp),%eax
8010522b:	83 e8 08             	sub    $0x8,%eax
8010522e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105231:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105238:	eb 37                	jmp    80105271 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010523a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010523e:	74 37                	je     80105277 <getcallerpcs+0x55>
80105240:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105247:	76 2e                	jbe    80105277 <getcallerpcs+0x55>
80105249:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010524d:	74 28                	je     80105277 <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010524f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105252:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105259:	8b 45 0c             	mov    0xc(%ebp),%eax
8010525c:	01 c2                	add    %eax,%edx
8010525e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105261:	8b 40 04             	mov    0x4(%eax),%eax
80105264:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105266:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105269:	8b 00                	mov    (%eax),%eax
8010526b:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010526e:	ff 45 f8             	incl   -0x8(%ebp)
80105271:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105275:	7e c3                	jle    8010523a <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105277:	eb 18                	jmp    80105291 <getcallerpcs+0x6f>
    pcs[i] = 0;
80105279:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010527c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105283:	8b 45 0c             	mov    0xc(%ebp),%eax
80105286:	01 d0                	add    %edx,%eax
80105288:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010528e:	ff 45 f8             	incl   -0x8(%ebp)
80105291:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105295:	7e e2                	jle    80105279 <getcallerpcs+0x57>
    pcs[i] = 0;
}
80105297:	c9                   	leave  
80105298:	c3                   	ret    

80105299 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105299:	55                   	push   %ebp
8010529a:	89 e5                	mov    %esp,%ebp
8010529c:	53                   	push   %ebx
8010529d:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801052a0:	8b 45 08             	mov    0x8(%ebp),%eax
801052a3:	8b 00                	mov    (%eax),%eax
801052a5:	85 c0                	test   %eax,%eax
801052a7:	74 16                	je     801052bf <holding+0x26>
801052a9:	8b 45 08             	mov    0x8(%ebp),%eax
801052ac:	8b 58 08             	mov    0x8(%eax),%ebx
801052af:	e8 e7 ee ff ff       	call   8010419b <mycpu>
801052b4:	39 c3                	cmp    %eax,%ebx
801052b6:	75 07                	jne    801052bf <holding+0x26>
801052b8:	b8 01 00 00 00       	mov    $0x1,%eax
801052bd:	eb 05                	jmp    801052c4 <holding+0x2b>
801052bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
801052c4:	83 c4 04             	add    $0x4,%esp
801052c7:	5b                   	pop    %ebx
801052c8:	5d                   	pop    %ebp
801052c9:	c3                   	ret    

801052ca <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801052ca:	55                   	push   %ebp
801052cb:	89 e5                	mov    %esp,%ebp
801052cd:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801052d0:	e8 3f fe ff ff       	call   80105114 <readeflags>
801052d5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801052d8:	e8 47 fe ff ff       	call   80105124 <cli>
  if(mycpu()->ncli == 0)
801052dd:	e8 b9 ee ff ff       	call   8010419b <mycpu>
801052e2:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801052e8:	85 c0                	test   %eax,%eax
801052ea:	75 14                	jne    80105300 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801052ec:	e8 aa ee ff ff       	call   8010419b <mycpu>
801052f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052f4:	81 e2 00 02 00 00    	and    $0x200,%edx
801052fa:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105300:	e8 96 ee ff ff       	call   8010419b <mycpu>
80105305:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010530b:	42                   	inc    %edx
8010530c:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105312:	c9                   	leave  
80105313:	c3                   	ret    

80105314 <popcli>:

void
popcli(void)
{
80105314:	55                   	push   %ebp
80105315:	89 e5                	mov    %esp,%ebp
80105317:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010531a:	e8 f5 fd ff ff       	call   80105114 <readeflags>
8010531f:	25 00 02 00 00       	and    $0x200,%eax
80105324:	85 c0                	test   %eax,%eax
80105326:	74 0c                	je     80105334 <popcli+0x20>
    panic("popcli - interruptible");
80105328:	c7 04 24 88 8c 10 80 	movl   $0x80108c88,(%esp)
8010532f:	e8 20 b2 ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
80105334:	e8 62 ee ff ff       	call   8010419b <mycpu>
80105339:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
8010533f:	4a                   	dec    %edx
80105340:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105346:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010534c:	85 c0                	test   %eax,%eax
8010534e:	79 0c                	jns    8010535c <popcli+0x48>
    panic("popcli");
80105350:	c7 04 24 9f 8c 10 80 	movl   $0x80108c9f,(%esp)
80105357:	e8 f8 b1 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010535c:	e8 3a ee ff ff       	call   8010419b <mycpu>
80105361:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105367:	85 c0                	test   %eax,%eax
80105369:	75 14                	jne    8010537f <popcli+0x6b>
8010536b:	e8 2b ee ff ff       	call   8010419b <mycpu>
80105370:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105376:	85 c0                	test   %eax,%eax
80105378:	74 05                	je     8010537f <popcli+0x6b>
    sti();
8010537a:	e8 ab fd ff ff       	call   8010512a <sti>
}
8010537f:	c9                   	leave  
80105380:	c3                   	ret    
80105381:	00 00                	add    %al,(%eax)
	...

80105384 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105384:	55                   	push   %ebp
80105385:	89 e5                	mov    %esp,%ebp
80105387:	57                   	push   %edi
80105388:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105389:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010538c:	8b 55 10             	mov    0x10(%ebp),%edx
8010538f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105392:	89 cb                	mov    %ecx,%ebx
80105394:	89 df                	mov    %ebx,%edi
80105396:	89 d1                	mov    %edx,%ecx
80105398:	fc                   	cld    
80105399:	f3 aa                	rep stos %al,%es:(%edi)
8010539b:	89 ca                	mov    %ecx,%edx
8010539d:	89 fb                	mov    %edi,%ebx
8010539f:	89 5d 08             	mov    %ebx,0x8(%ebp)
801053a2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801053a5:	5b                   	pop    %ebx
801053a6:	5f                   	pop    %edi
801053a7:	5d                   	pop    %ebp
801053a8:	c3                   	ret    

801053a9 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801053a9:	55                   	push   %ebp
801053aa:	89 e5                	mov    %esp,%ebp
801053ac:	57                   	push   %edi
801053ad:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801053ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053b1:	8b 55 10             	mov    0x10(%ebp),%edx
801053b4:	8b 45 0c             	mov    0xc(%ebp),%eax
801053b7:	89 cb                	mov    %ecx,%ebx
801053b9:	89 df                	mov    %ebx,%edi
801053bb:	89 d1                	mov    %edx,%ecx
801053bd:	fc                   	cld    
801053be:	f3 ab                	rep stos %eax,%es:(%edi)
801053c0:	89 ca                	mov    %ecx,%edx
801053c2:	89 fb                	mov    %edi,%ebx
801053c4:	89 5d 08             	mov    %ebx,0x8(%ebp)
801053c7:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801053ca:	5b                   	pop    %ebx
801053cb:	5f                   	pop    %edi
801053cc:	5d                   	pop    %ebp
801053cd:	c3                   	ret    

801053ce <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801053ce:	55                   	push   %ebp
801053cf:	89 e5                	mov    %esp,%ebp
801053d1:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801053d4:	8b 45 08             	mov    0x8(%ebp),%eax
801053d7:	83 e0 03             	and    $0x3,%eax
801053da:	85 c0                	test   %eax,%eax
801053dc:	75 49                	jne    80105427 <memset+0x59>
801053de:	8b 45 10             	mov    0x10(%ebp),%eax
801053e1:	83 e0 03             	and    $0x3,%eax
801053e4:	85 c0                	test   %eax,%eax
801053e6:	75 3f                	jne    80105427 <memset+0x59>
    c &= 0xFF;
801053e8:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801053ef:	8b 45 10             	mov    0x10(%ebp),%eax
801053f2:	c1 e8 02             	shr    $0x2,%eax
801053f5:	89 c2                	mov    %eax,%edx
801053f7:	8b 45 0c             	mov    0xc(%ebp),%eax
801053fa:	c1 e0 18             	shl    $0x18,%eax
801053fd:	89 c1                	mov    %eax,%ecx
801053ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80105402:	c1 e0 10             	shl    $0x10,%eax
80105405:	09 c1                	or     %eax,%ecx
80105407:	8b 45 0c             	mov    0xc(%ebp),%eax
8010540a:	c1 e0 08             	shl    $0x8,%eax
8010540d:	09 c8                	or     %ecx,%eax
8010540f:	0b 45 0c             	or     0xc(%ebp),%eax
80105412:	89 54 24 08          	mov    %edx,0x8(%esp)
80105416:	89 44 24 04          	mov    %eax,0x4(%esp)
8010541a:	8b 45 08             	mov    0x8(%ebp),%eax
8010541d:	89 04 24             	mov    %eax,(%esp)
80105420:	e8 84 ff ff ff       	call   801053a9 <stosl>
80105425:	eb 19                	jmp    80105440 <memset+0x72>
  } else
    stosb(dst, c, n);
80105427:	8b 45 10             	mov    0x10(%ebp),%eax
8010542a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010542e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105431:	89 44 24 04          	mov    %eax,0x4(%esp)
80105435:	8b 45 08             	mov    0x8(%ebp),%eax
80105438:	89 04 24             	mov    %eax,(%esp)
8010543b:	e8 44 ff ff ff       	call   80105384 <stosb>
  return dst;
80105440:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105443:	c9                   	leave  
80105444:	c3                   	ret    

80105445 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105445:	55                   	push   %ebp
80105446:	89 e5                	mov    %esp,%ebp
80105448:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
8010544b:	8b 45 08             	mov    0x8(%ebp),%eax
8010544e:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105451:	8b 45 0c             	mov    0xc(%ebp),%eax
80105454:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105457:	eb 2a                	jmp    80105483 <memcmp+0x3e>
    if(*s1 != *s2)
80105459:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010545c:	8a 10                	mov    (%eax),%dl
8010545e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105461:	8a 00                	mov    (%eax),%al
80105463:	38 c2                	cmp    %al,%dl
80105465:	74 16                	je     8010547d <memcmp+0x38>
      return *s1 - *s2;
80105467:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010546a:	8a 00                	mov    (%eax),%al
8010546c:	0f b6 d0             	movzbl %al,%edx
8010546f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105472:	8a 00                	mov    (%eax),%al
80105474:	0f b6 c0             	movzbl %al,%eax
80105477:	29 c2                	sub    %eax,%edx
80105479:	89 d0                	mov    %edx,%eax
8010547b:	eb 18                	jmp    80105495 <memcmp+0x50>
    s1++, s2++;
8010547d:	ff 45 fc             	incl   -0x4(%ebp)
80105480:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105483:	8b 45 10             	mov    0x10(%ebp),%eax
80105486:	8d 50 ff             	lea    -0x1(%eax),%edx
80105489:	89 55 10             	mov    %edx,0x10(%ebp)
8010548c:	85 c0                	test   %eax,%eax
8010548e:	75 c9                	jne    80105459 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105490:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105495:	c9                   	leave  
80105496:	c3                   	ret    

80105497 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105497:	55                   	push   %ebp
80105498:	89 e5                	mov    %esp,%ebp
8010549a:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
8010549d:	8b 45 0c             	mov    0xc(%ebp),%eax
801054a0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801054a3:	8b 45 08             	mov    0x8(%ebp),%eax
801054a6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801054a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054ac:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054af:	73 3a                	jae    801054eb <memmove+0x54>
801054b1:	8b 45 10             	mov    0x10(%ebp),%eax
801054b4:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054b7:	01 d0                	add    %edx,%eax
801054b9:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054bc:	76 2d                	jbe    801054eb <memmove+0x54>
    s += n;
801054be:	8b 45 10             	mov    0x10(%ebp),%eax
801054c1:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801054c4:	8b 45 10             	mov    0x10(%ebp),%eax
801054c7:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801054ca:	eb 10                	jmp    801054dc <memmove+0x45>
      *--d = *--s;
801054cc:	ff 4d f8             	decl   -0x8(%ebp)
801054cf:	ff 4d fc             	decl   -0x4(%ebp)
801054d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054d5:	8a 10                	mov    (%eax),%dl
801054d7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054da:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801054dc:	8b 45 10             	mov    0x10(%ebp),%eax
801054df:	8d 50 ff             	lea    -0x1(%eax),%edx
801054e2:	89 55 10             	mov    %edx,0x10(%ebp)
801054e5:	85 c0                	test   %eax,%eax
801054e7:	75 e3                	jne    801054cc <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801054e9:	eb 25                	jmp    80105510 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801054eb:	eb 16                	jmp    80105503 <memmove+0x6c>
      *d++ = *s++;
801054ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054f0:	8d 50 01             	lea    0x1(%eax),%edx
801054f3:	89 55 f8             	mov    %edx,-0x8(%ebp)
801054f6:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054f9:	8d 4a 01             	lea    0x1(%edx),%ecx
801054fc:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801054ff:	8a 12                	mov    (%edx),%dl
80105501:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105503:	8b 45 10             	mov    0x10(%ebp),%eax
80105506:	8d 50 ff             	lea    -0x1(%eax),%edx
80105509:	89 55 10             	mov    %edx,0x10(%ebp)
8010550c:	85 c0                	test   %eax,%eax
8010550e:	75 dd                	jne    801054ed <memmove+0x56>
      *d++ = *s++;

  return dst;
80105510:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105513:	c9                   	leave  
80105514:	c3                   	ret    

80105515 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105515:	55                   	push   %ebp
80105516:	89 e5                	mov    %esp,%ebp
80105518:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010551b:	8b 45 10             	mov    0x10(%ebp),%eax
8010551e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105522:	8b 45 0c             	mov    0xc(%ebp),%eax
80105525:	89 44 24 04          	mov    %eax,0x4(%esp)
80105529:	8b 45 08             	mov    0x8(%ebp),%eax
8010552c:	89 04 24             	mov    %eax,(%esp)
8010552f:	e8 63 ff ff ff       	call   80105497 <memmove>
}
80105534:	c9                   	leave  
80105535:	c3                   	ret    

80105536 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105536:	55                   	push   %ebp
80105537:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105539:	eb 09                	jmp    80105544 <strncmp+0xe>
    n--, p++, q++;
8010553b:	ff 4d 10             	decl   0x10(%ebp)
8010553e:	ff 45 08             	incl   0x8(%ebp)
80105541:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105544:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105548:	74 17                	je     80105561 <strncmp+0x2b>
8010554a:	8b 45 08             	mov    0x8(%ebp),%eax
8010554d:	8a 00                	mov    (%eax),%al
8010554f:	84 c0                	test   %al,%al
80105551:	74 0e                	je     80105561 <strncmp+0x2b>
80105553:	8b 45 08             	mov    0x8(%ebp),%eax
80105556:	8a 10                	mov    (%eax),%dl
80105558:	8b 45 0c             	mov    0xc(%ebp),%eax
8010555b:	8a 00                	mov    (%eax),%al
8010555d:	38 c2                	cmp    %al,%dl
8010555f:	74 da                	je     8010553b <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105561:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105565:	75 07                	jne    8010556e <strncmp+0x38>
    return 0;
80105567:	b8 00 00 00 00       	mov    $0x0,%eax
8010556c:	eb 14                	jmp    80105582 <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
8010556e:	8b 45 08             	mov    0x8(%ebp),%eax
80105571:	8a 00                	mov    (%eax),%al
80105573:	0f b6 d0             	movzbl %al,%edx
80105576:	8b 45 0c             	mov    0xc(%ebp),%eax
80105579:	8a 00                	mov    (%eax),%al
8010557b:	0f b6 c0             	movzbl %al,%eax
8010557e:	29 c2                	sub    %eax,%edx
80105580:	89 d0                	mov    %edx,%eax
}
80105582:	5d                   	pop    %ebp
80105583:	c3                   	ret    

80105584 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105584:	55                   	push   %ebp
80105585:	89 e5                	mov    %esp,%ebp
80105587:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010558a:	8b 45 08             	mov    0x8(%ebp),%eax
8010558d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105590:	90                   	nop
80105591:	8b 45 10             	mov    0x10(%ebp),%eax
80105594:	8d 50 ff             	lea    -0x1(%eax),%edx
80105597:	89 55 10             	mov    %edx,0x10(%ebp)
8010559a:	85 c0                	test   %eax,%eax
8010559c:	7e 1c                	jle    801055ba <strncpy+0x36>
8010559e:	8b 45 08             	mov    0x8(%ebp),%eax
801055a1:	8d 50 01             	lea    0x1(%eax),%edx
801055a4:	89 55 08             	mov    %edx,0x8(%ebp)
801055a7:	8b 55 0c             	mov    0xc(%ebp),%edx
801055aa:	8d 4a 01             	lea    0x1(%edx),%ecx
801055ad:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801055b0:	8a 12                	mov    (%edx),%dl
801055b2:	88 10                	mov    %dl,(%eax)
801055b4:	8a 00                	mov    (%eax),%al
801055b6:	84 c0                	test   %al,%al
801055b8:	75 d7                	jne    80105591 <strncpy+0xd>
    ;
  while(n-- > 0)
801055ba:	eb 0c                	jmp    801055c8 <strncpy+0x44>
    *s++ = 0;
801055bc:	8b 45 08             	mov    0x8(%ebp),%eax
801055bf:	8d 50 01             	lea    0x1(%eax),%edx
801055c2:	89 55 08             	mov    %edx,0x8(%ebp)
801055c5:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801055c8:	8b 45 10             	mov    0x10(%ebp),%eax
801055cb:	8d 50 ff             	lea    -0x1(%eax),%edx
801055ce:	89 55 10             	mov    %edx,0x10(%ebp)
801055d1:	85 c0                	test   %eax,%eax
801055d3:	7f e7                	jg     801055bc <strncpy+0x38>
    *s++ = 0;
  return os;
801055d5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801055d8:	c9                   	leave  
801055d9:	c3                   	ret    

801055da <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801055da:	55                   	push   %ebp
801055db:	89 e5                	mov    %esp,%ebp
801055dd:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801055e0:	8b 45 08             	mov    0x8(%ebp),%eax
801055e3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801055e6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055ea:	7f 05                	jg     801055f1 <safestrcpy+0x17>
    return os;
801055ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055ef:	eb 2e                	jmp    8010561f <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
801055f1:	ff 4d 10             	decl   0x10(%ebp)
801055f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801055f8:	7e 1c                	jle    80105616 <safestrcpy+0x3c>
801055fa:	8b 45 08             	mov    0x8(%ebp),%eax
801055fd:	8d 50 01             	lea    0x1(%eax),%edx
80105600:	89 55 08             	mov    %edx,0x8(%ebp)
80105603:	8b 55 0c             	mov    0xc(%ebp),%edx
80105606:	8d 4a 01             	lea    0x1(%edx),%ecx
80105609:	89 4d 0c             	mov    %ecx,0xc(%ebp)
8010560c:	8a 12                	mov    (%edx),%dl
8010560e:	88 10                	mov    %dl,(%eax)
80105610:	8a 00                	mov    (%eax),%al
80105612:	84 c0                	test   %al,%al
80105614:	75 db                	jne    801055f1 <safestrcpy+0x17>
    ;
  *s = 0;
80105616:	8b 45 08             	mov    0x8(%ebp),%eax
80105619:	c6 00 00             	movb   $0x0,(%eax)
  return os;
8010561c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010561f:	c9                   	leave  
80105620:	c3                   	ret    

80105621 <strlen>:

int
strlen(const char *s)
{
80105621:	55                   	push   %ebp
80105622:	89 e5                	mov    %esp,%ebp
80105624:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105627:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010562e:	eb 03                	jmp    80105633 <strlen+0x12>
80105630:	ff 45 fc             	incl   -0x4(%ebp)
80105633:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105636:	8b 45 08             	mov    0x8(%ebp),%eax
80105639:	01 d0                	add    %edx,%eax
8010563b:	8a 00                	mov    (%eax),%al
8010563d:	84 c0                	test   %al,%al
8010563f:	75 ef                	jne    80105630 <strlen+0xf>
    ;
  return n;
80105641:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105644:	c9                   	leave  
80105645:	c3                   	ret    
	...

80105648 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105648:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
8010564c:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105650:	55                   	push   %ebp
  pushl %ebx
80105651:	53                   	push   %ebx
  pushl %esi
80105652:	56                   	push   %esi
  pushl %edi
80105653:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105654:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105656:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105658:	5f                   	pop    %edi
  popl %esi
80105659:	5e                   	pop    %esi
  popl %ebx
8010565a:	5b                   	pop    %ebx
  popl %ebp
8010565b:	5d                   	pop    %ebp
  ret
8010565c:	c3                   	ret    
8010565d:	00 00                	add    %al,(%eax)
	...

80105660 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105660:	55                   	push   %ebp
80105661:	89 e5                	mov    %esp,%ebp
80105663:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105666:	e8 b4 eb ff ff       	call   8010421f <myproc>
8010566b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
8010566e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105671:	8b 00                	mov    (%eax),%eax
80105673:	3b 45 08             	cmp    0x8(%ebp),%eax
80105676:	76 0f                	jbe    80105687 <fetchint+0x27>
80105678:	8b 45 08             	mov    0x8(%ebp),%eax
8010567b:	8d 50 04             	lea    0x4(%eax),%edx
8010567e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105681:	8b 00                	mov    (%eax),%eax
80105683:	39 c2                	cmp    %eax,%edx
80105685:	76 07                	jbe    8010568e <fetchint+0x2e>
    return -1;
80105687:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010568c:	eb 0f                	jmp    8010569d <fetchint+0x3d>
  *ip = *(int*)(addr);
8010568e:	8b 45 08             	mov    0x8(%ebp),%eax
80105691:	8b 10                	mov    (%eax),%edx
80105693:	8b 45 0c             	mov    0xc(%ebp),%eax
80105696:	89 10                	mov    %edx,(%eax)
  return 0;
80105698:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010569d:	c9                   	leave  
8010569e:	c3                   	ret    

8010569f <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
8010569f:	55                   	push   %ebp
801056a0:	89 e5                	mov    %esp,%ebp
801056a2:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
801056a5:	e8 75 eb ff ff       	call   8010421f <myproc>
801056aa:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801056ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056b0:	8b 00                	mov    (%eax),%eax
801056b2:	3b 45 08             	cmp    0x8(%ebp),%eax
801056b5:	77 07                	ja     801056be <fetchstr+0x1f>
    return -1;
801056b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056bc:	eb 41                	jmp    801056ff <fetchstr+0x60>
  *pp = (char*)addr;
801056be:	8b 55 08             	mov    0x8(%ebp),%edx
801056c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801056c4:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801056c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056c9:	8b 00                	mov    (%eax),%eax
801056cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801056ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801056d1:	8b 00                	mov    (%eax),%eax
801056d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056d6:	eb 1a                	jmp    801056f2 <fetchstr+0x53>
    if(*s == 0)
801056d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056db:	8a 00                	mov    (%eax),%al
801056dd:	84 c0                	test   %al,%al
801056df:	75 0e                	jne    801056ef <fetchstr+0x50>
      return s - *pp;
801056e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801056e7:	8b 00                	mov    (%eax),%eax
801056e9:	29 c2                	sub    %eax,%edx
801056eb:	89 d0                	mov    %edx,%eax
801056ed:	eb 10                	jmp    801056ff <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
801056ef:	ff 45 f4             	incl   -0xc(%ebp)
801056f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056f5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801056f8:	72 de                	jb     801056d8 <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
801056fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801056ff:	c9                   	leave  
80105700:	c3                   	ret    

80105701 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105701:	55                   	push   %ebp
80105702:	89 e5                	mov    %esp,%ebp
80105704:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105707:	e8 13 eb ff ff       	call   8010421f <myproc>
8010570c:	8b 40 18             	mov    0x18(%eax),%eax
8010570f:	8b 50 44             	mov    0x44(%eax),%edx
80105712:	8b 45 08             	mov    0x8(%ebp),%eax
80105715:	c1 e0 02             	shl    $0x2,%eax
80105718:	01 d0                	add    %edx,%eax
8010571a:	8d 50 04             	lea    0x4(%eax),%edx
8010571d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105720:	89 44 24 04          	mov    %eax,0x4(%esp)
80105724:	89 14 24             	mov    %edx,(%esp)
80105727:	e8 34 ff ff ff       	call   80105660 <fetchint>
}
8010572c:	c9                   	leave  
8010572d:	c3                   	ret    

8010572e <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010572e:	55                   	push   %ebp
8010572f:	89 e5                	mov    %esp,%ebp
80105731:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
80105734:	e8 e6 ea ff ff       	call   8010421f <myproc>
80105739:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
8010573c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010573f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105743:	8b 45 08             	mov    0x8(%ebp),%eax
80105746:	89 04 24             	mov    %eax,(%esp)
80105749:	e8 b3 ff ff ff       	call   80105701 <argint>
8010574e:	85 c0                	test   %eax,%eax
80105750:	79 07                	jns    80105759 <argptr+0x2b>
    return -1;
80105752:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105757:	eb 3d                	jmp    80105796 <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105759:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010575d:	78 21                	js     80105780 <argptr+0x52>
8010575f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105762:	89 c2                	mov    %eax,%edx
80105764:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105767:	8b 00                	mov    (%eax),%eax
80105769:	39 c2                	cmp    %eax,%edx
8010576b:	73 13                	jae    80105780 <argptr+0x52>
8010576d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105770:	89 c2                	mov    %eax,%edx
80105772:	8b 45 10             	mov    0x10(%ebp),%eax
80105775:	01 c2                	add    %eax,%edx
80105777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010577a:	8b 00                	mov    (%eax),%eax
8010577c:	39 c2                	cmp    %eax,%edx
8010577e:	76 07                	jbe    80105787 <argptr+0x59>
    return -1;
80105780:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105785:	eb 0f                	jmp    80105796 <argptr+0x68>
  *pp = (char*)i;
80105787:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010578a:	89 c2                	mov    %eax,%edx
8010578c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010578f:	89 10                	mov    %edx,(%eax)
  return 0;
80105791:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105796:	c9                   	leave  
80105797:	c3                   	ret    

80105798 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105798:	55                   	push   %ebp
80105799:	89 e5                	mov    %esp,%ebp
8010579b:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010579e:	8d 45 f4             	lea    -0xc(%ebp),%eax
801057a1:	89 44 24 04          	mov    %eax,0x4(%esp)
801057a5:	8b 45 08             	mov    0x8(%ebp),%eax
801057a8:	89 04 24             	mov    %eax,(%esp)
801057ab:	e8 51 ff ff ff       	call   80105701 <argint>
801057b0:	85 c0                	test   %eax,%eax
801057b2:	79 07                	jns    801057bb <argstr+0x23>
    return -1;
801057b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057b9:	eb 12                	jmp    801057cd <argstr+0x35>
  return fetchstr(addr, pp);
801057bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057be:	8b 55 0c             	mov    0xc(%ebp),%edx
801057c1:	89 54 24 04          	mov    %edx,0x4(%esp)
801057c5:	89 04 24             	mov    %eax,(%esp)
801057c8:	e8 d2 fe ff ff       	call   8010569f <fetchstr>
}
801057cd:	c9                   	leave  
801057ce:	c3                   	ret    

801057cf <syscall>:
[SYS_cinfo] sys_cinfo,
};

void
syscall(void)
{
801057cf:	55                   	push   %ebp
801057d0:	89 e5                	mov    %esp,%ebp
801057d2:	53                   	push   %ebx
801057d3:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
801057d6:	e8 44 ea ff ff       	call   8010421f <myproc>
801057db:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
801057de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801057e1:	8b 40 18             	mov    0x18(%eax),%eax
801057e4:	8b 40 1c             	mov    0x1c(%eax),%eax
801057e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801057ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801057ee:	7e 2d                	jle    8010581d <syscall+0x4e>
801057f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057f3:	83 f8 1b             	cmp    $0x1b,%eax
801057f6:	77 25                	ja     8010581d <syscall+0x4e>
801057f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057fb:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105802:	85 c0                	test   %eax,%eax
80105804:	74 17                	je     8010581d <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105806:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105809:	8b 58 18             	mov    0x18(%eax),%ebx
8010580c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010580f:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105816:	ff d0                	call   *%eax
80105818:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010581b:	eb 34                	jmp    80105851 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
8010581d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105820:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105826:	8b 40 10             	mov    0x10(%eax),%eax
80105829:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010582c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105830:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105834:	89 44 24 04          	mov    %eax,0x4(%esp)
80105838:	c7 04 24 a6 8c 10 80 	movl   $0x80108ca6,(%esp)
8010583f:	e8 7d ab ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105844:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105847:	8b 40 18             	mov    0x18(%eax),%eax
8010584a:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105851:	83 c4 24             	add    $0x24,%esp
80105854:	5b                   	pop    %ebx
80105855:	5d                   	pop    %ebp
80105856:	c3                   	ret    
	...

80105858 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105858:	55                   	push   %ebp
80105859:	89 e5                	mov    %esp,%ebp
8010585b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010585e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105861:	89 44 24 04          	mov    %eax,0x4(%esp)
80105865:	8b 45 08             	mov    0x8(%ebp),%eax
80105868:	89 04 24             	mov    %eax,(%esp)
8010586b:	e8 91 fe ff ff       	call   80105701 <argint>
80105870:	85 c0                	test   %eax,%eax
80105872:	79 07                	jns    8010587b <argfd+0x23>
    return -1;
80105874:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105879:	eb 4f                	jmp    801058ca <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010587b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010587e:	85 c0                	test   %eax,%eax
80105880:	78 20                	js     801058a2 <argfd+0x4a>
80105882:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105885:	83 f8 0f             	cmp    $0xf,%eax
80105888:	7f 18                	jg     801058a2 <argfd+0x4a>
8010588a:	e8 90 e9 ff ff       	call   8010421f <myproc>
8010588f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105892:	83 c2 08             	add    $0x8,%edx
80105895:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105899:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010589c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058a0:	75 07                	jne    801058a9 <argfd+0x51>
    return -1;
801058a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058a7:	eb 21                	jmp    801058ca <argfd+0x72>
  if(pfd)
801058a9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801058ad:	74 08                	je     801058b7 <argfd+0x5f>
    *pfd = fd;
801058af:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801058b5:	89 10                	mov    %edx,(%eax)
  if(pf)
801058b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058bb:	74 08                	je     801058c5 <argfd+0x6d>
    *pf = f;
801058bd:	8b 45 10             	mov    0x10(%ebp),%eax
801058c0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058c3:	89 10                	mov    %edx,(%eax)
  return 0;
801058c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058ca:	c9                   	leave  
801058cb:	c3                   	ret    

801058cc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801058cc:	55                   	push   %ebp
801058cd:	89 e5                	mov    %esp,%ebp
801058cf:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801058d2:	e8 48 e9 ff ff       	call   8010421f <myproc>
801058d7:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801058da:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801058e1:	eb 29                	jmp    8010590c <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
801058e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058e9:	83 c2 08             	add    $0x8,%edx
801058ec:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801058f0:	85 c0                	test   %eax,%eax
801058f2:	75 15                	jne    80105909 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801058f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058fa:	8d 4a 08             	lea    0x8(%edx),%ecx
801058fd:	8b 55 08             	mov    0x8(%ebp),%edx
80105900:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105904:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105907:	eb 0e                	jmp    80105917 <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105909:	ff 45 f4             	incl   -0xc(%ebp)
8010590c:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105910:	7e d1                	jle    801058e3 <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105912:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105917:	c9                   	leave  
80105918:	c3                   	ret    

80105919 <sys_dup>:

int
sys_dup(void)
{
80105919:	55                   	push   %ebp
8010591a:	89 e5                	mov    %esp,%ebp
8010591c:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010591f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105922:	89 44 24 08          	mov    %eax,0x8(%esp)
80105926:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010592d:	00 
8010592e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105935:	e8 1e ff ff ff       	call   80105858 <argfd>
8010593a:	85 c0                	test   %eax,%eax
8010593c:	79 07                	jns    80105945 <sys_dup+0x2c>
    return -1;
8010593e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105943:	eb 29                	jmp    8010596e <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105945:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105948:	89 04 24             	mov    %eax,(%esp)
8010594b:	e8 7c ff ff ff       	call   801058cc <fdalloc>
80105950:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105953:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105957:	79 07                	jns    80105960 <sys_dup+0x47>
    return -1;
80105959:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010595e:	eb 0e                	jmp    8010596e <sys_dup+0x55>
  filedup(f);
80105960:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105963:	89 04 24             	mov    %eax,(%esp)
80105966:	e8 59 b7 ff ff       	call   801010c4 <filedup>
  return fd;
8010596b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010596e:	c9                   	leave  
8010596f:	c3                   	ret    

80105970 <sys_read>:

int
sys_read(void)
{
80105970:	55                   	push   %ebp
80105971:	89 e5                	mov    %esp,%ebp
80105973:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105976:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105979:	89 44 24 08          	mov    %eax,0x8(%esp)
8010597d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105984:	00 
80105985:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010598c:	e8 c7 fe ff ff       	call   80105858 <argfd>
80105991:	85 c0                	test   %eax,%eax
80105993:	78 35                	js     801059ca <sys_read+0x5a>
80105995:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105998:	89 44 24 04          	mov    %eax,0x4(%esp)
8010599c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801059a3:	e8 59 fd ff ff       	call   80105701 <argint>
801059a8:	85 c0                	test   %eax,%eax
801059aa:	78 1e                	js     801059ca <sys_read+0x5a>
801059ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059af:	89 44 24 08          	mov    %eax,0x8(%esp)
801059b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801059ba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801059c1:	e8 68 fd ff ff       	call   8010572e <argptr>
801059c6:	85 c0                	test   %eax,%eax
801059c8:	79 07                	jns    801059d1 <sys_read+0x61>
    return -1;
801059ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059cf:	eb 19                	jmp    801059ea <sys_read+0x7a>
  return fileread(f, p, n);
801059d1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801059d4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801059d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059da:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801059de:	89 54 24 04          	mov    %edx,0x4(%esp)
801059e2:	89 04 24             	mov    %eax,(%esp)
801059e5:	e8 3b b8 ff ff       	call   80101225 <fileread>
}
801059ea:	c9                   	leave  
801059eb:	c3                   	ret    

801059ec <sys_write>:

int
sys_write(void)
{
801059ec:	55                   	push   %ebp
801059ed:	89 e5                	mov    %esp,%ebp
801059ef:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801059f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059f5:	89 44 24 08          	mov    %eax,0x8(%esp)
801059f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105a00:	00 
80105a01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a08:	e8 4b fe ff ff       	call   80105858 <argfd>
80105a0d:	85 c0                	test   %eax,%eax
80105a0f:	78 35                	js     80105a46 <sys_write+0x5a>
80105a11:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a14:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a18:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105a1f:	e8 dd fc ff ff       	call   80105701 <argint>
80105a24:	85 c0                	test   %eax,%eax
80105a26:	78 1e                	js     80105a46 <sys_write+0x5a>
80105a28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a2b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a2f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a32:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a36:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105a3d:	e8 ec fc ff ff       	call   8010572e <argptr>
80105a42:	85 c0                	test   %eax,%eax
80105a44:	79 07                	jns    80105a4d <sys_write+0x61>
    return -1;
80105a46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a4b:	eb 19                	jmp    80105a66 <sys_write+0x7a>
  return filewrite(f, p, n);
80105a4d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a50:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a56:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105a5a:	89 54 24 04          	mov    %edx,0x4(%esp)
80105a5e:	89 04 24             	mov    %eax,(%esp)
80105a61:	e8 7a b8 ff ff       	call   801012e0 <filewrite>
}
80105a66:	c9                   	leave  
80105a67:	c3                   	ret    

80105a68 <sys_close>:

int
sys_close(void)
{
80105a68:	55                   	push   %ebp
80105a69:	89 e5                	mov    %esp,%ebp
80105a6b:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105a6e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a71:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a75:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a78:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105a83:	e8 d0 fd ff ff       	call   80105858 <argfd>
80105a88:	85 c0                	test   %eax,%eax
80105a8a:	79 07                	jns    80105a93 <sys_close+0x2b>
    return -1;
80105a8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a91:	eb 23                	jmp    80105ab6 <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
80105a93:	e8 87 e7 ff ff       	call   8010421f <myproc>
80105a98:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a9b:	83 c2 08             	add    $0x8,%edx
80105a9e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105aa5:	00 
  fileclose(f);
80105aa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aa9:	89 04 24             	mov    %eax,(%esp)
80105aac:	e8 5b b6 ff ff       	call   8010110c <fileclose>
  return 0;
80105ab1:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ab6:	c9                   	leave  
80105ab7:	c3                   	ret    

80105ab8 <sys_fstat>:

int
sys_fstat(void)
{
80105ab8:	55                   	push   %ebp
80105ab9:	89 e5                	mov    %esp,%ebp
80105abb:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105abe:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ac1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ac5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105acc:	00 
80105acd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105ad4:	e8 7f fd ff ff       	call   80105858 <argfd>
80105ad9:	85 c0                	test   %eax,%eax
80105adb:	78 1f                	js     80105afc <sys_fstat+0x44>
80105add:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105ae4:	00 
80105ae5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ae8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105aec:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105af3:	e8 36 fc ff ff       	call   8010572e <argptr>
80105af8:	85 c0                	test   %eax,%eax
80105afa:	79 07                	jns    80105b03 <sys_fstat+0x4b>
    return -1;
80105afc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b01:	eb 12                	jmp    80105b15 <sys_fstat+0x5d>
  return filestat(f, st);
80105b03:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b09:	89 54 24 04          	mov    %edx,0x4(%esp)
80105b0d:	89 04 24             	mov    %eax,(%esp)
80105b10:	e8 c1 b6 ff ff       	call   801011d6 <filestat>
}
80105b15:	c9                   	leave  
80105b16:	c3                   	ret    

80105b17 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105b17:	55                   	push   %ebp
80105b18:	89 e5                	mov    %esp,%ebp
80105b1a:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105b1d:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105b20:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b24:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105b2b:	e8 68 fc ff ff       	call   80105798 <argstr>
80105b30:	85 c0                	test   %eax,%eax
80105b32:	78 17                	js     80105b4b <sys_link+0x34>
80105b34:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105b37:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b3b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105b42:	e8 51 fc ff ff       	call   80105798 <argstr>
80105b47:	85 c0                	test   %eax,%eax
80105b49:	79 0a                	jns    80105b55 <sys_link+0x3e>
    return -1;
80105b4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b50:	e9 3d 01 00 00       	jmp    80105c92 <sys_link+0x17b>

  begin_op();
80105b55:	e8 c5 d9 ff ff       	call   8010351f <begin_op>
  if((ip = namei(old)) == 0){
80105b5a:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105b5d:	89 04 24             	mov    %eax,(%esp)
80105b60:	e8 e6 c9 ff ff       	call   8010254b <namei>
80105b65:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b68:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b6c:	75 0f                	jne    80105b7d <sys_link+0x66>
    end_op();
80105b6e:	e8 2e da ff ff       	call   801035a1 <end_op>
    return -1;
80105b73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b78:	e9 15 01 00 00       	jmp    80105c92 <sys_link+0x17b>
  }

  ilock(ip);
80105b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b80:	89 04 24             	mov    %eax,(%esp)
80105b83:	e8 9e be ff ff       	call   80101a26 <ilock>
  if(ip->type == T_DIR){
80105b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b8b:	8b 40 50             	mov    0x50(%eax),%eax
80105b8e:	66 83 f8 01          	cmp    $0x1,%ax
80105b92:	75 1a                	jne    80105bae <sys_link+0x97>
    iunlockput(ip);
80105b94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b97:	89 04 24             	mov    %eax,(%esp)
80105b9a:	e8 86 c0 ff ff       	call   80101c25 <iunlockput>
    end_op();
80105b9f:	e8 fd d9 ff ff       	call   801035a1 <end_op>
    return -1;
80105ba4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ba9:	e9 e4 00 00 00       	jmp    80105c92 <sys_link+0x17b>
  }

  ip->nlink++;
80105bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bb1:	66 8b 40 56          	mov    0x56(%eax),%ax
80105bb5:	40                   	inc    %eax
80105bb6:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bb9:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc0:	89 04 24             	mov    %eax,(%esp)
80105bc3:	e8 9b bc ff ff       	call   80101863 <iupdate>
  iunlock(ip);
80105bc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bcb:	89 04 24             	mov    %eax,(%esp)
80105bce:	e8 5d bf ff ff       	call   80101b30 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105bd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105bd6:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105bd9:	89 54 24 04          	mov    %edx,0x4(%esp)
80105bdd:	89 04 24             	mov    %eax,(%esp)
80105be0:	e8 88 c9 ff ff       	call   8010256d <nameiparent>
80105be5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105be8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105bec:	75 02                	jne    80105bf0 <sys_link+0xd9>
    goto bad;
80105bee:	eb 68                	jmp    80105c58 <sys_link+0x141>
  ilock(dp);
80105bf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bf3:	89 04 24             	mov    %eax,(%esp)
80105bf6:	e8 2b be ff ff       	call   80101a26 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105bfb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bfe:	8b 10                	mov    (%eax),%edx
80105c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c03:	8b 00                	mov    (%eax),%eax
80105c05:	39 c2                	cmp    %eax,%edx
80105c07:	75 20                	jne    80105c29 <sys_link+0x112>
80105c09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c0c:	8b 40 04             	mov    0x4(%eax),%eax
80105c0f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c13:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105c16:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1d:	89 04 24             	mov    %eax,(%esp)
80105c20:	e8 73 c6 ff ff       	call   80102298 <dirlink>
80105c25:	85 c0                	test   %eax,%eax
80105c27:	79 0d                	jns    80105c36 <sys_link+0x11f>
    iunlockput(dp);
80105c29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c2c:	89 04 24             	mov    %eax,(%esp)
80105c2f:	e8 f1 bf ff ff       	call   80101c25 <iunlockput>
    goto bad;
80105c34:	eb 22                	jmp    80105c58 <sys_link+0x141>
  }
  iunlockput(dp);
80105c36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c39:	89 04 24             	mov    %eax,(%esp)
80105c3c:	e8 e4 bf ff ff       	call   80101c25 <iunlockput>
  iput(ip);
80105c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c44:	89 04 24             	mov    %eax,(%esp)
80105c47:	e8 28 bf ff ff       	call   80101b74 <iput>

  end_op();
80105c4c:	e8 50 d9 ff ff       	call   801035a1 <end_op>

  return 0;
80105c51:	b8 00 00 00 00       	mov    $0x0,%eax
80105c56:	eb 3a                	jmp    80105c92 <sys_link+0x17b>

bad:
  ilock(ip);
80105c58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c5b:	89 04 24             	mov    %eax,(%esp)
80105c5e:	e8 c3 bd ff ff       	call   80101a26 <ilock>
  ip->nlink--;
80105c63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c66:	66 8b 40 56          	mov    0x56(%eax),%ax
80105c6a:	48                   	dec    %eax
80105c6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105c6e:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c75:	89 04 24             	mov    %eax,(%esp)
80105c78:	e8 e6 bb ff ff       	call   80101863 <iupdate>
  iunlockput(ip);
80105c7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c80:	89 04 24             	mov    %eax,(%esp)
80105c83:	e8 9d bf ff ff       	call   80101c25 <iunlockput>
  end_op();
80105c88:	e8 14 d9 ff ff       	call   801035a1 <end_op>
  return -1;
80105c8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c92:	c9                   	leave  
80105c93:	c3                   	ret    

80105c94 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105c94:	55                   	push   %ebp
80105c95:	89 e5                	mov    %esp,%ebp
80105c97:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105c9a:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105ca1:	eb 4a                	jmp    80105ced <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105ca3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ca6:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105cad:	00 
80105cae:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cb2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105cb5:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cb9:	8b 45 08             	mov    0x8(%ebp),%eax
80105cbc:	89 04 24             	mov    %eax,(%esp)
80105cbf:	e8 f9 c1 ff ff       	call   80101ebd <readi>
80105cc4:	83 f8 10             	cmp    $0x10,%eax
80105cc7:	74 0c                	je     80105cd5 <isdirempty+0x41>
      panic("isdirempty: readi");
80105cc9:	c7 04 24 c4 8c 10 80 	movl   $0x80108cc4,(%esp)
80105cd0:	e8 7f a8 ff ff       	call   80100554 <panic>
    if(de.inum != 0)
80105cd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105cd8:	66 85 c0             	test   %ax,%ax
80105cdb:	74 07                	je     80105ce4 <isdirempty+0x50>
      return 0;
80105cdd:	b8 00 00 00 00       	mov    $0x0,%eax
80105ce2:	eb 1b                	jmp    80105cff <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce7:	83 c0 10             	add    $0x10,%eax
80105cea:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ced:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cf0:	8b 45 08             	mov    0x8(%ebp),%eax
80105cf3:	8b 40 58             	mov    0x58(%eax),%eax
80105cf6:	39 c2                	cmp    %eax,%edx
80105cf8:	72 a9                	jb     80105ca3 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105cfa:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105cff:	c9                   	leave  
80105d00:	c3                   	ret    

80105d01 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105d01:	55                   	push   %ebp
80105d02:	89 e5                	mov    %esp,%ebp
80105d04:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105d07:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105d0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d0e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d15:	e8 7e fa ff ff       	call   80105798 <argstr>
80105d1a:	85 c0                	test   %eax,%eax
80105d1c:	79 0a                	jns    80105d28 <sys_unlink+0x27>
    return -1;
80105d1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d23:	e9 a9 01 00 00       	jmp    80105ed1 <sys_unlink+0x1d0>

  begin_op();
80105d28:	e8 f2 d7 ff ff       	call   8010351f <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105d2d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105d30:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105d33:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d37:	89 04 24             	mov    %eax,(%esp)
80105d3a:	e8 2e c8 ff ff       	call   8010256d <nameiparent>
80105d3f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d42:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d46:	75 0f                	jne    80105d57 <sys_unlink+0x56>
    end_op();
80105d48:	e8 54 d8 ff ff       	call   801035a1 <end_op>
    return -1;
80105d4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d52:	e9 7a 01 00 00       	jmp    80105ed1 <sys_unlink+0x1d0>
  }

  ilock(dp);
80105d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d5a:	89 04 24             	mov    %eax,(%esp)
80105d5d:	e8 c4 bc ff ff       	call   80101a26 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105d62:	c7 44 24 04 d6 8c 10 	movl   $0x80108cd6,0x4(%esp)
80105d69:	80 
80105d6a:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d6d:	89 04 24             	mov    %eax,(%esp)
80105d70:	e8 3b c4 ff ff       	call   801021b0 <namecmp>
80105d75:	85 c0                	test   %eax,%eax
80105d77:	0f 84 3f 01 00 00    	je     80105ebc <sys_unlink+0x1bb>
80105d7d:	c7 44 24 04 d8 8c 10 	movl   $0x80108cd8,0x4(%esp)
80105d84:	80 
80105d85:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d88:	89 04 24             	mov    %eax,(%esp)
80105d8b:	e8 20 c4 ff ff       	call   801021b0 <namecmp>
80105d90:	85 c0                	test   %eax,%eax
80105d92:	0f 84 24 01 00 00    	je     80105ebc <sys_unlink+0x1bb>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105d98:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105d9b:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d9f:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105da2:	89 44 24 04          	mov    %eax,0x4(%esp)
80105da6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da9:	89 04 24             	mov    %eax,(%esp)
80105dac:	e8 21 c4 ff ff       	call   801021d2 <dirlookup>
80105db1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105db4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105db8:	75 05                	jne    80105dbf <sys_unlink+0xbe>
    goto bad;
80105dba:	e9 fd 00 00 00       	jmp    80105ebc <sys_unlink+0x1bb>
  ilock(ip);
80105dbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc2:	89 04 24             	mov    %eax,(%esp)
80105dc5:	e8 5c bc ff ff       	call   80101a26 <ilock>

  if(ip->nlink < 1)
80105dca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dcd:	66 8b 40 56          	mov    0x56(%eax),%ax
80105dd1:	66 85 c0             	test   %ax,%ax
80105dd4:	7f 0c                	jg     80105de2 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
80105dd6:	c7 04 24 db 8c 10 80 	movl   $0x80108cdb,(%esp)
80105ddd:	e8 72 a7 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105de2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de5:	8b 40 50             	mov    0x50(%eax),%eax
80105de8:	66 83 f8 01          	cmp    $0x1,%ax
80105dec:	75 1f                	jne    80105e0d <sys_unlink+0x10c>
80105dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105df1:	89 04 24             	mov    %eax,(%esp)
80105df4:	e8 9b fe ff ff       	call   80105c94 <isdirempty>
80105df9:	85 c0                	test   %eax,%eax
80105dfb:	75 10                	jne    80105e0d <sys_unlink+0x10c>
    iunlockput(ip);
80105dfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e00:	89 04 24             	mov    %eax,(%esp)
80105e03:	e8 1d be ff ff       	call   80101c25 <iunlockput>
    goto bad;
80105e08:	e9 af 00 00 00       	jmp    80105ebc <sys_unlink+0x1bb>
  }

  memset(&de, 0, sizeof(de));
80105e0d:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105e14:	00 
80105e15:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e1c:	00 
80105e1d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e20:	89 04 24             	mov    %eax,(%esp)
80105e23:	e8 a6 f5 ff ff       	call   801053ce <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e28:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105e2b:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105e32:	00 
80105e33:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e37:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e3a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e41:	89 04 24             	mov    %eax,(%esp)
80105e44:	e8 d8 c1 ff ff       	call   80102021 <writei>
80105e49:	83 f8 10             	cmp    $0x10,%eax
80105e4c:	74 0c                	je     80105e5a <sys_unlink+0x159>
    panic("unlink: writei");
80105e4e:	c7 04 24 ed 8c 10 80 	movl   $0x80108ced,(%esp)
80105e55:	e8 fa a6 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR){
80105e5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e5d:	8b 40 50             	mov    0x50(%eax),%eax
80105e60:	66 83 f8 01          	cmp    $0x1,%ax
80105e64:	75 1a                	jne    80105e80 <sys_unlink+0x17f>
    dp->nlink--;
80105e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e69:	66 8b 40 56          	mov    0x56(%eax),%ax
80105e6d:	48                   	dec    %eax
80105e6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e71:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105e75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e78:	89 04 24             	mov    %eax,(%esp)
80105e7b:	e8 e3 b9 ff ff       	call   80101863 <iupdate>
  }
  iunlockput(dp);
80105e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e83:	89 04 24             	mov    %eax,(%esp)
80105e86:	e8 9a bd ff ff       	call   80101c25 <iunlockput>

  ip->nlink--;
80105e8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e8e:	66 8b 40 56          	mov    0x56(%eax),%ax
80105e92:	48                   	dec    %eax
80105e93:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e96:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105e9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e9d:	89 04 24             	mov    %eax,(%esp)
80105ea0:	e8 be b9 ff ff       	call   80101863 <iupdate>
  iunlockput(ip);
80105ea5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ea8:	89 04 24             	mov    %eax,(%esp)
80105eab:	e8 75 bd ff ff       	call   80101c25 <iunlockput>

  end_op();
80105eb0:	e8 ec d6 ff ff       	call   801035a1 <end_op>

  return 0;
80105eb5:	b8 00 00 00 00       	mov    $0x0,%eax
80105eba:	eb 15                	jmp    80105ed1 <sys_unlink+0x1d0>

bad:
  iunlockput(dp);
80105ebc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ebf:	89 04 24             	mov    %eax,(%esp)
80105ec2:	e8 5e bd ff ff       	call   80101c25 <iunlockput>
  end_op();
80105ec7:	e8 d5 d6 ff ff       	call   801035a1 <end_op>
  return -1;
80105ecc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ed1:	c9                   	leave  
80105ed2:	c3                   	ret    

80105ed3 <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
80105ed3:	55                   	push   %ebp
80105ed4:	89 e5                	mov    %esp,%ebp
80105ed6:	83 ec 48             	sub    $0x48,%esp
80105ed9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105edc:	8b 55 10             	mov    0x10(%ebp),%edx
80105edf:	8b 45 14             	mov    0x14(%ebp),%eax
80105ee2:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105ee6:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105eea:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105eee:	8d 45 de             	lea    -0x22(%ebp),%eax
80105ef1:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ef5:	8b 45 08             	mov    0x8(%ebp),%eax
80105ef8:	89 04 24             	mov    %eax,(%esp)
80105efb:	e8 6d c6 ff ff       	call   8010256d <nameiparent>
80105f00:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f03:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f07:	75 0a                	jne    80105f13 <create+0x40>
    return 0;
80105f09:	b8 00 00 00 00       	mov    $0x0,%eax
80105f0e:	e9 79 01 00 00       	jmp    8010608c <create+0x1b9>
  ilock(dp);
80105f13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f16:	89 04 24             	mov    %eax,(%esp)
80105f19:	e8 08 bb ff ff       	call   80101a26 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80105f1e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f21:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f25:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f28:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f2f:	89 04 24             	mov    %eax,(%esp)
80105f32:	e8 9b c2 ff ff       	call   801021d2 <dirlookup>
80105f37:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f3a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f3e:	74 46                	je     80105f86 <create+0xb3>
    iunlockput(dp);
80105f40:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f43:	89 04 24             	mov    %eax,(%esp)
80105f46:	e8 da bc ff ff       	call   80101c25 <iunlockput>
    ilock(ip);
80105f4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f4e:	89 04 24             	mov    %eax,(%esp)
80105f51:	e8 d0 ba ff ff       	call   80101a26 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80105f56:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105f5b:	75 14                	jne    80105f71 <create+0x9e>
80105f5d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f60:	8b 40 50             	mov    0x50(%eax),%eax
80105f63:	66 83 f8 02          	cmp    $0x2,%ax
80105f67:	75 08                	jne    80105f71 <create+0x9e>
      return ip;
80105f69:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f6c:	e9 1b 01 00 00       	jmp    8010608c <create+0x1b9>
    iunlockput(ip);
80105f71:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f74:	89 04 24             	mov    %eax,(%esp)
80105f77:	e8 a9 bc ff ff       	call   80101c25 <iunlockput>
    return 0;
80105f7c:	b8 00 00 00 00       	mov    $0x0,%eax
80105f81:	e9 06 01 00 00       	jmp    8010608c <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105f86:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105f8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f8d:	8b 00                	mov    (%eax),%eax
80105f8f:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f93:	89 04 24             	mov    %eax,(%esp)
80105f96:	e8 f6 b7 ff ff       	call   80101791 <ialloc>
80105f9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f9e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fa2:	75 0c                	jne    80105fb0 <create+0xdd>
    panic("create: ialloc");
80105fa4:	c7 04 24 fc 8c 10 80 	movl   $0x80108cfc,(%esp)
80105fab:	e8 a4 a5 ff ff       	call   80100554 <panic>

  ilock(ip);
80105fb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fb3:	89 04 24             	mov    %eax,(%esp)
80105fb6:	e8 6b ba ff ff       	call   80101a26 <ilock>
  ip->major = major;
80105fbb:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105fbe:	8b 45 d0             	mov    -0x30(%ebp),%eax
80105fc1:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
80105fc5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105fc8:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105fcb:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
80105fcf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fd2:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105fd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fdb:	89 04 24             	mov    %eax,(%esp)
80105fde:	e8 80 b8 ff ff       	call   80101863 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80105fe3:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80105fe8:	75 68                	jne    80106052 <create+0x17f>
    dp->nlink++;  // for ".."
80105fea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fed:	66 8b 40 56          	mov    0x56(%eax),%ax
80105ff1:	40                   	inc    %eax
80105ff2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ff5:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80105ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ffc:	89 04 24             	mov    %eax,(%esp)
80105fff:	e8 5f b8 ff ff       	call   80101863 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80106004:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106007:	8b 40 04             	mov    0x4(%eax),%eax
8010600a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010600e:	c7 44 24 04 d6 8c 10 	movl   $0x80108cd6,0x4(%esp)
80106015:	80 
80106016:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106019:	89 04 24             	mov    %eax,(%esp)
8010601c:	e8 77 c2 ff ff       	call   80102298 <dirlink>
80106021:	85 c0                	test   %eax,%eax
80106023:	78 21                	js     80106046 <create+0x173>
80106025:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106028:	8b 40 04             	mov    0x4(%eax),%eax
8010602b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010602f:	c7 44 24 04 d8 8c 10 	movl   $0x80108cd8,0x4(%esp)
80106036:	80 
80106037:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010603a:	89 04 24             	mov    %eax,(%esp)
8010603d:	e8 56 c2 ff ff       	call   80102298 <dirlink>
80106042:	85 c0                	test   %eax,%eax
80106044:	79 0c                	jns    80106052 <create+0x17f>
      panic("create dots");
80106046:	c7 04 24 0b 8d 10 80 	movl   $0x80108d0b,(%esp)
8010604d:	e8 02 a5 ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106052:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106055:	8b 40 04             	mov    0x4(%eax),%eax
80106058:	89 44 24 08          	mov    %eax,0x8(%esp)
8010605c:	8d 45 de             	lea    -0x22(%ebp),%eax
8010605f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106063:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106066:	89 04 24             	mov    %eax,(%esp)
80106069:	e8 2a c2 ff ff       	call   80102298 <dirlink>
8010606e:	85 c0                	test   %eax,%eax
80106070:	79 0c                	jns    8010607e <create+0x1ab>
    panic("create: dirlink");
80106072:	c7 04 24 17 8d 10 80 	movl   $0x80108d17,(%esp)
80106079:	e8 d6 a4 ff ff       	call   80100554 <panic>

  iunlockput(dp);
8010607e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106081:	89 04 24             	mov    %eax,(%esp)
80106084:	e8 9c bb ff ff       	call   80101c25 <iunlockput>

  return ip;
80106089:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010608c:	c9                   	leave  
8010608d:	c3                   	ret    

8010608e <sys_open>:

int
sys_open(void)
{
8010608e:	55                   	push   %ebp
8010608f:	89 e5                	mov    %esp,%ebp
80106091:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106094:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106097:	89 44 24 04          	mov    %eax,0x4(%esp)
8010609b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060a2:	e8 f1 f6 ff ff       	call   80105798 <argstr>
801060a7:	85 c0                	test   %eax,%eax
801060a9:	78 17                	js     801060c2 <sys_open+0x34>
801060ab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801060ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801060b2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801060b9:	e8 43 f6 ff ff       	call   80105701 <argint>
801060be:	85 c0                	test   %eax,%eax
801060c0:	79 0a                	jns    801060cc <sys_open+0x3e>
    return -1;
801060c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060c7:	e9 5b 01 00 00       	jmp    80106227 <sys_open+0x199>

  begin_op();
801060cc:	e8 4e d4 ff ff       	call   8010351f <begin_op>

  if(omode & O_CREATE){
801060d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060d4:	25 00 02 00 00       	and    $0x200,%eax
801060d9:	85 c0                	test   %eax,%eax
801060db:	74 3b                	je     80106118 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
801060dd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801060e0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801060e7:	00 
801060e8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801060ef:	00 
801060f0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801060f7:	00 
801060f8:	89 04 24             	mov    %eax,(%esp)
801060fb:	e8 d3 fd ff ff       	call   80105ed3 <create>
80106100:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106103:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106107:	75 6a                	jne    80106173 <sys_open+0xe5>
      end_op();
80106109:	e8 93 d4 ff ff       	call   801035a1 <end_op>
      return -1;
8010610e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106113:	e9 0f 01 00 00       	jmp    80106227 <sys_open+0x199>
    }
  } else {
    if((ip = namei(path)) == 0){
80106118:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010611b:	89 04 24             	mov    %eax,(%esp)
8010611e:	e8 28 c4 ff ff       	call   8010254b <namei>
80106123:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106126:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010612a:	75 0f                	jne    8010613b <sys_open+0xad>
      end_op();
8010612c:	e8 70 d4 ff ff       	call   801035a1 <end_op>
      return -1;
80106131:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106136:	e9 ec 00 00 00       	jmp    80106227 <sys_open+0x199>
    }
    ilock(ip);
8010613b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010613e:	89 04 24             	mov    %eax,(%esp)
80106141:	e8 e0 b8 ff ff       	call   80101a26 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80106146:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106149:	8b 40 50             	mov    0x50(%eax),%eax
8010614c:	66 83 f8 01          	cmp    $0x1,%ax
80106150:	75 21                	jne    80106173 <sys_open+0xe5>
80106152:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106155:	85 c0                	test   %eax,%eax
80106157:	74 1a                	je     80106173 <sys_open+0xe5>
      iunlockput(ip);
80106159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010615c:	89 04 24             	mov    %eax,(%esp)
8010615f:	e8 c1 ba ff ff       	call   80101c25 <iunlockput>
      end_op();
80106164:	e8 38 d4 ff ff       	call   801035a1 <end_op>
      return -1;
80106169:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010616e:	e9 b4 00 00 00       	jmp    80106227 <sys_open+0x199>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106173:	e8 ec ae ff ff       	call   80101064 <filealloc>
80106178:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010617b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010617f:	74 14                	je     80106195 <sys_open+0x107>
80106181:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106184:	89 04 24             	mov    %eax,(%esp)
80106187:	e8 40 f7 ff ff       	call   801058cc <fdalloc>
8010618c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010618f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106193:	79 28                	jns    801061bd <sys_open+0x12f>
    if(f)
80106195:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106199:	74 0b                	je     801061a6 <sys_open+0x118>
      fileclose(f);
8010619b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010619e:	89 04 24             	mov    %eax,(%esp)
801061a1:	e8 66 af ff ff       	call   8010110c <fileclose>
    iunlockput(ip);
801061a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061a9:	89 04 24             	mov    %eax,(%esp)
801061ac:	e8 74 ba ff ff       	call   80101c25 <iunlockput>
    end_op();
801061b1:	e8 eb d3 ff ff       	call   801035a1 <end_op>
    return -1;
801061b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061bb:	eb 6a                	jmp    80106227 <sys_open+0x199>
  }
  iunlock(ip);
801061bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061c0:	89 04 24             	mov    %eax,(%esp)
801061c3:	e8 68 b9 ff ff       	call   80101b30 <iunlock>
  end_op();
801061c8:	e8 d4 d3 ff ff       	call   801035a1 <end_op>

  f->type = FD_INODE;
801061cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d0:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801061d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801061dc:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801061df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061e2:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801061e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061ec:	83 e0 01             	and    $0x1,%eax
801061ef:	85 c0                	test   %eax,%eax
801061f1:	0f 94 c0             	sete   %al
801061f4:	88 c2                	mov    %al,%dl
801061f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f9:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801061fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801061ff:	83 e0 01             	and    $0x1,%eax
80106202:	85 c0                	test   %eax,%eax
80106204:	75 0a                	jne    80106210 <sys_open+0x182>
80106206:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106209:	83 e0 02             	and    $0x2,%eax
8010620c:	85 c0                	test   %eax,%eax
8010620e:	74 07                	je     80106217 <sys_open+0x189>
80106210:	b8 01 00 00 00       	mov    $0x1,%eax
80106215:	eb 05                	jmp    8010621c <sys_open+0x18e>
80106217:	b8 00 00 00 00       	mov    $0x0,%eax
8010621c:	88 c2                	mov    %al,%dl
8010621e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106221:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106224:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106227:	c9                   	leave  
80106228:	c3                   	ret    

80106229 <sys_mkdir>:

int
sys_mkdir(void)
{
80106229:	55                   	push   %ebp
8010622a:	89 e5                	mov    %esp,%ebp
8010622c:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010622f:	e8 eb d2 ff ff       	call   8010351f <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106234:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106237:	89 44 24 04          	mov    %eax,0x4(%esp)
8010623b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106242:	e8 51 f5 ff ff       	call   80105798 <argstr>
80106247:	85 c0                	test   %eax,%eax
80106249:	78 2c                	js     80106277 <sys_mkdir+0x4e>
8010624b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010624e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106255:	00 
80106256:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010625d:	00 
8010625e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106265:	00 
80106266:	89 04 24             	mov    %eax,(%esp)
80106269:	e8 65 fc ff ff       	call   80105ed3 <create>
8010626e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106271:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106275:	75 0c                	jne    80106283 <sys_mkdir+0x5a>
    end_op();
80106277:	e8 25 d3 ff ff       	call   801035a1 <end_op>
    return -1;
8010627c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106281:	eb 15                	jmp    80106298 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106283:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106286:	89 04 24             	mov    %eax,(%esp)
80106289:	e8 97 b9 ff ff       	call   80101c25 <iunlockput>
  end_op();
8010628e:	e8 0e d3 ff ff       	call   801035a1 <end_op>
  return 0;
80106293:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106298:	c9                   	leave  
80106299:	c3                   	ret    

8010629a <sys_mknod>:

int
sys_mknod(void)
{
8010629a:	55                   	push   %ebp
8010629b:	89 e5                	mov    %esp,%ebp
8010629d:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801062a0:	e8 7a d2 ff ff       	call   8010351f <begin_op>
  if((argstr(0, &path)) < 0 ||
801062a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801062ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062b3:	e8 e0 f4 ff ff       	call   80105798 <argstr>
801062b8:	85 c0                	test   %eax,%eax
801062ba:	78 5e                	js     8010631a <sys_mknod+0x80>
     argint(1, &major) < 0 ||
801062bc:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801062c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801062ca:	e8 32 f4 ff ff       	call   80105701 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
801062cf:	85 c0                	test   %eax,%eax
801062d1:	78 47                	js     8010631a <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801062d3:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801062da:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801062e1:	e8 1b f4 ff ff       	call   80105701 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801062e6:	85 c0                	test   %eax,%eax
801062e8:	78 30                	js     8010631a <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801062ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
801062ed:	0f bf c8             	movswl %ax,%ecx
801062f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801062f3:	0f bf d0             	movswl %ax,%edx
801062f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801062f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801062fd:	89 54 24 08          	mov    %edx,0x8(%esp)
80106301:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106308:	00 
80106309:	89 04 24             	mov    %eax,(%esp)
8010630c:	e8 c2 fb ff ff       	call   80105ed3 <create>
80106311:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106314:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106318:	75 0c                	jne    80106326 <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010631a:	e8 82 d2 ff ff       	call   801035a1 <end_op>
    return -1;
8010631f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106324:	eb 15                	jmp    8010633b <sys_mknod+0xa1>
  }
  iunlockput(ip);
80106326:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106329:	89 04 24             	mov    %eax,(%esp)
8010632c:	e8 f4 b8 ff ff       	call   80101c25 <iunlockput>
  end_op();
80106331:	e8 6b d2 ff ff       	call   801035a1 <end_op>
  return 0;
80106336:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010633b:	c9                   	leave  
8010633c:	c3                   	ret    

8010633d <sys_chdir>:

int
sys_chdir(void)
{
8010633d:	55                   	push   %ebp
8010633e:	89 e5                	mov    %esp,%ebp
80106340:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106343:	e8 d7 de ff ff       	call   8010421f <myproc>
80106348:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
8010634b:	e8 cf d1 ff ff       	call   8010351f <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106350:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106353:	89 44 24 04          	mov    %eax,0x4(%esp)
80106357:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010635e:	e8 35 f4 ff ff       	call   80105798 <argstr>
80106363:	85 c0                	test   %eax,%eax
80106365:	78 14                	js     8010637b <sys_chdir+0x3e>
80106367:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010636a:	89 04 24             	mov    %eax,(%esp)
8010636d:	e8 d9 c1 ff ff       	call   8010254b <namei>
80106372:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106375:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106379:	75 0c                	jne    80106387 <sys_chdir+0x4a>
    end_op();
8010637b:	e8 21 d2 ff ff       	call   801035a1 <end_op>
    return -1;
80106380:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106385:	eb 5a                	jmp    801063e1 <sys_chdir+0xa4>
  }
  ilock(ip);
80106387:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010638a:	89 04 24             	mov    %eax,(%esp)
8010638d:	e8 94 b6 ff ff       	call   80101a26 <ilock>
  if(ip->type != T_DIR){
80106392:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106395:	8b 40 50             	mov    0x50(%eax),%eax
80106398:	66 83 f8 01          	cmp    $0x1,%ax
8010639c:	74 17                	je     801063b5 <sys_chdir+0x78>
    iunlockput(ip);
8010639e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a1:	89 04 24             	mov    %eax,(%esp)
801063a4:	e8 7c b8 ff ff       	call   80101c25 <iunlockput>
    end_op();
801063a9:	e8 f3 d1 ff ff       	call   801035a1 <end_op>
    return -1;
801063ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063b3:	eb 2c                	jmp    801063e1 <sys_chdir+0xa4>
  }
  iunlock(ip);
801063b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b8:	89 04 24             	mov    %eax,(%esp)
801063bb:	e8 70 b7 ff ff       	call   80101b30 <iunlock>
  iput(curproc->cwd);
801063c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063c3:	8b 40 68             	mov    0x68(%eax),%eax
801063c6:	89 04 24             	mov    %eax,(%esp)
801063c9:	e8 a6 b7 ff ff       	call   80101b74 <iput>
  end_op();
801063ce:	e8 ce d1 ff ff       	call   801035a1 <end_op>
  curproc->cwd = ip;
801063d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063d9:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801063dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063e1:	c9                   	leave  
801063e2:	c3                   	ret    

801063e3 <sys_exec>:

int
sys_exec(void)
{
801063e3:	55                   	push   %ebp
801063e4:	89 e5                	mov    %esp,%ebp
801063e6:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801063ec:	8d 45 f0             	lea    -0x10(%ebp),%eax
801063ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801063f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801063fa:	e8 99 f3 ff ff       	call   80105798 <argstr>
801063ff:	85 c0                	test   %eax,%eax
80106401:	78 1a                	js     8010641d <sys_exec+0x3a>
80106403:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106409:	89 44 24 04          	mov    %eax,0x4(%esp)
8010640d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106414:	e8 e8 f2 ff ff       	call   80105701 <argint>
80106419:	85 c0                	test   %eax,%eax
8010641b:	79 0a                	jns    80106427 <sys_exec+0x44>
    return -1;
8010641d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106422:	e9 c7 00 00 00       	jmp    801064ee <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
80106427:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010642e:	00 
8010642f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106436:	00 
80106437:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010643d:	89 04 24             	mov    %eax,(%esp)
80106440:	e8 89 ef ff ff       	call   801053ce <memset>
  for(i=0;; i++){
80106445:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010644c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010644f:	83 f8 1f             	cmp    $0x1f,%eax
80106452:	76 0a                	jbe    8010645e <sys_exec+0x7b>
      return -1;
80106454:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106459:	e9 90 00 00 00       	jmp    801064ee <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010645e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106461:	c1 e0 02             	shl    $0x2,%eax
80106464:	89 c2                	mov    %eax,%edx
80106466:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
8010646c:	01 c2                	add    %eax,%edx
8010646e:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106474:	89 44 24 04          	mov    %eax,0x4(%esp)
80106478:	89 14 24             	mov    %edx,(%esp)
8010647b:	e8 e0 f1 ff ff       	call   80105660 <fetchint>
80106480:	85 c0                	test   %eax,%eax
80106482:	79 07                	jns    8010648b <sys_exec+0xa8>
      return -1;
80106484:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106489:	eb 63                	jmp    801064ee <sys_exec+0x10b>
    if(uarg == 0){
8010648b:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106491:	85 c0                	test   %eax,%eax
80106493:	75 26                	jne    801064bb <sys_exec+0xd8>
      argv[i] = 0;
80106495:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106498:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
8010649f:	00 00 00 00 
      break;
801064a3:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801064a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064a7:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801064ad:	89 54 24 04          	mov    %edx,0x4(%esp)
801064b1:	89 04 24             	mov    %eax,(%esp)
801064b4:	e8 4f a7 ff ff       	call   80100c08 <exec>
801064b9:	eb 33                	jmp    801064ee <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801064bb:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801064c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064c4:	c1 e2 02             	shl    $0x2,%edx
801064c7:	01 c2                	add    %eax,%edx
801064c9:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801064cf:	89 54 24 04          	mov    %edx,0x4(%esp)
801064d3:	89 04 24             	mov    %eax,(%esp)
801064d6:	e8 c4 f1 ff ff       	call   8010569f <fetchstr>
801064db:	85 c0                	test   %eax,%eax
801064dd:	79 07                	jns    801064e6 <sys_exec+0x103>
      return -1;
801064df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064e4:	eb 08                	jmp    801064ee <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801064e6:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801064e9:	e9 5e ff ff ff       	jmp    8010644c <sys_exec+0x69>
  return exec(path, argv);
}
801064ee:	c9                   	leave  
801064ef:	c3                   	ret    

801064f0 <sys_pipe>:

int
sys_pipe(void)
{
801064f0:	55                   	push   %ebp
801064f1:	89 e5                	mov    %esp,%ebp
801064f3:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
801064f6:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
801064fd:	00 
801064fe:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106501:	89 44 24 04          	mov    %eax,0x4(%esp)
80106505:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010650c:	e8 1d f2 ff ff       	call   8010572e <argptr>
80106511:	85 c0                	test   %eax,%eax
80106513:	79 0a                	jns    8010651f <sys_pipe+0x2f>
    return -1;
80106515:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010651a:	e9 9a 00 00 00       	jmp    801065b9 <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
8010651f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106522:	89 44 24 04          	mov    %eax,0x4(%esp)
80106526:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106529:	89 04 24             	mov    %eax,(%esp)
8010652c:	e8 43 d8 ff ff       	call   80103d74 <pipealloc>
80106531:	85 c0                	test   %eax,%eax
80106533:	79 07                	jns    8010653c <sys_pipe+0x4c>
    return -1;
80106535:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010653a:	eb 7d                	jmp    801065b9 <sys_pipe+0xc9>
  fd0 = -1;
8010653c:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106543:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106546:	89 04 24             	mov    %eax,(%esp)
80106549:	e8 7e f3 ff ff       	call   801058cc <fdalloc>
8010654e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106551:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106555:	78 14                	js     8010656b <sys_pipe+0x7b>
80106557:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010655a:	89 04 24             	mov    %eax,(%esp)
8010655d:	e8 6a f3 ff ff       	call   801058cc <fdalloc>
80106562:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106565:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106569:	79 36                	jns    801065a1 <sys_pipe+0xb1>
    if(fd0 >= 0)
8010656b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010656f:	78 13                	js     80106584 <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
80106571:	e8 a9 dc ff ff       	call   8010421f <myproc>
80106576:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106579:	83 c2 08             	add    $0x8,%edx
8010657c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106583:	00 
    fileclose(rf);
80106584:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106587:	89 04 24             	mov    %eax,(%esp)
8010658a:	e8 7d ab ff ff       	call   8010110c <fileclose>
    fileclose(wf);
8010658f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106592:	89 04 24             	mov    %eax,(%esp)
80106595:	e8 72 ab ff ff       	call   8010110c <fileclose>
    return -1;
8010659a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010659f:	eb 18                	jmp    801065b9 <sys_pipe+0xc9>
  }
  fd[0] = fd0;
801065a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065a7:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801065a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065ac:	8d 50 04             	lea    0x4(%eax),%edx
801065af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065b2:	89 02                	mov    %eax,(%edx)
  return 0;
801065b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065b9:	c9                   	leave  
801065ba:	c3                   	ret    

801065bb <sys_ccreate>:

int
sys_ccreate(void)
{
801065bb:	55                   	push   %ebp
801065bc:	89 e5                	mov    %esp,%ebp
801065be:	56                   	push   %esi
801065bf:	53                   	push   %ebx
801065c0:	81 ec d0 00 00 00    	sub    $0xd0,%esp
  
  char *name, *path, *argv[MAXARG];
  int i, progc, mproc;
  uint uargv, uarg, msz, mdsk;

  if(argstr(0, &name) < 0 || argint(2, &progc) < 0 || argint(3, &mproc) < 0 
801065c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801065c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801065cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065d4:	e8 bf f1 ff ff       	call   80105798 <argstr>
801065d9:	85 c0                	test   %eax,%eax
801065db:	78 68                	js     80106645 <sys_ccreate+0x8a>
801065dd:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801065e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801065e7:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801065ee:	e8 0e f1 ff ff       	call   80105701 <argint>
801065f3:	85 c0                	test   %eax,%eax
801065f5:	78 4e                	js     80106645 <sys_ccreate+0x8a>
801065f7:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
801065fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106601:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
80106608:	e8 f4 f0 ff ff       	call   80105701 <argint>
8010660d:	85 c0                	test   %eax,%eax
8010660f:	78 34                	js     80106645 <sys_ccreate+0x8a>
    || argint(4, (int*)&msz) < 0 || argint(5, (int*)&mdsk) < 0) {
80106611:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80106617:	89 44 24 04          	mov    %eax,0x4(%esp)
8010661b:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106622:	e8 da f0 ff ff       	call   80105701 <argint>
80106627:	85 c0                	test   %eax,%eax
80106629:	78 1a                	js     80106645 <sys_ccreate+0x8a>
8010662b:	8d 85 54 ff ff ff    	lea    -0xac(%ebp),%eax
80106631:	89 44 24 04          	mov    %eax,0x4(%esp)
80106635:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
8010663c:	e8 c0 f0 ff ff       	call   80105701 <argint>
80106641:	85 c0                	test   %eax,%eax
80106643:	79 16                	jns    8010665b <sys_ccreate+0xa0>
    cprintf("sys_ccreate: Error getting pointers\n");
80106645:	c7 04 24 28 8d 10 80 	movl   $0x80108d28,(%esp)
8010664c:	e8 70 9d ff ff       	call   801003c1 <cprintf>
    return -1;
80106651:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106656:	e9 92 01 00 00       	jmp    801067ed <sys_ccreate+0x232>
  }

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010665b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010665e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106662:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106669:	e8 2a f1 ff ff       	call   80105798 <argstr>
8010666e:	85 c0                	test   %eax,%eax
80106670:	78 1a                	js     8010668c <sys_ccreate+0xd1>
80106672:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
80106678:	89 44 24 04          	mov    %eax,0x4(%esp)
8010667c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106683:	e8 79 f0 ff ff       	call   80105701 <argint>
80106688:	85 c0                	test   %eax,%eax
8010668a:	79 0a                	jns    80106696 <sys_ccreate+0xdb>
    return -1;
8010668c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106691:	e9 57 01 00 00       	jmp    801067ed <sys_ccreate+0x232>
  }
  memset(argv, 0, sizeof(argv));
80106696:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010669d:	00 
8010669e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801066a5:	00 
801066a6:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801066ac:	89 04 24             	mov    %eax,(%esp)
801066af:	e8 1a ed ff ff       	call   801053ce <memset>
  for(i=0;; i++){
801066b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801066bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066be:	83 f8 1f             	cmp    $0x1f,%eax
801066c1:	76 0a                	jbe    801066cd <sys_ccreate+0x112>
      return -1;
801066c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066c8:	e9 20 01 00 00       	jmp    801067ed <sys_ccreate+0x232>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801066cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066d0:	c1 e0 02             	shl    $0x2,%eax
801066d3:	89 c2                	mov    %eax,%edx
801066d5:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
801066db:	01 c2                	add    %eax,%edx
801066dd:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
801066e3:	89 44 24 04          	mov    %eax,0x4(%esp)
801066e7:	89 14 24             	mov    %edx,(%esp)
801066ea:	e8 71 ef ff ff       	call   80105660 <fetchint>
801066ef:	85 c0                	test   %eax,%eax
801066f1:	79 0a                	jns    801066fd <sys_ccreate+0x142>
      return -1;
801066f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066f8:	e9 f0 00 00 00       	jmp    801067ed <sys_ccreate+0x232>
    if(uarg == 0){
801066fd:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
80106703:	85 c0                	test   %eax,%eax
80106705:	75 53                	jne    8010675a <sys_ccreate+0x19f>
      argv[i] = 0;
80106707:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010670a:	c7 84 85 6c ff ff ff 	movl   $0x0,-0x94(%ebp,%eax,4)
80106711:	00 00 00 00 
      break;
80106715:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_create\nuargv: %d\nname: %s\nmproc: %d\nmsz: %d\nmdsk: %d\n", uargv, name, mproc, msz, mdsk);
80106716:	8b b5 54 ff ff ff    	mov    -0xac(%ebp),%esi
8010671c:	8b 9d 58 ff ff ff    	mov    -0xa8(%ebp),%ebx
80106722:	8b 8d 64 ff ff ff    	mov    -0x9c(%ebp),%ecx
80106728:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010672b:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80106731:	89 74 24 14          	mov    %esi,0x14(%esp)
80106735:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106739:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010673d:	89 54 24 08          	mov    %edx,0x8(%esp)
80106741:	89 44 24 04          	mov    %eax,0x4(%esp)
80106745:	c7 04 24 50 8d 10 80 	movl   $0x80108d50,(%esp)
8010674c:	e8 70 9c ff ff       	call   801003c1 <cprintf>

  for (i = 0; i < 4; i++) {
80106751:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106758:	eb 50                	jmp    801067aa <sys_ccreate+0x1ef>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010675a:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106760:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106763:	c1 e2 02             	shl    $0x2,%edx
80106766:	01 c2                	add    %eax,%edx
80106768:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
8010676e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106772:	89 04 24             	mov    %eax,(%esp)
80106775:	e8 25 ef ff ff       	call   8010569f <fetchstr>
8010677a:	85 c0                	test   %eax,%eax
8010677c:	79 07                	jns    80106785 <sys_ccreate+0x1ca>
      return -1;
8010677e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106783:	eb 68                	jmp    801067ed <sys_ccreate+0x232>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106785:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106788:	e9 2e ff ff ff       	jmp    801066bb <sys_ccreate+0x100>

  cprintf("sys_create\nuargv: %d\nname: %s\nmproc: %d\nmsz: %d\nmdsk: %d\n", uargv, name, mproc, msz, mdsk);

  for (i = 0; i < 4; i++) {
    cprintf("\t%s\n", argv[i]);
8010678d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106790:	8b 84 85 6c ff ff ff 	mov    -0x94(%ebp,%eax,4),%eax
80106797:	89 44 24 04          	mov    %eax,0x4(%esp)
8010679b:	c7 04 24 8a 8d 10 80 	movl   $0x80108d8a,(%esp)
801067a2:	e8 1a 9c ff ff       	call   801003c1 <cprintf>
      return -1;
  }

  cprintf("sys_create\nuargv: %d\nname: %s\nmproc: %d\nmsz: %d\nmdsk: %d\n", uargv, name, mproc, msz, mdsk);

  for (i = 0; i < 4; i++) {
801067a7:	ff 45 f4             	incl   -0xc(%ebp)
801067aa:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
801067ae:	7e dd                	jle    8010678d <sys_ccreate+0x1d2>
    cprintf("\t%s\n", argv[i]);
  }
  
  return ccreate(name, argv, progc, mproc, msz, mdsk);
801067b0:	8b b5 54 ff ff ff    	mov    -0xac(%ebp),%esi
801067b6:	8b 9d 58 ff ff ff    	mov    -0xa8(%ebp),%ebx
801067bc:	8b 8d 64 ff ff ff    	mov    -0x9c(%ebp),%ecx
801067c2:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
801067c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067cb:	89 74 24 14          	mov    %esi,0x14(%esp)
801067cf:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801067d3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801067d7:	89 54 24 08          	mov    %edx,0x8(%esp)
801067db:	8d 95 6c ff ff ff    	lea    -0x94(%ebp),%edx
801067e1:	89 54 24 04          	mov    %edx,0x4(%esp)
801067e5:	89 04 24             	mov    %eax,(%esp)
801067e8:	e8 d5 e6 ff ff       	call   80104ec2 <ccreate>
}
801067ed:	81 c4 d0 00 00 00    	add    $0xd0,%esp
801067f3:	5b                   	pop    %ebx
801067f4:	5e                   	pop    %esi
801067f5:	5d                   	pop    %ebp
801067f6:	c3                   	ret    

801067f7 <sys_cstart>:

int
sys_cstart(void)
{
801067f7:	55                   	push   %ebp
801067f8:	89 e5                	mov    %esp,%ebp
  return 1;
801067fa:	b8 01 00 00 00       	mov    $0x1,%eax
}
801067ff:	5d                   	pop    %ebp
80106800:	c3                   	ret    

80106801 <sys_cstop>:

int
sys_cstop(void)
{
80106801:	55                   	push   %ebp
80106802:	89 e5                	mov    %esp,%ebp
  return 1;
80106804:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106809:	5d                   	pop    %ebp
8010680a:	c3                   	ret    

8010680b <sys_cinfo>:

int
sys_cinfo(void)
{
8010680b:	55                   	push   %ebp
8010680c:	89 e5                	mov    %esp,%ebp
  return 1;
8010680e:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106813:	5d                   	pop    %ebp
80106814:	c3                   	ret    

80106815 <sys_cpause>:

int
sys_cpause(void)
{
80106815:	55                   	push   %ebp
80106816:	89 e5                	mov    %esp,%ebp
  return 1;
80106818:	b8 01 00 00 00       	mov    $0x1,%eax
8010681d:	5d                   	pop    %ebp
8010681e:	c3                   	ret    
	...

80106820 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106820:	55                   	push   %ebp
80106821:	89 e5                	mov    %esp,%ebp
80106823:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106826:	e8 21 dd ff ff       	call   8010454c <fork>
}
8010682b:	c9                   	leave  
8010682c:	c3                   	ret    

8010682d <sys_exit>:

int
sys_exit(void)
{
8010682d:	55                   	push   %ebp
8010682e:	89 e5                	mov    %esp,%ebp
80106830:	83 ec 08             	sub    $0x8,%esp
  exit();
80106833:	e8 7a de ff ff       	call   801046b2 <exit>
  return 0;  // not reached
80106838:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010683d:	c9                   	leave  
8010683e:	c3                   	ret    

8010683f <sys_wait>:

int
sys_wait(void)
{
8010683f:	55                   	push   %ebp
80106840:	89 e5                	mov    %esp,%ebp
80106842:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106845:	e8 74 df ff ff       	call   801047be <wait>
}
8010684a:	c9                   	leave  
8010684b:	c3                   	ret    

8010684c <sys_kill>:

int
sys_kill(void)
{
8010684c:	55                   	push   %ebp
8010684d:	89 e5                	mov    %esp,%ebp
8010684f:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106852:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106855:	89 44 24 04          	mov    %eax,0x4(%esp)
80106859:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106860:	e8 9c ee ff ff       	call   80105701 <argint>
80106865:	85 c0                	test   %eax,%eax
80106867:	79 07                	jns    80106870 <sys_kill+0x24>
    return -1;
80106869:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010686e:	eb 0b                	jmp    8010687b <sys_kill+0x2f>
  return kill(pid);
80106870:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106873:	89 04 24             	mov    %eax,(%esp)
80106876:	e8 21 e3 ff ff       	call   80104b9c <kill>
}
8010687b:	c9                   	leave  
8010687c:	c3                   	ret    

8010687d <sys_getpid>:

int
sys_getpid(void)
{
8010687d:	55                   	push   %ebp
8010687e:	89 e5                	mov    %esp,%ebp
80106880:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106883:	e8 97 d9 ff ff       	call   8010421f <myproc>
80106888:	8b 40 10             	mov    0x10(%eax),%eax
}
8010688b:	c9                   	leave  
8010688c:	c3                   	ret    

8010688d <sys_sbrk>:

int
sys_sbrk(void)
{
8010688d:	55                   	push   %ebp
8010688e:	89 e5                	mov    %esp,%ebp
80106890:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106893:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106896:	89 44 24 04          	mov    %eax,0x4(%esp)
8010689a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068a1:	e8 5b ee ff ff       	call   80105701 <argint>
801068a6:	85 c0                	test   %eax,%eax
801068a8:	79 07                	jns    801068b1 <sys_sbrk+0x24>
    return -1;
801068aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068af:	eb 23                	jmp    801068d4 <sys_sbrk+0x47>
  addr = myproc()->sz;
801068b1:	e8 69 d9 ff ff       	call   8010421f <myproc>
801068b6:	8b 00                	mov    (%eax),%eax
801068b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801068bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068be:	89 04 24             	mov    %eax,(%esp)
801068c1:	e8 e8 db ff ff       	call   801044ae <growproc>
801068c6:	85 c0                	test   %eax,%eax
801068c8:	79 07                	jns    801068d1 <sys_sbrk+0x44>
    return -1;
801068ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068cf:	eb 03                	jmp    801068d4 <sys_sbrk+0x47>
  return addr;
801068d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801068d4:	c9                   	leave  
801068d5:	c3                   	ret    

801068d6 <sys_sleep>:

int
sys_sleep(void)
{
801068d6:	55                   	push   %ebp
801068d7:	89 e5                	mov    %esp,%ebp
801068d9:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
801068dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068df:	89 44 24 04          	mov    %eax,0x4(%esp)
801068e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068ea:	e8 12 ee ff ff       	call   80105701 <argint>
801068ef:	85 c0                	test   %eax,%eax
801068f1:	79 07                	jns    801068fa <sys_sleep+0x24>
    return -1;
801068f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068f8:	eb 6b                	jmp    80106965 <sys_sleep+0x8f>
  acquire(&tickslock);
801068fa:	c7 04 24 00 62 11 80 	movl   $0x80116200,(%esp)
80106901:	e8 65 e8 ff ff       	call   8010516b <acquire>
  ticks0 = ticks;
80106906:	a1 40 6a 11 80       	mov    0x80116a40,%eax
8010690b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010690e:	eb 33                	jmp    80106943 <sys_sleep+0x6d>
    if(myproc()->killed){
80106910:	e8 0a d9 ff ff       	call   8010421f <myproc>
80106915:	8b 40 24             	mov    0x24(%eax),%eax
80106918:	85 c0                	test   %eax,%eax
8010691a:	74 13                	je     8010692f <sys_sleep+0x59>
      release(&tickslock);
8010691c:	c7 04 24 00 62 11 80 	movl   $0x80116200,(%esp)
80106923:	e8 ad e8 ff ff       	call   801051d5 <release>
      return -1;
80106928:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010692d:	eb 36                	jmp    80106965 <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
8010692f:	c7 44 24 04 00 62 11 	movl   $0x80116200,0x4(%esp)
80106936:	80 
80106937:	c7 04 24 40 6a 11 80 	movl   $0x80116a40,(%esp)
8010693e:	e8 57 e1 ff ff       	call   80104a9a <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106943:	a1 40 6a 11 80       	mov    0x80116a40,%eax
80106948:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010694b:	89 c2                	mov    %eax,%edx
8010694d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106950:	39 c2                	cmp    %eax,%edx
80106952:	72 bc                	jb     80106910 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106954:	c7 04 24 00 62 11 80 	movl   $0x80116200,(%esp)
8010695b:	e8 75 e8 ff ff       	call   801051d5 <release>
  return 0;
80106960:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106965:	c9                   	leave  
80106966:	c3                   	ret    

80106967 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106967:	55                   	push   %ebp
80106968:	89 e5                	mov    %esp,%ebp
8010696a:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
8010696d:	c7 04 24 00 62 11 80 	movl   $0x80116200,(%esp)
80106974:	e8 f2 e7 ff ff       	call   8010516b <acquire>
  xticks = ticks;
80106979:	a1 40 6a 11 80       	mov    0x80116a40,%eax
8010697e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106981:	c7 04 24 00 62 11 80 	movl   $0x80116200,(%esp)
80106988:	e8 48 e8 ff ff       	call   801051d5 <release>
  return xticks;
8010698d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106990:	c9                   	leave  
80106991:	c3                   	ret    

80106992 <sys_getticks>:

int
sys_getticks(void)
{
80106992:	55                   	push   %ebp
80106993:	89 e5                	mov    %esp,%ebp
80106995:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
80106998:	e8 82 d8 ff ff       	call   8010421f <myproc>
8010699d:	8b 40 7c             	mov    0x7c(%eax),%eax
}
801069a0:	c9                   	leave  
801069a1:	c3                   	ret    
	...

801069a4 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801069a4:	1e                   	push   %ds
  pushl %es
801069a5:	06                   	push   %es
  pushl %fs
801069a6:	0f a0                	push   %fs
  pushl %gs
801069a8:	0f a8                	push   %gs
  pushal
801069aa:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801069ab:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801069af:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801069b1:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801069b3:	54                   	push   %esp
  call trap
801069b4:	e8 c0 01 00 00       	call   80106b79 <trap>
  addl $4, %esp
801069b9:	83 c4 04             	add    $0x4,%esp

801069bc <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
801069bc:	61                   	popa   
  popl %gs
801069bd:	0f a9                	pop    %gs
  popl %fs
801069bf:	0f a1                	pop    %fs
  popl %es
801069c1:	07                   	pop    %es
  popl %ds
801069c2:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
801069c3:	83 c4 08             	add    $0x8,%esp
  iret
801069c6:	cf                   	iret   
	...

801069c8 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
801069c8:	55                   	push   %ebp
801069c9:	89 e5                	mov    %esp,%ebp
801069cb:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801069ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801069d1:	48                   	dec    %eax
801069d2:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801069d6:	8b 45 08             	mov    0x8(%ebp),%eax
801069d9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801069dd:	8b 45 08             	mov    0x8(%ebp),%eax
801069e0:	c1 e8 10             	shr    $0x10,%eax
801069e3:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
801069e7:	8d 45 fa             	lea    -0x6(%ebp),%eax
801069ea:	0f 01 18             	lidtl  (%eax)
}
801069ed:	c9                   	leave  
801069ee:	c3                   	ret    

801069ef <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
801069ef:	55                   	push   %ebp
801069f0:	89 e5                	mov    %esp,%ebp
801069f2:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801069f5:	0f 20 d0             	mov    %cr2,%eax
801069f8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
801069fb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801069fe:	c9                   	leave  
801069ff:	c3                   	ret    

80106a00 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106a00:	55                   	push   %ebp
80106a01:	89 e5                	mov    %esp,%ebp
80106a03:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106a06:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106a0d:	e9 b8 00 00 00       	jmp    80106aca <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106a12:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a15:	8b 04 85 b0 b0 10 80 	mov    -0x7fef4f50(,%eax,4),%eax
80106a1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106a1f:	66 89 04 d5 40 62 11 	mov    %ax,-0x7fee9dc0(,%edx,8)
80106a26:	80 
80106a27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a2a:	66 c7 04 c5 42 62 11 	movw   $0x8,-0x7fee9dbe(,%eax,8)
80106a31:	80 08 00 
80106a34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a37:	8a 14 c5 44 62 11 80 	mov    -0x7fee9dbc(,%eax,8),%dl
80106a3e:	83 e2 e0             	and    $0xffffffe0,%edx
80106a41:	88 14 c5 44 62 11 80 	mov    %dl,-0x7fee9dbc(,%eax,8)
80106a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a4b:	8a 14 c5 44 62 11 80 	mov    -0x7fee9dbc(,%eax,8),%dl
80106a52:	83 e2 1f             	and    $0x1f,%edx
80106a55:	88 14 c5 44 62 11 80 	mov    %dl,-0x7fee9dbc(,%eax,8)
80106a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a5f:	8a 14 c5 45 62 11 80 	mov    -0x7fee9dbb(,%eax,8),%dl
80106a66:	83 e2 f0             	and    $0xfffffff0,%edx
80106a69:	83 ca 0e             	or     $0xe,%edx
80106a6c:	88 14 c5 45 62 11 80 	mov    %dl,-0x7fee9dbb(,%eax,8)
80106a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a76:	8a 14 c5 45 62 11 80 	mov    -0x7fee9dbb(,%eax,8),%dl
80106a7d:	83 e2 ef             	and    $0xffffffef,%edx
80106a80:	88 14 c5 45 62 11 80 	mov    %dl,-0x7fee9dbb(,%eax,8)
80106a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a8a:	8a 14 c5 45 62 11 80 	mov    -0x7fee9dbb(,%eax,8),%dl
80106a91:	83 e2 9f             	and    $0xffffff9f,%edx
80106a94:	88 14 c5 45 62 11 80 	mov    %dl,-0x7fee9dbb(,%eax,8)
80106a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a9e:	8a 14 c5 45 62 11 80 	mov    -0x7fee9dbb(,%eax,8),%dl
80106aa5:	83 ca 80             	or     $0xffffff80,%edx
80106aa8:	88 14 c5 45 62 11 80 	mov    %dl,-0x7fee9dbb(,%eax,8)
80106aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ab2:	8b 04 85 b0 b0 10 80 	mov    -0x7fef4f50(,%eax,4),%eax
80106ab9:	c1 e8 10             	shr    $0x10,%eax
80106abc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106abf:	66 89 04 d5 46 62 11 	mov    %ax,-0x7fee9dba(,%edx,8)
80106ac6:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106ac7:	ff 45 f4             	incl   -0xc(%ebp)
80106aca:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106ad1:	0f 8e 3b ff ff ff    	jle    80106a12 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106ad7:	a1 b0 b1 10 80       	mov    0x8010b1b0,%eax
80106adc:	66 a3 40 64 11 80    	mov    %ax,0x80116440
80106ae2:	66 c7 05 42 64 11 80 	movw   $0x8,0x80116442
80106ae9:	08 00 
80106aeb:	a0 44 64 11 80       	mov    0x80116444,%al
80106af0:	83 e0 e0             	and    $0xffffffe0,%eax
80106af3:	a2 44 64 11 80       	mov    %al,0x80116444
80106af8:	a0 44 64 11 80       	mov    0x80116444,%al
80106afd:	83 e0 1f             	and    $0x1f,%eax
80106b00:	a2 44 64 11 80       	mov    %al,0x80116444
80106b05:	a0 45 64 11 80       	mov    0x80116445,%al
80106b0a:	83 c8 0f             	or     $0xf,%eax
80106b0d:	a2 45 64 11 80       	mov    %al,0x80116445
80106b12:	a0 45 64 11 80       	mov    0x80116445,%al
80106b17:	83 e0 ef             	and    $0xffffffef,%eax
80106b1a:	a2 45 64 11 80       	mov    %al,0x80116445
80106b1f:	a0 45 64 11 80       	mov    0x80116445,%al
80106b24:	83 c8 60             	or     $0x60,%eax
80106b27:	a2 45 64 11 80       	mov    %al,0x80116445
80106b2c:	a0 45 64 11 80       	mov    0x80116445,%al
80106b31:	83 c8 80             	or     $0xffffff80,%eax
80106b34:	a2 45 64 11 80       	mov    %al,0x80116445
80106b39:	a1 b0 b1 10 80       	mov    0x8010b1b0,%eax
80106b3e:	c1 e8 10             	shr    $0x10,%eax
80106b41:	66 a3 46 64 11 80    	mov    %ax,0x80116446

  initlock(&tickslock, "time");
80106b47:	c7 44 24 04 90 8d 10 	movl   $0x80108d90,0x4(%esp)
80106b4e:	80 
80106b4f:	c7 04 24 00 62 11 80 	movl   $0x80116200,(%esp)
80106b56:	e8 ef e5 ff ff       	call   8010514a <initlock>
}
80106b5b:	c9                   	leave  
80106b5c:	c3                   	ret    

80106b5d <idtinit>:

void
idtinit(void)
{
80106b5d:	55                   	push   %ebp
80106b5e:	89 e5                	mov    %esp,%ebp
80106b60:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
80106b63:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80106b6a:	00 
80106b6b:	c7 04 24 40 62 11 80 	movl   $0x80116240,(%esp)
80106b72:	e8 51 fe ff ff       	call   801069c8 <lidt>
}
80106b77:	c9                   	leave  
80106b78:	c3                   	ret    

80106b79 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106b79:	55                   	push   %ebp
80106b7a:	89 e5                	mov    %esp,%ebp
80106b7c:	57                   	push   %edi
80106b7d:	56                   	push   %esi
80106b7e:	53                   	push   %ebx
80106b7f:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
80106b82:	8b 45 08             	mov    0x8(%ebp),%eax
80106b85:	8b 40 30             	mov    0x30(%eax),%eax
80106b88:	83 f8 40             	cmp    $0x40,%eax
80106b8b:	75 3c                	jne    80106bc9 <trap+0x50>
    if(myproc()->killed)
80106b8d:	e8 8d d6 ff ff       	call   8010421f <myproc>
80106b92:	8b 40 24             	mov    0x24(%eax),%eax
80106b95:	85 c0                	test   %eax,%eax
80106b97:	74 05                	je     80106b9e <trap+0x25>
      exit();
80106b99:	e8 14 db ff ff       	call   801046b2 <exit>
    myproc()->tf = tf;
80106b9e:	e8 7c d6 ff ff       	call   8010421f <myproc>
80106ba3:	8b 55 08             	mov    0x8(%ebp),%edx
80106ba6:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106ba9:	e8 21 ec ff ff       	call   801057cf <syscall>
    if(myproc()->killed)
80106bae:	e8 6c d6 ff ff       	call   8010421f <myproc>
80106bb3:	8b 40 24             	mov    0x24(%eax),%eax
80106bb6:	85 c0                	test   %eax,%eax
80106bb8:	74 0a                	je     80106bc4 <trap+0x4b>
      exit();
80106bba:	e8 f3 da ff ff       	call   801046b2 <exit>
    return;
80106bbf:	e9 30 02 00 00       	jmp    80106df4 <trap+0x27b>
80106bc4:	e9 2b 02 00 00       	jmp    80106df4 <trap+0x27b>
  }

  switch(tf->trapno){
80106bc9:	8b 45 08             	mov    0x8(%ebp),%eax
80106bcc:	8b 40 30             	mov    0x30(%eax),%eax
80106bcf:	83 e8 20             	sub    $0x20,%eax
80106bd2:	83 f8 1f             	cmp    $0x1f,%eax
80106bd5:	0f 87 cb 00 00 00    	ja     80106ca6 <trap+0x12d>
80106bdb:	8b 04 85 38 8e 10 80 	mov    -0x7fef71c8(,%eax,4),%eax
80106be2:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80106be4:	e8 6d d5 ff ff       	call   80104156 <cpuid>
80106be9:	85 c0                	test   %eax,%eax
80106beb:	75 2f                	jne    80106c1c <trap+0xa3>
      acquire(&tickslock);
80106bed:	c7 04 24 00 62 11 80 	movl   $0x80116200,(%esp)
80106bf4:	e8 72 e5 ff ff       	call   8010516b <acquire>
      ticks++;
80106bf9:	a1 40 6a 11 80       	mov    0x80116a40,%eax
80106bfe:	40                   	inc    %eax
80106bff:	a3 40 6a 11 80       	mov    %eax,0x80116a40
      wakeup(&ticks);
80106c04:	c7 04 24 40 6a 11 80 	movl   $0x80116a40,(%esp)
80106c0b:	e8 61 df ff ff       	call   80104b71 <wakeup>
      release(&tickslock);
80106c10:	c7 04 24 00 62 11 80 	movl   $0x80116200,(%esp)
80106c17:	e8 b9 e5 ff ff       	call   801051d5 <release>
    }
    p = myproc();
80106c1c:	e8 fe d5 ff ff       	call   8010421f <myproc>
80106c21:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
80106c24:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80106c28:	74 0f                	je     80106c39 <trap+0xc0>
      p->ticks++;
80106c2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c2d:	8b 40 7c             	mov    0x7c(%eax),%eax
80106c30:	8d 50 01             	lea    0x1(%eax),%edx
80106c33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106c36:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
80106c39:	e8 b9 c3 ff ff       	call   80102ff7 <lapiceoi>
    break;
80106c3e:	e9 35 01 00 00       	jmp    80106d78 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106c43:	e8 2e bc ff ff       	call   80102876 <ideintr>
    lapiceoi();
80106c48:	e8 aa c3 ff ff       	call   80102ff7 <lapiceoi>
    break;
80106c4d:	e9 26 01 00 00       	jmp    80106d78 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106c52:	e8 b7 c1 ff ff       	call   80102e0e <kbdintr>
    lapiceoi();
80106c57:	e8 9b c3 ff ff       	call   80102ff7 <lapiceoi>
    break;
80106c5c:	e9 17 01 00 00       	jmp    80106d78 <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106c61:	e8 6f 03 00 00       	call   80106fd5 <uartintr>
    lapiceoi();
80106c66:	e8 8c c3 ff ff       	call   80102ff7 <lapiceoi>
    break;
80106c6b:	e9 08 01 00 00       	jmp    80106d78 <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c70:	8b 45 08             	mov    0x8(%ebp),%eax
80106c73:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80106c76:	8b 45 08             	mov    0x8(%ebp),%eax
80106c79:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106c7c:	0f b7 d8             	movzwl %ax,%ebx
80106c7f:	e8 d2 d4 ff ff       	call   80104156 <cpuid>
80106c84:	89 74 24 0c          	mov    %esi,0xc(%esp)
80106c88:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80106c8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c90:	c7 04 24 98 8d 10 80 	movl   $0x80108d98,(%esp)
80106c97:	e8 25 97 ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80106c9c:	e8 56 c3 ff ff       	call   80102ff7 <lapiceoi>
    break;
80106ca1:	e9 d2 00 00 00       	jmp    80106d78 <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106ca6:	e8 74 d5 ff ff       	call   8010421f <myproc>
80106cab:	85 c0                	test   %eax,%eax
80106cad:	74 10                	je     80106cbf <trap+0x146>
80106caf:	8b 45 08             	mov    0x8(%ebp),%eax
80106cb2:	8b 40 3c             	mov    0x3c(%eax),%eax
80106cb5:	0f b7 c0             	movzwl %ax,%eax
80106cb8:	83 e0 03             	and    $0x3,%eax
80106cbb:	85 c0                	test   %eax,%eax
80106cbd:	75 40                	jne    80106cff <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106cbf:	e8 2b fd ff ff       	call   801069ef <rcr2>
80106cc4:	89 c3                	mov    %eax,%ebx
80106cc6:	8b 45 08             	mov    0x8(%ebp),%eax
80106cc9:	8b 70 38             	mov    0x38(%eax),%esi
80106ccc:	e8 85 d4 ff ff       	call   80104156 <cpuid>
80106cd1:	8b 55 08             	mov    0x8(%ebp),%edx
80106cd4:	8b 52 30             	mov    0x30(%edx),%edx
80106cd7:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106cdb:	89 74 24 0c          	mov    %esi,0xc(%esp)
80106cdf:	89 44 24 08          	mov    %eax,0x8(%esp)
80106ce3:	89 54 24 04          	mov    %edx,0x4(%esp)
80106ce7:	c7 04 24 bc 8d 10 80 	movl   $0x80108dbc,(%esp)
80106cee:	e8 ce 96 ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
80106cf3:	c7 04 24 ee 8d 10 80 	movl   $0x80108dee,(%esp)
80106cfa:	e8 55 98 ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106cff:	e8 eb fc ff ff       	call   801069ef <rcr2>
80106d04:	89 c6                	mov    %eax,%esi
80106d06:	8b 45 08             	mov    0x8(%ebp),%eax
80106d09:	8b 40 38             	mov    0x38(%eax),%eax
80106d0c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106d0f:	e8 42 d4 ff ff       	call   80104156 <cpuid>
80106d14:	89 c3                	mov    %eax,%ebx
80106d16:	8b 45 08             	mov    0x8(%ebp),%eax
80106d19:	8b 78 34             	mov    0x34(%eax),%edi
80106d1c:	89 7d d0             	mov    %edi,-0x30(%ebp)
80106d1f:	8b 45 08             	mov    0x8(%ebp),%eax
80106d22:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80106d25:	e8 f5 d4 ff ff       	call   8010421f <myproc>
80106d2a:	8d 50 6c             	lea    0x6c(%eax),%edx
80106d2d:	89 55 cc             	mov    %edx,-0x34(%ebp)
80106d30:	e8 ea d4 ff ff       	call   8010421f <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106d35:	8b 40 10             	mov    0x10(%eax),%eax
80106d38:	89 74 24 1c          	mov    %esi,0x1c(%esp)
80106d3c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
80106d3f:	89 4c 24 18          	mov    %ecx,0x18(%esp)
80106d43:	89 5c 24 14          	mov    %ebx,0x14(%esp)
80106d47:	8b 4d d0             	mov    -0x30(%ebp),%ecx
80106d4a:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80106d4e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80106d52:	8b 55 cc             	mov    -0x34(%ebp),%edx
80106d55:	89 54 24 08          	mov    %edx,0x8(%esp)
80106d59:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d5d:	c7 04 24 f4 8d 10 80 	movl   $0x80108df4,(%esp)
80106d64:	e8 58 96 ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106d69:	e8 b1 d4 ff ff       	call   8010421f <myproc>
80106d6e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106d75:	eb 01                	jmp    80106d78 <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106d77:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106d78:	e8 a2 d4 ff ff       	call   8010421f <myproc>
80106d7d:	85 c0                	test   %eax,%eax
80106d7f:	74 22                	je     80106da3 <trap+0x22a>
80106d81:	e8 99 d4 ff ff       	call   8010421f <myproc>
80106d86:	8b 40 24             	mov    0x24(%eax),%eax
80106d89:	85 c0                	test   %eax,%eax
80106d8b:	74 16                	je     80106da3 <trap+0x22a>
80106d8d:	8b 45 08             	mov    0x8(%ebp),%eax
80106d90:	8b 40 3c             	mov    0x3c(%eax),%eax
80106d93:	0f b7 c0             	movzwl %ax,%eax
80106d96:	83 e0 03             	and    $0x3,%eax
80106d99:	83 f8 03             	cmp    $0x3,%eax
80106d9c:	75 05                	jne    80106da3 <trap+0x22a>
    exit();
80106d9e:	e8 0f d9 ff ff       	call   801046b2 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106da3:	e8 77 d4 ff ff       	call   8010421f <myproc>
80106da8:	85 c0                	test   %eax,%eax
80106daa:	74 1d                	je     80106dc9 <trap+0x250>
80106dac:	e8 6e d4 ff ff       	call   8010421f <myproc>
80106db1:	8b 40 0c             	mov    0xc(%eax),%eax
80106db4:	83 f8 04             	cmp    $0x4,%eax
80106db7:	75 10                	jne    80106dc9 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80106db9:	8b 45 08             	mov    0x8(%ebp),%eax
80106dbc:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106dbf:	83 f8 20             	cmp    $0x20,%eax
80106dc2:	75 05                	jne    80106dc9 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80106dc4:	e8 61 dc ff ff       	call   80104a2a <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106dc9:	e8 51 d4 ff ff       	call   8010421f <myproc>
80106dce:	85 c0                	test   %eax,%eax
80106dd0:	74 22                	je     80106df4 <trap+0x27b>
80106dd2:	e8 48 d4 ff ff       	call   8010421f <myproc>
80106dd7:	8b 40 24             	mov    0x24(%eax),%eax
80106dda:	85 c0                	test   %eax,%eax
80106ddc:	74 16                	je     80106df4 <trap+0x27b>
80106dde:	8b 45 08             	mov    0x8(%ebp),%eax
80106de1:	8b 40 3c             	mov    0x3c(%eax),%eax
80106de4:	0f b7 c0             	movzwl %ax,%eax
80106de7:	83 e0 03             	and    $0x3,%eax
80106dea:	83 f8 03             	cmp    $0x3,%eax
80106ded:	75 05                	jne    80106df4 <trap+0x27b>
    exit();
80106def:	e8 be d8 ff ff       	call   801046b2 <exit>
}
80106df4:	83 c4 4c             	add    $0x4c,%esp
80106df7:	5b                   	pop    %ebx
80106df8:	5e                   	pop    %esi
80106df9:	5f                   	pop    %edi
80106dfa:	5d                   	pop    %ebp
80106dfb:	c3                   	ret    

80106dfc <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106dfc:	55                   	push   %ebp
80106dfd:	89 e5                	mov    %esp,%ebp
80106dff:	83 ec 14             	sub    $0x14,%esp
80106e02:	8b 45 08             	mov    0x8(%ebp),%eax
80106e05:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106e09:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106e0c:	89 c2                	mov    %eax,%edx
80106e0e:	ec                   	in     (%dx),%al
80106e0f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106e12:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80106e15:	c9                   	leave  
80106e16:	c3                   	ret    

80106e17 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106e17:	55                   	push   %ebp
80106e18:	89 e5                	mov    %esp,%ebp
80106e1a:	83 ec 08             	sub    $0x8,%esp
80106e1d:	8b 45 08             	mov    0x8(%ebp),%eax
80106e20:	8b 55 0c             	mov    0xc(%ebp),%edx
80106e23:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80106e27:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106e2a:	8a 45 f8             	mov    -0x8(%ebp),%al
80106e2d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80106e30:	ee                   	out    %al,(%dx)
}
80106e31:	c9                   	leave  
80106e32:	c3                   	ret    

80106e33 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106e33:	55                   	push   %ebp
80106e34:	89 e5                	mov    %esp,%ebp
80106e36:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106e39:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e40:	00 
80106e41:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106e48:	e8 ca ff ff ff       	call   80106e17 <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106e4d:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80106e54:	00 
80106e55:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106e5c:	e8 b6 ff ff ff       	call   80106e17 <outb>
  outb(COM1+0, 115200/9600);
80106e61:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80106e68:	00 
80106e69:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106e70:	e8 a2 ff ff ff       	call   80106e17 <outb>
  outb(COM1+1, 0);
80106e75:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e7c:	00 
80106e7d:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106e84:	e8 8e ff ff ff       	call   80106e17 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106e89:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106e90:	00 
80106e91:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80106e98:	e8 7a ff ff ff       	call   80106e17 <outb>
  outb(COM1+4, 0);
80106e9d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106ea4:	00 
80106ea5:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80106eac:	e8 66 ff ff ff       	call   80106e17 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106eb1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106eb8:	00 
80106eb9:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80106ec0:	e8 52 ff ff ff       	call   80106e17 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106ec5:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106ecc:	e8 2b ff ff ff       	call   80106dfc <inb>
80106ed1:	3c ff                	cmp    $0xff,%al
80106ed3:	75 02                	jne    80106ed7 <uartinit+0xa4>
    return;
80106ed5:	eb 5b                	jmp    80106f32 <uartinit+0xff>
  uart = 1;
80106ed7:	c7 05 84 b7 10 80 01 	movl   $0x1,0x8010b784
80106ede:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106ee1:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80106ee8:	e8 0f ff ff ff       	call   80106dfc <inb>
  inb(COM1+0);
80106eed:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106ef4:	e8 03 ff ff ff       	call   80106dfc <inb>
  ioapicenable(IRQ_COM1, 0);
80106ef9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106f00:	00 
80106f01:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106f08:	e8 de bb ff ff       	call   80102aeb <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106f0d:	c7 45 f4 b8 8e 10 80 	movl   $0x80108eb8,-0xc(%ebp)
80106f14:	eb 13                	jmp    80106f29 <uartinit+0xf6>
    uartputc(*p);
80106f16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f19:	8a 00                	mov    (%eax),%al
80106f1b:	0f be c0             	movsbl %al,%eax
80106f1e:	89 04 24             	mov    %eax,(%esp)
80106f21:	e8 0e 00 00 00       	call   80106f34 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106f26:	ff 45 f4             	incl   -0xc(%ebp)
80106f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f2c:	8a 00                	mov    (%eax),%al
80106f2e:	84 c0                	test   %al,%al
80106f30:	75 e4                	jne    80106f16 <uartinit+0xe3>
    uartputc(*p);
}
80106f32:	c9                   	leave  
80106f33:	c3                   	ret    

80106f34 <uartputc>:

void
uartputc(int c)
{
80106f34:	55                   	push   %ebp
80106f35:	89 e5                	mov    %esp,%ebp
80106f37:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80106f3a:	a1 84 b7 10 80       	mov    0x8010b784,%eax
80106f3f:	85 c0                	test   %eax,%eax
80106f41:	75 02                	jne    80106f45 <uartputc+0x11>
    return;
80106f43:	eb 4a                	jmp    80106f8f <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106f45:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106f4c:	eb 0f                	jmp    80106f5d <uartputc+0x29>
    microdelay(10);
80106f4e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80106f55:	e8 c2 c0 ff ff       	call   8010301c <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106f5a:	ff 45 f4             	incl   -0xc(%ebp)
80106f5d:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106f61:	7f 16                	jg     80106f79 <uartputc+0x45>
80106f63:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106f6a:	e8 8d fe ff ff       	call   80106dfc <inb>
80106f6f:	0f b6 c0             	movzbl %al,%eax
80106f72:	83 e0 20             	and    $0x20,%eax
80106f75:	85 c0                	test   %eax,%eax
80106f77:	74 d5                	je     80106f4e <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80106f79:	8b 45 08             	mov    0x8(%ebp),%eax
80106f7c:	0f b6 c0             	movzbl %al,%eax
80106f7f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f83:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106f8a:	e8 88 fe ff ff       	call   80106e17 <outb>
}
80106f8f:	c9                   	leave  
80106f90:	c3                   	ret    

80106f91 <uartgetc>:

static int
uartgetc(void)
{
80106f91:	55                   	push   %ebp
80106f92:	89 e5                	mov    %esp,%ebp
80106f94:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80106f97:	a1 84 b7 10 80       	mov    0x8010b784,%eax
80106f9c:	85 c0                	test   %eax,%eax
80106f9e:	75 07                	jne    80106fa7 <uartgetc+0x16>
    return -1;
80106fa0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fa5:	eb 2c                	jmp    80106fd3 <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80106fa7:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80106fae:	e8 49 fe ff ff       	call   80106dfc <inb>
80106fb3:	0f b6 c0             	movzbl %al,%eax
80106fb6:	83 e0 01             	and    $0x1,%eax
80106fb9:	85 c0                	test   %eax,%eax
80106fbb:	75 07                	jne    80106fc4 <uartgetc+0x33>
    return -1;
80106fbd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106fc2:	eb 0f                	jmp    80106fd3 <uartgetc+0x42>
  return inb(COM1+0);
80106fc4:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80106fcb:	e8 2c fe ff ff       	call   80106dfc <inb>
80106fd0:	0f b6 c0             	movzbl %al,%eax
}
80106fd3:	c9                   	leave  
80106fd4:	c3                   	ret    

80106fd5 <uartintr>:

void
uartintr(void)
{
80106fd5:	55                   	push   %ebp
80106fd6:	89 e5                	mov    %esp,%ebp
80106fd8:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80106fdb:	c7 04 24 91 6f 10 80 	movl   $0x80106f91,(%esp)
80106fe2:	e8 0e 98 ff ff       	call   801007f5 <consoleintr>
}
80106fe7:	c9                   	leave  
80106fe8:	c3                   	ret    
80106fe9:	00 00                	add    %al,(%eax)
	...

80106fec <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106fec:	6a 00                	push   $0x0
  pushl $0
80106fee:	6a 00                	push   $0x0
  jmp alltraps
80106ff0:	e9 af f9 ff ff       	jmp    801069a4 <alltraps>

80106ff5 <vector1>:
.globl vector1
vector1:
  pushl $0
80106ff5:	6a 00                	push   $0x0
  pushl $1
80106ff7:	6a 01                	push   $0x1
  jmp alltraps
80106ff9:	e9 a6 f9 ff ff       	jmp    801069a4 <alltraps>

80106ffe <vector2>:
.globl vector2
vector2:
  pushl $0
80106ffe:	6a 00                	push   $0x0
  pushl $2
80107000:	6a 02                	push   $0x2
  jmp alltraps
80107002:	e9 9d f9 ff ff       	jmp    801069a4 <alltraps>

80107007 <vector3>:
.globl vector3
vector3:
  pushl $0
80107007:	6a 00                	push   $0x0
  pushl $3
80107009:	6a 03                	push   $0x3
  jmp alltraps
8010700b:	e9 94 f9 ff ff       	jmp    801069a4 <alltraps>

80107010 <vector4>:
.globl vector4
vector4:
  pushl $0
80107010:	6a 00                	push   $0x0
  pushl $4
80107012:	6a 04                	push   $0x4
  jmp alltraps
80107014:	e9 8b f9 ff ff       	jmp    801069a4 <alltraps>

80107019 <vector5>:
.globl vector5
vector5:
  pushl $0
80107019:	6a 00                	push   $0x0
  pushl $5
8010701b:	6a 05                	push   $0x5
  jmp alltraps
8010701d:	e9 82 f9 ff ff       	jmp    801069a4 <alltraps>

80107022 <vector6>:
.globl vector6
vector6:
  pushl $0
80107022:	6a 00                	push   $0x0
  pushl $6
80107024:	6a 06                	push   $0x6
  jmp alltraps
80107026:	e9 79 f9 ff ff       	jmp    801069a4 <alltraps>

8010702b <vector7>:
.globl vector7
vector7:
  pushl $0
8010702b:	6a 00                	push   $0x0
  pushl $7
8010702d:	6a 07                	push   $0x7
  jmp alltraps
8010702f:	e9 70 f9 ff ff       	jmp    801069a4 <alltraps>

80107034 <vector8>:
.globl vector8
vector8:
  pushl $8
80107034:	6a 08                	push   $0x8
  jmp alltraps
80107036:	e9 69 f9 ff ff       	jmp    801069a4 <alltraps>

8010703b <vector9>:
.globl vector9
vector9:
  pushl $0
8010703b:	6a 00                	push   $0x0
  pushl $9
8010703d:	6a 09                	push   $0x9
  jmp alltraps
8010703f:	e9 60 f9 ff ff       	jmp    801069a4 <alltraps>

80107044 <vector10>:
.globl vector10
vector10:
  pushl $10
80107044:	6a 0a                	push   $0xa
  jmp alltraps
80107046:	e9 59 f9 ff ff       	jmp    801069a4 <alltraps>

8010704b <vector11>:
.globl vector11
vector11:
  pushl $11
8010704b:	6a 0b                	push   $0xb
  jmp alltraps
8010704d:	e9 52 f9 ff ff       	jmp    801069a4 <alltraps>

80107052 <vector12>:
.globl vector12
vector12:
  pushl $12
80107052:	6a 0c                	push   $0xc
  jmp alltraps
80107054:	e9 4b f9 ff ff       	jmp    801069a4 <alltraps>

80107059 <vector13>:
.globl vector13
vector13:
  pushl $13
80107059:	6a 0d                	push   $0xd
  jmp alltraps
8010705b:	e9 44 f9 ff ff       	jmp    801069a4 <alltraps>

80107060 <vector14>:
.globl vector14
vector14:
  pushl $14
80107060:	6a 0e                	push   $0xe
  jmp alltraps
80107062:	e9 3d f9 ff ff       	jmp    801069a4 <alltraps>

80107067 <vector15>:
.globl vector15
vector15:
  pushl $0
80107067:	6a 00                	push   $0x0
  pushl $15
80107069:	6a 0f                	push   $0xf
  jmp alltraps
8010706b:	e9 34 f9 ff ff       	jmp    801069a4 <alltraps>

80107070 <vector16>:
.globl vector16
vector16:
  pushl $0
80107070:	6a 00                	push   $0x0
  pushl $16
80107072:	6a 10                	push   $0x10
  jmp alltraps
80107074:	e9 2b f9 ff ff       	jmp    801069a4 <alltraps>

80107079 <vector17>:
.globl vector17
vector17:
  pushl $17
80107079:	6a 11                	push   $0x11
  jmp alltraps
8010707b:	e9 24 f9 ff ff       	jmp    801069a4 <alltraps>

80107080 <vector18>:
.globl vector18
vector18:
  pushl $0
80107080:	6a 00                	push   $0x0
  pushl $18
80107082:	6a 12                	push   $0x12
  jmp alltraps
80107084:	e9 1b f9 ff ff       	jmp    801069a4 <alltraps>

80107089 <vector19>:
.globl vector19
vector19:
  pushl $0
80107089:	6a 00                	push   $0x0
  pushl $19
8010708b:	6a 13                	push   $0x13
  jmp alltraps
8010708d:	e9 12 f9 ff ff       	jmp    801069a4 <alltraps>

80107092 <vector20>:
.globl vector20
vector20:
  pushl $0
80107092:	6a 00                	push   $0x0
  pushl $20
80107094:	6a 14                	push   $0x14
  jmp alltraps
80107096:	e9 09 f9 ff ff       	jmp    801069a4 <alltraps>

8010709b <vector21>:
.globl vector21
vector21:
  pushl $0
8010709b:	6a 00                	push   $0x0
  pushl $21
8010709d:	6a 15                	push   $0x15
  jmp alltraps
8010709f:	e9 00 f9 ff ff       	jmp    801069a4 <alltraps>

801070a4 <vector22>:
.globl vector22
vector22:
  pushl $0
801070a4:	6a 00                	push   $0x0
  pushl $22
801070a6:	6a 16                	push   $0x16
  jmp alltraps
801070a8:	e9 f7 f8 ff ff       	jmp    801069a4 <alltraps>

801070ad <vector23>:
.globl vector23
vector23:
  pushl $0
801070ad:	6a 00                	push   $0x0
  pushl $23
801070af:	6a 17                	push   $0x17
  jmp alltraps
801070b1:	e9 ee f8 ff ff       	jmp    801069a4 <alltraps>

801070b6 <vector24>:
.globl vector24
vector24:
  pushl $0
801070b6:	6a 00                	push   $0x0
  pushl $24
801070b8:	6a 18                	push   $0x18
  jmp alltraps
801070ba:	e9 e5 f8 ff ff       	jmp    801069a4 <alltraps>

801070bf <vector25>:
.globl vector25
vector25:
  pushl $0
801070bf:	6a 00                	push   $0x0
  pushl $25
801070c1:	6a 19                	push   $0x19
  jmp alltraps
801070c3:	e9 dc f8 ff ff       	jmp    801069a4 <alltraps>

801070c8 <vector26>:
.globl vector26
vector26:
  pushl $0
801070c8:	6a 00                	push   $0x0
  pushl $26
801070ca:	6a 1a                	push   $0x1a
  jmp alltraps
801070cc:	e9 d3 f8 ff ff       	jmp    801069a4 <alltraps>

801070d1 <vector27>:
.globl vector27
vector27:
  pushl $0
801070d1:	6a 00                	push   $0x0
  pushl $27
801070d3:	6a 1b                	push   $0x1b
  jmp alltraps
801070d5:	e9 ca f8 ff ff       	jmp    801069a4 <alltraps>

801070da <vector28>:
.globl vector28
vector28:
  pushl $0
801070da:	6a 00                	push   $0x0
  pushl $28
801070dc:	6a 1c                	push   $0x1c
  jmp alltraps
801070de:	e9 c1 f8 ff ff       	jmp    801069a4 <alltraps>

801070e3 <vector29>:
.globl vector29
vector29:
  pushl $0
801070e3:	6a 00                	push   $0x0
  pushl $29
801070e5:	6a 1d                	push   $0x1d
  jmp alltraps
801070e7:	e9 b8 f8 ff ff       	jmp    801069a4 <alltraps>

801070ec <vector30>:
.globl vector30
vector30:
  pushl $0
801070ec:	6a 00                	push   $0x0
  pushl $30
801070ee:	6a 1e                	push   $0x1e
  jmp alltraps
801070f0:	e9 af f8 ff ff       	jmp    801069a4 <alltraps>

801070f5 <vector31>:
.globl vector31
vector31:
  pushl $0
801070f5:	6a 00                	push   $0x0
  pushl $31
801070f7:	6a 1f                	push   $0x1f
  jmp alltraps
801070f9:	e9 a6 f8 ff ff       	jmp    801069a4 <alltraps>

801070fe <vector32>:
.globl vector32
vector32:
  pushl $0
801070fe:	6a 00                	push   $0x0
  pushl $32
80107100:	6a 20                	push   $0x20
  jmp alltraps
80107102:	e9 9d f8 ff ff       	jmp    801069a4 <alltraps>

80107107 <vector33>:
.globl vector33
vector33:
  pushl $0
80107107:	6a 00                	push   $0x0
  pushl $33
80107109:	6a 21                	push   $0x21
  jmp alltraps
8010710b:	e9 94 f8 ff ff       	jmp    801069a4 <alltraps>

80107110 <vector34>:
.globl vector34
vector34:
  pushl $0
80107110:	6a 00                	push   $0x0
  pushl $34
80107112:	6a 22                	push   $0x22
  jmp alltraps
80107114:	e9 8b f8 ff ff       	jmp    801069a4 <alltraps>

80107119 <vector35>:
.globl vector35
vector35:
  pushl $0
80107119:	6a 00                	push   $0x0
  pushl $35
8010711b:	6a 23                	push   $0x23
  jmp alltraps
8010711d:	e9 82 f8 ff ff       	jmp    801069a4 <alltraps>

80107122 <vector36>:
.globl vector36
vector36:
  pushl $0
80107122:	6a 00                	push   $0x0
  pushl $36
80107124:	6a 24                	push   $0x24
  jmp alltraps
80107126:	e9 79 f8 ff ff       	jmp    801069a4 <alltraps>

8010712b <vector37>:
.globl vector37
vector37:
  pushl $0
8010712b:	6a 00                	push   $0x0
  pushl $37
8010712d:	6a 25                	push   $0x25
  jmp alltraps
8010712f:	e9 70 f8 ff ff       	jmp    801069a4 <alltraps>

80107134 <vector38>:
.globl vector38
vector38:
  pushl $0
80107134:	6a 00                	push   $0x0
  pushl $38
80107136:	6a 26                	push   $0x26
  jmp alltraps
80107138:	e9 67 f8 ff ff       	jmp    801069a4 <alltraps>

8010713d <vector39>:
.globl vector39
vector39:
  pushl $0
8010713d:	6a 00                	push   $0x0
  pushl $39
8010713f:	6a 27                	push   $0x27
  jmp alltraps
80107141:	e9 5e f8 ff ff       	jmp    801069a4 <alltraps>

80107146 <vector40>:
.globl vector40
vector40:
  pushl $0
80107146:	6a 00                	push   $0x0
  pushl $40
80107148:	6a 28                	push   $0x28
  jmp alltraps
8010714a:	e9 55 f8 ff ff       	jmp    801069a4 <alltraps>

8010714f <vector41>:
.globl vector41
vector41:
  pushl $0
8010714f:	6a 00                	push   $0x0
  pushl $41
80107151:	6a 29                	push   $0x29
  jmp alltraps
80107153:	e9 4c f8 ff ff       	jmp    801069a4 <alltraps>

80107158 <vector42>:
.globl vector42
vector42:
  pushl $0
80107158:	6a 00                	push   $0x0
  pushl $42
8010715a:	6a 2a                	push   $0x2a
  jmp alltraps
8010715c:	e9 43 f8 ff ff       	jmp    801069a4 <alltraps>

80107161 <vector43>:
.globl vector43
vector43:
  pushl $0
80107161:	6a 00                	push   $0x0
  pushl $43
80107163:	6a 2b                	push   $0x2b
  jmp alltraps
80107165:	e9 3a f8 ff ff       	jmp    801069a4 <alltraps>

8010716a <vector44>:
.globl vector44
vector44:
  pushl $0
8010716a:	6a 00                	push   $0x0
  pushl $44
8010716c:	6a 2c                	push   $0x2c
  jmp alltraps
8010716e:	e9 31 f8 ff ff       	jmp    801069a4 <alltraps>

80107173 <vector45>:
.globl vector45
vector45:
  pushl $0
80107173:	6a 00                	push   $0x0
  pushl $45
80107175:	6a 2d                	push   $0x2d
  jmp alltraps
80107177:	e9 28 f8 ff ff       	jmp    801069a4 <alltraps>

8010717c <vector46>:
.globl vector46
vector46:
  pushl $0
8010717c:	6a 00                	push   $0x0
  pushl $46
8010717e:	6a 2e                	push   $0x2e
  jmp alltraps
80107180:	e9 1f f8 ff ff       	jmp    801069a4 <alltraps>

80107185 <vector47>:
.globl vector47
vector47:
  pushl $0
80107185:	6a 00                	push   $0x0
  pushl $47
80107187:	6a 2f                	push   $0x2f
  jmp alltraps
80107189:	e9 16 f8 ff ff       	jmp    801069a4 <alltraps>

8010718e <vector48>:
.globl vector48
vector48:
  pushl $0
8010718e:	6a 00                	push   $0x0
  pushl $48
80107190:	6a 30                	push   $0x30
  jmp alltraps
80107192:	e9 0d f8 ff ff       	jmp    801069a4 <alltraps>

80107197 <vector49>:
.globl vector49
vector49:
  pushl $0
80107197:	6a 00                	push   $0x0
  pushl $49
80107199:	6a 31                	push   $0x31
  jmp alltraps
8010719b:	e9 04 f8 ff ff       	jmp    801069a4 <alltraps>

801071a0 <vector50>:
.globl vector50
vector50:
  pushl $0
801071a0:	6a 00                	push   $0x0
  pushl $50
801071a2:	6a 32                	push   $0x32
  jmp alltraps
801071a4:	e9 fb f7 ff ff       	jmp    801069a4 <alltraps>

801071a9 <vector51>:
.globl vector51
vector51:
  pushl $0
801071a9:	6a 00                	push   $0x0
  pushl $51
801071ab:	6a 33                	push   $0x33
  jmp alltraps
801071ad:	e9 f2 f7 ff ff       	jmp    801069a4 <alltraps>

801071b2 <vector52>:
.globl vector52
vector52:
  pushl $0
801071b2:	6a 00                	push   $0x0
  pushl $52
801071b4:	6a 34                	push   $0x34
  jmp alltraps
801071b6:	e9 e9 f7 ff ff       	jmp    801069a4 <alltraps>

801071bb <vector53>:
.globl vector53
vector53:
  pushl $0
801071bb:	6a 00                	push   $0x0
  pushl $53
801071bd:	6a 35                	push   $0x35
  jmp alltraps
801071bf:	e9 e0 f7 ff ff       	jmp    801069a4 <alltraps>

801071c4 <vector54>:
.globl vector54
vector54:
  pushl $0
801071c4:	6a 00                	push   $0x0
  pushl $54
801071c6:	6a 36                	push   $0x36
  jmp alltraps
801071c8:	e9 d7 f7 ff ff       	jmp    801069a4 <alltraps>

801071cd <vector55>:
.globl vector55
vector55:
  pushl $0
801071cd:	6a 00                	push   $0x0
  pushl $55
801071cf:	6a 37                	push   $0x37
  jmp alltraps
801071d1:	e9 ce f7 ff ff       	jmp    801069a4 <alltraps>

801071d6 <vector56>:
.globl vector56
vector56:
  pushl $0
801071d6:	6a 00                	push   $0x0
  pushl $56
801071d8:	6a 38                	push   $0x38
  jmp alltraps
801071da:	e9 c5 f7 ff ff       	jmp    801069a4 <alltraps>

801071df <vector57>:
.globl vector57
vector57:
  pushl $0
801071df:	6a 00                	push   $0x0
  pushl $57
801071e1:	6a 39                	push   $0x39
  jmp alltraps
801071e3:	e9 bc f7 ff ff       	jmp    801069a4 <alltraps>

801071e8 <vector58>:
.globl vector58
vector58:
  pushl $0
801071e8:	6a 00                	push   $0x0
  pushl $58
801071ea:	6a 3a                	push   $0x3a
  jmp alltraps
801071ec:	e9 b3 f7 ff ff       	jmp    801069a4 <alltraps>

801071f1 <vector59>:
.globl vector59
vector59:
  pushl $0
801071f1:	6a 00                	push   $0x0
  pushl $59
801071f3:	6a 3b                	push   $0x3b
  jmp alltraps
801071f5:	e9 aa f7 ff ff       	jmp    801069a4 <alltraps>

801071fa <vector60>:
.globl vector60
vector60:
  pushl $0
801071fa:	6a 00                	push   $0x0
  pushl $60
801071fc:	6a 3c                	push   $0x3c
  jmp alltraps
801071fe:	e9 a1 f7 ff ff       	jmp    801069a4 <alltraps>

80107203 <vector61>:
.globl vector61
vector61:
  pushl $0
80107203:	6a 00                	push   $0x0
  pushl $61
80107205:	6a 3d                	push   $0x3d
  jmp alltraps
80107207:	e9 98 f7 ff ff       	jmp    801069a4 <alltraps>

8010720c <vector62>:
.globl vector62
vector62:
  pushl $0
8010720c:	6a 00                	push   $0x0
  pushl $62
8010720e:	6a 3e                	push   $0x3e
  jmp alltraps
80107210:	e9 8f f7 ff ff       	jmp    801069a4 <alltraps>

80107215 <vector63>:
.globl vector63
vector63:
  pushl $0
80107215:	6a 00                	push   $0x0
  pushl $63
80107217:	6a 3f                	push   $0x3f
  jmp alltraps
80107219:	e9 86 f7 ff ff       	jmp    801069a4 <alltraps>

8010721e <vector64>:
.globl vector64
vector64:
  pushl $0
8010721e:	6a 00                	push   $0x0
  pushl $64
80107220:	6a 40                	push   $0x40
  jmp alltraps
80107222:	e9 7d f7 ff ff       	jmp    801069a4 <alltraps>

80107227 <vector65>:
.globl vector65
vector65:
  pushl $0
80107227:	6a 00                	push   $0x0
  pushl $65
80107229:	6a 41                	push   $0x41
  jmp alltraps
8010722b:	e9 74 f7 ff ff       	jmp    801069a4 <alltraps>

80107230 <vector66>:
.globl vector66
vector66:
  pushl $0
80107230:	6a 00                	push   $0x0
  pushl $66
80107232:	6a 42                	push   $0x42
  jmp alltraps
80107234:	e9 6b f7 ff ff       	jmp    801069a4 <alltraps>

80107239 <vector67>:
.globl vector67
vector67:
  pushl $0
80107239:	6a 00                	push   $0x0
  pushl $67
8010723b:	6a 43                	push   $0x43
  jmp alltraps
8010723d:	e9 62 f7 ff ff       	jmp    801069a4 <alltraps>

80107242 <vector68>:
.globl vector68
vector68:
  pushl $0
80107242:	6a 00                	push   $0x0
  pushl $68
80107244:	6a 44                	push   $0x44
  jmp alltraps
80107246:	e9 59 f7 ff ff       	jmp    801069a4 <alltraps>

8010724b <vector69>:
.globl vector69
vector69:
  pushl $0
8010724b:	6a 00                	push   $0x0
  pushl $69
8010724d:	6a 45                	push   $0x45
  jmp alltraps
8010724f:	e9 50 f7 ff ff       	jmp    801069a4 <alltraps>

80107254 <vector70>:
.globl vector70
vector70:
  pushl $0
80107254:	6a 00                	push   $0x0
  pushl $70
80107256:	6a 46                	push   $0x46
  jmp alltraps
80107258:	e9 47 f7 ff ff       	jmp    801069a4 <alltraps>

8010725d <vector71>:
.globl vector71
vector71:
  pushl $0
8010725d:	6a 00                	push   $0x0
  pushl $71
8010725f:	6a 47                	push   $0x47
  jmp alltraps
80107261:	e9 3e f7 ff ff       	jmp    801069a4 <alltraps>

80107266 <vector72>:
.globl vector72
vector72:
  pushl $0
80107266:	6a 00                	push   $0x0
  pushl $72
80107268:	6a 48                	push   $0x48
  jmp alltraps
8010726a:	e9 35 f7 ff ff       	jmp    801069a4 <alltraps>

8010726f <vector73>:
.globl vector73
vector73:
  pushl $0
8010726f:	6a 00                	push   $0x0
  pushl $73
80107271:	6a 49                	push   $0x49
  jmp alltraps
80107273:	e9 2c f7 ff ff       	jmp    801069a4 <alltraps>

80107278 <vector74>:
.globl vector74
vector74:
  pushl $0
80107278:	6a 00                	push   $0x0
  pushl $74
8010727a:	6a 4a                	push   $0x4a
  jmp alltraps
8010727c:	e9 23 f7 ff ff       	jmp    801069a4 <alltraps>

80107281 <vector75>:
.globl vector75
vector75:
  pushl $0
80107281:	6a 00                	push   $0x0
  pushl $75
80107283:	6a 4b                	push   $0x4b
  jmp alltraps
80107285:	e9 1a f7 ff ff       	jmp    801069a4 <alltraps>

8010728a <vector76>:
.globl vector76
vector76:
  pushl $0
8010728a:	6a 00                	push   $0x0
  pushl $76
8010728c:	6a 4c                	push   $0x4c
  jmp alltraps
8010728e:	e9 11 f7 ff ff       	jmp    801069a4 <alltraps>

80107293 <vector77>:
.globl vector77
vector77:
  pushl $0
80107293:	6a 00                	push   $0x0
  pushl $77
80107295:	6a 4d                	push   $0x4d
  jmp alltraps
80107297:	e9 08 f7 ff ff       	jmp    801069a4 <alltraps>

8010729c <vector78>:
.globl vector78
vector78:
  pushl $0
8010729c:	6a 00                	push   $0x0
  pushl $78
8010729e:	6a 4e                	push   $0x4e
  jmp alltraps
801072a0:	e9 ff f6 ff ff       	jmp    801069a4 <alltraps>

801072a5 <vector79>:
.globl vector79
vector79:
  pushl $0
801072a5:	6a 00                	push   $0x0
  pushl $79
801072a7:	6a 4f                	push   $0x4f
  jmp alltraps
801072a9:	e9 f6 f6 ff ff       	jmp    801069a4 <alltraps>

801072ae <vector80>:
.globl vector80
vector80:
  pushl $0
801072ae:	6a 00                	push   $0x0
  pushl $80
801072b0:	6a 50                	push   $0x50
  jmp alltraps
801072b2:	e9 ed f6 ff ff       	jmp    801069a4 <alltraps>

801072b7 <vector81>:
.globl vector81
vector81:
  pushl $0
801072b7:	6a 00                	push   $0x0
  pushl $81
801072b9:	6a 51                	push   $0x51
  jmp alltraps
801072bb:	e9 e4 f6 ff ff       	jmp    801069a4 <alltraps>

801072c0 <vector82>:
.globl vector82
vector82:
  pushl $0
801072c0:	6a 00                	push   $0x0
  pushl $82
801072c2:	6a 52                	push   $0x52
  jmp alltraps
801072c4:	e9 db f6 ff ff       	jmp    801069a4 <alltraps>

801072c9 <vector83>:
.globl vector83
vector83:
  pushl $0
801072c9:	6a 00                	push   $0x0
  pushl $83
801072cb:	6a 53                	push   $0x53
  jmp alltraps
801072cd:	e9 d2 f6 ff ff       	jmp    801069a4 <alltraps>

801072d2 <vector84>:
.globl vector84
vector84:
  pushl $0
801072d2:	6a 00                	push   $0x0
  pushl $84
801072d4:	6a 54                	push   $0x54
  jmp alltraps
801072d6:	e9 c9 f6 ff ff       	jmp    801069a4 <alltraps>

801072db <vector85>:
.globl vector85
vector85:
  pushl $0
801072db:	6a 00                	push   $0x0
  pushl $85
801072dd:	6a 55                	push   $0x55
  jmp alltraps
801072df:	e9 c0 f6 ff ff       	jmp    801069a4 <alltraps>

801072e4 <vector86>:
.globl vector86
vector86:
  pushl $0
801072e4:	6a 00                	push   $0x0
  pushl $86
801072e6:	6a 56                	push   $0x56
  jmp alltraps
801072e8:	e9 b7 f6 ff ff       	jmp    801069a4 <alltraps>

801072ed <vector87>:
.globl vector87
vector87:
  pushl $0
801072ed:	6a 00                	push   $0x0
  pushl $87
801072ef:	6a 57                	push   $0x57
  jmp alltraps
801072f1:	e9 ae f6 ff ff       	jmp    801069a4 <alltraps>

801072f6 <vector88>:
.globl vector88
vector88:
  pushl $0
801072f6:	6a 00                	push   $0x0
  pushl $88
801072f8:	6a 58                	push   $0x58
  jmp alltraps
801072fa:	e9 a5 f6 ff ff       	jmp    801069a4 <alltraps>

801072ff <vector89>:
.globl vector89
vector89:
  pushl $0
801072ff:	6a 00                	push   $0x0
  pushl $89
80107301:	6a 59                	push   $0x59
  jmp alltraps
80107303:	e9 9c f6 ff ff       	jmp    801069a4 <alltraps>

80107308 <vector90>:
.globl vector90
vector90:
  pushl $0
80107308:	6a 00                	push   $0x0
  pushl $90
8010730a:	6a 5a                	push   $0x5a
  jmp alltraps
8010730c:	e9 93 f6 ff ff       	jmp    801069a4 <alltraps>

80107311 <vector91>:
.globl vector91
vector91:
  pushl $0
80107311:	6a 00                	push   $0x0
  pushl $91
80107313:	6a 5b                	push   $0x5b
  jmp alltraps
80107315:	e9 8a f6 ff ff       	jmp    801069a4 <alltraps>

8010731a <vector92>:
.globl vector92
vector92:
  pushl $0
8010731a:	6a 00                	push   $0x0
  pushl $92
8010731c:	6a 5c                	push   $0x5c
  jmp alltraps
8010731e:	e9 81 f6 ff ff       	jmp    801069a4 <alltraps>

80107323 <vector93>:
.globl vector93
vector93:
  pushl $0
80107323:	6a 00                	push   $0x0
  pushl $93
80107325:	6a 5d                	push   $0x5d
  jmp alltraps
80107327:	e9 78 f6 ff ff       	jmp    801069a4 <alltraps>

8010732c <vector94>:
.globl vector94
vector94:
  pushl $0
8010732c:	6a 00                	push   $0x0
  pushl $94
8010732e:	6a 5e                	push   $0x5e
  jmp alltraps
80107330:	e9 6f f6 ff ff       	jmp    801069a4 <alltraps>

80107335 <vector95>:
.globl vector95
vector95:
  pushl $0
80107335:	6a 00                	push   $0x0
  pushl $95
80107337:	6a 5f                	push   $0x5f
  jmp alltraps
80107339:	e9 66 f6 ff ff       	jmp    801069a4 <alltraps>

8010733e <vector96>:
.globl vector96
vector96:
  pushl $0
8010733e:	6a 00                	push   $0x0
  pushl $96
80107340:	6a 60                	push   $0x60
  jmp alltraps
80107342:	e9 5d f6 ff ff       	jmp    801069a4 <alltraps>

80107347 <vector97>:
.globl vector97
vector97:
  pushl $0
80107347:	6a 00                	push   $0x0
  pushl $97
80107349:	6a 61                	push   $0x61
  jmp alltraps
8010734b:	e9 54 f6 ff ff       	jmp    801069a4 <alltraps>

80107350 <vector98>:
.globl vector98
vector98:
  pushl $0
80107350:	6a 00                	push   $0x0
  pushl $98
80107352:	6a 62                	push   $0x62
  jmp alltraps
80107354:	e9 4b f6 ff ff       	jmp    801069a4 <alltraps>

80107359 <vector99>:
.globl vector99
vector99:
  pushl $0
80107359:	6a 00                	push   $0x0
  pushl $99
8010735b:	6a 63                	push   $0x63
  jmp alltraps
8010735d:	e9 42 f6 ff ff       	jmp    801069a4 <alltraps>

80107362 <vector100>:
.globl vector100
vector100:
  pushl $0
80107362:	6a 00                	push   $0x0
  pushl $100
80107364:	6a 64                	push   $0x64
  jmp alltraps
80107366:	e9 39 f6 ff ff       	jmp    801069a4 <alltraps>

8010736b <vector101>:
.globl vector101
vector101:
  pushl $0
8010736b:	6a 00                	push   $0x0
  pushl $101
8010736d:	6a 65                	push   $0x65
  jmp alltraps
8010736f:	e9 30 f6 ff ff       	jmp    801069a4 <alltraps>

80107374 <vector102>:
.globl vector102
vector102:
  pushl $0
80107374:	6a 00                	push   $0x0
  pushl $102
80107376:	6a 66                	push   $0x66
  jmp alltraps
80107378:	e9 27 f6 ff ff       	jmp    801069a4 <alltraps>

8010737d <vector103>:
.globl vector103
vector103:
  pushl $0
8010737d:	6a 00                	push   $0x0
  pushl $103
8010737f:	6a 67                	push   $0x67
  jmp alltraps
80107381:	e9 1e f6 ff ff       	jmp    801069a4 <alltraps>

80107386 <vector104>:
.globl vector104
vector104:
  pushl $0
80107386:	6a 00                	push   $0x0
  pushl $104
80107388:	6a 68                	push   $0x68
  jmp alltraps
8010738a:	e9 15 f6 ff ff       	jmp    801069a4 <alltraps>

8010738f <vector105>:
.globl vector105
vector105:
  pushl $0
8010738f:	6a 00                	push   $0x0
  pushl $105
80107391:	6a 69                	push   $0x69
  jmp alltraps
80107393:	e9 0c f6 ff ff       	jmp    801069a4 <alltraps>

80107398 <vector106>:
.globl vector106
vector106:
  pushl $0
80107398:	6a 00                	push   $0x0
  pushl $106
8010739a:	6a 6a                	push   $0x6a
  jmp alltraps
8010739c:	e9 03 f6 ff ff       	jmp    801069a4 <alltraps>

801073a1 <vector107>:
.globl vector107
vector107:
  pushl $0
801073a1:	6a 00                	push   $0x0
  pushl $107
801073a3:	6a 6b                	push   $0x6b
  jmp alltraps
801073a5:	e9 fa f5 ff ff       	jmp    801069a4 <alltraps>

801073aa <vector108>:
.globl vector108
vector108:
  pushl $0
801073aa:	6a 00                	push   $0x0
  pushl $108
801073ac:	6a 6c                	push   $0x6c
  jmp alltraps
801073ae:	e9 f1 f5 ff ff       	jmp    801069a4 <alltraps>

801073b3 <vector109>:
.globl vector109
vector109:
  pushl $0
801073b3:	6a 00                	push   $0x0
  pushl $109
801073b5:	6a 6d                	push   $0x6d
  jmp alltraps
801073b7:	e9 e8 f5 ff ff       	jmp    801069a4 <alltraps>

801073bc <vector110>:
.globl vector110
vector110:
  pushl $0
801073bc:	6a 00                	push   $0x0
  pushl $110
801073be:	6a 6e                	push   $0x6e
  jmp alltraps
801073c0:	e9 df f5 ff ff       	jmp    801069a4 <alltraps>

801073c5 <vector111>:
.globl vector111
vector111:
  pushl $0
801073c5:	6a 00                	push   $0x0
  pushl $111
801073c7:	6a 6f                	push   $0x6f
  jmp alltraps
801073c9:	e9 d6 f5 ff ff       	jmp    801069a4 <alltraps>

801073ce <vector112>:
.globl vector112
vector112:
  pushl $0
801073ce:	6a 00                	push   $0x0
  pushl $112
801073d0:	6a 70                	push   $0x70
  jmp alltraps
801073d2:	e9 cd f5 ff ff       	jmp    801069a4 <alltraps>

801073d7 <vector113>:
.globl vector113
vector113:
  pushl $0
801073d7:	6a 00                	push   $0x0
  pushl $113
801073d9:	6a 71                	push   $0x71
  jmp alltraps
801073db:	e9 c4 f5 ff ff       	jmp    801069a4 <alltraps>

801073e0 <vector114>:
.globl vector114
vector114:
  pushl $0
801073e0:	6a 00                	push   $0x0
  pushl $114
801073e2:	6a 72                	push   $0x72
  jmp alltraps
801073e4:	e9 bb f5 ff ff       	jmp    801069a4 <alltraps>

801073e9 <vector115>:
.globl vector115
vector115:
  pushl $0
801073e9:	6a 00                	push   $0x0
  pushl $115
801073eb:	6a 73                	push   $0x73
  jmp alltraps
801073ed:	e9 b2 f5 ff ff       	jmp    801069a4 <alltraps>

801073f2 <vector116>:
.globl vector116
vector116:
  pushl $0
801073f2:	6a 00                	push   $0x0
  pushl $116
801073f4:	6a 74                	push   $0x74
  jmp alltraps
801073f6:	e9 a9 f5 ff ff       	jmp    801069a4 <alltraps>

801073fb <vector117>:
.globl vector117
vector117:
  pushl $0
801073fb:	6a 00                	push   $0x0
  pushl $117
801073fd:	6a 75                	push   $0x75
  jmp alltraps
801073ff:	e9 a0 f5 ff ff       	jmp    801069a4 <alltraps>

80107404 <vector118>:
.globl vector118
vector118:
  pushl $0
80107404:	6a 00                	push   $0x0
  pushl $118
80107406:	6a 76                	push   $0x76
  jmp alltraps
80107408:	e9 97 f5 ff ff       	jmp    801069a4 <alltraps>

8010740d <vector119>:
.globl vector119
vector119:
  pushl $0
8010740d:	6a 00                	push   $0x0
  pushl $119
8010740f:	6a 77                	push   $0x77
  jmp alltraps
80107411:	e9 8e f5 ff ff       	jmp    801069a4 <alltraps>

80107416 <vector120>:
.globl vector120
vector120:
  pushl $0
80107416:	6a 00                	push   $0x0
  pushl $120
80107418:	6a 78                	push   $0x78
  jmp alltraps
8010741a:	e9 85 f5 ff ff       	jmp    801069a4 <alltraps>

8010741f <vector121>:
.globl vector121
vector121:
  pushl $0
8010741f:	6a 00                	push   $0x0
  pushl $121
80107421:	6a 79                	push   $0x79
  jmp alltraps
80107423:	e9 7c f5 ff ff       	jmp    801069a4 <alltraps>

80107428 <vector122>:
.globl vector122
vector122:
  pushl $0
80107428:	6a 00                	push   $0x0
  pushl $122
8010742a:	6a 7a                	push   $0x7a
  jmp alltraps
8010742c:	e9 73 f5 ff ff       	jmp    801069a4 <alltraps>

80107431 <vector123>:
.globl vector123
vector123:
  pushl $0
80107431:	6a 00                	push   $0x0
  pushl $123
80107433:	6a 7b                	push   $0x7b
  jmp alltraps
80107435:	e9 6a f5 ff ff       	jmp    801069a4 <alltraps>

8010743a <vector124>:
.globl vector124
vector124:
  pushl $0
8010743a:	6a 00                	push   $0x0
  pushl $124
8010743c:	6a 7c                	push   $0x7c
  jmp alltraps
8010743e:	e9 61 f5 ff ff       	jmp    801069a4 <alltraps>

80107443 <vector125>:
.globl vector125
vector125:
  pushl $0
80107443:	6a 00                	push   $0x0
  pushl $125
80107445:	6a 7d                	push   $0x7d
  jmp alltraps
80107447:	e9 58 f5 ff ff       	jmp    801069a4 <alltraps>

8010744c <vector126>:
.globl vector126
vector126:
  pushl $0
8010744c:	6a 00                	push   $0x0
  pushl $126
8010744e:	6a 7e                	push   $0x7e
  jmp alltraps
80107450:	e9 4f f5 ff ff       	jmp    801069a4 <alltraps>

80107455 <vector127>:
.globl vector127
vector127:
  pushl $0
80107455:	6a 00                	push   $0x0
  pushl $127
80107457:	6a 7f                	push   $0x7f
  jmp alltraps
80107459:	e9 46 f5 ff ff       	jmp    801069a4 <alltraps>

8010745e <vector128>:
.globl vector128
vector128:
  pushl $0
8010745e:	6a 00                	push   $0x0
  pushl $128
80107460:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107465:	e9 3a f5 ff ff       	jmp    801069a4 <alltraps>

8010746a <vector129>:
.globl vector129
vector129:
  pushl $0
8010746a:	6a 00                	push   $0x0
  pushl $129
8010746c:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107471:	e9 2e f5 ff ff       	jmp    801069a4 <alltraps>

80107476 <vector130>:
.globl vector130
vector130:
  pushl $0
80107476:	6a 00                	push   $0x0
  pushl $130
80107478:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010747d:	e9 22 f5 ff ff       	jmp    801069a4 <alltraps>

80107482 <vector131>:
.globl vector131
vector131:
  pushl $0
80107482:	6a 00                	push   $0x0
  pushl $131
80107484:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107489:	e9 16 f5 ff ff       	jmp    801069a4 <alltraps>

8010748e <vector132>:
.globl vector132
vector132:
  pushl $0
8010748e:	6a 00                	push   $0x0
  pushl $132
80107490:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107495:	e9 0a f5 ff ff       	jmp    801069a4 <alltraps>

8010749a <vector133>:
.globl vector133
vector133:
  pushl $0
8010749a:	6a 00                	push   $0x0
  pushl $133
8010749c:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801074a1:	e9 fe f4 ff ff       	jmp    801069a4 <alltraps>

801074a6 <vector134>:
.globl vector134
vector134:
  pushl $0
801074a6:	6a 00                	push   $0x0
  pushl $134
801074a8:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801074ad:	e9 f2 f4 ff ff       	jmp    801069a4 <alltraps>

801074b2 <vector135>:
.globl vector135
vector135:
  pushl $0
801074b2:	6a 00                	push   $0x0
  pushl $135
801074b4:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801074b9:	e9 e6 f4 ff ff       	jmp    801069a4 <alltraps>

801074be <vector136>:
.globl vector136
vector136:
  pushl $0
801074be:	6a 00                	push   $0x0
  pushl $136
801074c0:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801074c5:	e9 da f4 ff ff       	jmp    801069a4 <alltraps>

801074ca <vector137>:
.globl vector137
vector137:
  pushl $0
801074ca:	6a 00                	push   $0x0
  pushl $137
801074cc:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801074d1:	e9 ce f4 ff ff       	jmp    801069a4 <alltraps>

801074d6 <vector138>:
.globl vector138
vector138:
  pushl $0
801074d6:	6a 00                	push   $0x0
  pushl $138
801074d8:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801074dd:	e9 c2 f4 ff ff       	jmp    801069a4 <alltraps>

801074e2 <vector139>:
.globl vector139
vector139:
  pushl $0
801074e2:	6a 00                	push   $0x0
  pushl $139
801074e4:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801074e9:	e9 b6 f4 ff ff       	jmp    801069a4 <alltraps>

801074ee <vector140>:
.globl vector140
vector140:
  pushl $0
801074ee:	6a 00                	push   $0x0
  pushl $140
801074f0:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801074f5:	e9 aa f4 ff ff       	jmp    801069a4 <alltraps>

801074fa <vector141>:
.globl vector141
vector141:
  pushl $0
801074fa:	6a 00                	push   $0x0
  pushl $141
801074fc:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107501:	e9 9e f4 ff ff       	jmp    801069a4 <alltraps>

80107506 <vector142>:
.globl vector142
vector142:
  pushl $0
80107506:	6a 00                	push   $0x0
  pushl $142
80107508:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010750d:	e9 92 f4 ff ff       	jmp    801069a4 <alltraps>

80107512 <vector143>:
.globl vector143
vector143:
  pushl $0
80107512:	6a 00                	push   $0x0
  pushl $143
80107514:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107519:	e9 86 f4 ff ff       	jmp    801069a4 <alltraps>

8010751e <vector144>:
.globl vector144
vector144:
  pushl $0
8010751e:	6a 00                	push   $0x0
  pushl $144
80107520:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107525:	e9 7a f4 ff ff       	jmp    801069a4 <alltraps>

8010752a <vector145>:
.globl vector145
vector145:
  pushl $0
8010752a:	6a 00                	push   $0x0
  pushl $145
8010752c:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107531:	e9 6e f4 ff ff       	jmp    801069a4 <alltraps>

80107536 <vector146>:
.globl vector146
vector146:
  pushl $0
80107536:	6a 00                	push   $0x0
  pushl $146
80107538:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010753d:	e9 62 f4 ff ff       	jmp    801069a4 <alltraps>

80107542 <vector147>:
.globl vector147
vector147:
  pushl $0
80107542:	6a 00                	push   $0x0
  pushl $147
80107544:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107549:	e9 56 f4 ff ff       	jmp    801069a4 <alltraps>

8010754e <vector148>:
.globl vector148
vector148:
  pushl $0
8010754e:	6a 00                	push   $0x0
  pushl $148
80107550:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107555:	e9 4a f4 ff ff       	jmp    801069a4 <alltraps>

8010755a <vector149>:
.globl vector149
vector149:
  pushl $0
8010755a:	6a 00                	push   $0x0
  pushl $149
8010755c:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107561:	e9 3e f4 ff ff       	jmp    801069a4 <alltraps>

80107566 <vector150>:
.globl vector150
vector150:
  pushl $0
80107566:	6a 00                	push   $0x0
  pushl $150
80107568:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010756d:	e9 32 f4 ff ff       	jmp    801069a4 <alltraps>

80107572 <vector151>:
.globl vector151
vector151:
  pushl $0
80107572:	6a 00                	push   $0x0
  pushl $151
80107574:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107579:	e9 26 f4 ff ff       	jmp    801069a4 <alltraps>

8010757e <vector152>:
.globl vector152
vector152:
  pushl $0
8010757e:	6a 00                	push   $0x0
  pushl $152
80107580:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107585:	e9 1a f4 ff ff       	jmp    801069a4 <alltraps>

8010758a <vector153>:
.globl vector153
vector153:
  pushl $0
8010758a:	6a 00                	push   $0x0
  pushl $153
8010758c:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107591:	e9 0e f4 ff ff       	jmp    801069a4 <alltraps>

80107596 <vector154>:
.globl vector154
vector154:
  pushl $0
80107596:	6a 00                	push   $0x0
  pushl $154
80107598:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010759d:	e9 02 f4 ff ff       	jmp    801069a4 <alltraps>

801075a2 <vector155>:
.globl vector155
vector155:
  pushl $0
801075a2:	6a 00                	push   $0x0
  pushl $155
801075a4:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801075a9:	e9 f6 f3 ff ff       	jmp    801069a4 <alltraps>

801075ae <vector156>:
.globl vector156
vector156:
  pushl $0
801075ae:	6a 00                	push   $0x0
  pushl $156
801075b0:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801075b5:	e9 ea f3 ff ff       	jmp    801069a4 <alltraps>

801075ba <vector157>:
.globl vector157
vector157:
  pushl $0
801075ba:	6a 00                	push   $0x0
  pushl $157
801075bc:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801075c1:	e9 de f3 ff ff       	jmp    801069a4 <alltraps>

801075c6 <vector158>:
.globl vector158
vector158:
  pushl $0
801075c6:	6a 00                	push   $0x0
  pushl $158
801075c8:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801075cd:	e9 d2 f3 ff ff       	jmp    801069a4 <alltraps>

801075d2 <vector159>:
.globl vector159
vector159:
  pushl $0
801075d2:	6a 00                	push   $0x0
  pushl $159
801075d4:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801075d9:	e9 c6 f3 ff ff       	jmp    801069a4 <alltraps>

801075de <vector160>:
.globl vector160
vector160:
  pushl $0
801075de:	6a 00                	push   $0x0
  pushl $160
801075e0:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801075e5:	e9 ba f3 ff ff       	jmp    801069a4 <alltraps>

801075ea <vector161>:
.globl vector161
vector161:
  pushl $0
801075ea:	6a 00                	push   $0x0
  pushl $161
801075ec:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801075f1:	e9 ae f3 ff ff       	jmp    801069a4 <alltraps>

801075f6 <vector162>:
.globl vector162
vector162:
  pushl $0
801075f6:	6a 00                	push   $0x0
  pushl $162
801075f8:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801075fd:	e9 a2 f3 ff ff       	jmp    801069a4 <alltraps>

80107602 <vector163>:
.globl vector163
vector163:
  pushl $0
80107602:	6a 00                	push   $0x0
  pushl $163
80107604:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107609:	e9 96 f3 ff ff       	jmp    801069a4 <alltraps>

8010760e <vector164>:
.globl vector164
vector164:
  pushl $0
8010760e:	6a 00                	push   $0x0
  pushl $164
80107610:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107615:	e9 8a f3 ff ff       	jmp    801069a4 <alltraps>

8010761a <vector165>:
.globl vector165
vector165:
  pushl $0
8010761a:	6a 00                	push   $0x0
  pushl $165
8010761c:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107621:	e9 7e f3 ff ff       	jmp    801069a4 <alltraps>

80107626 <vector166>:
.globl vector166
vector166:
  pushl $0
80107626:	6a 00                	push   $0x0
  pushl $166
80107628:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010762d:	e9 72 f3 ff ff       	jmp    801069a4 <alltraps>

80107632 <vector167>:
.globl vector167
vector167:
  pushl $0
80107632:	6a 00                	push   $0x0
  pushl $167
80107634:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107639:	e9 66 f3 ff ff       	jmp    801069a4 <alltraps>

8010763e <vector168>:
.globl vector168
vector168:
  pushl $0
8010763e:	6a 00                	push   $0x0
  pushl $168
80107640:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107645:	e9 5a f3 ff ff       	jmp    801069a4 <alltraps>

8010764a <vector169>:
.globl vector169
vector169:
  pushl $0
8010764a:	6a 00                	push   $0x0
  pushl $169
8010764c:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107651:	e9 4e f3 ff ff       	jmp    801069a4 <alltraps>

80107656 <vector170>:
.globl vector170
vector170:
  pushl $0
80107656:	6a 00                	push   $0x0
  pushl $170
80107658:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010765d:	e9 42 f3 ff ff       	jmp    801069a4 <alltraps>

80107662 <vector171>:
.globl vector171
vector171:
  pushl $0
80107662:	6a 00                	push   $0x0
  pushl $171
80107664:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107669:	e9 36 f3 ff ff       	jmp    801069a4 <alltraps>

8010766e <vector172>:
.globl vector172
vector172:
  pushl $0
8010766e:	6a 00                	push   $0x0
  pushl $172
80107670:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107675:	e9 2a f3 ff ff       	jmp    801069a4 <alltraps>

8010767a <vector173>:
.globl vector173
vector173:
  pushl $0
8010767a:	6a 00                	push   $0x0
  pushl $173
8010767c:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107681:	e9 1e f3 ff ff       	jmp    801069a4 <alltraps>

80107686 <vector174>:
.globl vector174
vector174:
  pushl $0
80107686:	6a 00                	push   $0x0
  pushl $174
80107688:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010768d:	e9 12 f3 ff ff       	jmp    801069a4 <alltraps>

80107692 <vector175>:
.globl vector175
vector175:
  pushl $0
80107692:	6a 00                	push   $0x0
  pushl $175
80107694:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107699:	e9 06 f3 ff ff       	jmp    801069a4 <alltraps>

8010769e <vector176>:
.globl vector176
vector176:
  pushl $0
8010769e:	6a 00                	push   $0x0
  pushl $176
801076a0:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801076a5:	e9 fa f2 ff ff       	jmp    801069a4 <alltraps>

801076aa <vector177>:
.globl vector177
vector177:
  pushl $0
801076aa:	6a 00                	push   $0x0
  pushl $177
801076ac:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801076b1:	e9 ee f2 ff ff       	jmp    801069a4 <alltraps>

801076b6 <vector178>:
.globl vector178
vector178:
  pushl $0
801076b6:	6a 00                	push   $0x0
  pushl $178
801076b8:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801076bd:	e9 e2 f2 ff ff       	jmp    801069a4 <alltraps>

801076c2 <vector179>:
.globl vector179
vector179:
  pushl $0
801076c2:	6a 00                	push   $0x0
  pushl $179
801076c4:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801076c9:	e9 d6 f2 ff ff       	jmp    801069a4 <alltraps>

801076ce <vector180>:
.globl vector180
vector180:
  pushl $0
801076ce:	6a 00                	push   $0x0
  pushl $180
801076d0:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801076d5:	e9 ca f2 ff ff       	jmp    801069a4 <alltraps>

801076da <vector181>:
.globl vector181
vector181:
  pushl $0
801076da:	6a 00                	push   $0x0
  pushl $181
801076dc:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801076e1:	e9 be f2 ff ff       	jmp    801069a4 <alltraps>

801076e6 <vector182>:
.globl vector182
vector182:
  pushl $0
801076e6:	6a 00                	push   $0x0
  pushl $182
801076e8:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801076ed:	e9 b2 f2 ff ff       	jmp    801069a4 <alltraps>

801076f2 <vector183>:
.globl vector183
vector183:
  pushl $0
801076f2:	6a 00                	push   $0x0
  pushl $183
801076f4:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801076f9:	e9 a6 f2 ff ff       	jmp    801069a4 <alltraps>

801076fe <vector184>:
.globl vector184
vector184:
  pushl $0
801076fe:	6a 00                	push   $0x0
  pushl $184
80107700:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107705:	e9 9a f2 ff ff       	jmp    801069a4 <alltraps>

8010770a <vector185>:
.globl vector185
vector185:
  pushl $0
8010770a:	6a 00                	push   $0x0
  pushl $185
8010770c:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107711:	e9 8e f2 ff ff       	jmp    801069a4 <alltraps>

80107716 <vector186>:
.globl vector186
vector186:
  pushl $0
80107716:	6a 00                	push   $0x0
  pushl $186
80107718:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010771d:	e9 82 f2 ff ff       	jmp    801069a4 <alltraps>

80107722 <vector187>:
.globl vector187
vector187:
  pushl $0
80107722:	6a 00                	push   $0x0
  pushl $187
80107724:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107729:	e9 76 f2 ff ff       	jmp    801069a4 <alltraps>

8010772e <vector188>:
.globl vector188
vector188:
  pushl $0
8010772e:	6a 00                	push   $0x0
  pushl $188
80107730:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107735:	e9 6a f2 ff ff       	jmp    801069a4 <alltraps>

8010773a <vector189>:
.globl vector189
vector189:
  pushl $0
8010773a:	6a 00                	push   $0x0
  pushl $189
8010773c:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107741:	e9 5e f2 ff ff       	jmp    801069a4 <alltraps>

80107746 <vector190>:
.globl vector190
vector190:
  pushl $0
80107746:	6a 00                	push   $0x0
  pushl $190
80107748:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010774d:	e9 52 f2 ff ff       	jmp    801069a4 <alltraps>

80107752 <vector191>:
.globl vector191
vector191:
  pushl $0
80107752:	6a 00                	push   $0x0
  pushl $191
80107754:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107759:	e9 46 f2 ff ff       	jmp    801069a4 <alltraps>

8010775e <vector192>:
.globl vector192
vector192:
  pushl $0
8010775e:	6a 00                	push   $0x0
  pushl $192
80107760:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107765:	e9 3a f2 ff ff       	jmp    801069a4 <alltraps>

8010776a <vector193>:
.globl vector193
vector193:
  pushl $0
8010776a:	6a 00                	push   $0x0
  pushl $193
8010776c:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107771:	e9 2e f2 ff ff       	jmp    801069a4 <alltraps>

80107776 <vector194>:
.globl vector194
vector194:
  pushl $0
80107776:	6a 00                	push   $0x0
  pushl $194
80107778:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010777d:	e9 22 f2 ff ff       	jmp    801069a4 <alltraps>

80107782 <vector195>:
.globl vector195
vector195:
  pushl $0
80107782:	6a 00                	push   $0x0
  pushl $195
80107784:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107789:	e9 16 f2 ff ff       	jmp    801069a4 <alltraps>

8010778e <vector196>:
.globl vector196
vector196:
  pushl $0
8010778e:	6a 00                	push   $0x0
  pushl $196
80107790:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107795:	e9 0a f2 ff ff       	jmp    801069a4 <alltraps>

8010779a <vector197>:
.globl vector197
vector197:
  pushl $0
8010779a:	6a 00                	push   $0x0
  pushl $197
8010779c:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801077a1:	e9 fe f1 ff ff       	jmp    801069a4 <alltraps>

801077a6 <vector198>:
.globl vector198
vector198:
  pushl $0
801077a6:	6a 00                	push   $0x0
  pushl $198
801077a8:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801077ad:	e9 f2 f1 ff ff       	jmp    801069a4 <alltraps>

801077b2 <vector199>:
.globl vector199
vector199:
  pushl $0
801077b2:	6a 00                	push   $0x0
  pushl $199
801077b4:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801077b9:	e9 e6 f1 ff ff       	jmp    801069a4 <alltraps>

801077be <vector200>:
.globl vector200
vector200:
  pushl $0
801077be:	6a 00                	push   $0x0
  pushl $200
801077c0:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801077c5:	e9 da f1 ff ff       	jmp    801069a4 <alltraps>

801077ca <vector201>:
.globl vector201
vector201:
  pushl $0
801077ca:	6a 00                	push   $0x0
  pushl $201
801077cc:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801077d1:	e9 ce f1 ff ff       	jmp    801069a4 <alltraps>

801077d6 <vector202>:
.globl vector202
vector202:
  pushl $0
801077d6:	6a 00                	push   $0x0
  pushl $202
801077d8:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801077dd:	e9 c2 f1 ff ff       	jmp    801069a4 <alltraps>

801077e2 <vector203>:
.globl vector203
vector203:
  pushl $0
801077e2:	6a 00                	push   $0x0
  pushl $203
801077e4:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801077e9:	e9 b6 f1 ff ff       	jmp    801069a4 <alltraps>

801077ee <vector204>:
.globl vector204
vector204:
  pushl $0
801077ee:	6a 00                	push   $0x0
  pushl $204
801077f0:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801077f5:	e9 aa f1 ff ff       	jmp    801069a4 <alltraps>

801077fa <vector205>:
.globl vector205
vector205:
  pushl $0
801077fa:	6a 00                	push   $0x0
  pushl $205
801077fc:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107801:	e9 9e f1 ff ff       	jmp    801069a4 <alltraps>

80107806 <vector206>:
.globl vector206
vector206:
  pushl $0
80107806:	6a 00                	push   $0x0
  pushl $206
80107808:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
8010780d:	e9 92 f1 ff ff       	jmp    801069a4 <alltraps>

80107812 <vector207>:
.globl vector207
vector207:
  pushl $0
80107812:	6a 00                	push   $0x0
  pushl $207
80107814:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107819:	e9 86 f1 ff ff       	jmp    801069a4 <alltraps>

8010781e <vector208>:
.globl vector208
vector208:
  pushl $0
8010781e:	6a 00                	push   $0x0
  pushl $208
80107820:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107825:	e9 7a f1 ff ff       	jmp    801069a4 <alltraps>

8010782a <vector209>:
.globl vector209
vector209:
  pushl $0
8010782a:	6a 00                	push   $0x0
  pushl $209
8010782c:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107831:	e9 6e f1 ff ff       	jmp    801069a4 <alltraps>

80107836 <vector210>:
.globl vector210
vector210:
  pushl $0
80107836:	6a 00                	push   $0x0
  pushl $210
80107838:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
8010783d:	e9 62 f1 ff ff       	jmp    801069a4 <alltraps>

80107842 <vector211>:
.globl vector211
vector211:
  pushl $0
80107842:	6a 00                	push   $0x0
  pushl $211
80107844:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107849:	e9 56 f1 ff ff       	jmp    801069a4 <alltraps>

8010784e <vector212>:
.globl vector212
vector212:
  pushl $0
8010784e:	6a 00                	push   $0x0
  pushl $212
80107850:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107855:	e9 4a f1 ff ff       	jmp    801069a4 <alltraps>

8010785a <vector213>:
.globl vector213
vector213:
  pushl $0
8010785a:	6a 00                	push   $0x0
  pushl $213
8010785c:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107861:	e9 3e f1 ff ff       	jmp    801069a4 <alltraps>

80107866 <vector214>:
.globl vector214
vector214:
  pushl $0
80107866:	6a 00                	push   $0x0
  pushl $214
80107868:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
8010786d:	e9 32 f1 ff ff       	jmp    801069a4 <alltraps>

80107872 <vector215>:
.globl vector215
vector215:
  pushl $0
80107872:	6a 00                	push   $0x0
  pushl $215
80107874:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107879:	e9 26 f1 ff ff       	jmp    801069a4 <alltraps>

8010787e <vector216>:
.globl vector216
vector216:
  pushl $0
8010787e:	6a 00                	push   $0x0
  pushl $216
80107880:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107885:	e9 1a f1 ff ff       	jmp    801069a4 <alltraps>

8010788a <vector217>:
.globl vector217
vector217:
  pushl $0
8010788a:	6a 00                	push   $0x0
  pushl $217
8010788c:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107891:	e9 0e f1 ff ff       	jmp    801069a4 <alltraps>

80107896 <vector218>:
.globl vector218
vector218:
  pushl $0
80107896:	6a 00                	push   $0x0
  pushl $218
80107898:	68 da 00 00 00       	push   $0xda
  jmp alltraps
8010789d:	e9 02 f1 ff ff       	jmp    801069a4 <alltraps>

801078a2 <vector219>:
.globl vector219
vector219:
  pushl $0
801078a2:	6a 00                	push   $0x0
  pushl $219
801078a4:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801078a9:	e9 f6 f0 ff ff       	jmp    801069a4 <alltraps>

801078ae <vector220>:
.globl vector220
vector220:
  pushl $0
801078ae:	6a 00                	push   $0x0
  pushl $220
801078b0:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
801078b5:	e9 ea f0 ff ff       	jmp    801069a4 <alltraps>

801078ba <vector221>:
.globl vector221
vector221:
  pushl $0
801078ba:	6a 00                	push   $0x0
  pushl $221
801078bc:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
801078c1:	e9 de f0 ff ff       	jmp    801069a4 <alltraps>

801078c6 <vector222>:
.globl vector222
vector222:
  pushl $0
801078c6:	6a 00                	push   $0x0
  pushl $222
801078c8:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801078cd:	e9 d2 f0 ff ff       	jmp    801069a4 <alltraps>

801078d2 <vector223>:
.globl vector223
vector223:
  pushl $0
801078d2:	6a 00                	push   $0x0
  pushl $223
801078d4:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801078d9:	e9 c6 f0 ff ff       	jmp    801069a4 <alltraps>

801078de <vector224>:
.globl vector224
vector224:
  pushl $0
801078de:	6a 00                	push   $0x0
  pushl $224
801078e0:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801078e5:	e9 ba f0 ff ff       	jmp    801069a4 <alltraps>

801078ea <vector225>:
.globl vector225
vector225:
  pushl $0
801078ea:	6a 00                	push   $0x0
  pushl $225
801078ec:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801078f1:	e9 ae f0 ff ff       	jmp    801069a4 <alltraps>

801078f6 <vector226>:
.globl vector226
vector226:
  pushl $0
801078f6:	6a 00                	push   $0x0
  pushl $226
801078f8:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801078fd:	e9 a2 f0 ff ff       	jmp    801069a4 <alltraps>

80107902 <vector227>:
.globl vector227
vector227:
  pushl $0
80107902:	6a 00                	push   $0x0
  pushl $227
80107904:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107909:	e9 96 f0 ff ff       	jmp    801069a4 <alltraps>

8010790e <vector228>:
.globl vector228
vector228:
  pushl $0
8010790e:	6a 00                	push   $0x0
  pushl $228
80107910:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107915:	e9 8a f0 ff ff       	jmp    801069a4 <alltraps>

8010791a <vector229>:
.globl vector229
vector229:
  pushl $0
8010791a:	6a 00                	push   $0x0
  pushl $229
8010791c:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107921:	e9 7e f0 ff ff       	jmp    801069a4 <alltraps>

80107926 <vector230>:
.globl vector230
vector230:
  pushl $0
80107926:	6a 00                	push   $0x0
  pushl $230
80107928:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
8010792d:	e9 72 f0 ff ff       	jmp    801069a4 <alltraps>

80107932 <vector231>:
.globl vector231
vector231:
  pushl $0
80107932:	6a 00                	push   $0x0
  pushl $231
80107934:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107939:	e9 66 f0 ff ff       	jmp    801069a4 <alltraps>

8010793e <vector232>:
.globl vector232
vector232:
  pushl $0
8010793e:	6a 00                	push   $0x0
  pushl $232
80107940:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107945:	e9 5a f0 ff ff       	jmp    801069a4 <alltraps>

8010794a <vector233>:
.globl vector233
vector233:
  pushl $0
8010794a:	6a 00                	push   $0x0
  pushl $233
8010794c:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107951:	e9 4e f0 ff ff       	jmp    801069a4 <alltraps>

80107956 <vector234>:
.globl vector234
vector234:
  pushl $0
80107956:	6a 00                	push   $0x0
  pushl $234
80107958:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
8010795d:	e9 42 f0 ff ff       	jmp    801069a4 <alltraps>

80107962 <vector235>:
.globl vector235
vector235:
  pushl $0
80107962:	6a 00                	push   $0x0
  pushl $235
80107964:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107969:	e9 36 f0 ff ff       	jmp    801069a4 <alltraps>

8010796e <vector236>:
.globl vector236
vector236:
  pushl $0
8010796e:	6a 00                	push   $0x0
  pushl $236
80107970:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107975:	e9 2a f0 ff ff       	jmp    801069a4 <alltraps>

8010797a <vector237>:
.globl vector237
vector237:
  pushl $0
8010797a:	6a 00                	push   $0x0
  pushl $237
8010797c:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107981:	e9 1e f0 ff ff       	jmp    801069a4 <alltraps>

80107986 <vector238>:
.globl vector238
vector238:
  pushl $0
80107986:	6a 00                	push   $0x0
  pushl $238
80107988:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
8010798d:	e9 12 f0 ff ff       	jmp    801069a4 <alltraps>

80107992 <vector239>:
.globl vector239
vector239:
  pushl $0
80107992:	6a 00                	push   $0x0
  pushl $239
80107994:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107999:	e9 06 f0 ff ff       	jmp    801069a4 <alltraps>

8010799e <vector240>:
.globl vector240
vector240:
  pushl $0
8010799e:	6a 00                	push   $0x0
  pushl $240
801079a0:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801079a5:	e9 fa ef ff ff       	jmp    801069a4 <alltraps>

801079aa <vector241>:
.globl vector241
vector241:
  pushl $0
801079aa:	6a 00                	push   $0x0
  pushl $241
801079ac:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801079b1:	e9 ee ef ff ff       	jmp    801069a4 <alltraps>

801079b6 <vector242>:
.globl vector242
vector242:
  pushl $0
801079b6:	6a 00                	push   $0x0
  pushl $242
801079b8:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
801079bd:	e9 e2 ef ff ff       	jmp    801069a4 <alltraps>

801079c2 <vector243>:
.globl vector243
vector243:
  pushl $0
801079c2:	6a 00                	push   $0x0
  pushl $243
801079c4:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
801079c9:	e9 d6 ef ff ff       	jmp    801069a4 <alltraps>

801079ce <vector244>:
.globl vector244
vector244:
  pushl $0
801079ce:	6a 00                	push   $0x0
  pushl $244
801079d0:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801079d5:	e9 ca ef ff ff       	jmp    801069a4 <alltraps>

801079da <vector245>:
.globl vector245
vector245:
  pushl $0
801079da:	6a 00                	push   $0x0
  pushl $245
801079dc:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801079e1:	e9 be ef ff ff       	jmp    801069a4 <alltraps>

801079e6 <vector246>:
.globl vector246
vector246:
  pushl $0
801079e6:	6a 00                	push   $0x0
  pushl $246
801079e8:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801079ed:	e9 b2 ef ff ff       	jmp    801069a4 <alltraps>

801079f2 <vector247>:
.globl vector247
vector247:
  pushl $0
801079f2:	6a 00                	push   $0x0
  pushl $247
801079f4:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801079f9:	e9 a6 ef ff ff       	jmp    801069a4 <alltraps>

801079fe <vector248>:
.globl vector248
vector248:
  pushl $0
801079fe:	6a 00                	push   $0x0
  pushl $248
80107a00:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107a05:	e9 9a ef ff ff       	jmp    801069a4 <alltraps>

80107a0a <vector249>:
.globl vector249
vector249:
  pushl $0
80107a0a:	6a 00                	push   $0x0
  pushl $249
80107a0c:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107a11:	e9 8e ef ff ff       	jmp    801069a4 <alltraps>

80107a16 <vector250>:
.globl vector250
vector250:
  pushl $0
80107a16:	6a 00                	push   $0x0
  pushl $250
80107a18:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107a1d:	e9 82 ef ff ff       	jmp    801069a4 <alltraps>

80107a22 <vector251>:
.globl vector251
vector251:
  pushl $0
80107a22:	6a 00                	push   $0x0
  pushl $251
80107a24:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107a29:	e9 76 ef ff ff       	jmp    801069a4 <alltraps>

80107a2e <vector252>:
.globl vector252
vector252:
  pushl $0
80107a2e:	6a 00                	push   $0x0
  pushl $252
80107a30:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107a35:	e9 6a ef ff ff       	jmp    801069a4 <alltraps>

80107a3a <vector253>:
.globl vector253
vector253:
  pushl $0
80107a3a:	6a 00                	push   $0x0
  pushl $253
80107a3c:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107a41:	e9 5e ef ff ff       	jmp    801069a4 <alltraps>

80107a46 <vector254>:
.globl vector254
vector254:
  pushl $0
80107a46:	6a 00                	push   $0x0
  pushl $254
80107a48:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107a4d:	e9 52 ef ff ff       	jmp    801069a4 <alltraps>

80107a52 <vector255>:
.globl vector255
vector255:
  pushl $0
80107a52:	6a 00                	push   $0x0
  pushl $255
80107a54:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107a59:	e9 46 ef ff ff       	jmp    801069a4 <alltraps>
	...

80107a60 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107a60:	55                   	push   %ebp
80107a61:	89 e5                	mov    %esp,%ebp
80107a63:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107a66:	8b 45 0c             	mov    0xc(%ebp),%eax
80107a69:	48                   	dec    %eax
80107a6a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107a6e:	8b 45 08             	mov    0x8(%ebp),%eax
80107a71:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107a75:	8b 45 08             	mov    0x8(%ebp),%eax
80107a78:	c1 e8 10             	shr    $0x10,%eax
80107a7b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107a7f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107a82:	0f 01 10             	lgdtl  (%eax)
}
80107a85:	c9                   	leave  
80107a86:	c3                   	ret    

80107a87 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107a87:	55                   	push   %ebp
80107a88:	89 e5                	mov    %esp,%ebp
80107a8a:	83 ec 04             	sub    $0x4,%esp
80107a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80107a90:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107a94:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107a97:	0f 00 d8             	ltr    %ax
}
80107a9a:	c9                   	leave  
80107a9b:	c3                   	ret    

80107a9c <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80107a9c:	55                   	push   %ebp
80107a9d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107a9f:	8b 45 08             	mov    0x8(%ebp),%eax
80107aa2:	0f 22 d8             	mov    %eax,%cr3
}
80107aa5:	5d                   	pop    %ebp
80107aa6:	c3                   	ret    

80107aa7 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107aa7:	55                   	push   %ebp
80107aa8:	89 e5                	mov    %esp,%ebp
80107aaa:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107aad:	e8 a4 c6 ff ff       	call   80104156 <cpuid>
80107ab2:	89 c2                	mov    %eax,%edx
80107ab4:	89 d0                	mov    %edx,%eax
80107ab6:	c1 e0 02             	shl    $0x2,%eax
80107ab9:	01 d0                	add    %edx,%eax
80107abb:	01 c0                	add    %eax,%eax
80107abd:	01 d0                	add    %edx,%eax
80107abf:	c1 e0 04             	shl    $0x4,%eax
80107ac2:	05 60 39 11 80       	add    $0x80113960,%eax
80107ac7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107aca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107acd:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107ad3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad6:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107adc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107adf:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae6:	8a 50 7d             	mov    0x7d(%eax),%dl
80107ae9:	83 e2 f0             	and    $0xfffffff0,%edx
80107aec:	83 ca 0a             	or     $0xa,%edx
80107aef:	88 50 7d             	mov    %dl,0x7d(%eax)
80107af2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107af5:	8a 50 7d             	mov    0x7d(%eax),%dl
80107af8:	83 ca 10             	or     $0x10,%edx
80107afb:	88 50 7d             	mov    %dl,0x7d(%eax)
80107afe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b01:	8a 50 7d             	mov    0x7d(%eax),%dl
80107b04:	83 e2 9f             	and    $0xffffff9f,%edx
80107b07:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b0d:	8a 50 7d             	mov    0x7d(%eax),%dl
80107b10:	83 ca 80             	or     $0xffffff80,%edx
80107b13:	88 50 7d             	mov    %dl,0x7d(%eax)
80107b16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b19:	8a 50 7e             	mov    0x7e(%eax),%dl
80107b1c:	83 ca 0f             	or     $0xf,%edx
80107b1f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b25:	8a 50 7e             	mov    0x7e(%eax),%dl
80107b28:	83 e2 ef             	and    $0xffffffef,%edx
80107b2b:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b31:	8a 50 7e             	mov    0x7e(%eax),%dl
80107b34:	83 e2 df             	and    $0xffffffdf,%edx
80107b37:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b3d:	8a 50 7e             	mov    0x7e(%eax),%dl
80107b40:	83 ca 40             	or     $0x40,%edx
80107b43:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b49:	8a 50 7e             	mov    0x7e(%eax),%dl
80107b4c:	83 ca 80             	or     $0xffffff80,%edx
80107b4f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b55:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107b59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b5c:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107b63:	ff ff 
80107b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b68:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107b6f:	00 00 
80107b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b74:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b7e:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107b84:	83 e2 f0             	and    $0xfffffff0,%edx
80107b87:	83 ca 02             	or     $0x2,%edx
80107b8a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b93:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107b99:	83 ca 10             	or     $0x10,%edx
80107b9c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ba2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ba5:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107bab:	83 e2 9f             	and    $0xffffff9f,%edx
80107bae:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb7:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80107bbd:	83 ca 80             	or     $0xffffff80,%edx
80107bc0:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc9:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107bcf:	83 ca 0f             	or     $0xf,%edx
80107bd2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bdb:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107be1:	83 e2 ef             	and    $0xffffffef,%edx
80107be4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bed:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107bf3:	83 e2 df             	and    $0xffffffdf,%edx
80107bf6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bff:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107c05:	83 ca 40             	or     $0x40,%edx
80107c08:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c11:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80107c17:	83 ca 80             	or     $0xffffff80,%edx
80107c1a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c23:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c2d:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80107c34:	ff ff 
80107c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c39:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107c40:	00 00 
80107c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c45:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107c4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c4f:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107c55:	83 e2 f0             	and    $0xfffffff0,%edx
80107c58:	83 ca 0a             	or     $0xa,%edx
80107c5b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c64:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107c6a:	83 ca 10             	or     $0x10,%edx
80107c6d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c76:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107c7c:	83 ca 60             	or     $0x60,%edx
80107c7f:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c88:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80107c8e:	83 ca 80             	or     $0xffffff80,%edx
80107c91:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9a:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107ca0:	83 ca 0f             	or     $0xf,%edx
80107ca3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cac:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107cb2:	83 e2 ef             	and    $0xffffffef,%edx
80107cb5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cbe:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107cc4:	83 e2 df             	and    $0xffffffdf,%edx
80107cc7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd0:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107cd6:	83 ca 40             	or     $0x40,%edx
80107cd9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107cdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ce2:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80107ce8:	83 ca 80             	or     $0xffffff80,%edx
80107ceb:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf4:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfe:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107d05:	ff ff 
80107d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0a:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107d11:	00 00 
80107d13:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d16:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107d1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d20:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107d26:	83 e2 f0             	and    $0xfffffff0,%edx
80107d29:	83 ca 02             	or     $0x2,%edx
80107d2c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d35:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107d3b:	83 ca 10             	or     $0x10,%edx
80107d3e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d47:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107d4d:	83 ca 60             	or     $0x60,%edx
80107d50:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d59:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80107d5f:	83 ca 80             	or     $0xffffff80,%edx
80107d62:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d6b:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107d71:	83 ca 0f             	or     $0xf,%edx
80107d74:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d7d:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107d83:	83 e2 ef             	and    $0xffffffef,%edx
80107d86:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d8f:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107d95:	83 e2 df             	and    $0xffffffdf,%edx
80107d98:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107d9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107da1:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107da7:	83 ca 40             	or     $0x40,%edx
80107daa:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107db3:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80107db9:	83 ca 80             	or     $0xffffff80,%edx
80107dbc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107dc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dc5:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80107dcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dcf:	83 c0 70             	add    $0x70,%eax
80107dd2:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80107dd9:	00 
80107dda:	89 04 24             	mov    %eax,(%esp)
80107ddd:	e8 7e fc ff ff       	call   80107a60 <lgdt>
}
80107de2:	c9                   	leave  
80107de3:	c3                   	ret    

80107de4 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107de4:	55                   	push   %ebp
80107de5:	89 e5                	mov    %esp,%ebp
80107de7:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107dea:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ded:	c1 e8 16             	shr    $0x16,%eax
80107df0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107df7:	8b 45 08             	mov    0x8(%ebp),%eax
80107dfa:	01 d0                	add    %edx,%eax
80107dfc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107dff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e02:	8b 00                	mov    (%eax),%eax
80107e04:	83 e0 01             	and    $0x1,%eax
80107e07:	85 c0                	test   %eax,%eax
80107e09:	74 14                	je     80107e1f <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107e0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e0e:	8b 00                	mov    (%eax),%eax
80107e10:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e15:	05 00 00 00 80       	add    $0x80000000,%eax
80107e1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e1d:	eb 48                	jmp    80107e67 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107e1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107e23:	74 0e                	je     80107e33 <walkpgdir+0x4f>
80107e25:	e8 2d ae ff ff       	call   80102c57 <kalloc>
80107e2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e2d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e31:	75 07                	jne    80107e3a <walkpgdir+0x56>
      return 0;
80107e33:	b8 00 00 00 00       	mov    $0x0,%eax
80107e38:	eb 44                	jmp    80107e7e <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107e3a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107e41:	00 
80107e42:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107e49:	00 
80107e4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e4d:	89 04 24             	mov    %eax,(%esp)
80107e50:	e8 79 d5 ff ff       	call   801053ce <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107e55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e58:	05 00 00 00 80       	add    $0x80000000,%eax
80107e5d:	83 c8 07             	or     $0x7,%eax
80107e60:	89 c2                	mov    %eax,%edx
80107e62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e65:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107e67:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e6a:	c1 e8 0c             	shr    $0xc,%eax
80107e6d:	25 ff 03 00 00       	and    $0x3ff,%eax
80107e72:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e79:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e7c:	01 d0                	add    %edx,%eax
}
80107e7e:	c9                   	leave  
80107e7f:	c3                   	ret    

80107e80 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107e80:	55                   	push   %ebp
80107e81:	89 e5                	mov    %esp,%ebp
80107e83:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80107e86:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e89:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e8e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107e91:	8b 55 0c             	mov    0xc(%ebp),%edx
80107e94:	8b 45 10             	mov    0x10(%ebp),%eax
80107e97:	01 d0                	add    %edx,%eax
80107e99:	48                   	dec    %eax
80107e9a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107ea2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80107ea9:	00 
80107eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ead:	89 44 24 04          	mov    %eax,0x4(%esp)
80107eb1:	8b 45 08             	mov    0x8(%ebp),%eax
80107eb4:	89 04 24             	mov    %eax,(%esp)
80107eb7:	e8 28 ff ff ff       	call   80107de4 <walkpgdir>
80107ebc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107ebf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107ec3:	75 07                	jne    80107ecc <mappages+0x4c>
      return -1;
80107ec5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107eca:	eb 48                	jmp    80107f14 <mappages+0x94>
    if(*pte & PTE_P)
80107ecc:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ecf:	8b 00                	mov    (%eax),%eax
80107ed1:	83 e0 01             	and    $0x1,%eax
80107ed4:	85 c0                	test   %eax,%eax
80107ed6:	74 0c                	je     80107ee4 <mappages+0x64>
      panic("remap");
80107ed8:	c7 04 24 c0 8e 10 80 	movl   $0x80108ec0,(%esp)
80107edf:	e8 70 86 ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
80107ee4:	8b 45 18             	mov    0x18(%ebp),%eax
80107ee7:	0b 45 14             	or     0x14(%ebp),%eax
80107eea:	83 c8 01             	or     $0x1,%eax
80107eed:	89 c2                	mov    %eax,%edx
80107eef:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107ef2:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ef7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107efa:	75 08                	jne    80107f04 <mappages+0x84>
      break;
80107efc:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107efd:	b8 00 00 00 00       	mov    $0x0,%eax
80107f02:	eb 10                	jmp    80107f14 <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80107f04:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107f0b:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107f12:	eb 8e                	jmp    80107ea2 <mappages+0x22>
  return 0;
}
80107f14:	c9                   	leave  
80107f15:	c3                   	ret    

80107f16 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107f16:	55                   	push   %ebp
80107f17:	89 e5                	mov    %esp,%ebp
80107f19:	53                   	push   %ebx
80107f1a:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107f1d:	e8 35 ad ff ff       	call   80102c57 <kalloc>
80107f22:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107f25:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f29:	75 0a                	jne    80107f35 <setupkvm+0x1f>
    return 0;
80107f2b:	b8 00 00 00 00       	mov    $0x0,%eax
80107f30:	e9 84 00 00 00       	jmp    80107fb9 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
80107f35:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80107f3c:	00 
80107f3d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107f44:	00 
80107f45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f48:	89 04 24             	mov    %eax,(%esp)
80107f4b:	e8 7e d4 ff ff       	call   801053ce <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107f50:	c7 45 f4 c0 b4 10 80 	movl   $0x8010b4c0,-0xc(%ebp)
80107f57:	eb 54                	jmp    80107fad <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f5c:	8b 48 0c             	mov    0xc(%eax),%ecx
80107f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f62:	8b 50 04             	mov    0x4(%eax),%edx
80107f65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f68:	8b 58 08             	mov    0x8(%eax),%ebx
80107f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f6e:	8b 40 04             	mov    0x4(%eax),%eax
80107f71:	29 c3                	sub    %eax,%ebx
80107f73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f76:	8b 00                	mov    (%eax),%eax
80107f78:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80107f7c:	89 54 24 0c          	mov    %edx,0xc(%esp)
80107f80:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107f84:	89 44 24 04          	mov    %eax,0x4(%esp)
80107f88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f8b:	89 04 24             	mov    %eax,(%esp)
80107f8e:	e8 ed fe ff ff       	call   80107e80 <mappages>
80107f93:	85 c0                	test   %eax,%eax
80107f95:	79 12                	jns    80107fa9 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80107f97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f9a:	89 04 24             	mov    %eax,(%esp)
80107f9d:	e8 1a 05 00 00       	call   801084bc <freevm>
      return 0;
80107fa2:	b8 00 00 00 00       	mov    $0x0,%eax
80107fa7:	eb 10                	jmp    80107fb9 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107fa9:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107fad:	81 7d f4 00 b5 10 80 	cmpl   $0x8010b500,-0xc(%ebp)
80107fb4:	72 a3                	jb     80107f59 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80107fb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80107fb9:	83 c4 34             	add    $0x34,%esp
80107fbc:	5b                   	pop    %ebx
80107fbd:	5d                   	pop    %ebp
80107fbe:	c3                   	ret    

80107fbf <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80107fbf:	55                   	push   %ebp
80107fc0:	89 e5                	mov    %esp,%ebp
80107fc2:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80107fc5:	e8 4c ff ff ff       	call   80107f16 <setupkvm>
80107fca:	a3 44 6a 11 80       	mov    %eax,0x80116a44
  switchkvm();
80107fcf:	e8 02 00 00 00       	call   80107fd6 <switchkvm>
}
80107fd4:	c9                   	leave  
80107fd5:	c3                   	ret    

80107fd6 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80107fd6:	55                   	push   %ebp
80107fd7:	89 e5                	mov    %esp,%ebp
80107fd9:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107fdc:	a1 44 6a 11 80       	mov    0x80116a44,%eax
80107fe1:	05 00 00 00 80       	add    $0x80000000,%eax
80107fe6:	89 04 24             	mov    %eax,(%esp)
80107fe9:	e8 ae fa ff ff       	call   80107a9c <lcr3>
}
80107fee:	c9                   	leave  
80107fef:	c3                   	ret    

80107ff0 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107ff0:	55                   	push   %ebp
80107ff1:	89 e5                	mov    %esp,%ebp
80107ff3:	57                   	push   %edi
80107ff4:	56                   	push   %esi
80107ff5:	53                   	push   %ebx
80107ff6:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
80107ff9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80107ffd:	75 0c                	jne    8010800b <switchuvm+0x1b>
    panic("switchuvm: no process");
80107fff:	c7 04 24 c6 8e 10 80 	movl   $0x80108ec6,(%esp)
80108006:	e8 49 85 ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
8010800b:	8b 45 08             	mov    0x8(%ebp),%eax
8010800e:	8b 40 08             	mov    0x8(%eax),%eax
80108011:	85 c0                	test   %eax,%eax
80108013:	75 0c                	jne    80108021 <switchuvm+0x31>
    panic("switchuvm: no kstack");
80108015:	c7 04 24 dc 8e 10 80 	movl   $0x80108edc,(%esp)
8010801c:	e8 33 85 ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
80108021:	8b 45 08             	mov    0x8(%ebp),%eax
80108024:	8b 40 04             	mov    0x4(%eax),%eax
80108027:	85 c0                	test   %eax,%eax
80108029:	75 0c                	jne    80108037 <switchuvm+0x47>
    panic("switchuvm: no pgdir");
8010802b:	c7 04 24 f1 8e 10 80 	movl   $0x80108ef1,(%esp)
80108032:	e8 1d 85 ff ff       	call   80100554 <panic>

  pushcli();
80108037:	e8 8e d2 ff ff       	call   801052ca <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010803c:	e8 5a c1 ff ff       	call   8010419b <mycpu>
80108041:	89 c3                	mov    %eax,%ebx
80108043:	e8 53 c1 ff ff       	call   8010419b <mycpu>
80108048:	83 c0 08             	add    $0x8,%eax
8010804b:	89 c6                	mov    %eax,%esi
8010804d:	e8 49 c1 ff ff       	call   8010419b <mycpu>
80108052:	83 c0 08             	add    $0x8,%eax
80108055:	c1 e8 10             	shr    $0x10,%eax
80108058:	89 c7                	mov    %eax,%edi
8010805a:	e8 3c c1 ff ff       	call   8010419b <mycpu>
8010805f:	83 c0 08             	add    $0x8,%eax
80108062:	c1 e8 18             	shr    $0x18,%eax
80108065:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
8010806c:	67 00 
8010806e:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108075:	89 f9                	mov    %edi,%ecx
80108077:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
8010807d:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108083:	83 e2 f0             	and    $0xfffffff0,%edx
80108086:	83 ca 09             	or     $0x9,%edx
80108089:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010808f:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108095:	83 ca 10             	or     $0x10,%edx
80108098:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010809e:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
801080a4:	83 e2 9f             	and    $0xffffff9f,%edx
801080a7:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801080ad:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
801080b3:	83 ca 80             	or     $0xffffff80,%edx
801080b6:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801080bc:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801080c2:	83 e2 f0             	and    $0xfffffff0,%edx
801080c5:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801080cb:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801080d1:	83 e2 ef             	and    $0xffffffef,%edx
801080d4:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801080da:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801080e0:	83 e2 df             	and    $0xffffffdf,%edx
801080e3:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801080e9:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801080ef:	83 ca 40             	or     $0x40,%edx
801080f2:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801080f8:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801080fe:	83 e2 7f             	and    $0x7f,%edx
80108101:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108107:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010810d:	e8 89 c0 ff ff       	call   8010419b <mycpu>
80108112:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80108118:	83 e2 ef             	and    $0xffffffef,%edx
8010811b:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80108121:	e8 75 c0 ff ff       	call   8010419b <mycpu>
80108126:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010812c:	e8 6a c0 ff ff       	call   8010419b <mycpu>
80108131:	8b 55 08             	mov    0x8(%ebp),%edx
80108134:	8b 52 08             	mov    0x8(%edx),%edx
80108137:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010813d:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108140:	e8 56 c0 ff ff       	call   8010419b <mycpu>
80108145:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
8010814b:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
80108152:	e8 30 f9 ff ff       	call   80107a87 <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108157:	8b 45 08             	mov    0x8(%ebp),%eax
8010815a:	8b 40 04             	mov    0x4(%eax),%eax
8010815d:	05 00 00 00 80       	add    $0x80000000,%eax
80108162:	89 04 24             	mov    %eax,(%esp)
80108165:	e8 32 f9 ff ff       	call   80107a9c <lcr3>
  popcli();
8010816a:	e8 a5 d1 ff ff       	call   80105314 <popcli>
}
8010816f:	83 c4 1c             	add    $0x1c,%esp
80108172:	5b                   	pop    %ebx
80108173:	5e                   	pop    %esi
80108174:	5f                   	pop    %edi
80108175:	5d                   	pop    %ebp
80108176:	c3                   	ret    

80108177 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108177:	55                   	push   %ebp
80108178:	89 e5                	mov    %esp,%ebp
8010817a:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
8010817d:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108184:	76 0c                	jbe    80108192 <inituvm+0x1b>
    panic("inituvm: more than a page");
80108186:	c7 04 24 05 8f 10 80 	movl   $0x80108f05,(%esp)
8010818d:	e8 c2 83 ff ff       	call   80100554 <panic>
  mem = kalloc();
80108192:	e8 c0 aa ff ff       	call   80102c57 <kalloc>
80108197:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
8010819a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801081a1:	00 
801081a2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801081a9:	00 
801081aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ad:	89 04 24             	mov    %eax,(%esp)
801081b0:	e8 19 d2 ff ff       	call   801053ce <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801081b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b8:	05 00 00 00 80       	add    $0x80000000,%eax
801081bd:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801081c4:	00 
801081c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
801081c9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801081d0:	00 
801081d1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801081d8:	00 
801081d9:	8b 45 08             	mov    0x8(%ebp),%eax
801081dc:	89 04 24             	mov    %eax,(%esp)
801081df:	e8 9c fc ff ff       	call   80107e80 <mappages>
  memmove(mem, init, sz);
801081e4:	8b 45 10             	mov    0x10(%ebp),%eax
801081e7:	89 44 24 08          	mov    %eax,0x8(%esp)
801081eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801081ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801081f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f5:	89 04 24             	mov    %eax,(%esp)
801081f8:	e8 9a d2 ff ff       	call   80105497 <memmove>
}
801081fd:	c9                   	leave  
801081fe:	c3                   	ret    

801081ff <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801081ff:	55                   	push   %ebp
80108200:	89 e5                	mov    %esp,%ebp
80108202:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108205:	8b 45 0c             	mov    0xc(%ebp),%eax
80108208:	25 ff 0f 00 00       	and    $0xfff,%eax
8010820d:	85 c0                	test   %eax,%eax
8010820f:	74 0c                	je     8010821d <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80108211:	c7 04 24 20 8f 10 80 	movl   $0x80108f20,(%esp)
80108218:	e8 37 83 ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
8010821d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108224:	e9 a6 00 00 00       	jmp    801082cf <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108229:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010822f:	01 d0                	add    %edx,%eax
80108231:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108238:	00 
80108239:	89 44 24 04          	mov    %eax,0x4(%esp)
8010823d:	8b 45 08             	mov    0x8(%ebp),%eax
80108240:	89 04 24             	mov    %eax,(%esp)
80108243:	e8 9c fb ff ff       	call   80107de4 <walkpgdir>
80108248:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010824b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010824f:	75 0c                	jne    8010825d <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108251:	c7 04 24 43 8f 10 80 	movl   $0x80108f43,(%esp)
80108258:	e8 f7 82 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
8010825d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108260:	8b 00                	mov    (%eax),%eax
80108262:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108267:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010826a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010826d:	8b 55 18             	mov    0x18(%ebp),%edx
80108270:	29 c2                	sub    %eax,%edx
80108272:	89 d0                	mov    %edx,%eax
80108274:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108279:	77 0f                	ja     8010828a <loaduvm+0x8b>
      n = sz - i;
8010827b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010827e:	8b 55 18             	mov    0x18(%ebp),%edx
80108281:	29 c2                	sub    %eax,%edx
80108283:	89 d0                	mov    %edx,%eax
80108285:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108288:	eb 07                	jmp    80108291 <loaduvm+0x92>
    else
      n = PGSIZE;
8010828a:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108291:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108294:	8b 55 14             	mov    0x14(%ebp),%edx
80108297:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
8010829a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010829d:	05 00 00 00 80       	add    $0x80000000,%eax
801082a2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801082a5:	89 54 24 0c          	mov    %edx,0xc(%esp)
801082a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801082ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801082b1:	8b 45 10             	mov    0x10(%ebp),%eax
801082b4:	89 04 24             	mov    %eax,(%esp)
801082b7:	e8 01 9c ff ff       	call   80101ebd <readi>
801082bc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801082bf:	74 07                	je     801082c8 <loaduvm+0xc9>
      return -1;
801082c1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801082c6:	eb 18                	jmp    801082e0 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801082c8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d2:	3b 45 18             	cmp    0x18(%ebp),%eax
801082d5:	0f 82 4e ff ff ff    	jb     80108229 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801082db:	b8 00 00 00 00       	mov    $0x0,%eax
}
801082e0:	c9                   	leave  
801082e1:	c3                   	ret    

801082e2 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801082e2:	55                   	push   %ebp
801082e3:	89 e5                	mov    %esp,%ebp
801082e5:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801082e8:	8b 45 10             	mov    0x10(%ebp),%eax
801082eb:	85 c0                	test   %eax,%eax
801082ed:	79 0a                	jns    801082f9 <allocuvm+0x17>
    return 0;
801082ef:	b8 00 00 00 00       	mov    $0x0,%eax
801082f4:	e9 fd 00 00 00       	jmp    801083f6 <allocuvm+0x114>
  if(newsz < oldsz)
801082f9:	8b 45 10             	mov    0x10(%ebp),%eax
801082fc:	3b 45 0c             	cmp    0xc(%ebp),%eax
801082ff:	73 08                	jae    80108309 <allocuvm+0x27>
    return oldsz;
80108301:	8b 45 0c             	mov    0xc(%ebp),%eax
80108304:	e9 ed 00 00 00       	jmp    801083f6 <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
80108309:	8b 45 0c             	mov    0xc(%ebp),%eax
8010830c:	05 ff 0f 00 00       	add    $0xfff,%eax
80108311:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108316:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108319:	e9 c9 00 00 00       	jmp    801083e7 <allocuvm+0x105>
    mem = kalloc();
8010831e:	e8 34 a9 ff ff       	call   80102c57 <kalloc>
80108323:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108326:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010832a:	75 2f                	jne    8010835b <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
8010832c:	c7 04 24 61 8f 10 80 	movl   $0x80108f61,(%esp)
80108333:	e8 89 80 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108338:	8b 45 0c             	mov    0xc(%ebp),%eax
8010833b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010833f:	8b 45 10             	mov    0x10(%ebp),%eax
80108342:	89 44 24 04          	mov    %eax,0x4(%esp)
80108346:	8b 45 08             	mov    0x8(%ebp),%eax
80108349:	89 04 24             	mov    %eax,(%esp)
8010834c:	e8 a7 00 00 00       	call   801083f8 <deallocuvm>
      return 0;
80108351:	b8 00 00 00 00       	mov    $0x0,%eax
80108356:	e9 9b 00 00 00       	jmp    801083f6 <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
8010835b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108362:	00 
80108363:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010836a:	00 
8010836b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010836e:	89 04 24             	mov    %eax,(%esp)
80108371:	e8 58 d0 ff ff       	call   801053ce <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108376:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108379:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010837f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108382:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108389:	00 
8010838a:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010838e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108395:	00 
80108396:	89 44 24 04          	mov    %eax,0x4(%esp)
8010839a:	8b 45 08             	mov    0x8(%ebp),%eax
8010839d:	89 04 24             	mov    %eax,(%esp)
801083a0:	e8 db fa ff ff       	call   80107e80 <mappages>
801083a5:	85 c0                	test   %eax,%eax
801083a7:	79 37                	jns    801083e0 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
801083a9:	c7 04 24 79 8f 10 80 	movl   $0x80108f79,(%esp)
801083b0:	e8 0c 80 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801083b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801083b8:	89 44 24 08          	mov    %eax,0x8(%esp)
801083bc:	8b 45 10             	mov    0x10(%ebp),%eax
801083bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801083c3:	8b 45 08             	mov    0x8(%ebp),%eax
801083c6:	89 04 24             	mov    %eax,(%esp)
801083c9:	e8 2a 00 00 00       	call   801083f8 <deallocuvm>
      kfree(mem);
801083ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083d1:	89 04 24             	mov    %eax,(%esp)
801083d4:	e8 e8 a7 ff ff       	call   80102bc1 <kfree>
      return 0;
801083d9:	b8 00 00 00 00       	mov    $0x0,%eax
801083de:	eb 16                	jmp    801083f6 <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801083e0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ea:	3b 45 10             	cmp    0x10(%ebp),%eax
801083ed:	0f 82 2b ff ff ff    	jb     8010831e <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
801083f3:	8b 45 10             	mov    0x10(%ebp),%eax
}
801083f6:	c9                   	leave  
801083f7:	c3                   	ret    

801083f8 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801083f8:	55                   	push   %ebp
801083f9:	89 e5                	mov    %esp,%ebp
801083fb:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801083fe:	8b 45 10             	mov    0x10(%ebp),%eax
80108401:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108404:	72 08                	jb     8010840e <deallocuvm+0x16>
    return oldsz;
80108406:	8b 45 0c             	mov    0xc(%ebp),%eax
80108409:	e9 ac 00 00 00       	jmp    801084ba <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
8010840e:	8b 45 10             	mov    0x10(%ebp),%eax
80108411:	05 ff 0f 00 00       	add    $0xfff,%eax
80108416:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010841b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
8010841e:	e9 88 00 00 00       	jmp    801084ab <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108423:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108426:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010842d:	00 
8010842e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108432:	8b 45 08             	mov    0x8(%ebp),%eax
80108435:	89 04 24             	mov    %eax,(%esp)
80108438:	e8 a7 f9 ff ff       	call   80107de4 <walkpgdir>
8010843d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108440:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108444:	75 14                	jne    8010845a <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108449:	c1 e8 16             	shr    $0x16,%eax
8010844c:	40                   	inc    %eax
8010844d:	c1 e0 16             	shl    $0x16,%eax
80108450:	2d 00 10 00 00       	sub    $0x1000,%eax
80108455:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108458:	eb 4a                	jmp    801084a4 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
8010845a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010845d:	8b 00                	mov    (%eax),%eax
8010845f:	83 e0 01             	and    $0x1,%eax
80108462:	85 c0                	test   %eax,%eax
80108464:	74 3e                	je     801084a4 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108466:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108469:	8b 00                	mov    (%eax),%eax
8010846b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108470:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108473:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108477:	75 0c                	jne    80108485 <deallocuvm+0x8d>
        panic("kfree");
80108479:	c7 04 24 95 8f 10 80 	movl   $0x80108f95,(%esp)
80108480:	e8 cf 80 ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80108485:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108488:	05 00 00 00 80       	add    $0x80000000,%eax
8010848d:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108490:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108493:	89 04 24             	mov    %eax,(%esp)
80108496:	e8 26 a7 ff ff       	call   80102bc1 <kfree>
      *pte = 0;
8010849b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010849e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801084a4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801084ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ae:	3b 45 0c             	cmp    0xc(%ebp),%eax
801084b1:	0f 82 6c ff ff ff    	jb     80108423 <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801084b7:	8b 45 10             	mov    0x10(%ebp),%eax
}
801084ba:	c9                   	leave  
801084bb:	c3                   	ret    

801084bc <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801084bc:	55                   	push   %ebp
801084bd:	89 e5                	mov    %esp,%ebp
801084bf:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
801084c2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801084c6:	75 0c                	jne    801084d4 <freevm+0x18>
    panic("freevm: no pgdir");
801084c8:	c7 04 24 9b 8f 10 80 	movl   $0x80108f9b,(%esp)
801084cf:	e8 80 80 ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801084d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801084db:	00 
801084dc:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
801084e3:	80 
801084e4:	8b 45 08             	mov    0x8(%ebp),%eax
801084e7:	89 04 24             	mov    %eax,(%esp)
801084ea:	e8 09 ff ff ff       	call   801083f8 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801084ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084f6:	eb 44                	jmp    8010853c <freevm+0x80>
    if(pgdir[i] & PTE_P){
801084f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084fb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108502:	8b 45 08             	mov    0x8(%ebp),%eax
80108505:	01 d0                	add    %edx,%eax
80108507:	8b 00                	mov    (%eax),%eax
80108509:	83 e0 01             	and    $0x1,%eax
8010850c:	85 c0                	test   %eax,%eax
8010850e:	74 29                	je     80108539 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108510:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108513:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010851a:	8b 45 08             	mov    0x8(%ebp),%eax
8010851d:	01 d0                	add    %edx,%eax
8010851f:	8b 00                	mov    (%eax),%eax
80108521:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108526:	05 00 00 00 80       	add    $0x80000000,%eax
8010852b:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
8010852e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108531:	89 04 24             	mov    %eax,(%esp)
80108534:	e8 88 a6 ff ff       	call   80102bc1 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108539:	ff 45 f4             	incl   -0xc(%ebp)
8010853c:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108543:	76 b3                	jbe    801084f8 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108545:	8b 45 08             	mov    0x8(%ebp),%eax
80108548:	89 04 24             	mov    %eax,(%esp)
8010854b:	e8 71 a6 ff ff       	call   80102bc1 <kfree>
}
80108550:	c9                   	leave  
80108551:	c3                   	ret    

80108552 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108552:	55                   	push   %ebp
80108553:	89 e5                	mov    %esp,%ebp
80108555:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108558:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010855f:	00 
80108560:	8b 45 0c             	mov    0xc(%ebp),%eax
80108563:	89 44 24 04          	mov    %eax,0x4(%esp)
80108567:	8b 45 08             	mov    0x8(%ebp),%eax
8010856a:	89 04 24             	mov    %eax,(%esp)
8010856d:	e8 72 f8 ff ff       	call   80107de4 <walkpgdir>
80108572:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108575:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108579:	75 0c                	jne    80108587 <clearpteu+0x35>
    panic("clearpteu");
8010857b:	c7 04 24 ac 8f 10 80 	movl   $0x80108fac,(%esp)
80108582:	e8 cd 7f ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80108587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010858a:	8b 00                	mov    (%eax),%eax
8010858c:	83 e0 fb             	and    $0xfffffffb,%eax
8010858f:	89 c2                	mov    %eax,%edx
80108591:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108594:	89 10                	mov    %edx,(%eax)
}
80108596:	c9                   	leave  
80108597:	c3                   	ret    

80108598 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108598:	55                   	push   %ebp
80108599:	89 e5                	mov    %esp,%ebp
8010859b:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010859e:	e8 73 f9 ff ff       	call   80107f16 <setupkvm>
801085a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801085a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801085aa:	75 0a                	jne    801085b6 <copyuvm+0x1e>
    return 0;
801085ac:	b8 00 00 00 00       	mov    $0x0,%eax
801085b1:	e9 f8 00 00 00       	jmp    801086ae <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
801085b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801085bd:	e9 cb 00 00 00       	jmp    8010868d <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801085c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801085cc:	00 
801085cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801085d1:	8b 45 08             	mov    0x8(%ebp),%eax
801085d4:	89 04 24             	mov    %eax,(%esp)
801085d7:	e8 08 f8 ff ff       	call   80107de4 <walkpgdir>
801085dc:	89 45 ec             	mov    %eax,-0x14(%ebp)
801085df:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085e3:	75 0c                	jne    801085f1 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
801085e5:	c7 04 24 b6 8f 10 80 	movl   $0x80108fb6,(%esp)
801085ec:	e8 63 7f ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
801085f1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085f4:	8b 00                	mov    (%eax),%eax
801085f6:	83 e0 01             	and    $0x1,%eax
801085f9:	85 c0                	test   %eax,%eax
801085fb:	75 0c                	jne    80108609 <copyuvm+0x71>
      panic("copyuvm: page not present");
801085fd:	c7 04 24 d0 8f 10 80 	movl   $0x80108fd0,(%esp)
80108604:	e8 4b 7f ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108609:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010860c:	8b 00                	mov    (%eax),%eax
8010860e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108613:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108616:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108619:	8b 00                	mov    (%eax),%eax
8010861b:	25 ff 0f 00 00       	and    $0xfff,%eax
80108620:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108623:	e8 2f a6 ff ff       	call   80102c57 <kalloc>
80108628:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010862b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010862f:	75 02                	jne    80108633 <copyuvm+0x9b>
      goto bad;
80108631:	eb 6b                	jmp    8010869e <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108633:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108636:	05 00 00 00 80       	add    $0x80000000,%eax
8010863b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108642:	00 
80108643:	89 44 24 04          	mov    %eax,0x4(%esp)
80108647:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010864a:	89 04 24             	mov    %eax,(%esp)
8010864d:	e8 45 ce ff ff       	call   80105497 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108652:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108655:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108658:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
8010865e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108661:	89 54 24 10          	mov    %edx,0x10(%esp)
80108665:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108669:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108670:	00 
80108671:	89 44 24 04          	mov    %eax,0x4(%esp)
80108675:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108678:	89 04 24             	mov    %eax,(%esp)
8010867b:	e8 00 f8 ff ff       	call   80107e80 <mappages>
80108680:	85 c0                	test   %eax,%eax
80108682:	79 02                	jns    80108686 <copyuvm+0xee>
      goto bad;
80108684:	eb 18                	jmp    8010869e <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108686:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010868d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108690:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108693:	0f 82 29 ff ff ff    	jb     801085c2 <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
80108699:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010869c:	eb 10                	jmp    801086ae <copyuvm+0x116>

bad:
  freevm(d);
8010869e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086a1:	89 04 24             	mov    %eax,(%esp)
801086a4:	e8 13 fe ff ff       	call   801084bc <freevm>
  return 0;
801086a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801086ae:	c9                   	leave  
801086af:	c3                   	ret    

801086b0 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801086b0:	55                   	push   %ebp
801086b1:	89 e5                	mov    %esp,%ebp
801086b3:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801086b6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801086bd:	00 
801086be:	8b 45 0c             	mov    0xc(%ebp),%eax
801086c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801086c5:	8b 45 08             	mov    0x8(%ebp),%eax
801086c8:	89 04 24             	mov    %eax,(%esp)
801086cb:	e8 14 f7 ff ff       	call   80107de4 <walkpgdir>
801086d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
801086d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d6:	8b 00                	mov    (%eax),%eax
801086d8:	83 e0 01             	and    $0x1,%eax
801086db:	85 c0                	test   %eax,%eax
801086dd:	75 07                	jne    801086e6 <uva2ka+0x36>
    return 0;
801086df:	b8 00 00 00 00       	mov    $0x0,%eax
801086e4:	eb 22                	jmp    80108708 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801086e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e9:	8b 00                	mov    (%eax),%eax
801086eb:	83 e0 04             	and    $0x4,%eax
801086ee:	85 c0                	test   %eax,%eax
801086f0:	75 07                	jne    801086f9 <uva2ka+0x49>
    return 0;
801086f2:	b8 00 00 00 00       	mov    $0x0,%eax
801086f7:	eb 0f                	jmp    80108708 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
801086f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086fc:	8b 00                	mov    (%eax),%eax
801086fe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108703:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108708:	c9                   	leave  
80108709:	c3                   	ret    

8010870a <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010870a:	55                   	push   %ebp
8010870b:	89 e5                	mov    %esp,%ebp
8010870d:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108710:	8b 45 10             	mov    0x10(%ebp),%eax
80108713:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108716:	e9 87 00 00 00       	jmp    801087a2 <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
8010871b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010871e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108723:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108726:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108729:	89 44 24 04          	mov    %eax,0x4(%esp)
8010872d:	8b 45 08             	mov    0x8(%ebp),%eax
80108730:	89 04 24             	mov    %eax,(%esp)
80108733:	e8 78 ff ff ff       	call   801086b0 <uva2ka>
80108738:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
8010873b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010873f:	75 07                	jne    80108748 <copyout+0x3e>
      return -1;
80108741:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108746:	eb 69                	jmp    801087b1 <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108748:	8b 45 0c             	mov    0xc(%ebp),%eax
8010874b:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010874e:	29 c2                	sub    %eax,%edx
80108750:	89 d0                	mov    %edx,%eax
80108752:	05 00 10 00 00       	add    $0x1000,%eax
80108757:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
8010875a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010875d:	3b 45 14             	cmp    0x14(%ebp),%eax
80108760:	76 06                	jbe    80108768 <copyout+0x5e>
      n = len;
80108762:	8b 45 14             	mov    0x14(%ebp),%eax
80108765:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108768:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010876b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010876e:	29 c2                	sub    %eax,%edx
80108770:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108773:	01 c2                	add    %eax,%edx
80108775:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108778:	89 44 24 08          	mov    %eax,0x8(%esp)
8010877c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108783:	89 14 24             	mov    %edx,(%esp)
80108786:	e8 0c cd ff ff       	call   80105497 <memmove>
    len -= n;
8010878b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010878e:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108791:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108794:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108797:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010879a:	05 00 10 00 00       	add    $0x1000,%eax
8010879f:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801087a2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801087a6:	0f 85 6f ff ff ff    	jne    8010871b <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801087ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801087b1:	c9                   	leave  
801087b2:	c3                   	ret    
