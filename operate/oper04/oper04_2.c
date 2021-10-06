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

  uint64_t next_lsa = atol (argv[4]);

  CUBRID_LOG_ITEM *log_item_list;
  CUBRID_LOG_ITEM *log_item;

  CUBRID_DATA_ITEM *data_item;

  int list_size = 0;
  int i, j, k;

  int dml_count = 0;
  int insert_count = 0;
  int interval = 1;

  if (argc != 5)
    {
      printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }

  if (cubrid_log_set_max_log_item (500) != CUBRID_LOG_SUCCESS)
    {
      printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }

  if (cubrid_log_connect_server (host, port, dbname, "dba","") != CUBRID_LOG_SUCCESS)
    {
      printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }

  for (i = 0; i < 10; i++)
    {
      if (cubrid_log_extract (&next_lsa, &log_item_list, &list_size) != CUBRID_LOG_SUCCESS)
	{
	  printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
	  exit (-1);
	}
      sleep (1);
    }

  printf ("%lld\n",next_lsa);

  cubrid_log_finalize ();

  printf ("[SUCCESS] %s\n", __FILE__);

  return 0;
}
