
user/_primes:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <read_prime>:
#define R 0
#define W 1

int
read_prime(int pin[])
{
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	0080                	addi	s0,sp,64
   a:	84aa                	mv	s1,a0
  int prime;
  int pout[2];
  // printf("[%d] [%d, %d] ", getpid(), pin[R], pin[W]);
  int read_result = read(pin[R], &prime, sizeof(prime));
   c:	4611                	li	a2,4
   e:	fdc40593          	addi	a1,s0,-36
  12:	4108                	lw	a0,0(a0)
  14:	00000097          	auipc	ra,0x0
  18:	3c8080e7          	jalr	968(ra) # 3dc <read>
  /* [TODO]: for some reason the code hangs on read */
  // printf("-- [%d] -- %d", read_result, prime);
  
  /* sieves prime integer */
  if(read_result > 0)
  1c:	00a04763          	bgtz	a0,2a <read_prime+0x2a>
      close(pout[W]);
      close(pin[R]);
    }
  }
  /* last process, reaches end-of-seq */
  exit(0);
  20:	4501                	li	a0,0
  22:	00000097          	auipc	ra,0x0
  26:	3a2080e7          	jalr	930(ra) # 3c4 <exit>
    printf("prime %d\n", prime);
  2a:	fdc42583          	lw	a1,-36(s0)
  2e:	00001517          	auipc	a0,0x1
  32:	8b250513          	addi	a0,a0,-1870 # 8e0 <malloc+0xe6>
  36:	00000097          	auipc	ra,0x0
  3a:	706080e7          	jalr	1798(ra) # 73c <printf>
    pipe(pout);
  3e:	fd040513          	addi	a0,s0,-48
  42:	00000097          	auipc	ra,0x0
  46:	392080e7          	jalr	914(ra) # 3d4 <pipe>
    if(fork() == 0)
  4a:	00000097          	auipc	ra,0x0
  4e:	372080e7          	jalr	882(ra) # 3bc <fork>
  52:	e10d                	bnez	a0,74 <read_prime+0x74>
      close(pin[R]);
  54:	4088                	lw	a0,0(s1)
  56:	00000097          	auipc	ra,0x0
  5a:	396080e7          	jalr	918(ra) # 3ec <close>
      close(pin[W]);
  5e:	40c8                	lw	a0,4(s1)
  60:	00000097          	auipc	ra,0x0
  64:	38c080e7          	jalr	908(ra) # 3ec <close>
      read_prime(pout);
  68:	fd040513          	addi	a0,s0,-48
  6c:	00000097          	auipc	ra,0x0
  70:	f94080e7          	jalr	-108(ra) # 0 <read_prime>
      close(pout[R]);
  74:	fd042503          	lw	a0,-48(s0)
  78:	00000097          	auipc	ra,0x0
  7c:	374080e7          	jalr	884(ra) # 3ec <close>
      close(pin[W]);
  80:	40c8                	lw	a0,4(s1)
  82:	00000097          	auipc	ra,0x0
  86:	36a080e7          	jalr	874(ra) # 3ec <close>
      while(read(pin[R], &buff, sizeof(int)) > 0) 
  8a:	4611                	li	a2,4
  8c:	fcc40593          	addi	a1,s0,-52
  90:	4088                	lw	a0,0(s1)
  92:	00000097          	auipc	ra,0x0
  96:	34a080e7          	jalr	842(ra) # 3dc <read>
  9a:	02a05363          	blez	a0,c0 <read_prime+0xc0>
        if(buff % prime != 0)
  9e:	fcc42783          	lw	a5,-52(s0)
  a2:	fdc42703          	lw	a4,-36(s0)
  a6:	02e7e7bb          	remw	a5,a5,a4
  aa:	d3e5                	beqz	a5,8a <read_prime+0x8a>
          write(pout[W], &buff, sizeof(int));
  ac:	4611                	li	a2,4
  ae:	fcc40593          	addi	a1,s0,-52
  b2:	fd442503          	lw	a0,-44(s0)
  b6:	00000097          	auipc	ra,0x0
  ba:	32e080e7          	jalr	814(ra) # 3e4 <write>
  be:	b7f1                	j	8a <read_prime+0x8a>
      close(pout[W]);
  c0:	fd442503          	lw	a0,-44(s0)
  c4:	00000097          	auipc	ra,0x0
  c8:	328080e7          	jalr	808(ra) # 3ec <close>
      close(pin[R]);
  cc:	4088                	lw	a0,0(s1)
  ce:	00000097          	auipc	ra,0x0
  d2:	31e080e7          	jalr	798(ra) # 3ec <close>
  d6:	b7a9                	j	20 <read_prime+0x20>

00000000000000d8 <main>:
}

