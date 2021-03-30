
user/_zombie:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if(fork() > 0)
   8:	00000097          	auipc	ra,0x0
   c:	288080e7          	jalr	648(ra) # 290 <fork>
  10:	00a04763          	bgtz	a0,1e <main+0x1e>
    sleep(5);  // Let child exit before parent.
  exit(0);
  14:	4501                	li	a0,0
  16:	00000097          	auipc	ra,0x0
  1a:	282080e7          	jalr	642(ra) # 298 <exit>
    sleep(5);  // Let child exit before parent.
  1e:	4515                	li	a0,5
  20:	00000097          	auipc	ra,0x0
  24:	308080e7          	jalr	776(ra) # 328 <sleep>
  28:	b7f5                	j	14 <main+0x14>

000000000000002a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  2a:	1141                	addi	sp,sp,-16
  2c:	e422                	sd	s0,8(sp)
  2e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  30:	87aa                	mv	a5,a0
  32:	0585                	addi	a1,a1,1
  34:	0785                	addi	a5,a5,1
  36:	fff5c703          	lbu	a4,-1(a1)
  3a:	fee78fa3          	sb	a4,-1(a5)
  3e:	fb75                	bnez	a4,32 <strcpy+0x8>
    ;
  return os;
}
  40:	6422                	ld	s0,8(sp)
  42:	0141                	addi	sp,sp,16
  44:	8082                	ret

0000000000000046 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  46:	1141                	addi	sp,sp,-16
  48:	e422                	sd	s0,8(sp)
  4a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  4c:	00054783          	lbu	a5,0(a0)
  50:	cb91                	beqz	a5,64 <strcmp+0x1e>
  52:	0005c703          	lbu	a4,0(a1)
  56:	00f71763          	bne	a4,a5,64 <strcmp+0x1e>
    p++, q++;
  5a:	0505                	addi	a0,a0,1
  5c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  5e:	00054783          	lbu	a5,0(a0)
  62:	fbe5                	bnez	a5,52 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  64:	0005c503          	lbu	a0,0(a1)
}
  68:	40a7853b          	subw	a0,a5,a0
  6c:	6422                	ld	s0,8(sp)
  6e:	0141                	addi	sp,sp,16
  70:	8082                	ret

0000000000000072 <strlen>:

uint
strlen(const char *s)
{
  72:	1141                	addi	sp,sp,-16
  74:	e422                	sd	s0,8(sp)
  76:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  78:	00054783          	lbu	a5,0(a0)
  7c:	cf91                	beqz	a5,98 <strlen+0x26>
  7e:	0505                	addi	a0,a0,1
  80:	87aa                	mv	a5,a0
  82:	4685                	li	a3,1
  84:	9e89                	subw	a3,a3,a0
  86:	00f6853b          	addw	a0,a3,a5
  8a:	0785                	addi	a5,a5,1
  8c:	fff7c703          	lbu	a4,-1(a5)
  90:	fb7d                	bnez	a4,86 <strlen+0x14>
    ;
  return n;
}
  92:	6422                	ld	s0,8(sp)
  94:	0141                	addi	sp,sp,16
  96:	8082                	ret
  for(n = 0; s[n]; n++)
  98:	4501                	li	a0,0
  9a:	bfe5                	j	92 <strlen+0x20>

000000000000009c <memset>:

void*
memset(void *dst, int c, uint n)
{
  9c:	1141                	addi	sp,sp,-16
  9e:	e422                	sd	s0,8(sp)
  a0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  a2:	ca19                	beqz	a2,b8 <memset+0x1c>
  a4:	87aa                	mv	a5,a0
  a6:	1602                	slli	a2,a2,0x20
  a8:	9201                	srli	a2,a2,0x20
  aa:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  ae:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  b2:	0785                	addi	a5,a5,1
  b4:	fee79de3          	bne	a5,a4,ae <memset+0x12>
  }
  return dst;
}
  b8:	6422                	ld	s0,8(sp)
  ba:	0141                	addi	sp,sp,16
  bc:	8082                	ret

00000000000000be <strchr>:

char*
strchr(const char *s, char c)
{
  be:	1141                	addi	sp,sp,-16
  c0:	e422                	sd	s0,8(sp)
  c2:	0800                	addi	s0,sp,16
  for(; *s; s++)
  c4:	00054783          	lbu	a5,0(a0)
  c8:	cb99                	beqz	a5,de <strchr+0x20>
    if(*s == c)
  ca:	00f58763          	beq	a1,a5,d8 <strchr+0x1a>
  for(; *s; s++)
  ce:	0505                	addi	a0,a0,1
  d0:	00054783          	lbu	a5,0(a0)
  d4:	fbfd                	bnez	a5,ca <strchr+0xc>
      return (char*)s;
  return 0;
  d6:	4501                	li	a0,0
}
  d8:	6422                	ld	s0,8(sp)
  da:	0141                	addi	sp,sp,16
  dc:	8082                	ret
  return 0;
  de:	4501                	li	a0,0
  e0:	bfe5                	j	d8 <strchr+0x1a>

