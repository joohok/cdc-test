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

  if (cubrid_log_connect_server (host, port, dbname, "dba","") != CUBRID_LOG_SUCCESS)
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
            dml_count++;
            if(log_item->data_item.dml.dml_type == 0)
            {
              insert_count ++;
            }
          }

	  if (j % interval == 0)
	    {
	      data_item = &log_item->data_item;

	      printf ("\t=== DATA_ITEM ===\n");
	      switch (log_item->data_item_type)
		{
                case 0: 
                  break;
		case 1:
		  printf ("\tdml_type          : %d\n", data_item->dml.dml_type);
		  printf ("\tclassoid          : %lld\n", data_item->dml.classoid);
		  printf ("\tnum_changed_column: %d\n", data_item->dml.num_changed_column);
		  printf ("\tchanged_column_data[0]: %s\n", data_item->dml.changed_column_data[0]);
		  printf ("\tchanged_column_data[1]: %s\n", data_item->dml.changed_column_data[1]);
		  printf ("\tchanged_column_data[2]: %s\n", data_item->dml.changed_column_data[2]);
		  printf ("\tchanged_column_data[3]: %s\n", data_item->dml.changed_column_data[3]); // char  
                  printf ("DML SUCCESS \n");
		  printf ("\n");

		  break;

		case 2:
		  break;

		case 3:
		  break;

		default:
		  assert (0);
		}
	    }
	  log_item = log_item->next;
	}
      cubrid_log_clear_log_item (log_item_list);
      sleep (1);
    }

  printf("DML COUNT : %d\n", dml_count);
  printf("INSERT COUNT : %d\n", insert_count);

  cubrid_log_finalize ();

  printf ("[SUCCESS] %s\n", __FILE__);

  return 0;
}
