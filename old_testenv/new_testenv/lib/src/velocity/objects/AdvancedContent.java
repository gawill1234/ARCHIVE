
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
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
 *         &lt;element ref="{urn:/velocity/objects}content"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-index-stream" maxOccurs="unbounded" minOccurs="0"/>
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
    "content",
    "vseIndexStream"
})
@XmlRootElement(name = "advanced-content")
public class AdvancedContent {

    @XmlElement(required = true)
    protected Content content;
    @XmlElement(name = "vse-index-stream")
    protected List<VseIndexStream> vseIndexStream;

    /**
     * Gets the value of the content property.
     * 
     * @return
     *     possible object is
     *     {@link Content }
     *     
     */
    public Content getContent() {
        return content;
    }

    /**
     * Sets the value of the content property.
     * 
     * @param value
     *     allowed object is
     *     {@link Content }
     *     
     */
    public void setContent(Content value) {
        this.content = value;
    }

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

}
