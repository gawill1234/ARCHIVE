#include <stdio.h>

#include "test_clnt_srv.h"

extern int do_verify, Gquit;

/**************************************************************/
/*  PROCESS_CONFIG

    Take a configuration command to the server and execute
    the appropriate configuration change.

    PARAMETERS:
       fd:          socket descriptor
       command:     config change command
       param_1:     reserved
       param_2:     reserved

    RETURN:
       Returns nothing.
*/
void process_config(fd, command, param_1, param_2)
int fd;
word command, param_1, param_2;
{

   switch (command & CNF_MASK) {
      case CNF_PASS:
                change_pass_msg();
                break;

      case CNF_FAIL:
                change_fail_msg();
                break;

      case CNF_VERBOSE:
                change_msg_verbosity();
                break;

      case CNF_TIMING:
                break;

      case CNF_VERIFY:
                change_verify();
                break;

      default:
                fprintf(stderr, "Invalid config change requested - skipping\n");
                break;
   }
   return;
}
/**************************************************************/
/*  PROCESS_CMDS

    Take a commands passed to the server and execute

    PARAMETERS:
       fd:          socket descriptor
       command:     server command
       param_1:     varies with command
       param_2:     varies with command

    RETURN:
       Returns nothing.

*/
void process_cmds(fd, command, param_1, param_2)
int fd;
word command, param_1, param_2;
{

   switch (command & CMD_MASK) {
      case CMD_EXIT:
                fprintf(stderr, "process_cmds():  Exiting by command\n");
                Gquit = 1;
                break;

      case CMD_HEXIT:
                fprintf(stderr, "process_cmds():  Exiting by command\n");
                close(fd);
                _exit(0);
                break;

      case CMD_BLK_SZ:
                /*
                 *   param_1:    new send buffer size.
                 *   param_2:    new receive buffer size.
                 */
                new_buffer_size(fd, param_1, param_2);
                break;
      case CMD_TM_SYNC:
                r_sync_time(fd, param_1, param_2);
                break;

      default:
                fprintf(stderr, "Invalid command issued - skipping\n");
                break;
   }
   return;
}
