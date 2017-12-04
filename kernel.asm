
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
8010002d:	b8 32 39 10 80       	mov    $0x80103932,%eax
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
8010003a:	c7 44 24 04 00 91 10 	movl   $0x80109100,0x4(%esp)
80100041:	80 
80100042:	c7 04 24 a0 d7 10 80 	movl   $0x8010d7a0,(%esp)
80100049:	e8 94 58 00 00       	call   801058e2 <initlock>

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
80100087:	c7 44 24 04 07 91 10 	movl   $0x80109107,0x4(%esp)
8010008e:	80 
8010008f:	89 04 24             	mov    %eax,(%esp)
80100092:	e8 0d 57 00 00       	call   801057a4 <initsleeplock>
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
801000c9:	e8 35 58 00 00       	call   80105903 <acquire>

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
80100104:	e8 64 58 00 00       	call   8010596d <release>
      acquiresleep(&b->lock);
80100109:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010010c:	83 c0 0c             	add    $0xc,%eax
8010010f:	89 04 24             	mov    %eax,(%esp)
80100112:	e8 c7 56 00 00       	call   801057de <acquiresleep>
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
8010017d:	e8 eb 57 00 00       	call   8010596d <release>
      acquiresleep(&b->lock);
80100182:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100185:	83 c0 0c             	add    $0xc,%eax
80100188:	89 04 24             	mov    %eax,(%esp)
8010018b:	e8 4e 56 00 00       	call   801057de <acquiresleep>
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
801001a7:	c7 04 24 0e 91 10 80 	movl   $0x8010910e,(%esp)
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
801001e2:	e8 82 28 00 00       	call   80102a69 <iderw>
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
801001fb:	e8 7b 56 00 00       	call   8010587b <holdingsleep>
80100200:	85 c0                	test   %eax,%eax
80100202:	75 0c                	jne    80100210 <bwrite+0x24>
    panic("bwrite");
80100204:	c7 04 24 1f 91 10 80 	movl   $0x8010911f,(%esp)
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
80100225:	e8 3f 28 00 00       	call   80102a69 <iderw>
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
8010023b:	e8 3b 56 00 00       	call   8010587b <holdingsleep>
80100240:	85 c0                	test   %eax,%eax
80100242:	75 0c                	jne    80100250 <brelse+0x24>
    panic("brelse");
80100244:	c7 04 24 26 91 10 80 	movl   $0x80109126,(%esp)
8010024b:	e8 04 03 00 00       	call   80100554 <panic>

  releasesleep(&b->lock);
80100250:	8b 45 08             	mov    0x8(%ebp),%eax
80100253:	83 c0 0c             	add    $0xc,%eax
80100256:	89 04 24             	mov    %eax,(%esp)
80100259:	e8 db 55 00 00       	call   80105839 <releasesleep>

  acquire(&bcache.lock);
8010025e:	c7 04 24 a0 d7 10 80 	movl   $0x8010d7a0,(%esp)
80100265:	e8 99 56 00 00       	call   80105903 <acquire>
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
801002d1:	e8 97 56 00 00       	call   8010596d <release>
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
801003dc:	e8 22 55 00 00       	call   80105903 <acquire>

  if (fmt == 0)
801003e1:	8b 45 08             	mov    0x8(%ebp),%eax
801003e4:	85 c0                	test   %eax,%eax
801003e6:	75 0c                	jne    801003f4 <cprintf+0x33>
    panic("null fmt");
801003e8:	c7 04 24 2d 91 10 80 	movl   $0x8010912d,(%esp)
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
801004cf:	c7 45 ec 36 91 10 80 	movl   $0x80109136,-0x14(%ebp)
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
8010054d:	e8 1b 54 00 00       	call   8010596d <release>
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
80100569:	e8 97 2b 00 00       	call   80103105 <lapicid>
8010056e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100572:	c7 04 24 3d 91 10 80 	movl   $0x8010913d,(%esp)
80100579:	e8 43 fe ff ff       	call   801003c1 <cprintf>
  cprintf(s);
8010057e:	8b 45 08             	mov    0x8(%ebp),%eax
80100581:	89 04 24             	mov    %eax,(%esp)
80100584:	e8 38 fe ff ff       	call   801003c1 <cprintf>
  cprintf("\n");
80100589:	c7 04 24 51 91 10 80 	movl   $0x80109151,(%esp)
80100590:	e8 2c fe ff ff       	call   801003c1 <cprintf>
  getcallerpcs(&s, pcs);
80100595:	8d 45 cc             	lea    -0x34(%ebp),%eax
80100598:	89 44 24 04          	mov    %eax,0x4(%esp)
8010059c:	8d 45 08             	lea    0x8(%ebp),%eax
8010059f:	89 04 24             	mov    %eax,(%esp)
801005a2:	e8 13 54 00 00       	call   801059ba <getcallerpcs>
  for(i=0; i<10; i++)
801005a7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005ae:	eb 1a                	jmp    801005ca <panic+0x76>
    cprintf(" %p", pcs[i]);
801005b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005b3:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801005bb:	c7 04 24 53 91 10 80 	movl   $0x80109153,(%esp)
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
80100695:	c7 04 24 57 91 10 80 	movl   $0x80109157,(%esp)
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
801006c9:	e8 61 55 00 00       	call   80105c2f <memmove>
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
801006f8:	e8 69 54 00 00       	call   80105b66 <memset>
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
8010078e:	e8 ed 70 00 00       	call   80107880 <uartputc>
80100793:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010079a:	e8 e1 70 00 00       	call   80107880 <uartputc>
8010079f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801007a6:	e8 d5 70 00 00       	call   80107880 <uartputc>
801007ab:	eb 0b                	jmp    801007b8 <consputc+0x50>
  } else
    uartputc(c);
801007ad:	8b 45 08             	mov    0x8(%ebp),%eax
801007b0:	89 04 24             	mov    %eax,(%esp)
801007b3:	e8 c8 70 00 00       	call   80107880 <uartputc>
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
80100813:	e8 eb 50 00 00       	call   80105903 <acquire>
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
801009e0:	e8 9e 42 00 00       	call   80104c83 <wakeup>
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
80100a01:	e8 67 4f 00 00       	call   8010596d <release>
  if(doprocdump){
80100a06:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100a0a:	74 05                	je     80100a11 <consoleintr+0x21c>
    contdump();  // now call procdump() wo. cons.lock held
80100a0c:	e8 cf 4b 00 00       	call   801055e0 <contdump>
  }
  if(doconsoleswitch){
80100a11:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100a15:	74 15                	je     80100a2c <consoleintr+0x237>
    cprintf("\nActive console now: %d\n", active);
80100a17:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a20:	c7 04 24 6a 91 10 80 	movl   $0x8010916a,(%esp)
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
80100a52:	e8 ac 4e 00 00       	call   80105903 <acquire>
  while(n > 0){
80100a57:	e9 b7 00 00 00       	jmp    80100b13 <consoleread+0xdf>
    while((input.r == input.w) || (active != ip->minor)){
80100a5c:	eb 41                	jmp    80100a9f <consoleread+0x6b>
      if(myproc()->killed){
80100a5e:	e8 e9 37 00 00       	call   8010424c <myproc>
80100a63:	8b 40 24             	mov    0x24(%eax),%eax
80100a66:	85 c0                	test   %eax,%eax
80100a68:	74 21                	je     80100a8b <consoleread+0x57>
        release(&cons.lock);
80100a6a:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
80100a71:	e8 f7 4e 00 00       	call   8010596d <release>
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
80100a9a:	e8 c9 40 00 00       	call   80104b68 <sleep>

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
80100b24:	e8 44 4e 00 00       	call   8010596d <release>
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
80100b6a:	e8 94 4d 00 00       	call   80105903 <acquire>
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
80100ba2:	e8 c6 4d 00 00       	call   8010596d <release>
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
80100bbd:	c7 44 24 04 83 91 10 	movl   $0x80109183,0x4(%esp)
80100bc4:	80 
80100bc5:	c7 04 24 00 c7 10 80 	movl   $0x8010c700,(%esp)
80100bcc:	e8 11 4d 00 00       	call   801058e2 <initlock>

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
80100bfe:	e8 18 20 00 00       	call   80102c1b <ioapicenable>
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
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100c11:	e8 36 36 00 00       	call   8010424c <myproc>
80100c16:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100c19:	e8 31 2a 00 00       	call   8010364f <begin_op>

  if((ip = namei(path)) == 0){
80100c1e:	8b 45 08             	mov    0x8(%ebp),%eax
80100c21:	89 04 24             	mov    %eax,(%esp)
80100c24:	e8 53 1a 00 00       	call   8010267c <namei>
80100c29:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100c2c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100c30:	75 1b                	jne    80100c4d <exec+0x45>
    end_op();
80100c32:	e8 9a 2a 00 00       	call   801036d1 <end_op>
    cprintf("exec: fail\n");
80100c37:	c7 04 24 8b 91 10 80 	movl   $0x8010918b,(%esp)
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
80100ca0:	e8 bd 7b 00 00       	call   80108862 <setupkvm>
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
80100d5e:	e8 cb 7e 00 00       	call   80108c2e <allocuvm>
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
80100db0:	e8 96 7d 00 00       	call   80108b4b <loaduvm>
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
80100de7:	e8 e5 28 00 00       	call   801036d1 <end_op>
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
80100e1c:	e8 0d 7e 00 00       	call   80108c2e <allocuvm>
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
80100e41:	e8 58 80 00 00       	call   80108e9e <clearpteu>
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
80100e77:	e8 3d 4f 00 00       	call   80105db9 <strlen>
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
80100e9e:	e8 16 4f 00 00       	call   80105db9 <strlen>
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
80100ecc:	e8 85 81 00 00       	call   80109056 <copyout>
80100ed1:	85 c0                	test   %eax,%eax
80100ed3:	79 05                	jns    80100eda <exec+0x2d2>
      goto bad;
80100ed5:	e9 3d 01 00 00       	jmp    80101017 <exec+0x40f>
    ustack[3+argc] = sp;
80100eda:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100edd:	8d 50 03             	lea    0x3(%eax),%edx
80100ee0:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100ee3:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
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
80100f70:	e8 e1 80 00 00       	call   80109056 <copyout>
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
80100fc0:	e8 ad 4d 00 00       	call   80105d72 <safestrcpy>

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
80101000:	e8 37 79 00 00       	call   8010893c <switchuvm>
  freevm(oldpgdir);
80101005:	8b 45 cc             	mov    -0x34(%ebp),%eax
80101008:	89 04 24             	mov    %eax,(%esp)
8010100b:	e8 f8 7d 00 00       	call   80108e08 <freevm>
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
80101023:	e8 e0 7d 00 00       	call   80108e08 <freevm>
  if(ip){
80101028:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
8010102c:	74 10                	je     8010103e <exec+0x436>
    iunlockput(ip);
8010102e:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101031:	89 04 24             	mov    %eax,(%esp)
80101034:	e8 ec 0b 00 00       	call   80101c25 <iunlockput>
    end_op();
80101039:	e8 93 26 00 00       	call   801036d1 <end_op>
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
8010104e:	c7 44 24 04 97 91 10 	movl   $0x80109197,0x4(%esp)
80101055:	80 
80101056:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
8010105d:	e8 80 48 00 00       	call   801058e2 <initlock>
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
80101071:	e8 8d 48 00 00       	call   80105903 <acquire>
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
8010109a:	e8 ce 48 00 00       	call   8010596d <release>
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
801010b8:	e8 b0 48 00 00       	call   8010596d <release>
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
801010d1:	e8 2d 48 00 00       	call   80105903 <acquire>
  if(f->ref < 1)
801010d6:	8b 45 08             	mov    0x8(%ebp),%eax
801010d9:	8b 40 04             	mov    0x4(%eax),%eax
801010dc:	85 c0                	test   %eax,%eax
801010de:	7f 0c                	jg     801010ec <filedup+0x28>
    panic("filedup");
801010e0:	c7 04 24 9e 91 10 80 	movl   $0x8010919e,(%esp)
801010e7:	e8 68 f4 ff ff       	call   80100554 <panic>
  f->ref++;
801010ec:	8b 45 08             	mov    0x8(%ebp),%eax
801010ef:	8b 40 04             	mov    0x4(%eax),%eax
801010f2:	8d 50 01             	lea    0x1(%eax),%edx
801010f5:	8b 45 08             	mov    0x8(%ebp),%eax
801010f8:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
801010fb:	c7 04 24 a0 21 11 80 	movl   $0x801121a0,(%esp)
80101102:	e8 66 48 00 00       	call   8010596d <release>
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
8010111c:	e8 e2 47 00 00       	call   80105903 <acquire>
  if(f->ref < 1)
80101121:	8b 45 08             	mov    0x8(%ebp),%eax
80101124:	8b 40 04             	mov    0x4(%eax),%eax
80101127:	85 c0                	test   %eax,%eax
80101129:	7f 0c                	jg     80101137 <fileclose+0x2b>
    panic("fileclose");
8010112b:	c7 04 24 a6 91 10 80 	movl   $0x801091a6,(%esp)
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
80101157:	e8 11 48 00 00       	call   8010596d <release>
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
8010118d:	e8 db 47 00 00       	call   8010596d <release>

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
801011aa:	e8 30 2e 00 00       	call   80103fdf <pipeclose>
801011af:	eb 1d                	jmp    801011ce <fileclose+0xc2>
  else if(ff.type == FD_INODE){
801011b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801011b4:	83 f8 02             	cmp    $0x2,%eax
801011b7:	75 15                	jne    801011ce <fileclose+0xc2>
    begin_op();
801011b9:	e8 91 24 00 00       	call   8010364f <begin_op>
    iput(ff.ip);
801011be:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011c1:	89 04 24             	mov    %eax,(%esp)
801011c4:	e8 ab 09 00 00       	call   80101b74 <iput>
    end_op();
801011c9:	e8 03 25 00 00       	call   801036d1 <end_op>
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
80101260:	e8 f8 2e 00 00       	call   8010415d <piperead>
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
801012d2:	c7 04 24 b0 91 10 80 	movl   $0x801091b0,(%esp)
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
8010131c:	e8 50 2d 00 00       	call   80104071 <pipewrite>
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
80101362:	e8 e8 22 00 00       	call   8010364f <begin_op>
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
801013c8:	e8 04 23 00 00       	call   801036d1 <end_op>

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
801013dd:	c7 04 24 b9 91 10 80 	movl   $0x801091b9,(%esp)
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
8010140f:	c7 04 24 c9 91 10 80 	movl   $0x801091c9,(%esp)
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
80101458:	e8 d2 47 00 00       	call   80105c2f <memmove>
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
8010149e:	e8 c3 46 00 00       	call   80105b66 <memset>
  log_write(bp);
801014a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801014a6:	89 04 24             	mov    %eax,(%esp)
801014a9:	e8 a5 23 00 00       	call   80103853 <log_write>
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
80101571:	e8 dd 22 00 00       	call   80103853 <log_write>
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
801015e7:	c7 04 24 d4 91 10 80 	movl   $0x801091d4,(%esp)
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
80101677:	c7 04 24 ea 91 10 80 	movl   $0x801091ea,(%esp)
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
801016ad:	e8 a1 21 00 00       	call   80103853 <log_write>
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
801016cf:	c7 44 24 04 fd 91 10 	movl   $0x801091fd,0x4(%esp)
801016d6:	80 
801016d7:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
801016de:	e8 ff 41 00 00       	call   801058e2 <initlock>
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
80101704:	c7 44 24 04 04 92 10 	movl   $0x80109204,0x4(%esp)
8010170b:	80 
8010170c:	89 04 24             	mov    %eax,(%esp)
8010170f:	e8 90 40 00 00       	call   801057a4 <initsleeplock>
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
8010177d:	c7 04 24 0c 92 10 80 	movl   $0x8010920c,(%esp)
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
801017ff:	e8 62 43 00 00       	call   80105b66 <memset>
      dip->type = type;
80101804:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101807:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010180a:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
8010180d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101810:	89 04 24             	mov    %eax,(%esp)
80101813:	e8 3b 20 00 00       	call   80103853 <log_write>
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
80101855:	c7 04 24 5f 92 10 80 	movl   $0x8010925f,(%esp)
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
80101902:	e8 28 43 00 00       	call   80105c2f <memmove>
  log_write(bp);
80101907:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010190a:	89 04 24             	mov    %eax,(%esp)
8010190d:	e8 41 1f 00 00       	call   80103853 <log_write>
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
8010192c:	e8 d2 3f 00 00       	call   80105903 <acquire>

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
80101976:	e8 f2 3f 00 00       	call   8010596d <release>
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
801019ac:	c7 04 24 71 92 10 80 	movl   $0x80109271,(%esp)
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
801019ea:	e8 7e 3f 00 00       	call   8010596d <release>

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
80101a01:	e8 fd 3e 00 00       	call   80105903 <acquire>
  ip->ref++;
80101a06:	8b 45 08             	mov    0x8(%ebp),%eax
80101a09:	8b 40 08             	mov    0x8(%eax),%eax
80101a0c:	8d 50 01             	lea    0x1(%eax),%edx
80101a0f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a12:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101a15:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101a1c:	e8 4c 3f 00 00       	call   8010596d <release>
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
80101a3c:	c7 04 24 81 92 10 80 	movl   $0x80109281,(%esp)
80101a43:	e8 0c eb ff ff       	call   80100554 <panic>

  acquiresleep(&ip->lock);
80101a48:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4b:	83 c0 0c             	add    $0xc,%eax
80101a4e:	89 04 24             	mov    %eax,(%esp)
80101a51:	e8 88 3d 00 00       	call   801057de <acquiresleep>

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
80101afd:	e8 2d 41 00 00       	call   80105c2f <memmove>
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
80101b22:	c7 04 24 87 92 10 80 	movl   $0x80109287,(%esp)
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
80101b45:	e8 31 3d 00 00       	call   8010587b <holdingsleep>
80101b4a:	85 c0                	test   %eax,%eax
80101b4c:	74 0a                	je     80101b58 <iunlock+0x28>
80101b4e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b51:	8b 40 08             	mov    0x8(%eax),%eax
80101b54:	85 c0                	test   %eax,%eax
80101b56:	7f 0c                	jg     80101b64 <iunlock+0x34>
    panic("iunlock");
80101b58:	c7 04 24 96 92 10 80 	movl   $0x80109296,(%esp)
80101b5f:	e8 f0 e9 ff ff       	call   80100554 <panic>

  releasesleep(&ip->lock);
80101b64:	8b 45 08             	mov    0x8(%ebp),%eax
80101b67:	83 c0 0c             	add    $0xc,%eax
80101b6a:	89 04 24             	mov    %eax,(%esp)
80101b6d:	e8 c7 3c 00 00       	call   80105839 <releasesleep>
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
80101b83:	e8 56 3c 00 00       	call   801057de <acquiresleep>
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
80101ba5:	e8 59 3d 00 00       	call   80105903 <acquire>
    int r = ip->ref;
80101baa:	8b 45 08             	mov    0x8(%ebp),%eax
80101bad:	8b 40 08             	mov    0x8(%eax),%eax
80101bb0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101bb3:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101bba:	e8 ae 3d 00 00       	call   8010596d <release>
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
80101bf7:	e8 3d 3c 00 00       	call   80105839 <releasesleep>

  acquire(&icache.lock);
80101bfc:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101c03:	e8 fb 3c 00 00       	call   80105903 <acquire>
  ip->ref--;
80101c08:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0b:	8b 40 08             	mov    0x8(%eax),%eax
80101c0e:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c11:	8b 45 08             	mov    0x8(%ebp),%eax
80101c14:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c17:	c7 04 24 c0 2b 11 80 	movl   $0x80112bc0,(%esp)
80101c1e:	e8 4a 3d 00 00       	call   8010596d <release>
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
80101d2f:	e8 1f 1b 00 00       	call   80103853 <log_write>
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
80101d44:	c7 04 24 9e 92 10 80 	movl   $0x8010929e,(%esp)
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
80101fee:	e8 3c 3c 00 00       	call   80105c2f <memmove>
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
8010214d:	e8 dd 3a 00 00       	call   80105c2f <memmove>
    log_write(bp);
80102152:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102155:	89 04 24             	mov    %eax,(%esp)
80102158:	e8 f6 16 00 00       	call   80103853 <log_write>
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
801021cb:	e8 fe 3a 00 00       	call   80105cce <strncmp>
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
801021e4:	c7 04 24 b1 92 10 80 	movl   $0x801092b1,(%esp)
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
80102222:	c7 04 24 c3 92 10 80 	movl   $0x801092c3,(%esp)
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
80102305:	c7 04 24 d2 92 10 80 	movl   $0x801092d2,(%esp)
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
80102349:	e8 ce 39 00 00       	call   80105d1c <strncpy>
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
8010237b:	c7 04 24 df 92 10 80 	movl   $0x801092df,(%esp)
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
801023fa:	e8 30 38 00 00       	call   80105c2f <memmove>
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
80102415:	e8 15 38 00 00       	call   80105c2f <memmove>
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
8010243b:	53                   	push   %ebx
8010243c:	83 ec 24             	sub    $0x24,%esp
  struct inode *ip, *next, *iroot;

  iroot = iget(ROOTDEV, ROOTINO);
8010243f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102446:	00 
80102447:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010244e:	e8 cc f4 ff ff       	call   8010191f <iget>
80102453:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  cprintf("namex begin %s with proc %s \n", path, ((myproc() == 0) ? "null" : myproc()->name));
80102456:	e8 f1 1d 00 00       	call   8010424c <myproc>
8010245b:	85 c0                	test   %eax,%eax
8010245d:	74 0a                	je     80102469 <namex+0x31>
8010245f:	e8 e8 1d 00 00       	call   8010424c <myproc>
80102464:	83 c0 6c             	add    $0x6c,%eax
80102467:	eb 05                	jmp    8010246e <namex+0x36>
80102469:	b8 e7 92 10 80       	mov    $0x801092e7,%eax
8010246e:	89 44 24 08          	mov    %eax,0x8(%esp)
80102472:	8b 45 08             	mov    0x8(%ebp),%eax
80102475:	89 44 24 04          	mov    %eax,0x4(%esp)
80102479:	c7 04 24 ec 92 10 80 	movl   $0x801092ec,(%esp)
80102480:	e8 3c df ff ff       	call   801003c1 <cprintf>
  cprintf("\tiroot is type folder %d\n", (iroot->type == T_DIR));    
80102485:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102488:	8b 40 50             	mov    0x50(%eax),%eax
8010248b:	66 83 f8 01          	cmp    $0x1,%ax
8010248f:	0f 94 c0             	sete   %al
80102492:	0f b6 c0             	movzbl %al,%eax
80102495:	89 44 24 04          	mov    %eax,0x4(%esp)
80102499:	c7 04 24 0a 93 10 80 	movl   $0x8010930a,(%esp)
801024a0:	e8 1c df ff ff       	call   801003c1 <cprintf>

  // Absolute or relative
  if (myproc() == 0)
801024a5:	e8 a2 1d 00 00       	call   8010424c <myproc>
801024aa:	85 c0                	test   %eax,%eax
801024ac:	75 0b                	jne    801024b9 <namex+0x81>
    ip = iroot;
801024ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024b1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024b4:	e9 be 00 00 00       	jmp    80102577 <namex+0x13f>
  else if(*path == '/') 
801024b9:	8b 45 08             	mov    0x8(%ebp),%eax
801024bc:	8a 00                	mov    (%eax),%al
801024be:	3c 2f                	cmp    $0x2f,%al
801024c0:	75 1e                	jne    801024e0 <namex+0xa8>
    ip = idup(myproc()->cont->rootdir);
801024c2:	e8 85 1d 00 00       	call   8010424c <myproc>
801024c7:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801024cd:	8b 40 10             	mov    0x10(%eax),%eax
801024d0:	89 04 24             	mov    %eax,(%esp)
801024d3:	e8 1c f5 ff ff       	call   801019f4 <idup>
801024d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801024db:	e9 97 00 00 00       	jmp    80102577 <namex+0x13f>
  else {    
    ip = idup(myproc()->cwd);
801024e0:	e8 67 1d 00 00       	call   8010424c <myproc>
801024e5:	8b 40 68             	mov    0x68(%eax),%eax
801024e8:	89 04 24             	mov    %eax,(%esp)
801024eb:	e8 04 f5 ff ff       	call   801019f4 <idup>
801024f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("\tip = myproc's cwd (which is also it's container)%d\n", (myproc()->cwd->inum == myproc()->cont->rootdir->inum));
801024f3:	e8 54 1d 00 00       	call   8010424c <myproc>
801024f8:	8b 40 68             	mov    0x68(%eax),%eax
801024fb:	8b 58 04             	mov    0x4(%eax),%ebx
801024fe:	e8 49 1d 00 00       	call   8010424c <myproc>
80102503:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102509:	8b 40 10             	mov    0x10(%eax),%eax
8010250c:	8b 40 04             	mov    0x4(%eax),%eax
8010250f:	39 c3                	cmp    %eax,%ebx
80102511:	0f 94 c0             	sete   %al
80102514:	0f b6 c0             	movzbl %al,%eax
80102517:	89 44 24 04          	mov    %eax,0x4(%esp)
8010251b:	c7 04 24 24 93 10 80 	movl   $0x80109324,(%esp)
80102522:	e8 9a de ff ff       	call   801003c1 <cprintf>
    cprintf("\tip is type folder %d\n", (ip->type == T_DIR));    
80102527:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010252a:	8b 40 50             	mov    0x50(%eax),%eax
8010252d:	66 83 f8 01          	cmp    $0x1,%ax
80102531:	0f 94 c0             	sete   %al
80102534:	0f b6 c0             	movzbl %al,%eax
80102537:	89 44 24 04          	mov    %eax,0x4(%esp)
8010253b:	c7 04 24 59 93 10 80 	movl   $0x80109359,(%esp)
80102542:	e8 7a de ff ff       	call   801003c1 <cprintf>
    cprintf("\trootdir is type folder %d\n", (myproc()->cont->rootdir->type == T_DIR));    
80102547:	e8 00 1d 00 00       	call   8010424c <myproc>
8010254c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80102552:	8b 40 10             	mov    0x10(%eax),%eax
80102555:	8b 40 50             	mov    0x50(%eax),%eax
80102558:	66 83 f8 01          	cmp    $0x1,%ax
8010255c:	0f 94 c0             	sete   %al
8010255f:	0f b6 c0             	movzbl %al,%eax
80102562:	89 44 24 04          	mov    %eax,0x4(%esp)
80102566:	c7 04 24 70 93 10 80 	movl   $0x80109370,(%esp)
8010256d:	e8 4f de ff ff       	call   801003c1 <cprintf>
  // if (strncmp("/ctest1/init", path, strlen("/ctest1/init")) == 0) {
  //   cprintf("ip = root now\n");
  //   ip = iroot;    
  // }    

  while((path = skipelem(path, name)) != 0){
80102572:	e9 99 00 00 00       	jmp    80102610 <namex+0x1d8>
80102577:	e9 94 00 00 00       	jmp    80102610 <namex+0x1d8>
    ilock(ip);
8010257c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010257f:	89 04 24             	mov    %eax,(%esp)
80102582:	e8 9f f4 ff ff       	call   80101a26 <ilock>
    if(ip->type != T_DIR){
80102587:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010258a:	8b 40 50             	mov    0x50(%eax),%eax
8010258d:	66 83 f8 01          	cmp    $0x1,%ax
80102591:	74 15                	je     801025a8 <namex+0x170>
      iunlockput(ip);
80102593:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102596:	89 04 24             	mov    %eax,(%esp)
80102599:	e8 87 f6 ff ff       	call   80101c25 <iunlockput>
      return 0;
8010259e:	b8 00 00 00 00       	mov    $0x0,%eax
801025a3:	e9 ce 00 00 00       	jmp    80102676 <namex+0x23e>
    }
    if(nameiparent && *path == '\0'){
801025a8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801025ac:	74 1c                	je     801025ca <namex+0x192>
801025ae:	8b 45 08             	mov    0x8(%ebp),%eax
801025b1:	8a 00                	mov    (%eax),%al
801025b3:	84 c0                	test   %al,%al
801025b5:	75 13                	jne    801025ca <namex+0x192>
      // Stop one level early.
      iunlock(ip);
801025b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ba:	89 04 24             	mov    %eax,(%esp)
801025bd:	e8 6e f5 ff ff       	call   80101b30 <iunlock>
      return ip;
801025c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025c5:	e9 ac 00 00 00       	jmp    80102676 <namex+0x23e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801025ca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801025d1:	00 
801025d2:	8b 45 10             	mov    0x10(%ebp),%eax
801025d5:	89 44 24 04          	mov    %eax,0x4(%esp)
801025d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025dc:	89 04 24             	mov    %eax,(%esp)
801025df:	e8 ee fb ff ff       	call   801021d2 <dirlookup>
801025e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801025e7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801025eb:	75 12                	jne    801025ff <namex+0x1c7>
      iunlockput(ip);
801025ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025f0:	89 04 24             	mov    %eax,(%esp)
801025f3:	e8 2d f6 ff ff       	call   80101c25 <iunlockput>
      return 0;
801025f8:	b8 00 00 00 00       	mov    $0x0,%eax
801025fd:	eb 77                	jmp    80102676 <namex+0x23e>
    }    
    iunlockput(ip);
801025ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102602:	89 04 24             	mov    %eax,(%esp)
80102605:	e8 1b f6 ff ff       	call   80101c25 <iunlockput>
    // If myproc is running in root container, 
    // or the above (next) folder is not the root folder,
    // then set ip = next
    // TODO: validate that this works
    //if (myproc()->cont->rootdir->inum == iroot->inum || next->inum != iroot->inum)
    ip = next;
8010260a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010260d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  // if (strncmp("/ctest1/init", path, strlen("/ctest1/init")) == 0) {
  //   cprintf("ip = root now\n");
  //   ip = iroot;    
  // }    

  while((path = skipelem(path, name)) != 0){
80102610:	8b 45 10             	mov    0x10(%ebp),%eax
80102613:	89 44 24 04          	mov    %eax,0x4(%esp)
80102617:	8b 45 08             	mov    0x8(%ebp),%eax
8010261a:	89 04 24             	mov    %eax,(%esp)
8010261d:	e8 6c fd ff ff       	call   8010238e <skipelem>
80102622:	89 45 08             	mov    %eax,0x8(%ebp)
80102625:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102629:	0f 85 4d ff ff ff    	jne    8010257c <namex+0x144>
    // then set ip = next
    // TODO: validate that this works
    //if (myproc()->cont->rootdir->inum == iroot->inum || next->inum != iroot->inum)
    ip = next;
  }
  if(nameiparent){
8010262f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102633:	74 12                	je     80102647 <namex+0x20f>
    iput(ip);
80102635:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102638:	89 04 24             	mov    %eax,(%esp)
8010263b:	e8 34 f5 ff ff       	call   80101b74 <iput>
    return 0;
80102640:	b8 00 00 00 00       	mov    $0x0,%eax
80102645:	eb 2f                	jmp    80102676 <namex+0x23e>
  }
  cprintf("\treturning ip\n");
80102647:	c7 04 24 8c 93 10 80 	movl   $0x8010938c,(%esp)
8010264e:	e8 6e dd ff ff       	call   801003c1 <cprintf>
  cprintf("\tip is a folder? %d\n", (ip->type == T_DIR));
80102653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102656:	8b 40 50             	mov    0x50(%eax),%eax
80102659:	66 83 f8 01          	cmp    $0x1,%ax
8010265d:	0f 94 c0             	sete   %al
80102660:	0f b6 c0             	movzbl %al,%eax
80102663:	89 44 24 04          	mov    %eax,0x4(%esp)
80102667:	c7 04 24 9b 93 10 80 	movl   $0x8010939b,(%esp)
8010266e:	e8 4e dd ff ff       	call   801003c1 <cprintf>
  return ip;
80102673:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102676:	83 c4 24             	add    $0x24,%esp
80102679:	5b                   	pop    %ebx
8010267a:	5d                   	pop    %ebp
8010267b:	c3                   	ret    

8010267c <namei>:

struct inode*
namei(char *path)
{
8010267c:	55                   	push   %ebp
8010267d:	89 e5                	mov    %esp,%ebp
8010267f:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102682:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102685:	89 44 24 08          	mov    %eax,0x8(%esp)
80102689:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102690:	00 
80102691:	8b 45 08             	mov    0x8(%ebp),%eax
80102694:	89 04 24             	mov    %eax,(%esp)
80102697:	e8 9c fd ff ff       	call   80102438 <namex>
}
8010269c:	c9                   	leave  
8010269d:	c3                   	ret    

8010269e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
8010269e:	55                   	push   %ebp
8010269f:	89 e5                	mov    %esp,%ebp
801026a1:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 1, name);
801026a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801026a7:	89 44 24 08          	mov    %eax,0x8(%esp)
801026ab:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801026b2:	00 
801026b3:	8b 45 08             	mov    0x8(%ebp),%eax
801026b6:	89 04 24             	mov    %eax,(%esp)
801026b9:	e8 7a fd ff ff       	call   80102438 <namex>
}
801026be:	c9                   	leave  
801026bf:	c3                   	ret    

801026c0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801026c0:	55                   	push   %ebp
801026c1:	89 e5                	mov    %esp,%ebp
801026c3:	83 ec 14             	sub    $0x14,%esp
801026c6:	8b 45 08             	mov    0x8(%ebp),%eax
801026c9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801026cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801026d0:	89 c2                	mov    %eax,%edx
801026d2:	ec                   	in     (%dx),%al
801026d3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801026d6:	8a 45 ff             	mov    -0x1(%ebp),%al
}
801026d9:	c9                   	leave  
801026da:	c3                   	ret    

801026db <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
801026db:	55                   	push   %ebp
801026dc:	89 e5                	mov    %esp,%ebp
801026de:	57                   	push   %edi
801026df:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
801026e0:	8b 55 08             	mov    0x8(%ebp),%edx
801026e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801026e6:	8b 45 10             	mov    0x10(%ebp),%eax
801026e9:	89 cb                	mov    %ecx,%ebx
801026eb:	89 df                	mov    %ebx,%edi
801026ed:	89 c1                	mov    %eax,%ecx
801026ef:	fc                   	cld    
801026f0:	f3 6d                	rep insl (%dx),%es:(%edi)
801026f2:	89 c8                	mov    %ecx,%eax
801026f4:	89 fb                	mov    %edi,%ebx
801026f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801026f9:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
801026fc:	5b                   	pop    %ebx
801026fd:	5f                   	pop    %edi
801026fe:	5d                   	pop    %ebp
801026ff:	c3                   	ret    

80102700 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102700:	55                   	push   %ebp
80102701:	89 e5                	mov    %esp,%ebp
80102703:	83 ec 08             	sub    $0x8,%esp
80102706:	8b 45 08             	mov    0x8(%ebp),%eax
80102709:	8b 55 0c             	mov    0xc(%ebp),%edx
8010270c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102710:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102713:	8a 45 f8             	mov    -0x8(%ebp),%al
80102716:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102719:	ee                   	out    %al,(%dx)
}
8010271a:	c9                   	leave  
8010271b:	c3                   	ret    

8010271c <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
8010271c:	55                   	push   %ebp
8010271d:	89 e5                	mov    %esp,%ebp
8010271f:	56                   	push   %esi
80102720:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102721:	8b 55 08             	mov    0x8(%ebp),%edx
80102724:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102727:	8b 45 10             	mov    0x10(%ebp),%eax
8010272a:	89 cb                	mov    %ecx,%ebx
8010272c:	89 de                	mov    %ebx,%esi
8010272e:	89 c1                	mov    %eax,%ecx
80102730:	fc                   	cld    
80102731:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102733:	89 c8                	mov    %ecx,%eax
80102735:	89 f3                	mov    %esi,%ebx
80102737:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010273a:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010273d:	5b                   	pop    %ebx
8010273e:	5e                   	pop    %esi
8010273f:	5d                   	pop    %ebp
80102740:	c3                   	ret    

80102741 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102741:	55                   	push   %ebp
80102742:	89 e5                	mov    %esp,%ebp
80102744:	83 ec 14             	sub    $0x14,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102747:	90                   	nop
80102748:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010274f:	e8 6c ff ff ff       	call   801026c0 <inb>
80102754:	0f b6 c0             	movzbl %al,%eax
80102757:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010275a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010275d:	25 c0 00 00 00       	and    $0xc0,%eax
80102762:	83 f8 40             	cmp    $0x40,%eax
80102765:	75 e1                	jne    80102748 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80102767:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010276b:	74 11                	je     8010277e <idewait+0x3d>
8010276d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102770:	83 e0 21             	and    $0x21,%eax
80102773:	85 c0                	test   %eax,%eax
80102775:	74 07                	je     8010277e <idewait+0x3d>
    return -1;
80102777:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010277c:	eb 05                	jmp    80102783 <idewait+0x42>
  return 0;
8010277e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102783:	c9                   	leave  
80102784:	c3                   	ret    

80102785 <ideinit>:

void
ideinit(void)
{
80102785:	55                   	push   %ebp
80102786:	89 e5                	mov    %esp,%ebp
80102788:	83 ec 28             	sub    $0x28,%esp
  int i;

  initlock(&idelock, "ide");
8010278b:	c7 44 24 04 b0 93 10 	movl   $0x801093b0,0x4(%esp)
80102792:	80 
80102793:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
8010279a:	e8 43 31 00 00       	call   801058e2 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
8010279f:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
801027a4:	48                   	dec    %eax
801027a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801027a9:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
801027b0:	e8 66 04 00 00       	call   80102c1b <ioapicenable>
  idewait(0);
801027b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801027bc:	e8 80 ff ff ff       	call   80102741 <idewait>

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
801027c1:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
801027c8:	00 
801027c9:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
801027d0:	e8 2b ff ff ff       	call   80102700 <outb>
  for(i=0; i<1000; i++){
801027d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801027dc:	eb 1f                	jmp    801027fd <ideinit+0x78>
    if(inb(0x1f7) != 0){
801027de:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
801027e5:	e8 d6 fe ff ff       	call   801026c0 <inb>
801027ea:	84 c0                	test   %al,%al
801027ec:	74 0c                	je     801027fa <ideinit+0x75>
      havedisk1 = 1;
801027ee:	c7 05 78 c7 10 80 01 	movl   $0x1,0x8010c778
801027f5:	00 00 00 
      break;
801027f8:	eb 0c                	jmp    80102806 <ideinit+0x81>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
801027fa:	ff 45 f4             	incl   -0xc(%ebp)
801027fd:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
80102804:	7e d8                	jle    801027de <ideinit+0x59>
      break;
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
80102806:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
8010280d:	00 
8010280e:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102815:	e8 e6 fe ff ff       	call   80102700 <outb>
}
8010281a:	c9                   	leave  
8010281b:	c3                   	ret    

8010281c <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
8010281c:	55                   	push   %ebp
8010281d:	89 e5                	mov    %esp,%ebp
8010281f:	83 ec 28             	sub    $0x28,%esp
  if(b == 0)
80102822:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80102826:	75 0c                	jne    80102834 <idestart+0x18>
    panic("idestart");
80102828:	c7 04 24 b4 93 10 80 	movl   $0x801093b4,(%esp)
8010282f:	e8 20 dd ff ff       	call   80100554 <panic>
  if(b->blockno >= FSSIZE)
80102834:	8b 45 08             	mov    0x8(%ebp),%eax
80102837:	8b 40 08             	mov    0x8(%eax),%eax
8010283a:	3d e7 03 00 00       	cmp    $0x3e7,%eax
8010283f:	76 0c                	jbe    8010284d <idestart+0x31>
    panic("incorrect blockno");
80102841:	c7 04 24 bd 93 10 80 	movl   $0x801093bd,(%esp)
80102848:	e8 07 dd ff ff       	call   80100554 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
8010284d:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
80102854:	8b 45 08             	mov    0x8(%ebp),%eax
80102857:	8b 50 08             	mov    0x8(%eax),%edx
8010285a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010285d:	0f af c2             	imul   %edx,%eax
80102860:	89 45 f0             	mov    %eax,-0x10(%ebp)
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
80102863:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80102867:	75 07                	jne    80102870 <idestart+0x54>
80102869:	b8 20 00 00 00       	mov    $0x20,%eax
8010286e:	eb 05                	jmp    80102875 <idestart+0x59>
80102870:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102875:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
80102878:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
8010287c:	75 07                	jne    80102885 <idestart+0x69>
8010287e:	b8 30 00 00 00       	mov    $0x30,%eax
80102883:	eb 05                	jmp    8010288a <idestart+0x6e>
80102885:	b8 c5 00 00 00       	mov    $0xc5,%eax
8010288a:	89 45 e8             	mov    %eax,-0x18(%ebp)

  if (sector_per_block > 7) panic("idestart");
8010288d:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80102891:	7e 0c                	jle    8010289f <idestart+0x83>
80102893:	c7 04 24 b4 93 10 80 	movl   $0x801093b4,(%esp)
8010289a:	e8 b5 dc ff ff       	call   80100554 <panic>

  idewait(0);
8010289f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801028a6:	e8 96 fe ff ff       	call   80102741 <idewait>
  outb(0x3f6, 0);  // generate interrupt
801028ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801028b2:	00 
801028b3:	c7 04 24 f6 03 00 00 	movl   $0x3f6,(%esp)
801028ba:	e8 41 fe ff ff       	call   80102700 <outb>
  outb(0x1f2, sector_per_block);  // number of sectors
801028bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028c2:	0f b6 c0             	movzbl %al,%eax
801028c5:	89 44 24 04          	mov    %eax,0x4(%esp)
801028c9:	c7 04 24 f2 01 00 00 	movl   $0x1f2,(%esp)
801028d0:	e8 2b fe ff ff       	call   80102700 <outb>
  outb(0x1f3, sector & 0xff);
801028d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028d8:	0f b6 c0             	movzbl %al,%eax
801028db:	89 44 24 04          	mov    %eax,0x4(%esp)
801028df:	c7 04 24 f3 01 00 00 	movl   $0x1f3,(%esp)
801028e6:	e8 15 fe ff ff       	call   80102700 <outb>
  outb(0x1f4, (sector >> 8) & 0xff);
801028eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801028ee:	c1 f8 08             	sar    $0x8,%eax
801028f1:	0f b6 c0             	movzbl %al,%eax
801028f4:	89 44 24 04          	mov    %eax,0x4(%esp)
801028f8:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
801028ff:	e8 fc fd ff ff       	call   80102700 <outb>
  outb(0x1f5, (sector >> 16) & 0xff);
80102904:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102907:	c1 f8 10             	sar    $0x10,%eax
8010290a:	0f b6 c0             	movzbl %al,%eax
8010290d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102911:	c7 04 24 f5 01 00 00 	movl   $0x1f5,(%esp)
80102918:	e8 e3 fd ff ff       	call   80102700 <outb>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010291d:	8b 45 08             	mov    0x8(%ebp),%eax
80102920:	8b 40 04             	mov    0x4(%eax),%eax
80102923:	83 e0 01             	and    $0x1,%eax
80102926:	c1 e0 04             	shl    $0x4,%eax
80102929:	88 c2                	mov    %al,%dl
8010292b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010292e:	c1 f8 18             	sar    $0x18,%eax
80102931:	83 e0 0f             	and    $0xf,%eax
80102934:	09 d0                	or     %edx,%eax
80102936:	83 c8 e0             	or     $0xffffffe0,%eax
80102939:	0f b6 c0             	movzbl %al,%eax
8010293c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102940:	c7 04 24 f6 01 00 00 	movl   $0x1f6,(%esp)
80102947:	e8 b4 fd ff ff       	call   80102700 <outb>
  if(b->flags & B_DIRTY){
8010294c:	8b 45 08             	mov    0x8(%ebp),%eax
8010294f:	8b 00                	mov    (%eax),%eax
80102951:	83 e0 04             	and    $0x4,%eax
80102954:	85 c0                	test   %eax,%eax
80102956:	74 36                	je     8010298e <idestart+0x172>
    outb(0x1f7, write_cmd);
80102958:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010295b:	0f b6 c0             	movzbl %al,%eax
8010295e:	89 44 24 04          	mov    %eax,0x4(%esp)
80102962:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
80102969:	e8 92 fd ff ff       	call   80102700 <outb>
    outsl(0x1f0, b->data, BSIZE/4);
8010296e:	8b 45 08             	mov    0x8(%ebp),%eax
80102971:	83 c0 5c             	add    $0x5c,%eax
80102974:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
8010297b:	00 
8010297c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102980:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102987:	e8 90 fd ff ff       	call   8010271c <outsl>
8010298c:	eb 16                	jmp    801029a4 <idestart+0x188>
  } else {
    outb(0x1f7, read_cmd);
8010298e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102991:	0f b6 c0             	movzbl %al,%eax
80102994:	89 44 24 04          	mov    %eax,0x4(%esp)
80102998:	c7 04 24 f7 01 00 00 	movl   $0x1f7,(%esp)
8010299f:	e8 5c fd ff ff       	call   80102700 <outb>
  }
}
801029a4:	c9                   	leave  
801029a5:	c3                   	ret    

801029a6 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801029a6:	55                   	push   %ebp
801029a7:	89 e5                	mov    %esp,%ebp
801029a9:	83 ec 28             	sub    $0x28,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801029ac:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
801029b3:	e8 4b 2f 00 00       	call   80105903 <acquire>

  if((b = idequeue) == 0){
801029b8:	a1 74 c7 10 80       	mov    0x8010c774,%eax
801029bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801029c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801029c4:	75 11                	jne    801029d7 <ideintr+0x31>
    release(&idelock);
801029c6:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
801029cd:	e8 9b 2f 00 00       	call   8010596d <release>
    return;
801029d2:	e9 90 00 00 00       	jmp    80102a67 <ideintr+0xc1>
  }
  idequeue = b->qnext;
801029d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029da:	8b 40 58             	mov    0x58(%eax),%eax
801029dd:	a3 74 c7 10 80       	mov    %eax,0x8010c774

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801029e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029e5:	8b 00                	mov    (%eax),%eax
801029e7:	83 e0 04             	and    $0x4,%eax
801029ea:	85 c0                	test   %eax,%eax
801029ec:	75 2e                	jne    80102a1c <ideintr+0x76>
801029ee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801029f5:	e8 47 fd ff ff       	call   80102741 <idewait>
801029fa:	85 c0                	test   %eax,%eax
801029fc:	78 1e                	js     80102a1c <ideintr+0x76>
    insl(0x1f0, b->data, BSIZE/4);
801029fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a01:	83 c0 5c             	add    $0x5c,%eax
80102a04:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80102a0b:	00 
80102a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a10:	c7 04 24 f0 01 00 00 	movl   $0x1f0,(%esp)
80102a17:	e8 bf fc ff ff       	call   801026db <insl>

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a1f:	8b 00                	mov    (%eax),%eax
80102a21:	83 c8 02             	or     $0x2,%eax
80102a24:	89 c2                	mov    %eax,%edx
80102a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a29:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102a2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a2e:	8b 00                	mov    (%eax),%eax
80102a30:	83 e0 fb             	and    $0xfffffffb,%eax
80102a33:	89 c2                	mov    %eax,%edx
80102a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a38:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a3d:	89 04 24             	mov    %eax,(%esp)
80102a40:	e8 3e 22 00 00       	call   80104c83 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102a45:	a1 74 c7 10 80       	mov    0x8010c774,%eax
80102a4a:	85 c0                	test   %eax,%eax
80102a4c:	74 0d                	je     80102a5b <ideintr+0xb5>
    idestart(idequeue);
80102a4e:	a1 74 c7 10 80       	mov    0x8010c774,%eax
80102a53:	89 04 24             	mov    %eax,(%esp)
80102a56:	e8 c1 fd ff ff       	call   8010281c <idestart>

  release(&idelock);
80102a5b:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
80102a62:	e8 06 2f 00 00       	call   8010596d <release>
}
80102a67:	c9                   	leave  
80102a68:	c3                   	ret    

80102a69 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102a69:	55                   	push   %ebp
80102a6a:	89 e5                	mov    %esp,%ebp
80102a6c:	83 ec 28             	sub    $0x28,%esp
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80102a6f:	8b 45 08             	mov    0x8(%ebp),%eax
80102a72:	83 c0 0c             	add    $0xc,%eax
80102a75:	89 04 24             	mov    %eax,(%esp)
80102a78:	e8 fe 2d 00 00       	call   8010587b <holdingsleep>
80102a7d:	85 c0                	test   %eax,%eax
80102a7f:	75 0c                	jne    80102a8d <iderw+0x24>
    panic("iderw: buf not locked");
80102a81:	c7 04 24 cf 93 10 80 	movl   $0x801093cf,(%esp)
80102a88:	e8 c7 da ff ff       	call   80100554 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102a8d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a90:	8b 00                	mov    (%eax),%eax
80102a92:	83 e0 06             	and    $0x6,%eax
80102a95:	83 f8 02             	cmp    $0x2,%eax
80102a98:	75 0c                	jne    80102aa6 <iderw+0x3d>
    panic("iderw: nothing to do");
80102a9a:	c7 04 24 e5 93 10 80 	movl   $0x801093e5,(%esp)
80102aa1:	e8 ae da ff ff       	call   80100554 <panic>
  if(b->dev != 0 && !havedisk1)
80102aa6:	8b 45 08             	mov    0x8(%ebp),%eax
80102aa9:	8b 40 04             	mov    0x4(%eax),%eax
80102aac:	85 c0                	test   %eax,%eax
80102aae:	74 15                	je     80102ac5 <iderw+0x5c>
80102ab0:	a1 78 c7 10 80       	mov    0x8010c778,%eax
80102ab5:	85 c0                	test   %eax,%eax
80102ab7:	75 0c                	jne    80102ac5 <iderw+0x5c>
    panic("iderw: ide disk 1 not present");
80102ab9:	c7 04 24 fa 93 10 80 	movl   $0x801093fa,(%esp)
80102ac0:	e8 8f da ff ff       	call   80100554 <panic>

  acquire(&idelock);  //DOC:acquire-lock
80102ac5:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
80102acc:	e8 32 2e 00 00       	call   80105903 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80102ad1:	8b 45 08             	mov    0x8(%ebp),%eax
80102ad4:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102adb:	c7 45 f4 74 c7 10 80 	movl   $0x8010c774,-0xc(%ebp)
80102ae2:	eb 0b                	jmp    80102aef <iderw+0x86>
80102ae4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ae7:	8b 00                	mov    (%eax),%eax
80102ae9:	83 c0 58             	add    $0x58,%eax
80102aec:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102aef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102af2:	8b 00                	mov    (%eax),%eax
80102af4:	85 c0                	test   %eax,%eax
80102af6:	75 ec                	jne    80102ae4 <iderw+0x7b>
    ;
  *pp = b;
80102af8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102afb:	8b 55 08             	mov    0x8(%ebp),%edx
80102afe:	89 10                	mov    %edx,(%eax)

  // Start disk if necessary.
  if(idequeue == b)
80102b00:	a1 74 c7 10 80       	mov    0x8010c774,%eax
80102b05:	3b 45 08             	cmp    0x8(%ebp),%eax
80102b08:	75 0d                	jne    80102b17 <iderw+0xae>
    idestart(b);
80102b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b0d:	89 04 24             	mov    %eax,(%esp)
80102b10:	e8 07 fd ff ff       	call   8010281c <idestart>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b15:	eb 15                	jmp    80102b2c <iderw+0xc3>
80102b17:	eb 13                	jmp    80102b2c <iderw+0xc3>
    sleep(b, &idelock);
80102b19:	c7 44 24 04 40 c7 10 	movl   $0x8010c740,0x4(%esp)
80102b20:	80 
80102b21:	8b 45 08             	mov    0x8(%ebp),%eax
80102b24:	89 04 24             	mov    %eax,(%esp)
80102b27:	e8 3c 20 00 00       	call   80104b68 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102b2c:	8b 45 08             	mov    0x8(%ebp),%eax
80102b2f:	8b 00                	mov    (%eax),%eax
80102b31:	83 e0 06             	and    $0x6,%eax
80102b34:	83 f8 02             	cmp    $0x2,%eax
80102b37:	75 e0                	jne    80102b19 <iderw+0xb0>
    sleep(b, &idelock);
  }


  release(&idelock);
80102b39:	c7 04 24 40 c7 10 80 	movl   $0x8010c740,(%esp)
80102b40:	e8 28 2e 00 00       	call   8010596d <release>
}
80102b45:	c9                   	leave  
80102b46:	c3                   	ret    
	...

80102b48 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102b48:	55                   	push   %ebp
80102b49:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b4b:	a1 14 48 11 80       	mov    0x80114814,%eax
80102b50:	8b 55 08             	mov    0x8(%ebp),%edx
80102b53:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102b55:	a1 14 48 11 80       	mov    0x80114814,%eax
80102b5a:	8b 40 10             	mov    0x10(%eax),%eax
}
80102b5d:	5d                   	pop    %ebp
80102b5e:	c3                   	ret    

80102b5f <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102b5f:	55                   	push   %ebp
80102b60:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102b62:	a1 14 48 11 80       	mov    0x80114814,%eax
80102b67:	8b 55 08             	mov    0x8(%ebp),%edx
80102b6a:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102b6c:	a1 14 48 11 80       	mov    0x80114814,%eax
80102b71:	8b 55 0c             	mov    0xc(%ebp),%edx
80102b74:	89 50 10             	mov    %edx,0x10(%eax)
}
80102b77:	5d                   	pop    %ebp
80102b78:	c3                   	ret    

80102b79 <ioapicinit>:

void
ioapicinit(void)
{
80102b79:	55                   	push   %ebp
80102b7a:	89 e5                	mov    %esp,%ebp
80102b7c:	83 ec 28             	sub    $0x28,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102b7f:	c7 05 14 48 11 80 00 	movl   $0xfec00000,0x80114814
80102b86:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102b89:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80102b90:	e8 b3 ff ff ff       	call   80102b48 <ioapicread>
80102b95:	c1 e8 10             	shr    $0x10,%eax
80102b98:	25 ff 00 00 00       	and    $0xff,%eax
80102b9d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102ba0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80102ba7:	e8 9c ff ff ff       	call   80102b48 <ioapicread>
80102bac:	c1 e8 18             	shr    $0x18,%eax
80102baf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102bb2:	a0 40 49 11 80       	mov    0x80114940,%al
80102bb7:	0f b6 c0             	movzbl %al,%eax
80102bba:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102bbd:	74 0c                	je     80102bcb <ioapicinit+0x52>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102bbf:	c7 04 24 18 94 10 80 	movl   $0x80109418,(%esp)
80102bc6:	e8 f6 d7 ff ff       	call   801003c1 <cprintf>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102bcb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102bd2:	eb 3d                	jmp    80102c11 <ioapicinit+0x98>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bd7:	83 c0 20             	add    $0x20,%eax
80102bda:	0d 00 00 01 00       	or     $0x10000,%eax
80102bdf:	89 c2                	mov    %eax,%edx
80102be1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102be4:	83 c0 08             	add    $0x8,%eax
80102be7:	01 c0                	add    %eax,%eax
80102be9:	89 54 24 04          	mov    %edx,0x4(%esp)
80102bed:	89 04 24             	mov    %eax,(%esp)
80102bf0:	e8 6a ff ff ff       	call   80102b5f <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bf8:	83 c0 08             	add    $0x8,%eax
80102bfb:	01 c0                	add    %eax,%eax
80102bfd:	40                   	inc    %eax
80102bfe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80102c05:	00 
80102c06:	89 04 24             	mov    %eax,(%esp)
80102c09:	e8 51 ff ff ff       	call   80102b5f <ioapicwrite>
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102c0e:	ff 45 f4             	incl   -0xc(%ebp)
80102c11:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c14:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102c17:	7e bb                	jle    80102bd4 <ioapicinit+0x5b>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102c19:	c9                   	leave  
80102c1a:	c3                   	ret    

80102c1b <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102c1b:	55                   	push   %ebp
80102c1c:	89 e5                	mov    %esp,%ebp
80102c1e:	83 ec 08             	sub    $0x8,%esp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102c21:	8b 45 08             	mov    0x8(%ebp),%eax
80102c24:	83 c0 20             	add    $0x20,%eax
80102c27:	89 c2                	mov    %eax,%edx
80102c29:	8b 45 08             	mov    0x8(%ebp),%eax
80102c2c:	83 c0 08             	add    $0x8,%eax
80102c2f:	01 c0                	add    %eax,%eax
80102c31:	89 54 24 04          	mov    %edx,0x4(%esp)
80102c35:	89 04 24             	mov    %eax,(%esp)
80102c38:	e8 22 ff ff ff       	call   80102b5f <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102c3d:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c40:	c1 e0 18             	shl    $0x18,%eax
80102c43:	8b 55 08             	mov    0x8(%ebp),%edx
80102c46:	83 c2 08             	add    $0x8,%edx
80102c49:	01 d2                	add    %edx,%edx
80102c4b:	42                   	inc    %edx
80102c4c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c50:	89 14 24             	mov    %edx,(%esp)
80102c53:	e8 07 ff ff ff       	call   80102b5f <ioapicwrite>
}
80102c58:	c9                   	leave  
80102c59:	c3                   	ret    
	...

80102c5c <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102c5c:	55                   	push   %ebp
80102c5d:	89 e5                	mov    %esp,%ebp
80102c5f:	83 ec 18             	sub    $0x18,%esp
  initlock(&kmem.lock, "kmem");
80102c62:	c7 44 24 04 4a 94 10 	movl   $0x8010944a,0x4(%esp)
80102c69:	80 
80102c6a:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102c71:	e8 6c 2c 00 00       	call   801058e2 <initlock>
  kmem.use_lock = 0;
80102c76:	c7 05 54 48 11 80 00 	movl   $0x0,0x80114854
80102c7d:	00 00 00 
  freerange(vstart, vend);
80102c80:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c83:	89 44 24 04          	mov    %eax,0x4(%esp)
80102c87:	8b 45 08             	mov    0x8(%ebp),%eax
80102c8a:	89 04 24             	mov    %eax,(%esp)
80102c8d:	e8 26 00 00 00       	call   80102cb8 <freerange>
}
80102c92:	c9                   	leave  
80102c93:	c3                   	ret    

80102c94 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102c94:	55                   	push   %ebp
80102c95:	89 e5                	mov    %esp,%ebp
80102c97:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
80102c9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80102c9d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102ca1:	8b 45 08             	mov    0x8(%ebp),%eax
80102ca4:	89 04 24             	mov    %eax,(%esp)
80102ca7:	e8 0c 00 00 00       	call   80102cb8 <freerange>
  kmem.use_lock = 1;
80102cac:	c7 05 54 48 11 80 01 	movl   $0x1,0x80114854
80102cb3:	00 00 00 
}
80102cb6:	c9                   	leave  
80102cb7:	c3                   	ret    

80102cb8 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102cb8:	55                   	push   %ebp
80102cb9:	89 e5                	mov    %esp,%ebp
80102cbb:	83 ec 28             	sub    $0x28,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102cbe:	8b 45 08             	mov    0x8(%ebp),%eax
80102cc1:	05 ff 0f 00 00       	add    $0xfff,%eax
80102cc6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102ccb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102cce:	eb 12                	jmp    80102ce2 <freerange+0x2a>
    kfree(p);
80102cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cd3:	89 04 24             	mov    %eax,(%esp)
80102cd6:	e8 16 00 00 00       	call   80102cf1 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102cdb:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ce5:	05 00 10 00 00       	add    $0x1000,%eax
80102cea:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102ced:	76 e1                	jbe    80102cd0 <freerange+0x18>
    kfree(p);
}
80102cef:	c9                   	leave  
80102cf0:	c3                   	ret    

80102cf1 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102cf1:	55                   	push   %ebp
80102cf2:	89 e5                	mov    %esp,%ebp
80102cf4:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102cf7:	8b 45 08             	mov    0x8(%ebp),%eax
80102cfa:	25 ff 0f 00 00       	and    $0xfff,%eax
80102cff:	85 c0                	test   %eax,%eax
80102d01:	75 18                	jne    80102d1b <kfree+0x2a>
80102d03:	81 7d 08 48 61 12 80 	cmpl   $0x80126148,0x8(%ebp)
80102d0a:	72 0f                	jb     80102d1b <kfree+0x2a>
80102d0c:	8b 45 08             	mov    0x8(%ebp),%eax
80102d0f:	05 00 00 00 80       	add    $0x80000000,%eax
80102d14:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102d19:	76 0c                	jbe    80102d27 <kfree+0x36>
    panic("kfree");
80102d1b:	c7 04 24 4f 94 10 80 	movl   $0x8010944f,(%esp)
80102d22:	e8 2d d8 ff ff       	call   80100554 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102d27:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80102d2e:	00 
80102d2f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80102d36:	00 
80102d37:	8b 45 08             	mov    0x8(%ebp),%eax
80102d3a:	89 04 24             	mov    %eax,(%esp)
80102d3d:	e8 24 2e 00 00       	call   80105b66 <memset>

  if(kmem.use_lock)
80102d42:	a1 54 48 11 80       	mov    0x80114854,%eax
80102d47:	85 c0                	test   %eax,%eax
80102d49:	74 0c                	je     80102d57 <kfree+0x66>
    acquire(&kmem.lock);
80102d4b:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102d52:	e8 ac 2b 00 00       	call   80105903 <acquire>
  r = (struct run*)v;
80102d57:	8b 45 08             	mov    0x8(%ebp),%eax
80102d5a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102d5d:	8b 15 58 48 11 80    	mov    0x80114858,%edx
80102d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d66:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102d68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102d6b:	a3 58 48 11 80       	mov    %eax,0x80114858
  if(kmem.use_lock)
80102d70:	a1 54 48 11 80       	mov    0x80114854,%eax
80102d75:	85 c0                	test   %eax,%eax
80102d77:	74 0c                	je     80102d85 <kfree+0x94>
    release(&kmem.lock);
80102d79:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102d80:	e8 e8 2b 00 00       	call   8010596d <release>
}
80102d85:	c9                   	leave  
80102d86:	c3                   	ret    

80102d87 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102d87:	55                   	push   %ebp
80102d88:	89 e5                	mov    %esp,%ebp
80102d8a:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
80102d8d:	a1 54 48 11 80       	mov    0x80114854,%eax
80102d92:	85 c0                	test   %eax,%eax
80102d94:	74 0c                	je     80102da2 <kalloc+0x1b>
    acquire(&kmem.lock);
80102d96:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102d9d:	e8 61 2b 00 00       	call   80105903 <acquire>
  r = kmem.freelist;
80102da2:	a1 58 48 11 80       	mov    0x80114858,%eax
80102da7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102daa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102dae:	74 0a                	je     80102dba <kalloc+0x33>
    kmem.freelist = r->next;
80102db0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102db3:	8b 00                	mov    (%eax),%eax
80102db5:	a3 58 48 11 80       	mov    %eax,0x80114858
  if(kmem.use_lock)
80102dba:	a1 54 48 11 80       	mov    0x80114854,%eax
80102dbf:	85 c0                	test   %eax,%eax
80102dc1:	74 0c                	je     80102dcf <kalloc+0x48>
    release(&kmem.lock);
80102dc3:	c7 04 24 20 48 11 80 	movl   $0x80114820,(%esp)
80102dca:	e8 9e 2b 00 00       	call   8010596d <release>
  return (char*)r;
80102dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102dd2:	c9                   	leave  
80102dd3:	c3                   	ret    

80102dd4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102dd4:	55                   	push   %ebp
80102dd5:	89 e5                	mov    %esp,%ebp
80102dd7:	83 ec 14             	sub    $0x14,%esp
80102dda:	8b 45 08             	mov    0x8(%ebp),%eax
80102ddd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102de1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102de4:	89 c2                	mov    %eax,%edx
80102de6:	ec                   	in     (%dx),%al
80102de7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102dea:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102ded:	c9                   	leave  
80102dee:	c3                   	ret    

80102def <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102def:	55                   	push   %ebp
80102df0:	89 e5                	mov    %esp,%ebp
80102df2:	83 ec 14             	sub    $0x14,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102df5:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
80102dfc:	e8 d3 ff ff ff       	call   80102dd4 <inb>
80102e01:	0f b6 c0             	movzbl %al,%eax
80102e04:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e0a:	83 e0 01             	and    $0x1,%eax
80102e0d:	85 c0                	test   %eax,%eax
80102e0f:	75 0a                	jne    80102e1b <kbdgetc+0x2c>
    return -1;
80102e11:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e16:	e9 21 01 00 00       	jmp    80102f3c <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102e1b:	c7 04 24 60 00 00 00 	movl   $0x60,(%esp)
80102e22:	e8 ad ff ff ff       	call   80102dd4 <inb>
80102e27:	0f b6 c0             	movzbl %al,%eax
80102e2a:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102e2d:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102e34:	75 17                	jne    80102e4d <kbdgetc+0x5e>
    shift |= E0ESC;
80102e36:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102e3b:	83 c8 40             	or     $0x40,%eax
80102e3e:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
    return 0;
80102e43:	b8 00 00 00 00       	mov    $0x0,%eax
80102e48:	e9 ef 00 00 00       	jmp    80102f3c <kbdgetc+0x14d>
  } else if(data & 0x80){
80102e4d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e50:	25 80 00 00 00       	and    $0x80,%eax
80102e55:	85 c0                	test   %eax,%eax
80102e57:	74 44                	je     80102e9d <kbdgetc+0xae>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102e59:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102e5e:	83 e0 40             	and    $0x40,%eax
80102e61:	85 c0                	test   %eax,%eax
80102e63:	75 08                	jne    80102e6d <kbdgetc+0x7e>
80102e65:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e68:	83 e0 7f             	and    $0x7f,%eax
80102e6b:	eb 03                	jmp    80102e70 <kbdgetc+0x81>
80102e6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e70:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102e73:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102e76:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102e7b:	8a 00                	mov    (%eax),%al
80102e7d:	83 c8 40             	or     $0x40,%eax
80102e80:	0f b6 c0             	movzbl %al,%eax
80102e83:	f7 d0                	not    %eax
80102e85:	89 c2                	mov    %eax,%edx
80102e87:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102e8c:	21 d0                	and    %edx,%eax
80102e8e:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
    return 0;
80102e93:	b8 00 00 00 00       	mov    $0x0,%eax
80102e98:	e9 9f 00 00 00       	jmp    80102f3c <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102e9d:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102ea2:	83 e0 40             	and    $0x40,%eax
80102ea5:	85 c0                	test   %eax,%eax
80102ea7:	74 14                	je     80102ebd <kbdgetc+0xce>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102ea9:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102eb0:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102eb5:	83 e0 bf             	and    $0xffffffbf,%eax
80102eb8:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
  }

  shift |= shiftcode[data];
80102ebd:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ec0:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102ec5:	8a 00                	mov    (%eax),%al
80102ec7:	0f b6 d0             	movzbl %al,%edx
80102eca:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102ecf:	09 d0                	or     %edx,%eax
80102ed1:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
  shift ^= togglecode[data];
80102ed6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102ed9:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102ede:	8a 00                	mov    (%eax),%al
80102ee0:	0f b6 d0             	movzbl %al,%edx
80102ee3:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102ee8:	31 d0                	xor    %edx,%eax
80102eea:	a3 7c c7 10 80       	mov    %eax,0x8010c77c
  c = charcode[shift & (CTL | SHIFT)][data];
80102eef:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102ef4:	83 e0 03             	and    $0x3,%eax
80102ef7:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102efe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102f01:	01 d0                	add    %edx,%eax
80102f03:	8a 00                	mov    (%eax),%al
80102f05:	0f b6 c0             	movzbl %al,%eax
80102f08:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102f0b:	a1 7c c7 10 80       	mov    0x8010c77c,%eax
80102f10:	83 e0 08             	and    $0x8,%eax
80102f13:	85 c0                	test   %eax,%eax
80102f15:	74 22                	je     80102f39 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102f17:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102f1b:	76 0c                	jbe    80102f29 <kbdgetc+0x13a>
80102f1d:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102f21:	77 06                	ja     80102f29 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102f23:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102f27:	eb 10                	jmp    80102f39 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102f29:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102f2d:	76 0a                	jbe    80102f39 <kbdgetc+0x14a>
80102f2f:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102f33:	77 04                	ja     80102f39 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102f35:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102f39:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102f3c:	c9                   	leave  
80102f3d:	c3                   	ret    

80102f3e <kbdintr>:

void
kbdintr(void)
{
80102f3e:	55                   	push   %ebp
80102f3f:	89 e5                	mov    %esp,%ebp
80102f41:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
80102f44:	c7 04 24 ef 2d 10 80 	movl   $0x80102def,(%esp)
80102f4b:	e8 a5 d8 ff ff       	call   801007f5 <consoleintr>
}
80102f50:	c9                   	leave  
80102f51:	c3                   	ret    
	...

80102f54 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102f54:	55                   	push   %ebp
80102f55:	89 e5                	mov    %esp,%ebp
80102f57:	83 ec 14             	sub    $0x14,%esp
80102f5a:	8b 45 08             	mov    0x8(%ebp),%eax
80102f5d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f61:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f64:	89 c2                	mov    %eax,%edx
80102f66:	ec                   	in     (%dx),%al
80102f67:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102f6a:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80102f6d:	c9                   	leave  
80102f6e:	c3                   	ret    

80102f6f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102f6f:	55                   	push   %ebp
80102f70:	89 e5                	mov    %esp,%ebp
80102f72:	83 ec 08             	sub    $0x8,%esp
80102f75:	8b 45 08             	mov    0x8(%ebp),%eax
80102f78:	8b 55 0c             	mov    0xc(%ebp),%edx
80102f7b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80102f7f:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f82:	8a 45 f8             	mov    -0x8(%ebp),%al
80102f85:	8b 55 fc             	mov    -0x4(%ebp),%edx
80102f88:	ee                   	out    %al,(%dx)
}
80102f89:	c9                   	leave  
80102f8a:	c3                   	ret    

80102f8b <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
80102f8b:	55                   	push   %ebp
80102f8c:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102f8e:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80102f93:	8b 55 08             	mov    0x8(%ebp),%edx
80102f96:	c1 e2 02             	shl    $0x2,%edx
80102f99:	01 c2                	add    %eax,%edx
80102f9b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f9e:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102fa0:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80102fa5:	83 c0 20             	add    $0x20,%eax
80102fa8:	8b 00                	mov    (%eax),%eax
}
80102faa:	5d                   	pop    %ebp
80102fab:	c3                   	ret    

80102fac <lapicinit>:

void
lapicinit(void)
{
80102fac:	55                   	push   %ebp
80102fad:	89 e5                	mov    %esp,%ebp
80102faf:	83 ec 08             	sub    $0x8,%esp
  if(!lapic)
80102fb2:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80102fb7:	85 c0                	test   %eax,%eax
80102fb9:	75 05                	jne    80102fc0 <lapicinit+0x14>
    return;
80102fbb:	e9 43 01 00 00       	jmp    80103103 <lapicinit+0x157>

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102fc0:	c7 44 24 04 3f 01 00 	movl   $0x13f,0x4(%esp)
80102fc7:	00 
80102fc8:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
80102fcf:	e8 b7 ff ff ff       	call   80102f8b <lapicw>

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102fd4:	c7 44 24 04 0b 00 00 	movl   $0xb,0x4(%esp)
80102fdb:	00 
80102fdc:	c7 04 24 f8 00 00 00 	movl   $0xf8,(%esp)
80102fe3:	e8 a3 ff ff ff       	call   80102f8b <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102fe8:	c7 44 24 04 20 00 02 	movl   $0x20020,0x4(%esp)
80102fef:	00 
80102ff0:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
80102ff7:	e8 8f ff ff ff       	call   80102f8b <lapicw>
  lapicw(TICR, 10000000);
80102ffc:	c7 44 24 04 80 96 98 	movl   $0x989680,0x4(%esp)
80103003:	00 
80103004:	c7 04 24 e0 00 00 00 	movl   $0xe0,(%esp)
8010300b:	e8 7b ff ff ff       	call   80102f8b <lapicw>

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80103010:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103017:	00 
80103018:	c7 04 24 d4 00 00 00 	movl   $0xd4,(%esp)
8010301f:	e8 67 ff ff ff       	call   80102f8b <lapicw>
  lapicw(LINT1, MASKED);
80103024:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
8010302b:	00 
8010302c:	c7 04 24 d8 00 00 00 	movl   $0xd8,(%esp)
80103033:	e8 53 ff ff ff       	call   80102f8b <lapicw>

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80103038:	a1 5c 48 11 80       	mov    0x8011485c,%eax
8010303d:	83 c0 30             	add    $0x30,%eax
80103040:	8b 00                	mov    (%eax),%eax
80103042:	c1 e8 10             	shr    $0x10,%eax
80103045:	0f b6 c0             	movzbl %al,%eax
80103048:	83 f8 03             	cmp    $0x3,%eax
8010304b:	76 14                	jbe    80103061 <lapicinit+0xb5>
    lapicw(PCINT, MASKED);
8010304d:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103054:	00 
80103055:	c7 04 24 d0 00 00 00 	movl   $0xd0,(%esp)
8010305c:	e8 2a ff ff ff       	call   80102f8b <lapicw>

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80103061:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
80103068:	00 
80103069:	c7 04 24 dc 00 00 00 	movl   $0xdc,(%esp)
80103070:	e8 16 ff ff ff       	call   80102f8b <lapicw>

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80103075:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010307c:	00 
8010307d:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103084:	e8 02 ff ff ff       	call   80102f8b <lapicw>
  lapicw(ESR, 0);
80103089:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103090:	00 
80103091:	c7 04 24 a0 00 00 00 	movl   $0xa0,(%esp)
80103098:	e8 ee fe ff ff       	call   80102f8b <lapicw>

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
8010309d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030a4:	00 
801030a5:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
801030ac:	e8 da fe ff ff       	call   80102f8b <lapicw>

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
801030b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030b8:	00 
801030b9:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801030c0:	e8 c6 fe ff ff       	call   80102f8b <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801030c5:	c7 44 24 04 00 85 08 	movl   $0x88500,0x4(%esp)
801030cc:	00 
801030cd:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801030d4:	e8 b2 fe ff ff       	call   80102f8b <lapicw>
  while(lapic[ICRLO] & DELIVS)
801030d9:	90                   	nop
801030da:	a1 5c 48 11 80       	mov    0x8011485c,%eax
801030df:	05 00 03 00 00       	add    $0x300,%eax
801030e4:	8b 00                	mov    (%eax),%eax
801030e6:	25 00 10 00 00       	and    $0x1000,%eax
801030eb:	85 c0                	test   %eax,%eax
801030ed:	75 eb                	jne    801030da <lapicinit+0x12e>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
801030ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801030f6:	00 
801030f7:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
801030fe:	e8 88 fe ff ff       	call   80102f8b <lapicw>
}
80103103:	c9                   	leave  
80103104:	c3                   	ret    

80103105 <lapicid>:

int
lapicid(void)
{
80103105:	55                   	push   %ebp
80103106:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80103108:	a1 5c 48 11 80       	mov    0x8011485c,%eax
8010310d:	85 c0                	test   %eax,%eax
8010310f:	75 07                	jne    80103118 <lapicid+0x13>
    return 0;
80103111:	b8 00 00 00 00       	mov    $0x0,%eax
80103116:	eb 0d                	jmp    80103125 <lapicid+0x20>
  return lapic[ID] >> 24;
80103118:	a1 5c 48 11 80       	mov    0x8011485c,%eax
8010311d:	83 c0 20             	add    $0x20,%eax
80103120:	8b 00                	mov    (%eax),%eax
80103122:	c1 e8 18             	shr    $0x18,%eax
}
80103125:	5d                   	pop    %ebp
80103126:	c3                   	ret    

80103127 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80103127:	55                   	push   %ebp
80103128:	89 e5                	mov    %esp,%ebp
8010312a:	83 ec 08             	sub    $0x8,%esp
  if(lapic)
8010312d:	a1 5c 48 11 80       	mov    0x8011485c,%eax
80103132:	85 c0                	test   %eax,%eax
80103134:	74 14                	je     8010314a <lapiceoi+0x23>
    lapicw(EOI, 0);
80103136:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010313d:	00 
8010313e:	c7 04 24 2c 00 00 00 	movl   $0x2c,(%esp)
80103145:	e8 41 fe ff ff       	call   80102f8b <lapicw>
}
8010314a:	c9                   	leave  
8010314b:	c3                   	ret    

8010314c <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
8010314c:	55                   	push   %ebp
8010314d:	89 e5                	mov    %esp,%ebp
}
8010314f:	5d                   	pop    %ebp
80103150:	c3                   	ret    

80103151 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80103151:	55                   	push   %ebp
80103152:	89 e5                	mov    %esp,%ebp
80103154:	83 ec 1c             	sub    $0x1c,%esp
80103157:	8b 45 08             	mov    0x8(%ebp),%eax
8010315a:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
8010315d:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
80103164:	00 
80103165:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
8010316c:	e8 fe fd ff ff       	call   80102f6f <outb>
  outb(CMOS_PORT+1, 0x0A);
80103171:	c7 44 24 04 0a 00 00 	movl   $0xa,0x4(%esp)
80103178:	00 
80103179:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103180:	e8 ea fd ff ff       	call   80102f6f <outb>
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80103185:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
8010318c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010318f:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80103194:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103197:	8d 50 02             	lea    0x2(%eax),%edx
8010319a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010319d:	c1 e8 04             	shr    $0x4,%eax
801031a0:	66 89 02             	mov    %ax,(%edx)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
801031a3:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801031a7:	c1 e0 18             	shl    $0x18,%eax
801031aa:	89 44 24 04          	mov    %eax,0x4(%esp)
801031ae:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
801031b5:	e8 d1 fd ff ff       	call   80102f8b <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801031ba:	c7 44 24 04 00 c5 00 	movl   $0xc500,0x4(%esp)
801031c1:	00 
801031c2:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031c9:	e8 bd fd ff ff       	call   80102f8b <lapicw>
  microdelay(200);
801031ce:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
801031d5:	e8 72 ff ff ff       	call   8010314c <microdelay>
  lapicw(ICRLO, INIT | LEVEL);
801031da:	c7 44 24 04 00 85 00 	movl   $0x8500,0x4(%esp)
801031e1:	00 
801031e2:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
801031e9:	e8 9d fd ff ff       	call   80102f8b <lapicw>
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801031ee:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
801031f5:	e8 52 ff ff ff       	call   8010314c <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801031fa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103201:	eb 3f                	jmp    80103242 <lapicstartap+0xf1>
    lapicw(ICRHI, apicid<<24);
80103203:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103207:	c1 e0 18             	shl    $0x18,%eax
8010320a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010320e:	c7 04 24 c4 00 00 00 	movl   $0xc4,(%esp)
80103215:	e8 71 fd ff ff       	call   80102f8b <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
8010321a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010321d:	c1 e8 0c             	shr    $0xc,%eax
80103220:	80 cc 06             	or     $0x6,%ah
80103223:	89 44 24 04          	mov    %eax,0x4(%esp)
80103227:	c7 04 24 c0 00 00 00 	movl   $0xc0,(%esp)
8010322e:	e8 58 fd ff ff       	call   80102f8b <lapicw>
    microdelay(200);
80103233:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010323a:	e8 0d ff ff ff       	call   8010314c <microdelay>
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
8010323f:	ff 45 fc             	incl   -0x4(%ebp)
80103242:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103246:	7e bb                	jle    80103203 <lapicstartap+0xb2>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103248:	c9                   	leave  
80103249:	c3                   	ret    

8010324a <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010324a:	55                   	push   %ebp
8010324b:	89 e5                	mov    %esp,%ebp
8010324d:	83 ec 08             	sub    $0x8,%esp
  outb(CMOS_PORT,  reg);
80103250:	8b 45 08             	mov    0x8(%ebp),%eax
80103253:	0f b6 c0             	movzbl %al,%eax
80103256:	89 44 24 04          	mov    %eax,0x4(%esp)
8010325a:	c7 04 24 70 00 00 00 	movl   $0x70,(%esp)
80103261:	e8 09 fd ff ff       	call   80102f6f <outb>
  microdelay(200);
80103266:	c7 04 24 c8 00 00 00 	movl   $0xc8,(%esp)
8010326d:	e8 da fe ff ff       	call   8010314c <microdelay>

  return inb(CMOS_RETURN);
80103272:	c7 04 24 71 00 00 00 	movl   $0x71,(%esp)
80103279:	e8 d6 fc ff ff       	call   80102f54 <inb>
8010327e:	0f b6 c0             	movzbl %al,%eax
}
80103281:	c9                   	leave  
80103282:	c3                   	ret    

80103283 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80103283:	55                   	push   %ebp
80103284:	89 e5                	mov    %esp,%ebp
80103286:	83 ec 04             	sub    $0x4,%esp
  r->second = cmos_read(SECS);
80103289:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80103290:	e8 b5 ff ff ff       	call   8010324a <cmos_read>
80103295:	8b 55 08             	mov    0x8(%ebp),%edx
80103298:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
8010329a:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801032a1:	e8 a4 ff ff ff       	call   8010324a <cmos_read>
801032a6:	8b 55 08             	mov    0x8(%ebp),%edx
801032a9:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
801032ac:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
801032b3:	e8 92 ff ff ff       	call   8010324a <cmos_read>
801032b8:	8b 55 08             	mov    0x8(%ebp),%edx
801032bb:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
801032be:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
801032c5:	e8 80 ff ff ff       	call   8010324a <cmos_read>
801032ca:	8b 55 08             	mov    0x8(%ebp),%edx
801032cd:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
801032d0:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
801032d7:	e8 6e ff ff ff       	call   8010324a <cmos_read>
801032dc:	8b 55 08             	mov    0x8(%ebp),%edx
801032df:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
801032e2:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
801032e9:	e8 5c ff ff ff       	call   8010324a <cmos_read>
801032ee:	8b 55 08             	mov    0x8(%ebp),%edx
801032f1:	89 42 14             	mov    %eax,0x14(%edx)
}
801032f4:	c9                   	leave  
801032f5:	c3                   	ret    

801032f6 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801032f6:	55                   	push   %ebp
801032f7:	89 e5                	mov    %esp,%ebp
801032f9:	57                   	push   %edi
801032fa:	56                   	push   %esi
801032fb:	53                   	push   %ebx
801032fc:	83 ec 5c             	sub    $0x5c,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801032ff:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
80103306:	e8 3f ff ff ff       	call   8010324a <cmos_read>
8010330b:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010330e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103311:	83 e0 04             	and    $0x4,%eax
80103314:	85 c0                	test   %eax,%eax
80103316:	0f 94 c0             	sete   %al
80103319:	0f b6 c0             	movzbl %al,%eax
8010331c:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
8010331f:	8d 45 c8             	lea    -0x38(%ebp),%eax
80103322:	89 04 24             	mov    %eax,(%esp)
80103325:	e8 59 ff ff ff       	call   80103283 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010332a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
80103331:	e8 14 ff ff ff       	call   8010324a <cmos_read>
80103336:	25 80 00 00 00       	and    $0x80,%eax
8010333b:	85 c0                	test   %eax,%eax
8010333d:	74 02                	je     80103341 <cmostime+0x4b>
        continue;
8010333f:	eb 36                	jmp    80103377 <cmostime+0x81>
    fill_rtcdate(&t2);
80103341:	8d 45 b0             	lea    -0x50(%ebp),%eax
80103344:	89 04 24             	mov    %eax,(%esp)
80103347:	e8 37 ff ff ff       	call   80103283 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010334c:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
80103353:	00 
80103354:	8d 45 b0             	lea    -0x50(%ebp),%eax
80103357:	89 44 24 04          	mov    %eax,0x4(%esp)
8010335b:	8d 45 c8             	lea    -0x38(%ebp),%eax
8010335e:	89 04 24             	mov    %eax,(%esp)
80103361:	e8 77 28 00 00       	call   80105bdd <memcmp>
80103366:	85 c0                	test   %eax,%eax
80103368:	75 0d                	jne    80103377 <cmostime+0x81>
      break;
8010336a:	90                   	nop
  }

  // convert
  if(bcd) {
8010336b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010336f:	0f 84 ac 00 00 00    	je     80103421 <cmostime+0x12b>
80103375:	eb 02                	jmp    80103379 <cmostime+0x83>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103377:	eb a6                	jmp    8010331f <cmostime+0x29>

  // convert
  if(bcd) {
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103379:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010337c:	c1 e8 04             	shr    $0x4,%eax
8010337f:	89 c2                	mov    %eax,%edx
80103381:	89 d0                	mov    %edx,%eax
80103383:	c1 e0 02             	shl    $0x2,%eax
80103386:	01 d0                	add    %edx,%eax
80103388:	01 c0                	add    %eax,%eax
8010338a:	8b 55 c8             	mov    -0x38(%ebp),%edx
8010338d:	83 e2 0f             	and    $0xf,%edx
80103390:	01 d0                	add    %edx,%eax
80103392:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(minute);
80103395:	8b 45 cc             	mov    -0x34(%ebp),%eax
80103398:	c1 e8 04             	shr    $0x4,%eax
8010339b:	89 c2                	mov    %eax,%edx
8010339d:	89 d0                	mov    %edx,%eax
8010339f:	c1 e0 02             	shl    $0x2,%eax
801033a2:	01 d0                	add    %edx,%eax
801033a4:	01 c0                	add    %eax,%eax
801033a6:	8b 55 cc             	mov    -0x34(%ebp),%edx
801033a9:	83 e2 0f             	and    $0xf,%edx
801033ac:	01 d0                	add    %edx,%eax
801033ae:	89 45 cc             	mov    %eax,-0x34(%ebp)
    CONV(hour  );
801033b1:	8b 45 d0             	mov    -0x30(%ebp),%eax
801033b4:	c1 e8 04             	shr    $0x4,%eax
801033b7:	89 c2                	mov    %eax,%edx
801033b9:	89 d0                	mov    %edx,%eax
801033bb:	c1 e0 02             	shl    $0x2,%eax
801033be:	01 d0                	add    %edx,%eax
801033c0:	01 c0                	add    %eax,%eax
801033c2:	8b 55 d0             	mov    -0x30(%ebp),%edx
801033c5:	83 e2 0f             	and    $0xf,%edx
801033c8:	01 d0                	add    %edx,%eax
801033ca:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(day   );
801033cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801033d0:	c1 e8 04             	shr    $0x4,%eax
801033d3:	89 c2                	mov    %eax,%edx
801033d5:	89 d0                	mov    %edx,%eax
801033d7:	c1 e0 02             	shl    $0x2,%eax
801033da:	01 d0                	add    %edx,%eax
801033dc:	01 c0                	add    %eax,%eax
801033de:	8b 55 d4             	mov    -0x2c(%ebp),%edx
801033e1:	83 e2 0f             	and    $0xf,%edx
801033e4:	01 d0                	add    %edx,%eax
801033e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(month );
801033e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801033ec:	c1 e8 04             	shr    $0x4,%eax
801033ef:	89 c2                	mov    %eax,%edx
801033f1:	89 d0                	mov    %edx,%eax
801033f3:	c1 e0 02             	shl    $0x2,%eax
801033f6:	01 d0                	add    %edx,%eax
801033f8:	01 c0                	add    %eax,%eax
801033fa:	8b 55 d8             	mov    -0x28(%ebp),%edx
801033fd:	83 e2 0f             	and    $0xf,%edx
80103400:	01 d0                	add    %edx,%eax
80103402:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(year  );
80103405:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103408:	c1 e8 04             	shr    $0x4,%eax
8010340b:	89 c2                	mov    %eax,%edx
8010340d:	89 d0                	mov    %edx,%eax
8010340f:	c1 e0 02             	shl    $0x2,%eax
80103412:	01 d0                	add    %edx,%eax
80103414:	01 c0                	add    %eax,%eax
80103416:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103419:	83 e2 0f             	and    $0xf,%edx
8010341c:	01 d0                	add    %edx,%eax
8010341e:	89 45 dc             	mov    %eax,-0x24(%ebp)
#undef     CONV
  }

  *r = t1;
80103421:	8b 45 08             	mov    0x8(%ebp),%eax
80103424:	89 c2                	mov    %eax,%edx
80103426:	8d 5d c8             	lea    -0x38(%ebp),%ebx
80103429:	b8 06 00 00 00       	mov    $0x6,%eax
8010342e:	89 d7                	mov    %edx,%edi
80103430:	89 de                	mov    %ebx,%esi
80103432:	89 c1                	mov    %eax,%ecx
80103434:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
80103436:	8b 45 08             	mov    0x8(%ebp),%eax
80103439:	8b 40 14             	mov    0x14(%eax),%eax
8010343c:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103442:	8b 45 08             	mov    0x8(%ebp),%eax
80103445:	89 50 14             	mov    %edx,0x14(%eax)
}
80103448:	83 c4 5c             	add    $0x5c,%esp
8010344b:	5b                   	pop    %ebx
8010344c:	5e                   	pop    %esi
8010344d:	5f                   	pop    %edi
8010344e:	5d                   	pop    %ebp
8010344f:	c3                   	ret    

80103450 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103450:	55                   	push   %ebp
80103451:	89 e5                	mov    %esp,%ebp
80103453:	83 ec 38             	sub    $0x38,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103456:	c7 44 24 04 55 94 10 	movl   $0x80109455,0x4(%esp)
8010345d:	80 
8010345e:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103465:	e8 78 24 00 00       	call   801058e2 <initlock>
  readsb(dev, &sb);
8010346a:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010346d:	89 44 24 04          	mov    %eax,0x4(%esp)
80103471:	8b 45 08             	mov    0x8(%ebp),%eax
80103474:	89 04 24             	mov    %eax,(%esp)
80103477:	e8 a8 df ff ff       	call   80101424 <readsb>
  log.start = sb.logstart;
8010347c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010347f:	a3 94 48 11 80       	mov    %eax,0x80114894
  log.size = sb.nlog;
80103484:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103487:	a3 98 48 11 80       	mov    %eax,0x80114898
  log.dev = dev;
8010348c:	8b 45 08             	mov    0x8(%ebp),%eax
8010348f:	a3 a4 48 11 80       	mov    %eax,0x801148a4
  recover_from_log();
80103494:	e8 95 01 00 00       	call   8010362e <recover_from_log>
}
80103499:	c9                   	leave  
8010349a:	c3                   	ret    

8010349b <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
8010349b:	55                   	push   %ebp
8010349c:	89 e5                	mov    %esp,%ebp
8010349e:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801034a1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034a8:	e9 89 00 00 00       	jmp    80103536 <install_trans+0x9b>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801034ad:	8b 15 94 48 11 80    	mov    0x80114894,%edx
801034b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034b6:	01 d0                	add    %edx,%eax
801034b8:	40                   	inc    %eax
801034b9:	89 c2                	mov    %eax,%edx
801034bb:	a1 a4 48 11 80       	mov    0x801148a4,%eax
801034c0:	89 54 24 04          	mov    %edx,0x4(%esp)
801034c4:	89 04 24             	mov    %eax,(%esp)
801034c7:	e8 e9 cc ff ff       	call   801001b5 <bread>
801034cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801034cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034d2:	83 c0 10             	add    $0x10,%eax
801034d5:	8b 04 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%eax
801034dc:	89 c2                	mov    %eax,%edx
801034de:	a1 a4 48 11 80       	mov    0x801148a4,%eax
801034e3:	89 54 24 04          	mov    %edx,0x4(%esp)
801034e7:	89 04 24             	mov    %eax,(%esp)
801034ea:	e8 c6 cc ff ff       	call   801001b5 <bread>
801034ef:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801034f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034f5:	8d 50 5c             	lea    0x5c(%eax),%edx
801034f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034fb:	83 c0 5c             	add    $0x5c,%eax
801034fe:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
80103505:	00 
80103506:	89 54 24 04          	mov    %edx,0x4(%esp)
8010350a:	89 04 24             	mov    %eax,(%esp)
8010350d:	e8 1d 27 00 00       	call   80105c2f <memmove>
    bwrite(dbuf);  // write dst to disk
80103512:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103515:	89 04 24             	mov    %eax,(%esp)
80103518:	e8 cf cc ff ff       	call   801001ec <bwrite>
    brelse(lbuf);
8010351d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103520:	89 04 24             	mov    %eax,(%esp)
80103523:	e8 04 cd ff ff       	call   8010022c <brelse>
    brelse(dbuf);
80103528:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010352b:	89 04 24             	mov    %eax,(%esp)
8010352e:	e8 f9 cc ff ff       	call   8010022c <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103533:	ff 45 f4             	incl   -0xc(%ebp)
80103536:	a1 a8 48 11 80       	mov    0x801148a8,%eax
8010353b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010353e:	0f 8f 69 ff ff ff    	jg     801034ad <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
80103544:	c9                   	leave  
80103545:	c3                   	ret    

80103546 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103546:	55                   	push   %ebp
80103547:	89 e5                	mov    %esp,%ebp
80103549:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
8010354c:	a1 94 48 11 80       	mov    0x80114894,%eax
80103551:	89 c2                	mov    %eax,%edx
80103553:	a1 a4 48 11 80       	mov    0x801148a4,%eax
80103558:	89 54 24 04          	mov    %edx,0x4(%esp)
8010355c:	89 04 24             	mov    %eax,(%esp)
8010355f:	e8 51 cc ff ff       	call   801001b5 <bread>
80103564:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80103567:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010356a:	83 c0 5c             	add    $0x5c,%eax
8010356d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103570:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103573:	8b 00                	mov    (%eax),%eax
80103575:	a3 a8 48 11 80       	mov    %eax,0x801148a8
  for (i = 0; i < log.lh.n; i++) {
8010357a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103581:	eb 1a                	jmp    8010359d <read_head+0x57>
    log.lh.block[i] = lh->block[i];
80103583:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103586:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103589:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
8010358d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103590:	83 c2 10             	add    $0x10,%edx
80103593:	89 04 95 6c 48 11 80 	mov    %eax,-0x7feeb794(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010359a:	ff 45 f4             	incl   -0xc(%ebp)
8010359d:	a1 a8 48 11 80       	mov    0x801148a8,%eax
801035a2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801035a5:	7f dc                	jg     80103583 <read_head+0x3d>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
801035a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035aa:	89 04 24             	mov    %eax,(%esp)
801035ad:	e8 7a cc ff ff       	call   8010022c <brelse>
}
801035b2:	c9                   	leave  
801035b3:	c3                   	ret    

801035b4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801035b4:	55                   	push   %ebp
801035b5:	89 e5                	mov    %esp,%ebp
801035b7:	83 ec 28             	sub    $0x28,%esp
  struct buf *buf = bread(log.dev, log.start);
801035ba:	a1 94 48 11 80       	mov    0x80114894,%eax
801035bf:	89 c2                	mov    %eax,%edx
801035c1:	a1 a4 48 11 80       	mov    0x801148a4,%eax
801035c6:	89 54 24 04          	mov    %edx,0x4(%esp)
801035ca:	89 04 24             	mov    %eax,(%esp)
801035cd:	e8 e3 cb ff ff       	call   801001b5 <bread>
801035d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801035d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801035d8:	83 c0 5c             	add    $0x5c,%eax
801035db:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801035de:	8b 15 a8 48 11 80    	mov    0x801148a8,%edx
801035e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801035e7:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801035e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801035f0:	eb 1a                	jmp    8010360c <write_head+0x58>
    hb->block[i] = log.lh.block[i];
801035f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f5:	83 c0 10             	add    $0x10,%eax
801035f8:	8b 0c 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%ecx
801035ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103602:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103605:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103609:	ff 45 f4             	incl   -0xc(%ebp)
8010360c:	a1 a8 48 11 80       	mov    0x801148a8,%eax
80103611:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103614:	7f dc                	jg     801035f2 <write_head+0x3e>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80103616:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103619:	89 04 24             	mov    %eax,(%esp)
8010361c:	e8 cb cb ff ff       	call   801001ec <bwrite>
  brelse(buf);
80103621:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103624:	89 04 24             	mov    %eax,(%esp)
80103627:	e8 00 cc ff ff       	call   8010022c <brelse>
}
8010362c:	c9                   	leave  
8010362d:	c3                   	ret    

8010362e <recover_from_log>:

static void
recover_from_log(void)
{
8010362e:	55                   	push   %ebp
8010362f:	89 e5                	mov    %esp,%ebp
80103631:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103634:	e8 0d ff ff ff       	call   80103546 <read_head>
  install_trans(); // if committed, copy from log to disk
80103639:	e8 5d fe ff ff       	call   8010349b <install_trans>
  log.lh.n = 0;
8010363e:	c7 05 a8 48 11 80 00 	movl   $0x0,0x801148a8
80103645:	00 00 00 
  write_head(); // clear the log
80103648:	e8 67 ff ff ff       	call   801035b4 <write_head>
}
8010364d:	c9                   	leave  
8010364e:	c3                   	ret    

8010364f <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010364f:	55                   	push   %ebp
80103650:	89 e5                	mov    %esp,%ebp
80103652:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
80103655:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
8010365c:	e8 a2 22 00 00       	call   80105903 <acquire>
  while(1){
    if(log.committing){
80103661:	a1 a0 48 11 80       	mov    0x801148a0,%eax
80103666:	85 c0                	test   %eax,%eax
80103668:	74 16                	je     80103680 <begin_op+0x31>
      sleep(&log, &log.lock);
8010366a:	c7 44 24 04 60 48 11 	movl   $0x80114860,0x4(%esp)
80103671:	80 
80103672:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103679:	e8 ea 14 00 00       	call   80104b68 <sleep>
8010367e:	eb 4d                	jmp    801036cd <begin_op+0x7e>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103680:	8b 15 a8 48 11 80    	mov    0x801148a8,%edx
80103686:	a1 9c 48 11 80       	mov    0x8011489c,%eax
8010368b:	8d 48 01             	lea    0x1(%eax),%ecx
8010368e:	89 c8                	mov    %ecx,%eax
80103690:	c1 e0 02             	shl    $0x2,%eax
80103693:	01 c8                	add    %ecx,%eax
80103695:	01 c0                	add    %eax,%eax
80103697:	01 d0                	add    %edx,%eax
80103699:	83 f8 1e             	cmp    $0x1e,%eax
8010369c:	7e 16                	jle    801036b4 <begin_op+0x65>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
8010369e:	c7 44 24 04 60 48 11 	movl   $0x80114860,0x4(%esp)
801036a5:	80 
801036a6:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801036ad:	e8 b6 14 00 00       	call   80104b68 <sleep>
801036b2:	eb 19                	jmp    801036cd <begin_op+0x7e>
    } else {
      log.outstanding += 1;
801036b4:	a1 9c 48 11 80       	mov    0x8011489c,%eax
801036b9:	40                   	inc    %eax
801036ba:	a3 9c 48 11 80       	mov    %eax,0x8011489c
      release(&log.lock);
801036bf:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801036c6:	e8 a2 22 00 00       	call   8010596d <release>
      break;
801036cb:	eb 02                	jmp    801036cf <begin_op+0x80>
    }
  }
801036cd:	eb 92                	jmp    80103661 <begin_op+0x12>
}
801036cf:	c9                   	leave  
801036d0:	c3                   	ret    

801036d1 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801036d1:	55                   	push   %ebp
801036d2:	89 e5                	mov    %esp,%ebp
801036d4:	83 ec 28             	sub    $0x28,%esp
  int do_commit = 0;
801036d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801036de:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
801036e5:	e8 19 22 00 00       	call   80105903 <acquire>
  log.outstanding -= 1;
801036ea:	a1 9c 48 11 80       	mov    0x8011489c,%eax
801036ef:	48                   	dec    %eax
801036f0:	a3 9c 48 11 80       	mov    %eax,0x8011489c
  if(log.committing)
801036f5:	a1 a0 48 11 80       	mov    0x801148a0,%eax
801036fa:	85 c0                	test   %eax,%eax
801036fc:	74 0c                	je     8010370a <end_op+0x39>
    panic("log.committing");
801036fe:	c7 04 24 59 94 10 80 	movl   $0x80109459,(%esp)
80103705:	e8 4a ce ff ff       	call   80100554 <panic>
  if(log.outstanding == 0){
8010370a:	a1 9c 48 11 80       	mov    0x8011489c,%eax
8010370f:	85 c0                	test   %eax,%eax
80103711:	75 13                	jne    80103726 <end_op+0x55>
    do_commit = 1;
80103713:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010371a:	c7 05 a0 48 11 80 01 	movl   $0x1,0x801148a0
80103721:	00 00 00 
80103724:	eb 0c                	jmp    80103732 <end_op+0x61>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103726:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
8010372d:	e8 51 15 00 00       	call   80104c83 <wakeup>
  }
  release(&log.lock);
80103732:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103739:	e8 2f 22 00 00       	call   8010596d <release>

  if(do_commit){
8010373e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103742:	74 33                	je     80103777 <end_op+0xa6>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103744:	e8 db 00 00 00       	call   80103824 <commit>
    acquire(&log.lock);
80103749:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103750:	e8 ae 21 00 00       	call   80105903 <acquire>
    log.committing = 0;
80103755:	c7 05 a0 48 11 80 00 	movl   $0x0,0x801148a0
8010375c:	00 00 00 
    wakeup(&log);
8010375f:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103766:	e8 18 15 00 00       	call   80104c83 <wakeup>
    release(&log.lock);
8010376b:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
80103772:	e8 f6 21 00 00       	call   8010596d <release>
  }
}
80103777:	c9                   	leave  
80103778:	c3                   	ret    

80103779 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80103779:	55                   	push   %ebp
8010377a:	89 e5                	mov    %esp,%ebp
8010377c:	83 ec 28             	sub    $0x28,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010377f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103786:	e9 89 00 00 00       	jmp    80103814 <write_log+0x9b>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010378b:	8b 15 94 48 11 80    	mov    0x80114894,%edx
80103791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103794:	01 d0                	add    %edx,%eax
80103796:	40                   	inc    %eax
80103797:	89 c2                	mov    %eax,%edx
80103799:	a1 a4 48 11 80       	mov    0x801148a4,%eax
8010379e:	89 54 24 04          	mov    %edx,0x4(%esp)
801037a2:	89 04 24             	mov    %eax,(%esp)
801037a5:	e8 0b ca ff ff       	call   801001b5 <bread>
801037aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801037ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037b0:	83 c0 10             	add    $0x10,%eax
801037b3:	8b 04 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%eax
801037ba:	89 c2                	mov    %eax,%edx
801037bc:	a1 a4 48 11 80       	mov    0x801148a4,%eax
801037c1:	89 54 24 04          	mov    %edx,0x4(%esp)
801037c5:	89 04 24             	mov    %eax,(%esp)
801037c8:	e8 e8 c9 ff ff       	call   801001b5 <bread>
801037cd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801037d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037d3:	8d 50 5c             	lea    0x5c(%eax),%edx
801037d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037d9:	83 c0 5c             	add    $0x5c,%eax
801037dc:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801037e3:	00 
801037e4:	89 54 24 04          	mov    %edx,0x4(%esp)
801037e8:	89 04 24             	mov    %eax,(%esp)
801037eb:	e8 3f 24 00 00       	call   80105c2f <memmove>
    bwrite(to);  // write the log
801037f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801037f3:	89 04 24             	mov    %eax,(%esp)
801037f6:	e8 f1 c9 ff ff       	call   801001ec <bwrite>
    brelse(from);
801037fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801037fe:	89 04 24             	mov    %eax,(%esp)
80103801:	e8 26 ca ff ff       	call   8010022c <brelse>
    brelse(to);
80103806:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103809:	89 04 24             	mov    %eax,(%esp)
8010380c:	e8 1b ca ff ff       	call   8010022c <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103811:	ff 45 f4             	incl   -0xc(%ebp)
80103814:	a1 a8 48 11 80       	mov    0x801148a8,%eax
80103819:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010381c:	0f 8f 69 ff ff ff    	jg     8010378b <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from);
    brelse(to);
  }
}
80103822:	c9                   	leave  
80103823:	c3                   	ret    

80103824 <commit>:

static void
commit()
{
80103824:	55                   	push   %ebp
80103825:	89 e5                	mov    %esp,%ebp
80103827:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010382a:	a1 a8 48 11 80       	mov    0x801148a8,%eax
8010382f:	85 c0                	test   %eax,%eax
80103831:	7e 1e                	jle    80103851 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103833:	e8 41 ff ff ff       	call   80103779 <write_log>
    write_head();    // Write header to disk -- the real commit
80103838:	e8 77 fd ff ff       	call   801035b4 <write_head>
    install_trans(); // Now install writes to home locations
8010383d:	e8 59 fc ff ff       	call   8010349b <install_trans>
    log.lh.n = 0;
80103842:	c7 05 a8 48 11 80 00 	movl   $0x0,0x801148a8
80103849:	00 00 00 
    write_head();    // Erase the transaction from the log
8010384c:	e8 63 fd ff ff       	call   801035b4 <write_head>
  }
}
80103851:	c9                   	leave  
80103852:	c3                   	ret    

80103853 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103853:	55                   	push   %ebp
80103854:	89 e5                	mov    %esp,%ebp
80103856:	83 ec 28             	sub    $0x28,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103859:	a1 a8 48 11 80       	mov    0x801148a8,%eax
8010385e:	83 f8 1d             	cmp    $0x1d,%eax
80103861:	7f 10                	jg     80103873 <log_write+0x20>
80103863:	a1 a8 48 11 80       	mov    0x801148a8,%eax
80103868:	8b 15 98 48 11 80    	mov    0x80114898,%edx
8010386e:	4a                   	dec    %edx
8010386f:	39 d0                	cmp    %edx,%eax
80103871:	7c 0c                	jl     8010387f <log_write+0x2c>
    panic("too big a transaction");
80103873:	c7 04 24 68 94 10 80 	movl   $0x80109468,(%esp)
8010387a:	e8 d5 cc ff ff       	call   80100554 <panic>
  if (log.outstanding < 1)
8010387f:	a1 9c 48 11 80       	mov    0x8011489c,%eax
80103884:	85 c0                	test   %eax,%eax
80103886:	7f 0c                	jg     80103894 <log_write+0x41>
    panic("log_write outside of trans");
80103888:	c7 04 24 7e 94 10 80 	movl   $0x8010947e,(%esp)
8010388f:	e8 c0 cc ff ff       	call   80100554 <panic>

  acquire(&log.lock);
80103894:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
8010389b:	e8 63 20 00 00       	call   80105903 <acquire>
  for (i = 0; i < log.lh.n; i++) {
801038a0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038a7:	eb 1e                	jmp    801038c7 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801038a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801038ac:	83 c0 10             	add    $0x10,%eax
801038af:	8b 04 85 6c 48 11 80 	mov    -0x7feeb794(,%eax,4),%eax
801038b6:	89 c2                	mov    %eax,%edx
801038b8:	8b 45 08             	mov    0x8(%ebp),%eax
801038bb:	8b 40 08             	mov    0x8(%eax),%eax
801038be:	39 c2                	cmp    %eax,%edx
801038c0:	75 02                	jne    801038c4 <log_write+0x71>
      break;
801038c2:	eb 0d                	jmp    801038d1 <log_write+0x7e>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801038c4:	ff 45 f4             	incl   -0xc(%ebp)
801038c7:	a1 a8 48 11 80       	mov    0x801148a8,%eax
801038cc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038cf:	7f d8                	jg     801038a9 <log_write+0x56>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
801038d1:	8b 45 08             	mov    0x8(%ebp),%eax
801038d4:	8b 40 08             	mov    0x8(%eax),%eax
801038d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801038da:	83 c2 10             	add    $0x10,%edx
801038dd:	89 04 95 6c 48 11 80 	mov    %eax,-0x7feeb794(,%edx,4)
  if (i == log.lh.n)
801038e4:	a1 a8 48 11 80       	mov    0x801148a8,%eax
801038e9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801038ec:	75 0b                	jne    801038f9 <log_write+0xa6>
    log.lh.n++;
801038ee:	a1 a8 48 11 80       	mov    0x801148a8,%eax
801038f3:	40                   	inc    %eax
801038f4:	a3 a8 48 11 80       	mov    %eax,0x801148a8
  b->flags |= B_DIRTY; // prevent eviction
801038f9:	8b 45 08             	mov    0x8(%ebp),%eax
801038fc:	8b 00                	mov    (%eax),%eax
801038fe:	83 c8 04             	or     $0x4,%eax
80103901:	89 c2                	mov    %eax,%edx
80103903:	8b 45 08             	mov    0x8(%ebp),%eax
80103906:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
80103908:	c7 04 24 60 48 11 80 	movl   $0x80114860,(%esp)
8010390f:	e8 59 20 00 00       	call   8010596d <release>
}
80103914:	c9                   	leave  
80103915:	c3                   	ret    
	...

80103918 <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
80103918:	55                   	push   %ebp
80103919:	89 e5                	mov    %esp,%ebp
8010391b:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010391e:	8b 55 08             	mov    0x8(%ebp),%edx
80103921:	8b 45 0c             	mov    0xc(%ebp),%eax
80103924:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103927:	f0 87 02             	lock xchg %eax,(%edx)
8010392a:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010392d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103930:	c9                   	leave  
80103931:	c3                   	ret    

80103932 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103932:	55                   	push   %ebp
80103933:	89 e5                	mov    %esp,%ebp
80103935:	83 e4 f0             	and    $0xfffffff0,%esp
80103938:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010393b:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80103942:	80 
80103943:	c7 04 24 48 61 12 80 	movl   $0x80126148,(%esp)
8010394a:	e8 0d f3 ff ff       	call   80102c5c <kinit1>
  kvmalloc();      // kernel page table
8010394f:	e8 b7 4f 00 00       	call   8010890b <kvmalloc>
  mpinit();        // detect other processors
80103954:	e8 c4 03 00 00       	call   80103d1d <mpinit>
  lapicinit();     // interrupt controller
80103959:	e8 4e f6 ff ff       	call   80102fac <lapicinit>
  seginit();       // segment descriptors
8010395e:	e8 90 4a 00 00       	call   801083f3 <seginit>
  picinit();       // disable pic
80103963:	e8 04 05 00 00       	call   80103e6c <picinit>
  ioapicinit();    // another interrupt controller
80103968:	e8 0c f2 ff ff       	call   80102b79 <ioapicinit>
  consoleinit();   // console hardware
8010396d:	e8 45 d2 ff ff       	call   80100bb7 <consoleinit>
  uartinit();      // serial port
80103972:	e8 08 3e 00 00       	call   8010777f <uartinit>
  cinit();         // container table
80103977:	e8 9b 14 00 00       	call   80104e17 <cinit>
  tvinit();        // trap vectors
8010397c:	e8 cb 39 00 00       	call   8010734c <tvinit>
  binit();         // buffer cache
80103981:	e8 ae c6 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103986:	e8 bd d6 ff ff       	call   80101048 <fileinit>
  ideinit();       // disk 
8010398b:	e8 f5 ed ff ff       	call   80102785 <ideinit>
  startothers();   // start other processors
80103990:	e8 83 00 00 00       	call   80103a18 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103995:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
8010399c:	8e 
8010399d:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
801039a4:	e8 eb f2 ff ff       	call   80102c94 <kinit2>
  userinit();      // first user process
801039a9:	e8 c3 15 00 00       	call   80104f71 <userinit>
  mpmain();        // finish this processor's setup
801039ae:	e8 1a 00 00 00       	call   801039cd <mpmain>

801039b3 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801039b3:	55                   	push   %ebp
801039b4:	89 e5                	mov    %esp,%ebp
801039b6:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801039b9:	e8 64 4f 00 00       	call   80108922 <switchkvm>
  seginit();
801039be:	e8 30 4a 00 00       	call   801083f3 <seginit>
  lapicinit();
801039c3:	e8 e4 f5 ff ff       	call   80102fac <lapicinit>
  mpmain();
801039c8:	e8 00 00 00 00       	call   801039cd <mpmain>

801039cd <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801039cd:	55                   	push   %ebp
801039ce:	89 e5                	mov    %esp,%ebp
801039d0:	53                   	push   %ebx
801039d1:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801039d4:	e8 75 13 00 00       	call   80104d4e <cpuid>
801039d9:	89 c3                	mov    %eax,%ebx
801039db:	e8 6e 13 00 00       	call   80104d4e <cpuid>
801039e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801039e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801039e8:	c7 04 24 99 94 10 80 	movl   $0x80109499,(%esp)
801039ef:	e8 cd c9 ff ff       	call   801003c1 <cprintf>
  idtinit();       // load idt register
801039f4:	e8 b0 3a 00 00       	call   801074a9 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
801039f9:	e8 95 13 00 00       	call   80104d93 <mycpu>
801039fe:	05 a0 00 00 00       	add    $0xa0,%eax
80103a03:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80103a0a:	00 
80103a0b:	89 04 24             	mov    %eax,(%esp)
80103a0e:	e8 05 ff ff ff       	call   80103918 <xchg>
  scheduler();     // start running processes
80103a13:	e8 bf 16 00 00       	call   801050d7 <scheduler>

80103a18 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103a18:	55                   	push   %ebp
80103a19:	89 e5                	mov    %esp,%ebp
80103a1b:	83 ec 28             	sub    $0x28,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103a1e:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80103a25:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103a2a:	89 44 24 08          	mov    %eax,0x8(%esp)
80103a2e:	c7 44 24 04 2c c5 10 	movl   $0x8010c52c,0x4(%esp)
80103a35:	80 
80103a36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a39:	89 04 24             	mov    %eax,(%esp)
80103a3c:	e8 ee 21 00 00       	call   80105c2f <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80103a41:	c7 45 f4 60 49 11 80 	movl   $0x80114960,-0xc(%ebp)
80103a48:	eb 75                	jmp    80103abf <startothers+0xa7>
    if(c == mycpu())  // We've started already.
80103a4a:	e8 44 13 00 00       	call   80104d93 <mycpu>
80103a4f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a52:	75 02                	jne    80103a56 <startothers+0x3e>
      continue;
80103a54:	eb 62                	jmp    80103ab8 <startothers+0xa0>

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103a56:	e8 2c f3 ff ff       	call   80102d87 <kalloc>
80103a5b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
80103a5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a61:	83 e8 04             	sub    $0x4,%eax
80103a64:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103a67:	81 c2 00 10 00 00    	add    $0x1000,%edx
80103a6d:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103a6f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a72:	83 e8 08             	sub    $0x8,%eax
80103a75:	c7 00 b3 39 10 80    	movl   $0x801039b3,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103a7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a7e:	8d 50 f4             	lea    -0xc(%eax),%edx
80103a81:	b8 00 b0 10 80       	mov    $0x8010b000,%eax
80103a86:	05 00 00 00 80       	add    $0x80000000,%eax
80103a8b:	89 02                	mov    %eax,(%edx)

    lapicstartap(c->apicid, V2P(code));
80103a8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a90:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80103a96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a99:	8a 00                	mov    (%eax),%al
80103a9b:	0f b6 c0             	movzbl %al,%eax
80103a9e:	89 54 24 04          	mov    %edx,0x4(%esp)
80103aa2:	89 04 24             	mov    %eax,(%esp)
80103aa5:	e8 a7 f6 ff ff       	call   80103151 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103aaa:	90                   	nop
80103aab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aae:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
80103ab4:	85 c0                	test   %eax,%eax
80103ab6:	74 f3                	je     80103aab <startothers+0x93>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103ab8:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
80103abf:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80103ac4:	89 c2                	mov    %eax,%edx
80103ac6:	89 d0                	mov    %edx,%eax
80103ac8:	c1 e0 02             	shl    $0x2,%eax
80103acb:	01 d0                	add    %edx,%eax
80103acd:	01 c0                	add    %eax,%eax
80103acf:	01 d0                	add    %edx,%eax
80103ad1:	c1 e0 04             	shl    $0x4,%eax
80103ad4:	05 60 49 11 80       	add    $0x80114960,%eax
80103ad9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103adc:	0f 87 68 ff ff ff    	ja     80103a4a <startothers+0x32>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103ae2:	c9                   	leave  
80103ae3:	c3                   	ret    

80103ae4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103ae4:	55                   	push   %ebp
80103ae5:	89 e5                	mov    %esp,%ebp
80103ae7:	83 ec 14             	sub    $0x14,%esp
80103aea:	8b 45 08             	mov    0x8(%ebp),%eax
80103aed:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103af1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103af4:	89 c2                	mov    %eax,%edx
80103af6:	ec                   	in     (%dx),%al
80103af7:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103afa:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80103afd:	c9                   	leave  
80103afe:	c3                   	ret    

80103aff <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103aff:	55                   	push   %ebp
80103b00:	89 e5                	mov    %esp,%ebp
80103b02:	83 ec 08             	sub    $0x8,%esp
80103b05:	8b 45 08             	mov    0x8(%ebp),%eax
80103b08:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b0b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103b0f:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103b12:	8a 45 f8             	mov    -0x8(%ebp),%al
80103b15:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b18:	ee                   	out    %al,(%dx)
}
80103b19:	c9                   	leave  
80103b1a:	c3                   	ret    

80103b1b <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80103b1b:	55                   	push   %ebp
80103b1c:	89 e5                	mov    %esp,%ebp
80103b1e:	83 ec 10             	sub    $0x10,%esp
  int i, sum;

  sum = 0;
80103b21:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103b28:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103b2f:	eb 13                	jmp    80103b44 <sum+0x29>
    sum += addr[i];
80103b31:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103b34:	8b 45 08             	mov    0x8(%ebp),%eax
80103b37:	01 d0                	add    %edx,%eax
80103b39:	8a 00                	mov    (%eax),%al
80103b3b:	0f b6 c0             	movzbl %al,%eax
80103b3e:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80103b41:	ff 45 fc             	incl   -0x4(%ebp)
80103b44:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b47:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b4a:	7c e5                	jl     80103b31 <sum+0x16>
    sum += addr[i];
  return sum;
80103b4c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b4f:	c9                   	leave  
80103b50:	c3                   	ret    

80103b51 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b51:	55                   	push   %ebp
80103b52:	89 e5                	mov    %esp,%ebp
80103b54:	83 ec 28             	sub    $0x28,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80103b57:	8b 45 08             	mov    0x8(%ebp),%eax
80103b5a:	05 00 00 00 80       	add    $0x80000000,%eax
80103b5f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b62:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b68:	01 d0                	add    %edx,%eax
80103b6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b6d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b70:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b73:	eb 3f                	jmp    80103bb4 <mpsearch1+0x63>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b75:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103b7c:	00 
80103b7d:	c7 44 24 04 b0 94 10 	movl   $0x801094b0,0x4(%esp)
80103b84:	80 
80103b85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b88:	89 04 24             	mov    %eax,(%esp)
80103b8b:	e8 4d 20 00 00       	call   80105bdd <memcmp>
80103b90:	85 c0                	test   %eax,%eax
80103b92:	75 1c                	jne    80103bb0 <mpsearch1+0x5f>
80103b94:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
80103b9b:	00 
80103b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b9f:	89 04 24             	mov    %eax,(%esp)
80103ba2:	e8 74 ff ff ff       	call   80103b1b <sum>
80103ba7:	84 c0                	test   %al,%al
80103ba9:	75 05                	jne    80103bb0 <mpsearch1+0x5f>
      return (struct mp*)p;
80103bab:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bae:	eb 11                	jmp    80103bc1 <mpsearch1+0x70>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103bb0:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bb7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103bba:	72 b9                	jb     80103b75 <mpsearch1+0x24>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103bbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103bc1:	c9                   	leave  
80103bc2:	c3                   	ret    

80103bc3 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103bc3:	55                   	push   %ebp
80103bc4:	89 e5                	mov    %esp,%ebp
80103bc6:	83 ec 28             	sub    $0x28,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103bc9:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103bd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bd3:	83 c0 0f             	add    $0xf,%eax
80103bd6:	8a 00                	mov    (%eax),%al
80103bd8:	0f b6 c0             	movzbl %al,%eax
80103bdb:	c1 e0 08             	shl    $0x8,%eax
80103bde:	89 c2                	mov    %eax,%edx
80103be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103be3:	83 c0 0e             	add    $0xe,%eax
80103be6:	8a 00                	mov    (%eax),%al
80103be8:	0f b6 c0             	movzbl %al,%eax
80103beb:	09 d0                	or     %edx,%eax
80103bed:	c1 e0 04             	shl    $0x4,%eax
80103bf0:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bf3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bf7:	74 21                	je     80103c1a <mpsearch+0x57>
    if((mp = mpsearch1(p, 1024)))
80103bf9:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103c00:	00 
80103c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c04:	89 04 24             	mov    %eax,(%esp)
80103c07:	e8 45 ff ff ff       	call   80103b51 <mpsearch1>
80103c0c:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c0f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c13:	74 4e                	je     80103c63 <mpsearch+0xa0>
      return mp;
80103c15:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c18:	eb 5d                	jmp    80103c77 <mpsearch+0xb4>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103c1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1d:	83 c0 14             	add    $0x14,%eax
80103c20:	8a 00                	mov    (%eax),%al
80103c22:	0f b6 c0             	movzbl %al,%eax
80103c25:	c1 e0 08             	shl    $0x8,%eax
80103c28:	89 c2                	mov    %eax,%edx
80103c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2d:	83 c0 13             	add    $0x13,%eax
80103c30:	8a 00                	mov    (%eax),%al
80103c32:	0f b6 c0             	movzbl %al,%eax
80103c35:	09 d0                	or     %edx,%eax
80103c37:	c1 e0 0a             	shl    $0xa,%eax
80103c3a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103c3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c40:	2d 00 04 00 00       	sub    $0x400,%eax
80103c45:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
80103c4c:	00 
80103c4d:	89 04 24             	mov    %eax,(%esp)
80103c50:	e8 fc fe ff ff       	call   80103b51 <mpsearch1>
80103c55:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c58:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c5c:	74 05                	je     80103c63 <mpsearch+0xa0>
      return mp;
80103c5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c61:	eb 14                	jmp    80103c77 <mpsearch+0xb4>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c63:	c7 44 24 04 00 00 01 	movl   $0x10000,0x4(%esp)
80103c6a:	00 
80103c6b:	c7 04 24 00 00 0f 00 	movl   $0xf0000,(%esp)
80103c72:	e8 da fe ff ff       	call   80103b51 <mpsearch1>
}
80103c77:	c9                   	leave  
80103c78:	c3                   	ret    

80103c79 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c79:	55                   	push   %ebp
80103c7a:	89 e5                	mov    %esp,%ebp
80103c7c:	83 ec 28             	sub    $0x28,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c7f:	e8 3f ff ff ff       	call   80103bc3 <mpsearch>
80103c84:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c87:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c8b:	74 0a                	je     80103c97 <mpconfig+0x1e>
80103c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c90:	8b 40 04             	mov    0x4(%eax),%eax
80103c93:	85 c0                	test   %eax,%eax
80103c95:	75 07                	jne    80103c9e <mpconfig+0x25>
    return 0;
80103c97:	b8 00 00 00 00       	mov    $0x0,%eax
80103c9c:	eb 7d                	jmp    80103d1b <mpconfig+0xa2>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103c9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ca1:	8b 40 04             	mov    0x4(%eax),%eax
80103ca4:	05 00 00 00 80       	add    $0x80000000,%eax
80103ca9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103cac:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80103cb3:	00 
80103cb4:	c7 44 24 04 b5 94 10 	movl   $0x801094b5,0x4(%esp)
80103cbb:	80 
80103cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cbf:	89 04 24             	mov    %eax,(%esp)
80103cc2:	e8 16 1f 00 00       	call   80105bdd <memcmp>
80103cc7:	85 c0                	test   %eax,%eax
80103cc9:	74 07                	je     80103cd2 <mpconfig+0x59>
    return 0;
80103ccb:	b8 00 00 00 00       	mov    $0x0,%eax
80103cd0:	eb 49                	jmp    80103d1b <mpconfig+0xa2>
  if(conf->version != 1 && conf->version != 4)
80103cd2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cd5:	8a 40 06             	mov    0x6(%eax),%al
80103cd8:	3c 01                	cmp    $0x1,%al
80103cda:	74 11                	je     80103ced <mpconfig+0x74>
80103cdc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cdf:	8a 40 06             	mov    0x6(%eax),%al
80103ce2:	3c 04                	cmp    $0x4,%al
80103ce4:	74 07                	je     80103ced <mpconfig+0x74>
    return 0;
80103ce6:	b8 00 00 00 00       	mov    $0x0,%eax
80103ceb:	eb 2e                	jmp    80103d1b <mpconfig+0xa2>
  if(sum((uchar*)conf, conf->length) != 0)
80103ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf0:	8b 40 04             	mov    0x4(%eax),%eax
80103cf3:	0f b7 c0             	movzwl %ax,%eax
80103cf6:	89 44 24 04          	mov    %eax,0x4(%esp)
80103cfa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cfd:	89 04 24             	mov    %eax,(%esp)
80103d00:	e8 16 fe ff ff       	call   80103b1b <sum>
80103d05:	84 c0                	test   %al,%al
80103d07:	74 07                	je     80103d10 <mpconfig+0x97>
    return 0;
80103d09:	b8 00 00 00 00       	mov    $0x0,%eax
80103d0e:	eb 0b                	jmp    80103d1b <mpconfig+0xa2>
  *pmp = mp;
80103d10:	8b 45 08             	mov    0x8(%ebp),%eax
80103d13:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d16:	89 10                	mov    %edx,(%eax)
  return conf;
80103d18:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103d1b:	c9                   	leave  
80103d1c:	c3                   	ret    

80103d1d <mpinit>:

void
mpinit(void)
{
80103d1d:	55                   	push   %ebp
80103d1e:	89 e5                	mov    %esp,%ebp
80103d20:	83 ec 38             	sub    $0x38,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80103d23:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103d26:	89 04 24             	mov    %eax,(%esp)
80103d29:	e8 4b ff ff ff       	call   80103c79 <mpconfig>
80103d2e:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d31:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103d35:	75 0c                	jne    80103d43 <mpinit+0x26>
    panic("Expect to run on an SMP");
80103d37:	c7 04 24 ba 94 10 80 	movl   $0x801094ba,(%esp)
80103d3e:	e8 11 c8 ff ff       	call   80100554 <panic>
  ismp = 1;
80103d43:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  lapic = (uint*)conf->lapicaddr;
80103d4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d4d:	8b 40 24             	mov    0x24(%eax),%eax
80103d50:	a3 5c 48 11 80       	mov    %eax,0x8011485c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d55:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d58:	83 c0 2c             	add    $0x2c,%eax
80103d5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d61:	8b 40 04             	mov    0x4(%eax),%eax
80103d64:	0f b7 d0             	movzwl %ax,%edx
80103d67:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103d6a:	01 d0                	add    %edx,%eax
80103d6c:	89 45 e8             	mov    %eax,-0x18(%ebp)
80103d6f:	eb 7d                	jmp    80103dee <mpinit+0xd1>
    switch(*p){
80103d71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d74:	8a 00                	mov    (%eax),%al
80103d76:	0f b6 c0             	movzbl %al,%eax
80103d79:	83 f8 04             	cmp    $0x4,%eax
80103d7c:	77 68                	ja     80103de6 <mpinit+0xc9>
80103d7e:	8b 04 85 f4 94 10 80 	mov    -0x7fef6b0c(,%eax,4),%eax
80103d85:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103d87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d8a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(ncpu < NCPU) {
80103d8d:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80103d92:	83 f8 07             	cmp    $0x7,%eax
80103d95:	7f 2c                	jg     80103dc3 <mpinit+0xa6>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80103d97:	8b 15 e0 4e 11 80    	mov    0x80114ee0,%edx
80103d9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103da0:	8a 48 01             	mov    0x1(%eax),%cl
80103da3:	89 d0                	mov    %edx,%eax
80103da5:	c1 e0 02             	shl    $0x2,%eax
80103da8:	01 d0                	add    %edx,%eax
80103daa:	01 c0                	add    %eax,%eax
80103dac:	01 d0                	add    %edx,%eax
80103dae:	c1 e0 04             	shl    $0x4,%eax
80103db1:	05 60 49 11 80       	add    $0x80114960,%eax
80103db6:	88 08                	mov    %cl,(%eax)
        ncpu++;
80103db8:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80103dbd:	40                   	inc    %eax
80103dbe:	a3 e0 4e 11 80       	mov    %eax,0x80114ee0
      }
      p += sizeof(struct mpproc);
80103dc3:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103dc7:	eb 25                	jmp    80103dee <mpinit+0xd1>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103dc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dcc:	89 45 e0             	mov    %eax,-0x20(%ebp)
      ioapicid = ioapic->apicno;
80103dcf:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dd2:	8a 40 01             	mov    0x1(%eax),%al
80103dd5:	a2 40 49 11 80       	mov    %al,0x80114940
      p += sizeof(struct mpioapic);
80103dda:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103dde:	eb 0e                	jmp    80103dee <mpinit+0xd1>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103de0:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103de4:	eb 08                	jmp    80103dee <mpinit+0xd1>
    default:
      ismp = 0;
80103de6:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
      break;
80103ded:	90                   	nop

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103df1:	3b 45 e8             	cmp    -0x18(%ebp),%eax
80103df4:	0f 82 77 ff ff ff    	jb     80103d71 <mpinit+0x54>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103dfa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103dfe:	75 0c                	jne    80103e0c <mpinit+0xef>
    panic("Didn't find a suitable machine");
80103e00:	c7 04 24 d4 94 10 80 	movl   $0x801094d4,(%esp)
80103e07:	e8 48 c7 ff ff       	call   80100554 <panic>

  if(mp->imcrp){
80103e0c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e0f:	8a 40 0c             	mov    0xc(%eax),%al
80103e12:	84 c0                	test   %al,%al
80103e14:	74 36                	je     80103e4c <mpinit+0x12f>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103e16:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
80103e1d:	00 
80103e1e:	c7 04 24 22 00 00 00 	movl   $0x22,(%esp)
80103e25:	e8 d5 fc ff ff       	call   80103aff <outb>
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103e2a:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103e31:	e8 ae fc ff ff       	call   80103ae4 <inb>
80103e36:	83 c8 01             	or     $0x1,%eax
80103e39:	0f b6 c0             	movzbl %al,%eax
80103e3c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103e40:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
80103e47:	e8 b3 fc ff ff       	call   80103aff <outb>
  }
}
80103e4c:	c9                   	leave  
80103e4d:	c3                   	ret    
	...

80103e50 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103e50:	55                   	push   %ebp
80103e51:	89 e5                	mov    %esp,%ebp
80103e53:	83 ec 08             	sub    $0x8,%esp
80103e56:	8b 45 08             	mov    0x8(%ebp),%eax
80103e59:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e5c:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80103e60:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e63:	8a 45 f8             	mov    -0x8(%ebp),%al
80103e66:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103e69:	ee                   	out    %al,(%dx)
}
80103e6a:	c9                   	leave  
80103e6b:	c3                   	ret    

80103e6c <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103e6c:	55                   	push   %ebp
80103e6d:	89 e5                	mov    %esp,%ebp
80103e6f:	83 ec 08             	sub    $0x8,%esp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103e72:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e79:	00 
80103e7a:	c7 04 24 21 00 00 00 	movl   $0x21,(%esp)
80103e81:	e8 ca ff ff ff       	call   80103e50 <outb>
  outb(IO_PIC2+1, 0xFF);
80103e86:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
80103e8d:	00 
80103e8e:	c7 04 24 a1 00 00 00 	movl   $0xa1,(%esp)
80103e95:	e8 b6 ff ff ff       	call   80103e50 <outb>
}
80103e9a:	c9                   	leave  
80103e9b:	c3                   	ret    

80103e9c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103e9c:	55                   	push   %ebp
80103e9d:	89 e5                	mov    %esp,%ebp
80103e9f:	83 ec 28             	sub    $0x28,%esp
  struct pipe *p;

  p = 0;
80103ea2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103ea9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103eac:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103eb5:	8b 10                	mov    (%eax),%edx
80103eb7:	8b 45 08             	mov    0x8(%ebp),%eax
80103eba:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103ebc:	e8 a3 d1 ff ff       	call   80101064 <filealloc>
80103ec1:	8b 55 08             	mov    0x8(%ebp),%edx
80103ec4:	89 02                	mov    %eax,(%edx)
80103ec6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ec9:	8b 00                	mov    (%eax),%eax
80103ecb:	85 c0                	test   %eax,%eax
80103ecd:	0f 84 c8 00 00 00    	je     80103f9b <pipealloc+0xff>
80103ed3:	e8 8c d1 ff ff       	call   80101064 <filealloc>
80103ed8:	8b 55 0c             	mov    0xc(%ebp),%edx
80103edb:	89 02                	mov    %eax,(%edx)
80103edd:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ee0:	8b 00                	mov    (%eax),%eax
80103ee2:	85 c0                	test   %eax,%eax
80103ee4:	0f 84 b1 00 00 00    	je     80103f9b <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103eea:	e8 98 ee ff ff       	call   80102d87 <kalloc>
80103eef:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ef2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103ef6:	75 05                	jne    80103efd <pipealloc+0x61>
    goto bad;
80103ef8:	e9 9e 00 00 00       	jmp    80103f9b <pipealloc+0xff>
  p->readopen = 1;
80103efd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f00:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103f07:	00 00 00 
  p->writeopen = 1;
80103f0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f0d:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103f14:	00 00 00 
  p->nwrite = 0;
80103f17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f1a:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103f21:	00 00 00 
  p->nread = 0;
80103f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f27:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103f2e:	00 00 00 
  initlock(&p->lock, "pipe");
80103f31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f34:	c7 44 24 04 08 95 10 	movl   $0x80109508,0x4(%esp)
80103f3b:	80 
80103f3c:	89 04 24             	mov    %eax,(%esp)
80103f3f:	e8 9e 19 00 00       	call   801058e2 <initlock>
  (*f0)->type = FD_PIPE;
80103f44:	8b 45 08             	mov    0x8(%ebp),%eax
80103f47:	8b 00                	mov    (%eax),%eax
80103f49:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103f4f:	8b 45 08             	mov    0x8(%ebp),%eax
80103f52:	8b 00                	mov    (%eax),%eax
80103f54:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103f58:	8b 45 08             	mov    0x8(%ebp),%eax
80103f5b:	8b 00                	mov    (%eax),%eax
80103f5d:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103f61:	8b 45 08             	mov    0x8(%ebp),%eax
80103f64:	8b 00                	mov    (%eax),%eax
80103f66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f69:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80103f6c:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f6f:	8b 00                	mov    (%eax),%eax
80103f71:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103f77:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f7a:	8b 00                	mov    (%eax),%eax
80103f7c:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103f80:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f83:	8b 00                	mov    (%eax),%eax
80103f85:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80103f89:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f8c:	8b 00                	mov    (%eax),%eax
80103f8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103f91:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103f94:	b8 00 00 00 00       	mov    $0x0,%eax
80103f99:	eb 42                	jmp    80103fdd <pipealloc+0x141>

//PAGEBREAK: 20
 bad:
  if(p)
80103f9b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103f9f:	74 0b                	je     80103fac <pipealloc+0x110>
    kfree((char*)p);
80103fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103fa4:	89 04 24             	mov    %eax,(%esp)
80103fa7:	e8 45 ed ff ff       	call   80102cf1 <kfree>
  if(*f0)
80103fac:	8b 45 08             	mov    0x8(%ebp),%eax
80103faf:	8b 00                	mov    (%eax),%eax
80103fb1:	85 c0                	test   %eax,%eax
80103fb3:	74 0d                	je     80103fc2 <pipealloc+0x126>
    fileclose(*f0);
80103fb5:	8b 45 08             	mov    0x8(%ebp),%eax
80103fb8:	8b 00                	mov    (%eax),%eax
80103fba:	89 04 24             	mov    %eax,(%esp)
80103fbd:	e8 4a d1 ff ff       	call   8010110c <fileclose>
  if(*f1)
80103fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fc5:	8b 00                	mov    (%eax),%eax
80103fc7:	85 c0                	test   %eax,%eax
80103fc9:	74 0d                	je     80103fd8 <pipealloc+0x13c>
    fileclose(*f1);
80103fcb:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fce:	8b 00                	mov    (%eax),%eax
80103fd0:	89 04 24             	mov    %eax,(%esp)
80103fd3:	e8 34 d1 ff ff       	call   8010110c <fileclose>
  return -1;
80103fd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103fdd:	c9                   	leave  
80103fde:	c3                   	ret    

80103fdf <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103fdf:	55                   	push   %ebp
80103fe0:	89 e5                	mov    %esp,%ebp
80103fe2:	83 ec 18             	sub    $0x18,%esp
  acquire(&p->lock);
80103fe5:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe8:	89 04 24             	mov    %eax,(%esp)
80103feb:	e8 13 19 00 00       	call   80105903 <acquire>
  if(writable){
80103ff0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103ff4:	74 1f                	je     80104015 <pipeclose+0x36>
    p->writeopen = 0;
80103ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff9:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
80104000:	00 00 00 
    wakeup(&p->nread);
80104003:	8b 45 08             	mov    0x8(%ebp),%eax
80104006:	05 34 02 00 00       	add    $0x234,%eax
8010400b:	89 04 24             	mov    %eax,(%esp)
8010400e:	e8 70 0c 00 00       	call   80104c83 <wakeup>
80104013:	eb 1d                	jmp    80104032 <pipeclose+0x53>
  } else {
    p->readopen = 0;
80104015:	8b 45 08             	mov    0x8(%ebp),%eax
80104018:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010401f:	00 00 00 
    wakeup(&p->nwrite);
80104022:	8b 45 08             	mov    0x8(%ebp),%eax
80104025:	05 38 02 00 00       	add    $0x238,%eax
8010402a:	89 04 24             	mov    %eax,(%esp)
8010402d:	e8 51 0c 00 00       	call   80104c83 <wakeup>
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104032:	8b 45 08             	mov    0x8(%ebp),%eax
80104035:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010403b:	85 c0                	test   %eax,%eax
8010403d:	75 25                	jne    80104064 <pipeclose+0x85>
8010403f:	8b 45 08             	mov    0x8(%ebp),%eax
80104042:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104048:	85 c0                	test   %eax,%eax
8010404a:	75 18                	jne    80104064 <pipeclose+0x85>
    release(&p->lock);
8010404c:	8b 45 08             	mov    0x8(%ebp),%eax
8010404f:	89 04 24             	mov    %eax,(%esp)
80104052:	e8 16 19 00 00       	call   8010596d <release>
    kfree((char*)p);
80104057:	8b 45 08             	mov    0x8(%ebp),%eax
8010405a:	89 04 24             	mov    %eax,(%esp)
8010405d:	e8 8f ec ff ff       	call   80102cf1 <kfree>
80104062:	eb 0b                	jmp    8010406f <pipeclose+0x90>
  } else
    release(&p->lock);
80104064:	8b 45 08             	mov    0x8(%ebp),%eax
80104067:	89 04 24             	mov    %eax,(%esp)
8010406a:	e8 fe 18 00 00       	call   8010596d <release>
}
8010406f:	c9                   	leave  
80104070:	c3                   	ret    

80104071 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104071:	55                   	push   %ebp
80104072:	89 e5                	mov    %esp,%ebp
80104074:	83 ec 28             	sub    $0x28,%esp
  int i;

  acquire(&p->lock);
80104077:	8b 45 08             	mov    0x8(%ebp),%eax
8010407a:	89 04 24             	mov    %eax,(%esp)
8010407d:	e8 81 18 00 00       	call   80105903 <acquire>
  for(i = 0; i < n; i++){
80104082:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104089:	e9 a3 00 00 00       	jmp    80104131 <pipewrite+0xc0>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010408e:	eb 56                	jmp    801040e6 <pipewrite+0x75>
      if(p->readopen == 0 || myproc()->killed){
80104090:	8b 45 08             	mov    0x8(%ebp),%eax
80104093:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80104099:	85 c0                	test   %eax,%eax
8010409b:	74 0c                	je     801040a9 <pipewrite+0x38>
8010409d:	e8 aa 01 00 00       	call   8010424c <myproc>
801040a2:	8b 40 24             	mov    0x24(%eax),%eax
801040a5:	85 c0                	test   %eax,%eax
801040a7:	74 15                	je     801040be <pipewrite+0x4d>
        release(&p->lock);
801040a9:	8b 45 08             	mov    0x8(%ebp),%eax
801040ac:	89 04 24             	mov    %eax,(%esp)
801040af:	e8 b9 18 00 00       	call   8010596d <release>
        return -1;
801040b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040b9:	e9 9d 00 00 00       	jmp    8010415b <pipewrite+0xea>
      }
      wakeup(&p->nread);
801040be:	8b 45 08             	mov    0x8(%ebp),%eax
801040c1:	05 34 02 00 00       	add    $0x234,%eax
801040c6:	89 04 24             	mov    %eax,(%esp)
801040c9:	e8 b5 0b 00 00       	call   80104c83 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801040ce:	8b 45 08             	mov    0x8(%ebp),%eax
801040d1:	8b 55 08             	mov    0x8(%ebp),%edx
801040d4:	81 c2 38 02 00 00    	add    $0x238,%edx
801040da:	89 44 24 04          	mov    %eax,0x4(%esp)
801040de:	89 14 24             	mov    %edx,(%esp)
801040e1:	e8 82 0a 00 00       	call   80104b68 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801040e6:	8b 45 08             	mov    0x8(%ebp),%eax
801040e9:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801040ef:	8b 45 08             	mov    0x8(%ebp),%eax
801040f2:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801040f8:	05 00 02 00 00       	add    $0x200,%eax
801040fd:	39 c2                	cmp    %eax,%edx
801040ff:	74 8f                	je     80104090 <pipewrite+0x1f>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80104101:	8b 45 08             	mov    0x8(%ebp),%eax
80104104:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010410a:	8d 48 01             	lea    0x1(%eax),%ecx
8010410d:	8b 55 08             	mov    0x8(%ebp),%edx
80104110:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104116:	25 ff 01 00 00       	and    $0x1ff,%eax
8010411b:	89 c1                	mov    %eax,%ecx
8010411d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104120:	8b 45 0c             	mov    0xc(%ebp),%eax
80104123:	01 d0                	add    %edx,%eax
80104125:	8a 10                	mov    (%eax),%dl
80104127:	8b 45 08             	mov    0x8(%ebp),%eax
8010412a:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
8010412e:	ff 45 f4             	incl   -0xc(%ebp)
80104131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104134:	3b 45 10             	cmp    0x10(%ebp),%eax
80104137:	0f 8c 51 ff ff ff    	jl     8010408e <pipewrite+0x1d>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
8010413d:	8b 45 08             	mov    0x8(%ebp),%eax
80104140:	05 34 02 00 00       	add    $0x234,%eax
80104145:	89 04 24             	mov    %eax,(%esp)
80104148:	e8 36 0b 00 00       	call   80104c83 <wakeup>
  release(&p->lock);
8010414d:	8b 45 08             	mov    0x8(%ebp),%eax
80104150:	89 04 24             	mov    %eax,(%esp)
80104153:	e8 15 18 00 00       	call   8010596d <release>
  return n;
80104158:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010415b:	c9                   	leave  
8010415c:	c3                   	ret    

8010415d <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010415d:	55                   	push   %ebp
8010415e:	89 e5                	mov    %esp,%ebp
80104160:	53                   	push   %ebx
80104161:	83 ec 24             	sub    $0x24,%esp
  int i;

  acquire(&p->lock);
80104164:	8b 45 08             	mov    0x8(%ebp),%eax
80104167:	89 04 24             	mov    %eax,(%esp)
8010416a:	e8 94 17 00 00       	call   80105903 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010416f:	eb 39                	jmp    801041aa <piperead+0x4d>
    if(myproc()->killed){
80104171:	e8 d6 00 00 00       	call   8010424c <myproc>
80104176:	8b 40 24             	mov    0x24(%eax),%eax
80104179:	85 c0                	test   %eax,%eax
8010417b:	74 15                	je     80104192 <piperead+0x35>
      release(&p->lock);
8010417d:	8b 45 08             	mov    0x8(%ebp),%eax
80104180:	89 04 24             	mov    %eax,(%esp)
80104183:	e8 e5 17 00 00       	call   8010596d <release>
      return -1;
80104188:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010418d:	e9 b3 00 00 00       	jmp    80104245 <piperead+0xe8>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80104192:	8b 45 08             	mov    0x8(%ebp),%eax
80104195:	8b 55 08             	mov    0x8(%ebp),%edx
80104198:	81 c2 34 02 00 00    	add    $0x234,%edx
8010419e:	89 44 24 04          	mov    %eax,0x4(%esp)
801041a2:	89 14 24             	mov    %edx,(%esp)
801041a5:	e8 be 09 00 00       	call   80104b68 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801041aa:	8b 45 08             	mov    0x8(%ebp),%eax
801041ad:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801041b3:	8b 45 08             	mov    0x8(%ebp),%eax
801041b6:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041bc:	39 c2                	cmp    %eax,%edx
801041be:	75 0d                	jne    801041cd <piperead+0x70>
801041c0:	8b 45 08             	mov    0x8(%ebp),%eax
801041c3:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801041c9:	85 c0                	test   %eax,%eax
801041cb:	75 a4                	jne    80104171 <piperead+0x14>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801041cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041d4:	eb 49                	jmp    8010421f <piperead+0xc2>
    if(p->nread == p->nwrite)
801041d6:	8b 45 08             	mov    0x8(%ebp),%eax
801041d9:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801041df:	8b 45 08             	mov    0x8(%ebp),%eax
801041e2:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801041e8:	39 c2                	cmp    %eax,%edx
801041ea:	75 02                	jne    801041ee <piperead+0x91>
      break;
801041ec:	eb 39                	jmp    80104227 <piperead+0xca>
    addr[i] = p->data[p->nread++ % PIPESIZE];
801041ee:	8b 55 f4             	mov    -0xc(%ebp),%edx
801041f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801041f4:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801041f7:	8b 45 08             	mov    0x8(%ebp),%eax
801041fa:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104200:	8d 48 01             	lea    0x1(%eax),%ecx
80104203:	8b 55 08             	mov    0x8(%ebp),%edx
80104206:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
8010420c:	25 ff 01 00 00       	and    $0x1ff,%eax
80104211:	89 c2                	mov    %eax,%edx
80104213:	8b 45 08             	mov    0x8(%ebp),%eax
80104216:	8a 44 10 34          	mov    0x34(%eax,%edx,1),%al
8010421a:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010421c:	ff 45 f4             	incl   -0xc(%ebp)
8010421f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104222:	3b 45 10             	cmp    0x10(%ebp),%eax
80104225:	7c af                	jl     801041d6 <piperead+0x79>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104227:	8b 45 08             	mov    0x8(%ebp),%eax
8010422a:	05 38 02 00 00       	add    $0x238,%eax
8010422f:	89 04 24             	mov    %eax,(%esp)
80104232:	e8 4c 0a 00 00       	call   80104c83 <wakeup>
  release(&p->lock);
80104237:	8b 45 08             	mov    0x8(%ebp),%eax
8010423a:	89 04 24             	mov    %eax,(%esp)
8010423d:	e8 2b 17 00 00       	call   8010596d <release>
  return i;
80104242:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104245:	83 c4 24             	add    $0x24,%esp
80104248:	5b                   	pop    %ebx
80104249:	5d                   	pop    %ebp
8010424a:	c3                   	ret    
	...

8010424c <myproc>:
static void wakeup1(void *chan);

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
8010424c:	55                   	push   %ebp
8010424d:	89 e5                	mov    %esp,%ebp
8010424f:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80104252:	e8 0b 18 00 00       	call   80105a62 <pushcli>
  c = mycpu();
80104257:	e8 37 0b 00 00       	call   80104d93 <mycpu>
8010425c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
8010425f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104262:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104268:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
8010426b:	e8 3c 18 00 00       	call   80105aac <popcli>
  return p;
80104270:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80104273:	c9                   	leave  
80104274:	c3                   	ret    

80104275 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
struct proc*
allocproc(struct cont *parentcont)
{
80104275:	55                   	push   %ebp
80104276:	89 e5                	mov    %esp,%ebp
80104278:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  char *sp;
  struct proc *ptable;
  int nproc;

  acquirectable();
8010427b:	e8 c7 0b 00 00       	call   80104e47 <acquirectable>

  ptable = parentcont->ptable;
80104280:	8b 45 08             	mov    0x8(%ebp),%eax
80104283:	8b 40 28             	mov    0x28(%eax),%eax
80104286:	89 45 f0             	mov    %eax,-0x10(%ebp)
  nproc = parentcont->mproc;
80104289:	8b 45 08             	mov    0x8(%ebp),%eax
8010428c:	8b 40 08             	mov    0x8(%eax),%eax
8010428f:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for(p = ptable; p < &ptable[nproc]; p++) 
80104292:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104295:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104298:	eb 4c                	jmp    801042e6 <allocproc+0x71>
    if(p->state == UNUSED)
8010429a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010429d:	8b 40 0c             	mov    0xc(%eax),%eax
801042a0:	85 c0                	test   %eax,%eax
801042a2:	75 3b                	jne    801042df <allocproc+0x6a>
      goto found;  
801042a4:	90                   	nop

  releasectable();
  return 0;

found:
  p->state = EMBRYO;
801042a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042a8:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;  
801042af:	a1 00 c0 10 80       	mov    0x8010c000,%eax
801042b4:	8d 50 01             	lea    0x1(%eax),%edx
801042b7:	89 15 00 c0 10 80    	mov    %edx,0x8010c000
801042bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042c0:	89 42 10             	mov    %eax,0x10(%edx)

  releasectable();  
801042c3:	e8 93 0b 00 00       	call   80104e5b <releasectable>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801042c8:	e8 ba ea ff ff       	call   80102d87 <kalloc>
801042cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042d0:	89 42 08             	mov    %eax,0x8(%edx)
801042d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042d6:	8b 40 08             	mov    0x8(%eax),%eax
801042d9:	85 c0                	test   %eax,%eax
801042db:	75 40                	jne    8010431d <allocproc+0xa8>
801042dd:	eb 2d                	jmp    8010430c <allocproc+0x97>
  acquirectable();

  ptable = parentcont->ptable;
  nproc = parentcont->mproc;

  for(p = ptable; p < &ptable[nproc]; p++) 
801042df:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
801042e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801042e9:	c1 e0 02             	shl    $0x2,%eax
801042ec:	89 c2                	mov    %eax,%edx
801042ee:	c1 e2 05             	shl    $0x5,%edx
801042f1:	01 c2                	add    %eax,%edx
801042f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801042f6:	01 d0                	add    %edx,%eax
801042f8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801042fb:	77 9d                	ja     8010429a <allocproc+0x25>
    if(p->state == UNUSED)
      goto found;  

  releasectable();
801042fd:	e8 59 0b 00 00       	call   80104e5b <releasectable>
  return 0;
80104302:	b8 00 00 00 00       	mov    $0x0,%eax
80104307:	e9 8c 00 00 00       	jmp    80104398 <allocproc+0x123>

  releasectable();  

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
8010430c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010430f:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104316:	b8 00 00 00 00       	mov    $0x0,%eax
8010431b:	eb 7b                	jmp    80104398 <allocproc+0x123>
  }
  sp = p->kstack + KSTACKSIZE;
8010431d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104320:	8b 40 08             	mov    0x8(%eax),%eax
80104323:	05 00 10 00 00       	add    $0x1000,%eax
80104328:	89 45 e8             	mov    %eax,-0x18(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010432b:	83 6d e8 4c          	subl   $0x4c,-0x18(%ebp)
  p->tf = (struct trapframe*)sp;
8010432f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104332:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104335:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104338:	83 6d e8 04          	subl   $0x4,-0x18(%ebp)
  *(uint*)sp = (uint)trapret;
8010433c:	ba 08 73 10 80       	mov    $0x80107308,%edx
80104341:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104344:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80104346:	83 6d e8 14          	subl   $0x14,-0x18(%ebp)
  p->context = (struct context*)sp;
8010434a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104350:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80104353:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104356:	8b 40 1c             	mov    0x1c(%eax),%eax
80104359:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80104360:	00 
80104361:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104368:	00 
80104369:	89 04 24             	mov    %eax,(%esp)
8010436c:	e8 f5 17 00 00       	call   80105b66 <memset>
  p->context->eip = (uint)forkret;
80104371:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104374:	8b 40 1c             	mov    0x1c(%eax),%eax
80104377:	ba 84 4a 10 80       	mov    $0x80104a84,%edx
8010437c:	89 50 10             	mov    %edx,0x10(%eax)

  p->ticks = 0;
8010437f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104382:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
  p->cont = parentcont;
80104389:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010438c:	8b 55 08             	mov    0x8(%ebp),%edx
8010438f:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  return p;
80104395:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104398:	c9                   	leave  
80104399:	c3                   	ret    

8010439a <initprocess>:
// Set up first user process for a given container.
// If this is not the first root process, exec will
// set the sz and pgdir for the initialized process
struct proc*
initprocess(struct cont* parentcont, char* name, int isroot)
{
8010439a:	55                   	push   %ebp
8010439b:	89 e5                	mov    %esp,%ebp
8010439d:	83 ec 28             	sub    $0x28,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc(parentcont);
801043a0:	8b 45 08             	mov    0x8(%ebp),%eax
801043a3:	89 04 24             	mov    %eax,(%esp)
801043a6:	e8 ca fe ff ff       	call   80104275 <allocproc>
801043ab:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if((p->pgdir = setupkvm()) == 0) {
801043ae:	e8 af 44 00 00       	call   80108862 <setupkvm>
801043b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043b6:	89 42 04             	mov    %eax,0x4(%edx)
801043b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043bc:	8b 40 04             	mov    0x4(%eax),%eax
801043bf:	85 c0                	test   %eax,%eax
801043c1:	75 1c                	jne    801043df <initprocess+0x45>
    if (isroot)
801043c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801043c7:	74 0c                	je     801043d5 <initprocess+0x3b>
      panic("userinit: out of memory?");
801043c9:	c7 04 24 10 95 10 80 	movl   $0x80109510,(%esp)
801043d0:	e8 7f c1 ff ff       	call   80100554 <panic>
    else 
      return 0;
801043d5:	b8 00 00 00 00       	mov    $0x0,%eax
801043da:	e9 09 01 00 00       	jmp    801044e8 <initprocess+0x14e>
  }
  
  if (isroot) {
801043df:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801043e3:	0f 84 aa 00 00 00    	je     80104493 <initprocess+0xf9>
    initproc = p;     
801043e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ec:	a3 80 c7 10 80       	mov    %eax,0x8010c780
    inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);      
801043f1:	ba 2c 00 00 00       	mov    $0x2c,%edx
801043f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f9:	8b 40 04             	mov    0x4(%eax),%eax
801043fc:	89 54 24 08          	mov    %edx,0x8(%esp)
80104400:	c7 44 24 04 00 c5 10 	movl   $0x8010c500,0x4(%esp)
80104407:	80 
80104408:	89 04 24             	mov    %eax,(%esp)
8010440b:	e8 b3 46 00 00       	call   80108ac3 <inituvm>
    memset(p->tf, 0, sizeof(*p->tf));
80104410:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104413:	8b 40 18             	mov    0x18(%eax),%eax
80104416:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
8010441d:	00 
8010441e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104425:	00 
80104426:	89 04 24             	mov    %eax,(%esp)
80104429:	e8 38 17 00 00       	call   80105b66 <memset>
    p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010442e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104431:	8b 40 18             	mov    0x18(%eax),%eax
80104434:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
    p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010443a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443d:	8b 40 18             	mov    0x18(%eax),%eax
80104440:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
    p->tf->es = p->tf->ds;
80104446:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104449:	8b 50 18             	mov    0x18(%eax),%edx
8010444c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010444f:	8b 40 18             	mov    0x18(%eax),%eax
80104452:	8b 40 2c             	mov    0x2c(%eax),%eax
80104455:	66 89 42 28          	mov    %ax,0x28(%edx)
    p->tf->ss = p->tf->ds;
80104459:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010445c:	8b 50 18             	mov    0x18(%eax),%edx
8010445f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104462:	8b 40 18             	mov    0x18(%eax),%eax
80104465:	8b 40 2c             	mov    0x2c(%eax),%eax
80104468:	66 89 42 48          	mov    %ax,0x48(%edx)
    p->tf->eflags = FL_IF;
8010446c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010446f:	8b 40 18             	mov    0x18(%eax),%eax
80104472:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
    p->tf->esp = PGSIZE;
80104479:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447c:	8b 40 18             	mov    0x18(%eax),%eax
8010447f:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
    p->tf->eip = 0;  // beginning of initcode.S
80104486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104489:	8b 40 18             	mov    0x18(%eax),%eax
8010448c:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  }
  

  p->sz = PGSIZE;
80104493:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104496:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)

  safestrcpy(p->name, name, sizeof(p->name));
8010449c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010449f:	8d 50 6c             	lea    0x6c(%eax),%edx
801044a2:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801044a9:	00 
801044aa:	8b 45 0c             	mov    0xc(%ebp),%eax
801044ad:	89 44 24 04          	mov    %eax,0x4(%esp)
801044b1:	89 14 24             	mov    %edx,(%esp)
801044b4:	e8 b9 18 00 00       	call   80105d72 <safestrcpy>
  p->cwd = parentcont->rootdir;
801044b9:	8b 45 08             	mov    0x8(%ebp),%eax
801044bc:	8b 50 10             	mov    0x10(%eax),%edx
801044bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c2:	89 50 68             	mov    %edx,0x68(%eax)

  // Set initial process's cont to root
  p->cont = parentcont;
801044c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c8:	8b 55 08             	mov    0x8(%ebp),%edx
801044cb:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquirectable();
801044d1:	e8 71 09 00 00       	call   80104e47 <acquirectable>

  p->state = RUNNABLE;
801044d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044d9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  releasectable();
801044e0:	e8 76 09 00 00       	call   80104e5b <releasectable>

  return p;
801044e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044e8:	c9                   	leave  
801044e9:	c3                   	ret    

801044ea <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801044ea:	55                   	push   %ebp
801044eb:	89 e5                	mov    %esp,%ebp
801044ed:	83 ec 28             	sub    $0x28,%esp
  uint sz;
  struct proc *curproc = myproc();
801044f0:	e8 57 fd ff ff       	call   8010424c <myproc>
801044f5:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
801044f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044fb:	8b 00                	mov    (%eax),%eax
801044fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104500:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104504:	7e 31                	jle    80104537 <growproc+0x4d>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104506:	8b 55 08             	mov    0x8(%ebp),%edx
80104509:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010450c:	01 c2                	add    %eax,%edx
8010450e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104511:	8b 40 04             	mov    0x4(%eax),%eax
80104514:	89 54 24 08          	mov    %edx,0x8(%esp)
80104518:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010451b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010451f:	89 04 24             	mov    %eax,(%esp)
80104522:	e8 07 47 00 00       	call   80108c2e <allocuvm>
80104527:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010452a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010452e:	75 3e                	jne    8010456e <growproc+0x84>
      return -1;
80104530:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104535:	eb 4f                	jmp    80104586 <growproc+0x9c>
  } else if(n < 0){
80104537:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010453b:	79 31                	jns    8010456e <growproc+0x84>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010453d:	8b 55 08             	mov    0x8(%ebp),%edx
80104540:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104543:	01 c2                	add    %eax,%edx
80104545:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104548:	8b 40 04             	mov    0x4(%eax),%eax
8010454b:	89 54 24 08          	mov    %edx,0x8(%esp)
8010454f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104552:	89 54 24 04          	mov    %edx,0x4(%esp)
80104556:	89 04 24             	mov    %eax,(%esp)
80104559:	e8 e6 47 00 00       	call   80108d44 <deallocuvm>
8010455e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104561:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104565:	75 07                	jne    8010456e <growproc+0x84>
      return -1;
80104567:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010456c:	eb 18                	jmp    80104586 <growproc+0x9c>
  }
  curproc->sz = sz;
8010456e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104571:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104574:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80104576:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104579:	89 04 24             	mov    %eax,(%esp)
8010457c:	e8 bb 43 00 00       	call   8010893c <switchuvm>
  return 0;
80104581:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104586:	c9                   	leave  
80104587:	c3                   	ret    

80104588 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104588:	55                   	push   %ebp
80104589:	89 e5                	mov    %esp,%ebp
8010458b:	57                   	push   %edi
8010458c:	56                   	push   %esi
8010458d:	53                   	push   %ebx
8010458e:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80104591:	e8 b6 fc ff ff       	call   8010424c <myproc>
80104596:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc(curproc->cont)) == 0){
80104599:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010459c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801045a2:	89 04 24             	mov    %eax,(%esp)
801045a5:	e8 cb fc ff ff       	call   80104275 <allocproc>
801045aa:	89 45 dc             	mov    %eax,-0x24(%ebp)
801045ad:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
801045b1:	75 0a                	jne    801045bd <fork+0x35>
    return -1;
801045b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045b8:	e9 27 01 00 00       	jmp    801046e4 <fork+0x15c>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801045bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045c0:	8b 10                	mov    (%eax),%edx
801045c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801045c5:	8b 40 04             	mov    0x4(%eax),%eax
801045c8:	89 54 24 04          	mov    %edx,0x4(%esp)
801045cc:	89 04 24             	mov    %eax,(%esp)
801045cf:	e8 10 49 00 00       	call   80108ee4 <copyuvm>
801045d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
801045d7:	89 42 04             	mov    %eax,0x4(%edx)
801045da:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045dd:	8b 40 04             	mov    0x4(%eax),%eax
801045e0:	85 c0                	test   %eax,%eax
801045e2:	75 2c                	jne    80104610 <fork+0x88>
    kfree(np->kstack);
801045e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045e7:	8b 40 08             	mov    0x8(%eax),%eax
801045ea:	89 04 24             	mov    %eax,(%esp)
801045ed:	e8 ff e6 ff ff       	call   80102cf1 <kfree>
    np->kstack = 0;
801045f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045f5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801045fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045ff:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104606:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010460b:	e9 d4 00 00 00       	jmp    801046e4 <fork+0x15c>
  }
  np->sz = curproc->sz;
80104610:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104613:	8b 10                	mov    (%eax),%edx
80104615:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104618:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
8010461a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010461d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104620:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104623:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104626:	8b 50 18             	mov    0x18(%eax),%edx
80104629:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010462c:	8b 40 18             	mov    0x18(%eax),%eax
8010462f:	89 c3                	mov    %eax,%ebx
80104631:	b8 13 00 00 00       	mov    $0x13,%eax
80104636:	89 d7                	mov    %edx,%edi
80104638:	89 de                	mov    %ebx,%esi
8010463a:	89 c1                	mov    %eax,%ecx
8010463c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010463e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104641:	8b 40 18             	mov    0x18(%eax),%eax
80104644:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010464b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104652:	eb 36                	jmp    8010468a <fork+0x102>
    if(curproc->ofile[i])
80104654:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104657:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010465a:	83 c2 08             	add    $0x8,%edx
8010465d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104661:	85 c0                	test   %eax,%eax
80104663:	74 22                	je     80104687 <fork+0xff>
      np->ofile[i] = filedup(curproc->ofile[i]);
80104665:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104668:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010466b:	83 c2 08             	add    $0x8,%edx
8010466e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104672:	89 04 24             	mov    %eax,(%esp)
80104675:	e8 4a ca ff ff       	call   801010c4 <filedup>
8010467a:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010467d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80104680:	83 c1 08             	add    $0x8,%ecx
80104683:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104687:	ff 45 e4             	incl   -0x1c(%ebp)
8010468a:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010468e:	7e c4                	jle    80104654 <fork+0xcc>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
80104690:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104693:	8b 40 68             	mov    0x68(%eax),%eax
80104696:	89 04 24             	mov    %eax,(%esp)
80104699:	e8 56 d3 ff ff       	call   801019f4 <idup>
8010469e:	8b 55 dc             	mov    -0x24(%ebp),%edx
801046a1:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801046a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801046a7:	8d 50 6c             	lea    0x6c(%eax),%edx
801046aa:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046ad:	83 c0 6c             	add    $0x6c,%eax
801046b0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801046b7:	00 
801046b8:	89 54 24 04          	mov    %edx,0x4(%esp)
801046bc:	89 04 24             	mov    %eax,(%esp)
801046bf:	e8 ae 16 00 00       	call   80105d72 <safestrcpy>

  pid = np->pid;
801046c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046c7:	8b 40 10             	mov    0x10(%eax),%eax
801046ca:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquirectable();
801046cd:	e8 75 07 00 00       	call   80104e47 <acquirectable>

  np->state = RUNNABLE;
801046d2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801046d5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  releasectable();
801046dc:	e8 7a 07 00 00       	call   80104e5b <releasectable>

  return pid;
801046e1:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
801046e4:	83 c4 2c             	add    $0x2c,%esp
801046e7:	5b                   	pop    %ebx
801046e8:	5e                   	pop    %esi
801046e9:	5f                   	pop    %edi
801046ea:	5d                   	pop    %ebp
801046eb:	c3                   	ret    

801046ec <cfork>:

// TODO: Delete
struct proc*
cfork(struct cont* parentcont)
{
801046ec:	55                   	push   %ebp
801046ed:	89 e5                	mov    %esp,%ebp
801046ef:	57                   	push   %edi
801046f0:	56                   	push   %esi
801046f1:	53                   	push   %ebx
801046f2:	83 ec 2c             	sub    $0x2c,%esp
  //int i;
  struct proc *np;
  struct proc *curproc = myproc();
801046f5:	e8 52 fb ff ff       	call   8010424c <myproc>
801046fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  // Allocate process.
  if((np = allocproc(parentcont)) == 0){
801046fd:	8b 45 08             	mov    0x8(%ebp),%eax
80104700:	89 04 24             	mov    %eax,(%esp)
80104703:	e8 6d fb ff ff       	call   80104275 <allocproc>
80104708:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010470b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010470f:	75 0a                	jne    8010471b <cfork+0x2f>
    return 0;
80104711:	b8 00 00 00 00       	mov    $0x0,%eax
80104716:	e9 eb 00 00 00       	jmp    80104806 <cfork+0x11a>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010471b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010471e:	8b 10                	mov    (%eax),%edx
80104720:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104723:	8b 40 04             	mov    0x4(%eax),%eax
80104726:	89 54 24 04          	mov    %edx,0x4(%esp)
8010472a:	89 04 24             	mov    %eax,(%esp)
8010472d:	e8 b2 47 00 00       	call   80108ee4 <copyuvm>
80104732:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104735:	89 42 04             	mov    %eax,0x4(%edx)
80104738:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010473b:	8b 40 04             	mov    0x4(%eax),%eax
8010473e:	85 c0                	test   %eax,%eax
80104740:	75 2c                	jne    8010476e <cfork+0x82>
    kfree(np->kstack);
80104742:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104745:	8b 40 08             	mov    0x8(%eax),%eax
80104748:	89 04 24             	mov    %eax,(%esp)
8010474b:	e8 a1 e5 ff ff       	call   80102cf1 <kfree>
    np->kstack = 0;
80104750:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104753:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010475a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010475d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104764:	b8 00 00 00 00       	mov    $0x0,%eax
80104769:	e9 98 00 00 00       	jmp    80104806 <cfork+0x11a>
  }
  np->sz = curproc->sz;
8010476e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104771:	8b 10                	mov    (%eax),%edx
80104773:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104776:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80104778:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010477b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010477e:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80104781:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104784:	8b 50 18             	mov    0x18(%eax),%edx
80104787:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010478a:	8b 40 18             	mov    0x18(%eax),%eax
8010478d:	89 c3                	mov    %eax,%ebx
8010478f:	b8 13 00 00 00       	mov    $0x13,%eax
80104794:	89 d7                	mov    %edx,%edi
80104796:	89 de                	mov    %ebx,%esi
80104798:	89 c1                	mov    %eax,%ecx
8010479a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010479c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010479f:	8b 40 18             	mov    0x18(%eax),%eax
801047a2:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  // If parent cont is the same as curproc
      // for(i = 0; i < NOFILE; i++)
      //   if(curproc->ofile[i])
      //     np->ofile[i] = filedup(curproc->ofile[i]);
      // np->cwd = idup(curproc->cwd);
  np->cwd = parentcont->rootdir;
801047a9:	8b 45 08             	mov    0x8(%ebp),%eax
801047ac:	8b 50 10             	mov    0x10(%eax),%edx
801047af:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b2:	89 50 68             	mov    %edx,0x68(%eax)
  cprintf("cfork new proc container %s\n", (np->cont->name));
801047b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047b8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801047be:	83 c0 18             	add    $0x18,%eax
801047c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801047c5:	c7 04 24 29 95 10 80 	movl   $0x80109529,(%esp)
801047cc:	e8 f0 bb ff ff       	call   801003c1 <cprintf>
  // cprintf("cfork new proc container rootdir is a folder %d\n", (np->cont->rootdir->type == 1));
  // cprintf("cfork new proc cwd is a folder: %d\n", (np->cwd->type == 1));

  //safestrcpy(np->name, curproc->name, sizeof(curproc->name));
  safestrcpy(np->name, "testproc", sizeof("testproc"));
801047d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047d4:	83 c0 6c             	add    $0x6c,%eax
801047d7:	c7 44 24 08 09 00 00 	movl   $0x9,0x8(%esp)
801047de:	00 
801047df:	c7 44 24 04 46 95 10 	movl   $0x80109546,0x4(%esp)
801047e6:	80 
801047e7:	89 04 24             	mov    %eax,(%esp)
801047ea:	e8 83 15 00 00       	call   80105d72 <safestrcpy>

  acquirectable();
801047ef:	e8 53 06 00 00       	call   80104e47 <acquirectable>

  np->state = RUNNABLE;
801047f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047f7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  releasectable();
801047fe:	e8 58 06 00 00       	call   80104e5b <releasectable>

  return np;
80104803:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80104806:	83 c4 2c             	add    $0x2c,%esp
80104809:	5b                   	pop    %ebx
8010480a:	5e                   	pop    %esi
8010480b:	5f                   	pop    %edi
8010480c:	5d                   	pop    %ebp
8010480d:	c3                   	ret    

8010480e <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
8010480e:	55                   	push   %ebp
8010480f:	89 e5                	mov    %esp,%ebp
80104811:	83 ec 38             	sub    $0x38,%esp
  struct proc *curproc = myproc();
80104814:	e8 33 fa ff ff       	call   8010424c <myproc>
80104819:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  struct proc *ptable;
  int fd, nproc;

  if(curproc == initproc)
8010481c:	a1 80 c7 10 80       	mov    0x8010c780,%eax
80104821:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80104824:	75 0c                	jne    80104832 <exit+0x24>
    panic("init exiting");
80104826:	c7 04 24 4f 95 10 80 	movl   $0x8010954f,(%esp)
8010482d:	e8 22 bd ff ff       	call   80100554 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104832:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104839:	eb 3a                	jmp    80104875 <exit+0x67>
    if(curproc->ofile[fd]){
8010483b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010483e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104841:	83 c2 08             	add    $0x8,%edx
80104844:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104848:	85 c0                	test   %eax,%eax
8010484a:	74 26                	je     80104872 <exit+0x64>
      fileclose(curproc->ofile[fd]);
8010484c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010484f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104852:	83 c2 08             	add    $0x8,%edx
80104855:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104859:	89 04 24             	mov    %eax,(%esp)
8010485c:	e8 ab c8 ff ff       	call   8010110c <fileclose>
      curproc->ofile[fd] = 0;
80104861:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104864:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104867:	83 c2 08             	add    $0x8,%edx
8010486a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104871:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104872:	ff 45 f0             	incl   -0x10(%ebp)
80104875:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104879:	7e c0                	jle    8010483b <exit+0x2d>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
8010487b:	e8 cf ed ff ff       	call   8010364f <begin_op>
  iput(curproc->cwd);
80104880:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104883:	8b 40 68             	mov    0x68(%eax),%eax
80104886:	89 04 24             	mov    %eax,(%esp)
80104889:	e8 e6 d2 ff ff       	call   80101b74 <iput>
  end_op();
8010488e:	e8 3e ee ff ff       	call   801036d1 <end_op>
  curproc->cwd = 0;
80104893:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104896:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquirectable();
8010489d:	e8 a5 05 00 00       	call   80104e47 <acquirectable>

  ptable = curproc->cont->ptable;
801048a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801048a5:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801048ab:	8b 40 28             	mov    0x28(%eax),%eax
801048ae:	89 45 e8             	mov    %eax,-0x18(%ebp)
  nproc = curproc->cont->mproc;
801048b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801048b4:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801048ba:	8b 40 08             	mov    0x8(%eax),%eax
801048bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801048c0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801048c3:	8b 40 14             	mov    0x14(%eax),%eax
801048c6:	89 04 24             	mov    %eax,(%esp)
801048c9:	e8 24 03 00 00       	call   80104bf2 <wakeup1>

  // Pass abandoned children to init.
  for(p = ptable; p < &ptable[nproc]; p++){
801048ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
801048d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
801048d4:	eb 36                	jmp    8010490c <exit+0xfe>
    if(p->parent == curproc){
801048d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048d9:	8b 40 14             	mov    0x14(%eax),%eax
801048dc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801048df:	75 24                	jne    80104905 <exit+0xf7>
      p->parent = initproc;
801048e1:	8b 15 80 c7 10 80    	mov    0x8010c780,%edx
801048e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ea:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801048ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048f0:	8b 40 0c             	mov    0xc(%eax),%eax
801048f3:	83 f8 05             	cmp    $0x5,%eax
801048f6:	75 0d                	jne    80104905 <exit+0xf7>
        wakeup1(initproc);
801048f8:	a1 80 c7 10 80       	mov    0x8010c780,%eax
801048fd:	89 04 24             	mov    %eax,(%esp)
80104900:	e8 ed 02 00 00       	call   80104bf2 <wakeup1>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable; p < &ptable[nproc]; p++){
80104905:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
8010490c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010490f:	c1 e0 02             	shl    $0x2,%eax
80104912:	89 c2                	mov    %eax,%edx
80104914:	c1 e2 05             	shl    $0x5,%edx
80104917:	01 c2                	add    %eax,%edx
80104919:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010491c:	01 d0                	add    %edx,%eax
8010491e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104921:	77 b3                	ja     801048d6 <exit+0xc8>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80104923:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104926:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
8010492d:	e8 f5 06 00 00       	call   80105027 <sched>
  panic("zombie exit");
80104932:	c7 04 24 5c 95 10 80 	movl   $0x8010955c,(%esp)
80104939:	e8 16 bc ff ff       	call   80100554 <panic>

8010493e <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
8010493e:	55                   	push   %ebp
8010493f:	89 e5                	mov    %esp,%ebp
80104941:	83 ec 38             	sub    $0x38,%esp
  struct proc *p;
  struct proc *ptable;
  int havekids, pid, nproc;
  struct proc *curproc = myproc();
80104944:	e8 03 f9 ff ff       	call   8010424c <myproc>
80104949:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquirectable();
8010494c:	e8 f6 04 00 00       	call   80104e47 <acquirectable>

  ptable = curproc->cont->ptable;
80104951:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104954:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
8010495a:	8b 40 28             	mov    0x28(%eax),%eax
8010495d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  nproc = curproc->cont->mproc;
80104960:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104963:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104969:	8b 40 08             	mov    0x8(%eax),%eax
8010496c:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
8010496f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable; p < &ptable[nproc]; p++){
80104976:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104979:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010497c:	e9 8e 00 00 00       	jmp    80104a0f <wait+0xd1>
      if(p->parent != curproc)
80104981:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104984:	8b 40 14             	mov    0x14(%eax),%eax
80104987:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010498a:	74 02                	je     8010498e <wait+0x50>
        continue;
8010498c:	eb 7a                	jmp    80104a08 <wait+0xca>
      havekids = 1;
8010498e:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104995:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104998:	8b 40 0c             	mov    0xc(%eax),%eax
8010499b:	83 f8 05             	cmp    $0x5,%eax
8010499e:	75 68                	jne    80104a08 <wait+0xca>
        // Found one.
        pid = p->pid;
801049a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049a3:	8b 40 10             	mov    0x10(%eax),%eax
801049a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
        kfree(p->kstack);
801049a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ac:	8b 40 08             	mov    0x8(%eax),%eax
801049af:	89 04 24             	mov    %eax,(%esp)
801049b2:	e8 3a e3 ff ff       	call   80102cf1 <kfree>
        p->kstack = 0;
801049b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ba:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
801049c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049c4:	8b 40 04             	mov    0x4(%eax),%eax
801049c7:	89 04 24             	mov    %eax,(%esp)
801049ca:	e8 39 44 00 00       	call   80108e08 <freevm>
        p->pid = 0;
801049cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d2:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
801049d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049dc:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
801049e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049e6:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
801049ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ed:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
801049f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049f7:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        releasectable();
801049fe:	e8 58 04 00 00       	call   80104e5b <releasectable>
        return pid;
80104a03:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a06:	eb 57                	jmp    80104a5f <wait+0x121>
  nproc = curproc->cont->mproc;

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable; p < &ptable[nproc]; p++){
80104a08:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104a0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104a12:	c1 e0 02             	shl    $0x2,%eax
80104a15:	89 c2                	mov    %eax,%edx
80104a17:	c1 e2 05             	shl    $0x5,%edx
80104a1a:	01 c2                	add    %eax,%edx
80104a1c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80104a1f:	01 d0                	add    %edx,%eax
80104a21:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104a24:	0f 87 57 ff ff ff    	ja     80104981 <wait+0x43>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
80104a2a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104a2e:	74 0a                	je     80104a3a <wait+0xfc>
80104a30:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a33:	8b 40 24             	mov    0x24(%eax),%eax
80104a36:	85 c0                	test   %eax,%eax
80104a38:	74 0c                	je     80104a46 <wait+0x108>
      releasectable();
80104a3a:	e8 1c 04 00 00       	call   80104e5b <releasectable>
      return -1;
80104a3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a44:	eb 19                	jmp    80104a5f <wait+0x121>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, ctablelock());  //DOC: wait-sleep
80104a46:	e8 24 04 00 00       	call   80104e6f <ctablelock>
80104a4b:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104a52:	89 04 24             	mov    %eax,(%esp)
80104a55:	e8 0e 01 00 00       	call   80104b68 <sleep>
  }
80104a5a:	e9 10 ff ff ff       	jmp    8010496f <wait+0x31>
}
80104a5f:	c9                   	leave  
80104a60:	c3                   	ret    

80104a61 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104a61:	55                   	push   %ebp
80104a62:	89 e5                	mov    %esp,%ebp
80104a64:	83 ec 08             	sub    $0x8,%esp
  acquirectable();  //DOC: yieldlock
80104a67:	e8 db 03 00 00       	call   80104e47 <acquirectable>
  myproc()->state = RUNNABLE;
80104a6c:	e8 db f7 ff ff       	call   8010424c <myproc>
80104a71:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104a78:	e8 aa 05 00 00       	call   80105027 <sched>
  releasectable();
80104a7d:	e8 d9 03 00 00       	call   80104e5b <releasectable>
}
80104a82:	c9                   	leave  
80104a83:	c3                   	ret    

80104a84 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104a84:	55                   	push   %ebp
80104a85:	89 e5                	mov    %esp,%ebp
80104a87:	57                   	push   %edi
80104a88:	56                   	push   %esi
80104a89:	53                   	push   %ebx
80104a8a:	83 ec 2c             	sub    $0x2c,%esp
  static int first = 1;
  // Still holding ctablelock from scheduler.
  releasectable();
80104a8d:	e8 c9 03 00 00       	call   80104e5b <releasectable>

  cprintf("my proc %s\n", myproc()->name);
80104a92:	e8 b5 f7 ff ff       	call   8010424c <myproc>
80104a97:	83 c0 6c             	add    $0x6c,%eax
80104a9a:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a9e:	c7 04 24 68 95 10 80 	movl   $0x80109568,(%esp)
80104aa5:	e8 17 b9 ff ff       	call   801003c1 <cprintf>
  if (myproc()->cont->state == CREADY) {
80104aaa:	e8 9d f7 ff ff       	call   8010424c <myproc>
80104aaf:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104ab5:	8b 40 14             	mov    0x14(%eax),%eax
80104ab8:	83 f8 02             	cmp    $0x2,%eax
80104abb:	75 78                	jne    80104b35 <forkret+0xb1>
    // make runnable and exec current process
    cprintf("%s execing\n", myproc()->name);
80104abd:	e8 8a f7 ff ff       	call   8010424c <myproc>
80104ac2:	83 c0 6c             	add    $0x6c,%eax
80104ac5:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ac9:	c7 04 24 74 95 10 80 	movl   $0x80109574,(%esp)
80104ad0:	e8 ec b8 ff ff       	call   801003c1 <cprintf>
    char *argj[4] = { "echoloop", "100", "ab", 0 };
80104ad5:	8d 55 d8             	lea    -0x28(%ebp),%edx
80104ad8:	bb e4 95 10 80       	mov    $0x801095e4,%ebx
80104add:	b8 04 00 00 00       	mov    $0x4,%eax
80104ae2:	89 d7                	mov    %edx,%edi
80104ae4:	89 de                	mov    %ebx,%esi
80104ae6:	89 c1                	mov    %eax,%ecx
80104ae8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
    cprintf("execing proc %s with argv[1] %s\n", argj[0], argj[1]);   
80104aea:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104aed:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104af0:	89 54 24 08          	mov    %edx,0x8(%esp)
80104af4:	89 44 24 04          	mov    %eax,0x4(%esp)
80104af8:	c7 04 24 80 95 10 80 	movl   $0x80109580,(%esp)
80104aff:	e8 bd b8 ff ff       	call   801003c1 <cprintf>
    if (exec(argj[0], argj) == -1) {
80104b04:	8b 45 d8             	mov    -0x28(%ebp),%eax
80104b07:	8d 55 d8             	lea    -0x28(%ebp),%edx
80104b0a:	89 54 24 04          	mov    %edx,0x4(%esp)
80104b0e:	89 04 24             	mov    %eax,(%esp)
80104b11:	e8 f2 c0 ff ff       	call   80100c08 <exec>
80104b16:	83 f8 ff             	cmp    $0xffffffff,%eax
80104b19:	75 0e                	jne    80104b29 <forkret+0xa5>
      cprintf("exec proc failed\n");
80104b1b:	c7 04 24 a1 95 10 80 	movl   $0x801095a1,(%esp)
80104b22:	e8 9a b8 ff ff       	call   801003c1 <cprintf>
80104b27:	eb 0c                	jmp    80104b35 <forkret+0xb1>
    } else {
      cprintf("exec proc should have worked\n");
80104b29:	c7 04 24 b3 95 10 80 	movl   $0x801095b3,(%esp)
80104b30:	e8 8c b8 ff ff       	call   801003c1 <cprintf>
    }
  }

  if (first) {    
80104b35:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104b3a:	85 c0                	test   %eax,%eax
80104b3c:	74 22                	je     80104b60 <forkret+0xdc>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104b3e:	c7 05 04 c0 10 80 00 	movl   $0x0,0x8010c004
80104b45:	00 00 00 
    iinit(ROOTDEV);
80104b48:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104b4f:	e8 6b cb ff ff       	call   801016bf <iinit>
    initlog(ROOTDEV);
80104b54:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104b5b:	e8 f0 e8 ff ff       	call   80103450 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104b60:	83 c4 2c             	add    $0x2c,%esp
80104b63:	5b                   	pop    %ebx
80104b64:	5e                   	pop    %esi
80104b65:	5f                   	pop    %edi
80104b66:	5d                   	pop    %ebp
80104b67:	c3                   	ret    

80104b68 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104b68:	55                   	push   %ebp
80104b69:	89 e5                	mov    %esp,%ebp
80104b6b:	83 ec 28             	sub    $0x28,%esp
  struct proc *p = myproc();
80104b6e:	e8 d9 f6 ff ff       	call   8010424c <myproc>
80104b73:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
80104b76:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104b7a:	75 0c                	jne    80104b88 <sleep+0x20>
    panic("sleep");
80104b7c:	c7 04 24 f4 95 10 80 	movl   $0x801095f4,(%esp)
80104b83:	e8 cc b9 ff ff       	call   80100554 <panic>

  if(lk == 0)
80104b88:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104b8c:	75 0c                	jne    80104b9a <sleep+0x32>
    panic("sleep without lk");  
80104b8e:	c7 04 24 fa 95 10 80 	movl   $0x801095fa,(%esp)
80104b95:	e8 ba b9 ff ff       	call   80100554 <panic>
  // change p->state and then call sched.
  // Once we hold ctable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ctable.lock locked),
  // so it's okay to release lk.
  if(lk != ctablelock()){  //DOC: sleeplock0
80104b9a:	e8 d0 02 00 00       	call   80104e6f <ctablelock>
80104b9f:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104ba2:	74 10                	je     80104bb4 <sleep+0x4c>
    acquirectable();  //DOC: sleeplock1
80104ba4:	e8 9e 02 00 00       	call   80104e47 <acquirectable>
    release(lk);
80104ba9:	8b 45 0c             	mov    0xc(%ebp),%eax
80104bac:	89 04 24             	mov    %eax,(%esp)
80104baf:	e8 b9 0d 00 00       	call   8010596d <release>
  }
  // Go to sleep.
  p->chan = chan;
80104bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb7:	8b 55 08             	mov    0x8(%ebp),%edx
80104bba:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104bbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc0:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104bc7:	e8 5b 04 00 00       	call   80105027 <sched>

  // Tidy up.
  p->chan = 0;
80104bcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bcf:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != ctablelock()){  //DOC: sleeplock2
80104bd6:	e8 94 02 00 00       	call   80104e6f <ctablelock>
80104bdb:	3b 45 0c             	cmp    0xc(%ebp),%eax
80104bde:	74 10                	je     80104bf0 <sleep+0x88>
    releasectable();
80104be0:	e8 76 02 00 00       	call   80104e5b <releasectable>
    acquire(lk);
80104be5:	8b 45 0c             	mov    0xc(%ebp),%eax
80104be8:	89 04 24             	mov    %eax,(%esp)
80104beb:	e8 13 0d 00 00       	call   80105903 <acquire>
  }
}
80104bf0:	c9                   	leave  
80104bf1:	c3                   	ret    

80104bf2 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ctable lock must be held.
static void
wakeup1(void *chan)
{
80104bf2:	55                   	push   %ebp
80104bf3:	89 e5                	mov    %esp,%ebp
80104bf5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct proc *ptable;
  int nproc;

  // TODO: maybe remove mycont() function then change this to work
  if (myproc() == 0) {
80104bf8:	e8 4f f6 ff ff       	call   8010424c <myproc>
80104bfd:	85 c0                	test   %eax,%eax
80104bff:	75 18                	jne    80104c19 <wakeup1+0x27>
    nproc = mycont()->mproc;
80104c01:	e8 a2 03 00 00       	call   80104fa8 <mycont>
80104c06:	8b 40 08             	mov    0x8(%eax),%eax
80104c09:	89 45 ec             	mov    %eax,-0x14(%ebp)
    ptable = mycont()->ptable;
80104c0c:	e8 97 03 00 00       	call   80104fa8 <mycont>
80104c11:	8b 40 28             	mov    0x28(%eax),%eax
80104c14:	89 45 f0             	mov    %eax,-0x10(%ebp)
80104c17:	eb 22                	jmp    80104c3b <wakeup1+0x49>
  } else {
    nproc = myproc()->cont->mproc;
80104c19:	e8 2e f6 ff ff       	call   8010424c <myproc>
80104c1e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104c24:	8b 40 08             	mov    0x8(%eax),%eax
80104c27:	89 45 ec             	mov    %eax,-0x14(%ebp)
    ptable = myproc()->cont->ptable;
80104c2a:	e8 1d f6 ff ff       	call   8010424c <myproc>
80104c2f:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104c35:	8b 40 28             	mov    0x28(%eax),%eax
80104c38:	89 45 f0             	mov    %eax,-0x10(%ebp)
  }

  for(p = ptable; p < &ptable[nproc]; p++)
80104c3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c41:	eb 27                	jmp    80104c6a <wakeup1+0x78>
    if(p->state == SLEEPING && p->chan == chan) {
80104c43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c46:	8b 40 0c             	mov    0xc(%eax),%eax
80104c49:	83 f8 02             	cmp    $0x2,%eax
80104c4c:	75 15                	jne    80104c63 <wakeup1+0x71>
80104c4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c51:	8b 40 20             	mov    0x20(%eax),%eax
80104c54:	3b 45 08             	cmp    0x8(%ebp),%eax
80104c57:	75 0a                	jne    80104c63 <wakeup1+0x71>
      p->state = RUNNABLE;
80104c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c5c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  } else {
    nproc = myproc()->cont->mproc;
    ptable = myproc()->cont->ptable;
  }

  for(p = ptable; p < &ptable[nproc]; p++)
80104c63:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104c6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c6d:	c1 e0 02             	shl    $0x2,%eax
80104c70:	89 c2                	mov    %eax,%edx
80104c72:	c1 e2 05             	shl    $0x5,%edx
80104c75:	01 c2                	add    %eax,%edx
80104c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c7a:	01 d0                	add    %edx,%eax
80104c7c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104c7f:	77 c2                	ja     80104c43 <wakeup1+0x51>
    if(p->state == SLEEPING && p->chan == chan) {
      p->state = RUNNABLE;
    }
}
80104c81:	c9                   	leave  
80104c82:	c3                   	ret    

80104c83 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104c83:	55                   	push   %ebp
80104c84:	89 e5                	mov    %esp,%ebp
80104c86:	83 ec 18             	sub    $0x18,%esp
  acquirectable();
80104c89:	e8 b9 01 00 00       	call   80104e47 <acquirectable>
  wakeup1(chan);
80104c8e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c91:	89 04 24             	mov    %eax,(%esp)
80104c94:	e8 59 ff ff ff       	call   80104bf2 <wakeup1>
  releasectable();
80104c99:	e8 bd 01 00 00       	call   80104e5b <releasectable>
}
80104c9e:	c9                   	leave  
80104c9f:	c3                   	ret    

80104ca0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104ca0:	55                   	push   %ebp
80104ca1:	89 e5                	mov    %esp,%ebp
80104ca3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct proc *ptable;
  int nproc;

  acquirectable();
80104ca6:	e8 9c 01 00 00       	call   80104e47 <acquirectable>

  ptable = myproc()->cont->ptable;
80104cab:	e8 9c f5 ff ff       	call   8010424c <myproc>
80104cb0:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104cb6:	8b 40 28             	mov    0x28(%eax),%eax
80104cb9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  nproc = myproc()->cont->mproc;
80104cbc:	e8 8b f5 ff ff       	call   8010424c <myproc>
80104cc1:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104cc7:	8b 40 08             	mov    0x8(%eax),%eax
80104cca:	89 45 ec             	mov    %eax,-0x14(%ebp)

  for(p = ptable; p < &ptable[nproc]; p++){
80104ccd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104cd3:	eb 3d                	jmp    80104d12 <kill+0x72>
    if(p->pid == pid){
80104cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cd8:	8b 40 10             	mov    0x10(%eax),%eax
80104cdb:	3b 45 08             	cmp    0x8(%ebp),%eax
80104cde:	75 2b                	jne    80104d0b <kill+0x6b>
      p->killed = 1;
80104ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce3:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104cea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ced:	8b 40 0c             	mov    0xc(%eax),%eax
80104cf0:	83 f8 02             	cmp    $0x2,%eax
80104cf3:	75 0a                	jne    80104cff <kill+0x5f>
        p->state = RUNNABLE;
80104cf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      releasectable();
80104cff:	e8 57 01 00 00       	call   80104e5b <releasectable>
      return 0;
80104d04:	b8 00 00 00 00       	mov    $0x0,%eax
80104d09:	eb 28                	jmp    80104d33 <kill+0x93>
  acquirectable();

  ptable = myproc()->cont->ptable;
  nproc = myproc()->cont->mproc;

  for(p = ptable; p < &ptable[nproc]; p++){
80104d0b:	81 45 f4 84 00 00 00 	addl   $0x84,-0xc(%ebp)
80104d12:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d15:	c1 e0 02             	shl    $0x2,%eax
80104d18:	89 c2                	mov    %eax,%edx
80104d1a:	c1 e2 05             	shl    $0x5,%edx
80104d1d:	01 c2                	add    %eax,%edx
80104d1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d22:	01 d0                	add    %edx,%eax
80104d24:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104d27:	77 ac                	ja     80104cd5 <kill+0x35>
        p->state = RUNNABLE;
      releasectable();
      return 0;
    }
  }
  releasectable();
80104d29:	e8 2d 01 00 00       	call   80104e5b <releasectable>
  return -1;
80104d2e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d33:	c9                   	leave  
80104d34:	c3                   	ret    
80104d35:	00 00                	add    %al,(%eax)
	...

80104d38 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104d38:	55                   	push   %ebp
80104d39:	89 e5                	mov    %esp,%ebp
80104d3b:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104d3e:	9c                   	pushf  
80104d3f:	58                   	pop    %eax
80104d40:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80104d43:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104d46:	c9                   	leave  
80104d47:	c3                   	ret    

80104d48 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104d48:	55                   	push   %ebp
80104d49:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104d4b:	fb                   	sti    
}
80104d4c:	5d                   	pop    %ebp
80104d4d:	c3                   	ret    

80104d4e <cpuid>:

// TODO: Check to make sure ALL ctable calls have a lock

// Must be called with interrupts disabled
int
cpuid() {
80104d4e:	55                   	push   %ebp
80104d4f:	89 e5                	mov    %esp,%ebp
80104d51:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80104d54:	e8 3a 00 00 00       	call   80104d93 <mycpu>
80104d59:	89 c2                	mov    %eax,%edx
80104d5b:	b8 60 49 11 80       	mov    $0x80114960,%eax
80104d60:	29 c2                	sub    %eax,%edx
80104d62:	89 d0                	mov    %edx,%eax
80104d64:	c1 f8 04             	sar    $0x4,%eax
80104d67:	89 c1                	mov    %eax,%ecx
80104d69:	89 ca                	mov    %ecx,%edx
80104d6b:	c1 e2 03             	shl    $0x3,%edx
80104d6e:	01 ca                	add    %ecx,%edx
80104d70:	89 d0                	mov    %edx,%eax
80104d72:	c1 e0 05             	shl    $0x5,%eax
80104d75:	29 d0                	sub    %edx,%eax
80104d77:	c1 e0 02             	shl    $0x2,%eax
80104d7a:	01 c8                	add    %ecx,%eax
80104d7c:	c1 e0 03             	shl    $0x3,%eax
80104d7f:	01 c8                	add    %ecx,%eax
80104d81:	89 c2                	mov    %eax,%edx
80104d83:	c1 e2 0f             	shl    $0xf,%edx
80104d86:	29 c2                	sub    %eax,%edx
80104d88:	c1 e2 02             	shl    $0x2,%edx
80104d8b:	01 ca                	add    %ecx,%edx
80104d8d:	89 d0                	mov    %edx,%eax
80104d8f:	f7 d8                	neg    %eax
}
80104d91:	c9                   	leave  
80104d92:	c3                   	ret    

80104d93 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80104d93:	55                   	push   %ebp
80104d94:	89 e5                	mov    %esp,%ebp
80104d96:	83 ec 28             	sub    $0x28,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF)
80104d99:	e8 9a ff ff ff       	call   80104d38 <readeflags>
80104d9e:	25 00 02 00 00       	and    $0x200,%eax
80104da3:	85 c0                	test   %eax,%eax
80104da5:	74 0c                	je     80104db3 <mycpu+0x20>
    panic("mycpu called with interrupts enabled\n");
80104da7:	c7 04 24 0c 96 10 80 	movl   $0x8010960c,(%esp)
80104dae:	e8 a1 b7 ff ff       	call   80100554 <panic>
  
  apicid = lapicid();
80104db3:	e8 4d e3 ff ff       	call   80103105 <lapicid>
80104db8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104dbb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104dc2:	eb 3b                	jmp    80104dff <mycpu+0x6c>
    if (cpus[i].apicid == apicid)
80104dc4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104dc7:	89 d0                	mov    %edx,%eax
80104dc9:	c1 e0 02             	shl    $0x2,%eax
80104dcc:	01 d0                	add    %edx,%eax
80104dce:	01 c0                	add    %eax,%eax
80104dd0:	01 d0                	add    %edx,%eax
80104dd2:	c1 e0 04             	shl    $0x4,%eax
80104dd5:	05 60 49 11 80       	add    $0x80114960,%eax
80104dda:	8a 00                	mov    (%eax),%al
80104ddc:	0f b6 c0             	movzbl %al,%eax
80104ddf:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80104de2:	75 18                	jne    80104dfc <mycpu+0x69>
      return &cpus[i];
80104de4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104de7:	89 d0                	mov    %edx,%eax
80104de9:	c1 e0 02             	shl    $0x2,%eax
80104dec:	01 d0                	add    %edx,%eax
80104dee:	01 c0                	add    %eax,%eax
80104df0:	01 d0                	add    %edx,%eax
80104df2:	c1 e0 04             	shl    $0x4,%eax
80104df5:	05 60 49 11 80       	add    $0x80114960,%eax
80104dfa:	eb 19                	jmp    80104e15 <mycpu+0x82>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80104dfc:	ff 45 f4             	incl   -0xc(%ebp)
80104dff:	a1 e0 4e 11 80       	mov    0x80114ee0,%eax
80104e04:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80104e07:	7c bb                	jl     80104dc4 <mycpu+0x31>
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
80104e09:	c7 04 24 32 96 10 80 	movl   $0x80109632,(%esp)
80104e10:	e8 3f b7 ff ff       	call   80100554 <panic>
}
80104e15:	c9                   	leave  
80104e16:	c3                   	ret    

80104e17 <cinit>:

int nextcid = 1;

void
cinit(void)
{
80104e17:	55                   	push   %ebp
80104e18:	89 e5                	mov    %esp,%ebp
80104e1a:	83 ec 18             	sub    $0x18,%esp
  initlock(&ctable.lock, "ctable");
80104e1d:	c7 44 24 04 42 96 10 	movl   $0x80109642,0x4(%esp)
80104e24:	80 
80104e25:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104e2c:	e8 b1 0a 00 00       	call   801058e2 <initlock>
  initlock(&ptable.lock, "ptable");
80104e31:	c7 44 24 04 49 96 10 	movl   $0x80109649,0x4(%esp)
80104e38:	80 
80104e39:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
80104e40:	e8 9d 0a 00 00       	call   801058e2 <initlock>
}
80104e45:	c9                   	leave  
80104e46:	c3                   	ret    

80104e47 <acquirectable>:

void
acquirectable(void) 
{
80104e47:	55                   	push   %ebp
80104e48:	89 e5                	mov    %esp,%ebp
80104e4a:	83 ec 18             	sub    $0x18,%esp
	acquire(&ptable.lock);
80104e4d:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
80104e54:	e8 aa 0a 00 00       	call   80105903 <acquire>
}
80104e59:	c9                   	leave  
80104e5a:	c3                   	ret    

80104e5b <releasectable>:
// TODO: refactor name of ctablelock to ptable
// TODO: replace these aqcuires and releases with normal aqcuire and release using ctablelock()
void 
releasectable(void)
{
80104e5b:	55                   	push   %ebp
80104e5c:	89 e5                	mov    %esp,%ebp
80104e5e:	83 ec 18             	sub    $0x18,%esp
	release(&ptable.lock);
80104e61:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
80104e68:	e8 00 0b 00 00       	call   8010596d <release>
	//cprintf("\t\t Released ctable\n");
}
80104e6d:	c9                   	leave  
80104e6e:	c3                   	ret    

80104e6f <ctablelock>:

struct spinlock*
ctablelock(void)
{
80104e6f:	55                   	push   %ebp
80104e70:	89 e5                	mov    %esp,%ebp
	return &ptable.lock;
80104e72:	b8 c0 50 11 80       	mov    $0x801150c0,%eax
}
80104e77:	5d                   	pop    %ebp
80104e78:	c3                   	ret    

80104e79 <initcontainer>:

struct cont*
initcontainer(void)
{
80104e79:	55                   	push   %ebp
80104e7a:	89 e5                	mov    %esp,%ebp
80104e7c:	83 ec 38             	sub    $0x38,%esp
	int i,
		mproc = MAX_CONT_PROC,
80104e7f:	c7 45 f0 40 00 00 00 	movl   $0x40,-0x10(%ebp)
		msz   = MAX_CONT_MEM,
80104e86:	c7 45 ec 00 10 00 00 	movl   $0x1000,-0x14(%ebp)
		mdsk  = MAX_CONT_DSK;
80104e8d:	c7 45 e8 00 10 00 00 	movl   $0x1000,-0x18(%ebp)
	struct cont *c;

	if ((c = alloccont()) == 0) {
80104e94:	e8 19 01 00 00       	call   80104fb2 <alloccont>
80104e99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80104e9c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80104ea0:	75 0c                	jne    80104eae <initcontainer+0x35>
		panic("Can't alloc init container.");
80104ea2:	c7 04 24 50 96 10 80 	movl   $0x80109650,(%esp)
80104ea9:	e8 a6 b6 ff ff       	call   80100554 <panic>
	}

	currcont = c;	
80104eae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104eb1:	a3 b4 50 11 80       	mov    %eax,0x801150b4

	acquire(&ctable.lock);
80104eb6:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104ebd:	e8 41 0a 00 00       	call   80105903 <acquire>
	c->mproc = mproc;
80104ec2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ec5:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104ec8:	89 50 08             	mov    %edx,0x8(%eax)
	c->msz = msz;
80104ecb:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104ece:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ed1:	89 10                	mov    %edx,(%eax)
	c->mdsk = mdsk;	
80104ed3:	8b 55 e8             	mov    -0x18(%ebp),%edx
80104ed6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104ed9:	89 50 04             	mov    %edx,0x4(%eax)
	c->state = CRUNNABLE;	
80104edc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104edf:	c7 40 14 03 00 00 00 	movl   $0x3,0x14(%eax)
	c->rootdir = namei("/");
80104ee6:	c7 04 24 6c 96 10 80 	movl   $0x8010966c,(%esp)
80104eed:	e8 8a d7 ff ff       	call   8010267c <namei>
80104ef2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104ef5:	89 42 10             	mov    %eax,0x10(%edx)
	safestrcpy(c->name, "initcont", sizeof(c->name));	
80104ef8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104efb:	83 c0 18             	add    $0x18,%eax
80104efe:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80104f05:	00 
80104f06:	c7 44 24 04 6e 96 10 	movl   $0x8010966e,0x4(%esp)
80104f0d:	80 
80104f0e:	89 04 24             	mov    %eax,(%esp)
80104f11:	e8 5c 0e 00 00       	call   80105d72 <safestrcpy>

	// Init pointers to each container's process tables
	for (i = 0; i < NCONT; i++)
80104f16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104f1d:	eb 2f                	jmp    80104f4e <initcontainer+0xd5>
		ctable.cont[i].ptable = ptable.proc[i];
80104f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f22:	c1 e0 08             	shl    $0x8,%eax
80104f25:	89 c2                	mov    %eax,%edx
80104f27:	c1 e2 05             	shl    $0x5,%edx
80104f2a:	01 d0                	add    %edx,%eax
80104f2c:	83 c0 30             	add    $0x30,%eax
80104f2f:	05 c0 50 11 80       	add    $0x801150c0,%eax
80104f34:	8d 48 04             	lea    0x4(%eax),%ecx
80104f37:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104f3a:	89 d0                	mov    %edx,%eax
80104f3c:	01 c0                	add    %eax,%eax
80104f3e:	01 d0                	add    %edx,%eax
80104f40:	c1 e0 04             	shl    $0x4,%eax
80104f43:	05 50 4f 11 80       	add    $0x80114f50,%eax
80104f48:	89 48 0c             	mov    %ecx,0xc(%eax)
	c->state = CRUNNABLE;	
	c->rootdir = namei("/");
	safestrcpy(c->name, "initcont", sizeof(c->name));	

	// Init pointers to each container's process tables
	for (i = 0; i < NCONT; i++)
80104f4b:	ff 45 f4             	incl   -0xc(%ebp)
80104f4e:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80104f52:	7e cb                	jle    80104f1f <initcontainer+0xa6>
		ctable.cont[i].ptable = ptable.proc[i];

	release(&ctable.lock);	
80104f54:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104f5b:	e8 0d 0a 00 00       	call   8010596d <release>

	cprintf("Init container\n");
80104f60:	c7 04 24 77 96 10 80 	movl   $0x80109677,(%esp)
80104f67:	e8 55 b4 ff ff       	call   801003c1 <cprintf>

	return c;
80104f6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80104f6f:	c9                   	leave  
80104f70:	c3                   	ret    

80104f71 <userinit>:

// Set up first user container and process.
void
userinit(void)
{
80104f71:	55                   	push   %ebp
80104f72:	89 e5                	mov    %esp,%ebp
80104f74:	83 ec 28             	sub    $0x28,%esp
	cprintf("userinit\n");
80104f77:	c7 04 24 87 96 10 80 	movl   $0x80109687,(%esp)
80104f7e:	e8 3e b4 ff ff       	call   801003c1 <cprintf>
	struct cont* root;
  	root = initcontainer();
80104f83:	e8 f1 fe ff ff       	call   80104e79 <initcontainer>
80104f88:	89 45 f4             	mov    %eax,-0xc(%ebp)
  	initprocess(root, "initproc", 1);    	
80104f8b:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80104f92:	00 
80104f93:	c7 44 24 04 91 96 10 	movl   $0x80109691,0x4(%esp)
80104f9a:	80 
80104f9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f9e:	89 04 24             	mov    %eax,(%esp)
80104fa1:	e8 f4 f3 ff ff       	call   8010439a <initprocess>
}
80104fa6:	c9                   	leave  
80104fa7:	c3                   	ret    

80104fa8 <mycont>:

//TODO: REMOVE!!
struct cont*
mycont(void) {
80104fa8:	55                   	push   %ebp
80104fa9:	89 e5                	mov    %esp,%ebp
	return currcont;
80104fab:	a1 b4 50 11 80       	mov    0x801150b4,%eax
}
80104fb0:	5d                   	pop    %ebp
80104fb1:	c3                   	ret    

80104fb2 <alloccont>:
// Look in the container table for an CUNUSED cont.
// If found, change state to CEMBRYO
// Otherwise return 0.
static struct cont*
alloccont(void)
{
80104fb2:	55                   	push   %ebp
80104fb3:	89 e5                	mov    %esp,%ebp
80104fb5:	83 ec 28             	sub    $0x28,%esp
	struct cont *c;

	acquire(&ctable.lock);
80104fb8:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104fbf:	e8 3f 09 00 00       	call   80105903 <acquire>

	for(c = ctable.cont; c < &ctable.cont[NCONT]; c++)
80104fc4:	c7 45 f4 34 4f 11 80 	movl   $0x80114f34,-0xc(%ebp)
80104fcb:	eb 3e                	jmp    8010500b <alloccont+0x59>
		if(c->state == CUNUSED)
80104fcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd0:	8b 40 14             	mov    0x14(%eax),%eax
80104fd3:	85 c0                	test   %eax,%eax
80104fd5:	75 30                	jne    80105007 <alloccont+0x55>
		  goto found;
80104fd7:	90                   	nop

	release(&ctable.lock);
	return 0;

found:
	c->state = CEMBRYO;
80104fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fdb:	c7 40 14 01 00 00 00 	movl   $0x1,0x14(%eax)
	c->cid = nextcid++;
80104fe2:	a1 08 c0 10 80       	mov    0x8010c008,%eax
80104fe7:	8d 50 01             	lea    0x1(%eax),%edx
80104fea:	89 15 08 c0 10 80    	mov    %edx,0x8010c008
80104ff0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ff3:	89 42 0c             	mov    %eax,0xc(%edx)

	release(&ctable.lock);
80104ff6:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80104ffd:	e8 6b 09 00 00       	call   8010596d <release>

	return c;
80105002:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105005:	eb 1e                	jmp    80105025 <alloccont+0x73>
{
	struct cont *c;

	acquire(&ctable.lock);

	for(c = ctable.cont; c < &ctable.cont[NCONT]; c++)
80105007:	83 45 f4 30          	addl   $0x30,-0xc(%ebp)
8010500b:	81 7d f4 b4 50 11 80 	cmpl   $0x801150b4,-0xc(%ebp)
80105012:	72 b9                	jb     80104fcd <alloccont+0x1b>
		if(c->state == CUNUSED)
		  goto found;

	release(&ctable.lock);
80105014:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
8010501b:	e8 4d 09 00 00       	call   8010596d <release>
	return 0;
80105020:	b8 00 00 00 00       	mov    $0x0,%eax
	c->cid = nextcid++;

	release(&ctable.lock);

	return c;
}
80105025:	c9                   	leave  
80105026:	c3                   	ret    

80105027 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
80105027:	55                   	push   %ebp
80105028:	89 e5                	mov    %esp,%ebp
8010502a:	83 ec 28             	sub    $0x28,%esp
  int intena;
  struct proc *p = myproc();
8010502d:	e8 1a f2 ff ff       	call   8010424c <myproc>
80105032:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(ctablelock()))
80105035:	e8 35 fe ff ff       	call   80104e6f <ctablelock>
8010503a:	89 04 24             	mov    %eax,(%esp)
8010503d:	e8 ef 09 00 00       	call   80105a31 <holding>
80105042:	85 c0                	test   %eax,%eax
80105044:	75 0c                	jne    80105052 <sched+0x2b>
    panic("sched ptable.lock");
80105046:	c7 04 24 9a 96 10 80 	movl   $0x8010969a,(%esp)
8010504d:	e8 02 b5 ff ff       	call   80100554 <panic>
  if(mycpu()->ncli != 1) 
80105052:	e8 3c fd ff ff       	call   80104d93 <mycpu>
80105057:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010505d:	83 f8 01             	cmp    $0x1,%eax
80105060:	74 0c                	je     8010506e <sched+0x47>
    panic("sched locks");
80105062:	c7 04 24 ac 96 10 80 	movl   $0x801096ac,(%esp)
80105069:	e8 e6 b4 ff ff       	call   80100554 <panic>
  if(p->state == RUNNING)
8010506e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105071:	8b 40 0c             	mov    0xc(%eax),%eax
80105074:	83 f8 04             	cmp    $0x4,%eax
80105077:	75 0c                	jne    80105085 <sched+0x5e>
    panic("sched running");
80105079:	c7 04 24 b8 96 10 80 	movl   $0x801096b8,(%esp)
80105080:	e8 cf b4 ff ff       	call   80100554 <panic>
  if(readeflags()&FL_IF)
80105085:	e8 ae fc ff ff       	call   80104d38 <readeflags>
8010508a:	25 00 02 00 00       	and    $0x200,%eax
8010508f:	85 c0                	test   %eax,%eax
80105091:	74 0c                	je     8010509f <sched+0x78>
    panic("sched interruptible");
80105093:	c7 04 24 c6 96 10 80 	movl   $0x801096c6,(%esp)
8010509a:	e8 b5 b4 ff ff       	call   80100554 <panic>
  intena = mycpu()->intena;
8010509f:	e8 ef fc ff ff       	call   80104d93 <mycpu>
801050a4:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801050aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
801050ad:	e8 e1 fc ff ff       	call   80104d93 <mycpu>
801050b2:	8b 40 04             	mov    0x4(%eax),%eax
801050b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801050b8:	83 c2 1c             	add    $0x1c,%edx
801050bb:	89 44 24 04          	mov    %eax,0x4(%esp)
801050bf:	89 14 24             	mov    %edx,(%esp)
801050c2:	e8 19 0d 00 00       	call   80105de0 <swtch>
  mycpu()->intena = intena;
801050c7:	e8 c7 fc ff ff       	call   80104d93 <mycpu>
801050cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
801050cf:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
801050d5:	c9                   	leave  
801050d6:	c3                   	ret    

801050d7 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801050d7:	55                   	push   %ebp
801050d8:	89 e5                	mov    %esp,%ebp
801050da:	83 ec 38             	sub    $0x38,%esp
  struct proc *p;
  struct cont *cont;
  struct cpu *c = mycpu();
801050dd:	e8 b1 fc ff ff       	call   80104d93 <mycpu>
801050e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i, k;
  c->proc = 0;
801050e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801050e8:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801050ef:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
801050f2:	e8 51 fc ff ff       	call   80104d48 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
801050f7:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
801050fe:	e8 00 08 00 00       	call   80105903 <acquire>
    // TODO: do we need to acquire ctable lock too?

	// TODO: Check that scheulde cycles over ctable equally    
    for(i = 0; i < NCONT; i++) {
80105103:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010510a:	e9 57 01 00 00       	jmp    80105266 <scheduler+0x18f>

      cont = &ctable.cont[i];
8010510f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105112:	8d 50 01             	lea    0x1(%eax),%edx
80105115:	89 d0                	mov    %edx,%eax
80105117:	01 c0                	add    %eax,%eax
80105119:	01 d0                	add    %edx,%eax
8010511b:	c1 e0 04             	shl    $0x4,%eax
8010511e:	05 00 4f 11 80       	add    $0x80114f00,%eax
80105123:	83 c0 04             	add    $0x4,%eax
80105126:	89 45 e8             	mov    %eax,-0x18(%ebp)

      if (cont->state != CRUNNABLE && cont->state != CREADY)
80105129:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010512c:	8b 40 14             	mov    0x14(%eax),%eax
8010512f:	83 f8 03             	cmp    $0x3,%eax
80105132:	74 10                	je     80105144 <scheduler+0x6d>
80105134:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105137:	8b 40 14             	mov    0x14(%eax),%eax
8010513a:	83 f8 02             	cmp    $0x2,%eax
8010513d:	74 05                	je     80105144 <scheduler+0x6d>
      	continue;            
8010513f:	e9 1f 01 00 00       	jmp    80105263 <scheduler+0x18c>

      for (k = (cont->nextproc % cont->mproc); k < cont->mproc; k++) {
80105144:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105147:	8b 40 2c             	mov    0x2c(%eax),%eax
8010514a:	8b 55 e8             	mov    -0x18(%ebp),%edx
8010514d:	8b 4a 08             	mov    0x8(%edx),%ecx
80105150:	99                   	cltd   
80105151:	f7 f9                	idiv   %ecx
80105153:	89 55 f0             	mov    %edx,-0x10(%ebp)
80105156:	e9 f9 00 00 00       	jmp    80105254 <scheduler+0x17d>
      	
      	  p = &cont->ptable[k];       	  
8010515b:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010515e:	8b 50 28             	mov    0x28(%eax),%edx
80105161:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105164:	c1 e0 02             	shl    $0x2,%eax
80105167:	89 c1                	mov    %eax,%ecx
80105169:	c1 e1 05             	shl    $0x5,%ecx
8010516c:	01 c8                	add    %ecx,%eax
8010516e:	01 d0                	add    %edx,%eax
80105170:	89 45 e4             	mov    %eax,-0x1c(%ebp)

      	  cont->nextproc = cont->nextproc + 1;
80105173:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105176:	8b 40 2c             	mov    0x2c(%eax),%eax
80105179:	8d 50 01             	lea    0x1(%eax),%edx
8010517c:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010517f:	89 50 2c             	mov    %edx,0x2c(%eax)

	      if(p->state != RUNNABLE)
80105182:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105185:	8b 40 0c             	mov    0xc(%eax),%eax
80105188:	83 f8 03             	cmp    $0x3,%eax
8010518b:	74 05                	je     80105192 <scheduler+0xbb>
	        continue;
8010518d:	e9 bf 00 00 00       	jmp    80105251 <scheduler+0x17a>

	      if (strncmp("ctest1", cont->name, strlen("ctest1")) == 0 && strncmp("testproc", p->name, strlen("testproc")) == 0) {
80105192:	c7 04 24 da 96 10 80 	movl   $0x801096da,(%esp)
80105199:	e8 1b 0c 00 00       	call   80105db9 <strlen>
8010519e:	8b 55 e8             	mov    -0x18(%ebp),%edx
801051a1:	83 c2 18             	add    $0x18,%edx
801051a4:	89 44 24 08          	mov    %eax,0x8(%esp)
801051a8:	89 54 24 04          	mov    %edx,0x4(%esp)
801051ac:	c7 04 24 da 96 10 80 	movl   $0x801096da,(%esp)
801051b3:	e8 16 0b 00 00       	call   80105cce <strncmp>
801051b8:	85 c0                	test   %eax,%eax
801051ba:	75 4a                	jne    80105206 <scheduler+0x12f>
801051bc:	c7 04 24 e1 96 10 80 	movl   $0x801096e1,(%esp)
801051c3:	e8 f1 0b 00 00       	call   80105db9 <strlen>
801051c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801051cb:	83 c2 6c             	add    $0x6c,%edx
801051ce:	89 44 24 08          	mov    %eax,0x8(%esp)
801051d2:	89 54 24 04          	mov    %edx,0x4(%esp)
801051d6:	c7 04 24 e1 96 10 80 	movl   $0x801096e1,(%esp)
801051dd:	e8 ec 0a 00 00       	call   80105cce <strncmp>
801051e2:	85 c0                	test   %eax,%eax
801051e4:	75 20                	jne    80105206 <scheduler+0x12f>
	      	cprintf("\t\tScheduling %s proc %s\n", cont->name, p->name);
801051e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801051e9:	8d 50 6c             	lea    0x6c(%eax),%edx
801051ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
801051ef:	83 c0 18             	add    $0x18,%eax
801051f2:	89 54 24 08          	mov    %edx,0x8(%esp)
801051f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801051fa:	c7 04 24 ea 96 10 80 	movl   $0x801096ea,(%esp)
80105201:	e8 bb b1 ff ff       	call   801003c1 <cprintf>


	      // Switch to chosen process.  It is the process's job
	      // to release ctable.lock and then reacquire it
	      // before jumping back to us.
	      c->proc = p;
80105206:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105209:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010520c:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
	      switchuvm(p);
80105212:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105215:	89 04 24             	mov    %eax,(%esp)
80105218:	e8 1f 37 00 00       	call   8010893c <switchuvm>
	      p->state = RUNNING;
8010521d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105220:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

	      swtch(&(c->scheduler), p->context); 
80105227:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010522a:	8b 40 1c             	mov    0x1c(%eax),%eax
8010522d:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105230:	83 c2 04             	add    $0x4,%edx
80105233:	89 44 24 04          	mov    %eax,0x4(%esp)
80105237:	89 14 24             	mov    %edx,(%esp)
8010523a:	e8 a1 0b 00 00       	call   80105de0 <swtch>
	      switchkvm();
8010523f:	e8 de 36 00 00       	call   80108922 <switchkvm>

	      // Process is done running for now.
	      // It should have changed its p->state before coming back.
	      c->proc = 0;
80105244:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105247:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010524e:	00 00 00 
      cont = &ctable.cont[i];

      if (cont->state != CRUNNABLE && cont->state != CREADY)
      	continue;            

      for (k = (cont->nextproc % cont->mproc); k < cont->mproc; k++) {
80105251:	ff 45 f0             	incl   -0x10(%ebp)
80105254:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105257:	8b 40 08             	mov    0x8(%eax),%eax
8010525a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010525d:	0f 8f f8 fe ff ff    	jg     8010515b <scheduler+0x84>
    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    // TODO: do we need to acquire ctable lock too?

	// TODO: Check that scheulde cycles over ctable equally    
    for(i = 0; i < NCONT; i++) {
80105263:	ff 45 f4             	incl   -0xc(%ebp)
80105266:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010526a:	0f 8e 9f fe ff ff    	jle    8010510f <scheduler+0x38>
	      // Process is done running for now.
	      // It should have changed its p->state before coming back.
	      c->proc = 0;
	  }
    }
    release(&ptable.lock);
80105270:	c7 04 24 c0 50 11 80 	movl   $0x801150c0,(%esp)
80105277:	e8 f1 06 00 00       	call   8010596d <release>

  }
8010527c:	e9 71 fe ff ff       	jmp    801050f2 <scheduler+0x1b>

80105281 <ccreate>:
}

// TODO: Block processes inside non root containers from ccreating
int 
ccreate(char* name, char* progv[MAXARG], int progc, int mproc, uint msz, uint mdsk)
{
80105281:	55                   	push   %ebp
80105282:	89 e5                	mov    %esp,%ebp
80105284:	83 ec 28             	sub    $0x28,%esp
	int i;
	struct cont *nc;
	//struct inode *rootdir;

	// Allocate container.
	if ((nc = alloccont()) == 0) {
80105287:	e8 26 fd ff ff       	call   80104fb2 <alloccont>
8010528c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010528f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105293:	75 0a                	jne    8010529f <ccreate+0x1e>
		return -1;
80105295:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010529a:	e9 bc 00 00 00       	jmp    8010535b <ccreate+0xda>
	// }
	// iunlockput(rootdir);
	// end_op();	

	// TODO: Move files into folder
	for (i = 0; i < progc; i++) {
8010529f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801052a6:	eb 03                	jmp    801052ab <ccreate+0x2a>
801052a8:	ff 45 f4             	incl   -0xc(%ebp)
801052ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801052ae:	3b 45 10             	cmp    0x10(%ebp),%eax
801052b1:	7c f5                	jl     801052a8 <ccreate+0x27>
		// if (movefile(name, progv[i]) == 0) 
		// 	cprintf("Unable to move file %s\n", progv[i]);
	}

	acquire(&ctable.lock);
801052b3:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
801052ba:	e8 44 06 00 00       	call   80105903 <acquire>
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
	nc->rootdir = namei(name); // TODO: Check this with an if
801052d9:	8b 45 08             	mov    0x8(%ebp),%eax
801052dc:	89 04 24             	mov    %eax,(%esp)
801052df:	e8 98 d3 ff ff       	call   8010267c <namei>
801052e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801052e7:	89 42 10             	mov    %eax,0x10(%edx)
	strncpy(nc->name, name, 16); // TODO: strlen(name) instead of 16?
801052ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052ed:	8d 50 18             	lea    0x18(%eax),%edx
801052f0:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801052f7:	00 
801052f8:	8b 45 08             	mov    0x8(%ebp),%eax
801052fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801052ff:	89 14 24             	mov    %edx,(%esp)
80105302:	e8 15 0a 00 00       	call   80105d1c <strncpy>
	nc->state = CREADY;	
80105307:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010530a:	c7 40 14 02 00 00 00 	movl   $0x2,0x14(%eax)
	release(&ctable.lock);	
80105311:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80105318:	e8 50 06 00 00       	call   8010596d <release>

	cprintf("inited container %s\n", nc->name);
8010531d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105320:	83 c0 18             	add    $0x18,%eax
80105323:	89 44 24 04          	mov    %eax,0x4(%esp)
80105327:	c7 04 24 03 97 10 80 	movl   $0x80109703,(%esp)
8010532e:	e8 8e b0 ff ff       	call   801003c1 <cprintf>
	cprintf("rootdir is type folder %d\n", (nc->rootdir->type == T_DIR));    
80105333:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105336:	8b 40 10             	mov    0x10(%eax),%eax
80105339:	8b 40 50             	mov    0x50(%eax),%eax
8010533c:	66 83 f8 01          	cmp    $0x1,%ax
80105340:	0f 94 c0             	sete   %al
80105343:	0f b6 c0             	movzbl %al,%eax
80105346:	89 44 24 04          	mov    %eax,0x4(%esp)
8010534a:	c7 04 24 18 97 10 80 	movl   $0x80109718,(%esp)
80105351:	e8 6b b0 ff ff       	call   801003c1 <cprintf>

	return 1;  
80105356:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010535b:	c9                   	leave  
8010535c:	c3                   	ret    

8010535d <cstart>:

// Allocates a process for the table "name"
// Runs argv[0] (argv is program plus arguments)
int
cstart(char* name, char** argv, int argc) 
{	
8010535d:	55                   	push   %ebp
8010535e:	89 e5                	mov    %esp,%ebp
80105360:	53                   	push   %ebx
80105361:	83 ec 24             	sub    $0x24,%esp
	cprintf("Cstart\n");
80105364:	c7 04 24 33 97 10 80 	movl   $0x80109733,(%esp)
8010536b:	e8 51 b0 ff ff       	call   801003c1 <cprintf>
	//struct cpu *cpu;
	struct proc *np;
	int i;

	// Find container
	acquire(&ctable.lock);
80105370:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
80105377:	e8 87 05 00 00       	call   80105903 <acquire>

	for (i = 0; i < NCONT; i++) {
8010537c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105383:	e9 0d 01 00 00       	jmp    80105495 <cstart+0x138>
		nc = &ctable.cont[i];
80105388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010538b:	8d 50 01             	lea    0x1(%eax),%edx
8010538e:	89 d0                	mov    %edx,%eax
80105390:	01 c0                	add    %eax,%eax
80105392:	01 d0                	add    %edx,%eax
80105394:	c1 e0 04             	shl    $0x4,%eax
80105397:	05 00 4f 11 80       	add    $0x80114f00,%eax
8010539c:	83 c0 04             	add    $0x4,%eax
8010539f:	89 45 f0             	mov    %eax,-0x10(%ebp)
		// TODO: Check if this works
		if (strncmp(name, nc->name, strlen(name)) == 0 && nc->state == CREADY)
801053a2:	8b 45 08             	mov    0x8(%ebp),%eax
801053a5:	89 04 24             	mov    %eax,(%esp)
801053a8:	e8 0c 0a 00 00       	call   80105db9 <strlen>
801053ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
801053b0:	83 c2 18             	add    $0x18,%edx
801053b3:	89 44 24 08          	mov    %eax,0x8(%esp)
801053b7:	89 54 24 04          	mov    %edx,0x4(%esp)
801053bb:	8b 45 08             	mov    0x8(%ebp),%eax
801053be:	89 04 24             	mov    %eax,(%esp)
801053c1:	e8 08 09 00 00       	call   80105cce <strncmp>
801053c6:	85 c0                	test   %eax,%eax
801053c8:	0f 85 c4 00 00 00    	jne    80105492 <cstart+0x135>
801053ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053d1:	8b 40 14             	mov    0x14(%eax),%eax
801053d4:	83 f8 02             	cmp    $0x2,%eax
801053d7:	0f 85 b5 00 00 00    	jne    80105492 <cstart+0x135>
			goto found;
801053dd:	90                   	nop
	release(&ctable.lock);
	return -1;

found: 	

	cprintf("\tFound container to run (%s)\n", nc->name);
801053de:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053e1:	83 c0 18             	add    $0x18,%eax
801053e4:	89 44 24 04          	mov    %eax,0x4(%esp)
801053e8:	c7 04 24 5d 97 10 80 	movl   $0x8010975d,(%esp)
801053ef:	e8 cd af ff ff       	call   801003c1 <cprintf>
	// TODO COMMENT THIS A TON

	// TODO: Change init process back
	// TODO: Clean up cfork/ change fork to accept a parent container

	cprintf("cstart: nc->rootdir->type %d", nc->rootdir->type);
801053f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053f7:	8b 40 10             	mov    0x10(%eax),%eax
801053fa:	8b 40 50             	mov    0x50(%eax),%eax
801053fd:	98                   	cwtl   
801053fe:	89 44 24 04          	mov    %eax,0x4(%esp)
80105402:	c7 04 24 7b 97 10 80 	movl   $0x8010977b,(%esp)
80105409:	e8 b3 af ff ff       	call   801003c1 <cprintf>
	// if ((np = cfork(nc)) == 0) {
	// 	cprintf("couldn't cfork\n");
	// 	release(&ctable.lock);
	// 	return -1;
	// }
	np = initprocess(nc, "initproc", 0);
8010540e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80105415:	00 
80105416:	c7 44 24 04 91 96 10 	movl   $0x80109691,0x4(%esp)
8010541d:	80 
8010541e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105421:	89 04 24             	mov    %eax,(%esp)
80105424:	e8 71 ef ff ff       	call   8010439a <initprocess>
80105429:	89 45 ec             	mov    %eax,-0x14(%ebp)

	nc->state = CREADY;	
8010542c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010542f:	c7 40 14 02 00 00 00 	movl   $0x2,0x14(%eax)
	// myproc()->state = RUNNABLE; 
	cprintf("np->state is RUNNABLE: %d\n", (np->state == RUNNABLE));
80105436:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105439:	8b 40 0c             	mov    0xc(%eax),%eax
8010543c:	83 f8 03             	cmp    $0x3,%eax
8010543f:	0f 94 c0             	sete   %al
80105442:	0f b6 c0             	movzbl %al,%eax
80105445:	89 44 24 04          	mov    %eax,0x4(%esp)
80105449:	c7 04 24 98 97 10 80 	movl   $0x80109798,(%esp)
80105450:	e8 6c af ff ff       	call   801003c1 <cprintf>

	release(&ctable.lock);
80105455:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
8010545c:	e8 0c 05 00 00       	call   8010596d <release>
	// acquirectable();
	// sched();
	// releasectable();
	
	// Does copyuvm not also copy the place in kernel vm?
	cprintf("This should print twice: container %s proc %s\n", myproc()->cont->name, myproc()->name);
80105461:	e8 e6 ed ff ff       	call   8010424c <myproc>
80105466:	8d 58 6c             	lea    0x6c(%eax),%ebx
80105469:	e8 de ed ff ff       	call   8010424c <myproc>
8010546e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105474:	83 c0 18             	add    $0x18,%eax
80105477:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010547b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010547f:	c7 04 24 b4 97 10 80 	movl   $0x801097b4,(%esp)
80105486:	e8 36 af ff ff       	call   801003c1 <cprintf>
	// 	cprintf("CONFIRMATION THAT OTHER GUY RAN\n");
	// }		

	//	release(&ctable.lock);	

	return 1;
8010548b:	b8 01 00 00 00       	mov    $0x1,%eax
80105490:	eb 31                	jmp    801054c3 <cstart+0x166>
	int i;

	// Find container
	acquire(&ctable.lock);

	for (i = 0; i < NCONT; i++) {
80105492:	ff 45 f4             	incl   -0xc(%ebp)
80105495:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80105499:	0f 8e e9 fe ff ff    	jle    80105388 <cstart+0x2b>
		// TODO: Check if this works
		if (strncmp(name, nc->name, strlen(name)) == 0 && nc->state == CREADY)
			goto found;
	}

	cprintf("No free container with name %s \n", name);
8010549f:	8b 45 08             	mov    0x8(%ebp),%eax
801054a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801054a6:	c7 04 24 3c 97 10 80 	movl   $0x8010973c,(%esp)
801054ad:	e8 0f af ff ff       	call   801003c1 <cprintf>
	release(&ctable.lock);
801054b2:	c7 04 24 00 4f 11 80 	movl   $0x80114f00,(%esp)
801054b9:	e8 af 04 00 00       	call   8010596d <release>
	return -1;
801054be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	// }		

	//	release(&ctable.lock);	

	return 1;
}
801054c3:	83 c4 24             	add    $0x24,%esp
801054c6:	5b                   	pop    %ebx
801054c7:	5d                   	pop    %ebp
801054c8:	c3                   	ret    

801054c9 <movefile>:


/* Moves file src to folder dst 
TODO: Implement */
int
movefile(char* dst, char* src) {
801054c9:	55                   	push   %ebp
801054ca:	89 e5                	mov    %esp,%ebp
801054cc:	57                   	push   %edi
801054cd:	56                   	push   %esi
801054ce:	53                   	push   %ebx
801054cf:	83 ec 2c             	sub    $0x2c,%esp
801054d2:	89 e0                	mov    %esp,%eax
801054d4:	89 c6                	mov    %eax,%esi
	
	int pathsize = sizeof(dst) + sizeof(src) + 2; // dst.len + '\' + src.len + \0
801054d6:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
	char path[pathsize]; 
801054dd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801054e0:	8d 50 ff             	lea    -0x1(%eax),%edx
801054e3:	89 55 e0             	mov    %edx,-0x20(%ebp)
801054e6:	ba 10 00 00 00       	mov    $0x10,%edx
801054eb:	4a                   	dec    %edx
801054ec:	01 d0                	add    %edx,%eax
801054ee:	b9 10 00 00 00       	mov    $0x10,%ecx
801054f3:	ba 00 00 00 00       	mov    $0x0,%edx
801054f8:	f7 f1                	div    %ecx
801054fa:	6b c0 10             	imul   $0x10,%eax,%eax
801054fd:	29 c4                	sub    %eax,%esp
801054ff:	8d 44 24 0c          	lea    0xc(%esp),%eax
80105503:	83 c0 00             	add    $0x0,%eax
80105506:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// struct file *f;
	// struct inode *ip;

	memmove(path, dst, strlen(dst));
80105509:	8b 45 08             	mov    0x8(%ebp),%eax
8010550c:	89 04 24             	mov    %eax,(%esp)
8010550f:	e8 a5 08 00 00       	call   80105db9 <strlen>
80105514:	89 c2                	mov    %eax,%edx
80105516:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105519:	89 54 24 08          	mov    %edx,0x8(%esp)
8010551d:	8b 55 08             	mov    0x8(%ebp),%edx
80105520:	89 54 24 04          	mov    %edx,0x4(%esp)
80105524:	89 04 24             	mov    %eax,(%esp)
80105527:	e8 03 07 00 00       	call   80105c2f <memmove>
	memmove(path + strlen(dst), "/", 1);
8010552c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
8010552f:	8b 45 08             	mov    0x8(%ebp),%eax
80105532:	89 04 24             	mov    %eax,(%esp)
80105535:	e8 7f 08 00 00       	call   80105db9 <strlen>
8010553a:	01 d8                	add    %ebx,%eax
8010553c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
80105543:	00 
80105544:	c7 44 24 04 6c 96 10 	movl   $0x8010966c,0x4(%esp)
8010554b:	80 
8010554c:	89 04 24             	mov    %eax,(%esp)
8010554f:	e8 db 06 00 00       	call   80105c2f <memmove>
	memmove(path + strlen(dst) + 1, src, strlen(src));
80105554:	8b 45 0c             	mov    0xc(%ebp),%eax
80105557:	89 04 24             	mov    %eax,(%esp)
8010555a:	e8 5a 08 00 00       	call   80105db9 <strlen>
8010555f:	89 c3                	mov    %eax,%ebx
80105561:	8b 7d dc             	mov    -0x24(%ebp),%edi
80105564:	8b 45 08             	mov    0x8(%ebp),%eax
80105567:	89 04 24             	mov    %eax,(%esp)
8010556a:	e8 4a 08 00 00       	call   80105db9 <strlen>
8010556f:	40                   	inc    %eax
80105570:	8d 14 07             	lea    (%edi,%eax,1),%edx
80105573:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80105577:	8b 45 0c             	mov    0xc(%ebp),%eax
8010557a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010557e:	89 14 24             	mov    %edx,(%esp)
80105581:	e8 a9 06 00 00       	call   80105c2f <memmove>
	memmove(path + strlen(dst) + 1 + strlen(src), "\0", 1);
80105586:	8b 5d dc             	mov    -0x24(%ebp),%ebx
80105589:	8b 45 08             	mov    0x8(%ebp),%eax
8010558c:	89 04 24             	mov    %eax,(%esp)
8010558f:	e8 25 08 00 00       	call   80105db9 <strlen>
80105594:	89 c7                	mov    %eax,%edi
80105596:	8b 45 0c             	mov    0xc(%ebp),%eax
80105599:	89 04 24             	mov    %eax,(%esp)
8010559c:	e8 18 08 00 00       	call   80105db9 <strlen>
801055a1:	01 f8                	add    %edi,%eax
801055a3:	40                   	inc    %eax
801055a4:	01 d8                	add    %ebx,%eax
801055a6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801055ad:	00 
801055ae:	c7 44 24 04 e3 97 10 	movl   $0x801097e3,0x4(%esp)
801055b5:	80 
801055b6:	89 04 24             	mov    %eax,(%esp)
801055b9:	e8 71 06 00 00       	call   80105c2f <memmove>

	cprintf("movefile path: %s\n", path);
801055be:	8b 45 dc             	mov    -0x24(%ebp),%eax
801055c1:	89 44 24 04          	mov    %eax,0x4(%esp)
801055c5:	c7 04 24 e5 97 10 80 	movl   $0x801097e5,(%esp)
801055cc:	e8 f0 ad ff ff       	call   801003c1 <cprintf>
	// // Copy contents of src into new file
	// char* source;
	// fileread();	


	return 1;
801055d1:	b8 01 00 00 00       	mov    $0x1,%eax
801055d6:	89 f4                	mov    %esi,%esp
}
801055d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801055db:	5b                   	pop    %ebx
801055dc:	5e                   	pop    %esi
801055dd:	5f                   	pop    %edi
801055de:	5d                   	pop    %ebp
801055df:	c3                   	ret    

801055e0 <contdump>:
// Print a process listing of current container to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
contdump(void)
{
801055e0:	55                   	push   %ebp
801055e1:	89 e5                	mov    %esp,%ebp
801055e3:	53                   	push   %ebx
801055e4:	83 ec 64             	sub    $0x64,%esp
  struct cont *c;
  struct proc *p;
  char *state;
  uint pc[10];

  cprintf("Contdump()\n");
801055e7:	c7 04 24 f8 97 10 80 	movl   $0x801097f8,(%esp)
801055ee:	e8 ce ad ff ff       	call   801003c1 <cprintf>
  cprintf("cont 2 p[0] %s %s\n", ctable.cont[1].ptable[0].name, states[ctable.cont[1].ptable[0].state]);
801055f3:	a1 8c 4f 11 80       	mov    0x80114f8c,%eax
801055f8:	8b 40 0c             	mov    0xc(%eax),%eax
801055fb:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105602:	8b 15 8c 4f 11 80    	mov    0x80114f8c,%edx
80105608:	83 c2 6c             	add    $0x6c,%edx
8010560b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010560f:	89 54 24 04          	mov    %edx,0x4(%esp)
80105613:	c7 04 24 04 98 10 80 	movl   $0x80109804,(%esp)
8010561a:	e8 a2 ad ff ff       	call   801003c1 <cprintf>

  acquirectable();
8010561f:	e8 23 f8 ff ff       	call   80104e47 <acquirectable>

  for(i = 0; i < NCONT; i++) {
80105624:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010562b:	e9 5c 01 00 00       	jmp    8010578c <contdump+0x1ac>

      c = &ctable.cont[i];
80105630:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105633:	8d 50 01             	lea    0x1(%eax),%edx
80105636:	89 d0                	mov    %edx,%eax
80105638:	01 c0                	add    %eax,%eax
8010563a:	01 d0                	add    %edx,%eax
8010563c:	c1 e0 04             	shl    $0x4,%eax
8010563f:	05 00 4f 11 80       	add    $0x80114f00,%eax
80105644:	83 c0 04             	add    $0x4,%eax
80105647:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      nextproc = 0, k = 0;
8010564a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80105651:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

      if (c->state == CUNUSED)
80105658:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010565b:	8b 40 14             	mov    0x14(%eax),%eax
8010565e:	85 c0                	test   %eax,%eax
80105660:	75 05                	jne    80105667 <contdump+0x87>
      	continue;
80105662:	e9 22 01 00 00       	jmp    80105789 <contdump+0x1a9>

      for (k = (nextproc % c->mproc); k < c->mproc; k++) {
80105667:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010566a:	8b 48 08             	mov    0x8(%eax),%ecx
8010566d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105670:	99                   	cltd   
80105671:	f7 f9                	idiv   %ecx
80105673:	89 55 f0             	mov    %edx,-0x10(%ebp)
80105676:	e9 ff 00 00 00       	jmp    8010577a <contdump+0x19a>
      
      	p = &c->ptable[k]; 
8010567b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010567e:	8b 50 28             	mov    0x28(%eax),%edx
80105681:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105684:	c1 e0 02             	shl    $0x2,%eax
80105687:	89 c1                	mov    %eax,%ecx
80105689:	c1 e1 05             	shl    $0x5,%ecx
8010568c:	01 c8                	add    %ecx,%eax
8010568e:	01 d0                	add    %edx,%eax
80105690:	89 45 e0             	mov    %eax,-0x20(%ebp)

      	nextproc++;
80105693:	ff 45 ec             	incl   -0x14(%ebp)

	    if(p->state == UNUSED)
80105696:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105699:	8b 40 0c             	mov    0xc(%eax),%eax
8010569c:	85 c0                	test   %eax,%eax
8010569e:	75 05                	jne    801056a5 <contdump+0xc5>
		    continue;
801056a0:	e9 d2 00 00 00       	jmp    80105777 <contdump+0x197>
	    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801056a5:	8b 45 e0             	mov    -0x20(%ebp),%eax
801056a8:	8b 40 0c             	mov    0xc(%eax),%eax
801056ab:	83 f8 05             	cmp    $0x5,%eax
801056ae:	77 23                	ja     801056d3 <contdump+0xf3>
801056b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801056b3:	8b 40 0c             	mov    0xc(%eax),%eax
801056b6:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
801056bd:	85 c0                	test   %eax,%eax
801056bf:	74 12                	je     801056d3 <contdump+0xf3>
	      state = states[p->state];
801056c1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801056c4:	8b 40 0c             	mov    0xc(%eax),%eax
801056c7:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
801056ce:	89 45 e8             	mov    %eax,-0x18(%ebp)
801056d1:	eb 07                	jmp    801056da <contdump+0xfa>
	    else
	      state = "???";
801056d3:	c7 45 e8 17 98 10 80 	movl   $0x80109817,-0x18(%ebp)
	    cprintf("container: %s. %d %s %s", p->cont->name, p->pid, state, p->name);
801056da:	8b 45 e0             	mov    -0x20(%ebp),%eax
801056dd:	8d 58 6c             	lea    0x6c(%eax),%ebx
801056e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
801056e3:	8b 40 10             	mov    0x10(%eax),%eax
801056e6:	8b 55 e0             	mov    -0x20(%ebp),%edx
801056e9:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
801056ef:	8d 4a 18             	lea    0x18(%edx),%ecx
801056f2:	89 5c 24 10          	mov    %ebx,0x10(%esp)
801056f6:	8b 55 e8             	mov    -0x18(%ebp),%edx
801056f9:	89 54 24 0c          	mov    %edx,0xc(%esp)
801056fd:	89 44 24 08          	mov    %eax,0x8(%esp)
80105701:	89 4c 24 04          	mov    %ecx,0x4(%esp)
80105705:	c7 04 24 1b 98 10 80 	movl   $0x8010981b,(%esp)
8010570c:	e8 b0 ac ff ff       	call   801003c1 <cprintf>
	    if(p->state == SLEEPING){
80105711:	8b 45 e0             	mov    -0x20(%ebp),%eax
80105714:	8b 40 0c             	mov    0xc(%eax),%eax
80105717:	83 f8 02             	cmp    $0x2,%eax
8010571a:	75 4f                	jne    8010576b <contdump+0x18b>
	      getcallerpcs((uint*)p->context->ebp+2, pc);
8010571c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010571f:	8b 40 1c             	mov    0x1c(%eax),%eax
80105722:	8b 40 0c             	mov    0xc(%eax),%eax
80105725:	83 c0 08             	add    $0x8,%eax
80105728:	8d 55 b8             	lea    -0x48(%ebp),%edx
8010572b:	89 54 24 04          	mov    %edx,0x4(%esp)
8010572f:	89 04 24             	mov    %eax,(%esp)
80105732:	e8 83 02 00 00       	call   801059ba <getcallerpcs>
	      for(i=0; i<10 && pc[i] != 0; i++)
80105737:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010573e:	eb 1a                	jmp    8010575a <contdump+0x17a>
	        cprintf(" %p", pc[i]);
80105740:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105743:	8b 44 85 b8          	mov    -0x48(%ebp,%eax,4),%eax
80105747:	89 44 24 04          	mov    %eax,0x4(%esp)
8010574b:	c7 04 24 33 98 10 80 	movl   $0x80109833,(%esp)
80105752:	e8 6a ac ff ff       	call   801003c1 <cprintf>
	    else
	      state = "???";
	    cprintf("container: %s. %d %s %s", p->cont->name, p->pid, state, p->name);
	    if(p->state == SLEEPING){
	      getcallerpcs((uint*)p->context->ebp+2, pc);
	      for(i=0; i<10 && pc[i] != 0; i++)
80105757:	ff 45 f4             	incl   -0xc(%ebp)
8010575a:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010575e:	7f 0b                	jg     8010576b <contdump+0x18b>
80105760:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105763:	8b 44 85 b8          	mov    -0x48(%ebp,%eax,4),%eax
80105767:	85 c0                	test   %eax,%eax
80105769:	75 d5                	jne    80105740 <contdump+0x160>
	        cprintf(" %p", pc[i]);
	    }
	    cprintf("\n");
8010576b:	c7 04 24 37 98 10 80 	movl   $0x80109837,(%esp)
80105772:	e8 4a ac ff ff       	call   801003c1 <cprintf>
      nextproc = 0, k = 0;

      if (c->state == CUNUSED)
      	continue;

      for (k = (nextproc % c->mproc); k < c->mproc; k++) {
80105777:	ff 45 f0             	incl   -0x10(%ebp)
8010577a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010577d:	8b 40 08             	mov    0x8(%eax),%eax
80105780:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80105783:	0f 8f f2 fe ff ff    	jg     8010567b <contdump+0x9b>
  cprintf("Contdump()\n");
  cprintf("cont 2 p[0] %s %s\n", ctable.cont[1].ptable[0].name, states[ctable.cont[1].ptable[0].state]);

  acquirectable();

  for(i = 0; i < NCONT; i++) {
80105789:	ff 45 f4             	incl   -0xc(%ebp)
8010578c:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
80105790:	0f 8e 9a fe ff ff    	jle    80105630 <contdump+0x50>
	    }
	    cprintf("\n");
	  }
  }

  releasectable();
80105796:	e8 c0 f6 ff ff       	call   80104e5b <releasectable>
8010579b:	83 c4 64             	add    $0x64,%esp
8010579e:	5b                   	pop    %ebx
8010579f:	5d                   	pop    %ebp
801057a0:	c3                   	ret    
801057a1:	00 00                	add    %al,(%eax)
	...

801057a4 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801057a4:	55                   	push   %ebp
801057a5:	89 e5                	mov    %esp,%ebp
801057a7:	83 ec 18             	sub    $0x18,%esp
  initlock(&lk->lk, "sleep lock");
801057aa:	8b 45 08             	mov    0x8(%ebp),%eax
801057ad:	83 c0 04             	add    $0x4,%eax
801057b0:	c7 44 24 04 63 98 10 	movl   $0x80109863,0x4(%esp)
801057b7:	80 
801057b8:	89 04 24             	mov    %eax,(%esp)
801057bb:	e8 22 01 00 00       	call   801058e2 <initlock>
  lk->name = name;
801057c0:	8b 45 08             	mov    0x8(%ebp),%eax
801057c3:	8b 55 0c             	mov    0xc(%ebp),%edx
801057c6:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801057c9:	8b 45 08             	mov    0x8(%ebp),%eax
801057cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801057d2:	8b 45 08             	mov    0x8(%ebp),%eax
801057d5:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801057dc:	c9                   	leave  
801057dd:	c3                   	ret    

801057de <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801057de:	55                   	push   %ebp
801057df:	89 e5                	mov    %esp,%ebp
801057e1:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
801057e4:	8b 45 08             	mov    0x8(%ebp),%eax
801057e7:	83 c0 04             	add    $0x4,%eax
801057ea:	89 04 24             	mov    %eax,(%esp)
801057ed:	e8 11 01 00 00       	call   80105903 <acquire>
  while (lk->locked) {
801057f2:	eb 15                	jmp    80105809 <acquiresleep+0x2b>
    sleep(lk, &lk->lk);
801057f4:	8b 45 08             	mov    0x8(%ebp),%eax
801057f7:	83 c0 04             	add    $0x4,%eax
801057fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801057fe:	8b 45 08             	mov    0x8(%ebp),%eax
80105801:	89 04 24             	mov    %eax,(%esp)
80105804:	e8 5f f3 ff ff       	call   80104b68 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80105809:	8b 45 08             	mov    0x8(%ebp),%eax
8010580c:	8b 00                	mov    (%eax),%eax
8010580e:	85 c0                	test   %eax,%eax
80105810:	75 e2                	jne    801057f4 <acquiresleep+0x16>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80105812:	8b 45 08             	mov    0x8(%ebp),%eax
80105815:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
8010581b:	e8 2c ea ff ff       	call   8010424c <myproc>
80105820:	8b 50 10             	mov    0x10(%eax),%edx
80105823:	8b 45 08             	mov    0x8(%ebp),%eax
80105826:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80105829:	8b 45 08             	mov    0x8(%ebp),%eax
8010582c:	83 c0 04             	add    $0x4,%eax
8010582f:	89 04 24             	mov    %eax,(%esp)
80105832:	e8 36 01 00 00       	call   8010596d <release>
}
80105837:	c9                   	leave  
80105838:	c3                   	ret    

80105839 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80105839:	55                   	push   %ebp
8010583a:	89 e5                	mov    %esp,%ebp
8010583c:	83 ec 18             	sub    $0x18,%esp
  acquire(&lk->lk);
8010583f:	8b 45 08             	mov    0x8(%ebp),%eax
80105842:	83 c0 04             	add    $0x4,%eax
80105845:	89 04 24             	mov    %eax,(%esp)
80105848:	e8 b6 00 00 00       	call   80105903 <acquire>
  lk->locked = 0;
8010584d:	8b 45 08             	mov    0x8(%ebp),%eax
80105850:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80105856:	8b 45 08             	mov    0x8(%ebp),%eax
80105859:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80105860:	8b 45 08             	mov    0x8(%ebp),%eax
80105863:	89 04 24             	mov    %eax,(%esp)
80105866:	e8 18 f4 ff ff       	call   80104c83 <wakeup>
  release(&lk->lk);
8010586b:	8b 45 08             	mov    0x8(%ebp),%eax
8010586e:	83 c0 04             	add    $0x4,%eax
80105871:	89 04 24             	mov    %eax,(%esp)
80105874:	e8 f4 00 00 00       	call   8010596d <release>
}
80105879:	c9                   	leave  
8010587a:	c3                   	ret    

8010587b <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
8010587b:	55                   	push   %ebp
8010587c:	89 e5                	mov    %esp,%ebp
8010587e:	83 ec 28             	sub    $0x28,%esp
  int r;
  
  acquire(&lk->lk);
80105881:	8b 45 08             	mov    0x8(%ebp),%eax
80105884:	83 c0 04             	add    $0x4,%eax
80105887:	89 04 24             	mov    %eax,(%esp)
8010588a:	e8 74 00 00 00       	call   80105903 <acquire>
  r = lk->locked;
8010588f:	8b 45 08             	mov    0x8(%ebp),%eax
80105892:	8b 00                	mov    (%eax),%eax
80105894:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
80105897:	8b 45 08             	mov    0x8(%ebp),%eax
8010589a:	83 c0 04             	add    $0x4,%eax
8010589d:	89 04 24             	mov    %eax,(%esp)
801058a0:	e8 c8 00 00 00       	call   8010596d <release>
  return r;
801058a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801058a8:	c9                   	leave  
801058a9:	c3                   	ret    
	...

801058ac <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801058ac:	55                   	push   %ebp
801058ad:	89 e5                	mov    %esp,%ebp
801058af:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801058b2:	9c                   	pushf  
801058b3:	58                   	pop    %eax
801058b4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801058b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801058ba:	c9                   	leave  
801058bb:	c3                   	ret    

801058bc <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
801058bc:	55                   	push   %ebp
801058bd:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801058bf:	fa                   	cli    
}
801058c0:	5d                   	pop    %ebp
801058c1:	c3                   	ret    

801058c2 <sti>:

static inline void
sti(void)
{
801058c2:	55                   	push   %ebp
801058c3:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801058c5:	fb                   	sti    
}
801058c6:	5d                   	pop    %ebp
801058c7:	c3                   	ret    

801058c8 <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
801058c8:	55                   	push   %ebp
801058c9:	89 e5                	mov    %esp,%ebp
801058cb:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801058ce:	8b 55 08             	mov    0x8(%ebp),%edx
801058d1:	8b 45 0c             	mov    0xc(%ebp),%eax
801058d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
801058d7:	f0 87 02             	lock xchg %eax,(%edx)
801058da:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801058dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801058e0:	c9                   	leave  
801058e1:	c3                   	ret    

801058e2 <initlock>:
#include "container.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801058e2:	55                   	push   %ebp
801058e3:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801058e5:	8b 45 08             	mov    0x8(%ebp),%eax
801058e8:	8b 55 0c             	mov    0xc(%ebp),%edx
801058eb:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
801058ee:	8b 45 08             	mov    0x8(%ebp),%eax
801058f1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
801058f7:	8b 45 08             	mov    0x8(%ebp),%eax
801058fa:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105901:	5d                   	pop    %ebp
80105902:	c3                   	ret    

80105903 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105903:	55                   	push   %ebp
80105904:	89 e5                	mov    %esp,%ebp
80105906:	53                   	push   %ebx
80105907:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010590a:	e8 53 01 00 00       	call   80105a62 <pushcli>
  if(holding(lk))
8010590f:	8b 45 08             	mov    0x8(%ebp),%eax
80105912:	89 04 24             	mov    %eax,(%esp)
80105915:	e8 17 01 00 00       	call   80105a31 <holding>
8010591a:	85 c0                	test   %eax,%eax
8010591c:	74 0c                	je     8010592a <acquire+0x27>
    panic("acquire");
8010591e:	c7 04 24 6e 98 10 80 	movl   $0x8010986e,(%esp)
80105925:	e8 2a ac ff ff       	call   80100554 <panic>

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
8010592a:	90                   	nop
8010592b:	8b 45 08             	mov    0x8(%ebp),%eax
8010592e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80105935:	00 
80105936:	89 04 24             	mov    %eax,(%esp)
80105939:	e8 8a ff ff ff       	call   801058c8 <xchg>
8010593e:	85 c0                	test   %eax,%eax
80105940:	75 e9                	jne    8010592b <acquire+0x28>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80105942:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80105947:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010594a:	e8 44 f4 ff ff       	call   80104d93 <mycpu>
8010594f:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80105952:	8b 45 08             	mov    0x8(%ebp),%eax
80105955:	83 c0 0c             	add    $0xc,%eax
80105958:	89 44 24 04          	mov    %eax,0x4(%esp)
8010595c:	8d 45 08             	lea    0x8(%ebp),%eax
8010595f:	89 04 24             	mov    %eax,(%esp)
80105962:	e8 53 00 00 00       	call   801059ba <getcallerpcs>
}
80105967:	83 c4 14             	add    $0x14,%esp
8010596a:	5b                   	pop    %ebx
8010596b:	5d                   	pop    %ebp
8010596c:	c3                   	ret    

8010596d <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010596d:	55                   	push   %ebp
8010596e:	89 e5                	mov    %esp,%ebp
80105970:	83 ec 18             	sub    $0x18,%esp
  if(!holding(lk))
80105973:	8b 45 08             	mov    0x8(%ebp),%eax
80105976:	89 04 24             	mov    %eax,(%esp)
80105979:	e8 b3 00 00 00       	call   80105a31 <holding>
8010597e:	85 c0                	test   %eax,%eax
80105980:	75 0c                	jne    8010598e <release+0x21>
    panic("release");
80105982:	c7 04 24 76 98 10 80 	movl   $0x80109876,(%esp)
80105989:	e8 c6 ab ff ff       	call   80100554 <panic>

  lk->pcs[0] = 0;
8010598e:	8b 45 08             	mov    0x8(%ebp),%eax
80105991:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
80105998:	8b 45 08             	mov    0x8(%ebp),%eax
8010599b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801059a2:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801059a7:	8b 45 08             	mov    0x8(%ebp),%eax
801059aa:	8b 55 08             	mov    0x8(%ebp),%edx
801059ad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801059b3:	e8 f4 00 00 00       	call   80105aac <popcli>
}
801059b8:	c9                   	leave  
801059b9:	c3                   	ret    

801059ba <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801059ba:	55                   	push   %ebp
801059bb:	89 e5                	mov    %esp,%ebp
801059bd:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801059c0:	8b 45 08             	mov    0x8(%ebp),%eax
801059c3:	83 e8 08             	sub    $0x8,%eax
801059c6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801059c9:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801059d0:	eb 37                	jmp    80105a09 <getcallerpcs+0x4f>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801059d2:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801059d6:	74 37                	je     80105a0f <getcallerpcs+0x55>
801059d8:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801059df:	76 2e                	jbe    80105a0f <getcallerpcs+0x55>
801059e1:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
801059e5:	74 28                	je     80105a0f <getcallerpcs+0x55>
      break;
    pcs[i] = ebp[1];     // saved %eip
801059e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
801059ea:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801059f1:	8b 45 0c             	mov    0xc(%ebp),%eax
801059f4:	01 c2                	add    %eax,%edx
801059f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801059f9:	8b 40 04             	mov    0x4(%eax),%eax
801059fc:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801059fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a01:	8b 00                	mov    (%eax),%eax
80105a03:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80105a06:	ff 45 f8             	incl   -0x8(%ebp)
80105a09:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105a0d:	7e c3                	jle    801059d2 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105a0f:	eb 18                	jmp    80105a29 <getcallerpcs+0x6f>
    pcs[i] = 0;
80105a11:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105a14:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105a1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a1e:	01 d0                	add    %edx,%eax
80105a20:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80105a26:	ff 45 f8             	incl   -0x8(%ebp)
80105a29:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
80105a2d:	7e e2                	jle    80105a11 <getcallerpcs+0x57>
    pcs[i] = 0;
}
80105a2f:	c9                   	leave  
80105a30:	c3                   	ret    

80105a31 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80105a31:	55                   	push   %ebp
80105a32:	89 e5                	mov    %esp,%ebp
80105a34:	53                   	push   %ebx
80105a35:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80105a38:	8b 45 08             	mov    0x8(%ebp),%eax
80105a3b:	8b 00                	mov    (%eax),%eax
80105a3d:	85 c0                	test   %eax,%eax
80105a3f:	74 16                	je     80105a57 <holding+0x26>
80105a41:	8b 45 08             	mov    0x8(%ebp),%eax
80105a44:	8b 58 08             	mov    0x8(%eax),%ebx
80105a47:	e8 47 f3 ff ff       	call   80104d93 <mycpu>
80105a4c:	39 c3                	cmp    %eax,%ebx
80105a4e:	75 07                	jne    80105a57 <holding+0x26>
80105a50:	b8 01 00 00 00       	mov    $0x1,%eax
80105a55:	eb 05                	jmp    80105a5c <holding+0x2b>
80105a57:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105a5c:	83 c4 04             	add    $0x4,%esp
80105a5f:	5b                   	pop    %ebx
80105a60:	5d                   	pop    %ebp
80105a61:	c3                   	ret    

80105a62 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105a62:	55                   	push   %ebp
80105a63:	89 e5                	mov    %esp,%ebp
80105a65:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80105a68:	e8 3f fe ff ff       	call   801058ac <readeflags>
80105a6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
80105a70:	e8 47 fe ff ff       	call   801058bc <cli>
  if(mycpu()->ncli == 0)
80105a75:	e8 19 f3 ff ff       	call   80104d93 <mycpu>
80105a7a:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105a80:	85 c0                	test   %eax,%eax
80105a82:	75 14                	jne    80105a98 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
80105a84:	e8 0a f3 ff ff       	call   80104d93 <mycpu>
80105a89:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a8c:	81 e2 00 02 00 00    	and    $0x200,%edx
80105a92:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
80105a98:	e8 f6 f2 ff ff       	call   80104d93 <mycpu>
80105a9d:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105aa3:	42                   	inc    %edx
80105aa4:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
80105aaa:	c9                   	leave  
80105aab:	c3                   	ret    

80105aac <popcli>:

void
popcli(void)
{
80105aac:	55                   	push   %ebp
80105aad:	89 e5                	mov    %esp,%ebp
80105aaf:	83 ec 18             	sub    $0x18,%esp
  if(readeflags()&FL_IF)
80105ab2:	e8 f5 fd ff ff       	call   801058ac <readeflags>
80105ab7:	25 00 02 00 00       	and    $0x200,%eax
80105abc:	85 c0                	test   %eax,%eax
80105abe:	74 0c                	je     80105acc <popcli+0x20>
    panic("popcli - interruptible");
80105ac0:	c7 04 24 7e 98 10 80 	movl   $0x8010987e,(%esp)
80105ac7:	e8 88 aa ff ff       	call   80100554 <panic>
  if(--mycpu()->ncli < 0)
80105acc:	e8 c2 f2 ff ff       	call   80104d93 <mycpu>
80105ad1:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80105ad7:	4a                   	dec    %edx
80105ad8:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80105ade:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105ae4:	85 c0                	test   %eax,%eax
80105ae6:	79 0c                	jns    80105af4 <popcli+0x48>
    panic("popcli");
80105ae8:	c7 04 24 95 98 10 80 	movl   $0x80109895,(%esp)
80105aef:	e8 60 aa ff ff       	call   80100554 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80105af4:	e8 9a f2 ff ff       	call   80104d93 <mycpu>
80105af9:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80105aff:	85 c0                	test   %eax,%eax
80105b01:	75 14                	jne    80105b17 <popcli+0x6b>
80105b03:	e8 8b f2 ff ff       	call   80104d93 <mycpu>
80105b08:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80105b0e:	85 c0                	test   %eax,%eax
80105b10:	74 05                	je     80105b17 <popcli+0x6b>
    sti();
80105b12:	e8 ab fd ff ff       	call   801058c2 <sti>
}
80105b17:	c9                   	leave  
80105b18:	c3                   	ret    
80105b19:	00 00                	add    %al,(%eax)
	...

80105b1c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
80105b1c:	55                   	push   %ebp
80105b1d:	89 e5                	mov    %esp,%ebp
80105b1f:	57                   	push   %edi
80105b20:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80105b21:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105b24:	8b 55 10             	mov    0x10(%ebp),%edx
80105b27:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b2a:	89 cb                	mov    %ecx,%ebx
80105b2c:	89 df                	mov    %ebx,%edi
80105b2e:	89 d1                	mov    %edx,%ecx
80105b30:	fc                   	cld    
80105b31:	f3 aa                	rep stos %al,%es:(%edi)
80105b33:	89 ca                	mov    %ecx,%edx
80105b35:	89 fb                	mov    %edi,%ebx
80105b37:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105b3a:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105b3d:	5b                   	pop    %ebx
80105b3e:	5f                   	pop    %edi
80105b3f:	5d                   	pop    %ebp
80105b40:	c3                   	ret    

80105b41 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
80105b41:	55                   	push   %ebp
80105b42:	89 e5                	mov    %esp,%ebp
80105b44:	57                   	push   %edi
80105b45:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
80105b46:	8b 4d 08             	mov    0x8(%ebp),%ecx
80105b49:	8b 55 10             	mov    0x10(%ebp),%edx
80105b4c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b4f:	89 cb                	mov    %ecx,%ebx
80105b51:	89 df                	mov    %ebx,%edi
80105b53:	89 d1                	mov    %edx,%ecx
80105b55:	fc                   	cld    
80105b56:	f3 ab                	rep stos %eax,%es:(%edi)
80105b58:	89 ca                	mov    %ecx,%edx
80105b5a:	89 fb                	mov    %edi,%ebx
80105b5c:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105b5f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105b62:	5b                   	pop    %ebx
80105b63:	5f                   	pop    %edi
80105b64:	5d                   	pop    %ebp
80105b65:	c3                   	ret    

80105b66 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80105b66:	55                   	push   %ebp
80105b67:	89 e5                	mov    %esp,%ebp
80105b69:	83 ec 0c             	sub    $0xc,%esp
  if ((int)dst%4 == 0 && n%4 == 0){
80105b6c:	8b 45 08             	mov    0x8(%ebp),%eax
80105b6f:	83 e0 03             	and    $0x3,%eax
80105b72:	85 c0                	test   %eax,%eax
80105b74:	75 49                	jne    80105bbf <memset+0x59>
80105b76:	8b 45 10             	mov    0x10(%ebp),%eax
80105b79:	83 e0 03             	and    $0x3,%eax
80105b7c:	85 c0                	test   %eax,%eax
80105b7e:	75 3f                	jne    80105bbf <memset+0x59>
    c &= 0xFF;
80105b80:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105b87:	8b 45 10             	mov    0x10(%ebp),%eax
80105b8a:	c1 e8 02             	shr    $0x2,%eax
80105b8d:	89 c2                	mov    %eax,%edx
80105b8f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b92:	c1 e0 18             	shl    $0x18,%eax
80105b95:	89 c1                	mov    %eax,%ecx
80105b97:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b9a:	c1 e0 10             	shl    $0x10,%eax
80105b9d:	09 c1                	or     %eax,%ecx
80105b9f:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ba2:	c1 e0 08             	shl    $0x8,%eax
80105ba5:	09 c8                	or     %ecx,%eax
80105ba7:	0b 45 0c             	or     0xc(%ebp),%eax
80105baa:	89 54 24 08          	mov    %edx,0x8(%esp)
80105bae:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bb2:	8b 45 08             	mov    0x8(%ebp),%eax
80105bb5:	89 04 24             	mov    %eax,(%esp)
80105bb8:	e8 84 ff ff ff       	call   80105b41 <stosl>
80105bbd:	eb 19                	jmp    80105bd8 <memset+0x72>
  } else
    stosb(dst, c, n);
80105bbf:	8b 45 10             	mov    0x10(%ebp),%eax
80105bc2:	89 44 24 08          	mov    %eax,0x8(%esp)
80105bc6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bc9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105bcd:	8b 45 08             	mov    0x8(%ebp),%eax
80105bd0:	89 04 24             	mov    %eax,(%esp)
80105bd3:	e8 44 ff ff ff       	call   80105b1c <stosb>
  return dst;
80105bd8:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105bdb:	c9                   	leave  
80105bdc:	c3                   	ret    

80105bdd <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105bdd:	55                   	push   %ebp
80105bde:	89 e5                	mov    %esp,%ebp
80105be0:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
80105be3:	8b 45 08             	mov    0x8(%ebp),%eax
80105be6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105be9:	8b 45 0c             	mov    0xc(%ebp),%eax
80105bec:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105bef:	eb 2a                	jmp    80105c1b <memcmp+0x3e>
    if(*s1 != *s2)
80105bf1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105bf4:	8a 10                	mov    (%eax),%dl
80105bf6:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105bf9:	8a 00                	mov    (%eax),%al
80105bfb:	38 c2                	cmp    %al,%dl
80105bfd:	74 16                	je     80105c15 <memcmp+0x38>
      return *s1 - *s2;
80105bff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c02:	8a 00                	mov    (%eax),%al
80105c04:	0f b6 d0             	movzbl %al,%edx
80105c07:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c0a:	8a 00                	mov    (%eax),%al
80105c0c:	0f b6 c0             	movzbl %al,%eax
80105c0f:	29 c2                	sub    %eax,%edx
80105c11:	89 d0                	mov    %edx,%eax
80105c13:	eb 18                	jmp    80105c2d <memcmp+0x50>
    s1++, s2++;
80105c15:	ff 45 fc             	incl   -0x4(%ebp)
80105c18:	ff 45 f8             	incl   -0x8(%ebp)
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105c1b:	8b 45 10             	mov    0x10(%ebp),%eax
80105c1e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105c21:	89 55 10             	mov    %edx,0x10(%ebp)
80105c24:	85 c0                	test   %eax,%eax
80105c26:	75 c9                	jne    80105bf1 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105c28:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105c2d:	c9                   	leave  
80105c2e:	c3                   	ret    

80105c2f <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105c2f:	55                   	push   %ebp
80105c30:	89 e5                	mov    %esp,%ebp
80105c32:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105c35:	8b 45 0c             	mov    0xc(%ebp),%eax
80105c38:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105c3b:	8b 45 08             	mov    0x8(%ebp),%eax
80105c3e:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105c41:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c44:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105c47:	73 3a                	jae    80105c83 <memmove+0x54>
80105c49:	8b 45 10             	mov    0x10(%ebp),%eax
80105c4c:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105c4f:	01 d0                	add    %edx,%eax
80105c51:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105c54:	76 2d                	jbe    80105c83 <memmove+0x54>
    s += n;
80105c56:	8b 45 10             	mov    0x10(%ebp),%eax
80105c59:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105c5c:	8b 45 10             	mov    0x10(%ebp),%eax
80105c5f:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105c62:	eb 10                	jmp    80105c74 <memmove+0x45>
      *--d = *--s;
80105c64:	ff 4d f8             	decl   -0x8(%ebp)
80105c67:	ff 4d fc             	decl   -0x4(%ebp)
80105c6a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c6d:	8a 10                	mov    (%eax),%dl
80105c6f:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c72:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105c74:	8b 45 10             	mov    0x10(%ebp),%eax
80105c77:	8d 50 ff             	lea    -0x1(%eax),%edx
80105c7a:	89 55 10             	mov    %edx,0x10(%ebp)
80105c7d:	85 c0                	test   %eax,%eax
80105c7f:	75 e3                	jne    80105c64 <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105c81:	eb 25                	jmp    80105ca8 <memmove+0x79>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105c83:	eb 16                	jmp    80105c9b <memmove+0x6c>
      *d++ = *s++;
80105c85:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105c88:	8d 50 01             	lea    0x1(%eax),%edx
80105c8b:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105c8e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105c91:	8d 4a 01             	lea    0x1(%edx),%ecx
80105c94:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105c97:	8a 12                	mov    (%edx),%dl
80105c99:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105c9b:	8b 45 10             	mov    0x10(%ebp),%eax
80105c9e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105ca1:	89 55 10             	mov    %edx,0x10(%ebp)
80105ca4:	85 c0                	test   %eax,%eax
80105ca6:	75 dd                	jne    80105c85 <memmove+0x56>
      *d++ = *s++;

  return dst;
80105ca8:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105cab:	c9                   	leave  
80105cac:	c3                   	ret    

80105cad <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105cad:	55                   	push   %ebp
80105cae:	89 e5                	mov    %esp,%ebp
80105cb0:	83 ec 0c             	sub    $0xc,%esp
  return memmove(dst, src, n);
80105cb3:	8b 45 10             	mov    0x10(%ebp),%eax
80105cb6:	89 44 24 08          	mov    %eax,0x8(%esp)
80105cba:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cbd:	89 44 24 04          	mov    %eax,0x4(%esp)
80105cc1:	8b 45 08             	mov    0x8(%ebp),%eax
80105cc4:	89 04 24             	mov    %eax,(%esp)
80105cc7:	e8 63 ff ff ff       	call   80105c2f <memmove>
}
80105ccc:	c9                   	leave  
80105ccd:	c3                   	ret    

80105cce <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105cce:	55                   	push   %ebp
80105ccf:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105cd1:	eb 09                	jmp    80105cdc <strncmp+0xe>
    n--, p++, q++;
80105cd3:	ff 4d 10             	decl   0x10(%ebp)
80105cd6:	ff 45 08             	incl   0x8(%ebp)
80105cd9:	ff 45 0c             	incl   0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105cdc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ce0:	74 17                	je     80105cf9 <strncmp+0x2b>
80105ce2:	8b 45 08             	mov    0x8(%ebp),%eax
80105ce5:	8a 00                	mov    (%eax),%al
80105ce7:	84 c0                	test   %al,%al
80105ce9:	74 0e                	je     80105cf9 <strncmp+0x2b>
80105ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80105cee:	8a 10                	mov    (%eax),%dl
80105cf0:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cf3:	8a 00                	mov    (%eax),%al
80105cf5:	38 c2                	cmp    %al,%dl
80105cf7:	74 da                	je     80105cd3 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105cf9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105cfd:	75 07                	jne    80105d06 <strncmp+0x38>
    return 0;
80105cff:	b8 00 00 00 00       	mov    $0x0,%eax
80105d04:	eb 14                	jmp    80105d1a <strncmp+0x4c>
  return (uchar)*p - (uchar)*q;
80105d06:	8b 45 08             	mov    0x8(%ebp),%eax
80105d09:	8a 00                	mov    (%eax),%al
80105d0b:	0f b6 d0             	movzbl %al,%edx
80105d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d11:	8a 00                	mov    (%eax),%al
80105d13:	0f b6 c0             	movzbl %al,%eax
80105d16:	29 c2                	sub    %eax,%edx
80105d18:	89 d0                	mov    %edx,%eax
}
80105d1a:	5d                   	pop    %ebp
80105d1b:	c3                   	ret    

80105d1c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105d1c:	55                   	push   %ebp
80105d1d:	89 e5                	mov    %esp,%ebp
80105d1f:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105d22:	8b 45 08             	mov    0x8(%ebp),%eax
80105d25:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105d28:	90                   	nop
80105d29:	8b 45 10             	mov    0x10(%ebp),%eax
80105d2c:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d2f:	89 55 10             	mov    %edx,0x10(%ebp)
80105d32:	85 c0                	test   %eax,%eax
80105d34:	7e 1c                	jle    80105d52 <strncpy+0x36>
80105d36:	8b 45 08             	mov    0x8(%ebp),%eax
80105d39:	8d 50 01             	lea    0x1(%eax),%edx
80105d3c:	89 55 08             	mov    %edx,0x8(%ebp)
80105d3f:	8b 55 0c             	mov    0xc(%ebp),%edx
80105d42:	8d 4a 01             	lea    0x1(%edx),%ecx
80105d45:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105d48:	8a 12                	mov    (%edx),%dl
80105d4a:	88 10                	mov    %dl,(%eax)
80105d4c:	8a 00                	mov    (%eax),%al
80105d4e:	84 c0                	test   %al,%al
80105d50:	75 d7                	jne    80105d29 <strncpy+0xd>
    ;
  while(n-- > 0)
80105d52:	eb 0c                	jmp    80105d60 <strncpy+0x44>
    *s++ = 0;
80105d54:	8b 45 08             	mov    0x8(%ebp),%eax
80105d57:	8d 50 01             	lea    0x1(%eax),%edx
80105d5a:	89 55 08             	mov    %edx,0x8(%ebp)
80105d5d:	c6 00 00             	movb   $0x0,(%eax)
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105d60:	8b 45 10             	mov    0x10(%ebp),%eax
80105d63:	8d 50 ff             	lea    -0x1(%eax),%edx
80105d66:	89 55 10             	mov    %edx,0x10(%ebp)
80105d69:	85 c0                	test   %eax,%eax
80105d6b:	7f e7                	jg     80105d54 <strncpy+0x38>
    *s++ = 0;
  return os;
80105d6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105d70:	c9                   	leave  
80105d71:	c3                   	ret    

80105d72 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105d72:	55                   	push   %ebp
80105d73:	89 e5                	mov    %esp,%ebp
80105d75:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80105d78:	8b 45 08             	mov    0x8(%ebp),%eax
80105d7b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105d7e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105d82:	7f 05                	jg     80105d89 <safestrcpy+0x17>
    return os;
80105d84:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d87:	eb 2e                	jmp    80105db7 <safestrcpy+0x45>
  while(--n > 0 && (*s++ = *t++) != 0)
80105d89:	ff 4d 10             	decl   0x10(%ebp)
80105d8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105d90:	7e 1c                	jle    80105dae <safestrcpy+0x3c>
80105d92:	8b 45 08             	mov    0x8(%ebp),%eax
80105d95:	8d 50 01             	lea    0x1(%eax),%edx
80105d98:	89 55 08             	mov    %edx,0x8(%ebp)
80105d9b:	8b 55 0c             	mov    0xc(%ebp),%edx
80105d9e:	8d 4a 01             	lea    0x1(%edx),%ecx
80105da1:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105da4:	8a 12                	mov    (%edx),%dl
80105da6:	88 10                	mov    %dl,(%eax)
80105da8:	8a 00                	mov    (%eax),%al
80105daa:	84 c0                	test   %al,%al
80105dac:	75 db                	jne    80105d89 <safestrcpy+0x17>
    ;
  *s = 0;
80105dae:	8b 45 08             	mov    0x8(%ebp),%eax
80105db1:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105db4:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105db7:	c9                   	leave  
80105db8:	c3                   	ret    

80105db9 <strlen>:

int
strlen(const char *s)
{
80105db9:	55                   	push   %ebp
80105dba:	89 e5                	mov    %esp,%ebp
80105dbc:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105dbf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105dc6:	eb 03                	jmp    80105dcb <strlen+0x12>
80105dc8:	ff 45 fc             	incl   -0x4(%ebp)
80105dcb:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105dce:	8b 45 08             	mov    0x8(%ebp),%eax
80105dd1:	01 d0                	add    %edx,%eax
80105dd3:	8a 00                	mov    (%eax),%al
80105dd5:	84 c0                	test   %al,%al
80105dd7:	75 ef                	jne    80105dc8 <strlen+0xf>
    ;
  return n;
80105dd9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105ddc:	c9                   	leave  
80105ddd:	c3                   	ret    
	...

80105de0 <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105de0:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105de4:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105de8:	55                   	push   %ebp
  pushl %ebx
80105de9:	53                   	push   %ebx
  pushl %esi
80105dea:	56                   	push   %esi
  pushl %edi
80105deb:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105dec:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105dee:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105df0:	5f                   	pop    %edi
  popl %esi
80105df1:	5e                   	pop    %esi
  popl %ebx
80105df2:	5b                   	pop    %ebx
  popl %ebp
80105df3:	5d                   	pop    %ebp
  ret
80105df4:	c3                   	ret    
80105df5:	00 00                	add    %al,(%eax)
	...

80105df8 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105df8:	55                   	push   %ebp
80105df9:	89 e5                	mov    %esp,%ebp
80105dfb:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80105dfe:	e8 49 e4 ff ff       	call   8010424c <myproc>
80105e03:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80105e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e09:	8b 00                	mov    (%eax),%eax
80105e0b:	3b 45 08             	cmp    0x8(%ebp),%eax
80105e0e:	76 0f                	jbe    80105e1f <fetchint+0x27>
80105e10:	8b 45 08             	mov    0x8(%ebp),%eax
80105e13:	8d 50 04             	lea    0x4(%eax),%edx
80105e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e19:	8b 00                	mov    (%eax),%eax
80105e1b:	39 c2                	cmp    %eax,%edx
80105e1d:	76 07                	jbe    80105e26 <fetchint+0x2e>
    return -1;
80105e1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e24:	eb 0f                	jmp    80105e35 <fetchint+0x3d>
  *ip = *(int*)(addr);
80105e26:	8b 45 08             	mov    0x8(%ebp),%eax
80105e29:	8b 10                	mov    (%eax),%edx
80105e2b:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e2e:	89 10                	mov    %edx,(%eax)
  return 0;
80105e30:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105e35:	c9                   	leave  
80105e36:	c3                   	ret    

80105e37 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105e37:	55                   	push   %ebp
80105e38:	89 e5                	mov    %esp,%ebp
80105e3a:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80105e3d:	e8 0a e4 ff ff       	call   8010424c <myproc>
80105e42:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80105e45:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e48:	8b 00                	mov    (%eax),%eax
80105e4a:	3b 45 08             	cmp    0x8(%ebp),%eax
80105e4d:	77 07                	ja     80105e56 <fetchstr+0x1f>
    return -1;
80105e4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e54:	eb 41                	jmp    80105e97 <fetchstr+0x60>
  *pp = (char*)addr;
80105e56:	8b 55 08             	mov    0x8(%ebp),%edx
80105e59:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e5c:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80105e5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e61:	8b 00                	mov    (%eax),%eax
80105e63:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80105e66:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e69:	8b 00                	mov    (%eax),%eax
80105e6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105e6e:	eb 1a                	jmp    80105e8a <fetchstr+0x53>
    if(*s == 0)
80105e70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e73:	8a 00                	mov    (%eax),%al
80105e75:	84 c0                	test   %al,%al
80105e77:	75 0e                	jne    80105e87 <fetchstr+0x50>
      return s - *pp;
80105e79:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105e7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80105e7f:	8b 00                	mov    (%eax),%eax
80105e81:	29 c2                	sub    %eax,%edx
80105e83:	89 d0                	mov    %edx,%eax
80105e85:	eb 10                	jmp    80105e97 <fetchstr+0x60>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
80105e87:	ff 45 f4             	incl   -0xc(%ebp)
80105e8a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e8d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80105e90:	72 de                	jb     80105e70 <fetchstr+0x39>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
80105e92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e97:	c9                   	leave  
80105e98:	c3                   	ret    

80105e99 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105e99:	55                   	push   %ebp
80105e9a:	89 e5                	mov    %esp,%ebp
80105e9c:	83 ec 18             	sub    $0x18,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80105e9f:	e8 a8 e3 ff ff       	call   8010424c <myproc>
80105ea4:	8b 40 18             	mov    0x18(%eax),%eax
80105ea7:	8b 50 44             	mov    0x44(%eax),%edx
80105eaa:	8b 45 08             	mov    0x8(%ebp),%eax
80105ead:	c1 e0 02             	shl    $0x2,%eax
80105eb0:	01 d0                	add    %edx,%eax
80105eb2:	8d 50 04             	lea    0x4(%eax),%edx
80105eb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80105eb8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ebc:	89 14 24             	mov    %edx,(%esp)
80105ebf:	e8 34 ff ff ff       	call   80105df8 <fetchint>
}
80105ec4:	c9                   	leave  
80105ec5:	c3                   	ret    

80105ec6 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105ec6:	55                   	push   %ebp
80105ec7:	89 e5                	mov    %esp,%ebp
80105ec9:	83 ec 28             	sub    $0x28,%esp
  int i;
  struct proc *curproc = myproc();
80105ecc:	e8 7b e3 ff ff       	call   8010424c <myproc>
80105ed1:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80105ed4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ed7:	89 44 24 04          	mov    %eax,0x4(%esp)
80105edb:	8b 45 08             	mov    0x8(%ebp),%eax
80105ede:	89 04 24             	mov    %eax,(%esp)
80105ee1:	e8 b3 ff ff ff       	call   80105e99 <argint>
80105ee6:	85 c0                	test   %eax,%eax
80105ee8:	79 07                	jns    80105ef1 <argptr+0x2b>
    return -1;
80105eea:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eef:	eb 3d                	jmp    80105f2e <argptr+0x68>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80105ef1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ef5:	78 21                	js     80105f18 <argptr+0x52>
80105ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105efa:	89 c2                	mov    %eax,%edx
80105efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105eff:	8b 00                	mov    (%eax),%eax
80105f01:	39 c2                	cmp    %eax,%edx
80105f03:	73 13                	jae    80105f18 <argptr+0x52>
80105f05:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f08:	89 c2                	mov    %eax,%edx
80105f0a:	8b 45 10             	mov    0x10(%ebp),%eax
80105f0d:	01 c2                	add    %eax,%edx
80105f0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f12:	8b 00                	mov    (%eax),%eax
80105f14:	39 c2                	cmp    %eax,%edx
80105f16:	76 07                	jbe    80105f1f <argptr+0x59>
    return -1;
80105f18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f1d:	eb 0f                	jmp    80105f2e <argptr+0x68>
  *pp = (char*)i;
80105f1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f22:	89 c2                	mov    %eax,%edx
80105f24:	8b 45 0c             	mov    0xc(%ebp),%eax
80105f27:	89 10                	mov    %edx,(%eax)
  return 0;
80105f29:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105f2e:	c9                   	leave  
80105f2f:	c3                   	ret    

80105f30 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105f30:	55                   	push   %ebp
80105f31:	89 e5                	mov    %esp,%ebp
80105f33:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105f36:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f39:	89 44 24 04          	mov    %eax,0x4(%esp)
80105f3d:	8b 45 08             	mov    0x8(%ebp),%eax
80105f40:	89 04 24             	mov    %eax,(%esp)
80105f43:	e8 51 ff ff ff       	call   80105e99 <argint>
80105f48:	85 c0                	test   %eax,%eax
80105f4a:	79 07                	jns    80105f53 <argstr+0x23>
    return -1;
80105f4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f51:	eb 12                	jmp    80105f65 <argstr+0x35>
  return fetchstr(addr, pp);
80105f53:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f56:	8b 55 0c             	mov    0xc(%ebp),%edx
80105f59:	89 54 24 04          	mov    %edx,0x4(%esp)
80105f5d:	89 04 24             	mov    %eax,(%esp)
80105f60:	e8 d2 fe ff ff       	call   80105e37 <fetchstr>
}
80105f65:	c9                   	leave  
80105f66:	c3                   	ret    

80105f67 <syscall>:
[SYS_cinfo] sys_cinfo,
};

void
syscall(void)
{
80105f67:	55                   	push   %ebp
80105f68:	89 e5                	mov    %esp,%ebp
80105f6a:	53                   	push   %ebx
80105f6b:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
80105f6e:	e8 d9 e2 ff ff       	call   8010424c <myproc>
80105f73:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80105f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f79:	8b 40 18             	mov    0x18(%eax),%eax
80105f7c:	8b 40 1c             	mov    0x1c(%eax),%eax
80105f7f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105f82:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f86:	7e 2d                	jle    80105fb5 <syscall+0x4e>
80105f88:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f8b:	83 f8 1b             	cmp    $0x1b,%eax
80105f8e:	77 25                	ja     80105fb5 <syscall+0x4e>
80105f90:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f93:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105f9a:	85 c0                	test   %eax,%eax
80105f9c:	74 17                	je     80105fb5 <syscall+0x4e>
    curproc->tf->eax = syscalls[num]();
80105f9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa1:	8b 58 18             	mov    0x18(%eax),%ebx
80105fa4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa7:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105fae:	ff d0                	call   *%eax
80105fb0:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105fb3:	eb 34                	jmp    80105fe9 <syscall+0x82>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80105fb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fb8:	8d 48 6c             	lea    0x6c(%eax),%ecx

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fbe:	8b 40 10             	mov    0x10(%eax),%eax
80105fc1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105fc4:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105fc8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105fcc:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fd0:	c7 04 24 9c 98 10 80 	movl   $0x8010989c,(%esp)
80105fd7:	e8 e5 a3 ff ff       	call   801003c1 <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80105fdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fdf:	8b 40 18             	mov    0x18(%eax),%eax
80105fe2:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105fe9:	83 c4 24             	add    $0x24,%esp
80105fec:	5b                   	pop    %ebx
80105fed:	5d                   	pop    %ebp
80105fee:	c3                   	ret    
	...

80105ff0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105ff0:	55                   	push   %ebp
80105ff1:	89 e5                	mov    %esp,%ebp
80105ff3:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105ff6:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ff9:	89 44 24 04          	mov    %eax,0x4(%esp)
80105ffd:	8b 45 08             	mov    0x8(%ebp),%eax
80106000:	89 04 24             	mov    %eax,(%esp)
80106003:	e8 91 fe ff ff       	call   80105e99 <argint>
80106008:	85 c0                	test   %eax,%eax
8010600a:	79 07                	jns    80106013 <argfd+0x23>
    return -1;
8010600c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106011:	eb 4f                	jmp    80106062 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80106013:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106016:	85 c0                	test   %eax,%eax
80106018:	78 20                	js     8010603a <argfd+0x4a>
8010601a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010601d:	83 f8 0f             	cmp    $0xf,%eax
80106020:	7f 18                	jg     8010603a <argfd+0x4a>
80106022:	e8 25 e2 ff ff       	call   8010424c <myproc>
80106027:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010602a:	83 c2 08             	add    $0x8,%edx
8010602d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106031:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106034:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106038:	75 07                	jne    80106041 <argfd+0x51>
    return -1;
8010603a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010603f:	eb 21                	jmp    80106062 <argfd+0x72>
  if(pfd)
80106041:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80106045:	74 08                	je     8010604f <argfd+0x5f>
    *pfd = fd;
80106047:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010604a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010604d:	89 10                	mov    %edx,(%eax)
  if(pf)
8010604f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80106053:	74 08                	je     8010605d <argfd+0x6d>
    *pf = f;
80106055:	8b 45 10             	mov    0x10(%ebp),%eax
80106058:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010605b:	89 10                	mov    %edx,(%eax)
  return 0;
8010605d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106062:	c9                   	leave  
80106063:	c3                   	ret    

80106064 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80106064:	55                   	push   %ebp
80106065:	89 e5                	mov    %esp,%ebp
80106067:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
8010606a:	e8 dd e1 ff ff       	call   8010424c <myproc>
8010606f:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80106072:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106079:	eb 29                	jmp    801060a4 <fdalloc+0x40>
    if(curproc->ofile[fd] == 0){
8010607b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010607e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106081:	83 c2 08             	add    $0x8,%edx
80106084:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80106088:	85 c0                	test   %eax,%eax
8010608a:	75 15                	jne    801060a1 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
8010608c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010608f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106092:	8d 4a 08             	lea    0x8(%edx),%ecx
80106095:	8b 55 08             	mov    0x8(%ebp),%edx
80106098:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
8010609c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010609f:	eb 0e                	jmp    801060af <fdalloc+0x4b>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
801060a1:	ff 45 f4             	incl   -0xc(%ebp)
801060a4:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801060a8:	7e d1                	jle    8010607b <fdalloc+0x17>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
801060aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801060af:	c9                   	leave  
801060b0:	c3                   	ret    

801060b1 <sys_dup>:

int
sys_dup(void)
{
801060b1:	55                   	push   %ebp
801060b2:	89 e5                	mov    %esp,%ebp
801060b4:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
801060b7:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060ba:	89 44 24 08          	mov    %eax,0x8(%esp)
801060be:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801060c5:	00 
801060c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801060cd:	e8 1e ff ff ff       	call   80105ff0 <argfd>
801060d2:	85 c0                	test   %eax,%eax
801060d4:	79 07                	jns    801060dd <sys_dup+0x2c>
    return -1;
801060d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060db:	eb 29                	jmp    80106106 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
801060dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060e0:	89 04 24             	mov    %eax,(%esp)
801060e3:	e8 7c ff ff ff       	call   80106064 <fdalloc>
801060e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
801060eb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801060ef:	79 07                	jns    801060f8 <sys_dup+0x47>
    return -1;
801060f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060f6:	eb 0e                	jmp    80106106 <sys_dup+0x55>
  filedup(f);
801060f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801060fb:	89 04 24             	mov    %eax,(%esp)
801060fe:	e8 c1 af ff ff       	call   801010c4 <filedup>
  return fd;
80106103:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106106:	c9                   	leave  
80106107:	c3                   	ret    

80106108 <sys_read>:

int
sys_read(void)
{
80106108:	55                   	push   %ebp
80106109:	89 e5                	mov    %esp,%ebp
8010610b:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010610e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106111:	89 44 24 08          	mov    %eax,0x8(%esp)
80106115:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010611c:	00 
8010611d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106124:	e8 c7 fe ff ff       	call   80105ff0 <argfd>
80106129:	85 c0                	test   %eax,%eax
8010612b:	78 35                	js     80106162 <sys_read+0x5a>
8010612d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106130:	89 44 24 04          	mov    %eax,0x4(%esp)
80106134:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
8010613b:	e8 59 fd ff ff       	call   80105e99 <argint>
80106140:	85 c0                	test   %eax,%eax
80106142:	78 1e                	js     80106162 <sys_read+0x5a>
80106144:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106147:	89 44 24 08          	mov    %eax,0x8(%esp)
8010614b:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010614e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106152:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106159:	e8 68 fd ff ff       	call   80105ec6 <argptr>
8010615e:	85 c0                	test   %eax,%eax
80106160:	79 07                	jns    80106169 <sys_read+0x61>
    return -1;
80106162:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106167:	eb 19                	jmp    80106182 <sys_read+0x7a>
  return fileread(f, p, n);
80106169:	8b 4d f0             	mov    -0x10(%ebp),%ecx
8010616c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010616f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106172:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80106176:	89 54 24 04          	mov    %edx,0x4(%esp)
8010617a:	89 04 24             	mov    %eax,(%esp)
8010617d:	e8 a3 b0 ff ff       	call   80101225 <fileread>
}
80106182:	c9                   	leave  
80106183:	c3                   	ret    

80106184 <sys_write>:

int
sys_write(void)
{
80106184:	55                   	push   %ebp
80106185:	89 e5                	mov    %esp,%ebp
80106187:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010618a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010618d:	89 44 24 08          	mov    %eax,0x8(%esp)
80106191:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106198:	00 
80106199:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801061a0:	e8 4b fe ff ff       	call   80105ff0 <argfd>
801061a5:	85 c0                	test   %eax,%eax
801061a7:	78 35                	js     801061de <sys_write+0x5a>
801061a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801061ac:	89 44 24 04          	mov    %eax,0x4(%esp)
801061b0:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801061b7:	e8 dd fc ff ff       	call   80105e99 <argint>
801061bc:	85 c0                	test   %eax,%eax
801061be:	78 1e                	js     801061de <sys_write+0x5a>
801061c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061c3:	89 44 24 08          	mov    %eax,0x8(%esp)
801061c7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801061ca:	89 44 24 04          	mov    %eax,0x4(%esp)
801061ce:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801061d5:	e8 ec fc ff ff       	call   80105ec6 <argptr>
801061da:	85 c0                	test   %eax,%eax
801061dc:	79 07                	jns    801061e5 <sys_write+0x61>
    return -1;
801061de:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061e3:	eb 19                	jmp    801061fe <sys_write+0x7a>
  return filewrite(f, p, n);
801061e5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801061e8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801061eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061ee:	89 4c 24 08          	mov    %ecx,0x8(%esp)
801061f2:	89 54 24 04          	mov    %edx,0x4(%esp)
801061f6:	89 04 24             	mov    %eax,(%esp)
801061f9:	e8 e2 b0 ff ff       	call   801012e0 <filewrite>
}
801061fe:	c9                   	leave  
801061ff:	c3                   	ret    

80106200 <sys_close>:

int
sys_close(void)
{
80106200:	55                   	push   %ebp
80106201:	89 e5                	mov    %esp,%ebp
80106203:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80106206:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106209:	89 44 24 08          	mov    %eax,0x8(%esp)
8010620d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106210:	89 44 24 04          	mov    %eax,0x4(%esp)
80106214:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010621b:	e8 d0 fd ff ff       	call   80105ff0 <argfd>
80106220:	85 c0                	test   %eax,%eax
80106222:	79 07                	jns    8010622b <sys_close+0x2b>
    return -1;
80106224:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106229:	eb 23                	jmp    8010624e <sys_close+0x4e>
  myproc()->ofile[fd] = 0;
8010622b:	e8 1c e0 ff ff       	call   8010424c <myproc>
80106230:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106233:	83 c2 08             	add    $0x8,%edx
80106236:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
8010623d:	00 
  fileclose(f);
8010623e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106241:	89 04 24             	mov    %eax,(%esp)
80106244:	e8 c3 ae ff ff       	call   8010110c <fileclose>
  return 0;
80106249:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010624e:	c9                   	leave  
8010624f:	c3                   	ret    

80106250 <sys_fstat>:

int
sys_fstat(void)
{
80106250:	55                   	push   %ebp
80106251:	89 e5                	mov    %esp,%ebp
80106253:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80106256:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106259:	89 44 24 08          	mov    %eax,0x8(%esp)
8010625d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106264:	00 
80106265:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010626c:	e8 7f fd ff ff       	call   80105ff0 <argfd>
80106271:	85 c0                	test   %eax,%eax
80106273:	78 1f                	js     80106294 <sys_fstat+0x44>
80106275:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
8010627c:	00 
8010627d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106280:	89 44 24 04          	mov    %eax,0x4(%esp)
80106284:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010628b:	e8 36 fc ff ff       	call   80105ec6 <argptr>
80106290:	85 c0                	test   %eax,%eax
80106292:	79 07                	jns    8010629b <sys_fstat+0x4b>
    return -1;
80106294:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106299:	eb 12                	jmp    801062ad <sys_fstat+0x5d>
  return filestat(f, st);
8010629b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010629e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062a1:	89 54 24 04          	mov    %edx,0x4(%esp)
801062a5:	89 04 24             	mov    %eax,(%esp)
801062a8:	e8 29 af ff ff       	call   801011d6 <filestat>
}
801062ad:	c9                   	leave  
801062ae:	c3                   	ret    

801062af <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801062af:	55                   	push   %ebp
801062b0:	89 e5                	mov    %esp,%ebp
801062b2:	83 ec 38             	sub    $0x38,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801062b5:	8d 45 d8             	lea    -0x28(%ebp),%eax
801062b8:	89 44 24 04          	mov    %eax,0x4(%esp)
801062bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801062c3:	e8 68 fc ff ff       	call   80105f30 <argstr>
801062c8:	85 c0                	test   %eax,%eax
801062ca:	78 17                	js     801062e3 <sys_link+0x34>
801062cc:	8d 45 dc             	lea    -0x24(%ebp),%eax
801062cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801062d3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801062da:	e8 51 fc ff ff       	call   80105f30 <argstr>
801062df:	85 c0                	test   %eax,%eax
801062e1:	79 0a                	jns    801062ed <sys_link+0x3e>
    return -1;
801062e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e8:	e9 3d 01 00 00       	jmp    8010642a <sys_link+0x17b>

  begin_op();
801062ed:	e8 5d d3 ff ff       	call   8010364f <begin_op>
  if((ip = namei(old)) == 0){
801062f2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801062f5:	89 04 24             	mov    %eax,(%esp)
801062f8:	e8 7f c3 ff ff       	call   8010267c <namei>
801062fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106300:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106304:	75 0f                	jne    80106315 <sys_link+0x66>
    end_op();
80106306:	e8 c6 d3 ff ff       	call   801036d1 <end_op>
    return -1;
8010630b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106310:	e9 15 01 00 00       	jmp    8010642a <sys_link+0x17b>
  }

  ilock(ip);
80106315:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106318:	89 04 24             	mov    %eax,(%esp)
8010631b:	e8 06 b7 ff ff       	call   80101a26 <ilock>
  if(ip->type == T_DIR){
80106320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106323:	8b 40 50             	mov    0x50(%eax),%eax
80106326:	66 83 f8 01          	cmp    $0x1,%ax
8010632a:	75 1a                	jne    80106346 <sys_link+0x97>
    iunlockput(ip);
8010632c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010632f:	89 04 24             	mov    %eax,(%esp)
80106332:	e8 ee b8 ff ff       	call   80101c25 <iunlockput>
    end_op();
80106337:	e8 95 d3 ff ff       	call   801036d1 <end_op>
    return -1;
8010633c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106341:	e9 e4 00 00 00       	jmp    8010642a <sys_link+0x17b>
  }

  ip->nlink++;
80106346:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106349:	66 8b 40 56          	mov    0x56(%eax),%ax
8010634d:	40                   	inc    %eax
8010634e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106351:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80106355:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106358:	89 04 24             	mov    %eax,(%esp)
8010635b:	e8 03 b5 ff ff       	call   80101863 <iupdate>
  iunlock(ip);
80106360:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106363:	89 04 24             	mov    %eax,(%esp)
80106366:	e8 c5 b7 ff ff       	call   80101b30 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
8010636b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010636e:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80106371:	89 54 24 04          	mov    %edx,0x4(%esp)
80106375:	89 04 24             	mov    %eax,(%esp)
80106378:	e8 21 c3 ff ff       	call   8010269e <nameiparent>
8010637d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106384:	75 02                	jne    80106388 <sys_link+0xd9>
    goto bad;
80106386:	eb 68                	jmp    801063f0 <sys_link+0x141>
  ilock(dp);
80106388:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010638b:	89 04 24             	mov    %eax,(%esp)
8010638e:	e8 93 b6 ff ff       	call   80101a26 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80106393:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106396:	8b 10                	mov    (%eax),%edx
80106398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010639b:	8b 00                	mov    (%eax),%eax
8010639d:	39 c2                	cmp    %eax,%edx
8010639f:	75 20                	jne    801063c1 <sys_link+0x112>
801063a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a4:	8b 40 04             	mov    0x4(%eax),%eax
801063a7:	89 44 24 08          	mov    %eax,0x8(%esp)
801063ab:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801063ae:	89 44 24 04          	mov    %eax,0x4(%esp)
801063b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063b5:	89 04 24             	mov    %eax,(%esp)
801063b8:	e8 db be ff ff       	call   80102298 <dirlink>
801063bd:	85 c0                	test   %eax,%eax
801063bf:	79 0d                	jns    801063ce <sys_link+0x11f>
    iunlockput(dp);
801063c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063c4:	89 04 24             	mov    %eax,(%esp)
801063c7:	e8 59 b8 ff ff       	call   80101c25 <iunlockput>
    goto bad;
801063cc:	eb 22                	jmp    801063f0 <sys_link+0x141>
  }
  iunlockput(dp);
801063ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d1:	89 04 24             	mov    %eax,(%esp)
801063d4:	e8 4c b8 ff ff       	call   80101c25 <iunlockput>
  iput(ip);
801063d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063dc:	89 04 24             	mov    %eax,(%esp)
801063df:	e8 90 b7 ff ff       	call   80101b74 <iput>

  end_op();
801063e4:	e8 e8 d2 ff ff       	call   801036d1 <end_op>

  return 0;
801063e9:	b8 00 00 00 00       	mov    $0x0,%eax
801063ee:	eb 3a                	jmp    8010642a <sys_link+0x17b>

bad:
  ilock(ip);
801063f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063f3:	89 04 24             	mov    %eax,(%esp)
801063f6:	e8 2b b6 ff ff       	call   80101a26 <ilock>
  ip->nlink--;
801063fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063fe:	66 8b 40 56          	mov    0x56(%eax),%ax
80106402:	48                   	dec    %eax
80106403:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106406:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
8010640a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010640d:	89 04 24             	mov    %eax,(%esp)
80106410:	e8 4e b4 ff ff       	call   80101863 <iupdate>
  iunlockput(ip);
80106415:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106418:	89 04 24             	mov    %eax,(%esp)
8010641b:	e8 05 b8 ff ff       	call   80101c25 <iunlockput>
  end_op();
80106420:	e8 ac d2 ff ff       	call   801036d1 <end_op>
  return -1;
80106425:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010642a:	c9                   	leave  
8010642b:	c3                   	ret    

8010642c <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010642c:	55                   	push   %ebp
8010642d:	89 e5                	mov    %esp,%ebp
8010642f:	83 ec 38             	sub    $0x38,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106432:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80106439:	eb 4a                	jmp    80106485 <isdirempty+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010643b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010643e:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80106445:	00 
80106446:	89 44 24 08          	mov    %eax,0x8(%esp)
8010644a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010644d:	89 44 24 04          	mov    %eax,0x4(%esp)
80106451:	8b 45 08             	mov    0x8(%ebp),%eax
80106454:	89 04 24             	mov    %eax,(%esp)
80106457:	e8 61 ba ff ff       	call   80101ebd <readi>
8010645c:	83 f8 10             	cmp    $0x10,%eax
8010645f:	74 0c                	je     8010646d <isdirempty+0x41>
      panic("isdirempty: readi");
80106461:	c7 04 24 b8 98 10 80 	movl   $0x801098b8,(%esp)
80106468:	e8 e7 a0 ff ff       	call   80100554 <panic>
    if(de.inum != 0)
8010646d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106470:	66 85 c0             	test   %ax,%ax
80106473:	74 07                	je     8010647c <isdirempty+0x50>
      return 0;
80106475:	b8 00 00 00 00       	mov    $0x0,%eax
8010647a:	eb 1b                	jmp    80106497 <isdirempty+0x6b>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010647c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010647f:	83 c0 10             	add    $0x10,%eax
80106482:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106485:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106488:	8b 45 08             	mov    0x8(%ebp),%eax
8010648b:	8b 40 58             	mov    0x58(%eax),%eax
8010648e:	39 c2                	cmp    %eax,%edx
80106490:	72 a9                	jb     8010643b <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80106492:	b8 01 00 00 00       	mov    $0x1,%eax
}
80106497:	c9                   	leave  
80106498:	c3                   	ret    

80106499 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80106499:	55                   	push   %ebp
8010649a:	89 e5                	mov    %esp,%ebp
8010649c:	83 ec 48             	sub    $0x48,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010649f:	8d 45 cc             	lea    -0x34(%ebp),%eax
801064a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801064a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801064ad:	e8 7e fa ff ff       	call   80105f30 <argstr>
801064b2:	85 c0                	test   %eax,%eax
801064b4:	79 0a                	jns    801064c0 <sys_unlink+0x27>
    return -1;
801064b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064bb:	e9 a9 01 00 00       	jmp    80106669 <sys_unlink+0x1d0>

  begin_op();
801064c0:	e8 8a d1 ff ff       	call   8010364f <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801064c5:	8b 45 cc             	mov    -0x34(%ebp),%eax
801064c8:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801064cb:	89 54 24 04          	mov    %edx,0x4(%esp)
801064cf:	89 04 24             	mov    %eax,(%esp)
801064d2:	e8 c7 c1 ff ff       	call   8010269e <nameiparent>
801064d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
801064da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801064de:	75 0f                	jne    801064ef <sys_unlink+0x56>
    end_op();
801064e0:	e8 ec d1 ff ff       	call   801036d1 <end_op>
    return -1;
801064e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ea:	e9 7a 01 00 00       	jmp    80106669 <sys_unlink+0x1d0>
  }

  ilock(dp);
801064ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064f2:	89 04 24             	mov    %eax,(%esp)
801064f5:	e8 2c b5 ff ff       	call   80101a26 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801064fa:	c7 44 24 04 ca 98 10 	movl   $0x801098ca,0x4(%esp)
80106501:	80 
80106502:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106505:	89 04 24             	mov    %eax,(%esp)
80106508:	e8 a3 bc ff ff       	call   801021b0 <namecmp>
8010650d:	85 c0                	test   %eax,%eax
8010650f:	0f 84 3f 01 00 00    	je     80106654 <sys_unlink+0x1bb>
80106515:	c7 44 24 04 cc 98 10 	movl   $0x801098cc,0x4(%esp)
8010651c:	80 
8010651d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106520:	89 04 24             	mov    %eax,(%esp)
80106523:	e8 88 bc ff ff       	call   801021b0 <namecmp>
80106528:	85 c0                	test   %eax,%eax
8010652a:	0f 84 24 01 00 00    	je     80106654 <sys_unlink+0x1bb>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80106530:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106533:	89 44 24 08          	mov    %eax,0x8(%esp)
80106537:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010653a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010653e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106541:	89 04 24             	mov    %eax,(%esp)
80106544:	e8 89 bc ff ff       	call   801021d2 <dirlookup>
80106549:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010654c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106550:	75 05                	jne    80106557 <sys_unlink+0xbe>
    goto bad;
80106552:	e9 fd 00 00 00       	jmp    80106654 <sys_unlink+0x1bb>
  ilock(ip);
80106557:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010655a:	89 04 24             	mov    %eax,(%esp)
8010655d:	e8 c4 b4 ff ff       	call   80101a26 <ilock>

  if(ip->nlink < 1)
80106562:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106565:	66 8b 40 56          	mov    0x56(%eax),%ax
80106569:	66 85 c0             	test   %ax,%ax
8010656c:	7f 0c                	jg     8010657a <sys_unlink+0xe1>
    panic("unlink: nlink < 1");
8010656e:	c7 04 24 cf 98 10 80 	movl   $0x801098cf,(%esp)
80106575:	e8 da 9f ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010657a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010657d:	8b 40 50             	mov    0x50(%eax),%eax
80106580:	66 83 f8 01          	cmp    $0x1,%ax
80106584:	75 1f                	jne    801065a5 <sys_unlink+0x10c>
80106586:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106589:	89 04 24             	mov    %eax,(%esp)
8010658c:	e8 9b fe ff ff       	call   8010642c <isdirempty>
80106591:	85 c0                	test   %eax,%eax
80106593:	75 10                	jne    801065a5 <sys_unlink+0x10c>
    iunlockput(ip);
80106595:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106598:	89 04 24             	mov    %eax,(%esp)
8010659b:	e8 85 b6 ff ff       	call   80101c25 <iunlockput>
    goto bad;
801065a0:	e9 af 00 00 00       	jmp    80106654 <sys_unlink+0x1bb>
  }

  memset(&de, 0, sizeof(de));
801065a5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801065ac:	00 
801065ad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801065b4:	00 
801065b5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801065b8:	89 04 24             	mov    %eax,(%esp)
801065bb:	e8 a6 f5 ff ff       	call   80105b66 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801065c0:	8b 45 c8             	mov    -0x38(%ebp),%eax
801065c3:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
801065ca:	00 
801065cb:	89 44 24 08          	mov    %eax,0x8(%esp)
801065cf:	8d 45 e0             	lea    -0x20(%ebp),%eax
801065d2:	89 44 24 04          	mov    %eax,0x4(%esp)
801065d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801065d9:	89 04 24             	mov    %eax,(%esp)
801065dc:	e8 40 ba ff ff       	call   80102021 <writei>
801065e1:	83 f8 10             	cmp    $0x10,%eax
801065e4:	74 0c                	je     801065f2 <sys_unlink+0x159>
    panic("unlink: writei");
801065e6:	c7 04 24 e1 98 10 80 	movl   $0x801098e1,(%esp)
801065ed:	e8 62 9f ff ff       	call   80100554 <panic>
  if(ip->type == T_DIR){
801065f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065f5:	8b 40 50             	mov    0x50(%eax),%eax
801065f8:	66 83 f8 01          	cmp    $0x1,%ax
801065fc:	75 1a                	jne    80106618 <sys_unlink+0x17f>
    dp->nlink--;
801065fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106601:	66 8b 40 56          	mov    0x56(%eax),%ax
80106605:	48                   	dec    %eax
80106606:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106609:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
8010660d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106610:	89 04 24             	mov    %eax,(%esp)
80106613:	e8 4b b2 ff ff       	call   80101863 <iupdate>
  }
  iunlockput(dp);
80106618:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010661b:	89 04 24             	mov    %eax,(%esp)
8010661e:	e8 02 b6 ff ff       	call   80101c25 <iunlockput>

  ip->nlink--;
80106623:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106626:	66 8b 40 56          	mov    0x56(%eax),%ax
8010662a:	48                   	dec    %eax
8010662b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010662e:	66 89 42 56          	mov    %ax,0x56(%edx)
  iupdate(ip);
80106632:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106635:	89 04 24             	mov    %eax,(%esp)
80106638:	e8 26 b2 ff ff       	call   80101863 <iupdate>
  iunlockput(ip);
8010663d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106640:	89 04 24             	mov    %eax,(%esp)
80106643:	e8 dd b5 ff ff       	call   80101c25 <iunlockput>

  end_op();
80106648:	e8 84 d0 ff ff       	call   801036d1 <end_op>

  return 0;
8010664d:	b8 00 00 00 00       	mov    $0x0,%eax
80106652:	eb 15                	jmp    80106669 <sys_unlink+0x1d0>

bad:
  iunlockput(dp);
80106654:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106657:	89 04 24             	mov    %eax,(%esp)
8010665a:	e8 c6 b5 ff ff       	call   80101c25 <iunlockput>
  end_op();
8010665f:	e8 6d d0 ff ff       	call   801036d1 <end_op>
  return -1;
80106664:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106669:	c9                   	leave  
8010666a:	c3                   	ret    

8010666b <create>:

struct inode*
create(char *path, short type, short major, short minor)
{
8010666b:	55                   	push   %ebp
8010666c:	89 e5                	mov    %esp,%ebp
8010666e:	83 ec 48             	sub    $0x48,%esp
80106671:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80106674:	8b 55 10             	mov    0x10(%ebp),%edx
80106677:	8b 45 14             	mov    0x14(%ebp),%eax
8010667a:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010667e:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80106682:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80106686:	8d 45 de             	lea    -0x22(%ebp),%eax
80106689:	89 44 24 04          	mov    %eax,0x4(%esp)
8010668d:	8b 45 08             	mov    0x8(%ebp),%eax
80106690:	89 04 24             	mov    %eax,(%esp)
80106693:	e8 06 c0 ff ff       	call   8010269e <nameiparent>
80106698:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010669b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010669f:	75 0a                	jne    801066ab <create+0x40>
    return 0;
801066a1:	b8 00 00 00 00       	mov    $0x0,%eax
801066a6:	e9 79 01 00 00       	jmp    80106824 <create+0x1b9>
  ilock(dp);
801066ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066ae:	89 04 24             	mov    %eax,(%esp)
801066b1:	e8 70 b3 ff ff       	call   80101a26 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
801066b6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801066b9:	89 44 24 08          	mov    %eax,0x8(%esp)
801066bd:	8d 45 de             	lea    -0x22(%ebp),%eax
801066c0:	89 44 24 04          	mov    %eax,0x4(%esp)
801066c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066c7:	89 04 24             	mov    %eax,(%esp)
801066ca:	e8 03 bb ff ff       	call   801021d2 <dirlookup>
801066cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
801066d2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801066d6:	74 46                	je     8010671e <create+0xb3>
    iunlockput(dp);
801066d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801066db:	89 04 24             	mov    %eax,(%esp)
801066de:	e8 42 b5 ff ff       	call   80101c25 <iunlockput>
    ilock(ip);
801066e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066e6:	89 04 24             	mov    %eax,(%esp)
801066e9:	e8 38 b3 ff ff       	call   80101a26 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801066ee:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
801066f3:	75 14                	jne    80106709 <create+0x9e>
801066f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066f8:	8b 40 50             	mov    0x50(%eax),%eax
801066fb:	66 83 f8 02          	cmp    $0x2,%ax
801066ff:	75 08                	jne    80106709 <create+0x9e>
      return ip;
80106701:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106704:	e9 1b 01 00 00       	jmp    80106824 <create+0x1b9>
    iunlockput(ip);
80106709:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010670c:	89 04 24             	mov    %eax,(%esp)
8010670f:	e8 11 b5 ff ff       	call   80101c25 <iunlockput>
    return 0;
80106714:	b8 00 00 00 00       	mov    $0x0,%eax
80106719:	e9 06 01 00 00       	jmp    80106824 <create+0x1b9>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
8010671e:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106722:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106725:	8b 00                	mov    (%eax),%eax
80106727:	89 54 24 04          	mov    %edx,0x4(%esp)
8010672b:	89 04 24             	mov    %eax,(%esp)
8010672e:	e8 5e b0 ff ff       	call   80101791 <ialloc>
80106733:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106736:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010673a:	75 0c                	jne    80106748 <create+0xdd>
    panic("create: ialloc");
8010673c:	c7 04 24 f0 98 10 80 	movl   $0x801098f0,(%esp)
80106743:	e8 0c 9e ff ff       	call   80100554 <panic>

  ilock(ip);
80106748:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010674b:	89 04 24             	mov    %eax,(%esp)
8010674e:	e8 d3 b2 ff ff       	call   80101a26 <ilock>
  ip->major = major;
80106753:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106756:	8b 45 d0             	mov    -0x30(%ebp),%eax
80106759:	66 89 42 52          	mov    %ax,0x52(%edx)
  ip->minor = minor;
8010675d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106760:	8b 45 cc             	mov    -0x34(%ebp),%eax
80106763:	66 89 42 54          	mov    %ax,0x54(%edx)
  ip->nlink = 1;
80106767:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010676a:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80106770:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106773:	89 04 24             	mov    %eax,(%esp)
80106776:	e8 e8 b0 ff ff       	call   80101863 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
8010677b:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
80106780:	75 68                	jne    801067ea <create+0x17f>
    dp->nlink++;  // for ".."
80106782:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106785:	66 8b 40 56          	mov    0x56(%eax),%ax
80106789:	40                   	inc    %eax
8010678a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010678d:	66 89 42 56          	mov    %ax,0x56(%edx)
    iupdate(dp);
80106791:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106794:	89 04 24             	mov    %eax,(%esp)
80106797:	e8 c7 b0 ff ff       	call   80101863 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010679c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010679f:	8b 40 04             	mov    0x4(%eax),%eax
801067a2:	89 44 24 08          	mov    %eax,0x8(%esp)
801067a6:	c7 44 24 04 ca 98 10 	movl   $0x801098ca,0x4(%esp)
801067ad:	80 
801067ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067b1:	89 04 24             	mov    %eax,(%esp)
801067b4:	e8 df ba ff ff       	call   80102298 <dirlink>
801067b9:	85 c0                	test   %eax,%eax
801067bb:	78 21                	js     801067de <create+0x173>
801067bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067c0:	8b 40 04             	mov    0x4(%eax),%eax
801067c3:	89 44 24 08          	mov    %eax,0x8(%esp)
801067c7:	c7 44 24 04 cc 98 10 	movl   $0x801098cc,0x4(%esp)
801067ce:	80 
801067cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067d2:	89 04 24             	mov    %eax,(%esp)
801067d5:	e8 be ba ff ff       	call   80102298 <dirlink>
801067da:	85 c0                	test   %eax,%eax
801067dc:	79 0c                	jns    801067ea <create+0x17f>
      panic("create dots");
801067de:	c7 04 24 ff 98 10 80 	movl   $0x801098ff,(%esp)
801067e5:	e8 6a 9d ff ff       	call   80100554 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
801067ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067ed:	8b 40 04             	mov    0x4(%eax),%eax
801067f0:	89 44 24 08          	mov    %eax,0x8(%esp)
801067f4:	8d 45 de             	lea    -0x22(%ebp),%eax
801067f7:	89 44 24 04          	mov    %eax,0x4(%esp)
801067fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801067fe:	89 04 24             	mov    %eax,(%esp)
80106801:	e8 92 ba ff ff       	call   80102298 <dirlink>
80106806:	85 c0                	test   %eax,%eax
80106808:	79 0c                	jns    80106816 <create+0x1ab>
    panic("create: dirlink");
8010680a:	c7 04 24 0b 99 10 80 	movl   $0x8010990b,(%esp)
80106811:	e8 3e 9d ff ff       	call   80100554 <panic>

  iunlockput(dp);
80106816:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106819:	89 04 24             	mov    %eax,(%esp)
8010681c:	e8 04 b4 ff ff       	call   80101c25 <iunlockput>

  return ip;
80106821:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80106824:	c9                   	leave  
80106825:	c3                   	ret    

80106826 <sys_open>:

int
sys_open(void)
{
80106826:	55                   	push   %ebp
80106827:	89 e5                	mov    %esp,%ebp
80106829:	83 ec 38             	sub    $0x38,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
8010682c:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010682f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106833:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010683a:	e8 f1 f6 ff ff       	call   80105f30 <argstr>
8010683f:	85 c0                	test   %eax,%eax
80106841:	78 17                	js     8010685a <sys_open+0x34>
80106843:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106846:	89 44 24 04          	mov    %eax,0x4(%esp)
8010684a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106851:	e8 43 f6 ff ff       	call   80105e99 <argint>
80106856:	85 c0                	test   %eax,%eax
80106858:	79 0a                	jns    80106864 <sys_open+0x3e>
    return -1;
8010685a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010685f:	e9 5b 01 00 00       	jmp    801069bf <sys_open+0x199>

  begin_op();
80106864:	e8 e6 cd ff ff       	call   8010364f <begin_op>

  if(omode & O_CREATE){
80106869:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010686c:	25 00 02 00 00       	and    $0x200,%eax
80106871:	85 c0                	test   %eax,%eax
80106873:	74 3b                	je     801068b0 <sys_open+0x8a>
    ip = create(path, T_FILE, 0, 0);
80106875:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106878:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
8010687f:	00 
80106880:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106887:	00 
80106888:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
8010688f:	00 
80106890:	89 04 24             	mov    %eax,(%esp)
80106893:	e8 d3 fd ff ff       	call   8010666b <create>
80106898:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
8010689b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010689f:	75 6a                	jne    8010690b <sys_open+0xe5>
      end_op();
801068a1:	e8 2b ce ff ff       	call   801036d1 <end_op>
      return -1;
801068a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068ab:	e9 0f 01 00 00       	jmp    801069bf <sys_open+0x199>
    }
  } else {
    if((ip = namei(path)) == 0){
801068b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801068b3:	89 04 24             	mov    %eax,(%esp)
801068b6:	e8 c1 bd ff ff       	call   8010267c <namei>
801068bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801068be:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068c2:	75 0f                	jne    801068d3 <sys_open+0xad>
      end_op();
801068c4:	e8 08 ce ff ff       	call   801036d1 <end_op>
      return -1;
801068c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801068ce:	e9 ec 00 00 00       	jmp    801069bf <sys_open+0x199>
    }
    ilock(ip);
801068d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068d6:	89 04 24             	mov    %eax,(%esp)
801068d9:	e8 48 b1 ff ff       	call   80101a26 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
801068de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068e1:	8b 40 50             	mov    0x50(%eax),%eax
801068e4:	66 83 f8 01          	cmp    $0x1,%ax
801068e8:	75 21                	jne    8010690b <sys_open+0xe5>
801068ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801068ed:	85 c0                	test   %eax,%eax
801068ef:	74 1a                	je     8010690b <sys_open+0xe5>
      iunlockput(ip);
801068f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068f4:	89 04 24             	mov    %eax,(%esp)
801068f7:	e8 29 b3 ff ff       	call   80101c25 <iunlockput>
      end_op();
801068fc:	e8 d0 cd ff ff       	call   801036d1 <end_op>
      return -1;
80106901:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106906:	e9 b4 00 00 00       	jmp    801069bf <sys_open+0x199>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010690b:	e8 54 a7 ff ff       	call   80101064 <filealloc>
80106910:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106913:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106917:	74 14                	je     8010692d <sys_open+0x107>
80106919:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010691c:	89 04 24             	mov    %eax,(%esp)
8010691f:	e8 40 f7 ff ff       	call   80106064 <fdalloc>
80106924:	89 45 ec             	mov    %eax,-0x14(%ebp)
80106927:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010692b:	79 28                	jns    80106955 <sys_open+0x12f>
    if(f)
8010692d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106931:	74 0b                	je     8010693e <sys_open+0x118>
      fileclose(f);
80106933:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106936:	89 04 24             	mov    %eax,(%esp)
80106939:	e8 ce a7 ff ff       	call   8010110c <fileclose>
    iunlockput(ip);
8010693e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106941:	89 04 24             	mov    %eax,(%esp)
80106944:	e8 dc b2 ff ff       	call   80101c25 <iunlockput>
    end_op();
80106949:	e8 83 cd ff ff       	call   801036d1 <end_op>
    return -1;
8010694e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106953:	eb 6a                	jmp    801069bf <sys_open+0x199>
  }
  iunlock(ip);
80106955:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106958:	89 04 24             	mov    %eax,(%esp)
8010695b:	e8 d0 b1 ff ff       	call   80101b30 <iunlock>
  end_op();
80106960:	e8 6c cd ff ff       	call   801036d1 <end_op>

  f->type = FD_INODE;
80106965:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106968:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
8010696e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106971:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106974:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106977:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010697a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106981:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106984:	83 e0 01             	and    $0x1,%eax
80106987:	85 c0                	test   %eax,%eax
80106989:	0f 94 c0             	sete   %al
8010698c:	88 c2                	mov    %al,%dl
8010698e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106991:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106994:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106997:	83 e0 01             	and    $0x1,%eax
8010699a:	85 c0                	test   %eax,%eax
8010699c:	75 0a                	jne    801069a8 <sys_open+0x182>
8010699e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801069a1:	83 e0 02             	and    $0x2,%eax
801069a4:	85 c0                	test   %eax,%eax
801069a6:	74 07                	je     801069af <sys_open+0x189>
801069a8:	b8 01 00 00 00       	mov    $0x1,%eax
801069ad:	eb 05                	jmp    801069b4 <sys_open+0x18e>
801069af:	b8 00 00 00 00       	mov    $0x0,%eax
801069b4:	88 c2                	mov    %al,%dl
801069b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069b9:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801069bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801069bf:	c9                   	leave  
801069c0:	c3                   	ret    

801069c1 <sys_mkdir>:

int
sys_mkdir(void)
{
801069c1:	55                   	push   %ebp
801069c2:	89 e5                	mov    %esp,%ebp
801069c4:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
801069c7:	e8 83 cc ff ff       	call   8010364f <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801069cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801069cf:	89 44 24 04          	mov    %eax,0x4(%esp)
801069d3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801069da:	e8 51 f5 ff ff       	call   80105f30 <argstr>
801069df:	85 c0                	test   %eax,%eax
801069e1:	78 2c                	js     80106a0f <sys_mkdir+0x4e>
801069e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801069e6:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
801069ed:	00 
801069ee:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801069f5:	00 
801069f6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801069fd:	00 
801069fe:	89 04 24             	mov    %eax,(%esp)
80106a01:	e8 65 fc ff ff       	call   8010666b <create>
80106a06:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106a09:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106a0d:	75 0c                	jne    80106a1b <sys_mkdir+0x5a>
    end_op();
80106a0f:	e8 bd cc ff ff       	call   801036d1 <end_op>
    return -1;
80106a14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a19:	eb 15                	jmp    80106a30 <sys_mkdir+0x6f>
  }
  iunlockput(ip);
80106a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a1e:	89 04 24             	mov    %eax,(%esp)
80106a21:	e8 ff b1 ff ff       	call   80101c25 <iunlockput>
  end_op();
80106a26:	e8 a6 cc ff ff       	call   801036d1 <end_op>
  return 0;
80106a2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106a30:	c9                   	leave  
80106a31:	c3                   	ret    

80106a32 <sys_mknod>:

int
sys_mknod(void)
{
80106a32:	55                   	push   %ebp
80106a33:	89 e5                	mov    %esp,%ebp
80106a35:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80106a38:	e8 12 cc ff ff       	call   8010364f <begin_op>
  if((argstr(0, &path)) < 0 ||
80106a3d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a40:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a44:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106a4b:	e8 e0 f4 ff ff       	call   80105f30 <argstr>
80106a50:	85 c0                	test   %eax,%eax
80106a52:	78 5e                	js     80106ab2 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80106a54:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106a57:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a5b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106a62:	e8 32 f4 ff ff       	call   80105e99 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
80106a67:	85 c0                	test   %eax,%eax
80106a69:	78 47                	js     80106ab2 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106a6b:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106a6e:	89 44 24 04          	mov    %eax,0x4(%esp)
80106a72:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106a79:	e8 1b f4 ff ff       	call   80105e99 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
80106a7e:	85 c0                	test   %eax,%eax
80106a80:	78 30                	js     80106ab2 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106a82:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106a85:	0f bf c8             	movswl %ax,%ecx
80106a88:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106a8b:	0f bf d0             	movswl %ax,%edx
80106a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106a91:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106a95:	89 54 24 08          	mov    %edx,0x8(%esp)
80106a99:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
80106aa0:	00 
80106aa1:	89 04 24             	mov    %eax,(%esp)
80106aa4:	e8 c2 fb ff ff       	call   8010666b <create>
80106aa9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106aac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106ab0:	75 0c                	jne    80106abe <sys_mknod+0x8c>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106ab2:	e8 1a cc ff ff       	call   801036d1 <end_op>
    return -1;
80106ab7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106abc:	eb 15                	jmp    80106ad3 <sys_mknod+0xa1>
  }
  iunlockput(ip);
80106abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ac1:	89 04 24             	mov    %eax,(%esp)
80106ac4:	e8 5c b1 ff ff       	call   80101c25 <iunlockput>
  end_op();
80106ac9:	e8 03 cc ff ff       	call   801036d1 <end_op>
  return 0;
80106ace:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106ad3:	c9                   	leave  
80106ad4:	c3                   	ret    

80106ad5 <sys_chdir>:

int
sys_chdir(void)
{
80106ad5:	55                   	push   %ebp
80106ad6:	89 e5                	mov    %esp,%ebp
80106ad8:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80106adb:	e8 6c d7 ff ff       	call   8010424c <myproc>
80106ae0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
80106ae3:	e8 67 cb ff ff       	call   8010364f <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106ae8:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106aeb:	89 44 24 04          	mov    %eax,0x4(%esp)
80106aef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106af6:	e8 35 f4 ff ff       	call   80105f30 <argstr>
80106afb:	85 c0                	test   %eax,%eax
80106afd:	78 14                	js     80106b13 <sys_chdir+0x3e>
80106aff:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106b02:	89 04 24             	mov    %eax,(%esp)
80106b05:	e8 72 bb ff ff       	call   8010267c <namei>
80106b0a:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106b0d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106b11:	75 18                	jne    80106b2b <sys_chdir+0x56>
    cprintf("cant pick up path\n");
80106b13:	c7 04 24 1b 99 10 80 	movl   $0x8010991b,(%esp)
80106b1a:	e8 a2 98 ff ff       	call   801003c1 <cprintf>
    end_op();
80106b1f:	e8 ad cb ff ff       	call   801036d1 <end_op>
    return -1;
80106b24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b29:	eb 66                	jmp    80106b91 <sys_chdir+0xbc>
  }
  ilock(ip);
80106b2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b2e:	89 04 24             	mov    %eax,(%esp)
80106b31:	e8 f0 ae ff ff       	call   80101a26 <ilock>
  if(ip->type != T_DIR){
80106b36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b39:	8b 40 50             	mov    0x50(%eax),%eax
80106b3c:	66 83 f8 01          	cmp    $0x1,%ax
80106b40:	74 23                	je     80106b65 <sys_chdir+0x90>
    // TODO: REMOVE
    cprintf("not a dir\n");
80106b42:	c7 04 24 2e 99 10 80 	movl   $0x8010992e,(%esp)
80106b49:	e8 73 98 ff ff       	call   801003c1 <cprintf>
    iunlockput(ip);
80106b4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b51:	89 04 24             	mov    %eax,(%esp)
80106b54:	e8 cc b0 ff ff       	call   80101c25 <iunlockput>
    end_op();
80106b59:	e8 73 cb ff ff       	call   801036d1 <end_op>
    return -1;
80106b5e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b63:	eb 2c                	jmp    80106b91 <sys_chdir+0xbc>
  }
  iunlock(ip);
80106b65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106b68:	89 04 24             	mov    %eax,(%esp)
80106b6b:	e8 c0 af ff ff       	call   80101b30 <iunlock>
  iput(curproc->cwd);
80106b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b73:	8b 40 68             	mov    0x68(%eax),%eax
80106b76:	89 04 24             	mov    %eax,(%esp)
80106b79:	e8 f6 af ff ff       	call   80101b74 <iput>
  end_op();
80106b7e:	e8 4e cb ff ff       	call   801036d1 <end_op>
  curproc->cwd = ip;
80106b83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106b86:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106b89:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80106b8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106b91:	c9                   	leave  
80106b92:	c3                   	ret    

80106b93 <sys_exec>:

int
sys_exec(void)
{
80106b93:	55                   	push   %ebp
80106b94:	89 e5                	mov    %esp,%ebp
80106b96:	81 ec a8 00 00 00    	sub    $0xa8,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80106b9c:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106b9f:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ba3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106baa:	e8 81 f3 ff ff       	call   80105f30 <argstr>
80106baf:	85 c0                	test   %eax,%eax
80106bb1:	78 1a                	js     80106bcd <sys_exec+0x3a>
80106bb3:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106bb9:	89 44 24 04          	mov    %eax,0x4(%esp)
80106bbd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106bc4:	e8 d0 f2 ff ff       	call   80105e99 <argint>
80106bc9:	85 c0                	test   %eax,%eax
80106bcb:	79 0a                	jns    80106bd7 <sys_exec+0x44>
    return -1;
80106bcd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bd2:	e9 c7 00 00 00       	jmp    80106c9e <sys_exec+0x10b>
  }
  memset(argv, 0, sizeof(argv));
80106bd7:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106bde:	00 
80106bdf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106be6:	00 
80106be7:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106bed:	89 04 24             	mov    %eax,(%esp)
80106bf0:	e8 71 ef ff ff       	call   80105b66 <memset>
  for(i=0;; i++){
80106bf5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106bff:	83 f8 1f             	cmp    $0x1f,%eax
80106c02:	76 0a                	jbe    80106c0e <sys_exec+0x7b>
      return -1;
80106c04:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c09:	e9 90 00 00 00       	jmp    80106c9e <sys_exec+0x10b>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106c0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c11:	c1 e0 02             	shl    $0x2,%eax
80106c14:	89 c2                	mov    %eax,%edx
80106c16:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106c1c:	01 c2                	add    %eax,%edx
80106c1e:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106c24:	89 44 24 04          	mov    %eax,0x4(%esp)
80106c28:	89 14 24             	mov    %edx,(%esp)
80106c2b:	e8 c8 f1 ff ff       	call   80105df8 <fetchint>
80106c30:	85 c0                	test   %eax,%eax
80106c32:	79 07                	jns    80106c3b <sys_exec+0xa8>
      return -1;
80106c34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c39:	eb 63                	jmp    80106c9e <sys_exec+0x10b>
    if(uarg == 0){
80106c3b:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106c41:	85 c0                	test   %eax,%eax
80106c43:	75 26                	jne    80106c6b <sys_exec+0xd8>
      argv[i] = 0;
80106c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c48:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106c4f:	00 00 00 00 
      break;
80106c53:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106c54:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c57:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106c5d:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c61:	89 04 24             	mov    %eax,(%esp)
80106c64:	e8 9f 9f ff ff       	call   80100c08 <exec>
80106c69:	eb 33                	jmp    80106c9e <sys_exec+0x10b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106c6b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106c71:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106c74:	c1 e2 02             	shl    $0x2,%edx
80106c77:	01 c2                	add    %eax,%edx
80106c79:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106c7f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106c83:	89 04 24             	mov    %eax,(%esp)
80106c86:	e8 ac f1 ff ff       	call   80105e37 <fetchstr>
80106c8b:	85 c0                	test   %eax,%eax
80106c8d:	79 07                	jns    80106c96 <sys_exec+0x103>
      return -1;
80106c8f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c94:	eb 08                	jmp    80106c9e <sys_exec+0x10b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106c96:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106c99:	e9 5e ff ff ff       	jmp    80106bfc <sys_exec+0x69>
  return exec(path, argv);
}
80106c9e:	c9                   	leave  
80106c9f:	c3                   	ret    

80106ca0 <sys_pipe>:

int
sys_pipe(void)
{
80106ca0:	55                   	push   %ebp
80106ca1:	89 e5                	mov    %esp,%ebp
80106ca3:	83 ec 38             	sub    $0x38,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106ca6:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80106cad:	00 
80106cae:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106cb1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cb5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106cbc:	e8 05 f2 ff ff       	call   80105ec6 <argptr>
80106cc1:	85 c0                	test   %eax,%eax
80106cc3:	79 0a                	jns    80106ccf <sys_pipe+0x2f>
    return -1;
80106cc5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cca:	e9 9a 00 00 00       	jmp    80106d69 <sys_pipe+0xc9>
  if(pipealloc(&rf, &wf) < 0)
80106ccf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106cd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80106cd6:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106cd9:	89 04 24             	mov    %eax,(%esp)
80106cdc:	e8 bb d1 ff ff       	call   80103e9c <pipealloc>
80106ce1:	85 c0                	test   %eax,%eax
80106ce3:	79 07                	jns    80106cec <sys_pipe+0x4c>
    return -1;
80106ce5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106cea:	eb 7d                	jmp    80106d69 <sys_pipe+0xc9>
  fd0 = -1;
80106cec:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106cf3:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106cf6:	89 04 24             	mov    %eax,(%esp)
80106cf9:	e8 66 f3 ff ff       	call   80106064 <fdalloc>
80106cfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106d01:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d05:	78 14                	js     80106d1b <sys_pipe+0x7b>
80106d07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d0a:	89 04 24             	mov    %eax,(%esp)
80106d0d:	e8 52 f3 ff ff       	call   80106064 <fdalloc>
80106d12:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106d15:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106d19:	79 36                	jns    80106d51 <sys_pipe+0xb1>
    if(fd0 >= 0)
80106d1b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106d1f:	78 13                	js     80106d34 <sys_pipe+0x94>
      myproc()->ofile[fd0] = 0;
80106d21:	e8 26 d5 ff ff       	call   8010424c <myproc>
80106d26:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d29:	83 c2 08             	add    $0x8,%edx
80106d2c:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106d33:	00 
    fileclose(rf);
80106d34:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106d37:	89 04 24             	mov    %eax,(%esp)
80106d3a:	e8 cd a3 ff ff       	call   8010110c <fileclose>
    fileclose(wf);
80106d3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106d42:	89 04 24             	mov    %eax,(%esp)
80106d45:	e8 c2 a3 ff ff       	call   8010110c <fileclose>
    return -1;
80106d4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d4f:	eb 18                	jmp    80106d69 <sys_pipe+0xc9>
  }
  fd[0] = fd0;
80106d51:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106d54:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106d57:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106d59:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106d5c:	8d 50 04             	lea    0x4(%eax),%edx
80106d5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106d62:	89 02                	mov    %eax,(%edx)
  return 0;
80106d64:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d69:	c9                   	leave  
80106d6a:	c3                   	ret    

80106d6b <sys_ccreate>:

int
sys_ccreate(void)
{
80106d6b:	55                   	push   %ebp
80106d6c:	89 e5                	mov    %esp,%ebp
80106d6e:	56                   	push   %esi
80106d6f:	53                   	push   %ebx
80106d70:	81 ec c0 00 00 00    	sub    $0xc0,%esp

  char *name, *argv[MAXARG];
  int i, progc, mproc;
  uint uargv, uarg, msz, mdsk;

  if(argstr(0, &name) < 0 || argint(2, &progc) < 0 || argint(3, &mproc) < 0 
80106d76:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106d79:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106d84:	e8 a7 f1 ff ff       	call   80105f30 <argstr>
80106d89:	85 c0                	test   %eax,%eax
80106d8b:	78 68                	js     80106df5 <sys_ccreate+0x8a>
80106d8d:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106d93:	89 44 24 04          	mov    %eax,0x4(%esp)
80106d97:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106d9e:	e8 f6 f0 ff ff       	call   80105e99 <argint>
80106da3:	85 c0                	test   %eax,%eax
80106da5:	78 4e                	js     80106df5 <sys_ccreate+0x8a>
80106da7:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106dad:	89 44 24 04          	mov    %eax,0x4(%esp)
80106db1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
80106db8:	e8 dc f0 ff ff       	call   80105e99 <argint>
80106dbd:	85 c0                	test   %eax,%eax
80106dbf:	78 34                	js     80106df5 <sys_ccreate+0x8a>
    || argint(4, (int*)&msz) < 0 || argint(5, (int*)&mdsk) < 0) {
80106dc1:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
80106dc7:	89 44 24 04          	mov    %eax,0x4(%esp)
80106dcb:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80106dd2:	e8 c2 f0 ff ff       	call   80105e99 <argint>
80106dd7:	85 c0                	test   %eax,%eax
80106dd9:	78 1a                	js     80106df5 <sys_ccreate+0x8a>
80106ddb:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80106de1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106de5:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
80106dec:	e8 a8 f0 ff ff       	call   80105e99 <argint>
80106df1:	85 c0                	test   %eax,%eax
80106df3:	79 16                	jns    80106e0b <sys_ccreate+0xa0>
    cprintf("sys_ccreate: Error getting pointers\n");
80106df5:	c7 04 24 3c 99 10 80 	movl   $0x8010993c,(%esp)
80106dfc:	e8 c0 95 ff ff       	call   801003c1 <cprintf>
    return -1;
80106e01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e06:	e9 80 01 00 00       	jmp    80106f8b <sys_ccreate+0x220>
  }

  if(argint(1, (int*)&uargv) < 0){
80106e0b:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
80106e11:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e15:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106e1c:	e8 78 f0 ff ff       	call   80105e99 <argint>
80106e21:	85 c0                	test   %eax,%eax
80106e23:	79 0a                	jns    80106e2f <sys_ccreate+0xc4>
    return -1;
80106e25:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e2a:	e9 5c 01 00 00       	jmp    80106f8b <sys_ccreate+0x220>
  }
  memset(argv, 0, sizeof(argv));
80106e2f:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80106e36:	00 
80106e37:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80106e3e:	00 
80106e3f:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106e45:	89 04 24             	mov    %eax,(%esp)
80106e48:	e8 19 ed ff ff       	call   80105b66 <memset>
  for(i=0;; i++){
80106e4d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e57:	83 f8 1f             	cmp    $0x1f,%eax
80106e5a:	76 0a                	jbe    80106e66 <sys_ccreate+0xfb>
      return -1;
80106e5c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e61:	e9 25 01 00 00       	jmp    80106f8b <sys_ccreate+0x220>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106e66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e69:	c1 e0 02             	shl    $0x2,%eax
80106e6c:	89 c2                	mov    %eax,%edx
80106e6e:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80106e74:	01 c2                	add    %eax,%edx
80106e76:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
80106e7c:	89 44 24 04          	mov    %eax,0x4(%esp)
80106e80:	89 14 24             	mov    %edx,(%esp)
80106e83:	e8 70 ef ff ff       	call   80105df8 <fetchint>
80106e88:	85 c0                	test   %eax,%eax
80106e8a:	79 0a                	jns    80106e96 <sys_ccreate+0x12b>
      return -1;
80106e8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e91:	e9 f5 00 00 00       	jmp    80106f8b <sys_ccreate+0x220>
    if(uarg == 0){
80106e96:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80106e9c:	85 c0                	test   %eax,%eax
80106e9e:	75 53                	jne    80106ef3 <sys_ccreate+0x188>
      argv[i] = 0;
80106ea0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ea3:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106eaa:	00 00 00 00 
      break;
80106eae:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_create\nuargv: %d\nname: %s\nmproc: %d\nmsz: %d\nmdsk: %d\n", uargv, name, mproc, msz, mdsk);
80106eaf:	8b b5 58 ff ff ff    	mov    -0xa8(%ebp),%esi
80106eb5:	8b 9d 5c ff ff ff    	mov    -0xa4(%ebp),%ebx
80106ebb:	8b 8d 68 ff ff ff    	mov    -0x98(%ebp),%ecx
80106ec1:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106ec4:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80106eca:	89 74 24 14          	mov    %esi,0x14(%esp)
80106ece:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106ed2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106ed6:	89 54 24 08          	mov    %edx,0x8(%esp)
80106eda:	89 44 24 04          	mov    %eax,0x4(%esp)
80106ede:	c7 04 24 64 99 10 80 	movl   $0x80109964,(%esp)
80106ee5:	e8 d7 94 ff ff       	call   801003c1 <cprintf>
  for (i = 0; i < progc; i++) 
80106eea:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106ef1:	eb 50                	jmp    80106f43 <sys_ccreate+0x1d8>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106ef3:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106ef9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106efc:	c1 e2 02             	shl    $0x2,%edx
80106eff:	01 c2                	add    %eax,%edx
80106f01:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80106f07:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f0b:	89 04 24             	mov    %eax,(%esp)
80106f0e:	e8 24 ef ff ff       	call   80105e37 <fetchstr>
80106f13:	85 c0                	test   %eax,%eax
80106f15:	79 07                	jns    80106f1e <sys_ccreate+0x1b3>
      return -1;
80106f17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106f1c:	eb 6d                	jmp    80106f8b <sys_ccreate+0x220>

  if(argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106f1e:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106f21:	e9 2e ff ff ff       	jmp    80106e54 <sys_ccreate+0xe9>

  cprintf("sys_create\nuargv: %d\nname: %s\nmproc: %d\nmsz: %d\nmdsk: %d\n", uargv, name, mproc, msz, mdsk);
  for (i = 0; i < progc; i++) 
    cprintf("\t%s\n", argv[i]);
80106f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f29:	8b 84 85 70 ff ff ff 	mov    -0x90(%ebp,%eax,4),%eax
80106f30:	89 44 24 04          	mov    %eax,0x4(%esp)
80106f34:	c7 04 24 9e 99 10 80 	movl   $0x8010999e,(%esp)
80106f3b:	e8 81 94 ff ff       	call   801003c1 <cprintf>
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_create\nuargv: %d\nname: %s\nmproc: %d\nmsz: %d\nmdsk: %d\n", uargv, name, mproc, msz, mdsk);
  for (i = 0; i < progc; i++) 
80106f40:	ff 45 f4             	incl   -0xc(%ebp)
80106f43:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106f49:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80106f4c:	7c d8                	jl     80106f26 <sys_ccreate+0x1bb>
    cprintf("\t%s\n", argv[i]);
  
  return ccreate(name, argv, progc, mproc, msz, mdsk);
80106f4e:	8b b5 58 ff ff ff    	mov    -0xa8(%ebp),%esi
80106f54:	8b 9d 5c ff ff ff    	mov    -0xa4(%ebp),%ebx
80106f5a:	8b 8d 68 ff ff ff    	mov    -0x98(%ebp),%ecx
80106f60:	8b 95 6c ff ff ff    	mov    -0x94(%ebp),%edx
80106f66:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106f69:	89 74 24 14          	mov    %esi,0x14(%esp)
80106f6d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80106f71:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80106f75:	89 54 24 08          	mov    %edx,0x8(%esp)
80106f79:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106f7f:	89 54 24 04          	mov    %edx,0x4(%esp)
80106f83:	89 04 24             	mov    %eax,(%esp)
80106f86:	e8 f6 e2 ff ff       	call   80105281 <ccreate>
}
80106f8b:	81 c4 c0 00 00 00    	add    $0xc0,%esp
80106f91:	5b                   	pop    %ebx
80106f92:	5e                   	pop    %esi
80106f93:	5d                   	pop    %ebp
80106f94:	c3                   	ret    

80106f95 <sys_cstart>:

int
sys_cstart(void)
{
80106f95:	55                   	push   %ebp
80106f96:	89 e5                	mov    %esp,%ebp
80106f98:	81 ec b8 00 00 00    	sub    $0xb8,%esp

  char *name, *prog, *argv[MAXARG];
  int i, argc;
  uint uargv, uarg;

  if(argstr(0, &name) < 0 || argstr(1, &prog) < 0 || argint(2, &argc) < 0) {
80106f9e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106fa1:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fa5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80106fac:	e8 7f ef ff ff       	call   80105f30 <argstr>
80106fb1:	85 c0                	test   %eax,%eax
80106fb3:	78 31                	js     80106fe6 <sys_cstart+0x51>
80106fb5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106fb8:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fbc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80106fc3:	e8 68 ef ff ff       	call   80105f30 <argstr>
80106fc8:	85 c0                	test   %eax,%eax
80106fca:	78 1a                	js     80106fe6 <sys_cstart+0x51>
80106fcc:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106fd2:	89 44 24 04          	mov    %eax,0x4(%esp)
80106fd6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80106fdd:	e8 b7 ee ff ff       	call   80105e99 <argint>
80106fe2:	85 c0                	test   %eax,%eax
80106fe4:	79 16                	jns    80106ffc <sys_cstart+0x67>
    cprintf("sys_ccreate: Error getting pointers\n");
80106fe6:	c7 04 24 3c 99 10 80 	movl   $0x8010993c,(%esp)
80106fed:	e8 cf 93 ff ff       	call   801003c1 <cprintf>
    return -1;
80106ff2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ff7:	e9 4e 01 00 00       	jmp    8010714a <sys_cstart+0x1b5>
  }

  if(argint(1, (int*)&uargv) < 0){
80106ffc:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
80107002:	89 44 24 04          	mov    %eax,0x4(%esp)
80107006:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010700d:	e8 87 ee ff ff       	call   80105e99 <argint>
80107012:	85 c0                	test   %eax,%eax
80107014:	79 0a                	jns    80107020 <sys_cstart+0x8b>
    return -1;
80107016:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010701b:	e9 2a 01 00 00       	jmp    8010714a <sys_cstart+0x1b5>
  }
  memset(argv, 0, sizeof(argv));
80107020:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80107027:	00 
80107028:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010702f:	00 
80107030:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80107036:	89 04 24             	mov    %eax,(%esp)
80107039:	e8 28 eb ff ff       	call   80105b66 <memset>
  for(i=0;; i++){
8010703e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80107045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107048:	83 f8 1f             	cmp    $0x1f,%eax
8010704b:	76 0a                	jbe    80107057 <sys_cstart+0xc2>
      return -1;
8010704d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107052:	e9 f3 00 00 00       	jmp    8010714a <sys_cstart+0x1b5>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80107057:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010705a:	c1 e0 02             	shl    $0x2,%eax
8010705d:	89 c2                	mov    %eax,%edx
8010705f:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80107065:	01 c2                	add    %eax,%edx
80107067:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
8010706d:	89 44 24 04          	mov    %eax,0x4(%esp)
80107071:	89 14 24             	mov    %edx,(%esp)
80107074:	e8 7f ed ff ff       	call   80105df8 <fetchint>
80107079:	85 c0                	test   %eax,%eax
8010707b:	79 0a                	jns    80107087 <sys_cstart+0xf2>
      return -1;
8010707d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107082:	e9 c3 00 00 00       	jmp    8010714a <sys_cstart+0x1b5>
    if(uarg == 0){
80107087:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
8010708d:	85 c0                	test   %eax,%eax
8010708f:	75 3f                	jne    801070d0 <sys_cstart+0x13b>
      argv[i] = 0;
80107091:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107094:	c7 84 85 6c ff ff ff 	movl   $0x0,-0x94(%ebp,%eax,4)
8010709b:	00 00 00 00 
      break;
8010709f:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_cstart\n\tuargv: %d\n\tname: %s\n\targc: %d\n", uargv, name, argc);
801070a0:	8b 8d 68 ff ff ff    	mov    -0x98(%ebp),%ecx
801070a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801070a9:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
801070af:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
801070b3:	89 54 24 08          	mov    %edx,0x8(%esp)
801070b7:	89 44 24 04          	mov    %eax,0x4(%esp)
801070bb:	c7 04 24 a4 99 10 80 	movl   $0x801099a4,(%esp)
801070c2:	e8 fa 92 ff ff       	call   801003c1 <cprintf>
  for (i = 0; i < argc; i++) 
801070c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801070ce:	eb 50                	jmp    80107120 <sys_cstart+0x18b>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801070d0:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801070d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
801070d9:	c1 e2 02             	shl    $0x2,%edx
801070dc:	01 c2                	add    %eax,%edx
801070de:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
801070e4:	89 54 24 04          	mov    %edx,0x4(%esp)
801070e8:	89 04 24             	mov    %eax,(%esp)
801070eb:	e8 47 ed ff ff       	call   80105e37 <fetchstr>
801070f0:	85 c0                	test   %eax,%eax
801070f2:	79 07                	jns    801070fb <sys_cstart+0x166>
      return -1;
801070f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801070f9:	eb 4f                	jmp    8010714a <sys_cstart+0x1b5>

  if(argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801070fb:	ff 45 f4             	incl   -0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
801070fe:	e9 42 ff ff ff       	jmp    80107045 <sys_cstart+0xb0>

  cprintf("sys_cstart\n\tuargv: %d\n\tname: %s\n\targc: %d\n", uargv, name, argc);
  for (i = 0; i < argc; i++) 
    cprintf("\t%s\n", argv[i]);
80107103:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107106:	8b 84 85 6c ff ff ff 	mov    -0x94(%ebp,%eax,4),%eax
8010710d:	89 44 24 04          	mov    %eax,0x4(%esp)
80107111:	c7 04 24 9e 99 10 80 	movl   $0x8010999e,(%esp)
80107118:	e8 a4 92 ff ff       	call   801003c1 <cprintf>
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }

  cprintf("sys_cstart\n\tuargv: %d\n\tname: %s\n\targc: %d\n", uargv, name, argc);
  for (i = 0; i < argc; i++) 
8010711d:	ff 45 f4             	incl   -0xc(%ebp)
80107120:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80107126:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80107129:	7c d8                	jl     80107103 <sys_cstart+0x16e>
    cprintf("\t%s\n", argv[i]);
  
  return cstart(name, argv, argc);
8010712b:	8b 95 68 ff ff ff    	mov    -0x98(%ebp),%edx
80107131:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107134:	89 54 24 08          	mov    %edx,0x8(%esp)
80107138:	8d 95 6c ff ff ff    	lea    -0x94(%ebp),%edx
8010713e:	89 54 24 04          	mov    %edx,0x4(%esp)
80107142:	89 04 24             	mov    %eax,(%esp)
80107145:	e8 13 e2 ff ff       	call   8010535d <cstart>
}
8010714a:	c9                   	leave  
8010714b:	c3                   	ret    

8010714c <sys_cstop>:

int
sys_cstop(void)
{
8010714c:	55                   	push   %ebp
8010714d:	89 e5                	mov    %esp,%ebp
  return 1;
8010714f:	b8 01 00 00 00       	mov    $0x1,%eax
}
80107154:	5d                   	pop    %ebp
80107155:	c3                   	ret    

80107156 <sys_cinfo>:

int
sys_cinfo(void)
{
80107156:	55                   	push   %ebp
80107157:	89 e5                	mov    %esp,%ebp
  return 1;
80107159:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010715e:	5d                   	pop    %ebp
8010715f:	c3                   	ret    

80107160 <sys_cpause>:

int
sys_cpause(void)
{
80107160:	55                   	push   %ebp
80107161:	89 e5                	mov    %esp,%ebp
  return 1;
80107163:	b8 01 00 00 00       	mov    $0x1,%eax
80107168:	5d                   	pop    %ebp
80107169:	c3                   	ret    
	...

8010716c <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
8010716c:	55                   	push   %ebp
8010716d:	89 e5                	mov    %esp,%ebp
8010716f:	83 ec 08             	sub    $0x8,%esp
  return fork();
80107172:	e8 11 d4 ff ff       	call   80104588 <fork>
}
80107177:	c9                   	leave  
80107178:	c3                   	ret    

80107179 <sys_exit>:

int
sys_exit(void)
{
80107179:	55                   	push   %ebp
8010717a:	89 e5                	mov    %esp,%ebp
8010717c:	83 ec 08             	sub    $0x8,%esp
  exit();
8010717f:	e8 8a d6 ff ff       	call   8010480e <exit>
  return 0;  // not reached
80107184:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107189:	c9                   	leave  
8010718a:	c3                   	ret    

8010718b <sys_wait>:

int
sys_wait(void)
{
8010718b:	55                   	push   %ebp
8010718c:	89 e5                	mov    %esp,%ebp
8010718e:	83 ec 08             	sub    $0x8,%esp
  return wait();
80107191:	e8 a8 d7 ff ff       	call   8010493e <wait>
}
80107196:	c9                   	leave  
80107197:	c3                   	ret    

80107198 <sys_kill>:

int
sys_kill(void)
{
80107198:	55                   	push   %ebp
80107199:	89 e5                	mov    %esp,%ebp
8010719b:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010719e:	8d 45 f4             	lea    -0xc(%ebp),%eax
801071a1:	89 44 24 04          	mov    %eax,0x4(%esp)
801071a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801071ac:	e8 e8 ec ff ff       	call   80105e99 <argint>
801071b1:	85 c0                	test   %eax,%eax
801071b3:	79 07                	jns    801071bc <sys_kill+0x24>
    return -1;
801071b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071ba:	eb 0b                	jmp    801071c7 <sys_kill+0x2f>
  return kill(pid);
801071bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071bf:	89 04 24             	mov    %eax,(%esp)
801071c2:	e8 d9 da ff ff       	call   80104ca0 <kill>
}
801071c7:	c9                   	leave  
801071c8:	c3                   	ret    

801071c9 <sys_getpid>:

int
sys_getpid(void)
{
801071c9:	55                   	push   %ebp
801071ca:	89 e5                	mov    %esp,%ebp
801071cc:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
801071cf:	e8 78 d0 ff ff       	call   8010424c <myproc>
801071d4:	8b 40 10             	mov    0x10(%eax),%eax
}
801071d7:	c9                   	leave  
801071d8:	c3                   	ret    

801071d9 <sys_sbrk>:

int
sys_sbrk(void)
{
801071d9:	55                   	push   %ebp
801071da:	89 e5                	mov    %esp,%ebp
801071dc:	83 ec 28             	sub    $0x28,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801071df:	8d 45 f0             	lea    -0x10(%ebp),%eax
801071e2:	89 44 24 04          	mov    %eax,0x4(%esp)
801071e6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801071ed:	e8 a7 ec ff ff       	call   80105e99 <argint>
801071f2:	85 c0                	test   %eax,%eax
801071f4:	79 07                	jns    801071fd <sys_sbrk+0x24>
    return -1;
801071f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801071fb:	eb 23                	jmp    80107220 <sys_sbrk+0x47>
  addr = myproc()->sz;
801071fd:	e8 4a d0 ff ff       	call   8010424c <myproc>
80107202:	8b 00                	mov    (%eax),%eax
80107204:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80107207:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010720a:	89 04 24             	mov    %eax,(%esp)
8010720d:	e8 d8 d2 ff ff       	call   801044ea <growproc>
80107212:	85 c0                	test   %eax,%eax
80107214:	79 07                	jns    8010721d <sys_sbrk+0x44>
    return -1;
80107216:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010721b:	eb 03                	jmp    80107220 <sys_sbrk+0x47>
  return addr;
8010721d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80107220:	c9                   	leave  
80107221:	c3                   	ret    

80107222 <sys_sleep>:

int
sys_sleep(void)
{
80107222:	55                   	push   %ebp
80107223:	89 e5                	mov    %esp,%ebp
80107225:	83 ec 28             	sub    $0x28,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80107228:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010722b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010722f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80107236:	e8 5e ec ff ff       	call   80105e99 <argint>
8010723b:	85 c0                	test   %eax,%eax
8010723d:	79 07                	jns    80107246 <sys_sleep+0x24>
    return -1;
8010723f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107244:	eb 6b                	jmp    801072b1 <sys_sleep+0x8f>
  acquire(&tickslock);
80107246:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
8010724d:	e8 b1 e6 ff ff       	call   80105903 <acquire>
  ticks0 = ticks;
80107252:	a1 40 61 12 80       	mov    0x80126140,%eax
80107257:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010725a:	eb 33                	jmp    8010728f <sys_sleep+0x6d>
    if(myproc()->killed){
8010725c:	e8 eb cf ff ff       	call   8010424c <myproc>
80107261:	8b 40 24             	mov    0x24(%eax),%eax
80107264:	85 c0                	test   %eax,%eax
80107266:	74 13                	je     8010727b <sys_sleep+0x59>
      release(&tickslock);
80107268:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
8010726f:	e8 f9 e6 ff ff       	call   8010596d <release>
      return -1;
80107274:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107279:	eb 36                	jmp    801072b1 <sys_sleep+0x8f>
    }
    sleep(&ticks, &tickslock);
8010727b:	c7 44 24 04 00 59 12 	movl   $0x80125900,0x4(%esp)
80107282:	80 
80107283:	c7 04 24 40 61 12 80 	movl   $0x80126140,(%esp)
8010728a:	e8 d9 d8 ff ff       	call   80104b68 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
8010728f:	a1 40 61 12 80       	mov    0x80126140,%eax
80107294:	2b 45 f4             	sub    -0xc(%ebp),%eax
80107297:	89 c2                	mov    %eax,%edx
80107299:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010729c:	39 c2                	cmp    %eax,%edx
8010729e:	72 bc                	jb     8010725c <sys_sleep+0x3a>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
801072a0:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
801072a7:	e8 c1 e6 ff ff       	call   8010596d <release>
  return 0;
801072ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072b1:	c9                   	leave  
801072b2:	c3                   	ret    

801072b3 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
801072b3:	55                   	push   %ebp
801072b4:	89 e5                	mov    %esp,%ebp
801072b6:	83 ec 28             	sub    $0x28,%esp
  uint xticks;

  acquire(&tickslock);
801072b9:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
801072c0:	e8 3e e6 ff ff       	call   80105903 <acquire>
  xticks = ticks;
801072c5:	a1 40 61 12 80       	mov    0x80126140,%eax
801072ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801072cd:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
801072d4:	e8 94 e6 ff ff       	call   8010596d <release>
  return xticks;
801072d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801072dc:	c9                   	leave  
801072dd:	c3                   	ret    

801072de <sys_getticks>:

int
sys_getticks(void)
{
801072de:	55                   	push   %ebp
801072df:	89 e5                	mov    %esp,%ebp
801072e1:	83 ec 08             	sub    $0x8,%esp
  return myproc()->ticks;
801072e4:	e8 63 cf ff ff       	call   8010424c <myproc>
801072e9:	8b 40 7c             	mov    0x7c(%eax),%eax
}
801072ec:	c9                   	leave  
801072ed:	c3                   	ret    
	...

801072f0 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
801072f0:	1e                   	push   %ds
  pushl %es
801072f1:	06                   	push   %es
  pushl %fs
801072f2:	0f a0                	push   %fs
  pushl %gs
801072f4:	0f a8                	push   %gs
  pushal
801072f6:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
801072f7:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
801072fb:	8e d8                	mov    %eax,%ds
  movw %ax, %es
801072fd:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
801072ff:	54                   	push   %esp
  call trap
80107300:	e8 c0 01 00 00       	call   801074c5 <trap>
  addl $4, %esp
80107305:	83 c4 04             	add    $0x4,%esp

80107308 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80107308:	61                   	popa   
  popl %gs
80107309:	0f a9                	pop    %gs
  popl %fs
8010730b:	0f a1                	pop    %fs
  popl %es
8010730d:	07                   	pop    %es
  popl %ds
8010730e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
8010730f:	83 c4 08             	add    $0x8,%esp
  iret
80107312:	cf                   	iret   
	...

80107314 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80107314:	55                   	push   %ebp
80107315:	89 e5                	mov    %esp,%ebp
80107317:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010731a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010731d:	48                   	dec    %eax
8010731e:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107322:	8b 45 08             	mov    0x8(%ebp),%eax
80107325:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80107329:	8b 45 08             	mov    0x8(%ebp),%eax
8010732c:	c1 e8 10             	shr    $0x10,%eax
8010732f:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80107333:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107336:	0f 01 18             	lidtl  (%eax)
}
80107339:	c9                   	leave  
8010733a:	c3                   	ret    

8010733b <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
8010733b:	55                   	push   %ebp
8010733c:	89 e5                	mov    %esp,%ebp
8010733e:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80107341:	0f 20 d0             	mov    %cr2,%eax
80107344:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80107347:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010734a:	c9                   	leave  
8010734b:	c3                   	ret    

8010734c <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
8010734c:	55                   	push   %ebp
8010734d:	89 e5                	mov    %esp,%ebp
8010734f:	83 ec 28             	sub    $0x28,%esp
  int i;

  for(i = 0; i < 256; i++)
80107352:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107359:	e9 b8 00 00 00       	jmp    80107416 <tvinit+0xca>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
8010735e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107361:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
80107368:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010736b:	66 89 04 d5 40 59 12 	mov    %ax,-0x7feda6c0(,%edx,8)
80107372:	80 
80107373:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107376:	66 c7 04 c5 42 59 12 	movw   $0x8,-0x7feda6be(,%eax,8)
8010737d:	80 08 00 
80107380:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107383:	8a 14 c5 44 59 12 80 	mov    -0x7feda6bc(,%eax,8),%dl
8010738a:	83 e2 e0             	and    $0xffffffe0,%edx
8010738d:	88 14 c5 44 59 12 80 	mov    %dl,-0x7feda6bc(,%eax,8)
80107394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107397:	8a 14 c5 44 59 12 80 	mov    -0x7feda6bc(,%eax,8),%dl
8010739e:	83 e2 1f             	and    $0x1f,%edx
801073a1:	88 14 c5 44 59 12 80 	mov    %dl,-0x7feda6bc(,%eax,8)
801073a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ab:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
801073b2:	83 e2 f0             	and    $0xfffffff0,%edx
801073b5:	83 ca 0e             	or     $0xe,%edx
801073b8:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
801073bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073c2:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
801073c9:	83 e2 ef             	and    $0xffffffef,%edx
801073cc:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
801073d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073d6:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
801073dd:	83 e2 9f             	and    $0xffffff9f,%edx
801073e0:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
801073e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073ea:	8a 14 c5 45 59 12 80 	mov    -0x7feda6bb(,%eax,8),%dl
801073f1:	83 ca 80             	or     $0xffffff80,%edx
801073f4:	88 14 c5 45 59 12 80 	mov    %dl,-0x7feda6bb(,%eax,8)
801073fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801073fe:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
80107405:	c1 e8 10             	shr    $0x10,%eax
80107408:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010740b:	66 89 04 d5 46 59 12 	mov    %ax,-0x7feda6ba(,%edx,8)
80107412:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80107413:	ff 45 f4             	incl   -0xc(%ebp)
80107416:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010741d:	0f 8e 3b ff ff ff    	jle    8010735e <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80107423:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
80107428:	66 a3 40 5b 12 80    	mov    %ax,0x80125b40
8010742e:	66 c7 05 42 5b 12 80 	movw   $0x8,0x80125b42
80107435:	08 00 
80107437:	a0 44 5b 12 80       	mov    0x80125b44,%al
8010743c:	83 e0 e0             	and    $0xffffffe0,%eax
8010743f:	a2 44 5b 12 80       	mov    %al,0x80125b44
80107444:	a0 44 5b 12 80       	mov    0x80125b44,%al
80107449:	83 e0 1f             	and    $0x1f,%eax
8010744c:	a2 44 5b 12 80       	mov    %al,0x80125b44
80107451:	a0 45 5b 12 80       	mov    0x80125b45,%al
80107456:	83 c8 0f             	or     $0xf,%eax
80107459:	a2 45 5b 12 80       	mov    %al,0x80125b45
8010745e:	a0 45 5b 12 80       	mov    0x80125b45,%al
80107463:	83 e0 ef             	and    $0xffffffef,%eax
80107466:	a2 45 5b 12 80       	mov    %al,0x80125b45
8010746b:	a0 45 5b 12 80       	mov    0x80125b45,%al
80107470:	83 c8 60             	or     $0x60,%eax
80107473:	a2 45 5b 12 80       	mov    %al,0x80125b45
80107478:	a0 45 5b 12 80       	mov    0x80125b45,%al
8010747d:	83 c8 80             	or     $0xffffff80,%eax
80107480:	a2 45 5b 12 80       	mov    %al,0x80125b45
80107485:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
8010748a:	c1 e8 10             	shr    $0x10,%eax
8010748d:	66 a3 46 5b 12 80    	mov    %ax,0x80125b46

  initlock(&tickslock, "time");
80107493:	c7 44 24 04 d0 99 10 	movl   $0x801099d0,0x4(%esp)
8010749a:	80 
8010749b:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
801074a2:	e8 3b e4 ff ff       	call   801058e2 <initlock>
}
801074a7:	c9                   	leave  
801074a8:	c3                   	ret    

801074a9 <idtinit>:

void
idtinit(void)
{
801074a9:	55                   	push   %ebp
801074aa:	89 e5                	mov    %esp,%ebp
801074ac:	83 ec 08             	sub    $0x8,%esp
  lidt(idt, sizeof(idt));
801074af:	c7 44 24 04 00 08 00 	movl   $0x800,0x4(%esp)
801074b6:	00 
801074b7:	c7 04 24 40 59 12 80 	movl   $0x80125940,(%esp)
801074be:	e8 51 fe ff ff       	call   80107314 <lidt>
}
801074c3:	c9                   	leave  
801074c4:	c3                   	ret    

801074c5 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801074c5:	55                   	push   %ebp
801074c6:	89 e5                	mov    %esp,%ebp
801074c8:	57                   	push   %edi
801074c9:	56                   	push   %esi
801074ca:	53                   	push   %ebx
801074cb:	83 ec 4c             	sub    $0x4c,%esp
  struct proc *p;
  if(tf->trapno == T_SYSCALL){
801074ce:	8b 45 08             	mov    0x8(%ebp),%eax
801074d1:	8b 40 30             	mov    0x30(%eax),%eax
801074d4:	83 f8 40             	cmp    $0x40,%eax
801074d7:	75 3c                	jne    80107515 <trap+0x50>
    if(myproc()->killed)
801074d9:	e8 6e cd ff ff       	call   8010424c <myproc>
801074de:	8b 40 24             	mov    0x24(%eax),%eax
801074e1:	85 c0                	test   %eax,%eax
801074e3:	74 05                	je     801074ea <trap+0x25>
      exit();
801074e5:	e8 24 d3 ff ff       	call   8010480e <exit>
    myproc()->tf = tf;
801074ea:	e8 5d cd ff ff       	call   8010424c <myproc>
801074ef:	8b 55 08             	mov    0x8(%ebp),%edx
801074f2:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801074f5:	e8 6d ea ff ff       	call   80105f67 <syscall>
    if(myproc()->killed)
801074fa:	e8 4d cd ff ff       	call   8010424c <myproc>
801074ff:	8b 40 24             	mov    0x24(%eax),%eax
80107502:	85 c0                	test   %eax,%eax
80107504:	74 0a                	je     80107510 <trap+0x4b>
      exit();
80107506:	e8 03 d3 ff ff       	call   8010480e <exit>
    return;
8010750b:	e9 30 02 00 00       	jmp    80107740 <trap+0x27b>
80107510:	e9 2b 02 00 00       	jmp    80107740 <trap+0x27b>
  }

  switch(tf->trapno){
80107515:	8b 45 08             	mov    0x8(%ebp),%eax
80107518:	8b 40 30             	mov    0x30(%eax),%eax
8010751b:	83 e8 20             	sub    $0x20,%eax
8010751e:	83 f8 1f             	cmp    $0x1f,%eax
80107521:	0f 87 cb 00 00 00    	ja     801075f2 <trap+0x12d>
80107527:	8b 04 85 78 9a 10 80 	mov    -0x7fef6588(,%eax,4),%eax
8010752e:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80107530:	e8 19 d8 ff ff       	call   80104d4e <cpuid>
80107535:	85 c0                	test   %eax,%eax
80107537:	75 2f                	jne    80107568 <trap+0xa3>
      acquire(&tickslock);
80107539:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
80107540:	e8 be e3 ff ff       	call   80105903 <acquire>
      ticks++;
80107545:	a1 40 61 12 80       	mov    0x80126140,%eax
8010754a:	40                   	inc    %eax
8010754b:	a3 40 61 12 80       	mov    %eax,0x80126140
      wakeup(&ticks);
80107550:	c7 04 24 40 61 12 80 	movl   $0x80126140,(%esp)
80107557:	e8 27 d7 ff ff       	call   80104c83 <wakeup>
      release(&tickslock);
8010755c:	c7 04 24 00 59 12 80 	movl   $0x80125900,(%esp)
80107563:	e8 05 e4 ff ff       	call   8010596d <release>
    }
    p = myproc();
80107568:	e8 df cc ff ff       	call   8010424c <myproc>
8010756d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (p != 0) {
80107570:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80107574:	74 0f                	je     80107585 <trap+0xc0>
      p->ticks++;
80107576:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107579:	8b 40 7c             	mov    0x7c(%eax),%eax
8010757c:	8d 50 01             	lea    0x1(%eax),%edx
8010757f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107582:	89 50 7c             	mov    %edx,0x7c(%eax)
    }
    lapiceoi();
80107585:	e8 9d bb ff ff       	call   80103127 <lapiceoi>
    break;
8010758a:	e9 35 01 00 00       	jmp    801076c4 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010758f:	e8 12 b4 ff ff       	call   801029a6 <ideintr>
    lapiceoi();
80107594:	e8 8e bb ff ff       	call   80103127 <lapiceoi>
    break;
80107599:	e9 26 01 00 00       	jmp    801076c4 <trap+0x1ff>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010759e:	e8 9b b9 ff ff       	call   80102f3e <kbdintr>
    lapiceoi();
801075a3:	e8 7f bb ff ff       	call   80103127 <lapiceoi>
    break;
801075a8:	e9 17 01 00 00       	jmp    801076c4 <trap+0x1ff>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
801075ad:	e8 6f 03 00 00       	call   80107921 <uartintr>
    lapiceoi();
801075b2:	e8 70 bb ff ff       	call   80103127 <lapiceoi>
    break;
801075b7:	e9 08 01 00 00       	jmp    801076c4 <trap+0x1ff>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801075bc:	8b 45 08             	mov    0x8(%ebp),%eax
801075bf:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
801075c2:	8b 45 08             	mov    0x8(%ebp),%eax
801075c5:	8b 40 3c             	mov    0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801075c8:	0f b7 d8             	movzwl %ax,%ebx
801075cb:	e8 7e d7 ff ff       	call   80104d4e <cpuid>
801075d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
801075d4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801075d8:	89 44 24 04          	mov    %eax,0x4(%esp)
801075dc:	c7 04 24 d8 99 10 80 	movl   $0x801099d8,(%esp)
801075e3:	e8 d9 8d ff ff       	call   801003c1 <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
801075e8:	e8 3a bb ff ff       	call   80103127 <lapiceoi>
    break;
801075ed:	e9 d2 00 00 00       	jmp    801076c4 <trap+0x1ff>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
801075f2:	e8 55 cc ff ff       	call   8010424c <myproc>
801075f7:	85 c0                	test   %eax,%eax
801075f9:	74 10                	je     8010760b <trap+0x146>
801075fb:	8b 45 08             	mov    0x8(%ebp),%eax
801075fe:	8b 40 3c             	mov    0x3c(%eax),%eax
80107601:	0f b7 c0             	movzwl %ax,%eax
80107604:	83 e0 03             	and    $0x3,%eax
80107607:	85 c0                	test   %eax,%eax
80107609:	75 40                	jne    8010764b <trap+0x186>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010760b:	e8 2b fd ff ff       	call   8010733b <rcr2>
80107610:	89 c3                	mov    %eax,%ebx
80107612:	8b 45 08             	mov    0x8(%ebp),%eax
80107615:	8b 70 38             	mov    0x38(%eax),%esi
80107618:	e8 31 d7 ff ff       	call   80104d4e <cpuid>
8010761d:	8b 55 08             	mov    0x8(%ebp),%edx
80107620:	8b 52 30             	mov    0x30(%edx),%edx
80107623:	89 5c 24 10          	mov    %ebx,0x10(%esp)
80107627:	89 74 24 0c          	mov    %esi,0xc(%esp)
8010762b:	89 44 24 08          	mov    %eax,0x8(%esp)
8010762f:	89 54 24 04          	mov    %edx,0x4(%esp)
80107633:	c7 04 24 fc 99 10 80 	movl   $0x801099fc,(%esp)
8010763a:	e8 82 8d ff ff       	call   801003c1 <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
8010763f:	c7 04 24 2e 9a 10 80 	movl   $0x80109a2e,(%esp)
80107646:	e8 09 8f ff ff       	call   80100554 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010764b:	e8 eb fc ff ff       	call   8010733b <rcr2>
80107650:	89 c6                	mov    %eax,%esi
80107652:	8b 45 08             	mov    0x8(%ebp),%eax
80107655:	8b 40 38             	mov    0x38(%eax),%eax
80107658:	89 45 d4             	mov    %eax,-0x2c(%ebp)
8010765b:	e8 ee d6 ff ff       	call   80104d4e <cpuid>
80107660:	89 c3                	mov    %eax,%ebx
80107662:	8b 45 08             	mov    0x8(%ebp),%eax
80107665:	8b 78 34             	mov    0x34(%eax),%edi
80107668:	89 7d d0             	mov    %edi,-0x30(%ebp)
8010766b:	8b 45 08             	mov    0x8(%ebp),%eax
8010766e:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80107671:	e8 d6 cb ff ff       	call   8010424c <myproc>
80107676:	8d 50 6c             	lea    0x6c(%eax),%edx
80107679:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010767c:	e8 cb cb ff ff       	call   8010424c <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107681:	8b 40 10             	mov    0x10(%eax),%eax
80107684:	89 74 24 1c          	mov    %esi,0x1c(%esp)
80107688:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
8010768b:	89 4c 24 18          	mov    %ecx,0x18(%esp)
8010768f:	89 5c 24 14          	mov    %ebx,0x14(%esp)
80107693:	8b 4d d0             	mov    -0x30(%ebp),%ecx
80107696:	89 4c 24 10          	mov    %ecx,0x10(%esp)
8010769a:	89 7c 24 0c          	mov    %edi,0xc(%esp)
8010769e:	8b 55 cc             	mov    -0x34(%ebp),%edx
801076a1:	89 54 24 08          	mov    %edx,0x8(%esp)
801076a5:	89 44 24 04          	mov    %eax,0x4(%esp)
801076a9:	c7 04 24 34 9a 10 80 	movl   $0x80109a34,(%esp)
801076b0:	e8 0c 8d ff ff       	call   801003c1 <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
801076b5:	e8 92 cb ff ff       	call   8010424c <myproc>
801076ba:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801076c1:	eb 01                	jmp    801076c4 <trap+0x1ff>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
801076c3:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801076c4:	e8 83 cb ff ff       	call   8010424c <myproc>
801076c9:	85 c0                	test   %eax,%eax
801076cb:	74 22                	je     801076ef <trap+0x22a>
801076cd:	e8 7a cb ff ff       	call   8010424c <myproc>
801076d2:	8b 40 24             	mov    0x24(%eax),%eax
801076d5:	85 c0                	test   %eax,%eax
801076d7:	74 16                	je     801076ef <trap+0x22a>
801076d9:	8b 45 08             	mov    0x8(%ebp),%eax
801076dc:	8b 40 3c             	mov    0x3c(%eax),%eax
801076df:	0f b7 c0             	movzwl %ax,%eax
801076e2:	83 e0 03             	and    $0x3,%eax
801076e5:	83 f8 03             	cmp    $0x3,%eax
801076e8:	75 05                	jne    801076ef <trap+0x22a>
    exit();
801076ea:	e8 1f d1 ff ff       	call   8010480e <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801076ef:	e8 58 cb ff ff       	call   8010424c <myproc>
801076f4:	85 c0                	test   %eax,%eax
801076f6:	74 1d                	je     80107715 <trap+0x250>
801076f8:	e8 4f cb ff ff       	call   8010424c <myproc>
801076fd:	8b 40 0c             	mov    0xc(%eax),%eax
80107700:	83 f8 04             	cmp    $0x4,%eax
80107703:	75 10                	jne    80107715 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
80107705:	8b 45 08             	mov    0x8(%ebp),%eax
80107708:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010770b:	83 f8 20             	cmp    $0x20,%eax
8010770e:	75 05                	jne    80107715 <trap+0x250>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80107710:	e8 4c d3 ff ff       	call   80104a61 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80107715:	e8 32 cb ff ff       	call   8010424c <myproc>
8010771a:	85 c0                	test   %eax,%eax
8010771c:	74 22                	je     80107740 <trap+0x27b>
8010771e:	e8 29 cb ff ff       	call   8010424c <myproc>
80107723:	8b 40 24             	mov    0x24(%eax),%eax
80107726:	85 c0                	test   %eax,%eax
80107728:	74 16                	je     80107740 <trap+0x27b>
8010772a:	8b 45 08             	mov    0x8(%ebp),%eax
8010772d:	8b 40 3c             	mov    0x3c(%eax),%eax
80107730:	0f b7 c0             	movzwl %ax,%eax
80107733:	83 e0 03             	and    $0x3,%eax
80107736:	83 f8 03             	cmp    $0x3,%eax
80107739:	75 05                	jne    80107740 <trap+0x27b>
    exit();
8010773b:	e8 ce d0 ff ff       	call   8010480e <exit>
}
80107740:	83 c4 4c             	add    $0x4c,%esp
80107743:	5b                   	pop    %ebx
80107744:	5e                   	pop    %esi
80107745:	5f                   	pop    %edi
80107746:	5d                   	pop    %ebp
80107747:	c3                   	ret    

80107748 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80107748:	55                   	push   %ebp
80107749:	89 e5                	mov    %esp,%ebp
8010774b:	83 ec 14             	sub    $0x14,%esp
8010774e:	8b 45 08             	mov    0x8(%ebp),%eax
80107751:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107755:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107758:	89 c2                	mov    %eax,%edx
8010775a:	ec                   	in     (%dx),%al
8010775b:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010775e:	8a 45 ff             	mov    -0x1(%ebp),%al
}
80107761:	c9                   	leave  
80107762:	c3                   	ret    

80107763 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80107763:	55                   	push   %ebp
80107764:	89 e5                	mov    %esp,%ebp
80107766:	83 ec 08             	sub    $0x8,%esp
80107769:	8b 45 08             	mov    0x8(%ebp),%eax
8010776c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010776f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
80107773:	88 55 f8             	mov    %dl,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107776:	8a 45 f8             	mov    -0x8(%ebp),%al
80107779:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010777c:	ee                   	out    %al,(%dx)
}
8010777d:	c9                   	leave  
8010777e:	c3                   	ret    

8010777f <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
8010777f:	55                   	push   %ebp
80107780:	89 e5                	mov    %esp,%ebp
80107782:	83 ec 28             	sub    $0x28,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80107785:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010778c:	00 
8010778d:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107794:	e8 ca ff ff ff       	call   80107763 <outb>

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107799:	c7 44 24 04 80 00 00 	movl   $0x80,0x4(%esp)
801077a0:	00 
801077a1:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801077a8:	e8 b6 ff ff ff       	call   80107763 <outb>
  outb(COM1+0, 115200/9600);
801077ad:	c7 44 24 04 0c 00 00 	movl   $0xc,0x4(%esp)
801077b4:	00 
801077b5:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801077bc:	e8 a2 ff ff ff       	call   80107763 <outb>
  outb(COM1+1, 0);
801077c1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801077c8:	00 
801077c9:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
801077d0:	e8 8e ff ff ff       	call   80107763 <outb>
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
801077d5:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
801077dc:	00 
801077dd:	c7 04 24 fb 03 00 00 	movl   $0x3fb,(%esp)
801077e4:	e8 7a ff ff ff       	call   80107763 <outb>
  outb(COM1+4, 0);
801077e9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801077f0:	00 
801077f1:	c7 04 24 fc 03 00 00 	movl   $0x3fc,(%esp)
801077f8:	e8 66 ff ff ff       	call   80107763 <outb>
  outb(COM1+1, 0x01);    // Enable receive interrupts.
801077fd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
80107804:	00 
80107805:	c7 04 24 f9 03 00 00 	movl   $0x3f9,(%esp)
8010780c:	e8 52 ff ff ff       	call   80107763 <outb>

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107811:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
80107818:	e8 2b ff ff ff       	call   80107748 <inb>
8010781d:	3c ff                	cmp    $0xff,%al
8010781f:	75 02                	jne    80107823 <uartinit+0xa4>
    return;
80107821:	eb 5b                	jmp    8010787e <uartinit+0xff>
  uart = 1;
80107823:	c7 05 84 c7 10 80 01 	movl   $0x1,0x8010c784
8010782a:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010782d:	c7 04 24 fa 03 00 00 	movl   $0x3fa,(%esp)
80107834:	e8 0f ff ff ff       	call   80107748 <inb>
  inb(COM1+0);
80107839:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107840:	e8 03 ff ff ff       	call   80107748 <inb>
  ioapicenable(IRQ_COM1, 0);
80107845:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010784c:	00 
8010784d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80107854:	e8 c2 b3 ff ff       	call   80102c1b <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107859:	c7 45 f4 f8 9a 10 80 	movl   $0x80109af8,-0xc(%ebp)
80107860:	eb 13                	jmp    80107875 <uartinit+0xf6>
    uartputc(*p);
80107862:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107865:	8a 00                	mov    (%eax),%al
80107867:	0f be c0             	movsbl %al,%eax
8010786a:	89 04 24             	mov    %eax,(%esp)
8010786d:	e8 0e 00 00 00       	call   80107880 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80107872:	ff 45 f4             	incl   -0xc(%ebp)
80107875:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107878:	8a 00                	mov    (%eax),%al
8010787a:	84 c0                	test   %al,%al
8010787c:	75 e4                	jne    80107862 <uartinit+0xe3>
    uartputc(*p);
}
8010787e:	c9                   	leave  
8010787f:	c3                   	ret    

80107880 <uartputc>:

void
uartputc(int c)
{
80107880:	55                   	push   %ebp
80107881:	89 e5                	mov    %esp,%ebp
80107883:	83 ec 28             	sub    $0x28,%esp
  int i;

  if(!uart)
80107886:	a1 84 c7 10 80       	mov    0x8010c784,%eax
8010788b:	85 c0                	test   %eax,%eax
8010788d:	75 02                	jne    80107891 <uartputc+0x11>
    return;
8010788f:	eb 4a                	jmp    801078db <uartputc+0x5b>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80107891:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107898:	eb 0f                	jmp    801078a9 <uartputc+0x29>
    microdelay(10);
8010789a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801078a1:	e8 a6 b8 ff ff       	call   8010314c <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801078a6:	ff 45 f4             	incl   -0xc(%ebp)
801078a9:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801078ad:	7f 16                	jg     801078c5 <uartputc+0x45>
801078af:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801078b6:	e8 8d fe ff ff       	call   80107748 <inb>
801078bb:	0f b6 c0             	movzbl %al,%eax
801078be:	83 e0 20             	and    $0x20,%eax
801078c1:	85 c0                	test   %eax,%eax
801078c3:	74 d5                	je     8010789a <uartputc+0x1a>
    microdelay(10);
  outb(COM1+0, c);
801078c5:	8b 45 08             	mov    0x8(%ebp),%eax
801078c8:	0f b6 c0             	movzbl %al,%eax
801078cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801078cf:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
801078d6:	e8 88 fe ff ff       	call   80107763 <outb>
}
801078db:	c9                   	leave  
801078dc:	c3                   	ret    

801078dd <uartgetc>:

static int
uartgetc(void)
{
801078dd:	55                   	push   %ebp
801078de:	89 e5                	mov    %esp,%ebp
801078e0:	83 ec 04             	sub    $0x4,%esp
  if(!uart)
801078e3:	a1 84 c7 10 80       	mov    0x8010c784,%eax
801078e8:	85 c0                	test   %eax,%eax
801078ea:	75 07                	jne    801078f3 <uartgetc+0x16>
    return -1;
801078ec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801078f1:	eb 2c                	jmp    8010791f <uartgetc+0x42>
  if(!(inb(COM1+5) & 0x01))
801078f3:	c7 04 24 fd 03 00 00 	movl   $0x3fd,(%esp)
801078fa:	e8 49 fe ff ff       	call   80107748 <inb>
801078ff:	0f b6 c0             	movzbl %al,%eax
80107902:	83 e0 01             	and    $0x1,%eax
80107905:	85 c0                	test   %eax,%eax
80107907:	75 07                	jne    80107910 <uartgetc+0x33>
    return -1;
80107909:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010790e:	eb 0f                	jmp    8010791f <uartgetc+0x42>
  return inb(COM1+0);
80107910:	c7 04 24 f8 03 00 00 	movl   $0x3f8,(%esp)
80107917:	e8 2c fe ff ff       	call   80107748 <inb>
8010791c:	0f b6 c0             	movzbl %al,%eax
}
8010791f:	c9                   	leave  
80107920:	c3                   	ret    

80107921 <uartintr>:

void
uartintr(void)
{
80107921:	55                   	push   %ebp
80107922:	89 e5                	mov    %esp,%ebp
80107924:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
80107927:	c7 04 24 dd 78 10 80 	movl   $0x801078dd,(%esp)
8010792e:	e8 c2 8e ff ff       	call   801007f5 <consoleintr>
}
80107933:	c9                   	leave  
80107934:	c3                   	ret    
80107935:	00 00                	add    %al,(%eax)
	...

80107938 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107938:	6a 00                	push   $0x0
  pushl $0
8010793a:	6a 00                	push   $0x0
  jmp alltraps
8010793c:	e9 af f9 ff ff       	jmp    801072f0 <alltraps>

80107941 <vector1>:
.globl vector1
vector1:
  pushl $0
80107941:	6a 00                	push   $0x0
  pushl $1
80107943:	6a 01                	push   $0x1
  jmp alltraps
80107945:	e9 a6 f9 ff ff       	jmp    801072f0 <alltraps>

8010794a <vector2>:
.globl vector2
vector2:
  pushl $0
8010794a:	6a 00                	push   $0x0
  pushl $2
8010794c:	6a 02                	push   $0x2
  jmp alltraps
8010794e:	e9 9d f9 ff ff       	jmp    801072f0 <alltraps>

80107953 <vector3>:
.globl vector3
vector3:
  pushl $0
80107953:	6a 00                	push   $0x0
  pushl $3
80107955:	6a 03                	push   $0x3
  jmp alltraps
80107957:	e9 94 f9 ff ff       	jmp    801072f0 <alltraps>

8010795c <vector4>:
.globl vector4
vector4:
  pushl $0
8010795c:	6a 00                	push   $0x0
  pushl $4
8010795e:	6a 04                	push   $0x4
  jmp alltraps
80107960:	e9 8b f9 ff ff       	jmp    801072f0 <alltraps>

80107965 <vector5>:
.globl vector5
vector5:
  pushl $0
80107965:	6a 00                	push   $0x0
  pushl $5
80107967:	6a 05                	push   $0x5
  jmp alltraps
80107969:	e9 82 f9 ff ff       	jmp    801072f0 <alltraps>

8010796e <vector6>:
.globl vector6
vector6:
  pushl $0
8010796e:	6a 00                	push   $0x0
  pushl $6
80107970:	6a 06                	push   $0x6
  jmp alltraps
80107972:	e9 79 f9 ff ff       	jmp    801072f0 <alltraps>

80107977 <vector7>:
.globl vector7
vector7:
  pushl $0
80107977:	6a 00                	push   $0x0
  pushl $7
80107979:	6a 07                	push   $0x7
  jmp alltraps
8010797b:	e9 70 f9 ff ff       	jmp    801072f0 <alltraps>

80107980 <vector8>:
.globl vector8
vector8:
  pushl $8
80107980:	6a 08                	push   $0x8
  jmp alltraps
80107982:	e9 69 f9 ff ff       	jmp    801072f0 <alltraps>

80107987 <vector9>:
.globl vector9
vector9:
  pushl $0
80107987:	6a 00                	push   $0x0
  pushl $9
80107989:	6a 09                	push   $0x9
  jmp alltraps
8010798b:	e9 60 f9 ff ff       	jmp    801072f0 <alltraps>

80107990 <vector10>:
.globl vector10
vector10:
  pushl $10
80107990:	6a 0a                	push   $0xa
  jmp alltraps
80107992:	e9 59 f9 ff ff       	jmp    801072f0 <alltraps>

80107997 <vector11>:
.globl vector11
vector11:
  pushl $11
80107997:	6a 0b                	push   $0xb
  jmp alltraps
80107999:	e9 52 f9 ff ff       	jmp    801072f0 <alltraps>

8010799e <vector12>:
.globl vector12
vector12:
  pushl $12
8010799e:	6a 0c                	push   $0xc
  jmp alltraps
801079a0:	e9 4b f9 ff ff       	jmp    801072f0 <alltraps>

801079a5 <vector13>:
.globl vector13
vector13:
  pushl $13
801079a5:	6a 0d                	push   $0xd
  jmp alltraps
801079a7:	e9 44 f9 ff ff       	jmp    801072f0 <alltraps>

801079ac <vector14>:
.globl vector14
vector14:
  pushl $14
801079ac:	6a 0e                	push   $0xe
  jmp alltraps
801079ae:	e9 3d f9 ff ff       	jmp    801072f0 <alltraps>

801079b3 <vector15>:
.globl vector15
vector15:
  pushl $0
801079b3:	6a 00                	push   $0x0
  pushl $15
801079b5:	6a 0f                	push   $0xf
  jmp alltraps
801079b7:	e9 34 f9 ff ff       	jmp    801072f0 <alltraps>

801079bc <vector16>:
.globl vector16
vector16:
  pushl $0
801079bc:	6a 00                	push   $0x0
  pushl $16
801079be:	6a 10                	push   $0x10
  jmp alltraps
801079c0:	e9 2b f9 ff ff       	jmp    801072f0 <alltraps>

801079c5 <vector17>:
.globl vector17
vector17:
  pushl $17
801079c5:	6a 11                	push   $0x11
  jmp alltraps
801079c7:	e9 24 f9 ff ff       	jmp    801072f0 <alltraps>

801079cc <vector18>:
.globl vector18
vector18:
  pushl $0
801079cc:	6a 00                	push   $0x0
  pushl $18
801079ce:	6a 12                	push   $0x12
  jmp alltraps
801079d0:	e9 1b f9 ff ff       	jmp    801072f0 <alltraps>

801079d5 <vector19>:
.globl vector19
vector19:
  pushl $0
801079d5:	6a 00                	push   $0x0
  pushl $19
801079d7:	6a 13                	push   $0x13
  jmp alltraps
801079d9:	e9 12 f9 ff ff       	jmp    801072f0 <alltraps>

801079de <vector20>:
.globl vector20
vector20:
  pushl $0
801079de:	6a 00                	push   $0x0
  pushl $20
801079e0:	6a 14                	push   $0x14
  jmp alltraps
801079e2:	e9 09 f9 ff ff       	jmp    801072f0 <alltraps>

801079e7 <vector21>:
.globl vector21
vector21:
  pushl $0
801079e7:	6a 00                	push   $0x0
  pushl $21
801079e9:	6a 15                	push   $0x15
  jmp alltraps
801079eb:	e9 00 f9 ff ff       	jmp    801072f0 <alltraps>

801079f0 <vector22>:
.globl vector22
vector22:
  pushl $0
801079f0:	6a 00                	push   $0x0
  pushl $22
801079f2:	6a 16                	push   $0x16
  jmp alltraps
801079f4:	e9 f7 f8 ff ff       	jmp    801072f0 <alltraps>

801079f9 <vector23>:
.globl vector23
vector23:
  pushl $0
801079f9:	6a 00                	push   $0x0
  pushl $23
801079fb:	6a 17                	push   $0x17
  jmp alltraps
801079fd:	e9 ee f8 ff ff       	jmp    801072f0 <alltraps>

80107a02 <vector24>:
.globl vector24
vector24:
  pushl $0
80107a02:	6a 00                	push   $0x0
  pushl $24
80107a04:	6a 18                	push   $0x18
  jmp alltraps
80107a06:	e9 e5 f8 ff ff       	jmp    801072f0 <alltraps>

80107a0b <vector25>:
.globl vector25
vector25:
  pushl $0
80107a0b:	6a 00                	push   $0x0
  pushl $25
80107a0d:	6a 19                	push   $0x19
  jmp alltraps
80107a0f:	e9 dc f8 ff ff       	jmp    801072f0 <alltraps>

80107a14 <vector26>:
.globl vector26
vector26:
  pushl $0
80107a14:	6a 00                	push   $0x0
  pushl $26
80107a16:	6a 1a                	push   $0x1a
  jmp alltraps
80107a18:	e9 d3 f8 ff ff       	jmp    801072f0 <alltraps>

80107a1d <vector27>:
.globl vector27
vector27:
  pushl $0
80107a1d:	6a 00                	push   $0x0
  pushl $27
80107a1f:	6a 1b                	push   $0x1b
  jmp alltraps
80107a21:	e9 ca f8 ff ff       	jmp    801072f0 <alltraps>

80107a26 <vector28>:
.globl vector28
vector28:
  pushl $0
80107a26:	6a 00                	push   $0x0
  pushl $28
80107a28:	6a 1c                	push   $0x1c
  jmp alltraps
80107a2a:	e9 c1 f8 ff ff       	jmp    801072f0 <alltraps>

80107a2f <vector29>:
.globl vector29
vector29:
  pushl $0
80107a2f:	6a 00                	push   $0x0
  pushl $29
80107a31:	6a 1d                	push   $0x1d
  jmp alltraps
80107a33:	e9 b8 f8 ff ff       	jmp    801072f0 <alltraps>

80107a38 <vector30>:
.globl vector30
vector30:
  pushl $0
80107a38:	6a 00                	push   $0x0
  pushl $30
80107a3a:	6a 1e                	push   $0x1e
  jmp alltraps
80107a3c:	e9 af f8 ff ff       	jmp    801072f0 <alltraps>

80107a41 <vector31>:
.globl vector31
vector31:
  pushl $0
80107a41:	6a 00                	push   $0x0
  pushl $31
80107a43:	6a 1f                	push   $0x1f
  jmp alltraps
80107a45:	e9 a6 f8 ff ff       	jmp    801072f0 <alltraps>

80107a4a <vector32>:
.globl vector32
vector32:
  pushl $0
80107a4a:	6a 00                	push   $0x0
  pushl $32
80107a4c:	6a 20                	push   $0x20
  jmp alltraps
80107a4e:	e9 9d f8 ff ff       	jmp    801072f0 <alltraps>

80107a53 <vector33>:
.globl vector33
vector33:
  pushl $0
80107a53:	6a 00                	push   $0x0
  pushl $33
80107a55:	6a 21                	push   $0x21
  jmp alltraps
80107a57:	e9 94 f8 ff ff       	jmp    801072f0 <alltraps>

80107a5c <vector34>:
.globl vector34
vector34:
  pushl $0
80107a5c:	6a 00                	push   $0x0
  pushl $34
80107a5e:	6a 22                	push   $0x22
  jmp alltraps
80107a60:	e9 8b f8 ff ff       	jmp    801072f0 <alltraps>

80107a65 <vector35>:
.globl vector35
vector35:
  pushl $0
80107a65:	6a 00                	push   $0x0
  pushl $35
80107a67:	6a 23                	push   $0x23
  jmp alltraps
80107a69:	e9 82 f8 ff ff       	jmp    801072f0 <alltraps>

80107a6e <vector36>:
.globl vector36
vector36:
  pushl $0
80107a6e:	6a 00                	push   $0x0
  pushl $36
80107a70:	6a 24                	push   $0x24
  jmp alltraps
80107a72:	e9 79 f8 ff ff       	jmp    801072f0 <alltraps>

80107a77 <vector37>:
.globl vector37
vector37:
  pushl $0
80107a77:	6a 00                	push   $0x0
  pushl $37
80107a79:	6a 25                	push   $0x25
  jmp alltraps
80107a7b:	e9 70 f8 ff ff       	jmp    801072f0 <alltraps>

80107a80 <vector38>:
.globl vector38
vector38:
  pushl $0
80107a80:	6a 00                	push   $0x0
  pushl $38
80107a82:	6a 26                	push   $0x26
  jmp alltraps
80107a84:	e9 67 f8 ff ff       	jmp    801072f0 <alltraps>

80107a89 <vector39>:
.globl vector39
vector39:
  pushl $0
80107a89:	6a 00                	push   $0x0
  pushl $39
80107a8b:	6a 27                	push   $0x27
  jmp alltraps
80107a8d:	e9 5e f8 ff ff       	jmp    801072f0 <alltraps>

80107a92 <vector40>:
.globl vector40
vector40:
  pushl $0
80107a92:	6a 00                	push   $0x0
  pushl $40
80107a94:	6a 28                	push   $0x28
  jmp alltraps
80107a96:	e9 55 f8 ff ff       	jmp    801072f0 <alltraps>

80107a9b <vector41>:
.globl vector41
vector41:
  pushl $0
80107a9b:	6a 00                	push   $0x0
  pushl $41
80107a9d:	6a 29                	push   $0x29
  jmp alltraps
80107a9f:	e9 4c f8 ff ff       	jmp    801072f0 <alltraps>

80107aa4 <vector42>:
.globl vector42
vector42:
  pushl $0
80107aa4:	6a 00                	push   $0x0
  pushl $42
80107aa6:	6a 2a                	push   $0x2a
  jmp alltraps
80107aa8:	e9 43 f8 ff ff       	jmp    801072f0 <alltraps>

80107aad <vector43>:
.globl vector43
vector43:
  pushl $0
80107aad:	6a 00                	push   $0x0
  pushl $43
80107aaf:	6a 2b                	push   $0x2b
  jmp alltraps
80107ab1:	e9 3a f8 ff ff       	jmp    801072f0 <alltraps>

80107ab6 <vector44>:
.globl vector44
vector44:
  pushl $0
80107ab6:	6a 00                	push   $0x0
  pushl $44
80107ab8:	6a 2c                	push   $0x2c
  jmp alltraps
80107aba:	e9 31 f8 ff ff       	jmp    801072f0 <alltraps>

80107abf <vector45>:
.globl vector45
vector45:
  pushl $0
80107abf:	6a 00                	push   $0x0
  pushl $45
80107ac1:	6a 2d                	push   $0x2d
  jmp alltraps
80107ac3:	e9 28 f8 ff ff       	jmp    801072f0 <alltraps>

80107ac8 <vector46>:
.globl vector46
vector46:
  pushl $0
80107ac8:	6a 00                	push   $0x0
  pushl $46
80107aca:	6a 2e                	push   $0x2e
  jmp alltraps
80107acc:	e9 1f f8 ff ff       	jmp    801072f0 <alltraps>

80107ad1 <vector47>:
.globl vector47
vector47:
  pushl $0
80107ad1:	6a 00                	push   $0x0
  pushl $47
80107ad3:	6a 2f                	push   $0x2f
  jmp alltraps
80107ad5:	e9 16 f8 ff ff       	jmp    801072f0 <alltraps>

80107ada <vector48>:
.globl vector48
vector48:
  pushl $0
80107ada:	6a 00                	push   $0x0
  pushl $48
80107adc:	6a 30                	push   $0x30
  jmp alltraps
80107ade:	e9 0d f8 ff ff       	jmp    801072f0 <alltraps>

80107ae3 <vector49>:
.globl vector49
vector49:
  pushl $0
80107ae3:	6a 00                	push   $0x0
  pushl $49
80107ae5:	6a 31                	push   $0x31
  jmp alltraps
80107ae7:	e9 04 f8 ff ff       	jmp    801072f0 <alltraps>

80107aec <vector50>:
.globl vector50
vector50:
  pushl $0
80107aec:	6a 00                	push   $0x0
  pushl $50
80107aee:	6a 32                	push   $0x32
  jmp alltraps
80107af0:	e9 fb f7 ff ff       	jmp    801072f0 <alltraps>

80107af5 <vector51>:
.globl vector51
vector51:
  pushl $0
80107af5:	6a 00                	push   $0x0
  pushl $51
80107af7:	6a 33                	push   $0x33
  jmp alltraps
80107af9:	e9 f2 f7 ff ff       	jmp    801072f0 <alltraps>

80107afe <vector52>:
.globl vector52
vector52:
  pushl $0
80107afe:	6a 00                	push   $0x0
  pushl $52
80107b00:	6a 34                	push   $0x34
  jmp alltraps
80107b02:	e9 e9 f7 ff ff       	jmp    801072f0 <alltraps>

80107b07 <vector53>:
.globl vector53
vector53:
  pushl $0
80107b07:	6a 00                	push   $0x0
  pushl $53
80107b09:	6a 35                	push   $0x35
  jmp alltraps
80107b0b:	e9 e0 f7 ff ff       	jmp    801072f0 <alltraps>

80107b10 <vector54>:
.globl vector54
vector54:
  pushl $0
80107b10:	6a 00                	push   $0x0
  pushl $54
80107b12:	6a 36                	push   $0x36
  jmp alltraps
80107b14:	e9 d7 f7 ff ff       	jmp    801072f0 <alltraps>

80107b19 <vector55>:
.globl vector55
vector55:
  pushl $0
80107b19:	6a 00                	push   $0x0
  pushl $55
80107b1b:	6a 37                	push   $0x37
  jmp alltraps
80107b1d:	e9 ce f7 ff ff       	jmp    801072f0 <alltraps>

80107b22 <vector56>:
.globl vector56
vector56:
  pushl $0
80107b22:	6a 00                	push   $0x0
  pushl $56
80107b24:	6a 38                	push   $0x38
  jmp alltraps
80107b26:	e9 c5 f7 ff ff       	jmp    801072f0 <alltraps>

80107b2b <vector57>:
.globl vector57
vector57:
  pushl $0
80107b2b:	6a 00                	push   $0x0
  pushl $57
80107b2d:	6a 39                	push   $0x39
  jmp alltraps
80107b2f:	e9 bc f7 ff ff       	jmp    801072f0 <alltraps>

80107b34 <vector58>:
.globl vector58
vector58:
  pushl $0
80107b34:	6a 00                	push   $0x0
  pushl $58
80107b36:	6a 3a                	push   $0x3a
  jmp alltraps
80107b38:	e9 b3 f7 ff ff       	jmp    801072f0 <alltraps>

80107b3d <vector59>:
.globl vector59
vector59:
  pushl $0
80107b3d:	6a 00                	push   $0x0
  pushl $59
80107b3f:	6a 3b                	push   $0x3b
  jmp alltraps
80107b41:	e9 aa f7 ff ff       	jmp    801072f0 <alltraps>

80107b46 <vector60>:
.globl vector60
vector60:
  pushl $0
80107b46:	6a 00                	push   $0x0
  pushl $60
80107b48:	6a 3c                	push   $0x3c
  jmp alltraps
80107b4a:	e9 a1 f7 ff ff       	jmp    801072f0 <alltraps>

80107b4f <vector61>:
.globl vector61
vector61:
  pushl $0
80107b4f:	6a 00                	push   $0x0
  pushl $61
80107b51:	6a 3d                	push   $0x3d
  jmp alltraps
80107b53:	e9 98 f7 ff ff       	jmp    801072f0 <alltraps>

80107b58 <vector62>:
.globl vector62
vector62:
  pushl $0
80107b58:	6a 00                	push   $0x0
  pushl $62
80107b5a:	6a 3e                	push   $0x3e
  jmp alltraps
80107b5c:	e9 8f f7 ff ff       	jmp    801072f0 <alltraps>

80107b61 <vector63>:
.globl vector63
vector63:
  pushl $0
80107b61:	6a 00                	push   $0x0
  pushl $63
80107b63:	6a 3f                	push   $0x3f
  jmp alltraps
80107b65:	e9 86 f7 ff ff       	jmp    801072f0 <alltraps>

80107b6a <vector64>:
.globl vector64
vector64:
  pushl $0
80107b6a:	6a 00                	push   $0x0
  pushl $64
80107b6c:	6a 40                	push   $0x40
  jmp alltraps
80107b6e:	e9 7d f7 ff ff       	jmp    801072f0 <alltraps>

80107b73 <vector65>:
.globl vector65
vector65:
  pushl $0
80107b73:	6a 00                	push   $0x0
  pushl $65
80107b75:	6a 41                	push   $0x41
  jmp alltraps
80107b77:	e9 74 f7 ff ff       	jmp    801072f0 <alltraps>

80107b7c <vector66>:
.globl vector66
vector66:
  pushl $0
80107b7c:	6a 00                	push   $0x0
  pushl $66
80107b7e:	6a 42                	push   $0x42
  jmp alltraps
80107b80:	e9 6b f7 ff ff       	jmp    801072f0 <alltraps>

80107b85 <vector67>:
.globl vector67
vector67:
  pushl $0
80107b85:	6a 00                	push   $0x0
  pushl $67
80107b87:	6a 43                	push   $0x43
  jmp alltraps
80107b89:	e9 62 f7 ff ff       	jmp    801072f0 <alltraps>

80107b8e <vector68>:
.globl vector68
vector68:
  pushl $0
80107b8e:	6a 00                	push   $0x0
  pushl $68
80107b90:	6a 44                	push   $0x44
  jmp alltraps
80107b92:	e9 59 f7 ff ff       	jmp    801072f0 <alltraps>

80107b97 <vector69>:
.globl vector69
vector69:
  pushl $0
80107b97:	6a 00                	push   $0x0
  pushl $69
80107b99:	6a 45                	push   $0x45
  jmp alltraps
80107b9b:	e9 50 f7 ff ff       	jmp    801072f0 <alltraps>

80107ba0 <vector70>:
.globl vector70
vector70:
  pushl $0
80107ba0:	6a 00                	push   $0x0
  pushl $70
80107ba2:	6a 46                	push   $0x46
  jmp alltraps
80107ba4:	e9 47 f7 ff ff       	jmp    801072f0 <alltraps>

80107ba9 <vector71>:
.globl vector71
vector71:
  pushl $0
80107ba9:	6a 00                	push   $0x0
  pushl $71
80107bab:	6a 47                	push   $0x47
  jmp alltraps
80107bad:	e9 3e f7 ff ff       	jmp    801072f0 <alltraps>

80107bb2 <vector72>:
.globl vector72
vector72:
  pushl $0
80107bb2:	6a 00                	push   $0x0
  pushl $72
80107bb4:	6a 48                	push   $0x48
  jmp alltraps
80107bb6:	e9 35 f7 ff ff       	jmp    801072f0 <alltraps>

80107bbb <vector73>:
.globl vector73
vector73:
  pushl $0
80107bbb:	6a 00                	push   $0x0
  pushl $73
80107bbd:	6a 49                	push   $0x49
  jmp alltraps
80107bbf:	e9 2c f7 ff ff       	jmp    801072f0 <alltraps>

80107bc4 <vector74>:
.globl vector74
vector74:
  pushl $0
80107bc4:	6a 00                	push   $0x0
  pushl $74
80107bc6:	6a 4a                	push   $0x4a
  jmp alltraps
80107bc8:	e9 23 f7 ff ff       	jmp    801072f0 <alltraps>

80107bcd <vector75>:
.globl vector75
vector75:
  pushl $0
80107bcd:	6a 00                	push   $0x0
  pushl $75
80107bcf:	6a 4b                	push   $0x4b
  jmp alltraps
80107bd1:	e9 1a f7 ff ff       	jmp    801072f0 <alltraps>

80107bd6 <vector76>:
.globl vector76
vector76:
  pushl $0
80107bd6:	6a 00                	push   $0x0
  pushl $76
80107bd8:	6a 4c                	push   $0x4c
  jmp alltraps
80107bda:	e9 11 f7 ff ff       	jmp    801072f0 <alltraps>

80107bdf <vector77>:
.globl vector77
vector77:
  pushl $0
80107bdf:	6a 00                	push   $0x0
  pushl $77
80107be1:	6a 4d                	push   $0x4d
  jmp alltraps
80107be3:	e9 08 f7 ff ff       	jmp    801072f0 <alltraps>

80107be8 <vector78>:
.globl vector78
vector78:
  pushl $0
80107be8:	6a 00                	push   $0x0
  pushl $78
80107bea:	6a 4e                	push   $0x4e
  jmp alltraps
80107bec:	e9 ff f6 ff ff       	jmp    801072f0 <alltraps>

80107bf1 <vector79>:
.globl vector79
vector79:
  pushl $0
80107bf1:	6a 00                	push   $0x0
  pushl $79
80107bf3:	6a 4f                	push   $0x4f
  jmp alltraps
80107bf5:	e9 f6 f6 ff ff       	jmp    801072f0 <alltraps>

80107bfa <vector80>:
.globl vector80
vector80:
  pushl $0
80107bfa:	6a 00                	push   $0x0
  pushl $80
80107bfc:	6a 50                	push   $0x50
  jmp alltraps
80107bfe:	e9 ed f6 ff ff       	jmp    801072f0 <alltraps>

80107c03 <vector81>:
.globl vector81
vector81:
  pushl $0
80107c03:	6a 00                	push   $0x0
  pushl $81
80107c05:	6a 51                	push   $0x51
  jmp alltraps
80107c07:	e9 e4 f6 ff ff       	jmp    801072f0 <alltraps>

80107c0c <vector82>:
.globl vector82
vector82:
  pushl $0
80107c0c:	6a 00                	push   $0x0
  pushl $82
80107c0e:	6a 52                	push   $0x52
  jmp alltraps
80107c10:	e9 db f6 ff ff       	jmp    801072f0 <alltraps>

80107c15 <vector83>:
.globl vector83
vector83:
  pushl $0
80107c15:	6a 00                	push   $0x0
  pushl $83
80107c17:	6a 53                	push   $0x53
  jmp alltraps
80107c19:	e9 d2 f6 ff ff       	jmp    801072f0 <alltraps>

80107c1e <vector84>:
.globl vector84
vector84:
  pushl $0
80107c1e:	6a 00                	push   $0x0
  pushl $84
80107c20:	6a 54                	push   $0x54
  jmp alltraps
80107c22:	e9 c9 f6 ff ff       	jmp    801072f0 <alltraps>

80107c27 <vector85>:
.globl vector85
vector85:
  pushl $0
80107c27:	6a 00                	push   $0x0
  pushl $85
80107c29:	6a 55                	push   $0x55
  jmp alltraps
80107c2b:	e9 c0 f6 ff ff       	jmp    801072f0 <alltraps>

80107c30 <vector86>:
.globl vector86
vector86:
  pushl $0
80107c30:	6a 00                	push   $0x0
  pushl $86
80107c32:	6a 56                	push   $0x56
  jmp alltraps
80107c34:	e9 b7 f6 ff ff       	jmp    801072f0 <alltraps>

80107c39 <vector87>:
.globl vector87
vector87:
  pushl $0
80107c39:	6a 00                	push   $0x0
  pushl $87
80107c3b:	6a 57                	push   $0x57
  jmp alltraps
80107c3d:	e9 ae f6 ff ff       	jmp    801072f0 <alltraps>

80107c42 <vector88>:
.globl vector88
vector88:
  pushl $0
80107c42:	6a 00                	push   $0x0
  pushl $88
80107c44:	6a 58                	push   $0x58
  jmp alltraps
80107c46:	e9 a5 f6 ff ff       	jmp    801072f0 <alltraps>

80107c4b <vector89>:
.globl vector89
vector89:
  pushl $0
80107c4b:	6a 00                	push   $0x0
  pushl $89
80107c4d:	6a 59                	push   $0x59
  jmp alltraps
80107c4f:	e9 9c f6 ff ff       	jmp    801072f0 <alltraps>

80107c54 <vector90>:
.globl vector90
vector90:
  pushl $0
80107c54:	6a 00                	push   $0x0
  pushl $90
80107c56:	6a 5a                	push   $0x5a
  jmp alltraps
80107c58:	e9 93 f6 ff ff       	jmp    801072f0 <alltraps>

80107c5d <vector91>:
.globl vector91
vector91:
  pushl $0
80107c5d:	6a 00                	push   $0x0
  pushl $91
80107c5f:	6a 5b                	push   $0x5b
  jmp alltraps
80107c61:	e9 8a f6 ff ff       	jmp    801072f0 <alltraps>

80107c66 <vector92>:
.globl vector92
vector92:
  pushl $0
80107c66:	6a 00                	push   $0x0
  pushl $92
80107c68:	6a 5c                	push   $0x5c
  jmp alltraps
80107c6a:	e9 81 f6 ff ff       	jmp    801072f0 <alltraps>

80107c6f <vector93>:
.globl vector93
vector93:
  pushl $0
80107c6f:	6a 00                	push   $0x0
  pushl $93
80107c71:	6a 5d                	push   $0x5d
  jmp alltraps
80107c73:	e9 78 f6 ff ff       	jmp    801072f0 <alltraps>

80107c78 <vector94>:
.globl vector94
vector94:
  pushl $0
80107c78:	6a 00                	push   $0x0
  pushl $94
80107c7a:	6a 5e                	push   $0x5e
  jmp alltraps
80107c7c:	e9 6f f6 ff ff       	jmp    801072f0 <alltraps>

80107c81 <vector95>:
.globl vector95
vector95:
  pushl $0
80107c81:	6a 00                	push   $0x0
  pushl $95
80107c83:	6a 5f                	push   $0x5f
  jmp alltraps
80107c85:	e9 66 f6 ff ff       	jmp    801072f0 <alltraps>

80107c8a <vector96>:
.globl vector96
vector96:
  pushl $0
80107c8a:	6a 00                	push   $0x0
  pushl $96
80107c8c:	6a 60                	push   $0x60
  jmp alltraps
80107c8e:	e9 5d f6 ff ff       	jmp    801072f0 <alltraps>

80107c93 <vector97>:
.globl vector97
vector97:
  pushl $0
80107c93:	6a 00                	push   $0x0
  pushl $97
80107c95:	6a 61                	push   $0x61
  jmp alltraps
80107c97:	e9 54 f6 ff ff       	jmp    801072f0 <alltraps>

80107c9c <vector98>:
.globl vector98
vector98:
  pushl $0
80107c9c:	6a 00                	push   $0x0
  pushl $98
80107c9e:	6a 62                	push   $0x62
  jmp alltraps
80107ca0:	e9 4b f6 ff ff       	jmp    801072f0 <alltraps>

80107ca5 <vector99>:
.globl vector99
vector99:
  pushl $0
80107ca5:	6a 00                	push   $0x0
  pushl $99
80107ca7:	6a 63                	push   $0x63
  jmp alltraps
80107ca9:	e9 42 f6 ff ff       	jmp    801072f0 <alltraps>

80107cae <vector100>:
.globl vector100
vector100:
  pushl $0
80107cae:	6a 00                	push   $0x0
  pushl $100
80107cb0:	6a 64                	push   $0x64
  jmp alltraps
80107cb2:	e9 39 f6 ff ff       	jmp    801072f0 <alltraps>

80107cb7 <vector101>:
.globl vector101
vector101:
  pushl $0
80107cb7:	6a 00                	push   $0x0
  pushl $101
80107cb9:	6a 65                	push   $0x65
  jmp alltraps
80107cbb:	e9 30 f6 ff ff       	jmp    801072f0 <alltraps>

80107cc0 <vector102>:
.globl vector102
vector102:
  pushl $0
80107cc0:	6a 00                	push   $0x0
  pushl $102
80107cc2:	6a 66                	push   $0x66
  jmp alltraps
80107cc4:	e9 27 f6 ff ff       	jmp    801072f0 <alltraps>

80107cc9 <vector103>:
.globl vector103
vector103:
  pushl $0
80107cc9:	6a 00                	push   $0x0
  pushl $103
80107ccb:	6a 67                	push   $0x67
  jmp alltraps
80107ccd:	e9 1e f6 ff ff       	jmp    801072f0 <alltraps>

80107cd2 <vector104>:
.globl vector104
vector104:
  pushl $0
80107cd2:	6a 00                	push   $0x0
  pushl $104
80107cd4:	6a 68                	push   $0x68
  jmp alltraps
80107cd6:	e9 15 f6 ff ff       	jmp    801072f0 <alltraps>

80107cdb <vector105>:
.globl vector105
vector105:
  pushl $0
80107cdb:	6a 00                	push   $0x0
  pushl $105
80107cdd:	6a 69                	push   $0x69
  jmp alltraps
80107cdf:	e9 0c f6 ff ff       	jmp    801072f0 <alltraps>

80107ce4 <vector106>:
.globl vector106
vector106:
  pushl $0
80107ce4:	6a 00                	push   $0x0
  pushl $106
80107ce6:	6a 6a                	push   $0x6a
  jmp alltraps
80107ce8:	e9 03 f6 ff ff       	jmp    801072f0 <alltraps>

80107ced <vector107>:
.globl vector107
vector107:
  pushl $0
80107ced:	6a 00                	push   $0x0
  pushl $107
80107cef:	6a 6b                	push   $0x6b
  jmp alltraps
80107cf1:	e9 fa f5 ff ff       	jmp    801072f0 <alltraps>

80107cf6 <vector108>:
.globl vector108
vector108:
  pushl $0
80107cf6:	6a 00                	push   $0x0
  pushl $108
80107cf8:	6a 6c                	push   $0x6c
  jmp alltraps
80107cfa:	e9 f1 f5 ff ff       	jmp    801072f0 <alltraps>

80107cff <vector109>:
.globl vector109
vector109:
  pushl $0
80107cff:	6a 00                	push   $0x0
  pushl $109
80107d01:	6a 6d                	push   $0x6d
  jmp alltraps
80107d03:	e9 e8 f5 ff ff       	jmp    801072f0 <alltraps>

80107d08 <vector110>:
.globl vector110
vector110:
  pushl $0
80107d08:	6a 00                	push   $0x0
  pushl $110
80107d0a:	6a 6e                	push   $0x6e
  jmp alltraps
80107d0c:	e9 df f5 ff ff       	jmp    801072f0 <alltraps>

80107d11 <vector111>:
.globl vector111
vector111:
  pushl $0
80107d11:	6a 00                	push   $0x0
  pushl $111
80107d13:	6a 6f                	push   $0x6f
  jmp alltraps
80107d15:	e9 d6 f5 ff ff       	jmp    801072f0 <alltraps>

80107d1a <vector112>:
.globl vector112
vector112:
  pushl $0
80107d1a:	6a 00                	push   $0x0
  pushl $112
80107d1c:	6a 70                	push   $0x70
  jmp alltraps
80107d1e:	e9 cd f5 ff ff       	jmp    801072f0 <alltraps>

80107d23 <vector113>:
.globl vector113
vector113:
  pushl $0
80107d23:	6a 00                	push   $0x0
  pushl $113
80107d25:	6a 71                	push   $0x71
  jmp alltraps
80107d27:	e9 c4 f5 ff ff       	jmp    801072f0 <alltraps>

80107d2c <vector114>:
.globl vector114
vector114:
  pushl $0
80107d2c:	6a 00                	push   $0x0
  pushl $114
80107d2e:	6a 72                	push   $0x72
  jmp alltraps
80107d30:	e9 bb f5 ff ff       	jmp    801072f0 <alltraps>

80107d35 <vector115>:
.globl vector115
vector115:
  pushl $0
80107d35:	6a 00                	push   $0x0
  pushl $115
80107d37:	6a 73                	push   $0x73
  jmp alltraps
80107d39:	e9 b2 f5 ff ff       	jmp    801072f0 <alltraps>

80107d3e <vector116>:
.globl vector116
vector116:
  pushl $0
80107d3e:	6a 00                	push   $0x0
  pushl $116
80107d40:	6a 74                	push   $0x74
  jmp alltraps
80107d42:	e9 a9 f5 ff ff       	jmp    801072f0 <alltraps>

80107d47 <vector117>:
.globl vector117
vector117:
  pushl $0
80107d47:	6a 00                	push   $0x0
  pushl $117
80107d49:	6a 75                	push   $0x75
  jmp alltraps
80107d4b:	e9 a0 f5 ff ff       	jmp    801072f0 <alltraps>

80107d50 <vector118>:
.globl vector118
vector118:
  pushl $0
80107d50:	6a 00                	push   $0x0
  pushl $118
80107d52:	6a 76                	push   $0x76
  jmp alltraps
80107d54:	e9 97 f5 ff ff       	jmp    801072f0 <alltraps>

80107d59 <vector119>:
.globl vector119
vector119:
  pushl $0
80107d59:	6a 00                	push   $0x0
  pushl $119
80107d5b:	6a 77                	push   $0x77
  jmp alltraps
80107d5d:	e9 8e f5 ff ff       	jmp    801072f0 <alltraps>

80107d62 <vector120>:
.globl vector120
vector120:
  pushl $0
80107d62:	6a 00                	push   $0x0
  pushl $120
80107d64:	6a 78                	push   $0x78
  jmp alltraps
80107d66:	e9 85 f5 ff ff       	jmp    801072f0 <alltraps>

80107d6b <vector121>:
.globl vector121
vector121:
  pushl $0
80107d6b:	6a 00                	push   $0x0
  pushl $121
80107d6d:	6a 79                	push   $0x79
  jmp alltraps
80107d6f:	e9 7c f5 ff ff       	jmp    801072f0 <alltraps>

80107d74 <vector122>:
.globl vector122
vector122:
  pushl $0
80107d74:	6a 00                	push   $0x0
  pushl $122
80107d76:	6a 7a                	push   $0x7a
  jmp alltraps
80107d78:	e9 73 f5 ff ff       	jmp    801072f0 <alltraps>

80107d7d <vector123>:
.globl vector123
vector123:
  pushl $0
80107d7d:	6a 00                	push   $0x0
  pushl $123
80107d7f:	6a 7b                	push   $0x7b
  jmp alltraps
80107d81:	e9 6a f5 ff ff       	jmp    801072f0 <alltraps>

80107d86 <vector124>:
.globl vector124
vector124:
  pushl $0
80107d86:	6a 00                	push   $0x0
  pushl $124
80107d88:	6a 7c                	push   $0x7c
  jmp alltraps
80107d8a:	e9 61 f5 ff ff       	jmp    801072f0 <alltraps>

80107d8f <vector125>:
.globl vector125
vector125:
  pushl $0
80107d8f:	6a 00                	push   $0x0
  pushl $125
80107d91:	6a 7d                	push   $0x7d
  jmp alltraps
80107d93:	e9 58 f5 ff ff       	jmp    801072f0 <alltraps>

80107d98 <vector126>:
.globl vector126
vector126:
  pushl $0
80107d98:	6a 00                	push   $0x0
  pushl $126
80107d9a:	6a 7e                	push   $0x7e
  jmp alltraps
80107d9c:	e9 4f f5 ff ff       	jmp    801072f0 <alltraps>

80107da1 <vector127>:
.globl vector127
vector127:
  pushl $0
80107da1:	6a 00                	push   $0x0
  pushl $127
80107da3:	6a 7f                	push   $0x7f
  jmp alltraps
80107da5:	e9 46 f5 ff ff       	jmp    801072f0 <alltraps>

80107daa <vector128>:
.globl vector128
vector128:
  pushl $0
80107daa:	6a 00                	push   $0x0
  pushl $128
80107dac:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107db1:	e9 3a f5 ff ff       	jmp    801072f0 <alltraps>

80107db6 <vector129>:
.globl vector129
vector129:
  pushl $0
80107db6:	6a 00                	push   $0x0
  pushl $129
80107db8:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107dbd:	e9 2e f5 ff ff       	jmp    801072f0 <alltraps>

80107dc2 <vector130>:
.globl vector130
vector130:
  pushl $0
80107dc2:	6a 00                	push   $0x0
  pushl $130
80107dc4:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107dc9:	e9 22 f5 ff ff       	jmp    801072f0 <alltraps>

80107dce <vector131>:
.globl vector131
vector131:
  pushl $0
80107dce:	6a 00                	push   $0x0
  pushl $131
80107dd0:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107dd5:	e9 16 f5 ff ff       	jmp    801072f0 <alltraps>

80107dda <vector132>:
.globl vector132
vector132:
  pushl $0
80107dda:	6a 00                	push   $0x0
  pushl $132
80107ddc:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107de1:	e9 0a f5 ff ff       	jmp    801072f0 <alltraps>

80107de6 <vector133>:
.globl vector133
vector133:
  pushl $0
80107de6:	6a 00                	push   $0x0
  pushl $133
80107de8:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107ded:	e9 fe f4 ff ff       	jmp    801072f0 <alltraps>

80107df2 <vector134>:
.globl vector134
vector134:
  pushl $0
80107df2:	6a 00                	push   $0x0
  pushl $134
80107df4:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107df9:	e9 f2 f4 ff ff       	jmp    801072f0 <alltraps>

80107dfe <vector135>:
.globl vector135
vector135:
  pushl $0
80107dfe:	6a 00                	push   $0x0
  pushl $135
80107e00:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107e05:	e9 e6 f4 ff ff       	jmp    801072f0 <alltraps>

80107e0a <vector136>:
.globl vector136
vector136:
  pushl $0
80107e0a:	6a 00                	push   $0x0
  pushl $136
80107e0c:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107e11:	e9 da f4 ff ff       	jmp    801072f0 <alltraps>

80107e16 <vector137>:
.globl vector137
vector137:
  pushl $0
80107e16:	6a 00                	push   $0x0
  pushl $137
80107e18:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107e1d:	e9 ce f4 ff ff       	jmp    801072f0 <alltraps>

80107e22 <vector138>:
.globl vector138
vector138:
  pushl $0
80107e22:	6a 00                	push   $0x0
  pushl $138
80107e24:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107e29:	e9 c2 f4 ff ff       	jmp    801072f0 <alltraps>

80107e2e <vector139>:
.globl vector139
vector139:
  pushl $0
80107e2e:	6a 00                	push   $0x0
  pushl $139
80107e30:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107e35:	e9 b6 f4 ff ff       	jmp    801072f0 <alltraps>

80107e3a <vector140>:
.globl vector140
vector140:
  pushl $0
80107e3a:	6a 00                	push   $0x0
  pushl $140
80107e3c:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107e41:	e9 aa f4 ff ff       	jmp    801072f0 <alltraps>

80107e46 <vector141>:
.globl vector141
vector141:
  pushl $0
80107e46:	6a 00                	push   $0x0
  pushl $141
80107e48:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107e4d:	e9 9e f4 ff ff       	jmp    801072f0 <alltraps>

80107e52 <vector142>:
.globl vector142
vector142:
  pushl $0
80107e52:	6a 00                	push   $0x0
  pushl $142
80107e54:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107e59:	e9 92 f4 ff ff       	jmp    801072f0 <alltraps>

80107e5e <vector143>:
.globl vector143
vector143:
  pushl $0
80107e5e:	6a 00                	push   $0x0
  pushl $143
80107e60:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107e65:	e9 86 f4 ff ff       	jmp    801072f0 <alltraps>

80107e6a <vector144>:
.globl vector144
vector144:
  pushl $0
80107e6a:	6a 00                	push   $0x0
  pushl $144
80107e6c:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107e71:	e9 7a f4 ff ff       	jmp    801072f0 <alltraps>

80107e76 <vector145>:
.globl vector145
vector145:
  pushl $0
80107e76:	6a 00                	push   $0x0
  pushl $145
80107e78:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107e7d:	e9 6e f4 ff ff       	jmp    801072f0 <alltraps>

80107e82 <vector146>:
.globl vector146
vector146:
  pushl $0
80107e82:	6a 00                	push   $0x0
  pushl $146
80107e84:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107e89:	e9 62 f4 ff ff       	jmp    801072f0 <alltraps>

80107e8e <vector147>:
.globl vector147
vector147:
  pushl $0
80107e8e:	6a 00                	push   $0x0
  pushl $147
80107e90:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107e95:	e9 56 f4 ff ff       	jmp    801072f0 <alltraps>

80107e9a <vector148>:
.globl vector148
vector148:
  pushl $0
80107e9a:	6a 00                	push   $0x0
  pushl $148
80107e9c:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107ea1:	e9 4a f4 ff ff       	jmp    801072f0 <alltraps>

80107ea6 <vector149>:
.globl vector149
vector149:
  pushl $0
80107ea6:	6a 00                	push   $0x0
  pushl $149
80107ea8:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107ead:	e9 3e f4 ff ff       	jmp    801072f0 <alltraps>

80107eb2 <vector150>:
.globl vector150
vector150:
  pushl $0
80107eb2:	6a 00                	push   $0x0
  pushl $150
80107eb4:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107eb9:	e9 32 f4 ff ff       	jmp    801072f0 <alltraps>

80107ebe <vector151>:
.globl vector151
vector151:
  pushl $0
80107ebe:	6a 00                	push   $0x0
  pushl $151
80107ec0:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107ec5:	e9 26 f4 ff ff       	jmp    801072f0 <alltraps>

80107eca <vector152>:
.globl vector152
vector152:
  pushl $0
80107eca:	6a 00                	push   $0x0
  pushl $152
80107ecc:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107ed1:	e9 1a f4 ff ff       	jmp    801072f0 <alltraps>

80107ed6 <vector153>:
.globl vector153
vector153:
  pushl $0
80107ed6:	6a 00                	push   $0x0
  pushl $153
80107ed8:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107edd:	e9 0e f4 ff ff       	jmp    801072f0 <alltraps>

80107ee2 <vector154>:
.globl vector154
vector154:
  pushl $0
80107ee2:	6a 00                	push   $0x0
  pushl $154
80107ee4:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107ee9:	e9 02 f4 ff ff       	jmp    801072f0 <alltraps>

80107eee <vector155>:
.globl vector155
vector155:
  pushl $0
80107eee:	6a 00                	push   $0x0
  pushl $155
80107ef0:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107ef5:	e9 f6 f3 ff ff       	jmp    801072f0 <alltraps>

80107efa <vector156>:
.globl vector156
vector156:
  pushl $0
80107efa:	6a 00                	push   $0x0
  pushl $156
80107efc:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107f01:	e9 ea f3 ff ff       	jmp    801072f0 <alltraps>

80107f06 <vector157>:
.globl vector157
vector157:
  pushl $0
80107f06:	6a 00                	push   $0x0
  pushl $157
80107f08:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107f0d:	e9 de f3 ff ff       	jmp    801072f0 <alltraps>

80107f12 <vector158>:
.globl vector158
vector158:
  pushl $0
80107f12:	6a 00                	push   $0x0
  pushl $158
80107f14:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107f19:	e9 d2 f3 ff ff       	jmp    801072f0 <alltraps>

80107f1e <vector159>:
.globl vector159
vector159:
  pushl $0
80107f1e:	6a 00                	push   $0x0
  pushl $159
80107f20:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107f25:	e9 c6 f3 ff ff       	jmp    801072f0 <alltraps>

80107f2a <vector160>:
.globl vector160
vector160:
  pushl $0
80107f2a:	6a 00                	push   $0x0
  pushl $160
80107f2c:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107f31:	e9 ba f3 ff ff       	jmp    801072f0 <alltraps>

80107f36 <vector161>:
.globl vector161
vector161:
  pushl $0
80107f36:	6a 00                	push   $0x0
  pushl $161
80107f38:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107f3d:	e9 ae f3 ff ff       	jmp    801072f0 <alltraps>

80107f42 <vector162>:
.globl vector162
vector162:
  pushl $0
80107f42:	6a 00                	push   $0x0
  pushl $162
80107f44:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107f49:	e9 a2 f3 ff ff       	jmp    801072f0 <alltraps>

80107f4e <vector163>:
.globl vector163
vector163:
  pushl $0
80107f4e:	6a 00                	push   $0x0
  pushl $163
80107f50:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107f55:	e9 96 f3 ff ff       	jmp    801072f0 <alltraps>

80107f5a <vector164>:
.globl vector164
vector164:
  pushl $0
80107f5a:	6a 00                	push   $0x0
  pushl $164
80107f5c:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107f61:	e9 8a f3 ff ff       	jmp    801072f0 <alltraps>

80107f66 <vector165>:
.globl vector165
vector165:
  pushl $0
80107f66:	6a 00                	push   $0x0
  pushl $165
80107f68:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107f6d:	e9 7e f3 ff ff       	jmp    801072f0 <alltraps>

80107f72 <vector166>:
.globl vector166
vector166:
  pushl $0
80107f72:	6a 00                	push   $0x0
  pushl $166
80107f74:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107f79:	e9 72 f3 ff ff       	jmp    801072f0 <alltraps>

80107f7e <vector167>:
.globl vector167
vector167:
  pushl $0
80107f7e:	6a 00                	push   $0x0
  pushl $167
80107f80:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107f85:	e9 66 f3 ff ff       	jmp    801072f0 <alltraps>

80107f8a <vector168>:
.globl vector168
vector168:
  pushl $0
80107f8a:	6a 00                	push   $0x0
  pushl $168
80107f8c:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107f91:	e9 5a f3 ff ff       	jmp    801072f0 <alltraps>

80107f96 <vector169>:
.globl vector169
vector169:
  pushl $0
80107f96:	6a 00                	push   $0x0
  pushl $169
80107f98:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107f9d:	e9 4e f3 ff ff       	jmp    801072f0 <alltraps>

80107fa2 <vector170>:
.globl vector170
vector170:
  pushl $0
80107fa2:	6a 00                	push   $0x0
  pushl $170
80107fa4:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107fa9:	e9 42 f3 ff ff       	jmp    801072f0 <alltraps>

80107fae <vector171>:
.globl vector171
vector171:
  pushl $0
80107fae:	6a 00                	push   $0x0
  pushl $171
80107fb0:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107fb5:	e9 36 f3 ff ff       	jmp    801072f0 <alltraps>

80107fba <vector172>:
.globl vector172
vector172:
  pushl $0
80107fba:	6a 00                	push   $0x0
  pushl $172
80107fbc:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107fc1:	e9 2a f3 ff ff       	jmp    801072f0 <alltraps>

80107fc6 <vector173>:
.globl vector173
vector173:
  pushl $0
80107fc6:	6a 00                	push   $0x0
  pushl $173
80107fc8:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107fcd:	e9 1e f3 ff ff       	jmp    801072f0 <alltraps>

80107fd2 <vector174>:
.globl vector174
vector174:
  pushl $0
80107fd2:	6a 00                	push   $0x0
  pushl $174
80107fd4:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107fd9:	e9 12 f3 ff ff       	jmp    801072f0 <alltraps>

80107fde <vector175>:
.globl vector175
vector175:
  pushl $0
80107fde:	6a 00                	push   $0x0
  pushl $175
80107fe0:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107fe5:	e9 06 f3 ff ff       	jmp    801072f0 <alltraps>

80107fea <vector176>:
.globl vector176
vector176:
  pushl $0
80107fea:	6a 00                	push   $0x0
  pushl $176
80107fec:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107ff1:	e9 fa f2 ff ff       	jmp    801072f0 <alltraps>

80107ff6 <vector177>:
.globl vector177
vector177:
  pushl $0
80107ff6:	6a 00                	push   $0x0
  pushl $177
80107ff8:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107ffd:	e9 ee f2 ff ff       	jmp    801072f0 <alltraps>

80108002 <vector178>:
.globl vector178
vector178:
  pushl $0
80108002:	6a 00                	push   $0x0
  pushl $178
80108004:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80108009:	e9 e2 f2 ff ff       	jmp    801072f0 <alltraps>

8010800e <vector179>:
.globl vector179
vector179:
  pushl $0
8010800e:	6a 00                	push   $0x0
  pushl $179
80108010:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80108015:	e9 d6 f2 ff ff       	jmp    801072f0 <alltraps>

8010801a <vector180>:
.globl vector180
vector180:
  pushl $0
8010801a:	6a 00                	push   $0x0
  pushl $180
8010801c:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80108021:	e9 ca f2 ff ff       	jmp    801072f0 <alltraps>

80108026 <vector181>:
.globl vector181
vector181:
  pushl $0
80108026:	6a 00                	push   $0x0
  pushl $181
80108028:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
8010802d:	e9 be f2 ff ff       	jmp    801072f0 <alltraps>

80108032 <vector182>:
.globl vector182
vector182:
  pushl $0
80108032:	6a 00                	push   $0x0
  pushl $182
80108034:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80108039:	e9 b2 f2 ff ff       	jmp    801072f0 <alltraps>

8010803e <vector183>:
.globl vector183
vector183:
  pushl $0
8010803e:	6a 00                	push   $0x0
  pushl $183
80108040:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80108045:	e9 a6 f2 ff ff       	jmp    801072f0 <alltraps>

8010804a <vector184>:
.globl vector184
vector184:
  pushl $0
8010804a:	6a 00                	push   $0x0
  pushl $184
8010804c:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80108051:	e9 9a f2 ff ff       	jmp    801072f0 <alltraps>

80108056 <vector185>:
.globl vector185
vector185:
  pushl $0
80108056:	6a 00                	push   $0x0
  pushl $185
80108058:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
8010805d:	e9 8e f2 ff ff       	jmp    801072f0 <alltraps>

80108062 <vector186>:
.globl vector186
vector186:
  pushl $0
80108062:	6a 00                	push   $0x0
  pushl $186
80108064:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80108069:	e9 82 f2 ff ff       	jmp    801072f0 <alltraps>

8010806e <vector187>:
.globl vector187
vector187:
  pushl $0
8010806e:	6a 00                	push   $0x0
  pushl $187
80108070:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80108075:	e9 76 f2 ff ff       	jmp    801072f0 <alltraps>

8010807a <vector188>:
.globl vector188
vector188:
  pushl $0
8010807a:	6a 00                	push   $0x0
  pushl $188
8010807c:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80108081:	e9 6a f2 ff ff       	jmp    801072f0 <alltraps>

80108086 <vector189>:
.globl vector189
vector189:
  pushl $0
80108086:	6a 00                	push   $0x0
  pushl $189
80108088:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
8010808d:	e9 5e f2 ff ff       	jmp    801072f0 <alltraps>

80108092 <vector190>:
.globl vector190
vector190:
  pushl $0
80108092:	6a 00                	push   $0x0
  pushl $190
80108094:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80108099:	e9 52 f2 ff ff       	jmp    801072f0 <alltraps>

8010809e <vector191>:
.globl vector191
vector191:
  pushl $0
8010809e:	6a 00                	push   $0x0
  pushl $191
801080a0:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
801080a5:	e9 46 f2 ff ff       	jmp    801072f0 <alltraps>

801080aa <vector192>:
.globl vector192
vector192:
  pushl $0
801080aa:	6a 00                	push   $0x0
  pushl $192
801080ac:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
801080b1:	e9 3a f2 ff ff       	jmp    801072f0 <alltraps>

801080b6 <vector193>:
.globl vector193
vector193:
  pushl $0
801080b6:	6a 00                	push   $0x0
  pushl $193
801080b8:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
801080bd:	e9 2e f2 ff ff       	jmp    801072f0 <alltraps>

801080c2 <vector194>:
.globl vector194
vector194:
  pushl $0
801080c2:	6a 00                	push   $0x0
  pushl $194
801080c4:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
801080c9:	e9 22 f2 ff ff       	jmp    801072f0 <alltraps>

801080ce <vector195>:
.globl vector195
vector195:
  pushl $0
801080ce:	6a 00                	push   $0x0
  pushl $195
801080d0:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
801080d5:	e9 16 f2 ff ff       	jmp    801072f0 <alltraps>

801080da <vector196>:
.globl vector196
vector196:
  pushl $0
801080da:	6a 00                	push   $0x0
  pushl $196
801080dc:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
801080e1:	e9 0a f2 ff ff       	jmp    801072f0 <alltraps>

801080e6 <vector197>:
.globl vector197
vector197:
  pushl $0
801080e6:	6a 00                	push   $0x0
  pushl $197
801080e8:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
801080ed:	e9 fe f1 ff ff       	jmp    801072f0 <alltraps>

801080f2 <vector198>:
.globl vector198
vector198:
  pushl $0
801080f2:	6a 00                	push   $0x0
  pushl $198
801080f4:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
801080f9:	e9 f2 f1 ff ff       	jmp    801072f0 <alltraps>

801080fe <vector199>:
.globl vector199
vector199:
  pushl $0
801080fe:	6a 00                	push   $0x0
  pushl $199
80108100:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80108105:	e9 e6 f1 ff ff       	jmp    801072f0 <alltraps>

8010810a <vector200>:
.globl vector200
vector200:
  pushl $0
8010810a:	6a 00                	push   $0x0
  pushl $200
8010810c:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80108111:	e9 da f1 ff ff       	jmp    801072f0 <alltraps>

80108116 <vector201>:
.globl vector201
vector201:
  pushl $0
80108116:	6a 00                	push   $0x0
  pushl $201
80108118:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
8010811d:	e9 ce f1 ff ff       	jmp    801072f0 <alltraps>

80108122 <vector202>:
.globl vector202
vector202:
  pushl $0
80108122:	6a 00                	push   $0x0
  pushl $202
80108124:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80108129:	e9 c2 f1 ff ff       	jmp    801072f0 <alltraps>

8010812e <vector203>:
.globl vector203
vector203:
  pushl $0
8010812e:	6a 00                	push   $0x0
  pushl $203
80108130:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80108135:	e9 b6 f1 ff ff       	jmp    801072f0 <alltraps>

8010813a <vector204>:
.globl vector204
vector204:
  pushl $0
8010813a:	6a 00                	push   $0x0
  pushl $204
8010813c:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80108141:	e9 aa f1 ff ff       	jmp    801072f0 <alltraps>

80108146 <vector205>:
.globl vector205
vector205:
  pushl $0
80108146:	6a 00                	push   $0x0
  pushl $205
80108148:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
8010814d:	e9 9e f1 ff ff       	jmp    801072f0 <alltraps>

80108152 <vector206>:
.globl vector206
vector206:
  pushl $0
80108152:	6a 00                	push   $0x0
  pushl $206
80108154:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80108159:	e9 92 f1 ff ff       	jmp    801072f0 <alltraps>

8010815e <vector207>:
.globl vector207
vector207:
  pushl $0
8010815e:	6a 00                	push   $0x0
  pushl $207
80108160:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80108165:	e9 86 f1 ff ff       	jmp    801072f0 <alltraps>

8010816a <vector208>:
.globl vector208
vector208:
  pushl $0
8010816a:	6a 00                	push   $0x0
  pushl $208
8010816c:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80108171:	e9 7a f1 ff ff       	jmp    801072f0 <alltraps>

80108176 <vector209>:
.globl vector209
vector209:
  pushl $0
80108176:	6a 00                	push   $0x0
  pushl $209
80108178:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
8010817d:	e9 6e f1 ff ff       	jmp    801072f0 <alltraps>

80108182 <vector210>:
.globl vector210
vector210:
  pushl $0
80108182:	6a 00                	push   $0x0
  pushl $210
80108184:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80108189:	e9 62 f1 ff ff       	jmp    801072f0 <alltraps>

8010818e <vector211>:
.globl vector211
vector211:
  pushl $0
8010818e:	6a 00                	push   $0x0
  pushl $211
80108190:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80108195:	e9 56 f1 ff ff       	jmp    801072f0 <alltraps>

8010819a <vector212>:
.globl vector212
vector212:
  pushl $0
8010819a:	6a 00                	push   $0x0
  pushl $212
8010819c:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
801081a1:	e9 4a f1 ff ff       	jmp    801072f0 <alltraps>

801081a6 <vector213>:
.globl vector213
vector213:
  pushl $0
801081a6:	6a 00                	push   $0x0
  pushl $213
801081a8:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
801081ad:	e9 3e f1 ff ff       	jmp    801072f0 <alltraps>

801081b2 <vector214>:
.globl vector214
vector214:
  pushl $0
801081b2:	6a 00                	push   $0x0
  pushl $214
801081b4:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
801081b9:	e9 32 f1 ff ff       	jmp    801072f0 <alltraps>

801081be <vector215>:
.globl vector215
vector215:
  pushl $0
801081be:	6a 00                	push   $0x0
  pushl $215
801081c0:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
801081c5:	e9 26 f1 ff ff       	jmp    801072f0 <alltraps>

801081ca <vector216>:
.globl vector216
vector216:
  pushl $0
801081ca:	6a 00                	push   $0x0
  pushl $216
801081cc:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
801081d1:	e9 1a f1 ff ff       	jmp    801072f0 <alltraps>

801081d6 <vector217>:
.globl vector217
vector217:
  pushl $0
801081d6:	6a 00                	push   $0x0
  pushl $217
801081d8:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
801081dd:	e9 0e f1 ff ff       	jmp    801072f0 <alltraps>

801081e2 <vector218>:
.globl vector218
vector218:
  pushl $0
801081e2:	6a 00                	push   $0x0
  pushl $218
801081e4:	68 da 00 00 00       	push   $0xda
  jmp alltraps
801081e9:	e9 02 f1 ff ff       	jmp    801072f0 <alltraps>

801081ee <vector219>:
.globl vector219
vector219:
  pushl $0
801081ee:	6a 00                	push   $0x0
  pushl $219
801081f0:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
801081f5:	e9 f6 f0 ff ff       	jmp    801072f0 <alltraps>

801081fa <vector220>:
.globl vector220
vector220:
  pushl $0
801081fa:	6a 00                	push   $0x0
  pushl $220
801081fc:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80108201:	e9 ea f0 ff ff       	jmp    801072f0 <alltraps>

80108206 <vector221>:
.globl vector221
vector221:
  pushl $0
80108206:	6a 00                	push   $0x0
  pushl $221
80108208:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
8010820d:	e9 de f0 ff ff       	jmp    801072f0 <alltraps>

80108212 <vector222>:
.globl vector222
vector222:
  pushl $0
80108212:	6a 00                	push   $0x0
  pushl $222
80108214:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80108219:	e9 d2 f0 ff ff       	jmp    801072f0 <alltraps>

8010821e <vector223>:
.globl vector223
vector223:
  pushl $0
8010821e:	6a 00                	push   $0x0
  pushl $223
80108220:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80108225:	e9 c6 f0 ff ff       	jmp    801072f0 <alltraps>

8010822a <vector224>:
.globl vector224
vector224:
  pushl $0
8010822a:	6a 00                	push   $0x0
  pushl $224
8010822c:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80108231:	e9 ba f0 ff ff       	jmp    801072f0 <alltraps>

80108236 <vector225>:
.globl vector225
vector225:
  pushl $0
80108236:	6a 00                	push   $0x0
  pushl $225
80108238:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
8010823d:	e9 ae f0 ff ff       	jmp    801072f0 <alltraps>

80108242 <vector226>:
.globl vector226
vector226:
  pushl $0
80108242:	6a 00                	push   $0x0
  pushl $226
80108244:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80108249:	e9 a2 f0 ff ff       	jmp    801072f0 <alltraps>

8010824e <vector227>:
.globl vector227
vector227:
  pushl $0
8010824e:	6a 00                	push   $0x0
  pushl $227
80108250:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80108255:	e9 96 f0 ff ff       	jmp    801072f0 <alltraps>

8010825a <vector228>:
.globl vector228
vector228:
  pushl $0
8010825a:	6a 00                	push   $0x0
  pushl $228
8010825c:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80108261:	e9 8a f0 ff ff       	jmp    801072f0 <alltraps>

80108266 <vector229>:
.globl vector229
vector229:
  pushl $0
80108266:	6a 00                	push   $0x0
  pushl $229
80108268:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
8010826d:	e9 7e f0 ff ff       	jmp    801072f0 <alltraps>

80108272 <vector230>:
.globl vector230
vector230:
  pushl $0
80108272:	6a 00                	push   $0x0
  pushl $230
80108274:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80108279:	e9 72 f0 ff ff       	jmp    801072f0 <alltraps>

8010827e <vector231>:
.globl vector231
vector231:
  pushl $0
8010827e:	6a 00                	push   $0x0
  pushl $231
80108280:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80108285:	e9 66 f0 ff ff       	jmp    801072f0 <alltraps>

8010828a <vector232>:
.globl vector232
vector232:
  pushl $0
8010828a:	6a 00                	push   $0x0
  pushl $232
8010828c:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80108291:	e9 5a f0 ff ff       	jmp    801072f0 <alltraps>

80108296 <vector233>:
.globl vector233
vector233:
  pushl $0
80108296:	6a 00                	push   $0x0
  pushl $233
80108298:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010829d:	e9 4e f0 ff ff       	jmp    801072f0 <alltraps>

801082a2 <vector234>:
.globl vector234
vector234:
  pushl $0
801082a2:	6a 00                	push   $0x0
  pushl $234
801082a4:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
801082a9:	e9 42 f0 ff ff       	jmp    801072f0 <alltraps>

801082ae <vector235>:
.globl vector235
vector235:
  pushl $0
801082ae:	6a 00                	push   $0x0
  pushl $235
801082b0:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
801082b5:	e9 36 f0 ff ff       	jmp    801072f0 <alltraps>

801082ba <vector236>:
.globl vector236
vector236:
  pushl $0
801082ba:	6a 00                	push   $0x0
  pushl $236
801082bc:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
801082c1:	e9 2a f0 ff ff       	jmp    801072f0 <alltraps>

801082c6 <vector237>:
.globl vector237
vector237:
  pushl $0
801082c6:	6a 00                	push   $0x0
  pushl $237
801082c8:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
801082cd:	e9 1e f0 ff ff       	jmp    801072f0 <alltraps>

801082d2 <vector238>:
.globl vector238
vector238:
  pushl $0
801082d2:	6a 00                	push   $0x0
  pushl $238
801082d4:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
801082d9:	e9 12 f0 ff ff       	jmp    801072f0 <alltraps>

801082de <vector239>:
.globl vector239
vector239:
  pushl $0
801082de:	6a 00                	push   $0x0
  pushl $239
801082e0:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
801082e5:	e9 06 f0 ff ff       	jmp    801072f0 <alltraps>

801082ea <vector240>:
.globl vector240
vector240:
  pushl $0
801082ea:	6a 00                	push   $0x0
  pushl $240
801082ec:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
801082f1:	e9 fa ef ff ff       	jmp    801072f0 <alltraps>

801082f6 <vector241>:
.globl vector241
vector241:
  pushl $0
801082f6:	6a 00                	push   $0x0
  pushl $241
801082f8:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
801082fd:	e9 ee ef ff ff       	jmp    801072f0 <alltraps>

80108302 <vector242>:
.globl vector242
vector242:
  pushl $0
80108302:	6a 00                	push   $0x0
  pushl $242
80108304:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80108309:	e9 e2 ef ff ff       	jmp    801072f0 <alltraps>

8010830e <vector243>:
.globl vector243
vector243:
  pushl $0
8010830e:	6a 00                	push   $0x0
  pushl $243
80108310:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80108315:	e9 d6 ef ff ff       	jmp    801072f0 <alltraps>

8010831a <vector244>:
.globl vector244
vector244:
  pushl $0
8010831a:	6a 00                	push   $0x0
  pushl $244
8010831c:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80108321:	e9 ca ef ff ff       	jmp    801072f0 <alltraps>

80108326 <vector245>:
.globl vector245
vector245:
  pushl $0
80108326:	6a 00                	push   $0x0
  pushl $245
80108328:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010832d:	e9 be ef ff ff       	jmp    801072f0 <alltraps>

80108332 <vector246>:
.globl vector246
vector246:
  pushl $0
80108332:	6a 00                	push   $0x0
  pushl $246
80108334:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80108339:	e9 b2 ef ff ff       	jmp    801072f0 <alltraps>

8010833e <vector247>:
.globl vector247
vector247:
  pushl $0
8010833e:	6a 00                	push   $0x0
  pushl $247
80108340:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80108345:	e9 a6 ef ff ff       	jmp    801072f0 <alltraps>

8010834a <vector248>:
.globl vector248
vector248:
  pushl $0
8010834a:	6a 00                	push   $0x0
  pushl $248
8010834c:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80108351:	e9 9a ef ff ff       	jmp    801072f0 <alltraps>

80108356 <vector249>:
.globl vector249
vector249:
  pushl $0
80108356:	6a 00                	push   $0x0
  pushl $249
80108358:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
8010835d:	e9 8e ef ff ff       	jmp    801072f0 <alltraps>

80108362 <vector250>:
.globl vector250
vector250:
  pushl $0
80108362:	6a 00                	push   $0x0
  pushl $250
80108364:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80108369:	e9 82 ef ff ff       	jmp    801072f0 <alltraps>

8010836e <vector251>:
.globl vector251
vector251:
  pushl $0
8010836e:	6a 00                	push   $0x0
  pushl $251
80108370:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80108375:	e9 76 ef ff ff       	jmp    801072f0 <alltraps>

8010837a <vector252>:
.globl vector252
vector252:
  pushl $0
8010837a:	6a 00                	push   $0x0
  pushl $252
8010837c:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80108381:	e9 6a ef ff ff       	jmp    801072f0 <alltraps>

80108386 <vector253>:
.globl vector253
vector253:
  pushl $0
80108386:	6a 00                	push   $0x0
  pushl $253
80108388:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
8010838d:	e9 5e ef ff ff       	jmp    801072f0 <alltraps>

80108392 <vector254>:
.globl vector254
vector254:
  pushl $0
80108392:	6a 00                	push   $0x0
  pushl $254
80108394:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80108399:	e9 52 ef ff ff       	jmp    801072f0 <alltraps>

8010839e <vector255>:
.globl vector255
vector255:
  pushl $0
8010839e:	6a 00                	push   $0x0
  pushl $255
801083a0:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
801083a5:	e9 46 ef ff ff       	jmp    801072f0 <alltraps>
	...

801083ac <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
801083ac:	55                   	push   %ebp
801083ad:	89 e5                	mov    %esp,%ebp
801083af:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
801083b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801083b5:	48                   	dec    %eax
801083b6:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
801083ba:	8b 45 08             	mov    0x8(%ebp),%eax
801083bd:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801083c1:	8b 45 08             	mov    0x8(%ebp),%eax
801083c4:	c1 e8 10             	shr    $0x10,%eax
801083c7:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
801083cb:	8d 45 fa             	lea    -0x6(%ebp),%eax
801083ce:	0f 01 10             	lgdtl  (%eax)
}
801083d1:	c9                   	leave  
801083d2:	c3                   	ret    

801083d3 <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
801083d3:	55                   	push   %ebp
801083d4:	89 e5                	mov    %esp,%ebp
801083d6:	83 ec 04             	sub    $0x4,%esp
801083d9:	8b 45 08             	mov    0x8(%ebp),%eax
801083dc:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
801083e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801083e3:	0f 00 d8             	ltr    %ax
}
801083e6:	c9                   	leave  
801083e7:	c3                   	ret    

801083e8 <lcr3>:
  return val;
}

static inline void
lcr3(uint val)
{
801083e8:	55                   	push   %ebp
801083e9:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
801083eb:	8b 45 08             	mov    0x8(%ebp),%eax
801083ee:	0f 22 d8             	mov    %eax,%cr3
}
801083f1:	5d                   	pop    %ebp
801083f2:	c3                   	ret    

801083f3 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801083f3:	55                   	push   %ebp
801083f4:	89 e5                	mov    %esp,%ebp
801083f6:	83 ec 28             	sub    $0x28,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
801083f9:	e8 50 c9 ff ff       	call   80104d4e <cpuid>
801083fe:	89 c2                	mov    %eax,%edx
80108400:	89 d0                	mov    %edx,%eax
80108402:	c1 e0 02             	shl    $0x2,%eax
80108405:	01 d0                	add    %edx,%eax
80108407:	01 c0                	add    %eax,%eax
80108409:	01 d0                	add    %edx,%eax
8010840b:	c1 e0 04             	shl    $0x4,%eax
8010840e:	05 60 49 11 80       	add    $0x80114960,%eax
80108413:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80108416:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108419:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
8010841f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108422:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80108428:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842b:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
8010842f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108432:	8a 50 7d             	mov    0x7d(%eax),%dl
80108435:	83 e2 f0             	and    $0xfffffff0,%edx
80108438:	83 ca 0a             	or     $0xa,%edx
8010843b:	88 50 7d             	mov    %dl,0x7d(%eax)
8010843e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108441:	8a 50 7d             	mov    0x7d(%eax),%dl
80108444:	83 ca 10             	or     $0x10,%edx
80108447:	88 50 7d             	mov    %dl,0x7d(%eax)
8010844a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010844d:	8a 50 7d             	mov    0x7d(%eax),%dl
80108450:	83 e2 9f             	and    $0xffffff9f,%edx
80108453:	88 50 7d             	mov    %dl,0x7d(%eax)
80108456:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108459:	8a 50 7d             	mov    0x7d(%eax),%dl
8010845c:	83 ca 80             	or     $0xffffff80,%edx
8010845f:	88 50 7d             	mov    %dl,0x7d(%eax)
80108462:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108465:	8a 50 7e             	mov    0x7e(%eax),%dl
80108468:	83 ca 0f             	or     $0xf,%edx
8010846b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010846e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108471:	8a 50 7e             	mov    0x7e(%eax),%dl
80108474:	83 e2 ef             	and    $0xffffffef,%edx
80108477:	88 50 7e             	mov    %dl,0x7e(%eax)
8010847a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010847d:	8a 50 7e             	mov    0x7e(%eax),%dl
80108480:	83 e2 df             	and    $0xffffffdf,%edx
80108483:	88 50 7e             	mov    %dl,0x7e(%eax)
80108486:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108489:	8a 50 7e             	mov    0x7e(%eax),%dl
8010848c:	83 ca 40             	or     $0x40,%edx
8010848f:	88 50 7e             	mov    %dl,0x7e(%eax)
80108492:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108495:	8a 50 7e             	mov    0x7e(%eax),%dl
80108498:	83 ca 80             	or     $0xffffff80,%edx
8010849b:	88 50 7e             	mov    %dl,0x7e(%eax)
8010849e:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a1:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801084a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a8:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
801084af:	ff ff 
801084b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b4:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
801084bb:	00 00 
801084bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084c0:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
801084c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084ca:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801084d0:	83 e2 f0             	and    $0xfffffff0,%edx
801084d3:	83 ca 02             	or     $0x2,%edx
801084d6:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801084dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084df:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801084e5:	83 ca 10             	or     $0x10,%edx
801084e8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801084ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084f1:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
801084f7:	83 e2 9f             	and    $0xffffff9f,%edx
801084fa:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108500:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108503:	8a 90 85 00 00 00    	mov    0x85(%eax),%dl
80108509:	83 ca 80             	or     $0xffffff80,%edx
8010850c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108512:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108515:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010851b:	83 ca 0f             	or     $0xf,%edx
8010851e:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108524:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108527:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010852d:	83 e2 ef             	and    $0xffffffef,%edx
80108530:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108536:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108539:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
8010853f:	83 e2 df             	and    $0xffffffdf,%edx
80108542:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108548:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010854b:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108551:	83 ca 40             	or     $0x40,%edx
80108554:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010855a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855d:	8a 90 86 00 00 00    	mov    0x86(%eax),%dl
80108563:	83 ca 80             	or     $0xffffff80,%edx
80108566:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
8010856c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010856f:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80108576:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108579:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80108580:	ff ff 
80108582:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108585:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
8010858c:	00 00 
8010858e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108591:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80108598:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010859b:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801085a1:	83 e2 f0             	and    $0xfffffff0,%edx
801085a4:	83 ca 0a             	or     $0xa,%edx
801085a7:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801085ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085b0:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801085b6:	83 ca 10             	or     $0x10,%edx
801085b9:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801085bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085c2:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801085c8:	83 ca 60             	or     $0x60,%edx
801085cb:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801085d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085d4:	8a 90 8d 00 00 00    	mov    0x8d(%eax),%dl
801085da:	83 ca 80             	or     $0xffffff80,%edx
801085dd:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
801085e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085e6:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801085ec:	83 ca 0f             	or     $0xf,%edx
801085ef:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801085f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801085f8:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
801085fe:	83 e2 ef             	and    $0xffffffef,%edx
80108601:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010860a:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108610:	83 e2 df             	and    $0xffffffdf,%edx
80108613:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108619:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010861c:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108622:	83 ca 40             	or     $0x40,%edx
80108625:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010862b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010862e:	8a 90 8e 00 00 00    	mov    0x8e(%eax),%dl
80108634:	83 ca 80             	or     $0xffffff80,%edx
80108637:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010863d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108640:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80108647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010864a:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108651:	ff ff 
80108653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108656:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
8010865d:	00 00 
8010865f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108662:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108669:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010866c:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80108672:	83 e2 f0             	and    $0xfffffff0,%edx
80108675:	83 ca 02             	or     $0x2,%edx
80108678:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010867e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108681:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80108687:	83 ca 10             	or     $0x10,%edx
8010868a:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108690:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108693:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
80108699:	83 ca 60             	or     $0x60,%edx
8010869c:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a5:	8a 90 95 00 00 00    	mov    0x95(%eax),%dl
801086ab:	83 ca 80             	or     $0xffffff80,%edx
801086ae:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
801086b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b7:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801086bd:	83 ca 0f             	or     $0xf,%edx
801086c0:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801086c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c9:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801086cf:	83 e2 ef             	and    $0xffffffef,%edx
801086d2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801086d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086db:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801086e1:	83 e2 df             	and    $0xffffffdf,%edx
801086e4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801086ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ed:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
801086f3:	83 ca 40             	or     $0x40,%edx
801086f6:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801086fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086ff:	8a 90 96 00 00 00    	mov    0x96(%eax),%dl
80108705:	83 ca 80             	or     $0xffffff80,%edx
80108708:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010870e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108711:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80108718:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010871b:	83 c0 70             	add    $0x70,%eax
8010871e:	c7 44 24 04 30 00 00 	movl   $0x30,0x4(%esp)
80108725:	00 
80108726:	89 04 24             	mov    %eax,(%esp)
80108729:	e8 7e fc ff ff       	call   801083ac <lgdt>
}
8010872e:	c9                   	leave  
8010872f:	c3                   	ret    

80108730 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80108730:	55                   	push   %ebp
80108731:	89 e5                	mov    %esp,%ebp
80108733:	83 ec 28             	sub    $0x28,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80108736:	8b 45 0c             	mov    0xc(%ebp),%eax
80108739:	c1 e8 16             	shr    $0x16,%eax
8010873c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108743:	8b 45 08             	mov    0x8(%ebp),%eax
80108746:	01 d0                	add    %edx,%eax
80108748:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
8010874b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010874e:	8b 00                	mov    (%eax),%eax
80108750:	83 e0 01             	and    $0x1,%eax
80108753:	85 c0                	test   %eax,%eax
80108755:	74 14                	je     8010876b <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80108757:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010875a:	8b 00                	mov    (%eax),%eax
8010875c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108761:	05 00 00 00 80       	add    $0x80000000,%eax
80108766:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108769:	eb 48                	jmp    801087b3 <walkpgdir+0x83>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010876b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010876f:	74 0e                	je     8010877f <walkpgdir+0x4f>
80108771:	e8 11 a6 ff ff       	call   80102d87 <kalloc>
80108776:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108779:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010877d:	75 07                	jne    80108786 <walkpgdir+0x56>
      return 0;
8010877f:	b8 00 00 00 00       	mov    $0x0,%eax
80108784:	eb 44                	jmp    801087ca <walkpgdir+0x9a>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108786:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010878d:	00 
8010878e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108795:	00 
80108796:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108799:	89 04 24             	mov    %eax,(%esp)
8010879c:	e8 c5 d3 ff ff       	call   80105b66 <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801087a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087a4:	05 00 00 00 80       	add    $0x80000000,%eax
801087a9:	83 c8 07             	or     $0x7,%eax
801087ac:	89 c2                	mov    %eax,%edx
801087ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801087b1:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
801087b3:	8b 45 0c             	mov    0xc(%ebp),%eax
801087b6:	c1 e8 0c             	shr    $0xc,%eax
801087b9:	25 ff 03 00 00       	and    $0x3ff,%eax
801087be:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801087c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087c8:	01 d0                	add    %edx,%eax
}
801087ca:	c9                   	leave  
801087cb:	c3                   	ret    

801087cc <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
801087cc:	55                   	push   %ebp
801087cd:	89 e5                	mov    %esp,%ebp
801087cf:	83 ec 28             	sub    $0x28,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
801087d2:	8b 45 0c             	mov    0xc(%ebp),%eax
801087d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087da:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801087dd:	8b 55 0c             	mov    0xc(%ebp),%edx
801087e0:	8b 45 10             	mov    0x10(%ebp),%eax
801087e3:	01 d0                	add    %edx,%eax
801087e5:	48                   	dec    %eax
801087e6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801087eb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801087ee:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
801087f5:	00 
801087f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801087f9:	89 44 24 04          	mov    %eax,0x4(%esp)
801087fd:	8b 45 08             	mov    0x8(%ebp),%eax
80108800:	89 04 24             	mov    %eax,(%esp)
80108803:	e8 28 ff ff ff       	call   80108730 <walkpgdir>
80108808:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010880b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010880f:	75 07                	jne    80108818 <mappages+0x4c>
      return -1;
80108811:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108816:	eb 48                	jmp    80108860 <mappages+0x94>
    if(*pte & PTE_P)
80108818:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010881b:	8b 00                	mov    (%eax),%eax
8010881d:	83 e0 01             	and    $0x1,%eax
80108820:	85 c0                	test   %eax,%eax
80108822:	74 0c                	je     80108830 <mappages+0x64>
      panic("remap");
80108824:	c7 04 24 00 9b 10 80 	movl   $0x80109b00,(%esp)
8010882b:	e8 24 7d ff ff       	call   80100554 <panic>
    *pte = pa | perm | PTE_P;
80108830:	8b 45 18             	mov    0x18(%ebp),%eax
80108833:	0b 45 14             	or     0x14(%ebp),%eax
80108836:	83 c8 01             	or     $0x1,%eax
80108839:	89 c2                	mov    %eax,%edx
8010883b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010883e:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108840:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108843:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108846:	75 08                	jne    80108850 <mappages+0x84>
      break;
80108848:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108849:	b8 00 00 00 00       	mov    $0x0,%eax
8010884e:	eb 10                	jmp    80108860 <mappages+0x94>
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
    a += PGSIZE;
80108850:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108857:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
8010885e:	eb 8e                	jmp    801087ee <mappages+0x22>
  return 0;
}
80108860:	c9                   	leave  
80108861:	c3                   	ret    

80108862 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108862:	55                   	push   %ebp
80108863:	89 e5                	mov    %esp,%ebp
80108865:	53                   	push   %ebx
80108866:	83 ec 34             	sub    $0x34,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80108869:	e8 19 a5 ff ff       	call   80102d87 <kalloc>
8010886e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108871:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108875:	75 0a                	jne    80108881 <setupkvm+0x1f>
    return 0;
80108877:	b8 00 00 00 00       	mov    $0x0,%eax
8010887c:	e9 84 00 00 00       	jmp    80108905 <setupkvm+0xa3>
  memset(pgdir, 0, PGSIZE);
80108881:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108888:	00 
80108889:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108890:	00 
80108891:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108894:	89 04 24             	mov    %eax,(%esp)
80108897:	e8 ca d2 ff ff       	call   80105b66 <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010889c:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
801088a3:	eb 54                	jmp    801088f9 <setupkvm+0x97>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801088a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a8:	8b 48 0c             	mov    0xc(%eax),%ecx
801088ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ae:	8b 50 04             	mov    0x4(%eax),%edx
801088b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b4:	8b 58 08             	mov    0x8(%eax),%ebx
801088b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088ba:	8b 40 04             	mov    0x4(%eax),%eax
801088bd:	29 c3                	sub    %eax,%ebx
801088bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c2:	8b 00                	mov    (%eax),%eax
801088c4:	89 4c 24 10          	mov    %ecx,0x10(%esp)
801088c8:	89 54 24 0c          	mov    %edx,0xc(%esp)
801088cc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
801088d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801088d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088d7:	89 04 24             	mov    %eax,(%esp)
801088da:	e8 ed fe ff ff       	call   801087cc <mappages>
801088df:	85 c0                	test   %eax,%eax
801088e1:	79 12                	jns    801088f5 <setupkvm+0x93>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
801088e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801088e6:	89 04 24             	mov    %eax,(%esp)
801088e9:	e8 1a 05 00 00       	call   80108e08 <freevm>
      return 0;
801088ee:	b8 00 00 00 00       	mov    $0x0,%eax
801088f3:	eb 10                	jmp    80108905 <setupkvm+0xa3>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801088f5:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801088f9:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
80108900:	72 a3                	jb     801088a5 <setupkvm+0x43>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
80108902:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108905:	83 c4 34             	add    $0x34,%esp
80108908:	5b                   	pop    %ebx
80108909:	5d                   	pop    %ebp
8010890a:	c3                   	ret    

8010890b <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
8010890b:	55                   	push   %ebp
8010890c:	89 e5                	mov    %esp,%ebp
8010890e:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80108911:	e8 4c ff ff ff       	call   80108862 <setupkvm>
80108916:	a3 44 61 12 80       	mov    %eax,0x80126144
  switchkvm();
8010891b:	e8 02 00 00 00       	call   80108922 <switchkvm>
}
80108920:	c9                   	leave  
80108921:	c3                   	ret    

80108922 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108922:	55                   	push   %ebp
80108923:	89 e5                	mov    %esp,%ebp
80108925:	83 ec 04             	sub    $0x4,%esp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80108928:	a1 44 61 12 80       	mov    0x80126144,%eax
8010892d:	05 00 00 00 80       	add    $0x80000000,%eax
80108932:	89 04 24             	mov    %eax,(%esp)
80108935:	e8 ae fa ff ff       	call   801083e8 <lcr3>
}
8010893a:	c9                   	leave  
8010893b:	c3                   	ret    

8010893c <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010893c:	55                   	push   %ebp
8010893d:	89 e5                	mov    %esp,%ebp
8010893f:	57                   	push   %edi
80108940:	56                   	push   %esi
80108941:	53                   	push   %ebx
80108942:	83 ec 1c             	sub    $0x1c,%esp
  if(p == 0)
80108945:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108949:	75 0c                	jne    80108957 <switchuvm+0x1b>
    panic("switchuvm: no process");
8010894b:	c7 04 24 06 9b 10 80 	movl   $0x80109b06,(%esp)
80108952:	e8 fd 7b ff ff       	call   80100554 <panic>
  if(p->kstack == 0)
80108957:	8b 45 08             	mov    0x8(%ebp),%eax
8010895a:	8b 40 08             	mov    0x8(%eax),%eax
8010895d:	85 c0                	test   %eax,%eax
8010895f:	75 0c                	jne    8010896d <switchuvm+0x31>
    panic("switchuvm: no kstack");
80108961:	c7 04 24 1c 9b 10 80 	movl   $0x80109b1c,(%esp)
80108968:	e8 e7 7b ff ff       	call   80100554 <panic>
  if(p->pgdir == 0)
8010896d:	8b 45 08             	mov    0x8(%ebp),%eax
80108970:	8b 40 04             	mov    0x4(%eax),%eax
80108973:	85 c0                	test   %eax,%eax
80108975:	75 0c                	jne    80108983 <switchuvm+0x47>
    panic("switchuvm: no pgdir");
80108977:	c7 04 24 31 9b 10 80 	movl   $0x80109b31,(%esp)
8010897e:	e8 d1 7b ff ff       	call   80100554 <panic>

  pushcli();
80108983:	e8 da d0 ff ff       	call   80105a62 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80108988:	e8 06 c4 ff ff       	call   80104d93 <mycpu>
8010898d:	89 c3                	mov    %eax,%ebx
8010898f:	e8 ff c3 ff ff       	call   80104d93 <mycpu>
80108994:	83 c0 08             	add    $0x8,%eax
80108997:	89 c6                	mov    %eax,%esi
80108999:	e8 f5 c3 ff ff       	call   80104d93 <mycpu>
8010899e:	83 c0 08             	add    $0x8,%eax
801089a1:	c1 e8 10             	shr    $0x10,%eax
801089a4:	89 c7                	mov    %eax,%edi
801089a6:	e8 e8 c3 ff ff       	call   80104d93 <mycpu>
801089ab:	83 c0 08             	add    $0x8,%eax
801089ae:	c1 e8 18             	shr    $0x18,%eax
801089b1:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
801089b8:	67 00 
801089ba:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
801089c1:	89 f9                	mov    %edi,%ecx
801089c3:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
801089c9:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
801089cf:	83 e2 f0             	and    $0xfffffff0,%edx
801089d2:	83 ca 09             	or     $0x9,%edx
801089d5:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801089db:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
801089e1:	83 ca 10             	or     $0x10,%edx
801089e4:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801089ea:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
801089f0:	83 e2 9f             	and    $0xffffff9f,%edx
801089f3:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
801089f9:	8a 93 9d 00 00 00    	mov    0x9d(%ebx),%dl
801089ff:	83 ca 80             	or     $0xffffff80,%edx
80108a02:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80108a08:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108a0e:	83 e2 f0             	and    $0xfffffff0,%edx
80108a11:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108a17:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108a1d:	83 e2 ef             	and    $0xffffffef,%edx
80108a20:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108a26:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108a2c:	83 e2 df             	and    $0xffffffdf,%edx
80108a2f:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108a35:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108a3b:	83 ca 40             	or     $0x40,%edx
80108a3e:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108a44:	8a 93 9e 00 00 00    	mov    0x9e(%ebx),%dl
80108a4a:	83 e2 7f             	and    $0x7f,%edx
80108a4d:	88 93 9e 00 00 00    	mov    %dl,0x9e(%ebx)
80108a53:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80108a59:	e8 35 c3 ff ff       	call   80104d93 <mycpu>
80108a5e:	8a 90 9d 00 00 00    	mov    0x9d(%eax),%dl
80108a64:	83 e2 ef             	and    $0xffffffef,%edx
80108a67:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80108a6d:	e8 21 c3 ff ff       	call   80104d93 <mycpu>
80108a72:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80108a78:	e8 16 c3 ff ff       	call   80104d93 <mycpu>
80108a7d:	8b 55 08             	mov    0x8(%ebp),%edx
80108a80:	8b 52 08             	mov    0x8(%edx),%edx
80108a83:	81 c2 00 10 00 00    	add    $0x1000,%edx
80108a89:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80108a8c:	e8 02 c3 ff ff       	call   80104d93 <mycpu>
80108a91:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80108a97:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
80108a9e:	e8 30 f9 ff ff       	call   801083d3 <ltr>
  lcr3(V2P(p->pgdir));  // switch to process's address space
80108aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80108aa6:	8b 40 04             	mov    0x4(%eax),%eax
80108aa9:	05 00 00 00 80       	add    $0x80000000,%eax
80108aae:	89 04 24             	mov    %eax,(%esp)
80108ab1:	e8 32 f9 ff ff       	call   801083e8 <lcr3>
  popcli();
80108ab6:	e8 f1 cf ff ff       	call   80105aac <popcli>
}
80108abb:	83 c4 1c             	add    $0x1c,%esp
80108abe:	5b                   	pop    %ebx
80108abf:	5e                   	pop    %esi
80108ac0:	5f                   	pop    %edi
80108ac1:	5d                   	pop    %ebp
80108ac2:	c3                   	ret    

80108ac3 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108ac3:	55                   	push   %ebp
80108ac4:	89 e5                	mov    %esp,%ebp
80108ac6:	83 ec 38             	sub    $0x38,%esp
  char *mem;

  if(sz >= PGSIZE)
80108ac9:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
80108ad0:	76 0c                	jbe    80108ade <inituvm+0x1b>
    panic("inituvm: more than a page");
80108ad2:	c7 04 24 45 9b 10 80 	movl   $0x80109b45,(%esp)
80108ad9:	e8 76 7a ff ff       	call   80100554 <panic>
  mem = kalloc();
80108ade:	e8 a4 a2 ff ff       	call   80102d87 <kalloc>
80108ae3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
80108ae6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108aed:	00 
80108aee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108af5:	00 
80108af6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108af9:	89 04 24             	mov    %eax,(%esp)
80108afc:	e8 65 d0 ff ff       	call   80105b66 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80108b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b04:	05 00 00 00 80       	add    $0x80000000,%eax
80108b09:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108b10:	00 
80108b11:	89 44 24 0c          	mov    %eax,0xc(%esp)
80108b15:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108b1c:	00 
80108b1d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108b24:	00 
80108b25:	8b 45 08             	mov    0x8(%ebp),%eax
80108b28:	89 04 24             	mov    %eax,(%esp)
80108b2b:	e8 9c fc ff ff       	call   801087cc <mappages>
  memmove(mem, init, sz);
80108b30:	8b 45 10             	mov    0x10(%ebp),%eax
80108b33:	89 44 24 08          	mov    %eax,0x8(%esp)
80108b37:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b3a:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b41:	89 04 24             	mov    %eax,(%esp)
80108b44:	e8 e6 d0 ff ff       	call   80105c2f <memmove>
}
80108b49:	c9                   	leave  
80108b4a:	c3                   	ret    

80108b4b <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108b4b:	55                   	push   %ebp
80108b4c:	89 e5                	mov    %esp,%ebp
80108b4e:	83 ec 28             	sub    $0x28,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80108b51:	8b 45 0c             	mov    0xc(%ebp),%eax
80108b54:	25 ff 0f 00 00       	and    $0xfff,%eax
80108b59:	85 c0                	test   %eax,%eax
80108b5b:	74 0c                	je     80108b69 <loaduvm+0x1e>
    panic("loaduvm: addr must be page aligned");
80108b5d:	c7 04 24 60 9b 10 80 	movl   $0x80109b60,(%esp)
80108b64:	e8 eb 79 ff ff       	call   80100554 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108b69:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108b70:	e9 a6 00 00 00       	jmp    80108c1b <loaduvm+0xd0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b78:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b7b:	01 d0                	add    %edx,%eax
80108b7d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108b84:	00 
80108b85:	89 44 24 04          	mov    %eax,0x4(%esp)
80108b89:	8b 45 08             	mov    0x8(%ebp),%eax
80108b8c:	89 04 24             	mov    %eax,(%esp)
80108b8f:	e8 9c fb ff ff       	call   80108730 <walkpgdir>
80108b94:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108b97:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108b9b:	75 0c                	jne    80108ba9 <loaduvm+0x5e>
      panic("loaduvm: address should exist");
80108b9d:	c7 04 24 83 9b 10 80 	movl   $0x80109b83,(%esp)
80108ba4:	e8 ab 79 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108ba9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108bac:	8b 00                	mov    (%eax),%eax
80108bae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bb3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80108bb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bb9:	8b 55 18             	mov    0x18(%ebp),%edx
80108bbc:	29 c2                	sub    %eax,%edx
80108bbe:	89 d0                	mov    %edx,%eax
80108bc0:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108bc5:	77 0f                	ja     80108bd6 <loaduvm+0x8b>
      n = sz - i;
80108bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bca:	8b 55 18             	mov    0x18(%ebp),%edx
80108bcd:	29 c2                	sub    %eax,%edx
80108bcf:	89 d0                	mov    %edx,%eax
80108bd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108bd4:	eb 07                	jmp    80108bdd <loaduvm+0x92>
    else
      n = PGSIZE;
80108bd6:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80108bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108be0:	8b 55 14             	mov    0x14(%ebp),%edx
80108be3:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80108be6:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108be9:	05 00 00 00 80       	add    $0x80000000,%eax
80108bee:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108bf1:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108bf5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80108bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
80108bfd:	8b 45 10             	mov    0x10(%ebp),%eax
80108c00:	89 04 24             	mov    %eax,(%esp)
80108c03:	e8 b5 92 ff ff       	call   80101ebd <readi>
80108c08:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80108c0b:	74 07                	je     80108c14 <loaduvm+0xc9>
      return -1;
80108c0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c12:	eb 18                	jmp    80108c2c <loaduvm+0xe1>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80108c14:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c1e:	3b 45 18             	cmp    0x18(%ebp),%eax
80108c21:	0f 82 4e ff ff ff    	jb     80108b75 <loaduvm+0x2a>
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
80108c27:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108c2c:	c9                   	leave  
80108c2d:	c3                   	ret    

80108c2e <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108c2e:	55                   	push   %ebp
80108c2f:	89 e5                	mov    %esp,%ebp
80108c31:	83 ec 38             	sub    $0x38,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108c34:	8b 45 10             	mov    0x10(%ebp),%eax
80108c37:	85 c0                	test   %eax,%eax
80108c39:	79 0a                	jns    80108c45 <allocuvm+0x17>
    return 0;
80108c3b:	b8 00 00 00 00       	mov    $0x0,%eax
80108c40:	e9 fd 00 00 00       	jmp    80108d42 <allocuvm+0x114>
  if(newsz < oldsz)
80108c45:	8b 45 10             	mov    0x10(%ebp),%eax
80108c48:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108c4b:	73 08                	jae    80108c55 <allocuvm+0x27>
    return oldsz;
80108c4d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c50:	e9 ed 00 00 00       	jmp    80108d42 <allocuvm+0x114>

  a = PGROUNDUP(oldsz);
80108c55:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c58:	05 ff 0f 00 00       	add    $0xfff,%eax
80108c5d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108c62:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108c65:	e9 c9 00 00 00       	jmp    80108d33 <allocuvm+0x105>
    mem = kalloc();
80108c6a:	e8 18 a1 ff ff       	call   80102d87 <kalloc>
80108c6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108c72:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108c76:	75 2f                	jne    80108ca7 <allocuvm+0x79>
      cprintf("allocuvm out of memory\n");
80108c78:	c7 04 24 a1 9b 10 80 	movl   $0x80109ba1,(%esp)
80108c7f:	e8 3d 77 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108c84:	8b 45 0c             	mov    0xc(%ebp),%eax
80108c87:	89 44 24 08          	mov    %eax,0x8(%esp)
80108c8b:	8b 45 10             	mov    0x10(%ebp),%eax
80108c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80108c92:	8b 45 08             	mov    0x8(%ebp),%eax
80108c95:	89 04 24             	mov    %eax,(%esp)
80108c98:	e8 a7 00 00 00       	call   80108d44 <deallocuvm>
      return 0;
80108c9d:	b8 00 00 00 00       	mov    $0x0,%eax
80108ca2:	e9 9b 00 00 00       	jmp    80108d42 <allocuvm+0x114>
    }
    memset(mem, 0, PGSIZE);
80108ca7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108cae:	00 
80108caf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80108cb6:	00 
80108cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cba:	89 04 24             	mov    %eax,(%esp)
80108cbd:	e8 a4 ce ff ff       	call   80105b66 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80108cc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cc5:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108cce:	c7 44 24 10 06 00 00 	movl   $0x6,0x10(%esp)
80108cd5:	00 
80108cd6:	89 54 24 0c          	mov    %edx,0xc(%esp)
80108cda:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108ce1:	00 
80108ce2:	89 44 24 04          	mov    %eax,0x4(%esp)
80108ce6:	8b 45 08             	mov    0x8(%ebp),%eax
80108ce9:	89 04 24             	mov    %eax,(%esp)
80108cec:	e8 db fa ff ff       	call   801087cc <mappages>
80108cf1:	85 c0                	test   %eax,%eax
80108cf3:	79 37                	jns    80108d2c <allocuvm+0xfe>
      cprintf("allocuvm out of memory (2)\n");
80108cf5:	c7 04 24 b9 9b 10 80 	movl   $0x80109bb9,(%esp)
80108cfc:	e8 c0 76 ff ff       	call   801003c1 <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80108d01:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d04:	89 44 24 08          	mov    %eax,0x8(%esp)
80108d08:	8b 45 10             	mov    0x10(%ebp),%eax
80108d0b:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d0f:	8b 45 08             	mov    0x8(%ebp),%eax
80108d12:	89 04 24             	mov    %eax,(%esp)
80108d15:	e8 2a 00 00 00       	call   80108d44 <deallocuvm>
      kfree(mem);
80108d1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d1d:	89 04 24             	mov    %eax,(%esp)
80108d20:	e8 cc 9f ff ff       	call   80102cf1 <kfree>
      return 0;
80108d25:	b8 00 00 00 00       	mov    $0x0,%eax
80108d2a:	eb 16                	jmp    80108d42 <allocuvm+0x114>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108d2c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d36:	3b 45 10             	cmp    0x10(%ebp),%eax
80108d39:	0f 82 2b ff ff ff    	jb     80108c6a <allocuvm+0x3c>
      deallocuvm(pgdir, newsz, oldsz);
      kfree(mem);
      return 0;
    }
  }
  return newsz;
80108d3f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108d42:	c9                   	leave  
80108d43:	c3                   	ret    

80108d44 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108d44:	55                   	push   %ebp
80108d45:	89 e5                	mov    %esp,%ebp
80108d47:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108d4a:	8b 45 10             	mov    0x10(%ebp),%eax
80108d4d:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108d50:	72 08                	jb     80108d5a <deallocuvm+0x16>
    return oldsz;
80108d52:	8b 45 0c             	mov    0xc(%ebp),%eax
80108d55:	e9 ac 00 00 00       	jmp    80108e06 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80108d5a:	8b 45 10             	mov    0x10(%ebp),%eax
80108d5d:	05 ff 0f 00 00       	add    $0xfff,%eax
80108d62:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108d6a:	e9 88 00 00 00       	jmp    80108df7 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d72:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108d79:	00 
80108d7a:	89 44 24 04          	mov    %eax,0x4(%esp)
80108d7e:	8b 45 08             	mov    0x8(%ebp),%eax
80108d81:	89 04 24             	mov    %eax,(%esp)
80108d84:	e8 a7 f9 ff ff       	call   80108730 <walkpgdir>
80108d89:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108d8c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108d90:	75 14                	jne    80108da6 <deallocuvm+0x62>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80108d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d95:	c1 e8 16             	shr    $0x16,%eax
80108d98:	40                   	inc    %eax
80108d99:	c1 e0 16             	shl    $0x16,%eax
80108d9c:	2d 00 10 00 00       	sub    $0x1000,%eax
80108da1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108da4:	eb 4a                	jmp    80108df0 <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80108da6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108da9:	8b 00                	mov    (%eax),%eax
80108dab:	83 e0 01             	and    $0x1,%eax
80108dae:	85 c0                	test   %eax,%eax
80108db0:	74 3e                	je     80108df0 <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
80108db2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108db5:	8b 00                	mov    (%eax),%eax
80108db7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108dbc:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108dbf:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108dc3:	75 0c                	jne    80108dd1 <deallocuvm+0x8d>
        panic("kfree");
80108dc5:	c7 04 24 d5 9b 10 80 	movl   $0x80109bd5,(%esp)
80108dcc:	e8 83 77 ff ff       	call   80100554 <panic>
      char *v = P2V(pa);
80108dd1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dd4:	05 00 00 00 80       	add    $0x80000000,%eax
80108dd9:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108ddc:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ddf:	89 04 24             	mov    %eax,(%esp)
80108de2:	e8 0a 9f ff ff       	call   80102cf1 <kfree>
      *pte = 0;
80108de7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108dea:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108df0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108df7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108dfa:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108dfd:	0f 82 6c ff ff ff    	jb     80108d6f <deallocuvm+0x2b>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108e03:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108e06:	c9                   	leave  
80108e07:	c3                   	ret    

80108e08 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108e08:	55                   	push   %ebp
80108e09:	89 e5                	mov    %esp,%ebp
80108e0b:	83 ec 28             	sub    $0x28,%esp
  uint i;

  if(pgdir == 0)
80108e0e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108e12:	75 0c                	jne    80108e20 <freevm+0x18>
    panic("freevm: no pgdir");
80108e14:	c7 04 24 db 9b 10 80 	movl   $0x80109bdb,(%esp)
80108e1b:	e8 34 77 ff ff       	call   80100554 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108e20:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108e27:	00 
80108e28:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
80108e2f:	80 
80108e30:	8b 45 08             	mov    0x8(%ebp),%eax
80108e33:	89 04 24             	mov    %eax,(%esp)
80108e36:	e8 09 ff ff ff       	call   80108d44 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80108e3b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108e42:	eb 44                	jmp    80108e88 <freevm+0x80>
    if(pgdir[i] & PTE_P){
80108e44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e47:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e4e:	8b 45 08             	mov    0x8(%ebp),%eax
80108e51:	01 d0                	add    %edx,%eax
80108e53:	8b 00                	mov    (%eax),%eax
80108e55:	83 e0 01             	and    $0x1,%eax
80108e58:	85 c0                	test   %eax,%eax
80108e5a:	74 29                	je     80108e85 <freevm+0x7d>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80108e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e5f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108e66:	8b 45 08             	mov    0x8(%ebp),%eax
80108e69:	01 d0                	add    %edx,%eax
80108e6b:	8b 00                	mov    (%eax),%eax
80108e6d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108e72:	05 00 00 00 80       	add    $0x80000000,%eax
80108e77:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108e7a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e7d:	89 04 24             	mov    %eax,(%esp)
80108e80:	e8 6c 9e ff ff       	call   80102cf1 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108e85:	ff 45 f4             	incl   -0xc(%ebp)
80108e88:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108e8f:	76 b3                	jbe    80108e44 <freevm+0x3c>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108e91:	8b 45 08             	mov    0x8(%ebp),%eax
80108e94:	89 04 24             	mov    %eax,(%esp)
80108e97:	e8 55 9e ff ff       	call   80102cf1 <kfree>
}
80108e9c:	c9                   	leave  
80108e9d:	c3                   	ret    

80108e9e <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108e9e:	55                   	push   %ebp
80108e9f:	89 e5                	mov    %esp,%ebp
80108ea1:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108ea4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108eab:	00 
80108eac:	8b 45 0c             	mov    0xc(%ebp),%eax
80108eaf:	89 44 24 04          	mov    %eax,0x4(%esp)
80108eb3:	8b 45 08             	mov    0x8(%ebp),%eax
80108eb6:	89 04 24             	mov    %eax,(%esp)
80108eb9:	e8 72 f8 ff ff       	call   80108730 <walkpgdir>
80108ebe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108ec1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108ec5:	75 0c                	jne    80108ed3 <clearpteu+0x35>
    panic("clearpteu");
80108ec7:	c7 04 24 ec 9b 10 80 	movl   $0x80109bec,(%esp)
80108ece:	e8 81 76 ff ff       	call   80100554 <panic>
  *pte &= ~PTE_U;
80108ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ed6:	8b 00                	mov    (%eax),%eax
80108ed8:	83 e0 fb             	and    $0xfffffffb,%eax
80108edb:	89 c2                	mov    %eax,%edx
80108edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ee0:	89 10                	mov    %edx,(%eax)
}
80108ee2:	c9                   	leave  
80108ee3:	c3                   	ret    

80108ee4 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108ee4:	55                   	push   %ebp
80108ee5:	89 e5                	mov    %esp,%ebp
80108ee7:	83 ec 48             	sub    $0x48,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108eea:	e8 73 f9 ff ff       	call   80108862 <setupkvm>
80108eef:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108ef2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108ef6:	75 0a                	jne    80108f02 <copyuvm+0x1e>
    return 0;
80108ef8:	b8 00 00 00 00       	mov    $0x0,%eax
80108efd:	e9 f8 00 00 00       	jmp    80108ffa <copyuvm+0x116>
  for(i = 0; i < sz; i += PGSIZE){
80108f02:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108f09:	e9 cb 00 00 00       	jmp    80108fd9 <copyuvm+0xf5>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108f0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108f11:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80108f18:	00 
80108f19:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f1d:	8b 45 08             	mov    0x8(%ebp),%eax
80108f20:	89 04 24             	mov    %eax,(%esp)
80108f23:	e8 08 f8 ff ff       	call   80108730 <walkpgdir>
80108f28:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108f2b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108f2f:	75 0c                	jne    80108f3d <copyuvm+0x59>
      panic("copyuvm: pte should exist");
80108f31:	c7 04 24 f6 9b 10 80 	movl   $0x80109bf6,(%esp)
80108f38:	e8 17 76 ff ff       	call   80100554 <panic>
    if(!(*pte & PTE_P))
80108f3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f40:	8b 00                	mov    (%eax),%eax
80108f42:	83 e0 01             	and    $0x1,%eax
80108f45:	85 c0                	test   %eax,%eax
80108f47:	75 0c                	jne    80108f55 <copyuvm+0x71>
      panic("copyuvm: page not present");
80108f49:	c7 04 24 10 9c 10 80 	movl   $0x80109c10,(%esp)
80108f50:	e8 ff 75 ff ff       	call   80100554 <panic>
    pa = PTE_ADDR(*pte);
80108f55:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f58:	8b 00                	mov    (%eax),%eax
80108f5a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108f5f:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108f62:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108f65:	8b 00                	mov    (%eax),%eax
80108f67:	25 ff 0f 00 00       	and    $0xfff,%eax
80108f6c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108f6f:	e8 13 9e ff ff       	call   80102d87 <kalloc>
80108f74:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108f77:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108f7b:	75 02                	jne    80108f7f <copyuvm+0x9b>
      goto bad;
80108f7d:	eb 6b                	jmp    80108fea <copyuvm+0x106>
    memmove(mem, (char*)P2V(pa), PGSIZE);
80108f7f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108f82:	05 00 00 00 80       	add    $0x80000000,%eax
80108f87:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108f8e:	00 
80108f8f:	89 44 24 04          	mov    %eax,0x4(%esp)
80108f93:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108f96:	89 04 24             	mov    %eax,(%esp)
80108f99:	e8 91 cc ff ff       	call   80105c2f <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80108f9e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80108fa1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108fa4:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80108faa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fad:	89 54 24 10          	mov    %edx,0x10(%esp)
80108fb1:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
80108fb5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80108fbc:	00 
80108fbd:	89 44 24 04          	mov    %eax,0x4(%esp)
80108fc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fc4:	89 04 24             	mov    %eax,(%esp)
80108fc7:	e8 00 f8 ff ff       	call   801087cc <mappages>
80108fcc:	85 c0                	test   %eax,%eax
80108fce:	79 02                	jns    80108fd2 <copyuvm+0xee>
      goto bad;
80108fd0:	eb 18                	jmp    80108fea <copyuvm+0x106>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108fd2:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108fdc:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108fdf:	0f 82 29 ff ff ff    	jb     80108f0e <copyuvm+0x2a>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
      goto bad;
  }
  return d;
80108fe5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fe8:	eb 10                	jmp    80108ffa <copyuvm+0x116>

bad:
  freevm(d);
80108fea:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108fed:	89 04 24             	mov    %eax,(%esp)
80108ff0:	e8 13 fe ff ff       	call   80108e08 <freevm>
  return 0;
80108ff5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108ffa:	c9                   	leave  
80108ffb:	c3                   	ret    

80108ffc <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108ffc:	55                   	push   %ebp
80108ffd:	89 e5                	mov    %esp,%ebp
80108fff:	83 ec 28             	sub    $0x28,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80109002:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80109009:	00 
8010900a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010900d:	89 44 24 04          	mov    %eax,0x4(%esp)
80109011:	8b 45 08             	mov    0x8(%ebp),%eax
80109014:	89 04 24             	mov    %eax,(%esp)
80109017:	e8 14 f7 ff ff       	call   80108730 <walkpgdir>
8010901c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010901f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109022:	8b 00                	mov    (%eax),%eax
80109024:	83 e0 01             	and    $0x1,%eax
80109027:	85 c0                	test   %eax,%eax
80109029:	75 07                	jne    80109032 <uva2ka+0x36>
    return 0;
8010902b:	b8 00 00 00 00       	mov    $0x0,%eax
80109030:	eb 22                	jmp    80109054 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80109032:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109035:	8b 00                	mov    (%eax),%eax
80109037:	83 e0 04             	and    $0x4,%eax
8010903a:	85 c0                	test   %eax,%eax
8010903c:	75 07                	jne    80109045 <uva2ka+0x49>
    return 0;
8010903e:	b8 00 00 00 00       	mov    $0x0,%eax
80109043:	eb 0f                	jmp    80109054 <uva2ka+0x58>
  return (char*)P2V(PTE_ADDR(*pte));
80109045:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109048:	8b 00                	mov    (%eax),%eax
8010904a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010904f:	05 00 00 00 80       	add    $0x80000000,%eax
}
80109054:	c9                   	leave  
80109055:	c3                   	ret    

80109056 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80109056:	55                   	push   %ebp
80109057:	89 e5                	mov    %esp,%ebp
80109059:	83 ec 28             	sub    $0x28,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
8010905c:	8b 45 10             	mov    0x10(%ebp),%eax
8010905f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80109062:	e9 87 00 00 00       	jmp    801090ee <copyout+0x98>
    va0 = (uint)PGROUNDDOWN(va);
80109067:	8b 45 0c             	mov    0xc(%ebp),%eax
8010906a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010906f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80109072:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109075:	89 44 24 04          	mov    %eax,0x4(%esp)
80109079:	8b 45 08             	mov    0x8(%ebp),%eax
8010907c:	89 04 24             	mov    %eax,(%esp)
8010907f:	e8 78 ff ff ff       	call   80108ffc <uva2ka>
80109084:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80109087:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010908b:	75 07                	jne    80109094 <copyout+0x3e>
      return -1;
8010908d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80109092:	eb 69                	jmp    801090fd <copyout+0xa7>
    n = PGSIZE - (va - va0);
80109094:	8b 45 0c             	mov    0xc(%ebp),%eax
80109097:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010909a:	29 c2                	sub    %eax,%edx
8010909c:	89 d0                	mov    %edx,%eax
8010909e:	05 00 10 00 00       	add    $0x1000,%eax
801090a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
801090a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090a9:	3b 45 14             	cmp    0x14(%ebp),%eax
801090ac:	76 06                	jbe    801090b4 <copyout+0x5e>
      n = len;
801090ae:	8b 45 14             	mov    0x14(%ebp),%eax
801090b1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
801090b4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090b7:	8b 55 0c             	mov    0xc(%ebp),%edx
801090ba:	29 c2                	sub    %eax,%edx
801090bc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801090bf:	01 c2                	add    %eax,%edx
801090c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090c4:	89 44 24 08          	mov    %eax,0x8(%esp)
801090c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801090cb:	89 44 24 04          	mov    %eax,0x4(%esp)
801090cf:	89 14 24             	mov    %edx,(%esp)
801090d2:	e8 58 cb ff ff       	call   80105c2f <memmove>
    len -= n;
801090d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090da:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
801090dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801090e0:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
801090e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801090e6:	05 00 10 00 00       	add    $0x1000,%eax
801090eb:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801090ee:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
801090f2:	0f 85 6f ff ff ff    	jne    80109067 <copyout+0x11>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801090f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801090fd:	c9                   	leave  
801090fe:	c3                   	ret    
