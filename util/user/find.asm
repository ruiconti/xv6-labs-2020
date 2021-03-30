
user/_find:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print_substrings>:
 *  else.txt
 */


void print_substrings(char *fname, char *term)
{
   0:	7159                	addi	sp,sp,-112
   2:	f486                	sd	ra,104(sp)
   4:	f0a2                	sd	s0,96(sp)
   6:	eca6                	sd	s1,88(sp)
   8:	e8ca                	sd	s2,80(sp)
   a:	e4ce                	sd	s3,72(sp)
   c:	e0d2                	sd	s4,64(sp)
   e:	fc56                	sd	s5,56(sp)
  10:	f85a                	sd	s6,48(sp)
  12:	f45e                	sd	s7,40(sp)
  14:	f062                	sd	s8,32(sp)
  16:	ec66                	sd	s9,24(sp)
  18:	e86a                	sd	s10,16(sp)
  1a:	e46e                	sd	s11,8(sp)
  1c:	1880                	addi	s0,sp,112
  1e:	8caa                	mv	s9,a0
  20:	8a2e                	mv	s4,a1
     * order */ 
    char *pfname, *pterm, *ptermi, *pfnamei;
    int j=0;
    int vseek=1; // valid seek control flag

    pfname = fname; pterm = term;
  22:	892a                	mv	s2,a0
    for(int i=0; i<strlen(fname); i++)
  24:	4981                	li	s3,0
  26:	4b85                	li	s7,1
        if (*pfname == *pterm) {
            /* meaning that the beginning of both strs have matched */
            /* we set an pointer that iterates in fname */
            pfnamei = pfname;
            ptermi = pterm;
            for(j=0; j<strlen(term) && vseek == 1; j++) {
  28:	4d01                	li	s10,0
    for(int i=0; i<strlen(fname); i++)
  2a:	a88d                	j	9c <print_substrings+0x9c>
                if (*pfnamei && *ptermi && *pfnamei == *ptermi) 
                {
                    /* since we're adding p2 which points to term, strlen behaves
                     * unexpectedly. Hence we need to check if p2 and p3 are
                     * valid */
                    pfnamei++;
  2c:	0c05                	addi	s8,s8,1
                    ptermi++;
  2e:	0d85                	addi	s11,s11,1
  30:	a011                	j	34 <print_substrings+0x34>
                }
                else
                {
                    /* if anything doesn't match, its not a substr */
                    vseek = 0;
  32:	8b6a                	mv	s6,s10
            for(j=0; j<strlen(term) && vseek == 1; j++) {
  34:	2485                	addiw	s1,s1,1
  36:	8552                	mv	a0,s4
  38:	00000097          	auipc	ra,0x0
  3c:	31c080e7          	jalr	796(ra) # 354 <strlen>
  40:	2501                	sext.w	a0,a0
  42:	00048a9b          	sext.w	s5,s1
  46:	02aaf063          	bgeu	s5,a0,66 <print_substrings+0x66>
  4a:	057b1263          	bne	s6,s7,8e <print_substrings+0x8e>
                if (*pfnamei && *ptermi && *pfnamei == *ptermi) 
  4e:	000c4783          	lbu	a5,0(s8)
  52:	d3e5                	beqz	a5,32 <print_substrings+0x32>
  54:	000dc703          	lbu	a4,0(s11)
  58:	c709                	beqz	a4,62 <print_substrings+0x62>
  5a:	fce789e3          	beq	a5,a4,2c <print_substrings+0x2c>
                    vseek = 0;
  5e:	8b6a                	mv	s6,s10
  60:	bfd1                	j	34 <print_substrings+0x34>
  62:	8b6a                	mv	s6,s10
  64:	bfc1                	j	34 <print_substrings+0x34>
                    //break;
                }
            }
            if(j == strlen(term) && vseek == 1) {
  66:	8552                	mv	a0,s4
  68:	00000097          	auipc	ra,0x0
  6c:	2ec080e7          	jalr	748(ra) # 354 <strlen>
  70:	2501                	sext.w	a0,a0
  72:	03551363          	bne	a0,s5,98 <print_substrings+0x98>
  76:	037b1163          	bne	s6,s7,98 <print_substrings+0x98>
                printf("%s\n", fname);
  7a:	85e6                	mv	a1,s9
  7c:	00001517          	auipc	a0,0x1
  80:	a1c50513          	addi	a0,a0,-1508 # a98 <malloc+0xe8>
  84:	00001097          	auipc	ra,0x1
  88:	86e080e7          	jalr	-1938(ra) # 8f2 <printf>
  8c:	a031                	j	98 <print_substrings+0x98>
            if(j == strlen(term) && vseek == 1) {
  8e:	8552                	mv	a0,s4
  90:	00000097          	auipc	ra,0x0
  94:	2c4080e7          	jalr	708(ra) # 354 <strlen>
            }
        }
        ++pfname;
  98:	0905                	addi	s2,s2,1
    for(int i=0; i<strlen(fname); i++)
  9a:	2985                	addiw	s3,s3,1
  9c:	8566                	mv	a0,s9
  9e:	00000097          	auipc	ra,0x0
  a2:	2b6080e7          	jalr	694(ra) # 354 <strlen>
  a6:	2501                	sext.w	a0,a0
  a8:	00a9fd63          	bgeu	s3,a0,c2 <print_substrings+0xc2>
        if (*pfname == *pterm) {
  ac:	00094703          	lbu	a4,0(s2)
  b0:	000a4783          	lbu	a5,0(s4)
  b4:	fef712e3          	bne	a4,a5,98 <print_substrings+0x98>
            pfnamei = pfname;
  b8:	8c4a                	mv	s8,s2
            ptermi = pterm;
  ba:	8dd2                	mv	s11,s4
  bc:	8b5e                	mv	s6,s7
            for(j=0; j<strlen(term) && vseek == 1; j++) {
  be:	84ea                	mv	s1,s10
  c0:	bf9d                	j	36 <print_substrings+0x36>
        vseek = 1;
    }

}
  c2:	70a6                	ld	ra,104(sp)
  c4:	7406                	ld	s0,96(sp)
  c6:	64e6                	ld	s1,88(sp)
  c8:	6946                	ld	s2,80(sp)
  ca:	69a6                	ld	s3,72(sp)
  cc:	6a06                	ld	s4,64(sp)
  ce:	7ae2                	ld	s5,56(sp)
  d0:	7b42                	ld	s6,48(sp)
  d2:	7ba2                	ld	s7,40(sp)
  d4:	7c02                	ld	s8,32(sp)
  d6:	6ce2                	ld	s9,24(sp)
  d8:	6d42                	ld	s10,16(sp)
  da:	6da2                	ld	s11,8(sp)
  dc:	6165                	addi	sp,sp,112
  de:	8082                	ret

00000000000000e0 <find>:

void
find(char *dirpath, char *term)
{
  e0:	d8010113          	addi	sp,sp,-640
  e4:	26113c23          	sd	ra,632(sp)
  e8:	26813823          	sd	s0,624(sp)
  ec:	26913423          	sd	s1,616(sp)
  f0:	27213023          	sd	s2,608(sp)
  f4:	25313c23          	sd	s3,600(sp)
  f8:	25413823          	sd	s4,592(sp)
  fc:	25513423          	sd	s5,584(sp)
 100:	25613023          	sd	s6,576(sp)
 104:	23713c23          	sd	s7,568(sp)
 108:	23813823          	sd	s8,560(sp)
 10c:	0500                	addi	s0,sp,640
 10e:	892a                	mv	s2,a0
 110:	89ae                	mv	s3,a1
  int fd;
  struct stat st;
  struct dirent de;
  char buf[512], *p;

  if((fd = open(dirpath, 0)) < 0)
 112:	4581                	li	a1,0
 114:	00000097          	auipc	ra,0x0
 118:	4a6080e7          	jalr	1190(ra) # 5ba <open>
 11c:	06054b63          	bltz	a0,192 <find+0xb2>
 120:	84aa                	mv	s1,a0
  {
    fprintf(2, "find: directory %s does not exist\n", dirpath);
    return;
  }

  if(fstat(fd, &st) < 0)
 122:	f9840593          	addi	a1,s0,-104
 126:	00000097          	auipc	ra,0x0
 12a:	4ac080e7          	jalr	1196(ra) # 5d2 <fstat>
 12e:	06054d63          	bltz	a0,1a8 <find+0xc8>
    /* we're both getting stat for fd and checking for errors */
    fprintf(2, "find: cannot get status for directory %s\n", dirpath);
    return;
  }

  switch(st.type)
 132:	fa041783          	lh	a5,-96(s0)
 136:	0007869b          	sext.w	a3,a5
 13a:	4705                	li	a4,1
 13c:	08e68163          	beq	a3,a4,1be <find+0xde>
 140:	4709                	li	a4,2
 142:	00e69c63          	bne	a3,a4,15a <find+0x7a>
  {
  case T_FILE:
      fprintf(2, "find: %s is a file not a directory.", dirpath);
 146:	864a                	mv	a2,s2
 148:	00001597          	auipc	a1,0x1
 14c:	9b058593          	addi	a1,a1,-1616 # af8 <malloc+0x148>
 150:	4509                	li	a0,2
 152:	00000097          	auipc	ra,0x0
 156:	772080e7          	jalr	1906(ra) # 8c4 <fprintf>
              //print_substrings(buf, term);
          }
      }
      break;
  }
  close(fd);
 15a:	8526                	mv	a0,s1
 15c:	00000097          	auipc	ra,0x0
 160:	446080e7          	jalr	1094(ra) # 5a2 <close>
}
 164:	27813083          	ld	ra,632(sp)
 168:	27013403          	ld	s0,624(sp)
 16c:	26813483          	ld	s1,616(sp)
 170:	26013903          	ld	s2,608(sp)
 174:	25813983          	ld	s3,600(sp)
 178:	25013a03          	ld	s4,592(sp)
 17c:	24813a83          	ld	s5,584(sp)
 180:	24013b03          	ld	s6,576(sp)
 184:	23813b83          	ld	s7,568(sp)
 188:	23013c03          	ld	s8,560(sp)
 18c:	28010113          	addi	sp,sp,640
 190:	8082                	ret
    fprintf(2, "find: directory %s does not exist\n", dirpath);
 192:	864a                	mv	a2,s2
 194:	00001597          	auipc	a1,0x1
 198:	90c58593          	addi	a1,a1,-1780 # aa0 <malloc+0xf0>
 19c:	4509                	li	a0,2
 19e:	00000097          	auipc	ra,0x0
 1a2:	726080e7          	jalr	1830(ra) # 8c4 <fprintf>
    return;
 1a6:	bf7d                	j	164 <find+0x84>
    fprintf(2, "find: cannot get status for directory %s\n", dirpath);
 1a8:	864a                	mv	a2,s2
 1aa:	00001597          	auipc	a1,0x1
 1ae:	91e58593          	addi	a1,a1,-1762 # ac8 <malloc+0x118>
 1b2:	4509                	li	a0,2
 1b4:	00000097          	auipc	ra,0x0
 1b8:	710080e7          	jalr	1808(ra) # 8c4 <fprintf>
    return;
 1bc:	b765                	j	164 <find+0x84>
      strcpy(buf, dirpath);  /* copy dirpath content into buf */
 1be:	85ca                	mv	a1,s2
 1c0:	d8840513          	addi	a0,s0,-632
 1c4:	00000097          	auipc	ra,0x0
 1c8:	148080e7          	jalr	328(ra) # 30c <strcpy>
      p = buf + strlen(buf); /* points to the end of dirpath inside buf */ 
 1cc:	d8840513          	addi	a0,s0,-632
 1d0:	00000097          	auipc	ra,0x0
 1d4:	184080e7          	jalr	388(ra) # 354 <strlen>
 1d8:	02051913          	slli	s2,a0,0x20
 1dc:	02095913          	srli	s2,s2,0x20
 1e0:	d8840793          	addi	a5,s0,-632
 1e4:	993e                	add	s2,s2,a5
      *p++ = '/';  /* now it adds a / after dirpath */ 
 1e6:	00190a13          	addi	s4,s2,1
 1ea:	02f00793          	li	a5,47
 1ee:	00f90023          	sb	a5,0(s2)
          if(st.type == T_DIR)
 1f2:	4a85                	li	s5,1
          else if(st.type == T_FILE)
 1f4:	4b09                	li	s6,2
              if (!strcmp(de.name, term)) printf("%s\n", buf);
 1f6:	00001c17          	auipc	s8,0x1
 1fa:	8a2c0c13          	addi	s8,s8,-1886 # a98 <malloc+0xe8>
              if (strcmp(de.name, ".") == 0 || strcmp(de.name, "..") == 0)
 1fe:	00001b97          	auipc	s7,0x1
 202:	94ab8b93          	addi	s7,s7,-1718 # b48 <malloc+0x198>
      while(read(fd, &de, sizeof(de)) == sizeof(de))
 206:	4641                	li	a2,16
 208:	f8840593          	addi	a1,s0,-120
 20c:	8526                	mv	a0,s1
 20e:	00000097          	auipc	ra,0x0
 212:	384080e7          	jalr	900(ra) # 592 <read>
 216:	47c1                	li	a5,16
 218:	f4f511e3          	bne	a0,a5,15a <find+0x7a>
          if (de.inum == 0) continue;
 21c:	f8845783          	lhu	a5,-120(s0)
 220:	d3fd                	beqz	a5,206 <find+0x126>
          memmove(p, de.name, DIRSIZ);
 222:	4639                	li	a2,14
 224:	f8a40593          	addi	a1,s0,-118
 228:	8552                	mv	a0,s4
 22a:	00000097          	auipc	ra,0x0
 22e:	29e080e7          	jalr	670(ra) # 4c8 <memmove>
          p[DIRSIZ] = 0;
 232:	000907a3          	sb	zero,15(s2)
          if(stat(buf, &st) < 0)
 236:	f9840593          	addi	a1,s0,-104
 23a:	d8840513          	addi	a0,s0,-632
 23e:	00000097          	auipc	ra,0x0
 242:	1fa080e7          	jalr	506(ra) # 438 <stat>
 246:	02054b63          	bltz	a0,27c <find+0x19c>
          if(st.type == T_DIR)
 24a:	fa041783          	lh	a5,-96(s0)
 24e:	0007871b          	sext.w	a4,a5
 252:	05570163          	beq	a4,s5,294 <find+0x1b4>
          else if(st.type == T_FILE)
 256:	2781                	sext.w	a5,a5
 258:	fb6797e3          	bne	a5,s6,206 <find+0x126>
              if (!strcmp(de.name, term)) printf("%s\n", buf);
 25c:	85ce                	mv	a1,s3
 25e:	f8a40513          	addi	a0,s0,-118
 262:	00000097          	auipc	ra,0x0
 266:	0c6080e7          	jalr	198(ra) # 328 <strcmp>
 26a:	fd51                	bnez	a0,206 <find+0x126>
 26c:	d8840593          	addi	a1,s0,-632
 270:	8562                	mv	a0,s8
 272:	00000097          	auipc	ra,0x0
 276:	680080e7          	jalr	1664(ra) # 8f2 <printf>
 27a:	b771                	j	206 <find+0x126>
              fprintf(2, "find: cannot get status for file %s", de.name);
 27c:	f8a40613          	addi	a2,s0,-118
 280:	00001597          	auipc	a1,0x1
 284:	8a058593          	addi	a1,a1,-1888 # b20 <malloc+0x170>
 288:	4509                	li	a0,2
 28a:	00000097          	auipc	ra,0x0
 28e:	63a080e7          	jalr	1594(ra) # 8c4 <fprintf>
              return;
 292:	bdc9                	j	164 <find+0x84>
              if (strcmp(de.name, ".") == 0 || strcmp(de.name, "..") == 0)
 294:	85de                	mv	a1,s7
 296:	f8a40513          	addi	a0,s0,-118
 29a:	00000097          	auipc	ra,0x0
 29e:	08e080e7          	jalr	142(ra) # 328 <strcmp>
 2a2:	d135                	beqz	a0,206 <find+0x126>
 2a4:	00001597          	auipc	a1,0x1
 2a8:	8ac58593          	addi	a1,a1,-1876 # b50 <malloc+0x1a0>
 2ac:	f8a40513          	addi	a0,s0,-118
 2b0:	00000097          	auipc	ra,0x0
 2b4:	078080e7          	jalr	120(ra) # 328 <strcmp>
 2b8:	d539                	beqz	a0,206 <find+0x126>
              find(buf, term);
 2ba:	85ce                	mv	a1,s3
 2bc:	d8840513          	addi	a0,s0,-632
 2c0:	00000097          	auipc	ra,0x0
 2c4:	e20080e7          	jalr	-480(ra) # e0 <find>
 2c8:	bf3d                	j	206 <find+0x126>

