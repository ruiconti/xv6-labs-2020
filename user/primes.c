#include "kernel/types.h"
#include "user/user.h"

/* Definitions:
 * pipe: https://man7.org/linux/man-pages/man7/pipe.7.html
 * fork: https://man7.org/linux/man-pages/man2/fork.2.html
 * wait: https://man7.org/linux/man-pages/man2/wait.2.html */
/* Requirements:
 * 1. Generate prime sieve using pipes.
 * 2. Once the first process reaches 35, it should wait on all its children 
 * grandchildren, etc. */

#define N 35 
#define ARR_INT_SIZE sizeof(int) * N
#define R 0
#define W 1

int
read_prime(int pin[])
{
  int prime;
  int pout[2];
  // printf("[%d] [%d, %d] ", getpid(), pin[R], pin[W]);
  int read_result = read(pin[R], &prime, sizeof(prime));
  /* [TODO]: for some reason the code hangs on read */
  // printf("-- [%d] -- %d", read_result, prime);
  
  /* sieves prime integer */
  if(read_result > 0)
  {
    printf(" prime %d\n", prime);
    pipe(pout);

    if(fork() == 0)
    {
      /* This child process becomes parent after calling read_prime
       * and reaching fork state. */
      close(pin[R]);
      close(pin[W]);
      read_prime(pout);
    }
    else
    {
      int buff;
      
      close(pout[R]);
      close(pin[W]);
      /* Parent feeds for its child's 
       * which is a parent after next fork and reaches these commands */
      while(read(pin[R], &buff, sizeof(int)) > 0) 
      {
        if(buff % prime != 0)
        {
          write(pout[W], &buff, sizeof(int));
        }
      }
      close(pout[W]);
      close(pin[R]);
      exit(0);
    }
  }
  /* last process, reaches end-of-seq */
  exit(0);
}

int
main(int argc, char *argv[]) 
{
  int i;
  int p[2];

  pipe(p);  /* create pipe and reserves fd 3,4 */
  if(fork() > 0)
  {
    // parent
    // generate stream of integers
    for(i=2; i<=N; i++)
    {
      /* write(int fd, char *buf, int n) 
       * expects a *buf char. In that case, it wants the pointer
       * instead of actual data */
      write(p[W], &i, sizeof(int));
    }
    close(p[W]);
  }
  else
  {
    read_prime(p);
  }
  exit(0);
}
