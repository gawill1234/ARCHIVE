import java.io.*;
import java.util.Map;
import java.util.HashSet;
import java.util.Set;

import net.entropysoft.eci.Content;
import net.entropysoft.eci.Credentials;
import net.entropysoft.eci.Document;
import net.entropysoft.eci.Folder;
import net.entropysoft.eci.Item;
import net.entropysoft.eci.ID;
import net.entropysoft.eci.Property;
import net.entropysoft.eci.Permission;
import net.entropysoft.eci.PermissionType;
import net.entropysoft.eci.Repository;
import net.entropysoft.eci.ResultList;
import net.entropysoft.eci.ObjectDefinition;

import net.entropysoft.eci.fnetp8ws.P8WSContentProvider;
import net.entropysoft.eci.fnetp8ws.P8WSContentProviderFactory;

import net.entropysoft.eci.sharepoint.ws.SharepointContentProvider;
import net.entropysoft.eci.sharepoint.ws.SharepointContentProviderFactory;

import net.entropysoft.eci.opentext.LivelinkContentProvider;
import net.entropysoft.eci.opentext.LivelinkContentProviderFactory;

import net.entropysoft.eci.oracle.ucm.ConnectionType;
import net.entropysoft.eci.oracle.ucm.UCMContentProvider;
import net.entropysoft.eci.oracle.ucm.UCMContentProviderFactory;

import net.entropysoft.eci.sharepoint.ws.items.*;

import net.entropysoft.eci.spi.IContentProvider;
import net.entropysoft.eci.spi.IContentProviderFactory;

import net.entropysoft.eci.spi.ProviderResultList;
import net.entropysoft.search.QueryCriteria;
import net.entropysoft.searchparser.SearchParser;

public class myConnection {

   private static Repository repository;
   private static IContentProviderFactory factory;
   private static IContentProvider provider;

   //private static String username = "ceadmin";
   //private static String pw = "Baseball123";
   //private static String domain = "FNCEDomain";

   //private static String username = "administrator";
   //private static String pw = "Mustang5";
   //private static String domain = "sptest";

   private static String username;
   private static String pw;
   private static String domain;
   private static String port;
   private static String connPort;
   private static String connWebPort;
   private static String connStore;
   private static String connSite;
   private static String cgiParams;
   private static String connType;

   myConnection(String connectorName, String site,
                String user, String pw, String domain, String sport) {

      this.username = user;
      this.pw = pw;
      this.domain = domain;
      this.connSite = site;
      if (sport != "")
         this.connPort = sport;

      System.out.println("myConnection:" + connectorName);

      if (connectorName.equals("sharepoint")) {
         this.connectSharepoint();
      } else if (connectorName.equals("UCM")) {
         if (sport != "")
            this.socketConnectOracleUCM();
         else
            this.connectOracleUCM();
      } else if (connectorName.equals("livelink")) {
         this.port = "80";
         //#this.cgiParams = "/Livelink/livelink.exe";
         this.cgiParams = "/OTCS/livelink.exe";
         this.connectLiveLink();
      } else {
         System.out.println("Connector " + connectorName + " unknown.");
      }
   }

   myConnection(String connectorName, String site,
                String user, String pw, String domain,
                String sPort, String wPort, String sStore) {


      this.username = user;
      this.pw = pw;
      this.domain = domain;
      this.connSite = site;
      this.connPort = sPort;
      this.connWebPort = this.port = wPort;
      this.connStore = sStore;

      System.out.println("myConnection:" + connectorName);

      if (connectorName.equals("filenetp8")) {
         this.connectFileNetP8();
      } else if (connectorName.equals("sharepoint")) {
         this.connectSharepoint();
      } else if (connectorName.equals("UCM")) {
         //this.connectOracleUCM();
         this.socketConnectOracleUCM();
      } else if (connectorName.equals("livelink")) {
         this.port = "80";
         //this.cgiParams = "/Livelink/livelink.exe";
         this.cgiParams = "/OTCS/livelink.exe";
         this.connectLiveLink();
      } else {
         System.out.println("Connector " + connectorName + " unknown.");
      }
   }