00000000000000e2 <gets>:

char*
gets(char *buf, int max)
{
  e2:	711d                	addi	sp,sp,-96
  e4:	ec86                	sd	ra,88(sp)
  e6:	e8a2                	sd	s0,80(sp)
  e8:	e4a6                	sd	s1,72(sp)
  ea:	e0ca                	sd	s2,64(sp)
  ec:	fc4e                	sd	s3,56(sp)
  ee:	f852                	sd	s4,48(sp)
  f0:	f456                	sd	s5,40(sp)
  f2:	f05a                	sd	s6,32(sp)
  f4:	ec5e                	sd	s7,24(sp)
  f6:	1080                	addi	s0,sp,96
  f8:	8baa                	mv	s7,a0
  fa:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  fc:	892a                	mv	s2,a0
  fe:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 100:	4aa9                	li	s5,10
 102:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 104:	89a6                	mv	s3,s1
 106:	2485                	addiw	s1,s1,1
 108:	0344d863          	bge	s1,s4,138 <gets+0x56>
    cc = read(0, &c, 1);
 10c:	4605                	li	a2,1
 10e:	faf40593          	addi	a1,s0,-81
 112:	4501                	li	a0,0
 114:	00000097          	auipc	ra,0x0
 118:	19c080e7          	jalr	412(ra) # 2b0 <read>
    if(cc < 1)
 11c:	00a05e63          	blez	a0,138 <gets+0x56>
    buf[i++] = c;
 120:	faf44783          	lbu	a5,-81(s0)
 124:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 128:	01578763          	beq	a5,s5,136 <gets+0x54>
 12c:	0905                	addi	s2,s2,1
 12e:	fd679be3          	bne	a5,s6,104 <gets+0x22>
  for(i=0; i+1 < max; ){
 132:	89a6                	mv	s3,s1
 134:	a011                	j	138 <gets+0x56>
 136:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 138:	99de                	add	s3,s3,s7
 13a:	00098023          	sb	zero,0(s3)
  return buf;
}
 13e:	855e                	mv	a0,s7
 140:	60e6                	ld	ra,88(sp)
 142:	6446                	ld	s0,80(sp)
 144:	64a6                	ld	s1,72(sp)
 146:	6906                	ld	s2,64(sp)
 148:	79e2                	ld	s3,56(sp)
 14a:	7a42                	ld	s4,48(sp)
 14c:	7aa2                	ld	s5,40(sp)
 14e:	7b02                	ld	s6,32(sp)
 150:	6be2                	ld	s7,24(sp)
 152:	6125                	addi	sp,sp,96
 154:	8082                	ret

0000000000000156 <stat>:

int
stat(const char *n, struct stat *st)
{
 156:	1101                	addi	sp,sp,-32
 158:	ec06                	sd	ra,24(sp)
 15a:	e822                	sd	s0,16(sp)
 15c:	e426                	sd	s1,8(sp)
 15e:	e04a                	sd	s2,0(sp)
 160:	1000                	addi	s0,sp,32
 162:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 164:	4581                	li	a1,0
 166:	00000097          	auipc	ra,0x0
 16a:	172080e7          	jalr	370(ra) # 2d8 <open>
  if(fd < 0)
 16e:	02054563          	bltz	a0,198 <stat+0x42>
 172:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 174:	85ca                	mv	a1,s2
 176:	00000097          	auipc	ra,0x0
 17a:	17a080e7          	jalr	378(ra) # 2f0 <fstat>
 17e:	892a                	mv	s2,a0
  close(fd);
 180:	8526                	mv	a0,s1
 182:	00000097          	auipc	ra,0x0
 186:	13e080e7          	jalr	318(ra) # 2c0 <close>
  return r;
}
 18a:	854a                	mv	a0,s2
 18c:	60e2                	ld	ra,24(sp)
 18e:	6442                	ld	s0,16(sp)
 190:	64a2                	ld	s1,8(sp)
 192:	6902                	ld	s2,0(sp)
 194:	6105                	addi	sp,sp,32
 196:	8082                	ret
    return -1;
 198:	597d                	li	s2,-1
 19a:	bfc5                	j	18a <stat+0x34>

000000000000019c <atoi>:

int
atoi(const char *s)
{
 19c:	1141                	addi	sp,sp,-16
 19e:	e422                	sd	s0,8(sp)
 1a0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1a2:	00054603          	lbu	a2,0(a0)
 1a6:	fd06079b          	addiw	a5,a2,-48
 1aa:	0ff7f793          	andi	a5,a5,255
 1ae:	4725                	li	a4,9
 1b0:	02f76963          	bltu	a4,a5,1e2 <atoi+0x46>
 1b4:	86aa                	mv	a3,a0
  n = 0;
 1b6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1b8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1ba:	0685                	addi	a3,a3,1
 1bc:	0025179b          	slliw	a5,a0,0x2
 1c0:	9fa9                	addw	a5,a5,a0
 1c2:	0017979b          	slliw	a5,a5,0x1
 1c6:	9fb1                	addw	a5,a5,a2
 1c8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1cc:	0006c603          	lbu	a2,0(a3)
 1d0:	fd06071b          	addiw	a4,a2,-48
 1d4:	0ff77713          	andi	a4,a4,255
 1d8:	fee5f1e3          	bgeu	a1,a4,1ba <atoi+0x1e>
  return n;
}
 1dc:	6422                	ld	s0,8(sp)
 1de:	0141                	addi	sp,sp,16
 1e0:	8082                	ret
  n = 0;
 1e2:	4501                	li	a0,0
 1e4:	bfe5                	j	1dc <atoi+0x40>

00000000000001e6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1e6:	1141                	addi	sp,sp,-16
 1e8:	e422                	sd	s0,8(sp)
 1ea:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1ec:	02b57463          	bgeu	a0,a1,214 <memmove+0x2e>
    while(n-- > 0)
 1f0:	00c05f63          	blez	a2,20e <memmove+0x28>
 1f4:	1602                	slli	a2,a2,0x20
 1f6:	9201                	srli	a2,a2,0x20
 1f8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 1fc:	872a                	mv	a4,a0
      *dst++ = *src++;
 1fe:	0585                	addi	a1,a1,1
 200:	0705                	addi	a4,a4,1
 202:	fff5c683          	lbu	a3,-1(a1)
 206:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 20a:	fee79ae3          	bne	a5,a4,1fe <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 20e:	6422                	ld	s0,8(sp)
 210:	0141                	addi	sp,sp,16
 212:	8082                	ret
    dst += n;
 214:	00c50733          	add	a4,a0,a2
    src += n;
 218:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 21a:	fec05ae3          	blez	a2,20e <memmove+0x28>
 21e:	fff6079b          	addiw	a5,a2,-1
 222:	1782                	slli	a5,a5,0x20
 224:	9381                	srli	a5,a5,0x20
 226:	fff7c793          	not	a5,a5
 22a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 22c:	15fd                	addi	a1,a1,-1
 22e:	177d                	addi	a4,a4,-1
 230:	0005c683          	lbu	a3,0(a1)
 234:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 238:	fee79ae3          	bne	a5,a4,22c <memmove+0x46>
 23c:	bfc9                	j	20e <memmove+0x28>

000000000000023e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 23e:	1141                	addi	sp,sp,-16
 240:	e422                	sd	s0,8(sp)
 242:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 244:	ca05                	beqz	a2,274 <memcmp+0x36>
 246:	fff6069b          	addiw	a3,a2,-1
 24a:	1682                	slli	a3,a3,0x20
 24c:	9281                	srli	a3,a3,0x20
 24e:	0685                	addi	a3,a3,1
 250:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 252:	00054783          	lbu	a5,0(a0)
 256:	0005c703          	lbu	a4,0(a1)
 25a:	00e79863          	bne	a5,a4,26a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 25e:	0505                	addi	a0,a0,1
    p2++;
 260:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 262:	fed518e3          	bne	a0,a3,252 <memcmp+0x14>
  }
  return 0;
 266:	4501                	li	a0,0
 268:	a019                	j	26e <memcmp+0x30>
      return *p1 - *p2;
 26a:	40e7853b          	subw	a0,a5,a4
}
 26e:	6422                	ld	s0,8(sp)
 270:	0141                	addi	sp,sp,16
 272:	8082                	ret
  return 0;
 274:	4501                	li	a0,0
 276:	bfe5                	j	26e <memcmp+0x30>

