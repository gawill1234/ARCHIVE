
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType>
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;choice maxOccurs="unbounded" minOccurs="0">
 *         &lt;group ref="{urn:/velocity/objects}regexp-parser-actions"/>
 *       &lt;/choice>
 *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *       &lt;attribute name="token" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="goto" type="{urn:/velocity/objects}nmtoken-or-special-states" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "addDocumentOrAddContentOrAddString"
})
@XmlRootElement(name = "match")
public class Match {

    @XmlElements({
        @XmlElement(name = "add-attribute", type = AddAttribute.class),
        @XmlElement(name = "add-document", type = AddDocument.class),
        @XmlElement(name = "replace-xpath", type = ReplaceXpath.class),
        @XmlElement(name = "normalize", type = Normalize.class),
        @XmlElement(name = "add-parse-uri", type = AddParseUri.class),
        @XmlElement(name = "add-content", type = AddContent.class),
        @XmlElement(name = "replace", type = Replace.class),
        @XmlElement(name = "add-string", type = AddString.class),
        @XmlElement(name = "add-processed-xsl", type = AddProcessedXsl.class),
        @XmlElement(name = "add-parse-string", type = AddParseString.class),
        @XmlElement(name = "prepend", type = Prepend.class),
        @XmlElement(name = "append", type = Append.class)
    })
    protected List<Object> addDocumentOrAddContentOrAddString;
    @XmlAttribute
    protected String token;
    @XmlAttribute(name = "goto")
    protected String _goto;
    @XmlAttribute
    protected java.lang.Boolean async;
    @XmlAttribute(name = "elt-id")
    protected Integer eltId;
    @XmlAttribute(name = "max-elt-id")
    protected Integer maxEltId;
    @XmlAttribute(name = "execute-acl")
    protected String executeAcl;
    @XmlAttribute
    protected String process;

    /**
     * Gets the value of the addDocumentOrAddContentOrAddString property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the addDocumentOrAddContentOrAddString property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getAddDocumentOrAddContentOrAddString().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link AddAttribute }
     * {@link AddDocument }
     * {@link ReplaceXpath }
     * {@link Normalize }
     * {@link AddParseUri }
     * {@link AddContent }
     * {@link Replace }
     * {@link AddString }
     * {@link AddProcessedXsl }
     * {@link AddParseString }
     * {@link Prepend }
     * {@link Append }
     * 
     * 
     */
    public List<Object> getAddDocumentOrAddContentOrAddString() {
        if (addDocumentOrAddContentOrAddString == null) {
            addDocumentOrAddContentOrAddString = new ArrayList<Object>();
        }
        return this.addDocumentOrAddContentOrAddString;
    }

    /**
     * Gets the value of the token property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getToken() {
        return token;
    }

    /**
     * Sets the value of the token property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setToken(String value) {
        this.token = value;
    }

    /**
     * Gets the value of the goto property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getGoto() {
        return _goto;
    }

    /**
     * Sets the value of the goto property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setGoto(String value) {
        this._goto = value;
    }

    /**
     * Gets the value of the async property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public boolean isAsync() {
        if (async == null) {
            return true;
        } else {
            return async;
        }
    }

    /**
     * Sets the value of the async property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setAsync(java.lang.Boolean value) {
        this.async = value;
    }

    /**
     * Gets the value of the eltId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getEltId() {
        return eltId;
    }

    /**
     * Sets the value of the eltId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setEltId(Integer value) {
        this.eltId = value;
    }

    /**
     * Gets the value of the maxEltId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaxEltId() {
        return maxEltId;
    }

    /**
     * Sets the value of the maxEltId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxEltId(Integer value) {
        this.maxEltId = value;
    }

    /**
     * Gets the value of the executeAcl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getExecuteAcl() {
        return executeAcl;
    }

    /**
     * Sets the value of the executeAcl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setExecuteAcl(String value) {
        this.executeAcl = value;
    }

    /**
     * Gets the value of the process property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getProcess() {
        return process;
    }

    /**
     * Sets the value of the process property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setProcess(String value) {
        this.process = value;
    }

}
