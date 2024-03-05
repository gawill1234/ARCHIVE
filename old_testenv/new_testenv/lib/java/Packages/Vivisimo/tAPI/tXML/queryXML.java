package Vivisimo.tAPI;

import java.io.*;
import java.net.URL;

import java.util.Set;
import java.util.*;


public class queryXML
{

   String statusUrl = null;
   String collection = null;

   GoGetXML yy = null;

   public Set getQDocUrlList() {

      return(this.yy.getListOfAttrs("//document", "url"));

   }

   public Set getQDocAttrList(String vAttr) {

      return(this.yy.getListOfAttrs("//document", vAttr));

   }

   public Set getQContAttrList(String vAttr) {

      return(this.yy.getListOfAttrs("//content", vAttr));

   }

   private String readFileAsString(String filePath)
           throws java.io.IOException {

      byte[] buffer = new byte[(int) new File(filePath).length()];
      BufferedInputStream f = null;

      try {
         f = new BufferedInputStream(new FileInputStream(filePath));
         f.read(buffer);
      } finally {
         if (f != null)  {
            try { 
               f.close();
            } catch (IOException ioe) {
               System.out.println("ERROR: " + ioe);
            }
         }
      }

      return(new String(buffer));
   }

   public void fromXMLInit(String myXMLString) {

      try {
         this.yy = new GoGetXML(myXMLString);
      } catch (java.lang.Exception jle) {
         System.out.println("ERROR: " + jle);
      }
   }

   public void fromFileInit(String testFile) {

      try {
         this.yy = new GoGetXML(readFileAsString(testFile));
      } catch (java.lang.Exception jle) {
         System.out.println("ERROR: " + jle);
      }
   }

   public queryXML(String someStr, Boolean isAFile) {

      if (isAFile) {
         this.fromFileInit(someStr);
      } else {
         this.fromXMLInit(someStr);
      }

   }

}
