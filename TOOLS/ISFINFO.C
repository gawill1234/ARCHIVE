static char USMID[] = "@(#)cuts/src/cmd/ifsinfo.c	80.0	08/05/92 16:25:03";

/*
 *  (c) Copyright Cray Research, Inc.  Unpublished Proprietary Information.
 *  All Rights Reserved.
 */
/******************************************************************************
******************************************************************************
*
*
*   UNICOS Testing  -  Cray Research, Inc.  Mendota Heights, Minnesota
*
*   NAME	:  ifsinfo - Queries C1 file sytem super blocks and inode blocks.
*
*   AUTHOR          :  David D. Fenner  
*
*   CO-PILOT        :  Jon Hendrickson
*
*   DATE STARTED    :  02/22/90 
*
*   SYNOPSIS
*
*       ifsinfo [ -aAbBcCdDfFhmPqRsStTuUvVz ] filesystem
*       ifsinfo [ -i # ] filesystem
*       ifsinfo [ -I # ] filesystem
*       ifsinfo [ -p # ] filesystem
*
*       Options:
*
*	-a           Device Accounting Type
*	-A           Super-block Summary Totals
*	-b           Total File Byte Size For BIGFILE Classification
*	-B           Minimum Blocks Allocated For BIGFILE Classification
*	-c           Security Compartment Bit Values
*       -C           Security Compartment ASCII Values
*	-d           Dump Super-block, Partition, and Inode Region information
*	-D           Dump just Super-block 
*	-f           Total Free Sector Blocks
*	-F           Total Free Inodes
*	-h           Usage Clause
*	-i integer   File System Inode Region Number (verbose mode)
*	-I integer   File System File Inode Starting Block Number (verbose mode)
*       -m           Total Free Bitmap Blocks
*       -M           Display Free Bitmap Blocks
*       -n           File System Pack Name
*	-p integer   File System Partition Number
*       -P           Total Number of Partitions
*       -q           Query and identify block types (i.e bitmap vs inode)
*       -R           Ratios of Inodes to Blocks
*       -s           Minimum Security Level
*       -S           Maximum Security Level
*	-t           Total Allocated Inodes
*	-T           Total Available Inodes
*       -u           Last Super-block update in seconds
*       -U           Last Super-block update in HH:MM:SS
*       -v           Verbose Output
*       -V           Total Volume Available Blocks
*       -z           Determines if intra-partition super blocks are in sync
*                    (i.e. 10 copies per partition)
*       -Z           Determines if all partition dynamic blocks are in sync
*                    (i.e. 1 copy per partition)
*
*   ENVIRONMENTAL NEEDS
*
*       Must be super user to execute program. ifsinfo.c can only be run on 
*       (CX/1 and CEA) UNICOS 6.0 improved inode file system structures.
*
*   SPECIAL PROCEDURAL REQUIREMENTS
*
*      None.
*
*   OUTPUT
*
*       An error message will be written to standard error for the following
*       conditions.
*
*          If an invalid option or an invalid option argument is received.
*
*          If file system is not a block device or can't be read, or is not an 
*          improved inode file system.
*
*          If -p option argument value exceeds the number of available file
*          system partitions or is less han the number of available file system
*          partitions.
*
*          If -i option argument value exceeds the number of available file 
*          system partition inode regions or is less than the number of
*          available file system partition inode  regions.
*
*          If the -I option argument value exceeds the number of available
*          inode region inode blocks or is less than the number of available
*          inode region inode blocks. 
*
*          If -U option  processing incurs a ctime library routine error.
*
*          If a read(2) or lseek(2) system call error is incurred when 
*          processing system call error is incurred when processing filesystem.
*
*          If -h option entered and will write to standard error ifsinfo's
*          usage clause.
*
*       Otherwise, ifsinfo will write to standard output ASCII values
*       indicative of the information provided by the option(s) selected.  The
*       only special considerations are the -C,-d,-i,-I, and -p options.  The -C
*       option will have the NULL (octal 0) character written to standard 
*       output if no security compartments have been assigned.  The -C option in
*       verbose mode will have the token NULL written with a description if no 
*       security compartments have been assigned.  The -d option will result in
*       all super-block, inode region, and inode structure values written in a
*       verbose manner.  The -i option will always write in a verbose format 
*       an ASCII representation of all inode structures contained within inode
*       blocks within an inode region.  This can be a voluminous data stream
*       to standard output.  The -I option will always write in a verbose
*       format an ASCII representation of inode structures contained within a
*       particular inode block within an inode region.  Up to sixteen inode
*       structure representations maybe written to standard output.  No options
*       result in a verbose format standard output for the -A,-b,-B,-c,-C,-f,-F
*       ,-P, -s, -S, -t,-T,-V options.  Lastly, the -p option with no other
*       options will result in the -d option output being written.
*
*   EXIT VALUES
*
*       Whenever ifsinfo writes to standard error (produces error messages) or
*       echos a usage statement, exits with a value of one.
*
*   USER DESCRIPTION
*
*       ifsinfo's intended purpose is to query a (CX/1 and CEA) improved
*       inode file system super-block structure in UNICOS 6.0.  It can be
*       utilized to access each partition's super-block and/or inode region.
*       ifsinfo is conducive for command substitution within a shell program.
*
*   DETAILED DESCRIPTION
*
*   Process all command line options and arguments by setting a corresponding
*   bit within an information variable of type integer.
*
*   Report any invalid options or arguments received and exit with a status of
*   one.
*
*   If no option or argument error
*      If -h bit is set
*        Print to standard out the ifsinfo synopsis and exit with a one
*        value
*      Else
*         While the information variable is not zero.
*         do
*              Process the bit settings within the information variable and set
*              the corresponding bit to zero.
*         done
*
*   Exit with an appropriate value.
*
******************************************************************************/
#include <stdio.h> 
#include <ctype.h>                /* isdigit routine */
#include <fcntl.h> 
#include <sys/unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>             /* ctime routine */
#include <sys/param.h>
#include <sys/map.h>
#include <sys/inode.h>
#include <sys/fs/nc1ino.h>
#include <sys/fs/nc1inode.h>
#include <sys/fs/nc1filsys.h>
#include <sys/secparm.h>

/* Super Block Description Tags */

#define FSNAME "File System Name"
#define PKNAME "File System Pack Name"
#define FLGWRD "File System Flags"
#define VOLSZE "Volume Size in Blocks"
#define SECBLK "Total Free Sector Blocks"
#define MAPCNT "Total Free Bitmap Blocks"
#define TOTINO "Total Number of Inodes"
#define FREINO "Total Number of Free Inodes"
#define ALLINO "Total Allocated Inodes"
#define BIGFIL "Total Bytes Before BIG FILE"
#define BIGUNT "Min Number of BLKS For BIG FILE" 
#define ACTTYP "Device Accounting Type"
#define SECFIL "Security File System"
#define MAXLVL "Maximum Security Level"
#define MINLVL "Minimum Security Level"
#define SECCPT "Security Compartment"
#define SECNUL "NULL Security Compartment Values"
#define SECDES "Assigned Security Compartment"
#define PROCLK "Proc of Process Locking Super-block"
#define SUPCHG "Last Super-block Update Time"
#define FSSTAT "File System State"
#define FSTYPE "File System Type"
#define MAPSTR "Start Map Block Number"
#define MAPBLK "Last Map Block Number"
#define ALLPTR "Allocation pointer"
#define TOTPAR "Total Number of Partitions"
#define MNTPAR "Partition from which system mounted"
#define RATIOS "Ratio of Inodes to Blocks"
#define FDNAME "Physical Device Name"
#define FDFLAG "Physical Device Flag Word"
#define FDSTRT "Physical Device Start Block Number"
#define FDBLKS "Physical Device Number of Blocks"
#define INOSTR "Start Block Number"
#define INOBLK "Number of Blocks"
#define INOAVL "Available Inode Count"
#define MAGICS "File System Magic Number"
#define INSYNC "INSYNC"
#define NOTINSYNC "NOTINSYNC"
#define IOUNIT "Physical Block Size"
#define IRBPR  "Number of Inode Reservation Blocks Per Region"
#define BOPP "Bitmap of Primary Partitions"
#define BSPP "Block Allocation Unit Size of Primary Partition(s)"
#define WINP "Number of 512 wds Blocks in Primary"
#define BOSP "Bitmap of Secondary Partitions"
#define BSSP "Block Allocation Size of Secondary Partition(s)"
#define WISP "Number of 512 wds Blocks in Secondary"
#define BOPFSD "Bitmap of Partitions with File System Data"
#define BPRD "Bitmap of Partitions with Root Directory"
#define BNUDP "Bitmap of no-user-data partitions"
#define IRBMBLKS "Number of Inode Region bitmap blocks"


/* Inode Structure Description TAGS */

