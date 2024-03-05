import javax.xml.parsers.*;
import org.xml.sax.InputSource;
import org.w3c.dom.*;
import java.io.*;

import javax.xml.XMLConstants;
import javax.xml.parsers.*;
import javax.xml.xpath.*;
import javax.xml.namespace.QName;

import java.util.Set;
import java.util.*;
import java.util.HashSet;
import java.util.List;
import java.util.ArrayList;
 
public class GoGetXML {

   private Document doc = null;
   private XPath xPath = null;

   private Set getGeneralListByAttr(String startAt, String whichVal) {

      Set<String> collectionList = new HashSet<String>();

      NodeList nodeLst = doc.getElementsByTagName(startAt);
      
      for (int s = 0; s < nodeLst.getLength(); s++) {
         Node fstNode = nodeLst.item(s);
         Element fstElmnt = (Element) fstNode;      
         String cName = fstElmnt.getAttribute(whichVal);
         collectionList.add(cName);
      }
      return(collectionList);
   }

   private Object getXPathData(String xPExpression, QName rType) {
      try {
         XPathExpression xPathExpression = this.xPath.compile(xPExpression);
         return xPathExpression.evaluate(this.doc, rType);
      } catch (XPathExpressionException ex) {
          ex.printStackTrace();
          return null;
      }
   }
   
   private Set getGeneralValueList(String startAt) {

      Set<String> collectionList = new HashSet<String>();

      NodeList nodeLst = (NodeList)getXPathData(startAt, XPathConstants.NODESET);
      
      for (int s = 0; s < nodeLst.getLength(); s++) {
         String cName = nodeLst.item(s).getTextContent();
         collectionList.add(cName);
      }
      return(collectionList);
   }

   ///////////////////////////////////////////////////////////////////////////
   //
   //   This routine uses "startAt" as an xpath which may have multiple
   //   attributes that are wanted.  The attributes would be in attrList.
   //   Each of those would be gotten and the values stored in another list
   //   which is stored in a hashmap keyed by the value at startAt.
   //
   private Hashtable cmnGetAttrAndData(String startAt, ArrayList<String> attrList) {

      Hashtable<String,ArrayList<String>> stuff =
                       new Hashtable<String,ArrayList<String>>();

      NodeList nodeLst = (NodeList)getXPathData(startAt, XPathConstants.NODESET);
      
      for (int s = 0; s < nodeLst.getLength(); s++) {
         String cName = nodeLst.item(s).getTextContent();
         Node fstNode = nodeLst.item(s);
         if (fstNode.getNodeType() == Node.ELEMENT_NODE) {
            Element fstElmnt = (Element) fstNode;      
            ArrayList<String> myAl = new ArrayList<String>();
            for (String attrS : attrList) {
               String myAttr = fstElmnt.getAttribute(attrS);
               if (myAttr != null) {
                  myAl.add(myAttr);
               }
            }
            stuff.put(cName, myAl);
         }
      }

      return(stuff);
   }

   private Hashtable cmnGetAttrAndData(String startAt,
                                       String whichVal,
                                       Hashtable<String,String> stuff) {

      NodeList nodeLst = (NodeList)getXPathData(startAt, XPathConstants.NODESET);
      
      for (int s = 0; s < nodeLst.getLength(); s++) {
         String cName = nodeLst.item(s).getTextContent();
         Node fstNode = nodeLst.item(s);
         if (fstNode.getNodeType() == Node.ELEMENT_NODE) {
            Element fstElmnt = (Element) fstNode;      
            String myAttr = fstElmnt.getAttribute(whichVal);
            if (myAttr != null) {
               stuff.put(cName, myAttr);
            }
         }
      }
      return(stuff);
   }
   ///////////////////////////////////////////////////////////////////////////

   ////////////////////////////////////////////////////////////////////////////
   //
   //   For any given XPath (startAt), get the attribute and stash it in as
   //   hashmap keyed by the value at startAt.
   //
   public Hashtable getAttrAndData(String startAt, ArrayList<String> attrList) {

      return(cmnGetAttrAndData(startAt, attrList));
   }

   public Hashtable getAttrAndData(String startAt, String whichVal,
                                   Hashtable<String,String> stuff) {

      return(cmnGetAttrAndData(startAt, whichVal, stuff));
   }

   public Hashtable getAttrAndData(String startAt, String whichVal) {

      Hashtable<String,String> stuff = new Hashtable<String,String>();

      return(cmnGetAttrAndData(startAt, whichVal, stuff));
   }
   ////////////////////////////////////////////////////////////////////////////

