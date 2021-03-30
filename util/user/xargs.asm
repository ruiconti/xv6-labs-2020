
user/_xargs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <next_line>:
#include "user/user.h"

#define STDIN 0

char* next_line(char* str) 
{
   0:	711d                	addi	sp,sp,-96
   2:	ec86                	sd	ra,88(sp)
   4:	e8a2                	sd	s0,80(sp)
   6:	e4a6                	sd	s1,72(sp)
   8:	e0ca                	sd	s2,64(sp)
   a:	fc4e                	sd	s3,56(sp)
   c:	f852                	sd	s4,48(sp)
   e:	f456                	sd	s5,40(sp)
  10:	f05a                	sd	s6,32(sp)
  12:	ec5e                	sd	s7,24(sp)
  14:	e862                	sd	s8,16(sp)
  16:	e466                	sd	s9,8(sp)
  18:	1080                	addi	s0,sp,96
  1a:	8a2a                	mv	s4,a0
  char *p, *out;
  char *line;
  line = malloc(sizeof(char) * strlen(str));
  1c:	00000097          	auipc	ra,0x0
  20:	1da080e7          	jalr	474(ra) # 1f6 <strlen>
  24:	2501                	sext.w	a0,a0
  26:	00001097          	auipc	ra,0x1
  2a:	82c080e7          	jalr	-2004(ra) # 852 <malloc>
  2e:	8aaa                	mv	s5,a0

  p = line;  /* initialize walking pointer to empty buffer with line */
  for(int i=0; i<strlen(str); i++)
  30:	84d2                	mv	s1,s4
  32:	4901                	li	s2,0
  {
    if(str[i] == '\n')
  34:	4b29                	li	s6,10
    { 
      /* we stop when new line */
      break;
    }
    if(str[i] == '\\' && strlen(str) >= (i+1) && str[i+1] == 'n')  
  36:	05c00b93          	li	s7,92
  3a:	06e00c13          	li	s8,110
  for(int i=0; i<strlen(str); i++)
  3e:	a809                	j	50 <next_line+0x50>
      break;
    }
    /* associate str[i] with derreferencing p = p + 1 (which is line's next
     * memory slot which has sizeof char)
     */
    *p++ = str[i];
  40:	000cc703          	lbu	a4,0(s9)
  44:	012a87b3          	add	a5,s5,s2
  48:	00e78023          	sb	a4,0(a5)
  for(int i=0; i<strlen(str); i++)
  4c:	0905                	addi	s2,s2,1
  4e:	0485                	addi	s1,s1,1
  50:	8552                	mv	a0,s4
  52:	00000097          	auipc	ra,0x0
  56:	1a4080e7          	jalr	420(ra) # 1f6 <strlen>
  5a:	2501                	sext.w	a0,a0
  5c:	0009099b          	sext.w	s3,s2
  60:	02a9f663          	bgeu	s3,a0,8c <next_line+0x8c>
    if(str[i] == '\n')
  64:	8ca6                	mv	s9,s1
  66:	0004c783          	lbu	a5,0(s1)
  6a:	03678163          	beq	a5,s6,8c <next_line+0x8c>
    if(str[i] == '\\' && strlen(str) >= (i+1) && str[i+1] == 'n')  
  6e:	fd7799e3          	bne	a5,s7,40 <next_line+0x40>
  72:	8552                	mv	a0,s4
  74:	00000097          	auipc	ra,0x0
  78:	182080e7          	jalr	386(ra) # 1f6 <strlen>
  7c:	2501                	sext.w	a0,a0
  7e:	2985                	addiw	s3,s3,1
  80:	fd3560e3          	bltu	a0,s3,40 <next_line+0x40>
  84:	0014c783          	lbu	a5,1(s1)
  88:	fb879ce3          	bne	a5,s8,40 <next_line+0x40>
  }
  out = line;
  /* line pointer is persistant on different calls to next_line,
   * therefore, it must be offset */
  str = str + strlen(line) + sizeof(char);
  8c:	8556                	mv	a0,s5
  8e:	00000097          	auipc	ra,0x0
  92:	168080e7          	jalr	360(ra) # 1f6 <strlen>
  line = line + strlen(line);
  96:	8556                	mv	a0,s5
  98:	00000097          	auipc	ra,0x0
  9c:	15e080e7          	jalr	350(ra) # 1f6 <strlen>

  return out;
}
  a0:	8556                	mv	a0,s5
  a2:	60e6                	ld	ra,88(sp)
  a4:	6446                	ld	s0,80(sp)
  a6:	64a6                	ld	s1,72(sp)
  a8:	6906                	ld	s2,64(sp)
  aa:	79e2                	ld	s3,56(sp)
  ac:	7a42                	ld	s4,48(sp)
  ae:	7aa2                	ld	s5,40(sp)
  b0:	7b02                	ld	s6,32(sp)
  b2:	6be2                	ld	s7,24(sp)
  b4:	6c42                	ld	s8,16(sp)
  b6:	6ca2                	ld	s9,8(sp)
  b8:	6125                	addi	sp,sp,96
  ba:	8082                	ret

00000000000000bc <main>:

