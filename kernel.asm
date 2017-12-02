
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
8010002d:	b8 e6 39 10 80       	mov    $0x801039e6,%eax
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
8010003a:	c7 44 24 04 3c 91 10 	movl   $0x8010913c,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 a0 d7 10 80 	movl   $0x8010d7a0,(%esp)
80100049:	e8 d0 58 00 00       	call   8010591e <initlock>

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
80100087:	c7 44 24 04 43 91 10 	movl   $0x80109143,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 49 57 00 00       	call   801057e0 <initsleeplock>
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
801000c9:	e8 71 58 00 00       	call   8010593f <acquire>

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
80100104:	e8 a0 58 00 00       	call   801059a9 <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 03 57 00 00       	call   8010581a <acquiresleep>
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
8010017d:	e8 27 58 00 00       	call   801059a9 <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 8a 56 00 00       	call   8010581a <acquiresleep>
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
801001a7:	c7 04 24 4a 91 10 80 	movl   $0x8010914a,(%esp)
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
801001e2:	e8 36 29 00 00       	call   80102b1d <iderw>
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
801001fb:	e8 b7 56 00 00       	call   801058b7 <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 5b 91 10 80 	movl   $0x8010915b,(%esp)
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
80100225:	e8 f3 28 00 00       	call   80102b1d <iderw>
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
8010023b:	e8 77 56 00 00       	call   801058b7 <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 62 91 10 80 	movl   $0x80109162,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 17 56 00 00       	call   80105875 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 a0 d7 10 80 	movl   $0x8010d7a0,(%esp)
80100265:	e8 d5 56 00 00       	call   8010593f <acquire>
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
801002d1:	e8 d3 56 00 00       	call   801059a9 <release>
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
801003dc:	e8 5e 55 00 00       	call   8010593f <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 69 91 10 80 	movl   $0x80109169,(%esp)
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
801004cf:	c7 45 ec 72 91 10 80 	movl   $0x80109172,-0x14(%ebp)
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
8010054d:	e8 57 54 00 00       	call   801059a9 <release>
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
80100569:	e8 4b 2c 00 00       	call   801031b9 <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 79 91 10 80 	movl   $0x80109179,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 8d 91 10 80 	movl   $0x8010918d,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 4f 54 00 00       	call   801059f6 <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 8f 91 10 80 	movl   $0x8010918f,(%esp)
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
80100695:	c7 04 24 93 91 10 80 	movl   $0x80109193,(%esp)
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
801006c9:	e8 9d 55 00 00       	call   80105c6b <memmove>
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
801006f8:	e8 a5 54 00 00       	call   80105ba2 <memset>
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
8010078e:	e8 29 71 00 00       	call   801078bc <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 1d 71 00 00       	call   801078bc <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 11 71 00 00       	call   801078bc <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 04 71 00 00       	call   801078bc <uartputc>
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
80100813:	e8 27 51 00 00       	call   8010593f <acquire>
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
801009e0:	e8 dd 42 00 00       	call   80104cc2 <wakeup>
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
80100a01:	e8 a3 4f 00 00       	call   801059a9 <release>
  if(doprocdump){
80100a06:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a0a:	74 05                	je     80100a11 <consoleintr+0x21c>
    contdump();  // now call procdump() wo. cons.lock held
80100a0c:	e8 0b 4c 00 00       	call   8010561c <contdump>
  }
  if(doconsoleswitch){
80100a11:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a15:	74 15                	je     80100a2c <consoleintr+0x237>
    cprintf("\nActive console now: %d\n", active);
80100a17:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a20:	c7 04 24 a6 91 10 80 	movl   $0x801091a6,(%esp)
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
80100a40:	e8 63 11 00 00       	call   80101ba8 <iunlock>
  target = n;
80100a45:	8b 45 10             	mov    0x10(%ebp),%eax
80100a48:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
80100a4b:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
80100a52:	e8 e8 4e 00 00       	call   8010593f <acquire>
  while(n > 0){
80100a57:	e9 b7 00 00 00       	jmp    80100b13 <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a5c:	eb 41                	jmp    80100a9f <consoleread+0x6b>
      if(myproc()->killed){
80100a5e:	e8 9d 38 00 00       	call   80104300 <myproc>
80100a63:	8b 40 24             	mov    0x24(%eax),%eax
80100a66:	85 c0                	test   %eax,%eax
80100a68:	74 21                	je     80100a8b <consoleread+0x57>
        release(&cons.lock);
80100a6a:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
80100a71:	e8 33 4f 00 00       	call   801059a9 <release>
        ilock(ip);
80100a76:	8b 45 08             	mov    0x8(%ebp),%eax
80100a79:	89 04 24             	mov    %eax,(%esp)
80100a7c:	e8 1d 10 00 00       	call   80101a9e <ilock>
        return -1;
80100a81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100a86:	e9 b3 00 00 00       	jmp    80100b3e <consoleread+0x10a>
      }
      sleep(&input.r, &cons.lock);
80100a8b:	c7 44 24 04 00 c7 10 	movl   $0x8010c700,0x4(%esp)
80100a92:	80 
80100a93:	c7 04 24 80 21 11 80 	movl   $0x80112180,(%esp)
80100a9a:	e8 35 41 00 00       	call   80104bd4 <sleep>

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
80100b24:	e8 80 4e 00 00       	call   801059a9 <release>
  ilock(ip);
80100b29:	8b 45 08             	mov    0x8(%ebp),%eax
80100b2c:	89 04 24             	mov    %eax,(%esp)
80100b2f:	e8 6a 0f 00 00       	call   80101a9e <ilock>

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
80100b5e:	e8 45 10 00 00       	call   80101ba8 <iunlock>
    acquire(&cons.lock);
80100b63:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
80100b6a:	e8 d0 4d 00 00       	call   8010593f <acquire>
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
80100ba2:	e8 02 4e 00 00       	call   801059a9 <release>
    ilock(ip);
80100ba7:	8b 45 08             	mov    0x8(%ebp),%eax
80100baa:	89 04 24             	mov    %eax,(%esp)
80100bad:	e8 ec 0e 00 00       	call   80101a9e <ilock>
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
80100bbd:	c7 44 24 04 bf 91 10 	movl   $0x801091bf,0x4(%esp)
80100bc4:	80 
80100bc5:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
80100bcc:	e8 4d 4d 00 00       	call   8010591e <initlock>

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
80100bfe:	e8 cc 20 00 00       	call   80102ccf <ioapicenable>
}
80100c03:	c9                   	leave  
80100c04:	c3                   	ret    
80100c05:	00 00                	add    %al,(%eax)
	...

80100c08 <exec>:
#include "elf.h"
#include "container.h"

int
exec(char *path, char **argv)
{  
80100c08:	55                   	push   %ebp
80100c09:	89 e5                	mov    %esp,%ebp
80100c0b:	81 ec 38 01 00 00    	sub    $0x138,%esp
  cprintf("exec running\n");
80100c11:	c7 04 24 c7 91 10 80 	movl   $0x801091c7,(%esp)
80100c18:	e8 a4 f7 ff ff       	call   801003c1 <cprintf>
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100c1d:	e8 de 36 00 00       	call   80104300 <myproc>
80100c22:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c25:	e8 d9 2a 00 00       	call   80103703 <begin_op>

  if (myproc()->cont->state == CREADY)
80100c2a:	e8 d1 36 00 00       	call   80104300 <myproc>
80100c2f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80100c35:	8b 40 14             	mov    0x14(%eax),%eax
80100c38:	83 f8 02             	cmp    $0x2,%eax
80100c3b:	75 07                	jne    80100c44 <exec+0x3c>
    path = "/ctest1/init";
80100c3d:	c7 45 08 d5 91 10 80 	movl   $0x801091d5,0x8(%ebp)

  if((ip = namei(path)) == 0){
80100c44:	8b 45 08             	mov    0x8(%ebp),%eax
80100c47:	89 04 24             	mov    %eax,(%esp)
80100c4a:	e8 de 1a 00 00       	call   8010272d <namei>
80100c4f:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c52:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c56:	75 1b                	jne    80100c73 <exec+0x6b>
    end_op();
80100c58:	e8 28 2b 00 00       	call   80103785 <end_op>
    cprintf("exec: fail\n");
80100c5d:	c7 04 24 e2 91 10 80 	movl   $0x801091e2,(%esp)
80100c64:	e8 58 f7 ff ff       	call   801003c1 <cprintf>
    return -1;
80100c69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c6e:	e9 4a 04 00 00       	jmp    801010bd <exec+0x4b5>
  }
  cprintf("exec: got an ip\n");
80100c73:	c7 04 24 ee 91 10 80 	movl   $0x801091ee,(%esp)
80100c7a:	e8 42 f7 ff ff       	call   801003c1 <cprintf>
  ilock(ip);
80100c7f:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100c82:	89 04 24             	mov    %eax,(%esp)
80100c85:	e8 14 0e 00 00       	call   80101a9e <ilock>
  pgdir = 0;
80100c8a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  cprintf("exec: locked ip\n");
80100c91:	c7 04 24 ff 91 10 80 	movl   $0x801091ff,(%esp)
80100c98:	e8 24 f7 ff ff       	call   801003c1 <cprintf>

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100c9d:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100ca4:	00 
80100ca5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80100cac:	00 
80100cad:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100cb3:	89 44 24 04          	mov    %eax,0x4(%esp)
80100cb7:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100cba:	89 04 24             	mov    %eax,(%esp)
80100cbd:	e8 73 12 00 00       	call   80101f35 <readi>
80100cc2:	83 f8 34             	cmp    $0x34,%eax
80100cc5:	74 05                	je     80100ccc <exec+0xc4>
    goto bad;
80100cc7:	e9 c5 03 00 00       	jmp    80101091 <exec+0x489>
  if(elf.magic != ELF_MAGIC)
80100ccc:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100cd2:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100cd7:	74 05                	je     80100cde <exec+0xd6>
    goto bad;
80100cd9:	e9 b3 03 00 00       	jmp    80101091 <exec+0x489>

  if((pgdir = setupkvm()) == 0)
80100cde:	e8 bb 7b 00 00       	call   8010889e <setupkvm>
80100ce3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100ce6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100cea:	75 05                	jne    80100cf1 <exec+0xe9>
    goto bad;
80100cec:	e9 a0 03 00 00       	jmp    80101091 <exec+0x489>

  cprintf("exec: set up kvm\n");
80100cf1:	c7 04 24 10 92 10 80 	movl   $0x80109210,(%esp)
80100cf8:	e8 c4 f6 ff ff       	call   801003c1 <cprintf>

  // Load program into memory.
  sz = 0;
80100cfd:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d04:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100d0b:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100d11:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d14:	e9 fb 00 00 00       	jmp    80100e14 <exec+0x20c>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100d19:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d1c:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
80100d23:	00 
80100d24:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d28:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100d2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100d32:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100d35:	89 04 24             	mov    %eax,(%esp)
80100d38:	e8 f8 11 00 00       	call   80101f35 <readi>
80100d3d:	83 f8 20             	cmp    $0x20,%eax
80100d40:	74 05                	je     80100d47 <exec+0x13f>
      goto bad;
80100d42:	e9 4a 03 00 00       	jmp    80101091 <exec+0x489>
    if(ph.type != ELF_PROG_LOAD)
80100d47:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100d4d:	83 f8 01             	cmp    $0x1,%eax
80100d50:	74 05                	je     80100d57 <exec+0x14f>
      continue;
80100d52:	e9 b1 00 00 00       	jmp    80100e08 <exec+0x200>
    if(ph.memsz < ph.filesz)
80100d57:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100d5d:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100d63:	39 c2                	cmp    %eax,%edx
80100d65:	73 05                	jae    80100d6c <exec+0x164>
      goto bad;
80100d67:	e9 25 03 00 00       	jmp    80101091 <exec+0x489>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100d6c:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d72:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d78:	01 c2                	add    %eax,%edx
80100d7a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100d80:	39 c2                	cmp    %eax,%edx
80100d82:	73 05                	jae    80100d89 <exec+0x181>
      goto bad;
80100d84:	e9 08 03 00 00       	jmp    80101091 <exec+0x489>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100d89:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100d8f:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100d95:	01 d0                	add    %edx,%eax
80100d97:	89 44 24 08          	mov    %eax,0x8(%esp)
80100d9b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d9e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100da2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100da5:	89 04 24             	mov    %eax,(%esp)
80100da8:	e8 bd 7e 00 00       	call   80108c6a <allocuvm>
80100dad:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100db0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100db4:	75 05                	jne    80100dbb <exec+0x1b3>
      goto bad;
80100db6:	e9 d6 02 00 00       	jmp    80101091 <exec+0x489>
    if(ph.vaddr % PGSIZE != 0)
80100dbb:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100dc1:	25 ff 0f 00 00       	and    $0xfff,%eax
80100dc6:	85 c0                	test   %eax,%eax
80100dc8:	74 05                	je     80100dcf <exec+0x1c7>
      goto bad;
80100dca:	e9 c2 02 00 00       	jmp    80101091 <exec+0x489>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100dcf:	8b 8d f8 fe ff ff    	mov    -0x108(%ebp),%ecx
80100dd5:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100ddb:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100de1:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80100de5:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100de9:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100dec:	89 54 24 08          	mov    %edx,0x8(%esp)
80100df0:	89 44 24 04          	mov    %eax,0x4(%esp)
80100df4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100df7:	89 04 24             	mov    %eax,(%esp)
80100dfa:	e8 88 7d 00 00       	call   80108b87 <loaduvm>
80100dff:	85 c0                	test   %eax,%eax
80100e01:	79 05                	jns    80100e08 <exec+0x200>
      goto bad;
80100e03:	e9 89 02 00 00       	jmp    80101091 <exec+0x489>

  cprintf("exec: set up kvm\n");

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100e08:	ff 45 ec             	incl   -0x14(%ebp)
80100e0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100e0e:	83 c0 20             	add    $0x20,%eax
80100e11:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100e14:	8b 85 34 ff ff ff    	mov    -0xcc(%ebp),%eax
80100e1a:	0f b7 c0             	movzwl %ax,%eax
80100e1d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100e20:	0f 8f f3 fe ff ff    	jg     80100d19 <exec+0x111>
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100e26:	8b 45 d8             	mov    -0x28(%ebp),%eax
80100e29:	89 04 24             	mov    %eax,(%esp)
80100e2c:	e8 6c 0e 00 00       	call   80101c9d <iunlockput>
  end_op();
80100e31:	e8 4f 29 00 00       	call   80103785 <end_op>
  ip = 0;
80100e36:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  cprintf("exec: mem set stff\n");
80100e3d:	c7 04 24 22 92 10 80 	movl   $0x80109222,(%esp)
80100e44:	e8 78 f5 ff ff       	call   801003c1 <cprintf>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100e49:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e4c:	05 ff 0f 00 00       	add    $0xfff,%eax
80100e51:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100e56:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100e59:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e5c:	05 00 20 00 00       	add    $0x2000,%eax
80100e61:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e65:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e68:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e6c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e6f:	89 04 24             	mov    %eax,(%esp)
80100e72:	e8 f3 7d 00 00       	call   80108c6a <allocuvm>
80100e77:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100e7a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100e7e:	75 05                	jne    80100e85 <exec+0x27d>
    goto bad;
80100e80:	e9 0c 02 00 00       	jmp    80101091 <exec+0x489>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100e85:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e88:	2d 00 20 00 00       	sub    $0x2000,%eax
80100e8d:	89 44 24 04          	mov    %eax,0x4(%esp)
80100e91:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100e94:	89 04 24             	mov    %eax,(%esp)
80100e97:	e8 3e 80 00 00       	call   80108eda <clearpteu>
  sp = sz;
80100e9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100e9f:	89 45 dc             	mov    %eax,-0x24(%ebp)
cprintf("exec: allocuvm didnt fail\n");
80100ea2:	c7 04 24 36 92 10 80 	movl   $0x80109236,(%esp)
80100ea9:	e8 13 f5 ff ff       	call   801003c1 <cprintf>
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100eae:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100eb5:	e9 95 00 00 00       	jmp    80100f4f <exec+0x347>
    if(argc >= MAXARG)
80100eba:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100ebe:	76 05                	jbe    80100ec5 <exec+0x2bd>
      goto bad;
80100ec0:	e9 cc 01 00 00       	jmp    80101091 <exec+0x489>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100ec5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ec8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ed2:	01 d0                	add    %edx,%eax
80100ed4:	8b 00                	mov    (%eax),%eax
80100ed6:	89 04 24             	mov    %eax,(%esp)
80100ed9:	e8 17 4f 00 00       	call   80105df5 <strlen>
80100ede:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100ee1:	29 c2                	sub    %eax,%edx
80100ee3:	89 d0                	mov    %edx,%eax
80100ee5:	48                   	dec    %eax
80100ee6:	83 e0 fc             	and    $0xfffffffc,%eax
80100ee9:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100eec:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eef:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100ef6:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ef9:	01 d0                	add    %edx,%eax
80100efb:	8b 00                	mov    (%eax),%eax
80100efd:	89 04 24             	mov    %eax,(%esp)
80100f00:	e8 f0 4e 00 00       	call   80105df5 <strlen>
80100f05:	40                   	inc    %eax
80100f06:	89 c2                	mov    %eax,%edx
80100f08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f0b:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
80100f12:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f15:	01 c8                	add    %ecx,%eax
80100f17:	8b 00                	mov    (%eax),%eax
80100f19:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100f1d:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f21:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f24:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f28:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100f2b:	89 04 24             	mov    %eax,(%esp)
80100f2e:	e8 5f 81 00 00       	call   80109092 <copyout>
80100f33:	85 c0                	test   %eax,%eax
80100f35:	79 05                	jns    80100f3c <exec+0x334>
      goto bad;
80100f37:	e9 55 01 00 00       	jmp    80101091 <exec+0x489>
    ustack[3+argc] = sp;
80100f3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f3f:	8d 50 03             	lea    0x3(%eax),%edx
80100f42:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f45:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;
cprintf("exec: allocuvm didnt fail\n");
  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100f4c:	ff 45 e4             	incl   -0x1c(%ebp)
80100f4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f52:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f59:	8b 45 0c             	mov    0xc(%ebp),%eax
80100f5c:	01 d0                	add    %edx,%eax
80100f5e:	8b 00                	mov    (%eax),%eax
80100f60:	85 c0                	test   %eax,%eax
80100f62:	0f 85 52 ff ff ff    	jne    80100eba <exec+0x2b2>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100f68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f6b:	83 c0 03             	add    $0x3,%eax
80100f6e:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100f75:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100f79:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100f80:	ff ff ff 
  ustack[1] = argc;
80100f83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f86:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100f8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100f8f:	40                   	inc    %eax
80100f90:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100f97:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f9a:	29 d0                	sub    %edx,%eax
80100f9c:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100fa2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fa5:	83 c0 04             	add    $0x4,%eax
80100fa8:	c1 e0 02             	shl    $0x2,%eax
80100fab:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100fae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100fb1:	83 c0 04             	add    $0x4,%eax
80100fb4:	c1 e0 02             	shl    $0x2,%eax
80100fb7:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100fbb:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100fc1:	89 44 24 08          	mov    %eax,0x8(%esp)
80100fc5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100fc8:	89 44 24 04          	mov    %eax,0x4(%esp)
80100fcc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80100fcf:	89 04 24             	mov    %eax,(%esp)
80100fd2:	e8 bb 80 00 00       	call   80109092 <copyout>
80100fd7:	85 c0                	test   %eax,%eax
80100fd9:	79 05                	jns    80100fe0 <exec+0x3d8>
    goto bad;
80100fdb:	e9 b1 00 00 00       	jmp    80101091 <exec+0x489>
  cprintf("exec: before string copy\n");
80100fe0:	c7 04 24 51 92 10 80 	movl   $0x80109251,(%esp)
80100fe7:	e8 d5 f3 ff ff       	call   801003c1 <cprintf>

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100fec:	8b 45 08             	mov    0x8(%ebp),%eax
80100fef:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ff5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ff8:	eb 13                	jmp    8010100d <exec+0x405>
    if(*s == '/')
80100ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ffd:	8a 00                	mov    (%eax),%al
80100fff:	3c 2f                	cmp    $0x2f,%al
80101001:	75 07                	jne    8010100a <exec+0x402>
      last = s+1;
80101003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101006:	40                   	inc    %eax
80101007:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
  cprintf("exec: before string copy\n");

  // Save program name for debugging.
  for(last=s=path; *s; s++)
8010100a:	ff 45 f4             	incl   -0xc(%ebp)
8010100d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101010:	8a 00                	mov    (%eax),%al
80101012:	84 c0                	test   %al,%al
80101014:	75 e4                	jne    80100ffa <exec+0x3f2>
    if(*s == '/')
      last = s+1;
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80101016:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101019:	8d 50 6c             	lea    0x6c(%eax),%edx
8010101c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80101023:	00 
80101024:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101027:	89 44 24 04          	mov    %eax,0x4(%esp)
8010102b:	89 14 24             	mov    %edx,(%esp)
8010102e:	e8 7b 4d 00 00       	call   80105dae <safestrcpy>

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80101033:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101036:	8b 40 04             	mov    0x4(%eax),%eax
80101039:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
8010103c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010103f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80101042:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80101045:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101048:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010104b:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
8010104d:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101050:	8b 40 18             	mov    0x18(%eax),%eax
80101053:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80101059:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
8010105c:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010105f:	8b 40 18             	mov    0x18(%eax),%eax
80101062:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101065:	89 50 44             	mov    %edx,0x44(%eax)
  cprintf("exec: switchuvm\n");
80101068:	c7 04 24 6b 92 10 80 	movl   $0x8010926b,(%esp)
8010106f:	e8 4d f3 ff ff       	call   801003c1 <cprintf>
  switchuvm(curproc);
80101074:	8b 45 d0             	mov    -0x30(%ebp),%eax
80101077:	89 04 24             	mov    %eax,(%esp)
8010107a:	e8 f9 78 00 00       	call   80108978 <switchuvm>
  freevm(oldpgdir);
8010107f:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101082:	89 04 24             	mov    %eax,(%esp)
80101085:	e8 ba 7d 00 00       	call   80108e44 <freevm>
  return 0;
8010108a:	b8 00 00 00 00       	mov    $0x0,%eax
8010108f:	eb 2c                	jmp    801010bd <exec+0x4b5>

 bad:
  if(pgdir)
80101091:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80101095:	74 0b                	je     801010a2 <exec+0x49a>
    freevm(pgdir);
80101097:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010109a:	89 04 24             	mov    %eax,(%esp)
8010109d:	e8 a2 7d 00 00       	call   80108e44 <freevm>
  if(ip){
801010a2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
801010a6:	74 10                	je     801010b8 <exec+0x4b0>
    iunlockput(ip);
801010a8:	8b 45 d8             	mov    -0x28(%ebp),%eax
801010ab:	89 04 24             	mov    %eax,(%esp)
801010ae:	e8 ea 0b 00 00       	call   80101c9d <iunlockput>
    end_op();
801010b3:	e8 cd 26 00 00       	call   80103785 <end_op>
  }
  return -1;
801010b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010bd:	c9                   	leave  
801010be:	c3                   	ret    
	...

801010c0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
801010c0:	55                   	push   %ebp
801010c1:	89 e5                	mov    %esp,%ebp
801010c3:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
801010c6:	c7 44 24 04 7c 92 10 	movl   $0x8010927c,0x4(%esp)
801010cd:	80 
801010ce:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
801010d5:	e8 44 48 00 00       	call   8010591e <initlock>
}
801010da:	c9                   	leave  
801010db:	c3                   	ret    

801010dc <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
801010dc:	55                   	push   %ebp
801010dd:	89 e5                	mov    %esp,%ebp
801010df:	83 ec 28             	sub    $0x28,%esp
  struct file *f;

  acquire(&ftable.lock);
801010e2:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
801010e9:	e8 51 48 00 00       	call   8010593f <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
801010ee:	c7 45 f4 d4 21 11 80 	movl   $0x801121d4,-0xc(%ebp)
801010f5:	eb 29                	jmp    80101120 <filealloc+0x44>
    if(f->ref == 0){
801010f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801010fa:	8b 40 04             	mov    0x4(%eax),%eax
801010fd:	85 c0                	test   %eax,%eax
801010ff:	75 1b                	jne    8010111c <filealloc+0x40>
      f->ref = 1;
80101101:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101104:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010110b:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
80101112:	e8 92 48 00 00       	call   801059a9 <release>
      return f;
80101117:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010111a:	eb 1e                	jmp    8010113a <filealloc+0x5e>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010111c:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101120:	81 7d f4 34 2b 11 80 	cmpl   $0x80112b34,-0xc(%ebp)
80101127:	72 ce                	jb     801010f7 <filealloc+0x1b>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80101129:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
80101130:	e8 74 48 00 00       	call   801059a9 <release>
  return 0;
80101135:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010113a:	c9                   	leave  
8010113b:	c3                   	ret    

8010113c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
8010113c:	55                   	push   %ebp
8010113d:	89 e5                	mov    %esp,%ebp
8010113f:	83 ec 18             	sub    $0x18,%esp
  acquire(&ftable.lock);
80101142:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
80101149:	e8 f1 47 00 00       	call   8010593f <acquire>
  if(f->ref < 1)
8010114e:	8b 45 08             	mov    0x8(%ebp),%eax
80101151:	8b 40 04             	mov    0x4(%eax),%eax
80101154:	85 c0                	test   %eax,%eax
80101156:	7f 0c                	jg     80101164 <filedup+0x28>
    panic("filedup");
80101158:	c7 04 24 83 92 10 80 	movl   $0x80109283,(%esp)
8010115f:	e8 f0 f3 ff ff       	call   80100554 <panic>
  f->ref++;
80101164:	8b 45 08             	mov    0x8(%ebp),%eax
80101167:	8b 40 04             	mov    0x4(%eax),%eax
8010116a:	8d 50 01             	lea    0x1(%eax),%edx
8010116d:	8b 45 08             	mov    0x8(%ebp),%eax
80101170:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101173:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
8010117a:	e8 2a 48 00 00       	call   801059a9 <release>
  return f;
8010117f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101182:	c9                   	leave  
80101183:	c3                   	ret    

80101184 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101184:	55                   	push   %ebp
80101185:	89 e5                	mov    %esp,%ebp
80101187:	57                   	push   %edi
80101188:	56                   	push   %esi
80101189:	53                   	push   %ebx
8010118a:	83 ec 3c             	sub    $0x3c,%esp
  struct file ff;

  acquire(&ftable.lock);
8010118d:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
80101194:	e8 a6 47 00 00       	call   8010593f <acquire>
  if(f->ref < 1)
80101199:	8b 45 08             	mov    0x8(%ebp),%eax
8010119c:	8b 40 04             	mov    0x4(%eax),%eax
8010119f:	85 c0                	test   %eax,%eax
801011a1:	7f 0c                	jg     801011af <fileclose+0x2b>
    panic("fileclose");
801011a3:	c7 04 24 8b 92 10 80 	movl   $0x8010928b,(%esp)
801011aa:	e8 a5 f3 ff ff       	call   80100554 <panic>
  if(--f->ref > 0){
801011af:	8b 45 08             	mov    0x8(%ebp),%eax
801011b2:	8b 40 04             	mov    0x4(%eax),%eax
801011b5:	8d 50 ff             	lea    -0x1(%eax),%edx
801011b8:	8b 45 08             	mov    0x8(%ebp),%eax
801011bb:	89 50 04             	mov    %edx,0x4(%eax)
801011be:	8b 45 08             	mov    0x8(%ebp),%eax
801011c1:	8b 40 04             	mov    0x4(%eax),%eax
801011c4:	85 c0                	test   %eax,%eax
801011c6:	7e 0e                	jle    801011d6 <fileclose+0x52>
    release(&ftable.lock);
801011c8:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
801011cf:	e8 d5 47 00 00       	call   801059a9 <release>
801011d4:	eb 70                	jmp    80101246 <fileclose+0xc2>
    return;
  }
  ff = *f;
801011d6:	8b 45 08             	mov    0x8(%ebp),%eax
801011d9:	8d 55 d0             	lea    -0x30(%ebp),%edx
801011dc:	89 c3                	mov    %eax,%ebx
801011de:	b8 06 00 00 00       	mov    $0x6,%eax
801011e3:	89 d7                	mov    %edx,%edi
801011e5:	89 de                	mov    %ebx,%esi
801011e7:	89 c1                	mov    %eax,%ecx
801011e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  f->ref = 0;
801011eb:	8b 45 08             	mov    0x8(%ebp),%eax
801011ee:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801011f5:	8b 45 08             	mov    0x8(%ebp),%eax
801011f8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801011fe:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
80101205:	e8 9f 47 00 00       	call   801059a9 <release>

  if(ff.type == FD_PIPE)
8010120a:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010120d:	83 f8 01             	cmp    $0x1,%eax
80101210:	75 17                	jne    80101229 <fileclose+0xa5>
    pipeclose(ff.pipe, ff.writable);
80101212:	8a 45 d9             	mov    -0x27(%ebp),%al
80101215:	0f be d0             	movsbl %al,%edx
80101218:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010121b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010121f:	89 04 24             	mov    %eax,(%esp)
80101222:	e8 6c 2e 00 00       	call   80104093 <pipeclose>
80101227:	eb 1d                	jmp    80101246 <fileclose+0xc2>
  else if(ff.type == FD_INODE){
80101229:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010122c:	83 f8 02             	cmp    $0x2,%eax
8010122f:	75 15                	jne    80101246 <fileclose+0xc2>
    begin_op();
80101231:	e8 cd 24 00 00       	call   80103703 <begin_op>
    iput(ff.ip);
80101236:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101239:	89 04 24             	mov    %eax,(%esp)
8010123c:	e8 ab 09 00 00       	call   80101bec <iput>
    end_op();
80101241:	e8 3f 25 00 00       	call   80103785 <end_op>
  }
}
80101246:	83 c4 3c             	add    $0x3c,%esp
80101249:	5b                   	pop    %ebx
8010124a:	5e                   	pop    %esi
8010124b:	5f                   	pop    %edi
8010124c:	5d                   	pop    %ebp
8010124d:	c3                   	ret    

8010124e <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010124e:	55                   	push   %ebp
8010124f:	89 e5                	mov    %esp,%ebp
80101251:	83 ec 18             	sub    $0x18,%esp
  if(f->type == FD_INODE){
80101254:	8b 45 08             	mov    0x8(%ebp),%eax
80101257:	8b 00                	mov    (%eax),%eax
80101259:	83 f8 02             	cmp    $0x2,%eax
8010125c:	75 38                	jne    80101296 <filestat+0x48>
    ilock(f->ip);
8010125e:	8b 45 08             	mov    0x8(%ebp),%eax
80101261:	8b 40 10             	mov    0x10(%eax),%eax
80101264:	89 04 24             	mov    %eax,(%esp)
80101267:	e8 32 08 00 00       	call   80101a9e <ilock>
    stati(f->ip, st);
8010126c:	8b 45 08             	mov    0x8(%ebp),%eax
8010126f:	8b 40 10             	mov    0x10(%eax),%eax
80101272:	8b 55 0c             	mov    0xc(%ebp),%edx
80101275:	89 54 24 04          	mov    %edx,0x4(%esp)
80101279:	89 04 24             	mov    %eax,(%esp)
8010127c:	e8 70 0c 00 00       	call   80101ef1 <stati>
    iunlock(f->ip);
80101281:	8b 45 08             	mov    0x8(%ebp),%eax
80101284:	8b 40 10             	mov    0x10(%eax),%eax
80101287:	89 04 24             	mov    %eax,(%esp)
8010128a:	e8 19 09 00 00       	call   80101ba8 <iunlock>
    return 0;
8010128f:	b8 00 00 00 00       	mov    $0x0,%eax
80101294:	eb 05                	jmp    8010129b <filestat+0x4d>
  }
  return -1;
80101296:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010129b:	c9                   	leave  
8010129c:	c3                   	ret    

8010129d <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
8010129d:	55                   	push   %ebp
8010129e:	89 e5                	mov    %esp,%ebp
801012a0:	83 ec 28             	sub    $0x28,%esp
  int r;

  if(f->readable == 0)
801012a3:	8b 45 08             	mov    0x8(%ebp),%eax
801012a6:	8a 40 08             	mov    0x8(%eax),%al
801012a9:	84 c0                	test   %al,%al
801012ab:	75 0a                	jne    801012b7 <fileread+0x1a>
    return -1;
801012ad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012b2:	e9 9f 00 00 00       	jmp    80101356 <fileread+0xb9>
  if(f->type == FD_PIPE)
801012b7:	8b 45 08             	mov    0x8(%ebp),%eax
801012ba:	8b 00                	mov    (%eax),%eax
801012bc:	83 f8 01             	cmp    $0x1,%eax
801012bf:	75 1e                	jne    801012df <fileread+0x42>
    return piperead(f->pipe, addr, n);
801012c1:	8b 45 08             	mov    0x8(%ebp),%eax
801012c4:	8b 40 0c             	mov    0xc(%eax),%eax
801012c7:	8b 55 10             	mov    0x10(%ebp),%edx
801012ca:	89 54 24 08          	mov    %edx,0x8(%esp)
801012ce:	8b 55 0c             	mov    0xc(%ebp),%edx
801012d1:	89 54 24 04          	mov    %edx,0x4(%esp)
801012d5:	89 04 24             	mov    %eax,(%esp)
801012d8:	e8 34 2f 00 00       	call   80104211 <piperead>
801012dd:	eb 77                	jmp    80101356 <fileread+0xb9>
  if(f->type == FD_INODE){
801012df:	8b 45 08             	mov    0x8(%ebp),%eax
801012e2:	8b 00                	mov    (%eax),%eax
801012e4:	83 f8 02             	cmp    $0x2,%eax
801012e7:	75 61                	jne    8010134a <fileread+0xad>
    ilock(f->ip);
801012e9:	8b 45 08             	mov    0x8(%ebp),%eax
801012ec:	8b 40 10             	mov    0x10(%eax),%eax
801012ef:	89 04 24             	mov    %eax,(%esp)
801012f2:	e8 a7 07 00 00       	call   80101a9e <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801012f7:	8b 4d 10             	mov    0x10(%ebp),%ecx
801012fa:	8b 45 08             	mov    0x8(%ebp),%eax
801012fd:	8b 50 14             	mov    0x14(%eax),%edx
80101300:	8b 45 08             	mov    0x8(%ebp),%eax
80101303:	8b 40 10             	mov    0x10(%eax),%eax
80101306:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
8010130a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010130e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101311:	89 54 24 04          	mov    %edx,0x4(%esp)
80101315:	89 04 24             	mov    %eax,(%esp)
80101318:	e8 18 0c 00 00       	call   80101f35 <readi>
8010131d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101320:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101324:	7e 11                	jle    80101337 <fileread+0x9a>
      f->off += r;
80101326:	8b 45 08             	mov    0x8(%ebp),%eax
80101329:	8b 50 14             	mov    0x14(%eax),%edx
8010132c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010132f:	01 c2                	add    %eax,%edx
80101331:	8b 45 08             	mov    0x8(%ebp),%eax
80101334:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101337:	8b 45 08             	mov    0x8(%ebp),%eax
8010133a:	8b 40 10             	mov    0x10(%eax),%eax
8010133d:	89 04 24             	mov    %eax,(%esp)
80101340:	e8 63 08 00 00       	call   80101ba8 <iunlock>
    return r;
80101345:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101348:	eb 0c                	jmp    80101356 <fileread+0xb9>
  }
  panic("fileread");
8010134a:	c7 04 24 95 92 10 80 	movl   $0x80109295,(%esp)
80101351:	e8 fe f1 ff ff       	call   80100554 <panic>
}
80101356:	c9                   	leave  
80101357:	c3                   	ret    

80101358 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101358:	55                   	push   %ebp
80101359:	89 e5                	mov    %esp,%ebp
8010135b:	53                   	push   %ebx
8010135c:	83 ec 24             	sub    $0x24,%esp
  int r;

  if(f->writable == 0)
8010135f:	8b 45 08             	mov    0x8(%ebp),%eax
80101362:	8a 40 09             	mov    0x9(%eax),%al
80101365:	84 c0                	test   %al,%al
80101367:	75 0a                	jne    80101373 <filewrite+0x1b>
    return -1;
80101369:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010136e:	e9 20 01 00 00       	jmp    80101493 <filewrite+0x13b>
  if(f->type == FD_PIPE)
80101373:	8b 45 08             	mov    0x8(%ebp),%eax
80101376:	8b 00                	mov    (%eax),%eax
80101378:	83 f8 01             	cmp    $0x1,%eax
8010137b:	75 21                	jne    8010139e <filewrite+0x46>
    return pipewrite(f->pipe, addr, n);
8010137d:	8b 45 08             	mov    0x8(%ebp),%eax
80101380:	8b 40 0c             	mov    0xc(%eax),%eax
80101383:	8b 55 10             	mov    0x10(%ebp),%edx
80101386:	89 54 24 08          	mov    %edx,0x8(%esp)
8010138a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010138d:	89 54 24 04          	mov    %edx,0x4(%esp)
80101391:	89 04 24             	mov    %eax,(%esp)
80101394:	e8 8c 2d 00 00       	call   80104125 <pipewrite>
80101399:	e9 f5 00 00 00       	jmp    80101493 <filewrite+0x13b>
  if(f->type == FD_INODE){
8010139e:	8b 45 08             	mov    0x8(%ebp),%eax
801013a1:	8b 00                	mov    (%eax),%eax
801013a3:	83 f8 02             	cmp    $0x2,%eax
801013a6:	0f 85 db 00 00 00    	jne    80101487 <filewrite+0x12f>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
801013ac:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
801013b3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801013ba:	e9 a8 00 00 00       	jmp    80101467 <filewrite+0x10f>
      int n1 = n - i;
801013bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013c2:	8b 55 10             	mov    0x10(%ebp),%edx
801013c5:	29 c2                	sub    %eax,%edx
801013c7:	89 d0                	mov    %edx,%eax
801013c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
801013cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801013cf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801013d2:	7e 06                	jle    801013da <filewrite+0x82>
        n1 = max;
801013d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801013d7:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801013da:	e8 24 23 00 00       	call   80103703 <begin_op>
      ilock(f->ip);
801013df:	8b 45 08             	mov    0x8(%ebp),%eax
801013e2:	8b 40 10             	mov    0x10(%eax),%eax
801013e5:	89 04 24             	mov    %eax,(%esp)
801013e8:	e8 b1 06 00 00       	call   80101a9e <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801013ed:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801013f0:	8b 45 08             	mov    0x8(%ebp),%eax
801013f3:	8b 50 14             	mov    0x14(%eax),%edx
801013f6:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801013f9:	8b 45 0c             	mov    0xc(%ebp),%eax
801013fc:	01 c3                	add    %eax,%ebx
801013fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101401:	8b 40 10             	mov    0x10(%eax),%eax
80101404:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80101408:	89 54 24 08          	mov    %edx,0x8(%esp)
8010140c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101410:	89 04 24             	mov    %eax,(%esp)
80101413:	e8 81 0c 00 00       	call   80102099 <writei>
80101418:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010141b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010141f:	7e 11                	jle    80101432 <filewrite+0xda>
        f->off += r;
80101421:	8b 45 08             	mov    0x8(%ebp),%eax
80101424:	8b 50 14             	mov    0x14(%eax),%edx
80101427:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010142a:	01 c2                	add    %eax,%edx
8010142c:	8b 45 08             	mov    0x8(%ebp),%eax
8010142f:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
80101432:	8b 45 08             	mov    0x8(%ebp),%eax
80101435:	8b 40 10             	mov    0x10(%eax),%eax
80101438:	89 04 24             	mov    %eax,(%esp)
8010143b:	e8 68 07 00 00       	call   80101ba8 <iunlock>
      end_op();
80101440:	e8 40 23 00 00       	call   80103785 <end_op>

      if(r < 0)
80101445:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101449:	79 02                	jns    8010144d <filewrite+0xf5>
        break;
8010144b:	eb 26                	jmp    80101473 <filewrite+0x11b>
      if(r != n1)
8010144d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101450:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80101453:	74 0c                	je     80101461 <filewrite+0x109>
        panic("short filewrite");
80101455:	c7 04 24 9e 92 10 80 	movl   $0x8010929e,(%esp)
8010145c:	e8 f3 f0 ff ff       	call   80100554 <panic>
      i += r;
80101461:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101464:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101467:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010146a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010146d:	0f 8c 4c ff ff ff    	jl     801013bf <filewrite+0x67>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101473:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101476:	3b 45 10             	cmp    0x10(%ebp),%eax
80101479:	75 05                	jne    80101480 <filewrite+0x128>
8010147b:	8b 45 10             	mov    0x10(%ebp),%eax
8010147e:	eb 05                	jmp    80101485 <filewrite+0x12d>
80101480:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101485:	eb 0c                	jmp    80101493 <filewrite+0x13b>
  }
  panic("filewrite");
80101487:	c7 04 24 ae 92 10 80 	movl   $0x801092ae,(%esp)
8010148e:	e8 c1 f0 ff ff       	call   80100554 <panic>
}
80101493:	83 c4 24             	add    $0x24,%esp
80101496:	5b                   	pop    %ebx
80101497:	5d                   	pop    %ebp
80101498:	c3                   	ret    
80101499:	00 00                	add    %al,(%eax)
	...

8010149c <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010149c:	55                   	push   %ebp
8010149d:	89 e5                	mov    %esp,%ebp
8010149f:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801014a2:	8b 45 08             	mov    0x8(%ebp),%eax
801014a5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801014ac:	00 
801014ad:	89 04 24             	mov    %eax,(%esp)
801014b0:	e8 00 ed ff ff       	call   801001b5 <bread>
801014b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801014b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014bb:	83 c0 5c             	add    $0x5c,%eax
801014be:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
801014c5:	00 
801014c6:	89 44 24 04          	mov    %eax,0x4(%esp)
801014ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801014cd:	89 04 24             	mov    %eax,(%esp)
801014d0:	e8 96 47 00 00       	call   80105c6b <memmove>
  brelse(bp);
801014d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014d8:	89 04 24             	mov    %eax,(%esp)
801014db:	e8 4c ed ff ff       	call   8010022c <brelse>
}
801014e0:	c9                   	leave  
801014e1:	c3                   	ret    

801014e2 <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801014e2:	55                   	push   %ebp
801014e3:	89 e5                	mov    %esp,%ebp
801014e5:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;

  bp = bread(dev, bno);
801014e8:	8b 55 0c             	mov    0xc(%ebp),%edx
801014eb:	8b 45 08             	mov    0x8(%ebp),%eax
801014ee:	89 54 24 04          	mov    %edx,0x4(%esp)
801014f2:	89 04 24             	mov    %eax,(%esp)
801014f5:	e8 bb ec ff ff       	call   801001b5 <bread>
801014fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801014fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101500:	83 c0 5c             	add    $0x5c,%eax
80101503:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010150a:	00 
8010150b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101512:	00 
80101513:	89 04 24             	mov    %eax,(%esp)
80101516:	e8 87 46 00 00       	call   80105ba2 <memset>
  log_write(bp);
8010151b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010151e:	89 04 24             	mov    %eax,(%esp)
80101521:	e8 e1 23 00 00       	call   80103907 <log_write>
  brelse(bp);
80101526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101529:	89 04 24             	mov    %eax,(%esp)
8010152c:	e8 fb ec ff ff       	call   8010022c <brelse>
}
80101531:	c9                   	leave  
80101532:	c3                   	ret    

80101533 <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
80101533:	55                   	push   %ebp
80101534:	89 e5                	mov    %esp,%ebp
80101536:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101539:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101540:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101547:	e9 03 01 00 00       	jmp    8010164f <balloc+0x11c>
    bp = bread(dev, BBLOCK(b, sb));
8010154c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010154f:	85 c0                	test   %eax,%eax
80101551:	79 05                	jns    80101558 <balloc+0x25>
80101553:	05 ff 0f 00 00       	add    $0xfff,%eax
80101558:	c1 f8 0c             	sar    $0xc,%eax
8010155b:	89 c2                	mov    %eax,%edx
8010155d:	a1 b8 2b 11 80       	mov    0x80112bb8,%eax
80101562:	01 d0                	add    %edx,%eax
80101564:	89 44 24 04          	mov    %eax,0x4(%esp)
80101568:	8b 45 08             	mov    0x8(%ebp),%eax
8010156b:	89 04 24             	mov    %eax,(%esp)
8010156e:	e8 42 ec ff ff       	call   801001b5 <bread>
80101573:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101576:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010157d:	e9 9b 00 00 00       	jmp    8010161d <balloc+0xea>
      m = 1 << (bi % 8);
80101582:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101585:	25 07 00 00 80       	and    $0x80000007,%eax
8010158a:	85 c0                	test   %eax,%eax
8010158c:	79 05                	jns    80101593 <balloc+0x60>
8010158e:	48                   	dec    %eax
8010158f:	83 c8 f8             	or     $0xfffffff8,%eax
80101592:	40                   	inc    %eax
80101593:	ba 01 00 00 00       	mov    $0x1,%edx
80101598:	88 c1                	mov    %al,%cl
8010159a:	d3 e2                	shl    %cl,%edx
8010159c:	89 d0                	mov    %edx,%eax
8010159e:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801015a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a4:	85 c0                	test   %eax,%eax
801015a6:	79 03                	jns    801015ab <balloc+0x78>
801015a8:	83 c0 07             	add    $0x7,%eax
801015ab:	c1 f8 03             	sar    $0x3,%eax
801015ae:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015b1:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
801015b5:	0f b6 c0             	movzbl %al,%eax
801015b8:	23 45 e8             	and    -0x18(%ebp),%eax
801015bb:	85 c0                	test   %eax,%eax
801015bd:	75 5b                	jne    8010161a <balloc+0xe7>
        bp->data[bi/8] |= m;  // Mark block in use.
801015bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015c2:	85 c0                	test   %eax,%eax
801015c4:	79 03                	jns    801015c9 <balloc+0x96>
801015c6:	83 c0 07             	add    $0x7,%eax
801015c9:	c1 f8 03             	sar    $0x3,%eax
801015cc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015cf:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
801015d3:	88 d1                	mov    %dl,%cl
801015d5:	8b 55 e8             	mov    -0x18(%ebp),%edx
801015d8:	09 ca                	or     %ecx,%edx
801015da:	88 d1                	mov    %dl,%cl
801015dc:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015df:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
801015e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015e6:	89 04 24             	mov    %eax,(%esp)
801015e9:	e8 19 23 00 00       	call   80103907 <log_write>
        brelse(bp);
801015ee:	8b 45 ec             	mov    -0x14(%ebp),%eax
801015f1:	89 04 24             	mov    %eax,(%esp)
801015f4:	e8 33 ec ff ff       	call   8010022c <brelse>
        bzero(dev, b + bi);
801015f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015ff:	01 c2                	add    %eax,%edx
80101601:	8b 45 08             	mov    0x8(%ebp),%eax
80101604:	89 54 24 04          	mov    %edx,0x4(%esp)
80101608:	89 04 24             	mov    %eax,(%esp)
8010160b:	e8 d2 fe ff ff       	call   801014e2 <bzero>
        return b + bi;
80101610:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101613:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101616:	01 d0                	add    %edx,%eax
80101618:	eb 51                	jmp    8010166b <balloc+0x138>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010161a:	ff 45 f0             	incl   -0x10(%ebp)
8010161d:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101624:	7f 17                	jg     8010163d <balloc+0x10a>
80101626:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101629:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010162c:	01 d0                	add    %edx,%eax
8010162e:	89 c2                	mov    %eax,%edx
80101630:	a1 a0 2b 11 80       	mov    0x80112ba0,%eax
80101635:	39 c2                	cmp    %eax,%edx
80101637:	0f 82 45 ff ff ff    	jb     80101582 <balloc+0x4f>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010163d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101640:	89 04 24             	mov    %eax,(%esp)
80101643:	e8 e4 eb ff ff       	call   8010022c <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101648:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010164f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101652:	a1 a0 2b 11 80       	mov    0x80112ba0,%eax
80101657:	39 c2                	cmp    %eax,%edx
80101659:	0f 82 ed fe ff ff    	jb     8010154c <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
8010165f:	c7 04 24 b8 92 10 80 	movl   $0x801092b8,(%esp)
80101666:	e8 e9 ee ff ff       	call   80100554 <panic>
}
8010166b:	c9                   	leave  
8010166c:	c3                   	ret    

8010166d <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010166d:	55                   	push   %ebp
8010166e:	89 e5                	mov    %esp,%ebp
80101670:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101673:	c7 44 24 04 a0 2b 11 	movl   $0x80112ba0,0x4(%esp)
8010167a:	80 
8010167b:	8b 45 08             	mov    0x8(%ebp),%eax
8010167e:	89 04 24             	mov    %eax,(%esp)
80101681:	e8 16 fe ff ff       	call   8010149c <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101686:	8b 45 0c             	mov    0xc(%ebp),%eax
80101689:	c1 e8 0c             	shr    $0xc,%eax
8010168c:	89 c2                	mov    %eax,%edx
8010168e:	a1 b8 2b 11 80       	mov    0x80112bb8,%eax
80101693:	01 c2                	add    %eax,%edx
80101695:	8b 45 08             	mov    0x8(%ebp),%eax
80101698:	89 54 24 04          	mov    %edx,0x4(%esp)
8010169c:	89 04 24             	mov    %eax,(%esp)
8010169f:	e8 11 eb ff ff       	call   801001b5 <bread>
801016a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801016a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801016aa:	25 ff 0f 00 00       	and    $0xfff,%eax
801016af:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801016b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016b5:	25 07 00 00 80       	and    $0x80000007,%eax
801016ba:	85 c0                	test   %eax,%eax
801016bc:	79 05                	jns    801016c3 <bfree+0x56>
801016be:	48                   	dec    %eax
801016bf:	83 c8 f8             	or     $0xfffffff8,%eax
801016c2:	40                   	inc    %eax
801016c3:	ba 01 00 00 00       	mov    $0x1,%edx
801016c8:	88 c1                	mov    %al,%cl
801016ca:	d3 e2                	shl    %cl,%edx
801016cc:	89 d0                	mov    %edx,%eax
801016ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801016d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016d4:	85 c0                	test   %eax,%eax
801016d6:	79 03                	jns    801016db <bfree+0x6e>
801016d8:	83 c0 07             	add    $0x7,%eax
801016db:	c1 f8 03             	sar    $0x3,%eax
801016de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801016e1:	8a 44 02 5c          	mov    0x5c(%edx,%eax,1),%al
801016e5:	0f b6 c0             	movzbl %al,%eax
801016e8:	23 45 ec             	and    -0x14(%ebp),%eax
801016eb:	85 c0                	test   %eax,%eax
801016ed:	75 0c                	jne    801016fb <bfree+0x8e>
    panic("freeing free block");
801016ef:	c7 04 24 ce 92 10 80 	movl   $0x801092ce,(%esp)
801016f6:	e8 59 ee ff ff       	call   80100554 <panic>
  bp->data[bi/8] &= ~m;
801016fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016fe:	85 c0                	test   %eax,%eax
80101700:	79 03                	jns    80101705 <bfree+0x98>
80101702:	83 c0 07             	add    $0x7,%eax
80101705:	c1 f8 03             	sar    $0x3,%eax
80101708:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010170b:	8a 54 02 5c          	mov    0x5c(%edx,%eax,1),%dl
8010170f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80101712:	f7 d1                	not    %ecx
80101714:	21 ca                	and    %ecx,%edx
80101716:	88 d1                	mov    %dl,%cl
80101718:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010171b:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
8010171f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101722:	89 04 24             	mov    %eax,(%esp)
80101725:	e8 dd 21 00 00       	call   80103907 <log_write>
  brelse(bp);
8010172a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010172d:	89 04 24             	mov    %eax,(%esp)
80101730:	e8 f7 ea ff ff       	call   8010022c <brelse>
}
80101735:	c9                   	leave  
80101736:	c3                   	ret    

80101737 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101737:	55                   	push   %ebp
80101738:	89 e5                	mov    %esp,%ebp
8010173a:	57                   	push   %edi
8010173b:	56                   	push   %esi
8010173c:	53                   	push   %ebx
8010173d:	83 ec 4c             	sub    $0x4c,%esp
  int i = 0;
80101740:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101747:	c7 44 24 04 e1 92 10 	movl   $0x801092e1,0x4(%esp)
8010174e:	80 
8010174f:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101756:	e8 c3 41 00 00       	call   8010591e <initlock>
  for(i = 0; i < NINODE; i++) {
8010175b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101762:	eb 2b                	jmp    8010178f <iinit+0x58>
    initsleeplock(&icache.inode[i].lock, "inode");
80101764:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101767:	89 d0                	mov    %edx,%eax
80101769:	c1 e0 03             	shl    $0x3,%eax
8010176c:	01 d0                	add    %edx,%eax
8010176e:	c1 e0 04             	shl    $0x4,%eax
80101771:	83 c0 30             	add    $0x30,%eax
80101774:	05 c0 2b 11 80       	add    $0x80112bc0,%eax
80101779:	83 c0 10             	add    $0x10,%eax
8010177c:	c7 44 24 04 e8 92 10 	movl   $0x801092e8,0x4(%esp)
80101783:	80 
80101784:	89 04 24             	mov    %eax,(%esp)
80101787:	e8 54 40 00 00       	call   801057e0 <initsleeplock>
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
8010178c:	ff 45 e4             	incl   -0x1c(%ebp)
8010178f:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
80101793:	7e cf                	jle    80101764 <iinit+0x2d>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
80101795:	c7 44 24 04 a0 2b 11 	movl   $0x80112ba0,0x4(%esp)
8010179c:	80 
8010179d:	8b 45 08             	mov    0x8(%ebp),%eax
801017a0:	89 04 24             	mov    %eax,(%esp)
801017a3:	e8 f4 fc ff ff       	call   8010149c <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801017a8:	a1 b8 2b 11 80       	mov    0x80112bb8,%eax
801017ad:	8b 3d b4 2b 11 80    	mov    0x80112bb4,%edi
801017b3:	8b 35 b0 2b 11 80    	mov    0x80112bb0,%esi
801017b9:	8b 1d ac 2b 11 80    	mov    0x80112bac,%ebx
801017bf:	8b 0d a8 2b 11 80    	mov    0x80112ba8,%ecx
801017c5:	8b 15 a4 2b 11 80    	mov    0x80112ba4,%edx
801017cb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801017ce:	8b 15 a0 2b 11 80    	mov    0x80112ba0,%edx
801017d4:	89 44 24 1c          	mov    %eax,0x1c(%esp)
801017d8:	89 7c 24 18          	mov    %edi,0x18(%esp)
801017dc:	89 74 24 14          	mov    %esi,0x14(%esp)
801017e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801017e4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801017e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801017eb:	89 44 24 08          	mov    %eax,0x8(%esp)
801017ef:	89 d0                	mov    %edx,%eax
801017f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801017f5:	c7 04 24 f0 92 10 80 	movl   $0x801092f0,(%esp)
801017fc:	e8 c0 eb ff ff       	call   801003c1 <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101801:	83 c4 4c             	add    $0x4c,%esp
80101804:	5b                   	pop    %ebx
80101805:	5e                   	pop    %esi
80101806:	5f                   	pop    %edi
80101807:	5d                   	pop    %ebp
80101808:	c3                   	ret    

80101809 <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
80101809:	55                   	push   %ebp
8010180a:	89 e5                	mov    %esp,%ebp
8010180c:	83 ec 28             	sub    $0x28,%esp
8010180f:	8b 45 0c             	mov    0xc(%ebp),%eax
80101812:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101816:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010181d:	e9 9b 00 00 00       	jmp    801018bd <ialloc+0xb4>
    bp = bread(dev, IBLOCK(inum, sb));
80101822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101825:	c1 e8 03             	shr    $0x3,%eax
80101828:	89 c2                	mov    %eax,%edx
8010182a:	a1 b4 2b 11 80       	mov    0x80112bb4,%eax
8010182f:	01 d0                	add    %edx,%eax
80101831:	89 44 24 04          	mov    %eax,0x4(%esp)
80101835:	8b 45 08             	mov    0x8(%ebp),%eax
80101838:	89 04 24             	mov    %eax,(%esp)
8010183b:	e8 75 e9 ff ff       	call   801001b5 <bread>
80101840:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101843:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101846:	8d 50 5c             	lea    0x5c(%eax),%edx
80101849:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010184c:	83 e0 07             	and    $0x7,%eax
8010184f:	c1 e0 06             	shl    $0x6,%eax
80101852:	01 d0                	add    %edx,%eax
80101854:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
80101857:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010185a:	8b 00                	mov    (%eax),%eax
8010185c:	66 85 c0             	test   %ax,%ax
8010185f:	75 4e                	jne    801018af <ialloc+0xa6>
      memset(dip, 0, sizeof(*dip));
80101861:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
80101868:	00 
80101869:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80101870:	00 
80101871:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101874:	89 04 24             	mov    %eax,(%esp)
80101877:	e8 26 43 00 00       	call   80105ba2 <memset>
      dip->type = type;
8010187c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010187f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101882:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
80101885:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101888:	89 04 24             	mov    %eax,(%esp)
8010188b:	e8 77 20 00 00       	call   80103907 <log_write>
      brelse(bp);
80101890:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101893:	89 04 24             	mov    %eax,(%esp)
80101896:	e8 91 e9 ff ff       	call   8010022c <brelse>
      return iget(dev, inum);
8010189b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010189e:	89 44 24 04          	mov    %eax,0x4(%esp)
801018a2:	8b 45 08             	mov    0x8(%ebp),%eax
801018a5:	89 04 24             	mov    %eax,(%esp)
801018a8:	e8 ea 00 00 00       	call   80101997 <iget>
801018ad:	eb 2a                	jmp    801018d9 <ialloc+0xd0>
    }
    brelse(bp);
801018af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018b2:	89 04 24             	mov    %eax,(%esp)
801018b5:	e8 72 e9 ff ff       	call   8010022c <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801018ba:	ff 45 f4             	incl   -0xc(%ebp)
801018bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801018c0:	a1 a8 2b 11 80       	mov    0x80112ba8,%eax
801018c5:	39 c2                	cmp    %eax,%edx
801018c7:	0f 82 55 ff ff ff    	jb     80101822 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
801018cd:	c7 04 24 43 93 10 80 	movl   $0x80109343,(%esp)
801018d4:	e8 7b ec ff ff       	call   80100554 <panic>
}
801018d9:	c9                   	leave  
801018da:	c3                   	ret    

801018db <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
801018db:	55                   	push   %ebp
801018dc:	89 e5                	mov    %esp,%ebp
801018de:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801018e1:	8b 45 08             	mov    0x8(%ebp),%eax
801018e4:	8b 40 04             	mov    0x4(%eax),%eax
801018e7:	c1 e8 03             	shr    $0x3,%eax
801018ea:	89 c2                	mov    %eax,%edx
801018ec:	a1 b4 2b 11 80       	mov    0x80112bb4,%eax
801018f1:	01 c2                	add    %eax,%edx
801018f3:	8b 45 08             	mov    0x8(%ebp),%eax
801018f6:	8b 00                	mov    (%eax),%eax
801018f8:	89 54 24 04          	mov    %edx,0x4(%esp)
801018fc:	89 04 24             	mov    %eax,(%esp)
801018ff:	e8 b1 e8 ff ff       	call   801001b5 <bread>
80101904:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190a:	8d 50 5c             	lea    0x5c(%eax),%edx
8010190d:	8b 45 08             	mov    0x8(%ebp),%eax
80101910:	8b 40 04             	mov    0x4(%eax),%eax
80101913:	83 e0 07             	and    $0x7,%eax
80101916:	c1 e0 06             	shl    $0x6,%eax
80101919:	01 d0                	add    %edx,%eax
8010191b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
8010191e:	8b 45 08             	mov    0x8(%ebp),%eax
80101921:	8b 40 50             	mov    0x50(%eax),%eax
80101924:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101927:	66 89 02             	mov    %ax,(%edx)
  dip->major = ip->major;
8010192a:	8b 45 08             	mov    0x8(%ebp),%eax
8010192d:	66 8b 40 52          	mov    0x52(%eax),%ax
80101931:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101934:	66 89 42 02          	mov    %ax,0x2(%edx)
  dip->minor = ip->minor;
80101938:	8b 45 08             	mov    0x8(%ebp),%eax
8010193b:	8b 40 54             	mov    0x54(%eax),%eax
8010193e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80101941:	66 89 42 04          	mov    %ax,0x4(%edx)
  dip->nlink = ip->nlink;
80101945:	8b 45 08             	mov    0x8(%ebp),%eax
80101948:	66 8b 40 56          	mov    0x56(%eax),%ax
8010194c:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010194f:	66 89 42 06          	mov    %ax,0x6(%edx)
  dip->size = ip->size;
80101953:	8b 45 08             	mov    0x8(%ebp),%eax
80101956:	8b 50 58             	mov    0x58(%eax),%edx
80101959:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010195c:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010195f:	8b 45 08             	mov    0x8(%ebp),%eax
80101962:	8d 50 5c             	lea    0x5c(%eax),%edx
80101965:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101968:	83 c0 0c             	add    $0xc,%eax
8010196b:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101972:	00 
80101973:	89 54 24 04          	mov    %edx,0x4(%esp)
80101977:	89 04 24             	mov    %eax,(%esp)
8010197a:	e8 ec 42 00 00       	call   80105c6b <memmove>
  log_write(bp);
8010197f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101982:	89 04 24             	mov    %eax,(%esp)
80101985:	e8 7d 1f 00 00       	call   80103907 <log_write>
  brelse(bp);
8010198a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010198d:	89 04 24             	mov    %eax,(%esp)
80101990:	e8 97 e8 ff ff       	call   8010022c <brelse>
}
80101995:	c9                   	leave  
80101996:	c3                   	ret    

80101997 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101997:	55                   	push   %ebp
80101998:	89 e5                	mov    %esp,%ebp
8010199a:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010199d:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
801019a4:	e8 96 3f 00 00       	call   8010593f <acquire>

  // Is the inode already cached?
  empty = 0;
801019a9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801019b0:	c7 45 f4 f4 2b 11 80 	movl   $0x80112bf4,-0xc(%ebp)
801019b7:	eb 5c                	jmp    80101a15 <iget+0x7e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801019b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019bc:	8b 40 08             	mov    0x8(%eax),%eax
801019bf:	85 c0                	test   %eax,%eax
801019c1:	7e 35                	jle    801019f8 <iget+0x61>
801019c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019c6:	8b 00                	mov    (%eax),%eax
801019c8:	3b 45 08             	cmp    0x8(%ebp),%eax
801019cb:	75 2b                	jne    801019f8 <iget+0x61>
801019cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019d0:	8b 40 04             	mov    0x4(%eax),%eax
801019d3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801019d6:	75 20                	jne    801019f8 <iget+0x61>
      ip->ref++;
801019d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019db:	8b 40 08             	mov    0x8(%eax),%eax
801019de:	8d 50 01             	lea    0x1(%eax),%edx
801019e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019e4:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
801019e7:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
801019ee:	e8 b6 3f 00 00       	call   801059a9 <release>
      return ip;
801019f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019f6:	eb 72                	jmp    80101a6a <iget+0xd3>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801019f8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801019fc:	75 10                	jne    80101a0e <iget+0x77>
801019fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a01:	8b 40 08             	mov    0x8(%eax),%eax
80101a04:	85 c0                	test   %eax,%eax
80101a06:	75 06                	jne    80101a0e <iget+0x77>
      empty = ip;
80101a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a0b:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101a0e:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
80101a15:	81 7d f4 14 48 11 80 	cmpl   $0x80114814,-0xc(%ebp)
80101a1c:	72 9b                	jb     801019b9 <iget+0x22>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101a1e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101a22:	75 0c                	jne    80101a30 <iget+0x99>
    panic("iget: no inodes");
80101a24:	c7 04 24 55 93 10 80 	movl   $0x80109355,(%esp)
80101a2b:	e8 24 eb ff ff       	call   80100554 <panic>

  ip = empty;
80101a30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a33:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101a36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a39:	8b 55 08             	mov    0x8(%ebp),%edx
80101a3c:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101a3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a41:	8b 55 0c             	mov    0xc(%ebp),%edx
80101a44:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
80101a47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a4a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a54:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
80101a5b:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101a62:	e8 42 3f 00 00       	call   801059a9 <release>

  return ip;
80101a67:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101a6a:	c9                   	leave  
80101a6b:	c3                   	ret    

80101a6c <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101a6c:	55                   	push   %ebp
80101a6d:	89 e5                	mov    %esp,%ebp
80101a6f:	83 ec 18             	sub    $0x18,%esp
  acquire(&icache.lock);
80101a72:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101a79:	e8 c1 3e 00 00       	call   8010593f <acquire>
  ip->ref++;
80101a7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101a81:	8b 40 08             	mov    0x8(%eax),%eax
80101a84:	8d 50 01             	lea    0x1(%eax),%edx
80101a87:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8a:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a8d:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101a94:	e8 10 3f 00 00       	call   801059a9 <release>
  return ip;
80101a99:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101a9c:	c9                   	leave  
80101a9d:	c3                   	ret    

80101a9e <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
80101a9e:	55                   	push   %ebp
80101a9f:	89 e5                	mov    %esp,%ebp
80101aa1:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101aa4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101aa8:	74 0a                	je     80101ab4 <ilock+0x16>
80101aaa:	8b 45 08             	mov    0x8(%ebp),%eax
80101aad:	8b 40 08             	mov    0x8(%eax),%eax
80101ab0:	85 c0                	test   %eax,%eax
80101ab2:	7f 0c                	jg     80101ac0 <ilock+0x22>
    panic("ilock");
80101ab4:	c7 04 24 65 93 10 80 	movl   $0x80109365,(%esp)
80101abb:	e8 94 ea ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101ac0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac3:	83 c0 0c             	add    $0xc,%eax
80101ac6:	89 04 24             	mov    %eax,(%esp)
80101ac9:	e8 4c 3d 00 00       	call   8010581a <acquiresleep>

  if(ip->valid == 0){
80101ace:	8b 45 08             	mov    0x8(%ebp),%eax
80101ad1:	8b 40 4c             	mov    0x4c(%eax),%eax
80101ad4:	85 c0                	test   %eax,%eax
80101ad6:	0f 85 ca 00 00 00    	jne    80101ba6 <ilock+0x108>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101adc:	8b 45 08             	mov    0x8(%ebp),%eax
80101adf:	8b 40 04             	mov    0x4(%eax),%eax
80101ae2:	c1 e8 03             	shr    $0x3,%eax
80101ae5:	89 c2                	mov    %eax,%edx
80101ae7:	a1 b4 2b 11 80       	mov    0x80112bb4,%eax
80101aec:	01 c2                	add    %eax,%edx
80101aee:	8b 45 08             	mov    0x8(%ebp),%eax
80101af1:	8b 00                	mov    (%eax),%eax
80101af3:	89 54 24 04          	mov    %edx,0x4(%esp)
80101af7:	89 04 24             	mov    %eax,(%esp)
80101afa:	e8 b6 e6 ff ff       	call   801001b5 <bread>
80101aff:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b05:	8d 50 5c             	lea    0x5c(%eax),%edx
80101b08:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0b:	8b 40 04             	mov    0x4(%eax),%eax
80101b0e:	83 e0 07             	and    $0x7,%eax
80101b11:	c1 e0 06             	shl    $0x6,%eax
80101b14:	01 d0                	add    %edx,%eax
80101b16:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101b19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b1c:	8b 00                	mov    (%eax),%eax
80101b1e:	8b 55 08             	mov    0x8(%ebp),%edx
80101b21:	66 89 42 50          	mov    %ax,0x50(%edx)
    ip->major = dip->major;
80101b25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b28:	66 8b 40 02          	mov    0x2(%eax),%ax
80101b2c:	8b 55 08             	mov    0x8(%ebp),%edx
80101b2f:	66 89 42 52          	mov    %ax,0x52(%edx)
    ip->minor = dip->minor;
80101b33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b36:	8b 40 04             	mov    0x4(%eax),%eax
80101b39:	8b 55 08             	mov    0x8(%ebp),%edx
80101b3c:	66 89 42 54          	mov    %ax,0x54(%edx)
    ip->nlink = dip->nlink;
80101b40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b43:	66 8b 40 06          	mov    0x6(%eax),%ax
80101b47:	8b 55 08             	mov    0x8(%ebp),%edx
80101b4a:	66 89 42 56          	mov    %ax,0x56(%edx)
    ip->size = dip->size;
80101b4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b51:	8b 50 08             	mov    0x8(%eax),%edx
80101b54:	8b 45 08             	mov    0x8(%ebp),%eax
80101b57:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101b5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101b5d:	8d 50 0c             	lea    0xc(%eax),%edx
80101b60:	8b 45 08             	mov    0x8(%ebp),%eax
80101b63:	83 c0 5c             	add    $0x5c,%eax
80101b66:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101b6d:	00 
80101b6e:	89 54 24 04          	mov    %edx,0x4(%esp)
80101b72:	89 04 24             	mov    %eax,(%esp)
80101b75:	e8 f1 40 00 00       	call   80105c6b <memmove>
    brelse(bp);
80101b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101b7d:	89 04 24             	mov    %eax,(%esp)
80101b80:	e8 a7 e6 ff ff       	call   8010022c <brelse>
    ip->valid = 1;
80101b85:	8b 45 08             	mov    0x8(%ebp),%eax
80101b88:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101b8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b92:	8b 40 50             	mov    0x50(%eax),%eax
80101b95:	66 85 c0             	test   %ax,%ax
80101b98:	75 0c                	jne    80101ba6 <ilock+0x108>
      panic("ilock: no type");
80101b9a:	c7 04 24 6b 93 10 80 	movl   $0x8010936b,(%esp)
80101ba1:	e8 ae e9 ff ff       	call   80100554 <panic>
  }
}
80101ba6:	c9                   	leave  
80101ba7:	c3                   	ret    

80101ba8 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101ba8:	55                   	push   %ebp
80101ba9:	89 e5                	mov    %esp,%ebp
80101bab:	83 ec 18             	sub    $0x18,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101bae:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101bb2:	74 1c                	je     80101bd0 <iunlock+0x28>
80101bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb7:	83 c0 0c             	add    $0xc,%eax
80101bba:	89 04 24             	mov    %eax,(%esp)
80101bbd:	e8 f5 3c 00 00       	call   801058b7 <holdingsleep>
80101bc2:	85 c0                	test   %eax,%eax
80101bc4:	74 0a                	je     80101bd0 <iunlock+0x28>
80101bc6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc9:	8b 40 08             	mov    0x8(%eax),%eax
80101bcc:	85 c0                	test   %eax,%eax
80101bce:	7f 0c                	jg     80101bdc <iunlock+0x34>
    panic("iunlock");
80101bd0:	c7 04 24 7a 93 10 80 	movl   $0x8010937a,(%esp)
80101bd7:	e8 78 e9 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101bdc:	8b 45 08             	mov    0x8(%ebp),%eax
80101bdf:	83 c0 0c             	add    $0xc,%eax
80101be2:	89 04 24             	mov    %eax,(%esp)
80101be5:	e8 8b 3c 00 00       	call   80105875 <releasesleep>
}
80101bea:	c9                   	leave  
80101beb:	c3                   	ret    

80101bec <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101bec:	55                   	push   %ebp
80101bed:	89 e5                	mov    %esp,%ebp
80101bef:	83 ec 28             	sub    $0x28,%esp
  acquiresleep(&ip->lock);
80101bf2:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf5:	83 c0 0c             	add    $0xc,%eax
80101bf8:	89 04 24             	mov    %eax,(%esp)
80101bfb:	e8 1a 3c 00 00       	call   8010581a <acquiresleep>
  if(ip->valid && ip->nlink == 0){
80101c00:	8b 45 08             	mov    0x8(%ebp),%eax
80101c03:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c06:	85 c0                	test   %eax,%eax
80101c08:	74 5c                	je     80101c66 <iput+0x7a>
80101c0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0d:	66 8b 40 56          	mov    0x56(%eax),%ax
80101c11:	66 85 c0             	test   %ax,%ax
80101c14:	75 50                	jne    80101c66 <iput+0x7a>
    acquire(&icache.lock);
80101c16:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101c1d:	e8 1d 3d 00 00       	call   8010593f <acquire>
    int r = ip->ref;
80101c22:	8b 45 08             	mov    0x8(%ebp),%eax
80101c25:	8b 40 08             	mov    0x8(%eax),%eax
80101c28:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101c2b:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101c32:	e8 72 3d 00 00       	call   801059a9 <release>
    if(r == 1){
80101c37:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101c3b:	75 29                	jne    80101c66 <iput+0x7a>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101c3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c40:	89 04 24             	mov    %eax,(%esp)
80101c43:	e8 86 01 00 00       	call   80101dce <itrunc>
      ip->type = 0;
80101c48:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4b:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101c51:	8b 45 08             	mov    0x8(%ebp),%eax
80101c54:	89 04 24             	mov    %eax,(%esp)
80101c57:	e8 7f fc ff ff       	call   801018db <iupdate>
      ip->valid = 0;
80101c5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5f:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101c66:	8b 45 08             	mov    0x8(%ebp),%eax
80101c69:	83 c0 0c             	add    $0xc,%eax
80101c6c:	89 04 24             	mov    %eax,(%esp)
80101c6f:	e8 01 3c 00 00       	call   80105875 <releasesleep>

  acquire(&icache.lock);
80101c74:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101c7b:	e8 bf 3c 00 00       	call   8010593f <acquire>
  ip->ref--;
80101c80:	8b 45 08             	mov    0x8(%ebp),%eax
80101c83:	8b 40 08             	mov    0x8(%eax),%eax
80101c86:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c89:	8b 45 08             	mov    0x8(%ebp),%eax
80101c8c:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c8f:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101c96:	e8 0e 3d 00 00       	call   801059a9 <release>
}
80101c9b:	c9                   	leave  
80101c9c:	c3                   	ret    

80101c9d <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c9d:	55                   	push   %ebp
80101c9e:	89 e5                	mov    %esp,%ebp
80101ca0:	83 ec 18             	sub    $0x18,%esp
  iunlock(ip);
80101ca3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca6:	89 04 24             	mov    %eax,(%esp)
80101ca9:	e8 fa fe ff ff       	call   80101ba8 <iunlock>
  iput(ip);
80101cae:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb1:	89 04 24             	mov    %eax,(%esp)
80101cb4:	e8 33 ff ff ff       	call   80101bec <iput>
}
80101cb9:	c9                   	leave  
80101cba:	c3                   	ret    

80101cbb <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101cbb:	55                   	push   %ebp
80101cbc:	89 e5                	mov    %esp,%ebp
80101cbe:	53                   	push   %ebx
80101cbf:	83 ec 24             	sub    $0x24,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101cc2:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101cc6:	77 3e                	ja     80101d06 <bmap+0x4b>
    if((addr = ip->addrs[bn]) == 0)
80101cc8:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccb:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cce:	83 c2 14             	add    $0x14,%edx
80101cd1:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101cd5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cd8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cdc:	75 20                	jne    80101cfe <bmap+0x43>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101cde:	8b 45 08             	mov    0x8(%ebp),%eax
80101ce1:	8b 00                	mov    (%eax),%eax
80101ce3:	89 04 24             	mov    %eax,(%esp)
80101ce6:	e8 48 f8 ff ff       	call   80101533 <balloc>
80101ceb:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cee:	8b 45 08             	mov    0x8(%ebp),%eax
80101cf1:	8b 55 0c             	mov    0xc(%ebp),%edx
80101cf4:	8d 4a 14             	lea    0x14(%edx),%ecx
80101cf7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cfa:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101cfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d01:	e9 c2 00 00 00       	jmp    80101dc8 <bmap+0x10d>
  }
  bn -= NDIRECT;
80101d06:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101d0a:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101d0e:	0f 87 a8 00 00 00    	ja     80101dbc <bmap+0x101>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101d14:	8b 45 08             	mov    0x8(%ebp),%eax
80101d17:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101d1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d20:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d24:	75 1c                	jne    80101d42 <bmap+0x87>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101d26:	8b 45 08             	mov    0x8(%ebp),%eax
80101d29:	8b 00                	mov    (%eax),%eax
80101d2b:	89 04 24             	mov    %eax,(%esp)
80101d2e:	e8 00 f8 ff ff       	call   80101533 <balloc>
80101d33:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d36:	8b 45 08             	mov    0x8(%ebp),%eax
80101d39:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d3c:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101d42:	8b 45 08             	mov    0x8(%ebp),%eax
80101d45:	8b 00                	mov    (%eax),%eax
80101d47:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d4a:	89 54 24 04          	mov    %edx,0x4(%esp)
80101d4e:	89 04 24             	mov    %eax,(%esp)
80101d51:	e8 5f e4 ff ff       	call   801001b5 <bread>
80101d56:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101d5c:	83 c0 5c             	add    $0x5c,%eax
80101d5f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101d62:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d65:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d6f:	01 d0                	add    %edx,%eax
80101d71:	8b 00                	mov    (%eax),%eax
80101d73:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d76:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d7a:	75 30                	jne    80101dac <bmap+0xf1>
      a[bn] = addr = balloc(ip->dev);
80101d7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d7f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d86:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d89:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101d8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8f:	8b 00                	mov    (%eax),%eax
80101d91:	89 04 24             	mov    %eax,(%esp)
80101d94:	e8 9a f7 ff ff       	call   80101533 <balloc>
80101d99:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d9f:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101da1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101da4:	89 04 24             	mov    %eax,(%esp)
80101da7:	e8 5b 1b 00 00       	call   80103907 <log_write>
    }
    brelse(bp);
80101dac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101daf:	89 04 24             	mov    %eax,(%esp)
80101db2:	e8 75 e4 ff ff       	call   8010022c <brelse>
    return addr;
80101db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101dba:	eb 0c                	jmp    80101dc8 <bmap+0x10d>
  }

  panic("bmap: out of range");
80101dbc:	c7 04 24 82 93 10 80 	movl   $0x80109382,(%esp)
80101dc3:	e8 8c e7 ff ff       	call   80100554 <panic>
}
80101dc8:	83 c4 24             	add    $0x24,%esp
80101dcb:	5b                   	pop    %ebx
80101dcc:	5d                   	pop    %ebp
80101dcd:	c3                   	ret    

80101dce <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101dce:	55                   	push   %ebp
80101dcf:	89 e5                	mov    %esp,%ebp
80101dd1:	83 ec 28             	sub    $0x28,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101dd4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101ddb:	eb 43                	jmp    80101e20 <itrunc+0x52>
    if(ip->addrs[i]){
80101ddd:	8b 45 08             	mov    0x8(%ebp),%eax
80101de0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101de3:	83 c2 14             	add    $0x14,%edx
80101de6:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101dea:	85 c0                	test   %eax,%eax
80101dec:	74 2f                	je     80101e1d <itrunc+0x4f>
      bfree(ip->dev, ip->addrs[i]);
80101dee:	8b 45 08             	mov    0x8(%ebp),%eax
80101df1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101df4:	83 c2 14             	add    $0x14,%edx
80101df7:	8b 54 90 0c          	mov    0xc(%eax,%edx,4),%edx
80101dfb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dfe:	8b 00                	mov    (%eax),%eax
80101e00:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e04:	89 04 24             	mov    %eax,(%esp)
80101e07:	e8 61 f8 ff ff       	call   8010166d <bfree>
      ip->addrs[i] = 0;
80101e0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101e12:	83 c2 14             	add    $0x14,%edx
80101e15:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101e1c:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101e1d:	ff 45 f4             	incl   -0xc(%ebp)
80101e20:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101e24:	7e b7                	jle    80101ddd <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
80101e26:	8b 45 08             	mov    0x8(%ebp),%eax
80101e29:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e2f:	85 c0                	test   %eax,%eax
80101e31:	0f 84 a3 00 00 00    	je     80101eda <itrunc+0x10c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101e37:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3a:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101e40:	8b 45 08             	mov    0x8(%ebp),%eax
80101e43:	8b 00                	mov    (%eax),%eax
80101e45:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e49:	89 04 24             	mov    %eax,(%esp)
80101e4c:	e8 64 e3 ff ff       	call   801001b5 <bread>
80101e51:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101e54:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101e57:	83 c0 5c             	add    $0x5c,%eax
80101e5a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101e5d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e64:	eb 3a                	jmp    80101ea0 <itrunc+0xd2>
      if(a[j])
80101e66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e69:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e70:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e73:	01 d0                	add    %edx,%eax
80101e75:	8b 00                	mov    (%eax),%eax
80101e77:	85 c0                	test   %eax,%eax
80101e79:	74 22                	je     80101e9d <itrunc+0xcf>
        bfree(ip->dev, a[j]);
80101e7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e7e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e85:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e88:	01 d0                	add    %edx,%eax
80101e8a:	8b 10                	mov    (%eax),%edx
80101e8c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8f:	8b 00                	mov    (%eax),%eax
80101e91:	89 54 24 04          	mov    %edx,0x4(%esp)
80101e95:	89 04 24             	mov    %eax,(%esp)
80101e98:	e8 d0 f7 ff ff       	call   8010166d <bfree>
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101e9d:	ff 45 f0             	incl   -0x10(%ebp)
80101ea0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ea3:	83 f8 7f             	cmp    $0x7f,%eax
80101ea6:	76 be                	jbe    80101e66 <itrunc+0x98>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101ea8:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101eab:	89 04 24             	mov    %eax,(%esp)
80101eae:	e8 79 e3 ff ff       	call   8010022c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101eb3:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb6:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ebc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebf:	8b 00                	mov    (%eax),%eax
80101ec1:	89 54 24 04          	mov    %edx,0x4(%esp)
80101ec5:	89 04 24             	mov    %eax,(%esp)
80101ec8:	e8 a0 f7 ff ff       	call   8010166d <bfree>
    ip->addrs[NDIRECT] = 0;
80101ecd:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed0:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101ed7:	00 00 00 
  }

  ip->size = 0;
80101eda:	8b 45 08             	mov    0x8(%ebp),%eax
80101edd:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101ee4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee7:	89 04 24             	mov    %eax,(%esp)
80101eea:	e8 ec f9 ff ff       	call   801018db <iupdate>
}
80101eef:	c9                   	leave  
80101ef0:	c3                   	ret    

80101ef1 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101ef1:	55                   	push   %ebp
80101ef2:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101ef4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef7:	8b 00                	mov    (%eax),%eax
80101ef9:	89 c2                	mov    %eax,%edx
80101efb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101efe:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101f01:	8b 45 08             	mov    0x8(%ebp),%eax
80101f04:	8b 50 04             	mov    0x4(%eax),%edx
80101f07:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f0a:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101f0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f10:	8b 40 50             	mov    0x50(%eax),%eax
80101f13:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f16:	66 89 02             	mov    %ax,(%edx)
  st->nlink = ip->nlink;
80101f19:	8b 45 08             	mov    0x8(%ebp),%eax
80101f1c:	66 8b 40 56          	mov    0x56(%eax),%ax
80101f20:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f23:	66 89 42 0c          	mov    %ax,0xc(%edx)
  st->size = ip->size;
80101f27:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2a:	8b 50 58             	mov    0x58(%eax),%edx
80101f2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101f30:	89 50 10             	mov    %edx,0x10(%eax)
}
80101f33:	5d                   	pop    %ebp
80101f34:	c3                   	ret    

80101f35 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101f35:	55                   	push   %ebp
80101f36:	89 e5                	mov    %esp,%ebp
80101f38:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101f3b:	8b 45 08             	mov    0x8(%ebp),%eax
80101f3e:	8b 40 50             	mov    0x50(%eax),%eax
80101f41:	66 83 f8 03          	cmp    $0x3,%ax
80101f45:	75 60                	jne    80101fa7 <readi+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101f47:	8b 45 08             	mov    0x8(%ebp),%eax
80101f4a:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f4e:	66 85 c0             	test   %ax,%ax
80101f51:	78 20                	js     80101f73 <readi+0x3e>
80101f53:	8b 45 08             	mov    0x8(%ebp),%eax
80101f56:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f5a:	66 83 f8 09          	cmp    $0x9,%ax
80101f5e:	7f 13                	jg     80101f73 <readi+0x3e>
80101f60:	8b 45 08             	mov    0x8(%ebp),%eax
80101f63:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f67:	98                   	cwtl   
80101f68:	8b 04 c5 40 2b 11 80 	mov    -0x7feed4c0(,%eax,8),%eax
80101f6f:	85 c0                	test   %eax,%eax
80101f71:	75 0a                	jne    80101f7d <readi+0x48>
      return -1;
80101f73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f78:	e9 1a 01 00 00       	jmp    80102097 <readi+0x162>
    return devsw[ip->major].read(ip, dst, n);
80101f7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f80:	66 8b 40 52          	mov    0x52(%eax),%ax
80101f84:	98                   	cwtl   
80101f85:	8b 04 c5 40 2b 11 80 	mov    -0x7feed4c0(,%eax,8),%eax
80101f8c:	8b 55 14             	mov    0x14(%ebp),%edx
80101f8f:	89 54 24 08          	mov    %edx,0x8(%esp)
80101f93:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f96:	89 54 24 04          	mov    %edx,0x4(%esp)
80101f9a:	8b 55 08             	mov    0x8(%ebp),%edx
80101f9d:	89 14 24             	mov    %edx,(%esp)
80101fa0:	ff d0                	call   *%eax
80101fa2:	e9 f0 00 00 00       	jmp    80102097 <readi+0x162>
  }

  if(off > ip->size || off + n < off)
80101fa7:	8b 45 08             	mov    0x8(%ebp),%eax
80101faa:	8b 40 58             	mov    0x58(%eax),%eax
80101fad:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fb0:	72 0d                	jb     80101fbf <readi+0x8a>
80101fb2:	8b 45 14             	mov    0x14(%ebp),%eax
80101fb5:	8b 55 10             	mov    0x10(%ebp),%edx
80101fb8:	01 d0                	add    %edx,%eax
80101fba:	3b 45 10             	cmp    0x10(%ebp),%eax
80101fbd:	73 0a                	jae    80101fc9 <readi+0x94>
    return -1;
80101fbf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101fc4:	e9 ce 00 00 00       	jmp    80102097 <readi+0x162>
  if(off + n > ip->size)
80101fc9:	8b 45 14             	mov    0x14(%ebp),%eax
80101fcc:	8b 55 10             	mov    0x10(%ebp),%edx
80101fcf:	01 c2                	add    %eax,%edx
80101fd1:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd4:	8b 40 58             	mov    0x58(%eax),%eax
80101fd7:	39 c2                	cmp    %eax,%edx
80101fd9:	76 0c                	jbe    80101fe7 <readi+0xb2>
    n = ip->size - off;
80101fdb:	8b 45 08             	mov    0x8(%ebp),%eax
80101fde:	8b 40 58             	mov    0x58(%eax),%eax
80101fe1:	2b 45 10             	sub    0x10(%ebp),%eax
80101fe4:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101fe7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101fee:	e9 95 00 00 00       	jmp    80102088 <readi+0x153>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101ff3:	8b 45 10             	mov    0x10(%ebp),%eax
80101ff6:	c1 e8 09             	shr    $0x9,%eax
80101ff9:	89 44 24 04          	mov    %eax,0x4(%esp)
80101ffd:	8b 45 08             	mov    0x8(%ebp),%eax
80102000:	89 04 24             	mov    %eax,(%esp)
80102003:	e8 b3 fc ff ff       	call   80101cbb <bmap>
80102008:	8b 55 08             	mov    0x8(%ebp),%edx
8010200b:	8b 12                	mov    (%edx),%edx
8010200d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102011:	89 14 24             	mov    %edx,(%esp)
80102014:	e8 9c e1 ff ff       	call   801001b5 <bread>
80102019:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010201c:	8b 45 10             	mov    0x10(%ebp),%eax
8010201f:	25 ff 01 00 00       	and    $0x1ff,%eax
80102024:	89 c2                	mov    %eax,%edx
80102026:	b8 00 02 00 00       	mov    $0x200,%eax
8010202b:	29 d0                	sub    %edx,%eax
8010202d:	89 c1                	mov    %eax,%ecx
8010202f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102032:	8b 55 14             	mov    0x14(%ebp),%edx
80102035:	29 c2                	sub    %eax,%edx
80102037:	89 c8                	mov    %ecx,%eax
80102039:	39 d0                	cmp    %edx,%eax
8010203b:	76 02                	jbe    8010203f <readi+0x10a>
8010203d:	89 d0                	mov    %edx,%eax
8010203f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80102042:	8b 45 10             	mov    0x10(%ebp),%eax
80102045:	25 ff 01 00 00       	and    $0x1ff,%eax
8010204a:	8d 50 50             	lea    0x50(%eax),%edx
8010204d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102050:	01 d0                	add    %edx,%eax
80102052:	8d 50 0c             	lea    0xc(%eax),%edx
80102055:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102058:	89 44 24 08          	mov    %eax,0x8(%esp)
8010205c:	89 54 24 04          	mov    %edx,0x4(%esp)
80102060:	8b 45 0c             	mov    0xc(%ebp),%eax
80102063:	89 04 24             	mov    %eax,(%esp)
80102066:	e8 00 3c 00 00       	call   80105c6b <memmove>
    brelse(bp);
8010206b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010206e:	89 04 24             	mov    %eax,(%esp)
80102071:	e8 b6 e1 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102076:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102079:	01 45 f4             	add    %eax,-0xc(%ebp)
8010207c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010207f:	01 45 10             	add    %eax,0x10(%ebp)
80102082:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102085:	01 45 0c             	add    %eax,0xc(%ebp)
80102088:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010208b:	3b 45 14             	cmp    0x14(%ebp),%eax
8010208e:	0f 82 5f ff ff ff    	jb     80101ff3 <readi+0xbe>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80102094:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102097:	c9                   	leave  
80102098:	c3                   	ret    

80102099 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102099:	55                   	push   %ebp
8010209a:	89 e5                	mov    %esp,%ebp
8010209c:	83 ec 28             	sub    $0x28,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010209f:	8b 45 08             	mov    0x8(%ebp),%eax
801020a2:	8b 40 50             	mov    0x50(%eax),%eax
801020a5:	66 83 f8 03          	cmp    $0x3,%ax
801020a9:	75 60                	jne    8010210b <writei+0x72>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801020ab:	8b 45 08             	mov    0x8(%ebp),%eax
801020ae:	66 8b 40 52          	mov    0x52(%eax),%ax
801020b2:	66 85 c0             	test   %ax,%ax
801020b5:	78 20                	js     801020d7 <writei+0x3e>
801020b7:	8b 45 08             	mov    0x8(%ebp),%eax
801020ba:	66 8b 40 52          	mov    0x52(%eax),%ax
801020be:	66 83 f8 09          	cmp    $0x9,%ax
801020c2:	7f 13                	jg     801020d7 <writei+0x3e>
801020c4:	8b 45 08             	mov    0x8(%ebp),%eax
801020c7:	66 8b 40 52          	mov    0x52(%eax),%ax
801020cb:	98                   	cwtl   
801020cc:	8b 04 c5 44 2b 11 80 	mov    -0x7feed4bc(,%eax,8),%eax
801020d3:	85 c0                	test   %eax,%eax
801020d5:	75 0a                	jne    801020e1 <writei+0x48>
      return -1;
801020d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020dc:	e9 45 01 00 00       	jmp    80102226 <writei+0x18d>
    return devsw[ip->major].write(ip, src, n);
801020e1:	8b 45 08             	mov    0x8(%ebp),%eax
801020e4:	66 8b 40 52          	mov    0x52(%eax),%ax
801020e8:	98                   	cwtl   
801020e9:	8b 04 c5 44 2b 11 80 	mov    -0x7feed4bc(,%eax,8),%eax
801020f0:	8b 55 14             	mov    0x14(%ebp),%edx
801020f3:	89 54 24 08          	mov    %edx,0x8(%esp)
801020f7:	8b 55 0c             	mov    0xc(%ebp),%edx
801020fa:	89 54 24 04          	mov    %edx,0x4(%esp)
801020fe:	8b 55 08             	mov    0x8(%ebp),%edx
80102101:	89 14 24             	mov    %edx,(%esp)
80102104:	ff d0                	call   *%eax
80102106:	e9 1b 01 00 00       	jmp    80102226 <writei+0x18d>
  }

  if(off > ip->size || off + n < off)
8010210b:	8b 45 08             	mov    0x8(%ebp),%eax
8010210e:	8b 40 58             	mov    0x58(%eax),%eax
80102111:	3b 45 10             	cmp    0x10(%ebp),%eax
80102114:	72 0d                	jb     80102123 <writei+0x8a>
80102116:	8b 45 14             	mov    0x14(%ebp),%eax
80102119:	8b 55 10             	mov    0x10(%ebp),%edx
8010211c:	01 d0                	add    %edx,%eax
8010211e:	3b 45 10             	cmp    0x10(%ebp),%eax
80102121:	73 0a                	jae    8010212d <writei+0x94>
    return -1;
80102123:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102128:	e9 f9 00 00 00       	jmp    80102226 <writei+0x18d>
  if(off + n > MAXFILE*BSIZE)
8010212d:	8b 45 14             	mov    0x14(%ebp),%eax
80102130:	8b 55 10             	mov    0x10(%ebp),%edx
80102133:	01 d0                	add    %edx,%eax
80102135:	3d 00 18 01 00       	cmp    $0x11800,%eax
8010213a:	76 0a                	jbe    80102146 <writei+0xad>
    return -1;
8010213c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102141:	e9 e0 00 00 00       	jmp    80102226 <writei+0x18d>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102146:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010214d:	e9 a0 00 00 00       	jmp    801021f2 <writei+0x159>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102152:	8b 45 10             	mov    0x10(%ebp),%eax
80102155:	c1 e8 09             	shr    $0x9,%eax
80102158:	89 44 24 04          	mov    %eax,0x4(%esp)
8010215c:	8b 45 08             	mov    0x8(%ebp),%eax
8010215f:	89 04 24             	mov    %eax,(%esp)
80102162:	e8 54 fb ff ff       	call   80101cbb <bmap>
80102167:	8b 55 08             	mov    0x8(%ebp),%edx
8010216a:	8b 12                	mov    (%edx),%edx
8010216c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102170:	89 14 24             	mov    %edx,(%esp)
80102173:	e8 3d e0 ff ff       	call   801001b5 <bread>
80102178:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
8010217b:	8b 45 10             	mov    0x10(%ebp),%eax
8010217e:	25 ff 01 00 00       	and    $0x1ff,%eax
80102183:	89 c2                	mov    %eax,%edx
80102185:	b8 00 02 00 00       	mov    $0x200,%eax
8010218a:	29 d0                	sub    %edx,%eax
8010218c:	89 c1                	mov    %eax,%ecx
8010218e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102191:	8b 55 14             	mov    0x14(%ebp),%edx
80102194:	29 c2                	sub    %eax,%edx
80102196:	89 c8                	mov    %ecx,%eax
80102198:	39 d0                	cmp    %edx,%eax
8010219a:	76 02                	jbe    8010219e <writei+0x105>
8010219c:	89 d0                	mov    %edx,%eax
8010219e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801021a1:	8b 45 10             	mov    0x10(%ebp),%eax
801021a4:	25 ff 01 00 00       	and    $0x1ff,%eax
801021a9:	8d 50 50             	lea    0x50(%eax),%edx
801021ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021af:	01 d0                	add    %edx,%eax
801021b1:	8d 50 0c             	lea    0xc(%eax),%edx
801021b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021b7:	89 44 24 08          	mov    %eax,0x8(%esp)
801021bb:	8b 45 0c             	mov    0xc(%ebp),%eax
801021be:	89 44 24 04          	mov    %eax,0x4(%esp)
801021c2:	89 14 24             	mov    %edx,(%esp)
801021c5:	e8 a1 3a 00 00       	call   80105c6b <memmove>
    log_write(bp);
801021ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021cd:	89 04 24             	mov    %eax,(%esp)
801021d0:	e8 32 17 00 00       	call   80103907 <log_write>
    brelse(bp);
801021d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801021d8:	89 04 24             	mov    %eax,(%esp)
801021db:	e8 4c e0 ff ff       	call   8010022c <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801021e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021e3:	01 45 f4             	add    %eax,-0xc(%ebp)
801021e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021e9:	01 45 10             	add    %eax,0x10(%ebp)
801021ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801021ef:	01 45 0c             	add    %eax,0xc(%ebp)
801021f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801021f5:	3b 45 14             	cmp    0x14(%ebp),%eax
801021f8:	0f 82 54 ff ff ff    	jb     80102152 <writei+0xb9>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801021fe:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102202:	74 1f                	je     80102223 <writei+0x18a>
80102204:	8b 45 08             	mov    0x8(%ebp),%eax
80102207:	8b 40 58             	mov    0x58(%eax),%eax
8010220a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010220d:	73 14                	jae    80102223 <writei+0x18a>
    ip->size = off;
8010220f:	8b 45 08             	mov    0x8(%ebp),%eax
80102212:	8b 55 10             	mov    0x10(%ebp),%edx
80102215:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
80102218:	8b 45 08             	mov    0x8(%ebp),%eax
8010221b:	89 04 24             	mov    %eax,(%esp)
8010221e:	e8 b8 f6 ff ff       	call   801018db <iupdate>
  }
  return n;
80102223:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102226:	c9                   	leave  
80102227:	c3                   	ret    

80102228 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102228:	55                   	push   %ebp
80102229:	89 e5                	mov    %esp,%ebp
8010222b:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
8010222e:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102235:	00 
80102236:	8b 45 0c             	mov    0xc(%ebp),%eax
80102239:	89 44 24 04          	mov    %eax,0x4(%esp)
8010223d:	8b 45 08             	mov    0x8(%ebp),%eax
80102240:	89 04 24             	mov    %eax,(%esp)
80102243:	e8 c2 3a 00 00       	call   80105d0a <strncmp>
}
80102248:	c9                   	leave  
80102249:	c3                   	ret    

8010224a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010224a:	55                   	push   %ebp
8010224b:	89 e5                	mov    %esp,%ebp
8010224d:	83 ec 38             	sub    $0x38,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102250:	8b 45 08             	mov    0x8(%ebp),%eax
80102253:	8b 40 50             	mov    0x50(%eax),%eax
80102256:	66 83 f8 01          	cmp    $0x1,%ax
8010225a:	74 0c                	je     80102268 <dirlookup+0x1e>
    panic("dirlookup not DIR");
8010225c:	c7 04 24 95 93 10 80 	movl   $0x80109395,(%esp)
80102263:	e8 ec e2 ff ff       	call   80100554 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
80102268:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010226f:	e9 86 00 00 00       	jmp    801022fa <dirlookup+0xb0>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102274:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010227b:	00 
8010227c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010227f:	89 44 24 08          	mov    %eax,0x8(%esp)
80102283:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102286:	89 44 24 04          	mov    %eax,0x4(%esp)
8010228a:	8b 45 08             	mov    0x8(%ebp),%eax
8010228d:	89 04 24             	mov    %eax,(%esp)
80102290:	e8 a0 fc ff ff       	call   80101f35 <readi>
80102295:	83 f8 10             	cmp    $0x10,%eax
80102298:	74 0c                	je     801022a6 <dirlookup+0x5c>
      panic("dirlookup read");
8010229a:	c7 04 24 a7 93 10 80 	movl   $0x801093a7,(%esp)
801022a1:	e8 ae e2 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
801022a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801022a9:	66 85 c0             	test   %ax,%ax
801022ac:	75 02                	jne    801022b0 <dirlookup+0x66>
      continue;
801022ae:	eb 46                	jmp    801022f6 <dirlookup+0xac>
    if(namecmp(name, de.name) == 0){
801022b0:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022b3:	83 c0 02             	add    $0x2,%eax
801022b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801022ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801022bd:	89 04 24             	mov    %eax,(%esp)
801022c0:	e8 63 ff ff ff       	call   80102228 <namecmp>
801022c5:	85 c0                	test   %eax,%eax
801022c7:	75 2d                	jne    801022f6 <dirlookup+0xac>
      // entry matches path element
      if(poff)
801022c9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801022cd:	74 08                	je     801022d7 <dirlookup+0x8d>
        *poff = off;
801022cf:	8b 45 10             	mov    0x10(%ebp),%eax
801022d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801022d5:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801022d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801022da:	0f b7 c0             	movzwl %ax,%eax
801022dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801022e0:	8b 45 08             	mov    0x8(%ebp),%eax
801022e3:	8b 00                	mov    (%eax),%eax
801022e5:	8b 55 f0             	mov    -0x10(%ebp),%edx
801022e8:	89 54 24 04          	mov    %edx,0x4(%esp)
801022ec:	89 04 24             	mov    %eax,(%esp)
801022ef:	e8 a3 f6 ff ff       	call   80101997 <iget>
801022f4:	eb 18                	jmp    8010230e <dirlookup+0xc4>
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
801022f6:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801022fa:	8b 45 08             	mov    0x8(%ebp),%eax
801022fd:	8b 40 58             	mov    0x58(%eax),%eax
80102300:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102303:	0f 87 6b ff ff ff    	ja     80102274 <dirlookup+0x2a>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102309:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010230e:	c9                   	leave  
8010230f:	c3                   	ret    

80102310 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102310:	55                   	push   %ebp
80102311:	89 e5                	mov    %esp,%ebp
80102313:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102316:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010231d:	00 
8010231e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102321:	89 44 24 04          	mov    %eax,0x4(%esp)
80102325:	8b 45 08             	mov    0x8(%ebp),%eax
80102328:	89 04 24             	mov    %eax,(%esp)
8010232b:	e8 1a ff ff ff       	call   8010224a <dirlookup>
80102330:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102333:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102337:	74 15                	je     8010234e <dirlink+0x3e>
    iput(ip);
80102339:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010233c:	89 04 24             	mov    %eax,(%esp)
8010233f:	e8 a8 f8 ff ff       	call   80101bec <iput>
    return -1;
80102344:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102349:	e9 b6 00 00 00       	jmp    80102404 <dirlink+0xf4>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010234e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102355:	eb 45                	jmp    8010239c <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102357:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010235a:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102361:	00 
80102362:	89 44 24 08          	mov    %eax,0x8(%esp)
80102366:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102369:	89 44 24 04          	mov    %eax,0x4(%esp)
8010236d:	8b 45 08             	mov    0x8(%ebp),%eax
80102370:	89 04 24             	mov    %eax,(%esp)
80102373:	e8 bd fb ff ff       	call   80101f35 <readi>
80102378:	83 f8 10             	cmp    $0x10,%eax
8010237b:	74 0c                	je     80102389 <dirlink+0x79>
      panic("dirlink read");
8010237d:	c7 04 24 b6 93 10 80 	movl   $0x801093b6,(%esp)
80102384:	e8 cb e1 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
80102389:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010238c:	66 85 c0             	test   %ax,%ax
8010238f:	75 02                	jne    80102393 <dirlink+0x83>
      break;
80102391:	eb 16                	jmp    801023a9 <dirlink+0x99>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102396:	83 c0 10             	add    $0x10,%eax
80102399:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010239c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010239f:	8b 45 08             	mov    0x8(%ebp),%eax
801023a2:	8b 40 58             	mov    0x58(%eax),%eax
801023a5:	39 c2                	cmp    %eax,%edx
801023a7:	72 ae                	jb     80102357 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
801023a9:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
801023b0:	00 
801023b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801023b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801023b8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023bb:	83 c0 02             	add    $0x2,%eax
801023be:	89 04 24             	mov    %eax,(%esp)
801023c1:	e8 92 39 00 00       	call   80105d58 <strncpy>
  de.inum = inum;
801023c6:	8b 45 10             	mov    0x10(%ebp),%eax
801023c9:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801023cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023d0:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801023d7:	00 
801023d8:	89 44 24 08          	mov    %eax,0x8(%esp)
801023dc:	8d 45 e0             	lea    -0x20(%ebp),%eax
801023df:	89 44 24 04          	mov    %eax,0x4(%esp)
801023e3:	8b 45 08             	mov    0x8(%ebp),%eax
801023e6:	89 04 24             	mov    %eax,(%esp)
801023e9:	e8 ab fc ff ff       	call   80102099 <writei>
801023ee:	83 f8 10             	cmp    $0x10,%eax
801023f1:	74 0c                	je     801023ff <dirlink+0xef>
    panic("dirlink");
801023f3:	c7 04 24 c3 93 10 80 	movl   $0x801093c3,(%esp)
801023fa:	e8 55 e1 ff ff       	call   80100554 <panic>

  return 0;
801023ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102404:	c9                   	leave  
80102405:	c3                   	ret    

80102406 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102406:	55                   	push   %ebp
80102407:	89 e5                	mov    %esp,%ebp
80102409:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
8010240c:	eb 03                	jmp    80102411 <skipelem+0xb>
    path++;
8010240e:	ff 45 08             	incl   0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102411:	8b 45 08             	mov    0x8(%ebp),%eax
80102414:	8a 00                	mov    (%eax),%al
80102416:	3c 2f                	cmp    $0x2f,%al
80102418:	74 f4                	je     8010240e <skipelem+0x8>
    path++;
  if(*path == 0)
8010241a:	8b 45 08             	mov    0x8(%ebp),%eax
8010241d:	8a 00                	mov    (%eax),%al
8010241f:	84 c0                	test   %al,%al
80102421:	75 0a                	jne    8010242d <skipelem+0x27>
    return 0;
80102423:	b8 00 00 00 00       	mov    $0x0,%eax
80102428:	e9 81 00 00 00       	jmp    801024ae <skipelem+0xa8>
  s = path;
8010242d:	8b 45 08             	mov    0x8(%ebp),%eax
80102430:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102433:	eb 03                	jmp    80102438 <skipelem+0x32>
    path++;
80102435:	ff 45 08             	incl   0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102438:	8b 45 08             	mov    0x8(%ebp),%eax
8010243b:	8a 00                	mov    (%eax),%al
8010243d:	3c 2f                	cmp    $0x2f,%al
8010243f:	74 09                	je     8010244a <skipelem+0x44>
80102441:	8b 45 08             	mov    0x8(%ebp),%eax
80102444:	8a 00                	mov    (%eax),%al
80102446:	84 c0                	test   %al,%al
80102448:	75 eb                	jne    80102435 <skipelem+0x2f>
    path++;
  len = path - s;
8010244a:	8b 55 08             	mov    0x8(%ebp),%edx
8010244d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102450:	29 c2                	sub    %eax,%edx
80102452:	89 d0                	mov    %edx,%eax
80102454:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102457:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
8010245b:	7e 1c                	jle    80102479 <skipelem+0x73>
    memmove(name, s, DIRSIZ);
8010245d:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102464:	00 
80102465:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102468:	89 44 24 04          	mov    %eax,0x4(%esp)
8010246c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010246f:	89 04 24             	mov    %eax,(%esp)
80102472:	e8 f4 37 00 00       	call   80105c6b <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102477:	eb 29                	jmp    801024a2 <skipelem+0x9c>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102479:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010247c:	89 44 24 08          	mov    %eax,0x8(%esp)
80102480:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102483:	89 44 24 04          	mov    %eax,0x4(%esp)
80102487:	8b 45 0c             	mov    0xc(%ebp),%eax
8010248a:	89 04 24             	mov    %eax,(%esp)
8010248d:	e8 d9 37 00 00       	call   80105c6b <memmove>
    name[len] = 0;
80102492:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102495:	8b 45 0c             	mov    0xc(%ebp),%eax
80102498:	01 d0                	add    %edx,%eax
8010249a:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010249d:	eb 03                	jmp    801024a2 <skipelem+0x9c>
    path++;
8010249f:	ff 45 08             	incl   0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801024a2:	8b 45 08             	mov    0x8(%ebp),%eax
801024a5:	8a 00                	mov    (%eax),%al
801024a7:	3c 2f                	cmp    $0x2f,%al
801024a9:	74 f4                	je     8010249f <skipelem+0x99>
    path++;
  return path;
801024ab:	8b 45 08             	mov    0x8(%ebp),%eax
}
801024ae:	c9                   	leave  
801024af:	c3                   	ret    

801024b0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801024b0:	55                   	push   %ebp
801024b1:	89 e5                	mov    %esp,%ebp
801024b3:	53                   	push   %ebx
801024b4:	83 ec 24             	sub    $0x24,%esp
  struct inode *ip, *next, *iroot;

  iroot = iget(ROOTDEV, ROOTINO);
801024b7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801024be:	00 
801024bf:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801024c6:	e8 cc f4 ff ff       	call   80101997 <iget>
801024cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  cprintf("namex begin %s with proc %s \n", path, ((myproc() == 0) ? "null" : myproc()->name));
801024ce:	e8 2d 1e 00 00       	call   80104300 <myproc>
801024d3:	85 c0                	test   %eax,%eax
801024d5:	74 0a                	je     801024e1 <namex+0x31>
801024d7:	e8 24 1e 00 00       	call   80104300 <myproc>
801024dc:	83 c0 6c             	add    $0x6c,%eax
801024df:	eb 05                	jmp    801024e6 <namex+0x36>
801024e1:	b8 cb 93 10 80       	mov    $0x801093cb,%eax
801024e6:	89 44 24 08          	mov    %eax,0x8(%esp)
801024ea:	8b 45 08             	mov    0x8(%ebp),%eax
801024ed:	89 44 24 04          	mov    %eax,0x4(%esp)
801024f1:	c7 04 24 d0 93 10 80 	movl   $0x801093d0,(%esp)
801024f8:	e8 c4 de ff ff       	call   801003c1 <cprintf>
  cprintf("\tiroot is type folder %d\n", (iroot->type == T_DIR));    
801024fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102500:	8b 40 50             	mov    0x50(%eax),%eax
80102503:	66 83 f8 01          	cmp    $0x1,%ax
80102507:	0f 94 c0             	sete   %al
8010250a:	0f b6 c0             	movzbl %al,%eax
8010250d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102511:	c7 04 24 ee 93 10 80 	movl   $0x801093ee,(%esp)
80102518:	e8 a4 de ff ff       	call   801003c1 <cprintf>

  // Absolute or relative
  if (myproc() == 0)
8010251d:	e8 de 1d 00 00       	call   80104300 <myproc>
80102522:	85 c0                	test   %eax,%eax
80102524:	75 0b                	jne    80102531 <namex+0x81>
    ip = iroot;
80102526:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102529:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010252c:	e9 b9 00 00 00       	jmp    801025ea <namex+0x13a>
  else if(*path == '/') 
80102531:	8b 45 08             	mov    0x8(%ebp),%eax
80102534:	8a 00                	mov    (%eax),%al
80102536:	3c 2f                	cmp    $0x2f,%al
80102538:	75 1e                	jne    80102558 <namex+0xa8>
    ip = idup(myproc()->cont->rootdir);
8010253a:	e8 c1 1d 00 00       	call   80104300 <myproc>
8010253f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102545:	8b 40 10             	mov    0x10(%eax),%eax
80102548:	89 04 24             	mov    %eax,(%esp)
8010254b:	e8 1c f5 ff ff       	call   80101a6c <idup>
80102550:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102553:	e9 92 00 00 00       	jmp    801025ea <namex+0x13a>
  else {    
    ip = idup(myproc()->cwd);
80102558:	e8 a3 1d 00 00       	call   80104300 <myproc>
8010255d:	8b 40 68             	mov    0x68(%eax),%eax
80102560:	89 04 24             	mov    %eax,(%esp)
80102563:	e8 04 f5 ff ff       	call   80101a6c <idup>
80102568:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("\tip = myproc's cwd (which is also it's container)%d\n", (myproc()->cwd->inum == myproc()->cont->rootdir->inum));
8010256b:	e8 90 1d 00 00       	call   80104300 <myproc>
80102570:	8b 40 68             	mov    0x68(%eax),%eax
80102573:	8b 58 04             	mov    0x4(%eax),%ebx
80102576:	e8 85 1d 00 00       	call   80104300 <myproc>
8010257b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102581:	8b 40 10             	mov    0x10(%eax),%eax
80102584:	8b 40 04             	mov    0x4(%eax),%eax
80102587:	39 c3                	cmp    %eax,%ebx
80102589:	0f 94 c0             	sete   %al
8010258c:	0f b6 c0             	movzbl %al,%eax
8010258f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102593:	c7 04 24 08 94 10 80 	movl   $0x80109408,(%esp)
8010259a:	e8 22 de ff ff       	call   801003c1 <cprintf>
    cprintf("\tip is type folder %d\n", (ip->type == T_DIR));    
8010259f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025a2:	8b 40 50             	mov    0x50(%eax),%eax
801025a5:	66 83 f8 01          	cmp    $0x1,%ax
801025a9:	0f 94 c0             	sete   %al
801025ac:	0f b6 c0             	movzbl %al,%eax
801025af:	89 44 24 04          	mov    %eax,0x4(%esp)
801025b3:	c7 04 24 3d 94 10 80 	movl   $0x8010943d,(%esp)
801025ba:	e8 02 de ff ff       	call   801003c1 <cprintf>
    cprintf("\trootdir is type folder %d\n", (myproc()->cont->rootdir->type == T_DIR));    
801025bf:	e8 3c 1d 00 00       	call   80104300 <myproc>
801025c4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801025ca:	8b 40 10             	mov    0x10(%eax),%eax
801025cd:	8b 40 50             	mov    0x50(%eax),%eax
801025d0:	66 83 f8 01          	cmp    $0x1,%ax
801025d4:	0f 94 c0             	sete   %al
801025d7:	0f b6 c0             	movzbl %al,%eax
801025da:	89 44 24 04          	mov    %eax,0x4(%esp)
801025de:	c7 04 24 54 94 10 80 	movl   $0x80109454,(%esp)
801025e5:	e8 d7 dd ff ff       	call   801003c1 <cprintf>
    // TODO: to find out: Root dir for namei('/') is NOT a dir.. why?
  }

  if (strncmp("/ctest1/init", path, strlen("/ctest1/init")) == 0) {
801025ea:	c7 04 24 70 94 10 80 	movl   $0x80109470,(%esp)
801025f1:	e8 ff 37 00 00       	call   80105df5 <strlen>
801025f6:	89 44 24 08          	mov    %eax,0x8(%esp)
801025fa:	8b 45 08             	mov    0x8(%ebp),%eax
801025fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80102601:	c7 04 24 70 94 10 80 	movl   $0x80109470,(%esp)
80102608:	e8 fd 36 00 00       	call   80105d0a <strncmp>
8010260d:	85 c0                	test   %eax,%eax
8010260f:	75 17                	jne    80102628 <namex+0x178>
    cprintf("ip = root now\n");
80102611:	c7 04 24 7d 94 10 80 	movl   $0x8010947d,(%esp)
80102618:	e8 a4 dd ff ff       	call   801003c1 <cprintf>
    ip = iroot;    
8010261d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102620:	89 45 f4             	mov    %eax,-0xc(%ebp)
  }    

  while((path = skipelem(path, name)) != 0){
80102623:	e9 99 00 00 00       	jmp    801026c1 <namex+0x211>
80102628:	e9 94 00 00 00       	jmp    801026c1 <namex+0x211>
    ilock(ip);
8010262d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102630:	89 04 24             	mov    %eax,(%esp)
80102633:	e8 66 f4 ff ff       	call   80101a9e <ilock>
    if(ip->type != T_DIR){
80102638:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010263b:	8b 40 50             	mov    0x50(%eax),%eax
8010263e:	66 83 f8 01          	cmp    $0x1,%ax
80102642:	74 15                	je     80102659 <namex+0x1a9>
      iunlockput(ip);
80102644:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102647:	89 04 24             	mov    %eax,(%esp)
8010264a:	e8 4e f6 ff ff       	call   80101c9d <iunlockput>
      return 0;
8010264f:	b8 00 00 00 00       	mov    $0x0,%eax
80102654:	e9 ce 00 00 00       	jmp    80102727 <namex+0x277>
    }
    if(nameiparent && *path == '\0'){
80102659:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010265d:	74 1c                	je     8010267b <namex+0x1cb>
8010265f:	8b 45 08             	mov    0x8(%ebp),%eax
80102662:	8a 00                	mov    (%eax),%al
80102664:	84 c0                	test   %al,%al
80102666:	75 13                	jne    8010267b <namex+0x1cb>
      // Stop one level early.
      iunlock(ip);
80102668:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010266b:	89 04 24             	mov    %eax,(%esp)
8010266e:	e8 35 f5 ff ff       	call   80101ba8 <iunlock>
      return ip;
80102673:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102676:	e9 ac 00 00 00       	jmp    80102727 <namex+0x277>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010267b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80102682:	00 
80102683:	8b 45 10             	mov    0x10(%ebp),%eax
80102686:	89 44 24 04          	mov    %eax,0x4(%esp)
8010268a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010268d:	89 04 24             	mov    %eax,(%esp)
80102690:	e8 b5 fb ff ff       	call   8010224a <dirlookup>
80102695:	89 45 ec             	mov    %eax,-0x14(%ebp)
80102698:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010269c:	75 12                	jne    801026b0 <namex+0x200>
      iunlockput(ip);
8010269e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026a1:	89 04 24             	mov    %eax,(%esp)
801026a4:	e8 f4 f5 ff ff       	call   80101c9d <iunlockput>
      return 0;
801026a9:	b8 00 00 00 00       	mov    $0x0,%eax
801026ae:	eb 77                	jmp    80102727 <namex+0x277>
    }    
    iunlockput(ip);
801026b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026b3:	89 04 24             	mov    %eax,(%esp)
801026b6:	e8 e2 f5 ff ff       	call   80101c9d <iunlockput>
    // If myproc is running in root container, 
    // or the above (next) folder is not the root folder,
    // then set ip = next
    // TODO: validate that this works
    //if (myproc()->cont->rootdir->inum == iroot->inum || next->inum != iroot->inum)
    ip = next;
801026bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801026be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if (strncmp("/ctest1/init", path, strlen("/ctest1/init")) == 0) {
    cprintf("ip = root now\n");
    ip = iroot;    
  }    

  while((path = skipelem(path, name)) != 0){
801026c1:	8b 45 10             	mov    0x10(%ebp),%eax
801026c4:	89 44 24 04          	mov    %eax,0x4(%esp)
801026c8:	8b 45 08             	mov    0x8(%ebp),%eax
801026cb:	89 04 24             	mov    %eax,(%esp)
801026ce:	e8 33 fd ff ff       	call   80102406 <skipelem>
801026d3:	89 45 08             	mov    %eax,0x8(%ebp)
801026d6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026da:	0f 85 4d ff ff ff    	jne    8010262d <namex+0x17d>
    // then set ip = next
    // TODO: validate that this works
    //if (myproc()->cont->rootdir->inum == iroot->inum || next->inum != iroot->inum)
    ip = next;
  }
  if(nameiparent){
801026e0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801026e4:	74 12                	je     801026f8 <namex+0x248>
    iput(ip);
801026e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026e9:	89 04 24             	mov    %eax,(%esp)
801026ec:	e8 fb f4 ff ff       	call   80101bec <iput>
    return 0;
801026f1:	b8 00 00 00 00       	mov    $0x0,%eax
801026f6:	eb 2f                	jmp    80102727 <namex+0x277>
  }
  cprintf("\treturning ip\n");
801026f8:	c7 04 24 8c 94 10 80 	movl   $0x8010948c,(%esp)
801026ff:	e8 bd dc ff ff       	call   801003c1 <cprintf>
  cprintf("\tip is a folder? %d\n", (ip->type == T_DIR));
80102704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102707:	8b 40 50             	mov    0x50(%eax),%eax
8010270a:	66 83 f8 01          	cmp    $0x1,%ax
8010270e:	0f 94 c0             	sete   %al
80102711:	0f b6 c0             	movzbl %al,%eax
80102714:	89 44 24 04          	mov    %eax,0x4(%esp)
80102718:	c7 04 24 9b 94 10 80 	movl   $0x8010949b,(%esp)
8010271f:	e8 9d dc ff ff       	call   801003c1 <cprintf>
  return ip;
80102724:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102727:	83 c4 24             	add    $0x24,%esp
8010272a:	5b                   	pop    %ebx
8010272b:	5d                   	pop    %ebp
8010272c:	c3                   	ret    

8010272d <namei>:

struct inode*
namei(char *path)
{
8010272d:	55                   	push   %ebp
8010272e:	89 e5                	mov    %esp,%ebp
80102730:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102733:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102736:	89 44 24 08          	mov    %eax,0x8(%esp)
8010273a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102741:	00 
80102742:	8b 45 08             	mov    0x8(%ebp),%eax
80102745:	89 04 24             	mov    %eax,(%esp)
80102748:	e8 63 fd ff ff       	call   801024b0 <namex>
}
8010274d:	c9                   	leave  
8010274e:	c3                   	ret    

8010274f <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010274f:	55                   	push   %ebp
80102750:	89 e5                	mov    %esp,%ebp
80102752:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
80102755:	8b 45 0c             	mov    0xc(%ebp),%eax
80102758:	89 44 24 08          	mov    %eax,0x8(%esp)
8010275c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102763:	00 
80102764:	8b 45 08             	mov    0x8(%ebp),%eax
80102767:	89 04 24             	mov    %eax,(%esp)
8010276a:	e8 41 fd ff ff       	call   801024b0 <namex>
}
8010276f:	c9                   	leave  
80102770:	c3                   	ret    
80102771:	00 00                	add    %al,(%eax)
	...

80102774 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102774:	55                   	push   %ebp
80102775:	89 e5                	mov    %esp,%ebp
80102777:	83 ec 14             	sub    $0x14,%esp
8010277a:	8b 45 08             	mov    0x8(%ebp),%eax
8010277d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102781:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102784:	89 c2                	mov    %eax,%edx
80102786:	ec                   	in     (%dx),%al
80102787:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010278a:	8a 45 ff             	mov    -0x1(%ebp),%al
}
8010278d:	c9                   	leave  
8010278e:	c3                   	ret    

8010278f <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
8010278f:	55                   	push   %ebp
80102790:	89 e5                	mov    %esp,%ebp
80102792:	57                   	push   %edi
80102793:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102794:	8b 55 08             	mov    0x8(%ebp),%edx
80102797:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010279a:	8b 45 10             	mov    0x10(%ebp),%eax
8010279d:	89 cb                	mov    %ecx,%ebx
8010279f:	89 df                	mov    %ebx,%edi
801027a1:	89 c1                	mov    %eax,%ecx
801027a3:	fc                   	cld    
801027a4:	f3 6d                	rep insl (%dx),%es:(%edi)
801027a6:	89 c8                	mov    %ecx,%eax
801027a8:	89 fb                	mov    %edi,%ebx
801027aa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801027ad:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801027b0:	5b                   	pop    %ebx
801027b1:	5f                   	pop    %edi
801027b2:	5d                   	pop    %ebp
801027b3:	c3                   	ret    

801027b4 <outb>:

static inline void
outb(ushort port, uchar data)
{
801027b4:	55                   	push   %ebp
801027b5:	89 e5                	mov    %esp,%ebp
801027b7:	83 ec 08             	sub    $0x8,%esp
801027ba:	8b 45 08             	mov    0x8(%ebp),%eax
801027bd:	8b 55 0c             	mov    0xc(%ebp),%edx
801027c0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801027c4:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801027c7:	8a 45 f8             	mov    -0x8(%ebp),%al
801027ca:	8b 55 fc             	mov    -0x4(%ebp),%edx
801027cd:	ee                   	out    %al,(%dx)
}
801027ce:	c9                   	leave  
801027cf:	c3                   	ret    

801027d0 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801027d0:	55                   	push   %ebp
801027d1:	89 e5                	mov    %esp,%ebp
801027d3:	56                   	push   %esi
801027d4:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801027d5:	8b 55 08             	mov    0x8(%ebp),%edx
801027d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801027db:	8b 45 10             	mov    0x10(%ebp),%eax
801027de:	89 cb                	mov    %ecx,%ebx
801027e0:	89 de                	mov    %ebx,%esi
801027e2:	89 c1                	mov    %eax,%ecx
801027e4:	fc                   	cld    
801027e5:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801027e7:	89 c8                	mov    %ecx,%eax
801027e9:	89 f3                	mov    %esi,%ebx
801027eb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801027ee:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801027f1:	5b                   	pop    %ebx
801027f2:	5e                   	pop    %esi
801027f3:	5d                   	pop    %ebp
801027f4:	c3                   	ret    

801027f5 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801027f5:	55                   	push   %ebp
801027f6:	89 e5                	mov    %esp,%ebp
801027f8:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801027fb:	90                   	nop
801027fc:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102803:	e8 6c ff ff ff       	call   80102774 <inb>
80102808:	0f b6 c0             	movzbl %al,%eax
8010280b:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010280e:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102811:	25 c0 00 00 00       	and    $0xc0,%eax
80102816:	83 f8 40             	cmp    $0x40,%eax
80102819:	75 e1                	jne    801027fc <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010281b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010281f:	74 11                	je     80102832 <idewait+0x3d>
80102821:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102824:	83 e0 21             	and    $0x21,%eax
80102827:	85 c0                	test   %eax,%eax
80102829:	74 07                	je     80102832 <idewait+0x3d>
    return -1;
8010282b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102830:	eb 05                	jmp    80102837 <idewait+0x42>
  return 0;
80102832:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102837:	c9                   	leave  
80102838:	c3                   	ret    

80102839 <ideinit>:

void
ideinit(void)
{
80102839:	55                   	push   %ebp
8010283a:	89 e5                	mov    %esp,%ebp
8010283c:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
8010283f:	c7 44 24 04 b0 94 10 	movl   $0x801094b0,0x4(%esp)
80102846:	80 
80102847:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
8010284e:	e8 cb 30 00 00       	call   8010591e <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102853:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80102858:	48                   	dec    %eax
80102859:	89 44 24 04          	mov    %eax,0x4(%esp)
8010285d:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80102864:	e8 66 04 00 00       	call   80102ccf <ioapicenable>
  idewait(0);
80102869:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102870:	e8 80 ff ff ff       	call   801027f5 <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102875:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
8010287c:	00 
8010287d:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102884:	e8 2b ff ff ff       	call   801027b4 <outb>
  for(i=0; i<1000; i++){
80102889:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102890:	eb 1f                	jmp    801028b1 <ideinit+0x78>
    if(inb(0x1f7) != 0){
80102892:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102899:	e8 d6 fe ff ff       	call   80102774 <inb>
8010289e:	84 c0                	test   %al,%al
801028a0:	74 0c                	je     801028ae <ideinit+0x75>
      havedisk1 = 1;
801028a2:	c7 05 78 c7 10 80 01 	movl   $0x1,0x8010c778
801028a9:	00 00 00 
      break;
801028ac:	eb 0c                	jmp    801028ba <ideinit+0x81>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801028ae:	ff 45 f4             	incl   -0xc(%ebp)
801028b1:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801028b8:	7e d8                	jle    80102892 <ideinit+0x59>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801028ba:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
801028c1:	00 
801028c2:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801028c9:	e8 e6 fe ff ff       	call   801027b4 <outb>
}
801028ce:	c9                   	leave  
801028cf:	c3                   	ret    

801028d0 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801028d0:	55                   	push   %ebp
801028d1:	89 e5                	mov    %esp,%ebp
801028d3:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
801028d6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801028da:	75 0c                	jne    801028e8 <idestart+0x18>
    panic("idestart");
801028dc:	c7 04 24 b4 94 10 80 	movl   $0x801094b4,(%esp)
801028e3:	e8 6c dc ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
801028e8:	8b 45 08             	mov    0x8(%ebp),%eax
801028eb:	8b 40 08             	mov    0x8(%eax),%eax
801028ee:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801028f3:	76 0c                	jbe    80102901 <idestart+0x31>
    panic("incorrect blockno");
801028f5:	c7 04 24 bd 94 10 80 	movl   $0x801094bd,(%esp)
801028fc:	e8 53 dc ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102901:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102908:	8b 45 08             	mov    0x8(%ebp),%eax
8010290b:	8b 50 08             	mov    0x8(%eax),%edx
8010290e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102911:	0f af c2             	imul   %edx,%eax
80102914:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102917:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010291b:	75 07                	jne    80102924 <idestart+0x54>
8010291d:	b8 20 00 00 00       	mov    $0x20,%eax
80102922:	eb 05                	jmp    80102929 <idestart+0x59>
80102924:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102929:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
8010292c:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102930:	75 07                	jne    80102939 <idestart+0x69>
80102932:	b8 30 00 00 00       	mov    $0x30,%eax
80102937:	eb 05                	jmp    8010293e <idestart+0x6e>
80102939:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010293e:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102941:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102945:	7e 0c                	jle    80102953 <idestart+0x83>
80102947:	c7 04 24 b4 94 10 80 	movl   $0x801094b4,(%esp)
8010294e:	e8 01 dc ff ff       	call   80100554 <panic>

  idewait(0);
80102953:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010295a:	e8 96 fe ff ff       	call   801027f5 <idewait>
  outb(0x3f6, 0);  // generate interrupt
8010295f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102966:	00 
80102967:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
8010296e:	e8 41 fe ff ff       	call   801027b4 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
80102973:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102976:	0f b6 c0             	movzbl %al,%eax
80102979:	89 44 24 04          	mov    %eax,0x4(%esp)
8010297d:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
80102984:	e8 2b fe ff ff       	call   801027b4 <outb>
  outb(0x1f3, sector & 0xff);
80102989:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010298c:	0f b6 c0             	movzbl %al,%eax
8010298f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102993:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
8010299a:	e8 15 fe ff ff       	call   801027b4 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
8010299f:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029a2:	c1 f8 08             	sar    $0x8,%eax
801029a5:	0f b6 c0             	movzbl %al,%eax
801029a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801029ac:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801029b3:	e8 fc fd ff ff       	call   801027b4 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
801029b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029bb:	c1 f8 10             	sar    $0x10,%eax
801029be:	0f b6 c0             	movzbl %al,%eax
801029c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801029c5:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
801029cc:	e8 e3 fd ff ff       	call   801027b4 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801029d1:	8b 45 08             	mov    0x8(%ebp),%eax
801029d4:	8b 40 04             	mov    0x4(%eax),%eax
801029d7:	83 e0 01             	and    $0x1,%eax
801029da:	c1 e0 04             	shl    $0x4,%eax
801029dd:	88 c2                	mov    %al,%dl
801029df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801029e2:	c1 f8 18             	sar    $0x18,%eax
801029e5:	83 e0 0f             	and    $0xf,%eax
801029e8:	09 d0                	or     %edx,%eax
801029ea:	83 c8 e0             	or     $0xffffffe0,%eax
801029ed:	0f b6 c0             	movzbl %al,%eax
801029f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801029f4:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801029fb:	e8 b4 fd ff ff       	call   801027b4 <outb>
  if(b->flags & B_DIRTY){
80102a00:	8b 45 08             	mov    0x8(%ebp),%eax
80102a03:	8b 00                	mov    (%eax),%eax
80102a05:	83 e0 04             	and    $0x4,%eax
80102a08:	85 c0                	test   %eax,%eax
80102a0a:	74 36                	je     80102a42 <idestart+0x172>
    outb(0x1f7, write_cmd);
80102a0c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102a0f:	0f b6 c0             	movzbl %al,%eax
80102a12:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a16:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a1d:	e8 92 fd ff ff       	call   801027b4 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
80102a22:	8b 45 08             	mov    0x8(%ebp),%eax
80102a25:	83 c0 5c             	add    $0x5c,%eax
80102a28:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102a2f:	00 
80102a30:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a34:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102a3b:	e8 90 fd ff ff       	call   801027d0 <outsl>
80102a40:	eb 16                	jmp    80102a58 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
80102a42:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102a45:	0f b6 c0             	movzbl %al,%eax
80102a48:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a4c:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102a53:	e8 5c fd ff ff       	call   801027b4 <outb>
  }
}
80102a58:	c9                   	leave  
80102a59:	c3                   	ret    

80102a5a <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102a5a:	55                   	push   %ebp
80102a5b:	89 e5                	mov    %esp,%ebp
80102a5d:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102a60:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
80102a67:	e8 d3 2e 00 00       	call   8010593f <acquire>

  if((b = idequeue) == 0){
80102a6c:	a1 74 c7 10 80       	mov    0x8010c774,%eax
80102a71:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a74:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a78:	75 11                	jne    80102a8b <ideintr+0x31>
    release(&idelock);
80102a7a:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
80102a81:	e8 23 2f 00 00       	call   801059a9 <release>
    return;
80102a86:	e9 90 00 00 00       	jmp    80102b1b <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102a8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a8e:	8b 40 58             	mov    0x58(%eax),%eax
80102a91:	a3 74 c7 10 80       	mov    %eax,0x8010c774

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a99:	8b 00                	mov    (%eax),%eax
80102a9b:	83 e0 04             	and    $0x4,%eax
80102a9e:	85 c0                	test   %eax,%eax
80102aa0:	75 2e                	jne    80102ad0 <ideintr+0x76>
80102aa2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102aa9:	e8 47 fd ff ff       	call   801027f5 <idewait>
80102aae:	85 c0                	test   %eax,%eax
80102ab0:	78 1e                	js     80102ad0 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80102ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab5:	83 c0 5c             	add    $0x5c,%eax
80102ab8:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102abf:	00 
80102ac0:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ac4:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102acb:	e8 bf fc ff ff       	call   8010278f <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102ad0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ad3:	8b 00                	mov    (%eax),%eax
80102ad5:	83 c8 02             	or     $0x2,%eax
80102ad8:	89 c2                	mov    %eax,%edx
80102ada:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102add:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae2:	8b 00                	mov    (%eax),%eax
80102ae4:	83 e0 fb             	and    $0xfffffffb,%eax
80102ae7:	89 c2                	mov    %eax,%edx
80102ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102aec:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af1:	89 04 24             	mov    %eax,(%esp)
80102af4:	e8 c9 21 00 00       	call   80104cc2 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102af9:	a1 74 c7 10 80       	mov    0x8010c774,%eax
80102afe:	85 c0                	test   %eax,%eax
80102b00:	74 0d                	je     80102b0f <ideintr+0xb5>
    idestart(idequeue);
80102b02:	a1 74 c7 10 80       	mov    0x8010c774,%eax
80102b07:	89 04 24             	mov    %eax,(%esp)
80102b0a:	e8 c1 fd ff ff       	call   801028d0 <idestart>

  release(&idelock);
80102b0f:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
80102b16:	e8 8e 2e 00 00       	call   801059a9 <release>
}
80102b1b:	c9                   	leave  
80102b1c:	c3                   	ret    

80102b1d <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102b1d:	55                   	push   %ebp
80102b1e:	89 e5                	mov    %esp,%ebp
80102b20:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102b23:	8b 45 08             	mov    0x8(%ebp),%eax
80102b26:	83 c0 0c             	add    $0xc,%eax
80102b29:	89 04 24             	mov    %eax,(%esp)
80102b2c:	e8 86 2d 00 00       	call   801058b7 <holdingsleep>
80102b31:	85 c0                	test   %eax,%eax
80102b33:	75 0c                	jne    80102b41 <iderw+0x24>
    panic("iderw: buf not locked");
80102b35:	c7 04 24 cf 94 10 80 	movl   $0x801094cf,(%esp)
80102b3c:	e8 13 da ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102b41:	8b 45 08             	mov    0x8(%ebp),%eax
80102b44:	8b 00                	mov    (%eax),%eax
80102b46:	83 e0 06             	and    $0x6,%eax
80102b49:	83 f8 02             	cmp    $0x2,%eax
80102b4c:	75 0c                	jne    80102b5a <iderw+0x3d>
    panic("iderw: nothing to do");
80102b4e:	c7 04 24 e5 94 10 80 	movl   $0x801094e5,(%esp)
80102b55:	e8 fa d9 ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
80102b5a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b5d:	8b 40 04             	mov    0x4(%eax),%eax
80102b60:	85 c0                	test   %eax,%eax
80102b62:	74 15                	je     80102b79 <iderw+0x5c>
80102b64:	a1 78 c7 10 80       	mov    0x8010c778,%eax
80102b69:	85 c0                	test   %eax,%eax
80102b6b:	75 0c                	jne    80102b79 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
80102b6d:	c7 04 24 fa 94 10 80 	movl   $0x801094fa,(%esp)
80102b74:	e8 db d9 ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102b79:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
80102b80:	e8 ba 2d 00 00       	call   8010593f <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102b85:	8b 45 08             	mov    0x8(%ebp),%eax
80102b88:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102b8f:	c7 45 f4 74 c7 10 80 	movl   $0x8010c774,-0xc(%ebp)
80102b96:	eb 0b                	jmp    80102ba3 <iderw+0x86>
80102b98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b9b:	8b 00                	mov    (%eax),%eax
80102b9d:	83 c0 58             	add    $0x58,%eax
80102ba0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ba6:	8b 00                	mov    (%eax),%eax
80102ba8:	85 c0                	test   %eax,%eax
80102baa:	75 ec                	jne    80102b98 <iderw+0x7b>
    ;
  *pp = b;
80102bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102baf:	8b 55 08             	mov    0x8(%ebp),%edx
80102bb2:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102bb4:	a1 74 c7 10 80       	mov    0x8010c774,%eax
80102bb9:	3b 45 08             	cmp    0x8(%ebp),%eax
80102bbc:	75 0d                	jne    80102bcb <iderw+0xae>
    idestart(b);
80102bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80102bc1:	89 04 24             	mov    %eax,(%esp)
80102bc4:	e8 07 fd ff ff       	call   801028d0 <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102bc9:	eb 15                	jmp    80102be0 <iderw+0xc3>
80102bcb:	eb 13                	jmp    80102be0 <iderw+0xc3>
    sleep(b, &idelock);
80102bcd:	c7 44 24 04 40 c7 10 	movl   $0x8010c740,0x4(%esp)
80102bd4:	80 
80102bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80102bd8:	89 04 24             	mov    %eax,(%esp)
80102bdb:	e8 f4 1f 00 00       	call   80104bd4 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102be0:	8b 45 08             	mov    0x8(%ebp),%eax
80102be3:	8b 00                	mov    (%eax),%eax
80102be5:	83 e0 06             	and    $0x6,%eax
80102be8:	83 f8 02             	cmp    $0x2,%eax
80102beb:	75 e0                	jne    80102bcd <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
80102bed:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
80102bf4:	e8 b0 2d 00 00       	call   801059a9 <release>
}
80102bf9:	c9                   	leave  
80102bfa:	c3                   	ret    
	...

80102bfc <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102bfc:	55                   	push   %ebp
80102bfd:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bff:	a1 14 48 11 80       	mov    0x80114814,%eax
80102c04:	8b 55 08             	mov    0x8(%ebp),%edx
80102c07:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102c09:	a1 14 48 11 80       	mov    0x80114814,%eax
80102c0e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102c11:	5d                   	pop    %ebp
80102c12:	c3                   	ret    

80102c13 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102c13:	55                   	push   %ebp
80102c14:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102c16:	a1 14 48 11 80       	mov    0x80114814,%eax
80102c1b:	8b 55 08             	mov    0x8(%ebp),%edx
80102c1e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102c20:	a1 14 48 11 80       	mov    0x80114814,%eax
80102c25:	8b 55 0c             	mov    0xc(%ebp),%edx
80102c28:	89 50 10             	mov    %edx,0x10(%eax)
}
80102c2b:	5d                   	pop    %ebp
80102c2c:	c3                   	ret    

80102c2d <ioapicinit>:

void
ioapicinit(void)
{
80102c2d:	55                   	push   %ebp
80102c2e:	89 e5                	mov    %esp,%ebp
80102c30:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102c33:	c7 05 14 48 11 80 00 	movl   $0xfec00000,0x80114814
80102c3a:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102c3d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102c44:	e8 b3 ff ff ff       	call   80102bfc <ioapicread>
80102c49:	c1 e8 10             	shr    $0x10,%eax
80102c4c:	25 ff 00 00 00       	and    $0xff,%eax
80102c51:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102c54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102c5b:	e8 9c ff ff ff       	call   80102bfc <ioapicread>
80102c60:	c1 e8 18             	shr    $0x18,%eax
80102c63:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102c66:	a0 40 49 11 80       	mov    0x80114940,%al
80102c6b:	0f b6 c0             	movzbl %al,%eax
80102c6e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102c71:	74 0c                	je     80102c7f <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c73:	c7 04 24 18 95 10 80 	movl   $0x80109518,(%esp)
80102c7a:	e8 42 d7 ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c86:	eb 3d                	jmp    80102cc5 <ioapicinit+0x98>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c8b:	83 c0 20             	add    $0x20,%eax
80102c8e:	0d 00 00 01 00       	or     $0x10000,%eax
80102c93:	89 c2                	mov    %eax,%edx
80102c95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c98:	83 c0 08             	add    $0x8,%eax
80102c9b:	01 c0                	add    %eax,%eax
80102c9d:	89 54 24 04          	mov    %edx,0x4(%esp)
80102ca1:	89 04 24             	mov    %eax,(%esp)
80102ca4:	e8 6a ff ff ff       	call   80102c13 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cac:	83 c0 08             	add    $0x8,%eax
80102caf:	01 c0                	add    %eax,%eax
80102cb1:	40                   	inc    %eax
80102cb2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102cb9:	00 
80102cba:	89 04 24             	mov    %eax,(%esp)
80102cbd:	e8 51 ff ff ff       	call   80102c13 <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102cc2:	ff 45 f4             	incl   -0xc(%ebp)
80102cc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cc8:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ccb:	7e bb                	jle    80102c88 <ioapicinit+0x5b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102ccd:	c9                   	leave  
80102cce:	c3                   	ret    

80102ccf <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102ccf:	55                   	push   %ebp
80102cd0:	89 e5                	mov    %esp,%ebp
80102cd2:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102cd5:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd8:	83 c0 20             	add    $0x20,%eax
80102cdb:	89 c2                	mov    %eax,%edx
80102cdd:	8b 45 08             	mov    0x8(%ebp),%eax
80102ce0:	83 c0 08             	add    $0x8,%eax
80102ce3:	01 c0                	add    %eax,%eax
80102ce5:	89 54 24 04          	mov    %edx,0x4(%esp)
80102ce9:	89 04 24             	mov    %eax,(%esp)
80102cec:	e8 22 ff ff ff       	call   80102c13 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
80102cf4:	c1 e0 18             	shl    $0x18,%eax
80102cf7:	8b 55 08             	mov    0x8(%ebp),%edx
80102cfa:	83 c2 08             	add    $0x8,%edx
80102cfd:	01 d2                	add    %edx,%edx
80102cff:	42                   	inc    %edx
80102d00:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d04:	89 14 24             	mov    %edx,(%esp)
80102d07:	e8 07 ff ff ff       	call   80102c13 <ioapicwrite>
}
80102d0c:	c9                   	leave  
80102d0d:	c3                   	ret    
	...

80102d10 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102d10:	55                   	push   %ebp
80102d11:	89 e5                	mov    %esp,%ebp
80102d13:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102d16:	c7 44 24 04 4a 95 10 	movl   $0x8010954a,0x4(%esp)
80102d1d:	80 
80102d1e:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102d25:	e8 f4 2b 00 00       	call   8010591e <initlock>
  kmem.use_lock = 0;
80102d2a:	c7 05 54 48 11 80 00 	movl   $0x0,0x80114854
80102d31:	00 00 00 
  freerange(vstart, vend);
80102d34:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d37:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d3b:	8b 45 08             	mov    0x8(%ebp),%eax
80102d3e:	89 04 24             	mov    %eax,(%esp)
80102d41:	e8 26 00 00 00       	call   80102d6c <freerange>
}
80102d46:	c9                   	leave  
80102d47:	c3                   	ret    

80102d48 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102d48:	55                   	push   %ebp
80102d49:	89 e5                	mov    %esp,%ebp
80102d4b:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102d4e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102d51:	89 44 24 04          	mov    %eax,0x4(%esp)
80102d55:	8b 45 08             	mov    0x8(%ebp),%eax
80102d58:	89 04 24             	mov    %eax,(%esp)
80102d5b:	e8 0c 00 00 00       	call   80102d6c <freerange>
  kmem.use_lock = 1;
80102d60:	c7 05 54 48 11 80 01 	movl   $0x1,0x80114854
80102d67:	00 00 00 
}
80102d6a:	c9                   	leave  
80102d6b:	c3                   	ret    

80102d6c <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d6c:	55                   	push   %ebp
80102d6d:	89 e5                	mov    %esp,%ebp
80102d6f:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d72:	8b 45 08             	mov    0x8(%ebp),%eax
80102d75:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d7a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d7f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d82:	eb 12                	jmp    80102d96 <freerange+0x2a>
    kfree(p);
80102d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d87:	89 04 24             	mov    %eax,(%esp)
80102d8a:	e8 16 00 00 00       	call   80102da5 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d8f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d99:	05 00 10 00 00       	add    $0x1000,%eax
80102d9e:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102da1:	76 e1                	jbe    80102d84 <freerange+0x18>
    kfree(p);
}
80102da3:	c9                   	leave  
80102da4:	c3                   	ret    

80102da5 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102da5:	55                   	push   %ebp
80102da6:	89 e5                	mov    %esp,%ebp
80102da8:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102dab:	8b 45 08             	mov    0x8(%ebp),%eax
80102dae:	25 ff 0f 00 00       	and    $0xfff,%eax
80102db3:	85 c0                	test   %eax,%eax
80102db5:	75 18                	jne    80102dcf <kfree+0x2a>
80102db7:	81 7d 08 48 61 12 80 	cmpl   $0x80126148,0x8(%ebp)
80102dbe:	72 0f                	jb     80102dcf <kfree+0x2a>
80102dc0:	8b 45 08             	mov    0x8(%ebp),%eax
80102dc3:	05 00 00 00 80       	add    $0x80000000,%eax
80102dc8:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102dcd:	76 0c                	jbe    80102ddb <kfree+0x36>
    panic("kfree");
80102dcf:	c7 04 24 4f 95 10 80 	movl   $0x8010954f,(%esp)
80102dd6:	e8 79 d7 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102ddb:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102de2:	00 
80102de3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102dea:	00 
80102deb:	8b 45 08             	mov    0x8(%ebp),%eax
80102dee:	89 04 24             	mov    %eax,(%esp)
80102df1:	e8 ac 2d 00 00       	call   80105ba2 <memset>

  if(kmem.use_lock)
80102df6:	a1 54 48 11 80       	mov    0x80114854,%eax
80102dfb:	85 c0                	test   %eax,%eax
80102dfd:	74 0c                	je     80102e0b <kfree+0x66>
    acquire(&kmem.lock);
80102dff:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102e06:	e8 34 2b 00 00       	call   8010593f <acquire>
  r = (struct run*)v;
80102e0b:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102e11:	8b 15 58 48 11 80    	mov    0x80114858,%edx
80102e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e1a:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e1f:	a3 58 48 11 80       	mov    %eax,0x80114858
  if(kmem.use_lock)
80102e24:	a1 54 48 11 80       	mov    0x80114854,%eax
80102e29:	85 c0                	test   %eax,%eax
80102e2b:	74 0c                	je     80102e39 <kfree+0x94>
    release(&kmem.lock);
80102e2d:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102e34:	e8 70 2b 00 00       	call   801059a9 <release>
}
80102e39:	c9                   	leave  
80102e3a:	c3                   	ret    

80102e3b <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102e3b:	55                   	push   %ebp
80102e3c:	89 e5                	mov    %esp,%ebp
80102e3e:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102e41:	a1 54 48 11 80       	mov    0x80114854,%eax
80102e46:	85 c0                	test   %eax,%eax
80102e48:	74 0c                	je     80102e56 <kalloc+0x1b>
    acquire(&kmem.lock);
80102e4a:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102e51:	e8 e9 2a 00 00       	call   8010593f <acquire>
  r = kmem.freelist;
80102e56:	a1 58 48 11 80       	mov    0x80114858,%eax
80102e5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102e5e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102e62:	74 0a                	je     80102e6e <kalloc+0x33>
    kmem.freelist = r->next;
80102e64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e67:	8b 00                	mov    (%eax),%eax
80102e69:	a3 58 48 11 80       	mov    %eax,0x80114858
  if(kmem.use_lock)
80102e6e:	a1 54 48 11 80       	mov    0x80114854,%eax
80102e73:	85 c0                	test   %eax,%eax
80102e75:	74 0c                	je     80102e83 <kalloc+0x48>
    release(&kmem.lock);
80102e77:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102e7e:	e8 26 2b 00 00       	call   801059a9 <release>
  return (char*)r;
80102e83:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102e86:	c9                   	leave  
80102e87:	c3                   	ret    

80102e88 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e88:	55                   	push   %ebp
80102e89:	89 e5                	mov    %esp,%ebp
80102e8b:	83 ec 14             	sub    $0x14,%esp
80102e8e:	8b 45 08             	mov    0x8(%ebp),%eax
80102e91:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e98:	89 c2                	mov    %eax,%edx
80102e9a:	ec                   	in     (%dx),%al
80102e9b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e9e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102ea1:	c9                   	leave  
80102ea2:	c3                   	ret    

80102ea3 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102ea3:	55                   	push   %ebp
80102ea4:	89 e5                	mov    %esp,%ebp
80102ea6:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102ea9:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102eb0:	e8 d3 ff ff ff       	call   80102e88 <inb>
80102eb5:	0f b6 c0             	movzbl %al,%eax
80102eb8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ebe:	83 e0 01             	and    $0x1,%eax
80102ec1:	85 c0                	test   %eax,%eax
80102ec3:	75 0a                	jne    80102ecf <kbdgetc+0x2c>
    return -1;
80102ec5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102eca:	e9 21 01 00 00       	jmp    80102ff0 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102ecf:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102ed6:	e8 ad ff ff ff       	call   80102e88 <inb>
80102edb:	0f b6 c0             	movzbl %al,%eax
80102ede:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102ee1:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102ee8:	75 17                	jne    80102f01 <kbdgetc+0x5e>
    shift |= E0ESC;
80102eea:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102eef:	83 c8 40             	or     $0x40,%eax
80102ef2:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
    return 0;
80102ef7:	b8 00 00 00 00       	mov    $0x0,%eax
80102efc:	e9 ef 00 00 00       	jmp    80102ff0 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102f01:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f04:	25 80 00 00 00       	and    $0x80,%eax
80102f09:	85 c0                	test   %eax,%eax
80102f0b:	74 44                	je     80102f51 <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102f0d:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102f12:	83 e0 40             	and    $0x40,%eax
80102f15:	85 c0                	test   %eax,%eax
80102f17:	75 08                	jne    80102f21 <kbdgetc+0x7e>
80102f19:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f1c:	83 e0 7f             	and    $0x7f,%eax
80102f1f:	eb 03                	jmp    80102f24 <kbdgetc+0x81>
80102f21:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f24:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102f27:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f2a:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f2f:	8a 00                	mov    (%eax),%al
80102f31:	83 c8 40             	or     $0x40,%eax
80102f34:	0f b6 c0             	movzbl %al,%eax
80102f37:	f7 d0                	not    %eax
80102f39:	89 c2                	mov    %eax,%edx
80102f3b:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102f40:	21 d0                	and    %edx,%eax
80102f42:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
    return 0;
80102f47:	b8 00 00 00 00       	mov    $0x0,%eax
80102f4c:	e9 9f 00 00 00       	jmp    80102ff0 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102f51:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102f56:	83 e0 40             	and    $0x40,%eax
80102f59:	85 c0                	test   %eax,%eax
80102f5b:	74 14                	je     80102f71 <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102f5d:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102f64:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102f69:	83 e0 bf             	and    $0xffffffbf,%eax
80102f6c:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
  }

  shift |= shiftcode[data];
80102f71:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f74:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f79:	8a 00                	mov    (%eax),%al
80102f7b:	0f b6 d0             	movzbl %al,%edx
80102f7e:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102f83:	09 d0                	or     %edx,%eax
80102f85:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
  shift ^= togglecode[data];
80102f8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f8d:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102f92:	8a 00                	mov    (%eax),%al
80102f94:	0f b6 d0             	movzbl %al,%edx
80102f97:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102f9c:	31 d0                	xor    %edx,%eax
80102f9e:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
  c = charcode[shift & (CTL | SHIFT)][data];
80102fa3:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102fa8:	83 e0 03             	and    $0x3,%eax
80102fab:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102fb2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102fb5:	01 d0                	add    %edx,%eax
80102fb7:	8a 00                	mov    (%eax),%al
80102fb9:	0f b6 c0             	movzbl %al,%eax
80102fbc:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102fbf:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102fc4:	83 e0 08             	and    $0x8,%eax
80102fc7:	85 c0                	test   %eax,%eax
80102fc9:	74 22                	je     80102fed <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102fcb:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102fcf:	76 0c                	jbe    80102fdd <kbdgetc+0x13a>
80102fd1:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102fd5:	77 06                	ja     80102fdd <kbdgetc+0x13a>
      c += 'A' - 'a';
80102fd7:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102fdb:	eb 10                	jmp    80102fed <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102fdd:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102fe1:	76 0a                	jbe    80102fed <kbdgetc+0x14a>
80102fe3:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102fe7:	77 04                	ja     80102fed <kbdgetc+0x14a>
      c += 'a' - 'A';
80102fe9:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102fed:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102ff0:	c9                   	leave  
80102ff1:	c3                   	ret    

80102ff2 <kbdintr>:

void
kbdintr(void)
{
80102ff2:	55                   	push   %ebp
80102ff3:	89 e5                	mov    %esp,%ebp
80102ff5:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102ff8:	c7 04 24 a3 2e 10 80 	movl   $0x80102ea3,(%esp)
80102fff:	e8 f1 d7 ff ff       	call   801007f5 <consoleintr>
}
80103004:	c9                   	leave  
80103005:	c3                   	ret    
	...

80103008 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103008:	55                   	push   %ebp
80103009:	89 e5                	mov    %esp,%ebp
8010300b:	83 ec 14             	sub    $0x14,%esp
8010300e:	8b 45 08             	mov    0x8(%ebp),%eax
80103011:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103015:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103018:	89 c2                	mov    %eax,%edx
8010301a:	ec                   	in     (%dx),%al
8010301b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010301e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103021:	c9                   	leave  
80103022:	c3                   	ret    

80103023 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103023:	55                   	push   %ebp
80103024:	89 e5                	mov    %esp,%ebp
80103026:	83 ec 08             	sub    $0x8,%esp
80103029:	8b 45 08             	mov    0x8(%ebp),%eax
8010302c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010302f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103033:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103036:	8a 45 f8             	mov    -0x8(%ebp),%al
80103039:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010303c:	ee                   	out    %al,(%dx)
}
8010303d:	c9                   	leave  
8010303e:	c3                   	ret    

8010303f <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
8010303f:	55                   	push   %ebp
80103040:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80103042:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80103047:	8b 55 08             	mov    0x8(%ebp),%edx
8010304a:	c1 e2 02             	shl    $0x2,%edx
8010304d:	01 c2                	add    %eax,%edx
8010304f:	8b 45 0c             	mov    0xc(%ebp),%eax
80103052:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80103054:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80103059:	83 c0 20             	add    $0x20,%eax
8010305c:	8b 00                	mov    (%eax),%eax
}
8010305e:	5d                   	pop    %ebp
8010305f:	c3                   	ret    

80103060 <lapicinit>:

void
lapicinit(void)
{
80103060:	55                   	push   %ebp
80103061:	89 e5                	mov    %esp,%ebp
80103063:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80103066:	a1 5c 48 11 80       	mov    0x8011485c,%eax
8010306b:	85 c0                	test   %eax,%eax
8010306d:	75 05                	jne    80103074 <lapicinit+0x14>
    return;
8010306f:	e9 43 01 00 00       	jmp    801031b7 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80103074:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
8010307b:	00 
8010307c:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80103083:	e8 b7 ff ff ff       	call   8010303f <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103088:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
8010308f:	00 
80103090:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80103097:	e8 a3 ff ff ff       	call   8010303f <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010309c:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
801030a3:	00 
801030a4:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801030ab:	e8 8f ff ff ff       	call   8010303f <lapicw>
  lapicw(TICR, 10000000);
801030b0:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
801030b7:	00 
801030b8:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
801030bf:	e8 7b ff ff ff       	call   8010303f <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
801030c4:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801030cb:	00 
801030cc:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
801030d3:	e8 67 ff ff ff       	call   8010303f <lapicw>
  lapicw(LINT1, MASKED);
801030d8:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801030df:	00 
801030e0:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
801030e7:	e8 53 ff ff ff       	call   8010303f <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801030ec:	a1 5c 48 11 80       	mov    0x8011485c,%eax
801030f1:	83 c0 30             	add    $0x30,%eax
801030f4:	8b 00                	mov    (%eax),%eax
801030f6:	c1 e8 10             	shr    $0x10,%eax
801030f9:	0f b6 c0             	movzbl %al,%eax
801030fc:	83 f8 03             	cmp    $0x3,%eax
801030ff:	76 14                	jbe    80103115 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80103101:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103108:	00 
80103109:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
80103110:	e8 2a ff ff ff       	call   8010303f <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103115:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
8010311c:	00 
8010311d:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80103124:	e8 16 ff ff ff       	call   8010303f <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103129:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103130:	00 
80103131:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103138:	e8 02 ff ff ff       	call   8010303f <lapicw>
  lapicw(ESR, 0);
8010313d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103144:	00 
80103145:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
8010314c:	e8 ee fe ff ff       	call   8010303f <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80103151:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103158:	00 
80103159:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103160:	e8 da fe ff ff       	call   8010303f <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80103165:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010316c:	00 
8010316d:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103174:	e8 c6 fe ff ff       	call   8010303f <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103179:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80103180:	00 
80103181:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103188:	e8 b2 fe ff ff       	call   8010303f <lapicw>
  while(lapic[ICRLO] & DELIVS)
8010318d:	90                   	nop
8010318e:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80103193:	05 00 03 00 00       	add    $0x300,%eax
80103198:	8b 00                	mov    (%eax),%eax
8010319a:	25 00 10 00 00       	and    $0x1000,%eax
8010319f:	85 c0                	test   %eax,%eax
801031a1:	75 eb                	jne    8010318e <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801031a3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031aa:	00 
801031ab:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801031b2:	e8 88 fe ff ff       	call   8010303f <lapicw>
}
801031b7:	c9                   	leave  
801031b8:	c3                   	ret    

801031b9 <lapicid>:

int
lapicid(void)
{
801031b9:	55                   	push   %ebp
801031ba:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801031bc:	a1 5c 48 11 80       	mov    0x8011485c,%eax
801031c1:	85 c0                	test   %eax,%eax
801031c3:	75 07                	jne    801031cc <lapicid+0x13>
    return 0;
801031c5:	b8 00 00 00 00       	mov    $0x0,%eax
801031ca:	eb 0d                	jmp    801031d9 <lapicid+0x20>
  return lapic[ID] >> 24;
801031cc:	a1 5c 48 11 80       	mov    0x8011485c,%eax
801031d1:	83 c0 20             	add    $0x20,%eax
801031d4:	8b 00                	mov    (%eax),%eax
801031d6:	c1 e8 18             	shr    $0x18,%eax
}
801031d9:	5d                   	pop    %ebp
801031da:	c3                   	ret    

801031db <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801031db:	55                   	push   %ebp
801031dc:	89 e5                	mov    %esp,%ebp
801031de:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
801031e1:	a1 5c 48 11 80       	mov    0x8011485c,%eax
801031e6:	85 c0                	test   %eax,%eax
801031e8:	74 14                	je     801031fe <lapiceoi+0x23>
    lapicw(EOI, 0);
801031ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801031f1:	00 
801031f2:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
801031f9:	e8 41 fe ff ff       	call   8010303f <lapicw>
}
801031fe:	c9                   	leave  
801031ff:	c3                   	ret    

80103200 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103200:	55                   	push   %ebp
80103201:	89 e5                	mov    %esp,%ebp
}
80103203:	5d                   	pop    %ebp
80103204:	c3                   	ret    

80103205 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103205:	55                   	push   %ebp
80103206:	89 e5                	mov    %esp,%ebp
80103208:	83 ec 1c             	sub    $0x1c,%esp
8010320b:	8b 45 08             	mov    0x8(%ebp),%eax
8010320e:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103211:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103218:	00 
80103219:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103220:	e8 fe fd ff ff       	call   80103023 <outb>
  outb(CMOS_PORT+1, 0x0A);
80103225:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
8010322c:	00 
8010322d:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103234:	e8 ea fd ff ff       	call   80103023 <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103239:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103240:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103243:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103248:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010324b:	8d 50 02             	lea    0x2(%eax),%edx
8010324e:	8b 45 0c             	mov    0xc(%ebp),%eax
80103251:	c1 e8 04             	shr    $0x4,%eax
80103254:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80103257:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
8010325b:	c1 e0 18             	shl    $0x18,%eax
8010325e:	89 44 24 04          	mov    %eax,0x4(%esp)
80103262:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103269:	e8 d1 fd ff ff       	call   8010303f <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010326e:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
80103275:	00 
80103276:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010327d:	e8 bd fd ff ff       	call   8010303f <lapicw>
  microdelay(200);
80103282:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103289:	e8 72 ff ff ff       	call   80103200 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
8010328e:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
80103295:	00 
80103296:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010329d:	e8 9d fd ff ff       	call   8010303f <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801032a2:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801032a9:	e8 52 ff ff ff       	call   80103200 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801032ae:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801032b5:	eb 3f                	jmp    801032f6 <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
801032b7:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801032bb:	c1 e0 18             	shl    $0x18,%eax
801032be:	89 44 24 04          	mov    %eax,0x4(%esp)
801032c2:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801032c9:	e8 71 fd ff ff       	call   8010303f <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801032ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801032d1:	c1 e8 0c             	shr    $0xc,%eax
801032d4:	80 cc 06             	or     $0x6,%ah
801032d7:	89 44 24 04          	mov    %eax,0x4(%esp)
801032db:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801032e2:	e8 58 fd ff ff       	call   8010303f <lapicw>
    microdelay(200);
801032e7:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801032ee:	e8 0d ff ff ff       	call   80103200 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801032f3:	ff 45 fc             	incl   -0x4(%ebp)
801032f6:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
801032fa:	7e bb                	jle    801032b7 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801032fc:	c9                   	leave  
801032fd:	c3                   	ret    

801032fe <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
801032fe:	55                   	push   %ebp
801032ff:	89 e5                	mov    %esp,%ebp
80103301:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103304:	8b 45 08             	mov    0x8(%ebp),%eax
80103307:	0f b6 c0             	movzbl %al,%eax
8010330a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010330e:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103315:	e8 09 fd ff ff       	call   80103023 <outb>
  microdelay(200);
8010331a:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103321:	e8 da fe ff ff       	call   80103200 <microdelay>

  return inb(CMOS_RETURN);
80103326:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
8010332d:	e8 d6 fc ff ff       	call   80103008 <inb>
80103332:	0f b6 c0             	movzbl %al,%eax
}
80103335:	c9                   	leave  
80103336:	c3                   	ret    

80103337 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103337:	55                   	push   %ebp
80103338:	89 e5                	mov    %esp,%ebp
8010333a:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
8010333d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103344:	e8 b5 ff ff ff       	call   801032fe <cmos_read>
80103349:	8b 55 08             	mov    0x8(%ebp),%edx
8010334c:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010334e:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80103355:	e8 a4 ff ff ff       	call   801032fe <cmos_read>
8010335a:	8b 55 08             	mov    0x8(%ebp),%edx
8010335d:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80103360:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80103367:	e8 92 ff ff ff       	call   801032fe <cmos_read>
8010336c:	8b 55 08             	mov    0x8(%ebp),%edx
8010336f:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80103372:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
80103379:	e8 80 ff ff ff       	call   801032fe <cmos_read>
8010337e:	8b 55 08             	mov    0x8(%ebp),%edx
80103381:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80103384:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010338b:	e8 6e ff ff ff       	call   801032fe <cmos_read>
80103390:	8b 55 08             	mov    0x8(%ebp),%edx
80103393:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80103396:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
8010339d:	e8 5c ff ff ff       	call   801032fe <cmos_read>
801033a2:	8b 55 08             	mov    0x8(%ebp),%edx
801033a5:	89 42 14             	mov    %eax,0x14(%edx)
}
801033a8:	c9                   	leave  
801033a9:	c3                   	ret    

801033aa <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801033aa:	55                   	push   %ebp
801033ab:	89 e5                	mov    %esp,%ebp
801033ad:	57                   	push   %edi
801033ae:	56                   	push   %esi
801033af:	53                   	push   %ebx
801033b0:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801033b3:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
801033ba:	e8 3f ff ff ff       	call   801032fe <cmos_read>
801033bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801033c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801033c5:	83 e0 04             	and    $0x4,%eax
801033c8:	85 c0                	test   %eax,%eax
801033ca:	0f 94 c0             	sete   %al
801033cd:	0f b6 c0             	movzbl %al,%eax
801033d0:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801033d3:	8d 45 c8             	lea    -0x38(%ebp),%eax
801033d6:	89 04 24             	mov    %eax,(%esp)
801033d9:	e8 59 ff ff ff       	call   80103337 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801033de:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801033e5:	e8 14 ff ff ff       	call   801032fe <cmos_read>
801033ea:	25 80 00 00 00       	and    $0x80,%eax
801033ef:	85 c0                	test   %eax,%eax
801033f1:	74 02                	je     801033f5 <cmostime+0x4b>
        continue;
801033f3:	eb 36                	jmp    8010342b <cmostime+0x81>
    fill_rtcdate(&t2);
801033f5:	8d 45 b0             	lea    -0x50(%ebp),%eax
801033f8:	89 04 24             	mov    %eax,(%esp)
801033fb:	e8 37 ff ff ff       	call   80103337 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103400:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80103407:	00 
80103408:	8d 45 b0             	lea    -0x50(%ebp),%eax
8010340b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010340f:	8d 45 c8             	lea    -0x38(%ebp),%eax
80103412:	89 04 24             	mov    %eax,(%esp)
80103415:	e8 ff 27 00 00       	call   80105c19 <memcmp>
8010341a:	85 c0                	test   %eax,%eax
8010341c:	75 0d                	jne    8010342b <cmostime+0x81>
      break;
8010341e:	90                   	nop
  }

  // convert
  if(bcd) {
8010341f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80103423:	0f 84 ac 00 00 00    	je     801034d5 <cmostime+0x12b>
80103429:	eb 02                	jmp    8010342d <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
8010342b:	eb a6                	jmp    801033d3 <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010342d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80103430:	c1 e8 04             	shr    $0x4,%eax
80103433:	89 c2                	mov    %eax,%edx
80103435:	89 d0                	mov    %edx,%eax
80103437:	c1 e0 02             	shl    $0x2,%eax
8010343a:	01 d0                	add    %edx,%eax
8010343c:	01 c0                	add    %eax,%eax
8010343e:	8b 55 c8             	mov    -0x38(%ebp),%edx
80103441:	83 e2 0f             	and    $0xf,%edx
80103444:	01 d0                	add    %edx,%eax
80103446:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
80103449:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010344c:	c1 e8 04             	shr    $0x4,%eax
8010344f:	89 c2                	mov    %eax,%edx
80103451:	89 d0                	mov    %edx,%eax
80103453:	c1 e0 02             	shl    $0x2,%eax
80103456:	01 d0                	add    %edx,%eax
80103458:	01 c0                	add    %eax,%eax
8010345a:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010345d:	83 e2 0f             	and    $0xf,%edx
80103460:	01 d0                	add    %edx,%eax
80103462:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
80103465:	8b 45 d0             	mov    -0x30(%ebp),%eax
80103468:	c1 e8 04             	shr    $0x4,%eax
8010346b:	89 c2                	mov    %eax,%edx
8010346d:	89 d0                	mov    %edx,%eax
8010346f:	c1 e0 02             	shl    $0x2,%eax
80103472:	01 d0                	add    %edx,%eax
80103474:	01 c0                	add    %eax,%eax
80103476:	8b 55 d0             	mov    -0x30(%ebp),%edx
80103479:	83 e2 0f             	and    $0xf,%edx
8010347c:	01 d0                	add    %edx,%eax
8010347e:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
80103481:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80103484:	c1 e8 04             	shr    $0x4,%eax
80103487:	89 c2                	mov    %eax,%edx
80103489:	89 d0                	mov    %edx,%eax
8010348b:	c1 e0 02             	shl    $0x2,%eax
8010348e:	01 d0                	add    %edx,%eax
80103490:	01 c0                	add    %eax,%eax
80103492:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80103495:	83 e2 0f             	and    $0xf,%edx
80103498:	01 d0                	add    %edx,%eax
8010349a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
8010349d:	8b 45 d8             	mov    -0x28(%ebp),%eax
801034a0:	c1 e8 04             	shr    $0x4,%eax
801034a3:	89 c2                	mov    %eax,%edx
801034a5:	89 d0                	mov    %edx,%eax
801034a7:	c1 e0 02             	shl    $0x2,%eax
801034aa:	01 d0                	add    %edx,%eax
801034ac:	01 c0                	add    %eax,%eax
801034ae:	8b 55 d8             	mov    -0x28(%ebp),%edx
801034b1:	83 e2 0f             	and    $0xf,%edx
801034b4:	01 d0                	add    %edx,%eax
801034b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
801034b9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801034bc:	c1 e8 04             	shr    $0x4,%eax
801034bf:	89 c2                	mov    %eax,%edx
801034c1:	89 d0                	mov    %edx,%eax
801034c3:	c1 e0 02             	shl    $0x2,%eax
801034c6:	01 d0                	add    %edx,%eax
801034c8:	01 c0                	add    %eax,%eax
801034ca:	8b 55 dc             	mov    -0x24(%ebp),%edx
801034cd:	83 e2 0f             	and    $0xf,%edx
801034d0:	01 d0                	add    %edx,%eax
801034d2:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
801034d5:	8b 45 08             	mov    0x8(%ebp),%eax
801034d8:	89 c2                	mov    %eax,%edx
801034da:	8d 5d c8             	lea    -0x38(%ebp),%ebx
801034dd:	b8 06 00 00 00       	mov    $0x6,%eax
801034e2:	89 d7                	mov    %edx,%edi
801034e4:	89 de                	mov    %ebx,%esi
801034e6:	89 c1                	mov    %eax,%ecx
801034e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
801034ea:	8b 45 08             	mov    0x8(%ebp),%eax
801034ed:	8b 40 14             	mov    0x14(%eax),%eax
801034f0:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
801034f6:	8b 45 08             	mov    0x8(%ebp),%eax
801034f9:	89 50 14             	mov    %edx,0x14(%eax)
}
801034fc:	83 c4 5c             	add    $0x5c,%esp
801034ff:	5b                   	pop    %ebx
80103500:	5e                   	pop    %esi
80103501:	5f                   	pop    %edi
80103502:	5d                   	pop    %ebp
80103503:	c3                   	ret    

80103504 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103504:	55                   	push   %ebp
80103505:	89 e5                	mov    %esp,%ebp
80103507:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010350a:	c7 44 24 04 55 95 10 	movl   $0x80109555,0x4(%esp)
80103511:	80 
80103512:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103519:	e8 00 24 00 00       	call   8010591e <initlock>
  readsb(dev, &sb);
8010351e:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103521:	89 44 24 04          	mov    %eax,0x4(%esp)
80103525:	8b 45 08             	mov    0x8(%ebp),%eax
80103528:	89 04 24             	mov    %eax,(%esp)
8010352b:	e8 6c df ff ff       	call   8010149c <readsb>
  log.start = sb.logstart;
80103530:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103533:	a3 94 48 11 80       	mov    %eax,0x80114894
  log.size = sb.nlog;
80103538:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010353b:	a3 98 48 11 80       	mov    %eax,0x80114898
  log.dev = dev;
80103540:	8b 45 08             	mov    0x8(%ebp),%eax
80103543:	a3 a4 48 11 80       	mov    %eax,0x801148a4
  recover_from_log();
80103548:	e8 95 01 00 00       	call   801036e2 <recover_from_log>
}
8010354d:	c9                   	leave  
8010354e:	c3                   	ret    

8010354f <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010354f:	55                   	push   %ebp
80103550:	89 e5                	mov    %esp,%ebp
80103552:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103555:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010355c:	e9 89 00 00 00       	jmp    801035ea <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103561:	8b 15 94 48 11 80    	mov    0x80114894,%edx
80103567:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010356a:	01 d0                	add    %edx,%eax
8010356c:	40                   	inc    %eax
8010356d:	89 c2                	mov    %eax,%edx
8010356f:	a1 a4 48 11 80       	mov    0x801148a4,%eax
80103574:	89 54 24 04          	mov    %edx,0x4(%esp)
80103578:	89 04 24             	mov    %eax,(%esp)
8010357b:	e8 35 cc ff ff       	call   801001b5 <bread>
80103580:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103583:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103586:	83 c0 10             	add    $0x10,%eax
80103589:	8b 04 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%eax
80103590:	89 c2                	mov    %eax,%edx
80103592:	a1 a4 48 11 80       	mov    0x801148a4,%eax
80103597:	89 54 24 04          	mov    %edx,0x4(%esp)
8010359b:	89 04 24             	mov    %eax,(%esp)
8010359e:	e8 12 cc ff ff       	call   801001b5 <bread>
801035a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801035a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035a9:	8d 50 5c             	lea    0x5c(%eax),%edx
801035ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035af:	83 c0 5c             	add    $0x5c,%eax
801035b2:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801035b9:	00 
801035ba:	89 54 24 04          	mov    %edx,0x4(%esp)
801035be:	89 04 24             	mov    %eax,(%esp)
801035c1:	e8 a5 26 00 00       	call   80105c6b <memmove>
    bwrite(dbuf);  // write dst to disk
801035c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035c9:	89 04 24             	mov    %eax,(%esp)
801035cc:	e8 1b cc ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
801035d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035d4:	89 04 24             	mov    %eax,(%esp)
801035d7:	e8 50 cc ff ff       	call   8010022c <brelse>
    brelse(dbuf);
801035dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035df:	89 04 24             	mov    %eax,(%esp)
801035e2:	e8 45 cc ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801035e7:	ff 45 f4             	incl   -0xc(%ebp)
801035ea:	a1 a8 48 11 80       	mov    0x801148a8,%eax
801035ef:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035f2:	0f 8f 69 ff ff ff    	jg     80103561 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
801035f8:	c9                   	leave  
801035f9:	c3                   	ret    

801035fa <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801035fa:	55                   	push   %ebp
801035fb:	89 e5                	mov    %esp,%ebp
801035fd:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103600:	a1 94 48 11 80       	mov    0x80114894,%eax
80103605:	89 c2                	mov    %eax,%edx
80103607:	a1 a4 48 11 80       	mov    0x801148a4,%eax
8010360c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103610:	89 04 24             	mov    %eax,(%esp)
80103613:	e8 9d cb ff ff       	call   801001b5 <bread>
80103618:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010361b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010361e:	83 c0 5c             	add    $0x5c,%eax
80103621:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103624:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103627:	8b 00                	mov    (%eax),%eax
80103629:	a3 a8 48 11 80       	mov    %eax,0x801148a8
  for (i = 0; i < log.lh.n; i++) {
8010362e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103635:	eb 1a                	jmp    80103651 <read_head+0x57>
    log.lh.block[i] = lh->block[i];
80103637:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010363a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010363d:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103641:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103644:	83 c2 10             	add    $0x10,%edx
80103647:	89 04 95 6c 48 11 80 	mov    %eax,-0x7feeb794(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010364e:	ff 45 f4             	incl   -0xc(%ebp)
80103651:	a1 a8 48 11 80       	mov    0x801148a8,%eax
80103656:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103659:	7f dc                	jg     80103637 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
8010365b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010365e:	89 04 24             	mov    %eax,(%esp)
80103661:	e8 c6 cb ff ff       	call   8010022c <brelse>
}
80103666:	c9                   	leave  
80103667:	c3                   	ret    

80103668 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103668:	55                   	push   %ebp
80103669:	89 e5                	mov    %esp,%ebp
8010366b:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010366e:	a1 94 48 11 80       	mov    0x80114894,%eax
80103673:	89 c2                	mov    %eax,%edx
80103675:	a1 a4 48 11 80       	mov    0x801148a4,%eax
8010367a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010367e:	89 04 24             	mov    %eax,(%esp)
80103681:	e8 2f cb ff ff       	call   801001b5 <bread>
80103686:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103689:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010368c:	83 c0 5c             	add    $0x5c,%eax
8010368f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80103692:	8b 15 a8 48 11 80    	mov    0x801148a8,%edx
80103698:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010369b:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010369d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801036a4:	eb 1a                	jmp    801036c0 <write_head+0x58>
    hb->block[i] = log.lh.block[i];
801036a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036a9:	83 c0 10             	add    $0x10,%eax
801036ac:	8b 0c 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%ecx
801036b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801036b9:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801036bd:	ff 45 f4             	incl   -0xc(%ebp)
801036c0:	a1 a8 48 11 80       	mov    0x801148a8,%eax
801036c5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036c8:	7f dc                	jg     801036a6 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801036ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036cd:	89 04 24             	mov    %eax,(%esp)
801036d0:	e8 17 cb ff ff       	call   801001ec <bwrite>
  brelse(buf);
801036d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036d8:	89 04 24             	mov    %eax,(%esp)
801036db:	e8 4c cb ff ff       	call   8010022c <brelse>
}
801036e0:	c9                   	leave  
801036e1:	c3                   	ret    

801036e2 <recover_from_log>:

static void
recover_from_log(void)
{
801036e2:	55                   	push   %ebp
801036e3:	89 e5                	mov    %esp,%ebp
801036e5:	83 ec 08             	sub    $0x8,%esp
  read_head();
801036e8:	e8 0d ff ff ff       	call   801035fa <read_head>
  install_trans(); // if committed, copy from log to disk
801036ed:	e8 5d fe ff ff       	call   8010354f <install_trans>
  log.lh.n = 0;
801036f2:	c7 05 a8 48 11 80 00 	movl   $0x0,0x801148a8
801036f9:	00 00 00 
  write_head(); // clear the log
801036fc:	e8 67 ff ff ff       	call   80103668 <write_head>
}
80103701:	c9                   	leave  
80103702:	c3                   	ret    

80103703 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103703:	55                   	push   %ebp
80103704:	89 e5                	mov    %esp,%ebp
80103706:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103709:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103710:	e8 2a 22 00 00       	call   8010593f <acquire>
  while(1){
    if(log.committing){
80103715:	a1 a0 48 11 80       	mov    0x801148a0,%eax
8010371a:	85 c0                	test   %eax,%eax
8010371c:	74 16                	je     80103734 <begin_op+0x31>
      sleep(&log, &log.lock);
8010371e:	c7 44 24 04 60 48 11 	movl   $0x80114860,0x4(%esp)
80103725:	80 
80103726:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
8010372d:	e8 a2 14 00 00       	call   80104bd4 <sleep>
80103732:	eb 4d                	jmp    80103781 <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103734:	8b 15 a8 48 11 80    	mov    0x801148a8,%edx
8010373a:	a1 9c 48 11 80       	mov    0x8011489c,%eax
8010373f:	8d 48 01             	lea    0x1(%eax),%ecx
80103742:	89 c8                	mov    %ecx,%eax
80103744:	c1 e0 02             	shl    $0x2,%eax
80103747:	01 c8                	add    %ecx,%eax
80103749:	01 c0                	add    %eax,%eax
8010374b:	01 d0                	add    %edx,%eax
8010374d:	83 f8 1e             	cmp    $0x1e,%eax
80103750:	7e 16                	jle    80103768 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103752:	c7 44 24 04 60 48 11 	movl   $0x80114860,0x4(%esp)
80103759:	80 
8010375a:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103761:	e8 6e 14 00 00       	call   80104bd4 <sleep>
80103766:	eb 19                	jmp    80103781 <begin_op+0x7e>
    } else {
      log.outstanding += 1;
80103768:	a1 9c 48 11 80       	mov    0x8011489c,%eax
8010376d:	40                   	inc    %eax
8010376e:	a3 9c 48 11 80       	mov    %eax,0x8011489c
      release(&log.lock);
80103773:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
8010377a:	e8 2a 22 00 00       	call   801059a9 <release>
      break;
8010377f:	eb 02                	jmp    80103783 <begin_op+0x80>
    }
  }
80103781:	eb 92                	jmp    80103715 <begin_op+0x12>
}
80103783:	c9                   	leave  
80103784:	c3                   	ret    

80103785 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103785:	55                   	push   %ebp
80103786:	89 e5                	mov    %esp,%ebp
80103788:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
8010378b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
80103792:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103799:	e8 a1 21 00 00       	call   8010593f <acquire>
  log.outstanding -= 1;
8010379e:	a1 9c 48 11 80       	mov    0x8011489c,%eax
801037a3:	48                   	dec    %eax
801037a4:	a3 9c 48 11 80       	mov    %eax,0x8011489c
  if(log.committing)
801037a9:	a1 a0 48 11 80       	mov    0x801148a0,%eax
801037ae:	85 c0                	test   %eax,%eax
801037b0:	74 0c                	je     801037be <end_op+0x39>
    panic("log.committing");
801037b2:	c7 04 24 59 95 10 80 	movl   $0x80109559,(%esp)
801037b9:	e8 96 cd ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
801037be:	a1 9c 48 11 80       	mov    0x8011489c,%eax
801037c3:	85 c0                	test   %eax,%eax
801037c5:	75 13                	jne    801037da <end_op+0x55>
    do_commit = 1;
801037c7:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801037ce:	c7 05 a0 48 11 80 01 	movl   $0x1,0x801148a0
801037d5:	00 00 00 
801037d8:	eb 0c                	jmp    801037e6 <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801037da:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801037e1:	e8 dc 14 00 00       	call   80104cc2 <wakeup>
  }
  release(&log.lock);
801037e6:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801037ed:	e8 b7 21 00 00       	call   801059a9 <release>

  if(do_commit){
801037f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801037f6:	74 33                	je     8010382b <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801037f8:	e8 db 00 00 00       	call   801038d8 <commit>
    acquire(&log.lock);
801037fd:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103804:	e8 36 21 00 00       	call   8010593f <acquire>
    log.committing = 0;
80103809:	c7 05 a0 48 11 80 00 	movl   $0x0,0x801148a0
80103810:	00 00 00 
    wakeup(&log);
80103813:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
8010381a:	e8 a3 14 00 00       	call   80104cc2 <wakeup>
    release(&log.lock);
8010381f:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103826:	e8 7e 21 00 00       	call   801059a9 <release>
  }
}
8010382b:	c9                   	leave  
8010382c:	c3                   	ret    

8010382d <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010382d:	55                   	push   %ebp
8010382e:	89 e5                	mov    %esp,%ebp
80103830:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103833:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010383a:	e9 89 00 00 00       	jmp    801038c8 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010383f:	8b 15 94 48 11 80    	mov    0x80114894,%edx
80103845:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103848:	01 d0                	add    %edx,%eax
8010384a:	40                   	inc    %eax
8010384b:	89 c2                	mov    %eax,%edx
8010384d:	a1 a4 48 11 80       	mov    0x801148a4,%eax
80103852:	89 54 24 04          	mov    %edx,0x4(%esp)
80103856:	89 04 24             	mov    %eax,(%esp)
80103859:	e8 57 c9 ff ff       	call   801001b5 <bread>
8010385e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103864:	83 c0 10             	add    $0x10,%eax
80103867:	8b 04 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%eax
8010386e:	89 c2                	mov    %eax,%edx
80103870:	a1 a4 48 11 80       	mov    0x801148a4,%eax
80103875:	89 54 24 04          	mov    %edx,0x4(%esp)
80103879:	89 04 24             	mov    %eax,(%esp)
8010387c:	e8 34 c9 ff ff       	call   801001b5 <bread>
80103881:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
80103884:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103887:	8d 50 5c             	lea    0x5c(%eax),%edx
8010388a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010388d:	83 c0 5c             	add    $0x5c,%eax
80103890:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103897:	00 
80103898:	89 54 24 04          	mov    %edx,0x4(%esp)
8010389c:	89 04 24             	mov    %eax,(%esp)
8010389f:	e8 c7 23 00 00       	call   80105c6b <memmove>
    bwrite(to);  // write the log
801038a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038a7:	89 04 24             	mov    %eax,(%esp)
801038aa:	e8 3d c9 ff ff       	call   801001ec <bwrite>
    brelse(from);
801038af:	8b 45 ec             	mov    -0x14(%ebp),%eax
801038b2:	89 04 24             	mov    %eax,(%esp)
801038b5:	e8 72 c9 ff ff       	call   8010022c <brelse>
    brelse(to);
801038ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801038bd:	89 04 24             	mov    %eax,(%esp)
801038c0:	e8 67 c9 ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801038c5:	ff 45 f4             	incl   -0xc(%ebp)
801038c8:	a1 a8 48 11 80       	mov    0x801148a8,%eax
801038cd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038d0:	0f 8f 69 ff ff ff    	jg     8010383f <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
801038d6:	c9                   	leave  
801038d7:	c3                   	ret    

801038d8 <commit>:

static void
commit()
{
801038d8:	55                   	push   %ebp
801038d9:	89 e5                	mov    %esp,%ebp
801038db:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801038de:	a1 a8 48 11 80       	mov    0x801148a8,%eax
801038e3:	85 c0                	test   %eax,%eax
801038e5:	7e 1e                	jle    80103905 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801038e7:	e8 41 ff ff ff       	call   8010382d <write_log>
    write_head();    // Write header to disk -- the real commit
801038ec:	e8 77 fd ff ff       	call   80103668 <write_head>
    install_trans(); // Now install writes to home locations
801038f1:	e8 59 fc ff ff       	call   8010354f <install_trans>
    log.lh.n = 0;
801038f6:	c7 05 a8 48 11 80 00 	movl   $0x0,0x801148a8
801038fd:	00 00 00 
    write_head();    // Erase the transaction from the log
80103900:	e8 63 fd ff ff       	call   80103668 <write_head>
  }
}
80103905:	c9                   	leave  
80103906:	c3                   	ret    

80103907 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103907:	55                   	push   %ebp
80103908:	89 e5                	mov    %esp,%ebp
8010390a:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010390d:	a1 a8 48 11 80       	mov    0x801148a8,%eax
80103912:	83 f8 1d             	cmp    $0x1d,%eax
80103915:	7f 10                	jg     80103927 <log_write+0x20>
80103917:	a1 a8 48 11 80       	mov    0x801148a8,%eax
8010391c:	8b 15 98 48 11 80    	mov    0x80114898,%edx
80103922:	4a                   	dec    %edx
80103923:	39 d0                	cmp    %edx,%eax
80103925:	7c 0c                	jl     80103933 <log_write+0x2c>
    panic("too big a transaction");
80103927:	c7 04 24 68 95 10 80 	movl   $0x80109568,(%esp)
8010392e:	e8 21 cc ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
80103933:	a1 9c 48 11 80       	mov    0x8011489c,%eax
80103938:	85 c0                	test   %eax,%eax
8010393a:	7f 0c                	jg     80103948 <log_write+0x41>
    panic("log_write outside of trans");
8010393c:	c7 04 24 7e 95 10 80 	movl   $0x8010957e,(%esp)
80103943:	e8 0c cc ff ff       	call   80100554 <panic>

  acquire(&log.lock);
80103948:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
8010394f:	e8 eb 1f 00 00       	call   8010593f <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103954:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010395b:	eb 1e                	jmp    8010397b <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
8010395d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103960:	83 c0 10             	add    $0x10,%eax
80103963:	8b 04 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%eax
8010396a:	89 c2                	mov    %eax,%edx
8010396c:	8b 45 08             	mov    0x8(%ebp),%eax
8010396f:	8b 40 08             	mov    0x8(%eax),%eax
80103972:	39 c2                	cmp    %eax,%edx
80103974:	75 02                	jne    80103978 <log_write+0x71>
      break;
80103976:	eb 0d                	jmp    80103985 <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103978:	ff 45 f4             	incl   -0xc(%ebp)
8010397b:	a1 a8 48 11 80       	mov    0x801148a8,%eax
80103980:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103983:	7f d8                	jg     8010395d <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
80103985:	8b 45 08             	mov    0x8(%ebp),%eax
80103988:	8b 40 08             	mov    0x8(%eax),%eax
8010398b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010398e:	83 c2 10             	add    $0x10,%edx
80103991:	89 04 95 6c 48 11 80 	mov    %eax,-0x7feeb794(,%edx,4)
  if (i == log.lh.n)
80103998:	a1 a8 48 11 80       	mov    0x801148a8,%eax
8010399d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039a0:	75 0b                	jne    801039ad <log_write+0xa6>
    log.lh.n++;
801039a2:	a1 a8 48 11 80       	mov    0x801148a8,%eax
801039a7:	40                   	inc    %eax
801039a8:	a3 a8 48 11 80       	mov    %eax,0x801148a8
  b->flags |= B_DIRTY; // prevent eviction
801039ad:	8b 45 08             	mov    0x8(%ebp),%eax
801039b0:	8b 00                	mov    (%eax),%eax
801039b2:	83 c8 04             	or     $0x4,%eax
801039b5:	89 c2                	mov    %eax,%edx
801039b7:	8b 45 08             	mov    0x8(%ebp),%eax
801039ba:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801039bc:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801039c3:	e8 e1 1f 00 00       	call   801059a9 <release>
}
801039c8:	c9                   	leave  
801039c9:	c3                   	ret    
	...

801039cc <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801039cc:	55                   	push   %ebp
801039cd:	89 e5                	mov    %esp,%ebp
801039cf:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801039d2:	8b 55 08             	mov    0x8(%ebp),%edx
801039d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801039d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
801039db:	f0 87 02             	lock xchg %eax,(%edx)
801039de:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801039e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801039e4:	c9                   	leave  
801039e5:	c3                   	ret    

801039e6 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801039e6:	55                   	push   %ebp
801039e7:	89 e5                	mov    %esp,%ebp
801039e9:	83 e4 f0             	and    $0xfffffff0,%esp
801039ec:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
801039ef:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
801039f6:	80 
801039f7:	c7 04 24 48 61 12 80 	movl   $0x80126148,(%esp)
801039fe:	e8 0d f3 ff ff       	call   80102d10 <kinit1>
  kvmalloc();      // kernel page table
80103a03:	e8 3f 4f 00 00       	call   80108947 <kvmalloc>
  mpinit();        // detect other processors
80103a08:	e8 c4 03 00 00       	call   80103dd1 <mpinit>
  lapicinit();     // interrupt controller
80103a0d:	e8 4e f6 ff ff       	call   80103060 <lapicinit>
  seginit();       // segment descriptors
80103a12:	e8 18 4a 00 00       	call   8010842f <seginit>
  picinit();       // disable pic
80103a17:	e8 04 05 00 00       	call   80103f20 <picinit>
  ioapicinit();    // another interrupt controller
80103a1c:	e8 0c f2 ff ff       	call   80102c2d <ioapicinit>
  consoleinit();   // console hardware
80103a21:	e8 91 d1 ff ff       	call   80100bb7 <consoleinit>
  uartinit();      // serial port
80103a26:	e8 90 3d 00 00       	call   801077bb <uartinit>
  cinit();         // container table
80103a2b:	e8 23 14 00 00       	call   80104e53 <cinit>
  tvinit();        // trap vectors
80103a30:	e8 53 39 00 00       	call   80107388 <tvinit>
  binit();         // buffer cache
80103a35:	e8 fa c5 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103a3a:	e8 81 d6 ff ff       	call   801010c0 <fileinit>
  ideinit();       // disk 
80103a3f:	e8 f5 ed ff ff       	call   80102839 <ideinit>
  startothers();   // start other processors
80103a44:	e8 83 00 00 00       	call   80103acc <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103a49:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80103a50:	8e 
80103a51:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103a58:	e8 eb f2 ff ff       	call   80102d48 <kinit2>
  userinit();      // first user process
80103a5d:	e8 4b 15 00 00       	call   80104fad <userinit>
  mpmain();        // finish this processor's setup
80103a62:	e8 1a 00 00 00       	call   80103a81 <mpmain>

80103a67 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103a67:	55                   	push   %ebp
80103a68:	89 e5                	mov    %esp,%ebp
80103a6a:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103a6d:	e8 ec 4e 00 00       	call   8010895e <switchkvm>
  seginit();
80103a72:	e8 b8 49 00 00       	call   8010842f <seginit>
  lapicinit();
80103a77:	e8 e4 f5 ff ff       	call   80103060 <lapicinit>
  mpmain();
80103a7c:	e8 00 00 00 00       	call   80103a81 <mpmain>

80103a81 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103a81:	55                   	push   %ebp
80103a82:	89 e5                	mov    %esp,%ebp
80103a84:	53                   	push   %ebx
80103a85:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103a88:	e8 fd 12 00 00       	call   80104d8a <cpuid>
80103a8d:	89 c3                	mov    %eax,%ebx
80103a8f:	e8 f6 12 00 00       	call   80104d8a <cpuid>
80103a94:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80103a98:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a9c:	c7 04 24 99 95 10 80 	movl   $0x80109599,(%esp)
80103aa3:	e8 19 c9 ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
80103aa8:	e8 38 3a 00 00       	call   801074e5 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103aad:	e8 1d 13 00 00       	call   80104dcf <mycpu>
80103ab2:	05 a0 00 00 00       	add    $0xa0,%eax
80103ab7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103abe:	00 
80103abf:	89 04 24             	mov    %eax,(%esp)
80103ac2:	e8 05 ff ff ff       	call   801039cc <xchg>
  scheduler();     // start running processes
80103ac7:	e8 47 16 00 00       	call   80105113 <scheduler>

80103acc <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103acc:	55                   	push   %ebp
80103acd:	89 e5                	mov    %esp,%ebp
80103acf:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103ad2:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103ad9:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103ade:	89 44 24 08          	mov    %eax,0x8(%esp)
80103ae2:	c7 44 24 04 2c c5 10 	movl   $0x8010c52c,0x4(%esp)
80103ae9:	80 
80103aea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aed:	89 04 24             	mov    %eax,(%esp)
80103af0:	e8 76 21 00 00       	call   80105c6b <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103af5:	c7 45 f4 60 49 11 80 	movl   $0x80114960,-0xc(%ebp)
80103afc:	eb 75                	jmp    80103b73 <startothers+0xa7>
    if(c == mycpu())  // We've started already.
80103afe:	e8 cc 12 00 00       	call   80104dcf <mycpu>
80103b03:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b06:	75 02                	jne    80103b0a <startothers+0x3e>
      continue;
80103b08:	eb 62                	jmp    80103b6c <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103b0a:	e8 2c f3 ff ff       	call   80102e3b <kalloc>
80103b0f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103b12:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b15:	83 e8 04             	sub    $0x4,%eax
80103b18:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103b1b:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103b21:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103b23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b26:	83 e8 08             	sub    $0x8,%eax
80103b29:	c7 00 67 3a 10 80    	movl   $0x80103a67,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103b2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b32:	8d 50 f4             	lea    -0xc(%eax),%edx
80103b35:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103b3a:	05 00 00 00 80       	add    $0x80000000,%eax
80103b3f:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
80103b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b44:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b4d:	8a 00                	mov    (%eax),%al
80103b4f:	0f b6 c0             	movzbl %al,%eax
80103b52:	89 54 24 04          	mov    %edx,0x4(%esp)
80103b56:	89 04 24             	mov    %eax,(%esp)
80103b59:	e8 a7 f6 ff ff       	call   80103205 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103b5e:	90                   	nop
80103b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b62:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103b68:	85 c0                	test   %eax,%eax
80103b6a:	74 f3                	je     80103b5f <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103b6c:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103b73:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80103b78:	89 c2                	mov    %eax,%edx
80103b7a:	89 d0                	mov    %edx,%eax
80103b7c:	c1 e0 02             	shl    $0x2,%eax
80103b7f:	01 d0                	add    %edx,%eax
80103b81:	01 c0                	add    %eax,%eax
80103b83:	01 d0                	add    %edx,%eax
80103b85:	c1 e0 04             	shl    $0x4,%eax
80103b88:	05 60 49 11 80       	add    $0x80114960,%eax
80103b8d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b90:	0f 87 68 ff ff ff    	ja     80103afe <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103b96:	c9                   	leave  
80103b97:	c3                   	ret    

80103b98 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103b98:	55                   	push   %ebp
80103b99:	89 e5                	mov    %esp,%ebp
80103b9b:	83 ec 14             	sub    $0x14,%esp
80103b9e:	8b 45 08             	mov    0x8(%ebp),%eax
80103ba1:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103ba5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ba8:	89 c2                	mov    %eax,%edx
80103baa:	ec                   	in     (%dx),%al
80103bab:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103bae:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103bb1:	c9                   	leave  
80103bb2:	c3                   	ret    

80103bb3 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103bb3:	55                   	push   %ebp
80103bb4:	89 e5                	mov    %esp,%ebp
80103bb6:	83 ec 08             	sub    $0x8,%esp
80103bb9:	8b 45 08             	mov    0x8(%ebp),%eax
80103bbc:	8b 55 0c             	mov    0xc(%ebp),%edx
80103bbf:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103bc3:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103bc6:	8a 45 f8             	mov    -0x8(%ebp),%al
80103bc9:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103bcc:	ee                   	out    %al,(%dx)
}
80103bcd:	c9                   	leave  
80103bce:	c3                   	ret    

80103bcf <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103bcf:	55                   	push   %ebp
80103bd0:	89 e5                	mov    %esp,%ebp
80103bd2:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103bd5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103bdc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103be3:	eb 13                	jmp    80103bf8 <sum+0x29>
    sum += addr[i];
80103be5:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103be8:	8b 45 08             	mov    0x8(%ebp),%eax
80103beb:	01 d0                	add    %edx,%eax
80103bed:	8a 00                	mov    (%eax),%al
80103bef:	0f b6 c0             	movzbl %al,%eax
80103bf2:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103bf5:	ff 45 fc             	incl   -0x4(%ebp)
80103bf8:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103bfb:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103bfe:	7c e5                	jl     80103be5 <sum+0x16>
    sum += addr[i];
  return sum;
80103c00:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103c03:	c9                   	leave  
80103c04:	c3                   	ret    

80103c05 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103c05:	55                   	push   %ebp
80103c06:	89 e5                	mov    %esp,%ebp
80103c08:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103c0b:	8b 45 08             	mov    0x8(%ebp),%eax
80103c0e:	05 00 00 00 80       	add    $0x80000000,%eax
80103c13:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103c16:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c1c:	01 d0                	add    %edx,%eax
80103c1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c24:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c27:	eb 3f                	jmp    80103c68 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103c29:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103c30:	00 
80103c31:	c7 44 24 04 b0 95 10 	movl   $0x801095b0,0x4(%esp)
80103c38:	80 
80103c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c3c:	89 04 24             	mov    %eax,(%esp)
80103c3f:	e8 d5 1f 00 00       	call   80105c19 <memcmp>
80103c44:	85 c0                	test   %eax,%eax
80103c46:	75 1c                	jne    80103c64 <mpsearch1+0x5f>
80103c48:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103c4f:	00 
80103c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c53:	89 04 24             	mov    %eax,(%esp)
80103c56:	e8 74 ff ff ff       	call   80103bcf <sum>
80103c5b:	84 c0                	test   %al,%al
80103c5d:	75 05                	jne    80103c64 <mpsearch1+0x5f>
      return (struct mp*)p;
80103c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c62:	eb 11                	jmp    80103c75 <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103c64:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103c68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c6b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103c6e:	72 b9                	jb     80103c29 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103c70:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103c75:	c9                   	leave  
80103c76:	c3                   	ret    

80103c77 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103c77:	55                   	push   %ebp
80103c78:	89 e5                	mov    %esp,%ebp
80103c7a:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103c7d:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c87:	83 c0 0f             	add    $0xf,%eax
80103c8a:	8a 00                	mov    (%eax),%al
80103c8c:	0f b6 c0             	movzbl %al,%eax
80103c8f:	c1 e0 08             	shl    $0x8,%eax
80103c92:	89 c2                	mov    %eax,%edx
80103c94:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c97:	83 c0 0e             	add    $0xe,%eax
80103c9a:	8a 00                	mov    (%eax),%al
80103c9c:	0f b6 c0             	movzbl %al,%eax
80103c9f:	09 d0                	or     %edx,%eax
80103ca1:	c1 e0 04             	shl    $0x4,%eax
80103ca4:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103ca7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103cab:	74 21                	je     80103cce <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103cad:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103cb4:	00 
80103cb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb8:	89 04 24             	mov    %eax,(%esp)
80103cbb:	e8 45 ff ff ff       	call   80103c05 <mpsearch1>
80103cc0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103cc3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103cc7:	74 4e                	je     80103d17 <mpsearch+0xa0>
      return mp;
80103cc9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ccc:	eb 5d                	jmp    80103d2b <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd1:	83 c0 14             	add    $0x14,%eax
80103cd4:	8a 00                	mov    (%eax),%al
80103cd6:	0f b6 c0             	movzbl %al,%eax
80103cd9:	c1 e0 08             	shl    $0x8,%eax
80103cdc:	89 c2                	mov    %eax,%edx
80103cde:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ce1:	83 c0 13             	add    $0x13,%eax
80103ce4:	8a 00                	mov    (%eax),%al
80103ce6:	0f b6 c0             	movzbl %al,%eax
80103ce9:	09 d0                	or     %edx,%eax
80103ceb:	c1 e0 0a             	shl    $0xa,%eax
80103cee:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103cf1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf4:	2d 00 04 00 00       	sub    $0x400,%eax
80103cf9:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103d00:	00 
80103d01:	89 04 24             	mov    %eax,(%esp)
80103d04:	e8 fc fe ff ff       	call   80103c05 <mpsearch1>
80103d09:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d0c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d10:	74 05                	je     80103d17 <mpsearch+0xa0>
      return mp;
80103d12:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d15:	eb 14                	jmp    80103d2b <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103d17:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103d1e:	00 
80103d1f:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103d26:	e8 da fe ff ff       	call   80103c05 <mpsearch1>
}
80103d2b:	c9                   	leave  
80103d2c:	c3                   	ret    

80103d2d <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103d2d:	55                   	push   %ebp
80103d2e:	89 e5                	mov    %esp,%ebp
80103d30:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103d33:	e8 3f ff ff ff       	call   80103c77 <mpsearch>
80103d38:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d3b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d3f:	74 0a                	je     80103d4b <mpconfig+0x1e>
80103d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d44:	8b 40 04             	mov    0x4(%eax),%eax
80103d47:	85 c0                	test   %eax,%eax
80103d49:	75 07                	jne    80103d52 <mpconfig+0x25>
    return 0;
80103d4b:	b8 00 00 00 00       	mov    $0x0,%eax
80103d50:	eb 7d                	jmp    80103dcf <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103d52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d55:	8b 40 04             	mov    0x4(%eax),%eax
80103d58:	05 00 00 00 80       	add    $0x80000000,%eax
80103d5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103d60:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103d67:	00 
80103d68:	c7 44 24 04 b5 95 10 	movl   $0x801095b5,0x4(%esp)
80103d6f:	80 
80103d70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d73:	89 04 24             	mov    %eax,(%esp)
80103d76:	e8 9e 1e 00 00       	call   80105c19 <memcmp>
80103d7b:	85 c0                	test   %eax,%eax
80103d7d:	74 07                	je     80103d86 <mpconfig+0x59>
    return 0;
80103d7f:	b8 00 00 00 00       	mov    $0x0,%eax
80103d84:	eb 49                	jmp    80103dcf <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103d86:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d89:	8a 40 06             	mov    0x6(%eax),%al
80103d8c:	3c 01                	cmp    $0x1,%al
80103d8e:	74 11                	je     80103da1 <mpconfig+0x74>
80103d90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d93:	8a 40 06             	mov    0x6(%eax),%al
80103d96:	3c 04                	cmp    $0x4,%al
80103d98:	74 07                	je     80103da1 <mpconfig+0x74>
    return 0;
80103d9a:	b8 00 00 00 00       	mov    $0x0,%eax
80103d9f:	eb 2e                	jmp    80103dcf <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103da1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103da4:	8b 40 04             	mov    0x4(%eax),%eax
80103da7:	0f b7 c0             	movzwl %ax,%eax
80103daa:	89 44 24 04          	mov    %eax,0x4(%esp)
80103dae:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103db1:	89 04 24             	mov    %eax,(%esp)
80103db4:	e8 16 fe ff ff       	call   80103bcf <sum>
80103db9:	84 c0                	test   %al,%al
80103dbb:	74 07                	je     80103dc4 <mpconfig+0x97>
    return 0;
80103dbd:	b8 00 00 00 00       	mov    $0x0,%eax
80103dc2:	eb 0b                	jmp    80103dcf <mpconfig+0xa2>
  *pmp = mp;
80103dc4:	8b 45 08             	mov    0x8(%ebp),%eax
80103dc7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103dca:	89 10                	mov    %edx,(%eax)
  return conf;
80103dcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103dcf:	c9                   	leave  
80103dd0:	c3                   	ret    

80103dd1 <mpinit>:

void
mpinit(void)
{
80103dd1:	55                   	push   %ebp
80103dd2:	89 e5                	mov    %esp,%ebp
80103dd4:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103dd7:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103dda:	89 04 24             	mov    %eax,(%esp)
80103ddd:	e8 4b ff ff ff       	call   80103d2d <mpconfig>
80103de2:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103de5:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103de9:	75 0c                	jne    80103df7 <mpinit+0x26>
    panic("Expect to run on an SMP");
80103deb:	c7 04 24 ba 95 10 80 	movl   $0x801095ba,(%esp)
80103df2:	e8 5d c7 ff ff       	call   80100554 <panic>
  ismp = 1;
80103df7:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103dfe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e01:	8b 40 24             	mov    0x24(%eax),%eax
80103e04:	a3 5c 48 11 80       	mov    %eax,0x8011485c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e09:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e0c:	83 c0 2c             	add    $0x2c,%eax
80103e0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103e12:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e15:	8b 40 04             	mov    0x4(%eax),%eax
80103e18:	0f b7 d0             	movzwl %ax,%edx
80103e1b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103e1e:	01 d0                	add    %edx,%eax
80103e20:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103e23:	eb 7d                	jmp    80103ea2 <mpinit+0xd1>
    switch(*p){
80103e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e28:	8a 00                	mov    (%eax),%al
80103e2a:	0f b6 c0             	movzbl %al,%eax
80103e2d:	83 f8 04             	cmp    $0x4,%eax
80103e30:	77 68                	ja     80103e9a <mpinit+0xc9>
80103e32:	8b 04 85 f4 95 10 80 	mov    -0x7fef6a0c(,%eax,4),%eax
80103e39:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103e3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e3e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103e41:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80103e46:	83 f8 07             	cmp    $0x7,%eax
80103e49:	7f 2c                	jg     80103e77 <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103e4b:	8b 15 e0 4e 11 80    	mov    0x80114ee0,%edx
80103e51:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103e54:	8a 48 01             	mov    0x1(%eax),%cl
80103e57:	89 d0                	mov    %edx,%eax
80103e59:	c1 e0 02             	shl    $0x2,%eax
80103e5c:	01 d0                	add    %edx,%eax
80103e5e:	01 c0                	add    %eax,%eax
80103e60:	01 d0                	add    %edx,%eax
80103e62:	c1 e0 04             	shl    $0x4,%eax
80103e65:	05 60 49 11 80       	add    $0x80114960,%eax
80103e6a:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103e6c:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80103e71:	40                   	inc    %eax
80103e72:	a3 e0 4e 11 80       	mov    %eax,0x80114ee0
      }
      p += sizeof(struct mpproc);
80103e77:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103e7b:	eb 25                	jmp    80103ea2 <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e80:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103e83:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e86:	8a 40 01             	mov    0x1(%eax),%al
80103e89:	a2 40 49 11 80       	mov    %al,0x80114940
      p += sizeof(struct mpioapic);
80103e8e:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e92:	eb 0e                	jmp    80103ea2 <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e94:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e98:	eb 08                	jmp    80103ea2 <mpinit+0xd1>
    default:
      ismp = 0;
80103e9a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103ea1:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ea5:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103ea8:	0f 82 77 ff ff ff    	jb     80103e25 <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103eae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103eb2:	75 0c                	jne    80103ec0 <mpinit+0xef>
    panic("Didn't find a suitable machine");
80103eb4:	c7 04 24 d4 95 10 80 	movl   $0x801095d4,(%esp)
80103ebb:	e8 94 c6 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80103ec0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ec3:	8a 40 0c             	mov    0xc(%eax),%al
80103ec6:	84 c0                	test   %al,%al
80103ec8:	74 36                	je     80103f00 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103eca:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103ed1:	00 
80103ed2:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103ed9:	e8 d5 fc ff ff       	call   80103bb3 <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103ede:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103ee5:	e8 ae fc ff ff       	call   80103b98 <inb>
80103eea:	83 c8 01             	or     $0x1,%eax
80103eed:	0f b6 c0             	movzbl %al,%eax
80103ef0:	89 44 24 04          	mov    %eax,0x4(%esp)
80103ef4:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103efb:	e8 b3 fc ff ff       	call   80103bb3 <outb>
  }
}
80103f00:	c9                   	leave  
80103f01:	c3                   	ret    
	...

80103f04 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103f04:	55                   	push   %ebp
80103f05:	89 e5                	mov    %esp,%ebp
80103f07:	83 ec 08             	sub    $0x8,%esp
80103f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0d:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f10:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103f14:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103f17:	8a 45 f8             	mov    -0x8(%ebp),%al
80103f1a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103f1d:	ee                   	out    %al,(%dx)
}
80103f1e:	c9                   	leave  
80103f1f:	c3                   	ret    

80103f20 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103f20:	55                   	push   %ebp
80103f21:	89 e5                	mov    %esp,%ebp
80103f23:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f26:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103f2d:	00 
80103f2e:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103f35:	e8 ca ff ff ff       	call   80103f04 <outb>
  outb(IO_PIC2+1, 0xFF);
80103f3a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103f41:	00 
80103f42:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103f49:	e8 b6 ff ff ff       	call   80103f04 <outb>
}
80103f4e:	c9                   	leave  
80103f4f:	c3                   	ret    

80103f50 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103f50:	55                   	push   %ebp
80103f51:	89 e5                	mov    %esp,%ebp
80103f53:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103f56:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f60:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103f66:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f69:	8b 10                	mov    (%eax),%edx
80103f6b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6e:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f70:	e8 67 d1 ff ff       	call   801010dc <filealloc>
80103f75:	8b 55 08             	mov    0x8(%ebp),%edx
80103f78:	89 02                	mov    %eax,(%edx)
80103f7a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7d:	8b 00                	mov    (%eax),%eax
80103f7f:	85 c0                	test   %eax,%eax
80103f81:	0f 84 c8 00 00 00    	je     8010404f <pipealloc+0xff>
80103f87:	e8 50 d1 ff ff       	call   801010dc <filealloc>
80103f8c:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f8f:	89 02                	mov    %eax,(%edx)
80103f91:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f94:	8b 00                	mov    (%eax),%eax
80103f96:	85 c0                	test   %eax,%eax
80103f98:	0f 84 b1 00 00 00    	je     8010404f <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103f9e:	e8 98 ee ff ff       	call   80102e3b <kalloc>
80103fa3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103fa6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103faa:	75 05                	jne    80103fb1 <pipealloc+0x61>
    goto bad;
80103fac:	e9 9e 00 00 00       	jmp    8010404f <pipealloc+0xff>
  p->readopen = 1;
80103fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fb4:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103fbb:	00 00 00 
  p->writeopen = 1;
80103fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fc1:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103fc8:	00 00 00 
  p->nwrite = 0;
80103fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fce:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103fd5:	00 00 00 
  p->nread = 0;
80103fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fdb:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103fe2:	00 00 00 
  initlock(&p->lock, "pipe");
80103fe5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fe8:	c7 44 24 04 08 96 10 	movl   $0x80109608,0x4(%esp)
80103fef:	80 
80103ff0:	89 04 24             	mov    %eax,(%esp)
80103ff3:	e8 26 19 00 00       	call   8010591e <initlock>
  (*f0)->type = FD_PIPE;
80103ff8:	8b 45 08             	mov    0x8(%ebp),%eax
80103ffb:	8b 00                	mov    (%eax),%eax
80103ffd:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104003:	8b 45 08             	mov    0x8(%ebp),%eax
80104006:	8b 00                	mov    (%eax),%eax
80104008:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
8010400c:	8b 45 08             	mov    0x8(%ebp),%eax
8010400f:	8b 00                	mov    (%eax),%eax
80104011:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80104015:	8b 45 08             	mov    0x8(%ebp),%eax
80104018:	8b 00                	mov    (%eax),%eax
8010401a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010401d:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104020:	8b 45 0c             	mov    0xc(%ebp),%eax
80104023:	8b 00                	mov    (%eax),%eax
80104025:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
8010402b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010402e:	8b 00                	mov    (%eax),%eax
80104030:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80104034:	8b 45 0c             	mov    0xc(%ebp),%eax
80104037:	8b 00                	mov    (%eax),%eax
80104039:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010403d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104040:	8b 00                	mov    (%eax),%eax
80104042:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104045:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104048:	b8 00 00 00 00       	mov    $0x0,%eax
8010404d:	eb 42                	jmp    80104091 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
8010404f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104053:	74 0b                	je     80104060 <pipealloc+0x110>
    kfree((char*)p);
80104055:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104058:	89 04 24             	mov    %eax,(%esp)
8010405b:	e8 45 ed ff ff       	call   80102da5 <kfree>
  if(*f0)
80104060:	8b 45 08             	mov    0x8(%ebp),%eax
80104063:	8b 00                	mov    (%eax),%eax
80104065:	85 c0                	test   %eax,%eax
80104067:	74 0d                	je     80104076 <pipealloc+0x126>
    fileclose(*f0);
80104069:	8b 45 08             	mov    0x8(%ebp),%eax
8010406c:	8b 00                	mov    (%eax),%eax
8010406e:	89 04 24             	mov    %eax,(%esp)
80104071:	e8 0e d1 ff ff       	call   80101184 <fileclose>
  if(*f1)
80104076:	8b 45 0c             	mov    0xc(%ebp),%eax
80104079:	8b 00                	mov    (%eax),%eax
8010407b:	85 c0                	test   %eax,%eax
8010407d:	74 0d                	je     8010408c <pipealloc+0x13c>
    fileclose(*f1);
8010407f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104082:	8b 00                	mov    (%eax),%eax
80104084:	89 04 24             	mov    %eax,(%esp)
80104087:	e8 f8 d0 ff ff       	call   80101184 <fileclose>
  return -1;
8010408c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104091:	c9                   	leave  
80104092:	c3                   	ret    

80104093 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104093:	55                   	push   %ebp
80104094:	89 e5                	mov    %esp,%ebp
80104096:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104099:	8b 45 08             	mov    0x8(%ebp),%eax
8010409c:	89 04 24             	mov    %eax,(%esp)
8010409f:	e8 9b 18 00 00       	call   8010593f <acquire>
  if(writable){
801040a4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801040a8:	74 1f                	je     801040c9 <pipeclose+0x36>
    p->writeopen = 0;
801040aa:	8b 45 08             	mov    0x8(%ebp),%eax
801040ad:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801040b4:	00 00 00 
    wakeup(&p->nread);
801040b7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ba:	05 34 02 00 00       	add    $0x234,%eax
801040bf:	89 04 24             	mov    %eax,(%esp)
801040c2:	e8 fb 0b 00 00       	call   80104cc2 <wakeup>
801040c7:	eb 1d                	jmp    801040e6 <pipeclose+0x53>
  } else {
    p->readopen = 0;
801040c9:	8b 45 08             	mov    0x8(%ebp),%eax
801040cc:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801040d3:	00 00 00 
    wakeup(&p->nwrite);
801040d6:	8b 45 08             	mov    0x8(%ebp),%eax
801040d9:	05 38 02 00 00       	add    $0x238,%eax
801040de:	89 04 24             	mov    %eax,(%esp)
801040e1:	e8 dc 0b 00 00       	call   80104cc2 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
801040e6:	8b 45 08             	mov    0x8(%ebp),%eax
801040e9:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801040ef:	85 c0                	test   %eax,%eax
801040f1:	75 25                	jne    80104118 <pipeclose+0x85>
801040f3:	8b 45 08             	mov    0x8(%ebp),%eax
801040f6:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801040fc:	85 c0                	test   %eax,%eax
801040fe:	75 18                	jne    80104118 <pipeclose+0x85>
    release(&p->lock);
80104100:	8b 45 08             	mov    0x8(%ebp),%eax
80104103:	89 04 24             	mov    %eax,(%esp)
80104106:	e8 9e 18 00 00       	call   801059a9 <release>
    kfree((char*)p);
8010410b:	8b 45 08             	mov    0x8(%ebp),%eax
8010410e:	89 04 24             	mov    %eax,(%esp)
80104111:	e8 8f ec ff ff       	call   80102da5 <kfree>
80104116:	eb 0b                	jmp    80104123 <pipeclose+0x90>
  } else
    release(&p->lock);
80104118:	8b 45 08             	mov    0x8(%ebp),%eax
8010411b:	89 04 24             	mov    %eax,(%esp)
8010411e:	e8 86 18 00 00       	call   801059a9 <release>
}
80104123:	c9                   	leave  
80104124:	c3                   	ret    

80104125 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104125:	55                   	push   %ebp
80104126:	89 e5                	mov    %esp,%ebp
80104128:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
8010412b:	8b 45 08             	mov    0x8(%ebp),%eax
8010412e:	89 04 24             	mov    %eax,(%esp)
80104131:	e8 09 18 00 00       	call   8010593f <acquire>
  for(i = 0; i < n; i++){
80104136:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010413d:	e9 a3 00 00 00       	jmp    801041e5 <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104142:	eb 56                	jmp    8010419a <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
80104144:	8b 45 08             	mov    0x8(%ebp),%eax
80104147:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010414d:	85 c0                	test   %eax,%eax
8010414f:	74 0c                	je     8010415d <pipewrite+0x38>
80104151:	e8 aa 01 00 00       	call   80104300 <myproc>
80104156:	8b 40 24             	mov    0x24(%eax),%eax
80104159:	85 c0                	test   %eax,%eax
8010415b:	74 15                	je     80104172 <pipewrite+0x4d>
        release(&p->lock);
8010415d:	8b 45 08             	mov    0x8(%ebp),%eax
80104160:	89 04 24             	mov    %eax,(%esp)
80104163:	e8 41 18 00 00       	call   801059a9 <release>
        return -1;
80104168:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010416d:	e9 9d 00 00 00       	jmp    8010420f <pipewrite+0xea>
      }
      wakeup(&p->nread);
80104172:	8b 45 08             	mov    0x8(%ebp),%eax
80104175:	05 34 02 00 00       	add    $0x234,%eax
8010417a:	89 04 24             	mov    %eax,(%esp)
8010417d:	e8 40 0b 00 00       	call   80104cc2 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104182:	8b 45 08             	mov    0x8(%ebp),%eax
80104185:	8b 55 08             	mov    0x8(%ebp),%edx
80104188:	81 c2 38 02 00 00    	add    $0x238,%edx
8010418e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104192:	89 14 24             	mov    %edx,(%esp)
80104195:	e8 3a 0a 00 00       	call   80104bd4 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010419a:	8b 45 08             	mov    0x8(%ebp),%eax
8010419d:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801041a3:	8b 45 08             	mov    0x8(%ebp),%eax
801041a6:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801041ac:	05 00 02 00 00       	add    $0x200,%eax
801041b1:	39 c2                	cmp    %eax,%edx
801041b3:	74 8f                	je     80104144 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801041b5:	8b 45 08             	mov    0x8(%ebp),%eax
801041b8:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041be:	8d 48 01             	lea    0x1(%eax),%ecx
801041c1:	8b 55 08             	mov    0x8(%ebp),%edx
801041c4:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801041ca:	25 ff 01 00 00       	and    $0x1ff,%eax
801041cf:	89 c1                	mov    %eax,%ecx
801041d1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801041d7:	01 d0                	add    %edx,%eax
801041d9:	8a 10                	mov    (%eax),%dl
801041db:	8b 45 08             	mov    0x8(%ebp),%eax
801041de:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801041e2:	ff 45 f4             	incl   -0xc(%ebp)
801041e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041e8:	3b 45 10             	cmp    0x10(%ebp),%eax
801041eb:	0f 8c 51 ff ff ff    	jl     80104142 <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801041f1:	8b 45 08             	mov    0x8(%ebp),%eax
801041f4:	05 34 02 00 00       	add    $0x234,%eax
801041f9:	89 04 24             	mov    %eax,(%esp)
801041fc:	e8 c1 0a 00 00       	call   80104cc2 <wakeup>
  release(&p->lock);
80104201:	8b 45 08             	mov    0x8(%ebp),%eax
80104204:	89 04 24             	mov    %eax,(%esp)
80104207:	e8 9d 17 00 00       	call   801059a9 <release>
  return n;
8010420c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010420f:	c9                   	leave  
80104210:	c3                   	ret    

80104211 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104211:	55                   	push   %ebp
80104212:	89 e5                	mov    %esp,%ebp
80104214:	53                   	push   %ebx
80104215:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104218:	8b 45 08             	mov    0x8(%ebp),%eax
8010421b:	89 04 24             	mov    %eax,(%esp)
8010421e:	e8 1c 17 00 00       	call   8010593f <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104223:	eb 39                	jmp    8010425e <piperead+0x4d>
    if(myproc()->killed){
80104225:	e8 d6 00 00 00       	call   80104300 <myproc>
8010422a:	8b 40 24             	mov    0x24(%eax),%eax
8010422d:	85 c0                	test   %eax,%eax
8010422f:	74 15                	je     80104246 <piperead+0x35>
      release(&p->lock);
80104231:	8b 45 08             	mov    0x8(%ebp),%eax
80104234:	89 04 24             	mov    %eax,(%esp)
80104237:	e8 6d 17 00 00       	call   801059a9 <release>
      return -1;
8010423c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104241:	e9 b3 00 00 00       	jmp    801042f9 <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104246:	8b 45 08             	mov    0x8(%ebp),%eax
80104249:	8b 55 08             	mov    0x8(%ebp),%edx
8010424c:	81 c2 34 02 00 00    	add    $0x234,%edx
80104252:	89 44 24 04          	mov    %eax,0x4(%esp)
80104256:	89 14 24             	mov    %edx,(%esp)
80104259:	e8 76 09 00 00       	call   80104bd4 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010425e:	8b 45 08             	mov    0x8(%ebp),%eax
80104261:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104267:	8b 45 08             	mov    0x8(%ebp),%eax
8010426a:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104270:	39 c2                	cmp    %eax,%edx
80104272:	75 0d                	jne    80104281 <piperead+0x70>
80104274:	8b 45 08             	mov    0x8(%ebp),%eax
80104277:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010427d:	85 c0                	test   %eax,%eax
8010427f:	75 a4                	jne    80104225 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104281:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104288:	eb 49                	jmp    801042d3 <piperead+0xc2>
    if(p->nread == p->nwrite)
8010428a:	8b 45 08             	mov    0x8(%ebp),%eax
8010428d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104293:	8b 45 08             	mov    0x8(%ebp),%eax
80104296:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010429c:	39 c2                	cmp    %eax,%edx
8010429e:	75 02                	jne    801042a2 <piperead+0x91>
      break;
801042a0:	eb 39                	jmp    801042db <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
801042a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042a5:	8b 45 0c             	mov    0xc(%ebp),%eax
801042a8:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801042ab:	8b 45 08             	mov    0x8(%ebp),%eax
801042ae:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042b4:	8d 48 01             	lea    0x1(%eax),%ecx
801042b7:	8b 55 08             	mov    0x8(%ebp),%edx
801042ba:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801042c0:	25 ff 01 00 00       	and    $0x1ff,%eax
801042c5:	89 c2                	mov    %eax,%edx
801042c7:	8b 45 08             	mov    0x8(%ebp),%eax
801042ca:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
801042ce:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801042d0:	ff 45 f4             	incl   -0xc(%ebp)
801042d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d6:	3b 45 10             	cmp    0x10(%ebp),%eax
801042d9:	7c af                	jl     8010428a <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801042db:	8b 45 08             	mov    0x8(%ebp),%eax
801042de:	05 38 02 00 00       	add    $0x238,%eax
801042e3:	89 04 24             	mov    %eax,(%esp)
801042e6:	e8 d7 09 00 00       	call   80104cc2 <wakeup>
  release(&p->lock);
801042eb:	8b 45 08             	mov    0x8(%ebp),%eax
801042ee:	89 04 24             	mov    %eax,(%esp)
801042f1:	e8 b3 16 00 00       	call   801059a9 <release>
  return i;
801042f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801042f9:	83 c4 24             	add    $0x24,%esp
801042fc:	5b                   	pop    %ebx
801042fd:	5d                   	pop    %ebp
801042fe:	c3                   	ret    
	...

80104300 <myproc>:
static void wakeup1(void *chan);

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104300:	55                   	push   %ebp
80104301:	89 e5                	mov    %esp,%ebp
80104303:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104306:	e8 93 17 00 00       	call   80105a9e <pushcli>
  c = mycpu();
8010430b:	e8 bf 0a 00 00       	call   80104dcf <mycpu>
80104310:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80104313:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104316:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
8010431c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
8010431f:	e8 c4 17 00 00       	call   80105ae8 <popcli>
  return p;
80104324:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104327:	c9                   	leave  
80104328:	c3                   	ret    

80104329 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
struct proc*
allocproc(struct cont *parentcont)
{
80104329:	55                   	push   %ebp
8010432a:	89 e5                	mov    %esp,%ebp
8010432c:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;
  struct proc *ptable;
  int nproc;

  acquirectable();
8010432f:	e8 4f 0b 00 00       	call   80104e83 <acquirectable>

  ptable = parentcont->ptable;
80104334:	8b 45 08             	mov    0x8(%ebp),%eax
80104337:	8b 40 28             	mov    0x28(%eax),%eax
8010433a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  nproc = parentcont->mproc;
8010433d:	8b 45 08             	mov    0x8(%ebp),%eax
80104340:	8b 40 08             	mov    0x8(%eax),%eax
80104343:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for(p = ptable; p < &ptable[nproc]; p++) 
80104346:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104349:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010434c:	eb 4c                	jmp    8010439a <allocproc+0x71>
    if(p->state == UNUSED)
8010434e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104351:	8b 40 0c             	mov    0xc(%eax),%eax
80104354:	85 c0                	test   %eax,%eax
80104356:	75 3b                	jne    80104393 <allocproc+0x6a>
      goto found;  
80104358:	90                   	nop

  releasectable();
  return 0;

found:
  p->state = EMBRYO;
80104359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435c:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;  
80104363:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80104368:	8d 50 01             	lea    0x1(%eax),%edx
8010436b:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
80104371:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104374:	89 42 10             	mov    %eax,0x10(%edx)

  releasectable();  
80104377:	e8 1b 0b 00 00       	call   80104e97 <releasectable>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010437c:	e8 ba ea ff ff       	call   80102e3b <kalloc>
80104381:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104384:	89 42 08             	mov    %eax,0x8(%edx)
80104387:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010438a:	8b 40 08             	mov    0x8(%eax),%eax
8010438d:	85 c0                	test   %eax,%eax
8010438f:	75 40                	jne    801043d1 <allocproc+0xa8>
80104391:	eb 2d                	jmp    801043c0 <allocproc+0x97>
  acquirectable();

  ptable = parentcont->ptable;
  nproc = parentcont->mproc;

  for(p = ptable; p < &ptable[nproc]; p++) 
80104393:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010439a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010439d:	c1 e0 02             	shl    $0x2,%eax
801043a0:	89 c2                	mov    %eax,%edx
801043a2:	c1 e2 05             	shl    $0x5,%edx
801043a5:	01 c2                	add    %eax,%edx
801043a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043aa:	01 d0                	add    %edx,%eax
801043ac:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801043af:	77 9d                	ja     8010434e <allocproc+0x25>
    if(p->state == UNUSED)
      goto found;  

  releasectable();
801043b1:	e8 e1 0a 00 00       	call   80104e97 <releasectable>
  return 0;
801043b6:	b8 00 00 00 00       	mov    $0x0,%eax
801043bb:	e9 8c 00 00 00       	jmp    8010444c <allocproc+0x123>

  releasectable();  

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801043c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801043ca:	b8 00 00 00 00       	mov    $0x0,%eax
801043cf:	eb 7b                	jmp    8010444c <allocproc+0x123>
  }
  sp = p->kstack + KSTACKSIZE;
801043d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d4:	8b 40 08             	mov    0x8(%eax),%eax
801043d7:	05 00 10 00 00       	add    $0x1000,%eax
801043dc:	89 45 e8             	mov    %eax,-0x18(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801043df:	83 6d e8 4c          	subl   $0x4c,-0x18(%ebp)
  p->tf = (struct trapframe*)sp;
801043e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e6:	8b 55 e8             	mov    -0x18(%ebp),%edx
801043e9:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801043ec:	83 6d e8 04          	subl   $0x4,-0x18(%ebp)
  *(uint*)sp = (uint)trapret;
801043f0:	ba 44 73 10 80       	mov    $0x80107344,%edx
801043f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801043f8:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801043fa:	83 6d e8 14          	subl   $0x14,-0x18(%ebp)
  p->context = (struct context*)sp;
801043fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104401:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104404:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010440d:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104414:	00 
80104415:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010441c:	00 
8010441d:	89 04 24             	mov    %eax,(%esp)
80104420:	e8 7d 17 00 00       	call   80105ba2 <memset>
  p->context->eip = (uint)forkret;
80104425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104428:	8b 40 1c             	mov    0x1c(%eax),%eax
8010442b:	ba 84 4b 10 80       	mov    $0x80104b84,%edx
80104430:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
80104433:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104436:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->cont = parentcont;
8010443d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104440:	8b 55 08             	mov    0x8(%ebp),%edx
80104443:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  return p;
80104449:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010444c:	c9                   	leave  
8010444d:	c3                   	ret    

8010444e <initprocess>:
// Set up first user process for a given container.
// If this is not the first root process, exec will
// set the sz and pgdir for the initialized process
struct proc*
initprocess(struct cont* parentcont, char* name, int isroot)
{
8010444e:	55                   	push   %ebp
8010444f:	89 e5                	mov    %esp,%ebp
80104451:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc(parentcont);
80104454:	8b 45 08             	mov    0x8(%ebp),%eax
80104457:	89 04 24             	mov    %eax,(%esp)
8010445a:	e8 ca fe ff ff       	call   80104329 <allocproc>
8010445f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if((p->pgdir = setupkvm()) == 0) {
80104462:	e8 37 44 00 00       	call   8010889e <setupkvm>
80104467:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010446a:	89 42 04             	mov    %eax,0x4(%edx)
8010446d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104470:	8b 40 04             	mov    0x4(%eax),%eax
80104473:	85 c0                	test   %eax,%eax
80104475:	75 1c                	jne    80104493 <initprocess+0x45>
    if (isroot)
80104477:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010447b:	74 0c                	je     80104489 <initprocess+0x3b>
      panic("userinit: out of memory?");
8010447d:	c7 04 24 10 96 10 80 	movl   $0x80109610,(%esp)
80104484:	e8 cb c0 ff ff       	call   80100554 <panic>
    else 
      return 0;
80104489:	b8 00 00 00 00       	mov    $0x0,%eax
8010448e:	e9 09 01 00 00       	jmp    8010459c <initprocess+0x14e>
  }
  
  if (isroot) {
80104493:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104497:	0f 84 aa 00 00 00    	je     80104547 <initprocess+0xf9>
    initproc = p;     
8010449d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a0:	a3 80 c7 10 80       	mov    %eax,0x8010c780

    inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);      
801044a5:	ba 2c 00 00 00       	mov    $0x2c,%edx
801044aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ad:	8b 40 04             	mov    0x4(%eax),%eax
801044b0:	89 54 24 08          	mov    %edx,0x8(%esp)
801044b4:	c7 44 24 04 00 c5 10 	movl   $0x8010c500,0x4(%esp)
801044bb:	80 
801044bc:	89 04 24             	mov    %eax,(%esp)
801044bf:	e8 3b 46 00 00       	call   80108aff <inituvm>
    memset(p->tf, 0, sizeof(*p->tf));
801044c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c7:	8b 40 18             	mov    0x18(%eax),%eax
801044ca:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801044d1:	00 
801044d2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801044d9:	00 
801044da:	89 04 24             	mov    %eax,(%esp)
801044dd:	e8 c0 16 00 00       	call   80105ba2 <memset>
    p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801044e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e5:	8b 40 18             	mov    0x18(%eax),%eax
801044e8:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
    p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801044ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f1:	8b 40 18             	mov    0x18(%eax),%eax
801044f4:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
    p->tf->es = p->tf->ds;
801044fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044fd:	8b 50 18             	mov    0x18(%eax),%edx
80104500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104503:	8b 40 18             	mov    0x18(%eax),%eax
80104506:	8b 40 2c             	mov    0x2c(%eax),%eax
80104509:	66 89 42 28          	mov    %ax,0x28(%edx)
    p->tf->ss = p->tf->ds;
8010450d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104510:	8b 50 18             	mov    0x18(%eax),%edx
80104513:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104516:	8b 40 18             	mov    0x18(%eax),%eax
80104519:	8b 40 2c             	mov    0x2c(%eax),%eax
8010451c:	66 89 42 48          	mov    %ax,0x48(%edx)
    p->tf->eflags = FL_IF;
80104520:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104523:	8b 40 18             	mov    0x18(%eax),%eax
80104526:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
    p->tf->esp = PGSIZE;
8010452d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104530:	8b 40 18             	mov    0x18(%eax),%eax
80104533:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
    p->tf->eip = 0;  // beginning of initcode.S
8010453a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453d:	8b 40 18             	mov    0x18(%eax),%eax
80104540:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  }

  p->sz = PGSIZE;
80104547:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454a:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)

  safestrcpy(p->name, name, sizeof(p->name));
80104550:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104553:	8d 50 6c             	lea    0x6c(%eax),%edx
80104556:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010455d:	00 
8010455e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104561:	89 44 24 04          	mov    %eax,0x4(%esp)
80104565:	89 14 24             	mov    %edx,(%esp)
80104568:	e8 41 18 00 00       	call   80105dae <safestrcpy>
  p->cwd = parentcont->rootdir;
8010456d:	8b 45 08             	mov    0x8(%ebp),%eax
80104570:	8b 50 10             	mov    0x10(%eax),%edx
80104573:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104576:	89 50 68             	mov    %edx,0x68(%eax)

  // Set initial process's cont to root
  p->cont = parentcont;
80104579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457c:	8b 55 08             	mov    0x8(%ebp),%edx
8010457f:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquirectable();
80104585:	e8 f9 08 00 00       	call   80104e83 <acquirectable>

  p->state = RUNNABLE;
8010458a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010458d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  releasectable();
80104594:	e8 fe 08 00 00       	call   80104e97 <releasectable>

  return p;
80104599:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010459c:	c9                   	leave  
8010459d:	c3                   	ret    

8010459e <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010459e:	55                   	push   %ebp
8010459f:	89 e5                	mov    %esp,%ebp
801045a1:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
801045a4:	e8 57 fd ff ff       	call   80104300 <myproc>
801045a9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
801045ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045af:	8b 00                	mov    (%eax),%eax
801045b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801045b4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045b8:	7e 31                	jle    801045eb <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801045ba:	8b 55 08             	mov    0x8(%ebp),%edx
801045bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045c0:	01 c2                	add    %eax,%edx
801045c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045c5:	8b 40 04             	mov    0x4(%eax),%eax
801045c8:	89 54 24 08          	mov    %edx,0x8(%esp)
801045cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045cf:	89 54 24 04          	mov    %edx,0x4(%esp)
801045d3:	89 04 24             	mov    %eax,(%esp)
801045d6:	e8 8f 46 00 00       	call   80108c6a <allocuvm>
801045db:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045e2:	75 3e                	jne    80104622 <growproc+0x84>
      return -1;
801045e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045e9:	eb 4f                	jmp    8010463a <growproc+0x9c>
  } else if(n < 0){
801045eb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801045ef:	79 31                	jns    80104622 <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801045f1:	8b 55 08             	mov    0x8(%ebp),%edx
801045f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f7:	01 c2                	add    %eax,%edx
801045f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045fc:	8b 40 04             	mov    0x4(%eax),%eax
801045ff:	89 54 24 08          	mov    %edx,0x8(%esp)
80104603:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104606:	89 54 24 04          	mov    %edx,0x4(%esp)
8010460a:	89 04 24             	mov    %eax,(%esp)
8010460d:	e8 6e 47 00 00       	call   80108d80 <deallocuvm>
80104612:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104615:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104619:	75 07                	jne    80104622 <growproc+0x84>
      return -1;
8010461b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104620:	eb 18                	jmp    8010463a <growproc+0x9c>
  }
  curproc->sz = sz;
80104622:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104625:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104628:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010462a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010462d:	89 04 24             	mov    %eax,(%esp)
80104630:	e8 43 43 00 00       	call   80108978 <switchuvm>
  return 0;
80104635:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010463a:	c9                   	leave  
8010463b:	c3                   	ret    

8010463c <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010463c:	55                   	push   %ebp
8010463d:	89 e5                	mov    %esp,%ebp
8010463f:	57                   	push   %edi
80104640:	56                   	push   %esi
80104641:	53                   	push   %ebx
80104642:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104645:	e8 b6 fc ff ff       	call   80104300 <myproc>
8010464a:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc(curproc->cont)) == 0){
8010464d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104650:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104656:	89 04 24             	mov    %eax,(%esp)
80104659:	e8 cb fc ff ff       	call   80104329 <allocproc>
8010465e:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104661:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104665:	75 0a                	jne    80104671 <fork+0x35>
    return -1;
80104667:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010466c:	e9 27 01 00 00       	jmp    80104798 <fork+0x15c>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80104671:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104674:	8b 10                	mov    (%eax),%edx
80104676:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104679:	8b 40 04             	mov    0x4(%eax),%eax
8010467c:	89 54 24 04          	mov    %edx,0x4(%esp)
80104680:	89 04 24             	mov    %eax,(%esp)
80104683:	e8 98 48 00 00       	call   80108f20 <copyuvm>
80104688:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010468b:	89 42 04             	mov    %eax,0x4(%edx)
8010468e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104691:	8b 40 04             	mov    0x4(%eax),%eax
80104694:	85 c0                	test   %eax,%eax
80104696:	75 2c                	jne    801046c4 <fork+0x88>
    kfree(np->kstack);
80104698:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010469b:	8b 40 08             	mov    0x8(%eax),%eax
8010469e:	89 04 24             	mov    %eax,(%esp)
801046a1:	e8 ff e6 ff ff       	call   80102da5 <kfree>
    np->kstack = 0;
801046a6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046a9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801046b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046b3:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801046ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046bf:	e9 d4 00 00 00       	jmp    80104798 <fork+0x15c>
  }
  np->sz = curproc->sz;
801046c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046c7:	8b 10                	mov    (%eax),%edx
801046c9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046cc:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801046ce:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046d1:	8b 55 e0             	mov    -0x20(%ebp),%edx
801046d4:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801046d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046da:	8b 50 18             	mov    0x18(%eax),%edx
801046dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046e0:	8b 40 18             	mov    0x18(%eax),%eax
801046e3:	89 c3                	mov    %eax,%ebx
801046e5:	b8 13 00 00 00       	mov    $0x13,%eax
801046ea:	89 d7                	mov    %edx,%edi
801046ec:	89 de                	mov    %ebx,%esi
801046ee:	89 c1                	mov    %eax,%ecx
801046f0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
801046f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046f5:	8b 40 18             	mov    0x18(%eax),%eax
801046f8:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
801046ff:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104706:	eb 36                	jmp    8010473e <fork+0x102>
    if(curproc->ofile[i])
80104708:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010470b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010470e:	83 c2 08             	add    $0x8,%edx
80104711:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104715:	85 c0                	test   %eax,%eax
80104717:	74 22                	je     8010473b <fork+0xff>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104719:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010471c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010471f:	83 c2 08             	add    $0x8,%edx
80104722:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104726:	89 04 24             	mov    %eax,(%esp)
80104729:	e8 0e ca ff ff       	call   8010113c <filedup>
8010472e:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104731:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104734:	83 c1 08             	add    $0x8,%ecx
80104737:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010473b:	ff 45 e4             	incl   -0x1c(%ebp)
8010473e:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104742:	7e c4                	jle    80104708 <fork+0xcc>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80104744:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104747:	8b 40 68             	mov    0x68(%eax),%eax
8010474a:	89 04 24             	mov    %eax,(%esp)
8010474d:	e8 1a d3 ff ff       	call   80101a6c <idup>
80104752:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104755:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80104758:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010475b:	8d 50 6c             	lea    0x6c(%eax),%edx
8010475e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104761:	83 c0 6c             	add    $0x6c,%eax
80104764:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010476b:	00 
8010476c:	89 54 24 04          	mov    %edx,0x4(%esp)
80104770:	89 04 24             	mov    %eax,(%esp)
80104773:	e8 36 16 00 00       	call   80105dae <safestrcpy>

  pid = np->pid;
80104778:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010477b:	8b 40 10             	mov    0x10(%eax),%eax
8010477e:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquirectable();
80104781:	e8 fd 06 00 00       	call   80104e83 <acquirectable>

  np->state = RUNNABLE;
80104786:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104789:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  releasectable();
80104790:	e8 02 07 00 00       	call   80104e97 <releasectable>

  return pid;
80104795:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104798:	83 c4 2c             	add    $0x2c,%esp
8010479b:	5b                   	pop    %ebx
8010479c:	5e                   	pop    %esi
8010479d:	5f                   	pop    %edi
8010479e:	5d                   	pop    %ebp
8010479f:	c3                   	ret    

801047a0 <cfork>:

// TODO: Delete
struct proc*
cfork(struct cont* parentcont)
{
801047a0:	55                   	push   %ebp
801047a1:	89 e5                	mov    %esp,%ebp
801047a3:	57                   	push   %edi
801047a4:	56                   	push   %esi
801047a5:	53                   	push   %ebx
801047a6:	83 ec 2c             	sub    $0x2c,%esp
  //int i;
  struct proc *np;
  struct proc *curproc = myproc();
801047a9:	e8 52 fb ff ff       	call   80104300 <myproc>
801047ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  // Allocate process.
  if((np = allocproc(parentcont)) == 0){
801047b1:	8b 45 08             	mov    0x8(%ebp),%eax
801047b4:	89 04 24             	mov    %eax,(%esp)
801047b7:	e8 6d fb ff ff       	call   80104329 <allocproc>
801047bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
801047bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801047c3:	75 0a                	jne    801047cf <cfork+0x2f>
    return 0;
801047c5:	b8 00 00 00 00       	mov    $0x0,%eax
801047ca:	e9 37 01 00 00       	jmp    80104906 <cfork+0x166>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801047cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801047d2:	8b 10                	mov    (%eax),%edx
801047d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801047d7:	8b 40 04             	mov    0x4(%eax),%eax
801047da:	89 54 24 04          	mov    %edx,0x4(%esp)
801047de:	89 04 24             	mov    %eax,(%esp)
801047e1:	e8 3a 47 00 00       	call   80108f20 <copyuvm>
801047e6:	8b 55 e0             	mov    -0x20(%ebp),%edx
801047e9:	89 42 04             	mov    %eax,0x4(%edx)
801047ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ef:	8b 40 04             	mov    0x4(%eax),%eax
801047f2:	85 c0                	test   %eax,%eax
801047f4:	75 2c                	jne    80104822 <cfork+0x82>
    kfree(np->kstack);
801047f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047f9:	8b 40 08             	mov    0x8(%eax),%eax
801047fc:	89 04 24             	mov    %eax,(%esp)
801047ff:	e8 a1 e5 ff ff       	call   80102da5 <kfree>
    np->kstack = 0;
80104804:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104807:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010480e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104811:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104818:	b8 00 00 00 00       	mov    $0x0,%eax
8010481d:	e9 e4 00 00 00       	jmp    80104906 <cfork+0x166>
  }
  np->sz = curproc->sz;
80104822:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104825:	8b 10                	mov    (%eax),%edx
80104827:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010482a:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010482c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010482f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104832:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104835:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104838:	8b 50 18             	mov    0x18(%eax),%edx
8010483b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010483e:	8b 40 18             	mov    0x18(%eax),%eax
80104841:	89 c3                	mov    %eax,%ebx
80104843:	b8 13 00 00 00       	mov    $0x13,%eax
80104848:	89 d7                	mov    %edx,%edi
8010484a:	89 de                	mov    %ebx,%esi
8010484c:	89 c1                	mov    %eax,%ecx
8010484e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104850:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104853:	8b 40 18             	mov    0x18(%eax),%eax
80104856:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  // If parent cont is the same as curproc
      // for(i = 0; i < NOFILE; i++)
      //   if(curproc->ofile[i])
      //     np->ofile[i] = filedup(curproc->ofile[i]);
      // np->cwd = idup(curproc->cwd);
  np->cwd = parentcont->rootdir;
8010485d:	8b 45 08             	mov    0x8(%ebp),%eax
80104860:	8b 50 10             	mov    0x10(%eax),%edx
80104863:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104866:	89 50 68             	mov    %edx,0x68(%eax)
  cprintf("cfork new proc container %s\n", (np->cont->name));
80104869:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010486c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104872:	83 c0 18             	add    $0x18,%eax
80104875:	89 44 24 04          	mov    %eax,0x4(%esp)
80104879:	c7 04 24 29 96 10 80 	movl   $0x80109629,(%esp)
80104880:	e8 3c bb ff ff       	call   801003c1 <cprintf>
  cprintf("cfork new proc container rootdir is a folder %d\n", (np->cont->rootdir->type == 1));
80104885:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104888:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010488e:	8b 40 10             	mov    0x10(%eax),%eax
80104891:	8b 40 50             	mov    0x50(%eax),%eax
80104894:	66 83 f8 01          	cmp    $0x1,%ax
80104898:	0f 94 c0             	sete   %al
8010489b:	0f b6 c0             	movzbl %al,%eax
8010489e:	89 44 24 04          	mov    %eax,0x4(%esp)
801048a2:	c7 04 24 48 96 10 80 	movl   $0x80109648,(%esp)
801048a9:	e8 13 bb ff ff       	call   801003c1 <cprintf>
  cprintf("cfork new proc cwd is a folder: %d\n", (np->cwd->type == 1));
801048ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048b1:	8b 40 68             	mov    0x68(%eax),%eax
801048b4:	8b 40 50             	mov    0x50(%eax),%eax
801048b7:	66 83 f8 01          	cmp    $0x1,%ax
801048bb:	0f 94 c0             	sete   %al
801048be:	0f b6 c0             	movzbl %al,%eax
801048c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801048c5:	c7 04 24 7c 96 10 80 	movl   $0x8010967c,(%esp)
801048cc:	e8 f0 ba ff ff       	call   801003c1 <cprintf>

  //safestrcpy(np->name, curproc->name, sizeof(curproc->name));
  safestrcpy(np->name, "testproc", sizeof("testproc"));
801048d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048d4:	83 c0 6c             	add    $0x6c,%eax
801048d7:	c7 44 24 08 09 00 00 	movl   $0x9,0x8(%esp)
801048de:	00 
801048df:	c7 44 24 04 a0 96 10 	movl   $0x801096a0,0x4(%esp)
801048e6:	80 
801048e7:	89 04 24             	mov    %eax,(%esp)
801048ea:	e8 bf 14 00 00       	call   80105dae <safestrcpy>

  acquirectable();
801048ef:	e8 8f 05 00 00       	call   80104e83 <acquirectable>

  np->state = RUNNABLE;
801048f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048f7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  releasectable();
801048fe:	e8 94 05 00 00       	call   80104e97 <releasectable>

  return np;
80104903:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80104906:	83 c4 2c             	add    $0x2c,%esp
80104909:	5b                   	pop    %ebx
8010490a:	5e                   	pop    %esi
8010490b:	5f                   	pop    %edi
8010490c:	5d                   	pop    %ebp
8010490d:	c3                   	ret    

8010490e <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010490e:	55                   	push   %ebp
8010490f:	89 e5                	mov    %esp,%ebp
80104911:	83 ec 38             	sub    $0x38,%esp
  struct proc *curproc = myproc();
80104914:	e8 e7 f9 ff ff       	call   80104300 <myproc>
80104919:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  struct proc *ptable;
  int fd, nproc;

  if(curproc == initproc)
8010491c:	a1 80 c7 10 80       	mov    0x8010c780,%eax
80104921:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104924:	75 0c                	jne    80104932 <exit+0x24>
    panic("init exiting");
80104926:	c7 04 24 a9 96 10 80 	movl   $0x801096a9,(%esp)
8010492d:	e8 22 bc ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104932:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104939:	eb 3a                	jmp    80104975 <exit+0x67>
    if(curproc->ofile[fd]){
8010493b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010493e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104941:	83 c2 08             	add    $0x8,%edx
80104944:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104948:	85 c0                	test   %eax,%eax
8010494a:	74 26                	je     80104972 <exit+0x64>
      fileclose(curproc->ofile[fd]);
8010494c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010494f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104952:	83 c2 08             	add    $0x8,%edx
80104955:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104959:	89 04 24             	mov    %eax,(%esp)
8010495c:	e8 23 c8 ff ff       	call   80101184 <fileclose>
      curproc->ofile[fd] = 0;
80104961:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104964:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104967:	83 c2 08             	add    $0x8,%edx
8010496a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104971:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104972:	ff 45 f0             	incl   -0x10(%ebp)
80104975:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104979:	7e c0                	jle    8010493b <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
8010497b:	e8 83 ed ff ff       	call   80103703 <begin_op>
  iput(curproc->cwd);
80104980:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104983:	8b 40 68             	mov    0x68(%eax),%eax
80104986:	89 04 24             	mov    %eax,(%esp)
80104989:	e8 5e d2 ff ff       	call   80101bec <iput>
  end_op();
8010498e:	e8 f2 ed ff ff       	call   80103785 <end_op>
  curproc->cwd = 0;
80104993:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104996:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquirectable();
8010499d:	e8 e1 04 00 00       	call   80104e83 <acquirectable>

  ptable = curproc->cont->ptable;
801049a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049a5:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801049ab:	8b 40 28             	mov    0x28(%eax),%eax
801049ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
  nproc = curproc->cont->mproc;
801049b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049b4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801049ba:	8b 40 08             	mov    0x8(%eax),%eax
801049bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801049c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049c3:	8b 40 14             	mov    0x14(%eax),%eax
801049c6:	89 04 24             	mov    %eax,(%esp)
801049c9:	e8 90 02 00 00       	call   80104c5e <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable; p < &ptable[nproc]; p++){
801049ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
801049d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801049d4:	eb 36                	jmp    80104a0c <exit+0xfe>
    if(p->parent == curproc){
801049d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d9:	8b 40 14             	mov    0x14(%eax),%eax
801049dc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801049df:	75 24                	jne    80104a05 <exit+0xf7>
      p->parent = initproc;
801049e1:	8b 15 80 c7 10 80    	mov    0x8010c780,%edx
801049e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ea:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801049ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f0:	8b 40 0c             	mov    0xc(%eax),%eax
801049f3:	83 f8 05             	cmp    $0x5,%eax
801049f6:	75 0d                	jne    80104a05 <exit+0xf7>
        wakeup1(initproc);
801049f8:	a1 80 c7 10 80       	mov    0x8010c780,%eax
801049fd:	89 04 24             	mov    %eax,(%esp)
80104a00:	e8 59 02 00 00       	call   80104c5e <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable; p < &ptable[nproc]; p++){
80104a05:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104a0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104a0f:	c1 e0 02             	shl    $0x2,%eax
80104a12:	89 c2                	mov    %eax,%edx
80104a14:	c1 e2 05             	shl    $0x5,%edx
80104a17:	01 c2                	add    %eax,%edx
80104a19:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104a1c:	01 d0                	add    %edx,%eax
80104a1e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104a21:	77 b3                	ja     801049d6 <exit+0xc8>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104a23:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a26:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104a2d:	e8 31 06 00 00       	call   80105063 <sched>
  panic("zombie exit");
80104a32:	c7 04 24 b6 96 10 80 	movl   $0x801096b6,(%esp)
80104a39:	e8 16 bb ff ff       	call   80100554 <panic>

80104a3e <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a3e:	55                   	push   %ebp
80104a3f:	89 e5                	mov    %esp,%ebp
80104a41:	83 ec 38             	sub    $0x38,%esp
  struct proc *p;
  struct proc *ptable;
  int havekids, pid, nproc;
  struct proc *curproc = myproc();
80104a44:	e8 b7 f8 ff ff       	call   80104300 <myproc>
80104a49:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquirectable();
80104a4c:	e8 32 04 00 00       	call   80104e83 <acquirectable>

  ptable = curproc->cont->ptable;
80104a51:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a54:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104a5a:	8b 40 28             	mov    0x28(%eax),%eax
80104a5d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  nproc = curproc->cont->mproc;
80104a60:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a63:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104a69:	8b 40 08             	mov    0x8(%eax),%eax
80104a6c:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104a6f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable; p < &ptable[nproc]; p++){
80104a76:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104a79:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104a7c:	e9 8e 00 00 00       	jmp    80104b0f <wait+0xd1>
      if(p->parent != curproc)
80104a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a84:	8b 40 14             	mov    0x14(%eax),%eax
80104a87:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104a8a:	74 02                	je     80104a8e <wait+0x50>
        continue;
80104a8c:	eb 7a                	jmp    80104b08 <wait+0xca>
      havekids = 1;
80104a8e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a98:	8b 40 0c             	mov    0xc(%eax),%eax
80104a9b:	83 f8 05             	cmp    $0x5,%eax
80104a9e:	75 68                	jne    80104b08 <wait+0xca>
        // Found one.
        pid = p->pid;
80104aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa3:	8b 40 10             	mov    0x10(%eax),%eax
80104aa6:	89 45 e0             	mov    %eax,-0x20(%ebp)
        kfree(p->kstack);
80104aa9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aac:	8b 40 08             	mov    0x8(%eax),%eax
80104aaf:	89 04 24             	mov    %eax,(%esp)
80104ab2:	e8 ee e2 ff ff       	call   80102da5 <kfree>
        p->kstack = 0;
80104ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aba:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac4:	8b 40 04             	mov    0x4(%eax),%eax
80104ac7:	89 04 24             	mov    %eax,(%esp)
80104aca:	e8 75 43 00 00       	call   80108e44 <freevm>
        p->pid = 0;
80104acf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad2:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104adc:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae6:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aed:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        releasectable();
80104afe:	e8 94 03 00 00       	call   80104e97 <releasectable>
        return pid;
80104b03:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104b06:	eb 57                	jmp    80104b5f <wait+0x121>
  nproc = curproc->cont->mproc;

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable; p < &ptable[nproc]; p++){
80104b08:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104b0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104b12:	c1 e0 02             	shl    $0x2,%eax
80104b15:	89 c2                	mov    %eax,%edx
80104b17:	c1 e2 05             	shl    $0x5,%edx
80104b1a:	01 c2                	add    %eax,%edx
80104b1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b1f:	01 d0                	add    %edx,%eax
80104b21:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104b24:	0f 87 57 ff ff ff    	ja     80104a81 <wait+0x43>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104b2a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b2e:	74 0a                	je     80104b3a <wait+0xfc>
80104b30:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b33:	8b 40 24             	mov    0x24(%eax),%eax
80104b36:	85 c0                	test   %eax,%eax
80104b38:	74 0c                	je     80104b46 <wait+0x108>
      releasectable();
80104b3a:	e8 58 03 00 00       	call   80104e97 <releasectable>
      return -1;
80104b3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b44:	eb 19                	jmp    80104b5f <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, ctablelock());  //DOC: wait-sleep
80104b46:	e8 60 03 00 00       	call   80104eab <ctablelock>
80104b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b52:	89 04 24             	mov    %eax,(%esp)
80104b55:	e8 7a 00 00 00       	call   80104bd4 <sleep>
  }
80104b5a:	e9 10 ff ff ff       	jmp    80104a6f <wait+0x31>
}
80104b5f:	c9                   	leave  
80104b60:	c3                   	ret    

80104b61 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104b61:	55                   	push   %ebp
80104b62:	89 e5                	mov    %esp,%ebp
80104b64:	83 ec 08             	sub    $0x8,%esp
  acquirectable();  //DOC: yieldlock
80104b67:	e8 17 03 00 00       	call   80104e83 <acquirectable>
  myproc()->state = RUNNABLE;
80104b6c:	e8 8f f7 ff ff       	call   80104300 <myproc>
80104b71:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104b78:	e8 e6 04 00 00       	call   80105063 <sched>
  releasectable();
80104b7d:	e8 15 03 00 00       	call   80104e97 <releasectable>
}
80104b82:	c9                   	leave  
80104b83:	c3                   	ret    

80104b84 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104b84:	55                   	push   %ebp
80104b85:	89 e5                	mov    %esp,%ebp
80104b87:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ctablelock from scheduler.
  releasectable();
80104b8a:	e8 08 03 00 00       	call   80104e97 <releasectable>

  cprintf("my proc %s\n", myproc()->name);
80104b8f:	e8 6c f7 ff ff       	call   80104300 <myproc>
80104b94:	83 c0 6c             	add    $0x6c,%eax
80104b97:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b9b:	c7 04 24 c2 96 10 80 	movl   $0x801096c2,(%esp)
80104ba2:	e8 1a b8 ff ff       	call   801003c1 <cprintf>
  //   } else {
  //     cprintf("exec proc should have worked\n");
  //   }
  // }

  if (first) {    
80104ba7:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104bac:	85 c0                	test   %eax,%eax
80104bae:	74 22                	je     80104bd2 <forkret+0x4e>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104bb0:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104bb7:	00 00 00 
    iinit(ROOTDEV);
80104bba:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104bc1:	e8 71 cb ff ff       	call   80101737 <iinit>
    initlog(ROOTDEV);
80104bc6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104bcd:	e8 32 e9 ff ff       	call   80103504 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104bd2:	c9                   	leave  
80104bd3:	c3                   	ret    

80104bd4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104bd4:	55                   	push   %ebp
80104bd5:	89 e5                	mov    %esp,%ebp
80104bd7:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104bda:	e8 21 f7 ff ff       	call   80104300 <myproc>
80104bdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104be2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104be6:	75 0c                	jne    80104bf4 <sleep+0x20>
    panic("sleep");
80104be8:	c7 04 24 ce 96 10 80 	movl   $0x801096ce,(%esp)
80104bef:	e8 60 b9 ff ff       	call   80100554 <panic>

  if(lk == 0)
80104bf4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104bf8:	75 0c                	jne    80104c06 <sleep+0x32>
    panic("sleep without lk");  
80104bfa:	c7 04 24 d4 96 10 80 	movl   $0x801096d4,(%esp)
80104c01:	e8 4e b9 ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ctable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ctable.lock locked),
  // so it's okay to release lk.
  if(lk != ctablelock()){  //DOC: sleeplock0
80104c06:	e8 a0 02 00 00       	call   80104eab <ctablelock>
80104c0b:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104c0e:	74 10                	je     80104c20 <sleep+0x4c>
    acquirectable();  //DOC: sleeplock1
80104c10:	e8 6e 02 00 00       	call   80104e83 <acquirectable>
    release(lk);
80104c15:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c18:	89 04 24             	mov    %eax,(%esp)
80104c1b:	e8 89 0d 00 00       	call   801059a9 <release>
  }
  // Go to sleep.
  p->chan = chan;
80104c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c23:	8b 55 08             	mov    0x8(%ebp),%edx
80104c26:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c2c:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104c33:	e8 2b 04 00 00       	call   80105063 <sched>

  // Tidy up.
  p->chan = 0;
80104c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c3b:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != ctablelock()){  //DOC: sleeplock2
80104c42:	e8 64 02 00 00       	call   80104eab <ctablelock>
80104c47:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104c4a:	74 10                	je     80104c5c <sleep+0x88>
    releasectable();
80104c4c:	e8 46 02 00 00       	call   80104e97 <releasectable>
    acquire(lk);
80104c51:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c54:	89 04 24             	mov    %eax,(%esp)
80104c57:	e8 e3 0c 00 00       	call   8010593f <acquire>
  }
}
80104c5c:	c9                   	leave  
80104c5d:	c3                   	ret    

80104c5e <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ctable lock must be held.
static void
wakeup1(void *chan)
{
80104c5e:	55                   	push   %ebp
80104c5f:	89 e5                	mov    %esp,%ebp
80104c61:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct proc *ptable;
  int nproc;

  // TODO: maybe remove mycont() function then change this to work
  nproc = mycont()->mproc;
80104c64:	e8 7b 03 00 00       	call   80104fe4 <mycont>
80104c69:	8b 40 08             	mov    0x8(%eax),%eax
80104c6c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ptable = mycont()->ptable;
80104c6f:	e8 70 03 00 00       	call   80104fe4 <mycont>
80104c74:	8b 40 28             	mov    0x28(%eax),%eax
80104c77:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for(p = ptable; p < &ptable[nproc]; p++)
80104c7a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c7d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c80:	eb 27                	jmp    80104ca9 <wakeup1+0x4b>
    if(p->state == SLEEPING && p->chan == chan) {
80104c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c85:	8b 40 0c             	mov    0xc(%eax),%eax
80104c88:	83 f8 02             	cmp    $0x2,%eax
80104c8b:	75 15                	jne    80104ca2 <wakeup1+0x44>
80104c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c90:	8b 40 20             	mov    0x20(%eax),%eax
80104c93:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c96:	75 0a                	jne    80104ca2 <wakeup1+0x44>
      p->state = RUNNABLE;
80104c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c9b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  // TODO: maybe remove mycont() function then change this to work
  nproc = mycont()->mproc;
  ptable = mycont()->ptable;

  for(p = ptable; p < &ptable[nproc]; p++)
80104ca2:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104ca9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cac:	c1 e0 02             	shl    $0x2,%eax
80104caf:	89 c2                	mov    %eax,%edx
80104cb1:	c1 e2 05             	shl    $0x5,%edx
80104cb4:	01 c2                	add    %eax,%edx
80104cb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cb9:	01 d0                	add    %edx,%eax
80104cbb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104cbe:	77 c2                	ja     80104c82 <wakeup1+0x24>
    if(p->state == SLEEPING && p->chan == chan) {
      p->state = RUNNABLE;
    }
}
80104cc0:	c9                   	leave  
80104cc1:	c3                   	ret    

80104cc2 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104cc2:	55                   	push   %ebp
80104cc3:	89 e5                	mov    %esp,%ebp
80104cc5:	83 ec 18             	sub    $0x18,%esp
  acquirectable();
80104cc8:	e8 b6 01 00 00       	call   80104e83 <acquirectable>
  wakeup1(chan);
80104ccd:	8b 45 08             	mov    0x8(%ebp),%eax
80104cd0:	89 04 24             	mov    %eax,(%esp)
80104cd3:	e8 86 ff ff ff       	call   80104c5e <wakeup1>
  releasectable();
80104cd8:	e8 ba 01 00 00       	call   80104e97 <releasectable>
}
80104cdd:	c9                   	leave  
80104cde:	c3                   	ret    

80104cdf <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104cdf:	55                   	push   %ebp
80104ce0:	89 e5                	mov    %esp,%ebp
80104ce2:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct proc *ptable;
  int nproc;

  acquirectable();
80104ce5:	e8 99 01 00 00       	call   80104e83 <acquirectable>

  ptable = myproc()->cont->ptable;
80104cea:	e8 11 f6 ff ff       	call   80104300 <myproc>
80104cef:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104cf5:	8b 40 28             	mov    0x28(%eax),%eax
80104cf8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  nproc = myproc()->cont->mproc;
80104cfb:	e8 00 f6 ff ff       	call   80104300 <myproc>
80104d00:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104d06:	8b 40 08             	mov    0x8(%eax),%eax
80104d09:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for(p = ptable; p < &ptable[nproc]; p++){
80104d0c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104d12:	eb 3d                	jmp    80104d51 <kill+0x72>
    if(p->pid == pid){
80104d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d17:	8b 40 10             	mov    0x10(%eax),%eax
80104d1a:	3b 45 08             	cmp    0x8(%ebp),%eax
80104d1d:	75 2b                	jne    80104d4a <kill+0x6b>
      p->killed = 1;
80104d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d22:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104d29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2c:	8b 40 0c             	mov    0xc(%eax),%eax
80104d2f:	83 f8 02             	cmp    $0x2,%eax
80104d32:	75 0a                	jne    80104d3e <kill+0x5f>
        p->state = RUNNABLE;
80104d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d37:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      releasectable();
80104d3e:	e8 54 01 00 00       	call   80104e97 <releasectable>
      return 0;
80104d43:	b8 00 00 00 00       	mov    $0x0,%eax
80104d48:	eb 28                	jmp    80104d72 <kill+0x93>
  acquirectable();

  ptable = myproc()->cont->ptable;
  nproc = myproc()->cont->mproc;

  for(p = ptable; p < &ptable[nproc]; p++){
80104d4a:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104d51:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d54:	c1 e0 02             	shl    $0x2,%eax
80104d57:	89 c2                	mov    %eax,%edx
80104d59:	c1 e2 05             	shl    $0x5,%edx
80104d5c:	01 c2                	add    %eax,%edx
80104d5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d61:	01 d0                	add    %edx,%eax
80104d63:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104d66:	77 ac                	ja     80104d14 <kill+0x35>
        p->state = RUNNABLE;
      releasectable();
      return 0;
    }
  }
  releasectable();
80104d68:	e8 2a 01 00 00       	call   80104e97 <releasectable>
  return -1;
80104d6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d72:	c9                   	leave  
80104d73:	c3                   	ret    

80104d74 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104d74:	55                   	push   %ebp
80104d75:	89 e5                	mov    %esp,%ebp
80104d77:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104d7a:	9c                   	pushf  
80104d7b:	58                   	pop    %eax
80104d7c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104d7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d82:	c9                   	leave  
80104d83:	c3                   	ret    

80104d84 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104d84:	55                   	push   %ebp
80104d85:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104d87:	fb                   	sti    
}
80104d88:	5d                   	pop    %ebp
80104d89:	c3                   	ret    

80104d8a <cpuid>:

// TODO: Check to make sure ALL ctable calls have a lock

// Must be called with interrupts disabled
int
cpuid() {
80104d8a:	55                   	push   %ebp
80104d8b:	89 e5                	mov    %esp,%ebp
80104d8d:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104d90:	e8 3a 00 00 00       	call   80104dcf <mycpu>
80104d95:	89 c2                	mov    %eax,%edx
80104d97:	b8 60 49 11 80       	mov    $0x80114960,%eax
80104d9c:	29 c2                	sub    %eax,%edx
80104d9e:	89 d0                	mov    %edx,%eax
80104da0:	c1 f8 04             	sar    $0x4,%eax
80104da3:	89 c1                	mov    %eax,%ecx
80104da5:	89 ca                	mov    %ecx,%edx
80104da7:	c1 e2 03             	shl    $0x3,%edx
80104daa:	01 ca                	add    %ecx,%edx
80104dac:	89 d0                	mov    %edx,%eax
80104dae:	c1 e0 05             	shl    $0x5,%eax
80104db1:	29 d0                	sub    %edx,%eax
80104db3:	c1 e0 02             	shl    $0x2,%eax
80104db6:	01 c8                	add    %ecx,%eax
80104db8:	c1 e0 03             	shl    $0x3,%eax
80104dbb:	01 c8                	add    %ecx,%eax
80104dbd:	89 c2                	mov    %eax,%edx
80104dbf:	c1 e2 0f             	shl    $0xf,%edx
80104dc2:	29 c2                	sub    %eax,%edx
80104dc4:	c1 e2 02             	shl    $0x2,%edx
80104dc7:	01 ca                	add    %ecx,%edx
80104dc9:	89 d0                	mov    %edx,%eax
80104dcb:	f7 d8                	neg    %eax
}
80104dcd:	c9                   	leave  
80104dce:	c3                   	ret    

80104dcf <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104dcf:	55                   	push   %ebp
80104dd0:	89 e5                	mov    %esp,%ebp
80104dd2:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104dd5:	e8 9a ff ff ff       	call   80104d74 <readeflags>
80104dda:	25 00 02 00 00       	and    $0x200,%eax
80104ddf:	85 c0                	test   %eax,%eax
80104de1:	74 0c                	je     80104def <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
80104de3:	c7 04 24 e8 96 10 80 	movl   $0x801096e8,(%esp)
80104dea:	e8 65 b7 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
80104def:	e8 c5 e3 ff ff       	call   801031b9 <lapicid>
80104df4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104df7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104dfe:	eb 3b                	jmp    80104e3b <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
80104e00:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e03:	89 d0                	mov    %edx,%eax
80104e05:	c1 e0 02             	shl    $0x2,%eax
80104e08:	01 d0                	add    %edx,%eax
80104e0a:	01 c0                	add    %eax,%eax
80104e0c:	01 d0                	add    %edx,%eax
80104e0e:	c1 e0 04             	shl    $0x4,%eax
80104e11:	05 60 49 11 80       	add    $0x80114960,%eax
80104e16:	8a 00                	mov    (%eax),%al
80104e18:	0f b6 c0             	movzbl %al,%eax
80104e1b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104e1e:	75 18                	jne    80104e38 <mycpu+0x69>
      return &cpus[i];
80104e20:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e23:	89 d0                	mov    %edx,%eax
80104e25:	c1 e0 02             	shl    $0x2,%eax
80104e28:	01 d0                	add    %edx,%eax
80104e2a:	01 c0                	add    %eax,%eax
80104e2c:	01 d0                	add    %edx,%eax
80104e2e:	c1 e0 04             	shl    $0x4,%eax
80104e31:	05 60 49 11 80       	add    $0x80114960,%eax
80104e36:	eb 19                	jmp    80104e51 <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104e38:	ff 45 f4             	incl   -0xc(%ebp)
80104e3b:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80104e40:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104e43:	7c bb                	jl     80104e00 <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104e45:	c7 04 24 0e 97 10 80 	movl   $0x8010970e,(%esp)
80104e4c:	e8 03 b7 ff ff       	call   80100554 <panic>
}
80104e51:	c9                   	leave  
80104e52:	c3                   	ret    

80104e53 <cinit>:

int nextcid = 1;

void
cinit(void)
{
80104e53:	55                   	push   %ebp
80104e54:	89 e5                	mov    %esp,%ebp
80104e56:	83 ec 18             	sub    $0x18,%esp
  initlock(&ctable.lock, "ctable");
80104e59:	c7 44 24 04 1e 97 10 	movl   $0x8010971e,0x4(%esp)
80104e60:	80 
80104e61:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104e68:	e8 b1 0a 00 00       	call   8010591e <initlock>
  initlock(&ptable.lock, "ptable");
80104e6d:	c7 44 24 04 25 97 10 	movl   $0x80109725,0x4(%esp)
80104e74:	80 
80104e75:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
80104e7c:	e8 9d 0a 00 00       	call   8010591e <initlock>
}
80104e81:	c9                   	leave  
80104e82:	c3                   	ret    

80104e83 <acquirectable>:

void
acquirectable(void) 
{
80104e83:	55                   	push   %ebp
80104e84:	89 e5                	mov    %esp,%ebp
80104e86:	83 ec 18             	sub    $0x18,%esp
	acquire(&ptable.lock);
80104e89:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
80104e90:	e8 aa 0a 00 00       	call   8010593f <acquire>
}
80104e95:	c9                   	leave  
80104e96:	c3                   	ret    

80104e97 <releasectable>:
// TODO: refactor name of ctablelock to ptable
// TODO: replace these aqcuires and releases with normal aqcuire and release using ctablelock()
void 
releasectable(void)
{
80104e97:	55                   	push   %ebp
80104e98:	89 e5                	mov    %esp,%ebp
80104e9a:	83 ec 18             	sub    $0x18,%esp
	release(&ptable.lock);
80104e9d:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
80104ea4:	e8 00 0b 00 00       	call   801059a9 <release>
	//cprintf("\t\t Released ctable\n");
}
80104ea9:	c9                   	leave  
80104eaa:	c3                   	ret    

80104eab <ctablelock>:

struct spinlock*
ctablelock(void)
{
80104eab:	55                   	push   %ebp
80104eac:	89 e5                	mov    %esp,%ebp
	return &ptable.lock;
80104eae:	b8 c0 50 11 80       	mov    $0x801150c0,%eax
}
80104eb3:	5d                   	pop    %ebp
80104eb4:	c3                   	ret    

80104eb5 <initcontainer>:

struct cont*
initcontainer(void)
{
80104eb5:	55                   	push   %ebp
80104eb6:	89 e5                	mov    %esp,%ebp
80104eb8:	83 ec 38             	sub    $0x38,%esp
	int i,
		mproc = MAX_CONT_PROC,
80104ebb:	c7 45 f0 40 00 00 00 	movl   $0x40,-0x10(%ebp)
		msz   = MAX_CONT_MEM,
80104ec2:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
		mdsk  = MAX_CONT_DSK;
80104ec9:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
	struct cont *c;

	if ((c = alloccont()) == 0) {
80104ed0:	e8 19 01 00 00       	call   80104fee <alloccont>
80104ed5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80104ed8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80104edc:	75 0c                	jne    80104eea <initcontainer+0x35>
		panic("Can't alloc init container.");
80104ede:	c7 04 24 2c 97 10 80 	movl   $0x8010972c,(%esp)
80104ee5:	e8 6a b6 ff ff       	call   80100554 <panic>
	}

	currcont = c;	
80104eea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104eed:	a3 b4 50 11 80       	mov    %eax,0x801150b4

	acquire(&ctable.lock);
80104ef2:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104ef9:	e8 41 0a 00 00       	call   8010593f <acquire>
	c->mproc = mproc;
80104efe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104f01:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f04:	89 50 08             	mov    %edx,0x8(%eax)
	c->msz = msz;
80104f07:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104f0d:	89 10                	mov    %edx,(%eax)
	c->mdsk = mdsk;	
80104f0f:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104f12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104f15:	89 50 04             	mov    %edx,0x4(%eax)
	c->state = CRUNNABLE;	
80104f18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104f1b:	c7 40 14 03 00 00 00 	movl   $0x3,0x14(%eax)
	c->rootdir = namei("/");
80104f22:	c7 04 24 48 97 10 80 	movl   $0x80109748,(%esp)
80104f29:	e8 ff d7 ff ff       	call   8010272d <namei>
80104f2e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104f31:	89 42 10             	mov    %eax,0x10(%edx)
	safestrcpy(c->name, "initcont", sizeof(c->name));	
80104f34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104f37:	83 c0 18             	add    $0x18,%eax
80104f3a:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104f41:	00 
80104f42:	c7 44 24 04 4a 97 10 	movl   $0x8010974a,0x4(%esp)
80104f49:	80 
80104f4a:	89 04 24             	mov    %eax,(%esp)
80104f4d:	e8 5c 0e 00 00       	call   80105dae <safestrcpy>

	// Init pointers to each container's process tables
	for (i = 0; i < NCONT; i++)
80104f52:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f59:	eb 2f                	jmp    80104f8a <initcontainer+0xd5>
		ctable.cont[i].ptable = ptable.proc[i];
80104f5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f5e:	c1 e0 08             	shl    $0x8,%eax
80104f61:	89 c2                	mov    %eax,%edx
80104f63:	c1 e2 05             	shl    $0x5,%edx
80104f66:	01 d0                	add    %edx,%eax
80104f68:	83 c0 30             	add    $0x30,%eax
80104f6b:	05 c0 50 11 80       	add    $0x801150c0,%eax
80104f70:	8d 48 04             	lea    0x4(%eax),%ecx
80104f73:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f76:	89 d0                	mov    %edx,%eax
80104f78:	01 c0                	add    %eax,%eax
80104f7a:	01 d0                	add    %edx,%eax
80104f7c:	c1 e0 04             	shl    $0x4,%eax
80104f7f:	05 50 4f 11 80       	add    $0x80114f50,%eax
80104f84:	89 48 0c             	mov    %ecx,0xc(%eax)
	c->state = CRUNNABLE;	
	c->rootdir = namei("/");
	safestrcpy(c->name, "initcont", sizeof(c->name));	

	// Init pointers to each container's process tables
	for (i = 0; i < NCONT; i++)
80104f87:	ff 45 f4             	incl   -0xc(%ebp)
80104f8a:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80104f8e:	7e cb                	jle    80104f5b <initcontainer+0xa6>
		ctable.cont[i].ptable = ptable.proc[i];

	release(&ctable.lock);	
80104f90:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104f97:	e8 0d 0a 00 00       	call   801059a9 <release>

	cprintf("Init container\n");
80104f9c:	c7 04 24 53 97 10 80 	movl   $0x80109753,(%esp)
80104fa3:	e8 19 b4 ff ff       	call   801003c1 <cprintf>

	return c;
80104fa8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80104fab:	c9                   	leave  
80104fac:	c3                   	ret    

80104fad <userinit>:

// Set up first user container and process.
void
userinit(void)
{
80104fad:	55                   	push   %ebp
80104fae:	89 e5                	mov    %esp,%ebp
80104fb0:	83 ec 28             	sub    $0x28,%esp
	cprintf("userinit\n");
80104fb3:	c7 04 24 63 97 10 80 	movl   $0x80109763,(%esp)
80104fba:	e8 02 b4 ff ff       	call   801003c1 <cprintf>
	struct cont* root;
  	root = initcontainer();
80104fbf:	e8 f1 fe ff ff       	call   80104eb5 <initcontainer>
80104fc4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  	initprocess(root, "initproc", 1);    	
80104fc7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80104fce:	00 
80104fcf:	c7 44 24 04 6d 97 10 	movl   $0x8010976d,0x4(%esp)
80104fd6:	80 
80104fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fda:	89 04 24             	mov    %eax,(%esp)
80104fdd:	e8 6c f4 ff ff       	call   8010444e <initprocess>
}
80104fe2:	c9                   	leave  
80104fe3:	c3                   	ret    

80104fe4 <mycont>:

//TODO: REMOVE!!
struct cont*
mycont(void) {
80104fe4:	55                   	push   %ebp
80104fe5:	89 e5                	mov    %esp,%ebp
	return currcont;
80104fe7:	a1 b4 50 11 80       	mov    0x801150b4,%eax
}
80104fec:	5d                   	pop    %ebp
80104fed:	c3                   	ret    

80104fee <alloccont>:
// Look in the container table for an CUNUSED cont.
// If found, change state to CEMBRYO
// Otherwise return 0.
static struct cont*
alloccont(void)
{
80104fee:	55                   	push   %ebp
80104fef:	89 e5                	mov    %esp,%ebp
80104ff1:	83 ec 28             	sub    $0x28,%esp
	struct cont *c;

	acquire(&ctable.lock);
80104ff4:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104ffb:	e8 3f 09 00 00       	call   8010593f <acquire>

	for(c = ctable.cont; c < &ctable.cont[NCONT]; c++)
80105000:	c7 45 f4 34 4f 11 80 	movl   $0x80114f34,-0xc(%ebp)
80105007:	eb 3e                	jmp    80105047 <alloccont+0x59>
		if(c->state == CUNUSED)
80105009:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010500c:	8b 40 14             	mov    0x14(%eax),%eax
8010500f:	85 c0                	test   %eax,%eax
80105011:	75 30                	jne    80105043 <alloccont+0x55>
		  goto found;
80105013:	90                   	nop

	release(&ctable.lock);
	return 0;

found:
	c->state = CEMBRYO;
80105014:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105017:	c7 40 14 01 00 00 00 	movl   $0x1,0x14(%eax)
	c->cid = nextcid++;
8010501e:	a1 08 c0 10 80       	mov    0x8010c008,%eax
80105023:	8d 50 01             	lea    0x1(%eax),%edx
80105026:	89 15 08 c0 10 80    	mov    %edx,0x8010c008
8010502c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010502f:	89 42 0c             	mov    %eax,0xc(%edx)

	release(&ctable.lock);
80105032:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80105039:	e8 6b 09 00 00       	call   801059a9 <release>

	return c;
8010503e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105041:	eb 1e                	jmp    80105061 <alloccont+0x73>
{
	struct cont *c;

	acquire(&ctable.lock);

	for(c = ctable.cont; c < &ctable.cont[NCONT]; c++)
80105043:	83 45 f4 30          	addl   $0x30,-0xc(%ebp)
80105047:	81 7d f4 b4 50 11 80 	cmpl   $0x801150b4,-0xc(%ebp)
8010504e:	72 b9                	jb     80105009 <alloccont+0x1b>
		if(c->state == CUNUSED)
		  goto found;

	release(&ctable.lock);
80105050:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80105057:	e8 4d 09 00 00       	call   801059a9 <release>
	return 0;
8010505c:	b8 00 00 00 00       	mov    $0x0,%eax
	c->cid = nextcid++;

	release(&ctable.lock);

	return c;
}
80105061:	c9                   	leave  
80105062:	c3                   	ret    

80105063 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80105063:	55                   	push   %ebp
80105064:	89 e5                	mov    %esp,%ebp
80105066:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
80105069:	e8 92 f2 ff ff       	call   80104300 <myproc>
8010506e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(ctablelock()))
80105071:	e8 35 fe ff ff       	call   80104eab <ctablelock>
80105076:	89 04 24             	mov    %eax,(%esp)
80105079:	e8 ef 09 00 00       	call   80105a6d <holding>
8010507e:	85 c0                	test   %eax,%eax
80105080:	75 0c                	jne    8010508e <sched+0x2b>
    panic("sched ptable.lock");
80105082:	c7 04 24 76 97 10 80 	movl   $0x80109776,(%esp)
80105089:	e8 c6 b4 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1) 
8010508e:	e8 3c fd ff ff       	call   80104dcf <mycpu>
80105093:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105099:	83 f8 01             	cmp    $0x1,%eax
8010509c:	74 0c                	je     801050aa <sched+0x47>
    panic("sched locks");
8010509e:	c7 04 24 88 97 10 80 	movl   $0x80109788,(%esp)
801050a5:	e8 aa b4 ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
801050aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050ad:	8b 40 0c             	mov    0xc(%eax),%eax
801050b0:	83 f8 04             	cmp    $0x4,%eax
801050b3:	75 0c                	jne    801050c1 <sched+0x5e>
    panic("sched running");
801050b5:	c7 04 24 94 97 10 80 	movl   $0x80109794,(%esp)
801050bc:	e8 93 b4 ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
801050c1:	e8 ae fc ff ff       	call   80104d74 <readeflags>
801050c6:	25 00 02 00 00       	and    $0x200,%eax
801050cb:	85 c0                	test   %eax,%eax
801050cd:	74 0c                	je     801050db <sched+0x78>
    panic("sched interruptible");
801050cf:	c7 04 24 a2 97 10 80 	movl   $0x801097a2,(%esp)
801050d6:	e8 79 b4 ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
801050db:	e8 ef fc ff ff       	call   80104dcf <mycpu>
801050e0:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801050e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801050e9:	e8 e1 fc ff ff       	call   80104dcf <mycpu>
801050ee:	8b 40 04             	mov    0x4(%eax),%eax
801050f1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050f4:	83 c2 1c             	add    $0x1c,%edx
801050f7:	89 44 24 04          	mov    %eax,0x4(%esp)
801050fb:	89 14 24             	mov    %edx,(%esp)
801050fe:	e8 19 0d 00 00       	call   80105e1c <swtch>
  mycpu()->intena = intena;
80105103:	e8 c7 fc ff ff       	call   80104dcf <mycpu>
80105108:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010510b:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80105111:	c9                   	leave  
80105112:	c3                   	ret    

80105113 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80105113:	55                   	push   %ebp
80105114:	89 e5                	mov    %esp,%ebp
80105116:	83 ec 38             	sub    $0x38,%esp
  struct proc *p;
  struct cont *cont;
  struct cpu *c = mycpu();
80105119:	e8 b1 fc ff ff       	call   80104dcf <mycpu>
8010511e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i, k;
  c->proc = 0;
80105121:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105124:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010512b:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010512e:	e8 51 fc ff ff       	call   80104d84 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80105133:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
8010513a:	e8 00 08 00 00       	call   8010593f <acquire>
    // TODO: do we need to acquire ctable lock too?

	// TODO: Check that scheulde cycles over ctable equally    
    for(i = 0; i < NCONT; i++) {
8010513f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105146:	e9 57 01 00 00       	jmp    801052a2 <scheduler+0x18f>

      cont = &ctable.cont[i];
8010514b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010514e:	8d 50 01             	lea    0x1(%eax),%edx
80105151:	89 d0                	mov    %edx,%eax
80105153:	01 c0                	add    %eax,%eax
80105155:	01 d0                	add    %edx,%eax
80105157:	c1 e0 04             	shl    $0x4,%eax
8010515a:	05 00 4f 11 80       	add    $0x80114f00,%eax
8010515f:	83 c0 04             	add    $0x4,%eax
80105162:	89 45 e8             	mov    %eax,-0x18(%ebp)

      if (cont->state != CRUNNABLE && cont->state != CREADY)
80105165:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105168:	8b 40 14             	mov    0x14(%eax),%eax
8010516b:	83 f8 03             	cmp    $0x3,%eax
8010516e:	74 10                	je     80105180 <scheduler+0x6d>
80105170:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105173:	8b 40 14             	mov    0x14(%eax),%eax
80105176:	83 f8 02             	cmp    $0x2,%eax
80105179:	74 05                	je     80105180 <scheduler+0x6d>
      	continue;            
8010517b:	e9 1f 01 00 00       	jmp    8010529f <scheduler+0x18c>

      for (k = (cont->nextproc % cont->mproc); k < cont->mproc; k++) {
80105180:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105183:	8b 40 2c             	mov    0x2c(%eax),%eax
80105186:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105189:	8b 4a 08             	mov    0x8(%edx),%ecx
8010518c:	99                   	cltd   
8010518d:	f7 f9                	idiv   %ecx
8010518f:	89 55 f0             	mov    %edx,-0x10(%ebp)
80105192:	e9 f9 00 00 00       	jmp    80105290 <scheduler+0x17d>
      	
      	  p = &cont->ptable[k];       	  
80105197:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010519a:	8b 50 28             	mov    0x28(%eax),%edx
8010519d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051a0:	c1 e0 02             	shl    $0x2,%eax
801051a3:	89 c1                	mov    %eax,%ecx
801051a5:	c1 e1 05             	shl    $0x5,%ecx
801051a8:	01 c8                	add    %ecx,%eax
801051aa:	01 d0                	add    %edx,%eax
801051ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)

      	  cont->nextproc = cont->nextproc + 1;
801051af:	8b 45 e8             	mov    -0x18(%ebp),%eax
801051b2:	8b 40 2c             	mov    0x2c(%eax),%eax
801051b5:	8d 50 01             	lea    0x1(%eax),%edx
801051b8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801051bb:	89 50 2c             	mov    %edx,0x2c(%eax)

	      if(p->state != RUNNABLE)
801051be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801051c1:	8b 40 0c             	mov    0xc(%eax),%eax
801051c4:	83 f8 03             	cmp    $0x3,%eax
801051c7:	74 05                	je     801051ce <scheduler+0xbb>
	        continue;
801051c9:	e9 bf 00 00 00       	jmp    8010528d <scheduler+0x17a>

	      if (strncmp("ctest1", cont->name, strlen("ctest1")) == 0 && strncmp("testproc", p->name, strlen("testproc")) == 0) {
801051ce:	c7 04 24 b6 97 10 80 	movl   $0x801097b6,(%esp)
801051d5:	e8 1b 0c 00 00       	call   80105df5 <strlen>
801051da:	8b 55 e8             	mov    -0x18(%ebp),%edx
801051dd:	83 c2 18             	add    $0x18,%edx
801051e0:	89 44 24 08          	mov    %eax,0x8(%esp)
801051e4:	89 54 24 04          	mov    %edx,0x4(%esp)
801051e8:	c7 04 24 b6 97 10 80 	movl   $0x801097b6,(%esp)
801051ef:	e8 16 0b 00 00       	call   80105d0a <strncmp>
801051f4:	85 c0                	test   %eax,%eax
801051f6:	75 4a                	jne    80105242 <scheduler+0x12f>
801051f8:	c7 04 24 bd 97 10 80 	movl   $0x801097bd,(%esp)
801051ff:	e8 f1 0b 00 00       	call   80105df5 <strlen>
80105204:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105207:	83 c2 6c             	add    $0x6c,%edx
8010520a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010520e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105212:	c7 04 24 bd 97 10 80 	movl   $0x801097bd,(%esp)
80105219:	e8 ec 0a 00 00       	call   80105d0a <strncmp>
8010521e:	85 c0                	test   %eax,%eax
80105220:	75 20                	jne    80105242 <scheduler+0x12f>
	      	cprintf("\t\tScheduling %s proc %s\n", cont->name, p->name);
80105222:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105225:	8d 50 6c             	lea    0x6c(%eax),%edx
80105228:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010522b:	83 c0 18             	add    $0x18,%eax
8010522e:	89 54 24 08          	mov    %edx,0x8(%esp)
80105232:	89 44 24 04          	mov    %eax,0x4(%esp)
80105236:	c7 04 24 c6 97 10 80 	movl   $0x801097c6,(%esp)
8010523d:	e8 7f b1 ff ff       	call   801003c1 <cprintf>


	      // Switch to chosen process.  It is the process's job
	      // to release ctable.lock and then reacquire it
	      // before jumping back to us.
	      c->proc = p;
80105242:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105245:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105248:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
	      switchuvm(p);
8010524e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105251:	89 04 24             	mov    %eax,(%esp)
80105254:	e8 1f 37 00 00       	call   80108978 <switchuvm>
	      p->state = RUNNING;
80105259:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010525c:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

	      swtch(&(c->scheduler), p->context); 
80105263:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105266:	8b 40 1c             	mov    0x1c(%eax),%eax
80105269:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010526c:	83 c2 04             	add    $0x4,%edx
8010526f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105273:	89 14 24             	mov    %edx,(%esp)
80105276:	e8 a1 0b 00 00       	call   80105e1c <swtch>
	      switchkvm();
8010527b:	e8 de 36 00 00       	call   8010895e <switchkvm>

	      // Process is done running for now.
	      // It should have changed its p->state before coming back.
	      c->proc = 0;
80105280:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105283:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010528a:	00 00 00 
      cont = &ctable.cont[i];

      if (cont->state != CRUNNABLE && cont->state != CREADY)
      	continue;            

      for (k = (cont->nextproc % cont->mproc); k < cont->mproc; k++) {
8010528d:	ff 45 f0             	incl   -0x10(%ebp)
80105290:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105293:	8b 40 08             	mov    0x8(%eax),%eax
80105296:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80105299:	0f 8f f8 fe ff ff    	jg     80105197 <scheduler+0x84>
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    // TODO: do we need to acquire ctable lock too?

	// TODO: Check that scheulde cycles over ctable equally    
    for(i = 0; i < NCONT; i++) {
8010529f:	ff 45 f4             	incl   -0xc(%ebp)
801052a2:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801052a6:	0f 8e 9f fe ff ff    	jle    8010514b <scheduler+0x38>
	      // Process is done running for now.
	      // It should have changed its p->state before coming back.
	      c->proc = 0;
	  }
    }
    release(&ptable.lock);
801052ac:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
801052b3:	e8 f1 06 00 00       	call   801059a9 <release>

  }
801052b8:	e9 71 fe ff ff       	jmp    8010512e <scheduler+0x1b>

801052bd <ccreate>:
}

// TODO: Block processes inside non root containers from ccreating
int 
ccreate(char* name, char* progv[MAXARG], int progc, int mproc, uint msz, uint mdsk)
{
801052bd:	55                   	push   %ebp
801052be:	89 e5                	mov    %esp,%ebp
801052c0:	83 ec 28             	sub    $0x28,%esp
	int i;
	struct cont *nc;
	//struct inode *rootdir;

	// Allocate container.
	if ((nc = alloccont()) == 0) {
801052c3:	e8 26 fd ff ff       	call   80104fee <alloccont>
801052c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
801052cb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801052cf:	75 0a                	jne    801052db <ccreate+0x1e>
		return -1;
801052d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052d6:	e9 bc 00 00 00       	jmp    80105397 <ccreate+0xda>
	// }
	// iunlockput(rootdir);
	// end_op();	

	// TODO: Move files into folder
	for (i = 0; i < progc; i++) {
801052db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801052e2:	eb 03                	jmp    801052e7 <ccreate+0x2a>
801052e4:	ff 45 f4             	incl   -0xc(%ebp)
801052e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052ea:	3b 45 10             	cmp    0x10(%ebp),%eax
801052ed:	7c f5                	jl     801052e4 <ccreate+0x27>
		// if (movefile(name, progv[i]) == 0) 
		// 	cprintf("Unable to move file %s\n", progv[i]);
	}

	acquire(&ctable.lock);
801052ef:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
801052f6:	e8 44 06 00 00       	call   8010593f <acquire>
	nc->mproc = mproc;
801052fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052fe:	8b 55 14             	mov    0x14(%ebp),%edx
80105301:	89 50 08             	mov    %edx,0x8(%eax)
	nc->msz = msz;
80105304:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105307:	8b 55 18             	mov    0x18(%ebp),%edx
8010530a:	89 10                	mov    %edx,(%eax)
	nc->mdsk = mdsk;
8010530c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010530f:	8b 55 1c             	mov    0x1c(%ebp),%edx
80105312:	89 50 04             	mov    %edx,0x4(%eax)
	nc->rootdir = namei(name); // TODO: Check this with an if
80105315:	8b 45 08             	mov    0x8(%ebp),%eax
80105318:	89 04 24             	mov    %eax,(%esp)
8010531b:	e8 0d d4 ff ff       	call   8010272d <namei>
80105320:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105323:	89 42 10             	mov    %eax,0x10(%edx)
	strncpy(nc->name, name, 16); // TODO: strlen(name) instead of 16?
80105326:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105329:	8d 50 18             	lea    0x18(%eax),%edx
8010532c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105333:	00 
80105334:	8b 45 08             	mov    0x8(%ebp),%eax
80105337:	89 44 24 04          	mov    %eax,0x4(%esp)
8010533b:	89 14 24             	mov    %edx,(%esp)
8010533e:	e8 15 0a 00 00       	call   80105d58 <strncpy>
	nc->state = CREADY;	
80105343:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105346:	c7 40 14 02 00 00 00 	movl   $0x2,0x14(%eax)
	release(&ctable.lock);	
8010534d:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80105354:	e8 50 06 00 00       	call   801059a9 <release>

	cprintf("inited container %s\n", nc->name);
80105359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010535c:	83 c0 18             	add    $0x18,%eax
8010535f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105363:	c7 04 24 df 97 10 80 	movl   $0x801097df,(%esp)
8010536a:	e8 52 b0 ff ff       	call   801003c1 <cprintf>
	cprintf("rootdir is type folder %d\n", (nc->rootdir->type == T_DIR));    
8010536f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105372:	8b 40 10             	mov    0x10(%eax),%eax
80105375:	8b 40 50             	mov    0x50(%eax),%eax
80105378:	66 83 f8 01          	cmp    $0x1,%ax
8010537c:	0f 94 c0             	sete   %al
8010537f:	0f b6 c0             	movzbl %al,%eax
80105382:	89 44 24 04          	mov    %eax,0x4(%esp)
80105386:	c7 04 24 f4 97 10 80 	movl   $0x801097f4,(%esp)
8010538d:	e8 2f b0 ff ff       	call   801003c1 <cprintf>

	return 1;  
80105392:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105397:	c9                   	leave  
80105398:	c3                   	ret    

80105399 <cstart>:

// Allocates a process for the table "name"
// Runs argv[0] (argv is program plus arguments)
int
cstart(char* name, char** argv, int argc) 
{	
80105399:	55                   	push   %ebp
8010539a:	89 e5                	mov    %esp,%ebp
8010539c:	53                   	push   %ebx
8010539d:	83 ec 24             	sub    $0x24,%esp
	cprintf("Cstart\n");
801053a0:	c7 04 24 0f 98 10 80 	movl   $0x8010980f,(%esp)
801053a7:	e8 15 b0 ff ff       	call   801003c1 <cprintf>
	//struct cpu *cpu;
	struct proc *np;
	int i;

	// Find container
	acquire(&ctable.lock);
801053ac:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
801053b3:	e8 87 05 00 00       	call   8010593f <acquire>

	for (i = 0; i < NCONT; i++) {
801053b8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801053bf:	e9 0d 01 00 00       	jmp    801054d1 <cstart+0x138>
		nc = &ctable.cont[i];
801053c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c7:	8d 50 01             	lea    0x1(%eax),%edx
801053ca:	89 d0                	mov    %edx,%eax
801053cc:	01 c0                	add    %eax,%eax
801053ce:	01 d0                	add    %edx,%eax
801053d0:	c1 e0 04             	shl    $0x4,%eax
801053d3:	05 00 4f 11 80       	add    $0x80114f00,%eax
801053d8:	83 c0 04             	add    $0x4,%eax
801053db:	89 45 f0             	mov    %eax,-0x10(%ebp)
		// TODO: Check if this works
		if (strncmp(name, nc->name, strlen(name)) == 0 && nc->state == CREADY)
801053de:	8b 45 08             	mov    0x8(%ebp),%eax
801053e1:	89 04 24             	mov    %eax,(%esp)
801053e4:	e8 0c 0a 00 00       	call   80105df5 <strlen>
801053e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801053ec:	83 c2 18             	add    $0x18,%edx
801053ef:	89 44 24 08          	mov    %eax,0x8(%esp)
801053f3:	89 54 24 04          	mov    %edx,0x4(%esp)
801053f7:	8b 45 08             	mov    0x8(%ebp),%eax
801053fa:	89 04 24             	mov    %eax,(%esp)
801053fd:	e8 08 09 00 00       	call   80105d0a <strncmp>
80105402:	85 c0                	test   %eax,%eax
80105404:	0f 85 c4 00 00 00    	jne    801054ce <cstart+0x135>
8010540a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010540d:	8b 40 14             	mov    0x14(%eax),%eax
80105410:	83 f8 02             	cmp    $0x2,%eax
80105413:	0f 85 b5 00 00 00    	jne    801054ce <cstart+0x135>
			goto found;
80105419:	90                   	nop
	release(&ctable.lock);
	return -1;

found: 	

	cprintf("\tFound container to run (%s)\n", nc->name);
8010541a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010541d:	83 c0 18             	add    $0x18,%eax
80105420:	89 44 24 04          	mov    %eax,0x4(%esp)
80105424:	c7 04 24 39 98 10 80 	movl   $0x80109839,(%esp)
8010542b:	e8 91 af ff ff       	call   801003c1 <cprintf>
	// TODO COMMENT THIS A TON

	// TODO: Change init process back
	// TODO: Clean up cfork/ change fork to accept a parent container

	cprintf("cstart: nc->rootdir->type %d", nc->rootdir->type);
80105430:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105433:	8b 40 10             	mov    0x10(%eax),%eax
80105436:	8b 40 50             	mov    0x50(%eax),%eax
80105439:	98                   	cwtl   
8010543a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010543e:	c7 04 24 57 98 10 80 	movl   $0x80109857,(%esp)
80105445:	e8 77 af ff ff       	call   801003c1 <cprintf>
	// if ((np = cfork(nc)) == 0) {
	// 	cprintf("couldn't cfork\n");
	// 	release(&ctable.lock);
	// 	return -1;
	// }
	np = initprocess(nc, "initproc", 0);
8010544a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105451:	00 
80105452:	c7 44 24 04 6d 97 10 	movl   $0x8010976d,0x4(%esp)
80105459:	80 
8010545a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010545d:	89 04 24             	mov    %eax,(%esp)
80105460:	e8 e9 ef ff ff       	call   8010444e <initprocess>
80105465:	89 45 ec             	mov    %eax,-0x14(%ebp)

	nc->state = CREADY;	
80105468:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010546b:	c7 40 14 02 00 00 00 	movl   $0x2,0x14(%eax)
	// myproc()->state = RUNNABLE; 
	cprintf("np->state is RUNNABLE: %d\n", (np->state == RUNNABLE));
80105472:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105475:	8b 40 0c             	mov    0xc(%eax),%eax
80105478:	83 f8 03             	cmp    $0x3,%eax
8010547b:	0f 94 c0             	sete   %al
8010547e:	0f b6 c0             	movzbl %al,%eax
80105481:	89 44 24 04          	mov    %eax,0x4(%esp)
80105485:	c7 04 24 74 98 10 80 	movl   $0x80109874,(%esp)
8010548c:	e8 30 af ff ff       	call   801003c1 <cprintf>

	release(&ctable.lock);
80105491:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80105498:	e8 0c 05 00 00       	call   801059a9 <release>
	// acquirectable();
	// sched();
	// releasectable();
	
	// Does copyuvm not also copy the place in kernel vm?
	cprintf("This should print twice: container %s proc %s\n", myproc()->cont->name, myproc()->name);
8010549d:	e8 5e ee ff ff       	call   80104300 <myproc>
801054a2:	8d 58 6c             	lea    0x6c(%eax),%ebx
801054a5:	e8 56 ee ff ff       	call   80104300 <myproc>
801054aa:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801054b0:	83 c0 18             	add    $0x18,%eax
801054b3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801054b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801054bb:	c7 04 24 90 98 10 80 	movl   $0x80109890,(%esp)
801054c2:	e8 fa ae ff ff       	call   801003c1 <cprintf>
	// 	cprintf("CONFIRMATION THAT OTHER GUY RAN\n");
	// }		

	//	release(&ctable.lock);	

	return 1;
801054c7:	b8 01 00 00 00       	mov    $0x1,%eax
801054cc:	eb 31                	jmp    801054ff <cstart+0x166>
	int i;

	// Find container
	acquire(&ctable.lock);

	for (i = 0; i < NCONT; i++) {
801054ce:	ff 45 f4             	incl   -0xc(%ebp)
801054d1:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801054d5:	0f 8e e9 fe ff ff    	jle    801053c4 <cstart+0x2b>
		// TODO: Check if this works
		if (strncmp(name, nc->name, strlen(name)) == 0 && nc->state == CREADY)
			goto found;
	}

	cprintf("No free container with name %s \n", name);
801054db:	8b 45 08             	mov    0x8(%ebp),%eax
801054de:	89 44 24 04          	mov    %eax,0x4(%esp)
801054e2:	c7 04 24 18 98 10 80 	movl   $0x80109818,(%esp)
801054e9:	e8 d3 ae ff ff       	call   801003c1 <cprintf>
	release(&ctable.lock);
801054ee:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
801054f5:	e8 af 04 00 00       	call   801059a9 <release>
	return -1;
801054fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	// }		

	//	release(&ctable.lock);	

	return 1;
}
801054ff:	83 c4 24             	add    $0x24,%esp
80105502:	5b                   	pop    %ebx
80105503:	5d                   	pop    %ebp
80105504:	c3                   	ret    

80105505 <movefile>:


/* Moves file src to folder dst 
TODO: Implement */
int
movefile(char* dst, char* src) {
80105505:	55                   	push   %ebp
80105506:	89 e5                	mov    %esp,%ebp
80105508:	57                   	push   %edi
80105509:	56                   	push   %esi
8010550a:	53                   	push   %ebx
8010550b:	83 ec 2c             	sub    $0x2c,%esp
8010550e:	89 e0                	mov    %esp,%eax
80105510:	89 c6                	mov    %eax,%esi
	
	int pathsize = sizeof(dst) + sizeof(src) + 2; // dst.len + '\' + src.len + \0
80105512:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
	char path[pathsize]; 
80105519:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010551c:	8d 50 ff             	lea    -0x1(%eax),%edx
8010551f:	89 55 e0             	mov    %edx,-0x20(%ebp)
80105522:	ba 10 00 00 00       	mov    $0x10,%edx
80105527:	4a                   	dec    %edx
80105528:	01 d0                	add    %edx,%eax
8010552a:	b9 10 00 00 00       	mov    $0x10,%ecx
8010552f:	ba 00 00 00 00       	mov    $0x0,%edx
80105534:	f7 f1                	div    %ecx
80105536:	6b c0 10             	imul   $0x10,%eax,%eax
80105539:	29 c4                	sub    %eax,%esp
8010553b:	8d 44 24 0c          	lea    0xc(%esp),%eax
8010553f:	83 c0 00             	add    $0x0,%eax
80105542:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// struct file *f;
	// struct inode *ip;

	memmove(path, dst, strlen(dst));
80105545:	8b 45 08             	mov    0x8(%ebp),%eax
80105548:	89 04 24             	mov    %eax,(%esp)
8010554b:	e8 a5 08 00 00       	call   80105df5 <strlen>
80105550:	89 c2                	mov    %eax,%edx
80105552:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105555:	89 54 24 08          	mov    %edx,0x8(%esp)
80105559:	8b 55 08             	mov    0x8(%ebp),%edx
8010555c:	89 54 24 04          	mov    %edx,0x4(%esp)
80105560:	89 04 24             	mov    %eax,(%esp)
80105563:	e8 03 07 00 00       	call   80105c6b <memmove>
	memmove(path + strlen(dst), "/", 1);
80105568:	8b 5d dc             	mov    -0x24(%ebp),%ebx
8010556b:	8b 45 08             	mov    0x8(%ebp),%eax
8010556e:	89 04 24             	mov    %eax,(%esp)
80105571:	e8 7f 08 00 00       	call   80105df5 <strlen>
80105576:	01 d8                	add    %ebx,%eax
80105578:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
8010557f:	00 
80105580:	c7 44 24 04 48 97 10 	movl   $0x80109748,0x4(%esp)
80105587:	80 
80105588:	89 04 24             	mov    %eax,(%esp)
8010558b:	e8 db 06 00 00       	call   80105c6b <memmove>
	memmove(path + strlen(dst) + 1, src, strlen(src));
80105590:	8b 45 0c             	mov    0xc(%ebp),%eax
80105593:	89 04 24             	mov    %eax,(%esp)
80105596:	e8 5a 08 00 00       	call   80105df5 <strlen>
8010559b:	89 c3                	mov    %eax,%ebx
8010559d:	8b 7d dc             	mov    -0x24(%ebp),%edi
801055a0:	8b 45 08             	mov    0x8(%ebp),%eax
801055a3:	89 04 24             	mov    %eax,(%esp)
801055a6:	e8 4a 08 00 00       	call   80105df5 <strlen>
801055ab:	40                   	inc    %eax
801055ac:	8d 14 07             	lea    (%edi,%eax,1),%edx
801055af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801055b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801055b6:	89 44 24 04          	mov    %eax,0x4(%esp)
801055ba:	89 14 24             	mov    %edx,(%esp)
801055bd:	e8 a9 06 00 00       	call   80105c6b <memmove>
	memmove(path + strlen(dst) + 1 + strlen(src), "\0", 1);
801055c2:	8b 5d dc             	mov    -0x24(%ebp),%ebx
801055c5:	8b 45 08             	mov    0x8(%ebp),%eax
801055c8:	89 04 24             	mov    %eax,(%esp)
801055cb:	e8 25 08 00 00       	call   80105df5 <strlen>
801055d0:	89 c7                	mov    %eax,%edi
801055d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801055d5:	89 04 24             	mov    %eax,(%esp)
801055d8:	e8 18 08 00 00       	call   80105df5 <strlen>
801055dd:	01 f8                	add    %edi,%eax
801055df:	40                   	inc    %eax
801055e0:	01 d8                	add    %ebx,%eax
801055e2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801055e9:	00 
801055ea:	c7 44 24 04 bf 98 10 	movl   $0x801098bf,0x4(%esp)
801055f1:	80 
801055f2:	89 04 24             	mov    %eax,(%esp)
801055f5:	e8 71 06 00 00       	call   80105c6b <memmove>

	cprintf("movefile path: %s\n", path);
801055fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
801055fd:	89 44 24 04          	mov    %eax,0x4(%esp)
80105601:	c7 04 24 c1 98 10 80 	movl   $0x801098c1,(%esp)
80105608:	e8 b4 ad ff ff       	call   801003c1 <cprintf>
	// // Copy contents of src into new file
	// char* source;
	// fileread();	


	return 1;
8010560d:	b8 01 00 00 00       	mov    $0x1,%eax
80105612:	89 f4                	mov    %esi,%esp
}
80105614:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105617:	5b                   	pop    %ebx
80105618:	5e                   	pop    %esi
80105619:	5f                   	pop    %edi
8010561a:	5d                   	pop    %ebp
8010561b:	c3                   	ret    

8010561c <contdump>:
// Print a process listing of current container to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
contdump(void)
{
8010561c:	55                   	push   %ebp
8010561d:	89 e5                	mov    %esp,%ebp
8010561f:	53                   	push   %ebx
80105620:	83 ec 64             	sub    $0x64,%esp
  struct cont *c;
  struct proc *p;
  char *state;
  uint pc[10];

  cprintf("Contdump()\n");
80105623:	c7 04 24 d4 98 10 80 	movl   $0x801098d4,(%esp)
8010562a:	e8 92 ad ff ff       	call   801003c1 <cprintf>
  cprintf("cont 2 p[0] %s %s\n", ctable.cont[1].ptable[0].name, states[ctable.cont[1].ptable[0].state]);
8010562f:	a1 8c 4f 11 80       	mov    0x80114f8c,%eax
80105634:	8b 40 0c             	mov    0xc(%eax),%eax
80105637:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
8010563e:	8b 15 8c 4f 11 80    	mov    0x80114f8c,%edx
80105644:	83 c2 6c             	add    $0x6c,%edx
80105647:	89 44 24 08          	mov    %eax,0x8(%esp)
8010564b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010564f:	c7 04 24 e0 98 10 80 	movl   $0x801098e0,(%esp)
80105656:	e8 66 ad ff ff       	call   801003c1 <cprintf>

  acquirectable();
8010565b:	e8 23 f8 ff ff       	call   80104e83 <acquirectable>

  for(i = 0; i < NCONT; i++) {
80105660:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105667:	e9 5c 01 00 00       	jmp    801057c8 <contdump+0x1ac>

      c = &ctable.cont[i];
8010566c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010566f:	8d 50 01             	lea    0x1(%eax),%edx
80105672:	89 d0                	mov    %edx,%eax
80105674:	01 c0                	add    %eax,%eax
80105676:	01 d0                	add    %edx,%eax
80105678:	c1 e0 04             	shl    $0x4,%eax
8010567b:	05 00 4f 11 80       	add    $0x80114f00,%eax
80105680:	83 c0 04             	add    $0x4,%eax
80105683:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      nextproc = 0, k = 0;
80105686:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010568d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

      if (c->state == CUNUSED)
80105694:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105697:	8b 40 14             	mov    0x14(%eax),%eax
8010569a:	85 c0                	test   %eax,%eax
8010569c:	75 05                	jne    801056a3 <contdump+0x87>
      	continue;
8010569e:	e9 22 01 00 00       	jmp    801057c5 <contdump+0x1a9>

      for (k = (nextproc % c->mproc); k < c->mproc; k++) {
801056a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801056a6:	8b 48 08             	mov    0x8(%eax),%ecx
801056a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801056ac:	99                   	cltd   
801056ad:	f7 f9                	idiv   %ecx
801056af:	89 55 f0             	mov    %edx,-0x10(%ebp)
801056b2:	e9 ff 00 00 00       	jmp    801057b6 <contdump+0x19a>
      
      	p = &c->ptable[k]; 
801056b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801056ba:	8b 50 28             	mov    0x28(%eax),%edx
801056bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801056c0:	c1 e0 02             	shl    $0x2,%eax
801056c3:	89 c1                	mov    %eax,%ecx
801056c5:	c1 e1 05             	shl    $0x5,%ecx
801056c8:	01 c8                	add    %ecx,%eax
801056ca:	01 d0                	add    %edx,%eax
801056cc:	89 45 e0             	mov    %eax,-0x20(%ebp)

      	nextproc++;
801056cf:	ff 45 ec             	incl   -0x14(%ebp)

	    if(p->state == UNUSED)
801056d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801056d5:	8b 40 0c             	mov    0xc(%eax),%eax
801056d8:	85 c0                	test   %eax,%eax
801056da:	75 05                	jne    801056e1 <contdump+0xc5>
		    continue;
801056dc:	e9 d2 00 00 00       	jmp    801057b3 <contdump+0x197>
	    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801056e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801056e4:	8b 40 0c             	mov    0xc(%eax),%eax
801056e7:	83 f8 05             	cmp    $0x5,%eax
801056ea:	77 23                	ja     8010570f <contdump+0xf3>
801056ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
801056ef:	8b 40 0c             	mov    0xc(%eax),%eax
801056f2:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
801056f9:	85 c0                	test   %eax,%eax
801056fb:	74 12                	je     8010570f <contdump+0xf3>
	      state = states[p->state];
801056fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105700:	8b 40 0c             	mov    0xc(%eax),%eax
80105703:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
8010570a:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010570d:	eb 07                	jmp    80105716 <contdump+0xfa>
	    else
	      state = "???";
8010570f:	c7 45 e8 f3 98 10 80 	movl   $0x801098f3,-0x18(%ebp)
	    cprintf("container: %s. %d %s %s", p->cont->name, p->pid, state, p->name);
80105716:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105719:	8d 58 6c             	lea    0x6c(%eax),%ebx
8010571c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010571f:	8b 40 10             	mov    0x10(%eax),%eax
80105722:	8b 55 e0             	mov    -0x20(%ebp),%edx
80105725:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
8010572b:	8d 4a 18             	lea    0x18(%edx),%ecx
8010572e:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80105732:	8b 55 e8             	mov    -0x18(%ebp),%edx
80105735:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105739:	89 44 24 08          	mov    %eax,0x8(%esp)
8010573d:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80105741:	c7 04 24 f7 98 10 80 	movl   $0x801098f7,(%esp)
80105748:	e8 74 ac ff ff       	call   801003c1 <cprintf>
	    if(p->state == SLEEPING){
8010574d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105750:	8b 40 0c             	mov    0xc(%eax),%eax
80105753:	83 f8 02             	cmp    $0x2,%eax
80105756:	75 4f                	jne    801057a7 <contdump+0x18b>
	      getcallerpcs((uint*)p->context->ebp+2, pc);
80105758:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010575b:	8b 40 1c             	mov    0x1c(%eax),%eax
8010575e:	8b 40 0c             	mov    0xc(%eax),%eax
80105761:	83 c0 08             	add    $0x8,%eax
80105764:	8d 55 b8             	lea    -0x48(%ebp),%edx
80105767:	89 54 24 04          	mov    %edx,0x4(%esp)
8010576b:	89 04 24             	mov    %eax,(%esp)
8010576e:	e8 83 02 00 00       	call   801059f6 <getcallerpcs>
	      for(i=0; i<10 && pc[i] != 0; i++)
80105773:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010577a:	eb 1a                	jmp    80105796 <contdump+0x17a>
	        cprintf(" %p", pc[i]);
8010577c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010577f:	8b 44 85 b8          	mov    -0x48(%ebp,%eax,4),%eax
80105783:	89 44 24 04          	mov    %eax,0x4(%esp)
80105787:	c7 04 24 0f 99 10 80 	movl   $0x8010990f,(%esp)
8010578e:	e8 2e ac ff ff       	call   801003c1 <cprintf>
	    else
	      state = "???";
	    cprintf("container: %s. %d %s %s", p->cont->name, p->pid, state, p->name);
	    if(p->state == SLEEPING){
	      getcallerpcs((uint*)p->context->ebp+2, pc);
	      for(i=0; i<10 && pc[i] != 0; i++)
80105793:	ff 45 f4             	incl   -0xc(%ebp)
80105796:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010579a:	7f 0b                	jg     801057a7 <contdump+0x18b>
8010579c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010579f:	8b 44 85 b8          	mov    -0x48(%ebp,%eax,4),%eax
801057a3:	85 c0                	test   %eax,%eax
801057a5:	75 d5                	jne    8010577c <contdump+0x160>
	        cprintf(" %p", pc[i]);
	    }
	    cprintf("\n");
801057a7:	c7 04 24 13 99 10 80 	movl   $0x80109913,(%esp)
801057ae:	e8 0e ac ff ff       	call   801003c1 <cprintf>
      nextproc = 0, k = 0;

      if (c->state == CUNUSED)
      	continue;

      for (k = (nextproc % c->mproc); k < c->mproc; k++) {
801057b3:	ff 45 f0             	incl   -0x10(%ebp)
801057b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057b9:	8b 40 08             	mov    0x8(%eax),%eax
801057bc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801057bf:	0f 8f f2 fe ff ff    	jg     801056b7 <contdump+0x9b>
  cprintf("Contdump()\n");
  cprintf("cont 2 p[0] %s %s\n", ctable.cont[1].ptable[0].name, states[ctable.cont[1].ptable[0].state]);

  acquirectable();

  for(i = 0; i < NCONT; i++) {
801057c5:	ff 45 f4             	incl   -0xc(%ebp)
801057c8:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801057cc:	0f 8e 9a fe ff ff    	jle    8010566c <contdump+0x50>
	    }
	    cprintf("\n");
	  }
  }

  releasectable();
801057d2:	e8 c0 f6 ff ff       	call   80104e97 <releasectable>
801057d7:	83 c4 64             	add    $0x64,%esp
801057da:	5b                   	pop    %ebx
801057db:	5d                   	pop    %ebp
801057dc:	c3                   	ret    
801057dd:	00 00                	add    %al,(%eax)
	...

801057e0 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801057e0:	55                   	push   %ebp
801057e1:	89 e5                	mov    %esp,%ebp
801057e3:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
801057e6:	8b 45 08             	mov    0x8(%ebp),%eax
801057e9:	83 c0 04             	add    $0x4,%eax
801057ec:	c7 44 24 04 3f 99 10 	movl   $0x8010993f,0x4(%esp)
801057f3:	80 
801057f4:	89 04 24             	mov    %eax,(%esp)
801057f7:	e8 22 01 00 00       	call   8010591e <initlock>
  lk->name = name;
801057fc:	8b 45 08             	mov    0x8(%ebp),%eax
801057ff:	8b 55 0c             	mov    0xc(%ebp),%edx
80105802:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105805:	8b 45 08             	mov    0x8(%ebp),%eax
80105808:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010580e:	8b 45 08             	mov    0x8(%ebp),%eax
80105811:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105818:	c9                   	leave  
80105819:	c3                   	ret    

8010581a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010581a:	55                   	push   %ebp
8010581b:	89 e5                	mov    %esp,%ebp
8010581d:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80105820:	8b 45 08             	mov    0x8(%ebp),%eax
80105823:	83 c0 04             	add    $0x4,%eax
80105826:	89 04 24             	mov    %eax,(%esp)
80105829:	e8 11 01 00 00       	call   8010593f <acquire>
  while (lk->locked) {
8010582e:	eb 15                	jmp    80105845 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80105830:	8b 45 08             	mov    0x8(%ebp),%eax
80105833:	83 c0 04             	add    $0x4,%eax
80105836:	89 44 24 04          	mov    %eax,0x4(%esp)
8010583a:	8b 45 08             	mov    0x8(%ebp),%eax
8010583d:	89 04 24             	mov    %eax,(%esp)
80105840:	e8 8f f3 ff ff       	call   80104bd4 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80105845:	8b 45 08             	mov    0x8(%ebp),%eax
80105848:	8b 00                	mov    (%eax),%eax
8010584a:	85 c0                	test   %eax,%eax
8010584c:	75 e2                	jne    80105830 <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
8010584e:	8b 45 08             	mov    0x8(%ebp),%eax
80105851:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80105857:	e8 a4 ea ff ff       	call   80104300 <myproc>
8010585c:	8b 50 10             	mov    0x10(%eax),%edx
8010585f:	8b 45 08             	mov    0x8(%ebp),%eax
80105862:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105865:	8b 45 08             	mov    0x8(%ebp),%eax
80105868:	83 c0 04             	add    $0x4,%eax
8010586b:	89 04 24             	mov    %eax,(%esp)
8010586e:	e8 36 01 00 00       	call   801059a9 <release>
}
80105873:	c9                   	leave  
80105874:	c3                   	ret    

80105875 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105875:	55                   	push   %ebp
80105876:	89 e5                	mov    %esp,%ebp
80105878:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
8010587b:	8b 45 08             	mov    0x8(%ebp),%eax
8010587e:	83 c0 04             	add    $0x4,%eax
80105881:	89 04 24             	mov    %eax,(%esp)
80105884:	e8 b6 00 00 00       	call   8010593f <acquire>
  lk->locked = 0;
80105889:	8b 45 08             	mov    0x8(%ebp),%eax
8010588c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105892:	8b 45 08             	mov    0x8(%ebp),%eax
80105895:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
8010589c:	8b 45 08             	mov    0x8(%ebp),%eax
8010589f:	89 04 24             	mov    %eax,(%esp)
801058a2:	e8 1b f4 ff ff       	call   80104cc2 <wakeup>
  release(&lk->lk);
801058a7:	8b 45 08             	mov    0x8(%ebp),%eax
801058aa:	83 c0 04             	add    $0x4,%eax
801058ad:	89 04 24             	mov    %eax,(%esp)
801058b0:	e8 f4 00 00 00       	call   801059a9 <release>
}
801058b5:	c9                   	leave  
801058b6:	c3                   	ret    

801058b7 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801058b7:	55                   	push   %ebp
801058b8:	89 e5                	mov    %esp,%ebp
801058ba:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
801058bd:	8b 45 08             	mov    0x8(%ebp),%eax
801058c0:	83 c0 04             	add    $0x4,%eax
801058c3:	89 04 24             	mov    %eax,(%esp)
801058c6:	e8 74 00 00 00       	call   8010593f <acquire>
  r = lk->locked;
801058cb:	8b 45 08             	mov    0x8(%ebp),%eax
801058ce:	8b 00                	mov    (%eax),%eax
801058d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801058d3:	8b 45 08             	mov    0x8(%ebp),%eax
801058d6:	83 c0 04             	add    $0x4,%eax
801058d9:	89 04 24             	mov    %eax,(%esp)
801058dc:	e8 c8 00 00 00       	call   801059a9 <release>
  return r;
801058e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801058e4:	c9                   	leave  
801058e5:	c3                   	ret    
	...

801058e8 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801058e8:	55                   	push   %ebp
801058e9:	89 e5                	mov    %esp,%ebp
801058eb:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801058ee:	9c                   	pushf  
801058ef:	58                   	pop    %eax
801058f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801058f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801058f6:	c9                   	leave  
801058f7:	c3                   	ret    

801058f8 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801058f8:	55                   	push   %ebp
801058f9:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801058fb:	fa                   	cli    
}
801058fc:	5d                   	pop    %ebp
801058fd:	c3                   	ret    

801058fe <sti>:

static inline void
sti(void)
{
801058fe:	55                   	push   %ebp
801058ff:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105901:	fb                   	sti    
}
80105902:	5d                   	pop    %ebp
80105903:	c3                   	ret    

80105904 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105904:	55                   	push   %ebp
80105905:	89 e5                	mov    %esp,%ebp
80105907:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010590a:	8b 55 08             	mov    0x8(%ebp),%edx
8010590d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105910:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105913:	f0 87 02             	lock xchg %eax,(%edx)
80105916:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105919:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010591c:	c9                   	leave  
8010591d:	c3                   	ret    

8010591e <initlock>:
#include "container.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010591e:	55                   	push   %ebp
8010591f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105921:	8b 45 08             	mov    0x8(%ebp),%eax
80105924:	8b 55 0c             	mov    0xc(%ebp),%edx
80105927:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010592a:	8b 45 08             	mov    0x8(%ebp),%eax
8010592d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105933:	8b 45 08             	mov    0x8(%ebp),%eax
80105936:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010593d:	5d                   	pop    %ebp
8010593e:	c3                   	ret    

8010593f <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010593f:	55                   	push   %ebp
80105940:	89 e5                	mov    %esp,%ebp
80105942:	53                   	push   %ebx
80105943:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105946:	e8 53 01 00 00       	call   80105a9e <pushcli>
  if(holding(lk))
8010594b:	8b 45 08             	mov    0x8(%ebp),%eax
8010594e:	89 04 24             	mov    %eax,(%esp)
80105951:	e8 17 01 00 00       	call   80105a6d <holding>
80105956:	85 c0                	test   %eax,%eax
80105958:	74 0c                	je     80105966 <acquire+0x27>
    panic("acquire");
8010595a:	c7 04 24 4a 99 10 80 	movl   $0x8010994a,(%esp)
80105961:	e8 ee ab ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105966:	90                   	nop
80105967:	8b 45 08             	mov    0x8(%ebp),%eax
8010596a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105971:	00 
80105972:	89 04 24             	mov    %eax,(%esp)
80105975:	e8 8a ff ff ff       	call   80105904 <xchg>
8010597a:	85 c0                	test   %eax,%eax
8010597c:	75 e9                	jne    80105967 <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010597e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105983:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105986:	e8 44 f4 ff ff       	call   80104dcf <mycpu>
8010598b:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010598e:	8b 45 08             	mov    0x8(%ebp),%eax
80105991:	83 c0 0c             	add    $0xc,%eax
80105994:	89 44 24 04          	mov    %eax,0x4(%esp)
80105998:	8d 45 08             	lea    0x8(%ebp),%eax
8010599b:	89 04 24             	mov    %eax,(%esp)
8010599e:	e8 53 00 00 00       	call   801059f6 <getcallerpcs>
}
801059a3:	83 c4 14             	add    $0x14,%esp
801059a6:	5b                   	pop    %ebx
801059a7:	5d                   	pop    %ebp
801059a8:	c3                   	ret    

801059a9 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801059a9:	55                   	push   %ebp
801059aa:	89 e5                	mov    %esp,%ebp
801059ac:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
801059af:	8b 45 08             	mov    0x8(%ebp),%eax
801059b2:	89 04 24             	mov    %eax,(%esp)
801059b5:	e8 b3 00 00 00       	call   80105a6d <holding>
801059ba:	85 c0                	test   %eax,%eax
801059bc:	75 0c                	jne    801059ca <release+0x21>
    panic("release");
801059be:	c7 04 24 52 99 10 80 	movl   $0x80109952,(%esp)
801059c5:	e8 8a ab ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
801059ca:	8b 45 08             	mov    0x8(%ebp),%eax
801059cd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801059d4:	8b 45 08             	mov    0x8(%ebp),%eax
801059d7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801059de:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801059e3:	8b 45 08             	mov    0x8(%ebp),%eax
801059e6:	8b 55 08             	mov    0x8(%ebp),%edx
801059e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801059ef:	e8 f4 00 00 00       	call   80105ae8 <popcli>
}
801059f4:	c9                   	leave  
801059f5:	c3                   	ret    

801059f6 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801059f6:	55                   	push   %ebp
801059f7:	89 e5                	mov    %esp,%ebp
801059f9:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801059fc:	8b 45 08             	mov    0x8(%ebp),%eax
801059ff:	83 e8 08             	sub    $0x8,%eax
80105a02:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105a05:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105a0c:	eb 37                	jmp    80105a45 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105a0e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105a12:	74 37                	je     80105a4b <getcallerpcs+0x55>
80105a14:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105a1b:	76 2e                	jbe    80105a4b <getcallerpcs+0x55>
80105a1d:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105a21:	74 28                	je     80105a4b <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105a23:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105a26:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105a2d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a30:	01 c2                	add    %eax,%edx
80105a32:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a35:	8b 40 04             	mov    0x4(%eax),%eax
80105a38:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105a3a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a3d:	8b 00                	mov    (%eax),%eax
80105a3f:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105a42:	ff 45 f8             	incl   -0x8(%ebp)
80105a45:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105a49:	7e c3                	jle    80105a0e <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105a4b:	eb 18                	jmp    80105a65 <getcallerpcs+0x6f>
    pcs[i] = 0;
80105a4d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105a50:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105a57:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a5a:	01 d0                	add    %edx,%eax
80105a5c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105a62:	ff 45 f8             	incl   -0x8(%ebp)
80105a65:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105a69:	7e e2                	jle    80105a4d <getcallerpcs+0x57>
    pcs[i] = 0;
}
80105a6b:	c9                   	leave  
80105a6c:	c3                   	ret    

80105a6d <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105a6d:	55                   	push   %ebp
80105a6e:	89 e5                	mov    %esp,%ebp
80105a70:	53                   	push   %ebx
80105a71:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80105a74:	8b 45 08             	mov    0x8(%ebp),%eax
80105a77:	8b 00                	mov    (%eax),%eax
80105a79:	85 c0                	test   %eax,%eax
80105a7b:	74 16                	je     80105a93 <holding+0x26>
80105a7d:	8b 45 08             	mov    0x8(%ebp),%eax
80105a80:	8b 58 08             	mov    0x8(%eax),%ebx
80105a83:	e8 47 f3 ff ff       	call   80104dcf <mycpu>
80105a88:	39 c3                	cmp    %eax,%ebx
80105a8a:	75 07                	jne    80105a93 <holding+0x26>
80105a8c:	b8 01 00 00 00       	mov    $0x1,%eax
80105a91:	eb 05                	jmp    80105a98 <holding+0x2b>
80105a93:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a98:	83 c4 04             	add    $0x4,%esp
80105a9b:	5b                   	pop    %ebx
80105a9c:	5d                   	pop    %ebp
80105a9d:	c3                   	ret    

80105a9e <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105a9e:	55                   	push   %ebp
80105a9f:	89 e5                	mov    %esp,%ebp
80105aa1:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105aa4:	e8 3f fe ff ff       	call   801058e8 <readeflags>
80105aa9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105aac:	e8 47 fe ff ff       	call   801058f8 <cli>
  if(mycpu()->ncli == 0)
80105ab1:	e8 19 f3 ff ff       	call   80104dcf <mycpu>
80105ab6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105abc:	85 c0                	test   %eax,%eax
80105abe:	75 14                	jne    80105ad4 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80105ac0:	e8 0a f3 ff ff       	call   80104dcf <mycpu>
80105ac5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ac8:	81 e2 00 02 00 00    	and    $0x200,%edx
80105ace:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105ad4:	e8 f6 f2 ff ff       	call   80104dcf <mycpu>
80105ad9:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105adf:	42                   	inc    %edx
80105ae0:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105ae6:	c9                   	leave  
80105ae7:	c3                   	ret    

80105ae8 <popcli>:

void
popcli(void)
{
80105ae8:	55                   	push   %ebp
80105ae9:	89 e5                	mov    %esp,%ebp
80105aeb:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105aee:	e8 f5 fd ff ff       	call   801058e8 <readeflags>
80105af3:	25 00 02 00 00       	and    $0x200,%eax
80105af8:	85 c0                	test   %eax,%eax
80105afa:	74 0c                	je     80105b08 <popcli+0x20>
    panic("popcli - interruptible");
80105afc:	c7 04 24 5a 99 10 80 	movl   $0x8010995a,(%esp)
80105b03:	e8 4c aa ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
80105b08:	e8 c2 f2 ff ff       	call   80104dcf <mycpu>
80105b0d:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105b13:	4a                   	dec    %edx
80105b14:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105b1a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105b20:	85 c0                	test   %eax,%eax
80105b22:	79 0c                	jns    80105b30 <popcli+0x48>
    panic("popcli");
80105b24:	c7 04 24 71 99 10 80 	movl   $0x80109971,(%esp)
80105b2b:	e8 24 aa ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105b30:	e8 9a f2 ff ff       	call   80104dcf <mycpu>
80105b35:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105b3b:	85 c0                	test   %eax,%eax
80105b3d:	75 14                	jne    80105b53 <popcli+0x6b>
80105b3f:	e8 8b f2 ff ff       	call   80104dcf <mycpu>
80105b44:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105b4a:	85 c0                	test   %eax,%eax
80105b4c:	74 05                	je     80105b53 <popcli+0x6b>
    sti();
80105b4e:	e8 ab fd ff ff       	call   801058fe <sti>
}
80105b53:	c9                   	leave  
80105b54:	c3                   	ret    
80105b55:	00 00                	add    %al,(%eax)
	...

80105b58 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105b58:	55                   	push   %ebp
80105b59:	89 e5                	mov    %esp,%ebp
80105b5b:	57                   	push   %edi
80105b5c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105b5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105b60:	8b 55 10             	mov    0x10(%ebp),%edx
80105b63:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b66:	89 cb                	mov    %ecx,%ebx
80105b68:	89 df                	mov    %ebx,%edi
80105b6a:	89 d1                	mov    %edx,%ecx
80105b6c:	fc                   	cld    
80105b6d:	f3 aa                	rep stos %al,%es:(%edi)
80105b6f:	89 ca                	mov    %ecx,%edx
80105b71:	89 fb                	mov    %edi,%ebx
80105b73:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105b76:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105b79:	5b                   	pop    %ebx
80105b7a:	5f                   	pop    %edi
80105b7b:	5d                   	pop    %ebp
80105b7c:	c3                   	ret    

80105b7d <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105b7d:	55                   	push   %ebp
80105b7e:	89 e5                	mov    %esp,%ebp
80105b80:	57                   	push   %edi
80105b81:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105b82:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105b85:	8b 55 10             	mov    0x10(%ebp),%edx
80105b88:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b8b:	89 cb                	mov    %ecx,%ebx
80105b8d:	89 df                	mov    %ebx,%edi
80105b8f:	89 d1                	mov    %edx,%ecx
80105b91:	fc                   	cld    
80105b92:	f3 ab                	rep stos %eax,%es:(%edi)
80105b94:	89 ca                	mov    %ecx,%edx
80105b96:	89 fb                	mov    %edi,%ebx
80105b98:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105b9b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105b9e:	5b                   	pop    %ebx
80105b9f:	5f                   	pop    %edi
80105ba0:	5d                   	pop    %ebp
80105ba1:	c3                   	ret    

80105ba2 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105ba2:	55                   	push   %ebp
80105ba3:	89 e5                	mov    %esp,%ebp
80105ba5:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105ba8:	8b 45 08             	mov    0x8(%ebp),%eax
80105bab:	83 e0 03             	and    $0x3,%eax
80105bae:	85 c0                	test   %eax,%eax
80105bb0:	75 49                	jne    80105bfb <memset+0x59>
80105bb2:	8b 45 10             	mov    0x10(%ebp),%eax
80105bb5:	83 e0 03             	and    $0x3,%eax
80105bb8:	85 c0                	test   %eax,%eax
80105bba:	75 3f                	jne    80105bfb <memset+0x59>
    c &= 0xFF;
80105bbc:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105bc3:	8b 45 10             	mov    0x10(%ebp),%eax
80105bc6:	c1 e8 02             	shr    $0x2,%eax
80105bc9:	89 c2                	mov    %eax,%edx
80105bcb:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bce:	c1 e0 18             	shl    $0x18,%eax
80105bd1:	89 c1                	mov    %eax,%ecx
80105bd3:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bd6:	c1 e0 10             	shl    $0x10,%eax
80105bd9:	09 c1                	or     %eax,%ecx
80105bdb:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bde:	c1 e0 08             	shl    $0x8,%eax
80105be1:	09 c8                	or     %ecx,%eax
80105be3:	0b 45 0c             	or     0xc(%ebp),%eax
80105be6:	89 54 24 08          	mov    %edx,0x8(%esp)
80105bea:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bee:	8b 45 08             	mov    0x8(%ebp),%eax
80105bf1:	89 04 24             	mov    %eax,(%esp)
80105bf4:	e8 84 ff ff ff       	call   80105b7d <stosl>
80105bf9:	eb 19                	jmp    80105c14 <memset+0x72>
  } else
    stosb(dst, c, n);
80105bfb:	8b 45 10             	mov    0x10(%ebp),%eax
80105bfe:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c02:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c05:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c09:	8b 45 08             	mov    0x8(%ebp),%eax
80105c0c:	89 04 24             	mov    %eax,(%esp)
80105c0f:	e8 44 ff ff ff       	call   80105b58 <stosb>
  return dst;
80105c14:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105c17:	c9                   	leave  
80105c18:	c3                   	ret    

80105c19 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105c19:	55                   	push   %ebp
80105c1a:	89 e5                	mov    %esp,%ebp
80105c1c:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105c1f:	8b 45 08             	mov    0x8(%ebp),%eax
80105c22:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105c25:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c28:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105c2b:	eb 2a                	jmp    80105c57 <memcmp+0x3e>
    if(*s1 != *s2)
80105c2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c30:	8a 10                	mov    (%eax),%dl
80105c32:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c35:	8a 00                	mov    (%eax),%al
80105c37:	38 c2                	cmp    %al,%dl
80105c39:	74 16                	je     80105c51 <memcmp+0x38>
      return *s1 - *s2;
80105c3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c3e:	8a 00                	mov    (%eax),%al
80105c40:	0f b6 d0             	movzbl %al,%edx
80105c43:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c46:	8a 00                	mov    (%eax),%al
80105c48:	0f b6 c0             	movzbl %al,%eax
80105c4b:	29 c2                	sub    %eax,%edx
80105c4d:	89 d0                	mov    %edx,%eax
80105c4f:	eb 18                	jmp    80105c69 <memcmp+0x50>
    s1++, s2++;
80105c51:	ff 45 fc             	incl   -0x4(%ebp)
80105c54:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105c57:	8b 45 10             	mov    0x10(%ebp),%eax
80105c5a:	8d 50 ff             	lea    -0x1(%eax),%edx
80105c5d:	89 55 10             	mov    %edx,0x10(%ebp)
80105c60:	85 c0                	test   %eax,%eax
80105c62:	75 c9                	jne    80105c2d <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105c64:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c69:	c9                   	leave  
80105c6a:	c3                   	ret    

80105c6b <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105c6b:	55                   	push   %ebp
80105c6c:	89 e5                	mov    %esp,%ebp
80105c6e:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105c71:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c74:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105c77:	8b 45 08             	mov    0x8(%ebp),%eax
80105c7a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105c7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c80:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105c83:	73 3a                	jae    80105cbf <memmove+0x54>
80105c85:	8b 45 10             	mov    0x10(%ebp),%eax
80105c88:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105c8b:	01 d0                	add    %edx,%eax
80105c8d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105c90:	76 2d                	jbe    80105cbf <memmove+0x54>
    s += n;
80105c92:	8b 45 10             	mov    0x10(%ebp),%eax
80105c95:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105c98:	8b 45 10             	mov    0x10(%ebp),%eax
80105c9b:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105c9e:	eb 10                	jmp    80105cb0 <memmove+0x45>
      *--d = *--s;
80105ca0:	ff 4d f8             	decl   -0x8(%ebp)
80105ca3:	ff 4d fc             	decl   -0x4(%ebp)
80105ca6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ca9:	8a 10                	mov    (%eax),%dl
80105cab:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105cae:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105cb0:	8b 45 10             	mov    0x10(%ebp),%eax
80105cb3:	8d 50 ff             	lea    -0x1(%eax),%edx
80105cb6:	89 55 10             	mov    %edx,0x10(%ebp)
80105cb9:	85 c0                	test   %eax,%eax
80105cbb:	75 e3                	jne    80105ca0 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105cbd:	eb 25                	jmp    80105ce4 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105cbf:	eb 16                	jmp    80105cd7 <memmove+0x6c>
      *d++ = *s++;
80105cc1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105cc4:	8d 50 01             	lea    0x1(%eax),%edx
80105cc7:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105cca:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ccd:	8d 4a 01             	lea    0x1(%edx),%ecx
80105cd0:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105cd3:	8a 12                	mov    (%edx),%dl
80105cd5:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105cd7:	8b 45 10             	mov    0x10(%ebp),%eax
80105cda:	8d 50 ff             	lea    -0x1(%eax),%edx
80105cdd:	89 55 10             	mov    %edx,0x10(%ebp)
80105ce0:	85 c0                	test   %eax,%eax
80105ce2:	75 dd                	jne    80105cc1 <memmove+0x56>
      *d++ = *s++;

  return dst;
80105ce4:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105ce7:	c9                   	leave  
80105ce8:	c3                   	ret    

80105ce9 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105ce9:	55                   	push   %ebp
80105cea:	89 e5                	mov    %esp,%ebp
80105cec:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105cef:	8b 45 10             	mov    0x10(%ebp),%eax
80105cf2:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cf9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cfd:	8b 45 08             	mov    0x8(%ebp),%eax
80105d00:	89 04 24             	mov    %eax,(%esp)
80105d03:	e8 63 ff ff ff       	call   80105c6b <memmove>
}
80105d08:	c9                   	leave  
80105d09:	c3                   	ret    

80105d0a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105d0a:	55                   	push   %ebp
80105d0b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105d0d:	eb 09                	jmp    80105d18 <strncmp+0xe>
    n--, p++, q++;
80105d0f:	ff 4d 10             	decl   0x10(%ebp)
80105d12:	ff 45 08             	incl   0x8(%ebp)
80105d15:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105d18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105d1c:	74 17                	je     80105d35 <strncmp+0x2b>
80105d1e:	8b 45 08             	mov    0x8(%ebp),%eax
80105d21:	8a 00                	mov    (%eax),%al
80105d23:	84 c0                	test   %al,%al
80105d25:	74 0e                	je     80105d35 <strncmp+0x2b>
80105d27:	8b 45 08             	mov    0x8(%ebp),%eax
80105d2a:	8a 10                	mov    (%eax),%dl
80105d2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d2f:	8a 00                	mov    (%eax),%al
80105d31:	38 c2                	cmp    %al,%dl
80105d33:	74 da                	je     80105d0f <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105d35:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105d39:	75 07                	jne    80105d42 <strncmp+0x38>
    return 0;
80105d3b:	b8 00 00 00 00       	mov    $0x0,%eax
80105d40:	eb 14                	jmp    80105d56 <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
80105d42:	8b 45 08             	mov    0x8(%ebp),%eax
80105d45:	8a 00                	mov    (%eax),%al
80105d47:	0f b6 d0             	movzbl %al,%edx
80105d4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d4d:	8a 00                	mov    (%eax),%al
80105d4f:	0f b6 c0             	movzbl %al,%eax
80105d52:	29 c2                	sub    %eax,%edx
80105d54:	89 d0                	mov    %edx,%eax
}
80105d56:	5d                   	pop    %ebp
80105d57:	c3                   	ret    

80105d58 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105d58:	55                   	push   %ebp
80105d59:	89 e5                	mov    %esp,%ebp
80105d5b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105d5e:	8b 45 08             	mov    0x8(%ebp),%eax
80105d61:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105d64:	90                   	nop
80105d65:	8b 45 10             	mov    0x10(%ebp),%eax
80105d68:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d6b:	89 55 10             	mov    %edx,0x10(%ebp)
80105d6e:	85 c0                	test   %eax,%eax
80105d70:	7e 1c                	jle    80105d8e <strncpy+0x36>
80105d72:	8b 45 08             	mov    0x8(%ebp),%eax
80105d75:	8d 50 01             	lea    0x1(%eax),%edx
80105d78:	89 55 08             	mov    %edx,0x8(%ebp)
80105d7b:	8b 55 0c             	mov    0xc(%ebp),%edx
80105d7e:	8d 4a 01             	lea    0x1(%edx),%ecx
80105d81:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105d84:	8a 12                	mov    (%edx),%dl
80105d86:	88 10                	mov    %dl,(%eax)
80105d88:	8a 00                	mov    (%eax),%al
80105d8a:	84 c0                	test   %al,%al
80105d8c:	75 d7                	jne    80105d65 <strncpy+0xd>
    ;
  while(n-- > 0)
80105d8e:	eb 0c                	jmp    80105d9c <strncpy+0x44>
    *s++ = 0;
80105d90:	8b 45 08             	mov    0x8(%ebp),%eax
80105d93:	8d 50 01             	lea    0x1(%eax),%edx
80105d96:	89 55 08             	mov    %edx,0x8(%ebp)
80105d99:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105d9c:	8b 45 10             	mov    0x10(%ebp),%eax
80105d9f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105da2:	89 55 10             	mov    %edx,0x10(%ebp)
80105da5:	85 c0                	test   %eax,%eax
80105da7:	7f e7                	jg     80105d90 <strncpy+0x38>
    *s++ = 0;
  return os;
80105da9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105dac:	c9                   	leave  
80105dad:	c3                   	ret    

80105dae <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105dae:	55                   	push   %ebp
80105daf:	89 e5                	mov    %esp,%ebp
80105db1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105db4:	8b 45 08             	mov    0x8(%ebp),%eax
80105db7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105dba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105dbe:	7f 05                	jg     80105dc5 <safestrcpy+0x17>
    return os;
80105dc0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105dc3:	eb 2e                	jmp    80105df3 <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
80105dc5:	ff 4d 10             	decl   0x10(%ebp)
80105dc8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105dcc:	7e 1c                	jle    80105dea <safestrcpy+0x3c>
80105dce:	8b 45 08             	mov    0x8(%ebp),%eax
80105dd1:	8d 50 01             	lea    0x1(%eax),%edx
80105dd4:	89 55 08             	mov    %edx,0x8(%ebp)
80105dd7:	8b 55 0c             	mov    0xc(%ebp),%edx
80105dda:	8d 4a 01             	lea    0x1(%edx),%ecx
80105ddd:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105de0:	8a 12                	mov    (%edx),%dl
80105de2:	88 10                	mov    %dl,(%eax)
80105de4:	8a 00                	mov    (%eax),%al
80105de6:	84 c0                	test   %al,%al
80105de8:	75 db                	jne    80105dc5 <safestrcpy+0x17>
    ;
  *s = 0;
80105dea:	8b 45 08             	mov    0x8(%ebp),%eax
80105ded:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105df0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105df3:	c9                   	leave  
80105df4:	c3                   	ret    

80105df5 <strlen>:

int
strlen(const char *s)
{
80105df5:	55                   	push   %ebp
80105df6:	89 e5                	mov    %esp,%ebp
80105df8:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105dfb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105e02:	eb 03                	jmp    80105e07 <strlen+0x12>
80105e04:	ff 45 fc             	incl   -0x4(%ebp)
80105e07:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80105e0d:	01 d0                	add    %edx,%eax
80105e0f:	8a 00                	mov    (%eax),%al
80105e11:	84 c0                	test   %al,%al
80105e13:	75 ef                	jne    80105e04 <strlen+0xf>
    ;
  return n;
80105e15:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105e18:	c9                   	leave  
80105e19:	c3                   	ret    
	...

80105e1c <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105e1c:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105e20:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105e24:	55                   	push   %ebp
  pushl %ebx
80105e25:	53                   	push   %ebx
  pushl %esi
80105e26:	56                   	push   %esi
  pushl %edi
80105e27:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105e28:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105e2a:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105e2c:	5f                   	pop    %edi
  popl %esi
80105e2d:	5e                   	pop    %esi
  popl %ebx
80105e2e:	5b                   	pop    %ebx
  popl %ebp
80105e2f:	5d                   	pop    %ebp
  ret
80105e30:	c3                   	ret    
80105e31:	00 00                	add    %al,(%eax)
	...

80105e34 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105e34:	55                   	push   %ebp
80105e35:	89 e5                	mov    %esp,%ebp
80105e37:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105e3a:	e8 c1 e4 ff ff       	call   80104300 <myproc>
80105e3f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105e42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e45:	8b 00                	mov    (%eax),%eax
80105e47:	3b 45 08             	cmp    0x8(%ebp),%eax
80105e4a:	76 0f                	jbe    80105e5b <fetchint+0x27>
80105e4c:	8b 45 08             	mov    0x8(%ebp),%eax
80105e4f:	8d 50 04             	lea    0x4(%eax),%edx
80105e52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e55:	8b 00                	mov    (%eax),%eax
80105e57:	39 c2                	cmp    %eax,%edx
80105e59:	76 07                	jbe    80105e62 <fetchint+0x2e>
    return -1;
80105e5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e60:	eb 0f                	jmp    80105e71 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105e62:	8b 45 08             	mov    0x8(%ebp),%eax
80105e65:	8b 10                	mov    (%eax),%edx
80105e67:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e6a:	89 10                	mov    %edx,(%eax)
  return 0;
80105e6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e71:	c9                   	leave  
80105e72:	c3                   	ret    

80105e73 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105e73:	55                   	push   %ebp
80105e74:	89 e5                	mov    %esp,%ebp
80105e76:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105e79:	e8 82 e4 ff ff       	call   80104300 <myproc>
80105e7e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105e81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e84:	8b 00                	mov    (%eax),%eax
80105e86:	3b 45 08             	cmp    0x8(%ebp),%eax
80105e89:	77 07                	ja     80105e92 <fetchstr+0x1f>
    return -1;
80105e8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e90:	eb 41                	jmp    80105ed3 <fetchstr+0x60>
  *pp = (char*)addr;
80105e92:	8b 55 08             	mov    0x8(%ebp),%edx
80105e95:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e98:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105e9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e9d:	8b 00                	mov    (%eax),%eax
80105e9f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ea5:	8b 00                	mov    (%eax),%eax
80105ea7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105eaa:	eb 1a                	jmp    80105ec6 <fetchstr+0x53>
    if(*s == 0)
80105eac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eaf:	8a 00                	mov    (%eax),%al
80105eb1:	84 c0                	test   %al,%al
80105eb3:	75 0e                	jne    80105ec3 <fetchstr+0x50>
      return s - *pp;
80105eb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ebb:	8b 00                	mov    (%eax),%eax
80105ebd:	29 c2                	sub    %eax,%edx
80105ebf:	89 d0                	mov    %edx,%eax
80105ec1:	eb 10                	jmp    80105ed3 <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
80105ec3:	ff 45 f4             	incl   -0xc(%ebp)
80105ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ec9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105ecc:	72 de                	jb     80105eac <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
80105ece:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ed3:	c9                   	leave  
80105ed4:	c3                   	ret    

80105ed5 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105ed5:	55                   	push   %ebp
80105ed6:	89 e5                	mov    %esp,%ebp
80105ed8:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105edb:	e8 20 e4 ff ff       	call   80104300 <myproc>
80105ee0:	8b 40 18             	mov    0x18(%eax),%eax
80105ee3:	8b 50 44             	mov    0x44(%eax),%edx
80105ee6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ee9:	c1 e0 02             	shl    $0x2,%eax
80105eec:	01 d0                	add    %edx,%eax
80105eee:	8d 50 04             	lea    0x4(%eax),%edx
80105ef1:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ef4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ef8:	89 14 24             	mov    %edx,(%esp)
80105efb:	e8 34 ff ff ff       	call   80105e34 <fetchint>
}
80105f00:	c9                   	leave  
80105f01:	c3                   	ret    

80105f02 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105f02:	55                   	push   %ebp
80105f03:	89 e5                	mov    %esp,%ebp
80105f05:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
80105f08:	e8 f3 e3 ff ff       	call   80104300 <myproc>
80105f0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105f10:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f13:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f17:	8b 45 08             	mov    0x8(%ebp),%eax
80105f1a:	89 04 24             	mov    %eax,(%esp)
80105f1d:	e8 b3 ff ff ff       	call   80105ed5 <argint>
80105f22:	85 c0                	test   %eax,%eax
80105f24:	79 07                	jns    80105f2d <argptr+0x2b>
    return -1;
80105f26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f2b:	eb 3d                	jmp    80105f6a <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105f2d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105f31:	78 21                	js     80105f54 <argptr+0x52>
80105f33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f36:	89 c2                	mov    %eax,%edx
80105f38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f3b:	8b 00                	mov    (%eax),%eax
80105f3d:	39 c2                	cmp    %eax,%edx
80105f3f:	73 13                	jae    80105f54 <argptr+0x52>
80105f41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f44:	89 c2                	mov    %eax,%edx
80105f46:	8b 45 10             	mov    0x10(%ebp),%eax
80105f49:	01 c2                	add    %eax,%edx
80105f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4e:	8b 00                	mov    (%eax),%eax
80105f50:	39 c2                	cmp    %eax,%edx
80105f52:	76 07                	jbe    80105f5b <argptr+0x59>
    return -1;
80105f54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f59:	eb 0f                	jmp    80105f6a <argptr+0x68>
  *pp = (char*)i;
80105f5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f5e:	89 c2                	mov    %eax,%edx
80105f60:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f63:	89 10                	mov    %edx,(%eax)
  return 0;
80105f65:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f6a:	c9                   	leave  
80105f6b:	c3                   	ret    

80105f6c <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105f6c:	55                   	push   %ebp
80105f6d:	89 e5                	mov    %esp,%ebp
80105f6f:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105f72:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f75:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f79:	8b 45 08             	mov    0x8(%ebp),%eax
80105f7c:	89 04 24             	mov    %eax,(%esp)
80105f7f:	e8 51 ff ff ff       	call   80105ed5 <argint>
80105f84:	85 c0                	test   %eax,%eax
80105f86:	79 07                	jns    80105f8f <argstr+0x23>
    return -1;
80105f88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f8d:	eb 12                	jmp    80105fa1 <argstr+0x35>
  return fetchstr(addr, pp);
80105f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f92:	8b 55 0c             	mov    0xc(%ebp),%edx
80105f95:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f99:	89 04 24             	mov    %eax,(%esp)
80105f9c:	e8 d2 fe ff ff       	call   80105e73 <fetchstr>
}
80105fa1:	c9                   	leave  
80105fa2:	c3                   	ret    

80105fa3 <syscall>:
[SYS_cinfo] sys_cinfo,
};

void
syscall(void)
{
80105fa3:	55                   	push   %ebp
80105fa4:	89 e5                	mov    %esp,%ebp
80105fa6:	53                   	push   %ebx
80105fa7:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
80105faa:	e8 51 e3 ff ff       	call   80104300 <myproc>
80105faf:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fb5:	8b 40 18             	mov    0x18(%eax),%eax
80105fb8:	8b 40 1c             	mov    0x1c(%eax),%eax
80105fbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105fbe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fc2:	7e 2d                	jle    80105ff1 <syscall+0x4e>
80105fc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fc7:	83 f8 1b             	cmp    $0x1b,%eax
80105fca:	77 25                	ja     80105ff1 <syscall+0x4e>
80105fcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fcf:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105fd6:	85 c0                	test   %eax,%eax
80105fd8:	74 17                	je     80105ff1 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105fda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fdd:	8b 58 18             	mov    0x18(%eax),%ebx
80105fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe3:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105fea:	ff d0                	call   *%eax
80105fec:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105fef:	eb 34                	jmp    80106025 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ff4:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ffa:	8b 40 10             	mov    0x10(%eax),%eax
80105ffd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106000:	89 54 24 0c          	mov    %edx,0xc(%esp)
80106004:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106008:	89 44 24 04          	mov    %eax,0x4(%esp)
8010600c:	c7 04 24 78 99 10 80 	movl   $0x80109978,(%esp)
80106013:	e8 a9 a3 ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80106018:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010601b:	8b 40 18             	mov    0x18(%eax),%eax
8010601e:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80106025:	83 c4 24             	add    $0x24,%esp
80106028:	5b                   	pop    %ebx
80106029:	5d                   	pop    %ebp
8010602a:	c3                   	ret    
	...

8010602c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010602c:	55                   	push   %ebp
8010602d:	89 e5                	mov    %esp,%ebp
8010602f:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80106032:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106035:	89 44 24 04          	mov    %eax,0x4(%esp)
80106039:	8b 45 08             	mov    0x8(%ebp),%eax
8010603c:	89 04 24             	mov    %eax,(%esp)
8010603f:	e8 91 fe ff ff       	call   80105ed5 <argint>
80106044:	85 c0                	test   %eax,%eax
80106046:	79 07                	jns    8010604f <argfd+0x23>
    return -1;
80106048:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010604d:	eb 4f                	jmp    8010609e <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010604f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106052:	85 c0                	test   %eax,%eax
80106054:	78 20                	js     80106076 <argfd+0x4a>
80106056:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106059:	83 f8 0f             	cmp    $0xf,%eax
8010605c:	7f 18                	jg     80106076 <argfd+0x4a>
8010605e:	e8 9d e2 ff ff       	call   80104300 <myproc>
80106063:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106066:	83 c2 08             	add    $0x8,%edx
80106069:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010606d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106070:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106074:	75 07                	jne    8010607d <argfd+0x51>
    return -1;
80106076:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010607b:	eb 21                	jmp    8010609e <argfd+0x72>
  if(pfd)
8010607d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106081:	74 08                	je     8010608b <argfd+0x5f>
    *pfd = fd;
80106083:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106086:	8b 45 0c             	mov    0xc(%ebp),%eax
80106089:	89 10                	mov    %edx,(%eax)
  if(pf)
8010608b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010608f:	74 08                	je     80106099 <argfd+0x6d>
    *pf = f;
80106091:	8b 45 10             	mov    0x10(%ebp),%eax
80106094:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106097:	89 10                	mov    %edx,(%eax)
  return 0;
80106099:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010609e:	c9                   	leave  
8010609f:	c3                   	ret    

801060a0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801060a0:	55                   	push   %ebp
801060a1:	89 e5                	mov    %esp,%ebp
801060a3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
801060a6:	e8 55 e2 ff ff       	call   80104300 <myproc>
801060ab:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
801060ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801060b5:	eb 29                	jmp    801060e0 <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
801060b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060bd:	83 c2 08             	add    $0x8,%edx
801060c0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801060c4:	85 c0                	test   %eax,%eax
801060c6:	75 15                	jne    801060dd <fdalloc+0x3d>
      curproc->ofile[fd] = f;
801060c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801060ce:	8d 4a 08             	lea    0x8(%edx),%ecx
801060d1:	8b 55 08             	mov    0x8(%ebp),%edx
801060d4:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
801060d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060db:	eb 0e                	jmp    801060eb <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
801060dd:	ff 45 f4             	incl   -0xc(%ebp)
801060e0:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801060e4:	7e d1                	jle    801060b7 <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801060e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060eb:	c9                   	leave  
801060ec:	c3                   	ret    

801060ed <sys_dup>:

int
sys_dup(void)
{
801060ed:	55                   	push   %ebp
801060ee:	89 e5                	mov    %esp,%ebp
801060f0:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801060f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060f6:	89 44 24 08          	mov    %eax,0x8(%esp)
801060fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106101:	00 
80106102:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106109:	e8 1e ff ff ff       	call   8010602c <argfd>
8010610e:	85 c0                	test   %eax,%eax
80106110:	79 07                	jns    80106119 <sys_dup+0x2c>
    return -1;
80106112:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106117:	eb 29                	jmp    80106142 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80106119:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010611c:	89 04 24             	mov    %eax,(%esp)
8010611f:	e8 7c ff ff ff       	call   801060a0 <fdalloc>
80106124:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106127:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010612b:	79 07                	jns    80106134 <sys_dup+0x47>
    return -1;
8010612d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106132:	eb 0e                	jmp    80106142 <sys_dup+0x55>
  filedup(f);
80106134:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106137:	89 04 24             	mov    %eax,(%esp)
8010613a:	e8 fd af ff ff       	call   8010113c <filedup>
  return fd;
8010613f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106142:	c9                   	leave  
80106143:	c3                   	ret    

80106144 <sys_read>:

int
sys_read(void)
{
80106144:	55                   	push   %ebp
80106145:	89 e5                	mov    %esp,%ebp
80106147:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010614a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010614d:	89 44 24 08          	mov    %eax,0x8(%esp)
80106151:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106158:	00 
80106159:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106160:	e8 c7 fe ff ff       	call   8010602c <argfd>
80106165:	85 c0                	test   %eax,%eax
80106167:	78 35                	js     8010619e <sys_read+0x5a>
80106169:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010616c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106170:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106177:	e8 59 fd ff ff       	call   80105ed5 <argint>
8010617c:	85 c0                	test   %eax,%eax
8010617e:	78 1e                	js     8010619e <sys_read+0x5a>
80106180:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106183:	89 44 24 08          	mov    %eax,0x8(%esp)
80106187:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010618a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010618e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106195:	e8 68 fd ff ff       	call   80105f02 <argptr>
8010619a:	85 c0                	test   %eax,%eax
8010619c:	79 07                	jns    801061a5 <sys_read+0x61>
    return -1;
8010619e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061a3:	eb 19                	jmp    801061be <sys_read+0x7a>
  return fileread(f, p, n);
801061a5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801061a8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801061ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ae:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801061b2:	89 54 24 04          	mov    %edx,0x4(%esp)
801061b6:	89 04 24             	mov    %eax,(%esp)
801061b9:	e8 df b0 ff ff       	call   8010129d <fileread>
}
801061be:	c9                   	leave  
801061bf:	c3                   	ret    

801061c0 <sys_write>:

int
sys_write(void)
{
801061c0:	55                   	push   %ebp
801061c1:	89 e5                	mov    %esp,%ebp
801061c3:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801061c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801061c9:	89 44 24 08          	mov    %eax,0x8(%esp)
801061cd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801061d4:	00 
801061d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801061dc:	e8 4b fe ff ff       	call   8010602c <argfd>
801061e1:	85 c0                	test   %eax,%eax
801061e3:	78 35                	js     8010621a <sys_write+0x5a>
801061e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061e8:	89 44 24 04          	mov    %eax,0x4(%esp)
801061ec:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801061f3:	e8 dd fc ff ff       	call   80105ed5 <argint>
801061f8:	85 c0                	test   %eax,%eax
801061fa:	78 1e                	js     8010621a <sys_write+0x5a>
801061fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061ff:	89 44 24 08          	mov    %eax,0x8(%esp)
80106203:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106206:	89 44 24 04          	mov    %eax,0x4(%esp)
8010620a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106211:	e8 ec fc ff ff       	call   80105f02 <argptr>
80106216:	85 c0                	test   %eax,%eax
80106218:	79 07                	jns    80106221 <sys_write+0x61>
    return -1;
8010621a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010621f:	eb 19                	jmp    8010623a <sys_write+0x7a>
  return filewrite(f, p, n);
80106221:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106224:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106227:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010622e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106232:	89 04 24             	mov    %eax,(%esp)
80106235:	e8 1e b1 ff ff       	call   80101358 <filewrite>
}
8010623a:	c9                   	leave  
8010623b:	c3                   	ret    

8010623c <sys_close>:

int
sys_close(void)
{
8010623c:	55                   	push   %ebp
8010623d:	89 e5                	mov    %esp,%ebp
8010623f:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80106242:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106245:	89 44 24 08          	mov    %eax,0x8(%esp)
80106249:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010624c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106250:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106257:	e8 d0 fd ff ff       	call   8010602c <argfd>
8010625c:	85 c0                	test   %eax,%eax
8010625e:	79 07                	jns    80106267 <sys_close+0x2b>
    return -1;
80106260:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106265:	eb 23                	jmp    8010628a <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
80106267:	e8 94 e0 ff ff       	call   80104300 <myproc>
8010626c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010626f:	83 c2 08             	add    $0x8,%edx
80106272:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106279:	00 
  fileclose(f);
8010627a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010627d:	89 04 24             	mov    %eax,(%esp)
80106280:	e8 ff ae ff ff       	call   80101184 <fileclose>
  return 0;
80106285:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010628a:	c9                   	leave  
8010628b:	c3                   	ret    

8010628c <sys_fstat>:

int
sys_fstat(void)
{
8010628c:	55                   	push   %ebp
8010628d:	89 e5                	mov    %esp,%ebp
8010628f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80106292:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106295:	89 44 24 08          	mov    %eax,0x8(%esp)
80106299:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801062a0:	00 
801062a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062a8:	e8 7f fd ff ff       	call   8010602c <argfd>
801062ad:	85 c0                	test   %eax,%eax
801062af:	78 1f                	js     801062d0 <sys_fstat+0x44>
801062b1:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801062b8:	00 
801062b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801062bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801062c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801062c7:	e8 36 fc ff ff       	call   80105f02 <argptr>
801062cc:	85 c0                	test   %eax,%eax
801062ce:	79 07                	jns    801062d7 <sys_fstat+0x4b>
    return -1;
801062d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062d5:	eb 12                	jmp    801062e9 <sys_fstat+0x5d>
  return filestat(f, st);
801062d7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062dd:	89 54 24 04          	mov    %edx,0x4(%esp)
801062e1:	89 04 24             	mov    %eax,(%esp)
801062e4:	e8 65 af ff ff       	call   8010124e <filestat>
}
801062e9:	c9                   	leave  
801062ea:	c3                   	ret    

801062eb <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801062eb:	55                   	push   %ebp
801062ec:	89 e5                	mov    %esp,%ebp
801062ee:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801062f1:	8d 45 d8             	lea    -0x28(%ebp),%eax
801062f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801062f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062ff:	e8 68 fc ff ff       	call   80105f6c <argstr>
80106304:	85 c0                	test   %eax,%eax
80106306:	78 17                	js     8010631f <sys_link+0x34>
80106308:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010630b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010630f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106316:	e8 51 fc ff ff       	call   80105f6c <argstr>
8010631b:	85 c0                	test   %eax,%eax
8010631d:	79 0a                	jns    80106329 <sys_link+0x3e>
    return -1;
8010631f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106324:	e9 3d 01 00 00       	jmp    80106466 <sys_link+0x17b>

  begin_op();
80106329:	e8 d5 d3 ff ff       	call   80103703 <begin_op>
  if((ip = namei(old)) == 0){
8010632e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106331:	89 04 24             	mov    %eax,(%esp)
80106334:	e8 f4 c3 ff ff       	call   8010272d <namei>
80106339:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010633c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106340:	75 0f                	jne    80106351 <sys_link+0x66>
    end_op();
80106342:	e8 3e d4 ff ff       	call   80103785 <end_op>
    return -1;
80106347:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010634c:	e9 15 01 00 00       	jmp    80106466 <sys_link+0x17b>
  }

  ilock(ip);
80106351:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106354:	89 04 24             	mov    %eax,(%esp)
80106357:	e8 42 b7 ff ff       	call   80101a9e <ilock>
  if(ip->type == T_DIR){
8010635c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010635f:	8b 40 50             	mov    0x50(%eax),%eax
80106362:	66 83 f8 01          	cmp    $0x1,%ax
80106366:	75 1a                	jne    80106382 <sys_link+0x97>
    iunlockput(ip);
80106368:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010636b:	89 04 24             	mov    %eax,(%esp)
8010636e:	e8 2a b9 ff ff       	call   80101c9d <iunlockput>
    end_op();
80106373:	e8 0d d4 ff ff       	call   80103785 <end_op>
    return -1;
80106378:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010637d:	e9 e4 00 00 00       	jmp    80106466 <sys_link+0x17b>
  }

  ip->nlink++;
80106382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106385:	66 8b 40 56          	mov    0x56(%eax),%ax
80106389:	40                   	inc    %eax
8010638a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010638d:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80106391:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106394:	89 04 24             	mov    %eax,(%esp)
80106397:	e8 3f b5 ff ff       	call   801018db <iupdate>
  iunlock(ip);
8010639c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010639f:	89 04 24             	mov    %eax,(%esp)
801063a2:	e8 01 b8 ff ff       	call   80101ba8 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
801063a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801063aa:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801063ad:	89 54 24 04          	mov    %edx,0x4(%esp)
801063b1:	89 04 24             	mov    %eax,(%esp)
801063b4:	e8 96 c3 ff ff       	call   8010274f <nameiparent>
801063b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063c0:	75 02                	jne    801063c4 <sys_link+0xd9>
    goto bad;
801063c2:	eb 68                	jmp    8010642c <sys_link+0x141>
  ilock(dp);
801063c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c7:	89 04 24             	mov    %eax,(%esp)
801063ca:	e8 cf b6 ff ff       	call   80101a9e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801063cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d2:	8b 10                	mov    (%eax),%edx
801063d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063d7:	8b 00                	mov    (%eax),%eax
801063d9:	39 c2                	cmp    %eax,%edx
801063db:	75 20                	jne    801063fd <sys_link+0x112>
801063dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063e0:	8b 40 04             	mov    0x4(%eax),%eax
801063e3:	89 44 24 08          	mov    %eax,0x8(%esp)
801063e7:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801063ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801063ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063f1:	89 04 24             	mov    %eax,(%esp)
801063f4:	e8 17 bf ff ff       	call   80102310 <dirlink>
801063f9:	85 c0                	test   %eax,%eax
801063fb:	79 0d                	jns    8010640a <sys_link+0x11f>
    iunlockput(dp);
801063fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106400:	89 04 24             	mov    %eax,(%esp)
80106403:	e8 95 b8 ff ff       	call   80101c9d <iunlockput>
    goto bad;
80106408:	eb 22                	jmp    8010642c <sys_link+0x141>
  }
  iunlockput(dp);
8010640a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010640d:	89 04 24             	mov    %eax,(%esp)
80106410:	e8 88 b8 ff ff       	call   80101c9d <iunlockput>
  iput(ip);
80106415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106418:	89 04 24             	mov    %eax,(%esp)
8010641b:	e8 cc b7 ff ff       	call   80101bec <iput>

  end_op();
80106420:	e8 60 d3 ff ff       	call   80103785 <end_op>

  return 0;
80106425:	b8 00 00 00 00       	mov    $0x0,%eax
8010642a:	eb 3a                	jmp    80106466 <sys_link+0x17b>

bad:
  ilock(ip);
8010642c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010642f:	89 04 24             	mov    %eax,(%esp)
80106432:	e8 67 b6 ff ff       	call   80101a9e <ilock>
  ip->nlink--;
80106437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010643a:	66 8b 40 56          	mov    0x56(%eax),%ax
8010643e:	48                   	dec    %eax
8010643f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106442:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80106446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106449:	89 04 24             	mov    %eax,(%esp)
8010644c:	e8 8a b4 ff ff       	call   801018db <iupdate>
  iunlockput(ip);
80106451:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106454:	89 04 24             	mov    %eax,(%esp)
80106457:	e8 41 b8 ff ff       	call   80101c9d <iunlockput>
  end_op();
8010645c:	e8 24 d3 ff ff       	call   80103785 <end_op>
  return -1;
80106461:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106466:	c9                   	leave  
80106467:	c3                   	ret    

80106468 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80106468:	55                   	push   %ebp
80106469:	89 e5                	mov    %esp,%ebp
8010646b:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010646e:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80106475:	eb 4a                	jmp    801064c1 <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106477:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010647a:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106481:	00 
80106482:	89 44 24 08          	mov    %eax,0x8(%esp)
80106486:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106489:	89 44 24 04          	mov    %eax,0x4(%esp)
8010648d:	8b 45 08             	mov    0x8(%ebp),%eax
80106490:	89 04 24             	mov    %eax,(%esp)
80106493:	e8 9d ba ff ff       	call   80101f35 <readi>
80106498:	83 f8 10             	cmp    $0x10,%eax
8010649b:	74 0c                	je     801064a9 <isdirempty+0x41>
      panic("isdirempty: readi");
8010649d:	c7 04 24 94 99 10 80 	movl   $0x80109994,(%esp)
801064a4:	e8 ab a0 ff ff       	call   80100554 <panic>
    if(de.inum != 0)
801064a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064ac:	66 85 c0             	test   %ax,%ax
801064af:	74 07                	je     801064b8 <isdirempty+0x50>
      return 0;
801064b1:	b8 00 00 00 00       	mov    $0x0,%eax
801064b6:	eb 1b                	jmp    801064d3 <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801064b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064bb:	83 c0 10             	add    $0x10,%eax
801064be:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064c4:	8b 45 08             	mov    0x8(%ebp),%eax
801064c7:	8b 40 58             	mov    0x58(%eax),%eax
801064ca:	39 c2                	cmp    %eax,%edx
801064cc:	72 a9                	jb     80106477 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801064ce:	b8 01 00 00 00       	mov    $0x1,%eax
}
801064d3:	c9                   	leave  
801064d4:	c3                   	ret    

801064d5 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801064d5:	55                   	push   %ebp
801064d6:	89 e5                	mov    %esp,%ebp
801064d8:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801064db:	8d 45 cc             	lea    -0x34(%ebp),%eax
801064de:	89 44 24 04          	mov    %eax,0x4(%esp)
801064e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064e9:	e8 7e fa ff ff       	call   80105f6c <argstr>
801064ee:	85 c0                	test   %eax,%eax
801064f0:	79 0a                	jns    801064fc <sys_unlink+0x27>
    return -1;
801064f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064f7:	e9 a9 01 00 00       	jmp    801066a5 <sys_unlink+0x1d0>

  begin_op();
801064fc:	e8 02 d2 ff ff       	call   80103703 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106501:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106504:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106507:	89 54 24 04          	mov    %edx,0x4(%esp)
8010650b:	89 04 24             	mov    %eax,(%esp)
8010650e:	e8 3c c2 ff ff       	call   8010274f <nameiparent>
80106513:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106516:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010651a:	75 0f                	jne    8010652b <sys_unlink+0x56>
    end_op();
8010651c:	e8 64 d2 ff ff       	call   80103785 <end_op>
    return -1;
80106521:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106526:	e9 7a 01 00 00       	jmp    801066a5 <sys_unlink+0x1d0>
  }

  ilock(dp);
8010652b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010652e:	89 04 24             	mov    %eax,(%esp)
80106531:	e8 68 b5 ff ff       	call   80101a9e <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106536:	c7 44 24 04 a6 99 10 	movl   $0x801099a6,0x4(%esp)
8010653d:	80 
8010653e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106541:	89 04 24             	mov    %eax,(%esp)
80106544:	e8 df bc ff ff       	call   80102228 <namecmp>
80106549:	85 c0                	test   %eax,%eax
8010654b:	0f 84 3f 01 00 00    	je     80106690 <sys_unlink+0x1bb>
80106551:	c7 44 24 04 a8 99 10 	movl   $0x801099a8,0x4(%esp)
80106558:	80 
80106559:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010655c:	89 04 24             	mov    %eax,(%esp)
8010655f:	e8 c4 bc ff ff       	call   80102228 <namecmp>
80106564:	85 c0                	test   %eax,%eax
80106566:	0f 84 24 01 00 00    	je     80106690 <sys_unlink+0x1bb>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010656c:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010656f:	89 44 24 08          	mov    %eax,0x8(%esp)
80106573:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106576:	89 44 24 04          	mov    %eax,0x4(%esp)
8010657a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010657d:	89 04 24             	mov    %eax,(%esp)
80106580:	e8 c5 bc ff ff       	call   8010224a <dirlookup>
80106585:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106588:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010658c:	75 05                	jne    80106593 <sys_unlink+0xbe>
    goto bad;
8010658e:	e9 fd 00 00 00       	jmp    80106690 <sys_unlink+0x1bb>
  ilock(ip);
80106593:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106596:	89 04 24             	mov    %eax,(%esp)
80106599:	e8 00 b5 ff ff       	call   80101a9e <ilock>

  if(ip->nlink < 1)
8010659e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065a1:	66 8b 40 56          	mov    0x56(%eax),%ax
801065a5:	66 85 c0             	test   %ax,%ax
801065a8:	7f 0c                	jg     801065b6 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
801065aa:	c7 04 24 ab 99 10 80 	movl   $0x801099ab,(%esp)
801065b1:	e8 9e 9f ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801065b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065b9:	8b 40 50             	mov    0x50(%eax),%eax
801065bc:	66 83 f8 01          	cmp    $0x1,%ax
801065c0:	75 1f                	jne    801065e1 <sys_unlink+0x10c>
801065c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065c5:	89 04 24             	mov    %eax,(%esp)
801065c8:	e8 9b fe ff ff       	call   80106468 <isdirempty>
801065cd:	85 c0                	test   %eax,%eax
801065cf:	75 10                	jne    801065e1 <sys_unlink+0x10c>
    iunlockput(ip);
801065d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065d4:	89 04 24             	mov    %eax,(%esp)
801065d7:	e8 c1 b6 ff ff       	call   80101c9d <iunlockput>
    goto bad;
801065dc:	e9 af 00 00 00       	jmp    80106690 <sys_unlink+0x1bb>
  }

  memset(&de, 0, sizeof(de));
801065e1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801065e8:	00 
801065e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801065f0:	00 
801065f1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801065f4:	89 04 24             	mov    %eax,(%esp)
801065f7:	e8 a6 f5 ff ff       	call   80105ba2 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801065fc:	8b 45 c8             	mov    -0x38(%ebp),%eax
801065ff:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106606:	00 
80106607:	89 44 24 08          	mov    %eax,0x8(%esp)
8010660b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010660e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106612:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106615:	89 04 24             	mov    %eax,(%esp)
80106618:	e8 7c ba ff ff       	call   80102099 <writei>
8010661d:	83 f8 10             	cmp    $0x10,%eax
80106620:	74 0c                	je     8010662e <sys_unlink+0x159>
    panic("unlink: writei");
80106622:	c7 04 24 bd 99 10 80 	movl   $0x801099bd,(%esp)
80106629:	e8 26 9f ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR){
8010662e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106631:	8b 40 50             	mov    0x50(%eax),%eax
80106634:	66 83 f8 01          	cmp    $0x1,%ax
80106638:	75 1a                	jne    80106654 <sys_unlink+0x17f>
    dp->nlink--;
8010663a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010663d:	66 8b 40 56          	mov    0x56(%eax),%ax
80106641:	48                   	dec    %eax
80106642:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106645:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80106649:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010664c:	89 04 24             	mov    %eax,(%esp)
8010664f:	e8 87 b2 ff ff       	call   801018db <iupdate>
  }
  iunlockput(dp);
80106654:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106657:	89 04 24             	mov    %eax,(%esp)
8010665a:	e8 3e b6 ff ff       	call   80101c9d <iunlockput>

  ip->nlink--;
8010665f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106662:	66 8b 40 56          	mov    0x56(%eax),%ax
80106666:	48                   	dec    %eax
80106667:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010666a:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
8010666e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106671:	89 04 24             	mov    %eax,(%esp)
80106674:	e8 62 b2 ff ff       	call   801018db <iupdate>
  iunlockput(ip);
80106679:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010667c:	89 04 24             	mov    %eax,(%esp)
8010667f:	e8 19 b6 ff ff       	call   80101c9d <iunlockput>

  end_op();
80106684:	e8 fc d0 ff ff       	call   80103785 <end_op>

  return 0;
80106689:	b8 00 00 00 00       	mov    $0x0,%eax
8010668e:	eb 15                	jmp    801066a5 <sys_unlink+0x1d0>

bad:
  iunlockput(dp);
80106690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106693:	89 04 24             	mov    %eax,(%esp)
80106696:	e8 02 b6 ff ff       	call   80101c9d <iunlockput>
  end_op();
8010669b:	e8 e5 d0 ff ff       	call   80103785 <end_op>
  return -1;
801066a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801066a5:	c9                   	leave  
801066a6:	c3                   	ret    

801066a7 <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
801066a7:	55                   	push   %ebp
801066a8:	89 e5                	mov    %esp,%ebp
801066aa:	83 ec 48             	sub    $0x48,%esp
801066ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801066b0:	8b 55 10             	mov    0x10(%ebp),%edx
801066b3:	8b 45 14             	mov    0x14(%ebp),%eax
801066b6:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801066ba:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801066be:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801066c2:	8d 45 de             	lea    -0x22(%ebp),%eax
801066c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801066c9:	8b 45 08             	mov    0x8(%ebp),%eax
801066cc:	89 04 24             	mov    %eax,(%esp)
801066cf:	e8 7b c0 ff ff       	call   8010274f <nameiparent>
801066d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066db:	75 0a                	jne    801066e7 <create+0x40>
    return 0;
801066dd:	b8 00 00 00 00       	mov    $0x0,%eax
801066e2:	e9 79 01 00 00       	jmp    80106860 <create+0x1b9>
  ilock(dp);
801066e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ea:	89 04 24             	mov    %eax,(%esp)
801066ed:	e8 ac b3 ff ff       	call   80101a9e <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801066f2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066f5:	89 44 24 08          	mov    %eax,0x8(%esp)
801066f9:	8d 45 de             	lea    -0x22(%ebp),%eax
801066fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80106700:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106703:	89 04 24             	mov    %eax,(%esp)
80106706:	e8 3f bb ff ff       	call   8010224a <dirlookup>
8010670b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010670e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106712:	74 46                	je     8010675a <create+0xb3>
    iunlockput(dp);
80106714:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106717:	89 04 24             	mov    %eax,(%esp)
8010671a:	e8 7e b5 ff ff       	call   80101c9d <iunlockput>
    ilock(ip);
8010671f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106722:	89 04 24             	mov    %eax,(%esp)
80106725:	e8 74 b3 ff ff       	call   80101a9e <ilock>
    if(type == T_FILE && ip->type == T_FILE)
8010672a:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010672f:	75 14                	jne    80106745 <create+0x9e>
80106731:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106734:	8b 40 50             	mov    0x50(%eax),%eax
80106737:	66 83 f8 02          	cmp    $0x2,%ax
8010673b:	75 08                	jne    80106745 <create+0x9e>
      return ip;
8010673d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106740:	e9 1b 01 00 00       	jmp    80106860 <create+0x1b9>
    iunlockput(ip);
80106745:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106748:	89 04 24             	mov    %eax,(%esp)
8010674b:	e8 4d b5 ff ff       	call   80101c9d <iunlockput>
    return 0;
80106750:	b8 00 00 00 00       	mov    $0x0,%eax
80106755:	e9 06 01 00 00       	jmp    80106860 <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010675a:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010675e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106761:	8b 00                	mov    (%eax),%eax
80106763:	89 54 24 04          	mov    %edx,0x4(%esp)
80106767:	89 04 24             	mov    %eax,(%esp)
8010676a:	e8 9a b0 ff ff       	call   80101809 <ialloc>
8010676f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106772:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106776:	75 0c                	jne    80106784 <create+0xdd>
    panic("create: ialloc");
80106778:	c7 04 24 cc 99 10 80 	movl   $0x801099cc,(%esp)
8010677f:	e8 d0 9d ff ff       	call   80100554 <panic>

  ilock(ip);
80106784:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106787:	89 04 24             	mov    %eax,(%esp)
8010678a:	e8 0f b3 ff ff       	call   80101a9e <ilock>
  ip->major = major;
8010678f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106792:	8b 45 d0             	mov    -0x30(%ebp),%eax
80106795:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
80106799:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010679c:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010679f:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
801067a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067a6:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801067ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067af:	89 04 24             	mov    %eax,(%esp)
801067b2:	e8 24 b1 ff ff       	call   801018db <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
801067b7:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801067bc:	75 68                	jne    80106826 <create+0x17f>
    dp->nlink++;  // for ".."
801067be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c1:	66 8b 40 56          	mov    0x56(%eax),%ax
801067c5:	40                   	inc    %eax
801067c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067c9:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
801067cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067d0:	89 04 24             	mov    %eax,(%esp)
801067d3:	e8 03 b1 ff ff       	call   801018db <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801067d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067db:	8b 40 04             	mov    0x4(%eax),%eax
801067de:	89 44 24 08          	mov    %eax,0x8(%esp)
801067e2:	c7 44 24 04 a6 99 10 	movl   $0x801099a6,0x4(%esp)
801067e9:	80 
801067ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067ed:	89 04 24             	mov    %eax,(%esp)
801067f0:	e8 1b bb ff ff       	call   80102310 <dirlink>
801067f5:	85 c0                	test   %eax,%eax
801067f7:	78 21                	js     8010681a <create+0x173>
801067f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067fc:	8b 40 04             	mov    0x4(%eax),%eax
801067ff:	89 44 24 08          	mov    %eax,0x8(%esp)
80106803:	c7 44 24 04 a8 99 10 	movl   $0x801099a8,0x4(%esp)
8010680a:	80 
8010680b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010680e:	89 04 24             	mov    %eax,(%esp)
80106811:	e8 fa ba ff ff       	call   80102310 <dirlink>
80106816:	85 c0                	test   %eax,%eax
80106818:	79 0c                	jns    80106826 <create+0x17f>
      panic("create dots");
8010681a:	c7 04 24 db 99 10 80 	movl   $0x801099db,(%esp)
80106821:	e8 2e 9d ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106826:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106829:	8b 40 04             	mov    0x4(%eax),%eax
8010682c:	89 44 24 08          	mov    %eax,0x8(%esp)
80106830:	8d 45 de             	lea    -0x22(%ebp),%eax
80106833:	89 44 24 04          	mov    %eax,0x4(%esp)
80106837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010683a:	89 04 24             	mov    %eax,(%esp)
8010683d:	e8 ce ba ff ff       	call   80102310 <dirlink>
80106842:	85 c0                	test   %eax,%eax
80106844:	79 0c                	jns    80106852 <create+0x1ab>
    panic("create: dirlink");
80106846:	c7 04 24 e7 99 10 80 	movl   $0x801099e7,(%esp)
8010684d:	e8 02 9d ff ff       	call   80100554 <panic>

  iunlockput(dp);
80106852:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106855:	89 04 24             	mov    %eax,(%esp)
80106858:	e8 40 b4 ff ff       	call   80101c9d <iunlockput>

  return ip;
8010685d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106860:	c9                   	leave  
80106861:	c3                   	ret    

80106862 <sys_open>:

int
sys_open(void)
{
80106862:	55                   	push   %ebp
80106863:	89 e5                	mov    %esp,%ebp
80106865:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106868:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010686b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010686f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106876:	e8 f1 f6 ff ff       	call   80105f6c <argstr>
8010687b:	85 c0                	test   %eax,%eax
8010687d:	78 17                	js     80106896 <sys_open+0x34>
8010687f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106882:	89 44 24 04          	mov    %eax,0x4(%esp)
80106886:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010688d:	e8 43 f6 ff ff       	call   80105ed5 <argint>
80106892:	85 c0                	test   %eax,%eax
80106894:	79 0a                	jns    801068a0 <sys_open+0x3e>
    return -1;
80106896:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010689b:	e9 5b 01 00 00       	jmp    801069fb <sys_open+0x199>

  begin_op();
801068a0:	e8 5e ce ff ff       	call   80103703 <begin_op>

  if(omode & O_CREATE){
801068a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801068a8:	25 00 02 00 00       	and    $0x200,%eax
801068ad:	85 c0                	test   %eax,%eax
801068af:	74 3b                	je     801068ec <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
801068b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801068b4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801068bb:	00 
801068bc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801068c3:	00 
801068c4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801068cb:	00 
801068cc:	89 04 24             	mov    %eax,(%esp)
801068cf:	e8 d3 fd ff ff       	call   801066a7 <create>
801068d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801068d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068db:	75 6a                	jne    80106947 <sys_open+0xe5>
      end_op();
801068dd:	e8 a3 ce ff ff       	call   80103785 <end_op>
      return -1;
801068e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068e7:	e9 0f 01 00 00       	jmp    801069fb <sys_open+0x199>
    }
  } else {
    if((ip = namei(path)) == 0){
801068ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
801068ef:	89 04 24             	mov    %eax,(%esp)
801068f2:	e8 36 be ff ff       	call   8010272d <namei>
801068f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801068fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068fe:	75 0f                	jne    8010690f <sys_open+0xad>
      end_op();
80106900:	e8 80 ce ff ff       	call   80103785 <end_op>
      return -1;
80106905:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010690a:	e9 ec 00 00 00       	jmp    801069fb <sys_open+0x199>
    }
    ilock(ip);
8010690f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106912:	89 04 24             	mov    %eax,(%esp)
80106915:	e8 84 b1 ff ff       	call   80101a9e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
8010691a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010691d:	8b 40 50             	mov    0x50(%eax),%eax
80106920:	66 83 f8 01          	cmp    $0x1,%ax
80106924:	75 21                	jne    80106947 <sys_open+0xe5>
80106926:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106929:	85 c0                	test   %eax,%eax
8010692b:	74 1a                	je     80106947 <sys_open+0xe5>
      iunlockput(ip);
8010692d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106930:	89 04 24             	mov    %eax,(%esp)
80106933:	e8 65 b3 ff ff       	call   80101c9d <iunlockput>
      end_op();
80106938:	e8 48 ce ff ff       	call   80103785 <end_op>
      return -1;
8010693d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106942:	e9 b4 00 00 00       	jmp    801069fb <sys_open+0x199>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106947:	e8 90 a7 ff ff       	call   801010dc <filealloc>
8010694c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010694f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106953:	74 14                	je     80106969 <sys_open+0x107>
80106955:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106958:	89 04 24             	mov    %eax,(%esp)
8010695b:	e8 40 f7 ff ff       	call   801060a0 <fdalloc>
80106960:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106963:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106967:	79 28                	jns    80106991 <sys_open+0x12f>
    if(f)
80106969:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010696d:	74 0b                	je     8010697a <sys_open+0x118>
      fileclose(f);
8010696f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106972:	89 04 24             	mov    %eax,(%esp)
80106975:	e8 0a a8 ff ff       	call   80101184 <fileclose>
    iunlockput(ip);
8010697a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010697d:	89 04 24             	mov    %eax,(%esp)
80106980:	e8 18 b3 ff ff       	call   80101c9d <iunlockput>
    end_op();
80106985:	e8 fb cd ff ff       	call   80103785 <end_op>
    return -1;
8010698a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010698f:	eb 6a                	jmp    801069fb <sys_open+0x199>
  }
  iunlock(ip);
80106991:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106994:	89 04 24             	mov    %eax,(%esp)
80106997:	e8 0c b2 ff ff       	call   80101ba8 <iunlock>
  end_op();
8010699c:	e8 e4 cd ff ff       	call   80103785 <end_op>

  f->type = FD_INODE;
801069a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069a4:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801069aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069b0:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801069b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069b6:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801069bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069c0:	83 e0 01             	and    $0x1,%eax
801069c3:	85 c0                	test   %eax,%eax
801069c5:	0f 94 c0             	sete   %al
801069c8:	88 c2                	mov    %al,%dl
801069ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069cd:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801069d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069d3:	83 e0 01             	and    $0x1,%eax
801069d6:	85 c0                	test   %eax,%eax
801069d8:	75 0a                	jne    801069e4 <sys_open+0x182>
801069da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069dd:	83 e0 02             	and    $0x2,%eax
801069e0:	85 c0                	test   %eax,%eax
801069e2:	74 07                	je     801069eb <sys_open+0x189>
801069e4:	b8 01 00 00 00       	mov    $0x1,%eax
801069e9:	eb 05                	jmp    801069f0 <sys_open+0x18e>
801069eb:	b8 00 00 00 00       	mov    $0x0,%eax
801069f0:	88 c2                	mov    %al,%dl
801069f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069f5:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801069f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801069fb:	c9                   	leave  
801069fc:	c3                   	ret    

801069fd <sys_mkdir>:

int
sys_mkdir(void)
{
801069fd:	55                   	push   %ebp
801069fe:	89 e5                	mov    %esp,%ebp
80106a00:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106a03:	e8 fb cc ff ff       	call   80103703 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106a08:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a16:	e8 51 f5 ff ff       	call   80105f6c <argstr>
80106a1b:	85 c0                	test   %eax,%eax
80106a1d:	78 2c                	js     80106a4b <sys_mkdir+0x4e>
80106a1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a22:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106a29:	00 
80106a2a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106a31:	00 
80106a32:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106a39:	00 
80106a3a:	89 04 24             	mov    %eax,(%esp)
80106a3d:	e8 65 fc ff ff       	call   801066a7 <create>
80106a42:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106a45:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a49:	75 0c                	jne    80106a57 <sys_mkdir+0x5a>
    end_op();
80106a4b:	e8 35 cd ff ff       	call   80103785 <end_op>
    return -1;
80106a50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a55:	eb 15                	jmp    80106a6c <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a5a:	89 04 24             	mov    %eax,(%esp)
80106a5d:	e8 3b b2 ff ff       	call   80101c9d <iunlockput>
  end_op();
80106a62:	e8 1e cd ff ff       	call   80103785 <end_op>
  return 0;
80106a67:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a6c:	c9                   	leave  
80106a6d:	c3                   	ret    

80106a6e <sys_mknod>:

int
sys_mknod(void)
{
80106a6e:	55                   	push   %ebp
80106a6f:	89 e5                	mov    %esp,%ebp
80106a71:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106a74:	e8 8a cc ff ff       	call   80103703 <begin_op>
  if((argstr(0, &path)) < 0 ||
80106a79:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a7c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a87:	e8 e0 f4 ff ff       	call   80105f6c <argstr>
80106a8c:	85 c0                	test   %eax,%eax
80106a8e:	78 5e                	js     80106aee <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80106a90:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a93:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a97:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a9e:	e8 32 f4 ff ff       	call   80105ed5 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80106aa3:	85 c0                	test   %eax,%eax
80106aa5:	78 47                	js     80106aee <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106aa7:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106aaa:	89 44 24 04          	mov    %eax,0x4(%esp)
80106aae:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106ab5:	e8 1b f4 ff ff       	call   80105ed5 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106aba:	85 c0                	test   %eax,%eax
80106abc:	78 30                	js     80106aee <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106abe:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106ac1:	0f bf c8             	movswl %ax,%ecx
80106ac4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106ac7:	0f bf d0             	movswl %ax,%edx
80106aca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106acd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106ad1:	89 54 24 08          	mov    %edx,0x8(%esp)
80106ad5:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106adc:	00 
80106add:	89 04 24             	mov    %eax,(%esp)
80106ae0:	e8 c2 fb ff ff       	call   801066a7 <create>
80106ae5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106ae8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106aec:	75 0c                	jne    80106afa <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106aee:	e8 92 cc ff ff       	call   80103785 <end_op>
    return -1;
80106af3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106af8:	eb 15                	jmp    80106b0f <sys_mknod+0xa1>
  }
  iunlockput(ip);
80106afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106afd:	89 04 24             	mov    %eax,(%esp)
80106b00:	e8 98 b1 ff ff       	call   80101c9d <iunlockput>
  end_op();
80106b05:	e8 7b cc ff ff       	call   80103785 <end_op>
  return 0;
80106b0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b0f:	c9                   	leave  
80106b10:	c3                   	ret    

80106b11 <sys_chdir>:

int
sys_chdir(void)
{
80106b11:	55                   	push   %ebp
80106b12:	89 e5                	mov    %esp,%ebp
80106b14:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106b17:	e8 e4 d7 ff ff       	call   80104300 <myproc>
80106b1c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106b1f:	e8 df cb ff ff       	call   80103703 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106b24:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106b27:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b32:	e8 35 f4 ff ff       	call   80105f6c <argstr>
80106b37:	85 c0                	test   %eax,%eax
80106b39:	78 14                	js     80106b4f <sys_chdir+0x3e>
80106b3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106b3e:	89 04 24             	mov    %eax,(%esp)
80106b41:	e8 e7 bb ff ff       	call   8010272d <namei>
80106b46:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106b49:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106b4d:	75 18                	jne    80106b67 <sys_chdir+0x56>
    cprintf("cant pick up path\n");
80106b4f:	c7 04 24 f7 99 10 80 	movl   $0x801099f7,(%esp)
80106b56:	e8 66 98 ff ff       	call   801003c1 <cprintf>
    end_op();
80106b5b:	e8 25 cc ff ff       	call   80103785 <end_op>
    return -1;
80106b60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b65:	eb 66                	jmp    80106bcd <sys_chdir+0xbc>
  }
  ilock(ip);
80106b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b6a:	89 04 24             	mov    %eax,(%esp)
80106b6d:	e8 2c af ff ff       	call   80101a9e <ilock>
  if(ip->type != T_DIR){
80106b72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b75:	8b 40 50             	mov    0x50(%eax),%eax
80106b78:	66 83 f8 01          	cmp    $0x1,%ax
80106b7c:	74 23                	je     80106ba1 <sys_chdir+0x90>
    // TODO: REMOVE
    cprintf("not a dir\n");
80106b7e:	c7 04 24 0a 9a 10 80 	movl   $0x80109a0a,(%esp)
80106b85:	e8 37 98 ff ff       	call   801003c1 <cprintf>
    iunlockput(ip);
80106b8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b8d:	89 04 24             	mov    %eax,(%esp)
80106b90:	e8 08 b1 ff ff       	call   80101c9d <iunlockput>
    end_op();
80106b95:	e8 eb cb ff ff       	call   80103785 <end_op>
    return -1;
80106b9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b9f:	eb 2c                	jmp    80106bcd <sys_chdir+0xbc>
  }
  iunlock(ip);
80106ba1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ba4:	89 04 24             	mov    %eax,(%esp)
80106ba7:	e8 fc af ff ff       	call   80101ba8 <iunlock>
  iput(curproc->cwd);
80106bac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106baf:	8b 40 68             	mov    0x68(%eax),%eax
80106bb2:	89 04 24             	mov    %eax,(%esp)
80106bb5:	e8 32 b0 ff ff       	call   80101bec <iput>
  end_op();
80106bba:	e8 c6 cb ff ff       	call   80103785 <end_op>
  curproc->cwd = ip;
80106bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bc2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106bc5:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106bc8:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106bcd:	c9                   	leave  
80106bce:	c3                   	ret    

80106bcf <sys_exec>:

int
sys_exec(void)
{
80106bcf:	55                   	push   %ebp
80106bd0:	89 e5                	mov    %esp,%ebp
80106bd2:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106bd8:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106bdb:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bdf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106be6:	e8 81 f3 ff ff       	call   80105f6c <argstr>
80106beb:	85 c0                	test   %eax,%eax
80106bed:	78 1a                	js     80106c09 <sys_exec+0x3a>
80106bef:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106bf5:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bf9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106c00:	e8 d0 f2 ff ff       	call   80105ed5 <argint>
80106c05:	85 c0                	test   %eax,%eax
80106c07:	79 0a                	jns    80106c13 <sys_exec+0x44>
    return -1;
80106c09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c0e:	e9 c7 00 00 00       	jmp    80106cda <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
80106c13:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106c1a:	00 
80106c1b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c22:	00 
80106c23:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106c29:	89 04 24             	mov    %eax,(%esp)
80106c2c:	e8 71 ef ff ff       	call   80105ba2 <memset>
  for(i=0;; i++){
80106c31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c3b:	83 f8 1f             	cmp    $0x1f,%eax
80106c3e:	76 0a                	jbe    80106c4a <sys_exec+0x7b>
      return -1;
80106c40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c45:	e9 90 00 00 00       	jmp    80106cda <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106c4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c4d:	c1 e0 02             	shl    $0x2,%eax
80106c50:	89 c2                	mov    %eax,%edx
80106c52:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106c58:	01 c2                	add    %eax,%edx
80106c5a:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106c60:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c64:	89 14 24             	mov    %edx,(%esp)
80106c67:	e8 c8 f1 ff ff       	call   80105e34 <fetchint>
80106c6c:	85 c0                	test   %eax,%eax
80106c6e:	79 07                	jns    80106c77 <sys_exec+0xa8>
      return -1;
80106c70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c75:	eb 63                	jmp    80106cda <sys_exec+0x10b>
    if(uarg == 0){
80106c77:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106c7d:	85 c0                	test   %eax,%eax
80106c7f:	75 26                	jne    80106ca7 <sys_exec+0xd8>
      argv[i] = 0;
80106c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c84:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106c8b:	00 00 00 00 
      break;
80106c8f:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106c90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c93:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106c99:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c9d:	89 04 24             	mov    %eax,(%esp)
80106ca0:	e8 63 9f ff ff       	call   80100c08 <exec>
80106ca5:	eb 33                	jmp    80106cda <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106ca7:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106cad:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106cb0:	c1 e2 02             	shl    $0x2,%edx
80106cb3:	01 c2                	add    %eax,%edx
80106cb5:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106cbb:	89 54 24 04          	mov    %edx,0x4(%esp)
80106cbf:	89 04 24             	mov    %eax,(%esp)
80106cc2:	e8 ac f1 ff ff       	call   80105e73 <fetchstr>
80106cc7:	85 c0                	test   %eax,%eax
80106cc9:	79 07                	jns    80106cd2 <sys_exec+0x103>
      return -1;
80106ccb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cd0:	eb 08                	jmp    80106cda <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106cd2:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106cd5:	e9 5e ff ff ff       	jmp    80106c38 <sys_exec+0x69>
  return exec(path, argv);
}
80106cda:	c9                   	leave  
80106cdb:	c3                   	ret    

80106cdc <sys_pipe>:

int
sys_pipe(void)
{
80106cdc:	55                   	push   %ebp
80106cdd:	89 e5                	mov    %esp,%ebp
80106cdf:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106ce2:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106ce9:	00 
80106cea:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106ced:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cf1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106cf8:	e8 05 f2 ff ff       	call   80105f02 <argptr>
80106cfd:	85 c0                	test   %eax,%eax
80106cff:	79 0a                	jns    80106d0b <sys_pipe+0x2f>
    return -1;
80106d01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d06:	e9 9a 00 00 00       	jmp    80106da5 <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
80106d0b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106d0e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d12:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106d15:	89 04 24             	mov    %eax,(%esp)
80106d18:	e8 33 d2 ff ff       	call   80103f50 <pipealloc>
80106d1d:	85 c0                	test   %eax,%eax
80106d1f:	79 07                	jns    80106d28 <sys_pipe+0x4c>
    return -1;
80106d21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d26:	eb 7d                	jmp    80106da5 <sys_pipe+0xc9>
  fd0 = -1;
80106d28:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106d2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106d32:	89 04 24             	mov    %eax,(%esp)
80106d35:	e8 66 f3 ff ff       	call   801060a0 <fdalloc>
80106d3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106d3d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d41:	78 14                	js     80106d57 <sys_pipe+0x7b>
80106d43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d46:	89 04 24             	mov    %eax,(%esp)
80106d49:	e8 52 f3 ff ff       	call   801060a0 <fdalloc>
80106d4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106d51:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d55:	79 36                	jns    80106d8d <sys_pipe+0xb1>
    if(fd0 >= 0)
80106d57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d5b:	78 13                	js     80106d70 <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
80106d5d:	e8 9e d5 ff ff       	call   80104300 <myproc>
80106d62:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d65:	83 c2 08             	add    $0x8,%edx
80106d68:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106d6f:	00 
    fileclose(rf);
80106d70:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106d73:	89 04 24             	mov    %eax,(%esp)
80106d76:	e8 09 a4 ff ff       	call   80101184 <fileclose>
    fileclose(wf);
80106d7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d7e:	89 04 24             	mov    %eax,(%esp)
80106d81:	e8 fe a3 ff ff       	call   80101184 <fileclose>
    return -1;
80106d86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d8b:	eb 18                	jmp    80106da5 <sys_pipe+0xc9>
  }
  fd[0] = fd0;
80106d8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106d90:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d93:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106d95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106d98:	8d 50 04             	lea    0x4(%eax),%edx
80106d9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d9e:	89 02                	mov    %eax,(%edx)
  return 0;
80106da0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106da5:	c9                   	leave  
80106da6:	c3                   	ret    

80106da7 <sys_ccreate>:

int
sys_ccreate(void)
{
80106da7:	55                   	push   %ebp
80106da8:	89 e5                	mov    %esp,%ebp
80106daa:	56                   	push   %esi
80106dab:	53                   	push   %ebx
80106dac:	81 ec c0 00 00 00    	sub    $0xc0,%esp

  char *name, *argv[MAXARG];
  int i, progc, mproc;
  uint uargv, uarg, msz, mdsk;

  if(argstr(0, &name) < 0 || argint(2, &progc) < 0 || argint(3, &mproc) < 0 
80106db2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106db5:	89 44 24 04          	mov    %eax,0x4(%esp)
80106db9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106dc0:	e8 a7 f1 ff ff       	call   80105f6c <argstr>
80106dc5:	85 c0                	test   %eax,%eax
80106dc7:	78 68                	js     80106e31 <sys_ccreate+0x8a>
80106dc9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106dcf:	89 44 24 04          	mov    %eax,0x4(%esp)
80106dd3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106dda:	e8 f6 f0 ff ff       	call   80105ed5 <argint>
80106ddf:	85 c0                	test   %eax,%eax
80106de1:	78 4e                	js     80106e31 <sys_ccreate+0x8a>
80106de3:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106de9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ded:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
80106df4:	e8 dc f0 ff ff       	call   80105ed5 <argint>
80106df9:	85 c0                	test   %eax,%eax
80106dfb:	78 34                	js     80106e31 <sys_ccreate+0x8a>
    || argint(4, (int*)&msz) < 0 || argint(5, (int*)&mdsk) < 0) {
80106dfd:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
80106e03:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e07:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106e0e:	e8 c2 f0 ff ff       	call   80105ed5 <argint>
80106e13:	85 c0                	test   %eax,%eax
80106e15:	78 1a                	js     80106e31 <sys_ccreate+0x8a>
80106e17:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80106e1d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e21:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
80106e28:	e8 a8 f0 ff ff       	call   80105ed5 <argint>
80106e2d:	85 c0                	test   %eax,%eax
80106e2f:	79 16                	jns    80106e47 <sys_ccreate+0xa0>
    cprintf("sys_ccreate: Error getting pointers\n");
80106e31:	c7 04 24 18 9a 10 80 	movl   $0x80109a18,(%esp)
80106e38:	e8 84 95 ff ff       	call   801003c1 <cprintf>
    return -1;
80106e3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e42:	e9 80 01 00 00       	jmp    80106fc7 <sys_ccreate+0x220>
  }

  if(argint(1, (int*)&uargv) < 0){
80106e47:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
80106e4d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e51:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106e58:	e8 78 f0 ff ff       	call   80105ed5 <argint>
80106e5d:	85 c0                	test   %eax,%eax
80106e5f:	79 0a                	jns    80106e6b <sys_ccreate+0xc4>
    return -1;
80106e61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e66:	e9 5c 01 00 00       	jmp    80106fc7 <sys_ccreate+0x220>
  }
  memset(argv, 0, sizeof(argv));
80106e6b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106e72:	00 
80106e73:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e7a:	00 
80106e7b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106e81:	89 04 24             	mov    %eax,(%esp)
80106e84:	e8 19 ed ff ff       	call   80105ba2 <memset>
  for(i=0;; i++){
80106e89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e93:	83 f8 1f             	cmp    $0x1f,%eax
80106e96:	76 0a                	jbe    80106ea2 <sys_ccreate+0xfb>
      return -1;
80106e98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e9d:	e9 25 01 00 00       	jmp    80106fc7 <sys_ccreate+0x220>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ea5:	c1 e0 02             	shl    $0x2,%eax
80106ea8:	89 c2                	mov    %eax,%edx
80106eaa:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80106eb0:	01 c2                	add    %eax,%edx
80106eb2:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
80106eb8:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ebc:	89 14 24             	mov    %edx,(%esp)
80106ebf:	e8 70 ef ff ff       	call   80105e34 <fetchint>
80106ec4:	85 c0                	test   %eax,%eax
80106ec6:	79 0a                	jns    80106ed2 <sys_ccreate+0x12b>
      return -1;
80106ec8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ecd:	e9 f5 00 00 00       	jmp    80106fc7 <sys_ccreate+0x220>
    if(uarg == 0){
80106ed2:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80106ed8:	85 c0                	test   %eax,%eax
80106eda:	75 53                	jne    80106f2f <sys_ccreate+0x188>
      argv[i] = 0;
80106edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106edf:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106ee6:	00 00 00 00 
      break;
80106eea:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_create\nuargv: %d\nname: %s\nmproc: %d\nmsz: %d\nmdsk: %d\n", uargv, name, mproc, msz, mdsk);
80106eeb:	8b b5 58 ff ff ff    	mov    -0xa8(%ebp),%esi
80106ef1:	8b 9d 5c ff ff ff    	mov    -0xa4(%ebp),%ebx
80106ef7:	8b 8d 68 ff ff ff    	mov    -0x98(%ebp),%ecx
80106efd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106f00:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80106f06:	89 74 24 14          	mov    %esi,0x14(%esp)
80106f0a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106f0e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106f12:	89 54 24 08          	mov    %edx,0x8(%esp)
80106f16:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f1a:	c7 04 24 40 9a 10 80 	movl   $0x80109a40,(%esp)
80106f21:	e8 9b 94 ff ff       	call   801003c1 <cprintf>
  for (i = 0; i < progc; i++) 
80106f26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106f2d:	eb 50                	jmp    80106f7f <sys_ccreate+0x1d8>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106f2f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106f35:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f38:	c1 e2 02             	shl    $0x2,%edx
80106f3b:	01 c2                	add    %eax,%edx
80106f3d:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80106f43:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f47:	89 04 24             	mov    %eax,(%esp)
80106f4a:	e8 24 ef ff ff       	call   80105e73 <fetchstr>
80106f4f:	85 c0                	test   %eax,%eax
80106f51:	79 07                	jns    80106f5a <sys_ccreate+0x1b3>
      return -1;
80106f53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f58:	eb 6d                	jmp    80106fc7 <sys_ccreate+0x220>

  if(argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106f5a:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106f5d:	e9 2e ff ff ff       	jmp    80106e90 <sys_ccreate+0xe9>

  cprintf("sys_create\nuargv: %d\nname: %s\nmproc: %d\nmsz: %d\nmdsk: %d\n", uargv, name, mproc, msz, mdsk);
  for (i = 0; i < progc; i++) 
    cprintf("\t%s\n", argv[i]);
80106f62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f65:	8b 84 85 70 ff ff ff 	mov    -0x90(%ebp,%eax,4),%eax
80106f6c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f70:	c7 04 24 7a 9a 10 80 	movl   $0x80109a7a,(%esp)
80106f77:	e8 45 94 ff ff       	call   801003c1 <cprintf>
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_create\nuargv: %d\nname: %s\nmproc: %d\nmsz: %d\nmdsk: %d\n", uargv, name, mproc, msz, mdsk);
  for (i = 0; i < progc; i++) 
80106f7c:	ff 45 f4             	incl   -0xc(%ebp)
80106f7f:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106f85:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80106f88:	7c d8                	jl     80106f62 <sys_ccreate+0x1bb>
    cprintf("\t%s\n", argv[i]);
  
  return ccreate(name, argv, progc, mproc, msz, mdsk);
80106f8a:	8b b5 58 ff ff ff    	mov    -0xa8(%ebp),%esi
80106f90:	8b 9d 5c ff ff ff    	mov    -0xa4(%ebp),%ebx
80106f96:	8b 8d 68 ff ff ff    	mov    -0x98(%ebp),%ecx
80106f9c:	8b 95 6c ff ff ff    	mov    -0x94(%ebp),%edx
80106fa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106fa5:	89 74 24 14          	mov    %esi,0x14(%esp)
80106fa9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106fad:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106fb1:	89 54 24 08          	mov    %edx,0x8(%esp)
80106fb5:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106fbb:	89 54 24 04          	mov    %edx,0x4(%esp)
80106fbf:	89 04 24             	mov    %eax,(%esp)
80106fc2:	e8 f6 e2 ff ff       	call   801052bd <ccreate>
}
80106fc7:	81 c4 c0 00 00 00    	add    $0xc0,%esp
80106fcd:	5b                   	pop    %ebx
80106fce:	5e                   	pop    %esi
80106fcf:	5d                   	pop    %ebp
80106fd0:	c3                   	ret    

80106fd1 <sys_cstart>:

int
sys_cstart(void)
{
80106fd1:	55                   	push   %ebp
80106fd2:	89 e5                	mov    %esp,%ebp
80106fd4:	81 ec b8 00 00 00    	sub    $0xb8,%esp

  char *name, *prog, *argv[MAXARG];
  int i, argc;
  uint uargv, uarg;

  if(argstr(0, &name) < 0 || argstr(1, &prog) < 0 || argint(2, &argc) < 0) {
80106fda:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106fdd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fe1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106fe8:	e8 7f ef ff ff       	call   80105f6c <argstr>
80106fed:	85 c0                	test   %eax,%eax
80106fef:	78 31                	js     80107022 <sys_cstart+0x51>
80106ff1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106ff4:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ff8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106fff:	e8 68 ef ff ff       	call   80105f6c <argstr>
80107004:	85 c0                	test   %eax,%eax
80107006:	78 1a                	js     80107022 <sys_cstart+0x51>
80107008:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010700e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107012:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80107019:	e8 b7 ee ff ff       	call   80105ed5 <argint>
8010701e:	85 c0                	test   %eax,%eax
80107020:	79 16                	jns    80107038 <sys_cstart+0x67>
    cprintf("sys_ccreate: Error getting pointers\n");
80107022:	c7 04 24 18 9a 10 80 	movl   $0x80109a18,(%esp)
80107029:	e8 93 93 ff ff       	call   801003c1 <cprintf>
    return -1;
8010702e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107033:	e9 4e 01 00 00       	jmp    80107186 <sys_cstart+0x1b5>
  }

  if(argint(1, (int*)&uargv) < 0){
80107038:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
8010703e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107042:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80107049:	e8 87 ee ff ff       	call   80105ed5 <argint>
8010704e:	85 c0                	test   %eax,%eax
80107050:	79 0a                	jns    8010705c <sys_cstart+0x8b>
    return -1;
80107052:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107057:	e9 2a 01 00 00       	jmp    80107186 <sys_cstart+0x1b5>
  }
  memset(argv, 0, sizeof(argv));
8010705c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80107063:	00 
80107064:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010706b:	00 
8010706c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80107072:	89 04 24             	mov    %eax,(%esp)
80107075:	e8 28 eb ff ff       	call   80105ba2 <memset>
  for(i=0;; i++){
8010707a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80107081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107084:	83 f8 1f             	cmp    $0x1f,%eax
80107087:	76 0a                	jbe    80107093 <sys_cstart+0xc2>
      return -1;
80107089:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010708e:	e9 f3 00 00 00       	jmp    80107186 <sys_cstart+0x1b5>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80107093:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107096:	c1 e0 02             	shl    $0x2,%eax
80107099:	89 c2                	mov    %eax,%edx
8010709b:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
801070a1:	01 c2                	add    %eax,%edx
801070a3:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
801070a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801070ad:	89 14 24             	mov    %edx,(%esp)
801070b0:	e8 7f ed ff ff       	call   80105e34 <fetchint>
801070b5:	85 c0                	test   %eax,%eax
801070b7:	79 0a                	jns    801070c3 <sys_cstart+0xf2>
      return -1;
801070b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070be:	e9 c3 00 00 00       	jmp    80107186 <sys_cstart+0x1b5>
    if(uarg == 0){
801070c3:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
801070c9:	85 c0                	test   %eax,%eax
801070cb:	75 3f                	jne    8010710c <sys_cstart+0x13b>
      argv[i] = 0;
801070cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070d0:	c7 84 85 6c ff ff ff 	movl   $0x0,-0x94(%ebp,%eax,4)
801070d7:	00 00 00 00 
      break;
801070db:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_cstart\n\tuargv: %d\n\tname: %s\n\targc: %d\n", uargv, name, argc);
801070dc:	8b 8d 68 ff ff ff    	mov    -0x98(%ebp),%ecx
801070e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801070e5:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
801070eb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801070ef:	89 54 24 08          	mov    %edx,0x8(%esp)
801070f3:	89 44 24 04          	mov    %eax,0x4(%esp)
801070f7:	c7 04 24 80 9a 10 80 	movl   $0x80109a80,(%esp)
801070fe:	e8 be 92 ff ff       	call   801003c1 <cprintf>
  for (i = 0; i < argc; i++) 
80107103:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010710a:	eb 50                	jmp    8010715c <sys_cstart+0x18b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
8010710c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80107112:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107115:	c1 e2 02             	shl    $0x2,%edx
80107118:	01 c2                	add    %eax,%edx
8010711a:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80107120:	89 54 24 04          	mov    %edx,0x4(%esp)
80107124:	89 04 24             	mov    %eax,(%esp)
80107127:	e8 47 ed ff ff       	call   80105e73 <fetchstr>
8010712c:	85 c0                	test   %eax,%eax
8010712e:	79 07                	jns    80107137 <sys_cstart+0x166>
      return -1;
80107130:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107135:	eb 4f                	jmp    80107186 <sys_cstart+0x1b5>

  if(argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80107137:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
8010713a:	e9 42 ff ff ff       	jmp    80107081 <sys_cstart+0xb0>

  cprintf("sys_cstart\n\tuargv: %d\n\tname: %s\n\targc: %d\n", uargv, name, argc);
  for (i = 0; i < argc; i++) 
    cprintf("\t%s\n", argv[i]);
8010713f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107142:	8b 84 85 6c ff ff ff 	mov    -0x94(%ebp,%eax,4),%eax
80107149:	89 44 24 04          	mov    %eax,0x4(%esp)
8010714d:	c7 04 24 7a 9a 10 80 	movl   $0x80109a7a,(%esp)
80107154:	e8 68 92 ff ff       	call   801003c1 <cprintf>
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_cstart\n\tuargv: %d\n\tname: %s\n\targc: %d\n", uargv, name, argc);
  for (i = 0; i < argc; i++) 
80107159:	ff 45 f4             	incl   -0xc(%ebp)
8010715c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107162:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80107165:	7c d8                	jl     8010713f <sys_cstart+0x16e>
    cprintf("\t%s\n", argv[i]);
  
  return cstart(name, argv, argc);
80107167:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
8010716d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107170:	89 54 24 08          	mov    %edx,0x8(%esp)
80107174:	8d 95 6c ff ff ff    	lea    -0x94(%ebp),%edx
8010717a:	89 54 24 04          	mov    %edx,0x4(%esp)
8010717e:	89 04 24             	mov    %eax,(%esp)
80107181:	e8 13 e2 ff ff       	call   80105399 <cstart>
}
80107186:	c9                   	leave  
80107187:	c3                   	ret    

80107188 <sys_cstop>:

int
sys_cstop(void)
{
80107188:	55                   	push   %ebp
80107189:	89 e5                	mov    %esp,%ebp
  return 1;
8010718b:	b8 01 00 00 00       	mov    $0x1,%eax
}
80107190:	5d                   	pop    %ebp
80107191:	c3                   	ret    

80107192 <sys_cinfo>:

int
sys_cinfo(void)
{
80107192:	55                   	push   %ebp
80107193:	89 e5                	mov    %esp,%ebp
  return 1;
80107195:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010719a:	5d                   	pop    %ebp
8010719b:	c3                   	ret    

8010719c <sys_cpause>:

int
sys_cpause(void)
{
8010719c:	55                   	push   %ebp
8010719d:	89 e5                	mov    %esp,%ebp
  return 1;
8010719f:	b8 01 00 00 00       	mov    $0x1,%eax
801071a4:	5d                   	pop    %ebp
801071a5:	c3                   	ret    
	...

801071a8 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
801071a8:	55                   	push   %ebp
801071a9:	89 e5                	mov    %esp,%ebp
801071ab:	83 ec 08             	sub    $0x8,%esp
  return fork();
801071ae:	e8 89 d4 ff ff       	call   8010463c <fork>
}
801071b3:	c9                   	leave  
801071b4:	c3                   	ret    

801071b5 <sys_exit>:

int
sys_exit(void)
{
801071b5:	55                   	push   %ebp
801071b6:	89 e5                	mov    %esp,%ebp
801071b8:	83 ec 08             	sub    $0x8,%esp
  exit();
801071bb:	e8 4e d7 ff ff       	call   8010490e <exit>
  return 0;  // not reached
801071c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801071c5:	c9                   	leave  
801071c6:	c3                   	ret    

801071c7 <sys_wait>:

int
sys_wait(void)
{
801071c7:	55                   	push   %ebp
801071c8:	89 e5                	mov    %esp,%ebp
801071ca:	83 ec 08             	sub    $0x8,%esp
  return wait();
801071cd:	e8 6c d8 ff ff       	call   80104a3e <wait>
}
801071d2:	c9                   	leave  
801071d3:	c3                   	ret    

801071d4 <sys_kill>:

int
sys_kill(void)
{
801071d4:	55                   	push   %ebp
801071d5:	89 e5                	mov    %esp,%ebp
801071d7:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
801071da:	8d 45 f4             	lea    -0xc(%ebp),%eax
801071dd:	89 44 24 04          	mov    %eax,0x4(%esp)
801071e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801071e8:	e8 e8 ec ff ff       	call   80105ed5 <argint>
801071ed:	85 c0                	test   %eax,%eax
801071ef:	79 07                	jns    801071f8 <sys_kill+0x24>
    return -1;
801071f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071f6:	eb 0b                	jmp    80107203 <sys_kill+0x2f>
  return kill(pid);
801071f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071fb:	89 04 24             	mov    %eax,(%esp)
801071fe:	e8 dc da ff ff       	call   80104cdf <kill>
}
80107203:	c9                   	leave  
80107204:	c3                   	ret    

80107205 <sys_getpid>:

int
sys_getpid(void)
{
80107205:	55                   	push   %ebp
80107206:	89 e5                	mov    %esp,%ebp
80107208:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010720b:	e8 f0 d0 ff ff       	call   80104300 <myproc>
80107210:	8b 40 10             	mov    0x10(%eax),%eax
}
80107213:	c9                   	leave  
80107214:	c3                   	ret    

80107215 <sys_sbrk>:

int
sys_sbrk(void)
{
80107215:	55                   	push   %ebp
80107216:	89 e5                	mov    %esp,%ebp
80107218:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010721b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010721e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107222:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107229:	e8 a7 ec ff ff       	call   80105ed5 <argint>
8010722e:	85 c0                	test   %eax,%eax
80107230:	79 07                	jns    80107239 <sys_sbrk+0x24>
    return -1;
80107232:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107237:	eb 23                	jmp    8010725c <sys_sbrk+0x47>
  addr = myproc()->sz;
80107239:	e8 c2 d0 ff ff       	call   80104300 <myproc>
8010723e:	8b 00                	mov    (%eax),%eax
80107240:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80107243:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107246:	89 04 24             	mov    %eax,(%esp)
80107249:	e8 50 d3 ff ff       	call   8010459e <growproc>
8010724e:	85 c0                	test   %eax,%eax
80107250:	79 07                	jns    80107259 <sys_sbrk+0x44>
    return -1;
80107252:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107257:	eb 03                	jmp    8010725c <sys_sbrk+0x47>
  return addr;
80107259:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010725c:	c9                   	leave  
8010725d:	c3                   	ret    

8010725e <sys_sleep>:

int
sys_sleep(void)
{
8010725e:	55                   	push   %ebp
8010725f:	89 e5                	mov    %esp,%ebp
80107261:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80107264:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107267:	89 44 24 04          	mov    %eax,0x4(%esp)
8010726b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107272:	e8 5e ec ff ff       	call   80105ed5 <argint>
80107277:	85 c0                	test   %eax,%eax
80107279:	79 07                	jns    80107282 <sys_sleep+0x24>
    return -1;
8010727b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107280:	eb 6b                	jmp    801072ed <sys_sleep+0x8f>
  acquire(&tickslock);
80107282:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
80107289:	e8 b1 e6 ff ff       	call   8010593f <acquire>
  ticks0 = ticks;
8010728e:	a1 40 61 12 80       	mov    0x80126140,%eax
80107293:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80107296:	eb 33                	jmp    801072cb <sys_sleep+0x6d>
    if(myproc()->killed){
80107298:	e8 63 d0 ff ff       	call   80104300 <myproc>
8010729d:	8b 40 24             	mov    0x24(%eax),%eax
801072a0:	85 c0                	test   %eax,%eax
801072a2:	74 13                	je     801072b7 <sys_sleep+0x59>
      release(&tickslock);
801072a4:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
801072ab:	e8 f9 e6 ff ff       	call   801059a9 <release>
      return -1;
801072b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072b5:	eb 36                	jmp    801072ed <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
801072b7:	c7 44 24 04 00 59 12 	movl   $0x80125900,0x4(%esp)
801072be:	80 
801072bf:	c7 04 24 40 61 12 80 	movl   $0x80126140,(%esp)
801072c6:	e8 09 d9 ff ff       	call   80104bd4 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801072cb:	a1 40 61 12 80       	mov    0x80126140,%eax
801072d0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801072d3:	89 c2                	mov    %eax,%edx
801072d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801072d8:	39 c2                	cmp    %eax,%edx
801072da:	72 bc                	jb     80107298 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801072dc:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
801072e3:	e8 c1 e6 ff ff       	call   801059a9 <release>
  return 0;
801072e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072ed:	c9                   	leave  
801072ee:	c3                   	ret    

801072ef <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801072ef:	55                   	push   %ebp
801072f0:	89 e5                	mov    %esp,%ebp
801072f2:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
801072f5:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
801072fc:	e8 3e e6 ff ff       	call   8010593f <acquire>
  xticks = ticks;
80107301:	a1 40 61 12 80       	mov    0x80126140,%eax
80107306:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80107309:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
80107310:	e8 94 e6 ff ff       	call   801059a9 <release>
  return xticks;
80107315:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107318:	c9                   	leave  
80107319:	c3                   	ret    

8010731a <sys_getticks>:

int
sys_getticks(void)
{
8010731a:	55                   	push   %ebp
8010731b:	89 e5                	mov    %esp,%ebp
8010731d:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
80107320:	e8 db cf ff ff       	call   80104300 <myproc>
80107325:	8b 40 7c             	mov    0x7c(%eax),%eax
}
80107328:	c9                   	leave  
80107329:	c3                   	ret    
	...

8010732c <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010732c:	1e                   	push   %ds
  pushl %es
8010732d:	06                   	push   %es
  pushl %fs
8010732e:	0f a0                	push   %fs
  pushl %gs
80107330:	0f a8                	push   %gs
  pushal
80107332:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80107333:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80107337:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80107339:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010733b:	54                   	push   %esp
  call trap
8010733c:	e8 c0 01 00 00       	call   80107501 <trap>
  addl $4, %esp
80107341:	83 c4 04             	add    $0x4,%esp

80107344 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80107344:	61                   	popa   
  popl %gs
80107345:	0f a9                	pop    %gs
  popl %fs
80107347:	0f a1                	pop    %fs
  popl %es
80107349:	07                   	pop    %es
  popl %ds
8010734a:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010734b:	83 c4 08             	add    $0x8,%esp
  iret
8010734e:	cf                   	iret   
	...

80107350 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80107350:	55                   	push   %ebp
80107351:	89 e5                	mov    %esp,%ebp
80107353:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107356:	8b 45 0c             	mov    0xc(%ebp),%eax
80107359:	48                   	dec    %eax
8010735a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010735e:	8b 45 08             	mov    0x8(%ebp),%eax
80107361:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107365:	8b 45 08             	mov    0x8(%ebp),%eax
80107368:	c1 e8 10             	shr    $0x10,%eax
8010736b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010736f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107372:	0f 01 18             	lidtl  (%eax)
}
80107375:	c9                   	leave  
80107376:	c3                   	ret    

80107377 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80107377:	55                   	push   %ebp
80107378:	89 e5                	mov    %esp,%ebp
8010737a:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010737d:	0f 20 d0             	mov    %cr2,%eax
80107380:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80107383:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107386:	c9                   	leave  
80107387:	c3                   	ret    

80107388 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80107388:	55                   	push   %ebp
80107389:	89 e5                	mov    %esp,%ebp
8010738b:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
8010738e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107395:	e9 b8 00 00 00       	jmp    80107452 <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010739a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010739d:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
801073a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801073a7:	66 89 04 d5 40 59 12 	mov    %ax,-0x7feda6c0(,%edx,8)
801073ae:	80 
801073af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073b2:	66 c7 04 c5 42 59 12 	movw   $0x8,-0x7feda6be(,%eax,8)
801073b9:	80 08 00 
801073bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073bf:	8a 14 c5 44 59 12 80 	mov    -0x7feda6bc(,%eax,8),%dl
801073c6:	83 e2 e0             	and    $0xffffffe0,%edx
801073c9:	88 14 c5 44 59 12 80 	mov    %dl,-0x7feda6bc(,%eax,8)
801073d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d3:	8a 14 c5 44 59 12 80 	mov    -0x7feda6bc(,%eax,8),%dl
801073da:	83 e2 1f             	and    $0x1f,%edx
801073dd:	88 14 c5 44 59 12 80 	mov    %dl,-0x7feda6bc(,%eax,8)
801073e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073e7:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
801073ee:	83 e2 f0             	and    $0xfffffff0,%edx
801073f1:	83 ca 0e             	or     $0xe,%edx
801073f4:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
801073fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073fe:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
80107405:	83 e2 ef             	and    $0xffffffef,%edx
80107408:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
8010740f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107412:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
80107419:	83 e2 9f             	and    $0xffffff9f,%edx
8010741c:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
80107423:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107426:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
8010742d:	83 ca 80             	or     $0xffffff80,%edx
80107430:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
80107437:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010743a:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
80107441:	c1 e8 10             	shr    $0x10,%eax
80107444:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107447:	66 89 04 d5 46 59 12 	mov    %ax,-0x7feda6ba(,%edx,8)
8010744e:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010744f:	ff 45 f4             	incl   -0xc(%ebp)
80107452:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80107459:	0f 8e 3b ff ff ff    	jle    8010739a <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010745f:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
80107464:	66 a3 40 5b 12 80    	mov    %ax,0x80125b40
8010746a:	66 c7 05 42 5b 12 80 	movw   $0x8,0x80125b42
80107471:	08 00 
80107473:	a0 44 5b 12 80       	mov    0x80125b44,%al
80107478:	83 e0 e0             	and    $0xffffffe0,%eax
8010747b:	a2 44 5b 12 80       	mov    %al,0x80125b44
80107480:	a0 44 5b 12 80       	mov    0x80125b44,%al
80107485:	83 e0 1f             	and    $0x1f,%eax
80107488:	a2 44 5b 12 80       	mov    %al,0x80125b44
8010748d:	a0 45 5b 12 80       	mov    0x80125b45,%al
80107492:	83 c8 0f             	or     $0xf,%eax
80107495:	a2 45 5b 12 80       	mov    %al,0x80125b45
8010749a:	a0 45 5b 12 80       	mov    0x80125b45,%al
8010749f:	83 e0 ef             	and    $0xffffffef,%eax
801074a2:	a2 45 5b 12 80       	mov    %al,0x80125b45
801074a7:	a0 45 5b 12 80       	mov    0x80125b45,%al
801074ac:	83 c8 60             	or     $0x60,%eax
801074af:	a2 45 5b 12 80       	mov    %al,0x80125b45
801074b4:	a0 45 5b 12 80       	mov    0x80125b45,%al
801074b9:	83 c8 80             	or     $0xffffff80,%eax
801074bc:	a2 45 5b 12 80       	mov    %al,0x80125b45
801074c1:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
801074c6:	c1 e8 10             	shr    $0x10,%eax
801074c9:	66 a3 46 5b 12 80    	mov    %ax,0x80125b46

  initlock(&tickslock, "time");
801074cf:	c7 44 24 04 ac 9a 10 	movl   $0x80109aac,0x4(%esp)
801074d6:	80 
801074d7:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
801074de:	e8 3b e4 ff ff       	call   8010591e <initlock>
}
801074e3:	c9                   	leave  
801074e4:	c3                   	ret    

801074e5 <idtinit>:

void
idtinit(void)
{
801074e5:	55                   	push   %ebp
801074e6:	89 e5                	mov    %esp,%ebp
801074e8:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801074eb:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801074f2:	00 
801074f3:	c7 04 24 40 59 12 80 	movl   $0x80125940,(%esp)
801074fa:	e8 51 fe ff ff       	call   80107350 <lidt>
}
801074ff:	c9                   	leave  
80107500:	c3                   	ret    

80107501 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107501:	55                   	push   %ebp
80107502:	89 e5                	mov    %esp,%ebp
80107504:	57                   	push   %edi
80107505:	56                   	push   %esi
80107506:	53                   	push   %ebx
80107507:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
8010750a:	8b 45 08             	mov    0x8(%ebp),%eax
8010750d:	8b 40 30             	mov    0x30(%eax),%eax
80107510:	83 f8 40             	cmp    $0x40,%eax
80107513:	75 3c                	jne    80107551 <trap+0x50>
    if(myproc()->killed)
80107515:	e8 e6 cd ff ff       	call   80104300 <myproc>
8010751a:	8b 40 24             	mov    0x24(%eax),%eax
8010751d:	85 c0                	test   %eax,%eax
8010751f:	74 05                	je     80107526 <trap+0x25>
      exit();
80107521:	e8 e8 d3 ff ff       	call   8010490e <exit>
    myproc()->tf = tf;
80107526:	e8 d5 cd ff ff       	call   80104300 <myproc>
8010752b:	8b 55 08             	mov    0x8(%ebp),%edx
8010752e:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107531:	e8 6d ea ff ff       	call   80105fa3 <syscall>
    if(myproc()->killed)
80107536:	e8 c5 cd ff ff       	call   80104300 <myproc>
8010753b:	8b 40 24             	mov    0x24(%eax),%eax
8010753e:	85 c0                	test   %eax,%eax
80107540:	74 0a                	je     8010754c <trap+0x4b>
      exit();
80107542:	e8 c7 d3 ff ff       	call   8010490e <exit>
    return;
80107547:	e9 30 02 00 00       	jmp    8010777c <trap+0x27b>
8010754c:	e9 2b 02 00 00       	jmp    8010777c <trap+0x27b>
  }

  switch(tf->trapno){
80107551:	8b 45 08             	mov    0x8(%ebp),%eax
80107554:	8b 40 30             	mov    0x30(%eax),%eax
80107557:	83 e8 20             	sub    $0x20,%eax
8010755a:	83 f8 1f             	cmp    $0x1f,%eax
8010755d:	0f 87 cb 00 00 00    	ja     8010762e <trap+0x12d>
80107563:	8b 04 85 54 9b 10 80 	mov    -0x7fef64ac(,%eax,4),%eax
8010756a:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010756c:	e8 19 d8 ff ff       	call   80104d8a <cpuid>
80107571:	85 c0                	test   %eax,%eax
80107573:	75 2f                	jne    801075a4 <trap+0xa3>
      acquire(&tickslock);
80107575:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
8010757c:	e8 be e3 ff ff       	call   8010593f <acquire>
      ticks++;
80107581:	a1 40 61 12 80       	mov    0x80126140,%eax
80107586:	40                   	inc    %eax
80107587:	a3 40 61 12 80       	mov    %eax,0x80126140
      wakeup(&ticks);
8010758c:	c7 04 24 40 61 12 80 	movl   $0x80126140,(%esp)
80107593:	e8 2a d7 ff ff       	call   80104cc2 <wakeup>
      release(&tickslock);
80107598:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
8010759f:	e8 05 e4 ff ff       	call   801059a9 <release>
    }
    p = myproc();
801075a4:	e8 57 cd ff ff       	call   80104300 <myproc>
801075a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
801075ac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801075b0:	74 0f                	je     801075c1 <trap+0xc0>
      p->ticks++;
801075b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801075b5:	8b 40 7c             	mov    0x7c(%eax),%eax
801075b8:	8d 50 01             	lea    0x1(%eax),%edx
801075bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801075be:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
801075c1:	e8 15 bc ff ff       	call   801031db <lapiceoi>
    break;
801075c6:	e9 35 01 00 00       	jmp    80107700 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801075cb:	e8 8a b4 ff ff       	call   80102a5a <ideintr>
    lapiceoi();
801075d0:	e8 06 bc ff ff       	call   801031db <lapiceoi>
    break;
801075d5:	e9 26 01 00 00       	jmp    80107700 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801075da:	e8 13 ba ff ff       	call   80102ff2 <kbdintr>
    lapiceoi();
801075df:	e8 f7 bb ff ff       	call   801031db <lapiceoi>
    break;
801075e4:	e9 17 01 00 00       	jmp    80107700 <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801075e9:	e8 6f 03 00 00       	call   8010795d <uartintr>
    lapiceoi();
801075ee:	e8 e8 bb ff ff       	call   801031db <lapiceoi>
    break;
801075f3:	e9 08 01 00 00       	jmp    80107700 <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801075f8:	8b 45 08             	mov    0x8(%ebp),%eax
801075fb:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801075fe:	8b 45 08             	mov    0x8(%ebp),%eax
80107601:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107604:	0f b7 d8             	movzwl %ax,%ebx
80107607:	e8 7e d7 ff ff       	call   80104d8a <cpuid>
8010760c:	89 74 24 0c          	mov    %esi,0xc(%esp)
80107610:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107614:	89 44 24 04          	mov    %eax,0x4(%esp)
80107618:	c7 04 24 b4 9a 10 80 	movl   $0x80109ab4,(%esp)
8010761f:	e8 9d 8d ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80107624:	e8 b2 bb ff ff       	call   801031db <lapiceoi>
    break;
80107629:	e9 d2 00 00 00       	jmp    80107700 <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010762e:	e8 cd cc ff ff       	call   80104300 <myproc>
80107633:	85 c0                	test   %eax,%eax
80107635:	74 10                	je     80107647 <trap+0x146>
80107637:	8b 45 08             	mov    0x8(%ebp),%eax
8010763a:	8b 40 3c             	mov    0x3c(%eax),%eax
8010763d:	0f b7 c0             	movzwl %ax,%eax
80107640:	83 e0 03             	and    $0x3,%eax
80107643:	85 c0                	test   %eax,%eax
80107645:	75 40                	jne    80107687 <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107647:	e8 2b fd ff ff       	call   80107377 <rcr2>
8010764c:	89 c3                	mov    %eax,%ebx
8010764e:	8b 45 08             	mov    0x8(%ebp),%eax
80107651:	8b 70 38             	mov    0x38(%eax),%esi
80107654:	e8 31 d7 ff ff       	call   80104d8a <cpuid>
80107659:	8b 55 08             	mov    0x8(%ebp),%edx
8010765c:	8b 52 30             	mov    0x30(%edx),%edx
8010765f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80107663:	89 74 24 0c          	mov    %esi,0xc(%esp)
80107667:	89 44 24 08          	mov    %eax,0x8(%esp)
8010766b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010766f:	c7 04 24 d8 9a 10 80 	movl   $0x80109ad8,(%esp)
80107676:	e8 46 8d ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
8010767b:	c7 04 24 0a 9b 10 80 	movl   $0x80109b0a,(%esp)
80107682:	e8 cd 8e ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107687:	e8 eb fc ff ff       	call   80107377 <rcr2>
8010768c:	89 c6                	mov    %eax,%esi
8010768e:	8b 45 08             	mov    0x8(%ebp),%eax
80107691:	8b 40 38             	mov    0x38(%eax),%eax
80107694:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80107697:	e8 ee d6 ff ff       	call   80104d8a <cpuid>
8010769c:	89 c3                	mov    %eax,%ebx
8010769e:	8b 45 08             	mov    0x8(%ebp),%eax
801076a1:	8b 78 34             	mov    0x34(%eax),%edi
801076a4:	89 7d d0             	mov    %edi,-0x30(%ebp)
801076a7:	8b 45 08             	mov    0x8(%ebp),%eax
801076aa:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801076ad:	e8 4e cc ff ff       	call   80104300 <myproc>
801076b2:	8d 50 6c             	lea    0x6c(%eax),%edx
801076b5:	89 55 cc             	mov    %edx,-0x34(%ebp)
801076b8:	e8 43 cc ff ff       	call   80104300 <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801076bd:	8b 40 10             	mov    0x10(%eax),%eax
801076c0:	89 74 24 1c          	mov    %esi,0x1c(%esp)
801076c4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
801076c7:	89 4c 24 18          	mov    %ecx,0x18(%esp)
801076cb:	89 5c 24 14          	mov    %ebx,0x14(%esp)
801076cf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
801076d2:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801076d6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
801076da:	8b 55 cc             	mov    -0x34(%ebp),%edx
801076dd:	89 54 24 08          	mov    %edx,0x8(%esp)
801076e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801076e5:	c7 04 24 10 9b 10 80 	movl   $0x80109b10,(%esp)
801076ec:	e8 d0 8c ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801076f1:	e8 0a cc ff ff       	call   80104300 <myproc>
801076f6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801076fd:	eb 01                	jmp    80107700 <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801076ff:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80107700:	e8 fb cb ff ff       	call   80104300 <myproc>
80107705:	85 c0                	test   %eax,%eax
80107707:	74 22                	je     8010772b <trap+0x22a>
80107709:	e8 f2 cb ff ff       	call   80104300 <myproc>
8010770e:	8b 40 24             	mov    0x24(%eax),%eax
80107711:	85 c0                	test   %eax,%eax
80107713:	74 16                	je     8010772b <trap+0x22a>
80107715:	8b 45 08             	mov    0x8(%ebp),%eax
80107718:	8b 40 3c             	mov    0x3c(%eax),%eax
8010771b:	0f b7 c0             	movzwl %ax,%eax
8010771e:	83 e0 03             	and    $0x3,%eax
80107721:	83 f8 03             	cmp    $0x3,%eax
80107724:	75 05                	jne    8010772b <trap+0x22a>
    exit();
80107726:	e8 e3 d1 ff ff       	call   8010490e <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010772b:	e8 d0 cb ff ff       	call   80104300 <myproc>
80107730:	85 c0                	test   %eax,%eax
80107732:	74 1d                	je     80107751 <trap+0x250>
80107734:	e8 c7 cb ff ff       	call   80104300 <myproc>
80107739:	8b 40 0c             	mov    0xc(%eax),%eax
8010773c:	83 f8 04             	cmp    $0x4,%eax
8010773f:	75 10                	jne    80107751 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80107741:	8b 45 08             	mov    0x8(%ebp),%eax
80107744:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80107747:	83 f8 20             	cmp    $0x20,%eax
8010774a:	75 05                	jne    80107751 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
8010774c:	e8 10 d4 ff ff       	call   80104b61 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80107751:	e8 aa cb ff ff       	call   80104300 <myproc>
80107756:	85 c0                	test   %eax,%eax
80107758:	74 22                	je     8010777c <trap+0x27b>
8010775a:	e8 a1 cb ff ff       	call   80104300 <myproc>
8010775f:	8b 40 24             	mov    0x24(%eax),%eax
80107762:	85 c0                	test   %eax,%eax
80107764:	74 16                	je     8010777c <trap+0x27b>
80107766:	8b 45 08             	mov    0x8(%ebp),%eax
80107769:	8b 40 3c             	mov    0x3c(%eax),%eax
8010776c:	0f b7 c0             	movzwl %ax,%eax
8010776f:	83 e0 03             	and    $0x3,%eax
80107772:	83 f8 03             	cmp    $0x3,%eax
80107775:	75 05                	jne    8010777c <trap+0x27b>
    exit();
80107777:	e8 92 d1 ff ff       	call   8010490e <exit>
}
8010777c:	83 c4 4c             	add    $0x4c,%esp
8010777f:	5b                   	pop    %ebx
80107780:	5e                   	pop    %esi
80107781:	5f                   	pop    %edi
80107782:	5d                   	pop    %ebp
80107783:	c3                   	ret    

80107784 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107784:	55                   	push   %ebp
80107785:	89 e5                	mov    %esp,%ebp
80107787:	83 ec 14             	sub    $0x14,%esp
8010778a:	8b 45 08             	mov    0x8(%ebp),%eax
8010778d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107791:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107794:	89 c2                	mov    %eax,%edx
80107796:	ec                   	in     (%dx),%al
80107797:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010779a:	8a 45 ff             	mov    -0x1(%ebp),%al
}
8010779d:	c9                   	leave  
8010779e:	c3                   	ret    

8010779f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010779f:	55                   	push   %ebp
801077a0:	89 e5                	mov    %esp,%ebp
801077a2:	83 ec 08             	sub    $0x8,%esp
801077a5:	8b 45 08             	mov    0x8(%ebp),%eax
801077a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801077ab:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801077af:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801077b2:	8a 45 f8             	mov    -0x8(%ebp),%al
801077b5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801077b8:	ee                   	out    %al,(%dx)
}
801077b9:	c9                   	leave  
801077ba:	c3                   	ret    

801077bb <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801077bb:	55                   	push   %ebp
801077bc:	89 e5                	mov    %esp,%ebp
801077be:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801077c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801077c8:	00 
801077c9:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801077d0:	e8 ca ff ff ff       	call   8010779f <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801077d5:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801077dc:	00 
801077dd:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801077e4:	e8 b6 ff ff ff       	call   8010779f <outb>
  outb(COM1+0, 115200/9600);
801077e9:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
801077f0:	00 
801077f1:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801077f8:	e8 a2 ff ff ff       	call   8010779f <outb>
  outb(COM1+1, 0);
801077fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107804:	00 
80107805:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
8010780c:	e8 8e ff ff ff       	call   8010779f <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107811:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80107818:	00 
80107819:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107820:	e8 7a ff ff ff       	call   8010779f <outb>
  outb(COM1+4, 0);
80107825:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010782c:	00 
8010782d:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107834:	e8 66 ff ff ff       	call   8010779f <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107839:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107840:	00 
80107841:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107848:	e8 52 ff ff ff       	call   8010779f <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010784d:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107854:	e8 2b ff ff ff       	call   80107784 <inb>
80107859:	3c ff                	cmp    $0xff,%al
8010785b:	75 02                	jne    8010785f <uartinit+0xa4>
    return;
8010785d:	eb 5b                	jmp    801078ba <uartinit+0xff>
  uart = 1;
8010785f:	c7 05 84 c7 10 80 01 	movl   $0x1,0x8010c784
80107866:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107869:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107870:	e8 0f ff ff ff       	call   80107784 <inb>
  inb(COM1+0);
80107875:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010787c:	e8 03 ff ff ff       	call   80107784 <inb>
  ioapicenable(IRQ_COM1, 0);
80107881:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107888:	00 
80107889:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107890:	e8 3a b4 ff ff       	call   80102ccf <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107895:	c7 45 f4 d4 9b 10 80 	movl   $0x80109bd4,-0xc(%ebp)
8010789c:	eb 13                	jmp    801078b1 <uartinit+0xf6>
    uartputc(*p);
8010789e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a1:	8a 00                	mov    (%eax),%al
801078a3:	0f be c0             	movsbl %al,%eax
801078a6:	89 04 24             	mov    %eax,(%esp)
801078a9:	e8 0e 00 00 00       	call   801078bc <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801078ae:	ff 45 f4             	incl   -0xc(%ebp)
801078b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078b4:	8a 00                	mov    (%eax),%al
801078b6:	84 c0                	test   %al,%al
801078b8:	75 e4                	jne    8010789e <uartinit+0xe3>
    uartputc(*p);
}
801078ba:	c9                   	leave  
801078bb:	c3                   	ret    

801078bc <uartputc>:

void
uartputc(int c)
{
801078bc:	55                   	push   %ebp
801078bd:	89 e5                	mov    %esp,%ebp
801078bf:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801078c2:	a1 84 c7 10 80       	mov    0x8010c784,%eax
801078c7:	85 c0                	test   %eax,%eax
801078c9:	75 02                	jne    801078cd <uartputc+0x11>
    return;
801078cb:	eb 4a                	jmp    80107917 <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801078cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801078d4:	eb 0f                	jmp    801078e5 <uartputc+0x29>
    microdelay(10);
801078d6:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801078dd:	e8 1e b9 ff ff       	call   80103200 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801078e2:	ff 45 f4             	incl   -0xc(%ebp)
801078e5:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801078e9:	7f 16                	jg     80107901 <uartputc+0x45>
801078eb:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801078f2:	e8 8d fe ff ff       	call   80107784 <inb>
801078f7:	0f b6 c0             	movzbl %al,%eax
801078fa:	83 e0 20             	and    $0x20,%eax
801078fd:	85 c0                	test   %eax,%eax
801078ff:	74 d5                	je     801078d6 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80107901:	8b 45 08             	mov    0x8(%ebp),%eax
80107904:	0f b6 c0             	movzbl %al,%eax
80107907:	89 44 24 04          	mov    %eax,0x4(%esp)
8010790b:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107912:	e8 88 fe ff ff       	call   8010779f <outb>
}
80107917:	c9                   	leave  
80107918:	c3                   	ret    

80107919 <uartgetc>:

static int
uartgetc(void)
{
80107919:	55                   	push   %ebp
8010791a:	89 e5                	mov    %esp,%ebp
8010791c:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
8010791f:	a1 84 c7 10 80       	mov    0x8010c784,%eax
80107924:	85 c0                	test   %eax,%eax
80107926:	75 07                	jne    8010792f <uartgetc+0x16>
    return -1;
80107928:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010792d:	eb 2c                	jmp    8010795b <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
8010792f:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107936:	e8 49 fe ff ff       	call   80107784 <inb>
8010793b:	0f b6 c0             	movzbl %al,%eax
8010793e:	83 e0 01             	and    $0x1,%eax
80107941:	85 c0                	test   %eax,%eax
80107943:	75 07                	jne    8010794c <uartgetc+0x33>
    return -1;
80107945:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010794a:	eb 0f                	jmp    8010795b <uartgetc+0x42>
  return inb(COM1+0);
8010794c:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107953:	e8 2c fe ff ff       	call   80107784 <inb>
80107958:	0f b6 c0             	movzbl %al,%eax
}
8010795b:	c9                   	leave  
8010795c:	c3                   	ret    

8010795d <uartintr>:

void
uartintr(void)
{
8010795d:	55                   	push   %ebp
8010795e:	89 e5                	mov    %esp,%ebp
80107960:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80107963:	c7 04 24 19 79 10 80 	movl   $0x80107919,(%esp)
8010796a:	e8 86 8e ff ff       	call   801007f5 <consoleintr>
}
8010796f:	c9                   	leave  
80107970:	c3                   	ret    
80107971:	00 00                	add    %al,(%eax)
	...

80107974 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107974:	6a 00                	push   $0x0
  pushl $0
80107976:	6a 00                	push   $0x0
  jmp alltraps
80107978:	e9 af f9 ff ff       	jmp    8010732c <alltraps>

8010797d <vector1>:
.globl vector1
vector1:
  pushl $0
8010797d:	6a 00                	push   $0x0
  pushl $1
8010797f:	6a 01                	push   $0x1
  jmp alltraps
80107981:	e9 a6 f9 ff ff       	jmp    8010732c <alltraps>

80107986 <vector2>:
.globl vector2
vector2:
  pushl $0
80107986:	6a 00                	push   $0x0
  pushl $2
80107988:	6a 02                	push   $0x2
  jmp alltraps
8010798a:	e9 9d f9 ff ff       	jmp    8010732c <alltraps>

8010798f <vector3>:
.globl vector3
vector3:
  pushl $0
8010798f:	6a 00                	push   $0x0
  pushl $3
80107991:	6a 03                	push   $0x3
  jmp alltraps
80107993:	e9 94 f9 ff ff       	jmp    8010732c <alltraps>

80107998 <vector4>:
.globl vector4
vector4:
  pushl $0
80107998:	6a 00                	push   $0x0
  pushl $4
8010799a:	6a 04                	push   $0x4
  jmp alltraps
8010799c:	e9 8b f9 ff ff       	jmp    8010732c <alltraps>

801079a1 <vector5>:
.globl vector5
vector5:
  pushl $0
801079a1:	6a 00                	push   $0x0
  pushl $5
801079a3:	6a 05                	push   $0x5
  jmp alltraps
801079a5:	e9 82 f9 ff ff       	jmp    8010732c <alltraps>

801079aa <vector6>:
.globl vector6
vector6:
  pushl $0
801079aa:	6a 00                	push   $0x0
  pushl $6
801079ac:	6a 06                	push   $0x6
  jmp alltraps
801079ae:	e9 79 f9 ff ff       	jmp    8010732c <alltraps>

801079b3 <vector7>:
.globl vector7
vector7:
  pushl $0
801079b3:	6a 00                	push   $0x0
  pushl $7
801079b5:	6a 07                	push   $0x7
  jmp alltraps
801079b7:	e9 70 f9 ff ff       	jmp    8010732c <alltraps>

801079bc <vector8>:
.globl vector8
vector8:
  pushl $8
801079bc:	6a 08                	push   $0x8
  jmp alltraps
801079be:	e9 69 f9 ff ff       	jmp    8010732c <alltraps>

801079c3 <vector9>:
.globl vector9
vector9:
  pushl $0
801079c3:	6a 00                	push   $0x0
  pushl $9
801079c5:	6a 09                	push   $0x9
  jmp alltraps
801079c7:	e9 60 f9 ff ff       	jmp    8010732c <alltraps>

801079cc <vector10>:
.globl vector10
vector10:
  pushl $10
801079cc:	6a 0a                	push   $0xa
  jmp alltraps
801079ce:	e9 59 f9 ff ff       	jmp    8010732c <alltraps>

801079d3 <vector11>:
.globl vector11
vector11:
  pushl $11
801079d3:	6a 0b                	push   $0xb
  jmp alltraps
801079d5:	e9 52 f9 ff ff       	jmp    8010732c <alltraps>

801079da <vector12>:
.globl vector12
vector12:
  pushl $12
801079da:	6a 0c                	push   $0xc
  jmp alltraps
801079dc:	e9 4b f9 ff ff       	jmp    8010732c <alltraps>

801079e1 <vector13>:
.globl vector13
vector13:
  pushl $13
801079e1:	6a 0d                	push   $0xd
  jmp alltraps
801079e3:	e9 44 f9 ff ff       	jmp    8010732c <alltraps>

801079e8 <vector14>:
.globl vector14
vector14:
  pushl $14
801079e8:	6a 0e                	push   $0xe
  jmp alltraps
801079ea:	e9 3d f9 ff ff       	jmp    8010732c <alltraps>

801079ef <vector15>:
.globl vector15
vector15:
  pushl $0
801079ef:	6a 00                	push   $0x0
  pushl $15
801079f1:	6a 0f                	push   $0xf
  jmp alltraps
801079f3:	e9 34 f9 ff ff       	jmp    8010732c <alltraps>

801079f8 <vector16>:
.globl vector16
vector16:
  pushl $0
801079f8:	6a 00                	push   $0x0
  pushl $16
801079fa:	6a 10                	push   $0x10
  jmp alltraps
801079fc:	e9 2b f9 ff ff       	jmp    8010732c <alltraps>

80107a01 <vector17>:
.globl vector17
vector17:
  pushl $17
80107a01:	6a 11                	push   $0x11
  jmp alltraps
80107a03:	e9 24 f9 ff ff       	jmp    8010732c <alltraps>

80107a08 <vector18>:
.globl vector18
vector18:
  pushl $0
80107a08:	6a 00                	push   $0x0
  pushl $18
80107a0a:	6a 12                	push   $0x12
  jmp alltraps
80107a0c:	e9 1b f9 ff ff       	jmp    8010732c <alltraps>

80107a11 <vector19>:
.globl vector19
vector19:
  pushl $0
80107a11:	6a 00                	push   $0x0
  pushl $19
80107a13:	6a 13                	push   $0x13
  jmp alltraps
80107a15:	e9 12 f9 ff ff       	jmp    8010732c <alltraps>

80107a1a <vector20>:
.globl vector20
vector20:
  pushl $0
80107a1a:	6a 00                	push   $0x0
  pushl $20
80107a1c:	6a 14                	push   $0x14
  jmp alltraps
80107a1e:	e9 09 f9 ff ff       	jmp    8010732c <alltraps>

80107a23 <vector21>:
.globl vector21
vector21:
  pushl $0
80107a23:	6a 00                	push   $0x0
  pushl $21
80107a25:	6a 15                	push   $0x15
  jmp alltraps
80107a27:	e9 00 f9 ff ff       	jmp    8010732c <alltraps>

80107a2c <vector22>:
.globl vector22
vector22:
  pushl $0
80107a2c:	6a 00                	push   $0x0
  pushl $22
80107a2e:	6a 16                	push   $0x16
  jmp alltraps
80107a30:	e9 f7 f8 ff ff       	jmp    8010732c <alltraps>

80107a35 <vector23>:
.globl vector23
vector23:
  pushl $0
80107a35:	6a 00                	push   $0x0
  pushl $23
80107a37:	6a 17                	push   $0x17
  jmp alltraps
80107a39:	e9 ee f8 ff ff       	jmp    8010732c <alltraps>

80107a3e <vector24>:
.globl vector24
vector24:
  pushl $0
80107a3e:	6a 00                	push   $0x0
  pushl $24
80107a40:	6a 18                	push   $0x18
  jmp alltraps
80107a42:	e9 e5 f8 ff ff       	jmp    8010732c <alltraps>

80107a47 <vector25>:
.globl vector25
vector25:
  pushl $0
80107a47:	6a 00                	push   $0x0
  pushl $25
80107a49:	6a 19                	push   $0x19
  jmp alltraps
80107a4b:	e9 dc f8 ff ff       	jmp    8010732c <alltraps>

80107a50 <vector26>:
.globl vector26
vector26:
  pushl $0
80107a50:	6a 00                	push   $0x0
  pushl $26
80107a52:	6a 1a                	push   $0x1a
  jmp alltraps
80107a54:	e9 d3 f8 ff ff       	jmp    8010732c <alltraps>

80107a59 <vector27>:
.globl vector27
vector27:
  pushl $0
80107a59:	6a 00                	push   $0x0
  pushl $27
80107a5b:	6a 1b                	push   $0x1b
  jmp alltraps
80107a5d:	e9 ca f8 ff ff       	jmp    8010732c <alltraps>

80107a62 <vector28>:
.globl vector28
vector28:
  pushl $0
80107a62:	6a 00                	push   $0x0
  pushl $28
80107a64:	6a 1c                	push   $0x1c
  jmp alltraps
80107a66:	e9 c1 f8 ff ff       	jmp    8010732c <alltraps>

80107a6b <vector29>:
.globl vector29
vector29:
  pushl $0
80107a6b:	6a 00                	push   $0x0
  pushl $29
80107a6d:	6a 1d                	push   $0x1d
  jmp alltraps
80107a6f:	e9 b8 f8 ff ff       	jmp    8010732c <alltraps>

80107a74 <vector30>:
.globl vector30
vector30:
  pushl $0
80107a74:	6a 00                	push   $0x0
  pushl $30
80107a76:	6a 1e                	push   $0x1e
  jmp alltraps
80107a78:	e9 af f8 ff ff       	jmp    8010732c <alltraps>

80107a7d <vector31>:
.globl vector31
vector31:
  pushl $0
80107a7d:	6a 00                	push   $0x0
  pushl $31
80107a7f:	6a 1f                	push   $0x1f
  jmp alltraps
80107a81:	e9 a6 f8 ff ff       	jmp    8010732c <alltraps>

80107a86 <vector32>:
.globl vector32
vector32:
  pushl $0
80107a86:	6a 00                	push   $0x0
  pushl $32
80107a88:	6a 20                	push   $0x20
  jmp alltraps
80107a8a:	e9 9d f8 ff ff       	jmp    8010732c <alltraps>

80107a8f <vector33>:
.globl vector33
vector33:
  pushl $0
80107a8f:	6a 00                	push   $0x0
  pushl $33
80107a91:	6a 21                	push   $0x21
  jmp alltraps
80107a93:	e9 94 f8 ff ff       	jmp    8010732c <alltraps>

80107a98 <vector34>:
.globl vector34
vector34:
  pushl $0
80107a98:	6a 00                	push   $0x0
  pushl $34
80107a9a:	6a 22                	push   $0x22
  jmp alltraps
80107a9c:	e9 8b f8 ff ff       	jmp    8010732c <alltraps>

80107aa1 <vector35>:
.globl vector35
vector35:
  pushl $0
80107aa1:	6a 00                	push   $0x0
  pushl $35
80107aa3:	6a 23                	push   $0x23
  jmp alltraps
80107aa5:	e9 82 f8 ff ff       	jmp    8010732c <alltraps>

80107aaa <vector36>:
.globl vector36
vector36:
  pushl $0
80107aaa:	6a 00                	push   $0x0
  pushl $36
80107aac:	6a 24                	push   $0x24
  jmp alltraps
80107aae:	e9 79 f8 ff ff       	jmp    8010732c <alltraps>

80107ab3 <vector37>:
.globl vector37
vector37:
  pushl $0
80107ab3:	6a 00                	push   $0x0
  pushl $37
80107ab5:	6a 25                	push   $0x25
  jmp alltraps
80107ab7:	e9 70 f8 ff ff       	jmp    8010732c <alltraps>

80107abc <vector38>:
.globl vector38
vector38:
  pushl $0
80107abc:	6a 00                	push   $0x0
  pushl $38
80107abe:	6a 26                	push   $0x26
  jmp alltraps
80107ac0:	e9 67 f8 ff ff       	jmp    8010732c <alltraps>

80107ac5 <vector39>:
.globl vector39
vector39:
  pushl $0
80107ac5:	6a 00                	push   $0x0
  pushl $39
80107ac7:	6a 27                	push   $0x27
  jmp alltraps
80107ac9:	e9 5e f8 ff ff       	jmp    8010732c <alltraps>

80107ace <vector40>:
.globl vector40
vector40:
  pushl $0
80107ace:	6a 00                	push   $0x0
  pushl $40
80107ad0:	6a 28                	push   $0x28
  jmp alltraps
80107ad2:	e9 55 f8 ff ff       	jmp    8010732c <alltraps>

80107ad7 <vector41>:
.globl vector41
vector41:
  pushl $0
80107ad7:	6a 00                	push   $0x0
  pushl $41
80107ad9:	6a 29                	push   $0x29
  jmp alltraps
80107adb:	e9 4c f8 ff ff       	jmp    8010732c <alltraps>

80107ae0 <vector42>:
.globl vector42
vector42:
  pushl $0
80107ae0:	6a 00                	push   $0x0
  pushl $42
80107ae2:	6a 2a                	push   $0x2a
  jmp alltraps
80107ae4:	e9 43 f8 ff ff       	jmp    8010732c <alltraps>

80107ae9 <vector43>:
.globl vector43
vector43:
  pushl $0
80107ae9:	6a 00                	push   $0x0
  pushl $43
80107aeb:	6a 2b                	push   $0x2b
  jmp alltraps
80107aed:	e9 3a f8 ff ff       	jmp    8010732c <alltraps>

80107af2 <vector44>:
.globl vector44
vector44:
  pushl $0
80107af2:	6a 00                	push   $0x0
  pushl $44
80107af4:	6a 2c                	push   $0x2c
  jmp alltraps
80107af6:	e9 31 f8 ff ff       	jmp    8010732c <alltraps>

80107afb <vector45>:
.globl vector45
vector45:
  pushl $0
80107afb:	6a 00                	push   $0x0
  pushl $45
80107afd:	6a 2d                	push   $0x2d
  jmp alltraps
80107aff:	e9 28 f8 ff ff       	jmp    8010732c <alltraps>

80107b04 <vector46>:
.globl vector46
vector46:
  pushl $0
80107b04:	6a 00                	push   $0x0
  pushl $46
80107b06:	6a 2e                	push   $0x2e
  jmp alltraps
80107b08:	e9 1f f8 ff ff       	jmp    8010732c <alltraps>

80107b0d <vector47>:
.globl vector47
vector47:
  pushl $0
80107b0d:	6a 00                	push   $0x0
  pushl $47
80107b0f:	6a 2f                	push   $0x2f
  jmp alltraps
80107b11:	e9 16 f8 ff ff       	jmp    8010732c <alltraps>

80107b16 <vector48>:
.globl vector48
vector48:
  pushl $0
80107b16:	6a 00                	push   $0x0
  pushl $48
80107b18:	6a 30                	push   $0x30
  jmp alltraps
80107b1a:	e9 0d f8 ff ff       	jmp    8010732c <alltraps>

80107b1f <vector49>:
.globl vector49
vector49:
  pushl $0
80107b1f:	6a 00                	push   $0x0
  pushl $49
80107b21:	6a 31                	push   $0x31
  jmp alltraps
80107b23:	e9 04 f8 ff ff       	jmp    8010732c <alltraps>

80107b28 <vector50>:
.globl vector50
vector50:
  pushl $0
80107b28:	6a 00                	push   $0x0
  pushl $50
80107b2a:	6a 32                	push   $0x32
  jmp alltraps
80107b2c:	e9 fb f7 ff ff       	jmp    8010732c <alltraps>

80107b31 <vector51>:
.globl vector51
vector51:
  pushl $0
80107b31:	6a 00                	push   $0x0
  pushl $51
80107b33:	6a 33                	push   $0x33
  jmp alltraps
80107b35:	e9 f2 f7 ff ff       	jmp    8010732c <alltraps>

80107b3a <vector52>:
.globl vector52
vector52:
  pushl $0
80107b3a:	6a 00                	push   $0x0
  pushl $52
80107b3c:	6a 34                	push   $0x34
  jmp alltraps
80107b3e:	e9 e9 f7 ff ff       	jmp    8010732c <alltraps>

80107b43 <vector53>:
.globl vector53
vector53:
  pushl $0
80107b43:	6a 00                	push   $0x0
  pushl $53
80107b45:	6a 35                	push   $0x35
  jmp alltraps
80107b47:	e9 e0 f7 ff ff       	jmp    8010732c <alltraps>

80107b4c <vector54>:
.globl vector54
vector54:
  pushl $0
80107b4c:	6a 00                	push   $0x0
  pushl $54
80107b4e:	6a 36                	push   $0x36
  jmp alltraps
80107b50:	e9 d7 f7 ff ff       	jmp    8010732c <alltraps>

80107b55 <vector55>:
.globl vector55
vector55:
  pushl $0
80107b55:	6a 00                	push   $0x0
  pushl $55
80107b57:	6a 37                	push   $0x37
  jmp alltraps
80107b59:	e9 ce f7 ff ff       	jmp    8010732c <alltraps>

80107b5e <vector56>:
.globl vector56
vector56:
  pushl $0
80107b5e:	6a 00                	push   $0x0
  pushl $56
80107b60:	6a 38                	push   $0x38
  jmp alltraps
80107b62:	e9 c5 f7 ff ff       	jmp    8010732c <alltraps>

80107b67 <vector57>:
.globl vector57
vector57:
  pushl $0
80107b67:	6a 00                	push   $0x0
  pushl $57
80107b69:	6a 39                	push   $0x39
  jmp alltraps
80107b6b:	e9 bc f7 ff ff       	jmp    8010732c <alltraps>

80107b70 <vector58>:
.globl vector58
vector58:
  pushl $0
80107b70:	6a 00                	push   $0x0
  pushl $58
80107b72:	6a 3a                	push   $0x3a
  jmp alltraps
80107b74:	e9 b3 f7 ff ff       	jmp    8010732c <alltraps>

80107b79 <vector59>:
.globl vector59
vector59:
  pushl $0
80107b79:	6a 00                	push   $0x0
  pushl $59
80107b7b:	6a 3b                	push   $0x3b
  jmp alltraps
80107b7d:	e9 aa f7 ff ff       	jmp    8010732c <alltraps>

80107b82 <vector60>:
.globl vector60
vector60:
  pushl $0
80107b82:	6a 00                	push   $0x0
  pushl $60
80107b84:	6a 3c                	push   $0x3c
  jmp alltraps
80107b86:	e9 a1 f7 ff ff       	jmp    8010732c <alltraps>

80107b8b <vector61>:
.globl vector61
vector61:
  pushl $0
80107b8b:	6a 00                	push   $0x0
  pushl $61
80107b8d:	6a 3d                	push   $0x3d
  jmp alltraps
80107b8f:	e9 98 f7 ff ff       	jmp    8010732c <alltraps>

80107b94 <vector62>:
.globl vector62
vector62:
  pushl $0
80107b94:	6a 00                	push   $0x0
  pushl $62
80107b96:	6a 3e                	push   $0x3e
  jmp alltraps
80107b98:	e9 8f f7 ff ff       	jmp    8010732c <alltraps>

80107b9d <vector63>:
.globl vector63
vector63:
  pushl $0
80107b9d:	6a 00                	push   $0x0
  pushl $63
80107b9f:	6a 3f                	push   $0x3f
  jmp alltraps
80107ba1:	e9 86 f7 ff ff       	jmp    8010732c <alltraps>

80107ba6 <vector64>:
.globl vector64
vector64:
  pushl $0
80107ba6:	6a 00                	push   $0x0
  pushl $64
80107ba8:	6a 40                	push   $0x40
  jmp alltraps
80107baa:	e9 7d f7 ff ff       	jmp    8010732c <alltraps>

80107baf <vector65>:
.globl vector65
vector65:
  pushl $0
80107baf:	6a 00                	push   $0x0
  pushl $65
80107bb1:	6a 41                	push   $0x41
  jmp alltraps
80107bb3:	e9 74 f7 ff ff       	jmp    8010732c <alltraps>

80107bb8 <vector66>:
.globl vector66
vector66:
  pushl $0
80107bb8:	6a 00                	push   $0x0
  pushl $66
80107bba:	6a 42                	push   $0x42
  jmp alltraps
80107bbc:	e9 6b f7 ff ff       	jmp    8010732c <alltraps>

80107bc1 <vector67>:
.globl vector67
vector67:
  pushl $0
80107bc1:	6a 00                	push   $0x0
  pushl $67
80107bc3:	6a 43                	push   $0x43
  jmp alltraps
80107bc5:	e9 62 f7 ff ff       	jmp    8010732c <alltraps>

80107bca <vector68>:
.globl vector68
vector68:
  pushl $0
80107bca:	6a 00                	push   $0x0
  pushl $68
80107bcc:	6a 44                	push   $0x44
  jmp alltraps
80107bce:	e9 59 f7 ff ff       	jmp    8010732c <alltraps>

80107bd3 <vector69>:
.globl vector69
vector69:
  pushl $0
80107bd3:	6a 00                	push   $0x0
  pushl $69
80107bd5:	6a 45                	push   $0x45
  jmp alltraps
80107bd7:	e9 50 f7 ff ff       	jmp    8010732c <alltraps>

80107bdc <vector70>:
.globl vector70
vector70:
  pushl $0
80107bdc:	6a 00                	push   $0x0
  pushl $70
80107bde:	6a 46                	push   $0x46
  jmp alltraps
80107be0:	e9 47 f7 ff ff       	jmp    8010732c <alltraps>

80107be5 <vector71>:
.globl vector71
vector71:
  pushl $0
80107be5:	6a 00                	push   $0x0
  pushl $71
80107be7:	6a 47                	push   $0x47
  jmp alltraps
80107be9:	e9 3e f7 ff ff       	jmp    8010732c <alltraps>

80107bee <vector72>:
.globl vector72
vector72:
  pushl $0
80107bee:	6a 00                	push   $0x0
  pushl $72
80107bf0:	6a 48                	push   $0x48
  jmp alltraps
80107bf2:	e9 35 f7 ff ff       	jmp    8010732c <alltraps>

80107bf7 <vector73>:
.globl vector73
vector73:
  pushl $0
80107bf7:	6a 00                	push   $0x0
  pushl $73
80107bf9:	6a 49                	push   $0x49
  jmp alltraps
80107bfb:	e9 2c f7 ff ff       	jmp    8010732c <alltraps>

80107c00 <vector74>:
.globl vector74
vector74:
  pushl $0
80107c00:	6a 00                	push   $0x0
  pushl $74
80107c02:	6a 4a                	push   $0x4a
  jmp alltraps
80107c04:	e9 23 f7 ff ff       	jmp    8010732c <alltraps>

80107c09 <vector75>:
.globl vector75
vector75:
  pushl $0
80107c09:	6a 00                	push   $0x0
  pushl $75
80107c0b:	6a 4b                	push   $0x4b
  jmp alltraps
80107c0d:	e9 1a f7 ff ff       	jmp    8010732c <alltraps>

80107c12 <vector76>:
.globl vector76
vector76:
  pushl $0
80107c12:	6a 00                	push   $0x0
  pushl $76
80107c14:	6a 4c                	push   $0x4c
  jmp alltraps
80107c16:	e9 11 f7 ff ff       	jmp    8010732c <alltraps>

80107c1b <vector77>:
.globl vector77
vector77:
  pushl $0
80107c1b:	6a 00                	push   $0x0
  pushl $77
80107c1d:	6a 4d                	push   $0x4d
  jmp alltraps
80107c1f:	e9 08 f7 ff ff       	jmp    8010732c <alltraps>

80107c24 <vector78>:
.globl vector78
vector78:
  pushl $0
80107c24:	6a 00                	push   $0x0
  pushl $78
80107c26:	6a 4e                	push   $0x4e
  jmp alltraps
80107c28:	e9 ff f6 ff ff       	jmp    8010732c <alltraps>

80107c2d <vector79>:
.globl vector79
vector79:
  pushl $0
80107c2d:	6a 00                	push   $0x0
  pushl $79
80107c2f:	6a 4f                	push   $0x4f
  jmp alltraps
80107c31:	e9 f6 f6 ff ff       	jmp    8010732c <alltraps>

80107c36 <vector80>:
.globl vector80
vector80:
  pushl $0
80107c36:	6a 00                	push   $0x0
  pushl $80
80107c38:	6a 50                	push   $0x50
  jmp alltraps
80107c3a:	e9 ed f6 ff ff       	jmp    8010732c <alltraps>

80107c3f <vector81>:
.globl vector81
vector81:
  pushl $0
80107c3f:	6a 00                	push   $0x0
  pushl $81
80107c41:	6a 51                	push   $0x51
  jmp alltraps
80107c43:	e9 e4 f6 ff ff       	jmp    8010732c <alltraps>

80107c48 <vector82>:
.globl vector82
vector82:
  pushl $0
80107c48:	6a 00                	push   $0x0
  pushl $82
80107c4a:	6a 52                	push   $0x52
  jmp alltraps
80107c4c:	e9 db f6 ff ff       	jmp    8010732c <alltraps>

80107c51 <vector83>:
.globl vector83
vector83:
  pushl $0
80107c51:	6a 00                	push   $0x0
  pushl $83
80107c53:	6a 53                	push   $0x53
  jmp alltraps
80107c55:	e9 d2 f6 ff ff       	jmp    8010732c <alltraps>

80107c5a <vector84>:
.globl vector84
vector84:
  pushl $0
80107c5a:	6a 00                	push   $0x0
  pushl $84
80107c5c:	6a 54                	push   $0x54
  jmp alltraps
80107c5e:	e9 c9 f6 ff ff       	jmp    8010732c <alltraps>

80107c63 <vector85>:
.globl vector85
vector85:
  pushl $0
80107c63:	6a 00                	push   $0x0
  pushl $85
80107c65:	6a 55                	push   $0x55
  jmp alltraps
80107c67:	e9 c0 f6 ff ff       	jmp    8010732c <alltraps>

80107c6c <vector86>:
.globl vector86
vector86:
  pushl $0
80107c6c:	6a 00                	push   $0x0
  pushl $86
80107c6e:	6a 56                	push   $0x56
  jmp alltraps
80107c70:	e9 b7 f6 ff ff       	jmp    8010732c <alltraps>

80107c75 <vector87>:
.globl vector87
vector87:
  pushl $0
80107c75:	6a 00                	push   $0x0
  pushl $87
80107c77:	6a 57                	push   $0x57
  jmp alltraps
80107c79:	e9 ae f6 ff ff       	jmp    8010732c <alltraps>

80107c7e <vector88>:
.globl vector88
vector88:
  pushl $0
80107c7e:	6a 00                	push   $0x0
  pushl $88
80107c80:	6a 58                	push   $0x58
  jmp alltraps
80107c82:	e9 a5 f6 ff ff       	jmp    8010732c <alltraps>

80107c87 <vector89>:
.globl vector89
vector89:
  pushl $0
80107c87:	6a 00                	push   $0x0
  pushl $89
80107c89:	6a 59                	push   $0x59
  jmp alltraps
80107c8b:	e9 9c f6 ff ff       	jmp    8010732c <alltraps>

80107c90 <vector90>:
.globl vector90
vector90:
  pushl $0
80107c90:	6a 00                	push   $0x0
  pushl $90
80107c92:	6a 5a                	push   $0x5a
  jmp alltraps
80107c94:	e9 93 f6 ff ff       	jmp    8010732c <alltraps>

80107c99 <vector91>:
.globl vector91
vector91:
  pushl $0
80107c99:	6a 00                	push   $0x0
  pushl $91
80107c9b:	6a 5b                	push   $0x5b
  jmp alltraps
80107c9d:	e9 8a f6 ff ff       	jmp    8010732c <alltraps>

80107ca2 <vector92>:
.globl vector92
vector92:
  pushl $0
80107ca2:	6a 00                	push   $0x0
  pushl $92
80107ca4:	6a 5c                	push   $0x5c
  jmp alltraps
80107ca6:	e9 81 f6 ff ff       	jmp    8010732c <alltraps>

80107cab <vector93>:
.globl vector93
vector93:
  pushl $0
80107cab:	6a 00                	push   $0x0
  pushl $93
80107cad:	6a 5d                	push   $0x5d
  jmp alltraps
80107caf:	e9 78 f6 ff ff       	jmp    8010732c <alltraps>

80107cb4 <vector94>:
.globl vector94
vector94:
  pushl $0
80107cb4:	6a 00                	push   $0x0
  pushl $94
80107cb6:	6a 5e                	push   $0x5e
  jmp alltraps
80107cb8:	e9 6f f6 ff ff       	jmp    8010732c <alltraps>

80107cbd <vector95>:
.globl vector95
vector95:
  pushl $0
80107cbd:	6a 00                	push   $0x0
  pushl $95
80107cbf:	6a 5f                	push   $0x5f
  jmp alltraps
80107cc1:	e9 66 f6 ff ff       	jmp    8010732c <alltraps>

80107cc6 <vector96>:
.globl vector96
vector96:
  pushl $0
80107cc6:	6a 00                	push   $0x0
  pushl $96
80107cc8:	6a 60                	push   $0x60
  jmp alltraps
80107cca:	e9 5d f6 ff ff       	jmp    8010732c <alltraps>

80107ccf <vector97>:
.globl vector97
vector97:
  pushl $0
80107ccf:	6a 00                	push   $0x0
  pushl $97
80107cd1:	6a 61                	push   $0x61
  jmp alltraps
80107cd3:	e9 54 f6 ff ff       	jmp    8010732c <alltraps>

80107cd8 <vector98>:
.globl vector98
vector98:
  pushl $0
80107cd8:	6a 00                	push   $0x0
  pushl $98
80107cda:	6a 62                	push   $0x62
  jmp alltraps
80107cdc:	e9 4b f6 ff ff       	jmp    8010732c <alltraps>

80107ce1 <vector99>:
.globl vector99
vector99:
  pushl $0
80107ce1:	6a 00                	push   $0x0
  pushl $99
80107ce3:	6a 63                	push   $0x63
  jmp alltraps
80107ce5:	e9 42 f6 ff ff       	jmp    8010732c <alltraps>

80107cea <vector100>:
.globl vector100
vector100:
  pushl $0
80107cea:	6a 00                	push   $0x0
  pushl $100
80107cec:	6a 64                	push   $0x64
  jmp alltraps
80107cee:	e9 39 f6 ff ff       	jmp    8010732c <alltraps>

80107cf3 <vector101>:
.globl vector101
vector101:
  pushl $0
80107cf3:	6a 00                	push   $0x0
  pushl $101
80107cf5:	6a 65                	push   $0x65
  jmp alltraps
80107cf7:	e9 30 f6 ff ff       	jmp    8010732c <alltraps>

80107cfc <vector102>:
.globl vector102
vector102:
  pushl $0
80107cfc:	6a 00                	push   $0x0
  pushl $102
80107cfe:	6a 66                	push   $0x66
  jmp alltraps
80107d00:	e9 27 f6 ff ff       	jmp    8010732c <alltraps>

80107d05 <vector103>:
.globl vector103
vector103:
  pushl $0
80107d05:	6a 00                	push   $0x0
  pushl $103
80107d07:	6a 67                	push   $0x67
  jmp alltraps
80107d09:	e9 1e f6 ff ff       	jmp    8010732c <alltraps>

80107d0e <vector104>:
.globl vector104
vector104:
  pushl $0
80107d0e:	6a 00                	push   $0x0
  pushl $104
80107d10:	6a 68                	push   $0x68
  jmp alltraps
80107d12:	e9 15 f6 ff ff       	jmp    8010732c <alltraps>

80107d17 <vector105>:
.globl vector105
vector105:
  pushl $0
80107d17:	6a 00                	push   $0x0
  pushl $105
80107d19:	6a 69                	push   $0x69
  jmp alltraps
80107d1b:	e9 0c f6 ff ff       	jmp    8010732c <alltraps>

80107d20 <vector106>:
.globl vector106
vector106:
  pushl $0
80107d20:	6a 00                	push   $0x0
  pushl $106
80107d22:	6a 6a                	push   $0x6a
  jmp alltraps
80107d24:	e9 03 f6 ff ff       	jmp    8010732c <alltraps>

80107d29 <vector107>:
.globl vector107
vector107:
  pushl $0
80107d29:	6a 00                	push   $0x0
  pushl $107
80107d2b:	6a 6b                	push   $0x6b
  jmp alltraps
80107d2d:	e9 fa f5 ff ff       	jmp    8010732c <alltraps>

80107d32 <vector108>:
.globl vector108
vector108:
  pushl $0
80107d32:	6a 00                	push   $0x0
  pushl $108
80107d34:	6a 6c                	push   $0x6c
  jmp alltraps
80107d36:	e9 f1 f5 ff ff       	jmp    8010732c <alltraps>

80107d3b <vector109>:
.globl vector109
vector109:
  pushl $0
80107d3b:	6a 00                	push   $0x0
  pushl $109
80107d3d:	6a 6d                	push   $0x6d
  jmp alltraps
80107d3f:	e9 e8 f5 ff ff       	jmp    8010732c <alltraps>

80107d44 <vector110>:
.globl vector110
vector110:
  pushl $0
80107d44:	6a 00                	push   $0x0
  pushl $110
80107d46:	6a 6e                	push   $0x6e
  jmp alltraps
80107d48:	e9 df f5 ff ff       	jmp    8010732c <alltraps>

80107d4d <vector111>:
.globl vector111
vector111:
  pushl $0
80107d4d:	6a 00                	push   $0x0
  pushl $111
80107d4f:	6a 6f                	push   $0x6f
  jmp alltraps
80107d51:	e9 d6 f5 ff ff       	jmp    8010732c <alltraps>

80107d56 <vector112>:
.globl vector112
vector112:
  pushl $0
80107d56:	6a 00                	push   $0x0
  pushl $112
80107d58:	6a 70                	push   $0x70
  jmp alltraps
80107d5a:	e9 cd f5 ff ff       	jmp    8010732c <alltraps>

80107d5f <vector113>:
.globl vector113
vector113:
  pushl $0
80107d5f:	6a 00                	push   $0x0
  pushl $113
80107d61:	6a 71                	push   $0x71
  jmp alltraps
80107d63:	e9 c4 f5 ff ff       	jmp    8010732c <alltraps>

80107d68 <vector114>:
.globl vector114
vector114:
  pushl $0
80107d68:	6a 00                	push   $0x0
  pushl $114
80107d6a:	6a 72                	push   $0x72
  jmp alltraps
80107d6c:	e9 bb f5 ff ff       	jmp    8010732c <alltraps>

80107d71 <vector115>:
.globl vector115
vector115:
  pushl $0
80107d71:	6a 00                	push   $0x0
  pushl $115
80107d73:	6a 73                	push   $0x73
  jmp alltraps
80107d75:	e9 b2 f5 ff ff       	jmp    8010732c <alltraps>

80107d7a <vector116>:
.globl vector116
vector116:
  pushl $0
80107d7a:	6a 00                	push   $0x0
  pushl $116
80107d7c:	6a 74                	push   $0x74
  jmp alltraps
80107d7e:	e9 a9 f5 ff ff       	jmp    8010732c <alltraps>

80107d83 <vector117>:
.globl vector117
vector117:
  pushl $0
80107d83:	6a 00                	push   $0x0
  pushl $117
80107d85:	6a 75                	push   $0x75
  jmp alltraps
80107d87:	e9 a0 f5 ff ff       	jmp    8010732c <alltraps>

80107d8c <vector118>:
.globl vector118
vector118:
  pushl $0
80107d8c:	6a 00                	push   $0x0
  pushl $118
80107d8e:	6a 76                	push   $0x76
  jmp alltraps
80107d90:	e9 97 f5 ff ff       	jmp    8010732c <alltraps>

80107d95 <vector119>:
.globl vector119
vector119:
  pushl $0
80107d95:	6a 00                	push   $0x0
  pushl $119
80107d97:	6a 77                	push   $0x77
  jmp alltraps
80107d99:	e9 8e f5 ff ff       	jmp    8010732c <alltraps>

80107d9e <vector120>:
.globl vector120
vector120:
  pushl $0
80107d9e:	6a 00                	push   $0x0
  pushl $120
80107da0:	6a 78                	push   $0x78
  jmp alltraps
80107da2:	e9 85 f5 ff ff       	jmp    8010732c <alltraps>

80107da7 <vector121>:
.globl vector121
vector121:
  pushl $0
80107da7:	6a 00                	push   $0x0
  pushl $121
80107da9:	6a 79                	push   $0x79
  jmp alltraps
80107dab:	e9 7c f5 ff ff       	jmp    8010732c <alltraps>

80107db0 <vector122>:
.globl vector122
vector122:
  pushl $0
80107db0:	6a 00                	push   $0x0
  pushl $122
80107db2:	6a 7a                	push   $0x7a
  jmp alltraps
80107db4:	e9 73 f5 ff ff       	jmp    8010732c <alltraps>

80107db9 <vector123>:
.globl vector123
vector123:
  pushl $0
80107db9:	6a 00                	push   $0x0
  pushl $123
80107dbb:	6a 7b                	push   $0x7b
  jmp alltraps
80107dbd:	e9 6a f5 ff ff       	jmp    8010732c <alltraps>

80107dc2 <vector124>:
.globl vector124
vector124:
  pushl $0
80107dc2:	6a 00                	push   $0x0
  pushl $124
80107dc4:	6a 7c                	push   $0x7c
  jmp alltraps
80107dc6:	e9 61 f5 ff ff       	jmp    8010732c <alltraps>

80107dcb <vector125>:
.globl vector125
vector125:
  pushl $0
80107dcb:	6a 00                	push   $0x0
  pushl $125
80107dcd:	6a 7d                	push   $0x7d
  jmp alltraps
80107dcf:	e9 58 f5 ff ff       	jmp    8010732c <alltraps>

80107dd4 <vector126>:
.globl vector126
vector126:
  pushl $0
80107dd4:	6a 00                	push   $0x0
  pushl $126
80107dd6:	6a 7e                	push   $0x7e
  jmp alltraps
80107dd8:	e9 4f f5 ff ff       	jmp    8010732c <alltraps>

80107ddd <vector127>:
.globl vector127
vector127:
  pushl $0
80107ddd:	6a 00                	push   $0x0
  pushl $127
80107ddf:	6a 7f                	push   $0x7f
  jmp alltraps
80107de1:	e9 46 f5 ff ff       	jmp    8010732c <alltraps>

80107de6 <vector128>:
.globl vector128
vector128:
  pushl $0
80107de6:	6a 00                	push   $0x0
  pushl $128
80107de8:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107ded:	e9 3a f5 ff ff       	jmp    8010732c <alltraps>

80107df2 <vector129>:
.globl vector129
vector129:
  pushl $0
80107df2:	6a 00                	push   $0x0
  pushl $129
80107df4:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107df9:	e9 2e f5 ff ff       	jmp    8010732c <alltraps>

80107dfe <vector130>:
.globl vector130
vector130:
  pushl $0
80107dfe:	6a 00                	push   $0x0
  pushl $130
80107e00:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107e05:	e9 22 f5 ff ff       	jmp    8010732c <alltraps>

80107e0a <vector131>:
.globl vector131
vector131:
  pushl $0
80107e0a:	6a 00                	push   $0x0
  pushl $131
80107e0c:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107e11:	e9 16 f5 ff ff       	jmp    8010732c <alltraps>

80107e16 <vector132>:
.globl vector132
vector132:
  pushl $0
80107e16:	6a 00                	push   $0x0
  pushl $132
80107e18:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107e1d:	e9 0a f5 ff ff       	jmp    8010732c <alltraps>

80107e22 <vector133>:
.globl vector133
vector133:
  pushl $0
80107e22:	6a 00                	push   $0x0
  pushl $133
80107e24:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107e29:	e9 fe f4 ff ff       	jmp    8010732c <alltraps>

80107e2e <vector134>:
.globl vector134
vector134:
  pushl $0
80107e2e:	6a 00                	push   $0x0
  pushl $134
80107e30:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107e35:	e9 f2 f4 ff ff       	jmp    8010732c <alltraps>

80107e3a <vector135>:
.globl vector135
vector135:
  pushl $0
80107e3a:	6a 00                	push   $0x0
  pushl $135
80107e3c:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107e41:	e9 e6 f4 ff ff       	jmp    8010732c <alltraps>

80107e46 <vector136>:
.globl vector136
vector136:
  pushl $0
80107e46:	6a 00                	push   $0x0
  pushl $136
80107e48:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107e4d:	e9 da f4 ff ff       	jmp    8010732c <alltraps>

80107e52 <vector137>:
.globl vector137
vector137:
  pushl $0
80107e52:	6a 00                	push   $0x0
  pushl $137
80107e54:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107e59:	e9 ce f4 ff ff       	jmp    8010732c <alltraps>

80107e5e <vector138>:
.globl vector138
vector138:
  pushl $0
80107e5e:	6a 00                	push   $0x0
  pushl $138
80107e60:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107e65:	e9 c2 f4 ff ff       	jmp    8010732c <alltraps>

80107e6a <vector139>:
.globl vector139
vector139:
  pushl $0
80107e6a:	6a 00                	push   $0x0
  pushl $139
80107e6c:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107e71:	e9 b6 f4 ff ff       	jmp    8010732c <alltraps>

80107e76 <vector140>:
.globl vector140
vector140:
  pushl $0
80107e76:	6a 00                	push   $0x0
  pushl $140
80107e78:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107e7d:	e9 aa f4 ff ff       	jmp    8010732c <alltraps>

80107e82 <vector141>:
.globl vector141
vector141:
  pushl $0
80107e82:	6a 00                	push   $0x0
  pushl $141
80107e84:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107e89:	e9 9e f4 ff ff       	jmp    8010732c <alltraps>

80107e8e <vector142>:
.globl vector142
vector142:
  pushl $0
80107e8e:	6a 00                	push   $0x0
  pushl $142
80107e90:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107e95:	e9 92 f4 ff ff       	jmp    8010732c <alltraps>

80107e9a <vector143>:
.globl vector143
vector143:
  pushl $0
80107e9a:	6a 00                	push   $0x0
  pushl $143
80107e9c:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107ea1:	e9 86 f4 ff ff       	jmp    8010732c <alltraps>

80107ea6 <vector144>:
.globl vector144
vector144:
  pushl $0
80107ea6:	6a 00                	push   $0x0
  pushl $144
80107ea8:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107ead:	e9 7a f4 ff ff       	jmp    8010732c <alltraps>

80107eb2 <vector145>:
.globl vector145
vector145:
  pushl $0
80107eb2:	6a 00                	push   $0x0
  pushl $145
80107eb4:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107eb9:	e9 6e f4 ff ff       	jmp    8010732c <alltraps>

80107ebe <vector146>:
.globl vector146
vector146:
  pushl $0
80107ebe:	6a 00                	push   $0x0
  pushl $146
80107ec0:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107ec5:	e9 62 f4 ff ff       	jmp    8010732c <alltraps>

80107eca <vector147>:
.globl vector147
vector147:
  pushl $0
80107eca:	6a 00                	push   $0x0
  pushl $147
80107ecc:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107ed1:	e9 56 f4 ff ff       	jmp    8010732c <alltraps>

80107ed6 <vector148>:
.globl vector148
vector148:
  pushl $0
80107ed6:	6a 00                	push   $0x0
  pushl $148
80107ed8:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107edd:	e9 4a f4 ff ff       	jmp    8010732c <alltraps>

80107ee2 <vector149>:
.globl vector149
vector149:
  pushl $0
80107ee2:	6a 00                	push   $0x0
  pushl $149
80107ee4:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107ee9:	e9 3e f4 ff ff       	jmp    8010732c <alltraps>

80107eee <vector150>:
.globl vector150
vector150:
  pushl $0
80107eee:	6a 00                	push   $0x0
  pushl $150
80107ef0:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107ef5:	e9 32 f4 ff ff       	jmp    8010732c <alltraps>

80107efa <vector151>:
.globl vector151
vector151:
  pushl $0
80107efa:	6a 00                	push   $0x0
  pushl $151
80107efc:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107f01:	e9 26 f4 ff ff       	jmp    8010732c <alltraps>

80107f06 <vector152>:
.globl vector152
vector152:
  pushl $0
80107f06:	6a 00                	push   $0x0
  pushl $152
80107f08:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107f0d:	e9 1a f4 ff ff       	jmp    8010732c <alltraps>

80107f12 <vector153>:
.globl vector153
vector153:
  pushl $0
80107f12:	6a 00                	push   $0x0
  pushl $153
80107f14:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107f19:	e9 0e f4 ff ff       	jmp    8010732c <alltraps>

80107f1e <vector154>:
.globl vector154
vector154:
  pushl $0
80107f1e:	6a 00                	push   $0x0
  pushl $154
80107f20:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107f25:	e9 02 f4 ff ff       	jmp    8010732c <alltraps>

80107f2a <vector155>:
.globl vector155
vector155:
  pushl $0
80107f2a:	6a 00                	push   $0x0
  pushl $155
80107f2c:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107f31:	e9 f6 f3 ff ff       	jmp    8010732c <alltraps>

80107f36 <vector156>:
.globl vector156
vector156:
  pushl $0
80107f36:	6a 00                	push   $0x0
  pushl $156
80107f38:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107f3d:	e9 ea f3 ff ff       	jmp    8010732c <alltraps>

80107f42 <vector157>:
.globl vector157
vector157:
  pushl $0
80107f42:	6a 00                	push   $0x0
  pushl $157
80107f44:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107f49:	e9 de f3 ff ff       	jmp    8010732c <alltraps>

80107f4e <vector158>:
.globl vector158
vector158:
  pushl $0
80107f4e:	6a 00                	push   $0x0
  pushl $158
80107f50:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107f55:	e9 d2 f3 ff ff       	jmp    8010732c <alltraps>

80107f5a <vector159>:
.globl vector159
vector159:
  pushl $0
80107f5a:	6a 00                	push   $0x0
  pushl $159
80107f5c:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107f61:	e9 c6 f3 ff ff       	jmp    8010732c <alltraps>

80107f66 <vector160>:
.globl vector160
vector160:
  pushl $0
80107f66:	6a 00                	push   $0x0
  pushl $160
80107f68:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107f6d:	e9 ba f3 ff ff       	jmp    8010732c <alltraps>

80107f72 <vector161>:
.globl vector161
vector161:
  pushl $0
80107f72:	6a 00                	push   $0x0
  pushl $161
80107f74:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107f79:	e9 ae f3 ff ff       	jmp    8010732c <alltraps>

80107f7e <vector162>:
.globl vector162
vector162:
  pushl $0
80107f7e:	6a 00                	push   $0x0
  pushl $162
80107f80:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107f85:	e9 a2 f3 ff ff       	jmp    8010732c <alltraps>

80107f8a <vector163>:
.globl vector163
vector163:
  pushl $0
80107f8a:	6a 00                	push   $0x0
  pushl $163
80107f8c:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107f91:	e9 96 f3 ff ff       	jmp    8010732c <alltraps>

80107f96 <vector164>:
.globl vector164
vector164:
  pushl $0
80107f96:	6a 00                	push   $0x0
  pushl $164
80107f98:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107f9d:	e9 8a f3 ff ff       	jmp    8010732c <alltraps>

80107fa2 <vector165>:
.globl vector165
vector165:
  pushl $0
80107fa2:	6a 00                	push   $0x0
  pushl $165
80107fa4:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107fa9:	e9 7e f3 ff ff       	jmp    8010732c <alltraps>

80107fae <vector166>:
.globl vector166
vector166:
  pushl $0
80107fae:	6a 00                	push   $0x0
  pushl $166
80107fb0:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107fb5:	e9 72 f3 ff ff       	jmp    8010732c <alltraps>

80107fba <vector167>:
.globl vector167
vector167:
  pushl $0
80107fba:	6a 00                	push   $0x0
  pushl $167
80107fbc:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107fc1:	e9 66 f3 ff ff       	jmp    8010732c <alltraps>

80107fc6 <vector168>:
.globl vector168
vector168:
  pushl $0
80107fc6:	6a 00                	push   $0x0
  pushl $168
80107fc8:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107fcd:	e9 5a f3 ff ff       	jmp    8010732c <alltraps>

80107fd2 <vector169>:
.globl vector169
vector169:
  pushl $0
80107fd2:	6a 00                	push   $0x0
  pushl $169
80107fd4:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107fd9:	e9 4e f3 ff ff       	jmp    8010732c <alltraps>

80107fde <vector170>:
.globl vector170
vector170:
  pushl $0
80107fde:	6a 00                	push   $0x0
  pushl $170
80107fe0:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107fe5:	e9 42 f3 ff ff       	jmp    8010732c <alltraps>

80107fea <vector171>:
.globl vector171
vector171:
  pushl $0
80107fea:	6a 00                	push   $0x0
  pushl $171
80107fec:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107ff1:	e9 36 f3 ff ff       	jmp    8010732c <alltraps>

80107ff6 <vector172>:
.globl vector172
vector172:
  pushl $0
80107ff6:	6a 00                	push   $0x0
  pushl $172
80107ff8:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107ffd:	e9 2a f3 ff ff       	jmp    8010732c <alltraps>

80108002 <vector173>:
.globl vector173
vector173:
  pushl $0
80108002:	6a 00                	push   $0x0
  pushl $173
80108004:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80108009:	e9 1e f3 ff ff       	jmp    8010732c <alltraps>

8010800e <vector174>:
.globl vector174
vector174:
  pushl $0
8010800e:	6a 00                	push   $0x0
  pushl $174
80108010:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80108015:	e9 12 f3 ff ff       	jmp    8010732c <alltraps>

8010801a <vector175>:
.globl vector175
vector175:
  pushl $0
8010801a:	6a 00                	push   $0x0
  pushl $175
8010801c:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80108021:	e9 06 f3 ff ff       	jmp    8010732c <alltraps>

80108026 <vector176>:
.globl vector176
vector176:
  pushl $0
80108026:	6a 00                	push   $0x0
  pushl $176
80108028:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010802d:	e9 fa f2 ff ff       	jmp    8010732c <alltraps>

80108032 <vector177>:
.globl vector177
vector177:
  pushl $0
80108032:	6a 00                	push   $0x0
  pushl $177
80108034:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80108039:	e9 ee f2 ff ff       	jmp    8010732c <alltraps>

8010803e <vector178>:
.globl vector178
vector178:
  pushl $0
8010803e:	6a 00                	push   $0x0
  pushl $178
80108040:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80108045:	e9 e2 f2 ff ff       	jmp    8010732c <alltraps>

8010804a <vector179>:
.globl vector179
vector179:
  pushl $0
8010804a:	6a 00                	push   $0x0
  pushl $179
8010804c:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80108051:	e9 d6 f2 ff ff       	jmp    8010732c <alltraps>

80108056 <vector180>:
.globl vector180
vector180:
  pushl $0
80108056:	6a 00                	push   $0x0
  pushl $180
80108058:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
8010805d:	e9 ca f2 ff ff       	jmp    8010732c <alltraps>

80108062 <vector181>:
.globl vector181
vector181:
  pushl $0
80108062:	6a 00                	push   $0x0
  pushl $181
80108064:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80108069:	e9 be f2 ff ff       	jmp    8010732c <alltraps>

8010806e <vector182>:
.globl vector182
vector182:
  pushl $0
8010806e:	6a 00                	push   $0x0
  pushl $182
80108070:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80108075:	e9 b2 f2 ff ff       	jmp    8010732c <alltraps>

8010807a <vector183>:
.globl vector183
vector183:
  pushl $0
8010807a:	6a 00                	push   $0x0
  pushl $183
8010807c:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108081:	e9 a6 f2 ff ff       	jmp    8010732c <alltraps>

80108086 <vector184>:
.globl vector184
vector184:
  pushl $0
80108086:	6a 00                	push   $0x0
  pushl $184
80108088:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
8010808d:	e9 9a f2 ff ff       	jmp    8010732c <alltraps>

80108092 <vector185>:
.globl vector185
vector185:
  pushl $0
80108092:	6a 00                	push   $0x0
  pushl $185
80108094:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80108099:	e9 8e f2 ff ff       	jmp    8010732c <alltraps>

8010809e <vector186>:
.globl vector186
vector186:
  pushl $0
8010809e:	6a 00                	push   $0x0
  pushl $186
801080a0:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801080a5:	e9 82 f2 ff ff       	jmp    8010732c <alltraps>

801080aa <vector187>:
.globl vector187
vector187:
  pushl $0
801080aa:	6a 00                	push   $0x0
  pushl $187
801080ac:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801080b1:	e9 76 f2 ff ff       	jmp    8010732c <alltraps>

801080b6 <vector188>:
.globl vector188
vector188:
  pushl $0
801080b6:	6a 00                	push   $0x0
  pushl $188
801080b8:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
801080bd:	e9 6a f2 ff ff       	jmp    8010732c <alltraps>

801080c2 <vector189>:
.globl vector189
vector189:
  pushl $0
801080c2:	6a 00                	push   $0x0
  pushl $189
801080c4:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
801080c9:	e9 5e f2 ff ff       	jmp    8010732c <alltraps>

801080ce <vector190>:
.globl vector190
vector190:
  pushl $0
801080ce:	6a 00                	push   $0x0
  pushl $190
801080d0:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
801080d5:	e9 52 f2 ff ff       	jmp    8010732c <alltraps>

801080da <vector191>:
.globl vector191
vector191:
  pushl $0
801080da:	6a 00                	push   $0x0
  pushl $191
801080dc:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801080e1:	e9 46 f2 ff ff       	jmp    8010732c <alltraps>

801080e6 <vector192>:
.globl vector192
vector192:
  pushl $0
801080e6:	6a 00                	push   $0x0
  pushl $192
801080e8:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801080ed:	e9 3a f2 ff ff       	jmp    8010732c <alltraps>

801080f2 <vector193>:
.globl vector193
vector193:
  pushl $0
801080f2:	6a 00                	push   $0x0
  pushl $193
801080f4:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801080f9:	e9 2e f2 ff ff       	jmp    8010732c <alltraps>

801080fe <vector194>:
.globl vector194
vector194:
  pushl $0
801080fe:	6a 00                	push   $0x0
  pushl $194
80108100:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80108105:	e9 22 f2 ff ff       	jmp    8010732c <alltraps>

8010810a <vector195>:
.globl vector195
vector195:
  pushl $0
8010810a:	6a 00                	push   $0x0
  pushl $195
8010810c:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80108111:	e9 16 f2 ff ff       	jmp    8010732c <alltraps>

80108116 <vector196>:
.globl vector196
vector196:
  pushl $0
80108116:	6a 00                	push   $0x0
  pushl $196
80108118:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010811d:	e9 0a f2 ff ff       	jmp    8010732c <alltraps>

80108122 <vector197>:
.globl vector197
vector197:
  pushl $0
80108122:	6a 00                	push   $0x0
  pushl $197
80108124:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80108129:	e9 fe f1 ff ff       	jmp    8010732c <alltraps>

8010812e <vector198>:
.globl vector198
vector198:
  pushl $0
8010812e:	6a 00                	push   $0x0
  pushl $198
80108130:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80108135:	e9 f2 f1 ff ff       	jmp    8010732c <alltraps>

8010813a <vector199>:
.globl vector199
vector199:
  pushl $0
8010813a:	6a 00                	push   $0x0
  pushl $199
8010813c:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108141:	e9 e6 f1 ff ff       	jmp    8010732c <alltraps>

80108146 <vector200>:
.globl vector200
vector200:
  pushl $0
80108146:	6a 00                	push   $0x0
  pushl $200
80108148:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010814d:	e9 da f1 ff ff       	jmp    8010732c <alltraps>

80108152 <vector201>:
.globl vector201
vector201:
  pushl $0
80108152:	6a 00                	push   $0x0
  pushl $201
80108154:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80108159:	e9 ce f1 ff ff       	jmp    8010732c <alltraps>

8010815e <vector202>:
.globl vector202
vector202:
  pushl $0
8010815e:	6a 00                	push   $0x0
  pushl $202
80108160:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80108165:	e9 c2 f1 ff ff       	jmp    8010732c <alltraps>

8010816a <vector203>:
.globl vector203
vector203:
  pushl $0
8010816a:	6a 00                	push   $0x0
  pushl $203
8010816c:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108171:	e9 b6 f1 ff ff       	jmp    8010732c <alltraps>

80108176 <vector204>:
.globl vector204
vector204:
  pushl $0
80108176:	6a 00                	push   $0x0
  pushl $204
80108178:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
8010817d:	e9 aa f1 ff ff       	jmp    8010732c <alltraps>

80108182 <vector205>:
.globl vector205
vector205:
  pushl $0
80108182:	6a 00                	push   $0x0
  pushl $205
80108184:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80108189:	e9 9e f1 ff ff       	jmp    8010732c <alltraps>

8010818e <vector206>:
.globl vector206
vector206:
  pushl $0
8010818e:	6a 00                	push   $0x0
  pushl $206
80108190:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80108195:	e9 92 f1 ff ff       	jmp    8010732c <alltraps>

8010819a <vector207>:
.globl vector207
vector207:
  pushl $0
8010819a:	6a 00                	push   $0x0
  pushl $207
8010819c:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801081a1:	e9 86 f1 ff ff       	jmp    8010732c <alltraps>

801081a6 <vector208>:
.globl vector208
vector208:
  pushl $0
801081a6:	6a 00                	push   $0x0
  pushl $208
801081a8:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801081ad:	e9 7a f1 ff ff       	jmp    8010732c <alltraps>

801081b2 <vector209>:
.globl vector209
vector209:
  pushl $0
801081b2:	6a 00                	push   $0x0
  pushl $209
801081b4:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
801081b9:	e9 6e f1 ff ff       	jmp    8010732c <alltraps>

801081be <vector210>:
.globl vector210
vector210:
  pushl $0
801081be:	6a 00                	push   $0x0
  pushl $210
801081c0:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
801081c5:	e9 62 f1 ff ff       	jmp    8010732c <alltraps>

801081ca <vector211>:
.globl vector211
vector211:
  pushl $0
801081ca:	6a 00                	push   $0x0
  pushl $211
801081cc:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
801081d1:	e9 56 f1 ff ff       	jmp    8010732c <alltraps>

801081d6 <vector212>:
.globl vector212
vector212:
  pushl $0
801081d6:	6a 00                	push   $0x0
  pushl $212
801081d8:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801081dd:	e9 4a f1 ff ff       	jmp    8010732c <alltraps>

801081e2 <vector213>:
.globl vector213
vector213:
  pushl $0
801081e2:	6a 00                	push   $0x0
  pushl $213
801081e4:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801081e9:	e9 3e f1 ff ff       	jmp    8010732c <alltraps>

801081ee <vector214>:
.globl vector214
vector214:
  pushl $0
801081ee:	6a 00                	push   $0x0
  pushl $214
801081f0:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801081f5:	e9 32 f1 ff ff       	jmp    8010732c <alltraps>

801081fa <vector215>:
.globl vector215
vector215:
  pushl $0
801081fa:	6a 00                	push   $0x0
  pushl $215
801081fc:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108201:	e9 26 f1 ff ff       	jmp    8010732c <alltraps>

80108206 <vector216>:
.globl vector216
vector216:
  pushl $0
80108206:	6a 00                	push   $0x0
  pushl $216
80108208:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010820d:	e9 1a f1 ff ff       	jmp    8010732c <alltraps>

80108212 <vector217>:
.globl vector217
vector217:
  pushl $0
80108212:	6a 00                	push   $0x0
  pushl $217
80108214:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108219:	e9 0e f1 ff ff       	jmp    8010732c <alltraps>

8010821e <vector218>:
.globl vector218
vector218:
  pushl $0
8010821e:	6a 00                	push   $0x0
  pushl $218
80108220:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108225:	e9 02 f1 ff ff       	jmp    8010732c <alltraps>

8010822a <vector219>:
.globl vector219
vector219:
  pushl $0
8010822a:	6a 00                	push   $0x0
  pushl $219
8010822c:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108231:	e9 f6 f0 ff ff       	jmp    8010732c <alltraps>

80108236 <vector220>:
.globl vector220
vector220:
  pushl $0
80108236:	6a 00                	push   $0x0
  pushl $220
80108238:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010823d:	e9 ea f0 ff ff       	jmp    8010732c <alltraps>

80108242 <vector221>:
.globl vector221
vector221:
  pushl $0
80108242:	6a 00                	push   $0x0
  pushl $221
80108244:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108249:	e9 de f0 ff ff       	jmp    8010732c <alltraps>

8010824e <vector222>:
.globl vector222
vector222:
  pushl $0
8010824e:	6a 00                	push   $0x0
  pushl $222
80108250:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80108255:	e9 d2 f0 ff ff       	jmp    8010732c <alltraps>

8010825a <vector223>:
.globl vector223
vector223:
  pushl $0
8010825a:	6a 00                	push   $0x0
  pushl $223
8010825c:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108261:	e9 c6 f0 ff ff       	jmp    8010732c <alltraps>

80108266 <vector224>:
.globl vector224
vector224:
  pushl $0
80108266:	6a 00                	push   $0x0
  pushl $224
80108268:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010826d:	e9 ba f0 ff ff       	jmp    8010732c <alltraps>

80108272 <vector225>:
.globl vector225
vector225:
  pushl $0
80108272:	6a 00                	push   $0x0
  pushl $225
80108274:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80108279:	e9 ae f0 ff ff       	jmp    8010732c <alltraps>

8010827e <vector226>:
.globl vector226
vector226:
  pushl $0
8010827e:	6a 00                	push   $0x0
  pushl $226
80108280:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108285:	e9 a2 f0 ff ff       	jmp    8010732c <alltraps>

8010828a <vector227>:
.globl vector227
vector227:
  pushl $0
8010828a:	6a 00                	push   $0x0
  pushl $227
8010828c:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108291:	e9 96 f0 ff ff       	jmp    8010732c <alltraps>

80108296 <vector228>:
.globl vector228
vector228:
  pushl $0
80108296:	6a 00                	push   $0x0
  pushl $228
80108298:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010829d:	e9 8a f0 ff ff       	jmp    8010732c <alltraps>

801082a2 <vector229>:
.globl vector229
vector229:
  pushl $0
801082a2:	6a 00                	push   $0x0
  pushl $229
801082a4:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801082a9:	e9 7e f0 ff ff       	jmp    8010732c <alltraps>

801082ae <vector230>:
.globl vector230
vector230:
  pushl $0
801082ae:	6a 00                	push   $0x0
  pushl $230
801082b0:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801082b5:	e9 72 f0 ff ff       	jmp    8010732c <alltraps>

801082ba <vector231>:
.globl vector231
vector231:
  pushl $0
801082ba:	6a 00                	push   $0x0
  pushl $231
801082bc:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801082c1:	e9 66 f0 ff ff       	jmp    8010732c <alltraps>

801082c6 <vector232>:
.globl vector232
vector232:
  pushl $0
801082c6:	6a 00                	push   $0x0
  pushl $232
801082c8:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801082cd:	e9 5a f0 ff ff       	jmp    8010732c <alltraps>

801082d2 <vector233>:
.globl vector233
vector233:
  pushl $0
801082d2:	6a 00                	push   $0x0
  pushl $233
801082d4:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801082d9:	e9 4e f0 ff ff       	jmp    8010732c <alltraps>

801082de <vector234>:
.globl vector234
vector234:
  pushl $0
801082de:	6a 00                	push   $0x0
  pushl $234
801082e0:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801082e5:	e9 42 f0 ff ff       	jmp    8010732c <alltraps>

801082ea <vector235>:
.globl vector235
vector235:
  pushl $0
801082ea:	6a 00                	push   $0x0
  pushl $235
801082ec:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801082f1:	e9 36 f0 ff ff       	jmp    8010732c <alltraps>

801082f6 <vector236>:
.globl vector236
vector236:
  pushl $0
801082f6:	6a 00                	push   $0x0
  pushl $236
801082f8:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801082fd:	e9 2a f0 ff ff       	jmp    8010732c <alltraps>

80108302 <vector237>:
.globl vector237
vector237:
  pushl $0
80108302:	6a 00                	push   $0x0
  pushl $237
80108304:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108309:	e9 1e f0 ff ff       	jmp    8010732c <alltraps>

8010830e <vector238>:
.globl vector238
vector238:
  pushl $0
8010830e:	6a 00                	push   $0x0
  pushl $238
80108310:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108315:	e9 12 f0 ff ff       	jmp    8010732c <alltraps>

8010831a <vector239>:
.globl vector239
vector239:
  pushl $0
8010831a:	6a 00                	push   $0x0
  pushl $239
8010831c:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108321:	e9 06 f0 ff ff       	jmp    8010732c <alltraps>

80108326 <vector240>:
.globl vector240
vector240:
  pushl $0
80108326:	6a 00                	push   $0x0
  pushl $240
80108328:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010832d:	e9 fa ef ff ff       	jmp    8010732c <alltraps>

80108332 <vector241>:
.globl vector241
vector241:
  pushl $0
80108332:	6a 00                	push   $0x0
  pushl $241
80108334:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108339:	e9 ee ef ff ff       	jmp    8010732c <alltraps>

8010833e <vector242>:
.globl vector242
vector242:
  pushl $0
8010833e:	6a 00                	push   $0x0
  pushl $242
80108340:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80108345:	e9 e2 ef ff ff       	jmp    8010732c <alltraps>

8010834a <vector243>:
.globl vector243
vector243:
  pushl $0
8010834a:	6a 00                	push   $0x0
  pushl $243
8010834c:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108351:	e9 d6 ef ff ff       	jmp    8010732c <alltraps>

80108356 <vector244>:
.globl vector244
vector244:
  pushl $0
80108356:	6a 00                	push   $0x0
  pushl $244
80108358:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010835d:	e9 ca ef ff ff       	jmp    8010732c <alltraps>

80108362 <vector245>:
.globl vector245
vector245:
  pushl $0
80108362:	6a 00                	push   $0x0
  pushl $245
80108364:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80108369:	e9 be ef ff ff       	jmp    8010732c <alltraps>

8010836e <vector246>:
.globl vector246
vector246:
  pushl $0
8010836e:	6a 00                	push   $0x0
  pushl $246
80108370:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80108375:	e9 b2 ef ff ff       	jmp    8010732c <alltraps>

8010837a <vector247>:
.globl vector247
vector247:
  pushl $0
8010837a:	6a 00                	push   $0x0
  pushl $247
8010837c:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108381:	e9 a6 ef ff ff       	jmp    8010732c <alltraps>

80108386 <vector248>:
.globl vector248
vector248:
  pushl $0
80108386:	6a 00                	push   $0x0
  pushl $248
80108388:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010838d:	e9 9a ef ff ff       	jmp    8010732c <alltraps>

80108392 <vector249>:
.globl vector249
vector249:
  pushl $0
80108392:	6a 00                	push   $0x0
  pushl $249
80108394:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80108399:	e9 8e ef ff ff       	jmp    8010732c <alltraps>

8010839e <vector250>:
.globl vector250
vector250:
  pushl $0
8010839e:	6a 00                	push   $0x0
  pushl $250
801083a0:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801083a5:	e9 82 ef ff ff       	jmp    8010732c <alltraps>

801083aa <vector251>:
.globl vector251
vector251:
  pushl $0
801083aa:	6a 00                	push   $0x0
  pushl $251
801083ac:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801083b1:	e9 76 ef ff ff       	jmp    8010732c <alltraps>

801083b6 <vector252>:
.globl vector252
vector252:
  pushl $0
801083b6:	6a 00                	push   $0x0
  pushl $252
801083b8:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801083bd:	e9 6a ef ff ff       	jmp    8010732c <alltraps>

801083c2 <vector253>:
.globl vector253
vector253:
  pushl $0
801083c2:	6a 00                	push   $0x0
  pushl $253
801083c4:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801083c9:	e9 5e ef ff ff       	jmp    8010732c <alltraps>

801083ce <vector254>:
.globl vector254
vector254:
  pushl $0
801083ce:	6a 00                	push   $0x0
  pushl $254
801083d0:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801083d5:	e9 52 ef ff ff       	jmp    8010732c <alltraps>

801083da <vector255>:
.globl vector255
vector255:
  pushl $0
801083da:	6a 00                	push   $0x0
  pushl $255
801083dc:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801083e1:	e9 46 ef ff ff       	jmp    8010732c <alltraps>
	...

801083e8 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801083e8:	55                   	push   %ebp
801083e9:	89 e5                	mov    %esp,%ebp
801083eb:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801083ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801083f1:	48                   	dec    %eax
801083f2:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801083f6:	8b 45 08             	mov    0x8(%ebp),%eax
801083f9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801083fd:	8b 45 08             	mov    0x8(%ebp),%eax
80108400:	c1 e8 10             	shr    $0x10,%eax
80108403:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108407:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010840a:	0f 01 10             	lgdtl  (%eax)
}
8010840d:	c9                   	leave  
8010840e:	c3                   	ret    

8010840f <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010840f:	55                   	push   %ebp
80108410:	89 e5                	mov    %esp,%ebp
80108412:	83 ec 04             	sub    $0x4,%esp
80108415:	8b 45 08             	mov    0x8(%ebp),%eax
80108418:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010841c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010841f:	0f 00 d8             	ltr    %ax
}
80108422:	c9                   	leave  
80108423:	c3                   	ret    

80108424 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80108424:	55                   	push   %ebp
80108425:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80108427:	8b 45 08             	mov    0x8(%ebp),%eax
8010842a:	0f 22 d8             	mov    %eax,%cr3
}
8010842d:	5d                   	pop    %ebp
8010842e:	c3                   	ret    

8010842f <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010842f:	55                   	push   %ebp
80108430:	89 e5                	mov    %esp,%ebp
80108432:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80108435:	e8 50 c9 ff ff       	call   80104d8a <cpuid>
8010843a:	89 c2                	mov    %eax,%edx
8010843c:	89 d0                	mov    %edx,%eax
8010843e:	c1 e0 02             	shl    $0x2,%eax
80108441:	01 d0                	add    %edx,%eax
80108443:	01 c0                	add    %eax,%eax
80108445:	01 d0                	add    %edx,%eax
80108447:	c1 e0 04             	shl    $0x4,%eax
8010844a:	05 60 49 11 80       	add    $0x80114960,%eax
8010844f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80108452:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108455:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010845b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010845e:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108464:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108467:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010846b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010846e:	8a 50 7d             	mov    0x7d(%eax),%dl
80108471:	83 e2 f0             	and    $0xfffffff0,%edx
80108474:	83 ca 0a             	or     $0xa,%edx
80108477:	88 50 7d             	mov    %dl,0x7d(%eax)
8010847a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010847d:	8a 50 7d             	mov    0x7d(%eax),%dl
80108480:	83 ca 10             	or     $0x10,%edx
80108483:	88 50 7d             	mov    %dl,0x7d(%eax)
80108486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108489:	8a 50 7d             	mov    0x7d(%eax),%dl
8010848c:	83 e2 9f             	and    $0xffffff9f,%edx
8010848f:	88 50 7d             	mov    %dl,0x7d(%eax)
80108492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108495:	8a 50 7d             	mov    0x7d(%eax),%dl
80108498:	83 ca 80             	or     $0xffffff80,%edx
8010849b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010849e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a1:	8a 50 7e             	mov    0x7e(%eax),%dl
801084a4:	83 ca 0f             	or     $0xf,%edx
801084a7:	88 50 7e             	mov    %dl,0x7e(%eax)
801084aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ad:	8a 50 7e             	mov    0x7e(%eax),%dl
801084b0:	83 e2 ef             	and    $0xffffffef,%edx
801084b3:	88 50 7e             	mov    %dl,0x7e(%eax)
801084b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b9:	8a 50 7e             	mov    0x7e(%eax),%dl
801084bc:	83 e2 df             	and    $0xffffffdf,%edx
801084bf:	88 50 7e             	mov    %dl,0x7e(%eax)
801084c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c5:	8a 50 7e             	mov    0x7e(%eax),%dl
801084c8:	83 ca 40             	or     $0x40,%edx
801084cb:	88 50 7e             	mov    %dl,0x7e(%eax)
801084ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d1:	8a 50 7e             	mov    0x7e(%eax),%dl
801084d4:	83 ca 80             	or     $0xffffff80,%edx
801084d7:	88 50 7e             	mov    %dl,0x7e(%eax)
801084da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084dd:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801084e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e4:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801084eb:	ff ff 
801084ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f0:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801084f7:	00 00 
801084f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084fc:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108506:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010850c:	83 e2 f0             	and    $0xfffffff0,%edx
8010850f:	83 ca 02             	or     $0x2,%edx
80108512:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108518:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010851b:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108521:	83 ca 10             	or     $0x10,%edx
80108524:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010852a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010852d:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108533:	83 e2 9f             	and    $0xffffff9f,%edx
80108536:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010853c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853f:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108545:	83 ca 80             	or     $0xffffff80,%edx
80108548:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010854e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108551:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108557:	83 ca 0f             	or     $0xf,%edx
8010855a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108560:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108563:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108569:	83 e2 ef             	and    $0xffffffef,%edx
8010856c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108572:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108575:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010857b:	83 e2 df             	and    $0xffffffdf,%edx
8010857e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108587:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010858d:	83 ca 40             	or     $0x40,%edx
80108590:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108596:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108599:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010859f:	83 ca 80             	or     $0xffffff80,%edx
801085a2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801085a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ab:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801085b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b5:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801085bc:	ff ff 
801085be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c1:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801085c8:	00 00 
801085ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085cd:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801085d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d7:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801085dd:	83 e2 f0             	and    $0xfffffff0,%edx
801085e0:	83 ca 0a             	or     $0xa,%edx
801085e3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801085e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085ec:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801085f2:	83 ca 10             	or     $0x10,%edx
801085f5:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801085fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085fe:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108604:	83 ca 60             	or     $0x60,%edx
80108607:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010860d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108610:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108616:	83 ca 80             	or     $0xffffff80,%edx
80108619:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010861f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108622:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108628:	83 ca 0f             	or     $0xf,%edx
8010862b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108631:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108634:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010863a:	83 e2 ef             	and    $0xffffffef,%edx
8010863d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108643:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108646:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010864c:	83 e2 df             	and    $0xffffffdf,%edx
8010864f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108655:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108658:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010865e:	83 ca 40             	or     $0x40,%edx
80108661:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108667:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010866a:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108670:	83 ca 80             	or     $0xffffff80,%edx
80108673:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108679:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867c:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108683:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108686:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010868d:	ff ff 
8010868f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108692:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108699:	00 00 
8010869b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869e:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801086a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a8:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801086ae:	83 e2 f0             	and    $0xfffffff0,%edx
801086b1:	83 ca 02             	or     $0x2,%edx
801086b4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086bd:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801086c3:	83 ca 10             	or     $0x10,%edx
801086c6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086cf:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801086d5:	83 ca 60             	or     $0x60,%edx
801086d8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e1:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801086e7:	83 ca 80             	or     $0xffffff80,%edx
801086ea:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f3:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801086f9:	83 ca 0f             	or     $0xf,%edx
801086fc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108702:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108705:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010870b:	83 e2 ef             	and    $0xffffffef,%edx
8010870e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108714:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108717:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010871d:	83 e2 df             	and    $0xffffffdf,%edx
80108720:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108726:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108729:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010872f:	83 ca 40             	or     $0x40,%edx
80108732:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108738:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873b:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108741:	83 ca 80             	or     $0xffffff80,%edx
80108744:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010874a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010874d:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80108754:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108757:	83 c0 70             	add    $0x70,%eax
8010875a:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80108761:	00 
80108762:	89 04 24             	mov    %eax,(%esp)
80108765:	e8 7e fc ff ff       	call   801083e8 <lgdt>
}
8010876a:	c9                   	leave  
8010876b:	c3                   	ret    

8010876c <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010876c:	55                   	push   %ebp
8010876d:	89 e5                	mov    %esp,%ebp
8010876f:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108772:	8b 45 0c             	mov    0xc(%ebp),%eax
80108775:	c1 e8 16             	shr    $0x16,%eax
80108778:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010877f:	8b 45 08             	mov    0x8(%ebp),%eax
80108782:	01 d0                	add    %edx,%eax
80108784:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108787:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010878a:	8b 00                	mov    (%eax),%eax
8010878c:	83 e0 01             	and    $0x1,%eax
8010878f:	85 c0                	test   %eax,%eax
80108791:	74 14                	je     801087a7 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80108793:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108796:	8b 00                	mov    (%eax),%eax
80108798:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010879d:	05 00 00 00 80       	add    $0x80000000,%eax
801087a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801087a5:	eb 48                	jmp    801087ef <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801087a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801087ab:	74 0e                	je     801087bb <walkpgdir+0x4f>
801087ad:	e8 89 a6 ff ff       	call   80102e3b <kalloc>
801087b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801087b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801087b9:	75 07                	jne    801087c2 <walkpgdir+0x56>
      return 0;
801087bb:	b8 00 00 00 00       	mov    $0x0,%eax
801087c0:	eb 44                	jmp    80108806 <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801087c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801087c9:	00 
801087ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801087d1:	00 
801087d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087d5:	89 04 24             	mov    %eax,(%esp)
801087d8:	e8 c5 d3 ff ff       	call   80105ba2 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801087dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087e0:	05 00 00 00 80       	add    $0x80000000,%eax
801087e5:	83 c8 07             	or     $0x7,%eax
801087e8:	89 c2                	mov    %eax,%edx
801087ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087ed:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801087ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801087f2:	c1 e8 0c             	shr    $0xc,%eax
801087f5:	25 ff 03 00 00       	and    $0x3ff,%eax
801087fa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108804:	01 d0                	add    %edx,%eax
}
80108806:	c9                   	leave  
80108807:	c3                   	ret    

80108808 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108808:	55                   	push   %ebp
80108809:	89 e5                	mov    %esp,%ebp
8010880b:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010880e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108811:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108816:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108819:	8b 55 0c             	mov    0xc(%ebp),%edx
8010881c:	8b 45 10             	mov    0x10(%ebp),%eax
8010881f:	01 d0                	add    %edx,%eax
80108821:	48                   	dec    %eax
80108822:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108827:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010882a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108831:	00 
80108832:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108835:	89 44 24 04          	mov    %eax,0x4(%esp)
80108839:	8b 45 08             	mov    0x8(%ebp),%eax
8010883c:	89 04 24             	mov    %eax,(%esp)
8010883f:	e8 28 ff ff ff       	call   8010876c <walkpgdir>
80108844:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108847:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010884b:	75 07                	jne    80108854 <mappages+0x4c>
      return -1;
8010884d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108852:	eb 48                	jmp    8010889c <mappages+0x94>
    if(*pte & PTE_P)
80108854:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108857:	8b 00                	mov    (%eax),%eax
80108859:	83 e0 01             	and    $0x1,%eax
8010885c:	85 c0                	test   %eax,%eax
8010885e:	74 0c                	je     8010886c <mappages+0x64>
      panic("remap");
80108860:	c7 04 24 dc 9b 10 80 	movl   $0x80109bdc,(%esp)
80108867:	e8 e8 7c ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
8010886c:	8b 45 18             	mov    0x18(%ebp),%eax
8010886f:	0b 45 14             	or     0x14(%ebp),%eax
80108872:	83 c8 01             	or     $0x1,%eax
80108875:	89 c2                	mov    %eax,%edx
80108877:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010887a:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010887c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010887f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108882:	75 08                	jne    8010888c <mappages+0x84>
      break;
80108884:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108885:	b8 00 00 00 00       	mov    $0x0,%eax
8010888a:	eb 10                	jmp    8010889c <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
8010888c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108893:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
8010889a:	eb 8e                	jmp    8010882a <mappages+0x22>
  return 0;
}
8010889c:	c9                   	leave  
8010889d:	c3                   	ret    

8010889e <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010889e:	55                   	push   %ebp
8010889f:	89 e5                	mov    %esp,%ebp
801088a1:	53                   	push   %ebx
801088a2:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801088a5:	e8 91 a5 ff ff       	call   80102e3b <kalloc>
801088aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801088ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801088b1:	75 0a                	jne    801088bd <setupkvm+0x1f>
    return 0;
801088b3:	b8 00 00 00 00       	mov    $0x0,%eax
801088b8:	e9 84 00 00 00       	jmp    80108941 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
801088bd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801088c4:	00 
801088c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801088cc:	00 
801088cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088d0:	89 04 24             	mov    %eax,(%esp)
801088d3:	e8 ca d2 ff ff       	call   80105ba2 <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801088d8:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
801088df:	eb 54                	jmp    80108935 <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801088e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e4:	8b 48 0c             	mov    0xc(%eax),%ecx
801088e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ea:	8b 50 04             	mov    0x4(%eax),%edx
801088ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f0:	8b 58 08             	mov    0x8(%eax),%ebx
801088f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f6:	8b 40 04             	mov    0x4(%eax),%eax
801088f9:	29 c3                	sub    %eax,%ebx
801088fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088fe:	8b 00                	mov    (%eax),%eax
80108900:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108904:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108908:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010890c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108910:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108913:	89 04 24             	mov    %eax,(%esp)
80108916:	e8 ed fe ff ff       	call   80108808 <mappages>
8010891b:	85 c0                	test   %eax,%eax
8010891d:	79 12                	jns    80108931 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
8010891f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108922:	89 04 24             	mov    %eax,(%esp)
80108925:	e8 1a 05 00 00       	call   80108e44 <freevm>
      return 0;
8010892a:	b8 00 00 00 00       	mov    $0x0,%eax
8010892f:	eb 10                	jmp    80108941 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108931:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108935:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
8010893c:	72 a3                	jb     801088e1 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
8010893e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108941:	83 c4 34             	add    $0x34,%esp
80108944:	5b                   	pop    %ebx
80108945:	5d                   	pop    %ebp
80108946:	c3                   	ret    

80108947 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108947:	55                   	push   %ebp
80108948:	89 e5                	mov    %esp,%ebp
8010894a:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010894d:	e8 4c ff ff ff       	call   8010889e <setupkvm>
80108952:	a3 44 61 12 80       	mov    %eax,0x80126144
  switchkvm();
80108957:	e8 02 00 00 00       	call   8010895e <switchkvm>
}
8010895c:	c9                   	leave  
8010895d:	c3                   	ret    

8010895e <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010895e:	55                   	push   %ebp
8010895f:	89 e5                	mov    %esp,%ebp
80108961:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108964:	a1 44 61 12 80       	mov    0x80126144,%eax
80108969:	05 00 00 00 80       	add    $0x80000000,%eax
8010896e:	89 04 24             	mov    %eax,(%esp)
80108971:	e8 ae fa ff ff       	call   80108424 <lcr3>
}
80108976:	c9                   	leave  
80108977:	c3                   	ret    

80108978 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108978:	55                   	push   %ebp
80108979:	89 e5                	mov    %esp,%ebp
8010897b:	57                   	push   %edi
8010897c:	56                   	push   %esi
8010897d:	53                   	push   %ebx
8010897e:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
80108981:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108985:	75 0c                	jne    80108993 <switchuvm+0x1b>
    panic("switchuvm: no process");
80108987:	c7 04 24 e2 9b 10 80 	movl   $0x80109be2,(%esp)
8010898e:	e8 c1 7b ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
80108993:	8b 45 08             	mov    0x8(%ebp),%eax
80108996:	8b 40 08             	mov    0x8(%eax),%eax
80108999:	85 c0                	test   %eax,%eax
8010899b:	75 0c                	jne    801089a9 <switchuvm+0x31>
    panic("switchuvm: no kstack");
8010899d:	c7 04 24 f8 9b 10 80 	movl   $0x80109bf8,(%esp)
801089a4:	e8 ab 7b ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
801089a9:	8b 45 08             	mov    0x8(%ebp),%eax
801089ac:	8b 40 04             	mov    0x4(%eax),%eax
801089af:	85 c0                	test   %eax,%eax
801089b1:	75 0c                	jne    801089bf <switchuvm+0x47>
    panic("switchuvm: no pgdir");
801089b3:	c7 04 24 0d 9c 10 80 	movl   $0x80109c0d,(%esp)
801089ba:	e8 95 7b ff ff       	call   80100554 <panic>

  pushcli();
801089bf:	e8 da d0 ff ff       	call   80105a9e <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801089c4:	e8 06 c4 ff ff       	call   80104dcf <mycpu>
801089c9:	89 c3                	mov    %eax,%ebx
801089cb:	e8 ff c3 ff ff       	call   80104dcf <mycpu>
801089d0:	83 c0 08             	add    $0x8,%eax
801089d3:	89 c6                	mov    %eax,%esi
801089d5:	e8 f5 c3 ff ff       	call   80104dcf <mycpu>
801089da:	83 c0 08             	add    $0x8,%eax
801089dd:	c1 e8 10             	shr    $0x10,%eax
801089e0:	89 c7                	mov    %eax,%edi
801089e2:	e8 e8 c3 ff ff       	call   80104dcf <mycpu>
801089e7:	83 c0 08             	add    $0x8,%eax
801089ea:	c1 e8 18             	shr    $0x18,%eax
801089ed:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801089f4:	67 00 
801089f6:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801089fd:	89 f9                	mov    %edi,%ecx
801089ff:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80108a05:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108a0b:	83 e2 f0             	and    $0xfffffff0,%edx
80108a0e:	83 ca 09             	or     $0x9,%edx
80108a11:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108a17:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108a1d:	83 ca 10             	or     $0x10,%edx
80108a20:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108a26:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108a2c:	83 e2 9f             	and    $0xffffff9f,%edx
80108a2f:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108a35:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
80108a3b:	83 ca 80             	or     $0xffffff80,%edx
80108a3e:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108a44:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108a4a:	83 e2 f0             	and    $0xfffffff0,%edx
80108a4d:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108a53:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108a59:	83 e2 ef             	and    $0xffffffef,%edx
80108a5c:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108a62:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108a68:	83 e2 df             	and    $0xffffffdf,%edx
80108a6b:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108a71:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108a77:	83 ca 40             	or     $0x40,%edx
80108a7a:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108a80:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108a86:	83 e2 7f             	and    $0x7f,%edx
80108a89:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108a8f:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108a95:	e8 35 c3 ff ff       	call   80104dcf <mycpu>
80108a9a:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80108aa0:	83 e2 ef             	and    $0xffffffef,%edx
80108aa3:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80108aa9:	e8 21 c3 ff ff       	call   80104dcf <mycpu>
80108aae:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80108ab4:	e8 16 c3 ff ff       	call   80104dcf <mycpu>
80108ab9:	8b 55 08             	mov    0x8(%ebp),%edx
80108abc:	8b 52 08             	mov    0x8(%edx),%edx
80108abf:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108ac5:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108ac8:	e8 02 c3 ff ff       	call   80104dcf <mycpu>
80108acd:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108ad3:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
80108ada:	e8 30 f9 ff ff       	call   8010840f <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108adf:	8b 45 08             	mov    0x8(%ebp),%eax
80108ae2:	8b 40 04             	mov    0x4(%eax),%eax
80108ae5:	05 00 00 00 80       	add    $0x80000000,%eax
80108aea:	89 04 24             	mov    %eax,(%esp)
80108aed:	e8 32 f9 ff ff       	call   80108424 <lcr3>
  popcli();
80108af2:	e8 f1 cf ff ff       	call   80105ae8 <popcli>
}
80108af7:	83 c4 1c             	add    $0x1c,%esp
80108afa:	5b                   	pop    %ebx
80108afb:	5e                   	pop    %esi
80108afc:	5f                   	pop    %edi
80108afd:	5d                   	pop    %ebp
80108afe:	c3                   	ret    

80108aff <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108aff:	55                   	push   %ebp
80108b00:	89 e5                	mov    %esp,%ebp
80108b02:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80108b05:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108b0c:	76 0c                	jbe    80108b1a <inituvm+0x1b>
    panic("inituvm: more than a page");
80108b0e:	c7 04 24 21 9c 10 80 	movl   $0x80109c21,(%esp)
80108b15:	e8 3a 7a ff ff       	call   80100554 <panic>
  mem = kalloc();
80108b1a:	e8 1c a3 ff ff       	call   80102e3b <kalloc>
80108b1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108b22:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108b29:	00 
80108b2a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108b31:	00 
80108b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b35:	89 04 24             	mov    %eax,(%esp)
80108b38:	e8 65 d0 ff ff       	call   80105ba2 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b40:	05 00 00 00 80       	add    $0x80000000,%eax
80108b45:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108b4c:	00 
80108b4d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108b51:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108b58:	00 
80108b59:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108b60:	00 
80108b61:	8b 45 08             	mov    0x8(%ebp),%eax
80108b64:	89 04 24             	mov    %eax,(%esp)
80108b67:	e8 9c fc ff ff       	call   80108808 <mappages>
  memmove(mem, init, sz);
80108b6c:	8b 45 10             	mov    0x10(%ebp),%eax
80108b6f:	89 44 24 08          	mov    %eax,0x8(%esp)
80108b73:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b76:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b7d:	89 04 24             	mov    %eax,(%esp)
80108b80:	e8 e6 d0 ff ff       	call   80105c6b <memmove>
}
80108b85:	c9                   	leave  
80108b86:	c3                   	ret    

80108b87 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108b87:	55                   	push   %ebp
80108b88:	89 e5                	mov    %esp,%ebp
80108b8a:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108b8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b90:	25 ff 0f 00 00       	and    $0xfff,%eax
80108b95:	85 c0                	test   %eax,%eax
80108b97:	74 0c                	je     80108ba5 <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80108b99:	c7 04 24 3c 9c 10 80 	movl   $0x80109c3c,(%esp)
80108ba0:	e8 af 79 ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108ba5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108bac:	e9 a6 00 00 00       	jmp    80108c57 <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108bb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bb4:	8b 55 0c             	mov    0xc(%ebp),%edx
80108bb7:	01 d0                	add    %edx,%eax
80108bb9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108bc0:	00 
80108bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
80108bc5:	8b 45 08             	mov    0x8(%ebp),%eax
80108bc8:	89 04 24             	mov    %eax,(%esp)
80108bcb:	e8 9c fb ff ff       	call   8010876c <walkpgdir>
80108bd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108bd3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108bd7:	75 0c                	jne    80108be5 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108bd9:	c7 04 24 5f 9c 10 80 	movl   $0x80109c5f,(%esp)
80108be0:	e8 6f 79 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108be5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108be8:	8b 00                	mov    (%eax),%eax
80108bea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bef:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bf5:	8b 55 18             	mov    0x18(%ebp),%edx
80108bf8:	29 c2                	sub    %eax,%edx
80108bfa:	89 d0                	mov    %edx,%eax
80108bfc:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108c01:	77 0f                	ja     80108c12 <loaduvm+0x8b>
      n = sz - i;
80108c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c06:	8b 55 18             	mov    0x18(%ebp),%edx
80108c09:	29 c2                	sub    %eax,%edx
80108c0b:	89 d0                	mov    %edx,%eax
80108c0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108c10:	eb 07                	jmp    80108c19 <loaduvm+0x92>
    else
      n = PGSIZE;
80108c12:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108c19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c1c:	8b 55 14             	mov    0x14(%ebp),%edx
80108c1f:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80108c22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c25:	05 00 00 00 80       	add    $0x80000000,%eax
80108c2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108c2d:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108c31:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80108c35:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c39:	8b 45 10             	mov    0x10(%ebp),%eax
80108c3c:	89 04 24             	mov    %eax,(%esp)
80108c3f:	e8 f1 92 ff ff       	call   80101f35 <readi>
80108c44:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108c47:	74 07                	je     80108c50 <loaduvm+0xc9>
      return -1;
80108c49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c4e:	eb 18                	jmp    80108c68 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108c50:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c5a:	3b 45 18             	cmp    0x18(%ebp),%eax
80108c5d:	0f 82 4e ff ff ff    	jb     80108bb1 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108c63:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108c68:	c9                   	leave  
80108c69:	c3                   	ret    

80108c6a <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108c6a:	55                   	push   %ebp
80108c6b:	89 e5                	mov    %esp,%ebp
80108c6d:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108c70:	8b 45 10             	mov    0x10(%ebp),%eax
80108c73:	85 c0                	test   %eax,%eax
80108c75:	79 0a                	jns    80108c81 <allocuvm+0x17>
    return 0;
80108c77:	b8 00 00 00 00       	mov    $0x0,%eax
80108c7c:	e9 fd 00 00 00       	jmp    80108d7e <allocuvm+0x114>
  if(newsz < oldsz)
80108c81:	8b 45 10             	mov    0x10(%ebp),%eax
80108c84:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108c87:	73 08                	jae    80108c91 <allocuvm+0x27>
    return oldsz;
80108c89:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c8c:	e9 ed 00 00 00       	jmp    80108d7e <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
80108c91:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c94:	05 ff 0f 00 00       	add    $0xfff,%eax
80108c99:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108ca1:	e9 c9 00 00 00       	jmp    80108d6f <allocuvm+0x105>
    mem = kalloc();
80108ca6:	e8 90 a1 ff ff       	call   80102e3b <kalloc>
80108cab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108cae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108cb2:	75 2f                	jne    80108ce3 <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
80108cb4:	c7 04 24 7d 9c 10 80 	movl   $0x80109c7d,(%esp)
80108cbb:	e8 01 77 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108cc0:	8b 45 0c             	mov    0xc(%ebp),%eax
80108cc3:	89 44 24 08          	mov    %eax,0x8(%esp)
80108cc7:	8b 45 10             	mov    0x10(%ebp),%eax
80108cca:	89 44 24 04          	mov    %eax,0x4(%esp)
80108cce:	8b 45 08             	mov    0x8(%ebp),%eax
80108cd1:	89 04 24             	mov    %eax,(%esp)
80108cd4:	e8 a7 00 00 00       	call   80108d80 <deallocuvm>
      return 0;
80108cd9:	b8 00 00 00 00       	mov    $0x0,%eax
80108cde:	e9 9b 00 00 00       	jmp    80108d7e <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
80108ce3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108cea:	00 
80108ceb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108cf2:	00 
80108cf3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cf6:	89 04 24             	mov    %eax,(%esp)
80108cf9:	e8 a4 ce ff ff       	call   80105ba2 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108cfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d01:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108d07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d0a:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108d11:	00 
80108d12:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108d16:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108d1d:	00 
80108d1e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d22:	8b 45 08             	mov    0x8(%ebp),%eax
80108d25:	89 04 24             	mov    %eax,(%esp)
80108d28:	e8 db fa ff ff       	call   80108808 <mappages>
80108d2d:	85 c0                	test   %eax,%eax
80108d2f:	79 37                	jns    80108d68 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80108d31:	c7 04 24 95 9c 10 80 	movl   $0x80109c95,(%esp)
80108d38:	e8 84 76 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108d3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d40:	89 44 24 08          	mov    %eax,0x8(%esp)
80108d44:	8b 45 10             	mov    0x10(%ebp),%eax
80108d47:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d4b:	8b 45 08             	mov    0x8(%ebp),%eax
80108d4e:	89 04 24             	mov    %eax,(%esp)
80108d51:	e8 2a 00 00 00       	call   80108d80 <deallocuvm>
      kfree(mem);
80108d56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d59:	89 04 24             	mov    %eax,(%esp)
80108d5c:	e8 44 a0 ff ff       	call   80102da5 <kfree>
      return 0;
80108d61:	b8 00 00 00 00       	mov    $0x0,%eax
80108d66:	eb 16                	jmp    80108d7e <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108d68:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d72:	3b 45 10             	cmp    0x10(%ebp),%eax
80108d75:	0f 82 2b ff ff ff    	jb     80108ca6 <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80108d7b:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108d7e:	c9                   	leave  
80108d7f:	c3                   	ret    

80108d80 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108d80:	55                   	push   %ebp
80108d81:	89 e5                	mov    %esp,%ebp
80108d83:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108d86:	8b 45 10             	mov    0x10(%ebp),%eax
80108d89:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108d8c:	72 08                	jb     80108d96 <deallocuvm+0x16>
    return oldsz;
80108d8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d91:	e9 ac 00 00 00       	jmp    80108e42 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108d96:	8b 45 10             	mov    0x10(%ebp),%eax
80108d99:	05 ff 0f 00 00       	add    $0xfff,%eax
80108d9e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108da3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108da6:	e9 88 00 00 00       	jmp    80108e33 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108dab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108db5:	00 
80108db6:	89 44 24 04          	mov    %eax,0x4(%esp)
80108dba:	8b 45 08             	mov    0x8(%ebp),%eax
80108dbd:	89 04 24             	mov    %eax,(%esp)
80108dc0:	e8 a7 f9 ff ff       	call   8010876c <walkpgdir>
80108dc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108dc8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108dcc:	75 14                	jne    80108de2 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108dce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dd1:	c1 e8 16             	shr    $0x16,%eax
80108dd4:	40                   	inc    %eax
80108dd5:	c1 e0 16             	shl    $0x16,%eax
80108dd8:	2d 00 10 00 00       	sub    $0x1000,%eax
80108ddd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108de0:	eb 4a                	jmp    80108e2c <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80108de2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108de5:	8b 00                	mov    (%eax),%eax
80108de7:	83 e0 01             	and    $0x1,%eax
80108dea:	85 c0                	test   %eax,%eax
80108dec:	74 3e                	je     80108e2c <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108dee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108df1:	8b 00                	mov    (%eax),%eax
80108df3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108df8:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108dfb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108dff:	75 0c                	jne    80108e0d <deallocuvm+0x8d>
        panic("kfree");
80108e01:	c7 04 24 b1 9c 10 80 	movl   $0x80109cb1,(%esp)
80108e08:	e8 47 77 ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80108e0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e10:	05 00 00 00 80       	add    $0x80000000,%eax
80108e15:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108e18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e1b:	89 04 24             	mov    %eax,(%esp)
80108e1e:	e8 82 9f ff ff       	call   80102da5 <kfree>
      *pte = 0;
80108e23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e26:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108e2c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e36:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108e39:	0f 82 6c ff ff ff    	jb     80108dab <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108e3f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108e42:	c9                   	leave  
80108e43:	c3                   	ret    

80108e44 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108e44:	55                   	push   %ebp
80108e45:	89 e5                	mov    %esp,%ebp
80108e47:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108e4a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108e4e:	75 0c                	jne    80108e5c <freevm+0x18>
    panic("freevm: no pgdir");
80108e50:	c7 04 24 b7 9c 10 80 	movl   $0x80109cb7,(%esp)
80108e57:	e8 f8 76 ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108e5c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108e63:	00 
80108e64:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108e6b:	80 
80108e6c:	8b 45 08             	mov    0x8(%ebp),%eax
80108e6f:	89 04 24             	mov    %eax,(%esp)
80108e72:	e8 09 ff ff ff       	call   80108d80 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108e77:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e7e:	eb 44                	jmp    80108ec4 <freevm+0x80>
    if(pgdir[i] & PTE_P){
80108e80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e8a:	8b 45 08             	mov    0x8(%ebp),%eax
80108e8d:	01 d0                	add    %edx,%eax
80108e8f:	8b 00                	mov    (%eax),%eax
80108e91:	83 e0 01             	and    $0x1,%eax
80108e94:	85 c0                	test   %eax,%eax
80108e96:	74 29                	je     80108ec1 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108e98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e9b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ea2:	8b 45 08             	mov    0x8(%ebp),%eax
80108ea5:	01 d0                	add    %edx,%eax
80108ea7:	8b 00                	mov    (%eax),%eax
80108ea9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108eae:	05 00 00 00 80       	add    $0x80000000,%eax
80108eb3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108eb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108eb9:	89 04 24             	mov    %eax,(%esp)
80108ebc:	e8 e4 9e ff ff       	call   80102da5 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108ec1:	ff 45 f4             	incl   -0xc(%ebp)
80108ec4:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108ecb:	76 b3                	jbe    80108e80 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108ecd:	8b 45 08             	mov    0x8(%ebp),%eax
80108ed0:	89 04 24             	mov    %eax,(%esp)
80108ed3:	e8 cd 9e ff ff       	call   80102da5 <kfree>
}
80108ed8:	c9                   	leave  
80108ed9:	c3                   	ret    

80108eda <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108eda:	55                   	push   %ebp
80108edb:	89 e5                	mov    %esp,%ebp
80108edd:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108ee0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108ee7:	00 
80108ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
80108eeb:	89 44 24 04          	mov    %eax,0x4(%esp)
80108eef:	8b 45 08             	mov    0x8(%ebp),%eax
80108ef2:	89 04 24             	mov    %eax,(%esp)
80108ef5:	e8 72 f8 ff ff       	call   8010876c <walkpgdir>
80108efa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108efd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108f01:	75 0c                	jne    80108f0f <clearpteu+0x35>
    panic("clearpteu");
80108f03:	c7 04 24 c8 9c 10 80 	movl   $0x80109cc8,(%esp)
80108f0a:	e8 45 76 ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80108f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f12:	8b 00                	mov    (%eax),%eax
80108f14:	83 e0 fb             	and    $0xfffffffb,%eax
80108f17:	89 c2                	mov    %eax,%edx
80108f19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f1c:	89 10                	mov    %edx,(%eax)
}
80108f1e:	c9                   	leave  
80108f1f:	c3                   	ret    

80108f20 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108f20:	55                   	push   %ebp
80108f21:	89 e5                	mov    %esp,%ebp
80108f23:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108f26:	e8 73 f9 ff ff       	call   8010889e <setupkvm>
80108f2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108f2e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108f32:	75 0a                	jne    80108f3e <copyuvm+0x1e>
    return 0;
80108f34:	b8 00 00 00 00       	mov    $0x0,%eax
80108f39:	e9 f8 00 00 00       	jmp    80109036 <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80108f3e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f45:	e9 cb 00 00 00       	jmp    80109015 <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108f4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f4d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108f54:	00 
80108f55:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f59:	8b 45 08             	mov    0x8(%ebp),%eax
80108f5c:	89 04 24             	mov    %eax,(%esp)
80108f5f:	e8 08 f8 ff ff       	call   8010876c <walkpgdir>
80108f64:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108f67:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108f6b:	75 0c                	jne    80108f79 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108f6d:	c7 04 24 d2 9c 10 80 	movl   $0x80109cd2,(%esp)
80108f74:	e8 db 75 ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
80108f79:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f7c:	8b 00                	mov    (%eax),%eax
80108f7e:	83 e0 01             	and    $0x1,%eax
80108f81:	85 c0                	test   %eax,%eax
80108f83:	75 0c                	jne    80108f91 <copyuvm+0x71>
      panic("copyuvm: page not present");
80108f85:	c7 04 24 ec 9c 10 80 	movl   $0x80109cec,(%esp)
80108f8c:	e8 c3 75 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108f91:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f94:	8b 00                	mov    (%eax),%eax
80108f96:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f9b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108f9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108fa1:	8b 00                	mov    (%eax),%eax
80108fa3:	25 ff 0f 00 00       	and    $0xfff,%eax
80108fa8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108fab:	e8 8b 9e ff ff       	call   80102e3b <kalloc>
80108fb0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108fb3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108fb7:	75 02                	jne    80108fbb <copyuvm+0x9b>
      goto bad;
80108fb9:	eb 6b                	jmp    80109026 <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108fbb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108fbe:	05 00 00 00 80       	add    $0x80000000,%eax
80108fc3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108fca:	00 
80108fcb:	89 44 24 04          	mov    %eax,0x4(%esp)
80108fcf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fd2:	89 04 24             	mov    %eax,(%esp)
80108fd5:	e8 91 cc ff ff       	call   80105c6b <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108fda:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108fdd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fe0:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fe9:	89 54 24 10          	mov    %edx,0x10(%esp)
80108fed:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108ff1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108ff8:	00 
80108ff9:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ffd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109000:	89 04 24             	mov    %eax,(%esp)
80109003:	e8 00 f8 ff ff       	call   80108808 <mappages>
80109008:	85 c0                	test   %eax,%eax
8010900a:	79 02                	jns    8010900e <copyuvm+0xee>
      goto bad;
8010900c:	eb 18                	jmp    80109026 <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010900e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80109015:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109018:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010901b:	0f 82 29 ff ff ff    	jb     80108f4a <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
80109021:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109024:	eb 10                	jmp    80109036 <copyuvm+0x116>

bad:
  freevm(d);
80109026:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109029:	89 04 24             	mov    %eax,(%esp)
8010902c:	e8 13 fe ff ff       	call   80108e44 <freevm>
  return 0;
80109031:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109036:	c9                   	leave  
80109037:	c3                   	ret    

80109038 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80109038:	55                   	push   %ebp
80109039:	89 e5                	mov    %esp,%ebp
8010903b:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010903e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80109045:	00 
80109046:	8b 45 0c             	mov    0xc(%ebp),%eax
80109049:	89 44 24 04          	mov    %eax,0x4(%esp)
8010904d:	8b 45 08             	mov    0x8(%ebp),%eax
80109050:	89 04 24             	mov    %eax,(%esp)
80109053:	e8 14 f7 ff ff       	call   8010876c <walkpgdir>
80109058:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010905b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010905e:	8b 00                	mov    (%eax),%eax
80109060:	83 e0 01             	and    $0x1,%eax
80109063:	85 c0                	test   %eax,%eax
80109065:	75 07                	jne    8010906e <uva2ka+0x36>
    return 0;
80109067:	b8 00 00 00 00       	mov    $0x0,%eax
8010906c:	eb 22                	jmp    80109090 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
8010906e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109071:	8b 00                	mov    (%eax),%eax
80109073:	83 e0 04             	and    $0x4,%eax
80109076:	85 c0                	test   %eax,%eax
80109078:	75 07                	jne    80109081 <uva2ka+0x49>
    return 0;
8010907a:	b8 00 00 00 00       	mov    $0x0,%eax
8010907f:	eb 0f                	jmp    80109090 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
80109081:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109084:	8b 00                	mov    (%eax),%eax
80109086:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010908b:	05 00 00 00 80       	add    $0x80000000,%eax
}
80109090:	c9                   	leave  
80109091:	c3                   	ret    

80109092 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80109092:	55                   	push   %ebp
80109093:	89 e5                	mov    %esp,%ebp
80109095:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80109098:	8b 45 10             	mov    0x10(%ebp),%eax
8010909b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
8010909e:	e9 87 00 00 00       	jmp    8010912a <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
801090a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801090a6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801090ab:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801090ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090b1:	89 44 24 04          	mov    %eax,0x4(%esp)
801090b5:	8b 45 08             	mov    0x8(%ebp),%eax
801090b8:	89 04 24             	mov    %eax,(%esp)
801090bb:	e8 78 ff ff ff       	call   80109038 <uva2ka>
801090c0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
801090c3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801090c7:	75 07                	jne    801090d0 <copyout+0x3e>
      return -1;
801090c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801090ce:	eb 69                	jmp    80109139 <copyout+0xa7>
    n = PGSIZE - (va - va0);
801090d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801090d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801090d6:	29 c2                	sub    %eax,%edx
801090d8:	89 d0                	mov    %edx,%eax
801090da:	05 00 10 00 00       	add    $0x1000,%eax
801090df:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801090e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090e5:	3b 45 14             	cmp    0x14(%ebp),%eax
801090e8:	76 06                	jbe    801090f0 <copyout+0x5e>
      n = len;
801090ea:	8b 45 14             	mov    0x14(%ebp),%eax
801090ed:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801090f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090f3:	8b 55 0c             	mov    0xc(%ebp),%edx
801090f6:	29 c2                	sub    %eax,%edx
801090f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090fb:	01 c2                	add    %eax,%edx
801090fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109100:	89 44 24 08          	mov    %eax,0x8(%esp)
80109104:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109107:	89 44 24 04          	mov    %eax,0x4(%esp)
8010910b:	89 14 24             	mov    %edx,(%esp)
8010910e:	e8 58 cb ff ff       	call   80105c6b <memmove>
    len -= n;
80109113:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109116:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80109119:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010911c:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010911f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109122:	05 00 10 00 00       	add    $0x1000,%eax
80109127:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
8010912a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010912e:	0f 85 6f ff ff ff    	jne    801090a3 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80109134:	b8 00 00 00 00       	mov    $0x0,%eax
}
80109139:	c9                   	leave  
8010913a:	c3                   	ret    
