
user/_pingpong:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	1800                	addi	s0,sp,48
  int p_paren[2], p_child[2];
  pipe(p_paren);  // fd 3(in), 4(out)
   8:	fe840513          	addi	a0,s0,-24
   c:	00000097          	auipc	ra,0x0
  10:	38a080e7          	jalr	906(ra) # 396 <pipe>
  pipe(p_child);  // fd 5(in), 6(out)
  14:	fe040513          	addi	a0,s0,-32
  18:	00000097          	auipc	ra,0x0
  1c:	37e080e7          	jalr	894(ra) # 396 <pipe>

  if (fork() == 0)
  20:	00000097          	auipc	ra,0x0
  24:	35e080e7          	jalr	862(ra) # 37e <fork>
  28:	ed3d                	bnez	a0,a6 <main+0xa6>
  {
    // inside child
    char buff[5];
    char data[5] = "pong\n";
  2a:	676e77b7          	lui	a5,0x676e7
  2e:	f7078793          	addi	a5,a5,-144 # 676e6f70 <__global_pointer$+0x676e5e87>
  32:	fcf42c23          	sw	a5,-40(s0)
  36:	47a9                	li	a5,10
  38:	fcf40e23          	sb	a5,-36(s0)

    if (read(p_child[0], buff, 5) > 0)
  3c:	4615                	li	a2,5
  3e:	fd040593          	addi	a1,s0,-48
  42:	fe042503          	lw	a0,-32(s0)
  46:	00000097          	auipc	ra,0x0
  4a:	358080e7          	jalr	856(ra) # 39e <read>
  4e:	00a04763          	bgtz	a0,5c <main+0x5c>
      printf("%d: received %s\n", getpid(), buff);
      close(p_paren[0]);
      close(p_paren[1]);
    }
  }
  exit(0);
  52:	4501                	li	a0,0
  54:	00000097          	auipc	ra,0x0
  58:	332080e7          	jalr	818(ra) # 386 <exit>
      printf("%d: received %s", getpid(), buff);
  5c:	00000097          	auipc	ra,0x0
  60:	3aa080e7          	jalr	938(ra) # 406 <getpid>
  64:	85aa                	mv	a1,a0
  66:	fd040613          	addi	a2,s0,-48
  6a:	00001517          	auipc	a0,0x1
  6e:	83e50513          	addi	a0,a0,-1986 # 8a8 <malloc+0xec>
  72:	00000097          	auipc	ra,0x0
  76:	68c080e7          	jalr	1676(ra) # 6fe <printf>
      close(p_child[0]);
  7a:	fe042503          	lw	a0,-32(s0)
  7e:	00000097          	auipc	ra,0x0
  82:	330080e7          	jalr	816(ra) # 3ae <close>
      write(p_paren[1], data, 5);
  86:	4615                	li	a2,5
  88:	fd840593          	addi	a1,s0,-40
  8c:	fec42503          	lw	a0,-20(s0)
  90:	00000097          	auipc	ra,0x0
  94:	316080e7          	jalr	790(ra) # 3a6 <write>
      close(p_child[1]);
  98:	fe442503          	lw	a0,-28(s0)
  9c:	00000097          	auipc	ra,0x0
  a0:	312080e7          	jalr	786(ra) # 3ae <close>
  a4:	b77d                	j	52 <main+0x52>
    char data[5] = "ping\n";
  a6:	676e77b7          	lui	a5,0x676e7
  aa:	97078793          	addi	a5,a5,-1680 # 676e6970 <__global_pointer$+0x676e5887>
  ae:	fcf42c23          	sw	a5,-40(s0)
  b2:	47a9                	li	a5,10
  b4:	fcf40e23          	sb	a5,-36(s0)
    write(p_child[1], data, 5);
  b8:	4615                	li	a2,5
  ba:	fd840593          	addi	a1,s0,-40
  be:	fe442503          	lw	a0,-28(s0)
  c2:	00000097          	auipc	ra,0x0
  c6:	2e4080e7          	jalr	740(ra) # 3a6 <write>
    if (read(p_paren[0], buff, 5) > 0)
  ca:	4615                	li	a2,5
  cc:	fd040593          	addi	a1,s0,-48
  d0:	fe842503          	lw	a0,-24(s0)
  d4:	00000097          	auipc	ra,0x0
  d8:	2ca080e7          	jalr	714(ra) # 39e <read>
  dc:	f6a05be3          	blez	a0,52 <main+0x52>
      printf("%d: received %s\n", getpid(), buff);
  e0:	00000097          	auipc	ra,0x0
  e4:	326080e7          	jalr	806(ra) # 406 <getpid>
  e8:	85aa                	mv	a1,a0
  ea:	fd040613          	addi	a2,s0,-48
  ee:	00000517          	auipc	a0,0x0
  f2:	7ca50513          	addi	a0,a0,1994 # 8b8 <malloc+0xfc>
  f6:	00000097          	auipc	ra,0x0
  fa:	608080e7          	jalr	1544(ra) # 6fe <printf>
      close(p_paren[0]);
  fe:	fe842503          	lw	a0,-24(s0)
 102:	00000097          	auipc	ra,0x0
 106:	2ac080e7          	jalr	684(ra) # 3ae <close>
      close(p_paren[1]);
 10a:	fec42503          	lw	a0,-20(s0)
 10e:	00000097          	auipc	ra,0x0
 112:	2a0080e7          	jalr	672(ra) # 3ae <close>
 116:	bf35                	j	52 <main+0x52>

