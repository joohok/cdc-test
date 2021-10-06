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

  for (i = 0; i < 2; i++)
    {
      if (cubrid_log_extract (&next_lsa, &log_item_list, &list_size) != CUBRID_LOG_SUCCESS)
	{
	  printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
	  exit (-1);
	}

      log_item = log_item_list;

      for (j = 0; j < list_size; j++)
	{
          if (log_item->data_item_type == 1)
          {
            if(log_item->data_item.dml.dml_type == 0)
            {
              data_item = &log_item->data_item;

              printf ("%d\n", (int)*data_item->dml.changed_column_data[0]);
            }
          }
          log_item = log_item->next;
        }

      printf ("%lld\n",next_lsa);
      sleep (1);
    }


  cubrid_log_finalize ();

  printf ("[SUCCESS] %s\n", __FILE__);

  return 0;
}