   ////////////////////////////////////////////////////////////////////////////
   //
   //   For any given XPath (startAt), pick off the named attribute IF the
   //   data in that node matches the value in gData.  It is then stored in a
   //   hashmap keyed by the value at startAt.
   //
   public String getAttrByData(String startAt, String whichVal, String gData) {

      NodeList nodeLst = (NodeList)getXPathData(startAt, XPathConstants.NODESET);
      
      for (int s = 0; s < nodeLst.getLength(); s++) {
         String cName = nodeLst.item(s).getTextContent();
         if (cName.equals(gData)) {
            Node fstNode = nodeLst.item(s);
            if (fstNode.getNodeType() == Node.ELEMENT_NODE) {
               Element fstElmnt = (Element) fstNode;      
               String myAttr = fstElmnt.getAttribute(whichVal);
               return(myAttr);
            }
         }
      }
      return(null);
   }
   ////////////////////////////////////////////////////////////////////////////

   private ArrayList<String> getGeneralAttrListAL(String startAt, String attr) {

      ArrayList<String> collectionList = new ArrayList<String>();

      NodeList nodeLst = (NodeList)getXPathData(startAt, XPathConstants.NODESET);
      
      for (int s = 0; s < nodeLst.getLength(); s++) {
         Node fstNode = nodeLst.item(s);
         if (fstNode.getNodeType() == Node.ELEMENT_NODE) {
            Element fstElmnt = (Element) fstNode;      
            String cName = fstElmnt.getAttribute(attr);
            collectionList.add(cName);
         }
      }
      return(collectionList);
   }

   private Set getGeneralAttrList(String startAt, String attr) {

      Set<String> collectionList = new HashSet<String>();

      NodeList nodeLst = (NodeList)getXPathData(startAt, XPathConstants.NODESET);
      
      for (int s = 0; s < nodeLst.getLength(); s++) {
         Node fstNode = nodeLst.item(s);
         if (fstNode.getNodeType() == Node.ELEMENT_NODE) {
            Element fstElmnt = (Element) fstNode;      
            String cName = fstElmnt.getAttribute(attr);
            collectionList.add(cName);
         }
      }
      return(collectionList);
   }

   private ArrayList<String> getGeneralListAL(String startAt, String whichVal) {

      ArrayList<String> collectionList = new ArrayList<String>();

      NodeList nodeLst = doc.getElementsByTagName(startAt);
      
      for (int s = 0; s < nodeLst.getLength(); s++) {
         Node fstNode = nodeLst.item(s);
      
         if (fstNode.getNodeType() == Node.ELEMENT_NODE) {
            Element fstElmnt = (Element) fstNode;      
            NodeList fstNmElmntLst =
                     fstElmnt.getElementsByTagName(whichVal);
            Element fstNmElmnt = (Element) fstNmElmntLst.item(0);
            NodeList fstNm = fstNmElmnt.getChildNodes();
            String cName = ((Node) fstNm.item(0)).getNodeValue();
            collectionList.add(cName);
         }
      }
      return(collectionList);
   }

   private Set getGeneralList(String startAt, String whichVal) {

      Set<String> collectionList = new HashSet<String>();

      NodeList nodeLst = doc.getElementsByTagName(startAt);
      
      for (int s = 0; s < nodeLst.getLength(); s++) {
         Node fstNode = nodeLst.item(s);
      
         if (fstNode.getNodeType() == Node.ELEMENT_NODE) {
            Element fstElmnt = (Element) fstNode;      
            NodeList fstNmElmntLst =
                     fstElmnt.getElementsByTagName(whichVal);
            Element fstNmElmnt = (Element) fstNmElmntLst.item(0);
            NodeList fstNm = fstNmElmnt.getChildNodes();
            String cName = ((Node) fstNm.item(0)).getNodeValue();
            collectionList.add(cName);
         }
      }
      return(collectionList);
   }

   public Set getCollectionList() {

      return(getGeneralList("COLLECTION", "COLLECTION_NAME"));

   }

   public Set xPathValueGet(String xp) {

      return(getGeneralValueList(xp));

   }

   public ArrayList<String> xPathAttrGetAL(String xp, String attr) {

      return(getGeneralAttrListAL(xp, attr));

   }

   public Set xPathAttrGet(String xp, String attr) {

      return(getGeneralAttrList(xp, attr));

   }

   public Set getPidList() {

      return(getGeneralList("PIDLIST", "PID"));

   }

   public String firstElementValue(String elementName) {

      Set<String> bS = getGeneralList("REMOP", elementName);

      List<String> myList = new ArrayList<String>(bS);

      return(myList.get(0));
   }

 
   public GoGetXML(String myXmlString) {

      //System.out.println(myXmlString);
 
      try {
 
         InputSource IS = new InputSource();
         IS.setCharacterStream(new StringReader(myXmlString));

         DocumentBuilderFactory dbFactory =
                                DocumentBuilderFactory.newInstance();
         DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
         this.doc = dBuilder.parse(IS);
         this.xPath = XPathFactory.newInstance().newXPath();
 
      } catch (Exception e) {
         e.printStackTrace();
      }
   }
}
