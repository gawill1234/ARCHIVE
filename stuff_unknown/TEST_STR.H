#ifndef _H_TEST_STRUCT
#define _H_TEST_STRUCT

#include <sys/types.h>

#include "test.h"

#if defined(__SPANS)
#include <fore/types.h>
#include <fore_atm/fore_msg.h>
#include <fore_atm/fore_atm_user.h>
#endif

struct randomstruct {
    long sequence;
    long used;
    long number;
    long seekamt;
};

#if defined(__SPANS)
struct multicast_endpoint {
    char         *ep_name;  /* end-point name */
    Atm_endpoint ep_addr;       /* ASAP and NSAP */
};
#endif

#endif
