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
  int ret = CUBRID_LOG_SUCCESS;

  int dml_count = 0;
  int insert_count = 0;
  int interval = 1;

  if (argc != 5)
    {
      printf ("[FAIL] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }

  if (cubrid_log_set_extraction_timeout (300) != CUBRID_LOG_SUCCESS)
    {
      printf ("[FAIL] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }

  if (cubrid_log_connect_server (host, port, dbname, "dba", "") != CUBRID_LOG_SUCCESS)
    {
      printf ("[FAIL] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }

  if ((ret = cubrid_log_find_lsa (&start_time, &next_lsa)) != CUBRID_LOG_SUCCESS)
    {
      printf ("[find lsa  error : %d\n", ret);
      printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }
    
  for (i = 0; i < 10; i++)
    {
      ret = cubrid_log_extract (&next_lsa, &log_item_list, &list_size);
      if (ret != CUBRID_LOG_SUCCESS
	  && ret != CUBRID_LOG_SUCCESS_WITH_NO_LOGITEM
	  && ret != CUBRID_LOG_EXTRACTION_TIMEOUT)
	{
	  printf ("[extraction error : %d\n", ret);
	  printf ("[FAIL] %s:%d\n", __FILE__, __LINE__);
	  exit (-1);
	}
      if (ret == CUBRID_LOG_SUCCESS)
	{
	  log_item = log_item_list;
          printf ("extract\n");

	  for (j = 0; j < list_size; j++)
	    {
	      if (log_item->data_item_type == 1)
		{
                  printf ("DML SUCCESS \n");
		  dml_count++;
		  if (log_item->data_item.dml.dml_type == 0)
		    {
		      insert_count++;
		    }
		}
	      log_item = log_item->next;
	    }

          if (cubrid_log_clear_log_item (NULL) != CUBRID_LOG_SUCCESS)
            {
              printf ("ERROR %s:%d\n", __FILE__, __LINE__);
              exit (-1);
            }
	}
	  sleep (1);
    }
  cubrid_log_finalize ();

  printf ("[SUCCESS] %s\n", __FILE__);

  return 0;
}
