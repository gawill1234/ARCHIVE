
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
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
 *       &lt;all>
 *         &lt;element ref="{urn:/velocity/objects}crawler"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-index"/>
 *       &lt;/all>
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="read-only">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="idle"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {

})
@XmlRootElement(name = "vse-index-service")
public class VseIndexService {

    @XmlElement(required = true)
    protected Crawler crawler;
    @XmlElement(name = "vse-index", required = true)
    protected VseIndex vseIndex;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String name;
    @XmlAttribute(name = "read-only")
    protected String readOnly;

    /**
     * Gets the value of the crawler property.
     * 
     * @return
     *     possible object is
     *     {@link Crawler }
     *     
     */
    public Crawler getCrawler() {
        return crawler;
    }

    /**
     * Sets the value of the crawler property.
     * 
     * @param value
     *     allowed object is
     *     {@link Crawler }
     *     
     */
    public void setCrawler(Crawler value) {
        this.crawler = value;
    }

    /**
     * Gets the value of the vseIndex property.
     * 
     * @return
     *     possible object is
     *     {@link VseIndex }
     *     
     */
    public VseIndex getVseIndex() {
        return vseIndex;
    }

    /**
     * Sets the value of the vseIndex property.
     * 
     * @param value
     *     allowed object is
     *     {@link VseIndex }
     *     
     */
    public void setVseIndex(VseIndex value) {
        this.vseIndex = value;
    }

    /**
     * Gets the value of the name property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getName() {
        return name;
    }

    /**
     * Sets the value of the name property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setName(String value) {
        this.name = value;
    }

    /**
     * Gets the value of the readOnly property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getReadOnly() {
        return readOnly;
    }

    /**
     * Sets the value of the readOnly property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setReadOnly(String value) {
        this.readOnly = value;
    }

}
