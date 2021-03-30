
user/_sysinfotest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <sinfo>:
#include "kernel/sysinfo.h"
#include "user/user.h"


void
sinfo(struct sysinfo *info) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if (sysinfo(info) < 0) {
   8:	00000097          	auipc	ra,0x0
   c:	64e080e7          	jalr	1614(ra) # 656 <sysinfo>
  10:	00054663          	bltz	a0,1c <sinfo+0x1c>
    printf("FAIL: sysinfo failed");
    exit(1);
  }
}
  14:	60a2                	ld	ra,8(sp)
  16:	6402                	ld	s0,0(sp)
  18:	0141                	addi	sp,sp,16
  1a:	8082                	ret
    printf("FAIL: sysinfo failed");
  1c:	00001517          	auipc	a0,0x1
  20:	ac450513          	addi	a0,a0,-1340 # ae0 <malloc+0xec>
  24:	00001097          	auipc	ra,0x1
  28:	912080e7          	jalr	-1774(ra) # 936 <printf>
    exit(1);
  2c:	4505                	li	a0,1
  2e:	00000097          	auipc	ra,0x0
  32:	580080e7          	jalr	1408(ra) # 5ae <exit>

0000000000000036 <countfree>:
//
// use sbrk() to count how many free physical memory pages there are.
//
int
countfree()
{
  36:	7139                	addi	sp,sp,-64
  38:	fc06                	sd	ra,56(sp)
  3a:	f822                	sd	s0,48(sp)
  3c:	f426                	sd	s1,40(sp)
  3e:	f04a                	sd	s2,32(sp)
  40:	ec4e                	sd	s3,24(sp)
  42:	e852                	sd	s4,16(sp)
  44:	0080                	addi	s0,sp,64
  uint64 sz0 = (uint64)sbrk(0);
  46:	4501                	li	a0,0
  48:	00000097          	auipc	ra,0x0
  4c:	5ee080e7          	jalr	1518(ra) # 636 <sbrk>
  50:	8a2a                	mv	s4,a0
  struct sysinfo info;
  int n = 0;
  52:	4481                	li	s1,0

  while(1){
    if((uint64)sbrk(PGSIZE) == 0xffffffffffffffff){
  54:	597d                	li	s2,-1
      break;
    }
    n += PGSIZE;
  56:	6985                	lui	s3,0x1
  58:	a019                	j	5e <countfree+0x28>
  5a:	009984bb          	addw	s1,s3,s1
    if((uint64)sbrk(PGSIZE) == 0xffffffffffffffff){
  5e:	6505                	lui	a0,0x1
  60:	00000097          	auipc	ra,0x0
  64:	5d6080e7          	jalr	1494(ra) # 636 <sbrk>
  68:	ff2519e3          	bne	a0,s2,5a <countfree+0x24>
  }
  sinfo(&info);
  6c:	fc040513          	addi	a0,s0,-64
  70:	00000097          	auipc	ra,0x0
  74:	f90080e7          	jalr	-112(ra) # 0 <sinfo>
  if (info.freemem != 0) {
  78:	fc043583          	ld	a1,-64(s0)
  7c:	e58d                	bnez	a1,a6 <countfree+0x70>
    printf("FAIL: there is no free mem, but sysinfo.freemem=%d\n",
      info.freemem);
    exit(1);
  }
  sbrk(-((uint64)sbrk(0) - sz0));
  7e:	4501                	li	a0,0
  80:	00000097          	auipc	ra,0x0
  84:	5b6080e7          	jalr	1462(ra) # 636 <sbrk>
  88:	40aa053b          	subw	a0,s4,a0
  8c:	00000097          	auipc	ra,0x0
  90:	5aa080e7          	jalr	1450(ra) # 636 <sbrk>
  return n;
}
  94:	8526                	mv	a0,s1
  96:	70e2                	ld	ra,56(sp)
  98:	7442                	ld	s0,48(sp)
  9a:	74a2                	ld	s1,40(sp)
  9c:	7902                	ld	s2,32(sp)
  9e:	69e2                	ld	s3,24(sp)
  a0:	6a42                	ld	s4,16(sp)
  a2:	6121                	addi	sp,sp,64
  a4:	8082                	ret
    printf("FAIL: there is no free mem, but sysinfo.freemem=%d\n",
  a6:	00001517          	auipc	a0,0x1
  aa:	a5250513          	addi	a0,a0,-1454 # af8 <malloc+0x104>
  ae:	00001097          	auipc	ra,0x1
  b2:	888080e7          	jalr	-1912(ra) # 936 <printf>
    exit(1);
  b6:	4505                	li	a0,1
  b8:	00000097          	auipc	ra,0x0
  bc:	4f6080e7          	jalr	1270(ra) # 5ae <exit>

00000000000000c0 <testmem>:

void
testmem() {
  c0:	7179                	addi	sp,sp,-48
  c2:	f406                	sd	ra,40(sp)
  c4:	f022                	sd	s0,32(sp)
  c6:	ec26                	sd	s1,24(sp)
  c8:	e84a                	sd	s2,16(sp)
  ca:	1800                	addi	s0,sp,48
  struct sysinfo info;
  uint64 n = countfree();
  cc:	00000097          	auipc	ra,0x0
  d0:	f6a080e7          	jalr	-150(ra) # 36 <countfree>
  d4:	84aa                	mv	s1,a0
  
  sinfo(&info);
  d6:	fd040513          	addi	a0,s0,-48
  da:	00000097          	auipc	ra,0x0
  de:	f26080e7          	jalr	-218(ra) # 0 <sinfo>

  if (info.freemem!= n) {
  e2:	fd043583          	ld	a1,-48(s0)
  e6:	04959e63          	bne	a1,s1,142 <testmem+0x82>
    printf("FAIL: free mem %d (bytes) instead of %d\n", info.freemem, n);
    exit(1);
  }
  
  if((uint64)sbrk(PGSIZE) == 0xffffffffffffffff){
  ea:	6505                	lui	a0,0x1
  ec:	00000097          	auipc	ra,0x0
  f0:	54a080e7          	jalr	1354(ra) # 636 <sbrk>
  f4:	57fd                	li	a5,-1
  f6:	06f50463          	beq	a0,a5,15e <testmem+0x9e>
    printf("sbrk failed");
    exit(1);
  }

  sinfo(&info);
  fa:	fd040513          	addi	a0,s0,-48
  fe:	00000097          	auipc	ra,0x0
 102:	f02080e7          	jalr	-254(ra) # 0 <sinfo>
    
  if (info.freemem != n-PGSIZE) {
 106:	fd043603          	ld	a2,-48(s0)
 10a:	75fd                	lui	a1,0xfffff
 10c:	95a6                	add	a1,a1,s1
 10e:	06b61563          	bne	a2,a1,178 <testmem+0xb8>
    printf("FAIL: free mem %d (bytes) instead of %d\n", n-PGSIZE, info.freemem);
    exit(1);
  }
  
  if((uint64)sbrk(-PGSIZE) == 0xffffffffffffffff){
 112:	757d                	lui	a0,0xfffff
 114:	00000097          	auipc	ra,0x0
 118:	522080e7          	jalr	1314(ra) # 636 <sbrk>
 11c:	57fd                	li	a5,-1
 11e:	06f50a63          	beq	a0,a5,192 <testmem+0xd2>
    printf("sbrk failed");
    exit(1);
  }

  sinfo(&info);
 122:	fd040513          	addi	a0,s0,-48
 126:	00000097          	auipc	ra,0x0
 12a:	eda080e7          	jalr	-294(ra) # 0 <sinfo>
    
  if (info.freemem != n) {
 12e:	fd043603          	ld	a2,-48(s0)
 132:	06961d63          	bne	a2,s1,1ac <testmem+0xec>
    printf("FAIL: free mem %d (bytes) instead of %d\n", n, info.freemem);
    exit(1);
  }
}
 136:	70a2                	ld	ra,40(sp)
 138:	7402                	ld	s0,32(sp)
 13a:	64e2                	ld	s1,24(sp)
 13c:	6942                	ld	s2,16(sp)
 13e:	6145                	addi	sp,sp,48
 140:	8082                	ret
    printf("FAIL: free mem %d (bytes) instead of %d\n", info.freemem, n);
 142:	8626                	mv	a2,s1
 144:	00001517          	auipc	a0,0x1
 148:	9ec50513          	addi	a0,a0,-1556 # b30 <malloc+0x13c>
 14c:	00000097          	auipc	ra,0x0
 150:	7ea080e7          	jalr	2026(ra) # 936 <printf>
    exit(1);
 154:	4505                	li	a0,1
 156:	00000097          	auipc	ra,0x0
 15a:	458080e7          	jalr	1112(ra) # 5ae <exit>
    printf("sbrk failed");
 15e:	00001517          	auipc	a0,0x1
 162:	a0250513          	addi	a0,a0,-1534 # b60 <malloc+0x16c>
 166:	00000097          	auipc	ra,0x0
 16a:	7d0080e7          	jalr	2000(ra) # 936 <printf>
    exit(1);
 16e:	4505                	li	a0,1
 170:	00000097          	auipc	ra,0x0
 174:	43e080e7          	jalr	1086(ra) # 5ae <exit>
    printf("FAIL: free mem %d (bytes) instead of %d\n", n-PGSIZE, info.freemem);
 178:	00001517          	auipc	a0,0x1
 17c:	9b850513          	addi	a0,a0,-1608 # b30 <malloc+0x13c>
 180:	00000097          	auipc	ra,0x0
 184:	7b6080e7          	jalr	1974(ra) # 936 <printf>
    exit(1);
 188:	4505                	li	a0,1
 18a:	00000097          	auipc	ra,0x0
 18e:	424080e7          	jalr	1060(ra) # 5ae <exit>
    printf("sbrk failed");
 192:	00001517          	auipc	a0,0x1
 196:	9ce50513          	addi	a0,a0,-1586 # b60 <malloc+0x16c>
 19a:	00000097          	auipc	ra,0x0
 19e:	79c080e7          	jalr	1948(ra) # 936 <printf>
    exit(1);
 1a2:	4505                	li	a0,1
 1a4:	00000097          	auipc	ra,0x0
 1a8:	40a080e7          	jalr	1034(ra) # 5ae <exit>
    printf("FAIL: free mem %d (bytes) instead of %d\n", n, info.freemem);
 1ac:	85a6                	mv	a1,s1
 1ae:	00001517          	auipc	a0,0x1
 1b2:	98250513          	addi	a0,a0,-1662 # b30 <malloc+0x13c>
 1b6:	00000097          	auipc	ra,0x0
 1ba:	780080e7          	jalr	1920(ra) # 936 <printf>
    exit(1);
 1be:	4505                	li	a0,1
 1c0:	00000097          	auipc	ra,0x0
 1c4:	3ee080e7          	jalr	1006(ra) # 5ae <exit>

00000000000001c8 <testcall>:

void
testcall() {
 1c8:	1101                	addi	sp,sp,-32
 1ca:	ec06                	sd	ra,24(sp)
 1cc:	e822                	sd	s0,16(sp)
 1ce:	1000                	addi	s0,sp,32
  struct sysinfo info;
  
  if (sysinfo(&info) < 0) {
 1d0:	fe040513          	addi	a0,s0,-32
 1d4:	00000097          	auipc	ra,0x0
 1d8:	482080e7          	jalr	1154(ra) # 656 <sysinfo>
 1dc:	02054163          	bltz	a0,1fe <testcall+0x36>
    printf("FAIL: sysinfo failed\n");
    exit(1);
  }

  if (sysinfo((struct sysinfo *) 0xeaeb0b5b00002f5e) !=  0xffffffffffffffff) {
 1e0:	00001517          	auipc	a0,0x1
 1e4:	a7853503          	ld	a0,-1416(a0) # c58 <__SDATA_BEGIN__>
 1e8:	00000097          	auipc	ra,0x0
 1ec:	46e080e7          	jalr	1134(ra) # 656 <sysinfo>
 1f0:	57fd                	li	a5,-1
 1f2:	02f51363          	bne	a0,a5,218 <testcall+0x50>
    printf("FAIL: sysinfo succeeded with bad argument\n");
    exit(1);
  }
}
 1f6:	60e2                	ld	ra,24(sp)
 1f8:	6442                	ld	s0,16(sp)
 1fa:	6105                	addi	sp,sp,32
 1fc:	8082                	ret
    printf("FAIL: sysinfo failed\n");
 1fe:	00001517          	auipc	a0,0x1
 202:	97250513          	addi	a0,a0,-1678 # b70 <malloc+0x17c>
 206:	00000097          	auipc	ra,0x0
 20a:	730080e7          	jalr	1840(ra) # 936 <printf>
    exit(1);
 20e:	4505                	li	a0,1
 210:	00000097          	auipc	ra,0x0
 214:	39e080e7          	jalr	926(ra) # 5ae <exit>
    printf("FAIL: sysinfo succeeded with bad argument\n");
 218:	00001517          	auipc	a0,0x1
 21c:	97050513          	addi	a0,a0,-1680 # b88 <malloc+0x194>
 220:	00000097          	auipc	ra,0x0
 224:	716080e7          	jalr	1814(ra) # 936 <printf>
    exit(1);
 228:	4505                	li	a0,1
 22a:	00000097          	auipc	ra,0x0
 22e:	384080e7          	jalr	900(ra) # 5ae <exit>

0000000000000232 <testproc>:

void testproc() {
 232:	7139                	addi	sp,sp,-64
 234:	fc06                	sd	ra,56(sp)
 236:	f822                	sd	s0,48(sp)
 238:	f426                	sd	s1,40(sp)
 23a:	0080                	addi	s0,sp,64
  struct sysinfo info;
  uint64 nproc;
  int status;
  int pid;
  
  sinfo(&info);
 23c:	fd040513          	addi	a0,s0,-48
 240:	00000097          	auipc	ra,0x0
 244:	dc0080e7          	jalr	-576(ra) # 0 <sinfo>
  nproc = info.nproc;
 248:	fd843483          	ld	s1,-40(s0)

  pid = fork();
 24c:	00000097          	auipc	ra,0x0
 250:	35a080e7          	jalr	858(ra) # 5a6 <fork>
  if(pid < 0){
 254:	02054c63          	bltz	a0,28c <testproc+0x5a>
    printf("sysinfotest: fork failed\n");
    exit(1);
  }
  if(pid == 0){
 258:	ed21                	bnez	a0,2b0 <testproc+0x7e>
    sinfo(&info);
 25a:	fd040513          	addi	a0,s0,-48
 25e:	00000097          	auipc	ra,0x0
 262:	da2080e7          	jalr	-606(ra) # 0 <sinfo>
    if(info.nproc != nproc+1) {
 266:	fd843583          	ld	a1,-40(s0)
 26a:	00148613          	addi	a2,s1,1
 26e:	02c58c63          	beq	a1,a2,2a6 <testproc+0x74>
      printf("sysinfotest: FAIL nproc is %d instead of %d\n", info.nproc, nproc+1);
 272:	00001517          	auipc	a0,0x1
 276:	96650513          	addi	a0,a0,-1690 # bd8 <malloc+0x1e4>
 27a:	00000097          	auipc	ra,0x0
 27e:	6bc080e7          	jalr	1724(ra) # 936 <printf>
      exit(1);
 282:	4505                	li	a0,1
 284:	00000097          	auipc	ra,0x0
 288:	32a080e7          	jalr	810(ra) # 5ae <exit>
    printf("sysinfotest: fork failed\n");
 28c:	00001517          	auipc	a0,0x1
 290:	92c50513          	addi	a0,a0,-1748 # bb8 <malloc+0x1c4>
 294:	00000097          	auipc	ra,0x0
 298:	6a2080e7          	jalr	1698(ra) # 936 <printf>
    exit(1);
 29c:	4505                	li	a0,1
 29e:	00000097          	auipc	ra,0x0
 2a2:	310080e7          	jalr	784(ra) # 5ae <exit>
    }
    exit(0);
 2a6:	4501                	li	a0,0
 2a8:	00000097          	auipc	ra,0x0
 2ac:	306080e7          	jalr	774(ra) # 5ae <exit>
  }
  wait(&status);
 2b0:	fcc40513          	addi	a0,s0,-52
 2b4:	00000097          	auipc	ra,0x0
 2b8:	302080e7          	jalr	770(ra) # 5b6 <wait>
  sinfo(&info);
 2bc:	fd040513          	addi	a0,s0,-48
 2c0:	00000097          	auipc	ra,0x0
 2c4:	d40080e7          	jalr	-704(ra) # 0 <sinfo>
  if(info.nproc != nproc) {
 2c8:	fd843583          	ld	a1,-40(s0)
 2cc:	00959763          	bne	a1,s1,2da <testproc+0xa8>
      printf("sysinfotest: FAIL nproc is %d instead of %d\n", info.nproc, nproc);
      exit(1);
  }
}
 2d0:	70e2                	ld	ra,56(sp)
 2d2:	7442                	ld	s0,48(sp)
 2d4:	74a2                	ld	s1,40(sp)
 2d6:	6121                	addi	sp,sp,64
 2d8:	8082                	ret
      printf("sysinfotest: FAIL nproc is %d instead of %d\n", info.nproc, nproc);
 2da:	8626                	mv	a2,s1
 2dc:	00001517          	auipc	a0,0x1
 2e0:	8fc50513          	addi	a0,a0,-1796 # bd8 <malloc+0x1e4>
 2e4:	00000097          	auipc	ra,0x0
 2e8:	652080e7          	jalr	1618(ra) # 936 <printf>
      exit(1);
 2ec:	4505                	li	a0,1
 2ee:	00000097          	auipc	ra,0x0
 2f2:	2c0080e7          	jalr	704(ra) # 5ae <exit>

00000000000002f6 <main>:

int
main(int argc, char *argv[])
{
 2f6:	1141                	addi	sp,sp,-16
 2f8:	e406                	sd	ra,8(sp)
 2fa:	e022                	sd	s0,0(sp)
 2fc:	0800                	addi	s0,sp,16
  printf("sysinfotest: start\n");
 2fe:	00001517          	auipc	a0,0x1
 302:	90a50513          	addi	a0,a0,-1782 # c08 <malloc+0x214>
 306:	00000097          	auipc	ra,0x0
 30a:	630080e7          	jalr	1584(ra) # 936 <printf>
  testcall();
 30e:	00000097          	auipc	ra,0x0
 312:	eba080e7          	jalr	-326(ra) # 1c8 <testcall>
  testmem();
 316:	00000097          	auipc	ra,0x0
 31a:	daa080e7          	jalr	-598(ra) # c0 <testmem>
  testproc();
 31e:	00000097          	auipc	ra,0x0
 322:	f14080e7          	jalr	-236(ra) # 232 <testproc>
  printf("sysinfotest: OK\n");
 326:	00001517          	auipc	a0,0x1
 32a:	8fa50513          	addi	a0,a0,-1798 # c20 <malloc+0x22c>
 32e:	00000097          	auipc	ra,0x0
 332:	608080e7          	jalr	1544(ra) # 936 <printf>
  exit(0);
 336:	4501                	li	a0,0
 338:	00000097          	auipc	ra,0x0
 33c:	276080e7          	jalr	630(ra) # 5ae <exit>

0000000000000340 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 340:	1141                	addi	sp,sp,-16
 342:	e422                	sd	s0,8(sp)
 344:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 346:	87aa                	mv	a5,a0
 348:	0585                	addi	a1,a1,1
 34a:	0785                	addi	a5,a5,1
 34c:	fff5c703          	lbu	a4,-1(a1) # ffffffffffffefff <__global_pointer$+0xffffffffffffdbae>
 350:	fee78fa3          	sb	a4,-1(a5)
 354:	fb75                	bnez	a4,348 <strcpy+0x8>
    ;
  return os;
}
 356:	6422                	ld	s0,8(sp)
 358:	0141                	addi	sp,sp,16
 35a:	8082                	ret

000000000000035c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 35c:	1141                	addi	sp,sp,-16
 35e:	e422                	sd	s0,8(sp)
 360:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 362:	00054783          	lbu	a5,0(a0)
 366:	cb91                	beqz	a5,37a <strcmp+0x1e>
 368:	0005c703          	lbu	a4,0(a1)
 36c:	00f71763          	bne	a4,a5,37a <strcmp+0x1e>
    p++, q++;
 370:	0505                	addi	a0,a0,1
 372:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 374:	00054783          	lbu	a5,0(a0)
 378:	fbe5                	bnez	a5,368 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 37a:	0005c503          	lbu	a0,0(a1)
}
 37e:	40a7853b          	subw	a0,a5,a0
 382:	6422                	ld	s0,8(sp)
 384:	0141                	addi	sp,sp,16
 386:	8082                	ret

0000000000000388 <strlen>:

uint
strlen(const char *s)
{
 388:	1141                	addi	sp,sp,-16
 38a:	e422                	sd	s0,8(sp)
 38c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 38e:	00054783          	lbu	a5,0(a0)
 392:	cf91                	beqz	a5,3ae <strlen+0x26>
 394:	0505                	addi	a0,a0,1
 396:	87aa                	mv	a5,a0
 398:	4685                	li	a3,1
 39a:	9e89                	subw	a3,a3,a0
 39c:	00f6853b          	addw	a0,a3,a5
 3a0:	0785                	addi	a5,a5,1
 3a2:	fff7c703          	lbu	a4,-1(a5)
 3a6:	fb7d                	bnez	a4,39c <strlen+0x14>
    ;
  return n;
}
 3a8:	6422                	ld	s0,8(sp)
 3aa:	0141                	addi	sp,sp,16
 3ac:	8082                	ret
  for(n = 0; s[n]; n++)
 3ae:	4501                	li	a0,0
 3b0:	bfe5                	j	3a8 <strlen+0x20>

00000000000003b2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 3b2:	1141                	addi	sp,sp,-16
 3b4:	e422                	sd	s0,8(sp)
 3b6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 3b8:	ca19                	beqz	a2,3ce <memset+0x1c>
 3ba:	87aa                	mv	a5,a0
 3bc:	1602                	slli	a2,a2,0x20
 3be:	9201                	srli	a2,a2,0x20
 3c0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 3c4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 3c8:	0785                	addi	a5,a5,1
 3ca:	fee79de3          	bne	a5,a4,3c4 <memset+0x12>
  }
  return dst;
}
 3ce:	6422                	ld	s0,8(sp)
 3d0:	0141                	addi	sp,sp,16
 3d2:	8082                	ret

