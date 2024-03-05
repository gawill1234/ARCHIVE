#include <stdlib.h>

#ifdef PLATFORM_WINDOWS
char *servicearray[] = {"admin.exe\0",
                        "crawler-service.exe\0",
                        "indexer-service.exe\0",
                        "crawlerandindexerdummy\0",
                        "query-service.exe\0",
                        "ppidsupplieddummy\0",
                        "collection-service.exe\0",
                        "execute-worker.exe\0",
                        "collection-service-dispatch.exe\0",
                        "java.exe\0",
                        "collection-service.exe\0",
                        "query-service.exe\0",
                        "scheduler-service.exe\0",
                        "alert-service.exe\0",
                        "source-test-service.exe\0",
                        "report-service.exe\0",
                        "dispatch.exe\0",
                        "collection-broker.exe\0",
                        "velocity.exe\0"};
#else
char *servicearray[] = {"admin\0",
                        "crawler-service\0",
                        "indexer-service\0",
                        "crawlerandindexerdummy\0",
                        "query-service\0",
                        "ppidsupplieddummy\0",
                        "collection-service\0",
                        "execute-worker\0",
                        "collection-service-dispatch\0",
                        "java\0",
                        "collection-service\0",
                        "query-service\0",
                        "scheduler-service\0",
                        "alert-service\0",
                        "source-test-service\0",
                        "report-service\0",
                        "dispatch\0",
                        "collection-broker\0",
                        "velocity\0"};
#endif

int vivconfvaluecount = 15;

char *vivconfvalues[] = {"install-dir\0",
                         "search-collections-dir\0",
                         "vivisimo-conf\0",
                         "tmp-dir\0",
                         "debug-dir\0",
                         "repository\0",
                         "users-file\0",
                         "users-dir-file\0",
                         "users-dir\0",
                         "default-project\0",
                         "brand-file\0",
                         "authentication-macro\0",
                         "admin-authentication-macro\0",
                         "base-url\0",
                         "cookie-path\0",
                         "reporting-dir\0",
                         "system-reporting-dir\0",
                         "meta.cache-dir\0",
                         "cleaner.frequency\0",
                         "cleaner.file-limit\0",
                         "cleaner.access-time\0",
                         "cleaner.create-time\0"};

char *vivisimo_env_config_values[] = {NULL, 
                                      NULL, 
                                      NULL, 
                                      NULL, 
                                      NULL,
                                      NULL, 
                                      NULL, 
                                      NULL, 
                                      NULL, 
                                      NULL,
                                      NULL, 
                                      NULL, 
                                      NULL, 
                                      NULL, 
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL,
                                      NULL};
 

//
//   html header line.
//
char content[] = "Content-type: text/plain; charset=utf-8\n\n\0";

//
//   A savespace for instances where we need to
//   save an old piece of read buffer to use with
//   a new piece.  I guess I could have just used
//   two alternating read buffers ...
//
char *savespace = NULL;