int
main(int argc, char *argv[]) 
{
  d8:	7179                	addi	sp,sp,-48
  da:	f406                	sd	ra,40(sp)
  dc:	f022                	sd	s0,32(sp)
  de:	ec26                	sd	s1,24(sp)
  e0:	1800                	addi	s0,sp,48
  int i;
  int p[2];

  pipe(p);  /* create pipe and reserves fd 3,4 */
  e2:	fd040513          	addi	a0,s0,-48
  e6:	00000097          	auipc	ra,0x0
  ea:	2ee080e7          	jalr	750(ra) # 3d4 <pipe>
  if(fork() > 0)
  ee:	00000097          	auipc	ra,0x0
  f2:	2ce080e7          	jalr	718(ra) # 3bc <fork>
  f6:	04a05a63          	blez	a0,14a <main+0x72>
  {
    // parent
    // generate stream of integers
    for(i=2; i<=N; i++)
  fa:	4789                	li	a5,2
  fc:	fcf42e23          	sw	a5,-36(s0)
 100:	02300493          	li	s1,35
    {
      /* write(int fd, char *buf, int n) 
       * expects a *buf char. In that case, it wants the pointer
       * instead of actual data */
      write(p[W], &i, sizeof(int));
 104:	4611                	li	a2,4
 106:	fdc40593          	addi	a1,s0,-36
 10a:	fd442503          	lw	a0,-44(s0)
 10e:	00000097          	auipc	ra,0x0
 112:	2d6080e7          	jalr	726(ra) # 3e4 <write>
    for(i=2; i<=N; i++)
 116:	fdc42783          	lw	a5,-36(s0)
 11a:	2785                	addiw	a5,a5,1
 11c:	0007871b          	sext.w	a4,a5
 120:	fcf42e23          	sw	a5,-36(s0)
 124:	fee4d0e3          	bge	s1,a4,104 <main+0x2c>
    }
    close(p[R]);
 128:	fd042503          	lw	a0,-48(s0)
 12c:	00000097          	auipc	ra,0x0
 130:	2c0080e7          	jalr	704(ra) # 3ec <close>
    close(p[W]);
 134:	fd442503          	lw	a0,-44(s0)
 138:	00000097          	auipc	ra,0x0
 13c:	2b4080e7          	jalr	692(ra) # 3ec <close>
  }
  else
  {
    read_prime(p);
  }
  exit(0);
 140:	4501                	li	a0,0
 142:	00000097          	auipc	ra,0x0
 146:	282080e7          	jalr	642(ra) # 3c4 <exit>
    read_prime(p);
 14a:	fd040513          	addi	a0,s0,-48
 14e:	00000097          	auipc	ra,0x0
 152:	eb2080e7          	jalr	-334(ra) # 0 <read_prime>

0000000000000156 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 156:	1141                	addi	sp,sp,-16
 158:	e422                	sd	s0,8(sp)
 15a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 15c:	87aa                	mv	a5,a0
 15e:	0585                	addi	a1,a1,1
 160:	0785                	addi	a5,a5,1
 162:	fff5c703          	lbu	a4,-1(a1)
 166:	fee78fa3          	sb	a4,-1(a5)
 16a:	fb75                	bnez	a4,15e <strcpy+0x8>
    ;
  return os;
}
 16c:	6422                	ld	s0,8(sp)
 16e:	0141                	addi	sp,sp,16
 170:	8082                	ret

0000000000000172 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 172:	1141                	addi	sp,sp,-16
 174:	e422                	sd	s0,8(sp)
 176:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 178:	00054783          	lbu	a5,0(a0)
 17c:	cb91                	beqz	a5,190 <strcmp+0x1e>
 17e:	0005c703          	lbu	a4,0(a1)
 182:	00f71763          	bne	a4,a5,190 <strcmp+0x1e>
    p++, q++;
 186:	0505                	addi	a0,a0,1
 188:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 18a:	00054783          	lbu	a5,0(a0)
 18e:	fbe5                	bnez	a5,17e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 190:	0005c503          	lbu	a0,0(a1)
}
 194:	40a7853b          	subw	a0,a5,a0
 198:	6422                	ld	s0,8(sp)
 19a:	0141                	addi	sp,sp,16
 19c:	8082                	ret

000000000000019e <strlen>:

uint
strlen(const char *s)
{
 19e:	1141                	addi	sp,sp,-16
 1a0:	e422                	sd	s0,8(sp)
 1a2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1a4:	00054783          	lbu	a5,0(a0)
 1a8:	cf91                	beqz	a5,1c4 <strlen+0x26>
 1aa:	0505                	addi	a0,a0,1
 1ac:	87aa                	mv	a5,a0
 1ae:	4685                	li	a3,1
 1b0:	9e89                	subw	a3,a3,a0
 1b2:	00f6853b          	addw	a0,a3,a5
 1b6:	0785                	addi	a5,a5,1
 1b8:	fff7c703          	lbu	a4,-1(a5)
 1bc:	fb7d                	bnez	a4,1b2 <strlen+0x14>
    ;
  return n;
}
 1be:	6422                	ld	s0,8(sp)
 1c0:	0141                	addi	sp,sp,16
 1c2:	8082                	ret
  for(n = 0; s[n]; n++)
 1c4:	4501                	li	a0,0
 1c6:	bfe5                	j	1be <strlen+0x20>

00000000000001c8 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c8:	1141                	addi	sp,sp,-16
 1ca:	e422                	sd	s0,8(sp)
 1cc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1ce:	ca19                	beqz	a2,1e4 <memset+0x1c>
 1d0:	87aa                	mv	a5,a0
 1d2:	1602                	slli	a2,a2,0x20
 1d4:	9201                	srli	a2,a2,0x20
 1d6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1da:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1de:	0785                	addi	a5,a5,1
 1e0:	fee79de3          	bne	a5,a4,1da <memset+0x12>
  }
  return dst;
}
 1e4:	6422                	ld	s0,8(sp)
 1e6:	0141                	addi	sp,sp,16
 1e8:	8082                	ret

00000000000001ea <strchr>:

char*
strchr(const char *s, char c)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e422                	sd	s0,8(sp)
 1ee:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1f0:	00054783          	lbu	a5,0(a0)
 1f4:	cb99                	beqz	a5,20a <strchr+0x20>
    if(*s == c)
 1f6:	00f58763          	beq	a1,a5,204 <strchr+0x1a>
  for(; *s; s++)
 1fa:	0505                	addi	a0,a0,1
 1fc:	00054783          	lbu	a5,0(a0)
 200:	fbfd                	bnez	a5,1f6 <strchr+0xc>
      return (char*)s;
  return 0;
 202:	4501                	li	a0,0
}
 204:	6422                	ld	s0,8(sp)
 206:	0141                	addi	sp,sp,16
 208:	8082                	ret
  return 0;
 20a:	4501                	li	a0,0
 20c:	bfe5                	j	204 <strchr+0x1a>

000000000000020e <gets>:

char*
gets(char *buf, int max)
{
 20e:	711d                	addi	sp,sp,-96
 210:	ec86                	sd	ra,88(sp)
 212:	e8a2                	sd	s0,80(sp)
 214:	e4a6                	sd	s1,72(sp)
 216:	e0ca                	sd	s2,64(sp)
 218:	fc4e                	sd	s3,56(sp)
 21a:	f852                	sd	s4,48(sp)
 21c:	f456                	sd	s5,40(sp)
 21e:	f05a                	sd	s6,32(sp)
 220:	ec5e                	sd	s7,24(sp)
 222:	1080                	addi	s0,sp,96
 224:	8baa                	mv	s7,a0
 226:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 228:	892a                	mv	s2,a0
 22a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 22c:	4aa9                	li	s5,10
 22e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 230:	89a6                	mv	s3,s1
 232:	2485                	addiw	s1,s1,1
 234:	0344d863          	bge	s1,s4,264 <gets+0x56>
    cc = read(0, &c, 1);
 238:	4605                	li	a2,1
 23a:	faf40593          	addi	a1,s0,-81
 23e:	4501                	li	a0,0
 240:	00000097          	auipc	ra,0x0
 244:	19c080e7          	jalr	412(ra) # 3dc <read>
    if(cc < 1)
 248:	00a05e63          	blez	a0,264 <gets+0x56>
    buf[i++] = c;
 24c:	faf44783          	lbu	a5,-81(s0)
 250:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 254:	01578763          	beq	a5,s5,262 <gets+0x54>
 258:	0905                	addi	s2,s2,1
 25a:	fd679be3          	bne	a5,s6,230 <gets+0x22>
  for(i=0; i+1 < max; ){
 25e:	89a6                	mv	s3,s1
 260:	a011                	j	264 <gets+0x56>
 262:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 264:	99de                	add	s3,s3,s7
 266:	00098023          	sb	zero,0(s3)
  return buf;
}
 26a:	855e                	mv	a0,s7
 26c:	60e6                	ld	ra,88(sp)
 26e:	6446                	ld	s0,80(sp)
 270:	64a6                	ld	s1,72(sp)
 272:	6906                	ld	s2,64(sp)
 274:	79e2                	ld	s3,56(sp)
 276:	7a42                	ld	s4,48(sp)
 278:	7aa2                	ld	s5,40(sp)
 27a:	7b02                	ld	s6,32(sp)
 27c:	6be2                	ld	s7,24(sp)
 27e:	6125                	addi	sp,sp,96
 280:	8082                	ret

0000000000000282 <stat>:

int
stat(const char *n, struct stat *st)
{
 282:	1101                	addi	sp,sp,-32
 284:	ec06                	sd	ra,24(sp)
 286:	e822                	sd	s0,16(sp)
 288:	e426                	sd	s1,8(sp)
 28a:	e04a                	sd	s2,0(sp)
 28c:	1000                	addi	s0,sp,32
 28e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 290:	4581                	li	a1,0
 292:	00000097          	auipc	ra,0x0
 296:	172080e7          	jalr	370(ra) # 404 <open>
  if(fd < 0)
 29a:	02054563          	bltz	a0,2c4 <stat+0x42>
 29e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2a0:	85ca                	mv	a1,s2
 2a2:	00000097          	auipc	ra,0x0
 2a6:	17a080e7          	jalr	378(ra) # 41c <fstat>
 2aa:	892a                	mv	s2,a0
  close(fd);
 2ac:	8526                	mv	a0,s1
 2ae:	00000097          	auipc	ra,0x0
 2b2:	13e080e7          	jalr	318(ra) # 3ec <close>
  return r;
}
 2b6:	854a                	mv	a0,s2
 2b8:	60e2                	ld	ra,24(sp)
 2ba:	6442                	ld	s0,16(sp)
 2bc:	64a2                	ld	s1,8(sp)
 2be:	6902                	ld	s2,0(sp)
 2c0:	6105                	addi	sp,sp,32
 2c2:	8082                	ret
    return -1;
 2c4:	597d                	li	s2,-1
 2c6:	bfc5                	j	2b6 <stat+0x34>

00000000000002c8 <atoi>:

int
atoi(const char *s)
{
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e422                	sd	s0,8(sp)
 2cc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2ce:	00054603          	lbu	a2,0(a0)
 2d2:	fd06079b          	addiw	a5,a2,-48
 2d6:	0ff7f793          	andi	a5,a5,255
 2da:	4725                	li	a4,9
 2dc:	02f76963          	bltu	a4,a5,30e <atoi+0x46>
 2e0:	86aa                	mv	a3,a0
  n = 0;
 2e2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2e4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2e6:	0685                	addi	a3,a3,1
 2e8:	0025179b          	slliw	a5,a0,0x2
 2ec:	9fa9                	addw	a5,a5,a0
 2ee:	0017979b          	slliw	a5,a5,0x1
 2f2:	9fb1                	addw	a5,a5,a2
 2f4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2f8:	0006c603          	lbu	a2,0(a3)
 2fc:	fd06071b          	addiw	a4,a2,-48
 300:	0ff77713          	andi	a4,a4,255
 304:	fee5f1e3          	bgeu	a1,a4,2e6 <atoi+0x1e>
  return n;
}
 308:	6422                	ld	s0,8(sp)
 30a:	0141                	addi	sp,sp,16
 30c:	8082                	ret
  n = 0;
 30e:	4501                	li	a0,0
 310:	bfe5                	j	308 <atoi+0x40>

0000000000000312 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 312:	1141                	addi	sp,sp,-16
 314:	e422                	sd	s0,8(sp)
 316:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 318:	02b57463          	bgeu	a0,a1,340 <memmove+0x2e>
    while(n-- > 0)
 31c:	00c05f63          	blez	a2,33a <memmove+0x28>
 320:	1602                	slli	a2,a2,0x20
 322:	9201                	srli	a2,a2,0x20
 324:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 328:	872a                	mv	a4,a0
      *dst++ = *src++;
 32a:	0585                	addi	a1,a1,1
 32c:	0705                	addi	a4,a4,1
 32e:	fff5c683          	lbu	a3,-1(a1)
 332:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 336:	fee79ae3          	bne	a5,a4,32a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 33a:	6422                	ld	s0,8(sp)
 33c:	0141                	addi	sp,sp,16
 33e:	8082                	ret
    dst += n;
 340:	00c50733          	add	a4,a0,a2
    src += n;
 344:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 346:	fec05ae3          	blez	a2,33a <memmove+0x28>
 34a:	fff6079b          	addiw	a5,a2,-1
 34e:	1782                	slli	a5,a5,0x20
 350:	9381                	srli	a5,a5,0x20
 352:	fff7c793          	not	a5,a5
 356:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 358:	15fd                	addi	a1,a1,-1
 35a:	177d                	addi	a4,a4,-1
 35c:	0005c683          	lbu	a3,0(a1)
 360:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 364:	fee79ae3          	bne	a5,a4,358 <memmove+0x46>
 368:	bfc9                	j	33a <memmove+0x28>

000000000000036a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 36a:	1141                	addi	sp,sp,-16
 36c:	e422                	sd	s0,8(sp)
 36e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 370:	ca05                	beqz	a2,3a0 <memcmp+0x36>
 372:	fff6069b          	addiw	a3,a2,-1
 376:	1682                	slli	a3,a3,0x20
 378:	9281                	srli	a3,a3,0x20
 37a:	0685                	addi	a3,a3,1
 37c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 37e:	00054783          	lbu	a5,0(a0)
 382:	0005c703          	lbu	a4,0(a1)
 386:	00e79863          	bne	a5,a4,396 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 38a:	0505                	addi	a0,a0,1
    p2++;
 38c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 38e:	fed518e3          	bne	a0,a3,37e <memcmp+0x14>
  }
  return 0;
 392:	4501                	li	a0,0
 394:	a019                	j	39a <memcmp+0x30>
      return *p1 - *p2;
 396:	40e7853b          	subw	a0,a5,a4
}
 39a:	6422                	ld	s0,8(sp)
 39c:	0141                	addi	sp,sp,16
 39e:	8082                	ret
  return 0;
 3a0:	4501                	li	a0,0
 3a2:	bfe5                	j	39a <memcmp+0x30>

