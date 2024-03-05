#define MAXLINE 512

/*****************************************************/
/*   Test routine used to check out the networking 
     connection routines on the server side.
     Reads a line from a file descriptor, echos it back
     to the sender and prints it on the local stdout.

     Also out of the Stevens networking book.
*/

int str_echo(sockfd)
int sockfd;
{
int n;
char line[MAXLINE];

   for (;;) {
      n = readline(sockfd, line, MAXLINE);
      if (n == 0)
         return;
      else if (n < 0)
         err_dump("readline error");

      if (writen(sockfd, line, n) != n)
         err_dump("str_echo: writen error");
   }
}
