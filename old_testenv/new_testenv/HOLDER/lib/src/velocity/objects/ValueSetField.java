
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;
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
 *       &lt;attribute name="n-values" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="n-instances" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="data-bytes" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="meta-bytes" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="type" type="{urn:/velocity/objects}fast-index-type" />
 *       &lt;attribute name="arena-id" type="{http://www.w3.org/2001/XMLSchema}int" default="-1" />
 *       &lt;attribute name="state">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;enumeration value="alive"/>
 *             &lt;enumeration value="dead"/>
 *             &lt;enumeration value="transient"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="indexed">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *             &lt;enumeration value="indexed"/>
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
@XmlType(name = "")
@XmlRootElement(name = "value-set-field")
public class ValueSetField {

    @XmlAttribute(name = "n-values")
    protected Integer nValues;
    @XmlAttribute(name = "n-instances")
    protected Integer nInstances;
    @XmlAttribute(name = "data-bytes")
    protected Integer dataBytes;
    @XmlAttribute(name = "meta-bytes")
    protected Integer metaBytes;
    @XmlAttribute
    protected String name;
    @XmlAttribute
    protected FastIndexType type;
    @XmlAttribute(name = "arena-id")
    protected Integer arenaId;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String state;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    protected String indexed;

    /**
     * Gets the value of the nValues property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNValues() {
        if (nValues == null) {
            return  0;
        } else {
            return nValues;
        }
    }

    /**
     * Sets the value of the nValues property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNValues(Integer value) {
        this.nValues = value;
    }

    /**
     * Gets the value of the nInstances property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNInstances() {
        if (nInstances == null) {
            return  0;
        } else {
            return nInstances;
        }
    }

    /**
     * Sets the value of the nInstances property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNInstances(Integer value) {
        this.nInstances = value;
    }

    /**
     * Gets the value of the dataBytes property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getDataBytes() {
        if (dataBytes == null) {
            return  0;
        } else {
            return dataBytes;
        }
    }

    /**
     * Sets the value of the dataBytes property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setDataBytes(Integer value) {
        this.dataBytes = value;
    }

    /**
     * Gets the value of the metaBytes property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getMetaBytes() {
        if (metaBytes == null) {
            return  0;
        } else {
            return metaBytes;
        }
    }

    /**
     * Sets the value of the metaBytes property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMetaBytes(Integer value) {
        this.metaBytes = value;
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

    /**
     * Gets the value of the type property.
     * 
     * @return
     *     possible object is
     *     {@link FastIndexType }
     *     
     */
    public FastIndexType getType() {
        return type;
    }

    /**
     * Sets the value of the type property.
     * 
     * @param value
     *     allowed object is
     *     {@link FastIndexType }
     *     
     */
    public void setType(FastIndexType value) {
        this.type = value;
    }

    /**
     * Gets the value of the arenaId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getArenaId() {
        if (arenaId == null) {
            return -1;
        } else {
            return arenaId;
        }
    }

    /**
     * Sets the value of the arenaId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setArenaId(Integer value) {
        this.arenaId = value;
    }

    /**
     * Gets the value of the state property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getState() {
        return state;
    }

    /**
     * Sets the value of the state property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setState(String value) {
        this.state = value;
    }

    /**
     * Gets the value of the indexed property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getIndexed() {
        return indexed;
    }

    /**
     * Sets the value of the indexed property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setIndexed(String value) {
        this.indexed = value;
    }

}
