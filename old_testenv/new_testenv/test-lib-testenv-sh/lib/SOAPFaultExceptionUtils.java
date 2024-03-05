package soapfault;

import java.util.Iterator;
import java.io.PrintStream;

import javax.xml.namespace.QName;

import javax.xml.ws.soap.SOAPFaultException;
import javax.xml.soap.SOAPFault;
import javax.xml.soap.Detail;
import javax.xml.soap.DetailEntry;

public class SOAPFaultExceptionUtils
{
    public static void prettyPrintSOAPFaultException(PrintStream stream, SOAPFaultException sfe)
    {
        SOAPFault f = sfe.getFault();
        QName code = f.getFaultCodeAsQName();
        
        stream.println("fault-code: [" + code.getLocalPart() + "]");
        stream.println("fault-str: [" + f.getFaultString() + "]");
        
        Detail det = f.getDetail();
        Iterator iter = det.getDetailEntries();
        
        while (iter.hasNext()) {
            DetailEntry entry = (DetailEntry)iter.next(); 
            String value = entry.getTextContent();
            if (value != null) stream.println(value);
        }
    }

    public static boolean checkSOAPFaultExceptionType(SOAPFaultException sfe, String name)
    {
        SOAPFault f = sfe.getFault();
        QName code = f.getFaultCodeAsQName();

        return name.equals(code.getLocalPart());
    }

    public static void prettyPrintSOAPFaultException(SOAPFaultException sfe)
    {
        prettyPrintSOAPFaultException(System.err, sfe);
    }
}