int
main(int argc, char *argv[])
{
  bc:	dd010113          	addi	sp,sp,-560
  c0:	22113423          	sd	ra,552(sp)
  c4:	22813023          	sd	s0,544(sp)
  c8:	20913c23          	sd	s1,536(sp)
  cc:	21213823          	sd	s2,528(sp)
  d0:	21313423          	sd	s3,520(sp)
  d4:	21413023          	sd	s4,512(sp)
  d8:	1c00                	addi	s0,sp,560
  da:	89aa                	mv	s3,a0
  dc:	8a2e                	mv	s4,a1
  // argv[0] is program name (xargs)  
  // argv[1] is argument (that is also a program name)
  // argv[-1] is NULL
  char buff[512], *p;
  
  if(read(STDIN, &buff, sizeof(buff)) > 0)
  de:	20000613          	li	a2,512
  e2:	dd040593          	addi	a1,s0,-560
  e6:	4501                	li	a0,0
  e8:	00000097          	auipc	ra,0x0
  ec:	34c080e7          	jalr	844(ra) # 434 <read>
  f0:	04a05063          	blez	a0,130 <main+0x74>
  {
    p = buff;
  f4:	dd040493          	addi	s1,s0,-560
    while(1)
    {
      char *line = next_line(p);
  f8:	8526                	mv	a0,s1
  fa:	00000097          	auipc	ra,0x0
  fe:	f06080e7          	jalr	-250(ra) # 0 <next_line>
 102:	892a                	mv	s2,a0
      /* TODO: There is a bug here: if its a user input, \n equals
       * two characters, therefore, pointer offsetting should be char*2
       * otherwise, if it's received from another program (say find)
       * \n is properly parsed and works as expected */
      //p = p + strlen(line) + (sizeof(char) * 2);
      p = p + strlen(line) + (sizeof(char));
 104:	00000097          	auipc	ra,0x0
 108:	0f2080e7          	jalr	242(ra) # 1f6 <strlen>
 10c:	02051793          	slli	a5,a0,0x20
 110:	9381                	srli	a5,a5,0x20
 112:	0785                	addi	a5,a5,1
 114:	94be                	add	s1,s1,a5
      if(fork() == 0)
 116:	00000097          	auipc	ra,0x0
 11a:	2fe080e7          	jalr	766(ra) # 414 <fork>
 11e:	cd11                	beqz	a0,13a <main+0x7e>
        exec(argv[1], nargv);
        fprintf(2, "exec %s failed!", argv[1]);
        exit(0);
      }
      else {
        wait(0);
 120:	4501                	li	a0,0
 122:	00000097          	auipc	ra,0x0
 126:	302080e7          	jalr	770(ra) # 424 <wait>
      }

      /* there are no more lines to read */
      if (*p == '\0') break;
 12a:	0004c783          	lbu	a5,0(s1)
 12e:	f7e9                	bnez	a5,f8 <main+0x3c>
    }
  }

  exit(0);
 130:	4501                	li	a0,0
 132:	00000097          	auipc	ra,0x0
 136:	2ea080e7          	jalr	746(ra) # 41c <exit>
        char *nargv[argc];
 13a:	00399513          	slli	a0,s3,0x3
 13e:	00f50793          	addi	a5,a0,15
 142:	9bc1                	andi	a5,a5,-16
 144:	40f10133          	sub	sp,sp,a5
 148:	858a                	mv	a1,sp
        for(int i=1, j=0; i<argc; i++, j++)
 14a:	4785                	li	a5,1
 14c:	0337d463          	bge	a5,s3,174 <main+0xb8>
 150:	008a0793          	addi	a5,s4,8
 154:	872e                	mv	a4,a1
 156:	ffe9869b          	addiw	a3,s3,-2
 15a:	02069613          	slli	a2,a3,0x20
 15e:	01d65693          	srli	a3,a2,0x1d
 162:	010a0613          	addi	a2,s4,16
 166:	96b2                	add	a3,a3,a2
          nargv[j] = argv[i];
 168:	6390                	ld	a2,0(a5)
 16a:	e310                	sd	a2,0(a4)
        for(int i=1, j=0; i<argc; i++, j++)
 16c:	07a1                	addi	a5,a5,8
 16e:	0721                	addi	a4,a4,8
 170:	fed79ce3          	bne	a5,a3,168 <main+0xac>
        nargv[argc-1] = line;
 174:	00a587b3          	add	a5,a1,a0
 178:	ff27bc23          	sd	s2,-8(a5)
        nargv[argc] = argv[argc];
 17c:	9552                	add	a0,a0,s4
 17e:	6118                	ld	a4,0(a0)
 180:	e398                	sd	a4,0(a5)
        exec(argv[1], nargv);
 182:	008a3503          	ld	a0,8(s4)
 186:	00000097          	auipc	ra,0x0
 18a:	2ce080e7          	jalr	718(ra) # 454 <exec>
        fprintf(2, "exec %s failed!", argv[1]);
 18e:	008a3603          	ld	a2,8(s4)
 192:	00000597          	auipc	a1,0x0
 196:	7a658593          	addi	a1,a1,1958 # 938 <malloc+0xe6>
 19a:	4509                	li	a0,2
 19c:	00000097          	auipc	ra,0x0
 1a0:	5ca080e7          	jalr	1482(ra) # 766 <fprintf>
        exit(0);
 1a4:	4501                	li	a0,0
 1a6:	00000097          	auipc	ra,0x0
 1aa:	276080e7          	jalr	630(ra) # 41c <exit>

00000000000001ae <strcpy>:
 1ae:	1141                	addi	sp,sp,-16
 1b0:	e422                	sd	s0,8(sp)
 1b2:	0800                	addi	s0,sp,16
 1b4:	87aa                	mv	a5,a0
 1b6:	0585                	addi	a1,a1,1
 1b8:	0785                	addi	a5,a5,1
 1ba:	fff5c703          	lbu	a4,-1(a1)
 1be:	fee78fa3          	sb	a4,-1(a5)
 1c2:	fb75                	bnez	a4,1b6 <strcpy+0x8>
 1c4:	6422                	ld	s0,8(sp)
 1c6:	0141                	addi	sp,sp,16
 1c8:	8082                	ret

00000000000001ca <strcmp>:
 1ca:	1141                	addi	sp,sp,-16
 1cc:	e422                	sd	s0,8(sp)
 1ce:	0800                	addi	s0,sp,16
 1d0:	00054783          	lbu	a5,0(a0)
 1d4:	cb91                	beqz	a5,1e8 <strcmp+0x1e>
 1d6:	0005c703          	lbu	a4,0(a1)
 1da:	00f71763          	bne	a4,a5,1e8 <strcmp+0x1e>
 1de:	0505                	addi	a0,a0,1
 1e0:	0585                	addi	a1,a1,1
 1e2:	00054783          	lbu	a5,0(a0)
 1e6:	fbe5                	bnez	a5,1d6 <strcmp+0xc>
 1e8:	0005c503          	lbu	a0,0(a1)
 1ec:	40a7853b          	subw	a0,a5,a0
 1f0:	6422                	ld	s0,8(sp)
 1f2:	0141                	addi	sp,sp,16
 1f4:	8082                	ret

