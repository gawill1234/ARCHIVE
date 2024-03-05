import java.io.*;
import java.util.Map;
import java.util.Set;

public class mimeType {

   private static String fname;
   private static String suffix;
   private static String mimetype;
   private static File file;

   mimeType(String fname) {

      this.file = new File(fname);
      this.initializeItDude();
   }

   mimeType(File infile) {

      this.file = infile;
      this.initializeItDude();
   }

   private void initializeItDude() {

      String[] nameParts;
      int stringLen;

      this.fname = this.file.getName();
      nameParts = this.fname.split("\\.");
      stringLen = nameParts.length;
      this.suffix = nameParts[stringLen - 1];
      this.setMyMimeType();
   }

   private void setMyMimeType() {

      String localSuffix = this.suffix.toLowerCase();

      if (localSuffix.equals("html") || localSuffix.equals("htm") ||
         localSuffix.equals("stm")) {
         this.mimetype = "text/html";
      } else if (localSuffix.equals("pdf")) {
         this.mimetype = "application/pdf";
      } else if (localSuffix.equals("dot") || localSuffix.equals("doc") ||
                 localSuffix.equals("docx")) {
         this.mimetype = "application/msword";
      } else if (localSuffix.equals("ppt") || localSuffix.equals("pptx") ||
                 localSuffix.equals("pps")) {
         this.mimetype = "application/vnd.ms-powerpoint";
      } else if (localSuffix.equals("exe") || localSuffix.equals("class") ||
                 localSuffix.equals("bin") || localSuffix.equals("dms") ||
                 localSuffix.equals("lha") || localSuffix.equals("lzh")) {
         this.mimetype = "application/octet-stream";
      } else if (localSuffix.equals("xla") || localSuffix.equals("xlc") ||
                 localSuffix.equals("xlm") || localSuffix.equals("xlt") ||
                 localSuffix.equals("xls") || localSuffix.equals("xlsx")) {
         this.mimetype = "application/vnd.ms-excel";
      } else if (localSuffix.equals("dll")) {
         this.mimetype = "application/x-msdownload";
      } else if (localSuffix.equals("tsv")) {
         this.mimetype = "text/tab-separated-values";
      } else if (localSuffix.equals("ps")) {
         this.mimetype = "application/postscript";
      } else if (localSuffix.equals("qt")) {
         this.mimetype = "video/quicktime";
      } else if (localSuffix.equals("tar")) {
         this.mimetype = "application/x-tar";
      } else if (localSuffix.equals("wav")) {
         this.mimetype = "audio/x-wav";
      } else if (localSuffix.equals("zip")) {
         this.mimetype = "application/zip";
      } else if (localSuffix.equals("gif")) {
         this.mimetype = "image/gif";
      } else if (localSuffix.equals("css")) {
         this.mimetype = "text/css";
      } else if (localSuffix.equals("jpg")) {
         this.mimetype = "image/jpeg";
      } else if (localSuffix.equals("java")) {
         this.mimetype = "text/x-java";
      } else {
         this.mimetype = "text/plain";
      }

      return;
   }

   public String getMimeType() {
      return(this.mimetype);
   }

}