00000000000003d4 <strchr>:

char*
strchr(const char *s, char c)
{
 3d4:	1141                	addi	sp,sp,-16
 3d6:	e422                	sd	s0,8(sp)
 3d8:	0800                	addi	s0,sp,16
  for(; *s; s++)
 3da:	00054783          	lbu	a5,0(a0)
 3de:	cb99                	beqz	a5,3f4 <strchr+0x20>
    if(*s == c)
 3e0:	00f58763          	beq	a1,a5,3ee <strchr+0x1a>
  for(; *s; s++)
 3e4:	0505                	addi	a0,a0,1
 3e6:	00054783          	lbu	a5,0(a0)
 3ea:	fbfd                	bnez	a5,3e0 <strchr+0xc>
      return (char*)s;
  return 0;
 3ec:	4501                	li	a0,0
}
 3ee:	6422                	ld	s0,8(sp)
 3f0:	0141                	addi	sp,sp,16
 3f2:	8082                	ret
  return 0;
 3f4:	4501                	li	a0,0
 3f6:	bfe5                	j	3ee <strchr+0x1a>

00000000000003f8 <gets>:

char*
gets(char *buf, int max)
{
 3f8:	711d                	addi	sp,sp,-96
 3fa:	ec86                	sd	ra,88(sp)
 3fc:	e8a2                	sd	s0,80(sp)
 3fe:	e4a6                	sd	s1,72(sp)
 400:	e0ca                	sd	s2,64(sp)
 402:	fc4e                	sd	s3,56(sp)
 404:	f852                	sd	s4,48(sp)
 406:	f456                	sd	s5,40(sp)
 408:	f05a                	sd	s6,32(sp)
 40a:	ec5e                	sd	s7,24(sp)
 40c:	1080                	addi	s0,sp,96
 40e:	8baa                	mv	s7,a0
 410:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 412:	892a                	mv	s2,a0
 414:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 416:	4aa9                	li	s5,10
 418:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 41a:	89a6                	mv	s3,s1
 41c:	2485                	addiw	s1,s1,1
 41e:	0344d863          	bge	s1,s4,44e <gets+0x56>
    cc = read(0, &c, 1);
 422:	4605                	li	a2,1
 424:	faf40593          	addi	a1,s0,-81
 428:	4501                	li	a0,0
 42a:	00000097          	auipc	ra,0x0
 42e:	19c080e7          	jalr	412(ra) # 5c6 <read>
    if(cc < 1)
 432:	00a05e63          	blez	a0,44e <gets+0x56>
    buf[i++] = c;
 436:	faf44783          	lbu	a5,-81(s0)
 43a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 43e:	01578763          	beq	a5,s5,44c <gets+0x54>
 442:	0905                	addi	s2,s2,1
 444:	fd679be3          	bne	a5,s6,41a <gets+0x22>
  for(i=0; i+1 < max; ){
 448:	89a6                	mv	s3,s1
 44a:	a011                	j	44e <gets+0x56>
 44c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 44e:	99de                	add	s3,s3,s7
 450:	00098023          	sb	zero,0(s3) # 1000 <__BSS_END__+0x388>
  return buf;
}
 454:	855e                	mv	a0,s7
 456:	60e6                	ld	ra,88(sp)
 458:	6446                	ld	s0,80(sp)
 45a:	64a6                	ld	s1,72(sp)
 45c:	6906                	ld	s2,64(sp)
 45e:	79e2                	ld	s3,56(sp)
 460:	7a42                	ld	s4,48(sp)
 462:	7aa2                	ld	s5,40(sp)
 464:	7b02                	ld	s6,32(sp)
 466:	6be2                	ld	s7,24(sp)
 468:	6125                	addi	sp,sp,96
 46a:	8082                	ret

000000000000046c <stat>:

int
stat(const char *n, struct stat *st)
{
 46c:	1101                	addi	sp,sp,-32
 46e:	ec06                	sd	ra,24(sp)
 470:	e822                	sd	s0,16(sp)
 472:	e426                	sd	s1,8(sp)
 474:	e04a                	sd	s2,0(sp)
 476:	1000                	addi	s0,sp,32
 478:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 47a:	4581                	li	a1,0
 47c:	00000097          	auipc	ra,0x0
 480:	172080e7          	jalr	370(ra) # 5ee <open>
  if(fd < 0)
 484:	02054563          	bltz	a0,4ae <stat+0x42>
 488:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 48a:	85ca                	mv	a1,s2
 48c:	00000097          	auipc	ra,0x0
 490:	17a080e7          	jalr	378(ra) # 606 <fstat>
 494:	892a                	mv	s2,a0
  close(fd);
 496:	8526                	mv	a0,s1
 498:	00000097          	auipc	ra,0x0
 49c:	13e080e7          	jalr	318(ra) # 5d6 <close>
  return r;
}
 4a0:	854a                	mv	a0,s2
 4a2:	60e2                	ld	ra,24(sp)
 4a4:	6442                	ld	s0,16(sp)
 4a6:	64a2                	ld	s1,8(sp)
 4a8:	6902                	ld	s2,0(sp)
 4aa:	6105                	addi	sp,sp,32
 4ac:	8082                	ret
    return -1;
 4ae:	597d                	li	s2,-1
 4b0:	bfc5                	j	4a0 <stat+0x34>

00000000000004b2 <atoi>:

int
atoi(const char *s)
{
 4b2:	1141                	addi	sp,sp,-16
 4b4:	e422                	sd	s0,8(sp)
 4b6:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 4b8:	00054603          	lbu	a2,0(a0)
 4bc:	fd06079b          	addiw	a5,a2,-48
 4c0:	0ff7f793          	andi	a5,a5,255
 4c4:	4725                	li	a4,9
 4c6:	02f76963          	bltu	a4,a5,4f8 <atoi+0x46>
 4ca:	86aa                	mv	a3,a0
  n = 0;
 4cc:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 4ce:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 4d0:	0685                	addi	a3,a3,1
 4d2:	0025179b          	slliw	a5,a0,0x2
 4d6:	9fa9                	addw	a5,a5,a0
 4d8:	0017979b          	slliw	a5,a5,0x1
 4dc:	9fb1                	addw	a5,a5,a2
 4de:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 4e2:	0006c603          	lbu	a2,0(a3)
 4e6:	fd06071b          	addiw	a4,a2,-48
 4ea:	0ff77713          	andi	a4,a4,255
 4ee:	fee5f1e3          	bgeu	a1,a4,4d0 <atoi+0x1e>
  return n;
}
 4f2:	6422                	ld	s0,8(sp)
 4f4:	0141                	addi	sp,sp,16
 4f6:	8082                	ret
  n = 0;
 4f8:	4501                	li	a0,0
 4fa:	bfe5                	j	4f2 <atoi+0x40>

00000000000004fc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4fc:	1141                	addi	sp,sp,-16
 4fe:	e422                	sd	s0,8(sp)
 500:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 502:	02b57463          	bgeu	a0,a1,52a <memmove+0x2e>
    while(n-- > 0)
 506:	00c05f63          	blez	a2,524 <memmove+0x28>
 50a:	1602                	slli	a2,a2,0x20
 50c:	9201                	srli	a2,a2,0x20
 50e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 512:	872a                	mv	a4,a0
      *dst++ = *src++;
 514:	0585                	addi	a1,a1,1
 516:	0705                	addi	a4,a4,1
 518:	fff5c683          	lbu	a3,-1(a1)
 51c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 520:	fee79ae3          	bne	a5,a4,514 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 524:	6422                	ld	s0,8(sp)
 526:	0141                	addi	sp,sp,16
 528:	8082                	ret
    dst += n;
 52a:	00c50733          	add	a4,a0,a2
    src += n;
 52e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 530:	fec05ae3          	blez	a2,524 <memmove+0x28>
 534:	fff6079b          	addiw	a5,a2,-1
 538:	1782                	slli	a5,a5,0x20
 53a:	9381                	srli	a5,a5,0x20
 53c:	fff7c793          	not	a5,a5
 540:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 542:	15fd                	addi	a1,a1,-1
 544:	177d                	addi	a4,a4,-1
 546:	0005c683          	lbu	a3,0(a1)
 54a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 54e:	fee79ae3          	bne	a5,a4,542 <memmove+0x46>
 552:	bfc9                	j	524 <memmove+0x28>

0000000000000554 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 554:	1141                	addi	sp,sp,-16
 556:	e422                	sd	s0,8(sp)
 558:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 55a:	ca05                	beqz	a2,58a <memcmp+0x36>
 55c:	fff6069b          	addiw	a3,a2,-1
 560:	1682                	slli	a3,a3,0x20
 562:	9281                	srli	a3,a3,0x20
 564:	0685                	addi	a3,a3,1
 566:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 568:	00054783          	lbu	a5,0(a0)
 56c:	0005c703          	lbu	a4,0(a1)
 570:	00e79863          	bne	a5,a4,580 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 574:	0505                	addi	a0,a0,1
    p2++;
 576:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 578:	fed518e3          	bne	a0,a3,568 <memcmp+0x14>
  }
  return 0;
 57c:	4501                	li	a0,0
 57e:	a019                	j	584 <memcmp+0x30>
      return *p1 - *p2;
 580:	40e7853b          	subw	a0,a5,a4
}
 584:	6422                	ld	s0,8(sp)
 586:	0141                	addi	sp,sp,16
 588:	8082                	ret
  return 0;
 58a:	4501                	li	a0,0
 58c:	bfe5                	j	584 <memcmp+0x30>

