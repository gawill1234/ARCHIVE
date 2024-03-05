package helperFunctions;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class XMLReader {
	String inputfile;
	public List<String[][]> testInput = new ArrayList<String[][]>();

	public List<String[][]> getTestInput() {
		return testInput;
	}

	public static void main(String[] args) {
		XMLReader r = new XMLReader();
		r.readXML("C:\\Development\\projects\\RPL\\testdata\\blah.xml");

	}

	public void readXML(String _inputFile) {

		try {
			File file = new File(_inputFile);
			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
			DocumentBuilder db = dbf.newDocumentBuilder();
			Document doc = db.parse(file);
			doc.getDocumentElement().normalize();
			System.out.println("Root element " + doc.getDocumentElement().getNodeName());
			NodeList listOftests = doc.getElementsByTagName("test");
			System.out.println("test data");

			for (int s = 0; s < listOftests.getLength(); s++) {
				String[][] m = new String[1][2];
				Node firstTestNode = listOftests.item(s);
				if (firstTestNode.getNodeType() == Node.ELEMENT_NODE) {

					Element firstTestElement = (Element) firstTestNode;

					NodeList testDataList = firstTestElement.getElementsByTagName("queryterm");
					Element testDataElement = (Element) testDataList.item(0);

					NodeList textTestDataList = testDataElement.getChildNodes();
					String testData = ((Node) textTestDataList.item(0)).getNodeValue().trim();

					// -------
					NodeList expectedList = firstTestElement.getElementsByTagName("expecteddocument");
					Element expectedElement = (Element) expectedList.item(0);

					NodeList textExpectedList = expectedElement.getChildNodes();
					String expectedData = ((Node) textExpectedList.item(0)).getNodeValue().trim();
					m[0][0] = testData;
					m[0][1] = expectedData;
					testInput.add(m);

				}

			}
			

		} catch (Exception e) {
			e.printStackTrace();
		}
	
	}
}