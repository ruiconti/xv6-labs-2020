
user/_echo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	addi	s0,sp,48
  int i;

  for(i = 1; i < argc; i++){
  10:	4785                	li	a5,1
  12:	06a7d463          	bge	a5,a0,7a <main+0x7a>
  16:	00858493          	addi	s1,a1,8
  1a:	ffe5099b          	addiw	s3,a0,-2
  1e:	02099793          	slli	a5,s3,0x20
  22:	01d7d993          	srli	s3,a5,0x1d
  26:	05c1                	addi	a1,a1,16
  28:	99ae                	add	s3,s3,a1
    write(1, argv[i], strlen(argv[i]));
    if(i + 1 < argc){
      write(1, " ", 1);
  2a:	00000a17          	auipc	s4,0x0
  2e:	7f6a0a13          	addi	s4,s4,2038 # 820 <malloc+0xe8>
    write(1, argv[i], strlen(argv[i]));
  32:	0004b903          	ld	s2,0(s1)
  36:	854a                	mv	a0,s2
  38:	00000097          	auipc	ra,0x0
  3c:	094080e7          	jalr	148(ra) # cc <strlen>
  40:	0005061b          	sext.w	a2,a0
  44:	85ca                	mv	a1,s2
  46:	4505                	li	a0,1
  48:	00000097          	auipc	ra,0x0
  4c:	2ca080e7          	jalr	714(ra) # 312 <write>
    if(i + 1 < argc){
  50:	04a1                	addi	s1,s1,8
  52:	01348a63          	beq	s1,s3,66 <main+0x66>
      write(1, " ", 1);
  56:	4605                	li	a2,1
  58:	85d2                	mv	a1,s4
  5a:	4505                	li	a0,1
  5c:	00000097          	auipc	ra,0x0
  60:	2b6080e7          	jalr	694(ra) # 312 <write>
  for(i = 1; i < argc; i++){
  64:	b7f9                	j	32 <main+0x32>
    } else {
      write(1, "\n", 1);
  66:	4605                	li	a2,1
  68:	00000597          	auipc	a1,0x0
  6c:	7c058593          	addi	a1,a1,1984 # 828 <malloc+0xf0>
  70:	4505                	li	a0,1
  72:	00000097          	auipc	ra,0x0
  76:	2a0080e7          	jalr	672(ra) # 312 <write>
    }
  }
  exit(0);
  7a:	4501                	li	a0,0
  7c:	00000097          	auipc	ra,0x0
  80:	276080e7          	jalr	630(ra) # 2f2 <exit>

0000000000000084 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
  84:	1141                	addi	sp,sp,-16
  86:	e422                	sd	s0,8(sp)
  88:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  8a:	87aa                	mv	a5,a0
  8c:	0585                	addi	a1,a1,1
  8e:	0785                	addi	a5,a5,1
  90:	fff5c703          	lbu	a4,-1(a1)
  94:	fee78fa3          	sb	a4,-1(a5)
  98:	fb75                	bnez	a4,8c <strcpy+0x8>
    ;
  return os;
}
  9a:	6422                	ld	s0,8(sp)
  9c:	0141                	addi	sp,sp,16
  9e:	8082                	ret

00000000000000a0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e422                	sd	s0,8(sp)
  a4:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  a6:	00054783          	lbu	a5,0(a0)
  aa:	cb91                	beqz	a5,be <strcmp+0x1e>
  ac:	0005c703          	lbu	a4,0(a1)
  b0:	00f71763          	bne	a4,a5,be <strcmp+0x1e>
    p++, q++;
  b4:	0505                	addi	a0,a0,1
  b6:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  b8:	00054783          	lbu	a5,0(a0)
  bc:	fbe5                	bnez	a5,ac <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  be:	0005c503          	lbu	a0,0(a1)
}
  c2:	40a7853b          	subw	a0,a5,a0
  c6:	6422                	ld	s0,8(sp)
  c8:	0141                	addi	sp,sp,16
  ca:	8082                	ret

00000000000000cc <strlen>:

uint
strlen(const char *s)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e422                	sd	s0,8(sp)
  d0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  d2:	00054783          	lbu	a5,0(a0)
  d6:	cf91                	beqz	a5,f2 <strlen+0x26>
  d8:	0505                	addi	a0,a0,1
  da:	87aa                	mv	a5,a0
  dc:	4685                	li	a3,1
  de:	9e89                	subw	a3,a3,a0
  e0:	00f6853b          	addw	a0,a3,a5
  e4:	0785                	addi	a5,a5,1
  e6:	fff7c703          	lbu	a4,-1(a5)
  ea:	fb7d                	bnez	a4,e0 <strlen+0x14>
    ;
  return n;
}
  ec:	6422                	ld	s0,8(sp)
  ee:	0141                	addi	sp,sp,16
  f0:	8082                	ret
  for(n = 0; s[n]; n++)
  f2:	4501                	li	a0,0
  f4:	bfe5                	j	ec <strlen+0x20>

