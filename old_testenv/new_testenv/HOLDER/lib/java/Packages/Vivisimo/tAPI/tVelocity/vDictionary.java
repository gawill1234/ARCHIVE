package Vivisimo.tAPI;

import velocity.*;
import velocity.objects.*;
import velocity.soap.*;
import velocity.types.*;

import java.io.File;
import java.io.FileWriter;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.Attr;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import javax.xml.ws.soap.SOAPFaultException;
import static soapfault.SOAPFaultExceptionUtils.*;

import java.io.*;

import java.net.URL;
import javax.xml.namespace.QName;

import java.util.logging.*;
import java.util.StringTokenizer;

public class vDictionary
{
    private static final String WSDL_CGI_PARAMS = "?v.app=api-soap&wsdl=1&specialize-for=&use-types=true";
    private static final String URLS_FILE = "urls.txt";

    private static Logger log = Logger.getLogger(vDictionary.class.getName());

    /* -- */

    private String url;
    private ENVIRONMENT dictEnv;
    private VelocityPort p;
    private Authentication auth;

    public vDictionary(String url) throws java.lang.Exception
    {

       envInit();
       commonInit(url);

    }
    public vDictionary() throws java.lang.Exception
    {

       envInit();
       commonInit(this.dictEnv.getVelocityUrl());

    }

    private void envInit() {

       this.auth = new Authentication();

       this.dictEnv = new ENVIRONMENT();
       this.setUser(this.dictEnv.getVivUser());
       this.setPassword(this.dictEnv.getVivPassword());

    }

    private void commonInit(String url) throws java.lang.Exception
    {
        //log.info("Created a new test object");

        this.url = url + WSDL_CGI_PARAMS;

        //log.info("Using \"" + this.url + "\"");

        URL wsdlLocation = new URL(this.url);
        QName serviceName = new QName("urn:/velocity", "VelocityService");

        VelocityService s = new VelocityService(wsdlLocation, serviceName);
        this.p = s.getVelocityPort();

    }

    public void TestIt()
    {
       System.out.println("Hello World");
    }

    public void setUser(String user)
    {
        auth.setUsername(user);
    }

    public void setPassword(String password)
    {
        auth.setPassword(password);
    }

    public void dictCreate(String dname, String dbaseon)
    {
        //log.info("Creating the dictionary");

        DictionaryCreate create = new DictionaryCreate();

        create.setAuthentication(this.auth);
        create.setBasedOn(dbaseon);
        create.setDictionary(dname);

        this.p.dictionaryCreate(create);
    }

    public void dictDelete(String dbname)
    {
        //log.info("Deleting the dictionary");

        DictionaryDelete delete = new DictionaryDelete();

        delete.setAuthentication(this.auth);
        delete.setDictionary(dbname);

        this.p.dictionaryDelete(delete);
    }

    public void dictBuild(String dbname)
    {
        //log.info("Building the dictionary");

        DictionaryBuild build = new DictionaryBuild();

        build.setAuthentication(this.auth);
        build.setDictionary(dbname);

        this.p.dictionaryBuild(build);
    }

    public String dictStatus(String dbname)
    {
        Element dictResp;
        Element srvStatElem = null;
        String thingName = null;
        String statusString = "broken";
        NodeList srvStatNode = null;

        //log.info("Status of the dictionary");

        DictionaryStatusXml delete = new DictionaryStatusXml();

        delete.setAuthentication(this.auth);
        delete.setDictionary(dbname);

        try {
           DictionaryStatusXmlResponse resp = this.p.dictionaryStatusXml(delete);
           if (resp == null) {
              return null;
           }

           dictResp = (Element)resp.getAny();

           srvStatNode = dictResp.getElementsByTagName("dictionary-status");
           srvStatElem = (Element)srvStatNode.item(0);

           if (srvStatElem != null) {
              thingName = srvStatElem.getAttribute("status");
              if (thingName != null) {
                 statusString = thingName;
              }
           }

        } catch (SOAPFaultException e) {
           if (checkSOAPFaultExceptionType(e, "repository-unknown-node")) {
              //prettyPrintSOAPFaultException(e);
              //log.info("repositoryGet:  Item does not exist");
              return null;
           } else {
              throw e;
           }
        }

        return statusString;
    }

    public void dictStop(String dbname)
    {
        //log.info("Stop building the dictionary");

        DictionaryStop build = new DictionaryStop();

        build.setAuthentication(this.auth);
        build.setDictionary(dbname);

        this.p.dictionaryStop(build);
    }

}
