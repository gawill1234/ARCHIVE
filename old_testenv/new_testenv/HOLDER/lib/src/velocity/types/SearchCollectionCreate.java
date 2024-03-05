
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;
import velocity.objects.VseMeta;
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
 *         &lt;element name="collection" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN"/>
 *         &lt;element name="based-on" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" minOccurs="0"/>
 *         &lt;element name="collection-meta" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element ref="{urn:/velocity/objects}vse-meta"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="description" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
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
    "collection",
    "basedOn",
    "collectionMeta",
    "description"
})
@XmlRootElement(name = "SearchCollectionCreate")
public class SearchCollectionCreate {

    @XmlElement(namespace = "urn:/velocity/soap")
    protected Authentication authentication;
    @XmlElement(required = true)
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String collection;
    @XmlElement(name = "based-on", defaultValue = "default-push")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String basedOn;
    @XmlElement(name = "collection-meta")
    protected SearchCollectionCreate.CollectionMeta collectionMeta;
    protected String description;

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
     * Gets the value of the collection property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCollection() {
        return collection;
    }

    /**
     * Sets the value of the collection property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCollection(String value) {
        this.collection = value;
    }

    /**
     * Gets the value of the basedOn property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBasedOn() {
        return basedOn;
    }

    /**
     * Sets the value of the basedOn property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBasedOn(String value) {
        this.basedOn = value;
    }

    /**
     * Gets the value of the collectionMeta property.
     * 
     * @return
     *     possible object is
     *     {@link SearchCollectionCreate.CollectionMeta }
     *     
     */
    public SearchCollectionCreate.CollectionMeta getCollectionMeta() {
        return collectionMeta;
    }

    /**
     * Sets the value of the collectionMeta property.
     * 
     * @param value
     *     allowed object is
     *     {@link SearchCollectionCreate.CollectionMeta }
     *     
     */
    public void setCollectionMeta(SearchCollectionCreate.CollectionMeta value) {
        this.collectionMeta = value;
    }

    /**
     * Gets the value of the description property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDescription() {
        return description;
    }

    /**
     * Sets the value of the description property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDescription(String value) {
        this.description = value;
    }


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
     *         &lt;element ref="{urn:/velocity/objects}vse-meta"/>
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
        "vseMeta"
    })
    public static class CollectionMeta {

        @XmlElement(name = "vse-meta", namespace = "urn:/velocity/objects", required = true)
        protected VseMeta vseMeta;

        /**
         * Gets the value of the vseMeta property.
         * 
         * @return
         *     possible object is
         *     {@link VseMeta }
         *     
         */
        public VseMeta getVseMeta() {
            return vseMeta;
        }

        /**
         * Sets the value of the vseMeta property.
         * 
         * @param value
         *     allowed object is
         *     {@link VseMeta }
         *     
         */
        public void setVseMeta(VseMeta value) {
            this.vseMeta = value;
        }

    }

}
