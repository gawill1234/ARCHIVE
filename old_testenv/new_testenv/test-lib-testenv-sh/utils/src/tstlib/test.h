
long getFSType(char *);
int fileexist(char *);
int direxist(const char *);
char *uniquedirname(char *);
int create_nested_directories(const char *, FILE *, int);
int matchmode(char *, char *);
int copydirectory(char *, char *);
int cleardirectory(const char *);
char *searchdir(char *, char *);
char *findfile(char *);
int copyfile(char *, char *);
char *_basename(char *);
char *_dirname(char *);
char *myreadline(int, char *, int);
char *getmydir(int);
char *workingdir(char *);
char *getthefile(char *);
char *getfullpath(char *);
char *buildfullpath(const char *, char *);
char *genstring(char *);
int random_int_in_range(int);
char *getdate();
int streq(char *, char *);
int strneq(char *, char *, int);
char *cutatchar(char *, char);
char *swap_char(char *, char, char);
char **split_string(char *, char);

