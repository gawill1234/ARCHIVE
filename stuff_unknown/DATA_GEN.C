#include <stdio.h>
#include <unistd.h>

#include "test_clnt_srv.h"
#include "test_struct.h"
#include "test.h"


/***********************************************/
/*  Basically the same as
       buffer = (char *)calloc(buff_size, 1);
*/
char *get_buffer(buff_size)
word buff_size;
{
char *buffer;
int i;

   buffer = (char *)malloc(buff_size + 1 + (BYTESINWORD * 3));
   for (i = 0; i < (buff_size + 1); i++)
      buffer[i] = '\0';

   return(buffer);
}

/*****************************************************************/
/*  GENIT

    Generate a random sequence of word integers along with the
    correct lseek amount so that when the various members of the
    created structure are used, a file created in a random order
    will look ordered when it is complete.

    PARAMETERS:
       numwords:    The number of words to put in the list

    RETURNs:
       a structure which points to the words and the lseek
       amounts needed to randomly fill a file or memory.
*/

struct randomstruct *genit(numwords)
int numwords;
{
struct randomstruct *numlist;
int biggness, i, j;
double drand48();

   srand48(time((long *)0));
   biggness = sizeof(struct randomstruct);
   numlist = (struct randomstruct *)malloc(numwords * biggness);
   for (i = 0; i < numwords; i++) {
      numlist[i].sequence = i;
      numlist[i].used = 0;
      numlist[i].number = -1;
      numlist[i].seekamt = -1;
   }

   for (i = 0; i < numwords; i++) {
      j = (int)(drand48() * (double)(numwords));
      if (numlist[j].used == 1) {
         j = 0;
         while ((j < numwords) && (numlist[j].used == 1))
            j++;
      }
      numlist[j].used = 1;
      numlist[i].number = j;
      numlist[i].seekamt = numlist[i].number * BYTESINWORD;
   }

   for (i = (numwords - 1); i > 0; i--) {
      j = numlist[i - 1].seekamt + BYTESINWORD;
      numlist[i].seekamt = numlist[i].seekamt - j;
   }


   return(numlist);
}

/*******************************************************************/
/*  LONG_INORDER_DATA

    Create word data in memory, in order.

    PARAMETERS:
       filebytes:   A pointer to the number of bytes to create.
                    This is a pointer because filebytes may be
                    rounded up to cause the data to end on a word
                    boundary.

    RETURNS:
        A pointer to a buffer of word integers.
*/
word *word_inorder_data(filebytes)
int *filebytes;
{
word *placeholder;
word numwords, i;

   numwords = (*filebytes + (BYTESINWORD - 1)) / BYTESINWORD;
   *filebytes = numwords * BYTESINWORD;

   placeholder = (word *)malloc(sizeof(word) * numwords);

   for (i = 0; i < numwords; i++) {
      placeholder[i] = i;
   }

   return(placeholder);
}

/*******************************************************************/
/*  LONG_RANDOM_DATA

    Create word data in memory, in random order.
    For larger buffers, this can take a while.

    PARAMETERS:
       filebytes:   A pointer to the number of bytes to create.
                    This is a pointer because filebytes may be
                    rounded up to cause the data to end on a word
                    boundary.

    RETURNS:
        A pointer to a buffer of word integers.
*/
word *word_random_data(filebytes)
int *filebytes;
{
char *placeholder, *stayput;
struct randomstruct *numlist;
int numwords, i;

   numwords = (*filebytes + (BYTESINWORD - 1)) / BYTESINWORD;
   *filebytes = numwords * BYTESINWORD;
   numlist = genit(numwords);

   placeholder = (char *)malloc(sizeof(word) * numwords);
   stayput = placeholder;

   for (i = 0; i < numwords; i++) {
      memcpy(placeholder, &numlist[i].number, BYTESINWORD);
      placeholder = placeholder + BYTESINWORD;
   }

   free(numlist);
   return((word *)stayput);
}

/*******************************************************************/
/*  BIT_PATTERN

    Create word data in memory.  It will look like a bit pattern of
    010101010101010101010101010101  when written or copied to memory.

    PARAMETERS:
       filebytes:   A pointer to the number of bytes to create.
                    This is a pointer because filebytes may be
                    rounded up to cause the data to end on a word
                    boundary.

    RETURNS:
        A pointer to a buffer of the bit pattern stored as words.
*/
word *bit_pattern(filebytes)
int *filebytes;
{
char *placeholder, *stayput;
uword this_pattern = BIT_PATTERN_32;
struct randomstruct *numlist;
int numwords, i;

   numwords = (*filebytes + (BYTESINWORD - 1)) / BYTESINWORD;
   *filebytes = numwords * BYTESINWORD;

   placeholder = (char *)malloc(sizeof(word) * numwords);
   stayput = placeholder;

   for (i = 0; i < numwords; i++) {
      memcpy(placeholder, &this_pattern, BYTESINWORD);
      placeholder = placeholder + BYTESINWORD;
   }

   return((word *)stayput);
}

word *w_bit_pattern(filewords)
int filewords;
{
int filebytes;

   filebytes = filewords * BYTESINWORD;
   return(bit_pattern(&filebytes));
}


word *w_word_inorder_data(filewords)
int filewords;
{
int filebytes;

   filebytes = filewords * BYTESINWORD;
   return(word_inorder_data(&filebytes));
}


word *w_word_random_data(filewords)
int filewords;
{
int filebytes;

   filebytes = filewords * BYTESINWORD;
   return(word_random_data(&filebytes));
}

char *gen_data(dtype, dsize)
unsigned int dtype;
int *dsize;
{
char *arr;

   switch (dtype) {
      case DG_BP_DATA:
                arr = (char *)bit_pattern(dsize);
                break;

      case DG_LR_DATA:
                arr = (char *)word_random_data(dsize);
                break;

      case DG_LO_DATA:
                 arr = (char *)word_inorder_data(dsize);
                 break;
 
      case DG_CHR_DATA:
                 arr = (char *)create_chr_data(*dsize, getpid());
                 break;

      case DG_DATA_UNK:
      default:
                 arr = (char *)malloc(*dsize);
                 break;
   }
   return(arr);
}


/*****************************************************/
/*   Commented out.  Test driver for above routines.
*/
/*
main()
{
int i;
word *gump, *dorandom();

   gump = NULL;

   gump = w_word_inorder_data(10);
   for (i = 0; i < 10; i++)
      printf("%d  %d,  %d,  %d\n", i, gump[i], &gump[i], *gump+i);

   gump = w_word_random_data(20);
   for (i = 0; i < 20; i++)
      printf("%d  %d,  %d,  %d\n", i, gump[i], &gump[i], *gump+i);

   gump = w_bit_pattern(21);
   for (i = 0; i < 21; i++)
      printf("%d  %o,  %d,  %d\n", i, gump[i], &gump[i], *gump+i);
}
*/