00000000000001f6 <strlen>:
 1f6:	1141                	addi	sp,sp,-16
 1f8:	e422                	sd	s0,8(sp)
 1fa:	0800                	addi	s0,sp,16
 1fc:	00054783          	lbu	a5,0(a0)
 200:	cf91                	beqz	a5,21c <strlen+0x26>
 202:	0505                	addi	a0,a0,1
 204:	87aa                	mv	a5,a0
 206:	4685                	li	a3,1
 208:	9e89                	subw	a3,a3,a0
 20a:	00f6853b          	addw	a0,a3,a5
 20e:	0785                	addi	a5,a5,1
 210:	fff7c703          	lbu	a4,-1(a5)
 214:	fb7d                	bnez	a4,20a <strlen+0x14>
 216:	6422                	ld	s0,8(sp)
 218:	0141                	addi	sp,sp,16
 21a:	8082                	ret
 21c:	4501                	li	a0,0
 21e:	bfe5                	j	216 <strlen+0x20>

0000000000000220 <memset>:
 220:	1141                	addi	sp,sp,-16
 222:	e422                	sd	s0,8(sp)
 224:	0800                	addi	s0,sp,16
 226:	ca19                	beqz	a2,23c <memset+0x1c>
 228:	87aa                	mv	a5,a0
 22a:	1602                	slli	a2,a2,0x20
 22c:	9201                	srli	a2,a2,0x20
 22e:	00a60733          	add	a4,a2,a0
 232:	00b78023          	sb	a1,0(a5)
 236:	0785                	addi	a5,a5,1
 238:	fee79de3          	bne	a5,a4,232 <memset+0x12>
 23c:	6422                	ld	s0,8(sp)
 23e:	0141                	addi	sp,sp,16
 240:	8082                	ret

0000000000000242 <strchr>:
 242:	1141                	addi	sp,sp,-16
 244:	e422                	sd	s0,8(sp)
 246:	0800                	addi	s0,sp,16
 248:	00054783          	lbu	a5,0(a0)
 24c:	cb99                	beqz	a5,262 <strchr+0x20>
 24e:	00f58763          	beq	a1,a5,25c <strchr+0x1a>
 252:	0505                	addi	a0,a0,1
 254:	00054783          	lbu	a5,0(a0)
 258:	fbfd                	bnez	a5,24e <strchr+0xc>
 25a:	4501                	li	a0,0
 25c:	6422                	ld	s0,8(sp)
 25e:	0141                	addi	sp,sp,16
 260:	8082                	ret
 262:	4501                	li	a0,0
 264:	bfe5                	j	25c <strchr+0x1a>

0000000000000266 <gets>:
 266:	711d                	addi	sp,sp,-96
 268:	ec86                	sd	ra,88(sp)
 26a:	e8a2                	sd	s0,80(sp)
 26c:	e4a6                	sd	s1,72(sp)
 26e:	e0ca                	sd	s2,64(sp)
 270:	fc4e                	sd	s3,56(sp)
 272:	f852                	sd	s4,48(sp)
 274:	f456                	sd	s5,40(sp)
 276:	f05a                	sd	s6,32(sp)
 278:	ec5e                	sd	s7,24(sp)
 27a:	1080                	addi	s0,sp,96
 27c:	8baa                	mv	s7,a0
 27e:	8a2e                	mv	s4,a1
 280:	892a                	mv	s2,a0
 282:	4481                	li	s1,0
 284:	4aa9                	li	s5,10
 286:	4b35                	li	s6,13
 288:	89a6                	mv	s3,s1
 28a:	2485                	addiw	s1,s1,1
 28c:	0344d863          	bge	s1,s4,2bc <gets+0x56>
 290:	4605                	li	a2,1
 292:	faf40593          	addi	a1,s0,-81
 296:	4501                	li	a0,0
 298:	00000097          	auipc	ra,0x0
 29c:	19c080e7          	jalr	412(ra) # 434 <read>
 2a0:	00a05e63          	blez	a0,2bc <gets+0x56>
 2a4:	faf44783          	lbu	a5,-81(s0)
 2a8:	00f90023          	sb	a5,0(s2)
 2ac:	01578763          	beq	a5,s5,2ba <gets+0x54>
 2b0:	0905                	addi	s2,s2,1
 2b2:	fd679be3          	bne	a5,s6,288 <gets+0x22>
 2b6:	89a6                	mv	s3,s1
 2b8:	a011                	j	2bc <gets+0x56>
 2ba:	89a6                	mv	s3,s1
 2bc:	99de                	add	s3,s3,s7
 2be:	00098023          	sb	zero,0(s3)
 2c2:	855e                	mv	a0,s7
 2c4:	60e6                	ld	ra,88(sp)
 2c6:	6446                	ld	s0,80(sp)
 2c8:	64a6                	ld	s1,72(sp)
 2ca:	6906                	ld	s2,64(sp)
 2cc:	79e2                	ld	s3,56(sp)
 2ce:	7a42                	ld	s4,48(sp)
 2d0:	7aa2                	ld	s5,40(sp)
 2d2:	7b02                	ld	s6,32(sp)
 2d4:	6be2                	ld	s7,24(sp)
 2d6:	6125                	addi	sp,sp,96
 2d8:	8082                	ret

00000000000002da <stat>:
 2da:	1101                	addi	sp,sp,-32
 2dc:	ec06                	sd	ra,24(sp)
 2de:	e822                	sd	s0,16(sp)
 2e0:	e426                	sd	s1,8(sp)
 2e2:	e04a                	sd	s2,0(sp)
 2e4:	1000                	addi	s0,sp,32
 2e6:	892e                	mv	s2,a1
 2e8:	4581                	li	a1,0
 2ea:	00000097          	auipc	ra,0x0
 2ee:	172080e7          	jalr	370(ra) # 45c <open>
 2f2:	02054563          	bltz	a0,31c <stat+0x42>
 2f6:	84aa                	mv	s1,a0
 2f8:	85ca                	mv	a1,s2
 2fa:	00000097          	auipc	ra,0x0
 2fe:	17a080e7          	jalr	378(ra) # 474 <fstat>
 302:	892a                	mv	s2,a0
 304:	8526                	mv	a0,s1
 306:	00000097          	auipc	ra,0x0
 30a:	13e080e7          	jalr	318(ra) # 444 <close>
 30e:	854a                	mv	a0,s2
 310:	60e2                	ld	ra,24(sp)
 312:	6442                	ld	s0,16(sp)
 314:	64a2                	ld	s1,8(sp)
 316:	6902                	ld	s2,0(sp)
 318:	6105                	addi	sp,sp,32
 31a:	8082                	ret
 31c:	597d                	li	s2,-1
 31e:	bfc5                	j	30e <stat+0x34>

