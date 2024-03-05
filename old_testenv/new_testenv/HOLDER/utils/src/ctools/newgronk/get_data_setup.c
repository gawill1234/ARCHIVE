#include "myincludes.h"

//
//   Control routine.  Process the arguments
//   and execute the user operations.
//   These are specific to messing with the repository.
//
int service_int(char *service_name)
{

   if (streq(service_name, "query-all\0") ||
       streq(service_name, "query-service-all\0")) {
      return(QUERY_ALL);
   }
   if (streq(service_name, "crawler\0")) {
      return(CRAWLER);
   }
   if (streq(service_name, "indexer\0")) {
      return(INDEXER);
   }
   if (streq(service_name, "crindex\0")) {
      return(CRAWLER_AND_INDEXER);
   }
   if (streq(service_name, "collection-service\0")) {
      return(COLLECTION_SERVICE);
   }
   if (streq(service_name, "broker\0") ||
       streq(service_name, "collection-broker\0")) {
      return(CBROKER);
   }
   if (streq(service_name, "collection-service-all\0")) {
      return(COLLECTION_SERVICE_ALL);
   }
   if (streq(service_name, "query\0") ||
       streq(service_name, "query-service\0")) {
      return(QUERY);
   }
   if (streq(service_name, "collection-service-dispatch\0")) {
      return(COLLECTION_SERVICE_DISPATCH);
   }
   if (streq(service_name, "execute-worker\0")) {
      return(EXECUTE_WORKER);
   }
   if (streq(service_name, "admin\0")) {
      return(ADMIN);
   }
   if (streq(service_name, "java\0")) {
      return(JAVA);
   }
   if (streq(service_name, "velocity\0")) {
      return(VELOCITY);
   }
   if (streq(service_name, "supplied\0")) {
      return(PPID_SUPPLIED);
   }
   if (streq(service_name, "scheduler\0") ||
       streq(service_name, "scheduler-service\0")) {
      return(SCHEDULER);
   }
   if (streq(service_name, "source-test\0") ||
       streq(service_name, "source-test-service\0")) {
      return(SOURCETEST);
   }
   if (streq(service_name, "report\0") ||
       streq(service_name, "report-service\0")) {
      return(REPORT);
   }
   if (streq(service_name, "alert\0") ||
       streq(service_name, "alert-service\0")) {
      return(ALERTS);
   }

   return(-1);
}

char *find_value_in_arglist(char *value_of, char **argv, int argc)
{
int larg = 0;
char *value;

   while ( larg < argc ) {
      if (streq(argv[larg], value_of)) {
         larg++;
         if (larg < argc) {
            value = argv[larg];
            return(value);
         }
      }
      larg++;
   }

   return(NULL);
}

//
//   ACTION is "find-collection-core", "find-cgi-core", "find-core"
//
void cgi_do_find(int argc, char **argv, int findselect)
{
char collection_str[] = "collection\0";
char *collection;

   switch (findselect) {
      case 1:
         collection = find_value_in_arglist(collection_str, argv, argc);
         find_collection_core(collection);
         break;
      case 2:
         find_cgi_core();
         break;
      default:
         find_core();
         break;
   }

   return;
}

//
//   ACTION is "kill-query-services"
//
void cgi_kill_query_services(int argc, char **argv)
{
int err;

   ops_out(-1, KILLQUERY, "QUERY", "QUERY", 0);
   err = killqueryservices();
   ops_done(err, KILLQUERY, 0);

   return;
}

void cgi_kill_admin(int argc, char **argv)
{
int err;

   ops_out(-1, KILLADMIN, "ADMIN", "ADMIN", 0);
   err = killqueryservices();
   ops_done(err, KILLADMIN, 0);

   return;
}

//
//   ACTION is "velocity-shutdown"
//
void cgi_velocity_shutdown(int argc, char **argv)
{
int err;

   ops_out(-1, KILLALL, "ALL", "ALL", 0);
   err = killallservices(1);
   ops_done(err, KILLALL, 0);

   return;
}

//
//   ACTION is "kill-all-services"
//
void cgi_kill_all_services(int argc, char **argv)
{
int err;

   ops_out(-1, KILLALL, "ALL", "ALL", 0);
   err = killallservices(0);
   ops_done(err, KILLALL, 0);

   return;
}