   private void connectOracleUCM() {

      Property[] myProp;
      int i;

      this.connType = "OracleUCM";

      this.repository = new Repository();
      this.repository.setName("UCM");
      this.repository.setProperty(UCMContentProvider.PROP_CONNECTION_TYPE,
                                  ConnectionType.WEB);
      this.repository.setProperty(UCMContentProvider.PROP_WEB_URL,
                                  this.connSite);

      this.factory = new UCMContentProviderFactory();

      this.repository.setMappings(
                      this.factory.getDefaultMappings(this.repository));
     
      this.provider = factory.getContentProvider(this.repository,
                      new Credentials(this.username, this.pw, this.domain));

      //this.repository.setProperty(UCMContentProvider.PROP_WEB_URL,
      //                            "http://testbed6-6.test.vivisimo.com/idc/");

      myProp = this.repository.getProperties();
      for (i = 0; i < myProp.length; i++) {
         System.out.println("KEY: " + myProp[i].getKey());
         System.out.println("VAL: " + myProp[i].getValue());
      }
   }

   private void connectSharepoint() {

      Property[] myProp;
      int i;

      this.connType = "sharepoint";
      this.repository = new Repository();
      this.factory = new SharepointContentProviderFactory();

      this.repository.setName("Basic");
      //this.repository.setProperty(
      //                SharepointContentProvider.SHAREPOINT_URL_PROPERTY,
      //                "http://testbed18-1.test.vivisimo.com/");
      this.repository.setProperty(
                      SharepointContentProvider.SHAREPOINT_URL_PROPERTY,
                      this.connSite);

      this.repository.setMappings(
                      this.factory.getDefaultMappings(this.repository));

      this.provider = factory.getContentProvider(this.repository,
                      new Credentials(this.username, this.pw, this.domain));

      myProp = this.repository.getProperties();
      for (i = 0; i < myProp.length; i++) {
         System.out.println("KEY: " + myProp[i].getKey());
         System.out.println("VAL: " + myProp[i].getValue());
      }
   }

   private void connectLiveLink() {

      Property[] myProp;
      int i;

      this.connType = "livelink";
      this.repository = new Repository();

      this.repository.setName("livelink");
      this.repository.setProperty(LivelinkContentProvider.PROP_HOST, this.connSite);
      this.repository.setProperty(LivelinkContentProvider.PROPERTY_PORT, this.port);
      this.repository.setProperty(LivelinkContentProvider.PROPERTY_CGI, this.cgiParams);
      this.repository.setProperty(LivelinkContentProvider.PROPERTY_HTTPUSERNAME, this.username);
      this.repository.setProperty(LivelinkContentProvider.PROPERTY_HTTPPASSWORD, this.pw);

      this.factory = new LivelinkContentProviderFactory();
      this.repository.setMappings(
                      this.factory.getDefaultMappings(this.repository));

      this.provider = factory.getContentProvider(this.repository,
                      new Credentials(this.username, this.pw, this.domain));

      myProp = this.repository.getProperties();
      for (i = 0; i < myProp.length; i++) {
         System.out.println("KEY: " + myProp[i].getKey());
         System.out.println("VAL: " + myProp[i].getValue());
      }
   }

