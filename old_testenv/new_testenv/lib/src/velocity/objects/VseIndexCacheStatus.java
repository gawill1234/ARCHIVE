
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
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
 *       &lt;sequence maxOccurs="unbounded" minOccurs="0">
 *         &lt;element ref="{urn:/velocity/objects}vse-index-cache-status-segment"/>
 *       &lt;/sequence>
 *       &lt;attribute name="fname" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="core-size" use="required" type="{http://www.w3.org/2001/XMLSchema}int" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "vseIndexCacheStatusSegment"
})
@XmlRootElement(name = "vse-index-cache-status")
public class VseIndexCacheStatus {

    @XmlElement(name = "vse-index-cache-status-segment")
    protected List<VseIndexCacheStatusSegment> vseIndexCacheStatusSegment;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String fname;
    @XmlAttribute(name = "core-size", required = true)
    protected int coreSize;

    /**
     * Gets the value of the vseIndexCacheStatusSegment property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseIndexCacheStatusSegment property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseIndexCacheStatusSegment().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link VseIndexCacheStatusSegment }
     * 
     * 
     */
    public List<VseIndexCacheStatusSegment> getVseIndexCacheStatusSegment() {
        if (vseIndexCacheStatusSegment == null) {
            vseIndexCacheStatusSegment = new ArrayList<VseIndexCacheStatusSegment>();
        }
        return this.vseIndexCacheStatusSegment;
    }

    /**
     * Gets the value of the fname property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFname() {
        return fname;
    }

    /**
     * Sets the value of the fname property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFname(String value) {
        this.fname = value;
    }

    /**
     * Gets the value of the coreSize property.
     * 
     */
    public int getCoreSize() {
        return coreSize;
    }

    /**
     * Sets the value of the coreSize property.
     * 
     */
    public void setCoreSize(int value) {
        this.coreSize = value;
    }

}
