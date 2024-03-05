
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
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
 *       &lt;choice maxOccurs="unbounded">
 *         &lt;element ref="{urn:/velocity/objects}converter"/>
 *         &lt;element ref="{urn:/velocity/objects}scope"/>
 *       &lt;/choice>
 *       &lt;attribute name="collection" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="binpath" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="java-bin" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="java-classpath" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="cpu-limit" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="memory-limit" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "converterOrScope"
})
@XmlRootElement(name = "converters")
public class Converters {

    @XmlElements({
        @XmlElement(name = "scope", type = Scope.class),
        @XmlElement(name = "converter", type = Converter.class)
    })
    protected List<Object> converterOrScope;
    @XmlAttribute
    protected String collection;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String binpath;
    @XmlAttribute(name = "java-bin")
    @XmlSchemaType(name = "anySimpleType")
    protected String javaBin;
    @XmlAttribute(name = "java-classpath")
    @XmlSchemaType(name = "anySimpleType")
    protected String javaClasspath;
    @XmlAttribute(name = "cpu-limit")
    @XmlSchemaType(name = "anySimpleType")
    protected String cpuLimit;
    @XmlAttribute(name = "memory-limit")
    @XmlSchemaType(name = "anySimpleType")
    protected String memoryLimit;

    /**
     * Gets the value of the converterOrScope property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the converterOrScope property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getConverterOrScope().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Scope }
     * {@link Converter }
     * 
     * 
     */
    public List<Object> getConverterOrScope() {
        if (converterOrScope == null) {
            converterOrScope = new ArrayList<Object>();
        }
        return this.converterOrScope;
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
     * Gets the value of the binpath property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBinpath() {
        return binpath;
    }

    /**
     * Sets the value of the binpath property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBinpath(String value) {
        this.binpath = value;
    }

    /**
     * Gets the value of the javaBin property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getJavaBin() {
        return javaBin;
    }

    /**
     * Sets the value of the javaBin property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setJavaBin(String value) {
        this.javaBin = value;
    }

    /**
     * Gets the value of the javaClasspath property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getJavaClasspath() {
        return javaClasspath;
    }

    /**
     * Sets the value of the javaClasspath property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setJavaClasspath(String value) {
        this.javaClasspath = value;
    }

    /**
     * Gets the value of the cpuLimit property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCpuLimit() {
        return cpuLimit;
    }

    /**
     * Sets the value of the cpuLimit property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCpuLimit(String value) {
        this.cpuLimit = value;
    }

    /**
     * Gets the value of the memoryLimit property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMemoryLimit() {
        return memoryLimit;
    }

    /**
     * Sets the value of the memoryLimit property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMemoryLimit(String value) {
        this.memoryLimit = value;
    }

}