   private void connectFileNetP8() {

      this.connType = "filenetp8";
      this.repository = new Repository();
      this.factory = new P8WSContentProviderFactory();

      //this.repository.setProperty(P8WSContentProvider.PROP_OBJECT_STORE,
      //                       "Vivisimo Store");
      //this.repository.setName("filenetp8");
      //this.repository.setProperty(P8WSContentProvider.PROP_REMOTE_SERVER_URL,
      //                       "http://192.168.0.43:7001/wsi/FNCEWS40SOAP");
      //this.repository.setProperty(
      //       P8WSContentProvider.PROP_REMOTE_SERVER_FILE_TRANSFER_URL,
      //       "http://192.168.0.43:7001/wsi/FNCEWS40MTOM");
      //this.repository.setProperty(P8WSContentProvider.PROP_WORKPLACE_URL,
      //                       "http://192.168.0.43:7001/WorkplaceXT");
      //  connPort = 9443  connWebPort = 9080
      this.repository.setProperty(P8WSContentProvider.PROP_OBJECT_STORE,
                             this.connStore);
      this.repository.setName("filenetp8");
      this.repository.setProperty(P8WSContentProvider.PROP_REMOTE_SERVER_URL,
                             "https://" + this.connSite + ":" + this.connPort + "/wsi/FNCEWS40SOAP");
      this.repository.setProperty(
             P8WSContentProvider.PROP_REMOTE_SERVER_FILE_TRANSFER_URL,
             "https://" + this.connSite + ":" + this.connPort + "/wsi/FNCEWS40MTOM");
      this.repository.setProperty(P8WSContentProvider.PROP_WORKPLACE_URL,
                             "http://" + this.connSite + ":" + this.port + "/WorkplaceXT");

      this.repository.setMappings(
                      this.factory.getDefaultMappings(this.repository));

      this.provider = factory.getContentProvider(this.repository,
                      new Credentials(this.username, this.pw, this.domain));
   }

   private void socketConnectOracleUCM() {

      if (this.connPort == null) {
         this.port = "4444";
      }

      System.out.println("UCM, here I come ...");
      System.out.println("PORT: " + this.connPort);
      System.out.println("SITE: " + this.connSite);

      this.connType = "OracleUCM";
      this.repository = new Repository();

      this.repository.setName("UCM");
      this.repository.setProperty(UCMContentProvider.PROP_CONNECTION_TYPE, ConnectionType.SOCKET);
      this.repository.setProperty(UCMContentProvider.PROP_SOCKET_HOST, this.connSite);
      this.repository.setProperty(UCMContentProvider.PROP_SOCKET_PORT, this.connPort);

      this.factory = new UCMContentProviderFactory();
      this.repository.setMappings(this.factory.getDefaultMappings(this.repository));
      this.provider = factory.getContentProvider(this.repository,
                      new Credentials(this.username, this.pw, this.domain));

   }

   public String getConnectorType() {
      return(this.connType);
   }

   public void dumpDefs() {
 
      ObjectDefinition[] objList, ob2;
      Folder hLocation;
      int objcount, doh;

      hLocation = this.provider.getRootFolder();

      //hLocation = (Folder)this.provider.getItemByAbsPath("/");
      objList = this.provider.getObjectDefinitions(hLocation.getId(),
                                                   Item.CONTAINER);
      objcount = objList.length;
      for (doh = 0; doh < objcount; doh++) {
         System.out.println("Desc: " + objList[doh].getDisplayName());
         System.out.println("UID:  " + objList[doh].getId().getUid());
         System.out.println("Base: " + objList[doh].getBaseTypeId().getUid());
         //this.dumpDocumentPermissions(objList[doh].getId());
      }

      return;
   }

   public void dumpDocumentPermissions(ID id) {

      Permission[] permissions = this.provider.getPermissions(id);

      System.out.println("ACLS : " + permissions.length);

      for (Permission permission : permissions) {
         System.out.println("NAME : " + permission.getEntry().getName());
         PermissionType[] types = permission.getRights();
         for (PermissionType type : types) {
            System.out.println("ID   : " + type.getId());
            System.out.println("LABEL: " + type.getLabel());
         }
      }

      return;
   }

   //
   //   Internal method to build the Document for createDocument
   //
   private Document buildDocumentFromDoc(String myDocument) {

      mimeType thing = new mimeType(myDocument);
      Document document = new Document();
      File tmpfile = new File(myDocument);

      document.setName(tmpfile.getName());
      document.setMimeType(thing.getMimeType());

      return(document);
   }

   //
   //   Internal method to build the Content for createDocument
   //
   private Content buildContentFromDoc(String myDocument) {

      mimeType thing = new mimeType(myDocument);
      Content content = new Content();
      File file = new File(myDocument);

      //System.out.println("CONTENT: " + file.getParent());
      //System.out.println("CONTENT: " + file.getName());
     
      content.setContentLength(file.length());
      try {
         content.setStream(new FileInputStream(file));
      } catch (Exception e) {
         return(null);
      }
      content.setMimeType(thing.getMimeType());

      return(content);
   }

