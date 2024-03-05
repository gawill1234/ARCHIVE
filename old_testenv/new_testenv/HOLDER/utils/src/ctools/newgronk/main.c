#include "myincludes.h"

int main(int argc, char **argv)
{
   char *query;
   char **args;
   int i = 0;

#ifdef PLATFORM_WINDOWS
   setmode(0, O_BINARY); /* stdin */
   setmode(1, O_BINARY); /* stdout */
#endif

   viv_conf_init();

   query = get_query();
   args = split_query(query);

   while (args[i] != NULL) {
      i++;
   }
   if (args[0] != NULL) {
      if (streq(args[0], "installed-dir")) {
	 do_install_dir(INSTALL_DIR);
      } else if (streq(args[0], "repository")) {
	 do_install_dir(REPOSITORY);
      } else if (streq(args[0], "tmp-dir")) {
	 do_install_dir(TMP_DIR);
      } else if (streq(args[0], "users-file")) {
	 do_install_dir(USERS_FILE);
      } else if (streq(args[0], "default-project")) {
	 do_install_dir(DEFAULT_PROJECT);
      } else if (streq(args[0], "search-collections-dir")) {
	 do_install_dir(SEARCH_COLLECTIONS_DIR);
      } else if (streq(args[0], "repository-dir")) {
	 do_install_dir(REPOSITORY_DIR);
      } else if (streq(args[0], "repository-import")) {
	 mess_with_repo_setup(REPOIMPORT, i, args);
      } else if (streq(args[0], "restore-default")) {
	 restore_default_state();
      } else if (streq(args[0], "find-collection-core")) {
	 cgi_do_find(i, args, 1);
      } else if (streq(args[0], "find-cgi-core")) {
	 cgi_do_find(i, args, 2);
      } else if (streq(args[0], "find-core")) {
	 cgi_do_find(i, args, 3);
      } else if (streq(args[0], "get-pid-list")) {
	 cgi_get_pid_list(i, args);
      } else if (streq(args[0], "get-fs-mb-free")) {
	 cgi_file_system_free(i, args, 0);
      } else if (streq(args[0], "get-fs-gb-free")) {
	 cgi_file_system_free(i, args, 1);
      } else if (streq(args[0], "get-crawl-dir")) {
	 cgi_do_crawl_dir(i, args);
      } else if (streq(args[0], "restore-collection")) {
	 cgi_restore_collection(i, args);
      } else if (streq(args[0], "query-service-status")) {
	 cgi_query_service_status(i, args);
      } else if (streq(args[0], "check-collection-exists")) {
	 cgi_collection_exists(i, args);
      } else if (streq(args[0], "check-file-exists")) {
	 cgi_file_exists(i, args);
      } else if (streq(args[0], "file-size")) {
	 cgi_file_size(i, args);
      } else if (streq(args[0], "file-time")) {
	 cgi_file_time(i, args);
      } else if (streq(args[0], "send-file")) {
	 cgi_file_get(i, args);
      } else if (streq(args[0], "send-collection")) {
	 cgi_collection_get(i, args);
      } else if (streq(args[0], "get-file")) {
	 cgi_file_send(i, args);
      } else if (streq(args[0], "get-collection-list")) {
	 cgi_collection_list(i, args);
      } else if (streq(args[0], "get-collection")) {
	 cgi_collection_send(i, args);
      } else if (streq(args[0], "rm-file")) {
	 cgi_file_delete(i, args);
      } else if (streq(args[0], "rm-collection")) {
	 cgi_collection_delete(i, args);
      } else if (streq(args[0], "alter-file")) {
	 cgi_file_alter(i, args);
      } else if (streq(args[0], "alter-collection")) {
	 cgi_collection_alter(i, args);
      } else if (streq(args[0], "execute")) {
	 cgi_execute_command(i, args);
      } else if (streq(args[0], "get-status")) {
	 cgi_collection_status(i, args);
      } else if (streq(args[0], "stop-crawler")) {
	 cgi_do_crawler_indexer_kills(i, args, CRAWLER);
      } else if (streq(args[0], "stop-index")) {
	 cgi_do_crawler_indexer_kills(i, args, INDEXER);
      } else if (streq(args[0], "stop-crindex")) {
	 cgi_do_crawler_indexer_kills(i, args, CRAWLER_AND_INDEXER);
      } else if (streq(args[0], "kill-service-kids")) {
	 cgi_do_service_kills(i, args);
      } else if (streq(args[0], "kill-all-services")) {
	 cgi_kill_all_services(i, args);
      } else if (streq(args[0], "velocity-shutdown")) {
	 cgi_velocity_shutdown(i, args);
      } else if (streq(args[0], "kill-query-services")) {
	 cgi_kill_query_services(i, args);
      } else if (streq(args[0], "kill-admin")) {
	 cgi_kill_admin(i, args);
      } else if (streq(args[0], "process-memory")) {
	 cgi_pid_memory(i, args);
      } else {
	 printf("%sUnknown action '%s'\n\n", content, args[0]);
	 for (i=0; args[i] != NULL; i++) {
	    printf("    args[%d] = '%s'\n", i, args[i]);
	 }
      }
   } else {
      do_install_dir(INSTALL_DIR);
   }

   exit(0);
}
