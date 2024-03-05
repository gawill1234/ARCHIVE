
/*
                             CRC-10 Test Cases

                               (All values in hex)


Test cell #1:

0A 0B 0C 0D 0E 0F 00 00 00 00
00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00

CRC10 = 1F6

Test cell #2:

11 11 11 11 11 11 11 11 11 11
00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 00 00
00 00 00 00 00 00

CRC10 = 16B

Test cell #3:

FF FF FF FF FF FF FF FF FF FF
FF FF FF FF FF FF FF FF FF FF
FF FF FF FF FF FF FF FF FF FF
FF FF FF FF FF FF FF FF FF FF
FF FF FF FF FF FF

CRC10 = 30F

Test cell #4:

12 34 56 78 90 12 34 56 78 90
12 34 56 78 90 12 34 56 78 90
12 34 56 78 90 12 34 56 78 90
12 34 56 78 90 12 34 56 78 90
12 34 56 78 90 12

CRC10 = 2ED

AIS OAM cell:

10 6A 6A 6A 6A 6A 6A 6A 6A 6A
6A 6A 6A 6A 6A 6A 6A 6A 6A 6A
6A 6A 6A 6A 6A 6A 6A 6A 6A 6A
6A 6A 6A 6A 6A 6A 6A 6A 6A 6A
6A 6A 6A 6A 6A 6A

CRC10 = 3B9

RDI OAM cell:

11 6A 6A 6A 6A 6A 6A 6A 6A 6A
6A 6A 6A 6A 6A 6A 6A 6A 6A 6A
6A 6A 6A 6A 6A 6A 6A 6A 6A 6A
6A 6A 6A 6A 6A 6A 6A 6A 6A 6A
6A 6A 6A 6A 6A 6A

CRC10 = 0AF

Loopback OAM cell:

18 01 00 00 00 00 FF FF FF FF
FF FF FF FF FF FF FF FF FF FF
FF FF 00 00 00 00 00 00 00 00
00 00 00 00 00 00 00 00 6A 6A
6A 6A 6A 6A 6A 6A

CRC10 = 04A

*/


#include <assert.h>
#include <stdio.h>
#define PAYLOAD_SIZE 48
#define POLYNOMIAL_10 0x633

typedef struct{
    char *name;
    unsigned char *cell_payload;
} TCASE_STRUCT;

static char test_cell_1_name[]="Test cell #1";

static unsigned char test_cell_1_payload[PAYLOAD_SIZE]={
 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

static char test_cell_2_name[]="Test cell #2";

static unsigned char test_cell_2_payload[PAYLOAD_SIZE]={
 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11,
 0x11, 0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

static char test_cell_3_name[]="Test cell #3";

static unsigned char test_cell_3_payload[PAYLOAD_SIZE]={
 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00};

static char test_cell_4_name[]="Test cell #4";

static unsigned char test_cell_4_payload[PAYLOAD_SIZE]={
 0x12, 0x34, 0x56, 0x78, 0x90, 0x12, 0x34, 0x56,
 0x78, 0x90, 0x12, 0x34, 0x56, 0x78, 0x90, 0x12,
 0x34, 0x56, 0x78, 0x90, 0x12, 0x34, 0x56, 0x78,
 0x90, 0x12, 0x34, 0x56, 0x78, 0x90, 0x12, 0x34,
 0x56, 0x78, 0x90, 0x12, 0x34, 0x56, 0x78, 0x90,
 0x12, 0x34, 0x56, 0x78, 0x90, 0x12, 0x00, 0x00};

static char ais_cell_name[]="AIS OAM cell";

static unsigned char ais_cell_payload[PAYLOAD_SIZE]={
 0x10, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a,
 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a,
 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a,
 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a,
 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a,
 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x00, 0x00};

static char rdi_cell_name[]="RDI OAM cell";

static unsigned char rdi_cell_payload[PAYLOAD_SIZE]={
 0x11, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a,
 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a,
 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a,
 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a,
 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a,
 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x00, 0x00};

static char loopback_cell_name[]="Loopback OAM cell";

static unsigned char loopback_cell_payload[PAYLOAD_SIZE]={
 0x18, 0x01, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff,
 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x6a, 0x6a,
 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x6a, 0x00, 0x00};

static TCASE_STRUCT test_case_list[]={
    { test_cell_1_name, test_cell_1_payload },
    { test_cell_2_name, test_cell_2_payload },
    { test_cell_3_name, test_cell_3_payload },
    { test_cell_4_name, test_cell_4_payload },
    { ais_cell_name, ais_cell_payload },
    { rdi_cell_name, rdi_cell_payload },
    { loopback_cell_name, loopback_cell_payload },
    { 0, 0 }
};

static unsigned short byte_crc10_table[256];

/* generate the table of CRC-10 remainders for all possible bytes */
void gen_byte_crc10_table()
{
    register int i, j;
    register unsigned short crc10_accum;

    for ( i = 0;  i < 256;  i++ )
    {
        crc10_accum = ((unsigned short) i << 2);
        for ( j = 0;  j < 8;  j++ )
        {
            if ((crc10_accum <<= 1) & 0x400)
               crc10_accum ^= POLYNOMIAL_10;
        }
        byte_crc10_table[i] = crc10_accum;
    }
    return;
}

/* update the data block's CRC-10 remainder one byte at a time */

unsigned short update_crc10_by_bytes(crc10_accum, data_blk_ptr, data_blk_size)
 unsigned short crc10_accum;
 unsigned char *data_blk_ptr;
 int  data_blk_size;
{
    register int i;
    for ( i = 0;  i < data_blk_size;  i++ )
    {
        crc10_accum = ((crc10_accum << 8) & 0x3ff)
                       ^ byte_crc10_table[( crc10_accum >> 2) & 0xff]
                                                      ^ *data_blk_ptr++;
    }
    return crc10_accum;
}

void crc10_test()
{
    unsigned short crc10_accum=0;
    TCASE_STRUCT *current_test_case=test_case_list;

    gen_byte_crc10_table();

    while (current_test_case -> name != NULL)
    {
        /* assert that there is a cell payload to check */
        assert(current_test_case -> cell_payload != NULL);

        /* generate transmit crc10 and insert it into the cell */
        crc10_accum = update_crc10_by_bytes(0,
                                            current_test_case->cell_payload,
                                            PAYLOAD_SIZE);
        current_test_case->cell_payload[PAYLOAD_SIZE-2] ^= crc10_accum >> 8;
        current_test_case->cell_payload[PAYLOAD_SIZE-1] ^= crc10_accum & 0xff;

        /* check the receive crc10 remainder, and assert that it's zero */
        assert( update_crc10_by_bytes(0,
                                      current_test_case->cell_payload,
                                      PAYLOAD_SIZE) == 0);

        /* if assertions are correct then this test case checks out OK */
        printf("%s CRC-10 = %03x, remainder checks OK\n",
                                    current_test_case->name, crc10_accum);
        ++current_test_case;
    }

    return;
}