   //
   //   Create a new folder.  Painful.
   //
   public boolean createBlogPost(String folderName, String myDocument) {

      Folder hLocation;
      Content[] thingCnt;
      ID myid;
      thingCnt = new Content[1];

      Item thingy = this.buildDocumentFromDoc(myDocument);
      thingCnt[0] = this.buildContentFromDoc(myDocument);
   
      hLocation = (Folder)this.provider.getItemByAbsPath(folderName);
      thingy.setProperty("PostCategory", 4);
      thingy.setProperty("PublishedDate", "4/4/2011");
      //thingy.setProperty("sharepoint_moderationInformationStatus", "Approved");
      //System.out.println(hLocation.getId().toString());
      //System.out.println(hLocation.getPath());
   
      try {
         myid = this.provider.createItem(thingy, thingCnt, hLocation.getId());
         thingy = this.provider.getItem(myid);
         //thingy.setProperty("sharepoint_moderationInformationStatus",
         //                   "Approved");
         //thingy.setProperty("sharepoint_HasPublishedVersion", "true");
         this.provider.promote(myid);
         //this.provider.updateItem(thingy);
      } catch (Exception e) {
         System.out.println("createBlogPost():  KABOOM");
         e.printStackTrace();
         return(false);
      }

      return(true);
   }
   //
   //   Create a new folder.  Painful.
   //
   public boolean createDocument(String folderName, String myDocument) {

      Folder hLocation = null;
      Item thingy = null;

      Content[] thingCnt;
      thingCnt = new Content[1];

      try {
         thingy = this.buildDocumentFromDoc(myDocument);
         thingCnt[0] = this.buildContentFromDoc(myDocument);
         System.out.println("createDocument():  Doc Name, " + thingy.getName());
      } catch (Exception e) {
         System.out.println("createDocument():  Barfed on buildDocument");
         return(false);
      }
   
      if (folderName != null) {
         //
         //   If the "add to" folder is null, there will be no location id
         //   so skip this and go ahead with a null location.  Mostly for UCM.
         //
         try {
            hLocation = (Folder)this.provider.getItemByAbsPath(folderName);
         } catch (Exception e) {
            System.out.println("createDocument():  barfed on getItemByAbsPath, " + folderName);
            return(false);
         }
      }
   
      try {
         //
         //  Adding an item with no location ID will create a document that
         //  is not attached to any folder.  Added this mostly for UCM, but it
         //  may work for other connectors as well.
         //
         if (hLocation != null) {
            this.provider.createItem(thingy, thingCnt, hLocation.getId());
         } else {
            this.provider.createItem(thingy, thingCnt, null);
         }
      } catch (Exception e) {
         System.out.println("createDocument():  KABOOM");
         return(false);
      }

      return(true);
   }

   //
   //   Generic Folder traversal for getting items from the
   //   folderPath.  'what' can be either Item.LEAF (Documents),
   //   Item.CONTAINER (Folders), or 0 (ALL Items).
   //
   private ResultList getFolderList(String folderPath, int what) {

      Folder hLocation = null;
      ResultList childList = null;

      try {
         hLocation = (Folder)this.provider.getItemByAbsPath(folderPath);
         childList = this.provider.getChildren(hLocation.getId(), what,
                                               0, 0, null);
      } catch (Exception e) {
         System.out.println("getFolderList(), ERROR:  " + e);
      }

      return(childList);
   }

   //
   //   Get a list of Folders within the folderPath
   //
   public ResultList getFolderList(String folderPath) {

      Item child;
      ResultList childList;
      int i;

      try {
         childList = this.getFolderList(folderPath, Item.CONTAINER);
      } catch (Exception e) {
         return(null);
      }

      //for (i = 0; i < childList.getResults().length; i++ ) {
      //   child = (Item)childList.getResults()[i];
      //   System.out.println("     " + i + ": " + child.getName());
      //}

      return(childList);
   }