#define IMAGIC    "Inode Magic Number"
#define IMODE     "Mode And Type Of File"
#define IGEN      "Inode Generation Number"
#define INLINK    "Number Of File Links"
#define IUID      "Owner User Id"
#define IGID      "Owner Group Id"
#define IACID     "Disk File Account ID"
#define IMSREF    "Modification Signature Is Referenced"
#define IMS       "Modification Signature"
#define ISIZE     "Number Of Bytes In File"
#define ISLEVEL   "Security Level"
#define IMINLVL   "Device Minimum Security Level"
#define IMAXLVL   "Device Maximum Security Level"
#define IACLDSK   "ACL Security Inode Number"
#define ISECOMP   "Security Compartments"
#define ISECURE   "Security Reserved Area" 
#define ISECFLG   "Security Flag Settings"
#define IINTCLS   "Security Integrity Class"
#define IINTCAT   "Security Integrity Category"
#define ICBITS    "Allocation Control Bits"
#define ICPARTS   "Next Partition From cbits to Use"
#define ICBLKS    "Number of Blocks To Allocate Per Part"
#define IMACHID   "Offline File Machine Id"
#define IOFILENM  "Offline File Number"
#define IBLOCKS   "Number Of Physical Blocks Assigned"
#define IATIME    "Time Last Accessed in seconds"
#define IMTIME    "Time Last Modified in seconds"
#define ICTIME    "Time Last Changed in seconds"
#define IATIMEN   "Time Last Accessed in nanoseconds"
#define IMTIMEN   "Time Last Modified in nanoseconds"
#define ICTIMEN   "Time Last Changed in  nanoseconds"
#define IDADDR    "Disk Block Address"
#define IDASTR    "Data Block Starting Address"
#define IDANBR    "Number of Data Blocks"
#define IMOFF     "Modification offset for current signature"
#define IQBLKS    "Blocks allocated for quotas"
#define ISECEXT   "Extended Security Compartments Flag"
#define IPERMB    "Security Permissions inherited at exec time"
#define ISITEB    "Site Specific Bit Settings"
#define IVALCOMP  "Valid Security Compartments"
#define IDMKEY    "Data Migration Key"
#define IDBLKEXT  "Cray-1, X/YMP extent-based allocation technique"
#define IDBLKSEC  "Cray-2, sector/track block-style allocation technique"
#define IDMMACH   "Data Migration machine ID"
#define IPHYDEV   "Physical Disk Type"
#define ISLICE    "Slice Length in Blocks"
#define IABSBLK   "Absolute Starting Block Number"
#define IFLAGS    "File Flags"
#define ICLUST    "Cluster/IOS/CHN/CU/Unit"
#define IFILEN    "Filename of Logical Description File"
#define IALLOCF1  "Allocation Is Not Allowed To Grow"
#define IALLOCF2  "Allocation Of Partition Type Only"
#define ISLOCK    "SFS Lock Structure"


/* Program Option Defines */

#define ACCTYPE          01  /* -a option bit mask */
#define ACCTALL          02  /* -A option bit mask */
#define TBYTES           04  /* -b option bit mask */
#define TSECBLKS        010  /* -B option bit mask */
#define SECBITS         020  /* -c option bit mask */
#define SECASCII        040  /* -C option bit mask */
#define DUMPALL        0100  /* -d option bit mask */
#define DUMPSBLK       0200  /* -D option bit mask */
#define FBLKS          0400  /* -f option bit mask */
#define FINODES       01000  /* -F option bit mask */
#define TBMBLKS       02000  /* -m option bit mask */
#define PARTNUM       04000  /* -p option bit mask */
#define TPARTS       010000  /* -P option bit mask */
#define RATIO        020000  /* -R option bit mask */
#define MINSEC       040000  /* -s option bit mask */
#define MAXSEC      0100000  /* -S option bit mask */
#define ALCINODES   0200000  /* -t option bit mask */
#define AVLINODES   0400000  /* -T option bit mask */
#define SUPSEC     01000000  /* -u option bit mask */
#define SUPHMS     02000000  /* -U option bit mask */
#define INOREG     04000000  /* -i option bit mask */
#define STRBLK    010000000  /* -I option bit mask */
#define VERBOSE   020000000  /* -v option bit mask */
#define VOLSIZ    040000000  /* -V option bit mask */
#define SSYNC    0100000000  /* -z option bit mask */
#define PDPNAME  0200000000  /* -n option bit mask */
#define DSYNC    0400000000  /* -Z option bit mask */
#define QUERY   01000000000  /* -q option bit mask */
#define DBMBLKS 02000000000  /* -M option bit mask */
#define NOOPTIONS 060751476  /* -A,b,B,c,C,f,F,P,s,S,t,T,v,V options mask */

#define NC1MAPBLKS(fp) ((fp->s_priblock+1)*(fp->s_numiresblks+1))

/*  Remaining Defines */

#define OPTIONS "aAbBcCdDfFhmMnPqRsStTuUvVzZp:r:i:I:"

/*  Relative inumber starting values for inode regions and partitions */
/*     This is handled by the least significant 32 bits within a word */
        /*   The ordering of these bits is as follows. */
        /*   Bit positions 25 - 32 are for partition number */
        /*   Bit positions 21 - 24 are for inode region number */
        /*   Bit positions 1  - 20 are for relative offsets */

int iregs[4] = {
          0,         /* Inode Region number one */
   04000000,         /* Inode Region number two */
  010000000,         /* Inode Region number three */
 0140000000 };       /* Inode Region number four */

int pnums[64] = {
            0,       /*  Partition number one */
   0100000000,       /*  Partition number two */
   0200000000,
   0300000000,
   0400000000,
   0500000000,
   0600000000,
   0700000000,
  01000000000,
  01100000000,
  01200000000, 
  01300000000, 
  01400000000, 
  01500000000,
  01600000000,
  01700000000,
  02000000000, 
  02100000000,
  02200000000, 
  02300000000,
  02400000000,
  02500000000,
  02600000000,
  02700000000,
  03000000000,
  03100000000,
  03200000000,
  03300000000,
  03400000000,
  03500000000,
  03600000000,
  03700000000,
  04000000000,
  04100000000,
  04200000000,
  04300000000,
  04400000000,
  04500000000,
  04600000000,
  04700000000,
  05000000000,
  05100000000,
  05200000000,
  05300000000,
  05400000000,
  05500000000,
  05600000000,
  05700000000,
  06000000000,
  06100000000,
  06200000000,
  06300000000,
  06400000000,
  06500000000,
  06600000000,
  06700000000,
  07000000000,
  07100000000,
  07200000000,
  07300000000,
  07400000000,
  07500000000,
  07600000000,          /*  Partition number sixty three */
  07700000000 };        /*  Partition number sixty four */

/* Global Variables */
int partnumber=0;    /* To be reassigned when using -p option */
int iregnumber=0;    /* To be reassigned when using -i option */
int iblknumber=1;    /* To be reassigned when using -I option */
int query_blktype=0; /* To be reassigned when using -q option */
int start_block=0;
int beg_inode_block, end_inode_block;
long *map;           /* To be assigned when using -m option */
long device_offset=0;
char msg[256];       /* Message Reporting */
char *logical_device_name;
char *pg;            /* For name of this program */

struct free_block_locations   /* For -M option */
{
  int partition_number;
  int allocation_unit_size;
  int beg_blk_index;
  int end_blk_index;
  long phy_dev_nam;
  int part_bit_starting_location;
  int starting_location;
  int contiguous_followers;
  struct free_block_locations *next;
};

struct free_block_locations *list_start, *list_end;
 
