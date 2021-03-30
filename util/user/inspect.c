#include "kernel/types.h"
#include "user/user.h"
#include "kernel/stat.h"

int
main(int argc, char *argv[])
{
  int i;
  printf("%s called with %d args\n", argv[0], argc);
  for(i=1; i <= argc; i++) {
    printf("argv[%d]: %s\n", i, argv[i]);
  } 
  exit(0);
} 