   //
   //   Get a list of Documents within the folderPath
   //
   public ResultList getDocumentList(String folderPath) {

      Item child;
      ResultList childList;
      int i;
   
      try {
         childList = this.getFolderList(folderPath, Item.LEAF);
         for (i = 0; i < childList.getResults().length; i++ ) {
            child = (Item)childList.getResults()[i];
            System.out.println(child.getName());
         }
      } catch (Exception e) {
         System.out.println("getDocumentList(), ERROR:  " + e);
         return(null);
      }

      //for (i = 0; i < childList.getResults().length; i++ ) {
      //   child = (Item)childList.getResults()[i];
      //   System.out.println(child.getName());
      //}

      return(childList);
   }

   //
   //   Update a document using major version (3 = CHECKIN_MAJOR_VERSION)
   //
   //     public static final int	CHECKIN_KEEP_LOCK	0
   //     public static final int	CHECKIN_MAJOR_VERSION	3
   //     public static final int	CHECKIN_MINOR_VERSION	2
   //     public static final int	CHECKIN_RELEASE_LOCK	1
   //     public static final int	GETVERSIONS_OPTION_ALL	0
   //     public static final int	GETVERSIONS_OPTION_LATEST	1
   //     public static final int	GETVERSIONS_OPTION_LATESTMAJOR	2
   //
   public boolean updateDocument(String folderName, String myDocument,
                                 boolean usedirasis) {

      String fullName;

      Document dLocation;
      Content[] thingCnt;
      thingCnt = new Content[1];
      File glunk = new File(myDocument);

      int vers = this.provider.CHECKIN_MAJOR_VERSION;

      if ( usedirasis ) {
         fullName = folderName;
      } else {
         if (folderName == "/") {
            fullName = "/" + myDocument;
         } else {
            fullName = folderName + "/" + glunk.getName();
         }
      }

      dLocation = (Document)this.provider.getItemByAbsPath(fullName);
      thingCnt[0] = this.buildContentFromDoc(myDocument);
   
      try {
         this.provider.checkin(vers, dLocation, 
                               thingCnt, "Test checkin");
      } catch (Exception e) {
         System.out.println("updateDocument():  Kaboom!!!");
         e.printStackTrace();
         return(false);
      }

      return(true);
   }

   public boolean updateDocument(int demote, String folderName,
                                 String myDocument) {

      String fullName;
      Document dLocation;

      if (folderName == "/") {
         fullName = "/" + myDocument;
      } else {
         fullName = folderName + "/" + myDocument;
      }

      dLocation = (Document)this.provider.getItemByAbsPath(fullName);

      //System.out.println(dLocation.getId().toString());
      //System.out.println(dLocation.getName());
   
      try {
         this.provider.demote(dLocation.getId());
      } catch (Exception e) {
         return(false);
      }

      return(true);
   }

   public void deleteFolderPath(File folderName, String hangLocation) {

      File folderToBuild, folderAsHanger;

      System.out.println("Del Dirname : " + folderName.getParent());
      System.out.println("Del Basename: " + folderName.getName());
      try {
         this.deleteFolder(folderName.getName(), folderName.getParent());
      } catch (Exception e) {
         return;
      }

      if (!folderName.getParent().equals(hangLocation)) {
         folderToBuild = new File(folderName.getName());
         folderAsHanger = new File(folderName.getParent());
         this.deleteFolderPath(folderAsHanger, hangLocation);
      }

      return;
   }