main(argc,argv)
int argc;
char **argv;
{
   int c, fd, option_flg=0, exit_val;
   extern char *optarg;
   extern int optind;
 
   pg = argv[0];
   while ((c = getopt(argc, argv, OPTIONS)) != EOF)
   {
       switch (c)    /*  Process Command Line option and option arguments */
       {
            case 'a':
                    option_flg |= ACCTYPE;
                    break;
            case 'A':
                    option_flg |= ACCTALL;
                    break;
            case 'b':
                    option_flg |= TBYTES;
                    break;
            case 'B':
                    option_flg |= TSECBLKS;
                    break;
            case 'c':
                    option_flg |= SECBITS;
                    break;
            case 'C':
                    option_flg |= SECASCII;
                    break;
            case 'd':
                    option_flg |= DUMPALL;
                    break;
            case 'D':
                    option_flg |= DUMPSBLK;
                    break;
            case 'f':
                    option_flg |= FBLKS;
                    break;
            case 'F':
                    option_flg |= FINODES;
                    break;
            case 'h':
                    usage();
                    break;
            case 'i':     /*  Validate option arguments */
                    if ( is_non_numeric_arg(optarg) != 0 )
                    {
                       fprintf(stderr, "\nERROR: -i %s argument must be a valid integer\n\n", optarg);
                       usage();
                    }
                    sscanf(optarg, "%d", &iregnumber);
                    if (iregnumber <= 0 )
                    {
                       fprintf(stderr, "\nERROR: -i %s cannot be <= 0 for inode regions\n\n", optarg, NC1MAXIREG);
                       usage();
                    }
                    else if (iregnumber > NC1MAXIREG)  /* Defined in c1filsys.h */
                    {
                       fprintf(stderr, "\nERROR: -i %s > %d MAXIMUM inode regions\n\n", optarg, NC1MAXIREG);
                       usage();
                    }
                    option_flg |= INOREG;
                    break;
            case 'I':  /*  Validate option arguments */
                    if ( is_non_numeric_arg(optarg) != 0 )
                    {
                       fprintf(stderr, "\nERROR: -I %s argument must be a valid integer\n\n", optarg);
                       usage();
                    }
                    sscanf(optarg, "%d", &iblknumber);
                    if (iblknumber <= 0)
                    {
                       fprintf(stderr, "\nERROR: -I %s argument cannot be <= 0 for Inode Block Number\n\n", optarg);
                       usage();
                    }
                    option_flg |= STRBLK;
                    break;
            case 'm':
                    option_flg |= TBMBLKS;
                    break;
            case 'M':
                    option_flg |= DBMBLKS;
                    list_start = NULL;
                    break;
            case 'n':
                    option_flg |= PDPNAME;
                    break;
            case 'p':
                    if ( is_non_numeric_arg(optarg) != 0 )
                    {
                       fprintf(stderr, "\nERROR: -p %s argument must be a valid integer\n\n", optarg);
                       usage();
                    }
                    sscanf(optarg, "%d", &partnumber);
                    if (partnumber <= 0 )
                    {
                       fprintf(stderr, "\nERROR: -p %s cannot be <= 0 for MAXIMUM Device Partitions\n\n", optarg, NC1MAXIREG);
                       usage();
                    }
                    else if (partnumber > NC1MAXPART)  /* Defined in c1filsys.h */
                    {
                       fprintf(stderr, "\nERROR: -p %s > %d MAXIMUM Device Partitions\n\n", optarg, NC1MAXPART);
                       usage();
                    }
                    option_flg |= PARTNUM;
                    break;
            case 'P':
                    option_flg |= TPARTS;
                    break;
            case 'q':
                    query_blktype |= QUERY;
                    option_flg |= QUERY;
                    break;
            case 'R':
                    option_flg |= RATIO;
                    break;
            case 's':
                    option_flg |= MINSEC;
                    break;
            case 'S':
                    option_flg |= MAXSEC;
                    break;
            case 't':
                    option_flg |= ALCINODES;
                    break;
            case 'T':
                    option_flg |= AVLINODES;
                    break;
            case 'u':
                    option_flg |= SUPSEC;
                    break;
            case 'U':
                    option_flg |= SUPHMS;
                    break;
            case 'v':
                    option_flg |= VERBOSE;
                    break;
            case 'V':
                    option_flg |= VOLSIZ;
                    break;
            case 'z':
                    option_flg |= SSYNC;
                    break;
            case 'Z':
                    option_flg |= DSYNC;
                    break;
            default:
                    usage();
                    break;
       }
   }
   if (argc == 1)
      usage();
   else if ( ! is_block_device(argv[argc-1]))
   {
      fprintf(stderr, "\nProblem determining block device status for %s\n", argv[argc-1]);
      usage();
   }
   else if (argc == 2)
      option_flg |= NOOPTIONS;
   /*
   *  Open block device, and away we goooooooooooooooo!
   */
   logical_device_name=argv[argc-1];
   if ((fd = open(logical_device_name, O_RDONLY)) == -1) 
   {
   
      sprintf(msg, "\nopen(2) ERROR : %s : %s:\n\n", pg, logical_device_name);
      perror(msg); 
      exit(1);
   }
   exit_val=process_options(fd, option_flg);
   if (close(fd) == -1)
   {
      sprintf(msg, "\nclose(2) ERROR : %s : %s:\n\n", pg, argv[argc-1]);
      perror(msg);
      exit(1);
   }
   exit(exit_val);
}

/*
*  Process entered or default options
*/

process_options(fd, options)
int fd;
int options;
{
   int flag=0;
   char *ctime();
   struct nc1filsys *fptr, *get_nc1_super_blocks();
   struct nc1dblock *dptr, *get_nc1_dynamic_block();

   if (options & QUERY)
      if ( ! (options & PARTNUM))
         flag++;

   if ((fptr=get_nc1_super_blocks(fd, BSIZE, flag)) == NULL)
      return(1);

   if (options & PARTNUM)  /*  Do we want to see a particular partition? */
   {
      options ^= PARTNUM;
      if (partnumber > fptr->s_npart)
      {
         fprintf(stderr, "\nERROR : Requested partition %d is > than # of file system partitions which are %d\n\n", partnumber, fptr->s_npart);
         return 1;
      }
      if (! get_l_to_r_bits(fptr->s_priparts, partnumber-1, 1))
      {
         fprintf(stderr, "\nERROR : Requested partition %d is a secondary partition and does not contain any super/dynamic block information\n", partnumber);
         return 1;
      }
      if ((fptr=get_nc1_super_blocks(fd,((fptr->s_part[partnumber-1].fd_sblk*BSIZE)+BSIZE),1)) == NULL)
         return 1;

      if (options == 0)   /*  If only -p option enter, process -d option*/
      {
         options |= DUMPALL;
         partnumber=0;
      }
   }
   if (options & QUERY) /* Let global be the detector and not option flag */
   {
      options ^= QUERY;
   }

   /*  Get dynamic block which is pointed to by super block element s_dboff */

   if ((dptr=get_nc1_dynamic_block(fd, (((fptr->s_dboff-1)*BSIZE)+device_offset), partnumber)) == NULL)
      return(1);

   /* Now, we are ready to really process some options */

   if (options & DUMPALL)
   {
      if (traverse_sblk(DUMPALL, fptr, dptr, fd) != 0)
          return 1;
   }
   if (options & DUMPSBLK)
   {
      if (traverse_sblk(DUMPSBLK, fptr, dptr, fd) != 0)
          return 1;
   }
   if (options & PDPNAME)
   {
      if (traverse_sblk(PDPNAME, fptr, dptr, fd) != 0)
          return 1;
   }
   if (options & ACCTYPE)
   {
      if (options & VERBOSE)
         fprintf(stdout, "%d is %s\n", dptr->db_actype, ACTTYP);
      else
         fprintf(stdout, "%d\n", dptr->db_actype);
   }
   if (options & TBYTES)
   {
      if (options & VERBOSE)
         fprintf(stdout, "%ld is %s\n", fptr->s_bigfile, BIGFIL);
      else
         fprintf(stdout, "%ld\n", fptr->s_bigfile);
   }
   if (options & TSECBLKS)
   {
      if (options & VERBOSE)
         fprintf(stdout, "%ld is %s\n", fptr->s_bigunit, BIGUNT);
      else
         fprintf(stdout, "%ld\n", fptr->s_bigunit);
   }
   if (options & TBMBLKS)
   {
      if (traverse_sblk(((TBMBLKS & options)|(VERBOSE & options)), fptr, dptr, fd) != 0)
         return 1;
   }
   if (options & DBMBLKS)
   {
      if (traverse_sblk(((DBMBLKS & options)|(VERBOSE & options)), fptr, dptr, fd) != 0)
         return 1;
   }
   if (options & SECBITS)
   {
      if (options & VERBOSE)
         fprintf(stdout,"%o is %s bit pattern\n",fptr->s_valcmp, SECCPT);
      else
         fprintf(stdout, "%o\n", fptr->s_valcmp);
   }
   if (options & SECASCII)
   {
       int ctr;
       char *comparts[MAXCOMPART];
       secnames(fptr->s_valcmp, comparts, 1);
       if (comparts[0] != NULL)
       {
          for (ctr=0; comparts[ctr] != NULL; ctr++)
          {
                 fprintf(stdout,"%s ",comparts[ctr]);
          }
          if (options & VERBOSE)
             fprintf(stdout,"is %s Value(s)\n", SECDES);
       }
       else if (options & VERBOSE)
          fprintf(stdout, "%s\n", SECNUL);
       else
          fprintf(stdout, "%c\n", '\0');
   }
   if (options & FBLKS)
   {
      if (options & VERBOSE)
         fprintf(stdout, "%d is %s\n", dptr->db_tfree, SECBLK);
      else
         fprintf(stdout, "%d\n", dptr->db_tfree);
   }
   if (options & FINODES)
   {
      if (options & VERBOSE)
         fprintf(stdout, "%d is %s\n", dptr->db_ifree, FREINO);
      else
         fprintf(stdout, "%d\n", dptr->db_ifree);
   }
   if (options & ALCINODES)
   {
      if (options & VERBOSE)
         fprintf(stdout, "%d is %s\n", dptr->db_ninode, ALLINO);
      else
         fprintf(stdout, "%d\n", dptr->db_ninode);
   }
   if (options & AVLINODES)
   {
      if (options & VERBOSE)
         fprintf(stdout, "%d is %s\n", fptr->s_isize, TOTINO);
      else
         fprintf(stdout, "%d\n", fptr->s_isize);
   }
   if (options & TPARTS)
   {
      if (options & VERBOSE)
         fprintf(stdout, "%d is %s\n", fptr->s_npart, TOTPAR);
      else
         fprintf(stdout, "%d\n", fptr->s_npart);
   }
   if (options & RATIO)
   {
      if (options & VERBOSE)
         fprintf(stdout, "%d is %s\n", fptr->s_ifract, RATIOS);
      else
         fprintf(stdout, "%d\n", fptr->s_ifract);
   }
   if (options & MAXSEC)
   {
      if (options & VERBOSE)
         fprintf(stdout, "%d is %s\n", fptr->s_maxlvl, MAXLVL);
      else
         fprintf(stdout, "%d\n", fptr->s_maxlvl);
   }
   if (options & MINSEC)
   {
      if (options & VERBOSE)
         fprintf(stdout, "%d is %s\n", fptr->s_minlvl, MINLVL);
      else
         fprintf(stdout, "%d\n", fptr->s_minlvl);
   }
   if (options & SUPSEC)
   {
      if (options & VERBOSE)
      {
         fprintf(stdout, "%d is %s in Seconds\n", fptr->s_time, SUPCHG);
      }
      else
      {
         fprintf(stdout, "%d\n", fptr->s_time);
      }
   }
   if (options & SUPHMS)
   {
      char sblktime[10];
      if (get_ascii_time(ctime(&fptr->s_time),sblktime) != 0)
      {
         fprintf(stderr, "\nERROR : ctime library routine returned %s\n\n", ctime(&fptr->s_time));
         return 1;
      }
      else if (options & VERBOSE)
         fprintf(stdout, "%s is %s\n", sblktime, SUPCHG);
      else
         fprintf(stdout, "%s\n", sblktime);
   }
   if (options & VOLSIZ)
   {
      if (options & VERBOSE)
         fprintf(stdout, "%d is %s\n", fptr->s_fsize, VOLSZE);
      else
         fprintf(stdout, "%d\n", fptr->s_fsize);
   }
   if (options & INOREG)
   {
      if (options & STRBLK)
      {
          options ^= STRBLK;
           if (traverse_sblk(INOREG|STRBLK, fptr, dptr, fd) != 0)
              return 1;
      } 
      else
      {
         if (traverse_sblk(INOREG, fptr, dptr, fd) != 0)
             return 1;
      }
   }
   if (options & STRBLK)
   {
      if (traverse_sblk(STRBLK, fptr, dptr, fd) != 0)
         return 1;
   }
   if (options & ACCTALL)
   {
      if (traverse_sblk(ACCTALL, fptr, dptr, fd) != 0)
         return 1;
   }
   if (options & SSYNC)
   {
      if (cmp_nc1_sblks(fptr, (NC1NSUPER-1)) != 0)
      {
         if (options & VERBOSE)
            fprintf(stdout, "%s means partitions superblocks are not identical\n", NOTINSYNC);
         else
            fprintf(stdout, "%s\n", NOTINSYNC);
      }
      else
      {
         if (options & VERBOSE)
            fprintf(stdout, "%s means partitions superblocks are identical\n", INSYNC);
         else
            fprintf(stdout, "%s\n", INSYNC);
      }
   }
   if (options & DSYNC)
   {
      int ret;

      if ((ret=cmp_nc1_dblks(fd)) == 0)
      {
         if (options & VERBOSE)
            fprintf(stdout, "%s means partitions dynamic blocks are not identical\n", NOTINSYNC);
         else
            fprintf(stdout, "%s\n", NOTINSYNC);
      }
      else if (ret == 1)
      {
         if (options & VERBOSE)
            fprintf(stdout, "%s means partitions dynamic blocks are identical\n", INSYNC);
         else
            fprintf(stdout, "%s\n", INSYNC);
      }
      else
         return(1);
   }
   return 0;
}