0000000000000320 <atoi>:
 320:	1141                	addi	sp,sp,-16
 322:	e422                	sd	s0,8(sp)
 324:	0800                	addi	s0,sp,16
 326:	00054603          	lbu	a2,0(a0)
 32a:	fd06079b          	addiw	a5,a2,-48
 32e:	0ff7f793          	andi	a5,a5,255
 332:	4725                	li	a4,9
 334:	02f76963          	bltu	a4,a5,366 <atoi+0x46>
 338:	86aa                	mv	a3,a0
 33a:	4501                	li	a0,0
 33c:	45a5                	li	a1,9
 33e:	0685                	addi	a3,a3,1
 340:	0025179b          	slliw	a5,a0,0x2
 344:	9fa9                	addw	a5,a5,a0
 346:	0017979b          	slliw	a5,a5,0x1
 34a:	9fb1                	addw	a5,a5,a2
 34c:	fd07851b          	addiw	a0,a5,-48
 350:	0006c603          	lbu	a2,0(a3)
 354:	fd06071b          	addiw	a4,a2,-48
 358:	0ff77713          	andi	a4,a4,255
 35c:	fee5f1e3          	bgeu	a1,a4,33e <atoi+0x1e>
 360:	6422                	ld	s0,8(sp)
 362:	0141                	addi	sp,sp,16
 364:	8082                	ret
 366:	4501                	li	a0,0
 368:	bfe5                	j	360 <atoi+0x40>

000000000000036a <memmove>:
 36a:	1141                	addi	sp,sp,-16
 36c:	e422                	sd	s0,8(sp)
 36e:	0800                	addi	s0,sp,16
 370:	02b57463          	bgeu	a0,a1,398 <memmove+0x2e>
 374:	00c05f63          	blez	a2,392 <memmove+0x28>
 378:	1602                	slli	a2,a2,0x20
 37a:	9201                	srli	a2,a2,0x20
 37c:	00c507b3          	add	a5,a0,a2
 380:	872a                	mv	a4,a0
 382:	0585                	addi	a1,a1,1
 384:	0705                	addi	a4,a4,1
 386:	fff5c683          	lbu	a3,-1(a1)
 38a:	fed70fa3          	sb	a3,-1(a4)
 38e:	fee79ae3          	bne	a5,a4,382 <memmove+0x18>
 392:	6422                	ld	s0,8(sp)
 394:	0141                	addi	sp,sp,16
 396:	8082                	ret
 398:	00c50733          	add	a4,a0,a2
 39c:	95b2                	add	a1,a1,a2
 39e:	fec05ae3          	blez	a2,392 <memmove+0x28>
 3a2:	fff6079b          	addiw	a5,a2,-1
 3a6:	1782                	slli	a5,a5,0x20
 3a8:	9381                	srli	a5,a5,0x20
 3aa:	fff7c793          	not	a5,a5
 3ae:	97ba                	add	a5,a5,a4
 3b0:	15fd                	addi	a1,a1,-1
 3b2:	177d                	addi	a4,a4,-1
 3b4:	0005c683          	lbu	a3,0(a1)
 3b8:	00d70023          	sb	a3,0(a4)
 3bc:	fee79ae3          	bne	a5,a4,3b0 <memmove+0x46>
 3c0:	bfc9                	j	392 <memmove+0x28>

00000000000003c2 <memcmp>:
 3c2:	1141                	addi	sp,sp,-16
 3c4:	e422                	sd	s0,8(sp)
 3c6:	0800                	addi	s0,sp,16
 3c8:	ca05                	beqz	a2,3f8 <memcmp+0x36>
 3ca:	fff6069b          	addiw	a3,a2,-1
 3ce:	1682                	slli	a3,a3,0x20
 3d0:	9281                	srli	a3,a3,0x20
 3d2:	0685                	addi	a3,a3,1
 3d4:	96aa                	add	a3,a3,a0
 3d6:	00054783          	lbu	a5,0(a0)
 3da:	0005c703          	lbu	a4,0(a1)
 3de:	00e79863          	bne	a5,a4,3ee <memcmp+0x2c>
 3e2:	0505                	addi	a0,a0,1
 3e4:	0585                	addi	a1,a1,1
 3e6:	fed518e3          	bne	a0,a3,3d6 <memcmp+0x14>
 3ea:	4501                	li	a0,0
 3ec:	a019                	j	3f2 <memcmp+0x30>
 3ee:	40e7853b          	subw	a0,a5,a4
 3f2:	6422                	ld	s0,8(sp)
 3f4:	0141                	addi	sp,sp,16
 3f6:	8082                	ret
 3f8:	4501                	li	a0,0
 3fa:	bfe5                	j	3f2 <memcmp+0x30>

00000000000003fc <memcpy>:
 3fc:	1141                	addi	sp,sp,-16
 3fe:	e406                	sd	ra,8(sp)
 400:	e022                	sd	s0,0(sp)
 402:	0800                	addi	s0,sp,16
 404:	00000097          	auipc	ra,0x0
 408:	f66080e7          	jalr	-154(ra) # 36a <memmove>
 40c:	60a2                	ld	ra,8(sp)
 40e:	6402                	ld	s0,0(sp)
 410:	0141                	addi	sp,sp,16
 412:	8082                	ret

0000000000000414 <fork>:
 414:	4885                	li	a7,1
 416:	00000073          	ecall
 41a:	8082                	ret

000000000000041c <exit>:
 41c:	4889                	li	a7,2
 41e:	00000073          	ecall
 422:	8082                	ret

0000000000000424 <wait>:
 424:	488d                	li	a7,3
 426:	00000073          	ecall
 42a:	8082                	ret

000000000000042c <pipe>:
 42c:	4891                	li	a7,4
 42e:	00000073          	ecall
 432:	8082                	ret

0000000000000434 <read>:
 434:	4895                	li	a7,5
 436:	00000073          	ecall
 43a:	8082                	ret

000000000000043c <write>:
 43c:	48c1                	li	a7,16
 43e:	00000073          	ecall
 442:	8082                	ret

0000000000000444 <close>:
 444:	48d5                	li	a7,21
 446:	00000073          	ecall
 44a:	8082                	ret

