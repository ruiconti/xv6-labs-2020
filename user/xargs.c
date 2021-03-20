#include "kernel/types.h"
#include "user/user.h"

#define STDIN 0

char* next_line(char* str) 
{
  char line[512], *p, *out;
  //int literal = 0;

  p = line;  /* initialize walking pointer to empty buffer with line */
  for(int i=0; i<strlen(str); i++)
  {
    if(str[i] == '\n')
    { 
      /* we stop when new line */
     // literal = 1;
      break;
    }
    if(str[i] == '\\' && strlen(str) >= (i+1) && str[i+1] == 'n')  
      /* this is the same expr as above */
    {
    //  literal = 2;
      break;
    }
    /* associate str[i] with derreferencing p = p + 1 (which is line's next
     * memory slot which has sizeof char)
     */
    *p++ = str[i];
  }
  /* update original string to start of next line  */
  //str = str + strlen(line) + (sizeof(char) * literal);
  out = line;
  printf("out:%s, %d\n", out, strlen(str));

  return out;
}

int
main(int argc, char *argv[])
{
  // 1 read from stdin and split on \n
  // 2 for each split, fork and call exec on its args
  //char buff[512];
  char buff[512], *p, *line;
  
  p = buff;
  if(read(STDIN, &buff, sizeof(buff)) > 0)
  {
    while(1)
    {
      line = next_line(p);
      p = p + strlen(line) + (sizeof(char) * 2);
      printf("%s, %d\n", line, strlen(line));
      if (*p == '\0') break;

    }
  }
  //if(read(STDIN, buff, sizeof(buff)) > 0)
  //  /* read everything from stdin */
  //{
  //  char *argl;
  //  char *nargv[argc];
  //  while(*buff != '\0')
  //  {
  //    argl = next_line(buff);
  //    if(fork() == 0)
  //    {
  //      // we must append argl in argv
  //      // argv[0]: program
  //      // argv[1] - argv[argc]: args
  //      int i;
  //      for(i=0; i<argc; i++)
  //      {
  //        if(i==argc-1)
  //        {
  //          nargv[i] = argl;
  //        }
  //        else
  //        {
  //          nargv[i] = argv[i]; 
  //        }
  //        printf("args:%s, -1: %s\n", nargv[i], argv[i]);
  //      }
  //      nargv[i] = argl;
  //      printf("buff:%s\n\n", buff);
  //      exec(argv[0], nargv);
  //      exit(0);
  //    }
  //    else {
  //      wait(0);
  //    }
  //  }
  //}

  exit(0);


  // must catch program and its args
  // program is in argv[0] and its subsquent arguments in argv[i..n]


}
