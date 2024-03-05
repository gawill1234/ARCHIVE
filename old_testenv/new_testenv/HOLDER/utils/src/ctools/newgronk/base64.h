#ifndef __BASE64_H__
#define __BASE64_H__

#ifdef PLATFORM_WINDOWS
typedef unsigned __int64 big_num_t;
#else

#if defined(__WORDSIZE) && __WORDSIZE==64
typedef unsigned long big_num_t;
#else
typedef unsigned long long big_num_t;
#endif
#endif

#ifdef _cplusplus
extern "C" {
#endif

/* base64_encode

   Encodes the given data with the base64 encoding.

   Arguments:
     - {data}: The data to encode.
     - {size}: The length of data to encode.
     - {dest): A pointer to a string that will be allocated
       with the encoded data.

   Returns:
     - The length of the allocated encoded string on success, -1 on failure.
*/
int base64_encode(const void *data, int size, char **dest);

/* base64_decode

   Decodes the given base64 encoded string into raw data.

   Arguments:
     - {str}: The base64 encoded string.
     - {data}: A pointer to a location to decode the data to.

   Returns:
     - The length of the decoded data.
     - -1 if something goes wrong.

   Caveats:
     - {data} must be allocated before calling this function.
       A safe size to allocate
     is strlen(str) + 3.
 */
int base64_decode(const char *str, void *data);

#ifdef _cplusplus
}
#endif

#endif

