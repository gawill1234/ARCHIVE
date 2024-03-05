
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
 *       &lt;choice maxOccurs="unbounded" minOccurs="0">
 *         &lt;element ref="{urn:/velocity/objects}description" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}label" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}declare"/>
 *         &lt;element name="returns">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;attribute name="type" type="{urn:/velocity/objects}declare-type" />
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="throws" type="{http://www.w3.org/2001/XMLSchema}anyType"/>
 *         &lt;element ref="{urn:/velocity/objects}proto-section"/>
 *         &lt;element ref="{urn:/velocity/objects}available"/>
 *         &lt;element ref="{urn:/velocity/objects}deprecated"/>
 *         &lt;element ref="{urn:/velocity/objects}unavailable"/>
 *       &lt;/choice>
 *       &lt;attribute name="no-comment" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="proto-order">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="proto-order"/>
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
    "descriptionOrLabelOrDeclare"
})
@XmlRootElement(name = "prototype")
public class Prototype {

    @XmlElements({
        @XmlElement(name = "unavailable", type = Unavailable.class),
        @XmlElement(name = "proto-section", type = ProtoSection.class),
        @XmlElement(name = "description", type = Description.class),
        @XmlElement(name = "deprecated", type = Deprecated.class),
        @XmlElement(name = "available", type = Available.class),
        @XmlElement(name = "returns", type = Prototype.Returns.class),
        @XmlElement(name = "label", type = Label.class),
        @XmlElement(name = "throws"),
        @XmlElement(name = "declare", type = Declare.class)
    })
    protected List<Object> descriptionOrLabelOrDeclare;
    @XmlAttribute(name = "no-comment")
    @XmlSchemaType(name = "anySimpleType")
    protected String noComment;
    @XmlAttribute(name = "proto-order")
    protected String protoOrder;

    /**
     * Gets the value of the descriptionOrLabelOrDeclare property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the descriptionOrLabelOrDeclare property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getDescriptionOrLabelOrDeclare().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Unavailable }
     * {@link ProtoSection }
     * {@link Description }
     * {@link Deprecated }
     * {@link Available }
     * {@link Prototype.Returns }
     * {@link Label }
     * {@link Object }
     * {@link Declare }
     * 
     * 
     */
    public List<Object> getDescriptionOrLabelOrDeclare() {
        if (descriptionOrLabelOrDeclare == null) {
            descriptionOrLabelOrDeclare = new ArrayList<Object>();
        }
        return this.descriptionOrLabelOrDeclare;
    }

    /**
     * Gets the value of the noComment property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNoComment() {
        return noComment;
    }

    /**
     * Sets the value of the noComment property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNoComment(String value) {
        this.noComment = value;
    }

    /**
     * Gets the value of the protoOrder property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getProtoOrder() {
        return protoOrder;
    }

    /**
     * Sets the value of the protoOrder property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setProtoOrder(String value) {
        this.protoOrder = value;
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
     *       &lt;attribute name="type" type="{urn:/velocity/objects}declare-type" />
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "")
    public static class Returns {

        @XmlAttribute
        protected DeclareType type;

        /**
         * Gets the value of the type property.
         * 
         * @return
         *     possible object is
         *     {@link DeclareType }
         *     
         */
        public DeclareType getType() {
            return type;
        }

        /**
         * Sets the value of the type property.
         * 
         * @param value
         *     allowed object is
         *     {@link DeclareType }
         *     
         */
        public void setType(DeclareType value) {
            this.type = value;
        }

    }

}
