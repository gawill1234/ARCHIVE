// Copyright (C) 2008 Vivisimo, Inc.
// All rights reserved
//package com.vivisimo.connector;

import java.io.IOException;
import java.util.Map;
import java.util.Set;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.lang.System;

import net.entropysoft.eci.Content;
import net.entropysoft.eci.Credentials;
import net.entropysoft.eci.Document;
import net.entropysoft.eci.Folder;
import net.entropysoft.eci.Item;
import net.entropysoft.eci.Repository;
import net.entropysoft.eci.ResultList;
import net.entropysoft.eci.fnetp8ws.P8WSContentProvider;
import net.entropysoft.eci.fnetp8ws.P8WSContentProviderFactory;
import net.entropysoft.eci.spi.IContentProvider;
import net.entropysoft.eci.spi.IContentProviderFactory;

public class myBulkLoader {

	private static void parseRepository(IContentProvider provider,
			ResultList resultList) throws IOException {
		for (int i = 0; i < resultList.getResults().length; i++) {

			Item child = (Item) resultList.getResults()[i];

			System.out.println("CHILD NAME : " + child.getName() + " : " //$NON-NLS-1$ //$NON-NLS-2$
                                  + child.getId());
			System.out.println("CHILD UID  : " + child.getId().getUid());

			// Set<String> permissionsSet = processPermissions(provider, child
			// .getId());

			// for (String permission : permissionsSet) {
			// System.out.println("\t " + permission);
			// }

			// processMetadata(provider, child.getId(), null);

			// Permission[] permissions =
			// provider.getPermissions(child.getId());

			// for (Permission permission : permissions) {
			// DirectoryEntry dirEntry = permission.getEntry();
			// System.out.println("\t " + dirEntry);
			//
			// if ((dirEntry instanceof Group)
			// && (!dirEntry.getName().equals("World"))) {
			//
			// DirectoryEntry entries[] = provider
			// .getGroupMembers(dirEntry.getId());
			//
			// for (DirectoryEntry entry : entries) {
			// System.out.println("\t====" + entry);
			// }
			// }
			// PermissionType[] types = permission.getRights();

			// for (PermissionType type : types) {
			// System.out.println("\t\t" + type.getLabel());
			// }

			// DirectoryEntry entries[] = provider.getGroupMembers(dirEntry
			// .getId());
			//
			// for (DirectoryEntry entry : entries) {
			// if (entry instanceof Person) {
			//
			// Person person = (Person) entry;
			//
			// System.out.println("\t\t Name : " + person.getName()
			// + " Person : " + person.getUserPrincipal());
			// }
			// }
			// }

			if (child instanceof Document) {

				System.out
						.println("\t______________Document properties_______________"); //$NON-NLS-1$

				Document document = (Document) child;

				Map<?, ?> properties = document.getProperties();

				Set<?> propertyKey = properties.keySet();

				System.out.println("Document properties for "
						+ document.getName());

				for (Object key : propertyKey) {
					System.out.println(key + " : " + properties.get(key));

				}

				int pageCount = provider.getPageCount(document.getId());

				System.out.println("PAGE COUNT : " + pageCount);

				if (pageCount > 0) {
					for (int j = 0; j < pageCount; j++) {
						Content contentHolder = provider.getContent(document
								.getId(), j);

						System.out.println("=========="
								+ contentHolder.getMimeType());

					}
				}
			} else if (child instanceof Folder) {
				System.out.println("\t+++++++Folder properties+++++++"); //$NON-NLS-1$

				 Map<?, ?> properties = child.getProperties();
				
				 Set<?> propertyKey = properties.keySet();
				
				 for (Object key : propertyKey) {
				 System.out.println(key + " : " + properties.get(key));
				 }

				ResultList holder = provider.getLightweightChildren(child
						.getId(), 0, 0, 0);

				// System.out.println("Children of folder "
				// + holder.getTotalRows());

				parseRepository(provider, holder);
			} else {
				System.out
						.println("}}}}}}}}}}}}}}}Something else{{{{{{{{{{{{{{{"); //$NON-NLS-1$

				Map<?, ?> properties = child.getProperties();

				Set<?> propertyKey = properties.keySet();

				for (Object key : propertyKey) {
					System.out.println(key + " : " + properties.get(key)); //$NON-NLS-1$
				}
				ResultList holder = provider.getChildren(child.getId(), 0, 0,
						0, null);
				parseRepository(provider, holder);
			}
		}

	}

