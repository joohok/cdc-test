#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "cubrid_log.h"

int
main (int argc, char *argv[])
{
  char *path = argv[1]; 
  int level = atoi (argv[2]);
  int filesize = atoi (argv[3]);

  if (cubrid_log_set_tracelog (path, level, filesize) != CUBRID_LOG_SUCCESS)
    {
      printf ("[FAIL] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }

  printf ("[SUCCESS] %s\n", __FILE__);

  return 0;
}
