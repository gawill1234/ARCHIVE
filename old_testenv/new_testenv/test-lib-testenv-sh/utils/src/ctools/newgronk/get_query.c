#include "myincludes.h"

//
//   Get the CGI QUERY_STRING env variable.
//   This has the arguments needed to run the
//   program.
//
char *get_query()
{
char *query, *tmp;
int qlen, i;

 query = getenv("QUERY_STRING");
 if (!query) {
   return "";
 }

 qlen = strlen(query);
 tmp = calloc(qlen + 1, 1);
 i = url_decode(query, tmp, qlen);
 return(tmp);
}
