#include <stdio.h>
#include <string.h>
#include <stdlib.h>

class String {

   public:
      void print();

      void operator=(char *);
      void operator=(String);

      friend int length(String );
      String operator+(String);

   private:
      char *text;
};

int length(String words)
{
   return(strlen(words.text));
}

int length(char *instring)
{
   return(strlen(instring));
}

String String::operator+(String right)
{
String both;
int combined;

   combined = length(text) + length(right);
   both.text = (char *)malloc(combined + 2);
   sprintf(both.text, "%s %s\0", text, right.text);

   return(both);
}

void String::operator=(char *instring)
{
   text = (char *)malloc(length(instring) + 1);
   strcpy(text, instring);
}

void String::operator=(String instring)
{
   text = instring.text;
}

void String::print()
{
   printf("%s\n", text);
}

main()
{
String one, two, three;

   one = "hello";
   two = "world";

   three = one + two;

   three.print();
}
