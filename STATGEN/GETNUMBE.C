/*

   Translate a character string of numbers into an actual
   integer.  No floats or negatives allowed.
   Don't forget to include the -lm option on the C command line
   so the loader will pass in pow from libm.

*/

#include <stdio.h>
#include <math.h>

getnumber(string)
char *string;
{
int mult, value, next;
int len, ten, letterval;

   ten = 10;

   mult = value = next = 0;
   len = strlen(string);
   while (len > 0) {
      letterval = 0;
      len--;

      /***************************************************************/ 
      /*  Get the integer value of the character.
      */

      letterval = (int)string[next] - (int)'0';

      /***************************************************************/

      /***************************************************************/
      /*  If the character is not a number, return -1;  Not valid.
      */

      if ((letterval < 0) || (letterval > 9))
         return(-1);

      /***************************************************************/

      /***************************************************************/ 
      /*  Get the current multiple of 10 (1, 10, 100, 1000, etc.)
      */

      mult = (int)pow((double)ten, (double)len);

      /***************************************************************/

      /***************************************************************/
      /*  Increment "value" by the next known number, the number
          having come from a known place (1s column, 10s column, etc.,
          you remember from 3rd or 4rth grad math).
      */

      value = value + (mult * letterval);

      /**************************************************************/

      next++;
   }
   return(value);
}