000000000000058e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 58e:	1141                	addi	sp,sp,-16
 590:	e406                	sd	ra,8(sp)
 592:	e022                	sd	s0,0(sp)
 594:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 596:	00000097          	auipc	ra,0x0
 59a:	f66080e7          	jalr	-154(ra) # 4fc <memmove>
}
 59e:	60a2                	ld	ra,8(sp)
 5a0:	6402                	ld	s0,0(sp)
 5a2:	0141                	addi	sp,sp,16
 5a4:	8082                	ret

00000000000005a6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 5a6:	4885                	li	a7,1
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <exit>:
.global exit
exit:
 li a7, SYS_exit
 5ae:	4889                	li	a7,2
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 5b6:	488d                	li	a7,3
 ecall
 5b8:	00000073          	ecall
 ret
 5bc:	8082                	ret

00000000000005be <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 5be:	4891                	li	a7,4
 ecall
 5c0:	00000073          	ecall
 ret
 5c4:	8082                	ret

00000000000005c6 <read>:
.global read
read:
 li a7, SYS_read
 5c6:	4895                	li	a7,5
 ecall
 5c8:	00000073          	ecall
 ret
 5cc:	8082                	ret

00000000000005ce <write>:
.global write
write:
 li a7, SYS_write
 5ce:	48c1                	li	a7,16
 ecall
 5d0:	00000073          	ecall
 ret
 5d4:	8082                	ret

