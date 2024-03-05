
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import velocity.objects.CollectionBrokerConfiguration;
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
 *         &lt;element name="configuration" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element ref="{urn:/velocity/objects}collection-broker-configuration"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
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
    "configuration"
})
@XmlRootElement(name = "CollectionBrokerSet")
public class CollectionBrokerSet {

    @XmlElement(namespace = "urn:/velocity/soap")
    protected Authentication authentication;
    protected CollectionBrokerSet.Configuration configuration;

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
     * Gets the value of the configuration property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerSet.Configuration }
     *     
     */
    public CollectionBrokerSet.Configuration getConfiguration() {
        return configuration;
    }

    /**
     * Sets the value of the configuration property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerSet.Configuration }
     *     
     */
    public void setConfiguration(CollectionBrokerSet.Configuration value) {
        this.configuration = value;
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
     *         &lt;element ref="{urn:/velocity/objects}collection-broker-configuration"/>
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
        "collectionBrokerConfiguration"
    })
    public static class Configuration {

        @XmlElement(name = "collection-broker-configuration", namespace = "urn:/velocity/objects", required = true)
        protected CollectionBrokerConfiguration collectionBrokerConfiguration;

        /**
         * Gets the value of the collectionBrokerConfiguration property.
         * 
         * @return
         *     possible object is
         *     {@link CollectionBrokerConfiguration }
         *     
         */
        public CollectionBrokerConfiguration getCollectionBrokerConfiguration() {
            return collectionBrokerConfiguration;
        }

        /**
         * Sets the value of the collectionBrokerConfiguration property.
         * 
         * @param value
         *     allowed object is
         *     {@link CollectionBrokerConfiguration }
         *     
         */
        public void setCollectionBrokerConfiguration(CollectionBrokerConfiguration value) {
            this.collectionBrokerConfiguration = value;
        }

    }

}
