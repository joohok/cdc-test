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

  int int_val;
  float float_val;
  double double_val;

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


  if (cubrid_log_set_all_in_cond (1) != CUBRID_LOG_SUCCESS)
    {
      printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }


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
                  if (data_item->dml.dml_type == 2)
                  {
                    printf ("\tdml_type          : %d\n", data_item->dml.dml_type);
                    printf ("\tclassoid          : %lld\n", data_item->dml.classoid);
                    printf ("\tnum_cond_column: %d\n", data_item->dml.num_cond_column);

                    if (data_item->dml.num_cond_column > 0)
                    {
                    memcpy (&int_val, data_item->dml.cond_column_data[0], data_item->dml.cond_column_data_len[0]);
                    printf ("\tcond_column_data[0]: %d\n", int_val);

                    memcpy (&float_val, data_item->dml.cond_column_data[1], data_item->dml.cond_column_data_len[1]);
                    printf ("\tcond_column_data[1]: %lf\n", float_val);

                    memcpy (&double_val, data_item->dml.cond_column_data[2], data_item->dml.cond_column_data_len[2]);
                    printf ("\tcond_column_data[2]: %lf\n", double_val);

                    printf ("\tcond_column_data[3]: %s\n", data_item->dml.cond_column_data[3]); // char  
                    printf ("\tcond_column_data[4]: %s\n", data_item->dml.cond_column_data[4]); // varchar 
                    printf ("\tcond_column_data[5]: %s\n", data_item->dml.cond_column_data[5]); // bit 
                    printf ("\tcond_column_data[6]: %s\n", data_item->dml.cond_column_data[6]); // varbit 
                    printf ("\tcond_column_data[7]: %s\n", data_item->dml.cond_column_data[7]); // timestamp 
                    printf ("\tcond_column_data[8]: %s\n", data_item->dml.cond_column_data[8]); // timestamptz 
                    printf ("\tcond_column_data[9]: %s\n", data_item->dml.cond_column_data[9]);  // datetime 
                    printf ("\tcond_column_data[10]: %s\n", data_item->dml.cond_column_data[10]); // datetimetz 
                    printf ("\tcond_column_data[11]: %s\n", data_item->dml.cond_column_data[11]); // date
                    printf ("\tcond_column_data[12]: %s\n", data_item->dml.cond_column_data[12]); // time 
                    printf ("\tcond_column_data[13]: %s\n", data_item->dml.cond_column_data[13]); // BLOB 
                    printf ("\tcond_column_data[14]: %s\n", data_item->dml.cond_column_data[14]); // CLOB  
                    printf ("\tcond_column_data[15]: %s\n", data_item->dml.cond_column_data[15]); // numeric/decimal  
                    printf ("\tcond_column_data[16]: %s\n", data_item->dml.cond_column_data[16]); // enum  
                    }
                    printf ("DML SUCCESS \n");
                    printf ("\n");
                  }

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