00000000000003a4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3a4:	1141                	addi	sp,sp,-16
 3a6:	e406                	sd	ra,8(sp)
 3a8:	e022                	sd	s0,0(sp)
 3aa:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3ac:	00000097          	auipc	ra,0x0
 3b0:	f66080e7          	jalr	-154(ra) # 312 <memmove>
}
 3b4:	60a2                	ld	ra,8(sp)
 3b6:	6402                	ld	s0,0(sp)
 3b8:	0141                	addi	sp,sp,16
 3ba:	8082                	ret

00000000000003bc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3bc:	4885                	li	a7,1
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3c4:	4889                	li	a7,2
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <wait>:
.global wait
wait:
 li a7, SYS_wait
 3cc:	488d                	li	a7,3
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3d4:	4891                	li	a7,4
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <read>:
.global read
read:
 li a7, SYS_read
 3dc:	4895                	li	a7,5
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <write>:
.global write
write:
 li a7, SYS_write
 3e4:	48c1                	li	a7,16
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <close>:
.global close
close:
 li a7, SYS_close
 3ec:	48d5                	li	a7,21
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3f4:	4899                	li	a7,6
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <exec>:
.global exec
exec:
 li a7, SYS_exec
 3fc:	489d                	li	a7,7
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <open>:
.global open
open:
 li a7, SYS_open
 404:	48bd                	li	a7,15
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 40c:	48c5                	li	a7,17
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 414:	48c9                	li	a7,18
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 41c:	48a1                	li	a7,8
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <link>:
.global link
link:
 li a7, SYS_link
 424:	48cd                	li	a7,19
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 42c:	48d1                	li	a7,20
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 434:	48a5                	li	a7,9
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <dup>:
.global dup
dup:
 li a7, SYS_dup
 43c:	48a9                	li	a7,10
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 444:	48ad                	li	a7,11
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 44c:	48b1                	li	a7,12
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 454:	48b5                	li	a7,13
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 45c:	48b9                	li	a7,14
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 464:	1101                	addi	sp,sp,-32
 466:	ec06                	sd	ra,24(sp)
 468:	e822                	sd	s0,16(sp)
 46a:	1000                	addi	s0,sp,32
 46c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 470:	4605                	li	a2,1
 472:	fef40593          	addi	a1,s0,-17
 476:	00000097          	auipc	ra,0x0
 47a:	f6e080e7          	jalr	-146(ra) # 3e4 <write>
}
 47e:	60e2                	ld	ra,24(sp)
 480:	6442                	ld	s0,16(sp)
 482:	6105                	addi	sp,sp,32
 484:	8082                	ret