000000000000044c <kill>:
 44c:	4899                	li	a7,6
 44e:	00000073          	ecall
 452:	8082                	ret

0000000000000454 <exec>:
 454:	489d                	li	a7,7
 456:	00000073          	ecall
 45a:	8082                	ret

000000000000045c <open>:
 45c:	48bd                	li	a7,15
 45e:	00000073          	ecall
 462:	8082                	ret

0000000000000464 <mknod>:
 464:	48c5                	li	a7,17
 466:	00000073          	ecall
 46a:	8082                	ret

000000000000046c <unlink>:
 46c:	48c9                	li	a7,18
 46e:	00000073          	ecall
 472:	8082                	ret

0000000000000474 <fstat>:
 474:	48a1                	li	a7,8
 476:	00000073          	ecall
 47a:	8082                	ret

000000000000047c <link>:
 47c:	48cd                	li	a7,19
 47e:	00000073          	ecall
 482:	8082                	ret

0000000000000484 <mkdir>:
 484:	48d1                	li	a7,20
 486:	00000073          	ecall
 48a:	8082                	ret

000000000000048c <chdir>:
 48c:	48a5                	li	a7,9
 48e:	00000073          	ecall
 492:	8082                	ret

0000000000000494 <dup>:
 494:	48a9                	li	a7,10
 496:	00000073          	ecall
 49a:	8082                	ret

000000000000049c <getpid>:
 49c:	48ad                	li	a7,11
 49e:	00000073          	ecall
 4a2:	8082                	ret

00000000000004a4 <sbrk>:
 4a4:	48b1                	li	a7,12
 4a6:	00000073          	ecall
 4aa:	8082                	ret

00000000000004ac <sleep>:
 4ac:	48b5                	li	a7,13
 4ae:	00000073          	ecall
 4b2:	8082                	ret

00000000000004b4 <uptime>:
 4b4:	48b9                	li	a7,14
 4b6:	00000073          	ecall
 4ba:	8082                	ret

00000000000004bc <putc>:
 4bc:	1101                	addi	sp,sp,-32
 4be:	ec06                	sd	ra,24(sp)
 4c0:	e822                	sd	s0,16(sp)
 4c2:	1000                	addi	s0,sp,32
 4c4:	feb407a3          	sb	a1,-17(s0)
 4c8:	4605                	li	a2,1
 4ca:	fef40593          	addi	a1,s0,-17
 4ce:	00000097          	auipc	ra,0x0
 4d2:	f6e080e7          	jalr	-146(ra) # 43c <write>
 4d6:	60e2                	ld	ra,24(sp)
 4d8:	6442                	ld	s0,16(sp)
 4da:	6105                	addi	sp,sp,32
 4dc:	8082                	ret

00000000000004de <printint>:
 4de:	7139                	addi	sp,sp,-64
 4e0:	fc06                	sd	ra,56(sp)
 4e2:	f822                	sd	s0,48(sp)
 4e4:	f426                	sd	s1,40(sp)
 4e6:	f04a                	sd	s2,32(sp)
 4e8:	ec4e                	sd	s3,24(sp)
 4ea:	0080                	addi	s0,sp,64
 4ec:	84aa                	mv	s1,a0
 4ee:	c299                	beqz	a3,4f4 <printint+0x16>
 4f0:	0805c863          	bltz	a1,580 <printint+0xa2>
 4f4:	2581                	sext.w	a1,a1
 4f6:	4881                	li	a7,0
 4f8:	fc040693          	addi	a3,s0,-64
 4fc:	4701                	li	a4,0
 4fe:	2601                	sext.w	a2,a2
 500:	00000517          	auipc	a0,0x0
 504:	45050513          	addi	a0,a0,1104 # 950 <digits>
 508:	883a                	mv	a6,a4
 50a:	2705                	addiw	a4,a4,1
 50c:	02c5f7bb          	remuw	a5,a1,a2
 510:	1782                	slli	a5,a5,0x20
 512:	9381                	srli	a5,a5,0x20
 514:	97aa                	add	a5,a5,a0
 516:	0007c783          	lbu	a5,0(a5)
 51a:	00f68023          	sb	a5,0(a3)
 51e:	0005879b          	sext.w	a5,a1
 522:	02c5d5bb          	divuw	a1,a1,a2
 526:	0685                	addi	a3,a3,1
 528:	fec7f0e3          	bgeu	a5,a2,508 <printint+0x2a>
 52c:	00088b63          	beqz	a7,542 <printint+0x64>
 530:	fd040793          	addi	a5,s0,-48
 534:	973e                	add	a4,a4,a5
 536:	02d00793          	li	a5,45
 53a:	fef70823          	sb	a5,-16(a4)
 53e:	0028071b          	addiw	a4,a6,2
 542:	02e05863          	blez	a4,572 <printint+0x94>
 546:	fc040793          	addi	a5,s0,-64
 54a:	00e78933          	add	s2,a5,a4
 54e:	fff78993          	addi	s3,a5,-1
 552:	99ba                	add	s3,s3,a4
 554:	377d                	addiw	a4,a4,-1
 556:	1702                	slli	a4,a4,0x20
 558:	9301                	srli	a4,a4,0x20
 55a:	40e989b3          	sub	s3,s3,a4
 55e:	fff94583          	lbu	a1,-1(s2)
 562:	8526                	mv	a0,s1
 564:	00000097          	auipc	ra,0x0
 568:	f58080e7          	jalr	-168(ra) # 4bc <putc>
 56c:	197d                	addi	s2,s2,-1
 56e:	ff3918e3          	bne	s2,s3,55e <printint+0x80>
 572:	70e2                	ld	ra,56(sp)
 574:	7442                	ld	s0,48(sp)
 576:	74a2                	ld	s1,40(sp)
 578:	7902                	ld	s2,32(sp)
 57a:	69e2                	ld	s3,24(sp)
 57c:	6121                	addi	sp,sp,64
 57e:	8082                	ret
 580:	40b005bb          	negw	a1,a1
 584:	4885                	li	a7,1
 586:	bf8d                	j	4f8 <printint+0x1a>