00000000000000f6 <memset>:

void*
memset(void *dst, int c, uint n)
{
  f6:	1141                	addi	sp,sp,-16
  f8:	e422                	sd	s0,8(sp)
  fa:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  fc:	ca19                	beqz	a2,112 <memset+0x1c>
  fe:	87aa                	mv	a5,a0
 100:	1602                	slli	a2,a2,0x20
 102:	9201                	srli	a2,a2,0x20
 104:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 108:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 10c:	0785                	addi	a5,a5,1
 10e:	fee79de3          	bne	a5,a4,108 <memset+0x12>
  }
  return dst;
}
 112:	6422                	ld	s0,8(sp)
 114:	0141                	addi	sp,sp,16
 116:	8082                	ret

0000000000000118 <strchr>:

char*
strchr(const char *s, char c)
{
 118:	1141                	addi	sp,sp,-16
 11a:	e422                	sd	s0,8(sp)
 11c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 11e:	00054783          	lbu	a5,0(a0)
 122:	cb99                	beqz	a5,138 <strchr+0x20>
    if(*s == c)
 124:	00f58763          	beq	a1,a5,132 <strchr+0x1a>
  for(; *s; s++)
 128:	0505                	addi	a0,a0,1
 12a:	00054783          	lbu	a5,0(a0)
 12e:	fbfd                	bnez	a5,124 <strchr+0xc>
      return (char*)s;
  return 0;
 130:	4501                	li	a0,0
}
 132:	6422                	ld	s0,8(sp)
 134:	0141                	addi	sp,sp,16
 136:	8082                	ret
  return 0;
 138:	4501                	li	a0,0
 13a:	bfe5                	j	132 <strchr+0x1a>

000000000000013c <gets>:

char*
gets(char *buf, int max)
{
 13c:	711d                	addi	sp,sp,-96
 13e:	ec86                	sd	ra,88(sp)
 140:	e8a2                	sd	s0,80(sp)
 142:	e4a6                	sd	s1,72(sp)
 144:	e0ca                	sd	s2,64(sp)
 146:	fc4e                	sd	s3,56(sp)
 148:	f852                	sd	s4,48(sp)
 14a:	f456                	sd	s5,40(sp)
 14c:	f05a                	sd	s6,32(sp)
 14e:	ec5e                	sd	s7,24(sp)
 150:	1080                	addi	s0,sp,96
 152:	8baa                	mv	s7,a0
 154:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 156:	892a                	mv	s2,a0
 158:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 15a:	4aa9                	li	s5,10
 15c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 15e:	89a6                	mv	s3,s1
 160:	2485                	addiw	s1,s1,1
 162:	0344d863          	bge	s1,s4,192 <gets+0x56>
    cc = read(0, &c, 1);
 166:	4605                	li	a2,1
 168:	faf40593          	addi	a1,s0,-81
 16c:	4501                	li	a0,0
 16e:	00000097          	auipc	ra,0x0
 172:	19c080e7          	jalr	412(ra) # 30a <read>
    if(cc < 1)
 176:	00a05e63          	blez	a0,192 <gets+0x56>
    buf[i++] = c;
 17a:	faf44783          	lbu	a5,-81(s0)
 17e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 182:	01578763          	beq	a5,s5,190 <gets+0x54>
 186:	0905                	addi	s2,s2,1
 188:	fd679be3          	bne	a5,s6,15e <gets+0x22>
  for(i=0; i+1 < max; ){
 18c:	89a6                	mv	s3,s1
 18e:	a011                	j	192 <gets+0x56>
 190:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 192:	99de                	add	s3,s3,s7
 194:	00098023          	sb	zero,0(s3)
  return buf;
}
 198:	855e                	mv	a0,s7
 19a:	60e6                	ld	ra,88(sp)
 19c:	6446                	ld	s0,80(sp)
 19e:	64a6                	ld	s1,72(sp)
 1a0:	6906                	ld	s2,64(sp)
 1a2:	79e2                	ld	s3,56(sp)
 1a4:	7a42                	ld	s4,48(sp)
 1a6:	7aa2                	ld	s5,40(sp)
 1a8:	7b02                	ld	s6,32(sp)
 1aa:	6be2                	ld	s7,24(sp)
 1ac:	6125                	addi	sp,sp,96
 1ae:	8082                	ret

00000000000001b0 <stat>:

int
stat(const char *n, struct stat *st)
{
 1b0:	1101                	addi	sp,sp,-32
 1b2:	ec06                	sd	ra,24(sp)
 1b4:	e822                	sd	s0,16(sp)
 1b6:	e426                	sd	s1,8(sp)
 1b8:	e04a                	sd	s2,0(sp)
 1ba:	1000                	addi	s0,sp,32
 1bc:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1be:	4581                	li	a1,0
 1c0:	00000097          	auipc	ra,0x0
 1c4:	172080e7          	jalr	370(ra) # 332 <open>
  if(fd < 0)
 1c8:	02054563          	bltz	a0,1f2 <stat+0x42>
 1cc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ce:	85ca                	mv	a1,s2
 1d0:	00000097          	auipc	ra,0x0
 1d4:	17a080e7          	jalr	378(ra) # 34a <fstat>
 1d8:	892a                	mv	s2,a0
  close(fd);
 1da:	8526                	mv	a0,s1
 1dc:	00000097          	auipc	ra,0x0
 1e0:	13e080e7          	jalr	318(ra) # 31a <close>
  return r;
}
 1e4:	854a                	mv	a0,s2
 1e6:	60e2                	ld	ra,24(sp)
 1e8:	6442                	ld	s0,16(sp)
 1ea:	64a2                	ld	s1,8(sp)
 1ec:	6902                	ld	s2,0(sp)
 1ee:	6105                	addi	sp,sp,32
 1f0:	8082                	ret
    return -1;
 1f2:	597d                	li	s2,-1
 1f4:	bfc5                	j	1e4 <stat+0x34>

00000000000001f6 <atoi>:

int
atoi(const char *s)
{
 1f6:	1141                	addi	sp,sp,-16
 1f8:	e422                	sd	s0,8(sp)
 1fa:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1fc:	00054603          	lbu	a2,0(a0)
 200:	fd06079b          	addiw	a5,a2,-48
 204:	0ff7f793          	andi	a5,a5,255
 208:	4725                	li	a4,9
 20a:	02f76963          	bltu	a4,a5,23c <atoi+0x46>
 20e:	86aa                	mv	a3,a0
  n = 0;
 210:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 212:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 214:	0685                	addi	a3,a3,1
 216:	0025179b          	slliw	a5,a0,0x2
 21a:	9fa9                	addw	a5,a5,a0
 21c:	0017979b          	slliw	a5,a5,0x1
 220:	9fb1                	addw	a5,a5,a2
 222:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 226:	0006c603          	lbu	a2,0(a3)
 22a:	fd06071b          	addiw	a4,a2,-48
 22e:	0ff77713          	andi	a4,a4,255
 232:	fee5f1e3          	bgeu	a1,a4,214 <atoi+0x1e>
  return n;
}
 236:	6422                	ld	s0,8(sp)
 238:	0141                	addi	sp,sp,16
 23a:	8082                	ret
  n = 0;
 23c:	4501                	li	a0,0
 23e:	bfe5                	j	236 <atoi+0x40>

0000000000000240 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 240:	1141                	addi	sp,sp,-16
 242:	e422                	sd	s0,8(sp)
 244:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 246:	02b57463          	bgeu	a0,a1,26e <memmove+0x2e>
    while(n-- > 0)
 24a:	00c05f63          	blez	a2,268 <memmove+0x28>
 24e:	1602                	slli	a2,a2,0x20
 250:	9201                	srli	a2,a2,0x20
 252:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 256:	872a                	mv	a4,a0
      *dst++ = *src++;
 258:	0585                	addi	a1,a1,1
 25a:	0705                	addi	a4,a4,1
 25c:	fff5c683          	lbu	a3,-1(a1)
 260:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 264:	fee79ae3          	bne	a5,a4,258 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 268:	6422                	ld	s0,8(sp)
 26a:	0141                	addi	sp,sp,16
 26c:	8082                	ret
    dst += n;
 26e:	00c50733          	add	a4,a0,a2
    src += n;
 272:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 274:	fec05ae3          	blez	a2,268 <memmove+0x28>
 278:	fff6079b          	addiw	a5,a2,-1
 27c:	1782                	slli	a5,a5,0x20
 27e:	9381                	srli	a5,a5,0x20
 280:	fff7c793          	not	a5,a5
 284:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 286:	15fd                	addi	a1,a1,-1
 288:	177d                	addi	a4,a4,-1
 28a:	0005c683          	lbu	a3,0(a1)
 28e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 292:	fee79ae3          	bne	a5,a4,286 <memmove+0x46>
 296:	bfc9                	j	268 <memmove+0x28>

0000000000000298 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 29e:	ca05                	beqz	a2,2ce <memcmp+0x36>
 2a0:	fff6069b          	addiw	a3,a2,-1
 2a4:	1682                	slli	a3,a3,0x20
 2a6:	9281                	srli	a3,a3,0x20
 2a8:	0685                	addi	a3,a3,1
 2aa:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2ac:	00054783          	lbu	a5,0(a0)
 2b0:	0005c703          	lbu	a4,0(a1)
 2b4:	00e79863          	bne	a5,a4,2c4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2b8:	0505                	addi	a0,a0,1
    p2++;
 2ba:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2bc:	fed518e3          	bne	a0,a3,2ac <memcmp+0x14>
  }
  return 0;
 2c0:	4501                	li	a0,0
 2c2:	a019                	j	2c8 <memcmp+0x30>
      return *p1 - *p2;
 2c4:	40e7853b          	subw	a0,a5,a4
}
 2c8:	6422                	ld	s0,8(sp)
 2ca:	0141                	addi	sp,sp,16
 2cc:	8082                	ret
  return 0;
 2ce:	4501                	li	a0,0
 2d0:	bfe5                	j	2c8 <memcmp+0x30>

