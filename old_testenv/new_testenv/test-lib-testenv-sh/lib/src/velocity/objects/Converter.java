
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
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
 *       &lt;sequence>
 *         &lt;element ref="{urn:/velocity/objects}converter-test" minOccurs="0"/>
 *         &lt;choice minOccurs="0">
 *           &lt;element ref="{urn:/velocity/objects}scope"/>
 *           &lt;element ref="{urn:/velocity/objects}converter-execute"/>
 *           &lt;element ref="{urn:/velocity/objects}parser"/>
 *         &lt;/choice>
 *       &lt;/sequence>
 *       &lt;attribute name="type-in" type="{http://www.w3.org/2001/XMLSchema}string" default="unknown" />
 *       &lt;attribute name="type-out" type="{http://www.w3.org/2001/XMLSchema}string" default="unknown" />
 *       &lt;attribute name="fallback" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="program" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="fork">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="fork"/>
 *             &lt;enumeration value="fork-with-new-name"/>
 *             &lt;enumeration value="glue"/>
 *             &lt;enumeration value="fork-and-glue"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="timing-name" type="{http://www.w3.org/2001/XMLSchema}string" default="Other" />
 *       &lt;attribute name="attribute-name" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="attribute-value" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="attribute-sep" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="min-max-cpu" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="min-max-memory" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="min-max-elapsed" type="{http://www.w3.org/2001/XMLSchema}int" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "converterTest",
    "scope",
    "converterExecute",
    "parser"
})
@XmlRootElement(name = "converter")
public class Converter {

    @XmlElement(name = "converter-test")
    protected ConverterTest converterTest;
    protected Scope scope;
    @XmlElement(name = "converter-execute")
    protected String converterExecute;
    protected Parser parser;
    @XmlAttribute(name = "type-in")
    protected String typeIn;
    @XmlAttribute(name = "type-out")
    protected String typeOut;
    @XmlAttribute
    protected String fallback;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String program;
    @XmlAttribute
    protected String fork;
    @XmlAttribute(name = "timing-name")
    protected String timingName;
    @XmlAttribute(name = "attribute-name")
    protected String attributeName;
    @XmlAttribute(name = "attribute-value")
    protected String attributeValue;
    @XmlAttribute(name = "attribute-sep")
    protected String attributeSep;
    @XmlAttribute(name = "min-max-cpu")
    protected Integer minMaxCpu;
    @XmlAttribute(name = "min-max-memory")
    protected Integer minMaxMemory;
    @XmlAttribute(name = "min-max-elapsed")
    protected Integer minMaxElapsed;

    /**
     * Gets the value of the converterTest property.
     * 
     * @return
     *     possible object is
     *     {@link ConverterTest }
     *     
     */
    public ConverterTest getConverterTest() {
        return converterTest;
    }

    /**
     * Sets the value of the converterTest property.
     * 
     * @param value
     *     allowed object is
     *     {@link ConverterTest }
     *     
     */
    public void setConverterTest(ConverterTest value) {
        this.converterTest = value;
    }

    /**
     * Gets the value of the scope property.
     * 
     * @return
     *     possible object is
     *     {@link Scope }
     *     
     */
    public Scope getScope() {
        return scope;
    }

    /**
     * Sets the value of the scope property.
     * 
     * @param value
     *     allowed object is
     *     {@link Scope }
     *     
     */
    public void setScope(Scope value) {
        this.scope = value;
    }

    /**
     * Gets the value of the converterExecute property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getConverterExecute() {
        return converterExecute;
    }

    /**
     * Sets the value of the converterExecute property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setConverterExecute(String value) {
        this.converterExecute = value;
    }

    /**
     * Gets the value of the parser property.
     * 
     * @return
     *     possible object is
     *     {@link Parser }
     *     
     */
    public Parser getParser() {
        return parser;
    }

    /**
     * Sets the value of the parser property.
     * 
     * @param value
     *     allowed object is
     *     {@link Parser }
     *     
     */
    public void setParser(Parser value) {
        this.parser = value;
    }

    /**
     * Gets the value of the typeIn property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTypeIn() {
        if (typeIn == null) {
            return "unknown";
        } else {
            return typeIn;
        }
    }

    /**
     * Sets the value of the typeIn property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTypeIn(String value) {
        this.typeIn = value;
    }

    /**
     * Gets the value of the typeOut property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTypeOut() {
        if (typeOut == null) {
            return "unknown";
        } else {
            return typeOut;
        }
    }

    /**
     * Sets the value of the typeOut property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTypeOut(String value) {
        this.typeOut = value;
    }

    /**
     * Gets the value of the fallback property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFallback() {
        return fallback;
    }

    /**
     * Sets the value of the fallback property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFallback(String value) {
        this.fallback = value;
    }

    /**
     * Gets the value of the program property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getProgram() {
        return program;
    }

    /**
     * Sets the value of the program property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setProgram(String value) {
        this.program = value;
    }

    /**
     * Gets the value of the fork property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFork() {
        return fork;
    }

    /**
     * Sets the value of the fork property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFork(String value) {
        this.fork = value;
    }

    /**
     * Gets the value of the timingName property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTimingName() {
        if (timingName == null) {
            return "Other";
        } else {
            return timingName;
        }
    }

    /**
     * Sets the value of the timingName property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTimingName(String value) {
        this.timingName = value;
    }

    /**
     * Gets the value of the attributeName property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAttributeName() {
        return attributeName;
    }

    /**
     * Sets the value of the attributeName property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAttributeName(String value) {
        this.attributeName = value;
    }

    /**
     * Gets the value of the attributeValue property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAttributeValue() {
        return attributeValue;
    }

    /**
     * Sets the value of the attributeValue property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAttributeValue(String value) {
        this.attributeValue = value;
    }

    /**
     * Gets the value of the attributeSep property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAttributeSep() {
        return attributeSep;
    }

    /**
     * Sets the value of the attributeSep property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAttributeSep(String value) {
        this.attributeSep = value;
    }

    /**
     * Gets the value of the minMaxCpu property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMinMaxCpu() {
        return minMaxCpu;
    }

    /**
     * Sets the value of the minMaxCpu property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMinMaxCpu(Integer value) {
        this.minMaxCpu = value;
    }

    /**
     * Gets the value of the minMaxMemory property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMinMaxMemory() {
        return minMaxMemory;
    }

    /**
     * Sets the value of the minMaxMemory property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMinMaxMemory(Integer value) {
        this.minMaxMemory = value;
    }

    /**
     * Gets the value of the minMaxElapsed property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMinMaxElapsed() {
        return minMaxElapsed;
    }

    /**
     * Sets the value of the minMaxElapsed property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMinMaxElapsed(Integer value) {
        this.minMaxElapsed = value;
    }

}
