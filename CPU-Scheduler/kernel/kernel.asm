
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	18010113          	addi	sp,sp,384 # 80009180 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	078000ef          	jal	ra,8000008e <start>

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
    80000026:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	95b2                	add	a1,a1,a2
    80000046:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00269713          	slli	a4,a3,0x2
    8000004c:	9736                	add	a4,a4,a3
    8000004e:	00371693          	slli	a3,a4,0x3
    80000052:	00009717          	auipc	a4,0x9
    80000056:	fee70713          	addi	a4,a4,-18 # 80009040 <timer_scratch>
    8000005a:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005c:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005e:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000060:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000064:	00006797          	auipc	a5,0x6
    80000068:	fac78793          	addi	a5,a5,-84 # 80006010 <timervec>
    8000006c:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000070:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000074:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000078:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007c:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000080:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000084:	30479073          	csrw	mie,a5
}
    80000088:	6422                	ld	s0,8(sp)
    8000008a:	0141                	addi	sp,sp,16
    8000008c:	8082                	ret

000000008000008e <start>:
{
    8000008e:	1141                	addi	sp,sp,-16
    80000090:	e406                	sd	ra,8(sp)
    80000092:	e022                	sd	s0,0(sp)
    80000094:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000096:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000009a:	7779                	lui	a4,0xffffe
    8000009c:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd87ff>
    800000a0:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a2:	6705                	lui	a4,0x1
    800000a4:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000aa:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ae:	00001797          	auipc	a5,0x1
    800000b2:	dd278793          	addi	a5,a5,-558 # 80000e80 <main>
    800000b6:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000ba:	4781                	li	a5,0
    800000bc:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000c0:	67c1                	lui	a5,0x10
    800000c2:	17fd                	addi	a5,a5,-1
    800000c4:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c8:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000cc:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000d0:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d4:	10479073          	csrw	sie,a5
  timerinit();
    800000d8:	00000097          	auipc	ra,0x0
    800000dc:	f44080e7          	jalr	-188(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000e0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000e4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000e6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e8:	30200073          	mret
}
    800000ec:	60a2                	ld	ra,8(sp)
    800000ee:	6402                	ld	s0,0(sp)
    800000f0:	0141                	addi	sp,sp,16
    800000f2:	8082                	ret

00000000800000f4 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000f4:	715d                	addi	sp,sp,-80
    800000f6:	e486                	sd	ra,72(sp)
    800000f8:	e0a2                	sd	s0,64(sp)
    800000fa:	fc26                	sd	s1,56(sp)
    800000fc:	f84a                	sd	s2,48(sp)
    800000fe:	f44e                	sd	s3,40(sp)
    80000100:	f052                	sd	s4,32(sp)
    80000102:	ec56                	sd	s5,24(sp)
    80000104:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000106:	04c05663          	blez	a2,80000152 <consolewrite+0x5e>
    8000010a:	8a2a                	mv	s4,a0
    8000010c:	84ae                	mv	s1,a1
    8000010e:	89b2                	mv	s3,a2
    80000110:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80000112:	5afd                	li	s5,-1
    80000114:	4685                	li	a3,1
    80000116:	8626                	mv	a2,s1
    80000118:	85d2                	mv	a1,s4
    8000011a:	fbf40513          	addi	a0,s0,-65
    8000011e:	00002097          	auipc	ra,0x2
    80000122:	742080e7          	jalr	1858(ra) # 80002860 <either_copyin>
    80000126:	01550c63          	beq	a0,s5,8000013e <consolewrite+0x4a>
      break;
    uartputc(c);
    8000012a:	fbf44503          	lbu	a0,-65(s0)
    8000012e:	00000097          	auipc	ra,0x0
    80000132:	78e080e7          	jalr	1934(ra) # 800008bc <uartputc>
  for(i = 0; i < n; i++){
    80000136:	2905                	addiw	s2,s2,1
    80000138:	0485                	addi	s1,s1,1
    8000013a:	fd299de3          	bne	s3,s2,80000114 <consolewrite+0x20>
  }

  return i;
}
    8000013e:	854a                	mv	a0,s2
    80000140:	60a6                	ld	ra,72(sp)
    80000142:	6406                	ld	s0,64(sp)
    80000144:	74e2                	ld	s1,56(sp)
    80000146:	7942                	ld	s2,48(sp)
    80000148:	79a2                	ld	s3,40(sp)
    8000014a:	7a02                	ld	s4,32(sp)
    8000014c:	6ae2                	ld	s5,24(sp)
    8000014e:	6161                	addi	sp,sp,80
    80000150:	8082                	ret
  for(i = 0; i < n; i++){
    80000152:	4901                	li	s2,0
    80000154:	b7ed                	j	8000013e <consolewrite+0x4a>

0000000080000156 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000156:	7119                	addi	sp,sp,-128
    80000158:	fc86                	sd	ra,120(sp)
    8000015a:	f8a2                	sd	s0,112(sp)
    8000015c:	f4a6                	sd	s1,104(sp)
    8000015e:	f0ca                	sd	s2,96(sp)
    80000160:	ecce                	sd	s3,88(sp)
    80000162:	e8d2                	sd	s4,80(sp)
    80000164:	e4d6                	sd	s5,72(sp)
    80000166:	e0da                	sd	s6,64(sp)
    80000168:	fc5e                	sd	s7,56(sp)
    8000016a:	f862                	sd	s8,48(sp)
    8000016c:	f466                	sd	s9,40(sp)
    8000016e:	f06a                	sd	s10,32(sp)
    80000170:	ec6e                	sd	s11,24(sp)
    80000172:	0100                	addi	s0,sp,128
    80000174:	8b2a                	mv	s6,a0
    80000176:	8aae                	mv	s5,a1
    80000178:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000017a:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    8000017e:	00011517          	auipc	a0,0x11
    80000182:	00250513          	addi	a0,a0,2 # 80011180 <cons>
    80000186:	00001097          	auipc	ra,0x1
    8000018a:	a4c080e7          	jalr	-1460(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000018e:	00011497          	auipc	s1,0x11
    80000192:	ff248493          	addi	s1,s1,-14 # 80011180 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000196:	89a6                	mv	s3,s1
    80000198:	00011917          	auipc	s2,0x11
    8000019c:	08090913          	addi	s2,s2,128 # 80011218 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001a0:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001a2:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001a4:	4da9                	li	s11,10
  while(n > 0){
    800001a6:	07405863          	blez	s4,80000216 <consoleread+0xc0>
    while(cons.r == cons.w){
    800001aa:	0984a783          	lw	a5,152(s1)
    800001ae:	09c4a703          	lw	a4,156(s1)
    800001b2:	02f71463          	bne	a4,a5,800001da <consoleread+0x84>
      if(myproc()->killed){
    800001b6:	00002097          	auipc	ra,0x2
    800001ba:	8cc080e7          	jalr	-1844(ra) # 80001a82 <myproc>
    800001be:	551c                	lw	a5,40(a0)
    800001c0:	e7b5                	bnez	a5,8000022c <consoleread+0xd6>
      sleep(&cons.r, &cons.lock);
    800001c2:	85ce                	mv	a1,s3
    800001c4:	854a                	mv	a0,s2
    800001c6:	00002097          	auipc	ra,0x2
    800001ca:	220080e7          	jalr	544(ra) # 800023e6 <sleep>
    while(cons.r == cons.w){
    800001ce:	0984a783          	lw	a5,152(s1)
    800001d2:	09c4a703          	lw	a4,156(s1)
    800001d6:	fef700e3          	beq	a4,a5,800001b6 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001da:	0017871b          	addiw	a4,a5,1
    800001de:	08e4ac23          	sw	a4,152(s1)
    800001e2:	07f7f713          	andi	a4,a5,127
    800001e6:	9726                	add	a4,a4,s1
    800001e8:	01874703          	lbu	a4,24(a4)
    800001ec:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    800001f0:	079c0663          	beq	s8,s9,8000025c <consoleread+0x106>
    cbuf = c;
    800001f4:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001f8:	4685                	li	a3,1
    800001fa:	f8f40613          	addi	a2,s0,-113
    800001fe:	85d6                	mv	a1,s5
    80000200:	855a                	mv	a0,s6
    80000202:	00002097          	auipc	ra,0x2
    80000206:	608080e7          	jalr	1544(ra) # 8000280a <either_copyout>
    8000020a:	01a50663          	beq	a0,s10,80000216 <consoleread+0xc0>
    dst++;
    8000020e:	0a85                	addi	s5,s5,1
    --n;
    80000210:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80000212:	f9bc1ae3          	bne	s8,s11,800001a6 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000216:	00011517          	auipc	a0,0x11
    8000021a:	f6a50513          	addi	a0,a0,-150 # 80011180 <cons>
    8000021e:	00001097          	auipc	ra,0x1
    80000222:	a68080e7          	jalr	-1432(ra) # 80000c86 <release>

  return target - n;
    80000226:	414b853b          	subw	a0,s7,s4
    8000022a:	a811                	j	8000023e <consoleread+0xe8>
        release(&cons.lock);
    8000022c:	00011517          	auipc	a0,0x11
    80000230:	f5450513          	addi	a0,a0,-172 # 80011180 <cons>
    80000234:	00001097          	auipc	ra,0x1
    80000238:	a52080e7          	jalr	-1454(ra) # 80000c86 <release>
        return -1;
    8000023c:	557d                	li	a0,-1
}
    8000023e:	70e6                	ld	ra,120(sp)
    80000240:	7446                	ld	s0,112(sp)
    80000242:	74a6                	ld	s1,104(sp)
    80000244:	7906                	ld	s2,96(sp)
    80000246:	69e6                	ld	s3,88(sp)
    80000248:	6a46                	ld	s4,80(sp)
    8000024a:	6aa6                	ld	s5,72(sp)
    8000024c:	6b06                	ld	s6,64(sp)
    8000024e:	7be2                	ld	s7,56(sp)
    80000250:	7c42                	ld	s8,48(sp)
    80000252:	7ca2                	ld	s9,40(sp)
    80000254:	7d02                	ld	s10,32(sp)
    80000256:	6de2                	ld	s11,24(sp)
    80000258:	6109                	addi	sp,sp,128
    8000025a:	8082                	ret
      if(n < target){
    8000025c:	000a071b          	sext.w	a4,s4
    80000260:	fb777be3          	bgeu	a4,s7,80000216 <consoleread+0xc0>
        cons.r--;
    80000264:	00011717          	auipc	a4,0x11
    80000268:	faf72a23          	sw	a5,-76(a4) # 80011218 <cons+0x98>
    8000026c:	b76d                	j	80000216 <consoleread+0xc0>

000000008000026e <consputc>:
{
    8000026e:	1141                	addi	sp,sp,-16
    80000270:	e406                	sd	ra,8(sp)
    80000272:	e022                	sd	s0,0(sp)
    80000274:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000276:	10000793          	li	a5,256
    8000027a:	00f50a63          	beq	a0,a5,8000028e <consputc+0x20>
    uartputc_sync(c);
    8000027e:	00000097          	auipc	ra,0x0
    80000282:	564080e7          	jalr	1380(ra) # 800007e2 <uartputc_sync>
}
    80000286:	60a2                	ld	ra,8(sp)
    80000288:	6402                	ld	s0,0(sp)
    8000028a:	0141                	addi	sp,sp,16
    8000028c:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000028e:	4521                	li	a0,8
    80000290:	00000097          	auipc	ra,0x0
    80000294:	552080e7          	jalr	1362(ra) # 800007e2 <uartputc_sync>
    80000298:	02000513          	li	a0,32
    8000029c:	00000097          	auipc	ra,0x0
    800002a0:	546080e7          	jalr	1350(ra) # 800007e2 <uartputc_sync>
    800002a4:	4521                	li	a0,8
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	53c080e7          	jalr	1340(ra) # 800007e2 <uartputc_sync>
    800002ae:	bfe1                	j	80000286 <consputc+0x18>

00000000800002b0 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002b0:	1101                	addi	sp,sp,-32
    800002b2:	ec06                	sd	ra,24(sp)
    800002b4:	e822                	sd	s0,16(sp)
    800002b6:	e426                	sd	s1,8(sp)
    800002b8:	e04a                	sd	s2,0(sp)
    800002ba:	1000                	addi	s0,sp,32
    800002bc:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002be:	00011517          	auipc	a0,0x11
    800002c2:	ec250513          	addi	a0,a0,-318 # 80011180 <cons>
    800002c6:	00001097          	auipc	ra,0x1
    800002ca:	90c080e7          	jalr	-1780(ra) # 80000bd2 <acquire>

  switch(c){
    800002ce:	47d5                	li	a5,21
    800002d0:	0af48663          	beq	s1,a5,8000037c <consoleintr+0xcc>
    800002d4:	0297ca63          	blt	a5,s1,80000308 <consoleintr+0x58>
    800002d8:	47a1                	li	a5,8
    800002da:	0ef48763          	beq	s1,a5,800003c8 <consoleintr+0x118>
    800002de:	47c1                	li	a5,16
    800002e0:	10f49a63          	bne	s1,a5,800003f4 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002e4:	00002097          	auipc	ra,0x2
    800002e8:	5d2080e7          	jalr	1490(ra) # 800028b6 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002ec:	00011517          	auipc	a0,0x11
    800002f0:	e9450513          	addi	a0,a0,-364 # 80011180 <cons>
    800002f4:	00001097          	auipc	ra,0x1
    800002f8:	992080e7          	jalr	-1646(ra) # 80000c86 <release>
}
    800002fc:	60e2                	ld	ra,24(sp)
    800002fe:	6442                	ld	s0,16(sp)
    80000300:	64a2                	ld	s1,8(sp)
    80000302:	6902                	ld	s2,0(sp)
    80000304:	6105                	addi	sp,sp,32
    80000306:	8082                	ret
  switch(c){
    80000308:	07f00793          	li	a5,127
    8000030c:	0af48e63          	beq	s1,a5,800003c8 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000310:	00011717          	auipc	a4,0x11
    80000314:	e7070713          	addi	a4,a4,-400 # 80011180 <cons>
    80000318:	0a072783          	lw	a5,160(a4)
    8000031c:	09872703          	lw	a4,152(a4)
    80000320:	9f99                	subw	a5,a5,a4
    80000322:	07f00713          	li	a4,127
    80000326:	fcf763e3          	bltu	a4,a5,800002ec <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000032a:	47b5                	li	a5,13
    8000032c:	0cf48763          	beq	s1,a5,800003fa <consoleintr+0x14a>
      consputc(c);
    80000330:	8526                	mv	a0,s1
    80000332:	00000097          	auipc	ra,0x0
    80000336:	f3c080e7          	jalr	-196(ra) # 8000026e <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000033a:	00011797          	auipc	a5,0x11
    8000033e:	e4678793          	addi	a5,a5,-442 # 80011180 <cons>
    80000342:	0a07a703          	lw	a4,160(a5)
    80000346:	0017069b          	addiw	a3,a4,1
    8000034a:	0006861b          	sext.w	a2,a3
    8000034e:	0ad7a023          	sw	a3,160(a5)
    80000352:	07f77713          	andi	a4,a4,127
    80000356:	97ba                	add	a5,a5,a4
    80000358:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    8000035c:	47a9                	li	a5,10
    8000035e:	0cf48563          	beq	s1,a5,80000428 <consoleintr+0x178>
    80000362:	4791                	li	a5,4
    80000364:	0cf48263          	beq	s1,a5,80000428 <consoleintr+0x178>
    80000368:	00011797          	auipc	a5,0x11
    8000036c:	eb07a783          	lw	a5,-336(a5) # 80011218 <cons+0x98>
    80000370:	0807879b          	addiw	a5,a5,128
    80000374:	f6f61ce3          	bne	a2,a5,800002ec <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000378:	863e                	mv	a2,a5
    8000037a:	a07d                	j	80000428 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000037c:	00011717          	auipc	a4,0x11
    80000380:	e0470713          	addi	a4,a4,-508 # 80011180 <cons>
    80000384:	0a072783          	lw	a5,160(a4)
    80000388:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    8000038c:	00011497          	auipc	s1,0x11
    80000390:	df448493          	addi	s1,s1,-524 # 80011180 <cons>
    while(cons.e != cons.w &&
    80000394:	4929                	li	s2,10
    80000396:	f4f70be3          	beq	a4,a5,800002ec <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    8000039a:	37fd                	addiw	a5,a5,-1
    8000039c:	07f7f713          	andi	a4,a5,127
    800003a0:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003a2:	01874703          	lbu	a4,24(a4)
    800003a6:	f52703e3          	beq	a4,s2,800002ec <consoleintr+0x3c>
      cons.e--;
    800003aa:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003ae:	10000513          	li	a0,256
    800003b2:	00000097          	auipc	ra,0x0
    800003b6:	ebc080e7          	jalr	-324(ra) # 8000026e <consputc>
    while(cons.e != cons.w &&
    800003ba:	0a04a783          	lw	a5,160(s1)
    800003be:	09c4a703          	lw	a4,156(s1)
    800003c2:	fcf71ce3          	bne	a4,a5,8000039a <consoleintr+0xea>
    800003c6:	b71d                	j	800002ec <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003c8:	00011717          	auipc	a4,0x11
    800003cc:	db870713          	addi	a4,a4,-584 # 80011180 <cons>
    800003d0:	0a072783          	lw	a5,160(a4)
    800003d4:	09c72703          	lw	a4,156(a4)
    800003d8:	f0f70ae3          	beq	a4,a5,800002ec <consoleintr+0x3c>
      cons.e--;
    800003dc:	37fd                	addiw	a5,a5,-1
    800003de:	00011717          	auipc	a4,0x11
    800003e2:	e4f72123          	sw	a5,-446(a4) # 80011220 <cons+0xa0>
      consputc(BACKSPACE);
    800003e6:	10000513          	li	a0,256
    800003ea:	00000097          	auipc	ra,0x0
    800003ee:	e84080e7          	jalr	-380(ra) # 8000026e <consputc>
    800003f2:	bded                	j	800002ec <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    800003f4:	ee048ce3          	beqz	s1,800002ec <consoleintr+0x3c>
    800003f8:	bf21                	j	80000310 <consoleintr+0x60>
      consputc(c);
    800003fa:	4529                	li	a0,10
    800003fc:	00000097          	auipc	ra,0x0
    80000400:	e72080e7          	jalr	-398(ra) # 8000026e <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000404:	00011797          	auipc	a5,0x11
    80000408:	d7c78793          	addi	a5,a5,-644 # 80011180 <cons>
    8000040c:	0a07a703          	lw	a4,160(a5)
    80000410:	0017069b          	addiw	a3,a4,1
    80000414:	0006861b          	sext.w	a2,a3
    80000418:	0ad7a023          	sw	a3,160(a5)
    8000041c:	07f77713          	andi	a4,a4,127
    80000420:	97ba                	add	a5,a5,a4
    80000422:	4729                	li	a4,10
    80000424:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000428:	00011797          	auipc	a5,0x11
    8000042c:	dec7aa23          	sw	a2,-524(a5) # 8001121c <cons+0x9c>
        wakeup(&cons.r);
    80000430:	00011517          	auipc	a0,0x11
    80000434:	de850513          	addi	a0,a0,-536 # 80011218 <cons+0x98>
    80000438:	00002097          	auipc	ra,0x2
    8000043c:	13a080e7          	jalr	314(ra) # 80002572 <wakeup>
    80000440:	b575                	j	800002ec <consoleintr+0x3c>

0000000080000442 <consoleinit>:

void
consoleinit(void)
{
    80000442:	1141                	addi	sp,sp,-16
    80000444:	e406                	sd	ra,8(sp)
    80000446:	e022                	sd	s0,0(sp)
    80000448:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000044a:	00008597          	auipc	a1,0x8
    8000044e:	bc658593          	addi	a1,a1,-1082 # 80008010 <etext+0x10>
    80000452:	00011517          	auipc	a0,0x11
    80000456:	d2e50513          	addi	a0,a0,-722 # 80011180 <cons>
    8000045a:	00000097          	auipc	ra,0x0
    8000045e:	6e8080e7          	jalr	1768(ra) # 80000b42 <initlock>

  uartinit();
    80000462:	00000097          	auipc	ra,0x0
    80000466:	330080e7          	jalr	816(ra) # 80000792 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000046a:	00021797          	auipc	a5,0x21
    8000046e:	fbe78793          	addi	a5,a5,-66 # 80021428 <devsw>
    80000472:	00000717          	auipc	a4,0x0
    80000476:	ce470713          	addi	a4,a4,-796 # 80000156 <consoleread>
    8000047a:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	c7870713          	addi	a4,a4,-904 # 800000f4 <consolewrite>
    80000484:	ef98                	sd	a4,24(a5)
}
    80000486:	60a2                	ld	ra,8(sp)
    80000488:	6402                	ld	s0,0(sp)
    8000048a:	0141                	addi	sp,sp,16
    8000048c:	8082                	ret

000000008000048e <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000048e:	7179                	addi	sp,sp,-48
    80000490:	f406                	sd	ra,40(sp)
    80000492:	f022                	sd	s0,32(sp)
    80000494:	ec26                	sd	s1,24(sp)
    80000496:	e84a                	sd	s2,16(sp)
    80000498:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    8000049a:	c219                	beqz	a2,800004a0 <printint+0x12>
    8000049c:	08054663          	bltz	a0,80000528 <printint+0x9a>
    x = -xx;
  else
    x = xx;
    800004a0:	2501                	sext.w	a0,a0
    800004a2:	4881                	li	a7,0
    800004a4:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004a8:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004aa:	2581                	sext.w	a1,a1
    800004ac:	00008617          	auipc	a2,0x8
    800004b0:	b9460613          	addi	a2,a2,-1132 # 80008040 <digits>
    800004b4:	883a                	mv	a6,a4
    800004b6:	2705                	addiw	a4,a4,1
    800004b8:	02b577bb          	remuw	a5,a0,a1
    800004bc:	1782                	slli	a5,a5,0x20
    800004be:	9381                	srli	a5,a5,0x20
    800004c0:	97b2                	add	a5,a5,a2
    800004c2:	0007c783          	lbu	a5,0(a5)
    800004c6:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004ca:	0005079b          	sext.w	a5,a0
    800004ce:	02b5553b          	divuw	a0,a0,a1
    800004d2:	0685                	addi	a3,a3,1
    800004d4:	feb7f0e3          	bgeu	a5,a1,800004b4 <printint+0x26>

  if(sign)
    800004d8:	00088b63          	beqz	a7,800004ee <printint+0x60>
    buf[i++] = '-';
    800004dc:	fe040793          	addi	a5,s0,-32
    800004e0:	973e                	add	a4,a4,a5
    800004e2:	02d00793          	li	a5,45
    800004e6:	fef70823          	sb	a5,-16(a4)
    800004ea:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004ee:	02e05763          	blez	a4,8000051c <printint+0x8e>
    800004f2:	fd040793          	addi	a5,s0,-48
    800004f6:	00e784b3          	add	s1,a5,a4
    800004fa:	fff78913          	addi	s2,a5,-1
    800004fe:	993a                	add	s2,s2,a4
    80000500:	377d                	addiw	a4,a4,-1
    80000502:	1702                	slli	a4,a4,0x20
    80000504:	9301                	srli	a4,a4,0x20
    80000506:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000050a:	fff4c503          	lbu	a0,-1(s1)
    8000050e:	00000097          	auipc	ra,0x0
    80000512:	d60080e7          	jalr	-672(ra) # 8000026e <consputc>
  while(--i >= 0)
    80000516:	14fd                	addi	s1,s1,-1
    80000518:	ff2499e3          	bne	s1,s2,8000050a <printint+0x7c>
}
    8000051c:	70a2                	ld	ra,40(sp)
    8000051e:	7402                	ld	s0,32(sp)
    80000520:	64e2                	ld	s1,24(sp)
    80000522:	6942                	ld	s2,16(sp)
    80000524:	6145                	addi	sp,sp,48
    80000526:	8082                	ret
    x = -xx;
    80000528:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000052c:	4885                	li	a7,1
    x = -xx;
    8000052e:	bf9d                	j	800004a4 <printint+0x16>

0000000080000530 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000530:	1101                	addi	sp,sp,-32
    80000532:	ec06                	sd	ra,24(sp)
    80000534:	e822                	sd	s0,16(sp)
    80000536:	e426                	sd	s1,8(sp)
    80000538:	1000                	addi	s0,sp,32
    8000053a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000053c:	00011797          	auipc	a5,0x11
    80000540:	d007a223          	sw	zero,-764(a5) # 80011240 <pr+0x18>
  printf("panic: ");
    80000544:	00008517          	auipc	a0,0x8
    80000548:	ad450513          	addi	a0,a0,-1324 # 80008018 <etext+0x18>
    8000054c:	00000097          	auipc	ra,0x0
    80000550:	02e080e7          	jalr	46(ra) # 8000057a <printf>
  printf(s);
    80000554:	8526                	mv	a0,s1
    80000556:	00000097          	auipc	ra,0x0
    8000055a:	024080e7          	jalr	36(ra) # 8000057a <printf>
  printf("\n");
    8000055e:	00008517          	auipc	a0,0x8
    80000562:	b6a50513          	addi	a0,a0,-1174 # 800080c8 <digits+0x88>
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	014080e7          	jalr	20(ra) # 8000057a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000056e:	4785                	li	a5,1
    80000570:	00009717          	auipc	a4,0x9
    80000574:	a8f72823          	sw	a5,-1392(a4) # 80009000 <panicked>
  for(;;)
    80000578:	a001                	j	80000578 <panic+0x48>

000000008000057a <printf>:
{
    8000057a:	7131                	addi	sp,sp,-192
    8000057c:	fc86                	sd	ra,120(sp)
    8000057e:	f8a2                	sd	s0,112(sp)
    80000580:	f4a6                	sd	s1,104(sp)
    80000582:	f0ca                	sd	s2,96(sp)
    80000584:	ecce                	sd	s3,88(sp)
    80000586:	e8d2                	sd	s4,80(sp)
    80000588:	e4d6                	sd	s5,72(sp)
    8000058a:	e0da                	sd	s6,64(sp)
    8000058c:	fc5e                	sd	s7,56(sp)
    8000058e:	f862                	sd	s8,48(sp)
    80000590:	f466                	sd	s9,40(sp)
    80000592:	f06a                	sd	s10,32(sp)
    80000594:	ec6e                	sd	s11,24(sp)
    80000596:	0100                	addi	s0,sp,128
    80000598:	8a2a                	mv	s4,a0
    8000059a:	e40c                	sd	a1,8(s0)
    8000059c:	e810                	sd	a2,16(s0)
    8000059e:	ec14                	sd	a3,24(s0)
    800005a0:	f018                	sd	a4,32(s0)
    800005a2:	f41c                	sd	a5,40(s0)
    800005a4:	03043823          	sd	a6,48(s0)
    800005a8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005ac:	00011d97          	auipc	s11,0x11
    800005b0:	c94dad83          	lw	s11,-876(s11) # 80011240 <pr+0x18>
  if(locking)
    800005b4:	020d9b63          	bnez	s11,800005ea <printf+0x70>
  if (fmt == 0)
    800005b8:	040a0263          	beqz	s4,800005fc <printf+0x82>
  va_start(ap, fmt);
    800005bc:	00840793          	addi	a5,s0,8
    800005c0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005c4:	000a4503          	lbu	a0,0(s4)
    800005c8:	16050263          	beqz	a0,8000072c <printf+0x1b2>
    800005cc:	4481                	li	s1,0
    if(c != '%'){
    800005ce:	02500a93          	li	s5,37
    switch(c){
    800005d2:	07000b13          	li	s6,112
  consputc('x');
    800005d6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005d8:	00008b97          	auipc	s7,0x8
    800005dc:	a68b8b93          	addi	s7,s7,-1432 # 80008040 <digits>
    switch(c){
    800005e0:	07300c93          	li	s9,115
    800005e4:	06400c13          	li	s8,100
    800005e8:	a82d                	j	80000622 <printf+0xa8>
    acquire(&pr.lock);
    800005ea:	00011517          	auipc	a0,0x11
    800005ee:	c3e50513          	addi	a0,a0,-962 # 80011228 <pr>
    800005f2:	00000097          	auipc	ra,0x0
    800005f6:	5e0080e7          	jalr	1504(ra) # 80000bd2 <acquire>
    800005fa:	bf7d                	j	800005b8 <printf+0x3e>
    panic("null fmt");
    800005fc:	00008517          	auipc	a0,0x8
    80000600:	a2c50513          	addi	a0,a0,-1492 # 80008028 <etext+0x28>
    80000604:	00000097          	auipc	ra,0x0
    80000608:	f2c080e7          	jalr	-212(ra) # 80000530 <panic>
      consputc(c);
    8000060c:	00000097          	auipc	ra,0x0
    80000610:	c62080e7          	jalr	-926(ra) # 8000026e <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000614:	2485                	addiw	s1,s1,1
    80000616:	009a07b3          	add	a5,s4,s1
    8000061a:	0007c503          	lbu	a0,0(a5)
    8000061e:	10050763          	beqz	a0,8000072c <printf+0x1b2>
    if(c != '%'){
    80000622:	ff5515e3          	bne	a0,s5,8000060c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000626:	2485                	addiw	s1,s1,1
    80000628:	009a07b3          	add	a5,s4,s1
    8000062c:	0007c783          	lbu	a5,0(a5)
    80000630:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80000634:	cfe5                	beqz	a5,8000072c <printf+0x1b2>
    switch(c){
    80000636:	05678a63          	beq	a5,s6,8000068a <printf+0x110>
    8000063a:	02fb7663          	bgeu	s6,a5,80000666 <printf+0xec>
    8000063e:	09978963          	beq	a5,s9,800006d0 <printf+0x156>
    80000642:	07800713          	li	a4,120
    80000646:	0ce79863          	bne	a5,a4,80000716 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    8000064a:	f8843783          	ld	a5,-120(s0)
    8000064e:	00878713          	addi	a4,a5,8
    80000652:	f8e43423          	sd	a4,-120(s0)
    80000656:	4605                	li	a2,1
    80000658:	85ea                	mv	a1,s10
    8000065a:	4388                	lw	a0,0(a5)
    8000065c:	00000097          	auipc	ra,0x0
    80000660:	e32080e7          	jalr	-462(ra) # 8000048e <printint>
      break;
    80000664:	bf45                	j	80000614 <printf+0x9a>
    switch(c){
    80000666:	0b578263          	beq	a5,s5,8000070a <printf+0x190>
    8000066a:	0b879663          	bne	a5,s8,80000716 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    8000066e:	f8843783          	ld	a5,-120(s0)
    80000672:	00878713          	addi	a4,a5,8
    80000676:	f8e43423          	sd	a4,-120(s0)
    8000067a:	4605                	li	a2,1
    8000067c:	45a9                	li	a1,10
    8000067e:	4388                	lw	a0,0(a5)
    80000680:	00000097          	auipc	ra,0x0
    80000684:	e0e080e7          	jalr	-498(ra) # 8000048e <printint>
      break;
    80000688:	b771                	j	80000614 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000068a:	f8843783          	ld	a5,-120(s0)
    8000068e:	00878713          	addi	a4,a5,8
    80000692:	f8e43423          	sd	a4,-120(s0)
    80000696:	0007b983          	ld	s3,0(a5)
  consputc('0');
    8000069a:	03000513          	li	a0,48
    8000069e:	00000097          	auipc	ra,0x0
    800006a2:	bd0080e7          	jalr	-1072(ra) # 8000026e <consputc>
  consputc('x');
    800006a6:	07800513          	li	a0,120
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bc4080e7          	jalr	-1084(ra) # 8000026e <consputc>
    800006b2:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006b4:	03c9d793          	srli	a5,s3,0x3c
    800006b8:	97de                	add	a5,a5,s7
    800006ba:	0007c503          	lbu	a0,0(a5)
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	bb0080e7          	jalr	-1104(ra) # 8000026e <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006c6:	0992                	slli	s3,s3,0x4
    800006c8:	397d                	addiw	s2,s2,-1
    800006ca:	fe0915e3          	bnez	s2,800006b4 <printf+0x13a>
    800006ce:	b799                	j	80000614 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006d0:	f8843783          	ld	a5,-120(s0)
    800006d4:	00878713          	addi	a4,a5,8
    800006d8:	f8e43423          	sd	a4,-120(s0)
    800006dc:	0007b903          	ld	s2,0(a5)
    800006e0:	00090e63          	beqz	s2,800006fc <printf+0x182>
      for(; *s; s++)
    800006e4:	00094503          	lbu	a0,0(s2)
    800006e8:	d515                	beqz	a0,80000614 <printf+0x9a>
        consputc(*s);
    800006ea:	00000097          	auipc	ra,0x0
    800006ee:	b84080e7          	jalr	-1148(ra) # 8000026e <consputc>
      for(; *s; s++)
    800006f2:	0905                	addi	s2,s2,1
    800006f4:	00094503          	lbu	a0,0(s2)
    800006f8:	f96d                	bnez	a0,800006ea <printf+0x170>
    800006fa:	bf29                	j	80000614 <printf+0x9a>
        s = "(null)";
    800006fc:	00008917          	auipc	s2,0x8
    80000700:	92490913          	addi	s2,s2,-1756 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000704:	02800513          	li	a0,40
    80000708:	b7cd                	j	800006ea <printf+0x170>
      consputc('%');
    8000070a:	8556                	mv	a0,s5
    8000070c:	00000097          	auipc	ra,0x0
    80000710:	b62080e7          	jalr	-1182(ra) # 8000026e <consputc>
      break;
    80000714:	b701                	j	80000614 <printf+0x9a>
      consputc('%');
    80000716:	8556                	mv	a0,s5
    80000718:	00000097          	auipc	ra,0x0
    8000071c:	b56080e7          	jalr	-1194(ra) # 8000026e <consputc>
      consputc(c);
    80000720:	854a                	mv	a0,s2
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b4c080e7          	jalr	-1204(ra) # 8000026e <consputc>
      break;
    8000072a:	b5ed                	j	80000614 <printf+0x9a>
  if(locking)
    8000072c:	020d9163          	bnez	s11,8000074e <printf+0x1d4>
}
    80000730:	70e6                	ld	ra,120(sp)
    80000732:	7446                	ld	s0,112(sp)
    80000734:	74a6                	ld	s1,104(sp)
    80000736:	7906                	ld	s2,96(sp)
    80000738:	69e6                	ld	s3,88(sp)
    8000073a:	6a46                	ld	s4,80(sp)
    8000073c:	6aa6                	ld	s5,72(sp)
    8000073e:	6b06                	ld	s6,64(sp)
    80000740:	7be2                	ld	s7,56(sp)
    80000742:	7c42                	ld	s8,48(sp)
    80000744:	7ca2                	ld	s9,40(sp)
    80000746:	7d02                	ld	s10,32(sp)
    80000748:	6de2                	ld	s11,24(sp)
    8000074a:	6129                	addi	sp,sp,192
    8000074c:	8082                	ret
    release(&pr.lock);
    8000074e:	00011517          	auipc	a0,0x11
    80000752:	ada50513          	addi	a0,a0,-1318 # 80011228 <pr>
    80000756:	00000097          	auipc	ra,0x0
    8000075a:	530080e7          	jalr	1328(ra) # 80000c86 <release>
}
    8000075e:	bfc9                	j	80000730 <printf+0x1b6>

0000000080000760 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000760:	1101                	addi	sp,sp,-32
    80000762:	ec06                	sd	ra,24(sp)
    80000764:	e822                	sd	s0,16(sp)
    80000766:	e426                	sd	s1,8(sp)
    80000768:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000076a:	00011497          	auipc	s1,0x11
    8000076e:	abe48493          	addi	s1,s1,-1346 # 80011228 <pr>
    80000772:	00008597          	auipc	a1,0x8
    80000776:	8c658593          	addi	a1,a1,-1850 # 80008038 <etext+0x38>
    8000077a:	8526                	mv	a0,s1
    8000077c:	00000097          	auipc	ra,0x0
    80000780:	3c6080e7          	jalr	966(ra) # 80000b42 <initlock>
  pr.locking = 1;
    80000784:	4785                	li	a5,1
    80000786:	cc9c                	sw	a5,24(s1)
}
    80000788:	60e2                	ld	ra,24(sp)
    8000078a:	6442                	ld	s0,16(sp)
    8000078c:	64a2                	ld	s1,8(sp)
    8000078e:	6105                	addi	sp,sp,32
    80000790:	8082                	ret

0000000080000792 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000792:	1141                	addi	sp,sp,-16
    80000794:	e406                	sd	ra,8(sp)
    80000796:	e022                	sd	s0,0(sp)
    80000798:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000079a:	100007b7          	lui	a5,0x10000
    8000079e:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a2:	f8000713          	li	a4,-128
    800007a6:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007aa:	470d                	li	a4,3
    800007ac:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b0:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007b4:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007b8:	469d                	li	a3,7
    800007ba:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007be:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c2:	00008597          	auipc	a1,0x8
    800007c6:	89658593          	addi	a1,a1,-1898 # 80008058 <digits+0x18>
    800007ca:	00011517          	auipc	a0,0x11
    800007ce:	a7e50513          	addi	a0,a0,-1410 # 80011248 <uart_tx_lock>
    800007d2:	00000097          	auipc	ra,0x0
    800007d6:	370080e7          	jalr	880(ra) # 80000b42 <initlock>
}
    800007da:	60a2                	ld	ra,8(sp)
    800007dc:	6402                	ld	s0,0(sp)
    800007de:	0141                	addi	sp,sp,16
    800007e0:	8082                	ret

00000000800007e2 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e2:	1101                	addi	sp,sp,-32
    800007e4:	ec06                	sd	ra,24(sp)
    800007e6:	e822                	sd	s0,16(sp)
    800007e8:	e426                	sd	s1,8(sp)
    800007ea:	1000                	addi	s0,sp,32
    800007ec:	84aa                	mv	s1,a0
  push_off();
    800007ee:	00000097          	auipc	ra,0x0
    800007f2:	398080e7          	jalr	920(ra) # 80000b86 <push_off>

  if(panicked){
    800007f6:	00009797          	auipc	a5,0x9
    800007fa:	80a7a783          	lw	a5,-2038(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800007fe:	10000737          	lui	a4,0x10000
  if(panicked){
    80000802:	c391                	beqz	a5,80000806 <uartputc_sync+0x24>
    for(;;)
    80000804:	a001                	j	80000804 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000806:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000080a:	0ff7f793          	andi	a5,a5,255
    8000080e:	0207f793          	andi	a5,a5,32
    80000812:	dbf5                	beqz	a5,80000806 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000814:	0ff4f793          	andi	a5,s1,255
    80000818:	10000737          	lui	a4,0x10000
    8000081c:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80000820:	00000097          	auipc	ra,0x0
    80000824:	406080e7          	jalr	1030(ra) # 80000c26 <pop_off>
}
    80000828:	60e2                	ld	ra,24(sp)
    8000082a:	6442                	ld	s0,16(sp)
    8000082c:	64a2                	ld	s1,8(sp)
    8000082e:	6105                	addi	sp,sp,32
    80000830:	8082                	ret

0000000080000832 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000832:	00008717          	auipc	a4,0x8
    80000836:	7d673703          	ld	a4,2006(a4) # 80009008 <uart_tx_r>
    8000083a:	00008797          	auipc	a5,0x8
    8000083e:	7d67b783          	ld	a5,2006(a5) # 80009010 <uart_tx_w>
    80000842:	06e78c63          	beq	a5,a4,800008ba <uartstart+0x88>
{
    80000846:	7139                	addi	sp,sp,-64
    80000848:	fc06                	sd	ra,56(sp)
    8000084a:	f822                	sd	s0,48(sp)
    8000084c:	f426                	sd	s1,40(sp)
    8000084e:	f04a                	sd	s2,32(sp)
    80000850:	ec4e                	sd	s3,24(sp)
    80000852:	e852                	sd	s4,16(sp)
    80000854:	e456                	sd	s5,8(sp)
    80000856:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000858:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085c:	00011a17          	auipc	s4,0x11
    80000860:	9eca0a13          	addi	s4,s4,-1556 # 80011248 <uart_tx_lock>
    uart_tx_r += 1;
    80000864:	00008497          	auipc	s1,0x8
    80000868:	7a448493          	addi	s1,s1,1956 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086c:	00008997          	auipc	s3,0x8
    80000870:	7a498993          	addi	s3,s3,1956 # 80009010 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000874:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000878:	0ff7f793          	andi	a5,a5,255
    8000087c:	0207f793          	andi	a5,a5,32
    80000880:	c785                	beqz	a5,800008a8 <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000882:	01f77793          	andi	a5,a4,31
    80000886:	97d2                	add	a5,a5,s4
    80000888:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    8000088c:	0705                	addi	a4,a4,1
    8000088e:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000890:	8526                	mv	a0,s1
    80000892:	00002097          	auipc	ra,0x2
    80000896:	ce0080e7          	jalr	-800(ra) # 80002572 <wakeup>
    
    WriteReg(THR, c);
    8000089a:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089e:	6098                	ld	a4,0(s1)
    800008a0:	0009b783          	ld	a5,0(s3)
    800008a4:	fce798e3          	bne	a5,a4,80000874 <uartstart+0x42>
  }
}
    800008a8:	70e2                	ld	ra,56(sp)
    800008aa:	7442                	ld	s0,48(sp)
    800008ac:	74a2                	ld	s1,40(sp)
    800008ae:	7902                	ld	s2,32(sp)
    800008b0:	69e2                	ld	s3,24(sp)
    800008b2:	6a42                	ld	s4,16(sp)
    800008b4:	6aa2                	ld	s5,8(sp)
    800008b6:	6121                	addi	sp,sp,64
    800008b8:	8082                	ret
    800008ba:	8082                	ret

00000000800008bc <uartputc>:
{
    800008bc:	7179                	addi	sp,sp,-48
    800008be:	f406                	sd	ra,40(sp)
    800008c0:	f022                	sd	s0,32(sp)
    800008c2:	ec26                	sd	s1,24(sp)
    800008c4:	e84a                	sd	s2,16(sp)
    800008c6:	e44e                	sd	s3,8(sp)
    800008c8:	e052                	sd	s4,0(sp)
    800008ca:	1800                	addi	s0,sp,48
    800008cc:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    800008ce:	00011517          	auipc	a0,0x11
    800008d2:	97a50513          	addi	a0,a0,-1670 # 80011248 <uart_tx_lock>
    800008d6:	00000097          	auipc	ra,0x0
    800008da:	2fc080e7          	jalr	764(ra) # 80000bd2 <acquire>
  if(panicked){
    800008de:	00008797          	auipc	a5,0x8
    800008e2:	7227a783          	lw	a5,1826(a5) # 80009000 <panicked>
    800008e6:	c391                	beqz	a5,800008ea <uartputc+0x2e>
    for(;;)
    800008e8:	a001                	j	800008e8 <uartputc+0x2c>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008ea:	00008797          	auipc	a5,0x8
    800008ee:	7267b783          	ld	a5,1830(a5) # 80009010 <uart_tx_w>
    800008f2:	00008717          	auipc	a4,0x8
    800008f6:	71673703          	ld	a4,1814(a4) # 80009008 <uart_tx_r>
    800008fa:	02070713          	addi	a4,a4,32
    800008fe:	02f71b63          	bne	a4,a5,80000934 <uartputc+0x78>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000902:	00011a17          	auipc	s4,0x11
    80000906:	946a0a13          	addi	s4,s4,-1722 # 80011248 <uart_tx_lock>
    8000090a:	00008497          	auipc	s1,0x8
    8000090e:	6fe48493          	addi	s1,s1,1790 # 80009008 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000912:	00008917          	auipc	s2,0x8
    80000916:	6fe90913          	addi	s2,s2,1790 # 80009010 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85d2                	mv	a1,s4
    8000091c:	8526                	mv	a0,s1
    8000091e:	00002097          	auipc	ra,0x2
    80000922:	ac8080e7          	jalr	-1336(ra) # 800023e6 <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000926:	00093783          	ld	a5,0(s2)
    8000092a:	6098                	ld	a4,0(s1)
    8000092c:	02070713          	addi	a4,a4,32
    80000930:	fef705e3          	beq	a4,a5,8000091a <uartputc+0x5e>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00011497          	auipc	s1,0x11
    80000938:	91448493          	addi	s1,s1,-1772 # 80011248 <uart_tx_lock>
    8000093c:	01f7f713          	andi	a4,a5,31
    80000940:	9726                	add	a4,a4,s1
    80000942:	01370c23          	sb	s3,24(a4)
      uart_tx_w += 1;
    80000946:	0785                	addi	a5,a5,1
    80000948:	00008717          	auipc	a4,0x8
    8000094c:	6cf73423          	sd	a5,1736(a4) # 80009010 <uart_tx_w>
      uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee2080e7          	jalr	-286(ra) # 80000832 <uartstart>
      release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	32c080e7          	jalr	812(ra) # 80000c86 <release>
}
    80000962:	70a2                	ld	ra,40(sp)
    80000964:	7402                	ld	s0,32(sp)
    80000966:	64e2                	ld	s1,24(sp)
    80000968:	6942                	ld	s2,16(sp)
    8000096a:	69a2                	ld	s3,8(sp)
    8000096c:	6a02                	ld	s4,0(sp)
    8000096e:	6145                	addi	sp,sp,48
    80000970:	8082                	ret

0000000080000972 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000972:	1141                	addi	sp,sp,-16
    80000974:	e422                	sd	s0,8(sp)
    80000976:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000978:	100007b7          	lui	a5,0x10000
    8000097c:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000980:	8b85                	andi	a5,a5,1
    80000982:	cb81                	beqz	a5,80000992 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000984:	100007b7          	lui	a5,0x10000
    80000988:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098c:	6422                	ld	s0,8(sp)
    8000098e:	0141                	addi	sp,sp,16
    80000990:	8082                	ret
    return -1;
    80000992:	557d                	li	a0,-1
    80000994:	bfe5                	j	8000098c <uartgetc+0x1a>

0000000080000996 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000996:	1101                	addi	sp,sp,-32
    80000998:	ec06                	sd	ra,24(sp)
    8000099a:	e822                	sd	s0,16(sp)
    8000099c:	e426                	sd	s1,8(sp)
    8000099e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a0:	54fd                	li	s1,-1
    int c = uartgetc();
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	fd0080e7          	jalr	-48(ra) # 80000972 <uartgetc>
    if(c == -1)
    800009aa:	00950763          	beq	a0,s1,800009b8 <uartintr+0x22>
      break;
    consoleintr(c);
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	902080e7          	jalr	-1790(ra) # 800002b0 <consoleintr>
  while(1){
    800009b6:	b7f5                	j	800009a2 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b8:	00011497          	auipc	s1,0x11
    800009bc:	89048493          	addi	s1,s1,-1904 # 80011248 <uart_tx_lock>
    800009c0:	8526                	mv	a0,s1
    800009c2:	00000097          	auipc	ra,0x0
    800009c6:	210080e7          	jalr	528(ra) # 80000bd2 <acquire>
  uartstart();
    800009ca:	00000097          	auipc	ra,0x0
    800009ce:	e68080e7          	jalr	-408(ra) # 80000832 <uartstart>
  release(&uart_tx_lock);
    800009d2:	8526                	mv	a0,s1
    800009d4:	00000097          	auipc	ra,0x0
    800009d8:	2b2080e7          	jalr	690(ra) # 80000c86 <release>
}
    800009dc:	60e2                	ld	ra,24(sp)
    800009de:	6442                	ld	s0,16(sp)
    800009e0:	64a2                	ld	s1,8(sp)
    800009e2:	6105                	addi	sp,sp,32
    800009e4:	8082                	ret

00000000800009e6 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e6:	1101                	addi	sp,sp,-32
    800009e8:	ec06                	sd	ra,24(sp)
    800009ea:	e822                	sd	s0,16(sp)
    800009ec:	e426                	sd	s1,8(sp)
    800009ee:	e04a                	sd	s2,0(sp)
    800009f0:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f2:	03451793          	slli	a5,a0,0x34
    800009f6:	ebb9                	bnez	a5,80000a4c <kfree+0x66>
    800009f8:	84aa                	mv	s1,a0
    800009fa:	00025797          	auipc	a5,0x25
    800009fe:	60678793          	addi	a5,a5,1542 # 80026000 <end>
    80000a02:	04f56563          	bltu	a0,a5,80000a4c <kfree+0x66>
    80000a06:	47c5                	li	a5,17
    80000a08:	07ee                	slli	a5,a5,0x1b
    80000a0a:	04f57163          	bgeu	a0,a5,80000a4c <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0e:	6605                	lui	a2,0x1
    80000a10:	4585                	li	a1,1
    80000a12:	00000097          	auipc	ra,0x0
    80000a16:	2bc080e7          	jalr	700(ra) # 80000cce <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1a:	00011917          	auipc	s2,0x11
    80000a1e:	86690913          	addi	s2,s2,-1946 # 80011280 <kmem>
    80000a22:	854a                	mv	a0,s2
    80000a24:	00000097          	auipc	ra,0x0
    80000a28:	1ae080e7          	jalr	430(ra) # 80000bd2 <acquire>
  r->next = kmem.freelist;
    80000a2c:	01893783          	ld	a5,24(s2)
    80000a30:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a32:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a36:	854a                	mv	a0,s2
    80000a38:	00000097          	auipc	ra,0x0
    80000a3c:	24e080e7          	jalr	590(ra) # 80000c86 <release>
}
    80000a40:	60e2                	ld	ra,24(sp)
    80000a42:	6442                	ld	s0,16(sp)
    80000a44:	64a2                	ld	s1,8(sp)
    80000a46:	6902                	ld	s2,0(sp)
    80000a48:	6105                	addi	sp,sp,32
    80000a4a:	8082                	ret
    panic("kfree");
    80000a4c:	00007517          	auipc	a0,0x7
    80000a50:	61450513          	addi	a0,a0,1556 # 80008060 <digits+0x20>
    80000a54:	00000097          	auipc	ra,0x0
    80000a58:	adc080e7          	jalr	-1316(ra) # 80000530 <panic>

0000000080000a5c <freerange>:
{
    80000a5c:	7179                	addi	sp,sp,-48
    80000a5e:	f406                	sd	ra,40(sp)
    80000a60:	f022                	sd	s0,32(sp)
    80000a62:	ec26                	sd	s1,24(sp)
    80000a64:	e84a                	sd	s2,16(sp)
    80000a66:	e44e                	sd	s3,8(sp)
    80000a68:	e052                	sd	s4,0(sp)
    80000a6a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6c:	6785                	lui	a5,0x1
    80000a6e:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a72:	94aa                	add	s1,s1,a0
    80000a74:	757d                	lui	a0,0xfffff
    80000a76:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a78:	94be                	add	s1,s1,a5
    80000a7a:	0095ee63          	bltu	a1,s1,80000a96 <freerange+0x3a>
    80000a7e:	892e                	mv	s2,a1
    kfree(p);
    80000a80:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a82:	6985                	lui	s3,0x1
    kfree(p);
    80000a84:	01448533          	add	a0,s1,s4
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	f5e080e7          	jalr	-162(ra) # 800009e6 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94ce                	add	s1,s1,s3
    80000a92:	fe9979e3          	bgeu	s2,s1,80000a84 <freerange+0x28>
}
    80000a96:	70a2                	ld	ra,40(sp)
    80000a98:	7402                	ld	s0,32(sp)
    80000a9a:	64e2                	ld	s1,24(sp)
    80000a9c:	6942                	ld	s2,16(sp)
    80000a9e:	69a2                	ld	s3,8(sp)
    80000aa0:	6a02                	ld	s4,0(sp)
    80000aa2:	6145                	addi	sp,sp,48
    80000aa4:	8082                	ret

0000000080000aa6 <kinit>:
{
    80000aa6:	1141                	addi	sp,sp,-16
    80000aa8:	e406                	sd	ra,8(sp)
    80000aaa:	e022                	sd	s0,0(sp)
    80000aac:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aae:	00007597          	auipc	a1,0x7
    80000ab2:	5ba58593          	addi	a1,a1,1466 # 80008068 <digits+0x28>
    80000ab6:	00010517          	auipc	a0,0x10
    80000aba:	7ca50513          	addi	a0,a0,1994 # 80011280 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	slli	a1,a1,0x1b
    80000aca:	00025517          	auipc	a0,0x25
    80000ace:	53650513          	addi	a0,a0,1334 # 80026000 <end>
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	f8a080e7          	jalr	-118(ra) # 80000a5c <freerange>
}
    80000ada:	60a2                	ld	ra,8(sp)
    80000adc:	6402                	ld	s0,0(sp)
    80000ade:	0141                	addi	sp,sp,16
    80000ae0:	8082                	ret

0000000080000ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae2:	1101                	addi	sp,sp,-32
    80000ae4:	ec06                	sd	ra,24(sp)
    80000ae6:	e822                	sd	s0,16(sp)
    80000ae8:	e426                	sd	s1,8(sp)
    80000aea:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aec:	00010497          	auipc	s1,0x10
    80000af0:	79448493          	addi	s1,s1,1940 # 80011280 <kmem>
    80000af4:	8526                	mv	a0,s1
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	0dc080e7          	jalr	220(ra) # 80000bd2 <acquire>
  r = kmem.freelist;
    80000afe:	6c84                	ld	s1,24(s1)
  if(r)
    80000b00:	c885                	beqz	s1,80000b30 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b02:	609c                	ld	a5,0(s1)
    80000b04:	00010517          	auipc	a0,0x10
    80000b08:	77c50513          	addi	a0,a0,1916 # 80011280 <kmem>
    80000b0c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	178080e7          	jalr	376(ra) # 80000c86 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b16:	6605                	lui	a2,0x1
    80000b18:	4595                	li	a1,5
    80000b1a:	8526                	mv	a0,s1
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	1b2080e7          	jalr	434(ra) # 80000cce <memset>
  return (void*)r;
}
    80000b24:	8526                	mv	a0,s1
    80000b26:	60e2                	ld	ra,24(sp)
    80000b28:	6442                	ld	s0,16(sp)
    80000b2a:	64a2                	ld	s1,8(sp)
    80000b2c:	6105                	addi	sp,sp,32
    80000b2e:	8082                	ret
  release(&kmem.lock);
    80000b30:	00010517          	auipc	a0,0x10
    80000b34:	75050513          	addi	a0,a0,1872 # 80011280 <kmem>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	14e080e7          	jalr	334(ra) # 80000c86 <release>
  if(r)
    80000b40:	b7d5                	j	80000b24 <kalloc+0x42>

0000000080000b42 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b42:	1141                	addi	sp,sp,-16
    80000b44:	e422                	sd	s0,8(sp)
    80000b46:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b48:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4e:	00053823          	sd	zero,16(a0)
}
    80000b52:	6422                	ld	s0,8(sp)
    80000b54:	0141                	addi	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b58:	411c                	lw	a5,0(a0)
    80000b5a:	e399                	bnez	a5,80000b60 <holding+0x8>
    80000b5c:	4501                	li	a0,0
  return r;
}
    80000b5e:	8082                	ret
{
    80000b60:	1101                	addi	sp,sp,-32
    80000b62:	ec06                	sd	ra,24(sp)
    80000b64:	e822                	sd	s0,16(sp)
    80000b66:	e426                	sd	s1,8(sp)
    80000b68:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	6904                	ld	s1,16(a0)
    80000b6c:	00001097          	auipc	ra,0x1
    80000b70:	efa080e7          	jalr	-262(ra) # 80001a66 <mycpu>
    80000b74:	40a48533          	sub	a0,s1,a0
    80000b78:	00153513          	seqz	a0,a0
}
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6105                	addi	sp,sp,32
    80000b84:	8082                	ret

0000000080000b86 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b86:	1101                	addi	sp,sp,-32
    80000b88:	ec06                	sd	ra,24(sp)
    80000b8a:	e822                	sd	s0,16(sp)
    80000b8c:	e426                	sd	s1,8(sp)
    80000b8e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b90:	100024f3          	csrr	s1,sstatus
    80000b94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b98:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	ec8080e7          	jalr	-312(ra) # 80001a66 <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	cf89                	beqz	a5,80000bc2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	ebc080e7          	jalr	-324(ra) # 80001a66 <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	ea4080e7          	jalr	-348(ra) # 80001a66 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bca:	8085                	srli	s1,s1,0x1
    80000bcc:	8885                	andi	s1,s1,1
    80000bce:	dd64                	sw	s1,124(a0)
    80000bd0:	bfe9                	j	80000baa <push_off+0x24>

0000000080000bd2 <acquire>:
{
    80000bd2:	1101                	addi	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	addi	s0,sp,32
    80000bdc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bde:	00000097          	auipc	ra,0x0
    80000be2:	fa8080e7          	jalr	-88(ra) # 80000b86 <push_off>
  if(holding(lk))
    80000be6:	8526                	mv	a0,s1
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	f70080e7          	jalr	-144(ra) # 80000b58 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf0:	4705                	li	a4,1
  if(holding(lk))
    80000bf2:	e115                	bnez	a0,80000c16 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	87ba                	mv	a5,a4
    80000bf6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfa:	2781                	sext.w	a5,a5
    80000bfc:	ffe5                	bnez	a5,80000bf4 <acquire+0x22>
  __sync_synchronize();
    80000bfe:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c02:	00001097          	auipc	ra,0x1
    80000c06:	e64080e7          	jalr	-412(ra) # 80001a66 <mycpu>
    80000c0a:	e888                	sd	a0,16(s1)
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	addi	sp,sp,32
    80000c14:	8082                	ret
    panic("acquire");
    80000c16:	00007517          	auipc	a0,0x7
    80000c1a:	45a50513          	addi	a0,a0,1114 # 80008070 <digits+0x30>
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	912080e7          	jalr	-1774(ra) # 80000530 <panic>

0000000080000c26 <pop_off>:

void
pop_off(void)
{
    80000c26:	1141                	addi	sp,sp,-16
    80000c28:	e406                	sd	ra,8(sp)
    80000c2a:	e022                	sd	s0,0(sp)
    80000c2c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	e38080e7          	jalr	-456(ra) # 80001a66 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c36:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c3c:	e78d                	bnez	a5,80000c66 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3e:	5d3c                	lw	a5,120(a0)
    80000c40:	02f05b63          	blez	a5,80000c76 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c44:	37fd                	addiw	a5,a5,-1
    80000c46:	0007871b          	sext.w	a4,a5
    80000c4a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4c:	eb09                	bnez	a4,80000c5e <pop_off+0x38>
    80000c4e:	5d7c                	lw	a5,124(a0)
    80000c50:	c799                	beqz	a5,80000c5e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c52:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c56:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5e:	60a2                	ld	ra,8(sp)
    80000c60:	6402                	ld	s0,0(sp)
    80000c62:	0141                	addi	sp,sp,16
    80000c64:	8082                	ret
    panic("pop_off - interruptible");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	41250513          	addi	a0,a0,1042 # 80008078 <digits+0x38>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8c2080e7          	jalr	-1854(ra) # 80000530 <panic>
    panic("pop_off");
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	41a50513          	addi	a0,a0,1050 # 80008090 <digits+0x50>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8b2080e7          	jalr	-1870(ra) # 80000530 <panic>

0000000080000c86 <release>:
{
    80000c86:	1101                	addi	sp,sp,-32
    80000c88:	ec06                	sd	ra,24(sp)
    80000c8a:	e822                	sd	s0,16(sp)
    80000c8c:	e426                	sd	s1,8(sp)
    80000c8e:	1000                	addi	s0,sp,32
    80000c90:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c92:	00000097          	auipc	ra,0x0
    80000c96:	ec6080e7          	jalr	-314(ra) # 80000b58 <holding>
    80000c9a:	c115                	beqz	a0,80000cbe <release+0x38>
  lk->cpu = 0;
    80000c9c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca4:	0f50000f          	fence	iorw,ow
    80000ca8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	f7a080e7          	jalr	-134(ra) # 80000c26 <pop_off>
}
    80000cb4:	60e2                	ld	ra,24(sp)
    80000cb6:	6442                	ld	s0,16(sp)
    80000cb8:	64a2                	ld	s1,8(sp)
    80000cba:	6105                	addi	sp,sp,32
    80000cbc:	8082                	ret
    panic("release");
    80000cbe:	00007517          	auipc	a0,0x7
    80000cc2:	3da50513          	addi	a0,a0,986 # 80008098 <digits+0x58>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	86a080e7          	jalr	-1942(ra) # 80000530 <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	addi	sp,sp,-16
    80000cd0:	e422                	sd	s0,8(sp)
    80000cd2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd4:	ce09                	beqz	a2,80000cee <memset+0x20>
    80000cd6:	87aa                	mv	a5,a0
    80000cd8:	fff6071b          	addiw	a4,a2,-1
    80000cdc:	1702                	slli	a4,a4,0x20
    80000cde:	9301                	srli	a4,a4,0x20
    80000ce0:	0705                	addi	a4,a4,1
    80000ce2:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x16>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d34:	00a5f963          	bgeu	a1,a0,80000d46 <memmove+0x18>
    80000d38:	02061713          	slli	a4,a2,0x20
    80000d3c:	9301                	srli	a4,a4,0x20
    80000d3e:	00e587b3          	add	a5,a1,a4
    80000d42:	02f56563          	bltu	a0,a5,80000d6c <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d46:	fff6069b          	addiw	a3,a2,-1
    80000d4a:	ce11                	beqz	a2,80000d66 <memmove+0x38>
    80000d4c:	1682                	slli	a3,a3,0x20
    80000d4e:	9281                	srli	a3,a3,0x20
    80000d50:	0685                	addi	a3,a3,1
    80000d52:	96ae                	add	a3,a3,a1
    80000d54:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000d56:	0585                	addi	a1,a1,1
    80000d58:	0785                	addi	a5,a5,1
    80000d5a:	fff5c703          	lbu	a4,-1(a1)
    80000d5e:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000d62:	fed59ae3          	bne	a1,a3,80000d56 <memmove+0x28>

  return dst;
}
    80000d66:	6422                	ld	s0,8(sp)
    80000d68:	0141                	addi	sp,sp,16
    80000d6a:	8082                	ret
    d += n;
    80000d6c:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000d6e:	fff6069b          	addiw	a3,a2,-1
    80000d72:	da75                	beqz	a2,80000d66 <memmove+0x38>
    80000d74:	02069613          	slli	a2,a3,0x20
    80000d78:	9201                	srli	a2,a2,0x20
    80000d7a:	fff64613          	not	a2,a2
    80000d7e:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000d80:	17fd                	addi	a5,a5,-1
    80000d82:	177d                	addi	a4,a4,-1
    80000d84:	0007c683          	lbu	a3,0(a5)
    80000d88:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000d8c:	fec79ae3          	bne	a5,a2,80000d80 <memmove+0x52>
    80000d90:	bfd9                	j	80000d66 <memmove+0x38>

0000000080000d92 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d92:	1141                	addi	sp,sp,-16
    80000d94:	e406                	sd	ra,8(sp)
    80000d96:	e022                	sd	s0,0(sp)
    80000d98:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d9a:	00000097          	auipc	ra,0x0
    80000d9e:	f94080e7          	jalr	-108(ra) # 80000d2e <memmove>
}
    80000da2:	60a2                	ld	ra,8(sp)
    80000da4:	6402                	ld	s0,0(sp)
    80000da6:	0141                	addi	sp,sp,16
    80000da8:	8082                	ret

0000000080000daa <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000daa:	1141                	addi	sp,sp,-16
    80000dac:	e422                	sd	s0,8(sp)
    80000dae:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000db0:	ce11                	beqz	a2,80000dcc <strncmp+0x22>
    80000db2:	00054783          	lbu	a5,0(a0)
    80000db6:	cf89                	beqz	a5,80000dd0 <strncmp+0x26>
    80000db8:	0005c703          	lbu	a4,0(a1)
    80000dbc:	00f71a63          	bne	a4,a5,80000dd0 <strncmp+0x26>
    n--, p++, q++;
    80000dc0:	367d                	addiw	a2,a2,-1
    80000dc2:	0505                	addi	a0,a0,1
    80000dc4:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dc6:	f675                	bnez	a2,80000db2 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc8:	4501                	li	a0,0
    80000dca:	a809                	j	80000ddc <strncmp+0x32>
    80000dcc:	4501                	li	a0,0
    80000dce:	a039                	j	80000ddc <strncmp+0x32>
  if(n == 0)
    80000dd0:	ca09                	beqz	a2,80000de2 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dd2:	00054503          	lbu	a0,0(a0)
    80000dd6:	0005c783          	lbu	a5,0(a1)
    80000dda:	9d1d                	subw	a0,a0,a5
}
    80000ddc:	6422                	ld	s0,8(sp)
    80000dde:	0141                	addi	sp,sp,16
    80000de0:	8082                	ret
    return 0;
    80000de2:	4501                	li	a0,0
    80000de4:	bfe5                	j	80000ddc <strncmp+0x32>

0000000080000de6 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000de6:	1141                	addi	sp,sp,-16
    80000de8:	e422                	sd	s0,8(sp)
    80000dea:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dec:	872a                	mv	a4,a0
    80000dee:	8832                	mv	a6,a2
    80000df0:	367d                	addiw	a2,a2,-1
    80000df2:	01005963          	blez	a6,80000e04 <strncpy+0x1e>
    80000df6:	0705                	addi	a4,a4,1
    80000df8:	0005c783          	lbu	a5,0(a1)
    80000dfc:	fef70fa3          	sb	a5,-1(a4)
    80000e00:	0585                	addi	a1,a1,1
    80000e02:	f7f5                	bnez	a5,80000dee <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e04:	00c05d63          	blez	a2,80000e1e <strncpy+0x38>
    80000e08:	86ba                	mv	a3,a4
    *s++ = 0;
    80000e0a:	0685                	addi	a3,a3,1
    80000e0c:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e10:	fff6c793          	not	a5,a3
    80000e14:	9fb9                	addw	a5,a5,a4
    80000e16:	010787bb          	addw	a5,a5,a6
    80000e1a:	fef048e3          	bgtz	a5,80000e0a <strncpy+0x24>
  return os;
}
    80000e1e:	6422                	ld	s0,8(sp)
    80000e20:	0141                	addi	sp,sp,16
    80000e22:	8082                	ret

0000000080000e24 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e24:	1141                	addi	sp,sp,-16
    80000e26:	e422                	sd	s0,8(sp)
    80000e28:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e2a:	02c05363          	blez	a2,80000e50 <safestrcpy+0x2c>
    80000e2e:	fff6069b          	addiw	a3,a2,-1
    80000e32:	1682                	slli	a3,a3,0x20
    80000e34:	9281                	srli	a3,a3,0x20
    80000e36:	96ae                	add	a3,a3,a1
    80000e38:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e3a:	00d58963          	beq	a1,a3,80000e4c <safestrcpy+0x28>
    80000e3e:	0585                	addi	a1,a1,1
    80000e40:	0785                	addi	a5,a5,1
    80000e42:	fff5c703          	lbu	a4,-1(a1)
    80000e46:	fee78fa3          	sb	a4,-1(a5)
    80000e4a:	fb65                	bnez	a4,80000e3a <safestrcpy+0x16>
    ;
  *s = 0;
    80000e4c:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e50:	6422                	ld	s0,8(sp)
    80000e52:	0141                	addi	sp,sp,16
    80000e54:	8082                	ret

0000000080000e56 <strlen>:

int
strlen(const char *s)
{
    80000e56:	1141                	addi	sp,sp,-16
    80000e58:	e422                	sd	s0,8(sp)
    80000e5a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e5c:	00054783          	lbu	a5,0(a0)
    80000e60:	cf91                	beqz	a5,80000e7c <strlen+0x26>
    80000e62:	0505                	addi	a0,a0,1
    80000e64:	87aa                	mv	a5,a0
    80000e66:	4685                	li	a3,1
    80000e68:	9e89                	subw	a3,a3,a0
    80000e6a:	00f6853b          	addw	a0,a3,a5
    80000e6e:	0785                	addi	a5,a5,1
    80000e70:	fff7c703          	lbu	a4,-1(a5)
    80000e74:	fb7d                	bnez	a4,80000e6a <strlen+0x14>
    ;
  return n;
}
    80000e76:	6422                	ld	s0,8(sp)
    80000e78:	0141                	addi	sp,sp,16
    80000e7a:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e7c:	4501                	li	a0,0
    80000e7e:	bfe5                	j	80000e76 <strlen+0x20>

0000000080000e80 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e80:	1141                	addi	sp,sp,-16
    80000e82:	e406                	sd	ra,8(sp)
    80000e84:	e022                	sd	s0,0(sp)
    80000e86:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e88:	00001097          	auipc	ra,0x1
    80000e8c:	bce080e7          	jalr	-1074(ra) # 80001a56 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e90:	00008717          	auipc	a4,0x8
    80000e94:	18870713          	addi	a4,a4,392 # 80009018 <started>
  if(cpuid() == 0){
    80000e98:	c139                	beqz	a0,80000ede <main+0x5e>
    while(started == 0)
    80000e9a:	431c                	lw	a5,0(a4)
    80000e9c:	2781                	sext.w	a5,a5
    80000e9e:	dff5                	beqz	a5,80000e9a <main+0x1a>
      ;
    __sync_synchronize();
    80000ea0:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000ea4:	00001097          	auipc	ra,0x1
    80000ea8:	bb2080e7          	jalr	-1102(ra) # 80001a56 <cpuid>
    80000eac:	85aa                	mv	a1,a0
    80000eae:	00007517          	auipc	a0,0x7
    80000eb2:	20a50513          	addi	a0,a0,522 # 800080b8 <digits+0x78>
    80000eb6:	fffff097          	auipc	ra,0xfffff
    80000eba:	6c4080e7          	jalr	1732(ra) # 8000057a <printf>
    kvminithart();    // turn on paging
    80000ebe:	00000097          	auipc	ra,0x0
    80000ec2:	0d8080e7          	jalr	216(ra) # 80000f96 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ec6:	00002097          	auipc	ra,0x2
    80000eca:	b30080e7          	jalr	-1232(ra) # 800029f6 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ece:	00005097          	auipc	ra,0x5
    80000ed2:	182080e7          	jalr	386(ra) # 80006050 <plicinithart>
  }

  scheduler();        
    80000ed6:	00001097          	auipc	ra,0x1
    80000eda:	13c080e7          	jalr	316(ra) # 80002012 <scheduler>
    consoleinit();
    80000ede:	fffff097          	auipc	ra,0xfffff
    80000ee2:	564080e7          	jalr	1380(ra) # 80000442 <consoleinit>
    printfinit();
    80000ee6:	00000097          	auipc	ra,0x0
    80000eea:	87a080e7          	jalr	-1926(ra) # 80000760 <printfinit>
    printf("\n");
    80000eee:	00007517          	auipc	a0,0x7
    80000ef2:	1da50513          	addi	a0,a0,474 # 800080c8 <digits+0x88>
    80000ef6:	fffff097          	auipc	ra,0xfffff
    80000efa:	684080e7          	jalr	1668(ra) # 8000057a <printf>
    printf("xv6 kernel is booting\n");
    80000efe:	00007517          	auipc	a0,0x7
    80000f02:	1a250513          	addi	a0,a0,418 # 800080a0 <digits+0x60>
    80000f06:	fffff097          	auipc	ra,0xfffff
    80000f0a:	674080e7          	jalr	1652(ra) # 8000057a <printf>
    printf("\n");
    80000f0e:	00007517          	auipc	a0,0x7
    80000f12:	1ba50513          	addi	a0,a0,442 # 800080c8 <digits+0x88>
    80000f16:	fffff097          	auipc	ra,0xfffff
    80000f1a:	664080e7          	jalr	1636(ra) # 8000057a <printf>
    kinit();         // physical page allocator
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	b88080e7          	jalr	-1144(ra) # 80000aa6 <kinit>
    kvminit();       // create kernel page table
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	310080e7          	jalr	784(ra) # 80001236 <kvminit>
    kvminithart();   // turn on paging
    80000f2e:	00000097          	auipc	ra,0x0
    80000f32:	068080e7          	jalr	104(ra) # 80000f96 <kvminithart>
    procinit();      // process table
    80000f36:	00001097          	auipc	ra,0x1
    80000f3a:	a56080e7          	jalr	-1450(ra) # 8000198c <procinit>
    trapinit();      // trap vectors
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	a90080e7          	jalr	-1392(ra) # 800029ce <trapinit>
    trapinithart();  // install kernel trap vector
    80000f46:	00002097          	auipc	ra,0x2
    80000f4a:	ab0080e7          	jalr	-1360(ra) # 800029f6 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	0ec080e7          	jalr	236(ra) # 8000603a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f56:	00005097          	auipc	ra,0x5
    80000f5a:	0fa080e7          	jalr	250(ra) # 80006050 <plicinithart>
    binit();         // buffer cache
    80000f5e:	00002097          	auipc	ra,0x2
    80000f62:	2da080e7          	jalr	730(ra) # 80003238 <binit>
    iinit();         // inode cache
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	96a080e7          	jalr	-1686(ra) # 800038d0 <iinit>
    fileinit();      // file table
    80000f6e:	00004097          	auipc	ra,0x4
    80000f72:	914080e7          	jalr	-1772(ra) # 80004882 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f76:	00005097          	auipc	ra,0x5
    80000f7a:	1fc080e7          	jalr	508(ra) # 80006172 <virtio_disk_init>
    userinit();      // first user process
    80000f7e:	00001097          	auipc	ra,0x1
    80000f82:	dde080e7          	jalr	-546(ra) # 80001d5c <userinit>
    __sync_synchronize();
    80000f86:	0ff0000f          	fence
    started = 1;
    80000f8a:	4785                	li	a5,1
    80000f8c:	00008717          	auipc	a4,0x8
    80000f90:	08f72623          	sw	a5,140(a4) # 80009018 <started>
    80000f94:	b789                	j	80000ed6 <main+0x56>

0000000080000f96 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f96:	1141                	addi	sp,sp,-16
    80000f98:	e422                	sd	s0,8(sp)
    80000f9a:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000f9c:	00008797          	auipc	a5,0x8
    80000fa0:	0847b783          	ld	a5,132(a5) # 80009020 <kernel_pagetable>
    80000fa4:	83b1                	srli	a5,a5,0xc
    80000fa6:	577d                	li	a4,-1
    80000fa8:	177e                	slli	a4,a4,0x3f
    80000faa:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fac:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fb0:	12000073          	sfence.vma
  sfence_vma();
}
    80000fb4:	6422                	ld	s0,8(sp)
    80000fb6:	0141                	addi	sp,sp,16
    80000fb8:	8082                	ret

0000000080000fba <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fba:	7139                	addi	sp,sp,-64
    80000fbc:	fc06                	sd	ra,56(sp)
    80000fbe:	f822                	sd	s0,48(sp)
    80000fc0:	f426                	sd	s1,40(sp)
    80000fc2:	f04a                	sd	s2,32(sp)
    80000fc4:	ec4e                	sd	s3,24(sp)
    80000fc6:	e852                	sd	s4,16(sp)
    80000fc8:	e456                	sd	s5,8(sp)
    80000fca:	e05a                	sd	s6,0(sp)
    80000fcc:	0080                	addi	s0,sp,64
    80000fce:	84aa                	mv	s1,a0
    80000fd0:	89ae                	mv	s3,a1
    80000fd2:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd4:	57fd                	li	a5,-1
    80000fd6:	83e9                	srli	a5,a5,0x1a
    80000fd8:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fda:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fdc:	04b7f263          	bgeu	a5,a1,80001020 <walk+0x66>
    panic("walk");
    80000fe0:	00007517          	auipc	a0,0x7
    80000fe4:	0f050513          	addi	a0,a0,240 # 800080d0 <digits+0x90>
    80000fe8:	fffff097          	auipc	ra,0xfffff
    80000fec:	548080e7          	jalr	1352(ra) # 80000530 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000ff0:	060a8663          	beqz	s5,8000105c <walk+0xa2>
    80000ff4:	00000097          	auipc	ra,0x0
    80000ff8:	aee080e7          	jalr	-1298(ra) # 80000ae2 <kalloc>
    80000ffc:	84aa                	mv	s1,a0
    80000ffe:	c529                	beqz	a0,80001048 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001000:	6605                	lui	a2,0x1
    80001002:	4581                	li	a1,0
    80001004:	00000097          	auipc	ra,0x0
    80001008:	cca080e7          	jalr	-822(ra) # 80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000100c:	00c4d793          	srli	a5,s1,0xc
    80001010:	07aa                	slli	a5,a5,0xa
    80001012:	0017e793          	ori	a5,a5,1
    80001016:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    8000101a:	3a5d                	addiw	s4,s4,-9
    8000101c:	036a0063          	beq	s4,s6,8000103c <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001020:	0149d933          	srl	s2,s3,s4
    80001024:	1ff97913          	andi	s2,s2,511
    80001028:	090e                	slli	s2,s2,0x3
    8000102a:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000102c:	00093483          	ld	s1,0(s2)
    80001030:	0014f793          	andi	a5,s1,1
    80001034:	dfd5                	beqz	a5,80000ff0 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001036:	80a9                	srli	s1,s1,0xa
    80001038:	04b2                	slli	s1,s1,0xc
    8000103a:	b7c5                	j	8000101a <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000103c:	00c9d513          	srli	a0,s3,0xc
    80001040:	1ff57513          	andi	a0,a0,511
    80001044:	050e                	slli	a0,a0,0x3
    80001046:	9526                	add	a0,a0,s1
}
    80001048:	70e2                	ld	ra,56(sp)
    8000104a:	7442                	ld	s0,48(sp)
    8000104c:	74a2                	ld	s1,40(sp)
    8000104e:	7902                	ld	s2,32(sp)
    80001050:	69e2                	ld	s3,24(sp)
    80001052:	6a42                	ld	s4,16(sp)
    80001054:	6aa2                	ld	s5,8(sp)
    80001056:	6b02                	ld	s6,0(sp)
    80001058:	6121                	addi	sp,sp,64
    8000105a:	8082                	ret
        return 0;
    8000105c:	4501                	li	a0,0
    8000105e:	b7ed                	j	80001048 <walk+0x8e>

0000000080001060 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001060:	57fd                	li	a5,-1
    80001062:	83e9                	srli	a5,a5,0x1a
    80001064:	00b7f463          	bgeu	a5,a1,8000106c <walkaddr+0xc>
    return 0;
    80001068:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000106a:	8082                	ret
{
    8000106c:	1141                	addi	sp,sp,-16
    8000106e:	e406                	sd	ra,8(sp)
    80001070:	e022                	sd	s0,0(sp)
    80001072:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001074:	4601                	li	a2,0
    80001076:	00000097          	auipc	ra,0x0
    8000107a:	f44080e7          	jalr	-188(ra) # 80000fba <walk>
  if(pte == 0)
    8000107e:	c105                	beqz	a0,8000109e <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001080:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001082:	0117f693          	andi	a3,a5,17
    80001086:	4745                	li	a4,17
    return 0;
    80001088:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000108a:	00e68663          	beq	a3,a4,80001096 <walkaddr+0x36>
}
    8000108e:	60a2                	ld	ra,8(sp)
    80001090:	6402                	ld	s0,0(sp)
    80001092:	0141                	addi	sp,sp,16
    80001094:	8082                	ret
  pa = PTE2PA(*pte);
    80001096:	00a7d513          	srli	a0,a5,0xa
    8000109a:	0532                	slli	a0,a0,0xc
  return pa;
    8000109c:	bfcd                	j	8000108e <walkaddr+0x2e>
    return 0;
    8000109e:	4501                	li	a0,0
    800010a0:	b7fd                	j	8000108e <walkaddr+0x2e>

00000000800010a2 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010a2:	715d                	addi	sp,sp,-80
    800010a4:	e486                	sd	ra,72(sp)
    800010a6:	e0a2                	sd	s0,64(sp)
    800010a8:	fc26                	sd	s1,56(sp)
    800010aa:	f84a                	sd	s2,48(sp)
    800010ac:	f44e                	sd	s3,40(sp)
    800010ae:	f052                	sd	s4,32(sp)
    800010b0:	ec56                	sd	s5,24(sp)
    800010b2:	e85a                	sd	s6,16(sp)
    800010b4:	e45e                	sd	s7,8(sp)
    800010b6:	0880                	addi	s0,sp,80
    800010b8:	8aaa                	mv	s5,a0
    800010ba:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800010bc:	777d                	lui	a4,0xfffff
    800010be:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c2:	167d                	addi	a2,a2,-1
    800010c4:	00b609b3          	add	s3,a2,a1
    800010c8:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010cc:	893e                	mv	s2,a5
    800010ce:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d2:	6b85                	lui	s7,0x1
    800010d4:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d8:	4605                	li	a2,1
    800010da:	85ca                	mv	a1,s2
    800010dc:	8556                	mv	a0,s5
    800010de:	00000097          	auipc	ra,0x0
    800010e2:	edc080e7          	jalr	-292(ra) # 80000fba <walk>
    800010e6:	c51d                	beqz	a0,80001114 <mappages+0x72>
    if(*pte & PTE_V)
    800010e8:	611c                	ld	a5,0(a0)
    800010ea:	8b85                	andi	a5,a5,1
    800010ec:	ef81                	bnez	a5,80001104 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ee:	80b1                	srli	s1,s1,0xc
    800010f0:	04aa                	slli	s1,s1,0xa
    800010f2:	0164e4b3          	or	s1,s1,s6
    800010f6:	0014e493          	ori	s1,s1,1
    800010fa:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fc:	03390863          	beq	s2,s3,8000112c <mappages+0x8a>
    a += PGSIZE;
    80001100:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001102:	bfc9                	j	800010d4 <mappages+0x32>
      panic("remap");
    80001104:	00007517          	auipc	a0,0x7
    80001108:	fd450513          	addi	a0,a0,-44 # 800080d8 <digits+0x98>
    8000110c:	fffff097          	auipc	ra,0xfffff
    80001110:	424080e7          	jalr	1060(ra) # 80000530 <panic>
      return -1;
    80001114:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001116:	60a6                	ld	ra,72(sp)
    80001118:	6406                	ld	s0,64(sp)
    8000111a:	74e2                	ld	s1,56(sp)
    8000111c:	7942                	ld	s2,48(sp)
    8000111e:	79a2                	ld	s3,40(sp)
    80001120:	7a02                	ld	s4,32(sp)
    80001122:	6ae2                	ld	s5,24(sp)
    80001124:	6b42                	ld	s6,16(sp)
    80001126:	6ba2                	ld	s7,8(sp)
    80001128:	6161                	addi	sp,sp,80
    8000112a:	8082                	ret
  return 0;
    8000112c:	4501                	li	a0,0
    8000112e:	b7e5                	j	80001116 <mappages+0x74>

0000000080001130 <kvmmap>:
{
    80001130:	1141                	addi	sp,sp,-16
    80001132:	e406                	sd	ra,8(sp)
    80001134:	e022                	sd	s0,0(sp)
    80001136:	0800                	addi	s0,sp,16
    80001138:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000113a:	86b2                	mv	a3,a2
    8000113c:	863e                	mv	a2,a5
    8000113e:	00000097          	auipc	ra,0x0
    80001142:	f64080e7          	jalr	-156(ra) # 800010a2 <mappages>
    80001146:	e509                	bnez	a0,80001150 <kvmmap+0x20>
}
    80001148:	60a2                	ld	ra,8(sp)
    8000114a:	6402                	ld	s0,0(sp)
    8000114c:	0141                	addi	sp,sp,16
    8000114e:	8082                	ret
    panic("kvmmap");
    80001150:	00007517          	auipc	a0,0x7
    80001154:	f9050513          	addi	a0,a0,-112 # 800080e0 <digits+0xa0>
    80001158:	fffff097          	auipc	ra,0xfffff
    8000115c:	3d8080e7          	jalr	984(ra) # 80000530 <panic>

0000000080001160 <kvmmake>:
{
    80001160:	1101                	addi	sp,sp,-32
    80001162:	ec06                	sd	ra,24(sp)
    80001164:	e822                	sd	s0,16(sp)
    80001166:	e426                	sd	s1,8(sp)
    80001168:	e04a                	sd	s2,0(sp)
    8000116a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000116c:	00000097          	auipc	ra,0x0
    80001170:	976080e7          	jalr	-1674(ra) # 80000ae2 <kalloc>
    80001174:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001176:	6605                	lui	a2,0x1
    80001178:	4581                	li	a1,0
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	b54080e7          	jalr	-1196(ra) # 80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001182:	4719                	li	a4,6
    80001184:	6685                	lui	a3,0x1
    80001186:	10000637          	lui	a2,0x10000
    8000118a:	100005b7          	lui	a1,0x10000
    8000118e:	8526                	mv	a0,s1
    80001190:	00000097          	auipc	ra,0x0
    80001194:	fa0080e7          	jalr	-96(ra) # 80001130 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001198:	4719                	li	a4,6
    8000119a:	6685                	lui	a3,0x1
    8000119c:	10001637          	lui	a2,0x10001
    800011a0:	100015b7          	lui	a1,0x10001
    800011a4:	8526                	mv	a0,s1
    800011a6:	00000097          	auipc	ra,0x0
    800011aa:	f8a080e7          	jalr	-118(ra) # 80001130 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011ae:	4719                	li	a4,6
    800011b0:	004006b7          	lui	a3,0x400
    800011b4:	0c000637          	lui	a2,0xc000
    800011b8:	0c0005b7          	lui	a1,0xc000
    800011bc:	8526                	mv	a0,s1
    800011be:	00000097          	auipc	ra,0x0
    800011c2:	f72080e7          	jalr	-142(ra) # 80001130 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011c6:	00007917          	auipc	s2,0x7
    800011ca:	e3a90913          	addi	s2,s2,-454 # 80008000 <etext>
    800011ce:	4729                	li	a4,10
    800011d0:	80007697          	auipc	a3,0x80007
    800011d4:	e3068693          	addi	a3,a3,-464 # 8000 <_entry-0x7fff8000>
    800011d8:	4605                	li	a2,1
    800011da:	067e                	slli	a2,a2,0x1f
    800011dc:	85b2                	mv	a1,a2
    800011de:	8526                	mv	a0,s1
    800011e0:	00000097          	auipc	ra,0x0
    800011e4:	f50080e7          	jalr	-176(ra) # 80001130 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011e8:	4719                	li	a4,6
    800011ea:	46c5                	li	a3,17
    800011ec:	06ee                	slli	a3,a3,0x1b
    800011ee:	412686b3          	sub	a3,a3,s2
    800011f2:	864a                	mv	a2,s2
    800011f4:	85ca                	mv	a1,s2
    800011f6:	8526                	mv	a0,s1
    800011f8:	00000097          	auipc	ra,0x0
    800011fc:	f38080e7          	jalr	-200(ra) # 80001130 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001200:	4729                	li	a4,10
    80001202:	6685                	lui	a3,0x1
    80001204:	00006617          	auipc	a2,0x6
    80001208:	dfc60613          	addi	a2,a2,-516 # 80007000 <_trampoline>
    8000120c:	040005b7          	lui	a1,0x4000
    80001210:	15fd                	addi	a1,a1,-1
    80001212:	05b2                	slli	a1,a1,0xc
    80001214:	8526                	mv	a0,s1
    80001216:	00000097          	auipc	ra,0x0
    8000121a:	f1a080e7          	jalr	-230(ra) # 80001130 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000121e:	8526                	mv	a0,s1
    80001220:	00000097          	auipc	ra,0x0
    80001224:	6d6080e7          	jalr	1750(ra) # 800018f6 <proc_mapstacks>
}
    80001228:	8526                	mv	a0,s1
    8000122a:	60e2                	ld	ra,24(sp)
    8000122c:	6442                	ld	s0,16(sp)
    8000122e:	64a2                	ld	s1,8(sp)
    80001230:	6902                	ld	s2,0(sp)
    80001232:	6105                	addi	sp,sp,32
    80001234:	8082                	ret

0000000080001236 <kvminit>:
{
    80001236:	1141                	addi	sp,sp,-16
    80001238:	e406                	sd	ra,8(sp)
    8000123a:	e022                	sd	s0,0(sp)
    8000123c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000123e:	00000097          	auipc	ra,0x0
    80001242:	f22080e7          	jalr	-222(ra) # 80001160 <kvmmake>
    80001246:	00008797          	auipc	a5,0x8
    8000124a:	dca7bd23          	sd	a0,-550(a5) # 80009020 <kernel_pagetable>
}
    8000124e:	60a2                	ld	ra,8(sp)
    80001250:	6402                	ld	s0,0(sp)
    80001252:	0141                	addi	sp,sp,16
    80001254:	8082                	ret

0000000080001256 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001256:	715d                	addi	sp,sp,-80
    80001258:	e486                	sd	ra,72(sp)
    8000125a:	e0a2                	sd	s0,64(sp)
    8000125c:	fc26                	sd	s1,56(sp)
    8000125e:	f84a                	sd	s2,48(sp)
    80001260:	f44e                	sd	s3,40(sp)
    80001262:	f052                	sd	s4,32(sp)
    80001264:	ec56                	sd	s5,24(sp)
    80001266:	e85a                	sd	s6,16(sp)
    80001268:	e45e                	sd	s7,8(sp)
    8000126a:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000126c:	03459793          	slli	a5,a1,0x34
    80001270:	e795                	bnez	a5,8000129c <uvmunmap+0x46>
    80001272:	8a2a                	mv	s4,a0
    80001274:	892e                	mv	s2,a1
    80001276:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001278:	0632                	slli	a2,a2,0xc
    8000127a:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000127e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001280:	6b05                	lui	s6,0x1
    80001282:	0735e863          	bltu	a1,s3,800012f2 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001286:	60a6                	ld	ra,72(sp)
    80001288:	6406                	ld	s0,64(sp)
    8000128a:	74e2                	ld	s1,56(sp)
    8000128c:	7942                	ld	s2,48(sp)
    8000128e:	79a2                	ld	s3,40(sp)
    80001290:	7a02                	ld	s4,32(sp)
    80001292:	6ae2                	ld	s5,24(sp)
    80001294:	6b42                	ld	s6,16(sp)
    80001296:	6ba2                	ld	s7,8(sp)
    80001298:	6161                	addi	sp,sp,80
    8000129a:	8082                	ret
    panic("uvmunmap: not aligned");
    8000129c:	00007517          	auipc	a0,0x7
    800012a0:	e4c50513          	addi	a0,a0,-436 # 800080e8 <digits+0xa8>
    800012a4:	fffff097          	auipc	ra,0xfffff
    800012a8:	28c080e7          	jalr	652(ra) # 80000530 <panic>
      panic("uvmunmap: walk");
    800012ac:	00007517          	auipc	a0,0x7
    800012b0:	e5450513          	addi	a0,a0,-428 # 80008100 <digits+0xc0>
    800012b4:	fffff097          	auipc	ra,0xfffff
    800012b8:	27c080e7          	jalr	636(ra) # 80000530 <panic>
      panic("uvmunmap: not mapped");
    800012bc:	00007517          	auipc	a0,0x7
    800012c0:	e5450513          	addi	a0,a0,-428 # 80008110 <digits+0xd0>
    800012c4:	fffff097          	auipc	ra,0xfffff
    800012c8:	26c080e7          	jalr	620(ra) # 80000530 <panic>
      panic("uvmunmap: not a leaf");
    800012cc:	00007517          	auipc	a0,0x7
    800012d0:	e5c50513          	addi	a0,a0,-420 # 80008128 <digits+0xe8>
    800012d4:	fffff097          	auipc	ra,0xfffff
    800012d8:	25c080e7          	jalr	604(ra) # 80000530 <panic>
      uint64 pa = PTE2PA(*pte);
    800012dc:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800012de:	0532                	slli	a0,a0,0xc
    800012e0:	fffff097          	auipc	ra,0xfffff
    800012e4:	706080e7          	jalr	1798(ra) # 800009e6 <kfree>
    *pte = 0;
    800012e8:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ec:	995a                	add	s2,s2,s6
    800012ee:	f9397ce3          	bgeu	s2,s3,80001286 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f2:	4601                	li	a2,0
    800012f4:	85ca                	mv	a1,s2
    800012f6:	8552                	mv	a0,s4
    800012f8:	00000097          	auipc	ra,0x0
    800012fc:	cc2080e7          	jalr	-830(ra) # 80000fba <walk>
    80001300:	84aa                	mv	s1,a0
    80001302:	d54d                	beqz	a0,800012ac <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001304:	6108                	ld	a0,0(a0)
    80001306:	00157793          	andi	a5,a0,1
    8000130a:	dbcd                	beqz	a5,800012bc <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130c:	3ff57793          	andi	a5,a0,1023
    80001310:	fb778ee3          	beq	a5,s7,800012cc <uvmunmap+0x76>
    if(do_free){
    80001314:	fc0a8ae3          	beqz	s5,800012e8 <uvmunmap+0x92>
    80001318:	b7d1                	j	800012dc <uvmunmap+0x86>

000000008000131a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000131a:	1101                	addi	sp,sp,-32
    8000131c:	ec06                	sd	ra,24(sp)
    8000131e:	e822                	sd	s0,16(sp)
    80001320:	e426                	sd	s1,8(sp)
    80001322:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001324:	fffff097          	auipc	ra,0xfffff
    80001328:	7be080e7          	jalr	1982(ra) # 80000ae2 <kalloc>
    8000132c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000132e:	c519                	beqz	a0,8000133c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001330:	6605                	lui	a2,0x1
    80001332:	4581                	li	a1,0
    80001334:	00000097          	auipc	ra,0x0
    80001338:	99a080e7          	jalr	-1638(ra) # 80000cce <memset>
  return pagetable;
}
    8000133c:	8526                	mv	a0,s1
    8000133e:	60e2                	ld	ra,24(sp)
    80001340:	6442                	ld	s0,16(sp)
    80001342:	64a2                	ld	s1,8(sp)
    80001344:	6105                	addi	sp,sp,32
    80001346:	8082                	ret

0000000080001348 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001348:	7179                	addi	sp,sp,-48
    8000134a:	f406                	sd	ra,40(sp)
    8000134c:	f022                	sd	s0,32(sp)
    8000134e:	ec26                	sd	s1,24(sp)
    80001350:	e84a                	sd	s2,16(sp)
    80001352:	e44e                	sd	s3,8(sp)
    80001354:	e052                	sd	s4,0(sp)
    80001356:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001358:	6785                	lui	a5,0x1
    8000135a:	04f67863          	bgeu	a2,a5,800013aa <uvminit+0x62>
    8000135e:	8a2a                	mv	s4,a0
    80001360:	89ae                	mv	s3,a1
    80001362:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80001364:	fffff097          	auipc	ra,0xfffff
    80001368:	77e080e7          	jalr	1918(ra) # 80000ae2 <kalloc>
    8000136c:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000136e:	6605                	lui	a2,0x1
    80001370:	4581                	li	a1,0
    80001372:	00000097          	auipc	ra,0x0
    80001376:	95c080e7          	jalr	-1700(ra) # 80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000137a:	4779                	li	a4,30
    8000137c:	86ca                	mv	a3,s2
    8000137e:	6605                	lui	a2,0x1
    80001380:	4581                	li	a1,0
    80001382:	8552                	mv	a0,s4
    80001384:	00000097          	auipc	ra,0x0
    80001388:	d1e080e7          	jalr	-738(ra) # 800010a2 <mappages>
  memmove(mem, src, sz);
    8000138c:	8626                	mv	a2,s1
    8000138e:	85ce                	mv	a1,s3
    80001390:	854a                	mv	a0,s2
    80001392:	00000097          	auipc	ra,0x0
    80001396:	99c080e7          	jalr	-1636(ra) # 80000d2e <memmove>
}
    8000139a:	70a2                	ld	ra,40(sp)
    8000139c:	7402                	ld	s0,32(sp)
    8000139e:	64e2                	ld	s1,24(sp)
    800013a0:	6942                	ld	s2,16(sp)
    800013a2:	69a2                	ld	s3,8(sp)
    800013a4:	6a02                	ld	s4,0(sp)
    800013a6:	6145                	addi	sp,sp,48
    800013a8:	8082                	ret
    panic("inituvm: more than a page");
    800013aa:	00007517          	auipc	a0,0x7
    800013ae:	d9650513          	addi	a0,a0,-618 # 80008140 <digits+0x100>
    800013b2:	fffff097          	auipc	ra,0xfffff
    800013b6:	17e080e7          	jalr	382(ra) # 80000530 <panic>

00000000800013ba <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013ba:	1101                	addi	sp,sp,-32
    800013bc:	ec06                	sd	ra,24(sp)
    800013be:	e822                	sd	s0,16(sp)
    800013c0:	e426                	sd	s1,8(sp)
    800013c2:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013c4:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013c6:	00b67d63          	bgeu	a2,a1,800013e0 <uvmdealloc+0x26>
    800013ca:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013cc:	6785                	lui	a5,0x1
    800013ce:	17fd                	addi	a5,a5,-1
    800013d0:	00f60733          	add	a4,a2,a5
    800013d4:	767d                	lui	a2,0xfffff
    800013d6:	8f71                	and	a4,a4,a2
    800013d8:	97ae                	add	a5,a5,a1
    800013da:	8ff1                	and	a5,a5,a2
    800013dc:	00f76863          	bltu	a4,a5,800013ec <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e0:	8526                	mv	a0,s1
    800013e2:	60e2                	ld	ra,24(sp)
    800013e4:	6442                	ld	s0,16(sp)
    800013e6:	64a2                	ld	s1,8(sp)
    800013e8:	6105                	addi	sp,sp,32
    800013ea:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013ec:	8f99                	sub	a5,a5,a4
    800013ee:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f0:	4685                	li	a3,1
    800013f2:	0007861b          	sext.w	a2,a5
    800013f6:	85ba                	mv	a1,a4
    800013f8:	00000097          	auipc	ra,0x0
    800013fc:	e5e080e7          	jalr	-418(ra) # 80001256 <uvmunmap>
    80001400:	b7c5                	j	800013e0 <uvmdealloc+0x26>

0000000080001402 <uvmalloc>:
  if(newsz < oldsz)
    80001402:	0ab66163          	bltu	a2,a1,800014a4 <uvmalloc+0xa2>
{
    80001406:	7139                	addi	sp,sp,-64
    80001408:	fc06                	sd	ra,56(sp)
    8000140a:	f822                	sd	s0,48(sp)
    8000140c:	f426                	sd	s1,40(sp)
    8000140e:	f04a                	sd	s2,32(sp)
    80001410:	ec4e                	sd	s3,24(sp)
    80001412:	e852                	sd	s4,16(sp)
    80001414:	e456                	sd	s5,8(sp)
    80001416:	0080                	addi	s0,sp,64
    80001418:	8aaa                	mv	s5,a0
    8000141a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000141c:	6985                	lui	s3,0x1
    8000141e:	19fd                	addi	s3,s3,-1
    80001420:	95ce                	add	a1,a1,s3
    80001422:	79fd                	lui	s3,0xfffff
    80001424:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001428:	08c9f063          	bgeu	s3,a2,800014a8 <uvmalloc+0xa6>
    8000142c:	894e                	mv	s2,s3
    mem = kalloc();
    8000142e:	fffff097          	auipc	ra,0xfffff
    80001432:	6b4080e7          	jalr	1716(ra) # 80000ae2 <kalloc>
    80001436:	84aa                	mv	s1,a0
    if(mem == 0){
    80001438:	c51d                	beqz	a0,80001466 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    8000143a:	6605                	lui	a2,0x1
    8000143c:	4581                	li	a1,0
    8000143e:	00000097          	auipc	ra,0x0
    80001442:	890080e7          	jalr	-1904(ra) # 80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80001446:	4779                	li	a4,30
    80001448:	86a6                	mv	a3,s1
    8000144a:	6605                	lui	a2,0x1
    8000144c:	85ca                	mv	a1,s2
    8000144e:	8556                	mv	a0,s5
    80001450:	00000097          	auipc	ra,0x0
    80001454:	c52080e7          	jalr	-942(ra) # 800010a2 <mappages>
    80001458:	e905                	bnez	a0,80001488 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000145a:	6785                	lui	a5,0x1
    8000145c:	993e                	add	s2,s2,a5
    8000145e:	fd4968e3          	bltu	s2,s4,8000142e <uvmalloc+0x2c>
  return newsz;
    80001462:	8552                	mv	a0,s4
    80001464:	a809                	j	80001476 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80001466:	864e                	mv	a2,s3
    80001468:	85ca                	mv	a1,s2
    8000146a:	8556                	mv	a0,s5
    8000146c:	00000097          	auipc	ra,0x0
    80001470:	f4e080e7          	jalr	-178(ra) # 800013ba <uvmdealloc>
      return 0;
    80001474:	4501                	li	a0,0
}
    80001476:	70e2                	ld	ra,56(sp)
    80001478:	7442                	ld	s0,48(sp)
    8000147a:	74a2                	ld	s1,40(sp)
    8000147c:	7902                	ld	s2,32(sp)
    8000147e:	69e2                	ld	s3,24(sp)
    80001480:	6a42                	ld	s4,16(sp)
    80001482:	6aa2                	ld	s5,8(sp)
    80001484:	6121                	addi	sp,sp,64
    80001486:	8082                	ret
      kfree(mem);
    80001488:	8526                	mv	a0,s1
    8000148a:	fffff097          	auipc	ra,0xfffff
    8000148e:	55c080e7          	jalr	1372(ra) # 800009e6 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001492:	864e                	mv	a2,s3
    80001494:	85ca                	mv	a1,s2
    80001496:	8556                	mv	a0,s5
    80001498:	00000097          	auipc	ra,0x0
    8000149c:	f22080e7          	jalr	-222(ra) # 800013ba <uvmdealloc>
      return 0;
    800014a0:	4501                	li	a0,0
    800014a2:	bfd1                	j	80001476 <uvmalloc+0x74>
    return oldsz;
    800014a4:	852e                	mv	a0,a1
}
    800014a6:	8082                	ret
  return newsz;
    800014a8:	8532                	mv	a0,a2
    800014aa:	b7f1                	j	80001476 <uvmalloc+0x74>

00000000800014ac <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014ac:	7179                	addi	sp,sp,-48
    800014ae:	f406                	sd	ra,40(sp)
    800014b0:	f022                	sd	s0,32(sp)
    800014b2:	ec26                	sd	s1,24(sp)
    800014b4:	e84a                	sd	s2,16(sp)
    800014b6:	e44e                	sd	s3,8(sp)
    800014b8:	e052                	sd	s4,0(sp)
    800014ba:	1800                	addi	s0,sp,48
    800014bc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014be:	84aa                	mv	s1,a0
    800014c0:	6905                	lui	s2,0x1
    800014c2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014c4:	4985                	li	s3,1
    800014c6:	a821                	j	800014de <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014c8:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800014ca:	0532                	slli	a0,a0,0xc
    800014cc:	00000097          	auipc	ra,0x0
    800014d0:	fe0080e7          	jalr	-32(ra) # 800014ac <freewalk>
      pagetable[i] = 0;
    800014d4:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014d8:	04a1                	addi	s1,s1,8
    800014da:	03248163          	beq	s1,s2,800014fc <freewalk+0x50>
    pte_t pte = pagetable[i];
    800014de:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014e0:	00f57793          	andi	a5,a0,15
    800014e4:	ff3782e3          	beq	a5,s3,800014c8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014e8:	8905                	andi	a0,a0,1
    800014ea:	d57d                	beqz	a0,800014d8 <freewalk+0x2c>
      panic("freewalk: leaf");
    800014ec:	00007517          	auipc	a0,0x7
    800014f0:	c7450513          	addi	a0,a0,-908 # 80008160 <digits+0x120>
    800014f4:	fffff097          	auipc	ra,0xfffff
    800014f8:	03c080e7          	jalr	60(ra) # 80000530 <panic>
    }
  }
  kfree((void*)pagetable);
    800014fc:	8552                	mv	a0,s4
    800014fe:	fffff097          	auipc	ra,0xfffff
    80001502:	4e8080e7          	jalr	1256(ra) # 800009e6 <kfree>
}
    80001506:	70a2                	ld	ra,40(sp)
    80001508:	7402                	ld	s0,32(sp)
    8000150a:	64e2                	ld	s1,24(sp)
    8000150c:	6942                	ld	s2,16(sp)
    8000150e:	69a2                	ld	s3,8(sp)
    80001510:	6a02                	ld	s4,0(sp)
    80001512:	6145                	addi	sp,sp,48
    80001514:	8082                	ret

0000000080001516 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001516:	1101                	addi	sp,sp,-32
    80001518:	ec06                	sd	ra,24(sp)
    8000151a:	e822                	sd	s0,16(sp)
    8000151c:	e426                	sd	s1,8(sp)
    8000151e:	1000                	addi	s0,sp,32
    80001520:	84aa                	mv	s1,a0
  if(sz > 0)
    80001522:	e999                	bnez	a1,80001538 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001524:	8526                	mv	a0,s1
    80001526:	00000097          	auipc	ra,0x0
    8000152a:	f86080e7          	jalr	-122(ra) # 800014ac <freewalk>
}
    8000152e:	60e2                	ld	ra,24(sp)
    80001530:	6442                	ld	s0,16(sp)
    80001532:	64a2                	ld	s1,8(sp)
    80001534:	6105                	addi	sp,sp,32
    80001536:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001538:	6605                	lui	a2,0x1
    8000153a:	167d                	addi	a2,a2,-1
    8000153c:	962e                	add	a2,a2,a1
    8000153e:	4685                	li	a3,1
    80001540:	8231                	srli	a2,a2,0xc
    80001542:	4581                	li	a1,0
    80001544:	00000097          	auipc	ra,0x0
    80001548:	d12080e7          	jalr	-750(ra) # 80001256 <uvmunmap>
    8000154c:	bfe1                	j	80001524 <uvmfree+0xe>

000000008000154e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000154e:	c679                	beqz	a2,8000161c <uvmcopy+0xce>
{
    80001550:	715d                	addi	sp,sp,-80
    80001552:	e486                	sd	ra,72(sp)
    80001554:	e0a2                	sd	s0,64(sp)
    80001556:	fc26                	sd	s1,56(sp)
    80001558:	f84a                	sd	s2,48(sp)
    8000155a:	f44e                	sd	s3,40(sp)
    8000155c:	f052                	sd	s4,32(sp)
    8000155e:	ec56                	sd	s5,24(sp)
    80001560:	e85a                	sd	s6,16(sp)
    80001562:	e45e                	sd	s7,8(sp)
    80001564:	0880                	addi	s0,sp,80
    80001566:	8b2a                	mv	s6,a0
    80001568:	8aae                	mv	s5,a1
    8000156a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000156c:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000156e:	4601                	li	a2,0
    80001570:	85ce                	mv	a1,s3
    80001572:	855a                	mv	a0,s6
    80001574:	00000097          	auipc	ra,0x0
    80001578:	a46080e7          	jalr	-1466(ra) # 80000fba <walk>
    8000157c:	c531                	beqz	a0,800015c8 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000157e:	6118                	ld	a4,0(a0)
    80001580:	00177793          	andi	a5,a4,1
    80001584:	cbb1                	beqz	a5,800015d8 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001586:	00a75593          	srli	a1,a4,0xa
    8000158a:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000158e:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80001592:	fffff097          	auipc	ra,0xfffff
    80001596:	550080e7          	jalr	1360(ra) # 80000ae2 <kalloc>
    8000159a:	892a                	mv	s2,a0
    8000159c:	c939                	beqz	a0,800015f2 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000159e:	6605                	lui	a2,0x1
    800015a0:	85de                	mv	a1,s7
    800015a2:	fffff097          	auipc	ra,0xfffff
    800015a6:	78c080e7          	jalr	1932(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015aa:	8726                	mv	a4,s1
    800015ac:	86ca                	mv	a3,s2
    800015ae:	6605                	lui	a2,0x1
    800015b0:	85ce                	mv	a1,s3
    800015b2:	8556                	mv	a0,s5
    800015b4:	00000097          	auipc	ra,0x0
    800015b8:	aee080e7          	jalr	-1298(ra) # 800010a2 <mappages>
    800015bc:	e515                	bnez	a0,800015e8 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015be:	6785                	lui	a5,0x1
    800015c0:	99be                	add	s3,s3,a5
    800015c2:	fb49e6e3          	bltu	s3,s4,8000156e <uvmcopy+0x20>
    800015c6:	a081                	j	80001606 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015c8:	00007517          	auipc	a0,0x7
    800015cc:	ba850513          	addi	a0,a0,-1112 # 80008170 <digits+0x130>
    800015d0:	fffff097          	auipc	ra,0xfffff
    800015d4:	f60080e7          	jalr	-160(ra) # 80000530 <panic>
      panic("uvmcopy: page not present");
    800015d8:	00007517          	auipc	a0,0x7
    800015dc:	bb850513          	addi	a0,a0,-1096 # 80008190 <digits+0x150>
    800015e0:	fffff097          	auipc	ra,0xfffff
    800015e4:	f50080e7          	jalr	-176(ra) # 80000530 <panic>
      kfree(mem);
    800015e8:	854a                	mv	a0,s2
    800015ea:	fffff097          	auipc	ra,0xfffff
    800015ee:	3fc080e7          	jalr	1020(ra) # 800009e6 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800015f2:	4685                	li	a3,1
    800015f4:	00c9d613          	srli	a2,s3,0xc
    800015f8:	4581                	li	a1,0
    800015fa:	8556                	mv	a0,s5
    800015fc:	00000097          	auipc	ra,0x0
    80001600:	c5a080e7          	jalr	-934(ra) # 80001256 <uvmunmap>
  return -1;
    80001604:	557d                	li	a0,-1
}
    80001606:	60a6                	ld	ra,72(sp)
    80001608:	6406                	ld	s0,64(sp)
    8000160a:	74e2                	ld	s1,56(sp)
    8000160c:	7942                	ld	s2,48(sp)
    8000160e:	79a2                	ld	s3,40(sp)
    80001610:	7a02                	ld	s4,32(sp)
    80001612:	6ae2                	ld	s5,24(sp)
    80001614:	6b42                	ld	s6,16(sp)
    80001616:	6ba2                	ld	s7,8(sp)
    80001618:	6161                	addi	sp,sp,80
    8000161a:	8082                	ret
  return 0;
    8000161c:	4501                	li	a0,0
}
    8000161e:	8082                	ret

0000000080001620 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001620:	1141                	addi	sp,sp,-16
    80001622:	e406                	sd	ra,8(sp)
    80001624:	e022                	sd	s0,0(sp)
    80001626:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001628:	4601                	li	a2,0
    8000162a:	00000097          	auipc	ra,0x0
    8000162e:	990080e7          	jalr	-1648(ra) # 80000fba <walk>
  if(pte == 0)
    80001632:	c901                	beqz	a0,80001642 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001634:	611c                	ld	a5,0(a0)
    80001636:	9bbd                	andi	a5,a5,-17
    80001638:	e11c                	sd	a5,0(a0)
}
    8000163a:	60a2                	ld	ra,8(sp)
    8000163c:	6402                	ld	s0,0(sp)
    8000163e:	0141                	addi	sp,sp,16
    80001640:	8082                	ret
    panic("uvmclear");
    80001642:	00007517          	auipc	a0,0x7
    80001646:	b6e50513          	addi	a0,a0,-1170 # 800081b0 <digits+0x170>
    8000164a:	fffff097          	auipc	ra,0xfffff
    8000164e:	ee6080e7          	jalr	-282(ra) # 80000530 <panic>

0000000080001652 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001652:	c6bd                	beqz	a3,800016c0 <copyout+0x6e>
{
    80001654:	715d                	addi	sp,sp,-80
    80001656:	e486                	sd	ra,72(sp)
    80001658:	e0a2                	sd	s0,64(sp)
    8000165a:	fc26                	sd	s1,56(sp)
    8000165c:	f84a                	sd	s2,48(sp)
    8000165e:	f44e                	sd	s3,40(sp)
    80001660:	f052                	sd	s4,32(sp)
    80001662:	ec56                	sd	s5,24(sp)
    80001664:	e85a                	sd	s6,16(sp)
    80001666:	e45e                	sd	s7,8(sp)
    80001668:	e062                	sd	s8,0(sp)
    8000166a:	0880                	addi	s0,sp,80
    8000166c:	8b2a                	mv	s6,a0
    8000166e:	8c2e                	mv	s8,a1
    80001670:	8a32                	mv	s4,a2
    80001672:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001674:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001676:	6a85                	lui	s5,0x1
    80001678:	a015                	j	8000169c <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000167a:	9562                	add	a0,a0,s8
    8000167c:	0004861b          	sext.w	a2,s1
    80001680:	85d2                	mv	a1,s4
    80001682:	41250533          	sub	a0,a0,s2
    80001686:	fffff097          	auipc	ra,0xfffff
    8000168a:	6a8080e7          	jalr	1704(ra) # 80000d2e <memmove>

    len -= n;
    8000168e:	409989b3          	sub	s3,s3,s1
    src += n;
    80001692:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001694:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001698:	02098263          	beqz	s3,800016bc <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000169c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016a0:	85ca                	mv	a1,s2
    800016a2:	855a                	mv	a0,s6
    800016a4:	00000097          	auipc	ra,0x0
    800016a8:	9bc080e7          	jalr	-1604(ra) # 80001060 <walkaddr>
    if(pa0 == 0)
    800016ac:	cd01                	beqz	a0,800016c4 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016ae:	418904b3          	sub	s1,s2,s8
    800016b2:	94d6                	add	s1,s1,s5
    if(n > len)
    800016b4:	fc99f3e3          	bgeu	s3,s1,8000167a <copyout+0x28>
    800016b8:	84ce                	mv	s1,s3
    800016ba:	b7c1                	j	8000167a <copyout+0x28>
  }
  return 0;
    800016bc:	4501                	li	a0,0
    800016be:	a021                	j	800016c6 <copyout+0x74>
    800016c0:	4501                	li	a0,0
}
    800016c2:	8082                	ret
      return -1;
    800016c4:	557d                	li	a0,-1
}
    800016c6:	60a6                	ld	ra,72(sp)
    800016c8:	6406                	ld	s0,64(sp)
    800016ca:	74e2                	ld	s1,56(sp)
    800016cc:	7942                	ld	s2,48(sp)
    800016ce:	79a2                	ld	s3,40(sp)
    800016d0:	7a02                	ld	s4,32(sp)
    800016d2:	6ae2                	ld	s5,24(sp)
    800016d4:	6b42                	ld	s6,16(sp)
    800016d6:	6ba2                	ld	s7,8(sp)
    800016d8:	6c02                	ld	s8,0(sp)
    800016da:	6161                	addi	sp,sp,80
    800016dc:	8082                	ret

00000000800016de <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016de:	c6bd                	beqz	a3,8000174c <copyin+0x6e>
{
    800016e0:	715d                	addi	sp,sp,-80
    800016e2:	e486                	sd	ra,72(sp)
    800016e4:	e0a2                	sd	s0,64(sp)
    800016e6:	fc26                	sd	s1,56(sp)
    800016e8:	f84a                	sd	s2,48(sp)
    800016ea:	f44e                	sd	s3,40(sp)
    800016ec:	f052                	sd	s4,32(sp)
    800016ee:	ec56                	sd	s5,24(sp)
    800016f0:	e85a                	sd	s6,16(sp)
    800016f2:	e45e                	sd	s7,8(sp)
    800016f4:	e062                	sd	s8,0(sp)
    800016f6:	0880                	addi	s0,sp,80
    800016f8:	8b2a                	mv	s6,a0
    800016fa:	8a2e                	mv	s4,a1
    800016fc:	8c32                	mv	s8,a2
    800016fe:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001700:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001702:	6a85                	lui	s5,0x1
    80001704:	a015                	j	80001728 <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001706:	9562                	add	a0,a0,s8
    80001708:	0004861b          	sext.w	a2,s1
    8000170c:	412505b3          	sub	a1,a0,s2
    80001710:	8552                	mv	a0,s4
    80001712:	fffff097          	auipc	ra,0xfffff
    80001716:	61c080e7          	jalr	1564(ra) # 80000d2e <memmove>

    len -= n;
    8000171a:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000171e:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001720:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001724:	02098263          	beqz	s3,80001748 <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80001728:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000172c:	85ca                	mv	a1,s2
    8000172e:	855a                	mv	a0,s6
    80001730:	00000097          	auipc	ra,0x0
    80001734:	930080e7          	jalr	-1744(ra) # 80001060 <walkaddr>
    if(pa0 == 0)
    80001738:	cd01                	beqz	a0,80001750 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    8000173a:	418904b3          	sub	s1,s2,s8
    8000173e:	94d6                	add	s1,s1,s5
    if(n > len)
    80001740:	fc99f3e3          	bgeu	s3,s1,80001706 <copyin+0x28>
    80001744:	84ce                	mv	s1,s3
    80001746:	b7c1                	j	80001706 <copyin+0x28>
  }
  return 0;
    80001748:	4501                	li	a0,0
    8000174a:	a021                	j	80001752 <copyin+0x74>
    8000174c:	4501                	li	a0,0
}
    8000174e:	8082                	ret
      return -1;
    80001750:	557d                	li	a0,-1
}
    80001752:	60a6                	ld	ra,72(sp)
    80001754:	6406                	ld	s0,64(sp)
    80001756:	74e2                	ld	s1,56(sp)
    80001758:	7942                	ld	s2,48(sp)
    8000175a:	79a2                	ld	s3,40(sp)
    8000175c:	7a02                	ld	s4,32(sp)
    8000175e:	6ae2                	ld	s5,24(sp)
    80001760:	6b42                	ld	s6,16(sp)
    80001762:	6ba2                	ld	s7,8(sp)
    80001764:	6c02                	ld	s8,0(sp)
    80001766:	6161                	addi	sp,sp,80
    80001768:	8082                	ret

000000008000176a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000176a:	c6c5                	beqz	a3,80001812 <copyinstr+0xa8>
{
    8000176c:	715d                	addi	sp,sp,-80
    8000176e:	e486                	sd	ra,72(sp)
    80001770:	e0a2                	sd	s0,64(sp)
    80001772:	fc26                	sd	s1,56(sp)
    80001774:	f84a                	sd	s2,48(sp)
    80001776:	f44e                	sd	s3,40(sp)
    80001778:	f052                	sd	s4,32(sp)
    8000177a:	ec56                	sd	s5,24(sp)
    8000177c:	e85a                	sd	s6,16(sp)
    8000177e:	e45e                	sd	s7,8(sp)
    80001780:	0880                	addi	s0,sp,80
    80001782:	8a2a                	mv	s4,a0
    80001784:	8b2e                	mv	s6,a1
    80001786:	8bb2                	mv	s7,a2
    80001788:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    8000178a:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000178c:	6985                	lui	s3,0x1
    8000178e:	a035                	j	800017ba <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001790:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001794:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001796:	0017b793          	seqz	a5,a5
    8000179a:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000179e:	60a6                	ld	ra,72(sp)
    800017a0:	6406                	ld	s0,64(sp)
    800017a2:	74e2                	ld	s1,56(sp)
    800017a4:	7942                	ld	s2,48(sp)
    800017a6:	79a2                	ld	s3,40(sp)
    800017a8:	7a02                	ld	s4,32(sp)
    800017aa:	6ae2                	ld	s5,24(sp)
    800017ac:	6b42                	ld	s6,16(sp)
    800017ae:	6ba2                	ld	s7,8(sp)
    800017b0:	6161                	addi	sp,sp,80
    800017b2:	8082                	ret
    srcva = va0 + PGSIZE;
    800017b4:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017b8:	c8a9                	beqz	s1,8000180a <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    800017ba:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017be:	85ca                	mv	a1,s2
    800017c0:	8552                	mv	a0,s4
    800017c2:	00000097          	auipc	ra,0x0
    800017c6:	89e080e7          	jalr	-1890(ra) # 80001060 <walkaddr>
    if(pa0 == 0)
    800017ca:	c131                	beqz	a0,8000180e <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017cc:	41790833          	sub	a6,s2,s7
    800017d0:	984e                	add	a6,a6,s3
    if(n > max)
    800017d2:	0104f363          	bgeu	s1,a6,800017d8 <copyinstr+0x6e>
    800017d6:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017d8:	955e                	add	a0,a0,s7
    800017da:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017de:	fc080be3          	beqz	a6,800017b4 <copyinstr+0x4a>
    800017e2:	985a                	add	a6,a6,s6
    800017e4:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017e6:	41650633          	sub	a2,a0,s6
    800017ea:	14fd                	addi	s1,s1,-1
    800017ec:	9b26                	add	s6,s6,s1
    800017ee:	00f60733          	add	a4,a2,a5
    800017f2:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd9000>
    800017f6:	df49                	beqz	a4,80001790 <copyinstr+0x26>
        *dst = *p;
    800017f8:	00e78023          	sb	a4,0(a5)
      --max;
    800017fc:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80001800:	0785                	addi	a5,a5,1
    while(n > 0){
    80001802:	ff0796e3          	bne	a5,a6,800017ee <copyinstr+0x84>
      dst++;
    80001806:	8b42                	mv	s6,a6
    80001808:	b775                	j	800017b4 <copyinstr+0x4a>
    8000180a:	4781                	li	a5,0
    8000180c:	b769                	j	80001796 <copyinstr+0x2c>
      return -1;
    8000180e:	557d                	li	a0,-1
    80001810:	b779                	j	8000179e <copyinstr+0x34>
  int got_null = 0;
    80001812:	4781                	li	a5,0
  if(got_null){
    80001814:	0017b793          	seqz	a5,a5
    80001818:	40f00533          	neg	a0,a5
}
    8000181c:	8082                	ret

000000008000181e <enqueue>:


//add queue in startIndex. StartIndex could be NPROC or NPROC+1 or NPROC+2
//which correspon to first queue, second queue, third queue.
void
enqueue(int queue[], int item, int startIndex){
    8000181e:	1141                	addi	sp,sp,-16
    80001820:	e422                	sd	s0,8(sp)
    80001822:	0800                	addi	s0,sp,16
    //if there is duplicate just return
    //checking all three queue
    int temp = NPROC;
    80001824:	04000793          	li	a5,64
    while(queue[temp]!=-1){
    80001828:	577d                	li	a4,-1
    8000182a:	078a                	slli	a5,a5,0x2
    8000182c:	97aa                	add	a5,a5,a0
    8000182e:	439c                	lw	a5,0(a5)
    80001830:	00e78763          	beq	a5,a4,8000183e <enqueue+0x20>
      if(queue[temp]==item){
    80001834:	feb79be3          	bne	a5,a1,8000182a <enqueue+0xc>
      }
      index = queue[index];
    }
    queue[index] = item;

}
    80001838:	6422                	ld	s0,8(sp)
    8000183a:	0141                	addi	sp,sp,16
    8000183c:	8082                	ret
    temp = temp+1;
    8000183e:	04100793          	li	a5,65
    while(queue[temp]!=-1){
    80001842:	577d                	li	a4,-1
    80001844:	078a                	slli	a5,a5,0x2
    80001846:	97aa                	add	a5,a5,a0
    80001848:	439c                	lw	a5,0(a5)
    8000184a:	00e78563          	beq	a5,a4,80001854 <enqueue+0x36>
     if(queue[temp]==item){
    8000184e:	feb79be3          	bne	a5,a1,80001844 <enqueue+0x26>
    80001852:	b7dd                	j	80001838 <enqueue+0x1a>
    temp = temp+2;
    80001854:	04200793          	li	a5,66
    while(queue[temp]!=-1){
    80001858:	577d                	li	a4,-1
    8000185a:	078a                	slli	a5,a5,0x2
    8000185c:	97aa                	add	a5,a5,a0
    8000185e:	439c                	lw	a5,0(a5)
    80001860:	00e78563          	beq	a5,a4,8000186a <enqueue+0x4c>
      if(queue[temp]==item){
    80001864:	feb79be3          	bne	a5,a1,8000185a <enqueue+0x3c>
    80001868:	bfc1                	j	80001838 <enqueue+0x1a>
    while(queue[index]!=-1){
    8000186a:	577d                	li	a4,-1
    8000186c:	060a                	slli	a2,a2,0x2
    8000186e:	00c507b3          	add	a5,a0,a2
    80001872:	4390                	lw	a2,0(a5)
    80001874:	00e60563          	beq	a2,a4,8000187e <enqueue+0x60>
      if(queue[index]==item){
    80001878:	feb61ae3          	bne	a2,a1,8000186c <enqueue+0x4e>
    8000187c:	bf75                	j	80001838 <enqueue+0x1a>
    queue[index] = item;
    8000187e:	c38c                	sw	a1,0(a5)
    80001880:	bf65                	j	80001838 <enqueue+0x1a>

0000000080001882 <dequeue>:


//delete queue in index
//it also return the queue value which have deleted.
int
dequeue(int queue[],int targetIndex){
    80001882:	1141                	addi	sp,sp,-16
    80001884:	e422                	sd	s0,8(sp)
    80001886:	0800                	addi	s0,sp,16
    80001888:	872a                	mv	a4,a0
  //find where the targetIndex is
  int index = NPROC;
  int count = 0;
  int result = -1;
  int after = -1;
  while(index != targetIndex){
    8000188a:	04000793          	li	a5,64
    8000188e:	04f58663          	beq	a1,a5,800018da <dequeue+0x58>
  int count = 0;
    80001892:	4681                	li	a3,0
        result = queue[index];
        after = queue[result];
        queue[result] = -1;
        queue[targetIndex] = after;
      }
      if(queue[index]==-1){
    80001894:	567d                	li	a2,-1
          count++;
          index = NPROC + count;
          if(index >NPROC + 2)
    80001896:	04200813          	li	a6,66
    8000189a:	a025                	j	800018c2 <dequeue+0x40>
      if(queue[index]==-1){
    8000189c:	00c58a63          	beq	a1,a2,800018b0 <dequeue+0x2e>
        result = queue[index];
    800018a0:	852e                	mv	a0,a1
      if(queue[index]==-1){
    800018a2:	87ae                	mv	a5,a1
      }
      else{
        index = queue[index];
      }
  }
  if(result == -1){
    800018a4:	56fd                	li	a3,-1
    800018a6:	02d50b63          	beq	a0,a3,800018dc <dequeue+0x5a>
    after = queue[result];
    queue[result] = -1;
    queue[targetIndex] = after;
  }
  return result;
}
    800018aa:	6422                	ld	s0,8(sp)
    800018ac:	0141                	addi	sp,sp,16
    800018ae:	8082                	ret
          count++;
    800018b0:	0016851b          	addiw	a0,a3,1
          index = NPROC + count;
    800018b4:	0416879b          	addiw	a5,a3,65
          if(index >NPROC + 2)
    800018b8:	00f84f63          	blt	a6,a5,800018d6 <dequeue+0x54>
  while(index != targetIndex){
    800018bc:	00f58b63          	beq	a1,a5,800018d2 <dequeue+0x50>
          count++;
    800018c0:	86aa                	mv	a3,a0
      if(queue[index]==targetIndex){
    800018c2:	078a                	slli	a5,a5,0x2
    800018c4:	97ba                	add	a5,a5,a4
    800018c6:	439c                	lw	a5,0(a5)
    800018c8:	fcb78ae3          	beq	a5,a1,8000189c <dequeue+0x1a>
      if(queue[index]==-1){
    800018cc:	fec79be3          	bne	a5,a2,800018c2 <dequeue+0x40>
    800018d0:	b7c5                	j	800018b0 <dequeue+0x2e>
    800018d2:	557d                	li	a0,-1
    800018d4:	bfc1                	j	800018a4 <dequeue+0x22>
    800018d6:	557d                	li	a0,-1
    800018d8:	b7f1                	j	800018a4 <dequeue+0x22>
  int index = NPROC;
    800018da:	87ae                	mv	a5,a1
    result = queue[index];
    800018dc:	078a                	slli	a5,a5,0x2
    800018de:	97ba                	add	a5,a5,a4
    800018e0:	4388                	lw	a0,0(a5)
    after = queue[result];
    800018e2:	00251793          	slli	a5,a0,0x2
    800018e6:	97ba                	add	a5,a5,a4
    800018e8:	4394                	lw	a3,0(a5)
    queue[result] = -1;
    800018ea:	567d                	li	a2,-1
    800018ec:	c390                	sw	a2,0(a5)
    queue[targetIndex] = after;
    800018ee:	058a                	slli	a1,a1,0x2
    800018f0:	95ba                	add	a1,a1,a4
    800018f2:	c194                	sw	a3,0(a1)
  return result;
    800018f4:	bf5d                	j	800018aa <dequeue+0x28>

00000000800018f6 <proc_mapstacks>:

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl) {
    800018f6:	7139                	addi	sp,sp,-64
    800018f8:	fc06                	sd	ra,56(sp)
    800018fa:	f822                	sd	s0,48(sp)
    800018fc:	f426                	sd	s1,40(sp)
    800018fe:	f04a                	sd	s2,32(sp)
    80001900:	ec4e                	sd	s3,24(sp)
    80001902:	e852                	sd	s4,16(sp)
    80001904:	e456                	sd	s5,8(sp)
    80001906:	e05a                	sd	s6,0(sp)
    80001908:	0080                	addi	s0,sp,64
    8000190a:	89aa                	mv	s3,a0
  
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000190c:	00010497          	auipc	s1,0x10
    80001910:	ed448493          	addi	s1,s1,-300 # 800117e0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001914:	8b26                	mv	s6,s1
    80001916:	00006a97          	auipc	s5,0x6
    8000191a:	6eaa8a93          	addi	s5,s5,1770 # 80008000 <etext>
    8000191e:	04000937          	lui	s2,0x4000
    80001922:	197d                	addi	s2,s2,-1
    80001924:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001926:	00016a17          	auipc	s4,0x16
    8000192a:	8baa0a13          	addi	s4,s4,-1862 # 800171e0 <tickslock>
    char *pa = kalloc();
    8000192e:	fffff097          	auipc	ra,0xfffff
    80001932:	1b4080e7          	jalr	436(ra) # 80000ae2 <kalloc>
    80001936:	862a                	mv	a2,a0
    if(pa == 0)
    80001938:	c131                	beqz	a0,8000197c <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000193a:	416485b3          	sub	a1,s1,s6
    8000193e:	858d                	srai	a1,a1,0x3
    80001940:	000ab783          	ld	a5,0(s5)
    80001944:	02f585b3          	mul	a1,a1,a5
    80001948:	2585                	addiw	a1,a1,1
    8000194a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000194e:	4719                	li	a4,6
    80001950:	6685                	lui	a3,0x1
    80001952:	40b905b3          	sub	a1,s2,a1
    80001956:	854e                	mv	a0,s3
    80001958:	fffff097          	auipc	ra,0xfffff
    8000195c:	7d8080e7          	jalr	2008(ra) # 80001130 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001960:	16848493          	addi	s1,s1,360
    80001964:	fd4495e3          	bne	s1,s4,8000192e <proc_mapstacks+0x38>
  }
}
    80001968:	70e2                	ld	ra,56(sp)
    8000196a:	7442                	ld	s0,48(sp)
    8000196c:	74a2                	ld	s1,40(sp)
    8000196e:	7902                	ld	s2,32(sp)
    80001970:	69e2                	ld	s3,24(sp)
    80001972:	6a42                	ld	s4,16(sp)
    80001974:	6aa2                	ld	s5,8(sp)
    80001976:	6b02                	ld	s6,0(sp)
    80001978:	6121                	addi	sp,sp,64
    8000197a:	8082                	ret
      panic("kalloc");
    8000197c:	00007517          	auipc	a0,0x7
    80001980:	84450513          	addi	a0,a0,-1980 # 800081c0 <digits+0x180>
    80001984:	fffff097          	auipc	ra,0xfffff
    80001988:	bac080e7          	jalr	-1108(ra) # 80000530 <panic>

000000008000198c <procinit>:

// initialize the proc table at boot time.
void
procinit(void)
{
    8000198c:	7139                	addi	sp,sp,-64
    8000198e:	fc06                	sd	ra,56(sp)
    80001990:	f822                	sd	s0,48(sp)
    80001992:	f426                	sd	s1,40(sp)
    80001994:	f04a                	sd	s2,32(sp)
    80001996:	ec4e                	sd	s3,24(sp)
    80001998:	e852                	sd	s4,16(sp)
    8000199a:	e456                	sd	s5,8(sp)
    8000199c:	e05a                	sd	s6,0(sp)
    8000199e:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800019a0:	00007597          	auipc	a1,0x7
    800019a4:	82858593          	addi	a1,a1,-2008 # 800081c8 <digits+0x188>
    800019a8:	00010517          	auipc	a0,0x10
    800019ac:	8f850513          	addi	a0,a0,-1800 # 800112a0 <pid_lock>
    800019b0:	fffff097          	auipc	ra,0xfffff
    800019b4:	192080e7          	jalr	402(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    800019b8:	00007597          	auipc	a1,0x7
    800019bc:	81858593          	addi	a1,a1,-2024 # 800081d0 <digits+0x190>
    800019c0:	00010517          	auipc	a0,0x10
    800019c4:	8f850513          	addi	a0,a0,-1800 # 800112b8 <wait_lock>
    800019c8:	fffff097          	auipc	ra,0xfffff
    800019cc:	17a080e7          	jalr	378(ra) # 80000b42 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    800019d0:	00010497          	auipc	s1,0x10
    800019d4:	e1048493          	addi	s1,s1,-496 # 800117e0 <proc>
      initlock(&p->lock, "proc");
    800019d8:	00007b17          	auipc	s6,0x7
    800019dc:	808b0b13          	addi	s6,s6,-2040 # 800081e0 <digits+0x1a0>
      p->kstack = KSTACK((int) (p - proc));
    800019e0:	8aa6                	mv	s5,s1
    800019e2:	00006a17          	auipc	s4,0x6
    800019e6:	61ea0a13          	addi	s4,s4,1566 # 80008000 <etext>
    800019ea:	04000937          	lui	s2,0x4000
    800019ee:	197d                	addi	s2,s2,-1
    800019f0:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800019f2:	00015997          	auipc	s3,0x15
    800019f6:	7ee98993          	addi	s3,s3,2030 # 800171e0 <tickslock>
      initlock(&p->lock, "proc");
    800019fa:	85da                	mv	a1,s6
    800019fc:	8526                	mv	a0,s1
    800019fe:	fffff097          	auipc	ra,0xfffff
    80001a02:	144080e7          	jalr	324(ra) # 80000b42 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80001a06:	415487b3          	sub	a5,s1,s5
    80001a0a:	878d                	srai	a5,a5,0x3
    80001a0c:	000a3703          	ld	a4,0(s4)
    80001a10:	02e787b3          	mul	a5,a5,a4
    80001a14:	2785                	addiw	a5,a5,1
    80001a16:	00d7979b          	slliw	a5,a5,0xd
    80001a1a:	40f907b3          	sub	a5,s2,a5
    80001a1e:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001a20:	16848493          	addi	s1,s1,360
    80001a24:	fd349be3          	bne	s1,s3,800019fa <procinit+0x6e>
    80001a28:	00010797          	auipc	a5,0x10
    80001a2c:	8a878793          	addi	a5,a5,-1880 # 800112d0 <qtable>
    80001a30:	00010697          	auipc	a3,0x10
    80001a34:	9ac68693          	addi	a3,a3,-1620 # 800113dc <qtable+0x10c>
  }
  for(int i=0;i<NPROC+3;i++){
    qtable[i] = -1;
    80001a38:	577d                	li	a4,-1
    80001a3a:	c398                	sw	a4,0(a5)
  for(int i=0;i<NPROC+3;i++){
    80001a3c:	0791                	addi	a5,a5,4
    80001a3e:	fed79ee3          	bne	a5,a3,80001a3a <procinit+0xae>
  }
}
    80001a42:	70e2                	ld	ra,56(sp)
    80001a44:	7442                	ld	s0,48(sp)
    80001a46:	74a2                	ld	s1,40(sp)
    80001a48:	7902                	ld	s2,32(sp)
    80001a4a:	69e2                	ld	s3,24(sp)
    80001a4c:	6a42                	ld	s4,16(sp)
    80001a4e:	6aa2                	ld	s5,8(sp)
    80001a50:	6b02                	ld	s6,0(sp)
    80001a52:	6121                	addi	sp,sp,64
    80001a54:	8082                	ret

0000000080001a56 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001a56:	1141                	addi	sp,sp,-16
    80001a58:	e422                	sd	s0,8(sp)
    80001a5a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a5c:	8512                	mv	a0,tp
  
  int id = r_tp();
  return id;
}
    80001a5e:	2501                	sext.w	a0,a0
    80001a60:	6422                	ld	s0,8(sp)
    80001a62:	0141                	addi	sp,sp,16
    80001a64:	8082                	ret

0000000080001a66 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void) {
    80001a66:	1141                	addi	sp,sp,-16
    80001a68:	e422                	sd	s0,8(sp)
    80001a6a:	0800                	addi	s0,sp,16
    80001a6c:	8792                	mv	a5,tp
  
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001a6e:	2781                	sext.w	a5,a5
    80001a70:	079e                	slli	a5,a5,0x7
  return c;
}
    80001a72:	00010517          	auipc	a0,0x10
    80001a76:	96e50513          	addi	a0,a0,-1682 # 800113e0 <cpus>
    80001a7a:	953e                	add	a0,a0,a5
    80001a7c:	6422                	ld	s0,8(sp)
    80001a7e:	0141                	addi	sp,sp,16
    80001a80:	8082                	ret

0000000080001a82 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void) {
    80001a82:	1101                	addi	sp,sp,-32
    80001a84:	ec06                	sd	ra,24(sp)
    80001a86:	e822                	sd	s0,16(sp)
    80001a88:	e426                	sd	s1,8(sp)
    80001a8a:	1000                	addi	s0,sp,32
  
  push_off();
    80001a8c:	fffff097          	auipc	ra,0xfffff
    80001a90:	0fa080e7          	jalr	250(ra) # 80000b86 <push_off>
    80001a94:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a96:	2781                	sext.w	a5,a5
    80001a98:	079e                	slli	a5,a5,0x7
    80001a9a:	00010717          	auipc	a4,0x10
    80001a9e:	80670713          	addi	a4,a4,-2042 # 800112a0 <pid_lock>
    80001aa2:	97ba                	add	a5,a5,a4
    80001aa4:	1407b483          	ld	s1,320(a5)
  pop_off();
    80001aa8:	fffff097          	auipc	ra,0xfffff
    80001aac:	17e080e7          	jalr	382(ra) # 80000c26 <pop_off>
  return p;
}
    80001ab0:	8526                	mv	a0,s1
    80001ab2:	60e2                	ld	ra,24(sp)
    80001ab4:	6442                	ld	s0,16(sp)
    80001ab6:	64a2                	ld	s1,8(sp)
    80001ab8:	6105                	addi	sp,sp,32
    80001aba:	8082                	ret

0000000080001abc <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001abc:	1141                	addi	sp,sp,-16
    80001abe:	e406                	sd	ra,8(sp)
    80001ac0:	e022                	sd	s0,0(sp)
    80001ac2:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001ac4:	00000097          	auipc	ra,0x0
    80001ac8:	fbe080e7          	jalr	-66(ra) # 80001a82 <myproc>
    80001acc:	fffff097          	auipc	ra,0xfffff
    80001ad0:	1ba080e7          	jalr	442(ra) # 80000c86 <release>

  if (first) {
    80001ad4:	00007797          	auipc	a5,0x7
    80001ad8:	d2c7a783          	lw	a5,-724(a5) # 80008800 <first.1734>
    80001adc:	eb89                	bnez	a5,80001aee <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001ade:	00001097          	auipc	ra,0x1
    80001ae2:	f30080e7          	jalr	-208(ra) # 80002a0e <usertrapret>
}
    80001ae6:	60a2                	ld	ra,8(sp)
    80001ae8:	6402                	ld	s0,0(sp)
    80001aea:	0141                	addi	sp,sp,16
    80001aec:	8082                	ret
    first = 0;
    80001aee:	00007797          	auipc	a5,0x7
    80001af2:	d007a923          	sw	zero,-750(a5) # 80008800 <first.1734>
    fsinit(ROOTDEV);
    80001af6:	4505                	li	a0,1
    80001af8:	00002097          	auipc	ra,0x2
    80001afc:	d58080e7          	jalr	-680(ra) # 80003850 <fsinit>
    80001b00:	bff9                	j	80001ade <forkret+0x22>

0000000080001b02 <allocpid>:
allocpid() {
    80001b02:	1101                	addi	sp,sp,-32
    80001b04:	ec06                	sd	ra,24(sp)
    80001b06:	e822                	sd	s0,16(sp)
    80001b08:	e426                	sd	s1,8(sp)
    80001b0a:	e04a                	sd	s2,0(sp)
    80001b0c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b0e:	0000f917          	auipc	s2,0xf
    80001b12:	79290913          	addi	s2,s2,1938 # 800112a0 <pid_lock>
    80001b16:	854a                	mv	a0,s2
    80001b18:	fffff097          	auipc	ra,0xfffff
    80001b1c:	0ba080e7          	jalr	186(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001b20:	00007797          	auipc	a5,0x7
    80001b24:	ce478793          	addi	a5,a5,-796 # 80008804 <nextpid>
    80001b28:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001b2a:	0014871b          	addiw	a4,s1,1
    80001b2e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001b30:	854a                	mv	a0,s2
    80001b32:	fffff097          	auipc	ra,0xfffff
    80001b36:	154080e7          	jalr	340(ra) # 80000c86 <release>
}
    80001b3a:	8526                	mv	a0,s1
    80001b3c:	60e2                	ld	ra,24(sp)
    80001b3e:	6442                	ld	s0,16(sp)
    80001b40:	64a2                	ld	s1,8(sp)
    80001b42:	6902                	ld	s2,0(sp)
    80001b44:	6105                	addi	sp,sp,32
    80001b46:	8082                	ret

0000000080001b48 <proc_pagetable>:
{
    80001b48:	1101                	addi	sp,sp,-32
    80001b4a:	ec06                	sd	ra,24(sp)
    80001b4c:	e822                	sd	s0,16(sp)
    80001b4e:	e426                	sd	s1,8(sp)
    80001b50:	e04a                	sd	s2,0(sp)
    80001b52:	1000                	addi	s0,sp,32
    80001b54:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001b56:	fffff097          	auipc	ra,0xfffff
    80001b5a:	7c4080e7          	jalr	1988(ra) # 8000131a <uvmcreate>
    80001b5e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b60:	c121                	beqz	a0,80001ba0 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b62:	4729                	li	a4,10
    80001b64:	00005697          	auipc	a3,0x5
    80001b68:	49c68693          	addi	a3,a3,1180 # 80007000 <_trampoline>
    80001b6c:	6605                	lui	a2,0x1
    80001b6e:	040005b7          	lui	a1,0x4000
    80001b72:	15fd                	addi	a1,a1,-1
    80001b74:	05b2                	slli	a1,a1,0xc
    80001b76:	fffff097          	auipc	ra,0xfffff
    80001b7a:	52c080e7          	jalr	1324(ra) # 800010a2 <mappages>
    80001b7e:	02054863          	bltz	a0,80001bae <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b82:	4719                	li	a4,6
    80001b84:	05893683          	ld	a3,88(s2)
    80001b88:	6605                	lui	a2,0x1
    80001b8a:	020005b7          	lui	a1,0x2000
    80001b8e:	15fd                	addi	a1,a1,-1
    80001b90:	05b6                	slli	a1,a1,0xd
    80001b92:	8526                	mv	a0,s1
    80001b94:	fffff097          	auipc	ra,0xfffff
    80001b98:	50e080e7          	jalr	1294(ra) # 800010a2 <mappages>
    80001b9c:	02054163          	bltz	a0,80001bbe <proc_pagetable+0x76>
}
    80001ba0:	8526                	mv	a0,s1
    80001ba2:	60e2                	ld	ra,24(sp)
    80001ba4:	6442                	ld	s0,16(sp)
    80001ba6:	64a2                	ld	s1,8(sp)
    80001ba8:	6902                	ld	s2,0(sp)
    80001baa:	6105                	addi	sp,sp,32
    80001bac:	8082                	ret
    uvmfree(pagetable, 0);
    80001bae:	4581                	li	a1,0
    80001bb0:	8526                	mv	a0,s1
    80001bb2:	00000097          	auipc	ra,0x0
    80001bb6:	964080e7          	jalr	-1692(ra) # 80001516 <uvmfree>
    return 0;
    80001bba:	4481                	li	s1,0
    80001bbc:	b7d5                	j	80001ba0 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bbe:	4681                	li	a3,0
    80001bc0:	4605                	li	a2,1
    80001bc2:	040005b7          	lui	a1,0x4000
    80001bc6:	15fd                	addi	a1,a1,-1
    80001bc8:	05b2                	slli	a1,a1,0xc
    80001bca:	8526                	mv	a0,s1
    80001bcc:	fffff097          	auipc	ra,0xfffff
    80001bd0:	68a080e7          	jalr	1674(ra) # 80001256 <uvmunmap>
    uvmfree(pagetable, 0);
    80001bd4:	4581                	li	a1,0
    80001bd6:	8526                	mv	a0,s1
    80001bd8:	00000097          	auipc	ra,0x0
    80001bdc:	93e080e7          	jalr	-1730(ra) # 80001516 <uvmfree>
    return 0;
    80001be0:	4481                	li	s1,0
    80001be2:	bf7d                	j	80001ba0 <proc_pagetable+0x58>

0000000080001be4 <proc_freepagetable>:
{
    80001be4:	1101                	addi	sp,sp,-32
    80001be6:	ec06                	sd	ra,24(sp)
    80001be8:	e822                	sd	s0,16(sp)
    80001bea:	e426                	sd	s1,8(sp)
    80001bec:	e04a                	sd	s2,0(sp)
    80001bee:	1000                	addi	s0,sp,32
    80001bf0:	84aa                	mv	s1,a0
    80001bf2:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001bf4:	4681                	li	a3,0
    80001bf6:	4605                	li	a2,1
    80001bf8:	040005b7          	lui	a1,0x4000
    80001bfc:	15fd                	addi	a1,a1,-1
    80001bfe:	05b2                	slli	a1,a1,0xc
    80001c00:	fffff097          	auipc	ra,0xfffff
    80001c04:	656080e7          	jalr	1622(ra) # 80001256 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c08:	4681                	li	a3,0
    80001c0a:	4605                	li	a2,1
    80001c0c:	020005b7          	lui	a1,0x2000
    80001c10:	15fd                	addi	a1,a1,-1
    80001c12:	05b6                	slli	a1,a1,0xd
    80001c14:	8526                	mv	a0,s1
    80001c16:	fffff097          	auipc	ra,0xfffff
    80001c1a:	640080e7          	jalr	1600(ra) # 80001256 <uvmunmap>
  uvmfree(pagetable, sz);
    80001c1e:	85ca                	mv	a1,s2
    80001c20:	8526                	mv	a0,s1
    80001c22:	00000097          	auipc	ra,0x0
    80001c26:	8f4080e7          	jalr	-1804(ra) # 80001516 <uvmfree>
}
    80001c2a:	60e2                	ld	ra,24(sp)
    80001c2c:	6442                	ld	s0,16(sp)
    80001c2e:	64a2                	ld	s1,8(sp)
    80001c30:	6902                	ld	s2,0(sp)
    80001c32:	6105                	addi	sp,sp,32
    80001c34:	8082                	ret

0000000080001c36 <freeproc>:
{
    80001c36:	1101                	addi	sp,sp,-32
    80001c38:	ec06                	sd	ra,24(sp)
    80001c3a:	e822                	sd	s0,16(sp)
    80001c3c:	e426                	sd	s1,8(sp)
    80001c3e:	1000                	addi	s0,sp,32
    80001c40:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001c42:	6d28                	ld	a0,88(a0)
    80001c44:	c509                	beqz	a0,80001c4e <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001c46:	fffff097          	auipc	ra,0xfffff
    80001c4a:	da0080e7          	jalr	-608(ra) # 800009e6 <kfree>
  p->trapframe = 0;
    80001c4e:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001c52:	68a8                	ld	a0,80(s1)
    80001c54:	c511                	beqz	a0,80001c60 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001c56:	64ac                	ld	a1,72(s1)
    80001c58:	00000097          	auipc	ra,0x0
    80001c5c:	f8c080e7          	jalr	-116(ra) # 80001be4 <proc_freepagetable>
  p->pagetable = 0;
    80001c60:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c64:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c68:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001c6c:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001c70:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c74:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001c78:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001c7c:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001c80:	0004ac23          	sw	zero,24(s1)
}
    80001c84:	60e2                	ld	ra,24(sp)
    80001c86:	6442                	ld	s0,16(sp)
    80001c88:	64a2                	ld	s1,8(sp)
    80001c8a:	6105                	addi	sp,sp,32
    80001c8c:	8082                	ret

0000000080001c8e <allocproc>:
{
    80001c8e:	1101                	addi	sp,sp,-32
    80001c90:	ec06                	sd	ra,24(sp)
    80001c92:	e822                	sd	s0,16(sp)
    80001c94:	e426                	sd	s1,8(sp)
    80001c96:	e04a                	sd	s2,0(sp)
    80001c98:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c9a:	00010497          	auipc	s1,0x10
    80001c9e:	b4648493          	addi	s1,s1,-1210 # 800117e0 <proc>
    80001ca2:	00015917          	auipc	s2,0x15
    80001ca6:	53e90913          	addi	s2,s2,1342 # 800171e0 <tickslock>
    acquire(&p->lock);
    80001caa:	8526                	mv	a0,s1
    80001cac:	fffff097          	auipc	ra,0xfffff
    80001cb0:	f26080e7          	jalr	-218(ra) # 80000bd2 <acquire>
    if(p->state == UNUSED) {
    80001cb4:	4c9c                	lw	a5,24(s1)
    80001cb6:	cf81                	beqz	a5,80001cce <allocproc+0x40>
      release(&p->lock);
    80001cb8:	8526                	mv	a0,s1
    80001cba:	fffff097          	auipc	ra,0xfffff
    80001cbe:	fcc080e7          	jalr	-52(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001cc2:	16848493          	addi	s1,s1,360
    80001cc6:	ff2492e3          	bne	s1,s2,80001caa <allocproc+0x1c>
  return 0;
    80001cca:	4481                	li	s1,0
    80001ccc:	a889                	j	80001d1e <allocproc+0x90>
  p->pid = allocpid();
    80001cce:	00000097          	auipc	ra,0x0
    80001cd2:	e34080e7          	jalr	-460(ra) # 80001b02 <allocpid>
    80001cd6:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001cd8:	4785                	li	a5,1
    80001cda:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001cdc:	fffff097          	auipc	ra,0xfffff
    80001ce0:	e06080e7          	jalr	-506(ra) # 80000ae2 <kalloc>
    80001ce4:	892a                	mv	s2,a0
    80001ce6:	eca8                	sd	a0,88(s1)
    80001ce8:	c131                	beqz	a0,80001d2c <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001cea:	8526                	mv	a0,s1
    80001cec:	00000097          	auipc	ra,0x0
    80001cf0:	e5c080e7          	jalr	-420(ra) # 80001b48 <proc_pagetable>
    80001cf4:	892a                	mv	s2,a0
    80001cf6:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001cf8:	c531                	beqz	a0,80001d44 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001cfa:	07000613          	li	a2,112
    80001cfe:	4581                	li	a1,0
    80001d00:	06048513          	addi	a0,s1,96
    80001d04:	fffff097          	auipc	ra,0xfffff
    80001d08:	fca080e7          	jalr	-54(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001d0c:	00000797          	auipc	a5,0x0
    80001d10:	db078793          	addi	a5,a5,-592 # 80001abc <forkret>
    80001d14:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d16:	60bc                	ld	a5,64(s1)
    80001d18:	6705                	lui	a4,0x1
    80001d1a:	97ba                	add	a5,a5,a4
    80001d1c:	f4bc                	sd	a5,104(s1)
}
    80001d1e:	8526                	mv	a0,s1
    80001d20:	60e2                	ld	ra,24(sp)
    80001d22:	6442                	ld	s0,16(sp)
    80001d24:	64a2                	ld	s1,8(sp)
    80001d26:	6902                	ld	s2,0(sp)
    80001d28:	6105                	addi	sp,sp,32
    80001d2a:	8082                	ret
    freeproc(p);
    80001d2c:	8526                	mv	a0,s1
    80001d2e:	00000097          	auipc	ra,0x0
    80001d32:	f08080e7          	jalr	-248(ra) # 80001c36 <freeproc>
    release(&p->lock);
    80001d36:	8526                	mv	a0,s1
    80001d38:	fffff097          	auipc	ra,0xfffff
    80001d3c:	f4e080e7          	jalr	-178(ra) # 80000c86 <release>
    return 0;
    80001d40:	84ca                	mv	s1,s2
    80001d42:	bff1                	j	80001d1e <allocproc+0x90>
    freeproc(p);
    80001d44:	8526                	mv	a0,s1
    80001d46:	00000097          	auipc	ra,0x0
    80001d4a:	ef0080e7          	jalr	-272(ra) # 80001c36 <freeproc>
    release(&p->lock);
    80001d4e:	8526                	mv	a0,s1
    80001d50:	fffff097          	auipc	ra,0xfffff
    80001d54:	f36080e7          	jalr	-202(ra) # 80000c86 <release>
    return 0;
    80001d58:	84ca                	mv	s1,s2
    80001d5a:	b7d1                	j	80001d1e <allocproc+0x90>

0000000080001d5c <userinit>:
{
    80001d5c:	1101                	addi	sp,sp,-32
    80001d5e:	ec06                	sd	ra,24(sp)
    80001d60:	e822                	sd	s0,16(sp)
    80001d62:	e426                	sd	s1,8(sp)
    80001d64:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d66:	00000097          	auipc	ra,0x0
    80001d6a:	f28080e7          	jalr	-216(ra) # 80001c8e <allocproc>
    80001d6e:	84aa                	mv	s1,a0
  initproc = p;
    80001d70:	00007797          	auipc	a5,0x7
    80001d74:	2aa7bc23          	sd	a0,696(a5) # 80009028 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d78:	03400613          	li	a2,52
    80001d7c:	00007597          	auipc	a1,0x7
    80001d80:	a9458593          	addi	a1,a1,-1388 # 80008810 <initcode>
    80001d84:	6928                	ld	a0,80(a0)
    80001d86:	fffff097          	auipc	ra,0xfffff
    80001d8a:	5c2080e7          	jalr	1474(ra) # 80001348 <uvminit>
  p->sz = PGSIZE;
    80001d8e:	6785                	lui	a5,0x1
    80001d90:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d92:	6cb8                	ld	a4,88(s1)
    80001d94:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d98:	6cb8                	ld	a4,88(s1)
    80001d9a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d9c:	4641                	li	a2,16
    80001d9e:	00006597          	auipc	a1,0x6
    80001da2:	44a58593          	addi	a1,a1,1098 # 800081e8 <digits+0x1a8>
    80001da6:	15848513          	addi	a0,s1,344
    80001daa:	fffff097          	auipc	ra,0xfffff
    80001dae:	07a080e7          	jalr	122(ra) # 80000e24 <safestrcpy>
  p->cwd = namei("/");
    80001db2:	00006517          	auipc	a0,0x6
    80001db6:	44650513          	addi	a0,a0,1094 # 800081f8 <digits+0x1b8>
    80001dba:	00002097          	auipc	ra,0x2
    80001dbe:	4c4080e7          	jalr	1220(ra) # 8000427e <namei>
    80001dc2:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001dc6:	478d                	li	a5,3
    80001dc8:	cc9c                	sw	a5,24(s1)
    if(temp == p)
    80001dca:	00010797          	auipc	a5,0x10
    80001dce:	a1678793          	addi	a5,a5,-1514 # 800117e0 <proc>
    80001dd2:	04f48463          	beq	s1,a5,80001e1a <userinit+0xbe>
  for(temp = proc ; temp < &proc[NPROC];temp++){
    80001dd6:	00010797          	auipc	a5,0x10
    80001dda:	b7278793          	addi	a5,a5,-1166 # 80011948 <proc+0x168>
    index++;
    80001dde:	4585                	li	a1,1
  for(temp = proc ; temp < &proc[NPROC];temp++){
    80001de0:	04000713          	li	a4,64
    if(temp == p)
    80001de4:	00f48763          	beq	s1,a5,80001df2 <userinit+0x96>
    index++;
    80001de8:	2585                	addiw	a1,a1,1
  for(temp = proc ; temp < &proc[NPROC];temp++){
    80001dea:	16878793          	addi	a5,a5,360
    80001dee:	fee59be3          	bne	a1,a4,80001de4 <userinit+0x88>
  enqueue(qtable,index,NPROC);
    80001df2:	04000613          	li	a2,64
    80001df6:	0000f517          	auipc	a0,0xf
    80001dfa:	4da50513          	addi	a0,a0,1242 # 800112d0 <qtable>
    80001dfe:	00000097          	auipc	ra,0x0
    80001e02:	a20080e7          	jalr	-1504(ra) # 8000181e <enqueue>
  release(&p->lock);
    80001e06:	8526                	mv	a0,s1
    80001e08:	fffff097          	auipc	ra,0xfffff
    80001e0c:	e7e080e7          	jalr	-386(ra) # 80000c86 <release>
}
    80001e10:	60e2                	ld	ra,24(sp)
    80001e12:	6442                	ld	s0,16(sp)
    80001e14:	64a2                	ld	s1,8(sp)
    80001e16:	6105                	addi	sp,sp,32
    80001e18:	8082                	ret
  int index=0;
    80001e1a:	4581                	li	a1,0
    80001e1c:	bfd9                	j	80001df2 <userinit+0x96>

0000000080001e1e <growproc>:
{
    80001e1e:	1101                	addi	sp,sp,-32
    80001e20:	ec06                	sd	ra,24(sp)
    80001e22:	e822                	sd	s0,16(sp)
    80001e24:	e426                	sd	s1,8(sp)
    80001e26:	e04a                	sd	s2,0(sp)
    80001e28:	1000                	addi	s0,sp,32
    80001e2a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001e2c:	00000097          	auipc	ra,0x0
    80001e30:	c56080e7          	jalr	-938(ra) # 80001a82 <myproc>
    80001e34:	892a                	mv	s2,a0
  sz = p->sz;
    80001e36:	652c                	ld	a1,72(a0)
    80001e38:	0005861b          	sext.w	a2,a1
  if(n > 0){
    80001e3c:	00904f63          	bgtz	s1,80001e5a <growproc+0x3c>
  } else if(n < 0){
    80001e40:	0204cc63          	bltz	s1,80001e78 <growproc+0x5a>
  p->sz = sz;
    80001e44:	1602                	slli	a2,a2,0x20
    80001e46:	9201                	srli	a2,a2,0x20
    80001e48:	04c93423          	sd	a2,72(s2)
  return 0;
    80001e4c:	4501                	li	a0,0
}
    80001e4e:	60e2                	ld	ra,24(sp)
    80001e50:	6442                	ld	s0,16(sp)
    80001e52:	64a2                	ld	s1,8(sp)
    80001e54:	6902                	ld	s2,0(sp)
    80001e56:	6105                	addi	sp,sp,32
    80001e58:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001e5a:	9e25                	addw	a2,a2,s1
    80001e5c:	1602                	slli	a2,a2,0x20
    80001e5e:	9201                	srli	a2,a2,0x20
    80001e60:	1582                	slli	a1,a1,0x20
    80001e62:	9181                	srli	a1,a1,0x20
    80001e64:	6928                	ld	a0,80(a0)
    80001e66:	fffff097          	auipc	ra,0xfffff
    80001e6a:	59c080e7          	jalr	1436(ra) # 80001402 <uvmalloc>
    80001e6e:	0005061b          	sext.w	a2,a0
    80001e72:	fa69                	bnez	a2,80001e44 <growproc+0x26>
      return -1;
    80001e74:	557d                	li	a0,-1
    80001e76:	bfe1                	j	80001e4e <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e78:	9e25                	addw	a2,a2,s1
    80001e7a:	1602                	slli	a2,a2,0x20
    80001e7c:	9201                	srli	a2,a2,0x20
    80001e7e:	1582                	slli	a1,a1,0x20
    80001e80:	9181                	srli	a1,a1,0x20
    80001e82:	6928                	ld	a0,80(a0)
    80001e84:	fffff097          	auipc	ra,0xfffff
    80001e88:	536080e7          	jalr	1334(ra) # 800013ba <uvmdealloc>
    80001e8c:	0005061b          	sext.w	a2,a0
    80001e90:	bf55                	j	80001e44 <growproc+0x26>

0000000080001e92 <fork>:
{
    80001e92:	7179                	addi	sp,sp,-48
    80001e94:	f406                	sd	ra,40(sp)
    80001e96:	f022                	sd	s0,32(sp)
    80001e98:	ec26                	sd	s1,24(sp)
    80001e9a:	e84a                	sd	s2,16(sp)
    80001e9c:	e44e                	sd	s3,8(sp)
    80001e9e:	e052                	sd	s4,0(sp)
    80001ea0:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ea2:	00000097          	auipc	ra,0x0
    80001ea6:	be0080e7          	jalr	-1056(ra) # 80001a82 <myproc>
    80001eaa:	89aa                	mv	s3,a0
  if((np = allocproc()) == 0){
    80001eac:	00000097          	auipc	ra,0x0
    80001eb0:	de2080e7          	jalr	-542(ra) # 80001c8e <allocproc>
    80001eb4:	14050d63          	beqz	a0,8000200e <fork+0x17c>
    80001eb8:	892a                	mv	s2,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001eba:	0489b603          	ld	a2,72(s3)
    80001ebe:	692c                	ld	a1,80(a0)
    80001ec0:	0509b503          	ld	a0,80(s3)
    80001ec4:	fffff097          	auipc	ra,0xfffff
    80001ec8:	68a080e7          	jalr	1674(ra) # 8000154e <uvmcopy>
    80001ecc:	04054663          	bltz	a0,80001f18 <fork+0x86>
  np->sz = p->sz;
    80001ed0:	0489b783          	ld	a5,72(s3)
    80001ed4:	04f93423          	sd	a5,72(s2)
  *(np->trapframe) = *(p->trapframe);
    80001ed8:	0589b683          	ld	a3,88(s3)
    80001edc:	87b6                	mv	a5,a3
    80001ede:	05893703          	ld	a4,88(s2)
    80001ee2:	12068693          	addi	a3,a3,288
    80001ee6:	0007b803          	ld	a6,0(a5)
    80001eea:	6788                	ld	a0,8(a5)
    80001eec:	6b8c                	ld	a1,16(a5)
    80001eee:	6f90                	ld	a2,24(a5)
    80001ef0:	01073023          	sd	a6,0(a4)
    80001ef4:	e708                	sd	a0,8(a4)
    80001ef6:	eb0c                	sd	a1,16(a4)
    80001ef8:	ef10                	sd	a2,24(a4)
    80001efa:	02078793          	addi	a5,a5,32
    80001efe:	02070713          	addi	a4,a4,32
    80001f02:	fed792e3          	bne	a5,a3,80001ee6 <fork+0x54>
  np->trapframe->a0 = 0;
    80001f06:	05893783          	ld	a5,88(s2)
    80001f0a:	0607b823          	sd	zero,112(a5)
    80001f0e:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001f12:	15000a13          	li	s4,336
    80001f16:	a03d                	j	80001f44 <fork+0xb2>
    freeproc(np);
    80001f18:	854a                	mv	a0,s2
    80001f1a:	00000097          	auipc	ra,0x0
    80001f1e:	d1c080e7          	jalr	-740(ra) # 80001c36 <freeproc>
    release(&np->lock);
    80001f22:	854a                	mv	a0,s2
    80001f24:	fffff097          	auipc	ra,0xfffff
    80001f28:	d62080e7          	jalr	-670(ra) # 80000c86 <release>
    return -1;
    80001f2c:	5a7d                	li	s4,-1
    80001f2e:	a0e9                	j	80001ff8 <fork+0x166>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f30:	00003097          	auipc	ra,0x3
    80001f34:	9e4080e7          	jalr	-1564(ra) # 80004914 <filedup>
    80001f38:	009907b3          	add	a5,s2,s1
    80001f3c:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001f3e:	04a1                	addi	s1,s1,8
    80001f40:	01448763          	beq	s1,s4,80001f4e <fork+0xbc>
    if(p->ofile[i])
    80001f44:	009987b3          	add	a5,s3,s1
    80001f48:	6388                	ld	a0,0(a5)
    80001f4a:	f17d                	bnez	a0,80001f30 <fork+0x9e>
    80001f4c:	bfcd                	j	80001f3e <fork+0xac>
  np->cwd = idup(p->cwd);
    80001f4e:	1509b503          	ld	a0,336(s3)
    80001f52:	00002097          	auipc	ra,0x2
    80001f56:	b38080e7          	jalr	-1224(ra) # 80003a8a <idup>
    80001f5a:	14a93823          	sd	a0,336(s2)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f5e:	4641                	li	a2,16
    80001f60:	15898593          	addi	a1,s3,344
    80001f64:	15890513          	addi	a0,s2,344
    80001f68:	fffff097          	auipc	ra,0xfffff
    80001f6c:	ebc080e7          	jalr	-324(ra) # 80000e24 <safestrcpy>
  pid = np->pid;
    80001f70:	03092a03          	lw	s4,48(s2)
  release(&np->lock);
    80001f74:	854a                	mv	a0,s2
    80001f76:	fffff097          	auipc	ra,0xfffff
    80001f7a:	d10080e7          	jalr	-752(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001f7e:	0000f497          	auipc	s1,0xf
    80001f82:	33a48493          	addi	s1,s1,826 # 800112b8 <wait_lock>
    80001f86:	8526                	mv	a0,s1
    80001f88:	fffff097          	auipc	ra,0xfffff
    80001f8c:	c4a080e7          	jalr	-950(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001f90:	03393c23          	sd	s3,56(s2)
  release(&wait_lock);
    80001f94:	8526                	mv	a0,s1
    80001f96:	fffff097          	auipc	ra,0xfffff
    80001f9a:	cf0080e7          	jalr	-784(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001f9e:	854a                	mv	a0,s2
    80001fa0:	fffff097          	auipc	ra,0xfffff
    80001fa4:	c32080e7          	jalr	-974(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001fa8:	478d                	li	a5,3
    80001faa:	00f92c23          	sw	a5,24(s2)
    if(temp == np)
    80001fae:	00010797          	auipc	a5,0x10
    80001fb2:	83278793          	addi	a5,a5,-1998 # 800117e0 <proc>
    80001fb6:	04f90a63          	beq	s2,a5,8000200a <fork+0x178>
  for(temp = proc ; temp < &proc[NPROC];temp++){
    80001fba:	00010797          	auipc	a5,0x10
    80001fbe:	98e78793          	addi	a5,a5,-1650 # 80011948 <proc+0x168>
    index++;
    80001fc2:	4585                	li	a1,1
  for(temp = proc ; temp < &proc[NPROC];temp++){
    80001fc4:	00015717          	auipc	a4,0x15
    80001fc8:	21c70713          	addi	a4,a4,540 # 800171e0 <tickslock>
    if(temp == np)
    80001fcc:	00f90763          	beq	s2,a5,80001fda <fork+0x148>
    index++;
    80001fd0:	2585                	addiw	a1,a1,1
  for(temp = proc ; temp < &proc[NPROC];temp++){
    80001fd2:	16878793          	addi	a5,a5,360
    80001fd6:	fee79be3          	bne	a5,a4,80001fcc <fork+0x13a>
  enqueue(qtable,index,NPROC);
    80001fda:	04000613          	li	a2,64
    80001fde:	0000f517          	auipc	a0,0xf
    80001fe2:	2f250513          	addi	a0,a0,754 # 800112d0 <qtable>
    80001fe6:	00000097          	auipc	ra,0x0
    80001fea:	838080e7          	jalr	-1992(ra) # 8000181e <enqueue>
  release(&np->lock);
    80001fee:	854a                	mv	a0,s2
    80001ff0:	fffff097          	auipc	ra,0xfffff
    80001ff4:	c96080e7          	jalr	-874(ra) # 80000c86 <release>
}
    80001ff8:	8552                	mv	a0,s4
    80001ffa:	70a2                	ld	ra,40(sp)
    80001ffc:	7402                	ld	s0,32(sp)
    80001ffe:	64e2                	ld	s1,24(sp)
    80002000:	6942                	ld	s2,16(sp)
    80002002:	69a2                	ld	s3,8(sp)
    80002004:	6a02                	ld	s4,0(sp)
    80002006:	6145                	addi	sp,sp,48
    80002008:	8082                	ret
  int index=0;
    8000200a:	4581                	li	a1,0
    8000200c:	b7f9                	j	80001fda <fork+0x148>
    return -1;
    8000200e:	5a7d                	li	s4,-1
    80002010:	b7e5                	j	80001ff8 <fork+0x166>

0000000080002012 <scheduler>:
{
    80002012:	7159                	addi	sp,sp,-112
    80002014:	f486                	sd	ra,104(sp)
    80002016:	f0a2                	sd	s0,96(sp)
    80002018:	eca6                	sd	s1,88(sp)
    8000201a:	e8ca                	sd	s2,80(sp)
    8000201c:	e4ce                	sd	s3,72(sp)
    8000201e:	e0d2                	sd	s4,64(sp)
    80002020:	fc56                	sd	s5,56(sp)
    80002022:	f85a                	sd	s6,48(sp)
    80002024:	f45e                	sd	s7,40(sp)
    80002026:	f062                	sd	s8,32(sp)
    80002028:	ec66                	sd	s9,24(sp)
    8000202a:	e86a                	sd	s10,16(sp)
    8000202c:	e46e                	sd	s11,8(sp)
    8000202e:	1880                	addi	s0,sp,112
    80002030:	8792                	mv	a5,tp
  int id = r_tp();
    80002032:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002034:	00779c13          	slli	s8,a5,0x7
    80002038:	0000f717          	auipc	a4,0xf
    8000203c:	26870713          	addi	a4,a4,616 # 800112a0 <pid_lock>
    80002040:	9762                	add	a4,a4,s8
    80002042:	14073023          	sd	zero,320(a4)
      swtch(&c->context,&p->context);
    80002046:	0000f717          	auipc	a4,0xf
    8000204a:	3a270713          	addi	a4,a4,930 # 800113e8 <cpus+0x8>
    8000204e:	9c3a                	add	s8,s8,a4
    if(qtable[NPROC]!=-1){
    80002050:	0000fb17          	auipc	s6,0xf
    80002054:	250b0b13          	addi	s6,s6,592 # 800112a0 <pid_lock>
    80002058:	5bfd                	li	s7,-1
    8000205a:	16800a93          	li	s5,360
       p = &proc[qtable[NPROC+2]];
    8000205e:	0000f997          	auipc	s3,0xf
    80002062:	78298993          	addi	s3,s3,1922 # 800117e0 <proc>
      p->state = RUNNING;
    80002066:	4c91                	li	s9,4
      c->proc = p;
    80002068:	079e                	slli	a5,a5,0x7
    8000206a:	00fb0a33          	add	s4,s6,a5
          int mqv = dequeue(qtable,NPROC+1);
    8000206e:	0000fd17          	auipc	s10,0xf
    80002072:	262d0d13          	addi	s10,s10,610 # 800112d0 <qtable>
    80002076:	a025                	j	8000209e <scheduler+0x8c>
          t->state = RUNNABLE;
    80002078:	035507b3          	mul	a5,a0,s5
    8000207c:	97ce                	add	a5,a5,s3
    8000207e:	470d                	li	a4,3
    80002080:	cf98                	sw	a4,24(a5)
        enqueue(qtable,mqv,NPROC+1);
    80002082:	04100613          	li	a2,65
    80002086:	856a                	mv	a0,s10
    80002088:	fffff097          	auipc	ra,0xfffff
    8000208c:	796080e7          	jalr	1942(ra) # 8000181e <enqueue>
      release(&p->lock);
    80002090:	854a                	mv	a0,s2
    80002092:	fffff097          	auipc	ra,0xfffff
    80002096:	bf4080e7          	jalr	-1036(ra) # 80000c86 <release>
    c->proc = 0;
    8000209a:	140a3023          	sd	zero,320(s4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000209e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800020a2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800020a6:	10079073          	csrw	sstatus,a5
    if(qtable[NPROC]!=-1){
    800020aa:	130b2483          	lw	s1,304(s6)
    800020ae:	05748e63          	beq	s1,s7,8000210a <scheduler+0xf8>
      p = &proc[qtable[NPROC]];
    800020b2:	03548db3          	mul	s11,s1,s5
    800020b6:	013d8933          	add	s2,s11,s3
      acquire(&p->lock);
    800020ba:	854a                	mv	a0,s2
    800020bc:	fffff097          	auipc	ra,0xfffff
    800020c0:	b16080e7          	jalr	-1258(ra) # 80000bd2 <acquire>
      p->state = RUNNING;
    800020c4:	01992c23          	sw	s9,24(s2)
      c->proc = p;
    800020c8:	152a3023          	sd	s2,320(s4)
      swtch(&c->context,&p->context);
    800020cc:	060d8593          	addi	a1,s11,96
    800020d0:	95ce                	add	a1,a1,s3
    800020d2:	8562                	mv	a0,s8
    800020d4:	00001097          	auipc	ra,0x1
    800020d8:	890080e7          	jalr	-1904(ra) # 80002964 <swtch>
      if(p->ticks>1){
    800020dc:	03492703          	lw	a4,52(s2)
    800020e0:	4785                	li	a5,1
    800020e2:	fae7d7e3          	bge	a5,a4,80002090 <scheduler+0x7e>
        p->ticks=0;
    800020e6:	02092a23          	sw	zero,52(s2)
        int mqv = dequeue(qtable,NPROC);
    800020ea:	04000593          	li	a1,64
    800020ee:	856a                	mv	a0,s10
    800020f0:	fffff097          	auipc	ra,0xfffff
    800020f4:	792080e7          	jalr	1938(ra) # 80001882 <dequeue>
    800020f8:	85aa                	mv	a1,a0
        if(t->state != RUNNABLE)
    800020fa:	035507b3          	mul	a5,a0,s5
    800020fe:	97ce                	add	a5,a5,s3
    80002100:	4f98                	lw	a4,24(a5)
    80002102:	478d                	li	a5,3
    80002104:	f6f71ae3          	bne	a4,a5,80002078 <scheduler+0x66>
    80002108:	bfad                	j	80002082 <scheduler+0x70>
    else if(qtable[NPROC+1]!=-1){
    8000210a:	134b2483          	lw	s1,308(s6)
    8000210e:	05749163          	bne	s1,s7,80002150 <scheduler+0x13e>
    else if(qtable[NPROC+2]!=-1){
    80002112:	138b2583          	lw	a1,312(s6)
    80002116:	f97582e3          	beq	a1,s7,8000209a <scheduler+0x88>
       p = &proc[qtable[NPROC+2]];
    8000211a:	035584b3          	mul	s1,a1,s5
    8000211e:	01348933          	add	s2,s1,s3
      acquire(&p->lock);
    80002122:	854a                	mv	a0,s2
    80002124:	fffff097          	auipc	ra,0xfffff
    80002128:	aae080e7          	jalr	-1362(ra) # 80000bd2 <acquire>
      p->state = RUNNING;
    8000212c:	01992c23          	sw	s9,24(s2)
      c->proc = p;
    80002130:	152a3023          	sd	s2,320(s4)
      swtch(&c->context,&p->context);
    80002134:	06048593          	addi	a1,s1,96
    80002138:	95ce                	add	a1,a1,s3
    8000213a:	8562                	mv	a0,s8
    8000213c:	00001097          	auipc	ra,0x1
    80002140:	828080e7          	jalr	-2008(ra) # 80002964 <swtch>
      release(&p->lock); 
    80002144:	854a                	mv	a0,s2
    80002146:	fffff097          	auipc	ra,0xfffff
    8000214a:	b40080e7          	jalr	-1216(ra) # 80000c86 <release>
    8000214e:	b7b1                	j	8000209a <scheduler+0x88>
      p = &proc[qtable[NPROC+1]];
    80002150:	03548db3          	mul	s11,s1,s5
    80002154:	013d8933          	add	s2,s11,s3
      acquire(&p->lock);
    80002158:	854a                	mv	a0,s2
    8000215a:	fffff097          	auipc	ra,0xfffff
    8000215e:	a78080e7          	jalr	-1416(ra) # 80000bd2 <acquire>
      p->state = RUNNING;
    80002162:	01992c23          	sw	s9,24(s2)
      c->proc = p;
    80002166:	152a3023          	sd	s2,320(s4)
      swtch(&c->context,&p->context);
    8000216a:	060d8593          	addi	a1,s11,96
    8000216e:	95ce                	add	a1,a1,s3
    80002170:	8562                	mv	a0,s8
    80002172:	00000097          	auipc	ra,0x0
    80002176:	7f2080e7          	jalr	2034(ra) # 80002964 <swtch>
      if(p->ticks > 2){
    8000217a:	03492703          	lw	a4,52(s2)
    8000217e:	4789                	li	a5,2
    80002180:	00e7c863          	blt	a5,a4,80002190 <scheduler+0x17e>
      release(&p->lock); 
    80002184:	854a                	mv	a0,s2
    80002186:	fffff097          	auipc	ra,0xfffff
    8000218a:	b00080e7          	jalr	-1280(ra) # 80000c86 <release>
    8000218e:	b731                	j	8000209a <scheduler+0x88>
          p->ticks = 0;
    80002190:	02092a23          	sw	zero,52(s2)
          int mqv = dequeue(qtable,NPROC+1);
    80002194:	04100593          	li	a1,65
    80002198:	856a                	mv	a0,s10
    8000219a:	fffff097          	auipc	ra,0xfffff
    8000219e:	6e8080e7          	jalr	1768(ra) # 80001882 <dequeue>
    800021a2:	85aa                	mv	a1,a0
          enqueue(qtable,mqv,NPROC+2);
    800021a4:	04200613          	li	a2,66
    800021a8:	856a                	mv	a0,s10
    800021aa:	fffff097          	auipc	ra,0xfffff
    800021ae:	674080e7          	jalr	1652(ra) # 8000181e <enqueue>
    800021b2:	bfc9                	j	80002184 <scheduler+0x172>

00000000800021b4 <sched>:
{
    800021b4:	7179                	addi	sp,sp,-48
    800021b6:	f406                	sd	ra,40(sp)
    800021b8:	f022                	sd	s0,32(sp)
    800021ba:	ec26                	sd	s1,24(sp)
    800021bc:	e84a                	sd	s2,16(sp)
    800021be:	e44e                	sd	s3,8(sp)
    800021c0:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800021c2:	00000097          	auipc	ra,0x0
    800021c6:	8c0080e7          	jalr	-1856(ra) # 80001a82 <myproc>
    800021ca:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800021cc:	fffff097          	auipc	ra,0xfffff
    800021d0:	98c080e7          	jalr	-1652(ra) # 80000b58 <holding>
    800021d4:	c93d                	beqz	a0,8000224a <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800021d6:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800021d8:	2781                	sext.w	a5,a5
    800021da:	079e                	slli	a5,a5,0x7
    800021dc:	0000f717          	auipc	a4,0xf
    800021e0:	0c470713          	addi	a4,a4,196 # 800112a0 <pid_lock>
    800021e4:	97ba                	add	a5,a5,a4
    800021e6:	1b87a703          	lw	a4,440(a5)
    800021ea:	4785                	li	a5,1
    800021ec:	06f71763          	bne	a4,a5,8000225a <sched+0xa6>
  if(p->state == RUNNING)
    800021f0:	4c98                	lw	a4,24(s1)
    800021f2:	4791                	li	a5,4
    800021f4:	06f70b63          	beq	a4,a5,8000226a <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800021f8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800021fc:	8b89                	andi	a5,a5,2
  if(intr_get())
    800021fe:	efb5                	bnez	a5,8000227a <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002200:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002202:	0000f917          	auipc	s2,0xf
    80002206:	09e90913          	addi	s2,s2,158 # 800112a0 <pid_lock>
    8000220a:	2781                	sext.w	a5,a5
    8000220c:	079e                	slli	a5,a5,0x7
    8000220e:	97ca                	add	a5,a5,s2
    80002210:	1bc7a983          	lw	s3,444(a5)
    80002214:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002216:	2781                	sext.w	a5,a5
    80002218:	079e                	slli	a5,a5,0x7
    8000221a:	0000f597          	auipc	a1,0xf
    8000221e:	1ce58593          	addi	a1,a1,462 # 800113e8 <cpus+0x8>
    80002222:	95be                	add	a1,a1,a5
    80002224:	06048513          	addi	a0,s1,96
    80002228:	00000097          	auipc	ra,0x0
    8000222c:	73c080e7          	jalr	1852(ra) # 80002964 <swtch>
    80002230:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002232:	2781                	sext.w	a5,a5
    80002234:	079e                	slli	a5,a5,0x7
    80002236:	97ca                	add	a5,a5,s2
    80002238:	1b37ae23          	sw	s3,444(a5)
}
    8000223c:	70a2                	ld	ra,40(sp)
    8000223e:	7402                	ld	s0,32(sp)
    80002240:	64e2                	ld	s1,24(sp)
    80002242:	6942                	ld	s2,16(sp)
    80002244:	69a2                	ld	s3,8(sp)
    80002246:	6145                	addi	sp,sp,48
    80002248:	8082                	ret
    panic("sched p->lock");
    8000224a:	00006517          	auipc	a0,0x6
    8000224e:	fb650513          	addi	a0,a0,-74 # 80008200 <digits+0x1c0>
    80002252:	ffffe097          	auipc	ra,0xffffe
    80002256:	2de080e7          	jalr	734(ra) # 80000530 <panic>
    panic("sched locks");
    8000225a:	00006517          	auipc	a0,0x6
    8000225e:	fb650513          	addi	a0,a0,-74 # 80008210 <digits+0x1d0>
    80002262:	ffffe097          	auipc	ra,0xffffe
    80002266:	2ce080e7          	jalr	718(ra) # 80000530 <panic>
    panic("sched running");
    8000226a:	00006517          	auipc	a0,0x6
    8000226e:	fb650513          	addi	a0,a0,-74 # 80008220 <digits+0x1e0>
    80002272:	ffffe097          	auipc	ra,0xffffe
    80002276:	2be080e7          	jalr	702(ra) # 80000530 <panic>
    panic("sched interruptible");
    8000227a:	00006517          	auipc	a0,0x6
    8000227e:	fb650513          	addi	a0,a0,-74 # 80008230 <digits+0x1f0>
    80002282:	ffffe097          	auipc	ra,0xffffe
    80002286:	2ae080e7          	jalr	686(ra) # 80000530 <panic>

000000008000228a <yield>:
{
    8000228a:	715d                	addi	sp,sp,-80
    8000228c:	e486                	sd	ra,72(sp)
    8000228e:	e0a2                	sd	s0,64(sp)
    80002290:	fc26                	sd	s1,56(sp)
    80002292:	f84a                	sd	s2,48(sp)
    80002294:	f44e                	sd	s3,40(sp)
    80002296:	f052                	sd	s4,32(sp)
    80002298:	ec56                	sd	s5,24(sp)
    8000229a:	e85a                	sd	s6,16(sp)
    8000229c:	e45e                	sd	s7,8(sp)
    8000229e:	0880                	addi	s0,sp,80
  struct proc *p = myproc();
    800022a0:	fffff097          	auipc	ra,0xfffff
    800022a4:	7e2080e7          	jalr	2018(ra) # 80001a82 <myproc>
    800022a8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	928080e7          	jalr	-1752(ra) # 80000bd2 <acquire>
  p->ticks++;
    800022b2:	58dc                	lw	a5,52(s1)
    800022b4:	2785                	addiw	a5,a5,1
    800022b6:	d8dc                	sw	a5,52(s1)
  totalpick++;
    800022b8:	00007717          	auipc	a4,0x7
    800022bc:	d7870713          	addi	a4,a4,-648 # 80009030 <totalpick>
    800022c0:	431c                	lw	a5,0(a4)
    800022c2:	2785                	addiw	a5,a5,1
    800022c4:	c31c                	sw	a5,0(a4)
  p->state = RUNNABLE;
    800022c6:	478d                	li	a5,3
    800022c8:	cc9c                	sw	a5,24(s1)
    if(temp == p)
    800022ca:	0000f797          	auipc	a5,0xf
    800022ce:	51678793          	addi	a5,a5,1302 # 800117e0 <proc>
    800022d2:	06f48663          	beq	s1,a5,8000233e <yield+0xb4>
  for(temp = proc ; temp < &proc[NPROC];temp++){
    800022d6:	0000f797          	auipc	a5,0xf
    800022da:	67278793          	addi	a5,a5,1650 # 80011948 <proc+0x168>
    index++;
    800022de:	4585                	li	a1,1
  for(temp = proc ; temp < &proc[NPROC];temp++){
    800022e0:	04000713          	li	a4,64
    if(temp == p)
    800022e4:	00f48763          	beq	s1,a5,800022f2 <yield+0x68>
    index++;
    800022e8:	2585                	addiw	a1,a1,1
  for(temp = proc ; temp < &proc[NPROC];temp++){
    800022ea:	16878793          	addi	a5,a5,360
    800022ee:	fee59be3          	bne	a1,a4,800022e4 <yield+0x5a>
  enqueue(qtable,index,NPROC);
    800022f2:	04000613          	li	a2,64
    800022f6:	0000f517          	auipc	a0,0xf
    800022fa:	fda50513          	addi	a0,a0,-38 # 800112d0 <qtable>
    800022fe:	fffff097          	auipc	ra,0xfffff
    80002302:	520080e7          	jalr	1312(ra) # 8000181e <enqueue>
  if(totalpick == 32){
    80002306:	00007717          	auipc	a4,0x7
    8000230a:	d2a72703          	lw	a4,-726(a4) # 80009030 <totalpick>
    8000230e:	02000793          	li	a5,32
    80002312:	02f70863          	beq	a4,a5,80002342 <yield+0xb8>
  sched();
    80002316:	00000097          	auipc	ra,0x0
    8000231a:	e9e080e7          	jalr	-354(ra) # 800021b4 <sched>
  release(&p->lock);
    8000231e:	8526                	mv	a0,s1
    80002320:	fffff097          	auipc	ra,0xfffff
    80002324:	966080e7          	jalr	-1690(ra) # 80000c86 <release>
}
    80002328:	60a6                	ld	ra,72(sp)
    8000232a:	6406                	ld	s0,64(sp)
    8000232c:	74e2                	ld	s1,56(sp)
    8000232e:	7942                	ld	s2,48(sp)
    80002330:	79a2                	ld	s3,40(sp)
    80002332:	7a02                	ld	s4,32(sp)
    80002334:	6ae2                	ld	s5,24(sp)
    80002336:	6b42                	ld	s6,16(sp)
    80002338:	6ba2                	ld	s7,8(sp)
    8000233a:	6161                	addi	sp,sp,80
    8000233c:	8082                	ret
  int index=0;
    8000233e:	4581                	li	a1,0
    80002340:	bf4d                	j	800022f2 <yield+0x68>
    while(qtable[NPROC+1]!=-1){
    80002342:	0000f717          	auipc	a4,0xf
    80002346:	09272703          	lw	a4,146(a4) # 800113d4 <qtable+0x104>
    8000234a:	57fd                	li	a5,-1
    8000234c:	02f70e63          	beq	a4,a5,80002388 <yield+0xfe>
      int mqv = dequeue(qtable,NPROC+1);
    80002350:	0000fa17          	auipc	s4,0xf
    80002354:	f50a0a13          	addi	s4,s4,-176 # 800112a0 <pid_lock>
    80002358:	0000f917          	auipc	s2,0xf
    8000235c:	f7890913          	addi	s2,s2,-136 # 800112d0 <qtable>
    while(qtable[NPROC+1]!=-1){
    80002360:	59fd                	li	s3,-1
      int mqv = dequeue(qtable,NPROC+1);
    80002362:	04100593          	li	a1,65
    80002366:	854a                	mv	a0,s2
    80002368:	fffff097          	auipc	ra,0xfffff
    8000236c:	51a080e7          	jalr	1306(ra) # 80001882 <dequeue>
    80002370:	85aa                	mv	a1,a0
        enqueue(qtable,mqv,NPROC);
    80002372:	04000613          	li	a2,64
    80002376:	854a                	mv	a0,s2
    80002378:	fffff097          	auipc	ra,0xfffff
    8000237c:	4a6080e7          	jalr	1190(ra) # 8000181e <enqueue>
    while(qtable[NPROC+1]!=-1){
    80002380:	134a2783          	lw	a5,308(s4)
    80002384:	fd379fe3          	bne	a5,s3,80002362 <yield+0xd8>
    while(qtable[NPROC+2]!=-1){
    80002388:	0000f997          	auipc	s3,0xf
    8000238c:	f1898993          	addi	s3,s3,-232 # 800112a0 <pid_lock>
    80002390:	597d                	li	s2,-1
      if(t->state == RUNNABLE)
    80002392:	0000fb97          	auipc	s7,0xf
    80002396:	44eb8b93          	addi	s7,s7,1102 # 800117e0 <proc>
    8000239a:	16800b13          	li	s6,360
      int mqv = dequeue(qtable,NPROC+2);
    8000239e:	0000fa97          	auipc	s5,0xf
    800023a2:	f32a8a93          	addi	s5,s5,-206 # 800112d0 <qtable>
      if(t->state == RUNNABLE)
    800023a6:	4a0d                	li	s4,3
    while(qtable[NPROC+2]!=-1){
    800023a8:	1389a783          	lw	a5,312(s3)
    800023ac:	03278863          	beq	a5,s2,800023dc <yield+0x152>
      int mqv = dequeue(qtable,NPROC+2);
    800023b0:	04200593          	li	a1,66
    800023b4:	8556                	mv	a0,s5
    800023b6:	fffff097          	auipc	ra,0xfffff
    800023ba:	4cc080e7          	jalr	1228(ra) # 80001882 <dequeue>
      if(t->state == RUNNABLE)
    800023be:	036507b3          	mul	a5,a0,s6
    800023c2:	97de                	add	a5,a5,s7
    800023c4:	4f9c                	lw	a5,24(a5)
    800023c6:	ff4791e3          	bne	a5,s4,800023a8 <yield+0x11e>
        enqueue(qtable,mqv,NPROC);
    800023ca:	04000613          	li	a2,64
    800023ce:	85aa                	mv	a1,a0
    800023d0:	8556                	mv	a0,s5
    800023d2:	fffff097          	auipc	ra,0xfffff
    800023d6:	44c080e7          	jalr	1100(ra) # 8000181e <enqueue>
    800023da:	b7f1                	j	800023a6 <yield+0x11c>
    totalpick = 0;
    800023dc:	00007797          	auipc	a5,0x7
    800023e0:	c407aa23          	sw	zero,-940(a5) # 80009030 <totalpick>
    800023e4:	bf0d                	j	80002316 <yield+0x8c>

00000000800023e6 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800023e6:	7179                	addi	sp,sp,-48
    800023e8:	f406                	sd	ra,40(sp)
    800023ea:	f022                	sd	s0,32(sp)
    800023ec:	ec26                	sd	s1,24(sp)
    800023ee:	e84a                	sd	s2,16(sp)
    800023f0:	e44e                	sd	s3,8(sp)
    800023f2:	1800                	addi	s0,sp,48
    800023f4:	89aa                	mv	s3,a0
    800023f6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800023f8:	fffff097          	auipc	ra,0xfffff
    800023fc:	68a080e7          	jalr	1674(ra) # 80001a82 <myproc>
    80002400:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002402:	ffffe097          	auipc	ra,0xffffe
    80002406:	7d0080e7          	jalr	2000(ra) # 80000bd2 <acquire>
  release(lk);
    8000240a:	854a                	mv	a0,s2
    8000240c:	fffff097          	auipc	ra,0xfffff
    80002410:	87a080e7          	jalr	-1926(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    80002414:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002418:	4789                	li	a5,2
    8000241a:	cc9c                	sw	a5,24(s1)

  sched();
    8000241c:	00000097          	auipc	ra,0x0
    80002420:	d98080e7          	jalr	-616(ra) # 800021b4 <sched>

  // Tidy up.
  p->chan = 0;
    80002424:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002428:	8526                	mv	a0,s1
    8000242a:	fffff097          	auipc	ra,0xfffff
    8000242e:	85c080e7          	jalr	-1956(ra) # 80000c86 <release>
  acquire(lk);
    80002432:	854a                	mv	a0,s2
    80002434:	ffffe097          	auipc	ra,0xffffe
    80002438:	79e080e7          	jalr	1950(ra) # 80000bd2 <acquire>
}
    8000243c:	70a2                	ld	ra,40(sp)
    8000243e:	7402                	ld	s0,32(sp)
    80002440:	64e2                	ld	s1,24(sp)
    80002442:	6942                	ld	s2,16(sp)
    80002444:	69a2                	ld	s3,8(sp)
    80002446:	6145                	addi	sp,sp,48
    80002448:	8082                	ret

000000008000244a <wait>:
{
    8000244a:	715d                	addi	sp,sp,-80
    8000244c:	e486                	sd	ra,72(sp)
    8000244e:	e0a2                	sd	s0,64(sp)
    80002450:	fc26                	sd	s1,56(sp)
    80002452:	f84a                	sd	s2,48(sp)
    80002454:	f44e                	sd	s3,40(sp)
    80002456:	f052                	sd	s4,32(sp)
    80002458:	ec56                	sd	s5,24(sp)
    8000245a:	e85a                	sd	s6,16(sp)
    8000245c:	e45e                	sd	s7,8(sp)
    8000245e:	e062                	sd	s8,0(sp)
    80002460:	0880                	addi	s0,sp,80
    80002462:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002464:	fffff097          	auipc	ra,0xfffff
    80002468:	61e080e7          	jalr	1566(ra) # 80001a82 <myproc>
    8000246c:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000246e:	0000f517          	auipc	a0,0xf
    80002472:	e4a50513          	addi	a0,a0,-438 # 800112b8 <wait_lock>
    80002476:	ffffe097          	auipc	ra,0xffffe
    8000247a:	75c080e7          	jalr	1884(ra) # 80000bd2 <acquire>
    havekids = 0;
    8000247e:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002480:	4a15                	li	s4,5
    for(np = proc; np < &proc[NPROC]; np++){
    80002482:	00015997          	auipc	s3,0x15
    80002486:	d5e98993          	addi	s3,s3,-674 # 800171e0 <tickslock>
        havekids = 1;
    8000248a:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000248c:	0000fc17          	auipc	s8,0xf
    80002490:	e2cc0c13          	addi	s8,s8,-468 # 800112b8 <wait_lock>
    havekids = 0;
    80002494:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002496:	0000f497          	auipc	s1,0xf
    8000249a:	34a48493          	addi	s1,s1,842 # 800117e0 <proc>
    8000249e:	a0bd                	j	8000250c <wait+0xc2>
          pid = np->pid;
    800024a0:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800024a4:	000b0e63          	beqz	s6,800024c0 <wait+0x76>
    800024a8:	4691                	li	a3,4
    800024aa:	02c48613          	addi	a2,s1,44
    800024ae:	85da                	mv	a1,s6
    800024b0:	05093503          	ld	a0,80(s2)
    800024b4:	fffff097          	auipc	ra,0xfffff
    800024b8:	19e080e7          	jalr	414(ra) # 80001652 <copyout>
    800024bc:	02054563          	bltz	a0,800024e6 <wait+0x9c>
          freeproc(np);
    800024c0:	8526                	mv	a0,s1
    800024c2:	fffff097          	auipc	ra,0xfffff
    800024c6:	774080e7          	jalr	1908(ra) # 80001c36 <freeproc>
          release(&np->lock);
    800024ca:	8526                	mv	a0,s1
    800024cc:	ffffe097          	auipc	ra,0xffffe
    800024d0:	7ba080e7          	jalr	1978(ra) # 80000c86 <release>
          release(&wait_lock);
    800024d4:	0000f517          	auipc	a0,0xf
    800024d8:	de450513          	addi	a0,a0,-540 # 800112b8 <wait_lock>
    800024dc:	ffffe097          	auipc	ra,0xffffe
    800024e0:	7aa080e7          	jalr	1962(ra) # 80000c86 <release>
          return pid;
    800024e4:	a09d                	j	8000254a <wait+0x100>
            release(&np->lock);
    800024e6:	8526                	mv	a0,s1
    800024e8:	ffffe097          	auipc	ra,0xffffe
    800024ec:	79e080e7          	jalr	1950(ra) # 80000c86 <release>
            release(&wait_lock);
    800024f0:	0000f517          	auipc	a0,0xf
    800024f4:	dc850513          	addi	a0,a0,-568 # 800112b8 <wait_lock>
    800024f8:	ffffe097          	auipc	ra,0xffffe
    800024fc:	78e080e7          	jalr	1934(ra) # 80000c86 <release>
            return -1;
    80002500:	59fd                	li	s3,-1
    80002502:	a0a1                	j	8000254a <wait+0x100>
    for(np = proc; np < &proc[NPROC]; np++){
    80002504:	16848493          	addi	s1,s1,360
    80002508:	03348463          	beq	s1,s3,80002530 <wait+0xe6>
      if(np->parent == p){
    8000250c:	7c9c                	ld	a5,56(s1)
    8000250e:	ff279be3          	bne	a5,s2,80002504 <wait+0xba>
        acquire(&np->lock);
    80002512:	8526                	mv	a0,s1
    80002514:	ffffe097          	auipc	ra,0xffffe
    80002518:	6be080e7          	jalr	1726(ra) # 80000bd2 <acquire>
        if(np->state == ZOMBIE){
    8000251c:	4c9c                	lw	a5,24(s1)
    8000251e:	f94781e3          	beq	a5,s4,800024a0 <wait+0x56>
        release(&np->lock);
    80002522:	8526                	mv	a0,s1
    80002524:	ffffe097          	auipc	ra,0xffffe
    80002528:	762080e7          	jalr	1890(ra) # 80000c86 <release>
        havekids = 1;
    8000252c:	8756                	mv	a4,s5
    8000252e:	bfd9                	j	80002504 <wait+0xba>
    if(!havekids || p->killed){
    80002530:	c701                	beqz	a4,80002538 <wait+0xee>
    80002532:	02892783          	lw	a5,40(s2)
    80002536:	c79d                	beqz	a5,80002564 <wait+0x11a>
      release(&wait_lock);
    80002538:	0000f517          	auipc	a0,0xf
    8000253c:	d8050513          	addi	a0,a0,-640 # 800112b8 <wait_lock>
    80002540:	ffffe097          	auipc	ra,0xffffe
    80002544:	746080e7          	jalr	1862(ra) # 80000c86 <release>
      return -1;
    80002548:	59fd                	li	s3,-1
}
    8000254a:	854e                	mv	a0,s3
    8000254c:	60a6                	ld	ra,72(sp)
    8000254e:	6406                	ld	s0,64(sp)
    80002550:	74e2                	ld	s1,56(sp)
    80002552:	7942                	ld	s2,48(sp)
    80002554:	79a2                	ld	s3,40(sp)
    80002556:	7a02                	ld	s4,32(sp)
    80002558:	6ae2                	ld	s5,24(sp)
    8000255a:	6b42                	ld	s6,16(sp)
    8000255c:	6ba2                	ld	s7,8(sp)
    8000255e:	6c02                	ld	s8,0(sp)
    80002560:	6161                	addi	sp,sp,80
    80002562:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002564:	85e2                	mv	a1,s8
    80002566:	854a                	mv	a0,s2
    80002568:	00000097          	auipc	ra,0x0
    8000256c:	e7e080e7          	jalr	-386(ra) # 800023e6 <sleep>
    havekids = 0;
    80002570:	b715                	j	80002494 <wait+0x4a>

0000000080002572 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002572:	715d                	addi	sp,sp,-80
    80002574:	e486                	sd	ra,72(sp)
    80002576:	e0a2                	sd	s0,64(sp)
    80002578:	fc26                	sd	s1,56(sp)
    8000257a:	f84a                	sd	s2,48(sp)
    8000257c:	f44e                	sd	s3,40(sp)
    8000257e:	f052                	sd	s4,32(sp)
    80002580:	ec56                	sd	s5,24(sp)
    80002582:	e85a                	sd	s6,16(sp)
    80002584:	e45e                	sd	s7,8(sp)
    80002586:	0880                	addi	s0,sp,80
    80002588:	8aaa                	mv	s5,a0
  struct proc *p;
  int index=0;
    8000258a:	4901                	li	s2,0
  for(p = proc; p < &proc[NPROC]; p++) {
    8000258c:	0000f497          	auipc	s1,0xf
    80002590:	25448493          	addi	s1,s1,596 # 800117e0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002594:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80002596:	4b8d                	li	s7,3
        //add index to the first queue
        enqueue(qtable,index,NPROC);
    80002598:	0000fb17          	auipc	s6,0xf
    8000259c:	d38b0b13          	addi	s6,s6,-712 # 800112d0 <qtable>
  for(p = proc; p < &proc[NPROC]; p++) {
    800025a0:	00015997          	auipc	s3,0x15
    800025a4:	c4098993          	addi	s3,s3,-960 # 800171e0 <tickslock>
    800025a8:	a819                	j	800025be <wakeup+0x4c>
      }
      release(&p->lock);
    800025aa:	8526                	mv	a0,s1
    800025ac:	ffffe097          	auipc	ra,0xffffe
    800025b0:	6da080e7          	jalr	1754(ra) # 80000c86 <release>
    }
    index++;
    800025b4:	2905                	addiw	s2,s2,1
  for(p = proc; p < &proc[NPROC]; p++) {
    800025b6:	16848493          	addi	s1,s1,360
    800025ba:	03348e63          	beq	s1,s3,800025f6 <wakeup+0x84>
    if(p != myproc()){
    800025be:	fffff097          	auipc	ra,0xfffff
    800025c2:	4c4080e7          	jalr	1220(ra) # 80001a82 <myproc>
    800025c6:	fea487e3          	beq	s1,a0,800025b4 <wakeup+0x42>
      acquire(&p->lock);
    800025ca:	8526                	mv	a0,s1
    800025cc:	ffffe097          	auipc	ra,0xffffe
    800025d0:	606080e7          	jalr	1542(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800025d4:	4c9c                	lw	a5,24(s1)
    800025d6:	fd479ae3          	bne	a5,s4,800025aa <wakeup+0x38>
    800025da:	709c                	ld	a5,32(s1)
    800025dc:	fd5797e3          	bne	a5,s5,800025aa <wakeup+0x38>
        p->state = RUNNABLE;
    800025e0:	0174ac23          	sw	s7,24(s1)
        enqueue(qtable,index,NPROC);
    800025e4:	04000613          	li	a2,64
    800025e8:	85ca                	mv	a1,s2
    800025ea:	855a                	mv	a0,s6
    800025ec:	fffff097          	auipc	ra,0xfffff
    800025f0:	232080e7          	jalr	562(ra) # 8000181e <enqueue>
    800025f4:	bf5d                	j	800025aa <wakeup+0x38>
  }
}
    800025f6:	60a6                	ld	ra,72(sp)
    800025f8:	6406                	ld	s0,64(sp)
    800025fa:	74e2                	ld	s1,56(sp)
    800025fc:	7942                	ld	s2,48(sp)
    800025fe:	79a2                	ld	s3,40(sp)
    80002600:	7a02                	ld	s4,32(sp)
    80002602:	6ae2                	ld	s5,24(sp)
    80002604:	6b42                	ld	s6,16(sp)
    80002606:	6ba2                	ld	s7,8(sp)
    80002608:	6161                	addi	sp,sp,80
    8000260a:	8082                	ret

000000008000260c <reparent>:
{
    8000260c:	7179                	addi	sp,sp,-48
    8000260e:	f406                	sd	ra,40(sp)
    80002610:	f022                	sd	s0,32(sp)
    80002612:	ec26                	sd	s1,24(sp)
    80002614:	e84a                	sd	s2,16(sp)
    80002616:	e44e                	sd	s3,8(sp)
    80002618:	e052                	sd	s4,0(sp)
    8000261a:	1800                	addi	s0,sp,48
    8000261c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000261e:	0000f497          	auipc	s1,0xf
    80002622:	1c248493          	addi	s1,s1,450 # 800117e0 <proc>
      pp->parent = initproc;
    80002626:	00007a17          	auipc	s4,0x7
    8000262a:	a02a0a13          	addi	s4,s4,-1534 # 80009028 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000262e:	00015997          	auipc	s3,0x15
    80002632:	bb298993          	addi	s3,s3,-1102 # 800171e0 <tickslock>
    80002636:	a029                	j	80002640 <reparent+0x34>
    80002638:	16848493          	addi	s1,s1,360
    8000263c:	01348d63          	beq	s1,s3,80002656 <reparent+0x4a>
    if(pp->parent == p){
    80002640:	7c9c                	ld	a5,56(s1)
    80002642:	ff279be3          	bne	a5,s2,80002638 <reparent+0x2c>
      pp->parent = initproc;
    80002646:	000a3503          	ld	a0,0(s4)
    8000264a:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000264c:	00000097          	auipc	ra,0x0
    80002650:	f26080e7          	jalr	-218(ra) # 80002572 <wakeup>
    80002654:	b7d5                	j	80002638 <reparent+0x2c>
}
    80002656:	70a2                	ld	ra,40(sp)
    80002658:	7402                	ld	s0,32(sp)
    8000265a:	64e2                	ld	s1,24(sp)
    8000265c:	6942                	ld	s2,16(sp)
    8000265e:	69a2                	ld	s3,8(sp)
    80002660:	6a02                	ld	s4,0(sp)
    80002662:	6145                	addi	sp,sp,48
    80002664:	8082                	ret

0000000080002666 <exit>:
{
    80002666:	7179                	addi	sp,sp,-48
    80002668:	f406                	sd	ra,40(sp)
    8000266a:	f022                	sd	s0,32(sp)
    8000266c:	ec26                	sd	s1,24(sp)
    8000266e:	e84a                	sd	s2,16(sp)
    80002670:	e44e                	sd	s3,8(sp)
    80002672:	e052                	sd	s4,0(sp)
    80002674:	1800                	addi	s0,sp,48
    80002676:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002678:	fffff097          	auipc	ra,0xfffff
    8000267c:	40a080e7          	jalr	1034(ra) # 80001a82 <myproc>
    80002680:	892a                	mv	s2,a0
  if(p == initproc)
    80002682:	00007797          	auipc	a5,0x7
    80002686:	9a67b783          	ld	a5,-1626(a5) # 80009028 <initproc>
    8000268a:	0d050493          	addi	s1,a0,208
    8000268e:	15050993          	addi	s3,a0,336
    80002692:	02a79363          	bne	a5,a0,800026b8 <exit+0x52>
    panic("init exiting");
    80002696:	00006517          	auipc	a0,0x6
    8000269a:	bb250513          	addi	a0,a0,-1102 # 80008248 <digits+0x208>
    8000269e:	ffffe097          	auipc	ra,0xffffe
    800026a2:	e92080e7          	jalr	-366(ra) # 80000530 <panic>
      fileclose(f);
    800026a6:	00002097          	auipc	ra,0x2
    800026aa:	2c0080e7          	jalr	704(ra) # 80004966 <fileclose>
      p->ofile[fd] = 0;
    800026ae:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800026b2:	04a1                	addi	s1,s1,8
    800026b4:	01348563          	beq	s1,s3,800026be <exit+0x58>
    if(p->ofile[fd]){
    800026b8:	6088                	ld	a0,0(s1)
    800026ba:	f575                	bnez	a0,800026a6 <exit+0x40>
    800026bc:	bfdd                	j	800026b2 <exit+0x4c>
  begin_op();
    800026be:	00002097          	auipc	ra,0x2
    800026c2:	ddc080e7          	jalr	-548(ra) # 8000449a <begin_op>
  iput(p->cwd);
    800026c6:	15093503          	ld	a0,336(s2)
    800026ca:	00001097          	auipc	ra,0x1
    800026ce:	5b8080e7          	jalr	1464(ra) # 80003c82 <iput>
  end_op();
    800026d2:	00002097          	auipc	ra,0x2
    800026d6:	e48080e7          	jalr	-440(ra) # 8000451a <end_op>
  p->cwd = 0;
    800026da:	14093823          	sd	zero,336(s2)
  acquire(&wait_lock);
    800026de:	0000f517          	auipc	a0,0xf
    800026e2:	bda50513          	addi	a0,a0,-1062 # 800112b8 <wait_lock>
    800026e6:	ffffe097          	auipc	ra,0xffffe
    800026ea:	4ec080e7          	jalr	1260(ra) # 80000bd2 <acquire>
  reparent(p);
    800026ee:	854a                	mv	a0,s2
    800026f0:	00000097          	auipc	ra,0x0
    800026f4:	f1c080e7          	jalr	-228(ra) # 8000260c <reparent>
  wakeup(p->parent);
    800026f8:	03893503          	ld	a0,56(s2)
    800026fc:	00000097          	auipc	ra,0x0
    80002700:	e76080e7          	jalr	-394(ra) # 80002572 <wakeup>
  acquire(&p->lock);
    80002704:	854a                	mv	a0,s2
    80002706:	ffffe097          	auipc	ra,0xffffe
    8000270a:	4cc080e7          	jalr	1228(ra) # 80000bd2 <acquire>
  p->xstate = status;
    8000270e:	03492623          	sw	s4,44(s2)
    if(temp == p)
    80002712:	0000f797          	auipc	a5,0xf
    80002716:	0ce78793          	addi	a5,a5,206 # 800117e0 <proc>
    8000271a:	04f90e63          	beq	s2,a5,80002776 <exit+0x110>
  for(temp = proc ; temp < &proc[NPROC];temp++){
    8000271e:	0000f797          	auipc	a5,0xf
    80002722:	22a78793          	addi	a5,a5,554 # 80011948 <proc+0x168>
    index++;
    80002726:	4585                	li	a1,1
  for(temp = proc ; temp < &proc[NPROC];temp++){
    80002728:	00015717          	auipc	a4,0x15
    8000272c:	ab870713          	addi	a4,a4,-1352 # 800171e0 <tickslock>
    if(temp == p)
    80002730:	00f90763          	beq	s2,a5,8000273e <exit+0xd8>
    index++;
    80002734:	2585                	addiw	a1,a1,1
  for(temp = proc ; temp < &proc[NPROC];temp++){
    80002736:	16878793          	addi	a5,a5,360
    8000273a:	fee79be3          	bne	a5,a4,80002730 <exit+0xca>
  dequeue(qtable,index);
    8000273e:	0000f517          	auipc	a0,0xf
    80002742:	b9250513          	addi	a0,a0,-1134 # 800112d0 <qtable>
    80002746:	fffff097          	auipc	ra,0xfffff
    8000274a:	13c080e7          	jalr	316(ra) # 80001882 <dequeue>
  release(&wait_lock);
    8000274e:	0000f517          	auipc	a0,0xf
    80002752:	b6a50513          	addi	a0,a0,-1174 # 800112b8 <wait_lock>
    80002756:	ffffe097          	auipc	ra,0xffffe
    8000275a:	530080e7          	jalr	1328(ra) # 80000c86 <release>
  sched();
    8000275e:	00000097          	auipc	ra,0x0
    80002762:	a56080e7          	jalr	-1450(ra) # 800021b4 <sched>
  panic("zombie exit");
    80002766:	00006517          	auipc	a0,0x6
    8000276a:	af250513          	addi	a0,a0,-1294 # 80008258 <digits+0x218>
    8000276e:	ffffe097          	auipc	ra,0xffffe
    80002772:	dc2080e7          	jalr	-574(ra) # 80000530 <panic>
  int index=0;
    80002776:	4581                	li	a1,0
    80002778:	b7d9                	j	8000273e <exit+0xd8>

000000008000277a <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000277a:	7179                	addi	sp,sp,-48
    8000277c:	f406                	sd	ra,40(sp)
    8000277e:	f022                	sd	s0,32(sp)
    80002780:	ec26                	sd	s1,24(sp)
    80002782:	e84a                	sd	s2,16(sp)
    80002784:	e44e                	sd	s3,8(sp)
    80002786:	e052                	sd	s4,0(sp)
    80002788:	1800                	addi	s0,sp,48
    8000278a:	89aa                	mv	s3,a0
  struct proc *p;
  int index = 0;
    8000278c:	4901                	li	s2,0
  for(p = proc; p < &proc[NPROC]; p++){
    8000278e:	0000f497          	auipc	s1,0xf
    80002792:	05248493          	addi	s1,s1,82 # 800117e0 <proc>
    80002796:	00015a17          	auipc	s4,0x15
    8000279a:	a4aa0a13          	addi	s4,s4,-1462 # 800171e0 <tickslock>
    acquire(&p->lock);
    8000279e:	8526                	mv	a0,s1
    800027a0:	ffffe097          	auipc	ra,0xffffe
    800027a4:	432080e7          	jalr	1074(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    800027a8:	589c                	lw	a5,48(s1)
    800027aa:	01378e63          	beq	a5,s3,800027c6 <kill+0x4c>
        enqueue(qtable,index,NPROC);
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800027ae:	8526                	mv	a0,s1
    800027b0:	ffffe097          	auipc	ra,0xffffe
    800027b4:	4d6080e7          	jalr	1238(ra) # 80000c86 <release>
    index++;
    800027b8:	2905                	addiw	s2,s2,1
  for(p = proc; p < &proc[NPROC]; p++){
    800027ba:	16848493          	addi	s1,s1,360
    800027be:	ff4490e3          	bne	s1,s4,8000279e <kill+0x24>
  }
  return -1;
    800027c2:	557d                	li	a0,-1
    800027c4:	a829                	j	800027de <kill+0x64>
      p->killed = 1;
    800027c6:	4785                	li	a5,1
    800027c8:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800027ca:	4c98                	lw	a4,24(s1)
    800027cc:	4789                	li	a5,2
    800027ce:	02f70063          	beq	a4,a5,800027ee <kill+0x74>
      release(&p->lock);
    800027d2:	8526                	mv	a0,s1
    800027d4:	ffffe097          	auipc	ra,0xffffe
    800027d8:	4b2080e7          	jalr	1202(ra) # 80000c86 <release>
      return 0;
    800027dc:	4501                	li	a0,0
}
    800027de:	70a2                	ld	ra,40(sp)
    800027e0:	7402                	ld	s0,32(sp)
    800027e2:	64e2                	ld	s1,24(sp)
    800027e4:	6942                	ld	s2,16(sp)
    800027e6:	69a2                	ld	s3,8(sp)
    800027e8:	6a02                	ld	s4,0(sp)
    800027ea:	6145                	addi	sp,sp,48
    800027ec:	8082                	ret
        p->state = RUNNABLE;
    800027ee:	478d                	li	a5,3
    800027f0:	cc9c                	sw	a5,24(s1)
        enqueue(qtable,index,NPROC);
    800027f2:	04000613          	li	a2,64
    800027f6:	85ca                	mv	a1,s2
    800027f8:	0000f517          	auipc	a0,0xf
    800027fc:	ad850513          	addi	a0,a0,-1320 # 800112d0 <qtable>
    80002800:	fffff097          	auipc	ra,0xfffff
    80002804:	01e080e7          	jalr	30(ra) # 8000181e <enqueue>
    80002808:	b7e9                	j	800027d2 <kill+0x58>

000000008000280a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000280a:	7179                	addi	sp,sp,-48
    8000280c:	f406                	sd	ra,40(sp)
    8000280e:	f022                	sd	s0,32(sp)
    80002810:	ec26                	sd	s1,24(sp)
    80002812:	e84a                	sd	s2,16(sp)
    80002814:	e44e                	sd	s3,8(sp)
    80002816:	e052                	sd	s4,0(sp)
    80002818:	1800                	addi	s0,sp,48
    8000281a:	84aa                	mv	s1,a0
    8000281c:	892e                	mv	s2,a1
    8000281e:	89b2                	mv	s3,a2
    80002820:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002822:	fffff097          	auipc	ra,0xfffff
    80002826:	260080e7          	jalr	608(ra) # 80001a82 <myproc>
  if(user_dst){
    8000282a:	c08d                	beqz	s1,8000284c <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000282c:	86d2                	mv	a3,s4
    8000282e:	864e                	mv	a2,s3
    80002830:	85ca                	mv	a1,s2
    80002832:	6928                	ld	a0,80(a0)
    80002834:	fffff097          	auipc	ra,0xfffff
    80002838:	e1e080e7          	jalr	-482(ra) # 80001652 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000283c:	70a2                	ld	ra,40(sp)
    8000283e:	7402                	ld	s0,32(sp)
    80002840:	64e2                	ld	s1,24(sp)
    80002842:	6942                	ld	s2,16(sp)
    80002844:	69a2                	ld	s3,8(sp)
    80002846:	6a02                	ld	s4,0(sp)
    80002848:	6145                	addi	sp,sp,48
    8000284a:	8082                	ret
    memmove((char *)dst, src, len);
    8000284c:	000a061b          	sext.w	a2,s4
    80002850:	85ce                	mv	a1,s3
    80002852:	854a                	mv	a0,s2
    80002854:	ffffe097          	auipc	ra,0xffffe
    80002858:	4da080e7          	jalr	1242(ra) # 80000d2e <memmove>
    return 0;
    8000285c:	8526                	mv	a0,s1
    8000285e:	bff9                	j	8000283c <either_copyout+0x32>

0000000080002860 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002860:	7179                	addi	sp,sp,-48
    80002862:	f406                	sd	ra,40(sp)
    80002864:	f022                	sd	s0,32(sp)
    80002866:	ec26                	sd	s1,24(sp)
    80002868:	e84a                	sd	s2,16(sp)
    8000286a:	e44e                	sd	s3,8(sp)
    8000286c:	e052                	sd	s4,0(sp)
    8000286e:	1800                	addi	s0,sp,48
    80002870:	892a                	mv	s2,a0
    80002872:	84ae                	mv	s1,a1
    80002874:	89b2                	mv	s3,a2
    80002876:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002878:	fffff097          	auipc	ra,0xfffff
    8000287c:	20a080e7          	jalr	522(ra) # 80001a82 <myproc>
  if(user_src){
    80002880:	c08d                	beqz	s1,800028a2 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002882:	86d2                	mv	a3,s4
    80002884:	864e                	mv	a2,s3
    80002886:	85ca                	mv	a1,s2
    80002888:	6928                	ld	a0,80(a0)
    8000288a:	fffff097          	auipc	ra,0xfffff
    8000288e:	e54080e7          	jalr	-428(ra) # 800016de <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002892:	70a2                	ld	ra,40(sp)
    80002894:	7402                	ld	s0,32(sp)
    80002896:	64e2                	ld	s1,24(sp)
    80002898:	6942                	ld	s2,16(sp)
    8000289a:	69a2                	ld	s3,8(sp)
    8000289c:	6a02                	ld	s4,0(sp)
    8000289e:	6145                	addi	sp,sp,48
    800028a0:	8082                	ret
    memmove(dst, (char*)src, len);
    800028a2:	000a061b          	sext.w	a2,s4
    800028a6:	85ce                	mv	a1,s3
    800028a8:	854a                	mv	a0,s2
    800028aa:	ffffe097          	auipc	ra,0xffffe
    800028ae:	484080e7          	jalr	1156(ra) # 80000d2e <memmove>
    return 0;
    800028b2:	8526                	mv	a0,s1
    800028b4:	bff9                	j	80002892 <either_copyin+0x32>

00000000800028b6 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800028b6:	715d                	addi	sp,sp,-80
    800028b8:	e486                	sd	ra,72(sp)
    800028ba:	e0a2                	sd	s0,64(sp)
    800028bc:	fc26                	sd	s1,56(sp)
    800028be:	f84a                	sd	s2,48(sp)
    800028c0:	f44e                	sd	s3,40(sp)
    800028c2:	f052                	sd	s4,32(sp)
    800028c4:	ec56                	sd	s5,24(sp)
    800028c6:	e85a                	sd	s6,16(sp)
    800028c8:	e45e                	sd	s7,8(sp)
    800028ca:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800028cc:	00005517          	auipc	a0,0x5
    800028d0:	7fc50513          	addi	a0,a0,2044 # 800080c8 <digits+0x88>
    800028d4:	ffffe097          	auipc	ra,0xffffe
    800028d8:	ca6080e7          	jalr	-858(ra) # 8000057a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800028dc:	0000f497          	auipc	s1,0xf
    800028e0:	05c48493          	addi	s1,s1,92 # 80011938 <proc+0x158>
    800028e4:	00015917          	auipc	s2,0x15
    800028e8:	a5490913          	addi	s2,s2,-1452 # 80017338 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028ec:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800028ee:	00006997          	auipc	s3,0x6
    800028f2:	97a98993          	addi	s3,s3,-1670 # 80008268 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    800028f6:	00006a97          	auipc	s5,0x6
    800028fa:	97aa8a93          	addi	s5,s5,-1670 # 80008270 <digits+0x230>
    printf("\n");
    800028fe:	00005a17          	auipc	s4,0x5
    80002902:	7caa0a13          	addi	s4,s4,1994 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002906:	00006b97          	auipc	s7,0x6
    8000290a:	9a2b8b93          	addi	s7,s7,-1630 # 800082a8 <states.1773>
    8000290e:	a00d                	j	80002930 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80002910:	ed86a583          	lw	a1,-296(a3)
    80002914:	8556                	mv	a0,s5
    80002916:	ffffe097          	auipc	ra,0xffffe
    8000291a:	c64080e7          	jalr	-924(ra) # 8000057a <printf>
    printf("\n");
    8000291e:	8552                	mv	a0,s4
    80002920:	ffffe097          	auipc	ra,0xffffe
    80002924:	c5a080e7          	jalr	-934(ra) # 8000057a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002928:	16848493          	addi	s1,s1,360
    8000292c:	03248163          	beq	s1,s2,8000294e <procdump+0x98>
    if(p->state == UNUSED)
    80002930:	86a6                	mv	a3,s1
    80002932:	ec04a783          	lw	a5,-320(s1)
    80002936:	dbed                	beqz	a5,80002928 <procdump+0x72>
      state = "???";
    80002938:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000293a:	fcfb6be3          	bltu	s6,a5,80002910 <procdump+0x5a>
    8000293e:	1782                	slli	a5,a5,0x20
    80002940:	9381                	srli	a5,a5,0x20
    80002942:	078e                	slli	a5,a5,0x3
    80002944:	97de                	add	a5,a5,s7
    80002946:	6390                	ld	a2,0(a5)
    80002948:	f661                	bnez	a2,80002910 <procdump+0x5a>
      state = "???";
    8000294a:	864e                	mv	a2,s3
    8000294c:	b7d1                	j	80002910 <procdump+0x5a>
  }
    8000294e:	60a6                	ld	ra,72(sp)
    80002950:	6406                	ld	s0,64(sp)
    80002952:	74e2                	ld	s1,56(sp)
    80002954:	7942                	ld	s2,48(sp)
    80002956:	79a2                	ld	s3,40(sp)
    80002958:	7a02                	ld	s4,32(sp)
    8000295a:	6ae2                	ld	s5,24(sp)
    8000295c:	6b42                	ld	s6,16(sp)
    8000295e:	6ba2                	ld	s7,8(sp)
    80002960:	6161                	addi	sp,sp,80
    80002962:	8082                	ret

0000000080002964 <swtch>:
    80002964:	00153023          	sd	ra,0(a0)
    80002968:	00253423          	sd	sp,8(a0)
    8000296c:	e900                	sd	s0,16(a0)
    8000296e:	ed04                	sd	s1,24(a0)
    80002970:	03253023          	sd	s2,32(a0)
    80002974:	03353423          	sd	s3,40(a0)
    80002978:	03453823          	sd	s4,48(a0)
    8000297c:	03553c23          	sd	s5,56(a0)
    80002980:	05653023          	sd	s6,64(a0)
    80002984:	05753423          	sd	s7,72(a0)
    80002988:	05853823          	sd	s8,80(a0)
    8000298c:	05953c23          	sd	s9,88(a0)
    80002990:	07a53023          	sd	s10,96(a0)
    80002994:	07b53423          	sd	s11,104(a0)
    80002998:	0005b083          	ld	ra,0(a1)
    8000299c:	0085b103          	ld	sp,8(a1)
    800029a0:	6980                	ld	s0,16(a1)
    800029a2:	6d84                	ld	s1,24(a1)
    800029a4:	0205b903          	ld	s2,32(a1)
    800029a8:	0285b983          	ld	s3,40(a1)
    800029ac:	0305ba03          	ld	s4,48(a1)
    800029b0:	0385ba83          	ld	s5,56(a1)
    800029b4:	0405bb03          	ld	s6,64(a1)
    800029b8:	0485bb83          	ld	s7,72(a1)
    800029bc:	0505bc03          	ld	s8,80(a1)
    800029c0:	0585bc83          	ld	s9,88(a1)
    800029c4:	0605bd03          	ld	s10,96(a1)
    800029c8:	0685bd83          	ld	s11,104(a1)
    800029cc:	8082                	ret

00000000800029ce <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800029ce:	1141                	addi	sp,sp,-16
    800029d0:	e406                	sd	ra,8(sp)
    800029d2:	e022                	sd	s0,0(sp)
    800029d4:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800029d6:	00006597          	auipc	a1,0x6
    800029da:	90258593          	addi	a1,a1,-1790 # 800082d8 <states.1773+0x30>
    800029de:	00015517          	auipc	a0,0x15
    800029e2:	80250513          	addi	a0,a0,-2046 # 800171e0 <tickslock>
    800029e6:	ffffe097          	auipc	ra,0xffffe
    800029ea:	15c080e7          	jalr	348(ra) # 80000b42 <initlock>
}
    800029ee:	60a2                	ld	ra,8(sp)
    800029f0:	6402                	ld	s0,0(sp)
    800029f2:	0141                	addi	sp,sp,16
    800029f4:	8082                	ret

00000000800029f6 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800029f6:	1141                	addi	sp,sp,-16
    800029f8:	e422                	sd	s0,8(sp)
    800029fa:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029fc:	00003797          	auipc	a5,0x3
    80002a00:	58478793          	addi	a5,a5,1412 # 80005f80 <kernelvec>
    80002a04:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002a08:	6422                	ld	s0,8(sp)
    80002a0a:	0141                	addi	sp,sp,16
    80002a0c:	8082                	ret

0000000080002a0e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002a0e:	1141                	addi	sp,sp,-16
    80002a10:	e406                	sd	ra,8(sp)
    80002a12:	e022                	sd	s0,0(sp)
    80002a14:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a16:	fffff097          	auipc	ra,0xfffff
    80002a1a:	06c080e7          	jalr	108(ra) # 80001a82 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a1e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002a22:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a24:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002a28:	00004617          	auipc	a2,0x4
    80002a2c:	5d860613          	addi	a2,a2,1496 # 80007000 <_trampoline>
    80002a30:	00004697          	auipc	a3,0x4
    80002a34:	5d068693          	addi	a3,a3,1488 # 80007000 <_trampoline>
    80002a38:	8e91                	sub	a3,a3,a2
    80002a3a:	040007b7          	lui	a5,0x4000
    80002a3e:	17fd                	addi	a5,a5,-1
    80002a40:	07b2                	slli	a5,a5,0xc
    80002a42:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a44:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a48:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a4a:	180026f3          	csrr	a3,satp
    80002a4e:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a50:	6d38                	ld	a4,88(a0)
    80002a52:	6134                	ld	a3,64(a0)
    80002a54:	6585                	lui	a1,0x1
    80002a56:	96ae                	add	a3,a3,a1
    80002a58:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a5a:	6d38                	ld	a4,88(a0)
    80002a5c:	00000697          	auipc	a3,0x0
    80002a60:	13868693          	addi	a3,a3,312 # 80002b94 <usertrap>
    80002a64:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a66:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a68:	8692                	mv	a3,tp
    80002a6a:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a6c:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a70:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a74:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a78:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a7c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a7e:	6f18                	ld	a4,24(a4)
    80002a80:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a84:	692c                	ld	a1,80(a0)
    80002a86:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002a88:	00004717          	auipc	a4,0x4
    80002a8c:	60870713          	addi	a4,a4,1544 # 80007090 <userret>
    80002a90:	8f11                	sub	a4,a4,a2
    80002a92:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002a94:	577d                	li	a4,-1
    80002a96:	177e                	slli	a4,a4,0x3f
    80002a98:	8dd9                	or	a1,a1,a4
    80002a9a:	02000537          	lui	a0,0x2000
    80002a9e:	157d                	addi	a0,a0,-1
    80002aa0:	0536                	slli	a0,a0,0xd
    80002aa2:	9782                	jalr	a5
}
    80002aa4:	60a2                	ld	ra,8(sp)
    80002aa6:	6402                	ld	s0,0(sp)
    80002aa8:	0141                	addi	sp,sp,16
    80002aaa:	8082                	ret

0000000080002aac <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002aac:	1101                	addi	sp,sp,-32
    80002aae:	ec06                	sd	ra,24(sp)
    80002ab0:	e822                	sd	s0,16(sp)
    80002ab2:	e426                	sd	s1,8(sp)
    80002ab4:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002ab6:	00014497          	auipc	s1,0x14
    80002aba:	72a48493          	addi	s1,s1,1834 # 800171e0 <tickslock>
    80002abe:	8526                	mv	a0,s1
    80002ac0:	ffffe097          	auipc	ra,0xffffe
    80002ac4:	112080e7          	jalr	274(ra) # 80000bd2 <acquire>
  ticks++;
    80002ac8:	00006517          	auipc	a0,0x6
    80002acc:	56c50513          	addi	a0,a0,1388 # 80009034 <ticks>
    80002ad0:	411c                	lw	a5,0(a0)
    80002ad2:	2785                	addiw	a5,a5,1
    80002ad4:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002ad6:	00000097          	auipc	ra,0x0
    80002ada:	a9c080e7          	jalr	-1380(ra) # 80002572 <wakeup>
  release(&tickslock);
    80002ade:	8526                	mv	a0,s1
    80002ae0:	ffffe097          	auipc	ra,0xffffe
    80002ae4:	1a6080e7          	jalr	422(ra) # 80000c86 <release>
}
    80002ae8:	60e2                	ld	ra,24(sp)
    80002aea:	6442                	ld	s0,16(sp)
    80002aec:	64a2                	ld	s1,8(sp)
    80002aee:	6105                	addi	sp,sp,32
    80002af0:	8082                	ret

0000000080002af2 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002af2:	1101                	addi	sp,sp,-32
    80002af4:	ec06                	sd	ra,24(sp)
    80002af6:	e822                	sd	s0,16(sp)
    80002af8:	e426                	sd	s1,8(sp)
    80002afa:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002afc:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80002b00:	00074d63          	bltz	a4,80002b1a <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80002b04:	57fd                	li	a5,-1
    80002b06:	17fe                	slli	a5,a5,0x3f
    80002b08:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002b0a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002b0c:	06f70363          	beq	a4,a5,80002b72 <devintr+0x80>
  }
}
    80002b10:	60e2                	ld	ra,24(sp)
    80002b12:	6442                	ld	s0,16(sp)
    80002b14:	64a2                	ld	s1,8(sp)
    80002b16:	6105                	addi	sp,sp,32
    80002b18:	8082                	ret
     (scause & 0xff) == 9){
    80002b1a:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80002b1e:	46a5                	li	a3,9
    80002b20:	fed792e3          	bne	a5,a3,80002b04 <devintr+0x12>
    int irq = plic_claim();
    80002b24:	00003097          	auipc	ra,0x3
    80002b28:	564080e7          	jalr	1380(ra) # 80006088 <plic_claim>
    80002b2c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002b2e:	47a9                	li	a5,10
    80002b30:	02f50763          	beq	a0,a5,80002b5e <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002b34:	4785                	li	a5,1
    80002b36:	02f50963          	beq	a0,a5,80002b68 <devintr+0x76>
    return 1;
    80002b3a:	4505                	li	a0,1
    } else if(irq){
    80002b3c:	d8f1                	beqz	s1,80002b10 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b3e:	85a6                	mv	a1,s1
    80002b40:	00005517          	auipc	a0,0x5
    80002b44:	7a050513          	addi	a0,a0,1952 # 800082e0 <states.1773+0x38>
    80002b48:	ffffe097          	auipc	ra,0xffffe
    80002b4c:	a32080e7          	jalr	-1486(ra) # 8000057a <printf>
      plic_complete(irq);
    80002b50:	8526                	mv	a0,s1
    80002b52:	00003097          	auipc	ra,0x3
    80002b56:	55a080e7          	jalr	1370(ra) # 800060ac <plic_complete>
    return 1;
    80002b5a:	4505                	li	a0,1
    80002b5c:	bf55                	j	80002b10 <devintr+0x1e>
      uartintr();
    80002b5e:	ffffe097          	auipc	ra,0xffffe
    80002b62:	e38080e7          	jalr	-456(ra) # 80000996 <uartintr>
    80002b66:	b7ed                	j	80002b50 <devintr+0x5e>
      virtio_disk_intr();
    80002b68:	00004097          	auipc	ra,0x4
    80002b6c:	a24080e7          	jalr	-1500(ra) # 8000658c <virtio_disk_intr>
    80002b70:	b7c5                	j	80002b50 <devintr+0x5e>
    if(cpuid() == 0){
    80002b72:	fffff097          	auipc	ra,0xfffff
    80002b76:	ee4080e7          	jalr	-284(ra) # 80001a56 <cpuid>
    80002b7a:	c901                	beqz	a0,80002b8a <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002b7c:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002b80:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002b82:	14479073          	csrw	sip,a5
    return 2;
    80002b86:	4509                	li	a0,2
    80002b88:	b761                	j	80002b10 <devintr+0x1e>
      clockintr();
    80002b8a:	00000097          	auipc	ra,0x0
    80002b8e:	f22080e7          	jalr	-222(ra) # 80002aac <clockintr>
    80002b92:	b7ed                	j	80002b7c <devintr+0x8a>

0000000080002b94 <usertrap>:
{
    80002b94:	1101                	addi	sp,sp,-32
    80002b96:	ec06                	sd	ra,24(sp)
    80002b98:	e822                	sd	s0,16(sp)
    80002b9a:	e426                	sd	s1,8(sp)
    80002b9c:	e04a                	sd	s2,0(sp)
    80002b9e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ba0:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002ba4:	1007f793          	andi	a5,a5,256
    80002ba8:	e3ad                	bnez	a5,80002c0a <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002baa:	00003797          	auipc	a5,0x3
    80002bae:	3d678793          	addi	a5,a5,982 # 80005f80 <kernelvec>
    80002bb2:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002bb6:	fffff097          	auipc	ra,0xfffff
    80002bba:	ecc080e7          	jalr	-308(ra) # 80001a82 <myproc>
    80002bbe:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002bc0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bc2:	14102773          	csrr	a4,sepc
    80002bc6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bc8:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002bcc:	47a1                	li	a5,8
    80002bce:	04f71c63          	bne	a4,a5,80002c26 <usertrap+0x92>
    if(p->killed)
    80002bd2:	551c                	lw	a5,40(a0)
    80002bd4:	e3b9                	bnez	a5,80002c1a <usertrap+0x86>
    p->trapframe->epc += 4;
    80002bd6:	6cb8                	ld	a4,88(s1)
    80002bd8:	6f1c                	ld	a5,24(a4)
    80002bda:	0791                	addi	a5,a5,4
    80002bdc:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bde:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002be2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002be6:	10079073          	csrw	sstatus,a5
    syscall();
    80002bea:	00000097          	auipc	ra,0x0
    80002bee:	2e0080e7          	jalr	736(ra) # 80002eca <syscall>
  if(p->killed)
    80002bf2:	549c                	lw	a5,40(s1)
    80002bf4:	ebc1                	bnez	a5,80002c84 <usertrap+0xf0>
  usertrapret();
    80002bf6:	00000097          	auipc	ra,0x0
    80002bfa:	e18080e7          	jalr	-488(ra) # 80002a0e <usertrapret>
}
    80002bfe:	60e2                	ld	ra,24(sp)
    80002c00:	6442                	ld	s0,16(sp)
    80002c02:	64a2                	ld	s1,8(sp)
    80002c04:	6902                	ld	s2,0(sp)
    80002c06:	6105                	addi	sp,sp,32
    80002c08:	8082                	ret
    panic("usertrap: not from user mode");
    80002c0a:	00005517          	auipc	a0,0x5
    80002c0e:	6f650513          	addi	a0,a0,1782 # 80008300 <states.1773+0x58>
    80002c12:	ffffe097          	auipc	ra,0xffffe
    80002c16:	91e080e7          	jalr	-1762(ra) # 80000530 <panic>
      exit(-1);
    80002c1a:	557d                	li	a0,-1
    80002c1c:	00000097          	auipc	ra,0x0
    80002c20:	a4a080e7          	jalr	-1462(ra) # 80002666 <exit>
    80002c24:	bf4d                	j	80002bd6 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002c26:	00000097          	auipc	ra,0x0
    80002c2a:	ecc080e7          	jalr	-308(ra) # 80002af2 <devintr>
    80002c2e:	892a                	mv	s2,a0
    80002c30:	c501                	beqz	a0,80002c38 <usertrap+0xa4>
  if(p->killed)
    80002c32:	549c                	lw	a5,40(s1)
    80002c34:	c3a1                	beqz	a5,80002c74 <usertrap+0xe0>
    80002c36:	a815                	j	80002c6a <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c38:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002c3c:	5890                	lw	a2,48(s1)
    80002c3e:	00005517          	auipc	a0,0x5
    80002c42:	6e250513          	addi	a0,a0,1762 # 80008320 <states.1773+0x78>
    80002c46:	ffffe097          	auipc	ra,0xffffe
    80002c4a:	934080e7          	jalr	-1740(ra) # 8000057a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c4e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c52:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002c56:	00005517          	auipc	a0,0x5
    80002c5a:	6fa50513          	addi	a0,a0,1786 # 80008350 <states.1773+0xa8>
    80002c5e:	ffffe097          	auipc	ra,0xffffe
    80002c62:	91c080e7          	jalr	-1764(ra) # 8000057a <printf>
    p->killed = 1;
    80002c66:	4785                	li	a5,1
    80002c68:	d49c                	sw	a5,40(s1)
    exit(-1);
    80002c6a:	557d                	li	a0,-1
    80002c6c:	00000097          	auipc	ra,0x0
    80002c70:	9fa080e7          	jalr	-1542(ra) # 80002666 <exit>
  if(which_dev == 2)
    80002c74:	4789                	li	a5,2
    80002c76:	f8f910e3          	bne	s2,a5,80002bf6 <usertrap+0x62>
    yield();
    80002c7a:	fffff097          	auipc	ra,0xfffff
    80002c7e:	610080e7          	jalr	1552(ra) # 8000228a <yield>
    80002c82:	bf95                	j	80002bf6 <usertrap+0x62>
  int which_dev = 0;
    80002c84:	4901                	li	s2,0
    80002c86:	b7d5                	j	80002c6a <usertrap+0xd6>

0000000080002c88 <kerneltrap>:
{
    80002c88:	7179                	addi	sp,sp,-48
    80002c8a:	f406                	sd	ra,40(sp)
    80002c8c:	f022                	sd	s0,32(sp)
    80002c8e:	ec26                	sd	s1,24(sp)
    80002c90:	e84a                	sd	s2,16(sp)
    80002c92:	e44e                	sd	s3,8(sp)
    80002c94:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c96:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c9a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c9e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002ca2:	1004f793          	andi	a5,s1,256
    80002ca6:	cb85                	beqz	a5,80002cd6 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ca8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002cac:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002cae:	ef85                	bnez	a5,80002ce6 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002cb0:	00000097          	auipc	ra,0x0
    80002cb4:	e42080e7          	jalr	-446(ra) # 80002af2 <devintr>
    80002cb8:	cd1d                	beqz	a0,80002cf6 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002cba:	4789                	li	a5,2
    80002cbc:	06f50a63          	beq	a0,a5,80002d30 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002cc0:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cc4:	10049073          	csrw	sstatus,s1
}
    80002cc8:	70a2                	ld	ra,40(sp)
    80002cca:	7402                	ld	s0,32(sp)
    80002ccc:	64e2                	ld	s1,24(sp)
    80002cce:	6942                	ld	s2,16(sp)
    80002cd0:	69a2                	ld	s3,8(sp)
    80002cd2:	6145                	addi	sp,sp,48
    80002cd4:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002cd6:	00005517          	auipc	a0,0x5
    80002cda:	69a50513          	addi	a0,a0,1690 # 80008370 <states.1773+0xc8>
    80002cde:	ffffe097          	auipc	ra,0xffffe
    80002ce2:	852080e7          	jalr	-1966(ra) # 80000530 <panic>
    panic("kerneltrap: interrupts enabled");
    80002ce6:	00005517          	auipc	a0,0x5
    80002cea:	6b250513          	addi	a0,a0,1714 # 80008398 <states.1773+0xf0>
    80002cee:	ffffe097          	auipc	ra,0xffffe
    80002cf2:	842080e7          	jalr	-1982(ra) # 80000530 <panic>
    printf("scause %p\n", scause);
    80002cf6:	85ce                	mv	a1,s3
    80002cf8:	00005517          	auipc	a0,0x5
    80002cfc:	6c050513          	addi	a0,a0,1728 # 800083b8 <states.1773+0x110>
    80002d00:	ffffe097          	auipc	ra,0xffffe
    80002d04:	87a080e7          	jalr	-1926(ra) # 8000057a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d08:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d0c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d10:	00005517          	auipc	a0,0x5
    80002d14:	6b850513          	addi	a0,a0,1720 # 800083c8 <states.1773+0x120>
    80002d18:	ffffe097          	auipc	ra,0xffffe
    80002d1c:	862080e7          	jalr	-1950(ra) # 8000057a <printf>
    panic("kerneltrap");
    80002d20:	00005517          	auipc	a0,0x5
    80002d24:	6c050513          	addi	a0,a0,1728 # 800083e0 <states.1773+0x138>
    80002d28:	ffffe097          	auipc	ra,0xffffe
    80002d2c:	808080e7          	jalr	-2040(ra) # 80000530 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002d30:	fffff097          	auipc	ra,0xfffff
    80002d34:	d52080e7          	jalr	-686(ra) # 80001a82 <myproc>
    80002d38:	d541                	beqz	a0,80002cc0 <kerneltrap+0x38>
    80002d3a:	fffff097          	auipc	ra,0xfffff
    80002d3e:	d48080e7          	jalr	-696(ra) # 80001a82 <myproc>
    80002d42:	4d18                	lw	a4,24(a0)
    80002d44:	4791                	li	a5,4
    80002d46:	f6f71de3          	bne	a4,a5,80002cc0 <kerneltrap+0x38>
    yield();
    80002d4a:	fffff097          	auipc	ra,0xfffff
    80002d4e:	540080e7          	jalr	1344(ra) # 8000228a <yield>
    80002d52:	b7bd                	j	80002cc0 <kerneltrap+0x38>

0000000080002d54 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d54:	1101                	addi	sp,sp,-32
    80002d56:	ec06                	sd	ra,24(sp)
    80002d58:	e822                	sd	s0,16(sp)
    80002d5a:	e426                	sd	s1,8(sp)
    80002d5c:	1000                	addi	s0,sp,32
    80002d5e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d60:	fffff097          	auipc	ra,0xfffff
    80002d64:	d22080e7          	jalr	-734(ra) # 80001a82 <myproc>
  switch (n) {
    80002d68:	4795                	li	a5,5
    80002d6a:	0497e163          	bltu	a5,s1,80002dac <argraw+0x58>
    80002d6e:	048a                	slli	s1,s1,0x2
    80002d70:	00005717          	auipc	a4,0x5
    80002d74:	6a870713          	addi	a4,a4,1704 # 80008418 <states.1773+0x170>
    80002d78:	94ba                	add	s1,s1,a4
    80002d7a:	409c                	lw	a5,0(s1)
    80002d7c:	97ba                	add	a5,a5,a4
    80002d7e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d80:	6d3c                	ld	a5,88(a0)
    80002d82:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d84:	60e2                	ld	ra,24(sp)
    80002d86:	6442                	ld	s0,16(sp)
    80002d88:	64a2                	ld	s1,8(sp)
    80002d8a:	6105                	addi	sp,sp,32
    80002d8c:	8082                	ret
    return p->trapframe->a1;
    80002d8e:	6d3c                	ld	a5,88(a0)
    80002d90:	7fa8                	ld	a0,120(a5)
    80002d92:	bfcd                	j	80002d84 <argraw+0x30>
    return p->trapframe->a2;
    80002d94:	6d3c                	ld	a5,88(a0)
    80002d96:	63c8                	ld	a0,128(a5)
    80002d98:	b7f5                	j	80002d84 <argraw+0x30>
    return p->trapframe->a3;
    80002d9a:	6d3c                	ld	a5,88(a0)
    80002d9c:	67c8                	ld	a0,136(a5)
    80002d9e:	b7dd                	j	80002d84 <argraw+0x30>
    return p->trapframe->a4;
    80002da0:	6d3c                	ld	a5,88(a0)
    80002da2:	6bc8                	ld	a0,144(a5)
    80002da4:	b7c5                	j	80002d84 <argraw+0x30>
    return p->trapframe->a5;
    80002da6:	6d3c                	ld	a5,88(a0)
    80002da8:	6fc8                	ld	a0,152(a5)
    80002daa:	bfe9                	j	80002d84 <argraw+0x30>
  panic("argraw");
    80002dac:	00005517          	auipc	a0,0x5
    80002db0:	64450513          	addi	a0,a0,1604 # 800083f0 <states.1773+0x148>
    80002db4:	ffffd097          	auipc	ra,0xffffd
    80002db8:	77c080e7          	jalr	1916(ra) # 80000530 <panic>

0000000080002dbc <fetchaddr>:
{
    80002dbc:	1101                	addi	sp,sp,-32
    80002dbe:	ec06                	sd	ra,24(sp)
    80002dc0:	e822                	sd	s0,16(sp)
    80002dc2:	e426                	sd	s1,8(sp)
    80002dc4:	e04a                	sd	s2,0(sp)
    80002dc6:	1000                	addi	s0,sp,32
    80002dc8:	84aa                	mv	s1,a0
    80002dca:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002dcc:	fffff097          	auipc	ra,0xfffff
    80002dd0:	cb6080e7          	jalr	-842(ra) # 80001a82 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002dd4:	653c                	ld	a5,72(a0)
    80002dd6:	02f4f863          	bgeu	s1,a5,80002e06 <fetchaddr+0x4a>
    80002dda:	00848713          	addi	a4,s1,8
    80002dde:	02e7e663          	bltu	a5,a4,80002e0a <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002de2:	46a1                	li	a3,8
    80002de4:	8626                	mv	a2,s1
    80002de6:	85ca                	mv	a1,s2
    80002de8:	6928                	ld	a0,80(a0)
    80002dea:	fffff097          	auipc	ra,0xfffff
    80002dee:	8f4080e7          	jalr	-1804(ra) # 800016de <copyin>
    80002df2:	00a03533          	snez	a0,a0
    80002df6:	40a00533          	neg	a0,a0
}
    80002dfa:	60e2                	ld	ra,24(sp)
    80002dfc:	6442                	ld	s0,16(sp)
    80002dfe:	64a2                	ld	s1,8(sp)
    80002e00:	6902                	ld	s2,0(sp)
    80002e02:	6105                	addi	sp,sp,32
    80002e04:	8082                	ret
    return -1;
    80002e06:	557d                	li	a0,-1
    80002e08:	bfcd                	j	80002dfa <fetchaddr+0x3e>
    80002e0a:	557d                	li	a0,-1
    80002e0c:	b7fd                	j	80002dfa <fetchaddr+0x3e>

0000000080002e0e <fetchstr>:
{
    80002e0e:	7179                	addi	sp,sp,-48
    80002e10:	f406                	sd	ra,40(sp)
    80002e12:	f022                	sd	s0,32(sp)
    80002e14:	ec26                	sd	s1,24(sp)
    80002e16:	e84a                	sd	s2,16(sp)
    80002e18:	e44e                	sd	s3,8(sp)
    80002e1a:	1800                	addi	s0,sp,48
    80002e1c:	892a                	mv	s2,a0
    80002e1e:	84ae                	mv	s1,a1
    80002e20:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e22:	fffff097          	auipc	ra,0xfffff
    80002e26:	c60080e7          	jalr	-928(ra) # 80001a82 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002e2a:	86ce                	mv	a3,s3
    80002e2c:	864a                	mv	a2,s2
    80002e2e:	85a6                	mv	a1,s1
    80002e30:	6928                	ld	a0,80(a0)
    80002e32:	fffff097          	auipc	ra,0xfffff
    80002e36:	938080e7          	jalr	-1736(ra) # 8000176a <copyinstr>
  if(err < 0)
    80002e3a:	00054763          	bltz	a0,80002e48 <fetchstr+0x3a>
  return strlen(buf);
    80002e3e:	8526                	mv	a0,s1
    80002e40:	ffffe097          	auipc	ra,0xffffe
    80002e44:	016080e7          	jalr	22(ra) # 80000e56 <strlen>
}
    80002e48:	70a2                	ld	ra,40(sp)
    80002e4a:	7402                	ld	s0,32(sp)
    80002e4c:	64e2                	ld	s1,24(sp)
    80002e4e:	6942                	ld	s2,16(sp)
    80002e50:	69a2                	ld	s3,8(sp)
    80002e52:	6145                	addi	sp,sp,48
    80002e54:	8082                	ret

0000000080002e56 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002e56:	1101                	addi	sp,sp,-32
    80002e58:	ec06                	sd	ra,24(sp)
    80002e5a:	e822                	sd	s0,16(sp)
    80002e5c:	e426                	sd	s1,8(sp)
    80002e5e:	1000                	addi	s0,sp,32
    80002e60:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e62:	00000097          	auipc	ra,0x0
    80002e66:	ef2080e7          	jalr	-270(ra) # 80002d54 <argraw>
    80002e6a:	c088                	sw	a0,0(s1)
  return 0;
}
    80002e6c:	4501                	li	a0,0
    80002e6e:	60e2                	ld	ra,24(sp)
    80002e70:	6442                	ld	s0,16(sp)
    80002e72:	64a2                	ld	s1,8(sp)
    80002e74:	6105                	addi	sp,sp,32
    80002e76:	8082                	ret

0000000080002e78 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002e78:	1101                	addi	sp,sp,-32
    80002e7a:	ec06                	sd	ra,24(sp)
    80002e7c:	e822                	sd	s0,16(sp)
    80002e7e:	e426                	sd	s1,8(sp)
    80002e80:	1000                	addi	s0,sp,32
    80002e82:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e84:	00000097          	auipc	ra,0x0
    80002e88:	ed0080e7          	jalr	-304(ra) # 80002d54 <argraw>
    80002e8c:	e088                	sd	a0,0(s1)
  return 0;
}
    80002e8e:	4501                	li	a0,0
    80002e90:	60e2                	ld	ra,24(sp)
    80002e92:	6442                	ld	s0,16(sp)
    80002e94:	64a2                	ld	s1,8(sp)
    80002e96:	6105                	addi	sp,sp,32
    80002e98:	8082                	ret

0000000080002e9a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e9a:	1101                	addi	sp,sp,-32
    80002e9c:	ec06                	sd	ra,24(sp)
    80002e9e:	e822                	sd	s0,16(sp)
    80002ea0:	e426                	sd	s1,8(sp)
    80002ea2:	e04a                	sd	s2,0(sp)
    80002ea4:	1000                	addi	s0,sp,32
    80002ea6:	84ae                	mv	s1,a1
    80002ea8:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002eaa:	00000097          	auipc	ra,0x0
    80002eae:	eaa080e7          	jalr	-342(ra) # 80002d54 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002eb2:	864a                	mv	a2,s2
    80002eb4:	85a6                	mv	a1,s1
    80002eb6:	00000097          	auipc	ra,0x0
    80002eba:	f58080e7          	jalr	-168(ra) # 80002e0e <fetchstr>
}
    80002ebe:	60e2                	ld	ra,24(sp)
    80002ec0:	6442                	ld	s0,16(sp)
    80002ec2:	64a2                	ld	s1,8(sp)
    80002ec4:	6902                	ld	s2,0(sp)
    80002ec6:	6105                	addi	sp,sp,32
    80002ec8:	8082                	ret

0000000080002eca <syscall>:
[SYS_getpstat]  sys_getpstat,
};

void
syscall(void)
{
    80002eca:	1101                	addi	sp,sp,-32
    80002ecc:	ec06                	sd	ra,24(sp)
    80002ece:	e822                	sd	s0,16(sp)
    80002ed0:	e426                	sd	s1,8(sp)
    80002ed2:	e04a                	sd	s2,0(sp)
    80002ed4:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002ed6:	fffff097          	auipc	ra,0xfffff
    80002eda:	bac080e7          	jalr	-1108(ra) # 80001a82 <myproc>
    80002ede:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ee0:	05853903          	ld	s2,88(a0)
    80002ee4:	0a893783          	ld	a5,168(s2)
    80002ee8:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002eec:	37fd                	addiw	a5,a5,-1
    80002eee:	4755                	li	a4,21
    80002ef0:	00f76f63          	bltu	a4,a5,80002f0e <syscall+0x44>
    80002ef4:	00369713          	slli	a4,a3,0x3
    80002ef8:	00005797          	auipc	a5,0x5
    80002efc:	53878793          	addi	a5,a5,1336 # 80008430 <syscalls>
    80002f00:	97ba                	add	a5,a5,a4
    80002f02:	639c                	ld	a5,0(a5)
    80002f04:	c789                	beqz	a5,80002f0e <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002f06:	9782                	jalr	a5
    80002f08:	06a93823          	sd	a0,112(s2)
    80002f0c:	a839                	j	80002f2a <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002f0e:	15848613          	addi	a2,s1,344
    80002f12:	588c                	lw	a1,48(s1)
    80002f14:	00005517          	auipc	a0,0x5
    80002f18:	4e450513          	addi	a0,a0,1252 # 800083f8 <states.1773+0x150>
    80002f1c:	ffffd097          	auipc	ra,0xffffd
    80002f20:	65e080e7          	jalr	1630(ra) # 8000057a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002f24:	6cbc                	ld	a5,88(s1)
    80002f26:	577d                	li	a4,-1
    80002f28:	fbb8                	sd	a4,112(a5)
  }
}
    80002f2a:	60e2                	ld	ra,24(sp)
    80002f2c:	6442                	ld	s0,16(sp)
    80002f2e:	64a2                	ld	s1,8(sp)
    80002f30:	6902                	ld	s2,0(sp)
    80002f32:	6105                	addi	sp,sp,32
    80002f34:	8082                	ret

0000000080002f36 <sys_exit>:
#include "proc.h"
#include "pstat.h"

uint64
sys_exit(void)
{
    80002f36:	1101                	addi	sp,sp,-32
    80002f38:	ec06                	sd	ra,24(sp)
    80002f3a:	e822                	sd	s0,16(sp)
    80002f3c:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002f3e:	fec40593          	addi	a1,s0,-20
    80002f42:	4501                	li	a0,0
    80002f44:	00000097          	auipc	ra,0x0
    80002f48:	f12080e7          	jalr	-238(ra) # 80002e56 <argint>
    return -1;
    80002f4c:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002f4e:	00054963          	bltz	a0,80002f60 <sys_exit+0x2a>
  exit(n);
    80002f52:	fec42503          	lw	a0,-20(s0)
    80002f56:	fffff097          	auipc	ra,0xfffff
    80002f5a:	710080e7          	jalr	1808(ra) # 80002666 <exit>
  return 0;  // not reached
    80002f5e:	4781                	li	a5,0
}
    80002f60:	853e                	mv	a0,a5
    80002f62:	60e2                	ld	ra,24(sp)
    80002f64:	6442                	ld	s0,16(sp)
    80002f66:	6105                	addi	sp,sp,32
    80002f68:	8082                	ret

0000000080002f6a <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f6a:	1141                	addi	sp,sp,-16
    80002f6c:	e406                	sd	ra,8(sp)
    80002f6e:	e022                	sd	s0,0(sp)
    80002f70:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f72:	fffff097          	auipc	ra,0xfffff
    80002f76:	b10080e7          	jalr	-1264(ra) # 80001a82 <myproc>
}
    80002f7a:	5908                	lw	a0,48(a0)
    80002f7c:	60a2                	ld	ra,8(sp)
    80002f7e:	6402                	ld	s0,0(sp)
    80002f80:	0141                	addi	sp,sp,16
    80002f82:	8082                	ret

0000000080002f84 <sys_fork>:

uint64
sys_fork(void)
{
    80002f84:	1141                	addi	sp,sp,-16
    80002f86:	e406                	sd	ra,8(sp)
    80002f88:	e022                	sd	s0,0(sp)
    80002f8a:	0800                	addi	s0,sp,16
  return fork();
    80002f8c:	fffff097          	auipc	ra,0xfffff
    80002f90:	f06080e7          	jalr	-250(ra) # 80001e92 <fork>
}
    80002f94:	60a2                	ld	ra,8(sp)
    80002f96:	6402                	ld	s0,0(sp)
    80002f98:	0141                	addi	sp,sp,16
    80002f9a:	8082                	ret

0000000080002f9c <sys_wait>:

uint64
sys_wait(void)
{
    80002f9c:	1101                	addi	sp,sp,-32
    80002f9e:	ec06                	sd	ra,24(sp)
    80002fa0:	e822                	sd	s0,16(sp)
    80002fa2:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002fa4:	fe840593          	addi	a1,s0,-24
    80002fa8:	4501                	li	a0,0
    80002faa:	00000097          	auipc	ra,0x0
    80002fae:	ece080e7          	jalr	-306(ra) # 80002e78 <argaddr>
    80002fb2:	87aa                	mv	a5,a0
    return -1;
    80002fb4:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002fb6:	0007c863          	bltz	a5,80002fc6 <sys_wait+0x2a>
  return wait(p);
    80002fba:	fe843503          	ld	a0,-24(s0)
    80002fbe:	fffff097          	auipc	ra,0xfffff
    80002fc2:	48c080e7          	jalr	1164(ra) # 8000244a <wait>
}
    80002fc6:	60e2                	ld	ra,24(sp)
    80002fc8:	6442                	ld	s0,16(sp)
    80002fca:	6105                	addi	sp,sp,32
    80002fcc:	8082                	ret

0000000080002fce <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002fce:	7179                	addi	sp,sp,-48
    80002fd0:	f406                	sd	ra,40(sp)
    80002fd2:	f022                	sd	s0,32(sp)
    80002fd4:	ec26                	sd	s1,24(sp)
    80002fd6:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002fd8:	fdc40593          	addi	a1,s0,-36
    80002fdc:	4501                	li	a0,0
    80002fde:	00000097          	auipc	ra,0x0
    80002fe2:	e78080e7          	jalr	-392(ra) # 80002e56 <argint>
    80002fe6:	87aa                	mv	a5,a0
    return -1;
    80002fe8:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002fea:	0207c063          	bltz	a5,8000300a <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002fee:	fffff097          	auipc	ra,0xfffff
    80002ff2:	a94080e7          	jalr	-1388(ra) # 80001a82 <myproc>
    80002ff6:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002ff8:	fdc42503          	lw	a0,-36(s0)
    80002ffc:	fffff097          	auipc	ra,0xfffff
    80003000:	e22080e7          	jalr	-478(ra) # 80001e1e <growproc>
    80003004:	00054863          	bltz	a0,80003014 <sys_sbrk+0x46>
    return -1;
  return addr;
    80003008:	8526                	mv	a0,s1
}
    8000300a:	70a2                	ld	ra,40(sp)
    8000300c:	7402                	ld	s0,32(sp)
    8000300e:	64e2                	ld	s1,24(sp)
    80003010:	6145                	addi	sp,sp,48
    80003012:	8082                	ret
    return -1;
    80003014:	557d                	li	a0,-1
    80003016:	bfd5                	j	8000300a <sys_sbrk+0x3c>

0000000080003018 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003018:	7139                	addi	sp,sp,-64
    8000301a:	fc06                	sd	ra,56(sp)
    8000301c:	f822                	sd	s0,48(sp)
    8000301e:	f426                	sd	s1,40(sp)
    80003020:	f04a                	sd	s2,32(sp)
    80003022:	ec4e                	sd	s3,24(sp)
    80003024:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    80003026:	fcc40593          	addi	a1,s0,-52
    8000302a:	4501                	li	a0,0
    8000302c:	00000097          	auipc	ra,0x0
    80003030:	e2a080e7          	jalr	-470(ra) # 80002e56 <argint>
    return -1;
    80003034:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80003036:	06054563          	bltz	a0,800030a0 <sys_sleep+0x88>
  acquire(&tickslock);
    8000303a:	00014517          	auipc	a0,0x14
    8000303e:	1a650513          	addi	a0,a0,422 # 800171e0 <tickslock>
    80003042:	ffffe097          	auipc	ra,0xffffe
    80003046:	b90080e7          	jalr	-1136(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    8000304a:	00006917          	auipc	s2,0x6
    8000304e:	fea92903          	lw	s2,-22(s2) # 80009034 <ticks>
  while(ticks - ticks0 < n){
    80003052:	fcc42783          	lw	a5,-52(s0)
    80003056:	cf85                	beqz	a5,8000308e <sys_sleep+0x76>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003058:	00014997          	auipc	s3,0x14
    8000305c:	18898993          	addi	s3,s3,392 # 800171e0 <tickslock>
    80003060:	00006497          	auipc	s1,0x6
    80003064:	fd448493          	addi	s1,s1,-44 # 80009034 <ticks>
    if(myproc()->killed){
    80003068:	fffff097          	auipc	ra,0xfffff
    8000306c:	a1a080e7          	jalr	-1510(ra) # 80001a82 <myproc>
    80003070:	551c                	lw	a5,40(a0)
    80003072:	ef9d                	bnez	a5,800030b0 <sys_sleep+0x98>
    sleep(&ticks, &tickslock);
    80003074:	85ce                	mv	a1,s3
    80003076:	8526                	mv	a0,s1
    80003078:	fffff097          	auipc	ra,0xfffff
    8000307c:	36e080e7          	jalr	878(ra) # 800023e6 <sleep>
  while(ticks - ticks0 < n){
    80003080:	409c                	lw	a5,0(s1)
    80003082:	412787bb          	subw	a5,a5,s2
    80003086:	fcc42703          	lw	a4,-52(s0)
    8000308a:	fce7efe3          	bltu	a5,a4,80003068 <sys_sleep+0x50>
  }
  release(&tickslock);
    8000308e:	00014517          	auipc	a0,0x14
    80003092:	15250513          	addi	a0,a0,338 # 800171e0 <tickslock>
    80003096:	ffffe097          	auipc	ra,0xffffe
    8000309a:	bf0080e7          	jalr	-1040(ra) # 80000c86 <release>
  return 0;
    8000309e:	4781                	li	a5,0
}
    800030a0:	853e                	mv	a0,a5
    800030a2:	70e2                	ld	ra,56(sp)
    800030a4:	7442                	ld	s0,48(sp)
    800030a6:	74a2                	ld	s1,40(sp)
    800030a8:	7902                	ld	s2,32(sp)
    800030aa:	69e2                	ld	s3,24(sp)
    800030ac:	6121                	addi	sp,sp,64
    800030ae:	8082                	ret
      release(&tickslock);
    800030b0:	00014517          	auipc	a0,0x14
    800030b4:	13050513          	addi	a0,a0,304 # 800171e0 <tickslock>
    800030b8:	ffffe097          	auipc	ra,0xffffe
    800030bc:	bce080e7          	jalr	-1074(ra) # 80000c86 <release>
      return -1;
    800030c0:	57fd                	li	a5,-1
    800030c2:	bff9                	j	800030a0 <sys_sleep+0x88>

00000000800030c4 <sys_kill>:

uint64
sys_kill(void)
{
    800030c4:	1101                	addi	sp,sp,-32
    800030c6:	ec06                	sd	ra,24(sp)
    800030c8:	e822                	sd	s0,16(sp)
    800030ca:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    800030cc:	fec40593          	addi	a1,s0,-20
    800030d0:	4501                	li	a0,0
    800030d2:	00000097          	auipc	ra,0x0
    800030d6:	d84080e7          	jalr	-636(ra) # 80002e56 <argint>
    800030da:	87aa                	mv	a5,a0
    return -1;
    800030dc:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    800030de:	0007c863          	bltz	a5,800030ee <sys_kill+0x2a>
  return kill(pid);
    800030e2:	fec42503          	lw	a0,-20(s0)
    800030e6:	fffff097          	auipc	ra,0xfffff
    800030ea:	694080e7          	jalr	1684(ra) # 8000277a <kill>
}
    800030ee:	60e2                	ld	ra,24(sp)
    800030f0:	6442                	ld	s0,16(sp)
    800030f2:	6105                	addi	sp,sp,32
    800030f4:	8082                	ret

00000000800030f6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800030f6:	1101                	addi	sp,sp,-32
    800030f8:	ec06                	sd	ra,24(sp)
    800030fa:	e822                	sd	s0,16(sp)
    800030fc:	e426                	sd	s1,8(sp)
    800030fe:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003100:	00014517          	auipc	a0,0x14
    80003104:	0e050513          	addi	a0,a0,224 # 800171e0 <tickslock>
    80003108:	ffffe097          	auipc	ra,0xffffe
    8000310c:	aca080e7          	jalr	-1334(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80003110:	00006497          	auipc	s1,0x6
    80003114:	f244a483          	lw	s1,-220(s1) # 80009034 <ticks>
  release(&tickslock);
    80003118:	00014517          	auipc	a0,0x14
    8000311c:	0c850513          	addi	a0,a0,200 # 800171e0 <tickslock>
    80003120:	ffffe097          	auipc	ra,0xffffe
    80003124:	b66080e7          	jalr	-1178(ra) # 80000c86 <release>
  return xticks;
}
    80003128:	02049513          	slli	a0,s1,0x20
    8000312c:	9101                	srli	a0,a0,0x20
    8000312e:	60e2                	ld	ra,24(sp)
    80003130:	6442                	ld	s0,16(sp)
    80003132:	64a2                	ld	s1,8(sp)
    80003134:	6105                	addi	sp,sp,32
    80003136:	8082                	ret

0000000080003138 <kgetpstat>:

//helper function in sys_getpstat(void)
//get the right information in the process
//return 0 if success
uint64
kgetpstat(struct pstat* ps){
    80003138:	1101                	addi	sp,sp,-32
    8000313a:	ec06                	sd	ra,24(sp)
    8000313c:	e822                	sd	s0,16(sp)
    8000313e:	e426                	sd	s1,8(sp)
    80003140:	1000                	addi	s0,sp,32
    80003142:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80003144:	fffff097          	auipc	ra,0xfffff
    80003148:	93e080e7          	jalr	-1730(ra) # 80001a82 <myproc>
  if(p->state != 0){
    8000314c:	4d1c                	lw	a5,24(a0)
    8000314e:	cf91                	beqz	a5,8000316a <kgetpstat+0x32>
    80003150:	87a6                	mv	a5,s1
    for(int i=0;i<sizeof(ps->inuse);i++){
    80003152:	4701                	li	a4,0
      if(ps->inuse[i]<0){
    80003154:	0791                	addi	a5,a5,4
    80003156:	ffc7a683          	lw	a3,-4(a5)
    8000315a:	0006c463          	bltz	a3,80003162 <kgetpstat+0x2a>
    for(int i=0;i<sizeof(ps->inuse);i++){
    8000315e:	2705                	addiw	a4,a4,1
    80003160:	bfd5                	j	80003154 <kgetpstat+0x1c>
        ps->inuse[i] = 1;
    80003162:	070a                	slli	a4,a4,0x2
    80003164:	9726                	add	a4,a4,s1
    80003166:	4785                	li	a5,1
    80003168:	c31c                	sw	a5,0(a4)
        break;
      }
    }
  }
  for(int i=0;i<sizeof(ps->pid);i++){
    8000316a:	10048793          	addi	a5,s1,256
    8000316e:	4701                	li	a4,0
    if(ps->pid[i]<0 || ps->pid[i]>80000000){
    80003170:	04c4b637          	lui	a2,0x4c4b
    80003174:	40060613          	addi	a2,a2,1024 # 4c4b400 <_entry-0x7b3b4c00>
    80003178:	4394                	lw	a3,0(a5)
    8000317a:	0791                	addi	a5,a5,4
    8000317c:	00d66463          	bltu	a2,a3,80003184 <kgetpstat+0x4c>
  for(int i=0;i<sizeof(ps->pid);i++){
    80003180:	2705                	addiw	a4,a4,1
    80003182:	bfdd                	j	80003178 <kgetpstat+0x40>
       ps->pid[i] = p->pid;
    80003184:	591c                	lw	a5,48(a0)
    80003186:	04070713          	addi	a4,a4,64
    8000318a:	070a                	slli	a4,a4,0x2
    8000318c:	9726                	add	a4,a4,s1
    8000318e:	c31c                	sw	a5,0(a4)
       break;
    }
  }
  for(int i=0;i<sizeof(ps->ticks);i++){
    80003190:	20048793          	addi	a5,s1,512
    80003194:	4701                	li	a4,0
    if(ps->ticks[i]<0){
    80003196:	0791                	addi	a5,a5,4
    80003198:	ffc7a683          	lw	a3,-4(a5)
    8000319c:	0006c463          	bltz	a3,800031a4 <kgetpstat+0x6c>
  for(int i=0;i<sizeof(ps->ticks);i++){
    800031a0:	2705                	addiw	a4,a4,1
    800031a2:	bfd5                	j	80003196 <kgetpstat+0x5e>
      ps->ticks[i]=p->ticks;
    800031a4:	595c                	lw	a5,52(a0)
    800031a6:	08070713          	addi	a4,a4,128
    800031aa:	070a                	slli	a4,a4,0x2
    800031ac:	9726                	add	a4,a4,s1
    800031ae:	c31c                	sw	a5,0(a4)
      break;
    }
  }
    return 0;
}
    800031b0:	4501                	li	a0,0
    800031b2:	60e2                	ld	ra,24(sp)
    800031b4:	6442                	ld	s0,16(sp)
    800031b6:	64a2                	ld	s1,8(sp)
    800031b8:	6105                	addi	sp,sp,32
    800031ba:	8082                	ret

00000000800031bc <sys_getpstat>:


// update the userful information using helper function kgetpstat(struct pstat* ps)
uint64
sys_getpstat(void)
{
    800031bc:	bd010113          	addi	sp,sp,-1072
    800031c0:	42113423          	sd	ra,1064(sp)
    800031c4:	42813023          	sd	s0,1056(sp)
    800031c8:	40913c23          	sd	s1,1048(sp)
    800031cc:	41213823          	sd	s2,1040(sp)
    800031d0:	43010413          	addi	s0,sp,1072
  struct proc *p = myproc();
    800031d4:	fffff097          	auipc	ra,0xfffff
    800031d8:	8ae080e7          	jalr	-1874(ra) # 80001a82 <myproc>
    800031dc:	892a                	mv	s2,a0
  uint64 upstat; // user virtual address, pointing to a struct pstat
  struct pstat kpstat; // struct pstat in kernel memory
  // get system call argument
  if(argaddr(0, &upstat) < 0)
    800031de:	fd840593          	addi	a1,s0,-40
    800031e2:	4501                	li	a0,0
    800031e4:	00000097          	auipc	ra,0x0
    800031e8:	c94080e7          	jalr	-876(ra) # 80002e78 <argaddr>
    return -1;
    800031ec:	54fd                	li	s1,-1
  if(argaddr(0, &upstat) < 0)
    800031ee:	02054763          	bltz	a0,8000321c <sys_getpstat+0x60>
 //  TODO: define kernel side kgetpstat(struct pstat* ps)
  uint64 result = kgetpstat(&kpstat);
    800031f2:	bd840513          	addi	a0,s0,-1064
    800031f6:	00000097          	auipc	ra,0x0
    800031fa:	f42080e7          	jalr	-190(ra) # 80003138 <kgetpstat>
    800031fe:	84aa                	mv	s1,a0
  // copy pstat from kernel memor`y to user memory
  if(copyout(p->pagetable, upstat, (char *)&kpstat, sizeof(kpstat)) < 0)
    80003200:	40000693          	li	a3,1024
    80003204:	bd840613          	addi	a2,s0,-1064
    80003208:	fd843583          	ld	a1,-40(s0)
    8000320c:	05093503          	ld	a0,80(s2)
    80003210:	ffffe097          	auipc	ra,0xffffe
    80003214:	442080e7          	jalr	1090(ra) # 80001652 <copyout>
    80003218:	00054e63          	bltz	a0,80003234 <sys_getpstat+0x78>
    return -1;
  return result;
}
    8000321c:	8526                	mv	a0,s1
    8000321e:	42813083          	ld	ra,1064(sp)
    80003222:	42013403          	ld	s0,1056(sp)
    80003226:	41813483          	ld	s1,1048(sp)
    8000322a:	41013903          	ld	s2,1040(sp)
    8000322e:	43010113          	addi	sp,sp,1072
    80003232:	8082                	ret
    return -1;
    80003234:	54fd                	li	s1,-1
    80003236:	b7dd                	j	8000321c <sys_getpstat+0x60>

0000000080003238 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003238:	7179                	addi	sp,sp,-48
    8000323a:	f406                	sd	ra,40(sp)
    8000323c:	f022                	sd	s0,32(sp)
    8000323e:	ec26                	sd	s1,24(sp)
    80003240:	e84a                	sd	s2,16(sp)
    80003242:	e44e                	sd	s3,8(sp)
    80003244:	e052                	sd	s4,0(sp)
    80003246:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003248:	00005597          	auipc	a1,0x5
    8000324c:	2a058593          	addi	a1,a1,672 # 800084e8 <syscalls+0xb8>
    80003250:	00014517          	auipc	a0,0x14
    80003254:	fa850513          	addi	a0,a0,-88 # 800171f8 <bcache>
    80003258:	ffffe097          	auipc	ra,0xffffe
    8000325c:	8ea080e7          	jalr	-1814(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003260:	0001c797          	auipc	a5,0x1c
    80003264:	f9878793          	addi	a5,a5,-104 # 8001f1f8 <bcache+0x8000>
    80003268:	0001c717          	auipc	a4,0x1c
    8000326c:	1f870713          	addi	a4,a4,504 # 8001f460 <bcache+0x8268>
    80003270:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003274:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003278:	00014497          	auipc	s1,0x14
    8000327c:	f9848493          	addi	s1,s1,-104 # 80017210 <bcache+0x18>
    b->next = bcache.head.next;
    80003280:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003282:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003284:	00005a17          	auipc	s4,0x5
    80003288:	26ca0a13          	addi	s4,s4,620 # 800084f0 <syscalls+0xc0>
    b->next = bcache.head.next;
    8000328c:	2b893783          	ld	a5,696(s2)
    80003290:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003292:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003296:	85d2                	mv	a1,s4
    80003298:	01048513          	addi	a0,s1,16
    8000329c:	00001097          	auipc	ra,0x1
    800032a0:	4bc080e7          	jalr	1212(ra) # 80004758 <initsleeplock>
    bcache.head.next->prev = b;
    800032a4:	2b893783          	ld	a5,696(s2)
    800032a8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800032aa:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800032ae:	45848493          	addi	s1,s1,1112
    800032b2:	fd349de3          	bne	s1,s3,8000328c <binit+0x54>
  }
}
    800032b6:	70a2                	ld	ra,40(sp)
    800032b8:	7402                	ld	s0,32(sp)
    800032ba:	64e2                	ld	s1,24(sp)
    800032bc:	6942                	ld	s2,16(sp)
    800032be:	69a2                	ld	s3,8(sp)
    800032c0:	6a02                	ld	s4,0(sp)
    800032c2:	6145                	addi	sp,sp,48
    800032c4:	8082                	ret

00000000800032c6 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800032c6:	7179                	addi	sp,sp,-48
    800032c8:	f406                	sd	ra,40(sp)
    800032ca:	f022                	sd	s0,32(sp)
    800032cc:	ec26                	sd	s1,24(sp)
    800032ce:	e84a                	sd	s2,16(sp)
    800032d0:	e44e                	sd	s3,8(sp)
    800032d2:	1800                	addi	s0,sp,48
    800032d4:	89aa                	mv	s3,a0
    800032d6:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    800032d8:	00014517          	auipc	a0,0x14
    800032dc:	f2050513          	addi	a0,a0,-224 # 800171f8 <bcache>
    800032e0:	ffffe097          	auipc	ra,0xffffe
    800032e4:	8f2080e7          	jalr	-1806(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800032e8:	0001c497          	auipc	s1,0x1c
    800032ec:	1c84b483          	ld	s1,456(s1) # 8001f4b0 <bcache+0x82b8>
    800032f0:	0001c797          	auipc	a5,0x1c
    800032f4:	17078793          	addi	a5,a5,368 # 8001f460 <bcache+0x8268>
    800032f8:	02f48f63          	beq	s1,a5,80003336 <bread+0x70>
    800032fc:	873e                	mv	a4,a5
    800032fe:	a021                	j	80003306 <bread+0x40>
    80003300:	68a4                	ld	s1,80(s1)
    80003302:	02e48a63          	beq	s1,a4,80003336 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003306:	449c                	lw	a5,8(s1)
    80003308:	ff379ce3          	bne	a5,s3,80003300 <bread+0x3a>
    8000330c:	44dc                	lw	a5,12(s1)
    8000330e:	ff2799e3          	bne	a5,s2,80003300 <bread+0x3a>
      b->refcnt++;
    80003312:	40bc                	lw	a5,64(s1)
    80003314:	2785                	addiw	a5,a5,1
    80003316:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003318:	00014517          	auipc	a0,0x14
    8000331c:	ee050513          	addi	a0,a0,-288 # 800171f8 <bcache>
    80003320:	ffffe097          	auipc	ra,0xffffe
    80003324:	966080e7          	jalr	-1690(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80003328:	01048513          	addi	a0,s1,16
    8000332c:	00001097          	auipc	ra,0x1
    80003330:	466080e7          	jalr	1126(ra) # 80004792 <acquiresleep>
      return b;
    80003334:	a8b9                	j	80003392 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003336:	0001c497          	auipc	s1,0x1c
    8000333a:	1724b483          	ld	s1,370(s1) # 8001f4a8 <bcache+0x82b0>
    8000333e:	0001c797          	auipc	a5,0x1c
    80003342:	12278793          	addi	a5,a5,290 # 8001f460 <bcache+0x8268>
    80003346:	00f48863          	beq	s1,a5,80003356 <bread+0x90>
    8000334a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000334c:	40bc                	lw	a5,64(s1)
    8000334e:	cf81                	beqz	a5,80003366 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003350:	64a4                	ld	s1,72(s1)
    80003352:	fee49de3          	bne	s1,a4,8000334c <bread+0x86>
  panic("bget: no buffers");
    80003356:	00005517          	auipc	a0,0x5
    8000335a:	1a250513          	addi	a0,a0,418 # 800084f8 <syscalls+0xc8>
    8000335e:	ffffd097          	auipc	ra,0xffffd
    80003362:	1d2080e7          	jalr	466(ra) # 80000530 <panic>
      b->dev = dev;
    80003366:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000336a:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    8000336e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003372:	4785                	li	a5,1
    80003374:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003376:	00014517          	auipc	a0,0x14
    8000337a:	e8250513          	addi	a0,a0,-382 # 800171f8 <bcache>
    8000337e:	ffffe097          	auipc	ra,0xffffe
    80003382:	908080e7          	jalr	-1784(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80003386:	01048513          	addi	a0,s1,16
    8000338a:	00001097          	auipc	ra,0x1
    8000338e:	408080e7          	jalr	1032(ra) # 80004792 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003392:	409c                	lw	a5,0(s1)
    80003394:	cb89                	beqz	a5,800033a6 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003396:	8526                	mv	a0,s1
    80003398:	70a2                	ld	ra,40(sp)
    8000339a:	7402                	ld	s0,32(sp)
    8000339c:	64e2                	ld	s1,24(sp)
    8000339e:	6942                	ld	s2,16(sp)
    800033a0:	69a2                	ld	s3,8(sp)
    800033a2:	6145                	addi	sp,sp,48
    800033a4:	8082                	ret
    virtio_disk_rw(b, 0);
    800033a6:	4581                	li	a1,0
    800033a8:	8526                	mv	a0,s1
    800033aa:	00003097          	auipc	ra,0x3
    800033ae:	f0c080e7          	jalr	-244(ra) # 800062b6 <virtio_disk_rw>
    b->valid = 1;
    800033b2:	4785                	li	a5,1
    800033b4:	c09c                	sw	a5,0(s1)
  return b;
    800033b6:	b7c5                	j	80003396 <bread+0xd0>

00000000800033b8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800033b8:	1101                	addi	sp,sp,-32
    800033ba:	ec06                	sd	ra,24(sp)
    800033bc:	e822                	sd	s0,16(sp)
    800033be:	e426                	sd	s1,8(sp)
    800033c0:	1000                	addi	s0,sp,32
    800033c2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800033c4:	0541                	addi	a0,a0,16
    800033c6:	00001097          	auipc	ra,0x1
    800033ca:	466080e7          	jalr	1126(ra) # 8000482c <holdingsleep>
    800033ce:	cd01                	beqz	a0,800033e6 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800033d0:	4585                	li	a1,1
    800033d2:	8526                	mv	a0,s1
    800033d4:	00003097          	auipc	ra,0x3
    800033d8:	ee2080e7          	jalr	-286(ra) # 800062b6 <virtio_disk_rw>
}
    800033dc:	60e2                	ld	ra,24(sp)
    800033de:	6442                	ld	s0,16(sp)
    800033e0:	64a2                	ld	s1,8(sp)
    800033e2:	6105                	addi	sp,sp,32
    800033e4:	8082                	ret
    panic("bwrite");
    800033e6:	00005517          	auipc	a0,0x5
    800033ea:	12a50513          	addi	a0,a0,298 # 80008510 <syscalls+0xe0>
    800033ee:	ffffd097          	auipc	ra,0xffffd
    800033f2:	142080e7          	jalr	322(ra) # 80000530 <panic>

00000000800033f6 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800033f6:	1101                	addi	sp,sp,-32
    800033f8:	ec06                	sd	ra,24(sp)
    800033fa:	e822                	sd	s0,16(sp)
    800033fc:	e426                	sd	s1,8(sp)
    800033fe:	e04a                	sd	s2,0(sp)
    80003400:	1000                	addi	s0,sp,32
    80003402:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003404:	01050913          	addi	s2,a0,16
    80003408:	854a                	mv	a0,s2
    8000340a:	00001097          	auipc	ra,0x1
    8000340e:	422080e7          	jalr	1058(ra) # 8000482c <holdingsleep>
    80003412:	c92d                	beqz	a0,80003484 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003414:	854a                	mv	a0,s2
    80003416:	00001097          	auipc	ra,0x1
    8000341a:	3d2080e7          	jalr	978(ra) # 800047e8 <releasesleep>

  acquire(&bcache.lock);
    8000341e:	00014517          	auipc	a0,0x14
    80003422:	dda50513          	addi	a0,a0,-550 # 800171f8 <bcache>
    80003426:	ffffd097          	auipc	ra,0xffffd
    8000342a:	7ac080e7          	jalr	1964(ra) # 80000bd2 <acquire>
  b->refcnt--;
    8000342e:	40bc                	lw	a5,64(s1)
    80003430:	37fd                	addiw	a5,a5,-1
    80003432:	0007871b          	sext.w	a4,a5
    80003436:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003438:	eb05                	bnez	a4,80003468 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000343a:	68bc                	ld	a5,80(s1)
    8000343c:	64b8                	ld	a4,72(s1)
    8000343e:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003440:	64bc                	ld	a5,72(s1)
    80003442:	68b8                	ld	a4,80(s1)
    80003444:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003446:	0001c797          	auipc	a5,0x1c
    8000344a:	db278793          	addi	a5,a5,-590 # 8001f1f8 <bcache+0x8000>
    8000344e:	2b87b703          	ld	a4,696(a5)
    80003452:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003454:	0001c717          	auipc	a4,0x1c
    80003458:	00c70713          	addi	a4,a4,12 # 8001f460 <bcache+0x8268>
    8000345c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000345e:	2b87b703          	ld	a4,696(a5)
    80003462:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003464:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003468:	00014517          	auipc	a0,0x14
    8000346c:	d9050513          	addi	a0,a0,-624 # 800171f8 <bcache>
    80003470:	ffffe097          	auipc	ra,0xffffe
    80003474:	816080e7          	jalr	-2026(ra) # 80000c86 <release>
}
    80003478:	60e2                	ld	ra,24(sp)
    8000347a:	6442                	ld	s0,16(sp)
    8000347c:	64a2                	ld	s1,8(sp)
    8000347e:	6902                	ld	s2,0(sp)
    80003480:	6105                	addi	sp,sp,32
    80003482:	8082                	ret
    panic("brelse");
    80003484:	00005517          	auipc	a0,0x5
    80003488:	09450513          	addi	a0,a0,148 # 80008518 <syscalls+0xe8>
    8000348c:	ffffd097          	auipc	ra,0xffffd
    80003490:	0a4080e7          	jalr	164(ra) # 80000530 <panic>

0000000080003494 <bpin>:

void
bpin(struct buf *b) {
    80003494:	1101                	addi	sp,sp,-32
    80003496:	ec06                	sd	ra,24(sp)
    80003498:	e822                	sd	s0,16(sp)
    8000349a:	e426                	sd	s1,8(sp)
    8000349c:	1000                	addi	s0,sp,32
    8000349e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800034a0:	00014517          	auipc	a0,0x14
    800034a4:	d5850513          	addi	a0,a0,-680 # 800171f8 <bcache>
    800034a8:	ffffd097          	auipc	ra,0xffffd
    800034ac:	72a080e7          	jalr	1834(ra) # 80000bd2 <acquire>
  b->refcnt++;
    800034b0:	40bc                	lw	a5,64(s1)
    800034b2:	2785                	addiw	a5,a5,1
    800034b4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034b6:	00014517          	auipc	a0,0x14
    800034ba:	d4250513          	addi	a0,a0,-702 # 800171f8 <bcache>
    800034be:	ffffd097          	auipc	ra,0xffffd
    800034c2:	7c8080e7          	jalr	1992(ra) # 80000c86 <release>
}
    800034c6:	60e2                	ld	ra,24(sp)
    800034c8:	6442                	ld	s0,16(sp)
    800034ca:	64a2                	ld	s1,8(sp)
    800034cc:	6105                	addi	sp,sp,32
    800034ce:	8082                	ret

00000000800034d0 <bunpin>:

void
bunpin(struct buf *b) {
    800034d0:	1101                	addi	sp,sp,-32
    800034d2:	ec06                	sd	ra,24(sp)
    800034d4:	e822                	sd	s0,16(sp)
    800034d6:	e426                	sd	s1,8(sp)
    800034d8:	1000                	addi	s0,sp,32
    800034da:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800034dc:	00014517          	auipc	a0,0x14
    800034e0:	d1c50513          	addi	a0,a0,-740 # 800171f8 <bcache>
    800034e4:	ffffd097          	auipc	ra,0xffffd
    800034e8:	6ee080e7          	jalr	1774(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800034ec:	40bc                	lw	a5,64(s1)
    800034ee:	37fd                	addiw	a5,a5,-1
    800034f0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800034f2:	00014517          	auipc	a0,0x14
    800034f6:	d0650513          	addi	a0,a0,-762 # 800171f8 <bcache>
    800034fa:	ffffd097          	auipc	ra,0xffffd
    800034fe:	78c080e7          	jalr	1932(ra) # 80000c86 <release>
}
    80003502:	60e2                	ld	ra,24(sp)
    80003504:	6442                	ld	s0,16(sp)
    80003506:	64a2                	ld	s1,8(sp)
    80003508:	6105                	addi	sp,sp,32
    8000350a:	8082                	ret

000000008000350c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000350c:	1101                	addi	sp,sp,-32
    8000350e:	ec06                	sd	ra,24(sp)
    80003510:	e822                	sd	s0,16(sp)
    80003512:	e426                	sd	s1,8(sp)
    80003514:	e04a                	sd	s2,0(sp)
    80003516:	1000                	addi	s0,sp,32
    80003518:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000351a:	00d5d59b          	srliw	a1,a1,0xd
    8000351e:	0001c797          	auipc	a5,0x1c
    80003522:	3b67a783          	lw	a5,950(a5) # 8001f8d4 <sb+0x1c>
    80003526:	9dbd                	addw	a1,a1,a5
    80003528:	00000097          	auipc	ra,0x0
    8000352c:	d9e080e7          	jalr	-610(ra) # 800032c6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003530:	0074f713          	andi	a4,s1,7
    80003534:	4785                	li	a5,1
    80003536:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000353a:	14ce                	slli	s1,s1,0x33
    8000353c:	90d9                	srli	s1,s1,0x36
    8000353e:	00950733          	add	a4,a0,s1
    80003542:	05874703          	lbu	a4,88(a4)
    80003546:	00e7f6b3          	and	a3,a5,a4
    8000354a:	c69d                	beqz	a3,80003578 <bfree+0x6c>
    8000354c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000354e:	94aa                	add	s1,s1,a0
    80003550:	fff7c793          	not	a5,a5
    80003554:	8ff9                	and	a5,a5,a4
    80003556:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    8000355a:	00001097          	auipc	ra,0x1
    8000355e:	118080e7          	jalr	280(ra) # 80004672 <log_write>
  brelse(bp);
    80003562:	854a                	mv	a0,s2
    80003564:	00000097          	auipc	ra,0x0
    80003568:	e92080e7          	jalr	-366(ra) # 800033f6 <brelse>
}
    8000356c:	60e2                	ld	ra,24(sp)
    8000356e:	6442                	ld	s0,16(sp)
    80003570:	64a2                	ld	s1,8(sp)
    80003572:	6902                	ld	s2,0(sp)
    80003574:	6105                	addi	sp,sp,32
    80003576:	8082                	ret
    panic("freeing free block");
    80003578:	00005517          	auipc	a0,0x5
    8000357c:	fa850513          	addi	a0,a0,-88 # 80008520 <syscalls+0xf0>
    80003580:	ffffd097          	auipc	ra,0xffffd
    80003584:	fb0080e7          	jalr	-80(ra) # 80000530 <panic>

0000000080003588 <balloc>:
{
    80003588:	711d                	addi	sp,sp,-96
    8000358a:	ec86                	sd	ra,88(sp)
    8000358c:	e8a2                	sd	s0,80(sp)
    8000358e:	e4a6                	sd	s1,72(sp)
    80003590:	e0ca                	sd	s2,64(sp)
    80003592:	fc4e                	sd	s3,56(sp)
    80003594:	f852                	sd	s4,48(sp)
    80003596:	f456                	sd	s5,40(sp)
    80003598:	f05a                	sd	s6,32(sp)
    8000359a:	ec5e                	sd	s7,24(sp)
    8000359c:	e862                	sd	s8,16(sp)
    8000359e:	e466                	sd	s9,8(sp)
    800035a0:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800035a2:	0001c797          	auipc	a5,0x1c
    800035a6:	31a7a783          	lw	a5,794(a5) # 8001f8bc <sb+0x4>
    800035aa:	cbd1                	beqz	a5,8000363e <balloc+0xb6>
    800035ac:	8baa                	mv	s7,a0
    800035ae:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800035b0:	0001cb17          	auipc	s6,0x1c
    800035b4:	308b0b13          	addi	s6,s6,776 # 8001f8b8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035b8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800035ba:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035bc:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800035be:	6c89                	lui	s9,0x2
    800035c0:	a831                	j	800035dc <balloc+0x54>
    brelse(bp);
    800035c2:	854a                	mv	a0,s2
    800035c4:	00000097          	auipc	ra,0x0
    800035c8:	e32080e7          	jalr	-462(ra) # 800033f6 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800035cc:	015c87bb          	addw	a5,s9,s5
    800035d0:	00078a9b          	sext.w	s5,a5
    800035d4:	004b2703          	lw	a4,4(s6)
    800035d8:	06eaf363          	bgeu	s5,a4,8000363e <balloc+0xb6>
    bp = bread(dev, BBLOCK(b, sb));
    800035dc:	41fad79b          	sraiw	a5,s5,0x1f
    800035e0:	0137d79b          	srliw	a5,a5,0x13
    800035e4:	015787bb          	addw	a5,a5,s5
    800035e8:	40d7d79b          	sraiw	a5,a5,0xd
    800035ec:	01cb2583          	lw	a1,28(s6)
    800035f0:	9dbd                	addw	a1,a1,a5
    800035f2:	855e                	mv	a0,s7
    800035f4:	00000097          	auipc	ra,0x0
    800035f8:	cd2080e7          	jalr	-814(ra) # 800032c6 <bread>
    800035fc:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800035fe:	004b2503          	lw	a0,4(s6)
    80003602:	000a849b          	sext.w	s1,s5
    80003606:	8662                	mv	a2,s8
    80003608:	faa4fde3          	bgeu	s1,a0,800035c2 <balloc+0x3a>
      m = 1 << (bi % 8);
    8000360c:	41f6579b          	sraiw	a5,a2,0x1f
    80003610:	01d7d69b          	srliw	a3,a5,0x1d
    80003614:	00c6873b          	addw	a4,a3,a2
    80003618:	00777793          	andi	a5,a4,7
    8000361c:	9f95                	subw	a5,a5,a3
    8000361e:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003622:	4037571b          	sraiw	a4,a4,0x3
    80003626:	00e906b3          	add	a3,s2,a4
    8000362a:	0586c683          	lbu	a3,88(a3)
    8000362e:	00d7f5b3          	and	a1,a5,a3
    80003632:	cd91                	beqz	a1,8000364e <balloc+0xc6>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003634:	2605                	addiw	a2,a2,1
    80003636:	2485                	addiw	s1,s1,1
    80003638:	fd4618e3          	bne	a2,s4,80003608 <balloc+0x80>
    8000363c:	b759                	j	800035c2 <balloc+0x3a>
  panic("balloc: out of blocks");
    8000363e:	00005517          	auipc	a0,0x5
    80003642:	efa50513          	addi	a0,a0,-262 # 80008538 <syscalls+0x108>
    80003646:	ffffd097          	auipc	ra,0xffffd
    8000364a:	eea080e7          	jalr	-278(ra) # 80000530 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000364e:	974a                	add	a4,a4,s2
    80003650:	8fd5                	or	a5,a5,a3
    80003652:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80003656:	854a                	mv	a0,s2
    80003658:	00001097          	auipc	ra,0x1
    8000365c:	01a080e7          	jalr	26(ra) # 80004672 <log_write>
        brelse(bp);
    80003660:	854a                	mv	a0,s2
    80003662:	00000097          	auipc	ra,0x0
    80003666:	d94080e7          	jalr	-620(ra) # 800033f6 <brelse>
  bp = bread(dev, bno);
    8000366a:	85a6                	mv	a1,s1
    8000366c:	855e                	mv	a0,s7
    8000366e:	00000097          	auipc	ra,0x0
    80003672:	c58080e7          	jalr	-936(ra) # 800032c6 <bread>
    80003676:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003678:	40000613          	li	a2,1024
    8000367c:	4581                	li	a1,0
    8000367e:	05850513          	addi	a0,a0,88
    80003682:	ffffd097          	auipc	ra,0xffffd
    80003686:	64c080e7          	jalr	1612(ra) # 80000cce <memset>
  log_write(bp);
    8000368a:	854a                	mv	a0,s2
    8000368c:	00001097          	auipc	ra,0x1
    80003690:	fe6080e7          	jalr	-26(ra) # 80004672 <log_write>
  brelse(bp);
    80003694:	854a                	mv	a0,s2
    80003696:	00000097          	auipc	ra,0x0
    8000369a:	d60080e7          	jalr	-672(ra) # 800033f6 <brelse>
}
    8000369e:	8526                	mv	a0,s1
    800036a0:	60e6                	ld	ra,88(sp)
    800036a2:	6446                	ld	s0,80(sp)
    800036a4:	64a6                	ld	s1,72(sp)
    800036a6:	6906                	ld	s2,64(sp)
    800036a8:	79e2                	ld	s3,56(sp)
    800036aa:	7a42                	ld	s4,48(sp)
    800036ac:	7aa2                	ld	s5,40(sp)
    800036ae:	7b02                	ld	s6,32(sp)
    800036b0:	6be2                	ld	s7,24(sp)
    800036b2:	6c42                	ld	s8,16(sp)
    800036b4:	6ca2                	ld	s9,8(sp)
    800036b6:	6125                	addi	sp,sp,96
    800036b8:	8082                	ret

00000000800036ba <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800036ba:	7179                	addi	sp,sp,-48
    800036bc:	f406                	sd	ra,40(sp)
    800036be:	f022                	sd	s0,32(sp)
    800036c0:	ec26                	sd	s1,24(sp)
    800036c2:	e84a                	sd	s2,16(sp)
    800036c4:	e44e                	sd	s3,8(sp)
    800036c6:	e052                	sd	s4,0(sp)
    800036c8:	1800                	addi	s0,sp,48
    800036ca:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800036cc:	47ad                	li	a5,11
    800036ce:	04b7fe63          	bgeu	a5,a1,8000372a <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800036d2:	ff45849b          	addiw	s1,a1,-12
    800036d6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800036da:	0ff00793          	li	a5,255
    800036de:	0ae7e363          	bltu	a5,a4,80003784 <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800036e2:	08052583          	lw	a1,128(a0)
    800036e6:	c5ad                	beqz	a1,80003750 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800036e8:	00092503          	lw	a0,0(s2)
    800036ec:	00000097          	auipc	ra,0x0
    800036f0:	bda080e7          	jalr	-1062(ra) # 800032c6 <bread>
    800036f4:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800036f6:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800036fa:	02049593          	slli	a1,s1,0x20
    800036fe:	9181                	srli	a1,a1,0x20
    80003700:	058a                	slli	a1,a1,0x2
    80003702:	00b784b3          	add	s1,a5,a1
    80003706:	0004a983          	lw	s3,0(s1)
    8000370a:	04098d63          	beqz	s3,80003764 <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    8000370e:	8552                	mv	a0,s4
    80003710:	00000097          	auipc	ra,0x0
    80003714:	ce6080e7          	jalr	-794(ra) # 800033f6 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003718:	854e                	mv	a0,s3
    8000371a:	70a2                	ld	ra,40(sp)
    8000371c:	7402                	ld	s0,32(sp)
    8000371e:	64e2                	ld	s1,24(sp)
    80003720:	6942                	ld	s2,16(sp)
    80003722:	69a2                	ld	s3,8(sp)
    80003724:	6a02                	ld	s4,0(sp)
    80003726:	6145                	addi	sp,sp,48
    80003728:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000372a:	02059493          	slli	s1,a1,0x20
    8000372e:	9081                	srli	s1,s1,0x20
    80003730:	048a                	slli	s1,s1,0x2
    80003732:	94aa                	add	s1,s1,a0
    80003734:	0504a983          	lw	s3,80(s1)
    80003738:	fe0990e3          	bnez	s3,80003718 <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    8000373c:	4108                	lw	a0,0(a0)
    8000373e:	00000097          	auipc	ra,0x0
    80003742:	e4a080e7          	jalr	-438(ra) # 80003588 <balloc>
    80003746:	0005099b          	sext.w	s3,a0
    8000374a:	0534a823          	sw	s3,80(s1)
    8000374e:	b7e9                	j	80003718 <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003750:	4108                	lw	a0,0(a0)
    80003752:	00000097          	auipc	ra,0x0
    80003756:	e36080e7          	jalr	-458(ra) # 80003588 <balloc>
    8000375a:	0005059b          	sext.w	a1,a0
    8000375e:	08b92023          	sw	a1,128(s2)
    80003762:	b759                	j	800036e8 <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    80003764:	00092503          	lw	a0,0(s2)
    80003768:	00000097          	auipc	ra,0x0
    8000376c:	e20080e7          	jalr	-480(ra) # 80003588 <balloc>
    80003770:	0005099b          	sext.w	s3,a0
    80003774:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    80003778:	8552                	mv	a0,s4
    8000377a:	00001097          	auipc	ra,0x1
    8000377e:	ef8080e7          	jalr	-264(ra) # 80004672 <log_write>
    80003782:	b771                	j	8000370e <bmap+0x54>
  panic("bmap: out of range");
    80003784:	00005517          	auipc	a0,0x5
    80003788:	dcc50513          	addi	a0,a0,-564 # 80008550 <syscalls+0x120>
    8000378c:	ffffd097          	auipc	ra,0xffffd
    80003790:	da4080e7          	jalr	-604(ra) # 80000530 <panic>

0000000080003794 <iget>:
{
    80003794:	7179                	addi	sp,sp,-48
    80003796:	f406                	sd	ra,40(sp)
    80003798:	f022                	sd	s0,32(sp)
    8000379a:	ec26                	sd	s1,24(sp)
    8000379c:	e84a                	sd	s2,16(sp)
    8000379e:	e44e                	sd	s3,8(sp)
    800037a0:	e052                	sd	s4,0(sp)
    800037a2:	1800                	addi	s0,sp,48
    800037a4:	89aa                	mv	s3,a0
    800037a6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800037a8:	0001c517          	auipc	a0,0x1c
    800037ac:	13050513          	addi	a0,a0,304 # 8001f8d8 <itable>
    800037b0:	ffffd097          	auipc	ra,0xffffd
    800037b4:	422080e7          	jalr	1058(ra) # 80000bd2 <acquire>
  empty = 0;
    800037b8:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800037ba:	0001c497          	auipc	s1,0x1c
    800037be:	13648493          	addi	s1,s1,310 # 8001f8f0 <itable+0x18>
    800037c2:	0001e697          	auipc	a3,0x1e
    800037c6:	bbe68693          	addi	a3,a3,-1090 # 80021380 <log>
    800037ca:	a039                	j	800037d8 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800037cc:	02090b63          	beqz	s2,80003802 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800037d0:	08848493          	addi	s1,s1,136
    800037d4:	02d48a63          	beq	s1,a3,80003808 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800037d8:	449c                	lw	a5,8(s1)
    800037da:	fef059e3          	blez	a5,800037cc <iget+0x38>
    800037de:	4098                	lw	a4,0(s1)
    800037e0:	ff3716e3          	bne	a4,s3,800037cc <iget+0x38>
    800037e4:	40d8                	lw	a4,4(s1)
    800037e6:	ff4713e3          	bne	a4,s4,800037cc <iget+0x38>
      ip->ref++;
    800037ea:	2785                	addiw	a5,a5,1
    800037ec:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800037ee:	0001c517          	auipc	a0,0x1c
    800037f2:	0ea50513          	addi	a0,a0,234 # 8001f8d8 <itable>
    800037f6:	ffffd097          	auipc	ra,0xffffd
    800037fa:	490080e7          	jalr	1168(ra) # 80000c86 <release>
      return ip;
    800037fe:	8926                	mv	s2,s1
    80003800:	a03d                	j	8000382e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003802:	f7f9                	bnez	a5,800037d0 <iget+0x3c>
    80003804:	8926                	mv	s2,s1
    80003806:	b7e9                	j	800037d0 <iget+0x3c>
  if(empty == 0)
    80003808:	02090c63          	beqz	s2,80003840 <iget+0xac>
  ip->dev = dev;
    8000380c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003810:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003814:	4785                	li	a5,1
    80003816:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000381a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000381e:	0001c517          	auipc	a0,0x1c
    80003822:	0ba50513          	addi	a0,a0,186 # 8001f8d8 <itable>
    80003826:	ffffd097          	auipc	ra,0xffffd
    8000382a:	460080e7          	jalr	1120(ra) # 80000c86 <release>
}
    8000382e:	854a                	mv	a0,s2
    80003830:	70a2                	ld	ra,40(sp)
    80003832:	7402                	ld	s0,32(sp)
    80003834:	64e2                	ld	s1,24(sp)
    80003836:	6942                	ld	s2,16(sp)
    80003838:	69a2                	ld	s3,8(sp)
    8000383a:	6a02                	ld	s4,0(sp)
    8000383c:	6145                	addi	sp,sp,48
    8000383e:	8082                	ret
    panic("iget: no inodes");
    80003840:	00005517          	auipc	a0,0x5
    80003844:	d2850513          	addi	a0,a0,-728 # 80008568 <syscalls+0x138>
    80003848:	ffffd097          	auipc	ra,0xffffd
    8000384c:	ce8080e7          	jalr	-792(ra) # 80000530 <panic>

0000000080003850 <fsinit>:
fsinit(int dev) {
    80003850:	7179                	addi	sp,sp,-48
    80003852:	f406                	sd	ra,40(sp)
    80003854:	f022                	sd	s0,32(sp)
    80003856:	ec26                	sd	s1,24(sp)
    80003858:	e84a                	sd	s2,16(sp)
    8000385a:	e44e                	sd	s3,8(sp)
    8000385c:	1800                	addi	s0,sp,48
    8000385e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003860:	4585                	li	a1,1
    80003862:	00000097          	auipc	ra,0x0
    80003866:	a64080e7          	jalr	-1436(ra) # 800032c6 <bread>
    8000386a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000386c:	0001c997          	auipc	s3,0x1c
    80003870:	04c98993          	addi	s3,s3,76 # 8001f8b8 <sb>
    80003874:	02000613          	li	a2,32
    80003878:	05850593          	addi	a1,a0,88
    8000387c:	854e                	mv	a0,s3
    8000387e:	ffffd097          	auipc	ra,0xffffd
    80003882:	4b0080e7          	jalr	1200(ra) # 80000d2e <memmove>
  brelse(bp);
    80003886:	8526                	mv	a0,s1
    80003888:	00000097          	auipc	ra,0x0
    8000388c:	b6e080e7          	jalr	-1170(ra) # 800033f6 <brelse>
  if(sb.magic != FSMAGIC)
    80003890:	0009a703          	lw	a4,0(s3)
    80003894:	102037b7          	lui	a5,0x10203
    80003898:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000389c:	02f71263          	bne	a4,a5,800038c0 <fsinit+0x70>
  initlog(dev, &sb);
    800038a0:	0001c597          	auipc	a1,0x1c
    800038a4:	01858593          	addi	a1,a1,24 # 8001f8b8 <sb>
    800038a8:	854a                	mv	a0,s2
    800038aa:	00001097          	auipc	ra,0x1
    800038ae:	b4c080e7          	jalr	-1204(ra) # 800043f6 <initlog>
}
    800038b2:	70a2                	ld	ra,40(sp)
    800038b4:	7402                	ld	s0,32(sp)
    800038b6:	64e2                	ld	s1,24(sp)
    800038b8:	6942                	ld	s2,16(sp)
    800038ba:	69a2                	ld	s3,8(sp)
    800038bc:	6145                	addi	sp,sp,48
    800038be:	8082                	ret
    panic("invalid file system");
    800038c0:	00005517          	auipc	a0,0x5
    800038c4:	cb850513          	addi	a0,a0,-840 # 80008578 <syscalls+0x148>
    800038c8:	ffffd097          	auipc	ra,0xffffd
    800038cc:	c68080e7          	jalr	-920(ra) # 80000530 <panic>

00000000800038d0 <iinit>:
{
    800038d0:	7179                	addi	sp,sp,-48
    800038d2:	f406                	sd	ra,40(sp)
    800038d4:	f022                	sd	s0,32(sp)
    800038d6:	ec26                	sd	s1,24(sp)
    800038d8:	e84a                	sd	s2,16(sp)
    800038da:	e44e                	sd	s3,8(sp)
    800038dc:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800038de:	00005597          	auipc	a1,0x5
    800038e2:	cb258593          	addi	a1,a1,-846 # 80008590 <syscalls+0x160>
    800038e6:	0001c517          	auipc	a0,0x1c
    800038ea:	ff250513          	addi	a0,a0,-14 # 8001f8d8 <itable>
    800038ee:	ffffd097          	auipc	ra,0xffffd
    800038f2:	254080e7          	jalr	596(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    800038f6:	0001c497          	auipc	s1,0x1c
    800038fa:	00a48493          	addi	s1,s1,10 # 8001f900 <itable+0x28>
    800038fe:	0001e997          	auipc	s3,0x1e
    80003902:	a9298993          	addi	s3,s3,-1390 # 80021390 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003906:	00005917          	auipc	s2,0x5
    8000390a:	c9290913          	addi	s2,s2,-878 # 80008598 <syscalls+0x168>
    8000390e:	85ca                	mv	a1,s2
    80003910:	8526                	mv	a0,s1
    80003912:	00001097          	auipc	ra,0x1
    80003916:	e46080e7          	jalr	-442(ra) # 80004758 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000391a:	08848493          	addi	s1,s1,136
    8000391e:	ff3498e3          	bne	s1,s3,8000390e <iinit+0x3e>
}
    80003922:	70a2                	ld	ra,40(sp)
    80003924:	7402                	ld	s0,32(sp)
    80003926:	64e2                	ld	s1,24(sp)
    80003928:	6942                	ld	s2,16(sp)
    8000392a:	69a2                	ld	s3,8(sp)
    8000392c:	6145                	addi	sp,sp,48
    8000392e:	8082                	ret

0000000080003930 <ialloc>:
{
    80003930:	715d                	addi	sp,sp,-80
    80003932:	e486                	sd	ra,72(sp)
    80003934:	e0a2                	sd	s0,64(sp)
    80003936:	fc26                	sd	s1,56(sp)
    80003938:	f84a                	sd	s2,48(sp)
    8000393a:	f44e                	sd	s3,40(sp)
    8000393c:	f052                	sd	s4,32(sp)
    8000393e:	ec56                	sd	s5,24(sp)
    80003940:	e85a                	sd	s6,16(sp)
    80003942:	e45e                	sd	s7,8(sp)
    80003944:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003946:	0001c717          	auipc	a4,0x1c
    8000394a:	f7e72703          	lw	a4,-130(a4) # 8001f8c4 <sb+0xc>
    8000394e:	4785                	li	a5,1
    80003950:	04e7fa63          	bgeu	a5,a4,800039a4 <ialloc+0x74>
    80003954:	8aaa                	mv	s5,a0
    80003956:	8bae                	mv	s7,a1
    80003958:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000395a:	0001ca17          	auipc	s4,0x1c
    8000395e:	f5ea0a13          	addi	s4,s4,-162 # 8001f8b8 <sb>
    80003962:	00048b1b          	sext.w	s6,s1
    80003966:	0044d593          	srli	a1,s1,0x4
    8000396a:	018a2783          	lw	a5,24(s4)
    8000396e:	9dbd                	addw	a1,a1,a5
    80003970:	8556                	mv	a0,s5
    80003972:	00000097          	auipc	ra,0x0
    80003976:	954080e7          	jalr	-1708(ra) # 800032c6 <bread>
    8000397a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000397c:	05850993          	addi	s3,a0,88
    80003980:	00f4f793          	andi	a5,s1,15
    80003984:	079a                	slli	a5,a5,0x6
    80003986:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003988:	00099783          	lh	a5,0(s3)
    8000398c:	c785                	beqz	a5,800039b4 <ialloc+0x84>
    brelse(bp);
    8000398e:	00000097          	auipc	ra,0x0
    80003992:	a68080e7          	jalr	-1432(ra) # 800033f6 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003996:	0485                	addi	s1,s1,1
    80003998:	00ca2703          	lw	a4,12(s4)
    8000399c:	0004879b          	sext.w	a5,s1
    800039a0:	fce7e1e3          	bltu	a5,a4,80003962 <ialloc+0x32>
  panic("ialloc: no inodes");
    800039a4:	00005517          	auipc	a0,0x5
    800039a8:	bfc50513          	addi	a0,a0,-1028 # 800085a0 <syscalls+0x170>
    800039ac:	ffffd097          	auipc	ra,0xffffd
    800039b0:	b84080e7          	jalr	-1148(ra) # 80000530 <panic>
      memset(dip, 0, sizeof(*dip));
    800039b4:	04000613          	li	a2,64
    800039b8:	4581                	li	a1,0
    800039ba:	854e                	mv	a0,s3
    800039bc:	ffffd097          	auipc	ra,0xffffd
    800039c0:	312080e7          	jalr	786(ra) # 80000cce <memset>
      dip->type = type;
    800039c4:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800039c8:	854a                	mv	a0,s2
    800039ca:	00001097          	auipc	ra,0x1
    800039ce:	ca8080e7          	jalr	-856(ra) # 80004672 <log_write>
      brelse(bp);
    800039d2:	854a                	mv	a0,s2
    800039d4:	00000097          	auipc	ra,0x0
    800039d8:	a22080e7          	jalr	-1502(ra) # 800033f6 <brelse>
      return iget(dev, inum);
    800039dc:	85da                	mv	a1,s6
    800039de:	8556                	mv	a0,s5
    800039e0:	00000097          	auipc	ra,0x0
    800039e4:	db4080e7          	jalr	-588(ra) # 80003794 <iget>
}
    800039e8:	60a6                	ld	ra,72(sp)
    800039ea:	6406                	ld	s0,64(sp)
    800039ec:	74e2                	ld	s1,56(sp)
    800039ee:	7942                	ld	s2,48(sp)
    800039f0:	79a2                	ld	s3,40(sp)
    800039f2:	7a02                	ld	s4,32(sp)
    800039f4:	6ae2                	ld	s5,24(sp)
    800039f6:	6b42                	ld	s6,16(sp)
    800039f8:	6ba2                	ld	s7,8(sp)
    800039fa:	6161                	addi	sp,sp,80
    800039fc:	8082                	ret

00000000800039fe <iupdate>:
{
    800039fe:	1101                	addi	sp,sp,-32
    80003a00:	ec06                	sd	ra,24(sp)
    80003a02:	e822                	sd	s0,16(sp)
    80003a04:	e426                	sd	s1,8(sp)
    80003a06:	e04a                	sd	s2,0(sp)
    80003a08:	1000                	addi	s0,sp,32
    80003a0a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a0c:	415c                	lw	a5,4(a0)
    80003a0e:	0047d79b          	srliw	a5,a5,0x4
    80003a12:	0001c597          	auipc	a1,0x1c
    80003a16:	ebe5a583          	lw	a1,-322(a1) # 8001f8d0 <sb+0x18>
    80003a1a:	9dbd                	addw	a1,a1,a5
    80003a1c:	4108                	lw	a0,0(a0)
    80003a1e:	00000097          	auipc	ra,0x0
    80003a22:	8a8080e7          	jalr	-1880(ra) # 800032c6 <bread>
    80003a26:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a28:	05850793          	addi	a5,a0,88
    80003a2c:	40c8                	lw	a0,4(s1)
    80003a2e:	893d                	andi	a0,a0,15
    80003a30:	051a                	slli	a0,a0,0x6
    80003a32:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003a34:	04449703          	lh	a4,68(s1)
    80003a38:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80003a3c:	04649703          	lh	a4,70(s1)
    80003a40:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003a44:	04849703          	lh	a4,72(s1)
    80003a48:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80003a4c:	04a49703          	lh	a4,74(s1)
    80003a50:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003a54:	44f8                	lw	a4,76(s1)
    80003a56:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003a58:	03400613          	li	a2,52
    80003a5c:	05048593          	addi	a1,s1,80
    80003a60:	0531                	addi	a0,a0,12
    80003a62:	ffffd097          	auipc	ra,0xffffd
    80003a66:	2cc080e7          	jalr	716(ra) # 80000d2e <memmove>
  log_write(bp);
    80003a6a:	854a                	mv	a0,s2
    80003a6c:	00001097          	auipc	ra,0x1
    80003a70:	c06080e7          	jalr	-1018(ra) # 80004672 <log_write>
  brelse(bp);
    80003a74:	854a                	mv	a0,s2
    80003a76:	00000097          	auipc	ra,0x0
    80003a7a:	980080e7          	jalr	-1664(ra) # 800033f6 <brelse>
}
    80003a7e:	60e2                	ld	ra,24(sp)
    80003a80:	6442                	ld	s0,16(sp)
    80003a82:	64a2                	ld	s1,8(sp)
    80003a84:	6902                	ld	s2,0(sp)
    80003a86:	6105                	addi	sp,sp,32
    80003a88:	8082                	ret

0000000080003a8a <idup>:
{
    80003a8a:	1101                	addi	sp,sp,-32
    80003a8c:	ec06                	sd	ra,24(sp)
    80003a8e:	e822                	sd	s0,16(sp)
    80003a90:	e426                	sd	s1,8(sp)
    80003a92:	1000                	addi	s0,sp,32
    80003a94:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a96:	0001c517          	auipc	a0,0x1c
    80003a9a:	e4250513          	addi	a0,a0,-446 # 8001f8d8 <itable>
    80003a9e:	ffffd097          	auipc	ra,0xffffd
    80003aa2:	134080e7          	jalr	308(ra) # 80000bd2 <acquire>
  ip->ref++;
    80003aa6:	449c                	lw	a5,8(s1)
    80003aa8:	2785                	addiw	a5,a5,1
    80003aaa:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003aac:	0001c517          	auipc	a0,0x1c
    80003ab0:	e2c50513          	addi	a0,a0,-468 # 8001f8d8 <itable>
    80003ab4:	ffffd097          	auipc	ra,0xffffd
    80003ab8:	1d2080e7          	jalr	466(ra) # 80000c86 <release>
}
    80003abc:	8526                	mv	a0,s1
    80003abe:	60e2                	ld	ra,24(sp)
    80003ac0:	6442                	ld	s0,16(sp)
    80003ac2:	64a2                	ld	s1,8(sp)
    80003ac4:	6105                	addi	sp,sp,32
    80003ac6:	8082                	ret

0000000080003ac8 <ilock>:
{
    80003ac8:	1101                	addi	sp,sp,-32
    80003aca:	ec06                	sd	ra,24(sp)
    80003acc:	e822                	sd	s0,16(sp)
    80003ace:	e426                	sd	s1,8(sp)
    80003ad0:	e04a                	sd	s2,0(sp)
    80003ad2:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003ad4:	c115                	beqz	a0,80003af8 <ilock+0x30>
    80003ad6:	84aa                	mv	s1,a0
    80003ad8:	451c                	lw	a5,8(a0)
    80003ada:	00f05f63          	blez	a5,80003af8 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003ade:	0541                	addi	a0,a0,16
    80003ae0:	00001097          	auipc	ra,0x1
    80003ae4:	cb2080e7          	jalr	-846(ra) # 80004792 <acquiresleep>
  if(ip->valid == 0){
    80003ae8:	40bc                	lw	a5,64(s1)
    80003aea:	cf99                	beqz	a5,80003b08 <ilock+0x40>
}
    80003aec:	60e2                	ld	ra,24(sp)
    80003aee:	6442                	ld	s0,16(sp)
    80003af0:	64a2                	ld	s1,8(sp)
    80003af2:	6902                	ld	s2,0(sp)
    80003af4:	6105                	addi	sp,sp,32
    80003af6:	8082                	ret
    panic("ilock");
    80003af8:	00005517          	auipc	a0,0x5
    80003afc:	ac050513          	addi	a0,a0,-1344 # 800085b8 <syscalls+0x188>
    80003b00:	ffffd097          	auipc	ra,0xffffd
    80003b04:	a30080e7          	jalr	-1488(ra) # 80000530 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b08:	40dc                	lw	a5,4(s1)
    80003b0a:	0047d79b          	srliw	a5,a5,0x4
    80003b0e:	0001c597          	auipc	a1,0x1c
    80003b12:	dc25a583          	lw	a1,-574(a1) # 8001f8d0 <sb+0x18>
    80003b16:	9dbd                	addw	a1,a1,a5
    80003b18:	4088                	lw	a0,0(s1)
    80003b1a:	fffff097          	auipc	ra,0xfffff
    80003b1e:	7ac080e7          	jalr	1964(ra) # 800032c6 <bread>
    80003b22:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b24:	05850593          	addi	a1,a0,88
    80003b28:	40dc                	lw	a5,4(s1)
    80003b2a:	8bbd                	andi	a5,a5,15
    80003b2c:	079a                	slli	a5,a5,0x6
    80003b2e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003b30:	00059783          	lh	a5,0(a1)
    80003b34:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003b38:	00259783          	lh	a5,2(a1)
    80003b3c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003b40:	00459783          	lh	a5,4(a1)
    80003b44:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003b48:	00659783          	lh	a5,6(a1)
    80003b4c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003b50:	459c                	lw	a5,8(a1)
    80003b52:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003b54:	03400613          	li	a2,52
    80003b58:	05b1                	addi	a1,a1,12
    80003b5a:	05048513          	addi	a0,s1,80
    80003b5e:	ffffd097          	auipc	ra,0xffffd
    80003b62:	1d0080e7          	jalr	464(ra) # 80000d2e <memmove>
    brelse(bp);
    80003b66:	854a                	mv	a0,s2
    80003b68:	00000097          	auipc	ra,0x0
    80003b6c:	88e080e7          	jalr	-1906(ra) # 800033f6 <brelse>
    ip->valid = 1;
    80003b70:	4785                	li	a5,1
    80003b72:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003b74:	04449783          	lh	a5,68(s1)
    80003b78:	fbb5                	bnez	a5,80003aec <ilock+0x24>
      panic("ilock: no type");
    80003b7a:	00005517          	auipc	a0,0x5
    80003b7e:	a4650513          	addi	a0,a0,-1466 # 800085c0 <syscalls+0x190>
    80003b82:	ffffd097          	auipc	ra,0xffffd
    80003b86:	9ae080e7          	jalr	-1618(ra) # 80000530 <panic>

0000000080003b8a <iunlock>:
{
    80003b8a:	1101                	addi	sp,sp,-32
    80003b8c:	ec06                	sd	ra,24(sp)
    80003b8e:	e822                	sd	s0,16(sp)
    80003b90:	e426                	sd	s1,8(sp)
    80003b92:	e04a                	sd	s2,0(sp)
    80003b94:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003b96:	c905                	beqz	a0,80003bc6 <iunlock+0x3c>
    80003b98:	84aa                	mv	s1,a0
    80003b9a:	01050913          	addi	s2,a0,16
    80003b9e:	854a                	mv	a0,s2
    80003ba0:	00001097          	auipc	ra,0x1
    80003ba4:	c8c080e7          	jalr	-884(ra) # 8000482c <holdingsleep>
    80003ba8:	cd19                	beqz	a0,80003bc6 <iunlock+0x3c>
    80003baa:	449c                	lw	a5,8(s1)
    80003bac:	00f05d63          	blez	a5,80003bc6 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003bb0:	854a                	mv	a0,s2
    80003bb2:	00001097          	auipc	ra,0x1
    80003bb6:	c36080e7          	jalr	-970(ra) # 800047e8 <releasesleep>
}
    80003bba:	60e2                	ld	ra,24(sp)
    80003bbc:	6442                	ld	s0,16(sp)
    80003bbe:	64a2                	ld	s1,8(sp)
    80003bc0:	6902                	ld	s2,0(sp)
    80003bc2:	6105                	addi	sp,sp,32
    80003bc4:	8082                	ret
    panic("iunlock");
    80003bc6:	00005517          	auipc	a0,0x5
    80003bca:	a0a50513          	addi	a0,a0,-1526 # 800085d0 <syscalls+0x1a0>
    80003bce:	ffffd097          	auipc	ra,0xffffd
    80003bd2:	962080e7          	jalr	-1694(ra) # 80000530 <panic>

0000000080003bd6 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003bd6:	7179                	addi	sp,sp,-48
    80003bd8:	f406                	sd	ra,40(sp)
    80003bda:	f022                	sd	s0,32(sp)
    80003bdc:	ec26                	sd	s1,24(sp)
    80003bde:	e84a                	sd	s2,16(sp)
    80003be0:	e44e                	sd	s3,8(sp)
    80003be2:	e052                	sd	s4,0(sp)
    80003be4:	1800                	addi	s0,sp,48
    80003be6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003be8:	05050493          	addi	s1,a0,80
    80003bec:	08050913          	addi	s2,a0,128
    80003bf0:	a021                	j	80003bf8 <itrunc+0x22>
    80003bf2:	0491                	addi	s1,s1,4
    80003bf4:	01248d63          	beq	s1,s2,80003c0e <itrunc+0x38>
    if(ip->addrs[i]){
    80003bf8:	408c                	lw	a1,0(s1)
    80003bfa:	dde5                	beqz	a1,80003bf2 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003bfc:	0009a503          	lw	a0,0(s3)
    80003c00:	00000097          	auipc	ra,0x0
    80003c04:	90c080e7          	jalr	-1780(ra) # 8000350c <bfree>
      ip->addrs[i] = 0;
    80003c08:	0004a023          	sw	zero,0(s1)
    80003c0c:	b7dd                	j	80003bf2 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003c0e:	0809a583          	lw	a1,128(s3)
    80003c12:	e185                	bnez	a1,80003c32 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003c14:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003c18:	854e                	mv	a0,s3
    80003c1a:	00000097          	auipc	ra,0x0
    80003c1e:	de4080e7          	jalr	-540(ra) # 800039fe <iupdate>
}
    80003c22:	70a2                	ld	ra,40(sp)
    80003c24:	7402                	ld	s0,32(sp)
    80003c26:	64e2                	ld	s1,24(sp)
    80003c28:	6942                	ld	s2,16(sp)
    80003c2a:	69a2                	ld	s3,8(sp)
    80003c2c:	6a02                	ld	s4,0(sp)
    80003c2e:	6145                	addi	sp,sp,48
    80003c30:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003c32:	0009a503          	lw	a0,0(s3)
    80003c36:	fffff097          	auipc	ra,0xfffff
    80003c3a:	690080e7          	jalr	1680(ra) # 800032c6 <bread>
    80003c3e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003c40:	05850493          	addi	s1,a0,88
    80003c44:	45850913          	addi	s2,a0,1112
    80003c48:	a811                	j	80003c5c <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003c4a:	0009a503          	lw	a0,0(s3)
    80003c4e:	00000097          	auipc	ra,0x0
    80003c52:	8be080e7          	jalr	-1858(ra) # 8000350c <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80003c56:	0491                	addi	s1,s1,4
    80003c58:	01248563          	beq	s1,s2,80003c62 <itrunc+0x8c>
      if(a[j])
    80003c5c:	408c                	lw	a1,0(s1)
    80003c5e:	dde5                	beqz	a1,80003c56 <itrunc+0x80>
    80003c60:	b7ed                	j	80003c4a <itrunc+0x74>
    brelse(bp);
    80003c62:	8552                	mv	a0,s4
    80003c64:	fffff097          	auipc	ra,0xfffff
    80003c68:	792080e7          	jalr	1938(ra) # 800033f6 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003c6c:	0809a583          	lw	a1,128(s3)
    80003c70:	0009a503          	lw	a0,0(s3)
    80003c74:	00000097          	auipc	ra,0x0
    80003c78:	898080e7          	jalr	-1896(ra) # 8000350c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003c7c:	0809a023          	sw	zero,128(s3)
    80003c80:	bf51                	j	80003c14 <itrunc+0x3e>

0000000080003c82 <iput>:
{
    80003c82:	1101                	addi	sp,sp,-32
    80003c84:	ec06                	sd	ra,24(sp)
    80003c86:	e822                	sd	s0,16(sp)
    80003c88:	e426                	sd	s1,8(sp)
    80003c8a:	e04a                	sd	s2,0(sp)
    80003c8c:	1000                	addi	s0,sp,32
    80003c8e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003c90:	0001c517          	auipc	a0,0x1c
    80003c94:	c4850513          	addi	a0,a0,-952 # 8001f8d8 <itable>
    80003c98:	ffffd097          	auipc	ra,0xffffd
    80003c9c:	f3a080e7          	jalr	-198(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003ca0:	4498                	lw	a4,8(s1)
    80003ca2:	4785                	li	a5,1
    80003ca4:	02f70363          	beq	a4,a5,80003cca <iput+0x48>
  ip->ref--;
    80003ca8:	449c                	lw	a5,8(s1)
    80003caa:	37fd                	addiw	a5,a5,-1
    80003cac:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003cae:	0001c517          	auipc	a0,0x1c
    80003cb2:	c2a50513          	addi	a0,a0,-982 # 8001f8d8 <itable>
    80003cb6:	ffffd097          	auipc	ra,0xffffd
    80003cba:	fd0080e7          	jalr	-48(ra) # 80000c86 <release>
}
    80003cbe:	60e2                	ld	ra,24(sp)
    80003cc0:	6442                	ld	s0,16(sp)
    80003cc2:	64a2                	ld	s1,8(sp)
    80003cc4:	6902                	ld	s2,0(sp)
    80003cc6:	6105                	addi	sp,sp,32
    80003cc8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003cca:	40bc                	lw	a5,64(s1)
    80003ccc:	dff1                	beqz	a5,80003ca8 <iput+0x26>
    80003cce:	04a49783          	lh	a5,74(s1)
    80003cd2:	fbf9                	bnez	a5,80003ca8 <iput+0x26>
    acquiresleep(&ip->lock);
    80003cd4:	01048913          	addi	s2,s1,16
    80003cd8:	854a                	mv	a0,s2
    80003cda:	00001097          	auipc	ra,0x1
    80003cde:	ab8080e7          	jalr	-1352(ra) # 80004792 <acquiresleep>
    release(&itable.lock);
    80003ce2:	0001c517          	auipc	a0,0x1c
    80003ce6:	bf650513          	addi	a0,a0,-1034 # 8001f8d8 <itable>
    80003cea:	ffffd097          	auipc	ra,0xffffd
    80003cee:	f9c080e7          	jalr	-100(ra) # 80000c86 <release>
    itrunc(ip);
    80003cf2:	8526                	mv	a0,s1
    80003cf4:	00000097          	auipc	ra,0x0
    80003cf8:	ee2080e7          	jalr	-286(ra) # 80003bd6 <itrunc>
    ip->type = 0;
    80003cfc:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003d00:	8526                	mv	a0,s1
    80003d02:	00000097          	auipc	ra,0x0
    80003d06:	cfc080e7          	jalr	-772(ra) # 800039fe <iupdate>
    ip->valid = 0;
    80003d0a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003d0e:	854a                	mv	a0,s2
    80003d10:	00001097          	auipc	ra,0x1
    80003d14:	ad8080e7          	jalr	-1320(ra) # 800047e8 <releasesleep>
    acquire(&itable.lock);
    80003d18:	0001c517          	auipc	a0,0x1c
    80003d1c:	bc050513          	addi	a0,a0,-1088 # 8001f8d8 <itable>
    80003d20:	ffffd097          	auipc	ra,0xffffd
    80003d24:	eb2080e7          	jalr	-334(ra) # 80000bd2 <acquire>
    80003d28:	b741                	j	80003ca8 <iput+0x26>

0000000080003d2a <iunlockput>:
{
    80003d2a:	1101                	addi	sp,sp,-32
    80003d2c:	ec06                	sd	ra,24(sp)
    80003d2e:	e822                	sd	s0,16(sp)
    80003d30:	e426                	sd	s1,8(sp)
    80003d32:	1000                	addi	s0,sp,32
    80003d34:	84aa                	mv	s1,a0
  iunlock(ip);
    80003d36:	00000097          	auipc	ra,0x0
    80003d3a:	e54080e7          	jalr	-428(ra) # 80003b8a <iunlock>
  iput(ip);
    80003d3e:	8526                	mv	a0,s1
    80003d40:	00000097          	auipc	ra,0x0
    80003d44:	f42080e7          	jalr	-190(ra) # 80003c82 <iput>
}
    80003d48:	60e2                	ld	ra,24(sp)
    80003d4a:	6442                	ld	s0,16(sp)
    80003d4c:	64a2                	ld	s1,8(sp)
    80003d4e:	6105                	addi	sp,sp,32
    80003d50:	8082                	ret

0000000080003d52 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003d52:	1141                	addi	sp,sp,-16
    80003d54:	e422                	sd	s0,8(sp)
    80003d56:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003d58:	411c                	lw	a5,0(a0)
    80003d5a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003d5c:	415c                	lw	a5,4(a0)
    80003d5e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003d60:	04451783          	lh	a5,68(a0)
    80003d64:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003d68:	04a51783          	lh	a5,74(a0)
    80003d6c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003d70:	04c56783          	lwu	a5,76(a0)
    80003d74:	e99c                	sd	a5,16(a1)
}
    80003d76:	6422                	ld	s0,8(sp)
    80003d78:	0141                	addi	sp,sp,16
    80003d7a:	8082                	ret

0000000080003d7c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003d7c:	457c                	lw	a5,76(a0)
    80003d7e:	0ed7e963          	bltu	a5,a3,80003e70 <readi+0xf4>
{
    80003d82:	7159                	addi	sp,sp,-112
    80003d84:	f486                	sd	ra,104(sp)
    80003d86:	f0a2                	sd	s0,96(sp)
    80003d88:	eca6                	sd	s1,88(sp)
    80003d8a:	e8ca                	sd	s2,80(sp)
    80003d8c:	e4ce                	sd	s3,72(sp)
    80003d8e:	e0d2                	sd	s4,64(sp)
    80003d90:	fc56                	sd	s5,56(sp)
    80003d92:	f85a                	sd	s6,48(sp)
    80003d94:	f45e                	sd	s7,40(sp)
    80003d96:	f062                	sd	s8,32(sp)
    80003d98:	ec66                	sd	s9,24(sp)
    80003d9a:	e86a                	sd	s10,16(sp)
    80003d9c:	e46e                	sd	s11,8(sp)
    80003d9e:	1880                	addi	s0,sp,112
    80003da0:	8baa                	mv	s7,a0
    80003da2:	8c2e                	mv	s8,a1
    80003da4:	8ab2                	mv	s5,a2
    80003da6:	84b6                	mv	s1,a3
    80003da8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003daa:	9f35                	addw	a4,a4,a3
    return 0;
    80003dac:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003dae:	0ad76063          	bltu	a4,a3,80003e4e <readi+0xd2>
  if(off + n > ip->size)
    80003db2:	00e7f463          	bgeu	a5,a4,80003dba <readi+0x3e>
    n = ip->size - off;
    80003db6:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003dba:	0a0b0963          	beqz	s6,80003e6c <readi+0xf0>
    80003dbe:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003dc0:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003dc4:	5cfd                	li	s9,-1
    80003dc6:	a82d                	j	80003e00 <readi+0x84>
    80003dc8:	020a1d93          	slli	s11,s4,0x20
    80003dcc:	020ddd93          	srli	s11,s11,0x20
    80003dd0:	05890613          	addi	a2,s2,88
    80003dd4:	86ee                	mv	a3,s11
    80003dd6:	963a                	add	a2,a2,a4
    80003dd8:	85d6                	mv	a1,s5
    80003dda:	8562                	mv	a0,s8
    80003ddc:	fffff097          	auipc	ra,0xfffff
    80003de0:	a2e080e7          	jalr	-1490(ra) # 8000280a <either_copyout>
    80003de4:	05950d63          	beq	a0,s9,80003e3e <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003de8:	854a                	mv	a0,s2
    80003dea:	fffff097          	auipc	ra,0xfffff
    80003dee:	60c080e7          	jalr	1548(ra) # 800033f6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003df2:	013a09bb          	addw	s3,s4,s3
    80003df6:	009a04bb          	addw	s1,s4,s1
    80003dfa:	9aee                	add	s5,s5,s11
    80003dfc:	0569f763          	bgeu	s3,s6,80003e4a <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003e00:	000ba903          	lw	s2,0(s7)
    80003e04:	00a4d59b          	srliw	a1,s1,0xa
    80003e08:	855e                	mv	a0,s7
    80003e0a:	00000097          	auipc	ra,0x0
    80003e0e:	8b0080e7          	jalr	-1872(ra) # 800036ba <bmap>
    80003e12:	0005059b          	sext.w	a1,a0
    80003e16:	854a                	mv	a0,s2
    80003e18:	fffff097          	auipc	ra,0xfffff
    80003e1c:	4ae080e7          	jalr	1198(ra) # 800032c6 <bread>
    80003e20:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e22:	3ff4f713          	andi	a4,s1,1023
    80003e26:	40ed07bb          	subw	a5,s10,a4
    80003e2a:	413b06bb          	subw	a3,s6,s3
    80003e2e:	8a3e                	mv	s4,a5
    80003e30:	2781                	sext.w	a5,a5
    80003e32:	0006861b          	sext.w	a2,a3
    80003e36:	f8f679e3          	bgeu	a2,a5,80003dc8 <readi+0x4c>
    80003e3a:	8a36                	mv	s4,a3
    80003e3c:	b771                	j	80003dc8 <readi+0x4c>
      brelse(bp);
    80003e3e:	854a                	mv	a0,s2
    80003e40:	fffff097          	auipc	ra,0xfffff
    80003e44:	5b6080e7          	jalr	1462(ra) # 800033f6 <brelse>
      tot = -1;
    80003e48:	59fd                	li	s3,-1
  }
  return tot;
    80003e4a:	0009851b          	sext.w	a0,s3
}
    80003e4e:	70a6                	ld	ra,104(sp)
    80003e50:	7406                	ld	s0,96(sp)
    80003e52:	64e6                	ld	s1,88(sp)
    80003e54:	6946                	ld	s2,80(sp)
    80003e56:	69a6                	ld	s3,72(sp)
    80003e58:	6a06                	ld	s4,64(sp)
    80003e5a:	7ae2                	ld	s5,56(sp)
    80003e5c:	7b42                	ld	s6,48(sp)
    80003e5e:	7ba2                	ld	s7,40(sp)
    80003e60:	7c02                	ld	s8,32(sp)
    80003e62:	6ce2                	ld	s9,24(sp)
    80003e64:	6d42                	ld	s10,16(sp)
    80003e66:	6da2                	ld	s11,8(sp)
    80003e68:	6165                	addi	sp,sp,112
    80003e6a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e6c:	89da                	mv	s3,s6
    80003e6e:	bff1                	j	80003e4a <readi+0xce>
    return 0;
    80003e70:	4501                	li	a0,0
}
    80003e72:	8082                	ret

0000000080003e74 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e74:	457c                	lw	a5,76(a0)
    80003e76:	10d7e863          	bltu	a5,a3,80003f86 <writei+0x112>
{
    80003e7a:	7159                	addi	sp,sp,-112
    80003e7c:	f486                	sd	ra,104(sp)
    80003e7e:	f0a2                	sd	s0,96(sp)
    80003e80:	eca6                	sd	s1,88(sp)
    80003e82:	e8ca                	sd	s2,80(sp)
    80003e84:	e4ce                	sd	s3,72(sp)
    80003e86:	e0d2                	sd	s4,64(sp)
    80003e88:	fc56                	sd	s5,56(sp)
    80003e8a:	f85a                	sd	s6,48(sp)
    80003e8c:	f45e                	sd	s7,40(sp)
    80003e8e:	f062                	sd	s8,32(sp)
    80003e90:	ec66                	sd	s9,24(sp)
    80003e92:	e86a                	sd	s10,16(sp)
    80003e94:	e46e                	sd	s11,8(sp)
    80003e96:	1880                	addi	s0,sp,112
    80003e98:	8b2a                	mv	s6,a0
    80003e9a:	8c2e                	mv	s8,a1
    80003e9c:	8ab2                	mv	s5,a2
    80003e9e:	8936                	mv	s2,a3
    80003ea0:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80003ea2:	00e687bb          	addw	a5,a3,a4
    80003ea6:	0ed7e263          	bltu	a5,a3,80003f8a <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003eaa:	00043737          	lui	a4,0x43
    80003eae:	0ef76063          	bltu	a4,a5,80003f8e <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003eb2:	0c0b8863          	beqz	s7,80003f82 <writei+0x10e>
    80003eb6:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003eb8:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ebc:	5cfd                	li	s9,-1
    80003ebe:	a091                	j	80003f02 <writei+0x8e>
    80003ec0:	02099d93          	slli	s11,s3,0x20
    80003ec4:	020ddd93          	srli	s11,s11,0x20
    80003ec8:	05848513          	addi	a0,s1,88
    80003ecc:	86ee                	mv	a3,s11
    80003ece:	8656                	mv	a2,s5
    80003ed0:	85e2                	mv	a1,s8
    80003ed2:	953a                	add	a0,a0,a4
    80003ed4:	fffff097          	auipc	ra,0xfffff
    80003ed8:	98c080e7          	jalr	-1652(ra) # 80002860 <either_copyin>
    80003edc:	07950263          	beq	a0,s9,80003f40 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ee0:	8526                	mv	a0,s1
    80003ee2:	00000097          	auipc	ra,0x0
    80003ee6:	790080e7          	jalr	1936(ra) # 80004672 <log_write>
    brelse(bp);
    80003eea:	8526                	mv	a0,s1
    80003eec:	fffff097          	auipc	ra,0xfffff
    80003ef0:	50a080e7          	jalr	1290(ra) # 800033f6 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ef4:	01498a3b          	addw	s4,s3,s4
    80003ef8:	0129893b          	addw	s2,s3,s2
    80003efc:	9aee                	add	s5,s5,s11
    80003efe:	057a7663          	bgeu	s4,s7,80003f4a <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003f02:	000b2483          	lw	s1,0(s6)
    80003f06:	00a9559b          	srliw	a1,s2,0xa
    80003f0a:	855a                	mv	a0,s6
    80003f0c:	fffff097          	auipc	ra,0xfffff
    80003f10:	7ae080e7          	jalr	1966(ra) # 800036ba <bmap>
    80003f14:	0005059b          	sext.w	a1,a0
    80003f18:	8526                	mv	a0,s1
    80003f1a:	fffff097          	auipc	ra,0xfffff
    80003f1e:	3ac080e7          	jalr	940(ra) # 800032c6 <bread>
    80003f22:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f24:	3ff97713          	andi	a4,s2,1023
    80003f28:	40ed07bb          	subw	a5,s10,a4
    80003f2c:	414b86bb          	subw	a3,s7,s4
    80003f30:	89be                	mv	s3,a5
    80003f32:	2781                	sext.w	a5,a5
    80003f34:	0006861b          	sext.w	a2,a3
    80003f38:	f8f674e3          	bgeu	a2,a5,80003ec0 <writei+0x4c>
    80003f3c:	89b6                	mv	s3,a3
    80003f3e:	b749                	j	80003ec0 <writei+0x4c>
      brelse(bp);
    80003f40:	8526                	mv	a0,s1
    80003f42:	fffff097          	auipc	ra,0xfffff
    80003f46:	4b4080e7          	jalr	1204(ra) # 800033f6 <brelse>
  }

  if(off > ip->size)
    80003f4a:	04cb2783          	lw	a5,76(s6)
    80003f4e:	0127f463          	bgeu	a5,s2,80003f56 <writei+0xe2>
    ip->size = off;
    80003f52:	052b2623          	sw	s2,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003f56:	855a                	mv	a0,s6
    80003f58:	00000097          	auipc	ra,0x0
    80003f5c:	aa6080e7          	jalr	-1370(ra) # 800039fe <iupdate>

  return tot;
    80003f60:	000a051b          	sext.w	a0,s4
}
    80003f64:	70a6                	ld	ra,104(sp)
    80003f66:	7406                	ld	s0,96(sp)
    80003f68:	64e6                	ld	s1,88(sp)
    80003f6a:	6946                	ld	s2,80(sp)
    80003f6c:	69a6                	ld	s3,72(sp)
    80003f6e:	6a06                	ld	s4,64(sp)
    80003f70:	7ae2                	ld	s5,56(sp)
    80003f72:	7b42                	ld	s6,48(sp)
    80003f74:	7ba2                	ld	s7,40(sp)
    80003f76:	7c02                	ld	s8,32(sp)
    80003f78:	6ce2                	ld	s9,24(sp)
    80003f7a:	6d42                	ld	s10,16(sp)
    80003f7c:	6da2                	ld	s11,8(sp)
    80003f7e:	6165                	addi	sp,sp,112
    80003f80:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f82:	8a5e                	mv	s4,s7
    80003f84:	bfc9                	j	80003f56 <writei+0xe2>
    return -1;
    80003f86:	557d                	li	a0,-1
}
    80003f88:	8082                	ret
    return -1;
    80003f8a:	557d                	li	a0,-1
    80003f8c:	bfe1                	j	80003f64 <writei+0xf0>
    return -1;
    80003f8e:	557d                	li	a0,-1
    80003f90:	bfd1                	j	80003f64 <writei+0xf0>

0000000080003f92 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003f92:	1141                	addi	sp,sp,-16
    80003f94:	e406                	sd	ra,8(sp)
    80003f96:	e022                	sd	s0,0(sp)
    80003f98:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003f9a:	4639                	li	a2,14
    80003f9c:	ffffd097          	auipc	ra,0xffffd
    80003fa0:	e0e080e7          	jalr	-498(ra) # 80000daa <strncmp>
}
    80003fa4:	60a2                	ld	ra,8(sp)
    80003fa6:	6402                	ld	s0,0(sp)
    80003fa8:	0141                	addi	sp,sp,16
    80003faa:	8082                	ret

0000000080003fac <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003fac:	7139                	addi	sp,sp,-64
    80003fae:	fc06                	sd	ra,56(sp)
    80003fb0:	f822                	sd	s0,48(sp)
    80003fb2:	f426                	sd	s1,40(sp)
    80003fb4:	f04a                	sd	s2,32(sp)
    80003fb6:	ec4e                	sd	s3,24(sp)
    80003fb8:	e852                	sd	s4,16(sp)
    80003fba:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003fbc:	04451703          	lh	a4,68(a0)
    80003fc0:	4785                	li	a5,1
    80003fc2:	00f71a63          	bne	a4,a5,80003fd6 <dirlookup+0x2a>
    80003fc6:	892a                	mv	s2,a0
    80003fc8:	89ae                	mv	s3,a1
    80003fca:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fcc:	457c                	lw	a5,76(a0)
    80003fce:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003fd0:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fd2:	e79d                	bnez	a5,80004000 <dirlookup+0x54>
    80003fd4:	a8a5                	j	8000404c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003fd6:	00004517          	auipc	a0,0x4
    80003fda:	60250513          	addi	a0,a0,1538 # 800085d8 <syscalls+0x1a8>
    80003fde:	ffffc097          	auipc	ra,0xffffc
    80003fe2:	552080e7          	jalr	1362(ra) # 80000530 <panic>
      panic("dirlookup read");
    80003fe6:	00004517          	auipc	a0,0x4
    80003fea:	60a50513          	addi	a0,a0,1546 # 800085f0 <syscalls+0x1c0>
    80003fee:	ffffc097          	auipc	ra,0xffffc
    80003ff2:	542080e7          	jalr	1346(ra) # 80000530 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ff6:	24c1                	addiw	s1,s1,16
    80003ff8:	04c92783          	lw	a5,76(s2)
    80003ffc:	04f4f763          	bgeu	s1,a5,8000404a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004000:	4741                	li	a4,16
    80004002:	86a6                	mv	a3,s1
    80004004:	fc040613          	addi	a2,s0,-64
    80004008:	4581                	li	a1,0
    8000400a:	854a                	mv	a0,s2
    8000400c:	00000097          	auipc	ra,0x0
    80004010:	d70080e7          	jalr	-656(ra) # 80003d7c <readi>
    80004014:	47c1                	li	a5,16
    80004016:	fcf518e3          	bne	a0,a5,80003fe6 <dirlookup+0x3a>
    if(de.inum == 0)
    8000401a:	fc045783          	lhu	a5,-64(s0)
    8000401e:	dfe1                	beqz	a5,80003ff6 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80004020:	fc240593          	addi	a1,s0,-62
    80004024:	854e                	mv	a0,s3
    80004026:	00000097          	auipc	ra,0x0
    8000402a:	f6c080e7          	jalr	-148(ra) # 80003f92 <namecmp>
    8000402e:	f561                	bnez	a0,80003ff6 <dirlookup+0x4a>
      if(poff)
    80004030:	000a0463          	beqz	s4,80004038 <dirlookup+0x8c>
        *poff = off;
    80004034:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004038:	fc045583          	lhu	a1,-64(s0)
    8000403c:	00092503          	lw	a0,0(s2)
    80004040:	fffff097          	auipc	ra,0xfffff
    80004044:	754080e7          	jalr	1876(ra) # 80003794 <iget>
    80004048:	a011                	j	8000404c <dirlookup+0xa0>
  return 0;
    8000404a:	4501                	li	a0,0
}
    8000404c:	70e2                	ld	ra,56(sp)
    8000404e:	7442                	ld	s0,48(sp)
    80004050:	74a2                	ld	s1,40(sp)
    80004052:	7902                	ld	s2,32(sp)
    80004054:	69e2                	ld	s3,24(sp)
    80004056:	6a42                	ld	s4,16(sp)
    80004058:	6121                	addi	sp,sp,64
    8000405a:	8082                	ret

000000008000405c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000405c:	711d                	addi	sp,sp,-96
    8000405e:	ec86                	sd	ra,88(sp)
    80004060:	e8a2                	sd	s0,80(sp)
    80004062:	e4a6                	sd	s1,72(sp)
    80004064:	e0ca                	sd	s2,64(sp)
    80004066:	fc4e                	sd	s3,56(sp)
    80004068:	f852                	sd	s4,48(sp)
    8000406a:	f456                	sd	s5,40(sp)
    8000406c:	f05a                	sd	s6,32(sp)
    8000406e:	ec5e                	sd	s7,24(sp)
    80004070:	e862                	sd	s8,16(sp)
    80004072:	e466                	sd	s9,8(sp)
    80004074:	1080                	addi	s0,sp,96
    80004076:	84aa                	mv	s1,a0
    80004078:	8b2e                	mv	s6,a1
    8000407a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000407c:	00054703          	lbu	a4,0(a0)
    80004080:	02f00793          	li	a5,47
    80004084:	02f70363          	beq	a4,a5,800040aa <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004088:	ffffe097          	auipc	ra,0xffffe
    8000408c:	9fa080e7          	jalr	-1542(ra) # 80001a82 <myproc>
    80004090:	15053503          	ld	a0,336(a0)
    80004094:	00000097          	auipc	ra,0x0
    80004098:	9f6080e7          	jalr	-1546(ra) # 80003a8a <idup>
    8000409c:	89aa                	mv	s3,a0
  while(*path == '/')
    8000409e:	02f00913          	li	s2,47
  len = path - s;
    800040a2:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    800040a4:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800040a6:	4c05                	li	s8,1
    800040a8:	a865                	j	80004160 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800040aa:	4585                	li	a1,1
    800040ac:	4505                	li	a0,1
    800040ae:	fffff097          	auipc	ra,0xfffff
    800040b2:	6e6080e7          	jalr	1766(ra) # 80003794 <iget>
    800040b6:	89aa                	mv	s3,a0
    800040b8:	b7dd                	j	8000409e <namex+0x42>
      iunlockput(ip);
    800040ba:	854e                	mv	a0,s3
    800040bc:	00000097          	auipc	ra,0x0
    800040c0:	c6e080e7          	jalr	-914(ra) # 80003d2a <iunlockput>
      return 0;
    800040c4:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800040c6:	854e                	mv	a0,s3
    800040c8:	60e6                	ld	ra,88(sp)
    800040ca:	6446                	ld	s0,80(sp)
    800040cc:	64a6                	ld	s1,72(sp)
    800040ce:	6906                	ld	s2,64(sp)
    800040d0:	79e2                	ld	s3,56(sp)
    800040d2:	7a42                	ld	s4,48(sp)
    800040d4:	7aa2                	ld	s5,40(sp)
    800040d6:	7b02                	ld	s6,32(sp)
    800040d8:	6be2                	ld	s7,24(sp)
    800040da:	6c42                	ld	s8,16(sp)
    800040dc:	6ca2                	ld	s9,8(sp)
    800040de:	6125                	addi	sp,sp,96
    800040e0:	8082                	ret
      iunlock(ip);
    800040e2:	854e                	mv	a0,s3
    800040e4:	00000097          	auipc	ra,0x0
    800040e8:	aa6080e7          	jalr	-1370(ra) # 80003b8a <iunlock>
      return ip;
    800040ec:	bfe9                	j	800040c6 <namex+0x6a>
      iunlockput(ip);
    800040ee:	854e                	mv	a0,s3
    800040f0:	00000097          	auipc	ra,0x0
    800040f4:	c3a080e7          	jalr	-966(ra) # 80003d2a <iunlockput>
      return 0;
    800040f8:	89d2                	mv	s3,s4
    800040fa:	b7f1                	j	800040c6 <namex+0x6a>
  len = path - s;
    800040fc:	40b48633          	sub	a2,s1,a1
    80004100:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    80004104:	094cd463          	bge	s9,s4,8000418c <namex+0x130>
    memmove(name, s, DIRSIZ);
    80004108:	4639                	li	a2,14
    8000410a:	8556                	mv	a0,s5
    8000410c:	ffffd097          	auipc	ra,0xffffd
    80004110:	c22080e7          	jalr	-990(ra) # 80000d2e <memmove>
  while(*path == '/')
    80004114:	0004c783          	lbu	a5,0(s1)
    80004118:	01279763          	bne	a5,s2,80004126 <namex+0xca>
    path++;
    8000411c:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000411e:	0004c783          	lbu	a5,0(s1)
    80004122:	ff278de3          	beq	a5,s2,8000411c <namex+0xc0>
    ilock(ip);
    80004126:	854e                	mv	a0,s3
    80004128:	00000097          	auipc	ra,0x0
    8000412c:	9a0080e7          	jalr	-1632(ra) # 80003ac8 <ilock>
    if(ip->type != T_DIR){
    80004130:	04499783          	lh	a5,68(s3)
    80004134:	f98793e3          	bne	a5,s8,800040ba <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80004138:	000b0563          	beqz	s6,80004142 <namex+0xe6>
    8000413c:	0004c783          	lbu	a5,0(s1)
    80004140:	d3cd                	beqz	a5,800040e2 <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004142:	865e                	mv	a2,s7
    80004144:	85d6                	mv	a1,s5
    80004146:	854e                	mv	a0,s3
    80004148:	00000097          	auipc	ra,0x0
    8000414c:	e64080e7          	jalr	-412(ra) # 80003fac <dirlookup>
    80004150:	8a2a                	mv	s4,a0
    80004152:	dd51                	beqz	a0,800040ee <namex+0x92>
    iunlockput(ip);
    80004154:	854e                	mv	a0,s3
    80004156:	00000097          	auipc	ra,0x0
    8000415a:	bd4080e7          	jalr	-1068(ra) # 80003d2a <iunlockput>
    ip = next;
    8000415e:	89d2                	mv	s3,s4
  while(*path == '/')
    80004160:	0004c783          	lbu	a5,0(s1)
    80004164:	05279763          	bne	a5,s2,800041b2 <namex+0x156>
    path++;
    80004168:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000416a:	0004c783          	lbu	a5,0(s1)
    8000416e:	ff278de3          	beq	a5,s2,80004168 <namex+0x10c>
  if(*path == 0)
    80004172:	c79d                	beqz	a5,800041a0 <namex+0x144>
    path++;
    80004174:	85a6                	mv	a1,s1
  len = path - s;
    80004176:	8a5e                	mv	s4,s7
    80004178:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    8000417a:	01278963          	beq	a5,s2,8000418c <namex+0x130>
    8000417e:	dfbd                	beqz	a5,800040fc <namex+0xa0>
    path++;
    80004180:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80004182:	0004c783          	lbu	a5,0(s1)
    80004186:	ff279ce3          	bne	a5,s2,8000417e <namex+0x122>
    8000418a:	bf8d                	j	800040fc <namex+0xa0>
    memmove(name, s, len);
    8000418c:	2601                	sext.w	a2,a2
    8000418e:	8556                	mv	a0,s5
    80004190:	ffffd097          	auipc	ra,0xffffd
    80004194:	b9e080e7          	jalr	-1122(ra) # 80000d2e <memmove>
    name[len] = 0;
    80004198:	9a56                	add	s4,s4,s5
    8000419a:	000a0023          	sb	zero,0(s4)
    8000419e:	bf9d                	j	80004114 <namex+0xb8>
  if(nameiparent){
    800041a0:	f20b03e3          	beqz	s6,800040c6 <namex+0x6a>
    iput(ip);
    800041a4:	854e                	mv	a0,s3
    800041a6:	00000097          	auipc	ra,0x0
    800041aa:	adc080e7          	jalr	-1316(ra) # 80003c82 <iput>
    return 0;
    800041ae:	4981                	li	s3,0
    800041b0:	bf19                	j	800040c6 <namex+0x6a>
  if(*path == 0)
    800041b2:	d7fd                	beqz	a5,800041a0 <namex+0x144>
  while(*path != '/' && *path != 0)
    800041b4:	0004c783          	lbu	a5,0(s1)
    800041b8:	85a6                	mv	a1,s1
    800041ba:	b7d1                	j	8000417e <namex+0x122>

00000000800041bc <dirlink>:
{
    800041bc:	7139                	addi	sp,sp,-64
    800041be:	fc06                	sd	ra,56(sp)
    800041c0:	f822                	sd	s0,48(sp)
    800041c2:	f426                	sd	s1,40(sp)
    800041c4:	f04a                	sd	s2,32(sp)
    800041c6:	ec4e                	sd	s3,24(sp)
    800041c8:	e852                	sd	s4,16(sp)
    800041ca:	0080                	addi	s0,sp,64
    800041cc:	892a                	mv	s2,a0
    800041ce:	8a2e                	mv	s4,a1
    800041d0:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800041d2:	4601                	li	a2,0
    800041d4:	00000097          	auipc	ra,0x0
    800041d8:	dd8080e7          	jalr	-552(ra) # 80003fac <dirlookup>
    800041dc:	e93d                	bnez	a0,80004252 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041de:	04c92483          	lw	s1,76(s2)
    800041e2:	c49d                	beqz	s1,80004210 <dirlink+0x54>
    800041e4:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041e6:	4741                	li	a4,16
    800041e8:	86a6                	mv	a3,s1
    800041ea:	fc040613          	addi	a2,s0,-64
    800041ee:	4581                	li	a1,0
    800041f0:	854a                	mv	a0,s2
    800041f2:	00000097          	auipc	ra,0x0
    800041f6:	b8a080e7          	jalr	-1142(ra) # 80003d7c <readi>
    800041fa:	47c1                	li	a5,16
    800041fc:	06f51163          	bne	a0,a5,8000425e <dirlink+0xa2>
    if(de.inum == 0)
    80004200:	fc045783          	lhu	a5,-64(s0)
    80004204:	c791                	beqz	a5,80004210 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004206:	24c1                	addiw	s1,s1,16
    80004208:	04c92783          	lw	a5,76(s2)
    8000420c:	fcf4ede3          	bltu	s1,a5,800041e6 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004210:	4639                	li	a2,14
    80004212:	85d2                	mv	a1,s4
    80004214:	fc240513          	addi	a0,s0,-62
    80004218:	ffffd097          	auipc	ra,0xffffd
    8000421c:	bce080e7          	jalr	-1074(ra) # 80000de6 <strncpy>
  de.inum = inum;
    80004220:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004224:	4741                	li	a4,16
    80004226:	86a6                	mv	a3,s1
    80004228:	fc040613          	addi	a2,s0,-64
    8000422c:	4581                	li	a1,0
    8000422e:	854a                	mv	a0,s2
    80004230:	00000097          	auipc	ra,0x0
    80004234:	c44080e7          	jalr	-956(ra) # 80003e74 <writei>
    80004238:	872a                	mv	a4,a0
    8000423a:	47c1                	li	a5,16
  return 0;
    8000423c:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000423e:	02f71863          	bne	a4,a5,8000426e <dirlink+0xb2>
}
    80004242:	70e2                	ld	ra,56(sp)
    80004244:	7442                	ld	s0,48(sp)
    80004246:	74a2                	ld	s1,40(sp)
    80004248:	7902                	ld	s2,32(sp)
    8000424a:	69e2                	ld	s3,24(sp)
    8000424c:	6a42                	ld	s4,16(sp)
    8000424e:	6121                	addi	sp,sp,64
    80004250:	8082                	ret
    iput(ip);
    80004252:	00000097          	auipc	ra,0x0
    80004256:	a30080e7          	jalr	-1488(ra) # 80003c82 <iput>
    return -1;
    8000425a:	557d                	li	a0,-1
    8000425c:	b7dd                	j	80004242 <dirlink+0x86>
      panic("dirlink read");
    8000425e:	00004517          	auipc	a0,0x4
    80004262:	3a250513          	addi	a0,a0,930 # 80008600 <syscalls+0x1d0>
    80004266:	ffffc097          	auipc	ra,0xffffc
    8000426a:	2ca080e7          	jalr	714(ra) # 80000530 <panic>
    panic("dirlink");
    8000426e:	00004517          	auipc	a0,0x4
    80004272:	4a250513          	addi	a0,a0,1186 # 80008710 <syscalls+0x2e0>
    80004276:	ffffc097          	auipc	ra,0xffffc
    8000427a:	2ba080e7          	jalr	698(ra) # 80000530 <panic>

000000008000427e <namei>:

struct inode*
namei(char *path)
{
    8000427e:	1101                	addi	sp,sp,-32
    80004280:	ec06                	sd	ra,24(sp)
    80004282:	e822                	sd	s0,16(sp)
    80004284:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004286:	fe040613          	addi	a2,s0,-32
    8000428a:	4581                	li	a1,0
    8000428c:	00000097          	auipc	ra,0x0
    80004290:	dd0080e7          	jalr	-560(ra) # 8000405c <namex>
}
    80004294:	60e2                	ld	ra,24(sp)
    80004296:	6442                	ld	s0,16(sp)
    80004298:	6105                	addi	sp,sp,32
    8000429a:	8082                	ret

000000008000429c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000429c:	1141                	addi	sp,sp,-16
    8000429e:	e406                	sd	ra,8(sp)
    800042a0:	e022                	sd	s0,0(sp)
    800042a2:	0800                	addi	s0,sp,16
    800042a4:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800042a6:	4585                	li	a1,1
    800042a8:	00000097          	auipc	ra,0x0
    800042ac:	db4080e7          	jalr	-588(ra) # 8000405c <namex>
}
    800042b0:	60a2                	ld	ra,8(sp)
    800042b2:	6402                	ld	s0,0(sp)
    800042b4:	0141                	addi	sp,sp,16
    800042b6:	8082                	ret

00000000800042b8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800042b8:	1101                	addi	sp,sp,-32
    800042ba:	ec06                	sd	ra,24(sp)
    800042bc:	e822                	sd	s0,16(sp)
    800042be:	e426                	sd	s1,8(sp)
    800042c0:	e04a                	sd	s2,0(sp)
    800042c2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800042c4:	0001d917          	auipc	s2,0x1d
    800042c8:	0bc90913          	addi	s2,s2,188 # 80021380 <log>
    800042cc:	01892583          	lw	a1,24(s2)
    800042d0:	02892503          	lw	a0,40(s2)
    800042d4:	fffff097          	auipc	ra,0xfffff
    800042d8:	ff2080e7          	jalr	-14(ra) # 800032c6 <bread>
    800042dc:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800042de:	02c92683          	lw	a3,44(s2)
    800042e2:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800042e4:	02d05763          	blez	a3,80004312 <write_head+0x5a>
    800042e8:	0001d797          	auipc	a5,0x1d
    800042ec:	0c878793          	addi	a5,a5,200 # 800213b0 <log+0x30>
    800042f0:	05c50713          	addi	a4,a0,92
    800042f4:	36fd                	addiw	a3,a3,-1
    800042f6:	1682                	slli	a3,a3,0x20
    800042f8:	9281                	srli	a3,a3,0x20
    800042fa:	068a                	slli	a3,a3,0x2
    800042fc:	0001d617          	auipc	a2,0x1d
    80004300:	0b860613          	addi	a2,a2,184 # 800213b4 <log+0x34>
    80004304:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004306:	4390                	lw	a2,0(a5)
    80004308:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000430a:	0791                	addi	a5,a5,4
    8000430c:	0711                	addi	a4,a4,4
    8000430e:	fed79ce3          	bne	a5,a3,80004306 <write_head+0x4e>
  }
  bwrite(buf);
    80004312:	8526                	mv	a0,s1
    80004314:	fffff097          	auipc	ra,0xfffff
    80004318:	0a4080e7          	jalr	164(ra) # 800033b8 <bwrite>
  brelse(buf);
    8000431c:	8526                	mv	a0,s1
    8000431e:	fffff097          	auipc	ra,0xfffff
    80004322:	0d8080e7          	jalr	216(ra) # 800033f6 <brelse>
}
    80004326:	60e2                	ld	ra,24(sp)
    80004328:	6442                	ld	s0,16(sp)
    8000432a:	64a2                	ld	s1,8(sp)
    8000432c:	6902                	ld	s2,0(sp)
    8000432e:	6105                	addi	sp,sp,32
    80004330:	8082                	ret

0000000080004332 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004332:	0001d797          	auipc	a5,0x1d
    80004336:	07a7a783          	lw	a5,122(a5) # 800213ac <log+0x2c>
    8000433a:	0af05d63          	blez	a5,800043f4 <install_trans+0xc2>
{
    8000433e:	7139                	addi	sp,sp,-64
    80004340:	fc06                	sd	ra,56(sp)
    80004342:	f822                	sd	s0,48(sp)
    80004344:	f426                	sd	s1,40(sp)
    80004346:	f04a                	sd	s2,32(sp)
    80004348:	ec4e                	sd	s3,24(sp)
    8000434a:	e852                	sd	s4,16(sp)
    8000434c:	e456                	sd	s5,8(sp)
    8000434e:	e05a                	sd	s6,0(sp)
    80004350:	0080                	addi	s0,sp,64
    80004352:	8b2a                	mv	s6,a0
    80004354:	0001da97          	auipc	s5,0x1d
    80004358:	05ca8a93          	addi	s5,s5,92 # 800213b0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000435c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000435e:	0001d997          	auipc	s3,0x1d
    80004362:	02298993          	addi	s3,s3,34 # 80021380 <log>
    80004366:	a035                	j	80004392 <install_trans+0x60>
      bunpin(dbuf);
    80004368:	8526                	mv	a0,s1
    8000436a:	fffff097          	auipc	ra,0xfffff
    8000436e:	166080e7          	jalr	358(ra) # 800034d0 <bunpin>
    brelse(lbuf);
    80004372:	854a                	mv	a0,s2
    80004374:	fffff097          	auipc	ra,0xfffff
    80004378:	082080e7          	jalr	130(ra) # 800033f6 <brelse>
    brelse(dbuf);
    8000437c:	8526                	mv	a0,s1
    8000437e:	fffff097          	auipc	ra,0xfffff
    80004382:	078080e7          	jalr	120(ra) # 800033f6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004386:	2a05                	addiw	s4,s4,1
    80004388:	0a91                	addi	s5,s5,4
    8000438a:	02c9a783          	lw	a5,44(s3)
    8000438e:	04fa5963          	bge	s4,a5,800043e0 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004392:	0189a583          	lw	a1,24(s3)
    80004396:	014585bb          	addw	a1,a1,s4
    8000439a:	2585                	addiw	a1,a1,1
    8000439c:	0289a503          	lw	a0,40(s3)
    800043a0:	fffff097          	auipc	ra,0xfffff
    800043a4:	f26080e7          	jalr	-218(ra) # 800032c6 <bread>
    800043a8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800043aa:	000aa583          	lw	a1,0(s5)
    800043ae:	0289a503          	lw	a0,40(s3)
    800043b2:	fffff097          	auipc	ra,0xfffff
    800043b6:	f14080e7          	jalr	-236(ra) # 800032c6 <bread>
    800043ba:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800043bc:	40000613          	li	a2,1024
    800043c0:	05890593          	addi	a1,s2,88
    800043c4:	05850513          	addi	a0,a0,88
    800043c8:	ffffd097          	auipc	ra,0xffffd
    800043cc:	966080e7          	jalr	-1690(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    800043d0:	8526                	mv	a0,s1
    800043d2:	fffff097          	auipc	ra,0xfffff
    800043d6:	fe6080e7          	jalr	-26(ra) # 800033b8 <bwrite>
    if(recovering == 0)
    800043da:	f80b1ce3          	bnez	s6,80004372 <install_trans+0x40>
    800043de:	b769                	j	80004368 <install_trans+0x36>
}
    800043e0:	70e2                	ld	ra,56(sp)
    800043e2:	7442                	ld	s0,48(sp)
    800043e4:	74a2                	ld	s1,40(sp)
    800043e6:	7902                	ld	s2,32(sp)
    800043e8:	69e2                	ld	s3,24(sp)
    800043ea:	6a42                	ld	s4,16(sp)
    800043ec:	6aa2                	ld	s5,8(sp)
    800043ee:	6b02                	ld	s6,0(sp)
    800043f0:	6121                	addi	sp,sp,64
    800043f2:	8082                	ret
    800043f4:	8082                	ret

00000000800043f6 <initlog>:
{
    800043f6:	7179                	addi	sp,sp,-48
    800043f8:	f406                	sd	ra,40(sp)
    800043fa:	f022                	sd	s0,32(sp)
    800043fc:	ec26                	sd	s1,24(sp)
    800043fe:	e84a                	sd	s2,16(sp)
    80004400:	e44e                	sd	s3,8(sp)
    80004402:	1800                	addi	s0,sp,48
    80004404:	892a                	mv	s2,a0
    80004406:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004408:	0001d497          	auipc	s1,0x1d
    8000440c:	f7848493          	addi	s1,s1,-136 # 80021380 <log>
    80004410:	00004597          	auipc	a1,0x4
    80004414:	20058593          	addi	a1,a1,512 # 80008610 <syscalls+0x1e0>
    80004418:	8526                	mv	a0,s1
    8000441a:	ffffc097          	auipc	ra,0xffffc
    8000441e:	728080e7          	jalr	1832(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    80004422:	0149a583          	lw	a1,20(s3)
    80004426:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004428:	0109a783          	lw	a5,16(s3)
    8000442c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000442e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004432:	854a                	mv	a0,s2
    80004434:	fffff097          	auipc	ra,0xfffff
    80004438:	e92080e7          	jalr	-366(ra) # 800032c6 <bread>
  log.lh.n = lh->n;
    8000443c:	4d3c                	lw	a5,88(a0)
    8000443e:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004440:	02f05563          	blez	a5,8000446a <initlog+0x74>
    80004444:	05c50713          	addi	a4,a0,92
    80004448:	0001d697          	auipc	a3,0x1d
    8000444c:	f6868693          	addi	a3,a3,-152 # 800213b0 <log+0x30>
    80004450:	37fd                	addiw	a5,a5,-1
    80004452:	1782                	slli	a5,a5,0x20
    80004454:	9381                	srli	a5,a5,0x20
    80004456:	078a                	slli	a5,a5,0x2
    80004458:	06050613          	addi	a2,a0,96
    8000445c:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    8000445e:	4310                	lw	a2,0(a4)
    80004460:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80004462:	0711                	addi	a4,a4,4
    80004464:	0691                	addi	a3,a3,4
    80004466:	fef71ce3          	bne	a4,a5,8000445e <initlog+0x68>
  brelse(buf);
    8000446a:	fffff097          	auipc	ra,0xfffff
    8000446e:	f8c080e7          	jalr	-116(ra) # 800033f6 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004472:	4505                	li	a0,1
    80004474:	00000097          	auipc	ra,0x0
    80004478:	ebe080e7          	jalr	-322(ra) # 80004332 <install_trans>
  log.lh.n = 0;
    8000447c:	0001d797          	auipc	a5,0x1d
    80004480:	f207a823          	sw	zero,-208(a5) # 800213ac <log+0x2c>
  write_head(); // clear the log
    80004484:	00000097          	auipc	ra,0x0
    80004488:	e34080e7          	jalr	-460(ra) # 800042b8 <write_head>
}
    8000448c:	70a2                	ld	ra,40(sp)
    8000448e:	7402                	ld	s0,32(sp)
    80004490:	64e2                	ld	s1,24(sp)
    80004492:	6942                	ld	s2,16(sp)
    80004494:	69a2                	ld	s3,8(sp)
    80004496:	6145                	addi	sp,sp,48
    80004498:	8082                	ret

000000008000449a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000449a:	1101                	addi	sp,sp,-32
    8000449c:	ec06                	sd	ra,24(sp)
    8000449e:	e822                	sd	s0,16(sp)
    800044a0:	e426                	sd	s1,8(sp)
    800044a2:	e04a                	sd	s2,0(sp)
    800044a4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800044a6:	0001d517          	auipc	a0,0x1d
    800044aa:	eda50513          	addi	a0,a0,-294 # 80021380 <log>
    800044ae:	ffffc097          	auipc	ra,0xffffc
    800044b2:	724080e7          	jalr	1828(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    800044b6:	0001d497          	auipc	s1,0x1d
    800044ba:	eca48493          	addi	s1,s1,-310 # 80021380 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800044be:	4979                	li	s2,30
    800044c0:	a039                	j	800044ce <begin_op+0x34>
      sleep(&log, &log.lock);
    800044c2:	85a6                	mv	a1,s1
    800044c4:	8526                	mv	a0,s1
    800044c6:	ffffe097          	auipc	ra,0xffffe
    800044ca:	f20080e7          	jalr	-224(ra) # 800023e6 <sleep>
    if(log.committing){
    800044ce:	50dc                	lw	a5,36(s1)
    800044d0:	fbed                	bnez	a5,800044c2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800044d2:	509c                	lw	a5,32(s1)
    800044d4:	0017871b          	addiw	a4,a5,1
    800044d8:	0007069b          	sext.w	a3,a4
    800044dc:	0027179b          	slliw	a5,a4,0x2
    800044e0:	9fb9                	addw	a5,a5,a4
    800044e2:	0017979b          	slliw	a5,a5,0x1
    800044e6:	54d8                	lw	a4,44(s1)
    800044e8:	9fb9                	addw	a5,a5,a4
    800044ea:	00f95963          	bge	s2,a5,800044fc <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800044ee:	85a6                	mv	a1,s1
    800044f0:	8526                	mv	a0,s1
    800044f2:	ffffe097          	auipc	ra,0xffffe
    800044f6:	ef4080e7          	jalr	-268(ra) # 800023e6 <sleep>
    800044fa:	bfd1                	j	800044ce <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800044fc:	0001d517          	auipc	a0,0x1d
    80004500:	e8450513          	addi	a0,a0,-380 # 80021380 <log>
    80004504:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004506:	ffffc097          	auipc	ra,0xffffc
    8000450a:	780080e7          	jalr	1920(ra) # 80000c86 <release>
      break;
    }
  }
}
    8000450e:	60e2                	ld	ra,24(sp)
    80004510:	6442                	ld	s0,16(sp)
    80004512:	64a2                	ld	s1,8(sp)
    80004514:	6902                	ld	s2,0(sp)
    80004516:	6105                	addi	sp,sp,32
    80004518:	8082                	ret

000000008000451a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000451a:	7139                	addi	sp,sp,-64
    8000451c:	fc06                	sd	ra,56(sp)
    8000451e:	f822                	sd	s0,48(sp)
    80004520:	f426                	sd	s1,40(sp)
    80004522:	f04a                	sd	s2,32(sp)
    80004524:	ec4e                	sd	s3,24(sp)
    80004526:	e852                	sd	s4,16(sp)
    80004528:	e456                	sd	s5,8(sp)
    8000452a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000452c:	0001d497          	auipc	s1,0x1d
    80004530:	e5448493          	addi	s1,s1,-428 # 80021380 <log>
    80004534:	8526                	mv	a0,s1
    80004536:	ffffc097          	auipc	ra,0xffffc
    8000453a:	69c080e7          	jalr	1692(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    8000453e:	509c                	lw	a5,32(s1)
    80004540:	37fd                	addiw	a5,a5,-1
    80004542:	0007891b          	sext.w	s2,a5
    80004546:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004548:	50dc                	lw	a5,36(s1)
    8000454a:	efb9                	bnez	a5,800045a8 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000454c:	06091663          	bnez	s2,800045b8 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    80004550:	0001d497          	auipc	s1,0x1d
    80004554:	e3048493          	addi	s1,s1,-464 # 80021380 <log>
    80004558:	4785                	li	a5,1
    8000455a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000455c:	8526                	mv	a0,s1
    8000455e:	ffffc097          	auipc	ra,0xffffc
    80004562:	728080e7          	jalr	1832(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004566:	54dc                	lw	a5,44(s1)
    80004568:	06f04763          	bgtz	a5,800045d6 <end_op+0xbc>
    acquire(&log.lock);
    8000456c:	0001d497          	auipc	s1,0x1d
    80004570:	e1448493          	addi	s1,s1,-492 # 80021380 <log>
    80004574:	8526                	mv	a0,s1
    80004576:	ffffc097          	auipc	ra,0xffffc
    8000457a:	65c080e7          	jalr	1628(ra) # 80000bd2 <acquire>
    log.committing = 0;
    8000457e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004582:	8526                	mv	a0,s1
    80004584:	ffffe097          	auipc	ra,0xffffe
    80004588:	fee080e7          	jalr	-18(ra) # 80002572 <wakeup>
    release(&log.lock);
    8000458c:	8526                	mv	a0,s1
    8000458e:	ffffc097          	auipc	ra,0xffffc
    80004592:	6f8080e7          	jalr	1784(ra) # 80000c86 <release>
}
    80004596:	70e2                	ld	ra,56(sp)
    80004598:	7442                	ld	s0,48(sp)
    8000459a:	74a2                	ld	s1,40(sp)
    8000459c:	7902                	ld	s2,32(sp)
    8000459e:	69e2                	ld	s3,24(sp)
    800045a0:	6a42                	ld	s4,16(sp)
    800045a2:	6aa2                	ld	s5,8(sp)
    800045a4:	6121                	addi	sp,sp,64
    800045a6:	8082                	ret
    panic("log.committing");
    800045a8:	00004517          	auipc	a0,0x4
    800045ac:	07050513          	addi	a0,a0,112 # 80008618 <syscalls+0x1e8>
    800045b0:	ffffc097          	auipc	ra,0xffffc
    800045b4:	f80080e7          	jalr	-128(ra) # 80000530 <panic>
    wakeup(&log);
    800045b8:	0001d497          	auipc	s1,0x1d
    800045bc:	dc848493          	addi	s1,s1,-568 # 80021380 <log>
    800045c0:	8526                	mv	a0,s1
    800045c2:	ffffe097          	auipc	ra,0xffffe
    800045c6:	fb0080e7          	jalr	-80(ra) # 80002572 <wakeup>
  release(&log.lock);
    800045ca:	8526                	mv	a0,s1
    800045cc:	ffffc097          	auipc	ra,0xffffc
    800045d0:	6ba080e7          	jalr	1722(ra) # 80000c86 <release>
  if(do_commit){
    800045d4:	b7c9                	j	80004596 <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800045d6:	0001da97          	auipc	s5,0x1d
    800045da:	ddaa8a93          	addi	s5,s5,-550 # 800213b0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800045de:	0001da17          	auipc	s4,0x1d
    800045e2:	da2a0a13          	addi	s4,s4,-606 # 80021380 <log>
    800045e6:	018a2583          	lw	a1,24(s4)
    800045ea:	012585bb          	addw	a1,a1,s2
    800045ee:	2585                	addiw	a1,a1,1
    800045f0:	028a2503          	lw	a0,40(s4)
    800045f4:	fffff097          	auipc	ra,0xfffff
    800045f8:	cd2080e7          	jalr	-814(ra) # 800032c6 <bread>
    800045fc:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800045fe:	000aa583          	lw	a1,0(s5)
    80004602:	028a2503          	lw	a0,40(s4)
    80004606:	fffff097          	auipc	ra,0xfffff
    8000460a:	cc0080e7          	jalr	-832(ra) # 800032c6 <bread>
    8000460e:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004610:	40000613          	li	a2,1024
    80004614:	05850593          	addi	a1,a0,88
    80004618:	05848513          	addi	a0,s1,88
    8000461c:	ffffc097          	auipc	ra,0xffffc
    80004620:	712080e7          	jalr	1810(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004624:	8526                	mv	a0,s1
    80004626:	fffff097          	auipc	ra,0xfffff
    8000462a:	d92080e7          	jalr	-622(ra) # 800033b8 <bwrite>
    brelse(from);
    8000462e:	854e                	mv	a0,s3
    80004630:	fffff097          	auipc	ra,0xfffff
    80004634:	dc6080e7          	jalr	-570(ra) # 800033f6 <brelse>
    brelse(to);
    80004638:	8526                	mv	a0,s1
    8000463a:	fffff097          	auipc	ra,0xfffff
    8000463e:	dbc080e7          	jalr	-580(ra) # 800033f6 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004642:	2905                	addiw	s2,s2,1
    80004644:	0a91                	addi	s5,s5,4
    80004646:	02ca2783          	lw	a5,44(s4)
    8000464a:	f8f94ee3          	blt	s2,a5,800045e6 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000464e:	00000097          	auipc	ra,0x0
    80004652:	c6a080e7          	jalr	-918(ra) # 800042b8 <write_head>
    install_trans(0); // Now install writes to home locations
    80004656:	4501                	li	a0,0
    80004658:	00000097          	auipc	ra,0x0
    8000465c:	cda080e7          	jalr	-806(ra) # 80004332 <install_trans>
    log.lh.n = 0;
    80004660:	0001d797          	auipc	a5,0x1d
    80004664:	d407a623          	sw	zero,-692(a5) # 800213ac <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004668:	00000097          	auipc	ra,0x0
    8000466c:	c50080e7          	jalr	-944(ra) # 800042b8 <write_head>
    80004670:	bdf5                	j	8000456c <end_op+0x52>

0000000080004672 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004672:	1101                	addi	sp,sp,-32
    80004674:	ec06                	sd	ra,24(sp)
    80004676:	e822                	sd	s0,16(sp)
    80004678:	e426                	sd	s1,8(sp)
    8000467a:	e04a                	sd	s2,0(sp)
    8000467c:	1000                	addi	s0,sp,32
    8000467e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004680:	0001d917          	auipc	s2,0x1d
    80004684:	d0090913          	addi	s2,s2,-768 # 80021380 <log>
    80004688:	854a                	mv	a0,s2
    8000468a:	ffffc097          	auipc	ra,0xffffc
    8000468e:	548080e7          	jalr	1352(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004692:	02c92603          	lw	a2,44(s2)
    80004696:	47f5                	li	a5,29
    80004698:	06c7c563          	blt	a5,a2,80004702 <log_write+0x90>
    8000469c:	0001d797          	auipc	a5,0x1d
    800046a0:	d007a783          	lw	a5,-768(a5) # 8002139c <log+0x1c>
    800046a4:	37fd                	addiw	a5,a5,-1
    800046a6:	04f65e63          	bge	a2,a5,80004702 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800046aa:	0001d797          	auipc	a5,0x1d
    800046ae:	cf67a783          	lw	a5,-778(a5) # 800213a0 <log+0x20>
    800046b2:	06f05063          	blez	a5,80004712 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800046b6:	4781                	li	a5,0
    800046b8:	06c05563          	blez	a2,80004722 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800046bc:	44cc                	lw	a1,12(s1)
    800046be:	0001d717          	auipc	a4,0x1d
    800046c2:	cf270713          	addi	a4,a4,-782 # 800213b0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800046c6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800046c8:	4314                	lw	a3,0(a4)
    800046ca:	04b68c63          	beq	a3,a1,80004722 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800046ce:	2785                	addiw	a5,a5,1
    800046d0:	0711                	addi	a4,a4,4
    800046d2:	fef61be3          	bne	a2,a5,800046c8 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800046d6:	0621                	addi	a2,a2,8
    800046d8:	060a                	slli	a2,a2,0x2
    800046da:	0001d797          	auipc	a5,0x1d
    800046de:	ca678793          	addi	a5,a5,-858 # 80021380 <log>
    800046e2:	963e                	add	a2,a2,a5
    800046e4:	44dc                	lw	a5,12(s1)
    800046e6:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800046e8:	8526                	mv	a0,s1
    800046ea:	fffff097          	auipc	ra,0xfffff
    800046ee:	daa080e7          	jalr	-598(ra) # 80003494 <bpin>
    log.lh.n++;
    800046f2:	0001d717          	auipc	a4,0x1d
    800046f6:	c8e70713          	addi	a4,a4,-882 # 80021380 <log>
    800046fa:	575c                	lw	a5,44(a4)
    800046fc:	2785                	addiw	a5,a5,1
    800046fe:	d75c                	sw	a5,44(a4)
    80004700:	a835                	j	8000473c <log_write+0xca>
    panic("too big a transaction");
    80004702:	00004517          	auipc	a0,0x4
    80004706:	f2650513          	addi	a0,a0,-218 # 80008628 <syscalls+0x1f8>
    8000470a:	ffffc097          	auipc	ra,0xffffc
    8000470e:	e26080e7          	jalr	-474(ra) # 80000530 <panic>
    panic("log_write outside of trans");
    80004712:	00004517          	auipc	a0,0x4
    80004716:	f2e50513          	addi	a0,a0,-210 # 80008640 <syscalls+0x210>
    8000471a:	ffffc097          	auipc	ra,0xffffc
    8000471e:	e16080e7          	jalr	-490(ra) # 80000530 <panic>
  log.lh.block[i] = b->blockno;
    80004722:	00878713          	addi	a4,a5,8
    80004726:	00271693          	slli	a3,a4,0x2
    8000472a:	0001d717          	auipc	a4,0x1d
    8000472e:	c5670713          	addi	a4,a4,-938 # 80021380 <log>
    80004732:	9736                	add	a4,a4,a3
    80004734:	44d4                	lw	a3,12(s1)
    80004736:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004738:	faf608e3          	beq	a2,a5,800046e8 <log_write+0x76>
  }
  release(&log.lock);
    8000473c:	0001d517          	auipc	a0,0x1d
    80004740:	c4450513          	addi	a0,a0,-956 # 80021380 <log>
    80004744:	ffffc097          	auipc	ra,0xffffc
    80004748:	542080e7          	jalr	1346(ra) # 80000c86 <release>
}
    8000474c:	60e2                	ld	ra,24(sp)
    8000474e:	6442                	ld	s0,16(sp)
    80004750:	64a2                	ld	s1,8(sp)
    80004752:	6902                	ld	s2,0(sp)
    80004754:	6105                	addi	sp,sp,32
    80004756:	8082                	ret

0000000080004758 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004758:	1101                	addi	sp,sp,-32
    8000475a:	ec06                	sd	ra,24(sp)
    8000475c:	e822                	sd	s0,16(sp)
    8000475e:	e426                	sd	s1,8(sp)
    80004760:	e04a                	sd	s2,0(sp)
    80004762:	1000                	addi	s0,sp,32
    80004764:	84aa                	mv	s1,a0
    80004766:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004768:	00004597          	auipc	a1,0x4
    8000476c:	ef858593          	addi	a1,a1,-264 # 80008660 <syscalls+0x230>
    80004770:	0521                	addi	a0,a0,8
    80004772:	ffffc097          	auipc	ra,0xffffc
    80004776:	3d0080e7          	jalr	976(ra) # 80000b42 <initlock>
  lk->name = name;
    8000477a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000477e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004782:	0204a423          	sw	zero,40(s1)
}
    80004786:	60e2                	ld	ra,24(sp)
    80004788:	6442                	ld	s0,16(sp)
    8000478a:	64a2                	ld	s1,8(sp)
    8000478c:	6902                	ld	s2,0(sp)
    8000478e:	6105                	addi	sp,sp,32
    80004790:	8082                	ret

0000000080004792 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004792:	1101                	addi	sp,sp,-32
    80004794:	ec06                	sd	ra,24(sp)
    80004796:	e822                	sd	s0,16(sp)
    80004798:	e426                	sd	s1,8(sp)
    8000479a:	e04a                	sd	s2,0(sp)
    8000479c:	1000                	addi	s0,sp,32
    8000479e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047a0:	00850913          	addi	s2,a0,8
    800047a4:	854a                	mv	a0,s2
    800047a6:	ffffc097          	auipc	ra,0xffffc
    800047aa:	42c080e7          	jalr	1068(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    800047ae:	409c                	lw	a5,0(s1)
    800047b0:	cb89                	beqz	a5,800047c2 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800047b2:	85ca                	mv	a1,s2
    800047b4:	8526                	mv	a0,s1
    800047b6:	ffffe097          	auipc	ra,0xffffe
    800047ba:	c30080e7          	jalr	-976(ra) # 800023e6 <sleep>
  while (lk->locked) {
    800047be:	409c                	lw	a5,0(s1)
    800047c0:	fbed                	bnez	a5,800047b2 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800047c2:	4785                	li	a5,1
    800047c4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800047c6:	ffffd097          	auipc	ra,0xffffd
    800047ca:	2bc080e7          	jalr	700(ra) # 80001a82 <myproc>
    800047ce:	591c                	lw	a5,48(a0)
    800047d0:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800047d2:	854a                	mv	a0,s2
    800047d4:	ffffc097          	auipc	ra,0xffffc
    800047d8:	4b2080e7          	jalr	1202(ra) # 80000c86 <release>
}
    800047dc:	60e2                	ld	ra,24(sp)
    800047de:	6442                	ld	s0,16(sp)
    800047e0:	64a2                	ld	s1,8(sp)
    800047e2:	6902                	ld	s2,0(sp)
    800047e4:	6105                	addi	sp,sp,32
    800047e6:	8082                	ret

00000000800047e8 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800047e8:	1101                	addi	sp,sp,-32
    800047ea:	ec06                	sd	ra,24(sp)
    800047ec:	e822                	sd	s0,16(sp)
    800047ee:	e426                	sd	s1,8(sp)
    800047f0:	e04a                	sd	s2,0(sp)
    800047f2:	1000                	addi	s0,sp,32
    800047f4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047f6:	00850913          	addi	s2,a0,8
    800047fa:	854a                	mv	a0,s2
    800047fc:	ffffc097          	auipc	ra,0xffffc
    80004800:	3d6080e7          	jalr	982(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    80004804:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004808:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000480c:	8526                	mv	a0,s1
    8000480e:	ffffe097          	auipc	ra,0xffffe
    80004812:	d64080e7          	jalr	-668(ra) # 80002572 <wakeup>
  release(&lk->lk);
    80004816:	854a                	mv	a0,s2
    80004818:	ffffc097          	auipc	ra,0xffffc
    8000481c:	46e080e7          	jalr	1134(ra) # 80000c86 <release>
}
    80004820:	60e2                	ld	ra,24(sp)
    80004822:	6442                	ld	s0,16(sp)
    80004824:	64a2                	ld	s1,8(sp)
    80004826:	6902                	ld	s2,0(sp)
    80004828:	6105                	addi	sp,sp,32
    8000482a:	8082                	ret

000000008000482c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000482c:	7179                	addi	sp,sp,-48
    8000482e:	f406                	sd	ra,40(sp)
    80004830:	f022                	sd	s0,32(sp)
    80004832:	ec26                	sd	s1,24(sp)
    80004834:	e84a                	sd	s2,16(sp)
    80004836:	e44e                	sd	s3,8(sp)
    80004838:	1800                	addi	s0,sp,48
    8000483a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000483c:	00850913          	addi	s2,a0,8
    80004840:	854a                	mv	a0,s2
    80004842:	ffffc097          	auipc	ra,0xffffc
    80004846:	390080e7          	jalr	912(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000484a:	409c                	lw	a5,0(s1)
    8000484c:	ef99                	bnez	a5,8000486a <holdingsleep+0x3e>
    8000484e:	4481                	li	s1,0
  release(&lk->lk);
    80004850:	854a                	mv	a0,s2
    80004852:	ffffc097          	auipc	ra,0xffffc
    80004856:	434080e7          	jalr	1076(ra) # 80000c86 <release>
  return r;
}
    8000485a:	8526                	mv	a0,s1
    8000485c:	70a2                	ld	ra,40(sp)
    8000485e:	7402                	ld	s0,32(sp)
    80004860:	64e2                	ld	s1,24(sp)
    80004862:	6942                	ld	s2,16(sp)
    80004864:	69a2                	ld	s3,8(sp)
    80004866:	6145                	addi	sp,sp,48
    80004868:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    8000486a:	0284a983          	lw	s3,40(s1)
    8000486e:	ffffd097          	auipc	ra,0xffffd
    80004872:	214080e7          	jalr	532(ra) # 80001a82 <myproc>
    80004876:	5904                	lw	s1,48(a0)
    80004878:	413484b3          	sub	s1,s1,s3
    8000487c:	0014b493          	seqz	s1,s1
    80004880:	bfc1                	j	80004850 <holdingsleep+0x24>

0000000080004882 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004882:	1141                	addi	sp,sp,-16
    80004884:	e406                	sd	ra,8(sp)
    80004886:	e022                	sd	s0,0(sp)
    80004888:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000488a:	00004597          	auipc	a1,0x4
    8000488e:	de658593          	addi	a1,a1,-538 # 80008670 <syscalls+0x240>
    80004892:	0001d517          	auipc	a0,0x1d
    80004896:	c3650513          	addi	a0,a0,-970 # 800214c8 <ftable>
    8000489a:	ffffc097          	auipc	ra,0xffffc
    8000489e:	2a8080e7          	jalr	680(ra) # 80000b42 <initlock>
}
    800048a2:	60a2                	ld	ra,8(sp)
    800048a4:	6402                	ld	s0,0(sp)
    800048a6:	0141                	addi	sp,sp,16
    800048a8:	8082                	ret

00000000800048aa <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800048aa:	1101                	addi	sp,sp,-32
    800048ac:	ec06                	sd	ra,24(sp)
    800048ae:	e822                	sd	s0,16(sp)
    800048b0:	e426                	sd	s1,8(sp)
    800048b2:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800048b4:	0001d517          	auipc	a0,0x1d
    800048b8:	c1450513          	addi	a0,a0,-1004 # 800214c8 <ftable>
    800048bc:	ffffc097          	auipc	ra,0xffffc
    800048c0:	316080e7          	jalr	790(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048c4:	0001d497          	auipc	s1,0x1d
    800048c8:	c1c48493          	addi	s1,s1,-996 # 800214e0 <ftable+0x18>
    800048cc:	0001e717          	auipc	a4,0x1e
    800048d0:	bb470713          	addi	a4,a4,-1100 # 80022480 <ftable+0xfb8>
    if(f->ref == 0){
    800048d4:	40dc                	lw	a5,4(s1)
    800048d6:	cf99                	beqz	a5,800048f4 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048d8:	02848493          	addi	s1,s1,40
    800048dc:	fee49ce3          	bne	s1,a4,800048d4 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800048e0:	0001d517          	auipc	a0,0x1d
    800048e4:	be850513          	addi	a0,a0,-1048 # 800214c8 <ftable>
    800048e8:	ffffc097          	auipc	ra,0xffffc
    800048ec:	39e080e7          	jalr	926(ra) # 80000c86 <release>
  return 0;
    800048f0:	4481                	li	s1,0
    800048f2:	a819                	j	80004908 <filealloc+0x5e>
      f->ref = 1;
    800048f4:	4785                	li	a5,1
    800048f6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800048f8:	0001d517          	auipc	a0,0x1d
    800048fc:	bd050513          	addi	a0,a0,-1072 # 800214c8 <ftable>
    80004900:	ffffc097          	auipc	ra,0xffffc
    80004904:	386080e7          	jalr	902(ra) # 80000c86 <release>
}
    80004908:	8526                	mv	a0,s1
    8000490a:	60e2                	ld	ra,24(sp)
    8000490c:	6442                	ld	s0,16(sp)
    8000490e:	64a2                	ld	s1,8(sp)
    80004910:	6105                	addi	sp,sp,32
    80004912:	8082                	ret

0000000080004914 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004914:	1101                	addi	sp,sp,-32
    80004916:	ec06                	sd	ra,24(sp)
    80004918:	e822                	sd	s0,16(sp)
    8000491a:	e426                	sd	s1,8(sp)
    8000491c:	1000                	addi	s0,sp,32
    8000491e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004920:	0001d517          	auipc	a0,0x1d
    80004924:	ba850513          	addi	a0,a0,-1112 # 800214c8 <ftable>
    80004928:	ffffc097          	auipc	ra,0xffffc
    8000492c:	2aa080e7          	jalr	682(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004930:	40dc                	lw	a5,4(s1)
    80004932:	02f05263          	blez	a5,80004956 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004936:	2785                	addiw	a5,a5,1
    80004938:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000493a:	0001d517          	auipc	a0,0x1d
    8000493e:	b8e50513          	addi	a0,a0,-1138 # 800214c8 <ftable>
    80004942:	ffffc097          	auipc	ra,0xffffc
    80004946:	344080e7          	jalr	836(ra) # 80000c86 <release>
  return f;
}
    8000494a:	8526                	mv	a0,s1
    8000494c:	60e2                	ld	ra,24(sp)
    8000494e:	6442                	ld	s0,16(sp)
    80004950:	64a2                	ld	s1,8(sp)
    80004952:	6105                	addi	sp,sp,32
    80004954:	8082                	ret
    panic("filedup");
    80004956:	00004517          	auipc	a0,0x4
    8000495a:	d2250513          	addi	a0,a0,-734 # 80008678 <syscalls+0x248>
    8000495e:	ffffc097          	auipc	ra,0xffffc
    80004962:	bd2080e7          	jalr	-1070(ra) # 80000530 <panic>

0000000080004966 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004966:	7139                	addi	sp,sp,-64
    80004968:	fc06                	sd	ra,56(sp)
    8000496a:	f822                	sd	s0,48(sp)
    8000496c:	f426                	sd	s1,40(sp)
    8000496e:	f04a                	sd	s2,32(sp)
    80004970:	ec4e                	sd	s3,24(sp)
    80004972:	e852                	sd	s4,16(sp)
    80004974:	e456                	sd	s5,8(sp)
    80004976:	0080                	addi	s0,sp,64
    80004978:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    8000497a:	0001d517          	auipc	a0,0x1d
    8000497e:	b4e50513          	addi	a0,a0,-1202 # 800214c8 <ftable>
    80004982:	ffffc097          	auipc	ra,0xffffc
    80004986:	250080e7          	jalr	592(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    8000498a:	40dc                	lw	a5,4(s1)
    8000498c:	06f05163          	blez	a5,800049ee <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004990:	37fd                	addiw	a5,a5,-1
    80004992:	0007871b          	sext.w	a4,a5
    80004996:	c0dc                	sw	a5,4(s1)
    80004998:	06e04363          	bgtz	a4,800049fe <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000499c:	0004a903          	lw	s2,0(s1)
    800049a0:	0094ca83          	lbu	s5,9(s1)
    800049a4:	0104ba03          	ld	s4,16(s1)
    800049a8:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800049ac:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800049b0:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800049b4:	0001d517          	auipc	a0,0x1d
    800049b8:	b1450513          	addi	a0,a0,-1260 # 800214c8 <ftable>
    800049bc:	ffffc097          	auipc	ra,0xffffc
    800049c0:	2ca080e7          	jalr	714(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    800049c4:	4785                	li	a5,1
    800049c6:	04f90d63          	beq	s2,a5,80004a20 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800049ca:	3979                	addiw	s2,s2,-2
    800049cc:	4785                	li	a5,1
    800049ce:	0527e063          	bltu	a5,s2,80004a0e <fileclose+0xa8>
    begin_op();
    800049d2:	00000097          	auipc	ra,0x0
    800049d6:	ac8080e7          	jalr	-1336(ra) # 8000449a <begin_op>
    iput(ff.ip);
    800049da:	854e                	mv	a0,s3
    800049dc:	fffff097          	auipc	ra,0xfffff
    800049e0:	2a6080e7          	jalr	678(ra) # 80003c82 <iput>
    end_op();
    800049e4:	00000097          	auipc	ra,0x0
    800049e8:	b36080e7          	jalr	-1226(ra) # 8000451a <end_op>
    800049ec:	a00d                	j	80004a0e <fileclose+0xa8>
    panic("fileclose");
    800049ee:	00004517          	auipc	a0,0x4
    800049f2:	c9250513          	addi	a0,a0,-878 # 80008680 <syscalls+0x250>
    800049f6:	ffffc097          	auipc	ra,0xffffc
    800049fa:	b3a080e7          	jalr	-1222(ra) # 80000530 <panic>
    release(&ftable.lock);
    800049fe:	0001d517          	auipc	a0,0x1d
    80004a02:	aca50513          	addi	a0,a0,-1334 # 800214c8 <ftable>
    80004a06:	ffffc097          	auipc	ra,0xffffc
    80004a0a:	280080e7          	jalr	640(ra) # 80000c86 <release>
  }
}
    80004a0e:	70e2                	ld	ra,56(sp)
    80004a10:	7442                	ld	s0,48(sp)
    80004a12:	74a2                	ld	s1,40(sp)
    80004a14:	7902                	ld	s2,32(sp)
    80004a16:	69e2                	ld	s3,24(sp)
    80004a18:	6a42                	ld	s4,16(sp)
    80004a1a:	6aa2                	ld	s5,8(sp)
    80004a1c:	6121                	addi	sp,sp,64
    80004a1e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004a20:	85d6                	mv	a1,s5
    80004a22:	8552                	mv	a0,s4
    80004a24:	00000097          	auipc	ra,0x0
    80004a28:	34c080e7          	jalr	844(ra) # 80004d70 <pipeclose>
    80004a2c:	b7cd                	j	80004a0e <fileclose+0xa8>

0000000080004a2e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004a2e:	715d                	addi	sp,sp,-80
    80004a30:	e486                	sd	ra,72(sp)
    80004a32:	e0a2                	sd	s0,64(sp)
    80004a34:	fc26                	sd	s1,56(sp)
    80004a36:	f84a                	sd	s2,48(sp)
    80004a38:	f44e                	sd	s3,40(sp)
    80004a3a:	0880                	addi	s0,sp,80
    80004a3c:	84aa                	mv	s1,a0
    80004a3e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004a40:	ffffd097          	auipc	ra,0xffffd
    80004a44:	042080e7          	jalr	66(ra) # 80001a82 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004a48:	409c                	lw	a5,0(s1)
    80004a4a:	37f9                	addiw	a5,a5,-2
    80004a4c:	4705                	li	a4,1
    80004a4e:	04f76763          	bltu	a4,a5,80004a9c <filestat+0x6e>
    80004a52:	892a                	mv	s2,a0
    ilock(f->ip);
    80004a54:	6c88                	ld	a0,24(s1)
    80004a56:	fffff097          	auipc	ra,0xfffff
    80004a5a:	072080e7          	jalr	114(ra) # 80003ac8 <ilock>
    stati(f->ip, &st);
    80004a5e:	fb840593          	addi	a1,s0,-72
    80004a62:	6c88                	ld	a0,24(s1)
    80004a64:	fffff097          	auipc	ra,0xfffff
    80004a68:	2ee080e7          	jalr	750(ra) # 80003d52 <stati>
    iunlock(f->ip);
    80004a6c:	6c88                	ld	a0,24(s1)
    80004a6e:	fffff097          	auipc	ra,0xfffff
    80004a72:	11c080e7          	jalr	284(ra) # 80003b8a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004a76:	46e1                	li	a3,24
    80004a78:	fb840613          	addi	a2,s0,-72
    80004a7c:	85ce                	mv	a1,s3
    80004a7e:	05093503          	ld	a0,80(s2)
    80004a82:	ffffd097          	auipc	ra,0xffffd
    80004a86:	bd0080e7          	jalr	-1072(ra) # 80001652 <copyout>
    80004a8a:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004a8e:	60a6                	ld	ra,72(sp)
    80004a90:	6406                	ld	s0,64(sp)
    80004a92:	74e2                	ld	s1,56(sp)
    80004a94:	7942                	ld	s2,48(sp)
    80004a96:	79a2                	ld	s3,40(sp)
    80004a98:	6161                	addi	sp,sp,80
    80004a9a:	8082                	ret
  return -1;
    80004a9c:	557d                	li	a0,-1
    80004a9e:	bfc5                	j	80004a8e <filestat+0x60>

0000000080004aa0 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004aa0:	7179                	addi	sp,sp,-48
    80004aa2:	f406                	sd	ra,40(sp)
    80004aa4:	f022                	sd	s0,32(sp)
    80004aa6:	ec26                	sd	s1,24(sp)
    80004aa8:	e84a                	sd	s2,16(sp)
    80004aaa:	e44e                	sd	s3,8(sp)
    80004aac:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004aae:	00854783          	lbu	a5,8(a0)
    80004ab2:	c3d5                	beqz	a5,80004b56 <fileread+0xb6>
    80004ab4:	84aa                	mv	s1,a0
    80004ab6:	89ae                	mv	s3,a1
    80004ab8:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004aba:	411c                	lw	a5,0(a0)
    80004abc:	4705                	li	a4,1
    80004abe:	04e78963          	beq	a5,a4,80004b10 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ac2:	470d                	li	a4,3
    80004ac4:	04e78d63          	beq	a5,a4,80004b1e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ac8:	4709                	li	a4,2
    80004aca:	06e79e63          	bne	a5,a4,80004b46 <fileread+0xa6>
    ilock(f->ip);
    80004ace:	6d08                	ld	a0,24(a0)
    80004ad0:	fffff097          	auipc	ra,0xfffff
    80004ad4:	ff8080e7          	jalr	-8(ra) # 80003ac8 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004ad8:	874a                	mv	a4,s2
    80004ada:	5094                	lw	a3,32(s1)
    80004adc:	864e                	mv	a2,s3
    80004ade:	4585                	li	a1,1
    80004ae0:	6c88                	ld	a0,24(s1)
    80004ae2:	fffff097          	auipc	ra,0xfffff
    80004ae6:	29a080e7          	jalr	666(ra) # 80003d7c <readi>
    80004aea:	892a                	mv	s2,a0
    80004aec:	00a05563          	blez	a0,80004af6 <fileread+0x56>
      f->off += r;
    80004af0:	509c                	lw	a5,32(s1)
    80004af2:	9fa9                	addw	a5,a5,a0
    80004af4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004af6:	6c88                	ld	a0,24(s1)
    80004af8:	fffff097          	auipc	ra,0xfffff
    80004afc:	092080e7          	jalr	146(ra) # 80003b8a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004b00:	854a                	mv	a0,s2
    80004b02:	70a2                	ld	ra,40(sp)
    80004b04:	7402                	ld	s0,32(sp)
    80004b06:	64e2                	ld	s1,24(sp)
    80004b08:	6942                	ld	s2,16(sp)
    80004b0a:	69a2                	ld	s3,8(sp)
    80004b0c:	6145                	addi	sp,sp,48
    80004b0e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004b10:	6908                	ld	a0,16(a0)
    80004b12:	00000097          	auipc	ra,0x0
    80004b16:	3c8080e7          	jalr	968(ra) # 80004eda <piperead>
    80004b1a:	892a                	mv	s2,a0
    80004b1c:	b7d5                	j	80004b00 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004b1e:	02451783          	lh	a5,36(a0)
    80004b22:	03079693          	slli	a3,a5,0x30
    80004b26:	92c1                	srli	a3,a3,0x30
    80004b28:	4725                	li	a4,9
    80004b2a:	02d76863          	bltu	a4,a3,80004b5a <fileread+0xba>
    80004b2e:	0792                	slli	a5,a5,0x4
    80004b30:	0001d717          	auipc	a4,0x1d
    80004b34:	8f870713          	addi	a4,a4,-1800 # 80021428 <devsw>
    80004b38:	97ba                	add	a5,a5,a4
    80004b3a:	639c                	ld	a5,0(a5)
    80004b3c:	c38d                	beqz	a5,80004b5e <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004b3e:	4505                	li	a0,1
    80004b40:	9782                	jalr	a5
    80004b42:	892a                	mv	s2,a0
    80004b44:	bf75                	j	80004b00 <fileread+0x60>
    panic("fileread");
    80004b46:	00004517          	auipc	a0,0x4
    80004b4a:	b4a50513          	addi	a0,a0,-1206 # 80008690 <syscalls+0x260>
    80004b4e:	ffffc097          	auipc	ra,0xffffc
    80004b52:	9e2080e7          	jalr	-1566(ra) # 80000530 <panic>
    return -1;
    80004b56:	597d                	li	s2,-1
    80004b58:	b765                	j	80004b00 <fileread+0x60>
      return -1;
    80004b5a:	597d                	li	s2,-1
    80004b5c:	b755                	j	80004b00 <fileread+0x60>
    80004b5e:	597d                	li	s2,-1
    80004b60:	b745                	j	80004b00 <fileread+0x60>

0000000080004b62 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004b62:	715d                	addi	sp,sp,-80
    80004b64:	e486                	sd	ra,72(sp)
    80004b66:	e0a2                	sd	s0,64(sp)
    80004b68:	fc26                	sd	s1,56(sp)
    80004b6a:	f84a                	sd	s2,48(sp)
    80004b6c:	f44e                	sd	s3,40(sp)
    80004b6e:	f052                	sd	s4,32(sp)
    80004b70:	ec56                	sd	s5,24(sp)
    80004b72:	e85a                	sd	s6,16(sp)
    80004b74:	e45e                	sd	s7,8(sp)
    80004b76:	e062                	sd	s8,0(sp)
    80004b78:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004b7a:	00954783          	lbu	a5,9(a0)
    80004b7e:	10078663          	beqz	a5,80004c8a <filewrite+0x128>
    80004b82:	892a                	mv	s2,a0
    80004b84:	8aae                	mv	s5,a1
    80004b86:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b88:	411c                	lw	a5,0(a0)
    80004b8a:	4705                	li	a4,1
    80004b8c:	02e78263          	beq	a5,a4,80004bb0 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b90:	470d                	li	a4,3
    80004b92:	02e78663          	beq	a5,a4,80004bbe <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b96:	4709                	li	a4,2
    80004b98:	0ee79163          	bne	a5,a4,80004c7a <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004b9c:	0ac05d63          	blez	a2,80004c56 <filewrite+0xf4>
    int i = 0;
    80004ba0:	4981                	li	s3,0
    80004ba2:	6b05                	lui	s6,0x1
    80004ba4:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004ba8:	6b85                	lui	s7,0x1
    80004baa:	c00b8b9b          	addiw	s7,s7,-1024
    80004bae:	a861                	j	80004c46 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004bb0:	6908                	ld	a0,16(a0)
    80004bb2:	00000097          	auipc	ra,0x0
    80004bb6:	22e080e7          	jalr	558(ra) # 80004de0 <pipewrite>
    80004bba:	8a2a                	mv	s4,a0
    80004bbc:	a045                	j	80004c5c <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004bbe:	02451783          	lh	a5,36(a0)
    80004bc2:	03079693          	slli	a3,a5,0x30
    80004bc6:	92c1                	srli	a3,a3,0x30
    80004bc8:	4725                	li	a4,9
    80004bca:	0cd76263          	bltu	a4,a3,80004c8e <filewrite+0x12c>
    80004bce:	0792                	slli	a5,a5,0x4
    80004bd0:	0001d717          	auipc	a4,0x1d
    80004bd4:	85870713          	addi	a4,a4,-1960 # 80021428 <devsw>
    80004bd8:	97ba                	add	a5,a5,a4
    80004bda:	679c                	ld	a5,8(a5)
    80004bdc:	cbdd                	beqz	a5,80004c92 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004bde:	4505                	li	a0,1
    80004be0:	9782                	jalr	a5
    80004be2:	8a2a                	mv	s4,a0
    80004be4:	a8a5                	j	80004c5c <filewrite+0xfa>
    80004be6:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004bea:	00000097          	auipc	ra,0x0
    80004bee:	8b0080e7          	jalr	-1872(ra) # 8000449a <begin_op>
      ilock(f->ip);
    80004bf2:	01893503          	ld	a0,24(s2)
    80004bf6:	fffff097          	auipc	ra,0xfffff
    80004bfa:	ed2080e7          	jalr	-302(ra) # 80003ac8 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004bfe:	8762                	mv	a4,s8
    80004c00:	02092683          	lw	a3,32(s2)
    80004c04:	01598633          	add	a2,s3,s5
    80004c08:	4585                	li	a1,1
    80004c0a:	01893503          	ld	a0,24(s2)
    80004c0e:	fffff097          	auipc	ra,0xfffff
    80004c12:	266080e7          	jalr	614(ra) # 80003e74 <writei>
    80004c16:	84aa                	mv	s1,a0
    80004c18:	00a05763          	blez	a0,80004c26 <filewrite+0xc4>
        f->off += r;
    80004c1c:	02092783          	lw	a5,32(s2)
    80004c20:	9fa9                	addw	a5,a5,a0
    80004c22:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004c26:	01893503          	ld	a0,24(s2)
    80004c2a:	fffff097          	auipc	ra,0xfffff
    80004c2e:	f60080e7          	jalr	-160(ra) # 80003b8a <iunlock>
      end_op();
    80004c32:	00000097          	auipc	ra,0x0
    80004c36:	8e8080e7          	jalr	-1816(ra) # 8000451a <end_op>

      if(r != n1){
    80004c3a:	009c1f63          	bne	s8,s1,80004c58 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004c3e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004c42:	0149db63          	bge	s3,s4,80004c58 <filewrite+0xf6>
      int n1 = n - i;
    80004c46:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80004c4a:	84be                	mv	s1,a5
    80004c4c:	2781                	sext.w	a5,a5
    80004c4e:	f8fb5ce3          	bge	s6,a5,80004be6 <filewrite+0x84>
    80004c52:	84de                	mv	s1,s7
    80004c54:	bf49                	j	80004be6 <filewrite+0x84>
    int i = 0;
    80004c56:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004c58:	013a1f63          	bne	s4,s3,80004c76 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004c5c:	8552                	mv	a0,s4
    80004c5e:	60a6                	ld	ra,72(sp)
    80004c60:	6406                	ld	s0,64(sp)
    80004c62:	74e2                	ld	s1,56(sp)
    80004c64:	7942                	ld	s2,48(sp)
    80004c66:	79a2                	ld	s3,40(sp)
    80004c68:	7a02                	ld	s4,32(sp)
    80004c6a:	6ae2                	ld	s5,24(sp)
    80004c6c:	6b42                	ld	s6,16(sp)
    80004c6e:	6ba2                	ld	s7,8(sp)
    80004c70:	6c02                	ld	s8,0(sp)
    80004c72:	6161                	addi	sp,sp,80
    80004c74:	8082                	ret
    ret = (i == n ? n : -1);
    80004c76:	5a7d                	li	s4,-1
    80004c78:	b7d5                	j	80004c5c <filewrite+0xfa>
    panic("filewrite");
    80004c7a:	00004517          	auipc	a0,0x4
    80004c7e:	a2650513          	addi	a0,a0,-1498 # 800086a0 <syscalls+0x270>
    80004c82:	ffffc097          	auipc	ra,0xffffc
    80004c86:	8ae080e7          	jalr	-1874(ra) # 80000530 <panic>
    return -1;
    80004c8a:	5a7d                	li	s4,-1
    80004c8c:	bfc1                	j	80004c5c <filewrite+0xfa>
      return -1;
    80004c8e:	5a7d                	li	s4,-1
    80004c90:	b7f1                	j	80004c5c <filewrite+0xfa>
    80004c92:	5a7d                	li	s4,-1
    80004c94:	b7e1                	j	80004c5c <filewrite+0xfa>

0000000080004c96 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004c96:	7179                	addi	sp,sp,-48
    80004c98:	f406                	sd	ra,40(sp)
    80004c9a:	f022                	sd	s0,32(sp)
    80004c9c:	ec26                	sd	s1,24(sp)
    80004c9e:	e84a                	sd	s2,16(sp)
    80004ca0:	e44e                	sd	s3,8(sp)
    80004ca2:	e052                	sd	s4,0(sp)
    80004ca4:	1800                	addi	s0,sp,48
    80004ca6:	84aa                	mv	s1,a0
    80004ca8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004caa:	0005b023          	sd	zero,0(a1)
    80004cae:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004cb2:	00000097          	auipc	ra,0x0
    80004cb6:	bf8080e7          	jalr	-1032(ra) # 800048aa <filealloc>
    80004cba:	e088                	sd	a0,0(s1)
    80004cbc:	c551                	beqz	a0,80004d48 <pipealloc+0xb2>
    80004cbe:	00000097          	auipc	ra,0x0
    80004cc2:	bec080e7          	jalr	-1044(ra) # 800048aa <filealloc>
    80004cc6:	00aa3023          	sd	a0,0(s4)
    80004cca:	c92d                	beqz	a0,80004d3c <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004ccc:	ffffc097          	auipc	ra,0xffffc
    80004cd0:	e16080e7          	jalr	-490(ra) # 80000ae2 <kalloc>
    80004cd4:	892a                	mv	s2,a0
    80004cd6:	c125                	beqz	a0,80004d36 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004cd8:	4985                	li	s3,1
    80004cda:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004cde:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004ce2:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004ce6:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004cea:	00004597          	auipc	a1,0x4
    80004cee:	9c658593          	addi	a1,a1,-1594 # 800086b0 <syscalls+0x280>
    80004cf2:	ffffc097          	auipc	ra,0xffffc
    80004cf6:	e50080e7          	jalr	-432(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    80004cfa:	609c                	ld	a5,0(s1)
    80004cfc:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d00:	609c                	ld	a5,0(s1)
    80004d02:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d06:	609c                	ld	a5,0(s1)
    80004d08:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d0c:	609c                	ld	a5,0(s1)
    80004d0e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004d12:	000a3783          	ld	a5,0(s4)
    80004d16:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004d1a:	000a3783          	ld	a5,0(s4)
    80004d1e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004d22:	000a3783          	ld	a5,0(s4)
    80004d26:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004d2a:	000a3783          	ld	a5,0(s4)
    80004d2e:	0127b823          	sd	s2,16(a5)
  return 0;
    80004d32:	4501                	li	a0,0
    80004d34:	a025                	j	80004d5c <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004d36:	6088                	ld	a0,0(s1)
    80004d38:	e501                	bnez	a0,80004d40 <pipealloc+0xaa>
    80004d3a:	a039                	j	80004d48 <pipealloc+0xb2>
    80004d3c:	6088                	ld	a0,0(s1)
    80004d3e:	c51d                	beqz	a0,80004d6c <pipealloc+0xd6>
    fileclose(*f0);
    80004d40:	00000097          	auipc	ra,0x0
    80004d44:	c26080e7          	jalr	-986(ra) # 80004966 <fileclose>
  if(*f1)
    80004d48:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004d4c:	557d                	li	a0,-1
  if(*f1)
    80004d4e:	c799                	beqz	a5,80004d5c <pipealloc+0xc6>
    fileclose(*f1);
    80004d50:	853e                	mv	a0,a5
    80004d52:	00000097          	auipc	ra,0x0
    80004d56:	c14080e7          	jalr	-1004(ra) # 80004966 <fileclose>
  return -1;
    80004d5a:	557d                	li	a0,-1
}
    80004d5c:	70a2                	ld	ra,40(sp)
    80004d5e:	7402                	ld	s0,32(sp)
    80004d60:	64e2                	ld	s1,24(sp)
    80004d62:	6942                	ld	s2,16(sp)
    80004d64:	69a2                	ld	s3,8(sp)
    80004d66:	6a02                	ld	s4,0(sp)
    80004d68:	6145                	addi	sp,sp,48
    80004d6a:	8082                	ret
  return -1;
    80004d6c:	557d                	li	a0,-1
    80004d6e:	b7fd                	j	80004d5c <pipealloc+0xc6>

0000000080004d70 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004d70:	1101                	addi	sp,sp,-32
    80004d72:	ec06                	sd	ra,24(sp)
    80004d74:	e822                	sd	s0,16(sp)
    80004d76:	e426                	sd	s1,8(sp)
    80004d78:	e04a                	sd	s2,0(sp)
    80004d7a:	1000                	addi	s0,sp,32
    80004d7c:	84aa                	mv	s1,a0
    80004d7e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004d80:	ffffc097          	auipc	ra,0xffffc
    80004d84:	e52080e7          	jalr	-430(ra) # 80000bd2 <acquire>
  if(writable){
    80004d88:	02090d63          	beqz	s2,80004dc2 <pipeclose+0x52>
    pi->writeopen = 0;
    80004d8c:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004d90:	21848513          	addi	a0,s1,536
    80004d94:	ffffd097          	auipc	ra,0xffffd
    80004d98:	7de080e7          	jalr	2014(ra) # 80002572 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004d9c:	2204b783          	ld	a5,544(s1)
    80004da0:	eb95                	bnez	a5,80004dd4 <pipeclose+0x64>
    release(&pi->lock);
    80004da2:	8526                	mv	a0,s1
    80004da4:	ffffc097          	auipc	ra,0xffffc
    80004da8:	ee2080e7          	jalr	-286(ra) # 80000c86 <release>
    kfree((char*)pi);
    80004dac:	8526                	mv	a0,s1
    80004dae:	ffffc097          	auipc	ra,0xffffc
    80004db2:	c38080e7          	jalr	-968(ra) # 800009e6 <kfree>
  } else
    release(&pi->lock);
}
    80004db6:	60e2                	ld	ra,24(sp)
    80004db8:	6442                	ld	s0,16(sp)
    80004dba:	64a2                	ld	s1,8(sp)
    80004dbc:	6902                	ld	s2,0(sp)
    80004dbe:	6105                	addi	sp,sp,32
    80004dc0:	8082                	ret
    pi->readopen = 0;
    80004dc2:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004dc6:	21c48513          	addi	a0,s1,540
    80004dca:	ffffd097          	auipc	ra,0xffffd
    80004dce:	7a8080e7          	jalr	1960(ra) # 80002572 <wakeup>
    80004dd2:	b7e9                	j	80004d9c <pipeclose+0x2c>
    release(&pi->lock);
    80004dd4:	8526                	mv	a0,s1
    80004dd6:	ffffc097          	auipc	ra,0xffffc
    80004dda:	eb0080e7          	jalr	-336(ra) # 80000c86 <release>
}
    80004dde:	bfe1                	j	80004db6 <pipeclose+0x46>

0000000080004de0 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004de0:	7159                	addi	sp,sp,-112
    80004de2:	f486                	sd	ra,104(sp)
    80004de4:	f0a2                	sd	s0,96(sp)
    80004de6:	eca6                	sd	s1,88(sp)
    80004de8:	e8ca                	sd	s2,80(sp)
    80004dea:	e4ce                	sd	s3,72(sp)
    80004dec:	e0d2                	sd	s4,64(sp)
    80004dee:	fc56                	sd	s5,56(sp)
    80004df0:	f85a                	sd	s6,48(sp)
    80004df2:	f45e                	sd	s7,40(sp)
    80004df4:	f062                	sd	s8,32(sp)
    80004df6:	ec66                	sd	s9,24(sp)
    80004df8:	1880                	addi	s0,sp,112
    80004dfa:	84aa                	mv	s1,a0
    80004dfc:	8aae                	mv	s5,a1
    80004dfe:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004e00:	ffffd097          	auipc	ra,0xffffd
    80004e04:	c82080e7          	jalr	-894(ra) # 80001a82 <myproc>
    80004e08:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004e0a:	8526                	mv	a0,s1
    80004e0c:	ffffc097          	auipc	ra,0xffffc
    80004e10:	dc6080e7          	jalr	-570(ra) # 80000bd2 <acquire>
  while(i < n){
    80004e14:	0d405163          	blez	s4,80004ed6 <pipewrite+0xf6>
    80004e18:	8ba6                	mv	s7,s1
  int i = 0;
    80004e1a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004e1c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004e1e:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004e22:	21c48c13          	addi	s8,s1,540
    80004e26:	a08d                	j	80004e88 <pipewrite+0xa8>
      release(&pi->lock);
    80004e28:	8526                	mv	a0,s1
    80004e2a:	ffffc097          	auipc	ra,0xffffc
    80004e2e:	e5c080e7          	jalr	-420(ra) # 80000c86 <release>
      return -1;
    80004e32:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004e34:	854a                	mv	a0,s2
    80004e36:	70a6                	ld	ra,104(sp)
    80004e38:	7406                	ld	s0,96(sp)
    80004e3a:	64e6                	ld	s1,88(sp)
    80004e3c:	6946                	ld	s2,80(sp)
    80004e3e:	69a6                	ld	s3,72(sp)
    80004e40:	6a06                	ld	s4,64(sp)
    80004e42:	7ae2                	ld	s5,56(sp)
    80004e44:	7b42                	ld	s6,48(sp)
    80004e46:	7ba2                	ld	s7,40(sp)
    80004e48:	7c02                	ld	s8,32(sp)
    80004e4a:	6ce2                	ld	s9,24(sp)
    80004e4c:	6165                	addi	sp,sp,112
    80004e4e:	8082                	ret
      wakeup(&pi->nread);
    80004e50:	8566                	mv	a0,s9
    80004e52:	ffffd097          	auipc	ra,0xffffd
    80004e56:	720080e7          	jalr	1824(ra) # 80002572 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004e5a:	85de                	mv	a1,s7
    80004e5c:	8562                	mv	a0,s8
    80004e5e:	ffffd097          	auipc	ra,0xffffd
    80004e62:	588080e7          	jalr	1416(ra) # 800023e6 <sleep>
    80004e66:	a839                	j	80004e84 <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004e68:	21c4a783          	lw	a5,540(s1)
    80004e6c:	0017871b          	addiw	a4,a5,1
    80004e70:	20e4ae23          	sw	a4,540(s1)
    80004e74:	1ff7f793          	andi	a5,a5,511
    80004e78:	97a6                	add	a5,a5,s1
    80004e7a:	f9f44703          	lbu	a4,-97(s0)
    80004e7e:	00e78c23          	sb	a4,24(a5)
      i++;
    80004e82:	2905                	addiw	s2,s2,1
  while(i < n){
    80004e84:	03495d63          	bge	s2,s4,80004ebe <pipewrite+0xde>
    if(pi->readopen == 0 || pr->killed){
    80004e88:	2204a783          	lw	a5,544(s1)
    80004e8c:	dfd1                	beqz	a5,80004e28 <pipewrite+0x48>
    80004e8e:	0289a783          	lw	a5,40(s3)
    80004e92:	fbd9                	bnez	a5,80004e28 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004e94:	2184a783          	lw	a5,536(s1)
    80004e98:	21c4a703          	lw	a4,540(s1)
    80004e9c:	2007879b          	addiw	a5,a5,512
    80004ea0:	faf708e3          	beq	a4,a5,80004e50 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ea4:	4685                	li	a3,1
    80004ea6:	01590633          	add	a2,s2,s5
    80004eaa:	f9f40593          	addi	a1,s0,-97
    80004eae:	0509b503          	ld	a0,80(s3)
    80004eb2:	ffffd097          	auipc	ra,0xffffd
    80004eb6:	82c080e7          	jalr	-2004(ra) # 800016de <copyin>
    80004eba:	fb6517e3          	bne	a0,s6,80004e68 <pipewrite+0x88>
  wakeup(&pi->nread);
    80004ebe:	21848513          	addi	a0,s1,536
    80004ec2:	ffffd097          	auipc	ra,0xffffd
    80004ec6:	6b0080e7          	jalr	1712(ra) # 80002572 <wakeup>
  release(&pi->lock);
    80004eca:	8526                	mv	a0,s1
    80004ecc:	ffffc097          	auipc	ra,0xffffc
    80004ed0:	dba080e7          	jalr	-582(ra) # 80000c86 <release>
  return i;
    80004ed4:	b785                	j	80004e34 <pipewrite+0x54>
  int i = 0;
    80004ed6:	4901                	li	s2,0
    80004ed8:	b7dd                	j	80004ebe <pipewrite+0xde>

0000000080004eda <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004eda:	715d                	addi	sp,sp,-80
    80004edc:	e486                	sd	ra,72(sp)
    80004ede:	e0a2                	sd	s0,64(sp)
    80004ee0:	fc26                	sd	s1,56(sp)
    80004ee2:	f84a                	sd	s2,48(sp)
    80004ee4:	f44e                	sd	s3,40(sp)
    80004ee6:	f052                	sd	s4,32(sp)
    80004ee8:	ec56                	sd	s5,24(sp)
    80004eea:	e85a                	sd	s6,16(sp)
    80004eec:	0880                	addi	s0,sp,80
    80004eee:	84aa                	mv	s1,a0
    80004ef0:	892e                	mv	s2,a1
    80004ef2:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004ef4:	ffffd097          	auipc	ra,0xffffd
    80004ef8:	b8e080e7          	jalr	-1138(ra) # 80001a82 <myproc>
    80004efc:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004efe:	8b26                	mv	s6,s1
    80004f00:	8526                	mv	a0,s1
    80004f02:	ffffc097          	auipc	ra,0xffffc
    80004f06:	cd0080e7          	jalr	-816(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f0a:	2184a703          	lw	a4,536(s1)
    80004f0e:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f12:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f16:	02f71463          	bne	a4,a5,80004f3e <piperead+0x64>
    80004f1a:	2244a783          	lw	a5,548(s1)
    80004f1e:	c385                	beqz	a5,80004f3e <piperead+0x64>
    if(pr->killed){
    80004f20:	028a2783          	lw	a5,40(s4)
    80004f24:	ebc1                	bnez	a5,80004fb4 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f26:	85da                	mv	a1,s6
    80004f28:	854e                	mv	a0,s3
    80004f2a:	ffffd097          	auipc	ra,0xffffd
    80004f2e:	4bc080e7          	jalr	1212(ra) # 800023e6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f32:	2184a703          	lw	a4,536(s1)
    80004f36:	21c4a783          	lw	a5,540(s1)
    80004f3a:	fef700e3          	beq	a4,a5,80004f1a <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f3e:	09505263          	blez	s5,80004fc2 <piperead+0xe8>
    80004f42:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f44:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    80004f46:	2184a783          	lw	a5,536(s1)
    80004f4a:	21c4a703          	lw	a4,540(s1)
    80004f4e:	02f70d63          	beq	a4,a5,80004f88 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004f52:	0017871b          	addiw	a4,a5,1
    80004f56:	20e4ac23          	sw	a4,536(s1)
    80004f5a:	1ff7f793          	andi	a5,a5,511
    80004f5e:	97a6                	add	a5,a5,s1
    80004f60:	0187c783          	lbu	a5,24(a5)
    80004f64:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004f68:	4685                	li	a3,1
    80004f6a:	fbf40613          	addi	a2,s0,-65
    80004f6e:	85ca                	mv	a1,s2
    80004f70:	050a3503          	ld	a0,80(s4)
    80004f74:	ffffc097          	auipc	ra,0xffffc
    80004f78:	6de080e7          	jalr	1758(ra) # 80001652 <copyout>
    80004f7c:	01650663          	beq	a0,s6,80004f88 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004f80:	2985                	addiw	s3,s3,1
    80004f82:	0905                	addi	s2,s2,1
    80004f84:	fd3a91e3          	bne	s5,s3,80004f46 <piperead+0x6c>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004f88:	21c48513          	addi	a0,s1,540
    80004f8c:	ffffd097          	auipc	ra,0xffffd
    80004f90:	5e6080e7          	jalr	1510(ra) # 80002572 <wakeup>
  release(&pi->lock);
    80004f94:	8526                	mv	a0,s1
    80004f96:	ffffc097          	auipc	ra,0xffffc
    80004f9a:	cf0080e7          	jalr	-784(ra) # 80000c86 <release>
  return i;
}
    80004f9e:	854e                	mv	a0,s3
    80004fa0:	60a6                	ld	ra,72(sp)
    80004fa2:	6406                	ld	s0,64(sp)
    80004fa4:	74e2                	ld	s1,56(sp)
    80004fa6:	7942                	ld	s2,48(sp)
    80004fa8:	79a2                	ld	s3,40(sp)
    80004faa:	7a02                	ld	s4,32(sp)
    80004fac:	6ae2                	ld	s5,24(sp)
    80004fae:	6b42                	ld	s6,16(sp)
    80004fb0:	6161                	addi	sp,sp,80
    80004fb2:	8082                	ret
      release(&pi->lock);
    80004fb4:	8526                	mv	a0,s1
    80004fb6:	ffffc097          	auipc	ra,0xffffc
    80004fba:	cd0080e7          	jalr	-816(ra) # 80000c86 <release>
      return -1;
    80004fbe:	59fd                	li	s3,-1
    80004fc0:	bff9                	j	80004f9e <piperead+0xc4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fc2:	4981                	li	s3,0
    80004fc4:	b7d1                	j	80004f88 <piperead+0xae>

0000000080004fc6 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004fc6:	df010113          	addi	sp,sp,-528
    80004fca:	20113423          	sd	ra,520(sp)
    80004fce:	20813023          	sd	s0,512(sp)
    80004fd2:	ffa6                	sd	s1,504(sp)
    80004fd4:	fbca                	sd	s2,496(sp)
    80004fd6:	f7ce                	sd	s3,488(sp)
    80004fd8:	f3d2                	sd	s4,480(sp)
    80004fda:	efd6                	sd	s5,472(sp)
    80004fdc:	ebda                	sd	s6,464(sp)
    80004fde:	e7de                	sd	s7,456(sp)
    80004fe0:	e3e2                	sd	s8,448(sp)
    80004fe2:	ff66                	sd	s9,440(sp)
    80004fe4:	fb6a                	sd	s10,432(sp)
    80004fe6:	f76e                	sd	s11,424(sp)
    80004fe8:	0c00                	addi	s0,sp,528
    80004fea:	84aa                	mv	s1,a0
    80004fec:	dea43c23          	sd	a0,-520(s0)
    80004ff0:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004ff4:	ffffd097          	auipc	ra,0xffffd
    80004ff8:	a8e080e7          	jalr	-1394(ra) # 80001a82 <myproc>
    80004ffc:	892a                	mv	s2,a0

  begin_op();
    80004ffe:	fffff097          	auipc	ra,0xfffff
    80005002:	49c080e7          	jalr	1180(ra) # 8000449a <begin_op>

  if((ip = namei(path)) == 0){
    80005006:	8526                	mv	a0,s1
    80005008:	fffff097          	auipc	ra,0xfffff
    8000500c:	276080e7          	jalr	630(ra) # 8000427e <namei>
    80005010:	c92d                	beqz	a0,80005082 <exec+0xbc>
    80005012:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005014:	fffff097          	auipc	ra,0xfffff
    80005018:	ab4080e7          	jalr	-1356(ra) # 80003ac8 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000501c:	04000713          	li	a4,64
    80005020:	4681                	li	a3,0
    80005022:	e4840613          	addi	a2,s0,-440
    80005026:	4581                	li	a1,0
    80005028:	8526                	mv	a0,s1
    8000502a:	fffff097          	auipc	ra,0xfffff
    8000502e:	d52080e7          	jalr	-686(ra) # 80003d7c <readi>
    80005032:	04000793          	li	a5,64
    80005036:	00f51a63          	bne	a0,a5,8000504a <exec+0x84>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    8000503a:	e4842703          	lw	a4,-440(s0)
    8000503e:	464c47b7          	lui	a5,0x464c4
    80005042:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005046:	04f70463          	beq	a4,a5,8000508e <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000504a:	8526                	mv	a0,s1
    8000504c:	fffff097          	auipc	ra,0xfffff
    80005050:	cde080e7          	jalr	-802(ra) # 80003d2a <iunlockput>
    end_op();
    80005054:	fffff097          	auipc	ra,0xfffff
    80005058:	4c6080e7          	jalr	1222(ra) # 8000451a <end_op>
  }
  return -1;
    8000505c:	557d                	li	a0,-1
}
    8000505e:	20813083          	ld	ra,520(sp)
    80005062:	20013403          	ld	s0,512(sp)
    80005066:	74fe                	ld	s1,504(sp)
    80005068:	795e                	ld	s2,496(sp)
    8000506a:	79be                	ld	s3,488(sp)
    8000506c:	7a1e                	ld	s4,480(sp)
    8000506e:	6afe                	ld	s5,472(sp)
    80005070:	6b5e                	ld	s6,464(sp)
    80005072:	6bbe                	ld	s7,456(sp)
    80005074:	6c1e                	ld	s8,448(sp)
    80005076:	7cfa                	ld	s9,440(sp)
    80005078:	7d5a                	ld	s10,432(sp)
    8000507a:	7dba                	ld	s11,424(sp)
    8000507c:	21010113          	addi	sp,sp,528
    80005080:	8082                	ret
    end_op();
    80005082:	fffff097          	auipc	ra,0xfffff
    80005086:	498080e7          	jalr	1176(ra) # 8000451a <end_op>
    return -1;
    8000508a:	557d                	li	a0,-1
    8000508c:	bfc9                	j	8000505e <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    8000508e:	854a                	mv	a0,s2
    80005090:	ffffd097          	auipc	ra,0xffffd
    80005094:	ab8080e7          	jalr	-1352(ra) # 80001b48 <proc_pagetable>
    80005098:	8baa                	mv	s7,a0
    8000509a:	d945                	beqz	a0,8000504a <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000509c:	e6842983          	lw	s3,-408(s0)
    800050a0:	e8045783          	lhu	a5,-384(s0)
    800050a4:	c7ad                	beqz	a5,8000510e <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800050a6:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800050a8:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    800050aa:	6c85                	lui	s9,0x1
    800050ac:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800050b0:	def43823          	sd	a5,-528(s0)
    800050b4:	a42d                	j	800052de <exec+0x318>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800050b6:	00003517          	auipc	a0,0x3
    800050ba:	60250513          	addi	a0,a0,1538 # 800086b8 <syscalls+0x288>
    800050be:	ffffb097          	auipc	ra,0xffffb
    800050c2:	472080e7          	jalr	1138(ra) # 80000530 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800050c6:	8756                	mv	a4,s5
    800050c8:	012d86bb          	addw	a3,s11,s2
    800050cc:	4581                	li	a1,0
    800050ce:	8526                	mv	a0,s1
    800050d0:	fffff097          	auipc	ra,0xfffff
    800050d4:	cac080e7          	jalr	-852(ra) # 80003d7c <readi>
    800050d8:	2501                	sext.w	a0,a0
    800050da:	1aaa9963          	bne	s5,a0,8000528c <exec+0x2c6>
  for(i = 0; i < sz; i += PGSIZE){
    800050de:	6785                	lui	a5,0x1
    800050e0:	0127893b          	addw	s2,a5,s2
    800050e4:	77fd                	lui	a5,0xfffff
    800050e6:	01478a3b          	addw	s4,a5,s4
    800050ea:	1f897163          	bgeu	s2,s8,800052cc <exec+0x306>
    pa = walkaddr(pagetable, va + i);
    800050ee:	02091593          	slli	a1,s2,0x20
    800050f2:	9181                	srli	a1,a1,0x20
    800050f4:	95ea                	add	a1,a1,s10
    800050f6:	855e                	mv	a0,s7
    800050f8:	ffffc097          	auipc	ra,0xffffc
    800050fc:	f68080e7          	jalr	-152(ra) # 80001060 <walkaddr>
    80005100:	862a                	mv	a2,a0
    if(pa == 0)
    80005102:	d955                	beqz	a0,800050b6 <exec+0xf0>
      n = PGSIZE;
    80005104:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80005106:	fd9a70e3          	bgeu	s4,s9,800050c6 <exec+0x100>
      n = sz - i;
    8000510a:	8ad2                	mv	s5,s4
    8000510c:	bf6d                	j	800050c6 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    8000510e:	4901                	li	s2,0
  iunlockput(ip);
    80005110:	8526                	mv	a0,s1
    80005112:	fffff097          	auipc	ra,0xfffff
    80005116:	c18080e7          	jalr	-1000(ra) # 80003d2a <iunlockput>
  end_op();
    8000511a:	fffff097          	auipc	ra,0xfffff
    8000511e:	400080e7          	jalr	1024(ra) # 8000451a <end_op>
  p = myproc();
    80005122:	ffffd097          	auipc	ra,0xffffd
    80005126:	960080e7          	jalr	-1696(ra) # 80001a82 <myproc>
    8000512a:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    8000512c:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80005130:	6785                	lui	a5,0x1
    80005132:	17fd                	addi	a5,a5,-1
    80005134:	993e                	add	s2,s2,a5
    80005136:	757d                	lui	a0,0xfffff
    80005138:	00a977b3          	and	a5,s2,a0
    8000513c:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005140:	6609                	lui	a2,0x2
    80005142:	963e                	add	a2,a2,a5
    80005144:	85be                	mv	a1,a5
    80005146:	855e                	mv	a0,s7
    80005148:	ffffc097          	auipc	ra,0xffffc
    8000514c:	2ba080e7          	jalr	698(ra) # 80001402 <uvmalloc>
    80005150:	8b2a                	mv	s6,a0
  ip = 0;
    80005152:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80005154:	12050c63          	beqz	a0,8000528c <exec+0x2c6>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005158:	75f9                	lui	a1,0xffffe
    8000515a:	95aa                	add	a1,a1,a0
    8000515c:	855e                	mv	a0,s7
    8000515e:	ffffc097          	auipc	ra,0xffffc
    80005162:	4c2080e7          	jalr	1218(ra) # 80001620 <uvmclear>
  stackbase = sp - PGSIZE;
    80005166:	7c7d                	lui	s8,0xfffff
    80005168:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    8000516a:	e0043783          	ld	a5,-512(s0)
    8000516e:	6388                	ld	a0,0(a5)
    80005170:	c535                	beqz	a0,800051dc <exec+0x216>
    80005172:	e8840993          	addi	s3,s0,-376
    80005176:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    8000517a:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    8000517c:	ffffc097          	auipc	ra,0xffffc
    80005180:	cda080e7          	jalr	-806(ra) # 80000e56 <strlen>
    80005184:	2505                	addiw	a0,a0,1
    80005186:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000518a:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000518e:	13896363          	bltu	s2,s8,800052b4 <exec+0x2ee>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005192:	e0043d83          	ld	s11,-512(s0)
    80005196:	000dba03          	ld	s4,0(s11)
    8000519a:	8552                	mv	a0,s4
    8000519c:	ffffc097          	auipc	ra,0xffffc
    800051a0:	cba080e7          	jalr	-838(ra) # 80000e56 <strlen>
    800051a4:	0015069b          	addiw	a3,a0,1
    800051a8:	8652                	mv	a2,s4
    800051aa:	85ca                	mv	a1,s2
    800051ac:	855e                	mv	a0,s7
    800051ae:	ffffc097          	auipc	ra,0xffffc
    800051b2:	4a4080e7          	jalr	1188(ra) # 80001652 <copyout>
    800051b6:	10054363          	bltz	a0,800052bc <exec+0x2f6>
    ustack[argc] = sp;
    800051ba:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800051be:	0485                	addi	s1,s1,1
    800051c0:	008d8793          	addi	a5,s11,8
    800051c4:	e0f43023          	sd	a5,-512(s0)
    800051c8:	008db503          	ld	a0,8(s11)
    800051cc:	c911                	beqz	a0,800051e0 <exec+0x21a>
    if(argc >= MAXARG)
    800051ce:	09a1                	addi	s3,s3,8
    800051d0:	fb3c96e3          	bne	s9,s3,8000517c <exec+0x1b6>
  sz = sz1;
    800051d4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800051d8:	4481                	li	s1,0
    800051da:	a84d                	j	8000528c <exec+0x2c6>
  sp = sz;
    800051dc:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800051de:	4481                	li	s1,0
  ustack[argc] = 0;
    800051e0:	00349793          	slli	a5,s1,0x3
    800051e4:	f9040713          	addi	a4,s0,-112
    800051e8:	97ba                	add	a5,a5,a4
    800051ea:	ee07bc23          	sd	zero,-264(a5) # ef8 <_entry-0x7ffff108>
  sp -= (argc+1) * sizeof(uint64);
    800051ee:	00148693          	addi	a3,s1,1
    800051f2:	068e                	slli	a3,a3,0x3
    800051f4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800051f8:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800051fc:	01897663          	bgeu	s2,s8,80005208 <exec+0x242>
  sz = sz1;
    80005200:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80005204:	4481                	li	s1,0
    80005206:	a059                	j	8000528c <exec+0x2c6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005208:	e8840613          	addi	a2,s0,-376
    8000520c:	85ca                	mv	a1,s2
    8000520e:	855e                	mv	a0,s7
    80005210:	ffffc097          	auipc	ra,0xffffc
    80005214:	442080e7          	jalr	1090(ra) # 80001652 <copyout>
    80005218:	0a054663          	bltz	a0,800052c4 <exec+0x2fe>
  p->trapframe->a1 = sp;
    8000521c:	058ab783          	ld	a5,88(s5)
    80005220:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005224:	df843783          	ld	a5,-520(s0)
    80005228:	0007c703          	lbu	a4,0(a5)
    8000522c:	cf11                	beqz	a4,80005248 <exec+0x282>
    8000522e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005230:	02f00693          	li	a3,47
    80005234:	a029                	j	8000523e <exec+0x278>
  for(last=s=path; *s; s++)
    80005236:	0785                	addi	a5,a5,1
    80005238:	fff7c703          	lbu	a4,-1(a5)
    8000523c:	c711                	beqz	a4,80005248 <exec+0x282>
    if(*s == '/')
    8000523e:	fed71ce3          	bne	a4,a3,80005236 <exec+0x270>
      last = s+1;
    80005242:	def43c23          	sd	a5,-520(s0)
    80005246:	bfc5                	j	80005236 <exec+0x270>
  safestrcpy(p->name, last, sizeof(p->name));
    80005248:	4641                	li	a2,16
    8000524a:	df843583          	ld	a1,-520(s0)
    8000524e:	158a8513          	addi	a0,s5,344
    80005252:	ffffc097          	auipc	ra,0xffffc
    80005256:	bd2080e7          	jalr	-1070(ra) # 80000e24 <safestrcpy>
  oldpagetable = p->pagetable;
    8000525a:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000525e:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80005262:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005266:	058ab783          	ld	a5,88(s5)
    8000526a:	e6043703          	ld	a4,-416(s0)
    8000526e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005270:	058ab783          	ld	a5,88(s5)
    80005274:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005278:	85ea                	mv	a1,s10
    8000527a:	ffffd097          	auipc	ra,0xffffd
    8000527e:	96a080e7          	jalr	-1686(ra) # 80001be4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005282:	0004851b          	sext.w	a0,s1
    80005286:	bbe1                	j	8000505e <exec+0x98>
    80005288:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    8000528c:	e0843583          	ld	a1,-504(s0)
    80005290:	855e                	mv	a0,s7
    80005292:	ffffd097          	auipc	ra,0xffffd
    80005296:	952080e7          	jalr	-1710(ra) # 80001be4 <proc_freepagetable>
  if(ip){
    8000529a:	da0498e3          	bnez	s1,8000504a <exec+0x84>
  return -1;
    8000529e:	557d                	li	a0,-1
    800052a0:	bb7d                	j	8000505e <exec+0x98>
    800052a2:	e1243423          	sd	s2,-504(s0)
    800052a6:	b7dd                	j	8000528c <exec+0x2c6>
    800052a8:	e1243423          	sd	s2,-504(s0)
    800052ac:	b7c5                	j	8000528c <exec+0x2c6>
    800052ae:	e1243423          	sd	s2,-504(s0)
    800052b2:	bfe9                	j	8000528c <exec+0x2c6>
  sz = sz1;
    800052b4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800052b8:	4481                	li	s1,0
    800052ba:	bfc9                	j	8000528c <exec+0x2c6>
  sz = sz1;
    800052bc:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800052c0:	4481                	li	s1,0
    800052c2:	b7e9                	j	8000528c <exec+0x2c6>
  sz = sz1;
    800052c4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800052c8:	4481                	li	s1,0
    800052ca:	b7c9                	j	8000528c <exec+0x2c6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800052cc:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800052d0:	2b05                	addiw	s6,s6,1
    800052d2:	0389899b          	addiw	s3,s3,56
    800052d6:	e8045783          	lhu	a5,-384(s0)
    800052da:	e2fb5be3          	bge	s6,a5,80005110 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800052de:	2981                	sext.w	s3,s3
    800052e0:	03800713          	li	a4,56
    800052e4:	86ce                	mv	a3,s3
    800052e6:	e1040613          	addi	a2,s0,-496
    800052ea:	4581                	li	a1,0
    800052ec:	8526                	mv	a0,s1
    800052ee:	fffff097          	auipc	ra,0xfffff
    800052f2:	a8e080e7          	jalr	-1394(ra) # 80003d7c <readi>
    800052f6:	03800793          	li	a5,56
    800052fa:	f8f517e3          	bne	a0,a5,80005288 <exec+0x2c2>
    if(ph.type != ELF_PROG_LOAD)
    800052fe:	e1042783          	lw	a5,-496(s0)
    80005302:	4705                	li	a4,1
    80005304:	fce796e3          	bne	a5,a4,800052d0 <exec+0x30a>
    if(ph.memsz < ph.filesz)
    80005308:	e3843603          	ld	a2,-456(s0)
    8000530c:	e3043783          	ld	a5,-464(s0)
    80005310:	f8f669e3          	bltu	a2,a5,800052a2 <exec+0x2dc>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005314:	e2043783          	ld	a5,-480(s0)
    80005318:	963e                	add	a2,a2,a5
    8000531a:	f8f667e3          	bltu	a2,a5,800052a8 <exec+0x2e2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000531e:	85ca                	mv	a1,s2
    80005320:	855e                	mv	a0,s7
    80005322:	ffffc097          	auipc	ra,0xffffc
    80005326:	0e0080e7          	jalr	224(ra) # 80001402 <uvmalloc>
    8000532a:	e0a43423          	sd	a0,-504(s0)
    8000532e:	d141                	beqz	a0,800052ae <exec+0x2e8>
    if(ph.vaddr % PGSIZE != 0)
    80005330:	e2043d03          	ld	s10,-480(s0)
    80005334:	df043783          	ld	a5,-528(s0)
    80005338:	00fd77b3          	and	a5,s10,a5
    8000533c:	fba1                	bnez	a5,8000528c <exec+0x2c6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000533e:	e1842d83          	lw	s11,-488(s0)
    80005342:	e3042c03          	lw	s8,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005346:	f80c03e3          	beqz	s8,800052cc <exec+0x306>
    8000534a:	8a62                	mv	s4,s8
    8000534c:	4901                	li	s2,0
    8000534e:	b345                	j	800050ee <exec+0x128>

0000000080005350 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005350:	7179                	addi	sp,sp,-48
    80005352:	f406                	sd	ra,40(sp)
    80005354:	f022                	sd	s0,32(sp)
    80005356:	ec26                	sd	s1,24(sp)
    80005358:	e84a                	sd	s2,16(sp)
    8000535a:	1800                	addi	s0,sp,48
    8000535c:	892e                	mv	s2,a1
    8000535e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80005360:	fdc40593          	addi	a1,s0,-36
    80005364:	ffffe097          	auipc	ra,0xffffe
    80005368:	af2080e7          	jalr	-1294(ra) # 80002e56 <argint>
    8000536c:	04054063          	bltz	a0,800053ac <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005370:	fdc42703          	lw	a4,-36(s0)
    80005374:	47bd                	li	a5,15
    80005376:	02e7ed63          	bltu	a5,a4,800053b0 <argfd+0x60>
    8000537a:	ffffc097          	auipc	ra,0xffffc
    8000537e:	708080e7          	jalr	1800(ra) # 80001a82 <myproc>
    80005382:	fdc42703          	lw	a4,-36(s0)
    80005386:	01a70793          	addi	a5,a4,26
    8000538a:	078e                	slli	a5,a5,0x3
    8000538c:	953e                	add	a0,a0,a5
    8000538e:	611c                	ld	a5,0(a0)
    80005390:	c395                	beqz	a5,800053b4 <argfd+0x64>
    return -1;
  if(pfd)
    80005392:	00090463          	beqz	s2,8000539a <argfd+0x4a>
    *pfd = fd;
    80005396:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000539a:	4501                	li	a0,0
  if(pf)
    8000539c:	c091                	beqz	s1,800053a0 <argfd+0x50>
    *pf = f;
    8000539e:	e09c                	sd	a5,0(s1)
}
    800053a0:	70a2                	ld	ra,40(sp)
    800053a2:	7402                	ld	s0,32(sp)
    800053a4:	64e2                	ld	s1,24(sp)
    800053a6:	6942                	ld	s2,16(sp)
    800053a8:	6145                	addi	sp,sp,48
    800053aa:	8082                	ret
    return -1;
    800053ac:	557d                	li	a0,-1
    800053ae:	bfcd                	j	800053a0 <argfd+0x50>
    return -1;
    800053b0:	557d                	li	a0,-1
    800053b2:	b7fd                	j	800053a0 <argfd+0x50>
    800053b4:	557d                	li	a0,-1
    800053b6:	b7ed                	j	800053a0 <argfd+0x50>

00000000800053b8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800053b8:	1101                	addi	sp,sp,-32
    800053ba:	ec06                	sd	ra,24(sp)
    800053bc:	e822                	sd	s0,16(sp)
    800053be:	e426                	sd	s1,8(sp)
    800053c0:	1000                	addi	s0,sp,32
    800053c2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800053c4:	ffffc097          	auipc	ra,0xffffc
    800053c8:	6be080e7          	jalr	1726(ra) # 80001a82 <myproc>
    800053cc:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800053ce:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffd90d0>
    800053d2:	4501                	li	a0,0
    800053d4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800053d6:	6398                	ld	a4,0(a5)
    800053d8:	cb19                	beqz	a4,800053ee <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800053da:	2505                	addiw	a0,a0,1
    800053dc:	07a1                	addi	a5,a5,8
    800053de:	fed51ce3          	bne	a0,a3,800053d6 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800053e2:	557d                	li	a0,-1
}
    800053e4:	60e2                	ld	ra,24(sp)
    800053e6:	6442                	ld	s0,16(sp)
    800053e8:	64a2                	ld	s1,8(sp)
    800053ea:	6105                	addi	sp,sp,32
    800053ec:	8082                	ret
      p->ofile[fd] = f;
    800053ee:	01a50793          	addi	a5,a0,26
    800053f2:	078e                	slli	a5,a5,0x3
    800053f4:	963e                	add	a2,a2,a5
    800053f6:	e204                	sd	s1,0(a2)
      return fd;
    800053f8:	b7f5                	j	800053e4 <fdalloc+0x2c>

00000000800053fa <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800053fa:	715d                	addi	sp,sp,-80
    800053fc:	e486                	sd	ra,72(sp)
    800053fe:	e0a2                	sd	s0,64(sp)
    80005400:	fc26                	sd	s1,56(sp)
    80005402:	f84a                	sd	s2,48(sp)
    80005404:	f44e                	sd	s3,40(sp)
    80005406:	f052                	sd	s4,32(sp)
    80005408:	ec56                	sd	s5,24(sp)
    8000540a:	0880                	addi	s0,sp,80
    8000540c:	89ae                	mv	s3,a1
    8000540e:	8ab2                	mv	s5,a2
    80005410:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005412:	fb040593          	addi	a1,s0,-80
    80005416:	fffff097          	auipc	ra,0xfffff
    8000541a:	e86080e7          	jalr	-378(ra) # 8000429c <nameiparent>
    8000541e:	892a                	mv	s2,a0
    80005420:	12050f63          	beqz	a0,8000555e <create+0x164>
    return 0;

  ilock(dp);
    80005424:	ffffe097          	auipc	ra,0xffffe
    80005428:	6a4080e7          	jalr	1700(ra) # 80003ac8 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000542c:	4601                	li	a2,0
    8000542e:	fb040593          	addi	a1,s0,-80
    80005432:	854a                	mv	a0,s2
    80005434:	fffff097          	auipc	ra,0xfffff
    80005438:	b78080e7          	jalr	-1160(ra) # 80003fac <dirlookup>
    8000543c:	84aa                	mv	s1,a0
    8000543e:	c921                	beqz	a0,8000548e <create+0x94>
    iunlockput(dp);
    80005440:	854a                	mv	a0,s2
    80005442:	fffff097          	auipc	ra,0xfffff
    80005446:	8e8080e7          	jalr	-1816(ra) # 80003d2a <iunlockput>
    ilock(ip);
    8000544a:	8526                	mv	a0,s1
    8000544c:	ffffe097          	auipc	ra,0xffffe
    80005450:	67c080e7          	jalr	1660(ra) # 80003ac8 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005454:	2981                	sext.w	s3,s3
    80005456:	4789                	li	a5,2
    80005458:	02f99463          	bne	s3,a5,80005480 <create+0x86>
    8000545c:	0444d783          	lhu	a5,68(s1)
    80005460:	37f9                	addiw	a5,a5,-2
    80005462:	17c2                	slli	a5,a5,0x30
    80005464:	93c1                	srli	a5,a5,0x30
    80005466:	4705                	li	a4,1
    80005468:	00f76c63          	bltu	a4,a5,80005480 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    8000546c:	8526                	mv	a0,s1
    8000546e:	60a6                	ld	ra,72(sp)
    80005470:	6406                	ld	s0,64(sp)
    80005472:	74e2                	ld	s1,56(sp)
    80005474:	7942                	ld	s2,48(sp)
    80005476:	79a2                	ld	s3,40(sp)
    80005478:	7a02                	ld	s4,32(sp)
    8000547a:	6ae2                	ld	s5,24(sp)
    8000547c:	6161                	addi	sp,sp,80
    8000547e:	8082                	ret
    iunlockput(ip);
    80005480:	8526                	mv	a0,s1
    80005482:	fffff097          	auipc	ra,0xfffff
    80005486:	8a8080e7          	jalr	-1880(ra) # 80003d2a <iunlockput>
    return 0;
    8000548a:	4481                	li	s1,0
    8000548c:	b7c5                	j	8000546c <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    8000548e:	85ce                	mv	a1,s3
    80005490:	00092503          	lw	a0,0(s2)
    80005494:	ffffe097          	auipc	ra,0xffffe
    80005498:	49c080e7          	jalr	1180(ra) # 80003930 <ialloc>
    8000549c:	84aa                	mv	s1,a0
    8000549e:	c529                	beqz	a0,800054e8 <create+0xee>
  ilock(ip);
    800054a0:	ffffe097          	auipc	ra,0xffffe
    800054a4:	628080e7          	jalr	1576(ra) # 80003ac8 <ilock>
  ip->major = major;
    800054a8:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    800054ac:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    800054b0:	4785                	li	a5,1
    800054b2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054b6:	8526                	mv	a0,s1
    800054b8:	ffffe097          	auipc	ra,0xffffe
    800054bc:	546080e7          	jalr	1350(ra) # 800039fe <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800054c0:	2981                	sext.w	s3,s3
    800054c2:	4785                	li	a5,1
    800054c4:	02f98a63          	beq	s3,a5,800054f8 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    800054c8:	40d0                	lw	a2,4(s1)
    800054ca:	fb040593          	addi	a1,s0,-80
    800054ce:	854a                	mv	a0,s2
    800054d0:	fffff097          	auipc	ra,0xfffff
    800054d4:	cec080e7          	jalr	-788(ra) # 800041bc <dirlink>
    800054d8:	06054b63          	bltz	a0,8000554e <create+0x154>
  iunlockput(dp);
    800054dc:	854a                	mv	a0,s2
    800054de:	fffff097          	auipc	ra,0xfffff
    800054e2:	84c080e7          	jalr	-1972(ra) # 80003d2a <iunlockput>
  return ip;
    800054e6:	b759                	j	8000546c <create+0x72>
    panic("create: ialloc");
    800054e8:	00003517          	auipc	a0,0x3
    800054ec:	1f050513          	addi	a0,a0,496 # 800086d8 <syscalls+0x2a8>
    800054f0:	ffffb097          	auipc	ra,0xffffb
    800054f4:	040080e7          	jalr	64(ra) # 80000530 <panic>
    dp->nlink++;  // for ".."
    800054f8:	04a95783          	lhu	a5,74(s2)
    800054fc:	2785                	addiw	a5,a5,1
    800054fe:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005502:	854a                	mv	a0,s2
    80005504:	ffffe097          	auipc	ra,0xffffe
    80005508:	4fa080e7          	jalr	1274(ra) # 800039fe <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000550c:	40d0                	lw	a2,4(s1)
    8000550e:	00003597          	auipc	a1,0x3
    80005512:	1da58593          	addi	a1,a1,474 # 800086e8 <syscalls+0x2b8>
    80005516:	8526                	mv	a0,s1
    80005518:	fffff097          	auipc	ra,0xfffff
    8000551c:	ca4080e7          	jalr	-860(ra) # 800041bc <dirlink>
    80005520:	00054f63          	bltz	a0,8000553e <create+0x144>
    80005524:	00492603          	lw	a2,4(s2)
    80005528:	00003597          	auipc	a1,0x3
    8000552c:	1c858593          	addi	a1,a1,456 # 800086f0 <syscalls+0x2c0>
    80005530:	8526                	mv	a0,s1
    80005532:	fffff097          	auipc	ra,0xfffff
    80005536:	c8a080e7          	jalr	-886(ra) # 800041bc <dirlink>
    8000553a:	f80557e3          	bgez	a0,800054c8 <create+0xce>
      panic("create dots");
    8000553e:	00003517          	auipc	a0,0x3
    80005542:	1ba50513          	addi	a0,a0,442 # 800086f8 <syscalls+0x2c8>
    80005546:	ffffb097          	auipc	ra,0xffffb
    8000554a:	fea080e7          	jalr	-22(ra) # 80000530 <panic>
    panic("create: dirlink");
    8000554e:	00003517          	auipc	a0,0x3
    80005552:	1ba50513          	addi	a0,a0,442 # 80008708 <syscalls+0x2d8>
    80005556:	ffffb097          	auipc	ra,0xffffb
    8000555a:	fda080e7          	jalr	-38(ra) # 80000530 <panic>
    return 0;
    8000555e:	84aa                	mv	s1,a0
    80005560:	b731                	j	8000546c <create+0x72>

0000000080005562 <sys_dup>:
{
    80005562:	7179                	addi	sp,sp,-48
    80005564:	f406                	sd	ra,40(sp)
    80005566:	f022                	sd	s0,32(sp)
    80005568:	ec26                	sd	s1,24(sp)
    8000556a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000556c:	fd840613          	addi	a2,s0,-40
    80005570:	4581                	li	a1,0
    80005572:	4501                	li	a0,0
    80005574:	00000097          	auipc	ra,0x0
    80005578:	ddc080e7          	jalr	-548(ra) # 80005350 <argfd>
    return -1;
    8000557c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000557e:	02054363          	bltz	a0,800055a4 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80005582:	fd843503          	ld	a0,-40(s0)
    80005586:	00000097          	auipc	ra,0x0
    8000558a:	e32080e7          	jalr	-462(ra) # 800053b8 <fdalloc>
    8000558e:	84aa                	mv	s1,a0
    return -1;
    80005590:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005592:	00054963          	bltz	a0,800055a4 <sys_dup+0x42>
  filedup(f);
    80005596:	fd843503          	ld	a0,-40(s0)
    8000559a:	fffff097          	auipc	ra,0xfffff
    8000559e:	37a080e7          	jalr	890(ra) # 80004914 <filedup>
  return fd;
    800055a2:	87a6                	mv	a5,s1
}
    800055a4:	853e                	mv	a0,a5
    800055a6:	70a2                	ld	ra,40(sp)
    800055a8:	7402                	ld	s0,32(sp)
    800055aa:	64e2                	ld	s1,24(sp)
    800055ac:	6145                	addi	sp,sp,48
    800055ae:	8082                	ret

00000000800055b0 <sys_read>:
{
    800055b0:	7179                	addi	sp,sp,-48
    800055b2:	f406                	sd	ra,40(sp)
    800055b4:	f022                	sd	s0,32(sp)
    800055b6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055b8:	fe840613          	addi	a2,s0,-24
    800055bc:	4581                	li	a1,0
    800055be:	4501                	li	a0,0
    800055c0:	00000097          	auipc	ra,0x0
    800055c4:	d90080e7          	jalr	-624(ra) # 80005350 <argfd>
    return -1;
    800055c8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055ca:	04054163          	bltz	a0,8000560c <sys_read+0x5c>
    800055ce:	fe440593          	addi	a1,s0,-28
    800055d2:	4509                	li	a0,2
    800055d4:	ffffe097          	auipc	ra,0xffffe
    800055d8:	882080e7          	jalr	-1918(ra) # 80002e56 <argint>
    return -1;
    800055dc:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055de:	02054763          	bltz	a0,8000560c <sys_read+0x5c>
    800055e2:	fd840593          	addi	a1,s0,-40
    800055e6:	4505                	li	a0,1
    800055e8:	ffffe097          	auipc	ra,0xffffe
    800055ec:	890080e7          	jalr	-1904(ra) # 80002e78 <argaddr>
    return -1;
    800055f0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800055f2:	00054d63          	bltz	a0,8000560c <sys_read+0x5c>
  return fileread(f, p, n);
    800055f6:	fe442603          	lw	a2,-28(s0)
    800055fa:	fd843583          	ld	a1,-40(s0)
    800055fe:	fe843503          	ld	a0,-24(s0)
    80005602:	fffff097          	auipc	ra,0xfffff
    80005606:	49e080e7          	jalr	1182(ra) # 80004aa0 <fileread>
    8000560a:	87aa                	mv	a5,a0
}
    8000560c:	853e                	mv	a0,a5
    8000560e:	70a2                	ld	ra,40(sp)
    80005610:	7402                	ld	s0,32(sp)
    80005612:	6145                	addi	sp,sp,48
    80005614:	8082                	ret

0000000080005616 <sys_write>:
{
    80005616:	7179                	addi	sp,sp,-48
    80005618:	f406                	sd	ra,40(sp)
    8000561a:	f022                	sd	s0,32(sp)
    8000561c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000561e:	fe840613          	addi	a2,s0,-24
    80005622:	4581                	li	a1,0
    80005624:	4501                	li	a0,0
    80005626:	00000097          	auipc	ra,0x0
    8000562a:	d2a080e7          	jalr	-726(ra) # 80005350 <argfd>
    return -1;
    8000562e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005630:	04054163          	bltz	a0,80005672 <sys_write+0x5c>
    80005634:	fe440593          	addi	a1,s0,-28
    80005638:	4509                	li	a0,2
    8000563a:	ffffe097          	auipc	ra,0xffffe
    8000563e:	81c080e7          	jalr	-2020(ra) # 80002e56 <argint>
    return -1;
    80005642:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005644:	02054763          	bltz	a0,80005672 <sys_write+0x5c>
    80005648:	fd840593          	addi	a1,s0,-40
    8000564c:	4505                	li	a0,1
    8000564e:	ffffe097          	auipc	ra,0xffffe
    80005652:	82a080e7          	jalr	-2006(ra) # 80002e78 <argaddr>
    return -1;
    80005656:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005658:	00054d63          	bltz	a0,80005672 <sys_write+0x5c>
  return filewrite(f, p, n);
    8000565c:	fe442603          	lw	a2,-28(s0)
    80005660:	fd843583          	ld	a1,-40(s0)
    80005664:	fe843503          	ld	a0,-24(s0)
    80005668:	fffff097          	auipc	ra,0xfffff
    8000566c:	4fa080e7          	jalr	1274(ra) # 80004b62 <filewrite>
    80005670:	87aa                	mv	a5,a0
}
    80005672:	853e                	mv	a0,a5
    80005674:	70a2                	ld	ra,40(sp)
    80005676:	7402                	ld	s0,32(sp)
    80005678:	6145                	addi	sp,sp,48
    8000567a:	8082                	ret

000000008000567c <sys_close>:
{
    8000567c:	1101                	addi	sp,sp,-32
    8000567e:	ec06                	sd	ra,24(sp)
    80005680:	e822                	sd	s0,16(sp)
    80005682:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005684:	fe040613          	addi	a2,s0,-32
    80005688:	fec40593          	addi	a1,s0,-20
    8000568c:	4501                	li	a0,0
    8000568e:	00000097          	auipc	ra,0x0
    80005692:	cc2080e7          	jalr	-830(ra) # 80005350 <argfd>
    return -1;
    80005696:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005698:	02054463          	bltz	a0,800056c0 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000569c:	ffffc097          	auipc	ra,0xffffc
    800056a0:	3e6080e7          	jalr	998(ra) # 80001a82 <myproc>
    800056a4:	fec42783          	lw	a5,-20(s0)
    800056a8:	07e9                	addi	a5,a5,26
    800056aa:	078e                	slli	a5,a5,0x3
    800056ac:	97aa                	add	a5,a5,a0
    800056ae:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    800056b2:	fe043503          	ld	a0,-32(s0)
    800056b6:	fffff097          	auipc	ra,0xfffff
    800056ba:	2b0080e7          	jalr	688(ra) # 80004966 <fileclose>
  return 0;
    800056be:	4781                	li	a5,0
}
    800056c0:	853e                	mv	a0,a5
    800056c2:	60e2                	ld	ra,24(sp)
    800056c4:	6442                	ld	s0,16(sp)
    800056c6:	6105                	addi	sp,sp,32
    800056c8:	8082                	ret

00000000800056ca <sys_fstat>:
{
    800056ca:	1101                	addi	sp,sp,-32
    800056cc:	ec06                	sd	ra,24(sp)
    800056ce:	e822                	sd	s0,16(sp)
    800056d0:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800056d2:	fe840613          	addi	a2,s0,-24
    800056d6:	4581                	li	a1,0
    800056d8:	4501                	li	a0,0
    800056da:	00000097          	auipc	ra,0x0
    800056de:	c76080e7          	jalr	-906(ra) # 80005350 <argfd>
    return -1;
    800056e2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800056e4:	02054563          	bltz	a0,8000570e <sys_fstat+0x44>
    800056e8:	fe040593          	addi	a1,s0,-32
    800056ec:	4505                	li	a0,1
    800056ee:	ffffd097          	auipc	ra,0xffffd
    800056f2:	78a080e7          	jalr	1930(ra) # 80002e78 <argaddr>
    return -1;
    800056f6:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800056f8:	00054b63          	bltz	a0,8000570e <sys_fstat+0x44>
  return filestat(f, st);
    800056fc:	fe043583          	ld	a1,-32(s0)
    80005700:	fe843503          	ld	a0,-24(s0)
    80005704:	fffff097          	auipc	ra,0xfffff
    80005708:	32a080e7          	jalr	810(ra) # 80004a2e <filestat>
    8000570c:	87aa                	mv	a5,a0
}
    8000570e:	853e                	mv	a0,a5
    80005710:	60e2                	ld	ra,24(sp)
    80005712:	6442                	ld	s0,16(sp)
    80005714:	6105                	addi	sp,sp,32
    80005716:	8082                	ret

0000000080005718 <sys_link>:
{
    80005718:	7169                	addi	sp,sp,-304
    8000571a:	f606                	sd	ra,296(sp)
    8000571c:	f222                	sd	s0,288(sp)
    8000571e:	ee26                	sd	s1,280(sp)
    80005720:	ea4a                	sd	s2,272(sp)
    80005722:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005724:	08000613          	li	a2,128
    80005728:	ed040593          	addi	a1,s0,-304
    8000572c:	4501                	li	a0,0
    8000572e:	ffffd097          	auipc	ra,0xffffd
    80005732:	76c080e7          	jalr	1900(ra) # 80002e9a <argstr>
    return -1;
    80005736:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005738:	10054e63          	bltz	a0,80005854 <sys_link+0x13c>
    8000573c:	08000613          	li	a2,128
    80005740:	f5040593          	addi	a1,s0,-176
    80005744:	4505                	li	a0,1
    80005746:	ffffd097          	auipc	ra,0xffffd
    8000574a:	754080e7          	jalr	1876(ra) # 80002e9a <argstr>
    return -1;
    8000574e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005750:	10054263          	bltz	a0,80005854 <sys_link+0x13c>
  begin_op();
    80005754:	fffff097          	auipc	ra,0xfffff
    80005758:	d46080e7          	jalr	-698(ra) # 8000449a <begin_op>
  if((ip = namei(old)) == 0){
    8000575c:	ed040513          	addi	a0,s0,-304
    80005760:	fffff097          	auipc	ra,0xfffff
    80005764:	b1e080e7          	jalr	-1250(ra) # 8000427e <namei>
    80005768:	84aa                	mv	s1,a0
    8000576a:	c551                	beqz	a0,800057f6 <sys_link+0xde>
  ilock(ip);
    8000576c:	ffffe097          	auipc	ra,0xffffe
    80005770:	35c080e7          	jalr	860(ra) # 80003ac8 <ilock>
  if(ip->type == T_DIR){
    80005774:	04449703          	lh	a4,68(s1)
    80005778:	4785                	li	a5,1
    8000577a:	08f70463          	beq	a4,a5,80005802 <sys_link+0xea>
  ip->nlink++;
    8000577e:	04a4d783          	lhu	a5,74(s1)
    80005782:	2785                	addiw	a5,a5,1
    80005784:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005788:	8526                	mv	a0,s1
    8000578a:	ffffe097          	auipc	ra,0xffffe
    8000578e:	274080e7          	jalr	628(ra) # 800039fe <iupdate>
  iunlock(ip);
    80005792:	8526                	mv	a0,s1
    80005794:	ffffe097          	auipc	ra,0xffffe
    80005798:	3f6080e7          	jalr	1014(ra) # 80003b8a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000579c:	fd040593          	addi	a1,s0,-48
    800057a0:	f5040513          	addi	a0,s0,-176
    800057a4:	fffff097          	auipc	ra,0xfffff
    800057a8:	af8080e7          	jalr	-1288(ra) # 8000429c <nameiparent>
    800057ac:	892a                	mv	s2,a0
    800057ae:	c935                	beqz	a0,80005822 <sys_link+0x10a>
  ilock(dp);
    800057b0:	ffffe097          	auipc	ra,0xffffe
    800057b4:	318080e7          	jalr	792(ra) # 80003ac8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800057b8:	00092703          	lw	a4,0(s2)
    800057bc:	409c                	lw	a5,0(s1)
    800057be:	04f71d63          	bne	a4,a5,80005818 <sys_link+0x100>
    800057c2:	40d0                	lw	a2,4(s1)
    800057c4:	fd040593          	addi	a1,s0,-48
    800057c8:	854a                	mv	a0,s2
    800057ca:	fffff097          	auipc	ra,0xfffff
    800057ce:	9f2080e7          	jalr	-1550(ra) # 800041bc <dirlink>
    800057d2:	04054363          	bltz	a0,80005818 <sys_link+0x100>
  iunlockput(dp);
    800057d6:	854a                	mv	a0,s2
    800057d8:	ffffe097          	auipc	ra,0xffffe
    800057dc:	552080e7          	jalr	1362(ra) # 80003d2a <iunlockput>
  iput(ip);
    800057e0:	8526                	mv	a0,s1
    800057e2:	ffffe097          	auipc	ra,0xffffe
    800057e6:	4a0080e7          	jalr	1184(ra) # 80003c82 <iput>
  end_op();
    800057ea:	fffff097          	auipc	ra,0xfffff
    800057ee:	d30080e7          	jalr	-720(ra) # 8000451a <end_op>
  return 0;
    800057f2:	4781                	li	a5,0
    800057f4:	a085                	j	80005854 <sys_link+0x13c>
    end_op();
    800057f6:	fffff097          	auipc	ra,0xfffff
    800057fa:	d24080e7          	jalr	-732(ra) # 8000451a <end_op>
    return -1;
    800057fe:	57fd                	li	a5,-1
    80005800:	a891                	j	80005854 <sys_link+0x13c>
    iunlockput(ip);
    80005802:	8526                	mv	a0,s1
    80005804:	ffffe097          	auipc	ra,0xffffe
    80005808:	526080e7          	jalr	1318(ra) # 80003d2a <iunlockput>
    end_op();
    8000580c:	fffff097          	auipc	ra,0xfffff
    80005810:	d0e080e7          	jalr	-754(ra) # 8000451a <end_op>
    return -1;
    80005814:	57fd                	li	a5,-1
    80005816:	a83d                	j	80005854 <sys_link+0x13c>
    iunlockput(dp);
    80005818:	854a                	mv	a0,s2
    8000581a:	ffffe097          	auipc	ra,0xffffe
    8000581e:	510080e7          	jalr	1296(ra) # 80003d2a <iunlockput>
  ilock(ip);
    80005822:	8526                	mv	a0,s1
    80005824:	ffffe097          	auipc	ra,0xffffe
    80005828:	2a4080e7          	jalr	676(ra) # 80003ac8 <ilock>
  ip->nlink--;
    8000582c:	04a4d783          	lhu	a5,74(s1)
    80005830:	37fd                	addiw	a5,a5,-1
    80005832:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005836:	8526                	mv	a0,s1
    80005838:	ffffe097          	auipc	ra,0xffffe
    8000583c:	1c6080e7          	jalr	454(ra) # 800039fe <iupdate>
  iunlockput(ip);
    80005840:	8526                	mv	a0,s1
    80005842:	ffffe097          	auipc	ra,0xffffe
    80005846:	4e8080e7          	jalr	1256(ra) # 80003d2a <iunlockput>
  end_op();
    8000584a:	fffff097          	auipc	ra,0xfffff
    8000584e:	cd0080e7          	jalr	-816(ra) # 8000451a <end_op>
  return -1;
    80005852:	57fd                	li	a5,-1
}
    80005854:	853e                	mv	a0,a5
    80005856:	70b2                	ld	ra,296(sp)
    80005858:	7412                	ld	s0,288(sp)
    8000585a:	64f2                	ld	s1,280(sp)
    8000585c:	6952                	ld	s2,272(sp)
    8000585e:	6155                	addi	sp,sp,304
    80005860:	8082                	ret

0000000080005862 <sys_unlink>:
{
    80005862:	7151                	addi	sp,sp,-240
    80005864:	f586                	sd	ra,232(sp)
    80005866:	f1a2                	sd	s0,224(sp)
    80005868:	eda6                	sd	s1,216(sp)
    8000586a:	e9ca                	sd	s2,208(sp)
    8000586c:	e5ce                	sd	s3,200(sp)
    8000586e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005870:	08000613          	li	a2,128
    80005874:	f3040593          	addi	a1,s0,-208
    80005878:	4501                	li	a0,0
    8000587a:	ffffd097          	auipc	ra,0xffffd
    8000587e:	620080e7          	jalr	1568(ra) # 80002e9a <argstr>
    80005882:	18054163          	bltz	a0,80005a04 <sys_unlink+0x1a2>
  begin_op();
    80005886:	fffff097          	auipc	ra,0xfffff
    8000588a:	c14080e7          	jalr	-1004(ra) # 8000449a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000588e:	fb040593          	addi	a1,s0,-80
    80005892:	f3040513          	addi	a0,s0,-208
    80005896:	fffff097          	auipc	ra,0xfffff
    8000589a:	a06080e7          	jalr	-1530(ra) # 8000429c <nameiparent>
    8000589e:	84aa                	mv	s1,a0
    800058a0:	c979                	beqz	a0,80005976 <sys_unlink+0x114>
  ilock(dp);
    800058a2:	ffffe097          	auipc	ra,0xffffe
    800058a6:	226080e7          	jalr	550(ra) # 80003ac8 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800058aa:	00003597          	auipc	a1,0x3
    800058ae:	e3e58593          	addi	a1,a1,-450 # 800086e8 <syscalls+0x2b8>
    800058b2:	fb040513          	addi	a0,s0,-80
    800058b6:	ffffe097          	auipc	ra,0xffffe
    800058ba:	6dc080e7          	jalr	1756(ra) # 80003f92 <namecmp>
    800058be:	14050a63          	beqz	a0,80005a12 <sys_unlink+0x1b0>
    800058c2:	00003597          	auipc	a1,0x3
    800058c6:	e2e58593          	addi	a1,a1,-466 # 800086f0 <syscalls+0x2c0>
    800058ca:	fb040513          	addi	a0,s0,-80
    800058ce:	ffffe097          	auipc	ra,0xffffe
    800058d2:	6c4080e7          	jalr	1732(ra) # 80003f92 <namecmp>
    800058d6:	12050e63          	beqz	a0,80005a12 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800058da:	f2c40613          	addi	a2,s0,-212
    800058de:	fb040593          	addi	a1,s0,-80
    800058e2:	8526                	mv	a0,s1
    800058e4:	ffffe097          	auipc	ra,0xffffe
    800058e8:	6c8080e7          	jalr	1736(ra) # 80003fac <dirlookup>
    800058ec:	892a                	mv	s2,a0
    800058ee:	12050263          	beqz	a0,80005a12 <sys_unlink+0x1b0>
  ilock(ip);
    800058f2:	ffffe097          	auipc	ra,0xffffe
    800058f6:	1d6080e7          	jalr	470(ra) # 80003ac8 <ilock>
  if(ip->nlink < 1)
    800058fa:	04a91783          	lh	a5,74(s2)
    800058fe:	08f05263          	blez	a5,80005982 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005902:	04491703          	lh	a4,68(s2)
    80005906:	4785                	li	a5,1
    80005908:	08f70563          	beq	a4,a5,80005992 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    8000590c:	4641                	li	a2,16
    8000590e:	4581                	li	a1,0
    80005910:	fc040513          	addi	a0,s0,-64
    80005914:	ffffb097          	auipc	ra,0xffffb
    80005918:	3ba080e7          	jalr	954(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000591c:	4741                	li	a4,16
    8000591e:	f2c42683          	lw	a3,-212(s0)
    80005922:	fc040613          	addi	a2,s0,-64
    80005926:	4581                	li	a1,0
    80005928:	8526                	mv	a0,s1
    8000592a:	ffffe097          	auipc	ra,0xffffe
    8000592e:	54a080e7          	jalr	1354(ra) # 80003e74 <writei>
    80005932:	47c1                	li	a5,16
    80005934:	0af51563          	bne	a0,a5,800059de <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005938:	04491703          	lh	a4,68(s2)
    8000593c:	4785                	li	a5,1
    8000593e:	0af70863          	beq	a4,a5,800059ee <sys_unlink+0x18c>
  iunlockput(dp);
    80005942:	8526                	mv	a0,s1
    80005944:	ffffe097          	auipc	ra,0xffffe
    80005948:	3e6080e7          	jalr	998(ra) # 80003d2a <iunlockput>
  ip->nlink--;
    8000594c:	04a95783          	lhu	a5,74(s2)
    80005950:	37fd                	addiw	a5,a5,-1
    80005952:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005956:	854a                	mv	a0,s2
    80005958:	ffffe097          	auipc	ra,0xffffe
    8000595c:	0a6080e7          	jalr	166(ra) # 800039fe <iupdate>
  iunlockput(ip);
    80005960:	854a                	mv	a0,s2
    80005962:	ffffe097          	auipc	ra,0xffffe
    80005966:	3c8080e7          	jalr	968(ra) # 80003d2a <iunlockput>
  end_op();
    8000596a:	fffff097          	auipc	ra,0xfffff
    8000596e:	bb0080e7          	jalr	-1104(ra) # 8000451a <end_op>
  return 0;
    80005972:	4501                	li	a0,0
    80005974:	a84d                	j	80005a26 <sys_unlink+0x1c4>
    end_op();
    80005976:	fffff097          	auipc	ra,0xfffff
    8000597a:	ba4080e7          	jalr	-1116(ra) # 8000451a <end_op>
    return -1;
    8000597e:	557d                	li	a0,-1
    80005980:	a05d                	j	80005a26 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005982:	00003517          	auipc	a0,0x3
    80005986:	d9650513          	addi	a0,a0,-618 # 80008718 <syscalls+0x2e8>
    8000598a:	ffffb097          	auipc	ra,0xffffb
    8000598e:	ba6080e7          	jalr	-1114(ra) # 80000530 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005992:	04c92703          	lw	a4,76(s2)
    80005996:	02000793          	li	a5,32
    8000599a:	f6e7f9e3          	bgeu	a5,a4,8000590c <sys_unlink+0xaa>
    8000599e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059a2:	4741                	li	a4,16
    800059a4:	86ce                	mv	a3,s3
    800059a6:	f1840613          	addi	a2,s0,-232
    800059aa:	4581                	li	a1,0
    800059ac:	854a                	mv	a0,s2
    800059ae:	ffffe097          	auipc	ra,0xffffe
    800059b2:	3ce080e7          	jalr	974(ra) # 80003d7c <readi>
    800059b6:	47c1                	li	a5,16
    800059b8:	00f51b63          	bne	a0,a5,800059ce <sys_unlink+0x16c>
    if(de.inum != 0)
    800059bc:	f1845783          	lhu	a5,-232(s0)
    800059c0:	e7a1                	bnez	a5,80005a08 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800059c2:	29c1                	addiw	s3,s3,16
    800059c4:	04c92783          	lw	a5,76(s2)
    800059c8:	fcf9ede3          	bltu	s3,a5,800059a2 <sys_unlink+0x140>
    800059cc:	b781                	j	8000590c <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800059ce:	00003517          	auipc	a0,0x3
    800059d2:	d6250513          	addi	a0,a0,-670 # 80008730 <syscalls+0x300>
    800059d6:	ffffb097          	auipc	ra,0xffffb
    800059da:	b5a080e7          	jalr	-1190(ra) # 80000530 <panic>
    panic("unlink: writei");
    800059de:	00003517          	auipc	a0,0x3
    800059e2:	d6a50513          	addi	a0,a0,-662 # 80008748 <syscalls+0x318>
    800059e6:	ffffb097          	auipc	ra,0xffffb
    800059ea:	b4a080e7          	jalr	-1206(ra) # 80000530 <panic>
    dp->nlink--;
    800059ee:	04a4d783          	lhu	a5,74(s1)
    800059f2:	37fd                	addiw	a5,a5,-1
    800059f4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800059f8:	8526                	mv	a0,s1
    800059fa:	ffffe097          	auipc	ra,0xffffe
    800059fe:	004080e7          	jalr	4(ra) # 800039fe <iupdate>
    80005a02:	b781                	j	80005942 <sys_unlink+0xe0>
    return -1;
    80005a04:	557d                	li	a0,-1
    80005a06:	a005                	j	80005a26 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005a08:	854a                	mv	a0,s2
    80005a0a:	ffffe097          	auipc	ra,0xffffe
    80005a0e:	320080e7          	jalr	800(ra) # 80003d2a <iunlockput>
  iunlockput(dp);
    80005a12:	8526                	mv	a0,s1
    80005a14:	ffffe097          	auipc	ra,0xffffe
    80005a18:	316080e7          	jalr	790(ra) # 80003d2a <iunlockput>
  end_op();
    80005a1c:	fffff097          	auipc	ra,0xfffff
    80005a20:	afe080e7          	jalr	-1282(ra) # 8000451a <end_op>
  return -1;
    80005a24:	557d                	li	a0,-1
}
    80005a26:	70ae                	ld	ra,232(sp)
    80005a28:	740e                	ld	s0,224(sp)
    80005a2a:	64ee                	ld	s1,216(sp)
    80005a2c:	694e                	ld	s2,208(sp)
    80005a2e:	69ae                	ld	s3,200(sp)
    80005a30:	616d                	addi	sp,sp,240
    80005a32:	8082                	ret

0000000080005a34 <sys_open>:

uint64
sys_open(void)
{
    80005a34:	7131                	addi	sp,sp,-192
    80005a36:	fd06                	sd	ra,184(sp)
    80005a38:	f922                	sd	s0,176(sp)
    80005a3a:	f526                	sd	s1,168(sp)
    80005a3c:	f14a                	sd	s2,160(sp)
    80005a3e:	ed4e                	sd	s3,152(sp)
    80005a40:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005a42:	08000613          	li	a2,128
    80005a46:	f5040593          	addi	a1,s0,-176
    80005a4a:	4501                	li	a0,0
    80005a4c:	ffffd097          	auipc	ra,0xffffd
    80005a50:	44e080e7          	jalr	1102(ra) # 80002e9a <argstr>
    return -1;
    80005a54:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80005a56:	0c054163          	bltz	a0,80005b18 <sys_open+0xe4>
    80005a5a:	f4c40593          	addi	a1,s0,-180
    80005a5e:	4505                	li	a0,1
    80005a60:	ffffd097          	auipc	ra,0xffffd
    80005a64:	3f6080e7          	jalr	1014(ra) # 80002e56 <argint>
    80005a68:	0a054863          	bltz	a0,80005b18 <sys_open+0xe4>

  begin_op();
    80005a6c:	fffff097          	auipc	ra,0xfffff
    80005a70:	a2e080e7          	jalr	-1490(ra) # 8000449a <begin_op>

  if(omode & O_CREATE){
    80005a74:	f4c42783          	lw	a5,-180(s0)
    80005a78:	2007f793          	andi	a5,a5,512
    80005a7c:	cbdd                	beqz	a5,80005b32 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005a7e:	4681                	li	a3,0
    80005a80:	4601                	li	a2,0
    80005a82:	4589                	li	a1,2
    80005a84:	f5040513          	addi	a0,s0,-176
    80005a88:	00000097          	auipc	ra,0x0
    80005a8c:	972080e7          	jalr	-1678(ra) # 800053fa <create>
    80005a90:	892a                	mv	s2,a0
    if(ip == 0){
    80005a92:	c959                	beqz	a0,80005b28 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005a94:	04491703          	lh	a4,68(s2)
    80005a98:	478d                	li	a5,3
    80005a9a:	00f71763          	bne	a4,a5,80005aa8 <sys_open+0x74>
    80005a9e:	04695703          	lhu	a4,70(s2)
    80005aa2:	47a5                	li	a5,9
    80005aa4:	0ce7ec63          	bltu	a5,a4,80005b7c <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005aa8:	fffff097          	auipc	ra,0xfffff
    80005aac:	e02080e7          	jalr	-510(ra) # 800048aa <filealloc>
    80005ab0:	89aa                	mv	s3,a0
    80005ab2:	10050263          	beqz	a0,80005bb6 <sys_open+0x182>
    80005ab6:	00000097          	auipc	ra,0x0
    80005aba:	902080e7          	jalr	-1790(ra) # 800053b8 <fdalloc>
    80005abe:	84aa                	mv	s1,a0
    80005ac0:	0e054663          	bltz	a0,80005bac <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005ac4:	04491703          	lh	a4,68(s2)
    80005ac8:	478d                	li	a5,3
    80005aca:	0cf70463          	beq	a4,a5,80005b92 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005ace:	4789                	li	a5,2
    80005ad0:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005ad4:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005ad8:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005adc:	f4c42783          	lw	a5,-180(s0)
    80005ae0:	0017c713          	xori	a4,a5,1
    80005ae4:	8b05                	andi	a4,a4,1
    80005ae6:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005aea:	0037f713          	andi	a4,a5,3
    80005aee:	00e03733          	snez	a4,a4
    80005af2:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005af6:	4007f793          	andi	a5,a5,1024
    80005afa:	c791                	beqz	a5,80005b06 <sys_open+0xd2>
    80005afc:	04491703          	lh	a4,68(s2)
    80005b00:	4789                	li	a5,2
    80005b02:	08f70f63          	beq	a4,a5,80005ba0 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005b06:	854a                	mv	a0,s2
    80005b08:	ffffe097          	auipc	ra,0xffffe
    80005b0c:	082080e7          	jalr	130(ra) # 80003b8a <iunlock>
  end_op();
    80005b10:	fffff097          	auipc	ra,0xfffff
    80005b14:	a0a080e7          	jalr	-1526(ra) # 8000451a <end_op>

  return fd;
}
    80005b18:	8526                	mv	a0,s1
    80005b1a:	70ea                	ld	ra,184(sp)
    80005b1c:	744a                	ld	s0,176(sp)
    80005b1e:	74aa                	ld	s1,168(sp)
    80005b20:	790a                	ld	s2,160(sp)
    80005b22:	69ea                	ld	s3,152(sp)
    80005b24:	6129                	addi	sp,sp,192
    80005b26:	8082                	ret
      end_op();
    80005b28:	fffff097          	auipc	ra,0xfffff
    80005b2c:	9f2080e7          	jalr	-1550(ra) # 8000451a <end_op>
      return -1;
    80005b30:	b7e5                	j	80005b18 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005b32:	f5040513          	addi	a0,s0,-176
    80005b36:	ffffe097          	auipc	ra,0xffffe
    80005b3a:	748080e7          	jalr	1864(ra) # 8000427e <namei>
    80005b3e:	892a                	mv	s2,a0
    80005b40:	c905                	beqz	a0,80005b70 <sys_open+0x13c>
    ilock(ip);
    80005b42:	ffffe097          	auipc	ra,0xffffe
    80005b46:	f86080e7          	jalr	-122(ra) # 80003ac8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005b4a:	04491703          	lh	a4,68(s2)
    80005b4e:	4785                	li	a5,1
    80005b50:	f4f712e3          	bne	a4,a5,80005a94 <sys_open+0x60>
    80005b54:	f4c42783          	lw	a5,-180(s0)
    80005b58:	dba1                	beqz	a5,80005aa8 <sys_open+0x74>
      iunlockput(ip);
    80005b5a:	854a                	mv	a0,s2
    80005b5c:	ffffe097          	auipc	ra,0xffffe
    80005b60:	1ce080e7          	jalr	462(ra) # 80003d2a <iunlockput>
      end_op();
    80005b64:	fffff097          	auipc	ra,0xfffff
    80005b68:	9b6080e7          	jalr	-1610(ra) # 8000451a <end_op>
      return -1;
    80005b6c:	54fd                	li	s1,-1
    80005b6e:	b76d                	j	80005b18 <sys_open+0xe4>
      end_op();
    80005b70:	fffff097          	auipc	ra,0xfffff
    80005b74:	9aa080e7          	jalr	-1622(ra) # 8000451a <end_op>
      return -1;
    80005b78:	54fd                	li	s1,-1
    80005b7a:	bf79                	j	80005b18 <sys_open+0xe4>
    iunlockput(ip);
    80005b7c:	854a                	mv	a0,s2
    80005b7e:	ffffe097          	auipc	ra,0xffffe
    80005b82:	1ac080e7          	jalr	428(ra) # 80003d2a <iunlockput>
    end_op();
    80005b86:	fffff097          	auipc	ra,0xfffff
    80005b8a:	994080e7          	jalr	-1644(ra) # 8000451a <end_op>
    return -1;
    80005b8e:	54fd                	li	s1,-1
    80005b90:	b761                	j	80005b18 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005b92:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005b96:	04691783          	lh	a5,70(s2)
    80005b9a:	02f99223          	sh	a5,36(s3)
    80005b9e:	bf2d                	j	80005ad8 <sys_open+0xa4>
    itrunc(ip);
    80005ba0:	854a                	mv	a0,s2
    80005ba2:	ffffe097          	auipc	ra,0xffffe
    80005ba6:	034080e7          	jalr	52(ra) # 80003bd6 <itrunc>
    80005baa:	bfb1                	j	80005b06 <sys_open+0xd2>
      fileclose(f);
    80005bac:	854e                	mv	a0,s3
    80005bae:	fffff097          	auipc	ra,0xfffff
    80005bb2:	db8080e7          	jalr	-584(ra) # 80004966 <fileclose>
    iunlockput(ip);
    80005bb6:	854a                	mv	a0,s2
    80005bb8:	ffffe097          	auipc	ra,0xffffe
    80005bbc:	172080e7          	jalr	370(ra) # 80003d2a <iunlockput>
    end_op();
    80005bc0:	fffff097          	auipc	ra,0xfffff
    80005bc4:	95a080e7          	jalr	-1702(ra) # 8000451a <end_op>
    return -1;
    80005bc8:	54fd                	li	s1,-1
    80005bca:	b7b9                	j	80005b18 <sys_open+0xe4>

0000000080005bcc <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005bcc:	7175                	addi	sp,sp,-144
    80005bce:	e506                	sd	ra,136(sp)
    80005bd0:	e122                	sd	s0,128(sp)
    80005bd2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005bd4:	fffff097          	auipc	ra,0xfffff
    80005bd8:	8c6080e7          	jalr	-1850(ra) # 8000449a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005bdc:	08000613          	li	a2,128
    80005be0:	f7040593          	addi	a1,s0,-144
    80005be4:	4501                	li	a0,0
    80005be6:	ffffd097          	auipc	ra,0xffffd
    80005bea:	2b4080e7          	jalr	692(ra) # 80002e9a <argstr>
    80005bee:	02054963          	bltz	a0,80005c20 <sys_mkdir+0x54>
    80005bf2:	4681                	li	a3,0
    80005bf4:	4601                	li	a2,0
    80005bf6:	4585                	li	a1,1
    80005bf8:	f7040513          	addi	a0,s0,-144
    80005bfc:	fffff097          	auipc	ra,0xfffff
    80005c00:	7fe080e7          	jalr	2046(ra) # 800053fa <create>
    80005c04:	cd11                	beqz	a0,80005c20 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c06:	ffffe097          	auipc	ra,0xffffe
    80005c0a:	124080e7          	jalr	292(ra) # 80003d2a <iunlockput>
  end_op();
    80005c0e:	fffff097          	auipc	ra,0xfffff
    80005c12:	90c080e7          	jalr	-1780(ra) # 8000451a <end_op>
  return 0;
    80005c16:	4501                	li	a0,0
}
    80005c18:	60aa                	ld	ra,136(sp)
    80005c1a:	640a                	ld	s0,128(sp)
    80005c1c:	6149                	addi	sp,sp,144
    80005c1e:	8082                	ret
    end_op();
    80005c20:	fffff097          	auipc	ra,0xfffff
    80005c24:	8fa080e7          	jalr	-1798(ra) # 8000451a <end_op>
    return -1;
    80005c28:	557d                	li	a0,-1
    80005c2a:	b7fd                	j	80005c18 <sys_mkdir+0x4c>

0000000080005c2c <sys_mknod>:

uint64
sys_mknod(void)
{
    80005c2c:	7135                	addi	sp,sp,-160
    80005c2e:	ed06                	sd	ra,152(sp)
    80005c30:	e922                	sd	s0,144(sp)
    80005c32:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005c34:	fffff097          	auipc	ra,0xfffff
    80005c38:	866080e7          	jalr	-1946(ra) # 8000449a <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c3c:	08000613          	li	a2,128
    80005c40:	f7040593          	addi	a1,s0,-144
    80005c44:	4501                	li	a0,0
    80005c46:	ffffd097          	auipc	ra,0xffffd
    80005c4a:	254080e7          	jalr	596(ra) # 80002e9a <argstr>
    80005c4e:	04054a63          	bltz	a0,80005ca2 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80005c52:	f6c40593          	addi	a1,s0,-148
    80005c56:	4505                	li	a0,1
    80005c58:	ffffd097          	auipc	ra,0xffffd
    80005c5c:	1fe080e7          	jalr	510(ra) # 80002e56 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005c60:	04054163          	bltz	a0,80005ca2 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80005c64:	f6840593          	addi	a1,s0,-152
    80005c68:	4509                	li	a0,2
    80005c6a:	ffffd097          	auipc	ra,0xffffd
    80005c6e:	1ec080e7          	jalr	492(ra) # 80002e56 <argint>
     argint(1, &major) < 0 ||
    80005c72:	02054863          	bltz	a0,80005ca2 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005c76:	f6841683          	lh	a3,-152(s0)
    80005c7a:	f6c41603          	lh	a2,-148(s0)
    80005c7e:	458d                	li	a1,3
    80005c80:	f7040513          	addi	a0,s0,-144
    80005c84:	fffff097          	auipc	ra,0xfffff
    80005c88:	776080e7          	jalr	1910(ra) # 800053fa <create>
     argint(2, &minor) < 0 ||
    80005c8c:	c919                	beqz	a0,80005ca2 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005c8e:	ffffe097          	auipc	ra,0xffffe
    80005c92:	09c080e7          	jalr	156(ra) # 80003d2a <iunlockput>
  end_op();
    80005c96:	fffff097          	auipc	ra,0xfffff
    80005c9a:	884080e7          	jalr	-1916(ra) # 8000451a <end_op>
  return 0;
    80005c9e:	4501                	li	a0,0
    80005ca0:	a031                	j	80005cac <sys_mknod+0x80>
    end_op();
    80005ca2:	fffff097          	auipc	ra,0xfffff
    80005ca6:	878080e7          	jalr	-1928(ra) # 8000451a <end_op>
    return -1;
    80005caa:	557d                	li	a0,-1
}
    80005cac:	60ea                	ld	ra,152(sp)
    80005cae:	644a                	ld	s0,144(sp)
    80005cb0:	610d                	addi	sp,sp,160
    80005cb2:	8082                	ret

0000000080005cb4 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005cb4:	7135                	addi	sp,sp,-160
    80005cb6:	ed06                	sd	ra,152(sp)
    80005cb8:	e922                	sd	s0,144(sp)
    80005cba:	e526                	sd	s1,136(sp)
    80005cbc:	e14a                	sd	s2,128(sp)
    80005cbe:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005cc0:	ffffc097          	auipc	ra,0xffffc
    80005cc4:	dc2080e7          	jalr	-574(ra) # 80001a82 <myproc>
    80005cc8:	892a                	mv	s2,a0
  
  begin_op();
    80005cca:	ffffe097          	auipc	ra,0xffffe
    80005cce:	7d0080e7          	jalr	2000(ra) # 8000449a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005cd2:	08000613          	li	a2,128
    80005cd6:	f6040593          	addi	a1,s0,-160
    80005cda:	4501                	li	a0,0
    80005cdc:	ffffd097          	auipc	ra,0xffffd
    80005ce0:	1be080e7          	jalr	446(ra) # 80002e9a <argstr>
    80005ce4:	04054b63          	bltz	a0,80005d3a <sys_chdir+0x86>
    80005ce8:	f6040513          	addi	a0,s0,-160
    80005cec:	ffffe097          	auipc	ra,0xffffe
    80005cf0:	592080e7          	jalr	1426(ra) # 8000427e <namei>
    80005cf4:	84aa                	mv	s1,a0
    80005cf6:	c131                	beqz	a0,80005d3a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005cf8:	ffffe097          	auipc	ra,0xffffe
    80005cfc:	dd0080e7          	jalr	-560(ra) # 80003ac8 <ilock>
  if(ip->type != T_DIR){
    80005d00:	04449703          	lh	a4,68(s1)
    80005d04:	4785                	li	a5,1
    80005d06:	04f71063          	bne	a4,a5,80005d46 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005d0a:	8526                	mv	a0,s1
    80005d0c:	ffffe097          	auipc	ra,0xffffe
    80005d10:	e7e080e7          	jalr	-386(ra) # 80003b8a <iunlock>
  iput(p->cwd);
    80005d14:	15093503          	ld	a0,336(s2)
    80005d18:	ffffe097          	auipc	ra,0xffffe
    80005d1c:	f6a080e7          	jalr	-150(ra) # 80003c82 <iput>
  end_op();
    80005d20:	ffffe097          	auipc	ra,0xffffe
    80005d24:	7fa080e7          	jalr	2042(ra) # 8000451a <end_op>
  p->cwd = ip;
    80005d28:	14993823          	sd	s1,336(s2)
  return 0;
    80005d2c:	4501                	li	a0,0
}
    80005d2e:	60ea                	ld	ra,152(sp)
    80005d30:	644a                	ld	s0,144(sp)
    80005d32:	64aa                	ld	s1,136(sp)
    80005d34:	690a                	ld	s2,128(sp)
    80005d36:	610d                	addi	sp,sp,160
    80005d38:	8082                	ret
    end_op();
    80005d3a:	ffffe097          	auipc	ra,0xffffe
    80005d3e:	7e0080e7          	jalr	2016(ra) # 8000451a <end_op>
    return -1;
    80005d42:	557d                	li	a0,-1
    80005d44:	b7ed                	j	80005d2e <sys_chdir+0x7a>
    iunlockput(ip);
    80005d46:	8526                	mv	a0,s1
    80005d48:	ffffe097          	auipc	ra,0xffffe
    80005d4c:	fe2080e7          	jalr	-30(ra) # 80003d2a <iunlockput>
    end_op();
    80005d50:	ffffe097          	auipc	ra,0xffffe
    80005d54:	7ca080e7          	jalr	1994(ra) # 8000451a <end_op>
    return -1;
    80005d58:	557d                	li	a0,-1
    80005d5a:	bfd1                	j	80005d2e <sys_chdir+0x7a>

0000000080005d5c <sys_exec>:

uint64
sys_exec(void)
{
    80005d5c:	7145                	addi	sp,sp,-464
    80005d5e:	e786                	sd	ra,456(sp)
    80005d60:	e3a2                	sd	s0,448(sp)
    80005d62:	ff26                	sd	s1,440(sp)
    80005d64:	fb4a                	sd	s2,432(sp)
    80005d66:	f74e                	sd	s3,424(sp)
    80005d68:	f352                	sd	s4,416(sp)
    80005d6a:	ef56                	sd	s5,408(sp)
    80005d6c:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005d6e:	08000613          	li	a2,128
    80005d72:	f4040593          	addi	a1,s0,-192
    80005d76:	4501                	li	a0,0
    80005d78:	ffffd097          	auipc	ra,0xffffd
    80005d7c:	122080e7          	jalr	290(ra) # 80002e9a <argstr>
    return -1;
    80005d80:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005d82:	0c054a63          	bltz	a0,80005e56 <sys_exec+0xfa>
    80005d86:	e3840593          	addi	a1,s0,-456
    80005d8a:	4505                	li	a0,1
    80005d8c:	ffffd097          	auipc	ra,0xffffd
    80005d90:	0ec080e7          	jalr	236(ra) # 80002e78 <argaddr>
    80005d94:	0c054163          	bltz	a0,80005e56 <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    80005d98:	10000613          	li	a2,256
    80005d9c:	4581                	li	a1,0
    80005d9e:	e4040513          	addi	a0,s0,-448
    80005da2:	ffffb097          	auipc	ra,0xffffb
    80005da6:	f2c080e7          	jalr	-212(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005daa:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005dae:	89a6                	mv	s3,s1
    80005db0:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005db2:	02000a13          	li	s4,32
    80005db6:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005dba:	00391513          	slli	a0,s2,0x3
    80005dbe:	e3040593          	addi	a1,s0,-464
    80005dc2:	e3843783          	ld	a5,-456(s0)
    80005dc6:	953e                	add	a0,a0,a5
    80005dc8:	ffffd097          	auipc	ra,0xffffd
    80005dcc:	ff4080e7          	jalr	-12(ra) # 80002dbc <fetchaddr>
    80005dd0:	02054a63          	bltz	a0,80005e04 <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005dd4:	e3043783          	ld	a5,-464(s0)
    80005dd8:	c3b9                	beqz	a5,80005e1e <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005dda:	ffffb097          	auipc	ra,0xffffb
    80005dde:	d08080e7          	jalr	-760(ra) # 80000ae2 <kalloc>
    80005de2:	85aa                	mv	a1,a0
    80005de4:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005de8:	cd11                	beqz	a0,80005e04 <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005dea:	6605                	lui	a2,0x1
    80005dec:	e3043503          	ld	a0,-464(s0)
    80005df0:	ffffd097          	auipc	ra,0xffffd
    80005df4:	01e080e7          	jalr	30(ra) # 80002e0e <fetchstr>
    80005df8:	00054663          	bltz	a0,80005e04 <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005dfc:	0905                	addi	s2,s2,1
    80005dfe:	09a1                	addi	s3,s3,8
    80005e00:	fb491be3          	bne	s2,s4,80005db6 <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e04:	10048913          	addi	s2,s1,256
    80005e08:	6088                	ld	a0,0(s1)
    80005e0a:	c529                	beqz	a0,80005e54 <sys_exec+0xf8>
    kfree(argv[i]);
    80005e0c:	ffffb097          	auipc	ra,0xffffb
    80005e10:	bda080e7          	jalr	-1062(ra) # 800009e6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e14:	04a1                	addi	s1,s1,8
    80005e16:	ff2499e3          	bne	s1,s2,80005e08 <sys_exec+0xac>
  return -1;
    80005e1a:	597d                	li	s2,-1
    80005e1c:	a82d                	j	80005e56 <sys_exec+0xfa>
      argv[i] = 0;
    80005e1e:	0a8e                	slli	s5,s5,0x3
    80005e20:	fc040793          	addi	a5,s0,-64
    80005e24:	9abe                	add	s5,s5,a5
    80005e26:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005e2a:	e4040593          	addi	a1,s0,-448
    80005e2e:	f4040513          	addi	a0,s0,-192
    80005e32:	fffff097          	auipc	ra,0xfffff
    80005e36:	194080e7          	jalr	404(ra) # 80004fc6 <exec>
    80005e3a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e3c:	10048993          	addi	s3,s1,256
    80005e40:	6088                	ld	a0,0(s1)
    80005e42:	c911                	beqz	a0,80005e56 <sys_exec+0xfa>
    kfree(argv[i]);
    80005e44:	ffffb097          	auipc	ra,0xffffb
    80005e48:	ba2080e7          	jalr	-1118(ra) # 800009e6 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005e4c:	04a1                	addi	s1,s1,8
    80005e4e:	ff3499e3          	bne	s1,s3,80005e40 <sys_exec+0xe4>
    80005e52:	a011                	j	80005e56 <sys_exec+0xfa>
  return -1;
    80005e54:	597d                	li	s2,-1
}
    80005e56:	854a                	mv	a0,s2
    80005e58:	60be                	ld	ra,456(sp)
    80005e5a:	641e                	ld	s0,448(sp)
    80005e5c:	74fa                	ld	s1,440(sp)
    80005e5e:	795a                	ld	s2,432(sp)
    80005e60:	79ba                	ld	s3,424(sp)
    80005e62:	7a1a                	ld	s4,416(sp)
    80005e64:	6afa                	ld	s5,408(sp)
    80005e66:	6179                	addi	sp,sp,464
    80005e68:	8082                	ret

0000000080005e6a <sys_pipe>:

uint64
sys_pipe(void)
{
    80005e6a:	7139                	addi	sp,sp,-64
    80005e6c:	fc06                	sd	ra,56(sp)
    80005e6e:	f822                	sd	s0,48(sp)
    80005e70:	f426                	sd	s1,40(sp)
    80005e72:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005e74:	ffffc097          	auipc	ra,0xffffc
    80005e78:	c0e080e7          	jalr	-1010(ra) # 80001a82 <myproc>
    80005e7c:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005e7e:	fd840593          	addi	a1,s0,-40
    80005e82:	4501                	li	a0,0
    80005e84:	ffffd097          	auipc	ra,0xffffd
    80005e88:	ff4080e7          	jalr	-12(ra) # 80002e78 <argaddr>
    return -1;
    80005e8c:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005e8e:	0e054063          	bltz	a0,80005f6e <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005e92:	fc840593          	addi	a1,s0,-56
    80005e96:	fd040513          	addi	a0,s0,-48
    80005e9a:	fffff097          	auipc	ra,0xfffff
    80005e9e:	dfc080e7          	jalr	-516(ra) # 80004c96 <pipealloc>
    return -1;
    80005ea2:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005ea4:	0c054563          	bltz	a0,80005f6e <sys_pipe+0x104>
  fd0 = -1;
    80005ea8:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005eac:	fd043503          	ld	a0,-48(s0)
    80005eb0:	fffff097          	auipc	ra,0xfffff
    80005eb4:	508080e7          	jalr	1288(ra) # 800053b8 <fdalloc>
    80005eb8:	fca42223          	sw	a0,-60(s0)
    80005ebc:	08054c63          	bltz	a0,80005f54 <sys_pipe+0xea>
    80005ec0:	fc843503          	ld	a0,-56(s0)
    80005ec4:	fffff097          	auipc	ra,0xfffff
    80005ec8:	4f4080e7          	jalr	1268(ra) # 800053b8 <fdalloc>
    80005ecc:	fca42023          	sw	a0,-64(s0)
    80005ed0:	06054863          	bltz	a0,80005f40 <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ed4:	4691                	li	a3,4
    80005ed6:	fc440613          	addi	a2,s0,-60
    80005eda:	fd843583          	ld	a1,-40(s0)
    80005ede:	68a8                	ld	a0,80(s1)
    80005ee0:	ffffb097          	auipc	ra,0xffffb
    80005ee4:	772080e7          	jalr	1906(ra) # 80001652 <copyout>
    80005ee8:	02054063          	bltz	a0,80005f08 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005eec:	4691                	li	a3,4
    80005eee:	fc040613          	addi	a2,s0,-64
    80005ef2:	fd843583          	ld	a1,-40(s0)
    80005ef6:	0591                	addi	a1,a1,4
    80005ef8:	68a8                	ld	a0,80(s1)
    80005efa:	ffffb097          	auipc	ra,0xffffb
    80005efe:	758080e7          	jalr	1880(ra) # 80001652 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005f02:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f04:	06055563          	bgez	a0,80005f6e <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005f08:	fc442783          	lw	a5,-60(s0)
    80005f0c:	07e9                	addi	a5,a5,26
    80005f0e:	078e                	slli	a5,a5,0x3
    80005f10:	97a6                	add	a5,a5,s1
    80005f12:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005f16:	fc042503          	lw	a0,-64(s0)
    80005f1a:	0569                	addi	a0,a0,26
    80005f1c:	050e                	slli	a0,a0,0x3
    80005f1e:	9526                	add	a0,a0,s1
    80005f20:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005f24:	fd043503          	ld	a0,-48(s0)
    80005f28:	fffff097          	auipc	ra,0xfffff
    80005f2c:	a3e080e7          	jalr	-1474(ra) # 80004966 <fileclose>
    fileclose(wf);
    80005f30:	fc843503          	ld	a0,-56(s0)
    80005f34:	fffff097          	auipc	ra,0xfffff
    80005f38:	a32080e7          	jalr	-1486(ra) # 80004966 <fileclose>
    return -1;
    80005f3c:	57fd                	li	a5,-1
    80005f3e:	a805                	j	80005f6e <sys_pipe+0x104>
    if(fd0 >= 0)
    80005f40:	fc442783          	lw	a5,-60(s0)
    80005f44:	0007c863          	bltz	a5,80005f54 <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005f48:	01a78513          	addi	a0,a5,26
    80005f4c:	050e                	slli	a0,a0,0x3
    80005f4e:	9526                	add	a0,a0,s1
    80005f50:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005f54:	fd043503          	ld	a0,-48(s0)
    80005f58:	fffff097          	auipc	ra,0xfffff
    80005f5c:	a0e080e7          	jalr	-1522(ra) # 80004966 <fileclose>
    fileclose(wf);
    80005f60:	fc843503          	ld	a0,-56(s0)
    80005f64:	fffff097          	auipc	ra,0xfffff
    80005f68:	a02080e7          	jalr	-1534(ra) # 80004966 <fileclose>
    return -1;
    80005f6c:	57fd                	li	a5,-1
}
    80005f6e:	853e                	mv	a0,a5
    80005f70:	70e2                	ld	ra,56(sp)
    80005f72:	7442                	ld	s0,48(sp)
    80005f74:	74a2                	ld	s1,40(sp)
    80005f76:	6121                	addi	sp,sp,64
    80005f78:	8082                	ret
    80005f7a:	0000                	unimp
    80005f7c:	0000                	unimp
	...

0000000080005f80 <kernelvec>:
    80005f80:	7111                	addi	sp,sp,-256
    80005f82:	e006                	sd	ra,0(sp)
    80005f84:	e40a                	sd	sp,8(sp)
    80005f86:	e80e                	sd	gp,16(sp)
    80005f88:	ec12                	sd	tp,24(sp)
    80005f8a:	f016                	sd	t0,32(sp)
    80005f8c:	f41a                	sd	t1,40(sp)
    80005f8e:	f81e                	sd	t2,48(sp)
    80005f90:	fc22                	sd	s0,56(sp)
    80005f92:	e0a6                	sd	s1,64(sp)
    80005f94:	e4aa                	sd	a0,72(sp)
    80005f96:	e8ae                	sd	a1,80(sp)
    80005f98:	ecb2                	sd	a2,88(sp)
    80005f9a:	f0b6                	sd	a3,96(sp)
    80005f9c:	f4ba                	sd	a4,104(sp)
    80005f9e:	f8be                	sd	a5,112(sp)
    80005fa0:	fcc2                	sd	a6,120(sp)
    80005fa2:	e146                	sd	a7,128(sp)
    80005fa4:	e54a                	sd	s2,136(sp)
    80005fa6:	e94e                	sd	s3,144(sp)
    80005fa8:	ed52                	sd	s4,152(sp)
    80005faa:	f156                	sd	s5,160(sp)
    80005fac:	f55a                	sd	s6,168(sp)
    80005fae:	f95e                	sd	s7,176(sp)
    80005fb0:	fd62                	sd	s8,184(sp)
    80005fb2:	e1e6                	sd	s9,192(sp)
    80005fb4:	e5ea                	sd	s10,200(sp)
    80005fb6:	e9ee                	sd	s11,208(sp)
    80005fb8:	edf2                	sd	t3,216(sp)
    80005fba:	f1f6                	sd	t4,224(sp)
    80005fbc:	f5fa                	sd	t5,232(sp)
    80005fbe:	f9fe                	sd	t6,240(sp)
    80005fc0:	cc9fc0ef          	jal	ra,80002c88 <kerneltrap>
    80005fc4:	6082                	ld	ra,0(sp)
    80005fc6:	6122                	ld	sp,8(sp)
    80005fc8:	61c2                	ld	gp,16(sp)
    80005fca:	7282                	ld	t0,32(sp)
    80005fcc:	7322                	ld	t1,40(sp)
    80005fce:	73c2                	ld	t2,48(sp)
    80005fd0:	7462                	ld	s0,56(sp)
    80005fd2:	6486                	ld	s1,64(sp)
    80005fd4:	6526                	ld	a0,72(sp)
    80005fd6:	65c6                	ld	a1,80(sp)
    80005fd8:	6666                	ld	a2,88(sp)
    80005fda:	7686                	ld	a3,96(sp)
    80005fdc:	7726                	ld	a4,104(sp)
    80005fde:	77c6                	ld	a5,112(sp)
    80005fe0:	7866                	ld	a6,120(sp)
    80005fe2:	688a                	ld	a7,128(sp)
    80005fe4:	692a                	ld	s2,136(sp)
    80005fe6:	69ca                	ld	s3,144(sp)
    80005fe8:	6a6a                	ld	s4,152(sp)
    80005fea:	7a8a                	ld	s5,160(sp)
    80005fec:	7b2a                	ld	s6,168(sp)
    80005fee:	7bca                	ld	s7,176(sp)
    80005ff0:	7c6a                	ld	s8,184(sp)
    80005ff2:	6c8e                	ld	s9,192(sp)
    80005ff4:	6d2e                	ld	s10,200(sp)
    80005ff6:	6dce                	ld	s11,208(sp)
    80005ff8:	6e6e                	ld	t3,216(sp)
    80005ffa:	7e8e                	ld	t4,224(sp)
    80005ffc:	7f2e                	ld	t5,232(sp)
    80005ffe:	7fce                	ld	t6,240(sp)
    80006000:	6111                	addi	sp,sp,256
    80006002:	10200073          	sret
    80006006:	00000013          	nop
    8000600a:	00000013          	nop
    8000600e:	0001                	nop

0000000080006010 <timervec>:
    80006010:	34051573          	csrrw	a0,mscratch,a0
    80006014:	e10c                	sd	a1,0(a0)
    80006016:	e510                	sd	a2,8(a0)
    80006018:	e914                	sd	a3,16(a0)
    8000601a:	6d0c                	ld	a1,24(a0)
    8000601c:	7110                	ld	a2,32(a0)
    8000601e:	6194                	ld	a3,0(a1)
    80006020:	96b2                	add	a3,a3,a2
    80006022:	e194                	sd	a3,0(a1)
    80006024:	4589                	li	a1,2
    80006026:	14459073          	csrw	sip,a1
    8000602a:	6914                	ld	a3,16(a0)
    8000602c:	6510                	ld	a2,8(a0)
    8000602e:	610c                	ld	a1,0(a0)
    80006030:	34051573          	csrrw	a0,mscratch,a0
    80006034:	30200073          	mret
	...

000000008000603a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000603a:	1141                	addi	sp,sp,-16
    8000603c:	e422                	sd	s0,8(sp)
    8000603e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006040:	0c0007b7          	lui	a5,0xc000
    80006044:	4705                	li	a4,1
    80006046:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006048:	c3d8                	sw	a4,4(a5)
}
    8000604a:	6422                	ld	s0,8(sp)
    8000604c:	0141                	addi	sp,sp,16
    8000604e:	8082                	ret

0000000080006050 <plicinithart>:

void
plicinithart(void)
{
    80006050:	1141                	addi	sp,sp,-16
    80006052:	e406                	sd	ra,8(sp)
    80006054:	e022                	sd	s0,0(sp)
    80006056:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006058:	ffffc097          	auipc	ra,0xffffc
    8000605c:	9fe080e7          	jalr	-1538(ra) # 80001a56 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006060:	0085171b          	slliw	a4,a0,0x8
    80006064:	0c0027b7          	lui	a5,0xc002
    80006068:	97ba                	add	a5,a5,a4
    8000606a:	40200713          	li	a4,1026
    8000606e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006072:	00d5151b          	slliw	a0,a0,0xd
    80006076:	0c2017b7          	lui	a5,0xc201
    8000607a:	953e                	add	a0,a0,a5
    8000607c:	00052023          	sw	zero,0(a0)
}
    80006080:	60a2                	ld	ra,8(sp)
    80006082:	6402                	ld	s0,0(sp)
    80006084:	0141                	addi	sp,sp,16
    80006086:	8082                	ret

0000000080006088 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006088:	1141                	addi	sp,sp,-16
    8000608a:	e406                	sd	ra,8(sp)
    8000608c:	e022                	sd	s0,0(sp)
    8000608e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006090:	ffffc097          	auipc	ra,0xffffc
    80006094:	9c6080e7          	jalr	-1594(ra) # 80001a56 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006098:	00d5179b          	slliw	a5,a0,0xd
    8000609c:	0c201537          	lui	a0,0xc201
    800060a0:	953e                	add	a0,a0,a5
  return irq;
}
    800060a2:	4148                	lw	a0,4(a0)
    800060a4:	60a2                	ld	ra,8(sp)
    800060a6:	6402                	ld	s0,0(sp)
    800060a8:	0141                	addi	sp,sp,16
    800060aa:	8082                	ret

00000000800060ac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800060ac:	1101                	addi	sp,sp,-32
    800060ae:	ec06                	sd	ra,24(sp)
    800060b0:	e822                	sd	s0,16(sp)
    800060b2:	e426                	sd	s1,8(sp)
    800060b4:	1000                	addi	s0,sp,32
    800060b6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800060b8:	ffffc097          	auipc	ra,0xffffc
    800060bc:	99e080e7          	jalr	-1634(ra) # 80001a56 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800060c0:	00d5151b          	slliw	a0,a0,0xd
    800060c4:	0c2017b7          	lui	a5,0xc201
    800060c8:	97aa                	add	a5,a5,a0
    800060ca:	c3c4                	sw	s1,4(a5)
}
    800060cc:	60e2                	ld	ra,24(sp)
    800060ce:	6442                	ld	s0,16(sp)
    800060d0:	64a2                	ld	s1,8(sp)
    800060d2:	6105                	addi	sp,sp,32
    800060d4:	8082                	ret

00000000800060d6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800060d6:	1141                	addi	sp,sp,-16
    800060d8:	e406                	sd	ra,8(sp)
    800060da:	e022                	sd	s0,0(sp)
    800060dc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800060de:	479d                	li	a5,7
    800060e0:	06a7c963          	blt	a5,a0,80006152 <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    800060e4:	0001d797          	auipc	a5,0x1d
    800060e8:	f1c78793          	addi	a5,a5,-228 # 80023000 <disk>
    800060ec:	00a78733          	add	a4,a5,a0
    800060f0:	6789                	lui	a5,0x2
    800060f2:	97ba                	add	a5,a5,a4
    800060f4:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    800060f8:	e7ad                	bnez	a5,80006162 <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800060fa:	00451793          	slli	a5,a0,0x4
    800060fe:	0001f717          	auipc	a4,0x1f
    80006102:	f0270713          	addi	a4,a4,-254 # 80025000 <disk+0x2000>
    80006106:	6314                	ld	a3,0(a4)
    80006108:	96be                	add	a3,a3,a5
    8000610a:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    8000610e:	6314                	ld	a3,0(a4)
    80006110:	96be                	add	a3,a3,a5
    80006112:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80006116:	6314                	ld	a3,0(a4)
    80006118:	96be                	add	a3,a3,a5
    8000611a:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    8000611e:	6318                	ld	a4,0(a4)
    80006120:	97ba                	add	a5,a5,a4
    80006122:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    80006126:	0001d797          	auipc	a5,0x1d
    8000612a:	eda78793          	addi	a5,a5,-294 # 80023000 <disk>
    8000612e:	97aa                	add	a5,a5,a0
    80006130:	6509                	lui	a0,0x2
    80006132:	953e                	add	a0,a0,a5
    80006134:	4785                	li	a5,1
    80006136:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    8000613a:	0001f517          	auipc	a0,0x1f
    8000613e:	ede50513          	addi	a0,a0,-290 # 80025018 <disk+0x2018>
    80006142:	ffffc097          	auipc	ra,0xffffc
    80006146:	430080e7          	jalr	1072(ra) # 80002572 <wakeup>
}
    8000614a:	60a2                	ld	ra,8(sp)
    8000614c:	6402                	ld	s0,0(sp)
    8000614e:	0141                	addi	sp,sp,16
    80006150:	8082                	ret
    panic("free_desc 1");
    80006152:	00002517          	auipc	a0,0x2
    80006156:	60650513          	addi	a0,a0,1542 # 80008758 <syscalls+0x328>
    8000615a:	ffffa097          	auipc	ra,0xffffa
    8000615e:	3d6080e7          	jalr	982(ra) # 80000530 <panic>
    panic("free_desc 2");
    80006162:	00002517          	auipc	a0,0x2
    80006166:	60650513          	addi	a0,a0,1542 # 80008768 <syscalls+0x338>
    8000616a:	ffffa097          	auipc	ra,0xffffa
    8000616e:	3c6080e7          	jalr	966(ra) # 80000530 <panic>

0000000080006172 <virtio_disk_init>:
{
    80006172:	1101                	addi	sp,sp,-32
    80006174:	ec06                	sd	ra,24(sp)
    80006176:	e822                	sd	s0,16(sp)
    80006178:	e426                	sd	s1,8(sp)
    8000617a:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    8000617c:	00002597          	auipc	a1,0x2
    80006180:	5fc58593          	addi	a1,a1,1532 # 80008778 <syscalls+0x348>
    80006184:	0001f517          	auipc	a0,0x1f
    80006188:	fa450513          	addi	a0,a0,-92 # 80025128 <disk+0x2128>
    8000618c:	ffffb097          	auipc	ra,0xffffb
    80006190:	9b6080e7          	jalr	-1610(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006194:	100017b7          	lui	a5,0x10001
    80006198:	4398                	lw	a4,0(a5)
    8000619a:	2701                	sext.w	a4,a4
    8000619c:	747277b7          	lui	a5,0x74727
    800061a0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800061a4:	0ef71163          	bne	a4,a5,80006286 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800061a8:	100017b7          	lui	a5,0x10001
    800061ac:	43dc                	lw	a5,4(a5)
    800061ae:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800061b0:	4705                	li	a4,1
    800061b2:	0ce79a63          	bne	a5,a4,80006286 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061b6:	100017b7          	lui	a5,0x10001
    800061ba:	479c                	lw	a5,8(a5)
    800061bc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    800061be:	4709                	li	a4,2
    800061c0:	0ce79363          	bne	a5,a4,80006286 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800061c4:	100017b7          	lui	a5,0x10001
    800061c8:	47d8                	lw	a4,12(a5)
    800061ca:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800061cc:	554d47b7          	lui	a5,0x554d4
    800061d0:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800061d4:	0af71963          	bne	a4,a5,80006286 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    800061d8:	100017b7          	lui	a5,0x10001
    800061dc:	4705                	li	a4,1
    800061de:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061e0:	470d                	li	a4,3
    800061e2:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800061e4:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800061e6:	c7ffe737          	lui	a4,0xc7ffe
    800061ea:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd875f>
    800061ee:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800061f0:	2701                	sext.w	a4,a4
    800061f2:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061f4:	472d                	li	a4,11
    800061f6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800061f8:	473d                	li	a4,15
    800061fa:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    800061fc:	6705                	lui	a4,0x1
    800061fe:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006200:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006204:	5bdc                	lw	a5,52(a5)
    80006206:	2781                	sext.w	a5,a5
  if(max == 0)
    80006208:	c7d9                	beqz	a5,80006296 <virtio_disk_init+0x124>
  if(max < NUM)
    8000620a:	471d                	li	a4,7
    8000620c:	08f77d63          	bgeu	a4,a5,800062a6 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006210:	100014b7          	lui	s1,0x10001
    80006214:	47a1                	li	a5,8
    80006216:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80006218:	6609                	lui	a2,0x2
    8000621a:	4581                	li	a1,0
    8000621c:	0001d517          	auipc	a0,0x1d
    80006220:	de450513          	addi	a0,a0,-540 # 80023000 <disk>
    80006224:	ffffb097          	auipc	ra,0xffffb
    80006228:	aaa080e7          	jalr	-1366(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    8000622c:	0001d717          	auipc	a4,0x1d
    80006230:	dd470713          	addi	a4,a4,-556 # 80023000 <disk>
    80006234:	00c75793          	srli	a5,a4,0xc
    80006238:	2781                	sext.w	a5,a5
    8000623a:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    8000623c:	0001f797          	auipc	a5,0x1f
    80006240:	dc478793          	addi	a5,a5,-572 # 80025000 <disk+0x2000>
    80006244:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    80006246:	0001d717          	auipc	a4,0x1d
    8000624a:	e3a70713          	addi	a4,a4,-454 # 80023080 <disk+0x80>
    8000624e:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    80006250:	0001e717          	auipc	a4,0x1e
    80006254:	db070713          	addi	a4,a4,-592 # 80024000 <disk+0x1000>
    80006258:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    8000625a:	4705                	li	a4,1
    8000625c:	00e78c23          	sb	a4,24(a5)
    80006260:	00e78ca3          	sb	a4,25(a5)
    80006264:	00e78d23          	sb	a4,26(a5)
    80006268:	00e78da3          	sb	a4,27(a5)
    8000626c:	00e78e23          	sb	a4,28(a5)
    80006270:	00e78ea3          	sb	a4,29(a5)
    80006274:	00e78f23          	sb	a4,30(a5)
    80006278:	00e78fa3          	sb	a4,31(a5)
}
    8000627c:	60e2                	ld	ra,24(sp)
    8000627e:	6442                	ld	s0,16(sp)
    80006280:	64a2                	ld	s1,8(sp)
    80006282:	6105                	addi	sp,sp,32
    80006284:	8082                	ret
    panic("could not find virtio disk");
    80006286:	00002517          	auipc	a0,0x2
    8000628a:	50250513          	addi	a0,a0,1282 # 80008788 <syscalls+0x358>
    8000628e:	ffffa097          	auipc	ra,0xffffa
    80006292:	2a2080e7          	jalr	674(ra) # 80000530 <panic>
    panic("virtio disk has no queue 0");
    80006296:	00002517          	auipc	a0,0x2
    8000629a:	51250513          	addi	a0,a0,1298 # 800087a8 <syscalls+0x378>
    8000629e:	ffffa097          	auipc	ra,0xffffa
    800062a2:	292080e7          	jalr	658(ra) # 80000530 <panic>
    panic("virtio disk max queue too short");
    800062a6:	00002517          	auipc	a0,0x2
    800062aa:	52250513          	addi	a0,a0,1314 # 800087c8 <syscalls+0x398>
    800062ae:	ffffa097          	auipc	ra,0xffffa
    800062b2:	282080e7          	jalr	642(ra) # 80000530 <panic>

00000000800062b6 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800062b6:	7159                	addi	sp,sp,-112
    800062b8:	f486                	sd	ra,104(sp)
    800062ba:	f0a2                	sd	s0,96(sp)
    800062bc:	eca6                	sd	s1,88(sp)
    800062be:	e8ca                	sd	s2,80(sp)
    800062c0:	e4ce                	sd	s3,72(sp)
    800062c2:	e0d2                	sd	s4,64(sp)
    800062c4:	fc56                	sd	s5,56(sp)
    800062c6:	f85a                	sd	s6,48(sp)
    800062c8:	f45e                	sd	s7,40(sp)
    800062ca:	f062                	sd	s8,32(sp)
    800062cc:	ec66                	sd	s9,24(sp)
    800062ce:	e86a                	sd	s10,16(sp)
    800062d0:	1880                	addi	s0,sp,112
    800062d2:	892a                	mv	s2,a0
    800062d4:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800062d6:	00c52c83          	lw	s9,12(a0)
    800062da:	001c9c9b          	slliw	s9,s9,0x1
    800062de:	1c82                	slli	s9,s9,0x20
    800062e0:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800062e4:	0001f517          	auipc	a0,0x1f
    800062e8:	e4450513          	addi	a0,a0,-444 # 80025128 <disk+0x2128>
    800062ec:	ffffb097          	auipc	ra,0xffffb
    800062f0:	8e6080e7          	jalr	-1818(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    800062f4:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    800062f6:	4c21                	li	s8,8
      disk.free[i] = 0;
    800062f8:	0001db97          	auipc	s7,0x1d
    800062fc:	d08b8b93          	addi	s7,s7,-760 # 80023000 <disk>
    80006300:	6b09                	lui	s6,0x2
  for(int i = 0; i < 3; i++){
    80006302:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80006304:	8a4e                	mv	s4,s3
    80006306:	a051                	j	8000638a <virtio_disk_rw+0xd4>
      disk.free[i] = 0;
    80006308:	00fb86b3          	add	a3,s7,a5
    8000630c:	96da                	add	a3,a3,s6
    8000630e:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80006312:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    80006314:	0207c563          	bltz	a5,8000633e <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    80006318:	2485                	addiw	s1,s1,1
    8000631a:	0711                	addi	a4,a4,4
    8000631c:	25548063          	beq	s1,s5,8000655c <virtio_disk_rw+0x2a6>
    idx[i] = alloc_desc();
    80006320:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80006322:	0001f697          	auipc	a3,0x1f
    80006326:	cf668693          	addi	a3,a3,-778 # 80025018 <disk+0x2018>
    8000632a:	87d2                	mv	a5,s4
    if(disk.free[i]){
    8000632c:	0006c583          	lbu	a1,0(a3)
    80006330:	fde1                	bnez	a1,80006308 <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006332:	2785                	addiw	a5,a5,1
    80006334:	0685                	addi	a3,a3,1
    80006336:	ff879be3          	bne	a5,s8,8000632c <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000633a:	57fd                	li	a5,-1
    8000633c:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    8000633e:	02905a63          	blez	s1,80006372 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006342:	f9042503          	lw	a0,-112(s0)
    80006346:	00000097          	auipc	ra,0x0
    8000634a:	d90080e7          	jalr	-624(ra) # 800060d6 <free_desc>
      for(int j = 0; j < i; j++)
    8000634e:	4785                	li	a5,1
    80006350:	0297d163          	bge	a5,s1,80006372 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006354:	f9442503          	lw	a0,-108(s0)
    80006358:	00000097          	auipc	ra,0x0
    8000635c:	d7e080e7          	jalr	-642(ra) # 800060d6 <free_desc>
      for(int j = 0; j < i; j++)
    80006360:	4789                	li	a5,2
    80006362:	0097d863          	bge	a5,s1,80006372 <virtio_disk_rw+0xbc>
        free_desc(idx[j]);
    80006366:	f9842503          	lw	a0,-104(s0)
    8000636a:	00000097          	auipc	ra,0x0
    8000636e:	d6c080e7          	jalr	-660(ra) # 800060d6 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006372:	0001f597          	auipc	a1,0x1f
    80006376:	db658593          	addi	a1,a1,-586 # 80025128 <disk+0x2128>
    8000637a:	0001f517          	auipc	a0,0x1f
    8000637e:	c9e50513          	addi	a0,a0,-866 # 80025018 <disk+0x2018>
    80006382:	ffffc097          	auipc	ra,0xffffc
    80006386:	064080e7          	jalr	100(ra) # 800023e6 <sleep>
  for(int i = 0; i < 3; i++){
    8000638a:	f9040713          	addi	a4,s0,-112
    8000638e:	84ce                	mv	s1,s3
    80006390:	bf41                	j	80006320 <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80006392:	20058713          	addi	a4,a1,512
    80006396:	00471693          	slli	a3,a4,0x4
    8000639a:	0001d717          	auipc	a4,0x1d
    8000639e:	c6670713          	addi	a4,a4,-922 # 80023000 <disk>
    800063a2:	9736                	add	a4,a4,a3
    800063a4:	4685                	li	a3,1
    800063a6:	0ad72423          	sw	a3,168(a4)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800063aa:	20058713          	addi	a4,a1,512
    800063ae:	00471693          	slli	a3,a4,0x4
    800063b2:	0001d717          	auipc	a4,0x1d
    800063b6:	c4e70713          	addi	a4,a4,-946 # 80023000 <disk>
    800063ba:	9736                	add	a4,a4,a3
    800063bc:	0a072623          	sw	zero,172(a4)
  buf0->sector = sector;
    800063c0:	0b973823          	sd	s9,176(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800063c4:	7679                	lui	a2,0xffffe
    800063c6:	963e                	add	a2,a2,a5
    800063c8:	0001f697          	auipc	a3,0x1f
    800063cc:	c3868693          	addi	a3,a3,-968 # 80025000 <disk+0x2000>
    800063d0:	6298                	ld	a4,0(a3)
    800063d2:	9732                	add	a4,a4,a2
    800063d4:	e308                	sd	a0,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800063d6:	6298                	ld	a4,0(a3)
    800063d8:	9732                	add	a4,a4,a2
    800063da:	4541                	li	a0,16
    800063dc:	c708                	sw	a0,8(a4)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800063de:	6298                	ld	a4,0(a3)
    800063e0:	9732                	add	a4,a4,a2
    800063e2:	4505                	li	a0,1
    800063e4:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[0]].next = idx[1];
    800063e8:	f9442703          	lw	a4,-108(s0)
    800063ec:	6288                	ld	a0,0(a3)
    800063ee:	962a                	add	a2,a2,a0
    800063f0:	00e61723          	sh	a4,14(a2) # ffffffffffffe00e <end+0xffffffff7ffd800e>

  disk.desc[idx[1]].addr = (uint64) b->data;
    800063f4:	0712                	slli	a4,a4,0x4
    800063f6:	6290                	ld	a2,0(a3)
    800063f8:	963a                	add	a2,a2,a4
    800063fa:	05890513          	addi	a0,s2,88
    800063fe:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006400:	6294                	ld	a3,0(a3)
    80006402:	96ba                	add	a3,a3,a4
    80006404:	40000613          	li	a2,1024
    80006408:	c690                	sw	a2,8(a3)
  if(write)
    8000640a:	140d0063          	beqz	s10,8000654a <virtio_disk_rw+0x294>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000640e:	0001f697          	auipc	a3,0x1f
    80006412:	bf26b683          	ld	a3,-1038(a3) # 80025000 <disk+0x2000>
    80006416:	96ba                	add	a3,a3,a4
    80006418:	00069623          	sh	zero,12(a3)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000641c:	0001d817          	auipc	a6,0x1d
    80006420:	be480813          	addi	a6,a6,-1052 # 80023000 <disk>
    80006424:	0001f517          	auipc	a0,0x1f
    80006428:	bdc50513          	addi	a0,a0,-1060 # 80025000 <disk+0x2000>
    8000642c:	6114                	ld	a3,0(a0)
    8000642e:	96ba                	add	a3,a3,a4
    80006430:	00c6d603          	lhu	a2,12(a3)
    80006434:	00166613          	ori	a2,a2,1
    80006438:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    8000643c:	f9842683          	lw	a3,-104(s0)
    80006440:	6110                	ld	a2,0(a0)
    80006442:	9732                	add	a4,a4,a2
    80006444:	00d71723          	sh	a3,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006448:	20058613          	addi	a2,a1,512
    8000644c:	0612                	slli	a2,a2,0x4
    8000644e:	9642                	add	a2,a2,a6
    80006450:	577d                	li	a4,-1
    80006452:	02e60823          	sb	a4,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006456:	00469713          	slli	a4,a3,0x4
    8000645a:	6114                	ld	a3,0(a0)
    8000645c:	96ba                	add	a3,a3,a4
    8000645e:	03078793          	addi	a5,a5,48
    80006462:	97c2                	add	a5,a5,a6
    80006464:	e29c                	sd	a5,0(a3)
  disk.desc[idx[2]].len = 1;
    80006466:	611c                	ld	a5,0(a0)
    80006468:	97ba                	add	a5,a5,a4
    8000646a:	4685                	li	a3,1
    8000646c:	c794                	sw	a3,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000646e:	611c                	ld	a5,0(a0)
    80006470:	97ba                	add	a5,a5,a4
    80006472:	4809                	li	a6,2
    80006474:	01079623          	sh	a6,12(a5)
  disk.desc[idx[2]].next = 0;
    80006478:	611c                	ld	a5,0(a0)
    8000647a:	973e                	add	a4,a4,a5
    8000647c:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006480:	00d92223          	sw	a3,4(s2)
  disk.info[idx[0]].b = b;
    80006484:	03263423          	sd	s2,40(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006488:	6518                	ld	a4,8(a0)
    8000648a:	00275783          	lhu	a5,2(a4)
    8000648e:	8b9d                	andi	a5,a5,7
    80006490:	0786                	slli	a5,a5,0x1
    80006492:	97ba                	add	a5,a5,a4
    80006494:	00b79223          	sh	a1,4(a5)

  __sync_synchronize();
    80006498:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000649c:	6518                	ld	a4,8(a0)
    8000649e:	00275783          	lhu	a5,2(a4)
    800064a2:	2785                	addiw	a5,a5,1
    800064a4:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800064a8:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800064ac:	100017b7          	lui	a5,0x10001
    800064b0:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800064b4:	00492703          	lw	a4,4(s2)
    800064b8:	4785                	li	a5,1
    800064ba:	02f71163          	bne	a4,a5,800064dc <virtio_disk_rw+0x226>
    sleep(b, &disk.vdisk_lock);
    800064be:	0001f997          	auipc	s3,0x1f
    800064c2:	c6a98993          	addi	s3,s3,-918 # 80025128 <disk+0x2128>
  while(b->disk == 1) {
    800064c6:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800064c8:	85ce                	mv	a1,s3
    800064ca:	854a                	mv	a0,s2
    800064cc:	ffffc097          	auipc	ra,0xffffc
    800064d0:	f1a080e7          	jalr	-230(ra) # 800023e6 <sleep>
  while(b->disk == 1) {
    800064d4:	00492783          	lw	a5,4(s2)
    800064d8:	fe9788e3          	beq	a5,s1,800064c8 <virtio_disk_rw+0x212>
  }

  disk.info[idx[0]].b = 0;
    800064dc:	f9042903          	lw	s2,-112(s0)
    800064e0:	20090793          	addi	a5,s2,512
    800064e4:	00479713          	slli	a4,a5,0x4
    800064e8:	0001d797          	auipc	a5,0x1d
    800064ec:	b1878793          	addi	a5,a5,-1256 # 80023000 <disk>
    800064f0:	97ba                	add	a5,a5,a4
    800064f2:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    800064f6:	0001f997          	auipc	s3,0x1f
    800064fa:	b0a98993          	addi	s3,s3,-1270 # 80025000 <disk+0x2000>
    800064fe:	00491713          	slli	a4,s2,0x4
    80006502:	0009b783          	ld	a5,0(s3)
    80006506:	97ba                	add	a5,a5,a4
    80006508:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000650c:	854a                	mv	a0,s2
    8000650e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006512:	00000097          	auipc	ra,0x0
    80006516:	bc4080e7          	jalr	-1084(ra) # 800060d6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000651a:	8885                	andi	s1,s1,1
    8000651c:	f0ed                	bnez	s1,800064fe <virtio_disk_rw+0x248>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000651e:	0001f517          	auipc	a0,0x1f
    80006522:	c0a50513          	addi	a0,a0,-1014 # 80025128 <disk+0x2128>
    80006526:	ffffa097          	auipc	ra,0xffffa
    8000652a:	760080e7          	jalr	1888(ra) # 80000c86 <release>
}
    8000652e:	70a6                	ld	ra,104(sp)
    80006530:	7406                	ld	s0,96(sp)
    80006532:	64e6                	ld	s1,88(sp)
    80006534:	6946                	ld	s2,80(sp)
    80006536:	69a6                	ld	s3,72(sp)
    80006538:	6a06                	ld	s4,64(sp)
    8000653a:	7ae2                	ld	s5,56(sp)
    8000653c:	7b42                	ld	s6,48(sp)
    8000653e:	7ba2                	ld	s7,40(sp)
    80006540:	7c02                	ld	s8,32(sp)
    80006542:	6ce2                	ld	s9,24(sp)
    80006544:	6d42                	ld	s10,16(sp)
    80006546:	6165                	addi	sp,sp,112
    80006548:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000654a:	0001f697          	auipc	a3,0x1f
    8000654e:	ab66b683          	ld	a3,-1354(a3) # 80025000 <disk+0x2000>
    80006552:	96ba                	add	a3,a3,a4
    80006554:	4609                	li	a2,2
    80006556:	00c69623          	sh	a2,12(a3)
    8000655a:	b5c9                	j	8000641c <virtio_disk_rw+0x166>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000655c:	f9042583          	lw	a1,-112(s0)
    80006560:	20058793          	addi	a5,a1,512
    80006564:	0792                	slli	a5,a5,0x4
    80006566:	0001d517          	auipc	a0,0x1d
    8000656a:	b4250513          	addi	a0,a0,-1214 # 800230a8 <disk+0xa8>
    8000656e:	953e                	add	a0,a0,a5
  if(write)
    80006570:	e20d11e3          	bnez	s10,80006392 <virtio_disk_rw+0xdc>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80006574:	20058713          	addi	a4,a1,512
    80006578:	00471693          	slli	a3,a4,0x4
    8000657c:	0001d717          	auipc	a4,0x1d
    80006580:	a8470713          	addi	a4,a4,-1404 # 80023000 <disk>
    80006584:	9736                	add	a4,a4,a3
    80006586:	0a072423          	sw	zero,168(a4)
    8000658a:	b505                	j	800063aa <virtio_disk_rw+0xf4>

000000008000658c <virtio_disk_intr>:

void
virtio_disk_intr()
{
    8000658c:	1101                	addi	sp,sp,-32
    8000658e:	ec06                	sd	ra,24(sp)
    80006590:	e822                	sd	s0,16(sp)
    80006592:	e426                	sd	s1,8(sp)
    80006594:	e04a                	sd	s2,0(sp)
    80006596:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006598:	0001f517          	auipc	a0,0x1f
    8000659c:	b9050513          	addi	a0,a0,-1136 # 80025128 <disk+0x2128>
    800065a0:	ffffa097          	auipc	ra,0xffffa
    800065a4:	632080e7          	jalr	1586(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800065a8:	10001737          	lui	a4,0x10001
    800065ac:	533c                	lw	a5,96(a4)
    800065ae:	8b8d                	andi	a5,a5,3
    800065b0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800065b2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800065b6:	0001f797          	auipc	a5,0x1f
    800065ba:	a4a78793          	addi	a5,a5,-1462 # 80025000 <disk+0x2000>
    800065be:	6b94                	ld	a3,16(a5)
    800065c0:	0207d703          	lhu	a4,32(a5)
    800065c4:	0026d783          	lhu	a5,2(a3)
    800065c8:	06f70163          	beq	a4,a5,8000662a <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800065cc:	0001d917          	auipc	s2,0x1d
    800065d0:	a3490913          	addi	s2,s2,-1484 # 80023000 <disk>
    800065d4:	0001f497          	auipc	s1,0x1f
    800065d8:	a2c48493          	addi	s1,s1,-1492 # 80025000 <disk+0x2000>
    __sync_synchronize();
    800065dc:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800065e0:	6898                	ld	a4,16(s1)
    800065e2:	0204d783          	lhu	a5,32(s1)
    800065e6:	8b9d                	andi	a5,a5,7
    800065e8:	078e                	slli	a5,a5,0x3
    800065ea:	97ba                	add	a5,a5,a4
    800065ec:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800065ee:	20078713          	addi	a4,a5,512
    800065f2:	0712                	slli	a4,a4,0x4
    800065f4:	974a                	add	a4,a4,s2
    800065f6:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    800065fa:	e731                	bnez	a4,80006646 <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800065fc:	20078793          	addi	a5,a5,512
    80006600:	0792                	slli	a5,a5,0x4
    80006602:	97ca                	add	a5,a5,s2
    80006604:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    80006606:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000660a:	ffffc097          	auipc	ra,0xffffc
    8000660e:	f68080e7          	jalr	-152(ra) # 80002572 <wakeup>

    disk.used_idx += 1;
    80006612:	0204d783          	lhu	a5,32(s1)
    80006616:	2785                	addiw	a5,a5,1
    80006618:	17c2                	slli	a5,a5,0x30
    8000661a:	93c1                	srli	a5,a5,0x30
    8000661c:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006620:	6898                	ld	a4,16(s1)
    80006622:	00275703          	lhu	a4,2(a4)
    80006626:	faf71be3          	bne	a4,a5,800065dc <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    8000662a:	0001f517          	auipc	a0,0x1f
    8000662e:	afe50513          	addi	a0,a0,-1282 # 80025128 <disk+0x2128>
    80006632:	ffffa097          	auipc	ra,0xffffa
    80006636:	654080e7          	jalr	1620(ra) # 80000c86 <release>
}
    8000663a:	60e2                	ld	ra,24(sp)
    8000663c:	6442                	ld	s0,16(sp)
    8000663e:	64a2                	ld	s1,8(sp)
    80006640:	6902                	ld	s2,0(sp)
    80006642:	6105                	addi	sp,sp,32
    80006644:	8082                	ret
      panic("virtio_disk_intr status");
    80006646:	00002517          	auipc	a0,0x2
    8000664a:	1a250513          	addi	a0,a0,418 # 800087e8 <syscalls+0x3b8>
    8000664e:	ffffa097          	auipc	ra,0xffffa
    80006652:	ee2080e7          	jalr	-286(ra) # 80000530 <panic>
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
