import java.io.File;
import java.io.FileWriter;

import java.net.URL;
import javax.xml.namespace.QName;

public class doTheTime
{

   public static long getMyTime() throws java.lang.Exception
   {
      long mysecs = System.nanoTime();
      System.out.println("Nano/Milli Seconds " + mysecs);

      return mysecs;
   }

   //public static void main(String[] args) throws java.lang.Exception
   //{
   //   getMyTime();
   //
   //   System.exit(0);
   //}
}
