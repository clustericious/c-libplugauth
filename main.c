#include <stdio.h>
#include "plugauth.h"

int
main(int argc, char *argv[])
{
  plugauth_client_t *client;
  int ret;

  plugauth_client_init();

  if(argc == 2 && !strcmp(argv[1], "--version"))
  {
    printf("%s\n", plugauth_client_version_string());
    return 0;
  }
  
  printf("libplugauth version %s\n", plugauth_client_version_string());
  
  if(argc != 4)
  {
    fprintf(stderr, "usage: %s url user pass\n", argv[0]);
    return 1;
  }
  else
  {
    client = plugauth_client_new(argv[1]);
    printf("auth url = %s\n", plugauth_client_get_auth_url(client));
    ret = plugauth_client_auth(client, argv[2], argv[3]);
    if(ret == PLUGAUTH_AUTHORIZED)
    {
      printf("ok\n");
      return 0;
    }
    else if(ret == PLUGAUTH_UNAUTHORIZED)
    {
      printf("fail\n");
      return 2;
    }
    else
    {
      fprintf(stderr, "error: %s\n", plugauth_client_get_error(client));
      return 1;
    }  
  }
}