00000000000002ca <main>:

int
main(int argc, char *argv[])
{
 2ca:	1141                	addi	sp,sp,-16
 2cc:	e406                	sd	ra,8(sp)
 2ce:	e022                	sd	s0,0(sp)
 2d0:	0800                	addi	s0,sp,16
    if(argc != 3)
 2d2:	470d                	li	a4,3
 2d4:	02e50063          	beq	a0,a4,2f4 <main+0x2a>
    {
        fprintf(2, "USAGE: find <directory> <filename>");
 2d8:	00001597          	auipc	a1,0x1
 2dc:	88058593          	addi	a1,a1,-1920 # b58 <malloc+0x1a8>
 2e0:	4509                	li	a0,2
 2e2:	00000097          	auipc	ra,0x0
 2e6:	5e2080e7          	jalr	1506(ra) # 8c4 <fprintf>
        exit(1);
 2ea:	4505                	li	a0,1
 2ec:	00000097          	auipc	ra,0x0
 2f0:	28e080e7          	jalr	654(ra) # 57a <exit>
 2f4:	87ae                	mv	a5,a1
    } 
    find(argv[1], argv[2]);
 2f6:	698c                	ld	a1,16(a1)
 2f8:	6788                	ld	a0,8(a5)
 2fa:	00000097          	auipc	ra,0x0
 2fe:	de6080e7          	jalr	-538(ra) # e0 <find>
    exit(0);
 302:	4501                	li	a0,0
 304:	00000097          	auipc	ra,0x0
 308:	276080e7          	jalr	630(ra) # 57a <exit>

000000000000030c <strcpy>:
 30c:	1141                	addi	sp,sp,-16
 30e:	e422                	sd	s0,8(sp)
 310:	0800                	addi	s0,sp,16
 312:	87aa                	mv	a5,a0
 314:	0585                	addi	a1,a1,1
 316:	0785                	addi	a5,a5,1
 318:	fff5c703          	lbu	a4,-1(a1)
 31c:	fee78fa3          	sb	a4,-1(a5)
 320:	fb75                	bnez	a4,314 <strcpy+0x8>
 322:	6422                	ld	s0,8(sp)
 324:	0141                	addi	sp,sp,16
 326:	8082                	ret

0000000000000328 <strcmp>:
 328:	1141                	addi	sp,sp,-16
 32a:	e422                	sd	s0,8(sp)
 32c:	0800                	addi	s0,sp,16
 32e:	00054783          	lbu	a5,0(a0)
 332:	cb91                	beqz	a5,346 <strcmp+0x1e>
 334:	0005c703          	lbu	a4,0(a1)
 338:	00f71763          	bne	a4,a5,346 <strcmp+0x1e>
 33c:	0505                	addi	a0,a0,1
 33e:	0585                	addi	a1,a1,1
 340:	00054783          	lbu	a5,0(a0)
 344:	fbe5                	bnez	a5,334 <strcmp+0xc>
 346:	0005c503          	lbu	a0,0(a1)
 34a:	40a7853b          	subw	a0,a5,a0
 34e:	6422                	ld	s0,8(sp)
 350:	0141                	addi	sp,sp,16
 352:	8082                	ret

0000000000000354 <strlen>:
 354:	1141                	addi	sp,sp,-16
 356:	e422                	sd	s0,8(sp)
 358:	0800                	addi	s0,sp,16
 35a:	00054783          	lbu	a5,0(a0)
 35e:	cf91                	beqz	a5,37a <strlen+0x26>
 360:	0505                	addi	a0,a0,1
 362:	87aa                	mv	a5,a0
 364:	4685                	li	a3,1
 366:	9e89                	subw	a3,a3,a0
 368:	00f6853b          	addw	a0,a3,a5
 36c:	0785                	addi	a5,a5,1
 36e:	fff7c703          	lbu	a4,-1(a5)
 372:	fb7d                	bnez	a4,368 <strlen+0x14>
 374:	6422                	ld	s0,8(sp)
 376:	0141                	addi	sp,sp,16
 378:	8082                	ret
 37a:	4501                	li	a0,0
 37c:	bfe5                	j	374 <strlen+0x20>

000000000000037e <memset>:
 37e:	1141                	addi	sp,sp,-16
 380:	e422                	sd	s0,8(sp)
 382:	0800                	addi	s0,sp,16
 384:	ca19                	beqz	a2,39a <memset+0x1c>
 386:	87aa                	mv	a5,a0
 388:	1602                	slli	a2,a2,0x20
 38a:	9201                	srli	a2,a2,0x20
 38c:	00a60733          	add	a4,a2,a0
 390:	00b78023          	sb	a1,0(a5)
 394:	0785                	addi	a5,a5,1
 396:	fee79de3          	bne	a5,a4,390 <memset+0x12>
 39a:	6422                	ld	s0,8(sp)
 39c:	0141                	addi	sp,sp,16
 39e:	8082                	ret

00000000000003a0 <strchr>:
 3a0:	1141                	addi	sp,sp,-16
 3a2:	e422                	sd	s0,8(sp)
 3a4:	0800                	addi	s0,sp,16
 3a6:	00054783          	lbu	a5,0(a0)
 3aa:	cb99                	beqz	a5,3c0 <strchr+0x20>
 3ac:	00f58763          	beq	a1,a5,3ba <strchr+0x1a>
 3b0:	0505                	addi	a0,a0,1
 3b2:	00054783          	lbu	a5,0(a0)
 3b6:	fbfd                	bnez	a5,3ac <strchr+0xc>
 3b8:	4501                	li	a0,0
 3ba:	6422                	ld	s0,8(sp)
 3bc:	0141                	addi	sp,sp,16
 3be:	8082                	ret
 3c0:	4501                	li	a0,0
 3c2:	bfe5                	j	3ba <strchr+0x1a>

00000000000003c4 <gets>:
 3c4:	711d                	addi	sp,sp,-96
 3c6:	ec86                	sd	ra,88(sp)
 3c8:	e8a2                	sd	s0,80(sp)
 3ca:	e4a6                	sd	s1,72(sp)
 3cc:	e0ca                	sd	s2,64(sp)
 3ce:	fc4e                	sd	s3,56(sp)
 3d0:	f852                	sd	s4,48(sp)
 3d2:	f456                	sd	s5,40(sp)
 3d4:	f05a                	sd	s6,32(sp)
 3d6:	ec5e                	sd	s7,24(sp)
 3d8:	1080                	addi	s0,sp,96
 3da:	8baa                	mv	s7,a0
 3dc:	8a2e                	mv	s4,a1
 3de:	892a                	mv	s2,a0
 3e0:	4481                	li	s1,0
 3e2:	4aa9                	li	s5,10
 3e4:	4b35                	li	s6,13
 3e6:	89a6                	mv	s3,s1
 3e8:	2485                	addiw	s1,s1,1
 3ea:	0344d863          	bge	s1,s4,41a <gets+0x56>
 3ee:	4605                	li	a2,1
 3f0:	faf40593          	addi	a1,s0,-81
 3f4:	4501                	li	a0,0
 3f6:	00000097          	auipc	ra,0x0
 3fa:	19c080e7          	jalr	412(ra) # 592 <read>
 3fe:	00a05e63          	blez	a0,41a <gets+0x56>
 402:	faf44783          	lbu	a5,-81(s0)
 406:	00f90023          	sb	a5,0(s2)
 40a:	01578763          	beq	a5,s5,418 <gets+0x54>
 40e:	0905                	addi	s2,s2,1
 410:	fd679be3          	bne	a5,s6,3e6 <gets+0x22>
 414:	89a6                	mv	s3,s1
 416:	a011                	j	41a <gets+0x56>
 418:	89a6                	mv	s3,s1
 41a:	99de                	add	s3,s3,s7
 41c:	00098023          	sb	zero,0(s3)
 420:	855e                	mv	a0,s7
 422:	60e6                	ld	ra,88(sp)
 424:	6446                	ld	s0,80(sp)
 426:	64a6                	ld	s1,72(sp)
 428:	6906                	ld	s2,64(sp)
 42a:	79e2                	ld	s3,56(sp)
 42c:	7a42                	ld	s4,48(sp)
 42e:	7aa2                	ld	s5,40(sp)
 430:	7b02                	ld	s6,32(sp)
 432:	6be2                	ld	s7,24(sp)
 434:	6125                	addi	sp,sp,96
 436:	8082                	ret

0000000000000438 <stat>:
 438:	1101                	addi	sp,sp,-32
 43a:	ec06                	sd	ra,24(sp)
 43c:	e822                	sd	s0,16(sp)
 43e:	e426                	sd	s1,8(sp)
 440:	e04a                	sd	s2,0(sp)
 442:	1000                	addi	s0,sp,32
 444:	892e                	mv	s2,a1
 446:	4581                	li	a1,0
 448:	00000097          	auipc	ra,0x0
 44c:	172080e7          	jalr	370(ra) # 5ba <open>
 450:	02054563          	bltz	a0,47a <stat+0x42>
 454:	84aa                	mv	s1,a0
 456:	85ca                	mv	a1,s2
 458:	00000097          	auipc	ra,0x0
 45c:	17a080e7          	jalr	378(ra) # 5d2 <fstat>
 460:	892a                	mv	s2,a0
 462:	8526                	mv	a0,s1
 464:	00000097          	auipc	ra,0x0
 468:	13e080e7          	jalr	318(ra) # 5a2 <close>
 46c:	854a                	mv	a0,s2
 46e:	60e2                	ld	ra,24(sp)
 470:	6442                	ld	s0,16(sp)
 472:	64a2                	ld	s1,8(sp)
 474:	6902                	ld	s2,0(sp)
 476:	6105                	addi	sp,sp,32
 478:	8082                	ret
 47a:	597d                	li	s2,-1
 47c:	bfc5                	j	46c <stat+0x34>

000000000000047e <atoi>:
 47e:	1141                	addi	sp,sp,-16
 480:	e422                	sd	s0,8(sp)
 482:	0800                	addi	s0,sp,16
 484:	00054603          	lbu	a2,0(a0)
 488:	fd06079b          	addiw	a5,a2,-48
 48c:	0ff7f793          	andi	a5,a5,255
 490:	4725                	li	a4,9
 492:	02f76963          	bltu	a4,a5,4c4 <atoi+0x46>
 496:	86aa                	mv	a3,a0
 498:	4501                	li	a0,0
 49a:	45a5                	li	a1,9
 49c:	0685                	addi	a3,a3,1
 49e:	0025179b          	slliw	a5,a0,0x2
 4a2:	9fa9                	addw	a5,a5,a0
 4a4:	0017979b          	slliw	a5,a5,0x1
 4a8:	9fb1                	addw	a5,a5,a2
 4aa:	fd07851b          	addiw	a0,a5,-48
 4ae:	0006c603          	lbu	a2,0(a3)
 4b2:	fd06071b          	addiw	a4,a2,-48
 4b6:	0ff77713          	andi	a4,a4,255
 4ba:	fee5f1e3          	bgeu	a1,a4,49c <atoi+0x1e>
 4be:	6422                	ld	s0,8(sp)
 4c0:	0141                	addi	sp,sp,16
 4c2:	8082                	ret
 4c4:	4501                	li	a0,0
 4c6:	bfe5                	j	4be <atoi+0x40>

00000000000004c8 <memmove>:
 4c8:	1141                	addi	sp,sp,-16
 4ca:	e422                	sd	s0,8(sp)
 4cc:	0800                	addi	s0,sp,16
 4ce:	02b57463          	bgeu	a0,a1,4f6 <memmove+0x2e>
 4d2:	00c05f63          	blez	a2,4f0 <memmove+0x28>
 4d6:	1602                	slli	a2,a2,0x20
 4d8:	9201                	srli	a2,a2,0x20
 4da:	00c507b3          	add	a5,a0,a2
 4de:	872a                	mv	a4,a0
 4e0:	0585                	addi	a1,a1,1
 4e2:	0705                	addi	a4,a4,1
 4e4:	fff5c683          	lbu	a3,-1(a1)
 4e8:	fed70fa3          	sb	a3,-1(a4)
 4ec:	fee79ae3          	bne	a5,a4,4e0 <memmove+0x18>
 4f0:	6422                	ld	s0,8(sp)
 4f2:	0141                	addi	sp,sp,16
 4f4:	8082                	ret
 4f6:	00c50733          	add	a4,a0,a2
 4fa:	95b2                	add	a1,a1,a2
 4fc:	fec05ae3          	blez	a2,4f0 <memmove+0x28>
 500:	fff6079b          	addiw	a5,a2,-1
 504:	1782                	slli	a5,a5,0x20
 506:	9381                	srli	a5,a5,0x20
 508:	fff7c793          	not	a5,a5
 50c:	97ba                	add	a5,a5,a4
 50e:	15fd                	addi	a1,a1,-1
 510:	177d                	addi	a4,a4,-1
 512:	0005c683          	lbu	a3,0(a1)
 516:	00d70023          	sb	a3,0(a4)
 51a:	fee79ae3          	bne	a5,a4,50e <memmove+0x46>
 51e:	bfc9                	j	4f0 <memmove+0x28>

0000000000000520 <memcmp>:
 520:	1141                	addi	sp,sp,-16
 522:	e422                	sd	s0,8(sp)
 524:	0800                	addi	s0,sp,16
 526:	ca05                	beqz	a2,556 <memcmp+0x36>
 528:	fff6069b          	addiw	a3,a2,-1
 52c:	1682                	slli	a3,a3,0x20
 52e:	9281                	srli	a3,a3,0x20
 530:	0685                	addi	a3,a3,1
 532:	96aa                	add	a3,a3,a0
 534:	00054783          	lbu	a5,0(a0)
 538:	0005c703          	lbu	a4,0(a1)
 53c:	00e79863          	bne	a5,a4,54c <memcmp+0x2c>
 540:	0505                	addi	a0,a0,1
 542:	0585                	addi	a1,a1,1
 544:	fed518e3          	bne	a0,a3,534 <memcmp+0x14>
 548:	4501                	li	a0,0
 54a:	a019                	j	550 <memcmp+0x30>
 54c:	40e7853b          	subw	a0,a5,a4
 550:	6422                	ld	s0,8(sp)
 552:	0141                	addi	sp,sp,16
 554:	8082                	ret
 556:	4501                	li	a0,0
 558:	bfe5                	j	550 <memcmp+0x30>

000000000000055a <memcpy>:
 55a:	1141                	addi	sp,sp,-16
 55c:	e406                	sd	ra,8(sp)
 55e:	e022                	sd	s0,0(sp)
 560:	0800                	addi	s0,sp,16
 562:	00000097          	auipc	ra,0x0
 566:	f66080e7          	jalr	-154(ra) # 4c8 <memmove>
 56a:	60a2                	ld	ra,8(sp)
 56c:	6402                	ld	s0,0(sp)
 56e:	0141                	addi	sp,sp,16
 570:	8082                	ret

0000000000000572 <fork>:
 572:	4885                	li	a7,1
 574:	00000073          	ecall
 578:	8082                	ret

000000000000057a <exit>:
 57a:	4889                	li	a7,2
 57c:	00000073          	ecall
 580:	8082                	ret

0000000000000582 <wait>:
 582:	488d                	li	a7,3
 584:	00000073          	ecall
 588:	8082                	ret

000000000000058a <pipe>:
 58a:	4891                	li	a7,4
 58c:	00000073          	ecall
 590:	8082                	ret

0000000000000592 <read>:
 592:	4895                	li	a7,5
 594:	00000073          	ecall
 598:	8082                	ret

000000000000059a <write>:
 59a:	48c1                	li	a7,16
 59c:	00000073          	ecall
 5a0:	8082                	ret

00000000000005a2 <close>:
 5a2:	48d5                	li	a7,21
 5a4:	00000073          	ecall
 5a8:	8082                	ret

00000000000005aa <kill>:
 5aa:	4899                	li	a7,6
 5ac:	00000073          	ecall
 5b0:	8082                	ret

00000000000005b2 <exec>:
 5b2:	489d                	li	a7,7
 5b4:	00000073          	ecall
 5b8:	8082                	ret

00000000000005ba <open>:
 5ba:	48bd                	li	a7,15
 5bc:	00000073          	ecall
 5c0:	8082                	ret

00000000000005c2 <mknod>:
 5c2:	48c5                	li	a7,17
 5c4:	00000073          	ecall
 5c8:	8082                	ret

00000000000005ca <unlink>:
 5ca:	48c9                	li	a7,18
 5cc:	00000073          	ecall
 5d0:	8082                	ret

00000000000005d2 <fstat>:
 5d2:	48a1                	li	a7,8
 5d4:	00000073          	ecall
 5d8:	8082                	ret

00000000000005da <link>:
 5da:	48cd                	li	a7,19
 5dc:	00000073          	ecall
 5e0:	8082                	ret

00000000000005e2 <mkdir>:
 5e2:	48d1                	li	a7,20
 5e4:	00000073          	ecall
 5e8:	8082                	ret

00000000000005ea <chdir>:
 5ea:	48a5                	li	a7,9
 5ec:	00000073          	ecall
 5f0:	8082                	ret

00000000000005f2 <dup>:
 5f2:	48a9                	li	a7,10
 5f4:	00000073          	ecall
 5f8:	8082                	ret

00000000000005fa <getpid>:
 5fa:	48ad                	li	a7,11
 5fc:	00000073          	ecall
 600:	8082                	ret

0000000000000602 <sbrk>:
 602:	48b1                	li	a7,12
 604:	00000073          	ecall
 608:	8082                	ret

000000000000060a <sleep>:
 60a:	48b5                	li	a7,13
 60c:	00000073          	ecall
 610:	8082                	ret

0000000000000612 <uptime>:
 612:	48b9                	li	a7,14
 614:	00000073          	ecall
 618:	8082                	ret

000000000000061a <putc>:
 61a:	1101                	addi	sp,sp,-32
 61c:	ec06                	sd	ra,24(sp)
 61e:	e822                	sd	s0,16(sp)
 620:	1000                	addi	s0,sp,32
 622:	feb407a3          	sb	a1,-17(s0)
 626:	4605                	li	a2,1
 628:	fef40593          	addi	a1,s0,-17
 62c:	00000097          	auipc	ra,0x0
 630:	f6e080e7          	jalr	-146(ra) # 59a <write>
 634:	60e2                	ld	ra,24(sp)
 636:	6442                	ld	s0,16(sp)
 638:	6105                	addi	sp,sp,32
 63a:	8082                	ret

000000000000063c <printint>:
 63c:	7139                	addi	sp,sp,-64
 63e:	fc06                	sd	ra,56(sp)
 640:	f822                	sd	s0,48(sp)
 642:	f426                	sd	s1,40(sp)
 644:	f04a                	sd	s2,32(sp)
 646:	ec4e                	sd	s3,24(sp)
 648:	0080                	addi	s0,sp,64
 64a:	84aa                	mv	s1,a0
 64c:	c299                	beqz	a3,652 <printint+0x16>
 64e:	0805c863          	bltz	a1,6de <printint+0xa2>
 652:	2581                	sext.w	a1,a1
 654:	4881                	li	a7,0
 656:	fc040693          	addi	a3,s0,-64
 65a:	4701                	li	a4,0
 65c:	2601                	sext.w	a2,a2
 65e:	00000517          	auipc	a0,0x0
 662:	52a50513          	addi	a0,a0,1322 # b88 <digits>
 666:	883a                	mv	a6,a4
 668:	2705                	addiw	a4,a4,1
 66a:	02c5f7bb          	remuw	a5,a1,a2
 66e:	1782                	slli	a5,a5,0x20
 670:	9381                	srli	a5,a5,0x20
 672:	97aa                	add	a5,a5,a0
 674:	0007c783          	lbu	a5,0(a5)
 678:	00f68023          	sb	a5,0(a3)
 67c:	0005879b          	sext.w	a5,a1
 680:	02c5d5bb          	divuw	a1,a1,a2
 684:	0685                	addi	a3,a3,1
 686:	fec7f0e3          	bgeu	a5,a2,666 <printint+0x2a>
 68a:	00088b63          	beqz	a7,6a0 <printint+0x64>
 68e:	fd040793          	addi	a5,s0,-48
 692:	973e                	add	a4,a4,a5
 694:	02d00793          	li	a5,45
 698:	fef70823          	sb	a5,-16(a4)
 69c:	0028071b          	addiw	a4,a6,2
 6a0:	02e05863          	blez	a4,6d0 <printint+0x94>
 6a4:	fc040793          	addi	a5,s0,-64
 6a8:	00e78933          	add	s2,a5,a4
 6ac:	fff78993          	addi	s3,a5,-1
 6b0:	99ba                	add	s3,s3,a4
 6b2:	377d                	addiw	a4,a4,-1
 6b4:	1702                	slli	a4,a4,0x20
 6b6:	9301                	srli	a4,a4,0x20
 6b8:	40e989b3          	sub	s3,s3,a4
 6bc:	fff94583          	lbu	a1,-1(s2)
 6c0:	8526                	mv	a0,s1
 6c2:	00000097          	auipc	ra,0x0
 6c6:	f58080e7          	jalr	-168(ra) # 61a <putc>
 6ca:	197d                	addi	s2,s2,-1
 6cc:	ff3918e3          	bne	s2,s3,6bc <printint+0x80>
 6d0:	70e2                	ld	ra,56(sp)
 6d2:	7442                	ld	s0,48(sp)
 6d4:	74a2                	ld	s1,40(sp)
 6d6:	7902                	ld	s2,32(sp)
 6d8:	69e2                	ld	s3,24(sp)
 6da:	6121                	addi	sp,sp,64
 6dc:	8082                	ret
 6de:	40b005bb          	negw	a1,a1
 6e2:	4885                	li	a7,1
 6e4:	bf8d                	j	656 <printint+0x1a>

00000000000006e6 <vprintf>:
 6e6:	7119                	addi	sp,sp,-128
 6e8:	fc86                	sd	ra,120(sp)
 6ea:	f8a2                	sd	s0,112(sp)
 6ec:	f4a6                	sd	s1,104(sp)
 6ee:	f0ca                	sd	s2,96(sp)
 6f0:	ecce                	sd	s3,88(sp)
 6f2:	e8d2                	sd	s4,80(sp)
 6f4:	e4d6                	sd	s5,72(sp)
 6f6:	e0da                	sd	s6,64(sp)
 6f8:	fc5e                	sd	s7,56(sp)
 6fa:	f862                	sd	s8,48(sp)
 6fc:	f466                	sd	s9,40(sp)
 6fe:	f06a                	sd	s10,32(sp)
 700:	ec6e                	sd	s11,24(sp)
 702:	0100                	addi	s0,sp,128
 704:	0005c903          	lbu	s2,0(a1)
 708:	18090f63          	beqz	s2,8a6 <vprintf+0x1c0>
 70c:	8aaa                	mv	s5,a0
 70e:	8b32                	mv	s6,a2
 710:	00158493          	addi	s1,a1,1
 714:	4981                	li	s3,0
 716:	02500a13          	li	s4,37
 71a:	06400c13          	li	s8,100
 71e:	06c00c93          	li	s9,108
 722:	07800d13          	li	s10,120
 726:	07000d93          	li	s11,112
 72a:	00000b97          	auipc	s7,0x0
 72e:	45eb8b93          	addi	s7,s7,1118 # b88 <digits>
 732:	a839                	j	750 <vprintf+0x6a>
 734:	85ca                	mv	a1,s2
 736:	8556                	mv	a0,s5
 738:	00000097          	auipc	ra,0x0
 73c:	ee2080e7          	jalr	-286(ra) # 61a <putc>
 740:	a019                	j	746 <vprintf+0x60>
 742:	01498f63          	beq	s3,s4,760 <vprintf+0x7a>
 746:	0485                	addi	s1,s1,1
 748:	fff4c903          	lbu	s2,-1(s1)
 74c:	14090d63          	beqz	s2,8a6 <vprintf+0x1c0>
 750:	0009079b          	sext.w	a5,s2
 754:	fe0997e3          	bnez	s3,742 <vprintf+0x5c>
 758:	fd479ee3          	bne	a5,s4,734 <vprintf+0x4e>
 75c:	89be                	mv	s3,a5
 75e:	b7e5                	j	746 <vprintf+0x60>
 760:	05878063          	beq	a5,s8,7a0 <vprintf+0xba>
 764:	05978c63          	beq	a5,s9,7bc <vprintf+0xd6>
 768:	07a78863          	beq	a5,s10,7d8 <vprintf+0xf2>
 76c:	09b78463          	beq	a5,s11,7f4 <vprintf+0x10e>
 770:	07300713          	li	a4,115
 774:	0ce78663          	beq	a5,a4,840 <vprintf+0x15a>
 778:	06300713          	li	a4,99
 77c:	0ee78e63          	beq	a5,a4,878 <vprintf+0x192>
 780:	11478863          	beq	a5,s4,890 <vprintf+0x1aa>
 784:	85d2                	mv	a1,s4
 786:	8556                	mv	a0,s5
 788:	00000097          	auipc	ra,0x0
 78c:	e92080e7          	jalr	-366(ra) # 61a <putc>
 790:	85ca                	mv	a1,s2
 792:	8556                	mv	a0,s5
 794:	00000097          	auipc	ra,0x0
 798:	e86080e7          	jalr	-378(ra) # 61a <putc>
 79c:	4981                	li	s3,0
 79e:	b765                	j	746 <vprintf+0x60>
 7a0:	008b0913          	addi	s2,s6,8
 7a4:	4685                	li	a3,1
 7a6:	4629                	li	a2,10
 7a8:	000b2583          	lw	a1,0(s6)
 7ac:	8556                	mv	a0,s5
 7ae:	00000097          	auipc	ra,0x0
 7b2:	e8e080e7          	jalr	-370(ra) # 63c <printint>
 7b6:	8b4a                	mv	s6,s2
 7b8:	4981                	li	s3,0
 7ba:	b771                	j	746 <vprintf+0x60>
 7bc:	008b0913          	addi	s2,s6,8
 7c0:	4681                	li	a3,0
 7c2:	4629                	li	a2,10
 7c4:	000b2583          	lw	a1,0(s6)
 7c8:	8556                	mv	a0,s5
 7ca:	00000097          	auipc	ra,0x0
 7ce:	e72080e7          	jalr	-398(ra) # 63c <printint>
 7d2:	8b4a                	mv	s6,s2
 7d4:	4981                	li	s3,0
 7d6:	bf85                	j	746 <vprintf+0x60>
 7d8:	008b0913          	addi	s2,s6,8
 7dc:	4681                	li	a3,0
 7de:	4641                	li	a2,16
 7e0:	000b2583          	lw	a1,0(s6)
 7e4:	8556                	mv	a0,s5
 7e6:	00000097          	auipc	ra,0x0
 7ea:	e56080e7          	jalr	-426(ra) # 63c <printint>
 7ee:	8b4a                	mv	s6,s2
 7f0:	4981                	li	s3,0
 7f2:	bf91                	j	746 <vprintf+0x60>
 7f4:	008b0793          	addi	a5,s6,8
 7f8:	f8f43423          	sd	a5,-120(s0)
 7fc:	000b3983          	ld	s3,0(s6)
 800:	03000593          	li	a1,48
 804:	8556                	mv	a0,s5
 806:	00000097          	auipc	ra,0x0
 80a:	e14080e7          	jalr	-492(ra) # 61a <putc>
 80e:	85ea                	mv	a1,s10
 810:	8556                	mv	a0,s5
 812:	00000097          	auipc	ra,0x0
 816:	e08080e7          	jalr	-504(ra) # 61a <putc>
 81a:	4941                	li	s2,16
 81c:	03c9d793          	srli	a5,s3,0x3c
 820:	97de                	add	a5,a5,s7
 822:	0007c583          	lbu	a1,0(a5)
 826:	8556                	mv	a0,s5
 828:	00000097          	auipc	ra,0x0
 82c:	df2080e7          	jalr	-526(ra) # 61a <putc>
 830:	0992                	slli	s3,s3,0x4
 832:	397d                	addiw	s2,s2,-1
 834:	fe0914e3          	bnez	s2,81c <vprintf+0x136>
 838:	f8843b03          	ld	s6,-120(s0)
 83c:	4981                	li	s3,0
 83e:	b721                	j	746 <vprintf+0x60>
 840:	008b0993          	addi	s3,s6,8
 844:	000b3903          	ld	s2,0(s6)
 848:	02090163          	beqz	s2,86a <vprintf+0x184>
 84c:	00094583          	lbu	a1,0(s2)
 850:	c9a1                	beqz	a1,8a0 <vprintf+0x1ba>
 852:	8556                	mv	a0,s5
 854:	00000097          	auipc	ra,0x0
 858:	dc6080e7          	jalr	-570(ra) # 61a <putc>
 85c:	0905                	addi	s2,s2,1
 85e:	00094583          	lbu	a1,0(s2)
 862:	f9e5                	bnez	a1,852 <vprintf+0x16c>
 864:	8b4e                	mv	s6,s3
 866:	4981                	li	s3,0
 868:	bdf9                	j	746 <vprintf+0x60>
 86a:	00000917          	auipc	s2,0x0
 86e:	31690913          	addi	s2,s2,790 # b80 <malloc+0x1d0>
 872:	02800593          	li	a1,40
 876:	bff1                	j	852 <vprintf+0x16c>
 878:	008b0913          	addi	s2,s6,8
 87c:	000b4583          	lbu	a1,0(s6)
 880:	8556                	mv	a0,s5
 882:	00000097          	auipc	ra,0x0
 886:	d98080e7          	jalr	-616(ra) # 61a <putc>
 88a:	8b4a                	mv	s6,s2
 88c:	4981                	li	s3,0
 88e:	bd65                	j	746 <vprintf+0x60>
 890:	85d2                	mv	a1,s4
 892:	8556                	mv	a0,s5
 894:	00000097          	auipc	ra,0x0
 898:	d86080e7          	jalr	-634(ra) # 61a <putc>
 89c:	4981                	li	s3,0
 89e:	b565                	j	746 <vprintf+0x60>
 8a0:	8b4e                	mv	s6,s3
 8a2:	4981                	li	s3,0
 8a4:	b54d                	j	746 <vprintf+0x60>
 8a6:	70e6                	ld	ra,120(sp)
 8a8:	7446                	ld	s0,112(sp)
 8aa:	74a6                	ld	s1,104(sp)
 8ac:	7906                	ld	s2,96(sp)
 8ae:	69e6                	ld	s3,88(sp)
 8b0:	6a46                	ld	s4,80(sp)
 8b2:	6aa6                	ld	s5,72(sp)
 8b4:	6b06                	ld	s6,64(sp)
 8b6:	7be2                	ld	s7,56(sp)
 8b8:	7c42                	ld	s8,48(sp)
 8ba:	7ca2                	ld	s9,40(sp)
 8bc:	7d02                	ld	s10,32(sp)
 8be:	6de2                	ld	s11,24(sp)
 8c0:	6109                	addi	sp,sp,128
 8c2:	8082                	ret

00000000000008c4 <fprintf>:
 8c4:	715d                	addi	sp,sp,-80
 8c6:	ec06                	sd	ra,24(sp)
 8c8:	e822                	sd	s0,16(sp)
 8ca:	1000                	addi	s0,sp,32
 8cc:	e010                	sd	a2,0(s0)
 8ce:	e414                	sd	a3,8(s0)
 8d0:	e818                	sd	a4,16(s0)
 8d2:	ec1c                	sd	a5,24(s0)
 8d4:	03043023          	sd	a6,32(s0)
 8d8:	03143423          	sd	a7,40(s0)
 8dc:	fe843423          	sd	s0,-24(s0)
 8e0:	8622                	mv	a2,s0
 8e2:	00000097          	auipc	ra,0x0
 8e6:	e04080e7          	jalr	-508(ra) # 6e6 <vprintf>
 8ea:	60e2                	ld	ra,24(sp)
 8ec:	6442                	ld	s0,16(sp)
 8ee:	6161                	addi	sp,sp,80
 8f0:	8082                	ret

00000000000008f2 <printf>:
 8f2:	711d                	addi	sp,sp,-96
 8f4:	ec06                	sd	ra,24(sp)
 8f6:	e822                	sd	s0,16(sp)
 8f8:	1000                	addi	s0,sp,32
 8fa:	e40c                	sd	a1,8(s0)
 8fc:	e810                	sd	a2,16(s0)
 8fe:	ec14                	sd	a3,24(s0)
 900:	f018                	sd	a4,32(s0)
 902:	f41c                	sd	a5,40(s0)
 904:	03043823          	sd	a6,48(s0)
 908:	03143c23          	sd	a7,56(s0)
 90c:	00840613          	addi	a2,s0,8
 910:	fec43423          	sd	a2,-24(s0)
 914:	85aa                	mv	a1,a0
 916:	4505                	li	a0,1
 918:	00000097          	auipc	ra,0x0
 91c:	dce080e7          	jalr	-562(ra) # 6e6 <vprintf>
 920:	60e2                	ld	ra,24(sp)
 922:	6442                	ld	s0,16(sp)
 924:	6125                	addi	sp,sp,96
 926:	8082                	ret

0000000000000928 <free>:
 928:	1141                	addi	sp,sp,-16
 92a:	e422                	sd	s0,8(sp)
 92c:	0800                	addi	s0,sp,16
 92e:	ff050693          	addi	a3,a0,-16
 932:	00000797          	auipc	a5,0x0
 936:	26e7b783          	ld	a5,622(a5) # ba0 <freep>
 93a:	a805                	j	96a <free+0x42>
 93c:	4618                	lw	a4,8(a2)
 93e:	9db9                	addw	a1,a1,a4
 940:	feb52c23          	sw	a1,-8(a0)
 944:	6398                	ld	a4,0(a5)
 946:	6318                	ld	a4,0(a4)
 948:	fee53823          	sd	a4,-16(a0)
 94c:	a091                	j	990 <free+0x68>
 94e:	ff852703          	lw	a4,-8(a0)
 952:	9e39                	addw	a2,a2,a4
 954:	c790                	sw	a2,8(a5)
 956:	ff053703          	ld	a4,-16(a0)
 95a:	e398                	sd	a4,0(a5)
 95c:	a099                	j	9a2 <free+0x7a>
 95e:	6398                	ld	a4,0(a5)
 960:	00e7e463          	bltu	a5,a4,968 <free+0x40>
 964:	00e6ea63          	bltu	a3,a4,978 <free+0x50>
 968:	87ba                	mv	a5,a4
 96a:	fed7fae3          	bgeu	a5,a3,95e <free+0x36>
 96e:	6398                	ld	a4,0(a5)
 970:	00e6e463          	bltu	a3,a4,978 <free+0x50>
 974:	fee7eae3          	bltu	a5,a4,968 <free+0x40>
 978:	ff852583          	lw	a1,-8(a0)
 97c:	6390                	ld	a2,0(a5)
 97e:	02059813          	slli	a6,a1,0x20
 982:	01c85713          	srli	a4,a6,0x1c
 986:	9736                	add	a4,a4,a3
 988:	fae60ae3          	beq	a2,a4,93c <free+0x14>
 98c:	fec53823          	sd	a2,-16(a0)
 990:	4790                	lw	a2,8(a5)
 992:	02061593          	slli	a1,a2,0x20
 996:	01c5d713          	srli	a4,a1,0x1c
 99a:	973e                	add	a4,a4,a5
 99c:	fae689e3          	beq	a3,a4,94e <free+0x26>
 9a0:	e394                	sd	a3,0(a5)
 9a2:	00000717          	auipc	a4,0x0
 9a6:	1ef73f23          	sd	a5,510(a4) # ba0 <freep>
 9aa:	6422                	ld	s0,8(sp)
 9ac:	0141                	addi	sp,sp,16
 9ae:	8082                	ret

00000000000009b0 <malloc>:
 9b0:	7139                	addi	sp,sp,-64
 9b2:	fc06                	sd	ra,56(sp)
 9b4:	f822                	sd	s0,48(sp)
 9b6:	f426                	sd	s1,40(sp)
 9b8:	f04a                	sd	s2,32(sp)
 9ba:	ec4e                	sd	s3,24(sp)
 9bc:	e852                	sd	s4,16(sp)
 9be:	e456                	sd	s5,8(sp)
 9c0:	e05a                	sd	s6,0(sp)
 9c2:	0080                	addi	s0,sp,64
 9c4:	02051493          	slli	s1,a0,0x20
 9c8:	9081                	srli	s1,s1,0x20
 9ca:	04bd                	addi	s1,s1,15
 9cc:	8091                	srli	s1,s1,0x4
 9ce:	0014899b          	addiw	s3,s1,1
 9d2:	0485                	addi	s1,s1,1
 9d4:	00000517          	auipc	a0,0x0
 9d8:	1cc53503          	ld	a0,460(a0) # ba0 <freep>
 9dc:	c515                	beqz	a0,a08 <malloc+0x58>
 9de:	611c                	ld	a5,0(a0)
 9e0:	4798                	lw	a4,8(a5)
 9e2:	02977f63          	bgeu	a4,s1,a20 <malloc+0x70>
 9e6:	8a4e                	mv	s4,s3
 9e8:	0009871b          	sext.w	a4,s3
 9ec:	6685                	lui	a3,0x1
 9ee:	00d77363          	bgeu	a4,a3,9f4 <malloc+0x44>
 9f2:	6a05                	lui	s4,0x1
 9f4:	000a0b1b          	sext.w	s6,s4
 9f8:	004a1a1b          	slliw	s4,s4,0x4
 9fc:	00000917          	auipc	s2,0x0
 a00:	1a490913          	addi	s2,s2,420 # ba0 <freep>
 a04:	5afd                	li	s5,-1
 a06:	a895                	j	a7a <malloc+0xca>
 a08:	00000797          	auipc	a5,0x0
 a0c:	1a078793          	addi	a5,a5,416 # ba8 <base>
 a10:	00000717          	auipc	a4,0x0
 a14:	18f73823          	sd	a5,400(a4) # ba0 <freep>
 a18:	e39c                	sd	a5,0(a5)
 a1a:	0007a423          	sw	zero,8(a5)
 a1e:	b7e1                	j	9e6 <malloc+0x36>
 a20:	02e48c63          	beq	s1,a4,a58 <malloc+0xa8>
 a24:	4137073b          	subw	a4,a4,s3
 a28:	c798                	sw	a4,8(a5)
 a2a:	02071693          	slli	a3,a4,0x20
 a2e:	01c6d713          	srli	a4,a3,0x1c
 a32:	97ba                	add	a5,a5,a4
 a34:	0137a423          	sw	s3,8(a5)
 a38:	00000717          	auipc	a4,0x0
 a3c:	16a73423          	sd	a0,360(a4) # ba0 <freep>
 a40:	01078513          	addi	a0,a5,16
 a44:	70e2                	ld	ra,56(sp)
 a46:	7442                	ld	s0,48(sp)
 a48:	74a2                	ld	s1,40(sp)
 a4a:	7902                	ld	s2,32(sp)
 a4c:	69e2                	ld	s3,24(sp)
 a4e:	6a42                	ld	s4,16(sp)
 a50:	6aa2                	ld	s5,8(sp)
 a52:	6b02                	ld	s6,0(sp)
 a54:	6121                	addi	sp,sp,64
 a56:	8082                	ret
 a58:	6398                	ld	a4,0(a5)
 a5a:	e118                	sd	a4,0(a0)
 a5c:	bff1                	j	a38 <malloc+0x88>
 a5e:	01652423          	sw	s6,8(a0)
 a62:	0541                	addi	a0,a0,16
 a64:	00000097          	auipc	ra,0x0
 a68:	ec4080e7          	jalr	-316(ra) # 928 <free>
 a6c:	00093503          	ld	a0,0(s2)
 a70:	d971                	beqz	a0,a44 <malloc+0x94>
 a72:	611c                	ld	a5,0(a0)
 a74:	4798                	lw	a4,8(a5)
 a76:	fa9775e3          	bgeu	a4,s1,a20 <malloc+0x70>
 a7a:	00093703          	ld	a4,0(s2)
 a7e:	853e                	mv	a0,a5
 a80:	fef719e3          	bne	a4,a5,a72 <malloc+0xc2>
 a84:	8552                	mv	a0,s4
 a86:	00000097          	auipc	ra,0x0
 a8a:	b7c080e7          	jalr	-1156(ra) # 602 <sbrk>
 a8e:	fd5518e3          	bne	a0,s5,a5e <malloc+0xae>
 a92:	4501                	li	a0,0
 a94:	bf45                	j	a44 <malloc+0x94>
