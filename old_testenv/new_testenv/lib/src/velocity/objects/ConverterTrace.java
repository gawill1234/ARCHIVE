
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
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
 *       &lt;choice>
 *         &lt;element ref="{urn:/velocity/objects}converter"/>
 *       &lt;/choice>
 *       &lt;attribute name="n" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="cur-data-size" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="type-in" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="type-out" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="bytes-in" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="bytes-out" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="execute" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="message" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "converter"
})
@XmlRootElement(name = "converter-trace")
public class ConverterTrace {

    protected Converter converter;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String n;
    @XmlAttribute(name = "cur-data-size")
    protected Long curDataSize;
    @XmlAttribute(name = "type-in")
    @XmlSchemaType(name = "anySimpleType")
    protected String typeIn;
    @XmlAttribute(name = "type-out")
    @XmlSchemaType(name = "anySimpleType")
    protected String typeOut;
    @XmlAttribute(name = "bytes-in")
    protected Long bytesIn;
    @XmlAttribute(name = "bytes-out")
    protected Long bytesOut;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String execute;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String message;

    /**
     * Gets the value of the converter property.
     * 
     * @return
     *     possible object is
     *     {@link Converter }
     *     
     */
    public Converter getConverter() {
        return converter;
    }

    /**
     * Sets the value of the converter property.
     * 
     * @param value
     *     allowed object is
     *     {@link Converter }
     *     
     */
    public void setConverter(Converter value) {
        this.converter = value;
    }

    /**
     * Gets the value of the n property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getN() {
        return n;
    }

    /**
     * Sets the value of the n property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setN(String value) {
        this.n = value;
    }

    /**
     * Gets the value of the curDataSize property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getCurDataSize() {
        return curDataSize;
    }

    /**
     * Sets the value of the curDataSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setCurDataSize(Long value) {
        this.curDataSize = value;
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
        return typeIn;
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
        return typeOut;
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
     * Gets the value of the bytesIn property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getBytesIn() {
        return bytesIn;
    }

    /**
     * Sets the value of the bytesIn property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setBytesIn(Long value) {
        this.bytesIn = value;
    }

    /**
     * Gets the value of the bytesOut property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getBytesOut() {
        return bytesOut;
    }

    /**
     * Sets the value of the bytesOut property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setBytesOut(Long value) {
        this.bytesOut = value;
    }

    /**
     * Gets the value of the execute property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getExecute() {
        return execute;
    }

    /**
     * Sets the value of the execute property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setExecute(String value) {
        this.execute = value;
    }

    /**
     * Gets the value of the message property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMessage() {
        return message;
    }

    /**
     * Sets the value of the message property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMessage(String value) {
        this.message = value;
    }

}