0000000000000588 <vprintf>:
 588:	7119                	addi	sp,sp,-128
 58a:	fc86                	sd	ra,120(sp)
 58c:	f8a2                	sd	s0,112(sp)
 58e:	f4a6                	sd	s1,104(sp)
 590:	f0ca                	sd	s2,96(sp)
 592:	ecce                	sd	s3,88(sp)
 594:	e8d2                	sd	s4,80(sp)
 596:	e4d6                	sd	s5,72(sp)
 598:	e0da                	sd	s6,64(sp)
 59a:	fc5e                	sd	s7,56(sp)
 59c:	f862                	sd	s8,48(sp)
 59e:	f466                	sd	s9,40(sp)
 5a0:	f06a                	sd	s10,32(sp)
 5a2:	ec6e                	sd	s11,24(sp)
 5a4:	0100                	addi	s0,sp,128
 5a6:	0005c903          	lbu	s2,0(a1)
 5aa:	18090f63          	beqz	s2,748 <vprintf+0x1c0>
 5ae:	8aaa                	mv	s5,a0
 5b0:	8b32                	mv	s6,a2
 5b2:	00158493          	addi	s1,a1,1
 5b6:	4981                	li	s3,0
 5b8:	02500a13          	li	s4,37
 5bc:	06400c13          	li	s8,100
 5c0:	06c00c93          	li	s9,108
 5c4:	07800d13          	li	s10,120
 5c8:	07000d93          	li	s11,112
 5cc:	00000b97          	auipc	s7,0x0
 5d0:	384b8b93          	addi	s7,s7,900 # 950 <digits>
 5d4:	a839                	j	5f2 <vprintf+0x6a>
 5d6:	85ca                	mv	a1,s2
 5d8:	8556                	mv	a0,s5
 5da:	00000097          	auipc	ra,0x0
 5de:	ee2080e7          	jalr	-286(ra) # 4bc <putc>
 5e2:	a019                	j	5e8 <vprintf+0x60>
 5e4:	01498f63          	beq	s3,s4,602 <vprintf+0x7a>
 5e8:	0485                	addi	s1,s1,1
 5ea:	fff4c903          	lbu	s2,-1(s1)
 5ee:	14090d63          	beqz	s2,748 <vprintf+0x1c0>
 5f2:	0009079b          	sext.w	a5,s2
 5f6:	fe0997e3          	bnez	s3,5e4 <vprintf+0x5c>
 5fa:	fd479ee3          	bne	a5,s4,5d6 <vprintf+0x4e>
 5fe:	89be                	mv	s3,a5
 600:	b7e5                	j	5e8 <vprintf+0x60>
 602:	05878063          	beq	a5,s8,642 <vprintf+0xba>
 606:	05978c63          	beq	a5,s9,65e <vprintf+0xd6>
 60a:	07a78863          	beq	a5,s10,67a <vprintf+0xf2>
 60e:	09b78463          	beq	a5,s11,696 <vprintf+0x10e>
 612:	07300713          	li	a4,115
 616:	0ce78663          	beq	a5,a4,6e2 <vprintf+0x15a>
 61a:	06300713          	li	a4,99
 61e:	0ee78e63          	beq	a5,a4,71a <vprintf+0x192>
 622:	11478863          	beq	a5,s4,732 <vprintf+0x1aa>
 626:	85d2                	mv	a1,s4
 628:	8556                	mv	a0,s5
 62a:	00000097          	auipc	ra,0x0
 62e:	e92080e7          	jalr	-366(ra) # 4bc <putc>
 632:	85ca                	mv	a1,s2
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	e86080e7          	jalr	-378(ra) # 4bc <putc>
 63e:	4981                	li	s3,0
 640:	b765                	j	5e8 <vprintf+0x60>
 642:	008b0913          	addi	s2,s6,8
 646:	4685                	li	a3,1
 648:	4629                	li	a2,10
 64a:	000b2583          	lw	a1,0(s6)
 64e:	8556                	mv	a0,s5
 650:	00000097          	auipc	ra,0x0
 654:	e8e080e7          	jalr	-370(ra) # 4de <printint>
 658:	8b4a                	mv	s6,s2
 65a:	4981                	li	s3,0
 65c:	b771                	j	5e8 <vprintf+0x60>
 65e:	008b0913          	addi	s2,s6,8
 662:	4681                	li	a3,0
 664:	4629                	li	a2,10
 666:	000b2583          	lw	a1,0(s6)
 66a:	8556                	mv	a0,s5
 66c:	00000097          	auipc	ra,0x0
 670:	e72080e7          	jalr	-398(ra) # 4de <printint>
 674:	8b4a                	mv	s6,s2
 676:	4981                	li	s3,0
 678:	bf85                	j	5e8 <vprintf+0x60>
 67a:	008b0913          	addi	s2,s6,8
 67e:	4681                	li	a3,0
 680:	4641                	li	a2,16
 682:	000b2583          	lw	a1,0(s6)
 686:	8556                	mv	a0,s5
 688:	00000097          	auipc	ra,0x0
 68c:	e56080e7          	jalr	-426(ra) # 4de <printint>
 690:	8b4a                	mv	s6,s2
 692:	4981                	li	s3,0
 694:	bf91                	j	5e8 <vprintf+0x60>
 696:	008b0793          	addi	a5,s6,8
 69a:	f8f43423          	sd	a5,-120(s0)
 69e:	000b3983          	ld	s3,0(s6)
 6a2:	03000593          	li	a1,48
 6a6:	8556                	mv	a0,s5
 6a8:	00000097          	auipc	ra,0x0
 6ac:	e14080e7          	jalr	-492(ra) # 4bc <putc>
 6b0:	85ea                	mv	a1,s10
 6b2:	8556                	mv	a0,s5
 6b4:	00000097          	auipc	ra,0x0
 6b8:	e08080e7          	jalr	-504(ra) # 4bc <putc>
 6bc:	4941                	li	s2,16
 6be:	03c9d793          	srli	a5,s3,0x3c
 6c2:	97de                	add	a5,a5,s7
 6c4:	0007c583          	lbu	a1,0(a5)
 6c8:	8556                	mv	a0,s5
 6ca:	00000097          	auipc	ra,0x0
 6ce:	df2080e7          	jalr	-526(ra) # 4bc <putc>
 6d2:	0992                	slli	s3,s3,0x4
 6d4:	397d                	addiw	s2,s2,-1
 6d6:	fe0914e3          	bnez	s2,6be <vprintf+0x136>
 6da:	f8843b03          	ld	s6,-120(s0)
 6de:	4981                	li	s3,0
 6e0:	b721                	j	5e8 <vprintf+0x60>
 6e2:	008b0993          	addi	s3,s6,8
 6e6:	000b3903          	ld	s2,0(s6)
 6ea:	02090163          	beqz	s2,70c <vprintf+0x184>
 6ee:	00094583          	lbu	a1,0(s2)
 6f2:	c9a1                	beqz	a1,742 <vprintf+0x1ba>
 6f4:	8556                	mv	a0,s5
 6f6:	00000097          	auipc	ra,0x0
 6fa:	dc6080e7          	jalr	-570(ra) # 4bc <putc>
 6fe:	0905                	addi	s2,s2,1
 700:	00094583          	lbu	a1,0(s2)
 704:	f9e5                	bnez	a1,6f4 <vprintf+0x16c>
 706:	8b4e                	mv	s6,s3
 708:	4981                	li	s3,0
 70a:	bdf9                	j	5e8 <vprintf+0x60>
 70c:	00000917          	auipc	s2,0x0
 710:	23c90913          	addi	s2,s2,572 # 948 <malloc+0xf6>
 714:	02800593          	li	a1,40
 718:	bff1                	j	6f4 <vprintf+0x16c>
 71a:	008b0913          	addi	s2,s6,8
 71e:	000b4583          	lbu	a1,0(s6)
 722:	8556                	mv	a0,s5
 724:	00000097          	auipc	ra,0x0
 728:	d98080e7          	jalr	-616(ra) # 4bc <putc>
 72c:	8b4a                	mv	s6,s2
 72e:	4981                	li	s3,0
 730:	bd65                	j	5e8 <vprintf+0x60>
 732:	85d2                	mv	a1,s4
 734:	8556                	mv	a0,s5
 736:	00000097          	auipc	ra,0x0
 73a:	d86080e7          	jalr	-634(ra) # 4bc <putc>
 73e:	4981                	li	s3,0
 740:	b565                	j	5e8 <vprintf+0x60>
 742:	8b4e                	mv	s6,s3
 744:	4981                	li	s3,0
 746:	b54d                	j	5e8 <vprintf+0x60>
 748:	70e6                	ld	ra,120(sp)
 74a:	7446                	ld	s0,112(sp)
 74c:	74a6                	ld	s1,104(sp)
 74e:	7906                	ld	s2,96(sp)
 750:	69e6                	ld	s3,88(sp)
 752:	6a46                	ld	s4,80(sp)
 754:	6aa6                	ld	s5,72(sp)
 756:	6b06                	ld	s6,64(sp)
 758:	7be2                	ld	s7,56(sp)
 75a:	7c42                	ld	s8,48(sp)
 75c:	7ca2                	ld	s9,40(sp)
 75e:	7d02                	ld	s10,32(sp)
 760:	6de2                	ld	s11,24(sp)
 762:	6109                	addi	sp,sp,128
 764:	8082                	ret

