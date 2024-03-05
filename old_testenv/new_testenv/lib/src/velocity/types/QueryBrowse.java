
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import velocity.soap.Authentication;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType>
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element ref="{urn:/velocity/soap}authentication" minOccurs="0"/>
 *         &lt;element name="file" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="state" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="browse-num" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="browse-start" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="output-bold-contents" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="output-bold-contents-except" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="output-bold-class-root" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="output-bold-cluster-class-root" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="output-query-node" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="output-display-mode" minOccurs="0">
 *           &lt;simpleType>
 *             &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *               &lt;enumeration value="default"/>
 *               &lt;enumeration value="limited"/>
 *             &lt;/restriction>
 *           &lt;/simpleType>
 *         &lt;/element>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "authentication",
    "file",
    "state",
    "browseNum",
    "browseStart",
    "outputBoldContents",
    "outputBoldContentsExcept",
    "outputBoldClassRoot",
    "outputBoldClusterClassRoot",
    "outputQueryNode",
    "outputDisplayMode"
})
@XmlRootElement(name = "QueryBrowse")
public class QueryBrowse {

    @XmlElement(namespace = "urn:/velocity/soap")
    protected Authentication authentication;
    @XmlElement(required = true)
    protected String file;
    @XmlElement(defaultValue = "root|root")
    protected String state;
    @XmlElement(name = "browse-num")
    protected Integer browseNum;
    @XmlElement(name = "browse-start")
    protected Integer browseStart;
    @XmlElement(name = "output-bold-contents")
    protected String outputBoldContents;
    @XmlElement(name = "output-bold-contents-except", defaultValue = "false")
    protected Boolean outputBoldContentsExcept;
    @XmlElement(name = "output-bold-class-root")
    protected String outputBoldClassRoot;
    @XmlElement(name = "output-bold-cluster-class-root")
    protected String outputBoldClusterClassRoot;
    @XmlElement(name = "output-query-node", defaultValue = "true")
    protected Boolean outputQueryNode;
    @XmlElement(name = "output-display-mode", defaultValue = "default")
    protected String outputDisplayMode;

    /**
     * Gets the value of the authentication property.
     * 
     * @return
     *     possible object is
     *     {@link Authentication }
     *     
     */
    public Authentication getAuthentication() {
        return authentication;
    }

    /**
     * Sets the value of the authentication property.
     * 
     * @param value
     *     allowed object is
     *     {@link Authentication }
     *     
     */
    public void setAuthentication(Authentication value) {
        this.authentication = value;
    }

    /**
     * Gets the value of the file property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFile() {
        return file;
    }

    /**
     * Sets the value of the file property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFile(String value) {
        this.file = value;
    }

    /**
     * Gets the value of the state property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getState() {
        return state;
    }

    /**
     * Sets the value of the state property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setState(String value) {
        this.state = value;
    }

    /**
     * Gets the value of the browseNum property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getBrowseNum() {
        return browseNum;
    }

    /**
     * Sets the value of the browseNum property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setBrowseNum(Integer value) {
        this.browseNum = value;
    }

    /**
     * Gets the value of the browseStart property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getBrowseStart() {
        return browseStart;
    }

    /**
     * Sets the value of the browseStart property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setBrowseStart(Integer value) {
        this.browseStart = value;
    }

    /**
     * Gets the value of the outputBoldContents property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOutputBoldContents() {
        return outputBoldContents;
    }

    /**
     * Sets the value of the outputBoldContents property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOutputBoldContents(String value) {
        this.outputBoldContents = value;
    }

    /**
     * Gets the value of the outputBoldContentsExcept property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isOutputBoldContentsExcept() {
        return outputBoldContentsExcept;
    }

    /**
     * Sets the value of the outputBoldContentsExcept property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setOutputBoldContentsExcept(Boolean value) {
        this.outputBoldContentsExcept = value;
    }

    /**
     * Gets the value of the outputBoldClassRoot property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOutputBoldClassRoot() {
        return outputBoldClassRoot;
    }

    /**
     * Sets the value of the outputBoldClassRoot property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOutputBoldClassRoot(String value) {
        this.outputBoldClassRoot = value;
    }

    /**
     * Gets the value of the outputBoldClusterClassRoot property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOutputBoldClusterClassRoot() {
        return outputBoldClusterClassRoot;
    }

    /**
     * Sets the value of the outputBoldClusterClassRoot property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOutputBoldClusterClassRoot(String value) {
        this.outputBoldClusterClassRoot = value;
    }

    /**
     * Gets the value of the outputQueryNode property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isOutputQueryNode() {
        return outputQueryNode;
    }

    /**
     * Sets the value of the outputQueryNode property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setOutputQueryNode(Boolean value) {
        this.outputQueryNode = value;
    }

    /**
     * Gets the value of the outputDisplayMode property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOutputDisplayMode() {
        return outputDisplayMode;
    }

    /**
     * Sets the value of the outputDisplayMode property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOutputDisplayMode(String value) {
        this.outputDisplayMode = value;
    }

}
