
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
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
 *       &lt;sequence maxOccurs="unbounded" minOccurs="0">
 *         &lt;element ref="{urn:/velocity/objects}vse-index-stream"/>
 *       &lt;/sequence>
 *       &lt;attribute name="block-size" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="max-uncompressed-size" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="multi-stream">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="multi-stream"/>
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
    "vseIndexStream"
})
@XmlRootElement(name = "vse-index-info")
public class VseIndexInfo {

    @XmlElement(name = "vse-index-stream")
    protected List<VseIndexStream> vseIndexStream;
    @XmlAttribute(name = "block-size")
    protected Integer blockSize;
    @XmlAttribute(name = "max-uncompressed-size")
    protected Integer maxUncompressedSize;
    @XmlAttribute(name = "multi-stream")
    protected String multiStream;

    /**
     * Gets the value of the vseIndexStream property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseIndexStream property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseIndexStream().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link VseIndexStream }
     * 
     * 
     */
    public List<VseIndexStream> getVseIndexStream() {
        if (vseIndexStream == null) {
            vseIndexStream = new ArrayList<VseIndexStream>();
        }
        return this.vseIndexStream;
    }

    /**
     * Gets the value of the blockSize property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getBlockSize() {
        return blockSize;
    }

    /**
     * Sets the value of the blockSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setBlockSize(Integer value) {
        this.blockSize = value;
    }

    /**
     * Gets the value of the maxUncompressedSize property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaxUncompressedSize() {
        return maxUncompressedSize;
    }

    /**
     * Sets the value of the maxUncompressedSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxUncompressedSize(Integer value) {
        this.maxUncompressedSize = value;
    }

    /**
     * Gets the value of the multiStream property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMultiStream() {
        return multiStream;
    }

    /**
     * Sets the value of the multiStream property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMultiStream(String value) {
        this.multiStream = value;
    }

}