0000000000000118 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 118:	1141                	addi	sp,sp,-16
 11a:	e422                	sd	s0,8(sp)
 11c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 11e:	87aa                	mv	a5,a0
 120:	0585                	addi	a1,a1,1
 122:	0785                	addi	a5,a5,1
 124:	fff5c703          	lbu	a4,-1(a1)
 128:	fee78fa3          	sb	a4,-1(a5)
 12c:	fb75                	bnez	a4,120 <strcpy+0x8>
    ;
  return os;
}
 12e:	6422                	ld	s0,8(sp)
 130:	0141                	addi	sp,sp,16
 132:	8082                	ret

0000000000000134 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 134:	1141                	addi	sp,sp,-16
 136:	e422                	sd	s0,8(sp)
 138:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 13a:	00054783          	lbu	a5,0(a0)
 13e:	cb91                	beqz	a5,152 <strcmp+0x1e>
 140:	0005c703          	lbu	a4,0(a1)
 144:	00f71763          	bne	a4,a5,152 <strcmp+0x1e>
    p++, q++;
 148:	0505                	addi	a0,a0,1
 14a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 14c:	00054783          	lbu	a5,0(a0)
 150:	fbe5                	bnez	a5,140 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 152:	0005c503          	lbu	a0,0(a1)
}
 156:	40a7853b          	subw	a0,a5,a0
 15a:	6422                	ld	s0,8(sp)
 15c:	0141                	addi	sp,sp,16
 15e:	8082                	ret

0000000000000160 <strlen>:

uint
strlen(const char *s)
{
 160:	1141                	addi	sp,sp,-16
 162:	e422                	sd	s0,8(sp)
 164:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 166:	00054783          	lbu	a5,0(a0)
 16a:	cf91                	beqz	a5,186 <strlen+0x26>
 16c:	0505                	addi	a0,a0,1
 16e:	87aa                	mv	a5,a0
 170:	4685                	li	a3,1
 172:	9e89                	subw	a3,a3,a0
 174:	00f6853b          	addw	a0,a3,a5
 178:	0785                	addi	a5,a5,1
 17a:	fff7c703          	lbu	a4,-1(a5)
 17e:	fb7d                	bnez	a4,174 <strlen+0x14>
    ;
  return n;
}
 180:	6422                	ld	s0,8(sp)
 182:	0141                	addi	sp,sp,16
 184:	8082                	ret
  for(n = 0; s[n]; n++)
 186:	4501                	li	a0,0
 188:	bfe5                	j	180 <strlen+0x20>

000000000000018a <memset>:

void*
memset(void *dst, int c, uint n)
{
 18a:	1141                	addi	sp,sp,-16
 18c:	e422                	sd	s0,8(sp)
 18e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 190:	ca19                	beqz	a2,1a6 <memset+0x1c>
 192:	87aa                	mv	a5,a0
 194:	1602                	slli	a2,a2,0x20
 196:	9201                	srli	a2,a2,0x20
 198:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 19c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1a0:	0785                	addi	a5,a5,1
 1a2:	fee79de3          	bne	a5,a4,19c <memset+0x12>
  }
  return dst;
}
 1a6:	6422                	ld	s0,8(sp)
 1a8:	0141                	addi	sp,sp,16
 1aa:	8082                	ret

00000000000001ac <strchr>:

char*
strchr(const char *s, char c)
{
 1ac:	1141                	addi	sp,sp,-16
 1ae:	e422                	sd	s0,8(sp)
 1b0:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1b2:	00054783          	lbu	a5,0(a0)
 1b6:	cb99                	beqz	a5,1cc <strchr+0x20>
    if(*s == c)
 1b8:	00f58763          	beq	a1,a5,1c6 <strchr+0x1a>
  for(; *s; s++)
 1bc:	0505                	addi	a0,a0,1
 1be:	00054783          	lbu	a5,0(a0)
 1c2:	fbfd                	bnez	a5,1b8 <strchr+0xc>
      return (char*)s;
  return 0;
 1c4:	4501                	li	a0,0
}
 1c6:	6422                	ld	s0,8(sp)
 1c8:	0141                	addi	sp,sp,16
 1ca:	8082                	ret
  return 0;
 1cc:	4501                	li	a0,0
 1ce:	bfe5                	j	1c6 <strchr+0x1a>

00000000000001d0 <gets>:

char*
gets(char *buf, int max)
{
 1d0:	711d                	addi	sp,sp,-96
 1d2:	ec86                	sd	ra,88(sp)
 1d4:	e8a2                	sd	s0,80(sp)
 1d6:	e4a6                	sd	s1,72(sp)
 1d8:	e0ca                	sd	s2,64(sp)
 1da:	fc4e                	sd	s3,56(sp)
 1dc:	f852                	sd	s4,48(sp)
 1de:	f456                	sd	s5,40(sp)
 1e0:	f05a                	sd	s6,32(sp)
 1e2:	ec5e                	sd	s7,24(sp)
 1e4:	1080                	addi	s0,sp,96
 1e6:	8baa                	mv	s7,a0
 1e8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ea:	892a                	mv	s2,a0
 1ec:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ee:	4aa9                	li	s5,10
 1f0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1f2:	89a6                	mv	s3,s1
 1f4:	2485                	addiw	s1,s1,1
 1f6:	0344d863          	bge	s1,s4,226 <gets+0x56>
    cc = read(0, &c, 1);
 1fa:	4605                	li	a2,1
 1fc:	faf40593          	addi	a1,s0,-81
 200:	4501                	li	a0,0
 202:	00000097          	auipc	ra,0x0
 206:	19c080e7          	jalr	412(ra) # 39e <read>
    if(cc < 1)
 20a:	00a05e63          	blez	a0,226 <gets+0x56>
    buf[i++] = c;
 20e:	faf44783          	lbu	a5,-81(s0)
 212:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 216:	01578763          	beq	a5,s5,224 <gets+0x54>
 21a:	0905                	addi	s2,s2,1
 21c:	fd679be3          	bne	a5,s6,1f2 <gets+0x22>
  for(i=0; i+1 < max; ){
 220:	89a6                	mv	s3,s1
 222:	a011                	j	226 <gets+0x56>
 224:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 226:	99de                	add	s3,s3,s7
 228:	00098023          	sb	zero,0(s3)
  return buf;
}
 22c:	855e                	mv	a0,s7
 22e:	60e6                	ld	ra,88(sp)
 230:	6446                	ld	s0,80(sp)
 232:	64a6                	ld	s1,72(sp)
 234:	6906                	ld	s2,64(sp)
 236:	79e2                	ld	s3,56(sp)
 238:	7a42                	ld	s4,48(sp)
 23a:	7aa2                	ld	s5,40(sp)
 23c:	7b02                	ld	s6,32(sp)
 23e:	6be2                	ld	s7,24(sp)
 240:	6125                	addi	sp,sp,96
 242:	8082                	ret

0000000000000244 <stat>:

int
stat(const char *n, struct stat *st)
{
 244:	1101                	addi	sp,sp,-32
 246:	ec06                	sd	ra,24(sp)
 248:	e822                	sd	s0,16(sp)
 24a:	e426                	sd	s1,8(sp)
 24c:	e04a                	sd	s2,0(sp)
 24e:	1000                	addi	s0,sp,32
 250:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 252:	4581                	li	a1,0
 254:	00000097          	auipc	ra,0x0
 258:	172080e7          	jalr	370(ra) # 3c6 <open>
  if(fd < 0)
 25c:	02054563          	bltz	a0,286 <stat+0x42>
 260:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 262:	85ca                	mv	a1,s2
 264:	00000097          	auipc	ra,0x0
 268:	17a080e7          	jalr	378(ra) # 3de <fstat>
 26c:	892a                	mv	s2,a0
  close(fd);
 26e:	8526                	mv	a0,s1
 270:	00000097          	auipc	ra,0x0
 274:	13e080e7          	jalr	318(ra) # 3ae <close>
  return r;
}
 278:	854a                	mv	a0,s2
 27a:	60e2                	ld	ra,24(sp)
 27c:	6442                	ld	s0,16(sp)
 27e:	64a2                	ld	s1,8(sp)
 280:	6902                	ld	s2,0(sp)
 282:	6105                	addi	sp,sp,32
 284:	8082                	ret
    return -1;
 286:	597d                	li	s2,-1
 288:	bfc5                	j	278 <stat+0x34>

000000000000028a <atoi>:

int
atoi(const char *s)
{
 28a:	1141                	addi	sp,sp,-16
 28c:	e422                	sd	s0,8(sp)
 28e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 290:	00054603          	lbu	a2,0(a0)
 294:	fd06079b          	addiw	a5,a2,-48
 298:	0ff7f793          	andi	a5,a5,255
 29c:	4725                	li	a4,9
 29e:	02f76963          	bltu	a4,a5,2d0 <atoi+0x46>
 2a2:	86aa                	mv	a3,a0
  n = 0;
 2a4:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2a6:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2a8:	0685                	addi	a3,a3,1
 2aa:	0025179b          	slliw	a5,a0,0x2
 2ae:	9fa9                	addw	a5,a5,a0
 2b0:	0017979b          	slliw	a5,a5,0x1
 2b4:	9fb1                	addw	a5,a5,a2
 2b6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2ba:	0006c603          	lbu	a2,0(a3)
 2be:	fd06071b          	addiw	a4,a2,-48
 2c2:	0ff77713          	andi	a4,a4,255
 2c6:	fee5f1e3          	bgeu	a1,a4,2a8 <atoi+0x1e>
  return n;
}
 2ca:	6422                	ld	s0,8(sp)
 2cc:	0141                	addi	sp,sp,16
 2ce:	8082                	ret
  n = 0;
 2d0:	4501                	li	a0,0
 2d2:	bfe5                	j	2ca <atoi+0x40>

00000000000002d4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2d4:	1141                	addi	sp,sp,-16
 2d6:	e422                	sd	s0,8(sp)
 2d8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2da:	02b57463          	bgeu	a0,a1,302 <memmove+0x2e>
    while(n-- > 0)
 2de:	00c05f63          	blez	a2,2fc <memmove+0x28>
 2e2:	1602                	slli	a2,a2,0x20
 2e4:	9201                	srli	a2,a2,0x20
 2e6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2ea:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ec:	0585                	addi	a1,a1,1
 2ee:	0705                	addi	a4,a4,1
 2f0:	fff5c683          	lbu	a3,-1(a1)
 2f4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2f8:	fee79ae3          	bne	a5,a4,2ec <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2fc:	6422                	ld	s0,8(sp)
 2fe:	0141                	addi	sp,sp,16
 300:	8082                	ret
    dst += n;
 302:	00c50733          	add	a4,a0,a2
    src += n;
 306:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 308:	fec05ae3          	blez	a2,2fc <memmove+0x28>
 30c:	fff6079b          	addiw	a5,a2,-1
 310:	1782                	slli	a5,a5,0x20
 312:	9381                	srli	a5,a5,0x20
 314:	fff7c793          	not	a5,a5
 318:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 31a:	15fd                	addi	a1,a1,-1
 31c:	177d                	addi	a4,a4,-1
 31e:	0005c683          	lbu	a3,0(a1)
 322:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 326:	fee79ae3          	bne	a5,a4,31a <memmove+0x46>
 32a:	bfc9                	j	2fc <memmove+0x28>

000000000000032c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 32c:	1141                	addi	sp,sp,-16
 32e:	e422                	sd	s0,8(sp)
 330:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 332:	ca05                	beqz	a2,362 <memcmp+0x36>
 334:	fff6069b          	addiw	a3,a2,-1
 338:	1682                	slli	a3,a3,0x20
 33a:	9281                	srli	a3,a3,0x20
 33c:	0685                	addi	a3,a3,1
 33e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 340:	00054783          	lbu	a5,0(a0)
 344:	0005c703          	lbu	a4,0(a1)
 348:	00e79863          	bne	a5,a4,358 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 34c:	0505                	addi	a0,a0,1
    p2++;
 34e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 350:	fed518e3          	bne	a0,a3,340 <memcmp+0x14>
  }
  return 0;
 354:	4501                	li	a0,0
 356:	a019                	j	35c <memcmp+0x30>
      return *p1 - *p2;
 358:	40e7853b          	subw	a0,a5,a4
}
 35c:	6422                	ld	s0,8(sp)
 35e:	0141                	addi	sp,sp,16
 360:	8082                	ret
  return 0;
 362:	4501                	li	a0,0
 364:	bfe5                	j	35c <memcmp+0x30>

