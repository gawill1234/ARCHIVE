
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
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
 *       &lt;sequence>
 *         &lt;element ref="{urn:/velocity/objects}vse-index-stream"/>
 *       &lt;/sequence>
 *       &lt;attribute name="version" type="{http://www.w3.org/2001/XMLSchema}int" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "vseIndexStream"
})
@XmlRootElement(name = "term-expand-dictionary")
public class TermExpandDictionary {

    @XmlElement(name = "vse-index-stream", required = true)
    protected VseIndexStream vseIndexStream;
    @XmlAttribute
    protected Integer version;

    /**
     * Gets the value of the vseIndexStream property.
     * 
     * @return
     *     possible object is
     *     {@link VseIndexStream }
     *     
     */
    public VseIndexStream getVseIndexStream() {
        return vseIndexStream;
    }

    /**
     * Sets the value of the vseIndexStream property.
     * 
     * @param value
     *     allowed object is
     *     {@link VseIndexStream }
     *     
     */
    public void setVseIndexStream(VseIndexStream value) {
        this.vseIndexStream = value;
    }

    /**
     * Gets the value of the version property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getVersion() {
        return version;
    }

    /**
     * Sets the value of the version property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setVersion(Integer value) {
        this.version = value;
    }

}