/*
* Routine for traversing dynamic list built for -M option request
* and printing free block locations along with contiguous blocks
* counts
*/
print_free_blocks(option, fptr)
int option;
struct nc1filsys *fptr;
{
   int times, part_number;
   struct free_block_locations *ptr;
   char *string1 = " Start    Count    ";
   char *string2 = "-------  ------- | ";

   if (option & VERBOSE)
   {
      fprintf(stdout, "\nFree block layout for: %s\n\n", logical_device_name);
      for(times=0; times < 4; times++)
         fprintf(stdout, "%s", string1);
      fprintf(stdout, "\n");
      for(times=0; times < 4; times++)
         fprintf(stdout, "%s", string2);
   }
   for (times=0,ptr=list_start, part_number=-1; ptr != NULL; ptr=ptr->next, times++)
   {
       if (ptr->partition_number != part_number)
       {
           fprintf(stdout, "\n\nPartition: %d  Blks: %d-%d  Dev: %s\n\n", ptr->partition_number, ptr->beg_blk_index, ptr->end_blk_index-1, &ptr->phy_dev_nam);
           part_number=ptr->partition_number;
           times = 0;
       }
       if (times == 4)
       {
          fprintf(stdout, "\n");
          times = 0;
       }
       if (ptr->starting_location && ptr->contiguous_followers)
          fprintf(stdout, "%7d  %7d | ", (((ptr->starting_location - ptr->part_bit_starting_location)* ptr->allocation_unit_size)+ptr->beg_blk_index), (ptr->contiguous_followers * ptr->allocation_unit_size));

   }
   fprintf(stdout, "\n");
   fflush(stdout);
}

get_l_to_r_bits(x, p, n)
unsigned x, p, n;
{
   return(((x << (p+1-n)) & ~((unsigned)~0 >> n)) >> ((sizeof(x)*8) -n));
}

do_bit_translations(x, y, z)
long x;
char *y;
char *z;
{
    int ctr;
    unsigned bit;

    for (ctr=0; ctr < (sizeof(x)*8); ctr++)
    {
        bit=get_l_to_r_bits(x, ctr, 1);
        if (bit)
           fprintf(stdout, "%s %d %s\n", y, ctr+1, z);
    }
}