0000000000000278 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 278:	1141                	addi	sp,sp,-16
 27a:	e406                	sd	ra,8(sp)
 27c:	e022                	sd	s0,0(sp)
 27e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 280:	00000097          	auipc	ra,0x0
 284:	f66080e7          	jalr	-154(ra) # 1e6 <memmove>
}
 288:	60a2                	ld	ra,8(sp)
 28a:	6402                	ld	s0,0(sp)
 28c:	0141                	addi	sp,sp,16
 28e:	8082                	ret

0000000000000290 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 290:	4885                	li	a7,1
 ecall
 292:	00000073          	ecall
 ret
 296:	8082                	ret

0000000000000298 <exit>:
.global exit
exit:
 li a7, SYS_exit
 298:	4889                	li	a7,2
 ecall
 29a:	00000073          	ecall
 ret
 29e:	8082                	ret

00000000000002a0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2a0:	488d                	li	a7,3
 ecall
 2a2:	00000073          	ecall
 ret
 2a6:	8082                	ret

00000000000002a8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2a8:	4891                	li	a7,4
 ecall
 2aa:	00000073          	ecall
 ret
 2ae:	8082                	ret

00000000000002b0 <read>:
.global read
read:
 li a7, SYS_read
 2b0:	4895                	li	a7,5
 ecall
 2b2:	00000073          	ecall
 ret
 2b6:	8082                	ret

