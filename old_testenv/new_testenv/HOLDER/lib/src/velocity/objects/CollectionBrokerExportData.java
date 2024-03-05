
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;


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
 *         &lt;element ref="{urn:/velocity/objects}vse-meta" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}call-function"/>
 *       &lt;/sequence>
 *       &lt;attribute name="source-collection" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="destination-collection" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="move" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "vseMeta",
    "callFunction"
})
@XmlRootElement(name = "collection-broker-export-data")
public class CollectionBrokerExportData {

    @XmlElement(name = "vse-meta")
    protected VseMeta vseMeta;
    @XmlElement(name = "call-function", required = true)
    protected CallFunction callFunction;
    @XmlAttribute(name = "source-collection")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String sourceCollection;
    @XmlAttribute(name = "destination-collection")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String destinationCollection;
    @XmlAttribute
    protected java.lang.Boolean move;

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

    /**
     * Gets the value of the callFunction property.
     * 
     * @return
     *     possible object is
     *     {@link CallFunction }
     *     
     */
    public CallFunction getCallFunction() {
        return callFunction;
    }

    /**
     * Sets the value of the callFunction property.
     * 
     * @param value
     *     allowed object is
     *     {@link CallFunction }
     *     
     */
    public void setCallFunction(CallFunction value) {
        this.callFunction = value;
    }

    /**
     * Gets the value of the sourceCollection property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSourceCollection() {
        return sourceCollection;
    }

    /**
     * Sets the value of the sourceCollection property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSourceCollection(String value) {
        this.sourceCollection = value;
    }

    /**
     * Gets the value of the destinationCollection property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDestinationCollection() {
        return destinationCollection;
    }

    /**
     * Sets the value of the destinationCollection property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDestinationCollection(String value) {
        this.destinationCollection = value;
    }

    /**
     * Gets the value of the move property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isMove() {
        return move;
    }

    /**
     * Sets the value of the move property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setMove(java.lang.Boolean value) {
        this.move = value;
    }

}