//
//   ACTION is "get-crawl-dir"
//
void cgi_do_crawl_dir(int argc, char **argv)
{

char collection_str[] = "collection\0";
char *collection;

   collection = find_value_in_arglist(collection_str, argv, argc);
   do_crawl_dir(collection);

   return;
}

//
//   ACTION is "get-pid-list"
//
void cgi_get_pid_list(int argc, char **argv)
{

char service_str[] = "service\0";
char collection_str[] = "collection\0";

char *service_name, *collection;
int service;

   service_name = find_value_in_arglist(service_str, argv, argc);
   service =  service_int(service_name);

   switch (service) {
      case QUERY:
         collection = NULL;
         break;
      case CBROKER:
         collection = NULL;
      default:
         collection = find_value_in_arglist(collection_str, argv, argc);
         break;
   }

   pid_list(service, collection);

   return;
}

//
//   ACTION is "file-size"
//
void cgi_file_size(int argc, char **argv)
{

char file_str[] = "file\0";

char *filename;
int doesit;

   doesit = -1;
   filename = NULL;

   filename = find_value_in_arglist(file_str, argv, argc);

   ops_out(FILE_CP, SIZE, filename, filename, 0);
   if (filename != NULL) {
      doesit = get_file_size(filename);
   }
   ops_done(doesit, SIZE, 0);

   return;
}

//
//   ACTION is "get-collection-list"
//
void cgi_collection_list(int argc, char **argv)
{

char *collection_dir;

   collection_dir = NULL;
#ifdef PLATFORM_WINDOWS
   collection_dir = get_install_dir("\\data\\search-collections\0");
#else
   collection_dir = get_install_dir("/data/search-collections\0");
#endif

   get_collection_list(collection_dir);

   return;
}

//
//   ACTION is "file-time"
//
void cgi_file_time(int argc, char **argv)
{

char file_str[] = "file\0";
char date_str[] = "date\0";

char *filename, *whichdate;
int doesit;

   doesit = -1;
   filename = NULL;

   filename = find_value_in_arglist(file_str, argv, argc);
   whichdate = find_value_in_arglist(date_str, argv, argc);

   doesit = get_file_time(filename, whichdate);

   return;
}

//
//   ACTION is "get-fs-gb-free", "get-fs-mb-free"
//
void cgi_file_system_free(int argc, char **argv, int szselect)
{

char file_str[] = "file\0";

char *filename;

   filename = NULL;

   filename = find_value_in_arglist(file_str, argv, argc);

   if (filename != NULL) {
      fs_free(szselect, filename);
   }

   return;
}

//
//   ACTION is "rm-collection"
//
void cgi_collection_delete(int argc, char **argv)
{
char collection_str[] = "collection\0";

char *filename, *collection;
int err;

   err = -1;
   collection = filename = NULL;

   collection = find_value_in_arglist(collection_str, argv, argc);
   if (collection != NULL) {
      filename = build_collection_path(collection, 0);
   }

   ops_out(COLLECTION_CP, MYDELETE, filename, collection, 0);
   if (filename != NULL) {
      if (access(filename, F_OK) == 0) {
         err = delete_data(COLLECTION_CP, filename, collection);
      }
   }
   ops_done(err, MYDELETE, 0);

   return;
}

void cgi_restore_collection(int argc, char **argv)
{
char collection_str[] = "collection\0";
char testname_str[] = "testname\0";

char *collection, *testname;
int err;

   collection = testname = NULL;

   collection = find_value_in_arglist(collection_str, argv, argc);
   testname = find_value_in_arglist(testname_str, argv, argc);

   ops_out(COLLECTION_CP, RESTORECOLLECTION, NULL, collection, 0);
   err = restore_the_collection(testname, collection);
   ops_done(err, RESTORECOLLECTION, 0);

   return;

}

