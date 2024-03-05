#ifndef _H_INET
#define _H_INET

#include <stdio.h>
#include <fcntl.h>
#include <tiuser.h>
#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "test.h"

#ifdef AIX
#define DEV_UDP  "/dev/xti/udp"
#define DEV_TCP  "/dev/xti/tcp"
#else
#define DEV_UDP  "/dev/udp"
#define DEV_TCP  "/dev/tcp"
#endif

#define SERV_UDP_PORT  6542
#define SERV_TCP_PORT  6643

#define TCP_CONTROL_PORT 6742
#define UDP_CONTROL_PORT 6842

#define REXEC_TMP_PORT 9000

#define MAXLINE 255
#define TIMEOUT 90

#endif