   //
   //   Builds a full path up to and including the supplied
   //   folder name.  So if:
   //         folderName = hello
   //         hangLocation = /a/b/c/d/e
   //
   //   Even if none of the above folders exist, at the end
   //   there will exist /a/b/c/d/e/hello
   //
   public void createFolderPath(File folderName, String hangLocation) {

      File folderToBuild, folderAsHanger;

      try {
         if (folderName.getParent() != null) {
            if (!folderName.getParent().equals(hangLocation)) {
               folderToBuild = new File(folderName.getName());
               folderAsHanger = new File(folderName.getParent());
               this.createFolderPath(folderAsHanger, hangLocation);
            }
         } else {
            System.out.println("folderName.getParent() is null");
            return;
         }
      } catch (Exception e) {
         return;
      }

      String fullHang = this.combineThePathesRight(hangLocation,
                                                   folderName.getParent());

      System.out.println("Create Dirname : " + fullHang);
      System.out.println("Create Basename: " + folderName.getName());
      try {
         this.createFolder(folderName.getName(), fullHang);
      } catch (Exception e) {
         System.out.println("createFolderPath():  KABOOM!");
         return;
      }

      return;
   }

   private String findTheIdIWant(String IdDesc) {
 
      ObjectDefinition[] objList, ob2;
      Folder hLocation;
      int objcount, doh;

      hLocation = this.provider.getRootFolder();

      //hLocation = (Folder)this.provider.getItemByAbsPath("/");
      objList = this.provider.getObjectDefinitions(hLocation.getId(),
                                                   Item.CONTAINER);
      objcount = objList.length;
      for (doh = 0; doh < objcount; doh++) {
         if ( IdDesc.equals(objList[doh].getDisplayName()) ) {
            return(objList[doh].getId().getUid());
         }
      }

      return null;
   }

   private String combineThePathesRight(String hangLocation,
                                        String fullPath) {

      String myPath, newHang, newPath;
      int endcharH, endcharF;

      //return(hangLocation + fullPath);
      //System.out.println("combineThe...:  " + fullPath);

      myPath = newHang = newPath = null;
      endcharH = endcharF = 0;

      if (hangLocation == null) {
         myPath = fullPath;
      } else if (fullPath == null) {
         myPath = hangLocation;
      } else if (fullPath == "") {
         myPath = hangLocation;
      } else {
         endcharH = hangLocation.length() - 1;
         endcharF = fullPath.length();

        if (fullPath.charAt(0) == '/') {
            newPath = fullPath.substring(1, endcharF);
         } else {
            newPath = fullPath;
         }

         if (endcharH >= 0) {
            System.out.println("HANGER " + hangLocation);
            if (hangLocation.charAt(endcharH) == '/') {
               if (endcharH > 0) {
                  newHang = hangLocation.substring(0, endcharH - 1);
               } else {
                  newHang = hangLocation;
               }
            } else {
               newHang = hangLocation;
            }

            myPath = newHang + "/" + newPath;
         }
      }

      System.out.println("MYPATH:"+myPath+":");
      return(myPath);
  
   }

   //
   //   Create a new folder.  Painful.
   //
   public boolean createListItemAttach(String folderName, String myDocument) {

      Document hLocation;
      Content[] thingCnt;
      ID myid;
      thingCnt = new Content[1];

      Item thingy = this.buildDocumentFromDoc(myDocument);
      thingCnt[0] = this.buildContentFromDoc(myDocument);
   
      hLocation = (Document)this.provider.getItemByAbsPath(folderName);
   
      try {
         myid = this.provider.createItem(thingy, thingCnt, hLocation.getId());
      } catch (Exception e) {
         System.out.println("createListItemAttach():  KABOOM");
         e.printStackTrace();
         return(false);
      }

      return(true);
   }

   public boolean createListBunch(String folderName, String myDocument,
                                  int amount, String description) {

      String temdoc;
      int i;

      for ( i = 0; i < amount; i++) {
         temdoc = myDocument + '-' + i;
         this.createList(temdoc, folderName, description);
      }

      return(true);
   }

   public boolean deleteListBunch(String folderName, String myDocument,
                                  int amount) {

      String temdoc;
      int i;

      for ( i = 0; i < amount; i++) {
         temdoc = myDocument + '-' + i;
         this.deleteAnyItem(folderName, temdoc);
      }

      return(true);
   }


