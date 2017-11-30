
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
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
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
80100028:	bc 90 d7 10 80       	mov    $0x8010d790,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 46 38 10 80       	mov    $0x80103846,%eax
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
8010003a:	c7 44 24 04 90 8d 10 	movl   $0x80108d90,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 a0 d7 10 80 	movl   $0x8010d7a0,(%esp)
80100049:	e8 24 55 00 00       	call   80105572 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004e:	c7 05 ec 1e 11 80 9c 	movl   $0x80111e9c,0x80111eec
80100055:	1e 11 80 
  bcache.head.next = &bcache.head;
80100058:	c7 05 f0 1e 11 80 9c 	movl   $0x80111e9c,0x80111ef0
8010005f:	1e 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100062:	c7 45 f4 d4 d7 10 80 	movl   $0x8010d7d4,-0xc(%ebp)
80100069:	eb 46                	jmp    801000b1 <binit+0x7d>
    b->next = bcache.head.next;
8010006b:	8b 15 f0 1e 11 80    	mov    0x80111ef0,%edx
80100071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100074:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007a:	c7 40 50 9c 1e 11 80 	movl   $0x80111e9c,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
80100081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100084:	83 c0 0c             	add    $0xc,%eax
80100087:	c7 44 24 04 97 8d 10 	movl   $0x80108d97,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 9d 53 00 00       	call   80105434 <initsleeplock>
    bcache.head.next->prev = b;
80100097:	a1 f0 1e 11 80       	mov    0x80111ef0,%eax
8010009c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010009f:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a5:	a3 f0 1e 11 80       	mov    %eax,0x80111ef0

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000aa:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000b1:	81 7d f4 9c 1e 11 80 	cmpl   $0x80111e9c,-0xc(%ebp)
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
801000c2:	c7 04 24 a0 d7 10 80 	movl   $0x8010d7a0,(%esp)
801000c9:	e8 c5 54 00 00       	call   80105593 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000ce:	a1 f0 1e 11 80       	mov    0x80111ef0,%eax
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
801000fd:	c7 04 24 a0 d7 10 80 	movl   $0x8010d7a0,(%esp)
80100104:	e8 f4 54 00 00       	call   801055fd <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 57 53 00 00       	call   8010546e <acquiresleep>
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
80100128:	81 7d f4 9c 1e 11 80 	cmpl   $0x80111e9c,-0xc(%ebp)
8010012f:	75 a7                	jne    801000d8 <bget+0x1c>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100131:	a1 ec 1e 11 80       	mov    0x80111eec,%eax
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
80100176:	c7 04 24 a0 d7 10 80 	movl   $0x8010d7a0,(%esp)
8010017d:	e8 7b 54 00 00       	call   801055fd <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 de 52 00 00       	call   8010546e <acquiresleep>
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
8010019e:	81 7d f4 9c 1e 11 80 	cmpl   $0x80111e9c,-0xc(%ebp)
801001a5:	75 94                	jne    8010013b <bget+0x7f>
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	c7 04 24 9e 8d 10 80 	movl   $0x80108d9e,(%esp)
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
801001e2:	e8 96 27 00 00       	call   8010297d <iderw>
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
801001fb:	e8 0b 53 00 00       	call   8010550b <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 af 8d 10 80 	movl   $0x80108daf,(%esp)
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
80100225:	e8 53 27 00 00       	call   8010297d <iderw>
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
8010023b:	e8 cb 52 00 00       	call   8010550b <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 b6 8d 10 80 	movl   $0x80108db6,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 6b 52 00 00       	call   801054c9 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 a0 d7 10 80 	movl   $0x8010d7a0,(%esp)
80100265:	e8 29 53 00 00       	call   80105593 <acquire>
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
801002a1:	8b 15 f0 1e 11 80    	mov    0x80111ef0,%edx
801002a7:	8b 45 08             	mov    0x8(%ebp),%eax
801002aa:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801002ad:	8b 45 08             	mov    0x8(%ebp),%eax
801002b0:	c7 40 50 9c 1e 11 80 	movl   $0x80111e9c,0x50(%eax)
    bcache.head.next->prev = b;
801002b7:	a1 f0 1e 11 80       	mov    0x80111ef0,%eax
801002bc:	8b 55 08             	mov    0x8(%ebp),%edx
801002bf:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801002c2:	8b 45 08             	mov    0x8(%ebp),%eax
801002c5:	a3 f0 1e 11 80       	mov    %eax,0x80111ef0
  }
  
  release(&bcache.lock);
801002ca:	c7 04 24 a0 d7 10 80 	movl   $0x8010d7a0,(%esp)
801002d1:	e8 27 53 00 00       	call   801055fd <release>
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
80100364:	8a 80 08 a0 10 80    	mov    -0x7fef5ff8(%eax),%al
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
801003c7:	a1 34 c7 10 80       	mov    0x8010c734,%eax
801003cc:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003cf:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d3:	74 0c                	je     801003e1 <cprintf+0x20>
    acquire(&cons.lock);
801003d5:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
801003dc:	e8 b2 51 00 00       	call   80105593 <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 bd 8d 10 80 	movl   $0x80108dbd,(%esp)
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
801004cf:	c7 45 ec c6 8d 10 80 	movl   $0x80108dc6,-0x14(%ebp)
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
80100546:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
8010054d:	e8 ab 50 00 00       	call   801055fd <release>
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
8010055f:	c7 05 34 c7 10 80 00 	movl   $0x0,0x8010c734
80100566:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
80100569:	e8 ab 2a 00 00       	call   80103019 <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 cd 8d 10 80 	movl   $0x80108dcd,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 e1 8d 10 80 	movl   $0x80108de1,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 a3 50 00 00       	call   8010564a <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 e3 8d 10 80 	movl   $0x80108de3,(%esp)
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
801005d0:	c7 05 ec c6 10 80 01 	movl   $0x1,0x8010c6ec
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
80100666:	8b 0d 04 a0 10 80    	mov    0x8010a004,%ecx
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
80100695:	c7 04 24 e7 8d 10 80 	movl   $0x80108de7,(%esp)
8010069c:	e8 b3 fe ff ff       	call   80100554 <panic>

  if((pos/80) >= 24){  // Scroll up.
801006a1:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006a8:	7e 53                	jle    801006fd <cgaputc+0x121>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006aa:	a1 04 a0 10 80       	mov    0x8010a004,%eax
801006af:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006b5:	a1 04 a0 10 80       	mov    0x8010a004,%eax
801006ba:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
801006c1:	00 
801006c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801006c6:	89 04 24             	mov    %eax,(%esp)
801006c9:	e8 f1 51 00 00       	call   801058bf <memmove>
    pos -= 80;
801006ce:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006d2:	b8 80 07 00 00       	mov    $0x780,%eax
801006d7:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006da:	01 c0                	add    %eax,%eax
801006dc:	8b 0d 04 a0 10 80    	mov    0x8010a004,%ecx
801006e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801006e5:	01 d2                	add    %edx,%edx
801006e7:	01 ca                	add    %ecx,%edx
801006e9:	89 44 24 08          	mov    %eax,0x8(%esp)
801006ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801006f4:	00 
801006f5:	89 14 24             	mov    %edx,(%esp)
801006f8:	e8 f9 50 00 00       	call   801057f6 <memset>
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
80100754:	8b 15 04 a0 10 80    	mov    0x8010a004,%edx
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
8010076e:	a1 ec c6 10 80       	mov    0x8010c6ec,%eax
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
8010078e:	e8 7d 6d 00 00       	call   80107510 <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 71 6d 00 00       	call   80107510 <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 65 6d 00 00       	call   80107510 <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 58 6d 00 00       	call   80107510 <uartputc>
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
8010080c:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
80100813:	e8 7b 4d 00 00       	call   80105593 <acquire>
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
80100860:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100865:	83 f8 01             	cmp    $0x1,%eax
80100868:	75 3a                	jne    801008a4 <consoleintr+0xaf>
        active = 2;
8010086a:	c7 05 00 a0 10 80 02 	movl   $0x2,0x8010a000
80100871:	00 00 00 
        buf1 = input;
80100874:	ba c0 c5 10 80       	mov    $0x8010c5c0,%edx
80100879:	bb 00 21 11 80       	mov    $0x80112100,%ebx
8010087e:	b8 23 00 00 00       	mov    $0x23,%eax
80100883:	89 d7                	mov    %edx,%edi
80100885:	89 de                	mov    %ebx,%esi
80100887:	89 c1                	mov    %eax,%ecx
80100889:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        input = buf2;
8010088b:	ba 00 21 11 80       	mov    $0x80112100,%edx
80100890:	bb 60 c6 10 80       	mov    $0x8010c660,%ebx
80100895:	b8 23 00 00 00       	mov    $0x23,%eax
8010089a:	89 d7                	mov    %edx,%edi
8010089c:	89 de                	mov    %ebx,%esi
8010089e:	89 c1                	mov    %eax,%ecx
801008a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
801008a2:	eb 38                	jmp    801008dc <consoleintr+0xe7>
      }else{
        active = 1;
801008a4:	c7 05 00 a0 10 80 01 	movl   $0x1,0x8010a000
801008ab:	00 00 00 
        buf2 = input;
801008ae:	ba 60 c6 10 80       	mov    $0x8010c660,%edx
801008b3:	bb 00 21 11 80       	mov    $0x80112100,%ebx
801008b8:	b8 23 00 00 00       	mov    $0x23,%eax
801008bd:	89 d7                	mov    %edx,%edi
801008bf:	89 de                	mov    %ebx,%esi
801008c1:	89 c1                	mov    %eax,%ecx
801008c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
        input = buf1;
801008c5:	ba 00 21 11 80       	mov    $0x80112100,%edx
801008ca:	bb c0 c5 10 80       	mov    $0x8010c5c0,%ebx
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
801008e8:	a1 88 21 11 80       	mov    0x80112188,%eax
801008ed:	48                   	dec    %eax
801008ee:	a3 88 21 11 80       	mov    %eax,0x80112188
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
80100902:	8b 15 88 21 11 80    	mov    0x80112188,%edx
80100908:	a1 84 21 11 80       	mov    0x80112184,%eax
8010090d:	39 c2                	cmp    %eax,%edx
8010090f:	74 13                	je     80100924 <consoleintr+0x12f>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100911:	a1 88 21 11 80       	mov    0x80112188,%eax
80100916:	48                   	dec    %eax
80100917:	83 e0 7f             	and    $0x7f,%eax
8010091a:	8a 80 00 21 11 80    	mov    -0x7feedf00(%eax),%al
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
80100929:	8b 15 88 21 11 80    	mov    0x80112188,%edx
8010092f:	a1 84 21 11 80       	mov    0x80112184,%eax
80100934:	39 c2                	cmp    %eax,%edx
80100936:	74 1c                	je     80100954 <consoleintr+0x15f>
        input.e--;
80100938:	a1 88 21 11 80       	mov    0x80112188,%eax
8010093d:	48                   	dec    %eax
8010093e:	a3 88 21 11 80       	mov    %eax,0x80112188
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
80100963:	8b 15 88 21 11 80    	mov    0x80112188,%edx
80100969:	a1 80 21 11 80       	mov    0x80112180,%eax
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
8010098a:	a1 88 21 11 80       	mov    0x80112188,%eax
8010098f:	8d 50 01             	lea    0x1(%eax),%edx
80100992:	89 15 88 21 11 80    	mov    %edx,0x80112188
80100998:	83 e0 7f             	and    $0x7f,%eax
8010099b:	89 c2                	mov    %eax,%edx
8010099d:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009a0:	88 82 00 21 11 80    	mov    %al,-0x7feedf00(%edx)
        consputc(c);
801009a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009a9:	89 04 24             	mov    %eax,(%esp)
801009ac:	e8 b7 fd ff ff       	call   80100768 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009b1:	83 7d dc 0a          	cmpl   $0xa,-0x24(%ebp)
801009b5:	74 18                	je     801009cf <consoleintr+0x1da>
801009b7:	83 7d dc 04          	cmpl   $0x4,-0x24(%ebp)
801009bb:	74 12                	je     801009cf <consoleintr+0x1da>
801009bd:	a1 88 21 11 80       	mov    0x80112188,%eax
801009c2:	8b 15 80 21 11 80    	mov    0x80112180,%edx
801009c8:	83 ea 80             	sub    $0xffffff80,%edx
801009cb:	39 d0                	cmp    %edx,%eax
801009cd:	75 18                	jne    801009e7 <consoleintr+0x1f2>
          input.w = input.e;
801009cf:	a1 88 21 11 80       	mov    0x80112188,%eax
801009d4:	a3 84 21 11 80       	mov    %eax,0x80112184
          wakeup(&input.r);
801009d9:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
801009e0:	e8 ad 3f 00 00       	call   80104992 <wakeup>
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
801009fa:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
80100a01:	e8 f7 4b 00 00       	call   801055fd <release>
  if(doprocdump){
80100a06:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a0a:	74 05                	je     80100a11 <consoleintr+0x21c>
    procdump();  // now call procdump() wo. cons.lock held
80100a0c:	e8 33 40 00 00       	call   80104a44 <procdump>
  }
  if(doconsoleswitch){
80100a11:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a15:	74 15                	je     80100a2c <consoleintr+0x237>
    cprintf("\nActive console now: %d\n", active);
80100a17:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a20:	c7 04 24 fa 8d 10 80 	movl   $0x80108dfa,(%esp)
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
80100a4b:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
80100a52:	e8 3c 4b 00 00       	call   80105593 <acquire>
  while(n > 0){
80100a57:	e9 b7 00 00 00       	jmp    80100b13 <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a5c:	eb 41                	jmp    80100a9f <consoleread+0x6b>
      if(myproc()->killed){
80100a5e:	e8 fd 36 00 00       	call   80104160 <myproc>
80100a63:	8b 40 24             	mov    0x24(%eax),%eax
80100a66:	85 c0                	test   %eax,%eax
80100a68:	74 21                	je     80100a8b <consoleread+0x57>
        release(&cons.lock);
80100a6a:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
80100a71:	e8 87 4b 00 00       	call   801055fd <release>
        ilock(ip);
80100a76:	8b 45 08             	mov    0x8(%ebp),%eax
80100a79:	89 04 24             	mov    %eax,(%esp)
80100a7c:	e8 a5 0f 00 00       	call   80101a26 <ilock>
        return -1;
80100a81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a86:	e9 b3 00 00 00       	jmp    80100b3e <consoleread+0x10a>
      }
      sleep(&input.r, &cons.lock);
80100a8b:	c7 44 24 04 00 c7 10 	movl   $0x8010c700,0x4(%esp)
80100a92:	80 
80100a93:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80100a9a:	e8 05 3e 00 00       	call   801048a4 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while((input.r == input.w) || (active != ip->minor)){
80100a9f:	8b 15 80 21 11 80    	mov    0x80112180,%edx
80100aa5:	a1 84 21 11 80       	mov    0x80112184,%eax
80100aaa:	39 c2                	cmp    %eax,%edx
80100aac:	74 b0                	je     80100a5e <consoleread+0x2a>
80100aae:	8b 45 08             	mov    0x8(%ebp),%eax
80100ab1:	8b 40 54             	mov    0x54(%eax),%eax
80100ab4:	0f bf d0             	movswl %ax,%edx
80100ab7:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100abc:	39 c2                	cmp    %eax,%edx
80100abe:	75 9e                	jne    80100a5e <consoleread+0x2a>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100ac0:	a1 80 21 11 80       	mov    0x80112180,%eax
80100ac5:	8d 50 01             	lea    0x1(%eax),%edx
80100ac8:	89 15 80 21 11 80    	mov    %edx,0x80112180
80100ace:	83 e0 7f             	and    $0x7f,%eax
80100ad1:	8a 80 00 21 11 80    	mov    -0x7feedf00(%eax),%al
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
80100aeb:	a1 80 21 11 80       	mov    0x80112180,%eax
80100af0:	48                   	dec    %eax
80100af1:	a3 80 21 11 80       	mov    %eax,0x80112180
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
80100b1d:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
80100b24:	e8 d4 4a 00 00       	call   801055fd <release>
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
80100b4f:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100b54:	39 c2                	cmp    %eax,%edx
80100b56:	75 5a                	jne    80100bb2 <consolewrite+0x72>
    iunlock(ip);
80100b58:	8b 45 08             	mov    0x8(%ebp),%eax
80100b5b:	89 04 24             	mov    %eax,(%esp)
80100b5e:	e8 cd 0f 00 00       	call   80101b30 <iunlock>
    acquire(&cons.lock);
80100b63:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
80100b6a:	e8 24 4a 00 00       	call   80105593 <acquire>
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
80100b9b:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
80100ba2:	e8 56 4a 00 00       	call   801055fd <release>
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
80100bbd:	c7 44 24 04 13 8e 10 	movl   $0x80108e13,0x4(%esp)
80100bc4:	80 
80100bc5:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
80100bcc:	e8 a1 49 00 00       	call   80105572 <initlock>

  devsw[CONSOLE].write = consolewrite;
80100bd1:	c7 05 4c 2b 11 80 40 	movl   $0x80100b40,0x80112b4c
80100bd8:	0b 10 80 
  devsw[CONSOLE].read = consoleread;
80100bdb:	c7 05 48 2b 11 80 34 	movl   $0x80100a34,0x80112b48
80100be2:	0a 10 80 
  cons.locking = 1;
80100be5:	c7 05 34 c7 10 80 01 	movl   $0x1,0x8010c734
80100bec:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100bef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80100bf6:	00 
80100bf7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80100bfe:	e8 2c 1f 00 00       	call   80102b2f <ioapicenable>
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
80100c11:	e8 4a 35 00 00       	call   80104160 <myproc>
80100c16:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c19:	e8 45 29 00 00       	call   80103563 <begin_op>

  if((ip = namei(path)) == 0){
80100c1e:	8b 45 08             	mov    0x8(%ebp),%eax
80100c21:	89 04 24             	mov    %eax,(%esp)
80100c24:	e8 67 19 00 00       	call   80102590 <namei>
80100c29:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c2c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c30:	75 1b                	jne    80100c4d <exec+0x45>
    end_op();
80100c32:	e8 ae 29 00 00       	call   801035e5 <end_op>
    cprintf("exec: fail\n");
80100c37:	c7 04 24 1b 8e 10 80 	movl   $0x80108e1b,(%esp)
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
80100ca0:	e8 4d 78 00 00       	call   801084f2 <setupkvm>
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
80100d5e:	e8 5b 7b 00 00       	call   801088be <allocuvm>
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
80100db0:	e8 26 7a 00 00       	call   801087db <loaduvm>
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
80100de7:	e8 f9 27 00 00       	call   801035e5 <end_op>
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
80100e1c:	e8 9d 7a 00 00       	call   801088be <allocuvm>
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
80100e41:	e8 e8 7c 00 00       	call   80108b2e <clearpteu>
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
80100e77:	e8 cd 4b 00 00       	call   80105a49 <strlen>
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
80100e9e:	e8 a6 4b 00 00       	call   80105a49 <strlen>
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
80100ecc:	e8 15 7e 00 00       	call   80108ce6 <copyout>
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
80100f70:	e8 71 7d 00 00       	call   80108ce6 <copyout>
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
80100fc0:	e8 3d 4a 00 00       	call   80105a02 <safestrcpy>

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
80101000:	e8 c7 75 00 00       	call   801085cc <switchuvm>
  freevm(oldpgdir);
80101005:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101008:	89 04 24             	mov    %eax,(%esp)
8010100b:	e8 88 7a 00 00       	call   80108a98 <freevm>
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
80101023:	e8 70 7a 00 00       	call   80108a98 <freevm>
  if(ip){
80101028:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010102c:	74 10                	je     8010103e <exec+0x436>
    iunlockput(ip);
8010102e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101031:	89 04 24             	mov    %eax,(%esp)
80101034:	e8 ec 0b 00 00       	call   80101c25 <iunlockput>
    end_op();
80101039:	e8 a7 25 00 00       	call   801035e5 <end_op>
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
8010104e:	c7 44 24 04 27 8e 10 	movl   $0x80108e27,0x4(%esp)
80101055:	80 
80101056:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
8010105d:	e8 10 45 00 00       	call   80105572 <initlock>
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
8010106a:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
80101071:	e8 1d 45 00 00       	call   80105593 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80101076:	c7 45 f4 d4 21 11 80 	movl   $0x801121d4,-0xc(%ebp)
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
80101093:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
8010109a:	e8 5e 45 00 00       	call   801055fd <release>
      return f;
8010109f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010a2:	eb 1e                	jmp    801010c2 <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010a4:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
801010a8:	81 7d f4 34 2b 11 80 	cmpl   $0x80112b34,-0xc(%ebp)
801010af:	72 ce                	jb     8010107f <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
801010b1:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
801010b8:	e8 40 45 00 00       	call   801055fd <release>
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
801010ca:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
801010d1:	e8 bd 44 00 00       	call   80105593 <acquire>
  if(f->ref < 1)
801010d6:	8b 45 08             	mov    0x8(%ebp),%eax
801010d9:	8b 40 04             	mov    0x4(%eax),%eax
801010dc:	85 c0                	test   %eax,%eax
801010de:	7f 0c                	jg     801010ec <filedup+0x28>
    panic("filedup");
801010e0:	c7 04 24 2e 8e 10 80 	movl   $0x80108e2e,(%esp)
801010e7:	e8 68 f4 ff ff       	call   80100554 <panic>
  f->ref++;
801010ec:	8b 45 08             	mov    0x8(%ebp),%eax
801010ef:	8b 40 04             	mov    0x4(%eax),%eax
801010f2:	8d 50 01             	lea    0x1(%eax),%edx
801010f5:	8b 45 08             	mov    0x8(%ebp),%eax
801010f8:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010fb:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
80101102:	e8 f6 44 00 00       	call   801055fd <release>
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
80101115:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
8010111c:	e8 72 44 00 00       	call   80105593 <acquire>
  if(f->ref < 1)
80101121:	8b 45 08             	mov    0x8(%ebp),%eax
80101124:	8b 40 04             	mov    0x4(%eax),%eax
80101127:	85 c0                	test   %eax,%eax
80101129:	7f 0c                	jg     80101137 <fileclose+0x2b>
    panic("fileclose");
8010112b:	c7 04 24 36 8e 10 80 	movl   $0x80108e36,(%esp)
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
80101150:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
80101157:	e8 a1 44 00 00       	call   801055fd <release>
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
80101186:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
8010118d:	e8 6b 44 00 00       	call   801055fd <release>

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
801011aa:	e8 44 2d 00 00       	call   80103ef3 <pipeclose>
801011af:	eb 1d                	jmp    801011ce <fileclose+0xc2>
  else if(ff.type == FD_INODE){
801011b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801011b4:	83 f8 02             	cmp    $0x2,%eax
801011b7:	75 15                	jne    801011ce <fileclose+0xc2>
    begin_op();
801011b9:	e8 a5 23 00 00       	call   80103563 <begin_op>
    iput(ff.ip);
801011be:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011c1:	89 04 24             	mov    %eax,(%esp)
801011c4:	e8 ab 09 00 00       	call   80101b74 <iput>
    end_op();
801011c9:	e8 17 24 00 00       	call   801035e5 <end_op>
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
80101260:	e8 0c 2e 00 00       	call   80104071 <piperead>
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
801012d2:	c7 04 24 40 8e 10 80 	movl   $0x80108e40,(%esp)
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
8010131c:	e8 64 2c 00 00       	call   80103f85 <pipewrite>
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
80101362:	e8 fc 21 00 00       	call   80103563 <begin_op>
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
801013c8:	e8 18 22 00 00       	call   801035e5 <end_op>

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
801013dd:	c7 04 24 49 8e 10 80 	movl   $0x80108e49,(%esp)
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
8010140f:	c7 04 24 59 8e 10 80 	movl   $0x80108e59,(%esp)
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
80101458:	e8 62 44 00 00       	call   801058bf <memmove>
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
8010149e:	e8 53 43 00 00       	call   801057f6 <memset>
  log_write(bp);
801014a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014a6:	89 04 24             	mov    %eax,(%esp)
801014a9:	e8 b9 22 00 00       	call   80103767 <log_write>
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
801014e5:	a1 b8 2b 11 80       	mov    0x80112bb8,%eax
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
80101571:	e8 f1 21 00 00       	call   80103767 <log_write>
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
801015b8:	a1 a0 2b 11 80       	mov    0x80112ba0,%eax
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
801015da:	a1 a0 2b 11 80       	mov    0x80112ba0,%eax
801015df:	39 c2                	cmp    %eax,%edx
801015e1:	0f 82 ed fe ff ff    	jb     801014d4 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
801015e7:	c7 04 24 64 8e 10 80 	movl   $0x80108e64,(%esp)
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
801015fb:	c7 44 24 04 a0 2b 11 	movl   $0x80112ba0,0x4(%esp)
80101602:	80 
80101603:	8b 45 08             	mov    0x8(%ebp),%eax
80101606:	89 04 24             	mov    %eax,(%esp)
80101609:	e8 16 fe ff ff       	call   80101424 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
8010160e:	8b 45 0c             	mov    0xc(%ebp),%eax
80101611:	c1 e8 0c             	shr    $0xc,%eax
80101614:	89 c2                	mov    %eax,%edx
80101616:	a1 b8 2b 11 80       	mov    0x80112bb8,%eax
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
80101677:	c7 04 24 7a 8e 10 80 	movl   $0x80108e7a,(%esp)
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
801016ad:	e8 b5 20 00 00       	call   80103767 <log_write>
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
801016cf:	c7 44 24 04 8d 8e 10 	movl   $0x80108e8d,0x4(%esp)
801016d6:	80 
801016d7:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
801016de:	e8 8f 3e 00 00       	call   80105572 <initlock>
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
801016fc:	05 c0 2b 11 80       	add    $0x80112bc0,%eax
80101701:	83 c0 10             	add    $0x10,%eax
80101704:	c7 44 24 04 94 8e 10 	movl   $0x80108e94,0x4(%esp)
8010170b:	80 
8010170c:	89 04 24             	mov    %eax,(%esp)
8010170f:	e8 20 3d 00 00       	call   80105434 <initsleeplock>
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
8010171d:	c7 44 24 04 a0 2b 11 	movl   $0x80112ba0,0x4(%esp)
80101724:	80 
80101725:	8b 45 08             	mov    0x8(%ebp),%eax
80101728:	89 04 24             	mov    %eax,(%esp)
8010172b:	e8 f4 fc ff ff       	call   80101424 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101730:	a1 b8 2b 11 80       	mov    0x80112bb8,%eax
80101735:	8b 3d b4 2b 11 80    	mov    0x80112bb4,%edi
8010173b:	8b 35 b0 2b 11 80    	mov    0x80112bb0,%esi
80101741:	8b 1d ac 2b 11 80    	mov    0x80112bac,%ebx
80101747:	8b 0d a8 2b 11 80    	mov    0x80112ba8,%ecx
8010174d:	8b 15 a4 2b 11 80    	mov    0x80112ba4,%edx
80101753:	89 55 d4             	mov    %edx,-0x2c(%ebp)
80101756:	8b 15 a0 2b 11 80    	mov    0x80112ba0,%edx
8010175c:	89 44 24 1c          	mov    %eax,0x1c(%esp)
80101760:	89 7c 24 18          	mov    %edi,0x18(%esp)
80101764:	89 74 24 14          	mov    %esi,0x14(%esp)
80101768:	89 5c 24 10          	mov    %ebx,0x10(%esp)
8010176c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101770:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80101773:	89 44 24 08          	mov    %eax,0x8(%esp)
80101777:	89 d0                	mov    %edx,%eax
80101779:	89 44 24 04          	mov    %eax,0x4(%esp)
8010177d:	c7 04 24 9c 8e 10 80 	movl   $0x80108e9c,(%esp)
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
801017b2:	a1 b4 2b 11 80       	mov    0x80112bb4,%eax
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
801017ff:	e8 f2 3f 00 00       	call   801057f6 <memset>
      dip->type = type;
80101804:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101807:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010180a:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
8010180d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101810:	89 04 24             	mov    %eax,(%esp)
80101813:	e8 4f 1f 00 00       	call   80103767 <log_write>
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
80101848:	a1 a8 2b 11 80       	mov    0x80112ba8,%eax
8010184d:	39 c2                	cmp    %eax,%edx
8010184f:	0f 82 55 ff ff ff    	jb     801017aa <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101855:	c7 04 24 ef 8e 10 80 	movl   $0x80108eef,(%esp)
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
80101874:	a1 b4 2b 11 80       	mov    0x80112bb4,%eax
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
80101902:	e8 b8 3f 00 00       	call   801058bf <memmove>
  log_write(bp);
80101907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190a:	89 04 24             	mov    %eax,(%esp)
8010190d:	e8 55 1e 00 00       	call   80103767 <log_write>
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
80101925:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
8010192c:	e8 62 3c 00 00       	call   80105593 <acquire>

  // Is the inode already cached?
  empty = 0;
80101931:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101938:	c7 45 f4 f4 2b 11 80 	movl   $0x80112bf4,-0xc(%ebp)
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
8010196f:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101976:	e8 82 3c 00 00       	call   801055fd <release>
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
8010199d:	81 7d f4 14 48 11 80 	cmpl   $0x80114814,-0xc(%ebp)
801019a4:	72 9b                	jb     80101941 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801019a6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019aa:	75 0c                	jne    801019b8 <iget+0x99>
    panic("iget: no inodes");
801019ac:	c7 04 24 01 8f 10 80 	movl   $0x80108f01,(%esp)
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
801019e3:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
801019ea:	e8 0e 3c 00 00       	call   801055fd <release>

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
801019fa:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101a01:	e8 8d 3b 00 00       	call   80105593 <acquire>
  ip->ref++;
80101a06:	8b 45 08             	mov    0x8(%ebp),%eax
80101a09:	8b 40 08             	mov    0x8(%eax),%eax
80101a0c:	8d 50 01             	lea    0x1(%eax),%edx
80101a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a12:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a15:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101a1c:	e8 dc 3b 00 00       	call   801055fd <release>
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
80101a3c:	c7 04 24 11 8f 10 80 	movl   $0x80108f11,(%esp)
80101a43:	e8 0c eb ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101a48:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4b:	83 c0 0c             	add    $0xc,%eax
80101a4e:	89 04 24             	mov    %eax,(%esp)
80101a51:	e8 18 3a 00 00       	call   8010546e <acquiresleep>

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
80101a6f:	a1 b4 2b 11 80       	mov    0x80112bb4,%eax
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
80101afd:	e8 bd 3d 00 00       	call   801058bf <memmove>
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
80101b22:	c7 04 24 17 8f 10 80 	movl   $0x80108f17,(%esp)
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
80101b45:	e8 c1 39 00 00       	call   8010550b <holdingsleep>
80101b4a:	85 c0                	test   %eax,%eax
80101b4c:	74 0a                	je     80101b58 <iunlock+0x28>
80101b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b51:	8b 40 08             	mov    0x8(%eax),%eax
80101b54:	85 c0                	test   %eax,%eax
80101b56:	7f 0c                	jg     80101b64 <iunlock+0x34>
    panic("iunlock");
80101b58:	c7 04 24 26 8f 10 80 	movl   $0x80108f26,(%esp)
80101b5f:	e8 f0 e9 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101b64:	8b 45 08             	mov    0x8(%ebp),%eax
80101b67:	83 c0 0c             	add    $0xc,%eax
80101b6a:	89 04 24             	mov    %eax,(%esp)
80101b6d:	e8 57 39 00 00       	call   801054c9 <releasesleep>
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
80101b83:	e8 e6 38 00 00       	call   8010546e <acquiresleep>
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
80101b9e:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101ba5:	e8 e9 39 00 00       	call   80105593 <acquire>
    int r = ip->ref;
80101baa:	8b 45 08             	mov    0x8(%ebp),%eax
80101bad:	8b 40 08             	mov    0x8(%eax),%eax
80101bb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101bb3:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101bba:	e8 3e 3a 00 00       	call   801055fd <release>
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
80101bf7:	e8 cd 38 00 00       	call   801054c9 <releasesleep>

  acquire(&icache.lock);
80101bfc:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101c03:	e8 8b 39 00 00       	call   80105593 <acquire>
  ip->ref--;
80101c08:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0b:	8b 40 08             	mov    0x8(%eax),%eax
80101c0e:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c11:	8b 45 08             	mov    0x8(%ebp),%eax
80101c14:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c17:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101c1e:	e8 da 39 00 00       	call   801055fd <release>
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
80101d2f:	e8 33 1a 00 00       	call   80103767 <log_write>
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
80101d44:	c7 04 24 2e 8f 10 80 	movl   $0x80108f2e,(%esp)
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
80101ef0:	8b 04 c5 40 2b 11 80 	mov    -0x7feed4c0(,%eax,8),%eax
80101ef7:	85 c0                	test   %eax,%eax
80101ef9:	75 0a                	jne    80101f05 <readi+0x48>
      return -1;
80101efb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f00:	e9 1a 01 00 00       	jmp    8010201f <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101f05:	8b 45 08             	mov    0x8(%ebp),%eax
80101f08:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f0c:	98                   	cwtl   
80101f0d:	8b 04 c5 40 2b 11 80 	mov    -0x7feed4c0(,%eax,8),%eax
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
80101fee:	e8 cc 38 00 00       	call   801058bf <memmove>
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
80102054:	8b 04 c5 44 2b 11 80 	mov    -0x7feed4bc(,%eax,8),%eax
8010205b:	85 c0                	test   %eax,%eax
8010205d:	75 0a                	jne    80102069 <writei+0x48>
      return -1;
8010205f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102064:	e9 45 01 00 00       	jmp    801021ae <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
80102069:	8b 45 08             	mov    0x8(%ebp),%eax
8010206c:	66 8b 40 52          	mov    0x52(%eax),%ax
80102070:	98                   	cwtl   
80102071:	8b 04 c5 44 2b 11 80 	mov    -0x7feed4bc(,%eax,8),%eax
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
8010214d:	e8 6d 37 00 00       	call   801058bf <memmove>
    log_write(bp);
80102152:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102155:	89 04 24             	mov    %eax,(%esp)
80102158:	e8 0a 16 00 00       	call   80103767 <log_write>
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
801021cb:	e8 8e 37 00 00       	call   8010595e <strncmp>
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
801021e4:	c7 04 24 41 8f 10 80 	movl   $0x80108f41,(%esp)
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
80102222:	c7 04 24 53 8f 10 80 	movl   $0x80108f53,(%esp)
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
80102305:	c7 04 24 62 8f 10 80 	movl   $0x80108f62,(%esp)
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
80102349:	e8 5e 36 00 00       	call   801059ac <strncpy>
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
8010237b:	c7 04 24 6f 8f 10 80 	movl   $0x80108f6f,(%esp)
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
801023fa:	e8 c0 34 00 00       	call   801058bf <memmove>
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
80102415:	e8 a5 34 00 00       	call   801058bf <memmove>
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

  cprintf("namex begin\n");
8010243e:	c7 04 24 77 8f 10 80 	movl   $0x80108f77,(%esp)
80102445:	e8 77 df ff ff       	call   801003c1 <cprintf>

  if(*path == '/')
8010244a:	8b 45 08             	mov    0x8(%ebp),%eax
8010244d:	8a 00                	mov    (%eax),%al
8010244f:	3c 2f                	cmp    $0x2f,%al
80102451:	75 19                	jne    8010246c <namex+0x34>
    ip = iget(ROOTDEV, ROOTINO);
80102453:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010245a:	00 
8010245b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102462:	e8 b8 f4 ff ff       	call   8010191f <iget>
80102467:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010246a:	eb 13                	jmp    8010247f <namex+0x47>
  else
    ip = idup(myproc()->cwd);
8010246c:	e8 ef 1c 00 00       	call   80104160 <myproc>
80102471:	8b 40 68             	mov    0x68(%eax),%eax
80102474:	89 04 24             	mov    %eax,(%esp)
80102477:	e8 78 f5 ff ff       	call   801019f4 <idup>
8010247c:	89 45 f4             	mov    %eax,-0xc(%ebp)

  cprintf("namex continue2..\n");
8010247f:	c7 04 24 84 8f 10 80 	movl   $0x80108f84,(%esp)
80102486:	e8 36 df ff ff       	call   801003c1 <cprintf>

  while((path = skipelem(path, name)) != 0){
8010248b:	e9 c4 00 00 00       	jmp    80102554 <namex+0x11c>
    cprintf("namex continue3..\n");
80102490:	c7 04 24 97 8f 10 80 	movl   $0x80108f97,(%esp)
80102497:	e8 25 df ff ff       	call   801003c1 <cprintf>
    ilock(ip);
8010249c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010249f:	89 04 24             	mov    %eax,(%esp)
801024a2:	e8 7f f5 ff ff       	call   80101a26 <ilock>
    cprintf("namex continue4..\n");
801024a7:	c7 04 24 aa 8f 10 80 	movl   $0x80108faa,(%esp)
801024ae:	e8 0e df ff ff       	call   801003c1 <cprintf>
    if(ip->type != T_DIR){
801024b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024b6:	8b 40 50             	mov    0x50(%eax),%eax
801024b9:	66 83 f8 01          	cmp    $0x1,%ax
801024bd:	74 15                	je     801024d4 <namex+0x9c>
      iunlockput(ip);
801024bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024c2:	89 04 24             	mov    %eax,(%esp)
801024c5:	e8 5b f7 ff ff       	call   80101c25 <iunlockput>
      return 0;
801024ca:	b8 00 00 00 00       	mov    $0x0,%eax
801024cf:	e9 ba 00 00 00       	jmp    8010258e <namex+0x156>
    }
    cprintf("namex continue5..\n");
801024d4:	c7 04 24 bd 8f 10 80 	movl   $0x80108fbd,(%esp)
801024db:	e8 e1 de ff ff       	call   801003c1 <cprintf>
    if(nameiparent && *path == '\0'){
801024e0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024e4:	74 1c                	je     80102502 <namex+0xca>
801024e6:	8b 45 08             	mov    0x8(%ebp),%eax
801024e9:	8a 00                	mov    (%eax),%al
801024eb:	84 c0                	test   %al,%al
801024ed:	75 13                	jne    80102502 <namex+0xca>
      // Stop one level early.
      iunlock(ip);
801024ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024f2:	89 04 24             	mov    %eax,(%esp)
801024f5:	e8 36 f6 ff ff       	call   80101b30 <iunlock>
      return ip;
801024fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801024fd:	e9 8c 00 00 00       	jmp    8010258e <namex+0x156>
    }
    cprintf("namex continue6..\n");
80102502:	c7 04 24 d0 8f 10 80 	movl   $0x80108fd0,(%esp)
80102509:	e8 b3 de ff ff       	call   801003c1 <cprintf>
    if((next = dirlookup(ip, name, 0)) == 0){
8010250e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102515:	00 
80102516:	8b 45 10             	mov    0x10(%ebp),%eax
80102519:	89 44 24 04          	mov    %eax,0x4(%esp)
8010251d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102520:	89 04 24             	mov    %eax,(%esp)
80102523:	e8 aa fc ff ff       	call   801021d2 <dirlookup>
80102528:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010252b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010252f:	75 12                	jne    80102543 <namex+0x10b>
      iunlockput(ip);
80102531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102534:	89 04 24             	mov    %eax,(%esp)
80102537:	e8 e9 f6 ff ff       	call   80101c25 <iunlockput>
      return 0;
8010253c:	b8 00 00 00 00       	mov    $0x0,%eax
80102541:	eb 4b                	jmp    8010258e <namex+0x156>
    }
    iunlockput(ip);
80102543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102546:	89 04 24             	mov    %eax,(%esp)
80102549:	e8 d7 f6 ff ff       	call   80101c25 <iunlockput>
    ip = next;
8010254e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102551:	89 45 f4             	mov    %eax,-0xc(%ebp)
  else
    ip = idup(myproc()->cwd);

  cprintf("namex continue2..\n");

  while((path = skipelem(path, name)) != 0){
80102554:	8b 45 10             	mov    0x10(%ebp),%eax
80102557:	89 44 24 04          	mov    %eax,0x4(%esp)
8010255b:	8b 45 08             	mov    0x8(%ebp),%eax
8010255e:	89 04 24             	mov    %eax,(%esp)
80102561:	e8 28 fe ff ff       	call   8010238e <skipelem>
80102566:	89 45 08             	mov    %eax,0x8(%ebp)
80102569:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010256d:	0f 85 1d ff ff ff    	jne    80102490 <namex+0x58>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80102573:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102577:	74 12                	je     8010258b <namex+0x153>
    iput(ip);
80102579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010257c:	89 04 24             	mov    %eax,(%esp)
8010257f:	e8 f0 f5 ff ff       	call   80101b74 <iput>
    return 0;
80102584:	b8 00 00 00 00       	mov    $0x0,%eax
80102589:	eb 03                	jmp    8010258e <namex+0x156>
  }
  return ip;
8010258b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010258e:	c9                   	leave  
8010258f:	c3                   	ret    

80102590 <namei>:

struct inode*
namei(char *path)
{
80102590:	55                   	push   %ebp
80102591:	89 e5                	mov    %esp,%ebp
80102593:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102596:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102599:	89 44 24 08          	mov    %eax,0x8(%esp)
8010259d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801025a4:	00 
801025a5:	8b 45 08             	mov    0x8(%ebp),%eax
801025a8:	89 04 24             	mov    %eax,(%esp)
801025ab:	e8 88 fe ff ff       	call   80102438 <namex>
}
801025b0:	c9                   	leave  
801025b1:	c3                   	ret    

801025b2 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801025b2:	55                   	push   %ebp
801025b3:	89 e5                	mov    %esp,%ebp
801025b5:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
801025b8:	8b 45 0c             	mov    0xc(%ebp),%eax
801025bb:	89 44 24 08          	mov    %eax,0x8(%esp)
801025bf:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801025c6:	00 
801025c7:	8b 45 08             	mov    0x8(%ebp),%eax
801025ca:	89 04 24             	mov    %eax,(%esp)
801025cd:	e8 66 fe ff ff       	call   80102438 <namex>
}
801025d2:	c9                   	leave  
801025d3:	c3                   	ret    

801025d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801025d4:	55                   	push   %ebp
801025d5:	89 e5                	mov    %esp,%ebp
801025d7:	83 ec 14             	sub    $0x14,%esp
801025da:	8b 45 08             	mov    0x8(%ebp),%eax
801025dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801025e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801025e4:	89 c2                	mov    %eax,%edx
801025e6:	ec                   	in     (%dx),%al
801025e7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801025ea:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801025ed:	c9                   	leave  
801025ee:	c3                   	ret    

801025ef <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801025ef:	55                   	push   %ebp
801025f0:	89 e5                	mov    %esp,%ebp
801025f2:	57                   	push   %edi
801025f3:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801025f4:	8b 55 08             	mov    0x8(%ebp),%edx
801025f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025fa:	8b 45 10             	mov    0x10(%ebp),%eax
801025fd:	89 cb                	mov    %ecx,%ebx
801025ff:	89 df                	mov    %ebx,%edi
80102601:	89 c1                	mov    %eax,%ecx
80102603:	fc                   	cld    
80102604:	f3 6d                	rep insl (%dx),%es:(%edi)
80102606:	89 c8                	mov    %ecx,%eax
80102608:	89 fb                	mov    %edi,%ebx
8010260a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010260d:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102610:	5b                   	pop    %ebx
80102611:	5f                   	pop    %edi
80102612:	5d                   	pop    %ebp
80102613:	c3                   	ret    

80102614 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102614:	55                   	push   %ebp
80102615:	89 e5                	mov    %esp,%ebp
80102617:	83 ec 08             	sub    $0x8,%esp
8010261a:	8b 45 08             	mov    0x8(%ebp),%eax
8010261d:	8b 55 0c             	mov    0xc(%ebp),%edx
80102620:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102624:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102627:	8a 45 f8             	mov    -0x8(%ebp),%al
8010262a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010262d:	ee                   	out    %al,(%dx)
}
8010262e:	c9                   	leave  
8010262f:	c3                   	ret    

80102630 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102630:	55                   	push   %ebp
80102631:	89 e5                	mov    %esp,%ebp
80102633:	56                   	push   %esi
80102634:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102635:	8b 55 08             	mov    0x8(%ebp),%edx
80102638:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010263b:	8b 45 10             	mov    0x10(%ebp),%eax
8010263e:	89 cb                	mov    %ecx,%ebx
80102640:	89 de                	mov    %ebx,%esi
80102642:	89 c1                	mov    %eax,%ecx
80102644:	fc                   	cld    
80102645:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102647:	89 c8                	mov    %ecx,%eax
80102649:	89 f3                	mov    %esi,%ebx
8010264b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010264e:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102651:	5b                   	pop    %ebx
80102652:	5e                   	pop    %esi
80102653:	5d                   	pop    %ebp
80102654:	c3                   	ret    

80102655 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102655:	55                   	push   %ebp
80102656:	89 e5                	mov    %esp,%ebp
80102658:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
8010265b:	90                   	nop
8010265c:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102663:	e8 6c ff ff ff       	call   801025d4 <inb>
80102668:	0f b6 c0             	movzbl %al,%eax
8010266b:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010266e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102671:	25 c0 00 00 00       	and    $0xc0,%eax
80102676:	83 f8 40             	cmp    $0x40,%eax
80102679:	75 e1                	jne    8010265c <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010267b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010267f:	74 11                	je     80102692 <idewait+0x3d>
80102681:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102684:	83 e0 21             	and    $0x21,%eax
80102687:	85 c0                	test   %eax,%eax
80102689:	74 07                	je     80102692 <idewait+0x3d>
    return -1;
8010268b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102690:	eb 05                	jmp    80102697 <idewait+0x42>
  return 0;
80102692:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102697:	c9                   	leave  
80102698:	c3                   	ret    

80102699 <ideinit>:

void
ideinit(void)
{
80102699:	55                   	push   %ebp
8010269a:	89 e5                	mov    %esp,%ebp
8010269c:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
8010269f:	c7 44 24 04 e3 8f 10 	movl   $0x80108fe3,0x4(%esp)
801026a6:	80 
801026a7:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
801026ae:	e8 bf 2e 00 00       	call   80105572 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
801026b3:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
801026b8:	48                   	dec    %eax
801026b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801026bd:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801026c4:	e8 66 04 00 00       	call   80102b2f <ioapicenable>
  idewait(0);
801026c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801026d0:	e8 80 ff ff ff       	call   80102655 <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801026d5:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801026dc:	00 
801026dd:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801026e4:	e8 2b ff ff ff       	call   80102614 <outb>
  for(i=0; i<1000; i++){
801026e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801026f0:	eb 1f                	jmp    80102711 <ideinit+0x78>
    if(inb(0x1f7) != 0){
801026f2:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801026f9:	e8 d6 fe ff ff       	call   801025d4 <inb>
801026fe:	84 c0                	test   %al,%al
80102700:	74 0c                	je     8010270e <ideinit+0x75>
      havedisk1 = 1;
80102702:	c7 05 78 c7 10 80 01 	movl   $0x1,0x8010c778
80102709:	00 00 00 
      break;
8010270c:	eb 0c                	jmp    8010271a <ideinit+0x81>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
8010270e:	ff 45 f4             	incl   -0xc(%ebp)
80102711:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102718:	7e d8                	jle    801026f2 <ideinit+0x59>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010271a:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102721:	00 
80102722:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102729:	e8 e6 fe ff ff       	call   80102614 <outb>
}
8010272e:	c9                   	leave  
8010272f:	c3                   	ret    

80102730 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102730:	55                   	push   %ebp
80102731:	89 e5                	mov    %esp,%ebp
80102733:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
80102736:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010273a:	75 0c                	jne    80102748 <idestart+0x18>
    panic("idestart");
8010273c:	c7 04 24 e7 8f 10 80 	movl   $0x80108fe7,(%esp)
80102743:	e8 0c de ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
80102748:	8b 45 08             	mov    0x8(%ebp),%eax
8010274b:	8b 40 08             	mov    0x8(%eax),%eax
8010274e:	3d e7 03 00 00       	cmp    $0x3e7,%eax
80102753:	76 0c                	jbe    80102761 <idestart+0x31>
    panic("incorrect blockno");
80102755:	c7 04 24 f0 8f 10 80 	movl   $0x80108ff0,(%esp)
8010275c:	e8 f3 dd ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102761:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102768:	8b 45 08             	mov    0x8(%ebp),%eax
8010276b:	8b 50 08             	mov    0x8(%eax),%edx
8010276e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102771:	0f af c2             	imul   %edx,%eax
80102774:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102777:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010277b:	75 07                	jne    80102784 <idestart+0x54>
8010277d:	b8 20 00 00 00       	mov    $0x20,%eax
80102782:	eb 05                	jmp    80102789 <idestart+0x59>
80102784:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102789:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
8010278c:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102790:	75 07                	jne    80102799 <idestart+0x69>
80102792:	b8 30 00 00 00       	mov    $0x30,%eax
80102797:	eb 05                	jmp    8010279e <idestart+0x6e>
80102799:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010279e:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801027a1:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801027a5:	7e 0c                	jle    801027b3 <idestart+0x83>
801027a7:	c7 04 24 e7 8f 10 80 	movl   $0x80108fe7,(%esp)
801027ae:	e8 a1 dd ff ff       	call   80100554 <panic>

  idewait(0);
801027b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801027ba:	e8 96 fe ff ff       	call   80102655 <idewait>
  outb(0x3f6, 0);  // generate interrupt
801027bf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801027c6:	00 
801027c7:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801027ce:	e8 41 fe ff ff       	call   80102614 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
801027d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d6:	0f b6 c0             	movzbl %al,%eax
801027d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801027dd:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
801027e4:	e8 2b fe ff ff       	call   80102614 <outb>
  outb(0x1f3, sector & 0xff);
801027e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027ec:	0f b6 c0             	movzbl %al,%eax
801027ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801027f3:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
801027fa:	e8 15 fe ff ff       	call   80102614 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
801027ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102802:	c1 f8 08             	sar    $0x8,%eax
80102805:	0f b6 c0             	movzbl %al,%eax
80102808:	89 44 24 04          	mov    %eax,0x4(%esp)
8010280c:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
80102813:	e8 fc fd ff ff       	call   80102614 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
80102818:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010281b:	c1 f8 10             	sar    $0x10,%eax
8010281e:	0f b6 c0             	movzbl %al,%eax
80102821:	89 44 24 04          	mov    %eax,0x4(%esp)
80102825:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
8010282c:	e8 e3 fd ff ff       	call   80102614 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102831:	8b 45 08             	mov    0x8(%ebp),%eax
80102834:	8b 40 04             	mov    0x4(%eax),%eax
80102837:	83 e0 01             	and    $0x1,%eax
8010283a:	c1 e0 04             	shl    $0x4,%eax
8010283d:	88 c2                	mov    %al,%dl
8010283f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102842:	c1 f8 18             	sar    $0x18,%eax
80102845:	83 e0 0f             	and    $0xf,%eax
80102848:	09 d0                	or     %edx,%eax
8010284a:	83 c8 e0             	or     $0xffffffe0,%eax
8010284d:	0f b6 c0             	movzbl %al,%eax
80102850:	89 44 24 04          	mov    %eax,0x4(%esp)
80102854:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010285b:	e8 b4 fd ff ff       	call   80102614 <outb>
  if(b->flags & B_DIRTY){
80102860:	8b 45 08             	mov    0x8(%ebp),%eax
80102863:	8b 00                	mov    (%eax),%eax
80102865:	83 e0 04             	and    $0x4,%eax
80102868:	85 c0                	test   %eax,%eax
8010286a:	74 36                	je     801028a2 <idestart+0x172>
    outb(0x1f7, write_cmd);
8010286c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010286f:	0f b6 c0             	movzbl %al,%eax
80102872:	89 44 24 04          	mov    %eax,0x4(%esp)
80102876:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010287d:	e8 92 fd ff ff       	call   80102614 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102882:	8b 45 08             	mov    0x8(%ebp),%eax
80102885:	83 c0 5c             	add    $0x5c,%eax
80102888:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010288f:	00 
80102890:	89 44 24 04          	mov    %eax,0x4(%esp)
80102894:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010289b:	e8 90 fd ff ff       	call   80102630 <outsl>
801028a0:	eb 16                	jmp    801028b8 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
801028a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801028a5:	0f b6 c0             	movzbl %al,%eax
801028a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801028ac:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801028b3:	e8 5c fd ff ff       	call   80102614 <outb>
  }
}
801028b8:	c9                   	leave  
801028b9:	c3                   	ret    

801028ba <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801028ba:	55                   	push   %ebp
801028bb:	89 e5                	mov    %esp,%ebp
801028bd:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801028c0:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
801028c7:	e8 c7 2c 00 00       	call   80105593 <acquire>

  if((b = idequeue) == 0){
801028cc:	a1 74 c7 10 80       	mov    0x8010c774,%eax
801028d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801028d8:	75 11                	jne    801028eb <ideintr+0x31>
    release(&idelock);
801028da:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
801028e1:	e8 17 2d 00 00       	call   801055fd <release>
    return;
801028e6:	e9 90 00 00 00       	jmp    8010297b <ideintr+0xc1>
  }
  idequeue = b->qnext;
801028eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ee:	8b 40 58             	mov    0x58(%eax),%eax
801028f1:	a3 74 c7 10 80       	mov    %eax,0x8010c774

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801028f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f9:	8b 00                	mov    (%eax),%eax
801028fb:	83 e0 04             	and    $0x4,%eax
801028fe:	85 c0                	test   %eax,%eax
80102900:	75 2e                	jne    80102930 <ideintr+0x76>
80102902:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102909:	e8 47 fd ff ff       	call   80102655 <idewait>
8010290e:	85 c0                	test   %eax,%eax
80102910:	78 1e                	js     80102930 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80102912:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102915:	83 c0 5c             	add    $0x5c,%eax
80102918:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010291f:	00 
80102920:	89 44 24 04          	mov    %eax,0x4(%esp)
80102924:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
8010292b:	e8 bf fc ff ff       	call   801025ef <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102930:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102933:	8b 00                	mov    (%eax),%eax
80102935:	83 c8 02             	or     $0x2,%eax
80102938:	89 c2                	mov    %eax,%edx
8010293a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010293d:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
8010293f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102942:	8b 00                	mov    (%eax),%eax
80102944:	83 e0 fb             	and    $0xfffffffb,%eax
80102947:	89 c2                	mov    %eax,%edx
80102949:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010294c:	89 10                	mov    %edx,(%eax)
  wakeup(b);
8010294e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102951:	89 04 24             	mov    %eax,(%esp)
80102954:	e8 39 20 00 00       	call   80104992 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102959:	a1 74 c7 10 80       	mov    0x8010c774,%eax
8010295e:	85 c0                	test   %eax,%eax
80102960:	74 0d                	je     8010296f <ideintr+0xb5>
    idestart(idequeue);
80102962:	a1 74 c7 10 80       	mov    0x8010c774,%eax
80102967:	89 04 24             	mov    %eax,(%esp)
8010296a:	e8 c1 fd ff ff       	call   80102730 <idestart>

  release(&idelock);
8010296f:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
80102976:	e8 82 2c 00 00       	call   801055fd <release>
}
8010297b:	c9                   	leave  
8010297c:	c3                   	ret    

8010297d <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010297d:	55                   	push   %ebp
8010297e:	89 e5                	mov    %esp,%ebp
80102980:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102983:	8b 45 08             	mov    0x8(%ebp),%eax
80102986:	83 c0 0c             	add    $0xc,%eax
80102989:	89 04 24             	mov    %eax,(%esp)
8010298c:	e8 7a 2b 00 00       	call   8010550b <holdingsleep>
80102991:	85 c0                	test   %eax,%eax
80102993:	75 0c                	jne    801029a1 <iderw+0x24>
    panic("iderw: buf not locked");
80102995:	c7 04 24 02 90 10 80 	movl   $0x80109002,(%esp)
8010299c:	e8 b3 db ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801029a1:	8b 45 08             	mov    0x8(%ebp),%eax
801029a4:	8b 00                	mov    (%eax),%eax
801029a6:	83 e0 06             	and    $0x6,%eax
801029a9:	83 f8 02             	cmp    $0x2,%eax
801029ac:	75 0c                	jne    801029ba <iderw+0x3d>
    panic("iderw: nothing to do");
801029ae:	c7 04 24 18 90 10 80 	movl   $0x80109018,(%esp)
801029b5:	e8 9a db ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
801029ba:	8b 45 08             	mov    0x8(%ebp),%eax
801029bd:	8b 40 04             	mov    0x4(%eax),%eax
801029c0:	85 c0                	test   %eax,%eax
801029c2:	74 15                	je     801029d9 <iderw+0x5c>
801029c4:	a1 78 c7 10 80       	mov    0x8010c778,%eax
801029c9:	85 c0                	test   %eax,%eax
801029cb:	75 0c                	jne    801029d9 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
801029cd:	c7 04 24 2d 90 10 80 	movl   $0x8010902d,(%esp)
801029d4:	e8 7b db ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801029d9:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
801029e0:	e8 ae 2b 00 00       	call   80105593 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
801029e5:	8b 45 08             	mov    0x8(%ebp),%eax
801029e8:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029ef:	c7 45 f4 74 c7 10 80 	movl   $0x8010c774,-0xc(%ebp)
801029f6:	eb 0b                	jmp    80102a03 <iderw+0x86>
801029f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029fb:	8b 00                	mov    (%eax),%eax
801029fd:	83 c0 58             	add    $0x58,%eax
80102a00:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a06:	8b 00                	mov    (%eax),%eax
80102a08:	85 c0                	test   %eax,%eax
80102a0a:	75 ec                	jne    801029f8 <iderw+0x7b>
    ;
  *pp = b;
80102a0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a0f:	8b 55 08             	mov    0x8(%ebp),%edx
80102a12:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102a14:	a1 74 c7 10 80       	mov    0x8010c774,%eax
80102a19:	3b 45 08             	cmp    0x8(%ebp),%eax
80102a1c:	75 0d                	jne    80102a2b <iderw+0xae>
    idestart(b);
80102a1e:	8b 45 08             	mov    0x8(%ebp),%eax
80102a21:	89 04 24             	mov    %eax,(%esp)
80102a24:	e8 07 fd ff ff       	call   80102730 <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a29:	eb 15                	jmp    80102a40 <iderw+0xc3>
80102a2b:	eb 13                	jmp    80102a40 <iderw+0xc3>
    sleep(b, &idelock);
80102a2d:	c7 44 24 04 40 c7 10 	movl   $0x8010c740,0x4(%esp)
80102a34:	80 
80102a35:	8b 45 08             	mov    0x8(%ebp),%eax
80102a38:	89 04 24             	mov    %eax,(%esp)
80102a3b:	e8 64 1e 00 00       	call   801048a4 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102a40:	8b 45 08             	mov    0x8(%ebp),%eax
80102a43:	8b 00                	mov    (%eax),%eax
80102a45:	83 e0 06             	and    $0x6,%eax
80102a48:	83 f8 02             	cmp    $0x2,%eax
80102a4b:	75 e0                	jne    80102a2d <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
80102a4d:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
80102a54:	e8 a4 2b 00 00       	call   801055fd <release>
}
80102a59:	c9                   	leave  
80102a5a:	c3                   	ret    
	...

80102a5c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102a5c:	55                   	push   %ebp
80102a5d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a5f:	a1 14 48 11 80       	mov    0x80114814,%eax
80102a64:	8b 55 08             	mov    0x8(%ebp),%edx
80102a67:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a69:	a1 14 48 11 80       	mov    0x80114814,%eax
80102a6e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102a71:	5d                   	pop    %ebp
80102a72:	c3                   	ret    

80102a73 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102a73:	55                   	push   %ebp
80102a74:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102a76:	a1 14 48 11 80       	mov    0x80114814,%eax
80102a7b:	8b 55 08             	mov    0x8(%ebp),%edx
80102a7e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a80:	a1 14 48 11 80       	mov    0x80114814,%eax
80102a85:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a88:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a8b:	5d                   	pop    %ebp
80102a8c:	c3                   	ret    

80102a8d <ioapicinit>:

void
ioapicinit(void)
{
80102a8d:	55                   	push   %ebp
80102a8e:	89 e5                	mov    %esp,%ebp
80102a90:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a93:	c7 05 14 48 11 80 00 	movl   $0xfec00000,0x80114814
80102a9a:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a9d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102aa4:	e8 b3 ff ff ff       	call   80102a5c <ioapicread>
80102aa9:	c1 e8 10             	shr    $0x10,%eax
80102aac:	25 ff 00 00 00       	and    $0xff,%eax
80102ab1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102ab4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102abb:	e8 9c ff ff ff       	call   80102a5c <ioapicread>
80102ac0:	c1 e8 18             	shr    $0x18,%eax
80102ac3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102ac6:	a0 40 49 11 80       	mov    0x80114940,%al
80102acb:	0f b6 c0             	movzbl %al,%eax
80102ace:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102ad1:	74 0c                	je     80102adf <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102ad3:	c7 04 24 4c 90 10 80 	movl   $0x8010904c,(%esp)
80102ada:	e8 e2 d8 ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102adf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102ae6:	eb 3d                	jmp    80102b25 <ioapicinit+0x98>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aeb:	83 c0 20             	add    $0x20,%eax
80102aee:	0d 00 00 01 00       	or     $0x10000,%eax
80102af3:	89 c2                	mov    %eax,%edx
80102af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af8:	83 c0 08             	add    $0x8,%eax
80102afb:	01 c0                	add    %eax,%eax
80102afd:	89 54 24 04          	mov    %edx,0x4(%esp)
80102b01:	89 04 24             	mov    %eax,(%esp)
80102b04:	e8 6a ff ff ff       	call   80102a73 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b0c:	83 c0 08             	add    $0x8,%eax
80102b0f:	01 c0                	add    %eax,%eax
80102b11:	40                   	inc    %eax
80102b12:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102b19:	00 
80102b1a:	89 04 24             	mov    %eax,(%esp)
80102b1d:	e8 51 ff ff ff       	call   80102a73 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102b22:	ff 45 f4             	incl   -0xc(%ebp)
80102b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b28:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102b2b:	7e bb                	jle    80102ae8 <ioapicinit+0x5b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102b2d:	c9                   	leave  
80102b2e:	c3                   	ret    

80102b2f <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102b2f:	55                   	push   %ebp
80102b30:	89 e5                	mov    %esp,%ebp
80102b32:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102b35:	8b 45 08             	mov    0x8(%ebp),%eax
80102b38:	83 c0 20             	add    $0x20,%eax
80102b3b:	89 c2                	mov    %eax,%edx
80102b3d:	8b 45 08             	mov    0x8(%ebp),%eax
80102b40:	83 c0 08             	add    $0x8,%eax
80102b43:	01 c0                	add    %eax,%eax
80102b45:	89 54 24 04          	mov    %edx,0x4(%esp)
80102b49:	89 04 24             	mov    %eax,(%esp)
80102b4c:	e8 22 ff ff ff       	call   80102a73 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102b51:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b54:	c1 e0 18             	shl    $0x18,%eax
80102b57:	8b 55 08             	mov    0x8(%ebp),%edx
80102b5a:	83 c2 08             	add    $0x8,%edx
80102b5d:	01 d2                	add    %edx,%edx
80102b5f:	42                   	inc    %edx
80102b60:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b64:	89 14 24             	mov    %edx,(%esp)
80102b67:	e8 07 ff ff ff       	call   80102a73 <ioapicwrite>
}
80102b6c:	c9                   	leave  
80102b6d:	c3                   	ret    
	...

80102b70 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b70:	55                   	push   %ebp
80102b71:	89 e5                	mov    %esp,%ebp
80102b73:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102b76:	c7 44 24 04 7e 90 10 	movl   $0x8010907e,0x4(%esp)
80102b7d:	80 
80102b7e:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102b85:	e8 e8 29 00 00       	call   80105572 <initlock>
  kmem.use_lock = 0;
80102b8a:	c7 05 54 48 11 80 00 	movl   $0x0,0x80114854
80102b91:	00 00 00 
  freerange(vstart, vend);
80102b94:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b97:	89 44 24 04          	mov    %eax,0x4(%esp)
80102b9b:	8b 45 08             	mov    0x8(%ebp),%eax
80102b9e:	89 04 24             	mov    %eax,(%esp)
80102ba1:	e8 26 00 00 00       	call   80102bcc <freerange>
}
80102ba6:	c9                   	leave  
80102ba7:	c3                   	ret    

80102ba8 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102ba8:	55                   	push   %ebp
80102ba9:	89 e5                	mov    %esp,%ebp
80102bab:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102bae:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bb1:	89 44 24 04          	mov    %eax,0x4(%esp)
80102bb5:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb8:	89 04 24             	mov    %eax,(%esp)
80102bbb:	e8 0c 00 00 00       	call   80102bcc <freerange>
  kmem.use_lock = 1;
80102bc0:	c7 05 54 48 11 80 01 	movl   $0x1,0x80114854
80102bc7:	00 00 00 
}
80102bca:	c9                   	leave  
80102bcb:	c3                   	ret    

80102bcc <freerange>:

void
freerange(void *vstart, void *vend)
{
80102bcc:	55                   	push   %ebp
80102bcd:	89 e5                	mov    %esp,%ebp
80102bcf:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102bd2:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd5:	05 ff 0f 00 00       	add    $0xfff,%eax
80102bda:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102bdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102be2:	eb 12                	jmp    80102bf6 <freerange+0x2a>
    kfree(p);
80102be4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102be7:	89 04 24             	mov    %eax,(%esp)
80102bea:	e8 16 00 00 00       	call   80102c05 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102bef:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bf9:	05 00 10 00 00       	add    $0x1000,%eax
80102bfe:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102c01:	76 e1                	jbe    80102be4 <freerange+0x18>
    kfree(p);
}
80102c03:	c9                   	leave  
80102c04:	c3                   	ret    

80102c05 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102c05:	55                   	push   %ebp
80102c06:	89 e5                	mov    %esp,%ebp
80102c08:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80102c0e:	25 ff 0f 00 00       	and    $0xfff,%eax
80102c13:	85 c0                	test   %eax,%eax
80102c15:	75 18                	jne    80102c2f <kfree+0x2a>
80102c17:	81 7d 08 48 61 12 80 	cmpl   $0x80126148,0x8(%ebp)
80102c1e:	72 0f                	jb     80102c2f <kfree+0x2a>
80102c20:	8b 45 08             	mov    0x8(%ebp),%eax
80102c23:	05 00 00 00 80       	add    $0x80000000,%eax
80102c28:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102c2d:	76 0c                	jbe    80102c3b <kfree+0x36>
    panic("kfree");
80102c2f:	c7 04 24 83 90 10 80 	movl   $0x80109083,(%esp)
80102c36:	e8 19 d9 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102c3b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102c42:	00 
80102c43:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102c4a:	00 
80102c4b:	8b 45 08             	mov    0x8(%ebp),%eax
80102c4e:	89 04 24             	mov    %eax,(%esp)
80102c51:	e8 a0 2b 00 00       	call   801057f6 <memset>

  if(kmem.use_lock)
80102c56:	a1 54 48 11 80       	mov    0x80114854,%eax
80102c5b:	85 c0                	test   %eax,%eax
80102c5d:	74 0c                	je     80102c6b <kfree+0x66>
    acquire(&kmem.lock);
80102c5f:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102c66:	e8 28 29 00 00       	call   80105593 <acquire>
  r = (struct run*)v;
80102c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80102c6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c71:	8b 15 58 48 11 80    	mov    0x80114858,%edx
80102c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c7a:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c7f:	a3 58 48 11 80       	mov    %eax,0x80114858
  if(kmem.use_lock)
80102c84:	a1 54 48 11 80       	mov    0x80114854,%eax
80102c89:	85 c0                	test   %eax,%eax
80102c8b:	74 0c                	je     80102c99 <kfree+0x94>
    release(&kmem.lock);
80102c8d:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102c94:	e8 64 29 00 00       	call   801055fd <release>
}
80102c99:	c9                   	leave  
80102c9a:	c3                   	ret    

80102c9b <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c9b:	55                   	push   %ebp
80102c9c:	89 e5                	mov    %esp,%ebp
80102c9e:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102ca1:	a1 54 48 11 80       	mov    0x80114854,%eax
80102ca6:	85 c0                	test   %eax,%eax
80102ca8:	74 0c                	je     80102cb6 <kalloc+0x1b>
    acquire(&kmem.lock);
80102caa:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102cb1:	e8 dd 28 00 00       	call   80105593 <acquire>
  r = kmem.freelist;
80102cb6:	a1 58 48 11 80       	mov    0x80114858,%eax
80102cbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102cbe:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102cc2:	74 0a                	je     80102cce <kalloc+0x33>
    kmem.freelist = r->next;
80102cc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc7:	8b 00                	mov    (%eax),%eax
80102cc9:	a3 58 48 11 80       	mov    %eax,0x80114858
  if(kmem.use_lock)
80102cce:	a1 54 48 11 80       	mov    0x80114854,%eax
80102cd3:	85 c0                	test   %eax,%eax
80102cd5:	74 0c                	je     80102ce3 <kalloc+0x48>
    release(&kmem.lock);
80102cd7:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102cde:	e8 1a 29 00 00       	call   801055fd <release>
  return (char*)r;
80102ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102ce6:	c9                   	leave  
80102ce7:	c3                   	ret    

80102ce8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102ce8:	55                   	push   %ebp
80102ce9:	89 e5                	mov    %esp,%ebp
80102ceb:	83 ec 14             	sub    $0x14,%esp
80102cee:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cf5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102cf8:	89 c2                	mov    %eax,%edx
80102cfa:	ec                   	in     (%dx),%al
80102cfb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cfe:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102d01:	c9                   	leave  
80102d02:	c3                   	ret    

80102d03 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102d03:	55                   	push   %ebp
80102d04:	89 e5                	mov    %esp,%ebp
80102d06:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102d09:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102d10:	e8 d3 ff ff ff       	call   80102ce8 <inb>
80102d15:	0f b6 c0             	movzbl %al,%eax
80102d18:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d1e:	83 e0 01             	and    $0x1,%eax
80102d21:	85 c0                	test   %eax,%eax
80102d23:	75 0a                	jne    80102d2f <kbdgetc+0x2c>
    return -1;
80102d25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d2a:	e9 21 01 00 00       	jmp    80102e50 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102d2f:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102d36:	e8 ad ff ff ff       	call   80102ce8 <inb>
80102d3b:	0f b6 c0             	movzbl %al,%eax
80102d3e:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102d41:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102d48:	75 17                	jne    80102d61 <kbdgetc+0x5e>
    shift |= E0ESC;
80102d4a:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102d4f:	83 c8 40             	or     $0x40,%eax
80102d52:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
    return 0;
80102d57:	b8 00 00 00 00       	mov    $0x0,%eax
80102d5c:	e9 ef 00 00 00       	jmp    80102e50 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d61:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d64:	25 80 00 00 00       	and    $0x80,%eax
80102d69:	85 c0                	test   %eax,%eax
80102d6b:	74 44                	je     80102db1 <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d6d:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102d72:	83 e0 40             	and    $0x40,%eax
80102d75:	85 c0                	test   %eax,%eax
80102d77:	75 08                	jne    80102d81 <kbdgetc+0x7e>
80102d79:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d7c:	83 e0 7f             	and    $0x7f,%eax
80102d7f:	eb 03                	jmp    80102d84 <kbdgetc+0x81>
80102d81:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d84:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d87:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d8a:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102d8f:	8a 00                	mov    (%eax),%al
80102d91:	83 c8 40             	or     $0x40,%eax
80102d94:	0f b6 c0             	movzbl %al,%eax
80102d97:	f7 d0                	not    %eax
80102d99:	89 c2                	mov    %eax,%edx
80102d9b:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102da0:	21 d0                	and    %edx,%eax
80102da2:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
    return 0;
80102da7:	b8 00 00 00 00       	mov    $0x0,%eax
80102dac:	e9 9f 00 00 00       	jmp    80102e50 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102db1:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102db6:	83 e0 40             	and    $0x40,%eax
80102db9:	85 c0                	test   %eax,%eax
80102dbb:	74 14                	je     80102dd1 <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102dbd:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102dc4:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102dc9:	83 e0 bf             	and    $0xffffffbf,%eax
80102dcc:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
  }

  shift |= shiftcode[data];
80102dd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dd4:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102dd9:	8a 00                	mov    (%eax),%al
80102ddb:	0f b6 d0             	movzbl %al,%edx
80102dde:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102de3:	09 d0                	or     %edx,%eax
80102de5:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
  shift ^= togglecode[data];
80102dea:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ded:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102df2:	8a 00                	mov    (%eax),%al
80102df4:	0f b6 d0             	movzbl %al,%edx
80102df7:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102dfc:	31 d0                	xor    %edx,%eax
80102dfe:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
  c = charcode[shift & (CTL | SHIFT)][data];
80102e03:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102e08:	83 e0 03             	and    $0x3,%eax
80102e0b:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102e12:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e15:	01 d0                	add    %edx,%eax
80102e17:	8a 00                	mov    (%eax),%al
80102e19:	0f b6 c0             	movzbl %al,%eax
80102e1c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102e1f:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102e24:	83 e0 08             	and    $0x8,%eax
80102e27:	85 c0                	test   %eax,%eax
80102e29:	74 22                	je     80102e4d <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102e2b:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102e2f:	76 0c                	jbe    80102e3d <kbdgetc+0x13a>
80102e31:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102e35:	77 06                	ja     80102e3d <kbdgetc+0x13a>
      c += 'A' - 'a';
80102e37:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102e3b:	eb 10                	jmp    80102e4d <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102e3d:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102e41:	76 0a                	jbe    80102e4d <kbdgetc+0x14a>
80102e43:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e47:	77 04                	ja     80102e4d <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e49:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e50:	c9                   	leave  
80102e51:	c3                   	ret    

80102e52 <kbdintr>:

void
kbdintr(void)
{
80102e52:	55                   	push   %ebp
80102e53:	89 e5                	mov    %esp,%ebp
80102e55:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102e58:	c7 04 24 03 2d 10 80 	movl   $0x80102d03,(%esp)
80102e5f:	e8 91 d9 ff ff       	call   801007f5 <consoleintr>
}
80102e64:	c9                   	leave  
80102e65:	c3                   	ret    
	...

80102e68 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e68:	55                   	push   %ebp
80102e69:	89 e5                	mov    %esp,%ebp
80102e6b:	83 ec 14             	sub    $0x14,%esp
80102e6e:	8b 45 08             	mov    0x8(%ebp),%eax
80102e71:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e75:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e78:	89 c2                	mov    %eax,%edx
80102e7a:	ec                   	in     (%dx),%al
80102e7b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e7e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102e81:	c9                   	leave  
80102e82:	c3                   	ret    

80102e83 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102e83:	55                   	push   %ebp
80102e84:	89 e5                	mov    %esp,%ebp
80102e86:	83 ec 08             	sub    $0x8,%esp
80102e89:	8b 45 08             	mov    0x8(%ebp),%eax
80102e8c:	8b 55 0c             	mov    0xc(%ebp),%edx
80102e8f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102e93:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e96:	8a 45 f8             	mov    -0x8(%ebp),%al
80102e99:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102e9c:	ee                   	out    %al,(%dx)
}
80102e9d:	c9                   	leave  
80102e9e:	c3                   	ret    

80102e9f <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102e9f:	55                   	push   %ebp
80102ea0:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102ea2:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80102ea7:	8b 55 08             	mov    0x8(%ebp),%edx
80102eaa:	c1 e2 02             	shl    $0x2,%edx
80102ead:	01 c2                	add    %eax,%edx
80102eaf:	8b 45 0c             	mov    0xc(%ebp),%eax
80102eb2:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102eb4:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80102eb9:	83 c0 20             	add    $0x20,%eax
80102ebc:	8b 00                	mov    (%eax),%eax
}
80102ebe:	5d                   	pop    %ebp
80102ebf:	c3                   	ret    

80102ec0 <lapicinit>:

void
lapicinit(void)
{
80102ec0:	55                   	push   %ebp
80102ec1:	89 e5                	mov    %esp,%ebp
80102ec3:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80102ec6:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80102ecb:	85 c0                	test   %eax,%eax
80102ecd:	75 05                	jne    80102ed4 <lapicinit+0x14>
    return;
80102ecf:	e9 43 01 00 00       	jmp    80103017 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ed4:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102edb:	00 
80102edc:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102ee3:	e8 b7 ff ff ff       	call   80102e9f <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102ee8:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102eef:	00 
80102ef0:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102ef7:	e8 a3 ff ff ff       	call   80102e9f <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102efc:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102f03:	00 
80102f04:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102f0b:	e8 8f ff ff ff       	call   80102e9f <lapicw>
  lapicw(TICR, 10000000);
80102f10:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80102f17:	00 
80102f18:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80102f1f:	e8 7b ff ff ff       	call   80102e9f <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102f24:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102f2b:	00 
80102f2c:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
80102f33:	e8 67 ff ff ff       	call   80102e9f <lapicw>
  lapicw(LINT1, MASKED);
80102f38:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102f3f:	00 
80102f40:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80102f47:	e8 53 ff ff ff       	call   80102e9f <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f4c:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80102f51:	83 c0 30             	add    $0x30,%eax
80102f54:	8b 00                	mov    (%eax),%eax
80102f56:	c1 e8 10             	shr    $0x10,%eax
80102f59:	0f b6 c0             	movzbl %al,%eax
80102f5c:	83 f8 03             	cmp    $0x3,%eax
80102f5f:	76 14                	jbe    80102f75 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80102f61:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80102f68:	00 
80102f69:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80102f70:	e8 2a ff ff ff       	call   80102e9f <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f75:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80102f7c:	00 
80102f7d:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80102f84:	e8 16 ff ff ff       	call   80102e9f <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f89:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102f90:	00 
80102f91:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102f98:	e8 02 ff ff ff       	call   80102e9f <lapicw>
  lapicw(ESR, 0);
80102f9d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102fa4:	00 
80102fa5:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80102fac:	e8 ee fe ff ff       	call   80102e9f <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102fb1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102fb8:	00 
80102fb9:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80102fc0:	e8 da fe ff ff       	call   80102e9f <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102fc5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102fcc:	00 
80102fcd:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80102fd4:	e8 c6 fe ff ff       	call   80102e9f <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102fd9:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80102fe0:	00 
80102fe1:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80102fe8:	e8 b2 fe ff ff       	call   80102e9f <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102fed:	90                   	nop
80102fee:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80102ff3:	05 00 03 00 00       	add    $0x300,%eax
80102ff8:	8b 00                	mov    (%eax),%eax
80102ffa:	25 00 10 00 00       	and    $0x1000,%eax
80102fff:	85 c0                	test   %eax,%eax
80103001:	75 eb                	jne    80102fee <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80103003:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010300a:	00 
8010300b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80103012:	e8 88 fe ff ff       	call   80102e9f <lapicw>
}
80103017:	c9                   	leave  
80103018:	c3                   	ret    

80103019 <lapicid>:

int
lapicid(void)
{
80103019:	55                   	push   %ebp
8010301a:	89 e5                	mov    %esp,%ebp
  if (!lapic)
8010301c:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80103021:	85 c0                	test   %eax,%eax
80103023:	75 07                	jne    8010302c <lapicid+0x13>
    return 0;
80103025:	b8 00 00 00 00       	mov    $0x0,%eax
8010302a:	eb 0d                	jmp    80103039 <lapicid+0x20>
  return lapic[ID] >> 24;
8010302c:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80103031:	83 c0 20             	add    $0x20,%eax
80103034:	8b 00                	mov    (%eax),%eax
80103036:	c1 e8 18             	shr    $0x18,%eax
}
80103039:	5d                   	pop    %ebp
8010303a:	c3                   	ret    

8010303b <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010303b:	55                   	push   %ebp
8010303c:	89 e5                	mov    %esp,%ebp
8010303e:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103041:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80103046:	85 c0                	test   %eax,%eax
80103048:	74 14                	je     8010305e <lapiceoi+0x23>
    lapicw(EOI, 0);
8010304a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103051:	00 
80103052:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103059:	e8 41 fe ff ff       	call   80102e9f <lapicw>
}
8010305e:	c9                   	leave  
8010305f:	c3                   	ret    

80103060 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103060:	55                   	push   %ebp
80103061:	89 e5                	mov    %esp,%ebp
}
80103063:	5d                   	pop    %ebp
80103064:	c3                   	ret    

80103065 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103065:	55                   	push   %ebp
80103066:	89 e5                	mov    %esp,%ebp
80103068:	83 ec 1c             	sub    $0x1c,%esp
8010306b:	8b 45 08             	mov    0x8(%ebp),%eax
8010306e:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103071:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103078:	00 
80103079:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103080:	e8 fe fd ff ff       	call   80102e83 <outb>
  outb(CMOS_PORT+1, 0x0A);
80103085:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010308c:	00 
8010308d:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103094:	e8 ea fd ff ff       	call   80102e83 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103099:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801030a0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801030a3:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801030a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801030ab:	8d 50 02             	lea    0x2(%eax),%edx
801030ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801030b1:	c1 e8 04             	shr    $0x4,%eax
801030b4:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801030b7:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030bb:	c1 e0 18             	shl    $0x18,%eax
801030be:	89 44 24 04          	mov    %eax,0x4(%esp)
801030c2:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801030c9:	e8 d1 fd ff ff       	call   80102e9f <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801030ce:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801030d5:	00 
801030d6:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801030dd:	e8 bd fd ff ff       	call   80102e9f <lapicw>
  microdelay(200);
801030e2:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030e9:	e8 72 ff ff ff       	call   80103060 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801030ee:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801030f5:	00 
801030f6:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801030fd:	e8 9d fd ff ff       	call   80102e9f <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80103102:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103109:	e8 52 ff ff ff       	call   80103060 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010310e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103115:	eb 3f                	jmp    80103156 <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
80103117:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010311b:	c1 e0 18             	shl    $0x18,%eax
8010311e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103122:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103129:	e8 71 fd ff ff       	call   80102e9f <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
8010312e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103131:	c1 e8 0c             	shr    $0xc,%eax
80103134:	80 cc 06             	or     $0x6,%ah
80103137:	89 44 24 04          	mov    %eax,0x4(%esp)
8010313b:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103142:	e8 58 fd ff ff       	call   80102e9f <lapicw>
    microdelay(200);
80103147:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010314e:	e8 0d ff ff ff       	call   80103060 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103153:	ff 45 fc             	incl   -0x4(%ebp)
80103156:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
8010315a:	7e bb                	jle    80103117 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
8010315c:	c9                   	leave  
8010315d:	c3                   	ret    

8010315e <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010315e:	55                   	push   %ebp
8010315f:	89 e5                	mov    %esp,%ebp
80103161:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103164:	8b 45 08             	mov    0x8(%ebp),%eax
80103167:	0f b6 c0             	movzbl %al,%eax
8010316a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010316e:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103175:	e8 09 fd ff ff       	call   80102e83 <outb>
  microdelay(200);
8010317a:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103181:	e8 da fe ff ff       	call   80103060 <microdelay>

  return inb(CMOS_RETURN);
80103186:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010318d:	e8 d6 fc ff ff       	call   80102e68 <inb>
80103192:	0f b6 c0             	movzbl %al,%eax
}
80103195:	c9                   	leave  
80103196:	c3                   	ret    

80103197 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103197:	55                   	push   %ebp
80103198:	89 e5                	mov    %esp,%ebp
8010319a:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
8010319d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801031a4:	e8 b5 ff ff ff       	call   8010315e <cmos_read>
801031a9:	8b 55 08             	mov    0x8(%ebp),%edx
801031ac:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801031ae:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801031b5:	e8 a4 ff ff ff       	call   8010315e <cmos_read>
801031ba:	8b 55 08             	mov    0x8(%ebp),%edx
801031bd:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801031c0:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801031c7:	e8 92 ff ff ff       	call   8010315e <cmos_read>
801031cc:	8b 55 08             	mov    0x8(%ebp),%edx
801031cf:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801031d2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
801031d9:	e8 80 ff ff ff       	call   8010315e <cmos_read>
801031de:	8b 55 08             	mov    0x8(%ebp),%edx
801031e1:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801031e4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801031eb:	e8 6e ff ff ff       	call   8010315e <cmos_read>
801031f0:	8b 55 08             	mov    0x8(%ebp),%edx
801031f3:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801031f6:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
801031fd:	e8 5c ff ff ff       	call   8010315e <cmos_read>
80103202:	8b 55 08             	mov    0x8(%ebp),%edx
80103205:	89 42 14             	mov    %eax,0x14(%edx)
}
80103208:	c9                   	leave  
80103209:	c3                   	ret    

8010320a <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
8010320a:	55                   	push   %ebp
8010320b:	89 e5                	mov    %esp,%ebp
8010320d:	57                   	push   %edi
8010320e:	56                   	push   %esi
8010320f:	53                   	push   %ebx
80103210:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80103213:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
8010321a:	e8 3f ff ff ff       	call   8010315e <cmos_read>
8010321f:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80103222:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103225:	83 e0 04             	and    $0x4,%eax
80103228:	85 c0                	test   %eax,%eax
8010322a:	0f 94 c0             	sete   %al
8010322d:	0f b6 c0             	movzbl %al,%eax
80103230:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80103233:	8d 45 c8             	lea    -0x38(%ebp),%eax
80103236:	89 04 24             	mov    %eax,(%esp)
80103239:	e8 59 ff ff ff       	call   80103197 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010323e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80103245:	e8 14 ff ff ff       	call   8010315e <cmos_read>
8010324a:	25 80 00 00 00       	and    $0x80,%eax
8010324f:	85 c0                	test   %eax,%eax
80103251:	74 02                	je     80103255 <cmostime+0x4b>
        continue;
80103253:	eb 36                	jmp    8010328b <cmostime+0x81>
    fill_rtcdate(&t2);
80103255:	8d 45 b0             	lea    -0x50(%ebp),%eax
80103258:	89 04 24             	mov    %eax,(%esp)
8010325b:	e8 37 ff ff ff       	call   80103197 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103260:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80103267:	00 
80103268:	8d 45 b0             	lea    -0x50(%ebp),%eax
8010326b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010326f:	8d 45 c8             	lea    -0x38(%ebp),%eax
80103272:	89 04 24             	mov    %eax,(%esp)
80103275:	e8 f3 25 00 00       	call   8010586d <memcmp>
8010327a:	85 c0                	test   %eax,%eax
8010327c:	75 0d                	jne    8010328b <cmostime+0x81>
      break;
8010327e:	90                   	nop
  }

  // convert
  if(bcd) {
8010327f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80103283:	0f 84 ac 00 00 00    	je     80103335 <cmostime+0x12b>
80103289:	eb 02                	jmp    8010328d <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010328b:	eb a6                	jmp    80103233 <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010328d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80103290:	c1 e8 04             	shr    $0x4,%eax
80103293:	89 c2                	mov    %eax,%edx
80103295:	89 d0                	mov    %edx,%eax
80103297:	c1 e0 02             	shl    $0x2,%eax
8010329a:	01 d0                	add    %edx,%eax
8010329c:	01 c0                	add    %eax,%eax
8010329e:	8b 55 c8             	mov    -0x38(%ebp),%edx
801032a1:	83 e2 0f             	and    $0xf,%edx
801032a4:	01 d0                	add    %edx,%eax
801032a6:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
801032a9:	8b 45 cc             	mov    -0x34(%ebp),%eax
801032ac:	c1 e8 04             	shr    $0x4,%eax
801032af:	89 c2                	mov    %eax,%edx
801032b1:	89 d0                	mov    %edx,%eax
801032b3:	c1 e0 02             	shl    $0x2,%eax
801032b6:	01 d0                	add    %edx,%eax
801032b8:	01 c0                	add    %eax,%eax
801032ba:	8b 55 cc             	mov    -0x34(%ebp),%edx
801032bd:	83 e2 0f             	and    $0xf,%edx
801032c0:	01 d0                	add    %edx,%eax
801032c2:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
801032c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
801032c8:	c1 e8 04             	shr    $0x4,%eax
801032cb:	89 c2                	mov    %eax,%edx
801032cd:	89 d0                	mov    %edx,%eax
801032cf:	c1 e0 02             	shl    $0x2,%eax
801032d2:	01 d0                	add    %edx,%eax
801032d4:	01 c0                	add    %eax,%eax
801032d6:	8b 55 d0             	mov    -0x30(%ebp),%edx
801032d9:	83 e2 0f             	and    $0xf,%edx
801032dc:	01 d0                	add    %edx,%eax
801032de:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
801032e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801032e4:	c1 e8 04             	shr    $0x4,%eax
801032e7:	89 c2                	mov    %eax,%edx
801032e9:	89 d0                	mov    %edx,%eax
801032eb:	c1 e0 02             	shl    $0x2,%eax
801032ee:	01 d0                	add    %edx,%eax
801032f0:	01 c0                	add    %eax,%eax
801032f2:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801032f5:	83 e2 0f             	and    $0xf,%edx
801032f8:	01 d0                	add    %edx,%eax
801032fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
801032fd:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103300:	c1 e8 04             	shr    $0x4,%eax
80103303:	89 c2                	mov    %eax,%edx
80103305:	89 d0                	mov    %edx,%eax
80103307:	c1 e0 02             	shl    $0x2,%eax
8010330a:	01 d0                	add    %edx,%eax
8010330c:	01 c0                	add    %eax,%eax
8010330e:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103311:	83 e2 0f             	and    $0xf,%edx
80103314:	01 d0                	add    %edx,%eax
80103316:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
80103319:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010331c:	c1 e8 04             	shr    $0x4,%eax
8010331f:	89 c2                	mov    %eax,%edx
80103321:	89 d0                	mov    %edx,%eax
80103323:	c1 e0 02             	shl    $0x2,%eax
80103326:	01 d0                	add    %edx,%eax
80103328:	01 c0                	add    %eax,%eax
8010332a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010332d:	83 e2 0f             	and    $0xf,%edx
80103330:	01 d0                	add    %edx,%eax
80103332:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
80103335:	8b 45 08             	mov    0x8(%ebp),%eax
80103338:	89 c2                	mov    %eax,%edx
8010333a:	8d 5d c8             	lea    -0x38(%ebp),%ebx
8010333d:	b8 06 00 00 00       	mov    $0x6,%eax
80103342:	89 d7                	mov    %edx,%edi
80103344:	89 de                	mov    %ebx,%esi
80103346:	89 c1                	mov    %eax,%ecx
80103348:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
8010334a:	8b 45 08             	mov    0x8(%ebp),%eax
8010334d:	8b 40 14             	mov    0x14(%eax),%eax
80103350:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103356:	8b 45 08             	mov    0x8(%ebp),%eax
80103359:	89 50 14             	mov    %edx,0x14(%eax)
}
8010335c:	83 c4 5c             	add    $0x5c,%esp
8010335f:	5b                   	pop    %ebx
80103360:	5e                   	pop    %esi
80103361:	5f                   	pop    %edi
80103362:	5d                   	pop    %ebp
80103363:	c3                   	ret    

80103364 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103364:	55                   	push   %ebp
80103365:	89 e5                	mov    %esp,%ebp
80103367:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010336a:	c7 44 24 04 89 90 10 	movl   $0x80109089,0x4(%esp)
80103371:	80 
80103372:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103379:	e8 f4 21 00 00       	call   80105572 <initlock>
  readsb(dev, &sb);
8010337e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103381:	89 44 24 04          	mov    %eax,0x4(%esp)
80103385:	8b 45 08             	mov    0x8(%ebp),%eax
80103388:	89 04 24             	mov    %eax,(%esp)
8010338b:	e8 94 e0 ff ff       	call   80101424 <readsb>
  log.start = sb.logstart;
80103390:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103393:	a3 94 48 11 80       	mov    %eax,0x80114894
  log.size = sb.nlog;
80103398:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010339b:	a3 98 48 11 80       	mov    %eax,0x80114898
  log.dev = dev;
801033a0:	8b 45 08             	mov    0x8(%ebp),%eax
801033a3:	a3 a4 48 11 80       	mov    %eax,0x801148a4
  recover_from_log();
801033a8:	e8 95 01 00 00       	call   80103542 <recover_from_log>
}
801033ad:	c9                   	leave  
801033ae:	c3                   	ret    

801033af <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
801033af:	55                   	push   %ebp
801033b0:	89 e5                	mov    %esp,%ebp
801033b2:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801033b5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033bc:	e9 89 00 00 00       	jmp    8010344a <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801033c1:	8b 15 94 48 11 80    	mov    0x80114894,%edx
801033c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033ca:	01 d0                	add    %edx,%eax
801033cc:	40                   	inc    %eax
801033cd:	89 c2                	mov    %eax,%edx
801033cf:	a1 a4 48 11 80       	mov    0x801148a4,%eax
801033d4:	89 54 24 04          	mov    %edx,0x4(%esp)
801033d8:	89 04 24             	mov    %eax,(%esp)
801033db:	e8 d5 cd ff ff       	call   801001b5 <bread>
801033e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801033e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033e6:	83 c0 10             	add    $0x10,%eax
801033e9:	8b 04 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%eax
801033f0:	89 c2                	mov    %eax,%edx
801033f2:	a1 a4 48 11 80       	mov    0x801148a4,%eax
801033f7:	89 54 24 04          	mov    %edx,0x4(%esp)
801033fb:	89 04 24             	mov    %eax,(%esp)
801033fe:	e8 b2 cd ff ff       	call   801001b5 <bread>
80103403:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80103406:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103409:	8d 50 5c             	lea    0x5c(%eax),%edx
8010340c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010340f:	83 c0 5c             	add    $0x5c,%eax
80103412:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103419:	00 
8010341a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010341e:	89 04 24             	mov    %eax,(%esp)
80103421:	e8 99 24 00 00       	call   801058bf <memmove>
    bwrite(dbuf);  // write dst to disk
80103426:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103429:	89 04 24             	mov    %eax,(%esp)
8010342c:	e8 bb cd ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
80103431:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103434:	89 04 24             	mov    %eax,(%esp)
80103437:	e8 f0 cd ff ff       	call   8010022c <brelse>
    brelse(dbuf);
8010343c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010343f:	89 04 24             	mov    %eax,(%esp)
80103442:	e8 e5 cd ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103447:	ff 45 f4             	incl   -0xc(%ebp)
8010344a:	a1 a8 48 11 80       	mov    0x801148a8,%eax
8010344f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103452:	0f 8f 69 ff ff ff    	jg     801033c1 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
80103458:	c9                   	leave  
80103459:	c3                   	ret    

8010345a <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010345a:	55                   	push   %ebp
8010345b:	89 e5                	mov    %esp,%ebp
8010345d:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103460:	a1 94 48 11 80       	mov    0x80114894,%eax
80103465:	89 c2                	mov    %eax,%edx
80103467:	a1 a4 48 11 80       	mov    0x801148a4,%eax
8010346c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103470:	89 04 24             	mov    %eax,(%esp)
80103473:	e8 3d cd ff ff       	call   801001b5 <bread>
80103478:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010347b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010347e:	83 c0 5c             	add    $0x5c,%eax
80103481:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103484:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103487:	8b 00                	mov    (%eax),%eax
80103489:	a3 a8 48 11 80       	mov    %eax,0x801148a8
  for (i = 0; i < log.lh.n; i++) {
8010348e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103495:	eb 1a                	jmp    801034b1 <read_head+0x57>
    log.lh.block[i] = lh->block[i];
80103497:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010349a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010349d:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801034a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034a4:	83 c2 10             	add    $0x10,%edx
801034a7:	89 04 95 6c 48 11 80 	mov    %eax,-0x7feeb794(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801034ae:	ff 45 f4             	incl   -0xc(%ebp)
801034b1:	a1 a8 48 11 80       	mov    0x801148a8,%eax
801034b6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034b9:	7f dc                	jg     80103497 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
801034bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034be:	89 04 24             	mov    %eax,(%esp)
801034c1:	e8 66 cd ff ff       	call   8010022c <brelse>
}
801034c6:	c9                   	leave  
801034c7:	c3                   	ret    

801034c8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801034c8:	55                   	push   %ebp
801034c9:	89 e5                	mov    %esp,%ebp
801034cb:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801034ce:	a1 94 48 11 80       	mov    0x80114894,%eax
801034d3:	89 c2                	mov    %eax,%edx
801034d5:	a1 a4 48 11 80       	mov    0x801148a4,%eax
801034da:	89 54 24 04          	mov    %edx,0x4(%esp)
801034de:	89 04 24             	mov    %eax,(%esp)
801034e1:	e8 cf cc ff ff       	call   801001b5 <bread>
801034e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034ec:	83 c0 5c             	add    $0x5c,%eax
801034ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034f2:	8b 15 a8 48 11 80    	mov    0x801148a8,%edx
801034f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034fb:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034fd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103504:	eb 1a                	jmp    80103520 <write_head+0x58>
    hb->block[i] = log.lh.block[i];
80103506:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103509:	83 c0 10             	add    $0x10,%eax
8010350c:	8b 0c 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%ecx
80103513:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103516:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103519:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010351d:	ff 45 f4             	incl   -0xc(%ebp)
80103520:	a1 a8 48 11 80       	mov    0x801148a8,%eax
80103525:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103528:	7f dc                	jg     80103506 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
8010352a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010352d:	89 04 24             	mov    %eax,(%esp)
80103530:	e8 b7 cc ff ff       	call   801001ec <bwrite>
  brelse(buf);
80103535:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103538:	89 04 24             	mov    %eax,(%esp)
8010353b:	e8 ec cc ff ff       	call   8010022c <brelse>
}
80103540:	c9                   	leave  
80103541:	c3                   	ret    

80103542 <recover_from_log>:

static void
recover_from_log(void)
{
80103542:	55                   	push   %ebp
80103543:	89 e5                	mov    %esp,%ebp
80103545:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103548:	e8 0d ff ff ff       	call   8010345a <read_head>
  install_trans(); // if committed, copy from log to disk
8010354d:	e8 5d fe ff ff       	call   801033af <install_trans>
  log.lh.n = 0;
80103552:	c7 05 a8 48 11 80 00 	movl   $0x0,0x801148a8
80103559:	00 00 00 
  write_head(); // clear the log
8010355c:	e8 67 ff ff ff       	call   801034c8 <write_head>
}
80103561:	c9                   	leave  
80103562:	c3                   	ret    

80103563 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103563:	55                   	push   %ebp
80103564:	89 e5                	mov    %esp,%ebp
80103566:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103569:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103570:	e8 1e 20 00 00       	call   80105593 <acquire>
  while(1){
    if(log.committing){
80103575:	a1 a0 48 11 80       	mov    0x801148a0,%eax
8010357a:	85 c0                	test   %eax,%eax
8010357c:	74 16                	je     80103594 <begin_op+0x31>
      sleep(&log, &log.lock);
8010357e:	c7 44 24 04 60 48 11 	movl   $0x80114860,0x4(%esp)
80103585:	80 
80103586:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
8010358d:	e8 12 13 00 00       	call   801048a4 <sleep>
80103592:	eb 4d                	jmp    801035e1 <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103594:	8b 15 a8 48 11 80    	mov    0x801148a8,%edx
8010359a:	a1 9c 48 11 80       	mov    0x8011489c,%eax
8010359f:	8d 48 01             	lea    0x1(%eax),%ecx
801035a2:	89 c8                	mov    %ecx,%eax
801035a4:	c1 e0 02             	shl    $0x2,%eax
801035a7:	01 c8                	add    %ecx,%eax
801035a9:	01 c0                	add    %eax,%eax
801035ab:	01 d0                	add    %edx,%eax
801035ad:	83 f8 1e             	cmp    $0x1e,%eax
801035b0:	7e 16                	jle    801035c8 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801035b2:	c7 44 24 04 60 48 11 	movl   $0x80114860,0x4(%esp)
801035b9:	80 
801035ba:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801035c1:	e8 de 12 00 00       	call   801048a4 <sleep>
801035c6:	eb 19                	jmp    801035e1 <begin_op+0x7e>
    } else {
      log.outstanding += 1;
801035c8:	a1 9c 48 11 80       	mov    0x8011489c,%eax
801035cd:	40                   	inc    %eax
801035ce:	a3 9c 48 11 80       	mov    %eax,0x8011489c
      release(&log.lock);
801035d3:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801035da:	e8 1e 20 00 00       	call   801055fd <release>
      break;
801035df:	eb 02                	jmp    801035e3 <begin_op+0x80>
    }
  }
801035e1:	eb 92                	jmp    80103575 <begin_op+0x12>
}
801035e3:	c9                   	leave  
801035e4:	c3                   	ret    

801035e5 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035e5:	55                   	push   %ebp
801035e6:	89 e5                	mov    %esp,%ebp
801035e8:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
801035eb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035f2:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801035f9:	e8 95 1f 00 00       	call   80105593 <acquire>
  log.outstanding -= 1;
801035fe:	a1 9c 48 11 80       	mov    0x8011489c,%eax
80103603:	48                   	dec    %eax
80103604:	a3 9c 48 11 80       	mov    %eax,0x8011489c
  if(log.committing)
80103609:	a1 a0 48 11 80       	mov    0x801148a0,%eax
8010360e:	85 c0                	test   %eax,%eax
80103610:	74 0c                	je     8010361e <end_op+0x39>
    panic("log.committing");
80103612:	c7 04 24 8d 90 10 80 	movl   $0x8010908d,(%esp)
80103619:	e8 36 cf ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
8010361e:	a1 9c 48 11 80       	mov    0x8011489c,%eax
80103623:	85 c0                	test   %eax,%eax
80103625:	75 13                	jne    8010363a <end_op+0x55>
    do_commit = 1;
80103627:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010362e:	c7 05 a0 48 11 80 01 	movl   $0x1,0x801148a0
80103635:	00 00 00 
80103638:	eb 0c                	jmp    80103646 <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
8010363a:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103641:	e8 4c 13 00 00       	call   80104992 <wakeup>
  }
  release(&log.lock);
80103646:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
8010364d:	e8 ab 1f 00 00       	call   801055fd <release>

  if(do_commit){
80103652:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103656:	74 33                	je     8010368b <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103658:	e8 db 00 00 00       	call   80103738 <commit>
    acquire(&log.lock);
8010365d:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103664:	e8 2a 1f 00 00       	call   80105593 <acquire>
    log.committing = 0;
80103669:	c7 05 a0 48 11 80 00 	movl   $0x0,0x801148a0
80103670:	00 00 00 
    wakeup(&log);
80103673:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
8010367a:	e8 13 13 00 00       	call   80104992 <wakeup>
    release(&log.lock);
8010367f:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103686:	e8 72 1f 00 00       	call   801055fd <release>
  }
}
8010368b:	c9                   	leave  
8010368c:	c3                   	ret    

8010368d <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010368d:	55                   	push   %ebp
8010368e:	89 e5                	mov    %esp,%ebp
80103690:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103693:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010369a:	e9 89 00 00 00       	jmp    80103728 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010369f:	8b 15 94 48 11 80    	mov    0x80114894,%edx
801036a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036a8:	01 d0                	add    %edx,%eax
801036aa:	40                   	inc    %eax
801036ab:	89 c2                	mov    %eax,%edx
801036ad:	a1 a4 48 11 80       	mov    0x801148a4,%eax
801036b2:	89 54 24 04          	mov    %edx,0x4(%esp)
801036b6:	89 04 24             	mov    %eax,(%esp)
801036b9:	e8 f7 ca ff ff       	call   801001b5 <bread>
801036be:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036c4:	83 c0 10             	add    $0x10,%eax
801036c7:	8b 04 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%eax
801036ce:	89 c2                	mov    %eax,%edx
801036d0:	a1 a4 48 11 80       	mov    0x801148a4,%eax
801036d5:	89 54 24 04          	mov    %edx,0x4(%esp)
801036d9:	89 04 24             	mov    %eax,(%esp)
801036dc:	e8 d4 ca ff ff       	call   801001b5 <bread>
801036e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036e7:	8d 50 5c             	lea    0x5c(%eax),%edx
801036ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036ed:	83 c0 5c             	add    $0x5c,%eax
801036f0:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801036f7:	00 
801036f8:	89 54 24 04          	mov    %edx,0x4(%esp)
801036fc:	89 04 24             	mov    %eax,(%esp)
801036ff:	e8 bb 21 00 00       	call   801058bf <memmove>
    bwrite(to);  // write the log
80103704:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103707:	89 04 24             	mov    %eax,(%esp)
8010370a:	e8 dd ca ff ff       	call   801001ec <bwrite>
    brelse(from);
8010370f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103712:	89 04 24             	mov    %eax,(%esp)
80103715:	e8 12 cb ff ff       	call   8010022c <brelse>
    brelse(to);
8010371a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010371d:	89 04 24             	mov    %eax,(%esp)
80103720:	e8 07 cb ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103725:	ff 45 f4             	incl   -0xc(%ebp)
80103728:	a1 a8 48 11 80       	mov    0x801148a8,%eax
8010372d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103730:	0f 8f 69 ff ff ff    	jg     8010369f <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
80103736:	c9                   	leave  
80103737:	c3                   	ret    

80103738 <commit>:

static void
commit()
{
80103738:	55                   	push   %ebp
80103739:	89 e5                	mov    %esp,%ebp
8010373b:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010373e:	a1 a8 48 11 80       	mov    0x801148a8,%eax
80103743:	85 c0                	test   %eax,%eax
80103745:	7e 1e                	jle    80103765 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103747:	e8 41 ff ff ff       	call   8010368d <write_log>
    write_head();    // Write header to disk -- the real commit
8010374c:	e8 77 fd ff ff       	call   801034c8 <write_head>
    install_trans(); // Now install writes to home locations
80103751:	e8 59 fc ff ff       	call   801033af <install_trans>
    log.lh.n = 0;
80103756:	c7 05 a8 48 11 80 00 	movl   $0x0,0x801148a8
8010375d:	00 00 00 
    write_head();    // Erase the transaction from the log
80103760:	e8 63 fd ff ff       	call   801034c8 <write_head>
  }
}
80103765:	c9                   	leave  
80103766:	c3                   	ret    

80103767 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103767:	55                   	push   %ebp
80103768:	89 e5                	mov    %esp,%ebp
8010376a:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010376d:	a1 a8 48 11 80       	mov    0x801148a8,%eax
80103772:	83 f8 1d             	cmp    $0x1d,%eax
80103775:	7f 10                	jg     80103787 <log_write+0x20>
80103777:	a1 a8 48 11 80       	mov    0x801148a8,%eax
8010377c:	8b 15 98 48 11 80    	mov    0x80114898,%edx
80103782:	4a                   	dec    %edx
80103783:	39 d0                	cmp    %edx,%eax
80103785:	7c 0c                	jl     80103793 <log_write+0x2c>
    panic("too big a transaction");
80103787:	c7 04 24 9c 90 10 80 	movl   $0x8010909c,(%esp)
8010378e:	e8 c1 cd ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
80103793:	a1 9c 48 11 80       	mov    0x8011489c,%eax
80103798:	85 c0                	test   %eax,%eax
8010379a:	7f 0c                	jg     801037a8 <log_write+0x41>
    panic("log_write outside of trans");
8010379c:	c7 04 24 b2 90 10 80 	movl   $0x801090b2,(%esp)
801037a3:	e8 ac cd ff ff       	call   80100554 <panic>

  acquire(&log.lock);
801037a8:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801037af:	e8 df 1d 00 00       	call   80105593 <acquire>
  for (i = 0; i < log.lh.n; i++) {
801037b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037bb:	eb 1e                	jmp    801037db <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037c0:	83 c0 10             	add    $0x10,%eax
801037c3:	8b 04 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%eax
801037ca:	89 c2                	mov    %eax,%edx
801037cc:	8b 45 08             	mov    0x8(%ebp),%eax
801037cf:	8b 40 08             	mov    0x8(%eax),%eax
801037d2:	39 c2                	cmp    %eax,%edx
801037d4:	75 02                	jne    801037d8 <log_write+0x71>
      break;
801037d6:	eb 0d                	jmp    801037e5 <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801037d8:	ff 45 f4             	incl   -0xc(%ebp)
801037db:	a1 a8 48 11 80       	mov    0x801148a8,%eax
801037e0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037e3:	7f d8                	jg     801037bd <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
801037e5:	8b 45 08             	mov    0x8(%ebp),%eax
801037e8:	8b 40 08             	mov    0x8(%eax),%eax
801037eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801037ee:	83 c2 10             	add    $0x10,%edx
801037f1:	89 04 95 6c 48 11 80 	mov    %eax,-0x7feeb794(,%edx,4)
  if (i == log.lh.n)
801037f8:	a1 a8 48 11 80       	mov    0x801148a8,%eax
801037fd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103800:	75 0b                	jne    8010380d <log_write+0xa6>
    log.lh.n++;
80103802:	a1 a8 48 11 80       	mov    0x801148a8,%eax
80103807:	40                   	inc    %eax
80103808:	a3 a8 48 11 80       	mov    %eax,0x801148a8
  b->flags |= B_DIRTY; // prevent eviction
8010380d:	8b 45 08             	mov    0x8(%ebp),%eax
80103810:	8b 00                	mov    (%eax),%eax
80103812:	83 c8 04             	or     $0x4,%eax
80103815:	89 c2                	mov    %eax,%edx
80103817:	8b 45 08             	mov    0x8(%ebp),%eax
8010381a:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010381c:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103823:	e8 d5 1d 00 00       	call   801055fd <release>
}
80103828:	c9                   	leave  
80103829:	c3                   	ret    
	...

8010382c <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010382c:	55                   	push   %ebp
8010382d:	89 e5                	mov    %esp,%ebp
8010382f:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103832:	8b 55 08             	mov    0x8(%ebp),%edx
80103835:	8b 45 0c             	mov    0xc(%ebp),%eax
80103838:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010383b:	f0 87 02             	lock xchg %eax,(%edx)
8010383e:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103841:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103844:	c9                   	leave  
80103845:	c3                   	ret    

80103846 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103846:	55                   	push   %ebp
80103847:	89 e5                	mov    %esp,%ebp
80103849:	83 e4 f0             	and    $0xfffffff0,%esp
8010384c:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010384f:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103856:	80 
80103857:	c7 04 24 48 61 12 80 	movl   $0x80126148,(%esp)
8010385e:	e8 0d f3 ff ff       	call   80102b70 <kinit1>
  kvmalloc();      // kernel page table
80103863:	e8 33 4d 00 00       	call   8010859b <kvmalloc>
  mpinit();        // detect other processors
80103868:	e8 c4 03 00 00       	call   80103c31 <mpinit>
  lapicinit();     // interrupt controller
8010386d:	e8 4e f6 ff ff       	call   80102ec0 <lapicinit>
  seginit();       // segment descriptors
80103872:	e8 0c 48 00 00       	call   80108083 <seginit>
  picinit();       // disable pic
80103877:	e8 04 05 00 00       	call   80103d80 <picinit>
  ioapicinit();    // another interrupt controller
8010387c:	e8 0c f2 ff ff       	call   80102a8d <ioapicinit>
  consoleinit();   // console hardware
80103881:	e8 31 d3 ff ff       	call   80100bb7 <consoleinit>
  uartinit();      // serial port
80103886:	e8 84 3b 00 00       	call   8010740f <uartinit>
  cinit();         // container table
8010388b:	e8 df 13 00 00       	call   80104c6f <cinit>
  tvinit();        // trap vectors
80103890:	e8 47 37 00 00       	call   80106fdc <tvinit>
  binit();         // buffer cache
80103895:	e8 9a c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
8010389a:	e8 a9 d7 ff ff       	call   80101048 <fileinit>
  ideinit();       // disk 
8010389f:	e8 f5 ed ff ff       	call   80102699 <ideinit>
  startothers();   // start other processors
801038a4:	e8 83 00 00 00       	call   8010392c <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801038a9:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801038b0:	8e 
801038b1:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801038b8:	e8 eb f2 ff ff       	call   80102ba8 <kinit2>
  userinit();      // first user process
801038bd:	e8 e9 14 00 00       	call   80104dab <userinit>
  mpmain();        // finish this processor's setup
801038c2:	e8 1a 00 00 00       	call   801038e1 <mpmain>

801038c7 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801038c7:	55                   	push   %ebp
801038c8:	89 e5                	mov    %esp,%ebp
801038ca:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801038cd:	e8 e0 4c 00 00       	call   801085b2 <switchkvm>
  seginit();
801038d2:	e8 ac 47 00 00       	call   80108083 <seginit>
  lapicinit();
801038d7:	e8 e4 f5 ff ff       	call   80102ec0 <lapicinit>
  mpmain();
801038dc:	e8 00 00 00 00       	call   801038e1 <mpmain>

801038e1 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801038e1:	55                   	push   %ebp
801038e2:	89 e5                	mov    %esp,%ebp
801038e4:	53                   	push   %ebx
801038e5:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801038e8:	e8 b9 12 00 00       	call   80104ba6 <cpuid>
801038ed:	89 c3                	mov    %eax,%ebx
801038ef:	e8 b2 12 00 00       	call   80104ba6 <cpuid>
801038f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801038f8:	89 44 24 04          	mov    %eax,0x4(%esp)
801038fc:	c7 04 24 cd 90 10 80 	movl   $0x801090cd,(%esp)
80103903:	e8 b9 ca ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
80103908:	e8 2c 38 00 00       	call   80107139 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
8010390d:	e8 d9 12 00 00       	call   80104beb <mycpu>
80103912:	05 a0 00 00 00       	add    $0xa0,%eax
80103917:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010391e:	00 
8010391f:	89 04 24             	mov    %eax,(%esp)
80103922:	e8 05 ff ff ff       	call   8010382c <xchg>
  scheduler();     // start running processes
80103927:	e8 6e 16 00 00       	call   80104f9a <scheduler>

8010392c <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010392c:	55                   	push   %ebp
8010392d:	89 e5                	mov    %esp,%ebp
8010392f:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103932:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103939:	b8 8a 00 00 00       	mov    $0x8a,%eax
8010393e:	89 44 24 08          	mov    %eax,0x8(%esp)
80103942:	c7 44 24 04 2c c5 10 	movl   $0x8010c52c,0x4(%esp)
80103949:	80 
8010394a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010394d:	89 04 24             	mov    %eax,(%esp)
80103950:	e8 6a 1f 00 00       	call   801058bf <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103955:	c7 45 f4 60 49 11 80 	movl   $0x80114960,-0xc(%ebp)
8010395c:	eb 75                	jmp    801039d3 <startothers+0xa7>
    if(c == mycpu())  // We've started already.
8010395e:	e8 88 12 00 00       	call   80104beb <mycpu>
80103963:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103966:	75 02                	jne    8010396a <startothers+0x3e>
      continue;
80103968:	eb 62                	jmp    801039cc <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010396a:	e8 2c f3 ff ff       	call   80102c9b <kalloc>
8010396f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103972:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103975:	83 e8 04             	sub    $0x4,%eax
80103978:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010397b:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103981:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103983:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103986:	83 e8 08             	sub    $0x8,%eax
80103989:	c7 00 c7 38 10 80    	movl   $0x801038c7,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
8010398f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103992:	8d 50 f4             	lea    -0xc(%eax),%edx
80103995:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
8010399a:	05 00 00 00 80       	add    $0x80000000,%eax
8010399f:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
801039a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039a4:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801039aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ad:	8a 00                	mov    (%eax),%al
801039af:	0f b6 c0             	movzbl %al,%eax
801039b2:	89 54 24 04          	mov    %edx,0x4(%esp)
801039b6:	89 04 24             	mov    %eax,(%esp)
801039b9:	e8 a7 f6 ff ff       	call   80103065 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801039be:	90                   	nop
801039bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039c2:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801039c8:	85 c0                	test   %eax,%eax
801039ca:	74 f3                	je     801039bf <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801039cc:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
801039d3:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
801039d8:	89 c2                	mov    %eax,%edx
801039da:	89 d0                	mov    %edx,%eax
801039dc:	c1 e0 02             	shl    $0x2,%eax
801039df:	01 d0                	add    %edx,%eax
801039e1:	01 c0                	add    %eax,%eax
801039e3:	01 d0                	add    %edx,%eax
801039e5:	c1 e0 04             	shl    $0x4,%eax
801039e8:	05 60 49 11 80       	add    $0x80114960,%eax
801039ed:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039f0:	0f 87 68 ff ff ff    	ja     8010395e <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801039f6:	c9                   	leave  
801039f7:	c3                   	ret    

801039f8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801039f8:	55                   	push   %ebp
801039f9:	89 e5                	mov    %esp,%ebp
801039fb:	83 ec 14             	sub    $0x14,%esp
801039fe:	8b 45 08             	mov    0x8(%ebp),%eax
80103a01:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103a05:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103a08:	89 c2                	mov    %eax,%edx
80103a0a:	ec                   	in     (%dx),%al
80103a0b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103a0e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103a11:	c9                   	leave  
80103a12:	c3                   	ret    

80103a13 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103a13:	55                   	push   %ebp
80103a14:	89 e5                	mov    %esp,%ebp
80103a16:	83 ec 08             	sub    $0x8,%esp
80103a19:	8b 45 08             	mov    0x8(%ebp),%eax
80103a1c:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a1f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103a23:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a26:	8a 45 f8             	mov    -0x8(%ebp),%al
80103a29:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a2c:	ee                   	out    %al,(%dx)
}
80103a2d:	c9                   	leave  
80103a2e:	c3                   	ret    

80103a2f <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103a2f:	55                   	push   %ebp
80103a30:	89 e5                	mov    %esp,%ebp
80103a32:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103a35:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a3c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a43:	eb 13                	jmp    80103a58 <sum+0x29>
    sum += addr[i];
80103a45:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a48:	8b 45 08             	mov    0x8(%ebp),%eax
80103a4b:	01 d0                	add    %edx,%eax
80103a4d:	8a 00                	mov    (%eax),%al
80103a4f:	0f b6 c0             	movzbl %al,%eax
80103a52:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103a55:	ff 45 fc             	incl   -0x4(%ebp)
80103a58:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a5b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a5e:	7c e5                	jl     80103a45 <sum+0x16>
    sum += addr[i];
  return sum;
80103a60:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a63:	c9                   	leave  
80103a64:	c3                   	ret    

80103a65 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a65:	55                   	push   %ebp
80103a66:	89 e5                	mov    %esp,%ebp
80103a68:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103a6b:	8b 45 08             	mov    0x8(%ebp),%eax
80103a6e:	05 00 00 00 80       	add    $0x80000000,%eax
80103a73:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a76:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a7c:	01 d0                	add    %edx,%eax
80103a7e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a84:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a87:	eb 3f                	jmp    80103ac8 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a89:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a90:	00 
80103a91:	c7 44 24 04 e4 90 10 	movl   $0x801090e4,0x4(%esp)
80103a98:	80 
80103a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a9c:	89 04 24             	mov    %eax,(%esp)
80103a9f:	e8 c9 1d 00 00       	call   8010586d <memcmp>
80103aa4:	85 c0                	test   %eax,%eax
80103aa6:	75 1c                	jne    80103ac4 <mpsearch1+0x5f>
80103aa8:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103aaf:	00 
80103ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab3:	89 04 24             	mov    %eax,(%esp)
80103ab6:	e8 74 ff ff ff       	call   80103a2f <sum>
80103abb:	84 c0                	test   %al,%al
80103abd:	75 05                	jne    80103ac4 <mpsearch1+0x5f>
      return (struct mp*)p;
80103abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ac2:	eb 11                	jmp    80103ad5 <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103ac4:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103acb:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103ace:	72 b9                	jb     80103a89 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103ad0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103ad5:	c9                   	leave  
80103ad6:	c3                   	ret    

80103ad7 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103ad7:	55                   	push   %ebp
80103ad8:	89 e5                	mov    %esp,%ebp
80103ada:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103add:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae7:	83 c0 0f             	add    $0xf,%eax
80103aea:	8a 00                	mov    (%eax),%al
80103aec:	0f b6 c0             	movzbl %al,%eax
80103aef:	c1 e0 08             	shl    $0x8,%eax
80103af2:	89 c2                	mov    %eax,%edx
80103af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af7:	83 c0 0e             	add    $0xe,%eax
80103afa:	8a 00                	mov    (%eax),%al
80103afc:	0f b6 c0             	movzbl %al,%eax
80103aff:	09 d0                	or     %edx,%eax
80103b01:	c1 e0 04             	shl    $0x4,%eax
80103b04:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103b07:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103b0b:	74 21                	je     80103b2e <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103b0d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b14:	00 
80103b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b18:	89 04 24             	mov    %eax,(%esp)
80103b1b:	e8 45 ff ff ff       	call   80103a65 <mpsearch1>
80103b20:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b23:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b27:	74 4e                	je     80103b77 <mpsearch+0xa0>
      return mp;
80103b29:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b2c:	eb 5d                	jmp    80103b8b <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103b2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b31:	83 c0 14             	add    $0x14,%eax
80103b34:	8a 00                	mov    (%eax),%al
80103b36:	0f b6 c0             	movzbl %al,%eax
80103b39:	c1 e0 08             	shl    $0x8,%eax
80103b3c:	89 c2                	mov    %eax,%edx
80103b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b41:	83 c0 13             	add    $0x13,%eax
80103b44:	8a 00                	mov    (%eax),%al
80103b46:	0f b6 c0             	movzbl %al,%eax
80103b49:	09 d0                	or     %edx,%eax
80103b4b:	c1 e0 0a             	shl    $0xa,%eax
80103b4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b54:	2d 00 04 00 00       	sub    $0x400,%eax
80103b59:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b60:	00 
80103b61:	89 04 24             	mov    %eax,(%esp)
80103b64:	e8 fc fe ff ff       	call   80103a65 <mpsearch1>
80103b69:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b6c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b70:	74 05                	je     80103b77 <mpsearch+0xa0>
      return mp;
80103b72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b75:	eb 14                	jmp    80103b8b <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b77:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b7e:	00 
80103b7f:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b86:	e8 da fe ff ff       	call   80103a65 <mpsearch1>
}
80103b8b:	c9                   	leave  
80103b8c:	c3                   	ret    

80103b8d <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b8d:	55                   	push   %ebp
80103b8e:	89 e5                	mov    %esp,%ebp
80103b90:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b93:	e8 3f ff ff ff       	call   80103ad7 <mpsearch>
80103b98:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b9b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b9f:	74 0a                	je     80103bab <mpconfig+0x1e>
80103ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba4:	8b 40 04             	mov    0x4(%eax),%eax
80103ba7:	85 c0                	test   %eax,%eax
80103ba9:	75 07                	jne    80103bb2 <mpconfig+0x25>
    return 0;
80103bab:	b8 00 00 00 00       	mov    $0x0,%eax
80103bb0:	eb 7d                	jmp    80103c2f <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103bb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb5:	8b 40 04             	mov    0x4(%eax),%eax
80103bb8:	05 00 00 00 80       	add    $0x80000000,%eax
80103bbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103bc0:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103bc7:	00 
80103bc8:	c7 44 24 04 e9 90 10 	movl   $0x801090e9,0x4(%esp)
80103bcf:	80 
80103bd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bd3:	89 04 24             	mov    %eax,(%esp)
80103bd6:	e8 92 1c 00 00       	call   8010586d <memcmp>
80103bdb:	85 c0                	test   %eax,%eax
80103bdd:	74 07                	je     80103be6 <mpconfig+0x59>
    return 0;
80103bdf:	b8 00 00 00 00       	mov    $0x0,%eax
80103be4:	eb 49                	jmp    80103c2f <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103be6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103be9:	8a 40 06             	mov    0x6(%eax),%al
80103bec:	3c 01                	cmp    $0x1,%al
80103bee:	74 11                	je     80103c01 <mpconfig+0x74>
80103bf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bf3:	8a 40 06             	mov    0x6(%eax),%al
80103bf6:	3c 04                	cmp    $0x4,%al
80103bf8:	74 07                	je     80103c01 <mpconfig+0x74>
    return 0;
80103bfa:	b8 00 00 00 00       	mov    $0x0,%eax
80103bff:	eb 2e                	jmp    80103c2f <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c04:	8b 40 04             	mov    0x4(%eax),%eax
80103c07:	0f b7 c0             	movzwl %ax,%eax
80103c0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80103c0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c11:	89 04 24             	mov    %eax,(%esp)
80103c14:	e8 16 fe ff ff       	call   80103a2f <sum>
80103c19:	84 c0                	test   %al,%al
80103c1b:	74 07                	je     80103c24 <mpconfig+0x97>
    return 0;
80103c1d:	b8 00 00 00 00       	mov    $0x0,%eax
80103c22:	eb 0b                	jmp    80103c2f <mpconfig+0xa2>
  *pmp = mp;
80103c24:	8b 45 08             	mov    0x8(%ebp),%eax
80103c27:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c2a:	89 10                	mov    %edx,(%eax)
  return conf;
80103c2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c2f:	c9                   	leave  
80103c30:	c3                   	ret    

80103c31 <mpinit>:

void
mpinit(void)
{
80103c31:	55                   	push   %ebp
80103c32:	89 e5                	mov    %esp,%ebp
80103c34:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103c37:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103c3a:	89 04 24             	mov    %eax,(%esp)
80103c3d:	e8 4b ff ff ff       	call   80103b8d <mpconfig>
80103c42:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c45:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c49:	75 0c                	jne    80103c57 <mpinit+0x26>
    panic("Expect to run on an SMP");
80103c4b:	c7 04 24 ee 90 10 80 	movl   $0x801090ee,(%esp)
80103c52:	e8 fd c8 ff ff       	call   80100554 <panic>
  ismp = 1;
80103c57:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103c5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c61:	8b 40 24             	mov    0x24(%eax),%eax
80103c64:	a3 5c 48 11 80       	mov    %eax,0x8011485c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c69:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c6c:	83 c0 2c             	add    $0x2c,%eax
80103c6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c75:	8b 40 04             	mov    0x4(%eax),%eax
80103c78:	0f b7 d0             	movzwl %ax,%edx
80103c7b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c7e:	01 d0                	add    %edx,%eax
80103c80:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103c83:	eb 7d                	jmp    80103d02 <mpinit+0xd1>
    switch(*p){
80103c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c88:	8a 00                	mov    (%eax),%al
80103c8a:	0f b6 c0             	movzbl %al,%eax
80103c8d:	83 f8 04             	cmp    $0x4,%eax
80103c90:	77 68                	ja     80103cfa <mpinit+0xc9>
80103c92:	8b 04 85 28 91 10 80 	mov    -0x7fef6ed8(,%eax,4),%eax
80103c99:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103ca1:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80103ca6:	83 f8 07             	cmp    $0x7,%eax
80103ca9:	7f 2c                	jg     80103cd7 <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103cab:	8b 15 e0 4e 11 80    	mov    0x80114ee0,%edx
80103cb1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103cb4:	8a 48 01             	mov    0x1(%eax),%cl
80103cb7:	89 d0                	mov    %edx,%eax
80103cb9:	c1 e0 02             	shl    $0x2,%eax
80103cbc:	01 d0                	add    %edx,%eax
80103cbe:	01 c0                	add    %eax,%eax
80103cc0:	01 d0                	add    %edx,%eax
80103cc2:	c1 e0 04             	shl    $0x4,%eax
80103cc5:	05 60 49 11 80       	add    $0x80114960,%eax
80103cca:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103ccc:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80103cd1:	40                   	inc    %eax
80103cd2:	a3 e0 4e 11 80       	mov    %eax,0x80114ee0
      }
      p += sizeof(struct mpproc);
80103cd7:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103cdb:	eb 25                	jmp    80103d02 <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103cdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce0:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103ce3:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ce6:	8a 40 01             	mov    0x1(%eax),%al
80103ce9:	a2 40 49 11 80       	mov    %al,0x80114940
      p += sizeof(struct mpioapic);
80103cee:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cf2:	eb 0e                	jmp    80103d02 <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103cf4:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cf8:	eb 08                	jmp    80103d02 <mpinit+0xd1>
    default:
      ismp = 0;
80103cfa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103d01:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d05:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103d08:	0f 82 77 ff ff ff    	jb     80103c85 <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103d0e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d12:	75 0c                	jne    80103d20 <mpinit+0xef>
    panic("Didn't find a suitable machine");
80103d14:	c7 04 24 08 91 10 80 	movl   $0x80109108,(%esp)
80103d1b:	e8 34 c8 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80103d20:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d23:	8a 40 0c             	mov    0xc(%eax),%al
80103d26:	84 c0                	test   %al,%al
80103d28:	74 36                	je     80103d60 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103d2a:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103d31:	00 
80103d32:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103d39:	e8 d5 fc ff ff       	call   80103a13 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103d3e:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d45:	e8 ae fc ff ff       	call   801039f8 <inb>
80103d4a:	83 c8 01             	or     $0x1,%eax
80103d4d:	0f b6 c0             	movzbl %al,%eax
80103d50:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d54:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d5b:	e8 b3 fc ff ff       	call   80103a13 <outb>
  }
}
80103d60:	c9                   	leave  
80103d61:	c3                   	ret    
	...

80103d64 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d64:	55                   	push   %ebp
80103d65:	89 e5                	mov    %esp,%ebp
80103d67:	83 ec 08             	sub    $0x8,%esp
80103d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80103d6d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d70:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103d74:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d77:	8a 45 f8             	mov    -0x8(%ebp),%al
80103d7a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103d7d:	ee                   	out    %al,(%dx)
}
80103d7e:	c9                   	leave  
80103d7f:	c3                   	ret    

80103d80 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103d80:	55                   	push   %ebp
80103d81:	89 e5                	mov    %esp,%ebp
80103d83:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103d86:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103d8d:	00 
80103d8e:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103d95:	e8 ca ff ff ff       	call   80103d64 <outb>
  outb(IO_PIC2+1, 0xFF);
80103d9a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103da1:	00 
80103da2:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103da9:	e8 b6 ff ff ff       	call   80103d64 <outb>
}
80103dae:	c9                   	leave  
80103daf:	c3                   	ret    

80103db0 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103db0:	55                   	push   %ebp
80103db1:	89 e5                	mov    %esp,%ebp
80103db3:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103db6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103dbd:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dc0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103dc9:	8b 10                	mov    (%eax),%edx
80103dcb:	8b 45 08             	mov    0x8(%ebp),%eax
80103dce:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103dd0:	e8 8f d2 ff ff       	call   80101064 <filealloc>
80103dd5:	8b 55 08             	mov    0x8(%ebp),%edx
80103dd8:	89 02                	mov    %eax,(%edx)
80103dda:	8b 45 08             	mov    0x8(%ebp),%eax
80103ddd:	8b 00                	mov    (%eax),%eax
80103ddf:	85 c0                	test   %eax,%eax
80103de1:	0f 84 c8 00 00 00    	je     80103eaf <pipealloc+0xff>
80103de7:	e8 78 d2 ff ff       	call   80101064 <filealloc>
80103dec:	8b 55 0c             	mov    0xc(%ebp),%edx
80103def:	89 02                	mov    %eax,(%edx)
80103df1:	8b 45 0c             	mov    0xc(%ebp),%eax
80103df4:	8b 00                	mov    (%eax),%eax
80103df6:	85 c0                	test   %eax,%eax
80103df8:	0f 84 b1 00 00 00    	je     80103eaf <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103dfe:	e8 98 ee ff ff       	call   80102c9b <kalloc>
80103e03:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e06:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e0a:	75 05                	jne    80103e11 <pipealloc+0x61>
    goto bad;
80103e0c:	e9 9e 00 00 00       	jmp    80103eaf <pipealloc+0xff>
  p->readopen = 1;
80103e11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e14:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103e1b:	00 00 00 
  p->writeopen = 1;
80103e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e21:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103e28:	00 00 00 
  p->nwrite = 0;
80103e2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e2e:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103e35:	00 00 00 
  p->nread = 0;
80103e38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e3b:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103e42:	00 00 00 
  initlock(&p->lock, "pipe");
80103e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e48:	c7 44 24 04 3c 91 10 	movl   $0x8010913c,0x4(%esp)
80103e4f:	80 
80103e50:	89 04 24             	mov    %eax,(%esp)
80103e53:	e8 1a 17 00 00       	call   80105572 <initlock>
  (*f0)->type = FD_PIPE;
80103e58:	8b 45 08             	mov    0x8(%ebp),%eax
80103e5b:	8b 00                	mov    (%eax),%eax
80103e5d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103e63:	8b 45 08             	mov    0x8(%ebp),%eax
80103e66:	8b 00                	mov    (%eax),%eax
80103e68:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103e6c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e6f:	8b 00                	mov    (%eax),%eax
80103e71:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103e75:	8b 45 08             	mov    0x8(%ebp),%eax
80103e78:	8b 00                	mov    (%eax),%eax
80103e7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e7d:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103e80:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e83:	8b 00                	mov    (%eax),%eax
80103e85:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103e8b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e8e:	8b 00                	mov    (%eax),%eax
80103e90:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103e94:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e97:	8b 00                	mov    (%eax),%eax
80103e99:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103e9d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ea0:	8b 00                	mov    (%eax),%eax
80103ea2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ea5:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103ea8:	b8 00 00 00 00       	mov    $0x0,%eax
80103ead:	eb 42                	jmp    80103ef1 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103eaf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103eb3:	74 0b                	je     80103ec0 <pipealloc+0x110>
    kfree((char*)p);
80103eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103eb8:	89 04 24             	mov    %eax,(%esp)
80103ebb:	e8 45 ed ff ff       	call   80102c05 <kfree>
  if(*f0)
80103ec0:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec3:	8b 00                	mov    (%eax),%eax
80103ec5:	85 c0                	test   %eax,%eax
80103ec7:	74 0d                	je     80103ed6 <pipealloc+0x126>
    fileclose(*f0);
80103ec9:	8b 45 08             	mov    0x8(%ebp),%eax
80103ecc:	8b 00                	mov    (%eax),%eax
80103ece:	89 04 24             	mov    %eax,(%esp)
80103ed1:	e8 36 d2 ff ff       	call   8010110c <fileclose>
  if(*f1)
80103ed6:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ed9:	8b 00                	mov    (%eax),%eax
80103edb:	85 c0                	test   %eax,%eax
80103edd:	74 0d                	je     80103eec <pipealloc+0x13c>
    fileclose(*f1);
80103edf:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ee2:	8b 00                	mov    (%eax),%eax
80103ee4:	89 04 24             	mov    %eax,(%esp)
80103ee7:	e8 20 d2 ff ff       	call   8010110c <fileclose>
  return -1;
80103eec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103ef1:	c9                   	leave  
80103ef2:	c3                   	ret    

80103ef3 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103ef3:	55                   	push   %ebp
80103ef4:	89 e5                	mov    %esp,%ebp
80103ef6:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103ef9:	8b 45 08             	mov    0x8(%ebp),%eax
80103efc:	89 04 24             	mov    %eax,(%esp)
80103eff:	e8 8f 16 00 00       	call   80105593 <acquire>
  if(writable){
80103f04:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103f08:	74 1f                	je     80103f29 <pipeclose+0x36>
    p->writeopen = 0;
80103f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0d:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103f14:	00 00 00 
    wakeup(&p->nread);
80103f17:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1a:	05 34 02 00 00       	add    $0x234,%eax
80103f1f:	89 04 24             	mov    %eax,(%esp)
80103f22:	e8 6b 0a 00 00       	call   80104992 <wakeup>
80103f27:	eb 1d                	jmp    80103f46 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103f29:	8b 45 08             	mov    0x8(%ebp),%eax
80103f2c:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103f33:	00 00 00 
    wakeup(&p->nwrite);
80103f36:	8b 45 08             	mov    0x8(%ebp),%eax
80103f39:	05 38 02 00 00       	add    $0x238,%eax
80103f3e:	89 04 24             	mov    %eax,(%esp)
80103f41:	e8 4c 0a 00 00       	call   80104992 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103f46:	8b 45 08             	mov    0x8(%ebp),%eax
80103f49:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103f4f:	85 c0                	test   %eax,%eax
80103f51:	75 25                	jne    80103f78 <pipeclose+0x85>
80103f53:	8b 45 08             	mov    0x8(%ebp),%eax
80103f56:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103f5c:	85 c0                	test   %eax,%eax
80103f5e:	75 18                	jne    80103f78 <pipeclose+0x85>
    release(&p->lock);
80103f60:	8b 45 08             	mov    0x8(%ebp),%eax
80103f63:	89 04 24             	mov    %eax,(%esp)
80103f66:	e8 92 16 00 00       	call   801055fd <release>
    kfree((char*)p);
80103f6b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6e:	89 04 24             	mov    %eax,(%esp)
80103f71:	e8 8f ec ff ff       	call   80102c05 <kfree>
80103f76:	eb 0b                	jmp    80103f83 <pipeclose+0x90>
  } else
    release(&p->lock);
80103f78:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7b:	89 04 24             	mov    %eax,(%esp)
80103f7e:	e8 7a 16 00 00       	call   801055fd <release>
}
80103f83:	c9                   	leave  
80103f84:	c3                   	ret    

80103f85 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103f85:	55                   	push   %ebp
80103f86:	89 e5                	mov    %esp,%ebp
80103f88:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80103f8b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f8e:	89 04 24             	mov    %eax,(%esp)
80103f91:	e8 fd 15 00 00       	call   80105593 <acquire>
  for(i = 0; i < n; i++){
80103f96:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f9d:	e9 a3 00 00 00       	jmp    80104045 <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103fa2:	eb 56                	jmp    80103ffa <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
80103fa4:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa7:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103fad:	85 c0                	test   %eax,%eax
80103faf:	74 0c                	je     80103fbd <pipewrite+0x38>
80103fb1:	e8 aa 01 00 00       	call   80104160 <myproc>
80103fb6:	8b 40 24             	mov    0x24(%eax),%eax
80103fb9:	85 c0                	test   %eax,%eax
80103fbb:	74 15                	je     80103fd2 <pipewrite+0x4d>
        release(&p->lock);
80103fbd:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc0:	89 04 24             	mov    %eax,(%esp)
80103fc3:	e8 35 16 00 00       	call   801055fd <release>
        return -1;
80103fc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fcd:	e9 9d 00 00 00       	jmp    8010406f <pipewrite+0xea>
      }
      wakeup(&p->nread);
80103fd2:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd5:	05 34 02 00 00       	add    $0x234,%eax
80103fda:	89 04 24             	mov    %eax,(%esp)
80103fdd:	e8 b0 09 00 00       	call   80104992 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103fe2:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe5:	8b 55 08             	mov    0x8(%ebp),%edx
80103fe8:	81 c2 38 02 00 00    	add    $0x238,%edx
80103fee:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ff2:	89 14 24             	mov    %edx,(%esp)
80103ff5:	e8 aa 08 00 00       	call   801048a4 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103ffa:	8b 45 08             	mov    0x8(%ebp),%eax
80103ffd:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104003:	8b 45 08             	mov    0x8(%ebp),%eax
80104006:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010400c:	05 00 02 00 00       	add    $0x200,%eax
80104011:	39 c2                	cmp    %eax,%edx
80104013:	74 8f                	je     80103fa4 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104015:	8b 45 08             	mov    0x8(%ebp),%eax
80104018:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010401e:	8d 48 01             	lea    0x1(%eax),%ecx
80104021:	8b 55 08             	mov    0x8(%ebp),%edx
80104024:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
8010402a:	25 ff 01 00 00       	and    $0x1ff,%eax
8010402f:	89 c1                	mov    %eax,%ecx
80104031:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104034:	8b 45 0c             	mov    0xc(%ebp),%eax
80104037:	01 d0                	add    %edx,%eax
80104039:	8a 10                	mov    (%eax),%dl
8010403b:	8b 45 08             	mov    0x8(%ebp),%eax
8010403e:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104042:	ff 45 f4             	incl   -0xc(%ebp)
80104045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104048:	3b 45 10             	cmp    0x10(%ebp),%eax
8010404b:	0f 8c 51 ff ff ff    	jl     80103fa2 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104051:	8b 45 08             	mov    0x8(%ebp),%eax
80104054:	05 34 02 00 00       	add    $0x234,%eax
80104059:	89 04 24             	mov    %eax,(%esp)
8010405c:	e8 31 09 00 00       	call   80104992 <wakeup>
  release(&p->lock);
80104061:	8b 45 08             	mov    0x8(%ebp),%eax
80104064:	89 04 24             	mov    %eax,(%esp)
80104067:	e8 91 15 00 00       	call   801055fd <release>
  return n;
8010406c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010406f:	c9                   	leave  
80104070:	c3                   	ret    

80104071 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104071:	55                   	push   %ebp
80104072:	89 e5                	mov    %esp,%ebp
80104074:	53                   	push   %ebx
80104075:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104078:	8b 45 08             	mov    0x8(%ebp),%eax
8010407b:	89 04 24             	mov    %eax,(%esp)
8010407e:	e8 10 15 00 00       	call   80105593 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104083:	eb 39                	jmp    801040be <piperead+0x4d>
    if(myproc()->killed){
80104085:	e8 d6 00 00 00       	call   80104160 <myproc>
8010408a:	8b 40 24             	mov    0x24(%eax),%eax
8010408d:	85 c0                	test   %eax,%eax
8010408f:	74 15                	je     801040a6 <piperead+0x35>
      release(&p->lock);
80104091:	8b 45 08             	mov    0x8(%ebp),%eax
80104094:	89 04 24             	mov    %eax,(%esp)
80104097:	e8 61 15 00 00       	call   801055fd <release>
      return -1;
8010409c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040a1:	e9 b3 00 00 00       	jmp    80104159 <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801040a6:	8b 45 08             	mov    0x8(%ebp),%eax
801040a9:	8b 55 08             	mov    0x8(%ebp),%edx
801040ac:	81 c2 34 02 00 00    	add    $0x234,%edx
801040b2:	89 44 24 04          	mov    %eax,0x4(%esp)
801040b6:	89 14 24             	mov    %edx,(%esp)
801040b9:	e8 e6 07 00 00       	call   801048a4 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801040be:	8b 45 08             	mov    0x8(%ebp),%eax
801040c1:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801040c7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ca:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801040d0:	39 c2                	cmp    %eax,%edx
801040d2:	75 0d                	jne    801040e1 <piperead+0x70>
801040d4:	8b 45 08             	mov    0x8(%ebp),%eax
801040d7:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801040dd:	85 c0                	test   %eax,%eax
801040df:	75 a4                	jne    80104085 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801040e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801040e8:	eb 49                	jmp    80104133 <piperead+0xc2>
    if(p->nread == p->nwrite)
801040ea:	8b 45 08             	mov    0x8(%ebp),%eax
801040ed:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801040f3:	8b 45 08             	mov    0x8(%ebp),%eax
801040f6:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801040fc:	39 c2                	cmp    %eax,%edx
801040fe:	75 02                	jne    80104102 <piperead+0x91>
      break;
80104100:	eb 39                	jmp    8010413b <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104102:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104105:	8b 45 0c             	mov    0xc(%ebp),%eax
80104108:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010410b:	8b 45 08             	mov    0x8(%ebp),%eax
8010410e:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104114:	8d 48 01             	lea    0x1(%eax),%ecx
80104117:	8b 55 08             	mov    0x8(%ebp),%edx
8010411a:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104120:	25 ff 01 00 00       	and    $0x1ff,%eax
80104125:	89 c2                	mov    %eax,%edx
80104127:	8b 45 08             	mov    0x8(%ebp),%eax
8010412a:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
8010412e:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104130:	ff 45 f4             	incl   -0xc(%ebp)
80104133:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104136:	3b 45 10             	cmp    0x10(%ebp),%eax
80104139:	7c af                	jl     801040ea <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010413b:	8b 45 08             	mov    0x8(%ebp),%eax
8010413e:	05 38 02 00 00       	add    $0x238,%eax
80104143:	89 04 24             	mov    %eax,(%esp)
80104146:	e8 47 08 00 00       	call   80104992 <wakeup>
  release(&p->lock);
8010414b:	8b 45 08             	mov    0x8(%ebp),%eax
8010414e:	89 04 24             	mov    %eax,(%esp)
80104151:	e8 a7 14 00 00       	call   801055fd <release>
  return i;
80104156:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104159:	83 c4 24             	add    $0x24,%esp
8010415c:	5b                   	pop    %ebx
8010415d:	5d                   	pop    %ebp
8010415e:	c3                   	ret    
	...

80104160 <myproc>:
static void wakeup1(void *chan);

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104160:	55                   	push   %ebp
80104161:	89 e5                	mov    %esp,%ebp
80104163:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104166:	e8 87 15 00 00       	call   801056f2 <pushcli>
  c = mycpu();
8010416b:	e8 7b 0a 00 00       	call   80104beb <mycpu>
80104170:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104173:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104176:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010417c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
8010417f:	e8 b8 15 00 00       	call   8010573c <popcli>
  return p;
80104184:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104187:	c9                   	leave  
80104188:	c3                   	ret    

80104189 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
struct proc*
allocproc(struct cont *parentcont)
{
80104189:	55                   	push   %ebp
8010418a:	89 e5                	mov    %esp,%ebp
8010418c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;
  struct proc *ptable;
  int nproc;

  acquirectable();
8010418f:	e8 fc 0a 00 00       	call   80104c90 <acquirectable>

  ptable = parentcont->ptable;
80104194:	8b 45 08             	mov    0x8(%ebp),%eax
80104197:	8b 40 28             	mov    0x28(%eax),%eax
8010419a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  nproc = parentcont->mproc;
8010419d:	8b 45 08             	mov    0x8(%ebp),%eax
801041a0:	8b 40 08             	mov    0x8(%eax),%eax
801041a3:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for(p = ptable; p < &ptable[nproc]; p++) 
801041a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801041ac:	eb 4c                	jmp    801041fa <allocproc+0x71>
    if(p->state == UNUSED)
801041ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041b1:	8b 40 0c             	mov    0xc(%eax),%eax
801041b4:	85 c0                	test   %eax,%eax
801041b6:	75 3b                	jne    801041f3 <allocproc+0x6a>
      goto found;  
801041b8:	90                   	nop

  releasectable();
  return 0;

found:
  p->state = EMBRYO;
801041b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041bc:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;  
801041c3:	a1 00 c0 10 80       	mov    0x8010c000,%eax
801041c8:	8d 50 01             	lea    0x1(%eax),%edx
801041cb:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
801041d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041d4:	89 42 10             	mov    %eax,0x10(%edx)

  releasectable();  
801041d7:	e8 c8 0a 00 00       	call   80104ca4 <releasectable>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801041dc:	e8 ba ea ff ff       	call   80102c9b <kalloc>
801041e1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041e4:	89 42 08             	mov    %eax,0x8(%edx)
801041e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041ea:	8b 40 08             	mov    0x8(%eax),%eax
801041ed:	85 c0                	test   %eax,%eax
801041ef:	75 43                	jne    80104234 <allocproc+0xab>
801041f1:	eb 2d                	jmp    80104220 <allocproc+0x97>
  acquirectable();

  ptable = parentcont->ptable;
  nproc = parentcont->mproc;

  for(p = ptable; p < &ptable[nproc]; p++) 
801041f3:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801041fa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041fd:	c1 e0 02             	shl    $0x2,%eax
80104200:	89 c2                	mov    %eax,%edx
80104202:	c1 e2 05             	shl    $0x5,%edx
80104205:	01 c2                	add    %eax,%edx
80104207:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010420a:	01 d0                	add    %edx,%eax
8010420c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010420f:	77 9d                	ja     801041ae <allocproc+0x25>
    if(p->state == UNUSED)
      goto found;  

  releasectable();
80104211:	e8 8e 0a 00 00       	call   80104ca4 <releasectable>
  return 0;
80104216:	b8 00 00 00 00       	mov    $0x0,%eax
8010421b:	e9 94 00 00 00       	jmp    801042b4 <allocproc+0x12b>

  releasectable();  

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104220:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104223:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
8010422a:	b8 00 00 00 00       	mov    $0x0,%eax
8010422f:	e9 80 00 00 00       	jmp    801042b4 <allocproc+0x12b>
  }
  sp = p->kstack + KSTACKSIZE;
80104234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104237:	8b 40 08             	mov    0x8(%eax),%eax
8010423a:	05 00 10 00 00       	add    $0x1000,%eax
8010423f:	89 45 e8             	mov    %eax,-0x18(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104242:	83 6d e8 4c          	subl   $0x4c,-0x18(%ebp)
  p->tf = (struct trapframe*)sp;
80104246:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104249:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010424c:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010424f:	83 6d e8 04          	subl   $0x4,-0x18(%ebp)
  *(uint*)sp = (uint)trapret;
80104253:	ba 98 6f 10 80       	mov    $0x80106f98,%edx
80104258:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010425b:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010425d:	83 6d e8 14          	subl   $0x14,-0x18(%ebp)
  p->context = (struct context*)sp;
80104261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104264:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104267:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010426a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010426d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104270:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104277:	00 
80104278:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010427f:	00 
80104280:	89 04 24             	mov    %eax,(%esp)
80104283:	e8 6e 15 00 00       	call   801057f6 <memset>
  p->context->eip = (uint)forkret;
80104288:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010428b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010428e:	ba 6c 48 10 80       	mov    $0x8010486c,%edx
80104293:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
80104296:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104299:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->cont = parentcont;
801042a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042a3:	8b 55 08             	mov    0x8(%ebp),%edx
801042a6:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  procdump();
801042ac:	e8 93 07 00 00       	call   80104a44 <procdump>

  return p;
801042b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801042b4:	c9                   	leave  
801042b5:	c3                   	ret    

801042b6 <initprocess>:

// Set up first user process.
void
initprocess(void)
{
801042b6:	55                   	push   %ebp
801042b7:	89 e5                	mov    %esp,%ebp
801042b9:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc(rootcont());
801042bc:	e8 8a 0b 00 00       	call   80104e4b <rootcont>
801042c1:	89 04 24             	mov    %eax,(%esp)
801042c4:	e8 c0 fe ff ff       	call   80104189 <allocproc>
801042c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
801042cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042cf:	a3 80 c7 10 80       	mov    %eax,0x8010c780
  if((p->pgdir = setupkvm()) == 0)
801042d4:	e8 19 42 00 00       	call   801084f2 <setupkvm>
801042d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042dc:	89 42 04             	mov    %eax,0x4(%edx)
801042df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e2:	8b 40 04             	mov    0x4(%eax),%eax
801042e5:	85 c0                	test   %eax,%eax
801042e7:	75 0c                	jne    801042f5 <initprocess+0x3f>
    panic("userinit: out of memory?");
801042e9:	c7 04 24 41 91 10 80 	movl   $0x80109141,(%esp)
801042f0:	e8 5f c2 ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801042f5:	ba 2c 00 00 00       	mov    $0x2c,%edx
801042fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fd:	8b 40 04             	mov    0x4(%eax),%eax
80104300:	89 54 24 08          	mov    %edx,0x8(%esp)
80104304:	c7 44 24 04 00 c5 10 	movl   $0x8010c500,0x4(%esp)
8010430b:	80 
8010430c:	89 04 24             	mov    %eax,(%esp)
8010430f:	e8 3f 44 00 00       	call   80108753 <inituvm>
  p->sz = PGSIZE;
80104314:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104317:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
8010431d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104320:	8b 40 18             	mov    0x18(%eax),%eax
80104323:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
8010432a:	00 
8010432b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104332:	00 
80104333:	89 04 24             	mov    %eax,(%esp)
80104336:	e8 bb 14 00 00       	call   801057f6 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010433b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010433e:	8b 40 18             	mov    0x18(%eax),%eax
80104341:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104347:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434a:	8b 40 18             	mov    0x18(%eax),%eax
8010434d:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104353:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104356:	8b 50 18             	mov    0x18(%eax),%edx
80104359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435c:	8b 40 18             	mov    0x18(%eax),%eax
8010435f:	8b 40 2c             	mov    0x2c(%eax),%eax
80104362:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
80104366:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104369:	8b 50 18             	mov    0x18(%eax),%edx
8010436c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010436f:	8b 40 18             	mov    0x18(%eax),%eax
80104372:	8b 40 2c             	mov    0x2c(%eax),%eax
80104375:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
80104379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437c:	8b 40 18             	mov    0x18(%eax),%eax
8010437f:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104386:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104389:	8b 40 18             	mov    0x18(%eax),%eax
8010438c:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104396:	8b 40 18             	mov    0x18(%eax),%eax
80104399:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801043a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a3:	83 c0 6c             	add    $0x6c,%eax
801043a6:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801043ad:	00 
801043ae:	c7 44 24 04 5a 91 10 	movl   $0x8010915a,0x4(%esp)
801043b5:	80 
801043b6:	89 04 24             	mov    %eax,(%esp)
801043b9:	e8 44 16 00 00       	call   80105a02 <safestrcpy>
  p->cwd = namei("/");
801043be:	c7 04 24 63 91 10 80 	movl   $0x80109163,(%esp)
801043c5:	e8 c6 e1 ff ff       	call   80102590 <namei>
801043ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043cd:	89 42 68             	mov    %eax,0x68(%edx)

  // Set initial process's cont to root
  p->cont = rootcont();
801043d0:	e8 76 0a 00 00       	call   80104e4b <rootcont>
801043d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043d8:	89 82 80 00 00 00    	mov    %eax,0x80(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquirectable();
801043de:	e8 ad 08 00 00       	call   80104c90 <acquirectable>

  p->state = RUNNABLE;
801043e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e6:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  releasectable();
801043ed:	e8 b2 08 00 00       	call   80104ca4 <releasectable>
}
801043f2:	c9                   	leave  
801043f3:	c3                   	ret    

801043f4 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801043f4:	55                   	push   %ebp
801043f5:	89 e5                	mov    %esp,%ebp
801043f7:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
801043fa:	e8 61 fd ff ff       	call   80104160 <myproc>
801043ff:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80104402:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104405:	8b 00                	mov    (%eax),%eax
80104407:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
8010440a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010440e:	7e 31                	jle    80104441 <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104410:	8b 55 08             	mov    0x8(%ebp),%edx
80104413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104416:	01 c2                	add    %eax,%edx
80104418:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010441b:	8b 40 04             	mov    0x4(%eax),%eax
8010441e:	89 54 24 08          	mov    %edx,0x8(%esp)
80104422:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104425:	89 54 24 04          	mov    %edx,0x4(%esp)
80104429:	89 04 24             	mov    %eax,(%esp)
8010442c:	e8 8d 44 00 00       	call   801088be <allocuvm>
80104431:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104434:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104438:	75 3e                	jne    80104478 <growproc+0x84>
      return -1;
8010443a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010443f:	eb 4f                	jmp    80104490 <growproc+0x9c>
  } else if(n < 0){
80104441:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104445:	79 31                	jns    80104478 <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104447:	8b 55 08             	mov    0x8(%ebp),%edx
8010444a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444d:	01 c2                	add    %eax,%edx
8010444f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104452:	8b 40 04             	mov    0x4(%eax),%eax
80104455:	89 54 24 08          	mov    %edx,0x8(%esp)
80104459:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010445c:	89 54 24 04          	mov    %edx,0x4(%esp)
80104460:	89 04 24             	mov    %eax,(%esp)
80104463:	e8 6c 45 00 00       	call   801089d4 <deallocuvm>
80104468:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010446b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010446f:	75 07                	jne    80104478 <growproc+0x84>
      return -1;
80104471:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104476:	eb 18                	jmp    80104490 <growproc+0x9c>
  }
  curproc->sz = sz;
80104478:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010447b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010447e:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104480:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104483:	89 04 24             	mov    %eax,(%esp)
80104486:	e8 41 41 00 00       	call   801085cc <switchuvm>
  return 0;
8010448b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104490:	c9                   	leave  
80104491:	c3                   	ret    

80104492 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104492:	55                   	push   %ebp
80104493:	89 e5                	mov    %esp,%ebp
80104495:	57                   	push   %edi
80104496:	56                   	push   %esi
80104497:	53                   	push   %ebx
80104498:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
8010449b:	e8 c0 fc ff ff       	call   80104160 <myproc>
801044a0:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc(curproc->cont)) == 0){
801044a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044a6:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801044ac:	89 04 24             	mov    %eax,(%esp)
801044af:	e8 d5 fc ff ff       	call   80104189 <allocproc>
801044b4:	89 45 dc             	mov    %eax,-0x24(%ebp)
801044b7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801044bb:	75 0a                	jne    801044c7 <fork+0x35>
    return -1;
801044bd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044c2:	e9 27 01 00 00       	jmp    801045ee <fork+0x15c>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801044c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044ca:	8b 10                	mov    (%eax),%edx
801044cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044cf:	8b 40 04             	mov    0x4(%eax),%eax
801044d2:	89 54 24 04          	mov    %edx,0x4(%esp)
801044d6:	89 04 24             	mov    %eax,(%esp)
801044d9:	e8 96 46 00 00       	call   80108b74 <copyuvm>
801044de:	8b 55 dc             	mov    -0x24(%ebp),%edx
801044e1:	89 42 04             	mov    %eax,0x4(%edx)
801044e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044e7:	8b 40 04             	mov    0x4(%eax),%eax
801044ea:	85 c0                	test   %eax,%eax
801044ec:	75 2c                	jne    8010451a <fork+0x88>
    kfree(np->kstack);
801044ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044f1:	8b 40 08             	mov    0x8(%eax),%eax
801044f4:	89 04 24             	mov    %eax,(%esp)
801044f7:	e8 09 e7 ff ff       	call   80102c05 <kfree>
    np->kstack = 0;
801044fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044ff:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104506:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104509:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104510:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104515:	e9 d4 00 00 00       	jmp    801045ee <fork+0x15c>
  }
  np->sz = curproc->sz;
8010451a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010451d:	8b 10                	mov    (%eax),%edx
8010451f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104522:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104524:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104527:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010452a:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
8010452d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104530:	8b 50 18             	mov    0x18(%eax),%edx
80104533:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104536:	8b 40 18             	mov    0x18(%eax),%eax
80104539:	89 c3                	mov    %eax,%ebx
8010453b:	b8 13 00 00 00       	mov    $0x13,%eax
80104540:	89 d7                	mov    %edx,%edi
80104542:	89 de                	mov    %ebx,%esi
80104544:	89 c1                	mov    %eax,%ecx
80104546:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104548:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010454b:	8b 40 18             	mov    0x18(%eax),%eax
8010454e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104555:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010455c:	eb 36                	jmp    80104594 <fork+0x102>
    if(curproc->ofile[i])
8010455e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104561:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104564:	83 c2 08             	add    $0x8,%edx
80104567:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010456b:	85 c0                	test   %eax,%eax
8010456d:	74 22                	je     80104591 <fork+0xff>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010456f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104572:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104575:	83 c2 08             	add    $0x8,%edx
80104578:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010457c:	89 04 24             	mov    %eax,(%esp)
8010457f:	e8 40 cb ff ff       	call   801010c4 <filedup>
80104584:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104587:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010458a:	83 c1 08             	add    $0x8,%ecx
8010458d:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104591:	ff 45 e4             	incl   -0x1c(%ebp)
80104594:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104598:	7e c4                	jle    8010455e <fork+0xcc>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
8010459a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010459d:	8b 40 68             	mov    0x68(%eax),%eax
801045a0:	89 04 24             	mov    %eax,(%esp)
801045a3:	e8 4c d4 ff ff       	call   801019f4 <idup>
801045a8:	8b 55 dc             	mov    -0x24(%ebp),%edx
801045ab:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801045ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045b1:	8d 50 6c             	lea    0x6c(%eax),%edx
801045b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045b7:	83 c0 6c             	add    $0x6c,%eax
801045ba:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801045c1:	00 
801045c2:	89 54 24 04          	mov    %edx,0x4(%esp)
801045c6:	89 04 24             	mov    %eax,(%esp)
801045c9:	e8 34 14 00 00       	call   80105a02 <safestrcpy>

  pid = np->pid;
801045ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045d1:	8b 40 10             	mov    0x10(%eax),%eax
801045d4:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquirectable();
801045d7:	e8 b4 06 00 00       	call   80104c90 <acquirectable>

  np->state = RUNNABLE;
801045dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045df:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  releasectable();
801045e6:	e8 b9 06 00 00       	call   80104ca4 <releasectable>

  return pid;
801045eb:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801045ee:	83 c4 2c             	add    $0x2c,%esp
801045f1:	5b                   	pop    %ebx
801045f2:	5e                   	pop    %esi
801045f3:	5f                   	pop    %edi
801045f4:	5d                   	pop    %ebp
801045f5:	c3                   	ret    

801045f6 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801045f6:	55                   	push   %ebp
801045f7:	89 e5                	mov    %esp,%ebp
801045f9:	83 ec 38             	sub    $0x38,%esp
  struct proc *curproc = myproc();
801045fc:	e8 5f fb ff ff       	call   80104160 <myproc>
80104601:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  struct proc *ptable;
  int fd, nproc;

  if(curproc == initproc)
80104604:	a1 80 c7 10 80       	mov    0x8010c780,%eax
80104609:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010460c:	75 0c                	jne    8010461a <exit+0x24>
    panic("init exiting");
8010460e:	c7 04 24 65 91 10 80 	movl   $0x80109165,(%esp)
80104615:	e8 3a bf ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010461a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104621:	eb 3a                	jmp    8010465d <exit+0x67>
    if(curproc->ofile[fd]){
80104623:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104626:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104629:	83 c2 08             	add    $0x8,%edx
8010462c:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104630:	85 c0                	test   %eax,%eax
80104632:	74 26                	je     8010465a <exit+0x64>
      fileclose(curproc->ofile[fd]);
80104634:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104637:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010463a:	83 c2 08             	add    $0x8,%edx
8010463d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104641:	89 04 24             	mov    %eax,(%esp)
80104644:	e8 c3 ca ff ff       	call   8010110c <fileclose>
      curproc->ofile[fd] = 0;
80104649:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010464c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010464f:	83 c2 08             	add    $0x8,%edx
80104652:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104659:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010465a:	ff 45 f0             	incl   -0x10(%ebp)
8010465d:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104661:	7e c0                	jle    80104623 <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
80104663:	e8 fb ee ff ff       	call   80103563 <begin_op>
  iput(curproc->cwd);
80104668:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010466b:	8b 40 68             	mov    0x68(%eax),%eax
8010466e:	89 04 24             	mov    %eax,(%esp)
80104671:	e8 fe d4 ff ff       	call   80101b74 <iput>
  end_op();
80104676:	e8 6a ef ff ff       	call   801035e5 <end_op>
  curproc->cwd = 0;
8010467b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010467e:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquirectable();
80104685:	e8 06 06 00 00       	call   80104c90 <acquirectable>

  ptable = curproc->cont->ptable;
8010468a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010468d:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104693:	8b 40 28             	mov    0x28(%eax),%eax
80104696:	89 45 e8             	mov    %eax,-0x18(%ebp)
  nproc = curproc->cont->mproc;
80104699:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010469c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801046a2:	8b 40 08             	mov    0x8(%eax),%eax
801046a5:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801046a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046ab:	8b 40 14             	mov    0x14(%eax),%eax
801046ae:	89 04 24             	mov    %eax,(%esp)
801046b1:	e8 78 02 00 00       	call   8010492e <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable; p < &ptable[nproc]; p++){
801046b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
801046b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801046bc:	eb 36                	jmp    801046f4 <exit+0xfe>
    if(p->parent == curproc){
801046be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c1:	8b 40 14             	mov    0x14(%eax),%eax
801046c4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801046c7:	75 24                	jne    801046ed <exit+0xf7>
      p->parent = initproc;
801046c9:	8b 15 80 c7 10 80    	mov    0x8010c780,%edx
801046cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d2:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801046d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d8:	8b 40 0c             	mov    0xc(%eax),%eax
801046db:	83 f8 05             	cmp    $0x5,%eax
801046de:	75 0d                	jne    801046ed <exit+0xf7>
        wakeup1(initproc);
801046e0:	a1 80 c7 10 80       	mov    0x8010c780,%eax
801046e5:	89 04 24             	mov    %eax,(%esp)
801046e8:	e8 41 02 00 00       	call   8010492e <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable; p < &ptable[nproc]; p++){
801046ed:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801046f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801046f7:	c1 e0 02             	shl    $0x2,%eax
801046fa:	89 c2                	mov    %eax,%edx
801046fc:	c1 e2 05             	shl    $0x5,%edx
801046ff:	01 c2                	add    %eax,%edx
80104701:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104704:	01 d0                	add    %edx,%eax
80104706:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104709:	77 b3                	ja     801046be <exit+0xc8>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
8010470b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010470e:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104715:	e8 d0 07 00 00       	call   80104eea <sched>
  panic("zombie exit");
8010471a:	c7 04 24 72 91 10 80 	movl   $0x80109172,(%esp)
80104721:	e8 2e be ff ff       	call   80100554 <panic>

80104726 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104726:	55                   	push   %ebp
80104727:	89 e5                	mov    %esp,%ebp
80104729:	83 ec 38             	sub    $0x38,%esp
  struct proc *p;
  struct proc *ptable;
  int havekids, pid, nproc;
  struct proc *curproc = myproc();
8010472c:	e8 2f fa ff ff       	call   80104160 <myproc>
80104731:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquirectable();
80104734:	e8 57 05 00 00       	call   80104c90 <acquirectable>

  ptable = curproc->cont->ptable;
80104739:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010473c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104742:	8b 40 28             	mov    0x28(%eax),%eax
80104745:	89 45 e8             	mov    %eax,-0x18(%ebp)
  nproc = curproc->cont->mproc;
80104748:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010474b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104751:	8b 40 08             	mov    0x8(%eax),%eax
80104754:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104757:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable; p < &ptable[nproc]; p++){
8010475e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104761:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104764:	e9 8e 00 00 00       	jmp    801047f7 <wait+0xd1>
      if(p->parent != curproc)
80104769:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010476c:	8b 40 14             	mov    0x14(%eax),%eax
8010476f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104772:	74 02                	je     80104776 <wait+0x50>
        continue;
80104774:	eb 7a                	jmp    801047f0 <wait+0xca>
      havekids = 1;
80104776:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
8010477d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104780:	8b 40 0c             	mov    0xc(%eax),%eax
80104783:	83 f8 05             	cmp    $0x5,%eax
80104786:	75 68                	jne    801047f0 <wait+0xca>
        // Found one.
        pid = p->pid;
80104788:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478b:	8b 40 10             	mov    0x10(%eax),%eax
8010478e:	89 45 e0             	mov    %eax,-0x20(%ebp)
        kfree(p->kstack);
80104791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104794:	8b 40 08             	mov    0x8(%eax),%eax
80104797:	89 04 24             	mov    %eax,(%esp)
8010479a:	e8 66 e4 ff ff       	call   80102c05 <kfree>
        p->kstack = 0;
8010479f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047a2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801047a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ac:	8b 40 04             	mov    0x4(%eax),%eax
801047af:	89 04 24             	mov    %eax,(%esp)
801047b2:	e8 e1 42 00 00       	call   80108a98 <freevm>
        p->pid = 0;
801047b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ba:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801047c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047c4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801047cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047ce:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801047d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047d5:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801047dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047df:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        releasectable();
801047e6:	e8 b9 04 00 00       	call   80104ca4 <releasectable>
        return pid;
801047eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ee:	eb 57                	jmp    80104847 <wait+0x121>
  nproc = curproc->cont->mproc;

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable; p < &ptable[nproc]; p++){
801047f0:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801047f7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801047fa:	c1 e0 02             	shl    $0x2,%eax
801047fd:	89 c2                	mov    %eax,%edx
801047ff:	c1 e2 05             	shl    $0x5,%edx
80104802:	01 c2                	add    %eax,%edx
80104804:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104807:	01 d0                	add    %edx,%eax
80104809:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010480c:	0f 87 57 ff ff ff    	ja     80104769 <wait+0x43>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104812:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104816:	74 0a                	je     80104822 <wait+0xfc>
80104818:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010481b:	8b 40 24             	mov    0x24(%eax),%eax
8010481e:	85 c0                	test   %eax,%eax
80104820:	74 0c                	je     8010482e <wait+0x108>
      releasectable();
80104822:	e8 7d 04 00 00       	call   80104ca4 <releasectable>
      return -1;
80104827:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010482c:	eb 19                	jmp    80104847 <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, ctablelock());  //DOC: wait-sleep
8010482e:	e8 85 04 00 00       	call   80104cb8 <ctablelock>
80104833:	89 44 24 04          	mov    %eax,0x4(%esp)
80104837:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010483a:	89 04 24             	mov    %eax,(%esp)
8010483d:	e8 62 00 00 00       	call   801048a4 <sleep>
  }
80104842:	e9 10 ff ff ff       	jmp    80104757 <wait+0x31>
}
80104847:	c9                   	leave  
80104848:	c3                   	ret    

80104849 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104849:	55                   	push   %ebp
8010484a:	89 e5                	mov    %esp,%ebp
8010484c:	83 ec 08             	sub    $0x8,%esp
  acquirectable();  //DOC: yieldlock
8010484f:	e8 3c 04 00 00       	call   80104c90 <acquirectable>
  myproc()->state = RUNNABLE;
80104854:	e8 07 f9 ff ff       	call   80104160 <myproc>
80104859:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104860:	e8 85 06 00 00       	call   80104eea <sched>
  releasectable();
80104865:	e8 3a 04 00 00       	call   80104ca4 <releasectable>
}
8010486a:	c9                   	leave  
8010486b:	c3                   	ret    

8010486c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010486c:	55                   	push   %ebp
8010486d:	89 e5                	mov    %esp,%ebp
8010486f:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ctablelock from scheduler.
  releasectable();
80104872:	e8 2d 04 00 00       	call   80104ca4 <releasectable>

  if (first) {
80104877:	a1 04 c0 10 80       	mov    0x8010c004,%eax
8010487c:	85 c0                	test   %eax,%eax
8010487e:	74 22                	je     801048a2 <forkret+0x36>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104880:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104887:	00 00 00 
    iinit(ROOTDEV);
8010488a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104891:	e8 29 ce ff ff       	call   801016bf <iinit>
    initlog(ROOTDEV);
80104896:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010489d:	e8 c2 ea ff ff       	call   80103364 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
801048a2:	c9                   	leave  
801048a3:	c3                   	ret    

801048a4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801048a4:	55                   	push   %ebp
801048a5:	89 e5                	mov    %esp,%ebp
801048a7:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
801048aa:	e8 b1 f8 ff ff       	call   80104160 <myproc>
801048af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801048b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801048b6:	75 0c                	jne    801048c4 <sleep+0x20>
    panic("sleep");
801048b8:	c7 04 24 7e 91 10 80 	movl   $0x8010917e,(%esp)
801048bf:	e8 90 bc ff ff       	call   80100554 <panic>

  if(lk == 0)
801048c4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801048c8:	75 0c                	jne    801048d6 <sleep+0x32>
    panic("sleep without lk");  
801048ca:	c7 04 24 84 91 10 80 	movl   $0x80109184,(%esp)
801048d1:	e8 7e bc ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ctable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ctable.lock locked),
  // so it's okay to release lk.
  if(lk != ctablelock()){  //DOC: sleeplock0
801048d6:	e8 dd 03 00 00       	call   80104cb8 <ctablelock>
801048db:	3b 45 0c             	cmp    0xc(%ebp),%eax
801048de:	74 10                	je     801048f0 <sleep+0x4c>
    acquirectable();  //DOC: sleeplock1
801048e0:	e8 ab 03 00 00       	call   80104c90 <acquirectable>
    release(lk);
801048e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801048e8:	89 04 24             	mov    %eax,(%esp)
801048eb:	e8 0d 0d 00 00       	call   801055fd <release>
  }
  // Go to sleep.
  p->chan = chan;
801048f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f3:	8b 55 08             	mov    0x8(%ebp),%edx
801048f6:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801048f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048fc:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  //cprintf("Sleeping %s\n", p->name);

  sched();
80104903:	e8 e2 05 00 00       	call   80104eea <sched>

  // Tidy up.
  p->chan = 0;
80104908:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010490b:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != ctablelock()){  //DOC: sleeplock2
80104912:	e8 a1 03 00 00       	call   80104cb8 <ctablelock>
80104917:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010491a:	74 10                	je     8010492c <sleep+0x88>
    releasectable();
8010491c:	e8 83 03 00 00       	call   80104ca4 <releasectable>
    acquire(lk);
80104921:	8b 45 0c             	mov    0xc(%ebp),%eax
80104924:	89 04 24             	mov    %eax,(%esp)
80104927:	e8 67 0c 00 00       	call   80105593 <acquire>
  }
}
8010492c:	c9                   	leave  
8010492d:	c3                   	ret    

8010492e <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ctable lock must be held.
static void
wakeup1(void *chan)
{
8010492e:	55                   	push   %ebp
8010492f:	89 e5                	mov    %esp,%ebp
80104931:	83 ec 18             	sub    $0x18,%esp
  struct proc *ptable;
  int nproc;

  //cprintf("May not work, may have to wake up all containers processes\n");

  nproc = mycont()->mproc;
80104934:	e8 08 05 00 00       	call   80104e41 <mycont>
80104939:	8b 40 08             	mov    0x8(%eax),%eax
8010493c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ptable = mycont()->ptable;
8010493f:	e8 fd 04 00 00       	call   80104e41 <mycont>
80104944:	8b 40 28             	mov    0x28(%eax),%eax
80104947:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for(p = ptable; p < &ptable[nproc]; p++)
8010494a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010494d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104950:	eb 27                	jmp    80104979 <wakeup1+0x4b>
    if(p->state == SLEEPING && p->chan == chan) {
80104952:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104955:	8b 40 0c             	mov    0xc(%eax),%eax
80104958:	83 f8 02             	cmp    $0x2,%eax
8010495b:	75 15                	jne    80104972 <wakeup1+0x44>
8010495d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104960:	8b 40 20             	mov    0x20(%eax),%eax
80104963:	3b 45 08             	cmp    0x8(%ebp),%eax
80104966:	75 0a                	jne    80104972 <wakeup1+0x44>
      //cprintf("Waking up: %s\n", p->name);
      p->state = RUNNABLE;
80104968:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  //cprintf("May not work, may have to wake up all containers processes\n");

  nproc = mycont()->mproc;
  ptable = mycont()->ptable;

  for(p = ptable; p < &ptable[nproc]; p++)
80104972:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104979:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010497c:	c1 e0 02             	shl    $0x2,%eax
8010497f:	89 c2                	mov    %eax,%edx
80104981:	c1 e2 05             	shl    $0x5,%edx
80104984:	01 c2                	add    %eax,%edx
80104986:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104989:	01 d0                	add    %edx,%eax
8010498b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010498e:	77 c2                	ja     80104952 <wakeup1+0x24>
    if(p->state == SLEEPING && p->chan == chan) {
      //cprintf("Waking up: %s\n", p->name);
      p->state = RUNNABLE;
    }
}
80104990:	c9                   	leave  
80104991:	c3                   	ret    

80104992 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104992:	55                   	push   %ebp
80104993:	89 e5                	mov    %esp,%ebp
80104995:	83 ec 18             	sub    $0x18,%esp
  acquirectable();
80104998:	e8 f3 02 00 00       	call   80104c90 <acquirectable>
  wakeup1(chan);
8010499d:	8b 45 08             	mov    0x8(%ebp),%eax
801049a0:	89 04 24             	mov    %eax,(%esp)
801049a3:	e8 86 ff ff ff       	call   8010492e <wakeup1>
  releasectable();
801049a8:	e8 f7 02 00 00       	call   80104ca4 <releasectable>
}
801049ad:	c9                   	leave  
801049ae:	c3                   	ret    

801049af <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801049af:	55                   	push   %ebp
801049b0:	89 e5                	mov    %esp,%ebp
801049b2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct proc *ptable;
  int nproc;

  acquirectable();
801049b5:	e8 d6 02 00 00       	call   80104c90 <acquirectable>

  ptable = myproc()->cont->ptable;
801049ba:	e8 a1 f7 ff ff       	call   80104160 <myproc>
801049bf:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801049c5:	8b 40 28             	mov    0x28(%eax),%eax
801049c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  nproc = myproc()->cont->mproc;
801049cb:	e8 90 f7 ff ff       	call   80104160 <myproc>
801049d0:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801049d6:	8b 40 08             	mov    0x8(%eax),%eax
801049d9:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for(p = ptable; p < &ptable[nproc]; p++){
801049dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049df:	89 45 f4             	mov    %eax,-0xc(%ebp)
801049e2:	eb 3d                	jmp    80104a21 <kill+0x72>
    if(p->pid == pid){
801049e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e7:	8b 40 10             	mov    0x10(%eax),%eax
801049ea:	3b 45 08             	cmp    0x8(%ebp),%eax
801049ed:	75 2b                	jne    80104a1a <kill+0x6b>
      p->killed = 1;
801049ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f2:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801049f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049fc:	8b 40 0c             	mov    0xc(%eax),%eax
801049ff:	83 f8 02             	cmp    $0x2,%eax
80104a02:	75 0a                	jne    80104a0e <kill+0x5f>
        p->state = RUNNABLE;
80104a04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a07:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      releasectable();
80104a0e:	e8 91 02 00 00       	call   80104ca4 <releasectable>
      return 0;
80104a13:	b8 00 00 00 00       	mov    $0x0,%eax
80104a18:	eb 28                	jmp    80104a42 <kill+0x93>
  acquirectable();

  ptable = myproc()->cont->ptable;
  nproc = myproc()->cont->mproc;

  for(p = ptable; p < &ptable[nproc]; p++){
80104a1a:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104a21:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a24:	c1 e0 02             	shl    $0x2,%eax
80104a27:	89 c2                	mov    %eax,%edx
80104a29:	c1 e2 05             	shl    $0x5,%edx
80104a2c:	01 c2                	add    %eax,%edx
80104a2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a31:	01 d0                	add    %edx,%eax
80104a33:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104a36:	77 ac                	ja     801049e4 <kill+0x35>
        p->state = RUNNABLE;
      releasectable();
      return 0;
    }
  }
  releasectable();
80104a38:	e8 67 02 00 00       	call   80104ca4 <releasectable>
  return -1;
80104a3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104a42:	c9                   	leave  
80104a43:	c3                   	ret    

80104a44 <procdump>:
// Print a process listing of current container to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104a44:	55                   	push   %ebp
80104a45:	89 e5                	mov    %esp,%ebp
80104a47:	83 ec 68             	sub    $0x68,%esp
  uint pc[10];

  struct proc *ptable;
  int nproc;

  acquirectable();
80104a4a:	e8 41 02 00 00       	call   80104c90 <acquirectable>

  nproc = mycont()->mproc;
80104a4f:	e8 ed 03 00 00       	call   80104e41 <mycont>
80104a54:	8b 40 08             	mov    0x8(%eax),%eax
80104a57:	89 45 e8             	mov    %eax,-0x18(%ebp)
  ptable = mycont()->ptable;
80104a5a:	e8 e2 03 00 00       	call   80104e41 <mycont>
80104a5f:	8b 40 28             	mov    0x28(%eax),%eax
80104a62:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  cprintf("procdump() nproc: %d\n", nproc);
80104a65:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104a68:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a6c:	c7 04 24 95 91 10 80 	movl   $0x80109195,(%esp)
80104a73:	e8 49 b9 ff ff       	call   801003c1 <cprintf>

  for(p = ptable; p < &ptable[nproc]; p++){
80104a78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104a7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104a7e:	e9 e8 00 00 00       	jmp    80104b6b <procdump+0x127>
    if(p->state == UNUSED)
80104a83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a86:	8b 40 0c             	mov    0xc(%eax),%eax
80104a89:	85 c0                	test   %eax,%eax
80104a8b:	75 05                	jne    80104a92 <procdump+0x4e>
      continue;
80104a8d:	e9 d2 00 00 00       	jmp    80104b64 <procdump+0x120>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a95:	8b 40 0c             	mov    0xc(%eax),%eax
80104a98:	83 f8 05             	cmp    $0x5,%eax
80104a9b:	77 23                	ja     80104ac0 <procdump+0x7c>
80104a9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104aa0:	8b 40 0c             	mov    0xc(%eax),%eax
80104aa3:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104aaa:	85 c0                	test   %eax,%eax
80104aac:	74 12                	je     80104ac0 <procdump+0x7c>
      state = states[p->state];
80104aae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ab1:	8b 40 0c             	mov    0xc(%eax),%eax
80104ab4:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104abb:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104abe:	eb 07                	jmp    80104ac7 <procdump+0x83>
    else
      state = "???";
80104ac0:	c7 45 ec ab 91 10 80 	movl   $0x801091ab,-0x14(%ebp)
    cprintf("cid: %d. %d %s %s", p->cont->cid, p->pid, state, p->name);
80104ac7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104aca:	8d 48 6c             	lea    0x6c(%eax),%ecx
80104acd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ad0:	8b 50 10             	mov    0x10(%eax),%edx
80104ad3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ad6:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104adc:	8b 40 0c             	mov    0xc(%eax),%eax
80104adf:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80104ae3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80104ae6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80104aea:	89 54 24 08          	mov    %edx,0x8(%esp)
80104aee:	89 44 24 04          	mov    %eax,0x4(%esp)
80104af2:	c7 04 24 af 91 10 80 	movl   $0x801091af,(%esp)
80104af9:	e8 c3 b8 ff ff       	call   801003c1 <cprintf>
    if(p->state == SLEEPING){
80104afe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b01:	8b 40 0c             	mov    0xc(%eax),%eax
80104b04:	83 f8 02             	cmp    $0x2,%eax
80104b07:	75 4f                	jne    80104b58 <procdump+0x114>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104b09:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b0c:	8b 40 1c             	mov    0x1c(%eax),%eax
80104b0f:	8b 40 0c             	mov    0xc(%eax),%eax
80104b12:	83 c0 08             	add    $0x8,%eax
80104b15:	8d 55 bc             	lea    -0x44(%ebp),%edx
80104b18:	89 54 24 04          	mov    %edx,0x4(%esp)
80104b1c:	89 04 24             	mov    %eax,(%esp)
80104b1f:	e8 26 0b 00 00       	call   8010564a <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104b24:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104b2b:	eb 1a                	jmp    80104b47 <procdump+0x103>
        cprintf(" %p", pc[i]);
80104b2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b30:	8b 44 85 bc          	mov    -0x44(%ebp,%eax,4),%eax
80104b34:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b38:	c7 04 24 c1 91 10 80 	movl   $0x801091c1,(%esp)
80104b3f:	e8 7d b8 ff ff       	call   801003c1 <cprintf>
    else
      state = "???";
    cprintf("cid: %d. %d %s %s", p->cont->cid, p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104b44:	ff 45 f4             	incl   -0xc(%ebp)
80104b47:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104b4b:	7f 0b                	jg     80104b58 <procdump+0x114>
80104b4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b50:	8b 44 85 bc          	mov    -0x44(%ebp,%eax,4),%eax
80104b54:	85 c0                	test   %eax,%eax
80104b56:	75 d5                	jne    80104b2d <procdump+0xe9>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104b58:	c7 04 24 c5 91 10 80 	movl   $0x801091c5,(%esp)
80104b5f:	e8 5d b8 ff ff       	call   801003c1 <cprintf>
  nproc = mycont()->mproc;
  ptable = mycont()->ptable;

  cprintf("procdump() nproc: %d\n", nproc);

  for(p = ptable; p < &ptable[nproc]; p++){
80104b64:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104b6b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b6e:	c1 e0 02             	shl    $0x2,%eax
80104b71:	89 c2                	mov    %eax,%edx
80104b73:	c1 e2 05             	shl    $0x5,%edx
80104b76:	01 c2                	add    %eax,%edx
80104b78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104b7b:	01 d0                	add    %edx,%eax
80104b7d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104b80:	0f 87 fd fe ff ff    	ja     80104a83 <procdump+0x3f>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }

  releasectable();
80104b86:	e8 19 01 00 00       	call   80104ca4 <releasectable>
}
80104b8b:	c9                   	leave  
80104b8c:	c3                   	ret    
80104b8d:	00 00                	add    %al,(%eax)
	...

80104b90 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104b90:	55                   	push   %ebp
80104b91:	89 e5                	mov    %esp,%ebp
80104b93:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b96:	9c                   	pushf  
80104b97:	58                   	pop    %eax
80104b98:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104b9b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b9e:	c9                   	leave  
80104b9f:	c3                   	ret    

80104ba0 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104ba0:	55                   	push   %ebp
80104ba1:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104ba3:	fb                   	sti    
}
80104ba4:	5d                   	pop    %ebp
80104ba5:	c3                   	ret    

80104ba6 <cpuid>:

// TODO: Check to make sure ALL ctable calls have a lock

// Must be called with interrupts disabled
int
cpuid() {
80104ba6:	55                   	push   %ebp
80104ba7:	89 e5                	mov    %esp,%ebp
80104ba9:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104bac:	e8 3a 00 00 00       	call   80104beb <mycpu>
80104bb1:	89 c2                	mov    %eax,%edx
80104bb3:	b8 60 49 11 80       	mov    $0x80114960,%eax
80104bb8:	29 c2                	sub    %eax,%edx
80104bba:	89 d0                	mov    %edx,%eax
80104bbc:	c1 f8 04             	sar    $0x4,%eax
80104bbf:	89 c1                	mov    %eax,%ecx
80104bc1:	89 ca                	mov    %ecx,%edx
80104bc3:	c1 e2 03             	shl    $0x3,%edx
80104bc6:	01 ca                	add    %ecx,%edx
80104bc8:	89 d0                	mov    %edx,%eax
80104bca:	c1 e0 05             	shl    $0x5,%eax
80104bcd:	29 d0                	sub    %edx,%eax
80104bcf:	c1 e0 02             	shl    $0x2,%eax
80104bd2:	01 c8                	add    %ecx,%eax
80104bd4:	c1 e0 03             	shl    $0x3,%eax
80104bd7:	01 c8                	add    %ecx,%eax
80104bd9:	89 c2                	mov    %eax,%edx
80104bdb:	c1 e2 0f             	shl    $0xf,%edx
80104bde:	29 c2                	sub    %eax,%edx
80104be0:	c1 e2 02             	shl    $0x2,%edx
80104be3:	01 ca                	add    %ecx,%edx
80104be5:	89 d0                	mov    %edx,%eax
80104be7:	f7 d8                	neg    %eax
}
80104be9:	c9                   	leave  
80104bea:	c3                   	ret    

80104beb <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104beb:	55                   	push   %ebp
80104bec:	89 e5                	mov    %esp,%ebp
80104bee:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104bf1:	e8 9a ff ff ff       	call   80104b90 <readeflags>
80104bf6:	25 00 02 00 00       	and    $0x200,%eax
80104bfb:	85 c0                	test   %eax,%eax
80104bfd:	74 0c                	je     80104c0b <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
80104bff:	c7 04 24 f4 91 10 80 	movl   $0x801091f4,(%esp)
80104c06:	e8 49 b9 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
80104c0b:	e8 09 e4 ff ff       	call   80103019 <lapicid>
80104c10:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104c13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104c1a:	eb 3b                	jmp    80104c57 <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
80104c1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c1f:	89 d0                	mov    %edx,%eax
80104c21:	c1 e0 02             	shl    $0x2,%eax
80104c24:	01 d0                	add    %edx,%eax
80104c26:	01 c0                	add    %eax,%eax
80104c28:	01 d0                	add    %edx,%eax
80104c2a:	c1 e0 04             	shl    $0x4,%eax
80104c2d:	05 60 49 11 80       	add    $0x80114960,%eax
80104c32:	8a 00                	mov    (%eax),%al
80104c34:	0f b6 c0             	movzbl %al,%eax
80104c37:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104c3a:	75 18                	jne    80104c54 <mycpu+0x69>
      return &cpus[i];
80104c3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c3f:	89 d0                	mov    %edx,%eax
80104c41:	c1 e0 02             	shl    $0x2,%eax
80104c44:	01 d0                	add    %edx,%eax
80104c46:	01 c0                	add    %eax,%eax
80104c48:	01 d0                	add    %edx,%eax
80104c4a:	c1 e0 04             	shl    $0x4,%eax
80104c4d:	05 60 49 11 80       	add    $0x80114960,%eax
80104c52:	eb 19                	jmp    80104c6d <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104c54:	ff 45 f4             	incl   -0xc(%ebp)
80104c57:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80104c5c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104c5f:	7c bb                	jl     80104c1c <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104c61:	c7 04 24 1a 92 10 80 	movl   $0x8010921a,(%esp)
80104c68:	e8 e7 b8 ff ff       	call   80100554 <panic>
}
80104c6d:	c9                   	leave  
80104c6e:	c3                   	ret    

80104c6f <cinit>:

int nextcid = 1;

void
cinit(void)
{
80104c6f:	55                   	push   %ebp
80104c70:	89 e5                	mov    %esp,%ebp
80104c72:	83 ec 18             	sub    $0x18,%esp
  initlock(&ctable.lock, "ctable");
80104c75:	c7 44 24 04 2a 92 10 	movl   $0x8010922a,0x4(%esp)
80104c7c:	80 
80104c7d:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104c84:	e8 e9 08 00 00       	call   80105572 <initlock>
  // TODO: Remove
  contdump();
80104c89:	e8 3b 01 00 00       	call   80104dc9 <contdump>
}
80104c8e:	c9                   	leave  
80104c8f:	c3                   	ret    

80104c90 <acquirectable>:

void
acquirectable(void) 
{
80104c90:	55                   	push   %ebp
80104c91:	89 e5                	mov    %esp,%ebp
80104c93:	83 ec 18             	sub    $0x18,%esp
	//cprintf("\t\tWaiting on acquiring ctable...\n");
	acquire(&ptable.lock);
80104c96:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
80104c9d:	e8 f1 08 00 00       	call   80105593 <acquire>
	//cprintf("\t\tGot ctable\n");
}
80104ca2:	c9                   	leave  
80104ca3:	c3                   	ret    

80104ca4 <releasectable>:
// TODO: refactor name of ctablelock to ptable
// TODO: replace these aqcuires and releases with normal aqcuire and release using ctablelock()
void 
releasectable(void)
{
80104ca4:	55                   	push   %ebp
80104ca5:	89 e5                	mov    %esp,%ebp
80104ca7:	83 ec 18             	sub    $0x18,%esp
	release(&ptable.lock);
80104caa:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
80104cb1:	e8 47 09 00 00       	call   801055fd <release>
	//cprintf("\t\t Released ctable\n");
}
80104cb6:	c9                   	leave  
80104cb7:	c3                   	ret    

80104cb8 <ctablelock>:

struct spinlock*
ctablelock(void)
{
80104cb8:	55                   	push   %ebp
80104cb9:	89 e5                	mov    %esp,%ebp
	return &ptable.lock;
80104cbb:	b8 c0 50 11 80       	mov    $0x801150c0,%eax
}
80104cc0:	5d                   	pop    %ebp
80104cc1:	c3                   	ret    

80104cc2 <initcontainer>:

void
initcontainer(void)
{
80104cc2:	55                   	push   %ebp
80104cc3:	89 e5                	mov    %esp,%ebp
80104cc5:	83 ec 38             	sub    $0x38,%esp
	int i,
		mproc = MAX_CONT_PROC,
80104cc8:	c7 45 f0 40 00 00 00 	movl   $0x40,-0x10(%ebp)
		msz   = MAX_CONT_MEM,
80104ccf:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
		mdsk  = MAX_CONT_DSK;
80104cd6:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
	struct cont *c;

	if ((c = alloccont()) == 0) {
80104cdd:	e8 93 01 00 00       	call   80104e75 <alloccont>
80104ce2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80104ce5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80104ce9:	75 0c                	jne    80104cf7 <initcontainer+0x35>
		panic("Can't alloc init container.");
80104ceb:	c7 04 24 31 92 10 80 	movl   $0x80109231,(%esp)
80104cf2:	e8 5d b8 ff ff       	call   80100554 <panic>
	}

	currcont = c;	
80104cf7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104cfa:	a3 b4 50 11 80       	mov    %eax,0x801150b4

	acquire(&ctable.lock);
80104cff:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104d06:	e8 88 08 00 00       	call   80105593 <acquire>
	c->mproc = mproc;
80104d0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d0e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d11:	89 50 08             	mov    %edx,0x8(%eax)
	c->msz = msz;
80104d14:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104d17:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d1a:	89 10                	mov    %edx,(%eax)
	c->mdsk = mdsk;	
80104d1c:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104d1f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d22:	89 50 04             	mov    %edx,0x4(%eax)
	c->state = CRUNNABLE;	
80104d25:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d28:	c7 40 14 02 00 00 00 	movl   $0x2,0x14(%eax)
	c->rootdir = namei("/");
80104d2f:	c7 04 24 4d 92 10 80 	movl   $0x8010924d,(%esp)
80104d36:	e8 55 d8 ff ff       	call   80102590 <namei>
80104d3b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104d3e:	89 42 10             	mov    %eax,0x10(%edx)
	safestrcpy(c->name, "initcont", sizeof(c->name));	
80104d41:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d44:	83 c0 18             	add    $0x18,%eax
80104d47:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104d4e:	00 
80104d4f:	c7 44 24 04 4f 92 10 	movl   $0x8010924f,0x4(%esp)
80104d56:	80 
80104d57:	89 04 24             	mov    %eax,(%esp)
80104d5a:	e8 a3 0c 00 00       	call   80105a02 <safestrcpy>

	// Init pointers to each container's process tables
	for (i = 0; i < NCONT; i++)
80104d5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d66:	eb 2f                	jmp    80104d97 <initcontainer+0xd5>
		ctable.cont[i].ptable = ptable.proc[i];
80104d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d6b:	c1 e0 08             	shl    $0x8,%eax
80104d6e:	89 c2                	mov    %eax,%edx
80104d70:	c1 e2 05             	shl    $0x5,%edx
80104d73:	01 d0                	add    %edx,%eax
80104d75:	83 c0 30             	add    $0x30,%eax
80104d78:	05 c0 50 11 80       	add    $0x801150c0,%eax
80104d7d:	8d 48 04             	lea    0x4(%eax),%ecx
80104d80:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d83:	89 d0                	mov    %edx,%eax
80104d85:	01 c0                	add    %eax,%eax
80104d87:	01 d0                	add    %edx,%eax
80104d89:	c1 e0 04             	shl    $0x4,%eax
80104d8c:	05 50 4f 11 80       	add    $0x80114f50,%eax
80104d91:	89 48 0c             	mov    %ecx,0xc(%eax)
	c->state = CRUNNABLE;	
	c->rootdir = namei("/");
	safestrcpy(c->name, "initcont", sizeof(c->name));	

	// Init pointers to each container's process tables
	for (i = 0; i < NCONT; i++)
80104d94:	ff 45 f4             	incl   -0xc(%ebp)
80104d97:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80104d9b:	7e cb                	jle    80104d68 <initcontainer+0xa6>
		ctable.cont[i].ptable = ptable.proc[i];

	release(&ctable.lock);	
80104d9d:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104da4:	e8 54 08 00 00       	call   801055fd <release>
}
80104da9:	c9                   	leave  
80104daa:	c3                   	ret    

80104dab <userinit>:

// Set up first user container and process.
void
userinit(void)
{
80104dab:	55                   	push   %ebp
80104dac:	89 e5                	mov    %esp,%ebp
80104dae:	83 ec 18             	sub    $0x18,%esp
  initcontainer();
80104db1:	e8 0c ff ff ff       	call   80104cc2 <initcontainer>
  initprocess();  
80104db6:	e8 fb f4 ff ff       	call   801042b6 <initprocess>
  cprintf("init process\n");
80104dbb:	c7 04 24 58 92 10 80 	movl   $0x80109258,(%esp)
80104dc2:	e8 fa b5 ff ff       	call   801003c1 <cprintf>
}
80104dc7:	c9                   	leave  
80104dc8:	c3                   	ret    

80104dc9 <contdump>:

void
contdump(void)
{
80104dc9:	55                   	push   %ebp
80104dca:	89 e5                	mov    %esp,%ebp
80104dcc:	83 ec 28             	sub    $0x28,%esp
	  [CRUNNABLE]  "runnable",
	  [CEMBRYO]    "embryo"
	  };
	int i;
  
  	acquire(&ctable.lock);
80104dcf:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104dd6:	e8 b8 07 00 00       	call   80105593 <acquire>
  	for (i = 0; i < NCONT; i++)
80104ddb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104de2:	eb 49                	jmp    80104e2d <contdump+0x64>
  		cprintf("container %d: %s\n", ctable.cont[i].cid, states[ctable.cont[i].state]);
80104de4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104de7:	89 d0                	mov    %edx,%eax
80104de9:	01 c0                	add    %eax,%eax
80104deb:	01 d0                	add    %edx,%eax
80104ded:	c1 e0 04             	shl    $0x4,%eax
80104df0:	05 40 4f 11 80       	add    $0x80114f40,%eax
80104df5:	8b 40 08             	mov    0x8(%eax),%eax
80104df8:	8b 14 85 24 c0 10 80 	mov    -0x7fef3fdc(,%eax,4),%edx
80104dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e02:	8d 48 01             	lea    0x1(%eax),%ecx
80104e05:	89 c8                	mov    %ecx,%eax
80104e07:	01 c0                	add    %eax,%eax
80104e09:	01 c8                	add    %ecx,%eax
80104e0b:	c1 e0 04             	shl    $0x4,%eax
80104e0e:	05 00 4f 11 80       	add    $0x80114f00,%eax
80104e13:	8b 40 10             	mov    0x10(%eax),%eax
80104e16:	89 54 24 08          	mov    %edx,0x8(%esp)
80104e1a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104e1e:	c7 04 24 66 92 10 80 	movl   $0x80109266,(%esp)
80104e25:	e8 97 b5 ff ff       	call   801003c1 <cprintf>
	  [CEMBRYO]    "embryo"
	  };
	int i;
  
  	acquire(&ctable.lock);
  	for (i = 0; i < NCONT; i++)
80104e2a:	ff 45 f4             	incl   -0xc(%ebp)
80104e2d:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80104e31:	7e b1                	jle    80104de4 <contdump+0x1b>
  		cprintf("container %d: %s\n", ctable.cont[i].cid, states[ctable.cont[i].state]);
  	release(&ctable.lock);
80104e33:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104e3a:	e8 be 07 00 00       	call   801055fd <release>
}
80104e3f:	c9                   	leave  
80104e40:	c3                   	ret    

80104e41 <mycont>:

struct cont*
mycont(void) {
80104e41:	55                   	push   %ebp
80104e42:	89 e5                	mov    %esp,%ebp
	return currcont;
80104e44:	a1 b4 50 11 80       	mov    0x801150b4,%eax
}
80104e49:	5d                   	pop    %ebp
80104e4a:	c3                   	ret    

80104e4b <rootcont>:

struct cont* 	
rootcont(void) {
80104e4b:	55                   	push   %ebp
80104e4c:	89 e5                	mov    %esp,%ebp
80104e4e:	83 ec 28             	sub    $0x28,%esp
	struct cont *c;
	// TODO: Check to make sure it always inits at first index
  	acquire(&ctable.lock);  
80104e51:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104e58:	e8 36 07 00 00       	call   80105593 <acquire>
  	c = &ctable.cont[0];
80104e5d:	c7 45 f4 34 4f 11 80 	movl   $0x80114f34,-0xc(%ebp)
  	release(&ctable.lock);
80104e64:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104e6b:	e8 8d 07 00 00       	call   801055fd <release>
  	return c;
80104e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104e73:	c9                   	leave  
80104e74:	c3                   	ret    

80104e75 <alloccont>:
// Look in the container table for an CUNUSED cont.
// If found, change state to CEMBRYO
// Otherwise return 0.
static struct cont*
alloccont(void)
{
80104e75:	55                   	push   %ebp
80104e76:	89 e5                	mov    %esp,%ebp
80104e78:	83 ec 28             	sub    $0x28,%esp
	struct cont *c;

	acquire(&ctable.lock);
80104e7b:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104e82:	e8 0c 07 00 00       	call   80105593 <acquire>

	for(c = ctable.cont; c < &ctable.cont[NCONT]; c++)
80104e87:	c7 45 f4 34 4f 11 80 	movl   $0x80114f34,-0xc(%ebp)
80104e8e:	eb 3e                	jmp    80104ece <alloccont+0x59>
		if(c->state == CUNUSED)
80104e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e93:	8b 40 14             	mov    0x14(%eax),%eax
80104e96:	85 c0                	test   %eax,%eax
80104e98:	75 30                	jne    80104eca <alloccont+0x55>
		  goto found;
80104e9a:	90                   	nop

	release(&ctable.lock);
	return 0;

found:
	c->state = CEMBRYO;
80104e9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e9e:	c7 40 14 01 00 00 00 	movl   $0x1,0x14(%eax)
	c->cid = nextcid++;
80104ea5:	a1 20 c0 10 80       	mov    0x8010c020,%eax
80104eaa:	8d 50 01             	lea    0x1(%eax),%edx
80104ead:	89 15 20 c0 10 80    	mov    %edx,0x8010c020
80104eb3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104eb6:	89 42 0c             	mov    %eax,0xc(%edx)

	release(&ctable.lock);
80104eb9:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104ec0:	e8 38 07 00 00       	call   801055fd <release>

	return c;
80104ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ec8:	eb 1e                	jmp    80104ee8 <alloccont+0x73>
{
	struct cont *c;

	acquire(&ctable.lock);

	for(c = ctable.cont; c < &ctable.cont[NCONT]; c++)
80104eca:	83 45 f4 30          	addl   $0x30,-0xc(%ebp)
80104ece:	81 7d f4 b4 50 11 80 	cmpl   $0x801150b4,-0xc(%ebp)
80104ed5:	72 b9                	jb     80104e90 <alloccont+0x1b>
		if(c->state == CUNUSED)
		  goto found;

	release(&ctable.lock);
80104ed7:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104ede:	e8 1a 07 00 00       	call   801055fd <release>
	return 0;
80104ee3:	b8 00 00 00 00       	mov    $0x0,%eax
	c->cid = nextcid++;

	release(&ctable.lock);

	return c;
}
80104ee8:	c9                   	leave  
80104ee9:	c3                   	ret    

80104eea <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104eea:	55                   	push   %ebp
80104eeb:	89 e5                	mov    %esp,%ebp
80104eed:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
80104ef0:	e8 6b f2 ff ff       	call   80104160 <myproc>
80104ef5:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(ctablelock()))
80104ef8:	e8 bb fd ff ff       	call   80104cb8 <ctablelock>
80104efd:	89 04 24             	mov    %eax,(%esp)
80104f00:	e8 bc 07 00 00       	call   801056c1 <holding>
80104f05:	85 c0                	test   %eax,%eax
80104f07:	75 0c                	jne    80104f15 <sched+0x2b>
    panic("sched ctable.lock");
80104f09:	c7 04 24 78 92 10 80 	movl   $0x80109278,(%esp)
80104f10:	e8 3f b6 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
80104f15:	e8 d1 fc ff ff       	call   80104beb <mycpu>
80104f1a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104f20:	83 f8 01             	cmp    $0x1,%eax
80104f23:	74 0c                	je     80104f31 <sched+0x47>
    panic("sched locks");
80104f25:	c7 04 24 8a 92 10 80 	movl   $0x8010928a,(%esp)
80104f2c:	e8 23 b6 ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
80104f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f34:	8b 40 0c             	mov    0xc(%eax),%eax
80104f37:	83 f8 04             	cmp    $0x4,%eax
80104f3a:	75 0c                	jne    80104f48 <sched+0x5e>
    panic("sched running");
80104f3c:	c7 04 24 96 92 10 80 	movl   $0x80109296,(%esp)
80104f43:	e8 0c b6 ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80104f48:	e8 43 fc ff ff       	call   80104b90 <readeflags>
80104f4d:	25 00 02 00 00       	and    $0x200,%eax
80104f52:	85 c0                	test   %eax,%eax
80104f54:	74 0c                	je     80104f62 <sched+0x78>
    panic("sched interruptible");
80104f56:	c7 04 24 a4 92 10 80 	movl   $0x801092a4,(%esp)
80104f5d:	e8 f2 b5 ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
80104f62:	e8 84 fc ff ff       	call   80104beb <mycpu>
80104f67:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104f6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104f70:	e8 76 fc ff ff       	call   80104beb <mycpu>
80104f75:	8b 40 04             	mov    0x4(%eax),%eax
80104f78:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f7b:	83 c2 1c             	add    $0x1c,%edx
80104f7e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f82:	89 14 24             	mov    %edx,(%esp)
80104f85:	e8 e6 0a 00 00       	call   80105a70 <swtch>
  mycpu()->intena = intena;
80104f8a:	e8 5c fc ff ff       	call   80104beb <mycpu>
80104f8f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f92:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104f98:	c9                   	leave  
80104f99:	c3                   	ret    

80104f9a <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104f9a:	55                   	push   %ebp
80104f9b:	89 e5                	mov    %esp,%ebp
80104f9d:	83 ec 38             	sub    $0x38,%esp
  struct proc *p;
  struct cont *cont;
  struct cpu *c = mycpu();
80104fa0:	e8 46 fc ff ff       	call   80104beb <mycpu>
80104fa5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i, k;
  c->proc = 0;
80104fa8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104fab:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104fb2:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104fb5:	e8 e6 fb ff ff       	call   80104ba0 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104fba:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
80104fc1:	e8 cd 05 00 00       	call   80105593 <acquire>
    // TODO: do we need to acquire ctable lock too?

	// TODO: Check that scheulde cycles over ctable equally    
    for(i = 0; i < NCONT; i++) {
80104fc6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104fcd:	e9 d5 00 00 00       	jmp    801050a7 <scheduler+0x10d>

      cont = &ctable.cont[i];
80104fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd5:	8d 50 01             	lea    0x1(%eax),%edx
80104fd8:	89 d0                	mov    %edx,%eax
80104fda:	01 c0                	add    %eax,%eax
80104fdc:	01 d0                	add    %edx,%eax
80104fde:	c1 e0 04             	shl    $0x4,%eax
80104fe1:	05 00 4f 11 80       	add    $0x80114f00,%eax
80104fe6:	83 c0 04             	add    $0x4,%eax
80104fe9:	89 45 e8             	mov    %eax,-0x18(%ebp)

      if (cont->state != CRUNNABLE)
80104fec:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104fef:	8b 40 14             	mov    0x14(%eax),%eax
80104ff2:	83 f8 02             	cmp    $0x2,%eax
80104ff5:	74 05                	je     80104ffc <scheduler+0x62>
      	continue;      
80104ff7:	e9 a8 00 00 00       	jmp    801050a4 <scheduler+0x10a>

      for (k = (cont->nextproc % cont->mproc); k < cont->mproc; k++) {
80104ffc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104fff:	8b 40 2c             	mov    0x2c(%eax),%eax
80105002:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105005:	8b 4a 08             	mov    0x8(%edx),%ecx
80105008:	99                   	cltd   
80105009:	f7 f9                	idiv   %ecx
8010500b:	89 55 f0             	mov    %edx,-0x10(%ebp)
8010500e:	e9 82 00 00 00       	jmp    80105095 <scheduler+0xfb>
      	
      	  p = &cont->ptable[k]; 
80105013:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105016:	8b 50 28             	mov    0x28(%eax),%edx
80105019:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010501c:	c1 e0 02             	shl    $0x2,%eax
8010501f:	89 c1                	mov    %eax,%ecx
80105021:	c1 e1 05             	shl    $0x5,%ecx
80105024:	01 c8                	add    %ecx,%eax
80105026:	01 d0                	add    %edx,%eax
80105028:	89 45 e4             	mov    %eax,-0x1c(%ebp)

      	  cont->nextproc = cont->nextproc + 1;
8010502b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010502e:	8b 40 2c             	mov    0x2c(%eax),%eax
80105031:	8d 50 01             	lea    0x1(%eax),%edx
80105034:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105037:	89 50 2c             	mov    %edx,0x2c(%eax)

	      if(p->state != RUNNABLE)
8010503a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010503d:	8b 40 0c             	mov    0xc(%eax),%eax
80105040:	83 f8 03             	cmp    $0x3,%eax
80105043:	74 02                	je     80105047 <scheduler+0xad>
	        continue;
80105045:	eb 4b                	jmp    80105092 <scheduler+0xf8>

	      // Switch to chosen process.  It is the process's job
	      // to release ctable.lock and then reacquire it
	      // before jumping back to us.
	      c->proc = p;
80105047:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010504a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010504d:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
	      switchuvm(p);
80105053:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105056:	89 04 24             	mov    %eax,(%esp)
80105059:	e8 6e 35 00 00       	call   801085cc <switchuvm>
	      p->state = RUNNING;
8010505e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105061:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

	      swtch(&(c->scheduler), p->context);
80105068:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010506b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010506e:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105071:	83 c2 04             	add    $0x4,%edx
80105074:	89 44 24 04          	mov    %eax,0x4(%esp)
80105078:	89 14 24             	mov    %edx,(%esp)
8010507b:	e8 f0 09 00 00       	call   80105a70 <swtch>
	      switchkvm();
80105080:	e8 2d 35 00 00       	call   801085b2 <switchkvm>

	      // Process is done running for now.
	      // It should have changed its p->state before coming back.
	      c->proc = 0;
80105085:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105088:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010508f:	00 00 00 
      cont = &ctable.cont[i];

      if (cont->state != CRUNNABLE)
      	continue;      

      for (k = (cont->nextproc % cont->mproc); k < cont->mproc; k++) {
80105092:	ff 45 f0             	incl   -0x10(%ebp)
80105095:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105098:	8b 40 08             	mov    0x8(%eax),%eax
8010509b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010509e:	0f 8f 6f ff ff ff    	jg     80105013 <scheduler+0x79>
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    // TODO: do we need to acquire ctable lock too?

	// TODO: Check that scheulde cycles over ctable equally    
    for(i = 0; i < NCONT; i++) {
801050a4:	ff 45 f4             	incl   -0xc(%ebp)
801050a7:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801050ab:	0f 8e 21 ff ff ff    	jle    80104fd2 <scheduler+0x38>
	      // Process is done running for now.
	      // It should have changed its p->state before coming back.
	      c->proc = 0;
	  }
    }
    release(&ptable.lock);
801050b1:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
801050b8:	e8 40 05 00 00       	call   801055fd <release>

  }
801050bd:	e9 f3 fe ff ff       	jmp    80104fb5 <scheduler+0x1b>

801050c2 <movefile>:
}

/* Moves file src to folder dst 
TODO: Implement */
int
movefile(char* dst, char* src) {
801050c2:	55                   	push   %ebp
801050c3:	89 e5                	mov    %esp,%ebp
801050c5:	57                   	push   %edi
801050c6:	56                   	push   %esi
801050c7:	53                   	push   %ebx
801050c8:	83 ec 2c             	sub    $0x2c,%esp
801050cb:	89 e0                	mov    %esp,%eax
801050cd:	89 c6                	mov    %eax,%esi
	
	int pathsize = sizeof(dst) + sizeof(src) + 2; // dst.len + '\' + src.len + \0
801050cf:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
	char path[pathsize]; 
801050d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801050d9:	8d 50 ff             	lea    -0x1(%eax),%edx
801050dc:	89 55 e0             	mov    %edx,-0x20(%ebp)
801050df:	ba 10 00 00 00       	mov    $0x10,%edx
801050e4:	4a                   	dec    %edx
801050e5:	01 d0                	add    %edx,%eax
801050e7:	b9 10 00 00 00       	mov    $0x10,%ecx
801050ec:	ba 00 00 00 00       	mov    $0x0,%edx
801050f1:	f7 f1                	div    %ecx
801050f3:	6b c0 10             	imul   $0x10,%eax,%eax
801050f6:	29 c4                	sub    %eax,%esp
801050f8:	8d 44 24 0c          	lea    0xc(%esp),%eax
801050fc:	83 c0 00             	add    $0x0,%eax
801050ff:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// struct file *f;
	// struct inode *ip;

	memmove(path, dst, strlen(dst));
80105102:	8b 45 08             	mov    0x8(%ebp),%eax
80105105:	89 04 24             	mov    %eax,(%esp)
80105108:	e8 3c 09 00 00       	call   80105a49 <strlen>
8010510d:	89 c2                	mov    %eax,%edx
8010510f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105112:	89 54 24 08          	mov    %edx,0x8(%esp)
80105116:	8b 55 08             	mov    0x8(%ebp),%edx
80105119:	89 54 24 04          	mov    %edx,0x4(%esp)
8010511d:	89 04 24             	mov    %eax,(%esp)
80105120:	e8 9a 07 00 00       	call   801058bf <memmove>
	memmove(path + strlen(dst), "/", 1);
80105125:	8b 5d dc             	mov    -0x24(%ebp),%ebx
80105128:	8b 45 08             	mov    0x8(%ebp),%eax
8010512b:	89 04 24             	mov    %eax,(%esp)
8010512e:	e8 16 09 00 00       	call   80105a49 <strlen>
80105133:	01 d8                	add    %ebx,%eax
80105135:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010513c:	00 
8010513d:	c7 44 24 04 4d 92 10 	movl   $0x8010924d,0x4(%esp)
80105144:	80 
80105145:	89 04 24             	mov    %eax,(%esp)
80105148:	e8 72 07 00 00       	call   801058bf <memmove>
	memmove(path + strlen(dst) + 1, src, strlen(src));
8010514d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105150:	89 04 24             	mov    %eax,(%esp)
80105153:	e8 f1 08 00 00       	call   80105a49 <strlen>
80105158:	89 c3                	mov    %eax,%ebx
8010515a:	8b 7d dc             	mov    -0x24(%ebp),%edi
8010515d:	8b 45 08             	mov    0x8(%ebp),%eax
80105160:	89 04 24             	mov    %eax,(%esp)
80105163:	e8 e1 08 00 00       	call   80105a49 <strlen>
80105168:	40                   	inc    %eax
80105169:	8d 14 07             	lea    (%edi,%eax,1),%edx
8010516c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80105170:	8b 45 0c             	mov    0xc(%ebp),%eax
80105173:	89 44 24 04          	mov    %eax,0x4(%esp)
80105177:	89 14 24             	mov    %edx,(%esp)
8010517a:	e8 40 07 00 00       	call   801058bf <memmove>
	memmove(path + strlen(dst) + 1 + strlen(src), "\0", 1);
8010517f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
80105182:	8b 45 08             	mov    0x8(%ebp),%eax
80105185:	89 04 24             	mov    %eax,(%esp)
80105188:	e8 bc 08 00 00       	call   80105a49 <strlen>
8010518d:	89 c7                	mov    %eax,%edi
8010518f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105192:	89 04 24             	mov    %eax,(%esp)
80105195:	e8 af 08 00 00       	call   80105a49 <strlen>
8010519a:	01 f8                	add    %edi,%eax
8010519c:	40                   	inc    %eax
8010519d:	01 d8                	add    %ebx,%eax
8010519f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801051a6:	00 
801051a7:	c7 44 24 04 b8 92 10 	movl   $0x801092b8,0x4(%esp)
801051ae:	80 
801051af:	89 04 24             	mov    %eax,(%esp)
801051b2:	e8 08 07 00 00       	call   801058bf <memmove>

	cprintf("movefile path: %s\n", path);
801051b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801051ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801051be:	c7 04 24 ba 92 10 80 	movl   $0x801092ba,(%esp)
801051c5:	e8 f7 b1 ff ff       	call   801003c1 <cprintf>
	// // Copy contents of src into new file
	// char* source;
	// fileread();	


	return 1;
801051ca:	b8 01 00 00 00       	mov    $0x1,%eax
801051cf:	89 f4                	mov    %esi,%esp
}
801051d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801051d4:	5b                   	pop    %ebx
801051d5:	5e                   	pop    %esi
801051d6:	5f                   	pop    %edi
801051d7:	5d                   	pop    %ebp
801051d8:	c3                   	ret    

801051d9 <ccreate>:

int 
ccreate(char* name, char* progv[MAXARG], int progc, int mproc, uint msz, uint mdsk)
{
801051d9:	55                   	push   %ebp
801051da:	89 e5                	mov    %esp,%ebp
801051dc:	83 ec 28             	sub    $0x28,%esp
	int i;
	struct cont *nc;
	struct inode *rootdir;

	// Allocate container.
	if ((nc = alloccont()) == 0) {
801051df:	e8 91 fc ff ff       	call   80104e75 <alloccont>
801051e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
801051e7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801051eb:	75 0a                	jne    801051f7 <ccreate+0x1e>
		return -1;
801051ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051f2:	e9 23 01 00 00       	jmp    8010531a <ccreate+0x141>
	}

	// Create a directory (same implementation as sys_mkdir)	
	// TODO: check if container exists
	begin_op();
801051f7:	e8 67 e3 ff ff       	call   80103563 <begin_op>
	if((rootdir = create(name, T_DIR, 0, 0)) == 0){
801051fc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105203:	00 
80105204:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010520b:	00 
8010520c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105213:	00 
80105214:	8b 45 08             	mov    0x8(%ebp),%eax
80105217:	89 04 24             	mov    %eax,(%esp)
8010521a:	e8 dc 10 00 00       	call   801062fb <create>
8010521f:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105222:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80105226:	75 22                	jne    8010524a <ccreate+0x71>
		end_op();
80105228:	e8 b8 e3 ff ff       	call   801035e5 <end_op>
		cprintf("Unable to create container directory %s\n", name);
8010522d:	8b 45 08             	mov    0x8(%ebp),%eax
80105230:	89 44 24 04          	mov    %eax,0x4(%esp)
80105234:	c7 04 24 d0 92 10 80 	movl   $0x801092d0,(%esp)
8010523b:	e8 81 b1 ff ff       	call   801003c1 <cprintf>
		return -1;
80105240:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105245:	e9 d0 00 00 00       	jmp    8010531a <ccreate+0x141>
	}
	iunlockput(rootdir);
8010524a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010524d:	89 04 24             	mov    %eax,(%esp)
80105250:	e8 d0 c9 ff ff       	call   80101c25 <iunlockput>
	end_op();	
80105255:	e8 8b e3 ff ff       	call   801035e5 <end_op>

	// Move files into folder
	for (i = 0; i < progc; i++) {
8010525a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105261:	eb 48                	jmp    801052ab <ccreate+0xd2>
		if (movefile(name, progv[i]) == 0) 
80105263:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105266:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010526d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105270:	01 d0                	add    %edx,%eax
80105272:	8b 00                	mov    (%eax),%eax
80105274:	89 44 24 04          	mov    %eax,0x4(%esp)
80105278:	8b 45 08             	mov    0x8(%ebp),%eax
8010527b:	89 04 24             	mov    %eax,(%esp)
8010527e:	e8 3f fe ff ff       	call   801050c2 <movefile>
80105283:	85 c0                	test   %eax,%eax
80105285:	75 21                	jne    801052a8 <ccreate+0xcf>
			cprintf("Unable to move file %s\n", progv[i]);
80105287:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010528a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105291:	8b 45 0c             	mov    0xc(%ebp),%eax
80105294:	01 d0                	add    %edx,%eax
80105296:	8b 00                	mov    (%eax),%eax
80105298:	89 44 24 04          	mov    %eax,0x4(%esp)
8010529c:	c7 04 24 f9 92 10 80 	movl   $0x801092f9,(%esp)
801052a3:	e8 19 b1 ff ff       	call   801003c1 <cprintf>
	}
	iunlockput(rootdir);
	end_op();	

	// Move files into folder
	for (i = 0; i < progc; i++) {
801052a8:	ff 45 f4             	incl   -0xc(%ebp)
801052ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052ae:	3b 45 10             	cmp    0x10(%ebp),%eax
801052b1:	7c b0                	jl     80105263 <ccreate+0x8a>
		if (movefile(name, progv[i]) == 0) 
			cprintf("Unable to move file %s\n", progv[i]);
	}

	acquire(&ctable.lock);
801052b3:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
801052ba:	e8 d4 02 00 00       	call   80105593 <acquire>
	nc->mproc = mproc;
801052bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052c2:	8b 55 14             	mov    0x14(%ebp),%edx
801052c5:	89 50 08             	mov    %edx,0x8(%eax)
	nc->msz = msz;
801052c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052cb:	8b 55 18             	mov    0x18(%ebp),%edx
801052ce:	89 10                	mov    %edx,(%eax)
	nc->mdsk = mdsk;
801052d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052d3:	8b 55 1c             	mov    0x1c(%ebp),%edx
801052d6:	89 50 04             	mov    %edx,0x4(%eax)
	nc->rootdir = rootdir;
801052d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052dc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801052df:	89 50 10             	mov    %edx,0x10(%eax)
	strncpy(nc->name, name, 16);
801052e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052e5:	8d 50 18             	lea    0x18(%eax),%edx
801052e8:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801052ef:	00 
801052f0:	8b 45 08             	mov    0x8(%ebp),%eax
801052f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801052f7:	89 14 24             	mov    %edx,(%esp)
801052fa:	e8 ad 06 00 00       	call   801059ac <strncpy>
	nc->state = CRUNNABLE;	
801052ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105302:	c7 40 14 02 00 00 00 	movl   $0x2,0x14(%eax)
	release(&ctable.lock);	
80105309:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80105310:	e8 e8 02 00 00       	call   801055fd <release>

	return 1;  
80105315:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010531a:	c9                   	leave  
8010531b:	c3                   	ret    

8010531c <cstart>:

// Allocates a process for the table "name"
// Runs argv[0] (argv is program plus arguments)
int
cstart(char* name, char** argv, int argc) 
{	
8010531c:	55                   	push   %ebp
8010531d:	89 e5                	mov    %esp,%ebp
8010531f:	83 ec 28             	sub    $0x28,%esp
	struct cpu *cpu;
	struct proc *p;
	int i;

	// Find container
	acquire(&ctable.lock);
80105322:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80105329:	e8 65 02 00 00       	call   80105593 <acquire>

	for (i = 0; i < NCONT; i++) {
8010532e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105335:	eb 53                	jmp    8010538a <cstart+0x6e>
		c = &ctable.cont[i];
80105337:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010533a:	8d 50 01             	lea    0x1(%eax),%edx
8010533d:	89 d0                	mov    %edx,%eax
8010533f:	01 c0                	add    %eax,%eax
80105341:	01 d0                	add    %edx,%eax
80105343:	c1 e0 04             	shl    $0x4,%eax
80105346:	05 00 4f 11 80       	add    $0x80114f00,%eax
8010534b:	83 c0 04             	add    $0x4,%eax
8010534e:	89 45 f0             	mov    %eax,-0x10(%ebp)
		// TODO: Check if this works
		if (strncmp(name, c->name, strlen(name)) == 0)
80105351:	8b 45 08             	mov    0x8(%ebp),%eax
80105354:	89 04 24             	mov    %eax,(%esp)
80105357:	e8 ed 06 00 00       	call   80105a49 <strlen>
8010535c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010535f:	83 c2 18             	add    $0x18,%edx
80105362:	89 44 24 08          	mov    %eax,0x8(%esp)
80105366:	89 54 24 04          	mov    %edx,0x4(%esp)
8010536a:	8b 45 08             	mov    0x8(%ebp),%eax
8010536d:	89 04 24             	mov    %eax,(%esp)
80105370:	e8 e9 05 00 00       	call   8010595e <strncmp>
80105375:	85 c0                	test   %eax,%eax
80105377:	75 0e                	jne    80105387 <cstart+0x6b>
			goto found;
80105379:	90                   	nop
	return -1;

found: 	

	// Check if RUNNABLE
	if (c->state != CRUNNABLE || (p = allocproc(c)) == 0) {
8010537a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010537d:	8b 40 14             	mov    0x14(%eax),%eax
80105380:	83 f8 02             	cmp    $0x2,%eax
80105383:	75 35                	jne    801053ba <cstart+0x9e>
80105385:	eb 1f                	jmp    801053a6 <cstart+0x8a>
	int i;

	// Find container
	acquire(&ctable.lock);

	for (i = 0; i < NCONT; i++) {
80105387:	ff 45 f4             	incl   -0xc(%ebp)
8010538a:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010538e:	7e a7                	jle    80105337 <cstart+0x1b>
		// TODO: Check if this works
		if (strncmp(name, c->name, strlen(name)) == 0)
			goto found;
	}

	release(&ctable.lock);
80105390:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80105397:	e8 61 02 00 00       	call   801055fd <release>
	return -1;
8010539c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053a1:	e9 8a 00 00 00       	jmp    80105430 <cstart+0x114>

found: 	

	// Check if RUNNABLE
	if (c->state != CRUNNABLE || (p = allocproc(c)) == 0) {
801053a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053a9:	89 04 24             	mov    %eax,(%esp)
801053ac:	e8 d8 ed ff ff       	call   80104189 <allocproc>
801053b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
801053b4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801053b8:	75 13                	jne    801053cd <cstart+0xb1>
		release(&ctable.lock);	
801053ba:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
801053c1:	e8 37 02 00 00       	call   801055fd <release>
		return -1;
801053c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053cb:	eb 63                	jmp    80105430 <cstart+0x114>

	// TODO: Attach to a vc

	// TODO: Change namex to search container

	cpu = mycpu();	
801053cd:	e8 19 f8 ff ff       	call   80104beb <mycpu>
801053d2:	89 45 e8             	mov    %eax,-0x18(%ebp)

	// TODO: Check: Acquire ptable?
	// Exec process
	cpu->proc = p;
801053d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801053d8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801053db:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
	cprintf("execing proc %s with argv[1] %s\n", argv[0], argv[1]);
801053e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801053e4:	83 c0 04             	add    $0x4,%eax
801053e7:	8b 10                	mov    (%eax),%edx
801053e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801053ec:	8b 00                	mov    (%eax),%eax
801053ee:	89 54 24 08          	mov    %edx,0x8(%esp)
801053f2:	89 44 24 04          	mov    %eax,0x4(%esp)
801053f6:	c7 04 24 14 93 10 80 	movl   $0x80109314,(%esp)
801053fd:	e8 bf af ff ff       	call   801003c1 <cprintf>
	// TODO: CHANGE TO ARGV[0]
	exec("ctest1/echoloop", argv); 	
80105402:	8b 45 0c             	mov    0xc(%ebp),%eax
80105405:	89 44 24 04          	mov    %eax,0x4(%esp)
80105409:	c7 04 24 35 93 10 80 	movl   $0x80109335,(%esp)
80105410:	e8 f3 b7 ff ff       	call   80100c08 <exec>
	
	c->state = CRUNNING;	
80105415:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105418:	c7 40 14 04 00 00 00 	movl   $0x4,0x14(%eax)

	release(&ctable.lock);	
8010541f:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80105426:	e8 d2 01 00 00       	call   801055fd <release>

	return 1;
8010542b:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105430:	c9                   	leave  
80105431:	c3                   	ret    
	...

80105434 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80105434:	55                   	push   %ebp
80105435:	89 e5                	mov    %esp,%ebp
80105437:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
8010543a:	8b 45 08             	mov    0x8(%ebp),%eax
8010543d:	83 c0 04             	add    $0x4,%eax
80105440:	c7 44 24 04 6b 93 10 	movl   $0x8010936b,0x4(%esp)
80105447:	80 
80105448:	89 04 24             	mov    %eax,(%esp)
8010544b:	e8 22 01 00 00       	call   80105572 <initlock>
  lk->name = name;
80105450:	8b 45 08             	mov    0x8(%ebp),%eax
80105453:	8b 55 0c             	mov    0xc(%ebp),%edx
80105456:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105459:	8b 45 08             	mov    0x8(%ebp),%eax
8010545c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105462:	8b 45 08             	mov    0x8(%ebp),%eax
80105465:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
8010546c:	c9                   	leave  
8010546d:	c3                   	ret    

8010546e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010546e:	55                   	push   %ebp
8010546f:	89 e5                	mov    %esp,%ebp
80105471:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80105474:	8b 45 08             	mov    0x8(%ebp),%eax
80105477:	83 c0 04             	add    $0x4,%eax
8010547a:	89 04 24             	mov    %eax,(%esp)
8010547d:	e8 11 01 00 00       	call   80105593 <acquire>
  while (lk->locked) {
80105482:	eb 15                	jmp    80105499 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80105484:	8b 45 08             	mov    0x8(%ebp),%eax
80105487:	83 c0 04             	add    $0x4,%eax
8010548a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010548e:	8b 45 08             	mov    0x8(%ebp),%eax
80105491:	89 04 24             	mov    %eax,(%esp)
80105494:	e8 0b f4 ff ff       	call   801048a4 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80105499:	8b 45 08             	mov    0x8(%ebp),%eax
8010549c:	8b 00                	mov    (%eax),%eax
8010549e:	85 c0                	test   %eax,%eax
801054a0:	75 e2                	jne    80105484 <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
801054a2:	8b 45 08             	mov    0x8(%ebp),%eax
801054a5:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
801054ab:	e8 b0 ec ff ff       	call   80104160 <myproc>
801054b0:	8b 50 10             	mov    0x10(%eax),%edx
801054b3:	8b 45 08             	mov    0x8(%ebp),%eax
801054b6:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
801054b9:	8b 45 08             	mov    0x8(%ebp),%eax
801054bc:	83 c0 04             	add    $0x4,%eax
801054bf:	89 04 24             	mov    %eax,(%esp)
801054c2:	e8 36 01 00 00       	call   801055fd <release>
}
801054c7:	c9                   	leave  
801054c8:	c3                   	ret    

801054c9 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
801054c9:	55                   	push   %ebp
801054ca:	89 e5                	mov    %esp,%ebp
801054cc:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
801054cf:	8b 45 08             	mov    0x8(%ebp),%eax
801054d2:	83 c0 04             	add    $0x4,%eax
801054d5:	89 04 24             	mov    %eax,(%esp)
801054d8:	e8 b6 00 00 00       	call   80105593 <acquire>
  lk->locked = 0;
801054dd:	8b 45 08             	mov    0x8(%ebp),%eax
801054e0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801054e6:	8b 45 08             	mov    0x8(%ebp),%eax
801054e9:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801054f0:	8b 45 08             	mov    0x8(%ebp),%eax
801054f3:	89 04 24             	mov    %eax,(%esp)
801054f6:	e8 97 f4 ff ff       	call   80104992 <wakeup>
  release(&lk->lk);
801054fb:	8b 45 08             	mov    0x8(%ebp),%eax
801054fe:	83 c0 04             	add    $0x4,%eax
80105501:	89 04 24             	mov    %eax,(%esp)
80105504:	e8 f4 00 00 00       	call   801055fd <release>
}
80105509:	c9                   	leave  
8010550a:	c3                   	ret    

8010550b <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
8010550b:	55                   	push   %ebp
8010550c:	89 e5                	mov    %esp,%ebp
8010550e:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
80105511:	8b 45 08             	mov    0x8(%ebp),%eax
80105514:	83 c0 04             	add    $0x4,%eax
80105517:	89 04 24             	mov    %eax,(%esp)
8010551a:	e8 74 00 00 00       	call   80105593 <acquire>
  r = lk->locked;
8010551f:	8b 45 08             	mov    0x8(%ebp),%eax
80105522:	8b 00                	mov    (%eax),%eax
80105524:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105527:	8b 45 08             	mov    0x8(%ebp),%eax
8010552a:	83 c0 04             	add    $0x4,%eax
8010552d:	89 04 24             	mov    %eax,(%esp)
80105530:	e8 c8 00 00 00       	call   801055fd <release>
  return r;
80105535:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105538:	c9                   	leave  
80105539:	c3                   	ret    
	...

8010553c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010553c:	55                   	push   %ebp
8010553d:	89 e5                	mov    %esp,%ebp
8010553f:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105542:	9c                   	pushf  
80105543:	58                   	pop    %eax
80105544:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105547:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010554a:	c9                   	leave  
8010554b:	c3                   	ret    

8010554c <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010554c:	55                   	push   %ebp
8010554d:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010554f:	fa                   	cli    
}
80105550:	5d                   	pop    %ebp
80105551:	c3                   	ret    

80105552 <sti>:

static inline void
sti(void)
{
80105552:	55                   	push   %ebp
80105553:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105555:	fb                   	sti    
}
80105556:	5d                   	pop    %ebp
80105557:	c3                   	ret    

80105558 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105558:	55                   	push   %ebp
80105559:	89 e5                	mov    %esp,%ebp
8010555b:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010555e:	8b 55 08             	mov    0x8(%ebp),%edx
80105561:	8b 45 0c             	mov    0xc(%ebp),%eax
80105564:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105567:	f0 87 02             	lock xchg %eax,(%edx)
8010556a:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010556d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105570:	c9                   	leave  
80105571:	c3                   	ret    

80105572 <initlock>:
#include "container.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105572:	55                   	push   %ebp
80105573:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105575:	8b 45 08             	mov    0x8(%ebp),%eax
80105578:	8b 55 0c             	mov    0xc(%ebp),%edx
8010557b:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010557e:	8b 45 08             	mov    0x8(%ebp),%eax
80105581:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105587:	8b 45 08             	mov    0x8(%ebp),%eax
8010558a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105591:	5d                   	pop    %ebp
80105592:	c3                   	ret    

80105593 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105593:	55                   	push   %ebp
80105594:	89 e5                	mov    %esp,%ebp
80105596:	53                   	push   %ebx
80105597:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010559a:	e8 53 01 00 00       	call   801056f2 <pushcli>
  if(holding(lk))
8010559f:	8b 45 08             	mov    0x8(%ebp),%eax
801055a2:	89 04 24             	mov    %eax,(%esp)
801055a5:	e8 17 01 00 00       	call   801056c1 <holding>
801055aa:	85 c0                	test   %eax,%eax
801055ac:	74 0c                	je     801055ba <acquire+0x27>
    panic("acquire");
801055ae:	c7 04 24 76 93 10 80 	movl   $0x80109376,(%esp)
801055b5:	e8 9a af ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
801055ba:	90                   	nop
801055bb:	8b 45 08             	mov    0x8(%ebp),%eax
801055be:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801055c5:	00 
801055c6:	89 04 24             	mov    %eax,(%esp)
801055c9:	e8 8a ff ff ff       	call   80105558 <xchg>
801055ce:	85 c0                	test   %eax,%eax
801055d0:	75 e9                	jne    801055bb <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
801055d2:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801055d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
801055da:	e8 0c f6 ff ff       	call   80104beb <mycpu>
801055df:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801055e2:	8b 45 08             	mov    0x8(%ebp),%eax
801055e5:	83 c0 0c             	add    $0xc,%eax
801055e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801055ec:	8d 45 08             	lea    0x8(%ebp),%eax
801055ef:	89 04 24             	mov    %eax,(%esp)
801055f2:	e8 53 00 00 00       	call   8010564a <getcallerpcs>
}
801055f7:	83 c4 14             	add    $0x14,%esp
801055fa:	5b                   	pop    %ebx
801055fb:	5d                   	pop    %ebp
801055fc:	c3                   	ret    

801055fd <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801055fd:	55                   	push   %ebp
801055fe:	89 e5                	mov    %esp,%ebp
80105600:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105603:	8b 45 08             	mov    0x8(%ebp),%eax
80105606:	89 04 24             	mov    %eax,(%esp)
80105609:	e8 b3 00 00 00       	call   801056c1 <holding>
8010560e:	85 c0                	test   %eax,%eax
80105610:	75 0c                	jne    8010561e <release+0x21>
    panic("release");
80105612:	c7 04 24 7e 93 10 80 	movl   $0x8010937e,(%esp)
80105619:	e8 36 af ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
8010561e:	8b 45 08             	mov    0x8(%ebp),%eax
80105621:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105628:	8b 45 08             	mov    0x8(%ebp),%eax
8010562b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80105632:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105637:	8b 45 08             	mov    0x8(%ebp),%eax
8010563a:	8b 55 08             	mov    0x8(%ebp),%edx
8010563d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
80105643:	e8 f4 00 00 00       	call   8010573c <popcli>
}
80105648:	c9                   	leave  
80105649:	c3                   	ret    

8010564a <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
8010564a:	55                   	push   %ebp
8010564b:	89 e5                	mov    %esp,%ebp
8010564d:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80105650:	8b 45 08             	mov    0x8(%ebp),%eax
80105653:	83 e8 08             	sub    $0x8,%eax
80105656:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105659:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105660:	eb 37                	jmp    80105699 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105662:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105666:	74 37                	je     8010569f <getcallerpcs+0x55>
80105668:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010566f:	76 2e                	jbe    8010569f <getcallerpcs+0x55>
80105671:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105675:	74 28                	je     8010569f <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105677:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010567a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105681:	8b 45 0c             	mov    0xc(%ebp),%eax
80105684:	01 c2                	add    %eax,%edx
80105686:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105689:	8b 40 04             	mov    0x4(%eax),%eax
8010568c:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010568e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105691:	8b 00                	mov    (%eax),%eax
80105693:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105696:	ff 45 f8             	incl   -0x8(%ebp)
80105699:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010569d:	7e c3                	jle    80105662 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010569f:	eb 18                	jmp    801056b9 <getcallerpcs+0x6f>
    pcs[i] = 0;
801056a1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801056a4:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801056ab:	8b 45 0c             	mov    0xc(%ebp),%eax
801056ae:	01 d0                	add    %edx,%eax
801056b0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801056b6:	ff 45 f8             	incl   -0x8(%ebp)
801056b9:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801056bd:	7e e2                	jle    801056a1 <getcallerpcs+0x57>
    pcs[i] = 0;
}
801056bf:	c9                   	leave  
801056c0:	c3                   	ret    

801056c1 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801056c1:	55                   	push   %ebp
801056c2:	89 e5                	mov    %esp,%ebp
801056c4:	53                   	push   %ebx
801056c5:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
801056c8:	8b 45 08             	mov    0x8(%ebp),%eax
801056cb:	8b 00                	mov    (%eax),%eax
801056cd:	85 c0                	test   %eax,%eax
801056cf:	74 16                	je     801056e7 <holding+0x26>
801056d1:	8b 45 08             	mov    0x8(%ebp),%eax
801056d4:	8b 58 08             	mov    0x8(%eax),%ebx
801056d7:	e8 0f f5 ff ff       	call   80104beb <mycpu>
801056dc:	39 c3                	cmp    %eax,%ebx
801056de:	75 07                	jne    801056e7 <holding+0x26>
801056e0:	b8 01 00 00 00       	mov    $0x1,%eax
801056e5:	eb 05                	jmp    801056ec <holding+0x2b>
801056e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056ec:	83 c4 04             	add    $0x4,%esp
801056ef:	5b                   	pop    %ebx
801056f0:	5d                   	pop    %ebp
801056f1:	c3                   	ret    

801056f2 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801056f2:	55                   	push   %ebp
801056f3:	89 e5                	mov    %esp,%ebp
801056f5:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801056f8:	e8 3f fe ff ff       	call   8010553c <readeflags>
801056fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105700:	e8 47 fe ff ff       	call   8010554c <cli>
  if(mycpu()->ncli == 0)
80105705:	e8 e1 f4 ff ff       	call   80104beb <mycpu>
8010570a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105710:	85 c0                	test   %eax,%eax
80105712:	75 14                	jne    80105728 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80105714:	e8 d2 f4 ff ff       	call   80104beb <mycpu>
80105719:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010571c:	81 e2 00 02 00 00    	and    $0x200,%edx
80105722:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105728:	e8 be f4 ff ff       	call   80104beb <mycpu>
8010572d:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105733:	42                   	inc    %edx
80105734:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
8010573a:	c9                   	leave  
8010573b:	c3                   	ret    

8010573c <popcli>:

void
popcli(void)
{
8010573c:	55                   	push   %ebp
8010573d:	89 e5                	mov    %esp,%ebp
8010573f:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105742:	e8 f5 fd ff ff       	call   8010553c <readeflags>
80105747:	25 00 02 00 00       	and    $0x200,%eax
8010574c:	85 c0                	test   %eax,%eax
8010574e:	74 0c                	je     8010575c <popcli+0x20>
    panic("popcli - interruptible");
80105750:	c7 04 24 86 93 10 80 	movl   $0x80109386,(%esp)
80105757:	e8 f8 ad ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
8010575c:	e8 8a f4 ff ff       	call   80104beb <mycpu>
80105761:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105767:	4a                   	dec    %edx
80105768:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010576e:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105774:	85 c0                	test   %eax,%eax
80105776:	79 0c                	jns    80105784 <popcli+0x48>
    panic("popcli");
80105778:	c7 04 24 9d 93 10 80 	movl   $0x8010939d,(%esp)
8010577f:	e8 d0 ad ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105784:	e8 62 f4 ff ff       	call   80104beb <mycpu>
80105789:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010578f:	85 c0                	test   %eax,%eax
80105791:	75 14                	jne    801057a7 <popcli+0x6b>
80105793:	e8 53 f4 ff ff       	call   80104beb <mycpu>
80105798:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010579e:	85 c0                	test   %eax,%eax
801057a0:	74 05                	je     801057a7 <popcli+0x6b>
    sti();
801057a2:	e8 ab fd ff ff       	call   80105552 <sti>
}
801057a7:	c9                   	leave  
801057a8:	c3                   	ret    
801057a9:	00 00                	add    %al,(%eax)
	...

801057ac <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801057ac:	55                   	push   %ebp
801057ad:	89 e5                	mov    %esp,%ebp
801057af:	57                   	push   %edi
801057b0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801057b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
801057b4:	8b 55 10             	mov    0x10(%ebp),%edx
801057b7:	8b 45 0c             	mov    0xc(%ebp),%eax
801057ba:	89 cb                	mov    %ecx,%ebx
801057bc:	89 df                	mov    %ebx,%edi
801057be:	89 d1                	mov    %edx,%ecx
801057c0:	fc                   	cld    
801057c1:	f3 aa                	rep stos %al,%es:(%edi)
801057c3:	89 ca                	mov    %ecx,%edx
801057c5:	89 fb                	mov    %edi,%ebx
801057c7:	89 5d 08             	mov    %ebx,0x8(%ebp)
801057ca:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801057cd:	5b                   	pop    %ebx
801057ce:	5f                   	pop    %edi
801057cf:	5d                   	pop    %ebp
801057d0:	c3                   	ret    

801057d1 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801057d1:	55                   	push   %ebp
801057d2:	89 e5                	mov    %esp,%ebp
801057d4:	57                   	push   %edi
801057d5:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801057d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801057d9:	8b 55 10             	mov    0x10(%ebp),%edx
801057dc:	8b 45 0c             	mov    0xc(%ebp),%eax
801057df:	89 cb                	mov    %ecx,%ebx
801057e1:	89 df                	mov    %ebx,%edi
801057e3:	89 d1                	mov    %edx,%ecx
801057e5:	fc                   	cld    
801057e6:	f3 ab                	rep stos %eax,%es:(%edi)
801057e8:	89 ca                	mov    %ecx,%edx
801057ea:	89 fb                	mov    %edi,%ebx
801057ec:	89 5d 08             	mov    %ebx,0x8(%ebp)
801057ef:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801057f2:	5b                   	pop    %ebx
801057f3:	5f                   	pop    %edi
801057f4:	5d                   	pop    %ebp
801057f5:	c3                   	ret    

801057f6 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801057f6:	55                   	push   %ebp
801057f7:	89 e5                	mov    %esp,%ebp
801057f9:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801057fc:	8b 45 08             	mov    0x8(%ebp),%eax
801057ff:	83 e0 03             	and    $0x3,%eax
80105802:	85 c0                	test   %eax,%eax
80105804:	75 49                	jne    8010584f <memset+0x59>
80105806:	8b 45 10             	mov    0x10(%ebp),%eax
80105809:	83 e0 03             	and    $0x3,%eax
8010580c:	85 c0                	test   %eax,%eax
8010580e:	75 3f                	jne    8010584f <memset+0x59>
    c &= 0xFF;
80105810:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105817:	8b 45 10             	mov    0x10(%ebp),%eax
8010581a:	c1 e8 02             	shr    $0x2,%eax
8010581d:	89 c2                	mov    %eax,%edx
8010581f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105822:	c1 e0 18             	shl    $0x18,%eax
80105825:	89 c1                	mov    %eax,%ecx
80105827:	8b 45 0c             	mov    0xc(%ebp),%eax
8010582a:	c1 e0 10             	shl    $0x10,%eax
8010582d:	09 c1                	or     %eax,%ecx
8010582f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105832:	c1 e0 08             	shl    $0x8,%eax
80105835:	09 c8                	or     %ecx,%eax
80105837:	0b 45 0c             	or     0xc(%ebp),%eax
8010583a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010583e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105842:	8b 45 08             	mov    0x8(%ebp),%eax
80105845:	89 04 24             	mov    %eax,(%esp)
80105848:	e8 84 ff ff ff       	call   801057d1 <stosl>
8010584d:	eb 19                	jmp    80105868 <memset+0x72>
  } else
    stosb(dst, c, n);
8010584f:	8b 45 10             	mov    0x10(%ebp),%eax
80105852:	89 44 24 08          	mov    %eax,0x8(%esp)
80105856:	8b 45 0c             	mov    0xc(%ebp),%eax
80105859:	89 44 24 04          	mov    %eax,0x4(%esp)
8010585d:	8b 45 08             	mov    0x8(%ebp),%eax
80105860:	89 04 24             	mov    %eax,(%esp)
80105863:	e8 44 ff ff ff       	call   801057ac <stosb>
  return dst;
80105868:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010586b:	c9                   	leave  
8010586c:	c3                   	ret    

8010586d <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
8010586d:	55                   	push   %ebp
8010586e:	89 e5                	mov    %esp,%ebp
80105870:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105873:	8b 45 08             	mov    0x8(%ebp),%eax
80105876:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105879:	8b 45 0c             	mov    0xc(%ebp),%eax
8010587c:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010587f:	eb 2a                	jmp    801058ab <memcmp+0x3e>
    if(*s1 != *s2)
80105881:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105884:	8a 10                	mov    (%eax),%dl
80105886:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105889:	8a 00                	mov    (%eax),%al
8010588b:	38 c2                	cmp    %al,%dl
8010588d:	74 16                	je     801058a5 <memcmp+0x38>
      return *s1 - *s2;
8010588f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105892:	8a 00                	mov    (%eax),%al
80105894:	0f b6 d0             	movzbl %al,%edx
80105897:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010589a:	8a 00                	mov    (%eax),%al
8010589c:	0f b6 c0             	movzbl %al,%eax
8010589f:	29 c2                	sub    %eax,%edx
801058a1:	89 d0                	mov    %edx,%eax
801058a3:	eb 18                	jmp    801058bd <memcmp+0x50>
    s1++, s2++;
801058a5:	ff 45 fc             	incl   -0x4(%ebp)
801058a8:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801058ab:	8b 45 10             	mov    0x10(%ebp),%eax
801058ae:	8d 50 ff             	lea    -0x1(%eax),%edx
801058b1:	89 55 10             	mov    %edx,0x10(%ebp)
801058b4:	85 c0                	test   %eax,%eax
801058b6:	75 c9                	jne    80105881 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801058b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058bd:	c9                   	leave  
801058be:	c3                   	ret    

801058bf <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801058bf:	55                   	push   %ebp
801058c0:	89 e5                	mov    %esp,%ebp
801058c2:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801058c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801058c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801058cb:	8b 45 08             	mov    0x8(%ebp),%eax
801058ce:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801058d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058d4:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801058d7:	73 3a                	jae    80105913 <memmove+0x54>
801058d9:	8b 45 10             	mov    0x10(%ebp),%eax
801058dc:	8b 55 fc             	mov    -0x4(%ebp),%edx
801058df:	01 d0                	add    %edx,%eax
801058e1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801058e4:	76 2d                	jbe    80105913 <memmove+0x54>
    s += n;
801058e6:	8b 45 10             	mov    0x10(%ebp),%eax
801058e9:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801058ec:	8b 45 10             	mov    0x10(%ebp),%eax
801058ef:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801058f2:	eb 10                	jmp    80105904 <memmove+0x45>
      *--d = *--s;
801058f4:	ff 4d f8             	decl   -0x8(%ebp)
801058f7:	ff 4d fc             	decl   -0x4(%ebp)
801058fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058fd:	8a 10                	mov    (%eax),%dl
801058ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105902:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105904:	8b 45 10             	mov    0x10(%ebp),%eax
80105907:	8d 50 ff             	lea    -0x1(%eax),%edx
8010590a:	89 55 10             	mov    %edx,0x10(%ebp)
8010590d:	85 c0                	test   %eax,%eax
8010590f:	75 e3                	jne    801058f4 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105911:	eb 25                	jmp    80105938 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105913:	eb 16                	jmp    8010592b <memmove+0x6c>
      *d++ = *s++;
80105915:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105918:	8d 50 01             	lea    0x1(%eax),%edx
8010591b:	89 55 f8             	mov    %edx,-0x8(%ebp)
8010591e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105921:	8d 4a 01             	lea    0x1(%edx),%ecx
80105924:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105927:	8a 12                	mov    (%edx),%dl
80105929:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
8010592b:	8b 45 10             	mov    0x10(%ebp),%eax
8010592e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105931:	89 55 10             	mov    %edx,0x10(%ebp)
80105934:	85 c0                	test   %eax,%eax
80105936:	75 dd                	jne    80105915 <memmove+0x56>
      *d++ = *s++;

  return dst;
80105938:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010593b:	c9                   	leave  
8010593c:	c3                   	ret    

8010593d <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
8010593d:	55                   	push   %ebp
8010593e:	89 e5                	mov    %esp,%ebp
80105940:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105943:	8b 45 10             	mov    0x10(%ebp),%eax
80105946:	89 44 24 08          	mov    %eax,0x8(%esp)
8010594a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010594d:	89 44 24 04          	mov    %eax,0x4(%esp)
80105951:	8b 45 08             	mov    0x8(%ebp),%eax
80105954:	89 04 24             	mov    %eax,(%esp)
80105957:	e8 63 ff ff ff       	call   801058bf <memmove>
}
8010595c:	c9                   	leave  
8010595d:	c3                   	ret    

8010595e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010595e:	55                   	push   %ebp
8010595f:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105961:	eb 09                	jmp    8010596c <strncmp+0xe>
    n--, p++, q++;
80105963:	ff 4d 10             	decl   0x10(%ebp)
80105966:	ff 45 08             	incl   0x8(%ebp)
80105969:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
8010596c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105970:	74 17                	je     80105989 <strncmp+0x2b>
80105972:	8b 45 08             	mov    0x8(%ebp),%eax
80105975:	8a 00                	mov    (%eax),%al
80105977:	84 c0                	test   %al,%al
80105979:	74 0e                	je     80105989 <strncmp+0x2b>
8010597b:	8b 45 08             	mov    0x8(%ebp),%eax
8010597e:	8a 10                	mov    (%eax),%dl
80105980:	8b 45 0c             	mov    0xc(%ebp),%eax
80105983:	8a 00                	mov    (%eax),%al
80105985:	38 c2                	cmp    %al,%dl
80105987:	74 da                	je     80105963 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105989:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010598d:	75 07                	jne    80105996 <strncmp+0x38>
    return 0;
8010598f:	b8 00 00 00 00       	mov    $0x0,%eax
80105994:	eb 14                	jmp    801059aa <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
80105996:	8b 45 08             	mov    0x8(%ebp),%eax
80105999:	8a 00                	mov    (%eax),%al
8010599b:	0f b6 d0             	movzbl %al,%edx
8010599e:	8b 45 0c             	mov    0xc(%ebp),%eax
801059a1:	8a 00                	mov    (%eax),%al
801059a3:	0f b6 c0             	movzbl %al,%eax
801059a6:	29 c2                	sub    %eax,%edx
801059a8:	89 d0                	mov    %edx,%eax
}
801059aa:	5d                   	pop    %ebp
801059ab:	c3                   	ret    

801059ac <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801059ac:	55                   	push   %ebp
801059ad:	89 e5                	mov    %esp,%ebp
801059af:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801059b2:	8b 45 08             	mov    0x8(%ebp),%eax
801059b5:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801059b8:	90                   	nop
801059b9:	8b 45 10             	mov    0x10(%ebp),%eax
801059bc:	8d 50 ff             	lea    -0x1(%eax),%edx
801059bf:	89 55 10             	mov    %edx,0x10(%ebp)
801059c2:	85 c0                	test   %eax,%eax
801059c4:	7e 1c                	jle    801059e2 <strncpy+0x36>
801059c6:	8b 45 08             	mov    0x8(%ebp),%eax
801059c9:	8d 50 01             	lea    0x1(%eax),%edx
801059cc:	89 55 08             	mov    %edx,0x8(%ebp)
801059cf:	8b 55 0c             	mov    0xc(%ebp),%edx
801059d2:	8d 4a 01             	lea    0x1(%edx),%ecx
801059d5:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801059d8:	8a 12                	mov    (%edx),%dl
801059da:	88 10                	mov    %dl,(%eax)
801059dc:	8a 00                	mov    (%eax),%al
801059de:	84 c0                	test   %al,%al
801059e0:	75 d7                	jne    801059b9 <strncpy+0xd>
    ;
  while(n-- > 0)
801059e2:	eb 0c                	jmp    801059f0 <strncpy+0x44>
    *s++ = 0;
801059e4:	8b 45 08             	mov    0x8(%ebp),%eax
801059e7:	8d 50 01             	lea    0x1(%eax),%edx
801059ea:	89 55 08             	mov    %edx,0x8(%ebp)
801059ed:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801059f0:	8b 45 10             	mov    0x10(%ebp),%eax
801059f3:	8d 50 ff             	lea    -0x1(%eax),%edx
801059f6:	89 55 10             	mov    %edx,0x10(%ebp)
801059f9:	85 c0                	test   %eax,%eax
801059fb:	7f e7                	jg     801059e4 <strncpy+0x38>
    *s++ = 0;
  return os;
801059fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105a00:	c9                   	leave  
80105a01:	c3                   	ret    

80105a02 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105a02:	55                   	push   %ebp
80105a03:	89 e5                	mov    %esp,%ebp
80105a05:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105a08:	8b 45 08             	mov    0x8(%ebp),%eax
80105a0b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105a0e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a12:	7f 05                	jg     80105a19 <safestrcpy+0x17>
    return os;
80105a14:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a17:	eb 2e                	jmp    80105a47 <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
80105a19:	ff 4d 10             	decl   0x10(%ebp)
80105a1c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a20:	7e 1c                	jle    80105a3e <safestrcpy+0x3c>
80105a22:	8b 45 08             	mov    0x8(%ebp),%eax
80105a25:	8d 50 01             	lea    0x1(%eax),%edx
80105a28:	89 55 08             	mov    %edx,0x8(%ebp)
80105a2b:	8b 55 0c             	mov    0xc(%ebp),%edx
80105a2e:	8d 4a 01             	lea    0x1(%edx),%ecx
80105a31:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105a34:	8a 12                	mov    (%edx),%dl
80105a36:	88 10                	mov    %dl,(%eax)
80105a38:	8a 00                	mov    (%eax),%al
80105a3a:	84 c0                	test   %al,%al
80105a3c:	75 db                	jne    80105a19 <safestrcpy+0x17>
    ;
  *s = 0;
80105a3e:	8b 45 08             	mov    0x8(%ebp),%eax
80105a41:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105a44:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105a47:	c9                   	leave  
80105a48:	c3                   	ret    

80105a49 <strlen>:

int
strlen(const char *s)
{
80105a49:	55                   	push   %ebp
80105a4a:	89 e5                	mov    %esp,%ebp
80105a4c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105a4f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105a56:	eb 03                	jmp    80105a5b <strlen+0x12>
80105a58:	ff 45 fc             	incl   -0x4(%ebp)
80105a5b:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105a5e:	8b 45 08             	mov    0x8(%ebp),%eax
80105a61:	01 d0                	add    %edx,%eax
80105a63:	8a 00                	mov    (%eax),%al
80105a65:	84 c0                	test   %al,%al
80105a67:	75 ef                	jne    80105a58 <strlen+0xf>
    ;
  return n;
80105a69:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105a6c:	c9                   	leave  
80105a6d:	c3                   	ret    
	...

80105a70 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105a70:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105a74:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105a78:	55                   	push   %ebp
  pushl %ebx
80105a79:	53                   	push   %ebx
  pushl %esi
80105a7a:	56                   	push   %esi
  pushl %edi
80105a7b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105a7c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105a7e:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105a80:	5f                   	pop    %edi
  popl %esi
80105a81:	5e                   	pop    %esi
  popl %ebx
80105a82:	5b                   	pop    %ebx
  popl %ebp
80105a83:	5d                   	pop    %ebp
  ret
80105a84:	c3                   	ret    
80105a85:	00 00                	add    %al,(%eax)
	...

80105a88 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105a88:	55                   	push   %ebp
80105a89:	89 e5                	mov    %esp,%ebp
80105a8b:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105a8e:	e8 cd e6 ff ff       	call   80104160 <myproc>
80105a93:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a99:	8b 00                	mov    (%eax),%eax
80105a9b:	3b 45 08             	cmp    0x8(%ebp),%eax
80105a9e:	76 0f                	jbe    80105aaf <fetchint+0x27>
80105aa0:	8b 45 08             	mov    0x8(%ebp),%eax
80105aa3:	8d 50 04             	lea    0x4(%eax),%edx
80105aa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aa9:	8b 00                	mov    (%eax),%eax
80105aab:	39 c2                	cmp    %eax,%edx
80105aad:	76 07                	jbe    80105ab6 <fetchint+0x2e>
    return -1;
80105aaf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ab4:	eb 0f                	jmp    80105ac5 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105ab6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ab9:	8b 10                	mov    (%eax),%edx
80105abb:	8b 45 0c             	mov    0xc(%ebp),%eax
80105abe:	89 10                	mov    %edx,(%eax)
  return 0;
80105ac0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ac5:	c9                   	leave  
80105ac6:	c3                   	ret    

80105ac7 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105ac7:	55                   	push   %ebp
80105ac8:	89 e5                	mov    %esp,%ebp
80105aca:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105acd:	e8 8e e6 ff ff       	call   80104160 <myproc>
80105ad2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105ad5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ad8:	8b 00                	mov    (%eax),%eax
80105ada:	3b 45 08             	cmp    0x8(%ebp),%eax
80105add:	77 07                	ja     80105ae6 <fetchstr+0x1f>
    return -1;
80105adf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ae4:	eb 41                	jmp    80105b27 <fetchstr+0x60>
  *pp = (char*)addr;
80105ae6:	8b 55 08             	mov    0x8(%ebp),%edx
80105ae9:	8b 45 0c             	mov    0xc(%ebp),%eax
80105aec:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105aee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105af1:	8b 00                	mov    (%eax),%eax
80105af3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105af6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105af9:	8b 00                	mov    (%eax),%eax
80105afb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105afe:	eb 1a                	jmp    80105b1a <fetchstr+0x53>
    if(*s == 0)
80105b00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b03:	8a 00                	mov    (%eax),%al
80105b05:	84 c0                	test   %al,%al
80105b07:	75 0e                	jne    80105b17 <fetchstr+0x50>
      return s - *pp;
80105b09:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b0c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b0f:	8b 00                	mov    (%eax),%eax
80105b11:	29 c2                	sub    %eax,%edx
80105b13:	89 d0                	mov    %edx,%eax
80105b15:	eb 10                	jmp    80105b27 <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
80105b17:	ff 45 f4             	incl   -0xc(%ebp)
80105b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b1d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105b20:	72 de                	jb     80105b00 <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
80105b22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b27:	c9                   	leave  
80105b28:	c3                   	ret    

80105b29 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105b29:	55                   	push   %ebp
80105b2a:	89 e5                	mov    %esp,%ebp
80105b2c:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105b2f:	e8 2c e6 ff ff       	call   80104160 <myproc>
80105b34:	8b 40 18             	mov    0x18(%eax),%eax
80105b37:	8b 50 44             	mov    0x44(%eax),%edx
80105b3a:	8b 45 08             	mov    0x8(%ebp),%eax
80105b3d:	c1 e0 02             	shl    $0x2,%eax
80105b40:	01 d0                	add    %edx,%eax
80105b42:	8d 50 04             	lea    0x4(%eax),%edx
80105b45:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b48:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b4c:	89 14 24             	mov    %edx,(%esp)
80105b4f:	e8 34 ff ff ff       	call   80105a88 <fetchint>
}
80105b54:	c9                   	leave  
80105b55:	c3                   	ret    

80105b56 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105b56:	55                   	push   %ebp
80105b57:	89 e5                	mov    %esp,%ebp
80105b59:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
80105b5c:	e8 ff e5 ff ff       	call   80104160 <myproc>
80105b61:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105b64:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b67:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80105b6e:	89 04 24             	mov    %eax,(%esp)
80105b71:	e8 b3 ff ff ff       	call   80105b29 <argint>
80105b76:	85 c0                	test   %eax,%eax
80105b78:	79 07                	jns    80105b81 <argptr+0x2b>
    return -1;
80105b7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b7f:	eb 3d                	jmp    80105bbe <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105b81:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b85:	78 21                	js     80105ba8 <argptr+0x52>
80105b87:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b8a:	89 c2                	mov    %eax,%edx
80105b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b8f:	8b 00                	mov    (%eax),%eax
80105b91:	39 c2                	cmp    %eax,%edx
80105b93:	73 13                	jae    80105ba8 <argptr+0x52>
80105b95:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b98:	89 c2                	mov    %eax,%edx
80105b9a:	8b 45 10             	mov    0x10(%ebp),%eax
80105b9d:	01 c2                	add    %eax,%edx
80105b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba2:	8b 00                	mov    (%eax),%eax
80105ba4:	39 c2                	cmp    %eax,%edx
80105ba6:	76 07                	jbe    80105baf <argptr+0x59>
    return -1;
80105ba8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bad:	eb 0f                	jmp    80105bbe <argptr+0x68>
  *pp = (char*)i;
80105baf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bb2:	89 c2                	mov    %eax,%edx
80105bb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bb7:	89 10                	mov    %edx,(%eax)
  return 0;
80105bb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105bbe:	c9                   	leave  
80105bbf:	c3                   	ret    

80105bc0 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105bc0:	55                   	push   %ebp
80105bc1:	89 e5                	mov    %esp,%ebp
80105bc3:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105bc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bc9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80105bd0:	89 04 24             	mov    %eax,(%esp)
80105bd3:	e8 51 ff ff ff       	call   80105b29 <argint>
80105bd8:	85 c0                	test   %eax,%eax
80105bda:	79 07                	jns    80105be3 <argstr+0x23>
    return -1;
80105bdc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105be1:	eb 12                	jmp    80105bf5 <argstr+0x35>
  return fetchstr(addr, pp);
80105be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105be6:	8b 55 0c             	mov    0xc(%ebp),%edx
80105be9:	89 54 24 04          	mov    %edx,0x4(%esp)
80105bed:	89 04 24             	mov    %eax,(%esp)
80105bf0:	e8 d2 fe ff ff       	call   80105ac7 <fetchstr>
}
80105bf5:	c9                   	leave  
80105bf6:	c3                   	ret    

80105bf7 <syscall>:
[SYS_cinfo] sys_cinfo,
};

void
syscall(void)
{
80105bf7:	55                   	push   %ebp
80105bf8:	89 e5                	mov    %esp,%ebp
80105bfa:	53                   	push   %ebx
80105bfb:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
80105bfe:	e8 5d e5 ff ff       	call   80104160 <myproc>
80105c03:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105c06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c09:	8b 40 18             	mov    0x18(%eax),%eax
80105c0c:	8b 40 1c             	mov    0x1c(%eax),%eax
80105c0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105c12:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105c16:	7e 2d                	jle    80105c45 <syscall+0x4e>
80105c18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c1b:	83 f8 1b             	cmp    $0x1b,%eax
80105c1e:	77 25                	ja     80105c45 <syscall+0x4e>
80105c20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c23:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105c2a:	85 c0                	test   %eax,%eax
80105c2c:	74 17                	je     80105c45 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c31:	8b 58 18             	mov    0x18(%eax),%ebx
80105c34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c37:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105c3e:	ff d0                	call   *%eax
80105c40:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105c43:	eb 34                	jmp    80105c79 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c48:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c4e:	8b 40 10             	mov    0x10(%eax),%eax
80105c51:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105c54:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105c58:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105c5c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c60:	c7 04 24 a4 93 10 80 	movl   $0x801093a4,(%esp)
80105c67:	e8 55 a7 ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c6f:	8b 40 18             	mov    0x18(%eax),%eax
80105c72:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105c79:	83 c4 24             	add    $0x24,%esp
80105c7c:	5b                   	pop    %ebx
80105c7d:	5d                   	pop    %ebp
80105c7e:	c3                   	ret    
	...

80105c80 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105c80:	55                   	push   %ebp
80105c81:	89 e5                	mov    %esp,%ebp
80105c83:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105c86:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c89:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c8d:	8b 45 08             	mov    0x8(%ebp),%eax
80105c90:	89 04 24             	mov    %eax,(%esp)
80105c93:	e8 91 fe ff ff       	call   80105b29 <argint>
80105c98:	85 c0                	test   %eax,%eax
80105c9a:	79 07                	jns    80105ca3 <argfd+0x23>
    return -1;
80105c9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ca1:	eb 4f                	jmp    80105cf2 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105ca3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca6:	85 c0                	test   %eax,%eax
80105ca8:	78 20                	js     80105cca <argfd+0x4a>
80105caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105cad:	83 f8 0f             	cmp    $0xf,%eax
80105cb0:	7f 18                	jg     80105cca <argfd+0x4a>
80105cb2:	e8 a9 e4 ff ff       	call   80104160 <myproc>
80105cb7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cba:	83 c2 08             	add    $0x8,%edx
80105cbd:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105cc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cc4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105cc8:	75 07                	jne    80105cd1 <argfd+0x51>
    return -1;
80105cca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ccf:	eb 21                	jmp    80105cf2 <argfd+0x72>
  if(pfd)
80105cd1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105cd5:	74 08                	je     80105cdf <argfd+0x5f>
    *pfd = fd;
80105cd7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105cda:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cdd:	89 10                	mov    %edx,(%eax)
  if(pf)
80105cdf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ce3:	74 08                	je     80105ced <argfd+0x6d>
    *pf = f;
80105ce5:	8b 45 10             	mov    0x10(%ebp),%eax
80105ce8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ceb:	89 10                	mov    %edx,(%eax)
  return 0;
80105ced:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cf2:	c9                   	leave  
80105cf3:	c3                   	ret    

80105cf4 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105cf4:	55                   	push   %ebp
80105cf5:	89 e5                	mov    %esp,%ebp
80105cf7:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105cfa:	e8 61 e4 ff ff       	call   80104160 <myproc>
80105cff:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105d02:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105d09:	eb 29                	jmp    80105d34 <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
80105d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d0e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d11:	83 c2 08             	add    $0x8,%edx
80105d14:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105d18:	85 c0                	test   %eax,%eax
80105d1a:	75 15                	jne    80105d31 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105d1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d22:	8d 4a 08             	lea    0x8(%edx),%ecx
80105d25:	8b 55 08             	mov    0x8(%ebp),%edx
80105d28:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105d2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d2f:	eb 0e                	jmp    80105d3f <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105d31:	ff 45 f4             	incl   -0xc(%ebp)
80105d34:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105d38:	7e d1                	jle    80105d0b <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105d3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d3f:	c9                   	leave  
80105d40:	c3                   	ret    

80105d41 <sys_dup>:

int
sys_dup(void)
{
80105d41:	55                   	push   %ebp
80105d42:	89 e5                	mov    %esp,%ebp
80105d44:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105d47:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d4a:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d4e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105d55:	00 
80105d56:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d5d:	e8 1e ff ff ff       	call   80105c80 <argfd>
80105d62:	85 c0                	test   %eax,%eax
80105d64:	79 07                	jns    80105d6d <sys_dup+0x2c>
    return -1;
80105d66:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d6b:	eb 29                	jmp    80105d96 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d70:	89 04 24             	mov    %eax,(%esp)
80105d73:	e8 7c ff ff ff       	call   80105cf4 <fdalloc>
80105d78:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d7b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d7f:	79 07                	jns    80105d88 <sys_dup+0x47>
    return -1;
80105d81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d86:	eb 0e                	jmp    80105d96 <sys_dup+0x55>
  filedup(f);
80105d88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d8b:	89 04 24             	mov    %eax,(%esp)
80105d8e:	e8 31 b3 ff ff       	call   801010c4 <filedup>
  return fd;
80105d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105d96:	c9                   	leave  
80105d97:	c3                   	ret    

80105d98 <sys_read>:

int
sys_read(void)
{
80105d98:	55                   	push   %ebp
80105d99:	89 e5                	mov    %esp,%ebp
80105d9b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105d9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105da1:	89 44 24 08          	mov    %eax,0x8(%esp)
80105da5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105dac:	00 
80105dad:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105db4:	e8 c7 fe ff ff       	call   80105c80 <argfd>
80105db9:	85 c0                	test   %eax,%eax
80105dbb:	78 35                	js     80105df2 <sys_read+0x5a>
80105dbd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105dc0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105dc4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105dcb:	e8 59 fd ff ff       	call   80105b29 <argint>
80105dd0:	85 c0                	test   %eax,%eax
80105dd2:	78 1e                	js     80105df2 <sys_read+0x5a>
80105dd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dd7:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ddb:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105dde:	89 44 24 04          	mov    %eax,0x4(%esp)
80105de2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105de9:	e8 68 fd ff ff       	call   80105b56 <argptr>
80105dee:	85 c0                	test   %eax,%eax
80105df0:	79 07                	jns    80105df9 <sys_read+0x61>
    return -1;
80105df2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105df7:	eb 19                	jmp    80105e12 <sys_read+0x7a>
  return fileread(f, p, n);
80105df9:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105dfc:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105dff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e02:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105e06:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e0a:	89 04 24             	mov    %eax,(%esp)
80105e0d:	e8 13 b4 ff ff       	call   80101225 <fileread>
}
80105e12:	c9                   	leave  
80105e13:	c3                   	ret    

80105e14 <sys_write>:

int
sys_write(void)
{
80105e14:	55                   	push   %ebp
80105e15:	89 e5                	mov    %esp,%ebp
80105e17:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105e1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e1d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e21:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105e28:	00 
80105e29:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e30:	e8 4b fe ff ff       	call   80105c80 <argfd>
80105e35:	85 c0                	test   %eax,%eax
80105e37:	78 35                	js     80105e6e <sys_write+0x5a>
80105e39:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e3c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e40:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105e47:	e8 dd fc ff ff       	call   80105b29 <argint>
80105e4c:	85 c0                	test   %eax,%eax
80105e4e:	78 1e                	js     80105e6e <sys_write+0x5a>
80105e50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e53:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e57:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e5a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e5e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e65:	e8 ec fc ff ff       	call   80105b56 <argptr>
80105e6a:	85 c0                	test   %eax,%eax
80105e6c:	79 07                	jns    80105e75 <sys_write+0x61>
    return -1;
80105e6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e73:	eb 19                	jmp    80105e8e <sys_write+0x7a>
  return filewrite(f, p, n);
80105e75:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105e78:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105e82:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e86:	89 04 24             	mov    %eax,(%esp)
80105e89:	e8 52 b4 ff ff       	call   801012e0 <filewrite>
}
80105e8e:	c9                   	leave  
80105e8f:	c3                   	ret    

80105e90 <sys_close>:

int
sys_close(void)
{
80105e90:	55                   	push   %ebp
80105e91:	89 e5                	mov    %esp,%ebp
80105e93:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105e96:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e99:	89 44 24 08          	mov    %eax,0x8(%esp)
80105e9d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ea0:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ea4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105eab:	e8 d0 fd ff ff       	call   80105c80 <argfd>
80105eb0:	85 c0                	test   %eax,%eax
80105eb2:	79 07                	jns    80105ebb <sys_close+0x2b>
    return -1;
80105eb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eb9:	eb 23                	jmp    80105ede <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
80105ebb:	e8 a0 e2 ff ff       	call   80104160 <myproc>
80105ec0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ec3:	83 c2 08             	add    $0x8,%edx
80105ec6:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105ecd:	00 
  fileclose(f);
80105ece:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ed1:	89 04 24             	mov    %eax,(%esp)
80105ed4:	e8 33 b2 ff ff       	call   8010110c <fileclose>
  return 0;
80105ed9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ede:	c9                   	leave  
80105edf:	c3                   	ret    

80105ee0 <sys_fstat>:

int
sys_fstat(void)
{
80105ee0:	55                   	push   %ebp
80105ee1:	89 e5                	mov    %esp,%ebp
80105ee3:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105ee6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ee9:	89 44 24 08          	mov    %eax,0x8(%esp)
80105eed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105ef4:	00 
80105ef5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105efc:	e8 7f fd ff ff       	call   80105c80 <argfd>
80105f01:	85 c0                	test   %eax,%eax
80105f03:	78 1f                	js     80105f24 <sys_fstat+0x44>
80105f05:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105f0c:	00 
80105f0d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f10:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f14:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105f1b:	e8 36 fc ff ff       	call   80105b56 <argptr>
80105f20:	85 c0                	test   %eax,%eax
80105f22:	79 07                	jns    80105f2b <sys_fstat+0x4b>
    return -1;
80105f24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f29:	eb 12                	jmp    80105f3d <sys_fstat+0x5d>
  return filestat(f, st);
80105f2b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f31:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f35:	89 04 24             	mov    %eax,(%esp)
80105f38:	e8 99 b2 ff ff       	call   801011d6 <filestat>
}
80105f3d:	c9                   	leave  
80105f3e:	c3                   	ret    

80105f3f <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105f3f:	55                   	push   %ebp
80105f40:	89 e5                	mov    %esp,%ebp
80105f42:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105f45:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105f48:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f53:	e8 68 fc ff ff       	call   80105bc0 <argstr>
80105f58:	85 c0                	test   %eax,%eax
80105f5a:	78 17                	js     80105f73 <sys_link+0x34>
80105f5c:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105f5f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f63:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105f6a:	e8 51 fc ff ff       	call   80105bc0 <argstr>
80105f6f:	85 c0                	test   %eax,%eax
80105f71:	79 0a                	jns    80105f7d <sys_link+0x3e>
    return -1;
80105f73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f78:	e9 3d 01 00 00       	jmp    801060ba <sys_link+0x17b>

  begin_op();
80105f7d:	e8 e1 d5 ff ff       	call   80103563 <begin_op>
  if((ip = namei(old)) == 0){
80105f82:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105f85:	89 04 24             	mov    %eax,(%esp)
80105f88:	e8 03 c6 ff ff       	call   80102590 <namei>
80105f8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f94:	75 0f                	jne    80105fa5 <sys_link+0x66>
    end_op();
80105f96:	e8 4a d6 ff ff       	call   801035e5 <end_op>
    return -1;
80105f9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fa0:	e9 15 01 00 00       	jmp    801060ba <sys_link+0x17b>
  }

  ilock(ip);
80105fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa8:	89 04 24             	mov    %eax,(%esp)
80105fab:	e8 76 ba ff ff       	call   80101a26 <ilock>
  if(ip->type == T_DIR){
80105fb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fb3:	8b 40 50             	mov    0x50(%eax),%eax
80105fb6:	66 83 f8 01          	cmp    $0x1,%ax
80105fba:	75 1a                	jne    80105fd6 <sys_link+0x97>
    iunlockput(ip);
80105fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fbf:	89 04 24             	mov    %eax,(%esp)
80105fc2:	e8 5e bc ff ff       	call   80101c25 <iunlockput>
    end_op();
80105fc7:	e8 19 d6 ff ff       	call   801035e5 <end_op>
    return -1;
80105fcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fd1:	e9 e4 00 00 00       	jmp    801060ba <sys_link+0x17b>
  }

  ip->nlink++;
80105fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fd9:	66 8b 40 56          	mov    0x56(%eax),%ax
80105fdd:	40                   	inc    %eax
80105fde:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fe1:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105fe5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fe8:	89 04 24             	mov    %eax,(%esp)
80105feb:	e8 73 b8 ff ff       	call   80101863 <iupdate>
  iunlock(ip);
80105ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff3:	89 04 24             	mov    %eax,(%esp)
80105ff6:	e8 35 bb ff ff       	call   80101b30 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105ffb:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105ffe:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80106001:	89 54 24 04          	mov    %edx,0x4(%esp)
80106005:	89 04 24             	mov    %eax,(%esp)
80106008:	e8 a5 c5 ff ff       	call   801025b2 <nameiparent>
8010600d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106010:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106014:	75 02                	jne    80106018 <sys_link+0xd9>
    goto bad;
80106016:	eb 68                	jmp    80106080 <sys_link+0x141>
  ilock(dp);
80106018:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010601b:	89 04 24             	mov    %eax,(%esp)
8010601e:	e8 03 ba ff ff       	call   80101a26 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106023:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106026:	8b 10                	mov    (%eax),%edx
80106028:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010602b:	8b 00                	mov    (%eax),%eax
8010602d:	39 c2                	cmp    %eax,%edx
8010602f:	75 20                	jne    80106051 <sys_link+0x112>
80106031:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106034:	8b 40 04             	mov    0x4(%eax),%eax
80106037:	89 44 24 08          	mov    %eax,0x8(%esp)
8010603b:	8d 45 e2             	lea    -0x1e(%ebp),%eax
8010603e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106042:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106045:	89 04 24             	mov    %eax,(%esp)
80106048:	e8 4b c2 ff ff       	call   80102298 <dirlink>
8010604d:	85 c0                	test   %eax,%eax
8010604f:	79 0d                	jns    8010605e <sys_link+0x11f>
    iunlockput(dp);
80106051:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106054:	89 04 24             	mov    %eax,(%esp)
80106057:	e8 c9 bb ff ff       	call   80101c25 <iunlockput>
    goto bad;
8010605c:	eb 22                	jmp    80106080 <sys_link+0x141>
  }
  iunlockput(dp);
8010605e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106061:	89 04 24             	mov    %eax,(%esp)
80106064:	e8 bc bb ff ff       	call   80101c25 <iunlockput>
  iput(ip);
80106069:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010606c:	89 04 24             	mov    %eax,(%esp)
8010606f:	e8 00 bb ff ff       	call   80101b74 <iput>

  end_op();
80106074:	e8 6c d5 ff ff       	call   801035e5 <end_op>

  return 0;
80106079:	b8 00 00 00 00       	mov    $0x0,%eax
8010607e:	eb 3a                	jmp    801060ba <sys_link+0x17b>

bad:
  ilock(ip);
80106080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106083:	89 04 24             	mov    %eax,(%esp)
80106086:	e8 9b b9 ff ff       	call   80101a26 <ilock>
  ip->nlink--;
8010608b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010608e:	66 8b 40 56          	mov    0x56(%eax),%ax
80106092:	48                   	dec    %eax
80106093:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106096:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
8010609a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010609d:	89 04 24             	mov    %eax,(%esp)
801060a0:	e8 be b7 ff ff       	call   80101863 <iupdate>
  iunlockput(ip);
801060a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060a8:	89 04 24             	mov    %eax,(%esp)
801060ab:	e8 75 bb ff ff       	call   80101c25 <iunlockput>
  end_op();
801060b0:	e8 30 d5 ff ff       	call   801035e5 <end_op>
  return -1;
801060b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060ba:	c9                   	leave  
801060bb:	c3                   	ret    

801060bc <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801060bc:	55                   	push   %ebp
801060bd:	89 e5                	mov    %esp,%ebp
801060bf:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801060c2:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
801060c9:	eb 4a                	jmp    80106115 <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801060cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060ce:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801060d5:	00 
801060d6:	89 44 24 08          	mov    %eax,0x8(%esp)
801060da:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801060dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801060e1:	8b 45 08             	mov    0x8(%ebp),%eax
801060e4:	89 04 24             	mov    %eax,(%esp)
801060e7:	e8 d1 bd ff ff       	call   80101ebd <readi>
801060ec:	83 f8 10             	cmp    $0x10,%eax
801060ef:	74 0c                	je     801060fd <isdirempty+0x41>
      panic("isdirempty: readi");
801060f1:	c7 04 24 c0 93 10 80 	movl   $0x801093c0,(%esp)
801060f8:	e8 57 a4 ff ff       	call   80100554 <panic>
    if(de.inum != 0)
801060fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106100:	66 85 c0             	test   %ax,%ax
80106103:	74 07                	je     8010610c <isdirempty+0x50>
      return 0;
80106105:	b8 00 00 00 00       	mov    $0x0,%eax
8010610a:	eb 1b                	jmp    80106127 <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010610c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010610f:	83 c0 10             	add    $0x10,%eax
80106112:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106115:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106118:	8b 45 08             	mov    0x8(%ebp),%eax
8010611b:	8b 40 58             	mov    0x58(%eax),%eax
8010611e:	39 c2                	cmp    %eax,%edx
80106120:	72 a9                	jb     801060cb <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106122:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106127:	c9                   	leave  
80106128:	c3                   	ret    

80106129 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80106129:	55                   	push   %ebp
8010612a:	89 e5                	mov    %esp,%ebp
8010612c:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010612f:	8d 45 cc             	lea    -0x34(%ebp),%eax
80106132:	89 44 24 04          	mov    %eax,0x4(%esp)
80106136:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010613d:	e8 7e fa ff ff       	call   80105bc0 <argstr>
80106142:	85 c0                	test   %eax,%eax
80106144:	79 0a                	jns    80106150 <sys_unlink+0x27>
    return -1;
80106146:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010614b:	e9 a9 01 00 00       	jmp    801062f9 <sys_unlink+0x1d0>

  begin_op();
80106150:	e8 0e d4 ff ff       	call   80103563 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106155:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106158:	8d 55 d2             	lea    -0x2e(%ebp),%edx
8010615b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010615f:	89 04 24             	mov    %eax,(%esp)
80106162:	e8 4b c4 ff ff       	call   801025b2 <nameiparent>
80106167:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010616a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010616e:	75 0f                	jne    8010617f <sys_unlink+0x56>
    end_op();
80106170:	e8 70 d4 ff ff       	call   801035e5 <end_op>
    return -1;
80106175:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010617a:	e9 7a 01 00 00       	jmp    801062f9 <sys_unlink+0x1d0>
  }

  ilock(dp);
8010617f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106182:	89 04 24             	mov    %eax,(%esp)
80106185:	e8 9c b8 ff ff       	call   80101a26 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010618a:	c7 44 24 04 d2 93 10 	movl   $0x801093d2,0x4(%esp)
80106191:	80 
80106192:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106195:	89 04 24             	mov    %eax,(%esp)
80106198:	e8 13 c0 ff ff       	call   801021b0 <namecmp>
8010619d:	85 c0                	test   %eax,%eax
8010619f:	0f 84 3f 01 00 00    	je     801062e4 <sys_unlink+0x1bb>
801061a5:	c7 44 24 04 d4 93 10 	movl   $0x801093d4,0x4(%esp)
801061ac:	80 
801061ad:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801061b0:	89 04 24             	mov    %eax,(%esp)
801061b3:	e8 f8 bf ff ff       	call   801021b0 <namecmp>
801061b8:	85 c0                	test   %eax,%eax
801061ba:	0f 84 24 01 00 00    	je     801062e4 <sys_unlink+0x1bb>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801061c0:	8d 45 c8             	lea    -0x38(%ebp),%eax
801061c3:	89 44 24 08          	mov    %eax,0x8(%esp)
801061c7:	8d 45 d2             	lea    -0x2e(%ebp),%eax
801061ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801061ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061d1:	89 04 24             	mov    %eax,(%esp)
801061d4:	e8 f9 bf ff ff       	call   801021d2 <dirlookup>
801061d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061dc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061e0:	75 05                	jne    801061e7 <sys_unlink+0xbe>
    goto bad;
801061e2:	e9 fd 00 00 00       	jmp    801062e4 <sys_unlink+0x1bb>
  ilock(ip);
801061e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ea:	89 04 24             	mov    %eax,(%esp)
801061ed:	e8 34 b8 ff ff       	call   80101a26 <ilock>

  if(ip->nlink < 1)
801061f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f5:	66 8b 40 56          	mov    0x56(%eax),%ax
801061f9:	66 85 c0             	test   %ax,%ax
801061fc:	7f 0c                	jg     8010620a <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
801061fe:	c7 04 24 d7 93 10 80 	movl   $0x801093d7,(%esp)
80106205:	e8 4a a3 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010620a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010620d:	8b 40 50             	mov    0x50(%eax),%eax
80106210:	66 83 f8 01          	cmp    $0x1,%ax
80106214:	75 1f                	jne    80106235 <sys_unlink+0x10c>
80106216:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106219:	89 04 24             	mov    %eax,(%esp)
8010621c:	e8 9b fe ff ff       	call   801060bc <isdirempty>
80106221:	85 c0                	test   %eax,%eax
80106223:	75 10                	jne    80106235 <sys_unlink+0x10c>
    iunlockput(ip);
80106225:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106228:	89 04 24             	mov    %eax,(%esp)
8010622b:	e8 f5 b9 ff ff       	call   80101c25 <iunlockput>
    goto bad;
80106230:	e9 af 00 00 00       	jmp    801062e4 <sys_unlink+0x1bb>
  }

  memset(&de, 0, sizeof(de));
80106235:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010623c:	00 
8010623d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106244:	00 
80106245:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106248:	89 04 24             	mov    %eax,(%esp)
8010624b:	e8 a6 f5 ff ff       	call   801057f6 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106250:	8b 45 c8             	mov    -0x38(%ebp),%eax
80106253:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010625a:	00 
8010625b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010625f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106262:	89 44 24 04          	mov    %eax,0x4(%esp)
80106266:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106269:	89 04 24             	mov    %eax,(%esp)
8010626c:	e8 b0 bd ff ff       	call   80102021 <writei>
80106271:	83 f8 10             	cmp    $0x10,%eax
80106274:	74 0c                	je     80106282 <sys_unlink+0x159>
    panic("unlink: writei");
80106276:	c7 04 24 e9 93 10 80 	movl   $0x801093e9,(%esp)
8010627d:	e8 d2 a2 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR){
80106282:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106285:	8b 40 50             	mov    0x50(%eax),%eax
80106288:	66 83 f8 01          	cmp    $0x1,%ax
8010628c:	75 1a                	jne    801062a8 <sys_unlink+0x17f>
    dp->nlink--;
8010628e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106291:	66 8b 40 56          	mov    0x56(%eax),%ax
80106295:	48                   	dec    %eax
80106296:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106299:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
8010629d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a0:	89 04 24             	mov    %eax,(%esp)
801062a3:	e8 bb b5 ff ff       	call   80101863 <iupdate>
  }
  iunlockput(dp);
801062a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ab:	89 04 24             	mov    %eax,(%esp)
801062ae:	e8 72 b9 ff ff       	call   80101c25 <iunlockput>

  ip->nlink--;
801062b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062b6:	66 8b 40 56          	mov    0x56(%eax),%ax
801062ba:	48                   	dec    %eax
801062bb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062be:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
801062c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062c5:	89 04 24             	mov    %eax,(%esp)
801062c8:	e8 96 b5 ff ff       	call   80101863 <iupdate>
  iunlockput(ip);
801062cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062d0:	89 04 24             	mov    %eax,(%esp)
801062d3:	e8 4d b9 ff ff       	call   80101c25 <iunlockput>

  end_op();
801062d8:	e8 08 d3 ff ff       	call   801035e5 <end_op>

  return 0;
801062dd:	b8 00 00 00 00       	mov    $0x0,%eax
801062e2:	eb 15                	jmp    801062f9 <sys_unlink+0x1d0>

bad:
  iunlockput(dp);
801062e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e7:	89 04 24             	mov    %eax,(%esp)
801062ea:	e8 36 b9 ff ff       	call   80101c25 <iunlockput>
  end_op();
801062ef:	e8 f1 d2 ff ff       	call   801035e5 <end_op>
  return -1;
801062f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801062f9:	c9                   	leave  
801062fa:	c3                   	ret    

801062fb <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
801062fb:	55                   	push   %ebp
801062fc:	89 e5                	mov    %esp,%ebp
801062fe:	83 ec 48             	sub    $0x48,%esp
80106301:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106304:	8b 55 10             	mov    0x10(%ebp),%edx
80106307:	8b 45 14             	mov    0x14(%ebp),%eax
8010630a:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010630e:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106312:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106316:	8d 45 de             	lea    -0x22(%ebp),%eax
80106319:	89 44 24 04          	mov    %eax,0x4(%esp)
8010631d:	8b 45 08             	mov    0x8(%ebp),%eax
80106320:	89 04 24             	mov    %eax,(%esp)
80106323:	e8 8a c2 ff ff       	call   801025b2 <nameiparent>
80106328:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010632b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010632f:	75 0a                	jne    8010633b <create+0x40>
    return 0;
80106331:	b8 00 00 00 00       	mov    $0x0,%eax
80106336:	e9 79 01 00 00       	jmp    801064b4 <create+0x1b9>
  ilock(dp);
8010633b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010633e:	89 04 24             	mov    %eax,(%esp)
80106341:	e8 e0 b6 ff ff       	call   80101a26 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80106346:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106349:	89 44 24 08          	mov    %eax,0x8(%esp)
8010634d:	8d 45 de             	lea    -0x22(%ebp),%eax
80106350:	89 44 24 04          	mov    %eax,0x4(%esp)
80106354:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106357:	89 04 24             	mov    %eax,(%esp)
8010635a:	e8 73 be ff ff       	call   801021d2 <dirlookup>
8010635f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106362:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106366:	74 46                	je     801063ae <create+0xb3>
    iunlockput(dp);
80106368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010636b:	89 04 24             	mov    %eax,(%esp)
8010636e:	e8 b2 b8 ff ff       	call   80101c25 <iunlockput>
    ilock(ip);
80106373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106376:	89 04 24             	mov    %eax,(%esp)
80106379:	e8 a8 b6 ff ff       	call   80101a26 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
8010637e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106383:	75 14                	jne    80106399 <create+0x9e>
80106385:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106388:	8b 40 50             	mov    0x50(%eax),%eax
8010638b:	66 83 f8 02          	cmp    $0x2,%ax
8010638f:	75 08                	jne    80106399 <create+0x9e>
      return ip;
80106391:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106394:	e9 1b 01 00 00       	jmp    801064b4 <create+0x1b9>
    iunlockput(ip);
80106399:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010639c:	89 04 24             	mov    %eax,(%esp)
8010639f:	e8 81 b8 ff ff       	call   80101c25 <iunlockput>
    return 0;
801063a4:	b8 00 00 00 00       	mov    $0x0,%eax
801063a9:	e9 06 01 00 00       	jmp    801064b4 <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801063ae:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
801063b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063b5:	8b 00                	mov    (%eax),%eax
801063b7:	89 54 24 04          	mov    %edx,0x4(%esp)
801063bb:	89 04 24             	mov    %eax,(%esp)
801063be:	e8 ce b3 ff ff       	call   80101791 <ialloc>
801063c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063c6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063ca:	75 0c                	jne    801063d8 <create+0xdd>
    panic("create: ialloc");
801063cc:	c7 04 24 f8 93 10 80 	movl   $0x801093f8,(%esp)
801063d3:	e8 7c a1 ff ff       	call   80100554 <panic>

  ilock(ip);
801063d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063db:	89 04 24             	mov    %eax,(%esp)
801063de:	e8 43 b6 ff ff       	call   80101a26 <ilock>
  ip->major = major;
801063e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063e6:	8b 45 d0             	mov    -0x30(%ebp),%eax
801063e9:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
801063ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
801063f0:	8b 45 cc             	mov    -0x34(%ebp),%eax
801063f3:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
801063f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063fa:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80106400:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106403:	89 04 24             	mov    %eax,(%esp)
80106406:	e8 58 b4 ff ff       	call   80101863 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
8010640b:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106410:	75 68                	jne    8010647a <create+0x17f>
    dp->nlink++;  // for ".."
80106412:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106415:	66 8b 40 56          	mov    0x56(%eax),%ax
80106419:	40                   	inc    %eax
8010641a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010641d:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80106421:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106424:	89 04 24             	mov    %eax,(%esp)
80106427:	e8 37 b4 ff ff       	call   80101863 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010642c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010642f:	8b 40 04             	mov    0x4(%eax),%eax
80106432:	89 44 24 08          	mov    %eax,0x8(%esp)
80106436:	c7 44 24 04 d2 93 10 	movl   $0x801093d2,0x4(%esp)
8010643d:	80 
8010643e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106441:	89 04 24             	mov    %eax,(%esp)
80106444:	e8 4f be ff ff       	call   80102298 <dirlink>
80106449:	85 c0                	test   %eax,%eax
8010644b:	78 21                	js     8010646e <create+0x173>
8010644d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106450:	8b 40 04             	mov    0x4(%eax),%eax
80106453:	89 44 24 08          	mov    %eax,0x8(%esp)
80106457:	c7 44 24 04 d4 93 10 	movl   $0x801093d4,0x4(%esp)
8010645e:	80 
8010645f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106462:	89 04 24             	mov    %eax,(%esp)
80106465:	e8 2e be ff ff       	call   80102298 <dirlink>
8010646a:	85 c0                	test   %eax,%eax
8010646c:	79 0c                	jns    8010647a <create+0x17f>
      panic("create dots");
8010646e:	c7 04 24 07 94 10 80 	movl   $0x80109407,(%esp)
80106475:	e8 da a0 ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
8010647a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010647d:	8b 40 04             	mov    0x4(%eax),%eax
80106480:	89 44 24 08          	mov    %eax,0x8(%esp)
80106484:	8d 45 de             	lea    -0x22(%ebp),%eax
80106487:	89 44 24 04          	mov    %eax,0x4(%esp)
8010648b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010648e:	89 04 24             	mov    %eax,(%esp)
80106491:	e8 02 be ff ff       	call   80102298 <dirlink>
80106496:	85 c0                	test   %eax,%eax
80106498:	79 0c                	jns    801064a6 <create+0x1ab>
    panic("create: dirlink");
8010649a:	c7 04 24 13 94 10 80 	movl   $0x80109413,(%esp)
801064a1:	e8 ae a0 ff ff       	call   80100554 <panic>

  iunlockput(dp);
801064a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064a9:	89 04 24             	mov    %eax,(%esp)
801064ac:	e8 74 b7 ff ff       	call   80101c25 <iunlockput>

  return ip;
801064b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801064b4:	c9                   	leave  
801064b5:	c3                   	ret    

801064b6 <sys_open>:

int
sys_open(void)
{
801064b6:	55                   	push   %ebp
801064b7:	89 e5                	mov    %esp,%ebp
801064b9:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801064bc:	8d 45 e8             	lea    -0x18(%ebp),%eax
801064bf:	89 44 24 04          	mov    %eax,0x4(%esp)
801064c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064ca:	e8 f1 f6 ff ff       	call   80105bc0 <argstr>
801064cf:	85 c0                	test   %eax,%eax
801064d1:	78 17                	js     801064ea <sys_open+0x34>
801064d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801064d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801064da:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801064e1:	e8 43 f6 ff ff       	call   80105b29 <argint>
801064e6:	85 c0                	test   %eax,%eax
801064e8:	79 0a                	jns    801064f4 <sys_open+0x3e>
    return -1;
801064ea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ef:	e9 5b 01 00 00       	jmp    8010664f <sys_open+0x199>

  begin_op();
801064f4:	e8 6a d0 ff ff       	call   80103563 <begin_op>

  if(omode & O_CREATE){
801064f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064fc:	25 00 02 00 00       	and    $0x200,%eax
80106501:	85 c0                	test   %eax,%eax
80106503:	74 3b                	je     80106540 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80106505:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106508:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010650f:	00 
80106510:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106517:	00 
80106518:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
8010651f:	00 
80106520:	89 04 24             	mov    %eax,(%esp)
80106523:	e8 d3 fd ff ff       	call   801062fb <create>
80106528:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010652b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010652f:	75 6a                	jne    8010659b <sys_open+0xe5>
      end_op();
80106531:	e8 af d0 ff ff       	call   801035e5 <end_op>
      return -1;
80106536:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010653b:	e9 0f 01 00 00       	jmp    8010664f <sys_open+0x199>
    }
  } else {
    if((ip = namei(path)) == 0){
80106540:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106543:	89 04 24             	mov    %eax,(%esp)
80106546:	e8 45 c0 ff ff       	call   80102590 <namei>
8010654b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010654e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106552:	75 0f                	jne    80106563 <sys_open+0xad>
      end_op();
80106554:	e8 8c d0 ff ff       	call   801035e5 <end_op>
      return -1;
80106559:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010655e:	e9 ec 00 00 00       	jmp    8010664f <sys_open+0x199>
    }
    ilock(ip);
80106563:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106566:	89 04 24             	mov    %eax,(%esp)
80106569:	e8 b8 b4 ff ff       	call   80101a26 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
8010656e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106571:	8b 40 50             	mov    0x50(%eax),%eax
80106574:	66 83 f8 01          	cmp    $0x1,%ax
80106578:	75 21                	jne    8010659b <sys_open+0xe5>
8010657a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010657d:	85 c0                	test   %eax,%eax
8010657f:	74 1a                	je     8010659b <sys_open+0xe5>
      iunlockput(ip);
80106581:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106584:	89 04 24             	mov    %eax,(%esp)
80106587:	e8 99 b6 ff ff       	call   80101c25 <iunlockput>
      end_op();
8010658c:	e8 54 d0 ff ff       	call   801035e5 <end_op>
      return -1;
80106591:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106596:	e9 b4 00 00 00       	jmp    8010664f <sys_open+0x199>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010659b:	e8 c4 aa ff ff       	call   80101064 <filealloc>
801065a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065a7:	74 14                	je     801065bd <sys_open+0x107>
801065a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065ac:	89 04 24             	mov    %eax,(%esp)
801065af:	e8 40 f7 ff ff       	call   80105cf4 <fdalloc>
801065b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801065b7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801065bb:	79 28                	jns    801065e5 <sys_open+0x12f>
    if(f)
801065bd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065c1:	74 0b                	je     801065ce <sys_open+0x118>
      fileclose(f);
801065c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065c6:	89 04 24             	mov    %eax,(%esp)
801065c9:	e8 3e ab ff ff       	call   8010110c <fileclose>
    iunlockput(ip);
801065ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d1:	89 04 24             	mov    %eax,(%esp)
801065d4:	e8 4c b6 ff ff       	call   80101c25 <iunlockput>
    end_op();
801065d9:	e8 07 d0 ff ff       	call   801035e5 <end_op>
    return -1;
801065de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065e3:	eb 6a                	jmp    8010664f <sys_open+0x199>
  }
  iunlock(ip);
801065e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065e8:	89 04 24             	mov    %eax,(%esp)
801065eb:	e8 40 b5 ff ff       	call   80101b30 <iunlock>
  end_op();
801065f0:	e8 f0 cf ff ff       	call   801035e5 <end_op>

  f->type = FD_INODE;
801065f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065f8:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801065fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106601:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106604:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106607:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010660a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106611:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106614:	83 e0 01             	and    $0x1,%eax
80106617:	85 c0                	test   %eax,%eax
80106619:	0f 94 c0             	sete   %al
8010661c:	88 c2                	mov    %al,%dl
8010661e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106621:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106624:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106627:	83 e0 01             	and    $0x1,%eax
8010662a:	85 c0                	test   %eax,%eax
8010662c:	75 0a                	jne    80106638 <sys_open+0x182>
8010662e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106631:	83 e0 02             	and    $0x2,%eax
80106634:	85 c0                	test   %eax,%eax
80106636:	74 07                	je     8010663f <sys_open+0x189>
80106638:	b8 01 00 00 00       	mov    $0x1,%eax
8010663d:	eb 05                	jmp    80106644 <sys_open+0x18e>
8010663f:	b8 00 00 00 00       	mov    $0x0,%eax
80106644:	88 c2                	mov    %al,%dl
80106646:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106649:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010664c:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010664f:	c9                   	leave  
80106650:	c3                   	ret    

80106651 <sys_mkdir>:

int
sys_mkdir(void)
{
80106651:	55                   	push   %ebp
80106652:	89 e5                	mov    %esp,%ebp
80106654:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106657:	e8 07 cf ff ff       	call   80103563 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010665c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010665f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106663:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010666a:	e8 51 f5 ff ff       	call   80105bc0 <argstr>
8010666f:	85 c0                	test   %eax,%eax
80106671:	78 2c                	js     8010669f <sys_mkdir+0x4e>
80106673:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106676:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010667d:	00 
8010667e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106685:	00 
80106686:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010668d:	00 
8010668e:	89 04 24             	mov    %eax,(%esp)
80106691:	e8 65 fc ff ff       	call   801062fb <create>
80106696:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106699:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010669d:	75 0c                	jne    801066ab <sys_mkdir+0x5a>
    end_op();
8010669f:	e8 41 cf ff ff       	call   801035e5 <end_op>
    return -1;
801066a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066a9:	eb 15                	jmp    801066c0 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
801066ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ae:	89 04 24             	mov    %eax,(%esp)
801066b1:	e8 6f b5 ff ff       	call   80101c25 <iunlockput>
  end_op();
801066b6:	e8 2a cf ff ff       	call   801035e5 <end_op>
  return 0;
801066bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066c0:	c9                   	leave  
801066c1:	c3                   	ret    

801066c2 <sys_mknod>:

int
sys_mknod(void)
{
801066c2:	55                   	push   %ebp
801066c3:	89 e5                	mov    %esp,%ebp
801066c5:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801066c8:	e8 96 ce ff ff       	call   80103563 <begin_op>
  if((argstr(0, &path)) < 0 ||
801066cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801066d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801066db:	e8 e0 f4 ff ff       	call   80105bc0 <argstr>
801066e0:	85 c0                	test   %eax,%eax
801066e2:	78 5e                	js     80106742 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
801066e4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801066eb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801066f2:	e8 32 f4 ff ff       	call   80105b29 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
801066f7:	85 c0                	test   %eax,%eax
801066f9:	78 47                	js     80106742 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801066fb:	8d 45 e8             	lea    -0x18(%ebp),%eax
801066fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80106702:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106709:	e8 1b f4 ff ff       	call   80105b29 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
8010670e:	85 c0                	test   %eax,%eax
80106710:	78 30                	js     80106742 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106712:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106715:	0f bf c8             	movswl %ax,%ecx
80106718:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010671b:	0f bf d0             	movswl %ax,%edx
8010671e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106721:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106725:	89 54 24 08          	mov    %edx,0x8(%esp)
80106729:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106730:	00 
80106731:	89 04 24             	mov    %eax,(%esp)
80106734:	e8 c2 fb ff ff       	call   801062fb <create>
80106739:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010673c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106740:	75 0c                	jne    8010674e <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106742:	e8 9e ce ff ff       	call   801035e5 <end_op>
    return -1;
80106747:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010674c:	eb 15                	jmp    80106763 <sys_mknod+0xa1>
  }
  iunlockput(ip);
8010674e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106751:	89 04 24             	mov    %eax,(%esp)
80106754:	e8 cc b4 ff ff       	call   80101c25 <iunlockput>
  end_op();
80106759:	e8 87 ce ff ff       	call   801035e5 <end_op>
  return 0;
8010675e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106763:	c9                   	leave  
80106764:	c3                   	ret    

80106765 <sys_chdir>:

int
sys_chdir(void)
{
80106765:	55                   	push   %ebp
80106766:	89 e5                	mov    %esp,%ebp
80106768:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
8010676b:	e8 f0 d9 ff ff       	call   80104160 <myproc>
80106770:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106773:	e8 eb cd ff ff       	call   80103563 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106778:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010677b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010677f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106786:	e8 35 f4 ff ff       	call   80105bc0 <argstr>
8010678b:	85 c0                	test   %eax,%eax
8010678d:	78 14                	js     801067a3 <sys_chdir+0x3e>
8010678f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106792:	89 04 24             	mov    %eax,(%esp)
80106795:	e8 f6 bd ff ff       	call   80102590 <namei>
8010679a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010679d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067a1:	75 18                	jne    801067bb <sys_chdir+0x56>
    cprintf("cant pick up path\n");
801067a3:	c7 04 24 23 94 10 80 	movl   $0x80109423,(%esp)
801067aa:	e8 12 9c ff ff       	call   801003c1 <cprintf>
    end_op();
801067af:	e8 31 ce ff ff       	call   801035e5 <end_op>
    return -1;
801067b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067b9:	eb 66                	jmp    80106821 <sys_chdir+0xbc>
  }
  ilock(ip);
801067bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067be:	89 04 24             	mov    %eax,(%esp)
801067c1:	e8 60 b2 ff ff       	call   80101a26 <ilock>
  if(ip->type != T_DIR){
801067c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067c9:	8b 40 50             	mov    0x50(%eax),%eax
801067cc:	66 83 f8 01          	cmp    $0x1,%ax
801067d0:	74 23                	je     801067f5 <sys_chdir+0x90>
    // TODO: REMOVE
    cprintf("not a dir\n");
801067d2:	c7 04 24 36 94 10 80 	movl   $0x80109436,(%esp)
801067d9:	e8 e3 9b ff ff       	call   801003c1 <cprintf>
    iunlockput(ip);
801067de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067e1:	89 04 24             	mov    %eax,(%esp)
801067e4:	e8 3c b4 ff ff       	call   80101c25 <iunlockput>
    end_op();
801067e9:	e8 f7 cd ff ff       	call   801035e5 <end_op>
    return -1;
801067ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067f3:	eb 2c                	jmp    80106821 <sys_chdir+0xbc>
  }
  iunlock(ip);
801067f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067f8:	89 04 24             	mov    %eax,(%esp)
801067fb:	e8 30 b3 ff ff       	call   80101b30 <iunlock>
  iput(curproc->cwd);
80106800:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106803:	8b 40 68             	mov    0x68(%eax),%eax
80106806:	89 04 24             	mov    %eax,(%esp)
80106809:	e8 66 b3 ff ff       	call   80101b74 <iput>
  end_op();
8010680e:	e8 d2 cd ff ff       	call   801035e5 <end_op>
  curproc->cwd = ip;
80106813:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106816:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106819:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
8010681c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106821:	c9                   	leave  
80106822:	c3                   	ret    

80106823 <sys_exec>:

int
sys_exec(void)
{
80106823:	55                   	push   %ebp
80106824:	89 e5                	mov    %esp,%ebp
80106826:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010682c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010682f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106833:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010683a:	e8 81 f3 ff ff       	call   80105bc0 <argstr>
8010683f:	85 c0                	test   %eax,%eax
80106841:	78 1a                	js     8010685d <sys_exec+0x3a>
80106843:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106849:	89 44 24 04          	mov    %eax,0x4(%esp)
8010684d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106854:	e8 d0 f2 ff ff       	call   80105b29 <argint>
80106859:	85 c0                	test   %eax,%eax
8010685b:	79 0a                	jns    80106867 <sys_exec+0x44>
    return -1;
8010685d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106862:	e9 c7 00 00 00       	jmp    8010692e <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
80106867:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010686e:	00 
8010686f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106876:	00 
80106877:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
8010687d:	89 04 24             	mov    %eax,(%esp)
80106880:	e8 71 ef ff ff       	call   801057f6 <memset>
  for(i=0;; i++){
80106885:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
8010688c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010688f:	83 f8 1f             	cmp    $0x1f,%eax
80106892:	76 0a                	jbe    8010689e <sys_exec+0x7b>
      return -1;
80106894:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106899:	e9 90 00 00 00       	jmp    8010692e <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010689e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068a1:	c1 e0 02             	shl    $0x2,%eax
801068a4:	89 c2                	mov    %eax,%edx
801068a6:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
801068ac:	01 c2                	add    %eax,%edx
801068ae:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
801068b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801068b8:	89 14 24             	mov    %edx,(%esp)
801068bb:	e8 c8 f1 ff ff       	call   80105a88 <fetchint>
801068c0:	85 c0                	test   %eax,%eax
801068c2:	79 07                	jns    801068cb <sys_exec+0xa8>
      return -1;
801068c4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068c9:	eb 63                	jmp    8010692e <sys_exec+0x10b>
    if(uarg == 0){
801068cb:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801068d1:	85 c0                	test   %eax,%eax
801068d3:	75 26                	jne    801068fb <sys_exec+0xd8>
      argv[i] = 0;
801068d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068d8:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801068df:	00 00 00 00 
      break;
801068e3:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801068e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068e7:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801068ed:	89 54 24 04          	mov    %edx,0x4(%esp)
801068f1:	89 04 24             	mov    %eax,(%esp)
801068f4:	e8 0f a3 ff ff       	call   80100c08 <exec>
801068f9:	eb 33                	jmp    8010692e <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801068fb:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106901:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106904:	c1 e2 02             	shl    $0x2,%edx
80106907:	01 c2                	add    %eax,%edx
80106909:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010690f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106913:	89 04 24             	mov    %eax,(%esp)
80106916:	e8 ac f1 ff ff       	call   80105ac7 <fetchstr>
8010691b:	85 c0                	test   %eax,%eax
8010691d:	79 07                	jns    80106926 <sys_exec+0x103>
      return -1;
8010691f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106924:	eb 08                	jmp    8010692e <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106926:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106929:	e9 5e ff ff ff       	jmp    8010688c <sys_exec+0x69>
  return exec(path, argv);
}
8010692e:	c9                   	leave  
8010692f:	c3                   	ret    

80106930 <sys_pipe>:

int
sys_pipe(void)
{
80106930:	55                   	push   %ebp
80106931:	89 e5                	mov    %esp,%ebp
80106933:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106936:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
8010693d:	00 
8010693e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106941:	89 44 24 04          	mov    %eax,0x4(%esp)
80106945:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010694c:	e8 05 f2 ff ff       	call   80105b56 <argptr>
80106951:	85 c0                	test   %eax,%eax
80106953:	79 0a                	jns    8010695f <sys_pipe+0x2f>
    return -1;
80106955:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010695a:	e9 9a 00 00 00       	jmp    801069f9 <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
8010695f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106962:	89 44 24 04          	mov    %eax,0x4(%esp)
80106966:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106969:	89 04 24             	mov    %eax,(%esp)
8010696c:	e8 3f d4 ff ff       	call   80103db0 <pipealloc>
80106971:	85 c0                	test   %eax,%eax
80106973:	79 07                	jns    8010697c <sys_pipe+0x4c>
    return -1;
80106975:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010697a:	eb 7d                	jmp    801069f9 <sys_pipe+0xc9>
  fd0 = -1;
8010697c:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106983:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106986:	89 04 24             	mov    %eax,(%esp)
80106989:	e8 66 f3 ff ff       	call   80105cf4 <fdalloc>
8010698e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106991:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106995:	78 14                	js     801069ab <sys_pipe+0x7b>
80106997:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010699a:	89 04 24             	mov    %eax,(%esp)
8010699d:	e8 52 f3 ff ff       	call   80105cf4 <fdalloc>
801069a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
801069a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801069a9:	79 36                	jns    801069e1 <sys_pipe+0xb1>
    if(fd0 >= 0)
801069ab:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801069af:	78 13                	js     801069c4 <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
801069b1:	e8 aa d7 ff ff       	call   80104160 <myproc>
801069b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069b9:	83 c2 08             	add    $0x8,%edx
801069bc:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801069c3:	00 
    fileclose(rf);
801069c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801069c7:	89 04 24             	mov    %eax,(%esp)
801069ca:	e8 3d a7 ff ff       	call   8010110c <fileclose>
    fileclose(wf);
801069cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069d2:	89 04 24             	mov    %eax,(%esp)
801069d5:	e8 32 a7 ff ff       	call   8010110c <fileclose>
    return -1;
801069da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069df:	eb 18                	jmp    801069f9 <sys_pipe+0xc9>
  }
  fd[0] = fd0;
801069e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801069e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069e7:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801069e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801069ec:	8d 50 04             	lea    0x4(%eax),%edx
801069ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069f2:	89 02                	mov    %eax,(%edx)
  return 0;
801069f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069f9:	c9                   	leave  
801069fa:	c3                   	ret    

801069fb <sys_ccreate>:

int
sys_ccreate(void)
{
801069fb:	55                   	push   %ebp
801069fc:	89 e5                	mov    %esp,%ebp
801069fe:	56                   	push   %esi
801069ff:	53                   	push   %ebx
80106a00:	81 ec c0 00 00 00    	sub    $0xc0,%esp

  char *name, *argv[MAXARG];
  int i, progc, mproc;
  uint uargv, uarg, msz, mdsk;

  if(argstr(0, &name) < 0 || argint(2, &progc) < 0 || argint(3, &mproc) < 0 
80106a06:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a09:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a0d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a14:	e8 a7 f1 ff ff       	call   80105bc0 <argstr>
80106a19:	85 c0                	test   %eax,%eax
80106a1b:	78 68                	js     80106a85 <sys_ccreate+0x8a>
80106a1d:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106a23:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a27:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106a2e:	e8 f6 f0 ff ff       	call   80105b29 <argint>
80106a33:	85 c0                	test   %eax,%eax
80106a35:	78 4e                	js     80106a85 <sys_ccreate+0x8a>
80106a37:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106a3d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a41:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
80106a48:	e8 dc f0 ff ff       	call   80105b29 <argint>
80106a4d:	85 c0                	test   %eax,%eax
80106a4f:	78 34                	js     80106a85 <sys_ccreate+0x8a>
    || argint(4, (int*)&msz) < 0 || argint(5, (int*)&mdsk) < 0) {
80106a51:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
80106a57:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a5b:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106a62:	e8 c2 f0 ff ff       	call   80105b29 <argint>
80106a67:	85 c0                	test   %eax,%eax
80106a69:	78 1a                	js     80106a85 <sys_ccreate+0x8a>
80106a6b:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80106a71:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a75:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
80106a7c:	e8 a8 f0 ff ff       	call   80105b29 <argint>
80106a81:	85 c0                	test   %eax,%eax
80106a83:	79 16                	jns    80106a9b <sys_ccreate+0xa0>
    cprintf("sys_ccreate: Error getting pointers\n");
80106a85:	c7 04 24 44 94 10 80 	movl   $0x80109444,(%esp)
80106a8c:	e8 30 99 ff ff       	call   801003c1 <cprintf>
    return -1;
80106a91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a96:	e9 80 01 00 00       	jmp    80106c1b <sys_ccreate+0x220>
  }

  if(argint(1, (int*)&uargv) < 0){
80106a9b:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
80106aa1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106aa5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106aac:	e8 78 f0 ff ff       	call   80105b29 <argint>
80106ab1:	85 c0                	test   %eax,%eax
80106ab3:	79 0a                	jns    80106abf <sys_ccreate+0xc4>
    return -1;
80106ab5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aba:	e9 5c 01 00 00       	jmp    80106c1b <sys_ccreate+0x220>
  }
  memset(argv, 0, sizeof(argv));
80106abf:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106ac6:	00 
80106ac7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106ace:	00 
80106acf:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106ad5:	89 04 24             	mov    %eax,(%esp)
80106ad8:	e8 19 ed ff ff       	call   801057f6 <memset>
  for(i=0;; i++){
80106add:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ae7:	83 f8 1f             	cmp    $0x1f,%eax
80106aea:	76 0a                	jbe    80106af6 <sys_ccreate+0xfb>
      return -1;
80106aec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106af1:	e9 25 01 00 00       	jmp    80106c1b <sys_ccreate+0x220>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106af9:	c1 e0 02             	shl    $0x2,%eax
80106afc:	89 c2                	mov    %eax,%edx
80106afe:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80106b04:	01 c2                	add    %eax,%edx
80106b06:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
80106b0c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b10:	89 14 24             	mov    %edx,(%esp)
80106b13:	e8 70 ef ff ff       	call   80105a88 <fetchint>
80106b18:	85 c0                	test   %eax,%eax
80106b1a:	79 0a                	jns    80106b26 <sys_ccreate+0x12b>
      return -1;
80106b1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b21:	e9 f5 00 00 00       	jmp    80106c1b <sys_ccreate+0x220>
    if(uarg == 0){
80106b26:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80106b2c:	85 c0                	test   %eax,%eax
80106b2e:	75 53                	jne    80106b83 <sys_ccreate+0x188>
      argv[i] = 0;
80106b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b33:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106b3a:	00 00 00 00 
      break;
80106b3e:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_create\nuargv: %d\nname: %s\nmproc: %d\nmsz: %d\nmdsk: %d\n", uargv, name, mproc, msz, mdsk);
80106b3f:	8b b5 58 ff ff ff    	mov    -0xa8(%ebp),%esi
80106b45:	8b 9d 5c ff ff ff    	mov    -0xa4(%ebp),%ebx
80106b4b:	8b 8d 68 ff ff ff    	mov    -0x98(%ebp),%ecx
80106b51:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106b54:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80106b5a:	89 74 24 14          	mov    %esi,0x14(%esp)
80106b5e:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106b62:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106b66:	89 54 24 08          	mov    %edx,0x8(%esp)
80106b6a:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b6e:	c7 04 24 6c 94 10 80 	movl   $0x8010946c,(%esp)
80106b75:	e8 47 98 ff ff       	call   801003c1 <cprintf>
  for (i = 0; i < progc; i++) 
80106b7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106b81:	eb 50                	jmp    80106bd3 <sys_ccreate+0x1d8>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106b83:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106b89:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106b8c:	c1 e2 02             	shl    $0x2,%edx
80106b8f:	01 c2                	add    %eax,%edx
80106b91:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80106b97:	89 54 24 04          	mov    %edx,0x4(%esp)
80106b9b:	89 04 24             	mov    %eax,(%esp)
80106b9e:	e8 24 ef ff ff       	call   80105ac7 <fetchstr>
80106ba3:	85 c0                	test   %eax,%eax
80106ba5:	79 07                	jns    80106bae <sys_ccreate+0x1b3>
      return -1;
80106ba7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bac:	eb 6d                	jmp    80106c1b <sys_ccreate+0x220>

  if(argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106bae:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106bb1:	e9 2e ff ff ff       	jmp    80106ae4 <sys_ccreate+0xe9>

  cprintf("sys_create\nuargv: %d\nname: %s\nmproc: %d\nmsz: %d\nmdsk: %d\n", uargv, name, mproc, msz, mdsk);
  for (i = 0; i < progc; i++) 
    cprintf("\t%s\n", argv[i]);
80106bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb9:	8b 84 85 70 ff ff ff 	mov    -0x90(%ebp,%eax,4),%eax
80106bc0:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bc4:	c7 04 24 a6 94 10 80 	movl   $0x801094a6,(%esp)
80106bcb:	e8 f1 97 ff ff       	call   801003c1 <cprintf>
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_create\nuargv: %d\nname: %s\nmproc: %d\nmsz: %d\nmdsk: %d\n", uargv, name, mproc, msz, mdsk);
  for (i = 0; i < progc; i++) 
80106bd0:	ff 45 f4             	incl   -0xc(%ebp)
80106bd3:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106bd9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80106bdc:	7c d8                	jl     80106bb6 <sys_ccreate+0x1bb>
    cprintf("\t%s\n", argv[i]);
  
  return ccreate(name, argv, progc, mproc, msz, mdsk);
80106bde:	8b b5 58 ff ff ff    	mov    -0xa8(%ebp),%esi
80106be4:	8b 9d 5c ff ff ff    	mov    -0xa4(%ebp),%ebx
80106bea:	8b 8d 68 ff ff ff    	mov    -0x98(%ebp),%ecx
80106bf0:	8b 95 6c ff ff ff    	mov    -0x94(%ebp),%edx
80106bf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bf9:	89 74 24 14          	mov    %esi,0x14(%esp)
80106bfd:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106c01:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106c05:	89 54 24 08          	mov    %edx,0x8(%esp)
80106c09:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106c0f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c13:	89 04 24             	mov    %eax,(%esp)
80106c16:	e8 be e5 ff ff       	call   801051d9 <ccreate>
}
80106c1b:	81 c4 c0 00 00 00    	add    $0xc0,%esp
80106c21:	5b                   	pop    %ebx
80106c22:	5e                   	pop    %esi
80106c23:	5d                   	pop    %ebp
80106c24:	c3                   	ret    

80106c25 <sys_cstart>:

int
sys_cstart(void)
{
80106c25:	55                   	push   %ebp
80106c26:	89 e5                	mov    %esp,%ebp
80106c28:	81 ec b8 00 00 00    	sub    $0xb8,%esp

  char *name, *prog, *argv[MAXARG];
  int i, argc;
  uint uargv, uarg;

  if(argstr(0, &name) < 0 || argstr(1, &prog) < 0 || argint(2, &argc) < 0) {
80106c2e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c31:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106c3c:	e8 7f ef ff ff       	call   80105bc0 <argstr>
80106c41:	85 c0                	test   %eax,%eax
80106c43:	78 31                	js     80106c76 <sys_cstart+0x51>
80106c45:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106c48:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c4c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106c53:	e8 68 ef ff ff       	call   80105bc0 <argstr>
80106c58:	85 c0                	test   %eax,%eax
80106c5a:	78 1a                	js     80106c76 <sys_cstart+0x51>
80106c5c:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106c62:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c66:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106c6d:	e8 b7 ee ff ff       	call   80105b29 <argint>
80106c72:	85 c0                	test   %eax,%eax
80106c74:	79 16                	jns    80106c8c <sys_cstart+0x67>
    cprintf("sys_ccreate: Error getting pointers\n");
80106c76:	c7 04 24 44 94 10 80 	movl   $0x80109444,(%esp)
80106c7d:	e8 3f 97 ff ff       	call   801003c1 <cprintf>
    return -1;
80106c82:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c87:	e9 4e 01 00 00       	jmp    80106dda <sys_cstart+0x1b5>
  }

  if(argint(1, (int*)&uargv) < 0){
80106c8c:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
80106c92:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106c9d:	e8 87 ee ff ff       	call   80105b29 <argint>
80106ca2:	85 c0                	test   %eax,%eax
80106ca4:	79 0a                	jns    80106cb0 <sys_cstart+0x8b>
    return -1;
80106ca6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cab:	e9 2a 01 00 00       	jmp    80106dda <sys_cstart+0x1b5>
  }
  memset(argv, 0, sizeof(argv));
80106cb0:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106cb7:	00 
80106cb8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106cbf:	00 
80106cc0:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106cc6:	89 04 24             	mov    %eax,(%esp)
80106cc9:	e8 28 eb ff ff       	call   801057f6 <memset>
  for(i=0;; i++){
80106cce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cd8:	83 f8 1f             	cmp    $0x1f,%eax
80106cdb:	76 0a                	jbe    80106ce7 <sys_cstart+0xc2>
      return -1;
80106cdd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ce2:	e9 f3 00 00 00       	jmp    80106dda <sys_cstart+0x1b5>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cea:	c1 e0 02             	shl    $0x2,%eax
80106ced:	89 c2                	mov    %eax,%edx
80106cef:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80106cf5:	01 c2                	add    %eax,%edx
80106cf7:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
80106cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d01:	89 14 24             	mov    %edx,(%esp)
80106d04:	e8 7f ed ff ff       	call   80105a88 <fetchint>
80106d09:	85 c0                	test   %eax,%eax
80106d0b:	79 0a                	jns    80106d17 <sys_cstart+0xf2>
      return -1;
80106d0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d12:	e9 c3 00 00 00       	jmp    80106dda <sys_cstart+0x1b5>
    if(uarg == 0){
80106d17:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80106d1d:	85 c0                	test   %eax,%eax
80106d1f:	75 3f                	jne    80106d60 <sys_cstart+0x13b>
      argv[i] = 0;
80106d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d24:	c7 84 85 6c ff ff ff 	movl   $0x0,-0x94(%ebp,%eax,4)
80106d2b:	00 00 00 00 
      break;
80106d2f:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_cstart\nuargv: %d\nname: %s\nargc: %d\n", uargv, name, argc);
80106d30:	8b 8d 68 ff ff ff    	mov    -0x98(%ebp),%ecx
80106d36:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106d39:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80106d3f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106d43:	89 54 24 08          	mov    %edx,0x8(%esp)
80106d47:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d4b:	c7 04 24 ac 94 10 80 	movl   $0x801094ac,(%esp)
80106d52:	e8 6a 96 ff ff       	call   801003c1 <cprintf>
  for (i = 0; i < argc; i++) 
80106d57:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106d5e:	eb 50                	jmp    80106db0 <sys_cstart+0x18b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106d60:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106d66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d69:	c1 e2 02             	shl    $0x2,%edx
80106d6c:	01 c2                	add    %eax,%edx
80106d6e:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80106d74:	89 54 24 04          	mov    %edx,0x4(%esp)
80106d78:	89 04 24             	mov    %eax,(%esp)
80106d7b:	e8 47 ed ff ff       	call   80105ac7 <fetchstr>
80106d80:	85 c0                	test   %eax,%eax
80106d82:	79 07                	jns    80106d8b <sys_cstart+0x166>
      return -1;
80106d84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d89:	eb 4f                	jmp    80106dda <sys_cstart+0x1b5>

  if(argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106d8b:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106d8e:	e9 42 ff ff ff       	jmp    80106cd5 <sys_cstart+0xb0>

  cprintf("sys_cstart\nuargv: %d\nname: %s\nargc: %d\n", uargv, name, argc);
  for (i = 0; i < argc; i++) 
    cprintf("\t%s\n", argv[i]);
80106d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d96:	8b 84 85 6c ff ff ff 	mov    -0x94(%ebp,%eax,4),%eax
80106d9d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106da1:	c7 04 24 a6 94 10 80 	movl   $0x801094a6,(%esp)
80106da8:	e8 14 96 ff ff       	call   801003c1 <cprintf>
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_cstart\nuargv: %d\nname: %s\nargc: %d\n", uargv, name, argc);
  for (i = 0; i < argc; i++) 
80106dad:	ff 45 f4             	incl   -0xc(%ebp)
80106db0:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106db6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80106db9:	7c d8                	jl     80106d93 <sys_cstart+0x16e>
    cprintf("\t%s\n", argv[i]);
  
  return cstart(name, argv, argc);
80106dbb:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
80106dc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106dc4:	89 54 24 08          	mov    %edx,0x8(%esp)
80106dc8:	8d 95 6c ff ff ff    	lea    -0x94(%ebp),%edx
80106dce:	89 54 24 04          	mov    %edx,0x4(%esp)
80106dd2:	89 04 24             	mov    %eax,(%esp)
80106dd5:	e8 42 e5 ff ff       	call   8010531c <cstart>
}
80106dda:	c9                   	leave  
80106ddb:	c3                   	ret    

80106ddc <sys_cstop>:

int
sys_cstop(void)
{
80106ddc:	55                   	push   %ebp
80106ddd:	89 e5                	mov    %esp,%ebp
  return 1;
80106ddf:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106de4:	5d                   	pop    %ebp
80106de5:	c3                   	ret    

80106de6 <sys_cinfo>:

int
sys_cinfo(void)
{
80106de6:	55                   	push   %ebp
80106de7:	89 e5                	mov    %esp,%ebp
  return 1;
80106de9:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106dee:	5d                   	pop    %ebp
80106def:	c3                   	ret    

80106df0 <sys_cpause>:

int
sys_cpause(void)
{
80106df0:	55                   	push   %ebp
80106df1:	89 e5                	mov    %esp,%ebp
  return 1;
80106df3:	b8 01 00 00 00       	mov    $0x1,%eax
80106df8:	5d                   	pop    %ebp
80106df9:	c3                   	ret    
	...

80106dfc <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106dfc:	55                   	push   %ebp
80106dfd:	89 e5                	mov    %esp,%ebp
80106dff:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106e02:	e8 8b d6 ff ff       	call   80104492 <fork>
}
80106e07:	c9                   	leave  
80106e08:	c3                   	ret    

80106e09 <sys_exit>:

int
sys_exit(void)
{
80106e09:	55                   	push   %ebp
80106e0a:	89 e5                	mov    %esp,%ebp
80106e0c:	83 ec 08             	sub    $0x8,%esp
  exit();
80106e0f:	e8 e2 d7 ff ff       	call   801045f6 <exit>
  return 0;  // not reached
80106e14:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e19:	c9                   	leave  
80106e1a:	c3                   	ret    

80106e1b <sys_wait>:

int
sys_wait(void)
{
80106e1b:	55                   	push   %ebp
80106e1c:	89 e5                	mov    %esp,%ebp
80106e1e:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106e21:	e8 00 d9 ff ff       	call   80104726 <wait>
}
80106e26:	c9                   	leave  
80106e27:	c3                   	ret    

80106e28 <sys_kill>:

int
sys_kill(void)
{
80106e28:	55                   	push   %ebp
80106e29:	89 e5                	mov    %esp,%ebp
80106e2b:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106e2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e31:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e35:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e3c:	e8 e8 ec ff ff       	call   80105b29 <argint>
80106e41:	85 c0                	test   %eax,%eax
80106e43:	79 07                	jns    80106e4c <sys_kill+0x24>
    return -1;
80106e45:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e4a:	eb 0b                	jmp    80106e57 <sys_kill+0x2f>
  return kill(pid);
80106e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e4f:	89 04 24             	mov    %eax,(%esp)
80106e52:	e8 58 db ff ff       	call   801049af <kill>
}
80106e57:	c9                   	leave  
80106e58:	c3                   	ret    

80106e59 <sys_getpid>:

int
sys_getpid(void)
{
80106e59:	55                   	push   %ebp
80106e5a:	89 e5                	mov    %esp,%ebp
80106e5c:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106e5f:	e8 fc d2 ff ff       	call   80104160 <myproc>
80106e64:	8b 40 10             	mov    0x10(%eax),%eax
}
80106e67:	c9                   	leave  
80106e68:	c3                   	ret    

80106e69 <sys_sbrk>:

int
sys_sbrk(void)
{
80106e69:	55                   	push   %ebp
80106e6a:	89 e5                	mov    %esp,%ebp
80106e6c:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106e6f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106e72:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e76:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106e7d:	e8 a7 ec ff ff       	call   80105b29 <argint>
80106e82:	85 c0                	test   %eax,%eax
80106e84:	79 07                	jns    80106e8d <sys_sbrk+0x24>
    return -1;
80106e86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e8b:	eb 23                	jmp    80106eb0 <sys_sbrk+0x47>
  addr = myproc()->sz;
80106e8d:	e8 ce d2 ff ff       	call   80104160 <myproc>
80106e92:	8b 00                	mov    (%eax),%eax
80106e94:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106e97:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106e9a:	89 04 24             	mov    %eax,(%esp)
80106e9d:	e8 52 d5 ff ff       	call   801043f4 <growproc>
80106ea2:	85 c0                	test   %eax,%eax
80106ea4:	79 07                	jns    80106ead <sys_sbrk+0x44>
    return -1;
80106ea6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106eab:	eb 03                	jmp    80106eb0 <sys_sbrk+0x47>
  return addr;
80106ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106eb0:	c9                   	leave  
80106eb1:	c3                   	ret    

80106eb2 <sys_sleep>:

int
sys_sleep(void)
{
80106eb2:	55                   	push   %ebp
80106eb3:	89 e5                	mov    %esp,%ebp
80106eb5:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106eb8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106ebb:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ebf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106ec6:	e8 5e ec ff ff       	call   80105b29 <argint>
80106ecb:	85 c0                	test   %eax,%eax
80106ecd:	79 07                	jns    80106ed6 <sys_sleep+0x24>
    return -1;
80106ecf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ed4:	eb 6b                	jmp    80106f41 <sys_sleep+0x8f>
  acquire(&tickslock);
80106ed6:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
80106edd:	e8 b1 e6 ff ff       	call   80105593 <acquire>
  ticks0 = ticks;
80106ee2:	a1 40 61 12 80       	mov    0x80126140,%eax
80106ee7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106eea:	eb 33                	jmp    80106f1f <sys_sleep+0x6d>
    if(myproc()->killed){
80106eec:	e8 6f d2 ff ff       	call   80104160 <myproc>
80106ef1:	8b 40 24             	mov    0x24(%eax),%eax
80106ef4:	85 c0                	test   %eax,%eax
80106ef6:	74 13                	je     80106f0b <sys_sleep+0x59>
      release(&tickslock);
80106ef8:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
80106eff:	e8 f9 e6 ff ff       	call   801055fd <release>
      return -1;
80106f04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f09:	eb 36                	jmp    80106f41 <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
80106f0b:	c7 44 24 04 00 59 12 	movl   $0x80125900,0x4(%esp)
80106f12:	80 
80106f13:	c7 04 24 40 61 12 80 	movl   $0x80126140,(%esp)
80106f1a:	e8 85 d9 ff ff       	call   801048a4 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106f1f:	a1 40 61 12 80       	mov    0x80126140,%eax
80106f24:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106f27:	89 c2                	mov    %eax,%edx
80106f29:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f2c:	39 c2                	cmp    %eax,%edx
80106f2e:	72 bc                	jb     80106eec <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106f30:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
80106f37:	e8 c1 e6 ff ff       	call   801055fd <release>
  return 0;
80106f3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106f41:	c9                   	leave  
80106f42:	c3                   	ret    

80106f43 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106f43:	55                   	push   %ebp
80106f44:	89 e5                	mov    %esp,%ebp
80106f46:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
80106f49:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
80106f50:	e8 3e e6 ff ff       	call   80105593 <acquire>
  xticks = ticks;
80106f55:	a1 40 61 12 80       	mov    0x80126140,%eax
80106f5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106f5d:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
80106f64:	e8 94 e6 ff ff       	call   801055fd <release>
  return xticks;
80106f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106f6c:	c9                   	leave  
80106f6d:	c3                   	ret    

80106f6e <sys_getticks>:

int
sys_getticks(void)
{
80106f6e:	55                   	push   %ebp
80106f6f:	89 e5                	mov    %esp,%ebp
80106f71:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
80106f74:	e8 e7 d1 ff ff       	call   80104160 <myproc>
80106f79:	8b 40 7c             	mov    0x7c(%eax),%eax
}
80106f7c:	c9                   	leave  
80106f7d:	c3                   	ret    
	...

80106f80 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106f80:	1e                   	push   %ds
  pushl %es
80106f81:	06                   	push   %es
  pushl %fs
80106f82:	0f a0                	push   %fs
  pushl %gs
80106f84:	0f a8                	push   %gs
  pushal
80106f86:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106f87:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106f8b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106f8d:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106f8f:	54                   	push   %esp
  call trap
80106f90:	e8 c0 01 00 00       	call   80107155 <trap>
  addl $4, %esp
80106f95:	83 c4 04             	add    $0x4,%esp

80106f98 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106f98:	61                   	popa   
  popl %gs
80106f99:	0f a9                	pop    %gs
  popl %fs
80106f9b:	0f a1                	pop    %fs
  popl %es
80106f9d:	07                   	pop    %es
  popl %ds
80106f9e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106f9f:	83 c4 08             	add    $0x8,%esp
  iret
80106fa2:	cf                   	iret   
	...

80106fa4 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106fa4:	55                   	push   %ebp
80106fa5:	89 e5                	mov    %esp,%ebp
80106fa7:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106faa:	8b 45 0c             	mov    0xc(%ebp),%eax
80106fad:	48                   	dec    %eax
80106fae:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106fb2:	8b 45 08             	mov    0x8(%ebp),%eax
80106fb5:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80106fbc:	c1 e8 10             	shr    $0x10,%eax
80106fbf:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106fc3:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106fc6:	0f 01 18             	lidtl  (%eax)
}
80106fc9:	c9                   	leave  
80106fca:	c3                   	ret    

80106fcb <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106fcb:	55                   	push   %ebp
80106fcc:	89 e5                	mov    %esp,%ebp
80106fce:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106fd1:	0f 20 d0             	mov    %cr2,%eax
80106fd4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106fd7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106fda:	c9                   	leave  
80106fdb:	c3                   	ret    

80106fdc <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106fdc:	55                   	push   %ebp
80106fdd:	89 e5                	mov    %esp,%ebp
80106fdf:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106fe2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106fe9:	e9 b8 00 00 00       	jmp    801070a6 <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106fee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ff1:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
80106ff8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106ffb:	66 89 04 d5 40 59 12 	mov    %ax,-0x7feda6c0(,%edx,8)
80107002:	80 
80107003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107006:	66 c7 04 c5 42 59 12 	movw   $0x8,-0x7feda6be(,%eax,8)
8010700d:	80 08 00 
80107010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107013:	8a 14 c5 44 59 12 80 	mov    -0x7feda6bc(,%eax,8),%dl
8010701a:	83 e2 e0             	and    $0xffffffe0,%edx
8010701d:	88 14 c5 44 59 12 80 	mov    %dl,-0x7feda6bc(,%eax,8)
80107024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107027:	8a 14 c5 44 59 12 80 	mov    -0x7feda6bc(,%eax,8),%dl
8010702e:	83 e2 1f             	and    $0x1f,%edx
80107031:	88 14 c5 44 59 12 80 	mov    %dl,-0x7feda6bc(,%eax,8)
80107038:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010703b:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
80107042:	83 e2 f0             	and    $0xfffffff0,%edx
80107045:	83 ca 0e             	or     $0xe,%edx
80107048:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
8010704f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107052:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
80107059:	83 e2 ef             	and    $0xffffffef,%edx
8010705c:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
80107063:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107066:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
8010706d:	83 e2 9f             	and    $0xffffff9f,%edx
80107070:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
80107077:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010707a:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
80107081:	83 ca 80             	or     $0xffffff80,%edx
80107084:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
8010708b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010708e:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
80107095:	c1 e8 10             	shr    $0x10,%eax
80107098:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010709b:	66 89 04 d5 46 59 12 	mov    %ax,-0x7feda6ba(,%edx,8)
801070a2:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
801070a3:	ff 45 f4             	incl   -0xc(%ebp)
801070a6:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801070ad:	0f 8e 3b ff ff ff    	jle    80106fee <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
801070b3:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
801070b8:	66 a3 40 5b 12 80    	mov    %ax,0x80125b40
801070be:	66 c7 05 42 5b 12 80 	movw   $0x8,0x80125b42
801070c5:	08 00 
801070c7:	a0 44 5b 12 80       	mov    0x80125b44,%al
801070cc:	83 e0 e0             	and    $0xffffffe0,%eax
801070cf:	a2 44 5b 12 80       	mov    %al,0x80125b44
801070d4:	a0 44 5b 12 80       	mov    0x80125b44,%al
801070d9:	83 e0 1f             	and    $0x1f,%eax
801070dc:	a2 44 5b 12 80       	mov    %al,0x80125b44
801070e1:	a0 45 5b 12 80       	mov    0x80125b45,%al
801070e6:	83 c8 0f             	or     $0xf,%eax
801070e9:	a2 45 5b 12 80       	mov    %al,0x80125b45
801070ee:	a0 45 5b 12 80       	mov    0x80125b45,%al
801070f3:	83 e0 ef             	and    $0xffffffef,%eax
801070f6:	a2 45 5b 12 80       	mov    %al,0x80125b45
801070fb:	a0 45 5b 12 80       	mov    0x80125b45,%al
80107100:	83 c8 60             	or     $0x60,%eax
80107103:	a2 45 5b 12 80       	mov    %al,0x80125b45
80107108:	a0 45 5b 12 80       	mov    0x80125b45,%al
8010710d:	83 c8 80             	or     $0xffffff80,%eax
80107110:	a2 45 5b 12 80       	mov    %al,0x80125b45
80107115:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
8010711a:	c1 e8 10             	shr    $0x10,%eax
8010711d:	66 a3 46 5b 12 80    	mov    %ax,0x80125b46

  initlock(&tickslock, "time");
80107123:	c7 44 24 04 d4 94 10 	movl   $0x801094d4,0x4(%esp)
8010712a:	80 
8010712b:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
80107132:	e8 3b e4 ff ff       	call   80105572 <initlock>
}
80107137:	c9                   	leave  
80107138:	c3                   	ret    

80107139 <idtinit>:

void
idtinit(void)
{
80107139:	55                   	push   %ebp
8010713a:	89 e5                	mov    %esp,%ebp
8010713c:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
8010713f:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80107146:	00 
80107147:	c7 04 24 40 59 12 80 	movl   $0x80125940,(%esp)
8010714e:	e8 51 fe ff ff       	call   80106fa4 <lidt>
}
80107153:	c9                   	leave  
80107154:	c3                   	ret    

80107155 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107155:	55                   	push   %ebp
80107156:	89 e5                	mov    %esp,%ebp
80107158:	57                   	push   %edi
80107159:	56                   	push   %esi
8010715a:	53                   	push   %ebx
8010715b:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
8010715e:	8b 45 08             	mov    0x8(%ebp),%eax
80107161:	8b 40 30             	mov    0x30(%eax),%eax
80107164:	83 f8 40             	cmp    $0x40,%eax
80107167:	75 3c                	jne    801071a5 <trap+0x50>
    if(myproc()->killed)
80107169:	e8 f2 cf ff ff       	call   80104160 <myproc>
8010716e:	8b 40 24             	mov    0x24(%eax),%eax
80107171:	85 c0                	test   %eax,%eax
80107173:	74 05                	je     8010717a <trap+0x25>
      exit();
80107175:	e8 7c d4 ff ff       	call   801045f6 <exit>
    myproc()->tf = tf;
8010717a:	e8 e1 cf ff ff       	call   80104160 <myproc>
8010717f:	8b 55 08             	mov    0x8(%ebp),%edx
80107182:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107185:	e8 6d ea ff ff       	call   80105bf7 <syscall>
    if(myproc()->killed)
8010718a:	e8 d1 cf ff ff       	call   80104160 <myproc>
8010718f:	8b 40 24             	mov    0x24(%eax),%eax
80107192:	85 c0                	test   %eax,%eax
80107194:	74 0a                	je     801071a0 <trap+0x4b>
      exit();
80107196:	e8 5b d4 ff ff       	call   801045f6 <exit>
    return;
8010719b:	e9 30 02 00 00       	jmp    801073d0 <trap+0x27b>
801071a0:	e9 2b 02 00 00       	jmp    801073d0 <trap+0x27b>
  }

  switch(tf->trapno){
801071a5:	8b 45 08             	mov    0x8(%ebp),%eax
801071a8:	8b 40 30             	mov    0x30(%eax),%eax
801071ab:	83 e8 20             	sub    $0x20,%eax
801071ae:	83 f8 1f             	cmp    $0x1f,%eax
801071b1:	0f 87 cb 00 00 00    	ja     80107282 <trap+0x12d>
801071b7:	8b 04 85 7c 95 10 80 	mov    -0x7fef6a84(,%eax,4),%eax
801071be:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801071c0:	e8 e1 d9 ff ff       	call   80104ba6 <cpuid>
801071c5:	85 c0                	test   %eax,%eax
801071c7:	75 2f                	jne    801071f8 <trap+0xa3>
      acquire(&tickslock);
801071c9:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
801071d0:	e8 be e3 ff ff       	call   80105593 <acquire>
      ticks++;
801071d5:	a1 40 61 12 80       	mov    0x80126140,%eax
801071da:	40                   	inc    %eax
801071db:	a3 40 61 12 80       	mov    %eax,0x80126140
      wakeup(&ticks);
801071e0:	c7 04 24 40 61 12 80 	movl   $0x80126140,(%esp)
801071e7:	e8 a6 d7 ff ff       	call   80104992 <wakeup>
      release(&tickslock);
801071ec:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
801071f3:	e8 05 e4 ff ff       	call   801055fd <release>
    }
    p = myproc();
801071f8:	e8 63 cf ff ff       	call   80104160 <myproc>
801071fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
80107200:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80107204:	74 0f                	je     80107215 <trap+0xc0>
      p->ticks++;
80107206:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107209:	8b 40 7c             	mov    0x7c(%eax),%eax
8010720c:	8d 50 01             	lea    0x1(%eax),%edx
8010720f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107212:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
80107215:	e8 21 be ff ff       	call   8010303b <lapiceoi>
    break;
8010721a:	e9 35 01 00 00       	jmp    80107354 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010721f:	e8 96 b6 ff ff       	call   801028ba <ideintr>
    lapiceoi();
80107224:	e8 12 be ff ff       	call   8010303b <lapiceoi>
    break;
80107229:	e9 26 01 00 00       	jmp    80107354 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010722e:	e8 1f bc ff ff       	call   80102e52 <kbdintr>
    lapiceoi();
80107233:	e8 03 be ff ff       	call   8010303b <lapiceoi>
    break;
80107238:	e9 17 01 00 00       	jmp    80107354 <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010723d:	e8 6f 03 00 00       	call   801075b1 <uartintr>
    lapiceoi();
80107242:	e8 f4 bd ff ff       	call   8010303b <lapiceoi>
    break;
80107247:	e9 08 01 00 00       	jmp    80107354 <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010724c:	8b 45 08             	mov    0x8(%ebp),%eax
8010724f:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
80107252:	8b 45 08             	mov    0x8(%ebp),%eax
80107255:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107258:	0f b7 d8             	movzwl %ax,%ebx
8010725b:	e8 46 d9 ff ff       	call   80104ba6 <cpuid>
80107260:	89 74 24 0c          	mov    %esi,0xc(%esp)
80107264:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107268:	89 44 24 04          	mov    %eax,0x4(%esp)
8010726c:	c7 04 24 dc 94 10 80 	movl   $0x801094dc,(%esp)
80107273:	e8 49 91 ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80107278:	e8 be bd ff ff       	call   8010303b <lapiceoi>
    break;
8010727d:	e9 d2 00 00 00       	jmp    80107354 <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80107282:	e8 d9 ce ff ff       	call   80104160 <myproc>
80107287:	85 c0                	test   %eax,%eax
80107289:	74 10                	je     8010729b <trap+0x146>
8010728b:	8b 45 08             	mov    0x8(%ebp),%eax
8010728e:	8b 40 3c             	mov    0x3c(%eax),%eax
80107291:	0f b7 c0             	movzwl %ax,%eax
80107294:	83 e0 03             	and    $0x3,%eax
80107297:	85 c0                	test   %eax,%eax
80107299:	75 40                	jne    801072db <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010729b:	e8 2b fd ff ff       	call   80106fcb <rcr2>
801072a0:	89 c3                	mov    %eax,%ebx
801072a2:	8b 45 08             	mov    0x8(%ebp),%eax
801072a5:	8b 70 38             	mov    0x38(%eax),%esi
801072a8:	e8 f9 d8 ff ff       	call   80104ba6 <cpuid>
801072ad:	8b 55 08             	mov    0x8(%ebp),%edx
801072b0:	8b 52 30             	mov    0x30(%edx),%edx
801072b3:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801072b7:	89 74 24 0c          	mov    %esi,0xc(%esp)
801072bb:	89 44 24 08          	mov    %eax,0x8(%esp)
801072bf:	89 54 24 04          	mov    %edx,0x4(%esp)
801072c3:	c7 04 24 00 95 10 80 	movl   $0x80109500,(%esp)
801072ca:	e8 f2 90 ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801072cf:	c7 04 24 32 95 10 80 	movl   $0x80109532,(%esp)
801072d6:	e8 79 92 ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801072db:	e8 eb fc ff ff       	call   80106fcb <rcr2>
801072e0:	89 c6                	mov    %eax,%esi
801072e2:	8b 45 08             	mov    0x8(%ebp),%eax
801072e5:	8b 40 38             	mov    0x38(%eax),%eax
801072e8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801072eb:	e8 b6 d8 ff ff       	call   80104ba6 <cpuid>
801072f0:	89 c3                	mov    %eax,%ebx
801072f2:	8b 45 08             	mov    0x8(%ebp),%eax
801072f5:	8b 78 34             	mov    0x34(%eax),%edi
801072f8:	89 7d d0             	mov    %edi,-0x30(%ebp)
801072fb:	8b 45 08             	mov    0x8(%ebp),%eax
801072fe:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80107301:	e8 5a ce ff ff       	call   80104160 <myproc>
80107306:	8d 50 6c             	lea    0x6c(%eax),%edx
80107309:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010730c:	e8 4f ce ff ff       	call   80104160 <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107311:	8b 40 10             	mov    0x10(%eax),%eax
80107314:	89 74 24 1c          	mov    %esi,0x1c(%esp)
80107318:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
8010731b:	89 4c 24 18          	mov    %ecx,0x18(%esp)
8010731f:	89 5c 24 14          	mov    %ebx,0x14(%esp)
80107323:	8b 4d d0             	mov    -0x30(%ebp),%ecx
80107326:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010732a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
8010732e:	8b 55 cc             	mov    -0x34(%ebp),%edx
80107331:	89 54 24 08          	mov    %edx,0x8(%esp)
80107335:	89 44 24 04          	mov    %eax,0x4(%esp)
80107339:	c7 04 24 38 95 10 80 	movl   $0x80109538,(%esp)
80107340:	e8 7c 90 ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80107345:	e8 16 ce ff ff       	call   80104160 <myproc>
8010734a:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107351:	eb 01                	jmp    80107354 <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80107353:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80107354:	e8 07 ce ff ff       	call   80104160 <myproc>
80107359:	85 c0                	test   %eax,%eax
8010735b:	74 22                	je     8010737f <trap+0x22a>
8010735d:	e8 fe cd ff ff       	call   80104160 <myproc>
80107362:	8b 40 24             	mov    0x24(%eax),%eax
80107365:	85 c0                	test   %eax,%eax
80107367:	74 16                	je     8010737f <trap+0x22a>
80107369:	8b 45 08             	mov    0x8(%ebp),%eax
8010736c:	8b 40 3c             	mov    0x3c(%eax),%eax
8010736f:	0f b7 c0             	movzwl %ax,%eax
80107372:	83 e0 03             	and    $0x3,%eax
80107375:	83 f8 03             	cmp    $0x3,%eax
80107378:	75 05                	jne    8010737f <trap+0x22a>
    exit();
8010737a:	e8 77 d2 ff ff       	call   801045f6 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010737f:	e8 dc cd ff ff       	call   80104160 <myproc>
80107384:	85 c0                	test   %eax,%eax
80107386:	74 1d                	je     801073a5 <trap+0x250>
80107388:	e8 d3 cd ff ff       	call   80104160 <myproc>
8010738d:	8b 40 0c             	mov    0xc(%eax),%eax
80107390:	83 f8 04             	cmp    $0x4,%eax
80107393:	75 10                	jne    801073a5 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80107395:	8b 45 08             	mov    0x8(%ebp),%eax
80107398:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010739b:	83 f8 20             	cmp    $0x20,%eax
8010739e:	75 05                	jne    801073a5 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
801073a0:	e8 a4 d4 ff ff       	call   80104849 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801073a5:	e8 b6 cd ff ff       	call   80104160 <myproc>
801073aa:	85 c0                	test   %eax,%eax
801073ac:	74 22                	je     801073d0 <trap+0x27b>
801073ae:	e8 ad cd ff ff       	call   80104160 <myproc>
801073b3:	8b 40 24             	mov    0x24(%eax),%eax
801073b6:	85 c0                	test   %eax,%eax
801073b8:	74 16                	je     801073d0 <trap+0x27b>
801073ba:	8b 45 08             	mov    0x8(%ebp),%eax
801073bd:	8b 40 3c             	mov    0x3c(%eax),%eax
801073c0:	0f b7 c0             	movzwl %ax,%eax
801073c3:	83 e0 03             	and    $0x3,%eax
801073c6:	83 f8 03             	cmp    $0x3,%eax
801073c9:	75 05                	jne    801073d0 <trap+0x27b>
    exit();
801073cb:	e8 26 d2 ff ff       	call   801045f6 <exit>
}
801073d0:	83 c4 4c             	add    $0x4c,%esp
801073d3:	5b                   	pop    %ebx
801073d4:	5e                   	pop    %esi
801073d5:	5f                   	pop    %edi
801073d6:	5d                   	pop    %ebp
801073d7:	c3                   	ret    

801073d8 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801073d8:	55                   	push   %ebp
801073d9:	89 e5                	mov    %esp,%ebp
801073db:	83 ec 14             	sub    $0x14,%esp
801073de:	8b 45 08             	mov    0x8(%ebp),%eax
801073e1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801073e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801073e8:	89 c2                	mov    %eax,%edx
801073ea:	ec                   	in     (%dx),%al
801073eb:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801073ee:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801073f1:	c9                   	leave  
801073f2:	c3                   	ret    

801073f3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801073f3:	55                   	push   %ebp
801073f4:	89 e5                	mov    %esp,%ebp
801073f6:	83 ec 08             	sub    $0x8,%esp
801073f9:	8b 45 08             	mov    0x8(%ebp),%eax
801073fc:	8b 55 0c             	mov    0xc(%ebp),%edx
801073ff:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107403:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107406:	8a 45 f8             	mov    -0x8(%ebp),%al
80107409:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010740c:	ee                   	out    %al,(%dx)
}
8010740d:	c9                   	leave  
8010740e:	c3                   	ret    

8010740f <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010740f:	55                   	push   %ebp
80107410:	89 e5                	mov    %esp,%ebp
80107412:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107415:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010741c:	00 
8010741d:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107424:	e8 ca ff ff ff       	call   801073f3 <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107429:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
80107430:	00 
80107431:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107438:	e8 b6 ff ff ff       	call   801073f3 <outb>
  outb(COM1+0, 115200/9600);
8010743d:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80107444:	00 
80107445:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010744c:	e8 a2 ff ff ff       	call   801073f3 <outb>
  outb(COM1+1, 0);
80107451:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107458:	00 
80107459:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107460:	e8 8e ff ff ff       	call   801073f3 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107465:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
8010746c:	00 
8010746d:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107474:	e8 7a ff ff ff       	call   801073f3 <outb>
  outb(COM1+4, 0);
80107479:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107480:	00 
80107481:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107488:	e8 66 ff ff ff       	call   801073f3 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
8010748d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107494:	00 
80107495:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
8010749c:	e8 52 ff ff ff       	call   801073f3 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
801074a1:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801074a8:	e8 2b ff ff ff       	call   801073d8 <inb>
801074ad:	3c ff                	cmp    $0xff,%al
801074af:	75 02                	jne    801074b3 <uartinit+0xa4>
    return;
801074b1:	eb 5b                	jmp    8010750e <uartinit+0xff>
  uart = 1;
801074b3:	c7 05 84 c7 10 80 01 	movl   $0x1,0x8010c784
801074ba:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
801074bd:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801074c4:	e8 0f ff ff ff       	call   801073d8 <inb>
  inb(COM1+0);
801074c9:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801074d0:	e8 03 ff ff ff       	call   801073d8 <inb>
  ioapicenable(IRQ_COM1, 0);
801074d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801074dc:	00 
801074dd:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801074e4:	e8 46 b6 ff ff       	call   80102b2f <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801074e9:	c7 45 f4 fc 95 10 80 	movl   $0x801095fc,-0xc(%ebp)
801074f0:	eb 13                	jmp    80107505 <uartinit+0xf6>
    uartputc(*p);
801074f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074f5:	8a 00                	mov    (%eax),%al
801074f7:	0f be c0             	movsbl %al,%eax
801074fa:	89 04 24             	mov    %eax,(%esp)
801074fd:	e8 0e 00 00 00       	call   80107510 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107502:	ff 45 f4             	incl   -0xc(%ebp)
80107505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107508:	8a 00                	mov    (%eax),%al
8010750a:	84 c0                	test   %al,%al
8010750c:	75 e4                	jne    801074f2 <uartinit+0xe3>
    uartputc(*p);
}
8010750e:	c9                   	leave  
8010750f:	c3                   	ret    

80107510 <uartputc>:

void
uartputc(int c)
{
80107510:	55                   	push   %ebp
80107511:	89 e5                	mov    %esp,%ebp
80107513:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80107516:	a1 84 c7 10 80       	mov    0x8010c784,%eax
8010751b:	85 c0                	test   %eax,%eax
8010751d:	75 02                	jne    80107521 <uartputc+0x11>
    return;
8010751f:	eb 4a                	jmp    8010756b <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107521:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107528:	eb 0f                	jmp    80107539 <uartputc+0x29>
    microdelay(10);
8010752a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80107531:	e8 2a bb ff ff       	call   80103060 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107536:	ff 45 f4             	incl   -0xc(%ebp)
80107539:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
8010753d:	7f 16                	jg     80107555 <uartputc+0x45>
8010753f:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107546:	e8 8d fe ff ff       	call   801073d8 <inb>
8010754b:	0f b6 c0             	movzbl %al,%eax
8010754e:	83 e0 20             	and    $0x20,%eax
80107551:	85 c0                	test   %eax,%eax
80107553:	74 d5                	je     8010752a <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80107555:	8b 45 08             	mov    0x8(%ebp),%eax
80107558:	0f b6 c0             	movzbl %al,%eax
8010755b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010755f:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107566:	e8 88 fe ff ff       	call   801073f3 <outb>
}
8010756b:	c9                   	leave  
8010756c:	c3                   	ret    

8010756d <uartgetc>:

static int
uartgetc(void)
{
8010756d:	55                   	push   %ebp
8010756e:	89 e5                	mov    %esp,%ebp
80107570:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
80107573:	a1 84 c7 10 80       	mov    0x8010c784,%eax
80107578:	85 c0                	test   %eax,%eax
8010757a:	75 07                	jne    80107583 <uartgetc+0x16>
    return -1;
8010757c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107581:	eb 2c                	jmp    801075af <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
80107583:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
8010758a:	e8 49 fe ff ff       	call   801073d8 <inb>
8010758f:	0f b6 c0             	movzbl %al,%eax
80107592:	83 e0 01             	and    $0x1,%eax
80107595:	85 c0                	test   %eax,%eax
80107597:	75 07                	jne    801075a0 <uartgetc+0x33>
    return -1;
80107599:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010759e:	eb 0f                	jmp    801075af <uartgetc+0x42>
  return inb(COM1+0);
801075a0:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801075a7:	e8 2c fe ff ff       	call   801073d8 <inb>
801075ac:	0f b6 c0             	movzbl %al,%eax
}
801075af:	c9                   	leave  
801075b0:	c3                   	ret    

801075b1 <uartintr>:

void
uartintr(void)
{
801075b1:	55                   	push   %ebp
801075b2:	89 e5                	mov    %esp,%ebp
801075b4:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
801075b7:	c7 04 24 6d 75 10 80 	movl   $0x8010756d,(%esp)
801075be:	e8 32 92 ff ff       	call   801007f5 <consoleintr>
}
801075c3:	c9                   	leave  
801075c4:	c3                   	ret    
801075c5:	00 00                	add    %al,(%eax)
	...

801075c8 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801075c8:	6a 00                	push   $0x0
  pushl $0
801075ca:	6a 00                	push   $0x0
  jmp alltraps
801075cc:	e9 af f9 ff ff       	jmp    80106f80 <alltraps>

801075d1 <vector1>:
.globl vector1
vector1:
  pushl $0
801075d1:	6a 00                	push   $0x0
  pushl $1
801075d3:	6a 01                	push   $0x1
  jmp alltraps
801075d5:	e9 a6 f9 ff ff       	jmp    80106f80 <alltraps>

801075da <vector2>:
.globl vector2
vector2:
  pushl $0
801075da:	6a 00                	push   $0x0
  pushl $2
801075dc:	6a 02                	push   $0x2
  jmp alltraps
801075de:	e9 9d f9 ff ff       	jmp    80106f80 <alltraps>

801075e3 <vector3>:
.globl vector3
vector3:
  pushl $0
801075e3:	6a 00                	push   $0x0
  pushl $3
801075e5:	6a 03                	push   $0x3
  jmp alltraps
801075e7:	e9 94 f9 ff ff       	jmp    80106f80 <alltraps>

801075ec <vector4>:
.globl vector4
vector4:
  pushl $0
801075ec:	6a 00                	push   $0x0
  pushl $4
801075ee:	6a 04                	push   $0x4
  jmp alltraps
801075f0:	e9 8b f9 ff ff       	jmp    80106f80 <alltraps>

801075f5 <vector5>:
.globl vector5
vector5:
  pushl $0
801075f5:	6a 00                	push   $0x0
  pushl $5
801075f7:	6a 05                	push   $0x5
  jmp alltraps
801075f9:	e9 82 f9 ff ff       	jmp    80106f80 <alltraps>

801075fe <vector6>:
.globl vector6
vector6:
  pushl $0
801075fe:	6a 00                	push   $0x0
  pushl $6
80107600:	6a 06                	push   $0x6
  jmp alltraps
80107602:	e9 79 f9 ff ff       	jmp    80106f80 <alltraps>

80107607 <vector7>:
.globl vector7
vector7:
  pushl $0
80107607:	6a 00                	push   $0x0
  pushl $7
80107609:	6a 07                	push   $0x7
  jmp alltraps
8010760b:	e9 70 f9 ff ff       	jmp    80106f80 <alltraps>

80107610 <vector8>:
.globl vector8
vector8:
  pushl $8
80107610:	6a 08                	push   $0x8
  jmp alltraps
80107612:	e9 69 f9 ff ff       	jmp    80106f80 <alltraps>

80107617 <vector9>:
.globl vector9
vector9:
  pushl $0
80107617:	6a 00                	push   $0x0
  pushl $9
80107619:	6a 09                	push   $0x9
  jmp alltraps
8010761b:	e9 60 f9 ff ff       	jmp    80106f80 <alltraps>

80107620 <vector10>:
.globl vector10
vector10:
  pushl $10
80107620:	6a 0a                	push   $0xa
  jmp alltraps
80107622:	e9 59 f9 ff ff       	jmp    80106f80 <alltraps>

80107627 <vector11>:
.globl vector11
vector11:
  pushl $11
80107627:	6a 0b                	push   $0xb
  jmp alltraps
80107629:	e9 52 f9 ff ff       	jmp    80106f80 <alltraps>

8010762e <vector12>:
.globl vector12
vector12:
  pushl $12
8010762e:	6a 0c                	push   $0xc
  jmp alltraps
80107630:	e9 4b f9 ff ff       	jmp    80106f80 <alltraps>

80107635 <vector13>:
.globl vector13
vector13:
  pushl $13
80107635:	6a 0d                	push   $0xd
  jmp alltraps
80107637:	e9 44 f9 ff ff       	jmp    80106f80 <alltraps>

8010763c <vector14>:
.globl vector14
vector14:
  pushl $14
8010763c:	6a 0e                	push   $0xe
  jmp alltraps
8010763e:	e9 3d f9 ff ff       	jmp    80106f80 <alltraps>

80107643 <vector15>:
.globl vector15
vector15:
  pushl $0
80107643:	6a 00                	push   $0x0
  pushl $15
80107645:	6a 0f                	push   $0xf
  jmp alltraps
80107647:	e9 34 f9 ff ff       	jmp    80106f80 <alltraps>

8010764c <vector16>:
.globl vector16
vector16:
  pushl $0
8010764c:	6a 00                	push   $0x0
  pushl $16
8010764e:	6a 10                	push   $0x10
  jmp alltraps
80107650:	e9 2b f9 ff ff       	jmp    80106f80 <alltraps>

80107655 <vector17>:
.globl vector17
vector17:
  pushl $17
80107655:	6a 11                	push   $0x11
  jmp alltraps
80107657:	e9 24 f9 ff ff       	jmp    80106f80 <alltraps>

8010765c <vector18>:
.globl vector18
vector18:
  pushl $0
8010765c:	6a 00                	push   $0x0
  pushl $18
8010765e:	6a 12                	push   $0x12
  jmp alltraps
80107660:	e9 1b f9 ff ff       	jmp    80106f80 <alltraps>

80107665 <vector19>:
.globl vector19
vector19:
  pushl $0
80107665:	6a 00                	push   $0x0
  pushl $19
80107667:	6a 13                	push   $0x13
  jmp alltraps
80107669:	e9 12 f9 ff ff       	jmp    80106f80 <alltraps>

8010766e <vector20>:
.globl vector20
vector20:
  pushl $0
8010766e:	6a 00                	push   $0x0
  pushl $20
80107670:	6a 14                	push   $0x14
  jmp alltraps
80107672:	e9 09 f9 ff ff       	jmp    80106f80 <alltraps>

80107677 <vector21>:
.globl vector21
vector21:
  pushl $0
80107677:	6a 00                	push   $0x0
  pushl $21
80107679:	6a 15                	push   $0x15
  jmp alltraps
8010767b:	e9 00 f9 ff ff       	jmp    80106f80 <alltraps>

80107680 <vector22>:
.globl vector22
vector22:
  pushl $0
80107680:	6a 00                	push   $0x0
  pushl $22
80107682:	6a 16                	push   $0x16
  jmp alltraps
80107684:	e9 f7 f8 ff ff       	jmp    80106f80 <alltraps>

80107689 <vector23>:
.globl vector23
vector23:
  pushl $0
80107689:	6a 00                	push   $0x0
  pushl $23
8010768b:	6a 17                	push   $0x17
  jmp alltraps
8010768d:	e9 ee f8 ff ff       	jmp    80106f80 <alltraps>

80107692 <vector24>:
.globl vector24
vector24:
  pushl $0
80107692:	6a 00                	push   $0x0
  pushl $24
80107694:	6a 18                	push   $0x18
  jmp alltraps
80107696:	e9 e5 f8 ff ff       	jmp    80106f80 <alltraps>

8010769b <vector25>:
.globl vector25
vector25:
  pushl $0
8010769b:	6a 00                	push   $0x0
  pushl $25
8010769d:	6a 19                	push   $0x19
  jmp alltraps
8010769f:	e9 dc f8 ff ff       	jmp    80106f80 <alltraps>

801076a4 <vector26>:
.globl vector26
vector26:
  pushl $0
801076a4:	6a 00                	push   $0x0
  pushl $26
801076a6:	6a 1a                	push   $0x1a
  jmp alltraps
801076a8:	e9 d3 f8 ff ff       	jmp    80106f80 <alltraps>

801076ad <vector27>:
.globl vector27
vector27:
  pushl $0
801076ad:	6a 00                	push   $0x0
  pushl $27
801076af:	6a 1b                	push   $0x1b
  jmp alltraps
801076b1:	e9 ca f8 ff ff       	jmp    80106f80 <alltraps>

801076b6 <vector28>:
.globl vector28
vector28:
  pushl $0
801076b6:	6a 00                	push   $0x0
  pushl $28
801076b8:	6a 1c                	push   $0x1c
  jmp alltraps
801076ba:	e9 c1 f8 ff ff       	jmp    80106f80 <alltraps>

801076bf <vector29>:
.globl vector29
vector29:
  pushl $0
801076bf:	6a 00                	push   $0x0
  pushl $29
801076c1:	6a 1d                	push   $0x1d
  jmp alltraps
801076c3:	e9 b8 f8 ff ff       	jmp    80106f80 <alltraps>

801076c8 <vector30>:
.globl vector30
vector30:
  pushl $0
801076c8:	6a 00                	push   $0x0
  pushl $30
801076ca:	6a 1e                	push   $0x1e
  jmp alltraps
801076cc:	e9 af f8 ff ff       	jmp    80106f80 <alltraps>

801076d1 <vector31>:
.globl vector31
vector31:
  pushl $0
801076d1:	6a 00                	push   $0x0
  pushl $31
801076d3:	6a 1f                	push   $0x1f
  jmp alltraps
801076d5:	e9 a6 f8 ff ff       	jmp    80106f80 <alltraps>

801076da <vector32>:
.globl vector32
vector32:
  pushl $0
801076da:	6a 00                	push   $0x0
  pushl $32
801076dc:	6a 20                	push   $0x20
  jmp alltraps
801076de:	e9 9d f8 ff ff       	jmp    80106f80 <alltraps>

801076e3 <vector33>:
.globl vector33
vector33:
  pushl $0
801076e3:	6a 00                	push   $0x0
  pushl $33
801076e5:	6a 21                	push   $0x21
  jmp alltraps
801076e7:	e9 94 f8 ff ff       	jmp    80106f80 <alltraps>

801076ec <vector34>:
.globl vector34
vector34:
  pushl $0
801076ec:	6a 00                	push   $0x0
  pushl $34
801076ee:	6a 22                	push   $0x22
  jmp alltraps
801076f0:	e9 8b f8 ff ff       	jmp    80106f80 <alltraps>

801076f5 <vector35>:
.globl vector35
vector35:
  pushl $0
801076f5:	6a 00                	push   $0x0
  pushl $35
801076f7:	6a 23                	push   $0x23
  jmp alltraps
801076f9:	e9 82 f8 ff ff       	jmp    80106f80 <alltraps>

801076fe <vector36>:
.globl vector36
vector36:
  pushl $0
801076fe:	6a 00                	push   $0x0
  pushl $36
80107700:	6a 24                	push   $0x24
  jmp alltraps
80107702:	e9 79 f8 ff ff       	jmp    80106f80 <alltraps>

80107707 <vector37>:
.globl vector37
vector37:
  pushl $0
80107707:	6a 00                	push   $0x0
  pushl $37
80107709:	6a 25                	push   $0x25
  jmp alltraps
8010770b:	e9 70 f8 ff ff       	jmp    80106f80 <alltraps>

80107710 <vector38>:
.globl vector38
vector38:
  pushl $0
80107710:	6a 00                	push   $0x0
  pushl $38
80107712:	6a 26                	push   $0x26
  jmp alltraps
80107714:	e9 67 f8 ff ff       	jmp    80106f80 <alltraps>

80107719 <vector39>:
.globl vector39
vector39:
  pushl $0
80107719:	6a 00                	push   $0x0
  pushl $39
8010771b:	6a 27                	push   $0x27
  jmp alltraps
8010771d:	e9 5e f8 ff ff       	jmp    80106f80 <alltraps>

80107722 <vector40>:
.globl vector40
vector40:
  pushl $0
80107722:	6a 00                	push   $0x0
  pushl $40
80107724:	6a 28                	push   $0x28
  jmp alltraps
80107726:	e9 55 f8 ff ff       	jmp    80106f80 <alltraps>

8010772b <vector41>:
.globl vector41
vector41:
  pushl $0
8010772b:	6a 00                	push   $0x0
  pushl $41
8010772d:	6a 29                	push   $0x29
  jmp alltraps
8010772f:	e9 4c f8 ff ff       	jmp    80106f80 <alltraps>

80107734 <vector42>:
.globl vector42
vector42:
  pushl $0
80107734:	6a 00                	push   $0x0
  pushl $42
80107736:	6a 2a                	push   $0x2a
  jmp alltraps
80107738:	e9 43 f8 ff ff       	jmp    80106f80 <alltraps>

8010773d <vector43>:
.globl vector43
vector43:
  pushl $0
8010773d:	6a 00                	push   $0x0
  pushl $43
8010773f:	6a 2b                	push   $0x2b
  jmp alltraps
80107741:	e9 3a f8 ff ff       	jmp    80106f80 <alltraps>

80107746 <vector44>:
.globl vector44
vector44:
  pushl $0
80107746:	6a 00                	push   $0x0
  pushl $44
80107748:	6a 2c                	push   $0x2c
  jmp alltraps
8010774a:	e9 31 f8 ff ff       	jmp    80106f80 <alltraps>

8010774f <vector45>:
.globl vector45
vector45:
  pushl $0
8010774f:	6a 00                	push   $0x0
  pushl $45
80107751:	6a 2d                	push   $0x2d
  jmp alltraps
80107753:	e9 28 f8 ff ff       	jmp    80106f80 <alltraps>

80107758 <vector46>:
.globl vector46
vector46:
  pushl $0
80107758:	6a 00                	push   $0x0
  pushl $46
8010775a:	6a 2e                	push   $0x2e
  jmp alltraps
8010775c:	e9 1f f8 ff ff       	jmp    80106f80 <alltraps>

80107761 <vector47>:
.globl vector47
vector47:
  pushl $0
80107761:	6a 00                	push   $0x0
  pushl $47
80107763:	6a 2f                	push   $0x2f
  jmp alltraps
80107765:	e9 16 f8 ff ff       	jmp    80106f80 <alltraps>

8010776a <vector48>:
.globl vector48
vector48:
  pushl $0
8010776a:	6a 00                	push   $0x0
  pushl $48
8010776c:	6a 30                	push   $0x30
  jmp alltraps
8010776e:	e9 0d f8 ff ff       	jmp    80106f80 <alltraps>

80107773 <vector49>:
.globl vector49
vector49:
  pushl $0
80107773:	6a 00                	push   $0x0
  pushl $49
80107775:	6a 31                	push   $0x31
  jmp alltraps
80107777:	e9 04 f8 ff ff       	jmp    80106f80 <alltraps>

8010777c <vector50>:
.globl vector50
vector50:
  pushl $0
8010777c:	6a 00                	push   $0x0
  pushl $50
8010777e:	6a 32                	push   $0x32
  jmp alltraps
80107780:	e9 fb f7 ff ff       	jmp    80106f80 <alltraps>

80107785 <vector51>:
.globl vector51
vector51:
  pushl $0
80107785:	6a 00                	push   $0x0
  pushl $51
80107787:	6a 33                	push   $0x33
  jmp alltraps
80107789:	e9 f2 f7 ff ff       	jmp    80106f80 <alltraps>

8010778e <vector52>:
.globl vector52
vector52:
  pushl $0
8010778e:	6a 00                	push   $0x0
  pushl $52
80107790:	6a 34                	push   $0x34
  jmp alltraps
80107792:	e9 e9 f7 ff ff       	jmp    80106f80 <alltraps>

80107797 <vector53>:
.globl vector53
vector53:
  pushl $0
80107797:	6a 00                	push   $0x0
  pushl $53
80107799:	6a 35                	push   $0x35
  jmp alltraps
8010779b:	e9 e0 f7 ff ff       	jmp    80106f80 <alltraps>

801077a0 <vector54>:
.globl vector54
vector54:
  pushl $0
801077a0:	6a 00                	push   $0x0
  pushl $54
801077a2:	6a 36                	push   $0x36
  jmp alltraps
801077a4:	e9 d7 f7 ff ff       	jmp    80106f80 <alltraps>

801077a9 <vector55>:
.globl vector55
vector55:
  pushl $0
801077a9:	6a 00                	push   $0x0
  pushl $55
801077ab:	6a 37                	push   $0x37
  jmp alltraps
801077ad:	e9 ce f7 ff ff       	jmp    80106f80 <alltraps>

801077b2 <vector56>:
.globl vector56
vector56:
  pushl $0
801077b2:	6a 00                	push   $0x0
  pushl $56
801077b4:	6a 38                	push   $0x38
  jmp alltraps
801077b6:	e9 c5 f7 ff ff       	jmp    80106f80 <alltraps>

801077bb <vector57>:
.globl vector57
vector57:
  pushl $0
801077bb:	6a 00                	push   $0x0
  pushl $57
801077bd:	6a 39                	push   $0x39
  jmp alltraps
801077bf:	e9 bc f7 ff ff       	jmp    80106f80 <alltraps>

801077c4 <vector58>:
.globl vector58
vector58:
  pushl $0
801077c4:	6a 00                	push   $0x0
  pushl $58
801077c6:	6a 3a                	push   $0x3a
  jmp alltraps
801077c8:	e9 b3 f7 ff ff       	jmp    80106f80 <alltraps>

801077cd <vector59>:
.globl vector59
vector59:
  pushl $0
801077cd:	6a 00                	push   $0x0
  pushl $59
801077cf:	6a 3b                	push   $0x3b
  jmp alltraps
801077d1:	e9 aa f7 ff ff       	jmp    80106f80 <alltraps>

801077d6 <vector60>:
.globl vector60
vector60:
  pushl $0
801077d6:	6a 00                	push   $0x0
  pushl $60
801077d8:	6a 3c                	push   $0x3c
  jmp alltraps
801077da:	e9 a1 f7 ff ff       	jmp    80106f80 <alltraps>

801077df <vector61>:
.globl vector61
vector61:
  pushl $0
801077df:	6a 00                	push   $0x0
  pushl $61
801077e1:	6a 3d                	push   $0x3d
  jmp alltraps
801077e3:	e9 98 f7 ff ff       	jmp    80106f80 <alltraps>

801077e8 <vector62>:
.globl vector62
vector62:
  pushl $0
801077e8:	6a 00                	push   $0x0
  pushl $62
801077ea:	6a 3e                	push   $0x3e
  jmp alltraps
801077ec:	e9 8f f7 ff ff       	jmp    80106f80 <alltraps>

801077f1 <vector63>:
.globl vector63
vector63:
  pushl $0
801077f1:	6a 00                	push   $0x0
  pushl $63
801077f3:	6a 3f                	push   $0x3f
  jmp alltraps
801077f5:	e9 86 f7 ff ff       	jmp    80106f80 <alltraps>

801077fa <vector64>:
.globl vector64
vector64:
  pushl $0
801077fa:	6a 00                	push   $0x0
  pushl $64
801077fc:	6a 40                	push   $0x40
  jmp alltraps
801077fe:	e9 7d f7 ff ff       	jmp    80106f80 <alltraps>

80107803 <vector65>:
.globl vector65
vector65:
  pushl $0
80107803:	6a 00                	push   $0x0
  pushl $65
80107805:	6a 41                	push   $0x41
  jmp alltraps
80107807:	e9 74 f7 ff ff       	jmp    80106f80 <alltraps>

8010780c <vector66>:
.globl vector66
vector66:
  pushl $0
8010780c:	6a 00                	push   $0x0
  pushl $66
8010780e:	6a 42                	push   $0x42
  jmp alltraps
80107810:	e9 6b f7 ff ff       	jmp    80106f80 <alltraps>

80107815 <vector67>:
.globl vector67
vector67:
  pushl $0
80107815:	6a 00                	push   $0x0
  pushl $67
80107817:	6a 43                	push   $0x43
  jmp alltraps
80107819:	e9 62 f7 ff ff       	jmp    80106f80 <alltraps>

8010781e <vector68>:
.globl vector68
vector68:
  pushl $0
8010781e:	6a 00                	push   $0x0
  pushl $68
80107820:	6a 44                	push   $0x44
  jmp alltraps
80107822:	e9 59 f7 ff ff       	jmp    80106f80 <alltraps>

80107827 <vector69>:
.globl vector69
vector69:
  pushl $0
80107827:	6a 00                	push   $0x0
  pushl $69
80107829:	6a 45                	push   $0x45
  jmp alltraps
8010782b:	e9 50 f7 ff ff       	jmp    80106f80 <alltraps>

80107830 <vector70>:
.globl vector70
vector70:
  pushl $0
80107830:	6a 00                	push   $0x0
  pushl $70
80107832:	6a 46                	push   $0x46
  jmp alltraps
80107834:	e9 47 f7 ff ff       	jmp    80106f80 <alltraps>

80107839 <vector71>:
.globl vector71
vector71:
  pushl $0
80107839:	6a 00                	push   $0x0
  pushl $71
8010783b:	6a 47                	push   $0x47
  jmp alltraps
8010783d:	e9 3e f7 ff ff       	jmp    80106f80 <alltraps>

80107842 <vector72>:
.globl vector72
vector72:
  pushl $0
80107842:	6a 00                	push   $0x0
  pushl $72
80107844:	6a 48                	push   $0x48
  jmp alltraps
80107846:	e9 35 f7 ff ff       	jmp    80106f80 <alltraps>

8010784b <vector73>:
.globl vector73
vector73:
  pushl $0
8010784b:	6a 00                	push   $0x0
  pushl $73
8010784d:	6a 49                	push   $0x49
  jmp alltraps
8010784f:	e9 2c f7 ff ff       	jmp    80106f80 <alltraps>

80107854 <vector74>:
.globl vector74
vector74:
  pushl $0
80107854:	6a 00                	push   $0x0
  pushl $74
80107856:	6a 4a                	push   $0x4a
  jmp alltraps
80107858:	e9 23 f7 ff ff       	jmp    80106f80 <alltraps>

8010785d <vector75>:
.globl vector75
vector75:
  pushl $0
8010785d:	6a 00                	push   $0x0
  pushl $75
8010785f:	6a 4b                	push   $0x4b
  jmp alltraps
80107861:	e9 1a f7 ff ff       	jmp    80106f80 <alltraps>

80107866 <vector76>:
.globl vector76
vector76:
  pushl $0
80107866:	6a 00                	push   $0x0
  pushl $76
80107868:	6a 4c                	push   $0x4c
  jmp alltraps
8010786a:	e9 11 f7 ff ff       	jmp    80106f80 <alltraps>

8010786f <vector77>:
.globl vector77
vector77:
  pushl $0
8010786f:	6a 00                	push   $0x0
  pushl $77
80107871:	6a 4d                	push   $0x4d
  jmp alltraps
80107873:	e9 08 f7 ff ff       	jmp    80106f80 <alltraps>

80107878 <vector78>:
.globl vector78
vector78:
  pushl $0
80107878:	6a 00                	push   $0x0
  pushl $78
8010787a:	6a 4e                	push   $0x4e
  jmp alltraps
8010787c:	e9 ff f6 ff ff       	jmp    80106f80 <alltraps>

80107881 <vector79>:
.globl vector79
vector79:
  pushl $0
80107881:	6a 00                	push   $0x0
  pushl $79
80107883:	6a 4f                	push   $0x4f
  jmp alltraps
80107885:	e9 f6 f6 ff ff       	jmp    80106f80 <alltraps>

8010788a <vector80>:
.globl vector80
vector80:
  pushl $0
8010788a:	6a 00                	push   $0x0
  pushl $80
8010788c:	6a 50                	push   $0x50
  jmp alltraps
8010788e:	e9 ed f6 ff ff       	jmp    80106f80 <alltraps>

80107893 <vector81>:
.globl vector81
vector81:
  pushl $0
80107893:	6a 00                	push   $0x0
  pushl $81
80107895:	6a 51                	push   $0x51
  jmp alltraps
80107897:	e9 e4 f6 ff ff       	jmp    80106f80 <alltraps>

8010789c <vector82>:
.globl vector82
vector82:
  pushl $0
8010789c:	6a 00                	push   $0x0
  pushl $82
8010789e:	6a 52                	push   $0x52
  jmp alltraps
801078a0:	e9 db f6 ff ff       	jmp    80106f80 <alltraps>

801078a5 <vector83>:
.globl vector83
vector83:
  pushl $0
801078a5:	6a 00                	push   $0x0
  pushl $83
801078a7:	6a 53                	push   $0x53
  jmp alltraps
801078a9:	e9 d2 f6 ff ff       	jmp    80106f80 <alltraps>

801078ae <vector84>:
.globl vector84
vector84:
  pushl $0
801078ae:	6a 00                	push   $0x0
  pushl $84
801078b0:	6a 54                	push   $0x54
  jmp alltraps
801078b2:	e9 c9 f6 ff ff       	jmp    80106f80 <alltraps>

801078b7 <vector85>:
.globl vector85
vector85:
  pushl $0
801078b7:	6a 00                	push   $0x0
  pushl $85
801078b9:	6a 55                	push   $0x55
  jmp alltraps
801078bb:	e9 c0 f6 ff ff       	jmp    80106f80 <alltraps>

801078c0 <vector86>:
.globl vector86
vector86:
  pushl $0
801078c0:	6a 00                	push   $0x0
  pushl $86
801078c2:	6a 56                	push   $0x56
  jmp alltraps
801078c4:	e9 b7 f6 ff ff       	jmp    80106f80 <alltraps>

801078c9 <vector87>:
.globl vector87
vector87:
  pushl $0
801078c9:	6a 00                	push   $0x0
  pushl $87
801078cb:	6a 57                	push   $0x57
  jmp alltraps
801078cd:	e9 ae f6 ff ff       	jmp    80106f80 <alltraps>

801078d2 <vector88>:
.globl vector88
vector88:
  pushl $0
801078d2:	6a 00                	push   $0x0
  pushl $88
801078d4:	6a 58                	push   $0x58
  jmp alltraps
801078d6:	e9 a5 f6 ff ff       	jmp    80106f80 <alltraps>

801078db <vector89>:
.globl vector89
vector89:
  pushl $0
801078db:	6a 00                	push   $0x0
  pushl $89
801078dd:	6a 59                	push   $0x59
  jmp alltraps
801078df:	e9 9c f6 ff ff       	jmp    80106f80 <alltraps>

801078e4 <vector90>:
.globl vector90
vector90:
  pushl $0
801078e4:	6a 00                	push   $0x0
  pushl $90
801078e6:	6a 5a                	push   $0x5a
  jmp alltraps
801078e8:	e9 93 f6 ff ff       	jmp    80106f80 <alltraps>

801078ed <vector91>:
.globl vector91
vector91:
  pushl $0
801078ed:	6a 00                	push   $0x0
  pushl $91
801078ef:	6a 5b                	push   $0x5b
  jmp alltraps
801078f1:	e9 8a f6 ff ff       	jmp    80106f80 <alltraps>

801078f6 <vector92>:
.globl vector92
vector92:
  pushl $0
801078f6:	6a 00                	push   $0x0
  pushl $92
801078f8:	6a 5c                	push   $0x5c
  jmp alltraps
801078fa:	e9 81 f6 ff ff       	jmp    80106f80 <alltraps>

801078ff <vector93>:
.globl vector93
vector93:
  pushl $0
801078ff:	6a 00                	push   $0x0
  pushl $93
80107901:	6a 5d                	push   $0x5d
  jmp alltraps
80107903:	e9 78 f6 ff ff       	jmp    80106f80 <alltraps>

80107908 <vector94>:
.globl vector94
vector94:
  pushl $0
80107908:	6a 00                	push   $0x0
  pushl $94
8010790a:	6a 5e                	push   $0x5e
  jmp alltraps
8010790c:	e9 6f f6 ff ff       	jmp    80106f80 <alltraps>

80107911 <vector95>:
.globl vector95
vector95:
  pushl $0
80107911:	6a 00                	push   $0x0
  pushl $95
80107913:	6a 5f                	push   $0x5f
  jmp alltraps
80107915:	e9 66 f6 ff ff       	jmp    80106f80 <alltraps>

8010791a <vector96>:
.globl vector96
vector96:
  pushl $0
8010791a:	6a 00                	push   $0x0
  pushl $96
8010791c:	6a 60                	push   $0x60
  jmp alltraps
8010791e:	e9 5d f6 ff ff       	jmp    80106f80 <alltraps>

80107923 <vector97>:
.globl vector97
vector97:
  pushl $0
80107923:	6a 00                	push   $0x0
  pushl $97
80107925:	6a 61                	push   $0x61
  jmp alltraps
80107927:	e9 54 f6 ff ff       	jmp    80106f80 <alltraps>

8010792c <vector98>:
.globl vector98
vector98:
  pushl $0
8010792c:	6a 00                	push   $0x0
  pushl $98
8010792e:	6a 62                	push   $0x62
  jmp alltraps
80107930:	e9 4b f6 ff ff       	jmp    80106f80 <alltraps>

80107935 <vector99>:
.globl vector99
vector99:
  pushl $0
80107935:	6a 00                	push   $0x0
  pushl $99
80107937:	6a 63                	push   $0x63
  jmp alltraps
80107939:	e9 42 f6 ff ff       	jmp    80106f80 <alltraps>

8010793e <vector100>:
.globl vector100
vector100:
  pushl $0
8010793e:	6a 00                	push   $0x0
  pushl $100
80107940:	6a 64                	push   $0x64
  jmp alltraps
80107942:	e9 39 f6 ff ff       	jmp    80106f80 <alltraps>

80107947 <vector101>:
.globl vector101
vector101:
  pushl $0
80107947:	6a 00                	push   $0x0
  pushl $101
80107949:	6a 65                	push   $0x65
  jmp alltraps
8010794b:	e9 30 f6 ff ff       	jmp    80106f80 <alltraps>

80107950 <vector102>:
.globl vector102
vector102:
  pushl $0
80107950:	6a 00                	push   $0x0
  pushl $102
80107952:	6a 66                	push   $0x66
  jmp alltraps
80107954:	e9 27 f6 ff ff       	jmp    80106f80 <alltraps>

80107959 <vector103>:
.globl vector103
vector103:
  pushl $0
80107959:	6a 00                	push   $0x0
  pushl $103
8010795b:	6a 67                	push   $0x67
  jmp alltraps
8010795d:	e9 1e f6 ff ff       	jmp    80106f80 <alltraps>

80107962 <vector104>:
.globl vector104
vector104:
  pushl $0
80107962:	6a 00                	push   $0x0
  pushl $104
80107964:	6a 68                	push   $0x68
  jmp alltraps
80107966:	e9 15 f6 ff ff       	jmp    80106f80 <alltraps>

8010796b <vector105>:
.globl vector105
vector105:
  pushl $0
8010796b:	6a 00                	push   $0x0
  pushl $105
8010796d:	6a 69                	push   $0x69
  jmp alltraps
8010796f:	e9 0c f6 ff ff       	jmp    80106f80 <alltraps>

80107974 <vector106>:
.globl vector106
vector106:
  pushl $0
80107974:	6a 00                	push   $0x0
  pushl $106
80107976:	6a 6a                	push   $0x6a
  jmp alltraps
80107978:	e9 03 f6 ff ff       	jmp    80106f80 <alltraps>

8010797d <vector107>:
.globl vector107
vector107:
  pushl $0
8010797d:	6a 00                	push   $0x0
  pushl $107
8010797f:	6a 6b                	push   $0x6b
  jmp alltraps
80107981:	e9 fa f5 ff ff       	jmp    80106f80 <alltraps>

80107986 <vector108>:
.globl vector108
vector108:
  pushl $0
80107986:	6a 00                	push   $0x0
  pushl $108
80107988:	6a 6c                	push   $0x6c
  jmp alltraps
8010798a:	e9 f1 f5 ff ff       	jmp    80106f80 <alltraps>

8010798f <vector109>:
.globl vector109
vector109:
  pushl $0
8010798f:	6a 00                	push   $0x0
  pushl $109
80107991:	6a 6d                	push   $0x6d
  jmp alltraps
80107993:	e9 e8 f5 ff ff       	jmp    80106f80 <alltraps>

80107998 <vector110>:
.globl vector110
vector110:
  pushl $0
80107998:	6a 00                	push   $0x0
  pushl $110
8010799a:	6a 6e                	push   $0x6e
  jmp alltraps
8010799c:	e9 df f5 ff ff       	jmp    80106f80 <alltraps>

801079a1 <vector111>:
.globl vector111
vector111:
  pushl $0
801079a1:	6a 00                	push   $0x0
  pushl $111
801079a3:	6a 6f                	push   $0x6f
  jmp alltraps
801079a5:	e9 d6 f5 ff ff       	jmp    80106f80 <alltraps>

801079aa <vector112>:
.globl vector112
vector112:
  pushl $0
801079aa:	6a 00                	push   $0x0
  pushl $112
801079ac:	6a 70                	push   $0x70
  jmp alltraps
801079ae:	e9 cd f5 ff ff       	jmp    80106f80 <alltraps>

801079b3 <vector113>:
.globl vector113
vector113:
  pushl $0
801079b3:	6a 00                	push   $0x0
  pushl $113
801079b5:	6a 71                	push   $0x71
  jmp alltraps
801079b7:	e9 c4 f5 ff ff       	jmp    80106f80 <alltraps>

801079bc <vector114>:
.globl vector114
vector114:
  pushl $0
801079bc:	6a 00                	push   $0x0
  pushl $114
801079be:	6a 72                	push   $0x72
  jmp alltraps
801079c0:	e9 bb f5 ff ff       	jmp    80106f80 <alltraps>

801079c5 <vector115>:
.globl vector115
vector115:
  pushl $0
801079c5:	6a 00                	push   $0x0
  pushl $115
801079c7:	6a 73                	push   $0x73
  jmp alltraps
801079c9:	e9 b2 f5 ff ff       	jmp    80106f80 <alltraps>

801079ce <vector116>:
.globl vector116
vector116:
  pushl $0
801079ce:	6a 00                	push   $0x0
  pushl $116
801079d0:	6a 74                	push   $0x74
  jmp alltraps
801079d2:	e9 a9 f5 ff ff       	jmp    80106f80 <alltraps>

801079d7 <vector117>:
.globl vector117
vector117:
  pushl $0
801079d7:	6a 00                	push   $0x0
  pushl $117
801079d9:	6a 75                	push   $0x75
  jmp alltraps
801079db:	e9 a0 f5 ff ff       	jmp    80106f80 <alltraps>

801079e0 <vector118>:
.globl vector118
vector118:
  pushl $0
801079e0:	6a 00                	push   $0x0
  pushl $118
801079e2:	6a 76                	push   $0x76
  jmp alltraps
801079e4:	e9 97 f5 ff ff       	jmp    80106f80 <alltraps>

801079e9 <vector119>:
.globl vector119
vector119:
  pushl $0
801079e9:	6a 00                	push   $0x0
  pushl $119
801079eb:	6a 77                	push   $0x77
  jmp alltraps
801079ed:	e9 8e f5 ff ff       	jmp    80106f80 <alltraps>

801079f2 <vector120>:
.globl vector120
vector120:
  pushl $0
801079f2:	6a 00                	push   $0x0
  pushl $120
801079f4:	6a 78                	push   $0x78
  jmp alltraps
801079f6:	e9 85 f5 ff ff       	jmp    80106f80 <alltraps>

801079fb <vector121>:
.globl vector121
vector121:
  pushl $0
801079fb:	6a 00                	push   $0x0
  pushl $121
801079fd:	6a 79                	push   $0x79
  jmp alltraps
801079ff:	e9 7c f5 ff ff       	jmp    80106f80 <alltraps>

80107a04 <vector122>:
.globl vector122
vector122:
  pushl $0
80107a04:	6a 00                	push   $0x0
  pushl $122
80107a06:	6a 7a                	push   $0x7a
  jmp alltraps
80107a08:	e9 73 f5 ff ff       	jmp    80106f80 <alltraps>

80107a0d <vector123>:
.globl vector123
vector123:
  pushl $0
80107a0d:	6a 00                	push   $0x0
  pushl $123
80107a0f:	6a 7b                	push   $0x7b
  jmp alltraps
80107a11:	e9 6a f5 ff ff       	jmp    80106f80 <alltraps>

80107a16 <vector124>:
.globl vector124
vector124:
  pushl $0
80107a16:	6a 00                	push   $0x0
  pushl $124
80107a18:	6a 7c                	push   $0x7c
  jmp alltraps
80107a1a:	e9 61 f5 ff ff       	jmp    80106f80 <alltraps>

80107a1f <vector125>:
.globl vector125
vector125:
  pushl $0
80107a1f:	6a 00                	push   $0x0
  pushl $125
80107a21:	6a 7d                	push   $0x7d
  jmp alltraps
80107a23:	e9 58 f5 ff ff       	jmp    80106f80 <alltraps>

80107a28 <vector126>:
.globl vector126
vector126:
  pushl $0
80107a28:	6a 00                	push   $0x0
  pushl $126
80107a2a:	6a 7e                	push   $0x7e
  jmp alltraps
80107a2c:	e9 4f f5 ff ff       	jmp    80106f80 <alltraps>

80107a31 <vector127>:
.globl vector127
vector127:
  pushl $0
80107a31:	6a 00                	push   $0x0
  pushl $127
80107a33:	6a 7f                	push   $0x7f
  jmp alltraps
80107a35:	e9 46 f5 ff ff       	jmp    80106f80 <alltraps>

80107a3a <vector128>:
.globl vector128
vector128:
  pushl $0
80107a3a:	6a 00                	push   $0x0
  pushl $128
80107a3c:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107a41:	e9 3a f5 ff ff       	jmp    80106f80 <alltraps>

80107a46 <vector129>:
.globl vector129
vector129:
  pushl $0
80107a46:	6a 00                	push   $0x0
  pushl $129
80107a48:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107a4d:	e9 2e f5 ff ff       	jmp    80106f80 <alltraps>

80107a52 <vector130>:
.globl vector130
vector130:
  pushl $0
80107a52:	6a 00                	push   $0x0
  pushl $130
80107a54:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107a59:	e9 22 f5 ff ff       	jmp    80106f80 <alltraps>

80107a5e <vector131>:
.globl vector131
vector131:
  pushl $0
80107a5e:	6a 00                	push   $0x0
  pushl $131
80107a60:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107a65:	e9 16 f5 ff ff       	jmp    80106f80 <alltraps>

80107a6a <vector132>:
.globl vector132
vector132:
  pushl $0
80107a6a:	6a 00                	push   $0x0
  pushl $132
80107a6c:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107a71:	e9 0a f5 ff ff       	jmp    80106f80 <alltraps>

80107a76 <vector133>:
.globl vector133
vector133:
  pushl $0
80107a76:	6a 00                	push   $0x0
  pushl $133
80107a78:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107a7d:	e9 fe f4 ff ff       	jmp    80106f80 <alltraps>

80107a82 <vector134>:
.globl vector134
vector134:
  pushl $0
80107a82:	6a 00                	push   $0x0
  pushl $134
80107a84:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107a89:	e9 f2 f4 ff ff       	jmp    80106f80 <alltraps>

80107a8e <vector135>:
.globl vector135
vector135:
  pushl $0
80107a8e:	6a 00                	push   $0x0
  pushl $135
80107a90:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107a95:	e9 e6 f4 ff ff       	jmp    80106f80 <alltraps>

80107a9a <vector136>:
.globl vector136
vector136:
  pushl $0
80107a9a:	6a 00                	push   $0x0
  pushl $136
80107a9c:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107aa1:	e9 da f4 ff ff       	jmp    80106f80 <alltraps>

80107aa6 <vector137>:
.globl vector137
vector137:
  pushl $0
80107aa6:	6a 00                	push   $0x0
  pushl $137
80107aa8:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107aad:	e9 ce f4 ff ff       	jmp    80106f80 <alltraps>

80107ab2 <vector138>:
.globl vector138
vector138:
  pushl $0
80107ab2:	6a 00                	push   $0x0
  pushl $138
80107ab4:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107ab9:	e9 c2 f4 ff ff       	jmp    80106f80 <alltraps>

80107abe <vector139>:
.globl vector139
vector139:
  pushl $0
80107abe:	6a 00                	push   $0x0
  pushl $139
80107ac0:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107ac5:	e9 b6 f4 ff ff       	jmp    80106f80 <alltraps>

80107aca <vector140>:
.globl vector140
vector140:
  pushl $0
80107aca:	6a 00                	push   $0x0
  pushl $140
80107acc:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107ad1:	e9 aa f4 ff ff       	jmp    80106f80 <alltraps>

80107ad6 <vector141>:
.globl vector141
vector141:
  pushl $0
80107ad6:	6a 00                	push   $0x0
  pushl $141
80107ad8:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107add:	e9 9e f4 ff ff       	jmp    80106f80 <alltraps>

80107ae2 <vector142>:
.globl vector142
vector142:
  pushl $0
80107ae2:	6a 00                	push   $0x0
  pushl $142
80107ae4:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107ae9:	e9 92 f4 ff ff       	jmp    80106f80 <alltraps>

80107aee <vector143>:
.globl vector143
vector143:
  pushl $0
80107aee:	6a 00                	push   $0x0
  pushl $143
80107af0:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107af5:	e9 86 f4 ff ff       	jmp    80106f80 <alltraps>

80107afa <vector144>:
.globl vector144
vector144:
  pushl $0
80107afa:	6a 00                	push   $0x0
  pushl $144
80107afc:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107b01:	e9 7a f4 ff ff       	jmp    80106f80 <alltraps>

80107b06 <vector145>:
.globl vector145
vector145:
  pushl $0
80107b06:	6a 00                	push   $0x0
  pushl $145
80107b08:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107b0d:	e9 6e f4 ff ff       	jmp    80106f80 <alltraps>

80107b12 <vector146>:
.globl vector146
vector146:
  pushl $0
80107b12:	6a 00                	push   $0x0
  pushl $146
80107b14:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107b19:	e9 62 f4 ff ff       	jmp    80106f80 <alltraps>

80107b1e <vector147>:
.globl vector147
vector147:
  pushl $0
80107b1e:	6a 00                	push   $0x0
  pushl $147
80107b20:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107b25:	e9 56 f4 ff ff       	jmp    80106f80 <alltraps>

80107b2a <vector148>:
.globl vector148
vector148:
  pushl $0
80107b2a:	6a 00                	push   $0x0
  pushl $148
80107b2c:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107b31:	e9 4a f4 ff ff       	jmp    80106f80 <alltraps>

80107b36 <vector149>:
.globl vector149
vector149:
  pushl $0
80107b36:	6a 00                	push   $0x0
  pushl $149
80107b38:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107b3d:	e9 3e f4 ff ff       	jmp    80106f80 <alltraps>

80107b42 <vector150>:
.globl vector150
vector150:
  pushl $0
80107b42:	6a 00                	push   $0x0
  pushl $150
80107b44:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107b49:	e9 32 f4 ff ff       	jmp    80106f80 <alltraps>

80107b4e <vector151>:
.globl vector151
vector151:
  pushl $0
80107b4e:	6a 00                	push   $0x0
  pushl $151
80107b50:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107b55:	e9 26 f4 ff ff       	jmp    80106f80 <alltraps>

80107b5a <vector152>:
.globl vector152
vector152:
  pushl $0
80107b5a:	6a 00                	push   $0x0
  pushl $152
80107b5c:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107b61:	e9 1a f4 ff ff       	jmp    80106f80 <alltraps>

80107b66 <vector153>:
.globl vector153
vector153:
  pushl $0
80107b66:	6a 00                	push   $0x0
  pushl $153
80107b68:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107b6d:	e9 0e f4 ff ff       	jmp    80106f80 <alltraps>

80107b72 <vector154>:
.globl vector154
vector154:
  pushl $0
80107b72:	6a 00                	push   $0x0
  pushl $154
80107b74:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107b79:	e9 02 f4 ff ff       	jmp    80106f80 <alltraps>

80107b7e <vector155>:
.globl vector155
vector155:
  pushl $0
80107b7e:	6a 00                	push   $0x0
  pushl $155
80107b80:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107b85:	e9 f6 f3 ff ff       	jmp    80106f80 <alltraps>

80107b8a <vector156>:
.globl vector156
vector156:
  pushl $0
80107b8a:	6a 00                	push   $0x0
  pushl $156
80107b8c:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107b91:	e9 ea f3 ff ff       	jmp    80106f80 <alltraps>

80107b96 <vector157>:
.globl vector157
vector157:
  pushl $0
80107b96:	6a 00                	push   $0x0
  pushl $157
80107b98:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107b9d:	e9 de f3 ff ff       	jmp    80106f80 <alltraps>

80107ba2 <vector158>:
.globl vector158
vector158:
  pushl $0
80107ba2:	6a 00                	push   $0x0
  pushl $158
80107ba4:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107ba9:	e9 d2 f3 ff ff       	jmp    80106f80 <alltraps>

80107bae <vector159>:
.globl vector159
vector159:
  pushl $0
80107bae:	6a 00                	push   $0x0
  pushl $159
80107bb0:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107bb5:	e9 c6 f3 ff ff       	jmp    80106f80 <alltraps>

80107bba <vector160>:
.globl vector160
vector160:
  pushl $0
80107bba:	6a 00                	push   $0x0
  pushl $160
80107bbc:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107bc1:	e9 ba f3 ff ff       	jmp    80106f80 <alltraps>

80107bc6 <vector161>:
.globl vector161
vector161:
  pushl $0
80107bc6:	6a 00                	push   $0x0
  pushl $161
80107bc8:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107bcd:	e9 ae f3 ff ff       	jmp    80106f80 <alltraps>

80107bd2 <vector162>:
.globl vector162
vector162:
  pushl $0
80107bd2:	6a 00                	push   $0x0
  pushl $162
80107bd4:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107bd9:	e9 a2 f3 ff ff       	jmp    80106f80 <alltraps>

80107bde <vector163>:
.globl vector163
vector163:
  pushl $0
80107bde:	6a 00                	push   $0x0
  pushl $163
80107be0:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107be5:	e9 96 f3 ff ff       	jmp    80106f80 <alltraps>

80107bea <vector164>:
.globl vector164
vector164:
  pushl $0
80107bea:	6a 00                	push   $0x0
  pushl $164
80107bec:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107bf1:	e9 8a f3 ff ff       	jmp    80106f80 <alltraps>

80107bf6 <vector165>:
.globl vector165
vector165:
  pushl $0
80107bf6:	6a 00                	push   $0x0
  pushl $165
80107bf8:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107bfd:	e9 7e f3 ff ff       	jmp    80106f80 <alltraps>

80107c02 <vector166>:
.globl vector166
vector166:
  pushl $0
80107c02:	6a 00                	push   $0x0
  pushl $166
80107c04:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107c09:	e9 72 f3 ff ff       	jmp    80106f80 <alltraps>

80107c0e <vector167>:
.globl vector167
vector167:
  pushl $0
80107c0e:	6a 00                	push   $0x0
  pushl $167
80107c10:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107c15:	e9 66 f3 ff ff       	jmp    80106f80 <alltraps>

80107c1a <vector168>:
.globl vector168
vector168:
  pushl $0
80107c1a:	6a 00                	push   $0x0
  pushl $168
80107c1c:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107c21:	e9 5a f3 ff ff       	jmp    80106f80 <alltraps>

80107c26 <vector169>:
.globl vector169
vector169:
  pushl $0
80107c26:	6a 00                	push   $0x0
  pushl $169
80107c28:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107c2d:	e9 4e f3 ff ff       	jmp    80106f80 <alltraps>

80107c32 <vector170>:
.globl vector170
vector170:
  pushl $0
80107c32:	6a 00                	push   $0x0
  pushl $170
80107c34:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107c39:	e9 42 f3 ff ff       	jmp    80106f80 <alltraps>

80107c3e <vector171>:
.globl vector171
vector171:
  pushl $0
80107c3e:	6a 00                	push   $0x0
  pushl $171
80107c40:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107c45:	e9 36 f3 ff ff       	jmp    80106f80 <alltraps>

80107c4a <vector172>:
.globl vector172
vector172:
  pushl $0
80107c4a:	6a 00                	push   $0x0
  pushl $172
80107c4c:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107c51:	e9 2a f3 ff ff       	jmp    80106f80 <alltraps>

80107c56 <vector173>:
.globl vector173
vector173:
  pushl $0
80107c56:	6a 00                	push   $0x0
  pushl $173
80107c58:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107c5d:	e9 1e f3 ff ff       	jmp    80106f80 <alltraps>

80107c62 <vector174>:
.globl vector174
vector174:
  pushl $0
80107c62:	6a 00                	push   $0x0
  pushl $174
80107c64:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107c69:	e9 12 f3 ff ff       	jmp    80106f80 <alltraps>

80107c6e <vector175>:
.globl vector175
vector175:
  pushl $0
80107c6e:	6a 00                	push   $0x0
  pushl $175
80107c70:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107c75:	e9 06 f3 ff ff       	jmp    80106f80 <alltraps>

80107c7a <vector176>:
.globl vector176
vector176:
  pushl $0
80107c7a:	6a 00                	push   $0x0
  pushl $176
80107c7c:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107c81:	e9 fa f2 ff ff       	jmp    80106f80 <alltraps>

80107c86 <vector177>:
.globl vector177
vector177:
  pushl $0
80107c86:	6a 00                	push   $0x0
  pushl $177
80107c88:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107c8d:	e9 ee f2 ff ff       	jmp    80106f80 <alltraps>

80107c92 <vector178>:
.globl vector178
vector178:
  pushl $0
80107c92:	6a 00                	push   $0x0
  pushl $178
80107c94:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107c99:	e9 e2 f2 ff ff       	jmp    80106f80 <alltraps>

80107c9e <vector179>:
.globl vector179
vector179:
  pushl $0
80107c9e:	6a 00                	push   $0x0
  pushl $179
80107ca0:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107ca5:	e9 d6 f2 ff ff       	jmp    80106f80 <alltraps>

80107caa <vector180>:
.globl vector180
vector180:
  pushl $0
80107caa:	6a 00                	push   $0x0
  pushl $180
80107cac:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107cb1:	e9 ca f2 ff ff       	jmp    80106f80 <alltraps>

80107cb6 <vector181>:
.globl vector181
vector181:
  pushl $0
80107cb6:	6a 00                	push   $0x0
  pushl $181
80107cb8:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107cbd:	e9 be f2 ff ff       	jmp    80106f80 <alltraps>

80107cc2 <vector182>:
.globl vector182
vector182:
  pushl $0
80107cc2:	6a 00                	push   $0x0
  pushl $182
80107cc4:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107cc9:	e9 b2 f2 ff ff       	jmp    80106f80 <alltraps>

80107cce <vector183>:
.globl vector183
vector183:
  pushl $0
80107cce:	6a 00                	push   $0x0
  pushl $183
80107cd0:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107cd5:	e9 a6 f2 ff ff       	jmp    80106f80 <alltraps>

80107cda <vector184>:
.globl vector184
vector184:
  pushl $0
80107cda:	6a 00                	push   $0x0
  pushl $184
80107cdc:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107ce1:	e9 9a f2 ff ff       	jmp    80106f80 <alltraps>

80107ce6 <vector185>:
.globl vector185
vector185:
  pushl $0
80107ce6:	6a 00                	push   $0x0
  pushl $185
80107ce8:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107ced:	e9 8e f2 ff ff       	jmp    80106f80 <alltraps>

80107cf2 <vector186>:
.globl vector186
vector186:
  pushl $0
80107cf2:	6a 00                	push   $0x0
  pushl $186
80107cf4:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107cf9:	e9 82 f2 ff ff       	jmp    80106f80 <alltraps>

80107cfe <vector187>:
.globl vector187
vector187:
  pushl $0
80107cfe:	6a 00                	push   $0x0
  pushl $187
80107d00:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107d05:	e9 76 f2 ff ff       	jmp    80106f80 <alltraps>

80107d0a <vector188>:
.globl vector188
vector188:
  pushl $0
80107d0a:	6a 00                	push   $0x0
  pushl $188
80107d0c:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107d11:	e9 6a f2 ff ff       	jmp    80106f80 <alltraps>

80107d16 <vector189>:
.globl vector189
vector189:
  pushl $0
80107d16:	6a 00                	push   $0x0
  pushl $189
80107d18:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107d1d:	e9 5e f2 ff ff       	jmp    80106f80 <alltraps>

80107d22 <vector190>:
.globl vector190
vector190:
  pushl $0
80107d22:	6a 00                	push   $0x0
  pushl $190
80107d24:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107d29:	e9 52 f2 ff ff       	jmp    80106f80 <alltraps>

80107d2e <vector191>:
.globl vector191
vector191:
  pushl $0
80107d2e:	6a 00                	push   $0x0
  pushl $191
80107d30:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107d35:	e9 46 f2 ff ff       	jmp    80106f80 <alltraps>

80107d3a <vector192>:
.globl vector192
vector192:
  pushl $0
80107d3a:	6a 00                	push   $0x0
  pushl $192
80107d3c:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107d41:	e9 3a f2 ff ff       	jmp    80106f80 <alltraps>

80107d46 <vector193>:
.globl vector193
vector193:
  pushl $0
80107d46:	6a 00                	push   $0x0
  pushl $193
80107d48:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107d4d:	e9 2e f2 ff ff       	jmp    80106f80 <alltraps>

80107d52 <vector194>:
.globl vector194
vector194:
  pushl $0
80107d52:	6a 00                	push   $0x0
  pushl $194
80107d54:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107d59:	e9 22 f2 ff ff       	jmp    80106f80 <alltraps>

80107d5e <vector195>:
.globl vector195
vector195:
  pushl $0
80107d5e:	6a 00                	push   $0x0
  pushl $195
80107d60:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107d65:	e9 16 f2 ff ff       	jmp    80106f80 <alltraps>

80107d6a <vector196>:
.globl vector196
vector196:
  pushl $0
80107d6a:	6a 00                	push   $0x0
  pushl $196
80107d6c:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107d71:	e9 0a f2 ff ff       	jmp    80106f80 <alltraps>

80107d76 <vector197>:
.globl vector197
vector197:
  pushl $0
80107d76:	6a 00                	push   $0x0
  pushl $197
80107d78:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107d7d:	e9 fe f1 ff ff       	jmp    80106f80 <alltraps>

80107d82 <vector198>:
.globl vector198
vector198:
  pushl $0
80107d82:	6a 00                	push   $0x0
  pushl $198
80107d84:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107d89:	e9 f2 f1 ff ff       	jmp    80106f80 <alltraps>

80107d8e <vector199>:
.globl vector199
vector199:
  pushl $0
80107d8e:	6a 00                	push   $0x0
  pushl $199
80107d90:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107d95:	e9 e6 f1 ff ff       	jmp    80106f80 <alltraps>

80107d9a <vector200>:
.globl vector200
vector200:
  pushl $0
80107d9a:	6a 00                	push   $0x0
  pushl $200
80107d9c:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107da1:	e9 da f1 ff ff       	jmp    80106f80 <alltraps>

80107da6 <vector201>:
.globl vector201
vector201:
  pushl $0
80107da6:	6a 00                	push   $0x0
  pushl $201
80107da8:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107dad:	e9 ce f1 ff ff       	jmp    80106f80 <alltraps>

80107db2 <vector202>:
.globl vector202
vector202:
  pushl $0
80107db2:	6a 00                	push   $0x0
  pushl $202
80107db4:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107db9:	e9 c2 f1 ff ff       	jmp    80106f80 <alltraps>

80107dbe <vector203>:
.globl vector203
vector203:
  pushl $0
80107dbe:	6a 00                	push   $0x0
  pushl $203
80107dc0:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107dc5:	e9 b6 f1 ff ff       	jmp    80106f80 <alltraps>

80107dca <vector204>:
.globl vector204
vector204:
  pushl $0
80107dca:	6a 00                	push   $0x0
  pushl $204
80107dcc:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107dd1:	e9 aa f1 ff ff       	jmp    80106f80 <alltraps>

80107dd6 <vector205>:
.globl vector205
vector205:
  pushl $0
80107dd6:	6a 00                	push   $0x0
  pushl $205
80107dd8:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107ddd:	e9 9e f1 ff ff       	jmp    80106f80 <alltraps>

80107de2 <vector206>:
.globl vector206
vector206:
  pushl $0
80107de2:	6a 00                	push   $0x0
  pushl $206
80107de4:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107de9:	e9 92 f1 ff ff       	jmp    80106f80 <alltraps>

80107dee <vector207>:
.globl vector207
vector207:
  pushl $0
80107dee:	6a 00                	push   $0x0
  pushl $207
80107df0:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107df5:	e9 86 f1 ff ff       	jmp    80106f80 <alltraps>

80107dfa <vector208>:
.globl vector208
vector208:
  pushl $0
80107dfa:	6a 00                	push   $0x0
  pushl $208
80107dfc:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107e01:	e9 7a f1 ff ff       	jmp    80106f80 <alltraps>

80107e06 <vector209>:
.globl vector209
vector209:
  pushl $0
80107e06:	6a 00                	push   $0x0
  pushl $209
80107e08:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107e0d:	e9 6e f1 ff ff       	jmp    80106f80 <alltraps>

80107e12 <vector210>:
.globl vector210
vector210:
  pushl $0
80107e12:	6a 00                	push   $0x0
  pushl $210
80107e14:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107e19:	e9 62 f1 ff ff       	jmp    80106f80 <alltraps>

80107e1e <vector211>:
.globl vector211
vector211:
  pushl $0
80107e1e:	6a 00                	push   $0x0
  pushl $211
80107e20:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107e25:	e9 56 f1 ff ff       	jmp    80106f80 <alltraps>

80107e2a <vector212>:
.globl vector212
vector212:
  pushl $0
80107e2a:	6a 00                	push   $0x0
  pushl $212
80107e2c:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107e31:	e9 4a f1 ff ff       	jmp    80106f80 <alltraps>

80107e36 <vector213>:
.globl vector213
vector213:
  pushl $0
80107e36:	6a 00                	push   $0x0
  pushl $213
80107e38:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107e3d:	e9 3e f1 ff ff       	jmp    80106f80 <alltraps>

80107e42 <vector214>:
.globl vector214
vector214:
  pushl $0
80107e42:	6a 00                	push   $0x0
  pushl $214
80107e44:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107e49:	e9 32 f1 ff ff       	jmp    80106f80 <alltraps>

80107e4e <vector215>:
.globl vector215
vector215:
  pushl $0
80107e4e:	6a 00                	push   $0x0
  pushl $215
80107e50:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107e55:	e9 26 f1 ff ff       	jmp    80106f80 <alltraps>

80107e5a <vector216>:
.globl vector216
vector216:
  pushl $0
80107e5a:	6a 00                	push   $0x0
  pushl $216
80107e5c:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107e61:	e9 1a f1 ff ff       	jmp    80106f80 <alltraps>

80107e66 <vector217>:
.globl vector217
vector217:
  pushl $0
80107e66:	6a 00                	push   $0x0
  pushl $217
80107e68:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107e6d:	e9 0e f1 ff ff       	jmp    80106f80 <alltraps>

80107e72 <vector218>:
.globl vector218
vector218:
  pushl $0
80107e72:	6a 00                	push   $0x0
  pushl $218
80107e74:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107e79:	e9 02 f1 ff ff       	jmp    80106f80 <alltraps>

80107e7e <vector219>:
.globl vector219
vector219:
  pushl $0
80107e7e:	6a 00                	push   $0x0
  pushl $219
80107e80:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107e85:	e9 f6 f0 ff ff       	jmp    80106f80 <alltraps>

80107e8a <vector220>:
.globl vector220
vector220:
  pushl $0
80107e8a:	6a 00                	push   $0x0
  pushl $220
80107e8c:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107e91:	e9 ea f0 ff ff       	jmp    80106f80 <alltraps>

80107e96 <vector221>:
.globl vector221
vector221:
  pushl $0
80107e96:	6a 00                	push   $0x0
  pushl $221
80107e98:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107e9d:	e9 de f0 ff ff       	jmp    80106f80 <alltraps>

80107ea2 <vector222>:
.globl vector222
vector222:
  pushl $0
80107ea2:	6a 00                	push   $0x0
  pushl $222
80107ea4:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107ea9:	e9 d2 f0 ff ff       	jmp    80106f80 <alltraps>

80107eae <vector223>:
.globl vector223
vector223:
  pushl $0
80107eae:	6a 00                	push   $0x0
  pushl $223
80107eb0:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107eb5:	e9 c6 f0 ff ff       	jmp    80106f80 <alltraps>

80107eba <vector224>:
.globl vector224
vector224:
  pushl $0
80107eba:	6a 00                	push   $0x0
  pushl $224
80107ebc:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107ec1:	e9 ba f0 ff ff       	jmp    80106f80 <alltraps>

80107ec6 <vector225>:
.globl vector225
vector225:
  pushl $0
80107ec6:	6a 00                	push   $0x0
  pushl $225
80107ec8:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107ecd:	e9 ae f0 ff ff       	jmp    80106f80 <alltraps>

80107ed2 <vector226>:
.globl vector226
vector226:
  pushl $0
80107ed2:	6a 00                	push   $0x0
  pushl $226
80107ed4:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107ed9:	e9 a2 f0 ff ff       	jmp    80106f80 <alltraps>

80107ede <vector227>:
.globl vector227
vector227:
  pushl $0
80107ede:	6a 00                	push   $0x0
  pushl $227
80107ee0:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107ee5:	e9 96 f0 ff ff       	jmp    80106f80 <alltraps>

80107eea <vector228>:
.globl vector228
vector228:
  pushl $0
80107eea:	6a 00                	push   $0x0
  pushl $228
80107eec:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107ef1:	e9 8a f0 ff ff       	jmp    80106f80 <alltraps>

80107ef6 <vector229>:
.globl vector229
vector229:
  pushl $0
80107ef6:	6a 00                	push   $0x0
  pushl $229
80107ef8:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107efd:	e9 7e f0 ff ff       	jmp    80106f80 <alltraps>

80107f02 <vector230>:
.globl vector230
vector230:
  pushl $0
80107f02:	6a 00                	push   $0x0
  pushl $230
80107f04:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107f09:	e9 72 f0 ff ff       	jmp    80106f80 <alltraps>

80107f0e <vector231>:
.globl vector231
vector231:
  pushl $0
80107f0e:	6a 00                	push   $0x0
  pushl $231
80107f10:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107f15:	e9 66 f0 ff ff       	jmp    80106f80 <alltraps>

80107f1a <vector232>:
.globl vector232
vector232:
  pushl $0
80107f1a:	6a 00                	push   $0x0
  pushl $232
80107f1c:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107f21:	e9 5a f0 ff ff       	jmp    80106f80 <alltraps>

80107f26 <vector233>:
.globl vector233
vector233:
  pushl $0
80107f26:	6a 00                	push   $0x0
  pushl $233
80107f28:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107f2d:	e9 4e f0 ff ff       	jmp    80106f80 <alltraps>

80107f32 <vector234>:
.globl vector234
vector234:
  pushl $0
80107f32:	6a 00                	push   $0x0
  pushl $234
80107f34:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107f39:	e9 42 f0 ff ff       	jmp    80106f80 <alltraps>

80107f3e <vector235>:
.globl vector235
vector235:
  pushl $0
80107f3e:	6a 00                	push   $0x0
  pushl $235
80107f40:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107f45:	e9 36 f0 ff ff       	jmp    80106f80 <alltraps>

80107f4a <vector236>:
.globl vector236
vector236:
  pushl $0
80107f4a:	6a 00                	push   $0x0
  pushl $236
80107f4c:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107f51:	e9 2a f0 ff ff       	jmp    80106f80 <alltraps>

80107f56 <vector237>:
.globl vector237
vector237:
  pushl $0
80107f56:	6a 00                	push   $0x0
  pushl $237
80107f58:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107f5d:	e9 1e f0 ff ff       	jmp    80106f80 <alltraps>

80107f62 <vector238>:
.globl vector238
vector238:
  pushl $0
80107f62:	6a 00                	push   $0x0
  pushl $238
80107f64:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107f69:	e9 12 f0 ff ff       	jmp    80106f80 <alltraps>

80107f6e <vector239>:
.globl vector239
vector239:
  pushl $0
80107f6e:	6a 00                	push   $0x0
  pushl $239
80107f70:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107f75:	e9 06 f0 ff ff       	jmp    80106f80 <alltraps>

80107f7a <vector240>:
.globl vector240
vector240:
  pushl $0
80107f7a:	6a 00                	push   $0x0
  pushl $240
80107f7c:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107f81:	e9 fa ef ff ff       	jmp    80106f80 <alltraps>

80107f86 <vector241>:
.globl vector241
vector241:
  pushl $0
80107f86:	6a 00                	push   $0x0
  pushl $241
80107f88:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107f8d:	e9 ee ef ff ff       	jmp    80106f80 <alltraps>

80107f92 <vector242>:
.globl vector242
vector242:
  pushl $0
80107f92:	6a 00                	push   $0x0
  pushl $242
80107f94:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107f99:	e9 e2 ef ff ff       	jmp    80106f80 <alltraps>

80107f9e <vector243>:
.globl vector243
vector243:
  pushl $0
80107f9e:	6a 00                	push   $0x0
  pushl $243
80107fa0:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107fa5:	e9 d6 ef ff ff       	jmp    80106f80 <alltraps>

80107faa <vector244>:
.globl vector244
vector244:
  pushl $0
80107faa:	6a 00                	push   $0x0
  pushl $244
80107fac:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107fb1:	e9 ca ef ff ff       	jmp    80106f80 <alltraps>

80107fb6 <vector245>:
.globl vector245
vector245:
  pushl $0
80107fb6:	6a 00                	push   $0x0
  pushl $245
80107fb8:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107fbd:	e9 be ef ff ff       	jmp    80106f80 <alltraps>

80107fc2 <vector246>:
.globl vector246
vector246:
  pushl $0
80107fc2:	6a 00                	push   $0x0
  pushl $246
80107fc4:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107fc9:	e9 b2 ef ff ff       	jmp    80106f80 <alltraps>

80107fce <vector247>:
.globl vector247
vector247:
  pushl $0
80107fce:	6a 00                	push   $0x0
  pushl $247
80107fd0:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107fd5:	e9 a6 ef ff ff       	jmp    80106f80 <alltraps>

80107fda <vector248>:
.globl vector248
vector248:
  pushl $0
80107fda:	6a 00                	push   $0x0
  pushl $248
80107fdc:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107fe1:	e9 9a ef ff ff       	jmp    80106f80 <alltraps>

80107fe6 <vector249>:
.globl vector249
vector249:
  pushl $0
80107fe6:	6a 00                	push   $0x0
  pushl $249
80107fe8:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107fed:	e9 8e ef ff ff       	jmp    80106f80 <alltraps>

80107ff2 <vector250>:
.globl vector250
vector250:
  pushl $0
80107ff2:	6a 00                	push   $0x0
  pushl $250
80107ff4:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107ff9:	e9 82 ef ff ff       	jmp    80106f80 <alltraps>

80107ffe <vector251>:
.globl vector251
vector251:
  pushl $0
80107ffe:	6a 00                	push   $0x0
  pushl $251
80108000:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108005:	e9 76 ef ff ff       	jmp    80106f80 <alltraps>

8010800a <vector252>:
.globl vector252
vector252:
  pushl $0
8010800a:	6a 00                	push   $0x0
  pushl $252
8010800c:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80108011:	e9 6a ef ff ff       	jmp    80106f80 <alltraps>

80108016 <vector253>:
.globl vector253
vector253:
  pushl $0
80108016:	6a 00                	push   $0x0
  pushl $253
80108018:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010801d:	e9 5e ef ff ff       	jmp    80106f80 <alltraps>

80108022 <vector254>:
.globl vector254
vector254:
  pushl $0
80108022:	6a 00                	push   $0x0
  pushl $254
80108024:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80108029:	e9 52 ef ff ff       	jmp    80106f80 <alltraps>

8010802e <vector255>:
.globl vector255
vector255:
  pushl $0
8010802e:	6a 00                	push   $0x0
  pushl $255
80108030:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108035:	e9 46 ef ff ff       	jmp    80106f80 <alltraps>
	...

8010803c <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
8010803c:	55                   	push   %ebp
8010803d:	89 e5                	mov    %esp,%ebp
8010803f:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80108042:	8b 45 0c             	mov    0xc(%ebp),%eax
80108045:	48                   	dec    %eax
80108046:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010804a:	8b 45 08             	mov    0x8(%ebp),%eax
8010804d:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80108051:	8b 45 08             	mov    0x8(%ebp),%eax
80108054:	c1 e8 10             	shr    $0x10,%eax
80108057:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
8010805b:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010805e:	0f 01 10             	lgdtl  (%eax)
}
80108061:	c9                   	leave  
80108062:	c3                   	ret    

80108063 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80108063:	55                   	push   %ebp
80108064:	89 e5                	mov    %esp,%ebp
80108066:	83 ec 04             	sub    $0x4,%esp
80108069:	8b 45 08             	mov    0x8(%ebp),%eax
8010806c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80108070:	8b 45 fc             	mov    -0x4(%ebp),%eax
80108073:	0f 00 d8             	ltr    %ax
}
80108076:	c9                   	leave  
80108077:	c3                   	ret    

80108078 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80108078:	55                   	push   %ebp
80108079:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010807b:	8b 45 08             	mov    0x8(%ebp),%eax
8010807e:	0f 22 d8             	mov    %eax,%cr3
}
80108081:	5d                   	pop    %ebp
80108082:	c3                   	ret    

80108083 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108083:	55                   	push   %ebp
80108084:	89 e5                	mov    %esp,%ebp
80108086:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80108089:	e8 18 cb ff ff       	call   80104ba6 <cpuid>
8010808e:	89 c2                	mov    %eax,%edx
80108090:	89 d0                	mov    %edx,%eax
80108092:	c1 e0 02             	shl    $0x2,%eax
80108095:	01 d0                	add    %edx,%eax
80108097:	01 c0                	add    %eax,%eax
80108099:	01 d0                	add    %edx,%eax
8010809b:	c1 e0 04             	shl    $0x4,%eax
8010809e:	05 60 49 11 80       	add    $0x80114960,%eax
801080a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801080a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a9:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801080af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b2:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801080b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080bb:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801080bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c2:	8a 50 7d             	mov    0x7d(%eax),%dl
801080c5:	83 e2 f0             	and    $0xfffffff0,%edx
801080c8:	83 ca 0a             	or     $0xa,%edx
801080cb:	88 50 7d             	mov    %dl,0x7d(%eax)
801080ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d1:	8a 50 7d             	mov    0x7d(%eax),%dl
801080d4:	83 ca 10             	or     $0x10,%edx
801080d7:	88 50 7d             	mov    %dl,0x7d(%eax)
801080da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080dd:	8a 50 7d             	mov    0x7d(%eax),%dl
801080e0:	83 e2 9f             	and    $0xffffff9f,%edx
801080e3:	88 50 7d             	mov    %dl,0x7d(%eax)
801080e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e9:	8a 50 7d             	mov    0x7d(%eax),%dl
801080ec:	83 ca 80             	or     $0xffffff80,%edx
801080ef:	88 50 7d             	mov    %dl,0x7d(%eax)
801080f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f5:	8a 50 7e             	mov    0x7e(%eax),%dl
801080f8:	83 ca 0f             	or     $0xf,%edx
801080fb:	88 50 7e             	mov    %dl,0x7e(%eax)
801080fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108101:	8a 50 7e             	mov    0x7e(%eax),%dl
80108104:	83 e2 ef             	and    $0xffffffef,%edx
80108107:	88 50 7e             	mov    %dl,0x7e(%eax)
8010810a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010810d:	8a 50 7e             	mov    0x7e(%eax),%dl
80108110:	83 e2 df             	and    $0xffffffdf,%edx
80108113:	88 50 7e             	mov    %dl,0x7e(%eax)
80108116:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108119:	8a 50 7e             	mov    0x7e(%eax),%dl
8010811c:	83 ca 40             	or     $0x40,%edx
8010811f:	88 50 7e             	mov    %dl,0x7e(%eax)
80108122:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108125:	8a 50 7e             	mov    0x7e(%eax),%dl
80108128:	83 ca 80             	or     $0xffffff80,%edx
8010812b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010812e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108131:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108135:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108138:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010813f:	ff ff 
80108141:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108144:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010814b:	00 00 
8010814d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108150:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108157:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010815a:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108160:	83 e2 f0             	and    $0xfffffff0,%edx
80108163:	83 ca 02             	or     $0x2,%edx
80108166:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010816c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816f:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108175:	83 ca 10             	or     $0x10,%edx
80108178:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010817e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108181:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108187:	83 e2 9f             	and    $0xffffff9f,%edx
8010818a:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108193:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108199:	83 ca 80             	or     $0xffffff80,%edx
8010819c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801081a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a5:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801081ab:	83 ca 0f             	or     $0xf,%edx
801081ae:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801081b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b7:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801081bd:	83 e2 ef             	and    $0xffffffef,%edx
801081c0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801081c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c9:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801081cf:	83 e2 df             	and    $0xffffffdf,%edx
801081d2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801081d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081db:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801081e1:	83 ca 40             	or     $0x40,%edx
801081e4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801081ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ed:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801081f3:	83 ca 80             	or     $0xffffff80,%edx
801081f6:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801081fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ff:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108206:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108209:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80108210:	ff ff 
80108212:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108215:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
8010821c:	00 00 
8010821e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108221:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80108228:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010822b:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108231:	83 e2 f0             	and    $0xfffffff0,%edx
80108234:	83 ca 0a             	or     $0xa,%edx
80108237:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010823d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108240:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108246:	83 ca 10             	or     $0x10,%edx
80108249:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010824f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108252:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108258:	83 ca 60             	or     $0x60,%edx
8010825b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108261:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108264:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
8010826a:	83 ca 80             	or     $0xffffff80,%edx
8010826d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108273:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108276:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010827c:	83 ca 0f             	or     $0xf,%edx
8010827f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108285:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108288:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010828e:	83 e2 ef             	and    $0xffffffef,%edx
80108291:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108297:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010829a:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801082a0:	83 e2 df             	and    $0xffffffdf,%edx
801082a3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801082a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ac:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801082b2:	83 ca 40             	or     $0x40,%edx
801082b5:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801082bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082be:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801082c4:	83 ca 80             	or     $0xffffff80,%edx
801082c7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801082cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d0:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801082d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082da:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801082e1:	ff ff 
801082e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e6:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801082ed:	00 00 
801082ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f2:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801082f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082fc:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80108302:	83 e2 f0             	and    $0xfffffff0,%edx
80108305:	83 ca 02             	or     $0x2,%edx
80108308:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010830e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108311:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80108317:	83 ca 10             	or     $0x10,%edx
8010831a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108323:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80108329:	83 ca 60             	or     $0x60,%edx
8010832c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108332:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108335:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
8010833b:	83 ca 80             	or     $0xffffff80,%edx
8010833e:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108344:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108347:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010834d:	83 ca 0f             	or     $0xf,%edx
80108350:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108359:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010835f:	83 e2 ef             	and    $0xffffffef,%edx
80108362:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010836b:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108371:	83 e2 df             	and    $0xffffffdf,%edx
80108374:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010837a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010837d:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108383:	83 ca 40             	or     $0x40,%edx
80108386:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010838c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010838f:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108395:	83 ca 80             	or     $0xffffff80,%edx
80108398:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010839e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a1:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801083a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ab:	83 c0 70             	add    $0x70,%eax
801083ae:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
801083b5:	00 
801083b6:	89 04 24             	mov    %eax,(%esp)
801083b9:	e8 7e fc ff ff       	call   8010803c <lgdt>
}
801083be:	c9                   	leave  
801083bf:	c3                   	ret    

801083c0 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801083c0:	55                   	push   %ebp
801083c1:	89 e5                	mov    %esp,%ebp
801083c3:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801083c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801083c9:	c1 e8 16             	shr    $0x16,%eax
801083cc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801083d3:	8b 45 08             	mov    0x8(%ebp),%eax
801083d6:	01 d0                	add    %edx,%eax
801083d8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801083db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083de:	8b 00                	mov    (%eax),%eax
801083e0:	83 e0 01             	and    $0x1,%eax
801083e3:	85 c0                	test   %eax,%eax
801083e5:	74 14                	je     801083fb <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801083e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083ea:	8b 00                	mov    (%eax),%eax
801083ec:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083f1:	05 00 00 00 80       	add    $0x80000000,%eax
801083f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801083f9:	eb 48                	jmp    80108443 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801083fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801083ff:	74 0e                	je     8010840f <walkpgdir+0x4f>
80108401:	e8 95 a8 ff ff       	call   80102c9b <kalloc>
80108406:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108409:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010840d:	75 07                	jne    80108416 <walkpgdir+0x56>
      return 0;
8010840f:	b8 00 00 00 00       	mov    $0x0,%eax
80108414:	eb 44                	jmp    8010845a <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108416:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010841d:	00 
8010841e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108425:	00 
80108426:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108429:	89 04 24             	mov    %eax,(%esp)
8010842c:	e8 c5 d3 ff ff       	call   801057f6 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80108431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108434:	05 00 00 00 80       	add    $0x80000000,%eax
80108439:	83 c8 07             	or     $0x7,%eax
8010843c:	89 c2                	mov    %eax,%edx
8010843e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108441:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80108443:	8b 45 0c             	mov    0xc(%ebp),%eax
80108446:	c1 e8 0c             	shr    $0xc,%eax
80108449:	25 ff 03 00 00       	and    $0x3ff,%eax
8010844e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108455:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108458:	01 d0                	add    %edx,%eax
}
8010845a:	c9                   	leave  
8010845b:	c3                   	ret    

8010845c <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
8010845c:	55                   	push   %ebp
8010845d:	89 e5                	mov    %esp,%ebp
8010845f:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80108462:	8b 45 0c             	mov    0xc(%ebp),%eax
80108465:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010846a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
8010846d:	8b 55 0c             	mov    0xc(%ebp),%edx
80108470:	8b 45 10             	mov    0x10(%ebp),%eax
80108473:	01 d0                	add    %edx,%eax
80108475:	48                   	dec    %eax
80108476:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010847b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010847e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108485:	00 
80108486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108489:	89 44 24 04          	mov    %eax,0x4(%esp)
8010848d:	8b 45 08             	mov    0x8(%ebp),%eax
80108490:	89 04 24             	mov    %eax,(%esp)
80108493:	e8 28 ff ff ff       	call   801083c0 <walkpgdir>
80108498:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010849b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010849f:	75 07                	jne    801084a8 <mappages+0x4c>
      return -1;
801084a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801084a6:	eb 48                	jmp    801084f0 <mappages+0x94>
    if(*pte & PTE_P)
801084a8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084ab:	8b 00                	mov    (%eax),%eax
801084ad:	83 e0 01             	and    $0x1,%eax
801084b0:	85 c0                	test   %eax,%eax
801084b2:	74 0c                	je     801084c0 <mappages+0x64>
      panic("remap");
801084b4:	c7 04 24 04 96 10 80 	movl   $0x80109604,(%esp)
801084bb:	e8 94 80 ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
801084c0:	8b 45 18             	mov    0x18(%ebp),%eax
801084c3:	0b 45 14             	or     0x14(%ebp),%eax
801084c6:	83 c8 01             	or     $0x1,%eax
801084c9:	89 c2                	mov    %eax,%edx
801084cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801084ce:	89 10                	mov    %edx,(%eax)
    if(a == last)
801084d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801084d6:	75 08                	jne    801084e0 <mappages+0x84>
      break;
801084d8:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801084d9:	b8 00 00 00 00       	mov    $0x0,%eax
801084de:	eb 10                	jmp    801084f0 <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
801084e0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801084e7:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801084ee:	eb 8e                	jmp    8010847e <mappages+0x22>
  return 0;
}
801084f0:	c9                   	leave  
801084f1:	c3                   	ret    

801084f2 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801084f2:	55                   	push   %ebp
801084f3:	89 e5                	mov    %esp,%ebp
801084f5:	53                   	push   %ebx
801084f6:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801084f9:	e8 9d a7 ff ff       	call   80102c9b <kalloc>
801084fe:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108501:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108505:	75 0a                	jne    80108511 <setupkvm+0x1f>
    return 0;
80108507:	b8 00 00 00 00       	mov    $0x0,%eax
8010850c:	e9 84 00 00 00       	jmp    80108595 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
80108511:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108518:	00 
80108519:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108520:	00 
80108521:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108524:	89 04 24             	mov    %eax,(%esp)
80108527:	e8 ca d2 ff ff       	call   801057f6 <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010852c:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80108533:	eb 54                	jmp    80108589 <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108535:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108538:	8b 48 0c             	mov    0xc(%eax),%ecx
8010853b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853e:	8b 50 04             	mov    0x4(%eax),%edx
80108541:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108544:	8b 58 08             	mov    0x8(%eax),%ebx
80108547:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854a:	8b 40 04             	mov    0x4(%eax),%eax
8010854d:	29 c3                	sub    %eax,%ebx
8010854f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108552:	8b 00                	mov    (%eax),%eax
80108554:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108558:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010855c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80108560:	89 44 24 04          	mov    %eax,0x4(%esp)
80108564:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108567:	89 04 24             	mov    %eax,(%esp)
8010856a:	e8 ed fe ff ff       	call   8010845c <mappages>
8010856f:	85 c0                	test   %eax,%eax
80108571:	79 12                	jns    80108585 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
80108573:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108576:	89 04 24             	mov    %eax,(%esp)
80108579:	e8 1a 05 00 00       	call   80108a98 <freevm>
      return 0;
8010857e:	b8 00 00 00 00       	mov    $0x0,%eax
80108583:	eb 10                	jmp    80108595 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108585:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108589:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
80108590:	72 a3                	jb     80108535 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80108592:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108595:	83 c4 34             	add    $0x34,%esp
80108598:	5b                   	pop    %ebx
80108599:	5d                   	pop    %ebp
8010859a:	c3                   	ret    

8010859b <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010859b:	55                   	push   %ebp
8010859c:	89 e5                	mov    %esp,%ebp
8010859e:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801085a1:	e8 4c ff ff ff       	call   801084f2 <setupkvm>
801085a6:	a3 44 61 12 80       	mov    %eax,0x80126144
  switchkvm();
801085ab:	e8 02 00 00 00       	call   801085b2 <switchkvm>
}
801085b0:	c9                   	leave  
801085b1:	c3                   	ret    

801085b2 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801085b2:	55                   	push   %ebp
801085b3:	89 e5                	mov    %esp,%ebp
801085b5:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801085b8:	a1 44 61 12 80       	mov    0x80126144,%eax
801085bd:	05 00 00 00 80       	add    $0x80000000,%eax
801085c2:	89 04 24             	mov    %eax,(%esp)
801085c5:	e8 ae fa ff ff       	call   80108078 <lcr3>
}
801085ca:	c9                   	leave  
801085cb:	c3                   	ret    

801085cc <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801085cc:	55                   	push   %ebp
801085cd:	89 e5                	mov    %esp,%ebp
801085cf:	57                   	push   %edi
801085d0:	56                   	push   %esi
801085d1:	53                   	push   %ebx
801085d2:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
801085d5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801085d9:	75 0c                	jne    801085e7 <switchuvm+0x1b>
    panic("switchuvm: no process");
801085db:	c7 04 24 0a 96 10 80 	movl   $0x8010960a,(%esp)
801085e2:	e8 6d 7f ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
801085e7:	8b 45 08             	mov    0x8(%ebp),%eax
801085ea:	8b 40 08             	mov    0x8(%eax),%eax
801085ed:	85 c0                	test   %eax,%eax
801085ef:	75 0c                	jne    801085fd <switchuvm+0x31>
    panic("switchuvm: no kstack");
801085f1:	c7 04 24 20 96 10 80 	movl   $0x80109620,(%esp)
801085f8:	e8 57 7f ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
801085fd:	8b 45 08             	mov    0x8(%ebp),%eax
80108600:	8b 40 04             	mov    0x4(%eax),%eax
80108603:	85 c0                	test   %eax,%eax
80108605:	75 0c                	jne    80108613 <switchuvm+0x47>
    panic("switchuvm: no pgdir");
80108607:	c7 04 24 35 96 10 80 	movl   $0x80109635,(%esp)
8010860e:	e8 41 7f ff ff       	call   80100554 <panic>

  pushcli();
80108613:	e8 da d0 ff ff       	call   801056f2 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80108618:	e8 ce c5 ff ff       	call   80104beb <mycpu>
8010861d:	89 c3                	mov    %eax,%ebx
8010861f:	e8 c7 c5 ff ff       	call   80104beb <mycpu>
80108624:	83 c0 08             	add    $0x8,%eax
80108627:	89 c6                	mov    %eax,%esi
80108629:	e8 bd c5 ff ff       	call   80104beb <mycpu>
8010862e:	83 c0 08             	add    $0x8,%eax
80108631:	c1 e8 10             	shr    $0x10,%eax
80108634:	89 c7                	mov    %eax,%edi
80108636:	e8 b0 c5 ff ff       	call   80104beb <mycpu>
8010863b:	83 c0 08             	add    $0x8,%eax
8010863e:	c1 e8 18             	shr    $0x18,%eax
80108641:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108648:	67 00 
8010864a:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
80108651:	89 f9                	mov    %edi,%ecx
80108653:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80108659:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
8010865f:	83 e2 f0             	and    $0xfffffff0,%edx
80108662:	83 ca 09             	or     $0x9,%edx
80108665:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010866b:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108671:	83 ca 10             	or     $0x10,%edx
80108674:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010867a:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108680:	83 e2 9f             	and    $0xffffff9f,%edx
80108683:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108689:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
8010868f:	83 ca 80             	or     $0xffffff80,%edx
80108692:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108698:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
8010869e:	83 e2 f0             	and    $0xfffffff0,%edx
801086a1:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801086a7:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801086ad:	83 e2 ef             	and    $0xffffffef,%edx
801086b0:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801086b6:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801086bc:	83 e2 df             	and    $0xffffffdf,%edx
801086bf:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801086c5:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801086cb:	83 ca 40             	or     $0x40,%edx
801086ce:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801086d4:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801086da:	83 e2 7f             	and    $0x7f,%edx
801086dd:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801086e3:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801086e9:	e8 fd c4 ff ff       	call   80104beb <mycpu>
801086ee:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
801086f4:	83 e2 ef             	and    $0xffffffef,%edx
801086f7:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801086fd:	e8 e9 c4 ff ff       	call   80104beb <mycpu>
80108702:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80108708:	e8 de c4 ff ff       	call   80104beb <mycpu>
8010870d:	8b 55 08             	mov    0x8(%ebp),%edx
80108710:	8b 52 08             	mov    0x8(%edx),%edx
80108713:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108719:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010871c:	e8 ca c4 ff ff       	call   80104beb <mycpu>
80108721:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108727:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
8010872e:	e8 30 f9 ff ff       	call   80108063 <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108733:	8b 45 08             	mov    0x8(%ebp),%eax
80108736:	8b 40 04             	mov    0x4(%eax),%eax
80108739:	05 00 00 00 80       	add    $0x80000000,%eax
8010873e:	89 04 24             	mov    %eax,(%esp)
80108741:	e8 32 f9 ff ff       	call   80108078 <lcr3>
  popcli();
80108746:	e8 f1 cf ff ff       	call   8010573c <popcli>
}
8010874b:	83 c4 1c             	add    $0x1c,%esp
8010874e:	5b                   	pop    %ebx
8010874f:	5e                   	pop    %esi
80108750:	5f                   	pop    %edi
80108751:	5d                   	pop    %ebp
80108752:	c3                   	ret    

80108753 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108753:	55                   	push   %ebp
80108754:	89 e5                	mov    %esp,%ebp
80108756:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80108759:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108760:	76 0c                	jbe    8010876e <inituvm+0x1b>
    panic("inituvm: more than a page");
80108762:	c7 04 24 49 96 10 80 	movl   $0x80109649,(%esp)
80108769:	e8 e6 7d ff ff       	call   80100554 <panic>
  mem = kalloc();
8010876e:	e8 28 a5 ff ff       	call   80102c9b <kalloc>
80108773:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108776:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010877d:	00 
8010877e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108785:	00 
80108786:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108789:	89 04 24             	mov    %eax,(%esp)
8010878c:	e8 65 d0 ff ff       	call   801057f6 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108794:	05 00 00 00 80       	add    $0x80000000,%eax
80108799:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
801087a0:	00 
801087a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
801087a5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801087ac:	00 
801087ad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801087b4:	00 
801087b5:	8b 45 08             	mov    0x8(%ebp),%eax
801087b8:	89 04 24             	mov    %eax,(%esp)
801087bb:	e8 9c fc ff ff       	call   8010845c <mappages>
  memmove(mem, init, sz);
801087c0:	8b 45 10             	mov    0x10(%ebp),%eax
801087c3:	89 44 24 08          	mov    %eax,0x8(%esp)
801087c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801087ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801087ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d1:	89 04 24             	mov    %eax,(%esp)
801087d4:	e8 e6 d0 ff ff       	call   801058bf <memmove>
}
801087d9:	c9                   	leave  
801087da:	c3                   	ret    

801087db <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801087db:	55                   	push   %ebp
801087dc:	89 e5                	mov    %esp,%ebp
801087de:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801087e1:	8b 45 0c             	mov    0xc(%ebp),%eax
801087e4:	25 ff 0f 00 00       	and    $0xfff,%eax
801087e9:	85 c0                	test   %eax,%eax
801087eb:	74 0c                	je     801087f9 <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
801087ed:	c7 04 24 64 96 10 80 	movl   $0x80109664,(%esp)
801087f4:	e8 5b 7d ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801087f9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108800:	e9 a6 00 00 00       	jmp    801088ab <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108805:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108808:	8b 55 0c             	mov    0xc(%ebp),%edx
8010880b:	01 d0                	add    %edx,%eax
8010880d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108814:	00 
80108815:	89 44 24 04          	mov    %eax,0x4(%esp)
80108819:	8b 45 08             	mov    0x8(%ebp),%eax
8010881c:	89 04 24             	mov    %eax,(%esp)
8010881f:	e8 9c fb ff ff       	call   801083c0 <walkpgdir>
80108824:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108827:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010882b:	75 0c                	jne    80108839 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
8010882d:	c7 04 24 87 96 10 80 	movl   $0x80109687,(%esp)
80108834:	e8 1b 7d ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108839:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010883c:	8b 00                	mov    (%eax),%eax
8010883e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108843:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108846:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108849:	8b 55 18             	mov    0x18(%ebp),%edx
8010884c:	29 c2                	sub    %eax,%edx
8010884e:	89 d0                	mov    %edx,%eax
80108850:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108855:	77 0f                	ja     80108866 <loaduvm+0x8b>
      n = sz - i;
80108857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010885a:	8b 55 18             	mov    0x18(%ebp),%edx
8010885d:	29 c2                	sub    %eax,%edx
8010885f:	89 d0                	mov    %edx,%eax
80108861:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108864:	eb 07                	jmp    8010886d <loaduvm+0x92>
    else
      n = PGSIZE;
80108866:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010886d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108870:	8b 55 14             	mov    0x14(%ebp),%edx
80108873:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80108876:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108879:	05 00 00 00 80       	add    $0x80000000,%eax
8010887e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108881:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108885:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80108889:	89 44 24 04          	mov    %eax,0x4(%esp)
8010888d:	8b 45 10             	mov    0x10(%ebp),%eax
80108890:	89 04 24             	mov    %eax,(%esp)
80108893:	e8 25 96 ff ff       	call   80101ebd <readi>
80108898:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010889b:	74 07                	je     801088a4 <loaduvm+0xc9>
      return -1;
8010889d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801088a2:	eb 18                	jmp    801088bc <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801088a4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801088ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ae:	3b 45 18             	cmp    0x18(%ebp),%eax
801088b1:	0f 82 4e ff ff ff    	jb     80108805 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801088b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801088bc:	c9                   	leave  
801088bd:	c3                   	ret    

801088be <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801088be:	55                   	push   %ebp
801088bf:	89 e5                	mov    %esp,%ebp
801088c1:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801088c4:	8b 45 10             	mov    0x10(%ebp),%eax
801088c7:	85 c0                	test   %eax,%eax
801088c9:	79 0a                	jns    801088d5 <allocuvm+0x17>
    return 0;
801088cb:	b8 00 00 00 00       	mov    $0x0,%eax
801088d0:	e9 fd 00 00 00       	jmp    801089d2 <allocuvm+0x114>
  if(newsz < oldsz)
801088d5:	8b 45 10             	mov    0x10(%ebp),%eax
801088d8:	3b 45 0c             	cmp    0xc(%ebp),%eax
801088db:	73 08                	jae    801088e5 <allocuvm+0x27>
    return oldsz;
801088dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801088e0:	e9 ed 00 00 00       	jmp    801089d2 <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
801088e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801088e8:	05 ff 0f 00 00       	add    $0xfff,%eax
801088ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801088f5:	e9 c9 00 00 00       	jmp    801089c3 <allocuvm+0x105>
    mem = kalloc();
801088fa:	e8 9c a3 ff ff       	call   80102c9b <kalloc>
801088ff:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108902:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108906:	75 2f                	jne    80108937 <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
80108908:	c7 04 24 a5 96 10 80 	movl   $0x801096a5,(%esp)
8010890f:	e8 ad 7a ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108914:	8b 45 0c             	mov    0xc(%ebp),%eax
80108917:	89 44 24 08          	mov    %eax,0x8(%esp)
8010891b:	8b 45 10             	mov    0x10(%ebp),%eax
8010891e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108922:	8b 45 08             	mov    0x8(%ebp),%eax
80108925:	89 04 24             	mov    %eax,(%esp)
80108928:	e8 a7 00 00 00       	call   801089d4 <deallocuvm>
      return 0;
8010892d:	b8 00 00 00 00       	mov    $0x0,%eax
80108932:	e9 9b 00 00 00       	jmp    801089d2 <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
80108937:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010893e:	00 
8010893f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108946:	00 
80108947:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010894a:	89 04 24             	mov    %eax,(%esp)
8010894d:	e8 a4 ce ff ff       	call   801057f6 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108952:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108955:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
8010895b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010895e:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108965:	00 
80108966:	89 54 24 0c          	mov    %edx,0xc(%esp)
8010896a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108971:	00 
80108972:	89 44 24 04          	mov    %eax,0x4(%esp)
80108976:	8b 45 08             	mov    0x8(%ebp),%eax
80108979:	89 04 24             	mov    %eax,(%esp)
8010897c:	e8 db fa ff ff       	call   8010845c <mappages>
80108981:	85 c0                	test   %eax,%eax
80108983:	79 37                	jns    801089bc <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80108985:	c7 04 24 bd 96 10 80 	movl   $0x801096bd,(%esp)
8010898c:	e8 30 7a ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108991:	8b 45 0c             	mov    0xc(%ebp),%eax
80108994:	89 44 24 08          	mov    %eax,0x8(%esp)
80108998:	8b 45 10             	mov    0x10(%ebp),%eax
8010899b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010899f:	8b 45 08             	mov    0x8(%ebp),%eax
801089a2:	89 04 24             	mov    %eax,(%esp)
801089a5:	e8 2a 00 00 00       	call   801089d4 <deallocuvm>
      kfree(mem);
801089aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089ad:	89 04 24             	mov    %eax,(%esp)
801089b0:	e8 50 a2 ff ff       	call   80102c05 <kfree>
      return 0;
801089b5:	b8 00 00 00 00       	mov    $0x0,%eax
801089ba:	eb 16                	jmp    801089d2 <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801089bc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801089c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089c6:	3b 45 10             	cmp    0x10(%ebp),%eax
801089c9:	0f 82 2b ff ff ff    	jb     801088fa <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
801089cf:	8b 45 10             	mov    0x10(%ebp),%eax
}
801089d2:	c9                   	leave  
801089d3:	c3                   	ret    

801089d4 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801089d4:	55                   	push   %ebp
801089d5:	89 e5                	mov    %esp,%ebp
801089d7:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801089da:	8b 45 10             	mov    0x10(%ebp),%eax
801089dd:	3b 45 0c             	cmp    0xc(%ebp),%eax
801089e0:	72 08                	jb     801089ea <deallocuvm+0x16>
    return oldsz;
801089e2:	8b 45 0c             	mov    0xc(%ebp),%eax
801089e5:	e9 ac 00 00 00       	jmp    80108a96 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801089ea:	8b 45 10             	mov    0x10(%ebp),%eax
801089ed:	05 ff 0f 00 00       	add    $0xfff,%eax
801089f2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801089fa:	e9 88 00 00 00       	jmp    80108a87 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801089ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a02:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108a09:	00 
80108a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a0e:	8b 45 08             	mov    0x8(%ebp),%eax
80108a11:	89 04 24             	mov    %eax,(%esp)
80108a14:	e8 a7 f9 ff ff       	call   801083c0 <walkpgdir>
80108a19:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108a1c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108a20:	75 14                	jne    80108a36 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a25:	c1 e8 16             	shr    $0x16,%eax
80108a28:	40                   	inc    %eax
80108a29:	c1 e0 16             	shl    $0x16,%eax
80108a2c:	2d 00 10 00 00       	sub    $0x1000,%eax
80108a31:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108a34:	eb 4a                	jmp    80108a80 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80108a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a39:	8b 00                	mov    (%eax),%eax
80108a3b:	83 e0 01             	and    $0x1,%eax
80108a3e:	85 c0                	test   %eax,%eax
80108a40:	74 3e                	je     80108a80 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108a42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a45:	8b 00                	mov    (%eax),%eax
80108a47:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108a4f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108a53:	75 0c                	jne    80108a61 <deallocuvm+0x8d>
        panic("kfree");
80108a55:	c7 04 24 d9 96 10 80 	movl   $0x801096d9,(%esp)
80108a5c:	e8 f3 7a ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80108a61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a64:	05 00 00 00 80       	add    $0x80000000,%eax
80108a69:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108a6c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a6f:	89 04 24             	mov    %eax,(%esp)
80108a72:	e8 8e a1 ff ff       	call   80102c05 <kfree>
      *pte = 0;
80108a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a7a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108a80:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a8a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108a8d:	0f 82 6c ff ff ff    	jb     801089ff <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108a93:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108a96:	c9                   	leave  
80108a97:	c3                   	ret    

80108a98 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108a98:	55                   	push   %ebp
80108a99:	89 e5                	mov    %esp,%ebp
80108a9b:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108a9e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108aa2:	75 0c                	jne    80108ab0 <freevm+0x18>
    panic("freevm: no pgdir");
80108aa4:	c7 04 24 df 96 10 80 	movl   $0x801096df,(%esp)
80108aab:	e8 a4 7a ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108ab0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108ab7:	00 
80108ab8:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108abf:	80 
80108ac0:	8b 45 08             	mov    0x8(%ebp),%eax
80108ac3:	89 04 24             	mov    %eax,(%esp)
80108ac6:	e8 09 ff ff ff       	call   801089d4 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108acb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108ad2:	eb 44                	jmp    80108b18 <freevm+0x80>
    if(pgdir[i] & PTE_P){
80108ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ad7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ade:	8b 45 08             	mov    0x8(%ebp),%eax
80108ae1:	01 d0                	add    %edx,%eax
80108ae3:	8b 00                	mov    (%eax),%eax
80108ae5:	83 e0 01             	and    $0x1,%eax
80108ae8:	85 c0                	test   %eax,%eax
80108aea:	74 29                	je     80108b15 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aef:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108af6:	8b 45 08             	mov    0x8(%ebp),%eax
80108af9:	01 d0                	add    %edx,%eax
80108afb:	8b 00                	mov    (%eax),%eax
80108afd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108b02:	05 00 00 00 80       	add    $0x80000000,%eax
80108b07:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108b0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b0d:	89 04 24             	mov    %eax,(%esp)
80108b10:	e8 f0 a0 ff ff       	call   80102c05 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108b15:	ff 45 f4             	incl   -0xc(%ebp)
80108b18:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108b1f:	76 b3                	jbe    80108ad4 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108b21:	8b 45 08             	mov    0x8(%ebp),%eax
80108b24:	89 04 24             	mov    %eax,(%esp)
80108b27:	e8 d9 a0 ff ff       	call   80102c05 <kfree>
}
80108b2c:	c9                   	leave  
80108b2d:	c3                   	ret    

80108b2e <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108b2e:	55                   	push   %ebp
80108b2f:	89 e5                	mov    %esp,%ebp
80108b31:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108b34:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108b3b:	00 
80108b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b3f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b43:	8b 45 08             	mov    0x8(%ebp),%eax
80108b46:	89 04 24             	mov    %eax,(%esp)
80108b49:	e8 72 f8 ff ff       	call   801083c0 <walkpgdir>
80108b4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108b51:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108b55:	75 0c                	jne    80108b63 <clearpteu+0x35>
    panic("clearpteu");
80108b57:	c7 04 24 f0 96 10 80 	movl   $0x801096f0,(%esp)
80108b5e:	e8 f1 79 ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80108b63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b66:	8b 00                	mov    (%eax),%eax
80108b68:	83 e0 fb             	and    $0xfffffffb,%eax
80108b6b:	89 c2                	mov    %eax,%edx
80108b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b70:	89 10                	mov    %edx,(%eax)
}
80108b72:	c9                   	leave  
80108b73:	c3                   	ret    

80108b74 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108b74:	55                   	push   %ebp
80108b75:	89 e5                	mov    %esp,%ebp
80108b77:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108b7a:	e8 73 f9 ff ff       	call   801084f2 <setupkvm>
80108b7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108b82:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108b86:	75 0a                	jne    80108b92 <copyuvm+0x1e>
    return 0;
80108b88:	b8 00 00 00 00       	mov    $0x0,%eax
80108b8d:	e9 f8 00 00 00       	jmp    80108c8a <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80108b92:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108b99:	e9 cb 00 00 00       	jmp    80108c69 <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108ba8:	00 
80108ba9:	89 44 24 04          	mov    %eax,0x4(%esp)
80108bad:	8b 45 08             	mov    0x8(%ebp),%eax
80108bb0:	89 04 24             	mov    %eax,(%esp)
80108bb3:	e8 08 f8 ff ff       	call   801083c0 <walkpgdir>
80108bb8:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108bbb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108bbf:	75 0c                	jne    80108bcd <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108bc1:	c7 04 24 fa 96 10 80 	movl   $0x801096fa,(%esp)
80108bc8:	e8 87 79 ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
80108bcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bd0:	8b 00                	mov    (%eax),%eax
80108bd2:	83 e0 01             	and    $0x1,%eax
80108bd5:	85 c0                	test   %eax,%eax
80108bd7:	75 0c                	jne    80108be5 <copyuvm+0x71>
      panic("copyuvm: page not present");
80108bd9:	c7 04 24 14 97 10 80 	movl   $0x80109714,(%esp)
80108be0:	e8 6f 79 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108be5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108be8:	8b 00                	mov    (%eax),%eax
80108bea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bef:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108bf2:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bf5:	8b 00                	mov    (%eax),%eax
80108bf7:	25 ff 0f 00 00       	and    $0xfff,%eax
80108bfc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108bff:	e8 97 a0 ff ff       	call   80102c9b <kalloc>
80108c04:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108c07:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108c0b:	75 02                	jne    80108c0f <copyuvm+0x9b>
      goto bad;
80108c0d:	eb 6b                	jmp    80108c7a <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108c0f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c12:	05 00 00 00 80       	add    $0x80000000,%eax
80108c17:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108c1e:	00 
80108c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c23:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c26:	89 04 24             	mov    %eax,(%esp)
80108c29:	e8 91 cc ff ff       	call   801058bf <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108c2e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108c31:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108c34:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108c3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c3d:	89 54 24 10          	mov    %edx,0x10(%esp)
80108c41:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108c45:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108c4c:	00 
80108c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c54:	89 04 24             	mov    %eax,(%esp)
80108c57:	e8 00 f8 ff ff       	call   8010845c <mappages>
80108c5c:	85 c0                	test   %eax,%eax
80108c5e:	79 02                	jns    80108c62 <copyuvm+0xee>
      goto bad;
80108c60:	eb 18                	jmp    80108c7a <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108c62:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108c69:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c6c:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108c6f:	0f 82 29 ff ff ff    	jb     80108b9e <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
80108c75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c78:	eb 10                	jmp    80108c8a <copyuvm+0x116>

bad:
  freevm(d);
80108c7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c7d:	89 04 24             	mov    %eax,(%esp)
80108c80:	e8 13 fe ff ff       	call   80108a98 <freevm>
  return 0;
80108c85:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108c8a:	c9                   	leave  
80108c8b:	c3                   	ret    

80108c8c <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108c8c:	55                   	push   %ebp
80108c8d:	89 e5                	mov    %esp,%ebp
80108c8f:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108c92:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108c99:	00 
80108c9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c9d:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ca1:	8b 45 08             	mov    0x8(%ebp),%eax
80108ca4:	89 04 24             	mov    %eax,(%esp)
80108ca7:	e8 14 f7 ff ff       	call   801083c0 <walkpgdir>
80108cac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cb2:	8b 00                	mov    (%eax),%eax
80108cb4:	83 e0 01             	and    $0x1,%eax
80108cb7:	85 c0                	test   %eax,%eax
80108cb9:	75 07                	jne    80108cc2 <uva2ka+0x36>
    return 0;
80108cbb:	b8 00 00 00 00       	mov    $0x0,%eax
80108cc0:	eb 22                	jmp    80108ce4 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cc5:	8b 00                	mov    (%eax),%eax
80108cc7:	83 e0 04             	and    $0x4,%eax
80108cca:	85 c0                	test   %eax,%eax
80108ccc:	75 07                	jne    80108cd5 <uva2ka+0x49>
    return 0;
80108cce:	b8 00 00 00 00       	mov    $0x0,%eax
80108cd3:	eb 0f                	jmp    80108ce4 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
80108cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cd8:	8b 00                	mov    (%eax),%eax
80108cda:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108cdf:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108ce4:	c9                   	leave  
80108ce5:	c3                   	ret    

80108ce6 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108ce6:	55                   	push   %ebp
80108ce7:	89 e5                	mov    %esp,%ebp
80108ce9:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108cec:	8b 45 10             	mov    0x10(%ebp),%eax
80108cef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108cf2:	e9 87 00 00 00       	jmp    80108d7e <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108cf7:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cfa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108cff:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108d02:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d05:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d09:	8b 45 08             	mov    0x8(%ebp),%eax
80108d0c:	89 04 24             	mov    %eax,(%esp)
80108d0f:	e8 78 ff ff ff       	call   80108c8c <uva2ka>
80108d14:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108d17:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108d1b:	75 07                	jne    80108d24 <copyout+0x3e>
      return -1;
80108d1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108d22:	eb 69                	jmp    80108d8d <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108d24:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d27:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108d2a:	29 c2                	sub    %eax,%edx
80108d2c:	89 d0                	mov    %edx,%eax
80108d2e:	05 00 10 00 00       	add    $0x1000,%eax
80108d33:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108d36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d39:	3b 45 14             	cmp    0x14(%ebp),%eax
80108d3c:	76 06                	jbe    80108d44 <copyout+0x5e>
      n = len;
80108d3e:	8b 45 14             	mov    0x14(%ebp),%eax
80108d41:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108d44:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d47:	8b 55 0c             	mov    0xc(%ebp),%edx
80108d4a:	29 c2                	sub    %eax,%edx
80108d4c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d4f:	01 c2                	add    %eax,%edx
80108d51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d54:	89 44 24 08          	mov    %eax,0x8(%esp)
80108d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d5b:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d5f:	89 14 24             	mov    %edx,(%esp)
80108d62:	e8 58 cb ff ff       	call   801058bf <memmove>
    len -= n;
80108d67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d6a:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108d6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d70:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108d73:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d76:	05 00 10 00 00       	add    $0x1000,%eax
80108d7b:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108d7e:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108d82:	0f 85 6f ff ff ff    	jne    80108cf7 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108d88:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108d8d:	c9                   	leave  
80108d8e:	c3                   	ret    