//
//   ACTION is "execute"
//
void cgi_execute_command(int argc, char **argv)
{

char command_str[] = "command\0";
char type_str[] = "type\0";
char root_str[] = "runasroot\0";

char *command, *ftype, *runasroot;
int err, binflag;

   binflag = err = 0;
   command = NULL;

   command = find_value_in_arglist(command_str, argv, argc);
   ftype = find_value_in_arglist(type_str, argv, argc);
   runasroot = find_value_in_arglist(root_str, argv, argc);

   if ( ftype != NULL ) {
      if (streq(ftype, "binary")) {
         binflag = 1;
      }
   }

   ops_out(COMMAND, EXEC, command, command, binflag);
#ifndef PLATFORM_WINDOWS
   if ( runasroot != NULL ) {
      if (streq(runasroot, "runasroot")) {
         setuid(0);
      }
   }
#endif
   err = execute_command(COMMAND, command);
   ops_done(err, EXEC, binflag);

   return;
}

//
//   ACTION is "alter-file"
//
void cgi_file_alter(int argc, char **argv)
{

char file_str[] = "file\0";
char type_str[] = "type\0";
char chmod_str[] = "chmod\0";

char *filename, *ftype, *mode;
int err, binflag;

   binflag = err = 0;
   filename = NULL;

   filename = find_value_in_arglist(file_str, argv, argc);
   ftype = find_value_in_arglist(type_str, argv, argc);
   mode = find_value_in_arglist(chmod_str, argv, argc);

   if ( ftype != NULL ) {
      if (streq(ftype, "binary")) {
         binflag = 1;
      }
   }

   ops_out(FILE_CP, ALTER, filename, filename, binflag);
   if (filename != NULL) {
      if (access(filename, F_OK) == 0) {
         err = alter_file(FILE_CP, filename, mode);
      } else {
         err = -1;
      }
   }
   ops_done(err, ALTER, binflag);

   return;
}

//
//   ACTION is "alter-collection"
//
void cgi_collection_alter(int argc, char **argv)
{

char collection_str[] = "collection\0";
char file_str[] = "file\0";
char type_str[] = "type\0";
char chmod_str[] = "chmod\0";

char *filename, *ftype, *collection, *mode;
int err, binflag;

   binflag = err = 0;
   filename = NULL;

   collection = find_value_in_arglist(collection_str, argv, argc);
   ftype = find_value_in_arglist(type_str, argv, argc);
   mode = find_value_in_arglist(chmod_str, argv, argc);

   if (collection != NULL) {
      filename = build_collection_path(collection, 0);
   }

   if ( ftype != NULL ) {
      if (streq(ftype, "binary")) {
         binflag = 1;
      }
   }

   ops_out(COLLECTION_CP, ALTER, filename, collection, binflag);
   if (filename != NULL) {
      if (access(filename, F_OK) == 0) {
         err = alter_file(COLLECTION_CP, filename, mode);
      } else {
         err = -1;
      }
   }
   ops_done(err, ALTER, binflag);

   return;
}
//
//   ACTION is "send-file"
//
void cgi_file_get(int argc, char **argv)
{

char file_str[] = "file\0";
char type_str[] = "type\0";

char *filename, *ftype;
int err, binflag;

   binflag = err = 0;
   filename = NULL;

   filename = find_value_in_arglist(file_str, argv, argc);
   ftype = find_value_in_arglist(type_str, argv, argc);

   if ( ftype != NULL ) {
      if (streq(ftype, "binary")) {
         binflag = 1;
      }
   }

   ops_out(FILE_CP, SENDING, filename, filename, binflag);
   if (filename != NULL) {
      err = get_data(FILE_CP, filename);
   }
   ops_done(err, SENDING, binflag);

   return;
}