0000000000000766 <fprintf>:
 766:	715d                	addi	sp,sp,-80
 768:	ec06                	sd	ra,24(sp)
 76a:	e822                	sd	s0,16(sp)
 76c:	1000                	addi	s0,sp,32
 76e:	e010                	sd	a2,0(s0)
 770:	e414                	sd	a3,8(s0)
 772:	e818                	sd	a4,16(s0)
 774:	ec1c                	sd	a5,24(s0)
 776:	03043023          	sd	a6,32(s0)
 77a:	03143423          	sd	a7,40(s0)
 77e:	fe843423          	sd	s0,-24(s0)
 782:	8622                	mv	a2,s0
 784:	00000097          	auipc	ra,0x0
 788:	e04080e7          	jalr	-508(ra) # 588 <vprintf>
 78c:	60e2                	ld	ra,24(sp)
 78e:	6442                	ld	s0,16(sp)
 790:	6161                	addi	sp,sp,80
 792:	8082                	ret

0000000000000794 <printf>:
 794:	711d                	addi	sp,sp,-96
 796:	ec06                	sd	ra,24(sp)
 798:	e822                	sd	s0,16(sp)
 79a:	1000                	addi	s0,sp,32
 79c:	e40c                	sd	a1,8(s0)
 79e:	e810                	sd	a2,16(s0)
 7a0:	ec14                	sd	a3,24(s0)
 7a2:	f018                	sd	a4,32(s0)
 7a4:	f41c                	sd	a5,40(s0)
 7a6:	03043823          	sd	a6,48(s0)
 7aa:	03143c23          	sd	a7,56(s0)
 7ae:	00840613          	addi	a2,s0,8
 7b2:	fec43423          	sd	a2,-24(s0)
 7b6:	85aa                	mv	a1,a0
 7b8:	4505                	li	a0,1
 7ba:	00000097          	auipc	ra,0x0
 7be:	dce080e7          	jalr	-562(ra) # 588 <vprintf>
 7c2:	60e2                	ld	ra,24(sp)
 7c4:	6442                	ld	s0,16(sp)
 7c6:	6125                	addi	sp,sp,96
 7c8:	8082                	ret

