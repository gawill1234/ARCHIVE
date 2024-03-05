
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
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
 *         &lt;element ref="{urn:/velocity/objects}descriptor" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}node" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}document"/>
 *       &lt;/sequence>
 *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *       &lt;attribute name="id" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="level" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="ndocs" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="nbdocs" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="sep" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="cohesion" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="score" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="instances" type="{http://www.w3.org/2001/XMLSchema}NMTOKENS" />
 *       &lt;attribute name="ls" type="{urn:/velocity/objects}state" />
 *       &lt;attribute name="ts" type="{urn:/velocity/objects}state" />
 *       &lt;attribute name="bs" type="{urn:/velocity/objects}state" />
 *       &lt;attribute name="active" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *       &lt;attribute name="subnodes" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="matched" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="start" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="per" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="open">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="open"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="other">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="other"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="type">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="open"/>
 *             &lt;enumeration value="close"/>
 *             &lt;enumeration value="top"/>
 *             &lt;enumeration value="more"/>
 *             &lt;enumeration value="document"/>
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
    "descriptor",
    "node",
    "document"
})
@XmlRootElement(name = "node")
public class Node {

    protected List<Descriptor> descriptor;
    protected List<Node> node;
    @XmlElement(required = true)
    protected Document document;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String id;
    @XmlAttribute
    protected Integer level;
    @XmlAttribute
    protected Integer ndocs;
    @XmlAttribute
    protected Integer nbdocs;
    @XmlAttribute
    protected Double sep;
    @XmlAttribute
    protected Double cohesion;
    @XmlAttribute
    protected Double score;
    @XmlAttribute
    @XmlSchemaType(name = "NMTOKENS")
    protected List<String> instances;
    @XmlAttribute
    protected String ls;
    @XmlAttribute
    protected String ts;
    @XmlAttribute
    protected String bs;
    @XmlAttribute
    protected java.lang.Boolean active;
    @XmlAttribute
    protected Integer subnodes;
    @XmlAttribute
    protected Integer matched;
    @XmlAttribute
    protected Integer start;
    @XmlAttribute
    protected Integer per;
    @XmlAttribute
    protected String open;
    @XmlAttribute
    protected String other;
    @XmlAttribute
    protected String type;
    @XmlAttribute
    protected java.lang.Boolean async;
    @XmlAttribute(name = "elt-id")
    protected Integer eltId;
    @XmlAttribute(name = "max-elt-id")
    protected Integer maxEltId;
    @XmlAttribute(name = "execute-acl")
    protected String executeAcl;
    @XmlAttribute
    protected String process;

    /**
     * Gets the value of the descriptor property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the descriptor property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getDescriptor().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Descriptor }
     * 
     * 
     */
    public List<Descriptor> getDescriptor() {
        if (descriptor == null) {
            descriptor = new ArrayList<Descriptor>();
        }
        return this.descriptor;
    }

    /**
     * Gets the value of the node property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the node property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getNode().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Node }
     * 
     * 
     */
    public List<Node> getNode() {
        if (node == null) {
            node = new ArrayList<Node>();
        }
        return this.node;
    }

    /**
     * Gets the value of the document property.
     * 
     * @return
     *     possible object is
     *     {@link Document }
     *     
     */
    public Document getDocument() {
        return document;
    }

    /**
     * Sets the value of the document property.
     * 
     * @param value
     *     allowed object is
     *     {@link Document }
     *     
     */
    public void setDocument(Document value) {
        this.document = value;
    }