00000000000005d6 <close>:
.global close
close:
 li a7, SYS_close
 5d6:	48d5                	li	a7,21
 ecall
 5d8:	00000073          	ecall
 ret
 5dc:	8082                	ret

00000000000005de <kill>:
.global kill
kill:
 li a7, SYS_kill
 5de:	4899                	li	a7,6
 ecall
 5e0:	00000073          	ecall
 ret
 5e4:	8082                	ret

00000000000005e6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5e6:	489d                	li	a7,7
 ecall
 5e8:	00000073          	ecall
 ret
 5ec:	8082                	ret

00000000000005ee <open>:
.global open
open:
 li a7, SYS_open
 5ee:	48bd                	li	a7,15
 ecall
 5f0:	00000073          	ecall
 ret
 5f4:	8082                	ret

00000000000005f6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5f6:	48c5                	li	a7,17
 ecall
 5f8:	00000073          	ecall
 ret
 5fc:	8082                	ret

00000000000005fe <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5fe:	48c9                	li	a7,18
 ecall
 600:	00000073          	ecall
 ret
 604:	8082                	ret

0000000000000606 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 606:	48a1                	li	a7,8
 ecall
 608:	00000073          	ecall
 ret
 60c:	8082                	ret

000000000000060e <link>:
.global link
link:
 li a7, SYS_link
 60e:	48cd                	li	a7,19
 ecall
 610:	00000073          	ecall
 ret
 614:	8082                	ret