/*
***********************
*  Traverse super-block
***********************
*/
traverse_sblk(option, fptr, dptr, fd)
int option;
struct nc1filsys *fptr;
struct nc1dblock *dptr;
int fd;
{
   int ctr, ctr1, tot_pblks, tot_palinos, tot_pfinos, tot_parts;
   int free_blocks, tot_free_blocks, traverse_bmap();
   uint instart, inblks, begino_val;

   if ((option & DUMPALL) || (option & DUMPSBLK))
   {
      fprintf(stdout, "%#o is %s\n", fptr->s_magic, MAGICS);
      fprintf(stdout, "%s is %s\n", fptr->s_fname, FSNAME);
      fprintf(stdout, "%s is %s\n", fptr->s_fpack, PKNAME);
      fprintf(stdout, "%#o is %s\n", (fptr->s_flag & 017), FLGWRD);
      fprintf(stdout, "%d is %s\n", fptr->s_fsize, VOLSZE);
      fprintf(stdout, "%d is %s\n", dptr->db_tfree, SECBLK);
      fprintf(stdout, "%d is %s\n", fptr->s_isize, TOTINO);
      fprintf(stdout, "%d is %s\n", dptr->db_ifree, FREINO);
      fprintf(stdout, "%d is %s\n", dptr->db_ninode, ALLINO);
      fprintf(stdout, "%ld is %s\n", fptr->s_bigfile, BIGFIL);
      fprintf(stdout, "%ld is %s\n", fptr->s_bigunit, BIGUNT);
      fprintf(stdout, "%d is %s\n", dptr->db_actype, ACTTYP);
      fprintf(stdout, "%#x is %s\n", fptr->s_secure, SECFIL);
      fprintf(stdout, "%d is %s\n", fptr->s_maxlvl, MAXLVL);
      fprintf(stdout, "%d is %s\n", fptr->s_minlvl, MINLVL);
      fprintf(stdout, "%#o is %s\n", fptr->s_valcmp, SECCPT);
      fprintf(stdout, "%d is %s\n", dptr->db_proc, PROCLK);
      fprintf(stdout, "%ld is %s\n", dptr->db_state, FSSTAT);
      fprintf(stdout, "%ld is %s\n", dptr->db_type, FSTYPE);
      fprintf(stdout, "%d is %s\n", fptr->s_mapoff, MAPSTR);
      fprintf(stdout, "%d is %s\n", fptr->s_mapblks, MAPBLK);
      fprintf(stdout, "%d is %s\n", dptr->db_fptr, ALLPTR);
      fprintf(stdout, "%d is %s\n", fptr->s_npart, TOTPAR);
      fprintf(stdout, "%d is %s\n", dptr->db_spart, MNTPAR);
      fprintf(stdout, "%d is %s\n", fptr->s_ifract, RATIOS);
      fprintf(stdout, "%d is %s\n", fptr->s_iounit, IOUNIT);
      fprintf(stdout, "%d is %s\n", fptr->s_numiresblks, IRBPR);
      fprintf(stdout, "%#o is %s\n", fptr->s_priparts, BOPP);
      do_bit_translations(fptr->s_priparts, "Partition", "is a Primary Partition");
      fprintf(stdout, "%ld is %s\n", fptr->s_priblock+1, BSPP);
      fprintf(stdout, "%ld is %s\n", fptr->s_prinblks, WINP);
      fprintf(stdout, "%#o is %s\n", fptr->s_secparts, BOSP);
      do_bit_translations(fptr->s_secparts, "Partition", "is a secondary partition");
      fprintf(stdout, "%d is %s\n", fptr->s_secblock+1, BSSP);
      fprintf(stdout, "%d is %s\n", fptr->s_secnblks, WISP);
      fprintf(stdout, "%#o is %s\n", fptr->s_sbdbparts, BOPFSD);
      do_bit_translations(fptr->s_sbdbparts, "Partition", "has File System Data");
      fprintf(stdout, "%#o is %s\n", fptr->s_rootdparts, BPRD);
      do_bit_translations(fptr->s_rootdparts, "Partition", "has a root directory");
      fprintf(stdout, "%#o is %s\n", fptr->s_nudparts, BNUDP);
      fprintf(stdout, "%d is %s\n", NC1MAPBLKS(fptr), IRBMBLKS);
   }

   /*
   * For number of available partitions (as defined in fptr->s_npart)
   */
   tot_pblks=tot_pfinos=tot_parts=free_blocks=tot_free_blocks=0;
   for (ctr=0; ctr < fptr->s_npart; ctr++)
   {
       if (partnumber != 0)   /*  Did we want to look at this partition? */
       {
          if ((partnumber-1) != ctr)
             continue;
       }

       if (option & DUMPALL)
          fprintf(stdout, "\nVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV\n");

       if (option & ACCTALL)
       {
          tot_parts++;
          tot_pblks += fptr->s_part[ctr].fd_nblk;
       }
       if ((option & TBMBLKS) || (option & DBMBLKS))
       {
          if ((free_blocks=traverse_bmap(fd, fptr, ctr, option)) == -1)
             return 1;
          tot_free_blocks+=free_blocks;
          if ( partnumber != 0 )
          {
             if (option & TBMBLKS)
                if (option & VERBOSE)
                   fprintf(stdout, "%d is %s in partition %d\n", free_blocks, MAPCNT, (ctr+1));
                else
                   fprintf(stdout, "%d\n", free_blocks);
             if (option & DBMBLKS)
                print_free_blocks(option, fptr);
          }
          if (((ctr+1) == fptr->s_npart) && partnumber == 0)
          {
             if (option & TBMBLKS)
                if (option & VERBOSE)
                   fprintf(stdout, "%d is %s\n", tot_free_blocks, MAPCNT);
                else
                   fprintf(stdout, "%d\n", tot_free_blocks);
             if (option & DBMBLKS)
                print_free_blocks(option, fptr);
          }
       }
       if (option & DUMPALL )
       {
          fprintf(stdout, "%s is %s\n", &fptr->s_part[ctr].fd_name, FDNAME);
          fprintf(stdout, "%d is %s\n", dptr->db_part[ctr].fd_flag, FDFLAG);
          fprintf(stdout, "%d is %s\n", fptr->s_part[ctr].fd_sblk, FDSTRT);
          fprintf(stdout, "%d is %s\n", fptr->s_part[ctr].fd_nblk, FDBLKS);
       }
       if (option & PDPNAME)
          fprintf(stdout, "%s is %s\n", &fptr->s_part[ctr].fd_name, FDNAME);
       for ( ctr1=0; ctr1 < NC1MAXIREG; ctr1++ )
       {
           if (option & DUMPALL)
           {
              fprintf(stdout, "\n###########################################\n");
              fprintf(stdout, "%d is Partition # %d Inode Region # %d %s\n", fptr->s_part[ctr].fd_ireg[ctr1].i_sblk, (ctr+1), (ctr1+1), INOSTR);
              fprintf(stdout, "%d is Partition # %d Inode Region # %d %s\n", fptr->s_part[ctr].fd_ireg[ctr1].i_nblk, (ctr+1), (ctr1+1), INOBLK);
              fprintf(stdout, "%d is Partition # %d Inode Region # %d %s\n", dptr->db_part[ctr].fd_ireg[ctr1].i_avail, (ctr+1), (ctr1+1), INOAVL);
              fprintf(stdout, "\n############################################\n");
           }
           else if (option & ACCTALL)
           {
              if ( fptr->s_part[ctr].fd_ireg[ctr1].i_nblk != 0 ) 
              {
                 tot_pfinos += dptr->db_part[ctr].fd_ireg[ctr1].i_avail;
                 tot_palinos += ((fptr->s_part[ctr].fd_ireg[ctr1].i_nblk-1)*16)-dptr->db_part[ctr].fd_ireg[ctr1].i_avail;
              }
           }
           else
           {
              /*
              * Get beginning inode region block start address and number 
              * of inodes blocks within inode region.
              */
              beg_inode_block = instart = fptr->s_part[ctr].fd_ireg[ctr1].i_sblk;
              end_inode_block = inblks = fptr->s_part[ctr].fd_ireg[ctr1].i_nblk;

              /*
              *  Get beginning i_number value
              */
              /* begino_val=((instart-2)*16); */
              if ( partnumber == 1 )
                 if ( iregnumber == 1 )
                    begino_val= 0;
                 else
                    begino_val= iregs[iregnumber-1];
              else
                 begino_val= (pnums[partnumber-1] | iregs[iregnumber-1]);

              if ((option & INOREG) && (ctr1 == (iregnumber-1)))
              {
                 /*
                  *  We can access an inode block within desired inode region
                 */
                 if (option & STRBLK)
                 {
                    if ( ! query_blktype)
                    {
                       /*
                        * See if Inode Region Inode Block is not initialized
                       */
                       if ((instart == 0) && (inblks == 0))
                       {
                          fprintf(stdout, "Partion # %d Inode Region # %d Inode Block # %d is an UNITIALIZED INODE BLOCK\n", (ctr+1), (ctr1+1), iblknumber);
                          return 0;
                       }
                    }
                    /*
                    * Reduce number of inode blocks by total blocks for 
                    * inode region map and check if within range
                    */
                    if (iblknumber > (inblks-NC1MAPBLKS(fptr))) 
                    {
                       fprintf(stderr, "\nERROR : -I %d > # of available Inode Blocks which is %d for Partition # %d Inode Region %d\n\n", iblknumber, (inblks-NC1MAPBLKS(fptr)), (ctr+1),(ctr1+1));
                       return 1;
                    }
                    /*
                     * Re-adjust begginning i_number value if not the first
                     * inode block within an inode region
                    */

                    if (iblknumber-1)
                       begino_val += ((iblknumber-1)*16);
                    /*
                    * Bypasses inode map region and position to desired
                    * inode region block location
                    */
                    instart += ((NC1MAPBLKS(fptr)-1) + iblknumber);
                    /*
                    *  Let traverse_inodes routine now that we want only 
                    *  one block of inodes traversed and not the entire 
                    *  inode region
                    */
                    inblks = -1;
                 }
                 else
                 {
                    /*
                    * Bypasses inode map region
                    */
                    instart += NC1MAPBLKS(fptr);
                    if ( ! query_blktype)
                    {
                       /*
                       * See if Inode Region Inode Block is not initialized
                       */
                       if ((instart == 0) && (inblks == 0))
                          fprintf(stdout, "Partion # %d Inode Region # %d has UNITIALIZED INODE BLOCKS\n", (ctr+1), (ctr1+1));
                    }
                 }
                 if (traverse_inodes(fd, instart, inblks,(ctr+1),(ctr1+1), begino_val, fptr) != 0)
                    return 1;
                 else
                    break;
              }
              else  if ((option & STRBLK) && (! (option & INOREG)))
              {
                 if ( ! query_blktype)
                 {
                    /*
                     * We can access an inode block within all inode regions.
                     * See if Inode Region Inode Block is not initialized
                    */
                    if ((instart == 0) && (inblks == 0))
                    {
                       fprintf(stdout, "Partion # %d Inode Region # %d Inode Block %d is an UNITIALIZED INODE BLOCKs\n", (ctr+1), (ctr1+1), iblknumber);
                    }
                 }
                 /*
                 * Reduce number of inode blocks by total blocks for 
                 * inode region map and check if within range
                 */
                 if (iblknumber > (inblks-NC1MAPBLKS(fptr))) 
                 {
                    fprintf(stderr, "\nERROR : -I %d > # of available Inode Blocks which is %d for Partition # %d Inode Region %d\n\n", iblknumber, (inblks-1), (ctr+1),(ctr1+1));
                    return 1;
                 }
                 /*
                  * Re-adjust begginning i_number value if not the first
                  * inode block within an inode region
                 */

                 if (iblknumber-1)
                    begino_val += ((iblknumber-1)*16);
                 /*
                 * Bypasses inode map region and position to desired
                 * inode region block location
                 */
                 instart += ((NC1MAPBLKS(fptr)-1) + iblknumber);
                 /*
                 *  Let traverse_inodes routine now that we want only one
                 *  block of inodes traversed and not the entire inode region
                 */
                 inblks = -1;
                 if (traverse_inodes(fd, instart, inblks,(ctr+1),(ctr1+1), begino_val, fptr) != 0)
                    return 1;
              }
           }
       }
       if (option & DUMPALL)
          fprintf(stdout, "\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n");
       else if (option & ACCTALL)
       {
           /* Inodes 0 and 1 are not used for history reasons so reduce count */
           tot_palinos -= 2;
       }
   }

   if (option & ACCTALL)
   {
      fprintf(stdout, "\nSUPER BLOCK PROCESSING RESULTS AS FOLLOWS\n");
      if ( fptr->s_fsize == tot_pblks )
      {
         fprintf(stdout, "Volume block size (%d) = total block available in %d partitions (%d)\n", fptr->s_fsize, tot_parts, tot_pblks);
      }
      else
      {
         fprintf(stdout, "Volume block size (%d) != total block available in %d partitions (%d)\n", fptr->s_fsize, tot_parts, tot_pblks);
      }
      if ( dptr->db_ifree == tot_pfinos )
      {
         fprintf(stdout, "Volume free inodes (%d) = total free inodes available in %d partitions (%d)\n", dptr->db_ifree, tot_parts, tot_pfinos);
      }
      else
      {
         fprintf(stdout, "Volume free inodes (%d) != total free inodes available in %d partitions (%d)\n", dptr->db_ifree, tot_parts, tot_pfinos);
      }
      if ( dptr->db_ninode == tot_palinos )
      {
         fprintf(stdout, "Volume allocated inodes (%d) = total allocated inodes available in %d partitions (%d)\n", dptr->db_ninode, tot_parts, tot_palinos);
      }
      else
      {
         fprintf(stdout, "Volume allocated inodes (%d) != total allocated inodes available in %d partitions (%d)\n", dptr->db_ninode, tot_parts, tot_palinos);
      }
      /* Inodes 0 and 1 are not used for history reasons so reduce count */
      if ((fptr->s_isize -(fptr->s_npart * 2)) == (dptr->db_ninode + tot_pfinos))
      {
         fprintf(stdout, "Total allocated inodes (%d) plus partition free inodes (%d) = total volume available inodes (%d)\n", dptr->db_ninode, tot_pfinos, (fptr->s_isize - (fptr->s_npart * 2)));
      }
      else
      {
         fprintf(stdout, "Total allocated inodes (%d) plus partition free inodes (%d) != total volume available inodes (%d)\n", dptr->db_ninode, tot_pfinos, (fptr->s_isize - (fptr->s_npart * 2)));
      }
   }
   return 0;
}
/*
* This routine verifies argument to be a block device file on Cray
* environment.
*/
 
