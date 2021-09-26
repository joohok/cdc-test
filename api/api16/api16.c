#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "cubrid_log.h"

int
main (int argc, char *argv[])
{
  char ** user_arr = NULL;
  int num_user = 5;

  if (cubrid_log_set_extraction_user (user_arr, num_user) != CUBRID_LOG_SUCCESS)
    {
      printf ("[ERROR] %s:%d\n", __FILE__, __LINE__);
      exit (-1);
    }

  printf ("[SUCCESS] %s\n", __FILE__);

  return 0;
}