   public static void mimeDumper(String dirName) {

      File[] myDirs, myFiles;
      mimeType myMime;
      File singleFileOrDir;
      int dcount, di, fcount, fi;
      fileList slinky = new fileList();
      
      singleFileOrDir = new File(dirName);
     
      try {
         myDirs = slinky.getDirList(singleFileOrDir);
         dcount = myDirs.length;
         for (di = 0; di < dcount; di++) {
            mimeDumper(myDirs[di].getAbsolutePath());
         }
      } catch (Exception e) {
         System.out.println("DIR FAIL: " + dirName);
      }

      try {
         myFiles = slinky.getFileList(singleFileOrDir);
         fcount = myFiles.length;
         for (fi = 0; fi < fcount; fi++) {
            System.out.println("  File Name: " + myFiles[fi].getName());
            System.out.println("  File Path: " + myFiles[fi].getParent());
            myMime = new mimeType(myFiles[fi]);
            System.out.println("  Mime Type: " + myMime.getMimeType());
         }
      } catch (Exception e) {
         System.out.println("FILES FAIL: " + dirName);
      }
   }

   public static void uploadFromDir(String dirName, myConnection funcJunk,
                                    boolean unattached) {

      File[] myDirs, myFiles;
      File singleFileOrDir;
      int dcount, di, fcount, fi;
      String myRoot = "";
      fileList slinky = new fileList();
      
      singleFileOrDir = new File(dirName);
      System.out.println("IN_DIR_NAME:" + dirName);

      if (unattached) {
         myRoot = null;
      } else {
         if (funcJunk.getConnectorType().equals("filenetp8")) {
            //  filnetp8 root
            myRoot = "/A";
         } else if (funcJunk.getConnectorType().equals("livelink")) {
            //  livelink root
            myRoot = "/Enterprise";
         } else if (funcJunk.getConnectorType().equals("OracleUCM")) {
            //  UCM root
            myRoot = "/Contribution Folders";
         } else {
            //  sharepoint root
            myRoot = "/";
         }
      }

      funcJunk.createFolderPath(singleFileOrDir, myRoot);
     
      try {
         myDirs = slinky.getDirList(singleFileOrDir);
         dcount = myDirs.length;
         for (di = 0; di < dcount; di++) {
            uploadFromDir(myDirs[di].getAbsolutePath(), funcJunk, unattached);
         }
      } catch (Exception e) {
         System.out.println("(smurf)DIR FAIL: " + dirName);
         System.out.println(e);
         System.exit(1);
      }

      try {
         myFiles = slinky.getFileList(singleFileOrDir);
         fcount = myFiles.length;
         for (fi = 0; fi < fcount; fi++) {
            System.out.println("  File Name: " + myFiles[fi].getName());
            System.out.println("  File Path: " + myFiles[fi].getParent());
            //funcJunk.createDocument("/Enterprise" + myFiles[fi].getParent(),
            //funcJunk.createDocument("/A" + myFiles[fi].getParent(),
            if (myRoot == null) {
               funcJunk.createDocument(null,
                                       myFiles[fi].getAbsolutePath());
            } else {
               funcJunk.createDocument(myRoot + myFiles[fi].getParent(),
                                       myFiles[fi].getAbsolutePath());
            }
         }
      } catch (Exception e) {
         System.out.println("(smurf)FILES FAIL: " + dirName);
      }
   }


   public static void deleteAllFolders(myConnection funcJunk,
                                       String workingFolderName,
                                       boolean unattached) {

      String NewName;
      String myRoot;
      ResultList workingList, docList;
      Item child;
      int i, listlen;
      File singleFileOrDir;

      if (unattached) {
         myRoot = null;
      } else {
         if (funcJunk.getConnectorType().equals("filenetp8")) {
            //  filnetp8 root
            myRoot = "/A";
         } else if (funcJunk.getConnectorType().equals("livelink")) {
            //  livelink root
            myRoot = "/Enterprise";
         } else if (funcJunk.getConnectorType().equals("OracleUCM")) {
            //  UCM root
            myRoot = "/Contribution Folders";
         } else {
            //  sharepoint root
            myRoot = "/";
         }

         if (!workingFolderName.startsWith(myRoot)) {
            workingFolderName = myRoot + workingFolderName;
         }
      }

      
      System.out.println("WORKING ON: " + workingFolderName);
      workingList = funcJunk.getFolderList(workingFolderName);

      if (workingList != null) {
         listlen = workingList.getResults().length;

         for (i = 0; i < listlen; i++ ) {
            child = (Item)workingList.getResults()[i];
            if (child != null) {
               System.out.println("(" + i + ") ITEM = " + child.getName());
               if (workingFolderName == "/") {
                  NewName = workingFolderName + child.getName();
               } else {
                  NewName = workingFolderName + "/" + child.getName();
               }
               deleteAllFolders(funcJunk, NewName, unattached);
            }
         }
      }

      System.out.println("WORKING ON-2: " + workingFolderName);
      try {
         docList = funcJunk.getDocumentList(workingFolderName);
         if (docList != null) {
            for (i = 0; i < docList.getResults().length; i++) {
               child = (Item)docList.getResults()[i];
               funcJunk.deleteDocument(child);
            }
            System.out.println("   Deleting(B) " + workingFolderName);
            singleFileOrDir = new File(workingFolderName);
            funcJunk.deleteFolder(singleFileOrDir.getParent(),
                                  singleFileOrDir.getName());
         }
      } catch (Exception e) {
         System.out.println("deleteAllFolders (), ERROR:  " + e);
      }
   }