0000000000000366 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 366:	1141                	addi	sp,sp,-16
 368:	e406                	sd	ra,8(sp)
 36a:	e022                	sd	s0,0(sp)
 36c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 36e:	00000097          	auipc	ra,0x0
 372:	f66080e7          	jalr	-154(ra) # 2d4 <memmove>
}
 376:	60a2                	ld	ra,8(sp)
 378:	6402                	ld	s0,0(sp)
 37a:	0141                	addi	sp,sp,16
 37c:	8082                	ret

000000000000037e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 37e:	4885                	li	a7,1
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <exit>:
.global exit
exit:
 li a7, SYS_exit
 386:	4889                	li	a7,2
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <wait>:
.global wait
wait:
 li a7, SYS_wait
 38e:	488d                	li	a7,3
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 396:	4891                	li	a7,4
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <read>:
.global read
read:
 li a7, SYS_read
 39e:	4895                	li	a7,5
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <write>:
.global write
write:
 li a7, SYS_write
 3a6:	48c1                	li	a7,16
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <close>:
.global close
close:
 li a7, SYS_close
 3ae:	48d5                	li	a7,21
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3b6:	4899                	li	a7,6
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <exec>:
.global exec
exec:
 li a7, SYS_exec
 3be:	489d                	li	a7,7
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <open>:
.global open
open:
 li a7, SYS_open
 3c6:	48bd                	li	a7,15
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ce:	48c5                	li	a7,17
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3d6:	48c9                	li	a7,18
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3de:	48a1                	li	a7,8
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <link>:
.global link
link:
 li a7, SYS_link
 3e6:	48cd                	li	a7,19
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3ee:	48d1                	li	a7,20
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3f6:	48a5                	li	a7,9
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <dup>:
.global dup
dup:
 li a7, SYS_dup
 3fe:	48a9                	li	a7,10
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 406:	48ad                	li	a7,11
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 40e:	48b1                	li	a7,12
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 416:	48b5                	li	a7,13
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 41e:	48b9                	li	a7,14
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 426:	1101                	addi	sp,sp,-32
 428:	ec06                	sd	ra,24(sp)
 42a:	e822                	sd	s0,16(sp)
 42c:	1000                	addi	s0,sp,32
 42e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 432:	4605                	li	a2,1
 434:	fef40593          	addi	a1,s0,-17
 438:	00000097          	auipc	ra,0x0
 43c:	f6e080e7          	jalr	-146(ra) # 3a6 <write>
}
 440:	60e2                	ld	ra,24(sp)
 442:	6442                	ld	s0,16(sp)
 444:	6105                	addi	sp,sp,32
 446:	8082                	ret

