
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
8010002d:	b8 7e 39 10 80       	mov    $0x8010397e,%eax
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
8010003a:	c7 44 24 04 3c 8f 10 	movl   $0x80108f3c,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 a0 d7 10 80 	movl   $0x8010d7a0,(%esp)
80100049:	e8 d0 56 00 00       	call   8010571e <initlock>

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
80100087:	c7 44 24 04 43 8f 10 	movl   $0x80108f43,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 49 55 00 00       	call   801055e0 <initsleeplock>
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
801000c9:	e8 71 56 00 00       	call   8010573f <acquire>

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
80100104:	e8 a0 56 00 00       	call   801057a9 <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 03 55 00 00       	call   8010561a <acquiresleep>
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
8010017d:	e8 27 56 00 00       	call   801057a9 <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 8a 54 00 00       	call   8010561a <acquiresleep>
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
801001a7:	c7 04 24 4a 8f 10 80 	movl   $0x80108f4a,(%esp)
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
801001e2:	e8 ce 28 00 00       	call   80102ab5 <iderw>
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
801001fb:	e8 b7 54 00 00       	call   801056b7 <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 5b 8f 10 80 	movl   $0x80108f5b,(%esp)
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
80100225:	e8 8b 28 00 00       	call   80102ab5 <iderw>
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
8010023b:	e8 77 54 00 00       	call   801056b7 <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 62 8f 10 80 	movl   $0x80108f62,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 17 54 00 00       	call   80105675 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 a0 d7 10 80 	movl   $0x8010d7a0,(%esp)
80100265:	e8 d5 54 00 00       	call   8010573f <acquire>
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
801002d1:	e8 d3 54 00 00       	call   801057a9 <release>
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
801003dc:	e8 5e 53 00 00       	call   8010573f <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 69 8f 10 80 	movl   $0x80108f69,(%esp)
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
801004cf:	c7 45 ec 72 8f 10 80 	movl   $0x80108f72,-0x14(%ebp)
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
8010054d:	e8 57 52 00 00       	call   801057a9 <release>
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
80100569:	e8 e3 2b 00 00       	call   80103151 <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 79 8f 10 80 	movl   $0x80108f79,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 8d 8f 10 80 	movl   $0x80108f8d,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 4f 52 00 00       	call   801057f6 <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 8f 8f 10 80 	movl   $0x80108f8f,(%esp)
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
80100695:	c7 04 24 93 8f 10 80 	movl   $0x80108f93,(%esp)
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
801006c9:	e8 9d 53 00 00       	call   80105a6b <memmove>
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
801006f8:	e8 a5 52 00 00       	call   801059a2 <memset>
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
8010078e:	e8 29 6f 00 00       	call   801076bc <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 1d 6f 00 00       	call   801076bc <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 11 6f 00 00       	call   801076bc <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 04 6f 00 00       	call   801076bc <uartputc>
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
80100813:	e8 27 4f 00 00       	call   8010573f <acquire>
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
801009e0:	e8 e7 40 00 00       	call   80104acc <wakeup>
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
80100a01:	e8 a3 4d 00 00       	call   801057a9 <release>
  if(doprocdump){
80100a06:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a0a:	74 05                	je     80100a11 <consoleintr+0x21c>
    procdump();  // now call procdump() wo. cons.lock held
80100a0c:	e8 6d 41 00 00       	call   80104b7e <procdump>
  }
  if(doconsoleswitch){
80100a11:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a15:	74 15                	je     80100a2c <consoleintr+0x237>
    cprintf("\nActive console now: %d\n", active);
80100a17:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a20:	c7 04 24 a6 8f 10 80 	movl   $0x80108fa6,(%esp)
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
80100a52:	e8 e8 4c 00 00       	call   8010573f <acquire>
  while(n > 0){
80100a57:	e9 b7 00 00 00       	jmp    80100b13 <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a5c:	eb 41                	jmp    80100a9f <consoleread+0x6b>
      if(myproc()->killed){
80100a5e:	e8 35 38 00 00       	call   80104298 <myproc>
80100a63:	8b 40 24             	mov    0x24(%eax),%eax
80100a66:	85 c0                	test   %eax,%eax
80100a68:	74 21                	je     80100a8b <consoleread+0x57>
        release(&cons.lock);
80100a6a:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
80100a71:	e8 33 4d 00 00       	call   801057a9 <release>
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
80100a9a:	e8 3f 3f 00 00       	call   801049de <sleep>

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
80100b24:	e8 80 4c 00 00       	call   801057a9 <release>
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
80100b6a:	e8 d0 4b 00 00       	call   8010573f <acquire>
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
80100ba2:	e8 02 4c 00 00       	call   801057a9 <release>
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
80100bbd:	c7 44 24 04 bf 8f 10 	movl   $0x80108fbf,0x4(%esp)
80100bc4:	80 
80100bc5:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
80100bcc:	e8 4d 4b 00 00       	call   8010571e <initlock>

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
80100bfe:	e8 64 20 00 00       	call   80102c67 <ioapicenable>
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
80100c11:	e8 82 36 00 00       	call   80104298 <myproc>
80100c16:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c19:	e8 7d 2a 00 00       	call   8010369b <begin_op>

  if((ip = namei(path)) == 0){
80100c1e:	8b 45 08             	mov    0x8(%ebp),%eax
80100c21:	89 04 24             	mov    %eax,(%esp)
80100c24:	e8 9d 1a 00 00       	call   801026c6 <namei>
80100c29:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c2c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c30:	75 1b                	jne    80100c4d <exec+0x45>
    end_op();
80100c32:	e8 e6 2a 00 00       	call   8010371d <end_op>
    cprintf("exec: fail\n");
80100c37:	c7 04 24 c7 8f 10 80 	movl   $0x80108fc7,(%esp)
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
80100ca0:	e8 f9 79 00 00       	call   8010869e <setupkvm>
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
80100d5e:	e8 07 7d 00 00       	call   80108a6a <allocuvm>
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
80100db0:	e8 d2 7b 00 00       	call   80108987 <loaduvm>
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
80100de7:	e8 31 29 00 00       	call   8010371d <end_op>
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
80100e1c:	e8 49 7c 00 00       	call   80108a6a <allocuvm>
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
80100e41:	e8 94 7e 00 00       	call   80108cda <clearpteu>
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
80100e77:	e8 79 4d 00 00       	call   80105bf5 <strlen>
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
80100e9e:	e8 52 4d 00 00       	call   80105bf5 <strlen>
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
80100ecc:	e8 c1 7f 00 00       	call   80108e92 <copyout>
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
80100f70:	e8 1d 7f 00 00       	call   80108e92 <copyout>
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
80100fc0:	e8 e9 4b 00 00       	call   80105bae <safestrcpy>

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
80101000:	e8 73 77 00 00       	call   80108778 <switchuvm>
  freevm(oldpgdir);
80101005:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101008:	89 04 24             	mov    %eax,(%esp)
8010100b:	e8 34 7c 00 00       	call   80108c44 <freevm>
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
80101023:	e8 1c 7c 00 00       	call   80108c44 <freevm>
  if(ip){
80101028:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010102c:	74 10                	je     8010103e <exec+0x436>
    iunlockput(ip);
8010102e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101031:	89 04 24             	mov    %eax,(%esp)
80101034:	e8 ec 0b 00 00       	call   80101c25 <iunlockput>
    end_op();
80101039:	e8 df 26 00 00       	call   8010371d <end_op>
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
8010104e:	c7 44 24 04 d3 8f 10 	movl   $0x80108fd3,0x4(%esp)
80101055:	80 
80101056:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
8010105d:	e8 bc 46 00 00       	call   8010571e <initlock>
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
80101071:	e8 c9 46 00 00       	call   8010573f <acquire>
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
8010109a:	e8 0a 47 00 00       	call   801057a9 <release>
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
801010b8:	e8 ec 46 00 00       	call   801057a9 <release>
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
801010d1:	e8 69 46 00 00       	call   8010573f <acquire>
  if(f->ref < 1)
801010d6:	8b 45 08             	mov    0x8(%ebp),%eax
801010d9:	8b 40 04             	mov    0x4(%eax),%eax
801010dc:	85 c0                	test   %eax,%eax
801010de:	7f 0c                	jg     801010ec <filedup+0x28>
    panic("filedup");
801010e0:	c7 04 24 da 8f 10 80 	movl   $0x80108fda,(%esp)
801010e7:	e8 68 f4 ff ff       	call   80100554 <panic>
  f->ref++;
801010ec:	8b 45 08             	mov    0x8(%ebp),%eax
801010ef:	8b 40 04             	mov    0x4(%eax),%eax
801010f2:	8d 50 01             	lea    0x1(%eax),%edx
801010f5:	8b 45 08             	mov    0x8(%ebp),%eax
801010f8:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010fb:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
80101102:	e8 a2 46 00 00       	call   801057a9 <release>
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
8010111c:	e8 1e 46 00 00       	call   8010573f <acquire>
  if(f->ref < 1)
80101121:	8b 45 08             	mov    0x8(%ebp),%eax
80101124:	8b 40 04             	mov    0x4(%eax),%eax
80101127:	85 c0                	test   %eax,%eax
80101129:	7f 0c                	jg     80101137 <fileclose+0x2b>
    panic("fileclose");
8010112b:	c7 04 24 e2 8f 10 80 	movl   $0x80108fe2,(%esp)
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
80101157:	e8 4d 46 00 00       	call   801057a9 <release>
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
8010118d:	e8 17 46 00 00       	call   801057a9 <release>

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
801011aa:	e8 7c 2e 00 00       	call   8010402b <pipeclose>
801011af:	eb 1d                	jmp    801011ce <fileclose+0xc2>
  else if(ff.type == FD_INODE){
801011b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801011b4:	83 f8 02             	cmp    $0x2,%eax
801011b7:	75 15                	jne    801011ce <fileclose+0xc2>
    begin_op();
801011b9:	e8 dd 24 00 00       	call   8010369b <begin_op>
    iput(ff.ip);
801011be:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011c1:	89 04 24             	mov    %eax,(%esp)
801011c4:	e8 ab 09 00 00       	call   80101b74 <iput>
    end_op();
801011c9:	e8 4f 25 00 00       	call   8010371d <end_op>
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
80101260:	e8 44 2f 00 00       	call   801041a9 <piperead>
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
801012d2:	c7 04 24 ec 8f 10 80 	movl   $0x80108fec,(%esp)
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
8010131c:	e8 9c 2d 00 00       	call   801040bd <pipewrite>
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
80101362:	e8 34 23 00 00       	call   8010369b <begin_op>
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
801013c8:	e8 50 23 00 00       	call   8010371d <end_op>

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
801013dd:	c7 04 24 f5 8f 10 80 	movl   $0x80108ff5,(%esp)
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
8010140f:	c7 04 24 05 90 10 80 	movl   $0x80109005,(%esp)
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
80101458:	e8 0e 46 00 00       	call   80105a6b <memmove>
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
8010149e:	e8 ff 44 00 00       	call   801059a2 <memset>
  log_write(bp);
801014a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014a6:	89 04 24             	mov    %eax,(%esp)
801014a9:	e8 f1 23 00 00       	call   8010389f <log_write>
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
80101571:	e8 29 23 00 00       	call   8010389f <log_write>
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
801015e7:	c7 04 24 10 90 10 80 	movl   $0x80109010,(%esp)
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
80101677:	c7 04 24 26 90 10 80 	movl   $0x80109026,(%esp)
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
801016ad:	e8 ed 21 00 00       	call   8010389f <log_write>
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
801016cf:	c7 44 24 04 39 90 10 	movl   $0x80109039,0x4(%esp)
801016d6:	80 
801016d7:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
801016de:	e8 3b 40 00 00       	call   8010571e <initlock>
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
80101704:	c7 44 24 04 40 90 10 	movl   $0x80109040,0x4(%esp)
8010170b:	80 
8010170c:	89 04 24             	mov    %eax,(%esp)
8010170f:	e8 cc 3e 00 00       	call   801055e0 <initsleeplock>
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
8010177d:	c7 04 24 48 90 10 80 	movl   $0x80109048,(%esp)
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
801017ff:	e8 9e 41 00 00       	call   801059a2 <memset>
      dip->type = type;
80101804:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101807:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010180a:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
8010180d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101810:	89 04 24             	mov    %eax,(%esp)
80101813:	e8 87 20 00 00       	call   8010389f <log_write>
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
80101855:	c7 04 24 9b 90 10 80 	movl   $0x8010909b,(%esp)
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
80101902:	e8 64 41 00 00       	call   80105a6b <memmove>
  log_write(bp);
80101907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190a:	89 04 24             	mov    %eax,(%esp)
8010190d:	e8 8d 1f 00 00       	call   8010389f <log_write>
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
8010192c:	e8 0e 3e 00 00       	call   8010573f <acquire>

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
80101976:	e8 2e 3e 00 00       	call   801057a9 <release>
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
801019ac:	c7 04 24 ad 90 10 80 	movl   $0x801090ad,(%esp)
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
801019ea:	e8 ba 3d 00 00       	call   801057a9 <release>

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
80101a01:	e8 39 3d 00 00       	call   8010573f <acquire>
  ip->ref++;
80101a06:	8b 45 08             	mov    0x8(%ebp),%eax
80101a09:	8b 40 08             	mov    0x8(%eax),%eax
80101a0c:	8d 50 01             	lea    0x1(%eax),%edx
80101a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a12:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a15:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101a1c:	e8 88 3d 00 00       	call   801057a9 <release>
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
80101a3c:	c7 04 24 bd 90 10 80 	movl   $0x801090bd,(%esp)
80101a43:	e8 0c eb ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101a48:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4b:	83 c0 0c             	add    $0xc,%eax
80101a4e:	89 04 24             	mov    %eax,(%esp)
80101a51:	e8 c4 3b 00 00       	call   8010561a <acquiresleep>

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
80101afd:	e8 69 3f 00 00       	call   80105a6b <memmove>
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
80101b22:	c7 04 24 c3 90 10 80 	movl   $0x801090c3,(%esp)
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
80101b45:	e8 6d 3b 00 00       	call   801056b7 <holdingsleep>
80101b4a:	85 c0                	test   %eax,%eax
80101b4c:	74 0a                	je     80101b58 <iunlock+0x28>
80101b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b51:	8b 40 08             	mov    0x8(%eax),%eax
80101b54:	85 c0                	test   %eax,%eax
80101b56:	7f 0c                	jg     80101b64 <iunlock+0x34>
    panic("iunlock");
80101b58:	c7 04 24 d2 90 10 80 	movl   $0x801090d2,(%esp)
80101b5f:	e8 f0 e9 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101b64:	8b 45 08             	mov    0x8(%ebp),%eax
80101b67:	83 c0 0c             	add    $0xc,%eax
80101b6a:	89 04 24             	mov    %eax,(%esp)
80101b6d:	e8 03 3b 00 00       	call   80105675 <releasesleep>
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
80101b83:	e8 92 3a 00 00       	call   8010561a <acquiresleep>
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
80101ba5:	e8 95 3b 00 00       	call   8010573f <acquire>
    int r = ip->ref;
80101baa:	8b 45 08             	mov    0x8(%ebp),%eax
80101bad:	8b 40 08             	mov    0x8(%eax),%eax
80101bb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101bb3:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101bba:	e8 ea 3b 00 00       	call   801057a9 <release>
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
80101bf7:	e8 79 3a 00 00       	call   80105675 <releasesleep>

  acquire(&icache.lock);
80101bfc:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101c03:	e8 37 3b 00 00       	call   8010573f <acquire>
  ip->ref--;
80101c08:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0b:	8b 40 08             	mov    0x8(%eax),%eax
80101c0e:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c11:	8b 45 08             	mov    0x8(%ebp),%eax
80101c14:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c17:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101c1e:	e8 86 3b 00 00       	call   801057a9 <release>
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
80101d2f:	e8 6b 1b 00 00       	call   8010389f <log_write>
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
80101d44:	c7 04 24 da 90 10 80 	movl   $0x801090da,(%esp)
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
80101fee:	e8 78 3a 00 00       	call   80105a6b <memmove>
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
8010214d:	e8 19 39 00 00       	call   80105a6b <memmove>
    log_write(bp);
80102152:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102155:	89 04 24             	mov    %eax,(%esp)
80102158:	e8 42 17 00 00       	call   8010389f <log_write>
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
801021cb:	e8 3a 39 00 00       	call   80105b0a <strncmp>
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
801021e4:	c7 04 24 ed 90 10 80 	movl   $0x801090ed,(%esp)
801021eb:	e8 64 e3 ff ff       	call   80100554 <panic>

  cprintf("\t\ttest\n");
801021f0:	c7 04 24 ff 90 10 80 	movl   $0x801090ff,(%esp)
801021f7:	e8 c5 e1 ff ff       	call   801003c1 <cprintf>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102203:	e9 9e 00 00 00       	jmp    801022a6 <dirlookup+0xd4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102208:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010220f:	00 
80102210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102213:	89 44 24 08          	mov    %eax,0x8(%esp)
80102217:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010221a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010221e:	8b 45 08             	mov    0x8(%ebp),%eax
80102221:	89 04 24             	mov    %eax,(%esp)
80102224:	e8 94 fc ff ff       	call   80101ebd <readi>
80102229:	83 f8 10             	cmp    $0x10,%eax
8010222c:	74 0c                	je     8010223a <dirlookup+0x68>
      panic("dirlookup read");
8010222e:	c7 04 24 07 91 10 80 	movl   $0x80109107,(%esp)
80102235:	e8 1a e3 ff ff       	call   80100554 <panic>
    cprintf("\t\ttesta\n");
8010223a:	c7 04 24 16 91 10 80 	movl   $0x80109116,(%esp)
80102241:	e8 7b e1 ff ff       	call   801003c1 <cprintf>
    if(de.inum == 0)
80102246:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102249:	66 85 c0             	test   %ax,%ax
8010224c:	75 02                	jne    80102250 <dirlookup+0x7e>
      continue;
8010224e:	eb 52                	jmp    801022a2 <dirlookup+0xd0>
    if(namecmp(name, de.name) == 0){
80102250:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102253:	83 c0 02             	add    $0x2,%eax
80102256:	89 44 24 04          	mov    %eax,0x4(%esp)
8010225a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010225d:	89 04 24             	mov    %eax,(%esp)
80102260:	e8 4b ff ff ff       	call   801021b0 <namecmp>
80102265:	85 c0                	test   %eax,%eax
80102267:	75 39                	jne    801022a2 <dirlookup+0xd0>
      cprintf("\t\ttesta\n");
80102269:	c7 04 24 16 91 10 80 	movl   $0x80109116,(%esp)
80102270:	e8 4c e1 ff ff       	call   801003c1 <cprintf>
      // entry matches path element
      if(poff)
80102275:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102279:	74 08                	je     80102283 <dirlookup+0xb1>
        *poff = off;
8010227b:	8b 45 10             	mov    0x10(%ebp),%eax
8010227e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102281:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102283:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102286:	0f b7 c0             	movzwl %ax,%eax
80102289:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010228c:	8b 45 08             	mov    0x8(%ebp),%eax
8010228f:	8b 00                	mov    (%eax),%eax
80102291:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102294:	89 54 24 04          	mov    %edx,0x4(%esp)
80102298:	89 04 24             	mov    %eax,(%esp)
8010229b:	e8 7f f6 ff ff       	call   8010191f <iget>
801022a0:	eb 18                	jmp    801022ba <dirlookup+0xe8>
  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  cprintf("\t\ttest\n");

  for(off = 0; off < dp->size; off += sizeof(de)){
801022a2:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801022a6:	8b 45 08             	mov    0x8(%ebp),%eax
801022a9:	8b 40 58             	mov    0x58(%eax),%eax
801022ac:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801022af:	0f 87 53 ff ff ff    	ja     80102208 <dirlookup+0x36>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
801022b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022ba:	c9                   	leave  
801022bb:	c3                   	ret    

801022bc <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
801022bc:	55                   	push   %ebp
801022bd:	89 e5                	mov    %esp,%ebp
801022bf:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
801022c2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801022c9:	00 
801022ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801022cd:	89 44 24 04          	mov    %eax,0x4(%esp)
801022d1:	8b 45 08             	mov    0x8(%ebp),%eax
801022d4:	89 04 24             	mov    %eax,(%esp)
801022d7:	e8 f6 fe ff ff       	call   801021d2 <dirlookup>
801022dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022e3:	74 15                	je     801022fa <dirlink+0x3e>
    iput(ip);
801022e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801022e8:	89 04 24             	mov    %eax,(%esp)
801022eb:	e8 84 f8 ff ff       	call   80101b74 <iput>
    return -1;
801022f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022f5:	e9 b6 00 00 00       	jmp    801023b0 <dirlink+0xf4>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102301:	eb 45                	jmp    80102348 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102306:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
8010230d:	00 
8010230e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102312:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102315:	89 44 24 04          	mov    %eax,0x4(%esp)
80102319:	8b 45 08             	mov    0x8(%ebp),%eax
8010231c:	89 04 24             	mov    %eax,(%esp)
8010231f:	e8 99 fb ff ff       	call   80101ebd <readi>
80102324:	83 f8 10             	cmp    $0x10,%eax
80102327:	74 0c                	je     80102335 <dirlink+0x79>
      panic("dirlink read");
80102329:	c7 04 24 1f 91 10 80 	movl   $0x8010911f,(%esp)
80102330:	e8 1f e2 ff ff       	call   80100554 <panic>
    if(de.inum == 0)
80102335:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102338:	66 85 c0             	test   %ax,%ax
8010233b:	75 02                	jne    8010233f <dirlink+0x83>
      break;
8010233d:	eb 16                	jmp    80102355 <dirlink+0x99>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010233f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102342:	83 c0 10             	add    $0x10,%eax
80102345:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102348:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010234b:	8b 45 08             	mov    0x8(%ebp),%eax
8010234e:	8b 40 58             	mov    0x58(%eax),%eax
80102351:	39 c2                	cmp    %eax,%edx
80102353:	72 ae                	jb     80102303 <dirlink+0x47>
      panic("dirlink read");
    if(de.inum == 0)
      break;
  }

  strncpy(de.name, name, DIRSIZ);
80102355:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
8010235c:	00 
8010235d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102360:	89 44 24 04          	mov    %eax,0x4(%esp)
80102364:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102367:	83 c0 02             	add    $0x2,%eax
8010236a:	89 04 24             	mov    %eax,(%esp)
8010236d:	e8 e6 37 00 00       	call   80105b58 <strncpy>
  de.inum = inum;
80102372:	8b 45 10             	mov    0x10(%ebp),%eax
80102375:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010237c:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80102383:	00 
80102384:	89 44 24 08          	mov    %eax,0x8(%esp)
80102388:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010238b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010238f:	8b 45 08             	mov    0x8(%ebp),%eax
80102392:	89 04 24             	mov    %eax,(%esp)
80102395:	e8 87 fc ff ff       	call   80102021 <writei>
8010239a:	83 f8 10             	cmp    $0x10,%eax
8010239d:	74 0c                	je     801023ab <dirlink+0xef>
    panic("dirlink");
8010239f:	c7 04 24 2c 91 10 80 	movl   $0x8010912c,(%esp)
801023a6:	e8 a9 e1 ff ff       	call   80100554 <panic>

  return 0;
801023ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
801023b0:	c9                   	leave  
801023b1:	c3                   	ret    

801023b2 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801023b2:	55                   	push   %ebp
801023b3:	89 e5                	mov    %esp,%ebp
801023b5:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int len;

  while(*path == '/')
801023b8:	eb 03                	jmp    801023bd <skipelem+0xb>
    path++;
801023ba:	ff 45 08             	incl   0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
801023bd:	8b 45 08             	mov    0x8(%ebp),%eax
801023c0:	8a 00                	mov    (%eax),%al
801023c2:	3c 2f                	cmp    $0x2f,%al
801023c4:	74 f4                	je     801023ba <skipelem+0x8>
    path++;
  if(*path == 0)
801023c6:	8b 45 08             	mov    0x8(%ebp),%eax
801023c9:	8a 00                	mov    (%eax),%al
801023cb:	84 c0                	test   %al,%al
801023cd:	75 0a                	jne    801023d9 <skipelem+0x27>
    return 0;
801023cf:	b8 00 00 00 00       	mov    $0x0,%eax
801023d4:	e9 81 00 00 00       	jmp    8010245a <skipelem+0xa8>
  s = path;
801023d9:	8b 45 08             	mov    0x8(%ebp),%eax
801023dc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
801023df:	eb 03                	jmp    801023e4 <skipelem+0x32>
    path++;
801023e1:	ff 45 08             	incl   0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
801023e4:	8b 45 08             	mov    0x8(%ebp),%eax
801023e7:	8a 00                	mov    (%eax),%al
801023e9:	3c 2f                	cmp    $0x2f,%al
801023eb:	74 09                	je     801023f6 <skipelem+0x44>
801023ed:	8b 45 08             	mov    0x8(%ebp),%eax
801023f0:	8a 00                	mov    (%eax),%al
801023f2:	84 c0                	test   %al,%al
801023f4:	75 eb                	jne    801023e1 <skipelem+0x2f>
    path++;
  len = path - s;
801023f6:	8b 55 08             	mov    0x8(%ebp),%edx
801023f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023fc:	29 c2                	sub    %eax,%edx
801023fe:	89 d0                	mov    %edx,%eax
80102400:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102403:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102407:	7e 1c                	jle    80102425 <skipelem+0x73>
    memmove(name, s, DIRSIZ);
80102409:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80102410:	00 
80102411:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102414:	89 44 24 04          	mov    %eax,0x4(%esp)
80102418:	8b 45 0c             	mov    0xc(%ebp),%eax
8010241b:	89 04 24             	mov    %eax,(%esp)
8010241e:	e8 48 36 00 00       	call   80105a6b <memmove>
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102423:	eb 29                	jmp    8010244e <skipelem+0x9c>
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80102425:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102428:	89 44 24 08          	mov    %eax,0x8(%esp)
8010242c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010242f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102433:	8b 45 0c             	mov    0xc(%ebp),%eax
80102436:	89 04 24             	mov    %eax,(%esp)
80102439:	e8 2d 36 00 00       	call   80105a6b <memmove>
    name[len] = 0;
8010243e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102441:	8b 45 0c             	mov    0xc(%ebp),%eax
80102444:	01 d0                	add    %edx,%eax
80102446:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
80102449:	eb 03                	jmp    8010244e <skipelem+0x9c>
    path++;
8010244b:	ff 45 08             	incl   0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
8010244e:	8b 45 08             	mov    0x8(%ebp),%eax
80102451:	8a 00                	mov    (%eax),%al
80102453:	3c 2f                	cmp    $0x2f,%al
80102455:	74 f4                	je     8010244b <skipelem+0x99>
    path++;
  return path;
80102457:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010245a:	c9                   	leave  
8010245b:	c3                   	ret    

8010245c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
8010245c:	55                   	push   %ebp
8010245d:	89 e5                	mov    %esp,%ebp
8010245f:	53                   	push   %ebx
80102460:	83 ec 24             	sub    $0x24,%esp
  struct inode *ip, *next, *iroot;

  iroot = iget(ROOTDEV, ROOTINO);
80102463:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010246a:	00 
8010246b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102472:	e8 a8 f4 ff ff       	call   8010191f <iget>
80102477:	89 45 f0             	mov    %eax,-0x10(%ebp)

  cprintf("namex begin %s\n", path);
8010247a:	8b 45 08             	mov    0x8(%ebp),%eax
8010247d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102481:	c7 04 24 34 91 10 80 	movl   $0x80109134,(%esp)
80102488:	e8 34 df ff ff       	call   801003c1 <cprintf>
  cprintf("\tmyproc is %s\n", ((myproc() == 0) ? "null" : myproc()->name));
8010248d:	e8 06 1e 00 00       	call   80104298 <myproc>
80102492:	85 c0                	test   %eax,%eax
80102494:	74 0a                	je     801024a0 <namex+0x44>
80102496:	e8 fd 1d 00 00       	call   80104298 <myproc>
8010249b:	83 c0 6c             	add    $0x6c,%eax
8010249e:	eb 05                	jmp    801024a5 <namex+0x49>
801024a0:	b8 44 91 10 80       	mov    $0x80109144,%eax
801024a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801024a9:	c7 04 24 49 91 10 80 	movl   $0x80109149,(%esp)
801024b0:	e8 0c df ff ff       	call   801003c1 <cprintf>

  // Absolute or relative
  if (myproc() == 0)
801024b5:	e8 de 1d 00 00       	call   80104298 <myproc>
801024ba:	85 c0                	test   %eax,%eax
801024bc:	75 0b                	jne    801024c9 <namex+0x6d>
    ip = iroot;
801024be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024c4:	e9 96 00 00 00       	jmp    8010255f <namex+0x103>
  else if(*path == '/') 
801024c9:	8b 45 08             	mov    0x8(%ebp),%eax
801024cc:	8a 00                	mov    (%eax),%al
801024ce:	3c 2f                	cmp    $0x2f,%al
801024d0:	75 1b                	jne    801024ed <namex+0x91>
    ip = idup(myproc()->cont->rootdir);
801024d2:	e8 c1 1d 00 00       	call   80104298 <myproc>
801024d7:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801024dd:	8b 40 10             	mov    0x10(%eax),%eax
801024e0:	89 04 24             	mov    %eax,(%esp)
801024e3:	e8 0c f5 ff ff       	call   801019f4 <idup>
801024e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024eb:	eb 72                	jmp    8010255f <namex+0x103>
  else{    
    ip = idup(myproc()->cwd);
801024ed:	e8 a6 1d 00 00       	call   80104298 <myproc>
801024f2:	8b 40 68             	mov    0x68(%eax),%eax
801024f5:	89 04 24             	mov    %eax,(%esp)
801024f8:	e8 f7 f4 ff ff       	call   801019f4 <idup>
801024fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("\t\there.5 myproc cwd is it's container %d\n", (myproc()->cwd->inum == myproc()->cont->rootdir->inum));
80102500:	e8 93 1d 00 00       	call   80104298 <myproc>
80102505:	8b 40 68             	mov    0x68(%eax),%eax
80102508:	8b 58 04             	mov    0x4(%eax),%ebx
8010250b:	e8 88 1d 00 00       	call   80104298 <myproc>
80102510:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102516:	8b 40 10             	mov    0x10(%eax),%eax
80102519:	8b 40 04             	mov    0x4(%eax),%eax
8010251c:	39 c3                	cmp    %eax,%ebx
8010251e:	0f 94 c0             	sete   %al
80102521:	0f b6 c0             	movzbl %al,%eax
80102524:	89 44 24 04          	mov    %eax,0x4(%esp)
80102528:	c7 04 24 58 91 10 80 	movl   $0x80109158,(%esp)
8010252f:	e8 8d de ff ff       	call   801003c1 <cprintf>
    cprintf("\t\trootdir is type folder %d\n", (myproc()->cont->rootdir->type == T_DIR));    
80102534:	e8 5f 1d 00 00       	call   80104298 <myproc>
80102539:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010253f:	8b 40 10             	mov    0x10(%eax),%eax
80102542:	8b 40 50             	mov    0x50(%eax),%eax
80102545:	66 83 f8 01          	cmp    $0x1,%ax
80102549:	0f 94 c0             	sete   %al
8010254c:	0f b6 c0             	movzbl %al,%eax
8010254f:	89 44 24 04          	mov    %eax,0x4(%esp)
80102553:	c7 04 24 82 91 10 80 	movl   $0x80109182,(%esp)
8010255a:	e8 62 de ff ff       	call   801003c1 <cprintf>
  }

  cprintf("\tHere\n");
8010255f:	c7 04 24 9f 91 10 80 	movl   $0x8010919f,(%esp)
80102566:	e8 56 de ff ff       	call   801003c1 <cprintf>

  while((path = skipelem(path, name)) != 0){
8010256b:	e9 0a 01 00 00       	jmp    8010267a <namex+0x21e>
    ilock(ip);
80102570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102573:	89 04 24             	mov    %eax,(%esp)
80102576:	e8 ab f4 ff ff       	call   80101a26 <ilock>
    cprintf("Here1.5\n");
8010257b:	c7 04 24 a6 91 10 80 	movl   $0x801091a6,(%esp)
80102582:	e8 3a de ff ff       	call   801003c1 <cprintf>
    if(ip->type != T_DIR){
80102587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010258a:	8b 40 50             	mov    0x50(%eax),%eax
8010258d:	66 83 f8 01          	cmp    $0x1,%ax
80102591:	74 21                	je     801025b4 <namex+0x158>
      iunlockput(ip);
80102593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102596:	89 04 24             	mov    %eax,(%esp)
80102599:	e8 87 f6 ff ff       	call   80101c25 <iunlockput>
      cprintf("Here2\n");
8010259e:	c7 04 24 af 91 10 80 	movl   $0x801091af,(%esp)
801025a5:	e8 17 de ff ff       	call   801003c1 <cprintf>
      return 0;
801025aa:	b8 00 00 00 00       	mov    $0x0,%eax
801025af:	e9 0c 01 00 00       	jmp    801026c0 <namex+0x264>
    }
    if(nameiparent && *path == '\0'){
801025b4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025b8:	74 28                	je     801025e2 <namex+0x186>
801025ba:	8b 45 08             	mov    0x8(%ebp),%eax
801025bd:	8a 00                	mov    (%eax),%al
801025bf:	84 c0                	test   %al,%al
801025c1:	75 1f                	jne    801025e2 <namex+0x186>
      // Stop one level early.
      iunlock(ip);
801025c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025c6:	89 04 24             	mov    %eax,(%esp)
801025c9:	e8 62 f5 ff ff       	call   80101b30 <iunlock>
      cprintf("Here3\n");
801025ce:	c7 04 24 b6 91 10 80 	movl   $0x801091b6,(%esp)
801025d5:	e8 e7 dd ff ff       	call   801003c1 <cprintf>
      return ip;
801025da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025dd:	e9 de 00 00 00       	jmp    801026c0 <namex+0x264>
    }
    cprintf("\tHere3.5\n");
801025e2:	c7 04 24 bd 91 10 80 	movl   $0x801091bd,(%esp)
801025e9:	e8 d3 dd ff ff       	call   801003c1 <cprintf>
    if((next = dirlookup(ip, name, 0)) == 0){
801025ee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801025f5:	00 
801025f6:	8b 45 10             	mov    0x10(%ebp),%eax
801025f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801025fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102600:	89 04 24             	mov    %eax,(%esp)
80102603:	e8 ca fb ff ff       	call   801021d2 <dirlookup>
80102608:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010260b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010260f:	75 21                	jne    80102632 <namex+0x1d6>
      iunlockput(ip);
80102611:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102614:	89 04 24             	mov    %eax,(%esp)
80102617:	e8 09 f6 ff ff       	call   80101c25 <iunlockput>
      cprintf("Here4\n");
8010261c:	c7 04 24 c7 91 10 80 	movl   $0x801091c7,(%esp)
80102623:	e8 99 dd ff ff       	call   801003c1 <cprintf>
      return 0;
80102628:	b8 00 00 00 00       	mov    $0x0,%eax
8010262d:	e9 8e 00 00 00       	jmp    801026c0 <namex+0x264>
    }    
    iunlockput(ip);
80102632:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102635:	89 04 24             	mov    %eax,(%esp)
80102638:	e8 e8 f5 ff ff       	call   80101c25 <iunlockput>

    cprintf("\tHere5\n");
8010263d:	c7 04 24 ce 91 10 80 	movl   $0x801091ce,(%esp)
80102644:	e8 78 dd ff ff       	call   801003c1 <cprintf>
    
    // If myproc is running in root container, 
    // or the above (next) folder is not the root folder,
    // then set ip = next
    // TODO: validate that this works
    if (myproc()->cont->rootdir->inum == iroot->inum || next->inum != iroot->inum)
80102649:	e8 4a 1c 00 00       	call   80104298 <myproc>
8010264e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102654:	8b 40 10             	mov    0x10(%eax),%eax
80102657:	8b 50 04             	mov    0x4(%eax),%edx
8010265a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010265d:	8b 40 04             	mov    0x4(%eax),%eax
80102660:	39 c2                	cmp    %eax,%edx
80102662:	74 10                	je     80102674 <namex+0x218>
80102664:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102667:	8b 50 04             	mov    0x4(%eax),%edx
8010266a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010266d:	8b 40 04             	mov    0x4(%eax),%eax
80102670:	39 c2                	cmp    %eax,%edx
80102672:	74 06                	je     8010267a <namex+0x21e>
      ip = next;
80102674:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102677:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("\t\trootdir is type folder %d\n", (myproc()->cont->rootdir->type == T_DIR));    
  }

  cprintf("\tHere\n");

  while((path = skipelem(path, name)) != 0){
8010267a:	8b 45 10             	mov    0x10(%ebp),%eax
8010267d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102681:	8b 45 08             	mov    0x8(%ebp),%eax
80102684:	89 04 24             	mov    %eax,(%esp)
80102687:	e8 26 fd ff ff       	call   801023b2 <skipelem>
8010268c:	89 45 08             	mov    %eax,0x8(%ebp)
8010268f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102693:	0f 85 d7 fe ff ff    	jne    80102570 <namex+0x114>
    // then set ip = next
    // TODO: validate that this works
    if (myproc()->cont->rootdir->inum == iroot->inum || next->inum != iroot->inum)
      ip = next;
  }
  if(nameiparent){
80102699:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010269d:	74 12                	je     801026b1 <namex+0x255>
    iput(ip);
8010269f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801026a2:	89 04 24             	mov    %eax,(%esp)
801026a5:	e8 ca f4 ff ff       	call   80101b74 <iput>
    return 0;
801026aa:	b8 00 00 00 00       	mov    $0x0,%eax
801026af:	eb 0f                	jmp    801026c0 <namex+0x264>
  }
  cprintf("\treturning ip\n");
801026b1:	c7 04 24 d6 91 10 80 	movl   $0x801091d6,(%esp)
801026b8:	e8 04 dd ff ff       	call   801003c1 <cprintf>
  return ip;
801026bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801026c0:	83 c4 24             	add    $0x24,%esp
801026c3:	5b                   	pop    %ebx
801026c4:	5d                   	pop    %ebp
801026c5:	c3                   	ret    

801026c6 <namei>:

struct inode*
namei(char *path)
{
801026c6:	55                   	push   %ebp
801026c7:	89 e5                	mov    %esp,%ebp
801026c9:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801026cc:	8d 45 ea             	lea    -0x16(%ebp),%eax
801026cf:	89 44 24 08          	mov    %eax,0x8(%esp)
801026d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801026da:	00 
801026db:	8b 45 08             	mov    0x8(%ebp),%eax
801026de:	89 04 24             	mov    %eax,(%esp)
801026e1:	e8 76 fd ff ff       	call   8010245c <namex>
}
801026e6:	c9                   	leave  
801026e7:	c3                   	ret    

801026e8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801026e8:	55                   	push   %ebp
801026e9:	89 e5                	mov    %esp,%ebp
801026eb:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
801026ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801026f1:	89 44 24 08          	mov    %eax,0x8(%esp)
801026f5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801026fc:	00 
801026fd:	8b 45 08             	mov    0x8(%ebp),%eax
80102700:	89 04 24             	mov    %eax,(%esp)
80102703:	e8 54 fd ff ff       	call   8010245c <namex>
}
80102708:	c9                   	leave  
80102709:	c3                   	ret    
	...

8010270c <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
8010270c:	55                   	push   %ebp
8010270d:	89 e5                	mov    %esp,%ebp
8010270f:	83 ec 14             	sub    $0x14,%esp
80102712:	8b 45 08             	mov    0x8(%ebp),%eax
80102715:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102719:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010271c:	89 c2                	mov    %eax,%edx
8010271e:	ec                   	in     (%dx),%al
8010271f:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102722:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102725:	c9                   	leave  
80102726:	c3                   	ret    

80102727 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102727:	55                   	push   %ebp
80102728:	89 e5                	mov    %esp,%ebp
8010272a:	57                   	push   %edi
8010272b:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010272c:	8b 55 08             	mov    0x8(%ebp),%edx
8010272f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102732:	8b 45 10             	mov    0x10(%ebp),%eax
80102735:	89 cb                	mov    %ecx,%ebx
80102737:	89 df                	mov    %ebx,%edi
80102739:	89 c1                	mov    %eax,%ecx
8010273b:	fc                   	cld    
8010273c:	f3 6d                	rep insl (%dx),%es:(%edi)
8010273e:	89 c8                	mov    %ecx,%eax
80102740:	89 fb                	mov    %edi,%ebx
80102742:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102745:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102748:	5b                   	pop    %ebx
80102749:	5f                   	pop    %edi
8010274a:	5d                   	pop    %ebp
8010274b:	c3                   	ret    

8010274c <outb>:

static inline void
outb(ushort port, uchar data)
{
8010274c:	55                   	push   %ebp
8010274d:	89 e5                	mov    %esp,%ebp
8010274f:	83 ec 08             	sub    $0x8,%esp
80102752:	8b 45 08             	mov    0x8(%ebp),%eax
80102755:	8b 55 0c             	mov    0xc(%ebp),%edx
80102758:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
8010275c:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010275f:	8a 45 f8             	mov    -0x8(%ebp),%al
80102762:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102765:	ee                   	out    %al,(%dx)
}
80102766:	c9                   	leave  
80102767:	c3                   	ret    

80102768 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
80102768:	55                   	push   %ebp
80102769:	89 e5                	mov    %esp,%ebp
8010276b:	56                   	push   %esi
8010276c:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
8010276d:	8b 55 08             	mov    0x8(%ebp),%edx
80102770:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102773:	8b 45 10             	mov    0x10(%ebp),%eax
80102776:	89 cb                	mov    %ecx,%ebx
80102778:	89 de                	mov    %ebx,%esi
8010277a:	89 c1                	mov    %eax,%ecx
8010277c:	fc                   	cld    
8010277d:	f3 6f                	rep outsl %ds:(%esi),(%dx)
8010277f:	89 c8                	mov    %ecx,%eax
80102781:	89 f3                	mov    %esi,%ebx
80102783:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102786:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
80102789:	5b                   	pop    %ebx
8010278a:	5e                   	pop    %esi
8010278b:	5d                   	pop    %ebp
8010278c:	c3                   	ret    

8010278d <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
8010278d:	55                   	push   %ebp
8010278e:	89 e5                	mov    %esp,%ebp
80102790:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102793:	90                   	nop
80102794:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010279b:	e8 6c ff ff ff       	call   8010270c <inb>
801027a0:	0f b6 c0             	movzbl %al,%eax
801027a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
801027a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801027a9:	25 c0 00 00 00       	and    $0xc0,%eax
801027ae:	83 f8 40             	cmp    $0x40,%eax
801027b1:	75 e1                	jne    80102794 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801027b3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801027b7:	74 11                	je     801027ca <idewait+0x3d>
801027b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801027bc:	83 e0 21             	and    $0x21,%eax
801027bf:	85 c0                	test   %eax,%eax
801027c1:	74 07                	je     801027ca <idewait+0x3d>
    return -1;
801027c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801027c8:	eb 05                	jmp    801027cf <idewait+0x42>
  return 0;
801027ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
801027cf:	c9                   	leave  
801027d0:	c3                   	ret    

801027d1 <ideinit>:

void
ideinit(void)
{
801027d1:	55                   	push   %ebp
801027d2:	89 e5                	mov    %esp,%ebp
801027d4:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
801027d7:	c7 44 24 04 e5 91 10 	movl   $0x801091e5,0x4(%esp)
801027de:	80 
801027df:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
801027e6:	e8 33 2f 00 00       	call   8010571e <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
801027eb:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
801027f0:	48                   	dec    %eax
801027f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801027f5:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801027fc:	e8 66 04 00 00       	call   80102c67 <ioapicenable>
  idewait(0);
80102801:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102808:	e8 80 ff ff ff       	call   8010278d <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010280d:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
80102814:	00 
80102815:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
8010281c:	e8 2b ff ff ff       	call   8010274c <outb>
  for(i=0; i<1000; i++){
80102821:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102828:	eb 1f                	jmp    80102849 <ideinit+0x78>
    if(inb(0x1f7) != 0){
8010282a:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102831:	e8 d6 fe ff ff       	call   8010270c <inb>
80102836:	84 c0                	test   %al,%al
80102838:	74 0c                	je     80102846 <ideinit+0x75>
      havedisk1 = 1;
8010283a:	c7 05 78 c7 10 80 01 	movl   $0x1,0x8010c778
80102841:	00 00 00 
      break;
80102844:	eb 0c                	jmp    80102852 <ideinit+0x81>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102846:	ff 45 f4             	incl   -0xc(%ebp)
80102849:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102850:	7e d8                	jle    8010282a <ideinit+0x59>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102852:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
80102859:	00 
8010285a:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102861:	e8 e6 fe ff ff       	call   8010274c <outb>
}
80102866:	c9                   	leave  
80102867:	c3                   	ret    

80102868 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102868:	55                   	push   %ebp
80102869:	89 e5                	mov    %esp,%ebp
8010286b:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
8010286e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102872:	75 0c                	jne    80102880 <idestart+0x18>
    panic("idestart");
80102874:	c7 04 24 e9 91 10 80 	movl   $0x801091e9,(%esp)
8010287b:	e8 d4 dc ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
80102880:	8b 45 08             	mov    0x8(%ebp),%eax
80102883:	8b 40 08             	mov    0x8(%eax),%eax
80102886:	3d e7 03 00 00       	cmp    $0x3e7,%eax
8010288b:	76 0c                	jbe    80102899 <idestart+0x31>
    panic("incorrect blockno");
8010288d:	c7 04 24 f2 91 10 80 	movl   $0x801091f2,(%esp)
80102894:	e8 bb dc ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
80102899:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801028a0:	8b 45 08             	mov    0x8(%ebp),%eax
801028a3:	8b 50 08             	mov    0x8(%eax),%edx
801028a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028a9:	0f af c2             	imul   %edx,%eax
801028ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
801028af:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801028b3:	75 07                	jne    801028bc <idestart+0x54>
801028b5:	b8 20 00 00 00       	mov    $0x20,%eax
801028ba:	eb 05                	jmp    801028c1 <idestart+0x59>
801028bc:	b8 c4 00 00 00       	mov    $0xc4,%eax
801028c1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
801028c4:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
801028c8:	75 07                	jne    801028d1 <idestart+0x69>
801028ca:	b8 30 00 00 00       	mov    $0x30,%eax
801028cf:	eb 05                	jmp    801028d6 <idestart+0x6e>
801028d1:	b8 c5 00 00 00       	mov    $0xc5,%eax
801028d6:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
801028d9:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801028dd:	7e 0c                	jle    801028eb <idestart+0x83>
801028df:	c7 04 24 e9 91 10 80 	movl   $0x801091e9,(%esp)
801028e6:	e8 69 dc ff ff       	call   80100554 <panic>

  idewait(0);
801028eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028f2:	e8 96 fe ff ff       	call   8010278d <idewait>
  outb(0x3f6, 0);  // generate interrupt
801028f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801028fe:	00 
801028ff:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
80102906:	e8 41 fe ff ff       	call   8010274c <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
8010290b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010290e:	0f b6 c0             	movzbl %al,%eax
80102911:	89 44 24 04          	mov    %eax,0x4(%esp)
80102915:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
8010291c:	e8 2b fe ff ff       	call   8010274c <outb>
  outb(0x1f3, sector & 0xff);
80102921:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102924:	0f b6 c0             	movzbl %al,%eax
80102927:	89 44 24 04          	mov    %eax,0x4(%esp)
8010292b:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
80102932:	e8 15 fe ff ff       	call   8010274c <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
80102937:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010293a:	c1 f8 08             	sar    $0x8,%eax
8010293d:	0f b6 c0             	movzbl %al,%eax
80102940:	89 44 24 04          	mov    %eax,0x4(%esp)
80102944:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
8010294b:	e8 fc fd ff ff       	call   8010274c <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
80102950:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102953:	c1 f8 10             	sar    $0x10,%eax
80102956:	0f b6 c0             	movzbl %al,%eax
80102959:	89 44 24 04          	mov    %eax,0x4(%esp)
8010295d:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102964:	e8 e3 fd ff ff       	call   8010274c <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80102969:	8b 45 08             	mov    0x8(%ebp),%eax
8010296c:	8b 40 04             	mov    0x4(%eax),%eax
8010296f:	83 e0 01             	and    $0x1,%eax
80102972:	c1 e0 04             	shl    $0x4,%eax
80102975:	88 c2                	mov    %al,%dl
80102977:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010297a:	c1 f8 18             	sar    $0x18,%eax
8010297d:	83 e0 0f             	and    $0xf,%eax
80102980:	09 d0                	or     %edx,%eax
80102982:	83 c8 e0             	or     $0xffffffe0,%eax
80102985:	0f b6 c0             	movzbl %al,%eax
80102988:	89 44 24 04          	mov    %eax,0x4(%esp)
8010298c:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102993:	e8 b4 fd ff ff       	call   8010274c <outb>
  if(b->flags & B_DIRTY){
80102998:	8b 45 08             	mov    0x8(%ebp),%eax
8010299b:	8b 00                	mov    (%eax),%eax
8010299d:	83 e0 04             	and    $0x4,%eax
801029a0:	85 c0                	test   %eax,%eax
801029a2:	74 36                	je     801029da <idestart+0x172>
    outb(0x1f7, write_cmd);
801029a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
801029a7:	0f b6 c0             	movzbl %al,%eax
801029aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801029ae:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801029b5:	e8 92 fd ff ff       	call   8010274c <outb>
    outsl(0x1f0, b->data, BSIZE/4);
801029ba:	8b 45 08             	mov    0x8(%ebp),%eax
801029bd:	83 c0 5c             	add    $0x5c,%eax
801029c0:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
801029c7:	00 
801029c8:	89 44 24 04          	mov    %eax,0x4(%esp)
801029cc:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
801029d3:	e8 90 fd ff ff       	call   80102768 <outsl>
801029d8:	eb 16                	jmp    801029f0 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
801029da:	8b 45 ec             	mov    -0x14(%ebp),%eax
801029dd:	0f b6 c0             	movzbl %al,%eax
801029e0:	89 44 24 04          	mov    %eax,0x4(%esp)
801029e4:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801029eb:	e8 5c fd ff ff       	call   8010274c <outb>
  }
}
801029f0:	c9                   	leave  
801029f1:	c3                   	ret    

801029f2 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801029f2:	55                   	push   %ebp
801029f3:	89 e5                	mov    %esp,%ebp
801029f5:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801029f8:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
801029ff:	e8 3b 2d 00 00       	call   8010573f <acquire>

  if((b = idequeue) == 0){
80102a04:	a1 74 c7 10 80       	mov    0x8010c774,%eax
80102a09:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102a0c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102a10:	75 11                	jne    80102a23 <ideintr+0x31>
    release(&idelock);
80102a12:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
80102a19:	e8 8b 2d 00 00       	call   801057a9 <release>
    return;
80102a1e:	e9 90 00 00 00       	jmp    80102ab3 <ideintr+0xc1>
  }
  idequeue = b->qnext;
80102a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a26:	8b 40 58             	mov    0x58(%eax),%eax
80102a29:	a3 74 c7 10 80       	mov    %eax,0x8010c774

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102a2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a31:	8b 00                	mov    (%eax),%eax
80102a33:	83 e0 04             	and    $0x4,%eax
80102a36:	85 c0                	test   %eax,%eax
80102a38:	75 2e                	jne    80102a68 <ideintr+0x76>
80102a3a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102a41:	e8 47 fd ff ff       	call   8010278d <idewait>
80102a46:	85 c0                	test   %eax,%eax
80102a48:	78 1e                	js     80102a68 <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
80102a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a4d:	83 c0 5c             	add    $0x5c,%eax
80102a50:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102a57:	00 
80102a58:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a5c:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102a63:	e8 bf fc ff ff       	call   80102727 <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a6b:	8b 00                	mov    (%eax),%eax
80102a6d:	83 c8 02             	or     $0x2,%eax
80102a70:	89 c2                	mov    %eax,%edx
80102a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a75:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102a77:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a7a:	8b 00                	mov    (%eax),%eax
80102a7c:	83 e0 fb             	and    $0xfffffffb,%eax
80102a7f:	89 c2                	mov    %eax,%edx
80102a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a84:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a89:	89 04 24             	mov    %eax,(%esp)
80102a8c:	e8 3b 20 00 00       	call   80104acc <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102a91:	a1 74 c7 10 80       	mov    0x8010c774,%eax
80102a96:	85 c0                	test   %eax,%eax
80102a98:	74 0d                	je     80102aa7 <ideintr+0xb5>
    idestart(idequeue);
80102a9a:	a1 74 c7 10 80       	mov    0x8010c774,%eax
80102a9f:	89 04 24             	mov    %eax,(%esp)
80102aa2:	e8 c1 fd ff ff       	call   80102868 <idestart>

  release(&idelock);
80102aa7:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
80102aae:	e8 f6 2c 00 00       	call   801057a9 <release>
}
80102ab3:	c9                   	leave  
80102ab4:	c3                   	ret    

80102ab5 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102ab5:	55                   	push   %ebp
80102ab6:	89 e5                	mov    %esp,%ebp
80102ab8:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102abb:	8b 45 08             	mov    0x8(%ebp),%eax
80102abe:	83 c0 0c             	add    $0xc,%eax
80102ac1:	89 04 24             	mov    %eax,(%esp)
80102ac4:	e8 ee 2b 00 00       	call   801056b7 <holdingsleep>
80102ac9:	85 c0                	test   %eax,%eax
80102acb:	75 0c                	jne    80102ad9 <iderw+0x24>
    panic("iderw: buf not locked");
80102acd:	c7 04 24 04 92 10 80 	movl   $0x80109204,(%esp)
80102ad4:	e8 7b da ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102ad9:	8b 45 08             	mov    0x8(%ebp),%eax
80102adc:	8b 00                	mov    (%eax),%eax
80102ade:	83 e0 06             	and    $0x6,%eax
80102ae1:	83 f8 02             	cmp    $0x2,%eax
80102ae4:	75 0c                	jne    80102af2 <iderw+0x3d>
    panic("iderw: nothing to do");
80102ae6:	c7 04 24 1a 92 10 80 	movl   $0x8010921a,(%esp)
80102aed:	e8 62 da ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
80102af2:	8b 45 08             	mov    0x8(%ebp),%eax
80102af5:	8b 40 04             	mov    0x4(%eax),%eax
80102af8:	85 c0                	test   %eax,%eax
80102afa:	74 15                	je     80102b11 <iderw+0x5c>
80102afc:	a1 78 c7 10 80       	mov    0x8010c778,%eax
80102b01:	85 c0                	test   %eax,%eax
80102b03:	75 0c                	jne    80102b11 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
80102b05:	c7 04 24 2f 92 10 80 	movl   $0x8010922f,(%esp)
80102b0c:	e8 43 da ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102b11:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
80102b18:	e8 22 2c 00 00       	call   8010573f <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102b1d:	8b 45 08             	mov    0x8(%ebp),%eax
80102b20:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102b27:	c7 45 f4 74 c7 10 80 	movl   $0x8010c774,-0xc(%ebp)
80102b2e:	eb 0b                	jmp    80102b3b <iderw+0x86>
80102b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b33:	8b 00                	mov    (%eax),%eax
80102b35:	83 c0 58             	add    $0x58,%eax
80102b38:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102b3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b3e:	8b 00                	mov    (%eax),%eax
80102b40:	85 c0                	test   %eax,%eax
80102b42:	75 ec                	jne    80102b30 <iderw+0x7b>
    ;
  *pp = b;
80102b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b47:	8b 55 08             	mov    0x8(%ebp),%edx
80102b4a:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102b4c:	a1 74 c7 10 80       	mov    0x8010c774,%eax
80102b51:	3b 45 08             	cmp    0x8(%ebp),%eax
80102b54:	75 0d                	jne    80102b63 <iderw+0xae>
    idestart(b);
80102b56:	8b 45 08             	mov    0x8(%ebp),%eax
80102b59:	89 04 24             	mov    %eax,(%esp)
80102b5c:	e8 07 fd ff ff       	call   80102868 <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b61:	eb 15                	jmp    80102b78 <iderw+0xc3>
80102b63:	eb 13                	jmp    80102b78 <iderw+0xc3>
    sleep(b, &idelock);
80102b65:	c7 44 24 04 40 c7 10 	movl   $0x8010c740,0x4(%esp)
80102b6c:	80 
80102b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80102b70:	89 04 24             	mov    %eax,(%esp)
80102b73:	e8 66 1e 00 00       	call   801049de <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b78:	8b 45 08             	mov    0x8(%ebp),%eax
80102b7b:	8b 00                	mov    (%eax),%eax
80102b7d:	83 e0 06             	and    $0x6,%eax
80102b80:	83 f8 02             	cmp    $0x2,%eax
80102b83:	75 e0                	jne    80102b65 <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
80102b85:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
80102b8c:	e8 18 2c 00 00       	call   801057a9 <release>
}
80102b91:	c9                   	leave  
80102b92:	c3                   	ret    
	...

80102b94 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102b94:	55                   	push   %ebp
80102b95:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b97:	a1 14 48 11 80       	mov    0x80114814,%eax
80102b9c:	8b 55 08             	mov    0x8(%ebp),%edx
80102b9f:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102ba1:	a1 14 48 11 80       	mov    0x80114814,%eax
80102ba6:	8b 40 10             	mov    0x10(%eax),%eax
}
80102ba9:	5d                   	pop    %ebp
80102baa:	c3                   	ret    

80102bab <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102bab:	55                   	push   %ebp
80102bac:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102bae:	a1 14 48 11 80       	mov    0x80114814,%eax
80102bb3:	8b 55 08             	mov    0x8(%ebp),%edx
80102bb6:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102bb8:	a1 14 48 11 80       	mov    0x80114814,%eax
80102bbd:	8b 55 0c             	mov    0xc(%ebp),%edx
80102bc0:	89 50 10             	mov    %edx,0x10(%eax)
}
80102bc3:	5d                   	pop    %ebp
80102bc4:	c3                   	ret    

80102bc5 <ioapicinit>:

void
ioapicinit(void)
{
80102bc5:	55                   	push   %ebp
80102bc6:	89 e5                	mov    %esp,%ebp
80102bc8:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102bcb:	c7 05 14 48 11 80 00 	movl   $0xfec00000,0x80114814
80102bd2:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102bd5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102bdc:	e8 b3 ff ff ff       	call   80102b94 <ioapicread>
80102be1:	c1 e8 10             	shr    $0x10,%eax
80102be4:	25 ff 00 00 00       	and    $0xff,%eax
80102be9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102bec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102bf3:	e8 9c ff ff ff       	call   80102b94 <ioapicread>
80102bf8:	c1 e8 18             	shr    $0x18,%eax
80102bfb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102bfe:	a0 40 49 11 80       	mov    0x80114940,%al
80102c03:	0f b6 c0             	movzbl %al,%eax
80102c06:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102c09:	74 0c                	je     80102c17 <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102c0b:	c7 04 24 50 92 10 80 	movl   $0x80109250,(%esp)
80102c12:	e8 aa d7 ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c17:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102c1e:	eb 3d                	jmp    80102c5d <ioapicinit+0x98>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102c20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c23:	83 c0 20             	add    $0x20,%eax
80102c26:	0d 00 00 01 00       	or     $0x10000,%eax
80102c2b:	89 c2                	mov    %eax,%edx
80102c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c30:	83 c0 08             	add    $0x8,%eax
80102c33:	01 c0                	add    %eax,%eax
80102c35:	89 54 24 04          	mov    %edx,0x4(%esp)
80102c39:	89 04 24             	mov    %eax,(%esp)
80102c3c:	e8 6a ff ff ff       	call   80102bab <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c44:	83 c0 08             	add    $0x8,%eax
80102c47:	01 c0                	add    %eax,%eax
80102c49:	40                   	inc    %eax
80102c4a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102c51:	00 
80102c52:	89 04 24             	mov    %eax,(%esp)
80102c55:	e8 51 ff ff ff       	call   80102bab <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c5a:	ff 45 f4             	incl   -0xc(%ebp)
80102c5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c60:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102c63:	7e bb                	jle    80102c20 <ioapicinit+0x5b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102c65:	c9                   	leave  
80102c66:	c3                   	ret    

80102c67 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102c67:	55                   	push   %ebp
80102c68:	89 e5                	mov    %esp,%ebp
80102c6a:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102c6d:	8b 45 08             	mov    0x8(%ebp),%eax
80102c70:	83 c0 20             	add    $0x20,%eax
80102c73:	89 c2                	mov    %eax,%edx
80102c75:	8b 45 08             	mov    0x8(%ebp),%eax
80102c78:	83 c0 08             	add    $0x8,%eax
80102c7b:	01 c0                	add    %eax,%eax
80102c7d:	89 54 24 04          	mov    %edx,0x4(%esp)
80102c81:	89 04 24             	mov    %eax,(%esp)
80102c84:	e8 22 ff ff ff       	call   80102bab <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102c89:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c8c:	c1 e0 18             	shl    $0x18,%eax
80102c8f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c92:	83 c2 08             	add    $0x8,%edx
80102c95:	01 d2                	add    %edx,%edx
80102c97:	42                   	inc    %edx
80102c98:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c9c:	89 14 24             	mov    %edx,(%esp)
80102c9f:	e8 07 ff ff ff       	call   80102bab <ioapicwrite>
}
80102ca4:	c9                   	leave  
80102ca5:	c3                   	ret    
	...

80102ca8 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102ca8:	55                   	push   %ebp
80102ca9:	89 e5                	mov    %esp,%ebp
80102cab:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102cae:	c7 44 24 04 82 92 10 	movl   $0x80109282,0x4(%esp)
80102cb5:	80 
80102cb6:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102cbd:	e8 5c 2a 00 00       	call   8010571e <initlock>
  kmem.use_lock = 0;
80102cc2:	c7 05 54 48 11 80 00 	movl   $0x0,0x80114854
80102cc9:	00 00 00 
  freerange(vstart, vend);
80102ccc:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ccf:	89 44 24 04          	mov    %eax,0x4(%esp)
80102cd3:	8b 45 08             	mov    0x8(%ebp),%eax
80102cd6:	89 04 24             	mov    %eax,(%esp)
80102cd9:	e8 26 00 00 00       	call   80102d04 <freerange>
}
80102cde:	c9                   	leave  
80102cdf:	c3                   	ret    

80102ce0 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102ce0:	55                   	push   %ebp
80102ce1:	89 e5                	mov    %esp,%ebp
80102ce3:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102ce6:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ced:	8b 45 08             	mov    0x8(%ebp),%eax
80102cf0:	89 04 24             	mov    %eax,(%esp)
80102cf3:	e8 0c 00 00 00       	call   80102d04 <freerange>
  kmem.use_lock = 1;
80102cf8:	c7 05 54 48 11 80 01 	movl   $0x1,0x80114854
80102cff:	00 00 00 
}
80102d02:	c9                   	leave  
80102d03:	c3                   	ret    

80102d04 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102d04:	55                   	push   %ebp
80102d05:	89 e5                	mov    %esp,%ebp
80102d07:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102d0a:	8b 45 08             	mov    0x8(%ebp),%eax
80102d0d:	05 ff 0f 00 00       	add    $0xfff,%eax
80102d12:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102d17:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d1a:	eb 12                	jmp    80102d2e <freerange+0x2a>
    kfree(p);
80102d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d1f:	89 04 24             	mov    %eax,(%esp)
80102d22:	e8 16 00 00 00       	call   80102d3d <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102d27:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d31:	05 00 10 00 00       	add    $0x1000,%eax
80102d36:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102d39:	76 e1                	jbe    80102d1c <freerange+0x18>
    kfree(p);
}
80102d3b:	c9                   	leave  
80102d3c:	c3                   	ret    

80102d3d <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102d3d:	55                   	push   %ebp
80102d3e:	89 e5                	mov    %esp,%ebp
80102d40:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102d43:	8b 45 08             	mov    0x8(%ebp),%eax
80102d46:	25 ff 0f 00 00       	and    $0xfff,%eax
80102d4b:	85 c0                	test   %eax,%eax
80102d4d:	75 18                	jne    80102d67 <kfree+0x2a>
80102d4f:	81 7d 08 48 61 12 80 	cmpl   $0x80126148,0x8(%ebp)
80102d56:	72 0f                	jb     80102d67 <kfree+0x2a>
80102d58:	8b 45 08             	mov    0x8(%ebp),%eax
80102d5b:	05 00 00 00 80       	add    $0x80000000,%eax
80102d60:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102d65:	76 0c                	jbe    80102d73 <kfree+0x36>
    panic("kfree");
80102d67:	c7 04 24 87 92 10 80 	movl   $0x80109287,(%esp)
80102d6e:	e8 e1 d7 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102d73:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102d7a:	00 
80102d7b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102d82:	00 
80102d83:	8b 45 08             	mov    0x8(%ebp),%eax
80102d86:	89 04 24             	mov    %eax,(%esp)
80102d89:	e8 14 2c 00 00       	call   801059a2 <memset>

  if(kmem.use_lock)
80102d8e:	a1 54 48 11 80       	mov    0x80114854,%eax
80102d93:	85 c0                	test   %eax,%eax
80102d95:	74 0c                	je     80102da3 <kfree+0x66>
    acquire(&kmem.lock);
80102d97:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102d9e:	e8 9c 29 00 00       	call   8010573f <acquire>
  r = (struct run*)v;
80102da3:	8b 45 08             	mov    0x8(%ebp),%eax
80102da6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102da9:	8b 15 58 48 11 80    	mov    0x80114858,%edx
80102daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102db2:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102db4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102db7:	a3 58 48 11 80       	mov    %eax,0x80114858
  if(kmem.use_lock)
80102dbc:	a1 54 48 11 80       	mov    0x80114854,%eax
80102dc1:	85 c0                	test   %eax,%eax
80102dc3:	74 0c                	je     80102dd1 <kfree+0x94>
    release(&kmem.lock);
80102dc5:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102dcc:	e8 d8 29 00 00       	call   801057a9 <release>
}
80102dd1:	c9                   	leave  
80102dd2:	c3                   	ret    

80102dd3 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102dd3:	55                   	push   %ebp
80102dd4:	89 e5                	mov    %esp,%ebp
80102dd6:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102dd9:	a1 54 48 11 80       	mov    0x80114854,%eax
80102dde:	85 c0                	test   %eax,%eax
80102de0:	74 0c                	je     80102dee <kalloc+0x1b>
    acquire(&kmem.lock);
80102de2:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102de9:	e8 51 29 00 00       	call   8010573f <acquire>
  r = kmem.freelist;
80102dee:	a1 58 48 11 80       	mov    0x80114858,%eax
80102df3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102df6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102dfa:	74 0a                	je     80102e06 <kalloc+0x33>
    kmem.freelist = r->next;
80102dfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102dff:	8b 00                	mov    (%eax),%eax
80102e01:	a3 58 48 11 80       	mov    %eax,0x80114858
  if(kmem.use_lock)
80102e06:	a1 54 48 11 80       	mov    0x80114854,%eax
80102e0b:	85 c0                	test   %eax,%eax
80102e0d:	74 0c                	je     80102e1b <kalloc+0x48>
    release(&kmem.lock);
80102e0f:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102e16:	e8 8e 29 00 00       	call   801057a9 <release>
  return (char*)r;
80102e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102e1e:	c9                   	leave  
80102e1f:	c3                   	ret    

80102e20 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e20:	55                   	push   %ebp
80102e21:	89 e5                	mov    %esp,%ebp
80102e23:	83 ec 14             	sub    $0x14,%esp
80102e26:	8b 45 08             	mov    0x8(%ebp),%eax
80102e29:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e30:	89 c2                	mov    %eax,%edx
80102e32:	ec                   	in     (%dx),%al
80102e33:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e36:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102e39:	c9                   	leave  
80102e3a:	c3                   	ret    

80102e3b <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102e3b:	55                   	push   %ebp
80102e3c:	89 e5                	mov    %esp,%ebp
80102e3e:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102e41:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102e48:	e8 d3 ff ff ff       	call   80102e20 <inb>
80102e4d:	0f b6 c0             	movzbl %al,%eax
80102e50:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e56:	83 e0 01             	and    $0x1,%eax
80102e59:	85 c0                	test   %eax,%eax
80102e5b:	75 0a                	jne    80102e67 <kbdgetc+0x2c>
    return -1;
80102e5d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e62:	e9 21 01 00 00       	jmp    80102f88 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102e67:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102e6e:	e8 ad ff ff ff       	call   80102e20 <inb>
80102e73:	0f b6 c0             	movzbl %al,%eax
80102e76:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102e79:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102e80:	75 17                	jne    80102e99 <kbdgetc+0x5e>
    shift |= E0ESC;
80102e82:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102e87:	83 c8 40             	or     $0x40,%eax
80102e8a:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
    return 0;
80102e8f:	b8 00 00 00 00       	mov    $0x0,%eax
80102e94:	e9 ef 00 00 00       	jmp    80102f88 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102e99:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e9c:	25 80 00 00 00       	and    $0x80,%eax
80102ea1:	85 c0                	test   %eax,%eax
80102ea3:	74 44                	je     80102ee9 <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102ea5:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102eaa:	83 e0 40             	and    $0x40,%eax
80102ead:	85 c0                	test   %eax,%eax
80102eaf:	75 08                	jne    80102eb9 <kbdgetc+0x7e>
80102eb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102eb4:	83 e0 7f             	and    $0x7f,%eax
80102eb7:	eb 03                	jmp    80102ebc <kbdgetc+0x81>
80102eb9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ebc:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102ebf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ec2:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102ec7:	8a 00                	mov    (%eax),%al
80102ec9:	83 c8 40             	or     $0x40,%eax
80102ecc:	0f b6 c0             	movzbl %al,%eax
80102ecf:	f7 d0                	not    %eax
80102ed1:	89 c2                	mov    %eax,%edx
80102ed3:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102ed8:	21 d0                	and    %edx,%eax
80102eda:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
    return 0;
80102edf:	b8 00 00 00 00       	mov    $0x0,%eax
80102ee4:	e9 9f 00 00 00       	jmp    80102f88 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102ee9:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102eee:	83 e0 40             	and    $0x40,%eax
80102ef1:	85 c0                	test   %eax,%eax
80102ef3:	74 14                	je     80102f09 <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102ef5:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102efc:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102f01:	83 e0 bf             	and    $0xffffffbf,%eax
80102f04:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
  }

  shift |= shiftcode[data];
80102f09:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f0c:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102f11:	8a 00                	mov    (%eax),%al
80102f13:	0f b6 d0             	movzbl %al,%edx
80102f16:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102f1b:	09 d0                	or     %edx,%eax
80102f1d:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
  shift ^= togglecode[data];
80102f22:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f25:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102f2a:	8a 00                	mov    (%eax),%al
80102f2c:	0f b6 d0             	movzbl %al,%edx
80102f2f:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102f34:	31 d0                	xor    %edx,%eax
80102f36:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
  c = charcode[shift & (CTL | SHIFT)][data];
80102f3b:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102f40:	83 e0 03             	and    $0x3,%eax
80102f43:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102f4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f4d:	01 d0                	add    %edx,%eax
80102f4f:	8a 00                	mov    (%eax),%al
80102f51:	0f b6 c0             	movzbl %al,%eax
80102f54:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102f57:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102f5c:	83 e0 08             	and    $0x8,%eax
80102f5f:	85 c0                	test   %eax,%eax
80102f61:	74 22                	je     80102f85 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102f63:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102f67:	76 0c                	jbe    80102f75 <kbdgetc+0x13a>
80102f69:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102f6d:	77 06                	ja     80102f75 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102f6f:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102f73:	eb 10                	jmp    80102f85 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102f75:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102f79:	76 0a                	jbe    80102f85 <kbdgetc+0x14a>
80102f7b:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102f7f:	77 04                	ja     80102f85 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102f81:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102f85:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102f88:	c9                   	leave  
80102f89:	c3                   	ret    

80102f8a <kbdintr>:

void
kbdintr(void)
{
80102f8a:	55                   	push   %ebp
80102f8b:	89 e5                	mov    %esp,%ebp
80102f8d:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102f90:	c7 04 24 3b 2e 10 80 	movl   $0x80102e3b,(%esp)
80102f97:	e8 59 d8 ff ff       	call   801007f5 <consoleintr>
}
80102f9c:	c9                   	leave  
80102f9d:	c3                   	ret    
	...

80102fa0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102fa0:	55                   	push   %ebp
80102fa1:	89 e5                	mov    %esp,%ebp
80102fa3:	83 ec 14             	sub    $0x14,%esp
80102fa6:	8b 45 08             	mov    0x8(%ebp),%eax
80102fa9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102fad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fb0:	89 c2                	mov    %eax,%edx
80102fb2:	ec                   	in     (%dx),%al
80102fb3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102fb6:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102fb9:	c9                   	leave  
80102fba:	c3                   	ret    

80102fbb <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102fbb:	55                   	push   %ebp
80102fbc:	89 e5                	mov    %esp,%ebp
80102fbe:	83 ec 08             	sub    $0x8,%esp
80102fc1:	8b 45 08             	mov    0x8(%ebp),%eax
80102fc4:	8b 55 0c             	mov    0xc(%ebp),%edx
80102fc7:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102fcb:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102fce:	8a 45 f8             	mov    -0x8(%ebp),%al
80102fd1:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102fd4:	ee                   	out    %al,(%dx)
}
80102fd5:	c9                   	leave  
80102fd6:	c3                   	ret    

80102fd7 <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102fd7:	55                   	push   %ebp
80102fd8:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102fda:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80102fdf:	8b 55 08             	mov    0x8(%ebp),%edx
80102fe2:	c1 e2 02             	shl    $0x2,%edx
80102fe5:	01 c2                	add    %eax,%edx
80102fe7:	8b 45 0c             	mov    0xc(%ebp),%eax
80102fea:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102fec:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80102ff1:	83 c0 20             	add    $0x20,%eax
80102ff4:	8b 00                	mov    (%eax),%eax
}
80102ff6:	5d                   	pop    %ebp
80102ff7:	c3                   	ret    

80102ff8 <lapicinit>:

void
lapicinit(void)
{
80102ff8:	55                   	push   %ebp
80102ff9:	89 e5                	mov    %esp,%ebp
80102ffb:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80102ffe:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80103003:	85 c0                	test   %eax,%eax
80103005:	75 05                	jne    8010300c <lapicinit+0x14>
    return;
80103007:	e9 43 01 00 00       	jmp    8010314f <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
8010300c:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80103013:	00 
80103014:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
8010301b:	e8 b7 ff ff ff       	call   80102fd7 <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80103020:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80103027:	00 
80103028:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
8010302f:	e8 a3 ff ff ff       	call   80102fd7 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80103034:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
8010303b:	00 
8010303c:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103043:	e8 8f ff ff ff       	call   80102fd7 <lapicw>
  lapicw(TICR, 10000000);
80103048:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
8010304f:	00 
80103050:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
80103057:	e8 7b ff ff ff       	call   80102fd7 <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
8010305c:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103063:	00 
80103064:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
8010306b:	e8 67 ff ff ff       	call   80102fd7 <lapicw>
  lapicw(LINT1, MASKED);
80103070:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103077:	00 
80103078:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
8010307f:	e8 53 ff ff ff       	call   80102fd7 <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103084:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80103089:	83 c0 30             	add    $0x30,%eax
8010308c:	8b 00                	mov    (%eax),%eax
8010308e:	c1 e8 10             	shr    $0x10,%eax
80103091:	0f b6 c0             	movzbl %al,%eax
80103094:	83 f8 03             	cmp    $0x3,%eax
80103097:	76 14                	jbe    801030ad <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
80103099:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
801030a0:	00 
801030a1:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
801030a8:	e8 2a ff ff ff       	call   80102fd7 <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801030ad:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
801030b4:	00 
801030b5:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
801030bc:	e8 16 ff ff ff       	call   80102fd7 <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
801030c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030c8:	00 
801030c9:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801030d0:	e8 02 ff ff ff       	call   80102fd7 <lapicw>
  lapicw(ESR, 0);
801030d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030dc:	00 
801030dd:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
801030e4:	e8 ee fe ff ff       	call   80102fd7 <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
801030e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030f0:	00 
801030f1:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
801030f8:	e8 da fe ff ff       	call   80102fd7 <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
801030fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103104:	00 
80103105:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
8010310c:	e8 c6 fe ff ff       	call   80102fd7 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80103111:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
80103118:	00 
80103119:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103120:	e8 b2 fe ff ff       	call   80102fd7 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80103125:	90                   	nop
80103126:	a1 5c 48 11 80       	mov    0x8011485c,%eax
8010312b:	05 00 03 00 00       	add    $0x300,%eax
80103130:	8b 00                	mov    (%eax),%eax
80103132:	25 00 10 00 00       	and    $0x1000,%eax
80103137:	85 c0                	test   %eax,%eax
80103139:	75 eb                	jne    80103126 <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
8010313b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103142:	00 
80103143:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010314a:	e8 88 fe ff ff       	call   80102fd7 <lapicw>
}
8010314f:	c9                   	leave  
80103150:	c3                   	ret    

80103151 <lapicid>:

int
lapicid(void)
{
80103151:	55                   	push   %ebp
80103152:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80103154:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80103159:	85 c0                	test   %eax,%eax
8010315b:	75 07                	jne    80103164 <lapicid+0x13>
    return 0;
8010315d:	b8 00 00 00 00       	mov    $0x0,%eax
80103162:	eb 0d                	jmp    80103171 <lapicid+0x20>
  return lapic[ID] >> 24;
80103164:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80103169:	83 c0 20             	add    $0x20,%eax
8010316c:	8b 00                	mov    (%eax),%eax
8010316e:	c1 e8 18             	shr    $0x18,%eax
}
80103171:	5d                   	pop    %ebp
80103172:	c3                   	ret    

80103173 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103173:	55                   	push   %ebp
80103174:	89 e5                	mov    %esp,%ebp
80103176:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
80103179:	a1 5c 48 11 80       	mov    0x8011485c,%eax
8010317e:	85 c0                	test   %eax,%eax
80103180:	74 14                	je     80103196 <lapiceoi+0x23>
    lapicw(EOI, 0);
80103182:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103189:	00 
8010318a:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103191:	e8 41 fe ff ff       	call   80102fd7 <lapicw>
}
80103196:	c9                   	leave  
80103197:	c3                   	ret    

80103198 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103198:	55                   	push   %ebp
80103199:	89 e5                	mov    %esp,%ebp
}
8010319b:	5d                   	pop    %ebp
8010319c:	c3                   	ret    

8010319d <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010319d:	55                   	push   %ebp
8010319e:	89 e5                	mov    %esp,%ebp
801031a0:	83 ec 1c             	sub    $0x1c,%esp
801031a3:	8b 45 08             	mov    0x8(%ebp),%eax
801031a6:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
801031a9:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
801031b0:	00 
801031b1:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801031b8:	e8 fe fd ff ff       	call   80102fbb <outb>
  outb(CMOS_PORT+1, 0x0A);
801031bd:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
801031c4:	00 
801031c5:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801031cc:	e8 ea fd ff ff       	call   80102fbb <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
801031d1:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
801031d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801031db:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
801031e0:	8b 45 f8             	mov    -0x8(%ebp),%eax
801031e3:	8d 50 02             	lea    0x2(%eax),%edx
801031e6:	8b 45 0c             	mov    0xc(%ebp),%eax
801031e9:	c1 e8 04             	shr    $0x4,%eax
801031ec:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801031ef:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801031f3:	c1 e0 18             	shl    $0x18,%eax
801031f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801031fa:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103201:	e8 d1 fd ff ff       	call   80102fd7 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103206:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
8010320d:	00 
8010320e:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103215:	e8 bd fd ff ff       	call   80102fd7 <lapicw>
  microdelay(200);
8010321a:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103221:	e8 72 ff ff ff       	call   80103198 <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
80103226:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
8010322d:	00 
8010322e:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
80103235:	e8 9d fd ff ff       	call   80102fd7 <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010323a:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80103241:	e8 52 ff ff ff       	call   80103198 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103246:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010324d:	eb 3f                	jmp    8010328e <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
8010324f:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103253:	c1 e0 18             	shl    $0x18,%eax
80103256:	89 44 24 04          	mov    %eax,0x4(%esp)
8010325a:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103261:	e8 71 fd ff ff       	call   80102fd7 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80103266:	8b 45 0c             	mov    0xc(%ebp),%eax
80103269:	c1 e8 0c             	shr    $0xc,%eax
8010326c:	80 cc 06             	or     $0x6,%ah
8010326f:	89 44 24 04          	mov    %eax,0x4(%esp)
80103273:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010327a:	e8 58 fd ff ff       	call   80102fd7 <lapicw>
    microdelay(200);
8010327f:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80103286:	e8 0d ff ff ff       	call   80103198 <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010328b:	ff 45 fc             	incl   -0x4(%ebp)
8010328e:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103292:	7e bb                	jle    8010324f <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103294:	c9                   	leave  
80103295:	c3                   	ret    

80103296 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103296:	55                   	push   %ebp
80103297:	89 e5                	mov    %esp,%ebp
80103299:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
8010329c:	8b 45 08             	mov    0x8(%ebp),%eax
8010329f:	0f b6 c0             	movzbl %al,%eax
801032a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801032a6:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
801032ad:	e8 09 fd ff ff       	call   80102fbb <outb>
  microdelay(200);
801032b2:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801032b9:	e8 da fe ff ff       	call   80103198 <microdelay>

  return inb(CMOS_RETURN);
801032be:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
801032c5:	e8 d6 fc ff ff       	call   80102fa0 <inb>
801032ca:	0f b6 c0             	movzbl %al,%eax
}
801032cd:	c9                   	leave  
801032ce:	c3                   	ret    

801032cf <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801032cf:	55                   	push   %ebp
801032d0:	89 e5                	mov    %esp,%ebp
801032d2:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
801032d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801032dc:	e8 b5 ff ff ff       	call   80103296 <cmos_read>
801032e1:	8b 55 08             	mov    0x8(%ebp),%edx
801032e4:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
801032e6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801032ed:	e8 a4 ff ff ff       	call   80103296 <cmos_read>
801032f2:	8b 55 08             	mov    0x8(%ebp),%edx
801032f5:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801032f8:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801032ff:	e8 92 ff ff ff       	call   80103296 <cmos_read>
80103304:	8b 55 08             	mov    0x8(%ebp),%edx
80103307:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
8010330a:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
80103311:	e8 80 ff ff ff       	call   80103296 <cmos_read>
80103316:	8b 55 08             	mov    0x8(%ebp),%edx
80103319:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
8010331c:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80103323:	e8 6e ff ff ff       	call   80103296 <cmos_read>
80103328:	8b 55 08             	mov    0x8(%ebp),%edx
8010332b:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
8010332e:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
80103335:	e8 5c ff ff ff       	call   80103296 <cmos_read>
8010333a:	8b 55 08             	mov    0x8(%ebp),%edx
8010333d:	89 42 14             	mov    %eax,0x14(%edx)
}
80103340:	c9                   	leave  
80103341:	c3                   	ret    

80103342 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103342:	55                   	push   %ebp
80103343:	89 e5                	mov    %esp,%ebp
80103345:	57                   	push   %edi
80103346:	56                   	push   %esi
80103347:	53                   	push   %ebx
80103348:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010334b:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
80103352:	e8 3f ff ff ff       	call   80103296 <cmos_read>
80103357:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010335a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010335d:	83 e0 04             	and    $0x4,%eax
80103360:	85 c0                	test   %eax,%eax
80103362:	0f 94 c0             	sete   %al
80103365:	0f b6 c0             	movzbl %al,%eax
80103368:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010336b:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010336e:	89 04 24             	mov    %eax,(%esp)
80103371:	e8 59 ff ff ff       	call   801032cf <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80103376:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
8010337d:	e8 14 ff ff ff       	call   80103296 <cmos_read>
80103382:	25 80 00 00 00       	and    $0x80,%eax
80103387:	85 c0                	test   %eax,%eax
80103389:	74 02                	je     8010338d <cmostime+0x4b>
        continue;
8010338b:	eb 36                	jmp    801033c3 <cmostime+0x81>
    fill_rtcdate(&t2);
8010338d:	8d 45 b0             	lea    -0x50(%ebp),%eax
80103390:	89 04 24             	mov    %eax,(%esp)
80103393:	e8 37 ff ff ff       	call   801032cf <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80103398:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
8010339f:	00 
801033a0:	8d 45 b0             	lea    -0x50(%ebp),%eax
801033a3:	89 44 24 04          	mov    %eax,0x4(%esp)
801033a7:	8d 45 c8             	lea    -0x38(%ebp),%eax
801033aa:	89 04 24             	mov    %eax,(%esp)
801033ad:	e8 67 26 00 00       	call   80105a19 <memcmp>
801033b2:	85 c0                	test   %eax,%eax
801033b4:	75 0d                	jne    801033c3 <cmostime+0x81>
      break;
801033b6:	90                   	nop
  }

  // convert
  if(bcd) {
801033b7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801033bb:	0f 84 ac 00 00 00    	je     8010346d <cmostime+0x12b>
801033c1:	eb 02                	jmp    801033c5 <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
801033c3:	eb a6                	jmp    8010336b <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801033c5:	8b 45 c8             	mov    -0x38(%ebp),%eax
801033c8:	c1 e8 04             	shr    $0x4,%eax
801033cb:	89 c2                	mov    %eax,%edx
801033cd:	89 d0                	mov    %edx,%eax
801033cf:	c1 e0 02             	shl    $0x2,%eax
801033d2:	01 d0                	add    %edx,%eax
801033d4:	01 c0                	add    %eax,%eax
801033d6:	8b 55 c8             	mov    -0x38(%ebp),%edx
801033d9:	83 e2 0f             	and    $0xf,%edx
801033dc:	01 d0                	add    %edx,%eax
801033de:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
801033e1:	8b 45 cc             	mov    -0x34(%ebp),%eax
801033e4:	c1 e8 04             	shr    $0x4,%eax
801033e7:	89 c2                	mov    %eax,%edx
801033e9:	89 d0                	mov    %edx,%eax
801033eb:	c1 e0 02             	shl    $0x2,%eax
801033ee:	01 d0                	add    %edx,%eax
801033f0:	01 c0                	add    %eax,%eax
801033f2:	8b 55 cc             	mov    -0x34(%ebp),%edx
801033f5:	83 e2 0f             	and    $0xf,%edx
801033f8:	01 d0                	add    %edx,%eax
801033fa:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
801033fd:	8b 45 d0             	mov    -0x30(%ebp),%eax
80103400:	c1 e8 04             	shr    $0x4,%eax
80103403:	89 c2                	mov    %eax,%edx
80103405:	89 d0                	mov    %edx,%eax
80103407:	c1 e0 02             	shl    $0x2,%eax
8010340a:	01 d0                	add    %edx,%eax
8010340c:	01 c0                	add    %eax,%eax
8010340e:	8b 55 d0             	mov    -0x30(%ebp),%edx
80103411:	83 e2 0f             	and    $0xf,%edx
80103414:	01 d0                	add    %edx,%eax
80103416:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
80103419:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010341c:	c1 e8 04             	shr    $0x4,%eax
8010341f:	89 c2                	mov    %eax,%edx
80103421:	89 d0                	mov    %edx,%eax
80103423:	c1 e0 02             	shl    $0x2,%eax
80103426:	01 d0                	add    %edx,%eax
80103428:	01 c0                	add    %eax,%eax
8010342a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010342d:	83 e2 0f             	and    $0xf,%edx
80103430:	01 d0                	add    %edx,%eax
80103432:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
80103435:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103438:	c1 e8 04             	shr    $0x4,%eax
8010343b:	89 c2                	mov    %eax,%edx
8010343d:	89 d0                	mov    %edx,%eax
8010343f:	c1 e0 02             	shl    $0x2,%eax
80103442:	01 d0                	add    %edx,%eax
80103444:	01 c0                	add    %eax,%eax
80103446:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103449:	83 e2 0f             	and    $0xf,%edx
8010344c:	01 d0                	add    %edx,%eax
8010344e:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
80103451:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103454:	c1 e8 04             	shr    $0x4,%eax
80103457:	89 c2                	mov    %eax,%edx
80103459:	89 d0                	mov    %edx,%eax
8010345b:	c1 e0 02             	shl    $0x2,%eax
8010345e:	01 d0                	add    %edx,%eax
80103460:	01 c0                	add    %eax,%eax
80103462:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103465:	83 e2 0f             	and    $0xf,%edx
80103468:	01 d0                	add    %edx,%eax
8010346a:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
8010346d:	8b 45 08             	mov    0x8(%ebp),%eax
80103470:	89 c2                	mov    %eax,%edx
80103472:	8d 5d c8             	lea    -0x38(%ebp),%ebx
80103475:	b8 06 00 00 00       	mov    $0x6,%eax
8010347a:	89 d7                	mov    %edx,%edi
8010347c:	89 de                	mov    %ebx,%esi
8010347e:	89 c1                	mov    %eax,%ecx
80103480:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
80103482:	8b 45 08             	mov    0x8(%ebp),%eax
80103485:	8b 40 14             	mov    0x14(%eax),%eax
80103488:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010348e:	8b 45 08             	mov    0x8(%ebp),%eax
80103491:	89 50 14             	mov    %edx,0x14(%eax)
}
80103494:	83 c4 5c             	add    $0x5c,%esp
80103497:	5b                   	pop    %ebx
80103498:	5e                   	pop    %esi
80103499:	5f                   	pop    %edi
8010349a:	5d                   	pop    %ebp
8010349b:	c3                   	ret    

8010349c <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
8010349c:	55                   	push   %ebp
8010349d:	89 e5                	mov    %esp,%ebp
8010349f:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
801034a2:	c7 44 24 04 8d 92 10 	movl   $0x8010928d,0x4(%esp)
801034a9:	80 
801034aa:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801034b1:	e8 68 22 00 00       	call   8010571e <initlock>
  readsb(dev, &sb);
801034b6:	8d 45 dc             	lea    -0x24(%ebp),%eax
801034b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801034bd:	8b 45 08             	mov    0x8(%ebp),%eax
801034c0:	89 04 24             	mov    %eax,(%esp)
801034c3:	e8 5c df ff ff       	call   80101424 <readsb>
  log.start = sb.logstart;
801034c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034cb:	a3 94 48 11 80       	mov    %eax,0x80114894
  log.size = sb.nlog;
801034d0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801034d3:	a3 98 48 11 80       	mov    %eax,0x80114898
  log.dev = dev;
801034d8:	8b 45 08             	mov    0x8(%ebp),%eax
801034db:	a3 a4 48 11 80       	mov    %eax,0x801148a4
  recover_from_log();
801034e0:	e8 95 01 00 00       	call   8010367a <recover_from_log>
}
801034e5:	c9                   	leave  
801034e6:	c3                   	ret    

801034e7 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
801034e7:	55                   	push   %ebp
801034e8:	89 e5                	mov    %esp,%ebp
801034ea:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801034ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034f4:	e9 89 00 00 00       	jmp    80103582 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801034f9:	8b 15 94 48 11 80    	mov    0x80114894,%edx
801034ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103502:	01 d0                	add    %edx,%eax
80103504:	40                   	inc    %eax
80103505:	89 c2                	mov    %eax,%edx
80103507:	a1 a4 48 11 80       	mov    0x801148a4,%eax
8010350c:	89 54 24 04          	mov    %edx,0x4(%esp)
80103510:	89 04 24             	mov    %eax,(%esp)
80103513:	e8 9d cc ff ff       	call   801001b5 <bread>
80103518:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010351b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010351e:	83 c0 10             	add    $0x10,%eax
80103521:	8b 04 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%eax
80103528:	89 c2                	mov    %eax,%edx
8010352a:	a1 a4 48 11 80       	mov    0x801148a4,%eax
8010352f:	89 54 24 04          	mov    %edx,0x4(%esp)
80103533:	89 04 24             	mov    %eax,(%esp)
80103536:	e8 7a cc ff ff       	call   801001b5 <bread>
8010353b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010353e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103541:	8d 50 5c             	lea    0x5c(%eax),%edx
80103544:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103547:	83 c0 5c             	add    $0x5c,%eax
8010354a:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103551:	00 
80103552:	89 54 24 04          	mov    %edx,0x4(%esp)
80103556:	89 04 24             	mov    %eax,(%esp)
80103559:	e8 0d 25 00 00       	call   80105a6b <memmove>
    bwrite(dbuf);  // write dst to disk
8010355e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103561:	89 04 24             	mov    %eax,(%esp)
80103564:	e8 83 cc ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
80103569:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010356c:	89 04 24             	mov    %eax,(%esp)
8010356f:	e8 b8 cc ff ff       	call   8010022c <brelse>
    brelse(dbuf);
80103574:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103577:	89 04 24             	mov    %eax,(%esp)
8010357a:	e8 ad cc ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010357f:	ff 45 f4             	incl   -0xc(%ebp)
80103582:	a1 a8 48 11 80       	mov    0x801148a8,%eax
80103587:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010358a:	0f 8f 69 ff ff ff    	jg     801034f9 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
80103590:	c9                   	leave  
80103591:	c3                   	ret    

80103592 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103592:	55                   	push   %ebp
80103593:	89 e5                	mov    %esp,%ebp
80103595:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103598:	a1 94 48 11 80       	mov    0x80114894,%eax
8010359d:	89 c2                	mov    %eax,%edx
8010359f:	a1 a4 48 11 80       	mov    0x801148a4,%eax
801035a4:	89 54 24 04          	mov    %edx,0x4(%esp)
801035a8:	89 04 24             	mov    %eax,(%esp)
801035ab:	e8 05 cc ff ff       	call   801001b5 <bread>
801035b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801035b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035b6:	83 c0 5c             	add    $0x5c,%eax
801035b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801035bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035bf:	8b 00                	mov    (%eax),%eax
801035c1:	a3 a8 48 11 80       	mov    %eax,0x801148a8
  for (i = 0; i < log.lh.n; i++) {
801035c6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035cd:	eb 1a                	jmp    801035e9 <read_head+0x57>
    log.lh.block[i] = lh->block[i];
801035cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801035d5:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801035d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801035dc:	83 c2 10             	add    $0x10,%edx
801035df:	89 04 95 6c 48 11 80 	mov    %eax,-0x7feeb794(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801035e6:	ff 45 f4             	incl   -0xc(%ebp)
801035e9:	a1 a8 48 11 80       	mov    0x801148a8,%eax
801035ee:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035f1:	7f dc                	jg     801035cf <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
801035f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035f6:	89 04 24             	mov    %eax,(%esp)
801035f9:	e8 2e cc ff ff       	call   8010022c <brelse>
}
801035fe:	c9                   	leave  
801035ff:	c3                   	ret    

80103600 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80103600:	55                   	push   %ebp
80103601:	89 e5                	mov    %esp,%ebp
80103603:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
80103606:	a1 94 48 11 80       	mov    0x80114894,%eax
8010360b:	89 c2                	mov    %eax,%edx
8010360d:	a1 a4 48 11 80       	mov    0x801148a4,%eax
80103612:	89 54 24 04          	mov    %edx,0x4(%esp)
80103616:	89 04 24             	mov    %eax,(%esp)
80103619:	e8 97 cb ff ff       	call   801001b5 <bread>
8010361e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103621:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103624:	83 c0 5c             	add    $0x5c,%eax
80103627:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010362a:	8b 15 a8 48 11 80    	mov    0x801148a8,%edx
80103630:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103633:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103635:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010363c:	eb 1a                	jmp    80103658 <write_head+0x58>
    hb->block[i] = log.lh.block[i];
8010363e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103641:	83 c0 10             	add    $0x10,%eax
80103644:	8b 0c 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%ecx
8010364b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010364e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103651:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103655:	ff 45 f4             	incl   -0xc(%ebp)
80103658:	a1 a8 48 11 80       	mov    0x801148a8,%eax
8010365d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103660:	7f dc                	jg     8010363e <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103662:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103665:	89 04 24             	mov    %eax,(%esp)
80103668:	e8 7f cb ff ff       	call   801001ec <bwrite>
  brelse(buf);
8010366d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103670:	89 04 24             	mov    %eax,(%esp)
80103673:	e8 b4 cb ff ff       	call   8010022c <brelse>
}
80103678:	c9                   	leave  
80103679:	c3                   	ret    

8010367a <recover_from_log>:

static void
recover_from_log(void)
{
8010367a:	55                   	push   %ebp
8010367b:	89 e5                	mov    %esp,%ebp
8010367d:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103680:	e8 0d ff ff ff       	call   80103592 <read_head>
  install_trans(); // if committed, copy from log to disk
80103685:	e8 5d fe ff ff       	call   801034e7 <install_trans>
  log.lh.n = 0;
8010368a:	c7 05 a8 48 11 80 00 	movl   $0x0,0x801148a8
80103691:	00 00 00 
  write_head(); // clear the log
80103694:	e8 67 ff ff ff       	call   80103600 <write_head>
}
80103699:	c9                   	leave  
8010369a:	c3                   	ret    

8010369b <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010369b:	55                   	push   %ebp
8010369c:	89 e5                	mov    %esp,%ebp
8010369e:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801036a1:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801036a8:	e8 92 20 00 00       	call   8010573f <acquire>
  while(1){
    if(log.committing){
801036ad:	a1 a0 48 11 80       	mov    0x801148a0,%eax
801036b2:	85 c0                	test   %eax,%eax
801036b4:	74 16                	je     801036cc <begin_op+0x31>
      sleep(&log, &log.lock);
801036b6:	c7 44 24 04 60 48 11 	movl   $0x80114860,0x4(%esp)
801036bd:	80 
801036be:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801036c5:	e8 14 13 00 00       	call   801049de <sleep>
801036ca:	eb 4d                	jmp    80103719 <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801036cc:	8b 15 a8 48 11 80    	mov    0x801148a8,%edx
801036d2:	a1 9c 48 11 80       	mov    0x8011489c,%eax
801036d7:	8d 48 01             	lea    0x1(%eax),%ecx
801036da:	89 c8                	mov    %ecx,%eax
801036dc:	c1 e0 02             	shl    $0x2,%eax
801036df:	01 c8                	add    %ecx,%eax
801036e1:	01 c0                	add    %eax,%eax
801036e3:	01 d0                	add    %edx,%eax
801036e5:	83 f8 1e             	cmp    $0x1e,%eax
801036e8:	7e 16                	jle    80103700 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801036ea:	c7 44 24 04 60 48 11 	movl   $0x80114860,0x4(%esp)
801036f1:	80 
801036f2:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801036f9:	e8 e0 12 00 00       	call   801049de <sleep>
801036fe:	eb 19                	jmp    80103719 <begin_op+0x7e>
    } else {
      log.outstanding += 1;
80103700:	a1 9c 48 11 80       	mov    0x8011489c,%eax
80103705:	40                   	inc    %eax
80103706:	a3 9c 48 11 80       	mov    %eax,0x8011489c
      release(&log.lock);
8010370b:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103712:	e8 92 20 00 00       	call   801057a9 <release>
      break;
80103717:	eb 02                	jmp    8010371b <begin_op+0x80>
    }
  }
80103719:	eb 92                	jmp    801036ad <begin_op+0x12>
}
8010371b:	c9                   	leave  
8010371c:	c3                   	ret    

8010371d <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
8010371d:	55                   	push   %ebp
8010371e:	89 e5                	mov    %esp,%ebp
80103720:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
80103723:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010372a:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103731:	e8 09 20 00 00       	call   8010573f <acquire>
  log.outstanding -= 1;
80103736:	a1 9c 48 11 80       	mov    0x8011489c,%eax
8010373b:	48                   	dec    %eax
8010373c:	a3 9c 48 11 80       	mov    %eax,0x8011489c
  if(log.committing)
80103741:	a1 a0 48 11 80       	mov    0x801148a0,%eax
80103746:	85 c0                	test   %eax,%eax
80103748:	74 0c                	je     80103756 <end_op+0x39>
    panic("log.committing");
8010374a:	c7 04 24 91 92 10 80 	movl   $0x80109291,(%esp)
80103751:	e8 fe cd ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
80103756:	a1 9c 48 11 80       	mov    0x8011489c,%eax
8010375b:	85 c0                	test   %eax,%eax
8010375d:	75 13                	jne    80103772 <end_op+0x55>
    do_commit = 1;
8010375f:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103766:	c7 05 a0 48 11 80 01 	movl   $0x1,0x801148a0
8010376d:	00 00 00 
80103770:	eb 0c                	jmp    8010377e <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103772:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103779:	e8 4e 13 00 00       	call   80104acc <wakeup>
  }
  release(&log.lock);
8010377e:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103785:	e8 1f 20 00 00       	call   801057a9 <release>

  if(do_commit){
8010378a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010378e:	74 33                	je     801037c3 <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103790:	e8 db 00 00 00       	call   80103870 <commit>
    acquire(&log.lock);
80103795:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
8010379c:	e8 9e 1f 00 00       	call   8010573f <acquire>
    log.committing = 0;
801037a1:	c7 05 a0 48 11 80 00 	movl   $0x0,0x801148a0
801037a8:	00 00 00 
    wakeup(&log);
801037ab:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801037b2:	e8 15 13 00 00       	call   80104acc <wakeup>
    release(&log.lock);
801037b7:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801037be:	e8 e6 1f 00 00       	call   801057a9 <release>
  }
}
801037c3:	c9                   	leave  
801037c4:	c3                   	ret    

801037c5 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801037c5:	55                   	push   %ebp
801037c6:	89 e5                	mov    %esp,%ebp
801037c8:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801037cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037d2:	e9 89 00 00 00       	jmp    80103860 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801037d7:	8b 15 94 48 11 80    	mov    0x80114894,%edx
801037dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037e0:	01 d0                	add    %edx,%eax
801037e2:	40                   	inc    %eax
801037e3:	89 c2                	mov    %eax,%edx
801037e5:	a1 a4 48 11 80       	mov    0x801148a4,%eax
801037ea:	89 54 24 04          	mov    %edx,0x4(%esp)
801037ee:	89 04 24             	mov    %eax,(%esp)
801037f1:	e8 bf c9 ff ff       	call   801001b5 <bread>
801037f6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801037f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037fc:	83 c0 10             	add    $0x10,%eax
801037ff:	8b 04 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%eax
80103806:	89 c2                	mov    %eax,%edx
80103808:	a1 a4 48 11 80       	mov    0x801148a4,%eax
8010380d:	89 54 24 04          	mov    %edx,0x4(%esp)
80103811:	89 04 24             	mov    %eax,(%esp)
80103814:	e8 9c c9 ff ff       	call   801001b5 <bread>
80103819:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010381c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010381f:	8d 50 5c             	lea    0x5c(%eax),%edx
80103822:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103825:	83 c0 5c             	add    $0x5c,%eax
80103828:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
8010382f:	00 
80103830:	89 54 24 04          	mov    %edx,0x4(%esp)
80103834:	89 04 24             	mov    %eax,(%esp)
80103837:	e8 2f 22 00 00       	call   80105a6b <memmove>
    bwrite(to);  // write the log
8010383c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010383f:	89 04 24             	mov    %eax,(%esp)
80103842:	e8 a5 c9 ff ff       	call   801001ec <bwrite>
    brelse(from);
80103847:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010384a:	89 04 24             	mov    %eax,(%esp)
8010384d:	e8 da c9 ff ff       	call   8010022c <brelse>
    brelse(to);
80103852:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103855:	89 04 24             	mov    %eax,(%esp)
80103858:	e8 cf c9 ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010385d:	ff 45 f4             	incl   -0xc(%ebp)
80103860:	a1 a8 48 11 80       	mov    0x801148a8,%eax
80103865:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103868:	0f 8f 69 ff ff ff    	jg     801037d7 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
8010386e:	c9                   	leave  
8010386f:	c3                   	ret    

80103870 <commit>:

static void
commit()
{
80103870:	55                   	push   %ebp
80103871:	89 e5                	mov    %esp,%ebp
80103873:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103876:	a1 a8 48 11 80       	mov    0x801148a8,%eax
8010387b:	85 c0                	test   %eax,%eax
8010387d:	7e 1e                	jle    8010389d <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
8010387f:	e8 41 ff ff ff       	call   801037c5 <write_log>
    write_head();    // Write header to disk -- the real commit
80103884:	e8 77 fd ff ff       	call   80103600 <write_head>
    install_trans(); // Now install writes to home locations
80103889:	e8 59 fc ff ff       	call   801034e7 <install_trans>
    log.lh.n = 0;
8010388e:	c7 05 a8 48 11 80 00 	movl   $0x0,0x801148a8
80103895:	00 00 00 
    write_head();    // Erase the transaction from the log
80103898:	e8 63 fd ff ff       	call   80103600 <write_head>
  }
}
8010389d:	c9                   	leave  
8010389e:	c3                   	ret    

8010389f <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010389f:	55                   	push   %ebp
801038a0:	89 e5                	mov    %esp,%ebp
801038a2:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801038a5:	a1 a8 48 11 80       	mov    0x801148a8,%eax
801038aa:	83 f8 1d             	cmp    $0x1d,%eax
801038ad:	7f 10                	jg     801038bf <log_write+0x20>
801038af:	a1 a8 48 11 80       	mov    0x801148a8,%eax
801038b4:	8b 15 98 48 11 80    	mov    0x80114898,%edx
801038ba:	4a                   	dec    %edx
801038bb:	39 d0                	cmp    %edx,%eax
801038bd:	7c 0c                	jl     801038cb <log_write+0x2c>
    panic("too big a transaction");
801038bf:	c7 04 24 a0 92 10 80 	movl   $0x801092a0,(%esp)
801038c6:	e8 89 cc ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
801038cb:	a1 9c 48 11 80       	mov    0x8011489c,%eax
801038d0:	85 c0                	test   %eax,%eax
801038d2:	7f 0c                	jg     801038e0 <log_write+0x41>
    panic("log_write outside of trans");
801038d4:	c7 04 24 b6 92 10 80 	movl   $0x801092b6,(%esp)
801038db:	e8 74 cc ff ff       	call   80100554 <panic>

  acquire(&log.lock);
801038e0:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801038e7:	e8 53 1e 00 00       	call   8010573f <acquire>
  for (i = 0; i < log.lh.n; i++) {
801038ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038f3:	eb 1e                	jmp    80103913 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801038f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038f8:	83 c0 10             	add    $0x10,%eax
801038fb:	8b 04 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%eax
80103902:	89 c2                	mov    %eax,%edx
80103904:	8b 45 08             	mov    0x8(%ebp),%eax
80103907:	8b 40 08             	mov    0x8(%eax),%eax
8010390a:	39 c2                	cmp    %eax,%edx
8010390c:	75 02                	jne    80103910 <log_write+0x71>
      break;
8010390e:	eb 0d                	jmp    8010391d <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103910:	ff 45 f4             	incl   -0xc(%ebp)
80103913:	a1 a8 48 11 80       	mov    0x801148a8,%eax
80103918:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010391b:	7f d8                	jg     801038f5 <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
8010391d:	8b 45 08             	mov    0x8(%ebp),%eax
80103920:	8b 40 08             	mov    0x8(%eax),%eax
80103923:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103926:	83 c2 10             	add    $0x10,%edx
80103929:	89 04 95 6c 48 11 80 	mov    %eax,-0x7feeb794(,%edx,4)
  if (i == log.lh.n)
80103930:	a1 a8 48 11 80       	mov    0x801148a8,%eax
80103935:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103938:	75 0b                	jne    80103945 <log_write+0xa6>
    log.lh.n++;
8010393a:	a1 a8 48 11 80       	mov    0x801148a8,%eax
8010393f:	40                   	inc    %eax
80103940:	a3 a8 48 11 80       	mov    %eax,0x801148a8
  b->flags |= B_DIRTY; // prevent eviction
80103945:	8b 45 08             	mov    0x8(%ebp),%eax
80103948:	8b 00                	mov    (%eax),%eax
8010394a:	83 c8 04             	or     $0x4,%eax
8010394d:	89 c2                	mov    %eax,%edx
8010394f:	8b 45 08             	mov    0x8(%ebp),%eax
80103952:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103954:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
8010395b:	e8 49 1e 00 00       	call   801057a9 <release>
}
80103960:	c9                   	leave  
80103961:	c3                   	ret    
	...

80103964 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103964:	55                   	push   %ebp
80103965:	89 e5                	mov    %esp,%ebp
80103967:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010396a:	8b 55 08             	mov    0x8(%ebp),%edx
8010396d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103970:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103973:	f0 87 02             	lock xchg %eax,(%edx)
80103976:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103979:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010397c:	c9                   	leave  
8010397d:	c3                   	ret    

8010397e <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
8010397e:	55                   	push   %ebp
8010397f:	89 e5                	mov    %esp,%ebp
80103981:	83 e4 f0             	and    $0xfffffff0,%esp
80103984:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103987:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
8010398e:	80 
8010398f:	c7 04 24 48 61 12 80 	movl   $0x80126148,(%esp)
80103996:	e8 0d f3 ff ff       	call   80102ca8 <kinit1>
  kvmalloc();      // kernel page table
8010399b:	e8 a7 4d 00 00       	call   80108747 <kvmalloc>
  mpinit();        // detect other processors
801039a0:	e8 c4 03 00 00       	call   80103d69 <mpinit>
  lapicinit();     // interrupt controller
801039a5:	e8 4e f6 ff ff       	call   80102ff8 <lapicinit>
  seginit();       // segment descriptors
801039aa:	e8 80 48 00 00       	call   8010822f <seginit>
  picinit();       // disable pic
801039af:	e8 04 05 00 00       	call   80103eb8 <picinit>
  ioapicinit();    // another interrupt controller
801039b4:	e8 0c f2 ff ff       	call   80102bc5 <ioapicinit>
  consoleinit();   // console hardware
801039b9:	e8 f9 d1 ff ff       	call   80100bb7 <consoleinit>
  uartinit();      // serial port
801039be:	e8 f8 3b 00 00       	call   801075bb <uartinit>
  cinit();         // container table
801039c3:	e8 df 13 00 00       	call   80104da7 <cinit>
  tvinit();        // trap vectors
801039c8:	e8 bb 37 00 00       	call   80107188 <tvinit>
  binit();         // buffer cache
801039cd:	e8 62 c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801039d2:	e8 71 d6 ff ff       	call   80101048 <fileinit>
  ideinit();       // disk 
801039d7:	e8 f5 ed ff ff       	call   801027d1 <ideinit>
  startothers();   // start other processors
801039dc:	e8 83 00 00 00       	call   80103a64 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801039e1:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
801039e8:	8e 
801039e9:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801039f0:	e8 eb f2 ff ff       	call   80102ce0 <kinit2>
  userinit();      // first user process
801039f5:	e8 ec 14 00 00       	call   80104ee6 <userinit>
  mpmain();        // finish this processor's setup
801039fa:	e8 1a 00 00 00       	call   80103a19 <mpmain>

801039ff <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801039ff:	55                   	push   %ebp
80103a00:	89 e5                	mov    %esp,%ebp
80103a02:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103a05:	e8 54 4d 00 00       	call   8010875e <switchkvm>
  seginit();
80103a0a:	e8 20 48 00 00       	call   8010822f <seginit>
  lapicinit();
80103a0f:	e8 e4 f5 ff ff       	call   80102ff8 <lapicinit>
  mpmain();
80103a14:	e8 00 00 00 00       	call   80103a19 <mpmain>

80103a19 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103a19:	55                   	push   %ebp
80103a1a:	89 e5                	mov    %esp,%ebp
80103a1c:	53                   	push   %ebx
80103a1d:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103a20:	e8 b9 12 00 00       	call   80104cde <cpuid>
80103a25:	89 c3                	mov    %eax,%ebx
80103a27:	e8 b2 12 00 00       	call   80104cde <cpuid>
80103a2c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80103a30:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a34:	c7 04 24 d1 92 10 80 	movl   $0x801092d1,(%esp)
80103a3b:	e8 81 c9 ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
80103a40:	e8 a0 38 00 00       	call   801072e5 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103a45:	e8 d9 12 00 00       	call   80104d23 <mycpu>
80103a4a:	05 a0 00 00 00       	add    $0xa0,%eax
80103a4f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103a56:	00 
80103a57:	89 04 24             	mov    %eax,(%esp)
80103a5a:	e8 05 ff ff ff       	call   80103964 <xchg>
  scheduler();     // start running processes
80103a5f:	e8 60 16 00 00       	call   801050c4 <scheduler>

80103a64 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103a64:	55                   	push   %ebp
80103a65:	89 e5                	mov    %esp,%ebp
80103a67:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103a6a:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103a71:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103a76:	89 44 24 08          	mov    %eax,0x8(%esp)
80103a7a:	c7 44 24 04 2c c5 10 	movl   $0x8010c52c,0x4(%esp)
80103a81:	80 
80103a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a85:	89 04 24             	mov    %eax,(%esp)
80103a88:	e8 de 1f 00 00       	call   80105a6b <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103a8d:	c7 45 f4 60 49 11 80 	movl   $0x80114960,-0xc(%ebp)
80103a94:	eb 75                	jmp    80103b0b <startothers+0xa7>
    if(c == mycpu())  // We've started already.
80103a96:	e8 88 12 00 00       	call   80104d23 <mycpu>
80103a9b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a9e:	75 02                	jne    80103aa2 <startothers+0x3e>
      continue;
80103aa0:	eb 62                	jmp    80103b04 <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103aa2:	e8 2c f3 ff ff       	call   80102dd3 <kalloc>
80103aa7:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aad:	83 e8 04             	sub    $0x4,%eax
80103ab0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103ab3:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103ab9:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103abb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103abe:	83 e8 08             	sub    $0x8,%eax
80103ac1:	c7 00 ff 39 10 80    	movl   $0x801039ff,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103ac7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aca:	8d 50 f4             	lea    -0xc(%eax),%edx
80103acd:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103ad2:	05 00 00 00 80       	add    $0x80000000,%eax
80103ad7:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
80103ad9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103adc:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103ae2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ae5:	8a 00                	mov    (%eax),%al
80103ae7:	0f b6 c0             	movzbl %al,%eax
80103aea:	89 54 24 04          	mov    %edx,0x4(%esp)
80103aee:	89 04 24             	mov    %eax,(%esp)
80103af1:	e8 a7 f6 ff ff       	call   8010319d <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103af6:	90                   	nop
80103af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afa:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103b00:	85 c0                	test   %eax,%eax
80103b02:	74 f3                	je     80103af7 <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103b04:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103b0b:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80103b10:	89 c2                	mov    %eax,%edx
80103b12:	89 d0                	mov    %edx,%eax
80103b14:	c1 e0 02             	shl    $0x2,%eax
80103b17:	01 d0                	add    %edx,%eax
80103b19:	01 c0                	add    %eax,%eax
80103b1b:	01 d0                	add    %edx,%eax
80103b1d:	c1 e0 04             	shl    $0x4,%eax
80103b20:	05 60 49 11 80       	add    $0x80114960,%eax
80103b25:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103b28:	0f 87 68 ff ff ff    	ja     80103a96 <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103b2e:	c9                   	leave  
80103b2f:	c3                   	ret    

80103b30 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103b30:	55                   	push   %ebp
80103b31:	89 e5                	mov    %esp,%ebp
80103b33:	83 ec 14             	sub    $0x14,%esp
80103b36:	8b 45 08             	mov    0x8(%ebp),%eax
80103b39:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103b3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b40:	89 c2                	mov    %eax,%edx
80103b42:	ec                   	in     (%dx),%al
80103b43:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103b46:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103b49:	c9                   	leave  
80103b4a:	c3                   	ret    

80103b4b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103b4b:	55                   	push   %ebp
80103b4c:	89 e5                	mov    %esp,%ebp
80103b4e:	83 ec 08             	sub    $0x8,%esp
80103b51:	8b 45 08             	mov    0x8(%ebp),%eax
80103b54:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b57:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103b5b:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103b5e:	8a 45 f8             	mov    -0x8(%ebp),%al
80103b61:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b64:	ee                   	out    %al,(%dx)
}
80103b65:	c9                   	leave  
80103b66:	c3                   	ret    

80103b67 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103b67:	55                   	push   %ebp
80103b68:	89 e5                	mov    %esp,%ebp
80103b6a:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103b6d:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b74:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b7b:	eb 13                	jmp    80103b90 <sum+0x29>
    sum += addr[i];
80103b7d:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b80:	8b 45 08             	mov    0x8(%ebp),%eax
80103b83:	01 d0                	add    %edx,%eax
80103b85:	8a 00                	mov    (%eax),%al
80103b87:	0f b6 c0             	movzbl %al,%eax
80103b8a:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103b8d:	ff 45 fc             	incl   -0x4(%ebp)
80103b90:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b93:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b96:	7c e5                	jl     80103b7d <sum+0x16>
    sum += addr[i];
  return sum;
80103b98:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b9b:	c9                   	leave  
80103b9c:	c3                   	ret    

80103b9d <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b9d:	55                   	push   %ebp
80103b9e:	89 e5                	mov    %esp,%ebp
80103ba0:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ba6:	05 00 00 00 80       	add    $0x80000000,%eax
80103bab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103bae:	8b 55 0c             	mov    0xc(%ebp),%edx
80103bb1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bb4:	01 d0                	add    %edx,%eax
80103bb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103bb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bbc:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bbf:	eb 3f                	jmp    80103c00 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103bc1:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103bc8:	00 
80103bc9:	c7 44 24 04 e8 92 10 	movl   $0x801092e8,0x4(%esp)
80103bd0:	80 
80103bd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd4:	89 04 24             	mov    %eax,(%esp)
80103bd7:	e8 3d 1e 00 00       	call   80105a19 <memcmp>
80103bdc:	85 c0                	test   %eax,%eax
80103bde:	75 1c                	jne    80103bfc <mpsearch1+0x5f>
80103be0:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103be7:	00 
80103be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103beb:	89 04 24             	mov    %eax,(%esp)
80103bee:	e8 74 ff ff ff       	call   80103b67 <sum>
80103bf3:	84 c0                	test   %al,%al
80103bf5:	75 05                	jne    80103bfc <mpsearch1+0x5f>
      return (struct mp*)p;
80103bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfa:	eb 11                	jmp    80103c0d <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103bfc:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103c00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c03:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103c06:	72 b9                	jb     80103bc1 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103c08:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103c0d:	c9                   	leave  
80103c0e:	c3                   	ret    

80103c0f <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103c0f:	55                   	push   %ebp
80103c10:	89 e5                	mov    %esp,%ebp
80103c12:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103c15:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103c1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1f:	83 c0 0f             	add    $0xf,%eax
80103c22:	8a 00                	mov    (%eax),%al
80103c24:	0f b6 c0             	movzbl %al,%eax
80103c27:	c1 e0 08             	shl    $0x8,%eax
80103c2a:	89 c2                	mov    %eax,%edx
80103c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2f:	83 c0 0e             	add    $0xe,%eax
80103c32:	8a 00                	mov    (%eax),%al
80103c34:	0f b6 c0             	movzbl %al,%eax
80103c37:	09 d0                	or     %edx,%eax
80103c39:	c1 e0 04             	shl    $0x4,%eax
80103c3c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c3f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c43:	74 21                	je     80103c66 <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103c45:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103c4c:	00 
80103c4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c50:	89 04 24             	mov    %eax,(%esp)
80103c53:	e8 45 ff ff ff       	call   80103b9d <mpsearch1>
80103c58:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c5b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c5f:	74 4e                	je     80103caf <mpsearch+0xa0>
      return mp;
80103c61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c64:	eb 5d                	jmp    80103cc3 <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c69:	83 c0 14             	add    $0x14,%eax
80103c6c:	8a 00                	mov    (%eax),%al
80103c6e:	0f b6 c0             	movzbl %al,%eax
80103c71:	c1 e0 08             	shl    $0x8,%eax
80103c74:	89 c2                	mov    %eax,%edx
80103c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c79:	83 c0 13             	add    $0x13,%eax
80103c7c:	8a 00                	mov    (%eax),%al
80103c7e:	0f b6 c0             	movzbl %al,%eax
80103c81:	09 d0                	or     %edx,%eax
80103c83:	c1 e0 0a             	shl    $0xa,%eax
80103c86:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c8c:	2d 00 04 00 00       	sub    $0x400,%eax
80103c91:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103c98:	00 
80103c99:	89 04 24             	mov    %eax,(%esp)
80103c9c:	e8 fc fe ff ff       	call   80103b9d <mpsearch1>
80103ca1:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ca4:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ca8:	74 05                	je     80103caf <mpsearch+0xa0>
      return mp;
80103caa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103cad:	eb 14                	jmp    80103cc3 <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103caf:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103cb6:	00 
80103cb7:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103cbe:	e8 da fe ff ff       	call   80103b9d <mpsearch1>
}
80103cc3:	c9                   	leave  
80103cc4:	c3                   	ret    

80103cc5 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103cc5:	55                   	push   %ebp
80103cc6:	89 e5                	mov    %esp,%ebp
80103cc8:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103ccb:	e8 3f ff ff ff       	call   80103c0f <mpsearch>
80103cd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cd3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cd7:	74 0a                	je     80103ce3 <mpconfig+0x1e>
80103cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cdc:	8b 40 04             	mov    0x4(%eax),%eax
80103cdf:	85 c0                	test   %eax,%eax
80103ce1:	75 07                	jne    80103cea <mpconfig+0x25>
    return 0;
80103ce3:	b8 00 00 00 00       	mov    $0x0,%eax
80103ce8:	eb 7d                	jmp    80103d67 <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ced:	8b 40 04             	mov    0x4(%eax),%eax
80103cf0:	05 00 00 00 80       	add    $0x80000000,%eax
80103cf5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103cf8:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103cff:	00 
80103d00:	c7 44 24 04 ed 92 10 	movl   $0x801092ed,0x4(%esp)
80103d07:	80 
80103d08:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d0b:	89 04 24             	mov    %eax,(%esp)
80103d0e:	e8 06 1d 00 00       	call   80105a19 <memcmp>
80103d13:	85 c0                	test   %eax,%eax
80103d15:	74 07                	je     80103d1e <mpconfig+0x59>
    return 0;
80103d17:	b8 00 00 00 00       	mov    $0x0,%eax
80103d1c:	eb 49                	jmp    80103d67 <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103d1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d21:	8a 40 06             	mov    0x6(%eax),%al
80103d24:	3c 01                	cmp    $0x1,%al
80103d26:	74 11                	je     80103d39 <mpconfig+0x74>
80103d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d2b:	8a 40 06             	mov    0x6(%eax),%al
80103d2e:	3c 04                	cmp    $0x4,%al
80103d30:	74 07                	je     80103d39 <mpconfig+0x74>
    return 0;
80103d32:	b8 00 00 00 00       	mov    $0x0,%eax
80103d37:	eb 2e                	jmp    80103d67 <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103d39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d3c:	8b 40 04             	mov    0x4(%eax),%eax
80103d3f:	0f b7 c0             	movzwl %ax,%eax
80103d42:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d49:	89 04 24             	mov    %eax,(%esp)
80103d4c:	e8 16 fe ff ff       	call   80103b67 <sum>
80103d51:	84 c0                	test   %al,%al
80103d53:	74 07                	je     80103d5c <mpconfig+0x97>
    return 0;
80103d55:	b8 00 00 00 00       	mov    $0x0,%eax
80103d5a:	eb 0b                	jmp    80103d67 <mpconfig+0xa2>
  *pmp = mp;
80103d5c:	8b 45 08             	mov    0x8(%ebp),%eax
80103d5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d62:	89 10                	mov    %edx,(%eax)
  return conf;
80103d64:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d67:	c9                   	leave  
80103d68:	c3                   	ret    

80103d69 <mpinit>:

void
mpinit(void)
{
80103d69:	55                   	push   %ebp
80103d6a:	89 e5                	mov    %esp,%ebp
80103d6c:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103d6f:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103d72:	89 04 24             	mov    %eax,(%esp)
80103d75:	e8 4b ff ff ff       	call   80103cc5 <mpconfig>
80103d7a:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d7d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d81:	75 0c                	jne    80103d8f <mpinit+0x26>
    panic("Expect to run on an SMP");
80103d83:	c7 04 24 f2 92 10 80 	movl   $0x801092f2,(%esp)
80103d8a:	e8 c5 c7 ff ff       	call   80100554 <panic>
  ismp = 1;
80103d8f:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103d96:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d99:	8b 40 24             	mov    0x24(%eax),%eax
80103d9c:	a3 5c 48 11 80       	mov    %eax,0x8011485c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103da1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103da4:	83 c0 2c             	add    $0x2c,%eax
80103da7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103daa:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103dad:	8b 40 04             	mov    0x4(%eax),%eax
80103db0:	0f b7 d0             	movzwl %ax,%edx
80103db3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103db6:	01 d0                	add    %edx,%eax
80103db8:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103dbb:	eb 7d                	jmp    80103e3a <mpinit+0xd1>
    switch(*p){
80103dbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc0:	8a 00                	mov    (%eax),%al
80103dc2:	0f b6 c0             	movzbl %al,%eax
80103dc5:	83 f8 04             	cmp    $0x4,%eax
80103dc8:	77 68                	ja     80103e32 <mpinit+0xc9>
80103dca:	8b 04 85 2c 93 10 80 	mov    -0x7fef6cd4(,%eax,4),%eax
80103dd1:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103dd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dd6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103dd9:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80103dde:	83 f8 07             	cmp    $0x7,%eax
80103de1:	7f 2c                	jg     80103e0f <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103de3:	8b 15 e0 4e 11 80    	mov    0x80114ee0,%edx
80103de9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103dec:	8a 48 01             	mov    0x1(%eax),%cl
80103def:	89 d0                	mov    %edx,%eax
80103df1:	c1 e0 02             	shl    $0x2,%eax
80103df4:	01 d0                	add    %edx,%eax
80103df6:	01 c0                	add    %eax,%eax
80103df8:	01 d0                	add    %edx,%eax
80103dfa:	c1 e0 04             	shl    $0x4,%eax
80103dfd:	05 60 49 11 80       	add    $0x80114960,%eax
80103e02:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103e04:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80103e09:	40                   	inc    %eax
80103e0a:	a3 e0 4e 11 80       	mov    %eax,0x80114ee0
      }
      p += sizeof(struct mpproc);
80103e0f:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103e13:	eb 25                	jmp    80103e3a <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e18:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103e1b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e1e:	8a 40 01             	mov    0x1(%eax),%al
80103e21:	a2 40 49 11 80       	mov    %al,0x80114940
      p += sizeof(struct mpioapic);
80103e26:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e2a:	eb 0e                	jmp    80103e3a <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e2c:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e30:	eb 08                	jmp    80103e3a <mpinit+0xd1>
    default:
      ismp = 0;
80103e32:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103e39:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e3d:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103e40:	0f 82 77 ff ff ff    	jb     80103dbd <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103e46:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103e4a:	75 0c                	jne    80103e58 <mpinit+0xef>
    panic("Didn't find a suitable machine");
80103e4c:	c7 04 24 0c 93 10 80 	movl   $0x8010930c,(%esp)
80103e53:	e8 fc c6 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80103e58:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e5b:	8a 40 0c             	mov    0xc(%eax),%al
80103e5e:	84 c0                	test   %al,%al
80103e60:	74 36                	je     80103e98 <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103e62:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103e69:	00 
80103e6a:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103e71:	e8 d5 fc ff ff       	call   80103b4b <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103e76:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103e7d:	e8 ae fc ff ff       	call   80103b30 <inb>
80103e82:	83 c8 01             	or     $0x1,%eax
80103e85:	0f b6 c0             	movzbl %al,%eax
80103e88:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e8c:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103e93:	e8 b3 fc ff ff       	call   80103b4b <outb>
  }
}
80103e98:	c9                   	leave  
80103e99:	c3                   	ret    
	...

80103e9c <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103e9c:	55                   	push   %ebp
80103e9d:	89 e5                	mov    %esp,%ebp
80103e9f:	83 ec 08             	sub    $0x8,%esp
80103ea2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea5:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ea8:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103eac:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103eaf:	8a 45 f8             	mov    -0x8(%ebp),%al
80103eb2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103eb5:	ee                   	out    %al,(%dx)
}
80103eb6:	c9                   	leave  
80103eb7:	c3                   	ret    

80103eb8 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103eb8:	55                   	push   %ebp
80103eb9:	89 e5                	mov    %esp,%ebp
80103ebb:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103ebe:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103ec5:	00 
80103ec6:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103ecd:	e8 ca ff ff ff       	call   80103e9c <outb>
  outb(IO_PIC2+1, 0xFF);
80103ed2:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103ed9:	00 
80103eda:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103ee1:	e8 b6 ff ff ff       	call   80103e9c <outb>
}
80103ee6:	c9                   	leave  
80103ee7:	c3                   	ret    

80103ee8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103ee8:	55                   	push   %ebp
80103ee9:	89 e5                	mov    %esp,%ebp
80103eeb:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103eee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103ef5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ef8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103efe:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f01:	8b 10                	mov    (%eax),%edx
80103f03:	8b 45 08             	mov    0x8(%ebp),%eax
80103f06:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103f08:	e8 57 d1 ff ff       	call   80101064 <filealloc>
80103f0d:	8b 55 08             	mov    0x8(%ebp),%edx
80103f10:	89 02                	mov    %eax,(%edx)
80103f12:	8b 45 08             	mov    0x8(%ebp),%eax
80103f15:	8b 00                	mov    (%eax),%eax
80103f17:	85 c0                	test   %eax,%eax
80103f19:	0f 84 c8 00 00 00    	je     80103fe7 <pipealloc+0xff>
80103f1f:	e8 40 d1 ff ff       	call   80101064 <filealloc>
80103f24:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f27:	89 02                	mov    %eax,(%edx)
80103f29:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f2c:	8b 00                	mov    (%eax),%eax
80103f2e:	85 c0                	test   %eax,%eax
80103f30:	0f 84 b1 00 00 00    	je     80103fe7 <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103f36:	e8 98 ee ff ff       	call   80102dd3 <kalloc>
80103f3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103f3e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f42:	75 05                	jne    80103f49 <pipealloc+0x61>
    goto bad;
80103f44:	e9 9e 00 00 00       	jmp    80103fe7 <pipealloc+0xff>
  p->readopen = 1;
80103f49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f4c:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103f53:	00 00 00 
  p->writeopen = 1;
80103f56:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f59:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103f60:	00 00 00 
  p->nwrite = 0;
80103f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f66:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103f6d:	00 00 00 
  p->nread = 0;
80103f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f73:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103f7a:	00 00 00 
  initlock(&p->lock, "pipe");
80103f7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f80:	c7 44 24 04 40 93 10 	movl   $0x80109340,0x4(%esp)
80103f87:	80 
80103f88:	89 04 24             	mov    %eax,(%esp)
80103f8b:	e8 8e 17 00 00       	call   8010571e <initlock>
  (*f0)->type = FD_PIPE;
80103f90:	8b 45 08             	mov    0x8(%ebp),%eax
80103f93:	8b 00                	mov    (%eax),%eax
80103f95:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103f9b:	8b 45 08             	mov    0x8(%ebp),%eax
80103f9e:	8b 00                	mov    (%eax),%eax
80103fa0:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103fa4:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa7:	8b 00                	mov    (%eax),%eax
80103fa9:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103fad:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb0:	8b 00                	mov    (%eax),%eax
80103fb2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fb5:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103fb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fbb:	8b 00                	mov    (%eax),%eax
80103fbd:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fc6:	8b 00                	mov    (%eax),%eax
80103fc8:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103fcc:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fcf:	8b 00                	mov    (%eax),%eax
80103fd1:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fd8:	8b 00                	mov    (%eax),%eax
80103fda:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103fdd:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103fe0:	b8 00 00 00 00       	mov    $0x0,%eax
80103fe5:	eb 42                	jmp    80104029 <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103fe7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103feb:	74 0b                	je     80103ff8 <pipealloc+0x110>
    kfree((char*)p);
80103fed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ff0:	89 04 24             	mov    %eax,(%esp)
80103ff3:	e8 45 ed ff ff       	call   80102d3d <kfree>
  if(*f0)
80103ff8:	8b 45 08             	mov    0x8(%ebp),%eax
80103ffb:	8b 00                	mov    (%eax),%eax
80103ffd:	85 c0                	test   %eax,%eax
80103fff:	74 0d                	je     8010400e <pipealloc+0x126>
    fileclose(*f0);
80104001:	8b 45 08             	mov    0x8(%ebp),%eax
80104004:	8b 00                	mov    (%eax),%eax
80104006:	89 04 24             	mov    %eax,(%esp)
80104009:	e8 fe d0 ff ff       	call   8010110c <fileclose>
  if(*f1)
8010400e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104011:	8b 00                	mov    (%eax),%eax
80104013:	85 c0                	test   %eax,%eax
80104015:	74 0d                	je     80104024 <pipealloc+0x13c>
    fileclose(*f1);
80104017:	8b 45 0c             	mov    0xc(%ebp),%eax
8010401a:	8b 00                	mov    (%eax),%eax
8010401c:	89 04 24             	mov    %eax,(%esp)
8010401f:	e8 e8 d0 ff ff       	call   8010110c <fileclose>
  return -1;
80104024:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104029:	c9                   	leave  
8010402a:	c3                   	ret    

8010402b <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
8010402b:	55                   	push   %ebp
8010402c:	89 e5                	mov    %esp,%ebp
8010402e:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80104031:	8b 45 08             	mov    0x8(%ebp),%eax
80104034:	89 04 24             	mov    %eax,(%esp)
80104037:	e8 03 17 00 00       	call   8010573f <acquire>
  if(writable){
8010403c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104040:	74 1f                	je     80104061 <pipeclose+0x36>
    p->writeopen = 0;
80104042:	8b 45 08             	mov    0x8(%ebp),%eax
80104045:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010404c:	00 00 00 
    wakeup(&p->nread);
8010404f:	8b 45 08             	mov    0x8(%ebp),%eax
80104052:	05 34 02 00 00       	add    $0x234,%eax
80104057:	89 04 24             	mov    %eax,(%esp)
8010405a:	e8 6d 0a 00 00       	call   80104acc <wakeup>
8010405f:	eb 1d                	jmp    8010407e <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104061:	8b 45 08             	mov    0x8(%ebp),%eax
80104064:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010406b:	00 00 00 
    wakeup(&p->nwrite);
8010406e:	8b 45 08             	mov    0x8(%ebp),%eax
80104071:	05 38 02 00 00       	add    $0x238,%eax
80104076:	89 04 24             	mov    %eax,(%esp)
80104079:	e8 4e 0a 00 00       	call   80104acc <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010407e:	8b 45 08             	mov    0x8(%ebp),%eax
80104081:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104087:	85 c0                	test   %eax,%eax
80104089:	75 25                	jne    801040b0 <pipeclose+0x85>
8010408b:	8b 45 08             	mov    0x8(%ebp),%eax
8010408e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104094:	85 c0                	test   %eax,%eax
80104096:	75 18                	jne    801040b0 <pipeclose+0x85>
    release(&p->lock);
80104098:	8b 45 08             	mov    0x8(%ebp),%eax
8010409b:	89 04 24             	mov    %eax,(%esp)
8010409e:	e8 06 17 00 00       	call   801057a9 <release>
    kfree((char*)p);
801040a3:	8b 45 08             	mov    0x8(%ebp),%eax
801040a6:	89 04 24             	mov    %eax,(%esp)
801040a9:	e8 8f ec ff ff       	call   80102d3d <kfree>
801040ae:	eb 0b                	jmp    801040bb <pipeclose+0x90>
  } else
    release(&p->lock);
801040b0:	8b 45 08             	mov    0x8(%ebp),%eax
801040b3:	89 04 24             	mov    %eax,(%esp)
801040b6:	e8 ee 16 00 00       	call   801057a9 <release>
}
801040bb:	c9                   	leave  
801040bc:	c3                   	ret    

801040bd <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801040bd:	55                   	push   %ebp
801040be:	89 e5                	mov    %esp,%ebp
801040c0:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
801040c3:	8b 45 08             	mov    0x8(%ebp),%eax
801040c6:	89 04 24             	mov    %eax,(%esp)
801040c9:	e8 71 16 00 00       	call   8010573f <acquire>
  for(i = 0; i < n; i++){
801040ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801040d5:	e9 a3 00 00 00       	jmp    8010417d <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801040da:	eb 56                	jmp    80104132 <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
801040dc:	8b 45 08             	mov    0x8(%ebp),%eax
801040df:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801040e5:	85 c0                	test   %eax,%eax
801040e7:	74 0c                	je     801040f5 <pipewrite+0x38>
801040e9:	e8 aa 01 00 00       	call   80104298 <myproc>
801040ee:	8b 40 24             	mov    0x24(%eax),%eax
801040f1:	85 c0                	test   %eax,%eax
801040f3:	74 15                	je     8010410a <pipewrite+0x4d>
        release(&p->lock);
801040f5:	8b 45 08             	mov    0x8(%ebp),%eax
801040f8:	89 04 24             	mov    %eax,(%esp)
801040fb:	e8 a9 16 00 00       	call   801057a9 <release>
        return -1;
80104100:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104105:	e9 9d 00 00 00       	jmp    801041a7 <pipewrite+0xea>
      }
      wakeup(&p->nread);
8010410a:	8b 45 08             	mov    0x8(%ebp),%eax
8010410d:	05 34 02 00 00       	add    $0x234,%eax
80104112:	89 04 24             	mov    %eax,(%esp)
80104115:	e8 b2 09 00 00       	call   80104acc <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010411a:	8b 45 08             	mov    0x8(%ebp),%eax
8010411d:	8b 55 08             	mov    0x8(%ebp),%edx
80104120:	81 c2 38 02 00 00    	add    $0x238,%edx
80104126:	89 44 24 04          	mov    %eax,0x4(%esp)
8010412a:	89 14 24             	mov    %edx,(%esp)
8010412d:	e8 ac 08 00 00       	call   801049de <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104132:	8b 45 08             	mov    0x8(%ebp),%eax
80104135:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
8010413b:	8b 45 08             	mov    0x8(%ebp),%eax
8010413e:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104144:	05 00 02 00 00       	add    $0x200,%eax
80104149:	39 c2                	cmp    %eax,%edx
8010414b:	74 8f                	je     801040dc <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010414d:	8b 45 08             	mov    0x8(%ebp),%eax
80104150:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104156:	8d 48 01             	lea    0x1(%eax),%ecx
80104159:	8b 55 08             	mov    0x8(%ebp),%edx
8010415c:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104162:	25 ff 01 00 00       	and    $0x1ff,%eax
80104167:	89 c1                	mov    %eax,%ecx
80104169:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010416c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010416f:	01 d0                	add    %edx,%eax
80104171:	8a 10                	mov    (%eax),%dl
80104173:	8b 45 08             	mov    0x8(%ebp),%eax
80104176:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010417a:	ff 45 f4             	incl   -0xc(%ebp)
8010417d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104180:	3b 45 10             	cmp    0x10(%ebp),%eax
80104183:	0f 8c 51 ff ff ff    	jl     801040da <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104189:	8b 45 08             	mov    0x8(%ebp),%eax
8010418c:	05 34 02 00 00       	add    $0x234,%eax
80104191:	89 04 24             	mov    %eax,(%esp)
80104194:	e8 33 09 00 00       	call   80104acc <wakeup>
  release(&p->lock);
80104199:	8b 45 08             	mov    0x8(%ebp),%eax
8010419c:	89 04 24             	mov    %eax,(%esp)
8010419f:	e8 05 16 00 00       	call   801057a9 <release>
  return n;
801041a4:	8b 45 10             	mov    0x10(%ebp),%eax
}
801041a7:	c9                   	leave  
801041a8:	c3                   	ret    

801041a9 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801041a9:	55                   	push   %ebp
801041aa:	89 e5                	mov    %esp,%ebp
801041ac:	53                   	push   %ebx
801041ad:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
801041b0:	8b 45 08             	mov    0x8(%ebp),%eax
801041b3:	89 04 24             	mov    %eax,(%esp)
801041b6:	e8 84 15 00 00       	call   8010573f <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801041bb:	eb 39                	jmp    801041f6 <piperead+0x4d>
    if(myproc()->killed){
801041bd:	e8 d6 00 00 00       	call   80104298 <myproc>
801041c2:	8b 40 24             	mov    0x24(%eax),%eax
801041c5:	85 c0                	test   %eax,%eax
801041c7:	74 15                	je     801041de <piperead+0x35>
      release(&p->lock);
801041c9:	8b 45 08             	mov    0x8(%ebp),%eax
801041cc:	89 04 24             	mov    %eax,(%esp)
801041cf:	e8 d5 15 00 00       	call   801057a9 <release>
      return -1;
801041d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041d9:	e9 b3 00 00 00       	jmp    80104291 <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801041de:	8b 45 08             	mov    0x8(%ebp),%eax
801041e1:	8b 55 08             	mov    0x8(%ebp),%edx
801041e4:	81 c2 34 02 00 00    	add    $0x234,%edx
801041ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801041ee:	89 14 24             	mov    %edx,(%esp)
801041f1:	e8 e8 07 00 00       	call   801049de <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801041f6:	8b 45 08             	mov    0x8(%ebp),%eax
801041f9:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801041ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104202:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104208:	39 c2                	cmp    %eax,%edx
8010420a:	75 0d                	jne    80104219 <piperead+0x70>
8010420c:	8b 45 08             	mov    0x8(%ebp),%eax
8010420f:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104215:	85 c0                	test   %eax,%eax
80104217:	75 a4                	jne    801041bd <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104219:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104220:	eb 49                	jmp    8010426b <piperead+0xc2>
    if(p->nread == p->nwrite)
80104222:	8b 45 08             	mov    0x8(%ebp),%eax
80104225:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010422b:	8b 45 08             	mov    0x8(%ebp),%eax
8010422e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104234:	39 c2                	cmp    %eax,%edx
80104236:	75 02                	jne    8010423a <piperead+0x91>
      break;
80104238:	eb 39                	jmp    80104273 <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010423a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010423d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104240:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80104243:	8b 45 08             	mov    0x8(%ebp),%eax
80104246:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010424c:	8d 48 01             	lea    0x1(%eax),%ecx
8010424f:	8b 55 08             	mov    0x8(%ebp),%edx
80104252:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104258:	25 ff 01 00 00       	and    $0x1ff,%eax
8010425d:	89 c2                	mov    %eax,%edx
8010425f:	8b 45 08             	mov    0x8(%ebp),%eax
80104262:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
80104266:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104268:	ff 45 f4             	incl   -0xc(%ebp)
8010426b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010426e:	3b 45 10             	cmp    0x10(%ebp),%eax
80104271:	7c af                	jl     80104222 <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104273:	8b 45 08             	mov    0x8(%ebp),%eax
80104276:	05 38 02 00 00       	add    $0x238,%eax
8010427b:	89 04 24             	mov    %eax,(%esp)
8010427e:	e8 49 08 00 00       	call   80104acc <wakeup>
  release(&p->lock);
80104283:	8b 45 08             	mov    0x8(%ebp),%eax
80104286:	89 04 24             	mov    %eax,(%esp)
80104289:	e8 1b 15 00 00       	call   801057a9 <release>
  return i;
8010428e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104291:	83 c4 24             	add    $0x24,%esp
80104294:	5b                   	pop    %ebx
80104295:	5d                   	pop    %ebp
80104296:	c3                   	ret    
	...

80104298 <myproc>:
static void wakeup1(void *chan);

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80104298:	55                   	push   %ebp
80104299:	89 e5                	mov    %esp,%ebp
8010429b:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
8010429e:	e8 fb 15 00 00       	call   8010589e <pushcli>
  c = mycpu();
801042a3:	e8 7b 0a 00 00       	call   80104d23 <mycpu>
801042a8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
801042ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042ae:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801042b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
801042b7:	e8 2c 16 00 00       	call   801058e8 <popcli>
  return p;
801042bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801042bf:	c9                   	leave  
801042c0:	c3                   	ret    

801042c1 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
struct proc*
allocproc(struct cont *parentcont)
{
801042c1:	55                   	push   %ebp
801042c2:	89 e5                	mov    %esp,%ebp
801042c4:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;
  struct proc *ptable;
  int nproc;

  acquirectable();
801042c7:	e8 fc 0a 00 00       	call   80104dc8 <acquirectable>

  ptable = parentcont->ptable;
801042cc:	8b 45 08             	mov    0x8(%ebp),%eax
801042cf:	8b 40 28             	mov    0x28(%eax),%eax
801042d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  nproc = parentcont->mproc;
801042d5:	8b 45 08             	mov    0x8(%ebp),%eax
801042d8:	8b 40 08             	mov    0x8(%eax),%eax
801042db:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for(p = ptable; p < &ptable[nproc]; p++) 
801042de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042e1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801042e4:	eb 4c                	jmp    80104332 <allocproc+0x71>
    if(p->state == UNUSED)
801042e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042e9:	8b 40 0c             	mov    0xc(%eax),%eax
801042ec:	85 c0                	test   %eax,%eax
801042ee:	75 3b                	jne    8010432b <allocproc+0x6a>
      goto found;  
801042f0:	90                   	nop

  releasectable();
  return 0;

found:
  p->state = EMBRYO;
801042f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f4:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;  
801042fb:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80104300:	8d 50 01             	lea    0x1(%eax),%edx
80104303:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
80104309:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010430c:	89 42 10             	mov    %eax,0x10(%edx)

  releasectable();  
8010430f:	e8 c8 0a 00 00       	call   80104ddc <releasectable>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104314:	e8 ba ea ff ff       	call   80102dd3 <kalloc>
80104319:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010431c:	89 42 08             	mov    %eax,0x8(%edx)
8010431f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104322:	8b 40 08             	mov    0x8(%eax),%eax
80104325:	85 c0                	test   %eax,%eax
80104327:	75 43                	jne    8010436c <allocproc+0xab>
80104329:	eb 2d                	jmp    80104358 <allocproc+0x97>
  acquirectable();

  ptable = parentcont->ptable;
  nproc = parentcont->mproc;

  for(p = ptable; p < &ptable[nproc]; p++) 
8010432b:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104332:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104335:	c1 e0 02             	shl    $0x2,%eax
80104338:	89 c2                	mov    %eax,%edx
8010433a:	c1 e2 05             	shl    $0x5,%edx
8010433d:	01 c2                	add    %eax,%edx
8010433f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104342:	01 d0                	add    %edx,%eax
80104344:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104347:	77 9d                	ja     801042e6 <allocproc+0x25>
    if(p->state == UNUSED)
      goto found;  

  releasectable();
80104349:	e8 8e 0a 00 00       	call   80104ddc <releasectable>
  return 0;
8010434e:	b8 00 00 00 00       	mov    $0x0,%eax
80104353:	e9 94 00 00 00       	jmp    801043ec <allocproc+0x12b>

  releasectable();  

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
80104358:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104362:	b8 00 00 00 00       	mov    $0x0,%eax
80104367:	e9 80 00 00 00       	jmp    801043ec <allocproc+0x12b>
  }
  sp = p->kstack + KSTACKSIZE;
8010436c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010436f:	8b 40 08             	mov    0x8(%eax),%eax
80104372:	05 00 10 00 00       	add    $0x1000,%eax
80104377:	89 45 e8             	mov    %eax,-0x18(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010437a:	83 6d e8 4c          	subl   $0x4c,-0x18(%ebp)
  p->tf = (struct trapframe*)sp;
8010437e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104381:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104384:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104387:	83 6d e8 04          	subl   $0x4,-0x18(%ebp)
  *(uint*)sp = (uint)trapret;
8010438b:	ba 44 71 10 80       	mov    $0x80107144,%edx
80104390:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104393:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104395:	83 6d e8 14          	subl   $0x14,-0x18(%ebp)
  p->context = (struct context*)sp;
80104399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010439c:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010439f:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801043a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a5:	8b 40 1c             	mov    0x1c(%eax),%eax
801043a8:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801043af:	00 
801043b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801043b7:	00 
801043b8:	89 04 24             	mov    %eax,(%esp)
801043bb:	e8 e2 15 00 00       	call   801059a2 <memset>
  p->context->eip = (uint)forkret;
801043c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043c3:	8b 40 1c             	mov    0x1c(%eax),%eax
801043c6:	ba a6 49 10 80       	mov    $0x801049a6,%edx
801043cb:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
801043ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d1:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->cont = parentcont;
801043d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043db:	8b 55 08             	mov    0x8(%ebp),%edx
801043de:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  procdump();
801043e4:	e8 95 07 00 00       	call   80104b7e <procdump>

  return p;
801043e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801043ec:	c9                   	leave  
801043ed:	c3                   	ret    

801043ee <initprocess>:

// Set up first user process for a given container.
struct proc*
initprocess(struct cont* parentcont, char* name, int isroot)
{
801043ee:	55                   	push   %ebp
801043ef:	89 e5                	mov    %esp,%ebp
801043f1:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc(parentcont);
801043f4:	8b 45 08             	mov    0x8(%ebp),%eax
801043f7:	89 04 24             	mov    %eax,(%esp)
801043fa:	e8 c2 fe ff ff       	call   801042c1 <allocproc>
801043ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if (isroot) {
80104402:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104406:	0f 84 d4 00 00 00    	je     801044e0 <initprocess+0xf2>
    initproc = p;
8010440c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010440f:	a3 80 c7 10 80       	mov    %eax,0x8010c780
    if((p->pgdir = setupkvm()) == 0)
80104414:	e8 85 42 00 00       	call   8010869e <setupkvm>
80104419:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010441c:	89 42 04             	mov    %eax,0x4(%edx)
8010441f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104422:	8b 40 04             	mov    0x4(%eax),%eax
80104425:	85 c0                	test   %eax,%eax
80104427:	75 0c                	jne    80104435 <initprocess+0x47>
      panic("userinit: out of memory?");
80104429:	c7 04 24 45 93 10 80 	movl   $0x80109345,(%esp)
80104430:	e8 1f c1 ff ff       	call   80100554 <panic>
    inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80104435:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010443a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443d:	8b 40 04             	mov    0x4(%eax),%eax
80104440:	89 54 24 08          	mov    %edx,0x8(%esp)
80104444:	c7 44 24 04 00 c5 10 	movl   $0x8010c500,0x4(%esp)
8010444b:	80 
8010444c:	89 04 24             	mov    %eax,(%esp)
8010444f:	e8 ab 44 00 00       	call   801088ff <inituvm>
    p->sz = PGSIZE;
80104454:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104457:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
    memset(p->tf, 0, sizeof(*p->tf));
8010445d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104460:	8b 40 18             	mov    0x18(%eax),%eax
80104463:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
8010446a:	00 
8010446b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104472:	00 
80104473:	89 04 24             	mov    %eax,(%esp)
80104476:	e8 27 15 00 00       	call   801059a2 <memset>
    p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010447b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447e:	8b 40 18             	mov    0x18(%eax),%eax
80104481:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
    p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010448a:	8b 40 18             	mov    0x18(%eax),%eax
8010448d:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
    p->tf->es = p->tf->ds;
80104493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104496:	8b 50 18             	mov    0x18(%eax),%edx
80104499:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449c:	8b 40 18             	mov    0x18(%eax),%eax
8010449f:	8b 40 2c             	mov    0x2c(%eax),%eax
801044a2:	66 89 42 28          	mov    %ax,0x28(%edx)
    p->tf->ss = p->tf->ds;
801044a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a9:	8b 50 18             	mov    0x18(%eax),%edx
801044ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044af:	8b 40 18             	mov    0x18(%eax),%eax
801044b2:	8b 40 2c             	mov    0x2c(%eax),%eax
801044b5:	66 89 42 48          	mov    %ax,0x48(%edx)
    p->tf->eflags = FL_IF;
801044b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044bc:	8b 40 18             	mov    0x18(%eax),%eax
801044bf:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
    p->tf->esp = PGSIZE;
801044c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c9:	8b 40 18             	mov    0x18(%eax),%eax
801044cc:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
    p->tf->eip = 0;  // beginning of initcode.S
801044d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d6:	8b 40 18             	mov    0x18(%eax),%eax
801044d9:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  }

  safestrcpy(p->name, name, sizeof(p->name));
801044e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e3:	8d 50 6c             	lea    0x6c(%eax),%edx
801044e6:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801044ed:	00 
801044ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801044f1:	89 44 24 04          	mov    %eax,0x4(%esp)
801044f5:	89 14 24             	mov    %edx,(%esp)
801044f8:	e8 b1 16 00 00       	call   80105bae <safestrcpy>
  p->cwd = parentcont->rootdir;
801044fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104500:	8b 50 10             	mov    0x10(%eax),%edx
80104503:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104506:	89 50 68             	mov    %edx,0x68(%eax)

  // Set initial process's cont to root
  p->cont = parentcont;
80104509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450c:	8b 55 08             	mov    0x8(%ebp),%edx
8010450f:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquirectable();
80104515:	e8 ae 08 00 00       	call   80104dc8 <acquirectable>

  p->state = RUNNABLE;
8010451a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451d:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  releasectable();
80104524:	e8 b3 08 00 00       	call   80104ddc <releasectable>

  return p;
80104529:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010452c:	c9                   	leave  
8010452d:	c3                   	ret    

8010452e <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010452e:	55                   	push   %ebp
8010452f:	89 e5                	mov    %esp,%ebp
80104531:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
80104534:	e8 5f fd ff ff       	call   80104298 <myproc>
80104539:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
8010453c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010453f:	8b 00                	mov    (%eax),%eax
80104541:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104544:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104548:	7e 31                	jle    8010457b <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010454a:	8b 55 08             	mov    0x8(%ebp),%edx
8010454d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104550:	01 c2                	add    %eax,%edx
80104552:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104555:	8b 40 04             	mov    0x4(%eax),%eax
80104558:	89 54 24 08          	mov    %edx,0x8(%esp)
8010455c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010455f:	89 54 24 04          	mov    %edx,0x4(%esp)
80104563:	89 04 24             	mov    %eax,(%esp)
80104566:	e8 ff 44 00 00       	call   80108a6a <allocuvm>
8010456b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010456e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104572:	75 3e                	jne    801045b2 <growproc+0x84>
      return -1;
80104574:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104579:	eb 4f                	jmp    801045ca <growproc+0x9c>
  } else if(n < 0){
8010457b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010457f:	79 31                	jns    801045b2 <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104581:	8b 55 08             	mov    0x8(%ebp),%edx
80104584:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104587:	01 c2                	add    %eax,%edx
80104589:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010458c:	8b 40 04             	mov    0x4(%eax),%eax
8010458f:	89 54 24 08          	mov    %edx,0x8(%esp)
80104593:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104596:	89 54 24 04          	mov    %edx,0x4(%esp)
8010459a:	89 04 24             	mov    %eax,(%esp)
8010459d:	e8 de 45 00 00       	call   80108b80 <deallocuvm>
801045a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801045a5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801045a9:	75 07                	jne    801045b2 <growproc+0x84>
      return -1;
801045ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045b0:	eb 18                	jmp    801045ca <growproc+0x9c>
  }
  curproc->sz = sz;
801045b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045b8:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
801045ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801045bd:	89 04 24             	mov    %eax,(%esp)
801045c0:	e8 b3 41 00 00       	call   80108778 <switchuvm>
  return 0;
801045c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045ca:	c9                   	leave  
801045cb:	c3                   	ret    

801045cc <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801045cc:	55                   	push   %ebp
801045cd:	89 e5                	mov    %esp,%ebp
801045cf:	57                   	push   %edi
801045d0:	56                   	push   %esi
801045d1:	53                   	push   %ebx
801045d2:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
801045d5:	e8 be fc ff ff       	call   80104298 <myproc>
801045da:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc(curproc->cont)) == 0){
801045dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045e0:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801045e6:	89 04 24             	mov    %eax,(%esp)
801045e9:	e8 d3 fc ff ff       	call   801042c1 <allocproc>
801045ee:	89 45 dc             	mov    %eax,-0x24(%ebp)
801045f1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801045f5:	75 0a                	jne    80104601 <fork+0x35>
    return -1;
801045f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045fc:	e9 27 01 00 00       	jmp    80104728 <fork+0x15c>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80104601:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104604:	8b 10                	mov    (%eax),%edx
80104606:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104609:	8b 40 04             	mov    0x4(%eax),%eax
8010460c:	89 54 24 04          	mov    %edx,0x4(%esp)
80104610:	89 04 24             	mov    %eax,(%esp)
80104613:	e8 08 47 00 00       	call   80108d20 <copyuvm>
80104618:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010461b:	89 42 04             	mov    %eax,0x4(%edx)
8010461e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104621:	8b 40 04             	mov    0x4(%eax),%eax
80104624:	85 c0                	test   %eax,%eax
80104626:	75 2c                	jne    80104654 <fork+0x88>
    kfree(np->kstack);
80104628:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010462b:	8b 40 08             	mov    0x8(%eax),%eax
8010462e:	89 04 24             	mov    %eax,(%esp)
80104631:	e8 07 e7 ff ff       	call   80102d3d <kfree>
    np->kstack = 0;
80104636:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104639:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80104640:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104643:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010464a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010464f:	e9 d4 00 00 00       	jmp    80104728 <fork+0x15c>
  }
  np->sz = curproc->sz;
80104654:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104657:	8b 10                	mov    (%eax),%edx
80104659:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010465c:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010465e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104661:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104664:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104667:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010466a:	8b 50 18             	mov    0x18(%eax),%edx
8010466d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104670:	8b 40 18             	mov    0x18(%eax),%eax
80104673:	89 c3                	mov    %eax,%ebx
80104675:	b8 13 00 00 00       	mov    $0x13,%eax
8010467a:	89 d7                	mov    %edx,%edi
8010467c:	89 de                	mov    %ebx,%esi
8010467e:	89 c1                	mov    %eax,%ecx
80104680:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104682:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104685:	8b 40 18             	mov    0x18(%eax),%eax
80104688:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010468f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104696:	eb 36                	jmp    801046ce <fork+0x102>
    if(curproc->ofile[i])
80104698:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010469b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010469e:	83 c2 08             	add    $0x8,%edx
801046a1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046a5:	85 c0                	test   %eax,%eax
801046a7:	74 22                	je     801046cb <fork+0xff>
      np->ofile[i] = filedup(curproc->ofile[i]);
801046a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801046af:	83 c2 08             	add    $0x8,%edx
801046b2:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801046b6:	89 04 24             	mov    %eax,(%esp)
801046b9:	e8 06 ca ff ff       	call   801010c4 <filedup>
801046be:	8b 55 dc             	mov    -0x24(%ebp),%edx
801046c1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801046c4:	83 c1 08             	add    $0x8,%ecx
801046c7:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801046cb:	ff 45 e4             	incl   -0x1c(%ebp)
801046ce:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801046d2:	7e c4                	jle    80104698 <fork+0xcc>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
801046d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046d7:	8b 40 68             	mov    0x68(%eax),%eax
801046da:	89 04 24             	mov    %eax,(%esp)
801046dd:	e8 12 d3 ff ff       	call   801019f4 <idup>
801046e2:	8b 55 dc             	mov    -0x24(%ebp),%edx
801046e5:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801046e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046eb:	8d 50 6c             	lea    0x6c(%eax),%edx
801046ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046f1:	83 c0 6c             	add    $0x6c,%eax
801046f4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801046fb:	00 
801046fc:	89 54 24 04          	mov    %edx,0x4(%esp)
80104700:	89 04 24             	mov    %eax,(%esp)
80104703:	e8 a6 14 00 00       	call   80105bae <safestrcpy>

  pid = np->pid;
80104708:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010470b:	8b 40 10             	mov    0x10(%eax),%eax
8010470e:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquirectable();
80104711:	e8 b2 06 00 00       	call   80104dc8 <acquirectable>

  np->state = RUNNABLE;
80104716:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104719:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  releasectable();
80104720:	e8 b7 06 00 00       	call   80104ddc <releasectable>

  return pid;
80104725:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80104728:	83 c4 2c             	add    $0x2c,%esp
8010472b:	5b                   	pop    %ebx
8010472c:	5e                   	pop    %esi
8010472d:	5f                   	pop    %edi
8010472e:	5d                   	pop    %ebp
8010472f:	c3                   	ret    

80104730 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104730:	55                   	push   %ebp
80104731:	89 e5                	mov    %esp,%ebp
80104733:	83 ec 38             	sub    $0x38,%esp
  struct proc *curproc = myproc();
80104736:	e8 5d fb ff ff       	call   80104298 <myproc>
8010473b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  struct proc *ptable;
  int fd, nproc;

  if(curproc == initproc)
8010473e:	a1 80 c7 10 80       	mov    0x8010c780,%eax
80104743:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104746:	75 0c                	jne    80104754 <exit+0x24>
    panic("init exiting");
80104748:	c7 04 24 5e 93 10 80 	movl   $0x8010935e,(%esp)
8010474f:	e8 00 be ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104754:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010475b:	eb 3a                	jmp    80104797 <exit+0x67>
    if(curproc->ofile[fd]){
8010475d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104760:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104763:	83 c2 08             	add    $0x8,%edx
80104766:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010476a:	85 c0                	test   %eax,%eax
8010476c:	74 26                	je     80104794 <exit+0x64>
      fileclose(curproc->ofile[fd]);
8010476e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104771:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104774:	83 c2 08             	add    $0x8,%edx
80104777:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
8010477b:	89 04 24             	mov    %eax,(%esp)
8010477e:	e8 89 c9 ff ff       	call   8010110c <fileclose>
      curproc->ofile[fd] = 0;
80104783:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104786:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104789:	83 c2 08             	add    $0x8,%edx
8010478c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104793:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104794:	ff 45 f0             	incl   -0x10(%ebp)
80104797:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010479b:	7e c0                	jle    8010475d <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
8010479d:	e8 f9 ee ff ff       	call   8010369b <begin_op>
  iput(curproc->cwd);
801047a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047a5:	8b 40 68             	mov    0x68(%eax),%eax
801047a8:	89 04 24             	mov    %eax,(%esp)
801047ab:	e8 c4 d3 ff ff       	call   80101b74 <iput>
  end_op();
801047b0:	e8 68 ef ff ff       	call   8010371d <end_op>
  curproc->cwd = 0;
801047b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047b8:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquirectable();
801047bf:	e8 04 06 00 00       	call   80104dc8 <acquirectable>

  ptable = curproc->cont->ptable;
801047c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047c7:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801047cd:	8b 40 28             	mov    0x28(%eax),%eax
801047d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  nproc = curproc->cont->mproc;
801047d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047d6:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801047dc:	8b 40 08             	mov    0x8(%eax),%eax
801047df:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801047e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047e5:	8b 40 14             	mov    0x14(%eax),%eax
801047e8:	89 04 24             	mov    %eax,(%esp)
801047eb:	e8 78 02 00 00       	call   80104a68 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable; p < &ptable[nproc]; p++){
801047f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801047f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801047f6:	eb 36                	jmp    8010482e <exit+0xfe>
    if(p->parent == curproc){
801047f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801047fb:	8b 40 14             	mov    0x14(%eax),%eax
801047fe:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104801:	75 24                	jne    80104827 <exit+0xf7>
      p->parent = initproc;
80104803:	8b 15 80 c7 10 80    	mov    0x8010c780,%edx
80104809:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010480c:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
8010480f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104812:	8b 40 0c             	mov    0xc(%eax),%eax
80104815:	83 f8 05             	cmp    $0x5,%eax
80104818:	75 0d                	jne    80104827 <exit+0xf7>
        wakeup1(initproc);
8010481a:	a1 80 c7 10 80       	mov    0x8010c780,%eax
8010481f:	89 04 24             	mov    %eax,(%esp)
80104822:	e8 41 02 00 00       	call   80104a68 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable; p < &ptable[nproc]; p++){
80104827:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010482e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104831:	c1 e0 02             	shl    $0x2,%eax
80104834:	89 c2                	mov    %eax,%edx
80104836:	c1 e2 05             	shl    $0x5,%edx
80104839:	01 c2                	add    %eax,%edx
8010483b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010483e:	01 d0                	add    %edx,%eax
80104840:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104843:	77 b3                	ja     801047f8 <exit+0xc8>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104845:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104848:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010484f:	e8 c0 07 00 00       	call   80105014 <sched>
  panic("zombie exit");
80104854:	c7 04 24 6b 93 10 80 	movl   $0x8010936b,(%esp)
8010485b:	e8 f4 bc ff ff       	call   80100554 <panic>

80104860 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104860:	55                   	push   %ebp
80104861:	89 e5                	mov    %esp,%ebp
80104863:	83 ec 38             	sub    $0x38,%esp
  struct proc *p;
  struct proc *ptable;
  int havekids, pid, nproc;
  struct proc *curproc = myproc();
80104866:	e8 2d fa ff ff       	call   80104298 <myproc>
8010486b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquirectable();
8010486e:	e8 55 05 00 00       	call   80104dc8 <acquirectable>

  ptable = curproc->cont->ptable;
80104873:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104876:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010487c:	8b 40 28             	mov    0x28(%eax),%eax
8010487f:	89 45 e8             	mov    %eax,-0x18(%ebp)
  nproc = curproc->cont->mproc;
80104882:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104885:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010488b:	8b 40 08             	mov    0x8(%eax),%eax
8010488e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104891:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable; p < &ptable[nproc]; p++){
80104898:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010489b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010489e:	e9 8e 00 00 00       	jmp    80104931 <wait+0xd1>
      if(p->parent != curproc)
801048a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048a6:	8b 40 14             	mov    0x14(%eax),%eax
801048a9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801048ac:	74 02                	je     801048b0 <wait+0x50>
        continue;
801048ae:	eb 7a                	jmp    8010492a <wait+0xca>
      havekids = 1;
801048b0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
801048b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ba:	8b 40 0c             	mov    0xc(%eax),%eax
801048bd:	83 f8 05             	cmp    $0x5,%eax
801048c0:	75 68                	jne    8010492a <wait+0xca>
        // Found one.
        pid = p->pid;
801048c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c5:	8b 40 10             	mov    0x10(%eax),%eax
801048c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
        kfree(p->kstack);
801048cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ce:	8b 40 08             	mov    0x8(%eax),%eax
801048d1:	89 04 24             	mov    %eax,(%esp)
801048d4:	e8 64 e4 ff ff       	call   80102d3d <kfree>
        p->kstack = 0;
801048d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048dc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801048e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048e6:	8b 40 04             	mov    0x4(%eax),%eax
801048e9:	89 04 24             	mov    %eax,(%esp)
801048ec:	e8 53 43 00 00       	call   80108c44 <freevm>
        p->pid = 0;
801048f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f4:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801048fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048fe:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104905:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104908:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010490c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010490f:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104916:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104919:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        releasectable();
80104920:	e8 b7 04 00 00       	call   80104ddc <releasectable>
        return pid;
80104925:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104928:	eb 57                	jmp    80104981 <wait+0x121>
  nproc = curproc->cont->mproc;

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable; p < &ptable[nproc]; p++){
8010492a:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104931:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104934:	c1 e0 02             	shl    $0x2,%eax
80104937:	89 c2                	mov    %eax,%edx
80104939:	c1 e2 05             	shl    $0x5,%edx
8010493c:	01 c2                	add    %eax,%edx
8010493e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104941:	01 d0                	add    %edx,%eax
80104943:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104946:	0f 87 57 ff ff ff    	ja     801048a3 <wait+0x43>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
8010494c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104950:	74 0a                	je     8010495c <wait+0xfc>
80104952:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104955:	8b 40 24             	mov    0x24(%eax),%eax
80104958:	85 c0                	test   %eax,%eax
8010495a:	74 0c                	je     80104968 <wait+0x108>
      releasectable();
8010495c:	e8 7b 04 00 00       	call   80104ddc <releasectable>
      return -1;
80104961:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104966:	eb 19                	jmp    80104981 <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, ctablelock());  //DOC: wait-sleep
80104968:	e8 83 04 00 00       	call   80104df0 <ctablelock>
8010496d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104971:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104974:	89 04 24             	mov    %eax,(%esp)
80104977:	e8 62 00 00 00       	call   801049de <sleep>
  }
8010497c:	e9 10 ff ff ff       	jmp    80104891 <wait+0x31>
}
80104981:	c9                   	leave  
80104982:	c3                   	ret    

80104983 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104983:	55                   	push   %ebp
80104984:	89 e5                	mov    %esp,%ebp
80104986:	83 ec 08             	sub    $0x8,%esp
  acquirectable();  //DOC: yieldlock
80104989:	e8 3a 04 00 00       	call   80104dc8 <acquirectable>
  myproc()->state = RUNNABLE;
8010498e:	e8 05 f9 ff ff       	call   80104298 <myproc>
80104993:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010499a:	e8 75 06 00 00       	call   80105014 <sched>
  releasectable();
8010499f:	e8 38 04 00 00       	call   80104ddc <releasectable>
}
801049a4:	c9                   	leave  
801049a5:	c3                   	ret    

801049a6 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801049a6:	55                   	push   %ebp
801049a7:	89 e5                	mov    %esp,%ebp
801049a9:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ctablelock from scheduler.
  releasectable();
801049ac:	e8 2b 04 00 00       	call   80104ddc <releasectable>

  if (first) {
801049b1:	a1 04 c0 10 80       	mov    0x8010c004,%eax
801049b6:	85 c0                	test   %eax,%eax
801049b8:	74 22                	je     801049dc <forkret+0x36>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801049ba:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
801049c1:	00 00 00 
    iinit(ROOTDEV);
801049c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801049cb:	e8 ef cc ff ff       	call   801016bf <iinit>
    initlog(ROOTDEV);
801049d0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801049d7:	e8 c0 ea ff ff       	call   8010349c <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
801049dc:	c9                   	leave  
801049dd:	c3                   	ret    

801049de <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801049de:	55                   	push   %ebp
801049df:	89 e5                	mov    %esp,%ebp
801049e1:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
801049e4:	e8 af f8 ff ff       	call   80104298 <myproc>
801049e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801049ec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801049f0:	75 0c                	jne    801049fe <sleep+0x20>
    panic("sleep");
801049f2:	c7 04 24 77 93 10 80 	movl   $0x80109377,(%esp)
801049f9:	e8 56 bb ff ff       	call   80100554 <panic>

  if(lk == 0)
801049fe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104a02:	75 0c                	jne    80104a10 <sleep+0x32>
    panic("sleep without lk");  
80104a04:	c7 04 24 7d 93 10 80 	movl   $0x8010937d,(%esp)
80104a0b:	e8 44 bb ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ctable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ctable.lock locked),
  // so it's okay to release lk.
  if(lk != ctablelock()){  //DOC: sleeplock0
80104a10:	e8 db 03 00 00       	call   80104df0 <ctablelock>
80104a15:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104a18:	74 10                	je     80104a2a <sleep+0x4c>
    acquirectable();  //DOC: sleeplock1
80104a1a:	e8 a9 03 00 00       	call   80104dc8 <acquirectable>
    release(lk);
80104a1f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a22:	89 04 24             	mov    %eax,(%esp)
80104a25:	e8 7f 0d 00 00       	call   801057a9 <release>
  }
  // Go to sleep.
  p->chan = chan;
80104a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a2d:	8b 55 08             	mov    0x8(%ebp),%edx
80104a30:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a36:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  //cprintf("Sleeping %s\n", p->name);

  sched();
80104a3d:	e8 d2 05 00 00       	call   80105014 <sched>

  // Tidy up.
  p->chan = 0;
80104a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a45:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != ctablelock()){  //DOC: sleeplock2
80104a4c:	e8 9f 03 00 00       	call   80104df0 <ctablelock>
80104a51:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104a54:	74 10                	je     80104a66 <sleep+0x88>
    releasectable();
80104a56:	e8 81 03 00 00       	call   80104ddc <releasectable>
    acquire(lk);
80104a5b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a5e:	89 04 24             	mov    %eax,(%esp)
80104a61:	e8 d9 0c 00 00       	call   8010573f <acquire>
  }
}
80104a66:	c9                   	leave  
80104a67:	c3                   	ret    

80104a68 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ctable lock must be held.
static void
wakeup1(void *chan)
{
80104a68:	55                   	push   %ebp
80104a69:	89 e5                	mov    %esp,%ebp
80104a6b:	83 ec 18             	sub    $0x18,%esp
  int nproc;

  //cprintf("May not work, may have to wake up all containers processes\n");

  // TODO: maybe remove mycont() function then change this to work
  nproc = mycont()->mproc;
80104a6e:	e8 22 05 00 00       	call   80104f95 <mycont>
80104a73:	8b 40 08             	mov    0x8(%eax),%eax
80104a76:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ptable = mycont()->ptable;
80104a79:	e8 17 05 00 00       	call   80104f95 <mycont>
80104a7e:	8b 40 28             	mov    0x28(%eax),%eax
80104a81:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for(p = ptable; p < &ptable[nproc]; p++)
80104a84:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a87:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104a8a:	eb 27                	jmp    80104ab3 <wakeup1+0x4b>
    if(p->state == SLEEPING && p->chan == chan) {
80104a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8f:	8b 40 0c             	mov    0xc(%eax),%eax
80104a92:	83 f8 02             	cmp    $0x2,%eax
80104a95:	75 15                	jne    80104aac <wakeup1+0x44>
80104a97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9a:	8b 40 20             	mov    0x20(%eax),%eax
80104a9d:	3b 45 08             	cmp    0x8(%ebp),%eax
80104aa0:	75 0a                	jne    80104aac <wakeup1+0x44>
      //cprintf("Waking up: %s\n", p->name);
      p->state = RUNNABLE;
80104aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  // TODO: maybe remove mycont() function then change this to work
  nproc = mycont()->mproc;
  ptable = mycont()->ptable;

  for(p = ptable; p < &ptable[nproc]; p++)
80104aac:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104ab3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ab6:	c1 e0 02             	shl    $0x2,%eax
80104ab9:	89 c2                	mov    %eax,%edx
80104abb:	c1 e2 05             	shl    $0x5,%edx
80104abe:	01 c2                	add    %eax,%edx
80104ac0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104ac3:	01 d0                	add    %edx,%eax
80104ac5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104ac8:	77 c2                	ja     80104a8c <wakeup1+0x24>
    if(p->state == SLEEPING && p->chan == chan) {
      //cprintf("Waking up: %s\n", p->name);
      p->state = RUNNABLE;
    }
}
80104aca:	c9                   	leave  
80104acb:	c3                   	ret    

80104acc <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104acc:	55                   	push   %ebp
80104acd:	89 e5                	mov    %esp,%ebp
80104acf:	83 ec 18             	sub    $0x18,%esp
  acquirectable();
80104ad2:	e8 f1 02 00 00       	call   80104dc8 <acquirectable>
  wakeup1(chan);
80104ad7:	8b 45 08             	mov    0x8(%ebp),%eax
80104ada:	89 04 24             	mov    %eax,(%esp)
80104add:	e8 86 ff ff ff       	call   80104a68 <wakeup1>
  releasectable();
80104ae2:	e8 f5 02 00 00       	call   80104ddc <releasectable>
}
80104ae7:	c9                   	leave  
80104ae8:	c3                   	ret    

80104ae9 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104ae9:	55                   	push   %ebp
80104aea:	89 e5                	mov    %esp,%ebp
80104aec:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct proc *ptable;
  int nproc;

  acquirectable();
80104aef:	e8 d4 02 00 00       	call   80104dc8 <acquirectable>

  ptable = myproc()->cont->ptable;
80104af4:	e8 9f f7 ff ff       	call   80104298 <myproc>
80104af9:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104aff:	8b 40 28             	mov    0x28(%eax),%eax
80104b02:	89 45 f0             	mov    %eax,-0x10(%ebp)
  nproc = myproc()->cont->mproc;
80104b05:	e8 8e f7 ff ff       	call   80104298 <myproc>
80104b0a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104b10:	8b 40 08             	mov    0x8(%eax),%eax
80104b13:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for(p = ptable; p < &ptable[nproc]; p++){
80104b16:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b19:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104b1c:	eb 3d                	jmp    80104b5b <kill+0x72>
    if(p->pid == pid){
80104b1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b21:	8b 40 10             	mov    0x10(%eax),%eax
80104b24:	3b 45 08             	cmp    0x8(%ebp),%eax
80104b27:	75 2b                	jne    80104b54 <kill+0x6b>
      p->killed = 1;
80104b29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b2c:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b36:	8b 40 0c             	mov    0xc(%eax),%eax
80104b39:	83 f8 02             	cmp    $0x2,%eax
80104b3c:	75 0a                	jne    80104b48 <kill+0x5f>
        p->state = RUNNABLE;
80104b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b41:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      releasectable();
80104b48:	e8 8f 02 00 00       	call   80104ddc <releasectable>
      return 0;
80104b4d:	b8 00 00 00 00       	mov    $0x0,%eax
80104b52:	eb 28                	jmp    80104b7c <kill+0x93>
  acquirectable();

  ptable = myproc()->cont->ptable;
  nproc = myproc()->cont->mproc;

  for(p = ptable; p < &ptable[nproc]; p++){
80104b54:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104b5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b5e:	c1 e0 02             	shl    $0x2,%eax
80104b61:	89 c2                	mov    %eax,%edx
80104b63:	c1 e2 05             	shl    $0x5,%edx
80104b66:	01 c2                	add    %eax,%edx
80104b68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b6b:	01 d0                	add    %edx,%eax
80104b6d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104b70:	77 ac                	ja     80104b1e <kill+0x35>
        p->state = RUNNABLE;
      releasectable();
      return 0;
    }
  }
  releasectable();
80104b72:	e8 65 02 00 00       	call   80104ddc <releasectable>
  return -1;
80104b77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104b7c:	c9                   	leave  
80104b7d:	c3                   	ret    

80104b7e <procdump>:
// Print a process listing of current container to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104b7e:	55                   	push   %ebp
80104b7f:	89 e5                	mov    %esp,%ebp
80104b81:	83 ec 68             	sub    $0x68,%esp
  uint pc[10];

  struct proc *ptable;
  int nproc;

  acquirectable();
80104b84:	e8 3f 02 00 00       	call   80104dc8 <acquirectable>

  // TODO: Fix so maybe myproc()->cont->ptable
  nproc = mycont()->mproc;
80104b89:	e8 07 04 00 00       	call   80104f95 <mycont>
80104b8e:	8b 40 08             	mov    0x8(%eax),%eax
80104b91:	89 45 e8             	mov    %eax,-0x18(%ebp)
  ptable = mycont()->ptable;
80104b94:	e8 fc 03 00 00       	call   80104f95 <mycont>
80104b99:	8b 40 28             	mov    0x28(%eax),%eax
80104b9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  cprintf("procdump() nproc: %d\n", nproc);
80104b9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104ba2:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ba6:	c7 04 24 8e 93 10 80 	movl   $0x8010938e,(%esp)
80104bad:	e8 0f b8 ff ff       	call   801003c1 <cprintf>

  for(p = ptable; p < &ptable[nproc]; p++){
80104bb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104bb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104bb8:	e9 e8 00 00 00       	jmp    80104ca5 <procdump+0x127>
    if(p->state == UNUSED)
80104bbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bc0:	8b 40 0c             	mov    0xc(%eax),%eax
80104bc3:	85 c0                	test   %eax,%eax
80104bc5:	75 05                	jne    80104bcc <procdump+0x4e>
      continue;
80104bc7:	e9 d2 00 00 00       	jmp    80104c9e <procdump+0x120>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104bcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bcf:	8b 40 0c             	mov    0xc(%eax),%eax
80104bd2:	83 f8 05             	cmp    $0x5,%eax
80104bd5:	77 23                	ja     80104bfa <procdump+0x7c>
80104bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bda:	8b 40 0c             	mov    0xc(%eax),%eax
80104bdd:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104be4:	85 c0                	test   %eax,%eax
80104be6:	74 12                	je     80104bfa <procdump+0x7c>
      state = states[p->state];
80104be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104beb:	8b 40 0c             	mov    0xc(%eax),%eax
80104bee:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104bf5:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104bf8:	eb 07                	jmp    80104c01 <procdump+0x83>
    else
      state = "???";
80104bfa:	c7 45 ec a4 93 10 80 	movl   $0x801093a4,-0x14(%ebp)
    cprintf("cid: %d. %d %s %s", p->cont->cid, p->pid, state, p->name);
80104c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c04:	8d 48 6c             	lea    0x6c(%eax),%ecx
80104c07:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c0a:	8b 50 10             	mov    0x10(%eax),%edx
80104c0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c10:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104c16:	8b 40 0c             	mov    0xc(%eax),%eax
80104c19:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80104c1d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80104c20:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80104c24:	89 54 24 08          	mov    %edx,0x8(%esp)
80104c28:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c2c:	c7 04 24 a8 93 10 80 	movl   $0x801093a8,(%esp)
80104c33:	e8 89 b7 ff ff       	call   801003c1 <cprintf>
    if(p->state == SLEEPING){
80104c38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c3b:	8b 40 0c             	mov    0xc(%eax),%eax
80104c3e:	83 f8 02             	cmp    $0x2,%eax
80104c41:	75 4f                	jne    80104c92 <procdump+0x114>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c46:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c49:	8b 40 0c             	mov    0xc(%eax),%eax
80104c4c:	83 c0 08             	add    $0x8,%eax
80104c4f:	8d 55 bc             	lea    -0x44(%ebp),%edx
80104c52:	89 54 24 04          	mov    %edx,0x4(%esp)
80104c56:	89 04 24             	mov    %eax,(%esp)
80104c59:	e8 98 0b 00 00       	call   801057f6 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104c5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104c65:	eb 1a                	jmp    80104c81 <procdump+0x103>
        cprintf(" %p", pc[i]);
80104c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c6a:	8b 44 85 bc          	mov    -0x44(%ebp,%eax,4),%eax
80104c6e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c72:	c7 04 24 ba 93 10 80 	movl   $0x801093ba,(%esp)
80104c79:	e8 43 b7 ff ff       	call   801003c1 <cprintf>
    else
      state = "???";
    cprintf("cid: %d. %d %s %s", p->cont->cid, p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104c7e:	ff 45 f4             	incl   -0xc(%ebp)
80104c81:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104c85:	7f 0b                	jg     80104c92 <procdump+0x114>
80104c87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c8a:	8b 44 85 bc          	mov    -0x44(%ebp,%eax,4),%eax
80104c8e:	85 c0                	test   %eax,%eax
80104c90:	75 d5                	jne    80104c67 <procdump+0xe9>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104c92:	c7 04 24 be 93 10 80 	movl   $0x801093be,(%esp)
80104c99:	e8 23 b7 ff ff       	call   801003c1 <cprintf>
  nproc = mycont()->mproc;
  ptable = mycont()->ptable;

  cprintf("procdump() nproc: %d\n", nproc);

  for(p = ptable; p < &ptable[nproc]; p++){
80104c9e:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104ca5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104ca8:	c1 e0 02             	shl    $0x2,%eax
80104cab:	89 c2                	mov    %eax,%edx
80104cad:	c1 e2 05             	shl    $0x5,%edx
80104cb0:	01 c2                	add    %eax,%edx
80104cb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104cb5:	01 d0                	add    %edx,%eax
80104cb7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104cba:	0f 87 fd fe ff ff    	ja     80104bbd <procdump+0x3f>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }

  releasectable();
80104cc0:	e8 17 01 00 00       	call   80104ddc <releasectable>
}
80104cc5:	c9                   	leave  
80104cc6:	c3                   	ret    
	...

80104cc8 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104cc8:	55                   	push   %ebp
80104cc9:	89 e5                	mov    %esp,%ebp
80104ccb:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104cce:	9c                   	pushf  
80104ccf:	58                   	pop    %eax
80104cd0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104cd3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104cd6:	c9                   	leave  
80104cd7:	c3                   	ret    

80104cd8 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104cd8:	55                   	push   %ebp
80104cd9:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104cdb:	fb                   	sti    
}
80104cdc:	5d                   	pop    %ebp
80104cdd:	c3                   	ret    

80104cde <cpuid>:

// TODO: Check to make sure ALL ctable calls have a lock

// Must be called with interrupts disabled
int
cpuid() {
80104cde:	55                   	push   %ebp
80104cdf:	89 e5                	mov    %esp,%ebp
80104ce1:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104ce4:	e8 3a 00 00 00       	call   80104d23 <mycpu>
80104ce9:	89 c2                	mov    %eax,%edx
80104ceb:	b8 60 49 11 80       	mov    $0x80114960,%eax
80104cf0:	29 c2                	sub    %eax,%edx
80104cf2:	89 d0                	mov    %edx,%eax
80104cf4:	c1 f8 04             	sar    $0x4,%eax
80104cf7:	89 c1                	mov    %eax,%ecx
80104cf9:	89 ca                	mov    %ecx,%edx
80104cfb:	c1 e2 03             	shl    $0x3,%edx
80104cfe:	01 ca                	add    %ecx,%edx
80104d00:	89 d0                	mov    %edx,%eax
80104d02:	c1 e0 05             	shl    $0x5,%eax
80104d05:	29 d0                	sub    %edx,%eax
80104d07:	c1 e0 02             	shl    $0x2,%eax
80104d0a:	01 c8                	add    %ecx,%eax
80104d0c:	c1 e0 03             	shl    $0x3,%eax
80104d0f:	01 c8                	add    %ecx,%eax
80104d11:	89 c2                	mov    %eax,%edx
80104d13:	c1 e2 0f             	shl    $0xf,%edx
80104d16:	29 c2                	sub    %eax,%edx
80104d18:	c1 e2 02             	shl    $0x2,%edx
80104d1b:	01 ca                	add    %ecx,%edx
80104d1d:	89 d0                	mov    %edx,%eax
80104d1f:	f7 d8                	neg    %eax
}
80104d21:	c9                   	leave  
80104d22:	c3                   	ret    

80104d23 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104d23:	55                   	push   %ebp
80104d24:	89 e5                	mov    %esp,%ebp
80104d26:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104d29:	e8 9a ff ff ff       	call   80104cc8 <readeflags>
80104d2e:	25 00 02 00 00       	and    $0x200,%eax
80104d33:	85 c0                	test   %eax,%eax
80104d35:	74 0c                	je     80104d43 <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
80104d37:	c7 04 24 ec 93 10 80 	movl   $0x801093ec,(%esp)
80104d3e:	e8 11 b8 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
80104d43:	e8 09 e4 ff ff       	call   80103151 <lapicid>
80104d48:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104d4b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d52:	eb 3b                	jmp    80104d8f <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
80104d54:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d57:	89 d0                	mov    %edx,%eax
80104d59:	c1 e0 02             	shl    $0x2,%eax
80104d5c:	01 d0                	add    %edx,%eax
80104d5e:	01 c0                	add    %eax,%eax
80104d60:	01 d0                	add    %edx,%eax
80104d62:	c1 e0 04             	shl    $0x4,%eax
80104d65:	05 60 49 11 80       	add    $0x80114960,%eax
80104d6a:	8a 00                	mov    (%eax),%al
80104d6c:	0f b6 c0             	movzbl %al,%eax
80104d6f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104d72:	75 18                	jne    80104d8c <mycpu+0x69>
      return &cpus[i];
80104d74:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d77:	89 d0                	mov    %edx,%eax
80104d79:	c1 e0 02             	shl    $0x2,%eax
80104d7c:	01 d0                	add    %edx,%eax
80104d7e:	01 c0                	add    %eax,%eax
80104d80:	01 d0                	add    %edx,%eax
80104d82:	c1 e0 04             	shl    $0x4,%eax
80104d85:	05 60 49 11 80       	add    $0x80114960,%eax
80104d8a:	eb 19                	jmp    80104da5 <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104d8c:	ff 45 f4             	incl   -0xc(%ebp)
80104d8f:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80104d94:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104d97:	7c bb                	jl     80104d54 <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104d99:	c7 04 24 12 94 10 80 	movl   $0x80109412,(%esp)
80104da0:	e8 af b7 ff ff       	call   80100554 <panic>
}
80104da5:	c9                   	leave  
80104da6:	c3                   	ret    

80104da7 <cinit>:

int nextcid = 1;

void
cinit(void)
{
80104da7:	55                   	push   %ebp
80104da8:	89 e5                	mov    %esp,%ebp
80104daa:	83 ec 18             	sub    $0x18,%esp
  initlock(&ctable.lock, "ctable");
80104dad:	c7 44 24 04 22 94 10 	movl   $0x80109422,0x4(%esp)
80104db4:	80 
80104db5:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104dbc:	e8 5d 09 00 00       	call   8010571e <initlock>
  // TODO: Remove
  contdump();
80104dc1:	e8 57 01 00 00       	call   80104f1d <contdump>
}
80104dc6:	c9                   	leave  
80104dc7:	c3                   	ret    

80104dc8 <acquirectable>:

void
acquirectable(void) 
{
80104dc8:	55                   	push   %ebp
80104dc9:	89 e5                	mov    %esp,%ebp
80104dcb:	83 ec 18             	sub    $0x18,%esp
	//cprintf("\t\tWaiting on acquiring ctable...\n");
	acquire(&ptable.lock);
80104dce:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
80104dd5:	e8 65 09 00 00       	call   8010573f <acquire>
	//cprintf("\t\tGot ctable\n");
}
80104dda:	c9                   	leave  
80104ddb:	c3                   	ret    

80104ddc <releasectable>:
// TODO: refactor name of ctablelock to ptable
// TODO: replace these aqcuires and releases with normal aqcuire and release using ctablelock()
void 
releasectable(void)
{
80104ddc:	55                   	push   %ebp
80104ddd:	89 e5                	mov    %esp,%ebp
80104ddf:	83 ec 18             	sub    $0x18,%esp
	release(&ptable.lock);
80104de2:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
80104de9:	e8 bb 09 00 00       	call   801057a9 <release>
	//cprintf("\t\t Released ctable\n");
}
80104dee:	c9                   	leave  
80104def:	c3                   	ret    

80104df0 <ctablelock>:

struct spinlock*
ctablelock(void)
{
80104df0:	55                   	push   %ebp
80104df1:	89 e5                	mov    %esp,%ebp
	return &ptable.lock;
80104df3:	b8 c0 50 11 80       	mov    $0x801150c0,%eax
}
80104df8:	5d                   	pop    %ebp
80104df9:	c3                   	ret    

80104dfa <initcontainer>:

struct cont*
initcontainer(void)
{
80104dfa:	55                   	push   %ebp
80104dfb:	89 e5                	mov    %esp,%ebp
80104dfd:	83 ec 38             	sub    $0x38,%esp
	int i,
		mproc = MAX_CONT_PROC,
80104e00:	c7 45 f0 40 00 00 00 	movl   $0x40,-0x10(%ebp)
		msz   = MAX_CONT_MEM,
80104e07:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
		mdsk  = MAX_CONT_DSK;
80104e0e:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
	struct cont *c;

	if ((c = alloccont()) == 0) {
80104e15:	e8 85 01 00 00       	call   80104f9f <alloccont>
80104e1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80104e1d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80104e21:	75 0c                	jne    80104e2f <initcontainer+0x35>
		panic("Can't alloc init container.");
80104e23:	c7 04 24 29 94 10 80 	movl   $0x80109429,(%esp)
80104e2a:	e8 25 b7 ff ff       	call   80100554 <panic>
	}

	currcont = c;	
80104e2f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e32:	a3 b4 50 11 80       	mov    %eax,0x801150b4

	acquire(&ctable.lock);
80104e37:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104e3e:	e8 fc 08 00 00       	call   8010573f <acquire>
	c->mproc = mproc;
80104e43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e46:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e49:	89 50 08             	mov    %edx,0x8(%eax)
	c->msz = msz;
80104e4c:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104e4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e52:	89 10                	mov    %edx,(%eax)
	c->mdsk = mdsk;	
80104e54:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104e57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e5a:	89 50 04             	mov    %edx,0x4(%eax)
	c->state = CRUNNABLE;	
80104e5d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e60:	c7 40 14 02 00 00 00 	movl   $0x2,0x14(%eax)
	c->rootdir = namei("/");
80104e67:	c7 04 24 45 94 10 80 	movl   $0x80109445,(%esp)
80104e6e:	e8 53 d8 ff ff       	call   801026c6 <namei>
80104e73:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104e76:	89 42 10             	mov    %eax,0x10(%edx)
	safestrcpy(c->name, "initcont", sizeof(c->name));	
80104e79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104e7c:	83 c0 18             	add    $0x18,%eax
80104e7f:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104e86:	00 
80104e87:	c7 44 24 04 47 94 10 	movl   $0x80109447,0x4(%esp)
80104e8e:	80 
80104e8f:	89 04 24             	mov    %eax,(%esp)
80104e92:	e8 17 0d 00 00       	call   80105bae <safestrcpy>

	// Init pointers to each container's process tables
	for (i = 0; i < NCONT; i++)
80104e97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e9e:	eb 2f                	jmp    80104ecf <initcontainer+0xd5>
		ctable.cont[i].ptable = ptable.proc[i];
80104ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ea3:	c1 e0 08             	shl    $0x8,%eax
80104ea6:	89 c2                	mov    %eax,%edx
80104ea8:	c1 e2 05             	shl    $0x5,%edx
80104eab:	01 d0                	add    %edx,%eax
80104ead:	83 c0 30             	add    $0x30,%eax
80104eb0:	05 c0 50 11 80       	add    $0x801150c0,%eax
80104eb5:	8d 48 04             	lea    0x4(%eax),%ecx
80104eb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ebb:	89 d0                	mov    %edx,%eax
80104ebd:	01 c0                	add    %eax,%eax
80104ebf:	01 d0                	add    %edx,%eax
80104ec1:	c1 e0 04             	shl    $0x4,%eax
80104ec4:	05 50 4f 11 80       	add    $0x80114f50,%eax
80104ec9:	89 48 0c             	mov    %ecx,0xc(%eax)
	c->state = CRUNNABLE;	
	c->rootdir = namei("/");
	safestrcpy(c->name, "initcont", sizeof(c->name));	

	// Init pointers to each container's process tables
	for (i = 0; i < NCONT; i++)
80104ecc:	ff 45 f4             	incl   -0xc(%ebp)
80104ecf:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80104ed3:	7e cb                	jle    80104ea0 <initcontainer+0xa6>
		ctable.cont[i].ptable = ptable.proc[i];

	release(&ctable.lock);	
80104ed5:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104edc:	e8 c8 08 00 00       	call   801057a9 <release>

	return c;
80104ee1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80104ee4:	c9                   	leave  
80104ee5:	c3                   	ret    

80104ee6 <userinit>:

// Set up first user container and process.
void
userinit(void)
{
80104ee6:	55                   	push   %ebp
80104ee7:	89 e5                	mov    %esp,%ebp
80104ee9:	83 ec 28             	sub    $0x28,%esp
	cprintf("userinit\n");
80104eec:	c7 04 24 50 94 10 80 	movl   $0x80109450,(%esp)
80104ef3:	e8 c9 b4 ff ff       	call   801003c1 <cprintf>
	struct cont* root;
  	root = initcontainer();
80104ef8:	e8 fd fe ff ff       	call   80104dfa <initcontainer>
80104efd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  	initprocess(root, "initproc", 1);    	
80104f00:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80104f07:	00 
80104f08:	c7 44 24 04 5a 94 10 	movl   $0x8010945a,0x4(%esp)
80104f0f:	80 
80104f10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f13:	89 04 24             	mov    %eax,(%esp)
80104f16:	e8 d3 f4 ff ff       	call   801043ee <initprocess>
}
80104f1b:	c9                   	leave  
80104f1c:	c3                   	ret    

80104f1d <contdump>:

void
contdump(void)
{
80104f1d:	55                   	push   %ebp
80104f1e:	89 e5                	mov    %esp,%ebp
80104f20:	83 ec 28             	sub    $0x28,%esp
	  [CRUNNABLE]  "runnable",
	  [CEMBRYO]    "embryo"
	  };
	int i;
  
  	acquire(&ctable.lock);
80104f23:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104f2a:	e8 10 08 00 00       	call   8010573f <acquire>
  	for (i = 0; i < NCONT; i++)
80104f2f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f36:	eb 49                	jmp    80104f81 <contdump+0x64>
  		cprintf("container %d: %s\n", ctable.cont[i].cid, states[ctable.cont[i].state]);
80104f38:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f3b:	89 d0                	mov    %edx,%eax
80104f3d:	01 c0                	add    %eax,%eax
80104f3f:	01 d0                	add    %edx,%eax
80104f41:	c1 e0 04             	shl    $0x4,%eax
80104f44:	05 40 4f 11 80       	add    $0x80114f40,%eax
80104f49:	8b 40 08             	mov    0x8(%eax),%eax
80104f4c:	8b 14 85 24 c0 10 80 	mov    -0x7fef3fdc(,%eax,4),%edx
80104f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f56:	8d 48 01             	lea    0x1(%eax),%ecx
80104f59:	89 c8                	mov    %ecx,%eax
80104f5b:	01 c0                	add    %eax,%eax
80104f5d:	01 c8                	add    %ecx,%eax
80104f5f:	c1 e0 04             	shl    $0x4,%eax
80104f62:	05 00 4f 11 80       	add    $0x80114f00,%eax
80104f67:	8b 40 10             	mov    0x10(%eax),%eax
80104f6a:	89 54 24 08          	mov    %edx,0x8(%esp)
80104f6e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f72:	c7 04 24 63 94 10 80 	movl   $0x80109463,(%esp)
80104f79:	e8 43 b4 ff ff       	call   801003c1 <cprintf>
	  [CEMBRYO]    "embryo"
	  };
	int i;
  
  	acquire(&ctable.lock);
  	for (i = 0; i < NCONT; i++)
80104f7e:	ff 45 f4             	incl   -0xc(%ebp)
80104f81:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80104f85:	7e b1                	jle    80104f38 <contdump+0x1b>
  		cprintf("container %d: %s\n", ctable.cont[i].cid, states[ctable.cont[i].state]);
  	release(&ctable.lock);
80104f87:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104f8e:	e8 16 08 00 00       	call   801057a9 <release>
}
80104f93:	c9                   	leave  
80104f94:	c3                   	ret    

80104f95 <mycont>:

struct cont*
mycont(void) {
80104f95:	55                   	push   %ebp
80104f96:	89 e5                	mov    %esp,%ebp
	return currcont;
80104f98:	a1 b4 50 11 80       	mov    0x801150b4,%eax
}
80104f9d:	5d                   	pop    %ebp
80104f9e:	c3                   	ret    

80104f9f <alloccont>:
// Look in the container table for an CUNUSED cont.
// If found, change state to CEMBRYO
// Otherwise return 0.
static struct cont*
alloccont(void)
{
80104f9f:	55                   	push   %ebp
80104fa0:	89 e5                	mov    %esp,%ebp
80104fa2:	83 ec 28             	sub    $0x28,%esp
	struct cont *c;

	acquire(&ctable.lock);
80104fa5:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104fac:	e8 8e 07 00 00       	call   8010573f <acquire>

	for(c = ctable.cont; c < &ctable.cont[NCONT]; c++)
80104fb1:	c7 45 f4 34 4f 11 80 	movl   $0x80114f34,-0xc(%ebp)
80104fb8:	eb 3e                	jmp    80104ff8 <alloccont+0x59>
		if(c->state == CUNUSED)
80104fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fbd:	8b 40 14             	mov    0x14(%eax),%eax
80104fc0:	85 c0                	test   %eax,%eax
80104fc2:	75 30                	jne    80104ff4 <alloccont+0x55>
		  goto found;
80104fc4:	90                   	nop

	release(&ctable.lock);
	return 0;

found:
	c->state = CEMBRYO;
80104fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc8:	c7 40 14 01 00 00 00 	movl   $0x1,0x14(%eax)
	c->cid = nextcid++;
80104fcf:	a1 20 c0 10 80       	mov    0x8010c020,%eax
80104fd4:	8d 50 01             	lea    0x1(%eax),%edx
80104fd7:	89 15 20 c0 10 80    	mov    %edx,0x8010c020
80104fdd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104fe0:	89 42 0c             	mov    %eax,0xc(%edx)

	release(&ctable.lock);
80104fe3:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104fea:	e8 ba 07 00 00       	call   801057a9 <release>

	return c;
80104fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ff2:	eb 1e                	jmp    80105012 <alloccont+0x73>
{
	struct cont *c;

	acquire(&ctable.lock);

	for(c = ctable.cont; c < &ctable.cont[NCONT]; c++)
80104ff4:	83 45 f4 30          	addl   $0x30,-0xc(%ebp)
80104ff8:	81 7d f4 b4 50 11 80 	cmpl   $0x801150b4,-0xc(%ebp)
80104fff:	72 b9                	jb     80104fba <alloccont+0x1b>
		if(c->state == CUNUSED)
		  goto found;

	release(&ctable.lock);
80105001:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80105008:	e8 9c 07 00 00       	call   801057a9 <release>
	return 0;
8010500d:	b8 00 00 00 00       	mov    $0x0,%eax
	c->cid = nextcid++;

	release(&ctable.lock);

	return c;
}
80105012:	c9                   	leave  
80105013:	c3                   	ret    

80105014 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80105014:	55                   	push   %ebp
80105015:	89 e5                	mov    %esp,%ebp
80105017:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
8010501a:	e8 79 f2 ff ff       	call   80104298 <myproc>
8010501f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  // TODO: Maybe hold ptable lock?
  if(!holding(ctablelock()))
80105022:	e8 c9 fd ff ff       	call   80104df0 <ctablelock>
80105027:	89 04 24             	mov    %eax,(%esp)
8010502a:	e8 3e 08 00 00       	call   8010586d <holding>
8010502f:	85 c0                	test   %eax,%eax
80105031:	75 0c                	jne    8010503f <sched+0x2b>
    panic("sched ctable.lock");
80105033:	c7 04 24 75 94 10 80 	movl   $0x80109475,(%esp)
8010503a:	e8 15 b5 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
8010503f:	e8 df fc ff ff       	call   80104d23 <mycpu>
80105044:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010504a:	83 f8 01             	cmp    $0x1,%eax
8010504d:	74 0c                	je     8010505b <sched+0x47>
    panic("sched locks");
8010504f:	c7 04 24 87 94 10 80 	movl   $0x80109487,(%esp)
80105056:	e8 f9 b4 ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
8010505b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010505e:	8b 40 0c             	mov    0xc(%eax),%eax
80105061:	83 f8 04             	cmp    $0x4,%eax
80105064:	75 0c                	jne    80105072 <sched+0x5e>
    panic("sched running");
80105066:	c7 04 24 93 94 10 80 	movl   $0x80109493,(%esp)
8010506d:	e8 e2 b4 ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80105072:	e8 51 fc ff ff       	call   80104cc8 <readeflags>
80105077:	25 00 02 00 00       	and    $0x200,%eax
8010507c:	85 c0                	test   %eax,%eax
8010507e:	74 0c                	je     8010508c <sched+0x78>
    panic("sched interruptible");
80105080:	c7 04 24 a1 94 10 80 	movl   $0x801094a1,(%esp)
80105087:	e8 c8 b4 ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
8010508c:	e8 92 fc ff ff       	call   80104d23 <mycpu>
80105091:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105097:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
8010509a:	e8 84 fc ff ff       	call   80104d23 <mycpu>
8010509f:	8b 40 04             	mov    0x4(%eax),%eax
801050a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050a5:	83 c2 1c             	add    $0x1c,%edx
801050a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801050ac:	89 14 24             	mov    %edx,(%esp)
801050af:	e8 68 0b 00 00       	call   80105c1c <swtch>
  mycpu()->intena = intena;
801050b4:	e8 6a fc ff ff       	call   80104d23 <mycpu>
801050b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801050bc:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801050c2:	c9                   	leave  
801050c3:	c3                   	ret    

801050c4 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801050c4:	55                   	push   %ebp
801050c5:	89 e5                	mov    %esp,%ebp
801050c7:	83 ec 38             	sub    $0x38,%esp
  struct proc *p;
  struct cont *cont;
  struct cpu *c = mycpu();
801050ca:	e8 54 fc ff ff       	call   80104d23 <mycpu>
801050cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i, k;
  c->proc = 0;
801050d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801050d5:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801050dc:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801050df:	e8 f4 fb ff ff       	call   80104cd8 <sti>
    cprintf("running scheduler\n");
801050e4:	c7 04 24 b5 94 10 80 	movl   $0x801094b5,(%esp)
801050eb:	e8 d1 b2 ff ff       	call   801003c1 <cprintf>
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801050f0:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
801050f7:	e8 43 06 00 00       	call   8010573f <acquire>
    // TODO: do we need to acquire ctable lock too?

	// TODO: Check that scheulde cycles over ctable equally    
    for(i = 0; i < NCONT; i++) {
801050fc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105103:	e9 d5 00 00 00       	jmp    801051dd <scheduler+0x119>

      cont = &ctable.cont[i];
80105108:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010510b:	8d 50 01             	lea    0x1(%eax),%edx
8010510e:	89 d0                	mov    %edx,%eax
80105110:	01 c0                	add    %eax,%eax
80105112:	01 d0                	add    %edx,%eax
80105114:	c1 e0 04             	shl    $0x4,%eax
80105117:	05 00 4f 11 80       	add    $0x80114f00,%eax
8010511c:	83 c0 04             	add    $0x4,%eax
8010511f:	89 45 e8             	mov    %eax,-0x18(%ebp)

      if (cont->state != CRUNNABLE)
80105122:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105125:	8b 40 14             	mov    0x14(%eax),%eax
80105128:	83 f8 02             	cmp    $0x2,%eax
8010512b:	74 05                	je     80105132 <scheduler+0x6e>
      	continue;      
8010512d:	e9 a8 00 00 00       	jmp    801051da <scheduler+0x116>

      for (k = (cont->nextproc % cont->mproc); k < cont->mproc; k++) {
80105132:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105135:	8b 40 2c             	mov    0x2c(%eax),%eax
80105138:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010513b:	8b 4a 08             	mov    0x8(%edx),%ecx
8010513e:	99                   	cltd   
8010513f:	f7 f9                	idiv   %ecx
80105141:	89 55 f0             	mov    %edx,-0x10(%ebp)
80105144:	e9 82 00 00 00       	jmp    801051cb <scheduler+0x107>
      	
      	  p = &cont->ptable[k]; 
80105149:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010514c:	8b 50 28             	mov    0x28(%eax),%edx
8010514f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105152:	c1 e0 02             	shl    $0x2,%eax
80105155:	89 c1                	mov    %eax,%ecx
80105157:	c1 e1 05             	shl    $0x5,%ecx
8010515a:	01 c8                	add    %ecx,%eax
8010515c:	01 d0                	add    %edx,%eax
8010515e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

      	  cont->nextproc = cont->nextproc + 1;
80105161:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105164:	8b 40 2c             	mov    0x2c(%eax),%eax
80105167:	8d 50 01             	lea    0x1(%eax),%edx
8010516a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010516d:	89 50 2c             	mov    %edx,0x2c(%eax)

	      if(p->state != RUNNABLE)
80105170:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105173:	8b 40 0c             	mov    0xc(%eax),%eax
80105176:	83 f8 03             	cmp    $0x3,%eax
80105179:	74 02                	je     8010517d <scheduler+0xb9>
	        continue;
8010517b:	eb 4b                	jmp    801051c8 <scheduler+0x104>

	      // Switch to chosen process.  It is the process's job
	      // to release ctable.lock and then reacquire it
	      // before jumping back to us.
	      c->proc = p;
8010517d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105180:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105183:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
	      switchuvm(p);
80105189:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010518c:	89 04 24             	mov    %eax,(%esp)
8010518f:	e8 e4 35 00 00       	call   80108778 <switchuvm>
	      p->state = RUNNING;
80105194:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105197:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

	      swtch(&(c->scheduler), p->context);
8010519e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801051a1:	8b 40 1c             	mov    0x1c(%eax),%eax
801051a4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801051a7:	83 c2 04             	add    $0x4,%edx
801051aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801051ae:	89 14 24             	mov    %edx,(%esp)
801051b1:	e8 66 0a 00 00       	call   80105c1c <swtch>
	      switchkvm();
801051b6:	e8 a3 35 00 00       	call   8010875e <switchkvm>

	      // Process is done running for now.
	      // It should have changed its p->state before coming back.
	      c->proc = 0;
801051bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801051be:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801051c5:	00 00 00 
      cont = &ctable.cont[i];

      if (cont->state != CRUNNABLE)
      	continue;      

      for (k = (cont->nextproc % cont->mproc); k < cont->mproc; k++) {
801051c8:	ff 45 f0             	incl   -0x10(%ebp)
801051cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801051ce:	8b 40 08             	mov    0x8(%eax),%eax
801051d1:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801051d4:	0f 8f 6f ff ff ff    	jg     80105149 <scheduler+0x85>
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    // TODO: do we need to acquire ctable lock too?

	// TODO: Check that scheulde cycles over ctable equally    
    for(i = 0; i < NCONT; i++) {
801051da:	ff 45 f4             	incl   -0xc(%ebp)
801051dd:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801051e1:	0f 8e 21 ff ff ff    	jle    80105108 <scheduler+0x44>
	      // Process is done running for now.
	      // It should have changed its p->state before coming back.
	      c->proc = 0;
	  }
    }
    release(&ptable.lock);
801051e7:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
801051ee:	e8 b6 05 00 00       	call   801057a9 <release>

  }
801051f3:	e9 e7 fe ff ff       	jmp    801050df <scheduler+0x1b>

801051f8 <movefile>:
}

/* Moves file src to folder dst 
TODO: Implement */
int
movefile(char* dst, char* src) {
801051f8:	55                   	push   %ebp
801051f9:	89 e5                	mov    %esp,%ebp
801051fb:	57                   	push   %edi
801051fc:	56                   	push   %esi
801051fd:	53                   	push   %ebx
801051fe:	83 ec 2c             	sub    $0x2c,%esp
80105201:	89 e0                	mov    %esp,%eax
80105203:	89 c6                	mov    %eax,%esi
	
	int pathsize = sizeof(dst) + sizeof(src) + 2; // dst.len + '\' + src.len + \0
80105205:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
	char path[pathsize]; 
8010520c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010520f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105212:	89 55 e0             	mov    %edx,-0x20(%ebp)
80105215:	ba 10 00 00 00       	mov    $0x10,%edx
8010521a:	4a                   	dec    %edx
8010521b:	01 d0                	add    %edx,%eax
8010521d:	b9 10 00 00 00       	mov    $0x10,%ecx
80105222:	ba 00 00 00 00       	mov    $0x0,%edx
80105227:	f7 f1                	div    %ecx
80105229:	6b c0 10             	imul   $0x10,%eax,%eax
8010522c:	29 c4                	sub    %eax,%esp
8010522e:	8d 44 24 0c          	lea    0xc(%esp),%eax
80105232:	83 c0 00             	add    $0x0,%eax
80105235:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// struct file *f;
	// struct inode *ip;

	memmove(path, dst, strlen(dst));
80105238:	8b 45 08             	mov    0x8(%ebp),%eax
8010523b:	89 04 24             	mov    %eax,(%esp)
8010523e:	e8 b2 09 00 00       	call   80105bf5 <strlen>
80105243:	89 c2                	mov    %eax,%edx
80105245:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105248:	89 54 24 08          	mov    %edx,0x8(%esp)
8010524c:	8b 55 08             	mov    0x8(%ebp),%edx
8010524f:	89 54 24 04          	mov    %edx,0x4(%esp)
80105253:	89 04 24             	mov    %eax,(%esp)
80105256:	e8 10 08 00 00       	call   80105a6b <memmove>
	memmove(path + strlen(dst), "/", 1);
8010525b:	8b 5d dc             	mov    -0x24(%ebp),%ebx
8010525e:	8b 45 08             	mov    0x8(%ebp),%eax
80105261:	89 04 24             	mov    %eax,(%esp)
80105264:	e8 8c 09 00 00       	call   80105bf5 <strlen>
80105269:	01 d8                	add    %ebx,%eax
8010526b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80105272:	00 
80105273:	c7 44 24 04 45 94 10 	movl   $0x80109445,0x4(%esp)
8010527a:	80 
8010527b:	89 04 24             	mov    %eax,(%esp)
8010527e:	e8 e8 07 00 00       	call   80105a6b <memmove>
	memmove(path + strlen(dst) + 1, src, strlen(src));
80105283:	8b 45 0c             	mov    0xc(%ebp),%eax
80105286:	89 04 24             	mov    %eax,(%esp)
80105289:	e8 67 09 00 00       	call   80105bf5 <strlen>
8010528e:	89 c3                	mov    %eax,%ebx
80105290:	8b 7d dc             	mov    -0x24(%ebp),%edi
80105293:	8b 45 08             	mov    0x8(%ebp),%eax
80105296:	89 04 24             	mov    %eax,(%esp)
80105299:	e8 57 09 00 00       	call   80105bf5 <strlen>
8010529e:	40                   	inc    %eax
8010529f:	8d 14 07             	lea    (%edi,%eax,1),%edx
801052a2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801052a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801052a9:	89 44 24 04          	mov    %eax,0x4(%esp)
801052ad:	89 14 24             	mov    %edx,(%esp)
801052b0:	e8 b6 07 00 00       	call   80105a6b <memmove>
	memmove(path + strlen(dst) + 1 + strlen(src), "\0", 1);
801052b5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
801052b8:	8b 45 08             	mov    0x8(%ebp),%eax
801052bb:	89 04 24             	mov    %eax,(%esp)
801052be:	e8 32 09 00 00       	call   80105bf5 <strlen>
801052c3:	89 c7                	mov    %eax,%edi
801052c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801052c8:	89 04 24             	mov    %eax,(%esp)
801052cb:	e8 25 09 00 00       	call   80105bf5 <strlen>
801052d0:	01 f8                	add    %edi,%eax
801052d2:	40                   	inc    %eax
801052d3:	01 d8                	add    %ebx,%eax
801052d5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801052dc:	00 
801052dd:	c7 44 24 04 c8 94 10 	movl   $0x801094c8,0x4(%esp)
801052e4:	80 
801052e5:	89 04 24             	mov    %eax,(%esp)
801052e8:	e8 7e 07 00 00       	call   80105a6b <memmove>

	cprintf("movefile path: %s\n", path);
801052ed:	8b 45 dc             	mov    -0x24(%ebp),%eax
801052f0:	89 44 24 04          	mov    %eax,0x4(%esp)
801052f4:	c7 04 24 ca 94 10 80 	movl   $0x801094ca,(%esp)
801052fb:	e8 c1 b0 ff ff       	call   801003c1 <cprintf>
	// // Copy contents of src into new file
	// char* source;
	// fileread();	


	return 1;
80105300:	b8 01 00 00 00       	mov    $0x1,%eax
80105305:	89 f4                	mov    %esi,%esp
}
80105307:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010530a:	5b                   	pop    %ebx
8010530b:	5e                   	pop    %esi
8010530c:	5f                   	pop    %edi
8010530d:	5d                   	pop    %ebp
8010530e:	c3                   	ret    

8010530f <ccreate>:

// TODO: Block processes inside non root containers from ccreating
int 
ccreate(char* name, char* progv[MAXARG], int progc, int mproc, uint msz, uint mdsk)
{
8010530f:	55                   	push   %ebp
80105310:	89 e5                	mov    %esp,%ebp
80105312:	83 ec 28             	sub    $0x28,%esp
	int i;
	struct cont *nc;
	struct inode *rootdir;

	// Allocate container.
	if ((nc = alloccont()) == 0) {
80105315:	e8 85 fc ff ff       	call   80104f9f <alloccont>
8010531a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010531d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105321:	75 0a                	jne    8010532d <ccreate+0x1e>
		return -1;
80105323:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105328:	e9 39 01 00 00       	jmp    80105466 <ccreate+0x157>
	}

	// Create a directory (same implementation as sys_mkdir)	
	begin_op();
8010532d:	e8 69 e3 ff ff       	call   8010369b <begin_op>
	if((rootdir = create(name, T_DIR, 0, 0)) == 0){
80105332:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80105339:	00 
8010533a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105341:	00 
80105342:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105349:	00 
8010534a:	8b 45 08             	mov    0x8(%ebp),%eax
8010534d:	89 04 24             	mov    %eax,(%esp)
80105350:	e8 52 11 00 00       	call   801064a7 <create>
80105355:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105358:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010535c:	75 22                	jne    80105380 <ccreate+0x71>
		end_op();
8010535e:	e8 ba e3 ff ff       	call   8010371d <end_op>
		cprintf("Unable to create container directory %s\n", name);
80105363:	8b 45 08             	mov    0x8(%ebp),%eax
80105366:	89 44 24 04          	mov    %eax,0x4(%esp)
8010536a:	c7 04 24 e0 94 10 80 	movl   $0x801094e0,(%esp)
80105371:	e8 4b b0 ff ff       	call   801003c1 <cprintf>
		return -1;
80105376:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010537b:	e9 e6 00 00 00       	jmp    80105466 <ccreate+0x157>
	}
	iunlockput(rootdir);
80105380:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105383:	89 04 24             	mov    %eax,(%esp)
80105386:	e8 9a c8 ff ff       	call   80101c25 <iunlockput>
	end_op();	
8010538b:	e8 8d e3 ff ff       	call   8010371d <end_op>

	// Move files into folder
	for (i = 0; i < progc; i++) {
80105390:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105397:	eb 48                	jmp    801053e1 <ccreate+0xd2>
		if (movefile(name, progv[i]) == 0) 
80105399:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010539c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801053a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801053a6:	01 d0                	add    %edx,%eax
801053a8:	8b 00                	mov    (%eax),%eax
801053aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801053ae:	8b 45 08             	mov    0x8(%ebp),%eax
801053b1:	89 04 24             	mov    %eax,(%esp)
801053b4:	e8 3f fe ff ff       	call   801051f8 <movefile>
801053b9:	85 c0                	test   %eax,%eax
801053bb:	75 21                	jne    801053de <ccreate+0xcf>
			cprintf("Unable to move file %s\n", progv[i]);
801053bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053c0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801053c7:	8b 45 0c             	mov    0xc(%ebp),%eax
801053ca:	01 d0                	add    %edx,%eax
801053cc:	8b 00                	mov    (%eax),%eax
801053ce:	89 44 24 04          	mov    %eax,0x4(%esp)
801053d2:	c7 04 24 09 95 10 80 	movl   $0x80109509,(%esp)
801053d9:	e8 e3 af ff ff       	call   801003c1 <cprintf>
	}
	iunlockput(rootdir);
	end_op();	

	// Move files into folder
	for (i = 0; i < progc; i++) {
801053de:	ff 45 f4             	incl   -0xc(%ebp)
801053e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053e4:	3b 45 10             	cmp    0x10(%ebp),%eax
801053e7:	7c b0                	jl     80105399 <ccreate+0x8a>
		if (movefile(name, progv[i]) == 0) 
			cprintf("Unable to move file %s\n", progv[i]);
	}

	acquire(&ctable.lock);
801053e9:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
801053f0:	e8 4a 03 00 00       	call   8010573f <acquire>
	nc->mproc = mproc;
801053f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053f8:	8b 55 14             	mov    0x14(%ebp),%edx
801053fb:	89 50 08             	mov    %edx,0x8(%eax)
	nc->msz = msz;
801053fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105401:	8b 55 18             	mov    0x18(%ebp),%edx
80105404:	89 10                	mov    %edx,(%eax)
	nc->mdsk = mdsk;
80105406:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105409:	8b 55 1c             	mov    0x1c(%ebp),%edx
8010540c:	89 50 04             	mov    %edx,0x4(%eax)
	nc->rootdir = rootdir;	
8010540f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105412:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105415:	89 50 10             	mov    %edx,0x10(%eax)
	strncpy(nc->name, name, 16);	
80105418:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010541b:	8d 50 18             	lea    0x18(%eax),%edx
8010541e:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80105425:	00 
80105426:	8b 45 08             	mov    0x8(%ebp),%eax
80105429:	89 44 24 04          	mov    %eax,0x4(%esp)
8010542d:	89 14 24             	mov    %edx,(%esp)
80105430:	e8 23 07 00 00       	call   80105b58 <strncpy>
	nc->state = CRUNNABLE;	
80105435:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105438:	c7 40 14 02 00 00 00 	movl   $0x2,0x14(%eax)
	release(&ctable.lock);	
8010543f:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80105446:	e8 5e 03 00 00       	call   801057a9 <release>

	cprintf("inited container %s\n", nc->name);
8010544b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010544e:	83 c0 18             	add    $0x18,%eax
80105451:	89 44 24 04          	mov    %eax,0x4(%esp)
80105455:	c7 04 24 21 95 10 80 	movl   $0x80109521,(%esp)
8010545c:	e8 60 af ff ff       	call   801003c1 <cprintf>

	return 1;  
80105461:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105466:	c9                   	leave  
80105467:	c3                   	ret    

80105468 <cstart>:

// Allocates a process for the table "name"
// Runs argv[0] (argv is program plus arguments)
int
cstart(char* name, char** argv, int argc) 
{	
80105468:	55                   	push   %ebp
80105469:	89 e5                	mov    %esp,%ebp
8010546b:	83 ec 28             	sub    $0x28,%esp
	cprintf("Cstart\n");
8010546e:	c7 04 24 36 95 10 80 	movl   $0x80109536,(%esp)
80105475:	e8 47 af ff ff       	call   801003c1 <cprintf>
	struct cpu *cpu;
	struct proc *p;
	int i;

	// Find container
	acquire(&ctable.lock);
8010547a:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80105481:	e8 b9 02 00 00       	call   8010573f <acquire>

	for (i = 0; i < NCONT; i++) {
80105486:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010548d:	e9 2f 01 00 00       	jmp    801055c1 <cstart+0x159>
		c = &ctable.cont[i];
80105492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105495:	8d 50 01             	lea    0x1(%eax),%edx
80105498:	89 d0                	mov    %edx,%eax
8010549a:	01 c0                	add    %eax,%eax
8010549c:	01 d0                	add    %edx,%eax
8010549e:	c1 e0 04             	shl    $0x4,%eax
801054a1:	05 00 4f 11 80       	add    $0x80114f00,%eax
801054a6:	83 c0 04             	add    $0x4,%eax
801054a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
		// TODO: Check if this works
		if (strncmp(name, c->name, strlen(name)) == 0 && c->state == CRUNNABLE)
801054ac:	8b 45 08             	mov    0x8(%ebp),%eax
801054af:	89 04 24             	mov    %eax,(%esp)
801054b2:	e8 3e 07 00 00       	call   80105bf5 <strlen>
801054b7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801054ba:	83 c2 18             	add    $0x18,%edx
801054bd:	89 44 24 08          	mov    %eax,0x8(%esp)
801054c1:	89 54 24 04          	mov    %edx,0x4(%esp)
801054c5:	8b 45 08             	mov    0x8(%ebp),%eax
801054c8:	89 04 24             	mov    %eax,(%esp)
801054cb:	e8 3a 06 00 00       	call   80105b0a <strncmp>
801054d0:	85 c0                	test   %eax,%eax
801054d2:	0f 85 e6 00 00 00    	jne    801055be <cstart+0x156>
801054d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054db:	8b 40 14             	mov    0x14(%eax),%eax
801054de:	83 f8 02             	cmp    $0x2,%eax
801054e1:	0f 85 d7 00 00 00    	jne    801055be <cstart+0x156>
			goto found;
801054e7:	90                   	nop
	release(&ctable.lock);
	return -1;

found: 	

	cprintf("\tFound container to run (%s)\n", c->name);
801054e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054eb:	83 c0 18             	add    $0x18,%eax
801054ee:	89 44 24 04          	mov    %eax,0x4(%esp)
801054f2:	c7 04 24 3e 95 10 80 	movl   $0x8010953e,(%esp)
801054f9:	e8 c3 ae ff ff       	call   801003c1 <cprintf>

	// TODO: Attach to a vc

	p = initprocess(c, argv[0], 0);
801054fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80105501:	8b 00                	mov    (%eax),%eax
80105503:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010550a:	00 
8010550b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010550f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105512:	89 04 24             	mov    %eax,(%esp)
80105515:	e8 d4 ee ff ff       	call   801043ee <initprocess>
8010551a:	89 45 ec             	mov    %eax,-0x14(%ebp)

	cprintf("\tInit first process\n");	
8010551d:	c7 04 24 5c 95 10 80 	movl   $0x8010955c,(%esp)
80105524:	e8 98 ae ff ff       	call   801003c1 <cprintf>
	cprintf("\t\t/ctest1 is equal to this container's inode %d\n", (namei("/ctest1")->inum == c->rootdir->inum));
80105529:	c7 04 24 71 95 10 80 	movl   $0x80109571,(%esp)
80105530:	e8 91 d1 ff ff       	call   801026c6 <namei>
80105535:	8b 50 04             	mov    0x4(%eax),%edx
80105538:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010553b:	8b 40 10             	mov    0x10(%eax),%eax
8010553e:	8b 40 04             	mov    0x4(%eax),%eax
80105541:	39 c2                	cmp    %eax,%edx
80105543:	0f 94 c0             	sete   %al
80105546:	0f b6 c0             	movzbl %al,%eax
80105549:	89 44 24 04          	mov    %eax,0x4(%esp)
8010554d:	c7 04 24 7c 95 10 80 	movl   $0x8010957c,(%esp)
80105554:	e8 68 ae ff ff       	call   801003c1 <cprintf>

	cpu = mycpu();	
80105559:	e8 c5 f7 ff ff       	call   80104d23 <mycpu>
8010555e:	89 45 e8             	mov    %eax,-0x18(%ebp)

	// TODO: Check: Acquire ptable?
	// Exec process
	cpu->proc = p;
80105561:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105564:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105567:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
	cprintf("execing proc %s with argv[1] %s\n", argv[0], argv[1]);
8010556d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105570:	83 c0 04             	add    $0x4,%eax
80105573:	8b 10                	mov    (%eax),%edx
80105575:	8b 45 0c             	mov    0xc(%ebp),%eax
80105578:	8b 00                	mov    (%eax),%eax
8010557a:	89 54 24 08          	mov    %edx,0x8(%esp)
8010557e:	89 44 24 04          	mov    %eax,0x4(%esp)
80105582:	c7 04 24 b0 95 10 80 	movl   $0x801095b0,(%esp)
80105589:	e8 33 ae ff ff       	call   801003c1 <cprintf>
	// TODO: CHANGE TO ARGV[0]
	exec("echoloop", argv); 	
8010558e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105591:	89 44 24 04          	mov    %eax,0x4(%esp)
80105595:	c7 04 24 d1 95 10 80 	movl   $0x801095d1,(%esp)
8010559c:	e8 67 b6 ff ff       	call   80100c08 <exec>
	
	c->state = CRUNNING;	
801055a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055a4:	c7 40 14 04 00 00 00 	movl   $0x4,0x14(%eax)

	release(&ctable.lock);	
801055ab:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
801055b2:	e8 f2 01 00 00       	call   801057a9 <release>

	return 1;
801055b7:	b8 01 00 00 00       	mov    $0x1,%eax
801055bc:	eb 1e                	jmp    801055dc <cstart+0x174>
	int i;

	// Find container
	acquire(&ctable.lock);

	for (i = 0; i < NCONT; i++) {
801055be:	ff 45 f4             	incl   -0xc(%ebp)
801055c1:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
801055c5:	0f 8e c7 fe ff ff    	jle    80105492 <cstart+0x2a>
		// TODO: Check if this works
		if (strncmp(name, c->name, strlen(name)) == 0 && c->state == CRUNNABLE)
			goto found;
	}

	release(&ctable.lock);
801055cb:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
801055d2:	e8 d2 01 00 00       	call   801057a9 <release>
	return -1;
801055d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	c->state = CRUNNING;	

	release(&ctable.lock);	

	return 1;
}
801055dc:	c9                   	leave  
801055dd:	c3                   	ret    
	...

801055e0 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801055e0:	55                   	push   %ebp
801055e1:	89 e5                	mov    %esp,%ebp
801055e3:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
801055e6:	8b 45 08             	mov    0x8(%ebp),%eax
801055e9:	83 c0 04             	add    $0x4,%eax
801055ec:	c7 44 24 04 00 96 10 	movl   $0x80109600,0x4(%esp)
801055f3:	80 
801055f4:	89 04 24             	mov    %eax,(%esp)
801055f7:	e8 22 01 00 00       	call   8010571e <initlock>
  lk->name = name;
801055fc:	8b 45 08             	mov    0x8(%ebp),%eax
801055ff:	8b 55 0c             	mov    0xc(%ebp),%edx
80105602:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105605:	8b 45 08             	mov    0x8(%ebp),%eax
80105608:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010560e:	8b 45 08             	mov    0x8(%ebp),%eax
80105611:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105618:	c9                   	leave  
80105619:	c3                   	ret    

8010561a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010561a:	55                   	push   %ebp
8010561b:	89 e5                	mov    %esp,%ebp
8010561d:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80105620:	8b 45 08             	mov    0x8(%ebp),%eax
80105623:	83 c0 04             	add    $0x4,%eax
80105626:	89 04 24             	mov    %eax,(%esp)
80105629:	e8 11 01 00 00       	call   8010573f <acquire>
  while (lk->locked) {
8010562e:	eb 15                	jmp    80105645 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80105630:	8b 45 08             	mov    0x8(%ebp),%eax
80105633:	83 c0 04             	add    $0x4,%eax
80105636:	89 44 24 04          	mov    %eax,0x4(%esp)
8010563a:	8b 45 08             	mov    0x8(%ebp),%eax
8010563d:	89 04 24             	mov    %eax,(%esp)
80105640:	e8 99 f3 ff ff       	call   801049de <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80105645:	8b 45 08             	mov    0x8(%ebp),%eax
80105648:	8b 00                	mov    (%eax),%eax
8010564a:	85 c0                	test   %eax,%eax
8010564c:	75 e2                	jne    80105630 <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
8010564e:	8b 45 08             	mov    0x8(%ebp),%eax
80105651:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80105657:	e8 3c ec ff ff       	call   80104298 <myproc>
8010565c:	8b 50 10             	mov    0x10(%eax),%edx
8010565f:	8b 45 08             	mov    0x8(%ebp),%eax
80105662:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105665:	8b 45 08             	mov    0x8(%ebp),%eax
80105668:	83 c0 04             	add    $0x4,%eax
8010566b:	89 04 24             	mov    %eax,(%esp)
8010566e:	e8 36 01 00 00       	call   801057a9 <release>
}
80105673:	c9                   	leave  
80105674:	c3                   	ret    

80105675 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105675:	55                   	push   %ebp
80105676:	89 e5                	mov    %esp,%ebp
80105678:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
8010567b:	8b 45 08             	mov    0x8(%ebp),%eax
8010567e:	83 c0 04             	add    $0x4,%eax
80105681:	89 04 24             	mov    %eax,(%esp)
80105684:	e8 b6 00 00 00       	call   8010573f <acquire>
  lk->locked = 0;
80105689:	8b 45 08             	mov    0x8(%ebp),%eax
8010568c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105692:	8b 45 08             	mov    0x8(%ebp),%eax
80105695:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
8010569c:	8b 45 08             	mov    0x8(%ebp),%eax
8010569f:	89 04 24             	mov    %eax,(%esp)
801056a2:	e8 25 f4 ff ff       	call   80104acc <wakeup>
  release(&lk->lk);
801056a7:	8b 45 08             	mov    0x8(%ebp),%eax
801056aa:	83 c0 04             	add    $0x4,%eax
801056ad:	89 04 24             	mov    %eax,(%esp)
801056b0:	e8 f4 00 00 00       	call   801057a9 <release>
}
801056b5:	c9                   	leave  
801056b6:	c3                   	ret    

801056b7 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801056b7:	55                   	push   %ebp
801056b8:	89 e5                	mov    %esp,%ebp
801056ba:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
801056bd:	8b 45 08             	mov    0x8(%ebp),%eax
801056c0:	83 c0 04             	add    $0x4,%eax
801056c3:	89 04 24             	mov    %eax,(%esp)
801056c6:	e8 74 00 00 00       	call   8010573f <acquire>
  r = lk->locked;
801056cb:	8b 45 08             	mov    0x8(%ebp),%eax
801056ce:	8b 00                	mov    (%eax),%eax
801056d0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801056d3:	8b 45 08             	mov    0x8(%ebp),%eax
801056d6:	83 c0 04             	add    $0x4,%eax
801056d9:	89 04 24             	mov    %eax,(%esp)
801056dc:	e8 c8 00 00 00       	call   801057a9 <release>
  return r;
801056e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801056e4:	c9                   	leave  
801056e5:	c3                   	ret    
	...

801056e8 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801056e8:	55                   	push   %ebp
801056e9:	89 e5                	mov    %esp,%ebp
801056eb:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801056ee:	9c                   	pushf  
801056ef:	58                   	pop    %eax
801056f0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801056f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801056f6:	c9                   	leave  
801056f7:	c3                   	ret    

801056f8 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801056f8:	55                   	push   %ebp
801056f9:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801056fb:	fa                   	cli    
}
801056fc:	5d                   	pop    %ebp
801056fd:	c3                   	ret    

801056fe <sti>:

static inline void
sti(void)
{
801056fe:	55                   	push   %ebp
801056ff:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105701:	fb                   	sti    
}
80105702:	5d                   	pop    %ebp
80105703:	c3                   	ret    

80105704 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105704:	55                   	push   %ebp
80105705:	89 e5                	mov    %esp,%ebp
80105707:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010570a:	8b 55 08             	mov    0x8(%ebp),%edx
8010570d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105710:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105713:	f0 87 02             	lock xchg %eax,(%edx)
80105716:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105719:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010571c:	c9                   	leave  
8010571d:	c3                   	ret    

8010571e <initlock>:
#include "container.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010571e:	55                   	push   %ebp
8010571f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105721:	8b 45 08             	mov    0x8(%ebp),%eax
80105724:	8b 55 0c             	mov    0xc(%ebp),%edx
80105727:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010572a:	8b 45 08             	mov    0x8(%ebp),%eax
8010572d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105733:	8b 45 08             	mov    0x8(%ebp),%eax
80105736:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010573d:	5d                   	pop    %ebp
8010573e:	c3                   	ret    

8010573f <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010573f:	55                   	push   %ebp
80105740:	89 e5                	mov    %esp,%ebp
80105742:	53                   	push   %ebx
80105743:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105746:	e8 53 01 00 00       	call   8010589e <pushcli>
  if(holding(lk))
8010574b:	8b 45 08             	mov    0x8(%ebp),%eax
8010574e:	89 04 24             	mov    %eax,(%esp)
80105751:	e8 17 01 00 00       	call   8010586d <holding>
80105756:	85 c0                	test   %eax,%eax
80105758:	74 0c                	je     80105766 <acquire+0x27>
    panic("acquire");
8010575a:	c7 04 24 0b 96 10 80 	movl   $0x8010960b,(%esp)
80105761:	e8 ee ad ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105766:	90                   	nop
80105767:	8b 45 08             	mov    0x8(%ebp),%eax
8010576a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105771:	00 
80105772:	89 04 24             	mov    %eax,(%esp)
80105775:	e8 8a ff ff ff       	call   80105704 <xchg>
8010577a:	85 c0                	test   %eax,%eax
8010577c:	75 e9                	jne    80105767 <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010577e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105783:	8b 5d 08             	mov    0x8(%ebp),%ebx
80105786:	e8 98 f5 ff ff       	call   80104d23 <mycpu>
8010578b:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
8010578e:	8b 45 08             	mov    0x8(%ebp),%eax
80105791:	83 c0 0c             	add    $0xc,%eax
80105794:	89 44 24 04          	mov    %eax,0x4(%esp)
80105798:	8d 45 08             	lea    0x8(%ebp),%eax
8010579b:	89 04 24             	mov    %eax,(%esp)
8010579e:	e8 53 00 00 00       	call   801057f6 <getcallerpcs>
}
801057a3:	83 c4 14             	add    $0x14,%esp
801057a6:	5b                   	pop    %ebx
801057a7:	5d                   	pop    %ebp
801057a8:	c3                   	ret    

801057a9 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801057a9:	55                   	push   %ebp
801057aa:	89 e5                	mov    %esp,%ebp
801057ac:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
801057af:	8b 45 08             	mov    0x8(%ebp),%eax
801057b2:	89 04 24             	mov    %eax,(%esp)
801057b5:	e8 b3 00 00 00       	call   8010586d <holding>
801057ba:	85 c0                	test   %eax,%eax
801057bc:	75 0c                	jne    801057ca <release+0x21>
    panic("release");
801057be:	c7 04 24 13 96 10 80 	movl   $0x80109613,(%esp)
801057c5:	e8 8a ad ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
801057ca:	8b 45 08             	mov    0x8(%ebp),%eax
801057cd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801057d4:	8b 45 08             	mov    0x8(%ebp),%eax
801057d7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801057de:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801057e3:	8b 45 08             	mov    0x8(%ebp),%eax
801057e6:	8b 55 08             	mov    0x8(%ebp),%edx
801057e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801057ef:	e8 f4 00 00 00       	call   801058e8 <popcli>
}
801057f4:	c9                   	leave  
801057f5:	c3                   	ret    

801057f6 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801057f6:	55                   	push   %ebp
801057f7:	89 e5                	mov    %esp,%ebp
801057f9:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801057fc:	8b 45 08             	mov    0x8(%ebp),%eax
801057ff:	83 e8 08             	sub    $0x8,%eax
80105802:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105805:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010580c:	eb 37                	jmp    80105845 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010580e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105812:	74 37                	je     8010584b <getcallerpcs+0x55>
80105814:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010581b:	76 2e                	jbe    8010584b <getcallerpcs+0x55>
8010581d:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105821:	74 28                	je     8010584b <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105823:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105826:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010582d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105830:	01 c2                	add    %eax,%edx
80105832:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105835:	8b 40 04             	mov    0x4(%eax),%eax
80105838:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010583a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010583d:	8b 00                	mov    (%eax),%eax
8010583f:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105842:	ff 45 f8             	incl   -0x8(%ebp)
80105845:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105849:	7e c3                	jle    8010580e <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010584b:	eb 18                	jmp    80105865 <getcallerpcs+0x6f>
    pcs[i] = 0;
8010584d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105850:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105857:	8b 45 0c             	mov    0xc(%ebp),%eax
8010585a:	01 d0                	add    %edx,%eax
8010585c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105862:	ff 45 f8             	incl   -0x8(%ebp)
80105865:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105869:	7e e2                	jle    8010584d <getcallerpcs+0x57>
    pcs[i] = 0;
}
8010586b:	c9                   	leave  
8010586c:	c3                   	ret    

8010586d <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010586d:	55                   	push   %ebp
8010586e:	89 e5                	mov    %esp,%ebp
80105870:	53                   	push   %ebx
80105871:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80105874:	8b 45 08             	mov    0x8(%ebp),%eax
80105877:	8b 00                	mov    (%eax),%eax
80105879:	85 c0                	test   %eax,%eax
8010587b:	74 16                	je     80105893 <holding+0x26>
8010587d:	8b 45 08             	mov    0x8(%ebp),%eax
80105880:	8b 58 08             	mov    0x8(%eax),%ebx
80105883:	e8 9b f4 ff ff       	call   80104d23 <mycpu>
80105888:	39 c3                	cmp    %eax,%ebx
8010588a:	75 07                	jne    80105893 <holding+0x26>
8010588c:	b8 01 00 00 00       	mov    $0x1,%eax
80105891:	eb 05                	jmp    80105898 <holding+0x2b>
80105893:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105898:	83 c4 04             	add    $0x4,%esp
8010589b:	5b                   	pop    %ebx
8010589c:	5d                   	pop    %ebp
8010589d:	c3                   	ret    

8010589e <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
8010589e:	55                   	push   %ebp
8010589f:	89 e5                	mov    %esp,%ebp
801058a1:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801058a4:	e8 3f fe ff ff       	call   801056e8 <readeflags>
801058a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801058ac:	e8 47 fe ff ff       	call   801056f8 <cli>
  if(mycpu()->ncli == 0)
801058b1:	e8 6d f4 ff ff       	call   80104d23 <mycpu>
801058b6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801058bc:	85 c0                	test   %eax,%eax
801058be:	75 14                	jne    801058d4 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801058c0:	e8 5e f4 ff ff       	call   80104d23 <mycpu>
801058c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058c8:	81 e2 00 02 00 00    	and    $0x200,%edx
801058ce:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801058d4:	e8 4a f4 ff ff       	call   80104d23 <mycpu>
801058d9:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801058df:	42                   	inc    %edx
801058e0:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801058e6:	c9                   	leave  
801058e7:	c3                   	ret    

801058e8 <popcli>:

void
popcli(void)
{
801058e8:	55                   	push   %ebp
801058e9:	89 e5                	mov    %esp,%ebp
801058eb:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
801058ee:	e8 f5 fd ff ff       	call   801056e8 <readeflags>
801058f3:	25 00 02 00 00       	and    $0x200,%eax
801058f8:	85 c0                	test   %eax,%eax
801058fa:	74 0c                	je     80105908 <popcli+0x20>
    panic("popcli - interruptible");
801058fc:	c7 04 24 1b 96 10 80 	movl   $0x8010961b,(%esp)
80105903:	e8 4c ac ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
80105908:	e8 16 f4 ff ff       	call   80104d23 <mycpu>
8010590d:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105913:	4a                   	dec    %edx
80105914:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010591a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105920:	85 c0                	test   %eax,%eax
80105922:	79 0c                	jns    80105930 <popcli+0x48>
    panic("popcli");
80105924:	c7 04 24 32 96 10 80 	movl   $0x80109632,(%esp)
8010592b:	e8 24 ac ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105930:	e8 ee f3 ff ff       	call   80104d23 <mycpu>
80105935:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010593b:	85 c0                	test   %eax,%eax
8010593d:	75 14                	jne    80105953 <popcli+0x6b>
8010593f:	e8 df f3 ff ff       	call   80104d23 <mycpu>
80105944:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010594a:	85 c0                	test   %eax,%eax
8010594c:	74 05                	je     80105953 <popcli+0x6b>
    sti();
8010594e:	e8 ab fd ff ff       	call   801056fe <sti>
}
80105953:	c9                   	leave  
80105954:	c3                   	ret    
80105955:	00 00                	add    %al,(%eax)
	...

80105958 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105958:	55                   	push   %ebp
80105959:	89 e5                	mov    %esp,%ebp
8010595b:	57                   	push   %edi
8010595c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010595d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105960:	8b 55 10             	mov    0x10(%ebp),%edx
80105963:	8b 45 0c             	mov    0xc(%ebp),%eax
80105966:	89 cb                	mov    %ecx,%ebx
80105968:	89 df                	mov    %ebx,%edi
8010596a:	89 d1                	mov    %edx,%ecx
8010596c:	fc                   	cld    
8010596d:	f3 aa                	rep stos %al,%es:(%edi)
8010596f:	89 ca                	mov    %ecx,%edx
80105971:	89 fb                	mov    %edi,%ebx
80105973:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105976:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105979:	5b                   	pop    %ebx
8010597a:	5f                   	pop    %edi
8010597b:	5d                   	pop    %ebp
8010597c:	c3                   	ret    

8010597d <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
8010597d:	55                   	push   %ebp
8010597e:	89 e5                	mov    %esp,%ebp
80105980:	57                   	push   %edi
80105981:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105982:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105985:	8b 55 10             	mov    0x10(%ebp),%edx
80105988:	8b 45 0c             	mov    0xc(%ebp),%eax
8010598b:	89 cb                	mov    %ecx,%ebx
8010598d:	89 df                	mov    %ebx,%edi
8010598f:	89 d1                	mov    %edx,%ecx
80105991:	fc                   	cld    
80105992:	f3 ab                	rep stos %eax,%es:(%edi)
80105994:	89 ca                	mov    %ecx,%edx
80105996:	89 fb                	mov    %edi,%ebx
80105998:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010599b:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
8010599e:	5b                   	pop    %ebx
8010599f:	5f                   	pop    %edi
801059a0:	5d                   	pop    %ebp
801059a1:	c3                   	ret    

801059a2 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801059a2:	55                   	push   %ebp
801059a3:	89 e5                	mov    %esp,%ebp
801059a5:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801059a8:	8b 45 08             	mov    0x8(%ebp),%eax
801059ab:	83 e0 03             	and    $0x3,%eax
801059ae:	85 c0                	test   %eax,%eax
801059b0:	75 49                	jne    801059fb <memset+0x59>
801059b2:	8b 45 10             	mov    0x10(%ebp),%eax
801059b5:	83 e0 03             	and    $0x3,%eax
801059b8:	85 c0                	test   %eax,%eax
801059ba:	75 3f                	jne    801059fb <memset+0x59>
    c &= 0xFF;
801059bc:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801059c3:	8b 45 10             	mov    0x10(%ebp),%eax
801059c6:	c1 e8 02             	shr    $0x2,%eax
801059c9:	89 c2                	mov    %eax,%edx
801059cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801059ce:	c1 e0 18             	shl    $0x18,%eax
801059d1:	89 c1                	mov    %eax,%ecx
801059d3:	8b 45 0c             	mov    0xc(%ebp),%eax
801059d6:	c1 e0 10             	shl    $0x10,%eax
801059d9:	09 c1                	or     %eax,%ecx
801059db:	8b 45 0c             	mov    0xc(%ebp),%eax
801059de:	c1 e0 08             	shl    $0x8,%eax
801059e1:	09 c8                	or     %ecx,%eax
801059e3:	0b 45 0c             	or     0xc(%ebp),%eax
801059e6:	89 54 24 08          	mov    %edx,0x8(%esp)
801059ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801059ee:	8b 45 08             	mov    0x8(%ebp),%eax
801059f1:	89 04 24             	mov    %eax,(%esp)
801059f4:	e8 84 ff ff ff       	call   8010597d <stosl>
801059f9:	eb 19                	jmp    80105a14 <memset+0x72>
  } else
    stosb(dst, c, n);
801059fb:	8b 45 10             	mov    0x10(%ebp),%eax
801059fe:	89 44 24 08          	mov    %eax,0x8(%esp)
80105a02:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a05:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a09:	8b 45 08             	mov    0x8(%ebp),%eax
80105a0c:	89 04 24             	mov    %eax,(%esp)
80105a0f:	e8 44 ff ff ff       	call   80105958 <stosb>
  return dst;
80105a14:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105a17:	c9                   	leave  
80105a18:	c3                   	ret    

80105a19 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105a19:	55                   	push   %ebp
80105a1a:	89 e5                	mov    %esp,%ebp
80105a1c:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105a1f:	8b 45 08             	mov    0x8(%ebp),%eax
80105a22:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105a25:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a28:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105a2b:	eb 2a                	jmp    80105a57 <memcmp+0x3e>
    if(*s1 != *s2)
80105a2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a30:	8a 10                	mov    (%eax),%dl
80105a32:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105a35:	8a 00                	mov    (%eax),%al
80105a37:	38 c2                	cmp    %al,%dl
80105a39:	74 16                	je     80105a51 <memcmp+0x38>
      return *s1 - *s2;
80105a3b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a3e:	8a 00                	mov    (%eax),%al
80105a40:	0f b6 d0             	movzbl %al,%edx
80105a43:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105a46:	8a 00                	mov    (%eax),%al
80105a48:	0f b6 c0             	movzbl %al,%eax
80105a4b:	29 c2                	sub    %eax,%edx
80105a4d:	89 d0                	mov    %edx,%eax
80105a4f:	eb 18                	jmp    80105a69 <memcmp+0x50>
    s1++, s2++;
80105a51:	ff 45 fc             	incl   -0x4(%ebp)
80105a54:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105a57:	8b 45 10             	mov    0x10(%ebp),%eax
80105a5a:	8d 50 ff             	lea    -0x1(%eax),%edx
80105a5d:	89 55 10             	mov    %edx,0x10(%ebp)
80105a60:	85 c0                	test   %eax,%eax
80105a62:	75 c9                	jne    80105a2d <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105a64:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a69:	c9                   	leave  
80105a6a:	c3                   	ret    

80105a6b <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105a6b:	55                   	push   %ebp
80105a6c:	89 e5                	mov    %esp,%ebp
80105a6e:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105a71:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a74:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105a77:	8b 45 08             	mov    0x8(%ebp),%eax
80105a7a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105a7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a80:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105a83:	73 3a                	jae    80105abf <memmove+0x54>
80105a85:	8b 45 10             	mov    0x10(%ebp),%eax
80105a88:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105a8b:	01 d0                	add    %edx,%eax
80105a8d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105a90:	76 2d                	jbe    80105abf <memmove+0x54>
    s += n;
80105a92:	8b 45 10             	mov    0x10(%ebp),%eax
80105a95:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105a98:	8b 45 10             	mov    0x10(%ebp),%eax
80105a9b:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105a9e:	eb 10                	jmp    80105ab0 <memmove+0x45>
      *--d = *--s;
80105aa0:	ff 4d f8             	decl   -0x8(%ebp)
80105aa3:	ff 4d fc             	decl   -0x4(%ebp)
80105aa6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105aa9:	8a 10                	mov    (%eax),%dl
80105aab:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105aae:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105ab0:	8b 45 10             	mov    0x10(%ebp),%eax
80105ab3:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ab6:	89 55 10             	mov    %edx,0x10(%ebp)
80105ab9:	85 c0                	test   %eax,%eax
80105abb:	75 e3                	jne    80105aa0 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105abd:	eb 25                	jmp    80105ae4 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105abf:	eb 16                	jmp    80105ad7 <memmove+0x6c>
      *d++ = *s++;
80105ac1:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105ac4:	8d 50 01             	lea    0x1(%eax),%edx
80105ac7:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105aca:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105acd:	8d 4a 01             	lea    0x1(%edx),%ecx
80105ad0:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105ad3:	8a 12                	mov    (%edx),%dl
80105ad5:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105ad7:	8b 45 10             	mov    0x10(%ebp),%eax
80105ada:	8d 50 ff             	lea    -0x1(%eax),%edx
80105add:	89 55 10             	mov    %edx,0x10(%ebp)
80105ae0:	85 c0                	test   %eax,%eax
80105ae2:	75 dd                	jne    80105ac1 <memmove+0x56>
      *d++ = *s++;

  return dst;
80105ae4:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105ae7:	c9                   	leave  
80105ae8:	c3                   	ret    

80105ae9 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105ae9:	55                   	push   %ebp
80105aea:	89 e5                	mov    %esp,%ebp
80105aec:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105aef:	8b 45 10             	mov    0x10(%ebp),%eax
80105af2:	89 44 24 08          	mov    %eax,0x8(%esp)
80105af6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105af9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105afd:	8b 45 08             	mov    0x8(%ebp),%eax
80105b00:	89 04 24             	mov    %eax,(%esp)
80105b03:	e8 63 ff ff ff       	call   80105a6b <memmove>
}
80105b08:	c9                   	leave  
80105b09:	c3                   	ret    

80105b0a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105b0a:	55                   	push   %ebp
80105b0b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105b0d:	eb 09                	jmp    80105b18 <strncmp+0xe>
    n--, p++, q++;
80105b0f:	ff 4d 10             	decl   0x10(%ebp)
80105b12:	ff 45 08             	incl   0x8(%ebp)
80105b15:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105b18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b1c:	74 17                	je     80105b35 <strncmp+0x2b>
80105b1e:	8b 45 08             	mov    0x8(%ebp),%eax
80105b21:	8a 00                	mov    (%eax),%al
80105b23:	84 c0                	test   %al,%al
80105b25:	74 0e                	je     80105b35 <strncmp+0x2b>
80105b27:	8b 45 08             	mov    0x8(%ebp),%eax
80105b2a:	8a 10                	mov    (%eax),%dl
80105b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b2f:	8a 00                	mov    (%eax),%al
80105b31:	38 c2                	cmp    %al,%dl
80105b33:	74 da                	je     80105b0f <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105b35:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b39:	75 07                	jne    80105b42 <strncmp+0x38>
    return 0;
80105b3b:	b8 00 00 00 00       	mov    $0x0,%eax
80105b40:	eb 14                	jmp    80105b56 <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
80105b42:	8b 45 08             	mov    0x8(%ebp),%eax
80105b45:	8a 00                	mov    (%eax),%al
80105b47:	0f b6 d0             	movzbl %al,%edx
80105b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b4d:	8a 00                	mov    (%eax),%al
80105b4f:	0f b6 c0             	movzbl %al,%eax
80105b52:	29 c2                	sub    %eax,%edx
80105b54:	89 d0                	mov    %edx,%eax
}
80105b56:	5d                   	pop    %ebp
80105b57:	c3                   	ret    

80105b58 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105b58:	55                   	push   %ebp
80105b59:	89 e5                	mov    %esp,%ebp
80105b5b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105b5e:	8b 45 08             	mov    0x8(%ebp),%eax
80105b61:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105b64:	90                   	nop
80105b65:	8b 45 10             	mov    0x10(%ebp),%eax
80105b68:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b6b:	89 55 10             	mov    %edx,0x10(%ebp)
80105b6e:	85 c0                	test   %eax,%eax
80105b70:	7e 1c                	jle    80105b8e <strncpy+0x36>
80105b72:	8b 45 08             	mov    0x8(%ebp),%eax
80105b75:	8d 50 01             	lea    0x1(%eax),%edx
80105b78:	89 55 08             	mov    %edx,0x8(%ebp)
80105b7b:	8b 55 0c             	mov    0xc(%ebp),%edx
80105b7e:	8d 4a 01             	lea    0x1(%edx),%ecx
80105b81:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105b84:	8a 12                	mov    (%edx),%dl
80105b86:	88 10                	mov    %dl,(%eax)
80105b88:	8a 00                	mov    (%eax),%al
80105b8a:	84 c0                	test   %al,%al
80105b8c:	75 d7                	jne    80105b65 <strncpy+0xd>
    ;
  while(n-- > 0)
80105b8e:	eb 0c                	jmp    80105b9c <strncpy+0x44>
    *s++ = 0;
80105b90:	8b 45 08             	mov    0x8(%ebp),%eax
80105b93:	8d 50 01             	lea    0x1(%eax),%edx
80105b96:	89 55 08             	mov    %edx,0x8(%ebp)
80105b99:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105b9c:	8b 45 10             	mov    0x10(%ebp),%eax
80105b9f:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ba2:	89 55 10             	mov    %edx,0x10(%ebp)
80105ba5:	85 c0                	test   %eax,%eax
80105ba7:	7f e7                	jg     80105b90 <strncpy+0x38>
    *s++ = 0;
  return os;
80105ba9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105bac:	c9                   	leave  
80105bad:	c3                   	ret    

80105bae <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105bae:	55                   	push   %ebp
80105baf:	89 e5                	mov    %esp,%ebp
80105bb1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105bba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105bbe:	7f 05                	jg     80105bc5 <safestrcpy+0x17>
    return os;
80105bc0:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105bc3:	eb 2e                	jmp    80105bf3 <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
80105bc5:	ff 4d 10             	decl   0x10(%ebp)
80105bc8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105bcc:	7e 1c                	jle    80105bea <safestrcpy+0x3c>
80105bce:	8b 45 08             	mov    0x8(%ebp),%eax
80105bd1:	8d 50 01             	lea    0x1(%eax),%edx
80105bd4:	89 55 08             	mov    %edx,0x8(%ebp)
80105bd7:	8b 55 0c             	mov    0xc(%ebp),%edx
80105bda:	8d 4a 01             	lea    0x1(%edx),%ecx
80105bdd:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105be0:	8a 12                	mov    (%edx),%dl
80105be2:	88 10                	mov    %dl,(%eax)
80105be4:	8a 00                	mov    (%eax),%al
80105be6:	84 c0                	test   %al,%al
80105be8:	75 db                	jne    80105bc5 <safestrcpy+0x17>
    ;
  *s = 0;
80105bea:	8b 45 08             	mov    0x8(%ebp),%eax
80105bed:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105bf0:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105bf3:	c9                   	leave  
80105bf4:	c3                   	ret    

80105bf5 <strlen>:

int
strlen(const char *s)
{
80105bf5:	55                   	push   %ebp
80105bf6:	89 e5                	mov    %esp,%ebp
80105bf8:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105bfb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105c02:	eb 03                	jmp    80105c07 <strlen+0x12>
80105c04:	ff 45 fc             	incl   -0x4(%ebp)
80105c07:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105c0a:	8b 45 08             	mov    0x8(%ebp),%eax
80105c0d:	01 d0                	add    %edx,%eax
80105c0f:	8a 00                	mov    (%eax),%al
80105c11:	84 c0                	test   %al,%al
80105c13:	75 ef                	jne    80105c04 <strlen+0xf>
    ;
  return n;
80105c15:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c18:	c9                   	leave  
80105c19:	c3                   	ret    
	...

80105c1c <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105c1c:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105c20:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105c24:	55                   	push   %ebp
  pushl %ebx
80105c25:	53                   	push   %ebx
  pushl %esi
80105c26:	56                   	push   %esi
  pushl %edi
80105c27:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105c28:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105c2a:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105c2c:	5f                   	pop    %edi
  popl %esi
80105c2d:	5e                   	pop    %esi
  popl %ebx
80105c2e:	5b                   	pop    %ebx
  popl %ebp
80105c2f:	5d                   	pop    %ebp
  ret
80105c30:	c3                   	ret    
80105c31:	00 00                	add    %al,(%eax)
	...

80105c34 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105c34:	55                   	push   %ebp
80105c35:	89 e5                	mov    %esp,%ebp
80105c37:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105c3a:	e8 59 e6 ff ff       	call   80104298 <myproc>
80105c3f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c45:	8b 00                	mov    (%eax),%eax
80105c47:	3b 45 08             	cmp    0x8(%ebp),%eax
80105c4a:	76 0f                	jbe    80105c5b <fetchint+0x27>
80105c4c:	8b 45 08             	mov    0x8(%ebp),%eax
80105c4f:	8d 50 04             	lea    0x4(%eax),%edx
80105c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c55:	8b 00                	mov    (%eax),%eax
80105c57:	39 c2                	cmp    %eax,%edx
80105c59:	76 07                	jbe    80105c62 <fetchint+0x2e>
    return -1;
80105c5b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c60:	eb 0f                	jmp    80105c71 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105c62:	8b 45 08             	mov    0x8(%ebp),%eax
80105c65:	8b 10                	mov    (%eax),%edx
80105c67:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c6a:	89 10                	mov    %edx,(%eax)
  return 0;
80105c6c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c71:	c9                   	leave  
80105c72:	c3                   	ret    

80105c73 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105c73:	55                   	push   %ebp
80105c74:	89 e5                	mov    %esp,%ebp
80105c76:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105c79:	e8 1a e6 ff ff       	call   80104298 <myproc>
80105c7e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105c81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c84:	8b 00                	mov    (%eax),%eax
80105c86:	3b 45 08             	cmp    0x8(%ebp),%eax
80105c89:	77 07                	ja     80105c92 <fetchstr+0x1f>
    return -1;
80105c8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c90:	eb 41                	jmp    80105cd3 <fetchstr+0x60>
  *pp = (char*)addr;
80105c92:	8b 55 08             	mov    0x8(%ebp),%edx
80105c95:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c98:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105c9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c9d:	8b 00                	mov    (%eax),%eax
80105c9f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105ca2:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ca5:	8b 00                	mov    (%eax),%eax
80105ca7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105caa:	eb 1a                	jmp    80105cc6 <fetchstr+0x53>
    if(*s == 0)
80105cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105caf:	8a 00                	mov    (%eax),%al
80105cb1:	84 c0                	test   %al,%al
80105cb3:	75 0e                	jne    80105cc3 <fetchstr+0x50>
      return s - *pp;
80105cb5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cbb:	8b 00                	mov    (%eax),%eax
80105cbd:	29 c2                	sub    %eax,%edx
80105cbf:	89 d0                	mov    %edx,%eax
80105cc1:	eb 10                	jmp    80105cd3 <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
80105cc3:	ff 45 f4             	incl   -0xc(%ebp)
80105cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cc9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105ccc:	72 de                	jb     80105cac <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
80105cce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105cd3:	c9                   	leave  
80105cd4:	c3                   	ret    

80105cd5 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105cd5:	55                   	push   %ebp
80105cd6:	89 e5                	mov    %esp,%ebp
80105cd8:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105cdb:	e8 b8 e5 ff ff       	call   80104298 <myproc>
80105ce0:	8b 40 18             	mov    0x18(%eax),%eax
80105ce3:	8b 50 44             	mov    0x44(%eax),%edx
80105ce6:	8b 45 08             	mov    0x8(%ebp),%eax
80105ce9:	c1 e0 02             	shl    $0x2,%eax
80105cec:	01 d0                	add    %edx,%eax
80105cee:	8d 50 04             	lea    0x4(%eax),%edx
80105cf1:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cf4:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cf8:	89 14 24             	mov    %edx,(%esp)
80105cfb:	e8 34 ff ff ff       	call   80105c34 <fetchint>
}
80105d00:	c9                   	leave  
80105d01:	c3                   	ret    

80105d02 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105d02:	55                   	push   %ebp
80105d03:	89 e5                	mov    %esp,%ebp
80105d05:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
80105d08:	e8 8b e5 ff ff       	call   80104298 <myproc>
80105d0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105d10:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d13:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d17:	8b 45 08             	mov    0x8(%ebp),%eax
80105d1a:	89 04 24             	mov    %eax,(%esp)
80105d1d:	e8 b3 ff ff ff       	call   80105cd5 <argint>
80105d22:	85 c0                	test   %eax,%eax
80105d24:	79 07                	jns    80105d2d <argptr+0x2b>
    return -1;
80105d26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d2b:	eb 3d                	jmp    80105d6a <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105d2d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105d31:	78 21                	js     80105d54 <argptr+0x52>
80105d33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d36:	89 c2                	mov    %eax,%edx
80105d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d3b:	8b 00                	mov    (%eax),%eax
80105d3d:	39 c2                	cmp    %eax,%edx
80105d3f:	73 13                	jae    80105d54 <argptr+0x52>
80105d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d44:	89 c2                	mov    %eax,%edx
80105d46:	8b 45 10             	mov    0x10(%ebp),%eax
80105d49:	01 c2                	add    %eax,%edx
80105d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4e:	8b 00                	mov    (%eax),%eax
80105d50:	39 c2                	cmp    %eax,%edx
80105d52:	76 07                	jbe    80105d5b <argptr+0x59>
    return -1;
80105d54:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d59:	eb 0f                	jmp    80105d6a <argptr+0x68>
  *pp = (char*)i;
80105d5b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d5e:	89 c2                	mov    %eax,%edx
80105d60:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d63:	89 10                	mov    %edx,(%eax)
  return 0;
80105d65:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105d6a:	c9                   	leave  
80105d6b:	c3                   	ret    

80105d6c <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105d6c:	55                   	push   %ebp
80105d6d:	89 e5                	mov    %esp,%ebp
80105d6f:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105d72:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d75:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d79:	8b 45 08             	mov    0x8(%ebp),%eax
80105d7c:	89 04 24             	mov    %eax,(%esp)
80105d7f:	e8 51 ff ff ff       	call   80105cd5 <argint>
80105d84:	85 c0                	test   %eax,%eax
80105d86:	79 07                	jns    80105d8f <argstr+0x23>
    return -1;
80105d88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d8d:	eb 12                	jmp    80105da1 <argstr+0x35>
  return fetchstr(addr, pp);
80105d8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d92:	8b 55 0c             	mov    0xc(%ebp),%edx
80105d95:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d99:	89 04 24             	mov    %eax,(%esp)
80105d9c:	e8 d2 fe ff ff       	call   80105c73 <fetchstr>
}
80105da1:	c9                   	leave  
80105da2:	c3                   	ret    

80105da3 <syscall>:
[SYS_cinfo] sys_cinfo,
};

void
syscall(void)
{
80105da3:	55                   	push   %ebp
80105da4:	89 e5                	mov    %esp,%ebp
80105da6:	53                   	push   %ebx
80105da7:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
80105daa:	e8 e9 e4 ff ff       	call   80104298 <myproc>
80105daf:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105db2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105db5:	8b 40 18             	mov    0x18(%eax),%eax
80105db8:	8b 40 1c             	mov    0x1c(%eax),%eax
80105dbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105dbe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105dc2:	7e 2d                	jle    80105df1 <syscall+0x4e>
80105dc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dc7:	83 f8 1b             	cmp    $0x1b,%eax
80105dca:	77 25                	ja     80105df1 <syscall+0x4e>
80105dcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dcf:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105dd6:	85 c0                	test   %eax,%eax
80105dd8:	74 17                	je     80105df1 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddd:	8b 58 18             	mov    0x18(%eax),%ebx
80105de0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de3:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105dea:	ff d0                	call   *%eax
80105dec:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105def:	eb 34                	jmp    80105e25 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df4:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dfa:	8b 40 10             	mov    0x10(%eax),%eax
80105dfd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e00:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105e04:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105e08:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e0c:	c7 04 24 39 96 10 80 	movl   $0x80109639,(%esp)
80105e13:	e8 a9 a5 ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1b:	8b 40 18             	mov    0x18(%eax),%eax
80105e1e:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105e25:	83 c4 24             	add    $0x24,%esp
80105e28:	5b                   	pop    %ebx
80105e29:	5d                   	pop    %ebp
80105e2a:	c3                   	ret    
	...

80105e2c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105e2c:	55                   	push   %ebp
80105e2d:	89 e5                	mov    %esp,%ebp
80105e2f:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105e32:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e35:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e39:	8b 45 08             	mov    0x8(%ebp),%eax
80105e3c:	89 04 24             	mov    %eax,(%esp)
80105e3f:	e8 91 fe ff ff       	call   80105cd5 <argint>
80105e44:	85 c0                	test   %eax,%eax
80105e46:	79 07                	jns    80105e4f <argfd+0x23>
    return -1;
80105e48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e4d:	eb 4f                	jmp    80105e9e <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105e4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e52:	85 c0                	test   %eax,%eax
80105e54:	78 20                	js     80105e76 <argfd+0x4a>
80105e56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e59:	83 f8 0f             	cmp    $0xf,%eax
80105e5c:	7f 18                	jg     80105e76 <argfd+0x4a>
80105e5e:	e8 35 e4 ff ff       	call   80104298 <myproc>
80105e63:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e66:	83 c2 08             	add    $0x8,%edx
80105e69:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105e6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e70:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e74:	75 07                	jne    80105e7d <argfd+0x51>
    return -1;
80105e76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e7b:	eb 21                	jmp    80105e9e <argfd+0x72>
  if(pfd)
80105e7d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105e81:	74 08                	je     80105e8b <argfd+0x5f>
    *pfd = fd;
80105e83:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e86:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e89:	89 10                	mov    %edx,(%eax)
  if(pf)
80105e8b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105e8f:	74 08                	je     80105e99 <argfd+0x6d>
    *pf = f;
80105e91:	8b 45 10             	mov    0x10(%ebp),%eax
80105e94:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e97:	89 10                	mov    %edx,(%eax)
  return 0;
80105e99:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e9e:	c9                   	leave  
80105e9f:	c3                   	ret    

80105ea0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105ea0:	55                   	push   %ebp
80105ea1:	89 e5                	mov    %esp,%ebp
80105ea3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105ea6:	e8 ed e3 ff ff       	call   80104298 <myproc>
80105eab:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105eae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105eb5:	eb 29                	jmp    80105ee0 <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
80105eb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105eba:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ebd:	83 c2 08             	add    $0x8,%edx
80105ec0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105ec4:	85 c0                	test   %eax,%eax
80105ec6:	75 15                	jne    80105edd <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105ec8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ecb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ece:	8d 4a 08             	lea    0x8(%edx),%ecx
80105ed1:	8b 55 08             	mov    0x8(%ebp),%edx
80105ed4:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105edb:	eb 0e                	jmp    80105eeb <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105edd:	ff 45 f4             	incl   -0xc(%ebp)
80105ee0:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105ee4:	7e d1                	jle    80105eb7 <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105ee6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105eeb:	c9                   	leave  
80105eec:	c3                   	ret    

80105eed <sys_dup>:

int
sys_dup(void)
{
80105eed:	55                   	push   %ebp
80105eee:	89 e5                	mov    %esp,%ebp
80105ef0:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105ef3:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ef6:	89 44 24 08          	mov    %eax,0x8(%esp)
80105efa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105f01:	00 
80105f02:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f09:	e8 1e ff ff ff       	call   80105e2c <argfd>
80105f0e:	85 c0                	test   %eax,%eax
80105f10:	79 07                	jns    80105f19 <sys_dup+0x2c>
    return -1;
80105f12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f17:	eb 29                	jmp    80105f42 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105f19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f1c:	89 04 24             	mov    %eax,(%esp)
80105f1f:	e8 7c ff ff ff       	call   80105ea0 <fdalloc>
80105f24:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f27:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f2b:	79 07                	jns    80105f34 <sys_dup+0x47>
    return -1;
80105f2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f32:	eb 0e                	jmp    80105f42 <sys_dup+0x55>
  filedup(f);
80105f34:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f37:	89 04 24             	mov    %eax,(%esp)
80105f3a:	e8 85 b1 ff ff       	call   801010c4 <filedup>
  return fd;
80105f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105f42:	c9                   	leave  
80105f43:	c3                   	ret    

80105f44 <sys_read>:

int
sys_read(void)
{
80105f44:	55                   	push   %ebp
80105f45:	89 e5                	mov    %esp,%ebp
80105f47:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105f4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f4d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f51:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105f58:	00 
80105f59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105f60:	e8 c7 fe ff ff       	call   80105e2c <argfd>
80105f65:	85 c0                	test   %eax,%eax
80105f67:	78 35                	js     80105f9e <sys_read+0x5a>
80105f69:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f6c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f70:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105f77:	e8 59 fd ff ff       	call   80105cd5 <argint>
80105f7c:	85 c0                	test   %eax,%eax
80105f7e:	78 1e                	js     80105f9e <sys_read+0x5a>
80105f80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f83:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f87:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f8a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f8e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105f95:	e8 68 fd ff ff       	call   80105d02 <argptr>
80105f9a:	85 c0                	test   %eax,%eax
80105f9c:	79 07                	jns    80105fa5 <sys_read+0x61>
    return -1;
80105f9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fa3:	eb 19                	jmp    80105fbe <sys_read+0x7a>
  return fileread(f, p, n);
80105fa5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105fa8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fae:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105fb2:	89 54 24 04          	mov    %edx,0x4(%esp)
80105fb6:	89 04 24             	mov    %eax,(%esp)
80105fb9:	e8 67 b2 ff ff       	call   80101225 <fileread>
}
80105fbe:	c9                   	leave  
80105fbf:	c3                   	ret    

80105fc0 <sys_write>:

int
sys_write(void)
{
80105fc0:	55                   	push   %ebp
80105fc1:	89 e5                	mov    %esp,%ebp
80105fc3:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105fc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fc9:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fcd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105fd4:	00 
80105fd5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105fdc:	e8 4b fe ff ff       	call   80105e2c <argfd>
80105fe1:	85 c0                	test   %eax,%eax
80105fe3:	78 35                	js     8010601a <sys_write+0x5a>
80105fe5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105fe8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fec:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105ff3:	e8 dd fc ff ff       	call   80105cd5 <argint>
80105ff8:	85 c0                	test   %eax,%eax
80105ffa:	78 1e                	js     8010601a <sys_write+0x5a>
80105ffc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fff:	89 44 24 08          	mov    %eax,0x8(%esp)
80106003:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106006:	89 44 24 04          	mov    %eax,0x4(%esp)
8010600a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106011:	e8 ec fc ff ff       	call   80105d02 <argptr>
80106016:	85 c0                	test   %eax,%eax
80106018:	79 07                	jns    80106021 <sys_write+0x61>
    return -1;
8010601a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010601f:	eb 19                	jmp    8010603a <sys_write+0x7a>
  return filewrite(f, p, n);
80106021:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106024:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106027:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010602a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
8010602e:	89 54 24 04          	mov    %edx,0x4(%esp)
80106032:	89 04 24             	mov    %eax,(%esp)
80106035:	e8 a6 b2 ff ff       	call   801012e0 <filewrite>
}
8010603a:	c9                   	leave  
8010603b:	c3                   	ret    

8010603c <sys_close>:

int
sys_close(void)
{
8010603c:	55                   	push   %ebp
8010603d:	89 e5                	mov    %esp,%ebp
8010603f:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80106042:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106045:	89 44 24 08          	mov    %eax,0x8(%esp)
80106049:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010604c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106050:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106057:	e8 d0 fd ff ff       	call   80105e2c <argfd>
8010605c:	85 c0                	test   %eax,%eax
8010605e:	79 07                	jns    80106067 <sys_close+0x2b>
    return -1;
80106060:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106065:	eb 23                	jmp    8010608a <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
80106067:	e8 2c e2 ff ff       	call   80104298 <myproc>
8010606c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010606f:	83 c2 08             	add    $0x8,%edx
80106072:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106079:	00 
  fileclose(f);
8010607a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010607d:	89 04 24             	mov    %eax,(%esp)
80106080:	e8 87 b0 ff ff       	call   8010110c <fileclose>
  return 0;
80106085:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010608a:	c9                   	leave  
8010608b:	c3                   	ret    

8010608c <sys_fstat>:

int
sys_fstat(void)
{
8010608c:	55                   	push   %ebp
8010608d:	89 e5                	mov    %esp,%ebp
8010608f:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80106092:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106095:	89 44 24 08          	mov    %eax,0x8(%esp)
80106099:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801060a0:	00 
801060a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060a8:	e8 7f fd ff ff       	call   80105e2c <argfd>
801060ad:	85 c0                	test   %eax,%eax
801060af:	78 1f                	js     801060d0 <sys_fstat+0x44>
801060b1:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801060b8:	00 
801060b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060bc:	89 44 24 04          	mov    %eax,0x4(%esp)
801060c0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801060c7:	e8 36 fc ff ff       	call   80105d02 <argptr>
801060cc:	85 c0                	test   %eax,%eax
801060ce:	79 07                	jns    801060d7 <sys_fstat+0x4b>
    return -1;
801060d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d5:	eb 12                	jmp    801060e9 <sys_fstat+0x5d>
  return filestat(f, st);
801060d7:	8b 55 f0             	mov    -0x10(%ebp),%edx
801060da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060dd:	89 54 24 04          	mov    %edx,0x4(%esp)
801060e1:	89 04 24             	mov    %eax,(%esp)
801060e4:	e8 ed b0 ff ff       	call   801011d6 <filestat>
}
801060e9:	c9                   	leave  
801060ea:	c3                   	ret    

801060eb <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801060eb:	55                   	push   %ebp
801060ec:	89 e5                	mov    %esp,%ebp
801060ee:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801060f1:	8d 45 d8             	lea    -0x28(%ebp),%eax
801060f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801060f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060ff:	e8 68 fc ff ff       	call   80105d6c <argstr>
80106104:	85 c0                	test   %eax,%eax
80106106:	78 17                	js     8010611f <sys_link+0x34>
80106108:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010610b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010610f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106116:	e8 51 fc ff ff       	call   80105d6c <argstr>
8010611b:	85 c0                	test   %eax,%eax
8010611d:	79 0a                	jns    80106129 <sys_link+0x3e>
    return -1;
8010611f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106124:	e9 3d 01 00 00       	jmp    80106266 <sys_link+0x17b>

  begin_op();
80106129:	e8 6d d5 ff ff       	call   8010369b <begin_op>
  if((ip = namei(old)) == 0){
8010612e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80106131:	89 04 24             	mov    %eax,(%esp)
80106134:	e8 8d c5 ff ff       	call   801026c6 <namei>
80106139:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010613c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106140:	75 0f                	jne    80106151 <sys_link+0x66>
    end_op();
80106142:	e8 d6 d5 ff ff       	call   8010371d <end_op>
    return -1;
80106147:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010614c:	e9 15 01 00 00       	jmp    80106266 <sys_link+0x17b>
  }

  ilock(ip);
80106151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106154:	89 04 24             	mov    %eax,(%esp)
80106157:	e8 ca b8 ff ff       	call   80101a26 <ilock>
  if(ip->type == T_DIR){
8010615c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010615f:	8b 40 50             	mov    0x50(%eax),%eax
80106162:	66 83 f8 01          	cmp    $0x1,%ax
80106166:	75 1a                	jne    80106182 <sys_link+0x97>
    iunlockput(ip);
80106168:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010616b:	89 04 24             	mov    %eax,(%esp)
8010616e:	e8 b2 ba ff ff       	call   80101c25 <iunlockput>
    end_op();
80106173:	e8 a5 d5 ff ff       	call   8010371d <end_op>
    return -1;
80106178:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010617d:	e9 e4 00 00 00       	jmp    80106266 <sys_link+0x17b>
  }

  ip->nlink++;
80106182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106185:	66 8b 40 56          	mov    0x56(%eax),%ax
80106189:	40                   	inc    %eax
8010618a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010618d:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80106191:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106194:	89 04 24             	mov    %eax,(%esp)
80106197:	e8 c7 b6 ff ff       	call   80101863 <iupdate>
  iunlock(ip);
8010619c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010619f:	89 04 24             	mov    %eax,(%esp)
801061a2:	e8 89 b9 ff ff       	call   80101b30 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
801061a7:	8b 45 dc             	mov    -0x24(%ebp),%eax
801061aa:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801061ad:	89 54 24 04          	mov    %edx,0x4(%esp)
801061b1:	89 04 24             	mov    %eax,(%esp)
801061b4:	e8 2f c5 ff ff       	call   801026e8 <nameiparent>
801061b9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061bc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061c0:	75 02                	jne    801061c4 <sys_link+0xd9>
    goto bad;
801061c2:	eb 68                	jmp    8010622c <sys_link+0x141>
  ilock(dp);
801061c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c7:	89 04 24             	mov    %eax,(%esp)
801061ca:	e8 57 b8 ff ff       	call   80101a26 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801061cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061d2:	8b 10                	mov    (%eax),%edx
801061d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061d7:	8b 00                	mov    (%eax),%eax
801061d9:	39 c2                	cmp    %eax,%edx
801061db:	75 20                	jne    801061fd <sys_link+0x112>
801061dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e0:	8b 40 04             	mov    0x4(%eax),%eax
801061e3:	89 44 24 08          	mov    %eax,0x8(%esp)
801061e7:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801061ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801061ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f1:	89 04 24             	mov    %eax,(%esp)
801061f4:	e8 c3 c0 ff ff       	call   801022bc <dirlink>
801061f9:	85 c0                	test   %eax,%eax
801061fb:	79 0d                	jns    8010620a <sys_link+0x11f>
    iunlockput(dp);
801061fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106200:	89 04 24             	mov    %eax,(%esp)
80106203:	e8 1d ba ff ff       	call   80101c25 <iunlockput>
    goto bad;
80106208:	eb 22                	jmp    8010622c <sys_link+0x141>
  }
  iunlockput(dp);
8010620a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010620d:	89 04 24             	mov    %eax,(%esp)
80106210:	e8 10 ba ff ff       	call   80101c25 <iunlockput>
  iput(ip);
80106215:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106218:	89 04 24             	mov    %eax,(%esp)
8010621b:	e8 54 b9 ff ff       	call   80101b74 <iput>

  end_op();
80106220:	e8 f8 d4 ff ff       	call   8010371d <end_op>

  return 0;
80106225:	b8 00 00 00 00       	mov    $0x0,%eax
8010622a:	eb 3a                	jmp    80106266 <sys_link+0x17b>

bad:
  ilock(ip);
8010622c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010622f:	89 04 24             	mov    %eax,(%esp)
80106232:	e8 ef b7 ff ff       	call   80101a26 <ilock>
  ip->nlink--;
80106237:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010623a:	66 8b 40 56          	mov    0x56(%eax),%ax
8010623e:	48                   	dec    %eax
8010623f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106242:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80106246:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106249:	89 04 24             	mov    %eax,(%esp)
8010624c:	e8 12 b6 ff ff       	call   80101863 <iupdate>
  iunlockput(ip);
80106251:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106254:	89 04 24             	mov    %eax,(%esp)
80106257:	e8 c9 b9 ff ff       	call   80101c25 <iunlockput>
  end_op();
8010625c:	e8 bc d4 ff ff       	call   8010371d <end_op>
  return -1;
80106261:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106266:	c9                   	leave  
80106267:	c3                   	ret    

80106268 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80106268:	55                   	push   %ebp
80106269:	89 e5                	mov    %esp,%ebp
8010626b:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010626e:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80106275:	eb 4a                	jmp    801062c1 <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80106277:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010627a:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106281:	00 
80106282:	89 44 24 08          	mov    %eax,0x8(%esp)
80106286:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106289:	89 44 24 04          	mov    %eax,0x4(%esp)
8010628d:	8b 45 08             	mov    0x8(%ebp),%eax
80106290:	89 04 24             	mov    %eax,(%esp)
80106293:	e8 25 bc ff ff       	call   80101ebd <readi>
80106298:	83 f8 10             	cmp    $0x10,%eax
8010629b:	74 0c                	je     801062a9 <isdirempty+0x41>
      panic("isdirempty: readi");
8010629d:	c7 04 24 58 96 10 80 	movl   $0x80109658,(%esp)
801062a4:	e8 ab a2 ff ff       	call   80100554 <panic>
    if(de.inum != 0)
801062a9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062ac:	66 85 c0             	test   %ax,%ax
801062af:	74 07                	je     801062b8 <isdirempty+0x50>
      return 0;
801062b1:	b8 00 00 00 00       	mov    $0x0,%eax
801062b6:	eb 1b                	jmp    801062d3 <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801062b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062bb:	83 c0 10             	add    $0x10,%eax
801062be:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062c4:	8b 45 08             	mov    0x8(%ebp),%eax
801062c7:	8b 40 58             	mov    0x58(%eax),%eax
801062ca:	39 c2                	cmp    %eax,%edx
801062cc:	72 a9                	jb     80106277 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801062ce:	b8 01 00 00 00       	mov    $0x1,%eax
}
801062d3:	c9                   	leave  
801062d4:	c3                   	ret    

801062d5 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801062d5:	55                   	push   %ebp
801062d6:	89 e5                	mov    %esp,%ebp
801062d8:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801062db:	8d 45 cc             	lea    -0x34(%ebp),%eax
801062de:	89 44 24 04          	mov    %eax,0x4(%esp)
801062e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062e9:	e8 7e fa ff ff       	call   80105d6c <argstr>
801062ee:	85 c0                	test   %eax,%eax
801062f0:	79 0a                	jns    801062fc <sys_unlink+0x27>
    return -1;
801062f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062f7:	e9 a9 01 00 00       	jmp    801064a5 <sys_unlink+0x1d0>

  begin_op();
801062fc:	e8 9a d3 ff ff       	call   8010369b <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106301:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106304:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106307:	89 54 24 04          	mov    %edx,0x4(%esp)
8010630b:	89 04 24             	mov    %eax,(%esp)
8010630e:	e8 d5 c3 ff ff       	call   801026e8 <nameiparent>
80106313:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106316:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010631a:	75 0f                	jne    8010632b <sys_unlink+0x56>
    end_op();
8010631c:	e8 fc d3 ff ff       	call   8010371d <end_op>
    return -1;
80106321:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106326:	e9 7a 01 00 00       	jmp    801064a5 <sys_unlink+0x1d0>
  }

  ilock(dp);
8010632b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632e:	89 04 24             	mov    %eax,(%esp)
80106331:	e8 f0 b6 ff ff       	call   80101a26 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106336:	c7 44 24 04 6a 96 10 	movl   $0x8010966a,0x4(%esp)
8010633d:	80 
8010633e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106341:	89 04 24             	mov    %eax,(%esp)
80106344:	e8 67 be ff ff       	call   801021b0 <namecmp>
80106349:	85 c0                	test   %eax,%eax
8010634b:	0f 84 3f 01 00 00    	je     80106490 <sys_unlink+0x1bb>
80106351:	c7 44 24 04 6c 96 10 	movl   $0x8010966c,0x4(%esp)
80106358:	80 
80106359:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010635c:	89 04 24             	mov    %eax,(%esp)
8010635f:	e8 4c be ff ff       	call   801021b0 <namecmp>
80106364:	85 c0                	test   %eax,%eax
80106366:	0f 84 24 01 00 00    	je     80106490 <sys_unlink+0x1bb>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010636c:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010636f:	89 44 24 08          	mov    %eax,0x8(%esp)
80106373:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106376:	89 44 24 04          	mov    %eax,0x4(%esp)
8010637a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010637d:	89 04 24             	mov    %eax,(%esp)
80106380:	e8 4d be ff ff       	call   801021d2 <dirlookup>
80106385:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106388:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010638c:	75 05                	jne    80106393 <sys_unlink+0xbe>
    goto bad;
8010638e:	e9 fd 00 00 00       	jmp    80106490 <sys_unlink+0x1bb>
  ilock(ip);
80106393:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106396:	89 04 24             	mov    %eax,(%esp)
80106399:	e8 88 b6 ff ff       	call   80101a26 <ilock>

  if(ip->nlink < 1)
8010639e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063a1:	66 8b 40 56          	mov    0x56(%eax),%ax
801063a5:	66 85 c0             	test   %ax,%ax
801063a8:	7f 0c                	jg     801063b6 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
801063aa:	c7 04 24 6f 96 10 80 	movl   $0x8010966f,(%esp)
801063b1:	e8 9e a1 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801063b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b9:	8b 40 50             	mov    0x50(%eax),%eax
801063bc:	66 83 f8 01          	cmp    $0x1,%ax
801063c0:	75 1f                	jne    801063e1 <sys_unlink+0x10c>
801063c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c5:	89 04 24             	mov    %eax,(%esp)
801063c8:	e8 9b fe ff ff       	call   80106268 <isdirempty>
801063cd:	85 c0                	test   %eax,%eax
801063cf:	75 10                	jne    801063e1 <sys_unlink+0x10c>
    iunlockput(ip);
801063d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d4:	89 04 24             	mov    %eax,(%esp)
801063d7:	e8 49 b8 ff ff       	call   80101c25 <iunlockput>
    goto bad;
801063dc:	e9 af 00 00 00       	jmp    80106490 <sys_unlink+0x1bb>
  }

  memset(&de, 0, sizeof(de));
801063e1:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801063e8:	00 
801063e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801063f0:	00 
801063f1:	8d 45 e0             	lea    -0x20(%ebp),%eax
801063f4:	89 04 24             	mov    %eax,(%esp)
801063f7:	e8 a6 f5 ff ff       	call   801059a2 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801063fc:	8b 45 c8             	mov    -0x38(%ebp),%eax
801063ff:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106406:	00 
80106407:	89 44 24 08          	mov    %eax,0x8(%esp)
8010640b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010640e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106412:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106415:	89 04 24             	mov    %eax,(%esp)
80106418:	e8 04 bc ff ff       	call   80102021 <writei>
8010641d:	83 f8 10             	cmp    $0x10,%eax
80106420:	74 0c                	je     8010642e <sys_unlink+0x159>
    panic("unlink: writei");
80106422:	c7 04 24 81 96 10 80 	movl   $0x80109681,(%esp)
80106429:	e8 26 a1 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR){
8010642e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106431:	8b 40 50             	mov    0x50(%eax),%eax
80106434:	66 83 f8 01          	cmp    $0x1,%ax
80106438:	75 1a                	jne    80106454 <sys_unlink+0x17f>
    dp->nlink--;
8010643a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010643d:	66 8b 40 56          	mov    0x56(%eax),%ax
80106441:	48                   	dec    %eax
80106442:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106445:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80106449:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010644c:	89 04 24             	mov    %eax,(%esp)
8010644f:	e8 0f b4 ff ff       	call   80101863 <iupdate>
  }
  iunlockput(dp);
80106454:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106457:	89 04 24             	mov    %eax,(%esp)
8010645a:	e8 c6 b7 ff ff       	call   80101c25 <iunlockput>

  ip->nlink--;
8010645f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106462:	66 8b 40 56          	mov    0x56(%eax),%ax
80106466:	48                   	dec    %eax
80106467:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010646a:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
8010646e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106471:	89 04 24             	mov    %eax,(%esp)
80106474:	e8 ea b3 ff ff       	call   80101863 <iupdate>
  iunlockput(ip);
80106479:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010647c:	89 04 24             	mov    %eax,(%esp)
8010647f:	e8 a1 b7 ff ff       	call   80101c25 <iunlockput>

  end_op();
80106484:	e8 94 d2 ff ff       	call   8010371d <end_op>

  return 0;
80106489:	b8 00 00 00 00       	mov    $0x0,%eax
8010648e:	eb 15                	jmp    801064a5 <sys_unlink+0x1d0>

bad:
  iunlockput(dp);
80106490:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106493:	89 04 24             	mov    %eax,(%esp)
80106496:	e8 8a b7 ff ff       	call   80101c25 <iunlockput>
  end_op();
8010649b:	e8 7d d2 ff ff       	call   8010371d <end_op>
  return -1;
801064a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801064a5:	c9                   	leave  
801064a6:	c3                   	ret    

801064a7 <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
801064a7:	55                   	push   %ebp
801064a8:	89 e5                	mov    %esp,%ebp
801064aa:	83 ec 48             	sub    $0x48,%esp
801064ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801064b0:	8b 55 10             	mov    0x10(%ebp),%edx
801064b3:	8b 45 14             	mov    0x14(%ebp),%eax
801064b6:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801064ba:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801064be:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801064c2:	8d 45 de             	lea    -0x22(%ebp),%eax
801064c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801064c9:	8b 45 08             	mov    0x8(%ebp),%eax
801064cc:	89 04 24             	mov    %eax,(%esp)
801064cf:	e8 14 c2 ff ff       	call   801026e8 <nameiparent>
801064d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064db:	75 0a                	jne    801064e7 <create+0x40>
    return 0;
801064dd:	b8 00 00 00 00       	mov    $0x0,%eax
801064e2:	e9 79 01 00 00       	jmp    80106660 <create+0x1b9>
  ilock(dp);
801064e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ea:	89 04 24             	mov    %eax,(%esp)
801064ed:	e8 34 b5 ff ff       	call   80101a26 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801064f2:	8d 45 ec             	lea    -0x14(%ebp),%eax
801064f5:	89 44 24 08          	mov    %eax,0x8(%esp)
801064f9:	8d 45 de             	lea    -0x22(%ebp),%eax
801064fc:	89 44 24 04          	mov    %eax,0x4(%esp)
80106500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106503:	89 04 24             	mov    %eax,(%esp)
80106506:	e8 c7 bc ff ff       	call   801021d2 <dirlookup>
8010650b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010650e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106512:	74 46                	je     8010655a <create+0xb3>
    iunlockput(dp);
80106514:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106517:	89 04 24             	mov    %eax,(%esp)
8010651a:	e8 06 b7 ff ff       	call   80101c25 <iunlockput>
    ilock(ip);
8010651f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106522:	89 04 24             	mov    %eax,(%esp)
80106525:	e8 fc b4 ff ff       	call   80101a26 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
8010652a:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010652f:	75 14                	jne    80106545 <create+0x9e>
80106531:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106534:	8b 40 50             	mov    0x50(%eax),%eax
80106537:	66 83 f8 02          	cmp    $0x2,%ax
8010653b:	75 08                	jne    80106545 <create+0x9e>
      return ip;
8010653d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106540:	e9 1b 01 00 00       	jmp    80106660 <create+0x1b9>
    iunlockput(ip);
80106545:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106548:	89 04 24             	mov    %eax,(%esp)
8010654b:	e8 d5 b6 ff ff       	call   80101c25 <iunlockput>
    return 0;
80106550:	b8 00 00 00 00       	mov    $0x0,%eax
80106555:	e9 06 01 00 00       	jmp    80106660 <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010655a:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010655e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106561:	8b 00                	mov    (%eax),%eax
80106563:	89 54 24 04          	mov    %edx,0x4(%esp)
80106567:	89 04 24             	mov    %eax,(%esp)
8010656a:	e8 22 b2 ff ff       	call   80101791 <ialloc>
8010656f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106572:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106576:	75 0c                	jne    80106584 <create+0xdd>
    panic("create: ialloc");
80106578:	c7 04 24 90 96 10 80 	movl   $0x80109690,(%esp)
8010657f:	e8 d0 9f ff ff       	call   80100554 <panic>

  ilock(ip);
80106584:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106587:	89 04 24             	mov    %eax,(%esp)
8010658a:	e8 97 b4 ff ff       	call   80101a26 <ilock>
  ip->major = major;
8010658f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106592:	8b 45 d0             	mov    -0x30(%ebp),%eax
80106595:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
80106599:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010659c:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010659f:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
801065a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065a6:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801065ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065af:	89 04 24             	mov    %eax,(%esp)
801065b2:	e8 ac b2 ff ff       	call   80101863 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
801065b7:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801065bc:	75 68                	jne    80106626 <create+0x17f>
    dp->nlink++;  // for ".."
801065be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065c1:	66 8b 40 56          	mov    0x56(%eax),%ax
801065c5:	40                   	inc    %eax
801065c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065c9:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
801065cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d0:	89 04 24             	mov    %eax,(%esp)
801065d3:	e8 8b b2 ff ff       	call   80101863 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801065d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065db:	8b 40 04             	mov    0x4(%eax),%eax
801065de:	89 44 24 08          	mov    %eax,0x8(%esp)
801065e2:	c7 44 24 04 6a 96 10 	movl   $0x8010966a,0x4(%esp)
801065e9:	80 
801065ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065ed:	89 04 24             	mov    %eax,(%esp)
801065f0:	e8 c7 bc ff ff       	call   801022bc <dirlink>
801065f5:	85 c0                	test   %eax,%eax
801065f7:	78 21                	js     8010661a <create+0x173>
801065f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065fc:	8b 40 04             	mov    0x4(%eax),%eax
801065ff:	89 44 24 08          	mov    %eax,0x8(%esp)
80106603:	c7 44 24 04 6c 96 10 	movl   $0x8010966c,0x4(%esp)
8010660a:	80 
8010660b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010660e:	89 04 24             	mov    %eax,(%esp)
80106611:	e8 a6 bc ff ff       	call   801022bc <dirlink>
80106616:	85 c0                	test   %eax,%eax
80106618:	79 0c                	jns    80106626 <create+0x17f>
      panic("create dots");
8010661a:	c7 04 24 9f 96 10 80 	movl   $0x8010969f,(%esp)
80106621:	e8 2e 9f ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106626:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106629:	8b 40 04             	mov    0x4(%eax),%eax
8010662c:	89 44 24 08          	mov    %eax,0x8(%esp)
80106630:	8d 45 de             	lea    -0x22(%ebp),%eax
80106633:	89 44 24 04          	mov    %eax,0x4(%esp)
80106637:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010663a:	89 04 24             	mov    %eax,(%esp)
8010663d:	e8 7a bc ff ff       	call   801022bc <dirlink>
80106642:	85 c0                	test   %eax,%eax
80106644:	79 0c                	jns    80106652 <create+0x1ab>
    panic("create: dirlink");
80106646:	c7 04 24 ab 96 10 80 	movl   $0x801096ab,(%esp)
8010664d:	e8 02 9f ff ff       	call   80100554 <panic>

  iunlockput(dp);
80106652:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106655:	89 04 24             	mov    %eax,(%esp)
80106658:	e8 c8 b5 ff ff       	call   80101c25 <iunlockput>

  return ip;
8010665d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106660:	c9                   	leave  
80106661:	c3                   	ret    

80106662 <sys_open>:

int
sys_open(void)
{
80106662:	55                   	push   %ebp
80106663:	89 e5                	mov    %esp,%ebp
80106665:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106668:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010666b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010666f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106676:	e8 f1 f6 ff ff       	call   80105d6c <argstr>
8010667b:	85 c0                	test   %eax,%eax
8010667d:	78 17                	js     80106696 <sys_open+0x34>
8010667f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106682:	89 44 24 04          	mov    %eax,0x4(%esp)
80106686:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010668d:	e8 43 f6 ff ff       	call   80105cd5 <argint>
80106692:	85 c0                	test   %eax,%eax
80106694:	79 0a                	jns    801066a0 <sys_open+0x3e>
    return -1;
80106696:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010669b:	e9 5b 01 00 00       	jmp    801067fb <sys_open+0x199>

  begin_op();
801066a0:	e8 f6 cf ff ff       	call   8010369b <begin_op>

  if(omode & O_CREATE){
801066a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066a8:	25 00 02 00 00       	and    $0x200,%eax
801066ad:	85 c0                	test   %eax,%eax
801066af:	74 3b                	je     801066ec <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
801066b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066b4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801066bb:	00 
801066bc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801066c3:	00 
801066c4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801066cb:	00 
801066cc:	89 04 24             	mov    %eax,(%esp)
801066cf:	e8 d3 fd ff ff       	call   801064a7 <create>
801066d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801066d7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066db:	75 6a                	jne    80106747 <sys_open+0xe5>
      end_op();
801066dd:	e8 3b d0 ff ff       	call   8010371d <end_op>
      return -1;
801066e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066e7:	e9 0f 01 00 00       	jmp    801067fb <sys_open+0x199>
    }
  } else {
    if((ip = namei(path)) == 0){
801066ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066ef:	89 04 24             	mov    %eax,(%esp)
801066f2:	e8 cf bf ff ff       	call   801026c6 <namei>
801066f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801066fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801066fe:	75 0f                	jne    8010670f <sys_open+0xad>
      end_op();
80106700:	e8 18 d0 ff ff       	call   8010371d <end_op>
      return -1;
80106705:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010670a:	e9 ec 00 00 00       	jmp    801067fb <sys_open+0x199>
    }
    ilock(ip);
8010670f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106712:	89 04 24             	mov    %eax,(%esp)
80106715:	e8 0c b3 ff ff       	call   80101a26 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
8010671a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010671d:	8b 40 50             	mov    0x50(%eax),%eax
80106720:	66 83 f8 01          	cmp    $0x1,%ax
80106724:	75 21                	jne    80106747 <sys_open+0xe5>
80106726:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106729:	85 c0                	test   %eax,%eax
8010672b:	74 1a                	je     80106747 <sys_open+0xe5>
      iunlockput(ip);
8010672d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106730:	89 04 24             	mov    %eax,(%esp)
80106733:	e8 ed b4 ff ff       	call   80101c25 <iunlockput>
      end_op();
80106738:	e8 e0 cf ff ff       	call   8010371d <end_op>
      return -1;
8010673d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106742:	e9 b4 00 00 00       	jmp    801067fb <sys_open+0x199>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106747:	e8 18 a9 ff ff       	call   80101064 <filealloc>
8010674c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010674f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106753:	74 14                	je     80106769 <sys_open+0x107>
80106755:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106758:	89 04 24             	mov    %eax,(%esp)
8010675b:	e8 40 f7 ff ff       	call   80105ea0 <fdalloc>
80106760:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106763:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106767:	79 28                	jns    80106791 <sys_open+0x12f>
    if(f)
80106769:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010676d:	74 0b                	je     8010677a <sys_open+0x118>
      fileclose(f);
8010676f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106772:	89 04 24             	mov    %eax,(%esp)
80106775:	e8 92 a9 ff ff       	call   8010110c <fileclose>
    iunlockput(ip);
8010677a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010677d:	89 04 24             	mov    %eax,(%esp)
80106780:	e8 a0 b4 ff ff       	call   80101c25 <iunlockput>
    end_op();
80106785:	e8 93 cf ff ff       	call   8010371d <end_op>
    return -1;
8010678a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010678f:	eb 6a                	jmp    801067fb <sys_open+0x199>
  }
  iunlock(ip);
80106791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106794:	89 04 24             	mov    %eax,(%esp)
80106797:	e8 94 b3 ff ff       	call   80101b30 <iunlock>
  end_op();
8010679c:	e8 7c cf ff ff       	call   8010371d <end_op>

  f->type = FD_INODE;
801067a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067a4:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801067aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067b0:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801067b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067b6:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801067bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067c0:	83 e0 01             	and    $0x1,%eax
801067c3:	85 c0                	test   %eax,%eax
801067c5:	0f 94 c0             	sete   %al
801067c8:	88 c2                	mov    %al,%dl
801067ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067cd:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801067d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067d3:	83 e0 01             	and    $0x1,%eax
801067d6:	85 c0                	test   %eax,%eax
801067d8:	75 0a                	jne    801067e4 <sys_open+0x182>
801067da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801067dd:	83 e0 02             	and    $0x2,%eax
801067e0:	85 c0                	test   %eax,%eax
801067e2:	74 07                	je     801067eb <sys_open+0x189>
801067e4:	b8 01 00 00 00       	mov    $0x1,%eax
801067e9:	eb 05                	jmp    801067f0 <sys_open+0x18e>
801067eb:	b8 00 00 00 00       	mov    $0x0,%eax
801067f0:	88 c2                	mov    %al,%dl
801067f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067f5:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801067f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801067fb:	c9                   	leave  
801067fc:	c3                   	ret    

801067fd <sys_mkdir>:

int
sys_mkdir(void)
{
801067fd:	55                   	push   %ebp
801067fe:	89 e5                	mov    %esp,%ebp
80106800:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106803:	e8 93 ce ff ff       	call   8010369b <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106808:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010680b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010680f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106816:	e8 51 f5 ff ff       	call   80105d6c <argstr>
8010681b:	85 c0                	test   %eax,%eax
8010681d:	78 2c                	js     8010684b <sys_mkdir+0x4e>
8010681f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106822:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106829:	00 
8010682a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106831:	00 
80106832:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106839:	00 
8010683a:	89 04 24             	mov    %eax,(%esp)
8010683d:	e8 65 fc ff ff       	call   801064a7 <create>
80106842:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106845:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106849:	75 0c                	jne    80106857 <sys_mkdir+0x5a>
    end_op();
8010684b:	e8 cd ce ff ff       	call   8010371d <end_op>
    return -1;
80106850:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106855:	eb 15                	jmp    8010686c <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106857:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010685a:	89 04 24             	mov    %eax,(%esp)
8010685d:	e8 c3 b3 ff ff       	call   80101c25 <iunlockput>
  end_op();
80106862:	e8 b6 ce ff ff       	call   8010371d <end_op>
  return 0;
80106867:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010686c:	c9                   	leave  
8010686d:	c3                   	ret    

8010686e <sys_mknod>:

int
sys_mknod(void)
{
8010686e:	55                   	push   %ebp
8010686f:	89 e5                	mov    %esp,%ebp
80106871:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106874:	e8 22 ce ff ff       	call   8010369b <begin_op>
  if((argstr(0, &path)) < 0 ||
80106879:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010687c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106880:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106887:	e8 e0 f4 ff ff       	call   80105d6c <argstr>
8010688c:	85 c0                	test   %eax,%eax
8010688e:	78 5e                	js     801068ee <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80106890:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106893:	89 44 24 04          	mov    %eax,0x4(%esp)
80106897:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010689e:	e8 32 f4 ff ff       	call   80105cd5 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
801068a3:	85 c0                	test   %eax,%eax
801068a5:	78 47                	js     801068ee <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801068a7:	8d 45 e8             	lea    -0x18(%ebp),%eax
801068aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801068ae:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801068b5:	e8 1b f4 ff ff       	call   80105cd5 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801068ba:	85 c0                	test   %eax,%eax
801068bc:	78 30                	js     801068ee <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801068be:	8b 45 e8             	mov    -0x18(%ebp),%eax
801068c1:	0f bf c8             	movswl %ax,%ecx
801068c4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801068c7:	0f bf d0             	movswl %ax,%edx
801068ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801068cd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801068d1:	89 54 24 08          	mov    %edx,0x8(%esp)
801068d5:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801068dc:	00 
801068dd:	89 04 24             	mov    %eax,(%esp)
801068e0:	e8 c2 fb ff ff       	call   801064a7 <create>
801068e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
801068e8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068ec:	75 0c                	jne    801068fa <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
801068ee:	e8 2a ce ff ff       	call   8010371d <end_op>
    return -1;
801068f3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068f8:	eb 15                	jmp    8010690f <sys_mknod+0xa1>
  }
  iunlockput(ip);
801068fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068fd:	89 04 24             	mov    %eax,(%esp)
80106900:	e8 20 b3 ff ff       	call   80101c25 <iunlockput>
  end_op();
80106905:	e8 13 ce ff ff       	call   8010371d <end_op>
  return 0;
8010690a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010690f:	c9                   	leave  
80106910:	c3                   	ret    

80106911 <sys_chdir>:

int
sys_chdir(void)
{
80106911:	55                   	push   %ebp
80106912:	89 e5                	mov    %esp,%ebp
80106914:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106917:	e8 7c d9 ff ff       	call   80104298 <myproc>
8010691c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
8010691f:	e8 77 cd ff ff       	call   8010369b <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106924:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106927:	89 44 24 04          	mov    %eax,0x4(%esp)
8010692b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106932:	e8 35 f4 ff ff       	call   80105d6c <argstr>
80106937:	85 c0                	test   %eax,%eax
80106939:	78 14                	js     8010694f <sys_chdir+0x3e>
8010693b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010693e:	89 04 24             	mov    %eax,(%esp)
80106941:	e8 80 bd ff ff       	call   801026c6 <namei>
80106946:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106949:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010694d:	75 18                	jne    80106967 <sys_chdir+0x56>
    cprintf("cant pick up path\n");
8010694f:	c7 04 24 bb 96 10 80 	movl   $0x801096bb,(%esp)
80106956:	e8 66 9a ff ff       	call   801003c1 <cprintf>
    end_op();
8010695b:	e8 bd cd ff ff       	call   8010371d <end_op>
    return -1;
80106960:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106965:	eb 66                	jmp    801069cd <sys_chdir+0xbc>
  }
  ilock(ip);
80106967:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010696a:	89 04 24             	mov    %eax,(%esp)
8010696d:	e8 b4 b0 ff ff       	call   80101a26 <ilock>
  if(ip->type != T_DIR){
80106972:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106975:	8b 40 50             	mov    0x50(%eax),%eax
80106978:	66 83 f8 01          	cmp    $0x1,%ax
8010697c:	74 23                	je     801069a1 <sys_chdir+0x90>
    // TODO: REMOVE
    cprintf("not a dir\n");
8010697e:	c7 04 24 ce 96 10 80 	movl   $0x801096ce,(%esp)
80106985:	e8 37 9a ff ff       	call   801003c1 <cprintf>
    iunlockput(ip);
8010698a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010698d:	89 04 24             	mov    %eax,(%esp)
80106990:	e8 90 b2 ff ff       	call   80101c25 <iunlockput>
    end_op();
80106995:	e8 83 cd ff ff       	call   8010371d <end_op>
    return -1;
8010699a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010699f:	eb 2c                	jmp    801069cd <sys_chdir+0xbc>
  }
  iunlock(ip);
801069a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069a4:	89 04 24             	mov    %eax,(%esp)
801069a7:	e8 84 b1 ff ff       	call   80101b30 <iunlock>
  iput(curproc->cwd);
801069ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069af:	8b 40 68             	mov    0x68(%eax),%eax
801069b2:	89 04 24             	mov    %eax,(%esp)
801069b5:	e8 ba b1 ff ff       	call   80101b74 <iput>
  end_op();
801069ba:	e8 5e cd ff ff       	call   8010371d <end_op>
  curproc->cwd = ip;
801069bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801069c5:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801069c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069cd:	c9                   	leave  
801069ce:	c3                   	ret    

801069cf <sys_exec>:

int
sys_exec(void)
{
801069cf:	55                   	push   %ebp
801069d0:	89 e5                	mov    %esp,%ebp
801069d2:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801069d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069db:	89 44 24 04          	mov    %eax,0x4(%esp)
801069df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069e6:	e8 81 f3 ff ff       	call   80105d6c <argstr>
801069eb:	85 c0                	test   %eax,%eax
801069ed:	78 1a                	js     80106a09 <sys_exec+0x3a>
801069ef:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801069f5:	89 44 24 04          	mov    %eax,0x4(%esp)
801069f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a00:	e8 d0 f2 ff ff       	call   80105cd5 <argint>
80106a05:	85 c0                	test   %eax,%eax
80106a07:	79 0a                	jns    80106a13 <sys_exec+0x44>
    return -1;
80106a09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a0e:	e9 c7 00 00 00       	jmp    80106ada <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
80106a13:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106a1a:	00 
80106a1b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106a22:	00 
80106a23:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106a29:	89 04 24             	mov    %eax,(%esp)
80106a2c:	e8 71 ef ff ff       	call   801059a2 <memset>
  for(i=0;; i++){
80106a31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a3b:	83 f8 1f             	cmp    $0x1f,%eax
80106a3e:	76 0a                	jbe    80106a4a <sys_exec+0x7b>
      return -1;
80106a40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a45:	e9 90 00 00 00       	jmp    80106ada <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106a4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a4d:	c1 e0 02             	shl    $0x2,%eax
80106a50:	89 c2                	mov    %eax,%edx
80106a52:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106a58:	01 c2                	add    %eax,%edx
80106a5a:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106a60:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a64:	89 14 24             	mov    %edx,(%esp)
80106a67:	e8 c8 f1 ff ff       	call   80105c34 <fetchint>
80106a6c:	85 c0                	test   %eax,%eax
80106a6e:	79 07                	jns    80106a77 <sys_exec+0xa8>
      return -1;
80106a70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a75:	eb 63                	jmp    80106ada <sys_exec+0x10b>
    if(uarg == 0){
80106a77:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106a7d:	85 c0                	test   %eax,%eax
80106a7f:	75 26                	jne    80106aa7 <sys_exec+0xd8>
      argv[i] = 0;
80106a81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a84:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106a8b:	00 00 00 00 
      break;
80106a8f:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106a90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106a93:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106a99:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a9d:	89 04 24             	mov    %eax,(%esp)
80106aa0:	e8 63 a1 ff ff       	call   80100c08 <exec>
80106aa5:	eb 33                	jmp    80106ada <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106aa7:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106aad:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106ab0:	c1 e2 02             	shl    $0x2,%edx
80106ab3:	01 c2                	add    %eax,%edx
80106ab5:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106abb:	89 54 24 04          	mov    %edx,0x4(%esp)
80106abf:	89 04 24             	mov    %eax,(%esp)
80106ac2:	e8 ac f1 ff ff       	call   80105c73 <fetchstr>
80106ac7:	85 c0                	test   %eax,%eax
80106ac9:	79 07                	jns    80106ad2 <sys_exec+0x103>
      return -1;
80106acb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ad0:	eb 08                	jmp    80106ada <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106ad2:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106ad5:	e9 5e ff ff ff       	jmp    80106a38 <sys_exec+0x69>
  return exec(path, argv);
}
80106ada:	c9                   	leave  
80106adb:	c3                   	ret    

80106adc <sys_pipe>:

int
sys_pipe(void)
{
80106adc:	55                   	push   %ebp
80106add:	89 e5                	mov    %esp,%ebp
80106adf:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106ae2:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106ae9:	00 
80106aea:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106aed:	89 44 24 04          	mov    %eax,0x4(%esp)
80106af1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106af8:	e8 05 f2 ff ff       	call   80105d02 <argptr>
80106afd:	85 c0                	test   %eax,%eax
80106aff:	79 0a                	jns    80106b0b <sys_pipe+0x2f>
    return -1;
80106b01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b06:	e9 9a 00 00 00       	jmp    80106ba5 <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
80106b0b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106b0e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b12:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106b15:	89 04 24             	mov    %eax,(%esp)
80106b18:	e8 cb d3 ff ff       	call   80103ee8 <pipealloc>
80106b1d:	85 c0                	test   %eax,%eax
80106b1f:	79 07                	jns    80106b28 <sys_pipe+0x4c>
    return -1;
80106b21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b26:	eb 7d                	jmp    80106ba5 <sys_pipe+0xc9>
  fd0 = -1;
80106b28:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106b2f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106b32:	89 04 24             	mov    %eax,(%esp)
80106b35:	e8 66 f3 ff ff       	call   80105ea0 <fdalloc>
80106b3a:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106b3d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b41:	78 14                	js     80106b57 <sys_pipe+0x7b>
80106b43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b46:	89 04 24             	mov    %eax,(%esp)
80106b49:	e8 52 f3 ff ff       	call   80105ea0 <fdalloc>
80106b4e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106b51:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106b55:	79 36                	jns    80106b8d <sys_pipe+0xb1>
    if(fd0 >= 0)
80106b57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b5b:	78 13                	js     80106b70 <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
80106b5d:	e8 36 d7 ff ff       	call   80104298 <myproc>
80106b62:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106b65:	83 c2 08             	add    $0x8,%edx
80106b68:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106b6f:	00 
    fileclose(rf);
80106b70:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106b73:	89 04 24             	mov    %eax,(%esp)
80106b76:	e8 91 a5 ff ff       	call   8010110c <fileclose>
    fileclose(wf);
80106b7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b7e:	89 04 24             	mov    %eax,(%esp)
80106b81:	e8 86 a5 ff ff       	call   8010110c <fileclose>
    return -1;
80106b86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b8b:	eb 18                	jmp    80106ba5 <sys_pipe+0xc9>
  }
  fd[0] = fd0;
80106b8d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106b90:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106b93:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106b95:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106b98:	8d 50 04             	lea    0x4(%eax),%edx
80106b9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b9e:	89 02                	mov    %eax,(%edx)
  return 0;
80106ba0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106ba5:	c9                   	leave  
80106ba6:	c3                   	ret    

80106ba7 <sys_ccreate>:

int
sys_ccreate(void)
{
80106ba7:	55                   	push   %ebp
80106ba8:	89 e5                	mov    %esp,%ebp
80106baa:	56                   	push   %esi
80106bab:	53                   	push   %ebx
80106bac:	81 ec c0 00 00 00    	sub    $0xc0,%esp

  char *name, *argv[MAXARG];
  int i, progc, mproc;
  uint uargv, uarg, msz, mdsk;

  if(argstr(0, &name) < 0 || argint(2, &progc) < 0 || argint(3, &mproc) < 0 
80106bb2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106bb5:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bb9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106bc0:	e8 a7 f1 ff ff       	call   80105d6c <argstr>
80106bc5:	85 c0                	test   %eax,%eax
80106bc7:	78 68                	js     80106c31 <sys_ccreate+0x8a>
80106bc9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bd3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106bda:	e8 f6 f0 ff ff       	call   80105cd5 <argint>
80106bdf:	85 c0                	test   %eax,%eax
80106be1:	78 4e                	js     80106c31 <sys_ccreate+0x8a>
80106be3:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106be9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bed:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
80106bf4:	e8 dc f0 ff ff       	call   80105cd5 <argint>
80106bf9:	85 c0                	test   %eax,%eax
80106bfb:	78 34                	js     80106c31 <sys_ccreate+0x8a>
    || argint(4, (int*)&msz) < 0 || argint(5, (int*)&mdsk) < 0) {
80106bfd:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
80106c03:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c07:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106c0e:	e8 c2 f0 ff ff       	call   80105cd5 <argint>
80106c13:	85 c0                	test   %eax,%eax
80106c15:	78 1a                	js     80106c31 <sys_ccreate+0x8a>
80106c17:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80106c1d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c21:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
80106c28:	e8 a8 f0 ff ff       	call   80105cd5 <argint>
80106c2d:	85 c0                	test   %eax,%eax
80106c2f:	79 16                	jns    80106c47 <sys_ccreate+0xa0>
    cprintf("sys_ccreate: Error getting pointers\n");
80106c31:	c7 04 24 dc 96 10 80 	movl   $0x801096dc,(%esp)
80106c38:	e8 84 97 ff ff       	call   801003c1 <cprintf>
    return -1;
80106c3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c42:	e9 80 01 00 00       	jmp    80106dc7 <sys_ccreate+0x220>
  }

  if(argint(1, (int*)&uargv) < 0){
80106c47:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
80106c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c51:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106c58:	e8 78 f0 ff ff       	call   80105cd5 <argint>
80106c5d:	85 c0                	test   %eax,%eax
80106c5f:	79 0a                	jns    80106c6b <sys_ccreate+0xc4>
    return -1;
80106c61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c66:	e9 5c 01 00 00       	jmp    80106dc7 <sys_ccreate+0x220>
  }
  memset(argv, 0, sizeof(argv));
80106c6b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106c72:	00 
80106c73:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106c7a:	00 
80106c7b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106c81:	89 04 24             	mov    %eax,(%esp)
80106c84:	e8 19 ed ff ff       	call   801059a2 <memset>
  for(i=0;; i++){
80106c89:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c93:	83 f8 1f             	cmp    $0x1f,%eax
80106c96:	76 0a                	jbe    80106ca2 <sys_ccreate+0xfb>
      return -1;
80106c98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c9d:	e9 25 01 00 00       	jmp    80106dc7 <sys_ccreate+0x220>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ca5:	c1 e0 02             	shl    $0x2,%eax
80106ca8:	89 c2                	mov    %eax,%edx
80106caa:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80106cb0:	01 c2                	add    %eax,%edx
80106cb2:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
80106cb8:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cbc:	89 14 24             	mov    %edx,(%esp)
80106cbf:	e8 70 ef ff ff       	call   80105c34 <fetchint>
80106cc4:	85 c0                	test   %eax,%eax
80106cc6:	79 0a                	jns    80106cd2 <sys_ccreate+0x12b>
      return -1;
80106cc8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ccd:	e9 f5 00 00 00       	jmp    80106dc7 <sys_ccreate+0x220>
    if(uarg == 0){
80106cd2:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80106cd8:	85 c0                	test   %eax,%eax
80106cda:	75 53                	jne    80106d2f <sys_ccreate+0x188>
      argv[i] = 0;
80106cdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106cdf:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106ce6:	00 00 00 00 
      break;
80106cea:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_create\nuargv: %d\nname: %s\nmproc: %d\nmsz: %d\nmdsk: %d\n", uargv, name, mproc, msz, mdsk);
80106ceb:	8b b5 58 ff ff ff    	mov    -0xa8(%ebp),%esi
80106cf1:	8b 9d 5c ff ff ff    	mov    -0xa4(%ebp),%ebx
80106cf7:	8b 8d 68 ff ff ff    	mov    -0x98(%ebp),%ecx
80106cfd:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106d00:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80106d06:	89 74 24 14          	mov    %esi,0x14(%esp)
80106d0a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106d0e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106d12:	89 54 24 08          	mov    %edx,0x8(%esp)
80106d16:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d1a:	c7 04 24 04 97 10 80 	movl   $0x80109704,(%esp)
80106d21:	e8 9b 96 ff ff       	call   801003c1 <cprintf>
  for (i = 0; i < progc; i++) 
80106d26:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106d2d:	eb 50                	jmp    80106d7f <sys_ccreate+0x1d8>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106d2f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106d35:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d38:	c1 e2 02             	shl    $0x2,%edx
80106d3b:	01 c2                	add    %eax,%edx
80106d3d:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80106d43:	89 54 24 04          	mov    %edx,0x4(%esp)
80106d47:	89 04 24             	mov    %eax,(%esp)
80106d4a:	e8 24 ef ff ff       	call   80105c73 <fetchstr>
80106d4f:	85 c0                	test   %eax,%eax
80106d51:	79 07                	jns    80106d5a <sys_ccreate+0x1b3>
      return -1;
80106d53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d58:	eb 6d                	jmp    80106dc7 <sys_ccreate+0x220>

  if(argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106d5a:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106d5d:	e9 2e ff ff ff       	jmp    80106c90 <sys_ccreate+0xe9>

  cprintf("sys_create\nuargv: %d\nname: %s\nmproc: %d\nmsz: %d\nmdsk: %d\n", uargv, name, mproc, msz, mdsk);
  for (i = 0; i < progc; i++) 
    cprintf("\t%s\n", argv[i]);
80106d62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d65:	8b 84 85 70 ff ff ff 	mov    -0x90(%ebp,%eax,4),%eax
80106d6c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d70:	c7 04 24 3e 97 10 80 	movl   $0x8010973e,(%esp)
80106d77:	e8 45 96 ff ff       	call   801003c1 <cprintf>
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_create\nuargv: %d\nname: %s\nmproc: %d\nmsz: %d\nmdsk: %d\n", uargv, name, mproc, msz, mdsk);
  for (i = 0; i < progc; i++) 
80106d7c:	ff 45 f4             	incl   -0xc(%ebp)
80106d7f:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106d85:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80106d88:	7c d8                	jl     80106d62 <sys_ccreate+0x1bb>
    cprintf("\t%s\n", argv[i]);
  
  return ccreate(name, argv, progc, mproc, msz, mdsk);
80106d8a:	8b b5 58 ff ff ff    	mov    -0xa8(%ebp),%esi
80106d90:	8b 9d 5c ff ff ff    	mov    -0xa4(%ebp),%ebx
80106d96:	8b 8d 68 ff ff ff    	mov    -0x98(%ebp),%ecx
80106d9c:	8b 95 6c ff ff ff    	mov    -0x94(%ebp),%edx
80106da2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106da5:	89 74 24 14          	mov    %esi,0x14(%esp)
80106da9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106dad:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106db1:	89 54 24 08          	mov    %edx,0x8(%esp)
80106db5:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106dbb:	89 54 24 04          	mov    %edx,0x4(%esp)
80106dbf:	89 04 24             	mov    %eax,(%esp)
80106dc2:	e8 48 e5 ff ff       	call   8010530f <ccreate>
}
80106dc7:	81 c4 c0 00 00 00    	add    $0xc0,%esp
80106dcd:	5b                   	pop    %ebx
80106dce:	5e                   	pop    %esi
80106dcf:	5d                   	pop    %ebp
80106dd0:	c3                   	ret    

80106dd1 <sys_cstart>:

int
sys_cstart(void)
{
80106dd1:	55                   	push   %ebp
80106dd2:	89 e5                	mov    %esp,%ebp
80106dd4:	81 ec b8 00 00 00    	sub    $0xb8,%esp

  char *name, *prog, *argv[MAXARG];
  int i, argc;
  uint uargv, uarg;

  if(argstr(0, &name) < 0 || argstr(1, &prog) < 0 || argint(2, &argc) < 0) {
80106dda:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106ddd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106de1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106de8:	e8 7f ef ff ff       	call   80105d6c <argstr>
80106ded:	85 c0                	test   %eax,%eax
80106def:	78 31                	js     80106e22 <sys_cstart+0x51>
80106df1:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106df4:	89 44 24 04          	mov    %eax,0x4(%esp)
80106df8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106dff:	e8 68 ef ff ff       	call   80105d6c <argstr>
80106e04:	85 c0                	test   %eax,%eax
80106e06:	78 1a                	js     80106e22 <sys_cstart+0x51>
80106e08:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106e0e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e12:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106e19:	e8 b7 ee ff ff       	call   80105cd5 <argint>
80106e1e:	85 c0                	test   %eax,%eax
80106e20:	79 16                	jns    80106e38 <sys_cstart+0x67>
    cprintf("sys_ccreate: Error getting pointers\n");
80106e22:	c7 04 24 dc 96 10 80 	movl   $0x801096dc,(%esp)
80106e29:	e8 93 95 ff ff       	call   801003c1 <cprintf>
    return -1;
80106e2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e33:	e9 4e 01 00 00       	jmp    80106f86 <sys_cstart+0x1b5>
  }

  if(argint(1, (int*)&uargv) < 0){
80106e38:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
80106e3e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e42:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106e49:	e8 87 ee ff ff       	call   80105cd5 <argint>
80106e4e:	85 c0                	test   %eax,%eax
80106e50:	79 0a                	jns    80106e5c <sys_cstart+0x8b>
    return -1;
80106e52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e57:	e9 2a 01 00 00       	jmp    80106f86 <sys_cstart+0x1b5>
  }
  memset(argv, 0, sizeof(argv));
80106e5c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106e63:	00 
80106e64:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e6b:	00 
80106e6c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106e72:	89 04 24             	mov    %eax,(%esp)
80106e75:	e8 28 eb ff ff       	call   801059a2 <memset>
  for(i=0;; i++){
80106e7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e84:	83 f8 1f             	cmp    $0x1f,%eax
80106e87:	76 0a                	jbe    80106e93 <sys_cstart+0xc2>
      return -1;
80106e89:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e8e:	e9 f3 00 00 00       	jmp    80106f86 <sys_cstart+0x1b5>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e96:	c1 e0 02             	shl    $0x2,%eax
80106e99:	89 c2                	mov    %eax,%edx
80106e9b:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80106ea1:	01 c2                	add    %eax,%edx
80106ea3:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
80106ea9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ead:	89 14 24             	mov    %edx,(%esp)
80106eb0:	e8 7f ed ff ff       	call   80105c34 <fetchint>
80106eb5:	85 c0                	test   %eax,%eax
80106eb7:	79 0a                	jns    80106ec3 <sys_cstart+0xf2>
      return -1;
80106eb9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ebe:	e9 c3 00 00 00       	jmp    80106f86 <sys_cstart+0x1b5>
    if(uarg == 0){
80106ec3:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80106ec9:	85 c0                	test   %eax,%eax
80106ecb:	75 3f                	jne    80106f0c <sys_cstart+0x13b>
      argv[i] = 0;
80106ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ed0:	c7 84 85 6c ff ff ff 	movl   $0x0,-0x94(%ebp,%eax,4)
80106ed7:	00 00 00 00 
      break;
80106edb:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_cstart\n\tuargv: %d\n\tname: %s\n\targc: %d\n", uargv, name, argc);
80106edc:	8b 8d 68 ff ff ff    	mov    -0x98(%ebp),%ecx
80106ee2:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ee5:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80106eeb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106eef:	89 54 24 08          	mov    %edx,0x8(%esp)
80106ef3:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ef7:	c7 04 24 44 97 10 80 	movl   $0x80109744,(%esp)
80106efe:	e8 be 94 ff ff       	call   801003c1 <cprintf>
  for (i = 0; i < argc; i++) 
80106f03:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106f0a:	eb 50                	jmp    80106f5c <sys_cstart+0x18b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106f0c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106f12:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f15:	c1 e2 02             	shl    $0x2,%edx
80106f18:	01 c2                	add    %eax,%edx
80106f1a:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80106f20:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f24:	89 04 24             	mov    %eax,(%esp)
80106f27:	e8 47 ed ff ff       	call   80105c73 <fetchstr>
80106f2c:	85 c0                	test   %eax,%eax
80106f2e:	79 07                	jns    80106f37 <sys_cstart+0x166>
      return -1;
80106f30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f35:	eb 4f                	jmp    80106f86 <sys_cstart+0x1b5>

  if(argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106f37:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106f3a:	e9 42 ff ff ff       	jmp    80106e81 <sys_cstart+0xb0>

  cprintf("sys_cstart\n\tuargv: %d\n\tname: %s\n\targc: %d\n", uargv, name, argc);
  for (i = 0; i < argc; i++) 
    cprintf("\t%s\n", argv[i]);
80106f3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f42:	8b 84 85 6c ff ff ff 	mov    -0x94(%ebp,%eax,4),%eax
80106f49:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f4d:	c7 04 24 3e 97 10 80 	movl   $0x8010973e,(%esp)
80106f54:	e8 68 94 ff ff       	call   801003c1 <cprintf>
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_cstart\n\tuargv: %d\n\tname: %s\n\targc: %d\n", uargv, name, argc);
  for (i = 0; i < argc; i++) 
80106f59:	ff 45 f4             	incl   -0xc(%ebp)
80106f5c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106f62:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80106f65:	7c d8                	jl     80106f3f <sys_cstart+0x16e>
    cprintf("\t%s\n", argv[i]);
  
  return cstart(name, argv, argc);
80106f67:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
80106f6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f70:	89 54 24 08          	mov    %edx,0x8(%esp)
80106f74:	8d 95 6c ff ff ff    	lea    -0x94(%ebp),%edx
80106f7a:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f7e:	89 04 24             	mov    %eax,(%esp)
80106f81:	e8 e2 e4 ff ff       	call   80105468 <cstart>
}
80106f86:	c9                   	leave  
80106f87:	c3                   	ret    

80106f88 <sys_cstop>:

int
sys_cstop(void)
{
80106f88:	55                   	push   %ebp
80106f89:	89 e5                	mov    %esp,%ebp
  return 1;
80106f8b:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106f90:	5d                   	pop    %ebp
80106f91:	c3                   	ret    

80106f92 <sys_cinfo>:

int
sys_cinfo(void)
{
80106f92:	55                   	push   %ebp
80106f93:	89 e5                	mov    %esp,%ebp
  return 1;
80106f95:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106f9a:	5d                   	pop    %ebp
80106f9b:	c3                   	ret    

80106f9c <sys_cpause>:

int
sys_cpause(void)
{
80106f9c:	55                   	push   %ebp
80106f9d:	89 e5                	mov    %esp,%ebp
  return 1;
80106f9f:	b8 01 00 00 00       	mov    $0x1,%eax
80106fa4:	5d                   	pop    %ebp
80106fa5:	c3                   	ret    
	...

80106fa8 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106fa8:	55                   	push   %ebp
80106fa9:	89 e5                	mov    %esp,%ebp
80106fab:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106fae:	e8 19 d6 ff ff       	call   801045cc <fork>
}
80106fb3:	c9                   	leave  
80106fb4:	c3                   	ret    

80106fb5 <sys_exit>:

int
sys_exit(void)
{
80106fb5:	55                   	push   %ebp
80106fb6:	89 e5                	mov    %esp,%ebp
80106fb8:	83 ec 08             	sub    $0x8,%esp
  exit();
80106fbb:	e8 70 d7 ff ff       	call   80104730 <exit>
  return 0;  // not reached
80106fc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106fc5:	c9                   	leave  
80106fc6:	c3                   	ret    

80106fc7 <sys_wait>:

int
sys_wait(void)
{
80106fc7:	55                   	push   %ebp
80106fc8:	89 e5                	mov    %esp,%ebp
80106fca:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106fcd:	e8 8e d8 ff ff       	call   80104860 <wait>
}
80106fd2:	c9                   	leave  
80106fd3:	c3                   	ret    

80106fd4 <sys_kill>:

int
sys_kill(void)
{
80106fd4:	55                   	push   %ebp
80106fd5:	89 e5                	mov    %esp,%ebp
80106fd7:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106fda:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106fdd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fe1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106fe8:	e8 e8 ec ff ff       	call   80105cd5 <argint>
80106fed:	85 c0                	test   %eax,%eax
80106fef:	79 07                	jns    80106ff8 <sys_kill+0x24>
    return -1;
80106ff1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ff6:	eb 0b                	jmp    80107003 <sys_kill+0x2f>
  return kill(pid);
80106ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ffb:	89 04 24             	mov    %eax,(%esp)
80106ffe:	e8 e6 da ff ff       	call   80104ae9 <kill>
}
80107003:	c9                   	leave  
80107004:	c3                   	ret    

80107005 <sys_getpid>:

int
sys_getpid(void)
{
80107005:	55                   	push   %ebp
80107006:	89 e5                	mov    %esp,%ebp
80107008:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
8010700b:	e8 88 d2 ff ff       	call   80104298 <myproc>
80107010:	8b 40 10             	mov    0x10(%eax),%eax
}
80107013:	c9                   	leave  
80107014:	c3                   	ret    

80107015 <sys_sbrk>:

int
sys_sbrk(void)
{
80107015:	55                   	push   %ebp
80107016:	89 e5                	mov    %esp,%ebp
80107018:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
8010701b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010701e:	89 44 24 04          	mov    %eax,0x4(%esp)
80107022:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107029:	e8 a7 ec ff ff       	call   80105cd5 <argint>
8010702e:	85 c0                	test   %eax,%eax
80107030:	79 07                	jns    80107039 <sys_sbrk+0x24>
    return -1;
80107032:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107037:	eb 23                	jmp    8010705c <sys_sbrk+0x47>
  addr = myproc()->sz;
80107039:	e8 5a d2 ff ff       	call   80104298 <myproc>
8010703e:	8b 00                	mov    (%eax),%eax
80107040:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80107043:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107046:	89 04 24             	mov    %eax,(%esp)
80107049:	e8 e0 d4 ff ff       	call   8010452e <growproc>
8010704e:	85 c0                	test   %eax,%eax
80107050:	79 07                	jns    80107059 <sys_sbrk+0x44>
    return -1;
80107052:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107057:	eb 03                	jmp    8010705c <sys_sbrk+0x47>
  return addr;
80107059:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010705c:	c9                   	leave  
8010705d:	c3                   	ret    

8010705e <sys_sleep>:

int
sys_sleep(void)
{
8010705e:	55                   	push   %ebp
8010705f:	89 e5                	mov    %esp,%ebp
80107061:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80107064:	8d 45 f0             	lea    -0x10(%ebp),%eax
80107067:	89 44 24 04          	mov    %eax,0x4(%esp)
8010706b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107072:	e8 5e ec ff ff       	call   80105cd5 <argint>
80107077:	85 c0                	test   %eax,%eax
80107079:	79 07                	jns    80107082 <sys_sleep+0x24>
    return -1;
8010707b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107080:	eb 6b                	jmp    801070ed <sys_sleep+0x8f>
  acquire(&tickslock);
80107082:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
80107089:	e8 b1 e6 ff ff       	call   8010573f <acquire>
  ticks0 = ticks;
8010708e:	a1 40 61 12 80       	mov    0x80126140,%eax
80107093:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80107096:	eb 33                	jmp    801070cb <sys_sleep+0x6d>
    if(myproc()->killed){
80107098:	e8 fb d1 ff ff       	call   80104298 <myproc>
8010709d:	8b 40 24             	mov    0x24(%eax),%eax
801070a0:	85 c0                	test   %eax,%eax
801070a2:	74 13                	je     801070b7 <sys_sleep+0x59>
      release(&tickslock);
801070a4:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
801070ab:	e8 f9 e6 ff ff       	call   801057a9 <release>
      return -1;
801070b0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070b5:	eb 36                	jmp    801070ed <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
801070b7:	c7 44 24 04 00 59 12 	movl   $0x80125900,0x4(%esp)
801070be:	80 
801070bf:	c7 04 24 40 61 12 80 	movl   $0x80126140,(%esp)
801070c6:	e8 13 d9 ff ff       	call   801049de <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
801070cb:	a1 40 61 12 80       	mov    0x80126140,%eax
801070d0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801070d3:	89 c2                	mov    %eax,%edx
801070d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801070d8:	39 c2                	cmp    %eax,%edx
801070da:	72 bc                	jb     80107098 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801070dc:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
801070e3:	e8 c1 e6 ff ff       	call   801057a9 <release>
  return 0;
801070e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801070ed:	c9                   	leave  
801070ee:	c3                   	ret    

801070ef <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801070ef:	55                   	push   %ebp
801070f0:	89 e5                	mov    %esp,%ebp
801070f2:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
801070f5:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
801070fc:	e8 3e e6 ff ff       	call   8010573f <acquire>
  xticks = ticks;
80107101:	a1 40 61 12 80       	mov    0x80126140,%eax
80107106:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80107109:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
80107110:	e8 94 e6 ff ff       	call   801057a9 <release>
  return xticks;
80107115:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107118:	c9                   	leave  
80107119:	c3                   	ret    

8010711a <sys_getticks>:

int
sys_getticks(void)
{
8010711a:	55                   	push   %ebp
8010711b:	89 e5                	mov    %esp,%ebp
8010711d:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
80107120:	e8 73 d1 ff ff       	call   80104298 <myproc>
80107125:	8b 40 7c             	mov    0x7c(%eax),%eax
}
80107128:	c9                   	leave  
80107129:	c3                   	ret    
	...

8010712c <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010712c:	1e                   	push   %ds
  pushl %es
8010712d:	06                   	push   %es
  pushl %fs
8010712e:	0f a0                	push   %fs
  pushl %gs
80107130:	0f a8                	push   %gs
  pushal
80107132:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80107133:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80107137:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80107139:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
8010713b:	54                   	push   %esp
  call trap
8010713c:	e8 c0 01 00 00       	call   80107301 <trap>
  addl $4, %esp
80107141:	83 c4 04             	add    $0x4,%esp

80107144 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80107144:	61                   	popa   
  popl %gs
80107145:	0f a9                	pop    %gs
  popl %fs
80107147:	0f a1                	pop    %fs
  popl %es
80107149:	07                   	pop    %es
  popl %ds
8010714a:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010714b:	83 c4 08             	add    $0x8,%esp
  iret
8010714e:	cf                   	iret   
	...

80107150 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80107150:	55                   	push   %ebp
80107151:	89 e5                	mov    %esp,%ebp
80107153:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107156:	8b 45 0c             	mov    0xc(%ebp),%eax
80107159:	48                   	dec    %eax
8010715a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010715e:	8b 45 08             	mov    0x8(%ebp),%eax
80107161:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107165:	8b 45 08             	mov    0x8(%ebp),%eax
80107168:	c1 e8 10             	shr    $0x10,%eax
8010716b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
8010716f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107172:	0f 01 18             	lidtl  (%eax)
}
80107175:	c9                   	leave  
80107176:	c3                   	ret    

80107177 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80107177:	55                   	push   %ebp
80107178:	89 e5                	mov    %esp,%ebp
8010717a:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010717d:	0f 20 d0             	mov    %cr2,%eax
80107180:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80107183:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80107186:	c9                   	leave  
80107187:	c3                   	ret    

80107188 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80107188:	55                   	push   %ebp
80107189:	89 e5                	mov    %esp,%ebp
8010718b:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
8010718e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107195:	e9 b8 00 00 00       	jmp    80107252 <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010719a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010719d:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
801071a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801071a7:	66 89 04 d5 40 59 12 	mov    %ax,-0x7feda6c0(,%edx,8)
801071ae:	80 
801071af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071b2:	66 c7 04 c5 42 59 12 	movw   $0x8,-0x7feda6be(,%eax,8)
801071b9:	80 08 00 
801071bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071bf:	8a 14 c5 44 59 12 80 	mov    -0x7feda6bc(,%eax,8),%dl
801071c6:	83 e2 e0             	and    $0xffffffe0,%edx
801071c9:	88 14 c5 44 59 12 80 	mov    %dl,-0x7feda6bc(,%eax,8)
801071d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071d3:	8a 14 c5 44 59 12 80 	mov    -0x7feda6bc(,%eax,8),%dl
801071da:	83 e2 1f             	and    $0x1f,%edx
801071dd:	88 14 c5 44 59 12 80 	mov    %dl,-0x7feda6bc(,%eax,8)
801071e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071e7:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
801071ee:	83 e2 f0             	and    $0xfffffff0,%edx
801071f1:	83 ca 0e             	or     $0xe,%edx
801071f4:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
801071fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071fe:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
80107205:	83 e2 ef             	and    $0xffffffef,%edx
80107208:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
8010720f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107212:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
80107219:	83 e2 9f             	and    $0xffffff9f,%edx
8010721c:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
80107223:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107226:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
8010722d:	83 ca 80             	or     $0xffffff80,%edx
80107230:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
80107237:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010723a:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
80107241:	c1 e8 10             	shr    $0x10,%eax
80107244:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107247:	66 89 04 d5 46 59 12 	mov    %ax,-0x7feda6ba(,%edx,8)
8010724e:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
8010724f:	ff 45 f4             	incl   -0xc(%ebp)
80107252:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80107259:	0f 8e 3b ff ff ff    	jle    8010719a <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010725f:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
80107264:	66 a3 40 5b 12 80    	mov    %ax,0x80125b40
8010726a:	66 c7 05 42 5b 12 80 	movw   $0x8,0x80125b42
80107271:	08 00 
80107273:	a0 44 5b 12 80       	mov    0x80125b44,%al
80107278:	83 e0 e0             	and    $0xffffffe0,%eax
8010727b:	a2 44 5b 12 80       	mov    %al,0x80125b44
80107280:	a0 44 5b 12 80       	mov    0x80125b44,%al
80107285:	83 e0 1f             	and    $0x1f,%eax
80107288:	a2 44 5b 12 80       	mov    %al,0x80125b44
8010728d:	a0 45 5b 12 80       	mov    0x80125b45,%al
80107292:	83 c8 0f             	or     $0xf,%eax
80107295:	a2 45 5b 12 80       	mov    %al,0x80125b45
8010729a:	a0 45 5b 12 80       	mov    0x80125b45,%al
8010729f:	83 e0 ef             	and    $0xffffffef,%eax
801072a2:	a2 45 5b 12 80       	mov    %al,0x80125b45
801072a7:	a0 45 5b 12 80       	mov    0x80125b45,%al
801072ac:	83 c8 60             	or     $0x60,%eax
801072af:	a2 45 5b 12 80       	mov    %al,0x80125b45
801072b4:	a0 45 5b 12 80       	mov    0x80125b45,%al
801072b9:	83 c8 80             	or     $0xffffff80,%eax
801072bc:	a2 45 5b 12 80       	mov    %al,0x80125b45
801072c1:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
801072c6:	c1 e8 10             	shr    $0x10,%eax
801072c9:	66 a3 46 5b 12 80    	mov    %ax,0x80125b46

  initlock(&tickslock, "time");
801072cf:	c7 44 24 04 70 97 10 	movl   $0x80109770,0x4(%esp)
801072d6:	80 
801072d7:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
801072de:	e8 3b e4 ff ff       	call   8010571e <initlock>
}
801072e3:	c9                   	leave  
801072e4:	c3                   	ret    

801072e5 <idtinit>:

void
idtinit(void)
{
801072e5:	55                   	push   %ebp
801072e6:	89 e5                	mov    %esp,%ebp
801072e8:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801072eb:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801072f2:	00 
801072f3:	c7 04 24 40 59 12 80 	movl   $0x80125940,(%esp)
801072fa:	e8 51 fe ff ff       	call   80107150 <lidt>
}
801072ff:	c9                   	leave  
80107300:	c3                   	ret    

80107301 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107301:	55                   	push   %ebp
80107302:	89 e5                	mov    %esp,%ebp
80107304:	57                   	push   %edi
80107305:	56                   	push   %esi
80107306:	53                   	push   %ebx
80107307:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
8010730a:	8b 45 08             	mov    0x8(%ebp),%eax
8010730d:	8b 40 30             	mov    0x30(%eax),%eax
80107310:	83 f8 40             	cmp    $0x40,%eax
80107313:	75 3c                	jne    80107351 <trap+0x50>
    if(myproc()->killed)
80107315:	e8 7e cf ff ff       	call   80104298 <myproc>
8010731a:	8b 40 24             	mov    0x24(%eax),%eax
8010731d:	85 c0                	test   %eax,%eax
8010731f:	74 05                	je     80107326 <trap+0x25>
      exit();
80107321:	e8 0a d4 ff ff       	call   80104730 <exit>
    myproc()->tf = tf;
80107326:	e8 6d cf ff ff       	call   80104298 <myproc>
8010732b:	8b 55 08             	mov    0x8(%ebp),%edx
8010732e:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107331:	e8 6d ea ff ff       	call   80105da3 <syscall>
    if(myproc()->killed)
80107336:	e8 5d cf ff ff       	call   80104298 <myproc>
8010733b:	8b 40 24             	mov    0x24(%eax),%eax
8010733e:	85 c0                	test   %eax,%eax
80107340:	74 0a                	je     8010734c <trap+0x4b>
      exit();
80107342:	e8 e9 d3 ff ff       	call   80104730 <exit>
    return;
80107347:	e9 30 02 00 00       	jmp    8010757c <trap+0x27b>
8010734c:	e9 2b 02 00 00       	jmp    8010757c <trap+0x27b>
  }

  switch(tf->trapno){
80107351:	8b 45 08             	mov    0x8(%ebp),%eax
80107354:	8b 40 30             	mov    0x30(%eax),%eax
80107357:	83 e8 20             	sub    $0x20,%eax
8010735a:	83 f8 1f             	cmp    $0x1f,%eax
8010735d:	0f 87 cb 00 00 00    	ja     8010742e <trap+0x12d>
80107363:	8b 04 85 18 98 10 80 	mov    -0x7fef67e8(,%eax,4),%eax
8010736a:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010736c:	e8 6d d9 ff ff       	call   80104cde <cpuid>
80107371:	85 c0                	test   %eax,%eax
80107373:	75 2f                	jne    801073a4 <trap+0xa3>
      acquire(&tickslock);
80107375:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
8010737c:	e8 be e3 ff ff       	call   8010573f <acquire>
      ticks++;
80107381:	a1 40 61 12 80       	mov    0x80126140,%eax
80107386:	40                   	inc    %eax
80107387:	a3 40 61 12 80       	mov    %eax,0x80126140
      wakeup(&ticks);
8010738c:	c7 04 24 40 61 12 80 	movl   $0x80126140,(%esp)
80107393:	e8 34 d7 ff ff       	call   80104acc <wakeup>
      release(&tickslock);
80107398:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
8010739f:	e8 05 e4 ff ff       	call   801057a9 <release>
    }
    p = myproc();
801073a4:	e8 ef ce ff ff       	call   80104298 <myproc>
801073a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
801073ac:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801073b0:	74 0f                	je     801073c1 <trap+0xc0>
      p->ticks++;
801073b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801073b5:	8b 40 7c             	mov    0x7c(%eax),%eax
801073b8:	8d 50 01             	lea    0x1(%eax),%edx
801073bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801073be:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
801073c1:	e8 ad bd ff ff       	call   80103173 <lapiceoi>
    break;
801073c6:	e9 35 01 00 00       	jmp    80107500 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801073cb:	e8 22 b6 ff ff       	call   801029f2 <ideintr>
    lapiceoi();
801073d0:	e8 9e bd ff ff       	call   80103173 <lapiceoi>
    break;
801073d5:	e9 26 01 00 00       	jmp    80107500 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801073da:	e8 ab bb ff ff       	call   80102f8a <kbdintr>
    lapiceoi();
801073df:	e8 8f bd ff ff       	call   80103173 <lapiceoi>
    break;
801073e4:	e9 17 01 00 00       	jmp    80107500 <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801073e9:	e8 6f 03 00 00       	call   8010775d <uartintr>
    lapiceoi();
801073ee:	e8 80 bd ff ff       	call   80103173 <lapiceoi>
    break;
801073f3:	e9 08 01 00 00       	jmp    80107500 <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801073f8:	8b 45 08             	mov    0x8(%ebp),%eax
801073fb:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801073fe:	8b 45 08             	mov    0x8(%ebp),%eax
80107401:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107404:	0f b7 d8             	movzwl %ax,%ebx
80107407:	e8 d2 d8 ff ff       	call   80104cde <cpuid>
8010740c:	89 74 24 0c          	mov    %esi,0xc(%esp)
80107410:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107414:	89 44 24 04          	mov    %eax,0x4(%esp)
80107418:	c7 04 24 78 97 10 80 	movl   $0x80109778,(%esp)
8010741f:	e8 9d 8f ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80107424:	e8 4a bd ff ff       	call   80103173 <lapiceoi>
    break;
80107429:	e9 d2 00 00 00       	jmp    80107500 <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010742e:	e8 65 ce ff ff       	call   80104298 <myproc>
80107433:	85 c0                	test   %eax,%eax
80107435:	74 10                	je     80107447 <trap+0x146>
80107437:	8b 45 08             	mov    0x8(%ebp),%eax
8010743a:	8b 40 3c             	mov    0x3c(%eax),%eax
8010743d:	0f b7 c0             	movzwl %ax,%eax
80107440:	83 e0 03             	and    $0x3,%eax
80107443:	85 c0                	test   %eax,%eax
80107445:	75 40                	jne    80107487 <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107447:	e8 2b fd ff ff       	call   80107177 <rcr2>
8010744c:	89 c3                	mov    %eax,%ebx
8010744e:	8b 45 08             	mov    0x8(%ebp),%eax
80107451:	8b 70 38             	mov    0x38(%eax),%esi
80107454:	e8 85 d8 ff ff       	call   80104cde <cpuid>
80107459:	8b 55 08             	mov    0x8(%ebp),%edx
8010745c:	8b 52 30             	mov    0x30(%edx),%edx
8010745f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80107463:	89 74 24 0c          	mov    %esi,0xc(%esp)
80107467:	89 44 24 08          	mov    %eax,0x8(%esp)
8010746b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010746f:	c7 04 24 9c 97 10 80 	movl   $0x8010979c,(%esp)
80107476:	e8 46 8f ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
8010747b:	c7 04 24 ce 97 10 80 	movl   $0x801097ce,(%esp)
80107482:	e8 cd 90 ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107487:	e8 eb fc ff ff       	call   80107177 <rcr2>
8010748c:	89 c6                	mov    %eax,%esi
8010748e:	8b 45 08             	mov    0x8(%ebp),%eax
80107491:	8b 40 38             	mov    0x38(%eax),%eax
80107494:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80107497:	e8 42 d8 ff ff       	call   80104cde <cpuid>
8010749c:	89 c3                	mov    %eax,%ebx
8010749e:	8b 45 08             	mov    0x8(%ebp),%eax
801074a1:	8b 78 34             	mov    0x34(%eax),%edi
801074a4:	89 7d d0             	mov    %edi,-0x30(%ebp)
801074a7:	8b 45 08             	mov    0x8(%ebp),%eax
801074aa:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801074ad:	e8 e6 cd ff ff       	call   80104298 <myproc>
801074b2:	8d 50 6c             	lea    0x6c(%eax),%edx
801074b5:	89 55 cc             	mov    %edx,-0x34(%ebp)
801074b8:	e8 db cd ff ff       	call   80104298 <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801074bd:	8b 40 10             	mov    0x10(%eax),%eax
801074c0:	89 74 24 1c          	mov    %esi,0x1c(%esp)
801074c4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
801074c7:	89 4c 24 18          	mov    %ecx,0x18(%esp)
801074cb:	89 5c 24 14          	mov    %ebx,0x14(%esp)
801074cf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
801074d2:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801074d6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
801074da:	8b 55 cc             	mov    -0x34(%ebp),%edx
801074dd:	89 54 24 08          	mov    %edx,0x8(%esp)
801074e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801074e5:	c7 04 24 d4 97 10 80 	movl   $0x801097d4,(%esp)
801074ec:	e8 d0 8e ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801074f1:	e8 a2 cd ff ff       	call   80104298 <myproc>
801074f6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801074fd:	eb 01                	jmp    80107500 <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801074ff:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80107500:	e8 93 cd ff ff       	call   80104298 <myproc>
80107505:	85 c0                	test   %eax,%eax
80107507:	74 22                	je     8010752b <trap+0x22a>
80107509:	e8 8a cd ff ff       	call   80104298 <myproc>
8010750e:	8b 40 24             	mov    0x24(%eax),%eax
80107511:	85 c0                	test   %eax,%eax
80107513:	74 16                	je     8010752b <trap+0x22a>
80107515:	8b 45 08             	mov    0x8(%ebp),%eax
80107518:	8b 40 3c             	mov    0x3c(%eax),%eax
8010751b:	0f b7 c0             	movzwl %ax,%eax
8010751e:	83 e0 03             	and    $0x3,%eax
80107521:	83 f8 03             	cmp    $0x3,%eax
80107524:	75 05                	jne    8010752b <trap+0x22a>
    exit();
80107526:	e8 05 d2 ff ff       	call   80104730 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010752b:	e8 68 cd ff ff       	call   80104298 <myproc>
80107530:	85 c0                	test   %eax,%eax
80107532:	74 1d                	je     80107551 <trap+0x250>
80107534:	e8 5f cd ff ff       	call   80104298 <myproc>
80107539:	8b 40 0c             	mov    0xc(%eax),%eax
8010753c:	83 f8 04             	cmp    $0x4,%eax
8010753f:	75 10                	jne    80107551 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80107541:	8b 45 08             	mov    0x8(%ebp),%eax
80107544:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80107547:	83 f8 20             	cmp    $0x20,%eax
8010754a:	75 05                	jne    80107551 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
8010754c:	e8 32 d4 ff ff       	call   80104983 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80107551:	e8 42 cd ff ff       	call   80104298 <myproc>
80107556:	85 c0                	test   %eax,%eax
80107558:	74 22                	je     8010757c <trap+0x27b>
8010755a:	e8 39 cd ff ff       	call   80104298 <myproc>
8010755f:	8b 40 24             	mov    0x24(%eax),%eax
80107562:	85 c0                	test   %eax,%eax
80107564:	74 16                	je     8010757c <trap+0x27b>
80107566:	8b 45 08             	mov    0x8(%ebp),%eax
80107569:	8b 40 3c             	mov    0x3c(%eax),%eax
8010756c:	0f b7 c0             	movzwl %ax,%eax
8010756f:	83 e0 03             	and    $0x3,%eax
80107572:	83 f8 03             	cmp    $0x3,%eax
80107575:	75 05                	jne    8010757c <trap+0x27b>
    exit();
80107577:	e8 b4 d1 ff ff       	call   80104730 <exit>
}
8010757c:	83 c4 4c             	add    $0x4c,%esp
8010757f:	5b                   	pop    %ebx
80107580:	5e                   	pop    %esi
80107581:	5f                   	pop    %edi
80107582:	5d                   	pop    %ebp
80107583:	c3                   	ret    

80107584 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107584:	55                   	push   %ebp
80107585:	89 e5                	mov    %esp,%ebp
80107587:	83 ec 14             	sub    $0x14,%esp
8010758a:	8b 45 08             	mov    0x8(%ebp),%eax
8010758d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107591:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107594:	89 c2                	mov    %eax,%edx
80107596:	ec                   	in     (%dx),%al
80107597:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010759a:	8a 45 ff             	mov    -0x1(%ebp),%al
}
8010759d:	c9                   	leave  
8010759e:	c3                   	ret    

8010759f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
8010759f:	55                   	push   %ebp
801075a0:	89 e5                	mov    %esp,%ebp
801075a2:	83 ec 08             	sub    $0x8,%esp
801075a5:	8b 45 08             	mov    0x8(%ebp),%eax
801075a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801075ab:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801075af:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801075b2:	8a 45 f8             	mov    -0x8(%ebp),%al
801075b5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801075b8:	ee                   	out    %al,(%dx)
}
801075b9:	c9                   	leave  
801075ba:	c3                   	ret    

801075bb <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801075bb:	55                   	push   %ebp
801075bc:	89 e5                	mov    %esp,%ebp
801075be:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801075c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801075c8:	00 
801075c9:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801075d0:	e8 ca ff ff ff       	call   8010759f <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801075d5:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801075dc:	00 
801075dd:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801075e4:	e8 b6 ff ff ff       	call   8010759f <outb>
  outb(COM1+0, 115200/9600);
801075e9:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
801075f0:	00 
801075f1:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801075f8:	e8 a2 ff ff ff       	call   8010759f <outb>
  outb(COM1+1, 0);
801075fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107604:	00 
80107605:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
8010760c:	e8 8e ff ff ff       	call   8010759f <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107611:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80107618:	00 
80107619:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107620:	e8 7a ff ff ff       	call   8010759f <outb>
  outb(COM1+4, 0);
80107625:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010762c:	00 
8010762d:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107634:	e8 66 ff ff ff       	call   8010759f <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107639:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107640:	00 
80107641:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107648:	e8 52 ff ff ff       	call   8010759f <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010764d:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107654:	e8 2b ff ff ff       	call   80107584 <inb>
80107659:	3c ff                	cmp    $0xff,%al
8010765b:	75 02                	jne    8010765f <uartinit+0xa4>
    return;
8010765d:	eb 5b                	jmp    801076ba <uartinit+0xff>
  uart = 1;
8010765f:	c7 05 84 c7 10 80 01 	movl   $0x1,0x8010c784
80107666:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107669:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107670:	e8 0f ff ff ff       	call   80107584 <inb>
  inb(COM1+0);
80107675:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010767c:	e8 03 ff ff ff       	call   80107584 <inb>
  ioapicenable(IRQ_COM1, 0);
80107681:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107688:	00 
80107689:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107690:	e8 d2 b5 ff ff       	call   80102c67 <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107695:	c7 45 f4 98 98 10 80 	movl   $0x80109898,-0xc(%ebp)
8010769c:	eb 13                	jmp    801076b1 <uartinit+0xf6>
    uartputc(*p);
8010769e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076a1:	8a 00                	mov    (%eax),%al
801076a3:	0f be c0             	movsbl %al,%eax
801076a6:	89 04 24             	mov    %eax,(%esp)
801076a9:	e8 0e 00 00 00       	call   801076bc <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801076ae:	ff 45 f4             	incl   -0xc(%ebp)
801076b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076b4:	8a 00                	mov    (%eax),%al
801076b6:	84 c0                	test   %al,%al
801076b8:	75 e4                	jne    8010769e <uartinit+0xe3>
    uartputc(*p);
}
801076ba:	c9                   	leave  
801076bb:	c3                   	ret    

801076bc <uartputc>:

void
uartputc(int c)
{
801076bc:	55                   	push   %ebp
801076bd:	89 e5                	mov    %esp,%ebp
801076bf:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801076c2:	a1 84 c7 10 80       	mov    0x8010c784,%eax
801076c7:	85 c0                	test   %eax,%eax
801076c9:	75 02                	jne    801076cd <uartputc+0x11>
    return;
801076cb:	eb 4a                	jmp    80107717 <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801076cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801076d4:	eb 0f                	jmp    801076e5 <uartputc+0x29>
    microdelay(10);
801076d6:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801076dd:	e8 b6 ba ff ff       	call   80103198 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801076e2:	ff 45 f4             	incl   -0xc(%ebp)
801076e5:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801076e9:	7f 16                	jg     80107701 <uartputc+0x45>
801076eb:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801076f2:	e8 8d fe ff ff       	call   80107584 <inb>
801076f7:	0f b6 c0             	movzbl %al,%eax
801076fa:	83 e0 20             	and    $0x20,%eax
801076fd:	85 c0                	test   %eax,%eax
801076ff:	74 d5                	je     801076d6 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80107701:	8b 45 08             	mov    0x8(%ebp),%eax
80107704:	0f b6 c0             	movzbl %al,%eax
80107707:	89 44 24 04          	mov    %eax,0x4(%esp)
8010770b:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107712:	e8 88 fe ff ff       	call   8010759f <outb>
}
80107717:	c9                   	leave  
80107718:	c3                   	ret    

80107719 <uartgetc>:

static int
uartgetc(void)
{
80107719:	55                   	push   %ebp
8010771a:	89 e5                	mov    %esp,%ebp
8010771c:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
8010771f:	a1 84 c7 10 80       	mov    0x8010c784,%eax
80107724:	85 c0                	test   %eax,%eax
80107726:	75 07                	jne    8010772f <uartgetc+0x16>
    return -1;
80107728:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010772d:	eb 2c                	jmp    8010775b <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
8010772f:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107736:	e8 49 fe ff ff       	call   80107584 <inb>
8010773b:	0f b6 c0             	movzbl %al,%eax
8010773e:	83 e0 01             	and    $0x1,%eax
80107741:	85 c0                	test   %eax,%eax
80107743:	75 07                	jne    8010774c <uartgetc+0x33>
    return -1;
80107745:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010774a:	eb 0f                	jmp    8010775b <uartgetc+0x42>
  return inb(COM1+0);
8010774c:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107753:	e8 2c fe ff ff       	call   80107584 <inb>
80107758:	0f b6 c0             	movzbl %al,%eax
}
8010775b:	c9                   	leave  
8010775c:	c3                   	ret    

8010775d <uartintr>:

void
uartintr(void)
{
8010775d:	55                   	push   %ebp
8010775e:	89 e5                	mov    %esp,%ebp
80107760:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80107763:	c7 04 24 19 77 10 80 	movl   $0x80107719,(%esp)
8010776a:	e8 86 90 ff ff       	call   801007f5 <consoleintr>
}
8010776f:	c9                   	leave  
80107770:	c3                   	ret    
80107771:	00 00                	add    %al,(%eax)
	...

80107774 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107774:	6a 00                	push   $0x0
  pushl $0
80107776:	6a 00                	push   $0x0
  jmp alltraps
80107778:	e9 af f9 ff ff       	jmp    8010712c <alltraps>

8010777d <vector1>:
.globl vector1
vector1:
  pushl $0
8010777d:	6a 00                	push   $0x0
  pushl $1
8010777f:	6a 01                	push   $0x1
  jmp alltraps
80107781:	e9 a6 f9 ff ff       	jmp    8010712c <alltraps>

80107786 <vector2>:
.globl vector2
vector2:
  pushl $0
80107786:	6a 00                	push   $0x0
  pushl $2
80107788:	6a 02                	push   $0x2
  jmp alltraps
8010778a:	e9 9d f9 ff ff       	jmp    8010712c <alltraps>

8010778f <vector3>:
.globl vector3
vector3:
  pushl $0
8010778f:	6a 00                	push   $0x0
  pushl $3
80107791:	6a 03                	push   $0x3
  jmp alltraps
80107793:	e9 94 f9 ff ff       	jmp    8010712c <alltraps>

80107798 <vector4>:
.globl vector4
vector4:
  pushl $0
80107798:	6a 00                	push   $0x0
  pushl $4
8010779a:	6a 04                	push   $0x4
  jmp alltraps
8010779c:	e9 8b f9 ff ff       	jmp    8010712c <alltraps>

801077a1 <vector5>:
.globl vector5
vector5:
  pushl $0
801077a1:	6a 00                	push   $0x0
  pushl $5
801077a3:	6a 05                	push   $0x5
  jmp alltraps
801077a5:	e9 82 f9 ff ff       	jmp    8010712c <alltraps>

801077aa <vector6>:
.globl vector6
vector6:
  pushl $0
801077aa:	6a 00                	push   $0x0
  pushl $6
801077ac:	6a 06                	push   $0x6
  jmp alltraps
801077ae:	e9 79 f9 ff ff       	jmp    8010712c <alltraps>

801077b3 <vector7>:
.globl vector7
vector7:
  pushl $0
801077b3:	6a 00                	push   $0x0
  pushl $7
801077b5:	6a 07                	push   $0x7
  jmp alltraps
801077b7:	e9 70 f9 ff ff       	jmp    8010712c <alltraps>

801077bc <vector8>:
.globl vector8
vector8:
  pushl $8
801077bc:	6a 08                	push   $0x8
  jmp alltraps
801077be:	e9 69 f9 ff ff       	jmp    8010712c <alltraps>

801077c3 <vector9>:
.globl vector9
vector9:
  pushl $0
801077c3:	6a 00                	push   $0x0
  pushl $9
801077c5:	6a 09                	push   $0x9
  jmp alltraps
801077c7:	e9 60 f9 ff ff       	jmp    8010712c <alltraps>

801077cc <vector10>:
.globl vector10
vector10:
  pushl $10
801077cc:	6a 0a                	push   $0xa
  jmp alltraps
801077ce:	e9 59 f9 ff ff       	jmp    8010712c <alltraps>

801077d3 <vector11>:
.globl vector11
vector11:
  pushl $11
801077d3:	6a 0b                	push   $0xb
  jmp alltraps
801077d5:	e9 52 f9 ff ff       	jmp    8010712c <alltraps>

801077da <vector12>:
.globl vector12
vector12:
  pushl $12
801077da:	6a 0c                	push   $0xc
  jmp alltraps
801077dc:	e9 4b f9 ff ff       	jmp    8010712c <alltraps>

801077e1 <vector13>:
.globl vector13
vector13:
  pushl $13
801077e1:	6a 0d                	push   $0xd
  jmp alltraps
801077e3:	e9 44 f9 ff ff       	jmp    8010712c <alltraps>

801077e8 <vector14>:
.globl vector14
vector14:
  pushl $14
801077e8:	6a 0e                	push   $0xe
  jmp alltraps
801077ea:	e9 3d f9 ff ff       	jmp    8010712c <alltraps>

801077ef <vector15>:
.globl vector15
vector15:
  pushl $0
801077ef:	6a 00                	push   $0x0
  pushl $15
801077f1:	6a 0f                	push   $0xf
  jmp alltraps
801077f3:	e9 34 f9 ff ff       	jmp    8010712c <alltraps>

801077f8 <vector16>:
.globl vector16
vector16:
  pushl $0
801077f8:	6a 00                	push   $0x0
  pushl $16
801077fa:	6a 10                	push   $0x10
  jmp alltraps
801077fc:	e9 2b f9 ff ff       	jmp    8010712c <alltraps>

80107801 <vector17>:
.globl vector17
vector17:
  pushl $17
80107801:	6a 11                	push   $0x11
  jmp alltraps
80107803:	e9 24 f9 ff ff       	jmp    8010712c <alltraps>

80107808 <vector18>:
.globl vector18
vector18:
  pushl $0
80107808:	6a 00                	push   $0x0
  pushl $18
8010780a:	6a 12                	push   $0x12
  jmp alltraps
8010780c:	e9 1b f9 ff ff       	jmp    8010712c <alltraps>

80107811 <vector19>:
.globl vector19
vector19:
  pushl $0
80107811:	6a 00                	push   $0x0
  pushl $19
80107813:	6a 13                	push   $0x13
  jmp alltraps
80107815:	e9 12 f9 ff ff       	jmp    8010712c <alltraps>

8010781a <vector20>:
.globl vector20
vector20:
  pushl $0
8010781a:	6a 00                	push   $0x0
  pushl $20
8010781c:	6a 14                	push   $0x14
  jmp alltraps
8010781e:	e9 09 f9 ff ff       	jmp    8010712c <alltraps>

80107823 <vector21>:
.globl vector21
vector21:
  pushl $0
80107823:	6a 00                	push   $0x0
  pushl $21
80107825:	6a 15                	push   $0x15
  jmp alltraps
80107827:	e9 00 f9 ff ff       	jmp    8010712c <alltraps>

8010782c <vector22>:
.globl vector22
vector22:
  pushl $0
8010782c:	6a 00                	push   $0x0
  pushl $22
8010782e:	6a 16                	push   $0x16
  jmp alltraps
80107830:	e9 f7 f8 ff ff       	jmp    8010712c <alltraps>

80107835 <vector23>:
.globl vector23
vector23:
  pushl $0
80107835:	6a 00                	push   $0x0
  pushl $23
80107837:	6a 17                	push   $0x17
  jmp alltraps
80107839:	e9 ee f8 ff ff       	jmp    8010712c <alltraps>

8010783e <vector24>:
.globl vector24
vector24:
  pushl $0
8010783e:	6a 00                	push   $0x0
  pushl $24
80107840:	6a 18                	push   $0x18
  jmp alltraps
80107842:	e9 e5 f8 ff ff       	jmp    8010712c <alltraps>

80107847 <vector25>:
.globl vector25
vector25:
  pushl $0
80107847:	6a 00                	push   $0x0
  pushl $25
80107849:	6a 19                	push   $0x19
  jmp alltraps
8010784b:	e9 dc f8 ff ff       	jmp    8010712c <alltraps>

80107850 <vector26>:
.globl vector26
vector26:
  pushl $0
80107850:	6a 00                	push   $0x0
  pushl $26
80107852:	6a 1a                	push   $0x1a
  jmp alltraps
80107854:	e9 d3 f8 ff ff       	jmp    8010712c <alltraps>

80107859 <vector27>:
.globl vector27
vector27:
  pushl $0
80107859:	6a 00                	push   $0x0
  pushl $27
8010785b:	6a 1b                	push   $0x1b
  jmp alltraps
8010785d:	e9 ca f8 ff ff       	jmp    8010712c <alltraps>

80107862 <vector28>:
.globl vector28
vector28:
  pushl $0
80107862:	6a 00                	push   $0x0
  pushl $28
80107864:	6a 1c                	push   $0x1c
  jmp alltraps
80107866:	e9 c1 f8 ff ff       	jmp    8010712c <alltraps>

8010786b <vector29>:
.globl vector29
vector29:
  pushl $0
8010786b:	6a 00                	push   $0x0
  pushl $29
8010786d:	6a 1d                	push   $0x1d
  jmp alltraps
8010786f:	e9 b8 f8 ff ff       	jmp    8010712c <alltraps>

80107874 <vector30>:
.globl vector30
vector30:
  pushl $0
80107874:	6a 00                	push   $0x0
  pushl $30
80107876:	6a 1e                	push   $0x1e
  jmp alltraps
80107878:	e9 af f8 ff ff       	jmp    8010712c <alltraps>

8010787d <vector31>:
.globl vector31
vector31:
  pushl $0
8010787d:	6a 00                	push   $0x0
  pushl $31
8010787f:	6a 1f                	push   $0x1f
  jmp alltraps
80107881:	e9 a6 f8 ff ff       	jmp    8010712c <alltraps>

80107886 <vector32>:
.globl vector32
vector32:
  pushl $0
80107886:	6a 00                	push   $0x0
  pushl $32
80107888:	6a 20                	push   $0x20
  jmp alltraps
8010788a:	e9 9d f8 ff ff       	jmp    8010712c <alltraps>

8010788f <vector33>:
.globl vector33
vector33:
  pushl $0
8010788f:	6a 00                	push   $0x0
  pushl $33
80107891:	6a 21                	push   $0x21
  jmp alltraps
80107893:	e9 94 f8 ff ff       	jmp    8010712c <alltraps>

80107898 <vector34>:
.globl vector34
vector34:
  pushl $0
80107898:	6a 00                	push   $0x0
  pushl $34
8010789a:	6a 22                	push   $0x22
  jmp alltraps
8010789c:	e9 8b f8 ff ff       	jmp    8010712c <alltraps>

801078a1 <vector35>:
.globl vector35
vector35:
  pushl $0
801078a1:	6a 00                	push   $0x0
  pushl $35
801078a3:	6a 23                	push   $0x23
  jmp alltraps
801078a5:	e9 82 f8 ff ff       	jmp    8010712c <alltraps>

801078aa <vector36>:
.globl vector36
vector36:
  pushl $0
801078aa:	6a 00                	push   $0x0
  pushl $36
801078ac:	6a 24                	push   $0x24
  jmp alltraps
801078ae:	e9 79 f8 ff ff       	jmp    8010712c <alltraps>

801078b3 <vector37>:
.globl vector37
vector37:
  pushl $0
801078b3:	6a 00                	push   $0x0
  pushl $37
801078b5:	6a 25                	push   $0x25
  jmp alltraps
801078b7:	e9 70 f8 ff ff       	jmp    8010712c <alltraps>

801078bc <vector38>:
.globl vector38
vector38:
  pushl $0
801078bc:	6a 00                	push   $0x0
  pushl $38
801078be:	6a 26                	push   $0x26
  jmp alltraps
801078c0:	e9 67 f8 ff ff       	jmp    8010712c <alltraps>

801078c5 <vector39>:
.globl vector39
vector39:
  pushl $0
801078c5:	6a 00                	push   $0x0
  pushl $39
801078c7:	6a 27                	push   $0x27
  jmp alltraps
801078c9:	e9 5e f8 ff ff       	jmp    8010712c <alltraps>

801078ce <vector40>:
.globl vector40
vector40:
  pushl $0
801078ce:	6a 00                	push   $0x0
  pushl $40
801078d0:	6a 28                	push   $0x28
  jmp alltraps
801078d2:	e9 55 f8 ff ff       	jmp    8010712c <alltraps>

801078d7 <vector41>:
.globl vector41
vector41:
  pushl $0
801078d7:	6a 00                	push   $0x0
  pushl $41
801078d9:	6a 29                	push   $0x29
  jmp alltraps
801078db:	e9 4c f8 ff ff       	jmp    8010712c <alltraps>

801078e0 <vector42>:
.globl vector42
vector42:
  pushl $0
801078e0:	6a 00                	push   $0x0
  pushl $42
801078e2:	6a 2a                	push   $0x2a
  jmp alltraps
801078e4:	e9 43 f8 ff ff       	jmp    8010712c <alltraps>

801078e9 <vector43>:
.globl vector43
vector43:
  pushl $0
801078e9:	6a 00                	push   $0x0
  pushl $43
801078eb:	6a 2b                	push   $0x2b
  jmp alltraps
801078ed:	e9 3a f8 ff ff       	jmp    8010712c <alltraps>

801078f2 <vector44>:
.globl vector44
vector44:
  pushl $0
801078f2:	6a 00                	push   $0x0
  pushl $44
801078f4:	6a 2c                	push   $0x2c
  jmp alltraps
801078f6:	e9 31 f8 ff ff       	jmp    8010712c <alltraps>

801078fb <vector45>:
.globl vector45
vector45:
  pushl $0
801078fb:	6a 00                	push   $0x0
  pushl $45
801078fd:	6a 2d                	push   $0x2d
  jmp alltraps
801078ff:	e9 28 f8 ff ff       	jmp    8010712c <alltraps>

80107904 <vector46>:
.globl vector46
vector46:
  pushl $0
80107904:	6a 00                	push   $0x0
  pushl $46
80107906:	6a 2e                	push   $0x2e
  jmp alltraps
80107908:	e9 1f f8 ff ff       	jmp    8010712c <alltraps>

8010790d <vector47>:
.globl vector47
vector47:
  pushl $0
8010790d:	6a 00                	push   $0x0
  pushl $47
8010790f:	6a 2f                	push   $0x2f
  jmp alltraps
80107911:	e9 16 f8 ff ff       	jmp    8010712c <alltraps>

80107916 <vector48>:
.globl vector48
vector48:
  pushl $0
80107916:	6a 00                	push   $0x0
  pushl $48
80107918:	6a 30                	push   $0x30
  jmp alltraps
8010791a:	e9 0d f8 ff ff       	jmp    8010712c <alltraps>

8010791f <vector49>:
.globl vector49
vector49:
  pushl $0
8010791f:	6a 00                	push   $0x0
  pushl $49
80107921:	6a 31                	push   $0x31
  jmp alltraps
80107923:	e9 04 f8 ff ff       	jmp    8010712c <alltraps>

80107928 <vector50>:
.globl vector50
vector50:
  pushl $0
80107928:	6a 00                	push   $0x0
  pushl $50
8010792a:	6a 32                	push   $0x32
  jmp alltraps
8010792c:	e9 fb f7 ff ff       	jmp    8010712c <alltraps>

80107931 <vector51>:
.globl vector51
vector51:
  pushl $0
80107931:	6a 00                	push   $0x0
  pushl $51
80107933:	6a 33                	push   $0x33
  jmp alltraps
80107935:	e9 f2 f7 ff ff       	jmp    8010712c <alltraps>

8010793a <vector52>:
.globl vector52
vector52:
  pushl $0
8010793a:	6a 00                	push   $0x0
  pushl $52
8010793c:	6a 34                	push   $0x34
  jmp alltraps
8010793e:	e9 e9 f7 ff ff       	jmp    8010712c <alltraps>

80107943 <vector53>:
.globl vector53
vector53:
  pushl $0
80107943:	6a 00                	push   $0x0
  pushl $53
80107945:	6a 35                	push   $0x35
  jmp alltraps
80107947:	e9 e0 f7 ff ff       	jmp    8010712c <alltraps>

8010794c <vector54>:
.globl vector54
vector54:
  pushl $0
8010794c:	6a 00                	push   $0x0
  pushl $54
8010794e:	6a 36                	push   $0x36
  jmp alltraps
80107950:	e9 d7 f7 ff ff       	jmp    8010712c <alltraps>

80107955 <vector55>:
.globl vector55
vector55:
  pushl $0
80107955:	6a 00                	push   $0x0
  pushl $55
80107957:	6a 37                	push   $0x37
  jmp alltraps
80107959:	e9 ce f7 ff ff       	jmp    8010712c <alltraps>

8010795e <vector56>:
.globl vector56
vector56:
  pushl $0
8010795e:	6a 00                	push   $0x0
  pushl $56
80107960:	6a 38                	push   $0x38
  jmp alltraps
80107962:	e9 c5 f7 ff ff       	jmp    8010712c <alltraps>

80107967 <vector57>:
.globl vector57
vector57:
  pushl $0
80107967:	6a 00                	push   $0x0
  pushl $57
80107969:	6a 39                	push   $0x39
  jmp alltraps
8010796b:	e9 bc f7 ff ff       	jmp    8010712c <alltraps>

80107970 <vector58>:
.globl vector58
vector58:
  pushl $0
80107970:	6a 00                	push   $0x0
  pushl $58
80107972:	6a 3a                	push   $0x3a
  jmp alltraps
80107974:	e9 b3 f7 ff ff       	jmp    8010712c <alltraps>

80107979 <vector59>:
.globl vector59
vector59:
  pushl $0
80107979:	6a 00                	push   $0x0
  pushl $59
8010797b:	6a 3b                	push   $0x3b
  jmp alltraps
8010797d:	e9 aa f7 ff ff       	jmp    8010712c <alltraps>

80107982 <vector60>:
.globl vector60
vector60:
  pushl $0
80107982:	6a 00                	push   $0x0
  pushl $60
80107984:	6a 3c                	push   $0x3c
  jmp alltraps
80107986:	e9 a1 f7 ff ff       	jmp    8010712c <alltraps>

8010798b <vector61>:
.globl vector61
vector61:
  pushl $0
8010798b:	6a 00                	push   $0x0
  pushl $61
8010798d:	6a 3d                	push   $0x3d
  jmp alltraps
8010798f:	e9 98 f7 ff ff       	jmp    8010712c <alltraps>

80107994 <vector62>:
.globl vector62
vector62:
  pushl $0
80107994:	6a 00                	push   $0x0
  pushl $62
80107996:	6a 3e                	push   $0x3e
  jmp alltraps
80107998:	e9 8f f7 ff ff       	jmp    8010712c <alltraps>

8010799d <vector63>:
.globl vector63
vector63:
  pushl $0
8010799d:	6a 00                	push   $0x0
  pushl $63
8010799f:	6a 3f                	push   $0x3f
  jmp alltraps
801079a1:	e9 86 f7 ff ff       	jmp    8010712c <alltraps>

801079a6 <vector64>:
.globl vector64
vector64:
  pushl $0
801079a6:	6a 00                	push   $0x0
  pushl $64
801079a8:	6a 40                	push   $0x40
  jmp alltraps
801079aa:	e9 7d f7 ff ff       	jmp    8010712c <alltraps>

801079af <vector65>:
.globl vector65
vector65:
  pushl $0
801079af:	6a 00                	push   $0x0
  pushl $65
801079b1:	6a 41                	push   $0x41
  jmp alltraps
801079b3:	e9 74 f7 ff ff       	jmp    8010712c <alltraps>

801079b8 <vector66>:
.globl vector66
vector66:
  pushl $0
801079b8:	6a 00                	push   $0x0
  pushl $66
801079ba:	6a 42                	push   $0x42
  jmp alltraps
801079bc:	e9 6b f7 ff ff       	jmp    8010712c <alltraps>

801079c1 <vector67>:
.globl vector67
vector67:
  pushl $0
801079c1:	6a 00                	push   $0x0
  pushl $67
801079c3:	6a 43                	push   $0x43
  jmp alltraps
801079c5:	e9 62 f7 ff ff       	jmp    8010712c <alltraps>

801079ca <vector68>:
.globl vector68
vector68:
  pushl $0
801079ca:	6a 00                	push   $0x0
  pushl $68
801079cc:	6a 44                	push   $0x44
  jmp alltraps
801079ce:	e9 59 f7 ff ff       	jmp    8010712c <alltraps>

801079d3 <vector69>:
.globl vector69
vector69:
  pushl $0
801079d3:	6a 00                	push   $0x0
  pushl $69
801079d5:	6a 45                	push   $0x45
  jmp alltraps
801079d7:	e9 50 f7 ff ff       	jmp    8010712c <alltraps>

801079dc <vector70>:
.globl vector70
vector70:
  pushl $0
801079dc:	6a 00                	push   $0x0
  pushl $70
801079de:	6a 46                	push   $0x46
  jmp alltraps
801079e0:	e9 47 f7 ff ff       	jmp    8010712c <alltraps>

801079e5 <vector71>:
.globl vector71
vector71:
  pushl $0
801079e5:	6a 00                	push   $0x0
  pushl $71
801079e7:	6a 47                	push   $0x47
  jmp alltraps
801079e9:	e9 3e f7 ff ff       	jmp    8010712c <alltraps>

801079ee <vector72>:
.globl vector72
vector72:
  pushl $0
801079ee:	6a 00                	push   $0x0
  pushl $72
801079f0:	6a 48                	push   $0x48
  jmp alltraps
801079f2:	e9 35 f7 ff ff       	jmp    8010712c <alltraps>

801079f7 <vector73>:
.globl vector73
vector73:
  pushl $0
801079f7:	6a 00                	push   $0x0
  pushl $73
801079f9:	6a 49                	push   $0x49
  jmp alltraps
801079fb:	e9 2c f7 ff ff       	jmp    8010712c <alltraps>

80107a00 <vector74>:
.globl vector74
vector74:
  pushl $0
80107a00:	6a 00                	push   $0x0
  pushl $74
80107a02:	6a 4a                	push   $0x4a
  jmp alltraps
80107a04:	e9 23 f7 ff ff       	jmp    8010712c <alltraps>

80107a09 <vector75>:
.globl vector75
vector75:
  pushl $0
80107a09:	6a 00                	push   $0x0
  pushl $75
80107a0b:	6a 4b                	push   $0x4b
  jmp alltraps
80107a0d:	e9 1a f7 ff ff       	jmp    8010712c <alltraps>

80107a12 <vector76>:
.globl vector76
vector76:
  pushl $0
80107a12:	6a 00                	push   $0x0
  pushl $76
80107a14:	6a 4c                	push   $0x4c
  jmp alltraps
80107a16:	e9 11 f7 ff ff       	jmp    8010712c <alltraps>

80107a1b <vector77>:
.globl vector77
vector77:
  pushl $0
80107a1b:	6a 00                	push   $0x0
  pushl $77
80107a1d:	6a 4d                	push   $0x4d
  jmp alltraps
80107a1f:	e9 08 f7 ff ff       	jmp    8010712c <alltraps>

80107a24 <vector78>:
.globl vector78
vector78:
  pushl $0
80107a24:	6a 00                	push   $0x0
  pushl $78
80107a26:	6a 4e                	push   $0x4e
  jmp alltraps
80107a28:	e9 ff f6 ff ff       	jmp    8010712c <alltraps>

80107a2d <vector79>:
.globl vector79
vector79:
  pushl $0
80107a2d:	6a 00                	push   $0x0
  pushl $79
80107a2f:	6a 4f                	push   $0x4f
  jmp alltraps
80107a31:	e9 f6 f6 ff ff       	jmp    8010712c <alltraps>

80107a36 <vector80>:
.globl vector80
vector80:
  pushl $0
80107a36:	6a 00                	push   $0x0
  pushl $80
80107a38:	6a 50                	push   $0x50
  jmp alltraps
80107a3a:	e9 ed f6 ff ff       	jmp    8010712c <alltraps>

80107a3f <vector81>:
.globl vector81
vector81:
  pushl $0
80107a3f:	6a 00                	push   $0x0
  pushl $81
80107a41:	6a 51                	push   $0x51
  jmp alltraps
80107a43:	e9 e4 f6 ff ff       	jmp    8010712c <alltraps>

80107a48 <vector82>:
.globl vector82
vector82:
  pushl $0
80107a48:	6a 00                	push   $0x0
  pushl $82
80107a4a:	6a 52                	push   $0x52
  jmp alltraps
80107a4c:	e9 db f6 ff ff       	jmp    8010712c <alltraps>

80107a51 <vector83>:
.globl vector83
vector83:
  pushl $0
80107a51:	6a 00                	push   $0x0
  pushl $83
80107a53:	6a 53                	push   $0x53
  jmp alltraps
80107a55:	e9 d2 f6 ff ff       	jmp    8010712c <alltraps>

80107a5a <vector84>:
.globl vector84
vector84:
  pushl $0
80107a5a:	6a 00                	push   $0x0
  pushl $84
80107a5c:	6a 54                	push   $0x54
  jmp alltraps
80107a5e:	e9 c9 f6 ff ff       	jmp    8010712c <alltraps>

80107a63 <vector85>:
.globl vector85
vector85:
  pushl $0
80107a63:	6a 00                	push   $0x0
  pushl $85
80107a65:	6a 55                	push   $0x55
  jmp alltraps
80107a67:	e9 c0 f6 ff ff       	jmp    8010712c <alltraps>

80107a6c <vector86>:
.globl vector86
vector86:
  pushl $0
80107a6c:	6a 00                	push   $0x0
  pushl $86
80107a6e:	6a 56                	push   $0x56
  jmp alltraps
80107a70:	e9 b7 f6 ff ff       	jmp    8010712c <alltraps>

80107a75 <vector87>:
.globl vector87
vector87:
  pushl $0
80107a75:	6a 00                	push   $0x0
  pushl $87
80107a77:	6a 57                	push   $0x57
  jmp alltraps
80107a79:	e9 ae f6 ff ff       	jmp    8010712c <alltraps>

80107a7e <vector88>:
.globl vector88
vector88:
  pushl $0
80107a7e:	6a 00                	push   $0x0
  pushl $88
80107a80:	6a 58                	push   $0x58
  jmp alltraps
80107a82:	e9 a5 f6 ff ff       	jmp    8010712c <alltraps>

80107a87 <vector89>:
.globl vector89
vector89:
  pushl $0
80107a87:	6a 00                	push   $0x0
  pushl $89
80107a89:	6a 59                	push   $0x59
  jmp alltraps
80107a8b:	e9 9c f6 ff ff       	jmp    8010712c <alltraps>

80107a90 <vector90>:
.globl vector90
vector90:
  pushl $0
80107a90:	6a 00                	push   $0x0
  pushl $90
80107a92:	6a 5a                	push   $0x5a
  jmp alltraps
80107a94:	e9 93 f6 ff ff       	jmp    8010712c <alltraps>

80107a99 <vector91>:
.globl vector91
vector91:
  pushl $0
80107a99:	6a 00                	push   $0x0
  pushl $91
80107a9b:	6a 5b                	push   $0x5b
  jmp alltraps
80107a9d:	e9 8a f6 ff ff       	jmp    8010712c <alltraps>

80107aa2 <vector92>:
.globl vector92
vector92:
  pushl $0
80107aa2:	6a 00                	push   $0x0
  pushl $92
80107aa4:	6a 5c                	push   $0x5c
  jmp alltraps
80107aa6:	e9 81 f6 ff ff       	jmp    8010712c <alltraps>

80107aab <vector93>:
.globl vector93
vector93:
  pushl $0
80107aab:	6a 00                	push   $0x0
  pushl $93
80107aad:	6a 5d                	push   $0x5d
  jmp alltraps
80107aaf:	e9 78 f6 ff ff       	jmp    8010712c <alltraps>

80107ab4 <vector94>:
.globl vector94
vector94:
  pushl $0
80107ab4:	6a 00                	push   $0x0
  pushl $94
80107ab6:	6a 5e                	push   $0x5e
  jmp alltraps
80107ab8:	e9 6f f6 ff ff       	jmp    8010712c <alltraps>

80107abd <vector95>:
.globl vector95
vector95:
  pushl $0
80107abd:	6a 00                	push   $0x0
  pushl $95
80107abf:	6a 5f                	push   $0x5f
  jmp alltraps
80107ac1:	e9 66 f6 ff ff       	jmp    8010712c <alltraps>

80107ac6 <vector96>:
.globl vector96
vector96:
  pushl $0
80107ac6:	6a 00                	push   $0x0
  pushl $96
80107ac8:	6a 60                	push   $0x60
  jmp alltraps
80107aca:	e9 5d f6 ff ff       	jmp    8010712c <alltraps>

80107acf <vector97>:
.globl vector97
vector97:
  pushl $0
80107acf:	6a 00                	push   $0x0
  pushl $97
80107ad1:	6a 61                	push   $0x61
  jmp alltraps
80107ad3:	e9 54 f6 ff ff       	jmp    8010712c <alltraps>

80107ad8 <vector98>:
.globl vector98
vector98:
  pushl $0
80107ad8:	6a 00                	push   $0x0
  pushl $98
80107ada:	6a 62                	push   $0x62
  jmp alltraps
80107adc:	e9 4b f6 ff ff       	jmp    8010712c <alltraps>

80107ae1 <vector99>:
.globl vector99
vector99:
  pushl $0
80107ae1:	6a 00                	push   $0x0
  pushl $99
80107ae3:	6a 63                	push   $0x63
  jmp alltraps
80107ae5:	e9 42 f6 ff ff       	jmp    8010712c <alltraps>

80107aea <vector100>:
.globl vector100
vector100:
  pushl $0
80107aea:	6a 00                	push   $0x0
  pushl $100
80107aec:	6a 64                	push   $0x64
  jmp alltraps
80107aee:	e9 39 f6 ff ff       	jmp    8010712c <alltraps>

80107af3 <vector101>:
.globl vector101
vector101:
  pushl $0
80107af3:	6a 00                	push   $0x0
  pushl $101
80107af5:	6a 65                	push   $0x65
  jmp alltraps
80107af7:	e9 30 f6 ff ff       	jmp    8010712c <alltraps>

80107afc <vector102>:
.globl vector102
vector102:
  pushl $0
80107afc:	6a 00                	push   $0x0
  pushl $102
80107afe:	6a 66                	push   $0x66
  jmp alltraps
80107b00:	e9 27 f6 ff ff       	jmp    8010712c <alltraps>

80107b05 <vector103>:
.globl vector103
vector103:
  pushl $0
80107b05:	6a 00                	push   $0x0
  pushl $103
80107b07:	6a 67                	push   $0x67
  jmp alltraps
80107b09:	e9 1e f6 ff ff       	jmp    8010712c <alltraps>

80107b0e <vector104>:
.globl vector104
vector104:
  pushl $0
80107b0e:	6a 00                	push   $0x0
  pushl $104
80107b10:	6a 68                	push   $0x68
  jmp alltraps
80107b12:	e9 15 f6 ff ff       	jmp    8010712c <alltraps>

80107b17 <vector105>:
.globl vector105
vector105:
  pushl $0
80107b17:	6a 00                	push   $0x0
  pushl $105
80107b19:	6a 69                	push   $0x69
  jmp alltraps
80107b1b:	e9 0c f6 ff ff       	jmp    8010712c <alltraps>

80107b20 <vector106>:
.globl vector106
vector106:
  pushl $0
80107b20:	6a 00                	push   $0x0
  pushl $106
80107b22:	6a 6a                	push   $0x6a
  jmp alltraps
80107b24:	e9 03 f6 ff ff       	jmp    8010712c <alltraps>

80107b29 <vector107>:
.globl vector107
vector107:
  pushl $0
80107b29:	6a 00                	push   $0x0
  pushl $107
80107b2b:	6a 6b                	push   $0x6b
  jmp alltraps
80107b2d:	e9 fa f5 ff ff       	jmp    8010712c <alltraps>

80107b32 <vector108>:
.globl vector108
vector108:
  pushl $0
80107b32:	6a 00                	push   $0x0
  pushl $108
80107b34:	6a 6c                	push   $0x6c
  jmp alltraps
80107b36:	e9 f1 f5 ff ff       	jmp    8010712c <alltraps>

80107b3b <vector109>:
.globl vector109
vector109:
  pushl $0
80107b3b:	6a 00                	push   $0x0
  pushl $109
80107b3d:	6a 6d                	push   $0x6d
  jmp alltraps
80107b3f:	e9 e8 f5 ff ff       	jmp    8010712c <alltraps>

80107b44 <vector110>:
.globl vector110
vector110:
  pushl $0
80107b44:	6a 00                	push   $0x0
  pushl $110
80107b46:	6a 6e                	push   $0x6e
  jmp alltraps
80107b48:	e9 df f5 ff ff       	jmp    8010712c <alltraps>

80107b4d <vector111>:
.globl vector111
vector111:
  pushl $0
80107b4d:	6a 00                	push   $0x0
  pushl $111
80107b4f:	6a 6f                	push   $0x6f
  jmp alltraps
80107b51:	e9 d6 f5 ff ff       	jmp    8010712c <alltraps>

80107b56 <vector112>:
.globl vector112
vector112:
  pushl $0
80107b56:	6a 00                	push   $0x0
  pushl $112
80107b58:	6a 70                	push   $0x70
  jmp alltraps
80107b5a:	e9 cd f5 ff ff       	jmp    8010712c <alltraps>

80107b5f <vector113>:
.globl vector113
vector113:
  pushl $0
80107b5f:	6a 00                	push   $0x0
  pushl $113
80107b61:	6a 71                	push   $0x71
  jmp alltraps
80107b63:	e9 c4 f5 ff ff       	jmp    8010712c <alltraps>

80107b68 <vector114>:
.globl vector114
vector114:
  pushl $0
80107b68:	6a 00                	push   $0x0
  pushl $114
80107b6a:	6a 72                	push   $0x72
  jmp alltraps
80107b6c:	e9 bb f5 ff ff       	jmp    8010712c <alltraps>

80107b71 <vector115>:
.globl vector115
vector115:
  pushl $0
80107b71:	6a 00                	push   $0x0
  pushl $115
80107b73:	6a 73                	push   $0x73
  jmp alltraps
80107b75:	e9 b2 f5 ff ff       	jmp    8010712c <alltraps>

80107b7a <vector116>:
.globl vector116
vector116:
  pushl $0
80107b7a:	6a 00                	push   $0x0
  pushl $116
80107b7c:	6a 74                	push   $0x74
  jmp alltraps
80107b7e:	e9 a9 f5 ff ff       	jmp    8010712c <alltraps>

80107b83 <vector117>:
.globl vector117
vector117:
  pushl $0
80107b83:	6a 00                	push   $0x0
  pushl $117
80107b85:	6a 75                	push   $0x75
  jmp alltraps
80107b87:	e9 a0 f5 ff ff       	jmp    8010712c <alltraps>

80107b8c <vector118>:
.globl vector118
vector118:
  pushl $0
80107b8c:	6a 00                	push   $0x0
  pushl $118
80107b8e:	6a 76                	push   $0x76
  jmp alltraps
80107b90:	e9 97 f5 ff ff       	jmp    8010712c <alltraps>

80107b95 <vector119>:
.globl vector119
vector119:
  pushl $0
80107b95:	6a 00                	push   $0x0
  pushl $119
80107b97:	6a 77                	push   $0x77
  jmp alltraps
80107b99:	e9 8e f5 ff ff       	jmp    8010712c <alltraps>

80107b9e <vector120>:
.globl vector120
vector120:
  pushl $0
80107b9e:	6a 00                	push   $0x0
  pushl $120
80107ba0:	6a 78                	push   $0x78
  jmp alltraps
80107ba2:	e9 85 f5 ff ff       	jmp    8010712c <alltraps>

80107ba7 <vector121>:
.globl vector121
vector121:
  pushl $0
80107ba7:	6a 00                	push   $0x0
  pushl $121
80107ba9:	6a 79                	push   $0x79
  jmp alltraps
80107bab:	e9 7c f5 ff ff       	jmp    8010712c <alltraps>

80107bb0 <vector122>:
.globl vector122
vector122:
  pushl $0
80107bb0:	6a 00                	push   $0x0
  pushl $122
80107bb2:	6a 7a                	push   $0x7a
  jmp alltraps
80107bb4:	e9 73 f5 ff ff       	jmp    8010712c <alltraps>

80107bb9 <vector123>:
.globl vector123
vector123:
  pushl $0
80107bb9:	6a 00                	push   $0x0
  pushl $123
80107bbb:	6a 7b                	push   $0x7b
  jmp alltraps
80107bbd:	e9 6a f5 ff ff       	jmp    8010712c <alltraps>

80107bc2 <vector124>:
.globl vector124
vector124:
  pushl $0
80107bc2:	6a 00                	push   $0x0
  pushl $124
80107bc4:	6a 7c                	push   $0x7c
  jmp alltraps
80107bc6:	e9 61 f5 ff ff       	jmp    8010712c <alltraps>

80107bcb <vector125>:
.globl vector125
vector125:
  pushl $0
80107bcb:	6a 00                	push   $0x0
  pushl $125
80107bcd:	6a 7d                	push   $0x7d
  jmp alltraps
80107bcf:	e9 58 f5 ff ff       	jmp    8010712c <alltraps>

80107bd4 <vector126>:
.globl vector126
vector126:
  pushl $0
80107bd4:	6a 00                	push   $0x0
  pushl $126
80107bd6:	6a 7e                	push   $0x7e
  jmp alltraps
80107bd8:	e9 4f f5 ff ff       	jmp    8010712c <alltraps>

80107bdd <vector127>:
.globl vector127
vector127:
  pushl $0
80107bdd:	6a 00                	push   $0x0
  pushl $127
80107bdf:	6a 7f                	push   $0x7f
  jmp alltraps
80107be1:	e9 46 f5 ff ff       	jmp    8010712c <alltraps>

80107be6 <vector128>:
.globl vector128
vector128:
  pushl $0
80107be6:	6a 00                	push   $0x0
  pushl $128
80107be8:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107bed:	e9 3a f5 ff ff       	jmp    8010712c <alltraps>

80107bf2 <vector129>:
.globl vector129
vector129:
  pushl $0
80107bf2:	6a 00                	push   $0x0
  pushl $129
80107bf4:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107bf9:	e9 2e f5 ff ff       	jmp    8010712c <alltraps>

80107bfe <vector130>:
.globl vector130
vector130:
  pushl $0
80107bfe:	6a 00                	push   $0x0
  pushl $130
80107c00:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107c05:	e9 22 f5 ff ff       	jmp    8010712c <alltraps>

80107c0a <vector131>:
.globl vector131
vector131:
  pushl $0
80107c0a:	6a 00                	push   $0x0
  pushl $131
80107c0c:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107c11:	e9 16 f5 ff ff       	jmp    8010712c <alltraps>

80107c16 <vector132>:
.globl vector132
vector132:
  pushl $0
80107c16:	6a 00                	push   $0x0
  pushl $132
80107c18:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107c1d:	e9 0a f5 ff ff       	jmp    8010712c <alltraps>

80107c22 <vector133>:
.globl vector133
vector133:
  pushl $0
80107c22:	6a 00                	push   $0x0
  pushl $133
80107c24:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107c29:	e9 fe f4 ff ff       	jmp    8010712c <alltraps>

80107c2e <vector134>:
.globl vector134
vector134:
  pushl $0
80107c2e:	6a 00                	push   $0x0
  pushl $134
80107c30:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107c35:	e9 f2 f4 ff ff       	jmp    8010712c <alltraps>

80107c3a <vector135>:
.globl vector135
vector135:
  pushl $0
80107c3a:	6a 00                	push   $0x0
  pushl $135
80107c3c:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107c41:	e9 e6 f4 ff ff       	jmp    8010712c <alltraps>

80107c46 <vector136>:
.globl vector136
vector136:
  pushl $0
80107c46:	6a 00                	push   $0x0
  pushl $136
80107c48:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107c4d:	e9 da f4 ff ff       	jmp    8010712c <alltraps>

80107c52 <vector137>:
.globl vector137
vector137:
  pushl $0
80107c52:	6a 00                	push   $0x0
  pushl $137
80107c54:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107c59:	e9 ce f4 ff ff       	jmp    8010712c <alltraps>

80107c5e <vector138>:
.globl vector138
vector138:
  pushl $0
80107c5e:	6a 00                	push   $0x0
  pushl $138
80107c60:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107c65:	e9 c2 f4 ff ff       	jmp    8010712c <alltraps>

80107c6a <vector139>:
.globl vector139
vector139:
  pushl $0
80107c6a:	6a 00                	push   $0x0
  pushl $139
80107c6c:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107c71:	e9 b6 f4 ff ff       	jmp    8010712c <alltraps>

80107c76 <vector140>:
.globl vector140
vector140:
  pushl $0
80107c76:	6a 00                	push   $0x0
  pushl $140
80107c78:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107c7d:	e9 aa f4 ff ff       	jmp    8010712c <alltraps>

80107c82 <vector141>:
.globl vector141
vector141:
  pushl $0
80107c82:	6a 00                	push   $0x0
  pushl $141
80107c84:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107c89:	e9 9e f4 ff ff       	jmp    8010712c <alltraps>

80107c8e <vector142>:
.globl vector142
vector142:
  pushl $0
80107c8e:	6a 00                	push   $0x0
  pushl $142
80107c90:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107c95:	e9 92 f4 ff ff       	jmp    8010712c <alltraps>

80107c9a <vector143>:
.globl vector143
vector143:
  pushl $0
80107c9a:	6a 00                	push   $0x0
  pushl $143
80107c9c:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107ca1:	e9 86 f4 ff ff       	jmp    8010712c <alltraps>

80107ca6 <vector144>:
.globl vector144
vector144:
  pushl $0
80107ca6:	6a 00                	push   $0x0
  pushl $144
80107ca8:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107cad:	e9 7a f4 ff ff       	jmp    8010712c <alltraps>

80107cb2 <vector145>:
.globl vector145
vector145:
  pushl $0
80107cb2:	6a 00                	push   $0x0
  pushl $145
80107cb4:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107cb9:	e9 6e f4 ff ff       	jmp    8010712c <alltraps>

80107cbe <vector146>:
.globl vector146
vector146:
  pushl $0
80107cbe:	6a 00                	push   $0x0
  pushl $146
80107cc0:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107cc5:	e9 62 f4 ff ff       	jmp    8010712c <alltraps>

80107cca <vector147>:
.globl vector147
vector147:
  pushl $0
80107cca:	6a 00                	push   $0x0
  pushl $147
80107ccc:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107cd1:	e9 56 f4 ff ff       	jmp    8010712c <alltraps>

80107cd6 <vector148>:
.globl vector148
vector148:
  pushl $0
80107cd6:	6a 00                	push   $0x0
  pushl $148
80107cd8:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107cdd:	e9 4a f4 ff ff       	jmp    8010712c <alltraps>

80107ce2 <vector149>:
.globl vector149
vector149:
  pushl $0
80107ce2:	6a 00                	push   $0x0
  pushl $149
80107ce4:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107ce9:	e9 3e f4 ff ff       	jmp    8010712c <alltraps>

80107cee <vector150>:
.globl vector150
vector150:
  pushl $0
80107cee:	6a 00                	push   $0x0
  pushl $150
80107cf0:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107cf5:	e9 32 f4 ff ff       	jmp    8010712c <alltraps>

80107cfa <vector151>:
.globl vector151
vector151:
  pushl $0
80107cfa:	6a 00                	push   $0x0
  pushl $151
80107cfc:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107d01:	e9 26 f4 ff ff       	jmp    8010712c <alltraps>

80107d06 <vector152>:
.globl vector152
vector152:
  pushl $0
80107d06:	6a 00                	push   $0x0
  pushl $152
80107d08:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107d0d:	e9 1a f4 ff ff       	jmp    8010712c <alltraps>

80107d12 <vector153>:
.globl vector153
vector153:
  pushl $0
80107d12:	6a 00                	push   $0x0
  pushl $153
80107d14:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107d19:	e9 0e f4 ff ff       	jmp    8010712c <alltraps>

80107d1e <vector154>:
.globl vector154
vector154:
  pushl $0
80107d1e:	6a 00                	push   $0x0
  pushl $154
80107d20:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107d25:	e9 02 f4 ff ff       	jmp    8010712c <alltraps>

80107d2a <vector155>:
.globl vector155
vector155:
  pushl $0
80107d2a:	6a 00                	push   $0x0
  pushl $155
80107d2c:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107d31:	e9 f6 f3 ff ff       	jmp    8010712c <alltraps>

80107d36 <vector156>:
.globl vector156
vector156:
  pushl $0
80107d36:	6a 00                	push   $0x0
  pushl $156
80107d38:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107d3d:	e9 ea f3 ff ff       	jmp    8010712c <alltraps>

80107d42 <vector157>:
.globl vector157
vector157:
  pushl $0
80107d42:	6a 00                	push   $0x0
  pushl $157
80107d44:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107d49:	e9 de f3 ff ff       	jmp    8010712c <alltraps>

80107d4e <vector158>:
.globl vector158
vector158:
  pushl $0
80107d4e:	6a 00                	push   $0x0
  pushl $158
80107d50:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107d55:	e9 d2 f3 ff ff       	jmp    8010712c <alltraps>

80107d5a <vector159>:
.globl vector159
vector159:
  pushl $0
80107d5a:	6a 00                	push   $0x0
  pushl $159
80107d5c:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107d61:	e9 c6 f3 ff ff       	jmp    8010712c <alltraps>

80107d66 <vector160>:
.globl vector160
vector160:
  pushl $0
80107d66:	6a 00                	push   $0x0
  pushl $160
80107d68:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107d6d:	e9 ba f3 ff ff       	jmp    8010712c <alltraps>

80107d72 <vector161>:
.globl vector161
vector161:
  pushl $0
80107d72:	6a 00                	push   $0x0
  pushl $161
80107d74:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107d79:	e9 ae f3 ff ff       	jmp    8010712c <alltraps>

80107d7e <vector162>:
.globl vector162
vector162:
  pushl $0
80107d7e:	6a 00                	push   $0x0
  pushl $162
80107d80:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107d85:	e9 a2 f3 ff ff       	jmp    8010712c <alltraps>

80107d8a <vector163>:
.globl vector163
vector163:
  pushl $0
80107d8a:	6a 00                	push   $0x0
  pushl $163
80107d8c:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107d91:	e9 96 f3 ff ff       	jmp    8010712c <alltraps>

80107d96 <vector164>:
.globl vector164
vector164:
  pushl $0
80107d96:	6a 00                	push   $0x0
  pushl $164
80107d98:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107d9d:	e9 8a f3 ff ff       	jmp    8010712c <alltraps>

80107da2 <vector165>:
.globl vector165
vector165:
  pushl $0
80107da2:	6a 00                	push   $0x0
  pushl $165
80107da4:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107da9:	e9 7e f3 ff ff       	jmp    8010712c <alltraps>

80107dae <vector166>:
.globl vector166
vector166:
  pushl $0
80107dae:	6a 00                	push   $0x0
  pushl $166
80107db0:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107db5:	e9 72 f3 ff ff       	jmp    8010712c <alltraps>

80107dba <vector167>:
.globl vector167
vector167:
  pushl $0
80107dba:	6a 00                	push   $0x0
  pushl $167
80107dbc:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107dc1:	e9 66 f3 ff ff       	jmp    8010712c <alltraps>

80107dc6 <vector168>:
.globl vector168
vector168:
  pushl $0
80107dc6:	6a 00                	push   $0x0
  pushl $168
80107dc8:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107dcd:	e9 5a f3 ff ff       	jmp    8010712c <alltraps>

80107dd2 <vector169>:
.globl vector169
vector169:
  pushl $0
80107dd2:	6a 00                	push   $0x0
  pushl $169
80107dd4:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107dd9:	e9 4e f3 ff ff       	jmp    8010712c <alltraps>

80107dde <vector170>:
.globl vector170
vector170:
  pushl $0
80107dde:	6a 00                	push   $0x0
  pushl $170
80107de0:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107de5:	e9 42 f3 ff ff       	jmp    8010712c <alltraps>

80107dea <vector171>:
.globl vector171
vector171:
  pushl $0
80107dea:	6a 00                	push   $0x0
  pushl $171
80107dec:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107df1:	e9 36 f3 ff ff       	jmp    8010712c <alltraps>

80107df6 <vector172>:
.globl vector172
vector172:
  pushl $0
80107df6:	6a 00                	push   $0x0
  pushl $172
80107df8:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107dfd:	e9 2a f3 ff ff       	jmp    8010712c <alltraps>

80107e02 <vector173>:
.globl vector173
vector173:
  pushl $0
80107e02:	6a 00                	push   $0x0
  pushl $173
80107e04:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107e09:	e9 1e f3 ff ff       	jmp    8010712c <alltraps>

80107e0e <vector174>:
.globl vector174
vector174:
  pushl $0
80107e0e:	6a 00                	push   $0x0
  pushl $174
80107e10:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107e15:	e9 12 f3 ff ff       	jmp    8010712c <alltraps>

80107e1a <vector175>:
.globl vector175
vector175:
  pushl $0
80107e1a:	6a 00                	push   $0x0
  pushl $175
80107e1c:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107e21:	e9 06 f3 ff ff       	jmp    8010712c <alltraps>

80107e26 <vector176>:
.globl vector176
vector176:
  pushl $0
80107e26:	6a 00                	push   $0x0
  pushl $176
80107e28:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107e2d:	e9 fa f2 ff ff       	jmp    8010712c <alltraps>

80107e32 <vector177>:
.globl vector177
vector177:
  pushl $0
80107e32:	6a 00                	push   $0x0
  pushl $177
80107e34:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107e39:	e9 ee f2 ff ff       	jmp    8010712c <alltraps>

80107e3e <vector178>:
.globl vector178
vector178:
  pushl $0
80107e3e:	6a 00                	push   $0x0
  pushl $178
80107e40:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107e45:	e9 e2 f2 ff ff       	jmp    8010712c <alltraps>

80107e4a <vector179>:
.globl vector179
vector179:
  pushl $0
80107e4a:	6a 00                	push   $0x0
  pushl $179
80107e4c:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107e51:	e9 d6 f2 ff ff       	jmp    8010712c <alltraps>

80107e56 <vector180>:
.globl vector180
vector180:
  pushl $0
80107e56:	6a 00                	push   $0x0
  pushl $180
80107e58:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107e5d:	e9 ca f2 ff ff       	jmp    8010712c <alltraps>

80107e62 <vector181>:
.globl vector181
vector181:
  pushl $0
80107e62:	6a 00                	push   $0x0
  pushl $181
80107e64:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107e69:	e9 be f2 ff ff       	jmp    8010712c <alltraps>

80107e6e <vector182>:
.globl vector182
vector182:
  pushl $0
80107e6e:	6a 00                	push   $0x0
  pushl $182
80107e70:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107e75:	e9 b2 f2 ff ff       	jmp    8010712c <alltraps>

80107e7a <vector183>:
.globl vector183
vector183:
  pushl $0
80107e7a:	6a 00                	push   $0x0
  pushl $183
80107e7c:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107e81:	e9 a6 f2 ff ff       	jmp    8010712c <alltraps>

80107e86 <vector184>:
.globl vector184
vector184:
  pushl $0
80107e86:	6a 00                	push   $0x0
  pushl $184
80107e88:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107e8d:	e9 9a f2 ff ff       	jmp    8010712c <alltraps>

80107e92 <vector185>:
.globl vector185
vector185:
  pushl $0
80107e92:	6a 00                	push   $0x0
  pushl $185
80107e94:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107e99:	e9 8e f2 ff ff       	jmp    8010712c <alltraps>

80107e9e <vector186>:
.globl vector186
vector186:
  pushl $0
80107e9e:	6a 00                	push   $0x0
  pushl $186
80107ea0:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107ea5:	e9 82 f2 ff ff       	jmp    8010712c <alltraps>

80107eaa <vector187>:
.globl vector187
vector187:
  pushl $0
80107eaa:	6a 00                	push   $0x0
  pushl $187
80107eac:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107eb1:	e9 76 f2 ff ff       	jmp    8010712c <alltraps>

80107eb6 <vector188>:
.globl vector188
vector188:
  pushl $0
80107eb6:	6a 00                	push   $0x0
  pushl $188
80107eb8:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107ebd:	e9 6a f2 ff ff       	jmp    8010712c <alltraps>

80107ec2 <vector189>:
.globl vector189
vector189:
  pushl $0
80107ec2:	6a 00                	push   $0x0
  pushl $189
80107ec4:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107ec9:	e9 5e f2 ff ff       	jmp    8010712c <alltraps>

80107ece <vector190>:
.globl vector190
vector190:
  pushl $0
80107ece:	6a 00                	push   $0x0
  pushl $190
80107ed0:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107ed5:	e9 52 f2 ff ff       	jmp    8010712c <alltraps>

80107eda <vector191>:
.globl vector191
vector191:
  pushl $0
80107eda:	6a 00                	push   $0x0
  pushl $191
80107edc:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107ee1:	e9 46 f2 ff ff       	jmp    8010712c <alltraps>

80107ee6 <vector192>:
.globl vector192
vector192:
  pushl $0
80107ee6:	6a 00                	push   $0x0
  pushl $192
80107ee8:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107eed:	e9 3a f2 ff ff       	jmp    8010712c <alltraps>

80107ef2 <vector193>:
.globl vector193
vector193:
  pushl $0
80107ef2:	6a 00                	push   $0x0
  pushl $193
80107ef4:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107ef9:	e9 2e f2 ff ff       	jmp    8010712c <alltraps>

80107efe <vector194>:
.globl vector194
vector194:
  pushl $0
80107efe:	6a 00                	push   $0x0
  pushl $194
80107f00:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107f05:	e9 22 f2 ff ff       	jmp    8010712c <alltraps>

80107f0a <vector195>:
.globl vector195
vector195:
  pushl $0
80107f0a:	6a 00                	push   $0x0
  pushl $195
80107f0c:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107f11:	e9 16 f2 ff ff       	jmp    8010712c <alltraps>

80107f16 <vector196>:
.globl vector196
vector196:
  pushl $0
80107f16:	6a 00                	push   $0x0
  pushl $196
80107f18:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107f1d:	e9 0a f2 ff ff       	jmp    8010712c <alltraps>

80107f22 <vector197>:
.globl vector197
vector197:
  pushl $0
80107f22:	6a 00                	push   $0x0
  pushl $197
80107f24:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107f29:	e9 fe f1 ff ff       	jmp    8010712c <alltraps>

80107f2e <vector198>:
.globl vector198
vector198:
  pushl $0
80107f2e:	6a 00                	push   $0x0
  pushl $198
80107f30:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107f35:	e9 f2 f1 ff ff       	jmp    8010712c <alltraps>

80107f3a <vector199>:
.globl vector199
vector199:
  pushl $0
80107f3a:	6a 00                	push   $0x0
  pushl $199
80107f3c:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107f41:	e9 e6 f1 ff ff       	jmp    8010712c <alltraps>

80107f46 <vector200>:
.globl vector200
vector200:
  pushl $0
80107f46:	6a 00                	push   $0x0
  pushl $200
80107f48:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107f4d:	e9 da f1 ff ff       	jmp    8010712c <alltraps>

80107f52 <vector201>:
.globl vector201
vector201:
  pushl $0
80107f52:	6a 00                	push   $0x0
  pushl $201
80107f54:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107f59:	e9 ce f1 ff ff       	jmp    8010712c <alltraps>

80107f5e <vector202>:
.globl vector202
vector202:
  pushl $0
80107f5e:	6a 00                	push   $0x0
  pushl $202
80107f60:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107f65:	e9 c2 f1 ff ff       	jmp    8010712c <alltraps>

80107f6a <vector203>:
.globl vector203
vector203:
  pushl $0
80107f6a:	6a 00                	push   $0x0
  pushl $203
80107f6c:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107f71:	e9 b6 f1 ff ff       	jmp    8010712c <alltraps>

80107f76 <vector204>:
.globl vector204
vector204:
  pushl $0
80107f76:	6a 00                	push   $0x0
  pushl $204
80107f78:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107f7d:	e9 aa f1 ff ff       	jmp    8010712c <alltraps>

80107f82 <vector205>:
.globl vector205
vector205:
  pushl $0
80107f82:	6a 00                	push   $0x0
  pushl $205
80107f84:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107f89:	e9 9e f1 ff ff       	jmp    8010712c <alltraps>

80107f8e <vector206>:
.globl vector206
vector206:
  pushl $0
80107f8e:	6a 00                	push   $0x0
  pushl $206
80107f90:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107f95:	e9 92 f1 ff ff       	jmp    8010712c <alltraps>

80107f9a <vector207>:
.globl vector207
vector207:
  pushl $0
80107f9a:	6a 00                	push   $0x0
  pushl $207
80107f9c:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107fa1:	e9 86 f1 ff ff       	jmp    8010712c <alltraps>

80107fa6 <vector208>:
.globl vector208
vector208:
  pushl $0
80107fa6:	6a 00                	push   $0x0
  pushl $208
80107fa8:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107fad:	e9 7a f1 ff ff       	jmp    8010712c <alltraps>

80107fb2 <vector209>:
.globl vector209
vector209:
  pushl $0
80107fb2:	6a 00                	push   $0x0
  pushl $209
80107fb4:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107fb9:	e9 6e f1 ff ff       	jmp    8010712c <alltraps>

80107fbe <vector210>:
.globl vector210
vector210:
  pushl $0
80107fbe:	6a 00                	push   $0x0
  pushl $210
80107fc0:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107fc5:	e9 62 f1 ff ff       	jmp    8010712c <alltraps>

80107fca <vector211>:
.globl vector211
vector211:
  pushl $0
80107fca:	6a 00                	push   $0x0
  pushl $211
80107fcc:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107fd1:	e9 56 f1 ff ff       	jmp    8010712c <alltraps>

80107fd6 <vector212>:
.globl vector212
vector212:
  pushl $0
80107fd6:	6a 00                	push   $0x0
  pushl $212
80107fd8:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107fdd:	e9 4a f1 ff ff       	jmp    8010712c <alltraps>

80107fe2 <vector213>:
.globl vector213
vector213:
  pushl $0
80107fe2:	6a 00                	push   $0x0
  pushl $213
80107fe4:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107fe9:	e9 3e f1 ff ff       	jmp    8010712c <alltraps>

80107fee <vector214>:
.globl vector214
vector214:
  pushl $0
80107fee:	6a 00                	push   $0x0
  pushl $214
80107ff0:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107ff5:	e9 32 f1 ff ff       	jmp    8010712c <alltraps>

80107ffa <vector215>:
.globl vector215
vector215:
  pushl $0
80107ffa:	6a 00                	push   $0x0
  pushl $215
80107ffc:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80108001:	e9 26 f1 ff ff       	jmp    8010712c <alltraps>

80108006 <vector216>:
.globl vector216
vector216:
  pushl $0
80108006:	6a 00                	push   $0x0
  pushl $216
80108008:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010800d:	e9 1a f1 ff ff       	jmp    8010712c <alltraps>

80108012 <vector217>:
.globl vector217
vector217:
  pushl $0
80108012:	6a 00                	push   $0x0
  pushl $217
80108014:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80108019:	e9 0e f1 ff ff       	jmp    8010712c <alltraps>

8010801e <vector218>:
.globl vector218
vector218:
  pushl $0
8010801e:	6a 00                	push   $0x0
  pushl $218
80108020:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80108025:	e9 02 f1 ff ff       	jmp    8010712c <alltraps>

8010802a <vector219>:
.globl vector219
vector219:
  pushl $0
8010802a:	6a 00                	push   $0x0
  pushl $219
8010802c:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80108031:	e9 f6 f0 ff ff       	jmp    8010712c <alltraps>

80108036 <vector220>:
.globl vector220
vector220:
  pushl $0
80108036:	6a 00                	push   $0x0
  pushl $220
80108038:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010803d:	e9 ea f0 ff ff       	jmp    8010712c <alltraps>

80108042 <vector221>:
.globl vector221
vector221:
  pushl $0
80108042:	6a 00                	push   $0x0
  pushl $221
80108044:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80108049:	e9 de f0 ff ff       	jmp    8010712c <alltraps>

8010804e <vector222>:
.globl vector222
vector222:
  pushl $0
8010804e:	6a 00                	push   $0x0
  pushl $222
80108050:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80108055:	e9 d2 f0 ff ff       	jmp    8010712c <alltraps>

8010805a <vector223>:
.globl vector223
vector223:
  pushl $0
8010805a:	6a 00                	push   $0x0
  pushl $223
8010805c:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108061:	e9 c6 f0 ff ff       	jmp    8010712c <alltraps>

80108066 <vector224>:
.globl vector224
vector224:
  pushl $0
80108066:	6a 00                	push   $0x0
  pushl $224
80108068:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
8010806d:	e9 ba f0 ff ff       	jmp    8010712c <alltraps>

80108072 <vector225>:
.globl vector225
vector225:
  pushl $0
80108072:	6a 00                	push   $0x0
  pushl $225
80108074:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80108079:	e9 ae f0 ff ff       	jmp    8010712c <alltraps>

8010807e <vector226>:
.globl vector226
vector226:
  pushl $0
8010807e:	6a 00                	push   $0x0
  pushl $226
80108080:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108085:	e9 a2 f0 ff ff       	jmp    8010712c <alltraps>

8010808a <vector227>:
.globl vector227
vector227:
  pushl $0
8010808a:	6a 00                	push   $0x0
  pushl $227
8010808c:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108091:	e9 96 f0 ff ff       	jmp    8010712c <alltraps>

80108096 <vector228>:
.globl vector228
vector228:
  pushl $0
80108096:	6a 00                	push   $0x0
  pushl $228
80108098:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
8010809d:	e9 8a f0 ff ff       	jmp    8010712c <alltraps>

801080a2 <vector229>:
.globl vector229
vector229:
  pushl $0
801080a2:	6a 00                	push   $0x0
  pushl $229
801080a4:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801080a9:	e9 7e f0 ff ff       	jmp    8010712c <alltraps>

801080ae <vector230>:
.globl vector230
vector230:
  pushl $0
801080ae:	6a 00                	push   $0x0
  pushl $230
801080b0:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
801080b5:	e9 72 f0 ff ff       	jmp    8010712c <alltraps>

801080ba <vector231>:
.globl vector231
vector231:
  pushl $0
801080ba:	6a 00                	push   $0x0
  pushl $231
801080bc:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
801080c1:	e9 66 f0 ff ff       	jmp    8010712c <alltraps>

801080c6 <vector232>:
.globl vector232
vector232:
  pushl $0
801080c6:	6a 00                	push   $0x0
  pushl $232
801080c8:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
801080cd:	e9 5a f0 ff ff       	jmp    8010712c <alltraps>

801080d2 <vector233>:
.globl vector233
vector233:
  pushl $0
801080d2:	6a 00                	push   $0x0
  pushl $233
801080d4:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
801080d9:	e9 4e f0 ff ff       	jmp    8010712c <alltraps>

801080de <vector234>:
.globl vector234
vector234:
  pushl $0
801080de:	6a 00                	push   $0x0
  pushl $234
801080e0:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801080e5:	e9 42 f0 ff ff       	jmp    8010712c <alltraps>

801080ea <vector235>:
.globl vector235
vector235:
  pushl $0
801080ea:	6a 00                	push   $0x0
  pushl $235
801080ec:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801080f1:	e9 36 f0 ff ff       	jmp    8010712c <alltraps>

801080f6 <vector236>:
.globl vector236
vector236:
  pushl $0
801080f6:	6a 00                	push   $0x0
  pushl $236
801080f8:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801080fd:	e9 2a f0 ff ff       	jmp    8010712c <alltraps>

80108102 <vector237>:
.globl vector237
vector237:
  pushl $0
80108102:	6a 00                	push   $0x0
  pushl $237
80108104:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80108109:	e9 1e f0 ff ff       	jmp    8010712c <alltraps>

8010810e <vector238>:
.globl vector238
vector238:
  pushl $0
8010810e:	6a 00                	push   $0x0
  pushl $238
80108110:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80108115:	e9 12 f0 ff ff       	jmp    8010712c <alltraps>

8010811a <vector239>:
.globl vector239
vector239:
  pushl $0
8010811a:	6a 00                	push   $0x0
  pushl $239
8010811c:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80108121:	e9 06 f0 ff ff       	jmp    8010712c <alltraps>

80108126 <vector240>:
.globl vector240
vector240:
  pushl $0
80108126:	6a 00                	push   $0x0
  pushl $240
80108128:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010812d:	e9 fa ef ff ff       	jmp    8010712c <alltraps>

80108132 <vector241>:
.globl vector241
vector241:
  pushl $0
80108132:	6a 00                	push   $0x0
  pushl $241
80108134:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80108139:	e9 ee ef ff ff       	jmp    8010712c <alltraps>

8010813e <vector242>:
.globl vector242
vector242:
  pushl $0
8010813e:	6a 00                	push   $0x0
  pushl $242
80108140:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80108145:	e9 e2 ef ff ff       	jmp    8010712c <alltraps>

8010814a <vector243>:
.globl vector243
vector243:
  pushl $0
8010814a:	6a 00                	push   $0x0
  pushl $243
8010814c:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108151:	e9 d6 ef ff ff       	jmp    8010712c <alltraps>

80108156 <vector244>:
.globl vector244
vector244:
  pushl $0
80108156:	6a 00                	push   $0x0
  pushl $244
80108158:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010815d:	e9 ca ef ff ff       	jmp    8010712c <alltraps>

80108162 <vector245>:
.globl vector245
vector245:
  pushl $0
80108162:	6a 00                	push   $0x0
  pushl $245
80108164:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80108169:	e9 be ef ff ff       	jmp    8010712c <alltraps>

8010816e <vector246>:
.globl vector246
vector246:
  pushl $0
8010816e:	6a 00                	push   $0x0
  pushl $246
80108170:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80108175:	e9 b2 ef ff ff       	jmp    8010712c <alltraps>

8010817a <vector247>:
.globl vector247
vector247:
  pushl $0
8010817a:	6a 00                	push   $0x0
  pushl $247
8010817c:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108181:	e9 a6 ef ff ff       	jmp    8010712c <alltraps>

80108186 <vector248>:
.globl vector248
vector248:
  pushl $0
80108186:	6a 00                	push   $0x0
  pushl $248
80108188:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
8010818d:	e9 9a ef ff ff       	jmp    8010712c <alltraps>

80108192 <vector249>:
.globl vector249
vector249:
  pushl $0
80108192:	6a 00                	push   $0x0
  pushl $249
80108194:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80108199:	e9 8e ef ff ff       	jmp    8010712c <alltraps>

8010819e <vector250>:
.globl vector250
vector250:
  pushl $0
8010819e:	6a 00                	push   $0x0
  pushl $250
801081a0:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801081a5:	e9 82 ef ff ff       	jmp    8010712c <alltraps>

801081aa <vector251>:
.globl vector251
vector251:
  pushl $0
801081aa:	6a 00                	push   $0x0
  pushl $251
801081ac:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801081b1:	e9 76 ef ff ff       	jmp    8010712c <alltraps>

801081b6 <vector252>:
.globl vector252
vector252:
  pushl $0
801081b6:	6a 00                	push   $0x0
  pushl $252
801081b8:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801081bd:	e9 6a ef ff ff       	jmp    8010712c <alltraps>

801081c2 <vector253>:
.globl vector253
vector253:
  pushl $0
801081c2:	6a 00                	push   $0x0
  pushl $253
801081c4:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801081c9:	e9 5e ef ff ff       	jmp    8010712c <alltraps>

801081ce <vector254>:
.globl vector254
vector254:
  pushl $0
801081ce:	6a 00                	push   $0x0
  pushl $254
801081d0:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
801081d5:	e9 52 ef ff ff       	jmp    8010712c <alltraps>

801081da <vector255>:
.globl vector255
vector255:
  pushl $0
801081da:	6a 00                	push   $0x0
  pushl $255
801081dc:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801081e1:	e9 46 ef ff ff       	jmp    8010712c <alltraps>
	...

801081e8 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801081e8:	55                   	push   %ebp
801081e9:	89 e5                	mov    %esp,%ebp
801081eb:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801081ee:	8b 45 0c             	mov    0xc(%ebp),%eax
801081f1:	48                   	dec    %eax
801081f2:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801081f6:	8b 45 08             	mov    0x8(%ebp),%eax
801081f9:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801081fd:	8b 45 08             	mov    0x8(%ebp),%eax
80108200:	c1 e8 10             	shr    $0x10,%eax
80108203:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108207:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010820a:	0f 01 10             	lgdtl  (%eax)
}
8010820d:	c9                   	leave  
8010820e:	c3                   	ret    

8010820f <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010820f:	55                   	push   %ebp
80108210:	89 e5                	mov    %esp,%ebp
80108212:	83 ec 04             	sub    $0x4,%esp
80108215:	8b 45 08             	mov    0x8(%ebp),%eax
80108218:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010821c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010821f:	0f 00 d8             	ltr    %ax
}
80108222:	c9                   	leave  
80108223:	c3                   	ret    

80108224 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80108224:	55                   	push   %ebp
80108225:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80108227:	8b 45 08             	mov    0x8(%ebp),%eax
8010822a:	0f 22 d8             	mov    %eax,%cr3
}
8010822d:	5d                   	pop    %ebp
8010822e:	c3                   	ret    

8010822f <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
8010822f:	55                   	push   %ebp
80108230:	89 e5                	mov    %esp,%ebp
80108232:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80108235:	e8 a4 ca ff ff       	call   80104cde <cpuid>
8010823a:	89 c2                	mov    %eax,%edx
8010823c:	89 d0                	mov    %edx,%eax
8010823e:	c1 e0 02             	shl    $0x2,%eax
80108241:	01 d0                	add    %edx,%eax
80108243:	01 c0                	add    %eax,%eax
80108245:	01 d0                	add    %edx,%eax
80108247:	c1 e0 04             	shl    $0x4,%eax
8010824a:	05 60 49 11 80       	add    $0x80114960,%eax
8010824f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80108252:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108255:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010825b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010825e:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108264:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108267:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010826b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010826e:	8a 50 7d             	mov    0x7d(%eax),%dl
80108271:	83 e2 f0             	and    $0xfffffff0,%edx
80108274:	83 ca 0a             	or     $0xa,%edx
80108277:	88 50 7d             	mov    %dl,0x7d(%eax)
8010827a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010827d:	8a 50 7d             	mov    0x7d(%eax),%dl
80108280:	83 ca 10             	or     $0x10,%edx
80108283:	88 50 7d             	mov    %dl,0x7d(%eax)
80108286:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108289:	8a 50 7d             	mov    0x7d(%eax),%dl
8010828c:	83 e2 9f             	and    $0xffffff9f,%edx
8010828f:	88 50 7d             	mov    %dl,0x7d(%eax)
80108292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108295:	8a 50 7d             	mov    0x7d(%eax),%dl
80108298:	83 ca 80             	or     $0xffffff80,%edx
8010829b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010829e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082a1:	8a 50 7e             	mov    0x7e(%eax),%dl
801082a4:	83 ca 0f             	or     $0xf,%edx
801082a7:	88 50 7e             	mov    %dl,0x7e(%eax)
801082aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ad:	8a 50 7e             	mov    0x7e(%eax),%dl
801082b0:	83 e2 ef             	and    $0xffffffef,%edx
801082b3:	88 50 7e             	mov    %dl,0x7e(%eax)
801082b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b9:	8a 50 7e             	mov    0x7e(%eax),%dl
801082bc:	83 e2 df             	and    $0xffffffdf,%edx
801082bf:	88 50 7e             	mov    %dl,0x7e(%eax)
801082c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082c5:	8a 50 7e             	mov    0x7e(%eax),%dl
801082c8:	83 ca 40             	or     $0x40,%edx
801082cb:	88 50 7e             	mov    %dl,0x7e(%eax)
801082ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082d1:	8a 50 7e             	mov    0x7e(%eax),%dl
801082d4:	83 ca 80             	or     $0xffffff80,%edx
801082d7:	88 50 7e             	mov    %dl,0x7e(%eax)
801082da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082dd:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801082e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e4:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801082eb:	ff ff 
801082ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f0:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801082f7:	00 00 
801082f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082fc:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108306:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010830c:	83 e2 f0             	and    $0xfffffff0,%edx
8010830f:	83 ca 02             	or     $0x2,%edx
80108312:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108318:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010831b:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108321:	83 ca 10             	or     $0x10,%edx
80108324:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010832a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010832d:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108333:	83 e2 9f             	and    $0xffffff9f,%edx
80108336:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010833c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010833f:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108345:	83 ca 80             	or     $0xffffff80,%edx
80108348:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010834e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108351:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108357:	83 ca 0f             	or     $0xf,%edx
8010835a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108363:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108369:	83 e2 ef             	and    $0xffffffef,%edx
8010836c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108372:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108375:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010837b:	83 e2 df             	and    $0xffffffdf,%edx
8010837e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108384:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108387:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010838d:	83 ca 40             	or     $0x40,%edx
80108390:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108396:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108399:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010839f:	83 ca 80             	or     $0xffffff80,%edx
801083a2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801083a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ab:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801083b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b5:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801083bc:	ff ff 
801083be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c1:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801083c8:	00 00 
801083ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083cd:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801083d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083d7:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801083dd:	83 e2 f0             	and    $0xfffffff0,%edx
801083e0:	83 ca 0a             	or     $0xa,%edx
801083e3:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801083e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ec:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801083f2:	83 ca 10             	or     $0x10,%edx
801083f5:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801083fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083fe:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108404:	83 ca 60             	or     $0x60,%edx
80108407:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010840d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108410:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108416:	83 ca 80             	or     $0xffffff80,%edx
80108419:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010841f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108422:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108428:	83 ca 0f             	or     $0xf,%edx
8010842b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108431:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108434:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010843a:	83 e2 ef             	and    $0xffffffef,%edx
8010843d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108443:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108446:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010844c:	83 e2 df             	and    $0xffffffdf,%edx
8010844f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108455:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108458:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010845e:	83 ca 40             	or     $0x40,%edx
80108461:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108467:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010846a:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108470:	83 ca 80             	or     $0xffffff80,%edx
80108473:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010847c:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108483:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108486:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
8010848d:	ff ff 
8010848f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108492:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108499:	00 00 
8010849b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010849e:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801084a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a8:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801084ae:	83 e2 f0             	and    $0xfffffff0,%edx
801084b1:	83 ca 02             	or     $0x2,%edx
801084b4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801084ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084bd:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801084c3:	83 ca 10             	or     $0x10,%edx
801084c6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801084cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084cf:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801084d5:	83 ca 60             	or     $0x60,%edx
801084d8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801084de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e1:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801084e7:	83 ca 80             	or     $0xffffff80,%edx
801084ea:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801084f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f3:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801084f9:	83 ca 0f             	or     $0xf,%edx
801084fc:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108502:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108505:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010850b:	83 e2 ef             	and    $0xffffffef,%edx
8010850e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108514:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108517:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010851d:	83 e2 df             	and    $0xffffffdf,%edx
80108520:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108526:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108529:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010852f:	83 ca 40             	or     $0x40,%edx
80108532:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108538:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010853b:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108541:	83 ca 80             	or     $0xffffff80,%edx
80108544:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010854a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854d:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80108554:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108557:	83 c0 70             	add    $0x70,%eax
8010855a:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80108561:	00 
80108562:	89 04 24             	mov    %eax,(%esp)
80108565:	e8 7e fc ff ff       	call   801081e8 <lgdt>
}
8010856a:	c9                   	leave  
8010856b:	c3                   	ret    

8010856c <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010856c:	55                   	push   %ebp
8010856d:	89 e5                	mov    %esp,%ebp
8010856f:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108572:	8b 45 0c             	mov    0xc(%ebp),%eax
80108575:	c1 e8 16             	shr    $0x16,%eax
80108578:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010857f:	8b 45 08             	mov    0x8(%ebp),%eax
80108582:	01 d0                	add    %edx,%eax
80108584:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108587:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010858a:	8b 00                	mov    (%eax),%eax
8010858c:	83 e0 01             	and    $0x1,%eax
8010858f:	85 c0                	test   %eax,%eax
80108591:	74 14                	je     801085a7 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80108593:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108596:	8b 00                	mov    (%eax),%eax
80108598:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010859d:	05 00 00 00 80       	add    $0x80000000,%eax
801085a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801085a5:	eb 48                	jmp    801085ef <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801085a7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801085ab:	74 0e                	je     801085bb <walkpgdir+0x4f>
801085ad:	e8 21 a8 ff ff       	call   80102dd3 <kalloc>
801085b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801085b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801085b9:	75 07                	jne    801085c2 <walkpgdir+0x56>
      return 0;
801085bb:	b8 00 00 00 00       	mov    $0x0,%eax
801085c0:	eb 44                	jmp    80108606 <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801085c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801085c9:	00 
801085ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801085d1:	00 
801085d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d5:	89 04 24             	mov    %eax,(%esp)
801085d8:	e8 c5 d3 ff ff       	call   801059a2 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801085dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e0:	05 00 00 00 80       	add    $0x80000000,%eax
801085e5:	83 c8 07             	or     $0x7,%eax
801085e8:	89 c2                	mov    %eax,%edx
801085ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801085ed:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801085ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801085f2:	c1 e8 0c             	shr    $0xc,%eax
801085f5:	25 ff 03 00 00       	and    $0x3ff,%eax
801085fa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108604:	01 d0                	add    %edx,%eax
}
80108606:	c9                   	leave  
80108607:	c3                   	ret    

80108608 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108608:	55                   	push   %ebp
80108609:	89 e5                	mov    %esp,%ebp
8010860b:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010860e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108611:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108616:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108619:	8b 55 0c             	mov    0xc(%ebp),%edx
8010861c:	8b 45 10             	mov    0x10(%ebp),%eax
8010861f:	01 d0                	add    %edx,%eax
80108621:	48                   	dec    %eax
80108622:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108627:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010862a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108631:	00 
80108632:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108635:	89 44 24 04          	mov    %eax,0x4(%esp)
80108639:	8b 45 08             	mov    0x8(%ebp),%eax
8010863c:	89 04 24             	mov    %eax,(%esp)
8010863f:	e8 28 ff ff ff       	call   8010856c <walkpgdir>
80108644:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108647:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010864b:	75 07                	jne    80108654 <mappages+0x4c>
      return -1;
8010864d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108652:	eb 48                	jmp    8010869c <mappages+0x94>
    if(*pte & PTE_P)
80108654:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108657:	8b 00                	mov    (%eax),%eax
80108659:	83 e0 01             	and    $0x1,%eax
8010865c:	85 c0                	test   %eax,%eax
8010865e:	74 0c                	je     8010866c <mappages+0x64>
      panic("remap");
80108660:	c7 04 24 a0 98 10 80 	movl   $0x801098a0,(%esp)
80108667:	e8 e8 7e ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
8010866c:	8b 45 18             	mov    0x18(%ebp),%eax
8010866f:	0b 45 14             	or     0x14(%ebp),%eax
80108672:	83 c8 01             	or     $0x1,%eax
80108675:	89 c2                	mov    %eax,%edx
80108677:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010867a:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010867c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010867f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108682:	75 08                	jne    8010868c <mappages+0x84>
      break;
80108684:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108685:	b8 00 00 00 00       	mov    $0x0,%eax
8010868a:	eb 10                	jmp    8010869c <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
8010868c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108693:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
8010869a:	eb 8e                	jmp    8010862a <mappages+0x22>
  return 0;
}
8010869c:	c9                   	leave  
8010869d:	c3                   	ret    

8010869e <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
8010869e:	55                   	push   %ebp
8010869f:	89 e5                	mov    %esp,%ebp
801086a1:	53                   	push   %ebx
801086a2:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801086a5:	e8 29 a7 ff ff       	call   80102dd3 <kalloc>
801086aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
801086ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801086b1:	75 0a                	jne    801086bd <setupkvm+0x1f>
    return 0;
801086b3:	b8 00 00 00 00       	mov    $0x0,%eax
801086b8:	e9 84 00 00 00       	jmp    80108741 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
801086bd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801086c4:	00 
801086c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801086cc:	00 
801086cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801086d0:	89 04 24             	mov    %eax,(%esp)
801086d3:	e8 ca d2 ff ff       	call   801059a2 <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801086d8:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
801086df:	eb 54                	jmp    80108735 <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801086e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086e4:	8b 48 0c             	mov    0xc(%eax),%ecx
801086e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ea:	8b 50 04             	mov    0x4(%eax),%edx
801086ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f0:	8b 58 08             	mov    0x8(%eax),%ebx
801086f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086f6:	8b 40 04             	mov    0x4(%eax),%eax
801086f9:	29 c3                	sub    %eax,%ebx
801086fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086fe:	8b 00                	mov    (%eax),%eax
80108700:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108704:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108708:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010870c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108710:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108713:	89 04 24             	mov    %eax,(%esp)
80108716:	e8 ed fe ff ff       	call   80108608 <mappages>
8010871b:	85 c0                	test   %eax,%eax
8010871d:	79 12                	jns    80108731 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
8010871f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108722:	89 04 24             	mov    %eax,(%esp)
80108725:	e8 1a 05 00 00       	call   80108c44 <freevm>
      return 0;
8010872a:	b8 00 00 00 00       	mov    $0x0,%eax
8010872f:	eb 10                	jmp    80108741 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108731:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108735:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
8010873c:	72 a3                	jb     801086e1 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
8010873e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108741:	83 c4 34             	add    $0x34,%esp
80108744:	5b                   	pop    %ebx
80108745:	5d                   	pop    %ebp
80108746:	c3                   	ret    

80108747 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108747:	55                   	push   %ebp
80108748:	89 e5                	mov    %esp,%ebp
8010874a:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010874d:	e8 4c ff ff ff       	call   8010869e <setupkvm>
80108752:	a3 44 61 12 80       	mov    %eax,0x80126144
  switchkvm();
80108757:	e8 02 00 00 00       	call   8010875e <switchkvm>
}
8010875c:	c9                   	leave  
8010875d:	c3                   	ret    

8010875e <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010875e:	55                   	push   %ebp
8010875f:	89 e5                	mov    %esp,%ebp
80108761:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108764:	a1 44 61 12 80       	mov    0x80126144,%eax
80108769:	05 00 00 00 80       	add    $0x80000000,%eax
8010876e:	89 04 24             	mov    %eax,(%esp)
80108771:	e8 ae fa ff ff       	call   80108224 <lcr3>
}
80108776:	c9                   	leave  
80108777:	c3                   	ret    

80108778 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108778:	55                   	push   %ebp
80108779:	89 e5                	mov    %esp,%ebp
8010877b:	57                   	push   %edi
8010877c:	56                   	push   %esi
8010877d:	53                   	push   %ebx
8010877e:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
80108781:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108785:	75 0c                	jne    80108793 <switchuvm+0x1b>
    panic("switchuvm: no process");
80108787:	c7 04 24 a6 98 10 80 	movl   $0x801098a6,(%esp)
8010878e:	e8 c1 7d ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
80108793:	8b 45 08             	mov    0x8(%ebp),%eax
80108796:	8b 40 08             	mov    0x8(%eax),%eax
80108799:	85 c0                	test   %eax,%eax
8010879b:	75 0c                	jne    801087a9 <switchuvm+0x31>
    panic("switchuvm: no kstack");
8010879d:	c7 04 24 bc 98 10 80 	movl   $0x801098bc,(%esp)
801087a4:	e8 ab 7d ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
801087a9:	8b 45 08             	mov    0x8(%ebp),%eax
801087ac:	8b 40 04             	mov    0x4(%eax),%eax
801087af:	85 c0                	test   %eax,%eax
801087b1:	75 0c                	jne    801087bf <switchuvm+0x47>
    panic("switchuvm: no pgdir");
801087b3:	c7 04 24 d1 98 10 80 	movl   $0x801098d1,(%esp)
801087ba:	e8 95 7d ff ff       	call   80100554 <panic>

  pushcli();
801087bf:	e8 da d0 ff ff       	call   8010589e <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801087c4:	e8 5a c5 ff ff       	call   80104d23 <mycpu>
801087c9:	89 c3                	mov    %eax,%ebx
801087cb:	e8 53 c5 ff ff       	call   80104d23 <mycpu>
801087d0:	83 c0 08             	add    $0x8,%eax
801087d3:	89 c6                	mov    %eax,%esi
801087d5:	e8 49 c5 ff ff       	call   80104d23 <mycpu>
801087da:	83 c0 08             	add    $0x8,%eax
801087dd:	c1 e8 10             	shr    $0x10,%eax
801087e0:	89 c7                	mov    %eax,%edi
801087e2:	e8 3c c5 ff ff       	call   80104d23 <mycpu>
801087e7:	83 c0 08             	add    $0x8,%eax
801087ea:	c1 e8 18             	shr    $0x18,%eax
801087ed:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801087f4:	67 00 
801087f6:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801087fd:	89 f9                	mov    %edi,%ecx
801087ff:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80108805:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
8010880b:	83 e2 f0             	and    $0xfffffff0,%edx
8010880e:	83 ca 09             	or     $0x9,%edx
80108811:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108817:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
8010881d:	83 ca 10             	or     $0x10,%edx
80108820:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108826:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
8010882c:	83 e2 9f             	and    $0xffffff9f,%edx
8010882f:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108835:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
8010883b:	83 ca 80             	or     $0xffffff80,%edx
8010883e:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108844:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
8010884a:	83 e2 f0             	and    $0xfffffff0,%edx
8010884d:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108853:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108859:	83 e2 ef             	and    $0xffffffef,%edx
8010885c:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108862:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108868:	83 e2 df             	and    $0xffffffdf,%edx
8010886b:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108871:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108877:	83 ca 40             	or     $0x40,%edx
8010887a:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108880:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108886:	83 e2 7f             	and    $0x7f,%edx
80108889:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
8010888f:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108895:	e8 89 c4 ff ff       	call   80104d23 <mycpu>
8010889a:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
801088a0:	83 e2 ef             	and    $0xffffffef,%edx
801088a3:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801088a9:	e8 75 c4 ff ff       	call   80104d23 <mycpu>
801088ae:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801088b4:	e8 6a c4 ff ff       	call   80104d23 <mycpu>
801088b9:	8b 55 08             	mov    0x8(%ebp),%edx
801088bc:	8b 52 08             	mov    0x8(%edx),%edx
801088bf:	81 c2 00 10 00 00    	add    $0x1000,%edx
801088c5:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801088c8:	e8 56 c4 ff ff       	call   80104d23 <mycpu>
801088cd:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801088d3:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
801088da:	e8 30 f9 ff ff       	call   8010820f <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
801088df:	8b 45 08             	mov    0x8(%ebp),%eax
801088e2:	8b 40 04             	mov    0x4(%eax),%eax
801088e5:	05 00 00 00 80       	add    $0x80000000,%eax
801088ea:	89 04 24             	mov    %eax,(%esp)
801088ed:	e8 32 f9 ff ff       	call   80108224 <lcr3>
  popcli();
801088f2:	e8 f1 cf ff ff       	call   801058e8 <popcli>
}
801088f7:	83 c4 1c             	add    $0x1c,%esp
801088fa:	5b                   	pop    %ebx
801088fb:	5e                   	pop    %esi
801088fc:	5f                   	pop    %edi
801088fd:	5d                   	pop    %ebp
801088fe:	c3                   	ret    

801088ff <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801088ff:	55                   	push   %ebp
80108900:	89 e5                	mov    %esp,%ebp
80108902:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80108905:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010890c:	76 0c                	jbe    8010891a <inituvm+0x1b>
    panic("inituvm: more than a page");
8010890e:	c7 04 24 e5 98 10 80 	movl   $0x801098e5,(%esp)
80108915:	e8 3a 7c ff ff       	call   80100554 <panic>
  mem = kalloc();
8010891a:	e8 b4 a4 ff ff       	call   80102dd3 <kalloc>
8010891f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108922:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108929:	00 
8010892a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108931:	00 
80108932:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108935:	89 04 24             	mov    %eax,(%esp)
80108938:	e8 65 d0 ff ff       	call   801059a2 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010893d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108940:	05 00 00 00 80       	add    $0x80000000,%eax
80108945:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010894c:	00 
8010894d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108951:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108958:	00 
80108959:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108960:	00 
80108961:	8b 45 08             	mov    0x8(%ebp),%eax
80108964:	89 04 24             	mov    %eax,(%esp)
80108967:	e8 9c fc ff ff       	call   80108608 <mappages>
  memmove(mem, init, sz);
8010896c:	8b 45 10             	mov    0x10(%ebp),%eax
8010896f:	89 44 24 08          	mov    %eax,0x8(%esp)
80108973:	8b 45 0c             	mov    0xc(%ebp),%eax
80108976:	89 44 24 04          	mov    %eax,0x4(%esp)
8010897a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010897d:	89 04 24             	mov    %eax,(%esp)
80108980:	e8 e6 d0 ff ff       	call   80105a6b <memmove>
}
80108985:	c9                   	leave  
80108986:	c3                   	ret    

80108987 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108987:	55                   	push   %ebp
80108988:	89 e5                	mov    %esp,%ebp
8010898a:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010898d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108990:	25 ff 0f 00 00       	and    $0xfff,%eax
80108995:	85 c0                	test   %eax,%eax
80108997:	74 0c                	je     801089a5 <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80108999:	c7 04 24 00 99 10 80 	movl   $0x80109900,(%esp)
801089a0:	e8 af 7b ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801089a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801089ac:	e9 a6 00 00 00       	jmp    80108a57 <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801089b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089b4:	8b 55 0c             	mov    0xc(%ebp),%edx
801089b7:	01 d0                	add    %edx,%eax
801089b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801089c0:	00 
801089c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801089c5:	8b 45 08             	mov    0x8(%ebp),%eax
801089c8:	89 04 24             	mov    %eax,(%esp)
801089cb:	e8 9c fb ff ff       	call   8010856c <walkpgdir>
801089d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
801089d3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801089d7:	75 0c                	jne    801089e5 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
801089d9:	c7 04 24 23 99 10 80 	movl   $0x80109923,(%esp)
801089e0:	e8 6f 7b ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
801089e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801089e8:	8b 00                	mov    (%eax),%eax
801089ea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089ef:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
801089f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f5:	8b 55 18             	mov    0x18(%ebp),%edx
801089f8:	29 c2                	sub    %eax,%edx
801089fa:	89 d0                	mov    %edx,%eax
801089fc:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108a01:	77 0f                	ja     80108a12 <loaduvm+0x8b>
      n = sz - i;
80108a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a06:	8b 55 18             	mov    0x18(%ebp),%edx
80108a09:	29 c2                	sub    %eax,%edx
80108a0b:	89 d0                	mov    %edx,%eax
80108a0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a10:	eb 07                	jmp    80108a19 <loaduvm+0x92>
    else
      n = PGSIZE;
80108a12:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a1c:	8b 55 14             	mov    0x14(%ebp),%edx
80108a1f:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80108a22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a25:	05 00 00 00 80       	add    $0x80000000,%eax
80108a2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108a2d:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108a31:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80108a35:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a39:	8b 45 10             	mov    0x10(%ebp),%eax
80108a3c:	89 04 24             	mov    %eax,(%esp)
80108a3f:	e8 79 94 ff ff       	call   80101ebd <readi>
80108a44:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108a47:	74 07                	je     80108a50 <loaduvm+0xc9>
      return -1;
80108a49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108a4e:	eb 18                	jmp    80108a68 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108a50:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108a57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a5a:	3b 45 18             	cmp    0x18(%ebp),%eax
80108a5d:	0f 82 4e ff ff ff    	jb     801089b1 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108a63:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108a68:	c9                   	leave  
80108a69:	c3                   	ret    

80108a6a <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108a6a:	55                   	push   %ebp
80108a6b:	89 e5                	mov    %esp,%ebp
80108a6d:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108a70:	8b 45 10             	mov    0x10(%ebp),%eax
80108a73:	85 c0                	test   %eax,%eax
80108a75:	79 0a                	jns    80108a81 <allocuvm+0x17>
    return 0;
80108a77:	b8 00 00 00 00       	mov    $0x0,%eax
80108a7c:	e9 fd 00 00 00       	jmp    80108b7e <allocuvm+0x114>
  if(newsz < oldsz)
80108a81:	8b 45 10             	mov    0x10(%ebp),%eax
80108a84:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108a87:	73 08                	jae    80108a91 <allocuvm+0x27>
    return oldsz;
80108a89:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a8c:	e9 ed 00 00 00       	jmp    80108b7e <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
80108a91:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a94:	05 ff 0f 00 00       	add    $0xfff,%eax
80108a99:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a9e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108aa1:	e9 c9 00 00 00       	jmp    80108b6f <allocuvm+0x105>
    mem = kalloc();
80108aa6:	e8 28 a3 ff ff       	call   80102dd3 <kalloc>
80108aab:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108aae:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108ab2:	75 2f                	jne    80108ae3 <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
80108ab4:	c7 04 24 41 99 10 80 	movl   $0x80109941,(%esp)
80108abb:	e8 01 79 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108ac0:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ac3:	89 44 24 08          	mov    %eax,0x8(%esp)
80108ac7:	8b 45 10             	mov    0x10(%ebp),%eax
80108aca:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ace:	8b 45 08             	mov    0x8(%ebp),%eax
80108ad1:	89 04 24             	mov    %eax,(%esp)
80108ad4:	e8 a7 00 00 00       	call   80108b80 <deallocuvm>
      return 0;
80108ad9:	b8 00 00 00 00       	mov    $0x0,%eax
80108ade:	e9 9b 00 00 00       	jmp    80108b7e <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
80108ae3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108aea:	00 
80108aeb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108af2:	00 
80108af3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108af6:	89 04 24             	mov    %eax,(%esp)
80108af9:	e8 a4 ce ff ff       	call   801059a2 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108afe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b01:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b0a:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108b11:	00 
80108b12:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108b16:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108b1d:	00 
80108b1e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b22:	8b 45 08             	mov    0x8(%ebp),%eax
80108b25:	89 04 24             	mov    %eax,(%esp)
80108b28:	e8 db fa ff ff       	call   80108608 <mappages>
80108b2d:	85 c0                	test   %eax,%eax
80108b2f:	79 37                	jns    80108b68 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80108b31:	c7 04 24 59 99 10 80 	movl   $0x80109959,(%esp)
80108b38:	e8 84 78 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b40:	89 44 24 08          	mov    %eax,0x8(%esp)
80108b44:	8b 45 10             	mov    0x10(%ebp),%eax
80108b47:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b4b:	8b 45 08             	mov    0x8(%ebp),%eax
80108b4e:	89 04 24             	mov    %eax,(%esp)
80108b51:	e8 2a 00 00 00       	call   80108b80 <deallocuvm>
      kfree(mem);
80108b56:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b59:	89 04 24             	mov    %eax,(%esp)
80108b5c:	e8 dc a1 ff ff       	call   80102d3d <kfree>
      return 0;
80108b61:	b8 00 00 00 00       	mov    $0x0,%eax
80108b66:	eb 16                	jmp    80108b7e <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108b68:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108b6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b72:	3b 45 10             	cmp    0x10(%ebp),%eax
80108b75:	0f 82 2b ff ff ff    	jb     80108aa6 <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80108b7b:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108b7e:	c9                   	leave  
80108b7f:	c3                   	ret    

80108b80 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108b80:	55                   	push   %ebp
80108b81:	89 e5                	mov    %esp,%ebp
80108b83:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108b86:	8b 45 10             	mov    0x10(%ebp),%eax
80108b89:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108b8c:	72 08                	jb     80108b96 <deallocuvm+0x16>
    return oldsz;
80108b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b91:	e9 ac 00 00 00       	jmp    80108c42 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108b96:	8b 45 10             	mov    0x10(%ebp),%eax
80108b99:	05 ff 0f 00 00       	add    $0xfff,%eax
80108b9e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108ba3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108ba6:	e9 88 00 00 00       	jmp    80108c33 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108bb5:	00 
80108bb6:	89 44 24 04          	mov    %eax,0x4(%esp)
80108bba:	8b 45 08             	mov    0x8(%ebp),%eax
80108bbd:	89 04 24             	mov    %eax,(%esp)
80108bc0:	e8 a7 f9 ff ff       	call   8010856c <walkpgdir>
80108bc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108bc8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108bcc:	75 14                	jne    80108be2 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bd1:	c1 e8 16             	shr    $0x16,%eax
80108bd4:	40                   	inc    %eax
80108bd5:	c1 e0 16             	shl    $0x16,%eax
80108bd8:	2d 00 10 00 00       	sub    $0x1000,%eax
80108bdd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108be0:	eb 4a                	jmp    80108c2c <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80108be2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108be5:	8b 00                	mov    (%eax),%eax
80108be7:	83 e0 01             	and    $0x1,%eax
80108bea:	85 c0                	test   %eax,%eax
80108bec:	74 3e                	je     80108c2c <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108bee:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bf1:	8b 00                	mov    (%eax),%eax
80108bf3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bf8:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108bfb:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108bff:	75 0c                	jne    80108c0d <deallocuvm+0x8d>
        panic("kfree");
80108c01:	c7 04 24 75 99 10 80 	movl   $0x80109975,(%esp)
80108c08:	e8 47 79 ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80108c0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c10:	05 00 00 00 80       	add    $0x80000000,%eax
80108c15:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108c18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c1b:	89 04 24             	mov    %eax,(%esp)
80108c1e:	e8 1a a1 ff ff       	call   80102d3d <kfree>
      *pte = 0;
80108c23:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c26:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108c2c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c36:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108c39:	0f 82 6c ff ff ff    	jb     80108bab <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108c3f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108c42:	c9                   	leave  
80108c43:	c3                   	ret    

80108c44 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108c44:	55                   	push   %ebp
80108c45:	89 e5                	mov    %esp,%ebp
80108c47:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108c4a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108c4e:	75 0c                	jne    80108c5c <freevm+0x18>
    panic("freevm: no pgdir");
80108c50:	c7 04 24 7b 99 10 80 	movl   $0x8010997b,(%esp)
80108c57:	e8 f8 78 ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108c5c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108c63:	00 
80108c64:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108c6b:	80 
80108c6c:	8b 45 08             	mov    0x8(%ebp),%eax
80108c6f:	89 04 24             	mov    %eax,(%esp)
80108c72:	e8 09 ff ff ff       	call   80108b80 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108c77:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108c7e:	eb 44                	jmp    80108cc4 <freevm+0x80>
    if(pgdir[i] & PTE_P){
80108c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c83:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108c8a:	8b 45 08             	mov    0x8(%ebp),%eax
80108c8d:	01 d0                	add    %edx,%eax
80108c8f:	8b 00                	mov    (%eax),%eax
80108c91:	83 e0 01             	and    $0x1,%eax
80108c94:	85 c0                	test   %eax,%eax
80108c96:	74 29                	je     80108cc1 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c9b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108ca2:	8b 45 08             	mov    0x8(%ebp),%eax
80108ca5:	01 d0                	add    %edx,%eax
80108ca7:	8b 00                	mov    (%eax),%eax
80108ca9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108cae:	05 00 00 00 80       	add    $0x80000000,%eax
80108cb3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108cb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cb9:	89 04 24             	mov    %eax,(%esp)
80108cbc:	e8 7c a0 ff ff       	call   80102d3d <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108cc1:	ff 45 f4             	incl   -0xc(%ebp)
80108cc4:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108ccb:	76 b3                	jbe    80108c80 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108ccd:	8b 45 08             	mov    0x8(%ebp),%eax
80108cd0:	89 04 24             	mov    %eax,(%esp)
80108cd3:	e8 65 a0 ff ff       	call   80102d3d <kfree>
}
80108cd8:	c9                   	leave  
80108cd9:	c3                   	ret    

80108cda <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108cda:	55                   	push   %ebp
80108cdb:	89 e5                	mov    %esp,%ebp
80108cdd:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108ce0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108ce7:	00 
80108ce8:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ceb:	89 44 24 04          	mov    %eax,0x4(%esp)
80108cef:	8b 45 08             	mov    0x8(%ebp),%eax
80108cf2:	89 04 24             	mov    %eax,(%esp)
80108cf5:	e8 72 f8 ff ff       	call   8010856c <walkpgdir>
80108cfa:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108cfd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108d01:	75 0c                	jne    80108d0f <clearpteu+0x35>
    panic("clearpteu");
80108d03:	c7 04 24 8c 99 10 80 	movl   $0x8010998c,(%esp)
80108d0a:	e8 45 78 ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80108d0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d12:	8b 00                	mov    (%eax),%eax
80108d14:	83 e0 fb             	and    $0xfffffffb,%eax
80108d17:	89 c2                	mov    %eax,%edx
80108d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d1c:	89 10                	mov    %edx,(%eax)
}
80108d1e:	c9                   	leave  
80108d1f:	c3                   	ret    

80108d20 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108d20:	55                   	push   %ebp
80108d21:	89 e5                	mov    %esp,%ebp
80108d23:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108d26:	e8 73 f9 ff ff       	call   8010869e <setupkvm>
80108d2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108d2e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108d32:	75 0a                	jne    80108d3e <copyuvm+0x1e>
    return 0;
80108d34:	b8 00 00 00 00       	mov    $0x0,%eax
80108d39:	e9 f8 00 00 00       	jmp    80108e36 <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80108d3e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d45:	e9 cb 00 00 00       	jmp    80108e15 <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d4d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108d54:	00 
80108d55:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d59:	8b 45 08             	mov    0x8(%ebp),%eax
80108d5c:	89 04 24             	mov    %eax,(%esp)
80108d5f:	e8 08 f8 ff ff       	call   8010856c <walkpgdir>
80108d64:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108d67:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108d6b:	75 0c                	jne    80108d79 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108d6d:	c7 04 24 96 99 10 80 	movl   $0x80109996,(%esp)
80108d74:	e8 db 77 ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
80108d79:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d7c:	8b 00                	mov    (%eax),%eax
80108d7e:	83 e0 01             	and    $0x1,%eax
80108d81:	85 c0                	test   %eax,%eax
80108d83:	75 0c                	jne    80108d91 <copyuvm+0x71>
      panic("copyuvm: page not present");
80108d85:	c7 04 24 b0 99 10 80 	movl   $0x801099b0,(%esp)
80108d8c:	e8 c3 77 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108d91:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108d94:	8b 00                	mov    (%eax),%eax
80108d96:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d9b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108d9e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108da1:	8b 00                	mov    (%eax),%eax
80108da3:	25 ff 0f 00 00       	and    $0xfff,%eax
80108da8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108dab:	e8 23 a0 ff ff       	call   80102dd3 <kalloc>
80108db0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108db3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108db7:	75 02                	jne    80108dbb <copyuvm+0x9b>
      goto bad;
80108db9:	eb 6b                	jmp    80108e26 <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108dbb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108dbe:	05 00 00 00 80       	add    $0x80000000,%eax
80108dc3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108dca:	00 
80108dcb:	89 44 24 04          	mov    %eax,0x4(%esp)
80108dcf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108dd2:	89 04 24             	mov    %eax,(%esp)
80108dd5:	e8 91 cc ff ff       	call   80105a6b <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108dda:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108ddd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108de0:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108de6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108de9:	89 54 24 10          	mov    %edx,0x10(%esp)
80108ded:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108df1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108df8:	00 
80108df9:	89 44 24 04          	mov    %eax,0x4(%esp)
80108dfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e00:	89 04 24             	mov    %eax,(%esp)
80108e03:	e8 00 f8 ff ff       	call   80108608 <mappages>
80108e08:	85 c0                	test   %eax,%eax
80108e0a:	79 02                	jns    80108e0e <copyuvm+0xee>
      goto bad;
80108e0c:	eb 18                	jmp    80108e26 <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108e0e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108e15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e18:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108e1b:	0f 82 29 ff ff ff    	jb     80108d4a <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
80108e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e24:	eb 10                	jmp    80108e36 <copyuvm+0x116>

bad:
  freevm(d);
80108e26:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e29:	89 04 24             	mov    %eax,(%esp)
80108e2c:	e8 13 fe ff ff       	call   80108c44 <freevm>
  return 0;
80108e31:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108e36:	c9                   	leave  
80108e37:	c3                   	ret    

80108e38 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108e38:	55                   	push   %ebp
80108e39:	89 e5                	mov    %esp,%ebp
80108e3b:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108e3e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108e45:	00 
80108e46:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e49:	89 44 24 04          	mov    %eax,0x4(%esp)
80108e4d:	8b 45 08             	mov    0x8(%ebp),%eax
80108e50:	89 04 24             	mov    %eax,(%esp)
80108e53:	e8 14 f7 ff ff       	call   8010856c <walkpgdir>
80108e58:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108e5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e5e:	8b 00                	mov    (%eax),%eax
80108e60:	83 e0 01             	and    $0x1,%eax
80108e63:	85 c0                	test   %eax,%eax
80108e65:	75 07                	jne    80108e6e <uva2ka+0x36>
    return 0;
80108e67:	b8 00 00 00 00       	mov    $0x0,%eax
80108e6c:	eb 22                	jmp    80108e90 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e71:	8b 00                	mov    (%eax),%eax
80108e73:	83 e0 04             	and    $0x4,%eax
80108e76:	85 c0                	test   %eax,%eax
80108e78:	75 07                	jne    80108e81 <uva2ka+0x49>
    return 0;
80108e7a:	b8 00 00 00 00       	mov    $0x0,%eax
80108e7f:	eb 0f                	jmp    80108e90 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
80108e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e84:	8b 00                	mov    (%eax),%eax
80108e86:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e8b:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108e90:	c9                   	leave  
80108e91:	c3                   	ret    

80108e92 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108e92:	55                   	push   %ebp
80108e93:	89 e5                	mov    %esp,%ebp
80108e95:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108e98:	8b 45 10             	mov    0x10(%ebp),%eax
80108e9b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108e9e:	e9 87 00 00 00       	jmp    80108f2a <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ea6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108eab:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108eae:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108eb1:	89 44 24 04          	mov    %eax,0x4(%esp)
80108eb5:	8b 45 08             	mov    0x8(%ebp),%eax
80108eb8:	89 04 24             	mov    %eax,(%esp)
80108ebb:	e8 78 ff ff ff       	call   80108e38 <uva2ka>
80108ec0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108ec3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108ec7:	75 07                	jne    80108ed0 <copyout+0x3e>
      return -1;
80108ec9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108ece:	eb 69                	jmp    80108f39 <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
80108ed3:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108ed6:	29 c2                	sub    %eax,%edx
80108ed8:	89 d0                	mov    %edx,%eax
80108eda:	05 00 10 00 00       	add    $0x1000,%eax
80108edf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108ee2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ee5:	3b 45 14             	cmp    0x14(%ebp),%eax
80108ee8:	76 06                	jbe    80108ef0 <copyout+0x5e>
      n = len;
80108eea:	8b 45 14             	mov    0x14(%ebp),%eax
80108eed:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108ef0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ef3:	8b 55 0c             	mov    0xc(%ebp),%edx
80108ef6:	29 c2                	sub    %eax,%edx
80108ef8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108efb:	01 c2                	add    %eax,%edx
80108efd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f00:	89 44 24 08          	mov    %eax,0x8(%esp)
80108f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f07:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f0b:	89 14 24             	mov    %edx,(%esp)
80108f0e:	e8 58 cb ff ff       	call   80105a6b <memmove>
    len -= n;
80108f13:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f16:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108f19:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108f1c:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108f1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f22:	05 00 10 00 00       	add    $0x1000,%eax
80108f27:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108f2a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108f2e:	0f 85 6f ff ff ff    	jne    80108ea3 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108f34:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108f39:	c9                   	leave  
80108f3a:	c3                   	ret    