   public static void dumpFolders(myConnection funcJunk, 
                                  String workingFolderName) {

      String NewName;
      ResultList workingList;
      Item child;
      int i, listlen;
      
      System.out.println("WORKING ON: " + workingFolderName);
      workingList = funcJunk.getFolderList(workingFolderName);

      listlen = workingList.getResults().length;

      if (listlen > 0) {
         for (i = 0; i < listlen; i++) {
            child = (Item)workingList.getResults()[i];
            System.out.println("(" + i + ") ITEM = " + child.getName());
            if (workingFolderName == "/") {
               NewName = workingFolderName + child.getName();
            } else {
               NewName = workingFolderName + "/" + child.getName();
            }
            dumpFolders(funcJunk, NewName);
            funcJunk.getDocumentList(NewName);
         }
      } else {
         System.out.println("   No Folders in " + workingFolderName);
      }
   }

   public static void doTheDelete(myConnection myjunk,
                                  String dowhat, String itemname,
                                  String mountpoint, int quantity,
                                  boolean unattached) {

      if (dowhat.equals("tree")) {
         if ( myjunk.getConnectorType().equals("livelink") ) {
            myjunk.deleteAnyItem((String)(new File(mountpoint).getParent()),
                                 (String)(new File(mountpoint).getName()));
         } else {
            deleteAllFolders(myjunk, mountpoint, unattached);
         }
      } else if (dowhat.equals("listbunch")) {
         myjunk.deleteListBunch(mountpoint, itemname, quantity);
      } else if (dowhat.equals("title")) {
         myjunk.deleteItemByName(itemname);
      } else if (dowhat.equals("name")) {
         myjunk.deleteItemByName(itemname);
      } else {
         myjunk.deleteAnyItem(mountpoint, itemname);
      }

      return;
   }

   public static void doTheUpdate(myConnection myjunk,
                                  String dowhat, String itemname,
                                  String mountpoint) {
   
      if (dowhat.equals("document")) {
         myjunk.updateDocument(mountpoint, itemname, true);
      } else {
         System.out.println("WTF is that?  " + dowhat);
      }

      return;
   }

   public static void doTheCreate(myConnection myjunk,
                                  String dowhat, String itemname,
                                  String mountpoint, int quantity,
                                  boolean unattached) {
   
      if (dowhat.equals("list")) {
         myjunk.createList(itemname, mountpoint, "Empty comment");
      } else if (dowhat.equals("listbunch")) {
         myjunk.createListBunch(mountpoint, itemname, quantity, "Star Trek");
      } else if (dowhat.equals("folder")) {
         myjunk.createFolder(itemname, mountpoint);
      } else if (dowhat.equals("listitem")) {
         myjunk.createListItem(mountpoint, itemname);
      } else if (dowhat.equals("listitembunch")) {
         myjunk.createListItemBunch(mountpoint, itemname, quantity);
      } else if (dowhat.equals("listattach")) {
         //myjunk.createListItemAttach(mountpoint, itemname);
         myjunk.createDocument(mountpoint, itemname);
      } else if (dowhat.equals("document")) {
         myjunk.createDocument(mountpoint, itemname);
      } else if (dowhat.equals("post")) {
         myjunk.createBlogPost(mountpoint, itemname);
      } else if (dowhat.equals("file")) {
         myjunk.createDocument(mountpoint, itemname);
      } else if (dowhat.equals("tree")) {
         uploadFromDir(mountpoint, myjunk, unattached);
      } else {
         System.out.println("WTF is that?  " + dowhat);
      }

      return;
   }

