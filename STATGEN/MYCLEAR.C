static char USMID[] = "@(#)cmd/ucb/clear.c	6.0	10/25/89 15:53:53";

/*	COPYRIGHT CRAY RESEARCH, INC.
 *	UNPUBLISHED -- ALL RIGHTS RESERVED UNDER
 *	THE COPYRIGHT LAWS OF THE UNITED STATES.
 */	

static char *sccsid = "@(#)clear.c	4.1 (Berkeley) 10/1/80";
/* #ifndef USG
 * load me with -ltermlib
 * #else
 * load me with -lcurses
 * #endif
 */
/* #include <retrofit.h> on version 6 */
/*
 * clear - clear the screen
 */

#include <stdio.h>
#ifndef	USG
#include <sgtty.h>
#endif

char	*getenv();
char	*tgetstr();
#ifndef	USG
char	PC;
short	ospeed;
#endif
#undef	putchar
int	putchar();

clrwin()
{
	char *cp = getenv("TERM");
	char clbuf[20];
	char pcbuf[20];
	char *clbp = clbuf;
	char *pcbp = pcbuf;
	char *clear;
	char buf[1024];
#ifndef	USG
	char *pc;
	struct sgttyb tty;

	gtty(1, &tty);
	ospeed = tty.sg_ospeed;
#endif
	if (cp == (char *) 0)
		exit(1);
	if (tgetent(buf, cp) != 1)
		exit(1);
#ifndef	USG
	pc = tgetstr("pc", &pcbp);
	if (pc)
		PC = *pc;
#endif
	clear = tgetstr("cl", &clbp);
	if (clear) 
		tputs(clear, tgetnum("li"), putchar);
	return (clear == (char *) 0);
}
