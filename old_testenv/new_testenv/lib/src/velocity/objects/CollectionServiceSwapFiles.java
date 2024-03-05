
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
 *       &lt;sequence maxOccurs="unbounded">
 *         &lt;element ref="{urn:/velocity/objects}collection-service-swap-file"/>
 *       &lt;/sequence>
 *       &lt;attribute name="tmp-dir" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="token" type="{http://www.w3.org/2001/XMLSchema}string" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "collectionServiceSwapFile"
})
@XmlRootElement(name = "collection-service-swap-files")
public class CollectionServiceSwapFiles {

    @XmlElement(name = "collection-service-swap-file", required = true)
    protected List<CollectionServiceSwapFile> collectionServiceSwapFile;
    @XmlAttribute(name = "tmp-dir")
    protected String tmpDir;
    @XmlAttribute
    protected String token;

    /**
     * Gets the value of the collectionServiceSwapFile property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the collectionServiceSwapFile property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCollectionServiceSwapFile().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CollectionServiceSwapFile }
     * 
     * 
     */
    public List<CollectionServiceSwapFile> getCollectionServiceSwapFile() {
        if (collectionServiceSwapFile == null) {
            collectionServiceSwapFile = new ArrayList<CollectionServiceSwapFile>();
        }
        return this.collectionServiceSwapFile;
    }

    /**
     * Gets the value of the tmpDir property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTmpDir() {
        return tmpDir;
    }

    /**
     * Sets the value of the tmpDir property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTmpDir(String value) {
        this.tmpDir = value;
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

}
