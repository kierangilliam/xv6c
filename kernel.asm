
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
8010003a:	c7 44 24 04 5c 8c 10 	movl   $0x80108c5c,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 a0 d7 10 80 	movl   $0x8010d7a0,(%esp)
80100049:	e8 f0 53 00 00       	call   8010543e <initlock>

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
80100087:	c7 44 24 04 63 8c 10 	movl   $0x80108c63,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 69 52 00 00       	call   80105300 <initsleeplock>
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
801000c9:	e8 91 53 00 00       	call   8010545f <acquire>

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
80100104:	e8 c0 53 00 00       	call   801054c9 <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 23 52 00 00       	call   8010533a <acquiresleep>
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
8010017d:	e8 47 53 00 00       	call   801054c9 <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 aa 51 00 00       	call   8010533a <acquiresleep>
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
801001a7:	c7 04 24 6a 8c 10 80 	movl   $0x80108c6a,(%esp)
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
801001fb:	e8 d7 51 00 00       	call   801053d7 <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 7b 8c 10 80 	movl   $0x80108c7b,(%esp)
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
8010023b:	e8 97 51 00 00       	call   801053d7 <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 82 8c 10 80 	movl   $0x80108c82,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 37 51 00 00       	call   80105395 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 a0 d7 10 80 	movl   $0x8010d7a0,(%esp)
80100265:	e8 f5 51 00 00       	call   8010545f <acquire>
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
801002d1:	e8 f3 51 00 00       	call   801054c9 <release>
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
801003dc:	e8 7e 50 00 00       	call   8010545f <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 89 8c 10 80 	movl   $0x80108c89,(%esp)
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
801004cf:	c7 45 ec 92 8c 10 80 	movl   $0x80108c92,-0x14(%ebp)
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
8010054d:	e8 77 4f 00 00       	call   801054c9 <release>
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
80100569:	e8 67 2a 00 00       	call   80102fd5 <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 99 8c 10 80 	movl   $0x80108c99,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 ad 8c 10 80 	movl   $0x80108cad,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 6f 4f 00 00       	call   80105516 <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 af 8c 10 80 	movl   $0x80108caf,(%esp)
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
80100695:	c7 04 24 b3 8c 10 80 	movl   $0x80108cb3,(%esp)
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
801006c9:	e8 bd 50 00 00       	call   8010578b <memmove>
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
801006f8:	e8 c5 4f 00 00       	call   801056c2 <memset>
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
8010078e:	e8 49 6c 00 00       	call   801073dc <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 3d 6c 00 00       	call   801073dc <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 31 6c 00 00       	call   801073dc <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 24 6c 00 00       	call   801073dc <uartputc>
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
80100813:	e8 47 4c 00 00       	call   8010545f <acquire>
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
801009e0:	e8 69 3f 00 00       	call   8010494e <wakeup>
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
80100a01:	e8 c3 4a 00 00       	call   801054c9 <release>
  if(doprocdump){
80100a06:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a0a:	74 05                	je     80100a11 <consoleintr+0x21c>
    procdump();  // now call procdump() wo. cons.lock held
80100a0c:	e8 ef 3f 00 00       	call   80104a00 <procdump>
  }
  if(doconsoleswitch){
80100a11:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a15:	74 15                	je     80100a2c <consoleintr+0x237>
    cprintf("\nActive console now: %d\n", active);
80100a17:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a20:	c7 04 24 c6 8c 10 80 	movl   $0x80108cc6,(%esp)
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
80100a52:	e8 08 4a 00 00       	call   8010545f <acquire>
  while(n > 0){
80100a57:	e9 b7 00 00 00       	jmp    80100b13 <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a5c:	eb 41                	jmp    80100a9f <consoleread+0x6b>
      if(myproc()->killed){
80100a5e:	e8 b9 36 00 00       	call   8010411c <myproc>
80100a63:	8b 40 24             	mov    0x24(%eax),%eax
80100a66:	85 c0                	test   %eax,%eax
80100a68:	74 21                	je     80100a8b <consoleread+0x57>
        release(&cons.lock);
80100a6a:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
80100a71:	e8 53 4a 00 00       	call   801054c9 <release>
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
80100a9a:	e8 c1 3d 00 00       	call   80104860 <sleep>

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
80100b24:	e8 a0 49 00 00       	call   801054c9 <release>
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
80100b6a:	e8 f0 48 00 00       	call   8010545f <acquire>
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
80100ba2:	e8 22 49 00 00       	call   801054c9 <release>
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
80100bbd:	c7 44 24 04 df 8c 10 	movl   $0x80108cdf,0x4(%esp)
80100bc4:	80 
80100bc5:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
80100bcc:	e8 6d 48 00 00       	call   8010543e <initlock>

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
80100c11:	e8 06 35 00 00       	call   8010411c <myproc>
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
80100c37:	c7 04 24 e7 8c 10 80 	movl   $0x80108ce7,(%esp)
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
80100ca0:	e8 19 77 00 00       	call   801083be <setupkvm>
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
80100d5e:	e8 27 7a 00 00       	call   8010878a <allocuvm>
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
80100db0:	e8 f2 78 00 00       	call   801086a7 <loaduvm>
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
80100e1c:	e8 69 79 00 00       	call   8010878a <allocuvm>
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
80100e41:	e8 b4 7b 00 00       	call   801089fa <clearpteu>
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
80100e77:	e8 99 4a 00 00       	call   80105915 <strlen>
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
80100e9e:	e8 72 4a 00 00       	call   80105915 <strlen>
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
80100ecc:	e8 e1 7c 00 00       	call   80108bb2 <copyout>
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
80100f70:	e8 3d 7c 00 00       	call   80108bb2 <copyout>
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
80100fc0:	e8 09 49 00 00       	call   801058ce <safestrcpy>

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
80101000:	e8 93 74 00 00       	call   80108498 <switchuvm>
  freevm(oldpgdir);
80101005:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101008:	89 04 24             	mov    %eax,(%esp)
8010100b:	e8 54 79 00 00       	call   80108964 <freevm>
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
80101023:	e8 3c 79 00 00       	call   80108964 <freevm>
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
8010104e:	c7 44 24 04 f3 8c 10 	movl   $0x80108cf3,0x4(%esp)
80101055:	80 
80101056:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
8010105d:	e8 dc 43 00 00       	call   8010543e <initlock>
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
80101071:	e8 e9 43 00 00       	call   8010545f <acquire>
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
8010109a:	e8 2a 44 00 00       	call   801054c9 <release>
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
801010b8:	e8 0c 44 00 00       	call   801054c9 <release>
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
801010d1:	e8 89 43 00 00       	call   8010545f <acquire>
  if(f->ref < 1)
801010d6:	8b 45 08             	mov    0x8(%ebp),%eax
801010d9:	8b 40 04             	mov    0x4(%eax),%eax
801010dc:	85 c0                	test   %eax,%eax
801010de:	7f 0c                	jg     801010ec <filedup+0x28>
    panic("filedup");
801010e0:	c7 04 24 fa 8c 10 80 	movl   $0x80108cfa,(%esp)
801010e7:	e8 68 f4 ff ff       	call   80100554 <panic>
  f->ref++;
801010ec:	8b 45 08             	mov    0x8(%ebp),%eax
801010ef:	8b 40 04             	mov    0x4(%eax),%eax
801010f2:	8d 50 01             	lea    0x1(%eax),%edx
801010f5:	8b 45 08             	mov    0x8(%ebp),%eax
801010f8:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010fb:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
80101102:	e8 c2 43 00 00       	call   801054c9 <release>
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
8010111c:	e8 3e 43 00 00       	call   8010545f <acquire>
  if(f->ref < 1)
80101121:	8b 45 08             	mov    0x8(%ebp),%eax
80101124:	8b 40 04             	mov    0x4(%eax),%eax
80101127:	85 c0                	test   %eax,%eax
80101129:	7f 0c                	jg     80101137 <fileclose+0x2b>
    panic("fileclose");
8010112b:	c7 04 24 02 8d 10 80 	movl   $0x80108d02,(%esp)
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
80101157:	e8 6d 43 00 00       	call   801054c9 <release>
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
8010118d:	e8 37 43 00 00       	call   801054c9 <release>

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
801011aa:	e8 00 2d 00 00       	call   80103eaf <pipeclose>
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
80101260:	e8 c8 2d 00 00       	call   8010402d <piperead>
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
801012d2:	c7 04 24 0c 8d 10 80 	movl   $0x80108d0c,(%esp)
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
8010131c:	e8 20 2c 00 00       	call   80103f41 <pipewrite>
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
801013dd:	c7 04 24 15 8d 10 80 	movl   $0x80108d15,(%esp)
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
8010140f:	c7 04 24 25 8d 10 80 	movl   $0x80108d25,(%esp)
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
80101458:	e8 2e 43 00 00       	call   8010578b <memmove>
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
8010149e:	e8 1f 42 00 00       	call   801056c2 <memset>
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
801015e7:	c7 04 24 30 8d 10 80 	movl   $0x80108d30,(%esp)
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
80101677:	c7 04 24 46 8d 10 80 	movl   $0x80108d46,(%esp)
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
801016cf:	c7 44 24 04 59 8d 10 	movl   $0x80108d59,0x4(%esp)
801016d6:	80 
801016d7:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
801016de:	e8 5b 3d 00 00       	call   8010543e <initlock>
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
80101704:	c7 44 24 04 60 8d 10 	movl   $0x80108d60,0x4(%esp)
8010170b:	80 
8010170c:	89 04 24             	mov    %eax,(%esp)
8010170f:	e8 ec 3b 00 00       	call   80105300 <initsleeplock>
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
8010177d:	c7 04 24 68 8d 10 80 	movl   $0x80108d68,(%esp)
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
801017ff:	e8 be 3e 00 00       	call   801056c2 <memset>
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
80101848:	a1 a8 2b 11 80       	mov    0x80112ba8,%eax
8010184d:	39 c2                	cmp    %eax,%edx
8010184f:	0f 82 55 ff ff ff    	jb     801017aa <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101855:	c7 04 24 bb 8d 10 80 	movl   $0x80108dbb,(%esp)
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
80101902:	e8 84 3e 00 00       	call   8010578b <memmove>
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
80101925:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
8010192c:	e8 2e 3b 00 00       	call   8010545f <acquire>

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
80101976:	e8 4e 3b 00 00       	call   801054c9 <release>
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
801019ac:	c7 04 24 cd 8d 10 80 	movl   $0x80108dcd,(%esp)
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
801019ea:	e8 da 3a 00 00       	call   801054c9 <release>

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
80101a01:	e8 59 3a 00 00       	call   8010545f <acquire>
  ip->ref++;
80101a06:	8b 45 08             	mov    0x8(%ebp),%eax
80101a09:	8b 40 08             	mov    0x8(%eax),%eax
80101a0c:	8d 50 01             	lea    0x1(%eax),%edx
80101a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a12:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a15:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101a1c:	e8 a8 3a 00 00       	call   801054c9 <release>
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
80101a3c:	c7 04 24 dd 8d 10 80 	movl   $0x80108ddd,(%esp)
80101a43:	e8 0c eb ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101a48:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4b:	83 c0 0c             	add    $0xc,%eax
80101a4e:	89 04 24             	mov    %eax,(%esp)
80101a51:	e8 e4 38 00 00       	call   8010533a <acquiresleep>

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
80101afd:	e8 89 3c 00 00       	call   8010578b <memmove>
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
80101b22:	c7 04 24 e3 8d 10 80 	movl   $0x80108de3,(%esp)
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
80101b45:	e8 8d 38 00 00       	call   801053d7 <holdingsleep>
80101b4a:	85 c0                	test   %eax,%eax
80101b4c:	74 0a                	je     80101b58 <iunlock+0x28>
80101b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b51:	8b 40 08             	mov    0x8(%eax),%eax
80101b54:	85 c0                	test   %eax,%eax
80101b56:	7f 0c                	jg     80101b64 <iunlock+0x34>
    panic("iunlock");
80101b58:	c7 04 24 f2 8d 10 80 	movl   $0x80108df2,(%esp)
80101b5f:	e8 f0 e9 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101b64:	8b 45 08             	mov    0x8(%ebp),%eax
80101b67:	83 c0 0c             	add    $0xc,%eax
80101b6a:	89 04 24             	mov    %eax,(%esp)
80101b6d:	e8 23 38 00 00       	call   80105395 <releasesleep>
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
80101b83:	e8 b2 37 00 00       	call   8010533a <acquiresleep>
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
80101ba5:	e8 b5 38 00 00       	call   8010545f <acquire>
    int r = ip->ref;
80101baa:	8b 45 08             	mov    0x8(%ebp),%eax
80101bad:	8b 40 08             	mov    0x8(%eax),%eax
80101bb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101bb3:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101bba:	e8 0a 39 00 00       	call   801054c9 <release>
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
80101bf7:	e8 99 37 00 00       	call   80105395 <releasesleep>

  acquire(&icache.lock);
80101bfc:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101c03:	e8 57 38 00 00       	call   8010545f <acquire>
  ip->ref--;
80101c08:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0b:	8b 40 08             	mov    0x8(%eax),%eax
80101c0e:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c11:	8b 45 08             	mov    0x8(%ebp),%eax
80101c14:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c17:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101c1e:	e8 a6 38 00 00       	call   801054c9 <release>
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
80101d44:	c7 04 24 fa 8d 10 80 	movl   $0x80108dfa,(%esp)
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
80101fee:	e8 98 37 00 00       	call   8010578b <memmove>
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
8010214d:	e8 39 36 00 00       	call   8010578b <memmove>
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
801021cb:	e8 5a 36 00 00       	call   8010582a <strncmp>
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
801021e4:	c7 04 24 0d 8e 10 80 	movl   $0x80108e0d,(%esp)
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
80102222:	c7 04 24 1f 8e 10 80 	movl   $0x80108e1f,(%esp)
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
80102305:	c7 04 24 2e 8e 10 80 	movl   $0x80108e2e,(%esp)
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
80102349:	e8 2a 35 00 00       	call   80105878 <strncpy>
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
8010237b:	c7 04 24 3b 8e 10 80 	movl   $0x80108e3b,(%esp)
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
801023fa:	e8 8c 33 00 00       	call   8010578b <memmove>
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
80102415:	e8 71 33 00 00       	call   8010578b <memmove>
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
80102463:	e8 b4 1c 00 00       	call   8010411c <myproc>
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
8010265b:	c7 44 24 04 43 8e 10 	movl   $0x80108e43,0x4(%esp)
80102662:	80 
80102663:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
8010266a:	e8 cf 2d 00 00       	call   8010543e <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
8010266f:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
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
801026be:	c7 05 78 c7 10 80 01 	movl   $0x1,0x8010c778
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
801026f8:	c7 04 24 47 8e 10 80 	movl   $0x80108e47,(%esp)
801026ff:	e8 50 de ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
80102704:	8b 45 08             	mov    0x8(%ebp),%eax
80102707:	8b 40 08             	mov    0x8(%eax),%eax
8010270a:	3d e7 03 00 00       	cmp    $0x3e7,%eax
8010270f:	76 0c                	jbe    8010271d <idestart+0x31>
    panic("incorrect blockno");
80102711:	c7 04 24 50 8e 10 80 	movl   $0x80108e50,(%esp)
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
80102763:	c7 04 24 47 8e 10 80 	movl   $0x80108e47,(%esp)
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
8010287c:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
80102883:	e8 d7 2b 00 00       	call   8010545f <acquire>

  if((b = idequeue) == 0){
80102888:	a1 74 c7 10 80       	mov    0x8010c774,%eax
8010288d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102890:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102894:	75 11                	jne    801028a7 <ideintr+0x31>
    release(&idelock);
80102896:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
8010289d:	e8 27 2c 00 00       	call   801054c9 <release>
    return;
801028a2:	e9 90 00 00 00       	jmp    80102937 <ideintr+0xc1>
  }
  idequeue = b->qnext;
801028a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028aa:	8b 40 58             	mov    0x58(%eax),%eax
801028ad:	a3 74 c7 10 80       	mov    %eax,0x8010c774

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
80102910:	e8 39 20 00 00       	call   8010494e <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102915:	a1 74 c7 10 80       	mov    0x8010c774,%eax
8010291a:	85 c0                	test   %eax,%eax
8010291c:	74 0d                	je     8010292b <ideintr+0xb5>
    idestart(idequeue);
8010291e:	a1 74 c7 10 80       	mov    0x8010c774,%eax
80102923:	89 04 24             	mov    %eax,(%esp)
80102926:	e8 c1 fd ff ff       	call   801026ec <idestart>

  release(&idelock);
8010292b:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
80102932:	e8 92 2b 00 00       	call   801054c9 <release>
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
80102948:	e8 8a 2a 00 00       	call   801053d7 <holdingsleep>
8010294d:	85 c0                	test   %eax,%eax
8010294f:	75 0c                	jne    8010295d <iderw+0x24>
    panic("iderw: buf not locked");
80102951:	c7 04 24 62 8e 10 80 	movl   $0x80108e62,(%esp)
80102958:	e8 f7 db ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010295d:	8b 45 08             	mov    0x8(%ebp),%eax
80102960:	8b 00                	mov    (%eax),%eax
80102962:	83 e0 06             	and    $0x6,%eax
80102965:	83 f8 02             	cmp    $0x2,%eax
80102968:	75 0c                	jne    80102976 <iderw+0x3d>
    panic("iderw: nothing to do");
8010296a:	c7 04 24 78 8e 10 80 	movl   $0x80108e78,(%esp)
80102971:	e8 de db ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
80102976:	8b 45 08             	mov    0x8(%ebp),%eax
80102979:	8b 40 04             	mov    0x4(%eax),%eax
8010297c:	85 c0                	test   %eax,%eax
8010297e:	74 15                	je     80102995 <iderw+0x5c>
80102980:	a1 78 c7 10 80       	mov    0x8010c778,%eax
80102985:	85 c0                	test   %eax,%eax
80102987:	75 0c                	jne    80102995 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
80102989:	c7 04 24 8d 8e 10 80 	movl   $0x80108e8d,(%esp)
80102990:	e8 bf db ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102995:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
8010299c:	e8 be 2a 00 00       	call   8010545f <acquire>

  // Append b to idequeue.
  b->qnext = 0;
801029a1:	8b 45 08             	mov    0x8(%ebp),%eax
801029a4:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801029ab:	c7 45 f4 74 c7 10 80 	movl   $0x8010c774,-0xc(%ebp)
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
801029d0:	a1 74 c7 10 80       	mov    0x8010c774,%eax
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
801029e9:	c7 44 24 04 40 c7 10 	movl   $0x8010c740,0x4(%esp)
801029f0:	80 
801029f1:	8b 45 08             	mov    0x8(%ebp),%eax
801029f4:	89 04 24             	mov    %eax,(%esp)
801029f7:	e8 64 1e 00 00       	call   80104860 <sleep>
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
80102a09:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
80102a10:	e8 b4 2a 00 00       	call   801054c9 <release>
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
80102a1b:	a1 14 48 11 80       	mov    0x80114814,%eax
80102a20:	8b 55 08             	mov    0x8(%ebp),%edx
80102a23:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102a25:	a1 14 48 11 80       	mov    0x80114814,%eax
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
80102a32:	a1 14 48 11 80       	mov    0x80114814,%eax
80102a37:	8b 55 08             	mov    0x8(%ebp),%edx
80102a3a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102a3c:	a1 14 48 11 80       	mov    0x80114814,%eax
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
80102a4f:	c7 05 14 48 11 80 00 	movl   $0xfec00000,0x80114814
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
80102a82:	a0 40 49 11 80       	mov    0x80114940,%al
80102a87:	0f b6 c0             	movzbl %al,%eax
80102a8a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102a8d:	74 0c                	je     80102a9b <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a8f:	c7 04 24 ac 8e 10 80 	movl   $0x80108eac,(%esp)
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
80102b32:	c7 44 24 04 de 8e 10 	movl   $0x80108ede,0x4(%esp)
80102b39:	80 
80102b3a:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102b41:	e8 f8 28 00 00       	call   8010543e <initlock>
  kmem.use_lock = 0;
80102b46:	c7 05 54 48 11 80 00 	movl   $0x0,0x80114854
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
80102b7c:	c7 05 54 48 11 80 01 	movl   $0x1,0x80114854
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
80102bd3:	81 7d 08 48 61 12 80 	cmpl   $0x80126148,0x8(%ebp)
80102bda:	72 0f                	jb     80102beb <kfree+0x2a>
80102bdc:	8b 45 08             	mov    0x8(%ebp),%eax
80102bdf:	05 00 00 00 80       	add    $0x80000000,%eax
80102be4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102be9:	76 0c                	jbe    80102bf7 <kfree+0x36>
    panic("kfree");
80102beb:	c7 04 24 e3 8e 10 80 	movl   $0x80108ee3,(%esp)
80102bf2:	e8 5d d9 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102bf7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102bfe:	00 
80102bff:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102c06:	00 
80102c07:	8b 45 08             	mov    0x8(%ebp),%eax
80102c0a:	89 04 24             	mov    %eax,(%esp)
80102c0d:	e8 b0 2a 00 00       	call   801056c2 <memset>

  if(kmem.use_lock)
80102c12:	a1 54 48 11 80       	mov    0x80114854,%eax
80102c17:	85 c0                	test   %eax,%eax
80102c19:	74 0c                	je     80102c27 <kfree+0x66>
    acquire(&kmem.lock);
80102c1b:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102c22:	e8 38 28 00 00       	call   8010545f <acquire>
  r = (struct run*)v;
80102c27:	8b 45 08             	mov    0x8(%ebp),%eax
80102c2a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c2d:	8b 15 58 48 11 80    	mov    0x80114858,%edx
80102c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c36:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c3b:	a3 58 48 11 80       	mov    %eax,0x80114858
  if(kmem.use_lock)
80102c40:	a1 54 48 11 80       	mov    0x80114854,%eax
80102c45:	85 c0                	test   %eax,%eax
80102c47:	74 0c                	je     80102c55 <kfree+0x94>
    release(&kmem.lock);
80102c49:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102c50:	e8 74 28 00 00       	call   801054c9 <release>
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
80102c5d:	a1 54 48 11 80       	mov    0x80114854,%eax
80102c62:	85 c0                	test   %eax,%eax
80102c64:	74 0c                	je     80102c72 <kalloc+0x1b>
    acquire(&kmem.lock);
80102c66:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102c6d:	e8 ed 27 00 00       	call   8010545f <acquire>
  r = kmem.freelist;
80102c72:	a1 58 48 11 80       	mov    0x80114858,%eax
80102c77:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102c7a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c7e:	74 0a                	je     80102c8a <kalloc+0x33>
    kmem.freelist = r->next;
80102c80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c83:	8b 00                	mov    (%eax),%eax
80102c85:	a3 58 48 11 80       	mov    %eax,0x80114858
  if(kmem.use_lock)
80102c8a:	a1 54 48 11 80       	mov    0x80114854,%eax
80102c8f:	85 c0                	test   %eax,%eax
80102c91:	74 0c                	je     80102c9f <kalloc+0x48>
    release(&kmem.lock);
80102c93:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102c9a:	e8 2a 28 00 00       	call   801054c9 <release>
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
80102d06:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102d0b:	83 c8 40             	or     $0x40,%eax
80102d0e:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
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
80102d29:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
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
80102d46:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102d4b:	8a 00                	mov    (%eax),%al
80102d4d:	83 c8 40             	or     $0x40,%eax
80102d50:	0f b6 c0             	movzbl %al,%eax
80102d53:	f7 d0                	not    %eax
80102d55:	89 c2                	mov    %eax,%edx
80102d57:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102d5c:	21 d0                	and    %edx,%eax
80102d5e:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
    return 0;
80102d63:	b8 00 00 00 00       	mov    $0x0,%eax
80102d68:	e9 9f 00 00 00       	jmp    80102e0c <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102d6d:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102d72:	83 e0 40             	and    $0x40,%eax
80102d75:	85 c0                	test   %eax,%eax
80102d77:	74 14                	je     80102d8d <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102d79:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102d80:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102d85:	83 e0 bf             	and    $0xffffffbf,%eax
80102d88:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
  }

  shift |= shiftcode[data];
80102d8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d90:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102d95:	8a 00                	mov    (%eax),%al
80102d97:	0f b6 d0             	movzbl %al,%edx
80102d9a:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102d9f:	09 d0                	or     %edx,%eax
80102da1:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
  shift ^= togglecode[data];
80102da6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102da9:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102dae:	8a 00                	mov    (%eax),%al
80102db0:	0f b6 d0             	movzbl %al,%edx
80102db3:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102db8:	31 d0                	xor    %edx,%eax
80102dba:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
  c = charcode[shift & (CTL | SHIFT)][data];
80102dbf:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102dc4:	83 e0 03             	and    $0x3,%eax
80102dc7:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102dce:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dd1:	01 d0                	add    %edx,%eax
80102dd3:	8a 00                	mov    (%eax),%al
80102dd5:	0f b6 c0             	movzbl %al,%eax
80102dd8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102ddb:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
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
80102e5e:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80102e63:	8b 55 08             	mov    0x8(%ebp),%edx
80102e66:	c1 e2 02             	shl    $0x2,%edx
80102e69:	01 c2                	add    %eax,%edx
80102e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e6e:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102e70:	a1 5c 48 11 80       	mov    0x8011485c,%eax
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
80102e82:	a1 5c 48 11 80       	mov    0x8011485c,%eax
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
80102f08:	a1 5c 48 11 80       	mov    0x8011485c,%eax
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
80102faa:	a1 5c 48 11 80       	mov    0x8011485c,%eax
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
80102fd8:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80102fdd:	85 c0                	test   %eax,%eax
80102fdf:	75 07                	jne    80102fe8 <lapicid+0x13>
    return 0;
80102fe1:	b8 00 00 00 00       	mov    $0x0,%eax
80102fe6:	eb 0d                	jmp    80102ff5 <lapicid+0x20>
  return lapic[ID] >> 24;
80102fe8:	a1 5c 48 11 80       	mov    0x8011485c,%eax
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
80102ffd:	a1 5c 48 11 80       	mov    0x8011485c,%eax
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
80103231:	e8 03 25 00 00       	call   80105739 <memcmp>
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
80103326:	c7 44 24 04 e9 8e 10 	movl   $0x80108ee9,0x4(%esp)
8010332d:	80 
8010332e:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103335:	e8 04 21 00 00       	call   8010543e <initlock>
  readsb(dev, &sb);
8010333a:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010333d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103341:	8b 45 08             	mov    0x8(%ebp),%eax
80103344:	89 04 24             	mov    %eax,(%esp)
80103347:	e8 d8 e0 ff ff       	call   80101424 <readsb>
  log.start = sb.logstart;
8010334c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010334f:	a3 94 48 11 80       	mov    %eax,0x80114894
  log.size = sb.nlog;
80103354:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103357:	a3 98 48 11 80       	mov    %eax,0x80114898
  log.dev = dev;
8010335c:	8b 45 08             	mov    0x8(%ebp),%eax
8010335f:	a3 a4 48 11 80       	mov    %eax,0x801148a4
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
8010337d:	8b 15 94 48 11 80    	mov    0x80114894,%edx
80103383:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103386:	01 d0                	add    %edx,%eax
80103388:	40                   	inc    %eax
80103389:	89 c2                	mov    %eax,%edx
8010338b:	a1 a4 48 11 80       	mov    0x801148a4,%eax
80103390:	89 54 24 04          	mov    %edx,0x4(%esp)
80103394:	89 04 24             	mov    %eax,(%esp)
80103397:	e8 19 ce ff ff       	call   801001b5 <bread>
8010339c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010339f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801033a2:	83 c0 10             	add    $0x10,%eax
801033a5:	8b 04 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%eax
801033ac:	89 c2                	mov    %eax,%edx
801033ae:	a1 a4 48 11 80       	mov    0x801148a4,%eax
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
801033dd:	e8 a9 23 00 00       	call   8010578b <memmove>
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
80103406:	a1 a8 48 11 80       	mov    0x801148a8,%eax
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
8010341c:	a1 94 48 11 80       	mov    0x80114894,%eax
80103421:	89 c2                	mov    %eax,%edx
80103423:	a1 a4 48 11 80       	mov    0x801148a4,%eax
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
80103445:	a3 a8 48 11 80       	mov    %eax,0x801148a8
  for (i = 0; i < log.lh.n; i++) {
8010344a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103451:	eb 1a                	jmp    8010346d <read_head+0x57>
    log.lh.block[i] = lh->block[i];
80103453:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103456:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103459:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010345d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103460:	83 c2 10             	add    $0x10,%edx
80103463:	89 04 95 6c 48 11 80 	mov    %eax,-0x7feeb794(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010346a:	ff 45 f4             	incl   -0xc(%ebp)
8010346d:	a1 a8 48 11 80       	mov    0x801148a8,%eax
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
8010348a:	a1 94 48 11 80       	mov    0x80114894,%eax
8010348f:	89 c2                	mov    %eax,%edx
80103491:	a1 a4 48 11 80       	mov    0x801148a4,%eax
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
801034ae:	8b 15 a8 48 11 80    	mov    0x801148a8,%edx
801034b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034b7:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034b9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034c0:	eb 1a                	jmp    801034dc <write_head+0x58>
    hb->block[i] = log.lh.block[i];
801034c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034c5:	83 c0 10             	add    $0x10,%eax
801034c8:	8b 0c 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%ecx
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
801034dc:	a1 a8 48 11 80       	mov    0x801148a8,%eax
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
8010350e:	c7 05 a8 48 11 80 00 	movl   $0x0,0x801148a8
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
80103525:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
8010352c:	e8 2e 1f 00 00       	call   8010545f <acquire>
  while(1){
    if(log.committing){
80103531:	a1 a0 48 11 80       	mov    0x801148a0,%eax
80103536:	85 c0                	test   %eax,%eax
80103538:	74 16                	je     80103550 <begin_op+0x31>
      sleep(&log, &log.lock);
8010353a:	c7 44 24 04 60 48 11 	movl   $0x80114860,0x4(%esp)
80103541:	80 
80103542:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103549:	e8 12 13 00 00       	call   80104860 <sleep>
8010354e:	eb 4d                	jmp    8010359d <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103550:	8b 15 a8 48 11 80    	mov    0x801148a8,%edx
80103556:	a1 9c 48 11 80       	mov    0x8011489c,%eax
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
8010356e:	c7 44 24 04 60 48 11 	movl   $0x80114860,0x4(%esp)
80103575:	80 
80103576:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
8010357d:	e8 de 12 00 00       	call   80104860 <sleep>
80103582:	eb 19                	jmp    8010359d <begin_op+0x7e>
    } else {
      log.outstanding += 1;
80103584:	a1 9c 48 11 80       	mov    0x8011489c,%eax
80103589:	40                   	inc    %eax
8010358a:	a3 9c 48 11 80       	mov    %eax,0x8011489c
      release(&log.lock);
8010358f:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103596:	e8 2e 1f 00 00       	call   801054c9 <release>
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
801035ae:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801035b5:	e8 a5 1e 00 00       	call   8010545f <acquire>
  log.outstanding -= 1;
801035ba:	a1 9c 48 11 80       	mov    0x8011489c,%eax
801035bf:	48                   	dec    %eax
801035c0:	a3 9c 48 11 80       	mov    %eax,0x8011489c
  if(log.committing)
801035c5:	a1 a0 48 11 80       	mov    0x801148a0,%eax
801035ca:	85 c0                	test   %eax,%eax
801035cc:	74 0c                	je     801035da <end_op+0x39>
    panic("log.committing");
801035ce:	c7 04 24 ed 8e 10 80 	movl   $0x80108eed,(%esp)
801035d5:	e8 7a cf ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
801035da:	a1 9c 48 11 80       	mov    0x8011489c,%eax
801035df:	85 c0                	test   %eax,%eax
801035e1:	75 13                	jne    801035f6 <end_op+0x55>
    do_commit = 1;
801035e3:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
801035ea:	c7 05 a0 48 11 80 01 	movl   $0x1,0x801148a0
801035f1:	00 00 00 
801035f4:	eb 0c                	jmp    80103602 <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
801035f6:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801035fd:	e8 4c 13 00 00       	call   8010494e <wakeup>
  }
  release(&log.lock);
80103602:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103609:	e8 bb 1e 00 00       	call   801054c9 <release>

  if(do_commit){
8010360e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103612:	74 33                	je     80103647 <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103614:	e8 db 00 00 00       	call   801036f4 <commit>
    acquire(&log.lock);
80103619:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103620:	e8 3a 1e 00 00       	call   8010545f <acquire>
    log.committing = 0;
80103625:	c7 05 a0 48 11 80 00 	movl   $0x0,0x801148a0
8010362c:	00 00 00 
    wakeup(&log);
8010362f:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103636:	e8 13 13 00 00       	call   8010494e <wakeup>
    release(&log.lock);
8010363b:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103642:	e8 82 1e 00 00       	call   801054c9 <release>
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
8010365b:	8b 15 94 48 11 80    	mov    0x80114894,%edx
80103661:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103664:	01 d0                	add    %edx,%eax
80103666:	40                   	inc    %eax
80103667:	89 c2                	mov    %eax,%edx
80103669:	a1 a4 48 11 80       	mov    0x801148a4,%eax
8010366e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103672:	89 04 24             	mov    %eax,(%esp)
80103675:	e8 3b cb ff ff       	call   801001b5 <bread>
8010367a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010367d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103680:	83 c0 10             	add    $0x10,%eax
80103683:	8b 04 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%eax
8010368a:	89 c2                	mov    %eax,%edx
8010368c:	a1 a4 48 11 80       	mov    0x801148a4,%eax
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
801036bb:	e8 cb 20 00 00       	call   8010578b <memmove>
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
801036e4:	a1 a8 48 11 80       	mov    0x801148a8,%eax
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
801036fa:	a1 a8 48 11 80       	mov    0x801148a8,%eax
801036ff:	85 c0                	test   %eax,%eax
80103701:	7e 1e                	jle    80103721 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103703:	e8 41 ff ff ff       	call   80103649 <write_log>
    write_head();    // Write header to disk -- the real commit
80103708:	e8 77 fd ff ff       	call   80103484 <write_head>
    install_trans(); // Now install writes to home locations
8010370d:	e8 59 fc ff ff       	call   8010336b <install_trans>
    log.lh.n = 0;
80103712:	c7 05 a8 48 11 80 00 	movl   $0x0,0x801148a8
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
80103729:	a1 a8 48 11 80       	mov    0x801148a8,%eax
8010372e:	83 f8 1d             	cmp    $0x1d,%eax
80103731:	7f 10                	jg     80103743 <log_write+0x20>
80103733:	a1 a8 48 11 80       	mov    0x801148a8,%eax
80103738:	8b 15 98 48 11 80    	mov    0x80114898,%edx
8010373e:	4a                   	dec    %edx
8010373f:	39 d0                	cmp    %edx,%eax
80103741:	7c 0c                	jl     8010374f <log_write+0x2c>
    panic("too big a transaction");
80103743:	c7 04 24 fc 8e 10 80 	movl   $0x80108efc,(%esp)
8010374a:	e8 05 ce ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
8010374f:	a1 9c 48 11 80       	mov    0x8011489c,%eax
80103754:	85 c0                	test   %eax,%eax
80103756:	7f 0c                	jg     80103764 <log_write+0x41>
    panic("log_write outside of trans");
80103758:	c7 04 24 12 8f 10 80 	movl   $0x80108f12,(%esp)
8010375f:	e8 f0 cd ff ff       	call   80100554 <panic>

  acquire(&log.lock);
80103764:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
8010376b:	e8 ef 1c 00 00       	call   8010545f <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103770:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103777:	eb 1e                	jmp    80103797 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103779:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010377c:	83 c0 10             	add    $0x10,%eax
8010377f:	8b 04 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%eax
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
80103797:	a1 a8 48 11 80       	mov    0x801148a8,%eax
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
801037ad:	89 04 95 6c 48 11 80 	mov    %eax,-0x7feeb794(,%edx,4)
  if (i == log.lh.n)
801037b4:	a1 a8 48 11 80       	mov    0x801148a8,%eax
801037b9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037bc:	75 0b                	jne    801037c9 <log_write+0xa6>
    log.lh.n++;
801037be:	a1 a8 48 11 80       	mov    0x801148a8,%eax
801037c3:	40                   	inc    %eax
801037c4:	a3 a8 48 11 80       	mov    %eax,0x801148a8
  b->flags |= B_DIRTY; // prevent eviction
801037c9:	8b 45 08             	mov    0x8(%ebp),%eax
801037cc:	8b 00                	mov    (%eax),%eax
801037ce:	83 c8 04             	or     $0x4,%eax
801037d1:	89 c2                	mov    %eax,%edx
801037d3:	8b 45 08             	mov    0x8(%ebp),%eax
801037d6:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801037d8:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801037df:	e8 e5 1c 00 00       	call   801054c9 <release>
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
80103813:	c7 04 24 48 61 12 80 	movl   $0x80126148,(%esp)
8010381a:	e8 0d f3 ff ff       	call   80102b2c <kinit1>
  kvmalloc();      // kernel page table
8010381f:	e8 43 4c 00 00       	call   80108467 <kvmalloc>
  mpinit();        // detect other processors
80103824:	e8 c4 03 00 00       	call   80103bed <mpinit>
  lapicinit();     // interrupt controller
80103829:	e8 4e f6 ff ff       	call   80102e7c <lapicinit>
  seginit();       // segment descriptors
8010382e:	e8 1c 47 00 00       	call   80107f4f <seginit>
  picinit();       // disable pic
80103833:	e8 04 05 00 00       	call   80103d3c <picinit>
  ioapicinit();    // another interrupt controller
80103838:	e8 0c f2 ff ff       	call   80102a49 <ioapicinit>
  consoleinit();   // console hardware
8010383d:	e8 75 d3 ff ff       	call   80100bb7 <consoleinit>
  uartinit();      // serial port
80103842:	e8 94 3a 00 00       	call   801072db <uartinit>
  cinit();         // container table
80103847:	e8 df 13 00 00       	call   80104c2b <cinit>
  tvinit();        // trap vectors
8010384c:	e8 57 36 00 00       	call   80106ea8 <tvinit>
  binit();         // buffer cache
80103851:	e8 de c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103856:	e8 ed d7 ff ff       	call   80101048 <fileinit>
  ideinit();       // disk 
8010385b:	e8 f5 ed ff ff       	call   80102655 <ideinit>
  startothers();   // start other processors
80103860:	e8 83 00 00 00       	call   801038e8 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103865:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
8010386c:	8e 
8010386d:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80103874:	e8 eb f2 ff ff       	call   80102b64 <kinit2>
  userinit();      // first user process
80103879:	e8 e9 14 00 00       	call   80104d67 <userinit>
  mpmain();        // finish this processor's setup
8010387e:	e8 1a 00 00 00       	call   8010389d <mpmain>

80103883 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103883:	55                   	push   %ebp
80103884:	89 e5                	mov    %esp,%ebp
80103886:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103889:	e8 f0 4b 00 00       	call   8010847e <switchkvm>
  seginit();
8010388e:	e8 bc 46 00 00       	call   80107f4f <seginit>
  lapicinit();
80103893:	e8 e4 f5 ff ff       	call   80102e7c <lapicinit>
  mpmain();
80103898:	e8 00 00 00 00       	call   8010389d <mpmain>

8010389d <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010389d:	55                   	push   %ebp
8010389e:	89 e5                	mov    %esp,%ebp
801038a0:	53                   	push   %ebx
801038a1:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801038a4:	e8 b9 12 00 00       	call   80104b62 <cpuid>
801038a9:	89 c3                	mov    %eax,%ebx
801038ab:	e8 b2 12 00 00       	call   80104b62 <cpuid>
801038b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801038b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801038b8:	c7 04 24 2d 8f 10 80 	movl   $0x80108f2d,(%esp)
801038bf:	e8 fd ca ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
801038c4:	e8 3c 37 00 00       	call   80107005 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801038c9:	e8 d9 12 00 00       	call   80104ba7 <mycpu>
801038ce:	05 a0 00 00 00       	add    $0xa0,%eax
801038d3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801038da:	00 
801038db:	89 04 24             	mov    %eax,(%esp)
801038de:	e8 05 ff ff ff       	call   801037e8 <xchg>
  scheduler();     // start running processes
801038e3:	e8 6e 16 00 00       	call   80104f56 <scheduler>

801038e8 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801038e8:	55                   	push   %ebp
801038e9:	89 e5                	mov    %esp,%ebp
801038eb:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
801038ee:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801038f5:	b8 8a 00 00 00       	mov    $0x8a,%eax
801038fa:	89 44 24 08          	mov    %eax,0x8(%esp)
801038fe:	c7 44 24 04 2c c5 10 	movl   $0x8010c52c,0x4(%esp)
80103905:	80 
80103906:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103909:	89 04 24             	mov    %eax,(%esp)
8010390c:	e8 7a 1e 00 00       	call   8010578b <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103911:	c7 45 f4 60 49 11 80 	movl   $0x80114960,-0xc(%ebp)
80103918:	eb 75                	jmp    8010398f <startothers+0xa7>
    if(c == mycpu())  // We've started already.
8010391a:	e8 88 12 00 00       	call   80104ba7 <mycpu>
8010391f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103922:	75 02                	jne    80103926 <startothers+0x3e>
      continue;
80103924:	eb 62                	jmp    80103988 <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103926:	e8 2c f3 ff ff       	call   80102c57 <kalloc>
8010392b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010392e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103931:	83 e8 04             	sub    $0x4,%eax
80103934:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103937:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010393d:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
8010393f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103942:	83 e8 08             	sub    $0x8,%eax
80103945:	c7 00 83 38 10 80    	movl   $0x80103883,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
8010394b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010394e:	8d 50 f4             	lea    -0xc(%eax),%edx
80103951:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103956:	05 00 00 00 80       	add    $0x80000000,%eax
8010395b:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
8010395d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103960:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103966:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103969:	8a 00                	mov    (%eax),%al
8010396b:	0f b6 c0             	movzbl %al,%eax
8010396e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103972:	89 04 24             	mov    %eax,(%esp)
80103975:	e8 a7 f6 ff ff       	call   80103021 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
8010397a:	90                   	nop
8010397b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010397e:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103984:	85 c0                	test   %eax,%eax
80103986:	74 f3                	je     8010397b <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103988:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
8010398f:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80103994:	89 c2                	mov    %eax,%edx
80103996:	89 d0                	mov    %edx,%eax
80103998:	c1 e0 02             	shl    $0x2,%eax
8010399b:	01 d0                	add    %edx,%eax
8010399d:	01 c0                	add    %eax,%eax
8010399f:	01 d0                	add    %edx,%eax
801039a1:	c1 e0 04             	shl    $0x4,%eax
801039a4:	05 60 49 11 80       	add    $0x80114960,%eax
801039a9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039ac:	0f 87 68 ff ff ff    	ja     8010391a <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801039b2:	c9                   	leave  
801039b3:	c3                   	ret    

801039b4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801039b4:	55                   	push   %ebp
801039b5:	89 e5                	mov    %esp,%ebp
801039b7:	83 ec 14             	sub    $0x14,%esp
801039ba:	8b 45 08             	mov    0x8(%ebp),%eax
801039bd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801039c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801039c4:	89 c2                	mov    %eax,%edx
801039c6:	ec                   	in     (%dx),%al
801039c7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801039ca:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801039cd:	c9                   	leave  
801039ce:	c3                   	ret    

801039cf <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801039cf:	55                   	push   %ebp
801039d0:	89 e5                	mov    %esp,%ebp
801039d2:	83 ec 08             	sub    $0x8,%esp
801039d5:	8b 45 08             	mov    0x8(%ebp),%eax
801039d8:	8b 55 0c             	mov    0xc(%ebp),%edx
801039db:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801039df:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801039e2:	8a 45 f8             	mov    -0x8(%ebp),%al
801039e5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801039e8:	ee                   	out    %al,(%dx)
}
801039e9:	c9                   	leave  
801039ea:	c3                   	ret    

801039eb <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
801039eb:	55                   	push   %ebp
801039ec:	89 e5                	mov    %esp,%ebp
801039ee:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
801039f1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
801039f8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801039ff:	eb 13                	jmp    80103a14 <sum+0x29>
    sum += addr[i];
80103a01:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a04:	8b 45 08             	mov    0x8(%ebp),%eax
80103a07:	01 d0                	add    %edx,%eax
80103a09:	8a 00                	mov    (%eax),%al
80103a0b:	0f b6 c0             	movzbl %al,%eax
80103a0e:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103a11:	ff 45 fc             	incl   -0x4(%ebp)
80103a14:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a17:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a1a:	7c e5                	jl     80103a01 <sum+0x16>
    sum += addr[i];
  return sum;
80103a1c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a1f:	c9                   	leave  
80103a20:	c3                   	ret    

80103a21 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103a21:	55                   	push   %ebp
80103a22:	89 e5                	mov    %esp,%ebp
80103a24:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103a27:	8b 45 08             	mov    0x8(%ebp),%eax
80103a2a:	05 00 00 00 80       	add    $0x80000000,%eax
80103a2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103a32:	8b 55 0c             	mov    0xc(%ebp),%edx
80103a35:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a38:	01 d0                	add    %edx,%eax
80103a3a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103a3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103a43:	eb 3f                	jmp    80103a84 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103a45:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103a4c:	00 
80103a4d:	c7 44 24 04 44 8f 10 	movl   $0x80108f44,0x4(%esp)
80103a54:	80 
80103a55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a58:	89 04 24             	mov    %eax,(%esp)
80103a5b:	e8 d9 1c 00 00       	call   80105739 <memcmp>
80103a60:	85 c0                	test   %eax,%eax
80103a62:	75 1c                	jne    80103a80 <mpsearch1+0x5f>
80103a64:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103a6b:	00 
80103a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a6f:	89 04 24             	mov    %eax,(%esp)
80103a72:	e8 74 ff ff ff       	call   801039eb <sum>
80103a77:	84 c0                	test   %al,%al
80103a79:	75 05                	jne    80103a80 <mpsearch1+0x5f>
      return (struct mp*)p;
80103a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7e:	eb 11                	jmp    80103a91 <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103a80:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103a84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a87:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103a8a:	72 b9                	jb     80103a45 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103a8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103a91:	c9                   	leave  
80103a92:	c3                   	ret    

80103a93 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103a93:	55                   	push   %ebp
80103a94:	89 e5                	mov    %esp,%ebp
80103a96:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103a99:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103aa0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aa3:	83 c0 0f             	add    $0xf,%eax
80103aa6:	8a 00                	mov    (%eax),%al
80103aa8:	0f b6 c0             	movzbl %al,%eax
80103aab:	c1 e0 08             	shl    $0x8,%eax
80103aae:	89 c2                	mov    %eax,%edx
80103ab0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ab3:	83 c0 0e             	add    $0xe,%eax
80103ab6:	8a 00                	mov    (%eax),%al
80103ab8:	0f b6 c0             	movzbl %al,%eax
80103abb:	09 d0                	or     %edx,%eax
80103abd:	c1 e0 04             	shl    $0x4,%eax
80103ac0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103ac3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103ac7:	74 21                	je     80103aea <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103ac9:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103ad0:	00 
80103ad1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ad4:	89 04 24             	mov    %eax,(%esp)
80103ad7:	e8 45 ff ff ff       	call   80103a21 <mpsearch1>
80103adc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103adf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103ae3:	74 4e                	je     80103b33 <mpsearch+0xa0>
      return mp;
80103ae5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ae8:	eb 5d                	jmp    80103b47 <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aed:	83 c0 14             	add    $0x14,%eax
80103af0:	8a 00                	mov    (%eax),%al
80103af2:	0f b6 c0             	movzbl %al,%eax
80103af5:	c1 e0 08             	shl    $0x8,%eax
80103af8:	89 c2                	mov    %eax,%edx
80103afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afd:	83 c0 13             	add    $0x13,%eax
80103b00:	8a 00                	mov    (%eax),%al
80103b02:	0f b6 c0             	movzbl %al,%eax
80103b05:	09 d0                	or     %edx,%eax
80103b07:	c1 e0 0a             	shl    $0xa,%eax
80103b0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b10:	2d 00 04 00 00       	sub    $0x400,%eax
80103b15:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103b1c:	00 
80103b1d:	89 04 24             	mov    %eax,(%esp)
80103b20:	e8 fc fe ff ff       	call   80103a21 <mpsearch1>
80103b25:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b28:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b2c:	74 05                	je     80103b33 <mpsearch+0xa0>
      return mp;
80103b2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b31:	eb 14                	jmp    80103b47 <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103b33:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103b3a:	00 
80103b3b:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103b42:	e8 da fe ff ff       	call   80103a21 <mpsearch1>
}
80103b47:	c9                   	leave  
80103b48:	c3                   	ret    

80103b49 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103b49:	55                   	push   %ebp
80103b4a:	89 e5                	mov    %esp,%ebp
80103b4c:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103b4f:	e8 3f ff ff ff       	call   80103a93 <mpsearch>
80103b54:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103b5b:	74 0a                	je     80103b67 <mpconfig+0x1e>
80103b5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b60:	8b 40 04             	mov    0x4(%eax),%eax
80103b63:	85 c0                	test   %eax,%eax
80103b65:	75 07                	jne    80103b6e <mpconfig+0x25>
    return 0;
80103b67:	b8 00 00 00 00       	mov    $0x0,%eax
80103b6c:	eb 7d                	jmp    80103beb <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b71:	8b 40 04             	mov    0x4(%eax),%eax
80103b74:	05 00 00 00 80       	add    $0x80000000,%eax
80103b79:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103b7c:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b83:	00 
80103b84:	c7 44 24 04 49 8f 10 	movl   $0x80108f49,0x4(%esp)
80103b8b:	80 
80103b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b8f:	89 04 24             	mov    %eax,(%esp)
80103b92:	e8 a2 1b 00 00       	call   80105739 <memcmp>
80103b97:	85 c0                	test   %eax,%eax
80103b99:	74 07                	je     80103ba2 <mpconfig+0x59>
    return 0;
80103b9b:	b8 00 00 00 00       	mov    $0x0,%eax
80103ba0:	eb 49                	jmp    80103beb <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103ba2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ba5:	8a 40 06             	mov    0x6(%eax),%al
80103ba8:	3c 01                	cmp    $0x1,%al
80103baa:	74 11                	je     80103bbd <mpconfig+0x74>
80103bac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103baf:	8a 40 06             	mov    0x6(%eax),%al
80103bb2:	3c 04                	cmp    $0x4,%al
80103bb4:	74 07                	je     80103bbd <mpconfig+0x74>
    return 0;
80103bb6:	b8 00 00 00 00       	mov    $0x0,%eax
80103bbb:	eb 2e                	jmp    80103beb <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103bbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bc0:	8b 40 04             	mov    0x4(%eax),%eax
80103bc3:	0f b7 c0             	movzwl %ax,%eax
80103bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
80103bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103bcd:	89 04 24             	mov    %eax,(%esp)
80103bd0:	e8 16 fe ff ff       	call   801039eb <sum>
80103bd5:	84 c0                	test   %al,%al
80103bd7:	74 07                	je     80103be0 <mpconfig+0x97>
    return 0;
80103bd9:	b8 00 00 00 00       	mov    $0x0,%eax
80103bde:	eb 0b                	jmp    80103beb <mpconfig+0xa2>
  *pmp = mp;
80103be0:	8b 45 08             	mov    0x8(%ebp),%eax
80103be3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103be6:	89 10                	mov    %edx,(%eax)
  return conf;
80103be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103beb:	c9                   	leave  
80103bec:	c3                   	ret    

80103bed <mpinit>:

void
mpinit(void)
{
80103bed:	55                   	push   %ebp
80103bee:	89 e5                	mov    %esp,%ebp
80103bf0:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103bf3:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103bf6:	89 04 24             	mov    %eax,(%esp)
80103bf9:	e8 4b ff ff ff       	call   80103b49 <mpconfig>
80103bfe:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c01:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c05:	75 0c                	jne    80103c13 <mpinit+0x26>
    panic("Expect to run on an SMP");
80103c07:	c7 04 24 4e 8f 10 80 	movl   $0x80108f4e,(%esp)
80103c0e:	e8 41 c9 ff ff       	call   80100554 <panic>
  ismp = 1;
80103c13:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103c1a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c1d:	8b 40 24             	mov    0x24(%eax),%eax
80103c20:	a3 5c 48 11 80       	mov    %eax,0x8011485c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103c25:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c28:	83 c0 2c             	add    $0x2c,%eax
80103c2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c31:	8b 40 04             	mov    0x4(%eax),%eax
80103c34:	0f b7 d0             	movzwl %ax,%edx
80103c37:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c3a:	01 d0                	add    %edx,%eax
80103c3c:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103c3f:	eb 7d                	jmp    80103cbe <mpinit+0xd1>
    switch(*p){
80103c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c44:	8a 00                	mov    (%eax),%al
80103c46:	0f b6 c0             	movzbl %al,%eax
80103c49:	83 f8 04             	cmp    $0x4,%eax
80103c4c:	77 68                	ja     80103cb6 <mpinit+0xc9>
80103c4e:	8b 04 85 88 8f 10 80 	mov    -0x7fef7078(,%eax,4),%eax
80103c55:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c5a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103c5d:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80103c62:	83 f8 07             	cmp    $0x7,%eax
80103c65:	7f 2c                	jg     80103c93 <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103c67:	8b 15 e0 4e 11 80    	mov    0x80114ee0,%edx
80103c6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103c70:	8a 48 01             	mov    0x1(%eax),%cl
80103c73:	89 d0                	mov    %edx,%eax
80103c75:	c1 e0 02             	shl    $0x2,%eax
80103c78:	01 d0                	add    %edx,%eax
80103c7a:	01 c0                	add    %eax,%eax
80103c7c:	01 d0                	add    %edx,%eax
80103c7e:	c1 e0 04             	shl    $0x4,%eax
80103c81:	05 60 49 11 80       	add    $0x80114960,%eax
80103c86:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103c88:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80103c8d:	40                   	inc    %eax
80103c8e:	a3 e0 4e 11 80       	mov    %eax,0x80114ee0
      }
      p += sizeof(struct mpproc);
80103c93:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103c97:	eb 25                	jmp    80103cbe <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c9c:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103c9f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103ca2:	8a 40 01             	mov    0x1(%eax),%al
80103ca5:	a2 40 49 11 80       	mov    %al,0x80114940
      p += sizeof(struct mpioapic);
80103caa:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cae:	eb 0e                	jmp    80103cbe <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103cb0:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103cb4:	eb 08                	jmp    80103cbe <mpinit+0xd1>
    default:
      ismp = 0;
80103cb6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103cbd:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc1:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103cc4:	0f 82 77 ff ff ff    	jb     80103c41 <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103cca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103cce:	75 0c                	jne    80103cdc <mpinit+0xef>
    panic("Didn't find a suitable machine");
80103cd0:	c7 04 24 68 8f 10 80 	movl   $0x80108f68,(%esp)
80103cd7:	e8 78 c8 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80103cdc:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103cdf:	8a 40 0c             	mov    0xc(%eax),%al
80103ce2:	84 c0                	test   %al,%al
80103ce4:	74 36                	je     80103d1c <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103ce6:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103ced:	00 
80103cee:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103cf5:	e8 d5 fc ff ff       	call   801039cf <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103cfa:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d01:	e8 ae fc ff ff       	call   801039b4 <inb>
80103d06:	83 c8 01             	or     $0x1,%eax
80103d09:	0f b6 c0             	movzbl %al,%eax
80103d0c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d10:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103d17:	e8 b3 fc ff ff       	call   801039cf <outb>
  }
}
80103d1c:	c9                   	leave  
80103d1d:	c3                   	ret    
	...

80103d20 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103d20:	55                   	push   %ebp
80103d21:	89 e5                	mov    %esp,%ebp
80103d23:	83 ec 08             	sub    $0x8,%esp
80103d26:	8b 45 08             	mov    0x8(%ebp),%eax
80103d29:	8b 55 0c             	mov    0xc(%ebp),%edx
80103d2c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103d30:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103d33:	8a 45 f8             	mov    -0x8(%ebp),%al
80103d36:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103d39:	ee                   	out    %al,(%dx)
}
80103d3a:	c9                   	leave  
80103d3b:	c3                   	ret    

80103d3c <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103d3c:	55                   	push   %ebp
80103d3d:	89 e5                	mov    %esp,%ebp
80103d3f:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103d42:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103d49:	00 
80103d4a:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103d51:	e8 ca ff ff ff       	call   80103d20 <outb>
  outb(IO_PIC2+1, 0xFF);
80103d56:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103d5d:	00 
80103d5e:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103d65:	e8 b6 ff ff ff       	call   80103d20 <outb>
}
80103d6a:	c9                   	leave  
80103d6b:	c3                   	ret    

80103d6c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103d6c:	55                   	push   %ebp
80103d6d:	89 e5                	mov    %esp,%ebp
80103d6f:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103d72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103d79:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d7c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103d82:	8b 45 0c             	mov    0xc(%ebp),%eax
80103d85:	8b 10                	mov    (%eax),%edx
80103d87:	8b 45 08             	mov    0x8(%ebp),%eax
80103d8a:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103d8c:	e8 d3 d2 ff ff       	call   80101064 <filealloc>
80103d91:	8b 55 08             	mov    0x8(%ebp),%edx
80103d94:	89 02                	mov    %eax,(%edx)
80103d96:	8b 45 08             	mov    0x8(%ebp),%eax
80103d99:	8b 00                	mov    (%eax),%eax
80103d9b:	85 c0                	test   %eax,%eax
80103d9d:	0f 84 c8 00 00 00    	je     80103e6b <pipealloc+0xff>
80103da3:	e8 bc d2 ff ff       	call   80101064 <filealloc>
80103da8:	8b 55 0c             	mov    0xc(%ebp),%edx
80103dab:	89 02                	mov    %eax,(%edx)
80103dad:	8b 45 0c             	mov    0xc(%ebp),%eax
80103db0:	8b 00                	mov    (%eax),%eax
80103db2:	85 c0                	test   %eax,%eax
80103db4:	0f 84 b1 00 00 00    	je     80103e6b <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103dba:	e8 98 ee ff ff       	call   80102c57 <kalloc>
80103dbf:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103dc2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103dc6:	75 05                	jne    80103dcd <pipealloc+0x61>
    goto bad;
80103dc8:	e9 9e 00 00 00       	jmp    80103e6b <pipealloc+0xff>
  p->readopen = 1;
80103dcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dd0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103dd7:	00 00 00 
  p->writeopen = 1;
80103dda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ddd:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103de4:	00 00 00 
  p->nwrite = 0;
80103de7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dea:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103df1:	00 00 00 
  p->nread = 0;
80103df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103df7:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103dfe:	00 00 00 
  initlock(&p->lock, "pipe");
80103e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e04:	c7 44 24 04 9c 8f 10 	movl   $0x80108f9c,0x4(%esp)
80103e0b:	80 
80103e0c:	89 04 24             	mov    %eax,(%esp)
80103e0f:	e8 2a 16 00 00       	call   8010543e <initlock>
  (*f0)->type = FD_PIPE;
80103e14:	8b 45 08             	mov    0x8(%ebp),%eax
80103e17:	8b 00                	mov    (%eax),%eax
80103e19:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103e1f:	8b 45 08             	mov    0x8(%ebp),%eax
80103e22:	8b 00                	mov    (%eax),%eax
80103e24:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103e28:	8b 45 08             	mov    0x8(%ebp),%eax
80103e2b:	8b 00                	mov    (%eax),%eax
80103e2d:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103e31:	8b 45 08             	mov    0x8(%ebp),%eax
80103e34:	8b 00                	mov    (%eax),%eax
80103e36:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e39:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103e3c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e3f:	8b 00                	mov    (%eax),%eax
80103e41:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103e47:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e4a:	8b 00                	mov    (%eax),%eax
80103e4c:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103e50:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e53:	8b 00                	mov    (%eax),%eax
80103e55:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103e59:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e5c:	8b 00                	mov    (%eax),%eax
80103e5e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103e61:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103e64:	b8 00 00 00 00       	mov    $0x0,%eax
80103e69:	eb 42                	jmp    80103ead <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103e6b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103e6f:	74 0b                	je     80103e7c <pipealloc+0x110>
    kfree((char*)p);
80103e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e74:	89 04 24             	mov    %eax,(%esp)
80103e77:	e8 45 ed ff ff       	call   80102bc1 <kfree>
  if(*f0)
80103e7c:	8b 45 08             	mov    0x8(%ebp),%eax
80103e7f:	8b 00                	mov    (%eax),%eax
80103e81:	85 c0                	test   %eax,%eax
80103e83:	74 0d                	je     80103e92 <pipealloc+0x126>
    fileclose(*f0);
80103e85:	8b 45 08             	mov    0x8(%ebp),%eax
80103e88:	8b 00                	mov    (%eax),%eax
80103e8a:	89 04 24             	mov    %eax,(%esp)
80103e8d:	e8 7a d2 ff ff       	call   8010110c <fileclose>
  if(*f1)
80103e92:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e95:	8b 00                	mov    (%eax),%eax
80103e97:	85 c0                	test   %eax,%eax
80103e99:	74 0d                	je     80103ea8 <pipealloc+0x13c>
    fileclose(*f1);
80103e9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e9e:	8b 00                	mov    (%eax),%eax
80103ea0:	89 04 24             	mov    %eax,(%esp)
80103ea3:	e8 64 d2 ff ff       	call   8010110c <fileclose>
  return -1;
80103ea8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103ead:	c9                   	leave  
80103eae:	c3                   	ret    

80103eaf <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103eaf:	55                   	push   %ebp
80103eb0:	89 e5                	mov    %esp,%ebp
80103eb2:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103eb5:	8b 45 08             	mov    0x8(%ebp),%eax
80103eb8:	89 04 24             	mov    %eax,(%esp)
80103ebb:	e8 9f 15 00 00       	call   8010545f <acquire>
  if(writable){
80103ec0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103ec4:	74 1f                	je     80103ee5 <pipeclose+0x36>
    p->writeopen = 0;
80103ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec9:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80103ed0:	00 00 00 
    wakeup(&p->nread);
80103ed3:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed6:	05 34 02 00 00       	add    $0x234,%eax
80103edb:	89 04 24             	mov    %eax,(%esp)
80103ede:	e8 6b 0a 00 00       	call   8010494e <wakeup>
80103ee3:	eb 1d                	jmp    80103f02 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80103ee5:	8b 45 08             	mov    0x8(%ebp),%eax
80103ee8:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103eef:	00 00 00 
    wakeup(&p->nwrite);
80103ef2:	8b 45 08             	mov    0x8(%ebp),%eax
80103ef5:	05 38 02 00 00       	add    $0x238,%eax
80103efa:	89 04 24             	mov    %eax,(%esp)
80103efd:	e8 4c 0a 00 00       	call   8010494e <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103f02:	8b 45 08             	mov    0x8(%ebp),%eax
80103f05:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103f0b:	85 c0                	test   %eax,%eax
80103f0d:	75 25                	jne    80103f34 <pipeclose+0x85>
80103f0f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f12:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103f18:	85 c0                	test   %eax,%eax
80103f1a:	75 18                	jne    80103f34 <pipeclose+0x85>
    release(&p->lock);
80103f1c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f1f:	89 04 24             	mov    %eax,(%esp)
80103f22:	e8 a2 15 00 00       	call   801054c9 <release>
    kfree((char*)p);
80103f27:	8b 45 08             	mov    0x8(%ebp),%eax
80103f2a:	89 04 24             	mov    %eax,(%esp)
80103f2d:	e8 8f ec ff ff       	call   80102bc1 <kfree>
80103f32:	eb 0b                	jmp    80103f3f <pipeclose+0x90>
  } else
    release(&p->lock);
80103f34:	8b 45 08             	mov    0x8(%ebp),%eax
80103f37:	89 04 24             	mov    %eax,(%esp)
80103f3a:	e8 8a 15 00 00       	call   801054c9 <release>
}
80103f3f:	c9                   	leave  
80103f40:	c3                   	ret    

80103f41 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103f41:	55                   	push   %ebp
80103f42:	89 e5                	mov    %esp,%ebp
80103f44:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80103f47:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4a:	89 04 24             	mov    %eax,(%esp)
80103f4d:	e8 0d 15 00 00       	call   8010545f <acquire>
  for(i = 0; i < n; i++){
80103f52:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103f59:	e9 a3 00 00 00       	jmp    80104001 <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103f5e:	eb 56                	jmp    80103fb6 <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
80103f60:	8b 45 08             	mov    0x8(%ebp),%eax
80103f63:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103f69:	85 c0                	test   %eax,%eax
80103f6b:	74 0c                	je     80103f79 <pipewrite+0x38>
80103f6d:	e8 aa 01 00 00       	call   8010411c <myproc>
80103f72:	8b 40 24             	mov    0x24(%eax),%eax
80103f75:	85 c0                	test   %eax,%eax
80103f77:	74 15                	je     80103f8e <pipewrite+0x4d>
        release(&p->lock);
80103f79:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7c:	89 04 24             	mov    %eax,(%esp)
80103f7f:	e8 45 15 00 00       	call   801054c9 <release>
        return -1;
80103f84:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f89:	e9 9d 00 00 00       	jmp    8010402b <pipewrite+0xea>
      }
      wakeup(&p->nread);
80103f8e:	8b 45 08             	mov    0x8(%ebp),%eax
80103f91:	05 34 02 00 00       	add    $0x234,%eax
80103f96:	89 04 24             	mov    %eax,(%esp)
80103f99:	e8 b0 09 00 00       	call   8010494e <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103f9e:	8b 45 08             	mov    0x8(%ebp),%eax
80103fa1:	8b 55 08             	mov    0x8(%ebp),%edx
80103fa4:	81 c2 38 02 00 00    	add    $0x238,%edx
80103faa:	89 44 24 04          	mov    %eax,0x4(%esp)
80103fae:	89 14 24             	mov    %edx,(%esp)
80103fb1:	e8 aa 08 00 00       	call   80104860 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103fb6:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb9:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80103fbf:	8b 45 08             	mov    0x8(%ebp),%eax
80103fc2:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80103fc8:	05 00 02 00 00       	add    $0x200,%eax
80103fcd:	39 c2                	cmp    %eax,%edx
80103fcf:	74 8f                	je     80103f60 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103fd1:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd4:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103fda:	8d 48 01             	lea    0x1(%eax),%ecx
80103fdd:	8b 55 08             	mov    0x8(%ebp),%edx
80103fe0:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103fe6:	25 ff 01 00 00       	and    $0x1ff,%eax
80103feb:	89 c1                	mov    %eax,%ecx
80103fed:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ff0:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ff3:	01 d0                	add    %edx,%eax
80103ff5:	8a 10                	mov    (%eax),%dl
80103ff7:	8b 45 08             	mov    0x8(%ebp),%eax
80103ffa:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80103ffe:	ff 45 f4             	incl   -0xc(%ebp)
80104001:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104004:	3b 45 10             	cmp    0x10(%ebp),%eax
80104007:	0f 8c 51 ff ff ff    	jl     80103f5e <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010400d:	8b 45 08             	mov    0x8(%ebp),%eax
80104010:	05 34 02 00 00       	add    $0x234,%eax
80104015:	89 04 24             	mov    %eax,(%esp)
80104018:	e8 31 09 00 00       	call   8010494e <wakeup>
  release(&p->lock);
8010401d:	8b 45 08             	mov    0x8(%ebp),%eax
80104020:	89 04 24             	mov    %eax,(%esp)
80104023:	e8 a1 14 00 00       	call   801054c9 <release>
  return n;
80104028:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010402b:	c9                   	leave  
8010402c:	c3                   	ret    

8010402d <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010402d:	55                   	push   %ebp
8010402e:	89 e5                	mov    %esp,%ebp
80104030:	53                   	push   %ebx
80104031:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104034:	8b 45 08             	mov    0x8(%ebp),%eax
80104037:	89 04 24             	mov    %eax,(%esp)
8010403a:	e8 20 14 00 00       	call   8010545f <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010403f:	eb 39                	jmp    8010407a <piperead+0x4d>
    if(myproc()->killed){
80104041:	e8 d6 00 00 00       	call   8010411c <myproc>
80104046:	8b 40 24             	mov    0x24(%eax),%eax
80104049:	85 c0                	test   %eax,%eax
8010404b:	74 15                	je     80104062 <piperead+0x35>
      release(&p->lock);
8010404d:	8b 45 08             	mov    0x8(%ebp),%eax
80104050:	89 04 24             	mov    %eax,(%esp)
80104053:	e8 71 14 00 00       	call   801054c9 <release>
      return -1;
80104058:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010405d:	e9 b3 00 00 00       	jmp    80104115 <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104062:	8b 45 08             	mov    0x8(%ebp),%eax
80104065:	8b 55 08             	mov    0x8(%ebp),%edx
80104068:	81 c2 34 02 00 00    	add    $0x234,%edx
8010406e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104072:	89 14 24             	mov    %edx,(%esp)
80104075:	e8 e6 07 00 00       	call   80104860 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010407a:	8b 45 08             	mov    0x8(%ebp),%eax
8010407d:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104083:	8b 45 08             	mov    0x8(%ebp),%eax
80104086:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010408c:	39 c2                	cmp    %eax,%edx
8010408e:	75 0d                	jne    8010409d <piperead+0x70>
80104090:	8b 45 08             	mov    0x8(%ebp),%eax
80104093:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104099:	85 c0                	test   %eax,%eax
8010409b:	75 a4                	jne    80104041 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010409d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801040a4:	eb 49                	jmp    801040ef <piperead+0xc2>
    if(p->nread == p->nwrite)
801040a6:	8b 45 08             	mov    0x8(%ebp),%eax
801040a9:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801040af:	8b 45 08             	mov    0x8(%ebp),%eax
801040b2:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801040b8:	39 c2                	cmp    %eax,%edx
801040ba:	75 02                	jne    801040be <piperead+0x91>
      break;
801040bc:	eb 39                	jmp    801040f7 <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
801040be:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801040c4:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801040c7:	8b 45 08             	mov    0x8(%ebp),%eax
801040ca:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801040d0:	8d 48 01             	lea    0x1(%eax),%ecx
801040d3:	8b 55 08             	mov    0x8(%ebp),%edx
801040d6:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801040dc:	25 ff 01 00 00       	and    $0x1ff,%eax
801040e1:	89 c2                	mov    %eax,%edx
801040e3:	8b 45 08             	mov    0x8(%ebp),%eax
801040e6:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
801040ea:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801040ec:	ff 45 f4             	incl   -0xc(%ebp)
801040ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040f2:	3b 45 10             	cmp    0x10(%ebp),%eax
801040f5:	7c af                	jl     801040a6 <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801040f7:	8b 45 08             	mov    0x8(%ebp),%eax
801040fa:	05 38 02 00 00       	add    $0x238,%eax
801040ff:	89 04 24             	mov    %eax,(%esp)
80104102:	e8 47 08 00 00       	call   8010494e <wakeup>
  release(&p->lock);
80104107:	8b 45 08             	mov    0x8(%ebp),%eax
8010410a:	89 04 24             	mov    %eax,(%esp)
8010410d:	e8 b7 13 00 00       	call   801054c9 <release>
  return i;
80104112:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104115:	83 c4 24             	add    $0x24,%esp
80104118:	5b                   	pop    %ebx
80104119:	5d                   	pop    %ebp
8010411a:	c3                   	ret    
	...

8010411c <myproc>:
static void wakeup1(void *chan);

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
8010411c:	55                   	push   %ebp
8010411d:	89 e5                	mov    %esp,%ebp
8010411f:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104122:	e8 97 14 00 00       	call   801055be <pushcli>
  c = mycpu();
80104127:	e8 7b 0a 00 00       	call   80104ba7 <mycpu>
8010412c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
8010412f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104132:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104138:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
8010413b:	e8 c8 14 00 00       	call   80105608 <popcli>
  return p;
80104140:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104143:	c9                   	leave  
80104144:	c3                   	ret    

80104145 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(struct cont *parentcont)
{
80104145:	55                   	push   %ebp
80104146:	89 e5                	mov    %esp,%ebp
80104148:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;
  struct proc *ptable;
  int nproc;

  acquirectable();
8010414b:	e8 fc 0a 00 00       	call   80104c4c <acquirectable>

  ptable = parentcont->ptable;
80104150:	8b 45 08             	mov    0x8(%ebp),%eax
80104153:	8b 40 28             	mov    0x28(%eax),%eax
80104156:	89 45 f0             	mov    %eax,-0x10(%ebp)
  nproc = parentcont->mproc;
80104159:	8b 45 08             	mov    0x8(%ebp),%eax
8010415c:	8b 40 08             	mov    0x8(%eax),%eax
8010415f:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for(p = ptable; p < &ptable[nproc]; p++) 
80104162:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104165:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104168:	eb 4c                	jmp    801041b6 <allocproc+0x71>
    if(p->state == UNUSED)
8010416a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010416d:	8b 40 0c             	mov    0xc(%eax),%eax
80104170:	85 c0                	test   %eax,%eax
80104172:	75 3b                	jne    801041af <allocproc+0x6a>
      goto found;  
80104174:	90                   	nop

  releasectable();
  return 0;

found:
  p->state = EMBRYO;
80104175:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104178:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;  
8010417f:	a1 00 c0 10 80       	mov    0x8010c000,%eax
80104184:	8d 50 01             	lea    0x1(%eax),%edx
80104187:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
8010418d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104190:	89 42 10             	mov    %eax,0x10(%edx)

  releasectable();  
80104193:	e8 c8 0a 00 00       	call   80104c60 <releasectable>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104198:	e8 ba ea ff ff       	call   80102c57 <kalloc>
8010419d:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041a0:	89 42 08             	mov    %eax,0x8(%edx)
801041a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041a6:	8b 40 08             	mov    0x8(%eax),%eax
801041a9:	85 c0                	test   %eax,%eax
801041ab:	75 43                	jne    801041f0 <allocproc+0xab>
801041ad:	eb 2d                	jmp    801041dc <allocproc+0x97>
  acquirectable();

  ptable = parentcont->ptable;
  nproc = parentcont->mproc;

  for(p = ptable; p < &ptable[nproc]; p++) 
801041af:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801041b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801041b9:	c1 e0 02             	shl    $0x2,%eax
801041bc:	89 c2                	mov    %eax,%edx
801041be:	c1 e2 05             	shl    $0x5,%edx
801041c1:	01 c2                	add    %eax,%edx
801041c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801041c6:	01 d0                	add    %edx,%eax
801041c8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801041cb:	77 9d                	ja     8010416a <allocproc+0x25>
    if(p->state == UNUSED)
      goto found;  

  releasectable();
801041cd:	e8 8e 0a 00 00       	call   80104c60 <releasectable>
  return 0;
801041d2:	b8 00 00 00 00       	mov    $0x0,%eax
801041d7:	e9 94 00 00 00       	jmp    80104270 <allocproc+0x12b>

  releasectable();  

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
801041dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041df:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801041e6:	b8 00 00 00 00       	mov    $0x0,%eax
801041eb:	e9 80 00 00 00       	jmp    80104270 <allocproc+0x12b>
  }
  sp = p->kstack + KSTACKSIZE;
801041f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f3:	8b 40 08             	mov    0x8(%eax),%eax
801041f6:	05 00 10 00 00       	add    $0x1000,%eax
801041fb:	89 45 e8             	mov    %eax,-0x18(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
801041fe:	83 6d e8 4c          	subl   $0x4c,-0x18(%ebp)
  p->tf = (struct trapframe*)sp;
80104202:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104205:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104208:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
8010420b:	83 6d e8 04          	subl   $0x4,-0x18(%ebp)
  *(uint*)sp = (uint)trapret;
8010420f:	ba 64 6e 10 80       	mov    $0x80106e64,%edx
80104214:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104217:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104219:	83 6d e8 14          	subl   $0x14,-0x18(%ebp)
  p->context = (struct context*)sp;
8010421d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104220:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104223:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104226:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104229:	8b 40 1c             	mov    0x1c(%eax),%eax
8010422c:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104233:	00 
80104234:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010423b:	00 
8010423c:	89 04 24             	mov    %eax,(%esp)
8010423f:	e8 7e 14 00 00       	call   801056c2 <memset>
  p->context->eip = (uint)forkret;
80104244:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104247:	8b 40 1c             	mov    0x1c(%eax),%eax
8010424a:	ba 28 48 10 80       	mov    $0x80104828,%edx
8010424f:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
80104252:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104255:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->cont = parentcont;
8010425c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010425f:	8b 55 08             	mov    0x8(%ebp),%edx
80104262:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  procdump();
80104268:	e8 93 07 00 00       	call   80104a00 <procdump>

  return p;
8010426d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104270:	c9                   	leave  
80104271:	c3                   	ret    

80104272 <initprocess>:

// Set up first user process.
void
initprocess(void)
{
80104272:	55                   	push   %ebp
80104273:	89 e5                	mov    %esp,%ebp
80104275:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc(rootcont());
80104278:	e8 8a 0b 00 00       	call   80104e07 <rootcont>
8010427d:	89 04 24             	mov    %eax,(%esp)
80104280:	e8 c0 fe ff ff       	call   80104145 <allocproc>
80104285:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80104288:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010428b:	a3 80 c7 10 80       	mov    %eax,0x8010c780
  if((p->pgdir = setupkvm()) == 0)
80104290:	e8 29 41 00 00       	call   801083be <setupkvm>
80104295:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104298:	89 42 04             	mov    %eax,0x4(%edx)
8010429b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010429e:	8b 40 04             	mov    0x4(%eax),%eax
801042a1:	85 c0                	test   %eax,%eax
801042a3:	75 0c                	jne    801042b1 <initprocess+0x3f>
    panic("userinit: out of memory?");
801042a5:	c7 04 24 a1 8f 10 80 	movl   $0x80108fa1,(%esp)
801042ac:	e8 a3 c2 ff ff       	call   80100554 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801042b1:	ba 2c 00 00 00       	mov    $0x2c,%edx
801042b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042b9:	8b 40 04             	mov    0x4(%eax),%eax
801042bc:	89 54 24 08          	mov    %edx,0x8(%esp)
801042c0:	c7 44 24 04 00 c5 10 	movl   $0x8010c500,0x4(%esp)
801042c7:	80 
801042c8:	89 04 24             	mov    %eax,(%esp)
801042cb:	e8 4f 43 00 00       	call   8010861f <inituvm>
  p->sz = PGSIZE;
801042d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d3:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801042d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042dc:	8b 40 18             	mov    0x18(%eax),%eax
801042df:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
801042e6:	00 
801042e7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801042ee:	00 
801042ef:	89 04 24             	mov    %eax,(%esp)
801042f2:	e8 cb 13 00 00       	call   801056c2 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801042f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042fa:	8b 40 18             	mov    0x18(%eax),%eax
801042fd:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104303:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104306:	8b 40 18             	mov    0x18(%eax),%eax
80104309:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010430f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104312:	8b 50 18             	mov    0x18(%eax),%edx
80104315:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104318:	8b 40 18             	mov    0x18(%eax),%eax
8010431b:	8b 40 2c             	mov    0x2c(%eax),%eax
8010431e:	66 89 42 28          	mov    %ax,0x28(%edx)
  p->tf->ss = p->tf->ds;
80104322:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104325:	8b 50 18             	mov    0x18(%eax),%edx
80104328:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010432b:	8b 40 18             	mov    0x18(%eax),%eax
8010432e:	8b 40 2c             	mov    0x2c(%eax),%eax
80104331:	66 89 42 48          	mov    %ax,0x48(%edx)
  p->tf->eflags = FL_IF;
80104335:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104338:	8b 40 18             	mov    0x18(%eax),%eax
8010433b:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80104342:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104345:	8b 40 18             	mov    0x18(%eax),%eax
80104348:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010434f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104352:	8b 40 18             	mov    0x18(%eax),%eax
80104355:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
8010435c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010435f:	83 c0 6c             	add    $0x6c,%eax
80104362:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104369:	00 
8010436a:	c7 44 24 04 ba 8f 10 	movl   $0x80108fba,0x4(%esp)
80104371:	80 
80104372:	89 04 24             	mov    %eax,(%esp)
80104375:	e8 54 15 00 00       	call   801058ce <safestrcpy>
  p->cwd = namei("/");
8010437a:	c7 04 24 c3 8f 10 80 	movl   $0x80108fc3,(%esp)
80104381:	e8 c5 e1 ff ff       	call   8010254b <namei>
80104386:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104389:	89 42 68             	mov    %eax,0x68(%edx)

  // Set initial process's cont to root
  p->cont = rootcont();
8010438c:	e8 76 0a 00 00       	call   80104e07 <rootcont>
80104391:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104394:	89 82 80 00 00 00    	mov    %eax,0x80(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquirectable();
8010439a:	e8 ad 08 00 00       	call   80104c4c <acquirectable>

  p->state = RUNNABLE;
8010439f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043a2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  releasectable();
801043a9:	e8 b2 08 00 00       	call   80104c60 <releasectable>
}
801043ae:	c9                   	leave  
801043af:	c3                   	ret    

801043b0 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801043b0:	55                   	push   %ebp
801043b1:	89 e5                	mov    %esp,%ebp
801043b3:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
801043b6:	e8 61 fd ff ff       	call   8010411c <myproc>
801043bb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
801043be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043c1:	8b 00                	mov    (%eax),%eax
801043c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801043c6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801043ca:	7e 31                	jle    801043fd <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801043cc:	8b 55 08             	mov    0x8(%ebp),%edx
801043cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043d2:	01 c2                	add    %eax,%edx
801043d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043d7:	8b 40 04             	mov    0x4(%eax),%eax
801043da:	89 54 24 08          	mov    %edx,0x8(%esp)
801043de:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043e1:	89 54 24 04          	mov    %edx,0x4(%esp)
801043e5:	89 04 24             	mov    %eax,(%esp)
801043e8:	e8 9d 43 00 00       	call   8010878a <allocuvm>
801043ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
801043f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801043f4:	75 3e                	jne    80104434 <growproc+0x84>
      return -1;
801043f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043fb:	eb 4f                	jmp    8010444c <growproc+0x9c>
  } else if(n < 0){
801043fd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104401:	79 31                	jns    80104434 <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104403:	8b 55 08             	mov    0x8(%ebp),%edx
80104406:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104409:	01 c2                	add    %eax,%edx
8010440b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010440e:	8b 40 04             	mov    0x4(%eax),%eax
80104411:	89 54 24 08          	mov    %edx,0x8(%esp)
80104415:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104418:	89 54 24 04          	mov    %edx,0x4(%esp)
8010441c:	89 04 24             	mov    %eax,(%esp)
8010441f:	e8 7c 44 00 00       	call   801088a0 <deallocuvm>
80104424:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104427:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010442b:	75 07                	jne    80104434 <growproc+0x84>
      return -1;
8010442d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104432:	eb 18                	jmp    8010444c <growproc+0x9c>
  }
  curproc->sz = sz;
80104434:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104437:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010443a:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
8010443c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010443f:	89 04 24             	mov    %eax,(%esp)
80104442:	e8 51 40 00 00       	call   80108498 <switchuvm>
  return 0;
80104447:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010444c:	c9                   	leave  
8010444d:	c3                   	ret    

8010444e <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
8010444e:	55                   	push   %ebp
8010444f:	89 e5                	mov    %esp,%ebp
80104451:	57                   	push   %edi
80104452:	56                   	push   %esi
80104453:	53                   	push   %ebx
80104454:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104457:	e8 c0 fc ff ff       	call   8010411c <myproc>
8010445c:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc(curproc->cont)) == 0){
8010445f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104462:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104468:	89 04 24             	mov    %eax,(%esp)
8010446b:	e8 d5 fc ff ff       	call   80104145 <allocproc>
80104470:	89 45 dc             	mov    %eax,-0x24(%ebp)
80104473:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80104477:	75 0a                	jne    80104483 <fork+0x35>
    return -1;
80104479:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010447e:	e9 27 01 00 00       	jmp    801045aa <fork+0x15c>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80104483:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104486:	8b 10                	mov    (%eax),%edx
80104488:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010448b:	8b 40 04             	mov    0x4(%eax),%eax
8010448e:	89 54 24 04          	mov    %edx,0x4(%esp)
80104492:	89 04 24             	mov    %eax,(%esp)
80104495:	e8 a6 45 00 00       	call   80108a40 <copyuvm>
8010449a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010449d:	89 42 04             	mov    %eax,0x4(%edx)
801044a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044a3:	8b 40 04             	mov    0x4(%eax),%eax
801044a6:	85 c0                	test   %eax,%eax
801044a8:	75 2c                	jne    801044d6 <fork+0x88>
    kfree(np->kstack);
801044aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044ad:	8b 40 08             	mov    0x8(%eax),%eax
801044b0:	89 04 24             	mov    %eax,(%esp)
801044b3:	e8 09 e7 ff ff       	call   80102bc1 <kfree>
    np->kstack = 0;
801044b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044bb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801044c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044c5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801044cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044d1:	e9 d4 00 00 00       	jmp    801045aa <fork+0x15c>
  }
  np->sz = curproc->sz;
801044d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044d9:	8b 10                	mov    (%eax),%edx
801044db:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044de:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
801044e0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044e3:	8b 55 e0             	mov    -0x20(%ebp),%edx
801044e6:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
801044e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801044ec:	8b 50 18             	mov    0x18(%eax),%edx
801044ef:	8b 45 e0             	mov    -0x20(%ebp),%eax
801044f2:	8b 40 18             	mov    0x18(%eax),%eax
801044f5:	89 c3                	mov    %eax,%ebx
801044f7:	b8 13 00 00 00       	mov    $0x13,%eax
801044fc:	89 d7                	mov    %edx,%edi
801044fe:	89 de                	mov    %ebx,%esi
80104500:	89 c1                	mov    %eax,%ecx
80104502:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80104504:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104507:	8b 40 18             	mov    0x18(%eax),%eax
8010450a:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104511:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104518:	eb 36                	jmp    80104550 <fork+0x102>
    if(curproc->ofile[i])
8010451a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010451d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104520:	83 c2 08             	add    $0x8,%edx
80104523:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104527:	85 c0                	test   %eax,%eax
80104529:	74 22                	je     8010454d <fork+0xff>
      np->ofile[i] = filedup(curproc->ofile[i]);
8010452b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010452e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104531:	83 c2 08             	add    $0x8,%edx
80104534:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104538:	89 04 24             	mov    %eax,(%esp)
8010453b:	e8 84 cb ff ff       	call   801010c4 <filedup>
80104540:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104543:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104546:	83 c1 08             	add    $0x8,%ecx
80104549:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
8010454d:	ff 45 e4             	incl   -0x1c(%ebp)
80104550:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80104554:	7e c4                	jle    8010451a <fork+0xcc>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80104556:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104559:	8b 40 68             	mov    0x68(%eax),%eax
8010455c:	89 04 24             	mov    %eax,(%esp)
8010455f:	e8 90 d4 ff ff       	call   801019f4 <idup>
80104564:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104567:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010456a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010456d:	8d 50 6c             	lea    0x6c(%eax),%edx
80104570:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104573:	83 c0 6c             	add    $0x6c,%eax
80104576:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
8010457d:	00 
8010457e:	89 54 24 04          	mov    %edx,0x4(%esp)
80104582:	89 04 24             	mov    %eax,(%esp)
80104585:	e8 44 13 00 00       	call   801058ce <safestrcpy>

  pid = np->pid;
8010458a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010458d:	8b 40 10             	mov    0x10(%eax),%eax
80104590:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquirectable();
80104593:	e8 b4 06 00 00       	call   80104c4c <acquirectable>

  np->state = RUNNABLE;
80104598:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010459b:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  releasectable();
801045a2:	e8 b9 06 00 00       	call   80104c60 <releasectable>

  return pid;
801045a7:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801045aa:	83 c4 2c             	add    $0x2c,%esp
801045ad:	5b                   	pop    %ebx
801045ae:	5e                   	pop    %esi
801045af:	5f                   	pop    %edi
801045b0:	5d                   	pop    %ebp
801045b1:	c3                   	ret    

801045b2 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801045b2:	55                   	push   %ebp
801045b3:	89 e5                	mov    %esp,%ebp
801045b5:	83 ec 38             	sub    $0x38,%esp
  struct proc *curproc = myproc();
801045b8:	e8 5f fb ff ff       	call   8010411c <myproc>
801045bd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  struct proc *ptable;
  int fd, nproc;

  if(curproc == initproc)
801045c0:	a1 80 c7 10 80       	mov    0x8010c780,%eax
801045c5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801045c8:	75 0c                	jne    801045d6 <exit+0x24>
    panic("init exiting");
801045ca:	c7 04 24 c5 8f 10 80 	movl   $0x80108fc5,(%esp)
801045d1:	e8 7e bf ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801045d6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801045dd:	eb 3a                	jmp    80104619 <exit+0x67>
    if(curproc->ofile[fd]){
801045df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045e5:	83 c2 08             	add    $0x8,%edx
801045e8:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801045ec:	85 c0                	test   %eax,%eax
801045ee:	74 26                	je     80104616 <exit+0x64>
      fileclose(curproc->ofile[fd]);
801045f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801045f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801045f6:	83 c2 08             	add    $0x8,%edx
801045f9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801045fd:	89 04 24             	mov    %eax,(%esp)
80104600:	e8 07 cb ff ff       	call   8010110c <fileclose>
      curproc->ofile[fd] = 0;
80104605:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104608:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010460b:	83 c2 08             	add    $0x8,%edx
8010460e:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104615:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104616:	ff 45 f0             	incl   -0x10(%ebp)
80104619:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010461d:	7e c0                	jle    801045df <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
8010461f:	e8 fb ee ff ff       	call   8010351f <begin_op>
  iput(curproc->cwd);
80104624:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104627:	8b 40 68             	mov    0x68(%eax),%eax
8010462a:	89 04 24             	mov    %eax,(%esp)
8010462d:	e8 42 d5 ff ff       	call   80101b74 <iput>
  end_op();
80104632:	e8 6a ef ff ff       	call   801035a1 <end_op>
  curproc->cwd = 0;
80104637:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010463a:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquirectable();
80104641:	e8 06 06 00 00       	call   80104c4c <acquirectable>

  ptable = curproc->cont->ptable;
80104646:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104649:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010464f:	8b 40 28             	mov    0x28(%eax),%eax
80104652:	89 45 e8             	mov    %eax,-0x18(%ebp)
  nproc = curproc->cont->mproc;
80104655:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104658:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010465e:	8b 40 08             	mov    0x8(%eax),%eax
80104661:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80104664:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104667:	8b 40 14             	mov    0x14(%eax),%eax
8010466a:	89 04 24             	mov    %eax,(%esp)
8010466d:	e8 78 02 00 00       	call   801048ea <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable; p < &ptable[nproc]; p++){
80104672:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104675:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104678:	eb 36                	jmp    801046b0 <exit+0xfe>
    if(p->parent == curproc){
8010467a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010467d:	8b 40 14             	mov    0x14(%eax),%eax
80104680:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104683:	75 24                	jne    801046a9 <exit+0xf7>
      p->parent = initproc;
80104685:	8b 15 80 c7 10 80    	mov    0x8010c780,%edx
8010468b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010468e:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104691:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104694:	8b 40 0c             	mov    0xc(%eax),%eax
80104697:	83 f8 05             	cmp    $0x5,%eax
8010469a:	75 0d                	jne    801046a9 <exit+0xf7>
        wakeup1(initproc);
8010469c:	a1 80 c7 10 80       	mov    0x8010c780,%eax
801046a1:	89 04 24             	mov    %eax,(%esp)
801046a4:	e8 41 02 00 00       	call   801048ea <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable; p < &ptable[nproc]; p++){
801046a9:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801046b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801046b3:	c1 e0 02             	shl    $0x2,%eax
801046b6:	89 c2                	mov    %eax,%edx
801046b8:	c1 e2 05             	shl    $0x5,%edx
801046bb:	01 c2                	add    %eax,%edx
801046bd:	8b 45 e8             	mov    -0x18(%ebp),%eax
801046c0:	01 d0                	add    %edx,%eax
801046c2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801046c5:	77 b3                	ja     8010467a <exit+0xc8>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
801046c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046ca:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
801046d1:	e8 d0 07 00 00       	call   80104ea6 <sched>
  panic("zombie exit");
801046d6:	c7 04 24 d2 8f 10 80 	movl   $0x80108fd2,(%esp)
801046dd:	e8 72 be ff ff       	call   80100554 <panic>

801046e2 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
801046e2:	55                   	push   %ebp
801046e3:	89 e5                	mov    %esp,%ebp
801046e5:	83 ec 38             	sub    $0x38,%esp
  struct proc *p;
  struct proc *ptable;
  int havekids, pid, nproc;
  struct proc *curproc = myproc();
801046e8:	e8 2f fa ff ff       	call   8010411c <myproc>
801046ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquirectable();
801046f0:	e8 57 05 00 00       	call   80104c4c <acquirectable>

  ptable = curproc->cont->ptable;
801046f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801046f8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801046fe:	8b 40 28             	mov    0x28(%eax),%eax
80104701:	89 45 e8             	mov    %eax,-0x18(%ebp)
  nproc = curproc->cont->mproc;
80104704:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104707:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010470d:	8b 40 08             	mov    0x8(%eax),%eax
80104710:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80104713:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable; p < &ptable[nproc]; p++){
8010471a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010471d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104720:	e9 8e 00 00 00       	jmp    801047b3 <wait+0xd1>
      if(p->parent != curproc)
80104725:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104728:	8b 40 14             	mov    0x14(%eax),%eax
8010472b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010472e:	74 02                	je     80104732 <wait+0x50>
        continue;
80104730:	eb 7a                	jmp    801047ac <wait+0xca>
      havekids = 1;
80104732:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104739:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010473c:	8b 40 0c             	mov    0xc(%eax),%eax
8010473f:	83 f8 05             	cmp    $0x5,%eax
80104742:	75 68                	jne    801047ac <wait+0xca>
        // Found one.
        pid = p->pid;
80104744:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104747:	8b 40 10             	mov    0x10(%eax),%eax
8010474a:	89 45 e0             	mov    %eax,-0x20(%ebp)
        kfree(p->kstack);
8010474d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104750:	8b 40 08             	mov    0x8(%eax),%eax
80104753:	89 04 24             	mov    %eax,(%esp)
80104756:	e8 66 e4 ff ff       	call   80102bc1 <kfree>
        p->kstack = 0;
8010475b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010475e:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104765:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104768:	8b 40 04             	mov    0x4(%eax),%eax
8010476b:	89 04 24             	mov    %eax,(%esp)
8010476e:	e8 f1 41 00 00       	call   80108964 <freevm>
        p->pid = 0;
80104773:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104776:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
8010477d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104780:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104787:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010478a:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
8010478e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104791:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104798:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010479b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        releasectable();
801047a2:	e8 b9 04 00 00       	call   80104c60 <releasectable>
        return pid;
801047a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047aa:	eb 57                	jmp    80104803 <wait+0x121>
  nproc = curproc->cont->mproc;

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable; p < &ptable[nproc]; p++){
801047ac:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801047b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801047b6:	c1 e0 02             	shl    $0x2,%eax
801047b9:	89 c2                	mov    %eax,%edx
801047bb:	c1 e2 05             	shl    $0x5,%edx
801047be:	01 c2                	add    %eax,%edx
801047c0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801047c3:	01 d0                	add    %edx,%eax
801047c5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801047c8:	0f 87 57 ff ff ff    	ja     80104725 <wait+0x43>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801047ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801047d2:	74 0a                	je     801047de <wait+0xfc>
801047d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047d7:	8b 40 24             	mov    0x24(%eax),%eax
801047da:	85 c0                	test   %eax,%eax
801047dc:	74 0c                	je     801047ea <wait+0x108>
      releasectable();
801047de:	e8 7d 04 00 00       	call   80104c60 <releasectable>
      return -1;
801047e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047e8:	eb 19                	jmp    80104803 <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, ctablelock());  //DOC: wait-sleep
801047ea:	e8 85 04 00 00       	call   80104c74 <ctablelock>
801047ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801047f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801047f6:	89 04 24             	mov    %eax,(%esp)
801047f9:	e8 62 00 00 00       	call   80104860 <sleep>
  }
801047fe:	e9 10 ff ff ff       	jmp    80104713 <wait+0x31>
}
80104803:	c9                   	leave  
80104804:	c3                   	ret    

80104805 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104805:	55                   	push   %ebp
80104806:	89 e5                	mov    %esp,%ebp
80104808:	83 ec 08             	sub    $0x8,%esp
  acquirectable();  //DOC: yieldlock
8010480b:	e8 3c 04 00 00       	call   80104c4c <acquirectable>
  myproc()->state = RUNNABLE;
80104810:	e8 07 f9 ff ff       	call   8010411c <myproc>
80104815:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010481c:	e8 85 06 00 00       	call   80104ea6 <sched>
  releasectable();
80104821:	e8 3a 04 00 00       	call   80104c60 <releasectable>
}
80104826:	c9                   	leave  
80104827:	c3                   	ret    

80104828 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104828:	55                   	push   %ebp
80104829:	89 e5                	mov    %esp,%ebp
8010482b:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ctablelock from scheduler.
  releasectable();
8010482e:	e8 2d 04 00 00       	call   80104c60 <releasectable>

  if (first) {
80104833:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104838:	85 c0                	test   %eax,%eax
8010483a:	74 22                	je     8010485e <forkret+0x36>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
8010483c:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104843:	00 00 00 
    iinit(ROOTDEV);
80104846:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010484d:	e8 6d ce ff ff       	call   801016bf <iinit>
    initlog(ROOTDEV);
80104852:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104859:	e8 c2 ea ff ff       	call   80103320 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
8010485e:	c9                   	leave  
8010485f:	c3                   	ret    

80104860 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104860:	55                   	push   %ebp
80104861:	89 e5                	mov    %esp,%ebp
80104863:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104866:	e8 b1 f8 ff ff       	call   8010411c <myproc>
8010486b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
8010486e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104872:	75 0c                	jne    80104880 <sleep+0x20>
    panic("sleep");
80104874:	c7 04 24 de 8f 10 80 	movl   $0x80108fde,(%esp)
8010487b:	e8 d4 bc ff ff       	call   80100554 <panic>

  if(lk == 0)
80104880:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104884:	75 0c                	jne    80104892 <sleep+0x32>
    panic("sleep without lk");  
80104886:	c7 04 24 e4 8f 10 80 	movl   $0x80108fe4,(%esp)
8010488d:	e8 c2 bc ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ctable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ctable.lock locked),
  // so it's okay to release lk.
  if(lk != ctablelock()){  //DOC: sleeplock0
80104892:	e8 dd 03 00 00       	call   80104c74 <ctablelock>
80104897:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010489a:	74 10                	je     801048ac <sleep+0x4c>
    acquirectable();  //DOC: sleeplock1
8010489c:	e8 ab 03 00 00       	call   80104c4c <acquirectable>
    release(lk);
801048a1:	8b 45 0c             	mov    0xc(%ebp),%eax
801048a4:	89 04 24             	mov    %eax,(%esp)
801048a7:	e8 1d 0c 00 00       	call   801054c9 <release>
  }
  // Go to sleep.
  p->chan = chan;
801048ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048af:	8b 55 08             	mov    0x8(%ebp),%edx
801048b2:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
801048b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b8:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  //cprintf("Sleeping %s\n", p->name);

  sched();
801048bf:	e8 e2 05 00 00       	call   80104ea6 <sched>

  // Tidy up.
  p->chan = 0;
801048c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048c7:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != ctablelock()){  //DOC: sleeplock2
801048ce:	e8 a1 03 00 00       	call   80104c74 <ctablelock>
801048d3:	3b 45 0c             	cmp    0xc(%ebp),%eax
801048d6:	74 10                	je     801048e8 <sleep+0x88>
    releasectable();
801048d8:	e8 83 03 00 00       	call   80104c60 <releasectable>
    acquire(lk);
801048dd:	8b 45 0c             	mov    0xc(%ebp),%eax
801048e0:	89 04 24             	mov    %eax,(%esp)
801048e3:	e8 77 0b 00 00       	call   8010545f <acquire>
  }
}
801048e8:	c9                   	leave  
801048e9:	c3                   	ret    

801048ea <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ctable lock must be held.
static void
wakeup1(void *chan)
{
801048ea:	55                   	push   %ebp
801048eb:	89 e5                	mov    %esp,%ebp
801048ed:	83 ec 18             	sub    $0x18,%esp
  struct proc *ptable;
  int nproc;

  //cprintf("May not work, may have to wake up all containers processes\n");

  nproc = mycont()->mproc;
801048f0:	e8 08 05 00 00       	call   80104dfd <mycont>
801048f5:	8b 40 08             	mov    0x8(%eax),%eax
801048f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  ptable = mycont()->ptable;
801048fb:	e8 fd 04 00 00       	call   80104dfd <mycont>
80104900:	8b 40 28             	mov    0x28(%eax),%eax
80104903:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for(p = ptable; p < &ptable[nproc]; p++)
80104906:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104909:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010490c:	eb 27                	jmp    80104935 <wakeup1+0x4b>
    if(p->state == SLEEPING && p->chan == chan) {
8010490e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104911:	8b 40 0c             	mov    0xc(%eax),%eax
80104914:	83 f8 02             	cmp    $0x2,%eax
80104917:	75 15                	jne    8010492e <wakeup1+0x44>
80104919:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010491c:	8b 40 20             	mov    0x20(%eax),%eax
8010491f:	3b 45 08             	cmp    0x8(%ebp),%eax
80104922:	75 0a                	jne    8010492e <wakeup1+0x44>
      //cprintf("Waking up: %s\n", p->name);
      p->state = RUNNABLE;
80104924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104927:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  //cprintf("May not work, may have to wake up all containers processes\n");

  nproc = mycont()->mproc;
  ptable = mycont()->ptable;

  for(p = ptable; p < &ptable[nproc]; p++)
8010492e:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104935:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104938:	c1 e0 02             	shl    $0x2,%eax
8010493b:	89 c2                	mov    %eax,%edx
8010493d:	c1 e2 05             	shl    $0x5,%edx
80104940:	01 c2                	add    %eax,%edx
80104942:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104945:	01 d0                	add    %edx,%eax
80104947:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010494a:	77 c2                	ja     8010490e <wakeup1+0x24>
    if(p->state == SLEEPING && p->chan == chan) {
      //cprintf("Waking up: %s\n", p->name);
      p->state = RUNNABLE;
    }
}
8010494c:	c9                   	leave  
8010494d:	c3                   	ret    

8010494e <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010494e:	55                   	push   %ebp
8010494f:	89 e5                	mov    %esp,%ebp
80104951:	83 ec 18             	sub    $0x18,%esp
  acquirectable();
80104954:	e8 f3 02 00 00       	call   80104c4c <acquirectable>
  wakeup1(chan);
80104959:	8b 45 08             	mov    0x8(%ebp),%eax
8010495c:	89 04 24             	mov    %eax,(%esp)
8010495f:	e8 86 ff ff ff       	call   801048ea <wakeup1>
  releasectable();
80104964:	e8 f7 02 00 00       	call   80104c60 <releasectable>
}
80104969:	c9                   	leave  
8010496a:	c3                   	ret    

8010496b <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010496b:	55                   	push   %ebp
8010496c:	89 e5                	mov    %esp,%ebp
8010496e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct proc *ptable;
  int nproc;

  acquirectable();
80104971:	e8 d6 02 00 00       	call   80104c4c <acquirectable>

  ptable = myproc()->cont->ptable;
80104976:	e8 a1 f7 ff ff       	call   8010411c <myproc>
8010497b:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104981:	8b 40 28             	mov    0x28(%eax),%eax
80104984:	89 45 f0             	mov    %eax,-0x10(%ebp)
  nproc = myproc()->cont->mproc;
80104987:	e8 90 f7 ff ff       	call   8010411c <myproc>
8010498c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104992:	8b 40 08             	mov    0x8(%eax),%eax
80104995:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for(p = ptable; p < &ptable[nproc]; p++){
80104998:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010499b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010499e:	eb 3d                	jmp    801049dd <kill+0x72>
    if(p->pid == pid){
801049a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a3:	8b 40 10             	mov    0x10(%eax),%eax
801049a6:	3b 45 08             	cmp    0x8(%ebp),%eax
801049a9:	75 2b                	jne    801049d6 <kill+0x6b>
      p->killed = 1;
801049ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ae:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801049b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049b8:	8b 40 0c             	mov    0xc(%eax),%eax
801049bb:	83 f8 02             	cmp    $0x2,%eax
801049be:	75 0a                	jne    801049ca <kill+0x5f>
        p->state = RUNNABLE;
801049c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c3:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      releasectable();
801049ca:	e8 91 02 00 00       	call   80104c60 <releasectable>
      return 0;
801049cf:	b8 00 00 00 00       	mov    $0x0,%eax
801049d4:	eb 28                	jmp    801049fe <kill+0x93>
  acquirectable();

  ptable = myproc()->cont->ptable;
  nproc = myproc()->cont->mproc;

  for(p = ptable; p < &ptable[nproc]; p++){
801049d6:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801049dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049e0:	c1 e0 02             	shl    $0x2,%eax
801049e3:	89 c2                	mov    %eax,%edx
801049e5:	c1 e2 05             	shl    $0x5,%edx
801049e8:	01 c2                	add    %eax,%edx
801049ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801049ed:	01 d0                	add    %edx,%eax
801049ef:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801049f2:	77 ac                	ja     801049a0 <kill+0x35>
        p->state = RUNNABLE;
      releasectable();
      return 0;
    }
  }
  releasectable();
801049f4:	e8 67 02 00 00       	call   80104c60 <releasectable>
  return -1;
801049f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801049fe:	c9                   	leave  
801049ff:	c3                   	ret    

80104a00 <procdump>:
// Print a process listing of current container to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104a00:	55                   	push   %ebp
80104a01:	89 e5                	mov    %esp,%ebp
80104a03:	83 ec 68             	sub    $0x68,%esp
  uint pc[10];

  struct proc *ptable;
  int nproc;

  acquirectable();
80104a06:	e8 41 02 00 00       	call   80104c4c <acquirectable>

  nproc = mycont()->mproc;
80104a0b:	e8 ed 03 00 00       	call   80104dfd <mycont>
80104a10:	8b 40 08             	mov    0x8(%eax),%eax
80104a13:	89 45 e8             	mov    %eax,-0x18(%ebp)
  ptable = mycont()->ptable;
80104a16:	e8 e2 03 00 00       	call   80104dfd <mycont>
80104a1b:	8b 40 28             	mov    0x28(%eax),%eax
80104a1e:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  cprintf("procdump() nproc: %d\n", nproc);
80104a21:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104a24:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a28:	c7 04 24 f5 8f 10 80 	movl   $0x80108ff5,(%esp)
80104a2f:	e8 8d b9 ff ff       	call   801003c1 <cprintf>

  for(p = ptable; p < &ptable[nproc]; p++){
80104a34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104a37:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104a3a:	e9 e8 00 00 00       	jmp    80104b27 <procdump+0x127>
    if(p->state == UNUSED)
80104a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a42:	8b 40 0c             	mov    0xc(%eax),%eax
80104a45:	85 c0                	test   %eax,%eax
80104a47:	75 05                	jne    80104a4e <procdump+0x4e>
      continue;
80104a49:	e9 d2 00 00 00       	jmp    80104b20 <procdump+0x120>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80104a4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a51:	8b 40 0c             	mov    0xc(%eax),%eax
80104a54:	83 f8 05             	cmp    $0x5,%eax
80104a57:	77 23                	ja     80104a7c <procdump+0x7c>
80104a59:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a5c:	8b 40 0c             	mov    0xc(%eax),%eax
80104a5f:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104a66:	85 c0                	test   %eax,%eax
80104a68:	74 12                	je     80104a7c <procdump+0x7c>
      state = states[p->state];
80104a6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a6d:	8b 40 0c             	mov    0xc(%eax),%eax
80104a70:	8b 04 85 08 c0 10 80 	mov    -0x7fef3ff8(,%eax,4),%eax
80104a77:	89 45 ec             	mov    %eax,-0x14(%ebp)
80104a7a:	eb 07                	jmp    80104a83 <procdump+0x83>
    else
      state = "???";
80104a7c:	c7 45 ec 0b 90 10 80 	movl   $0x8010900b,-0x14(%ebp)
    cprintf("cid: %d. %d %s %s", p->cont->cid, p->pid, state, p->name);
80104a83:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a86:	8d 48 6c             	lea    0x6c(%eax),%ecx
80104a89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a8c:	8b 50 10             	mov    0x10(%eax),%edx
80104a8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104a92:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104a98:	8b 40 0c             	mov    0xc(%eax),%eax
80104a9b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80104a9f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80104aa2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80104aa6:	89 54 24 08          	mov    %edx,0x8(%esp)
80104aaa:	89 44 24 04          	mov    %eax,0x4(%esp)
80104aae:	c7 04 24 0f 90 10 80 	movl   $0x8010900f,(%esp)
80104ab5:	e8 07 b9 ff ff       	call   801003c1 <cprintf>
    if(p->state == SLEEPING){
80104aba:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104abd:	8b 40 0c             	mov    0xc(%eax),%eax
80104ac0:	83 f8 02             	cmp    $0x2,%eax
80104ac3:	75 4f                	jne    80104b14 <procdump+0x114>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104ac5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ac8:	8b 40 1c             	mov    0x1c(%eax),%eax
80104acb:	8b 40 0c             	mov    0xc(%eax),%eax
80104ace:	83 c0 08             	add    $0x8,%eax
80104ad1:	8d 55 bc             	lea    -0x44(%ebp),%edx
80104ad4:	89 54 24 04          	mov    %edx,0x4(%esp)
80104ad8:	89 04 24             	mov    %eax,(%esp)
80104adb:	e8 36 0a 00 00       	call   80105516 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104ae0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104ae7:	eb 1a                	jmp    80104b03 <procdump+0x103>
        cprintf(" %p", pc[i]);
80104ae9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aec:	8b 44 85 bc          	mov    -0x44(%ebp,%eax,4),%eax
80104af0:	89 44 24 04          	mov    %eax,0x4(%esp)
80104af4:	c7 04 24 21 90 10 80 	movl   $0x80109021,(%esp)
80104afb:	e8 c1 b8 ff ff       	call   801003c1 <cprintf>
    else
      state = "???";
    cprintf("cid: %d. %d %s %s", p->cont->cid, p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80104b00:	ff 45 f4             	incl   -0xc(%ebp)
80104b03:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80104b07:	7f 0b                	jg     80104b14 <procdump+0x114>
80104b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b0c:	8b 44 85 bc          	mov    -0x44(%ebp,%eax,4),%eax
80104b10:	85 c0                	test   %eax,%eax
80104b12:	75 d5                	jne    80104ae9 <procdump+0xe9>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104b14:	c7 04 24 25 90 10 80 	movl   $0x80109025,(%esp)
80104b1b:	e8 a1 b8 ff ff       	call   801003c1 <cprintf>
  nproc = mycont()->mproc;
  ptable = mycont()->ptable;

  cprintf("procdump() nproc: %d\n", nproc);

  for(p = ptable; p < &ptable[nproc]; p++){
80104b20:	81 45 f0 84 00 00 00 	addl   $0x84,-0x10(%ebp)
80104b27:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104b2a:	c1 e0 02             	shl    $0x2,%eax
80104b2d:	89 c2                	mov    %eax,%edx
80104b2f:	c1 e2 05             	shl    $0x5,%edx
80104b32:	01 c2                	add    %eax,%edx
80104b34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104b37:	01 d0                	add    %edx,%eax
80104b39:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104b3c:	0f 87 fd fe ff ff    	ja     80104a3f <procdump+0x3f>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }

  releasectable();
80104b42:	e8 19 01 00 00       	call   80104c60 <releasectable>
}
80104b47:	c9                   	leave  
80104b48:	c3                   	ret    
80104b49:	00 00                	add    %al,(%eax)
	...

80104b4c <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104b4c:	55                   	push   %ebp
80104b4d:	89 e5                	mov    %esp,%ebp
80104b4f:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104b52:	9c                   	pushf  
80104b53:	58                   	pop    %eax
80104b54:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104b57:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b5a:	c9                   	leave  
80104b5b:	c3                   	ret    

80104b5c <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104b5c:	55                   	push   %ebp
80104b5d:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104b5f:	fb                   	sti    
}
80104b60:	5d                   	pop    %ebp
80104b61:	c3                   	ret    

80104b62 <cpuid>:

// TODO: Check to make sure ALL ctable calls have a lock

// Must be called with interrupts disabled
int
cpuid() {
80104b62:	55                   	push   %ebp
80104b63:	89 e5                	mov    %esp,%ebp
80104b65:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104b68:	e8 3a 00 00 00       	call   80104ba7 <mycpu>
80104b6d:	89 c2                	mov    %eax,%edx
80104b6f:	b8 60 49 11 80       	mov    $0x80114960,%eax
80104b74:	29 c2                	sub    %eax,%edx
80104b76:	89 d0                	mov    %edx,%eax
80104b78:	c1 f8 04             	sar    $0x4,%eax
80104b7b:	89 c1                	mov    %eax,%ecx
80104b7d:	89 ca                	mov    %ecx,%edx
80104b7f:	c1 e2 03             	shl    $0x3,%edx
80104b82:	01 ca                	add    %ecx,%edx
80104b84:	89 d0                	mov    %edx,%eax
80104b86:	c1 e0 05             	shl    $0x5,%eax
80104b89:	29 d0                	sub    %edx,%eax
80104b8b:	c1 e0 02             	shl    $0x2,%eax
80104b8e:	01 c8                	add    %ecx,%eax
80104b90:	c1 e0 03             	shl    $0x3,%eax
80104b93:	01 c8                	add    %ecx,%eax
80104b95:	89 c2                	mov    %eax,%edx
80104b97:	c1 e2 0f             	shl    $0xf,%edx
80104b9a:	29 c2                	sub    %eax,%edx
80104b9c:	c1 e2 02             	shl    $0x2,%edx
80104b9f:	01 ca                	add    %ecx,%edx
80104ba1:	89 d0                	mov    %edx,%eax
80104ba3:	f7 d8                	neg    %eax
}
80104ba5:	c9                   	leave  
80104ba6:	c3                   	ret    

80104ba7 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104ba7:	55                   	push   %ebp
80104ba8:	89 e5                	mov    %esp,%ebp
80104baa:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104bad:	e8 9a ff ff ff       	call   80104b4c <readeflags>
80104bb2:	25 00 02 00 00       	and    $0x200,%eax
80104bb7:	85 c0                	test   %eax,%eax
80104bb9:	74 0c                	je     80104bc7 <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
80104bbb:	c7 04 24 54 90 10 80 	movl   $0x80109054,(%esp)
80104bc2:	e8 8d b9 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
80104bc7:	e8 09 e4 ff ff       	call   80102fd5 <lapicid>
80104bcc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104bcf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104bd6:	eb 3b                	jmp    80104c13 <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
80104bd8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bdb:	89 d0                	mov    %edx,%eax
80104bdd:	c1 e0 02             	shl    $0x2,%eax
80104be0:	01 d0                	add    %edx,%eax
80104be2:	01 c0                	add    %eax,%eax
80104be4:	01 d0                	add    %edx,%eax
80104be6:	c1 e0 04             	shl    $0x4,%eax
80104be9:	05 60 49 11 80       	add    $0x80114960,%eax
80104bee:	8a 00                	mov    (%eax),%al
80104bf0:	0f b6 c0             	movzbl %al,%eax
80104bf3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104bf6:	75 18                	jne    80104c10 <mycpu+0x69>
      return &cpus[i];
80104bf8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104bfb:	89 d0                	mov    %edx,%eax
80104bfd:	c1 e0 02             	shl    $0x2,%eax
80104c00:	01 d0                	add    %edx,%eax
80104c02:	01 c0                	add    %eax,%eax
80104c04:	01 d0                	add    %edx,%eax
80104c06:	c1 e0 04             	shl    $0x4,%eax
80104c09:	05 60 49 11 80       	add    $0x80114960,%eax
80104c0e:	eb 19                	jmp    80104c29 <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104c10:	ff 45 f4             	incl   -0xc(%ebp)
80104c13:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80104c18:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104c1b:	7c bb                	jl     80104bd8 <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104c1d:	c7 04 24 7a 90 10 80 	movl   $0x8010907a,(%esp)
80104c24:	e8 2b b9 ff ff       	call   80100554 <panic>
}
80104c29:	c9                   	leave  
80104c2a:	c3                   	ret    

80104c2b <cinit>:

int nextcid = 1;

void
cinit(void)
{
80104c2b:	55                   	push   %ebp
80104c2c:	89 e5                	mov    %esp,%ebp
80104c2e:	83 ec 18             	sub    $0x18,%esp
  initlock(&ctable.lock, "ctable");
80104c31:	c7 44 24 04 8a 90 10 	movl   $0x8010908a,0x4(%esp)
80104c38:	80 
80104c39:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104c40:	e8 f9 07 00 00       	call   8010543e <initlock>
  // TODO: Remove
  contdump();
80104c45:	e8 3b 01 00 00       	call   80104d85 <contdump>
}
80104c4a:	c9                   	leave  
80104c4b:	c3                   	ret    

80104c4c <acquirectable>:

void
acquirectable(void) 
{
80104c4c:	55                   	push   %ebp
80104c4d:	89 e5                	mov    %esp,%ebp
80104c4f:	83 ec 18             	sub    $0x18,%esp
	//cprintf("\t\tWaiting on acquiring ctable...\n");
	acquire(&ptable.lock);
80104c52:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
80104c59:	e8 01 08 00 00       	call   8010545f <acquire>
	//cprintf("\t\tGot ctable\n");
}
80104c5e:	c9                   	leave  
80104c5f:	c3                   	ret    

80104c60 <releasectable>:
// TODO: refactor name of ctablelock to ptable
// TODO: replace these aqcuires and releases with normal aqcuire and release using ctablelock()
void 
releasectable(void)
{
80104c60:	55                   	push   %ebp
80104c61:	89 e5                	mov    %esp,%ebp
80104c63:	83 ec 18             	sub    $0x18,%esp
	release(&ptable.lock);
80104c66:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
80104c6d:	e8 57 08 00 00       	call   801054c9 <release>
	//cprintf("\t\t Released ctable\n");
}
80104c72:	c9                   	leave  
80104c73:	c3                   	ret    

80104c74 <ctablelock>:

struct spinlock*
ctablelock(void)
{
80104c74:	55                   	push   %ebp
80104c75:	89 e5                	mov    %esp,%ebp
	return &ptable.lock;
80104c77:	b8 c0 50 11 80       	mov    $0x801150c0,%eax
}
80104c7c:	5d                   	pop    %ebp
80104c7d:	c3                   	ret    

80104c7e <initcontainer>:

void
initcontainer(void)
{
80104c7e:	55                   	push   %ebp
80104c7f:	89 e5                	mov    %esp,%ebp
80104c81:	83 ec 38             	sub    $0x38,%esp
	int i,
		mproc = MAX_CONT_PROC,
80104c84:	c7 45 f0 40 00 00 00 	movl   $0x40,-0x10(%ebp)
		msz   = MAX_CONT_MEM,
80104c8b:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
		mdsk  = MAX_CONT_DSK;
80104c92:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
	struct cont *c;

	if ((c = alloccont()) == 0) {
80104c99:	e8 93 01 00 00       	call   80104e31 <alloccont>
80104c9e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80104ca1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80104ca5:	75 0c                	jne    80104cb3 <initcontainer+0x35>
		panic("Can't alloc init container.");
80104ca7:	c7 04 24 91 90 10 80 	movl   $0x80109091,(%esp)
80104cae:	e8 a1 b8 ff ff       	call   80100554 <panic>
	}

	currcont = c;	
80104cb3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104cb6:	a3 b4 50 11 80       	mov    %eax,0x801150b4

	acquire(&ctable.lock);
80104cbb:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104cc2:	e8 98 07 00 00       	call   8010545f <acquire>
	c->mproc = mproc;
80104cc7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104cca:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ccd:	89 50 08             	mov    %edx,0x8(%eax)
	c->msz = msz;
80104cd0:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104cd3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104cd6:	89 10                	mov    %edx,(%eax)
	c->mdsk = mdsk;	
80104cd8:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104cdb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104cde:	89 50 04             	mov    %edx,0x4(%eax)
	c->state = CRUNNABLE;	
80104ce1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ce4:	c7 40 14 02 00 00 00 	movl   $0x2,0x14(%eax)
	c->rootdir = namei("/");
80104ceb:	c7 04 24 ad 90 10 80 	movl   $0x801090ad,(%esp)
80104cf2:	e8 54 d8 ff ff       	call   8010254b <namei>
80104cf7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104cfa:	89 42 10             	mov    %eax,0x10(%edx)
	safestrcpy(c->name, "initcont", sizeof(c->name));	
80104cfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104d00:	83 c0 18             	add    $0x18,%eax
80104d03:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104d0a:	00 
80104d0b:	c7 44 24 04 af 90 10 	movl   $0x801090af,0x4(%esp)
80104d12:	80 
80104d13:	89 04 24             	mov    %eax,(%esp)
80104d16:	e8 b3 0b 00 00       	call   801058ce <safestrcpy>

	// Init pointers to each container's process tables
	for (i = 0; i < NCONT; i++)
80104d1b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d22:	eb 2f                	jmp    80104d53 <initcontainer+0xd5>
		ctable.cont[i].ptable = ptable.proc[i];
80104d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d27:	c1 e0 08             	shl    $0x8,%eax
80104d2a:	89 c2                	mov    %eax,%edx
80104d2c:	c1 e2 05             	shl    $0x5,%edx
80104d2f:	01 d0                	add    %edx,%eax
80104d31:	83 c0 30             	add    $0x30,%eax
80104d34:	05 c0 50 11 80       	add    $0x801150c0,%eax
80104d39:	8d 48 04             	lea    0x4(%eax),%ecx
80104d3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d3f:	89 d0                	mov    %edx,%eax
80104d41:	01 c0                	add    %eax,%eax
80104d43:	01 d0                	add    %edx,%eax
80104d45:	c1 e0 04             	shl    $0x4,%eax
80104d48:	05 50 4f 11 80       	add    $0x80114f50,%eax
80104d4d:	89 48 0c             	mov    %ecx,0xc(%eax)
	c->state = CRUNNABLE;	
	c->rootdir = namei("/");
	safestrcpy(c->name, "initcont", sizeof(c->name));	

	// Init pointers to each container's process tables
	for (i = 0; i < NCONT; i++)
80104d50:	ff 45 f4             	incl   -0xc(%ebp)
80104d53:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80104d57:	7e cb                	jle    80104d24 <initcontainer+0xa6>
		ctable.cont[i].ptable = ptable.proc[i];

	release(&ctable.lock);	
80104d59:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104d60:	e8 64 07 00 00       	call   801054c9 <release>
}
80104d65:	c9                   	leave  
80104d66:	c3                   	ret    

80104d67 <userinit>:

// Set up first user container and process.
void
userinit(void)
{
80104d67:	55                   	push   %ebp
80104d68:	89 e5                	mov    %esp,%ebp
80104d6a:	83 ec 18             	sub    $0x18,%esp
  initcontainer();
80104d6d:	e8 0c ff ff ff       	call   80104c7e <initcontainer>
  initprocess();  
80104d72:	e8 fb f4 ff ff       	call   80104272 <initprocess>
  cprintf("init process\n");
80104d77:	c7 04 24 b8 90 10 80 	movl   $0x801090b8,(%esp)
80104d7e:	e8 3e b6 ff ff       	call   801003c1 <cprintf>
}
80104d83:	c9                   	leave  
80104d84:	c3                   	ret    

80104d85 <contdump>:

void
contdump(void)
{
80104d85:	55                   	push   %ebp
80104d86:	89 e5                	mov    %esp,%ebp
80104d88:	83 ec 28             	sub    $0x28,%esp
	  [CRUNNABLE]  "runnable",
	  [CEMBRYO]    "embryo"
	  };
	int i;
  
  	acquire(&ctable.lock);
80104d8b:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104d92:	e8 c8 06 00 00       	call   8010545f <acquire>
  	for (i = 0; i < NCONT; i++)
80104d97:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104d9e:	eb 49                	jmp    80104de9 <contdump+0x64>
  		cprintf("container %d: %s\n", ctable.cont[i].cid, states[ctable.cont[i].state]);
80104da0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104da3:	89 d0                	mov    %edx,%eax
80104da5:	01 c0                	add    %eax,%eax
80104da7:	01 d0                	add    %edx,%eax
80104da9:	c1 e0 04             	shl    $0x4,%eax
80104dac:	05 40 4f 11 80       	add    $0x80114f40,%eax
80104db1:	8b 40 08             	mov    0x8(%eax),%eax
80104db4:	8b 14 85 24 c0 10 80 	mov    -0x7fef3fdc(,%eax,4),%edx
80104dbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dbe:	8d 48 01             	lea    0x1(%eax),%ecx
80104dc1:	89 c8                	mov    %ecx,%eax
80104dc3:	01 c0                	add    %eax,%eax
80104dc5:	01 c8                	add    %ecx,%eax
80104dc7:	c1 e0 04             	shl    $0x4,%eax
80104dca:	05 00 4f 11 80       	add    $0x80114f00,%eax
80104dcf:	8b 40 10             	mov    0x10(%eax),%eax
80104dd2:	89 54 24 08          	mov    %edx,0x8(%esp)
80104dd6:	89 44 24 04          	mov    %eax,0x4(%esp)
80104dda:	c7 04 24 c6 90 10 80 	movl   $0x801090c6,(%esp)
80104de1:	e8 db b5 ff ff       	call   801003c1 <cprintf>
	  [CEMBRYO]    "embryo"
	  };
	int i;
  
  	acquire(&ctable.lock);
  	for (i = 0; i < NCONT; i++)
80104de6:	ff 45 f4             	incl   -0xc(%ebp)
80104de9:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80104ded:	7e b1                	jle    80104da0 <contdump+0x1b>
  		cprintf("container %d: %s\n", ctable.cont[i].cid, states[ctable.cont[i].state]);
  	release(&ctable.lock);
80104def:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104df6:	e8 ce 06 00 00       	call   801054c9 <release>
}
80104dfb:	c9                   	leave  
80104dfc:	c3                   	ret    

80104dfd <mycont>:

struct cont*
mycont(void) {
80104dfd:	55                   	push   %ebp
80104dfe:	89 e5                	mov    %esp,%ebp
	return currcont;
80104e00:	a1 b4 50 11 80       	mov    0x801150b4,%eax
}
80104e05:	5d                   	pop    %ebp
80104e06:	c3                   	ret    

80104e07 <rootcont>:

struct cont* 	
rootcont(void) {
80104e07:	55                   	push   %ebp
80104e08:	89 e5                	mov    %esp,%ebp
80104e0a:	83 ec 28             	sub    $0x28,%esp
	struct cont *c;
	// TODO: Check to make sure it always inits at first index
  	acquire(&ctable.lock);  
80104e0d:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104e14:	e8 46 06 00 00       	call   8010545f <acquire>
  	c = &ctable.cont[0];
80104e19:	c7 45 f4 34 4f 11 80 	movl   $0x80114f34,-0xc(%ebp)
  	release(&ctable.lock);
80104e20:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104e27:	e8 9d 06 00 00       	call   801054c9 <release>
  	return c;
80104e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104e2f:	c9                   	leave  
80104e30:	c3                   	ret    

80104e31 <alloccont>:
// Look in the container table for an CUNUSED cont.
// If found, change state to CEMBRYO
// Otherwise return 0.
static struct cont*
alloccont(void)
{
80104e31:	55                   	push   %ebp
80104e32:	89 e5                	mov    %esp,%ebp
80104e34:	83 ec 28             	sub    $0x28,%esp
	struct cont *c;

	acquire(&ctable.lock);
80104e37:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104e3e:	e8 1c 06 00 00       	call   8010545f <acquire>

	for(c = ctable.cont; c < &ctable.cont[NCONT]; c++)
80104e43:	c7 45 f4 34 4f 11 80 	movl   $0x80114f34,-0xc(%ebp)
80104e4a:	eb 3e                	jmp    80104e8a <alloccont+0x59>
		if(c->state == CUNUSED)
80104e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e4f:	8b 40 14             	mov    0x14(%eax),%eax
80104e52:	85 c0                	test   %eax,%eax
80104e54:	75 30                	jne    80104e86 <alloccont+0x55>
		  goto found;
80104e56:	90                   	nop

	release(&ctable.lock);
	return 0;

found:
	c->state = CEMBRYO;
80104e57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e5a:	c7 40 14 01 00 00 00 	movl   $0x1,0x14(%eax)
	c->cid = nextcid++;
80104e61:	a1 20 c0 10 80       	mov    0x8010c020,%eax
80104e66:	8d 50 01             	lea    0x1(%eax),%edx
80104e69:	89 15 20 c0 10 80    	mov    %edx,0x8010c020
80104e6f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e72:	89 42 0c             	mov    %eax,0xc(%edx)

	release(&ctable.lock);
80104e75:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104e7c:	e8 48 06 00 00       	call   801054c9 <release>

	return c;
80104e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104e84:	eb 1e                	jmp    80104ea4 <alloccont+0x73>
{
	struct cont *c;

	acquire(&ctable.lock);

	for(c = ctable.cont; c < &ctable.cont[NCONT]; c++)
80104e86:	83 45 f4 30          	addl   $0x30,-0xc(%ebp)
80104e8a:	81 7d f4 b4 50 11 80 	cmpl   $0x801150b4,-0xc(%ebp)
80104e91:	72 b9                	jb     80104e4c <alloccont+0x1b>
		if(c->state == CUNUSED)
		  goto found;

	release(&ctable.lock);
80104e93:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104e9a:	e8 2a 06 00 00       	call   801054c9 <release>
	return 0;
80104e9f:	b8 00 00 00 00       	mov    $0x0,%eax
	c->cid = nextcid++;

	release(&ctable.lock);

	return c;
}
80104ea4:	c9                   	leave  
80104ea5:	c3                   	ret    

80104ea6 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80104ea6:	55                   	push   %ebp
80104ea7:	89 e5                	mov    %esp,%ebp
80104ea9:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
80104eac:	e8 6b f2 ff ff       	call   8010411c <myproc>
80104eb1:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(ctablelock()))
80104eb4:	e8 bb fd ff ff       	call   80104c74 <ctablelock>
80104eb9:	89 04 24             	mov    %eax,(%esp)
80104ebc:	e8 cc 06 00 00       	call   8010558d <holding>
80104ec1:	85 c0                	test   %eax,%eax
80104ec3:	75 0c                	jne    80104ed1 <sched+0x2b>
    panic("sched ctable.lock");
80104ec5:	c7 04 24 d8 90 10 80 	movl   $0x801090d8,(%esp)
80104ecc:	e8 83 b6 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1)
80104ed1:	e8 d1 fc ff ff       	call   80104ba7 <mycpu>
80104ed6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104edc:	83 f8 01             	cmp    $0x1,%eax
80104edf:	74 0c                	je     80104eed <sched+0x47>
    panic("sched locks");
80104ee1:	c7 04 24 ea 90 10 80 	movl   $0x801090ea,(%esp)
80104ee8:	e8 67 b6 ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
80104eed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ef0:	8b 40 0c             	mov    0xc(%eax),%eax
80104ef3:	83 f8 04             	cmp    $0x4,%eax
80104ef6:	75 0c                	jne    80104f04 <sched+0x5e>
    panic("sched running");
80104ef8:	c7 04 24 f6 90 10 80 	movl   $0x801090f6,(%esp)
80104eff:	e8 50 b6 ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80104f04:	e8 43 fc ff ff       	call   80104b4c <readeflags>
80104f09:	25 00 02 00 00       	and    $0x200,%eax
80104f0e:	85 c0                	test   %eax,%eax
80104f10:	74 0c                	je     80104f1e <sched+0x78>
    panic("sched interruptible");
80104f12:	c7 04 24 04 91 10 80 	movl   $0x80109104,(%esp)
80104f19:	e8 36 b6 ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
80104f1e:	e8 84 fc ff ff       	call   80104ba7 <mycpu>
80104f23:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104f29:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104f2c:	e8 76 fc ff ff       	call   80104ba7 <mycpu>
80104f31:	8b 40 04             	mov    0x4(%eax),%eax
80104f34:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f37:	83 c2 1c             	add    $0x1c,%edx
80104f3a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104f3e:	89 14 24             	mov    %edx,(%esp)
80104f41:	e8 f6 09 00 00       	call   8010593c <swtch>
  mycpu()->intena = intena;
80104f46:	e8 5c fc ff ff       	call   80104ba7 <mycpu>
80104f4b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104f4e:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104f54:	c9                   	leave  
80104f55:	c3                   	ret    

80104f56 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104f56:	55                   	push   %ebp
80104f57:	89 e5                	mov    %esp,%ebp
80104f59:	83 ec 38             	sub    $0x38,%esp
  struct proc *p;
  struct cont *cont;
  struct cpu *c = mycpu();
80104f5c:	e8 46 fc ff ff       	call   80104ba7 <mycpu>
80104f61:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i, k;
  c->proc = 0;
80104f64:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104f67:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104f6e:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104f71:	e8 e6 fb ff ff       	call   80104b5c <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104f76:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
80104f7d:	e8 dd 04 00 00       	call   8010545f <acquire>
    // TODO: do we need to acquire ctable lock too?

	// TODO: Check that scheulde cycles over ctable equally    
    for(i = 0; i < NCONT; i++) {
80104f82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f89:	e9 d5 00 00 00       	jmp    80105063 <scheduler+0x10d>

      cont = &ctable.cont[i];
80104f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f91:	8d 50 01             	lea    0x1(%eax),%edx
80104f94:	89 d0                	mov    %edx,%eax
80104f96:	01 c0                	add    %eax,%eax
80104f98:	01 d0                	add    %edx,%eax
80104f9a:	c1 e0 04             	shl    $0x4,%eax
80104f9d:	05 00 4f 11 80       	add    $0x80114f00,%eax
80104fa2:	83 c0 04             	add    $0x4,%eax
80104fa5:	89 45 e8             	mov    %eax,-0x18(%ebp)

      if (cont->state != CRUNNABLE)
80104fa8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104fab:	8b 40 14             	mov    0x14(%eax),%eax
80104fae:	83 f8 02             	cmp    $0x2,%eax
80104fb1:	74 05                	je     80104fb8 <scheduler+0x62>
      	continue;      
80104fb3:	e9 a8 00 00 00       	jmp    80105060 <scheduler+0x10a>

      for (k = (cont->nextproc % cont->mproc); k < cont->mproc; k++) {
80104fb8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104fbb:	8b 40 2c             	mov    0x2c(%eax),%eax
80104fbe:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104fc1:	8b 4a 08             	mov    0x8(%edx),%ecx
80104fc4:	99                   	cltd   
80104fc5:	f7 f9                	idiv   %ecx
80104fc7:	89 55 f0             	mov    %edx,-0x10(%ebp)
80104fca:	e9 82 00 00 00       	jmp    80105051 <scheduler+0xfb>
      	
      	  p = &cont->ptable[k]; 
80104fcf:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104fd2:	8b 50 28             	mov    0x28(%eax),%edx
80104fd5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fd8:	c1 e0 02             	shl    $0x2,%eax
80104fdb:	89 c1                	mov    %eax,%ecx
80104fdd:	c1 e1 05             	shl    $0x5,%ecx
80104fe0:	01 c8                	add    %ecx,%eax
80104fe2:	01 d0                	add    %edx,%eax
80104fe4:	89 45 e4             	mov    %eax,-0x1c(%ebp)

      	  cont->nextproc = cont->nextproc + 1;
80104fe7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104fea:	8b 40 2c             	mov    0x2c(%eax),%eax
80104fed:	8d 50 01             	lea    0x1(%eax),%edx
80104ff0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104ff3:	89 50 2c             	mov    %edx,0x2c(%eax)

	      if(p->state != RUNNABLE)
80104ff6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ff9:	8b 40 0c             	mov    0xc(%eax),%eax
80104ffc:	83 f8 03             	cmp    $0x3,%eax
80104fff:	74 02                	je     80105003 <scheduler+0xad>
	        continue;
80105001:	eb 4b                	jmp    8010504e <scheduler+0xf8>

	      // Switch to chosen process.  It is the process's job
	      // to release ctable.lock and then reacquire it
	      // before jumping back to us.
	      c->proc = p;
80105003:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105006:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105009:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
	      switchuvm(p);
8010500f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105012:	89 04 24             	mov    %eax,(%esp)
80105015:	e8 7e 34 00 00       	call   80108498 <switchuvm>
	      p->state = RUNNING;
8010501a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010501d:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

	      swtch(&(c->scheduler), p->context);
80105024:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105027:	8b 40 1c             	mov    0x1c(%eax),%eax
8010502a:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010502d:	83 c2 04             	add    $0x4,%edx
80105030:	89 44 24 04          	mov    %eax,0x4(%esp)
80105034:	89 14 24             	mov    %edx,(%esp)
80105037:	e8 00 09 00 00       	call   8010593c <swtch>
	      switchkvm();
8010503c:	e8 3d 34 00 00       	call   8010847e <switchkvm>

	      // Process is done running for now.
	      // It should have changed its p->state before coming back.
	      c->proc = 0;
80105041:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105044:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010504b:	00 00 00 
      cont = &ctable.cont[i];

      if (cont->state != CRUNNABLE)
      	continue;      

      for (k = (cont->nextproc % cont->mproc); k < cont->mproc; k++) {
8010504e:	ff 45 f0             	incl   -0x10(%ebp)
80105051:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105054:	8b 40 08             	mov    0x8(%eax),%eax
80105057:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010505a:	0f 8f 6f ff ff ff    	jg     80104fcf <scheduler+0x79>
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    // TODO: do we need to acquire ctable lock too?

	// TODO: Check that scheulde cycles over ctable equally    
    for(i = 0; i < NCONT; i++) {
80105060:	ff 45 f4             	incl   -0xc(%ebp)
80105063:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80105067:	0f 8e 21 ff ff ff    	jle    80104f8e <scheduler+0x38>
	      // Process is done running for now.
	      // It should have changed its p->state before coming back.
	      c->proc = 0;
	  }
    }
    release(&ptable.lock);
8010506d:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
80105074:	e8 50 04 00 00       	call   801054c9 <release>

  }
80105079:	e9 f3 fe ff ff       	jmp    80104f71 <scheduler+0x1b>

8010507e <movefile>:
}

/* Moves file src to folder dst 
TODO: Implement */
int
movefile(char* dst, char* src) {
8010507e:	55                   	push   %ebp
8010507f:	89 e5                	mov    %esp,%ebp
80105081:	57                   	push   %edi
80105082:	56                   	push   %esi
80105083:	53                   	push   %ebx
80105084:	83 ec 2c             	sub    $0x2c,%esp
80105087:	89 e0                	mov    %esp,%eax
80105089:	89 c6                	mov    %eax,%esi
	
	int pathsize = sizeof(dst) + sizeof(src) + 2; // dst.len + '\' + src.len + \0
8010508b:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
	char path[pathsize]; 
80105092:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105095:	8d 50 ff             	lea    -0x1(%eax),%edx
80105098:	89 55 e0             	mov    %edx,-0x20(%ebp)
8010509b:	ba 10 00 00 00       	mov    $0x10,%edx
801050a0:	4a                   	dec    %edx
801050a1:	01 d0                	add    %edx,%eax
801050a3:	b9 10 00 00 00       	mov    $0x10,%ecx
801050a8:	ba 00 00 00 00       	mov    $0x0,%edx
801050ad:	f7 f1                	div    %ecx
801050af:	6b c0 10             	imul   $0x10,%eax,%eax
801050b2:	29 c4                	sub    %eax,%esp
801050b4:	8d 44 24 0c          	lea    0xc(%esp),%eax
801050b8:	83 c0 00             	add    $0x0,%eax
801050bb:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// struct file *f;
	// struct inode *ip;

	memmove(path, dst, strlen(dst));
801050be:	8b 45 08             	mov    0x8(%ebp),%eax
801050c1:	89 04 24             	mov    %eax,(%esp)
801050c4:	e8 4c 08 00 00       	call   80105915 <strlen>
801050c9:	89 c2                	mov    %eax,%edx
801050cb:	8b 45 dc             	mov    -0x24(%ebp),%eax
801050ce:	89 54 24 08          	mov    %edx,0x8(%esp)
801050d2:	8b 55 08             	mov    0x8(%ebp),%edx
801050d5:	89 54 24 04          	mov    %edx,0x4(%esp)
801050d9:	89 04 24             	mov    %eax,(%esp)
801050dc:	e8 aa 06 00 00       	call   8010578b <memmove>
	memmove(path + strlen(dst), "/", 1);
801050e1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
801050e4:	8b 45 08             	mov    0x8(%ebp),%eax
801050e7:	89 04 24             	mov    %eax,(%esp)
801050ea:	e8 26 08 00 00       	call   80105915 <strlen>
801050ef:	01 d8                	add    %ebx,%eax
801050f1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801050f8:	00 
801050f9:	c7 44 24 04 ad 90 10 	movl   $0x801090ad,0x4(%esp)
80105100:	80 
80105101:	89 04 24             	mov    %eax,(%esp)
80105104:	e8 82 06 00 00       	call   8010578b <memmove>
	memmove(path + strlen(dst) + 1, src, strlen(src));
80105109:	8b 45 0c             	mov    0xc(%ebp),%eax
8010510c:	89 04 24             	mov    %eax,(%esp)
8010510f:	e8 01 08 00 00       	call   80105915 <strlen>
80105114:	89 c3                	mov    %eax,%ebx
80105116:	8b 7d dc             	mov    -0x24(%ebp),%edi
80105119:	8b 45 08             	mov    0x8(%ebp),%eax
8010511c:	89 04 24             	mov    %eax,(%esp)
8010511f:	e8 f1 07 00 00       	call   80105915 <strlen>
80105124:	40                   	inc    %eax
80105125:	8d 14 07             	lea    (%edi,%eax,1),%edx
80105128:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010512c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010512f:	89 44 24 04          	mov    %eax,0x4(%esp)
80105133:	89 14 24             	mov    %edx,(%esp)
80105136:	e8 50 06 00 00       	call   8010578b <memmove>
	memmove(path + strlen(dst) + 1 + strlen(src), "\0", 1);
8010513b:	8b 5d dc             	mov    -0x24(%ebp),%ebx
8010513e:	8b 45 08             	mov    0x8(%ebp),%eax
80105141:	89 04 24             	mov    %eax,(%esp)
80105144:	e8 cc 07 00 00       	call   80105915 <strlen>
80105149:	89 c7                	mov    %eax,%edi
8010514b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010514e:	89 04 24             	mov    %eax,(%esp)
80105151:	e8 bf 07 00 00       	call   80105915 <strlen>
80105156:	01 f8                	add    %edi,%eax
80105158:	40                   	inc    %eax
80105159:	01 d8                	add    %ebx,%eax
8010515b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80105162:	00 
80105163:	c7 44 24 04 18 91 10 	movl   $0x80109118,0x4(%esp)
8010516a:	80 
8010516b:	89 04 24             	mov    %eax,(%esp)
8010516e:	e8 18 06 00 00       	call   8010578b <memmove>

	cprintf("movefile path: %s\n", path);
80105173:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105176:	89 44 24 04          	mov    %eax,0x4(%esp)
8010517a:	c7 04 24 1a 91 10 80 	movl   $0x8010911a,(%esp)
80105181:	e8 3b b2 ff ff       	call   801003c1 <cprintf>
	// // Copy contents of src into new file
	// char* source;
	// fileread();	


	return 1;
80105186:	b8 01 00 00 00       	mov    $0x1,%eax
8010518b:	89 f4                	mov    %esi,%esp
}
8010518d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105190:	5b                   	pop    %ebx
80105191:	5e                   	pop    %esi
80105192:	5f                   	pop    %edi
80105193:	5d                   	pop    %ebp
80105194:	c3                   	ret    

80105195 <ccreate>:

int 
ccreate(char* name, char* progv[MAXARG], int progc, int mproc, uint msz, uint mdsk)
{
80105195:	55                   	push   %ebp
80105196:	89 e5                	mov    %esp,%ebp
80105198:	83 ec 28             	sub    $0x28,%esp
	int i;
	struct cont *nc;
	struct inode *rootdir;

	// Allocate container.
	if ((nc = alloccont()) == 0) {
8010519b:	e8 91 fc ff ff       	call   80104e31 <alloccont>
801051a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801051a3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801051a7:	75 0a                	jne    801051b3 <ccreate+0x1e>
		return -1;
801051a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051ae:	e9 23 01 00 00       	jmp    801052d6 <ccreate+0x141>
	}

	// Create a directory (same implementation as sys_mkdir)	
	// TODO: check if container exists
	begin_op();
801051b3:	e8 67 e3 ff ff       	call   8010351f <begin_op>
	if((rootdir = create(name, T_DIR, 0, 0)) == 0){
801051b8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801051bf:	00 
801051c0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801051c7:	00 
801051c8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801051cf:	00 
801051d0:	8b 45 08             	mov    0x8(%ebp),%eax
801051d3:	89 04 24             	mov    %eax,(%esp)
801051d6:	e8 ec 0f 00 00       	call   801061c7 <create>
801051db:	89 45 ec             	mov    %eax,-0x14(%ebp)
801051de:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801051e2:	75 22                	jne    80105206 <ccreate+0x71>
		end_op();
801051e4:	e8 b8 e3 ff ff       	call   801035a1 <end_op>
		cprintf("Unable to create container directory %s\n", name);
801051e9:	8b 45 08             	mov    0x8(%ebp),%eax
801051ec:	89 44 24 04          	mov    %eax,0x4(%esp)
801051f0:	c7 04 24 30 91 10 80 	movl   $0x80109130,(%esp)
801051f7:	e8 c5 b1 ff ff       	call   801003c1 <cprintf>
		return -1;
801051fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105201:	e9 d0 00 00 00       	jmp    801052d6 <ccreate+0x141>
	}
	iunlockput(rootdir);
80105206:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105209:	89 04 24             	mov    %eax,(%esp)
8010520c:	e8 14 ca ff ff       	call   80101c25 <iunlockput>
	end_op();	
80105211:	e8 8b e3 ff ff       	call   801035a1 <end_op>

	// Move files into folder
	for (i = 0; i < progc; i++) {
80105216:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010521d:	eb 48                	jmp    80105267 <ccreate+0xd2>
		if (movefile(name, progv[i]) == 0) 
8010521f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105222:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105229:	8b 45 0c             	mov    0xc(%ebp),%eax
8010522c:	01 d0                	add    %edx,%eax
8010522e:	8b 00                	mov    (%eax),%eax
80105230:	89 44 24 04          	mov    %eax,0x4(%esp)
80105234:	8b 45 08             	mov    0x8(%ebp),%eax
80105237:	89 04 24             	mov    %eax,(%esp)
8010523a:	e8 3f fe ff ff       	call   8010507e <movefile>
8010523f:	85 c0                	test   %eax,%eax
80105241:	75 21                	jne    80105264 <ccreate+0xcf>
			cprintf("Unable to move file %s\n", progv[i]);
80105243:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105246:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010524d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105250:	01 d0                	add    %edx,%eax
80105252:	8b 00                	mov    (%eax),%eax
80105254:	89 44 24 04          	mov    %eax,0x4(%esp)
80105258:	c7 04 24 59 91 10 80 	movl   $0x80109159,(%esp)
8010525f:	e8 5d b1 ff ff       	call   801003c1 <cprintf>
	}
	iunlockput(rootdir);
	end_op();	

	// Move files into folder
	for (i = 0; i < progc; i++) {
80105264:	ff 45 f4             	incl   -0xc(%ebp)
80105267:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010526a:	3b 45 10             	cmp    0x10(%ebp),%eax
8010526d:	7c b0                	jl     8010521f <ccreate+0x8a>
		if (movefile(name, progv[i]) == 0) 
			cprintf("Unable to move file %s\n", progv[i]);
	}

	acquire(&ctable.lock);
8010526f:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80105276:	e8 e4 01 00 00       	call   8010545f <acquire>
	nc->mproc = mproc;
8010527b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010527e:	8b 55 14             	mov    0x14(%ebp),%edx
80105281:	89 50 08             	mov    %edx,0x8(%eax)
	nc->msz = msz;
80105284:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105287:	8b 55 18             	mov    0x18(%ebp),%edx
8010528a:	89 10                	mov    %edx,(%eax)
	nc->mdsk = mdsk;
8010528c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010528f:	8b 55 1c             	mov    0x1c(%ebp),%edx
80105292:	89 50 04             	mov    %edx,0x4(%eax)
	nc->rootdir = rootdir;
80105295:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105298:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010529b:	89 50 10             	mov    %edx,0x10(%eax)
	strncpy(nc->name, name, 16);
8010529e:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052a1:	8d 50 18             	lea    0x18(%eax),%edx
801052a4:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801052ab:	00 
801052ac:	8b 45 08             	mov    0x8(%ebp),%eax
801052af:	89 44 24 04          	mov    %eax,0x4(%esp)
801052b3:	89 14 24             	mov    %edx,(%esp)
801052b6:	e8 bd 05 00 00       	call   80105878 <strncpy>
	nc->state = CRUNNABLE;	
801052bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052be:	c7 40 14 02 00 00 00 	movl   $0x2,0x14(%eax)
	release(&ctable.lock);	
801052c5:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
801052cc:	e8 f8 01 00 00       	call   801054c9 <release>

	return 1;  
801052d1:	b8 01 00 00 00       	mov    $0x1,%eax
}
801052d6:	c9                   	leave  
801052d7:	c3                   	ret    

801052d8 <cstart>:

// Allocates a process for the table "name"
// Runs argv[0] (argv is program plus arguments)
int
cstart(char* name, char** argv, int argc) 
{	
801052d8:	55                   	push   %ebp
801052d9:	89 e5                	mov    %esp,%ebp
801052db:	83 ec 18             	sub    $0x18,%esp
	// Find container
	acquire(&ctable.lock);
801052de:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
801052e5:	e8 75 01 00 00       	call   8010545f <acquire>
	release(&ctable.lock);
801052ea:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
801052f1:	e8 d3 01 00 00       	call   801054c9 <release>
	// acquire(&ctable.lock);
	// nc->state = CRUNNING;		
	// release(&ctable.lock);	

	// Attach to a vc 
	return 1;
801052f6:	b8 01 00 00 00       	mov    $0x1,%eax
}
801052fb:	c9                   	leave  
801052fc:	c3                   	ret    
801052fd:	00 00                	add    %al,(%eax)
	...

80105300 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80105300:	55                   	push   %ebp
80105301:	89 e5                	mov    %esp,%ebp
80105303:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
80105306:	8b 45 08             	mov    0x8(%ebp),%eax
80105309:	83 c0 04             	add    $0x4,%eax
8010530c:	c7 44 24 04 97 91 10 	movl   $0x80109197,0x4(%esp)
80105313:	80 
80105314:	89 04 24             	mov    %eax,(%esp)
80105317:	e8 22 01 00 00       	call   8010543e <initlock>
  lk->name = name;
8010531c:	8b 45 08             	mov    0x8(%ebp),%eax
8010531f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105322:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
80105325:	8b 45 08             	mov    0x8(%ebp),%eax
80105328:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
8010532e:	8b 45 08             	mov    0x8(%ebp),%eax
80105331:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
80105338:	c9                   	leave  
80105339:	c3                   	ret    

8010533a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
8010533a:	55                   	push   %ebp
8010533b:	89 e5                	mov    %esp,%ebp
8010533d:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
80105340:	8b 45 08             	mov    0x8(%ebp),%eax
80105343:	83 c0 04             	add    $0x4,%eax
80105346:	89 04 24             	mov    %eax,(%esp)
80105349:	e8 11 01 00 00       	call   8010545f <acquire>
  while (lk->locked) {
8010534e:	eb 15                	jmp    80105365 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
80105350:	8b 45 08             	mov    0x8(%ebp),%eax
80105353:	83 c0 04             	add    $0x4,%eax
80105356:	89 44 24 04          	mov    %eax,0x4(%esp)
8010535a:	8b 45 08             	mov    0x8(%ebp),%eax
8010535d:	89 04 24             	mov    %eax,(%esp)
80105360:	e8 fb f4 ff ff       	call   80104860 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80105365:	8b 45 08             	mov    0x8(%ebp),%eax
80105368:	8b 00                	mov    (%eax),%eax
8010536a:	85 c0                	test   %eax,%eax
8010536c:	75 e2                	jne    80105350 <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
8010536e:	8b 45 08             	mov    0x8(%ebp),%eax
80105371:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80105377:	e8 a0 ed ff ff       	call   8010411c <myproc>
8010537c:	8b 50 10             	mov    0x10(%eax),%edx
8010537f:	8b 45 08             	mov    0x8(%ebp),%eax
80105382:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105385:	8b 45 08             	mov    0x8(%ebp),%eax
80105388:	83 c0 04             	add    $0x4,%eax
8010538b:	89 04 24             	mov    %eax,(%esp)
8010538e:	e8 36 01 00 00       	call   801054c9 <release>
}
80105393:	c9                   	leave  
80105394:	c3                   	ret    

80105395 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105395:	55                   	push   %ebp
80105396:	89 e5                	mov    %esp,%ebp
80105398:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
8010539b:	8b 45 08             	mov    0x8(%ebp),%eax
8010539e:	83 c0 04             	add    $0x4,%eax
801053a1:	89 04 24             	mov    %eax,(%esp)
801053a4:	e8 b6 00 00 00       	call   8010545f <acquire>
  lk->locked = 0;
801053a9:	8b 45 08             	mov    0x8(%ebp),%eax
801053ac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801053b2:	8b 45 08             	mov    0x8(%ebp),%eax
801053b5:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
801053bc:	8b 45 08             	mov    0x8(%ebp),%eax
801053bf:	89 04 24             	mov    %eax,(%esp)
801053c2:	e8 87 f5 ff ff       	call   8010494e <wakeup>
  release(&lk->lk);
801053c7:	8b 45 08             	mov    0x8(%ebp),%eax
801053ca:	83 c0 04             	add    $0x4,%eax
801053cd:	89 04 24             	mov    %eax,(%esp)
801053d0:	e8 f4 00 00 00       	call   801054c9 <release>
}
801053d5:	c9                   	leave  
801053d6:	c3                   	ret    

801053d7 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
801053d7:	55                   	push   %ebp
801053d8:	89 e5                	mov    %esp,%ebp
801053da:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
801053dd:	8b 45 08             	mov    0x8(%ebp),%eax
801053e0:	83 c0 04             	add    $0x4,%eax
801053e3:	89 04 24             	mov    %eax,(%esp)
801053e6:	e8 74 00 00 00       	call   8010545f <acquire>
  r = lk->locked;
801053eb:	8b 45 08             	mov    0x8(%ebp),%eax
801053ee:	8b 00                	mov    (%eax),%eax
801053f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801053f3:	8b 45 08             	mov    0x8(%ebp),%eax
801053f6:	83 c0 04             	add    $0x4,%eax
801053f9:	89 04 24             	mov    %eax,(%esp)
801053fc:	e8 c8 00 00 00       	call   801054c9 <release>
  return r;
80105401:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105404:	c9                   	leave  
80105405:	c3                   	ret    
	...

80105408 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80105408:	55                   	push   %ebp
80105409:	89 e5                	mov    %esp,%ebp
8010540b:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010540e:	9c                   	pushf  
8010540f:	58                   	pop    %eax
80105410:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105413:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105416:	c9                   	leave  
80105417:	c3                   	ret    

80105418 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80105418:	55                   	push   %ebp
80105419:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
8010541b:	fa                   	cli    
}
8010541c:	5d                   	pop    %ebp
8010541d:	c3                   	ret    

8010541e <sti>:

static inline void
sti(void)
{
8010541e:	55                   	push   %ebp
8010541f:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105421:	fb                   	sti    
}
80105422:	5d                   	pop    %ebp
80105423:	c3                   	ret    

80105424 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
80105424:	55                   	push   %ebp
80105425:	89 e5                	mov    %esp,%ebp
80105427:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010542a:	8b 55 08             	mov    0x8(%ebp),%edx
8010542d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105430:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105433:	f0 87 02             	lock xchg %eax,(%edx)
80105436:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105439:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010543c:	c9                   	leave  
8010543d:	c3                   	ret    

8010543e <initlock>:
#include "container.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
8010543e:	55                   	push   %ebp
8010543f:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105441:	8b 45 08             	mov    0x8(%ebp),%eax
80105444:	8b 55 0c             	mov    0xc(%ebp),%edx
80105447:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
8010544a:	8b 45 08             	mov    0x8(%ebp),%eax
8010544d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80105453:	8b 45 08             	mov    0x8(%ebp),%eax
80105456:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
8010545d:	5d                   	pop    %ebp
8010545e:	c3                   	ret    

8010545f <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
8010545f:	55                   	push   %ebp
80105460:	89 e5                	mov    %esp,%ebp
80105462:	53                   	push   %ebx
80105463:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80105466:	e8 53 01 00 00       	call   801055be <pushcli>
  if(holding(lk))
8010546b:	8b 45 08             	mov    0x8(%ebp),%eax
8010546e:	89 04 24             	mov    %eax,(%esp)
80105471:	e8 17 01 00 00       	call   8010558d <holding>
80105476:	85 c0                	test   %eax,%eax
80105478:	74 0c                	je     80105486 <acquire+0x27>
    panic("acquire");
8010547a:	c7 04 24 a2 91 10 80 	movl   $0x801091a2,(%esp)
80105481:	e8 ce b0 ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80105486:	90                   	nop
80105487:	8b 45 08             	mov    0x8(%ebp),%eax
8010548a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105491:	00 
80105492:	89 04 24             	mov    %eax,(%esp)
80105495:	e8 8a ff ff ff       	call   80105424 <xchg>
8010549a:	85 c0                	test   %eax,%eax
8010549c:	75 e9                	jne    80105487 <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
8010549e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
801054a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
801054a6:	e8 fc f6 ff ff       	call   80104ba7 <mycpu>
801054ab:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
801054ae:	8b 45 08             	mov    0x8(%ebp),%eax
801054b1:	83 c0 0c             	add    $0xc,%eax
801054b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801054b8:	8d 45 08             	lea    0x8(%ebp),%eax
801054bb:	89 04 24             	mov    %eax,(%esp)
801054be:	e8 53 00 00 00       	call   80105516 <getcallerpcs>
}
801054c3:	83 c4 14             	add    $0x14,%esp
801054c6:	5b                   	pop    %ebx
801054c7:	5d                   	pop    %ebp
801054c8:	c3                   	ret    

801054c9 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801054c9:	55                   	push   %ebp
801054ca:	89 e5                	mov    %esp,%ebp
801054cc:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
801054cf:	8b 45 08             	mov    0x8(%ebp),%eax
801054d2:	89 04 24             	mov    %eax,(%esp)
801054d5:	e8 b3 00 00 00       	call   8010558d <holding>
801054da:	85 c0                	test   %eax,%eax
801054dc:	75 0c                	jne    801054ea <release+0x21>
    panic("release");
801054de:	c7 04 24 aa 91 10 80 	movl   $0x801091aa,(%esp)
801054e5:	e8 6a b0 ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
801054ea:	8b 45 08             	mov    0x8(%ebp),%eax
801054ed:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801054f4:	8b 45 08             	mov    0x8(%ebp),%eax
801054f7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801054fe:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80105503:	8b 45 08             	mov    0x8(%ebp),%eax
80105506:	8b 55 08             	mov    0x8(%ebp),%edx
80105509:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
8010550f:	e8 f4 00 00 00       	call   80105608 <popcli>
}
80105514:	c9                   	leave  
80105515:	c3                   	ret    

80105516 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105516:	55                   	push   %ebp
80105517:	89 e5                	mov    %esp,%ebp
80105519:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
8010551c:	8b 45 08             	mov    0x8(%ebp),%eax
8010551f:	83 e8 08             	sub    $0x8,%eax
80105522:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80105525:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
8010552c:	eb 37                	jmp    80105565 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
8010552e:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105532:	74 37                	je     8010556b <getcallerpcs+0x55>
80105534:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
8010553b:	76 2e                	jbe    8010556b <getcallerpcs+0x55>
8010553d:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80105541:	74 28                	je     8010556b <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
80105543:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105546:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010554d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105550:	01 c2                	add    %eax,%edx
80105552:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105555:	8b 40 04             	mov    0x4(%eax),%eax
80105558:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010555a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010555d:	8b 00                	mov    (%eax),%eax
8010555f:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105562:	ff 45 f8             	incl   -0x8(%ebp)
80105565:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105569:	7e c3                	jle    8010552e <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
8010556b:	eb 18                	jmp    80105585 <getcallerpcs+0x6f>
    pcs[i] = 0;
8010556d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105570:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105577:	8b 45 0c             	mov    0xc(%ebp),%eax
8010557a:	01 d0                	add    %edx,%eax
8010557c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105582:	ff 45 f8             	incl   -0x8(%ebp)
80105585:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105589:	7e e2                	jle    8010556d <getcallerpcs+0x57>
    pcs[i] = 0;
}
8010558b:	c9                   	leave  
8010558c:	c3                   	ret    

8010558d <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
8010558d:	55                   	push   %ebp
8010558e:	89 e5                	mov    %esp,%ebp
80105590:	53                   	push   %ebx
80105591:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80105594:	8b 45 08             	mov    0x8(%ebp),%eax
80105597:	8b 00                	mov    (%eax),%eax
80105599:	85 c0                	test   %eax,%eax
8010559b:	74 16                	je     801055b3 <holding+0x26>
8010559d:	8b 45 08             	mov    0x8(%ebp),%eax
801055a0:	8b 58 08             	mov    0x8(%eax),%ebx
801055a3:	e8 ff f5 ff ff       	call   80104ba7 <mycpu>
801055a8:	39 c3                	cmp    %eax,%ebx
801055aa:	75 07                	jne    801055b3 <holding+0x26>
801055ac:	b8 01 00 00 00       	mov    $0x1,%eax
801055b1:	eb 05                	jmp    801055b8 <holding+0x2b>
801055b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801055b8:	83 c4 04             	add    $0x4,%esp
801055bb:	5b                   	pop    %ebx
801055bc:	5d                   	pop    %ebp
801055bd:	c3                   	ret    

801055be <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801055be:	55                   	push   %ebp
801055bf:	89 e5                	mov    %esp,%ebp
801055c1:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
801055c4:	e8 3f fe ff ff       	call   80105408 <readeflags>
801055c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
801055cc:	e8 47 fe ff ff       	call   80105418 <cli>
  if(mycpu()->ncli == 0)
801055d1:	e8 d1 f5 ff ff       	call   80104ba7 <mycpu>
801055d6:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801055dc:	85 c0                	test   %eax,%eax
801055de:	75 14                	jne    801055f4 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801055e0:	e8 c2 f5 ff ff       	call   80104ba7 <mycpu>
801055e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801055e8:	81 e2 00 02 00 00    	and    $0x200,%edx
801055ee:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801055f4:	e8 ae f5 ff ff       	call   80104ba7 <mycpu>
801055f9:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801055ff:	42                   	inc    %edx
80105600:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105606:	c9                   	leave  
80105607:	c3                   	ret    

80105608 <popcli>:

void
popcli(void)
{
80105608:	55                   	push   %ebp
80105609:	89 e5                	mov    %esp,%ebp
8010560b:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
8010560e:	e8 f5 fd ff ff       	call   80105408 <readeflags>
80105613:	25 00 02 00 00       	and    $0x200,%eax
80105618:	85 c0                	test   %eax,%eax
8010561a:	74 0c                	je     80105628 <popcli+0x20>
    panic("popcli - interruptible");
8010561c:	c7 04 24 b2 91 10 80 	movl   $0x801091b2,(%esp)
80105623:	e8 2c af ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
80105628:	e8 7a f5 ff ff       	call   80104ba7 <mycpu>
8010562d:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105633:	4a                   	dec    %edx
80105634:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
8010563a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105640:	85 c0                	test   %eax,%eax
80105642:	79 0c                	jns    80105650 <popcli+0x48>
    panic("popcli");
80105644:	c7 04 24 c9 91 10 80 	movl   $0x801091c9,(%esp)
8010564b:	e8 04 af ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105650:	e8 52 f5 ff ff       	call   80104ba7 <mycpu>
80105655:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010565b:	85 c0                	test   %eax,%eax
8010565d:	75 14                	jne    80105673 <popcli+0x6b>
8010565f:	e8 43 f5 ff ff       	call   80104ba7 <mycpu>
80105664:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
8010566a:	85 c0                	test   %eax,%eax
8010566c:	74 05                	je     80105673 <popcli+0x6b>
    sti();
8010566e:	e8 ab fd ff ff       	call   8010541e <sti>
}
80105673:	c9                   	leave  
80105674:	c3                   	ret    
80105675:	00 00                	add    %al,(%eax)
	...

80105678 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105678:	55                   	push   %ebp
80105679:	89 e5                	mov    %esp,%ebp
8010567b:	57                   	push   %edi
8010567c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
8010567d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105680:	8b 55 10             	mov    0x10(%ebp),%edx
80105683:	8b 45 0c             	mov    0xc(%ebp),%eax
80105686:	89 cb                	mov    %ecx,%ebx
80105688:	89 df                	mov    %ebx,%edi
8010568a:	89 d1                	mov    %edx,%ecx
8010568c:	fc                   	cld    
8010568d:	f3 aa                	rep stos %al,%es:(%edi)
8010568f:	89 ca                	mov    %ecx,%edx
80105691:	89 fb                	mov    %edi,%ebx
80105693:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105696:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105699:	5b                   	pop    %ebx
8010569a:	5f                   	pop    %edi
8010569b:	5d                   	pop    %ebp
8010569c:	c3                   	ret    

8010569d <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
8010569d:	55                   	push   %ebp
8010569e:	89 e5                	mov    %esp,%ebp
801056a0:	57                   	push   %edi
801056a1:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801056a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
801056a5:	8b 55 10             	mov    0x10(%ebp),%edx
801056a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801056ab:	89 cb                	mov    %ecx,%ebx
801056ad:	89 df                	mov    %ebx,%edi
801056af:	89 d1                	mov    %edx,%ecx
801056b1:	fc                   	cld    
801056b2:	f3 ab                	rep stos %eax,%es:(%edi)
801056b4:	89 ca                	mov    %ecx,%edx
801056b6:	89 fb                	mov    %edi,%ebx
801056b8:	89 5d 08             	mov    %ebx,0x8(%ebp)
801056bb:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801056be:	5b                   	pop    %ebx
801056bf:	5f                   	pop    %edi
801056c0:	5d                   	pop    %ebp
801056c1:	c3                   	ret    

801056c2 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801056c2:	55                   	push   %ebp
801056c3:	89 e5                	mov    %esp,%ebp
801056c5:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
801056c8:	8b 45 08             	mov    0x8(%ebp),%eax
801056cb:	83 e0 03             	and    $0x3,%eax
801056ce:	85 c0                	test   %eax,%eax
801056d0:	75 49                	jne    8010571b <memset+0x59>
801056d2:	8b 45 10             	mov    0x10(%ebp),%eax
801056d5:	83 e0 03             	and    $0x3,%eax
801056d8:	85 c0                	test   %eax,%eax
801056da:	75 3f                	jne    8010571b <memset+0x59>
    c &= 0xFF;
801056dc:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801056e3:	8b 45 10             	mov    0x10(%ebp),%eax
801056e6:	c1 e8 02             	shr    $0x2,%eax
801056e9:	89 c2                	mov    %eax,%edx
801056eb:	8b 45 0c             	mov    0xc(%ebp),%eax
801056ee:	c1 e0 18             	shl    $0x18,%eax
801056f1:	89 c1                	mov    %eax,%ecx
801056f3:	8b 45 0c             	mov    0xc(%ebp),%eax
801056f6:	c1 e0 10             	shl    $0x10,%eax
801056f9:	09 c1                	or     %eax,%ecx
801056fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801056fe:	c1 e0 08             	shl    $0x8,%eax
80105701:	09 c8                	or     %ecx,%eax
80105703:	0b 45 0c             	or     0xc(%ebp),%eax
80105706:	89 54 24 08          	mov    %edx,0x8(%esp)
8010570a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010570e:	8b 45 08             	mov    0x8(%ebp),%eax
80105711:	89 04 24             	mov    %eax,(%esp)
80105714:	e8 84 ff ff ff       	call   8010569d <stosl>
80105719:	eb 19                	jmp    80105734 <memset+0x72>
  } else
    stosb(dst, c, n);
8010571b:	8b 45 10             	mov    0x10(%ebp),%eax
8010571e:	89 44 24 08          	mov    %eax,0x8(%esp)
80105722:	8b 45 0c             	mov    0xc(%ebp),%eax
80105725:	89 44 24 04          	mov    %eax,0x4(%esp)
80105729:	8b 45 08             	mov    0x8(%ebp),%eax
8010572c:	89 04 24             	mov    %eax,(%esp)
8010572f:	e8 44 ff ff ff       	call   80105678 <stosb>
  return dst;
80105734:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105737:	c9                   	leave  
80105738:	c3                   	ret    

80105739 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105739:	55                   	push   %ebp
8010573a:	89 e5                	mov    %esp,%ebp
8010573c:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
8010573f:	8b 45 08             	mov    0x8(%ebp),%eax
80105742:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105745:	8b 45 0c             	mov    0xc(%ebp),%eax
80105748:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
8010574b:	eb 2a                	jmp    80105777 <memcmp+0x3e>
    if(*s1 != *s2)
8010574d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105750:	8a 10                	mov    (%eax),%dl
80105752:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105755:	8a 00                	mov    (%eax),%al
80105757:	38 c2                	cmp    %al,%dl
80105759:	74 16                	je     80105771 <memcmp+0x38>
      return *s1 - *s2;
8010575b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010575e:	8a 00                	mov    (%eax),%al
80105760:	0f b6 d0             	movzbl %al,%edx
80105763:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105766:	8a 00                	mov    (%eax),%al
80105768:	0f b6 c0             	movzbl %al,%eax
8010576b:	29 c2                	sub    %eax,%edx
8010576d:	89 d0                	mov    %edx,%eax
8010576f:	eb 18                	jmp    80105789 <memcmp+0x50>
    s1++, s2++;
80105771:	ff 45 fc             	incl   -0x4(%ebp)
80105774:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105777:	8b 45 10             	mov    0x10(%ebp),%eax
8010577a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010577d:	89 55 10             	mov    %edx,0x10(%ebp)
80105780:	85 c0                	test   %eax,%eax
80105782:	75 c9                	jne    8010574d <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105784:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105789:	c9                   	leave  
8010578a:	c3                   	ret    

8010578b <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
8010578b:	55                   	push   %ebp
8010578c:	89 e5                	mov    %esp,%ebp
8010578e:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105791:	8b 45 0c             	mov    0xc(%ebp),%eax
80105794:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105797:	8b 45 08             	mov    0x8(%ebp),%eax
8010579a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
8010579d:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057a0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801057a3:	73 3a                	jae    801057df <memmove+0x54>
801057a5:	8b 45 10             	mov    0x10(%ebp),%eax
801057a8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057ab:	01 d0                	add    %edx,%eax
801057ad:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801057b0:	76 2d                	jbe    801057df <memmove+0x54>
    s += n;
801057b2:	8b 45 10             	mov    0x10(%ebp),%eax
801057b5:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801057b8:	8b 45 10             	mov    0x10(%ebp),%eax
801057bb:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801057be:	eb 10                	jmp    801057d0 <memmove+0x45>
      *--d = *--s;
801057c0:	ff 4d f8             	decl   -0x8(%ebp)
801057c3:	ff 4d fc             	decl   -0x4(%ebp)
801057c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057c9:	8a 10                	mov    (%eax),%dl
801057cb:	8b 45 f8             	mov    -0x8(%ebp),%eax
801057ce:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
801057d0:	8b 45 10             	mov    0x10(%ebp),%eax
801057d3:	8d 50 ff             	lea    -0x1(%eax),%edx
801057d6:	89 55 10             	mov    %edx,0x10(%ebp)
801057d9:	85 c0                	test   %eax,%eax
801057db:	75 e3                	jne    801057c0 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
801057dd:	eb 25                	jmp    80105804 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801057df:	eb 16                	jmp    801057f7 <memmove+0x6c>
      *d++ = *s++;
801057e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
801057e4:	8d 50 01             	lea    0x1(%eax),%edx
801057e7:	89 55 f8             	mov    %edx,-0x8(%ebp)
801057ea:	8b 55 fc             	mov    -0x4(%ebp),%edx
801057ed:	8d 4a 01             	lea    0x1(%edx),%ecx
801057f0:	89 4d fc             	mov    %ecx,-0x4(%ebp)
801057f3:	8a 12                	mov    (%edx),%dl
801057f5:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
801057f7:	8b 45 10             	mov    0x10(%ebp),%eax
801057fa:	8d 50 ff             	lea    -0x1(%eax),%edx
801057fd:	89 55 10             	mov    %edx,0x10(%ebp)
80105800:	85 c0                	test   %eax,%eax
80105802:	75 dd                	jne    801057e1 <memmove+0x56>
      *d++ = *s++;

  return dst;
80105804:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105807:	c9                   	leave  
80105808:	c3                   	ret    

80105809 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105809:	55                   	push   %ebp
8010580a:	89 e5                	mov    %esp,%ebp
8010580c:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
8010580f:	8b 45 10             	mov    0x10(%ebp),%eax
80105812:	89 44 24 08          	mov    %eax,0x8(%esp)
80105816:	8b 45 0c             	mov    0xc(%ebp),%eax
80105819:	89 44 24 04          	mov    %eax,0x4(%esp)
8010581d:	8b 45 08             	mov    0x8(%ebp),%eax
80105820:	89 04 24             	mov    %eax,(%esp)
80105823:	e8 63 ff ff ff       	call   8010578b <memmove>
}
80105828:	c9                   	leave  
80105829:	c3                   	ret    

8010582a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010582a:	55                   	push   %ebp
8010582b:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
8010582d:	eb 09                	jmp    80105838 <strncmp+0xe>
    n--, p++, q++;
8010582f:	ff 4d 10             	decl   0x10(%ebp)
80105832:	ff 45 08             	incl   0x8(%ebp)
80105835:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105838:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010583c:	74 17                	je     80105855 <strncmp+0x2b>
8010583e:	8b 45 08             	mov    0x8(%ebp),%eax
80105841:	8a 00                	mov    (%eax),%al
80105843:	84 c0                	test   %al,%al
80105845:	74 0e                	je     80105855 <strncmp+0x2b>
80105847:	8b 45 08             	mov    0x8(%ebp),%eax
8010584a:	8a 10                	mov    (%eax),%dl
8010584c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010584f:	8a 00                	mov    (%eax),%al
80105851:	38 c2                	cmp    %al,%dl
80105853:	74 da                	je     8010582f <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105855:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105859:	75 07                	jne    80105862 <strncmp+0x38>
    return 0;
8010585b:	b8 00 00 00 00       	mov    $0x0,%eax
80105860:	eb 14                	jmp    80105876 <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
80105862:	8b 45 08             	mov    0x8(%ebp),%eax
80105865:	8a 00                	mov    (%eax),%al
80105867:	0f b6 d0             	movzbl %al,%edx
8010586a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010586d:	8a 00                	mov    (%eax),%al
8010586f:	0f b6 c0             	movzbl %al,%eax
80105872:	29 c2                	sub    %eax,%edx
80105874:	89 d0                	mov    %edx,%eax
}
80105876:	5d                   	pop    %ebp
80105877:	c3                   	ret    

80105878 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105878:	55                   	push   %ebp
80105879:	89 e5                	mov    %esp,%ebp
8010587b:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
8010587e:	8b 45 08             	mov    0x8(%ebp),%eax
80105881:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105884:	90                   	nop
80105885:	8b 45 10             	mov    0x10(%ebp),%eax
80105888:	8d 50 ff             	lea    -0x1(%eax),%edx
8010588b:	89 55 10             	mov    %edx,0x10(%ebp)
8010588e:	85 c0                	test   %eax,%eax
80105890:	7e 1c                	jle    801058ae <strncpy+0x36>
80105892:	8b 45 08             	mov    0x8(%ebp),%eax
80105895:	8d 50 01             	lea    0x1(%eax),%edx
80105898:	89 55 08             	mov    %edx,0x8(%ebp)
8010589b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010589e:	8d 4a 01             	lea    0x1(%edx),%ecx
801058a1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801058a4:	8a 12                	mov    (%edx),%dl
801058a6:	88 10                	mov    %dl,(%eax)
801058a8:	8a 00                	mov    (%eax),%al
801058aa:	84 c0                	test   %al,%al
801058ac:	75 d7                	jne    80105885 <strncpy+0xd>
    ;
  while(n-- > 0)
801058ae:	eb 0c                	jmp    801058bc <strncpy+0x44>
    *s++ = 0;
801058b0:	8b 45 08             	mov    0x8(%ebp),%eax
801058b3:	8d 50 01             	lea    0x1(%eax),%edx
801058b6:	89 55 08             	mov    %edx,0x8(%ebp)
801058b9:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801058bc:	8b 45 10             	mov    0x10(%ebp),%eax
801058bf:	8d 50 ff             	lea    -0x1(%eax),%edx
801058c2:	89 55 10             	mov    %edx,0x10(%ebp)
801058c5:	85 c0                	test   %eax,%eax
801058c7:	7f e7                	jg     801058b0 <strncpy+0x38>
    *s++ = 0;
  return os;
801058c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801058cc:	c9                   	leave  
801058cd:	c3                   	ret    

801058ce <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
801058ce:	55                   	push   %ebp
801058cf:	89 e5                	mov    %esp,%ebp
801058d1:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
801058d4:	8b 45 08             	mov    0x8(%ebp),%eax
801058d7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
801058da:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058de:	7f 05                	jg     801058e5 <safestrcpy+0x17>
    return os;
801058e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801058e3:	eb 2e                	jmp    80105913 <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
801058e5:	ff 4d 10             	decl   0x10(%ebp)
801058e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058ec:	7e 1c                	jle    8010590a <safestrcpy+0x3c>
801058ee:	8b 45 08             	mov    0x8(%ebp),%eax
801058f1:	8d 50 01             	lea    0x1(%eax),%edx
801058f4:	89 55 08             	mov    %edx,0x8(%ebp)
801058f7:	8b 55 0c             	mov    0xc(%ebp),%edx
801058fa:	8d 4a 01             	lea    0x1(%edx),%ecx
801058fd:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105900:	8a 12                	mov    (%edx),%dl
80105902:	88 10                	mov    %dl,(%eax)
80105904:	8a 00                	mov    (%eax),%al
80105906:	84 c0                	test   %al,%al
80105908:	75 db                	jne    801058e5 <safestrcpy+0x17>
    ;
  *s = 0;
8010590a:	8b 45 08             	mov    0x8(%ebp),%eax
8010590d:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105910:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105913:	c9                   	leave  
80105914:	c3                   	ret    

80105915 <strlen>:

int
strlen(const char *s)
{
80105915:	55                   	push   %ebp
80105916:	89 e5                	mov    %esp,%ebp
80105918:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010591b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105922:	eb 03                	jmp    80105927 <strlen+0x12>
80105924:	ff 45 fc             	incl   -0x4(%ebp)
80105927:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010592a:	8b 45 08             	mov    0x8(%ebp),%eax
8010592d:	01 d0                	add    %edx,%eax
8010592f:	8a 00                	mov    (%eax),%al
80105931:	84 c0                	test   %al,%al
80105933:	75 ef                	jne    80105924 <strlen+0xf>
    ;
  return n;
80105935:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105938:	c9                   	leave  
80105939:	c3                   	ret    
	...

8010593c <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010593c:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105940:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105944:	55                   	push   %ebp
  pushl %ebx
80105945:	53                   	push   %ebx
  pushl %esi
80105946:	56                   	push   %esi
  pushl %edi
80105947:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105948:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010594a:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010594c:	5f                   	pop    %edi
  popl %esi
8010594d:	5e                   	pop    %esi
  popl %ebx
8010594e:	5b                   	pop    %ebx
  popl %ebp
8010594f:	5d                   	pop    %ebp
  ret
80105950:	c3                   	ret    
80105951:	00 00                	add    %al,(%eax)
	...

80105954 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105954:	55                   	push   %ebp
80105955:	89 e5                	mov    %esp,%ebp
80105957:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
8010595a:	e8 bd e7 ff ff       	call   8010411c <myproc>
8010595f:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105962:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105965:	8b 00                	mov    (%eax),%eax
80105967:	3b 45 08             	cmp    0x8(%ebp),%eax
8010596a:	76 0f                	jbe    8010597b <fetchint+0x27>
8010596c:	8b 45 08             	mov    0x8(%ebp),%eax
8010596f:	8d 50 04             	lea    0x4(%eax),%edx
80105972:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105975:	8b 00                	mov    (%eax),%eax
80105977:	39 c2                	cmp    %eax,%edx
80105979:	76 07                	jbe    80105982 <fetchint+0x2e>
    return -1;
8010597b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105980:	eb 0f                	jmp    80105991 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105982:	8b 45 08             	mov    0x8(%ebp),%eax
80105985:	8b 10                	mov    (%eax),%edx
80105987:	8b 45 0c             	mov    0xc(%ebp),%eax
8010598a:	89 10                	mov    %edx,(%eax)
  return 0;
8010598c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105991:	c9                   	leave  
80105992:	c3                   	ret    

80105993 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105993:	55                   	push   %ebp
80105994:	89 e5                	mov    %esp,%ebp
80105996:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105999:	e8 7e e7 ff ff       	call   8010411c <myproc>
8010599e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
801059a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059a4:	8b 00                	mov    (%eax),%eax
801059a6:	3b 45 08             	cmp    0x8(%ebp),%eax
801059a9:	77 07                	ja     801059b2 <fetchstr+0x1f>
    return -1;
801059ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059b0:	eb 41                	jmp    801059f3 <fetchstr+0x60>
  *pp = (char*)addr;
801059b2:	8b 55 08             	mov    0x8(%ebp),%edx
801059b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801059b8:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
801059ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059bd:	8b 00                	mov    (%eax),%eax
801059bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
801059c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801059c5:	8b 00                	mov    (%eax),%eax
801059c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801059ca:	eb 1a                	jmp    801059e6 <fetchstr+0x53>
    if(*s == 0)
801059cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059cf:	8a 00                	mov    (%eax),%al
801059d1:	84 c0                	test   %al,%al
801059d3:	75 0e                	jne    801059e3 <fetchstr+0x50>
      return s - *pp;
801059d5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801059d8:	8b 45 0c             	mov    0xc(%ebp),%eax
801059db:	8b 00                	mov    (%eax),%eax
801059dd:	29 c2                	sub    %eax,%edx
801059df:	89 d0                	mov    %edx,%eax
801059e1:	eb 10                	jmp    801059f3 <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
801059e3:	ff 45 f4             	incl   -0xc(%ebp)
801059e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059e9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801059ec:	72 de                	jb     801059cc <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
801059ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059f3:	c9                   	leave  
801059f4:	c3                   	ret    

801059f5 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
801059f5:	55                   	push   %ebp
801059f6:	89 e5                	mov    %esp,%ebp
801059f8:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
801059fb:	e8 1c e7 ff ff       	call   8010411c <myproc>
80105a00:	8b 40 18             	mov    0x18(%eax),%eax
80105a03:	8b 50 44             	mov    0x44(%eax),%edx
80105a06:	8b 45 08             	mov    0x8(%ebp),%eax
80105a09:	c1 e0 02             	shl    $0x2,%eax
80105a0c:	01 d0                	add    %edx,%eax
80105a0e:	8d 50 04             	lea    0x4(%eax),%edx
80105a11:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a14:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a18:	89 14 24             	mov    %edx,(%esp)
80105a1b:	e8 34 ff ff ff       	call   80105954 <fetchint>
}
80105a20:	c9                   	leave  
80105a21:	c3                   	ret    

80105a22 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105a22:	55                   	push   %ebp
80105a23:	89 e5                	mov    %esp,%ebp
80105a25:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
80105a28:	e8 ef e6 ff ff       	call   8010411c <myproc>
80105a2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105a30:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a33:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a37:	8b 45 08             	mov    0x8(%ebp),%eax
80105a3a:	89 04 24             	mov    %eax,(%esp)
80105a3d:	e8 b3 ff ff ff       	call   801059f5 <argint>
80105a42:	85 c0                	test   %eax,%eax
80105a44:	79 07                	jns    80105a4d <argptr+0x2b>
    return -1;
80105a46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a4b:	eb 3d                	jmp    80105a8a <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105a4d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105a51:	78 21                	js     80105a74 <argptr+0x52>
80105a53:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a56:	89 c2                	mov    %eax,%edx
80105a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a5b:	8b 00                	mov    (%eax),%eax
80105a5d:	39 c2                	cmp    %eax,%edx
80105a5f:	73 13                	jae    80105a74 <argptr+0x52>
80105a61:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a64:	89 c2                	mov    %eax,%edx
80105a66:	8b 45 10             	mov    0x10(%ebp),%eax
80105a69:	01 c2                	add    %eax,%edx
80105a6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a6e:	8b 00                	mov    (%eax),%eax
80105a70:	39 c2                	cmp    %eax,%edx
80105a72:	76 07                	jbe    80105a7b <argptr+0x59>
    return -1;
80105a74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a79:	eb 0f                	jmp    80105a8a <argptr+0x68>
  *pp = (char*)i;
80105a7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a7e:	89 c2                	mov    %eax,%edx
80105a80:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a83:	89 10                	mov    %edx,(%eax)
  return 0;
80105a85:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a8a:	c9                   	leave  
80105a8b:	c3                   	ret    

80105a8c <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105a8c:	55                   	push   %ebp
80105a8d:	89 e5                	mov    %esp,%ebp
80105a8f:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105a92:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a95:	89 44 24 04          	mov    %eax,0x4(%esp)
80105a99:	8b 45 08             	mov    0x8(%ebp),%eax
80105a9c:	89 04 24             	mov    %eax,(%esp)
80105a9f:	e8 51 ff ff ff       	call   801059f5 <argint>
80105aa4:	85 c0                	test   %eax,%eax
80105aa6:	79 07                	jns    80105aaf <argstr+0x23>
    return -1;
80105aa8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aad:	eb 12                	jmp    80105ac1 <argstr+0x35>
  return fetchstr(addr, pp);
80105aaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ab2:	8b 55 0c             	mov    0xc(%ebp),%edx
80105ab5:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ab9:	89 04 24             	mov    %eax,(%esp)
80105abc:	e8 d2 fe ff ff       	call   80105993 <fetchstr>
}
80105ac1:	c9                   	leave  
80105ac2:	c3                   	ret    

80105ac3 <syscall>:
[SYS_cinfo] sys_cinfo,
};

void
syscall(void)
{
80105ac3:	55                   	push   %ebp
80105ac4:	89 e5                	mov    %esp,%ebp
80105ac6:	53                   	push   %ebx
80105ac7:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
80105aca:	e8 4d e6 ff ff       	call   8010411c <myproc>
80105acf:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105ad2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ad5:	8b 40 18             	mov    0x18(%eax),%eax
80105ad8:	8b 40 1c             	mov    0x1c(%eax),%eax
80105adb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105ade:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ae2:	7e 2d                	jle    80105b11 <syscall+0x4e>
80105ae4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ae7:	83 f8 1b             	cmp    $0x1b,%eax
80105aea:	77 25                	ja     80105b11 <syscall+0x4e>
80105aec:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105aef:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105af6:	85 c0                	test   %eax,%eax
80105af8:	74 17                	je     80105b11 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105afd:	8b 58 18             	mov    0x18(%eax),%ebx
80105b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b03:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105b0a:	ff d0                	call   *%eax
80105b0c:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105b0f:	eb 34                	jmp    80105b45 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b14:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b1a:	8b 40 10             	mov    0x10(%eax),%eax
80105b1d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b20:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105b24:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105b28:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b2c:	c7 04 24 d0 91 10 80 	movl   $0x801091d0,(%esp)
80105b33:	e8 89 a8 ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b3b:	8b 40 18             	mov    0x18(%eax),%eax
80105b3e:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105b45:	83 c4 24             	add    $0x24,%esp
80105b48:	5b                   	pop    %ebx
80105b49:	5d                   	pop    %ebp
80105b4a:	c3                   	ret    
	...

80105b4c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105b4c:	55                   	push   %ebp
80105b4d:	89 e5                	mov    %esp,%ebp
80105b4f:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105b52:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105b55:	89 44 24 04          	mov    %eax,0x4(%esp)
80105b59:	8b 45 08             	mov    0x8(%ebp),%eax
80105b5c:	89 04 24             	mov    %eax,(%esp)
80105b5f:	e8 91 fe ff ff       	call   801059f5 <argint>
80105b64:	85 c0                	test   %eax,%eax
80105b66:	79 07                	jns    80105b6f <argfd+0x23>
    return -1;
80105b68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b6d:	eb 4f                	jmp    80105bbe <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80105b6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b72:	85 c0                	test   %eax,%eax
80105b74:	78 20                	js     80105b96 <argfd+0x4a>
80105b76:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b79:	83 f8 0f             	cmp    $0xf,%eax
80105b7c:	7f 18                	jg     80105b96 <argfd+0x4a>
80105b7e:	e8 99 e5 ff ff       	call   8010411c <myproc>
80105b83:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105b86:	83 c2 08             	add    $0x8,%edx
80105b89:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105b8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b90:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b94:	75 07                	jne    80105b9d <argfd+0x51>
    return -1;
80105b96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b9b:	eb 21                	jmp    80105bbe <argfd+0x72>
  if(pfd)
80105b9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105ba1:	74 08                	je     80105bab <argfd+0x5f>
    *pfd = fd;
80105ba3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ba9:	89 10                	mov    %edx,(%eax)
  if(pf)
80105bab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105baf:	74 08                	je     80105bb9 <argfd+0x6d>
    *pf = f;
80105bb1:	8b 45 10             	mov    0x10(%ebp),%eax
80105bb4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bb7:	89 10                	mov    %edx,(%eax)
  return 0;
80105bb9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105bbe:	c9                   	leave  
80105bbf:	c3                   	ret    

80105bc0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105bc0:	55                   	push   %ebp
80105bc1:	89 e5                	mov    %esp,%ebp
80105bc3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80105bc6:	e8 51 e5 ff ff       	call   8010411c <myproc>
80105bcb:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80105bce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105bd5:	eb 29                	jmp    80105c00 <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
80105bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bda:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bdd:	83 c2 08             	add    $0x8,%edx
80105be0:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105be4:	85 c0                	test   %eax,%eax
80105be6:	75 15                	jne    80105bfd <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80105be8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105beb:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105bee:	8d 4a 08             	lea    0x8(%edx),%ecx
80105bf1:	8b 55 08             	mov    0x8(%ebp),%edx
80105bf4:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bfb:	eb 0e                	jmp    80105c0b <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80105bfd:	ff 45 f4             	incl   -0xc(%ebp)
80105c00:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105c04:	7e d1                	jle    80105bd7 <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105c06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c0b:	c9                   	leave  
80105c0c:	c3                   	ret    

80105c0d <sys_dup>:

int
sys_dup(void)
{
80105c0d:	55                   	push   %ebp
80105c0e:	89 e5                	mov    %esp,%ebp
80105c10:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80105c13:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c16:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c1a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105c21:	00 
80105c22:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c29:	e8 1e ff ff ff       	call   80105b4c <argfd>
80105c2e:	85 c0                	test   %eax,%eax
80105c30:	79 07                	jns    80105c39 <sys_dup+0x2c>
    return -1;
80105c32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c37:	eb 29                	jmp    80105c62 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105c39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c3c:	89 04 24             	mov    %eax,(%esp)
80105c3f:	e8 7c ff ff ff       	call   80105bc0 <fdalloc>
80105c44:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105c47:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105c4b:	79 07                	jns    80105c54 <sys_dup+0x47>
    return -1;
80105c4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c52:	eb 0e                	jmp    80105c62 <sys_dup+0x55>
  filedup(f);
80105c54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c57:	89 04 24             	mov    %eax,(%esp)
80105c5a:	e8 65 b4 ff ff       	call   801010c4 <filedup>
  return fd;
80105c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105c62:	c9                   	leave  
80105c63:	c3                   	ret    

80105c64 <sys_read>:

int
sys_read(void)
{
80105c64:	55                   	push   %ebp
80105c65:	89 e5                	mov    %esp,%ebp
80105c67:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105c6a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c6d:	89 44 24 08          	mov    %eax,0x8(%esp)
80105c71:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105c78:	00 
80105c79:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105c80:	e8 c7 fe ff ff       	call   80105b4c <argfd>
80105c85:	85 c0                	test   %eax,%eax
80105c87:	78 35                	js     80105cbe <sys_read+0x5a>
80105c89:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105c90:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105c97:	e8 59 fd ff ff       	call   801059f5 <argint>
80105c9c:	85 c0                	test   %eax,%eax
80105c9e:	78 1e                	js     80105cbe <sys_read+0x5a>
80105ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ca3:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ca7:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105caa:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105cb5:	e8 68 fd ff ff       	call   80105a22 <argptr>
80105cba:	85 c0                	test   %eax,%eax
80105cbc:	79 07                	jns    80105cc5 <sys_read+0x61>
    return -1;
80105cbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cc3:	eb 19                	jmp    80105cde <sys_read+0x7a>
  return fileread(f, p, n);
80105cc5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105cc8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cce:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105cd2:	89 54 24 04          	mov    %edx,0x4(%esp)
80105cd6:	89 04 24             	mov    %eax,(%esp)
80105cd9:	e8 47 b5 ff ff       	call   80101225 <fileread>
}
80105cde:	c9                   	leave  
80105cdf:	c3                   	ret    

80105ce0 <sys_write>:

int
sys_write(void)
{
80105ce0:	55                   	push   %ebp
80105ce1:	89 e5                	mov    %esp,%ebp
80105ce3:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105ce6:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ce9:	89 44 24 08          	mov    %eax,0x8(%esp)
80105ced:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105cf4:	00 
80105cf5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105cfc:	e8 4b fe ff ff       	call   80105b4c <argfd>
80105d01:	85 c0                	test   %eax,%eax
80105d03:	78 35                	js     80105d3a <sys_write+0x5a>
80105d05:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d08:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d0c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80105d13:	e8 dd fc ff ff       	call   801059f5 <argint>
80105d18:	85 c0                	test   %eax,%eax
80105d1a:	78 1e                	js     80105d3a <sys_write+0x5a>
80105d1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d1f:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d23:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105d26:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d2a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105d31:	e8 ec fc ff ff       	call   80105a22 <argptr>
80105d36:	85 c0                	test   %eax,%eax
80105d38:	79 07                	jns    80105d41 <sys_write+0x61>
    return -1;
80105d3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d3f:	eb 19                	jmp    80105d5a <sys_write+0x7a>
  return filewrite(f, p, n);
80105d41:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105d44:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105d47:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d4a:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105d4e:	89 54 24 04          	mov    %edx,0x4(%esp)
80105d52:	89 04 24             	mov    %eax,(%esp)
80105d55:	e8 86 b5 ff ff       	call   801012e0 <filewrite>
}
80105d5a:	c9                   	leave  
80105d5b:	c3                   	ret    

80105d5c <sys_close>:

int
sys_close(void)
{
80105d5c:	55                   	push   %ebp
80105d5d:	89 e5                	mov    %esp,%ebp
80105d5f:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80105d62:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105d65:	89 44 24 08          	mov    %eax,0x8(%esp)
80105d69:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d6c:	89 44 24 04          	mov    %eax,0x4(%esp)
80105d70:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105d77:	e8 d0 fd ff ff       	call   80105b4c <argfd>
80105d7c:	85 c0                	test   %eax,%eax
80105d7e:	79 07                	jns    80105d87 <sys_close+0x2b>
    return -1;
80105d80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d85:	eb 23                	jmp    80105daa <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
80105d87:	e8 90 e3 ff ff       	call   8010411c <myproc>
80105d8c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105d8f:	83 c2 08             	add    $0x8,%edx
80105d92:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105d99:	00 
  fileclose(f);
80105d9a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105d9d:	89 04 24             	mov    %eax,(%esp)
80105da0:	e8 67 b3 ff ff       	call   8010110c <fileclose>
  return 0;
80105da5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105daa:	c9                   	leave  
80105dab:	c3                   	ret    

80105dac <sys_fstat>:

int
sys_fstat(void)
{
80105dac:	55                   	push   %ebp
80105dad:	89 e5                	mov    %esp,%ebp
80105daf:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105db2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105db5:	89 44 24 08          	mov    %eax,0x8(%esp)
80105db9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105dc0:	00 
80105dc1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105dc8:	e8 7f fd ff ff       	call   80105b4c <argfd>
80105dcd:	85 c0                	test   %eax,%eax
80105dcf:	78 1f                	js     80105df0 <sys_fstat+0x44>
80105dd1:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80105dd8:	00 
80105dd9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ddc:	89 44 24 04          	mov    %eax,0x4(%esp)
80105de0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105de7:	e8 36 fc ff ff       	call   80105a22 <argptr>
80105dec:	85 c0                	test   %eax,%eax
80105dee:	79 07                	jns    80105df7 <sys_fstat+0x4b>
    return -1;
80105df0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105df5:	eb 12                	jmp    80105e09 <sys_fstat+0x5d>
  return filestat(f, st);
80105df7:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105dfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dfd:	89 54 24 04          	mov    %edx,0x4(%esp)
80105e01:	89 04 24             	mov    %eax,(%esp)
80105e04:	e8 cd b3 ff ff       	call   801011d6 <filestat>
}
80105e09:	c9                   	leave  
80105e0a:	c3                   	ret    

80105e0b <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105e0b:	55                   	push   %ebp
80105e0c:	89 e5                	mov    %esp,%ebp
80105e0e:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105e11:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105e14:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80105e1f:	e8 68 fc ff ff       	call   80105a8c <argstr>
80105e24:	85 c0                	test   %eax,%eax
80105e26:	78 17                	js     80105e3f <sys_link+0x34>
80105e28:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105e2b:	89 44 24 04          	mov    %eax,0x4(%esp)
80105e2f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80105e36:	e8 51 fc ff ff       	call   80105a8c <argstr>
80105e3b:	85 c0                	test   %eax,%eax
80105e3d:	79 0a                	jns    80105e49 <sys_link+0x3e>
    return -1;
80105e3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e44:	e9 3d 01 00 00       	jmp    80105f86 <sys_link+0x17b>

  begin_op();
80105e49:	e8 d1 d6 ff ff       	call   8010351f <begin_op>
  if((ip = namei(old)) == 0){
80105e4e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105e51:	89 04 24             	mov    %eax,(%esp)
80105e54:	e8 f2 c6 ff ff       	call   8010254b <namei>
80105e59:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e5c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105e60:	75 0f                	jne    80105e71 <sys_link+0x66>
    end_op();
80105e62:	e8 3a d7 ff ff       	call   801035a1 <end_op>
    return -1;
80105e67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e6c:	e9 15 01 00 00       	jmp    80105f86 <sys_link+0x17b>
  }

  ilock(ip);
80105e71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e74:	89 04 24             	mov    %eax,(%esp)
80105e77:	e8 aa bb ff ff       	call   80101a26 <ilock>
  if(ip->type == T_DIR){
80105e7c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e7f:	8b 40 50             	mov    0x50(%eax),%eax
80105e82:	66 83 f8 01          	cmp    $0x1,%ax
80105e86:	75 1a                	jne    80105ea2 <sys_link+0x97>
    iunlockput(ip);
80105e88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8b:	89 04 24             	mov    %eax,(%esp)
80105e8e:	e8 92 bd ff ff       	call   80101c25 <iunlockput>
    end_op();
80105e93:	e8 09 d7 ff ff       	call   801035a1 <end_op>
    return -1;
80105e98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e9d:	e9 e4 00 00 00       	jmp    80105f86 <sys_link+0x17b>
  }

  ip->nlink++;
80105ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ea5:	66 8b 40 56          	mov    0x56(%eax),%ax
80105ea9:	40                   	inc    %eax
80105eaa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ead:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eb4:	89 04 24             	mov    %eax,(%esp)
80105eb7:	e8 a7 b9 ff ff       	call   80101863 <iupdate>
  iunlock(ip);
80105ebc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ebf:	89 04 24             	mov    %eax,(%esp)
80105ec2:	e8 69 bc ff ff       	call   80101b30 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80105ec7:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105eca:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105ecd:	89 54 24 04          	mov    %edx,0x4(%esp)
80105ed1:	89 04 24             	mov    %eax,(%esp)
80105ed4:	e8 94 c6 ff ff       	call   8010256d <nameiparent>
80105ed9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105edc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105ee0:	75 02                	jne    80105ee4 <sys_link+0xd9>
    goto bad;
80105ee2:	eb 68                	jmp    80105f4c <sys_link+0x141>
  ilock(dp);
80105ee4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ee7:	89 04 24             	mov    %eax,(%esp)
80105eea:	e8 37 bb ff ff       	call   80101a26 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ef2:	8b 10                	mov    (%eax),%edx
80105ef4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ef7:	8b 00                	mov    (%eax),%eax
80105ef9:	39 c2                	cmp    %eax,%edx
80105efb:	75 20                	jne    80105f1d <sys_link+0x112>
80105efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f00:	8b 40 04             	mov    0x4(%eax),%eax
80105f03:	89 44 24 08          	mov    %eax,0x8(%esp)
80105f07:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105f0a:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f11:	89 04 24             	mov    %eax,(%esp)
80105f14:	e8 7f c3 ff ff       	call   80102298 <dirlink>
80105f19:	85 c0                	test   %eax,%eax
80105f1b:	79 0d                	jns    80105f2a <sys_link+0x11f>
    iunlockput(dp);
80105f1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f20:	89 04 24             	mov    %eax,(%esp)
80105f23:	e8 fd bc ff ff       	call   80101c25 <iunlockput>
    goto bad;
80105f28:	eb 22                	jmp    80105f4c <sys_link+0x141>
  }
  iunlockput(dp);
80105f2a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f2d:	89 04 24             	mov    %eax,(%esp)
80105f30:	e8 f0 bc ff ff       	call   80101c25 <iunlockput>
  iput(ip);
80105f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f38:	89 04 24             	mov    %eax,(%esp)
80105f3b:	e8 34 bc ff ff       	call   80101b74 <iput>

  end_op();
80105f40:	e8 5c d6 ff ff       	call   801035a1 <end_op>

  return 0;
80105f45:	b8 00 00 00 00       	mov    $0x0,%eax
80105f4a:	eb 3a                	jmp    80105f86 <sys_link+0x17b>

bad:
  ilock(ip);
80105f4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f4f:	89 04 24             	mov    %eax,(%esp)
80105f52:	e8 cf ba ff ff       	call   80101a26 <ilock>
  ip->nlink--;
80105f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f5a:	66 8b 40 56          	mov    0x56(%eax),%ax
80105f5e:	48                   	dec    %eax
80105f5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105f62:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80105f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f69:	89 04 24             	mov    %eax,(%esp)
80105f6c:	e8 f2 b8 ff ff       	call   80101863 <iupdate>
  iunlockput(ip);
80105f71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f74:	89 04 24             	mov    %eax,(%esp)
80105f77:	e8 a9 bc ff ff       	call   80101c25 <iunlockput>
  end_op();
80105f7c:	e8 20 d6 ff ff       	call   801035a1 <end_op>
  return -1;
80105f81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f86:	c9                   	leave  
80105f87:	c3                   	ret    

80105f88 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105f88:	55                   	push   %ebp
80105f89:	89 e5                	mov    %esp,%ebp
80105f8b:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105f8e:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105f95:	eb 4a                	jmp    80105fe1 <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f9a:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80105fa1:	00 
80105fa2:	89 44 24 08          	mov    %eax,0x8(%esp)
80105fa6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105fa9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fad:	8b 45 08             	mov    0x8(%ebp),%eax
80105fb0:	89 04 24             	mov    %eax,(%esp)
80105fb3:	e8 05 bf ff ff       	call   80101ebd <readi>
80105fb8:	83 f8 10             	cmp    $0x10,%eax
80105fbb:	74 0c                	je     80105fc9 <isdirempty+0x41>
      panic("isdirempty: readi");
80105fbd:	c7 04 24 ec 91 10 80 	movl   $0x801091ec,(%esp)
80105fc4:	e8 8b a5 ff ff       	call   80100554 <panic>
    if(de.inum != 0)
80105fc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fcc:	66 85 c0             	test   %ax,%ax
80105fcf:	74 07                	je     80105fd8 <isdirempty+0x50>
      return 0;
80105fd1:	b8 00 00 00 00       	mov    $0x0,%eax
80105fd6:	eb 1b                	jmp    80105ff3 <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fdb:	83 c0 10             	add    $0x10,%eax
80105fde:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105fe1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105fe4:	8b 45 08             	mov    0x8(%ebp),%eax
80105fe7:	8b 40 58             	mov    0x58(%eax),%eax
80105fea:	39 c2                	cmp    %eax,%edx
80105fec:	72 a9                	jb     80105f97 <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105fee:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105ff3:	c9                   	leave  
80105ff4:	c3                   	ret    

80105ff5 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105ff5:	55                   	push   %ebp
80105ff6:	89 e5                	mov    %esp,%ebp
80105ff8:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105ffb:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105ffe:	89 44 24 04          	mov    %eax,0x4(%esp)
80106002:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106009:	e8 7e fa ff ff       	call   80105a8c <argstr>
8010600e:	85 c0                	test   %eax,%eax
80106010:	79 0a                	jns    8010601c <sys_unlink+0x27>
    return -1;
80106012:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106017:	e9 a9 01 00 00       	jmp    801061c5 <sys_unlink+0x1d0>

  begin_op();
8010601c:	e8 fe d4 ff ff       	call   8010351f <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80106021:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106024:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106027:	89 54 24 04          	mov    %edx,0x4(%esp)
8010602b:	89 04 24             	mov    %eax,(%esp)
8010602e:	e8 3a c5 ff ff       	call   8010256d <nameiparent>
80106033:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106036:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010603a:	75 0f                	jne    8010604b <sys_unlink+0x56>
    end_op();
8010603c:	e8 60 d5 ff ff       	call   801035a1 <end_op>
    return -1;
80106041:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106046:	e9 7a 01 00 00       	jmp    801061c5 <sys_unlink+0x1d0>
  }

  ilock(dp);
8010604b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010604e:	89 04 24             	mov    %eax,(%esp)
80106051:	e8 d0 b9 ff ff       	call   80101a26 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106056:	c7 44 24 04 fe 91 10 	movl   $0x801091fe,0x4(%esp)
8010605d:	80 
8010605e:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106061:	89 04 24             	mov    %eax,(%esp)
80106064:	e8 47 c1 ff ff       	call   801021b0 <namecmp>
80106069:	85 c0                	test   %eax,%eax
8010606b:	0f 84 3f 01 00 00    	je     801061b0 <sys_unlink+0x1bb>
80106071:	c7 44 24 04 00 92 10 	movl   $0x80109200,0x4(%esp)
80106078:	80 
80106079:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010607c:	89 04 24             	mov    %eax,(%esp)
8010607f:	e8 2c c1 ff ff       	call   801021b0 <namecmp>
80106084:	85 c0                	test   %eax,%eax
80106086:	0f 84 24 01 00 00    	je     801061b0 <sys_unlink+0x1bb>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010608c:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010608f:	89 44 24 08          	mov    %eax,0x8(%esp)
80106093:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106096:	89 44 24 04          	mov    %eax,0x4(%esp)
8010609a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010609d:	89 04 24             	mov    %eax,(%esp)
801060a0:	e8 2d c1 ff ff       	call   801021d2 <dirlookup>
801060a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801060a8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801060ac:	75 05                	jne    801060b3 <sys_unlink+0xbe>
    goto bad;
801060ae:	e9 fd 00 00 00       	jmp    801061b0 <sys_unlink+0x1bb>
  ilock(ip);
801060b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060b6:	89 04 24             	mov    %eax,(%esp)
801060b9:	e8 68 b9 ff ff       	call   80101a26 <ilock>

  if(ip->nlink < 1)
801060be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060c1:	66 8b 40 56          	mov    0x56(%eax),%ax
801060c5:	66 85 c0             	test   %ax,%ax
801060c8:	7f 0c                	jg     801060d6 <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
801060ca:	c7 04 24 03 92 10 80 	movl   $0x80109203,(%esp)
801060d1:	e8 7e a4 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801060d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060d9:	8b 40 50             	mov    0x50(%eax),%eax
801060dc:	66 83 f8 01          	cmp    $0x1,%ax
801060e0:	75 1f                	jne    80106101 <sys_unlink+0x10c>
801060e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e5:	89 04 24             	mov    %eax,(%esp)
801060e8:	e8 9b fe ff ff       	call   80105f88 <isdirempty>
801060ed:	85 c0                	test   %eax,%eax
801060ef:	75 10                	jne    80106101 <sys_unlink+0x10c>
    iunlockput(ip);
801060f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060f4:	89 04 24             	mov    %eax,(%esp)
801060f7:	e8 29 bb ff ff       	call   80101c25 <iunlockput>
    goto bad;
801060fc:	e9 af 00 00 00       	jmp    801061b0 <sys_unlink+0x1bb>
  }

  memset(&de, 0, sizeof(de));
80106101:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80106108:	00 
80106109:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106110:	00 
80106111:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106114:	89 04 24             	mov    %eax,(%esp)
80106117:	e8 a6 f5 ff ff       	call   801056c2 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010611c:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010611f:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106126:	00 
80106127:	89 44 24 08          	mov    %eax,0x8(%esp)
8010612b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010612e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106135:	89 04 24             	mov    %eax,(%esp)
80106138:	e8 e4 be ff ff       	call   80102021 <writei>
8010613d:	83 f8 10             	cmp    $0x10,%eax
80106140:	74 0c                	je     8010614e <sys_unlink+0x159>
    panic("unlink: writei");
80106142:	c7 04 24 15 92 10 80 	movl   $0x80109215,(%esp)
80106149:	e8 06 a4 ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR){
8010614e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106151:	8b 40 50             	mov    0x50(%eax),%eax
80106154:	66 83 f8 01          	cmp    $0x1,%ax
80106158:	75 1a                	jne    80106174 <sys_unlink+0x17f>
    dp->nlink--;
8010615a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010615d:	66 8b 40 56          	mov    0x56(%eax),%ax
80106161:	48                   	dec    %eax
80106162:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106165:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80106169:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010616c:	89 04 24             	mov    %eax,(%esp)
8010616f:	e8 ef b6 ff ff       	call   80101863 <iupdate>
  }
  iunlockput(dp);
80106174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106177:	89 04 24             	mov    %eax,(%esp)
8010617a:	e8 a6 ba ff ff       	call   80101c25 <iunlockput>

  ip->nlink--;
8010617f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106182:	66 8b 40 56          	mov    0x56(%eax),%ax
80106186:	48                   	dec    %eax
80106187:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010618a:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
8010618e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106191:	89 04 24             	mov    %eax,(%esp)
80106194:	e8 ca b6 ff ff       	call   80101863 <iupdate>
  iunlockput(ip);
80106199:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010619c:	89 04 24             	mov    %eax,(%esp)
8010619f:	e8 81 ba ff ff       	call   80101c25 <iunlockput>

  end_op();
801061a4:	e8 f8 d3 ff ff       	call   801035a1 <end_op>

  return 0;
801061a9:	b8 00 00 00 00       	mov    $0x0,%eax
801061ae:	eb 15                	jmp    801061c5 <sys_unlink+0x1d0>

bad:
  iunlockput(dp);
801061b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061b3:	89 04 24             	mov    %eax,(%esp)
801061b6:	e8 6a ba ff ff       	call   80101c25 <iunlockput>
  end_op();
801061bb:	e8 e1 d3 ff ff       	call   801035a1 <end_op>
  return -1;
801061c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801061c5:	c9                   	leave  
801061c6:	c3                   	ret    

801061c7 <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
801061c7:	55                   	push   %ebp
801061c8:	89 e5                	mov    %esp,%ebp
801061ca:	83 ec 48             	sub    $0x48,%esp
801061cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801061d0:	8b 55 10             	mov    0x10(%ebp),%edx
801061d3:	8b 45 14             	mov    0x14(%ebp),%eax
801061d6:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801061da:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801061de:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801061e2:	8d 45 de             	lea    -0x22(%ebp),%eax
801061e5:	89 44 24 04          	mov    %eax,0x4(%esp)
801061e9:	8b 45 08             	mov    0x8(%ebp),%eax
801061ec:	89 04 24             	mov    %eax,(%esp)
801061ef:	e8 79 c3 ff ff       	call   8010256d <nameiparent>
801061f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
801061f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801061fb:	75 0a                	jne    80106207 <create+0x40>
    return 0;
801061fd:	b8 00 00 00 00       	mov    $0x0,%eax
80106202:	e9 79 01 00 00       	jmp    80106380 <create+0x1b9>
  ilock(dp);
80106207:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010620a:	89 04 24             	mov    %eax,(%esp)
8010620d:	e8 14 b8 ff ff       	call   80101a26 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80106212:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106215:	89 44 24 08          	mov    %eax,0x8(%esp)
80106219:	8d 45 de             	lea    -0x22(%ebp),%eax
8010621c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106220:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106223:	89 04 24             	mov    %eax,(%esp)
80106226:	e8 a7 bf ff ff       	call   801021d2 <dirlookup>
8010622b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010622e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106232:	74 46                	je     8010627a <create+0xb3>
    iunlockput(dp);
80106234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106237:	89 04 24             	mov    %eax,(%esp)
8010623a:	e8 e6 b9 ff ff       	call   80101c25 <iunlockput>
    ilock(ip);
8010623f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106242:	89 04 24             	mov    %eax,(%esp)
80106245:	e8 dc b7 ff ff       	call   80101a26 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
8010624a:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010624f:	75 14                	jne    80106265 <create+0x9e>
80106251:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106254:	8b 40 50             	mov    0x50(%eax),%eax
80106257:	66 83 f8 02          	cmp    $0x2,%ax
8010625b:	75 08                	jne    80106265 <create+0x9e>
      return ip;
8010625d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106260:	e9 1b 01 00 00       	jmp    80106380 <create+0x1b9>
    iunlockput(ip);
80106265:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106268:	89 04 24             	mov    %eax,(%esp)
8010626b:	e8 b5 b9 ff ff       	call   80101c25 <iunlockput>
    return 0;
80106270:	b8 00 00 00 00       	mov    $0x0,%eax
80106275:	e9 06 01 00 00       	jmp    80106380 <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010627a:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010627e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106281:	8b 00                	mov    (%eax),%eax
80106283:	89 54 24 04          	mov    %edx,0x4(%esp)
80106287:	89 04 24             	mov    %eax,(%esp)
8010628a:	e8 02 b5 ff ff       	call   80101791 <ialloc>
8010628f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106292:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106296:	75 0c                	jne    801062a4 <create+0xdd>
    panic("create: ialloc");
80106298:	c7 04 24 24 92 10 80 	movl   $0x80109224,(%esp)
8010629f:	e8 b0 a2 ff ff       	call   80100554 <panic>

  ilock(ip);
801062a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062a7:	89 04 24             	mov    %eax,(%esp)
801062aa:	e8 77 b7 ff ff       	call   80101a26 <ilock>
  ip->major = major;
801062af:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062b2:	8b 45 d0             	mov    -0x30(%ebp),%eax
801062b5:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
801062b9:	8b 55 f0             	mov    -0x10(%ebp),%edx
801062bc:	8b 45 cc             	mov    -0x34(%ebp),%eax
801062bf:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
801062c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062c6:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
801062cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062cf:	89 04 24             	mov    %eax,(%esp)
801062d2:	e8 8c b5 ff ff       	call   80101863 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
801062d7:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801062dc:	75 68                	jne    80106346 <create+0x17f>
    dp->nlink++;  // for ".."
801062de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e1:	66 8b 40 56          	mov    0x56(%eax),%ax
801062e5:	40                   	inc    %eax
801062e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801062e9:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
801062ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062f0:	89 04 24             	mov    %eax,(%esp)
801062f3:	e8 6b b5 ff ff       	call   80101863 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801062f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801062fb:	8b 40 04             	mov    0x4(%eax),%eax
801062fe:	89 44 24 08          	mov    %eax,0x8(%esp)
80106302:	c7 44 24 04 fe 91 10 	movl   $0x801091fe,0x4(%esp)
80106309:	80 
8010630a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010630d:	89 04 24             	mov    %eax,(%esp)
80106310:	e8 83 bf ff ff       	call   80102298 <dirlink>
80106315:	85 c0                	test   %eax,%eax
80106317:	78 21                	js     8010633a <create+0x173>
80106319:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010631c:	8b 40 04             	mov    0x4(%eax),%eax
8010631f:	89 44 24 08          	mov    %eax,0x8(%esp)
80106323:	c7 44 24 04 00 92 10 	movl   $0x80109200,0x4(%esp)
8010632a:	80 
8010632b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010632e:	89 04 24             	mov    %eax,(%esp)
80106331:	e8 62 bf ff ff       	call   80102298 <dirlink>
80106336:	85 c0                	test   %eax,%eax
80106338:	79 0c                	jns    80106346 <create+0x17f>
      panic("create dots");
8010633a:	c7 04 24 33 92 10 80 	movl   $0x80109233,(%esp)
80106341:	e8 0e a2 ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106346:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106349:	8b 40 04             	mov    0x4(%eax),%eax
8010634c:	89 44 24 08          	mov    %eax,0x8(%esp)
80106350:	8d 45 de             	lea    -0x22(%ebp),%eax
80106353:	89 44 24 04          	mov    %eax,0x4(%esp)
80106357:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010635a:	89 04 24             	mov    %eax,(%esp)
8010635d:	e8 36 bf ff ff       	call   80102298 <dirlink>
80106362:	85 c0                	test   %eax,%eax
80106364:	79 0c                	jns    80106372 <create+0x1ab>
    panic("create: dirlink");
80106366:	c7 04 24 3f 92 10 80 	movl   $0x8010923f,(%esp)
8010636d:	e8 e2 a1 ff ff       	call   80100554 <panic>

  iunlockput(dp);
80106372:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106375:	89 04 24             	mov    %eax,(%esp)
80106378:	e8 a8 b8 ff ff       	call   80101c25 <iunlockput>

  return ip;
8010637d:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106380:	c9                   	leave  
80106381:	c3                   	ret    

80106382 <sys_open>:

int
sys_open(void)
{
80106382:	55                   	push   %ebp
80106383:	89 e5                	mov    %esp,%ebp
80106385:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80106388:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010638b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010638f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106396:	e8 f1 f6 ff ff       	call   80105a8c <argstr>
8010639b:	85 c0                	test   %eax,%eax
8010639d:	78 17                	js     801063b6 <sys_open+0x34>
8010639f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801063a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801063a6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801063ad:	e8 43 f6 ff ff       	call   801059f5 <argint>
801063b2:	85 c0                	test   %eax,%eax
801063b4:	79 0a                	jns    801063c0 <sys_open+0x3e>
    return -1;
801063b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063bb:	e9 5b 01 00 00       	jmp    8010651b <sys_open+0x199>

  begin_op();
801063c0:	e8 5a d1 ff ff       	call   8010351f <begin_op>

  if(omode & O_CREATE){
801063c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801063c8:	25 00 02 00 00       	and    $0x200,%eax
801063cd:	85 c0                	test   %eax,%eax
801063cf:	74 3b                	je     8010640c <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
801063d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801063d4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801063db:	00 
801063dc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801063e3:	00 
801063e4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
801063eb:	00 
801063ec:	89 04 24             	mov    %eax,(%esp)
801063ef:	e8 d3 fd ff ff       	call   801061c7 <create>
801063f4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801063f7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801063fb:	75 6a                	jne    80106467 <sys_open+0xe5>
      end_op();
801063fd:	e8 9f d1 ff ff       	call   801035a1 <end_op>
      return -1;
80106402:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106407:	e9 0f 01 00 00       	jmp    8010651b <sys_open+0x199>
    }
  } else {
    if((ip = namei(path)) == 0){
8010640c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010640f:	89 04 24             	mov    %eax,(%esp)
80106412:	e8 34 c1 ff ff       	call   8010254b <namei>
80106417:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010641a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010641e:	75 0f                	jne    8010642f <sys_open+0xad>
      end_op();
80106420:	e8 7c d1 ff ff       	call   801035a1 <end_op>
      return -1;
80106425:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010642a:	e9 ec 00 00 00       	jmp    8010651b <sys_open+0x199>
    }
    ilock(ip);
8010642f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106432:	89 04 24             	mov    %eax,(%esp)
80106435:	e8 ec b5 ff ff       	call   80101a26 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
8010643a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010643d:	8b 40 50             	mov    0x50(%eax),%eax
80106440:	66 83 f8 01          	cmp    $0x1,%ax
80106444:	75 21                	jne    80106467 <sys_open+0xe5>
80106446:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106449:	85 c0                	test   %eax,%eax
8010644b:	74 1a                	je     80106467 <sys_open+0xe5>
      iunlockput(ip);
8010644d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106450:	89 04 24             	mov    %eax,(%esp)
80106453:	e8 cd b7 ff ff       	call   80101c25 <iunlockput>
      end_op();
80106458:	e8 44 d1 ff ff       	call   801035a1 <end_op>
      return -1;
8010645d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106462:	e9 b4 00 00 00       	jmp    8010651b <sys_open+0x199>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106467:	e8 f8 ab ff ff       	call   80101064 <filealloc>
8010646c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010646f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106473:	74 14                	je     80106489 <sys_open+0x107>
80106475:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106478:	89 04 24             	mov    %eax,(%esp)
8010647b:	e8 40 f7 ff ff       	call   80105bc0 <fdalloc>
80106480:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106483:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80106487:	79 28                	jns    801064b1 <sys_open+0x12f>
    if(f)
80106489:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010648d:	74 0b                	je     8010649a <sys_open+0x118>
      fileclose(f);
8010648f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106492:	89 04 24             	mov    %eax,(%esp)
80106495:	e8 72 ac ff ff       	call   8010110c <fileclose>
    iunlockput(ip);
8010649a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010649d:	89 04 24             	mov    %eax,(%esp)
801064a0:	e8 80 b7 ff ff       	call   80101c25 <iunlockput>
    end_op();
801064a5:	e8 f7 d0 ff ff       	call   801035a1 <end_op>
    return -1;
801064aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064af:	eb 6a                	jmp    8010651b <sys_open+0x199>
  }
  iunlock(ip);
801064b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064b4:	89 04 24             	mov    %eax,(%esp)
801064b7:	e8 74 b6 ff ff       	call   80101b30 <iunlock>
  end_op();
801064bc:	e8 e0 d0 ff ff       	call   801035a1 <end_op>

  f->type = FD_INODE;
801064c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064c4:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801064ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064d0:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801064d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064d6:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801064dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064e0:	83 e0 01             	and    $0x1,%eax
801064e3:	85 c0                	test   %eax,%eax
801064e5:	0f 94 c0             	sete   %al
801064e8:	88 c2                	mov    %al,%dl
801064ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064ed:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801064f0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064f3:	83 e0 01             	and    $0x1,%eax
801064f6:	85 c0                	test   %eax,%eax
801064f8:	75 0a                	jne    80106504 <sys_open+0x182>
801064fa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801064fd:	83 e0 02             	and    $0x2,%eax
80106500:	85 c0                	test   %eax,%eax
80106502:	74 07                	je     8010650b <sys_open+0x189>
80106504:	b8 01 00 00 00       	mov    $0x1,%eax
80106509:	eb 05                	jmp    80106510 <sys_open+0x18e>
8010650b:	b8 00 00 00 00       	mov    $0x0,%eax
80106510:	88 c2                	mov    %al,%dl
80106512:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106515:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
80106518:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
8010651b:	c9                   	leave  
8010651c:	c3                   	ret    

8010651d <sys_mkdir>:

int
sys_mkdir(void)
{
8010651d:	55                   	push   %ebp
8010651e:	89 e5                	mov    %esp,%ebp
80106520:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106523:	e8 f7 cf ff ff       	call   8010351f <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80106528:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010652b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010652f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106536:	e8 51 f5 ff ff       	call   80105a8c <argstr>
8010653b:	85 c0                	test   %eax,%eax
8010653d:	78 2c                	js     8010656b <sys_mkdir+0x4e>
8010653f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106542:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
80106549:	00 
8010654a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106551:	00 
80106552:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80106559:	00 
8010655a:	89 04 24             	mov    %eax,(%esp)
8010655d:	e8 65 fc ff ff       	call   801061c7 <create>
80106562:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106565:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106569:	75 0c                	jne    80106577 <sys_mkdir+0x5a>
    end_op();
8010656b:	e8 31 d0 ff ff       	call   801035a1 <end_op>
    return -1;
80106570:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106575:	eb 15                	jmp    8010658c <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106577:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010657a:	89 04 24             	mov    %eax,(%esp)
8010657d:	e8 a3 b6 ff ff       	call   80101c25 <iunlockput>
  end_op();
80106582:	e8 1a d0 ff ff       	call   801035a1 <end_op>
  return 0;
80106587:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010658c:	c9                   	leave  
8010658d:	c3                   	ret    

8010658e <sys_mknod>:

int
sys_mknod(void)
{
8010658e:	55                   	push   %ebp
8010658f:	89 e5                	mov    %esp,%ebp
80106591:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106594:	e8 86 cf ff ff       	call   8010351f <begin_op>
  if((argstr(0, &path)) < 0 ||
80106599:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010659c:	89 44 24 04          	mov    %eax,0x4(%esp)
801065a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801065a7:	e8 e0 f4 ff ff       	call   80105a8c <argstr>
801065ac:	85 c0                	test   %eax,%eax
801065ae:	78 5e                	js     8010660e <sys_mknod+0x80>
     argint(1, &major) < 0 ||
801065b0:	8d 45 ec             	lea    -0x14(%ebp),%eax
801065b3:	89 44 24 04          	mov    %eax,0x4(%esp)
801065b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801065be:	e8 32 f4 ff ff       	call   801059f5 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
801065c3:	85 c0                	test   %eax,%eax
801065c5:	78 47                	js     8010660e <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801065c7:	8d 45 e8             	lea    -0x18(%ebp),%eax
801065ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801065ce:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801065d5:	e8 1b f4 ff ff       	call   801059f5 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801065da:	85 c0                	test   %eax,%eax
801065dc:	78 30                	js     8010660e <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801065de:	8b 45 e8             	mov    -0x18(%ebp),%eax
801065e1:	0f bf c8             	movswl %ax,%ecx
801065e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065e7:	0f bf d0             	movswl %ax,%edx
801065ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801065ed:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801065f1:	89 54 24 08          	mov    %edx,0x8(%esp)
801065f5:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801065fc:	00 
801065fd:	89 04 24             	mov    %eax,(%esp)
80106600:	e8 c2 fb ff ff       	call   801061c7 <create>
80106605:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106608:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010660c:	75 0c                	jne    8010661a <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
8010660e:	e8 8e cf ff ff       	call   801035a1 <end_op>
    return -1;
80106613:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106618:	eb 15                	jmp    8010662f <sys_mknod+0xa1>
  }
  iunlockput(ip);
8010661a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010661d:	89 04 24             	mov    %eax,(%esp)
80106620:	e8 00 b6 ff ff       	call   80101c25 <iunlockput>
  end_op();
80106625:	e8 77 cf ff ff       	call   801035a1 <end_op>
  return 0;
8010662a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010662f:	c9                   	leave  
80106630:	c3                   	ret    

80106631 <sys_chdir>:

int
sys_chdir(void)
{
80106631:	55                   	push   %ebp
80106632:	89 e5                	mov    %esp,%ebp
80106634:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106637:	e8 e0 da ff ff       	call   8010411c <myproc>
8010663c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
8010663f:	e8 db ce ff ff       	call   8010351f <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106644:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106647:	89 44 24 04          	mov    %eax,0x4(%esp)
8010664b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106652:	e8 35 f4 ff ff       	call   80105a8c <argstr>
80106657:	85 c0                	test   %eax,%eax
80106659:	78 14                	js     8010666f <sys_chdir+0x3e>
8010665b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010665e:	89 04 24             	mov    %eax,(%esp)
80106661:	e8 e5 be ff ff       	call   8010254b <namei>
80106666:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106669:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010666d:	75 18                	jne    80106687 <sys_chdir+0x56>
    cprintf("cant pick up path\n");
8010666f:	c7 04 24 4f 92 10 80 	movl   $0x8010924f,(%esp)
80106676:	e8 46 9d ff ff       	call   801003c1 <cprintf>
    end_op();
8010667b:	e8 21 cf ff ff       	call   801035a1 <end_op>
    return -1;
80106680:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106685:	eb 66                	jmp    801066ed <sys_chdir+0xbc>
  }
  ilock(ip);
80106687:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010668a:	89 04 24             	mov    %eax,(%esp)
8010668d:	e8 94 b3 ff ff       	call   80101a26 <ilock>
  if(ip->type != T_DIR){
80106692:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106695:	8b 40 50             	mov    0x50(%eax),%eax
80106698:	66 83 f8 01          	cmp    $0x1,%ax
8010669c:	74 23                	je     801066c1 <sys_chdir+0x90>
    // TODO: REMOVE
    cprintf("not a dir\n");
8010669e:	c7 04 24 62 92 10 80 	movl   $0x80109262,(%esp)
801066a5:	e8 17 9d ff ff       	call   801003c1 <cprintf>
    iunlockput(ip);
801066aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066ad:	89 04 24             	mov    %eax,(%esp)
801066b0:	e8 70 b5 ff ff       	call   80101c25 <iunlockput>
    end_op();
801066b5:	e8 e7 ce ff ff       	call   801035a1 <end_op>
    return -1;
801066ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066bf:	eb 2c                	jmp    801066ed <sys_chdir+0xbc>
  }
  iunlock(ip);
801066c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066c4:	89 04 24             	mov    %eax,(%esp)
801066c7:	e8 64 b4 ff ff       	call   80101b30 <iunlock>
  iput(curproc->cwd);
801066cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066cf:	8b 40 68             	mov    0x68(%eax),%eax
801066d2:	89 04 24             	mov    %eax,(%esp)
801066d5:	e8 9a b4 ff ff       	call   80101b74 <iput>
  end_op();
801066da:	e8 c2 ce ff ff       	call   801035a1 <end_op>
  curproc->cwd = ip;
801066df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066e2:	8b 55 f0             	mov    -0x10(%ebp),%edx
801066e5:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801066e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801066ed:	c9                   	leave  
801066ee:	c3                   	ret    

801066ef <sys_exec>:

int
sys_exec(void)
{
801066ef:	55                   	push   %ebp
801066f0:	89 e5                	mov    %esp,%ebp
801066f2:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801066f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801066ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106706:	e8 81 f3 ff ff       	call   80105a8c <argstr>
8010670b:	85 c0                	test   %eax,%eax
8010670d:	78 1a                	js     80106729 <sys_exec+0x3a>
8010670f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106715:	89 44 24 04          	mov    %eax,0x4(%esp)
80106719:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106720:	e8 d0 f2 ff ff       	call   801059f5 <argint>
80106725:	85 c0                	test   %eax,%eax
80106727:	79 0a                	jns    80106733 <sys_exec+0x44>
    return -1;
80106729:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010672e:	e9 c7 00 00 00       	jmp    801067fa <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
80106733:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010673a:	00 
8010673b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106742:	00 
80106743:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106749:	89 04 24             	mov    %eax,(%esp)
8010674c:	e8 71 ef ff ff       	call   801056c2 <memset>
  for(i=0;; i++){
80106751:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010675b:	83 f8 1f             	cmp    $0x1f,%eax
8010675e:	76 0a                	jbe    8010676a <sys_exec+0x7b>
      return -1;
80106760:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106765:	e9 90 00 00 00       	jmp    801067fa <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
8010676a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010676d:	c1 e0 02             	shl    $0x2,%eax
80106770:	89 c2                	mov    %eax,%edx
80106772:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106778:	01 c2                	add    %eax,%edx
8010677a:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106780:	89 44 24 04          	mov    %eax,0x4(%esp)
80106784:	89 14 24             	mov    %edx,(%esp)
80106787:	e8 c8 f1 ff ff       	call   80105954 <fetchint>
8010678c:	85 c0                	test   %eax,%eax
8010678e:	79 07                	jns    80106797 <sys_exec+0xa8>
      return -1;
80106790:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106795:	eb 63                	jmp    801067fa <sys_exec+0x10b>
    if(uarg == 0){
80106797:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
8010679d:	85 c0                	test   %eax,%eax
8010679f:	75 26                	jne    801067c7 <sys_exec+0xd8>
      argv[i] = 0;
801067a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067a4:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801067ab:	00 00 00 00 
      break;
801067af:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801067b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067b3:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801067b9:	89 54 24 04          	mov    %edx,0x4(%esp)
801067bd:	89 04 24             	mov    %eax,(%esp)
801067c0:	e8 43 a4 ff ff       	call   80100c08 <exec>
801067c5:	eb 33                	jmp    801067fa <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801067c7:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801067cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067d0:	c1 e2 02             	shl    $0x2,%edx
801067d3:	01 c2                	add    %eax,%edx
801067d5:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801067db:	89 54 24 04          	mov    %edx,0x4(%esp)
801067df:	89 04 24             	mov    %eax,(%esp)
801067e2:	e8 ac f1 ff ff       	call   80105993 <fetchstr>
801067e7:	85 c0                	test   %eax,%eax
801067e9:	79 07                	jns    801067f2 <sys_exec+0x103>
      return -1;
801067eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067f0:	eb 08                	jmp    801067fa <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801067f2:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801067f5:	e9 5e ff ff ff       	jmp    80106758 <sys_exec+0x69>
  return exec(path, argv);
}
801067fa:	c9                   	leave  
801067fb:	c3                   	ret    

801067fc <sys_pipe>:

int
sys_pipe(void)
{
801067fc:	55                   	push   %ebp
801067fd:	89 e5                	mov    %esp,%ebp
801067ff:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106802:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106809:	00 
8010680a:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010680d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106811:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106818:	e8 05 f2 ff ff       	call   80105a22 <argptr>
8010681d:	85 c0                	test   %eax,%eax
8010681f:	79 0a                	jns    8010682b <sys_pipe+0x2f>
    return -1;
80106821:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106826:	e9 9a 00 00 00       	jmp    801068c5 <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
8010682b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010682e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106832:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106835:	89 04 24             	mov    %eax,(%esp)
80106838:	e8 2f d5 ff ff       	call   80103d6c <pipealloc>
8010683d:	85 c0                	test   %eax,%eax
8010683f:	79 07                	jns    80106848 <sys_pipe+0x4c>
    return -1;
80106841:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106846:	eb 7d                	jmp    801068c5 <sys_pipe+0xc9>
  fd0 = -1;
80106848:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
8010684f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106852:	89 04 24             	mov    %eax,(%esp)
80106855:	e8 66 f3 ff ff       	call   80105bc0 <fdalloc>
8010685a:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010685d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106861:	78 14                	js     80106877 <sys_pipe+0x7b>
80106863:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106866:	89 04 24             	mov    %eax,(%esp)
80106869:	e8 52 f3 ff ff       	call   80105bc0 <fdalloc>
8010686e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106871:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106875:	79 36                	jns    801068ad <sys_pipe+0xb1>
    if(fd0 >= 0)
80106877:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010687b:	78 13                	js     80106890 <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
8010687d:	e8 9a d8 ff ff       	call   8010411c <myproc>
80106882:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106885:	83 c2 08             	add    $0x8,%edx
80106888:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010688f:	00 
    fileclose(rf);
80106890:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106893:	89 04 24             	mov    %eax,(%esp)
80106896:	e8 71 a8 ff ff       	call   8010110c <fileclose>
    fileclose(wf);
8010689b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010689e:	89 04 24             	mov    %eax,(%esp)
801068a1:	e8 66 a8 ff ff       	call   8010110c <fileclose>
    return -1;
801068a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068ab:	eb 18                	jmp    801068c5 <sys_pipe+0xc9>
  }
  fd[0] = fd0;
801068ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
801068b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801068b3:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801068b5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801068b8:	8d 50 04             	lea    0x4(%eax),%edx
801068bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801068be:	89 02                	mov    %eax,(%edx)
  return 0;
801068c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068c5:	c9                   	leave  
801068c6:	c3                   	ret    

801068c7 <sys_ccreate>:

int
sys_ccreate(void)
{
801068c7:	55                   	push   %ebp
801068c8:	89 e5                	mov    %esp,%ebp
801068ca:	56                   	push   %esi
801068cb:	53                   	push   %ebx
801068cc:	81 ec c0 00 00 00    	sub    $0xc0,%esp

  char *name, *argv[MAXARG];
  int i, progc, mproc;
  uint uargv, uarg, msz, mdsk;

  if(argstr(0, &name) < 0 || argint(2, &progc) < 0 || argint(3, &mproc) < 0 
801068d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801068d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801068d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801068e0:	e8 a7 f1 ff ff       	call   80105a8c <argstr>
801068e5:	85 c0                	test   %eax,%eax
801068e7:	78 68                	js     80106951 <sys_ccreate+0x8a>
801068e9:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801068ef:	89 44 24 04          	mov    %eax,0x4(%esp)
801068f3:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801068fa:	e8 f6 f0 ff ff       	call   801059f5 <argint>
801068ff:	85 c0                	test   %eax,%eax
80106901:	78 4e                	js     80106951 <sys_ccreate+0x8a>
80106903:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106909:	89 44 24 04          	mov    %eax,0x4(%esp)
8010690d:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
80106914:	e8 dc f0 ff ff       	call   801059f5 <argint>
80106919:	85 c0                	test   %eax,%eax
8010691b:	78 34                	js     80106951 <sys_ccreate+0x8a>
    || argint(4, (int*)&msz) < 0 || argint(5, (int*)&mdsk) < 0) {
8010691d:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
80106923:	89 44 24 04          	mov    %eax,0x4(%esp)
80106927:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
8010692e:	e8 c2 f0 ff ff       	call   801059f5 <argint>
80106933:	85 c0                	test   %eax,%eax
80106935:	78 1a                	js     80106951 <sys_ccreate+0x8a>
80106937:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
8010693d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106941:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
80106948:	e8 a8 f0 ff ff       	call   801059f5 <argint>
8010694d:	85 c0                	test   %eax,%eax
8010694f:	79 16                	jns    80106967 <sys_ccreate+0xa0>
    cprintf("sys_ccreate: Error getting pointers\n");
80106951:	c7 04 24 70 92 10 80 	movl   $0x80109270,(%esp)
80106958:	e8 64 9a ff ff       	call   801003c1 <cprintf>
    return -1;
8010695d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106962:	e9 80 01 00 00       	jmp    80106ae7 <sys_ccreate+0x220>
  }

  if(argint(1, (int*)&uargv) < 0){
80106967:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
8010696d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106971:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106978:	e8 78 f0 ff ff       	call   801059f5 <argint>
8010697d:	85 c0                	test   %eax,%eax
8010697f:	79 0a                	jns    8010698b <sys_ccreate+0xc4>
    return -1;
80106981:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106986:	e9 5c 01 00 00       	jmp    80106ae7 <sys_ccreate+0x220>
  }
  memset(argv, 0, sizeof(argv));
8010698b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106992:	00 
80106993:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010699a:	00 
8010699b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801069a1:	89 04 24             	mov    %eax,(%esp)
801069a4:	e8 19 ed ff ff       	call   801056c2 <memset>
  for(i=0;; i++){
801069a9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801069b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069b3:	83 f8 1f             	cmp    $0x1f,%eax
801069b6:	76 0a                	jbe    801069c2 <sys_ccreate+0xfb>
      return -1;
801069b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069bd:	e9 25 01 00 00       	jmp    80106ae7 <sys_ccreate+0x220>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
801069c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069c5:	c1 e0 02             	shl    $0x2,%eax
801069c8:	89 c2                	mov    %eax,%edx
801069ca:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
801069d0:	01 c2                	add    %eax,%edx
801069d2:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
801069d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801069dc:	89 14 24             	mov    %edx,(%esp)
801069df:	e8 70 ef ff ff       	call   80105954 <fetchint>
801069e4:	85 c0                	test   %eax,%eax
801069e6:	79 0a                	jns    801069f2 <sys_ccreate+0x12b>
      return -1;
801069e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069ed:	e9 f5 00 00 00       	jmp    80106ae7 <sys_ccreate+0x220>
    if(uarg == 0){
801069f2:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
801069f8:	85 c0                	test   %eax,%eax
801069fa:	75 53                	jne    80106a4f <sys_ccreate+0x188>
      argv[i] = 0;
801069fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801069ff:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106a06:	00 00 00 00 
      break;
80106a0a:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_create\nuargv: %d\nname: %s\nmproc: %d\nmsz: %d\nmdsk: %d\n", uargv, name, mproc, msz, mdsk);
80106a0b:	8b b5 58 ff ff ff    	mov    -0xa8(%ebp),%esi
80106a11:	8b 9d 5c ff ff ff    	mov    -0xa4(%ebp),%ebx
80106a17:	8b 8d 68 ff ff ff    	mov    -0x98(%ebp),%ecx
80106a1d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106a20:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80106a26:	89 74 24 14          	mov    %esi,0x14(%esp)
80106a2a:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106a2e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106a32:	89 54 24 08          	mov    %edx,0x8(%esp)
80106a36:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a3a:	c7 04 24 98 92 10 80 	movl   $0x80109298,(%esp)
80106a41:	e8 7b 99 ff ff       	call   801003c1 <cprintf>
  for (i = 0; i < progc; i++) 
80106a46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106a4d:	eb 50                	jmp    80106a9f <sys_ccreate+0x1d8>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106a4f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106a55:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106a58:	c1 e2 02             	shl    $0x2,%edx
80106a5b:	01 c2                	add    %eax,%edx
80106a5d:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80106a63:	89 54 24 04          	mov    %edx,0x4(%esp)
80106a67:	89 04 24             	mov    %eax,(%esp)
80106a6a:	e8 24 ef ff ff       	call   80105993 <fetchstr>
80106a6f:	85 c0                	test   %eax,%eax
80106a71:	79 07                	jns    80106a7a <sys_ccreate+0x1b3>
      return -1;
80106a73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a78:	eb 6d                	jmp    80106ae7 <sys_ccreate+0x220>

  if(argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106a7a:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106a7d:	e9 2e ff ff ff       	jmp    801069b0 <sys_ccreate+0xe9>

  cprintf("sys_create\nuargv: %d\nname: %s\nmproc: %d\nmsz: %d\nmdsk: %d\n", uargv, name, mproc, msz, mdsk);
  for (i = 0; i < progc; i++) 
    cprintf("\t%s\n", argv[i]);
80106a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a85:	8b 84 85 70 ff ff ff 	mov    -0x90(%ebp,%eax,4),%eax
80106a8c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a90:	c7 04 24 d2 92 10 80 	movl   $0x801092d2,(%esp)
80106a97:	e8 25 99 ff ff       	call   801003c1 <cprintf>
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_create\nuargv: %d\nname: %s\nmproc: %d\nmsz: %d\nmdsk: %d\n", uargv, name, mproc, msz, mdsk);
  for (i = 0; i < progc; i++) 
80106a9c:	ff 45 f4             	incl   -0xc(%ebp)
80106a9f:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106aa5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80106aa8:	7c d8                	jl     80106a82 <sys_ccreate+0x1bb>
    cprintf("\t%s\n", argv[i]);
  
  return ccreate(name, argv, progc, mproc, msz, mdsk);
80106aaa:	8b b5 58 ff ff ff    	mov    -0xa8(%ebp),%esi
80106ab0:	8b 9d 5c ff ff ff    	mov    -0xa4(%ebp),%ebx
80106ab6:	8b 8d 68 ff ff ff    	mov    -0x98(%ebp),%ecx
80106abc:	8b 95 6c ff ff ff    	mov    -0x94(%ebp),%edx
80106ac2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106ac5:	89 74 24 14          	mov    %esi,0x14(%esp)
80106ac9:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106acd:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106ad1:	89 54 24 08          	mov    %edx,0x8(%esp)
80106ad5:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106adb:	89 54 24 04          	mov    %edx,0x4(%esp)
80106adf:	89 04 24             	mov    %eax,(%esp)
80106ae2:	e8 ae e6 ff ff       	call   80105195 <ccreate>
}
80106ae7:	81 c4 c0 00 00 00    	add    $0xc0,%esp
80106aed:	5b                   	pop    %ebx
80106aee:	5e                   	pop    %esi
80106aef:	5d                   	pop    %ebp
80106af0:	c3                   	ret    

80106af1 <sys_cstart>:

int
sys_cstart(void)
{
80106af1:	55                   	push   %ebp
80106af2:	89 e5                	mov    %esp,%ebp
80106af4:	81 ec b8 00 00 00    	sub    $0xb8,%esp

  char *name, *prog, *argv[MAXARG];
  int i, argc;
  uint uargv, uarg;

  if(argstr(0, &name) < 0 || argstr(1, &prog) < 0 || argint(2, &argc) < 0) {
80106afa:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106afd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106b08:	e8 7f ef ff ff       	call   80105a8c <argstr>
80106b0d:	85 c0                	test   %eax,%eax
80106b0f:	78 31                	js     80106b42 <sys_cstart+0x51>
80106b11:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106b14:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b18:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106b1f:	e8 68 ef ff ff       	call   80105a8c <argstr>
80106b24:	85 c0                	test   %eax,%eax
80106b26:	78 1a                	js     80106b42 <sys_cstart+0x51>
80106b28:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106b2e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b32:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106b39:	e8 b7 ee ff ff       	call   801059f5 <argint>
80106b3e:	85 c0                	test   %eax,%eax
80106b40:	79 16                	jns    80106b58 <sys_cstart+0x67>
    cprintf("sys_ccreate: Error getting pointers\n");
80106b42:	c7 04 24 70 92 10 80 	movl   $0x80109270,(%esp)
80106b49:	e8 73 98 ff ff       	call   801003c1 <cprintf>
    return -1;
80106b4e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b53:	e9 4e 01 00 00       	jmp    80106ca6 <sys_cstart+0x1b5>
  }

  if(argint(1, (int*)&uargv) < 0){
80106b58:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
80106b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106b62:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106b69:	e8 87 ee ff ff       	call   801059f5 <argint>
80106b6e:	85 c0                	test   %eax,%eax
80106b70:	79 0a                	jns    80106b7c <sys_cstart+0x8b>
    return -1;
80106b72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b77:	e9 2a 01 00 00       	jmp    80106ca6 <sys_cstart+0x1b5>
  }
  memset(argv, 0, sizeof(argv));
80106b7c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106b83:	00 
80106b84:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106b8b:	00 
80106b8c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106b92:	89 04 24             	mov    %eax,(%esp)
80106b95:	e8 28 eb ff ff       	call   801056c2 <memset>
  for(i=0;; i++){
80106b9a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ba4:	83 f8 1f             	cmp    $0x1f,%eax
80106ba7:	76 0a                	jbe    80106bb3 <sys_cstart+0xc2>
      return -1;
80106ba9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bae:	e9 f3 00 00 00       	jmp    80106ca6 <sys_cstart+0x1b5>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106bb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bb6:	c1 e0 02             	shl    $0x2,%eax
80106bb9:	89 c2                	mov    %eax,%edx
80106bbb:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80106bc1:	01 c2                	add    %eax,%edx
80106bc3:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
80106bc9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bcd:	89 14 24             	mov    %edx,(%esp)
80106bd0:	e8 7f ed ff ff       	call   80105954 <fetchint>
80106bd5:	85 c0                	test   %eax,%eax
80106bd7:	79 0a                	jns    80106be3 <sys_cstart+0xf2>
      return -1;
80106bd9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bde:	e9 c3 00 00 00       	jmp    80106ca6 <sys_cstart+0x1b5>
    if(uarg == 0){
80106be3:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80106be9:	85 c0                	test   %eax,%eax
80106beb:	75 3f                	jne    80106c2c <sys_cstart+0x13b>
      argv[i] = 0;
80106bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bf0:	c7 84 85 6c ff ff ff 	movl   $0x0,-0x94(%ebp,%eax,4)
80106bf7:	00 00 00 00 
      break;
80106bfb:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_cstart\nuargv: %d\nname: %s\nargc: %d\n", uargv, name, argc);
80106bfc:	8b 8d 68 ff ff ff    	mov    -0x98(%ebp),%ecx
80106c02:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106c05:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80106c0b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106c0f:	89 54 24 08          	mov    %edx,0x8(%esp)
80106c13:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c17:	c7 04 24 d8 92 10 80 	movl   $0x801092d8,(%esp)
80106c1e:	e8 9e 97 ff ff       	call   801003c1 <cprintf>
  for (i = 0; i < argc; i++) 
80106c23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106c2a:	eb 50                	jmp    80106c7c <sys_cstart+0x18b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106c2c:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106c32:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c35:	c1 e2 02             	shl    $0x2,%edx
80106c38:	01 c2                	add    %eax,%edx
80106c3a:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80106c40:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c44:	89 04 24             	mov    %eax,(%esp)
80106c47:	e8 47 ed ff ff       	call   80105993 <fetchstr>
80106c4c:	85 c0                	test   %eax,%eax
80106c4e:	79 07                	jns    80106c57 <sys_cstart+0x166>
      return -1;
80106c50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c55:	eb 4f                	jmp    80106ca6 <sys_cstart+0x1b5>

  if(argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106c57:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106c5a:	e9 42 ff ff ff       	jmp    80106ba1 <sys_cstart+0xb0>

  cprintf("sys_cstart\nuargv: %d\nname: %s\nargc: %d\n", uargv, name, argc);
  for (i = 0; i < argc; i++) 
    cprintf("\t%s\n", argv[i]);
80106c5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c62:	8b 84 85 6c ff ff ff 	mov    -0x94(%ebp,%eax,4),%eax
80106c69:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c6d:	c7 04 24 d2 92 10 80 	movl   $0x801092d2,(%esp)
80106c74:	e8 48 97 ff ff       	call   801003c1 <cprintf>
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_cstart\nuargv: %d\nname: %s\nargc: %d\n", uargv, name, argc);
  for (i = 0; i < argc; i++) 
80106c79:	ff 45 f4             	incl   -0xc(%ebp)
80106c7c:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106c82:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80106c85:	7c d8                	jl     80106c5f <sys_cstart+0x16e>
    cprintf("\t%s\n", argv[i]);
  
  return cstart(name, argv, argc);
80106c87:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
80106c8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c90:	89 54 24 08          	mov    %edx,0x8(%esp)
80106c94:	8d 95 6c ff ff ff    	lea    -0x94(%ebp),%edx
80106c9a:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c9e:	89 04 24             	mov    %eax,(%esp)
80106ca1:	e8 32 e6 ff ff       	call   801052d8 <cstart>
}
80106ca6:	c9                   	leave  
80106ca7:	c3                   	ret    

80106ca8 <sys_cstop>:

int
sys_cstop(void)
{
80106ca8:	55                   	push   %ebp
80106ca9:	89 e5                	mov    %esp,%ebp
  return 1;
80106cab:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106cb0:	5d                   	pop    %ebp
80106cb1:	c3                   	ret    

80106cb2 <sys_cinfo>:

int
sys_cinfo(void)
{
80106cb2:	55                   	push   %ebp
80106cb3:	89 e5                	mov    %esp,%ebp
  return 1;
80106cb5:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106cba:	5d                   	pop    %ebp
80106cbb:	c3                   	ret    

80106cbc <sys_cpause>:

int
sys_cpause(void)
{
80106cbc:	55                   	push   %ebp
80106cbd:	89 e5                	mov    %esp,%ebp
  return 1;
80106cbf:	b8 01 00 00 00       	mov    $0x1,%eax
80106cc4:	5d                   	pop    %ebp
80106cc5:	c3                   	ret    
	...

80106cc8 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80106cc8:	55                   	push   %ebp
80106cc9:	89 e5                	mov    %esp,%ebp
80106ccb:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106cce:	e8 7b d7 ff ff       	call   8010444e <fork>
}
80106cd3:	c9                   	leave  
80106cd4:	c3                   	ret    

80106cd5 <sys_exit>:

int
sys_exit(void)
{
80106cd5:	55                   	push   %ebp
80106cd6:	89 e5                	mov    %esp,%ebp
80106cd8:	83 ec 08             	sub    $0x8,%esp
  exit();
80106cdb:	e8 d2 d8 ff ff       	call   801045b2 <exit>
  return 0;  // not reached
80106ce0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106ce5:	c9                   	leave  
80106ce6:	c3                   	ret    

80106ce7 <sys_wait>:

int
sys_wait(void)
{
80106ce7:	55                   	push   %ebp
80106ce8:	89 e5                	mov    %esp,%ebp
80106cea:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106ced:	e8 f0 d9 ff ff       	call   801046e2 <wait>
}
80106cf2:	c9                   	leave  
80106cf3:	c3                   	ret    

80106cf4 <sys_kill>:

int
sys_kill(void)
{
80106cf4:	55                   	push   %ebp
80106cf5:	89 e5                	mov    %esp,%ebp
80106cf7:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106cfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106cfd:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d01:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d08:	e8 e8 ec ff ff       	call   801059f5 <argint>
80106d0d:	85 c0                	test   %eax,%eax
80106d0f:	79 07                	jns    80106d18 <sys_kill+0x24>
    return -1;
80106d11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d16:	eb 0b                	jmp    80106d23 <sys_kill+0x2f>
  return kill(pid);
80106d18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d1b:	89 04 24             	mov    %eax,(%esp)
80106d1e:	e8 48 dc ff ff       	call   8010496b <kill>
}
80106d23:	c9                   	leave  
80106d24:	c3                   	ret    

80106d25 <sys_getpid>:

int
sys_getpid(void)
{
80106d25:	55                   	push   %ebp
80106d26:	89 e5                	mov    %esp,%ebp
80106d28:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80106d2b:	e8 ec d3 ff ff       	call   8010411c <myproc>
80106d30:	8b 40 10             	mov    0x10(%eax),%eax
}
80106d33:	c9                   	leave  
80106d34:	c3                   	ret    

80106d35 <sys_sbrk>:

int
sys_sbrk(void)
{
80106d35:	55                   	push   %ebp
80106d36:	89 e5                	mov    %esp,%ebp
80106d38:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106d3b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d3e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d42:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d49:	e8 a7 ec ff ff       	call   801059f5 <argint>
80106d4e:	85 c0                	test   %eax,%eax
80106d50:	79 07                	jns    80106d59 <sys_sbrk+0x24>
    return -1;
80106d52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d57:	eb 23                	jmp    80106d7c <sys_sbrk+0x47>
  addr = myproc()->sz;
80106d59:	e8 be d3 ff ff       	call   8010411c <myproc>
80106d5e:	8b 00                	mov    (%eax),%eax
80106d60:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106d63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d66:	89 04 24             	mov    %eax,(%esp)
80106d69:	e8 42 d6 ff ff       	call   801043b0 <growproc>
80106d6e:	85 c0                	test   %eax,%eax
80106d70:	79 07                	jns    80106d79 <sys_sbrk+0x44>
    return -1;
80106d72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d77:	eb 03                	jmp    80106d7c <sys_sbrk+0x47>
  return addr;
80106d79:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106d7c:	c9                   	leave  
80106d7d:	c3                   	ret    

80106d7e <sys_sleep>:

int
sys_sleep(void)
{
80106d7e:	55                   	push   %ebp
80106d7f:	89 e5                	mov    %esp,%ebp
80106d81:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106d84:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d87:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d8b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d92:	e8 5e ec ff ff       	call   801059f5 <argint>
80106d97:	85 c0                	test   %eax,%eax
80106d99:	79 07                	jns    80106da2 <sys_sleep+0x24>
    return -1;
80106d9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106da0:	eb 6b                	jmp    80106e0d <sys_sleep+0x8f>
  acquire(&tickslock);
80106da2:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
80106da9:	e8 b1 e6 ff ff       	call   8010545f <acquire>
  ticks0 = ticks;
80106dae:	a1 40 61 12 80       	mov    0x80126140,%eax
80106db3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106db6:	eb 33                	jmp    80106deb <sys_sleep+0x6d>
    if(myproc()->killed){
80106db8:	e8 5f d3 ff ff       	call   8010411c <myproc>
80106dbd:	8b 40 24             	mov    0x24(%eax),%eax
80106dc0:	85 c0                	test   %eax,%eax
80106dc2:	74 13                	je     80106dd7 <sys_sleep+0x59>
      release(&tickslock);
80106dc4:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
80106dcb:	e8 f9 e6 ff ff       	call   801054c9 <release>
      return -1;
80106dd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106dd5:	eb 36                	jmp    80106e0d <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
80106dd7:	c7 44 24 04 00 59 12 	movl   $0x80125900,0x4(%esp)
80106dde:	80 
80106ddf:	c7 04 24 40 61 12 80 	movl   $0x80126140,(%esp)
80106de6:	e8 75 da ff ff       	call   80104860 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106deb:	a1 40 61 12 80       	mov    0x80126140,%eax
80106df0:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106df3:	89 c2                	mov    %eax,%edx
80106df5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106df8:	39 c2                	cmp    %eax,%edx
80106dfa:	72 bc                	jb     80106db8 <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106dfc:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
80106e03:	e8 c1 e6 ff ff       	call   801054c9 <release>
  return 0;
80106e08:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106e0d:	c9                   	leave  
80106e0e:	c3                   	ret    

80106e0f <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106e0f:	55                   	push   %ebp
80106e10:	89 e5                	mov    %esp,%ebp
80106e12:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
80106e15:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
80106e1c:	e8 3e e6 ff ff       	call   8010545f <acquire>
  xticks = ticks;
80106e21:	a1 40 61 12 80       	mov    0x80126140,%eax
80106e26:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106e29:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
80106e30:	e8 94 e6 ff ff       	call   801054c9 <release>
  return xticks;
80106e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106e38:	c9                   	leave  
80106e39:	c3                   	ret    

80106e3a <sys_getticks>:

int
sys_getticks(void)
{
80106e3a:	55                   	push   %ebp
80106e3b:	89 e5                	mov    %esp,%ebp
80106e3d:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
80106e40:	e8 d7 d2 ff ff       	call   8010411c <myproc>
80106e45:	8b 40 7c             	mov    0x7c(%eax),%eax
}
80106e48:	c9                   	leave  
80106e49:	c3                   	ret    
	...

80106e4c <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106e4c:	1e                   	push   %ds
  pushl %es
80106e4d:	06                   	push   %es
  pushl %fs
80106e4e:	0f a0                	push   %fs
  pushl %gs
80106e50:	0f a8                	push   %gs
  pushal
80106e52:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80106e53:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106e57:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106e59:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80106e5b:	54                   	push   %esp
  call trap
80106e5c:	e8 c0 01 00 00       	call   80107021 <trap>
  addl $4, %esp
80106e61:	83 c4 04             	add    $0x4,%esp

80106e64 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106e64:	61                   	popa   
  popl %gs
80106e65:	0f a9                	pop    %gs
  popl %fs
80106e67:	0f a1                	pop    %fs
  popl %es
80106e69:	07                   	pop    %es
  popl %ds
80106e6a:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106e6b:	83 c4 08             	add    $0x8,%esp
  iret
80106e6e:	cf                   	iret   
	...

80106e70 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106e70:	55                   	push   %ebp
80106e71:	89 e5                	mov    %esp,%ebp
80106e73:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106e76:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e79:	48                   	dec    %eax
80106e7a:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106e7e:	8b 45 08             	mov    0x8(%ebp),%eax
80106e81:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106e85:	8b 45 08             	mov    0x8(%ebp),%eax
80106e88:	c1 e8 10             	shr    $0x10,%eax
80106e8b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106e8f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106e92:	0f 01 18             	lidtl  (%eax)
}
80106e95:	c9                   	leave  
80106e96:	c3                   	ret    

80106e97 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106e97:	55                   	push   %ebp
80106e98:	89 e5                	mov    %esp,%ebp
80106e9a:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106e9d:	0f 20 d0             	mov    %cr2,%eax
80106ea0:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106ea3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106ea6:	c9                   	leave  
80106ea7:	c3                   	ret    

80106ea8 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106ea8:	55                   	push   %ebp
80106ea9:	89 e5                	mov    %esp,%ebp
80106eab:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80106eae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106eb5:	e9 b8 00 00 00       	jmp    80106f72 <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ebd:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
80106ec4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106ec7:	66 89 04 d5 40 59 12 	mov    %ax,-0x7feda6c0(,%edx,8)
80106ece:	80 
80106ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ed2:	66 c7 04 c5 42 59 12 	movw   $0x8,-0x7feda6be(,%eax,8)
80106ed9:	80 08 00 
80106edc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106edf:	8a 14 c5 44 59 12 80 	mov    -0x7feda6bc(,%eax,8),%dl
80106ee6:	83 e2 e0             	and    $0xffffffe0,%edx
80106ee9:	88 14 c5 44 59 12 80 	mov    %dl,-0x7feda6bc(,%eax,8)
80106ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ef3:	8a 14 c5 44 59 12 80 	mov    -0x7feda6bc(,%eax,8),%dl
80106efa:	83 e2 1f             	and    $0x1f,%edx
80106efd:	88 14 c5 44 59 12 80 	mov    %dl,-0x7feda6bc(,%eax,8)
80106f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f07:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
80106f0e:	83 e2 f0             	and    $0xfffffff0,%edx
80106f11:	83 ca 0e             	or     $0xe,%edx
80106f14:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
80106f1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f1e:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
80106f25:	83 e2 ef             	and    $0xffffffef,%edx
80106f28:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
80106f2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f32:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
80106f39:	83 e2 9f             	and    $0xffffff9f,%edx
80106f3c:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
80106f43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f46:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
80106f4d:	83 ca 80             	or     $0xffffff80,%edx
80106f50:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
80106f57:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f5a:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
80106f61:	c1 e8 10             	shr    $0x10,%eax
80106f64:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106f67:	66 89 04 d5 46 59 12 	mov    %ax,-0x7feda6ba(,%edx,8)
80106f6e:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106f6f:	ff 45 f4             	incl   -0xc(%ebp)
80106f72:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80106f79:	0f 8e 3b ff ff ff    	jle    80106eba <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106f7f:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
80106f84:	66 a3 40 5b 12 80    	mov    %ax,0x80125b40
80106f8a:	66 c7 05 42 5b 12 80 	movw   $0x8,0x80125b42
80106f91:	08 00 
80106f93:	a0 44 5b 12 80       	mov    0x80125b44,%al
80106f98:	83 e0 e0             	and    $0xffffffe0,%eax
80106f9b:	a2 44 5b 12 80       	mov    %al,0x80125b44
80106fa0:	a0 44 5b 12 80       	mov    0x80125b44,%al
80106fa5:	83 e0 1f             	and    $0x1f,%eax
80106fa8:	a2 44 5b 12 80       	mov    %al,0x80125b44
80106fad:	a0 45 5b 12 80       	mov    0x80125b45,%al
80106fb2:	83 c8 0f             	or     $0xf,%eax
80106fb5:	a2 45 5b 12 80       	mov    %al,0x80125b45
80106fba:	a0 45 5b 12 80       	mov    0x80125b45,%al
80106fbf:	83 e0 ef             	and    $0xffffffef,%eax
80106fc2:	a2 45 5b 12 80       	mov    %al,0x80125b45
80106fc7:	a0 45 5b 12 80       	mov    0x80125b45,%al
80106fcc:	83 c8 60             	or     $0x60,%eax
80106fcf:	a2 45 5b 12 80       	mov    %al,0x80125b45
80106fd4:	a0 45 5b 12 80       	mov    0x80125b45,%al
80106fd9:	83 c8 80             	or     $0xffffff80,%eax
80106fdc:	a2 45 5b 12 80       	mov    %al,0x80125b45
80106fe1:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
80106fe6:	c1 e8 10             	shr    $0x10,%eax
80106fe9:	66 a3 46 5b 12 80    	mov    %ax,0x80125b46

  initlock(&tickslock, "time");
80106fef:	c7 44 24 04 00 93 10 	movl   $0x80109300,0x4(%esp)
80106ff6:	80 
80106ff7:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
80106ffe:	e8 3b e4 ff ff       	call   8010543e <initlock>
}
80107003:	c9                   	leave  
80107004:	c3                   	ret    

80107005 <idtinit>:

void
idtinit(void)
{
80107005:	55                   	push   %ebp
80107006:	89 e5                	mov    %esp,%ebp
80107008:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
8010700b:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
80107012:	00 
80107013:	c7 04 24 40 59 12 80 	movl   $0x80125940,(%esp)
8010701a:	e8 51 fe ff ff       	call   80106e70 <lidt>
}
8010701f:	c9                   	leave  
80107020:	c3                   	ret    

80107021 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80107021:	55                   	push   %ebp
80107022:	89 e5                	mov    %esp,%ebp
80107024:	57                   	push   %edi
80107025:	56                   	push   %esi
80107026:	53                   	push   %ebx
80107027:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
8010702a:	8b 45 08             	mov    0x8(%ebp),%eax
8010702d:	8b 40 30             	mov    0x30(%eax),%eax
80107030:	83 f8 40             	cmp    $0x40,%eax
80107033:	75 3c                	jne    80107071 <trap+0x50>
    if(myproc()->killed)
80107035:	e8 e2 d0 ff ff       	call   8010411c <myproc>
8010703a:	8b 40 24             	mov    0x24(%eax),%eax
8010703d:	85 c0                	test   %eax,%eax
8010703f:	74 05                	je     80107046 <trap+0x25>
      exit();
80107041:	e8 6c d5 ff ff       	call   801045b2 <exit>
    myproc()->tf = tf;
80107046:	e8 d1 d0 ff ff       	call   8010411c <myproc>
8010704b:	8b 55 08             	mov    0x8(%ebp),%edx
8010704e:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80107051:	e8 6d ea ff ff       	call   80105ac3 <syscall>
    if(myproc()->killed)
80107056:	e8 c1 d0 ff ff       	call   8010411c <myproc>
8010705b:	8b 40 24             	mov    0x24(%eax),%eax
8010705e:	85 c0                	test   %eax,%eax
80107060:	74 0a                	je     8010706c <trap+0x4b>
      exit();
80107062:	e8 4b d5 ff ff       	call   801045b2 <exit>
    return;
80107067:	e9 30 02 00 00       	jmp    8010729c <trap+0x27b>
8010706c:	e9 2b 02 00 00       	jmp    8010729c <trap+0x27b>
  }

  switch(tf->trapno){
80107071:	8b 45 08             	mov    0x8(%ebp),%eax
80107074:	8b 40 30             	mov    0x30(%eax),%eax
80107077:	83 e8 20             	sub    $0x20,%eax
8010707a:	83 f8 1f             	cmp    $0x1f,%eax
8010707d:	0f 87 cb 00 00 00    	ja     8010714e <trap+0x12d>
80107083:	8b 04 85 a8 93 10 80 	mov    -0x7fef6c58(,%eax,4),%eax
8010708a:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010708c:	e8 d1 da ff ff       	call   80104b62 <cpuid>
80107091:	85 c0                	test   %eax,%eax
80107093:	75 2f                	jne    801070c4 <trap+0xa3>
      acquire(&tickslock);
80107095:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
8010709c:	e8 be e3 ff ff       	call   8010545f <acquire>
      ticks++;
801070a1:	a1 40 61 12 80       	mov    0x80126140,%eax
801070a6:	40                   	inc    %eax
801070a7:	a3 40 61 12 80       	mov    %eax,0x80126140
      wakeup(&ticks);
801070ac:	c7 04 24 40 61 12 80 	movl   $0x80126140,(%esp)
801070b3:	e8 96 d8 ff ff       	call   8010494e <wakeup>
      release(&tickslock);
801070b8:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
801070bf:	e8 05 e4 ff ff       	call   801054c9 <release>
    }
    p = myproc();
801070c4:	e8 53 d0 ff ff       	call   8010411c <myproc>
801070c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
801070cc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
801070d0:	74 0f                	je     801070e1 <trap+0xc0>
      p->ticks++;
801070d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801070d5:	8b 40 7c             	mov    0x7c(%eax),%eax
801070d8:	8d 50 01             	lea    0x1(%eax),%edx
801070db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801070de:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
801070e1:	e8 11 bf ff ff       	call   80102ff7 <lapiceoi>
    break;
801070e6:	e9 35 01 00 00       	jmp    80107220 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
801070eb:	e8 86 b7 ff ff       	call   80102876 <ideintr>
    lapiceoi();
801070f0:	e8 02 bf ff ff       	call   80102ff7 <lapiceoi>
    break;
801070f5:	e9 26 01 00 00       	jmp    80107220 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
801070fa:	e8 0f bd ff ff       	call   80102e0e <kbdintr>
    lapiceoi();
801070ff:	e8 f3 be ff ff       	call   80102ff7 <lapiceoi>
    break;
80107104:	e9 17 01 00 00       	jmp    80107220 <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80107109:	e8 6f 03 00 00       	call   8010747d <uartintr>
    lapiceoi();
8010710e:	e8 e4 be ff ff       	call   80102ff7 <lapiceoi>
    break;
80107113:	e9 08 01 00 00       	jmp    80107220 <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107118:	8b 45 08             	mov    0x8(%ebp),%eax
8010711b:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010711e:	8b 45 08             	mov    0x8(%ebp),%eax
80107121:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80107124:	0f b7 d8             	movzwl %ax,%ebx
80107127:	e8 36 da ff ff       	call   80104b62 <cpuid>
8010712c:	89 74 24 0c          	mov    %esi,0xc(%esp)
80107130:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80107134:	89 44 24 04          	mov    %eax,0x4(%esp)
80107138:	c7 04 24 08 93 10 80 	movl   $0x80109308,(%esp)
8010713f:	e8 7d 92 ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80107144:	e8 ae be ff ff       	call   80102ff7 <lapiceoi>
    break;
80107149:	e9 d2 00 00 00       	jmp    80107220 <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
8010714e:	e8 c9 cf ff ff       	call   8010411c <myproc>
80107153:	85 c0                	test   %eax,%eax
80107155:	74 10                	je     80107167 <trap+0x146>
80107157:	8b 45 08             	mov    0x8(%ebp),%eax
8010715a:	8b 40 3c             	mov    0x3c(%eax),%eax
8010715d:	0f b7 c0             	movzwl %ax,%eax
80107160:	83 e0 03             	and    $0x3,%eax
80107163:	85 c0                	test   %eax,%eax
80107165:	75 40                	jne    801071a7 <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107167:	e8 2b fd ff ff       	call   80106e97 <rcr2>
8010716c:	89 c3                	mov    %eax,%ebx
8010716e:	8b 45 08             	mov    0x8(%ebp),%eax
80107171:	8b 70 38             	mov    0x38(%eax),%esi
80107174:	e8 e9 d9 ff ff       	call   80104b62 <cpuid>
80107179:	8b 55 08             	mov    0x8(%ebp),%edx
8010717c:	8b 52 30             	mov    0x30(%edx),%edx
8010717f:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80107183:	89 74 24 0c          	mov    %esi,0xc(%esp)
80107187:	89 44 24 08          	mov    %eax,0x8(%esp)
8010718b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010718f:	c7 04 24 2c 93 10 80 	movl   $0x8010932c,(%esp)
80107196:	e8 26 92 ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
8010719b:	c7 04 24 5e 93 10 80 	movl   $0x8010935e,(%esp)
801071a2:	e8 ad 93 ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801071a7:	e8 eb fc ff ff       	call   80106e97 <rcr2>
801071ac:	89 c6                	mov    %eax,%esi
801071ae:	8b 45 08             	mov    0x8(%ebp),%eax
801071b1:	8b 40 38             	mov    0x38(%eax),%eax
801071b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801071b7:	e8 a6 d9 ff ff       	call   80104b62 <cpuid>
801071bc:	89 c3                	mov    %eax,%ebx
801071be:	8b 45 08             	mov    0x8(%ebp),%eax
801071c1:	8b 78 34             	mov    0x34(%eax),%edi
801071c4:	89 7d d0             	mov    %edi,-0x30(%ebp)
801071c7:	8b 45 08             	mov    0x8(%ebp),%eax
801071ca:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
801071cd:	e8 4a cf ff ff       	call   8010411c <myproc>
801071d2:	8d 50 6c             	lea    0x6c(%eax),%edx
801071d5:	89 55 cc             	mov    %edx,-0x34(%ebp)
801071d8:	e8 3f cf ff ff       	call   8010411c <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801071dd:	8b 40 10             	mov    0x10(%eax),%eax
801071e0:	89 74 24 1c          	mov    %esi,0x1c(%esp)
801071e4:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
801071e7:	89 4c 24 18          	mov    %ecx,0x18(%esp)
801071eb:	89 5c 24 14          	mov    %ebx,0x14(%esp)
801071ef:	8b 4d d0             	mov    -0x30(%ebp),%ecx
801071f2:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801071f6:	89 7c 24 0c          	mov    %edi,0xc(%esp)
801071fa:	8b 55 cc             	mov    -0x34(%ebp),%edx
801071fd:	89 54 24 08          	mov    %edx,0x8(%esp)
80107201:	89 44 24 04          	mov    %eax,0x4(%esp)
80107205:	c7 04 24 64 93 10 80 	movl   $0x80109364,(%esp)
8010720c:	e8 b0 91 ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80107211:	e8 06 cf ff ff       	call   8010411c <myproc>
80107216:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010721d:	eb 01                	jmp    80107220 <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010721f:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80107220:	e8 f7 ce ff ff       	call   8010411c <myproc>
80107225:	85 c0                	test   %eax,%eax
80107227:	74 22                	je     8010724b <trap+0x22a>
80107229:	e8 ee ce ff ff       	call   8010411c <myproc>
8010722e:	8b 40 24             	mov    0x24(%eax),%eax
80107231:	85 c0                	test   %eax,%eax
80107233:	74 16                	je     8010724b <trap+0x22a>
80107235:	8b 45 08             	mov    0x8(%ebp),%eax
80107238:	8b 40 3c             	mov    0x3c(%eax),%eax
8010723b:	0f b7 c0             	movzwl %ax,%eax
8010723e:	83 e0 03             	and    $0x3,%eax
80107241:	83 f8 03             	cmp    $0x3,%eax
80107244:	75 05                	jne    8010724b <trap+0x22a>
    exit();
80107246:	e8 67 d3 ff ff       	call   801045b2 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010724b:	e8 cc ce ff ff       	call   8010411c <myproc>
80107250:	85 c0                	test   %eax,%eax
80107252:	74 1d                	je     80107271 <trap+0x250>
80107254:	e8 c3 ce ff ff       	call   8010411c <myproc>
80107259:	8b 40 0c             	mov    0xc(%eax),%eax
8010725c:	83 f8 04             	cmp    $0x4,%eax
8010725f:	75 10                	jne    80107271 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80107261:	8b 45 08             	mov    0x8(%ebp),%eax
80107264:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80107267:	83 f8 20             	cmp    $0x20,%eax
8010726a:	75 05                	jne    80107271 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
8010726c:	e8 94 d5 ff ff       	call   80104805 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80107271:	e8 a6 ce ff ff       	call   8010411c <myproc>
80107276:	85 c0                	test   %eax,%eax
80107278:	74 22                	je     8010729c <trap+0x27b>
8010727a:	e8 9d ce ff ff       	call   8010411c <myproc>
8010727f:	8b 40 24             	mov    0x24(%eax),%eax
80107282:	85 c0                	test   %eax,%eax
80107284:	74 16                	je     8010729c <trap+0x27b>
80107286:	8b 45 08             	mov    0x8(%ebp),%eax
80107289:	8b 40 3c             	mov    0x3c(%eax),%eax
8010728c:	0f b7 c0             	movzwl %ax,%eax
8010728f:	83 e0 03             	and    $0x3,%eax
80107292:	83 f8 03             	cmp    $0x3,%eax
80107295:	75 05                	jne    8010729c <trap+0x27b>
    exit();
80107297:	e8 16 d3 ff ff       	call   801045b2 <exit>
}
8010729c:	83 c4 4c             	add    $0x4c,%esp
8010729f:	5b                   	pop    %ebx
801072a0:	5e                   	pop    %esi
801072a1:	5f                   	pop    %edi
801072a2:	5d                   	pop    %ebp
801072a3:	c3                   	ret    

801072a4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801072a4:	55                   	push   %ebp
801072a5:	89 e5                	mov    %esp,%ebp
801072a7:	83 ec 14             	sub    $0x14,%esp
801072aa:	8b 45 08             	mov    0x8(%ebp),%eax
801072ad:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801072b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801072b4:	89 c2                	mov    %eax,%edx
801072b6:	ec                   	in     (%dx),%al
801072b7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801072ba:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801072bd:	c9                   	leave  
801072be:	c3                   	ret    

801072bf <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801072bf:	55                   	push   %ebp
801072c0:	89 e5                	mov    %esp,%ebp
801072c2:	83 ec 08             	sub    $0x8,%esp
801072c5:	8b 45 08             	mov    0x8(%ebp),%eax
801072c8:	8b 55 0c             	mov    0xc(%ebp),%edx
801072cb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
801072cf:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801072d2:	8a 45 f8             	mov    -0x8(%ebp),%al
801072d5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801072d8:	ee                   	out    %al,(%dx)
}
801072d9:	c9                   	leave  
801072da:	c3                   	ret    

801072db <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801072db:	55                   	push   %ebp
801072dc:	89 e5                	mov    %esp,%ebp
801072de:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801072e1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801072e8:	00 
801072e9:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
801072f0:	e8 ca ff ff ff       	call   801072bf <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801072f5:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801072fc:	00 
801072fd:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107304:	e8 b6 ff ff ff       	call   801072bf <outb>
  outb(COM1+0, 115200/9600);
80107309:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
80107310:	00 
80107311:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107318:	e8 a2 ff ff ff       	call   801072bf <outb>
  outb(COM1+1, 0);
8010731d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80107324:	00 
80107325:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
8010732c:	e8 8e ff ff ff       	call   801072bf <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107331:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80107338:	00 
80107339:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
80107340:	e8 7a ff ff ff       	call   801072bf <outb>
  outb(COM1+4, 0);
80107345:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010734c:	00 
8010734d:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
80107354:	e8 66 ff ff ff       	call   801072bf <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107359:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107360:	00 
80107361:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
80107368:	e8 52 ff ff ff       	call   801072bf <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
8010736d:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107374:	e8 2b ff ff ff       	call   801072a4 <inb>
80107379:	3c ff                	cmp    $0xff,%al
8010737b:	75 02                	jne    8010737f <uartinit+0xa4>
    return;
8010737d:	eb 5b                	jmp    801073da <uartinit+0xff>
  uart = 1;
8010737f:	c7 05 84 c7 10 80 01 	movl   $0x1,0x8010c784
80107386:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80107389:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107390:	e8 0f ff ff ff       	call   801072a4 <inb>
  inb(COM1+0);
80107395:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
8010739c:	e8 03 ff ff ff       	call   801072a4 <inb>
  ioapicenable(IRQ_COM1, 0);
801073a1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801073a8:	00 
801073a9:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801073b0:	e8 36 b7 ff ff       	call   80102aeb <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801073b5:	c7 45 f4 28 94 10 80 	movl   $0x80109428,-0xc(%ebp)
801073bc:	eb 13                	jmp    801073d1 <uartinit+0xf6>
    uartputc(*p);
801073be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c1:	8a 00                	mov    (%eax),%al
801073c3:	0f be c0             	movsbl %al,%eax
801073c6:	89 04 24             	mov    %eax,(%esp)
801073c9:	e8 0e 00 00 00       	call   801073dc <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801073ce:	ff 45 f4             	incl   -0xc(%ebp)
801073d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d4:	8a 00                	mov    (%eax),%al
801073d6:	84 c0                	test   %al,%al
801073d8:	75 e4                	jne    801073be <uartinit+0xe3>
    uartputc(*p);
}
801073da:	c9                   	leave  
801073db:	c3                   	ret    

801073dc <uartputc>:

void
uartputc(int c)
{
801073dc:	55                   	push   %ebp
801073dd:	89 e5                	mov    %esp,%ebp
801073df:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
801073e2:	a1 84 c7 10 80       	mov    0x8010c784,%eax
801073e7:	85 c0                	test   %eax,%eax
801073e9:	75 02                	jne    801073ed <uartputc+0x11>
    return;
801073eb:	eb 4a                	jmp    80107437 <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801073ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801073f4:	eb 0f                	jmp    80107405 <uartputc+0x29>
    microdelay(10);
801073f6:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801073fd:	e8 1a bc ff ff       	call   8010301c <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107402:	ff 45 f4             	incl   -0xc(%ebp)
80107405:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107409:	7f 16                	jg     80107421 <uartputc+0x45>
8010740b:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107412:	e8 8d fe ff ff       	call   801072a4 <inb>
80107417:	0f b6 c0             	movzbl %al,%eax
8010741a:	83 e0 20             	and    $0x20,%eax
8010741d:	85 c0                	test   %eax,%eax
8010741f:	74 d5                	je     801073f6 <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
80107421:	8b 45 08             	mov    0x8(%ebp),%eax
80107424:	0f b6 c0             	movzbl %al,%eax
80107427:	89 44 24 04          	mov    %eax,0x4(%esp)
8010742b:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107432:	e8 88 fe ff ff       	call   801072bf <outb>
}
80107437:	c9                   	leave  
80107438:	c3                   	ret    

80107439 <uartgetc>:

static int
uartgetc(void)
{
80107439:	55                   	push   %ebp
8010743a:	89 e5                	mov    %esp,%ebp
8010743c:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
8010743f:	a1 84 c7 10 80       	mov    0x8010c784,%eax
80107444:	85 c0                	test   %eax,%eax
80107446:	75 07                	jne    8010744f <uartgetc+0x16>
    return -1;
80107448:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010744d:	eb 2c                	jmp    8010747b <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
8010744f:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107456:	e8 49 fe ff ff       	call   801072a4 <inb>
8010745b:	0f b6 c0             	movzbl %al,%eax
8010745e:	83 e0 01             	and    $0x1,%eax
80107461:	85 c0                	test   %eax,%eax
80107463:	75 07                	jne    8010746c <uartgetc+0x33>
    return -1;
80107465:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010746a:	eb 0f                	jmp    8010747b <uartgetc+0x42>
  return inb(COM1+0);
8010746c:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107473:	e8 2c fe ff ff       	call   801072a4 <inb>
80107478:	0f b6 c0             	movzbl %al,%eax
}
8010747b:	c9                   	leave  
8010747c:	c3                   	ret    

8010747d <uartintr>:

void
uartintr(void)
{
8010747d:	55                   	push   %ebp
8010747e:	89 e5                	mov    %esp,%ebp
80107480:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80107483:	c7 04 24 39 74 10 80 	movl   $0x80107439,(%esp)
8010748a:	e8 66 93 ff ff       	call   801007f5 <consoleintr>
}
8010748f:	c9                   	leave  
80107490:	c3                   	ret    
80107491:	00 00                	add    %al,(%eax)
	...

80107494 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107494:	6a 00                	push   $0x0
  pushl $0
80107496:	6a 00                	push   $0x0
  jmp alltraps
80107498:	e9 af f9 ff ff       	jmp    80106e4c <alltraps>

8010749d <vector1>:
.globl vector1
vector1:
  pushl $0
8010749d:	6a 00                	push   $0x0
  pushl $1
8010749f:	6a 01                	push   $0x1
  jmp alltraps
801074a1:	e9 a6 f9 ff ff       	jmp    80106e4c <alltraps>

801074a6 <vector2>:
.globl vector2
vector2:
  pushl $0
801074a6:	6a 00                	push   $0x0
  pushl $2
801074a8:	6a 02                	push   $0x2
  jmp alltraps
801074aa:	e9 9d f9 ff ff       	jmp    80106e4c <alltraps>

801074af <vector3>:
.globl vector3
vector3:
  pushl $0
801074af:	6a 00                	push   $0x0
  pushl $3
801074b1:	6a 03                	push   $0x3
  jmp alltraps
801074b3:	e9 94 f9 ff ff       	jmp    80106e4c <alltraps>

801074b8 <vector4>:
.globl vector4
vector4:
  pushl $0
801074b8:	6a 00                	push   $0x0
  pushl $4
801074ba:	6a 04                	push   $0x4
  jmp alltraps
801074bc:	e9 8b f9 ff ff       	jmp    80106e4c <alltraps>

801074c1 <vector5>:
.globl vector5
vector5:
  pushl $0
801074c1:	6a 00                	push   $0x0
  pushl $5
801074c3:	6a 05                	push   $0x5
  jmp alltraps
801074c5:	e9 82 f9 ff ff       	jmp    80106e4c <alltraps>

801074ca <vector6>:
.globl vector6
vector6:
  pushl $0
801074ca:	6a 00                	push   $0x0
  pushl $6
801074cc:	6a 06                	push   $0x6
  jmp alltraps
801074ce:	e9 79 f9 ff ff       	jmp    80106e4c <alltraps>

801074d3 <vector7>:
.globl vector7
vector7:
  pushl $0
801074d3:	6a 00                	push   $0x0
  pushl $7
801074d5:	6a 07                	push   $0x7
  jmp alltraps
801074d7:	e9 70 f9 ff ff       	jmp    80106e4c <alltraps>

801074dc <vector8>:
.globl vector8
vector8:
  pushl $8
801074dc:	6a 08                	push   $0x8
  jmp alltraps
801074de:	e9 69 f9 ff ff       	jmp    80106e4c <alltraps>

801074e3 <vector9>:
.globl vector9
vector9:
  pushl $0
801074e3:	6a 00                	push   $0x0
  pushl $9
801074e5:	6a 09                	push   $0x9
  jmp alltraps
801074e7:	e9 60 f9 ff ff       	jmp    80106e4c <alltraps>

801074ec <vector10>:
.globl vector10
vector10:
  pushl $10
801074ec:	6a 0a                	push   $0xa
  jmp alltraps
801074ee:	e9 59 f9 ff ff       	jmp    80106e4c <alltraps>

801074f3 <vector11>:
.globl vector11
vector11:
  pushl $11
801074f3:	6a 0b                	push   $0xb
  jmp alltraps
801074f5:	e9 52 f9 ff ff       	jmp    80106e4c <alltraps>

801074fa <vector12>:
.globl vector12
vector12:
  pushl $12
801074fa:	6a 0c                	push   $0xc
  jmp alltraps
801074fc:	e9 4b f9 ff ff       	jmp    80106e4c <alltraps>

80107501 <vector13>:
.globl vector13
vector13:
  pushl $13
80107501:	6a 0d                	push   $0xd
  jmp alltraps
80107503:	e9 44 f9 ff ff       	jmp    80106e4c <alltraps>

80107508 <vector14>:
.globl vector14
vector14:
  pushl $14
80107508:	6a 0e                	push   $0xe
  jmp alltraps
8010750a:	e9 3d f9 ff ff       	jmp    80106e4c <alltraps>

8010750f <vector15>:
.globl vector15
vector15:
  pushl $0
8010750f:	6a 00                	push   $0x0
  pushl $15
80107511:	6a 0f                	push   $0xf
  jmp alltraps
80107513:	e9 34 f9 ff ff       	jmp    80106e4c <alltraps>

80107518 <vector16>:
.globl vector16
vector16:
  pushl $0
80107518:	6a 00                	push   $0x0
  pushl $16
8010751a:	6a 10                	push   $0x10
  jmp alltraps
8010751c:	e9 2b f9 ff ff       	jmp    80106e4c <alltraps>

80107521 <vector17>:
.globl vector17
vector17:
  pushl $17
80107521:	6a 11                	push   $0x11
  jmp alltraps
80107523:	e9 24 f9 ff ff       	jmp    80106e4c <alltraps>

80107528 <vector18>:
.globl vector18
vector18:
  pushl $0
80107528:	6a 00                	push   $0x0
  pushl $18
8010752a:	6a 12                	push   $0x12
  jmp alltraps
8010752c:	e9 1b f9 ff ff       	jmp    80106e4c <alltraps>

80107531 <vector19>:
.globl vector19
vector19:
  pushl $0
80107531:	6a 00                	push   $0x0
  pushl $19
80107533:	6a 13                	push   $0x13
  jmp alltraps
80107535:	e9 12 f9 ff ff       	jmp    80106e4c <alltraps>

8010753a <vector20>:
.globl vector20
vector20:
  pushl $0
8010753a:	6a 00                	push   $0x0
  pushl $20
8010753c:	6a 14                	push   $0x14
  jmp alltraps
8010753e:	e9 09 f9 ff ff       	jmp    80106e4c <alltraps>

80107543 <vector21>:
.globl vector21
vector21:
  pushl $0
80107543:	6a 00                	push   $0x0
  pushl $21
80107545:	6a 15                	push   $0x15
  jmp alltraps
80107547:	e9 00 f9 ff ff       	jmp    80106e4c <alltraps>

8010754c <vector22>:
.globl vector22
vector22:
  pushl $0
8010754c:	6a 00                	push   $0x0
  pushl $22
8010754e:	6a 16                	push   $0x16
  jmp alltraps
80107550:	e9 f7 f8 ff ff       	jmp    80106e4c <alltraps>

80107555 <vector23>:
.globl vector23
vector23:
  pushl $0
80107555:	6a 00                	push   $0x0
  pushl $23
80107557:	6a 17                	push   $0x17
  jmp alltraps
80107559:	e9 ee f8 ff ff       	jmp    80106e4c <alltraps>

8010755e <vector24>:
.globl vector24
vector24:
  pushl $0
8010755e:	6a 00                	push   $0x0
  pushl $24
80107560:	6a 18                	push   $0x18
  jmp alltraps
80107562:	e9 e5 f8 ff ff       	jmp    80106e4c <alltraps>

80107567 <vector25>:
.globl vector25
vector25:
  pushl $0
80107567:	6a 00                	push   $0x0
  pushl $25
80107569:	6a 19                	push   $0x19
  jmp alltraps
8010756b:	e9 dc f8 ff ff       	jmp    80106e4c <alltraps>

80107570 <vector26>:
.globl vector26
vector26:
  pushl $0
80107570:	6a 00                	push   $0x0
  pushl $26
80107572:	6a 1a                	push   $0x1a
  jmp alltraps
80107574:	e9 d3 f8 ff ff       	jmp    80106e4c <alltraps>

80107579 <vector27>:
.globl vector27
vector27:
  pushl $0
80107579:	6a 00                	push   $0x0
  pushl $27
8010757b:	6a 1b                	push   $0x1b
  jmp alltraps
8010757d:	e9 ca f8 ff ff       	jmp    80106e4c <alltraps>

80107582 <vector28>:
.globl vector28
vector28:
  pushl $0
80107582:	6a 00                	push   $0x0
  pushl $28
80107584:	6a 1c                	push   $0x1c
  jmp alltraps
80107586:	e9 c1 f8 ff ff       	jmp    80106e4c <alltraps>

8010758b <vector29>:
.globl vector29
vector29:
  pushl $0
8010758b:	6a 00                	push   $0x0
  pushl $29
8010758d:	6a 1d                	push   $0x1d
  jmp alltraps
8010758f:	e9 b8 f8 ff ff       	jmp    80106e4c <alltraps>

80107594 <vector30>:
.globl vector30
vector30:
  pushl $0
80107594:	6a 00                	push   $0x0
  pushl $30
80107596:	6a 1e                	push   $0x1e
  jmp alltraps
80107598:	e9 af f8 ff ff       	jmp    80106e4c <alltraps>

8010759d <vector31>:
.globl vector31
vector31:
  pushl $0
8010759d:	6a 00                	push   $0x0
  pushl $31
8010759f:	6a 1f                	push   $0x1f
  jmp alltraps
801075a1:	e9 a6 f8 ff ff       	jmp    80106e4c <alltraps>

801075a6 <vector32>:
.globl vector32
vector32:
  pushl $0
801075a6:	6a 00                	push   $0x0
  pushl $32
801075a8:	6a 20                	push   $0x20
  jmp alltraps
801075aa:	e9 9d f8 ff ff       	jmp    80106e4c <alltraps>

801075af <vector33>:
.globl vector33
vector33:
  pushl $0
801075af:	6a 00                	push   $0x0
  pushl $33
801075b1:	6a 21                	push   $0x21
  jmp alltraps
801075b3:	e9 94 f8 ff ff       	jmp    80106e4c <alltraps>

801075b8 <vector34>:
.globl vector34
vector34:
  pushl $0
801075b8:	6a 00                	push   $0x0
  pushl $34
801075ba:	6a 22                	push   $0x22
  jmp alltraps
801075bc:	e9 8b f8 ff ff       	jmp    80106e4c <alltraps>

801075c1 <vector35>:
.globl vector35
vector35:
  pushl $0
801075c1:	6a 00                	push   $0x0
  pushl $35
801075c3:	6a 23                	push   $0x23
  jmp alltraps
801075c5:	e9 82 f8 ff ff       	jmp    80106e4c <alltraps>

801075ca <vector36>:
.globl vector36
vector36:
  pushl $0
801075ca:	6a 00                	push   $0x0
  pushl $36
801075cc:	6a 24                	push   $0x24
  jmp alltraps
801075ce:	e9 79 f8 ff ff       	jmp    80106e4c <alltraps>

801075d3 <vector37>:
.globl vector37
vector37:
  pushl $0
801075d3:	6a 00                	push   $0x0
  pushl $37
801075d5:	6a 25                	push   $0x25
  jmp alltraps
801075d7:	e9 70 f8 ff ff       	jmp    80106e4c <alltraps>

801075dc <vector38>:
.globl vector38
vector38:
  pushl $0
801075dc:	6a 00                	push   $0x0
  pushl $38
801075de:	6a 26                	push   $0x26
  jmp alltraps
801075e0:	e9 67 f8 ff ff       	jmp    80106e4c <alltraps>

801075e5 <vector39>:
.globl vector39
vector39:
  pushl $0
801075e5:	6a 00                	push   $0x0
  pushl $39
801075e7:	6a 27                	push   $0x27
  jmp alltraps
801075e9:	e9 5e f8 ff ff       	jmp    80106e4c <alltraps>

801075ee <vector40>:
.globl vector40
vector40:
  pushl $0
801075ee:	6a 00                	push   $0x0
  pushl $40
801075f0:	6a 28                	push   $0x28
  jmp alltraps
801075f2:	e9 55 f8 ff ff       	jmp    80106e4c <alltraps>

801075f7 <vector41>:
.globl vector41
vector41:
  pushl $0
801075f7:	6a 00                	push   $0x0
  pushl $41
801075f9:	6a 29                	push   $0x29
  jmp alltraps
801075fb:	e9 4c f8 ff ff       	jmp    80106e4c <alltraps>

80107600 <vector42>:
.globl vector42
vector42:
  pushl $0
80107600:	6a 00                	push   $0x0
  pushl $42
80107602:	6a 2a                	push   $0x2a
  jmp alltraps
80107604:	e9 43 f8 ff ff       	jmp    80106e4c <alltraps>

80107609 <vector43>:
.globl vector43
vector43:
  pushl $0
80107609:	6a 00                	push   $0x0
  pushl $43
8010760b:	6a 2b                	push   $0x2b
  jmp alltraps
8010760d:	e9 3a f8 ff ff       	jmp    80106e4c <alltraps>

80107612 <vector44>:
.globl vector44
vector44:
  pushl $0
80107612:	6a 00                	push   $0x0
  pushl $44
80107614:	6a 2c                	push   $0x2c
  jmp alltraps
80107616:	e9 31 f8 ff ff       	jmp    80106e4c <alltraps>

8010761b <vector45>:
.globl vector45
vector45:
  pushl $0
8010761b:	6a 00                	push   $0x0
  pushl $45
8010761d:	6a 2d                	push   $0x2d
  jmp alltraps
8010761f:	e9 28 f8 ff ff       	jmp    80106e4c <alltraps>

80107624 <vector46>:
.globl vector46
vector46:
  pushl $0
80107624:	6a 00                	push   $0x0
  pushl $46
80107626:	6a 2e                	push   $0x2e
  jmp alltraps
80107628:	e9 1f f8 ff ff       	jmp    80106e4c <alltraps>

8010762d <vector47>:
.globl vector47
vector47:
  pushl $0
8010762d:	6a 00                	push   $0x0
  pushl $47
8010762f:	6a 2f                	push   $0x2f
  jmp alltraps
80107631:	e9 16 f8 ff ff       	jmp    80106e4c <alltraps>

80107636 <vector48>:
.globl vector48
vector48:
  pushl $0
80107636:	6a 00                	push   $0x0
  pushl $48
80107638:	6a 30                	push   $0x30
  jmp alltraps
8010763a:	e9 0d f8 ff ff       	jmp    80106e4c <alltraps>

8010763f <vector49>:
.globl vector49
vector49:
  pushl $0
8010763f:	6a 00                	push   $0x0
  pushl $49
80107641:	6a 31                	push   $0x31
  jmp alltraps
80107643:	e9 04 f8 ff ff       	jmp    80106e4c <alltraps>

80107648 <vector50>:
.globl vector50
vector50:
  pushl $0
80107648:	6a 00                	push   $0x0
  pushl $50
8010764a:	6a 32                	push   $0x32
  jmp alltraps
8010764c:	e9 fb f7 ff ff       	jmp    80106e4c <alltraps>

80107651 <vector51>:
.globl vector51
vector51:
  pushl $0
80107651:	6a 00                	push   $0x0
  pushl $51
80107653:	6a 33                	push   $0x33
  jmp alltraps
80107655:	e9 f2 f7 ff ff       	jmp    80106e4c <alltraps>

8010765a <vector52>:
.globl vector52
vector52:
  pushl $0
8010765a:	6a 00                	push   $0x0
  pushl $52
8010765c:	6a 34                	push   $0x34
  jmp alltraps
8010765e:	e9 e9 f7 ff ff       	jmp    80106e4c <alltraps>

80107663 <vector53>:
.globl vector53
vector53:
  pushl $0
80107663:	6a 00                	push   $0x0
  pushl $53
80107665:	6a 35                	push   $0x35
  jmp alltraps
80107667:	e9 e0 f7 ff ff       	jmp    80106e4c <alltraps>

8010766c <vector54>:
.globl vector54
vector54:
  pushl $0
8010766c:	6a 00                	push   $0x0
  pushl $54
8010766e:	6a 36                	push   $0x36
  jmp alltraps
80107670:	e9 d7 f7 ff ff       	jmp    80106e4c <alltraps>

80107675 <vector55>:
.globl vector55
vector55:
  pushl $0
80107675:	6a 00                	push   $0x0
  pushl $55
80107677:	6a 37                	push   $0x37
  jmp alltraps
80107679:	e9 ce f7 ff ff       	jmp    80106e4c <alltraps>

8010767e <vector56>:
.globl vector56
vector56:
  pushl $0
8010767e:	6a 00                	push   $0x0
  pushl $56
80107680:	6a 38                	push   $0x38
  jmp alltraps
80107682:	e9 c5 f7 ff ff       	jmp    80106e4c <alltraps>

80107687 <vector57>:
.globl vector57
vector57:
  pushl $0
80107687:	6a 00                	push   $0x0
  pushl $57
80107689:	6a 39                	push   $0x39
  jmp alltraps
8010768b:	e9 bc f7 ff ff       	jmp    80106e4c <alltraps>

80107690 <vector58>:
.globl vector58
vector58:
  pushl $0
80107690:	6a 00                	push   $0x0
  pushl $58
80107692:	6a 3a                	push   $0x3a
  jmp alltraps
80107694:	e9 b3 f7 ff ff       	jmp    80106e4c <alltraps>

80107699 <vector59>:
.globl vector59
vector59:
  pushl $0
80107699:	6a 00                	push   $0x0
  pushl $59
8010769b:	6a 3b                	push   $0x3b
  jmp alltraps
8010769d:	e9 aa f7 ff ff       	jmp    80106e4c <alltraps>

801076a2 <vector60>:
.globl vector60
vector60:
  pushl $0
801076a2:	6a 00                	push   $0x0
  pushl $60
801076a4:	6a 3c                	push   $0x3c
  jmp alltraps
801076a6:	e9 a1 f7 ff ff       	jmp    80106e4c <alltraps>

801076ab <vector61>:
.globl vector61
vector61:
  pushl $0
801076ab:	6a 00                	push   $0x0
  pushl $61
801076ad:	6a 3d                	push   $0x3d
  jmp alltraps
801076af:	e9 98 f7 ff ff       	jmp    80106e4c <alltraps>

801076b4 <vector62>:
.globl vector62
vector62:
  pushl $0
801076b4:	6a 00                	push   $0x0
  pushl $62
801076b6:	6a 3e                	push   $0x3e
  jmp alltraps
801076b8:	e9 8f f7 ff ff       	jmp    80106e4c <alltraps>

801076bd <vector63>:
.globl vector63
vector63:
  pushl $0
801076bd:	6a 00                	push   $0x0
  pushl $63
801076bf:	6a 3f                	push   $0x3f
  jmp alltraps
801076c1:	e9 86 f7 ff ff       	jmp    80106e4c <alltraps>

801076c6 <vector64>:
.globl vector64
vector64:
  pushl $0
801076c6:	6a 00                	push   $0x0
  pushl $64
801076c8:	6a 40                	push   $0x40
  jmp alltraps
801076ca:	e9 7d f7 ff ff       	jmp    80106e4c <alltraps>

801076cf <vector65>:
.globl vector65
vector65:
  pushl $0
801076cf:	6a 00                	push   $0x0
  pushl $65
801076d1:	6a 41                	push   $0x41
  jmp alltraps
801076d3:	e9 74 f7 ff ff       	jmp    80106e4c <alltraps>

801076d8 <vector66>:
.globl vector66
vector66:
  pushl $0
801076d8:	6a 00                	push   $0x0
  pushl $66
801076da:	6a 42                	push   $0x42
  jmp alltraps
801076dc:	e9 6b f7 ff ff       	jmp    80106e4c <alltraps>

801076e1 <vector67>:
.globl vector67
vector67:
  pushl $0
801076e1:	6a 00                	push   $0x0
  pushl $67
801076e3:	6a 43                	push   $0x43
  jmp alltraps
801076e5:	e9 62 f7 ff ff       	jmp    80106e4c <alltraps>

801076ea <vector68>:
.globl vector68
vector68:
  pushl $0
801076ea:	6a 00                	push   $0x0
  pushl $68
801076ec:	6a 44                	push   $0x44
  jmp alltraps
801076ee:	e9 59 f7 ff ff       	jmp    80106e4c <alltraps>

801076f3 <vector69>:
.globl vector69
vector69:
  pushl $0
801076f3:	6a 00                	push   $0x0
  pushl $69
801076f5:	6a 45                	push   $0x45
  jmp alltraps
801076f7:	e9 50 f7 ff ff       	jmp    80106e4c <alltraps>

801076fc <vector70>:
.globl vector70
vector70:
  pushl $0
801076fc:	6a 00                	push   $0x0
  pushl $70
801076fe:	6a 46                	push   $0x46
  jmp alltraps
80107700:	e9 47 f7 ff ff       	jmp    80106e4c <alltraps>

80107705 <vector71>:
.globl vector71
vector71:
  pushl $0
80107705:	6a 00                	push   $0x0
  pushl $71
80107707:	6a 47                	push   $0x47
  jmp alltraps
80107709:	e9 3e f7 ff ff       	jmp    80106e4c <alltraps>

8010770e <vector72>:
.globl vector72
vector72:
  pushl $0
8010770e:	6a 00                	push   $0x0
  pushl $72
80107710:	6a 48                	push   $0x48
  jmp alltraps
80107712:	e9 35 f7 ff ff       	jmp    80106e4c <alltraps>

80107717 <vector73>:
.globl vector73
vector73:
  pushl $0
80107717:	6a 00                	push   $0x0
  pushl $73
80107719:	6a 49                	push   $0x49
  jmp alltraps
8010771b:	e9 2c f7 ff ff       	jmp    80106e4c <alltraps>

80107720 <vector74>:
.globl vector74
vector74:
  pushl $0
80107720:	6a 00                	push   $0x0
  pushl $74
80107722:	6a 4a                	push   $0x4a
  jmp alltraps
80107724:	e9 23 f7 ff ff       	jmp    80106e4c <alltraps>

80107729 <vector75>:
.globl vector75
vector75:
  pushl $0
80107729:	6a 00                	push   $0x0
  pushl $75
8010772b:	6a 4b                	push   $0x4b
  jmp alltraps
8010772d:	e9 1a f7 ff ff       	jmp    80106e4c <alltraps>

80107732 <vector76>:
.globl vector76
vector76:
  pushl $0
80107732:	6a 00                	push   $0x0
  pushl $76
80107734:	6a 4c                	push   $0x4c
  jmp alltraps
80107736:	e9 11 f7 ff ff       	jmp    80106e4c <alltraps>

8010773b <vector77>:
.globl vector77
vector77:
  pushl $0
8010773b:	6a 00                	push   $0x0
  pushl $77
8010773d:	6a 4d                	push   $0x4d
  jmp alltraps
8010773f:	e9 08 f7 ff ff       	jmp    80106e4c <alltraps>

80107744 <vector78>:
.globl vector78
vector78:
  pushl $0
80107744:	6a 00                	push   $0x0
  pushl $78
80107746:	6a 4e                	push   $0x4e
  jmp alltraps
80107748:	e9 ff f6 ff ff       	jmp    80106e4c <alltraps>

8010774d <vector79>:
.globl vector79
vector79:
  pushl $0
8010774d:	6a 00                	push   $0x0
  pushl $79
8010774f:	6a 4f                	push   $0x4f
  jmp alltraps
80107751:	e9 f6 f6 ff ff       	jmp    80106e4c <alltraps>

80107756 <vector80>:
.globl vector80
vector80:
  pushl $0
80107756:	6a 00                	push   $0x0
  pushl $80
80107758:	6a 50                	push   $0x50
  jmp alltraps
8010775a:	e9 ed f6 ff ff       	jmp    80106e4c <alltraps>

8010775f <vector81>:
.globl vector81
vector81:
  pushl $0
8010775f:	6a 00                	push   $0x0
  pushl $81
80107761:	6a 51                	push   $0x51
  jmp alltraps
80107763:	e9 e4 f6 ff ff       	jmp    80106e4c <alltraps>

80107768 <vector82>:
.globl vector82
vector82:
  pushl $0
80107768:	6a 00                	push   $0x0
  pushl $82
8010776a:	6a 52                	push   $0x52
  jmp alltraps
8010776c:	e9 db f6 ff ff       	jmp    80106e4c <alltraps>

80107771 <vector83>:
.globl vector83
vector83:
  pushl $0
80107771:	6a 00                	push   $0x0
  pushl $83
80107773:	6a 53                	push   $0x53
  jmp alltraps
80107775:	e9 d2 f6 ff ff       	jmp    80106e4c <alltraps>

8010777a <vector84>:
.globl vector84
vector84:
  pushl $0
8010777a:	6a 00                	push   $0x0
  pushl $84
8010777c:	6a 54                	push   $0x54
  jmp alltraps
8010777e:	e9 c9 f6 ff ff       	jmp    80106e4c <alltraps>

80107783 <vector85>:
.globl vector85
vector85:
  pushl $0
80107783:	6a 00                	push   $0x0
  pushl $85
80107785:	6a 55                	push   $0x55
  jmp alltraps
80107787:	e9 c0 f6 ff ff       	jmp    80106e4c <alltraps>

8010778c <vector86>:
.globl vector86
vector86:
  pushl $0
8010778c:	6a 00                	push   $0x0
  pushl $86
8010778e:	6a 56                	push   $0x56
  jmp alltraps
80107790:	e9 b7 f6 ff ff       	jmp    80106e4c <alltraps>

80107795 <vector87>:
.globl vector87
vector87:
  pushl $0
80107795:	6a 00                	push   $0x0
  pushl $87
80107797:	6a 57                	push   $0x57
  jmp alltraps
80107799:	e9 ae f6 ff ff       	jmp    80106e4c <alltraps>

8010779e <vector88>:
.globl vector88
vector88:
  pushl $0
8010779e:	6a 00                	push   $0x0
  pushl $88
801077a0:	6a 58                	push   $0x58
  jmp alltraps
801077a2:	e9 a5 f6 ff ff       	jmp    80106e4c <alltraps>

801077a7 <vector89>:
.globl vector89
vector89:
  pushl $0
801077a7:	6a 00                	push   $0x0
  pushl $89
801077a9:	6a 59                	push   $0x59
  jmp alltraps
801077ab:	e9 9c f6 ff ff       	jmp    80106e4c <alltraps>

801077b0 <vector90>:
.globl vector90
vector90:
  pushl $0
801077b0:	6a 00                	push   $0x0
  pushl $90
801077b2:	6a 5a                	push   $0x5a
  jmp alltraps
801077b4:	e9 93 f6 ff ff       	jmp    80106e4c <alltraps>

801077b9 <vector91>:
.globl vector91
vector91:
  pushl $0
801077b9:	6a 00                	push   $0x0
  pushl $91
801077bb:	6a 5b                	push   $0x5b
  jmp alltraps
801077bd:	e9 8a f6 ff ff       	jmp    80106e4c <alltraps>

801077c2 <vector92>:
.globl vector92
vector92:
  pushl $0
801077c2:	6a 00                	push   $0x0
  pushl $92
801077c4:	6a 5c                	push   $0x5c
  jmp alltraps
801077c6:	e9 81 f6 ff ff       	jmp    80106e4c <alltraps>

801077cb <vector93>:
.globl vector93
vector93:
  pushl $0
801077cb:	6a 00                	push   $0x0
  pushl $93
801077cd:	6a 5d                	push   $0x5d
  jmp alltraps
801077cf:	e9 78 f6 ff ff       	jmp    80106e4c <alltraps>

801077d4 <vector94>:
.globl vector94
vector94:
  pushl $0
801077d4:	6a 00                	push   $0x0
  pushl $94
801077d6:	6a 5e                	push   $0x5e
  jmp alltraps
801077d8:	e9 6f f6 ff ff       	jmp    80106e4c <alltraps>

801077dd <vector95>:
.globl vector95
vector95:
  pushl $0
801077dd:	6a 00                	push   $0x0
  pushl $95
801077df:	6a 5f                	push   $0x5f
  jmp alltraps
801077e1:	e9 66 f6 ff ff       	jmp    80106e4c <alltraps>

801077e6 <vector96>:
.globl vector96
vector96:
  pushl $0
801077e6:	6a 00                	push   $0x0
  pushl $96
801077e8:	6a 60                	push   $0x60
  jmp alltraps
801077ea:	e9 5d f6 ff ff       	jmp    80106e4c <alltraps>

801077ef <vector97>:
.globl vector97
vector97:
  pushl $0
801077ef:	6a 00                	push   $0x0
  pushl $97
801077f1:	6a 61                	push   $0x61
  jmp alltraps
801077f3:	e9 54 f6 ff ff       	jmp    80106e4c <alltraps>

801077f8 <vector98>:
.globl vector98
vector98:
  pushl $0
801077f8:	6a 00                	push   $0x0
  pushl $98
801077fa:	6a 62                	push   $0x62
  jmp alltraps
801077fc:	e9 4b f6 ff ff       	jmp    80106e4c <alltraps>

80107801 <vector99>:
.globl vector99
vector99:
  pushl $0
80107801:	6a 00                	push   $0x0
  pushl $99
80107803:	6a 63                	push   $0x63
  jmp alltraps
80107805:	e9 42 f6 ff ff       	jmp    80106e4c <alltraps>

8010780a <vector100>:
.globl vector100
vector100:
  pushl $0
8010780a:	6a 00                	push   $0x0
  pushl $100
8010780c:	6a 64                	push   $0x64
  jmp alltraps
8010780e:	e9 39 f6 ff ff       	jmp    80106e4c <alltraps>

80107813 <vector101>:
.globl vector101
vector101:
  pushl $0
80107813:	6a 00                	push   $0x0
  pushl $101
80107815:	6a 65                	push   $0x65
  jmp alltraps
80107817:	e9 30 f6 ff ff       	jmp    80106e4c <alltraps>

8010781c <vector102>:
.globl vector102
vector102:
  pushl $0
8010781c:	6a 00                	push   $0x0
  pushl $102
8010781e:	6a 66                	push   $0x66
  jmp alltraps
80107820:	e9 27 f6 ff ff       	jmp    80106e4c <alltraps>

80107825 <vector103>:
.globl vector103
vector103:
  pushl $0
80107825:	6a 00                	push   $0x0
  pushl $103
80107827:	6a 67                	push   $0x67
  jmp alltraps
80107829:	e9 1e f6 ff ff       	jmp    80106e4c <alltraps>

8010782e <vector104>:
.globl vector104
vector104:
  pushl $0
8010782e:	6a 00                	push   $0x0
  pushl $104
80107830:	6a 68                	push   $0x68
  jmp alltraps
80107832:	e9 15 f6 ff ff       	jmp    80106e4c <alltraps>

80107837 <vector105>:
.globl vector105
vector105:
  pushl $0
80107837:	6a 00                	push   $0x0
  pushl $105
80107839:	6a 69                	push   $0x69
  jmp alltraps
8010783b:	e9 0c f6 ff ff       	jmp    80106e4c <alltraps>

80107840 <vector106>:
.globl vector106
vector106:
  pushl $0
80107840:	6a 00                	push   $0x0
  pushl $106
80107842:	6a 6a                	push   $0x6a
  jmp alltraps
80107844:	e9 03 f6 ff ff       	jmp    80106e4c <alltraps>

80107849 <vector107>:
.globl vector107
vector107:
  pushl $0
80107849:	6a 00                	push   $0x0
  pushl $107
8010784b:	6a 6b                	push   $0x6b
  jmp alltraps
8010784d:	e9 fa f5 ff ff       	jmp    80106e4c <alltraps>

80107852 <vector108>:
.globl vector108
vector108:
  pushl $0
80107852:	6a 00                	push   $0x0
  pushl $108
80107854:	6a 6c                	push   $0x6c
  jmp alltraps
80107856:	e9 f1 f5 ff ff       	jmp    80106e4c <alltraps>

8010785b <vector109>:
.globl vector109
vector109:
  pushl $0
8010785b:	6a 00                	push   $0x0
  pushl $109
8010785d:	6a 6d                	push   $0x6d
  jmp alltraps
8010785f:	e9 e8 f5 ff ff       	jmp    80106e4c <alltraps>

80107864 <vector110>:
.globl vector110
vector110:
  pushl $0
80107864:	6a 00                	push   $0x0
  pushl $110
80107866:	6a 6e                	push   $0x6e
  jmp alltraps
80107868:	e9 df f5 ff ff       	jmp    80106e4c <alltraps>

8010786d <vector111>:
.globl vector111
vector111:
  pushl $0
8010786d:	6a 00                	push   $0x0
  pushl $111
8010786f:	6a 6f                	push   $0x6f
  jmp alltraps
80107871:	e9 d6 f5 ff ff       	jmp    80106e4c <alltraps>

80107876 <vector112>:
.globl vector112
vector112:
  pushl $0
80107876:	6a 00                	push   $0x0
  pushl $112
80107878:	6a 70                	push   $0x70
  jmp alltraps
8010787a:	e9 cd f5 ff ff       	jmp    80106e4c <alltraps>

8010787f <vector113>:
.globl vector113
vector113:
  pushl $0
8010787f:	6a 00                	push   $0x0
  pushl $113
80107881:	6a 71                	push   $0x71
  jmp alltraps
80107883:	e9 c4 f5 ff ff       	jmp    80106e4c <alltraps>

80107888 <vector114>:
.globl vector114
vector114:
  pushl $0
80107888:	6a 00                	push   $0x0
  pushl $114
8010788a:	6a 72                	push   $0x72
  jmp alltraps
8010788c:	e9 bb f5 ff ff       	jmp    80106e4c <alltraps>

80107891 <vector115>:
.globl vector115
vector115:
  pushl $0
80107891:	6a 00                	push   $0x0
  pushl $115
80107893:	6a 73                	push   $0x73
  jmp alltraps
80107895:	e9 b2 f5 ff ff       	jmp    80106e4c <alltraps>

8010789a <vector116>:
.globl vector116
vector116:
  pushl $0
8010789a:	6a 00                	push   $0x0
  pushl $116
8010789c:	6a 74                	push   $0x74
  jmp alltraps
8010789e:	e9 a9 f5 ff ff       	jmp    80106e4c <alltraps>

801078a3 <vector117>:
.globl vector117
vector117:
  pushl $0
801078a3:	6a 00                	push   $0x0
  pushl $117
801078a5:	6a 75                	push   $0x75
  jmp alltraps
801078a7:	e9 a0 f5 ff ff       	jmp    80106e4c <alltraps>

801078ac <vector118>:
.globl vector118
vector118:
  pushl $0
801078ac:	6a 00                	push   $0x0
  pushl $118
801078ae:	6a 76                	push   $0x76
  jmp alltraps
801078b0:	e9 97 f5 ff ff       	jmp    80106e4c <alltraps>

801078b5 <vector119>:
.globl vector119
vector119:
  pushl $0
801078b5:	6a 00                	push   $0x0
  pushl $119
801078b7:	6a 77                	push   $0x77
  jmp alltraps
801078b9:	e9 8e f5 ff ff       	jmp    80106e4c <alltraps>

801078be <vector120>:
.globl vector120
vector120:
  pushl $0
801078be:	6a 00                	push   $0x0
  pushl $120
801078c0:	6a 78                	push   $0x78
  jmp alltraps
801078c2:	e9 85 f5 ff ff       	jmp    80106e4c <alltraps>

801078c7 <vector121>:
.globl vector121
vector121:
  pushl $0
801078c7:	6a 00                	push   $0x0
  pushl $121
801078c9:	6a 79                	push   $0x79
  jmp alltraps
801078cb:	e9 7c f5 ff ff       	jmp    80106e4c <alltraps>

801078d0 <vector122>:
.globl vector122
vector122:
  pushl $0
801078d0:	6a 00                	push   $0x0
  pushl $122
801078d2:	6a 7a                	push   $0x7a
  jmp alltraps
801078d4:	e9 73 f5 ff ff       	jmp    80106e4c <alltraps>

801078d9 <vector123>:
.globl vector123
vector123:
  pushl $0
801078d9:	6a 00                	push   $0x0
  pushl $123
801078db:	6a 7b                	push   $0x7b
  jmp alltraps
801078dd:	e9 6a f5 ff ff       	jmp    80106e4c <alltraps>

801078e2 <vector124>:
.globl vector124
vector124:
  pushl $0
801078e2:	6a 00                	push   $0x0
  pushl $124
801078e4:	6a 7c                	push   $0x7c
  jmp alltraps
801078e6:	e9 61 f5 ff ff       	jmp    80106e4c <alltraps>

801078eb <vector125>:
.globl vector125
vector125:
  pushl $0
801078eb:	6a 00                	push   $0x0
  pushl $125
801078ed:	6a 7d                	push   $0x7d
  jmp alltraps
801078ef:	e9 58 f5 ff ff       	jmp    80106e4c <alltraps>

801078f4 <vector126>:
.globl vector126
vector126:
  pushl $0
801078f4:	6a 00                	push   $0x0
  pushl $126
801078f6:	6a 7e                	push   $0x7e
  jmp alltraps
801078f8:	e9 4f f5 ff ff       	jmp    80106e4c <alltraps>

801078fd <vector127>:
.globl vector127
vector127:
  pushl $0
801078fd:	6a 00                	push   $0x0
  pushl $127
801078ff:	6a 7f                	push   $0x7f
  jmp alltraps
80107901:	e9 46 f5 ff ff       	jmp    80106e4c <alltraps>

80107906 <vector128>:
.globl vector128
vector128:
  pushl $0
80107906:	6a 00                	push   $0x0
  pushl $128
80107908:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010790d:	e9 3a f5 ff ff       	jmp    80106e4c <alltraps>

80107912 <vector129>:
.globl vector129
vector129:
  pushl $0
80107912:	6a 00                	push   $0x0
  pushl $129
80107914:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107919:	e9 2e f5 ff ff       	jmp    80106e4c <alltraps>

8010791e <vector130>:
.globl vector130
vector130:
  pushl $0
8010791e:	6a 00                	push   $0x0
  pushl $130
80107920:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107925:	e9 22 f5 ff ff       	jmp    80106e4c <alltraps>

8010792a <vector131>:
.globl vector131
vector131:
  pushl $0
8010792a:	6a 00                	push   $0x0
  pushl $131
8010792c:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107931:	e9 16 f5 ff ff       	jmp    80106e4c <alltraps>

80107936 <vector132>:
.globl vector132
vector132:
  pushl $0
80107936:	6a 00                	push   $0x0
  pushl $132
80107938:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010793d:	e9 0a f5 ff ff       	jmp    80106e4c <alltraps>

80107942 <vector133>:
.globl vector133
vector133:
  pushl $0
80107942:	6a 00                	push   $0x0
  pushl $133
80107944:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107949:	e9 fe f4 ff ff       	jmp    80106e4c <alltraps>

8010794e <vector134>:
.globl vector134
vector134:
  pushl $0
8010794e:	6a 00                	push   $0x0
  pushl $134
80107950:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107955:	e9 f2 f4 ff ff       	jmp    80106e4c <alltraps>

8010795a <vector135>:
.globl vector135
vector135:
  pushl $0
8010795a:	6a 00                	push   $0x0
  pushl $135
8010795c:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107961:	e9 e6 f4 ff ff       	jmp    80106e4c <alltraps>

80107966 <vector136>:
.globl vector136
vector136:
  pushl $0
80107966:	6a 00                	push   $0x0
  pushl $136
80107968:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010796d:	e9 da f4 ff ff       	jmp    80106e4c <alltraps>

80107972 <vector137>:
.globl vector137
vector137:
  pushl $0
80107972:	6a 00                	push   $0x0
  pushl $137
80107974:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107979:	e9 ce f4 ff ff       	jmp    80106e4c <alltraps>

8010797e <vector138>:
.globl vector138
vector138:
  pushl $0
8010797e:	6a 00                	push   $0x0
  pushl $138
80107980:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107985:	e9 c2 f4 ff ff       	jmp    80106e4c <alltraps>

8010798a <vector139>:
.globl vector139
vector139:
  pushl $0
8010798a:	6a 00                	push   $0x0
  pushl $139
8010798c:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107991:	e9 b6 f4 ff ff       	jmp    80106e4c <alltraps>

80107996 <vector140>:
.globl vector140
vector140:
  pushl $0
80107996:	6a 00                	push   $0x0
  pushl $140
80107998:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010799d:	e9 aa f4 ff ff       	jmp    80106e4c <alltraps>

801079a2 <vector141>:
.globl vector141
vector141:
  pushl $0
801079a2:	6a 00                	push   $0x0
  pushl $141
801079a4:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801079a9:	e9 9e f4 ff ff       	jmp    80106e4c <alltraps>

801079ae <vector142>:
.globl vector142
vector142:
  pushl $0
801079ae:	6a 00                	push   $0x0
  pushl $142
801079b0:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801079b5:	e9 92 f4 ff ff       	jmp    80106e4c <alltraps>

801079ba <vector143>:
.globl vector143
vector143:
  pushl $0
801079ba:	6a 00                	push   $0x0
  pushl $143
801079bc:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801079c1:	e9 86 f4 ff ff       	jmp    80106e4c <alltraps>

801079c6 <vector144>:
.globl vector144
vector144:
  pushl $0
801079c6:	6a 00                	push   $0x0
  pushl $144
801079c8:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801079cd:	e9 7a f4 ff ff       	jmp    80106e4c <alltraps>

801079d2 <vector145>:
.globl vector145
vector145:
  pushl $0
801079d2:	6a 00                	push   $0x0
  pushl $145
801079d4:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801079d9:	e9 6e f4 ff ff       	jmp    80106e4c <alltraps>

801079de <vector146>:
.globl vector146
vector146:
  pushl $0
801079de:	6a 00                	push   $0x0
  pushl $146
801079e0:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801079e5:	e9 62 f4 ff ff       	jmp    80106e4c <alltraps>

801079ea <vector147>:
.globl vector147
vector147:
  pushl $0
801079ea:	6a 00                	push   $0x0
  pushl $147
801079ec:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801079f1:	e9 56 f4 ff ff       	jmp    80106e4c <alltraps>

801079f6 <vector148>:
.globl vector148
vector148:
  pushl $0
801079f6:	6a 00                	push   $0x0
  pushl $148
801079f8:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801079fd:	e9 4a f4 ff ff       	jmp    80106e4c <alltraps>

80107a02 <vector149>:
.globl vector149
vector149:
  pushl $0
80107a02:	6a 00                	push   $0x0
  pushl $149
80107a04:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107a09:	e9 3e f4 ff ff       	jmp    80106e4c <alltraps>

80107a0e <vector150>:
.globl vector150
vector150:
  pushl $0
80107a0e:	6a 00                	push   $0x0
  pushl $150
80107a10:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107a15:	e9 32 f4 ff ff       	jmp    80106e4c <alltraps>

80107a1a <vector151>:
.globl vector151
vector151:
  pushl $0
80107a1a:	6a 00                	push   $0x0
  pushl $151
80107a1c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107a21:	e9 26 f4 ff ff       	jmp    80106e4c <alltraps>

80107a26 <vector152>:
.globl vector152
vector152:
  pushl $0
80107a26:	6a 00                	push   $0x0
  pushl $152
80107a28:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107a2d:	e9 1a f4 ff ff       	jmp    80106e4c <alltraps>

80107a32 <vector153>:
.globl vector153
vector153:
  pushl $0
80107a32:	6a 00                	push   $0x0
  pushl $153
80107a34:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107a39:	e9 0e f4 ff ff       	jmp    80106e4c <alltraps>

80107a3e <vector154>:
.globl vector154
vector154:
  pushl $0
80107a3e:	6a 00                	push   $0x0
  pushl $154
80107a40:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107a45:	e9 02 f4 ff ff       	jmp    80106e4c <alltraps>

80107a4a <vector155>:
.globl vector155
vector155:
  pushl $0
80107a4a:	6a 00                	push   $0x0
  pushl $155
80107a4c:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107a51:	e9 f6 f3 ff ff       	jmp    80106e4c <alltraps>

80107a56 <vector156>:
.globl vector156
vector156:
  pushl $0
80107a56:	6a 00                	push   $0x0
  pushl $156
80107a58:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107a5d:	e9 ea f3 ff ff       	jmp    80106e4c <alltraps>

80107a62 <vector157>:
.globl vector157
vector157:
  pushl $0
80107a62:	6a 00                	push   $0x0
  pushl $157
80107a64:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107a69:	e9 de f3 ff ff       	jmp    80106e4c <alltraps>

80107a6e <vector158>:
.globl vector158
vector158:
  pushl $0
80107a6e:	6a 00                	push   $0x0
  pushl $158
80107a70:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107a75:	e9 d2 f3 ff ff       	jmp    80106e4c <alltraps>

80107a7a <vector159>:
.globl vector159
vector159:
  pushl $0
80107a7a:	6a 00                	push   $0x0
  pushl $159
80107a7c:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107a81:	e9 c6 f3 ff ff       	jmp    80106e4c <alltraps>

80107a86 <vector160>:
.globl vector160
vector160:
  pushl $0
80107a86:	6a 00                	push   $0x0
  pushl $160
80107a88:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107a8d:	e9 ba f3 ff ff       	jmp    80106e4c <alltraps>

80107a92 <vector161>:
.globl vector161
vector161:
  pushl $0
80107a92:	6a 00                	push   $0x0
  pushl $161
80107a94:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107a99:	e9 ae f3 ff ff       	jmp    80106e4c <alltraps>

80107a9e <vector162>:
.globl vector162
vector162:
  pushl $0
80107a9e:	6a 00                	push   $0x0
  pushl $162
80107aa0:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107aa5:	e9 a2 f3 ff ff       	jmp    80106e4c <alltraps>

80107aaa <vector163>:
.globl vector163
vector163:
  pushl $0
80107aaa:	6a 00                	push   $0x0
  pushl $163
80107aac:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107ab1:	e9 96 f3 ff ff       	jmp    80106e4c <alltraps>

80107ab6 <vector164>:
.globl vector164
vector164:
  pushl $0
80107ab6:	6a 00                	push   $0x0
  pushl $164
80107ab8:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107abd:	e9 8a f3 ff ff       	jmp    80106e4c <alltraps>

80107ac2 <vector165>:
.globl vector165
vector165:
  pushl $0
80107ac2:	6a 00                	push   $0x0
  pushl $165
80107ac4:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107ac9:	e9 7e f3 ff ff       	jmp    80106e4c <alltraps>

80107ace <vector166>:
.globl vector166
vector166:
  pushl $0
80107ace:	6a 00                	push   $0x0
  pushl $166
80107ad0:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107ad5:	e9 72 f3 ff ff       	jmp    80106e4c <alltraps>

80107ada <vector167>:
.globl vector167
vector167:
  pushl $0
80107ada:	6a 00                	push   $0x0
  pushl $167
80107adc:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107ae1:	e9 66 f3 ff ff       	jmp    80106e4c <alltraps>

80107ae6 <vector168>:
.globl vector168
vector168:
  pushl $0
80107ae6:	6a 00                	push   $0x0
  pushl $168
80107ae8:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107aed:	e9 5a f3 ff ff       	jmp    80106e4c <alltraps>

80107af2 <vector169>:
.globl vector169
vector169:
  pushl $0
80107af2:	6a 00                	push   $0x0
  pushl $169
80107af4:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107af9:	e9 4e f3 ff ff       	jmp    80106e4c <alltraps>

80107afe <vector170>:
.globl vector170
vector170:
  pushl $0
80107afe:	6a 00                	push   $0x0
  pushl $170
80107b00:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107b05:	e9 42 f3 ff ff       	jmp    80106e4c <alltraps>

80107b0a <vector171>:
.globl vector171
vector171:
  pushl $0
80107b0a:	6a 00                	push   $0x0
  pushl $171
80107b0c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107b11:	e9 36 f3 ff ff       	jmp    80106e4c <alltraps>

80107b16 <vector172>:
.globl vector172
vector172:
  pushl $0
80107b16:	6a 00                	push   $0x0
  pushl $172
80107b18:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107b1d:	e9 2a f3 ff ff       	jmp    80106e4c <alltraps>

80107b22 <vector173>:
.globl vector173
vector173:
  pushl $0
80107b22:	6a 00                	push   $0x0
  pushl $173
80107b24:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107b29:	e9 1e f3 ff ff       	jmp    80106e4c <alltraps>

80107b2e <vector174>:
.globl vector174
vector174:
  pushl $0
80107b2e:	6a 00                	push   $0x0
  pushl $174
80107b30:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107b35:	e9 12 f3 ff ff       	jmp    80106e4c <alltraps>

80107b3a <vector175>:
.globl vector175
vector175:
  pushl $0
80107b3a:	6a 00                	push   $0x0
  pushl $175
80107b3c:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107b41:	e9 06 f3 ff ff       	jmp    80106e4c <alltraps>

80107b46 <vector176>:
.globl vector176
vector176:
  pushl $0
80107b46:	6a 00                	push   $0x0
  pushl $176
80107b48:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107b4d:	e9 fa f2 ff ff       	jmp    80106e4c <alltraps>

80107b52 <vector177>:
.globl vector177
vector177:
  pushl $0
80107b52:	6a 00                	push   $0x0
  pushl $177
80107b54:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107b59:	e9 ee f2 ff ff       	jmp    80106e4c <alltraps>

80107b5e <vector178>:
.globl vector178
vector178:
  pushl $0
80107b5e:	6a 00                	push   $0x0
  pushl $178
80107b60:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107b65:	e9 e2 f2 ff ff       	jmp    80106e4c <alltraps>

80107b6a <vector179>:
.globl vector179
vector179:
  pushl $0
80107b6a:	6a 00                	push   $0x0
  pushl $179
80107b6c:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107b71:	e9 d6 f2 ff ff       	jmp    80106e4c <alltraps>

80107b76 <vector180>:
.globl vector180
vector180:
  pushl $0
80107b76:	6a 00                	push   $0x0
  pushl $180
80107b78:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107b7d:	e9 ca f2 ff ff       	jmp    80106e4c <alltraps>

80107b82 <vector181>:
.globl vector181
vector181:
  pushl $0
80107b82:	6a 00                	push   $0x0
  pushl $181
80107b84:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107b89:	e9 be f2 ff ff       	jmp    80106e4c <alltraps>

80107b8e <vector182>:
.globl vector182
vector182:
  pushl $0
80107b8e:	6a 00                	push   $0x0
  pushl $182
80107b90:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107b95:	e9 b2 f2 ff ff       	jmp    80106e4c <alltraps>

80107b9a <vector183>:
.globl vector183
vector183:
  pushl $0
80107b9a:	6a 00                	push   $0x0
  pushl $183
80107b9c:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107ba1:	e9 a6 f2 ff ff       	jmp    80106e4c <alltraps>

80107ba6 <vector184>:
.globl vector184
vector184:
  pushl $0
80107ba6:	6a 00                	push   $0x0
  pushl $184
80107ba8:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107bad:	e9 9a f2 ff ff       	jmp    80106e4c <alltraps>

80107bb2 <vector185>:
.globl vector185
vector185:
  pushl $0
80107bb2:	6a 00                	push   $0x0
  pushl $185
80107bb4:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107bb9:	e9 8e f2 ff ff       	jmp    80106e4c <alltraps>

80107bbe <vector186>:
.globl vector186
vector186:
  pushl $0
80107bbe:	6a 00                	push   $0x0
  pushl $186
80107bc0:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107bc5:	e9 82 f2 ff ff       	jmp    80106e4c <alltraps>

80107bca <vector187>:
.globl vector187
vector187:
  pushl $0
80107bca:	6a 00                	push   $0x0
  pushl $187
80107bcc:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107bd1:	e9 76 f2 ff ff       	jmp    80106e4c <alltraps>

80107bd6 <vector188>:
.globl vector188
vector188:
  pushl $0
80107bd6:	6a 00                	push   $0x0
  pushl $188
80107bd8:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107bdd:	e9 6a f2 ff ff       	jmp    80106e4c <alltraps>

80107be2 <vector189>:
.globl vector189
vector189:
  pushl $0
80107be2:	6a 00                	push   $0x0
  pushl $189
80107be4:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107be9:	e9 5e f2 ff ff       	jmp    80106e4c <alltraps>

80107bee <vector190>:
.globl vector190
vector190:
  pushl $0
80107bee:	6a 00                	push   $0x0
  pushl $190
80107bf0:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107bf5:	e9 52 f2 ff ff       	jmp    80106e4c <alltraps>

80107bfa <vector191>:
.globl vector191
vector191:
  pushl $0
80107bfa:	6a 00                	push   $0x0
  pushl $191
80107bfc:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107c01:	e9 46 f2 ff ff       	jmp    80106e4c <alltraps>

80107c06 <vector192>:
.globl vector192
vector192:
  pushl $0
80107c06:	6a 00                	push   $0x0
  pushl $192
80107c08:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107c0d:	e9 3a f2 ff ff       	jmp    80106e4c <alltraps>

80107c12 <vector193>:
.globl vector193
vector193:
  pushl $0
80107c12:	6a 00                	push   $0x0
  pushl $193
80107c14:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107c19:	e9 2e f2 ff ff       	jmp    80106e4c <alltraps>

80107c1e <vector194>:
.globl vector194
vector194:
  pushl $0
80107c1e:	6a 00                	push   $0x0
  pushl $194
80107c20:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107c25:	e9 22 f2 ff ff       	jmp    80106e4c <alltraps>

80107c2a <vector195>:
.globl vector195
vector195:
  pushl $0
80107c2a:	6a 00                	push   $0x0
  pushl $195
80107c2c:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107c31:	e9 16 f2 ff ff       	jmp    80106e4c <alltraps>

80107c36 <vector196>:
.globl vector196
vector196:
  pushl $0
80107c36:	6a 00                	push   $0x0
  pushl $196
80107c38:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107c3d:	e9 0a f2 ff ff       	jmp    80106e4c <alltraps>

80107c42 <vector197>:
.globl vector197
vector197:
  pushl $0
80107c42:	6a 00                	push   $0x0
  pushl $197
80107c44:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107c49:	e9 fe f1 ff ff       	jmp    80106e4c <alltraps>

80107c4e <vector198>:
.globl vector198
vector198:
  pushl $0
80107c4e:	6a 00                	push   $0x0
  pushl $198
80107c50:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107c55:	e9 f2 f1 ff ff       	jmp    80106e4c <alltraps>

80107c5a <vector199>:
.globl vector199
vector199:
  pushl $0
80107c5a:	6a 00                	push   $0x0
  pushl $199
80107c5c:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107c61:	e9 e6 f1 ff ff       	jmp    80106e4c <alltraps>

80107c66 <vector200>:
.globl vector200
vector200:
  pushl $0
80107c66:	6a 00                	push   $0x0
  pushl $200
80107c68:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107c6d:	e9 da f1 ff ff       	jmp    80106e4c <alltraps>

80107c72 <vector201>:
.globl vector201
vector201:
  pushl $0
80107c72:	6a 00                	push   $0x0
  pushl $201
80107c74:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107c79:	e9 ce f1 ff ff       	jmp    80106e4c <alltraps>

80107c7e <vector202>:
.globl vector202
vector202:
  pushl $0
80107c7e:	6a 00                	push   $0x0
  pushl $202
80107c80:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107c85:	e9 c2 f1 ff ff       	jmp    80106e4c <alltraps>

80107c8a <vector203>:
.globl vector203
vector203:
  pushl $0
80107c8a:	6a 00                	push   $0x0
  pushl $203
80107c8c:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107c91:	e9 b6 f1 ff ff       	jmp    80106e4c <alltraps>

80107c96 <vector204>:
.globl vector204
vector204:
  pushl $0
80107c96:	6a 00                	push   $0x0
  pushl $204
80107c98:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107c9d:	e9 aa f1 ff ff       	jmp    80106e4c <alltraps>

80107ca2 <vector205>:
.globl vector205
vector205:
  pushl $0
80107ca2:	6a 00                	push   $0x0
  pushl $205
80107ca4:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107ca9:	e9 9e f1 ff ff       	jmp    80106e4c <alltraps>

80107cae <vector206>:
.globl vector206
vector206:
  pushl $0
80107cae:	6a 00                	push   $0x0
  pushl $206
80107cb0:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107cb5:	e9 92 f1 ff ff       	jmp    80106e4c <alltraps>

80107cba <vector207>:
.globl vector207
vector207:
  pushl $0
80107cba:	6a 00                	push   $0x0
  pushl $207
80107cbc:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107cc1:	e9 86 f1 ff ff       	jmp    80106e4c <alltraps>

80107cc6 <vector208>:
.globl vector208
vector208:
  pushl $0
80107cc6:	6a 00                	push   $0x0
  pushl $208
80107cc8:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107ccd:	e9 7a f1 ff ff       	jmp    80106e4c <alltraps>

80107cd2 <vector209>:
.globl vector209
vector209:
  pushl $0
80107cd2:	6a 00                	push   $0x0
  pushl $209
80107cd4:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107cd9:	e9 6e f1 ff ff       	jmp    80106e4c <alltraps>

80107cde <vector210>:
.globl vector210
vector210:
  pushl $0
80107cde:	6a 00                	push   $0x0
  pushl $210
80107ce0:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107ce5:	e9 62 f1 ff ff       	jmp    80106e4c <alltraps>

80107cea <vector211>:
.globl vector211
vector211:
  pushl $0
80107cea:	6a 00                	push   $0x0
  pushl $211
80107cec:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107cf1:	e9 56 f1 ff ff       	jmp    80106e4c <alltraps>

80107cf6 <vector212>:
.globl vector212
vector212:
  pushl $0
80107cf6:	6a 00                	push   $0x0
  pushl $212
80107cf8:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107cfd:	e9 4a f1 ff ff       	jmp    80106e4c <alltraps>

80107d02 <vector213>:
.globl vector213
vector213:
  pushl $0
80107d02:	6a 00                	push   $0x0
  pushl $213
80107d04:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107d09:	e9 3e f1 ff ff       	jmp    80106e4c <alltraps>

80107d0e <vector214>:
.globl vector214
vector214:
  pushl $0
80107d0e:	6a 00                	push   $0x0
  pushl $214
80107d10:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107d15:	e9 32 f1 ff ff       	jmp    80106e4c <alltraps>

80107d1a <vector215>:
.globl vector215
vector215:
  pushl $0
80107d1a:	6a 00                	push   $0x0
  pushl $215
80107d1c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107d21:	e9 26 f1 ff ff       	jmp    80106e4c <alltraps>

80107d26 <vector216>:
.globl vector216
vector216:
  pushl $0
80107d26:	6a 00                	push   $0x0
  pushl $216
80107d28:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107d2d:	e9 1a f1 ff ff       	jmp    80106e4c <alltraps>

80107d32 <vector217>:
.globl vector217
vector217:
  pushl $0
80107d32:	6a 00                	push   $0x0
  pushl $217
80107d34:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107d39:	e9 0e f1 ff ff       	jmp    80106e4c <alltraps>

80107d3e <vector218>:
.globl vector218
vector218:
  pushl $0
80107d3e:	6a 00                	push   $0x0
  pushl $218
80107d40:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107d45:	e9 02 f1 ff ff       	jmp    80106e4c <alltraps>

80107d4a <vector219>:
.globl vector219
vector219:
  pushl $0
80107d4a:	6a 00                	push   $0x0
  pushl $219
80107d4c:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107d51:	e9 f6 f0 ff ff       	jmp    80106e4c <alltraps>

80107d56 <vector220>:
.globl vector220
vector220:
  pushl $0
80107d56:	6a 00                	push   $0x0
  pushl $220
80107d58:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107d5d:	e9 ea f0 ff ff       	jmp    80106e4c <alltraps>

80107d62 <vector221>:
.globl vector221
vector221:
  pushl $0
80107d62:	6a 00                	push   $0x0
  pushl $221
80107d64:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107d69:	e9 de f0 ff ff       	jmp    80106e4c <alltraps>

80107d6e <vector222>:
.globl vector222
vector222:
  pushl $0
80107d6e:	6a 00                	push   $0x0
  pushl $222
80107d70:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107d75:	e9 d2 f0 ff ff       	jmp    80106e4c <alltraps>

80107d7a <vector223>:
.globl vector223
vector223:
  pushl $0
80107d7a:	6a 00                	push   $0x0
  pushl $223
80107d7c:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107d81:	e9 c6 f0 ff ff       	jmp    80106e4c <alltraps>

80107d86 <vector224>:
.globl vector224
vector224:
  pushl $0
80107d86:	6a 00                	push   $0x0
  pushl $224
80107d88:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107d8d:	e9 ba f0 ff ff       	jmp    80106e4c <alltraps>

80107d92 <vector225>:
.globl vector225
vector225:
  pushl $0
80107d92:	6a 00                	push   $0x0
  pushl $225
80107d94:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107d99:	e9 ae f0 ff ff       	jmp    80106e4c <alltraps>

80107d9e <vector226>:
.globl vector226
vector226:
  pushl $0
80107d9e:	6a 00                	push   $0x0
  pushl $226
80107da0:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107da5:	e9 a2 f0 ff ff       	jmp    80106e4c <alltraps>

80107daa <vector227>:
.globl vector227
vector227:
  pushl $0
80107daa:	6a 00                	push   $0x0
  pushl $227
80107dac:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107db1:	e9 96 f0 ff ff       	jmp    80106e4c <alltraps>

80107db6 <vector228>:
.globl vector228
vector228:
  pushl $0
80107db6:	6a 00                	push   $0x0
  pushl $228
80107db8:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107dbd:	e9 8a f0 ff ff       	jmp    80106e4c <alltraps>

80107dc2 <vector229>:
.globl vector229
vector229:
  pushl $0
80107dc2:	6a 00                	push   $0x0
  pushl $229
80107dc4:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107dc9:	e9 7e f0 ff ff       	jmp    80106e4c <alltraps>

80107dce <vector230>:
.globl vector230
vector230:
  pushl $0
80107dce:	6a 00                	push   $0x0
  pushl $230
80107dd0:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107dd5:	e9 72 f0 ff ff       	jmp    80106e4c <alltraps>

80107dda <vector231>:
.globl vector231
vector231:
  pushl $0
80107dda:	6a 00                	push   $0x0
  pushl $231
80107ddc:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107de1:	e9 66 f0 ff ff       	jmp    80106e4c <alltraps>

80107de6 <vector232>:
.globl vector232
vector232:
  pushl $0
80107de6:	6a 00                	push   $0x0
  pushl $232
80107de8:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107ded:	e9 5a f0 ff ff       	jmp    80106e4c <alltraps>

80107df2 <vector233>:
.globl vector233
vector233:
  pushl $0
80107df2:	6a 00                	push   $0x0
  pushl $233
80107df4:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107df9:	e9 4e f0 ff ff       	jmp    80106e4c <alltraps>

80107dfe <vector234>:
.globl vector234
vector234:
  pushl $0
80107dfe:	6a 00                	push   $0x0
  pushl $234
80107e00:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107e05:	e9 42 f0 ff ff       	jmp    80106e4c <alltraps>

80107e0a <vector235>:
.globl vector235
vector235:
  pushl $0
80107e0a:	6a 00                	push   $0x0
  pushl $235
80107e0c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107e11:	e9 36 f0 ff ff       	jmp    80106e4c <alltraps>

80107e16 <vector236>:
.globl vector236
vector236:
  pushl $0
80107e16:	6a 00                	push   $0x0
  pushl $236
80107e18:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107e1d:	e9 2a f0 ff ff       	jmp    80106e4c <alltraps>

80107e22 <vector237>:
.globl vector237
vector237:
  pushl $0
80107e22:	6a 00                	push   $0x0
  pushl $237
80107e24:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107e29:	e9 1e f0 ff ff       	jmp    80106e4c <alltraps>

80107e2e <vector238>:
.globl vector238
vector238:
  pushl $0
80107e2e:	6a 00                	push   $0x0
  pushl $238
80107e30:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107e35:	e9 12 f0 ff ff       	jmp    80106e4c <alltraps>

80107e3a <vector239>:
.globl vector239
vector239:
  pushl $0
80107e3a:	6a 00                	push   $0x0
  pushl $239
80107e3c:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107e41:	e9 06 f0 ff ff       	jmp    80106e4c <alltraps>

80107e46 <vector240>:
.globl vector240
vector240:
  pushl $0
80107e46:	6a 00                	push   $0x0
  pushl $240
80107e48:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107e4d:	e9 fa ef ff ff       	jmp    80106e4c <alltraps>

80107e52 <vector241>:
.globl vector241
vector241:
  pushl $0
80107e52:	6a 00                	push   $0x0
  pushl $241
80107e54:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107e59:	e9 ee ef ff ff       	jmp    80106e4c <alltraps>

80107e5e <vector242>:
.globl vector242
vector242:
  pushl $0
80107e5e:	6a 00                	push   $0x0
  pushl $242
80107e60:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107e65:	e9 e2 ef ff ff       	jmp    80106e4c <alltraps>

80107e6a <vector243>:
.globl vector243
vector243:
  pushl $0
80107e6a:	6a 00                	push   $0x0
  pushl $243
80107e6c:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107e71:	e9 d6 ef ff ff       	jmp    80106e4c <alltraps>

80107e76 <vector244>:
.globl vector244
vector244:
  pushl $0
80107e76:	6a 00                	push   $0x0
  pushl $244
80107e78:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107e7d:	e9 ca ef ff ff       	jmp    80106e4c <alltraps>

80107e82 <vector245>:
.globl vector245
vector245:
  pushl $0
80107e82:	6a 00                	push   $0x0
  pushl $245
80107e84:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107e89:	e9 be ef ff ff       	jmp    80106e4c <alltraps>

80107e8e <vector246>:
.globl vector246
vector246:
  pushl $0
80107e8e:	6a 00                	push   $0x0
  pushl $246
80107e90:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107e95:	e9 b2 ef ff ff       	jmp    80106e4c <alltraps>

80107e9a <vector247>:
.globl vector247
vector247:
  pushl $0
80107e9a:	6a 00                	push   $0x0
  pushl $247
80107e9c:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107ea1:	e9 a6 ef ff ff       	jmp    80106e4c <alltraps>

80107ea6 <vector248>:
.globl vector248
vector248:
  pushl $0
80107ea6:	6a 00                	push   $0x0
  pushl $248
80107ea8:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107ead:	e9 9a ef ff ff       	jmp    80106e4c <alltraps>

80107eb2 <vector249>:
.globl vector249
vector249:
  pushl $0
80107eb2:	6a 00                	push   $0x0
  pushl $249
80107eb4:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107eb9:	e9 8e ef ff ff       	jmp    80106e4c <alltraps>

80107ebe <vector250>:
.globl vector250
vector250:
  pushl $0
80107ebe:	6a 00                	push   $0x0
  pushl $250
80107ec0:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107ec5:	e9 82 ef ff ff       	jmp    80106e4c <alltraps>

80107eca <vector251>:
.globl vector251
vector251:
  pushl $0
80107eca:	6a 00                	push   $0x0
  pushl $251
80107ecc:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107ed1:	e9 76 ef ff ff       	jmp    80106e4c <alltraps>

80107ed6 <vector252>:
.globl vector252
vector252:
  pushl $0
80107ed6:	6a 00                	push   $0x0
  pushl $252
80107ed8:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107edd:	e9 6a ef ff ff       	jmp    80106e4c <alltraps>

80107ee2 <vector253>:
.globl vector253
vector253:
  pushl $0
80107ee2:	6a 00                	push   $0x0
  pushl $253
80107ee4:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107ee9:	e9 5e ef ff ff       	jmp    80106e4c <alltraps>

80107eee <vector254>:
.globl vector254
vector254:
  pushl $0
80107eee:	6a 00                	push   $0x0
  pushl $254
80107ef0:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107ef5:	e9 52 ef ff ff       	jmp    80106e4c <alltraps>

80107efa <vector255>:
.globl vector255
vector255:
  pushl $0
80107efa:	6a 00                	push   $0x0
  pushl $255
80107efc:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107f01:	e9 46 ef ff ff       	jmp    80106e4c <alltraps>
	...

80107f08 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107f08:	55                   	push   %ebp
80107f09:	89 e5                	mov    %esp,%ebp
80107f0b:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80107f0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80107f11:	48                   	dec    %eax
80107f12:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107f16:	8b 45 08             	mov    0x8(%ebp),%eax
80107f19:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107f1d:	8b 45 08             	mov    0x8(%ebp),%eax
80107f20:	c1 e8 10             	shr    $0x10,%eax
80107f23:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107f27:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107f2a:	0f 01 10             	lgdtl  (%eax)
}
80107f2d:	c9                   	leave  
80107f2e:	c3                   	ret    

80107f2f <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
80107f2f:	55                   	push   %ebp
80107f30:	89 e5                	mov    %esp,%ebp
80107f32:	83 ec 04             	sub    $0x4,%esp
80107f35:	8b 45 08             	mov    0x8(%ebp),%eax
80107f38:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80107f3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107f3f:	0f 00 d8             	ltr    %ax
}
80107f42:	c9                   	leave  
80107f43:	c3                   	ret    

80107f44 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
80107f44:	55                   	push   %ebp
80107f45:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107f47:	8b 45 08             	mov    0x8(%ebp),%eax
80107f4a:	0f 22 d8             	mov    %eax,%cr3
}
80107f4d:	5d                   	pop    %ebp
80107f4e:	c3                   	ret    

80107f4f <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80107f4f:	55                   	push   %ebp
80107f50:	89 e5                	mov    %esp,%ebp
80107f52:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80107f55:	e8 08 cc ff ff       	call   80104b62 <cpuid>
80107f5a:	89 c2                	mov    %eax,%edx
80107f5c:	89 d0                	mov    %edx,%eax
80107f5e:	c1 e0 02             	shl    $0x2,%eax
80107f61:	01 d0                	add    %edx,%eax
80107f63:	01 c0                	add    %eax,%eax
80107f65:	01 d0                	add    %edx,%eax
80107f67:	c1 e0 04             	shl    $0x4,%eax
80107f6a:	05 60 49 11 80       	add    $0x80114960,%eax
80107f6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80107f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f75:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80107f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7e:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80107f84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f87:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80107f8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f8e:	8a 50 7d             	mov    0x7d(%eax),%dl
80107f91:	83 e2 f0             	and    $0xfffffff0,%edx
80107f94:	83 ca 0a             	or     $0xa,%edx
80107f97:	88 50 7d             	mov    %dl,0x7d(%eax)
80107f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f9d:	8a 50 7d             	mov    0x7d(%eax),%dl
80107fa0:	83 ca 10             	or     $0x10,%edx
80107fa3:	88 50 7d             	mov    %dl,0x7d(%eax)
80107fa6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fa9:	8a 50 7d             	mov    0x7d(%eax),%dl
80107fac:	83 e2 9f             	and    $0xffffff9f,%edx
80107faf:	88 50 7d             	mov    %dl,0x7d(%eax)
80107fb2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fb5:	8a 50 7d             	mov    0x7d(%eax),%dl
80107fb8:	83 ca 80             	or     $0xffffff80,%edx
80107fbb:	88 50 7d             	mov    %dl,0x7d(%eax)
80107fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc1:	8a 50 7e             	mov    0x7e(%eax),%dl
80107fc4:	83 ca 0f             	or     $0xf,%edx
80107fc7:	88 50 7e             	mov    %dl,0x7e(%eax)
80107fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fcd:	8a 50 7e             	mov    0x7e(%eax),%dl
80107fd0:	83 e2 ef             	and    $0xffffffef,%edx
80107fd3:	88 50 7e             	mov    %dl,0x7e(%eax)
80107fd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd9:	8a 50 7e             	mov    0x7e(%eax),%dl
80107fdc:	83 e2 df             	and    $0xffffffdf,%edx
80107fdf:	88 50 7e             	mov    %dl,0x7e(%eax)
80107fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fe5:	8a 50 7e             	mov    0x7e(%eax),%dl
80107fe8:	83 ca 40             	or     $0x40,%edx
80107feb:	88 50 7e             	mov    %dl,0x7e(%eax)
80107fee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ff1:	8a 50 7e             	mov    0x7e(%eax),%dl
80107ff4:	83 ca 80             	or     $0xffffff80,%edx
80107ff7:	88 50 7e             	mov    %dl,0x7e(%eax)
80107ffa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ffd:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108001:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108004:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010800b:	ff ff 
8010800d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108010:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80108017:	00 00 
80108019:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010801c:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108023:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108026:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
8010802c:	83 e2 f0             	and    $0xfffffff0,%edx
8010802f:	83 ca 02             	or     $0x2,%edx
80108032:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108038:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010803b:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108041:	83 ca 10             	or     $0x10,%edx
80108044:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010804a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804d:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108053:	83 e2 9f             	and    $0xffffff9f,%edx
80108056:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010805c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010805f:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108065:	83 ca 80             	or     $0xffffff80,%edx
80108068:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010806e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108071:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108077:	83 ca 0f             	or     $0xf,%edx
8010807a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108083:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108089:	83 e2 ef             	and    $0xffffffef,%edx
8010808c:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108092:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108095:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010809b:	83 e2 df             	and    $0xffffffdf,%edx
8010809e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801080a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a7:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801080ad:	83 ca 40             	or     $0x40,%edx
801080b0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801080b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b9:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
801080bf:	83 ca 80             	or     $0xffffff80,%edx
801080c2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801080c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080cb:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
801080d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d5:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
801080dc:	ff ff 
801080de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e1:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
801080e8:	00 00 
801080ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ed:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
801080f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080f7:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801080fd:	83 e2 f0             	and    $0xfffffff0,%edx
80108100:	83 ca 0a             	or     $0xa,%edx
80108103:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010810c:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108112:	83 ca 10             	or     $0x10,%edx
80108115:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010811b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010811e:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108124:	83 ca 60             	or     $0x60,%edx
80108127:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010812d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108130:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
80108136:	83 ca 80             	or     $0xffffff80,%edx
80108139:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010813f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108142:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108148:	83 ca 0f             	or     $0xf,%edx
8010814b:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108151:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108154:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010815a:	83 e2 ef             	and    $0xffffffef,%edx
8010815d:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108166:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010816c:	83 e2 df             	and    $0xffffffdf,%edx
8010816f:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108175:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108178:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
8010817e:	83 ca 40             	or     $0x40,%edx
80108181:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108187:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010818a:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108190:	83 ca 80             	or     $0xffffff80,%edx
80108193:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108199:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010819c:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801081a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a6:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801081ad:	ff ff 
801081af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081b2:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801081b9:	00 00 
801081bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081be:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801081c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081c8:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801081ce:	83 e2 f0             	and    $0xfffffff0,%edx
801081d1:	83 ca 02             	or     $0x2,%edx
801081d4:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801081da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081dd:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801081e3:	83 ca 10             	or     $0x10,%edx
801081e6:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801081ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ef:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801081f5:	83 ca 60             	or     $0x60,%edx
801081f8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801081fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108201:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80108207:	83 ca 80             	or     $0xffffff80,%edx
8010820a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108210:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108213:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108219:	83 ca 0f             	or     $0xf,%edx
8010821c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108222:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108225:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010822b:	83 e2 ef             	and    $0xffffffef,%edx
8010822e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108234:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108237:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010823d:	83 e2 df             	and    $0xffffffdf,%edx
80108240:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108246:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108249:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
8010824f:	83 ca 40             	or     $0x40,%edx
80108252:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108258:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010825b:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108261:	83 ca 80             	or     $0xffffff80,%edx
80108264:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010826a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010826d:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80108274:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108277:	83 c0 70             	add    $0x70,%eax
8010827a:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80108281:	00 
80108282:	89 04 24             	mov    %eax,(%esp)
80108285:	e8 7e fc ff ff       	call   80107f08 <lgdt>
}
8010828a:	c9                   	leave  
8010828b:	c3                   	ret    

8010828c <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
8010828c:	55                   	push   %ebp
8010828d:	89 e5                	mov    %esp,%ebp
8010828f:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108292:	8b 45 0c             	mov    0xc(%ebp),%eax
80108295:	c1 e8 16             	shr    $0x16,%eax
80108298:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010829f:	8b 45 08             	mov    0x8(%ebp),%eax
801082a2:	01 d0                	add    %edx,%eax
801082a4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801082a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082aa:	8b 00                	mov    (%eax),%eax
801082ac:	83 e0 01             	and    $0x1,%eax
801082af:	85 c0                	test   %eax,%eax
801082b1:	74 14                	je     801082c7 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801082b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801082b6:	8b 00                	mov    (%eax),%eax
801082b8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801082bd:	05 00 00 00 80       	add    $0x80000000,%eax
801082c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801082c5:	eb 48                	jmp    8010830f <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801082c7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801082cb:	74 0e                	je     801082db <walkpgdir+0x4f>
801082cd:	e8 85 a9 ff ff       	call   80102c57 <kalloc>
801082d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801082d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801082d9:	75 07                	jne    801082e2 <walkpgdir+0x56>
      return 0;
801082db:	b8 00 00 00 00       	mov    $0x0,%eax
801082e0:	eb 44                	jmp    80108326 <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
801082e2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801082e9:	00 
801082ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801082f1:	00 
801082f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f5:	89 04 24             	mov    %eax,(%esp)
801082f8:	e8 c5 d3 ff ff       	call   801056c2 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801082fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108300:	05 00 00 00 80       	add    $0x80000000,%eax
80108305:	83 c8 07             	or     $0x7,%eax
80108308:	89 c2                	mov    %eax,%edx
8010830a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010830d:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010830f:	8b 45 0c             	mov    0xc(%ebp),%eax
80108312:	c1 e8 0c             	shr    $0xc,%eax
80108315:	25 ff 03 00 00       	and    $0x3ff,%eax
8010831a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108321:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108324:	01 d0                	add    %edx,%eax
}
80108326:	c9                   	leave  
80108327:	c3                   	ret    

80108328 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108328:	55                   	push   %ebp
80108329:	89 e5                	mov    %esp,%ebp
8010832b:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010832e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108331:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108336:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80108339:	8b 55 0c             	mov    0xc(%ebp),%edx
8010833c:	8b 45 10             	mov    0x10(%ebp),%eax
8010833f:	01 d0                	add    %edx,%eax
80108341:	48                   	dec    %eax
80108342:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108347:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
8010834a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80108351:	00 
80108352:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108355:	89 44 24 04          	mov    %eax,0x4(%esp)
80108359:	8b 45 08             	mov    0x8(%ebp),%eax
8010835c:	89 04 24             	mov    %eax,(%esp)
8010835f:	e8 28 ff ff ff       	call   8010828c <walkpgdir>
80108364:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108367:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010836b:	75 07                	jne    80108374 <mappages+0x4c>
      return -1;
8010836d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108372:	eb 48                	jmp    801083bc <mappages+0x94>
    if(*pte & PTE_P)
80108374:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108377:	8b 00                	mov    (%eax),%eax
80108379:	83 e0 01             	and    $0x1,%eax
8010837c:	85 c0                	test   %eax,%eax
8010837e:	74 0c                	je     8010838c <mappages+0x64>
      panic("remap");
80108380:	c7 04 24 30 94 10 80 	movl   $0x80109430,(%esp)
80108387:	e8 c8 81 ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
8010838c:	8b 45 18             	mov    0x18(%ebp),%eax
8010838f:	0b 45 14             	or     0x14(%ebp),%eax
80108392:	83 c8 01             	or     $0x1,%eax
80108395:	89 c2                	mov    %eax,%edx
80108397:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010839a:	89 10                	mov    %edx,(%eax)
    if(a == last)
8010839c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010839f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801083a2:	75 08                	jne    801083ac <mappages+0x84>
      break;
801083a4:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
801083a5:	b8 00 00 00 00       	mov    $0x0,%eax
801083aa:	eb 10                	jmp    801083bc <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
801083ac:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801083b3:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
801083ba:	eb 8e                	jmp    8010834a <mappages+0x22>
  return 0;
}
801083bc:	c9                   	leave  
801083bd:	c3                   	ret    

801083be <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801083be:	55                   	push   %ebp
801083bf:	89 e5                	mov    %esp,%ebp
801083c1:	53                   	push   %ebx
801083c2:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
801083c5:	e8 8d a8 ff ff       	call   80102c57 <kalloc>
801083ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
801083cd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801083d1:	75 0a                	jne    801083dd <setupkvm+0x1f>
    return 0;
801083d3:	b8 00 00 00 00       	mov    $0x0,%eax
801083d8:	e9 84 00 00 00       	jmp    80108461 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
801083dd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801083e4:	00 
801083e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801083ec:	00 
801083ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083f0:	89 04 24             	mov    %eax,(%esp)
801083f3:	e8 ca d2 ff ff       	call   801056c2 <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801083f8:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
801083ff:	eb 54                	jmp    80108455 <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80108401:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108404:	8b 48 0c             	mov    0xc(%eax),%ecx
80108407:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010840a:	8b 50 04             	mov    0x4(%eax),%edx
8010840d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108410:	8b 58 08             	mov    0x8(%eax),%ebx
80108413:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108416:	8b 40 04             	mov    0x4(%eax),%eax
80108419:	29 c3                	sub    %eax,%ebx
8010841b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841e:	8b 00                	mov    (%eax),%eax
80108420:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80108424:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108428:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010842c:	89 44 24 04          	mov    %eax,0x4(%esp)
80108430:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108433:	89 04 24             	mov    %eax,(%esp)
80108436:	e8 ed fe ff ff       	call   80108328 <mappages>
8010843b:	85 c0                	test   %eax,%eax
8010843d:	79 12                	jns    80108451 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
8010843f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108442:	89 04 24             	mov    %eax,(%esp)
80108445:	e8 1a 05 00 00       	call   80108964 <freevm>
      return 0;
8010844a:	b8 00 00 00 00       	mov    $0x0,%eax
8010844f:	eb 10                	jmp    80108461 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80108451:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80108455:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
8010845c:	72 a3                	jb     80108401 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
8010845e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108461:	83 c4 34             	add    $0x34,%esp
80108464:	5b                   	pop    %ebx
80108465:	5d                   	pop    %ebp
80108466:	c3                   	ret    

80108467 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108467:	55                   	push   %ebp
80108468:	89 e5                	mov    %esp,%ebp
8010846a:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010846d:	e8 4c ff ff ff       	call   801083be <setupkvm>
80108472:	a3 44 61 12 80       	mov    %eax,0x80126144
  switchkvm();
80108477:	e8 02 00 00 00       	call   8010847e <switchkvm>
}
8010847c:	c9                   	leave  
8010847d:	c3                   	ret    

8010847e <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
8010847e:	55                   	push   %ebp
8010847f:	89 e5                	mov    %esp,%ebp
80108481:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108484:	a1 44 61 12 80       	mov    0x80126144,%eax
80108489:	05 00 00 00 80       	add    $0x80000000,%eax
8010848e:	89 04 24             	mov    %eax,(%esp)
80108491:	e8 ae fa ff ff       	call   80107f44 <lcr3>
}
80108496:	c9                   	leave  
80108497:	c3                   	ret    

80108498 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80108498:	55                   	push   %ebp
80108499:	89 e5                	mov    %esp,%ebp
8010849b:	57                   	push   %edi
8010849c:	56                   	push   %esi
8010849d:	53                   	push   %ebx
8010849e:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
801084a1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801084a5:	75 0c                	jne    801084b3 <switchuvm+0x1b>
    panic("switchuvm: no process");
801084a7:	c7 04 24 36 94 10 80 	movl   $0x80109436,(%esp)
801084ae:	e8 a1 80 ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
801084b3:	8b 45 08             	mov    0x8(%ebp),%eax
801084b6:	8b 40 08             	mov    0x8(%eax),%eax
801084b9:	85 c0                	test   %eax,%eax
801084bb:	75 0c                	jne    801084c9 <switchuvm+0x31>
    panic("switchuvm: no kstack");
801084bd:	c7 04 24 4c 94 10 80 	movl   $0x8010944c,(%esp)
801084c4:	e8 8b 80 ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
801084c9:	8b 45 08             	mov    0x8(%ebp),%eax
801084cc:	8b 40 04             	mov    0x4(%eax),%eax
801084cf:	85 c0                	test   %eax,%eax
801084d1:	75 0c                	jne    801084df <switchuvm+0x47>
    panic("switchuvm: no pgdir");
801084d3:	c7 04 24 61 94 10 80 	movl   $0x80109461,(%esp)
801084da:	e8 75 80 ff ff       	call   80100554 <panic>

  pushcli();
801084df:	e8 da d0 ff ff       	call   801055be <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801084e4:	e8 be c6 ff ff       	call   80104ba7 <mycpu>
801084e9:	89 c3                	mov    %eax,%ebx
801084eb:	e8 b7 c6 ff ff       	call   80104ba7 <mycpu>
801084f0:	83 c0 08             	add    $0x8,%eax
801084f3:	89 c6                	mov    %eax,%esi
801084f5:	e8 ad c6 ff ff       	call   80104ba7 <mycpu>
801084fa:	83 c0 08             	add    $0x8,%eax
801084fd:	c1 e8 10             	shr    $0x10,%eax
80108500:	89 c7                	mov    %eax,%edi
80108502:	e8 a0 c6 ff ff       	call   80104ba7 <mycpu>
80108507:	83 c0 08             	add    $0x8,%eax
8010850a:	c1 e8 18             	shr    $0x18,%eax
8010850d:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80108514:	67 00 
80108516:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010851d:	89 f9                	mov    %edi,%ecx
8010851f:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80108525:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
8010852b:	83 e2 f0             	and    $0xfffffff0,%edx
8010852e:	83 ca 09             	or     $0x9,%edx
80108531:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108537:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
8010853d:	83 ca 10             	or     $0x10,%edx
80108540:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108546:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
8010854c:	83 e2 9f             	and    $0xffffff9f,%edx
8010854f:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108555:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
8010855b:	83 ca 80             	or     $0xffffff80,%edx
8010855e:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108564:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
8010856a:	83 e2 f0             	and    $0xfffffff0,%edx
8010856d:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108573:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108579:	83 e2 ef             	and    $0xffffffef,%edx
8010857c:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108582:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108588:	83 e2 df             	and    $0xffffffdf,%edx
8010858b:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108591:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108597:	83 ca 40             	or     $0x40,%edx
8010859a:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801085a0:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
801085a6:	83 e2 7f             	and    $0x7f,%edx
801085a9:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
801085af:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
801085b5:	e8 ed c5 ff ff       	call   80104ba7 <mycpu>
801085ba:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
801085c0:	83 e2 ef             	and    $0xffffffef,%edx
801085c3:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801085c9:	e8 d9 c5 ff ff       	call   80104ba7 <mycpu>
801085ce:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801085d4:	e8 ce c5 ff ff       	call   80104ba7 <mycpu>
801085d9:	8b 55 08             	mov    0x8(%ebp),%edx
801085dc:	8b 52 08             	mov    0x8(%edx),%edx
801085df:	81 c2 00 10 00 00    	add    $0x1000,%edx
801085e5:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801085e8:	e8 ba c5 ff ff       	call   80104ba7 <mycpu>
801085ed:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
801085f3:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
801085fa:	e8 30 f9 ff ff       	call   80107f2f <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
801085ff:	8b 45 08             	mov    0x8(%ebp),%eax
80108602:	8b 40 04             	mov    0x4(%eax),%eax
80108605:	05 00 00 00 80       	add    $0x80000000,%eax
8010860a:	89 04 24             	mov    %eax,(%esp)
8010860d:	e8 32 f9 ff ff       	call   80107f44 <lcr3>
  popcli();
80108612:	e8 f1 cf ff ff       	call   80105608 <popcli>
}
80108617:	83 c4 1c             	add    $0x1c,%esp
8010861a:	5b                   	pop    %ebx
8010861b:	5e                   	pop    %esi
8010861c:	5f                   	pop    %edi
8010861d:	5d                   	pop    %ebp
8010861e:	c3                   	ret    

8010861f <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010861f:	55                   	push   %ebp
80108620:	89 e5                	mov    %esp,%ebp
80108622:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80108625:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010862c:	76 0c                	jbe    8010863a <inituvm+0x1b>
    panic("inituvm: more than a page");
8010862e:	c7 04 24 75 94 10 80 	movl   $0x80109475,(%esp)
80108635:	e8 1a 7f ff ff       	call   80100554 <panic>
  mem = kalloc();
8010863a:	e8 18 a6 ff ff       	call   80102c57 <kalloc>
8010863f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108642:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108649:	00 
8010864a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108651:	00 
80108652:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108655:	89 04 24             	mov    %eax,(%esp)
80108658:	e8 65 d0 ff ff       	call   801056c2 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
8010865d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108660:	05 00 00 00 80       	add    $0x80000000,%eax
80108665:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
8010866c:	00 
8010866d:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108671:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108678:	00 
80108679:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108680:	00 
80108681:	8b 45 08             	mov    0x8(%ebp),%eax
80108684:	89 04 24             	mov    %eax,(%esp)
80108687:	e8 9c fc ff ff       	call   80108328 <mappages>
  memmove(mem, init, sz);
8010868c:	8b 45 10             	mov    0x10(%ebp),%eax
8010868f:	89 44 24 08          	mov    %eax,0x8(%esp)
80108693:	8b 45 0c             	mov    0xc(%ebp),%eax
80108696:	89 44 24 04          	mov    %eax,0x4(%esp)
8010869a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869d:	89 04 24             	mov    %eax,(%esp)
801086a0:	e8 e6 d0 ff ff       	call   8010578b <memmove>
}
801086a5:	c9                   	leave  
801086a6:	c3                   	ret    

801086a7 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801086a7:	55                   	push   %ebp
801086a8:	89 e5                	mov    %esp,%ebp
801086aa:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801086ad:	8b 45 0c             	mov    0xc(%ebp),%eax
801086b0:	25 ff 0f 00 00       	and    $0xfff,%eax
801086b5:	85 c0                	test   %eax,%eax
801086b7:	74 0c                	je     801086c5 <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
801086b9:	c7 04 24 90 94 10 80 	movl   $0x80109490,(%esp)
801086c0:	e8 8f 7e ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
801086c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801086cc:	e9 a6 00 00 00       	jmp    80108777 <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801086d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086d4:	8b 55 0c             	mov    0xc(%ebp),%edx
801086d7:	01 d0                	add    %edx,%eax
801086d9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801086e0:	00 
801086e1:	89 44 24 04          	mov    %eax,0x4(%esp)
801086e5:	8b 45 08             	mov    0x8(%ebp),%eax
801086e8:	89 04 24             	mov    %eax,(%esp)
801086eb:	e8 9c fb ff ff       	call   8010828c <walkpgdir>
801086f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
801086f3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801086f7:	75 0c                	jne    80108705 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
801086f9:	c7 04 24 b3 94 10 80 	movl   $0x801094b3,(%esp)
80108700:	e8 4f 7e ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108705:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108708:	8b 00                	mov    (%eax),%eax
8010870a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010870f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108712:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108715:	8b 55 18             	mov    0x18(%ebp),%edx
80108718:	29 c2                	sub    %eax,%edx
8010871a:	89 d0                	mov    %edx,%eax
8010871c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108721:	77 0f                	ja     80108732 <loaduvm+0x8b>
      n = sz - i;
80108723:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108726:	8b 55 18             	mov    0x18(%ebp),%edx
80108729:	29 c2                	sub    %eax,%edx
8010872b:	89 d0                	mov    %edx,%eax
8010872d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108730:	eb 07                	jmp    80108739 <loaduvm+0x92>
    else
      n = PGSIZE;
80108732:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108739:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010873c:	8b 55 14             	mov    0x14(%ebp),%edx
8010873f:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80108742:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108745:	05 00 00 00 80       	add    $0x80000000,%eax
8010874a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010874d:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108751:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80108755:	89 44 24 04          	mov    %eax,0x4(%esp)
80108759:	8b 45 10             	mov    0x10(%ebp),%eax
8010875c:	89 04 24             	mov    %eax,(%esp)
8010875f:	e8 59 97 ff ff       	call   80101ebd <readi>
80108764:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108767:	74 07                	je     80108770 <loaduvm+0xc9>
      return -1;
80108769:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010876e:	eb 18                	jmp    80108788 <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108770:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108777:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010877a:	3b 45 18             	cmp    0x18(%ebp),%eax
8010877d:	0f 82 4e ff ff ff    	jb     801086d1 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108783:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108788:	c9                   	leave  
80108789:	c3                   	ret    

8010878a <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
8010878a:	55                   	push   %ebp
8010878b:	89 e5                	mov    %esp,%ebp
8010878d:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108790:	8b 45 10             	mov    0x10(%ebp),%eax
80108793:	85 c0                	test   %eax,%eax
80108795:	79 0a                	jns    801087a1 <allocuvm+0x17>
    return 0;
80108797:	b8 00 00 00 00       	mov    $0x0,%eax
8010879c:	e9 fd 00 00 00       	jmp    8010889e <allocuvm+0x114>
  if(newsz < oldsz)
801087a1:	8b 45 10             	mov    0x10(%ebp),%eax
801087a4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801087a7:	73 08                	jae    801087b1 <allocuvm+0x27>
    return oldsz;
801087a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801087ac:	e9 ed 00 00 00       	jmp    8010889e <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
801087b1:	8b 45 0c             	mov    0xc(%ebp),%eax
801087b4:	05 ff 0f 00 00       	add    $0xfff,%eax
801087b9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
801087c1:	e9 c9 00 00 00       	jmp    8010888f <allocuvm+0x105>
    mem = kalloc();
801087c6:	e8 8c a4 ff ff       	call   80102c57 <kalloc>
801087cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
801087ce:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801087d2:	75 2f                	jne    80108803 <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
801087d4:	c7 04 24 d1 94 10 80 	movl   $0x801094d1,(%esp)
801087db:	e8 e1 7b ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801087e0:	8b 45 0c             	mov    0xc(%ebp),%eax
801087e3:	89 44 24 08          	mov    %eax,0x8(%esp)
801087e7:	8b 45 10             	mov    0x10(%ebp),%eax
801087ea:	89 44 24 04          	mov    %eax,0x4(%esp)
801087ee:	8b 45 08             	mov    0x8(%ebp),%eax
801087f1:	89 04 24             	mov    %eax,(%esp)
801087f4:	e8 a7 00 00 00       	call   801088a0 <deallocuvm>
      return 0;
801087f9:	b8 00 00 00 00       	mov    $0x0,%eax
801087fe:	e9 9b 00 00 00       	jmp    8010889e <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
80108803:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010880a:	00 
8010880b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108812:	00 
80108813:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108816:	89 04 24             	mov    %eax,(%esp)
80108819:	e8 a4 ce ff ff       	call   801056c2 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010881e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108821:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108827:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010882a:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108831:	00 
80108832:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108836:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010883d:	00 
8010883e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108842:	8b 45 08             	mov    0x8(%ebp),%eax
80108845:	89 04 24             	mov    %eax,(%esp)
80108848:	e8 db fa ff ff       	call   80108328 <mappages>
8010884d:	85 c0                	test   %eax,%eax
8010884f:	79 37                	jns    80108888 <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80108851:	c7 04 24 e9 94 10 80 	movl   $0x801094e9,(%esp)
80108858:	e8 64 7b ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010885d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108860:	89 44 24 08          	mov    %eax,0x8(%esp)
80108864:	8b 45 10             	mov    0x10(%ebp),%eax
80108867:	89 44 24 04          	mov    %eax,0x4(%esp)
8010886b:	8b 45 08             	mov    0x8(%ebp),%eax
8010886e:	89 04 24             	mov    %eax,(%esp)
80108871:	e8 2a 00 00 00       	call   801088a0 <deallocuvm>
      kfree(mem);
80108876:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108879:	89 04 24             	mov    %eax,(%esp)
8010887c:	e8 40 a3 ff ff       	call   80102bc1 <kfree>
      return 0;
80108881:	b8 00 00 00 00       	mov    $0x0,%eax
80108886:	eb 16                	jmp    8010889e <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108888:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010888f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108892:	3b 45 10             	cmp    0x10(%ebp),%eax
80108895:	0f 82 2b ff ff ff    	jb     801087c6 <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
8010889b:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010889e:	c9                   	leave  
8010889f:	c3                   	ret    

801088a0 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801088a0:	55                   	push   %ebp
801088a1:	89 e5                	mov    %esp,%ebp
801088a3:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801088a6:	8b 45 10             	mov    0x10(%ebp),%eax
801088a9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801088ac:	72 08                	jb     801088b6 <deallocuvm+0x16>
    return oldsz;
801088ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801088b1:	e9 ac 00 00 00       	jmp    80108962 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
801088b6:	8b 45 10             	mov    0x10(%ebp),%eax
801088b9:	05 ff 0f 00 00       	add    $0xfff,%eax
801088be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801088c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801088c6:	e9 88 00 00 00       	jmp    80108953 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
801088cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ce:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801088d5:	00 
801088d6:	89 44 24 04          	mov    %eax,0x4(%esp)
801088da:	8b 45 08             	mov    0x8(%ebp),%eax
801088dd:	89 04 24             	mov    %eax,(%esp)
801088e0:	e8 a7 f9 ff ff       	call   8010828c <walkpgdir>
801088e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
801088e8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801088ec:	75 14                	jne    80108902 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801088ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f1:	c1 e8 16             	shr    $0x16,%eax
801088f4:	40                   	inc    %eax
801088f5:	c1 e0 16             	shl    $0x16,%eax
801088f8:	2d 00 10 00 00       	sub    $0x1000,%eax
801088fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108900:	eb 4a                	jmp    8010894c <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80108902:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108905:	8b 00                	mov    (%eax),%eax
80108907:	83 e0 01             	and    $0x1,%eax
8010890a:	85 c0                	test   %eax,%eax
8010890c:	74 3e                	je     8010894c <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
8010890e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108911:	8b 00                	mov    (%eax),%eax
80108913:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108918:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010891b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010891f:	75 0c                	jne    8010892d <deallocuvm+0x8d>
        panic("kfree");
80108921:	c7 04 24 05 95 10 80 	movl   $0x80109505,(%esp)
80108928:	e8 27 7c ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
8010892d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108930:	05 00 00 00 80       	add    $0x80000000,%eax
80108935:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108938:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010893b:	89 04 24             	mov    %eax,(%esp)
8010893e:	e8 7e a2 ff ff       	call   80102bc1 <kfree>
      *pte = 0;
80108943:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108946:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010894c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108953:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108956:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108959:	0f 82 6c ff ff ff    	jb     801088cb <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010895f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108962:	c9                   	leave  
80108963:	c3                   	ret    

80108964 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108964:	55                   	push   %ebp
80108965:	89 e5                	mov    %esp,%ebp
80108967:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
8010896a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010896e:	75 0c                	jne    8010897c <freevm+0x18>
    panic("freevm: no pgdir");
80108970:	c7 04 24 0b 95 10 80 	movl   $0x8010950b,(%esp)
80108977:	e8 d8 7b ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010897c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108983:	00 
80108984:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
8010898b:	80 
8010898c:	8b 45 08             	mov    0x8(%ebp),%eax
8010898f:	89 04 24             	mov    %eax,(%esp)
80108992:	e8 09 ff ff ff       	call   801088a0 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108997:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010899e:	eb 44                	jmp    801089e4 <freevm+0x80>
    if(pgdir[i] & PTE_P){
801089a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089a3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801089aa:	8b 45 08             	mov    0x8(%ebp),%eax
801089ad:	01 d0                	add    %edx,%eax
801089af:	8b 00                	mov    (%eax),%eax
801089b1:	83 e0 01             	and    $0x1,%eax
801089b4:	85 c0                	test   %eax,%eax
801089b6:	74 29                	je     801089e1 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801089b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089bb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801089c2:	8b 45 08             	mov    0x8(%ebp),%eax
801089c5:	01 d0                	add    %edx,%eax
801089c7:	8b 00                	mov    (%eax),%eax
801089c9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801089ce:	05 00 00 00 80       	add    $0x80000000,%eax
801089d3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801089d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089d9:	89 04 24             	mov    %eax,(%esp)
801089dc:	e8 e0 a1 ff ff       	call   80102bc1 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
801089e1:	ff 45 f4             	incl   -0xc(%ebp)
801089e4:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
801089eb:	76 b3                	jbe    801089a0 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
801089ed:	8b 45 08             	mov    0x8(%ebp),%eax
801089f0:	89 04 24             	mov    %eax,(%esp)
801089f3:	e8 c9 a1 ff ff       	call   80102bc1 <kfree>
}
801089f8:	c9                   	leave  
801089f9:	c3                   	ret    

801089fa <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
801089fa:	55                   	push   %ebp
801089fb:	89 e5                	mov    %esp,%ebp
801089fd:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108a00:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108a07:	00 
80108a08:	8b 45 0c             	mov    0xc(%ebp),%eax
80108a0b:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80108a12:	89 04 24             	mov    %eax,(%esp)
80108a15:	e8 72 f8 ff ff       	call   8010828c <walkpgdir>
80108a1a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108a1d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108a21:	75 0c                	jne    80108a2f <clearpteu+0x35>
    panic("clearpteu");
80108a23:	c7 04 24 1c 95 10 80 	movl   $0x8010951c,(%esp)
80108a2a:	e8 25 7b ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80108a2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a32:	8b 00                	mov    (%eax),%eax
80108a34:	83 e0 fb             	and    $0xfffffffb,%eax
80108a37:	89 c2                	mov    %eax,%edx
80108a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a3c:	89 10                	mov    %edx,(%eax)
}
80108a3e:	c9                   	leave  
80108a3f:	c3                   	ret    

80108a40 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108a40:	55                   	push   %ebp
80108a41:	89 e5                	mov    %esp,%ebp
80108a43:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108a46:	e8 73 f9 ff ff       	call   801083be <setupkvm>
80108a4b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108a4e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108a52:	75 0a                	jne    80108a5e <copyuvm+0x1e>
    return 0;
80108a54:	b8 00 00 00 00       	mov    $0x0,%eax
80108a59:	e9 f8 00 00 00       	jmp    80108b56 <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80108a5e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108a65:	e9 cb 00 00 00       	jmp    80108b35 <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108a6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a6d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108a74:	00 
80108a75:	89 44 24 04          	mov    %eax,0x4(%esp)
80108a79:	8b 45 08             	mov    0x8(%ebp),%eax
80108a7c:	89 04 24             	mov    %eax,(%esp)
80108a7f:	e8 08 f8 ff ff       	call   8010828c <walkpgdir>
80108a84:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108a87:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108a8b:	75 0c                	jne    80108a99 <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108a8d:	c7 04 24 26 95 10 80 	movl   $0x80109526,(%esp)
80108a94:	e8 bb 7a ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
80108a99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a9c:	8b 00                	mov    (%eax),%eax
80108a9e:	83 e0 01             	and    $0x1,%eax
80108aa1:	85 c0                	test   %eax,%eax
80108aa3:	75 0c                	jne    80108ab1 <copyuvm+0x71>
      panic("copyuvm: page not present");
80108aa5:	c7 04 24 40 95 10 80 	movl   $0x80109540,(%esp)
80108aac:	e8 a3 7a ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108ab1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ab4:	8b 00                	mov    (%eax),%eax
80108ab6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108abb:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108abe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ac1:	8b 00                	mov    (%eax),%eax
80108ac3:	25 ff 0f 00 00       	and    $0xfff,%eax
80108ac8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108acb:	e8 87 a1 ff ff       	call   80102c57 <kalloc>
80108ad0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108ad3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108ad7:	75 02                	jne    80108adb <copyuvm+0x9b>
      goto bad;
80108ad9:	eb 6b                	jmp    80108b46 <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108adb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ade:	05 00 00 00 80       	add    $0x80000000,%eax
80108ae3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108aea:	00 
80108aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
80108aef:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108af2:	89 04 24             	mov    %eax,(%esp)
80108af5:	e8 91 cc ff ff       	call   8010578b <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108afa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108afd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b00:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108b06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b09:	89 54 24 10          	mov    %edx,0x10(%esp)
80108b0d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108b11:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108b18:	00 
80108b19:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b20:	89 04 24             	mov    %eax,(%esp)
80108b23:	e8 00 f8 ff ff       	call   80108328 <mappages>
80108b28:	85 c0                	test   %eax,%eax
80108b2a:	79 02                	jns    80108b2e <copyuvm+0xee>
      goto bad;
80108b2c:	eb 18                	jmp    80108b46 <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108b2e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b38:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108b3b:	0f 82 29 ff ff ff    	jb     80108a6a <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
80108b41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b44:	eb 10                	jmp    80108b56 <copyuvm+0x116>

bad:
  freevm(d);
80108b46:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b49:	89 04 24             	mov    %eax,(%esp)
80108b4c:	e8 13 fe ff ff       	call   80108964 <freevm>
  return 0;
80108b51:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108b56:	c9                   	leave  
80108b57:	c3                   	ret    

80108b58 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108b58:	55                   	push   %ebp
80108b59:	89 e5                	mov    %esp,%ebp
80108b5b:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108b5e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108b65:	00 
80108b66:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b69:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b6d:	8b 45 08             	mov    0x8(%ebp),%eax
80108b70:	89 04 24             	mov    %eax,(%esp)
80108b73:	e8 14 f7 ff ff       	call   8010828c <walkpgdir>
80108b78:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108b7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b7e:	8b 00                	mov    (%eax),%eax
80108b80:	83 e0 01             	and    $0x1,%eax
80108b83:	85 c0                	test   %eax,%eax
80108b85:	75 07                	jne    80108b8e <uva2ka+0x36>
    return 0;
80108b87:	b8 00 00 00 00       	mov    $0x0,%eax
80108b8c:	eb 22                	jmp    80108bb0 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108b8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b91:	8b 00                	mov    (%eax),%eax
80108b93:	83 e0 04             	and    $0x4,%eax
80108b96:	85 c0                	test   %eax,%eax
80108b98:	75 07                	jne    80108ba1 <uva2ka+0x49>
    return 0;
80108b9a:	b8 00 00 00 00       	mov    $0x0,%eax
80108b9f:	eb 0f                	jmp    80108bb0 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
80108ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba4:	8b 00                	mov    (%eax),%eax
80108ba6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bab:	05 00 00 00 80       	add    $0x80000000,%eax
}
80108bb0:	c9                   	leave  
80108bb1:	c3                   	ret    

80108bb2 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108bb2:	55                   	push   %ebp
80108bb3:	89 e5                	mov    %esp,%ebp
80108bb5:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108bb8:	8b 45 10             	mov    0x10(%ebp),%eax
80108bbb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108bbe:	e9 87 00 00 00       	jmp    80108c4a <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80108bc3:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bc6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bcb:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108bce:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
80108bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80108bd8:	89 04 24             	mov    %eax,(%esp)
80108bdb:	e8 78 ff ff ff       	call   80108b58 <uva2ka>
80108be0:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108be3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108be7:	75 07                	jne    80108bf0 <copyout+0x3e>
      return -1;
80108be9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108bee:	eb 69                	jmp    80108c59 <copyout+0xa7>
    n = PGSIZE - (va - va0);
80108bf0:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bf3:	8b 55 ec             	mov    -0x14(%ebp),%edx
80108bf6:	29 c2                	sub    %eax,%edx
80108bf8:	89 d0                	mov    %edx,%eax
80108bfa:	05 00 10 00 00       	add    $0x1000,%eax
80108bff:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108c02:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c05:	3b 45 14             	cmp    0x14(%ebp),%eax
80108c08:	76 06                	jbe    80108c10 <copyout+0x5e>
      n = len;
80108c0a:	8b 45 14             	mov    0x14(%ebp),%eax
80108c0d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108c10:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c13:	8b 55 0c             	mov    0xc(%ebp),%edx
80108c16:	29 c2                	sub    %eax,%edx
80108c18:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108c1b:	01 c2                	add    %eax,%edx
80108c1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c20:	89 44 24 08          	mov    %eax,0x8(%esp)
80108c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c27:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c2b:	89 14 24             	mov    %edx,(%esp)
80108c2e:	e8 58 cb ff ff       	call   8010578b <memmove>
    len -= n;
80108c33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c36:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108c39:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108c3c:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108c3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c42:	05 00 10 00 00       	add    $0x1000,%eax
80108c47:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108c4a:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108c4e:	0f 85 6f ff ff ff    	jne    80108bc3 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108c54:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108c59:	c9                   	leave  
80108c5a:	c3                   	ret    
