#include "kernel/types.h"
#include "user/user.h"

#define STDIN 0

char* next_line(char* str) 
{
  char *p, *out;
  char *line;
  line = malloc(sizeof(char) * strlen(str));

  p = line;  /* initialize walking pointer to empty buffer with line */
  for(int i=0; i<strlen(str); i++)
  {
    if(str[i] == '\n')
    { 
      /* we stop when new line */
      break;
    }
    if(str[i] == '\\' && strlen(str) >= (i+1) && str[i+1] == 'n')  
      /* this is the same expr as above */
    {
      break;
    }
    /* associate str[i] with derreferencing p = p + 1 (which is line's next
     * memory slot which has sizeof char)
     */
    *p++ = str[i];
  }
  out = line;
  /* line pointer is persistant on different calls to next_line,
   * therefore, it must be offset */
  str = str + strlen(line) + sizeof(char);
  line = line + strlen(line);

  return out;
}

int
main(int argc, char *argv[])
{
  // 1 read from stdin and split on \n
  // 2 for each split, fork and call exec on its args
  // reminder:
  // argv[0] is program name (xargs)  
  // argv[1] is argument (that is also a program name)
  // argv[-1] is NULL
  char buff[512], *p;
  
  if(read(STDIN, &buff, sizeof(buff)) > 0)
  {
    p = buff;
    while(1)
    {
      char *line = next_line(p);
      /* TODO: There is a bug here: if its a user input, \n equals
       * two characters, therefore, pointer offsetting should be char*2
       * otherwise, if it's received from another program (say find)
       * \n is properly parsed and works as expected */
      //p = p + strlen(line) + (sizeof(char) * 2);
      p = p + strlen(line) + (sizeof(char));
      if(fork() == 0)
      {
        char *nargv[argc];

        /* copy xargs prog's arguments to new argv
         * NOTE: in order to exec run as expected,
         * argv[0] *must* also be program name */
        for(int i=1, j=0; i<argc; i++, j++)
        {
          nargv[j] = argv[i];
        }
        /* put line in the end of argv */
        nargv[argc-1] = line;
        /* properly write a NULL at the end of arr of strs */
        nargv[argc] = argv[argc];

        exec(argv[1], nargv);
        fprintf(2, "exec %s failed!", argv[1]);
        exit(0);
      }
      else {
        wait(0);
      }

      /* there are no more lines to read */
      if (*p == '\0') break;
    }
  }

  exit(0);

}