is_block_device(filesystem)
char *filesystem;
{
    struct stat statbuf;
 
    if (stat(filesystem,&statbuf) == -1)
    {
       perror("stat(2) Error:");
       return 0;
    }
    if ((statbuf.st_mode & S_IFMT) != S_IFBLK)
    {
       return 0;
    }
    return 1;
}

/*
* This routine will access the super-block(s) within an improved inode file
* system which is available on all non-Cray2 environments.
*/
 
struct nc1filsys *
get_nc1_super_blocks(fd, offset, query_action)
int fd;
off_t offset;
int query_action;
{
   static struct nc1filsys nc1sblks[NC1NSUPER];
 
   /* Seek to offset */
 
   device_offset=offset;
   if (lseek(fd, offset, SEEK_SET) == -1 )
   {
      perror("lseek(fd, offset, SEEK_SET) : Error ");
      return (NULL);
   }
 
   if (read(fd, nc1sblks, sizeof(nc1sblks)) != sizeof(nc1sblks))
   {
      perror("read(fd, nc1sblks, sizeof(nc1sblks)) != sizeof(nc1sblks)) : Error: ");
      return (NULL);
   }
   if (nc1sblks[0].s_magic == FsMAGIC_NC1)
   {
      if (query_action)
      {
         if (query_blktype)
         {
             int ctr, blk_number;

             start_block = blk_number = offset / BSIZE;
             fprintf(stdout, "block %d is boot block \n", blk_number-1);
             fprintf(stdout, "block %d is super block \n", blk_number++);
             for (ctr=0; ctr < 9; ctr++, blk_number++)
             {
                fprintf(stdout, "block %d is copy %d of super block\n", blk_number, ctr+1);
             }
             blk_number=start_block+(nc1sblks[0].s_mapoff-1);
             fprintf(stdout, "block %d is filesystem bitmap block \n", blk_number++);
             for (ctr=1; ctr < nc1sblks[0].s_mapblks; ctr++, blk_number++)
             {
                fprintf(stdout, "block %d is filesystem bitmap block \n", blk_number);
             }
          }
      }
      return((struct nc1filsys *)nc1sblks);
   }
   else
   {
      fprintf(stderr, "\nERROR : Super-block magic number not found for NC1 file system\n");
      return (NULL);
   }
}

/*
* This routine will access the dynamic block within an improved inode file
* system which is available on all non-Cray2 environments.
*/
struct nc1dblock *
get_nc1_dynamic_block(fd, offset, partition_number)
int fd;
off_t offset;
int partition_number;
{
   static struct nc1dblock dynamic;
 

   /* Seek to offset */
   if (lseek(fd, 0, SEEK_SET) == -1 )
   {
      perror("lseek(fd, offset, SEEK_SET) : Error ");
      return (NULL);
   }
   if (lseek(fd, offset, SEEK_SET) == -1 )
   {
      perror("lseek(fd, offset, SEEK_SET) : Error ");
      return (NULL);
   }
   if (read(fd, (char *)&dynamic, sizeof(dynamic)) != sizeof(dynamic))
   {
      perror("read(fd, (char *)&dynamic, sizeof(dynamic)) != sizeof(dynamic)) : Error: ");
      return (NULL);
   }
   if (dynamic.db_magic == DbMAGIC_NC1)
   {
      if (query_blktype)
      {
         fprintf(stdout, "block %d is dynamic super block \n", (offset/BSIZE));
      }
      return((struct nc1dblock *)&dynamic);
   }
   else
   {
      fprintf(stderr, "\nERROR : Cannot find partition # %ld dynamic block in NC1 file system : %x dynamic block magic number encountered\n", partition_number, dynamic.db_magic);
      return (NULL);
   }
}

/*
* This routine will insure that the dynamic block within all improved inode
* file system partitions are identical in informational content...  There 
* is one dynamic block per improved inode C1 file system partition.
*/
cmp_nc1_dblks(fd)
int fd;
{
    int ctr;
    struct nc1filsys *fptr, *t_ptr, *get_nc1_super_blocks();
    struct nc1dblock *dptr, *get_nc1_dynamic_block();
    struct nc1dblock dblks[NC1MAXPART];

    /*
    ******************************************************
    *  Get primary partition super block and dynamic block
    ******************************************************
    */
    if ((fptr=get_nc1_super_blocks(fd, BSIZE, 0)) == NULL)
       return(-1);
    else if ((dptr=get_nc1_dynamic_block(fd, (((fptr->s_dboff-1)*BSIZE)+device_offset), partnumber)) == NULL)
       return(-1);

    bcopy(dblks[0], (char *)dptr, sizeof(struct nc1dblock));
    /*
    ************************************************
    *  Access all remaining partition dynamic blocks
    ************************************************
    */
    for (ctr=1; ctr <= fptr->s_npart-1; ctr++)
    {
        if ((t_ptr=get_nc1_super_blocks(fd, (fptr->s_part[ctr].fd_sblk*BSIZE)+BSIZE, 0)) == NULL)
           return(-1);
        else if ((dptr=get_nc1_dynamic_block(fd, (((t_ptr->s_dboff-1)*BSIZE)+device_offset), ctr+1)) == NULL)
           return(-1);
        bcopy(dblks[ctr], (char *)dptr, sizeof(struct nc1dblock));
    }
    /*
    ***********************************
    *  Compare first against all others
    ***********************************
    */
    for (ctr=1; ctr <= fptr->s_npart-1; ctr++)
    {
        if (bcmp(dblks[0], dblks[ctr], sizeof(struct nc1dblock)) != 0)
           return(0);
    }
    return(1);

    
}