0000000000000448 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 448:	7139                	addi	sp,sp,-64
 44a:	fc06                	sd	ra,56(sp)
 44c:	f822                	sd	s0,48(sp)
 44e:	f426                	sd	s1,40(sp)
 450:	f04a                	sd	s2,32(sp)
 452:	ec4e                	sd	s3,24(sp)
 454:	0080                	addi	s0,sp,64
 456:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 458:	c299                	beqz	a3,45e <printint+0x16>
 45a:	0805c863          	bltz	a1,4ea <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 45e:	2581                	sext.w	a1,a1
  neg = 0;
 460:	4881                	li	a7,0
 462:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 466:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 468:	2601                	sext.w	a2,a2
 46a:	00000517          	auipc	a0,0x0
 46e:	46e50513          	addi	a0,a0,1134 # 8d8 <digits>
 472:	883a                	mv	a6,a4
 474:	2705                	addiw	a4,a4,1
 476:	02c5f7bb          	remuw	a5,a1,a2
 47a:	1782                	slli	a5,a5,0x20
 47c:	9381                	srli	a5,a5,0x20
 47e:	97aa                	add	a5,a5,a0
 480:	0007c783          	lbu	a5,0(a5)
 484:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 488:	0005879b          	sext.w	a5,a1
 48c:	02c5d5bb          	divuw	a1,a1,a2
 490:	0685                	addi	a3,a3,1
 492:	fec7f0e3          	bgeu	a5,a2,472 <printint+0x2a>
  if(neg)
 496:	00088b63          	beqz	a7,4ac <printint+0x64>
    buf[i++] = '-';
 49a:	fd040793          	addi	a5,s0,-48
 49e:	973e                	add	a4,a4,a5
 4a0:	02d00793          	li	a5,45
 4a4:	fef70823          	sb	a5,-16(a4)
 4a8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4ac:	02e05863          	blez	a4,4dc <printint+0x94>
 4b0:	fc040793          	addi	a5,s0,-64
 4b4:	00e78933          	add	s2,a5,a4
 4b8:	fff78993          	addi	s3,a5,-1
 4bc:	99ba                	add	s3,s3,a4
 4be:	377d                	addiw	a4,a4,-1
 4c0:	1702                	slli	a4,a4,0x20
 4c2:	9301                	srli	a4,a4,0x20
 4c4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4c8:	fff94583          	lbu	a1,-1(s2)
 4cc:	8526                	mv	a0,s1
 4ce:	00000097          	auipc	ra,0x0
 4d2:	f58080e7          	jalr	-168(ra) # 426 <putc>
  while(--i >= 0)
 4d6:	197d                	addi	s2,s2,-1
 4d8:	ff3918e3          	bne	s2,s3,4c8 <printint+0x80>
}
 4dc:	70e2                	ld	ra,56(sp)
 4de:	7442                	ld	s0,48(sp)
 4e0:	74a2                	ld	s1,40(sp)
 4e2:	7902                	ld	s2,32(sp)
 4e4:	69e2                	ld	s3,24(sp)
 4e6:	6121                	addi	sp,sp,64
 4e8:	8082                	ret
    x = -xx;
 4ea:	40b005bb          	negw	a1,a1
    neg = 1;
 4ee:	4885                	li	a7,1
    x = -xx;
 4f0:	bf8d                	j	462 <printint+0x1a>

