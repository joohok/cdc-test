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

  time_t start_time = atoi (argv[4]);

  uint64_t next_lsa = 0;

  CUBRID_LOG_ITEM *log_item_list;
  CUBRID_LOG_ITEM *log_item;

  CUBRID_DATA_ITEM *data_item;

  int list_size = 0;
  int i, j, k;

  int dml_count = 0;
  int insert_count = 0;
  int interval = 1;

  int error;
  start_time = time (NULL) - 5;
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

/*
  if (cubrid_log_set_all_in_cond (1) != CUBRID_LOG_SUCCESS)
    {
      printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }
*/

  if (cubrid_log_connect_server (host, port, dbname, "","") != CUBRID_LOG_SUCCESS)
    {
      printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }

  if (cubrid_log_find_lsa (&start_time, &next_lsa) != CUBRID_LOG_SUCCESS)
    {
      printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }

  for (i = 0; i < 10; i++)
    {
      if ((error = cubrid_log_extract (&next_lsa, &log_item_list, &list_size)) != CUBRID_LOG_SUCCESS)
	{
	  printf ("[ERROR] %s:%d %d\n", __FILE__, __LINE__, error);
	}

      log_item = log_item_list;

      for (j = 0; j < list_size; j++)
	{
          if (log_item->data_item_type == 1)
          {
            dml_count++;
            if(log_item->data_item.dml.dml_type == 0)
            {
              insert_count ++;
            }
          }

	  if (j % interval == 0)
	    {
	      printf ("=== LOG_ITEM ===\n");
	      printf ("transaction_id: %d\n", log_item->transaction_id);
	      printf ("user          : %s\n", log_item->user);
	      printf ("data_item_type: %d\n", log_item->data_item_type);
	      printf ("\n");

	      data_item = &log_item->data_item;

	      printf ("\t=== DATA_ITEM ===\n");
	      switch (log_item->data_item_type)
		{
                case 0:
                  break;

		case 1:
		  printf ("\tdml_type          : %d\n", data_item->dml.dml_type);
		  printf ("\tclassoid          : %ld\n", data_item->dml.classoid);
		  printf ("\tnum_changed_column: %d\n", data_item->dml.num_changed_column);
                  printf ("DML SUCCESS \n");
		  printf ("\n");

		  break;

		case 2:
		  printf ("\tdcl_type          : %d\n", data_item->dcl.dcl_type);
		  printf ("\ttimestamp         : %ld\n", data_item->dcl.timestamp);
		  printf ("\n");

		  break;

		case 3:
		  printf ("\ttimestamp         : %ld\n", data_item->timer.timestamp);

		  break;

		default:
		  assert (0);
		}
	    }
	  log_item = log_item->next;
	}

      sleep (1);
    }

  printf("DML COUNT : %d\n", dml_count);
  printf("INSERT COUNT : %d\n", insert_count);

  cubrid_log_finalize ();

  printf ("[SUCCESS] %s\n", __FILE__);

  return 0;
}
