import javax.xml.parsers.*;
import org.xml.sax.InputSource;
import org.w3c.dom.*;
import java.io.*;
 
public class vQueryXML {

   private NodeList nList = null;

   private static String getTagValue(String sTag, Element eElement) {
      NodeList nlList = eElement.getElementsByTagName(sTag).item(0).getChildNodes();
 
      Node nValue = (Node) nlList.item(0);
 
      return nValue.getNodeValue();
   }

   public String firstElementValue(String elementName)
   {

         for (int temp = 0; temp < nList.getLength(); temp++) {
 
            Node nNode = this.nList.item(temp);
            if (nNode.getNodeType() == Node.ELEMENT_NODE) {
 
               Element eElement = (Element) nNode;
 
               return(getTagValue(elementName, eElement));
 
            }
         }

      return("Empty");

   }
 
   public vQueryXML(String myXmlString) {
 
      try {
 
         // File fXmlFile = new File("c:\\file.xml");
         InputSource IS = new InputSource();
         IS.setCharacterStream(new StringReader(myXmlString));

         DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
         DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
         Document doc = dBuilder.parse(IS);
         doc.getDocumentElement().normalize();
 
         //System.out.println("Root element :" + doc.getDocumentElement().getNodeName());
         this.nList = doc.getElementsByTagName("query-results");

         //System.out.println("-----------------------");
 
      } catch (Exception e) {
         e.printStackTrace();
      }
   }
 

}
