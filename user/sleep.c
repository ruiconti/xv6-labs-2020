#include "kernel/types.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
  if(argc < 2 || argc > 2) {
    fprintf(2, "usage: sleep clock_ticks\n");
    exit(1);
  }
  int ticks = atoi(argv[1]);
  if (sleep(ticks) > 0) {
    fprintf(2, "unexpected error\n");
    exit(1);
  }
  exit(0);
}
