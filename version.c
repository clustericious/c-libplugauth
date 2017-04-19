#include <stdio.h>
#include "plugauth.h"

static int first = 1;
static char version_buffer[10] = "";

void plugauth_client_init()
{
  if(first)
  {
    snprintf(version_buffer, sizeof(version_buffer), "%d.%02d", PLUGAUTH_VERSION / 100, PLUGAUTH_VERSION % 100);  
    first = 1;
  }
}

int plugauth_client_version()
{
  return PLUGAUTH_VERSION;
}

const char *plugauth_client_version_string()
{
  return version_buffer;
}