    /**
     * Gets the value of the id property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getId() {
        return id;
    }

    /**
     * Sets the value of the id property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setId(String value) {
        this.id = value;
    }

    /**
     * Gets the value of the level property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getLevel() {
        return level;
    }

    /**
     * Sets the value of the level property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setLevel(Integer value) {
        this.level = value;
    }

    /**
     * Gets the value of the ndocs property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNdocs() {
        return ndocs;
    }

    /**
     * Sets the value of the ndocs property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNdocs(Integer value) {
        this.ndocs = value;
    }

    /**
     * Gets the value of the nbdocs property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNbdocs() {
        return nbdocs;
    }

    /**
     * Sets the value of the nbdocs property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNbdocs(Integer value) {
        this.nbdocs = value;
    }

    /**
     * Gets the value of the sep property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getSep() {
        return sep;
    }

    /**
     * Sets the value of the sep property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setSep(Double value) {
        this.sep = value;
    }

    /**
     * Gets the value of the cohesion property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getCohesion() {
        return cohesion;
    }

    /**
     * Sets the value of the cohesion property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setCohesion(Double value) {
        this.cohesion = value;
    }

    /**
     * Gets the value of the score property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getScore() {
        return score;
    }

    /**
     * Sets the value of the score property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setScore(Double value) {
        this.score = value;
    }

    /**
     * Gets the value of the instances property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the instances property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getInstances().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link String }
     * 
     * 
     */
    public List<String> getInstances() {
        if (instances == null) {
            instances = new ArrayList<String>();
        }
        return this.instances;
    }

    /**
     * Gets the value of the ls property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLs() {
        return ls;
    }

    /**
     * Sets the value of the ls property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLs(String value) {
        this.ls = value;
    }

    /**
     * Gets the value of the ts property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTs() {
        return ts;
    }

    /**
     * Sets the value of the ts property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTs(String value) {
        this.ts = value;
    }

    /**
     * Gets the value of the bs property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBs() {
        return bs;
    }

    /**
     * Sets the value of the bs property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBs(String value) {
        this.bs = value;
    }

    /**
     * Gets the value of the active property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isActive() {
        return active;
    }

    /**
     * Sets the value of the active property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setActive(java.lang.Boolean value) {
        this.active = value;
    }

    /**
     * Gets the value of the subnodes property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getSubnodes() {
        return subnodes;
    }

    /**
     * Sets the value of the subnodes property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setSubnodes(Integer value) {
        this.subnodes = value;
    }

    /**
     * Gets the value of the matched property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMatched() {
        return matched;
    }

    /**
     * Sets the value of the matched property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMatched(Integer value) {
        this.matched = value;
    }

    /**
     * Gets the value of the start property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getStart() {
        return start;
    }

    /**
     * Sets the value of the start property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setStart(Integer value) {
        this.start = value;
    }

    /**
     * Gets the value of the per property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getPer() {
        return per;
    }

    /**
     * Sets the value of the per property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setPer(Integer value) {
        this.per = value;
    }

    /**
     * Gets the value of the open property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOpen() {
        return open;
    }

    /**
     * Sets the value of the open property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOpen(String value) {
        this.open = value;
    }

    /**
     * Gets the value of the other property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOther() {
        return other;
    }

    /**
     * Sets the value of the other property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOther(String value) {
        this.other = value;
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
        return type;
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
     * Gets the value of the async property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public boolean isAsync() {
        if (async == null) {
            return true;
        } else {
            return async;
        }
    }

    /**
     * Sets the value of the async property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setAsync(java.lang.Boolean value) {
        this.async = value;
    }

    /**
     * Gets the value of the eltId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getEltId() {
        return eltId;
    }

    /**
     * Sets the value of the eltId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setEltId(Integer value) {
        this.eltId = value;
    }

    /**
     * Gets the value of the maxEltId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaxEltId() {
        return maxEltId;
    }

    /**
     * Sets the value of the maxEltId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxEltId(Integer value) {
        this.maxEltId = value;
    }

    /**
     * Gets the value of the executeAcl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getExecuteAcl() {
        return executeAcl;
    }

    /**
     * Sets the value of the executeAcl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setExecuteAcl(String value) {
        this.executeAcl = value;
    }

    /**
     * Gets the value of the process property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getProcess() {
        return process;
    }

    /**
     * Sets the value of the process property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setProcess(String value) {
        this.process = value;
    }

}