00000000000002d2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2d2:	1141                	addi	sp,sp,-16
 2d4:	e406                	sd	ra,8(sp)
 2d6:	e022                	sd	s0,0(sp)
 2d8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2da:	00000097          	auipc	ra,0x0
 2de:	f66080e7          	jalr	-154(ra) # 240 <memmove>
}
 2e2:	60a2                	ld	ra,8(sp)
 2e4:	6402                	ld	s0,0(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret

00000000000002ea <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2ea:	4885                	li	a7,1
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2f2:	4889                	li	a7,2
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <wait>:
.global wait
wait:
 li a7, SYS_wait
 2fa:	488d                	li	a7,3
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 302:	4891                	li	a7,4
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <read>:
.global read
read:
 li a7, SYS_read
 30a:	4895                	li	a7,5
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <write>:
.global write
write:
 li a7, SYS_write
 312:	48c1                	li	a7,16
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <close>:
.global close
close:
 li a7, SYS_close
 31a:	48d5                	li	a7,21
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <kill>:
.global kill
kill:
 li a7, SYS_kill
 322:	4899                	li	a7,6
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <exec>:
.global exec
exec:
 li a7, SYS_exec
 32a:	489d                	li	a7,7
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <open>:
.global open
open:
 li a7, SYS_open
 332:	48bd                	li	a7,15
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 33a:	48c5                	li	a7,17
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 342:	48c9                	li	a7,18
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 34a:	48a1                	li	a7,8
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <link>:
.global link
link:
 li a7, SYS_link
 352:	48cd                	li	a7,19
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 35a:	48d1                	li	a7,20
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 362:	48a5                	li	a7,9
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <dup>:
.global dup
dup:
 li a7, SYS_dup
 36a:	48a9                	li	a7,10
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 372:	48ad                	li	a7,11
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 37a:	48b1                	li	a7,12
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 382:	48b5                	li	a7,13
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 38a:	48b9                	li	a7,14
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <trace>:
.global trace
trace:
 li a7, SYS_trace
 392:	48d9                	li	a7,22
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 39a:	48dd                	li	a7,23
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3a2:	1101                	addi	sp,sp,-32
 3a4:	ec06                	sd	ra,24(sp)
 3a6:	e822                	sd	s0,16(sp)
 3a8:	1000                	addi	s0,sp,32
 3aa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3ae:	4605                	li	a2,1
 3b0:	fef40593          	addi	a1,s0,-17
 3b4:	00000097          	auipc	ra,0x0
 3b8:	f5e080e7          	jalr	-162(ra) # 312 <write>
}
 3bc:	60e2                	ld	ra,24(sp)
 3be:	6442                	ld	s0,16(sp)
 3c0:	6105                	addi	sp,sp,32
 3c2:	8082                	ret

00000000000003c4 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3c4:	7139                	addi	sp,sp,-64
 3c6:	fc06                	sd	ra,56(sp)
 3c8:	f822                	sd	s0,48(sp)
 3ca:	f426                	sd	s1,40(sp)
 3cc:	f04a                	sd	s2,32(sp)
 3ce:	ec4e                	sd	s3,24(sp)
 3d0:	0080                	addi	s0,sp,64
 3d2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3d4:	c299                	beqz	a3,3da <printint+0x16>
 3d6:	0805c863          	bltz	a1,466 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3da:	2581                	sext.w	a1,a1
  neg = 0;
 3dc:	4881                	li	a7,0
 3de:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3e2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3e4:	2601                	sext.w	a2,a2
 3e6:	00000517          	auipc	a0,0x0
 3ea:	45250513          	addi	a0,a0,1106 # 838 <digits>
 3ee:	883a                	mv	a6,a4
 3f0:	2705                	addiw	a4,a4,1
 3f2:	02c5f7bb          	remuw	a5,a1,a2
 3f6:	1782                	slli	a5,a5,0x20
 3f8:	9381                	srli	a5,a5,0x20
 3fa:	97aa                	add	a5,a5,a0
 3fc:	0007c783          	lbu	a5,0(a5)
 400:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 404:	0005879b          	sext.w	a5,a1
 408:	02c5d5bb          	divuw	a1,a1,a2
 40c:	0685                	addi	a3,a3,1
 40e:	fec7f0e3          	bgeu	a5,a2,3ee <printint+0x2a>
  if(neg)
 412:	00088b63          	beqz	a7,428 <printint+0x64>
    buf[i++] = '-';
 416:	fd040793          	addi	a5,s0,-48
 41a:	973e                	add	a4,a4,a5
 41c:	02d00793          	li	a5,45
 420:	fef70823          	sb	a5,-16(a4)
 424:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 428:	02e05863          	blez	a4,458 <printint+0x94>
 42c:	fc040793          	addi	a5,s0,-64
 430:	00e78933          	add	s2,a5,a4
 434:	fff78993          	addi	s3,a5,-1
 438:	99ba                	add	s3,s3,a4
 43a:	377d                	addiw	a4,a4,-1
 43c:	1702                	slli	a4,a4,0x20
 43e:	9301                	srli	a4,a4,0x20
 440:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 444:	fff94583          	lbu	a1,-1(s2)
 448:	8526                	mv	a0,s1
 44a:	00000097          	auipc	ra,0x0
 44e:	f58080e7          	jalr	-168(ra) # 3a2 <putc>
  while(--i >= 0)
 452:	197d                	addi	s2,s2,-1
 454:	ff3918e3          	bne	s2,s3,444 <printint+0x80>
}
 458:	70e2                	ld	ra,56(sp)
 45a:	7442                	ld	s0,48(sp)
 45c:	74a2                	ld	s1,40(sp)
 45e:	7902                	ld	s2,32(sp)
 460:	69e2                	ld	s3,24(sp)
 462:	6121                	addi	sp,sp,64
 464:	8082                	ret
    x = -xx;
 466:	40b005bb          	negw	a1,a1
    neg = 1;
 46a:	4885                	li	a7,1
    x = -xx;
 46c:	bf8d                	j	3de <printint+0x1a>