0000000000000486 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 486:	7139                	addi	sp,sp,-64
 488:	fc06                	sd	ra,56(sp)
 48a:	f822                	sd	s0,48(sp)
 48c:	f426                	sd	s1,40(sp)
 48e:	f04a                	sd	s2,32(sp)
 490:	ec4e                	sd	s3,24(sp)
 492:	0080                	addi	s0,sp,64
 494:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 496:	c299                	beqz	a3,49c <printint+0x16>
 498:	0805c863          	bltz	a1,528 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 49c:	2581                	sext.w	a1,a1
  neg = 0;
 49e:	4881                	li	a7,0
 4a0:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4a4:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4a6:	2601                	sext.w	a2,a2
 4a8:	00000517          	auipc	a0,0x0
 4ac:	45050513          	addi	a0,a0,1104 # 8f8 <digits>
 4b0:	883a                	mv	a6,a4
 4b2:	2705                	addiw	a4,a4,1
 4b4:	02c5f7bb          	remuw	a5,a1,a2
 4b8:	1782                	slli	a5,a5,0x20
 4ba:	9381                	srli	a5,a5,0x20
 4bc:	97aa                	add	a5,a5,a0
 4be:	0007c783          	lbu	a5,0(a5)
 4c2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4c6:	0005879b          	sext.w	a5,a1
 4ca:	02c5d5bb          	divuw	a1,a1,a2
 4ce:	0685                	addi	a3,a3,1
 4d0:	fec7f0e3          	bgeu	a5,a2,4b0 <printint+0x2a>
  if(neg)
 4d4:	00088b63          	beqz	a7,4ea <printint+0x64>
    buf[i++] = '-';
 4d8:	fd040793          	addi	a5,s0,-48
 4dc:	973e                	add	a4,a4,a5
 4de:	02d00793          	li	a5,45
 4e2:	fef70823          	sb	a5,-16(a4)
 4e6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4ea:	02e05863          	blez	a4,51a <printint+0x94>
 4ee:	fc040793          	addi	a5,s0,-64
 4f2:	00e78933          	add	s2,a5,a4
 4f6:	fff78993          	addi	s3,a5,-1
 4fa:	99ba                	add	s3,s3,a4
 4fc:	377d                	addiw	a4,a4,-1
 4fe:	1702                	slli	a4,a4,0x20
 500:	9301                	srli	a4,a4,0x20
 502:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 506:	fff94583          	lbu	a1,-1(s2)
 50a:	8526                	mv	a0,s1
 50c:	00000097          	auipc	ra,0x0
 510:	f58080e7          	jalr	-168(ra) # 464 <putc>
  while(--i >= 0)
 514:	197d                	addi	s2,s2,-1
 516:	ff3918e3          	bne	s2,s3,506 <printint+0x80>
}
 51a:	70e2                	ld	ra,56(sp)
 51c:	7442                	ld	s0,48(sp)
 51e:	74a2                	ld	s1,40(sp)
 520:	7902                	ld	s2,32(sp)
 522:	69e2                	ld	s3,24(sp)
 524:	6121                	addi	sp,sp,64
 526:	8082                	ret
    x = -xx;
 528:	40b005bb          	negw	a1,a1
    neg = 1;
 52c:	4885                	li	a7,1
    x = -xx;
 52e:	bf8d                	j	4a0 <printint+0x1a>

