#include <stdio.h>
#include <stdlib.h>

#include "cubrid_log.h"

int
main (int argc, char *argv[])
{
  char *host;
  char *dbname;
  int port;
  int extraction_timeout;
  int ret; 

  if (argc != 5)
    {
      printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }

  host = argv[1];
  port = atoi (argv[2]);
  dbname = argv[3];

  if (cubrid_log_connect_server (host, port, dbname, "joo", "") != CUBRID_LOG_SUCCESS)
    {
      printf ("FAIL :  %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }

//  cubrid_log_finalize ();

  printf ("[SUCCESS] %s\n", __FILE__);

  return 0;
}
