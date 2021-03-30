
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	83010113          	addi	sp,sp,-2000 # 80009830 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	00009617          	auipc	a2,0x9
    8000004e:	fe660613          	addi	a2,a2,-26 # 80009030 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	cb478793          	addi	a5,a5,-844 # 80005d10 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e5478793          	addi	a5,a5,-428 # 80000efa <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000c8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000cc:	10479073          	csrw	sie,a5
  timerinit();
    800000d0:	00000097          	auipc	ra,0x0
    800000d4:	f4c080e7          	jalr	-180(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000d8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000dc:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000de:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e0:	30200073          	mret
}
    800000e4:	60a2                	ld	ra,8(sp)
    800000e6:	6402                	ld	s0,0(sp)
    800000e8:	0141                	addi	sp,sp,16
    800000ea:	8082                	ret

00000000800000ec <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000ec:	715d                	addi	sp,sp,-80
    800000ee:	e486                	sd	ra,72(sp)
    800000f0:	e0a2                	sd	s0,64(sp)
    800000f2:	fc26                	sd	s1,56(sp)
    800000f4:	f84a                	sd	s2,48(sp)
    800000f6:	f44e                	sd	s3,40(sp)
    800000f8:	f052                	sd	s4,32(sp)
    800000fa:	ec56                	sd	s5,24(sp)
    800000fc:	0880                	addi	s0,sp,80
    800000fe:	8a2a                	mv	s4,a0
    80000100:	84ae                	mv	s1,a1
    80000102:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    80000104:	00011517          	auipc	a0,0x11
    80000108:	72c50513          	addi	a0,a0,1836 # 80011830 <cons>
    8000010c:	00001097          	auipc	ra,0x1
    80000110:	b44080e7          	jalr	-1212(ra) # 80000c50 <acquire>
  for(i = 0; i < n; i++){
    80000114:	05305b63          	blez	s3,8000016a <consolewrite+0x7e>
    80000118:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011a:	5afd                	li	s5,-1
    8000011c:	4685                	li	a3,1
    8000011e:	8626                	mv	a2,s1
    80000120:	85d2                	mv	a1,s4
    80000122:	fbf40513          	addi	a0,s0,-65
    80000126:	00002097          	auipc	ra,0x2
    8000012a:	3b6080e7          	jalr	950(ra) # 800024dc <either_copyin>
    8000012e:	01550c63          	beq	a0,s5,80000146 <consolewrite+0x5a>
      break;
    uartputc(c);
    80000132:	fbf44503          	lbu	a0,-65(s0)
    80000136:	00000097          	auipc	ra,0x0
    8000013a:	796080e7          	jalr	1942(ra) # 800008cc <uartputc>
  for(i = 0; i < n; i++){
    8000013e:	2905                	addiw	s2,s2,1
    80000140:	0485                	addi	s1,s1,1
    80000142:	fd299de3          	bne	s3,s2,8000011c <consolewrite+0x30>
  }
  release(&cons.lock);
    80000146:	00011517          	auipc	a0,0x11
    8000014a:	6ea50513          	addi	a0,a0,1770 # 80011830 <cons>
    8000014e:	00001097          	auipc	ra,0x1
    80000152:	bb6080e7          	jalr	-1098(ra) # 80000d04 <release>

  return i;
}
    80000156:	854a                	mv	a0,s2
    80000158:	60a6                	ld	ra,72(sp)
    8000015a:	6406                	ld	s0,64(sp)
    8000015c:	74e2                	ld	s1,56(sp)
    8000015e:	7942                	ld	s2,48(sp)
    80000160:	79a2                	ld	s3,40(sp)
    80000162:	7a02                	ld	s4,32(sp)
    80000164:	6ae2                	ld	s5,24(sp)
    80000166:	6161                	addi	sp,sp,80
    80000168:	8082                	ret
  for(i = 0; i < n; i++){
    8000016a:	4901                	li	s2,0
    8000016c:	bfe9                	j	80000146 <consolewrite+0x5a>

000000008000016e <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	7159                	addi	sp,sp,-112
    80000170:	f486                	sd	ra,104(sp)
    80000172:	f0a2                	sd	s0,96(sp)
    80000174:	eca6                	sd	s1,88(sp)
    80000176:	e8ca                	sd	s2,80(sp)
    80000178:	e4ce                	sd	s3,72(sp)
    8000017a:	e0d2                	sd	s4,64(sp)
    8000017c:	fc56                	sd	s5,56(sp)
    8000017e:	f85a                	sd	s6,48(sp)
    80000180:	f45e                	sd	s7,40(sp)
    80000182:	f062                	sd	s8,32(sp)
    80000184:	ec66                	sd	s9,24(sp)
    80000186:	e86a                	sd	s10,16(sp)
    80000188:	1880                	addi	s0,sp,112
    8000018a:	8aaa                	mv	s5,a0
    8000018c:	8a2e                	mv	s4,a1
    8000018e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000190:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000194:	00011517          	auipc	a0,0x11
    80000198:	69c50513          	addi	a0,a0,1692 # 80011830 <cons>
    8000019c:	00001097          	auipc	ra,0x1
    800001a0:	ab4080e7          	jalr	-1356(ra) # 80000c50 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001a4:	00011497          	auipc	s1,0x11
    800001a8:	68c48493          	addi	s1,s1,1676 # 80011830 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ac:	00011917          	auipc	s2,0x11
    800001b0:	71c90913          	addi	s2,s2,1820 # 800118c8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001b4:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001b6:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001b8:	4ca9                	li	s9,10
  while(n > 0){
    800001ba:	07305863          	blez	s3,8000022a <consoleread+0xbc>
    while(cons.r == cons.w){
    800001be:	0984a783          	lw	a5,152(s1)
    800001c2:	09c4a703          	lw	a4,156(s1)
    800001c6:	02f71463          	bne	a4,a5,800001ee <consoleread+0x80>
      if(myproc()->killed){
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	852080e7          	jalr	-1966(ra) # 80001a1c <myproc>
    800001d2:	591c                	lw	a5,48(a0)
    800001d4:	e7b5                	bnez	a5,80000240 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001d6:	85a6                	mv	a1,s1
    800001d8:	854a                	mv	a0,s2
    800001da:	00002097          	auipc	ra,0x2
    800001de:	052080e7          	jalr	82(ra) # 8000222c <sleep>
    while(cons.r == cons.w){
    800001e2:	0984a783          	lw	a5,152(s1)
    800001e6:	09c4a703          	lw	a4,156(s1)
    800001ea:	fef700e3          	beq	a4,a5,800001ca <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001ee:	0017871b          	addiw	a4,a5,1
    800001f2:	08e4ac23          	sw	a4,152(s1)
    800001f6:	07f7f713          	andi	a4,a5,127
    800001fa:	9726                	add	a4,a4,s1
    800001fc:	01874703          	lbu	a4,24(a4)
    80000200:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000204:	077d0563          	beq	s10,s7,8000026e <consoleread+0x100>
    cbuf = c;
    80000208:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000020c:	4685                	li	a3,1
    8000020e:	f9f40613          	addi	a2,s0,-97
    80000212:	85d2                	mv	a1,s4
    80000214:	8556                	mv	a0,s5
    80000216:	00002097          	auipc	ra,0x2
    8000021a:	270080e7          	jalr	624(ra) # 80002486 <either_copyout>
    8000021e:	01850663          	beq	a0,s8,8000022a <consoleread+0xbc>
    dst++;
    80000222:	0a05                	addi	s4,s4,1
    --n;
    80000224:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000226:	f99d1ae3          	bne	s10,s9,800001ba <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022a:	00011517          	auipc	a0,0x11
    8000022e:	60650513          	addi	a0,a0,1542 # 80011830 <cons>
    80000232:	00001097          	auipc	ra,0x1
    80000236:	ad2080e7          	jalr	-1326(ra) # 80000d04 <release>

  return target - n;
    8000023a:	413b053b          	subw	a0,s6,s3
    8000023e:	a811                	j	80000252 <consoleread+0xe4>
        release(&cons.lock);
    80000240:	00011517          	auipc	a0,0x11
    80000244:	5f050513          	addi	a0,a0,1520 # 80011830 <cons>
    80000248:	00001097          	auipc	ra,0x1
    8000024c:	abc080e7          	jalr	-1348(ra) # 80000d04 <release>
        return -1;
    80000250:	557d                	li	a0,-1
}
    80000252:	70a6                	ld	ra,104(sp)
    80000254:	7406                	ld	s0,96(sp)
    80000256:	64e6                	ld	s1,88(sp)
    80000258:	6946                	ld	s2,80(sp)
    8000025a:	69a6                	ld	s3,72(sp)
    8000025c:	6a06                	ld	s4,64(sp)
    8000025e:	7ae2                	ld	s5,56(sp)
    80000260:	7b42                	ld	s6,48(sp)
    80000262:	7ba2                	ld	s7,40(sp)
    80000264:	7c02                	ld	s8,32(sp)
    80000266:	6ce2                	ld	s9,24(sp)
    80000268:	6d42                	ld	s10,16(sp)
    8000026a:	6165                	addi	sp,sp,112
    8000026c:	8082                	ret
      if(n < target){
    8000026e:	0009871b          	sext.w	a4,s3
    80000272:	fb677ce3          	bgeu	a4,s6,8000022a <consoleread+0xbc>
        cons.r--;
    80000276:	00011717          	auipc	a4,0x11
    8000027a:	64f72923          	sw	a5,1618(a4) # 800118c8 <cons+0x98>
    8000027e:	b775                	j	8000022a <consoleread+0xbc>

0000000080000280 <consputc>:
{
    80000280:	1141                	addi	sp,sp,-16
    80000282:	e406                	sd	ra,8(sp)
    80000284:	e022                	sd	s0,0(sp)
    80000286:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000288:	10000793          	li	a5,256
    8000028c:	00f50a63          	beq	a0,a5,800002a0 <consputc+0x20>
    uartputc_sync(c);
    80000290:	00000097          	auipc	ra,0x0
    80000294:	55e080e7          	jalr	1374(ra) # 800007ee <uartputc_sync>
}
    80000298:	60a2                	ld	ra,8(sp)
    8000029a:	6402                	ld	s0,0(sp)
    8000029c:	0141                	addi	sp,sp,16
    8000029e:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a0:	4521                	li	a0,8
    800002a2:	00000097          	auipc	ra,0x0
    800002a6:	54c080e7          	jalr	1356(ra) # 800007ee <uartputc_sync>
    800002aa:	02000513          	li	a0,32
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	540080e7          	jalr	1344(ra) # 800007ee <uartputc_sync>
    800002b6:	4521                	li	a0,8
    800002b8:	00000097          	auipc	ra,0x0
    800002bc:	536080e7          	jalr	1334(ra) # 800007ee <uartputc_sync>
    800002c0:	bfe1                	j	80000298 <consputc+0x18>

00000000800002c2 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c2:	1101                	addi	sp,sp,-32
    800002c4:	ec06                	sd	ra,24(sp)
    800002c6:	e822                	sd	s0,16(sp)
    800002c8:	e426                	sd	s1,8(sp)
    800002ca:	e04a                	sd	s2,0(sp)
    800002cc:	1000                	addi	s0,sp,32
    800002ce:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d0:	00011517          	auipc	a0,0x11
    800002d4:	56050513          	addi	a0,a0,1376 # 80011830 <cons>
    800002d8:	00001097          	auipc	ra,0x1
    800002dc:	978080e7          	jalr	-1672(ra) # 80000c50 <acquire>

  switch(c){
    800002e0:	47d5                	li	a5,21
    800002e2:	0af48663          	beq	s1,a5,8000038e <consoleintr+0xcc>
    800002e6:	0297ca63          	blt	a5,s1,8000031a <consoleintr+0x58>
    800002ea:	47a1                	li	a5,8
    800002ec:	0ef48763          	beq	s1,a5,800003da <consoleintr+0x118>
    800002f0:	47c1                	li	a5,16
    800002f2:	10f49a63          	bne	s1,a5,80000406 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f6:	00002097          	auipc	ra,0x2
    800002fa:	23c080e7          	jalr	572(ra) # 80002532 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fe:	00011517          	auipc	a0,0x11
    80000302:	53250513          	addi	a0,a0,1330 # 80011830 <cons>
    80000306:	00001097          	auipc	ra,0x1
    8000030a:	9fe080e7          	jalr	-1538(ra) # 80000d04 <release>
}
    8000030e:	60e2                	ld	ra,24(sp)
    80000310:	6442                	ld	s0,16(sp)
    80000312:	64a2                	ld	s1,8(sp)
    80000314:	6902                	ld	s2,0(sp)
    80000316:	6105                	addi	sp,sp,32
    80000318:	8082                	ret
  switch(c){
    8000031a:	07f00793          	li	a5,127
    8000031e:	0af48e63          	beq	s1,a5,800003da <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000322:	00011717          	auipc	a4,0x11
    80000326:	50e70713          	addi	a4,a4,1294 # 80011830 <cons>
    8000032a:	0a072783          	lw	a5,160(a4)
    8000032e:	09872703          	lw	a4,152(a4)
    80000332:	9f99                	subw	a5,a5,a4
    80000334:	07f00713          	li	a4,127
    80000338:	fcf763e3          	bltu	a4,a5,800002fe <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000033c:	47b5                	li	a5,13
    8000033e:	0cf48763          	beq	s1,a5,8000040c <consoleintr+0x14a>
      consputc(c);
    80000342:	8526                	mv	a0,s1
    80000344:	00000097          	auipc	ra,0x0
    80000348:	f3c080e7          	jalr	-196(ra) # 80000280 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000034c:	00011797          	auipc	a5,0x11
    80000350:	4e478793          	addi	a5,a5,1252 # 80011830 <cons>
    80000354:	0a07a703          	lw	a4,160(a5)
    80000358:	0017069b          	addiw	a3,a4,1
    8000035c:	0006861b          	sext.w	a2,a3
    80000360:	0ad7a023          	sw	a3,160(a5)
    80000364:	07f77713          	andi	a4,a4,127
    80000368:	97ba                	add	a5,a5,a4
    8000036a:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000036e:	47a9                	li	a5,10
    80000370:	0cf48563          	beq	s1,a5,8000043a <consoleintr+0x178>
    80000374:	4791                	li	a5,4
    80000376:	0cf48263          	beq	s1,a5,8000043a <consoleintr+0x178>
    8000037a:	00011797          	auipc	a5,0x11
    8000037e:	54e7a783          	lw	a5,1358(a5) # 800118c8 <cons+0x98>
    80000382:	0807879b          	addiw	a5,a5,128
    80000386:	f6f61ce3          	bne	a2,a5,800002fe <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000038a:	863e                	mv	a2,a5
    8000038c:	a07d                	j	8000043a <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038e:	00011717          	auipc	a4,0x11
    80000392:	4a270713          	addi	a4,a4,1186 # 80011830 <cons>
    80000396:	0a072783          	lw	a5,160(a4)
    8000039a:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    8000039e:	00011497          	auipc	s1,0x11
    800003a2:	49248493          	addi	s1,s1,1170 # 80011830 <cons>
    while(cons.e != cons.w &&
    800003a6:	4929                	li	s2,10
    800003a8:	f4f70be3          	beq	a4,a5,800002fe <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003ac:	37fd                	addiw	a5,a5,-1
    800003ae:	07f7f713          	andi	a4,a5,127
    800003b2:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b4:	01874703          	lbu	a4,24(a4)
    800003b8:	f52703e3          	beq	a4,s2,800002fe <consoleintr+0x3c>
      cons.e--;
    800003bc:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c0:	10000513          	li	a0,256
    800003c4:	00000097          	auipc	ra,0x0
    800003c8:	ebc080e7          	jalr	-324(ra) # 80000280 <consputc>
    while(cons.e != cons.w &&
    800003cc:	0a04a783          	lw	a5,160(s1)
    800003d0:	09c4a703          	lw	a4,156(s1)
    800003d4:	fcf71ce3          	bne	a4,a5,800003ac <consoleintr+0xea>
    800003d8:	b71d                	j	800002fe <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003da:	00011717          	auipc	a4,0x11
    800003de:	45670713          	addi	a4,a4,1110 # 80011830 <cons>
    800003e2:	0a072783          	lw	a5,160(a4)
    800003e6:	09c72703          	lw	a4,156(a4)
    800003ea:	f0f70ae3          	beq	a4,a5,800002fe <consoleintr+0x3c>
      cons.e--;
    800003ee:	37fd                	addiw	a5,a5,-1
    800003f0:	00011717          	auipc	a4,0x11
    800003f4:	4ef72023          	sw	a5,1248(a4) # 800118d0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f8:	10000513          	li	a0,256
    800003fc:	00000097          	auipc	ra,0x0
    80000400:	e84080e7          	jalr	-380(ra) # 80000280 <consputc>
    80000404:	bded                	j	800002fe <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000406:	ee048ce3          	beqz	s1,800002fe <consoleintr+0x3c>
    8000040a:	bf21                	j	80000322 <consoleintr+0x60>
      consputc(c);
    8000040c:	4529                	li	a0,10
    8000040e:	00000097          	auipc	ra,0x0
    80000412:	e72080e7          	jalr	-398(ra) # 80000280 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000416:	00011797          	auipc	a5,0x11
    8000041a:	41a78793          	addi	a5,a5,1050 # 80011830 <cons>
    8000041e:	0a07a703          	lw	a4,160(a5)
    80000422:	0017069b          	addiw	a3,a4,1
    80000426:	0006861b          	sext.w	a2,a3
    8000042a:	0ad7a023          	sw	a3,160(a5)
    8000042e:	07f77713          	andi	a4,a4,127
    80000432:	97ba                	add	a5,a5,a4
    80000434:	4729                	li	a4,10
    80000436:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000043a:	00011797          	auipc	a5,0x11
    8000043e:	48c7a923          	sw	a2,1170(a5) # 800118cc <cons+0x9c>
        wakeup(&cons.r);
    80000442:	00011517          	auipc	a0,0x11
    80000446:	48650513          	addi	a0,a0,1158 # 800118c8 <cons+0x98>
    8000044a:	00002097          	auipc	ra,0x2
    8000044e:	f62080e7          	jalr	-158(ra) # 800023ac <wakeup>
    80000452:	b575                	j	800002fe <consoleintr+0x3c>

0000000080000454 <consoleinit>:

void
consoleinit(void)
{
    80000454:	1141                	addi	sp,sp,-16
    80000456:	e406                	sd	ra,8(sp)
    80000458:	e022                	sd	s0,0(sp)
    8000045a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000045c:	00008597          	auipc	a1,0x8
    80000460:	bb458593          	addi	a1,a1,-1100 # 80008010 <etext+0x10>
    80000464:	00011517          	auipc	a0,0x11
    80000468:	3cc50513          	addi	a0,a0,972 # 80011830 <cons>
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	754080e7          	jalr	1876(ra) # 80000bc0 <initlock>

  uartinit();
    80000474:	00000097          	auipc	ra,0x0
    80000478:	32a080e7          	jalr	810(ra) # 8000079e <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047c:	00021797          	auipc	a5,0x21
    80000480:	53478793          	addi	a5,a5,1332 # 800219b0 <devsw>
    80000484:	00000717          	auipc	a4,0x0
    80000488:	cea70713          	addi	a4,a4,-790 # 8000016e <consoleread>
    8000048c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048e:	00000717          	auipc	a4,0x0
    80000492:	c5e70713          	addi	a4,a4,-930 # 800000ec <consolewrite>
    80000496:	ef98                	sd	a4,24(a5)
}
    80000498:	60a2                	ld	ra,8(sp)
    8000049a:	6402                	ld	s0,0(sp)
    8000049c:	0141                	addi	sp,sp,16
    8000049e:	8082                	ret

00000000800004a0 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a0:	7179                	addi	sp,sp,-48
    800004a2:	f406                	sd	ra,40(sp)
    800004a4:	f022                	sd	s0,32(sp)
    800004a6:	ec26                	sd	s1,24(sp)
    800004a8:	e84a                	sd	s2,16(sp)
    800004aa:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ac:	c219                	beqz	a2,800004b2 <printint+0x12>
    800004ae:	08054663          	bltz	a0,8000053a <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004b2:	2501                	sext.w	a0,a0
    800004b4:	4881                	li	a7,0
    800004b6:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004ba:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004bc:	2581                	sext.w	a1,a1
    800004be:	00008617          	auipc	a2,0x8
    800004c2:	b8260613          	addi	a2,a2,-1150 # 80008040 <digits>
    800004c6:	883a                	mv	a6,a4
    800004c8:	2705                	addiw	a4,a4,1
    800004ca:	02b577bb          	remuw	a5,a0,a1
    800004ce:	1782                	slli	a5,a5,0x20
    800004d0:	9381                	srli	a5,a5,0x20
    800004d2:	97b2                	add	a5,a5,a2
    800004d4:	0007c783          	lbu	a5,0(a5)
    800004d8:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004dc:	0005079b          	sext.w	a5,a0
    800004e0:	02b5553b          	divuw	a0,a0,a1
    800004e4:	0685                	addi	a3,a3,1
    800004e6:	feb7f0e3          	bgeu	a5,a1,800004c6 <printint+0x26>

  if(sign)
    800004ea:	00088b63          	beqz	a7,80000500 <printint+0x60>
    buf[i++] = '-';
    800004ee:	fe040793          	addi	a5,s0,-32
    800004f2:	973e                	add	a4,a4,a5
    800004f4:	02d00793          	li	a5,45
    800004f8:	fef70823          	sb	a5,-16(a4)
    800004fc:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000500:	02e05763          	blez	a4,8000052e <printint+0x8e>
    80000504:	fd040793          	addi	a5,s0,-48
    80000508:	00e784b3          	add	s1,a5,a4
    8000050c:	fff78913          	addi	s2,a5,-1
    80000510:	993a                	add	s2,s2,a4
    80000512:	377d                	addiw	a4,a4,-1
    80000514:	1702                	slli	a4,a4,0x20
    80000516:	9301                	srli	a4,a4,0x20
    80000518:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051c:	fff4c503          	lbu	a0,-1(s1)
    80000520:	00000097          	auipc	ra,0x0
    80000524:	d60080e7          	jalr	-672(ra) # 80000280 <consputc>
  while(--i >= 0)
    80000528:	14fd                	addi	s1,s1,-1
    8000052a:	ff2499e3          	bne	s1,s2,8000051c <printint+0x7c>
}
    8000052e:	70a2                	ld	ra,40(sp)
    80000530:	7402                	ld	s0,32(sp)
    80000532:	64e2                	ld	s1,24(sp)
    80000534:	6942                	ld	s2,16(sp)
    80000536:	6145                	addi	sp,sp,48
    80000538:	8082                	ret
    x = -xx;
    8000053a:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053e:	4885                	li	a7,1
    x = -xx;
    80000540:	bf9d                	j	800004b6 <printint+0x16>

0000000080000542 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000542:	1101                	addi	sp,sp,-32
    80000544:	ec06                	sd	ra,24(sp)
    80000546:	e822                	sd	s0,16(sp)
    80000548:	e426                	sd	s1,8(sp)
    8000054a:	1000                	addi	s0,sp,32
    8000054c:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054e:	00011797          	auipc	a5,0x11
    80000552:	3a07a123          	sw	zero,930(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    80000556:	00008517          	auipc	a0,0x8
    8000055a:	ac250513          	addi	a0,a0,-1342 # 80008018 <etext+0x18>
    8000055e:	00000097          	auipc	ra,0x0
    80000562:	02e080e7          	jalr	46(ra) # 8000058c <printf>
  printf(s);
    80000566:	8526                	mv	a0,s1
    80000568:	00000097          	auipc	ra,0x0
    8000056c:	024080e7          	jalr	36(ra) # 8000058c <printf>
  printf("\n");
    80000570:	00008517          	auipc	a0,0x8
    80000574:	b5850513          	addi	a0,a0,-1192 # 800080c8 <digits+0x88>
    80000578:	00000097          	auipc	ra,0x0
    8000057c:	014080e7          	jalr	20(ra) # 8000058c <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000580:	4785                	li	a5,1
    80000582:	00009717          	auipc	a4,0x9
    80000586:	a6f72f23          	sw	a5,-1410(a4) # 80009000 <panicked>
  for(;;)
    8000058a:	a001                	j	8000058a <panic+0x48>

000000008000058c <printf>:
{
    8000058c:	7131                	addi	sp,sp,-192
    8000058e:	fc86                	sd	ra,120(sp)
    80000590:	f8a2                	sd	s0,112(sp)
    80000592:	f4a6                	sd	s1,104(sp)
    80000594:	f0ca                	sd	s2,96(sp)
    80000596:	ecce                	sd	s3,88(sp)
    80000598:	e8d2                	sd	s4,80(sp)
    8000059a:	e4d6                	sd	s5,72(sp)
    8000059c:	e0da                	sd	s6,64(sp)
    8000059e:	fc5e                	sd	s7,56(sp)
    800005a0:	f862                	sd	s8,48(sp)
    800005a2:	f466                	sd	s9,40(sp)
    800005a4:	f06a                	sd	s10,32(sp)
    800005a6:	ec6e                	sd	s11,24(sp)
    800005a8:	0100                	addi	s0,sp,128
    800005aa:	8a2a                	mv	s4,a0
    800005ac:	e40c                	sd	a1,8(s0)
    800005ae:	e810                	sd	a2,16(s0)
    800005b0:	ec14                	sd	a3,24(s0)
    800005b2:	f018                	sd	a4,32(s0)
    800005b4:	f41c                	sd	a5,40(s0)
    800005b6:	03043823          	sd	a6,48(s0)
    800005ba:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005be:	00011d97          	auipc	s11,0x11
    800005c2:	332dad83          	lw	s11,818(s11) # 800118f0 <pr+0x18>
  if(locking)
    800005c6:	020d9b63          	bnez	s11,800005fc <printf+0x70>
  if (fmt == 0)
    800005ca:	040a0263          	beqz	s4,8000060e <printf+0x82>
  va_start(ap, fmt);
    800005ce:	00840793          	addi	a5,s0,8
    800005d2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d6:	000a4503          	lbu	a0,0(s4)
    800005da:	14050f63          	beqz	a0,80000738 <printf+0x1ac>
    800005de:	4981                	li	s3,0
    if(c != '%'){
    800005e0:	02500a93          	li	s5,37
    switch(c){
    800005e4:	07000b93          	li	s7,112
  consputc('x');
    800005e8:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005ea:	00008b17          	auipc	s6,0x8
    800005ee:	a56b0b13          	addi	s6,s6,-1450 # 80008040 <digits>
    switch(c){
    800005f2:	07300c93          	li	s9,115
    800005f6:	06400c13          	li	s8,100
    800005fa:	a82d                	j	80000634 <printf+0xa8>
    acquire(&pr.lock);
    800005fc:	00011517          	auipc	a0,0x11
    80000600:	2dc50513          	addi	a0,a0,732 # 800118d8 <pr>
    80000604:	00000097          	auipc	ra,0x0
    80000608:	64c080e7          	jalr	1612(ra) # 80000c50 <acquire>
    8000060c:	bf7d                	j	800005ca <printf+0x3e>
    panic("null fmt");
    8000060e:	00008517          	auipc	a0,0x8
    80000612:	a1a50513          	addi	a0,a0,-1510 # 80008028 <etext+0x28>
    80000616:	00000097          	auipc	ra,0x0
    8000061a:	f2c080e7          	jalr	-212(ra) # 80000542 <panic>
      consputc(c);
    8000061e:	00000097          	auipc	ra,0x0
    80000622:	c62080e7          	jalr	-926(ra) # 80000280 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000626:	2985                	addiw	s3,s3,1
    80000628:	013a07b3          	add	a5,s4,s3
    8000062c:	0007c503          	lbu	a0,0(a5)
    80000630:	10050463          	beqz	a0,80000738 <printf+0x1ac>
    if(c != '%'){
    80000634:	ff5515e3          	bne	a0,s5,8000061e <printf+0x92>
    c = fmt[++i] & 0xff;
    80000638:	2985                	addiw	s3,s3,1
    8000063a:	013a07b3          	add	a5,s4,s3
    8000063e:	0007c783          	lbu	a5,0(a5)
    80000642:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000646:	cbed                	beqz	a5,80000738 <printf+0x1ac>
    switch(c){
    80000648:	05778a63          	beq	a5,s7,8000069c <printf+0x110>
    8000064c:	02fbf663          	bgeu	s7,a5,80000678 <printf+0xec>
    80000650:	09978863          	beq	a5,s9,800006e0 <printf+0x154>
    80000654:	07800713          	li	a4,120
    80000658:	0ce79563          	bne	a5,a4,80000722 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065c:	f8843783          	ld	a5,-120(s0)
    80000660:	00878713          	addi	a4,a5,8
    80000664:	f8e43423          	sd	a4,-120(s0)
    80000668:	4605                	li	a2,1
    8000066a:	85ea                	mv	a1,s10
    8000066c:	4388                	lw	a0,0(a5)
    8000066e:	00000097          	auipc	ra,0x0
    80000672:	e32080e7          	jalr	-462(ra) # 800004a0 <printint>
      break;
    80000676:	bf45                	j	80000626 <printf+0x9a>
    switch(c){
    80000678:	09578f63          	beq	a5,s5,80000716 <printf+0x18a>
    8000067c:	0b879363          	bne	a5,s8,80000722 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000680:	f8843783          	ld	a5,-120(s0)
    80000684:	00878713          	addi	a4,a5,8
    80000688:	f8e43423          	sd	a4,-120(s0)
    8000068c:	4605                	li	a2,1
    8000068e:	45a9                	li	a1,10
    80000690:	4388                	lw	a0,0(a5)
    80000692:	00000097          	auipc	ra,0x0
    80000696:	e0e080e7          	jalr	-498(ra) # 800004a0 <printint>
      break;
    8000069a:	b771                	j	80000626 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069c:	f8843783          	ld	a5,-120(s0)
    800006a0:	00878713          	addi	a4,a5,8
    800006a4:	f8e43423          	sd	a4,-120(s0)
    800006a8:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006ac:	03000513          	li	a0,48
    800006b0:	00000097          	auipc	ra,0x0
    800006b4:	bd0080e7          	jalr	-1072(ra) # 80000280 <consputc>
  consputc('x');
    800006b8:	07800513          	li	a0,120
    800006bc:	00000097          	auipc	ra,0x0
    800006c0:	bc4080e7          	jalr	-1084(ra) # 80000280 <consputc>
    800006c4:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c6:	03c95793          	srli	a5,s2,0x3c
    800006ca:	97da                	add	a5,a5,s6
    800006cc:	0007c503          	lbu	a0,0(a5)
    800006d0:	00000097          	auipc	ra,0x0
    800006d4:	bb0080e7          	jalr	-1104(ra) # 80000280 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d8:	0912                	slli	s2,s2,0x4
    800006da:	34fd                	addiw	s1,s1,-1
    800006dc:	f4ed                	bnez	s1,800006c6 <printf+0x13a>
    800006de:	b7a1                	j	80000626 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e0:	f8843783          	ld	a5,-120(s0)
    800006e4:	00878713          	addi	a4,a5,8
    800006e8:	f8e43423          	sd	a4,-120(s0)
    800006ec:	6384                	ld	s1,0(a5)
    800006ee:	cc89                	beqz	s1,80000708 <printf+0x17c>
      for(; *s; s++)
    800006f0:	0004c503          	lbu	a0,0(s1)
    800006f4:	d90d                	beqz	a0,80000626 <printf+0x9a>
        consputc(*s);
    800006f6:	00000097          	auipc	ra,0x0
    800006fa:	b8a080e7          	jalr	-1142(ra) # 80000280 <consputc>
      for(; *s; s++)
    800006fe:	0485                	addi	s1,s1,1
    80000700:	0004c503          	lbu	a0,0(s1)
    80000704:	f96d                	bnez	a0,800006f6 <printf+0x16a>
    80000706:	b705                	j	80000626 <printf+0x9a>
        s = "(null)";
    80000708:	00008497          	auipc	s1,0x8
    8000070c:	91848493          	addi	s1,s1,-1768 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000710:	02800513          	li	a0,40
    80000714:	b7cd                	j	800006f6 <printf+0x16a>
      consputc('%');
    80000716:	8556                	mv	a0,s5
    80000718:	00000097          	auipc	ra,0x0
    8000071c:	b68080e7          	jalr	-1176(ra) # 80000280 <consputc>
      break;
    80000720:	b719                	j	80000626 <printf+0x9a>
      consputc('%');
    80000722:	8556                	mv	a0,s5
    80000724:	00000097          	auipc	ra,0x0
    80000728:	b5c080e7          	jalr	-1188(ra) # 80000280 <consputc>
      consputc(c);
    8000072c:	8526                	mv	a0,s1
    8000072e:	00000097          	auipc	ra,0x0
    80000732:	b52080e7          	jalr	-1198(ra) # 80000280 <consputc>
      break;
    80000736:	bdc5                	j	80000626 <printf+0x9a>
  if(locking)
    80000738:	020d9163          	bnez	s11,8000075a <printf+0x1ce>
}
    8000073c:	70e6                	ld	ra,120(sp)
    8000073e:	7446                	ld	s0,112(sp)
    80000740:	74a6                	ld	s1,104(sp)
    80000742:	7906                	ld	s2,96(sp)
    80000744:	69e6                	ld	s3,88(sp)
    80000746:	6a46                	ld	s4,80(sp)
    80000748:	6aa6                	ld	s5,72(sp)
    8000074a:	6b06                	ld	s6,64(sp)
    8000074c:	7be2                	ld	s7,56(sp)
    8000074e:	7c42                	ld	s8,48(sp)
    80000750:	7ca2                	ld	s9,40(sp)
    80000752:	7d02                	ld	s10,32(sp)
    80000754:	6de2                	ld	s11,24(sp)
    80000756:	6129                	addi	sp,sp,192
    80000758:	8082                	ret
    release(&pr.lock);
    8000075a:	00011517          	auipc	a0,0x11
    8000075e:	17e50513          	addi	a0,a0,382 # 800118d8 <pr>
    80000762:	00000097          	auipc	ra,0x0
    80000766:	5a2080e7          	jalr	1442(ra) # 80000d04 <release>
}
    8000076a:	bfc9                	j	8000073c <printf+0x1b0>

000000008000076c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076c:	1101                	addi	sp,sp,-32
    8000076e:	ec06                	sd	ra,24(sp)
    80000770:	e822                	sd	s0,16(sp)
    80000772:	e426                	sd	s1,8(sp)
    80000774:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000776:	00011497          	auipc	s1,0x11
    8000077a:	16248493          	addi	s1,s1,354 # 800118d8 <pr>
    8000077e:	00008597          	auipc	a1,0x8
    80000782:	8ba58593          	addi	a1,a1,-1862 # 80008038 <etext+0x38>
    80000786:	8526                	mv	a0,s1
    80000788:	00000097          	auipc	ra,0x0
    8000078c:	438080e7          	jalr	1080(ra) # 80000bc0 <initlock>
  pr.locking = 1;
    80000790:	4785                	li	a5,1
    80000792:	cc9c                	sw	a5,24(s1)
}
    80000794:	60e2                	ld	ra,24(sp)
    80000796:	6442                	ld	s0,16(sp)
    80000798:	64a2                	ld	s1,8(sp)
    8000079a:	6105                	addi	sp,sp,32
    8000079c:	8082                	ret

000000008000079e <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079e:	1141                	addi	sp,sp,-16
    800007a0:	e406                	sd	ra,8(sp)
    800007a2:	e022                	sd	s0,0(sp)
    800007a4:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a6:	100007b7          	lui	a5,0x10000
    800007aa:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ae:	f8000713          	li	a4,-128
    800007b2:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b6:	470d                	li	a4,3
    800007b8:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007bc:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007c0:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c4:	469d                	li	a3,7
    800007c6:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007ca:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007ce:	00008597          	auipc	a1,0x8
    800007d2:	88a58593          	addi	a1,a1,-1910 # 80008058 <digits+0x18>
    800007d6:	00011517          	auipc	a0,0x11
    800007da:	12250513          	addi	a0,a0,290 # 800118f8 <uart_tx_lock>
    800007de:	00000097          	auipc	ra,0x0
    800007e2:	3e2080e7          	jalr	994(ra) # 80000bc0 <initlock>
}
    800007e6:	60a2                	ld	ra,8(sp)
    800007e8:	6402                	ld	s0,0(sp)
    800007ea:	0141                	addi	sp,sp,16
    800007ec:	8082                	ret

00000000800007ee <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ee:	1101                	addi	sp,sp,-32
    800007f0:	ec06                	sd	ra,24(sp)
    800007f2:	e822                	sd	s0,16(sp)
    800007f4:	e426                	sd	s1,8(sp)
    800007f6:	1000                	addi	s0,sp,32
    800007f8:	84aa                	mv	s1,a0
  push_off();
    800007fa:	00000097          	auipc	ra,0x0
    800007fe:	40a080e7          	jalr	1034(ra) # 80000c04 <push_off>

  if(panicked){
    80000802:	00008797          	auipc	a5,0x8
    80000806:	7fe7a783          	lw	a5,2046(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080a:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080e:	c391                	beqz	a5,80000812 <uartputc_sync+0x24>
    for(;;)
    80000810:	a001                	j	80000810 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000812:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000816:	0207f793          	andi	a5,a5,32
    8000081a:	dfe5                	beqz	a5,80000812 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081c:	0ff4f513          	andi	a0,s1,255
    80000820:	100007b7          	lui	a5,0x10000
    80000824:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000828:	00000097          	auipc	ra,0x0
    8000082c:	47c080e7          	jalr	1148(ra) # 80000ca4 <pop_off>
}
    80000830:	60e2                	ld	ra,24(sp)
    80000832:	6442                	ld	s0,16(sp)
    80000834:	64a2                	ld	s1,8(sp)
    80000836:	6105                	addi	sp,sp,32
    80000838:	8082                	ret

000000008000083a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000083a:	00008797          	auipc	a5,0x8
    8000083e:	7ca7a783          	lw	a5,1994(a5) # 80009004 <uart_tx_r>
    80000842:	00008717          	auipc	a4,0x8
    80000846:	7c672703          	lw	a4,1990(a4) # 80009008 <uart_tx_w>
    8000084a:	08f70063          	beq	a4,a5,800008ca <uartstart+0x90>
{
    8000084e:	7139                	addi	sp,sp,-64
    80000850:	fc06                	sd	ra,56(sp)
    80000852:	f822                	sd	s0,48(sp)
    80000854:	f426                	sd	s1,40(sp)
    80000856:	f04a                	sd	s2,32(sp)
    80000858:	ec4e                	sd	s3,24(sp)
    8000085a:	e852                	sd	s4,16(sp)
    8000085c:	e456                	sd	s5,8(sp)
    8000085e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000860:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    80000864:	00011a97          	auipc	s5,0x11
    80000868:	094a8a93          	addi	s5,s5,148 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    8000086c:	00008497          	auipc	s1,0x8
    80000870:	79848493          	addi	s1,s1,1944 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000874:	00008a17          	auipc	s4,0x8
    80000878:	794a0a13          	addi	s4,s4,1940 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000880:	02077713          	andi	a4,a4,32
    80000884:	cb15                	beqz	a4,800008b8 <uartstart+0x7e>
    int c = uart_tx_buf[uart_tx_r];
    80000886:	00fa8733          	add	a4,s5,a5
    8000088a:	01874983          	lbu	s3,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    8000088e:	2785                	addiw	a5,a5,1
    80000890:	41f7d71b          	sraiw	a4,a5,0x1f
    80000894:	01b7571b          	srliw	a4,a4,0x1b
    80000898:	9fb9                	addw	a5,a5,a4
    8000089a:	8bfd                	andi	a5,a5,31
    8000089c:	9f99                	subw	a5,a5,a4
    8000089e:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a0:	8526                	mv	a0,s1
    800008a2:	00002097          	auipc	ra,0x2
    800008a6:	b0a080e7          	jalr	-1270(ra) # 800023ac <wakeup>
    
    WriteReg(THR, c);
    800008aa:	01390023          	sb	s3,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008ae:	409c                	lw	a5,0(s1)
    800008b0:	000a2703          	lw	a4,0(s4)
    800008b4:	fcf714e3          	bne	a4,a5,8000087c <uartstart+0x42>
  }
}
    800008b8:	70e2                	ld	ra,56(sp)
    800008ba:	7442                	ld	s0,48(sp)
    800008bc:	74a2                	ld	s1,40(sp)
    800008be:	7902                	ld	s2,32(sp)
    800008c0:	69e2                	ld	s3,24(sp)
    800008c2:	6a42                	ld	s4,16(sp)
    800008c4:	6aa2                	ld	s5,8(sp)
    800008c6:	6121                	addi	sp,sp,64
    800008c8:	8082                	ret
    800008ca:	8082                	ret

00000000800008cc <uartputc>:
{
    800008cc:	7179                	addi	sp,sp,-48
    800008ce:	f406                	sd	ra,40(sp)
    800008d0:	f022                	sd	s0,32(sp)
    800008d2:	ec26                	sd	s1,24(sp)
    800008d4:	e84a                	sd	s2,16(sp)
    800008d6:	e44e                	sd	s3,8(sp)
    800008d8:	e052                	sd	s4,0(sp)
    800008da:	1800                	addi	s0,sp,48
    800008dc:	84aa                	mv	s1,a0
  acquire(&uart_tx_lock);
    800008de:	00011517          	auipc	a0,0x11
    800008e2:	01a50513          	addi	a0,a0,26 # 800118f8 <uart_tx_lock>
    800008e6:	00000097          	auipc	ra,0x0
    800008ea:	36a080e7          	jalr	874(ra) # 80000c50 <acquire>
  if(panicked){
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	7127a783          	lw	a5,1810(a5) # 80009000 <panicked>
    800008f6:	c391                	beqz	a5,800008fa <uartputc+0x2e>
    for(;;)
    800008f8:	a001                	j	800008f8 <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    800008fa:	00008697          	auipc	a3,0x8
    800008fe:	70e6a683          	lw	a3,1806(a3) # 80009008 <uart_tx_w>
    80000902:	0016879b          	addiw	a5,a3,1
    80000906:	41f7d71b          	sraiw	a4,a5,0x1f
    8000090a:	01b7571b          	srliw	a4,a4,0x1b
    8000090e:	9fb9                	addw	a5,a5,a4
    80000910:	8bfd                	andi	a5,a5,31
    80000912:	9f99                	subw	a5,a5,a4
    80000914:	00008717          	auipc	a4,0x8
    80000918:	6f072703          	lw	a4,1776(a4) # 80009004 <uart_tx_r>
    8000091c:	04f71363          	bne	a4,a5,80000962 <uartputc+0x96>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000920:	00011a17          	auipc	s4,0x11
    80000924:	fd8a0a13          	addi	s4,s4,-40 # 800118f8 <uart_tx_lock>
    80000928:	00008917          	auipc	s2,0x8
    8000092c:	6dc90913          	addi	s2,s2,1756 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000930:	00008997          	auipc	s3,0x8
    80000934:	6d898993          	addi	s3,s3,1752 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000938:	85d2                	mv	a1,s4
    8000093a:	854a                	mv	a0,s2
    8000093c:	00002097          	auipc	ra,0x2
    80000940:	8f0080e7          	jalr	-1808(ra) # 8000222c <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000944:	0009a683          	lw	a3,0(s3)
    80000948:	0016879b          	addiw	a5,a3,1
    8000094c:	41f7d71b          	sraiw	a4,a5,0x1f
    80000950:	01b7571b          	srliw	a4,a4,0x1b
    80000954:	9fb9                	addw	a5,a5,a4
    80000956:	8bfd                	andi	a5,a5,31
    80000958:	9f99                	subw	a5,a5,a4
    8000095a:	00092703          	lw	a4,0(s2)
    8000095e:	fcf70de3          	beq	a4,a5,80000938 <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    80000962:	00011917          	auipc	s2,0x11
    80000966:	f9690913          	addi	s2,s2,-106 # 800118f8 <uart_tx_lock>
    8000096a:	96ca                	add	a3,a3,s2
    8000096c:	00968c23          	sb	s1,24(a3)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    80000970:	00008717          	auipc	a4,0x8
    80000974:	68f72c23          	sw	a5,1688(a4) # 80009008 <uart_tx_w>
      uartstart();
    80000978:	00000097          	auipc	ra,0x0
    8000097c:	ec2080e7          	jalr	-318(ra) # 8000083a <uartstart>
      release(&uart_tx_lock);
    80000980:	854a                	mv	a0,s2
    80000982:	00000097          	auipc	ra,0x0
    80000986:	382080e7          	jalr	898(ra) # 80000d04 <release>
}
    8000098a:	70a2                	ld	ra,40(sp)
    8000098c:	7402                	ld	s0,32(sp)
    8000098e:	64e2                	ld	s1,24(sp)
    80000990:	6942                	ld	s2,16(sp)
    80000992:	69a2                	ld	s3,8(sp)
    80000994:	6a02                	ld	s4,0(sp)
    80000996:	6145                	addi	sp,sp,48
    80000998:	8082                	ret

000000008000099a <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000099a:	1141                	addi	sp,sp,-16
    8000099c:	e422                	sd	s0,8(sp)
    8000099e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009a0:	100007b7          	lui	a5,0x10000
    800009a4:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009a8:	8b85                	andi	a5,a5,1
    800009aa:	cb91                	beqz	a5,800009be <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009ac:	100007b7          	lui	a5,0x10000
    800009b0:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009b4:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009b8:	6422                	ld	s0,8(sp)
    800009ba:	0141                	addi	sp,sp,16
    800009bc:	8082                	ret
    return -1;
    800009be:	557d                	li	a0,-1
    800009c0:	bfe5                	j	800009b8 <uartgetc+0x1e>

00000000800009c2 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    800009c2:	1101                	addi	sp,sp,-32
    800009c4:	ec06                	sd	ra,24(sp)
    800009c6:	e822                	sd	s0,16(sp)
    800009c8:	e426                	sd	s1,8(sp)
    800009ca:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009cc:	54fd                	li	s1,-1
    800009ce:	a029                	j	800009d8 <uartintr+0x16>
      break;
    consoleintr(c);
    800009d0:	00000097          	auipc	ra,0x0
    800009d4:	8f2080e7          	jalr	-1806(ra) # 800002c2 <consoleintr>
    int c = uartgetc();
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	fc2080e7          	jalr	-62(ra) # 8000099a <uartgetc>
    if(c == -1)
    800009e0:	fe9518e3          	bne	a0,s1,800009d0 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009e4:	00011497          	auipc	s1,0x11
    800009e8:	f1448493          	addi	s1,s1,-236 # 800118f8 <uart_tx_lock>
    800009ec:	8526                	mv	a0,s1
    800009ee:	00000097          	auipc	ra,0x0
    800009f2:	262080e7          	jalr	610(ra) # 80000c50 <acquire>
  uartstart();
    800009f6:	00000097          	auipc	ra,0x0
    800009fa:	e44080e7          	jalr	-444(ra) # 8000083a <uartstart>
  release(&uart_tx_lock);
    800009fe:	8526                	mv	a0,s1
    80000a00:	00000097          	auipc	ra,0x0
    80000a04:	304080e7          	jalr	772(ra) # 80000d04 <release>
}
    80000a08:	60e2                	ld	ra,24(sp)
    80000a0a:	6442                	ld	s0,16(sp)
    80000a0c:	64a2                	ld	s1,8(sp)
    80000a0e:	6105                	addi	sp,sp,32
    80000a10:	8082                	ret

0000000080000a12 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a12:	1101                	addi	sp,sp,-32
    80000a14:	ec06                	sd	ra,24(sp)
    80000a16:	e822                	sd	s0,16(sp)
    80000a18:	e426                	sd	s1,8(sp)
    80000a1a:	e04a                	sd	s2,0(sp)
    80000a1c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a1e:	03451793          	slli	a5,a0,0x34
    80000a22:	ebb9                	bnez	a5,80000a78 <kfree+0x66>
    80000a24:	84aa                	mv	s1,a0
    80000a26:	00025797          	auipc	a5,0x25
    80000a2a:	5da78793          	addi	a5,a5,1498 # 80026000 <end>
    80000a2e:	04f56563          	bltu	a0,a5,80000a78 <kfree+0x66>
    80000a32:	47c5                	li	a5,17
    80000a34:	07ee                	slli	a5,a5,0x1b
    80000a36:	04f57163          	bgeu	a0,a5,80000a78 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a3a:	6605                	lui	a2,0x1
    80000a3c:	4585                	li	a1,1
    80000a3e:	00000097          	auipc	ra,0x0
    80000a42:	30e080e7          	jalr	782(ra) # 80000d4c <memset>
  // Cast that byte-page memory that was freed
  // as a free-linked-list-node aka struct run
  r = (struct run*)pa;

  // Appends to the linked-list of free-pages
  acquire(&kmem.lock);
    80000a46:	00011917          	auipc	s2,0x11
    80000a4a:	eea90913          	addi	s2,s2,-278 # 80011930 <kmem>
    80000a4e:	854a                	mv	a0,s2
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	200080e7          	jalr	512(ra) # 80000c50 <acquire>
  r->next = kmem.freelist;
    80000a58:	01893783          	ld	a5,24(s2)
    80000a5c:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a5e:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a62:	854a                	mv	a0,s2
    80000a64:	00000097          	auipc	ra,0x0
    80000a68:	2a0080e7          	jalr	672(ra) # 80000d04 <release>
}
    80000a6c:	60e2                	ld	ra,24(sp)
    80000a6e:	6442                	ld	s0,16(sp)
    80000a70:	64a2                	ld	s1,8(sp)
    80000a72:	6902                	ld	s2,0(sp)
    80000a74:	6105                	addi	sp,sp,32
    80000a76:	8082                	ret
    panic("kfree");
    80000a78:	00007517          	auipc	a0,0x7
    80000a7c:	5e850513          	addi	a0,a0,1512 # 80008060 <digits+0x20>
    80000a80:	00000097          	auipc	ra,0x0
    80000a84:	ac2080e7          	jalr	-1342(ra) # 80000542 <panic>

0000000080000a88 <freerange>:
{
    80000a88:	7179                	addi	sp,sp,-48
    80000a8a:	f406                	sd	ra,40(sp)
    80000a8c:	f022                	sd	s0,32(sp)
    80000a8e:	ec26                	sd	s1,24(sp)
    80000a90:	e84a                	sd	s2,16(sp)
    80000a92:	e44e                	sd	s3,8(sp)
    80000a94:	e052                	sd	s4,0(sp)
    80000a96:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a98:	6785                	lui	a5,0x1
    80000a9a:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a9e:	94aa                	add	s1,s1,a0
    80000aa0:	757d                	lui	a0,0xfffff
    80000aa2:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aa4:	94be                	add	s1,s1,a5
    80000aa6:	0095ee63          	bltu	a1,s1,80000ac2 <freerange+0x3a>
    80000aaa:	892e                	mv	s2,a1
    kfree(p);
    80000aac:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000aae:	6985                	lui	s3,0x1
    kfree(p);
    80000ab0:	01448533          	add	a0,s1,s4
    80000ab4:	00000097          	auipc	ra,0x0
    80000ab8:	f5e080e7          	jalr	-162(ra) # 80000a12 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000abc:	94ce                	add	s1,s1,s3
    80000abe:	fe9979e3          	bgeu	s2,s1,80000ab0 <freerange+0x28>
}
    80000ac2:	70a2                	ld	ra,40(sp)
    80000ac4:	7402                	ld	s0,32(sp)
    80000ac6:	64e2                	ld	s1,24(sp)
    80000ac8:	6942                	ld	s2,16(sp)
    80000aca:	69a2                	ld	s3,8(sp)
    80000acc:	6a02                	ld	s4,0(sp)
    80000ace:	6145                	addi	sp,sp,48
    80000ad0:	8082                	ret

0000000080000ad2 <kinit>:
{
    80000ad2:	1141                	addi	sp,sp,-16
    80000ad4:	e406                	sd	ra,8(sp)
    80000ad6:	e022                	sd	s0,0(sp)
    80000ad8:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ada:	00007597          	auipc	a1,0x7
    80000ade:	58e58593          	addi	a1,a1,1422 # 80008068 <digits+0x28>
    80000ae2:	00011517          	auipc	a0,0x11
    80000ae6:	e4e50513          	addi	a0,a0,-434 # 80011930 <kmem>
    80000aea:	00000097          	auipc	ra,0x0
    80000aee:	0d6080e7          	jalr	214(ra) # 80000bc0 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000af2:	45c5                	li	a1,17
    80000af4:	05ee                	slli	a1,a1,0x1b
    80000af6:	00025517          	auipc	a0,0x25
    80000afa:	50a50513          	addi	a0,a0,1290 # 80026000 <end>
    80000afe:	00000097          	auipc	ra,0x0
    80000b02:	f8a080e7          	jalr	-118(ra) # 80000a88 <freerange>
}
    80000b06:	60a2                	ld	ra,8(sp)
    80000b08:	6402                	ld	s0,0(sp)
    80000b0a:	0141                	addi	sp,sp,16
    80000b0c:	8082                	ret

0000000080000b0e <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b0e:	1101                	addi	sp,sp,-32
    80000b10:	ec06                	sd	ra,24(sp)
    80000b12:	e822                	sd	s0,16(sp)
    80000b14:	e426                	sd	s1,8(sp)
    80000b16:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b18:	00011497          	auipc	s1,0x11
    80000b1c:	e1848493          	addi	s1,s1,-488 # 80011930 <kmem>
    80000b20:	8526                	mv	a0,s1
    80000b22:	00000097          	auipc	ra,0x0
    80000b26:	12e080e7          	jalr	302(ra) # 80000c50 <acquire>
  r = kmem.freelist;
    80000b2a:	6c84                	ld	s1,24(s1)
  if(r)
    80000b2c:	c885                	beqz	s1,80000b5c <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b2e:	609c                	ld	a5,0(s1)
    80000b30:	00011517          	auipc	a0,0x11
    80000b34:	e0050513          	addi	a0,a0,-512 # 80011930 <kmem>
    80000b38:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b3a:	00000097          	auipc	ra,0x0
    80000b3e:	1ca080e7          	jalr	458(ra) # 80000d04 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b42:	6605                	lui	a2,0x1
    80000b44:	4595                	li	a1,5
    80000b46:	8526                	mv	a0,s1
    80000b48:	00000097          	auipc	ra,0x0
    80000b4c:	204080e7          	jalr	516(ra) # 80000d4c <memset>
  return (void*)r;
}
    80000b50:	8526                	mv	a0,s1
    80000b52:	60e2                	ld	ra,24(sp)
    80000b54:	6442                	ld	s0,16(sp)
    80000b56:	64a2                	ld	s1,8(sp)
    80000b58:	6105                	addi	sp,sp,32
    80000b5a:	8082                	ret
  release(&kmem.lock);
    80000b5c:	00011517          	auipc	a0,0x11
    80000b60:	dd450513          	addi	a0,a0,-556 # 80011930 <kmem>
    80000b64:	00000097          	auipc	ra,0x0
    80000b68:	1a0080e7          	jalr	416(ra) # 80000d04 <release>
  if(r)
    80000b6c:	b7d5                	j	80000b50 <kalloc+0x42>

0000000080000b6e <countfree>:


void
countfree(uint64 *mem)
{
    80000b6e:	1101                	addi	sp,sp,-32
    80000b70:	ec06                	sd	ra,24(sp)
    80000b72:	e822                	sd	s0,16(sp)
    80000b74:	e426                	sd	s1,8(sp)
    80000b76:	e04a                	sd	s2,0(sp)
    80000b78:	1000                	addi	s0,sp,32
    80000b7a:	84aa                	mv	s1,a0
  struct run *t;
  struct run *s;
  *(mem) = 0;
    80000b7c:	00053023          	sd	zero,0(a0)

  acquire(&kmem.lock);
    80000b80:	00011917          	auipc	s2,0x11
    80000b84:	db090913          	addi	s2,s2,-592 # 80011930 <kmem>
    80000b88:	854a                	mv	a0,s2
    80000b8a:	00000097          	auipc	ra,0x0
    80000b8e:	0c6080e7          	jalr	198(ra) # 80000c50 <acquire>
  t = kmem.freelist;
    80000b92:	01893703          	ld	a4,24(s2)
  s = kmem.freelist;
  while(s)
    80000b96:	c719                	beqz	a4,80000ba4 <countfree+0x36>
  {
    s = t->next;
    t = s;
    *mem += PGSIZE;
    80000b98:	6685                	lui	a3,0x1
    s = t->next;
    80000b9a:	6318                	ld	a4,0(a4)
    *mem += PGSIZE;
    80000b9c:	609c                	ld	a5,0(s1)
    80000b9e:	97b6                	add	a5,a5,a3
    80000ba0:	e09c                	sd	a5,0(s1)
  while(s)
    80000ba2:	ff65                	bnez	a4,80000b9a <countfree+0x2c>
  }
  release(&kmem.lock);
    80000ba4:	00011517          	auipc	a0,0x11
    80000ba8:	d8c50513          	addi	a0,a0,-628 # 80011930 <kmem>
    80000bac:	00000097          	auipc	ra,0x0
    80000bb0:	158080e7          	jalr	344(ra) # 80000d04 <release>
}
    80000bb4:	60e2                	ld	ra,24(sp)
    80000bb6:	6442                	ld	s0,16(sp)
    80000bb8:	64a2                	ld	s1,8(sp)
    80000bba:	6902                	ld	s2,0(sp)
    80000bbc:	6105                	addi	sp,sp,32
    80000bbe:	8082                	ret

0000000080000bc0 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bc0:	1141                	addi	sp,sp,-16
    80000bc2:	e422                	sd	s0,8(sp)
    80000bc4:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bc6:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bc8:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bcc:	00053823          	sd	zero,16(a0)
}
    80000bd0:	6422                	ld	s0,8(sp)
    80000bd2:	0141                	addi	sp,sp,16
    80000bd4:	8082                	ret

0000000080000bd6 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bd6:	411c                	lw	a5,0(a0)
    80000bd8:	e399                	bnez	a5,80000bde <holding+0x8>
    80000bda:	4501                	li	a0,0
  return r;
}
    80000bdc:	8082                	ret
{
    80000bde:	1101                	addi	sp,sp,-32
    80000be0:	ec06                	sd	ra,24(sp)
    80000be2:	e822                	sd	s0,16(sp)
    80000be4:	e426                	sd	s1,8(sp)
    80000be6:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000be8:	6904                	ld	s1,16(a0)
    80000bea:	00001097          	auipc	ra,0x1
    80000bee:	e16080e7          	jalr	-490(ra) # 80001a00 <mycpu>
    80000bf2:	40a48533          	sub	a0,s1,a0
    80000bf6:	00153513          	seqz	a0,a0
}
    80000bfa:	60e2                	ld	ra,24(sp)
    80000bfc:	6442                	ld	s0,16(sp)
    80000bfe:	64a2                	ld	s1,8(sp)
    80000c00:	6105                	addi	sp,sp,32
    80000c02:	8082                	ret

0000000080000c04 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c04:	1101                	addi	sp,sp,-32
    80000c06:	ec06                	sd	ra,24(sp)
    80000c08:	e822                	sd	s0,16(sp)
    80000c0a:	e426                	sd	s1,8(sp)
    80000c0c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c0e:	100024f3          	csrr	s1,sstatus
    80000c12:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c16:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c18:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c1c:	00001097          	auipc	ra,0x1
    80000c20:	de4080e7          	jalr	-540(ra) # 80001a00 <mycpu>
    80000c24:	5d3c                	lw	a5,120(a0)
    80000c26:	cf89                	beqz	a5,80000c40 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c28:	00001097          	auipc	ra,0x1
    80000c2c:	dd8080e7          	jalr	-552(ra) # 80001a00 <mycpu>
    80000c30:	5d3c                	lw	a5,120(a0)
    80000c32:	2785                	addiw	a5,a5,1
    80000c34:	dd3c                	sw	a5,120(a0)
}
    80000c36:	60e2                	ld	ra,24(sp)
    80000c38:	6442                	ld	s0,16(sp)
    80000c3a:	64a2                	ld	s1,8(sp)
    80000c3c:	6105                	addi	sp,sp,32
    80000c3e:	8082                	ret
    mycpu()->intena = old;
    80000c40:	00001097          	auipc	ra,0x1
    80000c44:	dc0080e7          	jalr	-576(ra) # 80001a00 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c48:	8085                	srli	s1,s1,0x1
    80000c4a:	8885                	andi	s1,s1,1
    80000c4c:	dd64                	sw	s1,124(a0)
    80000c4e:	bfe9                	j	80000c28 <push_off+0x24>

0000000080000c50 <acquire>:
{
    80000c50:	1101                	addi	sp,sp,-32
    80000c52:	ec06                	sd	ra,24(sp)
    80000c54:	e822                	sd	s0,16(sp)
    80000c56:	e426                	sd	s1,8(sp)
    80000c58:	1000                	addi	s0,sp,32
    80000c5a:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c5c:	00000097          	auipc	ra,0x0
    80000c60:	fa8080e7          	jalr	-88(ra) # 80000c04 <push_off>
  if(holding(lk))
    80000c64:	8526                	mv	a0,s1
    80000c66:	00000097          	auipc	ra,0x0
    80000c6a:	f70080e7          	jalr	-144(ra) # 80000bd6 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c6e:	4705                	li	a4,1
  if(holding(lk))
    80000c70:	e115                	bnez	a0,80000c94 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c72:	87ba                	mv	a5,a4
    80000c74:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c78:	2781                	sext.w	a5,a5
    80000c7a:	ffe5                	bnez	a5,80000c72 <acquire+0x22>
  __sync_synchronize();
    80000c7c:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c80:	00001097          	auipc	ra,0x1
    80000c84:	d80080e7          	jalr	-640(ra) # 80001a00 <mycpu>
    80000c88:	e888                	sd	a0,16(s1)
}
    80000c8a:	60e2                	ld	ra,24(sp)
    80000c8c:	6442                	ld	s0,16(sp)
    80000c8e:	64a2                	ld	s1,8(sp)
    80000c90:	6105                	addi	sp,sp,32
    80000c92:	8082                	ret
    panic("acquire");
    80000c94:	00007517          	auipc	a0,0x7
    80000c98:	3dc50513          	addi	a0,a0,988 # 80008070 <digits+0x30>
    80000c9c:	00000097          	auipc	ra,0x0
    80000ca0:	8a6080e7          	jalr	-1882(ra) # 80000542 <panic>

0000000080000ca4 <pop_off>:

void
pop_off(void)
{
    80000ca4:	1141                	addi	sp,sp,-16
    80000ca6:	e406                	sd	ra,8(sp)
    80000ca8:	e022                	sd	s0,0(sp)
    80000caa:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cac:	00001097          	auipc	ra,0x1
    80000cb0:	d54080e7          	jalr	-684(ra) # 80001a00 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cb4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cb8:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cba:	e78d                	bnez	a5,80000ce4 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cbc:	5d3c                	lw	a5,120(a0)
    80000cbe:	02f05b63          	blez	a5,80000cf4 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000cc2:	37fd                	addiw	a5,a5,-1
    80000cc4:	0007871b          	sext.w	a4,a5
    80000cc8:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cca:	eb09                	bnez	a4,80000cdc <pop_off+0x38>
    80000ccc:	5d7c                	lw	a5,124(a0)
    80000cce:	c799                	beqz	a5,80000cdc <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cd0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cd4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cd8:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cdc:	60a2                	ld	ra,8(sp)
    80000cde:	6402                	ld	s0,0(sp)
    80000ce0:	0141                	addi	sp,sp,16
    80000ce2:	8082                	ret
    panic("pop_off - interruptible");
    80000ce4:	00007517          	auipc	a0,0x7
    80000ce8:	39450513          	addi	a0,a0,916 # 80008078 <digits+0x38>
    80000cec:	00000097          	auipc	ra,0x0
    80000cf0:	856080e7          	jalr	-1962(ra) # 80000542 <panic>
    panic("pop_off");
    80000cf4:	00007517          	auipc	a0,0x7
    80000cf8:	39c50513          	addi	a0,a0,924 # 80008090 <digits+0x50>
    80000cfc:	00000097          	auipc	ra,0x0
    80000d00:	846080e7          	jalr	-1978(ra) # 80000542 <panic>

0000000080000d04 <release>:
{
    80000d04:	1101                	addi	sp,sp,-32
    80000d06:	ec06                	sd	ra,24(sp)
    80000d08:	e822                	sd	s0,16(sp)
    80000d0a:	e426                	sd	s1,8(sp)
    80000d0c:	1000                	addi	s0,sp,32
    80000d0e:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d10:	00000097          	auipc	ra,0x0
    80000d14:	ec6080e7          	jalr	-314(ra) # 80000bd6 <holding>
    80000d18:	c115                	beqz	a0,80000d3c <release+0x38>
  lk->cpu = 0;
    80000d1a:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d1e:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d22:	0f50000f          	fence	iorw,ow
    80000d26:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d2a:	00000097          	auipc	ra,0x0
    80000d2e:	f7a080e7          	jalr	-134(ra) # 80000ca4 <pop_off>
}
    80000d32:	60e2                	ld	ra,24(sp)
    80000d34:	6442                	ld	s0,16(sp)
    80000d36:	64a2                	ld	s1,8(sp)
    80000d38:	6105                	addi	sp,sp,32
    80000d3a:	8082                	ret
    panic("release");
    80000d3c:	00007517          	auipc	a0,0x7
    80000d40:	35c50513          	addi	a0,a0,860 # 80008098 <digits+0x58>
    80000d44:	fffff097          	auipc	ra,0xfffff
    80000d48:	7fe080e7          	jalr	2046(ra) # 80000542 <panic>

0000000080000d4c <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d4c:	1141                	addi	sp,sp,-16
    80000d4e:	e422                	sd	s0,8(sp)
    80000d50:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d52:	ca19                	beqz	a2,80000d68 <memset+0x1c>
    80000d54:	87aa                	mv	a5,a0
    80000d56:	1602                	slli	a2,a2,0x20
    80000d58:	9201                	srli	a2,a2,0x20
    80000d5a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d5e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d62:	0785                	addi	a5,a5,1
    80000d64:	fee79de3          	bne	a5,a4,80000d5e <memset+0x12>
  }
  return dst;
}
    80000d68:	6422                	ld	s0,8(sp)
    80000d6a:	0141                	addi	sp,sp,16
    80000d6c:	8082                	ret

0000000080000d6e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d6e:	1141                	addi	sp,sp,-16
    80000d70:	e422                	sd	s0,8(sp)
    80000d72:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d74:	ca05                	beqz	a2,80000da4 <memcmp+0x36>
    80000d76:	fff6069b          	addiw	a3,a2,-1
    80000d7a:	1682                	slli	a3,a3,0x20
    80000d7c:	9281                	srli	a3,a3,0x20
    80000d7e:	0685                	addi	a3,a3,1
    80000d80:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d82:	00054783          	lbu	a5,0(a0)
    80000d86:	0005c703          	lbu	a4,0(a1)
    80000d8a:	00e79863          	bne	a5,a4,80000d9a <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d8e:	0505                	addi	a0,a0,1
    80000d90:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d92:	fed518e3          	bne	a0,a3,80000d82 <memcmp+0x14>
  }

  return 0;
    80000d96:	4501                	li	a0,0
    80000d98:	a019                	j	80000d9e <memcmp+0x30>
      return *s1 - *s2;
    80000d9a:	40e7853b          	subw	a0,a5,a4
}
    80000d9e:	6422                	ld	s0,8(sp)
    80000da0:	0141                	addi	sp,sp,16
    80000da2:	8082                	ret
  return 0;
    80000da4:	4501                	li	a0,0
    80000da6:	bfe5                	j	80000d9e <memcmp+0x30>

0000000080000da8 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000da8:	1141                	addi	sp,sp,-16
    80000daa:	e422                	sd	s0,8(sp)
    80000dac:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dae:	02a5e563          	bltu	a1,a0,80000dd8 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000db2:	fff6069b          	addiw	a3,a2,-1
    80000db6:	ce11                	beqz	a2,80000dd2 <memmove+0x2a>
    80000db8:	1682                	slli	a3,a3,0x20
    80000dba:	9281                	srli	a3,a3,0x20
    80000dbc:	0685                	addi	a3,a3,1
    80000dbe:	96ae                	add	a3,a3,a1
    80000dc0:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000dc2:	0585                	addi	a1,a1,1
    80000dc4:	0785                	addi	a5,a5,1
    80000dc6:	fff5c703          	lbu	a4,-1(a1)
    80000dca:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000dce:	fed59ae3          	bne	a1,a3,80000dc2 <memmove+0x1a>

  return dst;
}
    80000dd2:	6422                	ld	s0,8(sp)
    80000dd4:	0141                	addi	sp,sp,16
    80000dd6:	8082                	ret
  if(s < d && s + n > d){
    80000dd8:	02061713          	slli	a4,a2,0x20
    80000ddc:	9301                	srli	a4,a4,0x20
    80000dde:	00e587b3          	add	a5,a1,a4
    80000de2:	fcf578e3          	bgeu	a0,a5,80000db2 <memmove+0xa>
    d += n;
    80000de6:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000de8:	fff6069b          	addiw	a3,a2,-1
    80000dec:	d27d                	beqz	a2,80000dd2 <memmove+0x2a>
    80000dee:	02069613          	slli	a2,a3,0x20
    80000df2:	9201                	srli	a2,a2,0x20
    80000df4:	fff64613          	not	a2,a2
    80000df8:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000dfa:	17fd                	addi	a5,a5,-1
    80000dfc:	177d                	addi	a4,a4,-1
    80000dfe:	0007c683          	lbu	a3,0(a5)
    80000e02:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000e06:	fef61ae3          	bne	a2,a5,80000dfa <memmove+0x52>
    80000e0a:	b7e1                	j	80000dd2 <memmove+0x2a>

0000000080000e0c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e0c:	1141                	addi	sp,sp,-16
    80000e0e:	e406                	sd	ra,8(sp)
    80000e10:	e022                	sd	s0,0(sp)
    80000e12:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e14:	00000097          	auipc	ra,0x0
    80000e18:	f94080e7          	jalr	-108(ra) # 80000da8 <memmove>
}
    80000e1c:	60a2                	ld	ra,8(sp)
    80000e1e:	6402                	ld	s0,0(sp)
    80000e20:	0141                	addi	sp,sp,16
    80000e22:	8082                	ret

0000000080000e24 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e24:	1141                	addi	sp,sp,-16
    80000e26:	e422                	sd	s0,8(sp)
    80000e28:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e2a:	ce11                	beqz	a2,80000e46 <strncmp+0x22>
    80000e2c:	00054783          	lbu	a5,0(a0)
    80000e30:	cf89                	beqz	a5,80000e4a <strncmp+0x26>
    80000e32:	0005c703          	lbu	a4,0(a1)
    80000e36:	00f71a63          	bne	a4,a5,80000e4a <strncmp+0x26>
    n--, p++, q++;
    80000e3a:	367d                	addiw	a2,a2,-1
    80000e3c:	0505                	addi	a0,a0,1
    80000e3e:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e40:	f675                	bnez	a2,80000e2c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e42:	4501                	li	a0,0
    80000e44:	a809                	j	80000e56 <strncmp+0x32>
    80000e46:	4501                	li	a0,0
    80000e48:	a039                	j	80000e56 <strncmp+0x32>
  if(n == 0)
    80000e4a:	ca09                	beqz	a2,80000e5c <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e4c:	00054503          	lbu	a0,0(a0)
    80000e50:	0005c783          	lbu	a5,0(a1)
    80000e54:	9d1d                	subw	a0,a0,a5
}
    80000e56:	6422                	ld	s0,8(sp)
    80000e58:	0141                	addi	sp,sp,16
    80000e5a:	8082                	ret
    return 0;
    80000e5c:	4501                	li	a0,0
    80000e5e:	bfe5                	j	80000e56 <strncmp+0x32>

0000000080000e60 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e60:	1141                	addi	sp,sp,-16
    80000e62:	e422                	sd	s0,8(sp)
    80000e64:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e66:	872a                	mv	a4,a0
    80000e68:	8832                	mv	a6,a2
    80000e6a:	367d                	addiw	a2,a2,-1
    80000e6c:	01005963          	blez	a6,80000e7e <strncpy+0x1e>
    80000e70:	0705                	addi	a4,a4,1
    80000e72:	0005c783          	lbu	a5,0(a1)
    80000e76:	fef70fa3          	sb	a5,-1(a4)
    80000e7a:	0585                	addi	a1,a1,1
    80000e7c:	f7f5                	bnez	a5,80000e68 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e7e:	86ba                	mv	a3,a4
    80000e80:	00c05c63          	blez	a2,80000e98 <strncpy+0x38>
    *s++ = 0;
    80000e84:	0685                	addi	a3,a3,1
    80000e86:	fe068fa3          	sb	zero,-1(a3) # fff <_entry-0x7ffff001>
  while(n-- > 0)
    80000e8a:	fff6c793          	not	a5,a3
    80000e8e:	9fb9                	addw	a5,a5,a4
    80000e90:	010787bb          	addw	a5,a5,a6
    80000e94:	fef048e3          	bgtz	a5,80000e84 <strncpy+0x24>
  return os;
}
    80000e98:	6422                	ld	s0,8(sp)
    80000e9a:	0141                	addi	sp,sp,16
    80000e9c:	8082                	ret

0000000080000e9e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e9e:	1141                	addi	sp,sp,-16
    80000ea0:	e422                	sd	s0,8(sp)
    80000ea2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ea4:	02c05363          	blez	a2,80000eca <safestrcpy+0x2c>
    80000ea8:	fff6069b          	addiw	a3,a2,-1
    80000eac:	1682                	slli	a3,a3,0x20
    80000eae:	9281                	srli	a3,a3,0x20
    80000eb0:	96ae                	add	a3,a3,a1
    80000eb2:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000eb4:	00d58963          	beq	a1,a3,80000ec6 <safestrcpy+0x28>
    80000eb8:	0585                	addi	a1,a1,1
    80000eba:	0785                	addi	a5,a5,1
    80000ebc:	fff5c703          	lbu	a4,-1(a1)
    80000ec0:	fee78fa3          	sb	a4,-1(a5)
    80000ec4:	fb65                	bnez	a4,80000eb4 <safestrcpy+0x16>
    ;
  *s = 0;
    80000ec6:	00078023          	sb	zero,0(a5)
  return os;
}
    80000eca:	6422                	ld	s0,8(sp)
    80000ecc:	0141                	addi	sp,sp,16
    80000ece:	8082                	ret

0000000080000ed0 <strlen>:

int
strlen(const char *s)
{
    80000ed0:	1141                	addi	sp,sp,-16
    80000ed2:	e422                	sd	s0,8(sp)
    80000ed4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000ed6:	00054783          	lbu	a5,0(a0)
    80000eda:	cf91                	beqz	a5,80000ef6 <strlen+0x26>
    80000edc:	0505                	addi	a0,a0,1
    80000ede:	87aa                	mv	a5,a0
    80000ee0:	4685                	li	a3,1
    80000ee2:	9e89                	subw	a3,a3,a0
    80000ee4:	00f6853b          	addw	a0,a3,a5
    80000ee8:	0785                	addi	a5,a5,1
    80000eea:	fff7c703          	lbu	a4,-1(a5)
    80000eee:	fb7d                	bnez	a4,80000ee4 <strlen+0x14>
    ;
  return n;
}
    80000ef0:	6422                	ld	s0,8(sp)
    80000ef2:	0141                	addi	sp,sp,16
    80000ef4:	8082                	ret
  for(n = 0; s[n]; n++)
    80000ef6:	4501                	li	a0,0
    80000ef8:	bfe5                	j	80000ef0 <strlen+0x20>

0000000080000efa <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000efa:	1141                	addi	sp,sp,-16
    80000efc:	e406                	sd	ra,8(sp)
    80000efe:	e022                	sd	s0,0(sp)
    80000f00:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f02:	00001097          	auipc	ra,0x1
    80000f06:	aee080e7          	jalr	-1298(ra) # 800019f0 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f0a:	00008717          	auipc	a4,0x8
    80000f0e:	10270713          	addi	a4,a4,258 # 8000900c <started>
  if(cpuid() == 0){
    80000f12:	c139                	beqz	a0,80000f58 <main+0x5e>
    while(started == 0)
    80000f14:	431c                	lw	a5,0(a4)
    80000f16:	2781                	sext.w	a5,a5
    80000f18:	dff5                	beqz	a5,80000f14 <main+0x1a>
      ;
    __sync_synchronize();
    80000f1a:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f1e:	00001097          	auipc	ra,0x1
    80000f22:	ad2080e7          	jalr	-1326(ra) # 800019f0 <cpuid>
    80000f26:	85aa                	mv	a1,a0
    80000f28:	00007517          	auipc	a0,0x7
    80000f2c:	19050513          	addi	a0,a0,400 # 800080b8 <digits+0x78>
    80000f30:	fffff097          	auipc	ra,0xfffff
    80000f34:	65c080e7          	jalr	1628(ra) # 8000058c <printf>
    kvminithart();    // turn on paging
    80000f38:	00000097          	auipc	ra,0x0
    80000f3c:	0d8080e7          	jalr	216(ra) # 80001010 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f40:	00001097          	auipc	ra,0x1
    80000f44:	764080e7          	jalr	1892(ra) # 800026a4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	e08080e7          	jalr	-504(ra) # 80005d50 <plicinithart>
  }

  scheduler();        
    80000f50:	00001097          	auipc	ra,0x1
    80000f54:	000080e7          	jalr	ra # 80001f50 <scheduler>
    consoleinit();
    80000f58:	fffff097          	auipc	ra,0xfffff
    80000f5c:	4fc080e7          	jalr	1276(ra) # 80000454 <consoleinit>
    printfinit();
    80000f60:	00000097          	auipc	ra,0x0
    80000f64:	80c080e7          	jalr	-2036(ra) # 8000076c <printfinit>
    printf("\n");
    80000f68:	00007517          	auipc	a0,0x7
    80000f6c:	16050513          	addi	a0,a0,352 # 800080c8 <digits+0x88>
    80000f70:	fffff097          	auipc	ra,0xfffff
    80000f74:	61c080e7          	jalr	1564(ra) # 8000058c <printf>
    printf("xv6 kernel is booting\n");
    80000f78:	00007517          	auipc	a0,0x7
    80000f7c:	12850513          	addi	a0,a0,296 # 800080a0 <digits+0x60>
    80000f80:	fffff097          	auipc	ra,0xfffff
    80000f84:	60c080e7          	jalr	1548(ra) # 8000058c <printf>
    printf("\n");
    80000f88:	00007517          	auipc	a0,0x7
    80000f8c:	14050513          	addi	a0,a0,320 # 800080c8 <digits+0x88>
    80000f90:	fffff097          	auipc	ra,0xfffff
    80000f94:	5fc080e7          	jalr	1532(ra) # 8000058c <printf>
    kinit();         // physical page allocator
    80000f98:	00000097          	auipc	ra,0x0
    80000f9c:	b3a080e7          	jalr	-1222(ra) # 80000ad2 <kinit>
    kvminit();       // create kernel page table
    80000fa0:	00000097          	auipc	ra,0x0
    80000fa4:	2a0080e7          	jalr	672(ra) # 80001240 <kvminit>
    kvminithart();   // turn on paging
    80000fa8:	00000097          	auipc	ra,0x0
    80000fac:	068080e7          	jalr	104(ra) # 80001010 <kvminithart>
    procinit();      // process table
    80000fb0:	00001097          	auipc	ra,0x1
    80000fb4:	970080e7          	jalr	-1680(ra) # 80001920 <procinit>
    trapinit();      // trap vectors
    80000fb8:	00001097          	auipc	ra,0x1
    80000fbc:	6c4080e7          	jalr	1732(ra) # 8000267c <trapinit>
    trapinithart();  // install kernel trap vector
    80000fc0:	00001097          	auipc	ra,0x1
    80000fc4:	6e4080e7          	jalr	1764(ra) # 800026a4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fc8:	00005097          	auipc	ra,0x5
    80000fcc:	d72080e7          	jalr	-654(ra) # 80005d3a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fd0:	00005097          	auipc	ra,0x5
    80000fd4:	d80080e7          	jalr	-640(ra) # 80005d50 <plicinithart>
    binit();         // buffer cache
    80000fd8:	00002097          	auipc	ra,0x2
    80000fdc:	f2a080e7          	jalr	-214(ra) # 80002f02 <binit>
    iinit();         // inode cache
    80000fe0:	00002097          	auipc	ra,0x2
    80000fe4:	5bc080e7          	jalr	1468(ra) # 8000359c <iinit>
    fileinit();      // file table
    80000fe8:	00003097          	auipc	ra,0x3
    80000fec:	55a080e7          	jalr	1370(ra) # 80004542 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ff0:	00005097          	auipc	ra,0x5
    80000ff4:	e68080e7          	jalr	-408(ra) # 80005e58 <virtio_disk_init>
    userinit();      // first user process
    80000ff8:	00001097          	auipc	ra,0x1
    80000ffc:	cee080e7          	jalr	-786(ra) # 80001ce6 <userinit>
    __sync_synchronize();
    80001000:	0ff0000f          	fence
    started = 1;
    80001004:	4785                	li	a5,1
    80001006:	00008717          	auipc	a4,0x8
    8000100a:	00f72323          	sw	a5,6(a4) # 8000900c <started>
    8000100e:	b789                	j	80000f50 <main+0x56>

0000000080001010 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001010:	1141                	addi	sp,sp,-16
    80001012:	e422                	sd	s0,8(sp)
    80001014:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001016:	00008797          	auipc	a5,0x8
    8000101a:	ffa7b783          	ld	a5,-6(a5) # 80009010 <kernel_pagetable>
    8000101e:	83b1                	srli	a5,a5,0xc
    80001020:	577d                	li	a4,-1
    80001022:	177e                	slli	a4,a4,0x3f
    80001024:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001026:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000102a:	12000073          	sfence.vma
  sfence_vma();
}
    8000102e:	6422                	ld	s0,8(sp)
    80001030:	0141                	addi	sp,sp,16
    80001032:	8082                	ret

0000000080001034 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001034:	7139                	addi	sp,sp,-64
    80001036:	fc06                	sd	ra,56(sp)
    80001038:	f822                	sd	s0,48(sp)
    8000103a:	f426                	sd	s1,40(sp)
    8000103c:	f04a                	sd	s2,32(sp)
    8000103e:	ec4e                	sd	s3,24(sp)
    80001040:	e852                	sd	s4,16(sp)
    80001042:	e456                	sd	s5,8(sp)
    80001044:	e05a                	sd	s6,0(sp)
    80001046:	0080                	addi	s0,sp,64
    80001048:	84aa                	mv	s1,a0
    8000104a:	89ae                	mv	s3,a1
    8000104c:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000104e:	57fd                	li	a5,-1
    80001050:	83e9                	srli	a5,a5,0x1a
    80001052:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001054:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001056:	04b7f263          	bgeu	a5,a1,8000109a <walk+0x66>
    panic("walk");
    8000105a:	00007517          	auipc	a0,0x7
    8000105e:	07650513          	addi	a0,a0,118 # 800080d0 <digits+0x90>
    80001062:	fffff097          	auipc	ra,0xfffff
    80001066:	4e0080e7          	jalr	1248(ra) # 80000542 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000106a:	060a8663          	beqz	s5,800010d6 <walk+0xa2>
    8000106e:	00000097          	auipc	ra,0x0
    80001072:	aa0080e7          	jalr	-1376(ra) # 80000b0e <kalloc>
    80001076:	84aa                	mv	s1,a0
    80001078:	c529                	beqz	a0,800010c2 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000107a:	6605                	lui	a2,0x1
    8000107c:	4581                	li	a1,0
    8000107e:	00000097          	auipc	ra,0x0
    80001082:	cce080e7          	jalr	-818(ra) # 80000d4c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001086:	00c4d793          	srli	a5,s1,0xc
    8000108a:	07aa                	slli	a5,a5,0xa
    8000108c:	0017e793          	ori	a5,a5,1
    80001090:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001094:	3a5d                	addiw	s4,s4,-9
    80001096:	036a0063          	beq	s4,s6,800010b6 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000109a:	0149d933          	srl	s2,s3,s4
    8000109e:	1ff97913          	andi	s2,s2,511
    800010a2:	090e                	slli	s2,s2,0x3
    800010a4:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010a6:	00093483          	ld	s1,0(s2)
    800010aa:	0014f793          	andi	a5,s1,1
    800010ae:	dfd5                	beqz	a5,8000106a <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010b0:	80a9                	srli	s1,s1,0xa
    800010b2:	04b2                	slli	s1,s1,0xc
    800010b4:	b7c5                	j	80001094 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010b6:	00c9d513          	srli	a0,s3,0xc
    800010ba:	1ff57513          	andi	a0,a0,511
    800010be:	050e                	slli	a0,a0,0x3
    800010c0:	9526                	add	a0,a0,s1
}
    800010c2:	70e2                	ld	ra,56(sp)
    800010c4:	7442                	ld	s0,48(sp)
    800010c6:	74a2                	ld	s1,40(sp)
    800010c8:	7902                	ld	s2,32(sp)
    800010ca:	69e2                	ld	s3,24(sp)
    800010cc:	6a42                	ld	s4,16(sp)
    800010ce:	6aa2                	ld	s5,8(sp)
    800010d0:	6b02                	ld	s6,0(sp)
    800010d2:	6121                	addi	sp,sp,64
    800010d4:	8082                	ret
        return 0;
    800010d6:	4501                	li	a0,0
    800010d8:	b7ed                	j	800010c2 <walk+0x8e>

00000000800010da <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010da:	57fd                	li	a5,-1
    800010dc:	83e9                	srli	a5,a5,0x1a
    800010de:	00b7f463          	bgeu	a5,a1,800010e6 <walkaddr+0xc>
    return 0;
    800010e2:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010e4:	8082                	ret
{
    800010e6:	1141                	addi	sp,sp,-16
    800010e8:	e406                	sd	ra,8(sp)
    800010ea:	e022                	sd	s0,0(sp)
    800010ec:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010ee:	4601                	li	a2,0
    800010f0:	00000097          	auipc	ra,0x0
    800010f4:	f44080e7          	jalr	-188(ra) # 80001034 <walk>
  if(pte == 0)
    800010f8:	c105                	beqz	a0,80001118 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    800010fa:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010fc:	0117f693          	andi	a3,a5,17
    80001100:	4745                	li	a4,17
    return 0;
    80001102:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001104:	00e68663          	beq	a3,a4,80001110 <walkaddr+0x36>
}
    80001108:	60a2                	ld	ra,8(sp)
    8000110a:	6402                	ld	s0,0(sp)
    8000110c:	0141                	addi	sp,sp,16
    8000110e:	8082                	ret
  pa = PTE2PA(*pte);
    80001110:	00a7d513          	srli	a0,a5,0xa
    80001114:	0532                	slli	a0,a0,0xc
  return pa;
    80001116:	bfcd                	j	80001108 <walkaddr+0x2e>
    return 0;
    80001118:	4501                	li	a0,0
    8000111a:	b7fd                	j	80001108 <walkaddr+0x2e>

000000008000111c <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    8000111c:	1101                	addi	sp,sp,-32
    8000111e:	ec06                	sd	ra,24(sp)
    80001120:	e822                	sd	s0,16(sp)
    80001122:	e426                	sd	s1,8(sp)
    80001124:	1000                	addi	s0,sp,32
    80001126:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80001128:	1552                	slli	a0,a0,0x34
    8000112a:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    8000112e:	4601                	li	a2,0
    80001130:	00008517          	auipc	a0,0x8
    80001134:	ee053503          	ld	a0,-288(a0) # 80009010 <kernel_pagetable>
    80001138:	00000097          	auipc	ra,0x0
    8000113c:	efc080e7          	jalr	-260(ra) # 80001034 <walk>
  if(pte == 0)
    80001140:	cd09                	beqz	a0,8000115a <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    80001142:	6108                	ld	a0,0(a0)
    80001144:	00157793          	andi	a5,a0,1
    80001148:	c38d                	beqz	a5,8000116a <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    8000114a:	8129                	srli	a0,a0,0xa
    8000114c:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    8000114e:	9526                	add	a0,a0,s1
    80001150:	60e2                	ld	ra,24(sp)
    80001152:	6442                	ld	s0,16(sp)
    80001154:	64a2                	ld	s1,8(sp)
    80001156:	6105                	addi	sp,sp,32
    80001158:	8082                	ret
    panic("kvmpa");
    8000115a:	00007517          	auipc	a0,0x7
    8000115e:	f7e50513          	addi	a0,a0,-130 # 800080d8 <digits+0x98>
    80001162:	fffff097          	auipc	ra,0xfffff
    80001166:	3e0080e7          	jalr	992(ra) # 80000542 <panic>
    panic("kvmpa");
    8000116a:	00007517          	auipc	a0,0x7
    8000116e:	f6e50513          	addi	a0,a0,-146 # 800080d8 <digits+0x98>
    80001172:	fffff097          	auipc	ra,0xfffff
    80001176:	3d0080e7          	jalr	976(ra) # 80000542 <panic>

000000008000117a <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000117a:	715d                	addi	sp,sp,-80
    8000117c:	e486                	sd	ra,72(sp)
    8000117e:	e0a2                	sd	s0,64(sp)
    80001180:	fc26                	sd	s1,56(sp)
    80001182:	f84a                	sd	s2,48(sp)
    80001184:	f44e                	sd	s3,40(sp)
    80001186:	f052                	sd	s4,32(sp)
    80001188:	ec56                	sd	s5,24(sp)
    8000118a:	e85a                	sd	s6,16(sp)
    8000118c:	e45e                	sd	s7,8(sp)
    8000118e:	0880                	addi	s0,sp,80
    80001190:	8aaa                	mv	s5,a0
    80001192:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    80001194:	777d                	lui	a4,0xfffff
    80001196:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    8000119a:	167d                	addi	a2,a2,-1
    8000119c:	00b609b3          	add	s3,a2,a1
    800011a0:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800011a4:	893e                	mv	s2,a5
    800011a6:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800011aa:	6b85                	lui	s7,0x1
    800011ac:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800011b0:	4605                	li	a2,1
    800011b2:	85ca                	mv	a1,s2
    800011b4:	8556                	mv	a0,s5
    800011b6:	00000097          	auipc	ra,0x0
    800011ba:	e7e080e7          	jalr	-386(ra) # 80001034 <walk>
    800011be:	c51d                	beqz	a0,800011ec <mappages+0x72>
    if(*pte & PTE_V)
    800011c0:	611c                	ld	a5,0(a0)
    800011c2:	8b85                	andi	a5,a5,1
    800011c4:	ef81                	bnez	a5,800011dc <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011c6:	80b1                	srli	s1,s1,0xc
    800011c8:	04aa                	slli	s1,s1,0xa
    800011ca:	0164e4b3          	or	s1,s1,s6
    800011ce:	0014e493          	ori	s1,s1,1
    800011d2:	e104                	sd	s1,0(a0)
    if(a == last)
    800011d4:	03390863          	beq	s2,s3,80001204 <mappages+0x8a>
    a += PGSIZE;
    800011d8:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800011da:	bfc9                	j	800011ac <mappages+0x32>
      panic("remap");
    800011dc:	00007517          	auipc	a0,0x7
    800011e0:	f0450513          	addi	a0,a0,-252 # 800080e0 <digits+0xa0>
    800011e4:	fffff097          	auipc	ra,0xfffff
    800011e8:	35e080e7          	jalr	862(ra) # 80000542 <panic>
      return -1;
    800011ec:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011ee:	60a6                	ld	ra,72(sp)
    800011f0:	6406                	ld	s0,64(sp)
    800011f2:	74e2                	ld	s1,56(sp)
    800011f4:	7942                	ld	s2,48(sp)
    800011f6:	79a2                	ld	s3,40(sp)
    800011f8:	7a02                	ld	s4,32(sp)
    800011fa:	6ae2                	ld	s5,24(sp)
    800011fc:	6b42                	ld	s6,16(sp)
    800011fe:	6ba2                	ld	s7,8(sp)
    80001200:	6161                	addi	sp,sp,80
    80001202:	8082                	ret
  return 0;
    80001204:	4501                	li	a0,0
    80001206:	b7e5                	j	800011ee <mappages+0x74>

0000000080001208 <kvmmap>:
{
    80001208:	1141                	addi	sp,sp,-16
    8000120a:	e406                	sd	ra,8(sp)
    8000120c:	e022                	sd	s0,0(sp)
    8000120e:	0800                	addi	s0,sp,16
    80001210:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    80001212:	86ae                	mv	a3,a1
    80001214:	85aa                	mv	a1,a0
    80001216:	00008517          	auipc	a0,0x8
    8000121a:	dfa53503          	ld	a0,-518(a0) # 80009010 <kernel_pagetable>
    8000121e:	00000097          	auipc	ra,0x0
    80001222:	f5c080e7          	jalr	-164(ra) # 8000117a <mappages>
    80001226:	e509                	bnez	a0,80001230 <kvmmap+0x28>
}
    80001228:	60a2                	ld	ra,8(sp)
    8000122a:	6402                	ld	s0,0(sp)
    8000122c:	0141                	addi	sp,sp,16
    8000122e:	8082                	ret
    panic("kvmmap");
    80001230:	00007517          	auipc	a0,0x7
    80001234:	eb850513          	addi	a0,a0,-328 # 800080e8 <digits+0xa8>
    80001238:	fffff097          	auipc	ra,0xfffff
    8000123c:	30a080e7          	jalr	778(ra) # 80000542 <panic>

0000000080001240 <kvminit>:
{
    80001240:	1101                	addi	sp,sp,-32
    80001242:	ec06                	sd	ra,24(sp)
    80001244:	e822                	sd	s0,16(sp)
    80001246:	e426                	sd	s1,8(sp)
    80001248:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    8000124a:	00000097          	auipc	ra,0x0
    8000124e:	8c4080e7          	jalr	-1852(ra) # 80000b0e <kalloc>
    80001252:	00008797          	auipc	a5,0x8
    80001256:	daa7bf23          	sd	a0,-578(a5) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    8000125a:	6605                	lui	a2,0x1
    8000125c:	4581                	li	a1,0
    8000125e:	00000097          	auipc	ra,0x0
    80001262:	aee080e7          	jalr	-1298(ra) # 80000d4c <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001266:	4699                	li	a3,6
    80001268:	6605                	lui	a2,0x1
    8000126a:	100005b7          	lui	a1,0x10000
    8000126e:	10000537          	lui	a0,0x10000
    80001272:	00000097          	auipc	ra,0x0
    80001276:	f96080e7          	jalr	-106(ra) # 80001208 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000127a:	4699                	li	a3,6
    8000127c:	6605                	lui	a2,0x1
    8000127e:	100015b7          	lui	a1,0x10001
    80001282:	10001537          	lui	a0,0x10001
    80001286:	00000097          	auipc	ra,0x0
    8000128a:	f82080e7          	jalr	-126(ra) # 80001208 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    8000128e:	4699                	li	a3,6
    80001290:	6641                	lui	a2,0x10
    80001292:	020005b7          	lui	a1,0x2000
    80001296:	02000537          	lui	a0,0x2000
    8000129a:	00000097          	auipc	ra,0x0
    8000129e:	f6e080e7          	jalr	-146(ra) # 80001208 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012a2:	4699                	li	a3,6
    800012a4:	00400637          	lui	a2,0x400
    800012a8:	0c0005b7          	lui	a1,0xc000
    800012ac:	0c000537          	lui	a0,0xc000
    800012b0:	00000097          	auipc	ra,0x0
    800012b4:	f58080e7          	jalr	-168(ra) # 80001208 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800012b8:	00007497          	auipc	s1,0x7
    800012bc:	d4848493          	addi	s1,s1,-696 # 80008000 <etext>
    800012c0:	46a9                	li	a3,10
    800012c2:	80007617          	auipc	a2,0x80007
    800012c6:	d3e60613          	addi	a2,a2,-706 # 8000 <_entry-0x7fff8000>
    800012ca:	4585                	li	a1,1
    800012cc:	05fe                	slli	a1,a1,0x1f
    800012ce:	852e                	mv	a0,a1
    800012d0:	00000097          	auipc	ra,0x0
    800012d4:	f38080e7          	jalr	-200(ra) # 80001208 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800012d8:	4699                	li	a3,6
    800012da:	4645                	li	a2,17
    800012dc:	066e                	slli	a2,a2,0x1b
    800012de:	8e05                	sub	a2,a2,s1
    800012e0:	85a6                	mv	a1,s1
    800012e2:	8526                	mv	a0,s1
    800012e4:	00000097          	auipc	ra,0x0
    800012e8:	f24080e7          	jalr	-220(ra) # 80001208 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012ec:	46a9                	li	a3,10
    800012ee:	6605                	lui	a2,0x1
    800012f0:	00006597          	auipc	a1,0x6
    800012f4:	d1058593          	addi	a1,a1,-752 # 80007000 <_trampoline>
    800012f8:	04000537          	lui	a0,0x4000
    800012fc:	157d                	addi	a0,a0,-1
    800012fe:	0532                	slli	a0,a0,0xc
    80001300:	00000097          	auipc	ra,0x0
    80001304:	f08080e7          	jalr	-248(ra) # 80001208 <kvmmap>
}
    80001308:	60e2                	ld	ra,24(sp)
    8000130a:	6442                	ld	s0,16(sp)
    8000130c:	64a2                	ld	s1,8(sp)
    8000130e:	6105                	addi	sp,sp,32
    80001310:	8082                	ret

0000000080001312 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001312:	715d                	addi	sp,sp,-80
    80001314:	e486                	sd	ra,72(sp)
    80001316:	e0a2                	sd	s0,64(sp)
    80001318:	fc26                	sd	s1,56(sp)
    8000131a:	f84a                	sd	s2,48(sp)
    8000131c:	f44e                	sd	s3,40(sp)
    8000131e:	f052                	sd	s4,32(sp)
    80001320:	ec56                	sd	s5,24(sp)
    80001322:	e85a                	sd	s6,16(sp)
    80001324:	e45e                	sd	s7,8(sp)
    80001326:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001328:	03459793          	slli	a5,a1,0x34
    8000132c:	e795                	bnez	a5,80001358 <uvmunmap+0x46>
    8000132e:	8a2a                	mv	s4,a0
    80001330:	892e                	mv	s2,a1
    80001332:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001334:	0632                	slli	a2,a2,0xc
    80001336:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000133a:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000133c:	6b05                	lui	s6,0x1
    8000133e:	0735e263          	bltu	a1,s3,800013a2 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001342:	60a6                	ld	ra,72(sp)
    80001344:	6406                	ld	s0,64(sp)
    80001346:	74e2                	ld	s1,56(sp)
    80001348:	7942                	ld	s2,48(sp)
    8000134a:	79a2                	ld	s3,40(sp)
    8000134c:	7a02                	ld	s4,32(sp)
    8000134e:	6ae2                	ld	s5,24(sp)
    80001350:	6b42                	ld	s6,16(sp)
    80001352:	6ba2                	ld	s7,8(sp)
    80001354:	6161                	addi	sp,sp,80
    80001356:	8082                	ret
    panic("uvmunmap: not aligned");
    80001358:	00007517          	auipc	a0,0x7
    8000135c:	d9850513          	addi	a0,a0,-616 # 800080f0 <digits+0xb0>
    80001360:	fffff097          	auipc	ra,0xfffff
    80001364:	1e2080e7          	jalr	482(ra) # 80000542 <panic>
      panic("uvmunmap: walk");
    80001368:	00007517          	auipc	a0,0x7
    8000136c:	da050513          	addi	a0,a0,-608 # 80008108 <digits+0xc8>
    80001370:	fffff097          	auipc	ra,0xfffff
    80001374:	1d2080e7          	jalr	466(ra) # 80000542 <panic>
      panic("uvmunmap: not mapped");
    80001378:	00007517          	auipc	a0,0x7
    8000137c:	da050513          	addi	a0,a0,-608 # 80008118 <digits+0xd8>
    80001380:	fffff097          	auipc	ra,0xfffff
    80001384:	1c2080e7          	jalr	450(ra) # 80000542 <panic>
      panic("uvmunmap: not a leaf");
    80001388:	00007517          	auipc	a0,0x7
    8000138c:	da850513          	addi	a0,a0,-600 # 80008130 <digits+0xf0>
    80001390:	fffff097          	auipc	ra,0xfffff
    80001394:	1b2080e7          	jalr	434(ra) # 80000542 <panic>
    *pte = 0;
    80001398:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000139c:	995a                	add	s2,s2,s6
    8000139e:	fb3972e3          	bgeu	s2,s3,80001342 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013a2:	4601                	li	a2,0
    800013a4:	85ca                	mv	a1,s2
    800013a6:	8552                	mv	a0,s4
    800013a8:	00000097          	auipc	ra,0x0
    800013ac:	c8c080e7          	jalr	-884(ra) # 80001034 <walk>
    800013b0:	84aa                	mv	s1,a0
    800013b2:	d95d                	beqz	a0,80001368 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800013b4:	6108                	ld	a0,0(a0)
    800013b6:	00157793          	andi	a5,a0,1
    800013ba:	dfdd                	beqz	a5,80001378 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013bc:	3ff57793          	andi	a5,a0,1023
    800013c0:	fd7784e3          	beq	a5,s7,80001388 <uvmunmap+0x76>
    if(do_free){
    800013c4:	fc0a8ae3          	beqz	s5,80001398 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800013c8:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800013ca:	0532                	slli	a0,a0,0xc
    800013cc:	fffff097          	auipc	ra,0xfffff
    800013d0:	646080e7          	jalr	1606(ra) # 80000a12 <kfree>
    800013d4:	b7d1                	j	80001398 <uvmunmap+0x86>

00000000800013d6 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013d6:	1101                	addi	sp,sp,-32
    800013d8:	ec06                	sd	ra,24(sp)
    800013da:	e822                	sd	s0,16(sp)
    800013dc:	e426                	sd	s1,8(sp)
    800013de:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013e0:	fffff097          	auipc	ra,0xfffff
    800013e4:	72e080e7          	jalr	1838(ra) # 80000b0e <kalloc>
    800013e8:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013ea:	c519                	beqz	a0,800013f8 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013ec:	6605                	lui	a2,0x1
    800013ee:	4581                	li	a1,0
    800013f0:	00000097          	auipc	ra,0x0
    800013f4:	95c080e7          	jalr	-1700(ra) # 80000d4c <memset>
  return pagetable;
}
    800013f8:	8526                	mv	a0,s1
    800013fa:	60e2                	ld	ra,24(sp)
    800013fc:	6442                	ld	s0,16(sp)
    800013fe:	64a2                	ld	s1,8(sp)
    80001400:	6105                	addi	sp,sp,32
    80001402:	8082                	ret

0000000080001404 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001404:	7179                	addi	sp,sp,-48
    80001406:	f406                	sd	ra,40(sp)
    80001408:	f022                	sd	s0,32(sp)
    8000140a:	ec26                	sd	s1,24(sp)
    8000140c:	e84a                	sd	s2,16(sp)
    8000140e:	e44e                	sd	s3,8(sp)
    80001410:	e052                	sd	s4,0(sp)
    80001412:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001414:	6785                	lui	a5,0x1
    80001416:	04f67863          	bgeu	a2,a5,80001466 <uvminit+0x62>
    8000141a:	8a2a                	mv	s4,a0
    8000141c:	89ae                	mv	s3,a1
    8000141e:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001420:	fffff097          	auipc	ra,0xfffff
    80001424:	6ee080e7          	jalr	1774(ra) # 80000b0e <kalloc>
    80001428:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000142a:	6605                	lui	a2,0x1
    8000142c:	4581                	li	a1,0
    8000142e:	00000097          	auipc	ra,0x0
    80001432:	91e080e7          	jalr	-1762(ra) # 80000d4c <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001436:	4779                	li	a4,30
    80001438:	86ca                	mv	a3,s2
    8000143a:	6605                	lui	a2,0x1
    8000143c:	4581                	li	a1,0
    8000143e:	8552                	mv	a0,s4
    80001440:	00000097          	auipc	ra,0x0
    80001444:	d3a080e7          	jalr	-710(ra) # 8000117a <mappages>
  memmove(mem, src, sz);
    80001448:	8626                	mv	a2,s1
    8000144a:	85ce                	mv	a1,s3
    8000144c:	854a                	mv	a0,s2
    8000144e:	00000097          	auipc	ra,0x0
    80001452:	95a080e7          	jalr	-1702(ra) # 80000da8 <memmove>
}
    80001456:	70a2                	ld	ra,40(sp)
    80001458:	7402                	ld	s0,32(sp)
    8000145a:	64e2                	ld	s1,24(sp)
    8000145c:	6942                	ld	s2,16(sp)
    8000145e:	69a2                	ld	s3,8(sp)
    80001460:	6a02                	ld	s4,0(sp)
    80001462:	6145                	addi	sp,sp,48
    80001464:	8082                	ret
    panic("inituvm: more than a page");
    80001466:	00007517          	auipc	a0,0x7
    8000146a:	ce250513          	addi	a0,a0,-798 # 80008148 <digits+0x108>
    8000146e:	fffff097          	auipc	ra,0xfffff
    80001472:	0d4080e7          	jalr	212(ra) # 80000542 <panic>

0000000080001476 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001476:	1101                	addi	sp,sp,-32
    80001478:	ec06                	sd	ra,24(sp)
    8000147a:	e822                	sd	s0,16(sp)
    8000147c:	e426                	sd	s1,8(sp)
    8000147e:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001480:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001482:	00b67d63          	bgeu	a2,a1,8000149c <uvmdealloc+0x26>
    80001486:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001488:	6785                	lui	a5,0x1
    8000148a:	17fd                	addi	a5,a5,-1
    8000148c:	00f60733          	add	a4,a2,a5
    80001490:	767d                	lui	a2,0xfffff
    80001492:	8f71                	and	a4,a4,a2
    80001494:	97ae                	add	a5,a5,a1
    80001496:	8ff1                	and	a5,a5,a2
    80001498:	00f76863          	bltu	a4,a5,800014a8 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000149c:	8526                	mv	a0,s1
    8000149e:	60e2                	ld	ra,24(sp)
    800014a0:	6442                	ld	s0,16(sp)
    800014a2:	64a2                	ld	s1,8(sp)
    800014a4:	6105                	addi	sp,sp,32
    800014a6:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014a8:	8f99                	sub	a5,a5,a4
    800014aa:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014ac:	4685                	li	a3,1
    800014ae:	0007861b          	sext.w	a2,a5
    800014b2:	85ba                	mv	a1,a4
    800014b4:	00000097          	auipc	ra,0x0
    800014b8:	e5e080e7          	jalr	-418(ra) # 80001312 <uvmunmap>
    800014bc:	b7c5                	j	8000149c <uvmdealloc+0x26>

00000000800014be <uvmalloc>:
  if(newsz < oldsz)
    800014be:	0ab66163          	bltu	a2,a1,80001560 <uvmalloc+0xa2>
{
    800014c2:	7139                	addi	sp,sp,-64
    800014c4:	fc06                	sd	ra,56(sp)
    800014c6:	f822                	sd	s0,48(sp)
    800014c8:	f426                	sd	s1,40(sp)
    800014ca:	f04a                	sd	s2,32(sp)
    800014cc:	ec4e                	sd	s3,24(sp)
    800014ce:	e852                	sd	s4,16(sp)
    800014d0:	e456                	sd	s5,8(sp)
    800014d2:	0080                	addi	s0,sp,64
    800014d4:	8aaa                	mv	s5,a0
    800014d6:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014d8:	6985                	lui	s3,0x1
    800014da:	19fd                	addi	s3,s3,-1
    800014dc:	95ce                	add	a1,a1,s3
    800014de:	79fd                	lui	s3,0xfffff
    800014e0:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014e4:	08c9f063          	bgeu	s3,a2,80001564 <uvmalloc+0xa6>
    800014e8:	894e                	mv	s2,s3
    mem = kalloc();
    800014ea:	fffff097          	auipc	ra,0xfffff
    800014ee:	624080e7          	jalr	1572(ra) # 80000b0e <kalloc>
    800014f2:	84aa                	mv	s1,a0
    if(mem == 0){
    800014f4:	c51d                	beqz	a0,80001522 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800014f6:	6605                	lui	a2,0x1
    800014f8:	4581                	li	a1,0
    800014fa:	00000097          	auipc	ra,0x0
    800014fe:	852080e7          	jalr	-1966(ra) # 80000d4c <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001502:	4779                	li	a4,30
    80001504:	86a6                	mv	a3,s1
    80001506:	6605                	lui	a2,0x1
    80001508:	85ca                	mv	a1,s2
    8000150a:	8556                	mv	a0,s5
    8000150c:	00000097          	auipc	ra,0x0
    80001510:	c6e080e7          	jalr	-914(ra) # 8000117a <mappages>
    80001514:	e905                	bnez	a0,80001544 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001516:	6785                	lui	a5,0x1
    80001518:	993e                	add	s2,s2,a5
    8000151a:	fd4968e3          	bltu	s2,s4,800014ea <uvmalloc+0x2c>
  return newsz;
    8000151e:	8552                	mv	a0,s4
    80001520:	a809                	j	80001532 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001522:	864e                	mv	a2,s3
    80001524:	85ca                	mv	a1,s2
    80001526:	8556                	mv	a0,s5
    80001528:	00000097          	auipc	ra,0x0
    8000152c:	f4e080e7          	jalr	-178(ra) # 80001476 <uvmdealloc>
      return 0;
    80001530:	4501                	li	a0,0
}
    80001532:	70e2                	ld	ra,56(sp)
    80001534:	7442                	ld	s0,48(sp)
    80001536:	74a2                	ld	s1,40(sp)
    80001538:	7902                	ld	s2,32(sp)
    8000153a:	69e2                	ld	s3,24(sp)
    8000153c:	6a42                	ld	s4,16(sp)
    8000153e:	6aa2                	ld	s5,8(sp)
    80001540:	6121                	addi	sp,sp,64
    80001542:	8082                	ret
      kfree(mem);
    80001544:	8526                	mv	a0,s1
    80001546:	fffff097          	auipc	ra,0xfffff
    8000154a:	4cc080e7          	jalr	1228(ra) # 80000a12 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000154e:	864e                	mv	a2,s3
    80001550:	85ca                	mv	a1,s2
    80001552:	8556                	mv	a0,s5
    80001554:	00000097          	auipc	ra,0x0
    80001558:	f22080e7          	jalr	-222(ra) # 80001476 <uvmdealloc>
      return 0;
    8000155c:	4501                	li	a0,0
    8000155e:	bfd1                	j	80001532 <uvmalloc+0x74>
    return oldsz;
    80001560:	852e                	mv	a0,a1
}
    80001562:	8082                	ret
  return newsz;
    80001564:	8532                	mv	a0,a2
    80001566:	b7f1                	j	80001532 <uvmalloc+0x74>

0000000080001568 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001568:	7179                	addi	sp,sp,-48
    8000156a:	f406                	sd	ra,40(sp)
    8000156c:	f022                	sd	s0,32(sp)
    8000156e:	ec26                	sd	s1,24(sp)
    80001570:	e84a                	sd	s2,16(sp)
    80001572:	e44e                	sd	s3,8(sp)
    80001574:	e052                	sd	s4,0(sp)
    80001576:	1800                	addi	s0,sp,48
    80001578:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000157a:	84aa                	mv	s1,a0
    8000157c:	6905                	lui	s2,0x1
    8000157e:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001580:	4985                	li	s3,1
    80001582:	a821                	j	8000159a <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001584:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80001586:	0532                	slli	a0,a0,0xc
    80001588:	00000097          	auipc	ra,0x0
    8000158c:	fe0080e7          	jalr	-32(ra) # 80001568 <freewalk>
      pagetable[i] = 0;
    80001590:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001594:	04a1                	addi	s1,s1,8
    80001596:	03248163          	beq	s1,s2,800015b8 <freewalk+0x50>
    pte_t pte = pagetable[i];
    8000159a:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000159c:	00f57793          	andi	a5,a0,15
    800015a0:	ff3782e3          	beq	a5,s3,80001584 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015a4:	8905                	andi	a0,a0,1
    800015a6:	d57d                	beqz	a0,80001594 <freewalk+0x2c>
      panic("freewalk: leaf");
    800015a8:	00007517          	auipc	a0,0x7
    800015ac:	bc050513          	addi	a0,a0,-1088 # 80008168 <digits+0x128>
    800015b0:	fffff097          	auipc	ra,0xfffff
    800015b4:	f92080e7          	jalr	-110(ra) # 80000542 <panic>
    }
  }
  kfree((void*)pagetable);
    800015b8:	8552                	mv	a0,s4
    800015ba:	fffff097          	auipc	ra,0xfffff
    800015be:	458080e7          	jalr	1112(ra) # 80000a12 <kfree>
}
    800015c2:	70a2                	ld	ra,40(sp)
    800015c4:	7402                	ld	s0,32(sp)
    800015c6:	64e2                	ld	s1,24(sp)
    800015c8:	6942                	ld	s2,16(sp)
    800015ca:	69a2                	ld	s3,8(sp)
    800015cc:	6a02                	ld	s4,0(sp)
    800015ce:	6145                	addi	sp,sp,48
    800015d0:	8082                	ret

00000000800015d2 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015d2:	1101                	addi	sp,sp,-32
    800015d4:	ec06                	sd	ra,24(sp)
    800015d6:	e822                	sd	s0,16(sp)
    800015d8:	e426                	sd	s1,8(sp)
    800015da:	1000                	addi	s0,sp,32
    800015dc:	84aa                	mv	s1,a0
  if(sz > 0)
    800015de:	e999                	bnez	a1,800015f4 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015e0:	8526                	mv	a0,s1
    800015e2:	00000097          	auipc	ra,0x0
    800015e6:	f86080e7          	jalr	-122(ra) # 80001568 <freewalk>
}
    800015ea:	60e2                	ld	ra,24(sp)
    800015ec:	6442                	ld	s0,16(sp)
    800015ee:	64a2                	ld	s1,8(sp)
    800015f0:	6105                	addi	sp,sp,32
    800015f2:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015f4:	6605                	lui	a2,0x1
    800015f6:	167d                	addi	a2,a2,-1
    800015f8:	962e                	add	a2,a2,a1
    800015fa:	4685                	li	a3,1
    800015fc:	8231                	srli	a2,a2,0xc
    800015fe:	4581                	li	a1,0
    80001600:	00000097          	auipc	ra,0x0
    80001604:	d12080e7          	jalr	-750(ra) # 80001312 <uvmunmap>
    80001608:	bfe1                	j	800015e0 <uvmfree+0xe>

000000008000160a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000160a:	c679                	beqz	a2,800016d8 <uvmcopy+0xce>
{
    8000160c:	715d                	addi	sp,sp,-80
    8000160e:	e486                	sd	ra,72(sp)
    80001610:	e0a2                	sd	s0,64(sp)
    80001612:	fc26                	sd	s1,56(sp)
    80001614:	f84a                	sd	s2,48(sp)
    80001616:	f44e                	sd	s3,40(sp)
    80001618:	f052                	sd	s4,32(sp)
    8000161a:	ec56                	sd	s5,24(sp)
    8000161c:	e85a                	sd	s6,16(sp)
    8000161e:	e45e                	sd	s7,8(sp)
    80001620:	0880                	addi	s0,sp,80
    80001622:	8b2a                	mv	s6,a0
    80001624:	8aae                	mv	s5,a1
    80001626:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001628:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000162a:	4601                	li	a2,0
    8000162c:	85ce                	mv	a1,s3
    8000162e:	855a                	mv	a0,s6
    80001630:	00000097          	auipc	ra,0x0
    80001634:	a04080e7          	jalr	-1532(ra) # 80001034 <walk>
    80001638:	c531                	beqz	a0,80001684 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000163a:	6118                	ld	a4,0(a0)
    8000163c:	00177793          	andi	a5,a4,1
    80001640:	cbb1                	beqz	a5,80001694 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001642:	00a75593          	srli	a1,a4,0xa
    80001646:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000164a:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000164e:	fffff097          	auipc	ra,0xfffff
    80001652:	4c0080e7          	jalr	1216(ra) # 80000b0e <kalloc>
    80001656:	892a                	mv	s2,a0
    80001658:	c939                	beqz	a0,800016ae <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000165a:	6605                	lui	a2,0x1
    8000165c:	85de                	mv	a1,s7
    8000165e:	fffff097          	auipc	ra,0xfffff
    80001662:	74a080e7          	jalr	1866(ra) # 80000da8 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001666:	8726                	mv	a4,s1
    80001668:	86ca                	mv	a3,s2
    8000166a:	6605                	lui	a2,0x1
    8000166c:	85ce                	mv	a1,s3
    8000166e:	8556                	mv	a0,s5
    80001670:	00000097          	auipc	ra,0x0
    80001674:	b0a080e7          	jalr	-1270(ra) # 8000117a <mappages>
    80001678:	e515                	bnez	a0,800016a4 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000167a:	6785                	lui	a5,0x1
    8000167c:	99be                	add	s3,s3,a5
    8000167e:	fb49e6e3          	bltu	s3,s4,8000162a <uvmcopy+0x20>
    80001682:	a081                	j	800016c2 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001684:	00007517          	auipc	a0,0x7
    80001688:	af450513          	addi	a0,a0,-1292 # 80008178 <digits+0x138>
    8000168c:	fffff097          	auipc	ra,0xfffff
    80001690:	eb6080e7          	jalr	-330(ra) # 80000542 <panic>
      panic("uvmcopy: page not present");
    80001694:	00007517          	auipc	a0,0x7
    80001698:	b0450513          	addi	a0,a0,-1276 # 80008198 <digits+0x158>
    8000169c:	fffff097          	auipc	ra,0xfffff
    800016a0:	ea6080e7          	jalr	-346(ra) # 80000542 <panic>
      kfree(mem);
    800016a4:	854a                	mv	a0,s2
    800016a6:	fffff097          	auipc	ra,0xfffff
    800016aa:	36c080e7          	jalr	876(ra) # 80000a12 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016ae:	4685                	li	a3,1
    800016b0:	00c9d613          	srli	a2,s3,0xc
    800016b4:	4581                	li	a1,0
    800016b6:	8556                	mv	a0,s5
    800016b8:	00000097          	auipc	ra,0x0
    800016bc:	c5a080e7          	jalr	-934(ra) # 80001312 <uvmunmap>
  return -1;
    800016c0:	557d                	li	a0,-1
}
    800016c2:	60a6                	ld	ra,72(sp)
    800016c4:	6406                	ld	s0,64(sp)
    800016c6:	74e2                	ld	s1,56(sp)
    800016c8:	7942                	ld	s2,48(sp)
    800016ca:	79a2                	ld	s3,40(sp)
    800016cc:	7a02                	ld	s4,32(sp)
    800016ce:	6ae2                	ld	s5,24(sp)
    800016d0:	6b42                	ld	s6,16(sp)
    800016d2:	6ba2                	ld	s7,8(sp)
    800016d4:	6161                	addi	sp,sp,80
    800016d6:	8082                	ret
  return 0;
    800016d8:	4501                	li	a0,0
}
    800016da:	8082                	ret

00000000800016dc <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016dc:	1141                	addi	sp,sp,-16
    800016de:	e406                	sd	ra,8(sp)
    800016e0:	e022                	sd	s0,0(sp)
    800016e2:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016e4:	4601                	li	a2,0
    800016e6:	00000097          	auipc	ra,0x0
    800016ea:	94e080e7          	jalr	-1714(ra) # 80001034 <walk>
  if(pte == 0)
    800016ee:	c901                	beqz	a0,800016fe <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800016f0:	611c                	ld	a5,0(a0)
    800016f2:	9bbd                	andi	a5,a5,-17
    800016f4:	e11c                	sd	a5,0(a0)
}
    800016f6:	60a2                	ld	ra,8(sp)
    800016f8:	6402                	ld	s0,0(sp)
    800016fa:	0141                	addi	sp,sp,16
    800016fc:	8082                	ret
    panic("uvmclear");
    800016fe:	00007517          	auipc	a0,0x7
    80001702:	aba50513          	addi	a0,a0,-1350 # 800081b8 <digits+0x178>
    80001706:	fffff097          	auipc	ra,0xfffff
    8000170a:	e3c080e7          	jalr	-452(ra) # 80000542 <panic>

000000008000170e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000170e:	c6bd                	beqz	a3,8000177c <copyout+0x6e>
{
    80001710:	715d                	addi	sp,sp,-80
    80001712:	e486                	sd	ra,72(sp)
    80001714:	e0a2                	sd	s0,64(sp)
    80001716:	fc26                	sd	s1,56(sp)
    80001718:	f84a                	sd	s2,48(sp)
    8000171a:	f44e                	sd	s3,40(sp)
    8000171c:	f052                	sd	s4,32(sp)
    8000171e:	ec56                	sd	s5,24(sp)
    80001720:	e85a                	sd	s6,16(sp)
    80001722:	e45e                	sd	s7,8(sp)
    80001724:	e062                	sd	s8,0(sp)
    80001726:	0880                	addi	s0,sp,80
    80001728:	8b2a                	mv	s6,a0
    8000172a:	8c2e                	mv	s8,a1
    8000172c:	8a32                	mv	s4,a2
    8000172e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001730:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001732:	6a85                	lui	s5,0x1
    80001734:	a015                	j	80001758 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001736:	9562                	add	a0,a0,s8
    80001738:	0004861b          	sext.w	a2,s1
    8000173c:	85d2                	mv	a1,s4
    8000173e:	41250533          	sub	a0,a0,s2
    80001742:	fffff097          	auipc	ra,0xfffff
    80001746:	666080e7          	jalr	1638(ra) # 80000da8 <memmove>

    len -= n;
    8000174a:	409989b3          	sub	s3,s3,s1
    src += n;
    8000174e:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001750:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001754:	02098263          	beqz	s3,80001778 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001758:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000175c:	85ca                	mv	a1,s2
    8000175e:	855a                	mv	a0,s6
    80001760:	00000097          	auipc	ra,0x0
    80001764:	97a080e7          	jalr	-1670(ra) # 800010da <walkaddr>
    if(pa0 == 0)
    80001768:	cd01                	beqz	a0,80001780 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000176a:	418904b3          	sub	s1,s2,s8
    8000176e:	94d6                	add	s1,s1,s5
    if(n > len)
    80001770:	fc99f3e3          	bgeu	s3,s1,80001736 <copyout+0x28>
    80001774:	84ce                	mv	s1,s3
    80001776:	b7c1                	j	80001736 <copyout+0x28>
  }
  return 0;
    80001778:	4501                	li	a0,0
    8000177a:	a021                	j	80001782 <copyout+0x74>
    8000177c:	4501                	li	a0,0
}
    8000177e:	8082                	ret
      return -1;
    80001780:	557d                	li	a0,-1
}
    80001782:	60a6                	ld	ra,72(sp)
    80001784:	6406                	ld	s0,64(sp)
    80001786:	74e2                	ld	s1,56(sp)
    80001788:	7942                	ld	s2,48(sp)
    8000178a:	79a2                	ld	s3,40(sp)
    8000178c:	7a02                	ld	s4,32(sp)
    8000178e:	6ae2                	ld	s5,24(sp)
    80001790:	6b42                	ld	s6,16(sp)
    80001792:	6ba2                	ld	s7,8(sp)
    80001794:	6c02                	ld	s8,0(sp)
    80001796:	6161                	addi	sp,sp,80
    80001798:	8082                	ret

000000008000179a <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000179a:	caa5                	beqz	a3,8000180a <copyin+0x70>
{
    8000179c:	715d                	addi	sp,sp,-80
    8000179e:	e486                	sd	ra,72(sp)
    800017a0:	e0a2                	sd	s0,64(sp)
    800017a2:	fc26                	sd	s1,56(sp)
    800017a4:	f84a                	sd	s2,48(sp)
    800017a6:	f44e                	sd	s3,40(sp)
    800017a8:	f052                	sd	s4,32(sp)
    800017aa:	ec56                	sd	s5,24(sp)
    800017ac:	e85a                	sd	s6,16(sp)
    800017ae:	e45e                	sd	s7,8(sp)
    800017b0:	e062                	sd	s8,0(sp)
    800017b2:	0880                	addi	s0,sp,80
    800017b4:	8b2a                	mv	s6,a0
    800017b6:	8a2e                	mv	s4,a1
    800017b8:	8c32                	mv	s8,a2
    800017ba:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017bc:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017be:	6a85                	lui	s5,0x1
    800017c0:	a01d                	j	800017e6 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017c2:	018505b3          	add	a1,a0,s8
    800017c6:	0004861b          	sext.w	a2,s1
    800017ca:	412585b3          	sub	a1,a1,s2
    800017ce:	8552                	mv	a0,s4
    800017d0:	fffff097          	auipc	ra,0xfffff
    800017d4:	5d8080e7          	jalr	1496(ra) # 80000da8 <memmove>

    len -= n;
    800017d8:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017dc:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017de:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017e2:	02098263          	beqz	s3,80001806 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017e6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017ea:	85ca                	mv	a1,s2
    800017ec:	855a                	mv	a0,s6
    800017ee:	00000097          	auipc	ra,0x0
    800017f2:	8ec080e7          	jalr	-1812(ra) # 800010da <walkaddr>
    if(pa0 == 0)
    800017f6:	cd01                	beqz	a0,8000180e <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800017f8:	418904b3          	sub	s1,s2,s8
    800017fc:	94d6                	add	s1,s1,s5
    if(n > len)
    800017fe:	fc99f2e3          	bgeu	s3,s1,800017c2 <copyin+0x28>
    80001802:	84ce                	mv	s1,s3
    80001804:	bf7d                	j	800017c2 <copyin+0x28>
  }
  return 0;
    80001806:	4501                	li	a0,0
    80001808:	a021                	j	80001810 <copyin+0x76>
    8000180a:	4501                	li	a0,0
}
    8000180c:	8082                	ret
      return -1;
    8000180e:	557d                	li	a0,-1
}
    80001810:	60a6                	ld	ra,72(sp)
    80001812:	6406                	ld	s0,64(sp)
    80001814:	74e2                	ld	s1,56(sp)
    80001816:	7942                	ld	s2,48(sp)
    80001818:	79a2                	ld	s3,40(sp)
    8000181a:	7a02                	ld	s4,32(sp)
    8000181c:	6ae2                	ld	s5,24(sp)
    8000181e:	6b42                	ld	s6,16(sp)
    80001820:	6ba2                	ld	s7,8(sp)
    80001822:	6c02                	ld	s8,0(sp)
    80001824:	6161                	addi	sp,sp,80
    80001826:	8082                	ret

0000000080001828 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001828:	c6c5                	beqz	a3,800018d0 <copyinstr+0xa8>
{
    8000182a:	715d                	addi	sp,sp,-80
    8000182c:	e486                	sd	ra,72(sp)
    8000182e:	e0a2                	sd	s0,64(sp)
    80001830:	fc26                	sd	s1,56(sp)
    80001832:	f84a                	sd	s2,48(sp)
    80001834:	f44e                	sd	s3,40(sp)
    80001836:	f052                	sd	s4,32(sp)
    80001838:	ec56                	sd	s5,24(sp)
    8000183a:	e85a                	sd	s6,16(sp)
    8000183c:	e45e                	sd	s7,8(sp)
    8000183e:	0880                	addi	s0,sp,80
    80001840:	8a2a                	mv	s4,a0
    80001842:	8b2e                	mv	s6,a1
    80001844:	8bb2                	mv	s7,a2
    80001846:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001848:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000184a:	6985                	lui	s3,0x1
    8000184c:	a035                	j	80001878 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000184e:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001852:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001854:	0017b793          	seqz	a5,a5
    80001858:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000185c:	60a6                	ld	ra,72(sp)
    8000185e:	6406                	ld	s0,64(sp)
    80001860:	74e2                	ld	s1,56(sp)
    80001862:	7942                	ld	s2,48(sp)
    80001864:	79a2                	ld	s3,40(sp)
    80001866:	7a02                	ld	s4,32(sp)
    80001868:	6ae2                	ld	s5,24(sp)
    8000186a:	6b42                	ld	s6,16(sp)
    8000186c:	6ba2                	ld	s7,8(sp)
    8000186e:	6161                	addi	sp,sp,80
    80001870:	8082                	ret
    srcva = va0 + PGSIZE;
    80001872:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001876:	c8a9                	beqz	s1,800018c8 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80001878:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000187c:	85ca                	mv	a1,s2
    8000187e:	8552                	mv	a0,s4
    80001880:	00000097          	auipc	ra,0x0
    80001884:	85a080e7          	jalr	-1958(ra) # 800010da <walkaddr>
    if(pa0 == 0)
    80001888:	c131                	beqz	a0,800018cc <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    8000188a:	41790833          	sub	a6,s2,s7
    8000188e:	984e                	add	a6,a6,s3
    if(n > max)
    80001890:	0104f363          	bgeu	s1,a6,80001896 <copyinstr+0x6e>
    80001894:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001896:	955e                	add	a0,a0,s7
    80001898:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000189c:	fc080be3          	beqz	a6,80001872 <copyinstr+0x4a>
    800018a0:	985a                	add	a6,a6,s6
    800018a2:	87da                	mv	a5,s6
      if(*p == '\0'){
    800018a4:	41650633          	sub	a2,a0,s6
    800018a8:	14fd                	addi	s1,s1,-1
    800018aa:	9b26                	add	s6,s6,s1
    800018ac:	00f60733          	add	a4,a2,a5
    800018b0:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    800018b4:	df49                	beqz	a4,8000184e <copyinstr+0x26>
        *dst = *p;
    800018b6:	00e78023          	sb	a4,0(a5)
      --max;
    800018ba:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800018be:	0785                	addi	a5,a5,1
    while(n > 0){
    800018c0:	ff0796e3          	bne	a5,a6,800018ac <copyinstr+0x84>
      dst++;
    800018c4:	8b42                	mv	s6,a6
    800018c6:	b775                	j	80001872 <copyinstr+0x4a>
    800018c8:	4781                	li	a5,0
    800018ca:	b769                	j	80001854 <copyinstr+0x2c>
      return -1;
    800018cc:	557d                	li	a0,-1
    800018ce:	b779                	j	8000185c <copyinstr+0x34>
  int got_null = 0;
    800018d0:	4781                	li	a5,0
  if(got_null){
    800018d2:	0017b793          	seqz	a5,a5
    800018d6:	40f00533          	neg	a0,a5
}
    800018da:	8082                	ret

00000000800018dc <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    800018dc:	1101                	addi	sp,sp,-32
    800018de:	ec06                	sd	ra,24(sp)
    800018e0:	e822                	sd	s0,16(sp)
    800018e2:	e426                	sd	s1,8(sp)
    800018e4:	1000                	addi	s0,sp,32
    800018e6:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800018e8:	fffff097          	auipc	ra,0xfffff
    800018ec:	2ee080e7          	jalr	750(ra) # 80000bd6 <holding>
    800018f0:	c909                	beqz	a0,80001902 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    800018f2:	749c                	ld	a5,40(s1)
    800018f4:	00978f63          	beq	a5,s1,80001912 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    800018f8:	60e2                	ld	ra,24(sp)
    800018fa:	6442                	ld	s0,16(sp)
    800018fc:	64a2                	ld	s1,8(sp)
    800018fe:	6105                	addi	sp,sp,32
    80001900:	8082                	ret
    panic("wakeup1");
    80001902:	00007517          	auipc	a0,0x7
    80001906:	8c650513          	addi	a0,a0,-1850 # 800081c8 <digits+0x188>
    8000190a:	fffff097          	auipc	ra,0xfffff
    8000190e:	c38080e7          	jalr	-968(ra) # 80000542 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80001912:	4c98                	lw	a4,24(s1)
    80001914:	4785                	li	a5,1
    80001916:	fef711e3          	bne	a4,a5,800018f8 <wakeup1+0x1c>
    p->state = RUNNABLE;
    8000191a:	4789                	li	a5,2
    8000191c:	cc9c                	sw	a5,24(s1)
}
    8000191e:	bfe9                	j	800018f8 <wakeup1+0x1c>

0000000080001920 <procinit>:
{
    80001920:	715d                	addi	sp,sp,-80
    80001922:	e486                	sd	ra,72(sp)
    80001924:	e0a2                	sd	s0,64(sp)
    80001926:	fc26                	sd	s1,56(sp)
    80001928:	f84a                	sd	s2,48(sp)
    8000192a:	f44e                	sd	s3,40(sp)
    8000192c:	f052                	sd	s4,32(sp)
    8000192e:	ec56                	sd	s5,24(sp)
    80001930:	e85a                	sd	s6,16(sp)
    80001932:	e45e                	sd	s7,8(sp)
    80001934:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001936:	00007597          	auipc	a1,0x7
    8000193a:	89a58593          	addi	a1,a1,-1894 # 800081d0 <digits+0x190>
    8000193e:	00010517          	auipc	a0,0x10
    80001942:	01250513          	addi	a0,a0,18 # 80011950 <pid_lock>
    80001946:	fffff097          	auipc	ra,0xfffff
    8000194a:	27a080e7          	jalr	634(ra) # 80000bc0 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000194e:	00010917          	auipc	s2,0x10
    80001952:	41a90913          	addi	s2,s2,1050 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    80001956:	00007b97          	auipc	s7,0x7
    8000195a:	882b8b93          	addi	s7,s7,-1918 # 800081d8 <digits+0x198>
      uint64 va = KSTACK((int) (p - proc));
    8000195e:	8b4a                	mv	s6,s2
    80001960:	00006a97          	auipc	s5,0x6
    80001964:	6a0a8a93          	addi	s5,s5,1696 # 80008000 <etext>
    80001968:	040009b7          	lui	s3,0x4000
    8000196c:	19fd                	addi	s3,s3,-1
    8000196e:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001970:	00016a17          	auipc	s4,0x16
    80001974:	df8a0a13          	addi	s4,s4,-520 # 80017768 <tickslock>
      initlock(&p->lock, "proc");
    80001978:	85de                	mv	a1,s7
    8000197a:	854a                	mv	a0,s2
    8000197c:	fffff097          	auipc	ra,0xfffff
    80001980:	244080e7          	jalr	580(ra) # 80000bc0 <initlock>
      char *pa = kalloc();
    80001984:	fffff097          	auipc	ra,0xfffff
    80001988:	18a080e7          	jalr	394(ra) # 80000b0e <kalloc>
    8000198c:	85aa                	mv	a1,a0
      if(pa == 0)
    8000198e:	c929                	beqz	a0,800019e0 <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    80001990:	416904b3          	sub	s1,s2,s6
    80001994:	848d                	srai	s1,s1,0x3
    80001996:	000ab783          	ld	a5,0(s5)
    8000199a:	02f484b3          	mul	s1,s1,a5
    8000199e:	2485                	addiw	s1,s1,1
    800019a0:	00d4949b          	slliw	s1,s1,0xd
    800019a4:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019a8:	4699                	li	a3,6
    800019aa:	6605                	lui	a2,0x1
    800019ac:	8526                	mv	a0,s1
    800019ae:	00000097          	auipc	ra,0x0
    800019b2:	85a080e7          	jalr	-1958(ra) # 80001208 <kvmmap>
      p->kstack = va;
    800019b6:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019ba:	16890913          	addi	s2,s2,360
    800019be:	fb491de3          	bne	s2,s4,80001978 <procinit+0x58>
  kvminithart();
    800019c2:	fffff097          	auipc	ra,0xfffff
    800019c6:	64e080e7          	jalr	1614(ra) # 80001010 <kvminithart>
}
    800019ca:	60a6                	ld	ra,72(sp)
    800019cc:	6406                	ld	s0,64(sp)
    800019ce:	74e2                	ld	s1,56(sp)
    800019d0:	7942                	ld	s2,48(sp)
    800019d2:	79a2                	ld	s3,40(sp)
    800019d4:	7a02                	ld	s4,32(sp)
    800019d6:	6ae2                	ld	s5,24(sp)
    800019d8:	6b42                	ld	s6,16(sp)
    800019da:	6ba2                	ld	s7,8(sp)
    800019dc:	6161                	addi	sp,sp,80
    800019de:	8082                	ret
        panic("kalloc");
    800019e0:	00007517          	auipc	a0,0x7
    800019e4:	80050513          	addi	a0,a0,-2048 # 800081e0 <digits+0x1a0>
    800019e8:	fffff097          	auipc	ra,0xfffff
    800019ec:	b5a080e7          	jalr	-1190(ra) # 80000542 <panic>

00000000800019f0 <cpuid>:
{
    800019f0:	1141                	addi	sp,sp,-16
    800019f2:	e422                	sd	s0,8(sp)
    800019f4:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019f6:	8512                	mv	a0,tp
}
    800019f8:	2501                	sext.w	a0,a0
    800019fa:	6422                	ld	s0,8(sp)
    800019fc:	0141                	addi	sp,sp,16
    800019fe:	8082                	ret

0000000080001a00 <mycpu>:
mycpu(void) {
    80001a00:	1141                	addi	sp,sp,-16
    80001a02:	e422                	sd	s0,8(sp)
    80001a04:	0800                	addi	s0,sp,16
    80001a06:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a08:	2781                	sext.w	a5,a5
    80001a0a:	079e                	slli	a5,a5,0x7
}
    80001a0c:	00010517          	auipc	a0,0x10
    80001a10:	f5c50513          	addi	a0,a0,-164 # 80011968 <cpus>
    80001a14:	953e                	add	a0,a0,a5
    80001a16:	6422                	ld	s0,8(sp)
    80001a18:	0141                	addi	sp,sp,16
    80001a1a:	8082                	ret

0000000080001a1c <myproc>:
myproc(void) {
    80001a1c:	1101                	addi	sp,sp,-32
    80001a1e:	ec06                	sd	ra,24(sp)
    80001a20:	e822                	sd	s0,16(sp)
    80001a22:	e426                	sd	s1,8(sp)
    80001a24:	1000                	addi	s0,sp,32
  push_off();
    80001a26:	fffff097          	auipc	ra,0xfffff
    80001a2a:	1de080e7          	jalr	478(ra) # 80000c04 <push_off>
    80001a2e:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a30:	2781                	sext.w	a5,a5
    80001a32:	079e                	slli	a5,a5,0x7
    80001a34:	00010717          	auipc	a4,0x10
    80001a38:	f1c70713          	addi	a4,a4,-228 # 80011950 <pid_lock>
    80001a3c:	97ba                	add	a5,a5,a4
    80001a3e:	6f84                	ld	s1,24(a5)
  pop_off();
    80001a40:	fffff097          	auipc	ra,0xfffff
    80001a44:	264080e7          	jalr	612(ra) # 80000ca4 <pop_off>
}
    80001a48:	8526                	mv	a0,s1
    80001a4a:	60e2                	ld	ra,24(sp)
    80001a4c:	6442                	ld	s0,16(sp)
    80001a4e:	64a2                	ld	s1,8(sp)
    80001a50:	6105                	addi	sp,sp,32
    80001a52:	8082                	ret

0000000080001a54 <forkret>:
{
    80001a54:	1141                	addi	sp,sp,-16
    80001a56:	e406                	sd	ra,8(sp)
    80001a58:	e022                	sd	s0,0(sp)
    80001a5a:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a5c:	00000097          	auipc	ra,0x0
    80001a60:	fc0080e7          	jalr	-64(ra) # 80001a1c <myproc>
    80001a64:	fffff097          	auipc	ra,0xfffff
    80001a68:	2a0080e7          	jalr	672(ra) # 80000d04 <release>
  if (first) {
    80001a6c:	00007797          	auipc	a5,0x7
    80001a70:	e747a783          	lw	a5,-396(a5) # 800088e0 <first.1>
    80001a74:	eb89                	bnez	a5,80001a86 <forkret+0x32>
  usertrapret();
    80001a76:	00001097          	auipc	ra,0x1
    80001a7a:	c46080e7          	jalr	-954(ra) # 800026bc <usertrapret>
}
    80001a7e:	60a2                	ld	ra,8(sp)
    80001a80:	6402                	ld	s0,0(sp)
    80001a82:	0141                	addi	sp,sp,16
    80001a84:	8082                	ret
    first = 0;
    80001a86:	00007797          	auipc	a5,0x7
    80001a8a:	e407ad23          	sw	zero,-422(a5) # 800088e0 <first.1>
    fsinit(ROOTDEV);
    80001a8e:	4505                	li	a0,1
    80001a90:	00002097          	auipc	ra,0x2
    80001a94:	a8c080e7          	jalr	-1396(ra) # 8000351c <fsinit>
    80001a98:	bff9                	j	80001a76 <forkret+0x22>

0000000080001a9a <allocpid>:
allocpid() {
    80001a9a:	1101                	addi	sp,sp,-32
    80001a9c:	ec06                	sd	ra,24(sp)
    80001a9e:	e822                	sd	s0,16(sp)
    80001aa0:	e426                	sd	s1,8(sp)
    80001aa2:	e04a                	sd	s2,0(sp)
    80001aa4:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001aa6:	00010917          	auipc	s2,0x10
    80001aaa:	eaa90913          	addi	s2,s2,-342 # 80011950 <pid_lock>
    80001aae:	854a                	mv	a0,s2
    80001ab0:	fffff097          	auipc	ra,0xfffff
    80001ab4:	1a0080e7          	jalr	416(ra) # 80000c50 <acquire>
  pid = nextpid;
    80001ab8:	00007797          	auipc	a5,0x7
    80001abc:	e2c78793          	addi	a5,a5,-468 # 800088e4 <nextpid>
    80001ac0:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ac2:	0014871b          	addiw	a4,s1,1
    80001ac6:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ac8:	854a                	mv	a0,s2
    80001aca:	fffff097          	auipc	ra,0xfffff
    80001ace:	23a080e7          	jalr	570(ra) # 80000d04 <release>
}
    80001ad2:	8526                	mv	a0,s1
    80001ad4:	60e2                	ld	ra,24(sp)
    80001ad6:	6442                	ld	s0,16(sp)
    80001ad8:	64a2                	ld	s1,8(sp)
    80001ada:	6902                	ld	s2,0(sp)
    80001adc:	6105                	addi	sp,sp,32
    80001ade:	8082                	ret

0000000080001ae0 <proc_pagetable>:
{
    80001ae0:	1101                	addi	sp,sp,-32
    80001ae2:	ec06                	sd	ra,24(sp)
    80001ae4:	e822                	sd	s0,16(sp)
    80001ae6:	e426                	sd	s1,8(sp)
    80001ae8:	e04a                	sd	s2,0(sp)
    80001aea:	1000                	addi	s0,sp,32
    80001aec:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001aee:	00000097          	auipc	ra,0x0
    80001af2:	8e8080e7          	jalr	-1816(ra) # 800013d6 <uvmcreate>
    80001af6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001af8:	c121                	beqz	a0,80001b38 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001afa:	4729                	li	a4,10
    80001afc:	00005697          	auipc	a3,0x5
    80001b00:	50468693          	addi	a3,a3,1284 # 80007000 <_trampoline>
    80001b04:	6605                	lui	a2,0x1
    80001b06:	040005b7          	lui	a1,0x4000
    80001b0a:	15fd                	addi	a1,a1,-1
    80001b0c:	05b2                	slli	a1,a1,0xc
    80001b0e:	fffff097          	auipc	ra,0xfffff
    80001b12:	66c080e7          	jalr	1644(ra) # 8000117a <mappages>
    80001b16:	02054863          	bltz	a0,80001b46 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b1a:	4719                	li	a4,6
    80001b1c:	05893683          	ld	a3,88(s2)
    80001b20:	6605                	lui	a2,0x1
    80001b22:	020005b7          	lui	a1,0x2000
    80001b26:	15fd                	addi	a1,a1,-1
    80001b28:	05b6                	slli	a1,a1,0xd
    80001b2a:	8526                	mv	a0,s1
    80001b2c:	fffff097          	auipc	ra,0xfffff
    80001b30:	64e080e7          	jalr	1614(ra) # 8000117a <mappages>
    80001b34:	02054163          	bltz	a0,80001b56 <proc_pagetable+0x76>
}
    80001b38:	8526                	mv	a0,s1
    80001b3a:	60e2                	ld	ra,24(sp)
    80001b3c:	6442                	ld	s0,16(sp)
    80001b3e:	64a2                	ld	s1,8(sp)
    80001b40:	6902                	ld	s2,0(sp)
    80001b42:	6105                	addi	sp,sp,32
    80001b44:	8082                	ret
    uvmfree(pagetable, 0);
    80001b46:	4581                	li	a1,0
    80001b48:	8526                	mv	a0,s1
    80001b4a:	00000097          	auipc	ra,0x0
    80001b4e:	a88080e7          	jalr	-1400(ra) # 800015d2 <uvmfree>
    return 0;
    80001b52:	4481                	li	s1,0
    80001b54:	b7d5                	j	80001b38 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b56:	4681                	li	a3,0
    80001b58:	4605                	li	a2,1
    80001b5a:	040005b7          	lui	a1,0x4000
    80001b5e:	15fd                	addi	a1,a1,-1
    80001b60:	05b2                	slli	a1,a1,0xc
    80001b62:	8526                	mv	a0,s1
    80001b64:	fffff097          	auipc	ra,0xfffff
    80001b68:	7ae080e7          	jalr	1966(ra) # 80001312 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b6c:	4581                	li	a1,0
    80001b6e:	8526                	mv	a0,s1
    80001b70:	00000097          	auipc	ra,0x0
    80001b74:	a62080e7          	jalr	-1438(ra) # 800015d2 <uvmfree>
    return 0;
    80001b78:	4481                	li	s1,0
    80001b7a:	bf7d                	j	80001b38 <proc_pagetable+0x58>

0000000080001b7c <proc_freepagetable>:
{
    80001b7c:	1101                	addi	sp,sp,-32
    80001b7e:	ec06                	sd	ra,24(sp)
    80001b80:	e822                	sd	s0,16(sp)
    80001b82:	e426                	sd	s1,8(sp)
    80001b84:	e04a                	sd	s2,0(sp)
    80001b86:	1000                	addi	s0,sp,32
    80001b88:	84aa                	mv	s1,a0
    80001b8a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b8c:	4681                	li	a3,0
    80001b8e:	4605                	li	a2,1
    80001b90:	040005b7          	lui	a1,0x4000
    80001b94:	15fd                	addi	a1,a1,-1
    80001b96:	05b2                	slli	a1,a1,0xc
    80001b98:	fffff097          	auipc	ra,0xfffff
    80001b9c:	77a080e7          	jalr	1914(ra) # 80001312 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001ba0:	4681                	li	a3,0
    80001ba2:	4605                	li	a2,1
    80001ba4:	020005b7          	lui	a1,0x2000
    80001ba8:	15fd                	addi	a1,a1,-1
    80001baa:	05b6                	slli	a1,a1,0xd
    80001bac:	8526                	mv	a0,s1
    80001bae:	fffff097          	auipc	ra,0xfffff
    80001bb2:	764080e7          	jalr	1892(ra) # 80001312 <uvmunmap>
  uvmfree(pagetable, sz);
    80001bb6:	85ca                	mv	a1,s2
    80001bb8:	8526                	mv	a0,s1
    80001bba:	00000097          	auipc	ra,0x0
    80001bbe:	a18080e7          	jalr	-1512(ra) # 800015d2 <uvmfree>
}
    80001bc2:	60e2                	ld	ra,24(sp)
    80001bc4:	6442                	ld	s0,16(sp)
    80001bc6:	64a2                	ld	s1,8(sp)
    80001bc8:	6902                	ld	s2,0(sp)
    80001bca:	6105                	addi	sp,sp,32
    80001bcc:	8082                	ret

0000000080001bce <freeproc>:
{
    80001bce:	1101                	addi	sp,sp,-32
    80001bd0:	ec06                	sd	ra,24(sp)
    80001bd2:	e822                	sd	s0,16(sp)
    80001bd4:	e426                	sd	s1,8(sp)
    80001bd6:	1000                	addi	s0,sp,32
    80001bd8:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bda:	6d28                	ld	a0,88(a0)
    80001bdc:	c509                	beqz	a0,80001be6 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bde:	fffff097          	auipc	ra,0xfffff
    80001be2:	e34080e7          	jalr	-460(ra) # 80000a12 <kfree>
  p->trapframe = 0;
    80001be6:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001bea:	68a8                	ld	a0,80(s1)
    80001bec:	c511                	beqz	a0,80001bf8 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bee:	64ac                	ld	a1,72(s1)
    80001bf0:	00000097          	auipc	ra,0x0
    80001bf4:	f8c080e7          	jalr	-116(ra) # 80001b7c <proc_freepagetable>
  p->pagetable = 0;
    80001bf8:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bfc:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c00:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001c04:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001c08:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c0c:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001c10:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001c14:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001c18:	0004ac23          	sw	zero,24(s1)
}
    80001c1c:	60e2                	ld	ra,24(sp)
    80001c1e:	6442                	ld	s0,16(sp)
    80001c20:	64a2                	ld	s1,8(sp)
    80001c22:	6105                	addi	sp,sp,32
    80001c24:	8082                	ret

0000000080001c26 <allocproc>:
{
    80001c26:	1101                	addi	sp,sp,-32
    80001c28:	ec06                	sd	ra,24(sp)
    80001c2a:	e822                	sd	s0,16(sp)
    80001c2c:	e426                	sd	s1,8(sp)
    80001c2e:	e04a                	sd	s2,0(sp)
    80001c30:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c32:	00010497          	auipc	s1,0x10
    80001c36:	13648493          	addi	s1,s1,310 # 80011d68 <proc>
    80001c3a:	00016917          	auipc	s2,0x16
    80001c3e:	b2e90913          	addi	s2,s2,-1234 # 80017768 <tickslock>
    acquire(&p->lock);
    80001c42:	8526                	mv	a0,s1
    80001c44:	fffff097          	auipc	ra,0xfffff
    80001c48:	00c080e7          	jalr	12(ra) # 80000c50 <acquire>
    if(p->state == UNUSED) {
    80001c4c:	4c9c                	lw	a5,24(s1)
    80001c4e:	cf81                	beqz	a5,80001c66 <allocproc+0x40>
      release(&p->lock);
    80001c50:	8526                	mv	a0,s1
    80001c52:	fffff097          	auipc	ra,0xfffff
    80001c56:	0b2080e7          	jalr	178(ra) # 80000d04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c5a:	16848493          	addi	s1,s1,360
    80001c5e:	ff2492e3          	bne	s1,s2,80001c42 <allocproc+0x1c>
  return 0;
    80001c62:	4481                	li	s1,0
    80001c64:	a0b9                	j	80001cb2 <allocproc+0x8c>
  p->pid = allocpid();
    80001c66:	00000097          	auipc	ra,0x0
    80001c6a:	e34080e7          	jalr	-460(ra) # 80001a9a <allocpid>
    80001c6e:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c70:	fffff097          	auipc	ra,0xfffff
    80001c74:	e9e080e7          	jalr	-354(ra) # 80000b0e <kalloc>
    80001c78:	892a                	mv	s2,a0
    80001c7a:	eca8                	sd	a0,88(s1)
    80001c7c:	c131                	beqz	a0,80001cc0 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001c7e:	8526                	mv	a0,s1
    80001c80:	00000097          	auipc	ra,0x0
    80001c84:	e60080e7          	jalr	-416(ra) # 80001ae0 <proc_pagetable>
    80001c88:	892a                	mv	s2,a0
    80001c8a:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c8c:	c129                	beqz	a0,80001cce <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001c8e:	07000613          	li	a2,112
    80001c92:	4581                	li	a1,0
    80001c94:	06048513          	addi	a0,s1,96
    80001c98:	fffff097          	auipc	ra,0xfffff
    80001c9c:	0b4080e7          	jalr	180(ra) # 80000d4c <memset>
  p->context.ra = (uint64)forkret;
    80001ca0:	00000797          	auipc	a5,0x0
    80001ca4:	db478793          	addi	a5,a5,-588 # 80001a54 <forkret>
    80001ca8:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001caa:	60bc                	ld	a5,64(s1)
    80001cac:	6705                	lui	a4,0x1
    80001cae:	97ba                	add	a5,a5,a4
    80001cb0:	f4bc                	sd	a5,104(s1)
}
    80001cb2:	8526                	mv	a0,s1
    80001cb4:	60e2                	ld	ra,24(sp)
    80001cb6:	6442                	ld	s0,16(sp)
    80001cb8:	64a2                	ld	s1,8(sp)
    80001cba:	6902                	ld	s2,0(sp)
    80001cbc:	6105                	addi	sp,sp,32
    80001cbe:	8082                	ret
    release(&p->lock);
    80001cc0:	8526                	mv	a0,s1
    80001cc2:	fffff097          	auipc	ra,0xfffff
    80001cc6:	042080e7          	jalr	66(ra) # 80000d04 <release>
    return 0;
    80001cca:	84ca                	mv	s1,s2
    80001ccc:	b7dd                	j	80001cb2 <allocproc+0x8c>
    freeproc(p);
    80001cce:	8526                	mv	a0,s1
    80001cd0:	00000097          	auipc	ra,0x0
    80001cd4:	efe080e7          	jalr	-258(ra) # 80001bce <freeproc>
    release(&p->lock);
    80001cd8:	8526                	mv	a0,s1
    80001cda:	fffff097          	auipc	ra,0xfffff
    80001cde:	02a080e7          	jalr	42(ra) # 80000d04 <release>
    return 0;
    80001ce2:	84ca                	mv	s1,s2
    80001ce4:	b7f9                	j	80001cb2 <allocproc+0x8c>

0000000080001ce6 <userinit>:
{
    80001ce6:	1101                	addi	sp,sp,-32
    80001ce8:	ec06                	sd	ra,24(sp)
    80001cea:	e822                	sd	s0,16(sp)
    80001cec:	e426                	sd	s1,8(sp)
    80001cee:	1000                	addi	s0,sp,32
  p = allocproc();
    80001cf0:	00000097          	auipc	ra,0x0
    80001cf4:	f36080e7          	jalr	-202(ra) # 80001c26 <allocproc>
    80001cf8:	84aa                	mv	s1,a0
  initproc = p;
    80001cfa:	00007797          	auipc	a5,0x7
    80001cfe:	30a7bf23          	sd	a0,798(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d02:	03400613          	li	a2,52
    80001d06:	00007597          	auipc	a1,0x7
    80001d0a:	bea58593          	addi	a1,a1,-1046 # 800088f0 <initcode>
    80001d0e:	6928                	ld	a0,80(a0)
    80001d10:	fffff097          	auipc	ra,0xfffff
    80001d14:	6f4080e7          	jalr	1780(ra) # 80001404 <uvminit>
  p->sz = PGSIZE;
    80001d18:	6785                	lui	a5,0x1
    80001d1a:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d1c:	6cb8                	ld	a4,88(s1)
    80001d1e:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d22:	6cb8                	ld	a4,88(s1)
    80001d24:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d26:	4641                	li	a2,16
    80001d28:	00006597          	auipc	a1,0x6
    80001d2c:	4c058593          	addi	a1,a1,1216 # 800081e8 <digits+0x1a8>
    80001d30:	15848513          	addi	a0,s1,344
    80001d34:	fffff097          	auipc	ra,0xfffff
    80001d38:	16a080e7          	jalr	362(ra) # 80000e9e <safestrcpy>
  p->cwd = namei("/");
    80001d3c:	00006517          	auipc	a0,0x6
    80001d40:	4bc50513          	addi	a0,a0,1212 # 800081f8 <digits+0x1b8>
    80001d44:	00002097          	auipc	ra,0x2
    80001d48:	200080e7          	jalr	512(ra) # 80003f44 <namei>
    80001d4c:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d50:	4789                	li	a5,2
    80001d52:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d54:	8526                	mv	a0,s1
    80001d56:	fffff097          	auipc	ra,0xfffff
    80001d5a:	fae080e7          	jalr	-82(ra) # 80000d04 <release>
}
    80001d5e:	60e2                	ld	ra,24(sp)
    80001d60:	6442                	ld	s0,16(sp)
    80001d62:	64a2                	ld	s1,8(sp)
    80001d64:	6105                	addi	sp,sp,32
    80001d66:	8082                	ret

0000000080001d68 <growproc>:
{
    80001d68:	1101                	addi	sp,sp,-32
    80001d6a:	ec06                	sd	ra,24(sp)
    80001d6c:	e822                	sd	s0,16(sp)
    80001d6e:	e426                	sd	s1,8(sp)
    80001d70:	e04a                	sd	s2,0(sp)
    80001d72:	1000                	addi	s0,sp,32
    80001d74:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001d76:	00000097          	auipc	ra,0x0
    80001d7a:	ca6080e7          	jalr	-858(ra) # 80001a1c <myproc>
    80001d7e:	892a                	mv	s2,a0
  sz = p->sz;
    80001d80:	652c                	ld	a1,72(a0)
    80001d82:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001d86:	00904f63          	bgtz	s1,80001da4 <growproc+0x3c>
  } else if(n < 0){
    80001d8a:	0204cc63          	bltz	s1,80001dc2 <growproc+0x5a>
  p->sz = sz;
    80001d8e:	1602                	slli	a2,a2,0x20
    80001d90:	9201                	srli	a2,a2,0x20
    80001d92:	04c93423          	sd	a2,72(s2)
  return 0;
    80001d96:	4501                	li	a0,0
}
    80001d98:	60e2                	ld	ra,24(sp)
    80001d9a:	6442                	ld	s0,16(sp)
    80001d9c:	64a2                	ld	s1,8(sp)
    80001d9e:	6902                	ld	s2,0(sp)
    80001da0:	6105                	addi	sp,sp,32
    80001da2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001da4:	9e25                	addw	a2,a2,s1
    80001da6:	1602                	slli	a2,a2,0x20
    80001da8:	9201                	srli	a2,a2,0x20
    80001daa:	1582                	slli	a1,a1,0x20
    80001dac:	9181                	srli	a1,a1,0x20
    80001dae:	6928                	ld	a0,80(a0)
    80001db0:	fffff097          	auipc	ra,0xfffff
    80001db4:	70e080e7          	jalr	1806(ra) # 800014be <uvmalloc>
    80001db8:	0005061b          	sext.w	a2,a0
    80001dbc:	fa69                	bnez	a2,80001d8e <growproc+0x26>
      return -1;
    80001dbe:	557d                	li	a0,-1
    80001dc0:	bfe1                	j	80001d98 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dc2:	9e25                	addw	a2,a2,s1
    80001dc4:	1602                	slli	a2,a2,0x20
    80001dc6:	9201                	srli	a2,a2,0x20
    80001dc8:	1582                	slli	a1,a1,0x20
    80001dca:	9181                	srli	a1,a1,0x20
    80001dcc:	6928                	ld	a0,80(a0)
    80001dce:	fffff097          	auipc	ra,0xfffff
    80001dd2:	6a8080e7          	jalr	1704(ra) # 80001476 <uvmdealloc>
    80001dd6:	0005061b          	sext.w	a2,a0
    80001dda:	bf55                	j	80001d8e <growproc+0x26>

0000000080001ddc <fork>:
{
    80001ddc:	7139                	addi	sp,sp,-64
    80001dde:	fc06                	sd	ra,56(sp)
    80001de0:	f822                	sd	s0,48(sp)
    80001de2:	f426                	sd	s1,40(sp)
    80001de4:	f04a                	sd	s2,32(sp)
    80001de6:	ec4e                	sd	s3,24(sp)
    80001de8:	e852                	sd	s4,16(sp)
    80001dea:	e456                	sd	s5,8(sp)
    80001dec:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001dee:	00000097          	auipc	ra,0x0
    80001df2:	c2e080e7          	jalr	-978(ra) # 80001a1c <myproc>
    80001df6:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001df8:	00000097          	auipc	ra,0x0
    80001dfc:	e2e080e7          	jalr	-466(ra) # 80001c26 <allocproc>
    80001e00:	c17d                	beqz	a0,80001ee6 <fork+0x10a>
    80001e02:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e04:	048ab603          	ld	a2,72(s5)
    80001e08:	692c                	ld	a1,80(a0)
    80001e0a:	050ab503          	ld	a0,80(s5)
    80001e0e:	fffff097          	auipc	ra,0xfffff
    80001e12:	7fc080e7          	jalr	2044(ra) # 8000160a <uvmcopy>
    80001e16:	04054a63          	bltz	a0,80001e6a <fork+0x8e>
  np->sz = p->sz;
    80001e1a:	048ab783          	ld	a5,72(s5)
    80001e1e:	04fa3423          	sd	a5,72(s4)
  np->parent = p;
    80001e22:	035a3023          	sd	s5,32(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e26:	058ab683          	ld	a3,88(s5)
    80001e2a:	87b6                	mv	a5,a3
    80001e2c:	058a3703          	ld	a4,88(s4)
    80001e30:	12068693          	addi	a3,a3,288
    80001e34:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e38:	6788                	ld	a0,8(a5)
    80001e3a:	6b8c                	ld	a1,16(a5)
    80001e3c:	6f90                	ld	a2,24(a5)
    80001e3e:	01073023          	sd	a6,0(a4)
    80001e42:	e708                	sd	a0,8(a4)
    80001e44:	eb0c                	sd	a1,16(a4)
    80001e46:	ef10                	sd	a2,24(a4)
    80001e48:	02078793          	addi	a5,a5,32
    80001e4c:	02070713          	addi	a4,a4,32
    80001e50:	fed792e3          	bne	a5,a3,80001e34 <fork+0x58>
  np->trapframe->a0 = 0;
    80001e54:	058a3783          	ld	a5,88(s4)
    80001e58:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e5c:	0d0a8493          	addi	s1,s5,208
    80001e60:	0d0a0913          	addi	s2,s4,208
    80001e64:	150a8993          	addi	s3,s5,336
    80001e68:	a00d                	j	80001e8a <fork+0xae>
    freeproc(np);
    80001e6a:	8552                	mv	a0,s4
    80001e6c:	00000097          	auipc	ra,0x0
    80001e70:	d62080e7          	jalr	-670(ra) # 80001bce <freeproc>
    release(&np->lock);
    80001e74:	8552                	mv	a0,s4
    80001e76:	fffff097          	auipc	ra,0xfffff
    80001e7a:	e8e080e7          	jalr	-370(ra) # 80000d04 <release>
    return -1;
    80001e7e:	54fd                	li	s1,-1
    80001e80:	a889                	j	80001ed2 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
    80001e82:	04a1                	addi	s1,s1,8
    80001e84:	0921                	addi	s2,s2,8
    80001e86:	01348b63          	beq	s1,s3,80001e9c <fork+0xc0>
    if(p->ofile[i])
    80001e8a:	6088                	ld	a0,0(s1)
    80001e8c:	d97d                	beqz	a0,80001e82 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e8e:	00002097          	auipc	ra,0x2
    80001e92:	746080e7          	jalr	1862(ra) # 800045d4 <filedup>
    80001e96:	00a93023          	sd	a0,0(s2)
    80001e9a:	b7e5                	j	80001e82 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001e9c:	150ab503          	ld	a0,336(s5)
    80001ea0:	00002097          	auipc	ra,0x2
    80001ea4:	8b6080e7          	jalr	-1866(ra) # 80003756 <idup>
    80001ea8:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001eac:	4641                	li	a2,16
    80001eae:	158a8593          	addi	a1,s5,344
    80001eb2:	158a0513          	addi	a0,s4,344
    80001eb6:	fffff097          	auipc	ra,0xfffff
    80001eba:	fe8080e7          	jalr	-24(ra) # 80000e9e <safestrcpy>
  pid = np->pid;
    80001ebe:	038a2483          	lw	s1,56(s4)
  np->state = RUNNABLE;
    80001ec2:	4789                	li	a5,2
    80001ec4:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001ec8:	8552                	mv	a0,s4
    80001eca:	fffff097          	auipc	ra,0xfffff
    80001ece:	e3a080e7          	jalr	-454(ra) # 80000d04 <release>
}
    80001ed2:	8526                	mv	a0,s1
    80001ed4:	70e2                	ld	ra,56(sp)
    80001ed6:	7442                	ld	s0,48(sp)
    80001ed8:	74a2                	ld	s1,40(sp)
    80001eda:	7902                	ld	s2,32(sp)
    80001edc:	69e2                	ld	s3,24(sp)
    80001ede:	6a42                	ld	s4,16(sp)
    80001ee0:	6aa2                	ld	s5,8(sp)
    80001ee2:	6121                	addi	sp,sp,64
    80001ee4:	8082                	ret
    return -1;
    80001ee6:	54fd                	li	s1,-1
    80001ee8:	b7ed                	j	80001ed2 <fork+0xf6>

0000000080001eea <reparent>:
{
    80001eea:	7179                	addi	sp,sp,-48
    80001eec:	f406                	sd	ra,40(sp)
    80001eee:	f022                	sd	s0,32(sp)
    80001ef0:	ec26                	sd	s1,24(sp)
    80001ef2:	e84a                	sd	s2,16(sp)
    80001ef4:	e44e                	sd	s3,8(sp)
    80001ef6:	e052                	sd	s4,0(sp)
    80001ef8:	1800                	addi	s0,sp,48
    80001efa:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001efc:	00010497          	auipc	s1,0x10
    80001f00:	e6c48493          	addi	s1,s1,-404 # 80011d68 <proc>
      pp->parent = initproc;
    80001f04:	00007a17          	auipc	s4,0x7
    80001f08:	114a0a13          	addi	s4,s4,276 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f0c:	00016997          	auipc	s3,0x16
    80001f10:	85c98993          	addi	s3,s3,-1956 # 80017768 <tickslock>
    80001f14:	a029                	j	80001f1e <reparent+0x34>
    80001f16:	16848493          	addi	s1,s1,360
    80001f1a:	03348363          	beq	s1,s3,80001f40 <reparent+0x56>
    if(pp->parent == p){
    80001f1e:	709c                	ld	a5,32(s1)
    80001f20:	ff279be3          	bne	a5,s2,80001f16 <reparent+0x2c>
      acquire(&pp->lock);
    80001f24:	8526                	mv	a0,s1
    80001f26:	fffff097          	auipc	ra,0xfffff
    80001f2a:	d2a080e7          	jalr	-726(ra) # 80000c50 <acquire>
      pp->parent = initproc;
    80001f2e:	000a3783          	ld	a5,0(s4)
    80001f32:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001f34:	8526                	mv	a0,s1
    80001f36:	fffff097          	auipc	ra,0xfffff
    80001f3a:	dce080e7          	jalr	-562(ra) # 80000d04 <release>
    80001f3e:	bfe1                	j	80001f16 <reparent+0x2c>
}
    80001f40:	70a2                	ld	ra,40(sp)
    80001f42:	7402                	ld	s0,32(sp)
    80001f44:	64e2                	ld	s1,24(sp)
    80001f46:	6942                	ld	s2,16(sp)
    80001f48:	69a2                	ld	s3,8(sp)
    80001f4a:	6a02                	ld	s4,0(sp)
    80001f4c:	6145                	addi	sp,sp,48
    80001f4e:	8082                	ret

0000000080001f50 <scheduler>:
{
    80001f50:	715d                	addi	sp,sp,-80
    80001f52:	e486                	sd	ra,72(sp)
    80001f54:	e0a2                	sd	s0,64(sp)
    80001f56:	fc26                	sd	s1,56(sp)
    80001f58:	f84a                	sd	s2,48(sp)
    80001f5a:	f44e                	sd	s3,40(sp)
    80001f5c:	f052                	sd	s4,32(sp)
    80001f5e:	ec56                	sd	s5,24(sp)
    80001f60:	e85a                	sd	s6,16(sp)
    80001f62:	e45e                	sd	s7,8(sp)
    80001f64:	e062                	sd	s8,0(sp)
    80001f66:	0880                	addi	s0,sp,80
    80001f68:	8792                	mv	a5,tp
  int id = r_tp();
    80001f6a:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f6c:	00779b13          	slli	s6,a5,0x7
    80001f70:	00010717          	auipc	a4,0x10
    80001f74:	9e070713          	addi	a4,a4,-1568 # 80011950 <pid_lock>
    80001f78:	975a                	add	a4,a4,s6
    80001f7a:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001f7e:	00010717          	auipc	a4,0x10
    80001f82:	9f270713          	addi	a4,a4,-1550 # 80011970 <cpus+0x8>
    80001f86:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001f88:	4c0d                	li	s8,3
        c->proc = p;
    80001f8a:	079e                	slli	a5,a5,0x7
    80001f8c:	00010a17          	auipc	s4,0x10
    80001f90:	9c4a0a13          	addi	s4,s4,-1596 # 80011950 <pid_lock>
    80001f94:	9a3e                	add	s4,s4,a5
        found = 1;
    80001f96:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f98:	00015997          	auipc	s3,0x15
    80001f9c:	7d098993          	addi	s3,s3,2000 # 80017768 <tickslock>
    80001fa0:	a899                	j	80001ff6 <scheduler+0xa6>
      release(&p->lock);
    80001fa2:	8526                	mv	a0,s1
    80001fa4:	fffff097          	auipc	ra,0xfffff
    80001fa8:	d60080e7          	jalr	-672(ra) # 80000d04 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fac:	16848493          	addi	s1,s1,360
    80001fb0:	03348963          	beq	s1,s3,80001fe2 <scheduler+0x92>
      acquire(&p->lock);
    80001fb4:	8526                	mv	a0,s1
    80001fb6:	fffff097          	auipc	ra,0xfffff
    80001fba:	c9a080e7          	jalr	-870(ra) # 80000c50 <acquire>
      if(p->state == RUNNABLE) {
    80001fbe:	4c9c                	lw	a5,24(s1)
    80001fc0:	ff2791e3          	bne	a5,s2,80001fa2 <scheduler+0x52>
        p->state = RUNNING;
    80001fc4:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001fc8:	009a3c23          	sd	s1,24(s4)
        swtch(&c->context, &p->context);
    80001fcc:	06048593          	addi	a1,s1,96
    80001fd0:	855a                	mv	a0,s6
    80001fd2:	00000097          	auipc	ra,0x0
    80001fd6:	640080e7          	jalr	1600(ra) # 80002612 <swtch>
        c->proc = 0;
    80001fda:	000a3c23          	sd	zero,24(s4)
        found = 1;
    80001fde:	8ade                	mv	s5,s7
    80001fe0:	b7c9                	j	80001fa2 <scheduler+0x52>
    if(found == 0) {
    80001fe2:	000a9a63          	bnez	s5,80001ff6 <scheduler+0xa6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001fe6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fea:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fee:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001ff2:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ff6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001ffa:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ffe:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002002:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002004:	00010497          	auipc	s1,0x10
    80002008:	d6448493          	addi	s1,s1,-668 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    8000200c:	4909                	li	s2,2
    8000200e:	b75d                	j	80001fb4 <scheduler+0x64>

0000000080002010 <sched>:
{
    80002010:	7179                	addi	sp,sp,-48
    80002012:	f406                	sd	ra,40(sp)
    80002014:	f022                	sd	s0,32(sp)
    80002016:	ec26                	sd	s1,24(sp)
    80002018:	e84a                	sd	s2,16(sp)
    8000201a:	e44e                	sd	s3,8(sp)
    8000201c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000201e:	00000097          	auipc	ra,0x0
    80002022:	9fe080e7          	jalr	-1538(ra) # 80001a1c <myproc>
    80002026:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002028:	fffff097          	auipc	ra,0xfffff
    8000202c:	bae080e7          	jalr	-1106(ra) # 80000bd6 <holding>
    80002030:	c93d                	beqz	a0,800020a6 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002032:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002034:	2781                	sext.w	a5,a5
    80002036:	079e                	slli	a5,a5,0x7
    80002038:	00010717          	auipc	a4,0x10
    8000203c:	91870713          	addi	a4,a4,-1768 # 80011950 <pid_lock>
    80002040:	97ba                	add	a5,a5,a4
    80002042:	0907a703          	lw	a4,144(a5)
    80002046:	4785                	li	a5,1
    80002048:	06f71763          	bne	a4,a5,800020b6 <sched+0xa6>
  if(p->state == RUNNING)
    8000204c:	4c98                	lw	a4,24(s1)
    8000204e:	478d                	li	a5,3
    80002050:	06f70b63          	beq	a4,a5,800020c6 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002054:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002058:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000205a:	efb5                	bnez	a5,800020d6 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000205c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000205e:	00010917          	auipc	s2,0x10
    80002062:	8f290913          	addi	s2,s2,-1806 # 80011950 <pid_lock>
    80002066:	2781                	sext.w	a5,a5
    80002068:	079e                	slli	a5,a5,0x7
    8000206a:	97ca                	add	a5,a5,s2
    8000206c:	0947a983          	lw	s3,148(a5)
    80002070:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002072:	2781                	sext.w	a5,a5
    80002074:	079e                	slli	a5,a5,0x7
    80002076:	00010597          	auipc	a1,0x10
    8000207a:	8fa58593          	addi	a1,a1,-1798 # 80011970 <cpus+0x8>
    8000207e:	95be                	add	a1,a1,a5
    80002080:	06048513          	addi	a0,s1,96
    80002084:	00000097          	auipc	ra,0x0
    80002088:	58e080e7          	jalr	1422(ra) # 80002612 <swtch>
    8000208c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000208e:	2781                	sext.w	a5,a5
    80002090:	079e                	slli	a5,a5,0x7
    80002092:	97ca                	add	a5,a5,s2
    80002094:	0937aa23          	sw	s3,148(a5)
}
    80002098:	70a2                	ld	ra,40(sp)
    8000209a:	7402                	ld	s0,32(sp)
    8000209c:	64e2                	ld	s1,24(sp)
    8000209e:	6942                	ld	s2,16(sp)
    800020a0:	69a2                	ld	s3,8(sp)
    800020a2:	6145                	addi	sp,sp,48
    800020a4:	8082                	ret
    panic("sched p->lock");
    800020a6:	00006517          	auipc	a0,0x6
    800020aa:	15a50513          	addi	a0,a0,346 # 80008200 <digits+0x1c0>
    800020ae:	ffffe097          	auipc	ra,0xffffe
    800020b2:	494080e7          	jalr	1172(ra) # 80000542 <panic>
    panic("sched locks");
    800020b6:	00006517          	auipc	a0,0x6
    800020ba:	15a50513          	addi	a0,a0,346 # 80008210 <digits+0x1d0>
    800020be:	ffffe097          	auipc	ra,0xffffe
    800020c2:	484080e7          	jalr	1156(ra) # 80000542 <panic>
    panic("sched running");
    800020c6:	00006517          	auipc	a0,0x6
    800020ca:	15a50513          	addi	a0,a0,346 # 80008220 <digits+0x1e0>
    800020ce:	ffffe097          	auipc	ra,0xffffe
    800020d2:	474080e7          	jalr	1140(ra) # 80000542 <panic>
    panic("sched interruptible");
    800020d6:	00006517          	auipc	a0,0x6
    800020da:	15a50513          	addi	a0,a0,346 # 80008230 <digits+0x1f0>
    800020de:	ffffe097          	auipc	ra,0xffffe
    800020e2:	464080e7          	jalr	1124(ra) # 80000542 <panic>

00000000800020e6 <exit>:
{
    800020e6:	7179                	addi	sp,sp,-48
    800020e8:	f406                	sd	ra,40(sp)
    800020ea:	f022                	sd	s0,32(sp)
    800020ec:	ec26                	sd	s1,24(sp)
    800020ee:	e84a                	sd	s2,16(sp)
    800020f0:	e44e                	sd	s3,8(sp)
    800020f2:	e052                	sd	s4,0(sp)
    800020f4:	1800                	addi	s0,sp,48
    800020f6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800020f8:	00000097          	auipc	ra,0x0
    800020fc:	924080e7          	jalr	-1756(ra) # 80001a1c <myproc>
    80002100:	89aa                	mv	s3,a0
  if(p == initproc)
    80002102:	00007797          	auipc	a5,0x7
    80002106:	f167b783          	ld	a5,-234(a5) # 80009018 <initproc>
    8000210a:	0d050493          	addi	s1,a0,208
    8000210e:	15050913          	addi	s2,a0,336
    80002112:	02a79363          	bne	a5,a0,80002138 <exit+0x52>
    panic("init exiting");
    80002116:	00006517          	auipc	a0,0x6
    8000211a:	13250513          	addi	a0,a0,306 # 80008248 <digits+0x208>
    8000211e:	ffffe097          	auipc	ra,0xffffe
    80002122:	424080e7          	jalr	1060(ra) # 80000542 <panic>
      fileclose(f);
    80002126:	00002097          	auipc	ra,0x2
    8000212a:	500080e7          	jalr	1280(ra) # 80004626 <fileclose>
      p->ofile[fd] = 0;
    8000212e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002132:	04a1                	addi	s1,s1,8
    80002134:	01248563          	beq	s1,s2,8000213e <exit+0x58>
    if(p->ofile[fd]){
    80002138:	6088                	ld	a0,0(s1)
    8000213a:	f575                	bnez	a0,80002126 <exit+0x40>
    8000213c:	bfdd                	j	80002132 <exit+0x4c>
  begin_op();
    8000213e:	00002097          	auipc	ra,0x2
    80002142:	016080e7          	jalr	22(ra) # 80004154 <begin_op>
  iput(p->cwd);
    80002146:	1509b503          	ld	a0,336(s3)
    8000214a:	00002097          	auipc	ra,0x2
    8000214e:	804080e7          	jalr	-2044(ra) # 8000394e <iput>
  end_op();
    80002152:	00002097          	auipc	ra,0x2
    80002156:	082080e7          	jalr	130(ra) # 800041d4 <end_op>
  p->cwd = 0;
    8000215a:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    8000215e:	00007497          	auipc	s1,0x7
    80002162:	eba48493          	addi	s1,s1,-326 # 80009018 <initproc>
    80002166:	6088                	ld	a0,0(s1)
    80002168:	fffff097          	auipc	ra,0xfffff
    8000216c:	ae8080e7          	jalr	-1304(ra) # 80000c50 <acquire>
  wakeup1(initproc);
    80002170:	6088                	ld	a0,0(s1)
    80002172:	fffff097          	auipc	ra,0xfffff
    80002176:	76a080e7          	jalr	1898(ra) # 800018dc <wakeup1>
  release(&initproc->lock);
    8000217a:	6088                	ld	a0,0(s1)
    8000217c:	fffff097          	auipc	ra,0xfffff
    80002180:	b88080e7          	jalr	-1144(ra) # 80000d04 <release>
  acquire(&p->lock);
    80002184:	854e                	mv	a0,s3
    80002186:	fffff097          	auipc	ra,0xfffff
    8000218a:	aca080e7          	jalr	-1334(ra) # 80000c50 <acquire>
  struct proc *original_parent = p->parent;
    8000218e:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    80002192:	854e                	mv	a0,s3
    80002194:	fffff097          	auipc	ra,0xfffff
    80002198:	b70080e7          	jalr	-1168(ra) # 80000d04 <release>
  acquire(&original_parent->lock);
    8000219c:	8526                	mv	a0,s1
    8000219e:	fffff097          	auipc	ra,0xfffff
    800021a2:	ab2080e7          	jalr	-1358(ra) # 80000c50 <acquire>
  acquire(&p->lock);
    800021a6:	854e                	mv	a0,s3
    800021a8:	fffff097          	auipc	ra,0xfffff
    800021ac:	aa8080e7          	jalr	-1368(ra) # 80000c50 <acquire>
  reparent(p);
    800021b0:	854e                	mv	a0,s3
    800021b2:	00000097          	auipc	ra,0x0
    800021b6:	d38080e7          	jalr	-712(ra) # 80001eea <reparent>
  wakeup1(original_parent);
    800021ba:	8526                	mv	a0,s1
    800021bc:	fffff097          	auipc	ra,0xfffff
    800021c0:	720080e7          	jalr	1824(ra) # 800018dc <wakeup1>
  p->xstate = status;
    800021c4:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800021c8:	4791                	li	a5,4
    800021ca:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    800021ce:	8526                	mv	a0,s1
    800021d0:	fffff097          	auipc	ra,0xfffff
    800021d4:	b34080e7          	jalr	-1228(ra) # 80000d04 <release>
  sched();
    800021d8:	00000097          	auipc	ra,0x0
    800021dc:	e38080e7          	jalr	-456(ra) # 80002010 <sched>
  panic("zombie exit");
    800021e0:	00006517          	auipc	a0,0x6
    800021e4:	07850513          	addi	a0,a0,120 # 80008258 <digits+0x218>
    800021e8:	ffffe097          	auipc	ra,0xffffe
    800021ec:	35a080e7          	jalr	858(ra) # 80000542 <panic>

00000000800021f0 <yield>:
{
    800021f0:	1101                	addi	sp,sp,-32
    800021f2:	ec06                	sd	ra,24(sp)
    800021f4:	e822                	sd	s0,16(sp)
    800021f6:	e426                	sd	s1,8(sp)
    800021f8:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800021fa:	00000097          	auipc	ra,0x0
    800021fe:	822080e7          	jalr	-2014(ra) # 80001a1c <myproc>
    80002202:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002204:	fffff097          	auipc	ra,0xfffff
    80002208:	a4c080e7          	jalr	-1460(ra) # 80000c50 <acquire>
  p->state = RUNNABLE;
    8000220c:	4789                	li	a5,2
    8000220e:	cc9c                	sw	a5,24(s1)
  sched();
    80002210:	00000097          	auipc	ra,0x0
    80002214:	e00080e7          	jalr	-512(ra) # 80002010 <sched>
  release(&p->lock);
    80002218:	8526                	mv	a0,s1
    8000221a:	fffff097          	auipc	ra,0xfffff
    8000221e:	aea080e7          	jalr	-1302(ra) # 80000d04 <release>
}
    80002222:	60e2                	ld	ra,24(sp)
    80002224:	6442                	ld	s0,16(sp)
    80002226:	64a2                	ld	s1,8(sp)
    80002228:	6105                	addi	sp,sp,32
    8000222a:	8082                	ret

000000008000222c <sleep>:
{
    8000222c:	7179                	addi	sp,sp,-48
    8000222e:	f406                	sd	ra,40(sp)
    80002230:	f022                	sd	s0,32(sp)
    80002232:	ec26                	sd	s1,24(sp)
    80002234:	e84a                	sd	s2,16(sp)
    80002236:	e44e                	sd	s3,8(sp)
    80002238:	1800                	addi	s0,sp,48
    8000223a:	89aa                	mv	s3,a0
    8000223c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000223e:	fffff097          	auipc	ra,0xfffff
    80002242:	7de080e7          	jalr	2014(ra) # 80001a1c <myproc>
    80002246:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80002248:	05250663          	beq	a0,s2,80002294 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000224c:	fffff097          	auipc	ra,0xfffff
    80002250:	a04080e7          	jalr	-1532(ra) # 80000c50 <acquire>
    release(lk);
    80002254:	854a                	mv	a0,s2
    80002256:	fffff097          	auipc	ra,0xfffff
    8000225a:	aae080e7          	jalr	-1362(ra) # 80000d04 <release>
  p->chan = chan;
    8000225e:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002262:	4785                	li	a5,1
    80002264:	cc9c                	sw	a5,24(s1)
  sched();
    80002266:	00000097          	auipc	ra,0x0
    8000226a:	daa080e7          	jalr	-598(ra) # 80002010 <sched>
  p->chan = 0;
    8000226e:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80002272:	8526                	mv	a0,s1
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	a90080e7          	jalr	-1392(ra) # 80000d04 <release>
    acquire(lk);
    8000227c:	854a                	mv	a0,s2
    8000227e:	fffff097          	auipc	ra,0xfffff
    80002282:	9d2080e7          	jalr	-1582(ra) # 80000c50 <acquire>
}
    80002286:	70a2                	ld	ra,40(sp)
    80002288:	7402                	ld	s0,32(sp)
    8000228a:	64e2                	ld	s1,24(sp)
    8000228c:	6942                	ld	s2,16(sp)
    8000228e:	69a2                	ld	s3,8(sp)
    80002290:	6145                	addi	sp,sp,48
    80002292:	8082                	ret
  p->chan = chan;
    80002294:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80002298:	4785                	li	a5,1
    8000229a:	cd1c                	sw	a5,24(a0)
  sched();
    8000229c:	00000097          	auipc	ra,0x0
    800022a0:	d74080e7          	jalr	-652(ra) # 80002010 <sched>
  p->chan = 0;
    800022a4:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    800022a8:	bff9                	j	80002286 <sleep+0x5a>

00000000800022aa <wait>:
{
    800022aa:	715d                	addi	sp,sp,-80
    800022ac:	e486                	sd	ra,72(sp)
    800022ae:	e0a2                	sd	s0,64(sp)
    800022b0:	fc26                	sd	s1,56(sp)
    800022b2:	f84a                	sd	s2,48(sp)
    800022b4:	f44e                	sd	s3,40(sp)
    800022b6:	f052                	sd	s4,32(sp)
    800022b8:	ec56                	sd	s5,24(sp)
    800022ba:	e85a                	sd	s6,16(sp)
    800022bc:	e45e                	sd	s7,8(sp)
    800022be:	0880                	addi	s0,sp,80
    800022c0:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800022c2:	fffff097          	auipc	ra,0xfffff
    800022c6:	75a080e7          	jalr	1882(ra) # 80001a1c <myproc>
    800022ca:	892a                	mv	s2,a0
  acquire(&p->lock);
    800022cc:	fffff097          	auipc	ra,0xfffff
    800022d0:	984080e7          	jalr	-1660(ra) # 80000c50 <acquire>
    havekids = 0;
    800022d4:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    800022d6:	4a11                	li	s4,4
        havekids = 1;
    800022d8:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    800022da:	00015997          	auipc	s3,0x15
    800022de:	48e98993          	addi	s3,s3,1166 # 80017768 <tickslock>
    havekids = 0;
    800022e2:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    800022e4:	00010497          	auipc	s1,0x10
    800022e8:	a8448493          	addi	s1,s1,-1404 # 80011d68 <proc>
    800022ec:	a08d                	j	8000234e <wait+0xa4>
          pid = np->pid;
    800022ee:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800022f2:	000b0e63          	beqz	s6,8000230e <wait+0x64>
    800022f6:	4691                	li	a3,4
    800022f8:	03448613          	addi	a2,s1,52
    800022fc:	85da                	mv	a1,s6
    800022fe:	05093503          	ld	a0,80(s2)
    80002302:	fffff097          	auipc	ra,0xfffff
    80002306:	40c080e7          	jalr	1036(ra) # 8000170e <copyout>
    8000230a:	02054263          	bltz	a0,8000232e <wait+0x84>
          freeproc(np);
    8000230e:	8526                	mv	a0,s1
    80002310:	00000097          	auipc	ra,0x0
    80002314:	8be080e7          	jalr	-1858(ra) # 80001bce <freeproc>
          release(&np->lock);
    80002318:	8526                	mv	a0,s1
    8000231a:	fffff097          	auipc	ra,0xfffff
    8000231e:	9ea080e7          	jalr	-1558(ra) # 80000d04 <release>
          release(&p->lock);
    80002322:	854a                	mv	a0,s2
    80002324:	fffff097          	auipc	ra,0xfffff
    80002328:	9e0080e7          	jalr	-1568(ra) # 80000d04 <release>
          return pid;
    8000232c:	a8a9                	j	80002386 <wait+0xdc>
            release(&np->lock);
    8000232e:	8526                	mv	a0,s1
    80002330:	fffff097          	auipc	ra,0xfffff
    80002334:	9d4080e7          	jalr	-1580(ra) # 80000d04 <release>
            release(&p->lock);
    80002338:	854a                	mv	a0,s2
    8000233a:	fffff097          	auipc	ra,0xfffff
    8000233e:	9ca080e7          	jalr	-1590(ra) # 80000d04 <release>
            return -1;
    80002342:	59fd                	li	s3,-1
    80002344:	a089                	j	80002386 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    80002346:	16848493          	addi	s1,s1,360
    8000234a:	03348463          	beq	s1,s3,80002372 <wait+0xc8>
      if(np->parent == p){
    8000234e:	709c                	ld	a5,32(s1)
    80002350:	ff279be3          	bne	a5,s2,80002346 <wait+0x9c>
        acquire(&np->lock);
    80002354:	8526                	mv	a0,s1
    80002356:	fffff097          	auipc	ra,0xfffff
    8000235a:	8fa080e7          	jalr	-1798(ra) # 80000c50 <acquire>
        if(np->state == ZOMBIE){
    8000235e:	4c9c                	lw	a5,24(s1)
    80002360:	f94787e3          	beq	a5,s4,800022ee <wait+0x44>
        release(&np->lock);
    80002364:	8526                	mv	a0,s1
    80002366:	fffff097          	auipc	ra,0xfffff
    8000236a:	99e080e7          	jalr	-1634(ra) # 80000d04 <release>
        havekids = 1;
    8000236e:	8756                	mv	a4,s5
    80002370:	bfd9                	j	80002346 <wait+0x9c>
    if(!havekids || p->killed){
    80002372:	c701                	beqz	a4,8000237a <wait+0xd0>
    80002374:	03092783          	lw	a5,48(s2)
    80002378:	c39d                	beqz	a5,8000239e <wait+0xf4>
      release(&p->lock);
    8000237a:	854a                	mv	a0,s2
    8000237c:	fffff097          	auipc	ra,0xfffff
    80002380:	988080e7          	jalr	-1656(ra) # 80000d04 <release>
      return -1;
    80002384:	59fd                	li	s3,-1
}
    80002386:	854e                	mv	a0,s3
    80002388:	60a6                	ld	ra,72(sp)
    8000238a:	6406                	ld	s0,64(sp)
    8000238c:	74e2                	ld	s1,56(sp)
    8000238e:	7942                	ld	s2,48(sp)
    80002390:	79a2                	ld	s3,40(sp)
    80002392:	7a02                	ld	s4,32(sp)
    80002394:	6ae2                	ld	s5,24(sp)
    80002396:	6b42                	ld	s6,16(sp)
    80002398:	6ba2                	ld	s7,8(sp)
    8000239a:	6161                	addi	sp,sp,80
    8000239c:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    8000239e:	85ca                	mv	a1,s2
    800023a0:	854a                	mv	a0,s2
    800023a2:	00000097          	auipc	ra,0x0
    800023a6:	e8a080e7          	jalr	-374(ra) # 8000222c <sleep>
    havekids = 0;
    800023aa:	bf25                	j	800022e2 <wait+0x38>

00000000800023ac <wakeup>:
{
    800023ac:	7139                	addi	sp,sp,-64
    800023ae:	fc06                	sd	ra,56(sp)
    800023b0:	f822                	sd	s0,48(sp)
    800023b2:	f426                	sd	s1,40(sp)
    800023b4:	f04a                	sd	s2,32(sp)
    800023b6:	ec4e                	sd	s3,24(sp)
    800023b8:	e852                	sd	s4,16(sp)
    800023ba:	e456                	sd	s5,8(sp)
    800023bc:	0080                	addi	s0,sp,64
    800023be:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800023c0:	00010497          	auipc	s1,0x10
    800023c4:	9a848493          	addi	s1,s1,-1624 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800023c8:	4985                	li	s3,1
      p->state = RUNNABLE;
    800023ca:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800023cc:	00015917          	auipc	s2,0x15
    800023d0:	39c90913          	addi	s2,s2,924 # 80017768 <tickslock>
    800023d4:	a811                	j	800023e8 <wakeup+0x3c>
    release(&p->lock);
    800023d6:	8526                	mv	a0,s1
    800023d8:	fffff097          	auipc	ra,0xfffff
    800023dc:	92c080e7          	jalr	-1748(ra) # 80000d04 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800023e0:	16848493          	addi	s1,s1,360
    800023e4:	03248063          	beq	s1,s2,80002404 <wakeup+0x58>
    acquire(&p->lock);
    800023e8:	8526                	mv	a0,s1
    800023ea:	fffff097          	auipc	ra,0xfffff
    800023ee:	866080e7          	jalr	-1946(ra) # 80000c50 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800023f2:	4c9c                	lw	a5,24(s1)
    800023f4:	ff3791e3          	bne	a5,s3,800023d6 <wakeup+0x2a>
    800023f8:	749c                	ld	a5,40(s1)
    800023fa:	fd479ee3          	bne	a5,s4,800023d6 <wakeup+0x2a>
      p->state = RUNNABLE;
    800023fe:	0154ac23          	sw	s5,24(s1)
    80002402:	bfd1                	j	800023d6 <wakeup+0x2a>
}
    80002404:	70e2                	ld	ra,56(sp)
    80002406:	7442                	ld	s0,48(sp)
    80002408:	74a2                	ld	s1,40(sp)
    8000240a:	7902                	ld	s2,32(sp)
    8000240c:	69e2                	ld	s3,24(sp)
    8000240e:	6a42                	ld	s4,16(sp)
    80002410:	6aa2                	ld	s5,8(sp)
    80002412:	6121                	addi	sp,sp,64
    80002414:	8082                	ret

0000000080002416 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002416:	7179                	addi	sp,sp,-48
    80002418:	f406                	sd	ra,40(sp)
    8000241a:	f022                	sd	s0,32(sp)
    8000241c:	ec26                	sd	s1,24(sp)
    8000241e:	e84a                	sd	s2,16(sp)
    80002420:	e44e                	sd	s3,8(sp)
    80002422:	1800                	addi	s0,sp,48
    80002424:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002426:	00010497          	auipc	s1,0x10
    8000242a:	94248493          	addi	s1,s1,-1726 # 80011d68 <proc>
    8000242e:	00015997          	auipc	s3,0x15
    80002432:	33a98993          	addi	s3,s3,826 # 80017768 <tickslock>
    acquire(&p->lock);
    80002436:	8526                	mv	a0,s1
    80002438:	fffff097          	auipc	ra,0xfffff
    8000243c:	818080e7          	jalr	-2024(ra) # 80000c50 <acquire>
    if(p->pid == pid){
    80002440:	5c9c                	lw	a5,56(s1)
    80002442:	01278d63          	beq	a5,s2,8000245c <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002446:	8526                	mv	a0,s1
    80002448:	fffff097          	auipc	ra,0xfffff
    8000244c:	8bc080e7          	jalr	-1860(ra) # 80000d04 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002450:	16848493          	addi	s1,s1,360
    80002454:	ff3491e3          	bne	s1,s3,80002436 <kill+0x20>
  }
  return -1;
    80002458:	557d                	li	a0,-1
    8000245a:	a821                	j	80002472 <kill+0x5c>
      p->killed = 1;
    8000245c:	4785                	li	a5,1
    8000245e:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80002460:	4c98                	lw	a4,24(s1)
    80002462:	00f70f63          	beq	a4,a5,80002480 <kill+0x6a>
      release(&p->lock);
    80002466:	8526                	mv	a0,s1
    80002468:	fffff097          	auipc	ra,0xfffff
    8000246c:	89c080e7          	jalr	-1892(ra) # 80000d04 <release>
      return 0;
    80002470:	4501                	li	a0,0
}
    80002472:	70a2                	ld	ra,40(sp)
    80002474:	7402                	ld	s0,32(sp)
    80002476:	64e2                	ld	s1,24(sp)
    80002478:	6942                	ld	s2,16(sp)
    8000247a:	69a2                	ld	s3,8(sp)
    8000247c:	6145                	addi	sp,sp,48
    8000247e:	8082                	ret
        p->state = RUNNABLE;
    80002480:	4789                	li	a5,2
    80002482:	cc9c                	sw	a5,24(s1)
    80002484:	b7cd                	j	80002466 <kill+0x50>

0000000080002486 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002486:	7179                	addi	sp,sp,-48
    80002488:	f406                	sd	ra,40(sp)
    8000248a:	f022                	sd	s0,32(sp)
    8000248c:	ec26                	sd	s1,24(sp)
    8000248e:	e84a                	sd	s2,16(sp)
    80002490:	e44e                	sd	s3,8(sp)
    80002492:	e052                	sd	s4,0(sp)
    80002494:	1800                	addi	s0,sp,48
    80002496:	84aa                	mv	s1,a0
    80002498:	892e                	mv	s2,a1
    8000249a:	89b2                	mv	s3,a2
    8000249c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000249e:	fffff097          	auipc	ra,0xfffff
    800024a2:	57e080e7          	jalr	1406(ra) # 80001a1c <myproc>
  if(user_dst){
    800024a6:	c08d                	beqz	s1,800024c8 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800024a8:	86d2                	mv	a3,s4
    800024aa:	864e                	mv	a2,s3
    800024ac:	85ca                	mv	a1,s2
    800024ae:	6928                	ld	a0,80(a0)
    800024b0:	fffff097          	auipc	ra,0xfffff
    800024b4:	25e080e7          	jalr	606(ra) # 8000170e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024b8:	70a2                	ld	ra,40(sp)
    800024ba:	7402                	ld	s0,32(sp)
    800024bc:	64e2                	ld	s1,24(sp)
    800024be:	6942                	ld	s2,16(sp)
    800024c0:	69a2                	ld	s3,8(sp)
    800024c2:	6a02                	ld	s4,0(sp)
    800024c4:	6145                	addi	sp,sp,48
    800024c6:	8082                	ret
    memmove((char *)dst, src, len);
    800024c8:	000a061b          	sext.w	a2,s4
    800024cc:	85ce                	mv	a1,s3
    800024ce:	854a                	mv	a0,s2
    800024d0:	fffff097          	auipc	ra,0xfffff
    800024d4:	8d8080e7          	jalr	-1832(ra) # 80000da8 <memmove>
    return 0;
    800024d8:	8526                	mv	a0,s1
    800024da:	bff9                	j	800024b8 <either_copyout+0x32>

00000000800024dc <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024dc:	7179                	addi	sp,sp,-48
    800024de:	f406                	sd	ra,40(sp)
    800024e0:	f022                	sd	s0,32(sp)
    800024e2:	ec26                	sd	s1,24(sp)
    800024e4:	e84a                	sd	s2,16(sp)
    800024e6:	e44e                	sd	s3,8(sp)
    800024e8:	e052                	sd	s4,0(sp)
    800024ea:	1800                	addi	s0,sp,48
    800024ec:	892a                	mv	s2,a0
    800024ee:	84ae                	mv	s1,a1
    800024f0:	89b2                	mv	s3,a2
    800024f2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024f4:	fffff097          	auipc	ra,0xfffff
    800024f8:	528080e7          	jalr	1320(ra) # 80001a1c <myproc>
  if(user_src){
    800024fc:	c08d                	beqz	s1,8000251e <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024fe:	86d2                	mv	a3,s4
    80002500:	864e                	mv	a2,s3
    80002502:	85ca                	mv	a1,s2
    80002504:	6928                	ld	a0,80(a0)
    80002506:	fffff097          	auipc	ra,0xfffff
    8000250a:	294080e7          	jalr	660(ra) # 8000179a <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000250e:	70a2                	ld	ra,40(sp)
    80002510:	7402                	ld	s0,32(sp)
    80002512:	64e2                	ld	s1,24(sp)
    80002514:	6942                	ld	s2,16(sp)
    80002516:	69a2                	ld	s3,8(sp)
    80002518:	6a02                	ld	s4,0(sp)
    8000251a:	6145                	addi	sp,sp,48
    8000251c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000251e:	000a061b          	sext.w	a2,s4
    80002522:	85ce                	mv	a1,s3
    80002524:	854a                	mv	a0,s2
    80002526:	fffff097          	auipc	ra,0xfffff
    8000252a:	882080e7          	jalr	-1918(ra) # 80000da8 <memmove>
    return 0;
    8000252e:	8526                	mv	a0,s1
    80002530:	bff9                	j	8000250e <either_copyin+0x32>

0000000080002532 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002532:	715d                	addi	sp,sp,-80
    80002534:	e486                	sd	ra,72(sp)
    80002536:	e0a2                	sd	s0,64(sp)
    80002538:	fc26                	sd	s1,56(sp)
    8000253a:	f84a                	sd	s2,48(sp)
    8000253c:	f44e                	sd	s3,40(sp)
    8000253e:	f052                	sd	s4,32(sp)
    80002540:	ec56                	sd	s5,24(sp)
    80002542:	e85a                	sd	s6,16(sp)
    80002544:	e45e                	sd	s7,8(sp)
    80002546:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002548:	00006517          	auipc	a0,0x6
    8000254c:	b8050513          	addi	a0,a0,-1152 # 800080c8 <digits+0x88>
    80002550:	ffffe097          	auipc	ra,0xffffe
    80002554:	03c080e7          	jalr	60(ra) # 8000058c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002558:	00010497          	auipc	s1,0x10
    8000255c:	96848493          	addi	s1,s1,-1688 # 80011ec0 <proc+0x158>
    80002560:	00015917          	auipc	s2,0x15
    80002564:	36090913          	addi	s2,s2,864 # 800178c0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002568:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    8000256a:	00006997          	auipc	s3,0x6
    8000256e:	cfe98993          	addi	s3,s3,-770 # 80008268 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    80002572:	00006a97          	auipc	s5,0x6
    80002576:	cfea8a93          	addi	s5,s5,-770 # 80008270 <digits+0x230>
    printf("\n");
    8000257a:	00006a17          	auipc	s4,0x6
    8000257e:	b4ea0a13          	addi	s4,s4,-1202 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002582:	00006b97          	auipc	s7,0x6
    80002586:	d26b8b93          	addi	s7,s7,-730 # 800082a8 <states.0>
    8000258a:	a00d                	j	800025ac <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000258c:	ee06a583          	lw	a1,-288(a3)
    80002590:	8556                	mv	a0,s5
    80002592:	ffffe097          	auipc	ra,0xffffe
    80002596:	ffa080e7          	jalr	-6(ra) # 8000058c <printf>
    printf("\n");
    8000259a:	8552                	mv	a0,s4
    8000259c:	ffffe097          	auipc	ra,0xffffe
    800025a0:	ff0080e7          	jalr	-16(ra) # 8000058c <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025a4:	16848493          	addi	s1,s1,360
    800025a8:	03248263          	beq	s1,s2,800025cc <procdump+0x9a>
    if(p->state == UNUSED)
    800025ac:	86a6                	mv	a3,s1
    800025ae:	ec04a783          	lw	a5,-320(s1)
    800025b2:	dbed                	beqz	a5,800025a4 <procdump+0x72>
      state = "???";
    800025b4:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025b6:	fcfb6be3          	bltu	s6,a5,8000258c <procdump+0x5a>
    800025ba:	02079713          	slli	a4,a5,0x20
    800025be:	01d75793          	srli	a5,a4,0x1d
    800025c2:	97de                	add	a5,a5,s7
    800025c4:	6390                	ld	a2,0(a5)
    800025c6:	f279                	bnez	a2,8000258c <procdump+0x5a>
      state = "???";
    800025c8:	864e                	mv	a2,s3
    800025ca:	b7c9                	j	8000258c <procdump+0x5a>
  }
}
    800025cc:	60a6                	ld	ra,72(sp)
    800025ce:	6406                	ld	s0,64(sp)
    800025d0:	74e2                	ld	s1,56(sp)
    800025d2:	7942                	ld	s2,48(sp)
    800025d4:	79a2                	ld	s3,40(sp)
    800025d6:	7a02                	ld	s4,32(sp)
    800025d8:	6ae2                	ld	s5,24(sp)
    800025da:	6b42                	ld	s6,16(sp)
    800025dc:	6ba2                	ld	s7,8(sp)
    800025de:	6161                	addi	sp,sp,80
    800025e0:	8082                	ret

00000000800025e2 <countproc>:

int
countproc()
{
    800025e2:	1141                	addi	sp,sp,-16
    800025e4:	e422                	sd	s0,8(sp)
    800025e6:	0800                	addi	s0,sp,16
  uint64 count = 0;
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800025e8:	0000f797          	auipc	a5,0xf
    800025ec:	78078793          	addi	a5,a5,1920 # 80011d68 <proc>
  uint64 count = 0;
    800025f0:	4501                	li	a0,0
  for(p = proc; p < &proc[NPROC]; p++){
    800025f2:	00015697          	auipc	a3,0x15
    800025f6:	17668693          	addi	a3,a3,374 # 80017768 <tickslock>
    if(p->state != UNUSED)
    800025fa:	4f98                	lw	a4,24(a5)
      count++;
    800025fc:	00e03733          	snez	a4,a4
    80002600:	953a                	add	a0,a0,a4
  for(p = proc; p < &proc[NPROC]; p++){
    80002602:	16878793          	addi	a5,a5,360
    80002606:	fed79ae3          	bne	a5,a3,800025fa <countproc+0x18>
  }
  return count;
}
    8000260a:	2501                	sext.w	a0,a0
    8000260c:	6422                	ld	s0,8(sp)
    8000260e:	0141                	addi	sp,sp,16
    80002610:	8082                	ret

0000000080002612 <swtch>:
    80002612:	00153023          	sd	ra,0(a0)
    80002616:	00253423          	sd	sp,8(a0)
    8000261a:	e900                	sd	s0,16(a0)
    8000261c:	ed04                	sd	s1,24(a0)
    8000261e:	03253023          	sd	s2,32(a0)
    80002622:	03353423          	sd	s3,40(a0)
    80002626:	03453823          	sd	s4,48(a0)
    8000262a:	03553c23          	sd	s5,56(a0)
    8000262e:	05653023          	sd	s6,64(a0)
    80002632:	05753423          	sd	s7,72(a0)
    80002636:	05853823          	sd	s8,80(a0)
    8000263a:	05953c23          	sd	s9,88(a0)
    8000263e:	07a53023          	sd	s10,96(a0)
    80002642:	07b53423          	sd	s11,104(a0)
    80002646:	0005b083          	ld	ra,0(a1)
    8000264a:	0085b103          	ld	sp,8(a1)
    8000264e:	6980                	ld	s0,16(a1)
    80002650:	6d84                	ld	s1,24(a1)
    80002652:	0205b903          	ld	s2,32(a1)
    80002656:	0285b983          	ld	s3,40(a1)
    8000265a:	0305ba03          	ld	s4,48(a1)
    8000265e:	0385ba83          	ld	s5,56(a1)
    80002662:	0405bb03          	ld	s6,64(a1)
    80002666:	0485bb83          	ld	s7,72(a1)
    8000266a:	0505bc03          	ld	s8,80(a1)
    8000266e:	0585bc83          	ld	s9,88(a1)
    80002672:	0605bd03          	ld	s10,96(a1)
    80002676:	0685bd83          	ld	s11,104(a1)
    8000267a:	8082                	ret

000000008000267c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000267c:	1141                	addi	sp,sp,-16
    8000267e:	e406                	sd	ra,8(sp)
    80002680:	e022                	sd	s0,0(sp)
    80002682:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002684:	00006597          	auipc	a1,0x6
    80002688:	c4c58593          	addi	a1,a1,-948 # 800082d0 <states.0+0x28>
    8000268c:	00015517          	auipc	a0,0x15
    80002690:	0dc50513          	addi	a0,a0,220 # 80017768 <tickslock>
    80002694:	ffffe097          	auipc	ra,0xffffe
    80002698:	52c080e7          	jalr	1324(ra) # 80000bc0 <initlock>
}
    8000269c:	60a2                	ld	ra,8(sp)
    8000269e:	6402                	ld	s0,0(sp)
    800026a0:	0141                	addi	sp,sp,16
    800026a2:	8082                	ret

00000000800026a4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026a4:	1141                	addi	sp,sp,-16
    800026a6:	e422                	sd	s0,8(sp)
    800026a8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026aa:	00003797          	auipc	a5,0x3
    800026ae:	5d678793          	addi	a5,a5,1494 # 80005c80 <kernelvec>
    800026b2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026b6:	6422                	ld	s0,8(sp)
    800026b8:	0141                	addi	sp,sp,16
    800026ba:	8082                	ret

00000000800026bc <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026bc:	1141                	addi	sp,sp,-16
    800026be:	e406                	sd	ra,8(sp)
    800026c0:	e022                	sd	s0,0(sp)
    800026c2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026c4:	fffff097          	auipc	ra,0xfffff
    800026c8:	358080e7          	jalr	856(ra) # 80001a1c <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026cc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026d0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026d2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    800026d6:	00005617          	auipc	a2,0x5
    800026da:	92a60613          	addi	a2,a2,-1750 # 80007000 <_trampoline>
    800026de:	00005697          	auipc	a3,0x5
    800026e2:	92268693          	addi	a3,a3,-1758 # 80007000 <_trampoline>
    800026e6:	8e91                	sub	a3,a3,a2
    800026e8:	040007b7          	lui	a5,0x4000
    800026ec:	17fd                	addi	a5,a5,-1
    800026ee:	07b2                	slli	a5,a5,0xc
    800026f0:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026f2:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026f6:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026f8:	180026f3          	csrr	a3,satp
    800026fc:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026fe:	6d38                	ld	a4,88(a0)
    80002700:	6134                	ld	a3,64(a0)
    80002702:	6585                	lui	a1,0x1
    80002704:	96ae                	add	a3,a3,a1
    80002706:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002708:	6d38                	ld	a4,88(a0)
    8000270a:	00000697          	auipc	a3,0x0
    8000270e:	13868693          	addi	a3,a3,312 # 80002842 <usertrap>
    80002712:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002714:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002716:	8692                	mv	a3,tp
    80002718:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000271a:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000271e:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002722:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002726:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000272a:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000272c:	6f18                	ld	a4,24(a4)
    8000272e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002732:	692c                	ld	a1,80(a0)
    80002734:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002736:	00005717          	auipc	a4,0x5
    8000273a:	95a70713          	addi	a4,a4,-1702 # 80007090 <userret>
    8000273e:	8f11                	sub	a4,a4,a2
    80002740:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002742:	577d                	li	a4,-1
    80002744:	177e                	slli	a4,a4,0x3f
    80002746:	8dd9                	or	a1,a1,a4
    80002748:	02000537          	lui	a0,0x2000
    8000274c:	157d                	addi	a0,a0,-1
    8000274e:	0536                	slli	a0,a0,0xd
    80002750:	9782                	jalr	a5
}
    80002752:	60a2                	ld	ra,8(sp)
    80002754:	6402                	ld	s0,0(sp)
    80002756:	0141                	addi	sp,sp,16
    80002758:	8082                	ret

000000008000275a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000275a:	1101                	addi	sp,sp,-32
    8000275c:	ec06                	sd	ra,24(sp)
    8000275e:	e822                	sd	s0,16(sp)
    80002760:	e426                	sd	s1,8(sp)
    80002762:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002764:	00015497          	auipc	s1,0x15
    80002768:	00448493          	addi	s1,s1,4 # 80017768 <tickslock>
    8000276c:	8526                	mv	a0,s1
    8000276e:	ffffe097          	auipc	ra,0xffffe
    80002772:	4e2080e7          	jalr	1250(ra) # 80000c50 <acquire>
  ticks++;
    80002776:	00007517          	auipc	a0,0x7
    8000277a:	8aa50513          	addi	a0,a0,-1878 # 80009020 <ticks>
    8000277e:	411c                	lw	a5,0(a0)
    80002780:	2785                	addiw	a5,a5,1
    80002782:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002784:	00000097          	auipc	ra,0x0
    80002788:	c28080e7          	jalr	-984(ra) # 800023ac <wakeup>
  release(&tickslock);
    8000278c:	8526                	mv	a0,s1
    8000278e:	ffffe097          	auipc	ra,0xffffe
    80002792:	576080e7          	jalr	1398(ra) # 80000d04 <release>
}
    80002796:	60e2                	ld	ra,24(sp)
    80002798:	6442                	ld	s0,16(sp)
    8000279a:	64a2                	ld	s1,8(sp)
    8000279c:	6105                	addi	sp,sp,32
    8000279e:	8082                	ret

00000000800027a0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027a0:	1101                	addi	sp,sp,-32
    800027a2:	ec06                	sd	ra,24(sp)
    800027a4:	e822                	sd	s0,16(sp)
    800027a6:	e426                	sd	s1,8(sp)
    800027a8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027aa:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800027ae:	00074d63          	bltz	a4,800027c8 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800027b2:	57fd                	li	a5,-1
    800027b4:	17fe                	slli	a5,a5,0x3f
    800027b6:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027b8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027ba:	06f70363          	beq	a4,a5,80002820 <devintr+0x80>
  }
}
    800027be:	60e2                	ld	ra,24(sp)
    800027c0:	6442                	ld	s0,16(sp)
    800027c2:	64a2                	ld	s1,8(sp)
    800027c4:	6105                	addi	sp,sp,32
    800027c6:	8082                	ret
     (scause & 0xff) == 9){
    800027c8:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    800027cc:	46a5                	li	a3,9
    800027ce:	fed792e3          	bne	a5,a3,800027b2 <devintr+0x12>
    int irq = plic_claim();
    800027d2:	00003097          	auipc	ra,0x3
    800027d6:	5b6080e7          	jalr	1462(ra) # 80005d88 <plic_claim>
    800027da:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027dc:	47a9                	li	a5,10
    800027de:	02f50763          	beq	a0,a5,8000280c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800027e2:	4785                	li	a5,1
    800027e4:	02f50963          	beq	a0,a5,80002816 <devintr+0x76>
    return 1;
    800027e8:	4505                	li	a0,1
    } else if(irq){
    800027ea:	d8f1                	beqz	s1,800027be <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800027ec:	85a6                	mv	a1,s1
    800027ee:	00006517          	auipc	a0,0x6
    800027f2:	aea50513          	addi	a0,a0,-1302 # 800082d8 <states.0+0x30>
    800027f6:	ffffe097          	auipc	ra,0xffffe
    800027fa:	d96080e7          	jalr	-618(ra) # 8000058c <printf>
      plic_complete(irq);
    800027fe:	8526                	mv	a0,s1
    80002800:	00003097          	auipc	ra,0x3
    80002804:	5ac080e7          	jalr	1452(ra) # 80005dac <plic_complete>
    return 1;
    80002808:	4505                	li	a0,1
    8000280a:	bf55                	j	800027be <devintr+0x1e>
      uartintr();
    8000280c:	ffffe097          	auipc	ra,0xffffe
    80002810:	1b6080e7          	jalr	438(ra) # 800009c2 <uartintr>
    80002814:	b7ed                	j	800027fe <devintr+0x5e>
      virtio_disk_intr();
    80002816:	00004097          	auipc	ra,0x4
    8000281a:	a10080e7          	jalr	-1520(ra) # 80006226 <virtio_disk_intr>
    8000281e:	b7c5                	j	800027fe <devintr+0x5e>
    if(cpuid() == 0){
    80002820:	fffff097          	auipc	ra,0xfffff
    80002824:	1d0080e7          	jalr	464(ra) # 800019f0 <cpuid>
    80002828:	c901                	beqz	a0,80002838 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000282a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000282e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002830:	14479073          	csrw	sip,a5
    return 2;
    80002834:	4509                	li	a0,2
    80002836:	b761                	j	800027be <devintr+0x1e>
      clockintr();
    80002838:	00000097          	auipc	ra,0x0
    8000283c:	f22080e7          	jalr	-222(ra) # 8000275a <clockintr>
    80002840:	b7ed                	j	8000282a <devintr+0x8a>

0000000080002842 <usertrap>:
{
    80002842:	1101                	addi	sp,sp,-32
    80002844:	ec06                	sd	ra,24(sp)
    80002846:	e822                	sd	s0,16(sp)
    80002848:	e426                	sd	s1,8(sp)
    8000284a:	e04a                	sd	s2,0(sp)
    8000284c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000284e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002852:	1007f793          	andi	a5,a5,256
    80002856:	e3ad                	bnez	a5,800028b8 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002858:	00003797          	auipc	a5,0x3
    8000285c:	42878793          	addi	a5,a5,1064 # 80005c80 <kernelvec>
    80002860:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002864:	fffff097          	auipc	ra,0xfffff
    80002868:	1b8080e7          	jalr	440(ra) # 80001a1c <myproc>
    8000286c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000286e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002870:	14102773          	csrr	a4,sepc
    80002874:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002876:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000287a:	47a1                	li	a5,8
    8000287c:	04f71c63          	bne	a4,a5,800028d4 <usertrap+0x92>
    if(p->killed)
    80002880:	591c                	lw	a5,48(a0)
    80002882:	e3b9                	bnez	a5,800028c8 <usertrap+0x86>
    p->trapframe->epc += 4;
    80002884:	6cb8                	ld	a4,88(s1)
    80002886:	6f1c                	ld	a5,24(a4)
    80002888:	0791                	addi	a5,a5,4
    8000288a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000288c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002890:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002894:	10079073          	csrw	sstatus,a5
    syscall();
    80002898:	00000097          	auipc	ra,0x0
    8000289c:	2e0080e7          	jalr	736(ra) # 80002b78 <syscall>
  if(p->killed)
    800028a0:	589c                	lw	a5,48(s1)
    800028a2:	ebc1                	bnez	a5,80002932 <usertrap+0xf0>
  usertrapret();
    800028a4:	00000097          	auipc	ra,0x0
    800028a8:	e18080e7          	jalr	-488(ra) # 800026bc <usertrapret>
}
    800028ac:	60e2                	ld	ra,24(sp)
    800028ae:	6442                	ld	s0,16(sp)
    800028b0:	64a2                	ld	s1,8(sp)
    800028b2:	6902                	ld	s2,0(sp)
    800028b4:	6105                	addi	sp,sp,32
    800028b6:	8082                	ret
    panic("usertrap: not from user mode");
    800028b8:	00006517          	auipc	a0,0x6
    800028bc:	a4050513          	addi	a0,a0,-1472 # 800082f8 <states.0+0x50>
    800028c0:	ffffe097          	auipc	ra,0xffffe
    800028c4:	c82080e7          	jalr	-894(ra) # 80000542 <panic>
      exit(-1);
    800028c8:	557d                	li	a0,-1
    800028ca:	00000097          	auipc	ra,0x0
    800028ce:	81c080e7          	jalr	-2020(ra) # 800020e6 <exit>
    800028d2:	bf4d                	j	80002884 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    800028d4:	00000097          	auipc	ra,0x0
    800028d8:	ecc080e7          	jalr	-308(ra) # 800027a0 <devintr>
    800028dc:	892a                	mv	s2,a0
    800028de:	c501                	beqz	a0,800028e6 <usertrap+0xa4>
  if(p->killed)
    800028e0:	589c                	lw	a5,48(s1)
    800028e2:	c3a1                	beqz	a5,80002922 <usertrap+0xe0>
    800028e4:	a815                	j	80002918 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028e6:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028ea:	5c90                	lw	a2,56(s1)
    800028ec:	00006517          	auipc	a0,0x6
    800028f0:	a2c50513          	addi	a0,a0,-1492 # 80008318 <states.0+0x70>
    800028f4:	ffffe097          	auipc	ra,0xffffe
    800028f8:	c98080e7          	jalr	-872(ra) # 8000058c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028fc:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002900:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002904:	00006517          	auipc	a0,0x6
    80002908:	a4450513          	addi	a0,a0,-1468 # 80008348 <states.0+0xa0>
    8000290c:	ffffe097          	auipc	ra,0xffffe
    80002910:	c80080e7          	jalr	-896(ra) # 8000058c <printf>
    p->killed = 1;
    80002914:	4785                	li	a5,1
    80002916:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002918:	557d                	li	a0,-1
    8000291a:	fffff097          	auipc	ra,0xfffff
    8000291e:	7cc080e7          	jalr	1996(ra) # 800020e6 <exit>
  if(which_dev == 2)
    80002922:	4789                	li	a5,2
    80002924:	f8f910e3          	bne	s2,a5,800028a4 <usertrap+0x62>
    yield();
    80002928:	00000097          	auipc	ra,0x0
    8000292c:	8c8080e7          	jalr	-1848(ra) # 800021f0 <yield>
    80002930:	bf95                	j	800028a4 <usertrap+0x62>
  int which_dev = 0;
    80002932:	4901                	li	s2,0
    80002934:	b7d5                	j	80002918 <usertrap+0xd6>

0000000080002936 <kerneltrap>:
{
    80002936:	7179                	addi	sp,sp,-48
    80002938:	f406                	sd	ra,40(sp)
    8000293a:	f022                	sd	s0,32(sp)
    8000293c:	ec26                	sd	s1,24(sp)
    8000293e:	e84a                	sd	s2,16(sp)
    80002940:	e44e                	sd	s3,8(sp)
    80002942:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002944:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002948:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000294c:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002950:	1004f793          	andi	a5,s1,256
    80002954:	cb85                	beqz	a5,80002984 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002956:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000295a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000295c:	ef85                	bnez	a5,80002994 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000295e:	00000097          	auipc	ra,0x0
    80002962:	e42080e7          	jalr	-446(ra) # 800027a0 <devintr>
    80002966:	cd1d                	beqz	a0,800029a4 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002968:	4789                	li	a5,2
    8000296a:	06f50a63          	beq	a0,a5,800029de <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000296e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002972:	10049073          	csrw	sstatus,s1
}
    80002976:	70a2                	ld	ra,40(sp)
    80002978:	7402                	ld	s0,32(sp)
    8000297a:	64e2                	ld	s1,24(sp)
    8000297c:	6942                	ld	s2,16(sp)
    8000297e:	69a2                	ld	s3,8(sp)
    80002980:	6145                	addi	sp,sp,48
    80002982:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002984:	00006517          	auipc	a0,0x6
    80002988:	9e450513          	addi	a0,a0,-1564 # 80008368 <states.0+0xc0>
    8000298c:	ffffe097          	auipc	ra,0xffffe
    80002990:	bb6080e7          	jalr	-1098(ra) # 80000542 <panic>
    panic("kerneltrap: interrupts enabled");
    80002994:	00006517          	auipc	a0,0x6
    80002998:	9fc50513          	addi	a0,a0,-1540 # 80008390 <states.0+0xe8>
    8000299c:	ffffe097          	auipc	ra,0xffffe
    800029a0:	ba6080e7          	jalr	-1114(ra) # 80000542 <panic>
    printf("scause %p\n", scause);
    800029a4:	85ce                	mv	a1,s3
    800029a6:	00006517          	auipc	a0,0x6
    800029aa:	a0a50513          	addi	a0,a0,-1526 # 800083b0 <states.0+0x108>
    800029ae:	ffffe097          	auipc	ra,0xffffe
    800029b2:	bde080e7          	jalr	-1058(ra) # 8000058c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029b6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029ba:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029be:	00006517          	auipc	a0,0x6
    800029c2:	a0250513          	addi	a0,a0,-1534 # 800083c0 <states.0+0x118>
    800029c6:	ffffe097          	auipc	ra,0xffffe
    800029ca:	bc6080e7          	jalr	-1082(ra) # 8000058c <printf>
    panic("kerneltrap");
    800029ce:	00006517          	auipc	a0,0x6
    800029d2:	a0a50513          	addi	a0,a0,-1526 # 800083d8 <states.0+0x130>
    800029d6:	ffffe097          	auipc	ra,0xffffe
    800029da:	b6c080e7          	jalr	-1172(ra) # 80000542 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029de:	fffff097          	auipc	ra,0xfffff
    800029e2:	03e080e7          	jalr	62(ra) # 80001a1c <myproc>
    800029e6:	d541                	beqz	a0,8000296e <kerneltrap+0x38>
    800029e8:	fffff097          	auipc	ra,0xfffff
    800029ec:	034080e7          	jalr	52(ra) # 80001a1c <myproc>
    800029f0:	4d18                	lw	a4,24(a0)
    800029f2:	478d                	li	a5,3
    800029f4:	f6f71de3          	bne	a4,a5,8000296e <kerneltrap+0x38>
    yield();
    800029f8:	fffff097          	auipc	ra,0xfffff
    800029fc:	7f8080e7          	jalr	2040(ra) # 800021f0 <yield>
    80002a00:	b7bd                	j	8000296e <kerneltrap+0x38>

0000000080002a02 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a02:	1101                	addi	sp,sp,-32
    80002a04:	ec06                	sd	ra,24(sp)
    80002a06:	e822                	sd	s0,16(sp)
    80002a08:	e426                	sd	s1,8(sp)
    80002a0a:	1000                	addi	s0,sp,32
    80002a0c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a0e:	fffff097          	auipc	ra,0xfffff
    80002a12:	00e080e7          	jalr	14(ra) # 80001a1c <myproc>
  switch (n) {
    80002a16:	4795                	li	a5,5
    80002a18:	0497e163          	bltu	a5,s1,80002a5a <argraw+0x58>
    80002a1c:	048a                	slli	s1,s1,0x2
    80002a1e:	00006717          	auipc	a4,0x6
    80002a22:	aba70713          	addi	a4,a4,-1350 # 800084d8 <states.0+0x230>
    80002a26:	94ba                	add	s1,s1,a4
    80002a28:	409c                	lw	a5,0(s1)
    80002a2a:	97ba                	add	a5,a5,a4
    80002a2c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002a2e:	6d3c                	ld	a5,88(a0)
    80002a30:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002a32:	60e2                	ld	ra,24(sp)
    80002a34:	6442                	ld	s0,16(sp)
    80002a36:	64a2                	ld	s1,8(sp)
    80002a38:	6105                	addi	sp,sp,32
    80002a3a:	8082                	ret
    return p->trapframe->a1;
    80002a3c:	6d3c                	ld	a5,88(a0)
    80002a3e:	7fa8                	ld	a0,120(a5)
    80002a40:	bfcd                	j	80002a32 <argraw+0x30>
    return p->trapframe->a2;
    80002a42:	6d3c                	ld	a5,88(a0)
    80002a44:	63c8                	ld	a0,128(a5)
    80002a46:	b7f5                	j	80002a32 <argraw+0x30>
    return p->trapframe->a3;
    80002a48:	6d3c                	ld	a5,88(a0)
    80002a4a:	67c8                	ld	a0,136(a5)
    80002a4c:	b7dd                	j	80002a32 <argraw+0x30>
    return p->trapframe->a4;
    80002a4e:	6d3c                	ld	a5,88(a0)
    80002a50:	6bc8                	ld	a0,144(a5)
    80002a52:	b7c5                	j	80002a32 <argraw+0x30>
    return p->trapframe->a5;
    80002a54:	6d3c                	ld	a5,88(a0)
    80002a56:	6fc8                	ld	a0,152(a5)
    80002a58:	bfe9                	j	80002a32 <argraw+0x30>
  panic("argraw");
    80002a5a:	00006517          	auipc	a0,0x6
    80002a5e:	98e50513          	addi	a0,a0,-1650 # 800083e8 <states.0+0x140>
    80002a62:	ffffe097          	auipc	ra,0xffffe
    80002a66:	ae0080e7          	jalr	-1312(ra) # 80000542 <panic>

0000000080002a6a <fetchaddr>:
{
    80002a6a:	1101                	addi	sp,sp,-32
    80002a6c:	ec06                	sd	ra,24(sp)
    80002a6e:	e822                	sd	s0,16(sp)
    80002a70:	e426                	sd	s1,8(sp)
    80002a72:	e04a                	sd	s2,0(sp)
    80002a74:	1000                	addi	s0,sp,32
    80002a76:	84aa                	mv	s1,a0
    80002a78:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a7a:	fffff097          	auipc	ra,0xfffff
    80002a7e:	fa2080e7          	jalr	-94(ra) # 80001a1c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002a82:	653c                	ld	a5,72(a0)
    80002a84:	02f4f863          	bgeu	s1,a5,80002ab4 <fetchaddr+0x4a>
    80002a88:	00848713          	addi	a4,s1,8
    80002a8c:	02e7e663          	bltu	a5,a4,80002ab8 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a90:	46a1                	li	a3,8
    80002a92:	8626                	mv	a2,s1
    80002a94:	85ca                	mv	a1,s2
    80002a96:	6928                	ld	a0,80(a0)
    80002a98:	fffff097          	auipc	ra,0xfffff
    80002a9c:	d02080e7          	jalr	-766(ra) # 8000179a <copyin>
    80002aa0:	00a03533          	snez	a0,a0
    80002aa4:	40a00533          	neg	a0,a0
}
    80002aa8:	60e2                	ld	ra,24(sp)
    80002aaa:	6442                	ld	s0,16(sp)
    80002aac:	64a2                	ld	s1,8(sp)
    80002aae:	6902                	ld	s2,0(sp)
    80002ab0:	6105                	addi	sp,sp,32
    80002ab2:	8082                	ret
    return -1;
    80002ab4:	557d                	li	a0,-1
    80002ab6:	bfcd                	j	80002aa8 <fetchaddr+0x3e>
    80002ab8:	557d                	li	a0,-1
    80002aba:	b7fd                	j	80002aa8 <fetchaddr+0x3e>

0000000080002abc <fetchstr>:
{
    80002abc:	7179                	addi	sp,sp,-48
    80002abe:	f406                	sd	ra,40(sp)
    80002ac0:	f022                	sd	s0,32(sp)
    80002ac2:	ec26                	sd	s1,24(sp)
    80002ac4:	e84a                	sd	s2,16(sp)
    80002ac6:	e44e                	sd	s3,8(sp)
    80002ac8:	1800                	addi	s0,sp,48
    80002aca:	892a                	mv	s2,a0
    80002acc:	84ae                	mv	s1,a1
    80002ace:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ad0:	fffff097          	auipc	ra,0xfffff
    80002ad4:	f4c080e7          	jalr	-180(ra) # 80001a1c <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002ad8:	86ce                	mv	a3,s3
    80002ada:	864a                	mv	a2,s2
    80002adc:	85a6                	mv	a1,s1
    80002ade:	6928                	ld	a0,80(a0)
    80002ae0:	fffff097          	auipc	ra,0xfffff
    80002ae4:	d48080e7          	jalr	-696(ra) # 80001828 <copyinstr>
  if(err < 0)
    80002ae8:	00054763          	bltz	a0,80002af6 <fetchstr+0x3a>
  return strlen(buf);
    80002aec:	8526                	mv	a0,s1
    80002aee:	ffffe097          	auipc	ra,0xffffe
    80002af2:	3e2080e7          	jalr	994(ra) # 80000ed0 <strlen>
}
    80002af6:	70a2                	ld	ra,40(sp)
    80002af8:	7402                	ld	s0,32(sp)
    80002afa:	64e2                	ld	s1,24(sp)
    80002afc:	6942                	ld	s2,16(sp)
    80002afe:	69a2                	ld	s3,8(sp)
    80002b00:	6145                	addi	sp,sp,48
    80002b02:	8082                	ret

0000000080002b04 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002b04:	1101                	addi	sp,sp,-32
    80002b06:	ec06                	sd	ra,24(sp)
    80002b08:	e822                	sd	s0,16(sp)
    80002b0a:	e426                	sd	s1,8(sp)
    80002b0c:	1000                	addi	s0,sp,32
    80002b0e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b10:	00000097          	auipc	ra,0x0
    80002b14:	ef2080e7          	jalr	-270(ra) # 80002a02 <argraw>
    80002b18:	c088                	sw	a0,0(s1)
  return 0;
}
    80002b1a:	4501                	li	a0,0
    80002b1c:	60e2                	ld	ra,24(sp)
    80002b1e:	6442                	ld	s0,16(sp)
    80002b20:	64a2                	ld	s1,8(sp)
    80002b22:	6105                	addi	sp,sp,32
    80002b24:	8082                	ret

0000000080002b26 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002b26:	1101                	addi	sp,sp,-32
    80002b28:	ec06                	sd	ra,24(sp)
    80002b2a:	e822                	sd	s0,16(sp)
    80002b2c:	e426                	sd	s1,8(sp)
    80002b2e:	1000                	addi	s0,sp,32
    80002b30:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b32:	00000097          	auipc	ra,0x0
    80002b36:	ed0080e7          	jalr	-304(ra) # 80002a02 <argraw>
    80002b3a:	e088                	sd	a0,0(s1)
  return 0;
}
    80002b3c:	4501                	li	a0,0
    80002b3e:	60e2                	ld	ra,24(sp)
    80002b40:	6442                	ld	s0,16(sp)
    80002b42:	64a2                	ld	s1,8(sp)
    80002b44:	6105                	addi	sp,sp,32
    80002b46:	8082                	ret

0000000080002b48 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b48:	1101                	addi	sp,sp,-32
    80002b4a:	ec06                	sd	ra,24(sp)
    80002b4c:	e822                	sd	s0,16(sp)
    80002b4e:	e426                	sd	s1,8(sp)
    80002b50:	e04a                	sd	s2,0(sp)
    80002b52:	1000                	addi	s0,sp,32
    80002b54:	84ae                	mv	s1,a1
    80002b56:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002b58:	00000097          	auipc	ra,0x0
    80002b5c:	eaa080e7          	jalr	-342(ra) # 80002a02 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002b60:	864a                	mv	a2,s2
    80002b62:	85a6                	mv	a1,s1
    80002b64:	00000097          	auipc	ra,0x0
    80002b68:	f58080e7          	jalr	-168(ra) # 80002abc <fetchstr>
}
    80002b6c:	60e2                	ld	ra,24(sp)
    80002b6e:	6442                	ld	s0,16(sp)
    80002b70:	64a2                	ld	s1,8(sp)
    80002b72:	6902                	ld	s2,0(sp)
    80002b74:	6105                	addi	sp,sp,32
    80002b76:	8082                	ret

0000000080002b78 <syscall>:
  "sysinfo",
};

void
syscall(void)
{
    80002b78:	7179                	addi	sp,sp,-48
    80002b7a:	f406                	sd	ra,40(sp)
    80002b7c:	f022                	sd	s0,32(sp)
    80002b7e:	ec26                	sd	s1,24(sp)
    80002b80:	e84a                	sd	s2,16(sp)
    80002b82:	e44e                	sd	s3,8(sp)
    80002b84:	1800                	addi	s0,sp,48
  int num;
  int tracemsk;
  struct proc *p = myproc();
    80002b86:	fffff097          	auipc	ra,0xfffff
    80002b8a:	e96080e7          	jalr	-362(ra) # 80001a1c <myproc>
    80002b8e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b90:	05853903          	ld	s2,88(a0)
    80002b94:	0a893783          	ld	a5,168(s2)
    80002b98:	0007899b          	sext.w	s3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b9c:	37fd                	addiw	a5,a5,-1
    80002b9e:	4759                	li	a4,22
    80002ba0:	04f76f63          	bltu	a4,a5,80002bfe <syscall+0x86>
    80002ba4:	00399713          	slli	a4,s3,0x3
    80002ba8:	00006797          	auipc	a5,0x6
    80002bac:	94878793          	addi	a5,a5,-1720 # 800084f0 <syscalls>
    80002bb0:	97ba                	add	a5,a5,a4
    80002bb2:	639c                	ld	a5,0(a5)
    80002bb4:	c7a9                	beqz	a5,80002bfe <syscall+0x86>
    p->trapframe->a0 = syscalls[num]();
    80002bb6:	9782                	jalr	a5
    80002bb8:	06a93823          	sd	a0,112(s2)
    tracemsk = (1 << num) & p->trapframe->t1;  // filters syscalls 
    80002bbc:	6cbc                	ld	a5,88(s1)
    if(p->trapframe->t0 == 1 && tracemsk > 0) {
    80002bbe:	67b4                	ld	a3,72(a5)
    80002bc0:	4705                	li	a4,1
    80002bc2:	04e69d63          	bne	a3,a4,80002c1c <syscall+0xa4>
    tracemsk = (1 << num) & p->trapframe->t1;  // filters syscalls 
    80002bc6:	013716bb          	sllw	a3,a4,s3
    80002bca:	6bb8                	ld	a4,80(a5)
    80002bcc:	8f75                	and	a4,a4,a3
    if(p->trapframe->t0 == 1 && tracemsk > 0) {
    80002bce:	2701                	sext.w	a4,a4
    80002bd0:	04e05663          	blez	a4,80002c1c <syscall+0xa4>
      printf("%d: syscall %s -> %d\n", p->pid, syscallsn[num-1], p->trapframe->a0);
    80002bd4:	39fd                	addiw	s3,s3,-1
    80002bd6:	00399713          	slli	a4,s3,0x3
    80002bda:	00006997          	auipc	s3,0x6
    80002bde:	d4e98993          	addi	s3,s3,-690 # 80008928 <syscallsn>
    80002be2:	99ba                	add	s3,s3,a4
    80002be4:	7bb4                	ld	a3,112(a5)
    80002be6:	0009b603          	ld	a2,0(s3)
    80002bea:	5c8c                	lw	a1,56(s1)
    80002bec:	00006517          	auipc	a0,0x6
    80002bf0:	80450513          	addi	a0,a0,-2044 # 800083f0 <states.0+0x148>
    80002bf4:	ffffe097          	auipc	ra,0xffffe
    80002bf8:	998080e7          	jalr	-1640(ra) # 8000058c <printf>
    80002bfc:	a005                	j	80002c1c <syscall+0xa4>
    }
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002bfe:	86ce                	mv	a3,s3
    80002c00:	15848613          	addi	a2,s1,344
    80002c04:	5c8c                	lw	a1,56(s1)
    80002c06:	00006517          	auipc	a0,0x6
    80002c0a:	80250513          	addi	a0,a0,-2046 # 80008408 <states.0+0x160>
    80002c0e:	ffffe097          	auipc	ra,0xffffe
    80002c12:	97e080e7          	jalr	-1666(ra) # 8000058c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c16:	6cbc                	ld	a5,88(s1)
    80002c18:	577d                	li	a4,-1
    80002c1a:	fbb8                	sd	a4,112(a5)
  }
}
    80002c1c:	70a2                	ld	ra,40(sp)
    80002c1e:	7402                	ld	s0,32(sp)
    80002c20:	64e2                	ld	s1,24(sp)
    80002c22:	6942                	ld	s2,16(sp)
    80002c24:	69a2                	ld	s3,8(sp)
    80002c26:	6145                	addi	sp,sp,48
    80002c28:	8082                	ret

0000000080002c2a <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c2a:	1101                	addi	sp,sp,-32
    80002c2c:	ec06                	sd	ra,24(sp)
    80002c2e:	e822                	sd	s0,16(sp)
    80002c30:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002c32:	fec40593          	addi	a1,s0,-20
    80002c36:	4501                	li	a0,0
    80002c38:	00000097          	auipc	ra,0x0
    80002c3c:	ecc080e7          	jalr	-308(ra) # 80002b04 <argint>
    return -1;
    80002c40:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002c42:	00054963          	bltz	a0,80002c54 <sys_exit+0x2a>
  exit(n);
    80002c46:	fec42503          	lw	a0,-20(s0)
    80002c4a:	fffff097          	auipc	ra,0xfffff
    80002c4e:	49c080e7          	jalr	1180(ra) # 800020e6 <exit>
  return 0;  // not reached
    80002c52:	4781                	li	a5,0
}
    80002c54:	853e                	mv	a0,a5
    80002c56:	60e2                	ld	ra,24(sp)
    80002c58:	6442                	ld	s0,16(sp)
    80002c5a:	6105                	addi	sp,sp,32
    80002c5c:	8082                	ret

0000000080002c5e <sys_getpid>:

uint64
sys_getpid(void)
{
    80002c5e:	1141                	addi	sp,sp,-16
    80002c60:	e406                	sd	ra,8(sp)
    80002c62:	e022                	sd	s0,0(sp)
    80002c64:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002c66:	fffff097          	auipc	ra,0xfffff
    80002c6a:	db6080e7          	jalr	-586(ra) # 80001a1c <myproc>
}
    80002c6e:	5d08                	lw	a0,56(a0)
    80002c70:	60a2                	ld	ra,8(sp)
    80002c72:	6402                	ld	s0,0(sp)
    80002c74:	0141                	addi	sp,sp,16
    80002c76:	8082                	ret

0000000080002c78 <sys_fork>:

uint64
sys_fork(void)
{
    80002c78:	1141                	addi	sp,sp,-16
    80002c7a:	e406                	sd	ra,8(sp)
    80002c7c:	e022                	sd	s0,0(sp)
    80002c7e:	0800                	addi	s0,sp,16
  return fork();
    80002c80:	fffff097          	auipc	ra,0xfffff
    80002c84:	15c080e7          	jalr	348(ra) # 80001ddc <fork>
}
    80002c88:	60a2                	ld	ra,8(sp)
    80002c8a:	6402                	ld	s0,0(sp)
    80002c8c:	0141                	addi	sp,sp,16
    80002c8e:	8082                	ret

0000000080002c90 <sys_wait>:

uint64
sys_wait(void)
{
    80002c90:	1101                	addi	sp,sp,-32
    80002c92:	ec06                	sd	ra,24(sp)
    80002c94:	e822                	sd	s0,16(sp)
    80002c96:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002c98:	fe840593          	addi	a1,s0,-24
    80002c9c:	4501                	li	a0,0
    80002c9e:	00000097          	auipc	ra,0x0
    80002ca2:	e88080e7          	jalr	-376(ra) # 80002b26 <argaddr>
    80002ca6:	87aa                	mv	a5,a0
    return -1;
    80002ca8:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002caa:	0007c863          	bltz	a5,80002cba <sys_wait+0x2a>
  return wait(p);
    80002cae:	fe843503          	ld	a0,-24(s0)
    80002cb2:	fffff097          	auipc	ra,0xfffff
    80002cb6:	5f8080e7          	jalr	1528(ra) # 800022aa <wait>
}
    80002cba:	60e2                	ld	ra,24(sp)
    80002cbc:	6442                	ld	s0,16(sp)
    80002cbe:	6105                	addi	sp,sp,32
    80002cc0:	8082                	ret

0000000080002cc2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cc2:	7179                	addi	sp,sp,-48
    80002cc4:	f406                	sd	ra,40(sp)
    80002cc6:	f022                	sd	s0,32(sp)
    80002cc8:	ec26                	sd	s1,24(sp)
    80002cca:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002ccc:	fdc40593          	addi	a1,s0,-36
    80002cd0:	4501                	li	a0,0
    80002cd2:	00000097          	auipc	ra,0x0
    80002cd6:	e32080e7          	jalr	-462(ra) # 80002b04 <argint>
    return -1;
    80002cda:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002cdc:	00054f63          	bltz	a0,80002cfa <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002ce0:	fffff097          	auipc	ra,0xfffff
    80002ce4:	d3c080e7          	jalr	-708(ra) # 80001a1c <myproc>
    80002ce8:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002cea:	fdc42503          	lw	a0,-36(s0)
    80002cee:	fffff097          	auipc	ra,0xfffff
    80002cf2:	07a080e7          	jalr	122(ra) # 80001d68 <growproc>
    80002cf6:	00054863          	bltz	a0,80002d06 <sys_sbrk+0x44>
    return -1;
  return addr;
}
    80002cfa:	8526                	mv	a0,s1
    80002cfc:	70a2                	ld	ra,40(sp)
    80002cfe:	7402                	ld	s0,32(sp)
    80002d00:	64e2                	ld	s1,24(sp)
    80002d02:	6145                	addi	sp,sp,48
    80002d04:	8082                	ret
    return -1;
    80002d06:	54fd                	li	s1,-1
    80002d08:	bfcd                	j	80002cfa <sys_sbrk+0x38>

0000000080002d0a <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d0a:	7139                	addi	sp,sp,-64
    80002d0c:	fc06                	sd	ra,56(sp)
    80002d0e:	f822                	sd	s0,48(sp)
    80002d10:	f426                	sd	s1,40(sp)
    80002d12:	f04a                	sd	s2,32(sp)
    80002d14:	ec4e                	sd	s3,24(sp)
    80002d16:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80002d18:	fcc40593          	addi	a1,s0,-52
    80002d1c:	4501                	li	a0,0
    80002d1e:	00000097          	auipc	ra,0x0
    80002d22:	de6080e7          	jalr	-538(ra) # 80002b04 <argint>
    return -1;
    80002d26:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d28:	06054563          	bltz	a0,80002d92 <sys_sleep+0x88>
  acquire(&tickslock);
    80002d2c:	00015517          	auipc	a0,0x15
    80002d30:	a3c50513          	addi	a0,a0,-1476 # 80017768 <tickslock>
    80002d34:	ffffe097          	auipc	ra,0xffffe
    80002d38:	f1c080e7          	jalr	-228(ra) # 80000c50 <acquire>
  ticks0 = ticks;
    80002d3c:	00006917          	auipc	s2,0x6
    80002d40:	2e492903          	lw	s2,740(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002d44:	fcc42783          	lw	a5,-52(s0)
    80002d48:	cf85                	beqz	a5,80002d80 <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d4a:	00015997          	auipc	s3,0x15
    80002d4e:	a1e98993          	addi	s3,s3,-1506 # 80017768 <tickslock>
    80002d52:	00006497          	auipc	s1,0x6
    80002d56:	2ce48493          	addi	s1,s1,718 # 80009020 <ticks>
    if(myproc()->killed){
    80002d5a:	fffff097          	auipc	ra,0xfffff
    80002d5e:	cc2080e7          	jalr	-830(ra) # 80001a1c <myproc>
    80002d62:	591c                	lw	a5,48(a0)
    80002d64:	ef9d                	bnez	a5,80002da2 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80002d66:	85ce                	mv	a1,s3
    80002d68:	8526                	mv	a0,s1
    80002d6a:	fffff097          	auipc	ra,0xfffff
    80002d6e:	4c2080e7          	jalr	1218(ra) # 8000222c <sleep>
  while(ticks - ticks0 < n){
    80002d72:	409c                	lw	a5,0(s1)
    80002d74:	412787bb          	subw	a5,a5,s2
    80002d78:	fcc42703          	lw	a4,-52(s0)
    80002d7c:	fce7efe3          	bltu	a5,a4,80002d5a <sys_sleep+0x50>
  }
  release(&tickslock);
    80002d80:	00015517          	auipc	a0,0x15
    80002d84:	9e850513          	addi	a0,a0,-1560 # 80017768 <tickslock>
    80002d88:	ffffe097          	auipc	ra,0xffffe
    80002d8c:	f7c080e7          	jalr	-132(ra) # 80000d04 <release>
  return 0;
    80002d90:	4781                	li	a5,0
}
    80002d92:	853e                	mv	a0,a5
    80002d94:	70e2                	ld	ra,56(sp)
    80002d96:	7442                	ld	s0,48(sp)
    80002d98:	74a2                	ld	s1,40(sp)
    80002d9a:	7902                	ld	s2,32(sp)
    80002d9c:	69e2                	ld	s3,24(sp)
    80002d9e:	6121                	addi	sp,sp,64
    80002da0:	8082                	ret
      release(&tickslock);
    80002da2:	00015517          	auipc	a0,0x15
    80002da6:	9c650513          	addi	a0,a0,-1594 # 80017768 <tickslock>
    80002daa:	ffffe097          	auipc	ra,0xffffe
    80002dae:	f5a080e7          	jalr	-166(ra) # 80000d04 <release>
      return -1;
    80002db2:	57fd                	li	a5,-1
    80002db4:	bff9                	j	80002d92 <sys_sleep+0x88>

0000000080002db6 <sys_kill>:

uint64
sys_kill(void)
{
    80002db6:	1101                	addi	sp,sp,-32
    80002db8:	ec06                	sd	ra,24(sp)
    80002dba:	e822                	sd	s0,16(sp)
    80002dbc:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002dbe:	fec40593          	addi	a1,s0,-20
    80002dc2:	4501                	li	a0,0
    80002dc4:	00000097          	auipc	ra,0x0
    80002dc8:	d40080e7          	jalr	-704(ra) # 80002b04 <argint>
    80002dcc:	87aa                	mv	a5,a0
    return -1;
    80002dce:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002dd0:	0007c863          	bltz	a5,80002de0 <sys_kill+0x2a>
  return kill(pid);
    80002dd4:	fec42503          	lw	a0,-20(s0)
    80002dd8:	fffff097          	auipc	ra,0xfffff
    80002ddc:	63e080e7          	jalr	1598(ra) # 80002416 <kill>
}
    80002de0:	60e2                	ld	ra,24(sp)
    80002de2:	6442                	ld	s0,16(sp)
    80002de4:	6105                	addi	sp,sp,32
    80002de6:	8082                	ret

0000000080002de8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002de8:	1101                	addi	sp,sp,-32
    80002dea:	ec06                	sd	ra,24(sp)
    80002dec:	e822                	sd	s0,16(sp)
    80002dee:	e426                	sd	s1,8(sp)
    80002df0:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002df2:	00015517          	auipc	a0,0x15
    80002df6:	97650513          	addi	a0,a0,-1674 # 80017768 <tickslock>
    80002dfa:	ffffe097          	auipc	ra,0xffffe
    80002dfe:	e56080e7          	jalr	-426(ra) # 80000c50 <acquire>
  xticks = ticks;
    80002e02:	00006497          	auipc	s1,0x6
    80002e06:	21e4a483          	lw	s1,542(s1) # 80009020 <ticks>
  release(&tickslock);
    80002e0a:	00015517          	auipc	a0,0x15
    80002e0e:	95e50513          	addi	a0,a0,-1698 # 80017768 <tickslock>
    80002e12:	ffffe097          	auipc	ra,0xffffe
    80002e16:	ef2080e7          	jalr	-270(ra) # 80000d04 <release>
  return xticks;
}
    80002e1a:	02049513          	slli	a0,s1,0x20
    80002e1e:	9101                	srli	a0,a0,0x20
    80002e20:	60e2                	ld	ra,24(sp)
    80002e22:	6442                	ld	s0,16(sp)
    80002e24:	64a2                	ld	s1,8(sp)
    80002e26:	6105                	addi	sp,sp,32
    80002e28:	8082                	ret

0000000080002e2a <sys_trace>:

uint64
sys_trace(void)
{
    80002e2a:	7179                	addi	sp,sp,-48
    80002e2c:	f406                	sd	ra,40(sp)
    80002e2e:	f022                	sd	s0,32(sp)
    80002e30:	ec26                	sd	s1,24(sp)
    80002e32:	1800                	addi	s0,sp,48
  int n;

  if(argint(0, &n) < 0)
    80002e34:	fdc40593          	addi	a1,s0,-36
    80002e38:	4501                	li	a0,0
    80002e3a:	00000097          	auipc	ra,0x0
    80002e3e:	cca080e7          	jalr	-822(ra) # 80002b04 <argint>
    return -1;
    80002e42:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002e44:	02054263          	bltz	a0,80002e68 <sys_trace+0x3e>

  myproc()->trapframe->t0 = 1;
    80002e48:	fffff097          	auipc	ra,0xfffff
    80002e4c:	bd4080e7          	jalr	-1068(ra) # 80001a1c <myproc>
    80002e50:	6d3c                	ld	a5,88(a0)
    80002e52:	4705                	li	a4,1
    80002e54:	e7b8                	sd	a4,72(a5)
  myproc()->trapframe->t1 = n;
    80002e56:	fdc42483          	lw	s1,-36(s0)
    80002e5a:	fffff097          	auipc	ra,0xfffff
    80002e5e:	bc2080e7          	jalr	-1086(ra) # 80001a1c <myproc>
    80002e62:	6d3c                	ld	a5,88(a0)
    80002e64:	eba4                	sd	s1,80(a5)
  return 0;
    80002e66:	4781                	li	a5,0
}
    80002e68:	853e                	mv	a0,a5
    80002e6a:	70a2                	ld	ra,40(sp)
    80002e6c:	7402                	ld	s0,32(sp)
    80002e6e:	64e2                	ld	s1,24(sp)
    80002e70:	6145                	addi	sp,sp,48
    80002e72:	8082                	ret

0000000080002e74 <sysinfo>:

void
sysinfo(struct sysinfo *si)
{
    80002e74:	1101                	addi	sp,sp,-32
    80002e76:	ec06                	sd	ra,24(sp)
    80002e78:	e822                	sd	s0,16(sp)
    80002e7a:	e426                	sd	s1,8(sp)
    80002e7c:	1000                	addi	s0,sp,32
    80002e7e:	84aa                	mv	s1,a0
  si->nproc = countproc();
    80002e80:	fffff097          	auipc	ra,0xfffff
    80002e84:	762080e7          	jalr	1890(ra) # 800025e2 <countproc>
    80002e88:	e488                	sd	a0,8(s1)
  countfree(&si->freemem);
    80002e8a:	8526                	mv	a0,s1
    80002e8c:	ffffe097          	auipc	ra,0xffffe
    80002e90:	ce2080e7          	jalr	-798(ra) # 80000b6e <countfree>
}
    80002e94:	60e2                	ld	ra,24(sp)
    80002e96:	6442                	ld	s0,16(sp)
    80002e98:	64a2                	ld	s1,8(sp)
    80002e9a:	6105                	addi	sp,sp,32
    80002e9c:	8082                	ret

0000000080002e9e <sys_sysinfo>:


uint64
sys_sysinfo(void)
{
    80002e9e:	7139                	addi	sp,sp,-64
    80002ea0:	fc06                	sd	ra,56(sp)
    80002ea2:	f822                	sd	s0,48(sp)
    80002ea4:	f426                	sd	s1,40(sp)
    80002ea6:	0080                	addi	s0,sp,64
  struct sysinfo si;
  struct proc *p = myproc();
    80002ea8:	fffff097          	auipc	ra,0xfffff
    80002eac:	b74080e7          	jalr	-1164(ra) # 80001a1c <myproc>
    80002eb0:	84aa                	mv	s1,a0
  uint64 addr;

  if(argaddr(0, &addr) < 0)
    80002eb2:	fc840593          	addi	a1,s0,-56
    80002eb6:	4501                	li	a0,0
    80002eb8:	00000097          	auipc	ra,0x0
    80002ebc:	c6e080e7          	jalr	-914(ra) # 80002b26 <argaddr>
    return -1;
    80002ec0:	57fd                	li	a5,-1
  if(argaddr(0, &addr) < 0)
    80002ec2:	02054a63          	bltz	a0,80002ef6 <sys_sysinfo+0x58>

  //countfree(&si->freemem);
  uint64 mem;
  countfree(&mem);
    80002ec6:	fc040513          	addi	a0,s0,-64
    80002eca:	ffffe097          	auipc	ra,0xffffe
    80002ece:	ca4080e7          	jalr	-860(ra) # 80000b6e <countfree>
  
  sysinfo(&si);
    80002ed2:	fd040513          	addi	a0,s0,-48
    80002ed6:	00000097          	auipc	ra,0x0
    80002eda:	f9e080e7          	jalr	-98(ra) # 80002e74 <sysinfo>

  if(copyout(p->pagetable, addr, (char *)&si, sizeof(si)) < 0)
    80002ede:	46c1                	li	a3,16
    80002ee0:	fd040613          	addi	a2,s0,-48
    80002ee4:	fc843583          	ld	a1,-56(s0)
    80002ee8:	68a8                	ld	a0,80(s1)
    80002eea:	fffff097          	auipc	ra,0xfffff
    80002eee:	824080e7          	jalr	-2012(ra) # 8000170e <copyout>
    80002ef2:	43f55793          	srai	a5,a0,0x3f
    return -1;

  return 0;
}
    80002ef6:	853e                	mv	a0,a5
    80002ef8:	70e2                	ld	ra,56(sp)
    80002efa:	7442                	ld	s0,48(sp)
    80002efc:	74a2                	ld	s1,40(sp)
    80002efe:	6121                	addi	sp,sp,64
    80002f00:	8082                	ret

0000000080002f02 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f02:	7179                	addi	sp,sp,-48
    80002f04:	f406                	sd	ra,40(sp)
    80002f06:	f022                	sd	s0,32(sp)
    80002f08:	ec26                	sd	s1,24(sp)
    80002f0a:	e84a                	sd	s2,16(sp)
    80002f0c:	e44e                	sd	s3,8(sp)
    80002f0e:	e052                	sd	s4,0(sp)
    80002f10:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f12:	00005597          	auipc	a1,0x5
    80002f16:	69e58593          	addi	a1,a1,1694 # 800085b0 <syscalls+0xc0>
    80002f1a:	00015517          	auipc	a0,0x15
    80002f1e:	86650513          	addi	a0,a0,-1946 # 80017780 <bcache>
    80002f22:	ffffe097          	auipc	ra,0xffffe
    80002f26:	c9e080e7          	jalr	-866(ra) # 80000bc0 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f2a:	0001d797          	auipc	a5,0x1d
    80002f2e:	85678793          	addi	a5,a5,-1962 # 8001f780 <bcache+0x8000>
    80002f32:	0001d717          	auipc	a4,0x1d
    80002f36:	ab670713          	addi	a4,a4,-1354 # 8001f9e8 <bcache+0x8268>
    80002f3a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f3e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f42:	00015497          	auipc	s1,0x15
    80002f46:	85648493          	addi	s1,s1,-1962 # 80017798 <bcache+0x18>
    b->next = bcache.head.next;
    80002f4a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f4c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f4e:	00005a17          	auipc	s4,0x5
    80002f52:	66aa0a13          	addi	s4,s4,1642 # 800085b8 <syscalls+0xc8>
    b->next = bcache.head.next;
    80002f56:	2b893783          	ld	a5,696(s2)
    80002f5a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f5c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f60:	85d2                	mv	a1,s4
    80002f62:	01048513          	addi	a0,s1,16
    80002f66:	00001097          	auipc	ra,0x1
    80002f6a:	4b2080e7          	jalr	1202(ra) # 80004418 <initsleeplock>
    bcache.head.next->prev = b;
    80002f6e:	2b893783          	ld	a5,696(s2)
    80002f72:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f74:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f78:	45848493          	addi	s1,s1,1112
    80002f7c:	fd349de3          	bne	s1,s3,80002f56 <binit+0x54>
  }
}
    80002f80:	70a2                	ld	ra,40(sp)
    80002f82:	7402                	ld	s0,32(sp)
    80002f84:	64e2                	ld	s1,24(sp)
    80002f86:	6942                	ld	s2,16(sp)
    80002f88:	69a2                	ld	s3,8(sp)
    80002f8a:	6a02                	ld	s4,0(sp)
    80002f8c:	6145                	addi	sp,sp,48
    80002f8e:	8082                	ret

0000000080002f90 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f90:	7179                	addi	sp,sp,-48
    80002f92:	f406                	sd	ra,40(sp)
    80002f94:	f022                	sd	s0,32(sp)
    80002f96:	ec26                	sd	s1,24(sp)
    80002f98:	e84a                	sd	s2,16(sp)
    80002f9a:	e44e                	sd	s3,8(sp)
    80002f9c:	1800                	addi	s0,sp,48
    80002f9e:	892a                	mv	s2,a0
    80002fa0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002fa2:	00014517          	auipc	a0,0x14
    80002fa6:	7de50513          	addi	a0,a0,2014 # 80017780 <bcache>
    80002faa:	ffffe097          	auipc	ra,0xffffe
    80002fae:	ca6080e7          	jalr	-858(ra) # 80000c50 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002fb2:	0001d497          	auipc	s1,0x1d
    80002fb6:	a864b483          	ld	s1,-1402(s1) # 8001fa38 <bcache+0x82b8>
    80002fba:	0001d797          	auipc	a5,0x1d
    80002fbe:	a2e78793          	addi	a5,a5,-1490 # 8001f9e8 <bcache+0x8268>
    80002fc2:	02f48f63          	beq	s1,a5,80003000 <bread+0x70>
    80002fc6:	873e                	mv	a4,a5
    80002fc8:	a021                	j	80002fd0 <bread+0x40>
    80002fca:	68a4                	ld	s1,80(s1)
    80002fcc:	02e48a63          	beq	s1,a4,80003000 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002fd0:	449c                	lw	a5,8(s1)
    80002fd2:	ff279ce3          	bne	a5,s2,80002fca <bread+0x3a>
    80002fd6:	44dc                	lw	a5,12(s1)
    80002fd8:	ff3799e3          	bne	a5,s3,80002fca <bread+0x3a>
      b->refcnt++;
    80002fdc:	40bc                	lw	a5,64(s1)
    80002fde:	2785                	addiw	a5,a5,1
    80002fe0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fe2:	00014517          	auipc	a0,0x14
    80002fe6:	79e50513          	addi	a0,a0,1950 # 80017780 <bcache>
    80002fea:	ffffe097          	auipc	ra,0xffffe
    80002fee:	d1a080e7          	jalr	-742(ra) # 80000d04 <release>
      acquiresleep(&b->lock);
    80002ff2:	01048513          	addi	a0,s1,16
    80002ff6:	00001097          	auipc	ra,0x1
    80002ffa:	45c080e7          	jalr	1116(ra) # 80004452 <acquiresleep>
      return b;
    80002ffe:	a8b9                	j	8000305c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003000:	0001d497          	auipc	s1,0x1d
    80003004:	a304b483          	ld	s1,-1488(s1) # 8001fa30 <bcache+0x82b0>
    80003008:	0001d797          	auipc	a5,0x1d
    8000300c:	9e078793          	addi	a5,a5,-1568 # 8001f9e8 <bcache+0x8268>
    80003010:	00f48863          	beq	s1,a5,80003020 <bread+0x90>
    80003014:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003016:	40bc                	lw	a5,64(s1)
    80003018:	cf81                	beqz	a5,80003030 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000301a:	64a4                	ld	s1,72(s1)
    8000301c:	fee49de3          	bne	s1,a4,80003016 <bread+0x86>
  panic("bget: no buffers");
    80003020:	00005517          	auipc	a0,0x5
    80003024:	5a050513          	addi	a0,a0,1440 # 800085c0 <syscalls+0xd0>
    80003028:	ffffd097          	auipc	ra,0xffffd
    8000302c:	51a080e7          	jalr	1306(ra) # 80000542 <panic>
      b->dev = dev;
    80003030:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003034:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003038:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000303c:	4785                	li	a5,1
    8000303e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003040:	00014517          	auipc	a0,0x14
    80003044:	74050513          	addi	a0,a0,1856 # 80017780 <bcache>
    80003048:	ffffe097          	auipc	ra,0xffffe
    8000304c:	cbc080e7          	jalr	-836(ra) # 80000d04 <release>
      acquiresleep(&b->lock);
    80003050:	01048513          	addi	a0,s1,16
    80003054:	00001097          	auipc	ra,0x1
    80003058:	3fe080e7          	jalr	1022(ra) # 80004452 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000305c:	409c                	lw	a5,0(s1)
    8000305e:	cb89                	beqz	a5,80003070 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003060:	8526                	mv	a0,s1
    80003062:	70a2                	ld	ra,40(sp)
    80003064:	7402                	ld	s0,32(sp)
    80003066:	64e2                	ld	s1,24(sp)
    80003068:	6942                	ld	s2,16(sp)
    8000306a:	69a2                	ld	s3,8(sp)
    8000306c:	6145                	addi	sp,sp,48
    8000306e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003070:	4581                	li	a1,0
    80003072:	8526                	mv	a0,s1
    80003074:	00003097          	auipc	ra,0x3
    80003078:	f28080e7          	jalr	-216(ra) # 80005f9c <virtio_disk_rw>
    b->valid = 1;
    8000307c:	4785                	li	a5,1
    8000307e:	c09c                	sw	a5,0(s1)
  return b;
    80003080:	b7c5                	j	80003060 <bread+0xd0>

0000000080003082 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003082:	1101                	addi	sp,sp,-32
    80003084:	ec06                	sd	ra,24(sp)
    80003086:	e822                	sd	s0,16(sp)
    80003088:	e426                	sd	s1,8(sp)
    8000308a:	1000                	addi	s0,sp,32
    8000308c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000308e:	0541                	addi	a0,a0,16
    80003090:	00001097          	auipc	ra,0x1
    80003094:	45c080e7          	jalr	1116(ra) # 800044ec <holdingsleep>
    80003098:	cd01                	beqz	a0,800030b0 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000309a:	4585                	li	a1,1
    8000309c:	8526                	mv	a0,s1
    8000309e:	00003097          	auipc	ra,0x3
    800030a2:	efe080e7          	jalr	-258(ra) # 80005f9c <virtio_disk_rw>
}
    800030a6:	60e2                	ld	ra,24(sp)
    800030a8:	6442                	ld	s0,16(sp)
    800030aa:	64a2                	ld	s1,8(sp)
    800030ac:	6105                	addi	sp,sp,32
    800030ae:	8082                	ret
    panic("bwrite");
    800030b0:	00005517          	auipc	a0,0x5
    800030b4:	52850513          	addi	a0,a0,1320 # 800085d8 <syscalls+0xe8>
    800030b8:	ffffd097          	auipc	ra,0xffffd
    800030bc:	48a080e7          	jalr	1162(ra) # 80000542 <panic>

00000000800030c0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800030c0:	1101                	addi	sp,sp,-32
    800030c2:	ec06                	sd	ra,24(sp)
    800030c4:	e822                	sd	s0,16(sp)
    800030c6:	e426                	sd	s1,8(sp)
    800030c8:	e04a                	sd	s2,0(sp)
    800030ca:	1000                	addi	s0,sp,32
    800030cc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030ce:	01050913          	addi	s2,a0,16
    800030d2:	854a                	mv	a0,s2
    800030d4:	00001097          	auipc	ra,0x1
    800030d8:	418080e7          	jalr	1048(ra) # 800044ec <holdingsleep>
    800030dc:	c92d                	beqz	a0,8000314e <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800030de:	854a                	mv	a0,s2
    800030e0:	00001097          	auipc	ra,0x1
    800030e4:	3c8080e7          	jalr	968(ra) # 800044a8 <releasesleep>

  acquire(&bcache.lock);
    800030e8:	00014517          	auipc	a0,0x14
    800030ec:	69850513          	addi	a0,a0,1688 # 80017780 <bcache>
    800030f0:	ffffe097          	auipc	ra,0xffffe
    800030f4:	b60080e7          	jalr	-1184(ra) # 80000c50 <acquire>
  b->refcnt--;
    800030f8:	40bc                	lw	a5,64(s1)
    800030fa:	37fd                	addiw	a5,a5,-1
    800030fc:	0007871b          	sext.w	a4,a5
    80003100:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003102:	eb05                	bnez	a4,80003132 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003104:	68bc                	ld	a5,80(s1)
    80003106:	64b8                	ld	a4,72(s1)
    80003108:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    8000310a:	64bc                	ld	a5,72(s1)
    8000310c:	68b8                	ld	a4,80(s1)
    8000310e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003110:	0001c797          	auipc	a5,0x1c
    80003114:	67078793          	addi	a5,a5,1648 # 8001f780 <bcache+0x8000>
    80003118:	2b87b703          	ld	a4,696(a5)
    8000311c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000311e:	0001d717          	auipc	a4,0x1d
    80003122:	8ca70713          	addi	a4,a4,-1846 # 8001f9e8 <bcache+0x8268>
    80003126:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003128:	2b87b703          	ld	a4,696(a5)
    8000312c:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000312e:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003132:	00014517          	auipc	a0,0x14
    80003136:	64e50513          	addi	a0,a0,1614 # 80017780 <bcache>
    8000313a:	ffffe097          	auipc	ra,0xffffe
    8000313e:	bca080e7          	jalr	-1078(ra) # 80000d04 <release>
}
    80003142:	60e2                	ld	ra,24(sp)
    80003144:	6442                	ld	s0,16(sp)
    80003146:	64a2                	ld	s1,8(sp)
    80003148:	6902                	ld	s2,0(sp)
    8000314a:	6105                	addi	sp,sp,32
    8000314c:	8082                	ret
    panic("brelse");
    8000314e:	00005517          	auipc	a0,0x5
    80003152:	49250513          	addi	a0,a0,1170 # 800085e0 <syscalls+0xf0>
    80003156:	ffffd097          	auipc	ra,0xffffd
    8000315a:	3ec080e7          	jalr	1004(ra) # 80000542 <panic>

000000008000315e <bpin>:

void
bpin(struct buf *b) {
    8000315e:	1101                	addi	sp,sp,-32
    80003160:	ec06                	sd	ra,24(sp)
    80003162:	e822                	sd	s0,16(sp)
    80003164:	e426                	sd	s1,8(sp)
    80003166:	1000                	addi	s0,sp,32
    80003168:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000316a:	00014517          	auipc	a0,0x14
    8000316e:	61650513          	addi	a0,a0,1558 # 80017780 <bcache>
    80003172:	ffffe097          	auipc	ra,0xffffe
    80003176:	ade080e7          	jalr	-1314(ra) # 80000c50 <acquire>
  b->refcnt++;
    8000317a:	40bc                	lw	a5,64(s1)
    8000317c:	2785                	addiw	a5,a5,1
    8000317e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003180:	00014517          	auipc	a0,0x14
    80003184:	60050513          	addi	a0,a0,1536 # 80017780 <bcache>
    80003188:	ffffe097          	auipc	ra,0xffffe
    8000318c:	b7c080e7          	jalr	-1156(ra) # 80000d04 <release>
}
    80003190:	60e2                	ld	ra,24(sp)
    80003192:	6442                	ld	s0,16(sp)
    80003194:	64a2                	ld	s1,8(sp)
    80003196:	6105                	addi	sp,sp,32
    80003198:	8082                	ret

000000008000319a <bunpin>:

void
bunpin(struct buf *b) {
    8000319a:	1101                	addi	sp,sp,-32
    8000319c:	ec06                	sd	ra,24(sp)
    8000319e:	e822                	sd	s0,16(sp)
    800031a0:	e426                	sd	s1,8(sp)
    800031a2:	1000                	addi	s0,sp,32
    800031a4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031a6:	00014517          	auipc	a0,0x14
    800031aa:	5da50513          	addi	a0,a0,1498 # 80017780 <bcache>
    800031ae:	ffffe097          	auipc	ra,0xffffe
    800031b2:	aa2080e7          	jalr	-1374(ra) # 80000c50 <acquire>
  b->refcnt--;
    800031b6:	40bc                	lw	a5,64(s1)
    800031b8:	37fd                	addiw	a5,a5,-1
    800031ba:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031bc:	00014517          	auipc	a0,0x14
    800031c0:	5c450513          	addi	a0,a0,1476 # 80017780 <bcache>
    800031c4:	ffffe097          	auipc	ra,0xffffe
    800031c8:	b40080e7          	jalr	-1216(ra) # 80000d04 <release>
}
    800031cc:	60e2                	ld	ra,24(sp)
    800031ce:	6442                	ld	s0,16(sp)
    800031d0:	64a2                	ld	s1,8(sp)
    800031d2:	6105                	addi	sp,sp,32
    800031d4:	8082                	ret

00000000800031d6 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800031d6:	1101                	addi	sp,sp,-32
    800031d8:	ec06                	sd	ra,24(sp)
    800031da:	e822                	sd	s0,16(sp)
    800031dc:	e426                	sd	s1,8(sp)
    800031de:	e04a                	sd	s2,0(sp)
    800031e0:	1000                	addi	s0,sp,32
    800031e2:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800031e4:	00d5d59b          	srliw	a1,a1,0xd
    800031e8:	0001d797          	auipc	a5,0x1d
    800031ec:	c747a783          	lw	a5,-908(a5) # 8001fe5c <sb+0x1c>
    800031f0:	9dbd                	addw	a1,a1,a5
    800031f2:	00000097          	auipc	ra,0x0
    800031f6:	d9e080e7          	jalr	-610(ra) # 80002f90 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800031fa:	0074f713          	andi	a4,s1,7
    800031fe:	4785                	li	a5,1
    80003200:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003204:	14ce                	slli	s1,s1,0x33
    80003206:	90d9                	srli	s1,s1,0x36
    80003208:	00950733          	add	a4,a0,s1
    8000320c:	05874703          	lbu	a4,88(a4)
    80003210:	00e7f6b3          	and	a3,a5,a4
    80003214:	c69d                	beqz	a3,80003242 <bfree+0x6c>
    80003216:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003218:	94aa                	add	s1,s1,a0
    8000321a:	fff7c793          	not	a5,a5
    8000321e:	8ff9                	and	a5,a5,a4
    80003220:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80003224:	00001097          	auipc	ra,0x1
    80003228:	106080e7          	jalr	262(ra) # 8000432a <log_write>
  brelse(bp);
    8000322c:	854a                	mv	a0,s2
    8000322e:	00000097          	auipc	ra,0x0
    80003232:	e92080e7          	jalr	-366(ra) # 800030c0 <brelse>
}
    80003236:	60e2                	ld	ra,24(sp)
    80003238:	6442                	ld	s0,16(sp)
    8000323a:	64a2                	ld	s1,8(sp)
    8000323c:	6902                	ld	s2,0(sp)
    8000323e:	6105                	addi	sp,sp,32
    80003240:	8082                	ret
    panic("freeing free block");
    80003242:	00005517          	auipc	a0,0x5
    80003246:	3a650513          	addi	a0,a0,934 # 800085e8 <syscalls+0xf8>
    8000324a:	ffffd097          	auipc	ra,0xffffd
    8000324e:	2f8080e7          	jalr	760(ra) # 80000542 <panic>

0000000080003252 <balloc>:
{
    80003252:	711d                	addi	sp,sp,-96
    80003254:	ec86                	sd	ra,88(sp)
    80003256:	e8a2                	sd	s0,80(sp)
    80003258:	e4a6                	sd	s1,72(sp)
    8000325a:	e0ca                	sd	s2,64(sp)
    8000325c:	fc4e                	sd	s3,56(sp)
    8000325e:	f852                	sd	s4,48(sp)
    80003260:	f456                	sd	s5,40(sp)
    80003262:	f05a                	sd	s6,32(sp)
    80003264:	ec5e                	sd	s7,24(sp)
    80003266:	e862                	sd	s8,16(sp)
    80003268:	e466                	sd	s9,8(sp)
    8000326a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000326c:	0001d797          	auipc	a5,0x1d
    80003270:	bd87a783          	lw	a5,-1064(a5) # 8001fe44 <sb+0x4>
    80003274:	cbd1                	beqz	a5,80003308 <balloc+0xb6>
    80003276:	8baa                	mv	s7,a0
    80003278:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000327a:	0001db17          	auipc	s6,0x1d
    8000327e:	bc6b0b13          	addi	s6,s6,-1082 # 8001fe40 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003282:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003284:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003286:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003288:	6c89                	lui	s9,0x2
    8000328a:	a831                	j	800032a6 <balloc+0x54>
    brelse(bp);
    8000328c:	854a                	mv	a0,s2
    8000328e:	00000097          	auipc	ra,0x0
    80003292:	e32080e7          	jalr	-462(ra) # 800030c0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003296:	015c87bb          	addw	a5,s9,s5
    8000329a:	00078a9b          	sext.w	s5,a5
    8000329e:	004b2703          	lw	a4,4(s6)
    800032a2:	06eaf363          	bgeu	s5,a4,80003308 <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800032a6:	41fad79b          	sraiw	a5,s5,0x1f
    800032aa:	0137d79b          	srliw	a5,a5,0x13
    800032ae:	015787bb          	addw	a5,a5,s5
    800032b2:	40d7d79b          	sraiw	a5,a5,0xd
    800032b6:	01cb2583          	lw	a1,28(s6)
    800032ba:	9dbd                	addw	a1,a1,a5
    800032bc:	855e                	mv	a0,s7
    800032be:	00000097          	auipc	ra,0x0
    800032c2:	cd2080e7          	jalr	-814(ra) # 80002f90 <bread>
    800032c6:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032c8:	004b2503          	lw	a0,4(s6)
    800032cc:	000a849b          	sext.w	s1,s5
    800032d0:	8662                	mv	a2,s8
    800032d2:	faa4fde3          	bgeu	s1,a0,8000328c <balloc+0x3a>
      m = 1 << (bi % 8);
    800032d6:	41f6579b          	sraiw	a5,a2,0x1f
    800032da:	01d7d69b          	srliw	a3,a5,0x1d
    800032de:	00c6873b          	addw	a4,a3,a2
    800032e2:	00777793          	andi	a5,a4,7
    800032e6:	9f95                	subw	a5,a5,a3
    800032e8:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800032ec:	4037571b          	sraiw	a4,a4,0x3
    800032f0:	00e906b3          	add	a3,s2,a4
    800032f4:	0586c683          	lbu	a3,88(a3)
    800032f8:	00d7f5b3          	and	a1,a5,a3
    800032fc:	cd91                	beqz	a1,80003318 <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032fe:	2605                	addiw	a2,a2,1
    80003300:	2485                	addiw	s1,s1,1
    80003302:	fd4618e3          	bne	a2,s4,800032d2 <balloc+0x80>
    80003306:	b759                	j	8000328c <balloc+0x3a>
  panic("balloc: out of blocks");
    80003308:	00005517          	auipc	a0,0x5
    8000330c:	2f850513          	addi	a0,a0,760 # 80008600 <syscalls+0x110>
    80003310:	ffffd097          	auipc	ra,0xffffd
    80003314:	232080e7          	jalr	562(ra) # 80000542 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003318:	974a                	add	a4,a4,s2
    8000331a:	8fd5                	or	a5,a5,a3
    8000331c:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003320:	854a                	mv	a0,s2
    80003322:	00001097          	auipc	ra,0x1
    80003326:	008080e7          	jalr	8(ra) # 8000432a <log_write>
        brelse(bp);
    8000332a:	854a                	mv	a0,s2
    8000332c:	00000097          	auipc	ra,0x0
    80003330:	d94080e7          	jalr	-620(ra) # 800030c0 <brelse>
  bp = bread(dev, bno);
    80003334:	85a6                	mv	a1,s1
    80003336:	855e                	mv	a0,s7
    80003338:	00000097          	auipc	ra,0x0
    8000333c:	c58080e7          	jalr	-936(ra) # 80002f90 <bread>
    80003340:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003342:	40000613          	li	a2,1024
    80003346:	4581                	li	a1,0
    80003348:	05850513          	addi	a0,a0,88
    8000334c:	ffffe097          	auipc	ra,0xffffe
    80003350:	a00080e7          	jalr	-1536(ra) # 80000d4c <memset>
  log_write(bp);
    80003354:	854a                	mv	a0,s2
    80003356:	00001097          	auipc	ra,0x1
    8000335a:	fd4080e7          	jalr	-44(ra) # 8000432a <log_write>
  brelse(bp);
    8000335e:	854a                	mv	a0,s2
    80003360:	00000097          	auipc	ra,0x0
    80003364:	d60080e7          	jalr	-672(ra) # 800030c0 <brelse>
}
    80003368:	8526                	mv	a0,s1
    8000336a:	60e6                	ld	ra,88(sp)
    8000336c:	6446                	ld	s0,80(sp)
    8000336e:	64a6                	ld	s1,72(sp)
    80003370:	6906                	ld	s2,64(sp)
    80003372:	79e2                	ld	s3,56(sp)
    80003374:	7a42                	ld	s4,48(sp)
    80003376:	7aa2                	ld	s5,40(sp)
    80003378:	7b02                	ld	s6,32(sp)
    8000337a:	6be2                	ld	s7,24(sp)
    8000337c:	6c42                	ld	s8,16(sp)
    8000337e:	6ca2                	ld	s9,8(sp)
    80003380:	6125                	addi	sp,sp,96
    80003382:	8082                	ret

0000000080003384 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    80003384:	7179                	addi	sp,sp,-48
    80003386:	f406                	sd	ra,40(sp)
    80003388:	f022                	sd	s0,32(sp)
    8000338a:	ec26                	sd	s1,24(sp)
    8000338c:	e84a                	sd	s2,16(sp)
    8000338e:	e44e                	sd	s3,8(sp)
    80003390:	e052                	sd	s4,0(sp)
    80003392:	1800                	addi	s0,sp,48
    80003394:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003396:	47ad                	li	a5,11
    80003398:	04b7fe63          	bgeu	a5,a1,800033f4 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    8000339c:	ff45849b          	addiw	s1,a1,-12
    800033a0:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800033a4:	0ff00793          	li	a5,255
    800033a8:	0ae7e463          	bltu	a5,a4,80003450 <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800033ac:	08052583          	lw	a1,128(a0)
    800033b0:	c5b5                	beqz	a1,8000341c <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800033b2:	00092503          	lw	a0,0(s2)
    800033b6:	00000097          	auipc	ra,0x0
    800033ba:	bda080e7          	jalr	-1062(ra) # 80002f90 <bread>
    800033be:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800033c0:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800033c4:	02049713          	slli	a4,s1,0x20
    800033c8:	01e75593          	srli	a1,a4,0x1e
    800033cc:	00b784b3          	add	s1,a5,a1
    800033d0:	0004a983          	lw	s3,0(s1)
    800033d4:	04098e63          	beqz	s3,80003430 <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    800033d8:	8552                	mv	a0,s4
    800033da:	00000097          	auipc	ra,0x0
    800033de:	ce6080e7          	jalr	-794(ra) # 800030c0 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800033e2:	854e                	mv	a0,s3
    800033e4:	70a2                	ld	ra,40(sp)
    800033e6:	7402                	ld	s0,32(sp)
    800033e8:	64e2                	ld	s1,24(sp)
    800033ea:	6942                	ld	s2,16(sp)
    800033ec:	69a2                	ld	s3,8(sp)
    800033ee:	6a02                	ld	s4,0(sp)
    800033f0:	6145                	addi	sp,sp,48
    800033f2:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    800033f4:	02059793          	slli	a5,a1,0x20
    800033f8:	01e7d593          	srli	a1,a5,0x1e
    800033fc:	00b504b3          	add	s1,a0,a1
    80003400:	0504a983          	lw	s3,80(s1)
    80003404:	fc099fe3          	bnez	s3,800033e2 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003408:	4108                	lw	a0,0(a0)
    8000340a:	00000097          	auipc	ra,0x0
    8000340e:	e48080e7          	jalr	-440(ra) # 80003252 <balloc>
    80003412:	0005099b          	sext.w	s3,a0
    80003416:	0534a823          	sw	s3,80(s1)
    8000341a:	b7e1                	j	800033e2 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    8000341c:	4108                	lw	a0,0(a0)
    8000341e:	00000097          	auipc	ra,0x0
    80003422:	e34080e7          	jalr	-460(ra) # 80003252 <balloc>
    80003426:	0005059b          	sext.w	a1,a0
    8000342a:	08b92023          	sw	a1,128(s2)
    8000342e:	b751                	j	800033b2 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003430:	00092503          	lw	a0,0(s2)
    80003434:	00000097          	auipc	ra,0x0
    80003438:	e1e080e7          	jalr	-482(ra) # 80003252 <balloc>
    8000343c:	0005099b          	sext.w	s3,a0
    80003440:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003444:	8552                	mv	a0,s4
    80003446:	00001097          	auipc	ra,0x1
    8000344a:	ee4080e7          	jalr	-284(ra) # 8000432a <log_write>
    8000344e:	b769                	j	800033d8 <bmap+0x54>
  panic("bmap: out of range");
    80003450:	00005517          	auipc	a0,0x5
    80003454:	1c850513          	addi	a0,a0,456 # 80008618 <syscalls+0x128>
    80003458:	ffffd097          	auipc	ra,0xffffd
    8000345c:	0ea080e7          	jalr	234(ra) # 80000542 <panic>

0000000080003460 <iget>:
{
    80003460:	7179                	addi	sp,sp,-48
    80003462:	f406                	sd	ra,40(sp)
    80003464:	f022                	sd	s0,32(sp)
    80003466:	ec26                	sd	s1,24(sp)
    80003468:	e84a                	sd	s2,16(sp)
    8000346a:	e44e                	sd	s3,8(sp)
    8000346c:	e052                	sd	s4,0(sp)
    8000346e:	1800                	addi	s0,sp,48
    80003470:	89aa                	mv	s3,a0
    80003472:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    80003474:	0001d517          	auipc	a0,0x1d
    80003478:	9ec50513          	addi	a0,a0,-1556 # 8001fe60 <icache>
    8000347c:	ffffd097          	auipc	ra,0xffffd
    80003480:	7d4080e7          	jalr	2004(ra) # 80000c50 <acquire>
  empty = 0;
    80003484:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    80003486:	0001d497          	auipc	s1,0x1d
    8000348a:	9f248493          	addi	s1,s1,-1550 # 8001fe78 <icache+0x18>
    8000348e:	0001e697          	auipc	a3,0x1e
    80003492:	47a68693          	addi	a3,a3,1146 # 80021908 <log>
    80003496:	a039                	j	800034a4 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003498:	02090b63          	beqz	s2,800034ce <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    8000349c:	08848493          	addi	s1,s1,136
    800034a0:	02d48a63          	beq	s1,a3,800034d4 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800034a4:	449c                	lw	a5,8(s1)
    800034a6:	fef059e3          	blez	a5,80003498 <iget+0x38>
    800034aa:	4098                	lw	a4,0(s1)
    800034ac:	ff3716e3          	bne	a4,s3,80003498 <iget+0x38>
    800034b0:	40d8                	lw	a4,4(s1)
    800034b2:	ff4713e3          	bne	a4,s4,80003498 <iget+0x38>
      ip->ref++;
    800034b6:	2785                	addiw	a5,a5,1
    800034b8:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800034ba:	0001d517          	auipc	a0,0x1d
    800034be:	9a650513          	addi	a0,a0,-1626 # 8001fe60 <icache>
    800034c2:	ffffe097          	auipc	ra,0xffffe
    800034c6:	842080e7          	jalr	-1982(ra) # 80000d04 <release>
      return ip;
    800034ca:	8926                	mv	s2,s1
    800034cc:	a03d                	j	800034fa <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034ce:	f7f9                	bnez	a5,8000349c <iget+0x3c>
    800034d0:	8926                	mv	s2,s1
    800034d2:	b7e9                	j	8000349c <iget+0x3c>
  if(empty == 0)
    800034d4:	02090c63          	beqz	s2,8000350c <iget+0xac>
  ip->dev = dev;
    800034d8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800034dc:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800034e0:	4785                	li	a5,1
    800034e2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800034e6:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    800034ea:	0001d517          	auipc	a0,0x1d
    800034ee:	97650513          	addi	a0,a0,-1674 # 8001fe60 <icache>
    800034f2:	ffffe097          	auipc	ra,0xffffe
    800034f6:	812080e7          	jalr	-2030(ra) # 80000d04 <release>
}
    800034fa:	854a                	mv	a0,s2
    800034fc:	70a2                	ld	ra,40(sp)
    800034fe:	7402                	ld	s0,32(sp)
    80003500:	64e2                	ld	s1,24(sp)
    80003502:	6942                	ld	s2,16(sp)
    80003504:	69a2                	ld	s3,8(sp)
    80003506:	6a02                	ld	s4,0(sp)
    80003508:	6145                	addi	sp,sp,48
    8000350a:	8082                	ret
    panic("iget: no inodes");
    8000350c:	00005517          	auipc	a0,0x5
    80003510:	12450513          	addi	a0,a0,292 # 80008630 <syscalls+0x140>
    80003514:	ffffd097          	auipc	ra,0xffffd
    80003518:	02e080e7          	jalr	46(ra) # 80000542 <panic>

000000008000351c <fsinit>:
fsinit(int dev) {
    8000351c:	7179                	addi	sp,sp,-48
    8000351e:	f406                	sd	ra,40(sp)
    80003520:	f022                	sd	s0,32(sp)
    80003522:	ec26                	sd	s1,24(sp)
    80003524:	e84a                	sd	s2,16(sp)
    80003526:	e44e                	sd	s3,8(sp)
    80003528:	1800                	addi	s0,sp,48
    8000352a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000352c:	4585                	li	a1,1
    8000352e:	00000097          	auipc	ra,0x0
    80003532:	a62080e7          	jalr	-1438(ra) # 80002f90 <bread>
    80003536:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003538:	0001d997          	auipc	s3,0x1d
    8000353c:	90898993          	addi	s3,s3,-1784 # 8001fe40 <sb>
    80003540:	02000613          	li	a2,32
    80003544:	05850593          	addi	a1,a0,88
    80003548:	854e                	mv	a0,s3
    8000354a:	ffffe097          	auipc	ra,0xffffe
    8000354e:	85e080e7          	jalr	-1954(ra) # 80000da8 <memmove>
  brelse(bp);
    80003552:	8526                	mv	a0,s1
    80003554:	00000097          	auipc	ra,0x0
    80003558:	b6c080e7          	jalr	-1172(ra) # 800030c0 <brelse>
  if(sb.magic != FSMAGIC)
    8000355c:	0009a703          	lw	a4,0(s3)
    80003560:	102037b7          	lui	a5,0x10203
    80003564:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003568:	02f71263          	bne	a4,a5,8000358c <fsinit+0x70>
  initlog(dev, &sb);
    8000356c:	0001d597          	auipc	a1,0x1d
    80003570:	8d458593          	addi	a1,a1,-1836 # 8001fe40 <sb>
    80003574:	854a                	mv	a0,s2
    80003576:	00001097          	auipc	ra,0x1
    8000357a:	b3a080e7          	jalr	-1222(ra) # 800040b0 <initlog>
}
    8000357e:	70a2                	ld	ra,40(sp)
    80003580:	7402                	ld	s0,32(sp)
    80003582:	64e2                	ld	s1,24(sp)
    80003584:	6942                	ld	s2,16(sp)
    80003586:	69a2                	ld	s3,8(sp)
    80003588:	6145                	addi	sp,sp,48
    8000358a:	8082                	ret
    panic("invalid file system");
    8000358c:	00005517          	auipc	a0,0x5
    80003590:	0b450513          	addi	a0,a0,180 # 80008640 <syscalls+0x150>
    80003594:	ffffd097          	auipc	ra,0xffffd
    80003598:	fae080e7          	jalr	-82(ra) # 80000542 <panic>

000000008000359c <iinit>:
{
    8000359c:	7179                	addi	sp,sp,-48
    8000359e:	f406                	sd	ra,40(sp)
    800035a0:	f022                	sd	s0,32(sp)
    800035a2:	ec26                	sd	s1,24(sp)
    800035a4:	e84a                	sd	s2,16(sp)
    800035a6:	e44e                	sd	s3,8(sp)
    800035a8:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800035aa:	00005597          	auipc	a1,0x5
    800035ae:	0ae58593          	addi	a1,a1,174 # 80008658 <syscalls+0x168>
    800035b2:	0001d517          	auipc	a0,0x1d
    800035b6:	8ae50513          	addi	a0,a0,-1874 # 8001fe60 <icache>
    800035ba:	ffffd097          	auipc	ra,0xffffd
    800035be:	606080e7          	jalr	1542(ra) # 80000bc0 <initlock>
  for(i = 0; i < NINODE; i++) {
    800035c2:	0001d497          	auipc	s1,0x1d
    800035c6:	8c648493          	addi	s1,s1,-1850 # 8001fe88 <icache+0x28>
    800035ca:	0001e997          	auipc	s3,0x1e
    800035ce:	34e98993          	addi	s3,s3,846 # 80021918 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800035d2:	00005917          	auipc	s2,0x5
    800035d6:	08e90913          	addi	s2,s2,142 # 80008660 <syscalls+0x170>
    800035da:	85ca                	mv	a1,s2
    800035dc:	8526                	mv	a0,s1
    800035de:	00001097          	auipc	ra,0x1
    800035e2:	e3a080e7          	jalr	-454(ra) # 80004418 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800035e6:	08848493          	addi	s1,s1,136
    800035ea:	ff3498e3          	bne	s1,s3,800035da <iinit+0x3e>
}
    800035ee:	70a2                	ld	ra,40(sp)
    800035f0:	7402                	ld	s0,32(sp)
    800035f2:	64e2                	ld	s1,24(sp)
    800035f4:	6942                	ld	s2,16(sp)
    800035f6:	69a2                	ld	s3,8(sp)
    800035f8:	6145                	addi	sp,sp,48
    800035fa:	8082                	ret

00000000800035fc <ialloc>:
{
    800035fc:	715d                	addi	sp,sp,-80
    800035fe:	e486                	sd	ra,72(sp)
    80003600:	e0a2                	sd	s0,64(sp)
    80003602:	fc26                	sd	s1,56(sp)
    80003604:	f84a                	sd	s2,48(sp)
    80003606:	f44e                	sd	s3,40(sp)
    80003608:	f052                	sd	s4,32(sp)
    8000360a:	ec56                	sd	s5,24(sp)
    8000360c:	e85a                	sd	s6,16(sp)
    8000360e:	e45e                	sd	s7,8(sp)
    80003610:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003612:	0001d717          	auipc	a4,0x1d
    80003616:	83a72703          	lw	a4,-1990(a4) # 8001fe4c <sb+0xc>
    8000361a:	4785                	li	a5,1
    8000361c:	04e7fa63          	bgeu	a5,a4,80003670 <ialloc+0x74>
    80003620:	8aaa                	mv	s5,a0
    80003622:	8bae                	mv	s7,a1
    80003624:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003626:	0001da17          	auipc	s4,0x1d
    8000362a:	81aa0a13          	addi	s4,s4,-2022 # 8001fe40 <sb>
    8000362e:	00048b1b          	sext.w	s6,s1
    80003632:	0044d793          	srli	a5,s1,0x4
    80003636:	018a2583          	lw	a1,24(s4)
    8000363a:	9dbd                	addw	a1,a1,a5
    8000363c:	8556                	mv	a0,s5
    8000363e:	00000097          	auipc	ra,0x0
    80003642:	952080e7          	jalr	-1710(ra) # 80002f90 <bread>
    80003646:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003648:	05850993          	addi	s3,a0,88
    8000364c:	00f4f793          	andi	a5,s1,15
    80003650:	079a                	slli	a5,a5,0x6
    80003652:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003654:	00099783          	lh	a5,0(s3)
    80003658:	c785                	beqz	a5,80003680 <ialloc+0x84>
    brelse(bp);
    8000365a:	00000097          	auipc	ra,0x0
    8000365e:	a66080e7          	jalr	-1434(ra) # 800030c0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003662:	0485                	addi	s1,s1,1
    80003664:	00ca2703          	lw	a4,12(s4)
    80003668:	0004879b          	sext.w	a5,s1
    8000366c:	fce7e1e3          	bltu	a5,a4,8000362e <ialloc+0x32>
  panic("ialloc: no inodes");
    80003670:	00005517          	auipc	a0,0x5
    80003674:	ff850513          	addi	a0,a0,-8 # 80008668 <syscalls+0x178>
    80003678:	ffffd097          	auipc	ra,0xffffd
    8000367c:	eca080e7          	jalr	-310(ra) # 80000542 <panic>
      memset(dip, 0, sizeof(*dip));
    80003680:	04000613          	li	a2,64
    80003684:	4581                	li	a1,0
    80003686:	854e                	mv	a0,s3
    80003688:	ffffd097          	auipc	ra,0xffffd
    8000368c:	6c4080e7          	jalr	1732(ra) # 80000d4c <memset>
      dip->type = type;
    80003690:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003694:	854a                	mv	a0,s2
    80003696:	00001097          	auipc	ra,0x1
    8000369a:	c94080e7          	jalr	-876(ra) # 8000432a <log_write>
      brelse(bp);
    8000369e:	854a                	mv	a0,s2
    800036a0:	00000097          	auipc	ra,0x0
    800036a4:	a20080e7          	jalr	-1504(ra) # 800030c0 <brelse>
      return iget(dev, inum);
    800036a8:	85da                	mv	a1,s6
    800036aa:	8556                	mv	a0,s5
    800036ac:	00000097          	auipc	ra,0x0
    800036b0:	db4080e7          	jalr	-588(ra) # 80003460 <iget>
}
    800036b4:	60a6                	ld	ra,72(sp)
    800036b6:	6406                	ld	s0,64(sp)
    800036b8:	74e2                	ld	s1,56(sp)
    800036ba:	7942                	ld	s2,48(sp)
    800036bc:	79a2                	ld	s3,40(sp)
    800036be:	7a02                	ld	s4,32(sp)
    800036c0:	6ae2                	ld	s5,24(sp)
    800036c2:	6b42                	ld	s6,16(sp)
    800036c4:	6ba2                	ld	s7,8(sp)
    800036c6:	6161                	addi	sp,sp,80
    800036c8:	8082                	ret

00000000800036ca <iupdate>:
{
    800036ca:	1101                	addi	sp,sp,-32
    800036cc:	ec06                	sd	ra,24(sp)
    800036ce:	e822                	sd	s0,16(sp)
    800036d0:	e426                	sd	s1,8(sp)
    800036d2:	e04a                	sd	s2,0(sp)
    800036d4:	1000                	addi	s0,sp,32
    800036d6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036d8:	415c                	lw	a5,4(a0)
    800036da:	0047d79b          	srliw	a5,a5,0x4
    800036de:	0001c597          	auipc	a1,0x1c
    800036e2:	77a5a583          	lw	a1,1914(a1) # 8001fe58 <sb+0x18>
    800036e6:	9dbd                	addw	a1,a1,a5
    800036e8:	4108                	lw	a0,0(a0)
    800036ea:	00000097          	auipc	ra,0x0
    800036ee:	8a6080e7          	jalr	-1882(ra) # 80002f90 <bread>
    800036f2:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800036f4:	05850793          	addi	a5,a0,88
    800036f8:	40c8                	lw	a0,4(s1)
    800036fa:	893d                	andi	a0,a0,15
    800036fc:	051a                	slli	a0,a0,0x6
    800036fe:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003700:	04449703          	lh	a4,68(s1)
    80003704:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003708:	04649703          	lh	a4,70(s1)
    8000370c:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003710:	04849703          	lh	a4,72(s1)
    80003714:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003718:	04a49703          	lh	a4,74(s1)
    8000371c:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003720:	44f8                	lw	a4,76(s1)
    80003722:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003724:	03400613          	li	a2,52
    80003728:	05048593          	addi	a1,s1,80
    8000372c:	0531                	addi	a0,a0,12
    8000372e:	ffffd097          	auipc	ra,0xffffd
    80003732:	67a080e7          	jalr	1658(ra) # 80000da8 <memmove>
  log_write(bp);
    80003736:	854a                	mv	a0,s2
    80003738:	00001097          	auipc	ra,0x1
    8000373c:	bf2080e7          	jalr	-1038(ra) # 8000432a <log_write>
  brelse(bp);
    80003740:	854a                	mv	a0,s2
    80003742:	00000097          	auipc	ra,0x0
    80003746:	97e080e7          	jalr	-1666(ra) # 800030c0 <brelse>
}
    8000374a:	60e2                	ld	ra,24(sp)
    8000374c:	6442                	ld	s0,16(sp)
    8000374e:	64a2                	ld	s1,8(sp)
    80003750:	6902                	ld	s2,0(sp)
    80003752:	6105                	addi	sp,sp,32
    80003754:	8082                	ret

0000000080003756 <idup>:
{
    80003756:	1101                	addi	sp,sp,-32
    80003758:	ec06                	sd	ra,24(sp)
    8000375a:	e822                	sd	s0,16(sp)
    8000375c:	e426                	sd	s1,8(sp)
    8000375e:	1000                	addi	s0,sp,32
    80003760:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80003762:	0001c517          	auipc	a0,0x1c
    80003766:	6fe50513          	addi	a0,a0,1790 # 8001fe60 <icache>
    8000376a:	ffffd097          	auipc	ra,0xffffd
    8000376e:	4e6080e7          	jalr	1254(ra) # 80000c50 <acquire>
  ip->ref++;
    80003772:	449c                	lw	a5,8(s1)
    80003774:	2785                	addiw	a5,a5,1
    80003776:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80003778:	0001c517          	auipc	a0,0x1c
    8000377c:	6e850513          	addi	a0,a0,1768 # 8001fe60 <icache>
    80003780:	ffffd097          	auipc	ra,0xffffd
    80003784:	584080e7          	jalr	1412(ra) # 80000d04 <release>
}
    80003788:	8526                	mv	a0,s1
    8000378a:	60e2                	ld	ra,24(sp)
    8000378c:	6442                	ld	s0,16(sp)
    8000378e:	64a2                	ld	s1,8(sp)
    80003790:	6105                	addi	sp,sp,32
    80003792:	8082                	ret

0000000080003794 <ilock>:
{
    80003794:	1101                	addi	sp,sp,-32
    80003796:	ec06                	sd	ra,24(sp)
    80003798:	e822                	sd	s0,16(sp)
    8000379a:	e426                	sd	s1,8(sp)
    8000379c:	e04a                	sd	s2,0(sp)
    8000379e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800037a0:	c115                	beqz	a0,800037c4 <ilock+0x30>
    800037a2:	84aa                	mv	s1,a0
    800037a4:	451c                	lw	a5,8(a0)
    800037a6:	00f05f63          	blez	a5,800037c4 <ilock+0x30>
  acquiresleep(&ip->lock);
    800037aa:	0541                	addi	a0,a0,16
    800037ac:	00001097          	auipc	ra,0x1
    800037b0:	ca6080e7          	jalr	-858(ra) # 80004452 <acquiresleep>
  if(ip->valid == 0){
    800037b4:	40bc                	lw	a5,64(s1)
    800037b6:	cf99                	beqz	a5,800037d4 <ilock+0x40>
}
    800037b8:	60e2                	ld	ra,24(sp)
    800037ba:	6442                	ld	s0,16(sp)
    800037bc:	64a2                	ld	s1,8(sp)
    800037be:	6902                	ld	s2,0(sp)
    800037c0:	6105                	addi	sp,sp,32
    800037c2:	8082                	ret
    panic("ilock");
    800037c4:	00005517          	auipc	a0,0x5
    800037c8:	ebc50513          	addi	a0,a0,-324 # 80008680 <syscalls+0x190>
    800037cc:	ffffd097          	auipc	ra,0xffffd
    800037d0:	d76080e7          	jalr	-650(ra) # 80000542 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037d4:	40dc                	lw	a5,4(s1)
    800037d6:	0047d79b          	srliw	a5,a5,0x4
    800037da:	0001c597          	auipc	a1,0x1c
    800037de:	67e5a583          	lw	a1,1662(a1) # 8001fe58 <sb+0x18>
    800037e2:	9dbd                	addw	a1,a1,a5
    800037e4:	4088                	lw	a0,0(s1)
    800037e6:	fffff097          	auipc	ra,0xfffff
    800037ea:	7aa080e7          	jalr	1962(ra) # 80002f90 <bread>
    800037ee:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037f0:	05850593          	addi	a1,a0,88
    800037f4:	40dc                	lw	a5,4(s1)
    800037f6:	8bbd                	andi	a5,a5,15
    800037f8:	079a                	slli	a5,a5,0x6
    800037fa:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037fc:	00059783          	lh	a5,0(a1)
    80003800:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003804:	00259783          	lh	a5,2(a1)
    80003808:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000380c:	00459783          	lh	a5,4(a1)
    80003810:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003814:	00659783          	lh	a5,6(a1)
    80003818:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000381c:	459c                	lw	a5,8(a1)
    8000381e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003820:	03400613          	li	a2,52
    80003824:	05b1                	addi	a1,a1,12
    80003826:	05048513          	addi	a0,s1,80
    8000382a:	ffffd097          	auipc	ra,0xffffd
    8000382e:	57e080e7          	jalr	1406(ra) # 80000da8 <memmove>
    brelse(bp);
    80003832:	854a                	mv	a0,s2
    80003834:	00000097          	auipc	ra,0x0
    80003838:	88c080e7          	jalr	-1908(ra) # 800030c0 <brelse>
    ip->valid = 1;
    8000383c:	4785                	li	a5,1
    8000383e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003840:	04449783          	lh	a5,68(s1)
    80003844:	fbb5                	bnez	a5,800037b8 <ilock+0x24>
      panic("ilock: no type");
    80003846:	00005517          	auipc	a0,0x5
    8000384a:	e4250513          	addi	a0,a0,-446 # 80008688 <syscalls+0x198>
    8000384e:	ffffd097          	auipc	ra,0xffffd
    80003852:	cf4080e7          	jalr	-780(ra) # 80000542 <panic>

0000000080003856 <iunlock>:
{
    80003856:	1101                	addi	sp,sp,-32
    80003858:	ec06                	sd	ra,24(sp)
    8000385a:	e822                	sd	s0,16(sp)
    8000385c:	e426                	sd	s1,8(sp)
    8000385e:	e04a                	sd	s2,0(sp)
    80003860:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003862:	c905                	beqz	a0,80003892 <iunlock+0x3c>
    80003864:	84aa                	mv	s1,a0
    80003866:	01050913          	addi	s2,a0,16
    8000386a:	854a                	mv	a0,s2
    8000386c:	00001097          	auipc	ra,0x1
    80003870:	c80080e7          	jalr	-896(ra) # 800044ec <holdingsleep>
    80003874:	cd19                	beqz	a0,80003892 <iunlock+0x3c>
    80003876:	449c                	lw	a5,8(s1)
    80003878:	00f05d63          	blez	a5,80003892 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000387c:	854a                	mv	a0,s2
    8000387e:	00001097          	auipc	ra,0x1
    80003882:	c2a080e7          	jalr	-982(ra) # 800044a8 <releasesleep>
}
    80003886:	60e2                	ld	ra,24(sp)
    80003888:	6442                	ld	s0,16(sp)
    8000388a:	64a2                	ld	s1,8(sp)
    8000388c:	6902                	ld	s2,0(sp)
    8000388e:	6105                	addi	sp,sp,32
    80003890:	8082                	ret
    panic("iunlock");
    80003892:	00005517          	auipc	a0,0x5
    80003896:	e0650513          	addi	a0,a0,-506 # 80008698 <syscalls+0x1a8>
    8000389a:	ffffd097          	auipc	ra,0xffffd
    8000389e:	ca8080e7          	jalr	-856(ra) # 80000542 <panic>

00000000800038a2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800038a2:	7179                	addi	sp,sp,-48
    800038a4:	f406                	sd	ra,40(sp)
    800038a6:	f022                	sd	s0,32(sp)
    800038a8:	ec26                	sd	s1,24(sp)
    800038aa:	e84a                	sd	s2,16(sp)
    800038ac:	e44e                	sd	s3,8(sp)
    800038ae:	e052                	sd	s4,0(sp)
    800038b0:	1800                	addi	s0,sp,48
    800038b2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800038b4:	05050493          	addi	s1,a0,80
    800038b8:	08050913          	addi	s2,a0,128
    800038bc:	a021                	j	800038c4 <itrunc+0x22>
    800038be:	0491                	addi	s1,s1,4
    800038c0:	01248d63          	beq	s1,s2,800038da <itrunc+0x38>
    if(ip->addrs[i]){
    800038c4:	408c                	lw	a1,0(s1)
    800038c6:	dde5                	beqz	a1,800038be <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800038c8:	0009a503          	lw	a0,0(s3)
    800038cc:	00000097          	auipc	ra,0x0
    800038d0:	90a080e7          	jalr	-1782(ra) # 800031d6 <bfree>
      ip->addrs[i] = 0;
    800038d4:	0004a023          	sw	zero,0(s1)
    800038d8:	b7dd                	j	800038be <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038da:	0809a583          	lw	a1,128(s3)
    800038de:	e185                	bnez	a1,800038fe <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800038e0:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800038e4:	854e                	mv	a0,s3
    800038e6:	00000097          	auipc	ra,0x0
    800038ea:	de4080e7          	jalr	-540(ra) # 800036ca <iupdate>
}
    800038ee:	70a2                	ld	ra,40(sp)
    800038f0:	7402                	ld	s0,32(sp)
    800038f2:	64e2                	ld	s1,24(sp)
    800038f4:	6942                	ld	s2,16(sp)
    800038f6:	69a2                	ld	s3,8(sp)
    800038f8:	6a02                	ld	s4,0(sp)
    800038fa:	6145                	addi	sp,sp,48
    800038fc:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038fe:	0009a503          	lw	a0,0(s3)
    80003902:	fffff097          	auipc	ra,0xfffff
    80003906:	68e080e7          	jalr	1678(ra) # 80002f90 <bread>
    8000390a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000390c:	05850493          	addi	s1,a0,88
    80003910:	45850913          	addi	s2,a0,1112
    80003914:	a021                	j	8000391c <itrunc+0x7a>
    80003916:	0491                	addi	s1,s1,4
    80003918:	01248b63          	beq	s1,s2,8000392e <itrunc+0x8c>
      if(a[j])
    8000391c:	408c                	lw	a1,0(s1)
    8000391e:	dde5                	beqz	a1,80003916 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003920:	0009a503          	lw	a0,0(s3)
    80003924:	00000097          	auipc	ra,0x0
    80003928:	8b2080e7          	jalr	-1870(ra) # 800031d6 <bfree>
    8000392c:	b7ed                	j	80003916 <itrunc+0x74>
    brelse(bp);
    8000392e:	8552                	mv	a0,s4
    80003930:	fffff097          	auipc	ra,0xfffff
    80003934:	790080e7          	jalr	1936(ra) # 800030c0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003938:	0809a583          	lw	a1,128(s3)
    8000393c:	0009a503          	lw	a0,0(s3)
    80003940:	00000097          	auipc	ra,0x0
    80003944:	896080e7          	jalr	-1898(ra) # 800031d6 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003948:	0809a023          	sw	zero,128(s3)
    8000394c:	bf51                	j	800038e0 <itrunc+0x3e>

000000008000394e <iput>:
{
    8000394e:	1101                	addi	sp,sp,-32
    80003950:	ec06                	sd	ra,24(sp)
    80003952:	e822                	sd	s0,16(sp)
    80003954:	e426                	sd	s1,8(sp)
    80003956:	e04a                	sd	s2,0(sp)
    80003958:	1000                	addi	s0,sp,32
    8000395a:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    8000395c:	0001c517          	auipc	a0,0x1c
    80003960:	50450513          	addi	a0,a0,1284 # 8001fe60 <icache>
    80003964:	ffffd097          	auipc	ra,0xffffd
    80003968:	2ec080e7          	jalr	748(ra) # 80000c50 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000396c:	4498                	lw	a4,8(s1)
    8000396e:	4785                	li	a5,1
    80003970:	02f70363          	beq	a4,a5,80003996 <iput+0x48>
  ip->ref--;
    80003974:	449c                	lw	a5,8(s1)
    80003976:	37fd                	addiw	a5,a5,-1
    80003978:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    8000397a:	0001c517          	auipc	a0,0x1c
    8000397e:	4e650513          	addi	a0,a0,1254 # 8001fe60 <icache>
    80003982:	ffffd097          	auipc	ra,0xffffd
    80003986:	382080e7          	jalr	898(ra) # 80000d04 <release>
}
    8000398a:	60e2                	ld	ra,24(sp)
    8000398c:	6442                	ld	s0,16(sp)
    8000398e:	64a2                	ld	s1,8(sp)
    80003990:	6902                	ld	s2,0(sp)
    80003992:	6105                	addi	sp,sp,32
    80003994:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003996:	40bc                	lw	a5,64(s1)
    80003998:	dff1                	beqz	a5,80003974 <iput+0x26>
    8000399a:	04a49783          	lh	a5,74(s1)
    8000399e:	fbf9                	bnez	a5,80003974 <iput+0x26>
    acquiresleep(&ip->lock);
    800039a0:	01048913          	addi	s2,s1,16
    800039a4:	854a                	mv	a0,s2
    800039a6:	00001097          	auipc	ra,0x1
    800039aa:	aac080e7          	jalr	-1364(ra) # 80004452 <acquiresleep>
    release(&icache.lock);
    800039ae:	0001c517          	auipc	a0,0x1c
    800039b2:	4b250513          	addi	a0,a0,1202 # 8001fe60 <icache>
    800039b6:	ffffd097          	auipc	ra,0xffffd
    800039ba:	34e080e7          	jalr	846(ra) # 80000d04 <release>
    itrunc(ip);
    800039be:	8526                	mv	a0,s1
    800039c0:	00000097          	auipc	ra,0x0
    800039c4:	ee2080e7          	jalr	-286(ra) # 800038a2 <itrunc>
    ip->type = 0;
    800039c8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800039cc:	8526                	mv	a0,s1
    800039ce:	00000097          	auipc	ra,0x0
    800039d2:	cfc080e7          	jalr	-772(ra) # 800036ca <iupdate>
    ip->valid = 0;
    800039d6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039da:	854a                	mv	a0,s2
    800039dc:	00001097          	auipc	ra,0x1
    800039e0:	acc080e7          	jalr	-1332(ra) # 800044a8 <releasesleep>
    acquire(&icache.lock);
    800039e4:	0001c517          	auipc	a0,0x1c
    800039e8:	47c50513          	addi	a0,a0,1148 # 8001fe60 <icache>
    800039ec:	ffffd097          	auipc	ra,0xffffd
    800039f0:	264080e7          	jalr	612(ra) # 80000c50 <acquire>
    800039f4:	b741                	j	80003974 <iput+0x26>

00000000800039f6 <iunlockput>:
{
    800039f6:	1101                	addi	sp,sp,-32
    800039f8:	ec06                	sd	ra,24(sp)
    800039fa:	e822                	sd	s0,16(sp)
    800039fc:	e426                	sd	s1,8(sp)
    800039fe:	1000                	addi	s0,sp,32
    80003a00:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a02:	00000097          	auipc	ra,0x0
    80003a06:	e54080e7          	jalr	-428(ra) # 80003856 <iunlock>
  iput(ip);
    80003a0a:	8526                	mv	a0,s1
    80003a0c:	00000097          	auipc	ra,0x0
    80003a10:	f42080e7          	jalr	-190(ra) # 8000394e <iput>
}
    80003a14:	60e2                	ld	ra,24(sp)
    80003a16:	6442                	ld	s0,16(sp)
    80003a18:	64a2                	ld	s1,8(sp)
    80003a1a:	6105                	addi	sp,sp,32
    80003a1c:	8082                	ret

0000000080003a1e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a1e:	1141                	addi	sp,sp,-16
    80003a20:	e422                	sd	s0,8(sp)
    80003a22:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003a24:	411c                	lw	a5,0(a0)
    80003a26:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a28:	415c                	lw	a5,4(a0)
    80003a2a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a2c:	04451783          	lh	a5,68(a0)
    80003a30:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a34:	04a51783          	lh	a5,74(a0)
    80003a38:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a3c:	04c56783          	lwu	a5,76(a0)
    80003a40:	e99c                	sd	a5,16(a1)
}
    80003a42:	6422                	ld	s0,8(sp)
    80003a44:	0141                	addi	sp,sp,16
    80003a46:	8082                	ret

0000000080003a48 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a48:	457c                	lw	a5,76(a0)
    80003a4a:	0ed7e863          	bltu	a5,a3,80003b3a <readi+0xf2>
{
    80003a4e:	7159                	addi	sp,sp,-112
    80003a50:	f486                	sd	ra,104(sp)
    80003a52:	f0a2                	sd	s0,96(sp)
    80003a54:	eca6                	sd	s1,88(sp)
    80003a56:	e8ca                	sd	s2,80(sp)
    80003a58:	e4ce                	sd	s3,72(sp)
    80003a5a:	e0d2                	sd	s4,64(sp)
    80003a5c:	fc56                	sd	s5,56(sp)
    80003a5e:	f85a                	sd	s6,48(sp)
    80003a60:	f45e                	sd	s7,40(sp)
    80003a62:	f062                	sd	s8,32(sp)
    80003a64:	ec66                	sd	s9,24(sp)
    80003a66:	e86a                	sd	s10,16(sp)
    80003a68:	e46e                	sd	s11,8(sp)
    80003a6a:	1880                	addi	s0,sp,112
    80003a6c:	8baa                	mv	s7,a0
    80003a6e:	8c2e                	mv	s8,a1
    80003a70:	8ab2                	mv	s5,a2
    80003a72:	84b6                	mv	s1,a3
    80003a74:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003a76:	9f35                	addw	a4,a4,a3
    return 0;
    80003a78:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a7a:	08d76f63          	bltu	a4,a3,80003b18 <readi+0xd0>
  if(off + n > ip->size)
    80003a7e:	00e7f463          	bgeu	a5,a4,80003a86 <readi+0x3e>
    n = ip->size - off;
    80003a82:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a86:	0a0b0863          	beqz	s6,80003b36 <readi+0xee>
    80003a8a:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a8c:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a90:	5cfd                	li	s9,-1
    80003a92:	a82d                	j	80003acc <readi+0x84>
    80003a94:	020a1d93          	slli	s11,s4,0x20
    80003a98:	020ddd93          	srli	s11,s11,0x20
    80003a9c:	05890793          	addi	a5,s2,88
    80003aa0:	86ee                	mv	a3,s11
    80003aa2:	963e                	add	a2,a2,a5
    80003aa4:	85d6                	mv	a1,s5
    80003aa6:	8562                	mv	a0,s8
    80003aa8:	fffff097          	auipc	ra,0xfffff
    80003aac:	9de080e7          	jalr	-1570(ra) # 80002486 <either_copyout>
    80003ab0:	05950d63          	beq	a0,s9,80003b0a <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003ab4:	854a                	mv	a0,s2
    80003ab6:	fffff097          	auipc	ra,0xfffff
    80003aba:	60a080e7          	jalr	1546(ra) # 800030c0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003abe:	013a09bb          	addw	s3,s4,s3
    80003ac2:	009a04bb          	addw	s1,s4,s1
    80003ac6:	9aee                	add	s5,s5,s11
    80003ac8:	0569f663          	bgeu	s3,s6,80003b14 <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003acc:	000ba903          	lw	s2,0(s7)
    80003ad0:	00a4d59b          	srliw	a1,s1,0xa
    80003ad4:	855e                	mv	a0,s7
    80003ad6:	00000097          	auipc	ra,0x0
    80003ada:	8ae080e7          	jalr	-1874(ra) # 80003384 <bmap>
    80003ade:	0005059b          	sext.w	a1,a0
    80003ae2:	854a                	mv	a0,s2
    80003ae4:	fffff097          	auipc	ra,0xfffff
    80003ae8:	4ac080e7          	jalr	1196(ra) # 80002f90 <bread>
    80003aec:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aee:	3ff4f613          	andi	a2,s1,1023
    80003af2:	40cd07bb          	subw	a5,s10,a2
    80003af6:	413b073b          	subw	a4,s6,s3
    80003afa:	8a3e                	mv	s4,a5
    80003afc:	2781                	sext.w	a5,a5
    80003afe:	0007069b          	sext.w	a3,a4
    80003b02:	f8f6f9e3          	bgeu	a3,a5,80003a94 <readi+0x4c>
    80003b06:	8a3a                	mv	s4,a4
    80003b08:	b771                	j	80003a94 <readi+0x4c>
      brelse(bp);
    80003b0a:	854a                	mv	a0,s2
    80003b0c:	fffff097          	auipc	ra,0xfffff
    80003b10:	5b4080e7          	jalr	1460(ra) # 800030c0 <brelse>
  }
  return tot;
    80003b14:	0009851b          	sext.w	a0,s3
}
    80003b18:	70a6                	ld	ra,104(sp)
    80003b1a:	7406                	ld	s0,96(sp)
    80003b1c:	64e6                	ld	s1,88(sp)
    80003b1e:	6946                	ld	s2,80(sp)
    80003b20:	69a6                	ld	s3,72(sp)
    80003b22:	6a06                	ld	s4,64(sp)
    80003b24:	7ae2                	ld	s5,56(sp)
    80003b26:	7b42                	ld	s6,48(sp)
    80003b28:	7ba2                	ld	s7,40(sp)
    80003b2a:	7c02                	ld	s8,32(sp)
    80003b2c:	6ce2                	ld	s9,24(sp)
    80003b2e:	6d42                	ld	s10,16(sp)
    80003b30:	6da2                	ld	s11,8(sp)
    80003b32:	6165                	addi	sp,sp,112
    80003b34:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b36:	89da                	mv	s3,s6
    80003b38:	bff1                	j	80003b14 <readi+0xcc>
    return 0;
    80003b3a:	4501                	li	a0,0
}
    80003b3c:	8082                	ret

0000000080003b3e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b3e:	457c                	lw	a5,76(a0)
    80003b40:	10d7e663          	bltu	a5,a3,80003c4c <writei+0x10e>
{
    80003b44:	7159                	addi	sp,sp,-112
    80003b46:	f486                	sd	ra,104(sp)
    80003b48:	f0a2                	sd	s0,96(sp)
    80003b4a:	eca6                	sd	s1,88(sp)
    80003b4c:	e8ca                	sd	s2,80(sp)
    80003b4e:	e4ce                	sd	s3,72(sp)
    80003b50:	e0d2                	sd	s4,64(sp)
    80003b52:	fc56                	sd	s5,56(sp)
    80003b54:	f85a                	sd	s6,48(sp)
    80003b56:	f45e                	sd	s7,40(sp)
    80003b58:	f062                	sd	s8,32(sp)
    80003b5a:	ec66                	sd	s9,24(sp)
    80003b5c:	e86a                	sd	s10,16(sp)
    80003b5e:	e46e                	sd	s11,8(sp)
    80003b60:	1880                	addi	s0,sp,112
    80003b62:	8baa                	mv	s7,a0
    80003b64:	8c2e                	mv	s8,a1
    80003b66:	8ab2                	mv	s5,a2
    80003b68:	8936                	mv	s2,a3
    80003b6a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b6c:	00e687bb          	addw	a5,a3,a4
    80003b70:	0ed7e063          	bltu	a5,a3,80003c50 <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b74:	00043737          	lui	a4,0x43
    80003b78:	0cf76e63          	bltu	a4,a5,80003c54 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b7c:	0a0b0763          	beqz	s6,80003c2a <writei+0xec>
    80003b80:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b82:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b86:	5cfd                	li	s9,-1
    80003b88:	a091                	j	80003bcc <writei+0x8e>
    80003b8a:	02099d93          	slli	s11,s3,0x20
    80003b8e:	020ddd93          	srli	s11,s11,0x20
    80003b92:	05848793          	addi	a5,s1,88
    80003b96:	86ee                	mv	a3,s11
    80003b98:	8656                	mv	a2,s5
    80003b9a:	85e2                	mv	a1,s8
    80003b9c:	953e                	add	a0,a0,a5
    80003b9e:	fffff097          	auipc	ra,0xfffff
    80003ba2:	93e080e7          	jalr	-1730(ra) # 800024dc <either_copyin>
    80003ba6:	07950263          	beq	a0,s9,80003c0a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003baa:	8526                	mv	a0,s1
    80003bac:	00000097          	auipc	ra,0x0
    80003bb0:	77e080e7          	jalr	1918(ra) # 8000432a <log_write>
    brelse(bp);
    80003bb4:	8526                	mv	a0,s1
    80003bb6:	fffff097          	auipc	ra,0xfffff
    80003bba:	50a080e7          	jalr	1290(ra) # 800030c0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bbe:	01498a3b          	addw	s4,s3,s4
    80003bc2:	0129893b          	addw	s2,s3,s2
    80003bc6:	9aee                	add	s5,s5,s11
    80003bc8:	056a7663          	bgeu	s4,s6,80003c14 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003bcc:	000ba483          	lw	s1,0(s7)
    80003bd0:	00a9559b          	srliw	a1,s2,0xa
    80003bd4:	855e                	mv	a0,s7
    80003bd6:	fffff097          	auipc	ra,0xfffff
    80003bda:	7ae080e7          	jalr	1966(ra) # 80003384 <bmap>
    80003bde:	0005059b          	sext.w	a1,a0
    80003be2:	8526                	mv	a0,s1
    80003be4:	fffff097          	auipc	ra,0xfffff
    80003be8:	3ac080e7          	jalr	940(ra) # 80002f90 <bread>
    80003bec:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bee:	3ff97513          	andi	a0,s2,1023
    80003bf2:	40ad07bb          	subw	a5,s10,a0
    80003bf6:	414b073b          	subw	a4,s6,s4
    80003bfa:	89be                	mv	s3,a5
    80003bfc:	2781                	sext.w	a5,a5
    80003bfe:	0007069b          	sext.w	a3,a4
    80003c02:	f8f6f4e3          	bgeu	a3,a5,80003b8a <writei+0x4c>
    80003c06:	89ba                	mv	s3,a4
    80003c08:	b749                	j	80003b8a <writei+0x4c>
      brelse(bp);
    80003c0a:	8526                	mv	a0,s1
    80003c0c:	fffff097          	auipc	ra,0xfffff
    80003c10:	4b4080e7          	jalr	1204(ra) # 800030c0 <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003c14:	04cba783          	lw	a5,76(s7)
    80003c18:	0127f463          	bgeu	a5,s2,80003c20 <writei+0xe2>
      ip->size = off;
    80003c1c:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003c20:	855e                	mv	a0,s7
    80003c22:	00000097          	auipc	ra,0x0
    80003c26:	aa8080e7          	jalr	-1368(ra) # 800036ca <iupdate>
  }

  return n;
    80003c2a:	000b051b          	sext.w	a0,s6
}
    80003c2e:	70a6                	ld	ra,104(sp)
    80003c30:	7406                	ld	s0,96(sp)
    80003c32:	64e6                	ld	s1,88(sp)
    80003c34:	6946                	ld	s2,80(sp)
    80003c36:	69a6                	ld	s3,72(sp)
    80003c38:	6a06                	ld	s4,64(sp)
    80003c3a:	7ae2                	ld	s5,56(sp)
    80003c3c:	7b42                	ld	s6,48(sp)
    80003c3e:	7ba2                	ld	s7,40(sp)
    80003c40:	7c02                	ld	s8,32(sp)
    80003c42:	6ce2                	ld	s9,24(sp)
    80003c44:	6d42                	ld	s10,16(sp)
    80003c46:	6da2                	ld	s11,8(sp)
    80003c48:	6165                	addi	sp,sp,112
    80003c4a:	8082                	ret
    return -1;
    80003c4c:	557d                	li	a0,-1
}
    80003c4e:	8082                	ret
    return -1;
    80003c50:	557d                	li	a0,-1
    80003c52:	bff1                	j	80003c2e <writei+0xf0>
    return -1;
    80003c54:	557d                	li	a0,-1
    80003c56:	bfe1                	j	80003c2e <writei+0xf0>

0000000080003c58 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c58:	1141                	addi	sp,sp,-16
    80003c5a:	e406                	sd	ra,8(sp)
    80003c5c:	e022                	sd	s0,0(sp)
    80003c5e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c60:	4639                	li	a2,14
    80003c62:	ffffd097          	auipc	ra,0xffffd
    80003c66:	1c2080e7          	jalr	450(ra) # 80000e24 <strncmp>
}
    80003c6a:	60a2                	ld	ra,8(sp)
    80003c6c:	6402                	ld	s0,0(sp)
    80003c6e:	0141                	addi	sp,sp,16
    80003c70:	8082                	ret

0000000080003c72 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c72:	7139                	addi	sp,sp,-64
    80003c74:	fc06                	sd	ra,56(sp)
    80003c76:	f822                	sd	s0,48(sp)
    80003c78:	f426                	sd	s1,40(sp)
    80003c7a:	f04a                	sd	s2,32(sp)
    80003c7c:	ec4e                	sd	s3,24(sp)
    80003c7e:	e852                	sd	s4,16(sp)
    80003c80:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c82:	04451703          	lh	a4,68(a0)
    80003c86:	4785                	li	a5,1
    80003c88:	00f71a63          	bne	a4,a5,80003c9c <dirlookup+0x2a>
    80003c8c:	892a                	mv	s2,a0
    80003c8e:	89ae                	mv	s3,a1
    80003c90:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c92:	457c                	lw	a5,76(a0)
    80003c94:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c96:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c98:	e79d                	bnez	a5,80003cc6 <dirlookup+0x54>
    80003c9a:	a8a5                	j	80003d12 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c9c:	00005517          	auipc	a0,0x5
    80003ca0:	a0450513          	addi	a0,a0,-1532 # 800086a0 <syscalls+0x1b0>
    80003ca4:	ffffd097          	auipc	ra,0xffffd
    80003ca8:	89e080e7          	jalr	-1890(ra) # 80000542 <panic>
      panic("dirlookup read");
    80003cac:	00005517          	auipc	a0,0x5
    80003cb0:	a0c50513          	addi	a0,a0,-1524 # 800086b8 <syscalls+0x1c8>
    80003cb4:	ffffd097          	auipc	ra,0xffffd
    80003cb8:	88e080e7          	jalr	-1906(ra) # 80000542 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cbc:	24c1                	addiw	s1,s1,16
    80003cbe:	04c92783          	lw	a5,76(s2)
    80003cc2:	04f4f763          	bgeu	s1,a5,80003d10 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cc6:	4741                	li	a4,16
    80003cc8:	86a6                	mv	a3,s1
    80003cca:	fc040613          	addi	a2,s0,-64
    80003cce:	4581                	li	a1,0
    80003cd0:	854a                	mv	a0,s2
    80003cd2:	00000097          	auipc	ra,0x0
    80003cd6:	d76080e7          	jalr	-650(ra) # 80003a48 <readi>
    80003cda:	47c1                	li	a5,16
    80003cdc:	fcf518e3          	bne	a0,a5,80003cac <dirlookup+0x3a>
    if(de.inum == 0)
    80003ce0:	fc045783          	lhu	a5,-64(s0)
    80003ce4:	dfe1                	beqz	a5,80003cbc <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003ce6:	fc240593          	addi	a1,s0,-62
    80003cea:	854e                	mv	a0,s3
    80003cec:	00000097          	auipc	ra,0x0
    80003cf0:	f6c080e7          	jalr	-148(ra) # 80003c58 <namecmp>
    80003cf4:	f561                	bnez	a0,80003cbc <dirlookup+0x4a>
      if(poff)
    80003cf6:	000a0463          	beqz	s4,80003cfe <dirlookup+0x8c>
        *poff = off;
    80003cfa:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003cfe:	fc045583          	lhu	a1,-64(s0)
    80003d02:	00092503          	lw	a0,0(s2)
    80003d06:	fffff097          	auipc	ra,0xfffff
    80003d0a:	75a080e7          	jalr	1882(ra) # 80003460 <iget>
    80003d0e:	a011                	j	80003d12 <dirlookup+0xa0>
  return 0;
    80003d10:	4501                	li	a0,0
}
    80003d12:	70e2                	ld	ra,56(sp)
    80003d14:	7442                	ld	s0,48(sp)
    80003d16:	74a2                	ld	s1,40(sp)
    80003d18:	7902                	ld	s2,32(sp)
    80003d1a:	69e2                	ld	s3,24(sp)
    80003d1c:	6a42                	ld	s4,16(sp)
    80003d1e:	6121                	addi	sp,sp,64
    80003d20:	8082                	ret

0000000080003d22 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d22:	711d                	addi	sp,sp,-96
    80003d24:	ec86                	sd	ra,88(sp)
    80003d26:	e8a2                	sd	s0,80(sp)
    80003d28:	e4a6                	sd	s1,72(sp)
    80003d2a:	e0ca                	sd	s2,64(sp)
    80003d2c:	fc4e                	sd	s3,56(sp)
    80003d2e:	f852                	sd	s4,48(sp)
    80003d30:	f456                	sd	s5,40(sp)
    80003d32:	f05a                	sd	s6,32(sp)
    80003d34:	ec5e                	sd	s7,24(sp)
    80003d36:	e862                	sd	s8,16(sp)
    80003d38:	e466                	sd	s9,8(sp)
    80003d3a:	1080                	addi	s0,sp,96
    80003d3c:	84aa                	mv	s1,a0
    80003d3e:	8aae                	mv	s5,a1
    80003d40:	8a32                	mv	s4,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d42:	00054703          	lbu	a4,0(a0)
    80003d46:	02f00793          	li	a5,47
    80003d4a:	02f70363          	beq	a4,a5,80003d70 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d4e:	ffffe097          	auipc	ra,0xffffe
    80003d52:	cce080e7          	jalr	-818(ra) # 80001a1c <myproc>
    80003d56:	15053503          	ld	a0,336(a0)
    80003d5a:	00000097          	auipc	ra,0x0
    80003d5e:	9fc080e7          	jalr	-1540(ra) # 80003756 <idup>
    80003d62:	89aa                	mv	s3,a0
  while(*path == '/')
    80003d64:	02f00913          	li	s2,47
  len = path - s;
    80003d68:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    80003d6a:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d6c:	4b85                	li	s7,1
    80003d6e:	a865                	j	80003e26 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003d70:	4585                	li	a1,1
    80003d72:	4505                	li	a0,1
    80003d74:	fffff097          	auipc	ra,0xfffff
    80003d78:	6ec080e7          	jalr	1772(ra) # 80003460 <iget>
    80003d7c:	89aa                	mv	s3,a0
    80003d7e:	b7dd                	j	80003d64 <namex+0x42>
      iunlockput(ip);
    80003d80:	854e                	mv	a0,s3
    80003d82:	00000097          	auipc	ra,0x0
    80003d86:	c74080e7          	jalr	-908(ra) # 800039f6 <iunlockput>
      return 0;
    80003d8a:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d8c:	854e                	mv	a0,s3
    80003d8e:	60e6                	ld	ra,88(sp)
    80003d90:	6446                	ld	s0,80(sp)
    80003d92:	64a6                	ld	s1,72(sp)
    80003d94:	6906                	ld	s2,64(sp)
    80003d96:	79e2                	ld	s3,56(sp)
    80003d98:	7a42                	ld	s4,48(sp)
    80003d9a:	7aa2                	ld	s5,40(sp)
    80003d9c:	7b02                	ld	s6,32(sp)
    80003d9e:	6be2                	ld	s7,24(sp)
    80003da0:	6c42                	ld	s8,16(sp)
    80003da2:	6ca2                	ld	s9,8(sp)
    80003da4:	6125                	addi	sp,sp,96
    80003da6:	8082                	ret
      iunlock(ip);
    80003da8:	854e                	mv	a0,s3
    80003daa:	00000097          	auipc	ra,0x0
    80003dae:	aac080e7          	jalr	-1364(ra) # 80003856 <iunlock>
      return ip;
    80003db2:	bfe9                	j	80003d8c <namex+0x6a>
      iunlockput(ip);
    80003db4:	854e                	mv	a0,s3
    80003db6:	00000097          	auipc	ra,0x0
    80003dba:	c40080e7          	jalr	-960(ra) # 800039f6 <iunlockput>
      return 0;
    80003dbe:	89e6                	mv	s3,s9
    80003dc0:	b7f1                	j	80003d8c <namex+0x6a>
  len = path - s;
    80003dc2:	40b48633          	sub	a2,s1,a1
    80003dc6:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003dca:	099c5463          	bge	s8,s9,80003e52 <namex+0x130>
    memmove(name, s, DIRSIZ);
    80003dce:	4639                	li	a2,14
    80003dd0:	8552                	mv	a0,s4
    80003dd2:	ffffd097          	auipc	ra,0xffffd
    80003dd6:	fd6080e7          	jalr	-42(ra) # 80000da8 <memmove>
  while(*path == '/')
    80003dda:	0004c783          	lbu	a5,0(s1)
    80003dde:	01279763          	bne	a5,s2,80003dec <namex+0xca>
    path++;
    80003de2:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003de4:	0004c783          	lbu	a5,0(s1)
    80003de8:	ff278de3          	beq	a5,s2,80003de2 <namex+0xc0>
    ilock(ip);
    80003dec:	854e                	mv	a0,s3
    80003dee:	00000097          	auipc	ra,0x0
    80003df2:	9a6080e7          	jalr	-1626(ra) # 80003794 <ilock>
    if(ip->type != T_DIR){
    80003df6:	04499783          	lh	a5,68(s3)
    80003dfa:	f97793e3          	bne	a5,s7,80003d80 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003dfe:	000a8563          	beqz	s5,80003e08 <namex+0xe6>
    80003e02:	0004c783          	lbu	a5,0(s1)
    80003e06:	d3cd                	beqz	a5,80003da8 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003e08:	865a                	mv	a2,s6
    80003e0a:	85d2                	mv	a1,s4
    80003e0c:	854e                	mv	a0,s3
    80003e0e:	00000097          	auipc	ra,0x0
    80003e12:	e64080e7          	jalr	-412(ra) # 80003c72 <dirlookup>
    80003e16:	8caa                	mv	s9,a0
    80003e18:	dd51                	beqz	a0,80003db4 <namex+0x92>
    iunlockput(ip);
    80003e1a:	854e                	mv	a0,s3
    80003e1c:	00000097          	auipc	ra,0x0
    80003e20:	bda080e7          	jalr	-1062(ra) # 800039f6 <iunlockput>
    ip = next;
    80003e24:	89e6                	mv	s3,s9
  while(*path == '/')
    80003e26:	0004c783          	lbu	a5,0(s1)
    80003e2a:	05279763          	bne	a5,s2,80003e78 <namex+0x156>
    path++;
    80003e2e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e30:	0004c783          	lbu	a5,0(s1)
    80003e34:	ff278de3          	beq	a5,s2,80003e2e <namex+0x10c>
  if(*path == 0)
    80003e38:	c79d                	beqz	a5,80003e66 <namex+0x144>
    path++;
    80003e3a:	85a6                	mv	a1,s1
  len = path - s;
    80003e3c:	8cda                	mv	s9,s6
    80003e3e:	865a                	mv	a2,s6
  while(*path != '/' && *path != 0)
    80003e40:	01278963          	beq	a5,s2,80003e52 <namex+0x130>
    80003e44:	dfbd                	beqz	a5,80003dc2 <namex+0xa0>
    path++;
    80003e46:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003e48:	0004c783          	lbu	a5,0(s1)
    80003e4c:	ff279ce3          	bne	a5,s2,80003e44 <namex+0x122>
    80003e50:	bf8d                	j	80003dc2 <namex+0xa0>
    memmove(name, s, len);
    80003e52:	2601                	sext.w	a2,a2
    80003e54:	8552                	mv	a0,s4
    80003e56:	ffffd097          	auipc	ra,0xffffd
    80003e5a:	f52080e7          	jalr	-174(ra) # 80000da8 <memmove>
    name[len] = 0;
    80003e5e:	9cd2                	add	s9,s9,s4
    80003e60:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003e64:	bf9d                	j	80003dda <namex+0xb8>
  if(nameiparent){
    80003e66:	f20a83e3          	beqz	s5,80003d8c <namex+0x6a>
    iput(ip);
    80003e6a:	854e                	mv	a0,s3
    80003e6c:	00000097          	auipc	ra,0x0
    80003e70:	ae2080e7          	jalr	-1310(ra) # 8000394e <iput>
    return 0;
    80003e74:	4981                	li	s3,0
    80003e76:	bf19                	j	80003d8c <namex+0x6a>
  if(*path == 0)
    80003e78:	d7fd                	beqz	a5,80003e66 <namex+0x144>
  while(*path != '/' && *path != 0)
    80003e7a:	0004c783          	lbu	a5,0(s1)
    80003e7e:	85a6                	mv	a1,s1
    80003e80:	b7d1                	j	80003e44 <namex+0x122>

0000000080003e82 <dirlink>:
{
    80003e82:	7139                	addi	sp,sp,-64
    80003e84:	fc06                	sd	ra,56(sp)
    80003e86:	f822                	sd	s0,48(sp)
    80003e88:	f426                	sd	s1,40(sp)
    80003e8a:	f04a                	sd	s2,32(sp)
    80003e8c:	ec4e                	sd	s3,24(sp)
    80003e8e:	e852                	sd	s4,16(sp)
    80003e90:	0080                	addi	s0,sp,64
    80003e92:	892a                	mv	s2,a0
    80003e94:	8a2e                	mv	s4,a1
    80003e96:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e98:	4601                	li	a2,0
    80003e9a:	00000097          	auipc	ra,0x0
    80003e9e:	dd8080e7          	jalr	-552(ra) # 80003c72 <dirlookup>
    80003ea2:	e93d                	bnez	a0,80003f18 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ea4:	04c92483          	lw	s1,76(s2)
    80003ea8:	c49d                	beqz	s1,80003ed6 <dirlink+0x54>
    80003eaa:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003eac:	4741                	li	a4,16
    80003eae:	86a6                	mv	a3,s1
    80003eb0:	fc040613          	addi	a2,s0,-64
    80003eb4:	4581                	li	a1,0
    80003eb6:	854a                	mv	a0,s2
    80003eb8:	00000097          	auipc	ra,0x0
    80003ebc:	b90080e7          	jalr	-1136(ra) # 80003a48 <readi>
    80003ec0:	47c1                	li	a5,16
    80003ec2:	06f51163          	bne	a0,a5,80003f24 <dirlink+0xa2>
    if(de.inum == 0)
    80003ec6:	fc045783          	lhu	a5,-64(s0)
    80003eca:	c791                	beqz	a5,80003ed6 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ecc:	24c1                	addiw	s1,s1,16
    80003ece:	04c92783          	lw	a5,76(s2)
    80003ed2:	fcf4ede3          	bltu	s1,a5,80003eac <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003ed6:	4639                	li	a2,14
    80003ed8:	85d2                	mv	a1,s4
    80003eda:	fc240513          	addi	a0,s0,-62
    80003ede:	ffffd097          	auipc	ra,0xffffd
    80003ee2:	f82080e7          	jalr	-126(ra) # 80000e60 <strncpy>
  de.inum = inum;
    80003ee6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003eea:	4741                	li	a4,16
    80003eec:	86a6                	mv	a3,s1
    80003eee:	fc040613          	addi	a2,s0,-64
    80003ef2:	4581                	li	a1,0
    80003ef4:	854a                	mv	a0,s2
    80003ef6:	00000097          	auipc	ra,0x0
    80003efa:	c48080e7          	jalr	-952(ra) # 80003b3e <writei>
    80003efe:	872a                	mv	a4,a0
    80003f00:	47c1                	li	a5,16
  return 0;
    80003f02:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f04:	02f71863          	bne	a4,a5,80003f34 <dirlink+0xb2>
}
    80003f08:	70e2                	ld	ra,56(sp)
    80003f0a:	7442                	ld	s0,48(sp)
    80003f0c:	74a2                	ld	s1,40(sp)
    80003f0e:	7902                	ld	s2,32(sp)
    80003f10:	69e2                	ld	s3,24(sp)
    80003f12:	6a42                	ld	s4,16(sp)
    80003f14:	6121                	addi	sp,sp,64
    80003f16:	8082                	ret
    iput(ip);
    80003f18:	00000097          	auipc	ra,0x0
    80003f1c:	a36080e7          	jalr	-1482(ra) # 8000394e <iput>
    return -1;
    80003f20:	557d                	li	a0,-1
    80003f22:	b7dd                	j	80003f08 <dirlink+0x86>
      panic("dirlink read");
    80003f24:	00004517          	auipc	a0,0x4
    80003f28:	7a450513          	addi	a0,a0,1956 # 800086c8 <syscalls+0x1d8>
    80003f2c:	ffffc097          	auipc	ra,0xffffc
    80003f30:	616080e7          	jalr	1558(ra) # 80000542 <panic>
    panic("dirlink");
    80003f34:	00005517          	auipc	a0,0x5
    80003f38:	8ac50513          	addi	a0,a0,-1876 # 800087e0 <syscalls+0x2f0>
    80003f3c:	ffffc097          	auipc	ra,0xffffc
    80003f40:	606080e7          	jalr	1542(ra) # 80000542 <panic>

0000000080003f44 <namei>:

struct inode*
namei(char *path)
{
    80003f44:	1101                	addi	sp,sp,-32
    80003f46:	ec06                	sd	ra,24(sp)
    80003f48:	e822                	sd	s0,16(sp)
    80003f4a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f4c:	fe040613          	addi	a2,s0,-32
    80003f50:	4581                	li	a1,0
    80003f52:	00000097          	auipc	ra,0x0
    80003f56:	dd0080e7          	jalr	-560(ra) # 80003d22 <namex>
}
    80003f5a:	60e2                	ld	ra,24(sp)
    80003f5c:	6442                	ld	s0,16(sp)
    80003f5e:	6105                	addi	sp,sp,32
    80003f60:	8082                	ret

0000000080003f62 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f62:	1141                	addi	sp,sp,-16
    80003f64:	e406                	sd	ra,8(sp)
    80003f66:	e022                	sd	s0,0(sp)
    80003f68:	0800                	addi	s0,sp,16
    80003f6a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f6c:	4585                	li	a1,1
    80003f6e:	00000097          	auipc	ra,0x0
    80003f72:	db4080e7          	jalr	-588(ra) # 80003d22 <namex>
}
    80003f76:	60a2                	ld	ra,8(sp)
    80003f78:	6402                	ld	s0,0(sp)
    80003f7a:	0141                	addi	sp,sp,16
    80003f7c:	8082                	ret

0000000080003f7e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f7e:	1101                	addi	sp,sp,-32
    80003f80:	ec06                	sd	ra,24(sp)
    80003f82:	e822                	sd	s0,16(sp)
    80003f84:	e426                	sd	s1,8(sp)
    80003f86:	e04a                	sd	s2,0(sp)
    80003f88:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f8a:	0001e917          	auipc	s2,0x1e
    80003f8e:	97e90913          	addi	s2,s2,-1666 # 80021908 <log>
    80003f92:	01892583          	lw	a1,24(s2)
    80003f96:	02892503          	lw	a0,40(s2)
    80003f9a:	fffff097          	auipc	ra,0xfffff
    80003f9e:	ff6080e7          	jalr	-10(ra) # 80002f90 <bread>
    80003fa2:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003fa4:	02c92683          	lw	a3,44(s2)
    80003fa8:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003faa:	02d05863          	blez	a3,80003fda <write_head+0x5c>
    80003fae:	0001e797          	auipc	a5,0x1e
    80003fb2:	98a78793          	addi	a5,a5,-1654 # 80021938 <log+0x30>
    80003fb6:	05c50713          	addi	a4,a0,92
    80003fba:	36fd                	addiw	a3,a3,-1
    80003fbc:	02069613          	slli	a2,a3,0x20
    80003fc0:	01e65693          	srli	a3,a2,0x1e
    80003fc4:	0001e617          	auipc	a2,0x1e
    80003fc8:	97860613          	addi	a2,a2,-1672 # 8002193c <log+0x34>
    80003fcc:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003fce:	4390                	lw	a2,0(a5)
    80003fd0:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003fd2:	0791                	addi	a5,a5,4
    80003fd4:	0711                	addi	a4,a4,4
    80003fd6:	fed79ce3          	bne	a5,a3,80003fce <write_head+0x50>
  }
  bwrite(buf);
    80003fda:	8526                	mv	a0,s1
    80003fdc:	fffff097          	auipc	ra,0xfffff
    80003fe0:	0a6080e7          	jalr	166(ra) # 80003082 <bwrite>
  brelse(buf);
    80003fe4:	8526                	mv	a0,s1
    80003fe6:	fffff097          	auipc	ra,0xfffff
    80003fea:	0da080e7          	jalr	218(ra) # 800030c0 <brelse>
}
    80003fee:	60e2                	ld	ra,24(sp)
    80003ff0:	6442                	ld	s0,16(sp)
    80003ff2:	64a2                	ld	s1,8(sp)
    80003ff4:	6902                	ld	s2,0(sp)
    80003ff6:	6105                	addi	sp,sp,32
    80003ff8:	8082                	ret

0000000080003ffa <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ffa:	0001e797          	auipc	a5,0x1e
    80003ffe:	93a7a783          	lw	a5,-1734(a5) # 80021934 <log+0x2c>
    80004002:	0af05663          	blez	a5,800040ae <install_trans+0xb4>
{
    80004006:	7139                	addi	sp,sp,-64
    80004008:	fc06                	sd	ra,56(sp)
    8000400a:	f822                	sd	s0,48(sp)
    8000400c:	f426                	sd	s1,40(sp)
    8000400e:	f04a                	sd	s2,32(sp)
    80004010:	ec4e                	sd	s3,24(sp)
    80004012:	e852                	sd	s4,16(sp)
    80004014:	e456                	sd	s5,8(sp)
    80004016:	0080                	addi	s0,sp,64
    80004018:	0001ea97          	auipc	s5,0x1e
    8000401c:	920a8a93          	addi	s5,s5,-1760 # 80021938 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004020:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004022:	0001e997          	auipc	s3,0x1e
    80004026:	8e698993          	addi	s3,s3,-1818 # 80021908 <log>
    8000402a:	0189a583          	lw	a1,24(s3)
    8000402e:	014585bb          	addw	a1,a1,s4
    80004032:	2585                	addiw	a1,a1,1
    80004034:	0289a503          	lw	a0,40(s3)
    80004038:	fffff097          	auipc	ra,0xfffff
    8000403c:	f58080e7          	jalr	-168(ra) # 80002f90 <bread>
    80004040:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004042:	000aa583          	lw	a1,0(s5)
    80004046:	0289a503          	lw	a0,40(s3)
    8000404a:	fffff097          	auipc	ra,0xfffff
    8000404e:	f46080e7          	jalr	-186(ra) # 80002f90 <bread>
    80004052:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004054:	40000613          	li	a2,1024
    80004058:	05890593          	addi	a1,s2,88
    8000405c:	05850513          	addi	a0,a0,88
    80004060:	ffffd097          	auipc	ra,0xffffd
    80004064:	d48080e7          	jalr	-696(ra) # 80000da8 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004068:	8526                	mv	a0,s1
    8000406a:	fffff097          	auipc	ra,0xfffff
    8000406e:	018080e7          	jalr	24(ra) # 80003082 <bwrite>
    bunpin(dbuf);
    80004072:	8526                	mv	a0,s1
    80004074:	fffff097          	auipc	ra,0xfffff
    80004078:	126080e7          	jalr	294(ra) # 8000319a <bunpin>
    brelse(lbuf);
    8000407c:	854a                	mv	a0,s2
    8000407e:	fffff097          	auipc	ra,0xfffff
    80004082:	042080e7          	jalr	66(ra) # 800030c0 <brelse>
    brelse(dbuf);
    80004086:	8526                	mv	a0,s1
    80004088:	fffff097          	auipc	ra,0xfffff
    8000408c:	038080e7          	jalr	56(ra) # 800030c0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004090:	2a05                	addiw	s4,s4,1
    80004092:	0a91                	addi	s5,s5,4
    80004094:	02c9a783          	lw	a5,44(s3)
    80004098:	f8fa49e3          	blt	s4,a5,8000402a <install_trans+0x30>
}
    8000409c:	70e2                	ld	ra,56(sp)
    8000409e:	7442                	ld	s0,48(sp)
    800040a0:	74a2                	ld	s1,40(sp)
    800040a2:	7902                	ld	s2,32(sp)
    800040a4:	69e2                	ld	s3,24(sp)
    800040a6:	6a42                	ld	s4,16(sp)
    800040a8:	6aa2                	ld	s5,8(sp)
    800040aa:	6121                	addi	sp,sp,64
    800040ac:	8082                	ret
    800040ae:	8082                	ret

00000000800040b0 <initlog>:
{
    800040b0:	7179                	addi	sp,sp,-48
    800040b2:	f406                	sd	ra,40(sp)
    800040b4:	f022                	sd	s0,32(sp)
    800040b6:	ec26                	sd	s1,24(sp)
    800040b8:	e84a                	sd	s2,16(sp)
    800040ba:	e44e                	sd	s3,8(sp)
    800040bc:	1800                	addi	s0,sp,48
    800040be:	892a                	mv	s2,a0
    800040c0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800040c2:	0001e497          	auipc	s1,0x1e
    800040c6:	84648493          	addi	s1,s1,-1978 # 80021908 <log>
    800040ca:	00004597          	auipc	a1,0x4
    800040ce:	60e58593          	addi	a1,a1,1550 # 800086d8 <syscalls+0x1e8>
    800040d2:	8526                	mv	a0,s1
    800040d4:	ffffd097          	auipc	ra,0xffffd
    800040d8:	aec080e7          	jalr	-1300(ra) # 80000bc0 <initlock>
  log.start = sb->logstart;
    800040dc:	0149a583          	lw	a1,20(s3)
    800040e0:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800040e2:	0109a783          	lw	a5,16(s3)
    800040e6:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800040e8:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800040ec:	854a                	mv	a0,s2
    800040ee:	fffff097          	auipc	ra,0xfffff
    800040f2:	ea2080e7          	jalr	-350(ra) # 80002f90 <bread>
  log.lh.n = lh->n;
    800040f6:	4d34                	lw	a3,88(a0)
    800040f8:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800040fa:	02d05663          	blez	a3,80004126 <initlog+0x76>
    800040fe:	05c50793          	addi	a5,a0,92
    80004102:	0001e717          	auipc	a4,0x1e
    80004106:	83670713          	addi	a4,a4,-1994 # 80021938 <log+0x30>
    8000410a:	36fd                	addiw	a3,a3,-1
    8000410c:	02069613          	slli	a2,a3,0x20
    80004110:	01e65693          	srli	a3,a2,0x1e
    80004114:	06050613          	addi	a2,a0,96
    80004118:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000411a:	4390                	lw	a2,0(a5)
    8000411c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000411e:	0791                	addi	a5,a5,4
    80004120:	0711                	addi	a4,a4,4
    80004122:	fed79ce3          	bne	a5,a3,8000411a <initlog+0x6a>
  brelse(buf);
    80004126:	fffff097          	auipc	ra,0xfffff
    8000412a:	f9a080e7          	jalr	-102(ra) # 800030c0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    8000412e:	00000097          	auipc	ra,0x0
    80004132:	ecc080e7          	jalr	-308(ra) # 80003ffa <install_trans>
  log.lh.n = 0;
    80004136:	0001d797          	auipc	a5,0x1d
    8000413a:	7e07af23          	sw	zero,2046(a5) # 80021934 <log+0x2c>
  write_head(); // clear the log
    8000413e:	00000097          	auipc	ra,0x0
    80004142:	e40080e7          	jalr	-448(ra) # 80003f7e <write_head>
}
    80004146:	70a2                	ld	ra,40(sp)
    80004148:	7402                	ld	s0,32(sp)
    8000414a:	64e2                	ld	s1,24(sp)
    8000414c:	6942                	ld	s2,16(sp)
    8000414e:	69a2                	ld	s3,8(sp)
    80004150:	6145                	addi	sp,sp,48
    80004152:	8082                	ret

0000000080004154 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004154:	1101                	addi	sp,sp,-32
    80004156:	ec06                	sd	ra,24(sp)
    80004158:	e822                	sd	s0,16(sp)
    8000415a:	e426                	sd	s1,8(sp)
    8000415c:	e04a                	sd	s2,0(sp)
    8000415e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004160:	0001d517          	auipc	a0,0x1d
    80004164:	7a850513          	addi	a0,a0,1960 # 80021908 <log>
    80004168:	ffffd097          	auipc	ra,0xffffd
    8000416c:	ae8080e7          	jalr	-1304(ra) # 80000c50 <acquire>
  while(1){
    if(log.committing){
    80004170:	0001d497          	auipc	s1,0x1d
    80004174:	79848493          	addi	s1,s1,1944 # 80021908 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004178:	4979                	li	s2,30
    8000417a:	a039                	j	80004188 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000417c:	85a6                	mv	a1,s1
    8000417e:	8526                	mv	a0,s1
    80004180:	ffffe097          	auipc	ra,0xffffe
    80004184:	0ac080e7          	jalr	172(ra) # 8000222c <sleep>
    if(log.committing){
    80004188:	50dc                	lw	a5,36(s1)
    8000418a:	fbed                	bnez	a5,8000417c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000418c:	509c                	lw	a5,32(s1)
    8000418e:	0017871b          	addiw	a4,a5,1
    80004192:	0007069b          	sext.w	a3,a4
    80004196:	0027179b          	slliw	a5,a4,0x2
    8000419a:	9fb9                	addw	a5,a5,a4
    8000419c:	0017979b          	slliw	a5,a5,0x1
    800041a0:	54d8                	lw	a4,44(s1)
    800041a2:	9fb9                	addw	a5,a5,a4
    800041a4:	00f95963          	bge	s2,a5,800041b6 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800041a8:	85a6                	mv	a1,s1
    800041aa:	8526                	mv	a0,s1
    800041ac:	ffffe097          	auipc	ra,0xffffe
    800041b0:	080080e7          	jalr	128(ra) # 8000222c <sleep>
    800041b4:	bfd1                	j	80004188 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800041b6:	0001d517          	auipc	a0,0x1d
    800041ba:	75250513          	addi	a0,a0,1874 # 80021908 <log>
    800041be:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800041c0:	ffffd097          	auipc	ra,0xffffd
    800041c4:	b44080e7          	jalr	-1212(ra) # 80000d04 <release>
      break;
    }
  }
}
    800041c8:	60e2                	ld	ra,24(sp)
    800041ca:	6442                	ld	s0,16(sp)
    800041cc:	64a2                	ld	s1,8(sp)
    800041ce:	6902                	ld	s2,0(sp)
    800041d0:	6105                	addi	sp,sp,32
    800041d2:	8082                	ret

00000000800041d4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800041d4:	7139                	addi	sp,sp,-64
    800041d6:	fc06                	sd	ra,56(sp)
    800041d8:	f822                	sd	s0,48(sp)
    800041da:	f426                	sd	s1,40(sp)
    800041dc:	f04a                	sd	s2,32(sp)
    800041de:	ec4e                	sd	s3,24(sp)
    800041e0:	e852                	sd	s4,16(sp)
    800041e2:	e456                	sd	s5,8(sp)
    800041e4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800041e6:	0001d497          	auipc	s1,0x1d
    800041ea:	72248493          	addi	s1,s1,1826 # 80021908 <log>
    800041ee:	8526                	mv	a0,s1
    800041f0:	ffffd097          	auipc	ra,0xffffd
    800041f4:	a60080e7          	jalr	-1440(ra) # 80000c50 <acquire>
  log.outstanding -= 1;
    800041f8:	509c                	lw	a5,32(s1)
    800041fa:	37fd                	addiw	a5,a5,-1
    800041fc:	0007891b          	sext.w	s2,a5
    80004200:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004202:	50dc                	lw	a5,36(s1)
    80004204:	e7b9                	bnez	a5,80004252 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004206:	04091e63          	bnez	s2,80004262 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000420a:	0001d497          	auipc	s1,0x1d
    8000420e:	6fe48493          	addi	s1,s1,1790 # 80021908 <log>
    80004212:	4785                	li	a5,1
    80004214:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004216:	8526                	mv	a0,s1
    80004218:	ffffd097          	auipc	ra,0xffffd
    8000421c:	aec080e7          	jalr	-1300(ra) # 80000d04 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004220:	54dc                	lw	a5,44(s1)
    80004222:	06f04763          	bgtz	a5,80004290 <end_op+0xbc>
    acquire(&log.lock);
    80004226:	0001d497          	auipc	s1,0x1d
    8000422a:	6e248493          	addi	s1,s1,1762 # 80021908 <log>
    8000422e:	8526                	mv	a0,s1
    80004230:	ffffd097          	auipc	ra,0xffffd
    80004234:	a20080e7          	jalr	-1504(ra) # 80000c50 <acquire>
    log.committing = 0;
    80004238:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000423c:	8526                	mv	a0,s1
    8000423e:	ffffe097          	auipc	ra,0xffffe
    80004242:	16e080e7          	jalr	366(ra) # 800023ac <wakeup>
    release(&log.lock);
    80004246:	8526                	mv	a0,s1
    80004248:	ffffd097          	auipc	ra,0xffffd
    8000424c:	abc080e7          	jalr	-1348(ra) # 80000d04 <release>
}
    80004250:	a03d                	j	8000427e <end_op+0xaa>
    panic("log.committing");
    80004252:	00004517          	auipc	a0,0x4
    80004256:	48e50513          	addi	a0,a0,1166 # 800086e0 <syscalls+0x1f0>
    8000425a:	ffffc097          	auipc	ra,0xffffc
    8000425e:	2e8080e7          	jalr	744(ra) # 80000542 <panic>
    wakeup(&log);
    80004262:	0001d497          	auipc	s1,0x1d
    80004266:	6a648493          	addi	s1,s1,1702 # 80021908 <log>
    8000426a:	8526                	mv	a0,s1
    8000426c:	ffffe097          	auipc	ra,0xffffe
    80004270:	140080e7          	jalr	320(ra) # 800023ac <wakeup>
  release(&log.lock);
    80004274:	8526                	mv	a0,s1
    80004276:	ffffd097          	auipc	ra,0xffffd
    8000427a:	a8e080e7          	jalr	-1394(ra) # 80000d04 <release>
}
    8000427e:	70e2                	ld	ra,56(sp)
    80004280:	7442                	ld	s0,48(sp)
    80004282:	74a2                	ld	s1,40(sp)
    80004284:	7902                	ld	s2,32(sp)
    80004286:	69e2                	ld	s3,24(sp)
    80004288:	6a42                	ld	s4,16(sp)
    8000428a:	6aa2                	ld	s5,8(sp)
    8000428c:	6121                	addi	sp,sp,64
    8000428e:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004290:	0001da97          	auipc	s5,0x1d
    80004294:	6a8a8a93          	addi	s5,s5,1704 # 80021938 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004298:	0001da17          	auipc	s4,0x1d
    8000429c:	670a0a13          	addi	s4,s4,1648 # 80021908 <log>
    800042a0:	018a2583          	lw	a1,24(s4)
    800042a4:	012585bb          	addw	a1,a1,s2
    800042a8:	2585                	addiw	a1,a1,1
    800042aa:	028a2503          	lw	a0,40(s4)
    800042ae:	fffff097          	auipc	ra,0xfffff
    800042b2:	ce2080e7          	jalr	-798(ra) # 80002f90 <bread>
    800042b6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800042b8:	000aa583          	lw	a1,0(s5)
    800042bc:	028a2503          	lw	a0,40(s4)
    800042c0:	fffff097          	auipc	ra,0xfffff
    800042c4:	cd0080e7          	jalr	-816(ra) # 80002f90 <bread>
    800042c8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800042ca:	40000613          	li	a2,1024
    800042ce:	05850593          	addi	a1,a0,88
    800042d2:	05848513          	addi	a0,s1,88
    800042d6:	ffffd097          	auipc	ra,0xffffd
    800042da:	ad2080e7          	jalr	-1326(ra) # 80000da8 <memmove>
    bwrite(to);  // write the log
    800042de:	8526                	mv	a0,s1
    800042e0:	fffff097          	auipc	ra,0xfffff
    800042e4:	da2080e7          	jalr	-606(ra) # 80003082 <bwrite>
    brelse(from);
    800042e8:	854e                	mv	a0,s3
    800042ea:	fffff097          	auipc	ra,0xfffff
    800042ee:	dd6080e7          	jalr	-554(ra) # 800030c0 <brelse>
    brelse(to);
    800042f2:	8526                	mv	a0,s1
    800042f4:	fffff097          	auipc	ra,0xfffff
    800042f8:	dcc080e7          	jalr	-564(ra) # 800030c0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042fc:	2905                	addiw	s2,s2,1
    800042fe:	0a91                	addi	s5,s5,4
    80004300:	02ca2783          	lw	a5,44(s4)
    80004304:	f8f94ee3          	blt	s2,a5,800042a0 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004308:	00000097          	auipc	ra,0x0
    8000430c:	c76080e7          	jalr	-906(ra) # 80003f7e <write_head>
    install_trans(); // Now install writes to home locations
    80004310:	00000097          	auipc	ra,0x0
    80004314:	cea080e7          	jalr	-790(ra) # 80003ffa <install_trans>
    log.lh.n = 0;
    80004318:	0001d797          	auipc	a5,0x1d
    8000431c:	6007ae23          	sw	zero,1564(a5) # 80021934 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004320:	00000097          	auipc	ra,0x0
    80004324:	c5e080e7          	jalr	-930(ra) # 80003f7e <write_head>
    80004328:	bdfd                	j	80004226 <end_op+0x52>

000000008000432a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000432a:	1101                	addi	sp,sp,-32
    8000432c:	ec06                	sd	ra,24(sp)
    8000432e:	e822                	sd	s0,16(sp)
    80004330:	e426                	sd	s1,8(sp)
    80004332:	e04a                	sd	s2,0(sp)
    80004334:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004336:	0001d717          	auipc	a4,0x1d
    8000433a:	5fe72703          	lw	a4,1534(a4) # 80021934 <log+0x2c>
    8000433e:	47f5                	li	a5,29
    80004340:	08e7c063          	blt	a5,a4,800043c0 <log_write+0x96>
    80004344:	84aa                	mv	s1,a0
    80004346:	0001d797          	auipc	a5,0x1d
    8000434a:	5de7a783          	lw	a5,1502(a5) # 80021924 <log+0x1c>
    8000434e:	37fd                	addiw	a5,a5,-1
    80004350:	06f75863          	bge	a4,a5,800043c0 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004354:	0001d797          	auipc	a5,0x1d
    80004358:	5d47a783          	lw	a5,1492(a5) # 80021928 <log+0x20>
    8000435c:	06f05a63          	blez	a5,800043d0 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    80004360:	0001d917          	auipc	s2,0x1d
    80004364:	5a890913          	addi	s2,s2,1448 # 80021908 <log>
    80004368:	854a                	mv	a0,s2
    8000436a:	ffffd097          	auipc	ra,0xffffd
    8000436e:	8e6080e7          	jalr	-1818(ra) # 80000c50 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    80004372:	02c92603          	lw	a2,44(s2)
    80004376:	06c05563          	blez	a2,800043e0 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    8000437a:	44cc                	lw	a1,12(s1)
    8000437c:	0001d717          	auipc	a4,0x1d
    80004380:	5bc70713          	addi	a4,a4,1468 # 80021938 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004384:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    80004386:	4314                	lw	a3,0(a4)
    80004388:	04b68d63          	beq	a3,a1,800043e2 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    8000438c:	2785                	addiw	a5,a5,1
    8000438e:	0711                	addi	a4,a4,4
    80004390:	fec79be3          	bne	a5,a2,80004386 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004394:	0621                	addi	a2,a2,8
    80004396:	060a                	slli	a2,a2,0x2
    80004398:	0001d797          	auipc	a5,0x1d
    8000439c:	57078793          	addi	a5,a5,1392 # 80021908 <log>
    800043a0:	963e                	add	a2,a2,a5
    800043a2:	44dc                	lw	a5,12(s1)
    800043a4:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800043a6:	8526                	mv	a0,s1
    800043a8:	fffff097          	auipc	ra,0xfffff
    800043ac:	db6080e7          	jalr	-586(ra) # 8000315e <bpin>
    log.lh.n++;
    800043b0:	0001d717          	auipc	a4,0x1d
    800043b4:	55870713          	addi	a4,a4,1368 # 80021908 <log>
    800043b8:	575c                	lw	a5,44(a4)
    800043ba:	2785                	addiw	a5,a5,1
    800043bc:	d75c                	sw	a5,44(a4)
    800043be:	a83d                	j	800043fc <log_write+0xd2>
    panic("too big a transaction");
    800043c0:	00004517          	auipc	a0,0x4
    800043c4:	33050513          	addi	a0,a0,816 # 800086f0 <syscalls+0x200>
    800043c8:	ffffc097          	auipc	ra,0xffffc
    800043cc:	17a080e7          	jalr	378(ra) # 80000542 <panic>
    panic("log_write outside of trans");
    800043d0:	00004517          	auipc	a0,0x4
    800043d4:	33850513          	addi	a0,a0,824 # 80008708 <syscalls+0x218>
    800043d8:	ffffc097          	auipc	ra,0xffffc
    800043dc:	16a080e7          	jalr	362(ra) # 80000542 <panic>
  for (i = 0; i < log.lh.n; i++) {
    800043e0:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    800043e2:	00878713          	addi	a4,a5,8
    800043e6:	00271693          	slli	a3,a4,0x2
    800043ea:	0001d717          	auipc	a4,0x1d
    800043ee:	51e70713          	addi	a4,a4,1310 # 80021908 <log>
    800043f2:	9736                	add	a4,a4,a3
    800043f4:	44d4                	lw	a3,12(s1)
    800043f6:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043f8:	faf607e3          	beq	a2,a5,800043a6 <log_write+0x7c>
  }
  release(&log.lock);
    800043fc:	0001d517          	auipc	a0,0x1d
    80004400:	50c50513          	addi	a0,a0,1292 # 80021908 <log>
    80004404:	ffffd097          	auipc	ra,0xffffd
    80004408:	900080e7          	jalr	-1792(ra) # 80000d04 <release>
}
    8000440c:	60e2                	ld	ra,24(sp)
    8000440e:	6442                	ld	s0,16(sp)
    80004410:	64a2                	ld	s1,8(sp)
    80004412:	6902                	ld	s2,0(sp)
    80004414:	6105                	addi	sp,sp,32
    80004416:	8082                	ret

0000000080004418 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004418:	1101                	addi	sp,sp,-32
    8000441a:	ec06                	sd	ra,24(sp)
    8000441c:	e822                	sd	s0,16(sp)
    8000441e:	e426                	sd	s1,8(sp)
    80004420:	e04a                	sd	s2,0(sp)
    80004422:	1000                	addi	s0,sp,32
    80004424:	84aa                	mv	s1,a0
    80004426:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004428:	00004597          	auipc	a1,0x4
    8000442c:	30058593          	addi	a1,a1,768 # 80008728 <syscalls+0x238>
    80004430:	0521                	addi	a0,a0,8
    80004432:	ffffc097          	auipc	ra,0xffffc
    80004436:	78e080e7          	jalr	1934(ra) # 80000bc0 <initlock>
  lk->name = name;
    8000443a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000443e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004442:	0204a423          	sw	zero,40(s1)
}
    80004446:	60e2                	ld	ra,24(sp)
    80004448:	6442                	ld	s0,16(sp)
    8000444a:	64a2                	ld	s1,8(sp)
    8000444c:	6902                	ld	s2,0(sp)
    8000444e:	6105                	addi	sp,sp,32
    80004450:	8082                	ret

0000000080004452 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004452:	1101                	addi	sp,sp,-32
    80004454:	ec06                	sd	ra,24(sp)
    80004456:	e822                	sd	s0,16(sp)
    80004458:	e426                	sd	s1,8(sp)
    8000445a:	e04a                	sd	s2,0(sp)
    8000445c:	1000                	addi	s0,sp,32
    8000445e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004460:	00850913          	addi	s2,a0,8
    80004464:	854a                	mv	a0,s2
    80004466:	ffffc097          	auipc	ra,0xffffc
    8000446a:	7ea080e7          	jalr	2026(ra) # 80000c50 <acquire>
  while (lk->locked) {
    8000446e:	409c                	lw	a5,0(s1)
    80004470:	cb89                	beqz	a5,80004482 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004472:	85ca                	mv	a1,s2
    80004474:	8526                	mv	a0,s1
    80004476:	ffffe097          	auipc	ra,0xffffe
    8000447a:	db6080e7          	jalr	-586(ra) # 8000222c <sleep>
  while (lk->locked) {
    8000447e:	409c                	lw	a5,0(s1)
    80004480:	fbed                	bnez	a5,80004472 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004482:	4785                	li	a5,1
    80004484:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004486:	ffffd097          	auipc	ra,0xffffd
    8000448a:	596080e7          	jalr	1430(ra) # 80001a1c <myproc>
    8000448e:	5d1c                	lw	a5,56(a0)
    80004490:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004492:	854a                	mv	a0,s2
    80004494:	ffffd097          	auipc	ra,0xffffd
    80004498:	870080e7          	jalr	-1936(ra) # 80000d04 <release>
}
    8000449c:	60e2                	ld	ra,24(sp)
    8000449e:	6442                	ld	s0,16(sp)
    800044a0:	64a2                	ld	s1,8(sp)
    800044a2:	6902                	ld	s2,0(sp)
    800044a4:	6105                	addi	sp,sp,32
    800044a6:	8082                	ret

00000000800044a8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800044a8:	1101                	addi	sp,sp,-32
    800044aa:	ec06                	sd	ra,24(sp)
    800044ac:	e822                	sd	s0,16(sp)
    800044ae:	e426                	sd	s1,8(sp)
    800044b0:	e04a                	sd	s2,0(sp)
    800044b2:	1000                	addi	s0,sp,32
    800044b4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044b6:	00850913          	addi	s2,a0,8
    800044ba:	854a                	mv	a0,s2
    800044bc:	ffffc097          	auipc	ra,0xffffc
    800044c0:	794080e7          	jalr	1940(ra) # 80000c50 <acquire>
  lk->locked = 0;
    800044c4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044c8:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800044cc:	8526                	mv	a0,s1
    800044ce:	ffffe097          	auipc	ra,0xffffe
    800044d2:	ede080e7          	jalr	-290(ra) # 800023ac <wakeup>
  release(&lk->lk);
    800044d6:	854a                	mv	a0,s2
    800044d8:	ffffd097          	auipc	ra,0xffffd
    800044dc:	82c080e7          	jalr	-2004(ra) # 80000d04 <release>
}
    800044e0:	60e2                	ld	ra,24(sp)
    800044e2:	6442                	ld	s0,16(sp)
    800044e4:	64a2                	ld	s1,8(sp)
    800044e6:	6902                	ld	s2,0(sp)
    800044e8:	6105                	addi	sp,sp,32
    800044ea:	8082                	ret

00000000800044ec <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800044ec:	7179                	addi	sp,sp,-48
    800044ee:	f406                	sd	ra,40(sp)
    800044f0:	f022                	sd	s0,32(sp)
    800044f2:	ec26                	sd	s1,24(sp)
    800044f4:	e84a                	sd	s2,16(sp)
    800044f6:	e44e                	sd	s3,8(sp)
    800044f8:	1800                	addi	s0,sp,48
    800044fa:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800044fc:	00850913          	addi	s2,a0,8
    80004500:	854a                	mv	a0,s2
    80004502:	ffffc097          	auipc	ra,0xffffc
    80004506:	74e080e7          	jalr	1870(ra) # 80000c50 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000450a:	409c                	lw	a5,0(s1)
    8000450c:	ef99                	bnez	a5,8000452a <holdingsleep+0x3e>
    8000450e:	4481                	li	s1,0
  release(&lk->lk);
    80004510:	854a                	mv	a0,s2
    80004512:	ffffc097          	auipc	ra,0xffffc
    80004516:	7f2080e7          	jalr	2034(ra) # 80000d04 <release>
  return r;
}
    8000451a:	8526                	mv	a0,s1
    8000451c:	70a2                	ld	ra,40(sp)
    8000451e:	7402                	ld	s0,32(sp)
    80004520:	64e2                	ld	s1,24(sp)
    80004522:	6942                	ld	s2,16(sp)
    80004524:	69a2                	ld	s3,8(sp)
    80004526:	6145                	addi	sp,sp,48
    80004528:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000452a:	0284a983          	lw	s3,40(s1)
    8000452e:	ffffd097          	auipc	ra,0xffffd
    80004532:	4ee080e7          	jalr	1262(ra) # 80001a1c <myproc>
    80004536:	5d04                	lw	s1,56(a0)
    80004538:	413484b3          	sub	s1,s1,s3
    8000453c:	0014b493          	seqz	s1,s1
    80004540:	bfc1                	j	80004510 <holdingsleep+0x24>

0000000080004542 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004542:	1141                	addi	sp,sp,-16
    80004544:	e406                	sd	ra,8(sp)
    80004546:	e022                	sd	s0,0(sp)
    80004548:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000454a:	00004597          	auipc	a1,0x4
    8000454e:	1ee58593          	addi	a1,a1,494 # 80008738 <syscalls+0x248>
    80004552:	0001d517          	auipc	a0,0x1d
    80004556:	4fe50513          	addi	a0,a0,1278 # 80021a50 <ftable>
    8000455a:	ffffc097          	auipc	ra,0xffffc
    8000455e:	666080e7          	jalr	1638(ra) # 80000bc0 <initlock>
}
    80004562:	60a2                	ld	ra,8(sp)
    80004564:	6402                	ld	s0,0(sp)
    80004566:	0141                	addi	sp,sp,16
    80004568:	8082                	ret

000000008000456a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000456a:	1101                	addi	sp,sp,-32
    8000456c:	ec06                	sd	ra,24(sp)
    8000456e:	e822                	sd	s0,16(sp)
    80004570:	e426                	sd	s1,8(sp)
    80004572:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004574:	0001d517          	auipc	a0,0x1d
    80004578:	4dc50513          	addi	a0,a0,1244 # 80021a50 <ftable>
    8000457c:	ffffc097          	auipc	ra,0xffffc
    80004580:	6d4080e7          	jalr	1748(ra) # 80000c50 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004584:	0001d497          	auipc	s1,0x1d
    80004588:	4e448493          	addi	s1,s1,1252 # 80021a68 <ftable+0x18>
    8000458c:	0001e717          	auipc	a4,0x1e
    80004590:	47c70713          	addi	a4,a4,1148 # 80022a08 <ftable+0xfb8>
    if(f->ref == 0){
    80004594:	40dc                	lw	a5,4(s1)
    80004596:	cf99                	beqz	a5,800045b4 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004598:	02848493          	addi	s1,s1,40
    8000459c:	fee49ce3          	bne	s1,a4,80004594 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800045a0:	0001d517          	auipc	a0,0x1d
    800045a4:	4b050513          	addi	a0,a0,1200 # 80021a50 <ftable>
    800045a8:	ffffc097          	auipc	ra,0xffffc
    800045ac:	75c080e7          	jalr	1884(ra) # 80000d04 <release>
  return 0;
    800045b0:	4481                	li	s1,0
    800045b2:	a819                	j	800045c8 <filealloc+0x5e>
      f->ref = 1;
    800045b4:	4785                	li	a5,1
    800045b6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800045b8:	0001d517          	auipc	a0,0x1d
    800045bc:	49850513          	addi	a0,a0,1176 # 80021a50 <ftable>
    800045c0:	ffffc097          	auipc	ra,0xffffc
    800045c4:	744080e7          	jalr	1860(ra) # 80000d04 <release>
}
    800045c8:	8526                	mv	a0,s1
    800045ca:	60e2                	ld	ra,24(sp)
    800045cc:	6442                	ld	s0,16(sp)
    800045ce:	64a2                	ld	s1,8(sp)
    800045d0:	6105                	addi	sp,sp,32
    800045d2:	8082                	ret

00000000800045d4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800045d4:	1101                	addi	sp,sp,-32
    800045d6:	ec06                	sd	ra,24(sp)
    800045d8:	e822                	sd	s0,16(sp)
    800045da:	e426                	sd	s1,8(sp)
    800045dc:	1000                	addi	s0,sp,32
    800045de:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800045e0:	0001d517          	auipc	a0,0x1d
    800045e4:	47050513          	addi	a0,a0,1136 # 80021a50 <ftable>
    800045e8:	ffffc097          	auipc	ra,0xffffc
    800045ec:	668080e7          	jalr	1640(ra) # 80000c50 <acquire>
  if(f->ref < 1)
    800045f0:	40dc                	lw	a5,4(s1)
    800045f2:	02f05263          	blez	a5,80004616 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800045f6:	2785                	addiw	a5,a5,1
    800045f8:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800045fa:	0001d517          	auipc	a0,0x1d
    800045fe:	45650513          	addi	a0,a0,1110 # 80021a50 <ftable>
    80004602:	ffffc097          	auipc	ra,0xffffc
    80004606:	702080e7          	jalr	1794(ra) # 80000d04 <release>
  return f;
}
    8000460a:	8526                	mv	a0,s1
    8000460c:	60e2                	ld	ra,24(sp)
    8000460e:	6442                	ld	s0,16(sp)
    80004610:	64a2                	ld	s1,8(sp)
    80004612:	6105                	addi	sp,sp,32
    80004614:	8082                	ret
    panic("filedup");
    80004616:	00004517          	auipc	a0,0x4
    8000461a:	12a50513          	addi	a0,a0,298 # 80008740 <syscalls+0x250>
    8000461e:	ffffc097          	auipc	ra,0xffffc
    80004622:	f24080e7          	jalr	-220(ra) # 80000542 <panic>

0000000080004626 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004626:	7139                	addi	sp,sp,-64
    80004628:	fc06                	sd	ra,56(sp)
    8000462a:	f822                	sd	s0,48(sp)
    8000462c:	f426                	sd	s1,40(sp)
    8000462e:	f04a                	sd	s2,32(sp)
    80004630:	ec4e                	sd	s3,24(sp)
    80004632:	e852                	sd	s4,16(sp)
    80004634:	e456                	sd	s5,8(sp)
    80004636:	0080                	addi	s0,sp,64
    80004638:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000463a:	0001d517          	auipc	a0,0x1d
    8000463e:	41650513          	addi	a0,a0,1046 # 80021a50 <ftable>
    80004642:	ffffc097          	auipc	ra,0xffffc
    80004646:	60e080e7          	jalr	1550(ra) # 80000c50 <acquire>
  if(f->ref < 1)
    8000464a:	40dc                	lw	a5,4(s1)
    8000464c:	06f05163          	blez	a5,800046ae <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004650:	37fd                	addiw	a5,a5,-1
    80004652:	0007871b          	sext.w	a4,a5
    80004656:	c0dc                	sw	a5,4(s1)
    80004658:	06e04363          	bgtz	a4,800046be <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000465c:	0004a903          	lw	s2,0(s1)
    80004660:	0094ca83          	lbu	s5,9(s1)
    80004664:	0104ba03          	ld	s4,16(s1)
    80004668:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000466c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004670:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004674:	0001d517          	auipc	a0,0x1d
    80004678:	3dc50513          	addi	a0,a0,988 # 80021a50 <ftable>
    8000467c:	ffffc097          	auipc	ra,0xffffc
    80004680:	688080e7          	jalr	1672(ra) # 80000d04 <release>

  if(ff.type == FD_PIPE){
    80004684:	4785                	li	a5,1
    80004686:	04f90d63          	beq	s2,a5,800046e0 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000468a:	3979                	addiw	s2,s2,-2
    8000468c:	4785                	li	a5,1
    8000468e:	0527e063          	bltu	a5,s2,800046ce <fileclose+0xa8>
    begin_op();
    80004692:	00000097          	auipc	ra,0x0
    80004696:	ac2080e7          	jalr	-1342(ra) # 80004154 <begin_op>
    iput(ff.ip);
    8000469a:	854e                	mv	a0,s3
    8000469c:	fffff097          	auipc	ra,0xfffff
    800046a0:	2b2080e7          	jalr	690(ra) # 8000394e <iput>
    end_op();
    800046a4:	00000097          	auipc	ra,0x0
    800046a8:	b30080e7          	jalr	-1232(ra) # 800041d4 <end_op>
    800046ac:	a00d                	j	800046ce <fileclose+0xa8>
    panic("fileclose");
    800046ae:	00004517          	auipc	a0,0x4
    800046b2:	09a50513          	addi	a0,a0,154 # 80008748 <syscalls+0x258>
    800046b6:	ffffc097          	auipc	ra,0xffffc
    800046ba:	e8c080e7          	jalr	-372(ra) # 80000542 <panic>
    release(&ftable.lock);
    800046be:	0001d517          	auipc	a0,0x1d
    800046c2:	39250513          	addi	a0,a0,914 # 80021a50 <ftable>
    800046c6:	ffffc097          	auipc	ra,0xffffc
    800046ca:	63e080e7          	jalr	1598(ra) # 80000d04 <release>
  }
}
    800046ce:	70e2                	ld	ra,56(sp)
    800046d0:	7442                	ld	s0,48(sp)
    800046d2:	74a2                	ld	s1,40(sp)
    800046d4:	7902                	ld	s2,32(sp)
    800046d6:	69e2                	ld	s3,24(sp)
    800046d8:	6a42                	ld	s4,16(sp)
    800046da:	6aa2                	ld	s5,8(sp)
    800046dc:	6121                	addi	sp,sp,64
    800046de:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800046e0:	85d6                	mv	a1,s5
    800046e2:	8552                	mv	a0,s4
    800046e4:	00000097          	auipc	ra,0x0
    800046e8:	372080e7          	jalr	882(ra) # 80004a56 <pipeclose>
    800046ec:	b7cd                	j	800046ce <fileclose+0xa8>

00000000800046ee <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800046ee:	715d                	addi	sp,sp,-80
    800046f0:	e486                	sd	ra,72(sp)
    800046f2:	e0a2                	sd	s0,64(sp)
    800046f4:	fc26                	sd	s1,56(sp)
    800046f6:	f84a                	sd	s2,48(sp)
    800046f8:	f44e                	sd	s3,40(sp)
    800046fa:	0880                	addi	s0,sp,80
    800046fc:	84aa                	mv	s1,a0
    800046fe:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004700:	ffffd097          	auipc	ra,0xffffd
    80004704:	31c080e7          	jalr	796(ra) # 80001a1c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004708:	409c                	lw	a5,0(s1)
    8000470a:	37f9                	addiw	a5,a5,-2
    8000470c:	4705                	li	a4,1
    8000470e:	04f76763          	bltu	a4,a5,8000475c <filestat+0x6e>
    80004712:	892a                	mv	s2,a0
    ilock(f->ip);
    80004714:	6c88                	ld	a0,24(s1)
    80004716:	fffff097          	auipc	ra,0xfffff
    8000471a:	07e080e7          	jalr	126(ra) # 80003794 <ilock>
    stati(f->ip, &st);
    8000471e:	fb840593          	addi	a1,s0,-72
    80004722:	6c88                	ld	a0,24(s1)
    80004724:	fffff097          	auipc	ra,0xfffff
    80004728:	2fa080e7          	jalr	762(ra) # 80003a1e <stati>
    iunlock(f->ip);
    8000472c:	6c88                	ld	a0,24(s1)
    8000472e:	fffff097          	auipc	ra,0xfffff
    80004732:	128080e7          	jalr	296(ra) # 80003856 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004736:	46e1                	li	a3,24
    80004738:	fb840613          	addi	a2,s0,-72
    8000473c:	85ce                	mv	a1,s3
    8000473e:	05093503          	ld	a0,80(s2)
    80004742:	ffffd097          	auipc	ra,0xffffd
    80004746:	fcc080e7          	jalr	-52(ra) # 8000170e <copyout>
    8000474a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000474e:	60a6                	ld	ra,72(sp)
    80004750:	6406                	ld	s0,64(sp)
    80004752:	74e2                	ld	s1,56(sp)
    80004754:	7942                	ld	s2,48(sp)
    80004756:	79a2                	ld	s3,40(sp)
    80004758:	6161                	addi	sp,sp,80
    8000475a:	8082                	ret
  return -1;
    8000475c:	557d                	li	a0,-1
    8000475e:	bfc5                	j	8000474e <filestat+0x60>

0000000080004760 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004760:	7179                	addi	sp,sp,-48
    80004762:	f406                	sd	ra,40(sp)
    80004764:	f022                	sd	s0,32(sp)
    80004766:	ec26                	sd	s1,24(sp)
    80004768:	e84a                	sd	s2,16(sp)
    8000476a:	e44e                	sd	s3,8(sp)
    8000476c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000476e:	00854783          	lbu	a5,8(a0)
    80004772:	c3d5                	beqz	a5,80004816 <fileread+0xb6>
    80004774:	84aa                	mv	s1,a0
    80004776:	89ae                	mv	s3,a1
    80004778:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000477a:	411c                	lw	a5,0(a0)
    8000477c:	4705                	li	a4,1
    8000477e:	04e78963          	beq	a5,a4,800047d0 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004782:	470d                	li	a4,3
    80004784:	04e78d63          	beq	a5,a4,800047de <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004788:	4709                	li	a4,2
    8000478a:	06e79e63          	bne	a5,a4,80004806 <fileread+0xa6>
    ilock(f->ip);
    8000478e:	6d08                	ld	a0,24(a0)
    80004790:	fffff097          	auipc	ra,0xfffff
    80004794:	004080e7          	jalr	4(ra) # 80003794 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004798:	874a                	mv	a4,s2
    8000479a:	5094                	lw	a3,32(s1)
    8000479c:	864e                	mv	a2,s3
    8000479e:	4585                	li	a1,1
    800047a0:	6c88                	ld	a0,24(s1)
    800047a2:	fffff097          	auipc	ra,0xfffff
    800047a6:	2a6080e7          	jalr	678(ra) # 80003a48 <readi>
    800047aa:	892a                	mv	s2,a0
    800047ac:	00a05563          	blez	a0,800047b6 <fileread+0x56>
      f->off += r;
    800047b0:	509c                	lw	a5,32(s1)
    800047b2:	9fa9                	addw	a5,a5,a0
    800047b4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800047b6:	6c88                	ld	a0,24(s1)
    800047b8:	fffff097          	auipc	ra,0xfffff
    800047bc:	09e080e7          	jalr	158(ra) # 80003856 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800047c0:	854a                	mv	a0,s2
    800047c2:	70a2                	ld	ra,40(sp)
    800047c4:	7402                	ld	s0,32(sp)
    800047c6:	64e2                	ld	s1,24(sp)
    800047c8:	6942                	ld	s2,16(sp)
    800047ca:	69a2                	ld	s3,8(sp)
    800047cc:	6145                	addi	sp,sp,48
    800047ce:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800047d0:	6908                	ld	a0,16(a0)
    800047d2:	00000097          	auipc	ra,0x0
    800047d6:	3f4080e7          	jalr	1012(ra) # 80004bc6 <piperead>
    800047da:	892a                	mv	s2,a0
    800047dc:	b7d5                	j	800047c0 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800047de:	02451783          	lh	a5,36(a0)
    800047e2:	03079693          	slli	a3,a5,0x30
    800047e6:	92c1                	srli	a3,a3,0x30
    800047e8:	4725                	li	a4,9
    800047ea:	02d76863          	bltu	a4,a3,8000481a <fileread+0xba>
    800047ee:	0792                	slli	a5,a5,0x4
    800047f0:	0001d717          	auipc	a4,0x1d
    800047f4:	1c070713          	addi	a4,a4,448 # 800219b0 <devsw>
    800047f8:	97ba                	add	a5,a5,a4
    800047fa:	639c                	ld	a5,0(a5)
    800047fc:	c38d                	beqz	a5,8000481e <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800047fe:	4505                	li	a0,1
    80004800:	9782                	jalr	a5
    80004802:	892a                	mv	s2,a0
    80004804:	bf75                	j	800047c0 <fileread+0x60>
    panic("fileread");
    80004806:	00004517          	auipc	a0,0x4
    8000480a:	f5250513          	addi	a0,a0,-174 # 80008758 <syscalls+0x268>
    8000480e:	ffffc097          	auipc	ra,0xffffc
    80004812:	d34080e7          	jalr	-716(ra) # 80000542 <panic>
    return -1;
    80004816:	597d                	li	s2,-1
    80004818:	b765                	j	800047c0 <fileread+0x60>
      return -1;
    8000481a:	597d                	li	s2,-1
    8000481c:	b755                	j	800047c0 <fileread+0x60>
    8000481e:	597d                	li	s2,-1
    80004820:	b745                	j	800047c0 <fileread+0x60>

0000000080004822 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004822:	00954783          	lbu	a5,9(a0)
    80004826:	14078563          	beqz	a5,80004970 <filewrite+0x14e>
{
    8000482a:	715d                	addi	sp,sp,-80
    8000482c:	e486                	sd	ra,72(sp)
    8000482e:	e0a2                	sd	s0,64(sp)
    80004830:	fc26                	sd	s1,56(sp)
    80004832:	f84a                	sd	s2,48(sp)
    80004834:	f44e                	sd	s3,40(sp)
    80004836:	f052                	sd	s4,32(sp)
    80004838:	ec56                	sd	s5,24(sp)
    8000483a:	e85a                	sd	s6,16(sp)
    8000483c:	e45e                	sd	s7,8(sp)
    8000483e:	e062                	sd	s8,0(sp)
    80004840:	0880                	addi	s0,sp,80
    80004842:	892a                	mv	s2,a0
    80004844:	8aae                	mv	s5,a1
    80004846:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004848:	411c                	lw	a5,0(a0)
    8000484a:	4705                	li	a4,1
    8000484c:	02e78263          	beq	a5,a4,80004870 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004850:	470d                	li	a4,3
    80004852:	02e78563          	beq	a5,a4,8000487c <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004856:	4709                	li	a4,2
    80004858:	10e79463          	bne	a5,a4,80004960 <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000485c:	0ec05e63          	blez	a2,80004958 <filewrite+0x136>
    int i = 0;
    80004860:	4981                	li	s3,0
    80004862:	6b05                	lui	s6,0x1
    80004864:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004868:	6b85                	lui	s7,0x1
    8000486a:	c00b8b9b          	addiw	s7,s7,-1024
    8000486e:	a851                	j	80004902 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004870:	6908                	ld	a0,16(a0)
    80004872:	00000097          	auipc	ra,0x0
    80004876:	254080e7          	jalr	596(ra) # 80004ac6 <pipewrite>
    8000487a:	a85d                	j	80004930 <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000487c:	02451783          	lh	a5,36(a0)
    80004880:	03079693          	slli	a3,a5,0x30
    80004884:	92c1                	srli	a3,a3,0x30
    80004886:	4725                	li	a4,9
    80004888:	0ed76663          	bltu	a4,a3,80004974 <filewrite+0x152>
    8000488c:	0792                	slli	a5,a5,0x4
    8000488e:	0001d717          	auipc	a4,0x1d
    80004892:	12270713          	addi	a4,a4,290 # 800219b0 <devsw>
    80004896:	97ba                	add	a5,a5,a4
    80004898:	679c                	ld	a5,8(a5)
    8000489a:	cff9                	beqz	a5,80004978 <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    8000489c:	4505                	li	a0,1
    8000489e:	9782                	jalr	a5
    800048a0:	a841                	j	80004930 <filewrite+0x10e>
    800048a2:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    800048a6:	00000097          	auipc	ra,0x0
    800048aa:	8ae080e7          	jalr	-1874(ra) # 80004154 <begin_op>
      ilock(f->ip);
    800048ae:	01893503          	ld	a0,24(s2)
    800048b2:	fffff097          	auipc	ra,0xfffff
    800048b6:	ee2080e7          	jalr	-286(ra) # 80003794 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800048ba:	8762                	mv	a4,s8
    800048bc:	02092683          	lw	a3,32(s2)
    800048c0:	01598633          	add	a2,s3,s5
    800048c4:	4585                	li	a1,1
    800048c6:	01893503          	ld	a0,24(s2)
    800048ca:	fffff097          	auipc	ra,0xfffff
    800048ce:	274080e7          	jalr	628(ra) # 80003b3e <writei>
    800048d2:	84aa                	mv	s1,a0
    800048d4:	02a05f63          	blez	a0,80004912 <filewrite+0xf0>
        f->off += r;
    800048d8:	02092783          	lw	a5,32(s2)
    800048dc:	9fa9                	addw	a5,a5,a0
    800048de:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800048e2:	01893503          	ld	a0,24(s2)
    800048e6:	fffff097          	auipc	ra,0xfffff
    800048ea:	f70080e7          	jalr	-144(ra) # 80003856 <iunlock>
      end_op();
    800048ee:	00000097          	auipc	ra,0x0
    800048f2:	8e6080e7          	jalr	-1818(ra) # 800041d4 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    800048f6:	049c1963          	bne	s8,s1,80004948 <filewrite+0x126>
        panic("short filewrite");
      i += r;
    800048fa:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800048fe:	0349d663          	bge	s3,s4,8000492a <filewrite+0x108>
      int n1 = n - i;
    80004902:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004906:	84be                	mv	s1,a5
    80004908:	2781                	sext.w	a5,a5
    8000490a:	f8fb5ce3          	bge	s6,a5,800048a2 <filewrite+0x80>
    8000490e:	84de                	mv	s1,s7
    80004910:	bf49                	j	800048a2 <filewrite+0x80>
      iunlock(f->ip);
    80004912:	01893503          	ld	a0,24(s2)
    80004916:	fffff097          	auipc	ra,0xfffff
    8000491a:	f40080e7          	jalr	-192(ra) # 80003856 <iunlock>
      end_op();
    8000491e:	00000097          	auipc	ra,0x0
    80004922:	8b6080e7          	jalr	-1866(ra) # 800041d4 <end_op>
      if(r < 0)
    80004926:	fc04d8e3          	bgez	s1,800048f6 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    8000492a:	8552                	mv	a0,s4
    8000492c:	033a1863          	bne	s4,s3,8000495c <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004930:	60a6                	ld	ra,72(sp)
    80004932:	6406                	ld	s0,64(sp)
    80004934:	74e2                	ld	s1,56(sp)
    80004936:	7942                	ld	s2,48(sp)
    80004938:	79a2                	ld	s3,40(sp)
    8000493a:	7a02                	ld	s4,32(sp)
    8000493c:	6ae2                	ld	s5,24(sp)
    8000493e:	6b42                	ld	s6,16(sp)
    80004940:	6ba2                	ld	s7,8(sp)
    80004942:	6c02                	ld	s8,0(sp)
    80004944:	6161                	addi	sp,sp,80
    80004946:	8082                	ret
        panic("short filewrite");
    80004948:	00004517          	auipc	a0,0x4
    8000494c:	e2050513          	addi	a0,a0,-480 # 80008768 <syscalls+0x278>
    80004950:	ffffc097          	auipc	ra,0xffffc
    80004954:	bf2080e7          	jalr	-1038(ra) # 80000542 <panic>
    int i = 0;
    80004958:	4981                	li	s3,0
    8000495a:	bfc1                	j	8000492a <filewrite+0x108>
    ret = (i == n ? n : -1);
    8000495c:	557d                	li	a0,-1
    8000495e:	bfc9                	j	80004930 <filewrite+0x10e>
    panic("filewrite");
    80004960:	00004517          	auipc	a0,0x4
    80004964:	e1850513          	addi	a0,a0,-488 # 80008778 <syscalls+0x288>
    80004968:	ffffc097          	auipc	ra,0xffffc
    8000496c:	bda080e7          	jalr	-1062(ra) # 80000542 <panic>
    return -1;
    80004970:	557d                	li	a0,-1
}
    80004972:	8082                	ret
      return -1;
    80004974:	557d                	li	a0,-1
    80004976:	bf6d                	j	80004930 <filewrite+0x10e>
    80004978:	557d                	li	a0,-1
    8000497a:	bf5d                	j	80004930 <filewrite+0x10e>

000000008000497c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000497c:	7179                	addi	sp,sp,-48
    8000497e:	f406                	sd	ra,40(sp)
    80004980:	f022                	sd	s0,32(sp)
    80004982:	ec26                	sd	s1,24(sp)
    80004984:	e84a                	sd	s2,16(sp)
    80004986:	e44e                	sd	s3,8(sp)
    80004988:	e052                	sd	s4,0(sp)
    8000498a:	1800                	addi	s0,sp,48
    8000498c:	84aa                	mv	s1,a0
    8000498e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004990:	0005b023          	sd	zero,0(a1)
    80004994:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004998:	00000097          	auipc	ra,0x0
    8000499c:	bd2080e7          	jalr	-1070(ra) # 8000456a <filealloc>
    800049a0:	e088                	sd	a0,0(s1)
    800049a2:	c551                	beqz	a0,80004a2e <pipealloc+0xb2>
    800049a4:	00000097          	auipc	ra,0x0
    800049a8:	bc6080e7          	jalr	-1082(ra) # 8000456a <filealloc>
    800049ac:	00aa3023          	sd	a0,0(s4)
    800049b0:	c92d                	beqz	a0,80004a22 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800049b2:	ffffc097          	auipc	ra,0xffffc
    800049b6:	15c080e7          	jalr	348(ra) # 80000b0e <kalloc>
    800049ba:	892a                	mv	s2,a0
    800049bc:	c125                	beqz	a0,80004a1c <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800049be:	4985                	li	s3,1
    800049c0:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800049c4:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800049c8:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800049cc:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800049d0:	00004597          	auipc	a1,0x4
    800049d4:	a7058593          	addi	a1,a1,-1424 # 80008440 <states.0+0x198>
    800049d8:	ffffc097          	auipc	ra,0xffffc
    800049dc:	1e8080e7          	jalr	488(ra) # 80000bc0 <initlock>
  (*f0)->type = FD_PIPE;
    800049e0:	609c                	ld	a5,0(s1)
    800049e2:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800049e6:	609c                	ld	a5,0(s1)
    800049e8:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800049ec:	609c                	ld	a5,0(s1)
    800049ee:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800049f2:	609c                	ld	a5,0(s1)
    800049f4:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800049f8:	000a3783          	ld	a5,0(s4)
    800049fc:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004a00:	000a3783          	ld	a5,0(s4)
    80004a04:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004a08:	000a3783          	ld	a5,0(s4)
    80004a0c:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004a10:	000a3783          	ld	a5,0(s4)
    80004a14:	0127b823          	sd	s2,16(a5)
  return 0;
    80004a18:	4501                	li	a0,0
    80004a1a:	a025                	j	80004a42 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004a1c:	6088                	ld	a0,0(s1)
    80004a1e:	e501                	bnez	a0,80004a26 <pipealloc+0xaa>
    80004a20:	a039                	j	80004a2e <pipealloc+0xb2>
    80004a22:	6088                	ld	a0,0(s1)
    80004a24:	c51d                	beqz	a0,80004a52 <pipealloc+0xd6>
    fileclose(*f0);
    80004a26:	00000097          	auipc	ra,0x0
    80004a2a:	c00080e7          	jalr	-1024(ra) # 80004626 <fileclose>
  if(*f1)
    80004a2e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a32:	557d                	li	a0,-1
  if(*f1)
    80004a34:	c799                	beqz	a5,80004a42 <pipealloc+0xc6>
    fileclose(*f1);
    80004a36:	853e                	mv	a0,a5
    80004a38:	00000097          	auipc	ra,0x0
    80004a3c:	bee080e7          	jalr	-1042(ra) # 80004626 <fileclose>
  return -1;
    80004a40:	557d                	li	a0,-1
}
    80004a42:	70a2                	ld	ra,40(sp)
    80004a44:	7402                	ld	s0,32(sp)
    80004a46:	64e2                	ld	s1,24(sp)
    80004a48:	6942                	ld	s2,16(sp)
    80004a4a:	69a2                	ld	s3,8(sp)
    80004a4c:	6a02                	ld	s4,0(sp)
    80004a4e:	6145                	addi	sp,sp,48
    80004a50:	8082                	ret
  return -1;
    80004a52:	557d                	li	a0,-1
    80004a54:	b7fd                	j	80004a42 <pipealloc+0xc6>

0000000080004a56 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a56:	1101                	addi	sp,sp,-32
    80004a58:	ec06                	sd	ra,24(sp)
    80004a5a:	e822                	sd	s0,16(sp)
    80004a5c:	e426                	sd	s1,8(sp)
    80004a5e:	e04a                	sd	s2,0(sp)
    80004a60:	1000                	addi	s0,sp,32
    80004a62:	84aa                	mv	s1,a0
    80004a64:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a66:	ffffc097          	auipc	ra,0xffffc
    80004a6a:	1ea080e7          	jalr	490(ra) # 80000c50 <acquire>
  if(writable){
    80004a6e:	02090d63          	beqz	s2,80004aa8 <pipeclose+0x52>
    pi->writeopen = 0;
    80004a72:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a76:	21848513          	addi	a0,s1,536
    80004a7a:	ffffe097          	auipc	ra,0xffffe
    80004a7e:	932080e7          	jalr	-1742(ra) # 800023ac <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a82:	2204b783          	ld	a5,544(s1)
    80004a86:	eb95                	bnez	a5,80004aba <pipeclose+0x64>
    release(&pi->lock);
    80004a88:	8526                	mv	a0,s1
    80004a8a:	ffffc097          	auipc	ra,0xffffc
    80004a8e:	27a080e7          	jalr	634(ra) # 80000d04 <release>
    kfree((char*)pi);
    80004a92:	8526                	mv	a0,s1
    80004a94:	ffffc097          	auipc	ra,0xffffc
    80004a98:	f7e080e7          	jalr	-130(ra) # 80000a12 <kfree>
  } else
    release(&pi->lock);
}
    80004a9c:	60e2                	ld	ra,24(sp)
    80004a9e:	6442                	ld	s0,16(sp)
    80004aa0:	64a2                	ld	s1,8(sp)
    80004aa2:	6902                	ld	s2,0(sp)
    80004aa4:	6105                	addi	sp,sp,32
    80004aa6:	8082                	ret
    pi->readopen = 0;
    80004aa8:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004aac:	21c48513          	addi	a0,s1,540
    80004ab0:	ffffe097          	auipc	ra,0xffffe
    80004ab4:	8fc080e7          	jalr	-1796(ra) # 800023ac <wakeup>
    80004ab8:	b7e9                	j	80004a82 <pipeclose+0x2c>
    release(&pi->lock);
    80004aba:	8526                	mv	a0,s1
    80004abc:	ffffc097          	auipc	ra,0xffffc
    80004ac0:	248080e7          	jalr	584(ra) # 80000d04 <release>
}
    80004ac4:	bfe1                	j	80004a9c <pipeclose+0x46>

0000000080004ac6 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ac6:	711d                	addi	sp,sp,-96
    80004ac8:	ec86                	sd	ra,88(sp)
    80004aca:	e8a2                	sd	s0,80(sp)
    80004acc:	e4a6                	sd	s1,72(sp)
    80004ace:	e0ca                	sd	s2,64(sp)
    80004ad0:	fc4e                	sd	s3,56(sp)
    80004ad2:	f852                	sd	s4,48(sp)
    80004ad4:	f456                	sd	s5,40(sp)
    80004ad6:	f05a                	sd	s6,32(sp)
    80004ad8:	ec5e                	sd	s7,24(sp)
    80004ada:	e862                	sd	s8,16(sp)
    80004adc:	1080                	addi	s0,sp,96
    80004ade:	84aa                	mv	s1,a0
    80004ae0:	8b2e                	mv	s6,a1
    80004ae2:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004ae4:	ffffd097          	auipc	ra,0xffffd
    80004ae8:	f38080e7          	jalr	-200(ra) # 80001a1c <myproc>
    80004aec:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004aee:	8526                	mv	a0,s1
    80004af0:	ffffc097          	auipc	ra,0xffffc
    80004af4:	160080e7          	jalr	352(ra) # 80000c50 <acquire>
  for(i = 0; i < n; i++){
    80004af8:	09505763          	blez	s5,80004b86 <pipewrite+0xc0>
    80004afc:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004afe:	21848a13          	addi	s4,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004b02:	21c48993          	addi	s3,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b06:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004b08:	2184a783          	lw	a5,536(s1)
    80004b0c:	21c4a703          	lw	a4,540(s1)
    80004b10:	2007879b          	addiw	a5,a5,512
    80004b14:	02f71b63          	bne	a4,a5,80004b4a <pipewrite+0x84>
      if(pi->readopen == 0 || pr->killed){
    80004b18:	2204a783          	lw	a5,544(s1)
    80004b1c:	c3d1                	beqz	a5,80004ba0 <pipewrite+0xda>
    80004b1e:	03092783          	lw	a5,48(s2)
    80004b22:	efbd                	bnez	a5,80004ba0 <pipewrite+0xda>
      wakeup(&pi->nread);
    80004b24:	8552                	mv	a0,s4
    80004b26:	ffffe097          	auipc	ra,0xffffe
    80004b2a:	886080e7          	jalr	-1914(ra) # 800023ac <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004b2e:	85a6                	mv	a1,s1
    80004b30:	854e                	mv	a0,s3
    80004b32:	ffffd097          	auipc	ra,0xffffd
    80004b36:	6fa080e7          	jalr	1786(ra) # 8000222c <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004b3a:	2184a783          	lw	a5,536(s1)
    80004b3e:	21c4a703          	lw	a4,540(s1)
    80004b42:	2007879b          	addiw	a5,a5,512
    80004b46:	fcf709e3          	beq	a4,a5,80004b18 <pipewrite+0x52>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b4a:	4685                	li	a3,1
    80004b4c:	865a                	mv	a2,s6
    80004b4e:	faf40593          	addi	a1,s0,-81
    80004b52:	05093503          	ld	a0,80(s2)
    80004b56:	ffffd097          	auipc	ra,0xffffd
    80004b5a:	c44080e7          	jalr	-956(ra) # 8000179a <copyin>
    80004b5e:	03850563          	beq	a0,s8,80004b88 <pipewrite+0xc2>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b62:	21c4a783          	lw	a5,540(s1)
    80004b66:	0017871b          	addiw	a4,a5,1
    80004b6a:	20e4ae23          	sw	a4,540(s1)
    80004b6e:	1ff7f793          	andi	a5,a5,511
    80004b72:	97a6                	add	a5,a5,s1
    80004b74:	faf44703          	lbu	a4,-81(s0)
    80004b78:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004b7c:	2b85                	addiw	s7,s7,1
    80004b7e:	0b05                	addi	s6,s6,1
    80004b80:	f97a94e3          	bne	s5,s7,80004b08 <pipewrite+0x42>
    80004b84:	a011                	j	80004b88 <pipewrite+0xc2>
    80004b86:	4b81                	li	s7,0
  }
  wakeup(&pi->nread);
    80004b88:	21848513          	addi	a0,s1,536
    80004b8c:	ffffe097          	auipc	ra,0xffffe
    80004b90:	820080e7          	jalr	-2016(ra) # 800023ac <wakeup>
  release(&pi->lock);
    80004b94:	8526                	mv	a0,s1
    80004b96:	ffffc097          	auipc	ra,0xffffc
    80004b9a:	16e080e7          	jalr	366(ra) # 80000d04 <release>
  return i;
    80004b9e:	a039                	j	80004bac <pipewrite+0xe6>
        release(&pi->lock);
    80004ba0:	8526                	mv	a0,s1
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	162080e7          	jalr	354(ra) # 80000d04 <release>
        return -1;
    80004baa:	5bfd                	li	s7,-1
}
    80004bac:	855e                	mv	a0,s7
    80004bae:	60e6                	ld	ra,88(sp)
    80004bb0:	6446                	ld	s0,80(sp)
    80004bb2:	64a6                	ld	s1,72(sp)
    80004bb4:	6906                	ld	s2,64(sp)
    80004bb6:	79e2                	ld	s3,56(sp)
    80004bb8:	7a42                	ld	s4,48(sp)
    80004bba:	7aa2                	ld	s5,40(sp)
    80004bbc:	7b02                	ld	s6,32(sp)
    80004bbe:	6be2                	ld	s7,24(sp)
    80004bc0:	6c42                	ld	s8,16(sp)
    80004bc2:	6125                	addi	sp,sp,96
    80004bc4:	8082                	ret

0000000080004bc6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004bc6:	715d                	addi	sp,sp,-80
    80004bc8:	e486                	sd	ra,72(sp)
    80004bca:	e0a2                	sd	s0,64(sp)
    80004bcc:	fc26                	sd	s1,56(sp)
    80004bce:	f84a                	sd	s2,48(sp)
    80004bd0:	f44e                	sd	s3,40(sp)
    80004bd2:	f052                	sd	s4,32(sp)
    80004bd4:	ec56                	sd	s5,24(sp)
    80004bd6:	e85a                	sd	s6,16(sp)
    80004bd8:	0880                	addi	s0,sp,80
    80004bda:	84aa                	mv	s1,a0
    80004bdc:	892e                	mv	s2,a1
    80004bde:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004be0:	ffffd097          	auipc	ra,0xffffd
    80004be4:	e3c080e7          	jalr	-452(ra) # 80001a1c <myproc>
    80004be8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004bea:	8526                	mv	a0,s1
    80004bec:	ffffc097          	auipc	ra,0xffffc
    80004bf0:	064080e7          	jalr	100(ra) # 80000c50 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bf4:	2184a703          	lw	a4,536(s1)
    80004bf8:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bfc:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c00:	02f71463          	bne	a4,a5,80004c28 <piperead+0x62>
    80004c04:	2244a783          	lw	a5,548(s1)
    80004c08:	c385                	beqz	a5,80004c28 <piperead+0x62>
    if(pr->killed){
    80004c0a:	030a2783          	lw	a5,48(s4)
    80004c0e:	ebc1                	bnez	a5,80004c9e <piperead+0xd8>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c10:	85a6                	mv	a1,s1
    80004c12:	854e                	mv	a0,s3
    80004c14:	ffffd097          	auipc	ra,0xffffd
    80004c18:	618080e7          	jalr	1560(ra) # 8000222c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c1c:	2184a703          	lw	a4,536(s1)
    80004c20:	21c4a783          	lw	a5,540(s1)
    80004c24:	fef700e3          	beq	a4,a5,80004c04 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c28:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c2a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c2c:	05505363          	blez	s5,80004c72 <piperead+0xac>
    if(pi->nread == pi->nwrite)
    80004c30:	2184a783          	lw	a5,536(s1)
    80004c34:	21c4a703          	lw	a4,540(s1)
    80004c38:	02f70d63          	beq	a4,a5,80004c72 <piperead+0xac>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004c3c:	0017871b          	addiw	a4,a5,1
    80004c40:	20e4ac23          	sw	a4,536(s1)
    80004c44:	1ff7f793          	andi	a5,a5,511
    80004c48:	97a6                	add	a5,a5,s1
    80004c4a:	0187c783          	lbu	a5,24(a5)
    80004c4e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c52:	4685                	li	a3,1
    80004c54:	fbf40613          	addi	a2,s0,-65
    80004c58:	85ca                	mv	a1,s2
    80004c5a:	050a3503          	ld	a0,80(s4)
    80004c5e:	ffffd097          	auipc	ra,0xffffd
    80004c62:	ab0080e7          	jalr	-1360(ra) # 8000170e <copyout>
    80004c66:	01650663          	beq	a0,s6,80004c72 <piperead+0xac>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c6a:	2985                	addiw	s3,s3,1
    80004c6c:	0905                	addi	s2,s2,1
    80004c6e:	fd3a91e3          	bne	s5,s3,80004c30 <piperead+0x6a>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c72:	21c48513          	addi	a0,s1,540
    80004c76:	ffffd097          	auipc	ra,0xffffd
    80004c7a:	736080e7          	jalr	1846(ra) # 800023ac <wakeup>
  release(&pi->lock);
    80004c7e:	8526                	mv	a0,s1
    80004c80:	ffffc097          	auipc	ra,0xffffc
    80004c84:	084080e7          	jalr	132(ra) # 80000d04 <release>
  return i;
}
    80004c88:	854e                	mv	a0,s3
    80004c8a:	60a6                	ld	ra,72(sp)
    80004c8c:	6406                	ld	s0,64(sp)
    80004c8e:	74e2                	ld	s1,56(sp)
    80004c90:	7942                	ld	s2,48(sp)
    80004c92:	79a2                	ld	s3,40(sp)
    80004c94:	7a02                	ld	s4,32(sp)
    80004c96:	6ae2                	ld	s5,24(sp)
    80004c98:	6b42                	ld	s6,16(sp)
    80004c9a:	6161                	addi	sp,sp,80
    80004c9c:	8082                	ret
      release(&pi->lock);
    80004c9e:	8526                	mv	a0,s1
    80004ca0:	ffffc097          	auipc	ra,0xffffc
    80004ca4:	064080e7          	jalr	100(ra) # 80000d04 <release>
      return -1;
    80004ca8:	59fd                	li	s3,-1
    80004caa:	bff9                	j	80004c88 <piperead+0xc2>

0000000080004cac <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004cac:	de010113          	addi	sp,sp,-544
    80004cb0:	20113c23          	sd	ra,536(sp)
    80004cb4:	20813823          	sd	s0,528(sp)
    80004cb8:	20913423          	sd	s1,520(sp)
    80004cbc:	21213023          	sd	s2,512(sp)
    80004cc0:	ffce                	sd	s3,504(sp)
    80004cc2:	fbd2                	sd	s4,496(sp)
    80004cc4:	f7d6                	sd	s5,488(sp)
    80004cc6:	f3da                	sd	s6,480(sp)
    80004cc8:	efde                	sd	s7,472(sp)
    80004cca:	ebe2                	sd	s8,464(sp)
    80004ccc:	e7e6                	sd	s9,456(sp)
    80004cce:	e3ea                	sd	s10,448(sp)
    80004cd0:	ff6e                	sd	s11,440(sp)
    80004cd2:	1400                	addi	s0,sp,544
    80004cd4:	892a                	mv	s2,a0
    80004cd6:	dea43423          	sd	a0,-536(s0)
    80004cda:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004cde:	ffffd097          	auipc	ra,0xffffd
    80004ce2:	d3e080e7          	jalr	-706(ra) # 80001a1c <myproc>
    80004ce6:	84aa                	mv	s1,a0

  begin_op();
    80004ce8:	fffff097          	auipc	ra,0xfffff
    80004cec:	46c080e7          	jalr	1132(ra) # 80004154 <begin_op>

  if((ip = namei(path)) == 0){
    80004cf0:	854a                	mv	a0,s2
    80004cf2:	fffff097          	auipc	ra,0xfffff
    80004cf6:	252080e7          	jalr	594(ra) # 80003f44 <namei>
    80004cfa:	c93d                	beqz	a0,80004d70 <exec+0xc4>
    80004cfc:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004cfe:	fffff097          	auipc	ra,0xfffff
    80004d02:	a96080e7          	jalr	-1386(ra) # 80003794 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004d06:	04000713          	li	a4,64
    80004d0a:	4681                	li	a3,0
    80004d0c:	e4840613          	addi	a2,s0,-440
    80004d10:	4581                	li	a1,0
    80004d12:	8556                	mv	a0,s5
    80004d14:	fffff097          	auipc	ra,0xfffff
    80004d18:	d34080e7          	jalr	-716(ra) # 80003a48 <readi>
    80004d1c:	04000793          	li	a5,64
    80004d20:	00f51a63          	bne	a0,a5,80004d34 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004d24:	e4842703          	lw	a4,-440(s0)
    80004d28:	464c47b7          	lui	a5,0x464c4
    80004d2c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d30:	04f70663          	beq	a4,a5,80004d7c <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004d34:	8556                	mv	a0,s5
    80004d36:	fffff097          	auipc	ra,0xfffff
    80004d3a:	cc0080e7          	jalr	-832(ra) # 800039f6 <iunlockput>
    end_op();
    80004d3e:	fffff097          	auipc	ra,0xfffff
    80004d42:	496080e7          	jalr	1174(ra) # 800041d4 <end_op>
  }
  return -1;
    80004d46:	557d                	li	a0,-1
}
    80004d48:	21813083          	ld	ra,536(sp)
    80004d4c:	21013403          	ld	s0,528(sp)
    80004d50:	20813483          	ld	s1,520(sp)
    80004d54:	20013903          	ld	s2,512(sp)
    80004d58:	79fe                	ld	s3,504(sp)
    80004d5a:	7a5e                	ld	s4,496(sp)
    80004d5c:	7abe                	ld	s5,488(sp)
    80004d5e:	7b1e                	ld	s6,480(sp)
    80004d60:	6bfe                	ld	s7,472(sp)
    80004d62:	6c5e                	ld	s8,464(sp)
    80004d64:	6cbe                	ld	s9,456(sp)
    80004d66:	6d1e                	ld	s10,448(sp)
    80004d68:	7dfa                	ld	s11,440(sp)
    80004d6a:	22010113          	addi	sp,sp,544
    80004d6e:	8082                	ret
    end_op();
    80004d70:	fffff097          	auipc	ra,0xfffff
    80004d74:	464080e7          	jalr	1124(ra) # 800041d4 <end_op>
    return -1;
    80004d78:	557d                	li	a0,-1
    80004d7a:	b7f9                	j	80004d48 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004d7c:	8526                	mv	a0,s1
    80004d7e:	ffffd097          	auipc	ra,0xffffd
    80004d82:	d62080e7          	jalr	-670(ra) # 80001ae0 <proc_pagetable>
    80004d86:	8b2a                	mv	s6,a0
    80004d88:	d555                	beqz	a0,80004d34 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d8a:	e6842783          	lw	a5,-408(s0)
    80004d8e:	e8045703          	lhu	a4,-384(s0)
    80004d92:	c735                	beqz	a4,80004dfe <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004d94:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d96:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004d9a:	6a05                	lui	s4,0x1
    80004d9c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004da0:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004da4:	6d85                	lui	s11,0x1
    80004da6:	7d7d                	lui	s10,0xfffff
    80004da8:	ac1d                	j	80004fde <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004daa:	00004517          	auipc	a0,0x4
    80004dae:	9de50513          	addi	a0,a0,-1570 # 80008788 <syscalls+0x298>
    80004db2:	ffffb097          	auipc	ra,0xffffb
    80004db6:	790080e7          	jalr	1936(ra) # 80000542 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004dba:	874a                	mv	a4,s2
    80004dbc:	009c86bb          	addw	a3,s9,s1
    80004dc0:	4581                	li	a1,0
    80004dc2:	8556                	mv	a0,s5
    80004dc4:	fffff097          	auipc	ra,0xfffff
    80004dc8:	c84080e7          	jalr	-892(ra) # 80003a48 <readi>
    80004dcc:	2501                	sext.w	a0,a0
    80004dce:	1aa91863          	bne	s2,a0,80004f7e <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004dd2:	009d84bb          	addw	s1,s11,s1
    80004dd6:	013d09bb          	addw	s3,s10,s3
    80004dda:	1f74f263          	bgeu	s1,s7,80004fbe <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004dde:	02049593          	slli	a1,s1,0x20
    80004de2:	9181                	srli	a1,a1,0x20
    80004de4:	95e2                	add	a1,a1,s8
    80004de6:	855a                	mv	a0,s6
    80004de8:	ffffc097          	auipc	ra,0xffffc
    80004dec:	2f2080e7          	jalr	754(ra) # 800010da <walkaddr>
    80004df0:	862a                	mv	a2,a0
    if(pa == 0)
    80004df2:	dd45                	beqz	a0,80004daa <exec+0xfe>
      n = PGSIZE;
    80004df4:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004df6:	fd49f2e3          	bgeu	s3,s4,80004dba <exec+0x10e>
      n = sz - i;
    80004dfa:	894e                	mv	s2,s3
    80004dfc:	bf7d                	j	80004dba <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004dfe:	4481                	li	s1,0
  iunlockput(ip);
    80004e00:	8556                	mv	a0,s5
    80004e02:	fffff097          	auipc	ra,0xfffff
    80004e06:	bf4080e7          	jalr	-1036(ra) # 800039f6 <iunlockput>
  end_op();
    80004e0a:	fffff097          	auipc	ra,0xfffff
    80004e0e:	3ca080e7          	jalr	970(ra) # 800041d4 <end_op>
  p = myproc();
    80004e12:	ffffd097          	auipc	ra,0xffffd
    80004e16:	c0a080e7          	jalr	-1014(ra) # 80001a1c <myproc>
    80004e1a:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004e1c:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004e20:	6785                	lui	a5,0x1
    80004e22:	17fd                	addi	a5,a5,-1
    80004e24:	94be                	add	s1,s1,a5
    80004e26:	77fd                	lui	a5,0xfffff
    80004e28:	8fe5                	and	a5,a5,s1
    80004e2a:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004e2e:	6609                	lui	a2,0x2
    80004e30:	963e                	add	a2,a2,a5
    80004e32:	85be                	mv	a1,a5
    80004e34:	855a                	mv	a0,s6
    80004e36:	ffffc097          	auipc	ra,0xffffc
    80004e3a:	688080e7          	jalr	1672(ra) # 800014be <uvmalloc>
    80004e3e:	8c2a                	mv	s8,a0
  ip = 0;
    80004e40:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004e42:	12050e63          	beqz	a0,80004f7e <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004e46:	75f9                	lui	a1,0xffffe
    80004e48:	95aa                	add	a1,a1,a0
    80004e4a:	855a                	mv	a0,s6
    80004e4c:	ffffd097          	auipc	ra,0xffffd
    80004e50:	890080e7          	jalr	-1904(ra) # 800016dc <uvmclear>
  stackbase = sp - PGSIZE;
    80004e54:	7afd                	lui	s5,0xfffff
    80004e56:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e58:	df043783          	ld	a5,-528(s0)
    80004e5c:	6388                	ld	a0,0(a5)
    80004e5e:	c925                	beqz	a0,80004ece <exec+0x222>
    80004e60:	e8840993          	addi	s3,s0,-376
    80004e64:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004e68:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004e6a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004e6c:	ffffc097          	auipc	ra,0xffffc
    80004e70:	064080e7          	jalr	100(ra) # 80000ed0 <strlen>
    80004e74:	0015079b          	addiw	a5,a0,1
    80004e78:	40f90933          	sub	s2,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004e7c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004e80:	13596363          	bltu	s2,s5,80004fa6 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004e84:	df043d83          	ld	s11,-528(s0)
    80004e88:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004e8c:	8552                	mv	a0,s4
    80004e8e:	ffffc097          	auipc	ra,0xffffc
    80004e92:	042080e7          	jalr	66(ra) # 80000ed0 <strlen>
    80004e96:	0015069b          	addiw	a3,a0,1
    80004e9a:	8652                	mv	a2,s4
    80004e9c:	85ca                	mv	a1,s2
    80004e9e:	855a                	mv	a0,s6
    80004ea0:	ffffd097          	auipc	ra,0xffffd
    80004ea4:	86e080e7          	jalr	-1938(ra) # 8000170e <copyout>
    80004ea8:	10054363          	bltz	a0,80004fae <exec+0x302>
    ustack[argc] = sp;
    80004eac:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004eb0:	0485                	addi	s1,s1,1
    80004eb2:	008d8793          	addi	a5,s11,8
    80004eb6:	def43823          	sd	a5,-528(s0)
    80004eba:	008db503          	ld	a0,8(s11)
    80004ebe:	c911                	beqz	a0,80004ed2 <exec+0x226>
    if(argc >= MAXARG)
    80004ec0:	09a1                	addi	s3,s3,8
    80004ec2:	fb3c95e3          	bne	s9,s3,80004e6c <exec+0x1c0>
  sz = sz1;
    80004ec6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004eca:	4a81                	li	s5,0
    80004ecc:	a84d                	j	80004f7e <exec+0x2d2>
  sp = sz;
    80004ece:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004ed0:	4481                	li	s1,0
  ustack[argc] = 0;
    80004ed2:	00349793          	slli	a5,s1,0x3
    80004ed6:	f9040713          	addi	a4,s0,-112
    80004eda:	97ba                	add	a5,a5,a4
    80004edc:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd8ef8>
  sp -= (argc+1) * sizeof(uint64);
    80004ee0:	00148693          	addi	a3,s1,1
    80004ee4:	068e                	slli	a3,a3,0x3
    80004ee6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004eea:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004eee:	01597663          	bgeu	s2,s5,80004efa <exec+0x24e>
  sz = sz1;
    80004ef2:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004ef6:	4a81                	li	s5,0
    80004ef8:	a059                	j	80004f7e <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004efa:	e8840613          	addi	a2,s0,-376
    80004efe:	85ca                	mv	a1,s2
    80004f00:	855a                	mv	a0,s6
    80004f02:	ffffd097          	auipc	ra,0xffffd
    80004f06:	80c080e7          	jalr	-2036(ra) # 8000170e <copyout>
    80004f0a:	0a054663          	bltz	a0,80004fb6 <exec+0x30a>
  p->trapframe->a1 = sp;
    80004f0e:	058bb783          	ld	a5,88(s7) # 1058 <_entry-0x7fffefa8>
    80004f12:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f16:	de843783          	ld	a5,-536(s0)
    80004f1a:	0007c703          	lbu	a4,0(a5)
    80004f1e:	cf11                	beqz	a4,80004f3a <exec+0x28e>
    80004f20:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f22:	02f00693          	li	a3,47
    80004f26:	a039                	j	80004f34 <exec+0x288>
      last = s+1;
    80004f28:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004f2c:	0785                	addi	a5,a5,1
    80004f2e:	fff7c703          	lbu	a4,-1(a5)
    80004f32:	c701                	beqz	a4,80004f3a <exec+0x28e>
    if(*s == '/')
    80004f34:	fed71ce3          	bne	a4,a3,80004f2c <exec+0x280>
    80004f38:	bfc5                	j	80004f28 <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f3a:	4641                	li	a2,16
    80004f3c:	de843583          	ld	a1,-536(s0)
    80004f40:	158b8513          	addi	a0,s7,344
    80004f44:	ffffc097          	auipc	ra,0xffffc
    80004f48:	f5a080e7          	jalr	-166(ra) # 80000e9e <safestrcpy>
  oldpagetable = p->pagetable;
    80004f4c:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004f50:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004f54:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004f58:	058bb783          	ld	a5,88(s7)
    80004f5c:	e6043703          	ld	a4,-416(s0)
    80004f60:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004f62:	058bb783          	ld	a5,88(s7)
    80004f66:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004f6a:	85ea                	mv	a1,s10
    80004f6c:	ffffd097          	auipc	ra,0xffffd
    80004f70:	c10080e7          	jalr	-1008(ra) # 80001b7c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004f74:	0004851b          	sext.w	a0,s1
    80004f78:	bbc1                	j	80004d48 <exec+0x9c>
    80004f7a:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004f7e:	df843583          	ld	a1,-520(s0)
    80004f82:	855a                	mv	a0,s6
    80004f84:	ffffd097          	auipc	ra,0xffffd
    80004f88:	bf8080e7          	jalr	-1032(ra) # 80001b7c <proc_freepagetable>
  if(ip){
    80004f8c:	da0a94e3          	bnez	s5,80004d34 <exec+0x88>
  return -1;
    80004f90:	557d                	li	a0,-1
    80004f92:	bb5d                	j	80004d48 <exec+0x9c>
    80004f94:	de943c23          	sd	s1,-520(s0)
    80004f98:	b7dd                	j	80004f7e <exec+0x2d2>
    80004f9a:	de943c23          	sd	s1,-520(s0)
    80004f9e:	b7c5                	j	80004f7e <exec+0x2d2>
    80004fa0:	de943c23          	sd	s1,-520(s0)
    80004fa4:	bfe9                	j	80004f7e <exec+0x2d2>
  sz = sz1;
    80004fa6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004faa:	4a81                	li	s5,0
    80004fac:	bfc9                	j	80004f7e <exec+0x2d2>
  sz = sz1;
    80004fae:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004fb2:	4a81                	li	s5,0
    80004fb4:	b7e9                	j	80004f7e <exec+0x2d2>
  sz = sz1;
    80004fb6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004fba:	4a81                	li	s5,0
    80004fbc:	b7c9                	j	80004f7e <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80004fbe:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fc2:	e0843783          	ld	a5,-504(s0)
    80004fc6:	0017869b          	addiw	a3,a5,1
    80004fca:	e0d43423          	sd	a3,-504(s0)
    80004fce:	e0043783          	ld	a5,-512(s0)
    80004fd2:	0387879b          	addiw	a5,a5,56
    80004fd6:	e8045703          	lhu	a4,-384(s0)
    80004fda:	e2e6d3e3          	bge	a3,a4,80004e00 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004fde:	2781                	sext.w	a5,a5
    80004fe0:	e0f43023          	sd	a5,-512(s0)
    80004fe4:	03800713          	li	a4,56
    80004fe8:	86be                	mv	a3,a5
    80004fea:	e1040613          	addi	a2,s0,-496
    80004fee:	4581                	li	a1,0
    80004ff0:	8556                	mv	a0,s5
    80004ff2:	fffff097          	auipc	ra,0xfffff
    80004ff6:	a56080e7          	jalr	-1450(ra) # 80003a48 <readi>
    80004ffa:	03800793          	li	a5,56
    80004ffe:	f6f51ee3          	bne	a0,a5,80004f7a <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80005002:	e1042783          	lw	a5,-496(s0)
    80005006:	4705                	li	a4,1
    80005008:	fae79de3          	bne	a5,a4,80004fc2 <exec+0x316>
    if(ph.memsz < ph.filesz)
    8000500c:	e3843603          	ld	a2,-456(s0)
    80005010:	e3043783          	ld	a5,-464(s0)
    80005014:	f8f660e3          	bltu	a2,a5,80004f94 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005018:	e2043783          	ld	a5,-480(s0)
    8000501c:	963e                	add	a2,a2,a5
    8000501e:	f6f66ee3          	bltu	a2,a5,80004f9a <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005022:	85a6                	mv	a1,s1
    80005024:	855a                	mv	a0,s6
    80005026:	ffffc097          	auipc	ra,0xffffc
    8000502a:	498080e7          	jalr	1176(ra) # 800014be <uvmalloc>
    8000502e:	dea43c23          	sd	a0,-520(s0)
    80005032:	d53d                	beqz	a0,80004fa0 <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    80005034:	e2043c03          	ld	s8,-480(s0)
    80005038:	de043783          	ld	a5,-544(s0)
    8000503c:	00fc77b3          	and	a5,s8,a5
    80005040:	ff9d                	bnez	a5,80004f7e <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005042:	e1842c83          	lw	s9,-488(s0)
    80005046:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000504a:	f60b8ae3          	beqz	s7,80004fbe <exec+0x312>
    8000504e:	89de                	mv	s3,s7
    80005050:	4481                	li	s1,0
    80005052:	b371                	j	80004dde <exec+0x132>

0000000080005054 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005054:	7179                	addi	sp,sp,-48
    80005056:	f406                	sd	ra,40(sp)
    80005058:	f022                	sd	s0,32(sp)
    8000505a:	ec26                	sd	s1,24(sp)
    8000505c:	e84a                	sd	s2,16(sp)
    8000505e:	1800                	addi	s0,sp,48
    80005060:	892e                	mv	s2,a1
    80005062:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005064:	fdc40593          	addi	a1,s0,-36
    80005068:	ffffe097          	auipc	ra,0xffffe
    8000506c:	a9c080e7          	jalr	-1380(ra) # 80002b04 <argint>
    80005070:	04054063          	bltz	a0,800050b0 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005074:	fdc42703          	lw	a4,-36(s0)
    80005078:	47bd                	li	a5,15
    8000507a:	02e7ed63          	bltu	a5,a4,800050b4 <argfd+0x60>
    8000507e:	ffffd097          	auipc	ra,0xffffd
    80005082:	99e080e7          	jalr	-1634(ra) # 80001a1c <myproc>
    80005086:	fdc42703          	lw	a4,-36(s0)
    8000508a:	01a70793          	addi	a5,a4,26
    8000508e:	078e                	slli	a5,a5,0x3
    80005090:	953e                	add	a0,a0,a5
    80005092:	611c                	ld	a5,0(a0)
    80005094:	c395                	beqz	a5,800050b8 <argfd+0x64>
    return -1;
  if(pfd)
    80005096:	00090463          	beqz	s2,8000509e <argfd+0x4a>
    *pfd = fd;
    8000509a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000509e:	4501                	li	a0,0
  if(pf)
    800050a0:	c091                	beqz	s1,800050a4 <argfd+0x50>
    *pf = f;
    800050a2:	e09c                	sd	a5,0(s1)
}
    800050a4:	70a2                	ld	ra,40(sp)
    800050a6:	7402                	ld	s0,32(sp)
    800050a8:	64e2                	ld	s1,24(sp)
    800050aa:	6942                	ld	s2,16(sp)
    800050ac:	6145                	addi	sp,sp,48
    800050ae:	8082                	ret
    return -1;
    800050b0:	557d                	li	a0,-1
    800050b2:	bfcd                	j	800050a4 <argfd+0x50>
    return -1;
    800050b4:	557d                	li	a0,-1
    800050b6:	b7fd                	j	800050a4 <argfd+0x50>
    800050b8:	557d                	li	a0,-1
    800050ba:	b7ed                	j	800050a4 <argfd+0x50>

00000000800050bc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800050bc:	1101                	addi	sp,sp,-32
    800050be:	ec06                	sd	ra,24(sp)
    800050c0:	e822                	sd	s0,16(sp)
    800050c2:	e426                	sd	s1,8(sp)
    800050c4:	1000                	addi	s0,sp,32
    800050c6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800050c8:	ffffd097          	auipc	ra,0xffffd
    800050cc:	954080e7          	jalr	-1708(ra) # 80001a1c <myproc>
    800050d0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800050d2:	0d050793          	addi	a5,a0,208
    800050d6:	4501                	li	a0,0
    800050d8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800050da:	6398                	ld	a4,0(a5)
    800050dc:	cb19                	beqz	a4,800050f2 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800050de:	2505                	addiw	a0,a0,1
    800050e0:	07a1                	addi	a5,a5,8
    800050e2:	fed51ce3          	bne	a0,a3,800050da <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800050e6:	557d                	li	a0,-1
}
    800050e8:	60e2                	ld	ra,24(sp)
    800050ea:	6442                	ld	s0,16(sp)
    800050ec:	64a2                	ld	s1,8(sp)
    800050ee:	6105                	addi	sp,sp,32
    800050f0:	8082                	ret
      p->ofile[fd] = f;
    800050f2:	01a50793          	addi	a5,a0,26
    800050f6:	078e                	slli	a5,a5,0x3
    800050f8:	963e                	add	a2,a2,a5
    800050fa:	e204                	sd	s1,0(a2)
      return fd;
    800050fc:	b7f5                	j	800050e8 <fdalloc+0x2c>

00000000800050fe <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800050fe:	715d                	addi	sp,sp,-80
    80005100:	e486                	sd	ra,72(sp)
    80005102:	e0a2                	sd	s0,64(sp)
    80005104:	fc26                	sd	s1,56(sp)
    80005106:	f84a                	sd	s2,48(sp)
    80005108:	f44e                	sd	s3,40(sp)
    8000510a:	f052                	sd	s4,32(sp)
    8000510c:	ec56                	sd	s5,24(sp)
    8000510e:	0880                	addi	s0,sp,80
    80005110:	89ae                	mv	s3,a1
    80005112:	8ab2                	mv	s5,a2
    80005114:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005116:	fb040593          	addi	a1,s0,-80
    8000511a:	fffff097          	auipc	ra,0xfffff
    8000511e:	e48080e7          	jalr	-440(ra) # 80003f62 <nameiparent>
    80005122:	892a                	mv	s2,a0
    80005124:	12050e63          	beqz	a0,80005260 <create+0x162>
    return 0;

  ilock(dp);
    80005128:	ffffe097          	auipc	ra,0xffffe
    8000512c:	66c080e7          	jalr	1644(ra) # 80003794 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005130:	4601                	li	a2,0
    80005132:	fb040593          	addi	a1,s0,-80
    80005136:	854a                	mv	a0,s2
    80005138:	fffff097          	auipc	ra,0xfffff
    8000513c:	b3a080e7          	jalr	-1222(ra) # 80003c72 <dirlookup>
    80005140:	84aa                	mv	s1,a0
    80005142:	c921                	beqz	a0,80005192 <create+0x94>
    iunlockput(dp);
    80005144:	854a                	mv	a0,s2
    80005146:	fffff097          	auipc	ra,0xfffff
    8000514a:	8b0080e7          	jalr	-1872(ra) # 800039f6 <iunlockput>
    ilock(ip);
    8000514e:	8526                	mv	a0,s1
    80005150:	ffffe097          	auipc	ra,0xffffe
    80005154:	644080e7          	jalr	1604(ra) # 80003794 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005158:	2981                	sext.w	s3,s3
    8000515a:	4789                	li	a5,2
    8000515c:	02f99463          	bne	s3,a5,80005184 <create+0x86>
    80005160:	0444d783          	lhu	a5,68(s1)
    80005164:	37f9                	addiw	a5,a5,-2
    80005166:	17c2                	slli	a5,a5,0x30
    80005168:	93c1                	srli	a5,a5,0x30
    8000516a:	4705                	li	a4,1
    8000516c:	00f76c63          	bltu	a4,a5,80005184 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80005170:	8526                	mv	a0,s1
    80005172:	60a6                	ld	ra,72(sp)
    80005174:	6406                	ld	s0,64(sp)
    80005176:	74e2                	ld	s1,56(sp)
    80005178:	7942                	ld	s2,48(sp)
    8000517a:	79a2                	ld	s3,40(sp)
    8000517c:	7a02                	ld	s4,32(sp)
    8000517e:	6ae2                	ld	s5,24(sp)
    80005180:	6161                	addi	sp,sp,80
    80005182:	8082                	ret
    iunlockput(ip);
    80005184:	8526                	mv	a0,s1
    80005186:	fffff097          	auipc	ra,0xfffff
    8000518a:	870080e7          	jalr	-1936(ra) # 800039f6 <iunlockput>
    return 0;
    8000518e:	4481                	li	s1,0
    80005190:	b7c5                	j	80005170 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80005192:	85ce                	mv	a1,s3
    80005194:	00092503          	lw	a0,0(s2)
    80005198:	ffffe097          	auipc	ra,0xffffe
    8000519c:	464080e7          	jalr	1124(ra) # 800035fc <ialloc>
    800051a0:	84aa                	mv	s1,a0
    800051a2:	c521                	beqz	a0,800051ea <create+0xec>
  ilock(ip);
    800051a4:	ffffe097          	auipc	ra,0xffffe
    800051a8:	5f0080e7          	jalr	1520(ra) # 80003794 <ilock>
  ip->major = major;
    800051ac:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800051b0:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800051b4:	4a05                	li	s4,1
    800051b6:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    800051ba:	8526                	mv	a0,s1
    800051bc:	ffffe097          	auipc	ra,0xffffe
    800051c0:	50e080e7          	jalr	1294(ra) # 800036ca <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800051c4:	2981                	sext.w	s3,s3
    800051c6:	03498a63          	beq	s3,s4,800051fa <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800051ca:	40d0                	lw	a2,4(s1)
    800051cc:	fb040593          	addi	a1,s0,-80
    800051d0:	854a                	mv	a0,s2
    800051d2:	fffff097          	auipc	ra,0xfffff
    800051d6:	cb0080e7          	jalr	-848(ra) # 80003e82 <dirlink>
    800051da:	06054b63          	bltz	a0,80005250 <create+0x152>
  iunlockput(dp);
    800051de:	854a                	mv	a0,s2
    800051e0:	fffff097          	auipc	ra,0xfffff
    800051e4:	816080e7          	jalr	-2026(ra) # 800039f6 <iunlockput>
  return ip;
    800051e8:	b761                	j	80005170 <create+0x72>
    panic("create: ialloc");
    800051ea:	00003517          	auipc	a0,0x3
    800051ee:	5be50513          	addi	a0,a0,1470 # 800087a8 <syscalls+0x2b8>
    800051f2:	ffffb097          	auipc	ra,0xffffb
    800051f6:	350080e7          	jalr	848(ra) # 80000542 <panic>
    dp->nlink++;  // for ".."
    800051fa:	04a95783          	lhu	a5,74(s2)
    800051fe:	2785                	addiw	a5,a5,1
    80005200:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005204:	854a                	mv	a0,s2
    80005206:	ffffe097          	auipc	ra,0xffffe
    8000520a:	4c4080e7          	jalr	1220(ra) # 800036ca <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000520e:	40d0                	lw	a2,4(s1)
    80005210:	00003597          	auipc	a1,0x3
    80005214:	5a858593          	addi	a1,a1,1448 # 800087b8 <syscalls+0x2c8>
    80005218:	8526                	mv	a0,s1
    8000521a:	fffff097          	auipc	ra,0xfffff
    8000521e:	c68080e7          	jalr	-920(ra) # 80003e82 <dirlink>
    80005222:	00054f63          	bltz	a0,80005240 <create+0x142>
    80005226:	00492603          	lw	a2,4(s2)
    8000522a:	00003597          	auipc	a1,0x3
    8000522e:	59658593          	addi	a1,a1,1430 # 800087c0 <syscalls+0x2d0>
    80005232:	8526                	mv	a0,s1
    80005234:	fffff097          	auipc	ra,0xfffff
    80005238:	c4e080e7          	jalr	-946(ra) # 80003e82 <dirlink>
    8000523c:	f80557e3          	bgez	a0,800051ca <create+0xcc>
      panic("create dots");
    80005240:	00003517          	auipc	a0,0x3
    80005244:	58850513          	addi	a0,a0,1416 # 800087c8 <syscalls+0x2d8>
    80005248:	ffffb097          	auipc	ra,0xffffb
    8000524c:	2fa080e7          	jalr	762(ra) # 80000542 <panic>
    panic("create: dirlink");
    80005250:	00003517          	auipc	a0,0x3
    80005254:	58850513          	addi	a0,a0,1416 # 800087d8 <syscalls+0x2e8>
    80005258:	ffffb097          	auipc	ra,0xffffb
    8000525c:	2ea080e7          	jalr	746(ra) # 80000542 <panic>
    return 0;
    80005260:	84aa                	mv	s1,a0
    80005262:	b739                	j	80005170 <create+0x72>

0000000080005264 <sys_dup>:
{
    80005264:	7179                	addi	sp,sp,-48
    80005266:	f406                	sd	ra,40(sp)
    80005268:	f022                	sd	s0,32(sp)
    8000526a:	ec26                	sd	s1,24(sp)
    8000526c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000526e:	fd840613          	addi	a2,s0,-40
    80005272:	4581                	li	a1,0
    80005274:	4501                	li	a0,0
    80005276:	00000097          	auipc	ra,0x0
    8000527a:	dde080e7          	jalr	-546(ra) # 80005054 <argfd>
    return -1;
    8000527e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005280:	02054363          	bltz	a0,800052a6 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005284:	fd843503          	ld	a0,-40(s0)
    80005288:	00000097          	auipc	ra,0x0
    8000528c:	e34080e7          	jalr	-460(ra) # 800050bc <fdalloc>
    80005290:	84aa                	mv	s1,a0
    return -1;
    80005292:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005294:	00054963          	bltz	a0,800052a6 <sys_dup+0x42>
  filedup(f);
    80005298:	fd843503          	ld	a0,-40(s0)
    8000529c:	fffff097          	auipc	ra,0xfffff
    800052a0:	338080e7          	jalr	824(ra) # 800045d4 <filedup>
  return fd;
    800052a4:	87a6                	mv	a5,s1
}
    800052a6:	853e                	mv	a0,a5
    800052a8:	70a2                	ld	ra,40(sp)
    800052aa:	7402                	ld	s0,32(sp)
    800052ac:	64e2                	ld	s1,24(sp)
    800052ae:	6145                	addi	sp,sp,48
    800052b0:	8082                	ret

00000000800052b2 <sys_read>:
{
    800052b2:	7179                	addi	sp,sp,-48
    800052b4:	f406                	sd	ra,40(sp)
    800052b6:	f022                	sd	s0,32(sp)
    800052b8:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052ba:	fe840613          	addi	a2,s0,-24
    800052be:	4581                	li	a1,0
    800052c0:	4501                	li	a0,0
    800052c2:	00000097          	auipc	ra,0x0
    800052c6:	d92080e7          	jalr	-622(ra) # 80005054 <argfd>
    return -1;
    800052ca:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052cc:	04054163          	bltz	a0,8000530e <sys_read+0x5c>
    800052d0:	fe440593          	addi	a1,s0,-28
    800052d4:	4509                	li	a0,2
    800052d6:	ffffe097          	auipc	ra,0xffffe
    800052da:	82e080e7          	jalr	-2002(ra) # 80002b04 <argint>
    return -1;
    800052de:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052e0:	02054763          	bltz	a0,8000530e <sys_read+0x5c>
    800052e4:	fd840593          	addi	a1,s0,-40
    800052e8:	4505                	li	a0,1
    800052ea:	ffffe097          	auipc	ra,0xffffe
    800052ee:	83c080e7          	jalr	-1988(ra) # 80002b26 <argaddr>
    return -1;
    800052f2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800052f4:	00054d63          	bltz	a0,8000530e <sys_read+0x5c>
  return fileread(f, p, n);
    800052f8:	fe442603          	lw	a2,-28(s0)
    800052fc:	fd843583          	ld	a1,-40(s0)
    80005300:	fe843503          	ld	a0,-24(s0)
    80005304:	fffff097          	auipc	ra,0xfffff
    80005308:	45c080e7          	jalr	1116(ra) # 80004760 <fileread>
    8000530c:	87aa                	mv	a5,a0
}
    8000530e:	853e                	mv	a0,a5
    80005310:	70a2                	ld	ra,40(sp)
    80005312:	7402                	ld	s0,32(sp)
    80005314:	6145                	addi	sp,sp,48
    80005316:	8082                	ret

0000000080005318 <sys_write>:
{
    80005318:	7179                	addi	sp,sp,-48
    8000531a:	f406                	sd	ra,40(sp)
    8000531c:	f022                	sd	s0,32(sp)
    8000531e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005320:	fe840613          	addi	a2,s0,-24
    80005324:	4581                	li	a1,0
    80005326:	4501                	li	a0,0
    80005328:	00000097          	auipc	ra,0x0
    8000532c:	d2c080e7          	jalr	-724(ra) # 80005054 <argfd>
    return -1;
    80005330:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005332:	04054163          	bltz	a0,80005374 <sys_write+0x5c>
    80005336:	fe440593          	addi	a1,s0,-28
    8000533a:	4509                	li	a0,2
    8000533c:	ffffd097          	auipc	ra,0xffffd
    80005340:	7c8080e7          	jalr	1992(ra) # 80002b04 <argint>
    return -1;
    80005344:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005346:	02054763          	bltz	a0,80005374 <sys_write+0x5c>
    8000534a:	fd840593          	addi	a1,s0,-40
    8000534e:	4505                	li	a0,1
    80005350:	ffffd097          	auipc	ra,0xffffd
    80005354:	7d6080e7          	jalr	2006(ra) # 80002b26 <argaddr>
    return -1;
    80005358:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000535a:	00054d63          	bltz	a0,80005374 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000535e:	fe442603          	lw	a2,-28(s0)
    80005362:	fd843583          	ld	a1,-40(s0)
    80005366:	fe843503          	ld	a0,-24(s0)
    8000536a:	fffff097          	auipc	ra,0xfffff
    8000536e:	4b8080e7          	jalr	1208(ra) # 80004822 <filewrite>
    80005372:	87aa                	mv	a5,a0
}
    80005374:	853e                	mv	a0,a5
    80005376:	70a2                	ld	ra,40(sp)
    80005378:	7402                	ld	s0,32(sp)
    8000537a:	6145                	addi	sp,sp,48
    8000537c:	8082                	ret

000000008000537e <sys_close>:
{
    8000537e:	1101                	addi	sp,sp,-32
    80005380:	ec06                	sd	ra,24(sp)
    80005382:	e822                	sd	s0,16(sp)
    80005384:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005386:	fe040613          	addi	a2,s0,-32
    8000538a:	fec40593          	addi	a1,s0,-20
    8000538e:	4501                	li	a0,0
    80005390:	00000097          	auipc	ra,0x0
    80005394:	cc4080e7          	jalr	-828(ra) # 80005054 <argfd>
    return -1;
    80005398:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000539a:	02054463          	bltz	a0,800053c2 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000539e:	ffffc097          	auipc	ra,0xffffc
    800053a2:	67e080e7          	jalr	1662(ra) # 80001a1c <myproc>
    800053a6:	fec42783          	lw	a5,-20(s0)
    800053aa:	07e9                	addi	a5,a5,26
    800053ac:	078e                	slli	a5,a5,0x3
    800053ae:	97aa                	add	a5,a5,a0
    800053b0:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800053b4:	fe043503          	ld	a0,-32(s0)
    800053b8:	fffff097          	auipc	ra,0xfffff
    800053bc:	26e080e7          	jalr	622(ra) # 80004626 <fileclose>
  return 0;
    800053c0:	4781                	li	a5,0
}
    800053c2:	853e                	mv	a0,a5
    800053c4:	60e2                	ld	ra,24(sp)
    800053c6:	6442                	ld	s0,16(sp)
    800053c8:	6105                	addi	sp,sp,32
    800053ca:	8082                	ret

00000000800053cc <sys_fstat>:
{
    800053cc:	1101                	addi	sp,sp,-32
    800053ce:	ec06                	sd	ra,24(sp)
    800053d0:	e822                	sd	s0,16(sp)
    800053d2:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053d4:	fe840613          	addi	a2,s0,-24
    800053d8:	4581                	li	a1,0
    800053da:	4501                	li	a0,0
    800053dc:	00000097          	auipc	ra,0x0
    800053e0:	c78080e7          	jalr	-904(ra) # 80005054 <argfd>
    return -1;
    800053e4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053e6:	02054563          	bltz	a0,80005410 <sys_fstat+0x44>
    800053ea:	fe040593          	addi	a1,s0,-32
    800053ee:	4505                	li	a0,1
    800053f0:	ffffd097          	auipc	ra,0xffffd
    800053f4:	736080e7          	jalr	1846(ra) # 80002b26 <argaddr>
    return -1;
    800053f8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800053fa:	00054b63          	bltz	a0,80005410 <sys_fstat+0x44>
  return filestat(f, st);
    800053fe:	fe043583          	ld	a1,-32(s0)
    80005402:	fe843503          	ld	a0,-24(s0)
    80005406:	fffff097          	auipc	ra,0xfffff
    8000540a:	2e8080e7          	jalr	744(ra) # 800046ee <filestat>
    8000540e:	87aa                	mv	a5,a0
}
    80005410:	853e                	mv	a0,a5
    80005412:	60e2                	ld	ra,24(sp)
    80005414:	6442                	ld	s0,16(sp)
    80005416:	6105                	addi	sp,sp,32
    80005418:	8082                	ret

000000008000541a <sys_link>:
{
    8000541a:	7169                	addi	sp,sp,-304
    8000541c:	f606                	sd	ra,296(sp)
    8000541e:	f222                	sd	s0,288(sp)
    80005420:	ee26                	sd	s1,280(sp)
    80005422:	ea4a                	sd	s2,272(sp)
    80005424:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005426:	08000613          	li	a2,128
    8000542a:	ed040593          	addi	a1,s0,-304
    8000542e:	4501                	li	a0,0
    80005430:	ffffd097          	auipc	ra,0xffffd
    80005434:	718080e7          	jalr	1816(ra) # 80002b48 <argstr>
    return -1;
    80005438:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000543a:	10054e63          	bltz	a0,80005556 <sys_link+0x13c>
    8000543e:	08000613          	li	a2,128
    80005442:	f5040593          	addi	a1,s0,-176
    80005446:	4505                	li	a0,1
    80005448:	ffffd097          	auipc	ra,0xffffd
    8000544c:	700080e7          	jalr	1792(ra) # 80002b48 <argstr>
    return -1;
    80005450:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005452:	10054263          	bltz	a0,80005556 <sys_link+0x13c>
  begin_op();
    80005456:	fffff097          	auipc	ra,0xfffff
    8000545a:	cfe080e7          	jalr	-770(ra) # 80004154 <begin_op>
  if((ip = namei(old)) == 0){
    8000545e:	ed040513          	addi	a0,s0,-304
    80005462:	fffff097          	auipc	ra,0xfffff
    80005466:	ae2080e7          	jalr	-1310(ra) # 80003f44 <namei>
    8000546a:	84aa                	mv	s1,a0
    8000546c:	c551                	beqz	a0,800054f8 <sys_link+0xde>
  ilock(ip);
    8000546e:	ffffe097          	auipc	ra,0xffffe
    80005472:	326080e7          	jalr	806(ra) # 80003794 <ilock>
  if(ip->type == T_DIR){
    80005476:	04449703          	lh	a4,68(s1)
    8000547a:	4785                	li	a5,1
    8000547c:	08f70463          	beq	a4,a5,80005504 <sys_link+0xea>
  ip->nlink++;
    80005480:	04a4d783          	lhu	a5,74(s1)
    80005484:	2785                	addiw	a5,a5,1
    80005486:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000548a:	8526                	mv	a0,s1
    8000548c:	ffffe097          	auipc	ra,0xffffe
    80005490:	23e080e7          	jalr	574(ra) # 800036ca <iupdate>
  iunlock(ip);
    80005494:	8526                	mv	a0,s1
    80005496:	ffffe097          	auipc	ra,0xffffe
    8000549a:	3c0080e7          	jalr	960(ra) # 80003856 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000549e:	fd040593          	addi	a1,s0,-48
    800054a2:	f5040513          	addi	a0,s0,-176
    800054a6:	fffff097          	auipc	ra,0xfffff
    800054aa:	abc080e7          	jalr	-1348(ra) # 80003f62 <nameiparent>
    800054ae:	892a                	mv	s2,a0
    800054b0:	c935                	beqz	a0,80005524 <sys_link+0x10a>
  ilock(dp);
    800054b2:	ffffe097          	auipc	ra,0xffffe
    800054b6:	2e2080e7          	jalr	738(ra) # 80003794 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800054ba:	00092703          	lw	a4,0(s2)
    800054be:	409c                	lw	a5,0(s1)
    800054c0:	04f71d63          	bne	a4,a5,8000551a <sys_link+0x100>
    800054c4:	40d0                	lw	a2,4(s1)
    800054c6:	fd040593          	addi	a1,s0,-48
    800054ca:	854a                	mv	a0,s2
    800054cc:	fffff097          	auipc	ra,0xfffff
    800054d0:	9b6080e7          	jalr	-1610(ra) # 80003e82 <dirlink>
    800054d4:	04054363          	bltz	a0,8000551a <sys_link+0x100>
  iunlockput(dp);
    800054d8:	854a                	mv	a0,s2
    800054da:	ffffe097          	auipc	ra,0xffffe
    800054de:	51c080e7          	jalr	1308(ra) # 800039f6 <iunlockput>
  iput(ip);
    800054e2:	8526                	mv	a0,s1
    800054e4:	ffffe097          	auipc	ra,0xffffe
    800054e8:	46a080e7          	jalr	1130(ra) # 8000394e <iput>
  end_op();
    800054ec:	fffff097          	auipc	ra,0xfffff
    800054f0:	ce8080e7          	jalr	-792(ra) # 800041d4 <end_op>
  return 0;
    800054f4:	4781                	li	a5,0
    800054f6:	a085                	j	80005556 <sys_link+0x13c>
    end_op();
    800054f8:	fffff097          	auipc	ra,0xfffff
    800054fc:	cdc080e7          	jalr	-804(ra) # 800041d4 <end_op>
    return -1;
    80005500:	57fd                	li	a5,-1
    80005502:	a891                	j	80005556 <sys_link+0x13c>
    iunlockput(ip);
    80005504:	8526                	mv	a0,s1
    80005506:	ffffe097          	auipc	ra,0xffffe
    8000550a:	4f0080e7          	jalr	1264(ra) # 800039f6 <iunlockput>
    end_op();
    8000550e:	fffff097          	auipc	ra,0xfffff
    80005512:	cc6080e7          	jalr	-826(ra) # 800041d4 <end_op>
    return -1;
    80005516:	57fd                	li	a5,-1
    80005518:	a83d                	j	80005556 <sys_link+0x13c>
    iunlockput(dp);
    8000551a:	854a                	mv	a0,s2
    8000551c:	ffffe097          	auipc	ra,0xffffe
    80005520:	4da080e7          	jalr	1242(ra) # 800039f6 <iunlockput>
  ilock(ip);
    80005524:	8526                	mv	a0,s1
    80005526:	ffffe097          	auipc	ra,0xffffe
    8000552a:	26e080e7          	jalr	622(ra) # 80003794 <ilock>
  ip->nlink--;
    8000552e:	04a4d783          	lhu	a5,74(s1)
    80005532:	37fd                	addiw	a5,a5,-1
    80005534:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005538:	8526                	mv	a0,s1
    8000553a:	ffffe097          	auipc	ra,0xffffe
    8000553e:	190080e7          	jalr	400(ra) # 800036ca <iupdate>
  iunlockput(ip);
    80005542:	8526                	mv	a0,s1
    80005544:	ffffe097          	auipc	ra,0xffffe
    80005548:	4b2080e7          	jalr	1202(ra) # 800039f6 <iunlockput>
  end_op();
    8000554c:	fffff097          	auipc	ra,0xfffff
    80005550:	c88080e7          	jalr	-888(ra) # 800041d4 <end_op>
  return -1;
    80005554:	57fd                	li	a5,-1
}
    80005556:	853e                	mv	a0,a5
    80005558:	70b2                	ld	ra,296(sp)
    8000555a:	7412                	ld	s0,288(sp)
    8000555c:	64f2                	ld	s1,280(sp)
    8000555e:	6952                	ld	s2,272(sp)
    80005560:	6155                	addi	sp,sp,304
    80005562:	8082                	ret

0000000080005564 <sys_unlink>:
{
    80005564:	7151                	addi	sp,sp,-240
    80005566:	f586                	sd	ra,232(sp)
    80005568:	f1a2                	sd	s0,224(sp)
    8000556a:	eda6                	sd	s1,216(sp)
    8000556c:	e9ca                	sd	s2,208(sp)
    8000556e:	e5ce                	sd	s3,200(sp)
    80005570:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005572:	08000613          	li	a2,128
    80005576:	f3040593          	addi	a1,s0,-208
    8000557a:	4501                	li	a0,0
    8000557c:	ffffd097          	auipc	ra,0xffffd
    80005580:	5cc080e7          	jalr	1484(ra) # 80002b48 <argstr>
    80005584:	18054163          	bltz	a0,80005706 <sys_unlink+0x1a2>
  begin_op();
    80005588:	fffff097          	auipc	ra,0xfffff
    8000558c:	bcc080e7          	jalr	-1076(ra) # 80004154 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005590:	fb040593          	addi	a1,s0,-80
    80005594:	f3040513          	addi	a0,s0,-208
    80005598:	fffff097          	auipc	ra,0xfffff
    8000559c:	9ca080e7          	jalr	-1590(ra) # 80003f62 <nameiparent>
    800055a0:	84aa                	mv	s1,a0
    800055a2:	c979                	beqz	a0,80005678 <sys_unlink+0x114>
  ilock(dp);
    800055a4:	ffffe097          	auipc	ra,0xffffe
    800055a8:	1f0080e7          	jalr	496(ra) # 80003794 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800055ac:	00003597          	auipc	a1,0x3
    800055b0:	20c58593          	addi	a1,a1,524 # 800087b8 <syscalls+0x2c8>
    800055b4:	fb040513          	addi	a0,s0,-80
    800055b8:	ffffe097          	auipc	ra,0xffffe
    800055bc:	6a0080e7          	jalr	1696(ra) # 80003c58 <namecmp>
    800055c0:	14050a63          	beqz	a0,80005714 <sys_unlink+0x1b0>
    800055c4:	00003597          	auipc	a1,0x3
    800055c8:	1fc58593          	addi	a1,a1,508 # 800087c0 <syscalls+0x2d0>
    800055cc:	fb040513          	addi	a0,s0,-80
    800055d0:	ffffe097          	auipc	ra,0xffffe
    800055d4:	688080e7          	jalr	1672(ra) # 80003c58 <namecmp>
    800055d8:	12050e63          	beqz	a0,80005714 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800055dc:	f2c40613          	addi	a2,s0,-212
    800055e0:	fb040593          	addi	a1,s0,-80
    800055e4:	8526                	mv	a0,s1
    800055e6:	ffffe097          	auipc	ra,0xffffe
    800055ea:	68c080e7          	jalr	1676(ra) # 80003c72 <dirlookup>
    800055ee:	892a                	mv	s2,a0
    800055f0:	12050263          	beqz	a0,80005714 <sys_unlink+0x1b0>
  ilock(ip);
    800055f4:	ffffe097          	auipc	ra,0xffffe
    800055f8:	1a0080e7          	jalr	416(ra) # 80003794 <ilock>
  if(ip->nlink < 1)
    800055fc:	04a91783          	lh	a5,74(s2)
    80005600:	08f05263          	blez	a5,80005684 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005604:	04491703          	lh	a4,68(s2)
    80005608:	4785                	li	a5,1
    8000560a:	08f70563          	beq	a4,a5,80005694 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000560e:	4641                	li	a2,16
    80005610:	4581                	li	a1,0
    80005612:	fc040513          	addi	a0,s0,-64
    80005616:	ffffb097          	auipc	ra,0xffffb
    8000561a:	736080e7          	jalr	1846(ra) # 80000d4c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000561e:	4741                	li	a4,16
    80005620:	f2c42683          	lw	a3,-212(s0)
    80005624:	fc040613          	addi	a2,s0,-64
    80005628:	4581                	li	a1,0
    8000562a:	8526                	mv	a0,s1
    8000562c:	ffffe097          	auipc	ra,0xffffe
    80005630:	512080e7          	jalr	1298(ra) # 80003b3e <writei>
    80005634:	47c1                	li	a5,16
    80005636:	0af51563          	bne	a0,a5,800056e0 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    8000563a:	04491703          	lh	a4,68(s2)
    8000563e:	4785                	li	a5,1
    80005640:	0af70863          	beq	a4,a5,800056f0 <sys_unlink+0x18c>
  iunlockput(dp);
    80005644:	8526                	mv	a0,s1
    80005646:	ffffe097          	auipc	ra,0xffffe
    8000564a:	3b0080e7          	jalr	944(ra) # 800039f6 <iunlockput>
  ip->nlink--;
    8000564e:	04a95783          	lhu	a5,74(s2)
    80005652:	37fd                	addiw	a5,a5,-1
    80005654:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005658:	854a                	mv	a0,s2
    8000565a:	ffffe097          	auipc	ra,0xffffe
    8000565e:	070080e7          	jalr	112(ra) # 800036ca <iupdate>
  iunlockput(ip);
    80005662:	854a                	mv	a0,s2
    80005664:	ffffe097          	auipc	ra,0xffffe
    80005668:	392080e7          	jalr	914(ra) # 800039f6 <iunlockput>
  end_op();
    8000566c:	fffff097          	auipc	ra,0xfffff
    80005670:	b68080e7          	jalr	-1176(ra) # 800041d4 <end_op>
  return 0;
    80005674:	4501                	li	a0,0
    80005676:	a84d                	j	80005728 <sys_unlink+0x1c4>
    end_op();
    80005678:	fffff097          	auipc	ra,0xfffff
    8000567c:	b5c080e7          	jalr	-1188(ra) # 800041d4 <end_op>
    return -1;
    80005680:	557d                	li	a0,-1
    80005682:	a05d                	j	80005728 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005684:	00003517          	auipc	a0,0x3
    80005688:	16450513          	addi	a0,a0,356 # 800087e8 <syscalls+0x2f8>
    8000568c:	ffffb097          	auipc	ra,0xffffb
    80005690:	eb6080e7          	jalr	-330(ra) # 80000542 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005694:	04c92703          	lw	a4,76(s2)
    80005698:	02000793          	li	a5,32
    8000569c:	f6e7f9e3          	bgeu	a5,a4,8000560e <sys_unlink+0xaa>
    800056a0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056a4:	4741                	li	a4,16
    800056a6:	86ce                	mv	a3,s3
    800056a8:	f1840613          	addi	a2,s0,-232
    800056ac:	4581                	li	a1,0
    800056ae:	854a                	mv	a0,s2
    800056b0:	ffffe097          	auipc	ra,0xffffe
    800056b4:	398080e7          	jalr	920(ra) # 80003a48 <readi>
    800056b8:	47c1                	li	a5,16
    800056ba:	00f51b63          	bne	a0,a5,800056d0 <sys_unlink+0x16c>
    if(de.inum != 0)
    800056be:	f1845783          	lhu	a5,-232(s0)
    800056c2:	e7a1                	bnez	a5,8000570a <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056c4:	29c1                	addiw	s3,s3,16
    800056c6:	04c92783          	lw	a5,76(s2)
    800056ca:	fcf9ede3          	bltu	s3,a5,800056a4 <sys_unlink+0x140>
    800056ce:	b781                	j	8000560e <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800056d0:	00003517          	auipc	a0,0x3
    800056d4:	13050513          	addi	a0,a0,304 # 80008800 <syscalls+0x310>
    800056d8:	ffffb097          	auipc	ra,0xffffb
    800056dc:	e6a080e7          	jalr	-406(ra) # 80000542 <panic>
    panic("unlink: writei");
    800056e0:	00003517          	auipc	a0,0x3
    800056e4:	13850513          	addi	a0,a0,312 # 80008818 <syscalls+0x328>
    800056e8:	ffffb097          	auipc	ra,0xffffb
    800056ec:	e5a080e7          	jalr	-422(ra) # 80000542 <panic>
    dp->nlink--;
    800056f0:	04a4d783          	lhu	a5,74(s1)
    800056f4:	37fd                	addiw	a5,a5,-1
    800056f6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056fa:	8526                	mv	a0,s1
    800056fc:	ffffe097          	auipc	ra,0xffffe
    80005700:	fce080e7          	jalr	-50(ra) # 800036ca <iupdate>
    80005704:	b781                	j	80005644 <sys_unlink+0xe0>
    return -1;
    80005706:	557d                	li	a0,-1
    80005708:	a005                	j	80005728 <sys_unlink+0x1c4>
    iunlockput(ip);
    8000570a:	854a                	mv	a0,s2
    8000570c:	ffffe097          	auipc	ra,0xffffe
    80005710:	2ea080e7          	jalr	746(ra) # 800039f6 <iunlockput>
  iunlockput(dp);
    80005714:	8526                	mv	a0,s1
    80005716:	ffffe097          	auipc	ra,0xffffe
    8000571a:	2e0080e7          	jalr	736(ra) # 800039f6 <iunlockput>
  end_op();
    8000571e:	fffff097          	auipc	ra,0xfffff
    80005722:	ab6080e7          	jalr	-1354(ra) # 800041d4 <end_op>
  return -1;
    80005726:	557d                	li	a0,-1
}
    80005728:	70ae                	ld	ra,232(sp)
    8000572a:	740e                	ld	s0,224(sp)
    8000572c:	64ee                	ld	s1,216(sp)
    8000572e:	694e                	ld	s2,208(sp)
    80005730:	69ae                	ld	s3,200(sp)
    80005732:	616d                	addi	sp,sp,240
    80005734:	8082                	ret

0000000080005736 <sys_open>:

uint64
sys_open(void)
{
    80005736:	7131                	addi	sp,sp,-192
    80005738:	fd06                	sd	ra,184(sp)
    8000573a:	f922                	sd	s0,176(sp)
    8000573c:	f526                	sd	s1,168(sp)
    8000573e:	f14a                	sd	s2,160(sp)
    80005740:	ed4e                	sd	s3,152(sp)
    80005742:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005744:	08000613          	li	a2,128
    80005748:	f5040593          	addi	a1,s0,-176
    8000574c:	4501                	li	a0,0
    8000574e:	ffffd097          	auipc	ra,0xffffd
    80005752:	3fa080e7          	jalr	1018(ra) # 80002b48 <argstr>
    return -1;
    80005756:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005758:	0c054163          	bltz	a0,8000581a <sys_open+0xe4>
    8000575c:	f4c40593          	addi	a1,s0,-180
    80005760:	4505                	li	a0,1
    80005762:	ffffd097          	auipc	ra,0xffffd
    80005766:	3a2080e7          	jalr	930(ra) # 80002b04 <argint>
    8000576a:	0a054863          	bltz	a0,8000581a <sys_open+0xe4>

  begin_op();
    8000576e:	fffff097          	auipc	ra,0xfffff
    80005772:	9e6080e7          	jalr	-1562(ra) # 80004154 <begin_op>

  if(omode & O_CREATE){
    80005776:	f4c42783          	lw	a5,-180(s0)
    8000577a:	2007f793          	andi	a5,a5,512
    8000577e:	cbdd                	beqz	a5,80005834 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005780:	4681                	li	a3,0
    80005782:	4601                	li	a2,0
    80005784:	4589                	li	a1,2
    80005786:	f5040513          	addi	a0,s0,-176
    8000578a:	00000097          	auipc	ra,0x0
    8000578e:	974080e7          	jalr	-1676(ra) # 800050fe <create>
    80005792:	892a                	mv	s2,a0
    if(ip == 0){
    80005794:	c959                	beqz	a0,8000582a <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005796:	04491703          	lh	a4,68(s2)
    8000579a:	478d                	li	a5,3
    8000579c:	00f71763          	bne	a4,a5,800057aa <sys_open+0x74>
    800057a0:	04695703          	lhu	a4,70(s2)
    800057a4:	47a5                	li	a5,9
    800057a6:	0ce7ec63          	bltu	a5,a4,8000587e <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800057aa:	fffff097          	auipc	ra,0xfffff
    800057ae:	dc0080e7          	jalr	-576(ra) # 8000456a <filealloc>
    800057b2:	89aa                	mv	s3,a0
    800057b4:	10050263          	beqz	a0,800058b8 <sys_open+0x182>
    800057b8:	00000097          	auipc	ra,0x0
    800057bc:	904080e7          	jalr	-1788(ra) # 800050bc <fdalloc>
    800057c0:	84aa                	mv	s1,a0
    800057c2:	0e054663          	bltz	a0,800058ae <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800057c6:	04491703          	lh	a4,68(s2)
    800057ca:	478d                	li	a5,3
    800057cc:	0cf70463          	beq	a4,a5,80005894 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800057d0:	4789                	li	a5,2
    800057d2:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    800057d6:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    800057da:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    800057de:	f4c42783          	lw	a5,-180(s0)
    800057e2:	0017c713          	xori	a4,a5,1
    800057e6:	8b05                	andi	a4,a4,1
    800057e8:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800057ec:	0037f713          	andi	a4,a5,3
    800057f0:	00e03733          	snez	a4,a4
    800057f4:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800057f8:	4007f793          	andi	a5,a5,1024
    800057fc:	c791                	beqz	a5,80005808 <sys_open+0xd2>
    800057fe:	04491703          	lh	a4,68(s2)
    80005802:	4789                	li	a5,2
    80005804:	08f70f63          	beq	a4,a5,800058a2 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005808:	854a                	mv	a0,s2
    8000580a:	ffffe097          	auipc	ra,0xffffe
    8000580e:	04c080e7          	jalr	76(ra) # 80003856 <iunlock>
  end_op();
    80005812:	fffff097          	auipc	ra,0xfffff
    80005816:	9c2080e7          	jalr	-1598(ra) # 800041d4 <end_op>

  return fd;
}
    8000581a:	8526                	mv	a0,s1
    8000581c:	70ea                	ld	ra,184(sp)
    8000581e:	744a                	ld	s0,176(sp)
    80005820:	74aa                	ld	s1,168(sp)
    80005822:	790a                	ld	s2,160(sp)
    80005824:	69ea                	ld	s3,152(sp)
    80005826:	6129                	addi	sp,sp,192
    80005828:	8082                	ret
      end_op();
    8000582a:	fffff097          	auipc	ra,0xfffff
    8000582e:	9aa080e7          	jalr	-1622(ra) # 800041d4 <end_op>
      return -1;
    80005832:	b7e5                	j	8000581a <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005834:	f5040513          	addi	a0,s0,-176
    80005838:	ffffe097          	auipc	ra,0xffffe
    8000583c:	70c080e7          	jalr	1804(ra) # 80003f44 <namei>
    80005840:	892a                	mv	s2,a0
    80005842:	c905                	beqz	a0,80005872 <sys_open+0x13c>
    ilock(ip);
    80005844:	ffffe097          	auipc	ra,0xffffe
    80005848:	f50080e7          	jalr	-176(ra) # 80003794 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000584c:	04491703          	lh	a4,68(s2)
    80005850:	4785                	li	a5,1
    80005852:	f4f712e3          	bne	a4,a5,80005796 <sys_open+0x60>
    80005856:	f4c42783          	lw	a5,-180(s0)
    8000585a:	dba1                	beqz	a5,800057aa <sys_open+0x74>
      iunlockput(ip);
    8000585c:	854a                	mv	a0,s2
    8000585e:	ffffe097          	auipc	ra,0xffffe
    80005862:	198080e7          	jalr	408(ra) # 800039f6 <iunlockput>
      end_op();
    80005866:	fffff097          	auipc	ra,0xfffff
    8000586a:	96e080e7          	jalr	-1682(ra) # 800041d4 <end_op>
      return -1;
    8000586e:	54fd                	li	s1,-1
    80005870:	b76d                	j	8000581a <sys_open+0xe4>
      end_op();
    80005872:	fffff097          	auipc	ra,0xfffff
    80005876:	962080e7          	jalr	-1694(ra) # 800041d4 <end_op>
      return -1;
    8000587a:	54fd                	li	s1,-1
    8000587c:	bf79                	j	8000581a <sys_open+0xe4>
    iunlockput(ip);
    8000587e:	854a                	mv	a0,s2
    80005880:	ffffe097          	auipc	ra,0xffffe
    80005884:	176080e7          	jalr	374(ra) # 800039f6 <iunlockput>
    end_op();
    80005888:	fffff097          	auipc	ra,0xfffff
    8000588c:	94c080e7          	jalr	-1716(ra) # 800041d4 <end_op>
    return -1;
    80005890:	54fd                	li	s1,-1
    80005892:	b761                	j	8000581a <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005894:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005898:	04691783          	lh	a5,70(s2)
    8000589c:	02f99223          	sh	a5,36(s3)
    800058a0:	bf2d                	j	800057da <sys_open+0xa4>
    itrunc(ip);
    800058a2:	854a                	mv	a0,s2
    800058a4:	ffffe097          	auipc	ra,0xffffe
    800058a8:	ffe080e7          	jalr	-2(ra) # 800038a2 <itrunc>
    800058ac:	bfb1                	j	80005808 <sys_open+0xd2>
      fileclose(f);
    800058ae:	854e                	mv	a0,s3
    800058b0:	fffff097          	auipc	ra,0xfffff
    800058b4:	d76080e7          	jalr	-650(ra) # 80004626 <fileclose>
    iunlockput(ip);
    800058b8:	854a                	mv	a0,s2
    800058ba:	ffffe097          	auipc	ra,0xffffe
    800058be:	13c080e7          	jalr	316(ra) # 800039f6 <iunlockput>
    end_op();
    800058c2:	fffff097          	auipc	ra,0xfffff
    800058c6:	912080e7          	jalr	-1774(ra) # 800041d4 <end_op>
    return -1;
    800058ca:	54fd                	li	s1,-1
    800058cc:	b7b9                	j	8000581a <sys_open+0xe4>

00000000800058ce <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800058ce:	7175                	addi	sp,sp,-144
    800058d0:	e506                	sd	ra,136(sp)
    800058d2:	e122                	sd	s0,128(sp)
    800058d4:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800058d6:	fffff097          	auipc	ra,0xfffff
    800058da:	87e080e7          	jalr	-1922(ra) # 80004154 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800058de:	08000613          	li	a2,128
    800058e2:	f7040593          	addi	a1,s0,-144
    800058e6:	4501                	li	a0,0
    800058e8:	ffffd097          	auipc	ra,0xffffd
    800058ec:	260080e7          	jalr	608(ra) # 80002b48 <argstr>
    800058f0:	02054963          	bltz	a0,80005922 <sys_mkdir+0x54>
    800058f4:	4681                	li	a3,0
    800058f6:	4601                	li	a2,0
    800058f8:	4585                	li	a1,1
    800058fa:	f7040513          	addi	a0,s0,-144
    800058fe:	00000097          	auipc	ra,0x0
    80005902:	800080e7          	jalr	-2048(ra) # 800050fe <create>
    80005906:	cd11                	beqz	a0,80005922 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005908:	ffffe097          	auipc	ra,0xffffe
    8000590c:	0ee080e7          	jalr	238(ra) # 800039f6 <iunlockput>
  end_op();
    80005910:	fffff097          	auipc	ra,0xfffff
    80005914:	8c4080e7          	jalr	-1852(ra) # 800041d4 <end_op>
  return 0;
    80005918:	4501                	li	a0,0
}
    8000591a:	60aa                	ld	ra,136(sp)
    8000591c:	640a                	ld	s0,128(sp)
    8000591e:	6149                	addi	sp,sp,144
    80005920:	8082                	ret
    end_op();
    80005922:	fffff097          	auipc	ra,0xfffff
    80005926:	8b2080e7          	jalr	-1870(ra) # 800041d4 <end_op>
    return -1;
    8000592a:	557d                	li	a0,-1
    8000592c:	b7fd                	j	8000591a <sys_mkdir+0x4c>

000000008000592e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000592e:	7135                	addi	sp,sp,-160
    80005930:	ed06                	sd	ra,152(sp)
    80005932:	e922                	sd	s0,144(sp)
    80005934:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005936:	fffff097          	auipc	ra,0xfffff
    8000593a:	81e080e7          	jalr	-2018(ra) # 80004154 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000593e:	08000613          	li	a2,128
    80005942:	f7040593          	addi	a1,s0,-144
    80005946:	4501                	li	a0,0
    80005948:	ffffd097          	auipc	ra,0xffffd
    8000594c:	200080e7          	jalr	512(ra) # 80002b48 <argstr>
    80005950:	04054a63          	bltz	a0,800059a4 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005954:	f6c40593          	addi	a1,s0,-148
    80005958:	4505                	li	a0,1
    8000595a:	ffffd097          	auipc	ra,0xffffd
    8000595e:	1aa080e7          	jalr	426(ra) # 80002b04 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005962:	04054163          	bltz	a0,800059a4 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005966:	f6840593          	addi	a1,s0,-152
    8000596a:	4509                	li	a0,2
    8000596c:	ffffd097          	auipc	ra,0xffffd
    80005970:	198080e7          	jalr	408(ra) # 80002b04 <argint>
     argint(1, &major) < 0 ||
    80005974:	02054863          	bltz	a0,800059a4 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005978:	f6841683          	lh	a3,-152(s0)
    8000597c:	f6c41603          	lh	a2,-148(s0)
    80005980:	458d                	li	a1,3
    80005982:	f7040513          	addi	a0,s0,-144
    80005986:	fffff097          	auipc	ra,0xfffff
    8000598a:	778080e7          	jalr	1912(ra) # 800050fe <create>
     argint(2, &minor) < 0 ||
    8000598e:	c919                	beqz	a0,800059a4 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005990:	ffffe097          	auipc	ra,0xffffe
    80005994:	066080e7          	jalr	102(ra) # 800039f6 <iunlockput>
  end_op();
    80005998:	fffff097          	auipc	ra,0xfffff
    8000599c:	83c080e7          	jalr	-1988(ra) # 800041d4 <end_op>
  return 0;
    800059a0:	4501                	li	a0,0
    800059a2:	a031                	j	800059ae <sys_mknod+0x80>
    end_op();
    800059a4:	fffff097          	auipc	ra,0xfffff
    800059a8:	830080e7          	jalr	-2000(ra) # 800041d4 <end_op>
    return -1;
    800059ac:	557d                	li	a0,-1
}
    800059ae:	60ea                	ld	ra,152(sp)
    800059b0:	644a                	ld	s0,144(sp)
    800059b2:	610d                	addi	sp,sp,160
    800059b4:	8082                	ret

00000000800059b6 <sys_chdir>:

uint64
sys_chdir(void)
{
    800059b6:	7135                	addi	sp,sp,-160
    800059b8:	ed06                	sd	ra,152(sp)
    800059ba:	e922                	sd	s0,144(sp)
    800059bc:	e526                	sd	s1,136(sp)
    800059be:	e14a                	sd	s2,128(sp)
    800059c0:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800059c2:	ffffc097          	auipc	ra,0xffffc
    800059c6:	05a080e7          	jalr	90(ra) # 80001a1c <myproc>
    800059ca:	892a                	mv	s2,a0
  
  begin_op();
    800059cc:	ffffe097          	auipc	ra,0xffffe
    800059d0:	788080e7          	jalr	1928(ra) # 80004154 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800059d4:	08000613          	li	a2,128
    800059d8:	f6040593          	addi	a1,s0,-160
    800059dc:	4501                	li	a0,0
    800059de:	ffffd097          	auipc	ra,0xffffd
    800059e2:	16a080e7          	jalr	362(ra) # 80002b48 <argstr>
    800059e6:	04054b63          	bltz	a0,80005a3c <sys_chdir+0x86>
    800059ea:	f6040513          	addi	a0,s0,-160
    800059ee:	ffffe097          	auipc	ra,0xffffe
    800059f2:	556080e7          	jalr	1366(ra) # 80003f44 <namei>
    800059f6:	84aa                	mv	s1,a0
    800059f8:	c131                	beqz	a0,80005a3c <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800059fa:	ffffe097          	auipc	ra,0xffffe
    800059fe:	d9a080e7          	jalr	-614(ra) # 80003794 <ilock>
  if(ip->type != T_DIR){
    80005a02:	04449703          	lh	a4,68(s1)
    80005a06:	4785                	li	a5,1
    80005a08:	04f71063          	bne	a4,a5,80005a48 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005a0c:	8526                	mv	a0,s1
    80005a0e:	ffffe097          	auipc	ra,0xffffe
    80005a12:	e48080e7          	jalr	-440(ra) # 80003856 <iunlock>
  iput(p->cwd);
    80005a16:	15093503          	ld	a0,336(s2)
    80005a1a:	ffffe097          	auipc	ra,0xffffe
    80005a1e:	f34080e7          	jalr	-204(ra) # 8000394e <iput>
  end_op();
    80005a22:	ffffe097          	auipc	ra,0xffffe
    80005a26:	7b2080e7          	jalr	1970(ra) # 800041d4 <end_op>
  p->cwd = ip;
    80005a2a:	14993823          	sd	s1,336(s2)
  return 0;
    80005a2e:	4501                	li	a0,0
}
    80005a30:	60ea                	ld	ra,152(sp)
    80005a32:	644a                	ld	s0,144(sp)
    80005a34:	64aa                	ld	s1,136(sp)
    80005a36:	690a                	ld	s2,128(sp)
    80005a38:	610d                	addi	sp,sp,160
    80005a3a:	8082                	ret
    end_op();
    80005a3c:	ffffe097          	auipc	ra,0xffffe
    80005a40:	798080e7          	jalr	1944(ra) # 800041d4 <end_op>
    return -1;
    80005a44:	557d                	li	a0,-1
    80005a46:	b7ed                	j	80005a30 <sys_chdir+0x7a>
    iunlockput(ip);
    80005a48:	8526                	mv	a0,s1
    80005a4a:	ffffe097          	auipc	ra,0xffffe
    80005a4e:	fac080e7          	jalr	-84(ra) # 800039f6 <iunlockput>
    end_op();
    80005a52:	ffffe097          	auipc	ra,0xffffe
    80005a56:	782080e7          	jalr	1922(ra) # 800041d4 <end_op>
    return -1;
    80005a5a:	557d                	li	a0,-1
    80005a5c:	bfd1                	j	80005a30 <sys_chdir+0x7a>

0000000080005a5e <sys_exec>:

uint64
sys_exec(void)
{
    80005a5e:	7145                	addi	sp,sp,-464
    80005a60:	e786                	sd	ra,456(sp)
    80005a62:	e3a2                	sd	s0,448(sp)
    80005a64:	ff26                	sd	s1,440(sp)
    80005a66:	fb4a                	sd	s2,432(sp)
    80005a68:	f74e                	sd	s3,424(sp)
    80005a6a:	f352                	sd	s4,416(sp)
    80005a6c:	ef56                	sd	s5,408(sp)
    80005a6e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a70:	08000613          	li	a2,128
    80005a74:	f4040593          	addi	a1,s0,-192
    80005a78:	4501                	li	a0,0
    80005a7a:	ffffd097          	auipc	ra,0xffffd
    80005a7e:	0ce080e7          	jalr	206(ra) # 80002b48 <argstr>
    return -1;
    80005a82:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005a84:	0c054a63          	bltz	a0,80005b58 <sys_exec+0xfa>
    80005a88:	e3840593          	addi	a1,s0,-456
    80005a8c:	4505                	li	a0,1
    80005a8e:	ffffd097          	auipc	ra,0xffffd
    80005a92:	098080e7          	jalr	152(ra) # 80002b26 <argaddr>
    80005a96:	0c054163          	bltz	a0,80005b58 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005a9a:	10000613          	li	a2,256
    80005a9e:	4581                	li	a1,0
    80005aa0:	e4040513          	addi	a0,s0,-448
    80005aa4:	ffffb097          	auipc	ra,0xffffb
    80005aa8:	2a8080e7          	jalr	680(ra) # 80000d4c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005aac:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005ab0:	89a6                	mv	s3,s1
    80005ab2:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005ab4:	02000a13          	li	s4,32
    80005ab8:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005abc:	00391793          	slli	a5,s2,0x3
    80005ac0:	e3040593          	addi	a1,s0,-464
    80005ac4:	e3843503          	ld	a0,-456(s0)
    80005ac8:	953e                	add	a0,a0,a5
    80005aca:	ffffd097          	auipc	ra,0xffffd
    80005ace:	fa0080e7          	jalr	-96(ra) # 80002a6a <fetchaddr>
    80005ad2:	02054a63          	bltz	a0,80005b06 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005ad6:	e3043783          	ld	a5,-464(s0)
    80005ada:	c3b9                	beqz	a5,80005b20 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005adc:	ffffb097          	auipc	ra,0xffffb
    80005ae0:	032080e7          	jalr	50(ra) # 80000b0e <kalloc>
    80005ae4:	85aa                	mv	a1,a0
    80005ae6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005aea:	cd11                	beqz	a0,80005b06 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005aec:	6605                	lui	a2,0x1
    80005aee:	e3043503          	ld	a0,-464(s0)
    80005af2:	ffffd097          	auipc	ra,0xffffd
    80005af6:	fca080e7          	jalr	-54(ra) # 80002abc <fetchstr>
    80005afa:	00054663          	bltz	a0,80005b06 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005afe:	0905                	addi	s2,s2,1
    80005b00:	09a1                	addi	s3,s3,8
    80005b02:	fb491be3          	bne	s2,s4,80005ab8 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b06:	10048913          	addi	s2,s1,256
    80005b0a:	6088                	ld	a0,0(s1)
    80005b0c:	c529                	beqz	a0,80005b56 <sys_exec+0xf8>
    kfree(argv[i]);
    80005b0e:	ffffb097          	auipc	ra,0xffffb
    80005b12:	f04080e7          	jalr	-252(ra) # 80000a12 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b16:	04a1                	addi	s1,s1,8
    80005b18:	ff2499e3          	bne	s1,s2,80005b0a <sys_exec+0xac>
  return -1;
    80005b1c:	597d                	li	s2,-1
    80005b1e:	a82d                	j	80005b58 <sys_exec+0xfa>
      argv[i] = 0;
    80005b20:	0a8e                	slli	s5,s5,0x3
    80005b22:	fc040793          	addi	a5,s0,-64
    80005b26:	9abe                	add	s5,s5,a5
    80005b28:	e80ab023          	sd	zero,-384(s5) # ffffffffffffee80 <end+0xffffffff7ffd8e80>
  int ret = exec(path, argv);
    80005b2c:	e4040593          	addi	a1,s0,-448
    80005b30:	f4040513          	addi	a0,s0,-192
    80005b34:	fffff097          	auipc	ra,0xfffff
    80005b38:	178080e7          	jalr	376(ra) # 80004cac <exec>
    80005b3c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b3e:	10048993          	addi	s3,s1,256
    80005b42:	6088                	ld	a0,0(s1)
    80005b44:	c911                	beqz	a0,80005b58 <sys_exec+0xfa>
    kfree(argv[i]);
    80005b46:	ffffb097          	auipc	ra,0xffffb
    80005b4a:	ecc080e7          	jalr	-308(ra) # 80000a12 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b4e:	04a1                	addi	s1,s1,8
    80005b50:	ff3499e3          	bne	s1,s3,80005b42 <sys_exec+0xe4>
    80005b54:	a011                	j	80005b58 <sys_exec+0xfa>
  return -1;
    80005b56:	597d                	li	s2,-1
}
    80005b58:	854a                	mv	a0,s2
    80005b5a:	60be                	ld	ra,456(sp)
    80005b5c:	641e                	ld	s0,448(sp)
    80005b5e:	74fa                	ld	s1,440(sp)
    80005b60:	795a                	ld	s2,432(sp)
    80005b62:	79ba                	ld	s3,424(sp)
    80005b64:	7a1a                	ld	s4,416(sp)
    80005b66:	6afa                	ld	s5,408(sp)
    80005b68:	6179                	addi	sp,sp,464
    80005b6a:	8082                	ret

0000000080005b6c <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b6c:	7139                	addi	sp,sp,-64
    80005b6e:	fc06                	sd	ra,56(sp)
    80005b70:	f822                	sd	s0,48(sp)
    80005b72:	f426                	sd	s1,40(sp)
    80005b74:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b76:	ffffc097          	auipc	ra,0xffffc
    80005b7a:	ea6080e7          	jalr	-346(ra) # 80001a1c <myproc>
    80005b7e:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005b80:	fd840593          	addi	a1,s0,-40
    80005b84:	4501                	li	a0,0
    80005b86:	ffffd097          	auipc	ra,0xffffd
    80005b8a:	fa0080e7          	jalr	-96(ra) # 80002b26 <argaddr>
    return -1;
    80005b8e:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005b90:	0e054063          	bltz	a0,80005c70 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005b94:	fc840593          	addi	a1,s0,-56
    80005b98:	fd040513          	addi	a0,s0,-48
    80005b9c:	fffff097          	auipc	ra,0xfffff
    80005ba0:	de0080e7          	jalr	-544(ra) # 8000497c <pipealloc>
    return -1;
    80005ba4:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005ba6:	0c054563          	bltz	a0,80005c70 <sys_pipe+0x104>
  fd0 = -1;
    80005baa:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005bae:	fd043503          	ld	a0,-48(s0)
    80005bb2:	fffff097          	auipc	ra,0xfffff
    80005bb6:	50a080e7          	jalr	1290(ra) # 800050bc <fdalloc>
    80005bba:	fca42223          	sw	a0,-60(s0)
    80005bbe:	08054c63          	bltz	a0,80005c56 <sys_pipe+0xea>
    80005bc2:	fc843503          	ld	a0,-56(s0)
    80005bc6:	fffff097          	auipc	ra,0xfffff
    80005bca:	4f6080e7          	jalr	1270(ra) # 800050bc <fdalloc>
    80005bce:	fca42023          	sw	a0,-64(s0)
    80005bd2:	06054863          	bltz	a0,80005c42 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005bd6:	4691                	li	a3,4
    80005bd8:	fc440613          	addi	a2,s0,-60
    80005bdc:	fd843583          	ld	a1,-40(s0)
    80005be0:	68a8                	ld	a0,80(s1)
    80005be2:	ffffc097          	auipc	ra,0xffffc
    80005be6:	b2c080e7          	jalr	-1236(ra) # 8000170e <copyout>
    80005bea:	02054063          	bltz	a0,80005c0a <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005bee:	4691                	li	a3,4
    80005bf0:	fc040613          	addi	a2,s0,-64
    80005bf4:	fd843583          	ld	a1,-40(s0)
    80005bf8:	0591                	addi	a1,a1,4
    80005bfa:	68a8                	ld	a0,80(s1)
    80005bfc:	ffffc097          	auipc	ra,0xffffc
    80005c00:	b12080e7          	jalr	-1262(ra) # 8000170e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c04:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c06:	06055563          	bgez	a0,80005c70 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005c0a:	fc442783          	lw	a5,-60(s0)
    80005c0e:	07e9                	addi	a5,a5,26
    80005c10:	078e                	slli	a5,a5,0x3
    80005c12:	97a6                	add	a5,a5,s1
    80005c14:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005c18:	fc042503          	lw	a0,-64(s0)
    80005c1c:	0569                	addi	a0,a0,26
    80005c1e:	050e                	slli	a0,a0,0x3
    80005c20:	9526                	add	a0,a0,s1
    80005c22:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005c26:	fd043503          	ld	a0,-48(s0)
    80005c2a:	fffff097          	auipc	ra,0xfffff
    80005c2e:	9fc080e7          	jalr	-1540(ra) # 80004626 <fileclose>
    fileclose(wf);
    80005c32:	fc843503          	ld	a0,-56(s0)
    80005c36:	fffff097          	auipc	ra,0xfffff
    80005c3a:	9f0080e7          	jalr	-1552(ra) # 80004626 <fileclose>
    return -1;
    80005c3e:	57fd                	li	a5,-1
    80005c40:	a805                	j	80005c70 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005c42:	fc442783          	lw	a5,-60(s0)
    80005c46:	0007c863          	bltz	a5,80005c56 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005c4a:	01a78513          	addi	a0,a5,26
    80005c4e:	050e                	slli	a0,a0,0x3
    80005c50:	9526                	add	a0,a0,s1
    80005c52:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005c56:	fd043503          	ld	a0,-48(s0)
    80005c5a:	fffff097          	auipc	ra,0xfffff
    80005c5e:	9cc080e7          	jalr	-1588(ra) # 80004626 <fileclose>
    fileclose(wf);
    80005c62:	fc843503          	ld	a0,-56(s0)
    80005c66:	fffff097          	auipc	ra,0xfffff
    80005c6a:	9c0080e7          	jalr	-1600(ra) # 80004626 <fileclose>
    return -1;
    80005c6e:	57fd                	li	a5,-1
}
    80005c70:	853e                	mv	a0,a5
    80005c72:	70e2                	ld	ra,56(sp)
    80005c74:	7442                	ld	s0,48(sp)
    80005c76:	74a2                	ld	s1,40(sp)
    80005c78:	6121                	addi	sp,sp,64
    80005c7a:	8082                	ret
    80005c7c:	0000                	unimp
	...

0000000080005c80 <kernelvec>:
    80005c80:	7111                	addi	sp,sp,-256
    80005c82:	e006                	sd	ra,0(sp)
    80005c84:	e40a                	sd	sp,8(sp)
    80005c86:	e80e                	sd	gp,16(sp)
    80005c88:	ec12                	sd	tp,24(sp)
    80005c8a:	f016                	sd	t0,32(sp)
    80005c8c:	f41a                	sd	t1,40(sp)
    80005c8e:	f81e                	sd	t2,48(sp)
    80005c90:	fc22                	sd	s0,56(sp)
    80005c92:	e0a6                	sd	s1,64(sp)
    80005c94:	e4aa                	sd	a0,72(sp)
    80005c96:	e8ae                	sd	a1,80(sp)
    80005c98:	ecb2                	sd	a2,88(sp)
    80005c9a:	f0b6                	sd	a3,96(sp)
    80005c9c:	f4ba                	sd	a4,104(sp)
    80005c9e:	f8be                	sd	a5,112(sp)
    80005ca0:	fcc2                	sd	a6,120(sp)
    80005ca2:	e146                	sd	a7,128(sp)
    80005ca4:	e54a                	sd	s2,136(sp)
    80005ca6:	e94e                	sd	s3,144(sp)
    80005ca8:	ed52                	sd	s4,152(sp)
    80005caa:	f156                	sd	s5,160(sp)
    80005cac:	f55a                	sd	s6,168(sp)
    80005cae:	f95e                	sd	s7,176(sp)
    80005cb0:	fd62                	sd	s8,184(sp)
    80005cb2:	e1e6                	sd	s9,192(sp)
    80005cb4:	e5ea                	sd	s10,200(sp)
    80005cb6:	e9ee                	sd	s11,208(sp)
    80005cb8:	edf2                	sd	t3,216(sp)
    80005cba:	f1f6                	sd	t4,224(sp)
    80005cbc:	f5fa                	sd	t5,232(sp)
    80005cbe:	f9fe                	sd	t6,240(sp)
    80005cc0:	c77fc0ef          	jal	ra,80002936 <kerneltrap>
    80005cc4:	6082                	ld	ra,0(sp)
    80005cc6:	6122                	ld	sp,8(sp)
    80005cc8:	61c2                	ld	gp,16(sp)
    80005cca:	7282                	ld	t0,32(sp)
    80005ccc:	7322                	ld	t1,40(sp)
    80005cce:	73c2                	ld	t2,48(sp)
    80005cd0:	7462                	ld	s0,56(sp)
    80005cd2:	6486                	ld	s1,64(sp)
    80005cd4:	6526                	ld	a0,72(sp)
    80005cd6:	65c6                	ld	a1,80(sp)
    80005cd8:	6666                	ld	a2,88(sp)
    80005cda:	7686                	ld	a3,96(sp)
    80005cdc:	7726                	ld	a4,104(sp)
    80005cde:	77c6                	ld	a5,112(sp)
    80005ce0:	7866                	ld	a6,120(sp)
    80005ce2:	688a                	ld	a7,128(sp)
    80005ce4:	692a                	ld	s2,136(sp)
    80005ce6:	69ca                	ld	s3,144(sp)
    80005ce8:	6a6a                	ld	s4,152(sp)
    80005cea:	7a8a                	ld	s5,160(sp)
    80005cec:	7b2a                	ld	s6,168(sp)
    80005cee:	7bca                	ld	s7,176(sp)
    80005cf0:	7c6a                	ld	s8,184(sp)
    80005cf2:	6c8e                	ld	s9,192(sp)
    80005cf4:	6d2e                	ld	s10,200(sp)
    80005cf6:	6dce                	ld	s11,208(sp)
    80005cf8:	6e6e                	ld	t3,216(sp)
    80005cfa:	7e8e                	ld	t4,224(sp)
    80005cfc:	7f2e                	ld	t5,232(sp)
    80005cfe:	7fce                	ld	t6,240(sp)
    80005d00:	6111                	addi	sp,sp,256
    80005d02:	10200073          	sret
    80005d06:	00000013          	nop
    80005d0a:	00000013          	nop
    80005d0e:	0001                	nop

0000000080005d10 <timervec>:
    80005d10:	34051573          	csrrw	a0,mscratch,a0
    80005d14:	e10c                	sd	a1,0(a0)
    80005d16:	e510                	sd	a2,8(a0)
    80005d18:	e914                	sd	a3,16(a0)
    80005d1a:	710c                	ld	a1,32(a0)
    80005d1c:	7510                	ld	a2,40(a0)
    80005d1e:	6194                	ld	a3,0(a1)
    80005d20:	96b2                	add	a3,a3,a2
    80005d22:	e194                	sd	a3,0(a1)
    80005d24:	4589                	li	a1,2
    80005d26:	14459073          	csrw	sip,a1
    80005d2a:	6914                	ld	a3,16(a0)
    80005d2c:	6510                	ld	a2,8(a0)
    80005d2e:	610c                	ld	a1,0(a0)
    80005d30:	34051573          	csrrw	a0,mscratch,a0
    80005d34:	30200073          	mret
	...

0000000080005d3a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005d3a:	1141                	addi	sp,sp,-16
    80005d3c:	e422                	sd	s0,8(sp)
    80005d3e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005d40:	0c0007b7          	lui	a5,0xc000
    80005d44:	4705                	li	a4,1
    80005d46:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005d48:	c3d8                	sw	a4,4(a5)
}
    80005d4a:	6422                	ld	s0,8(sp)
    80005d4c:	0141                	addi	sp,sp,16
    80005d4e:	8082                	ret

0000000080005d50 <plicinithart>:

void
plicinithart(void)
{
    80005d50:	1141                	addi	sp,sp,-16
    80005d52:	e406                	sd	ra,8(sp)
    80005d54:	e022                	sd	s0,0(sp)
    80005d56:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d58:	ffffc097          	auipc	ra,0xffffc
    80005d5c:	c98080e7          	jalr	-872(ra) # 800019f0 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d60:	0085171b          	slliw	a4,a0,0x8
    80005d64:	0c0027b7          	lui	a5,0xc002
    80005d68:	97ba                	add	a5,a5,a4
    80005d6a:	40200713          	li	a4,1026
    80005d6e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d72:	00d5151b          	slliw	a0,a0,0xd
    80005d76:	0c2017b7          	lui	a5,0xc201
    80005d7a:	953e                	add	a0,a0,a5
    80005d7c:	00052023          	sw	zero,0(a0)
}
    80005d80:	60a2                	ld	ra,8(sp)
    80005d82:	6402                	ld	s0,0(sp)
    80005d84:	0141                	addi	sp,sp,16
    80005d86:	8082                	ret

0000000080005d88 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d88:	1141                	addi	sp,sp,-16
    80005d8a:	e406                	sd	ra,8(sp)
    80005d8c:	e022                	sd	s0,0(sp)
    80005d8e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d90:	ffffc097          	auipc	ra,0xffffc
    80005d94:	c60080e7          	jalr	-928(ra) # 800019f0 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d98:	00d5179b          	slliw	a5,a0,0xd
    80005d9c:	0c201537          	lui	a0,0xc201
    80005da0:	953e                	add	a0,a0,a5
  return irq;
}
    80005da2:	4148                	lw	a0,4(a0)
    80005da4:	60a2                	ld	ra,8(sp)
    80005da6:	6402                	ld	s0,0(sp)
    80005da8:	0141                	addi	sp,sp,16
    80005daa:	8082                	ret

0000000080005dac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005dac:	1101                	addi	sp,sp,-32
    80005dae:	ec06                	sd	ra,24(sp)
    80005db0:	e822                	sd	s0,16(sp)
    80005db2:	e426                	sd	s1,8(sp)
    80005db4:	1000                	addi	s0,sp,32
    80005db6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005db8:	ffffc097          	auipc	ra,0xffffc
    80005dbc:	c38080e7          	jalr	-968(ra) # 800019f0 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005dc0:	00d5151b          	slliw	a0,a0,0xd
    80005dc4:	0c2017b7          	lui	a5,0xc201
    80005dc8:	97aa                	add	a5,a5,a0
    80005dca:	c3c4                	sw	s1,4(a5)
}
    80005dcc:	60e2                	ld	ra,24(sp)
    80005dce:	6442                	ld	s0,16(sp)
    80005dd0:	64a2                	ld	s1,8(sp)
    80005dd2:	6105                	addi	sp,sp,32
    80005dd4:	8082                	ret

0000000080005dd6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005dd6:	1141                	addi	sp,sp,-16
    80005dd8:	e406                	sd	ra,8(sp)
    80005dda:	e022                	sd	s0,0(sp)
    80005ddc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005dde:	479d                	li	a5,7
    80005de0:	04a7cc63          	blt	a5,a0,80005e38 <free_desc+0x62>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005de4:	0001d797          	auipc	a5,0x1d
    80005de8:	21c78793          	addi	a5,a5,540 # 80023000 <disk>
    80005dec:	00a78733          	add	a4,a5,a0
    80005df0:	6789                	lui	a5,0x2
    80005df2:	97ba                	add	a5,a5,a4
    80005df4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005df8:	eba1                	bnez	a5,80005e48 <free_desc+0x72>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005dfa:	00451713          	slli	a4,a0,0x4
    80005dfe:	0001f797          	auipc	a5,0x1f
    80005e02:	2027b783          	ld	a5,514(a5) # 80025000 <disk+0x2000>
    80005e06:	97ba                	add	a5,a5,a4
    80005e08:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005e0c:	0001d797          	auipc	a5,0x1d
    80005e10:	1f478793          	addi	a5,a5,500 # 80023000 <disk>
    80005e14:	97aa                	add	a5,a5,a0
    80005e16:	6509                	lui	a0,0x2
    80005e18:	953e                	add	a0,a0,a5
    80005e1a:	4785                	li	a5,1
    80005e1c:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005e20:	0001f517          	auipc	a0,0x1f
    80005e24:	1f850513          	addi	a0,a0,504 # 80025018 <disk+0x2018>
    80005e28:	ffffc097          	auipc	ra,0xffffc
    80005e2c:	584080e7          	jalr	1412(ra) # 800023ac <wakeup>
}
    80005e30:	60a2                	ld	ra,8(sp)
    80005e32:	6402                	ld	s0,0(sp)
    80005e34:	0141                	addi	sp,sp,16
    80005e36:	8082                	ret
    panic("virtio_disk_intr 1");
    80005e38:	00003517          	auipc	a0,0x3
    80005e3c:	9f050513          	addi	a0,a0,-1552 # 80008828 <syscalls+0x338>
    80005e40:	ffffa097          	auipc	ra,0xffffa
    80005e44:	702080e7          	jalr	1794(ra) # 80000542 <panic>
    panic("virtio_disk_intr 2");
    80005e48:	00003517          	auipc	a0,0x3
    80005e4c:	9f850513          	addi	a0,a0,-1544 # 80008840 <syscalls+0x350>
    80005e50:	ffffa097          	auipc	ra,0xffffa
    80005e54:	6f2080e7          	jalr	1778(ra) # 80000542 <panic>

0000000080005e58 <virtio_disk_init>:
{
    80005e58:	1101                	addi	sp,sp,-32
    80005e5a:	ec06                	sd	ra,24(sp)
    80005e5c:	e822                	sd	s0,16(sp)
    80005e5e:	e426                	sd	s1,8(sp)
    80005e60:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e62:	00003597          	auipc	a1,0x3
    80005e66:	9f658593          	addi	a1,a1,-1546 # 80008858 <syscalls+0x368>
    80005e6a:	0001f517          	auipc	a0,0x1f
    80005e6e:	23e50513          	addi	a0,a0,574 # 800250a8 <disk+0x20a8>
    80005e72:	ffffb097          	auipc	ra,0xffffb
    80005e76:	d4e080e7          	jalr	-690(ra) # 80000bc0 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e7a:	100017b7          	lui	a5,0x10001
    80005e7e:	4398                	lw	a4,0(a5)
    80005e80:	2701                	sext.w	a4,a4
    80005e82:	747277b7          	lui	a5,0x74727
    80005e86:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e8a:	0ef71163          	bne	a4,a5,80005f6c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005e8e:	100017b7          	lui	a5,0x10001
    80005e92:	43dc                	lw	a5,4(a5)
    80005e94:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e96:	4705                	li	a4,1
    80005e98:	0ce79a63          	bne	a5,a4,80005f6c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e9c:	100017b7          	lui	a5,0x10001
    80005ea0:	479c                	lw	a5,8(a5)
    80005ea2:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005ea4:	4709                	li	a4,2
    80005ea6:	0ce79363          	bne	a5,a4,80005f6c <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005eaa:	100017b7          	lui	a5,0x10001
    80005eae:	47d8                	lw	a4,12(a5)
    80005eb0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005eb2:	554d47b7          	lui	a5,0x554d4
    80005eb6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005eba:	0af71963          	bne	a4,a5,80005f6c <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ebe:	100017b7          	lui	a5,0x10001
    80005ec2:	4705                	li	a4,1
    80005ec4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ec6:	470d                	li	a4,3
    80005ec8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005eca:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005ecc:	c7ffe737          	lui	a4,0xc7ffe
    80005ed0:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    80005ed4:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005ed6:	2701                	sext.w	a4,a4
    80005ed8:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005eda:	472d                	li	a4,11
    80005edc:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ede:	473d                	li	a4,15
    80005ee0:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005ee2:	6705                	lui	a4,0x1
    80005ee4:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005ee6:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005eea:	5bdc                	lw	a5,52(a5)
    80005eec:	2781                	sext.w	a5,a5
  if(max == 0)
    80005eee:	c7d9                	beqz	a5,80005f7c <virtio_disk_init+0x124>
  if(max < NUM)
    80005ef0:	471d                	li	a4,7
    80005ef2:	08f77d63          	bgeu	a4,a5,80005f8c <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005ef6:	100014b7          	lui	s1,0x10001
    80005efa:	47a1                	li	a5,8
    80005efc:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005efe:	6609                	lui	a2,0x2
    80005f00:	4581                	li	a1,0
    80005f02:	0001d517          	auipc	a0,0x1d
    80005f06:	0fe50513          	addi	a0,a0,254 # 80023000 <disk>
    80005f0a:	ffffb097          	auipc	ra,0xffffb
    80005f0e:	e42080e7          	jalr	-446(ra) # 80000d4c <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005f12:	0001d717          	auipc	a4,0x1d
    80005f16:	0ee70713          	addi	a4,a4,238 # 80023000 <disk>
    80005f1a:	00c75793          	srli	a5,a4,0xc
    80005f1e:	2781                	sext.w	a5,a5
    80005f20:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80005f22:	0001f797          	auipc	a5,0x1f
    80005f26:	0de78793          	addi	a5,a5,222 # 80025000 <disk+0x2000>
    80005f2a:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80005f2c:	0001d717          	auipc	a4,0x1d
    80005f30:	15470713          	addi	a4,a4,340 # 80023080 <disk+0x80>
    80005f34:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80005f36:	0001e717          	auipc	a4,0x1e
    80005f3a:	0ca70713          	addi	a4,a4,202 # 80024000 <disk+0x1000>
    80005f3e:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005f40:	4705                	li	a4,1
    80005f42:	00e78c23          	sb	a4,24(a5)
    80005f46:	00e78ca3          	sb	a4,25(a5)
    80005f4a:	00e78d23          	sb	a4,26(a5)
    80005f4e:	00e78da3          	sb	a4,27(a5)
    80005f52:	00e78e23          	sb	a4,28(a5)
    80005f56:	00e78ea3          	sb	a4,29(a5)
    80005f5a:	00e78f23          	sb	a4,30(a5)
    80005f5e:	00e78fa3          	sb	a4,31(a5)
}
    80005f62:	60e2                	ld	ra,24(sp)
    80005f64:	6442                	ld	s0,16(sp)
    80005f66:	64a2                	ld	s1,8(sp)
    80005f68:	6105                	addi	sp,sp,32
    80005f6a:	8082                	ret
    panic("could not find virtio disk");
    80005f6c:	00003517          	auipc	a0,0x3
    80005f70:	8fc50513          	addi	a0,a0,-1796 # 80008868 <syscalls+0x378>
    80005f74:	ffffa097          	auipc	ra,0xffffa
    80005f78:	5ce080e7          	jalr	1486(ra) # 80000542 <panic>
    panic("virtio disk has no queue 0");
    80005f7c:	00003517          	auipc	a0,0x3
    80005f80:	90c50513          	addi	a0,a0,-1780 # 80008888 <syscalls+0x398>
    80005f84:	ffffa097          	auipc	ra,0xffffa
    80005f88:	5be080e7          	jalr	1470(ra) # 80000542 <panic>
    panic("virtio disk max queue too short");
    80005f8c:	00003517          	auipc	a0,0x3
    80005f90:	91c50513          	addi	a0,a0,-1764 # 800088a8 <syscalls+0x3b8>
    80005f94:	ffffa097          	auipc	ra,0xffffa
    80005f98:	5ae080e7          	jalr	1454(ra) # 80000542 <panic>

0000000080005f9c <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f9c:	7175                	addi	sp,sp,-144
    80005f9e:	e506                	sd	ra,136(sp)
    80005fa0:	e122                	sd	s0,128(sp)
    80005fa2:	fca6                	sd	s1,120(sp)
    80005fa4:	f8ca                	sd	s2,112(sp)
    80005fa6:	f4ce                	sd	s3,104(sp)
    80005fa8:	f0d2                	sd	s4,96(sp)
    80005faa:	ecd6                	sd	s5,88(sp)
    80005fac:	e8da                	sd	s6,80(sp)
    80005fae:	e4de                	sd	s7,72(sp)
    80005fb0:	e0e2                	sd	s8,64(sp)
    80005fb2:	fc66                	sd	s9,56(sp)
    80005fb4:	f86a                	sd	s10,48(sp)
    80005fb6:	f46e                	sd	s11,40(sp)
    80005fb8:	0900                	addi	s0,sp,144
    80005fba:	8aaa                	mv	s5,a0
    80005fbc:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005fbe:	00c52c83          	lw	s9,12(a0)
    80005fc2:	001c9c9b          	slliw	s9,s9,0x1
    80005fc6:	1c82                	slli	s9,s9,0x20
    80005fc8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005fcc:	0001f517          	auipc	a0,0x1f
    80005fd0:	0dc50513          	addi	a0,a0,220 # 800250a8 <disk+0x20a8>
    80005fd4:	ffffb097          	auipc	ra,0xffffb
    80005fd8:	c7c080e7          	jalr	-900(ra) # 80000c50 <acquire>
  for(int i = 0; i < 3; i++){
    80005fdc:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005fde:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005fe0:	0001dc17          	auipc	s8,0x1d
    80005fe4:	020c0c13          	addi	s8,s8,32 # 80023000 <disk>
    80005fe8:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80005fea:	4b0d                	li	s6,3
    80005fec:	a0ad                	j	80006056 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    80005fee:	00fc0733          	add	a4,s8,a5
    80005ff2:	975e                	add	a4,a4,s7
    80005ff4:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005ff8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005ffa:	0207c563          	bltz	a5,80006024 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80005ffe:	2905                	addiw	s2,s2,1
    80006000:	0611                	addi	a2,a2,4
    80006002:	19690d63          	beq	s2,s6,8000619c <virtio_disk_rw+0x200>
    idx[i] = alloc_desc();
    80006006:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006008:	0001f717          	auipc	a4,0x1f
    8000600c:	01070713          	addi	a4,a4,16 # 80025018 <disk+0x2018>
    80006010:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006012:	00074683          	lbu	a3,0(a4)
    80006016:	fee1                	bnez	a3,80005fee <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006018:	2785                	addiw	a5,a5,1
    8000601a:	0705                	addi	a4,a4,1
    8000601c:	fe979be3          	bne	a5,s1,80006012 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    80006020:	57fd                	li	a5,-1
    80006022:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006024:	01205d63          	blez	s2,8000603e <virtio_disk_rw+0xa2>
    80006028:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    8000602a:	000a2503          	lw	a0,0(s4)
    8000602e:	00000097          	auipc	ra,0x0
    80006032:	da8080e7          	jalr	-600(ra) # 80005dd6 <free_desc>
      for(int j = 0; j < i; j++)
    80006036:	2d85                	addiw	s11,s11,1
    80006038:	0a11                	addi	s4,s4,4
    8000603a:	ffb918e3          	bne	s2,s11,8000602a <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000603e:	0001f597          	auipc	a1,0x1f
    80006042:	06a58593          	addi	a1,a1,106 # 800250a8 <disk+0x20a8>
    80006046:	0001f517          	auipc	a0,0x1f
    8000604a:	fd250513          	addi	a0,a0,-46 # 80025018 <disk+0x2018>
    8000604e:	ffffc097          	auipc	ra,0xffffc
    80006052:	1de080e7          	jalr	478(ra) # 8000222c <sleep>
  for(int i = 0; i < 3; i++){
    80006056:	f8040a13          	addi	s4,s0,-128
{
    8000605a:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    8000605c:	894e                	mv	s2,s3
    8000605e:	b765                	j	80006006 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80006060:	0001f717          	auipc	a4,0x1f
    80006064:	fa073703          	ld	a4,-96(a4) # 80025000 <disk+0x2000>
    80006068:	973e                	add	a4,a4,a5
    8000606a:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000606e:	0001d517          	auipc	a0,0x1d
    80006072:	f9250513          	addi	a0,a0,-110 # 80023000 <disk>
    80006076:	0001f717          	auipc	a4,0x1f
    8000607a:	f8a70713          	addi	a4,a4,-118 # 80025000 <disk+0x2000>
    8000607e:	6314                	ld	a3,0(a4)
    80006080:	96be                	add	a3,a3,a5
    80006082:	00c6d603          	lhu	a2,12(a3)
    80006086:	00166613          	ori	a2,a2,1
    8000608a:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000608e:	f8842683          	lw	a3,-120(s0)
    80006092:	6310                	ld	a2,0(a4)
    80006094:	97b2                	add	a5,a5,a2
    80006096:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0;
    8000609a:	20048613          	addi	a2,s1,512 # 10001200 <_entry-0x6fffee00>
    8000609e:	0612                	slli	a2,a2,0x4
    800060a0:	962a                	add	a2,a2,a0
    800060a2:	02060823          	sb	zero,48(a2) # 2030 <_entry-0x7fffdfd0>
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800060a6:	00469793          	slli	a5,a3,0x4
    800060aa:	630c                	ld	a1,0(a4)
    800060ac:	95be                	add	a1,a1,a5
    800060ae:	6689                	lui	a3,0x2
    800060b0:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    800060b4:	96ca                	add	a3,a3,s2
    800060b6:	96aa                	add	a3,a3,a0
    800060b8:	e194                	sd	a3,0(a1)
  disk.desc[idx[2]].len = 1;
    800060ba:	6314                	ld	a3,0(a4)
    800060bc:	96be                	add	a3,a3,a5
    800060be:	4585                	li	a1,1
    800060c0:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800060c2:	6314                	ld	a3,0(a4)
    800060c4:	96be                	add	a3,a3,a5
    800060c6:	4509                	li	a0,2
    800060c8:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    800060cc:	6314                	ld	a3,0(a4)
    800060ce:	97b6                	add	a5,a5,a3
    800060d0:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800060d4:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    800060d8:	03563423          	sd	s5,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    800060dc:	6714                	ld	a3,8(a4)
    800060de:	0026d783          	lhu	a5,2(a3)
    800060e2:	8b9d                	andi	a5,a5,7
    800060e4:	0789                	addi	a5,a5,2
    800060e6:	0786                	slli	a5,a5,0x1
    800060e8:	97b6                	add	a5,a5,a3
    800060ea:	00979023          	sh	s1,0(a5)
  __sync_synchronize();
    800060ee:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    800060f2:	6718                	ld	a4,8(a4)
    800060f4:	00275783          	lhu	a5,2(a4)
    800060f8:	2785                	addiw	a5,a5,1
    800060fa:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800060fe:	100017b7          	lui	a5,0x10001
    80006102:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006106:	004aa783          	lw	a5,4(s5)
    8000610a:	02b79163          	bne	a5,a1,8000612c <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    8000610e:	0001f917          	auipc	s2,0x1f
    80006112:	f9a90913          	addi	s2,s2,-102 # 800250a8 <disk+0x20a8>
  while(b->disk == 1) {
    80006116:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006118:	85ca                	mv	a1,s2
    8000611a:	8556                	mv	a0,s5
    8000611c:	ffffc097          	auipc	ra,0xffffc
    80006120:	110080e7          	jalr	272(ra) # 8000222c <sleep>
  while(b->disk == 1) {
    80006124:	004aa783          	lw	a5,4(s5)
    80006128:	fe9788e3          	beq	a5,s1,80006118 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    8000612c:	f8042483          	lw	s1,-128(s0)
    80006130:	20048793          	addi	a5,s1,512
    80006134:	00479713          	slli	a4,a5,0x4
    80006138:	0001d797          	auipc	a5,0x1d
    8000613c:	ec878793          	addi	a5,a5,-312 # 80023000 <disk>
    80006140:	97ba                	add	a5,a5,a4
    80006142:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    80006146:	0001f917          	auipc	s2,0x1f
    8000614a:	eba90913          	addi	s2,s2,-326 # 80025000 <disk+0x2000>
    8000614e:	a019                	j	80006154 <virtio_disk_rw+0x1b8>
      i = disk.desc[i].next;
    80006150:	00e4d483          	lhu	s1,14(s1)
    free_desc(i);
    80006154:	8526                	mv	a0,s1
    80006156:	00000097          	auipc	ra,0x0
    8000615a:	c80080e7          	jalr	-896(ra) # 80005dd6 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    8000615e:	0492                	slli	s1,s1,0x4
    80006160:	00093783          	ld	a5,0(s2)
    80006164:	94be                	add	s1,s1,a5
    80006166:	00c4d783          	lhu	a5,12(s1)
    8000616a:	8b85                	andi	a5,a5,1
    8000616c:	f3f5                	bnez	a5,80006150 <virtio_disk_rw+0x1b4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000616e:	0001f517          	auipc	a0,0x1f
    80006172:	f3a50513          	addi	a0,a0,-198 # 800250a8 <disk+0x20a8>
    80006176:	ffffb097          	auipc	ra,0xffffb
    8000617a:	b8e080e7          	jalr	-1138(ra) # 80000d04 <release>
}
    8000617e:	60aa                	ld	ra,136(sp)
    80006180:	640a                	ld	s0,128(sp)
    80006182:	74e6                	ld	s1,120(sp)
    80006184:	7946                	ld	s2,112(sp)
    80006186:	79a6                	ld	s3,104(sp)
    80006188:	7a06                	ld	s4,96(sp)
    8000618a:	6ae6                	ld	s5,88(sp)
    8000618c:	6b46                	ld	s6,80(sp)
    8000618e:	6ba6                	ld	s7,72(sp)
    80006190:	6c06                	ld	s8,64(sp)
    80006192:	7ce2                	ld	s9,56(sp)
    80006194:	7d42                	ld	s10,48(sp)
    80006196:	7da2                	ld	s11,40(sp)
    80006198:	6149                	addi	sp,sp,144
    8000619a:	8082                	ret
  if(write)
    8000619c:	01a037b3          	snez	a5,s10
    800061a0:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    800061a4:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    800061a8:	f7943c23          	sd	s9,-136(s0)
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    800061ac:	f8042483          	lw	s1,-128(s0)
    800061b0:	00449913          	slli	s2,s1,0x4
    800061b4:	0001f997          	auipc	s3,0x1f
    800061b8:	e4c98993          	addi	s3,s3,-436 # 80025000 <disk+0x2000>
    800061bc:	0009ba03          	ld	s4,0(s3)
    800061c0:	9a4a                	add	s4,s4,s2
    800061c2:	f7040513          	addi	a0,s0,-144
    800061c6:	ffffb097          	auipc	ra,0xffffb
    800061ca:	f56080e7          	jalr	-170(ra) # 8000111c <kvmpa>
    800061ce:	00aa3023          	sd	a0,0(s4)
  disk.desc[idx[0]].len = sizeof(buf0);
    800061d2:	0009b783          	ld	a5,0(s3)
    800061d6:	97ca                	add	a5,a5,s2
    800061d8:	4741                	li	a4,16
    800061da:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800061dc:	0009b783          	ld	a5,0(s3)
    800061e0:	97ca                	add	a5,a5,s2
    800061e2:	4705                	li	a4,1
    800061e4:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    800061e8:	f8442783          	lw	a5,-124(s0)
    800061ec:	0009b703          	ld	a4,0(s3)
    800061f0:	974a                	add	a4,a4,s2
    800061f2:	00f71723          	sh	a5,14(a4)
  disk.desc[idx[1]].addr = (uint64) b->data;
    800061f6:	0792                	slli	a5,a5,0x4
    800061f8:	0009b703          	ld	a4,0(s3)
    800061fc:	973e                	add	a4,a4,a5
    800061fe:	058a8693          	addi	a3,s5,88
    80006202:	e314                	sd	a3,0(a4)
  disk.desc[idx[1]].len = BSIZE;
    80006204:	0009b703          	ld	a4,0(s3)
    80006208:	973e                	add	a4,a4,a5
    8000620a:	40000693          	li	a3,1024
    8000620e:	c714                	sw	a3,8(a4)
  if(write)
    80006210:	e40d18e3          	bnez	s10,80006060 <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80006214:	0001f717          	auipc	a4,0x1f
    80006218:	dec73703          	ld	a4,-532(a4) # 80025000 <disk+0x2000>
    8000621c:	973e                	add	a4,a4,a5
    8000621e:	4689                	li	a3,2
    80006220:	00d71623          	sh	a3,12(a4)
    80006224:	b5a9                	j	8000606e <virtio_disk_rw+0xd2>

0000000080006226 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006226:	1101                	addi	sp,sp,-32
    80006228:	ec06                	sd	ra,24(sp)
    8000622a:	e822                	sd	s0,16(sp)
    8000622c:	e426                	sd	s1,8(sp)
    8000622e:	e04a                	sd	s2,0(sp)
    80006230:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006232:	0001f517          	auipc	a0,0x1f
    80006236:	e7650513          	addi	a0,a0,-394 # 800250a8 <disk+0x20a8>
    8000623a:	ffffb097          	auipc	ra,0xffffb
    8000623e:	a16080e7          	jalr	-1514(ra) # 80000c50 <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    80006242:	0001f717          	auipc	a4,0x1f
    80006246:	dbe70713          	addi	a4,a4,-578 # 80025000 <disk+0x2000>
    8000624a:	02075783          	lhu	a5,32(a4)
    8000624e:	6b18                	ld	a4,16(a4)
    80006250:	00275683          	lhu	a3,2(a4)
    80006254:	8ebd                	xor	a3,a3,a5
    80006256:	8a9d                	andi	a3,a3,7
    80006258:	cab9                	beqz	a3,800062ae <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    8000625a:	0001d917          	auipc	s2,0x1d
    8000625e:	da690913          	addi	s2,s2,-602 # 80023000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006262:	0001f497          	auipc	s1,0x1f
    80006266:	d9e48493          	addi	s1,s1,-610 # 80025000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    8000626a:	078e                	slli	a5,a5,0x3
    8000626c:	97ba                	add	a5,a5,a4
    8000626e:	43dc                	lw	a5,4(a5)
    if(disk.info[id].status != 0)
    80006270:	20078713          	addi	a4,a5,512
    80006274:	0712                	slli	a4,a4,0x4
    80006276:	974a                	add	a4,a4,s2
    80006278:	03074703          	lbu	a4,48(a4)
    8000627c:	ef21                	bnez	a4,800062d4 <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    8000627e:	20078793          	addi	a5,a5,512
    80006282:	0792                	slli	a5,a5,0x4
    80006284:	97ca                	add	a5,a5,s2
    80006286:	7798                	ld	a4,40(a5)
    80006288:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    8000628c:	7788                	ld	a0,40(a5)
    8000628e:	ffffc097          	auipc	ra,0xffffc
    80006292:	11e080e7          	jalr	286(ra) # 800023ac <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006296:	0204d783          	lhu	a5,32(s1)
    8000629a:	2785                	addiw	a5,a5,1
    8000629c:	8b9d                	andi	a5,a5,7
    8000629e:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800062a2:	6898                	ld	a4,16(s1)
    800062a4:	00275683          	lhu	a3,2(a4)
    800062a8:	8a9d                	andi	a3,a3,7
    800062aa:	fcf690e3          	bne	a3,a5,8000626a <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800062ae:	10001737          	lui	a4,0x10001
    800062b2:	533c                	lw	a5,96(a4)
    800062b4:	8b8d                	andi	a5,a5,3
    800062b6:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    800062b8:	0001f517          	auipc	a0,0x1f
    800062bc:	df050513          	addi	a0,a0,-528 # 800250a8 <disk+0x20a8>
    800062c0:	ffffb097          	auipc	ra,0xffffb
    800062c4:	a44080e7          	jalr	-1468(ra) # 80000d04 <release>
}
    800062c8:	60e2                	ld	ra,24(sp)
    800062ca:	6442                	ld	s0,16(sp)
    800062cc:	64a2                	ld	s1,8(sp)
    800062ce:	6902                	ld	s2,0(sp)
    800062d0:	6105                	addi	sp,sp,32
    800062d2:	8082                	ret
      panic("virtio_disk_intr status");
    800062d4:	00002517          	auipc	a0,0x2
    800062d8:	5f450513          	addi	a0,a0,1524 # 800088c8 <syscalls+0x3d8>
    800062dc:	ffffa097          	auipc	ra,0xffffa
    800062e0:	266080e7          	jalr	614(ra) # 80000542 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