0000000000000530 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 530:	7119                	addi	sp,sp,-128
 532:	fc86                	sd	ra,120(sp)
 534:	f8a2                	sd	s0,112(sp)
 536:	f4a6                	sd	s1,104(sp)
 538:	f0ca                	sd	s2,96(sp)
 53a:	ecce                	sd	s3,88(sp)
 53c:	e8d2                	sd	s4,80(sp)
 53e:	e4d6                	sd	s5,72(sp)
 540:	e0da                	sd	s6,64(sp)
 542:	fc5e                	sd	s7,56(sp)
 544:	f862                	sd	s8,48(sp)
 546:	f466                	sd	s9,40(sp)
 548:	f06a                	sd	s10,32(sp)
 54a:	ec6e                	sd	s11,24(sp)
 54c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 54e:	0005c903          	lbu	s2,0(a1)
 552:	18090f63          	beqz	s2,6f0 <vprintf+0x1c0>
 556:	8aaa                	mv	s5,a0
 558:	8b32                	mv	s6,a2
 55a:	00158493          	addi	s1,a1,1
  state = 0;
 55e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 560:	02500a13          	li	s4,37
      if(c == 'd'){
 564:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 568:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 56c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 570:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 574:	00000b97          	auipc	s7,0x0
 578:	384b8b93          	addi	s7,s7,900 # 8f8 <digits>
 57c:	a839                	j	59a <vprintf+0x6a>
        putc(fd, c);
 57e:	85ca                	mv	a1,s2
 580:	8556                	mv	a0,s5
 582:	00000097          	auipc	ra,0x0
 586:	ee2080e7          	jalr	-286(ra) # 464 <putc>
 58a:	a019                	j	590 <vprintf+0x60>
    } else if(state == '%'){
 58c:	01498f63          	beq	s3,s4,5aa <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 590:	0485                	addi	s1,s1,1
 592:	fff4c903          	lbu	s2,-1(s1)
 596:	14090d63          	beqz	s2,6f0 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 59a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 59e:	fe0997e3          	bnez	s3,58c <vprintf+0x5c>
      if(c == '%'){
 5a2:	fd479ee3          	bne	a5,s4,57e <vprintf+0x4e>
        state = '%';
 5a6:	89be                	mv	s3,a5
 5a8:	b7e5                	j	590 <vprintf+0x60>
      if(c == 'd'){
 5aa:	05878063          	beq	a5,s8,5ea <vprintf+0xba>
      } else if(c == 'l') {
 5ae:	05978c63          	beq	a5,s9,606 <vprintf+0xd6>
      } else if(c == 'x') {
 5b2:	07a78863          	beq	a5,s10,622 <vprintf+0xf2>
      } else if(c == 'p') {
 5b6:	09b78463          	beq	a5,s11,63e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5ba:	07300713          	li	a4,115
 5be:	0ce78663          	beq	a5,a4,68a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5c2:	06300713          	li	a4,99
 5c6:	0ee78e63          	beq	a5,a4,6c2 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5ca:	11478863          	beq	a5,s4,6da <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5ce:	85d2                	mv	a1,s4
 5d0:	8556                	mv	a0,s5
 5d2:	00000097          	auipc	ra,0x0
 5d6:	e92080e7          	jalr	-366(ra) # 464 <putc>
        putc(fd, c);
 5da:	85ca                	mv	a1,s2
 5dc:	8556                	mv	a0,s5
 5de:	00000097          	auipc	ra,0x0
 5e2:	e86080e7          	jalr	-378(ra) # 464 <putc>
      }
      state = 0;
 5e6:	4981                	li	s3,0
 5e8:	b765                	j	590 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5ea:	008b0913          	addi	s2,s6,8
 5ee:	4685                	li	a3,1
 5f0:	4629                	li	a2,10
 5f2:	000b2583          	lw	a1,0(s6)
 5f6:	8556                	mv	a0,s5
 5f8:	00000097          	auipc	ra,0x0
 5fc:	e8e080e7          	jalr	-370(ra) # 486 <printint>
 600:	8b4a                	mv	s6,s2
      state = 0;
 602:	4981                	li	s3,0
 604:	b771                	j	590 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 606:	008b0913          	addi	s2,s6,8
 60a:	4681                	li	a3,0
 60c:	4629                	li	a2,10
 60e:	000b2583          	lw	a1,0(s6)
 612:	8556                	mv	a0,s5
 614:	00000097          	auipc	ra,0x0
 618:	e72080e7          	jalr	-398(ra) # 486 <printint>
 61c:	8b4a                	mv	s6,s2
      state = 0;
 61e:	4981                	li	s3,0
 620:	bf85                	j	590 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 622:	008b0913          	addi	s2,s6,8
 626:	4681                	li	a3,0
 628:	4641                	li	a2,16
 62a:	000b2583          	lw	a1,0(s6)
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	e56080e7          	jalr	-426(ra) # 486 <printint>
 638:	8b4a                	mv	s6,s2
      state = 0;
 63a:	4981                	li	s3,0
 63c:	bf91                	j	590 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 63e:	008b0793          	addi	a5,s6,8
 642:	f8f43423          	sd	a5,-120(s0)
 646:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 64a:	03000593          	li	a1,48
 64e:	8556                	mv	a0,s5
 650:	00000097          	auipc	ra,0x0
 654:	e14080e7          	jalr	-492(ra) # 464 <putc>
  putc(fd, 'x');
 658:	85ea                	mv	a1,s10
 65a:	8556                	mv	a0,s5
 65c:	00000097          	auipc	ra,0x0
 660:	e08080e7          	jalr	-504(ra) # 464 <putc>
 664:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 666:	03c9d793          	srli	a5,s3,0x3c
 66a:	97de                	add	a5,a5,s7
 66c:	0007c583          	lbu	a1,0(a5)
 670:	8556                	mv	a0,s5
 672:	00000097          	auipc	ra,0x0
 676:	df2080e7          	jalr	-526(ra) # 464 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 67a:	0992                	slli	s3,s3,0x4
 67c:	397d                	addiw	s2,s2,-1
 67e:	fe0914e3          	bnez	s2,666 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 682:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 686:	4981                	li	s3,0
 688:	b721                	j	590 <vprintf+0x60>
        s = va_arg(ap, char*);
 68a:	008b0993          	addi	s3,s6,8
 68e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 692:	02090163          	beqz	s2,6b4 <vprintf+0x184>
        while(*s != 0){
 696:	00094583          	lbu	a1,0(s2)
 69a:	c9a1                	beqz	a1,6ea <vprintf+0x1ba>
          putc(fd, *s);
 69c:	8556                	mv	a0,s5
 69e:	00000097          	auipc	ra,0x0
 6a2:	dc6080e7          	jalr	-570(ra) # 464 <putc>
          s++;
 6a6:	0905                	addi	s2,s2,1
        while(*s != 0){
 6a8:	00094583          	lbu	a1,0(s2)
 6ac:	f9e5                	bnez	a1,69c <vprintf+0x16c>
        s = va_arg(ap, char*);
 6ae:	8b4e                	mv	s6,s3
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	bdf9                	j	590 <vprintf+0x60>
          s = "(null)";
 6b4:	00000917          	auipc	s2,0x0
 6b8:	23c90913          	addi	s2,s2,572 # 8f0 <malloc+0xf6>
        while(*s != 0){
 6bc:	02800593          	li	a1,40
 6c0:	bff1                	j	69c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6c2:	008b0913          	addi	s2,s6,8
 6c6:	000b4583          	lbu	a1,0(s6)
 6ca:	8556                	mv	a0,s5
 6cc:	00000097          	auipc	ra,0x0
 6d0:	d98080e7          	jalr	-616(ra) # 464 <putc>
 6d4:	8b4a                	mv	s6,s2
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	bd65                	j	590 <vprintf+0x60>
        putc(fd, c);
 6da:	85d2                	mv	a1,s4
 6dc:	8556                	mv	a0,s5
 6de:	00000097          	auipc	ra,0x0
 6e2:	d86080e7          	jalr	-634(ra) # 464 <putc>
      state = 0;
 6e6:	4981                	li	s3,0
 6e8:	b565                	j	590 <vprintf+0x60>
        s = va_arg(ap, char*);
 6ea:	8b4e                	mv	s6,s3
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	b54d                	j	590 <vprintf+0x60>
    }
  }
}
 6f0:	70e6                	ld	ra,120(sp)
 6f2:	7446                	ld	s0,112(sp)
 6f4:	74a6                	ld	s1,104(sp)
 6f6:	7906                	ld	s2,96(sp)
 6f8:	69e6                	ld	s3,88(sp)
 6fa:	6a46                	ld	s4,80(sp)
 6fc:	6aa6                	ld	s5,72(sp)
 6fe:	6b06                	ld	s6,64(sp)
 700:	7be2                	ld	s7,56(sp)
 702:	7c42                	ld	s8,48(sp)
 704:	7ca2                	ld	s9,40(sp)
 706:	7d02                	ld	s10,32(sp)
 708:	6de2                	ld	s11,24(sp)
 70a:	6109                	addi	sp,sp,128
 70c:	8082                	ret

000000000000070e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 70e:	715d                	addi	sp,sp,-80
 710:	ec06                	sd	ra,24(sp)
 712:	e822                	sd	s0,16(sp)
 714:	1000                	addi	s0,sp,32
 716:	e010                	sd	a2,0(s0)
 718:	e414                	sd	a3,8(s0)
 71a:	e818                	sd	a4,16(s0)
 71c:	ec1c                	sd	a5,24(s0)
 71e:	03043023          	sd	a6,32(s0)
 722:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 726:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 72a:	8622                	mv	a2,s0
 72c:	00000097          	auipc	ra,0x0
 730:	e04080e7          	jalr	-508(ra) # 530 <vprintf>
}
 734:	60e2                	ld	ra,24(sp)
 736:	6442                	ld	s0,16(sp)
 738:	6161                	addi	sp,sp,80
 73a:	8082                	ret

000000000000073c <printf>:

void
printf(const char *fmt, ...)
{
 73c:	711d                	addi	sp,sp,-96
 73e:	ec06                	sd	ra,24(sp)
 740:	e822                	sd	s0,16(sp)
 742:	1000                	addi	s0,sp,32
 744:	e40c                	sd	a1,8(s0)
 746:	e810                	sd	a2,16(s0)
 748:	ec14                	sd	a3,24(s0)
 74a:	f018                	sd	a4,32(s0)
 74c:	f41c                	sd	a5,40(s0)
 74e:	03043823          	sd	a6,48(s0)
 752:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 756:	00840613          	addi	a2,s0,8
 75a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 75e:	85aa                	mv	a1,a0
 760:	4505                	li	a0,1
 762:	00000097          	auipc	ra,0x0
 766:	dce080e7          	jalr	-562(ra) # 530 <vprintf>
}
 76a:	60e2                	ld	ra,24(sp)
 76c:	6442                	ld	s0,16(sp)
 76e:	6125                	addi	sp,sp,96
 770:	8082                	ret

0000000000000772 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 772:	1141                	addi	sp,sp,-16
 774:	e422                	sd	s0,8(sp)
 776:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 778:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77c:	00000797          	auipc	a5,0x0
 780:	1947b783          	ld	a5,404(a5) # 910 <freep>
 784:	a805                	j	7b4 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 786:	4618                	lw	a4,8(a2)
 788:	9db9                	addw	a1,a1,a4
 78a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 78e:	6398                	ld	a4,0(a5)
 790:	6318                	ld	a4,0(a4)
 792:	fee53823          	sd	a4,-16(a0)
 796:	a091                	j	7da <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 798:	ff852703          	lw	a4,-8(a0)
 79c:	9e39                	addw	a2,a2,a4
 79e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7a0:	ff053703          	ld	a4,-16(a0)
 7a4:	e398                	sd	a4,0(a5)
 7a6:	a099                	j	7ec <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a8:	6398                	ld	a4,0(a5)
 7aa:	00e7e463          	bltu	a5,a4,7b2 <free+0x40>
 7ae:	00e6ea63          	bltu	a3,a4,7c2 <free+0x50>
{
 7b2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b4:	fed7fae3          	bgeu	a5,a3,7a8 <free+0x36>
 7b8:	6398                	ld	a4,0(a5)
 7ba:	00e6e463          	bltu	a3,a4,7c2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7be:	fee7eae3          	bltu	a5,a4,7b2 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7c2:	ff852583          	lw	a1,-8(a0)
 7c6:	6390                	ld	a2,0(a5)
 7c8:	02059813          	slli	a6,a1,0x20
 7cc:	01c85713          	srli	a4,a6,0x1c
 7d0:	9736                	add	a4,a4,a3
 7d2:	fae60ae3          	beq	a2,a4,786 <free+0x14>
    bp->s.ptr = p->s.ptr;
 7d6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7da:	4790                	lw	a2,8(a5)
 7dc:	02061593          	slli	a1,a2,0x20
 7e0:	01c5d713          	srli	a4,a1,0x1c
 7e4:	973e                	add	a4,a4,a5
 7e6:	fae689e3          	beq	a3,a4,798 <free+0x26>
  } else
    p->s.ptr = bp;
 7ea:	e394                	sd	a3,0(a5)
  freep = p;
 7ec:	00000717          	auipc	a4,0x0
 7f0:	12f73223          	sd	a5,292(a4) # 910 <freep>
}
 7f4:	6422                	ld	s0,8(sp)
 7f6:	0141                	addi	sp,sp,16
 7f8:	8082                	ret

