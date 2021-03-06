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
  char * user;
  char * password;
#if 0 
  if (argc != 5)
    {
      printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }
#endif 

  host = argv[1];
  port = atoi (argv[2]);
  dbname = argv[3];
  user = argv [4];
  password = argv [5];

  if (cubrid_log_connect_server (host, port, dbname, user, password) != CUBRID_LOG_SUCCESS)
    {
      printf ("FAIL :  %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }

  sleep (5);
//  cubrid_log_finalize ();

  printf ("[SUCCESS] %s\n", __FILE__);

  return 0;
}
