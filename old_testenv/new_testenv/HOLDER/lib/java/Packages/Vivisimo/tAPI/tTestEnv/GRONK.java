package Vivisimo.tAPI;

import java.io.*;
import java.net.URL;

import java.util.Set;
import java.util.*;


public class GRONK
{

   String gronkUrl = null;
   String collection = null;

   ENVIRONMENT gronkEnv = null;

   private void getVelocityEnv() {

      this.gronkEnv = new ENVIRONMENT();

   }

   private void commonInit() {
      String grcmd;

      getVelocityEnv();

      this.gronkUrl = this.gronkEnv.getGronkUrl();
   }

   public void setCollection(String collection) {

      this.collection = collection;

   }

   public String standardGRONKAction(String action) {

      String answer = null;
      String url = this.gronkUrl + "?action=" + action;

      GoGet zz = new GoGet(url, this.gronkEnv.getVivUser(), this.gronkEnv.getVivPassword());
      answer = zz.DoHttpGoGet();

      return(answer);
   }

   public ENVIRONMENT getEnvironment() {
      return(this.gronkEnv);
   }


   /////////////////////////////////////////////////////////////////
   //
   //   File operations
   //

   //
   //   Does a given files exist on the target host?
   //
   public Boolean checkFileExists(String filename) {

      if ( filename == null ) {
         return(false);
      }

      String actionString = "check-file-exists&file=" + filename;

      String answer = standardGRONKAction(actionString);

      if (answer != null) {
         GoGetXML yy = new GoGetXML(answer);

         if (yy.firstElementValue("OUTCOME").equals("Yes")) {
            return(true);
         }
      }

      return(false);
      
   }

   //
   //   How big is the named file on the target host?
   //
   public Integer fileSize(String filename) {

      if ( filename == null ) {
         return(-1);
      }

      if (checkFileExists(filename)) {
         String actionString = "file-size&file=" + filename;

         String answer = standardGRONKAction(actionString);

         //System.out.println(answer);

         GoGetXML yy = new GoGetXML(answer);

         return(Integer.parseInt(yy.firstElementValue("SIZE")));
      }

      return(-1);
      
   }

   //
   //   How big is the named file on the target host?
   //
   public Integer fileTime(String filename) {

      if ( filename == null ) {
         return(-1);
      }

      if (checkFileExists(filename)) {
         String actionString = "file-time&file=" + filename;

         String answer = standardGRONKAction(actionString);

         //System.out.println(answer);

         GoGetXML yy = new GoGetXML(answer);

         return(Integer.parseInt(yy.firstElementValue("TIMESTAMP")));
      }

      return(-1);
      
   }

   //
   //   How big is the named file on the target host?
   //
   public String executeCommand(String cmd, Boolean isBinary) {

      if ( cmd == null ) {
         return(null);
      }

      String actionString = "execute&command=" + cmd;
      if ( isBinary ) {
         actionString = actionString + "&type=binary";
      }

      String answer = standardGRONKAction(actionString);

      //System.out.println(answer);

      return(answer);
   }

   public Integer velocityStartup() {

      String whereIsIt = this.installedDir();
      String cmd = whereIsIt + "/bin/velocity-startup --yes";

      String response = this.executeCommand(cmd, true);

      if (response.contains("Velocity is ready")) {
         System.out.println("Velocity startup was successful");
         return(1);
      }

      System.out.println("Velocity startup was not successful");
      return(0);
   }

   public Integer velocityShutdown() {

      String whereIsIt = this.installedDir();
      String cmd = whereIsIt + "/bin/velocity-shutdown --force --yes";

      String response = this.executeCommand(cmd, true);

      if (response.contains("Velocity has been shutdown")) {
         System.out.println("Velocity shutdown was successful");
         return(1);
      }

      System.out.println("Velocity shutdown was not successful");
      return(0);
   }

   /////////////////////////////////////////////////////////////////
   //
   //  Get the Veloctiy installation directory
   //
   public String installedDir() {

      String answer = null;

      answer = standardGRONKAction("installed-dir");
      if (answer != null) {
         GoGetXML yy = new GoGetXML(answer);

         return(yy.firstElementValue("DIRECTORY"));
      } else {
         return("");
      }
   }