00000000000004f2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4f2:	7119                	addi	sp,sp,-128
 4f4:	fc86                	sd	ra,120(sp)
 4f6:	f8a2                	sd	s0,112(sp)
 4f8:	f4a6                	sd	s1,104(sp)
 4fa:	f0ca                	sd	s2,96(sp)
 4fc:	ecce                	sd	s3,88(sp)
 4fe:	e8d2                	sd	s4,80(sp)
 500:	e4d6                	sd	s5,72(sp)
 502:	e0da                	sd	s6,64(sp)
 504:	fc5e                	sd	s7,56(sp)
 506:	f862                	sd	s8,48(sp)
 508:	f466                	sd	s9,40(sp)
 50a:	f06a                	sd	s10,32(sp)
 50c:	ec6e                	sd	s11,24(sp)
 50e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 510:	0005c903          	lbu	s2,0(a1)
 514:	18090f63          	beqz	s2,6b2 <vprintf+0x1c0>
 518:	8aaa                	mv	s5,a0
 51a:	8b32                	mv	s6,a2
 51c:	00158493          	addi	s1,a1,1
  state = 0;
 520:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 522:	02500a13          	li	s4,37
      if(c == 'd'){
 526:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 52a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 52e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 532:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 536:	00000b97          	auipc	s7,0x0
 53a:	3a2b8b93          	addi	s7,s7,930 # 8d8 <digits>
 53e:	a839                	j	55c <vprintf+0x6a>
        putc(fd, c);
 540:	85ca                	mv	a1,s2
 542:	8556                	mv	a0,s5
 544:	00000097          	auipc	ra,0x0
 548:	ee2080e7          	jalr	-286(ra) # 426 <putc>
 54c:	a019                	j	552 <vprintf+0x60>
    } else if(state == '%'){
 54e:	01498f63          	beq	s3,s4,56c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 552:	0485                	addi	s1,s1,1
 554:	fff4c903          	lbu	s2,-1(s1)
 558:	14090d63          	beqz	s2,6b2 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 55c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 560:	fe0997e3          	bnez	s3,54e <vprintf+0x5c>
      if(c == '%'){
 564:	fd479ee3          	bne	a5,s4,540 <vprintf+0x4e>
        state = '%';
 568:	89be                	mv	s3,a5
 56a:	b7e5                	j	552 <vprintf+0x60>
      if(c == 'd'){
 56c:	05878063          	beq	a5,s8,5ac <vprintf+0xba>
      } else if(c == 'l') {
 570:	05978c63          	beq	a5,s9,5c8 <vprintf+0xd6>
      } else if(c == 'x') {
 574:	07a78863          	beq	a5,s10,5e4 <vprintf+0xf2>
      } else if(c == 'p') {
 578:	09b78463          	beq	a5,s11,600 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 57c:	07300713          	li	a4,115
 580:	0ce78663          	beq	a5,a4,64c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 584:	06300713          	li	a4,99
 588:	0ee78e63          	beq	a5,a4,684 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 58c:	11478863          	beq	a5,s4,69c <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 590:	85d2                	mv	a1,s4
 592:	8556                	mv	a0,s5
 594:	00000097          	auipc	ra,0x0
 598:	e92080e7          	jalr	-366(ra) # 426 <putc>
        putc(fd, c);
 59c:	85ca                	mv	a1,s2
 59e:	8556                	mv	a0,s5
 5a0:	00000097          	auipc	ra,0x0
 5a4:	e86080e7          	jalr	-378(ra) # 426 <putc>
      }
      state = 0;
 5a8:	4981                	li	s3,0
 5aa:	b765                	j	552 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5ac:	008b0913          	addi	s2,s6,8
 5b0:	4685                	li	a3,1
 5b2:	4629                	li	a2,10
 5b4:	000b2583          	lw	a1,0(s6)
 5b8:	8556                	mv	a0,s5
 5ba:	00000097          	auipc	ra,0x0
 5be:	e8e080e7          	jalr	-370(ra) # 448 <printint>
 5c2:	8b4a                	mv	s6,s2
      state = 0;
 5c4:	4981                	li	s3,0
 5c6:	b771                	j	552 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c8:	008b0913          	addi	s2,s6,8
 5cc:	4681                	li	a3,0
 5ce:	4629                	li	a2,10
 5d0:	000b2583          	lw	a1,0(s6)
 5d4:	8556                	mv	a0,s5
 5d6:	00000097          	auipc	ra,0x0
 5da:	e72080e7          	jalr	-398(ra) # 448 <printint>
 5de:	8b4a                	mv	s6,s2
      state = 0;
 5e0:	4981                	li	s3,0
 5e2:	bf85                	j	552 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5e4:	008b0913          	addi	s2,s6,8
 5e8:	4681                	li	a3,0
 5ea:	4641                	li	a2,16
 5ec:	000b2583          	lw	a1,0(s6)
 5f0:	8556                	mv	a0,s5
 5f2:	00000097          	auipc	ra,0x0
 5f6:	e56080e7          	jalr	-426(ra) # 448 <printint>
 5fa:	8b4a                	mv	s6,s2
      state = 0;
 5fc:	4981                	li	s3,0
 5fe:	bf91                	j	552 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 600:	008b0793          	addi	a5,s6,8
 604:	f8f43423          	sd	a5,-120(s0)
 608:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 60c:	03000593          	li	a1,48
 610:	8556                	mv	a0,s5
 612:	00000097          	auipc	ra,0x0
 616:	e14080e7          	jalr	-492(ra) # 426 <putc>
  putc(fd, 'x');
 61a:	85ea                	mv	a1,s10
 61c:	8556                	mv	a0,s5
 61e:	00000097          	auipc	ra,0x0
 622:	e08080e7          	jalr	-504(ra) # 426 <putc>
 626:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 628:	03c9d793          	srli	a5,s3,0x3c
 62c:	97de                	add	a5,a5,s7
 62e:	0007c583          	lbu	a1,0(a5)
 632:	8556                	mv	a0,s5
 634:	00000097          	auipc	ra,0x0
 638:	df2080e7          	jalr	-526(ra) # 426 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 63c:	0992                	slli	s3,s3,0x4
 63e:	397d                	addiw	s2,s2,-1
 640:	fe0914e3          	bnez	s2,628 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 644:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 648:	4981                	li	s3,0
 64a:	b721                	j	552 <vprintf+0x60>
        s = va_arg(ap, char*);
 64c:	008b0993          	addi	s3,s6,8
 650:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 654:	02090163          	beqz	s2,676 <vprintf+0x184>
        while(*s != 0){
 658:	00094583          	lbu	a1,0(s2)
 65c:	c9a1                	beqz	a1,6ac <vprintf+0x1ba>
          putc(fd, *s);
 65e:	8556                	mv	a0,s5
 660:	00000097          	auipc	ra,0x0
 664:	dc6080e7          	jalr	-570(ra) # 426 <putc>
          s++;
 668:	0905                	addi	s2,s2,1
        while(*s != 0){
 66a:	00094583          	lbu	a1,0(s2)
 66e:	f9e5                	bnez	a1,65e <vprintf+0x16c>
        s = va_arg(ap, char*);
 670:	8b4e                	mv	s6,s3
      state = 0;
 672:	4981                	li	s3,0
 674:	bdf9                	j	552 <vprintf+0x60>
          s = "(null)";
 676:	00000917          	auipc	s2,0x0
 67a:	25a90913          	addi	s2,s2,602 # 8d0 <malloc+0x114>
        while(*s != 0){
 67e:	02800593          	li	a1,40
 682:	bff1                	j	65e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 684:	008b0913          	addi	s2,s6,8
 688:	000b4583          	lbu	a1,0(s6)
 68c:	8556                	mv	a0,s5
 68e:	00000097          	auipc	ra,0x0
 692:	d98080e7          	jalr	-616(ra) # 426 <putc>
 696:	8b4a                	mv	s6,s2
      state = 0;
 698:	4981                	li	s3,0
 69a:	bd65                	j	552 <vprintf+0x60>
        putc(fd, c);
 69c:	85d2                	mv	a1,s4
 69e:	8556                	mv	a0,s5
 6a0:	00000097          	auipc	ra,0x0
 6a4:	d86080e7          	jalr	-634(ra) # 426 <putc>
      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	b565                	j	552 <vprintf+0x60>
        s = va_arg(ap, char*);
 6ac:	8b4e                	mv	s6,s3
      state = 0;
 6ae:	4981                	li	s3,0
 6b0:	b54d                	j	552 <vprintf+0x60>
    }
  }
}
 6b2:	70e6                	ld	ra,120(sp)
 6b4:	7446                	ld	s0,112(sp)
 6b6:	74a6                	ld	s1,104(sp)
 6b8:	7906                	ld	s2,96(sp)
 6ba:	69e6                	ld	s3,88(sp)
 6bc:	6a46                	ld	s4,80(sp)
 6be:	6aa6                	ld	s5,72(sp)
 6c0:	6b06                	ld	s6,64(sp)
 6c2:	7be2                	ld	s7,56(sp)
 6c4:	7c42                	ld	s8,48(sp)
 6c6:	7ca2                	ld	s9,40(sp)
 6c8:	7d02                	ld	s10,32(sp)
 6ca:	6de2                	ld	s11,24(sp)
 6cc:	6109                	addi	sp,sp,128
 6ce:	8082                	ret

00000000000006d0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6d0:	715d                	addi	sp,sp,-80
 6d2:	ec06                	sd	ra,24(sp)
 6d4:	e822                	sd	s0,16(sp)
 6d6:	1000                	addi	s0,sp,32
 6d8:	e010                	sd	a2,0(s0)
 6da:	e414                	sd	a3,8(s0)
 6dc:	e818                	sd	a4,16(s0)
 6de:	ec1c                	sd	a5,24(s0)
 6e0:	03043023          	sd	a6,32(s0)
 6e4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6e8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6ec:	8622                	mv	a2,s0
 6ee:	00000097          	auipc	ra,0x0
 6f2:	e04080e7          	jalr	-508(ra) # 4f2 <vprintf>
}
 6f6:	60e2                	ld	ra,24(sp)
 6f8:	6442                	ld	s0,16(sp)
 6fa:	6161                	addi	sp,sp,80
 6fc:	8082                	ret

00000000000006fe <printf>:

void
printf(const char *fmt, ...)
{
 6fe:	711d                	addi	sp,sp,-96
 700:	ec06                	sd	ra,24(sp)
 702:	e822                	sd	s0,16(sp)
 704:	1000                	addi	s0,sp,32
 706:	e40c                	sd	a1,8(s0)
 708:	e810                	sd	a2,16(s0)
 70a:	ec14                	sd	a3,24(s0)
 70c:	f018                	sd	a4,32(s0)
 70e:	f41c                	sd	a5,40(s0)
 710:	03043823          	sd	a6,48(s0)
 714:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 718:	00840613          	addi	a2,s0,8
 71c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 720:	85aa                	mv	a1,a0
 722:	4505                	li	a0,1
 724:	00000097          	auipc	ra,0x0
 728:	dce080e7          	jalr	-562(ra) # 4f2 <vprintf>
}
 72c:	60e2                	ld	ra,24(sp)
 72e:	6442                	ld	s0,16(sp)
 730:	6125                	addi	sp,sp,96
 732:	8082                	ret

0000000000000734 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 734:	1141                	addi	sp,sp,-16
 736:	e422                	sd	s0,8(sp)
 738:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 73a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 73e:	00000797          	auipc	a5,0x0
 742:	1b27b783          	ld	a5,434(a5) # 8f0 <freep>
 746:	a805                	j	776 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 748:	4618                	lw	a4,8(a2)
 74a:	9db9                	addw	a1,a1,a4
 74c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 750:	6398                	ld	a4,0(a5)
 752:	6318                	ld	a4,0(a4)
 754:	fee53823          	sd	a4,-16(a0)
 758:	a091                	j	79c <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 75a:	ff852703          	lw	a4,-8(a0)
 75e:	9e39                	addw	a2,a2,a4
 760:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 762:	ff053703          	ld	a4,-16(a0)
 766:	e398                	sd	a4,0(a5)
 768:	a099                	j	7ae <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 76a:	6398                	ld	a4,0(a5)
 76c:	00e7e463          	bltu	a5,a4,774 <free+0x40>
 770:	00e6ea63          	bltu	a3,a4,784 <free+0x50>
{
 774:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 776:	fed7fae3          	bgeu	a5,a3,76a <free+0x36>
 77a:	6398                	ld	a4,0(a5)
 77c:	00e6e463          	bltu	a3,a4,784 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 780:	fee7eae3          	bltu	a5,a4,774 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 784:	ff852583          	lw	a1,-8(a0)
 788:	6390                	ld	a2,0(a5)
 78a:	02059813          	slli	a6,a1,0x20
 78e:	01c85713          	srli	a4,a6,0x1c
 792:	9736                	add	a4,a4,a3
 794:	fae60ae3          	beq	a2,a4,748 <free+0x14>
    bp->s.ptr = p->s.ptr;
 798:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 79c:	4790                	lw	a2,8(a5)
 79e:	02061593          	slli	a1,a2,0x20
 7a2:	01c5d713          	srli	a4,a1,0x1c
 7a6:	973e                	add	a4,a4,a5
 7a8:	fae689e3          	beq	a3,a4,75a <free+0x26>
  } else
    p->s.ptr = bp;
 7ac:	e394                	sd	a3,0(a5)
  freep = p;
 7ae:	00000717          	auipc	a4,0x0
 7b2:	14f73123          	sd	a5,322(a4) # 8f0 <freep>
}
 7b6:	6422                	ld	s0,8(sp)
 7b8:	0141                	addi	sp,sp,16
 7ba:	8082                	ret

