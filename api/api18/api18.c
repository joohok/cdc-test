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

  int max_log_item = atoi (argv[5]);

  uint64_t next_lsa = 0;
  int i; 

  CUBRID_LOG_ITEM *log_item_list;
  CUBRID_LOG_ITEM *log_item;

  CUBRID_DATA_ITEM *data_item;

  int list_size = 0;
  int ret = CUBRID_LOG_SUCCESS;

  if (argc != 6)
    {
      printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }
  
  if (cubrid_log_set_max_log_item (max_log_item) != CUBRID_LOG_SUCCESS)
    {
      printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }
 
  if (cubrid_log_connect_server (host, port, dbname, "", "") != CUBRID_LOG_SUCCESS)
    {
      printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }

  if (cubrid_log_find_lsa (&start_time, &next_lsa) != CUBRID_LOG_SUCCESS)
    {
      printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }

  for (i = 0; i < 5; i++)
    {
      ret = cubrid_log_extract (&next_lsa, &log_item_list, &list_size);
      if (ret != CUBRID_LOG_SUCCESS
	  && ret != CUBRID_LOG_SUCCESS_WITH_NO_LOGITEM
	  && ret != CUBRID_LOG_EXTRACTION_TIMEOUT)
	{
	  printf ("[extraction error : %d\n", ret);
	  printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
	  exit (-1);
	}
      if (ret == CUBRID_LOG_SUCCESS)
	{
          printf ("\tlist size = %d\n", list_size);
          
	  sleep (1);
	}
      cubrid_log_clear_log_item (log_item_list);
    }

  cubrid_log_finalize ();

  return 0;
}