//
//   ACTION is "send-collection"
//
void cgi_collection_get(int argc, char **argv)
{

char collection_str[] = "collection\0";
char file_str[] = "file\0";
char type_str[] = "type\0";

char *filename, *ftype, *collection;
int err, binflag;

   binflag = err = 0;
   filename = NULL;

   collection = find_value_in_arglist(collection_str, argv, argc);
   ftype = find_value_in_arglist(type_str, argv, argc);

   if (collection != NULL) {
      filename = build_collection_path(collection, 0);
   }

   if ( ftype != NULL ) {
      if (streq(ftype, "binary")) {
         binflag = 1;
      }
   }

   ops_out(COLLECTION_CP, SENDING, filename, collection, binflag);
   if (filename != NULL) {
      err = get_data(COLLECTION_CP, filename);
   }
   ops_done(err, SENDING, binflag);

   return;
}
//
//   ACTION is "get-file"
//
void cgi_file_send(int argc, char **argv)
{

char file_str[] = "file\0";
char type_str[] = "type\0";

char *filename, *ftype;
int err, binflag;

   binflag = err = 0;
   filename = NULL;

   filename = find_value_in_arglist(file_str, argv, argc);
   ftype = find_value_in_arglist(type_str, argv, argc);

   if ( ftype != NULL ) {
      if (streq(ftype, "binary")) {
         binflag = 1;
      }
   }

   ops_out(FILE_CP, GETTING, filename, filename, binflag);
   if (filename != NULL) {
      if (access(filename, F_OK) == 0) {
         err = send_data(FILE_CP, filename);
      } else {
         err = -1;
      }
   }
   ops_done(err, GETTING, binflag);

   return;
}

//
//   ACTION is "get-collection"
//
void cgi_collection_send(int argc, char **argv)
{

char collection_str[] = "collection\0";
char file_str[] = "file\0";
char type_str[] = "type\0";

char *filename, *ftype, *collection;
int err, binflag;

   binflag = err = 0;
   filename = NULL;

   collection = find_value_in_arglist(collection_str, argv, argc);
   ftype = find_value_in_arglist(type_str, argv, argc);

   if (collection != NULL) {
      filename = build_collection_path(collection, 0);
   }

   if ( ftype != NULL ) {
      if (streq(ftype, "binary")) {
         binflag = 1;
      }
   }

   ops_out(COLLECTION_CP, GETTING, filename, collection, binflag);
   if (filename != NULL) {
      if (access(filename, F_OK) == 0) {
         err = send_data(COLLECTION_CP, filename);
      } else {
         err = -1;
      }
   }
   ops_done(err, GETTING, binflag);

   return;
}
//
//   ACTION is "rm-file"
//
void cgi_file_delete(int argc, char **argv)
{

char file_str[] = "file\0";

char *filename;
int err;

   err = -1;
   filename = NULL;

   filename = find_value_in_arglist(file_str, argv, argc);

   ops_out(FILE_CP, MYDELETE, filename, filename, 0);
   if (filename != NULL) {
      if (access(filename, F_OK) == 0) {
         err = delete_data(FILE_CP, filename, NULL);
      }
   }
   ops_done(err, MYDELETE, 0);

   return;
}

//
//   ACTION is "check-file-exists"
//
void cgi_file_exists(int argc, char **argv)
{

char file_str[] = "file\0";

char *filename;
int doesit;

   doesit = -1;
   filename = NULL;

   filename = find_value_in_arglist(file_str, argv, argc);

   ops_out(FILE_CP, EXISTS, filename, filename, 0);
   if (filename != NULL) {
      doesit = collection_exists_check(FILE_CP, filename);
   }
   ops_done(doesit, EXISTS, 0);

   return;
}

//
//   ACTION is "query-service-status"
//
void cgi_query_service_status(int argc, char **argv)
{

char *filename;
int err;

#ifdef PLATFORM_WINDOWS
   filename = get_install_dir("\\data\\query-service-run.xml\0");
#else
   filename = get_install_dir("/data/query-service-run.xml\0");
#endif

   ops_out(-1, STATUS, filename, filename, 0);
   err = setup_status(filename, 1);
   ops_done(err, STATUS, 0);

   return;
}

//
//   ACTION is "get-status"
//
void cgi_collection_status(int argc, char **argv)
{
char collection_str[] = "collection\0";

char *filename, *collection;
int err;

   collection = find_value_in_arglist(collection_str, argv, argc);

   if (collection != NULL) {
      filename = build_collection_path(collection, 0);
   }

   ops_out(-1, STATUS, filename, collection, 0);
   err = setup_status(collection, 0);
   ops_done(err, STATUS, 0);

   return;
}

//
//   ACTION is GET_CURRENT_RSS for a given pid
//
void cgi_pid_memory(int argc, char **argv)
{
char pid_str[] = "pid\0";

char *pid;

   pid = find_value_in_arglist(pid_str, argv, argc);

   GetProcessRSSOut(pid);

   return;
}