0000000000000616 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 616:	48d1                	li	a7,20
 ecall
 618:	00000073          	ecall
 ret
 61c:	8082                	ret

000000000000061e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 61e:	48a5                	li	a7,9
 ecall
 620:	00000073          	ecall
 ret
 624:	8082                	ret

0000000000000626 <dup>:
.global dup
dup:
 li a7, SYS_dup
 626:	48a9                	li	a7,10
 ecall
 628:	00000073          	ecall
 ret
 62c:	8082                	ret

000000000000062e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 62e:	48ad                	li	a7,11
 ecall
 630:	00000073          	ecall
 ret
 634:	8082                	ret

0000000000000636 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 636:	48b1                	li	a7,12
 ecall
 638:	00000073          	ecall
 ret
 63c:	8082                	ret

000000000000063e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 63e:	48b5                	li	a7,13
 ecall
 640:	00000073          	ecall
 ret
 644:	8082                	ret

0000000000000646 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 646:	48b9                	li	a7,14
 ecall
 648:	00000073          	ecall
 ret
 64c:	8082                	ret

000000000000064e <trace>:
.global trace
trace:
 li a7, SYS_trace
 64e:	48d9                	li	a7,22
 ecall
 650:	00000073          	ecall
 ret
 654:	8082                	ret

0000000000000656 <sysinfo>:
.global sysinfo
sysinfo:
 li a7, SYS_sysinfo
 656:	48dd                	li	a7,23
 ecall
 658:	00000073          	ecall
 ret
 65c:	8082                	ret