   public static void main(String[] args) {

      //String site = "http://testbed18-1.test.vivisimo.com/";
      //String user = "administrator";
      //String pw = "Mustang5";
      //String domain = "sptest";

      Folder root;
      ResultList resultList;
      int i, quantity;

      //  Login variables/options
      String site, user, pw, domain, connectto, sport, wport, sstore;
      myConnection myjunk;

      //  Operation variables
      boolean createFlag, deleteFlag, updateFlag;
      boolean unattached, dumpMime, fullDump, qc, lstDump, srchDump;
      String dowhat, itemname, mountpoint;

      //
      //   Initialize all because Java hates it if I do not.
      //
      myjunk = null;
      connectto = "sharepoint";
      site = user = pw = domain = "";
      sport = wport = sstore = "";
      dowhat = itemname = mountpoint = "";
      createFlag = deleteFlag = updateFlag = false;
      unattached = dumpMime = fullDump = false;
      lstDump = srchDump = false;
      qc = true;
      quantity = 0;

      //
      //   Options:
      //      -user:  The username for the connection
      //      -pw:  The pw for the connection
      //      -domain:  The domain for the connection
      //      -create:  The site for the connection
      //                values are list, folder, listitem,
      //                document or file, tree
      //      -delete:  The username for the connection
      //                values are list, folder, listitem,
      //                document or file, tree
      //      -update:  The username for the connection
      //                values are list, folder, listitem,
      //                document or file, tree
      //      -itemname:  Item to do something with
      //      -mountpoint:  Place to put the item or the point to
      //                    delete/delete from
      //
      for (i = 0; i < args.length; i++) {
         if ( args[i].equals("-user")) {
            user = args[i + 1];
            i++;
         } else if (args[i].equals("-pw")) {
            pw = args[i + 1];
            i++;
         } else if (args[i].equals("-connector")) {
            connectto = args[i + 1];
            i++;
         } else if (args[i].equals("-site")) {
            site = args[i + 1];
            i++;
         } else if (args[i].equals("-domain")) {
            domain = args[i + 1];
            i++;
         } else if (args[i].equals("-port")) {
            sport = args[i + 1];
            i++;
         } else if (args[i].equals("-webport")) {
            wport = args[i + 1];
            i++;
         } else if (args[i].equals("-store")) {
            sstore = args[i + 1];
            i++;
         } else if (args[i].equals("-create")) {
            createFlag = true;
            dowhat = args[i + 1];
            i++;
         } else if (args[i].equals("-delete")) {
            deleteFlag = true;
            dowhat = args[i + 1];
            i++;
         } else if (args[i].equals("-update")) {
            updateFlag = true;
            dowhat = args[i + 1];
            i++;
         } else if (args[i].equals("-itemname")) {
            itemname = args[i + 1];
            i++;
         } else if (args[i].equals("-numitems")) {
            quantity = Integer.parseInt(args[i + 1]);
            i++;
         } else if (args[i].equals("-showdoctype")) {
            dumpMime = true;
         } else if (args[i].equals("-showall_list")) {
            lstDump = true;
            fullDump = true;
         } else if (args[i].equals("-showall_search")) {
            srchDump = true;
            fullDump = true;
         } else if (args[i].equals("-showall")) {
            lstDump = true;
            fullDump = true;
         } else if (args[i].equals("-quickcheck")) {
            qc = true;
         } else if (args[i].equals("-unattached")) {
            unattached = true;
         } else if (args[i].equals("-mountpoint")) {
            mountpoint = args[i + 1];
            i++;
         } else {
            System.out.println("I dunno");
         }
      }

      try {
         if (sstore != "" && sport != "" && wport != "") {
            myjunk = new myConnection(connectto, site,
                                      user, pw, domain,
                                      sport, wport, sstore);
         } else {
            System.out.println("Going no ports route");
            myjunk = new myConnection(connectto, site,
                                      user, pw, domain);
         }
      } catch (Exception e) {
         System.out.println("Connection to " + site + " failed.");
         System.out.println("ERROR:  " + e);
         System.exit(1);
      }

      if ( qc ) {
         myjunk.dumpDefs();
      }

      if (createFlag) {
         doTheCreate(myjunk, dowhat, itemname, mountpoint,
                     quantity, unattached);
      } else if (deleteFlag) {
         doTheDelete(myjunk, dowhat, itemname, mountpoint,
                     quantity, unattached);
      } else if (updateFlag) {
         doTheUpdate(myjunk, dowhat, itemname, mountpoint);
      } else {
         System.out.println("Other OPS: ");
         if ( dumpMime ) {
            mimeDumper(mountpoint);
         } else if ( fullDump ) {
            //System.out.println("EntropySoft new SAAJOutInterceptor test");
            //new org.apache.cxf.binding.soap.saaj.SAAJOutInterceptor();
		
            root = myjunk.getRootFolder();
            resultList = myjunk.getAllChildren(root);

            System.out.println("ROOT ID STRING:  " + root.getId().toString());
            try {
               if (srchDump) {
                  myjunk.getListOfContents();
               } else {
                  parseRepository(myjunk.getContentProvider(), resultList);
               }
            } catch (Exception e) {

            }
         } else {
            System.out.println("Huh?");
         }
      }
      System.exit(0);
   }
}