00000000000002b8 <write>:
.global write
write:
 li a7, SYS_write
 2b8:	48c1                	li	a7,16
 ecall
 2ba:	00000073          	ecall
 ret
 2be:	8082                	ret

00000000000002c0 <close>:
.global close
close:
 li a7, SYS_close
 2c0:	48d5                	li	a7,21
 ecall
 2c2:	00000073          	ecall
 ret
 2c6:	8082                	ret

00000000000002c8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2c8:	4899                	li	a7,6
 ecall
 2ca:	00000073          	ecall
 ret
 2ce:	8082                	ret

00000000000002d0 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2d0:	489d                	li	a7,7
 ecall
 2d2:	00000073          	ecall
 ret
 2d6:	8082                	ret

00000000000002d8 <open>:
.global open
open:
 li a7, SYS_open
 2d8:	48bd                	li	a7,15
 ecall
 2da:	00000073          	ecall
 ret
 2de:	8082                	ret

00000000000002e0 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2e0:	48c5                	li	a7,17
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2e8:	48c9                	li	a7,18
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2f0:	48a1                	li	a7,8
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <link>:
.global link
link:
 li a7, SYS_link
 2f8:	48cd                	li	a7,19
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 300:	48d1                	li	a7,20
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 308:	48a5                	li	a7,9
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <dup>:
.global dup
dup:
 li a7, SYS_dup
 310:	48a9                	li	a7,10
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 318:	48ad                	li	a7,11
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 320:	48b1                	li	a7,12
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 328:	48b5                	li	a7,13
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 330:	48b9                	li	a7,14
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <trace>:
.global trace
trace:
 li a7, SYS_trace
 338:	48d9                	li	a7,22
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 340:	48dd                	li	a7,23
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 348:	1101                	addi	sp,sp,-32
 34a:	ec06                	sd	ra,24(sp)
 34c:	e822                	sd	s0,16(sp)
 34e:	1000                	addi	s0,sp,32
 350:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 354:	4605                	li	a2,1
 356:	fef40593          	addi	a1,s0,-17
 35a:	00000097          	auipc	ra,0x0
 35e:	f5e080e7          	jalr	-162(ra) # 2b8 <write>
}
 362:	60e2                	ld	ra,24(sp)
 364:	6442                	ld	s0,16(sp)
 366:	6105                	addi	sp,sp,32
 368:	8082                	ret

000000000000036a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 36a:	7139                	addi	sp,sp,-64
 36c:	fc06                	sd	ra,56(sp)
 36e:	f822                	sd	s0,48(sp)
 370:	f426                	sd	s1,40(sp)
 372:	f04a                	sd	s2,32(sp)
 374:	ec4e                	sd	s3,24(sp)
 376:	0080                	addi	s0,sp,64
 378:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 37a:	c299                	beqz	a3,380 <printint+0x16>
 37c:	0805c863          	bltz	a1,40c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 380:	2581                	sext.w	a1,a1
  neg = 0;
 382:	4881                	li	a7,0
 384:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 388:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 38a:	2601                	sext.w	a2,a2
 38c:	00000517          	auipc	a0,0x0
 390:	44450513          	addi	a0,a0,1092 # 7d0 <digits>
 394:	883a                	mv	a6,a4
 396:	2705                	addiw	a4,a4,1
 398:	02c5f7bb          	remuw	a5,a1,a2
 39c:	1782                	slli	a5,a5,0x20
 39e:	9381                	srli	a5,a5,0x20
 3a0:	97aa                	add	a5,a5,a0
 3a2:	0007c783          	lbu	a5,0(a5)
 3a6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3aa:	0005879b          	sext.w	a5,a1
 3ae:	02c5d5bb          	divuw	a1,a1,a2
 3b2:	0685                	addi	a3,a3,1
 3b4:	fec7f0e3          	bgeu	a5,a2,394 <printint+0x2a>
  if(neg)
 3b8:	00088b63          	beqz	a7,3ce <printint+0x64>
    buf[i++] = '-';
 3bc:	fd040793          	addi	a5,s0,-48
 3c0:	973e                	add	a4,a4,a5
 3c2:	02d00793          	li	a5,45
 3c6:	fef70823          	sb	a5,-16(a4)
 3ca:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3ce:	02e05863          	blez	a4,3fe <printint+0x94>
 3d2:	fc040793          	addi	a5,s0,-64
 3d6:	00e78933          	add	s2,a5,a4
 3da:	fff78993          	addi	s3,a5,-1
 3de:	99ba                	add	s3,s3,a4
 3e0:	377d                	addiw	a4,a4,-1
 3e2:	1702                	slli	a4,a4,0x20
 3e4:	9301                	srli	a4,a4,0x20
 3e6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3ea:	fff94583          	lbu	a1,-1(s2)
 3ee:	8526                	mv	a0,s1
 3f0:	00000097          	auipc	ra,0x0
 3f4:	f58080e7          	jalr	-168(ra) # 348 <putc>
  while(--i >= 0)
 3f8:	197d                	addi	s2,s2,-1
 3fa:	ff3918e3          	bne	s2,s3,3ea <printint+0x80>
}
 3fe:	70e2                	ld	ra,56(sp)
 400:	7442                	ld	s0,48(sp)
 402:	74a2                	ld	s1,40(sp)
 404:	7902                	ld	s2,32(sp)
 406:	69e2                	ld	s3,24(sp)
 408:	6121                	addi	sp,sp,64
 40a:	8082                	ret
    x = -xx;
 40c:	40b005bb          	negw	a1,a1
    neg = 1;
 410:	4885                	li	a7,1
    x = -xx;
 412:	bf8d                	j	384 <printint+0x1a>

