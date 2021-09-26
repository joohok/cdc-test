#include <stdio.h>
#include <stdlib.h>

#include "cubrid_log.h"

int
main (int argc, char *argv[])
{
  char *host;
  char *dbname;
  int port;
  int max_log_item;
  int ret;
  time_t start_time;
  uint64_t lsa;

  if (argc != 5)
    {
      printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }

  host = argv[1];
  port = atoi (argv[2]);
  dbname = argv[3];
  start_time = atol (argv[4]);

  if (cubrid_log_connect_server (host, port, dbname,"dba","") != CUBRID_LOG_SUCCESS)
    {
      printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }

  if (cubrid_log_find_lsa (&start_time, NULL) != CUBRID_LOG_SUCCESS)
  {
      printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
  }

  cubrid_log_finalize ();

  printf ("[SUCCESS] %s\n", __FILE__);

  return 0;
}
