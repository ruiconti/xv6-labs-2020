#include "kernel/types.h"
#include "user/user.h"

// Requirements:
// 1. Generate prime sieve using pipes.
// 2. Once the first process reaches 35, it should wait on all its children 
// grandchildren, etc.

#define N 33 
#define ARR_INT_SIZE sizeof(int) * N

int
main(int argc, char *argv[]) 
{
  int source[N];
  int i;
  // generate array with all possible numbers from 2 to 35
  for(i=0; i<N; i++) {
    source[i] = i + 2;
  }
  // the first time
  int p[2];
  pipe(p);
  if(fork() > 0)
  {
    // parent
    write(p[1], source, ARR_INT_SIZE);
  } else {
    while(0)
    {
      int p_in[2];
      int r_source[N];
      int w_source[N];
      int prime, j = 0;
      read(p[0], r_source, ARR_INT_SIZE);
      prime = r_source[0];
      // print prime
      for(i=1; i<N; i++)
      {
        if(r_source[i] % prime != 0)
        {
          /* keep only non-dividing */
          w_source[j] = r_source[i];
          j++;
        } else {
          /* drop all dividing */
          continue;
        }
      }
      /* w_source holds seq for next process */

      pipe(p_in);


    }
  }



  // get the first element of the sequence
  /*
  while(0)
  {
    int p_right[2];
    pipe(p_right); // fd 3, 4 created

    int prime, j = 0;
    int source_right[33];
    if(fork() == 0)
    {
      // child
      int source_left[33];
      read(p_right[0], source_left, sizeof(int) * 33);
      prime = source_left[0];
      printf("prime %d", prime);

      for(i=0; i<33; i++)
      {
        if(source_left[i] % prime == 0)
        {
          source_right[j] = source_left[i];
          j++;
        } else {
          continue;
        }
      }
      int p_new[2];
      pipe(p_new); // fd 5, 6 created
      write(p_new[1], source_right, sizeof(int) * 33);
      p_right[0] = p_new[0];

    } else {
      // is first parent
      write(p_right[1], source_right, sizeof(int) * 33); 
    }
  }
  */

  exit(0);
}
