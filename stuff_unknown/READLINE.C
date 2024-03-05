/*******************************************************/
/*  Three routines right out of the Stevens netork programming
    book.  Easy to use, but god awful slow.  Included for your
    I/O pleasure.
*/
int readn(fd, ptr, nbytes)
register int fd;
register char *ptr;
register int nbytes;
{
int nleft, nread;

   nleft = nbytes;
   while (nleft > 0) {
      nread = read(fd, ptr, nleft);
      if (nread < 0)
         return(nread);
      else if (nread == 0)
         break;

      nleft -= nread;
      ptr += nread;
   }
   return(nbytes - nleft);
}

int writen(fd, ptr, nbytes)
register int fd;
register char *ptr;
register int nbytes;
{
int nleft, nwritten;

   nleft = nbytes;
   while (nleft > 0) {
      nwritten = write(fd, ptr, nleft);
      if (nwritten <= 0)
         return(nwritten);

      nleft -= nwritten;
      ptr += nwritten;
   }
   return(nbytes - nleft);
}

int readline(fd, ptr, maxlen)
register int fd;
register char *ptr;
register int maxlen;
{
int n, rc;
char c;

   for (n = 1; n< maxlen; n++) {
      if ((rc = read(fd, &c, 1)) == 1) {
         *ptr++ = c;
         if ( c == '\n')
            break;

      } 
      else if (rc == 0) {
         if (n == 1)
            return(0);
         else
            break;
      }
      else 
         return(-1);
   }

   *ptr = 0;
   return(n);
}