   /////////////////////////////////////////////////////////////////
   //
   //   Collection operations.
   //

   //
   //   Get the current status of collection services
   //   i.e., the crawler or indexer
   //
   public Integer getStatus(String collection) {

      Integer crawler_running = 3;
      Integer indexer_running = 2;
      Integer unknown = 1;
      Integer all_idle = 0;
      Integer absolutely_lost = -1;

      if ( collection == null ) {
         return(absolutely_lost);
      }

      if (cEX(collection)) {
         String actionString = "get-status&collection=" + collection;

         String answer = standardGRONKAction(actionString);

         if (answer != null) {
            GoGetXML yy = new GoGetXML(answer);

            String statval = yy.firstElementValue("DATA");

            if (statval.equals("Indexer running")) {
               return(indexer_running);
            } else if (statval.equals("Crawler running")) {
               return(crawler_running);
            } else if (statval.equals("Crawler and indexer are idle.")) {
               return(all_idle);
            } else {
               return(unknown);
            }
         }
      }

      return(absolutely_lost);
      
   }

   ////////////////////////////////////////////////////////////////
   // 
   //   Does a collection exist on the target host
   //
   private Boolean cEX(String collection) {

      if ( collection == null ) {
         return(false);
      }

      String actionString = "check-collection-exists&collection=" + collection;

      String answer = standardGRONKAction(actionString);

      if (answer != null) {
         try {
            GoGetXML yy = new GoGetXML(answer);

            if (yy.firstElementValue("OUTCOME").equals("Yes")) {
               return(true);
            }
         } catch (java.lang.NullPointerException npe) {
            return(false);
         }
      }

      return(false);
      
   }

   public Boolean checkCollectionExists() {

      return(cEX(this.collection));

   }

   public Boolean checkCollectionExists(String collection) {

      return(cEX(collection));

   }

   //
   //   Get a list of all the collections on the target.
   //
   private String getCollectionXML() {

      GoGetXML yy = null;
      String actionString = "get-collection";

      String answer = standardGRONKAction(actionString + "&collection=" + this.collection + "&type=binary");
      //System.out.println(answer);

      return(answer);
      
   }

   public String getCollection() {

      if (this.collection == null ) {
         return(null);
      }

      return(this.getCollectionXML());

   }

   public String getCollection(String cName) {

      this.collection = cName;

      return(this.getCollectionXML());
   }

   //
   //   Get a list of all the collections on the target.
   //
   private GoGetXML getCollectionFileXML(String cName) {

      GoGetXML yy = null;
      this.collection = cName;

      String answer = this.getCollection();
      //System.out.println(answer);

      if (answer != null) {
         yy = new GoGetXML(answer);
      } else {
         System.out.println("getCollectionIndexFileList():  No node returned");
         return(null);
      }

      return(yy);
      
   }

   public Set grnkGetCollectionIndexMergeFileList(String cName) {

      GoGetXML yy = this.getCollectionFileXML(cName);
      return(yy.xPathAttrGet("//vse-index-merging-status/vse-index-file", "name"));

   }

   public Integer grnkGetCrawlerStatusIntAttr(String cName, String attrName) {
      GoGetXML gg = this.getCollectionFileXML(cName);
      return(Integer.valueOf((String)gg.xPathAttrGet("//vse-collection/vse-status/crawler-status", attrName).iterator().next()));
   }

   public Integer grnkGetIndexerStatusIntAttr(String cName, String attrName) {
      GoGetXML gg = this.getCollectionFileXML(cName);
      return(Integer.valueOf((String)gg.xPathAttrGet("//vse-collection/vse-status/vse-index-status", attrName).iterator().next()));
   }

   public Set grnkGetCollectionIndexFileList(String cName) {

      GoGetXML yy = this.getCollectionFileXML(cName);
      return(yy.xPathAttrGet("//vse-index-status/vse-index-file", "name"));

   }

