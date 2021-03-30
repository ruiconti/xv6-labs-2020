#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  int p_paren[2], p_child[2];
  pipe(p_paren);  // fd 3(in), 4(out)
  pipe(p_child);  // fd 5(in), 6(out)

  if (fork() == 0)
  {
    // inside child
    char buff[5];
    char data[5] = "pong\n";

    if (read(p_child[0], buff, 5) > 0)
    {
      // something was read
      printf("%d: received %s", getpid(), buff);
      close(p_child[0]);
      write(p_paren[1], data, 5);
      close(p_child[1]);
    }
  }
  else
  {
    // inside paren
    char buff[5];
    char data[5] = "ping\n";
    write(p_child[1], data, 5);
    if (read(p_paren[0], buff, 5) > 0)
    {
      // something was read
      printf("%d: received %s\n", getpid(), buff);
      close(p_paren[0]);
      close(p_paren[1]);
    }
  }
  exit(0);
}






