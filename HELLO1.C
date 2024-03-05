#include <stdio.h>
#include <string.h>
#include <stdlib.h>

class String {

   public:
      String();
      String(String &);
      String(char *);
      ~String();

      void print();

      String operator=(char *);
      String operator=(const String &);

      friend int length(const String &);
      friend String operator+(const String &, const String &);

   private:
      char *text;
};

String::String()
       :text(NULL)
{
}

String::String(char *a)
{
   text = (char *)malloc(strlen(a) + 1);
   sprintf(text, "%s\0", a);
}

String::String(String &a)
{
   text = (char *)malloc(strlen(a.text) + 1);
   sprintf(text, "%s\0", a.text);
}

String::~String()
{
    free(text);
}

int length(const String &words)
{
   return(strlen(words.text));
}

int length(char *instring)
{
   return(strlen(instring));
}

String operator+(const String &left, const String &right)
{
String both;
int combined;

   combined = length(left) + length(right);
   both.text = (char *)malloc(combined + 2);

   printf("%s %s\n", left.text, right.text);fflush(stdout);

   sprintf(both.text, "%s %s\0", left.text, right.text);

   return(both);
}

String String::operator=(char *instring)
{
   text = (char *)malloc(length(instring) + 1);
   strcpy(text, instring);
   return(*this);
}

String String::operator=(const String &instring)
{
   text = (char *)malloc(strlen(instring.text) + 1);
   sprintf(text, "%s\0", instring.text);
   return(*this);
}

void String::print()
{
   printf("%s\n", text);
}

main()
{
String one, two, three, four;

   one = "hello";
   four = two = "world";

   three = one + four;

   three.print();
}
