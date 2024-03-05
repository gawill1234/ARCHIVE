
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
 *         &lt;element ref="{urn:/velocity/objects}vse-index-content"/>
 *       &lt;/sequence>
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="fname" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="size" type="{http://www.w3.org/2001/XMLSchema}long" default="0" />
 *       &lt;attribute name="at" use="required" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="rm">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="rm"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="merge">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="pending"/>
 *             &lt;enumeration value="active"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="n-docs" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="max-docs" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="min-docid" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="max-docid" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="type" default="index">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="segment"/>
 *             &lt;enumeration value="index"/>
 *             &lt;enumeration value="docs-data"/>
 *             &lt;enumeration value="fast-index"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="main">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="main"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="old-index">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="old-index"/>
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
    "vseIndexContent"
})
@XmlRootElement(name = "vse-index-file")
public class VseIndexFile {

    @XmlElement(name = "vse-index-content")
    protected List<VseIndexContent> vseIndexContent;
    @XmlAttribute
    protected String name;
    @XmlAttribute
    protected String fname;
    @XmlAttribute
    protected Long size;
    @XmlAttribute(required = true)
    protected int at;
    @XmlAttribute
    protected String rm;
    @XmlAttribute
    protected String merge;
    @XmlAttribute(name = "n-docs")
    protected Integer nDocs;
    @XmlAttribute(name = "max-docs")
    protected Integer maxDocs;
    @XmlAttribute(name = "min-docid")
    protected Integer minDocid;
    @XmlAttribute(name = "max-docid")
    protected Integer maxDocid;
    @XmlAttribute
    protected String type;
    @XmlAttribute
    protected String main;
    @XmlAttribute(name = "old-index")
    protected String oldIndex;

    /**
     * Gets the value of the vseIndexContent property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseIndexContent property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseIndexContent().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link VseIndexContent }
     * 
     * 
     */
    public List<VseIndexContent> getVseIndexContent() {
        if (vseIndexContent == null) {
            vseIndexContent = new ArrayList<VseIndexContent>();
        }
        return this.vseIndexContent;
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
     * Gets the value of the size property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public long getSize() {
        if (size == null) {
            return  0L;
        } else {
            return size;
        }
    }

    /**
     * Sets the value of the size property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setSize(Long value) {
        this.size = value;
    }

    /**
     * Gets the value of the at property.
     * 
     */
    public int getAt() {
        return at;
    }

    /**
     * Sets the value of the at property.
     * 
     */
    public void setAt(int value) {
        this.at = value;
    }

    /**
     * Gets the value of the rm property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRm() {
        return rm;
    }

    /**
     * Sets the value of the rm property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRm(String value) {
        this.rm = value;
    }

    /**
     * Gets the value of the merge property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMerge() {
        return merge;
    }

    /**
     * Sets the value of the merge property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMerge(String value) {
        this.merge = value;
    }

    /**
     * Gets the value of the nDocs property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNDocs() {
        if (nDocs == null) {
            return  0;
        } else {
            return nDocs;
        }
    }

    /**
     * Sets the value of the nDocs property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNDocs(Integer value) {
        this.nDocs = value;
    }

    /**
     * Gets the value of the maxDocs property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getMaxDocs() {
        if (maxDocs == null) {
            return  0;
        } else {
            return maxDocs;
        }
    }

    /**
     * Sets the value of the maxDocs property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxDocs(Integer value) {
        this.maxDocs = value;
    }

    /**
     * Gets the value of the minDocid property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getMinDocid() {
        if (minDocid == null) {
            return  0;
        } else {
            return minDocid;
        }
    }

    /**
     * Sets the value of the minDocid property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMinDocid(Integer value) {
        this.minDocid = value;
    }

    /**
     * Gets the value of the maxDocid property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getMaxDocid() {
        if (maxDocid == null) {
            return  0;
        } else {
            return maxDocid;
        }
    }

    /**
     * Sets the value of the maxDocid property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxDocid(Integer value) {
        this.maxDocid = value;
    }

    /**
     * Gets the value of the type property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getType() {
        if (type == null) {
            return "index";
        } else {
            return type;
        }
    }

    /**
     * Sets the value of the type property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setType(String value) {
        this.type = value;
    }

    /**
     * Gets the value of the main property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMain() {
        return main;
    }

    /**
     * Sets the value of the main property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMain(String value) {
        this.main = value;
    }

    /**
     * Gets the value of the oldIndex property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOldIndex() {
        return oldIndex;
    }

    /**
     * Sets the value of the oldIndex property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOldIndex(String value) {
        this.oldIndex = value;
    }

}