/*
* This routine will insure that the super-block(s) within an improved inode
* file system are identical in informational content...  There are ten 
* super-blocks  improved inode C1 file system partition.
*/
cmp_nc1_sblks(fptr, size)
struct nc1filsys *fptr;
uint size;
{
   int ctr;
   struct nc1filsys sblk, *tptr;
 
   if (fptr->s_magic != FsMAGIC_NC1)
   {
      fprintf(stderr, "\nERROR : Super-block magic number not found for NC1 file system\n");
      return(1);
   }
   tptr=fptr;
 
   for (ctr=1; ctr <= size; ctr++)
   {
       if (memcmp(&fptr[0], &tptr[ctr], sizeof(fptr[0])) != 0)
          return(1);
   }
   return(0);
}
/*
* Calculate partition's offset into bitmap based on preceding
* partitions total block counts.  If file system has a primary
* secondary partition configuration, word align start of first
* secondary partition in bitmap in offset calculation
*/ 
calculate_start(f, part)
struct nc1filsys *f; 
int part;
{
   int start_bit_location=0, alloc_size, ctr, first_secondary=1;

   if ( part != 0)
   {
      for (ctr=0; ctr < part; ctr++)
      {
          if (get_l_to_r_bits(f->s_priparts, ctr, 1))
          {
             alloc_size=f->s_priblock+1;
             start_bit_location += (f->s_part[ctr].fd_nblk/alloc_size);
          }
          else
          {
             alloc_size=f->s_secblock+1;
             if (first_secondary) /* Word align in bitmap */
             {
                first_secondary=0;
                start_bit_location = (f->s_part[ctr].fd_nblk/alloc_size) + ((start_bit_location/64)+1)*64; 
             }
             else
                start_bit_location += (f->s_part[ctr].fd_nblk/alloc_size);
          }

      }
      if (! get_l_to_r_bits(f->s_priparts, ctr, 1))
      {
         alloc_size=f->s_secblock+1;
         if (first_secondary) /* Word align in bitmap */
            start_bit_location = ((start_bit_location/64)+1)*64; 
      }
   }
   return(start_bit_location);
}

/*
*  This routine will process a partitions bitmap region looking for all
*  instances were bits are unset or a zero value.  If bit is zero, then 
*  that physical block is free....
*/

traverse_bmap(fd, f, part, option)
int fd;
struct nc1filsys *f;
int part;
int option;
{
   char *malloc();
   int i,j, no_free_bits, bitcount, start_of_contiguous, alloc_unit_size, a_primary_partition;
   long mapsiz;
   struct free_block_locations *ptr;

   /*
   ***********************************************
   * Determine if a primary or secondary partition 
   * and set alloc_unit_size accordingly
   ***********************************************
   */
   if (get_l_to_r_bits(f->s_priparts, part, 1))
   {
      alloc_unit_size=f->s_priblock+1;
      a_primary_partition=part;
   }
   else if (get_l_to_r_bits(f->s_secparts, part, 1))
   {
      alloc_unit_size=f->s_secblock+1;
      a_primary_partition=partnumber-1;
   }
   else
   {
      fprintf(stderr, "%s : Cannot determine if parition # %d is a primary or secondary partition in order to set allocation unit size\n", pg, part+1);
      return -1;
   }
   if ((map = (long *)malloc(mapsiz = (f->s_mapblks*BSIZE))) == NULL)
   {
      sprintf(msg, "\nmalloc(3) ERROR: %s\n\n", pg);
      perror(msg);
      return -1;
   }
   else if (lseek(fd, 0L, SEEK_SET) < 0)
   {
      sprintf(msg, "\nlseek(2) ERROR: %s\n\n", pg);
      perror(msg);
      return -1;
   }
   else if (lseek(fd,((f->s_mapoff+f->s_part[a_primary_partition].fd_sblk)*BSIZE),SEEK_SET) < 0)
   {
      sprintf(msg, "\nlseek(2) ERROR: %s\n\n", pg);
      perror(msg);
      return -1;
   }
   else if (read(fd,map,mapsiz) != mapsiz)
   {
      sprintf(msg, "\nread(2) ERROR: %s\n\n", pg);
      perror(msg);
      return -1;
   }
   for (no_free_bits=start_of_contiguous=1, bitcount=0, j=i=calculate_start(f, part); i < (j+(f->s_part[part].fd_nblk/alloc_unit_size)); i++)
   {
       if (!isbitset(i))
       {
          if (option & TBMBLKS)
             bitcount++;
          if (option & DBMBLKS)
          {
             no_free_bits=0;
             if (start_of_contiguous)
             {
                 start_of_contiguous=0;
                 if ((ptr = (struct free_block_locations *)malloc(sizeof(struct free_block_locations))) == NULL)
                 {
                    sprintf(msg, "\nmalloc(3) ERROR: %s\n\n", pg);
                    perror(msg);
                    return -1;
                 }
                 else if (! list_start)
                    list_start=ptr;
                 else
                    list_end->next=ptr;
                 ptr->partition_number=part;
                 ptr->allocation_unit_size = alloc_unit_size; 
                 ptr->beg_blk_index=f->s_part[part].fd_sblk;
                 ptr->end_blk_index=f->s_part[part].fd_sblk + f->s_part[part].fd_nblk;
                 ptr->phy_dev_nam=f->s_part[part].fd_name;
                 ptr->next=NULL;
                 list_end=ptr;
                 list_end->starting_location=i;
                 list_end->part_bit_starting_location=j;
                 list_end->contiguous_followers=0;
             }
             list_end->contiguous_followers++;
          }
       }
       else
          start_of_contiguous=1;
   }
   if (option & DBMBLKS)
   {
      if ( no_free_bits ) /* Install partition info in list */
      {                   /* and mark as such */
         if ((ptr = (struct free_block_locations *)malloc(sizeof(struct free_block_locations))) == NULL)
         {
            sprintf(msg, "\nmalloc(3) ERROR: %s\n\n", pg);
            perror(msg);
            return -1;
         }
         else if (! list_start)
            list_start=ptr;
         else
            list_end->next=ptr;
         ptr->partition_number=part;
         ptr->allocation_unit_size = alloc_unit_size; 
         ptr->beg_blk_index=f->s_part[part].fd_sblk;
         ptr->end_blk_index=f->s_part[part].fd_sblk + f->s_part[part].fd_nblk;
         ptr->phy_dev_nam=f->s_part[part].fd_name;
         ptr->next=NULL;
         list_end=ptr;
         list_end->starting_location=0;
         list_end->contiguous_followers=0;
      }
   }
   return (bitcount*alloc_unit_size);
}

/*
*  This routine accesses desired bit from bitmap
*/

isbitset(index)
int index;
{
   int wrd, offset;

   wrd = index/64;
   offset = index%64;
   return((map[wrd]>>(63-offset))&1);
}

/*
*  Traverse inode region in manner so desired.  Either the entire inode region
*  and all inode data blocks or just one particular inode data block within
*  a inode region.
*/
traverse_inodes(fd, start, stop, part, inoreg, inumber, fptr)
int fd;
uint start, stop;
int part, inoreg;
uint inumber;
struct nc1filsys *fptr;
{
   long int inode_blk_ctr, file_position, bytes_read, bytes_to_read, byte_ctr;
   uint free_inode_block, start_bytes, stop_bytes, ctr, ctr1;
   struct cdinode nc1inode[16];
   struct bdes *dblk;

   start_bytes=start*BSIZE;
   if ( stop != -1 )    /*  Traverse entire inode region */
   {
         stop_bytes = (start+(stop-NC1MAPBLKS(fptr)))* BSIZE;
         bytes_to_read = stop_bytes - start_bytes;
   }
   else       /*  Traverse only one inode block within an inode region */
   {
      bytes_to_read=BSIZE;
   }

