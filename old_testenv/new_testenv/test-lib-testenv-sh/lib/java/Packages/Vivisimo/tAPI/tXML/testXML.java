package Vivisimo.tAPI;

import java.io.*;
import java.net.URL;

import java.util.Set;
import java.util.*;


public class testXML
{

   String statusUrl = null;
   String collection = null;

   GoGetXML yy = null;

   public Set getQueryList() {
      return(this.yy.xPathValueGet("//query"));
   }

   private Hashtable innerGetQueryData(Hashtable<String,Integer> queryECount) {

      Set<String> gruber = null;
      String numStr = null;

      gruber = this.getQueryList();
      for (String cN : gruber) {
         numStr = this.yy.getAttrByData("//query", "eValue", cN);
         if (numStr != null) {
            queryECount.put(cN, new Integer(Integer.valueOf(numStr)));
         }
      }

      return(queryECount);
   }

   public Hashtable getQueryData(Hashtable<String,ArrayList<String>> queryECount) {

      ArrayList<String> attrList = new ArrayList<String>();
      attrList.add("eValue");
      attrList.add("cFile");

      //return(this.yy.getAttrAndData("//query", "eValue", queryECount));
      return(this.yy.getAttrAndData("//query", attrList, queryECount));

   }

   public Hashtable getQueryData() {

      ArrayList<String> attrList = new ArrayList<String>();
      attrList.add("eValue");
      attrList.add("cFile");

      //return(this.yy.getAttrAndData("//query", "eValue"));
      return(this.yy.getAttrAndData("//query", attrList));

   }

   public String getTestName() {

      return((String)this.yy.xPathAttrGetAL("//test", "name").get(0));

   }

   public String getCollectionName(Integer which) {

      return((String)this.yy.xPathAttrGetAL("//collection", "name").get(which));

   }

   public String getCollectionName() {

      return((String)this.yy.xPathAttrGetAL("//collection", "name").get(0));

   }

   public Set getCollectionNames() {

      return(this.yy.xPathAttrGet("//collection", "name"));

   }

   public Hashtable getStatusData() {

      ArrayList<String> attrList = new ArrayList<String>();
      attrList.add("eValue");
      attrList.add("vAttr");

      return(this.yy.getAttrAndDataWithDups("//status-item", attrList));

   }

   public Hashtable getUpdateData() {

      ArrayList<String> attrList = new ArrayList<String>();
      attrList.add("name");
      attrList.add("type");

      return(this.yy.getAttrAndData("//updates", attrList));

   }

   private static String readFileAsString(String filePath)
           throws java.io.IOException {

      byte[] buffer = new byte[(int) new File(filePath).length()];
      BufferedInputStream f = null;

      try {
         f = new BufferedInputStream(new FileInputStream(filePath));
         f.read(buffer);
      } finally {
         if (f != null) try { f.close(); } catch (IOException ignored) { }
      }

      return new String(buffer);
   }

   public testXML(String testFile) {

      try {
         this.yy = new GoGetXML(readFileAsString(testFile));
      } catch (java.lang.Exception jle) {
         System.out.println("ERROR: " + jle);
      }
 

   }
}