   public boolean createListItemBunch(String folderName, String myDocument, int amount) {

      Folder hLocation;
      String temdoc;
      int i;

      hLocation = (Folder)this.provider.getItemByAbsPath(folderName);

      for ( i = 0; i < amount; i++) {
         temdoc = myDocument + '-' + i;
         Item thingy = this.buildDocumentFromDoc(temdoc);
   
         try {
            this.provider.createItem(thingy, null, hLocation.getId());
         } catch (Exception e) {
            System.out.println("createListItemBunch():  KABOOM");
            return(false);
         }
      }

      return(true);
   }

   public boolean createListItem(String folderName, String myDocument) {

      Folder hLocation;
      Item thingy = this.buildDocumentFromDoc(myDocument);
   
      hLocation = (Folder)this.provider.getItemByAbsPath(folderName);
   
      try {
         System.out.println("createListItem():  ========================");
         this.provider.createItem(thingy, null, hLocation.getId());
         this.dumpDocumentPermissions(hLocation.getId());
         System.out.println("createListItem():  ========================");
      } catch (Exception e) {
         System.out.println("createListItem():  KABOOM");
         return(false);
      }

      return(true);
   }

   public boolean createList(String folderName,
                             String hangLocation,
                             String description) {

      Item thingy = new Folder();
      Folder hLocation;

      String IdString = this.findTheIdIWant("GenericList");
      String repoName = this.repository.getName();
      ID id = new ID(repoName, IdString);

      //System.out.println("Folder: " + folderName);
      //System.out.println("Hang Where: " + hangLocation);
   
      hLocation = (Folder)this.provider.getItemByAbsPath(hangLocation);
      thingy.setName(folderName);
      thingy.setObjectClass(id);
      if ( description != null ) {
         thingy.setComment(description);
      }
   
      try {
         this.provider.createItem(thingy, null, hLocation.getId());
      } catch (Exception e) {
         System.out.println("createList():  KABOOOOMM");
         System.out.println("createList():  ========================");
         System.out.println("createList():  " + thingy.getName());
         String junk = hangLocation + thingy.getName();
         System.out.println("createList():  " + junk);
         hLocation = (Folder)this.provider.getItemByAbsPath(junk);
         this.dumpDocumentPermissions(hLocation.getId());
         System.out.println("createList():  ========================");
         return(false);
      }

      return(true);
   }

   //
   //   Create a new folder.  Painful.
   //
   public boolean createFolder(String folderName, String hangLocation) {

      Item thingy = new Folder();
      Folder hLocation;
   
      hLocation = (Folder)this.provider.getItemByAbsPath(hangLocation);
      System.out.println("createFolder():" + folderName);
      thingy.setName(folderName);
      System.out.println("createFolder():" + thingy.getName());
   
      try {
         this.provider.createItem(thingy, null, hLocation.getId());
      } catch (Exception e) {
         System.out.println("createFolder():  KABOOOOMM");
         System.out.println("createFolder(): ERROR:  " + e);
         return(false);
      }

      return(true);
   }

   public boolean deleteAnyItem(Item thingToDelete) {

      ID[] thingId;
      thingId = new ID[1];
   
      try {
         thingId[0] = thingToDelete.getId();
         this.provider.deleteItems(thingId);
      } catch (Exception e) {
         System.out.println("deleteAnyItemById():  Shazbot!!");
         return(false);
      }

      return(true);
   }

   public boolean deleteAnyItem(String hangLocation, String thingToDelete) {

      String fullName, myId;
      Item hLocation;

      ID[] thingId;
      thingId = new ID[1];

      fullName = this.combineThePathesRight(hangLocation,
                                            thingToDelete);

      try {
         hLocation = (Item)this.provider.getItemByAbsPath(fullName);
         thingId[0] = hLocation.getId();
         System.out.println("Deleting:  " + fullName);
         this.provider.deleteItems(thingId);
      } catch (Exception e) {
         System.out.println("deleteAnyItem():  " + e);
         return(false);
      }

      return(true);
   }

