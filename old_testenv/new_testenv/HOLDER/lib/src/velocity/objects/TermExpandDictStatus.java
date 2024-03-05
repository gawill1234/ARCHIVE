
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
 *         &lt;element ref="{urn:/velocity/objects}vse-index-stream" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="filename" use="required" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="n-words" use="required" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="n-bytes" use="required" type="{http://www.w3.org/2001/XMLSchema}long" />
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
@XmlRootElement(name = "term-expand-dict-status")
public class TermExpandDictStatus {

    @XmlElement(name = "vse-index-stream")
    protected VseIndexStream vseIndexStream;
    @XmlAttribute(required = true)
    protected String filename;
    @XmlAttribute(name = "n-words", required = true)
    protected int nWords;
    @XmlAttribute(name = "n-bytes", required = true)
    protected long nBytes;

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
     * Gets the value of the filename property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFilename() {
        return filename;
    }

    /**
     * Sets the value of the filename property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFilename(String value) {
        this.filename = value;
    }

    /**
     * Gets the value of the nWords property.
     * 
     */
    public int getNWords() {
        return nWords;
    }

    /**
     * Sets the value of the nWords property.
     * 
     */
    public void setNWords(int value) {
        this.nWords = value;
    }

    /**
     * Gets the value of the nBytes property.
     * 
     */
    public long getNBytes() {
        return nBytes;
    }

    /**
     * Sets the value of the nBytes property.
     * 
     */
    public void setNBytes(long value) {
        this.nBytes = value;
    }

}