   if (query_blktype)
   {
      int ctr, blk_number;
      int beg_inodes=0;
      int end_inodes=-1;

      for (ctr=1, blk_number=beg_inode_block; ctr <= NC1MAPBLKS(fptr); ctr++, blk_number++) 
          fprintf(stdout, "block %d is inode region map block \n", blk_number);

      for (ctr=NC1MAPBLKS(fptr); ctr < end_inode_block; ctr++, blk_number++)
      {
          /* beg_inodes = (blk_number-3)*16; */
          beg_inodes = end_inodes + 1;
          end_inodes = beg_inodes + 15;
          fprintf(stdout, "block %d is an inode block for inodes %d.%d.%d - %d\n", blk_number, partnumber-1, iregnumber-1, beg_inodes, end_inodes);
      }
   }
   if (lseek(fd, 0L, SEEK_SET) == -1)
   {
      sprintf(msg, "\nlseek(2) ERROR: %s\n\n", pg);
      perror(msg);
      return 1;
   }
   else if (lseek(fd, start_bytes, SEEK_CUR) == -1)
   {
      sprintf(msg, "\nlseek(2) ERROR: %s\n\n", pg);
      perror(msg);
      return 1;
   }

   for (inode_blk_ctr=bytes_read=byte_ctr=0; byte_ctr < bytes_to_read; byte_ctr += bytes_read, inode_blk_ctr++)
   {
       if ((bytes_read=read(fd, (char *)nc1inode, sizeof(nc1inode))) != sizeof(nc1inode))
       {
          sprintf(msg, "\nread(2) ERROR: %s\n\n", pg);
          perror(msg);
          return 1;
       }
       for (free_inode_block=ctr=0; ctr < 16; ctr++, inumber++)
       {
           if (! nc1inode[ctr].cdi_mode)
           {
                 free_inode_block++;
                 continue;
           }
           if (query_blktype)
           {
              int tctr;
              extent_t *dbptr;

              dbptr = (extent_t *) &nc1inode[ctr].cdi_addr[0].daddr;
              for (tctr=0; tctr < 8; tctr++, dbptr++)
              {
                  if (dbptr->blk)
                  {
                     int ttctr, blk_number;
                     for (ttctr=0, blk_number=dbptr->blk; ttctr < dbptr->nblks; ttctr++, blk_number++)
                     {
                         fprintf(stdout, "block %d is data block for file\n", blk_number); 
                     }
                     
                  }
              }
           }
           else
           {
              fprintf(stdout, "%o is %s for INODE # %d \n", nc1inode[ctr].cdi_mode, IMODE, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_gen, IGEN,inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_nlink, INLINK, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_uid, IUID, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_gid, IGID,inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_acid, IACID, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_msref, IMSREF, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_ms, IMS, inumber);
              fprintf(stdout, "%ld is %s for INODE # %d \n", nc1inode[ctr].cdi_size, ISIZE, inumber);
              fprintf(stdout, "%ld is %s for INODE # %d \n", nc1inode[ctr].cdi_moffset, IMOFF, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_blocks, IQBLKS, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_extcomp, ISECEXT, inumber);
              fprintf(stdout, "%o is %s for INODE # %d \n", nc1inode[ctr].cdi_compart.smallcmps, ISECOMP, inumber);
              fprintf(stdout, "%o is %s for INODE # %d \n", nc1inode[ctr].cdi_slevel, ISLEVEL, inumber);
              fprintf(stdout, "%o is %s for INODE # %d \n", nc1inode[ctr].cdi_secflg, ISECFLG, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_intcls, IINTCLS, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_intcat, IINTCAT, inumber);
              fprintf(stdout, "%ld is %s for INODE # %d \n", nc1inode[ctr].cdi_permits, IPERMB, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_cpart, ICPARTS, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_dmkey, IDMKEY, inumber);
              if (CDI_ALF_NOGRW & nc1inode[ctr].cdi_allocf)
                 fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_allocf, IALLOCF1, inumber);
              else
                 fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_allocf, IALLOCF2, inumber);
              if (C1_EXTENT & nc1inode[ctr].cdi_alloc)
                 fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_alloc, IDBLKEXT, inumber);
              else
                 fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_alloc, IDBLKSEC, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_dmmid, IDMMACH, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_atmsec, IATIME, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_mtmsec, IMTIME, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_ctmsec, ICTIME, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_natmsec, IATIMEN, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_nmtmsec, IMTIMEN, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_nctmsec, ICTIMEN, inumber);
              fprintf(stdout, "%ld is %s for INODE # %d \n", nc1inode[ctr].cdi_cbits, ICBITS, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_minlvl, IMINLVL, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_maxlvl, IMAXLVL, inumber);
              fprintf(stdout, "%ld is %s for INODE # %d \n", nc1inode[ctr].cdi_valcmp, IVALCOMP, inumber);
/*
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_type, IPHYDEV, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_length, ISLICE, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_start, IABSBLK, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_flags, IFLAGS, inumber);
              fprintf(stdout, "%d is %s for INODE # %d \n", nc1inode[ctr].cdi_iopath, ICLUST, inumber);
*/
              fprintf(stdout, "%ld is %s for INODE # %d \n", nc1inode[ctr].cdi_filename, IFILEN, inumber);
              fprintf(stdout,"#IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII\n");
           }
       }
       if ( ! query_blktype)
       {
          if (free_inode_block == 16)
          {
             free_inode_block=0;
             if (stop != -1 )
                fprintf(stdout, "Partition # %d Inode Region # %d Inode block # %d is FREE INODE BLOCK\n", part, inoreg, inode_blk_ctr+1);
             else
                fprintf(stdout, "Partition # %d Inode Region # %d Inode block # %d is FREE INODE BLOCK\n", part, inoreg, iblknumber);
          }
       }
   }
   return 0;
}

/*
* This function verifies argument is a integer string
*/


is_non_numeric_arg(ptr)
char *ptr;
{
    while (*ptr)
    {
        if ( ! isdigit(*ptr))
           return 1;
        ptr++;
    }
    return 0;
}
/*
*  Obtain hh:mm:ss from ctime string (i.e Sun Sep 16 01:32:52 1973\n\0 )
*/
 
get_ascii_time(ptr, ptr1)
char *ptr ;
char *ptr1;
{
   char *s_ptr;
 
   s_ptr = ptr;
   while ( *s_ptr && *s_ptr != ':' )
         s_ptr++;
   if (s_ptr == '\0')
       return 1;
 
   s_ptr -= 2;
   for (; *s_ptr != ' '; *ptr1++ = *s_ptr++)
       ;;
   *ptr1 = '\0';
   return 0;
}

/*
* Self-explanatory
*/
usage()
{
    fprintf(stderr, "\n%s [%s] file-system\n\n", pg, OPTIONS);
    fprintf(stderr, "Where options are defined as follows\n\n");
    fprintf(stderr, "  -a           Device Accounting Type\n");
    fprintf(stderr, "  -A           Super-block Summary Totals\n");
    fprintf(stderr, "  -b           Total File Byte Size For BIGFILE Classification\n");
    fprintf(stderr, "  -B           Minimum Blocks Allocated For BIGFILE Classification\n");
    fprintf(stderr, "  -c           Security Compartment Bit Values\n");
    fprintf(stderr, "  -C           Security Compartment ASCII Values\n");
    fprintf(stderr, "  -d           Dump Super-block, Partition, and Inode Region information\n");
    fprintf(stderr, "  -D           Dump just Super-block information\n");
    fprintf(stderr, "  -f           Total Free Sector Blocks\n");
    fprintf(stderr, "  -F           Total Free Inodes\n");
    fprintf(stderr, "  -h           Usage Clause\n");
    fprintf(stderr, "  -i integer   Inode Region Selection > 0 and <= %d\n", NC1MAXIREG);
    fprintf(stderr, "  -I integer   Inode Block Starting Number\n");
    fprintf(stderr, "  -m           Total Free Bitmap Blocks\n");
    fprintf(stderr, "  -M           Display Free Bitmap Blocks\n");
    fprintf(stderr, "  -n           File System Pack Name\n");
    fprintf(stderr, "  -p integer   Partition Selection > 0 and <= %d\n", NC1MAXPART);
    fprintf(stderr, "  -P           Total Number of Partitions\n");
    fprintf(stderr, "  -q           Query and identify block types (i.e bitmap vs inode)\n");
    fprintf(stderr, "  -R           Ratio of Inodes to Blocks\n");
    fprintf(stderr, "  -s           Minimum Security Level\n");
    fprintf(stderr, "  -S           Maximum Security Level\n");
    fprintf(stderr, "  -t           Total Allocated Inodes\n");
    fprintf(stderr, "  -T           Total Available Inodes\n");
    fprintf(stderr, "  -u           Last Super-block update in seconds\n");
    fprintf(stderr, "  -U           Last Super-block update in HH:MM:SS\n");
    fprintf(stderr, "  -v           Verbose Output\n");
    fprintf(stderr, "  -V           Total Volume Available Blocks\n");
    fprintf(stderr, "  -z           Determine if intra-partition super blocks are in sync (i.e 10 per partition)\n");
    fprintf(stderr, "  -Z           Determine if partition dynamic blocks are in sync (i.e 1 per partition)\n");
    exit(1);
}