0000000000000414 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 414:	7119                	addi	sp,sp,-128
 416:	fc86                	sd	ra,120(sp)
 418:	f8a2                	sd	s0,112(sp)
 41a:	f4a6                	sd	s1,104(sp)
 41c:	f0ca                	sd	s2,96(sp)
 41e:	ecce                	sd	s3,88(sp)
 420:	e8d2                	sd	s4,80(sp)
 422:	e4d6                	sd	s5,72(sp)
 424:	e0da                	sd	s6,64(sp)
 426:	fc5e                	sd	s7,56(sp)
 428:	f862                	sd	s8,48(sp)
 42a:	f466                	sd	s9,40(sp)
 42c:	f06a                	sd	s10,32(sp)
 42e:	ec6e                	sd	s11,24(sp)
 430:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 432:	0005c903          	lbu	s2,0(a1)
 436:	18090f63          	beqz	s2,5d4 <vprintf+0x1c0>
 43a:	8aaa                	mv	s5,a0
 43c:	8b32                	mv	s6,a2
 43e:	00158493          	addi	s1,a1,1
  state = 0;
 442:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 444:	02500a13          	li	s4,37
      if(c == 'd'){
 448:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 44c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 450:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 454:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 458:	00000b97          	auipc	s7,0x0
 45c:	378b8b93          	addi	s7,s7,888 # 7d0 <digits>
 460:	a839                	j	47e <vprintf+0x6a>
        putc(fd, c);
 462:	85ca                	mv	a1,s2
 464:	8556                	mv	a0,s5
 466:	00000097          	auipc	ra,0x0
 46a:	ee2080e7          	jalr	-286(ra) # 348 <putc>
 46e:	a019                	j	474 <vprintf+0x60>
    } else if(state == '%'){
 470:	01498f63          	beq	s3,s4,48e <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 474:	0485                	addi	s1,s1,1
 476:	fff4c903          	lbu	s2,-1(s1)
 47a:	14090d63          	beqz	s2,5d4 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 47e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 482:	fe0997e3          	bnez	s3,470 <vprintf+0x5c>
      if(c == '%'){
 486:	fd479ee3          	bne	a5,s4,462 <vprintf+0x4e>
        state = '%';
 48a:	89be                	mv	s3,a5
 48c:	b7e5                	j	474 <vprintf+0x60>
      if(c == 'd'){
 48e:	05878063          	beq	a5,s8,4ce <vprintf+0xba>
      } else if(c == 'l') {
 492:	05978c63          	beq	a5,s9,4ea <vprintf+0xd6>
      } else if(c == 'x') {
 496:	07a78863          	beq	a5,s10,506 <vprintf+0xf2>
      } else if(c == 'p') {
 49a:	09b78463          	beq	a5,s11,522 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 49e:	07300713          	li	a4,115
 4a2:	0ce78663          	beq	a5,a4,56e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4a6:	06300713          	li	a4,99
 4aa:	0ee78e63          	beq	a5,a4,5a6 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 4ae:	11478863          	beq	a5,s4,5be <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4b2:	85d2                	mv	a1,s4
 4b4:	8556                	mv	a0,s5
 4b6:	00000097          	auipc	ra,0x0
 4ba:	e92080e7          	jalr	-366(ra) # 348 <putc>
        putc(fd, c);
 4be:	85ca                	mv	a1,s2
 4c0:	8556                	mv	a0,s5
 4c2:	00000097          	auipc	ra,0x0
 4c6:	e86080e7          	jalr	-378(ra) # 348 <putc>
      }
      state = 0;
 4ca:	4981                	li	s3,0
 4cc:	b765                	j	474 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 4ce:	008b0913          	addi	s2,s6,8
 4d2:	4685                	li	a3,1
 4d4:	4629                	li	a2,10
 4d6:	000b2583          	lw	a1,0(s6)
 4da:	8556                	mv	a0,s5
 4dc:	00000097          	auipc	ra,0x0
 4e0:	e8e080e7          	jalr	-370(ra) # 36a <printint>
 4e4:	8b4a                	mv	s6,s2
      state = 0;
 4e6:	4981                	li	s3,0
 4e8:	b771                	j	474 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4ea:	008b0913          	addi	s2,s6,8
 4ee:	4681                	li	a3,0
 4f0:	4629                	li	a2,10
 4f2:	000b2583          	lw	a1,0(s6)
 4f6:	8556                	mv	a0,s5
 4f8:	00000097          	auipc	ra,0x0
 4fc:	e72080e7          	jalr	-398(ra) # 36a <printint>
 500:	8b4a                	mv	s6,s2
      state = 0;
 502:	4981                	li	s3,0
 504:	bf85                	j	474 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 506:	008b0913          	addi	s2,s6,8
 50a:	4681                	li	a3,0
 50c:	4641                	li	a2,16
 50e:	000b2583          	lw	a1,0(s6)
 512:	8556                	mv	a0,s5
 514:	00000097          	auipc	ra,0x0
 518:	e56080e7          	jalr	-426(ra) # 36a <printint>
 51c:	8b4a                	mv	s6,s2
      state = 0;
 51e:	4981                	li	s3,0
 520:	bf91                	j	474 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 522:	008b0793          	addi	a5,s6,8
 526:	f8f43423          	sd	a5,-120(s0)
 52a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 52e:	03000593          	li	a1,48
 532:	8556                	mv	a0,s5
 534:	00000097          	auipc	ra,0x0
 538:	e14080e7          	jalr	-492(ra) # 348 <putc>
  putc(fd, 'x');
 53c:	85ea                	mv	a1,s10
 53e:	8556                	mv	a0,s5
 540:	00000097          	auipc	ra,0x0
 544:	e08080e7          	jalr	-504(ra) # 348 <putc>
 548:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 54a:	03c9d793          	srli	a5,s3,0x3c
 54e:	97de                	add	a5,a5,s7
 550:	0007c583          	lbu	a1,0(a5)
 554:	8556                	mv	a0,s5
 556:	00000097          	auipc	ra,0x0
 55a:	df2080e7          	jalr	-526(ra) # 348 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 55e:	0992                	slli	s3,s3,0x4
 560:	397d                	addiw	s2,s2,-1
 562:	fe0914e3          	bnez	s2,54a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 566:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 56a:	4981                	li	s3,0
 56c:	b721                	j	474 <vprintf+0x60>
        s = va_arg(ap, char*);
 56e:	008b0993          	addi	s3,s6,8
 572:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 576:	02090163          	beqz	s2,598 <vprintf+0x184>
        while(*s != 0){
 57a:	00094583          	lbu	a1,0(s2)
 57e:	c9a1                	beqz	a1,5ce <vprintf+0x1ba>
          putc(fd, *s);
 580:	8556                	mv	a0,s5
 582:	00000097          	auipc	ra,0x0
 586:	dc6080e7          	jalr	-570(ra) # 348 <putc>
          s++;
 58a:	0905                	addi	s2,s2,1
        while(*s != 0){
 58c:	00094583          	lbu	a1,0(s2)
 590:	f9e5                	bnez	a1,580 <vprintf+0x16c>
        s = va_arg(ap, char*);
 592:	8b4e                	mv	s6,s3
      state = 0;
 594:	4981                	li	s3,0
 596:	bdf9                	j	474 <vprintf+0x60>
          s = "(null)";
 598:	00000917          	auipc	s2,0x0
 59c:	23090913          	addi	s2,s2,560 # 7c8 <malloc+0xea>
        while(*s != 0){
 5a0:	02800593          	li	a1,40
 5a4:	bff1                	j	580 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 5a6:	008b0913          	addi	s2,s6,8
 5aa:	000b4583          	lbu	a1,0(s6)
 5ae:	8556                	mv	a0,s5
 5b0:	00000097          	auipc	ra,0x0
 5b4:	d98080e7          	jalr	-616(ra) # 348 <putc>
 5b8:	8b4a                	mv	s6,s2
      state = 0;
 5ba:	4981                	li	s3,0
 5bc:	bd65                	j	474 <vprintf+0x60>
        putc(fd, c);
 5be:	85d2                	mv	a1,s4
 5c0:	8556                	mv	a0,s5
 5c2:	00000097          	auipc	ra,0x0
 5c6:	d86080e7          	jalr	-634(ra) # 348 <putc>
      state = 0;
 5ca:	4981                	li	s3,0
 5cc:	b565                	j	474 <vprintf+0x60>
        s = va_arg(ap, char*);
 5ce:	8b4e                	mv	s6,s3
      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	b54d                	j	474 <vprintf+0x60>
    }
  }
}
 5d4:	70e6                	ld	ra,120(sp)
 5d6:	7446                	ld	s0,112(sp)
 5d8:	74a6                	ld	s1,104(sp)
 5da:	7906                	ld	s2,96(sp)
 5dc:	69e6                	ld	s3,88(sp)
 5de:	6a46                	ld	s4,80(sp)
 5e0:	6aa6                	ld	s5,72(sp)
 5e2:	6b06                	ld	s6,64(sp)
 5e4:	7be2                	ld	s7,56(sp)
 5e6:	7c42                	ld	s8,48(sp)
 5e8:	7ca2                	ld	s9,40(sp)
 5ea:	7d02                	ld	s10,32(sp)
 5ec:	6de2                	ld	s11,24(sp)
 5ee:	6109                	addi	sp,sp,128
 5f0:	8082                	ret

00000000000005f2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 5f2:	715d                	addi	sp,sp,-80
 5f4:	ec06                	sd	ra,24(sp)
 5f6:	e822                	sd	s0,16(sp)
 5f8:	1000                	addi	s0,sp,32
 5fa:	e010                	sd	a2,0(s0)
 5fc:	e414                	sd	a3,8(s0)
 5fe:	e818                	sd	a4,16(s0)
 600:	ec1c                	sd	a5,24(s0)
 602:	03043023          	sd	a6,32(s0)
 606:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 60a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 60e:	8622                	mv	a2,s0
 610:	00000097          	auipc	ra,0x0
 614:	e04080e7          	jalr	-508(ra) # 414 <vprintf>
}
 618:	60e2                	ld	ra,24(sp)
 61a:	6442                	ld	s0,16(sp)
 61c:	6161                	addi	sp,sp,80
 61e:	8082                	ret

0000000000000620 <printf>:

void
printf(const char *fmt, ...)
{
 620:	711d                	addi	sp,sp,-96
 622:	ec06                	sd	ra,24(sp)
 624:	e822                	sd	s0,16(sp)
 626:	1000                	addi	s0,sp,32
 628:	e40c                	sd	a1,8(s0)
 62a:	e810                	sd	a2,16(s0)
 62c:	ec14                	sd	a3,24(s0)
 62e:	f018                	sd	a4,32(s0)
 630:	f41c                	sd	a5,40(s0)
 632:	03043823          	sd	a6,48(s0)
 636:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 63a:	00840613          	addi	a2,s0,8
 63e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 642:	85aa                	mv	a1,a0
 644:	4505                	li	a0,1
 646:	00000097          	auipc	ra,0x0
 64a:	dce080e7          	jalr	-562(ra) # 414 <vprintf>
}
 64e:	60e2                	ld	ra,24(sp)
 650:	6442                	ld	s0,16(sp)
 652:	6125                	addi	sp,sp,96
 654:	8082                	ret

0000000000000656 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 656:	1141                	addi	sp,sp,-16
 658:	e422                	sd	s0,8(sp)
 65a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 65c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 660:	00000797          	auipc	a5,0x0
 664:	1887b783          	ld	a5,392(a5) # 7e8 <freep>
 668:	a805                	j	698 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 66a:	4618                	lw	a4,8(a2)
 66c:	9db9                	addw	a1,a1,a4
 66e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 672:	6398                	ld	a4,0(a5)
 674:	6318                	ld	a4,0(a4)
 676:	fee53823          	sd	a4,-16(a0)
 67a:	a091                	j	6be <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 67c:	ff852703          	lw	a4,-8(a0)
 680:	9e39                	addw	a2,a2,a4
 682:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 684:	ff053703          	ld	a4,-16(a0)
 688:	e398                	sd	a4,0(a5)
 68a:	a099                	j	6d0 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 68c:	6398                	ld	a4,0(a5)
 68e:	00e7e463          	bltu	a5,a4,696 <free+0x40>
 692:	00e6ea63          	bltu	a3,a4,6a6 <free+0x50>
{
 696:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 698:	fed7fae3          	bgeu	a5,a3,68c <free+0x36>
 69c:	6398                	ld	a4,0(a5)
 69e:	00e6e463          	bltu	a3,a4,6a6 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6a2:	fee7eae3          	bltu	a5,a4,696 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 6a6:	ff852583          	lw	a1,-8(a0)
 6aa:	6390                	ld	a2,0(a5)
 6ac:	02059813          	slli	a6,a1,0x20
 6b0:	01c85713          	srli	a4,a6,0x1c
 6b4:	9736                	add	a4,a4,a3
 6b6:	fae60ae3          	beq	a2,a4,66a <free+0x14>
    bp->s.ptr = p->s.ptr;
 6ba:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6be:	4790                	lw	a2,8(a5)
 6c0:	02061593          	slli	a1,a2,0x20
 6c4:	01c5d713          	srli	a4,a1,0x1c
 6c8:	973e                	add	a4,a4,a5
 6ca:	fae689e3          	beq	a3,a4,67c <free+0x26>
  } else
    p->s.ptr = bp;
 6ce:	e394                	sd	a3,0(a5)
  freep = p;
 6d0:	00000717          	auipc	a4,0x0
 6d4:	10f73c23          	sd	a5,280(a4) # 7e8 <freep>
}
 6d8:	6422                	ld	s0,8(sp)
 6da:	0141                	addi	sp,sp,16
 6dc:	8082                	ret

