
extern struct limitations test_limits;

extern struct thing **mymess;

/****************************************************/
/*  This is the running test table.  It contains all
 *  of the data for up to MAXTESTS tests (default, 32).
 *  This defines the maximum level of concurrency 
 *  allowed by the drive.
 */
extern struct tdata running_tests[MAXTESTS];

extern char *newenv, *thome, *optDir;
extern char *driveCommand;
extern char *infile;
extern int myuid;

extern FILE *outfp, *fp, *failfp, *runfp;

extern char *tmpdirname;
extern int runcount, newsession;

extern int MAXCONCUR;
extern int TIMEOUT_TIME;
extern int SLEEPTIME;
extern int REPEAT_COUNT;
extern int RUN_TIME;

extern int GL_keepall, GL_dorandom, GL_time_over;
extern int GL_ig_ig, GL_totalmem, GL_wantmem;

extern time_t GL_start_time, GL_end_time;