000000000000046e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 46e:	7119                	addi	sp,sp,-128
 470:	fc86                	sd	ra,120(sp)
 472:	f8a2                	sd	s0,112(sp)
 474:	f4a6                	sd	s1,104(sp)
 476:	f0ca                	sd	s2,96(sp)
 478:	ecce                	sd	s3,88(sp)
 47a:	e8d2                	sd	s4,80(sp)
 47c:	e4d6                	sd	s5,72(sp)
 47e:	e0da                	sd	s6,64(sp)
 480:	fc5e                	sd	s7,56(sp)
 482:	f862                	sd	s8,48(sp)
 484:	f466                	sd	s9,40(sp)
 486:	f06a                	sd	s10,32(sp)
 488:	ec6e                	sd	s11,24(sp)
 48a:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 48c:	0005c903          	lbu	s2,0(a1)
 490:	18090f63          	beqz	s2,62e <vprintf+0x1c0>
 494:	8aaa                	mv	s5,a0
 496:	8b32                	mv	s6,a2
 498:	00158493          	addi	s1,a1,1
  state = 0;
 49c:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 49e:	02500a13          	li	s4,37
      if(c == 'd'){
 4a2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 4a6:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 4aa:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 4ae:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 4b2:	00000b97          	auipc	s7,0x0
 4b6:	386b8b93          	addi	s7,s7,902 # 838 <digits>
 4ba:	a839                	j	4d8 <vprintf+0x6a>
        putc(fd, c);
 4bc:	85ca                	mv	a1,s2
 4be:	8556                	mv	a0,s5
 4c0:	00000097          	auipc	ra,0x0
 4c4:	ee2080e7          	jalr	-286(ra) # 3a2 <putc>
 4c8:	a019                	j	4ce <vprintf+0x60>
    } else if(state == '%'){
 4ca:	01498f63          	beq	s3,s4,4e8 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 4ce:	0485                	addi	s1,s1,1
 4d0:	fff4c903          	lbu	s2,-1(s1)
 4d4:	14090d63          	beqz	s2,62e <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 4d8:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4dc:	fe0997e3          	bnez	s3,4ca <vprintf+0x5c>
      if(c == '%'){
 4e0:	fd479ee3          	bne	a5,s4,4bc <vprintf+0x4e>
        state = '%';
 4e4:	89be                	mv	s3,a5
 4e6:	b7e5                	j	4ce <vprintf+0x60>
      if(c == 'd'){
 4e8:	05878063          	beq	a5,s8,528 <vprintf+0xba>
      } else if(c == 'l') {
 4ec:	05978c63          	beq	a5,s9,544 <vprintf+0xd6>
      } else if(c == 'x') {
 4f0:	07a78863          	beq	a5,s10,560 <vprintf+0xf2>
      } else if(c == 'p') {
 4f4:	09b78463          	beq	a5,s11,57c <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 4f8:	07300713          	li	a4,115
 4fc:	0ce78663          	beq	a5,a4,5c8 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 500:	06300713          	li	a4,99
 504:	0ee78e63          	beq	a5,a4,600 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 508:	11478863          	beq	a5,s4,618 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 50c:	85d2                	mv	a1,s4
 50e:	8556                	mv	a0,s5
 510:	00000097          	auipc	ra,0x0
 514:	e92080e7          	jalr	-366(ra) # 3a2 <putc>
        putc(fd, c);
 518:	85ca                	mv	a1,s2
 51a:	8556                	mv	a0,s5
 51c:	00000097          	auipc	ra,0x0
 520:	e86080e7          	jalr	-378(ra) # 3a2 <putc>
      }
      state = 0;
 524:	4981                	li	s3,0
 526:	b765                	j	4ce <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 528:	008b0913          	addi	s2,s6,8
 52c:	4685                	li	a3,1
 52e:	4629                	li	a2,10
 530:	000b2583          	lw	a1,0(s6)
 534:	8556                	mv	a0,s5
 536:	00000097          	auipc	ra,0x0
 53a:	e8e080e7          	jalr	-370(ra) # 3c4 <printint>
 53e:	8b4a                	mv	s6,s2
      state = 0;
 540:	4981                	li	s3,0
 542:	b771                	j	4ce <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 544:	008b0913          	addi	s2,s6,8
 548:	4681                	li	a3,0
 54a:	4629                	li	a2,10
 54c:	000b2583          	lw	a1,0(s6)
 550:	8556                	mv	a0,s5
 552:	00000097          	auipc	ra,0x0
 556:	e72080e7          	jalr	-398(ra) # 3c4 <printint>
 55a:	8b4a                	mv	s6,s2
      state = 0;
 55c:	4981                	li	s3,0
 55e:	bf85                	j	4ce <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 560:	008b0913          	addi	s2,s6,8
 564:	4681                	li	a3,0
 566:	4641                	li	a2,16
 568:	000b2583          	lw	a1,0(s6)
 56c:	8556                	mv	a0,s5
 56e:	00000097          	auipc	ra,0x0
 572:	e56080e7          	jalr	-426(ra) # 3c4 <printint>
 576:	8b4a                	mv	s6,s2
      state = 0;
 578:	4981                	li	s3,0
 57a:	bf91                	j	4ce <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 57c:	008b0793          	addi	a5,s6,8
 580:	f8f43423          	sd	a5,-120(s0)
 584:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 588:	03000593          	li	a1,48
 58c:	8556                	mv	a0,s5
 58e:	00000097          	auipc	ra,0x0
 592:	e14080e7          	jalr	-492(ra) # 3a2 <putc>
  putc(fd, 'x');
 596:	85ea                	mv	a1,s10
 598:	8556                	mv	a0,s5
 59a:	00000097          	auipc	ra,0x0
 59e:	e08080e7          	jalr	-504(ra) # 3a2 <putc>
 5a2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5a4:	03c9d793          	srli	a5,s3,0x3c
 5a8:	97de                	add	a5,a5,s7
 5aa:	0007c583          	lbu	a1,0(a5)
 5ae:	8556                	mv	a0,s5
 5b0:	00000097          	auipc	ra,0x0
 5b4:	df2080e7          	jalr	-526(ra) # 3a2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5b8:	0992                	slli	s3,s3,0x4
 5ba:	397d                	addiw	s2,s2,-1
 5bc:	fe0914e3          	bnez	s2,5a4 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 5c0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 5c4:	4981                	li	s3,0
 5c6:	b721                	j	4ce <vprintf+0x60>
        s = va_arg(ap, char*);
 5c8:	008b0993          	addi	s3,s6,8
 5cc:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 5d0:	02090163          	beqz	s2,5f2 <vprintf+0x184>
        while(*s != 0){
 5d4:	00094583          	lbu	a1,0(s2)
 5d8:	c9a1                	beqz	a1,628 <vprintf+0x1ba>
          putc(fd, *s);
 5da:	8556                	mv	a0,s5
 5dc:	00000097          	auipc	ra,0x0
 5e0:	dc6080e7          	jalr	-570(ra) # 3a2 <putc>
          s++;
 5e4:	0905                	addi	s2,s2,1
        while(*s != 0){
 5e6:	00094583          	lbu	a1,0(s2)
 5ea:	f9e5                	bnez	a1,5da <vprintf+0x16c>
        s = va_arg(ap, char*);
 5ec:	8b4e                	mv	s6,s3
      state = 0;
 5ee:	4981                	li	s3,0
 5f0:	bdf9                	j	4ce <vprintf+0x60>
          s = "(null)";
 5f2:	00000917          	auipc	s2,0x0
 5f6:	23e90913          	addi	s2,s2,574 # 830 <malloc+0xf8>
        while(*s != 0){
 5fa:	02800593          	li	a1,40
 5fe:	bff1                	j	5da <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 600:	008b0913          	addi	s2,s6,8
 604:	000b4583          	lbu	a1,0(s6)
 608:	8556                	mv	a0,s5
 60a:	00000097          	auipc	ra,0x0
 60e:	d98080e7          	jalr	-616(ra) # 3a2 <putc>
 612:	8b4a                	mv	s6,s2
      state = 0;
 614:	4981                	li	s3,0
 616:	bd65                	j	4ce <vprintf+0x60>
        putc(fd, c);
 618:	85d2                	mv	a1,s4
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	d86080e7          	jalr	-634(ra) # 3a2 <putc>
      state = 0;
 624:	4981                	li	s3,0
 626:	b565                	j	4ce <vprintf+0x60>
        s = va_arg(ap, char*);
 628:	8b4e                	mv	s6,s3
      state = 0;
 62a:	4981                	li	s3,0
 62c:	b54d                	j	4ce <vprintf+0x60>
    }
  }
}
 62e:	70e6                	ld	ra,120(sp)
 630:	7446                	ld	s0,112(sp)
 632:	74a6                	ld	s1,104(sp)
 634:	7906                	ld	s2,96(sp)
 636:	69e6                	ld	s3,88(sp)
 638:	6a46                	ld	s4,80(sp)
 63a:	6aa6                	ld	s5,72(sp)
 63c:	6b06                	ld	s6,64(sp)
 63e:	7be2                	ld	s7,56(sp)
 640:	7c42                	ld	s8,48(sp)
 642:	7ca2                	ld	s9,40(sp)
 644:	7d02                	ld	s10,32(sp)
 646:	6de2                	ld	s11,24(sp)
 648:	6109                	addi	sp,sp,128
 64a:	8082                	ret

000000000000064c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 64c:	715d                	addi	sp,sp,-80
 64e:	ec06                	sd	ra,24(sp)
 650:	e822                	sd	s0,16(sp)
 652:	1000                	addi	s0,sp,32
 654:	e010                	sd	a2,0(s0)
 656:	e414                	sd	a3,8(s0)
 658:	e818                	sd	a4,16(s0)
 65a:	ec1c                	sd	a5,24(s0)
 65c:	03043023          	sd	a6,32(s0)
 660:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 664:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 668:	8622                	mv	a2,s0
 66a:	00000097          	auipc	ra,0x0
 66e:	e04080e7          	jalr	-508(ra) # 46e <vprintf>
}
 672:	60e2                	ld	ra,24(sp)
 674:	6442                	ld	s0,16(sp)
 676:	6161                	addi	sp,sp,80
 678:	8082                	ret

000000000000067a <printf>:

void
printf(const char *fmt, ...)
{
 67a:	711d                	addi	sp,sp,-96
 67c:	ec06                	sd	ra,24(sp)
 67e:	e822                	sd	s0,16(sp)
 680:	1000                	addi	s0,sp,32
 682:	e40c                	sd	a1,8(s0)
 684:	e810                	sd	a2,16(s0)
 686:	ec14                	sd	a3,24(s0)
 688:	f018                	sd	a4,32(s0)
 68a:	f41c                	sd	a5,40(s0)
 68c:	03043823          	sd	a6,48(s0)
 690:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 694:	00840613          	addi	a2,s0,8
 698:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 69c:	85aa                	mv	a1,a0
 69e:	4505                	li	a0,1
 6a0:	00000097          	auipc	ra,0x0
 6a4:	dce080e7          	jalr	-562(ra) # 46e <vprintf>
}
 6a8:	60e2                	ld	ra,24(sp)
 6aa:	6442                	ld	s0,16(sp)
 6ac:	6125                	addi	sp,sp,96
 6ae:	8082                	ret

00000000000006b0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6b0:	1141                	addi	sp,sp,-16
 6b2:	e422                	sd	s0,8(sp)
 6b4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6b6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6ba:	00000797          	auipc	a5,0x0
 6be:	1967b783          	ld	a5,406(a5) # 850 <freep>
 6c2:	a805                	j	6f2 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6c4:	4618                	lw	a4,8(a2)
 6c6:	9db9                	addw	a1,a1,a4
 6c8:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6cc:	6398                	ld	a4,0(a5)
 6ce:	6318                	ld	a4,0(a4)
 6d0:	fee53823          	sd	a4,-16(a0)
 6d4:	a091                	j	718 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 6d6:	ff852703          	lw	a4,-8(a0)
 6da:	9e39                	addw	a2,a2,a4
 6dc:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 6de:	ff053703          	ld	a4,-16(a0)
 6e2:	e398                	sd	a4,0(a5)
 6e4:	a099                	j	72a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6e6:	6398                	ld	a4,0(a5)
 6e8:	00e7e463          	bltu	a5,a4,6f0 <free+0x40>
 6ec:	00e6ea63          	bltu	a3,a4,700 <free+0x50>
{
 6f0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f2:	fed7fae3          	bgeu	a5,a3,6e6 <free+0x36>
 6f6:	6398                	ld	a4,0(a5)
 6f8:	00e6e463          	bltu	a3,a4,700 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6fc:	fee7eae3          	bltu	a5,a4,6f0 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 700:	ff852583          	lw	a1,-8(a0)
 704:	6390                	ld	a2,0(a5)
 706:	02059813          	slli	a6,a1,0x20
 70a:	01c85713          	srli	a4,a6,0x1c
 70e:	9736                	add	a4,a4,a3
 710:	fae60ae3          	beq	a2,a4,6c4 <free+0x14>
    bp->s.ptr = p->s.ptr;
 714:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 718:	4790                	lw	a2,8(a5)
 71a:	02061593          	slli	a1,a2,0x20
 71e:	01c5d713          	srli	a4,a1,0x1c
 722:	973e                	add	a4,a4,a5
 724:	fae689e3          	beq	a3,a4,6d6 <free+0x26>
  } else
    p->s.ptr = bp;
 728:	e394                	sd	a3,0(a5)
  freep = p;
 72a:	00000717          	auipc	a4,0x0
 72e:	12f73323          	sd	a5,294(a4) # 850 <freep>
}
 732:	6422                	ld	s0,8(sp)
 734:	0141                	addi	sp,sp,16
 736:	8082                	ret