   //
   //   Get a crawl directory
   //
   public String getCollectionCrawlDirectory(String cName) {

      GoGetXML yy = null;
      String actionString = "get-crawl-dir&collection=" + cName;

      String answer = standardGRONKAction(actionString);
      //System.out.println(answer);

      if (answer != null) {
         yy = new GoGetXML(answer);
      } else {
         System.out.println("getCollectionCrawlDirectory():  No node returned");
         return(null);
      }

      //return(yy.getCollectionList());
      //Iterator itr = yy.xPathValueGet("//REMOP/DIRECTORY").iterator();
      return((String)yy.xPathValueGet("//REMOP/DIRECTORY").iterator().next());
      //return((String)itr.next());
      
   }

   //
   //   Get a list of all the collections on the target.
   //
   public Set getCollectionList() {

      GoGetXML yy = null;
      String actionString = "get-collection-list";

      String answer = standardGRONKAction(actionString);
      //System.out.println(answer);

      if (answer != null) {
         yy = new GoGetXML(answer);
      } else {
         System.out.println("getCollectionList():  No node returned");
         return(null);
      }

      //return(yy.getCollectionList());
      return(yy.xPathValueGet("//COLLECTION/COLLECTION_NAME"));
      
   }

   //
   //   Find core files.
   //
   public Set findCoreFiles() {

      GoGetXML yy = null;
      String actionString = "find-core";

      String answer = standardGRONKAction(actionString);
      //System.out.println(answer);

      if (answer != null) {
         yy = new GoGetXML(answer);
      } else {
         System.out.println("findCoreFiles():  No node returned");
         return(null);
      }

      //return(yy.getCollectionList());
      return(yy.xPathValueGet("//FINDFILE/FILEPATH"));
      
   }

   //
   //   Find cgi core files.
   //
   public Set findCollectionCoreFiles(String cName) {

      GoGetXML yy = null;
      String actionString = "find-collection-core&collection=" + cName;

      String answer = standardGRONKAction(actionString);
      //System.out.println(answer);

      if (answer != null) {
         yy = new GoGetXML(answer);
      } else {
         System.out.println("findCollectionCoreFiles():  No node returned");
         return(null);
      }

      //return(yy.getCollectionList());
      return(yy.xPathValueGet("//FINDFILE/FILEPATH"));
      
   }

   //
   //   Find cgi core files.
   //
   public Set findCGICoreFiles() {

      GoGetXML yy = null;
      String actionString = "find-cgi-core";

      String answer = standardGRONKAction(actionString);
      //System.out.println(answer);

      if (answer != null) {
         yy = new GoGetXML(answer);
      } else {
         System.out.println("findCGICoreFiles():  No node returned");
         return(null);
      }

      //return(yy.getCollectionList());
      return(yy.xPathValueGet("//FINDFILE/FILEPATH"));
      
   }

   //
   //   Get a list of all the collections on the target.
   //
   public Set getServicePidList(String cName, String vSrvc) {

      GoGetXML yy = null;
      String actionString = "get-pid-list&collection=" + cName + "&service=" + vSrvc;

      String answer = standardGRONKAction(actionString);
      //System.out.println(answer);

      if (answer != null) {
         yy = new GoGetXML(answer);
      } else {
         System.out.println("getServicePidList():  No node returned");
         return(null);
      }

      //return(yy.getPidList());
      return(yy.xPathValueGet("//PIDLIST/PID"));
      
   }

   ///////////////////////////////////////////////////////////
   //
   //   This section is dedicated to the death of services
   //
   //
   //   This is the internal method to kill a service by
   //   collection and process id.  It will kill the service
   //   with the specified pid.
   //   
   private Boolean killByPID(String collection, String PID) {

      if ( collection == null ) {
         return(false);
      }

      if ( PID == null ) {
         return(false);
      }

      String actionString = "kill-service-kids" + 
                            "&service=supplied" +
                            "&collection=" + collection +
                            "&ppid=" + PID;

      String answer = standardGRONKAction(actionString);

      if (answer != null) {
         GoGetXML yy = new GoGetXML(answer);

         if (yy.firstElementValue("OUTCOME").equals("Success")) {
            return(true);
         }
      }

      return(false);
      
   }