00000000000007ca <free>:
 7ca:	1141                	addi	sp,sp,-16
 7cc:	e422                	sd	s0,8(sp)
 7ce:	0800                	addi	s0,sp,16
 7d0:	ff050693          	addi	a3,a0,-16
 7d4:	00000797          	auipc	a5,0x0
 7d8:	1947b783          	ld	a5,404(a5) # 968 <freep>
 7dc:	a805                	j	80c <free+0x42>
 7de:	4618                	lw	a4,8(a2)
 7e0:	9db9                	addw	a1,a1,a4
 7e2:	feb52c23          	sw	a1,-8(a0)
 7e6:	6398                	ld	a4,0(a5)
 7e8:	6318                	ld	a4,0(a4)
 7ea:	fee53823          	sd	a4,-16(a0)
 7ee:	a091                	j	832 <free+0x68>
 7f0:	ff852703          	lw	a4,-8(a0)
 7f4:	9e39                	addw	a2,a2,a4
 7f6:	c790                	sw	a2,8(a5)
 7f8:	ff053703          	ld	a4,-16(a0)
 7fc:	e398                	sd	a4,0(a5)
 7fe:	a099                	j	844 <free+0x7a>
 800:	6398                	ld	a4,0(a5)
 802:	00e7e463          	bltu	a5,a4,80a <free+0x40>
 806:	00e6ea63          	bltu	a3,a4,81a <free+0x50>
 80a:	87ba                	mv	a5,a4
 80c:	fed7fae3          	bgeu	a5,a3,800 <free+0x36>
 810:	6398                	ld	a4,0(a5)
 812:	00e6e463          	bltu	a3,a4,81a <free+0x50>
 816:	fee7eae3          	bltu	a5,a4,80a <free+0x40>
 81a:	ff852583          	lw	a1,-8(a0)
 81e:	6390                	ld	a2,0(a5)
 820:	02059813          	slli	a6,a1,0x20
 824:	01c85713          	srli	a4,a6,0x1c
 828:	9736                	add	a4,a4,a3
 82a:	fae60ae3          	beq	a2,a4,7de <free+0x14>
 82e:	fec53823          	sd	a2,-16(a0)
 832:	4790                	lw	a2,8(a5)
 834:	02061593          	slli	a1,a2,0x20
 838:	01c5d713          	srli	a4,a1,0x1c
 83c:	973e                	add	a4,a4,a5
 83e:	fae689e3          	beq	a3,a4,7f0 <free+0x26>
 842:	e394                	sd	a3,0(a5)
 844:	00000717          	auipc	a4,0x0
 848:	12f73223          	sd	a5,292(a4) # 968 <freep>
 84c:	6422                	ld	s0,8(sp)
 84e:	0141                	addi	sp,sp,16
 850:	8082                	ret

0000000000000852 <malloc>:
 852:	7139                	addi	sp,sp,-64
 854:	fc06                	sd	ra,56(sp)
 856:	f822                	sd	s0,48(sp)
 858:	f426                	sd	s1,40(sp)
 85a:	f04a                	sd	s2,32(sp)
 85c:	ec4e                	sd	s3,24(sp)
 85e:	e852                	sd	s4,16(sp)
 860:	e456                	sd	s5,8(sp)
 862:	e05a                	sd	s6,0(sp)
 864:	0080                	addi	s0,sp,64
 866:	02051493          	slli	s1,a0,0x20
 86a:	9081                	srli	s1,s1,0x20
 86c:	04bd                	addi	s1,s1,15
 86e:	8091                	srli	s1,s1,0x4
 870:	0014899b          	addiw	s3,s1,1
 874:	0485                	addi	s1,s1,1
 876:	00000517          	auipc	a0,0x0
 87a:	0f253503          	ld	a0,242(a0) # 968 <freep>
 87e:	c515                	beqz	a0,8aa <malloc+0x58>
 880:	611c                	ld	a5,0(a0)
 882:	4798                	lw	a4,8(a5)
 884:	02977f63          	bgeu	a4,s1,8c2 <malloc+0x70>
 888:	8a4e                	mv	s4,s3
 88a:	0009871b          	sext.w	a4,s3
 88e:	6685                	lui	a3,0x1
 890:	00d77363          	bgeu	a4,a3,896 <malloc+0x44>
 894:	6a05                	lui	s4,0x1
 896:	000a0b1b          	sext.w	s6,s4
 89a:	004a1a1b          	slliw	s4,s4,0x4
 89e:	00000917          	auipc	s2,0x0
 8a2:	0ca90913          	addi	s2,s2,202 # 968 <freep>
 8a6:	5afd                	li	s5,-1
 8a8:	a895                	j	91c <malloc+0xca>
 8aa:	00000797          	auipc	a5,0x0
 8ae:	0c678793          	addi	a5,a5,198 # 970 <base>
 8b2:	00000717          	auipc	a4,0x0
 8b6:	0af73b23          	sd	a5,182(a4) # 968 <freep>
 8ba:	e39c                	sd	a5,0(a5)
 8bc:	0007a423          	sw	zero,8(a5)
 8c0:	b7e1                	j	888 <malloc+0x36>
 8c2:	02e48c63          	beq	s1,a4,8fa <malloc+0xa8>
 8c6:	4137073b          	subw	a4,a4,s3
 8ca:	c798                	sw	a4,8(a5)
 8cc:	02071693          	slli	a3,a4,0x20
 8d0:	01c6d713          	srli	a4,a3,0x1c
 8d4:	97ba                	add	a5,a5,a4
 8d6:	0137a423          	sw	s3,8(a5)
 8da:	00000717          	auipc	a4,0x0
 8de:	08a73723          	sd	a0,142(a4) # 968 <freep>
 8e2:	01078513          	addi	a0,a5,16
 8e6:	70e2                	ld	ra,56(sp)
 8e8:	7442                	ld	s0,48(sp)
 8ea:	74a2                	ld	s1,40(sp)
 8ec:	7902                	ld	s2,32(sp)
 8ee:	69e2                	ld	s3,24(sp)
 8f0:	6a42                	ld	s4,16(sp)
 8f2:	6aa2                	ld	s5,8(sp)
 8f4:	6b02                	ld	s6,0(sp)
 8f6:	6121                	addi	sp,sp,64
 8f8:	8082                	ret
 8fa:	6398                	ld	a4,0(a5)
 8fc:	e118                	sd	a4,0(a0)
 8fe:	bff1                	j	8da <malloc+0x88>
 900:	01652423          	sw	s6,8(a0)
 904:	0541                	addi	a0,a0,16
 906:	00000097          	auipc	ra,0x0
 90a:	ec4080e7          	jalr	-316(ra) # 7ca <free>
 90e:	00093503          	ld	a0,0(s2)
 912:	d971                	beqz	a0,8e6 <malloc+0x94>
 914:	611c                	ld	a5,0(a0)
 916:	4798                	lw	a4,8(a5)
 918:	fa9775e3          	bgeu	a4,s1,8c2 <malloc+0x70>
 91c:	00093703          	ld	a4,0(s2)
 920:	853e                	mv	a0,a5
 922:	fef719e3          	bne	a4,a5,914 <malloc+0xc2>
 926:	8552                	mv	a0,s4
 928:	00000097          	auipc	ra,0x0
 92c:	b7c080e7          	jalr	-1156(ra) # 4a4 <sbrk>
 930:	fd5518e3          	bne	a0,s5,900 <malloc+0xae>
 934:	4501                	li	a0,0
 936:	bf45                	j	8e6 <malloc+0x94>
