#include "myincludes.h"

/* I don't think this code is good, but it's better than before. */

#define REPLACESTRING_SIZE 4096

char *replacestring(const char * const source, const char * const from, const char * const to)
{
    char buffer[REPLACESTRING_SIZE];
    char *cur_buffer = buffer;
    const char * const buffer_end = buffer + REPLACESTRING_SIZE - 1;
    const char * start = source;

    char *p;
    int to_len = strlen(to);
    int from_len = strlen(from);
    int source_len = strlen(source);

    memset(buffer, 0, REPLACESTRING_SIZE);

    while ((p = strstr(start, from)) != NULL) {
        int to_copy;

        to_copy = p - start;
        if (cur_buffer + to_copy > buffer_end) {
            exit(1);
        }
        strncpy(cur_buffer, start, to_copy);
        cur_buffer += to_copy;
        start = p + from_len;

        to_copy = to_len;
        if (cur_buffer + to_copy > buffer_end) {
            exit(1);
        }
        strncpy(cur_buffer, to, to_copy);
        cur_buffer += to_copy;
    }

    if (start != source + source_len) {
        int to_copy;
        to_copy = source_len - (start - source);
        if (cur_buffer + to_copy > buffer_end) {
            exit(1);
        }
        strncpy(cur_buffer, start, to_copy);
    }

    return strdup(buffer);
}

#if 0
int
test(char *expected, char *str, char *from, char *to)
{
    char *res;
    res = replacestring(str, from, to);

    printf("%s -> %s\n", str, res);
    if (strcmp(expected, res) == 0) {
        printf("Pass\n");
    } else {
        printf("Fail\n");
    }
    free(res);
}

int
main(int argc, char **argv)
{
    test("he-o world", "hello world", "ll", "-");
    test("he11o wor1d", "hello world", "l", "1");
    test("hello worrrld", "hello world", "r", "rrr");
    return 0;
}
#endif