00000000000007bc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7bc:	7139                	addi	sp,sp,-64
 7be:	fc06                	sd	ra,56(sp)
 7c0:	f822                	sd	s0,48(sp)
 7c2:	f426                	sd	s1,40(sp)
 7c4:	f04a                	sd	s2,32(sp)
 7c6:	ec4e                	sd	s3,24(sp)
 7c8:	e852                	sd	s4,16(sp)
 7ca:	e456                	sd	s5,8(sp)
 7cc:	e05a                	sd	s6,0(sp)
 7ce:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7d0:	02051493          	slli	s1,a0,0x20
 7d4:	9081                	srli	s1,s1,0x20
 7d6:	04bd                	addi	s1,s1,15
 7d8:	8091                	srli	s1,s1,0x4
 7da:	0014899b          	addiw	s3,s1,1
 7de:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7e0:	00000517          	auipc	a0,0x0
 7e4:	11053503          	ld	a0,272(a0) # 8f0 <freep>
 7e8:	c515                	beqz	a0,814 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7ea:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ec:	4798                	lw	a4,8(a5)
 7ee:	02977f63          	bgeu	a4,s1,82c <malloc+0x70>
 7f2:	8a4e                	mv	s4,s3
 7f4:	0009871b          	sext.w	a4,s3
 7f8:	6685                	lui	a3,0x1
 7fa:	00d77363          	bgeu	a4,a3,800 <malloc+0x44>
 7fe:	6a05                	lui	s4,0x1
 800:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 804:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 808:	00000917          	auipc	s2,0x0
 80c:	0e890913          	addi	s2,s2,232 # 8f0 <freep>
  if(p == (char*)-1)
 810:	5afd                	li	s5,-1
 812:	a895                	j	886 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 814:	00000797          	auipc	a5,0x0
 818:	0e478793          	addi	a5,a5,228 # 8f8 <base>
 81c:	00000717          	auipc	a4,0x0
 820:	0cf73a23          	sd	a5,212(a4) # 8f0 <freep>
 824:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 826:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 82a:	b7e1                	j	7f2 <malloc+0x36>
      if(p->s.size == nunits)
 82c:	02e48c63          	beq	s1,a4,864 <malloc+0xa8>
        p->s.size -= nunits;
 830:	4137073b          	subw	a4,a4,s3
 834:	c798                	sw	a4,8(a5)
        p += p->s.size;
 836:	02071693          	slli	a3,a4,0x20
 83a:	01c6d713          	srli	a4,a3,0x1c
 83e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 840:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 844:	00000717          	auipc	a4,0x0
 848:	0aa73623          	sd	a0,172(a4) # 8f0 <freep>
      return (void*)(p + 1);
 84c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 850:	70e2                	ld	ra,56(sp)
 852:	7442                	ld	s0,48(sp)
 854:	74a2                	ld	s1,40(sp)
 856:	7902                	ld	s2,32(sp)
 858:	69e2                	ld	s3,24(sp)
 85a:	6a42                	ld	s4,16(sp)
 85c:	6aa2                	ld	s5,8(sp)
 85e:	6b02                	ld	s6,0(sp)
 860:	6121                	addi	sp,sp,64
 862:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 864:	6398                	ld	a4,0(a5)
 866:	e118                	sd	a4,0(a0)
 868:	bff1                	j	844 <malloc+0x88>
  hp->s.size = nu;
 86a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 86e:	0541                	addi	a0,a0,16
 870:	00000097          	auipc	ra,0x0
 874:	ec4080e7          	jalr	-316(ra) # 734 <free>
  return freep;
 878:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 87c:	d971                	beqz	a0,850 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 87e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 880:	4798                	lw	a4,8(a5)
 882:	fa9775e3          	bgeu	a4,s1,82c <malloc+0x70>
    if(p == freep)
 886:	00093703          	ld	a4,0(s2)
 88a:	853e                	mv	a0,a5
 88c:	fef719e3          	bne	a4,a5,87e <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 890:	8552                	mv	a0,s4
 892:	00000097          	auipc	ra,0x0
 896:	b7c080e7          	jalr	-1156(ra) # 40e <sbrk>
  if(p == (char*)-1)
 89a:	fd5518e3          	bne	a0,s5,86a <malloc+0xae>
        return 0;
 89e:	4501                	li	a0,0
 8a0:	bf45                	j	850 <malloc+0x94>