   public void deleteItemByName(String getRidOfIt) {

      Integer ilastDocId, icurrentDocId;

      icurrentDocId = -1;
      String gatherQry = "SELECT TOP 500 * FROM document";

      SearchParser parser = new SearchParser(new StringReader(gatherQry));
      QueryCriteria qryParsed = parser.parse();
      ProviderResultList resultList = this.provider.search(qryParsed);

      do {

         for (int i = 0; i < resultList.getResults().length; i++) {
            Item child = (Item) resultList.getResults()[i];

            String lastDocId = child.getProperty("dID").toString();
            ilastDocId = Integer.valueOf(lastDocId);
            if (icurrentDocId == -1) {
               icurrentDocId = ilastDocId;
            } else {
               if (ilastDocId < icurrentDocId) {
                  icurrentDocId = ilastDocId;
               }
            }

            String lastDocName = child.getProperty("dDocTitle").toString();
            //System.out.println(lastDocName + " -- " + getRidOfIt);
            if (lastDocName.equals(getRidOfIt)) {
               System.out.println("DOC ID: " + ilastDocId);
               System.out.println("DOC Name: " + lastDocName);
               System.out.println("Die, mother fucker, die.");
               deleteAnyItem(child);
            }
         }

         gatherQry = "SELECT TOP 500 * FROM document where dID < " + icurrentDocId;

         parser = new SearchParser(new StringReader(gatherQry));
         qryParsed = parser.parse();
         resultList = this.provider.search(qryParsed);

      } while (resultList.getResults().length > 0);
      
      return;
   }


   public void getListOfContents() {

      Integer ilastDocId, icurrentDocId;

      icurrentDocId = -1;
      String gatherQry = "SELECT TOP 50 * FROM document";

      SearchParser parser = new SearchParser(new StringReader(gatherQry));
      QueryCriteria qryParsed = parser.parse();
      ProviderResultList resultList = this.provider.search(qryParsed);

      do {

         for (int i = 0; i < resultList.getResults().length; i++) {
            Item child = (Item) resultList.getResults()[i];

            //System.out.println(child.getProperties());

            System.out.println("============================");
            System.out.println("DOCUMENT DATA");
            String lastDocId = child.getProperty("dID").toString();
            ilastDocId = Integer.valueOf(lastDocId);
            System.out.println("    ID: " + lastDocId);
            String lastDocddName = child.getProperty("dDocName").toString();
            System.out.println("    INTERNAL NAME: " + lastDocddName);
            String realName = child.getProperty("name").toString();
            System.out.println("    REAL NAME: " + realName);
            String lastDocNm = child.getName();
            System.out.println("    Name: " + lastDocNm);
            String lastDocTitle = child.getProperty("dDocTitle").toString();
            System.out.println("    Title: " + lastDocTitle);
            String lastDocUid = child.getId().getUid();
            System.out.println("    UID: " + lastDocUid);
            System.out.println("============================");

            if (icurrentDocId == -1) {
               icurrentDocId = ilastDocId;
            } else {
               if (ilastDocId < icurrentDocId) {
                  icurrentDocId = ilastDocId;
               }
            }
         }

         gatherQry = "SELECT TOP 50 * FROM document where dID < " + icurrentDocId;

         parser = new SearchParser(new StringReader(gatherQry));
         qryParsed = parser.parse();
         resultList = this.provider.search(qryParsed);

      } while (resultList.getResults().length > 0);

      return;
      
   }

   //
   //   Delete a folder (empty, non-recursive).
   //   Variant of delete Item.  Can probably be reused to delete
   //   a document.
   //
   public boolean deleteFolder(String hangLocation, String thingToDelete) {

      return( this.deleteAnyItem(hangLocation, thingToDelete) );
   }


   public boolean deleteDocument(String folderName, String docName) {

     return( this.deleteAnyItem(folderName, docName) );

   }
   public boolean deleteDocument(Item thing) {

     return( this.deleteAnyItem(thing) );

   }

   public IContentProvider getContentProvider() {

      return(this.provider);

   }

   public Folder getRootFolder() {
      
      return(this.provider.getRootFolder());
 
   }

   public ResultList getAllChildren(Folder f) {

      return(this.provider.getChildren(f.getId(), 0, 0, 0, null));

   }
}
