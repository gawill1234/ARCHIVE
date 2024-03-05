#include <stdio.h>
#include <stdlib.h>

static char badcharset[] =
        "\001\002\003\004\005\006\007\010\011\012\013\014\015\016\017\020"
        "\021\022\023\024\025\026\027\030\031\032\033\034\035\036\037\040"
        "\177\"'%$:|";

int url_encode(const char *src, char *copy, int lensrc)
{
int i, j, k;

   for (i=k=0; i < lensrc; i++) {
      for (j=0; badcharset[j]; j++) {
         if ( src[i] == badcharset[j] ) break;
      }

      if ( badcharset[j] ) {
         snprintf(copy+k, 4, "%%%02X", src[i]);
         k += 3;
      } else {
         copy[k++] = src[i];
      }
   }

   return(k);
}

int url_decode(const char *src, char *copy, int lensrc)
{
char hexnum[3] = {0};
int i, k;

   for (i = k = 0;  i < lensrc; i++)
      if ( src[i] == '%' && src[i+1] && src[i+2] ) {
         hexnum[0] = src[++i];
         hexnum[1] = src[++i];
         copy[k++] = strtoul(hexnum, 0, 16);
      } else {
         copy[k++] = src[i];
      }

   return(k);
}

