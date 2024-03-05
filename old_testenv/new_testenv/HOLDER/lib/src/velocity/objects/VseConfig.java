
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
 *       &lt;sequence>
 *         &lt;element ref="{urn:/velocity/objects}crawler" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-index" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}converters" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-remote" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "crawler",
    "vseIndex",
    "converters",
    "vseRemote"
})
@XmlRootElement(name = "vse-config")
public class VseConfig {

    protected Crawler crawler;
    @XmlElement(name = "vse-index")
    protected VseIndex vseIndex;
    protected Converters converters;
    @XmlElement(name = "vse-remote")
    protected VseRemote vseRemote;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String name;

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
     * Gets the value of the converters property.
     * 
     * @return
     *     possible object is
     *     {@link Converters }
     *     
     */
    public Converters getConverters() {
        return converters;
    }

    /**
     * Sets the value of the converters property.
     * 
     * @param value
     *     allowed object is
     *     {@link Converters }
     *     
     */
    public void setConverters(Converters value) {
        this.converters = value;
    }

    /**
     * Gets the value of the vseRemote property.
     * 
     * @return
     *     possible object is
     *     {@link VseRemote }
     *     
     */
    public VseRemote getVseRemote() {
        return vseRemote;
    }

    /**
     * Sets the value of the vseRemote property.
     * 
     * @param value
     *     allowed object is
     *     {@link VseRemote }
     *     
     */
    public void setVseRemote(VseRemote value) {
        this.vseRemote = value;
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

}