000000000000065e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 65e:	1101                	addi	sp,sp,-32
 660:	ec06                	sd	ra,24(sp)
 662:	e822                	sd	s0,16(sp)
 664:	1000                	addi	s0,sp,32
 666:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 66a:	4605                	li	a2,1
 66c:	fef40593          	addi	a1,s0,-17
 670:	00000097          	auipc	ra,0x0
 674:	f5e080e7          	jalr	-162(ra) # 5ce <write>
}
 678:	60e2                	ld	ra,24(sp)
 67a:	6442                	ld	s0,16(sp)
 67c:	6105                	addi	sp,sp,32
 67e:	8082                	ret

0000000000000680 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 680:	7139                	addi	sp,sp,-64
 682:	fc06                	sd	ra,56(sp)
 684:	f822                	sd	s0,48(sp)
 686:	f426                	sd	s1,40(sp)
 688:	f04a                	sd	s2,32(sp)
 68a:	ec4e                	sd	s3,24(sp)
 68c:	0080                	addi	s0,sp,64
 68e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 690:	c299                	beqz	a3,696 <printint+0x16>
 692:	0805c863          	bltz	a1,722 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 696:	2581                	sext.w	a1,a1
  neg = 0;
 698:	4881                	li	a7,0
 69a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 69e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 6a0:	2601                	sext.w	a2,a2
 6a2:	00000517          	auipc	a0,0x0
 6a6:	59e50513          	addi	a0,a0,1438 # c40 <digits>
 6aa:	883a                	mv	a6,a4
 6ac:	2705                	addiw	a4,a4,1
 6ae:	02c5f7bb          	remuw	a5,a1,a2
 6b2:	1782                	slli	a5,a5,0x20
 6b4:	9381                	srli	a5,a5,0x20
 6b6:	97aa                	add	a5,a5,a0
 6b8:	0007c783          	lbu	a5,0(a5)
 6bc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 6c0:	0005879b          	sext.w	a5,a1
 6c4:	02c5d5bb          	divuw	a1,a1,a2
 6c8:	0685                	addi	a3,a3,1
 6ca:	fec7f0e3          	bgeu	a5,a2,6aa <printint+0x2a>
  if(neg)
 6ce:	00088b63          	beqz	a7,6e4 <printint+0x64>
    buf[i++] = '-';
 6d2:	fd040793          	addi	a5,s0,-48
 6d6:	973e                	add	a4,a4,a5
 6d8:	02d00793          	li	a5,45
 6dc:	fef70823          	sb	a5,-16(a4)
 6e0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 6e4:	02e05863          	blez	a4,714 <printint+0x94>
 6e8:	fc040793          	addi	a5,s0,-64
 6ec:	00e78933          	add	s2,a5,a4
 6f0:	fff78993          	addi	s3,a5,-1
 6f4:	99ba                	add	s3,s3,a4
 6f6:	377d                	addiw	a4,a4,-1
 6f8:	1702                	slli	a4,a4,0x20
 6fa:	9301                	srli	a4,a4,0x20
 6fc:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 700:	fff94583          	lbu	a1,-1(s2)
 704:	8526                	mv	a0,s1
 706:	00000097          	auipc	ra,0x0
 70a:	f58080e7          	jalr	-168(ra) # 65e <putc>
  while(--i >= 0)
 70e:	197d                	addi	s2,s2,-1
 710:	ff3918e3          	bne	s2,s3,700 <printint+0x80>
}
 714:	70e2                	ld	ra,56(sp)
 716:	7442                	ld	s0,48(sp)
 718:	74a2                	ld	s1,40(sp)
 71a:	7902                	ld	s2,32(sp)
 71c:	69e2                	ld	s3,24(sp)
 71e:	6121                	addi	sp,sp,64
 720:	8082                	ret
    x = -xx;
 722:	40b005bb          	negw	a1,a1
    neg = 1;
 726:	4885                	li	a7,1
    x = -xx;
 728:	bf8d                	j	69a <printint+0x1a>