00000000000007fa <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7fa:	7139                	addi	sp,sp,-64
 7fc:	fc06                	sd	ra,56(sp)
 7fe:	f822                	sd	s0,48(sp)
 800:	f426                	sd	s1,40(sp)
 802:	f04a                	sd	s2,32(sp)
 804:	ec4e                	sd	s3,24(sp)
 806:	e852                	sd	s4,16(sp)
 808:	e456                	sd	s5,8(sp)
 80a:	e05a                	sd	s6,0(sp)
 80c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 80e:	02051493          	slli	s1,a0,0x20
 812:	9081                	srli	s1,s1,0x20
 814:	04bd                	addi	s1,s1,15
 816:	8091                	srli	s1,s1,0x4
 818:	0014899b          	addiw	s3,s1,1
 81c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 81e:	00000517          	auipc	a0,0x0
 822:	0f253503          	ld	a0,242(a0) # 910 <freep>
 826:	c515                	beqz	a0,852 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 828:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 82a:	4798                	lw	a4,8(a5)
 82c:	02977f63          	bgeu	a4,s1,86a <malloc+0x70>
 830:	8a4e                	mv	s4,s3
 832:	0009871b          	sext.w	a4,s3
 836:	6685                	lui	a3,0x1
 838:	00d77363          	bgeu	a4,a3,83e <malloc+0x44>
 83c:	6a05                	lui	s4,0x1
 83e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 842:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 846:	00000917          	auipc	s2,0x0
 84a:	0ca90913          	addi	s2,s2,202 # 910 <freep>
  if(p == (char*)-1)
 84e:	5afd                	li	s5,-1
 850:	a895                	j	8c4 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 852:	00000797          	auipc	a5,0x0
 856:	0c678793          	addi	a5,a5,198 # 918 <base>
 85a:	00000717          	auipc	a4,0x0
 85e:	0af73b23          	sd	a5,182(a4) # 910 <freep>
 862:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 864:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 868:	b7e1                	j	830 <malloc+0x36>
      if(p->s.size == nunits)
 86a:	02e48c63          	beq	s1,a4,8a2 <malloc+0xa8>
        p->s.size -= nunits;
 86e:	4137073b          	subw	a4,a4,s3
 872:	c798                	sw	a4,8(a5)
        p += p->s.size;
 874:	02071693          	slli	a3,a4,0x20
 878:	01c6d713          	srli	a4,a3,0x1c
 87c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 87e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 882:	00000717          	auipc	a4,0x0
 886:	08a73723          	sd	a0,142(a4) # 910 <freep>
      return (void*)(p + 1);
 88a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 88e:	70e2                	ld	ra,56(sp)
 890:	7442                	ld	s0,48(sp)
 892:	74a2                	ld	s1,40(sp)
 894:	7902                	ld	s2,32(sp)
 896:	69e2                	ld	s3,24(sp)
 898:	6a42                	ld	s4,16(sp)
 89a:	6aa2                	ld	s5,8(sp)
 89c:	6b02                	ld	s6,0(sp)
 89e:	6121                	addi	sp,sp,64
 8a0:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8a2:	6398                	ld	a4,0(a5)
 8a4:	e118                	sd	a4,0(a0)
 8a6:	bff1                	j	882 <malloc+0x88>
  hp->s.size = nu;
 8a8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ac:	0541                	addi	a0,a0,16
 8ae:	00000097          	auipc	ra,0x0
 8b2:	ec4080e7          	jalr	-316(ra) # 772 <free>
  return freep;
 8b6:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8ba:	d971                	beqz	a0,88e <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8bc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8be:	4798                	lw	a4,8(a5)
 8c0:	fa9775e3          	bgeu	a4,s1,86a <malloc+0x70>
    if(p == freep)
 8c4:	00093703          	ld	a4,0(s2)
 8c8:	853e                	mv	a0,a5
 8ca:	fef719e3          	bne	a4,a5,8bc <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8ce:	8552                	mv	a0,s4
 8d0:	00000097          	auipc	ra,0x0
 8d4:	b7c080e7          	jalr	-1156(ra) # 44c <sbrk>
  if(p == (char*)-1)
 8d8:	fd5518e3          	bne	a0,s5,8a8 <malloc+0xae>
        return 0;
 8dc:	4501                	li	a0,0
 8de:	bf45                	j	88e <malloc+0x94>