   //
   //   Kill a service by process and collection
   //
   public Boolean killServicePID(String collection, String PID) {
  
      return(killByPID(collection, PID));

   }

   //
   //   This is the internal method to kill any service for 
   //   the specified collection.
   //
   private Boolean killByCollection(String service, String collection) {

      if ( collection == null ) {
         return(false);
      }

      String actionString = "kill-service-kids" + 
                            "&service=" + service +
                            "&collection=" + collection;

      String answer = standardGRONKAction(actionString);

      if (answer != null) {
         GoGetXML yy = new GoGetXML(answer);

         if (yy.firstElementValue("OUTCOME").equals("Success")) {
            return(true);
         }
      }

      return(false);
      
   }

   //
   //   Kill the crawler for the specified collection
   //
   public Boolean killCrawler(String collection) {
  
      return(killByCollection("crawler", collection));

   }

   //
   //   Kill the indexer for the specified collection
   //
   public Boolean killIndexer(String collection) {
  
      return(killByCollection("indexer", collection));

   }

   //
   //   Kill the query service
   //
   public Boolean killQueryService(String collection) {
  
      return(killByCollection("query", collection));

   }

   //
   //   Kill the crawler and indexer for the specified collection
   //
   public Boolean killCrawlerAndIndexer(String collection) {
  
      return(killByCollection("crindex", collection));

   }

   //
   //  Remove a collection; the hard way.
   //
   public Boolean rmCollection(String collection) {

      if ( collection == null ) {
         return(false);
      }

      String actionString = "rm-collection&collection=" + collection;

      String answer = standardGRONKAction(actionString);

      if (answer != null) {
         GoGetXML yy = new GoGetXML(answer);

         if (yy.firstElementValue("OUTCOME").equals("Yes")) {
            return(true);
         }
      }

      return(false);
      
   }

   //
   //  These represent older means of killing services within gronk
   //
   private Boolean internalBS(String action, String collection) {

      if ( collection == null ) {
         return(false);
      }

      String actionString = action + "&collection=" + collection;

      String answer = standardGRONKAction(actionString);

      if (answer != null) {
         GoGetXML yy = new GoGetXML(answer);

         if (yy.firstElementValue("OUTCOME").equals("Yes")) {
            return(true);
         }
      }

      return(false);
      
   }

   //
   //   Stop the crawler for the specified collection
   //
   public void stopCrawler(String collection) {
  
      internalBS("stop-crawler", collection);

   }

   //
   //   Stop the indexer for the specified collection
   //
   public void stopIndexer(String collection) {
  
      internalBS("stop-index", collection);

   }

   //
   //   Stop the crawler and indexer for the specified collection
   //
   public void stopCrawlerAndIndexer(String collection) {
  
      internalBS("stop-crindex", collection);

   }


   //
   //   Kill ALL SERVICE without regard to ownership
   //   You should have absolute control of the target box if
   //   you are going to do this.
   //   The VIVKILLALL environment variable must be = "True"
   //
   public void killAllServices() {

      if (this.gronkEnv.getVivKillAll().equals("True")) {
         standardGRONKAction("kill-all-services");
      }
      return;
   }

   //
   //   Kill query services
   //   The VIVKILLALL environment variable must be = "True"
   //
   public void killQueryServices() {

      if (this.gronkEnv.getVivKillAll().equals("True")) {
         standardGRONKAction("kill-query-services");
      }
      return;
   }

   //
   //   Kill admin processes
   //   The VIVKILLALL environment variable must be = "True"
   //
   public void killAdmin() {

      if (this.gronkEnv.getVivKillAll().equals("True")) {
         standardGRONKAction("kill-admin");
      }
      return;
   }

   public GRONK() {

      commonInit();

   }

   public GRONK(String collection) {

      this.collection = collection;
      commonInit();

   }

}