000000000000072a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 72a:	7119                	addi	sp,sp,-128
 72c:	fc86                	sd	ra,120(sp)
 72e:	f8a2                	sd	s0,112(sp)
 730:	f4a6                	sd	s1,104(sp)
 732:	f0ca                	sd	s2,96(sp)
 734:	ecce                	sd	s3,88(sp)
 736:	e8d2                	sd	s4,80(sp)
 738:	e4d6                	sd	s5,72(sp)
 73a:	e0da                	sd	s6,64(sp)
 73c:	fc5e                	sd	s7,56(sp)
 73e:	f862                	sd	s8,48(sp)
 740:	f466                	sd	s9,40(sp)
 742:	f06a                	sd	s10,32(sp)
 744:	ec6e                	sd	s11,24(sp)
 746:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 748:	0005c903          	lbu	s2,0(a1)
 74c:	18090f63          	beqz	s2,8ea <vprintf+0x1c0>
 750:	8aaa                	mv	s5,a0
 752:	8b32                	mv	s6,a2
 754:	00158493          	addi	s1,a1,1
  state = 0;
 758:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 75a:	02500a13          	li	s4,37
      if(c == 'd'){
 75e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 762:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 766:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 76a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 76e:	00000b97          	auipc	s7,0x0
 772:	4d2b8b93          	addi	s7,s7,1234 # c40 <digits>
 776:	a839                	j	794 <vprintf+0x6a>
        putc(fd, c);
 778:	85ca                	mv	a1,s2
 77a:	8556                	mv	a0,s5
 77c:	00000097          	auipc	ra,0x0
 780:	ee2080e7          	jalr	-286(ra) # 65e <putc>
 784:	a019                	j	78a <vprintf+0x60>
    } else if(state == '%'){
 786:	01498f63          	beq	s3,s4,7a4 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 78a:	0485                	addi	s1,s1,1
 78c:	fff4c903          	lbu	s2,-1(s1)
 790:	14090d63          	beqz	s2,8ea <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 794:	0009079b          	sext.w	a5,s2
    if(state == 0){
 798:	fe0997e3          	bnez	s3,786 <vprintf+0x5c>
      if(c == '%'){
 79c:	fd479ee3          	bne	a5,s4,778 <vprintf+0x4e>
        state = '%';
 7a0:	89be                	mv	s3,a5
 7a2:	b7e5                	j	78a <vprintf+0x60>
      if(c == 'd'){
 7a4:	05878063          	beq	a5,s8,7e4 <vprintf+0xba>
      } else if(c == 'l') {
 7a8:	05978c63          	beq	a5,s9,800 <vprintf+0xd6>
      } else if(c == 'x') {
 7ac:	07a78863          	beq	a5,s10,81c <vprintf+0xf2>
      } else if(c == 'p') {
 7b0:	09b78463          	beq	a5,s11,838 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 7b4:	07300713          	li	a4,115
 7b8:	0ce78663          	beq	a5,a4,884 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 7bc:	06300713          	li	a4,99
 7c0:	0ee78e63          	beq	a5,a4,8bc <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 7c4:	11478863          	beq	a5,s4,8d4 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 7c8:	85d2                	mv	a1,s4
 7ca:	8556                	mv	a0,s5
 7cc:	00000097          	auipc	ra,0x0
 7d0:	e92080e7          	jalr	-366(ra) # 65e <putc>
        putc(fd, c);
 7d4:	85ca                	mv	a1,s2
 7d6:	8556                	mv	a0,s5
 7d8:	00000097          	auipc	ra,0x0
 7dc:	e86080e7          	jalr	-378(ra) # 65e <putc>
      }
      state = 0;
 7e0:	4981                	li	s3,0
 7e2:	b765                	j	78a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 7e4:	008b0913          	addi	s2,s6,8
 7e8:	4685                	li	a3,1
 7ea:	4629                	li	a2,10
 7ec:	000b2583          	lw	a1,0(s6)
 7f0:	8556                	mv	a0,s5
 7f2:	00000097          	auipc	ra,0x0
 7f6:	e8e080e7          	jalr	-370(ra) # 680 <printint>
 7fa:	8b4a                	mv	s6,s2
      state = 0;
 7fc:	4981                	li	s3,0
 7fe:	b771                	j	78a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 800:	008b0913          	addi	s2,s6,8
 804:	4681                	li	a3,0
 806:	4629                	li	a2,10
 808:	000b2583          	lw	a1,0(s6)
 80c:	8556                	mv	a0,s5
 80e:	00000097          	auipc	ra,0x0
 812:	e72080e7          	jalr	-398(ra) # 680 <printint>
 816:	8b4a                	mv	s6,s2
      state = 0;
 818:	4981                	li	s3,0
 81a:	bf85                	j	78a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 81c:	008b0913          	addi	s2,s6,8
 820:	4681                	li	a3,0
 822:	4641                	li	a2,16
 824:	000b2583          	lw	a1,0(s6)
 828:	8556                	mv	a0,s5
 82a:	00000097          	auipc	ra,0x0
 82e:	e56080e7          	jalr	-426(ra) # 680 <printint>
 832:	8b4a                	mv	s6,s2
      state = 0;
 834:	4981                	li	s3,0
 836:	bf91                	j	78a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 838:	008b0793          	addi	a5,s6,8
 83c:	f8f43423          	sd	a5,-120(s0)
 840:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 844:	03000593          	li	a1,48
 848:	8556                	mv	a0,s5
 84a:	00000097          	auipc	ra,0x0
 84e:	e14080e7          	jalr	-492(ra) # 65e <putc>
  putc(fd, 'x');
 852:	85ea                	mv	a1,s10
 854:	8556                	mv	a0,s5
 856:	00000097          	auipc	ra,0x0
 85a:	e08080e7          	jalr	-504(ra) # 65e <putc>
 85e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 860:	03c9d793          	srli	a5,s3,0x3c
 864:	97de                	add	a5,a5,s7
 866:	0007c583          	lbu	a1,0(a5)
 86a:	8556                	mv	a0,s5
 86c:	00000097          	auipc	ra,0x0
 870:	df2080e7          	jalr	-526(ra) # 65e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 874:	0992                	slli	s3,s3,0x4
 876:	397d                	addiw	s2,s2,-1
 878:	fe0914e3          	bnez	s2,860 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 87c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 880:	4981                	li	s3,0
 882:	b721                	j	78a <vprintf+0x60>
        s = va_arg(ap, char*);
 884:	008b0993          	addi	s3,s6,8
 888:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 88c:	02090163          	beqz	s2,8ae <vprintf+0x184>
        while(*s != 0){
 890:	00094583          	lbu	a1,0(s2)
 894:	c9a1                	beqz	a1,8e4 <vprintf+0x1ba>
          putc(fd, *s);
 896:	8556                	mv	a0,s5
 898:	00000097          	auipc	ra,0x0
 89c:	dc6080e7          	jalr	-570(ra) # 65e <putc>
          s++;
 8a0:	0905                	addi	s2,s2,1
        while(*s != 0){
 8a2:	00094583          	lbu	a1,0(s2)
 8a6:	f9e5                	bnez	a1,896 <vprintf+0x16c>
        s = va_arg(ap, char*);
 8a8:	8b4e                	mv	s6,s3
      state = 0;
 8aa:	4981                	li	s3,0
 8ac:	bdf9                	j	78a <vprintf+0x60>
          s = "(null)";
 8ae:	00000917          	auipc	s2,0x0
 8b2:	38a90913          	addi	s2,s2,906 # c38 <malloc+0x244>
        while(*s != 0){
 8b6:	02800593          	li	a1,40
 8ba:	bff1                	j	896 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 8bc:	008b0913          	addi	s2,s6,8
 8c0:	000b4583          	lbu	a1,0(s6)
 8c4:	8556                	mv	a0,s5
 8c6:	00000097          	auipc	ra,0x0
 8ca:	d98080e7          	jalr	-616(ra) # 65e <putc>
 8ce:	8b4a                	mv	s6,s2
      state = 0;
 8d0:	4981                	li	s3,0
 8d2:	bd65                	j	78a <vprintf+0x60>
        putc(fd, c);
 8d4:	85d2                	mv	a1,s4
 8d6:	8556                	mv	a0,s5
 8d8:	00000097          	auipc	ra,0x0
 8dc:	d86080e7          	jalr	-634(ra) # 65e <putc>
      state = 0;
 8e0:	4981                	li	s3,0
 8e2:	b565                	j	78a <vprintf+0x60>
        s = va_arg(ap, char*);
 8e4:	8b4e                	mv	s6,s3
      state = 0;
 8e6:	4981                	li	s3,0
 8e8:	b54d                	j	78a <vprintf+0x60>
    }
  }
}
 8ea:	70e6                	ld	ra,120(sp)
 8ec:	7446                	ld	s0,112(sp)
 8ee:	74a6                	ld	s1,104(sp)
 8f0:	7906                	ld	s2,96(sp)
 8f2:	69e6                	ld	s3,88(sp)
 8f4:	6a46                	ld	s4,80(sp)
 8f6:	6aa6                	ld	s5,72(sp)
 8f8:	6b06                	ld	s6,64(sp)
 8fa:	7be2                	ld	s7,56(sp)
 8fc:	7c42                	ld	s8,48(sp)
 8fe:	7ca2                	ld	s9,40(sp)
 900:	7d02                	ld	s10,32(sp)
 902:	6de2                	ld	s11,24(sp)
 904:	6109                	addi	sp,sp,128
 906:	8082                	ret

0000000000000908 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 908:	715d                	addi	sp,sp,-80
 90a:	ec06                	sd	ra,24(sp)
 90c:	e822                	sd	s0,16(sp)
 90e:	1000                	addi	s0,sp,32
 910:	e010                	sd	a2,0(s0)
 912:	e414                	sd	a3,8(s0)
 914:	e818                	sd	a4,16(s0)
 916:	ec1c                	sd	a5,24(s0)
 918:	03043023          	sd	a6,32(s0)
 91c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 920:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 924:	8622                	mv	a2,s0
 926:	00000097          	auipc	ra,0x0
 92a:	e04080e7          	jalr	-508(ra) # 72a <vprintf>
}
 92e:	60e2                	ld	ra,24(sp)
 930:	6442                	ld	s0,16(sp)
 932:	6161                	addi	sp,sp,80
 934:	8082                	ret

0000000000000936 <printf>:

void
printf(const char *fmt, ...)
{
 936:	711d                	addi	sp,sp,-96
 938:	ec06                	sd	ra,24(sp)
 93a:	e822                	sd	s0,16(sp)
 93c:	1000                	addi	s0,sp,32
 93e:	e40c                	sd	a1,8(s0)
 940:	e810                	sd	a2,16(s0)
 942:	ec14                	sd	a3,24(s0)
 944:	f018                	sd	a4,32(s0)
 946:	f41c                	sd	a5,40(s0)
 948:	03043823          	sd	a6,48(s0)
 94c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 950:	00840613          	addi	a2,s0,8
 954:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 958:	85aa                	mv	a1,a0
 95a:	4505                	li	a0,1
 95c:	00000097          	auipc	ra,0x0
 960:	dce080e7          	jalr	-562(ra) # 72a <vprintf>
}
 964:	60e2                	ld	ra,24(sp)
 966:	6442                	ld	s0,16(sp)
 968:	6125                	addi	sp,sp,96
 96a:	8082                	ret

000000000000096c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 96c:	1141                	addi	sp,sp,-16
 96e:	e422                	sd	s0,8(sp)
 970:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 972:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 976:	00000797          	auipc	a5,0x0
 97a:	2ea7b783          	ld	a5,746(a5) # c60 <freep>
 97e:	a805                	j	9ae <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 980:	4618                	lw	a4,8(a2)
 982:	9db9                	addw	a1,a1,a4
 984:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 988:	6398                	ld	a4,0(a5)
 98a:	6318                	ld	a4,0(a4)
 98c:	fee53823          	sd	a4,-16(a0)
 990:	a091                	j	9d4 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 992:	ff852703          	lw	a4,-8(a0)
 996:	9e39                	addw	a2,a2,a4
 998:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 99a:	ff053703          	ld	a4,-16(a0)
 99e:	e398                	sd	a4,0(a5)
 9a0:	a099                	j	9e6 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9a2:	6398                	ld	a4,0(a5)
 9a4:	00e7e463          	bltu	a5,a4,9ac <free+0x40>
 9a8:	00e6ea63          	bltu	a3,a4,9bc <free+0x50>
{
 9ac:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9ae:	fed7fae3          	bgeu	a5,a3,9a2 <free+0x36>
 9b2:	6398                	ld	a4,0(a5)
 9b4:	00e6e463          	bltu	a3,a4,9bc <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9b8:	fee7eae3          	bltu	a5,a4,9ac <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 9bc:	ff852583          	lw	a1,-8(a0)
 9c0:	6390                	ld	a2,0(a5)
 9c2:	02059813          	slli	a6,a1,0x20
 9c6:	01c85713          	srli	a4,a6,0x1c
 9ca:	9736                	add	a4,a4,a3
 9cc:	fae60ae3          	beq	a2,a4,980 <free+0x14>
    bp->s.ptr = p->s.ptr;
 9d0:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 9d4:	4790                	lw	a2,8(a5)
 9d6:	02061593          	slli	a1,a2,0x20
 9da:	01c5d713          	srli	a4,a1,0x1c
 9de:	973e                	add	a4,a4,a5
 9e0:	fae689e3          	beq	a3,a4,992 <free+0x26>
  } else
    p->s.ptr = bp;
 9e4:	e394                	sd	a3,0(a5)
  freep = p;
 9e6:	00000717          	auipc	a4,0x0
 9ea:	26f73d23          	sd	a5,634(a4) # c60 <freep>
}
 9ee:	6422                	ld	s0,8(sp)
 9f0:	0141                	addi	sp,sp,16
 9f2:	8082                	ret

00000000000009f4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9f4:	7139                	addi	sp,sp,-64
 9f6:	fc06                	sd	ra,56(sp)
 9f8:	f822                	sd	s0,48(sp)
 9fa:	f426                	sd	s1,40(sp)
 9fc:	f04a                	sd	s2,32(sp)
 9fe:	ec4e                	sd	s3,24(sp)
 a00:	e852                	sd	s4,16(sp)
 a02:	e456                	sd	s5,8(sp)
 a04:	e05a                	sd	s6,0(sp)
 a06:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a08:	02051493          	slli	s1,a0,0x20
 a0c:	9081                	srli	s1,s1,0x20
 a0e:	04bd                	addi	s1,s1,15
 a10:	8091                	srli	s1,s1,0x4
 a12:	0014899b          	addiw	s3,s1,1
 a16:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a18:	00000517          	auipc	a0,0x0
 a1c:	24853503          	ld	a0,584(a0) # c60 <freep>
 a20:	c515                	beqz	a0,a4c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a22:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a24:	4798                	lw	a4,8(a5)
 a26:	02977f63          	bgeu	a4,s1,a64 <malloc+0x70>
 a2a:	8a4e                	mv	s4,s3
 a2c:	0009871b          	sext.w	a4,s3
 a30:	6685                	lui	a3,0x1
 a32:	00d77363          	bgeu	a4,a3,a38 <malloc+0x44>
 a36:	6a05                	lui	s4,0x1
 a38:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a3c:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a40:	00000917          	auipc	s2,0x0
 a44:	22090913          	addi	s2,s2,544 # c60 <freep>
  if(p == (char*)-1)
 a48:	5afd                	li	s5,-1
 a4a:	a895                	j	abe <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 a4c:	00000797          	auipc	a5,0x0
 a50:	21c78793          	addi	a5,a5,540 # c68 <base>
 a54:	00000717          	auipc	a4,0x0
 a58:	20f73623          	sd	a5,524(a4) # c60 <freep>
 a5c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a5e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a62:	b7e1                	j	a2a <malloc+0x36>
      if(p->s.size == nunits)
 a64:	02e48c63          	beq	s1,a4,a9c <malloc+0xa8>
        p->s.size -= nunits;
 a68:	4137073b          	subw	a4,a4,s3
 a6c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a6e:	02071693          	slli	a3,a4,0x20
 a72:	01c6d713          	srli	a4,a3,0x1c
 a76:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a78:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a7c:	00000717          	auipc	a4,0x0
 a80:	1ea73223          	sd	a0,484(a4) # c60 <freep>
      return (void*)(p + 1);
 a84:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 a88:	70e2                	ld	ra,56(sp)
 a8a:	7442                	ld	s0,48(sp)
 a8c:	74a2                	ld	s1,40(sp)
 a8e:	7902                	ld	s2,32(sp)
 a90:	69e2                	ld	s3,24(sp)
 a92:	6a42                	ld	s4,16(sp)
 a94:	6aa2                	ld	s5,8(sp)
 a96:	6b02                	ld	s6,0(sp)
 a98:	6121                	addi	sp,sp,64
 a9a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 a9c:	6398                	ld	a4,0(a5)
 a9e:	e118                	sd	a4,0(a0)
 aa0:	bff1                	j	a7c <malloc+0x88>
  hp->s.size = nu;
 aa2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 aa6:	0541                	addi	a0,a0,16
 aa8:	00000097          	auipc	ra,0x0
 aac:	ec4080e7          	jalr	-316(ra) # 96c <free>
  return freep;
 ab0:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ab4:	d971                	beqz	a0,a88 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ab6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ab8:	4798                	lw	a4,8(a5)
 aba:	fa9775e3          	bgeu	a4,s1,a64 <malloc+0x70>
    if(p == freep)
 abe:	00093703          	ld	a4,0(s2)
 ac2:	853e                	mv	a0,a5
 ac4:	fef719e3          	bne	a4,a5,ab6 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 ac8:	8552                	mv	a0,s4
 aca:	00000097          	auipc	ra,0x0
 ace:	b6c080e7          	jalr	-1172(ra) # 636 <sbrk>
  if(p == (char*)-1)
 ad2:	fd5518e3          	bne	a0,s5,aa2 <malloc+0xae>
        return 0;
 ad6:	4501                	li	a0,0
 ad8:	bf45                	j	a88 <malloc+0x94>