//
//   ACTION is "check-collection-exists"
//
void cgi_collection_exists(int argc, char **argv)
{
char collection_str[] = "collection\0";

char *collection, *filename;
int doesit;

   doesit = -1;
   collection = filename = NULL;

   collection = find_value_in_arglist(collection_str, argv, argc);
   if (collection != NULL) {
      filename = build_collection_path(collection, 0);
   }

   ops_out(FILE_CP, EXISTS, filename, collection, 0);
   if (filename != NULL) {
      doesit = collection_exists_check(FILE_CP, filename);
   }
   ops_done(doesit, EXISTS, 0);

   return;
}
//
//   ACTION is "stop-index", "stop-crawler", "stop-crindex"
//
void cgi_do_crawler_indexer_kills(int argc, char **argv, int which)
{
char collection_str[] = "collection\0";

char *collection;
int err;

   collection = find_value_in_arglist(collection_str, argv, argc);

   ops_out(-1, KILL, collection, collection, 0);
   switch (which) {
      case CRAWLER:
         err = kill_crawler(collection);
         break;
      case INDEXER:
         err = kill_index(collection);
         break;
      default:
         err = kill_crindex(collection);
         break;
   }
   ops_done(err, KILL, 0);

   return;
}

//
//   ACTION is "kill-service-kids"
//
void cgi_do_service_kills(int argc, char **argv)
{

char service_str[] = "service\0";
char collection_str[] = "collection\0";
char filename_str[] = "filename\0";
char ppid_str[] = "ppid\0";

char *service_name, *collection, *filename, *ppidarg;
int service, ppid, err;

   service_name = find_value_in_arglist(service_str, argv, argc);
   service =  service_int(service_name);

   collection = filename = NULL;

   switch (service) {
      case QUERY:
#ifdef PLATFORM_WINDOWS
         filename = get_install_dir("\\data\\query-service-run.xml\0");
#else
         filename = get_install_dir("/data/query-service-run.xml\0");
#endif
         break;
      case CBROKER:
#ifdef PLATFORM_WINDOWS
         filename = get_install_dir("\\data\\collection-broker.xml.run\0");
#else
         filename = get_install_dir("/data/collection-broker.xml.run\0");
#endif
         break;
      case COLLECTION_SERVICE:
         collection = find_value_in_arglist(collection_str, argv, argc);
         if (collection != NULL) {
            filename = build_collection_path(collection, 3);
         }
         break;
      default:
         collection = find_value_in_arglist(collection_str, argv, argc);
         if (collection != NULL) {
            filename = build_collection_path(collection, 0);
         }
         break;
   }

   ppidarg = find_value_in_arglist(ppid_str, argv, argc);
   if ( ppidarg != NULL ) {
      ppid = atoi(ppidarg);
   } else {
      ppid = -1;
   }

   if (filename != NULL) {
      ops_out(-1, KILL, filename, collection, 0);
      err = kill_service_children(filename, service, ppid);
      ops_done(err, KILL, 0);
   } else {
      ops_out(-1, KILL, "NO-FILE-FOUND", collection, 0);
      ops_done(-1, KILL, 0);
   }

   return;
}

int mess_with_repo_setup(int what, int argc, char **argv)
{
int larg = 0;
int from, binflag, err;
char *importfile, *repositoryfile;

   err = from = binflag = 0;

   repositoryfile = vivisimo_env_config_values[REPOSITORY];
//#ifdef PLATFORM_WINDOWS
//   repositoryfile = get_install_dir("\\data\\repository.xml\0");
//#else
//   repositoryfile = get_install_dir("/data/repository.xml\0");
//#endif

   while (larg < argc) {
      if (streq(argv[larg], "importfile\0")) {
         larg++;
         if (larg < argc) {
            importfile = argv[larg];
            from = REPO;
         }
      }
      larg++;
   }

   switch (what) {
      case REPOIMPORT:
                     ops_out(from, what, importfile, repositoryfile, binflag);
                     err = test_import(importfile, repositoryfile);
                     ops_done(err, what, binflag);
                     break;
      default:
                     break;
   }

   return(0);
}