0000000000000738 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 738:	7139                	addi	sp,sp,-64
 73a:	fc06                	sd	ra,56(sp)
 73c:	f822                	sd	s0,48(sp)
 73e:	f426                	sd	s1,40(sp)
 740:	f04a                	sd	s2,32(sp)
 742:	ec4e                	sd	s3,24(sp)
 744:	e852                	sd	s4,16(sp)
 746:	e456                	sd	s5,8(sp)
 748:	e05a                	sd	s6,0(sp)
 74a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 74c:	02051493          	slli	s1,a0,0x20
 750:	9081                	srli	s1,s1,0x20
 752:	04bd                	addi	s1,s1,15
 754:	8091                	srli	s1,s1,0x4
 756:	0014899b          	addiw	s3,s1,1
 75a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 75c:	00000517          	auipc	a0,0x0
 760:	0f453503          	ld	a0,244(a0) # 850 <freep>
 764:	c515                	beqz	a0,790 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 766:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 768:	4798                	lw	a4,8(a5)
 76a:	02977f63          	bgeu	a4,s1,7a8 <malloc+0x70>
 76e:	8a4e                	mv	s4,s3
 770:	0009871b          	sext.w	a4,s3
 774:	6685                	lui	a3,0x1
 776:	00d77363          	bgeu	a4,a3,77c <malloc+0x44>
 77a:	6a05                	lui	s4,0x1
 77c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 780:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 784:	00000917          	auipc	s2,0x0
 788:	0cc90913          	addi	s2,s2,204 # 850 <freep>
  if(p == (char*)-1)
 78c:	5afd                	li	s5,-1
 78e:	a895                	j	802 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 790:	00000797          	auipc	a5,0x0
 794:	0c878793          	addi	a5,a5,200 # 858 <base>
 798:	00000717          	auipc	a4,0x0
 79c:	0af73c23          	sd	a5,184(a4) # 850 <freep>
 7a0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7a2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7a6:	b7e1                	j	76e <malloc+0x36>
      if(p->s.size == nunits)
 7a8:	02e48c63          	beq	s1,a4,7e0 <malloc+0xa8>
        p->s.size -= nunits;
 7ac:	4137073b          	subw	a4,a4,s3
 7b0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7b2:	02071693          	slli	a3,a4,0x20
 7b6:	01c6d713          	srli	a4,a3,0x1c
 7ba:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7bc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7c0:	00000717          	auipc	a4,0x0
 7c4:	08a73823          	sd	a0,144(a4) # 850 <freep>
      return (void*)(p + 1);
 7c8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7cc:	70e2                	ld	ra,56(sp)
 7ce:	7442                	ld	s0,48(sp)
 7d0:	74a2                	ld	s1,40(sp)
 7d2:	7902                	ld	s2,32(sp)
 7d4:	69e2                	ld	s3,24(sp)
 7d6:	6a42                	ld	s4,16(sp)
 7d8:	6aa2                	ld	s5,8(sp)
 7da:	6b02                	ld	s6,0(sp)
 7dc:	6121                	addi	sp,sp,64
 7de:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7e0:	6398                	ld	a4,0(a5)
 7e2:	e118                	sd	a4,0(a0)
 7e4:	bff1                	j	7c0 <malloc+0x88>
  hp->s.size = nu;
 7e6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7ea:	0541                	addi	a0,a0,16
 7ec:	00000097          	auipc	ra,0x0
 7f0:	ec4080e7          	jalr	-316(ra) # 6b0 <free>
  return freep;
 7f4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7f8:	d971                	beqz	a0,7cc <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7fa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7fc:	4798                	lw	a4,8(a5)
 7fe:	fa9775e3          	bgeu	a4,s1,7a8 <malloc+0x70>
    if(p == freep)
 802:	00093703          	ld	a4,0(s2)
 806:	853e                	mv	a0,a5
 808:	fef719e3          	bne	a4,a5,7fa <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 80c:	8552                	mv	a0,s4
 80e:	00000097          	auipc	ra,0x0
 812:	b6c080e7          	jalr	-1172(ra) # 37a <sbrk>
  if(p == (char*)-1)
 816:	fd5518e3          	bne	a0,s5,7e6 <malloc+0xae>
        return 0;
 81a:	4501                	li	a0,0
 81c:	bf45                	j	7cc <malloc+0x94>
