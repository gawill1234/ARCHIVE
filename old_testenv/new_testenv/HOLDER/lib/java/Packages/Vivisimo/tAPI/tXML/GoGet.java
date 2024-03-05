package Vivisimo.tAPI;

import java.io.*;
import java.net.*;
import java.util.Scanner;

import org.apache.commons.httpclient.Credentials;
import org.apache.commons.httpclient.Header;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpException;
import org.apache.commons.httpclient.HttpMethod;
import org.apache.commons.httpclient.UsernamePasswordCredentials;
import org.apache.commons.httpclient.auth.AuthScope;
import org.apache.commons.httpclient.methods.GetMethod;

public class GoGet
{

    private UsernamePasswordCredentials creds = null;
    private String url = null;
    private String getHttpStatus = null;
    private String getHttpResponseData = null;
    private String getHttpQuery = null;
    private String getHttpPath = null;
    private Header[] requestHeaders;
    private Header[] responseHeaders;

    //create a singular HttpClient object
    private HttpClient client = null;
    private HttpMethod method = null;

    public void dumpGoGetResponseBody()
    {
        //write out the response body
        System.out.println("*** Response Body ***");
        System.out.println(this.getHttpResponseData);
    }

    public void dumpGoGetRequestHeaders()
    {
        //write out the request headers
        System.out.println("*** Request ***");
        System.out.println("Request Path: " + this.getHttpPath);
        for (int i=0; i<this.requestHeaders.length; i++){
            System.out.print(this.requestHeaders[i]);
        }
    }

    public void dumpGoGetResponseHeaders()
    {

        //write out the response headers
        System.out.println("*** Response ***");
        System.out.println("Status Line: " + this.getHttpStatus);

        for (int i=0; i<this.responseHeaders.length; i++){
            System.out.print(this.responseHeaders[i]);
        }
    }

    public String getGoGetStatus()
    {
       return(this.getHttpStatus);
    }

    public String getGoGetResponse()
    {
       return(this.getHttpResponseData);
    }

    public String getGoGetQuery()
    {
       return(this.getHttpQuery);
    }

    public String getGoGetPath()
    {
       return(this.getHttpPath);
    }

    private void setClient()
    {
        this.client = new HttpClient();
        //establish a connection within 5 seconds
        this.client.getHttpConnectionManager().
            getParams().setConnectionTimeout(5000);
    }

    public void setCreds(String user, String password)
    {

       if ( this.creds == null ) {
          this.creds = new UsernamePasswordCredentials();
       }

       if ( this.creds != null ) {
          this.creds.setUserName(user);
          this.creds.setPassword(password);
       }

       //set the default credentials
       if (this.creds != null) {
           this.client.getState().setCredentials(AuthScope.ANY, this.creds);
       }

    }

    public void setUrl(String url)
    {

       String strUrl = null;

       this.url = url;
   
       //
       //   Convert my url string to a uri.  For most of our stuff
       //   linux would be happy with the string.  Buuuuttt, windows
       //   must have a uri string or it will throw and exception.
       //   So this works with both windows and linux.
       //
       try {
          URL cnvUrl = new URL(this.url);
          URI uri = new URI(cnvUrl.getProtocol(), cnvUrl.getUserInfo(),
                            cnvUrl.getHost(), cnvUrl.getPort(), cnvUrl.getPath(),
                            cnvUrl.getQuery(), cnvUrl.getRef());
          //cnvUrl = uri.toURL();
          strUrl = uri.toString();
       } catch (java.lang.Exception jle) {
          System.out.println("URL:  " + url);
          System.out.println("URL String to URI conversion failed");
          System.out.println("ERROR:  " + jle);
       }


       //create a method object

       try {
          // private HttpMethod method = null;
          this.method = new GetMethod(strUrl);
          this.method.setFollowRedirects(true);
       } catch (java.lang.Exception jle) {
          System.out.println("URL:  " + url);
          System.out.println("URI:  " + strUrl);
          System.out.println("ERROR:  " + jle);
          System.exit(99);
       }
    }
    
    public String DoHttpGoGet()
    {
        //execute the method
        try{
            this.client.executeMethod(this.method);
            //
            //   Use InputStream because I got sick of warnings for
            //   getResponseBody().
            //
            InputStream iShit = this.method.getResponseBodyAsStream();
            //
            //   The scanner will take the whole stream and turn it into a
            //   string.  The reason it works is because Scanner iterates
            //   over tokens in the stream, and in this case we separate
            //   tokens using "beginning of the input boundary" (\A) thus
            //   giving us only one token for the entire contents of the stream.
            //
            this.getHttpResponseData = new Scanner(iShit).useDelimiter("\\A").next();
            iShit.close();
        } catch (HttpException he) {
            System.err.println("Http error connecting to '" + url + "'");
            System.err.println(he.getMessage());
            System.exit(-4);
        } catch (IOException ioe){
            System.err.println("Unable to connect to '" + url + "'");
            System.exit(-3);
        }

        this.getHttpPath = this.method.getPath();
        this.getHttpQuery = this.method.getQueryString();
        this.requestHeaders = this.method.getRequestHeaders();

        this.getHttpStatus = this.method.getStatusLine().toString();
        this.responseHeaders = this.method.getResponseHeaders();

        //clean up the connection resources
        this.method.releaseConnection();

        return(this.getHttpResponseData);
    }

    public GoGet()
    {
        setClient();
    }

    public GoGet(String url, String user, String password)
    {
        setClient();
        setUrl(url);
        setCreds(user, password);
    }

    public GoGet(String url)
    {
        setClient();
        setUrl(url);
    }
}

