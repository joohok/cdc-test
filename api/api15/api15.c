#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "cubrid_log.h"

int
main (int argc, char *argv[])
{
  char *host = argv[1];
  int port = atoi (argv[2]);
  char *dbname = argv[3];
  int timeout = atoi (argv[4]);

  if (cubrid_log_set_extraction_timeout (timeout) != CUBRID_LOG_SUCCESS)
    {
      printf ("[FAIL] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }

  printf ("[SUCCESS] %s\n", __FILE__);

  return 0;
}