00000000000006de <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6de:	7139                	addi	sp,sp,-64
 6e0:	fc06                	sd	ra,56(sp)
 6e2:	f822                	sd	s0,48(sp)
 6e4:	f426                	sd	s1,40(sp)
 6e6:	f04a                	sd	s2,32(sp)
 6e8:	ec4e                	sd	s3,24(sp)
 6ea:	e852                	sd	s4,16(sp)
 6ec:	e456                	sd	s5,8(sp)
 6ee:	e05a                	sd	s6,0(sp)
 6f0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6f2:	02051493          	slli	s1,a0,0x20
 6f6:	9081                	srli	s1,s1,0x20
 6f8:	04bd                	addi	s1,s1,15
 6fa:	8091                	srli	s1,s1,0x4
 6fc:	0014899b          	addiw	s3,s1,1
 700:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 702:	00000517          	auipc	a0,0x0
 706:	0e653503          	ld	a0,230(a0) # 7e8 <freep>
 70a:	c515                	beqz	a0,736 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 70c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 70e:	4798                	lw	a4,8(a5)
 710:	02977f63          	bgeu	a4,s1,74e <malloc+0x70>
 714:	8a4e                	mv	s4,s3
 716:	0009871b          	sext.w	a4,s3
 71a:	6685                	lui	a3,0x1
 71c:	00d77363          	bgeu	a4,a3,722 <malloc+0x44>
 720:	6a05                	lui	s4,0x1
 722:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 726:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 72a:	00000917          	auipc	s2,0x0
 72e:	0be90913          	addi	s2,s2,190 # 7e8 <freep>
  if(p == (char*)-1)
 732:	5afd                	li	s5,-1
 734:	a895                	j	7a8 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 736:	00000797          	auipc	a5,0x0
 73a:	0ba78793          	addi	a5,a5,186 # 7f0 <base>
 73e:	00000717          	auipc	a4,0x0
 742:	0af73523          	sd	a5,170(a4) # 7e8 <freep>
 746:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 748:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 74c:	b7e1                	j	714 <malloc+0x36>
      if(p->s.size == nunits)
 74e:	02e48c63          	beq	s1,a4,786 <malloc+0xa8>
        p->s.size -= nunits;
 752:	4137073b          	subw	a4,a4,s3
 756:	c798                	sw	a4,8(a5)
        p += p->s.size;
 758:	02071693          	slli	a3,a4,0x20
 75c:	01c6d713          	srli	a4,a3,0x1c
 760:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 762:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 766:	00000717          	auipc	a4,0x0
 76a:	08a73123          	sd	a0,130(a4) # 7e8 <freep>
      return (void*)(p + 1);
 76e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 772:	70e2                	ld	ra,56(sp)
 774:	7442                	ld	s0,48(sp)
 776:	74a2                	ld	s1,40(sp)
 778:	7902                	ld	s2,32(sp)
 77a:	69e2                	ld	s3,24(sp)
 77c:	6a42                	ld	s4,16(sp)
 77e:	6aa2                	ld	s5,8(sp)
 780:	6b02                	ld	s6,0(sp)
 782:	6121                	addi	sp,sp,64
 784:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 786:	6398                	ld	a4,0(a5)
 788:	e118                	sd	a4,0(a0)
 78a:	bff1                	j	766 <malloc+0x88>
  hp->s.size = nu;
 78c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 790:	0541                	addi	a0,a0,16
 792:	00000097          	auipc	ra,0x0
 796:	ec4080e7          	jalr	-316(ra) # 656 <free>
  return freep;
 79a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 79e:	d971                	beqz	a0,772 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7a2:	4798                	lw	a4,8(a5)
 7a4:	fa9775e3          	bgeu	a4,s1,74e <malloc+0x70>
    if(p == freep)
 7a8:	00093703          	ld	a4,0(s2)
 7ac:	853e                	mv	a0,a5
 7ae:	fef719e3          	bne	a4,a5,7a0 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 7b2:	8552                	mv	a0,s4
 7b4:	00000097          	auipc	ra,0x0
 7b8:	b6c080e7          	jalr	-1172(ra) # 320 <sbrk>
  if(p == (char*)-1)
 7bc:	fd5518e3          	bne	a0,s5,78c <malloc+0xae>
        return 0;
 7c0:	4501                	li	a0,0
 7c2:	bf45                	j	772 <malloc+0x94>
