
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
 *       &lt;choice maxOccurs="unbounded" minOccurs="0">
 *         &lt;element ref="{urn:/velocity/objects}param"/>
 *         &lt;element ref="{urn:/velocity/objects}parse-param"/>
 *         &lt;element ref="{urn:/velocity/objects}operator"/>
 *       &lt;/choice>
 *       &lt;attribute name="form" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "paramOrParseParamOrOperator"
})
@XmlRootElement(name = "query")
public class Query {

    @XmlElements({
        @XmlElement(name = "parse-param", type = ParseParam.class),
        @XmlElement(name = "param", type = Param.class),
        @XmlElement(name = "operator", type = Operator.class)
    })
    protected List<Object> paramOrParseParamOrOperator;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String form;

    /**
     * Gets the value of the paramOrParseParamOrOperator property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the paramOrParseParamOrOperator property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getParamOrParseParamOrOperator().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link ParseParam }
     * {@link Param }
     * {@link Operator }
     * 
     * 
     */
    public List<Object> getParamOrParseParamOrOperator() {
        if (paramOrParseParamOrOperator == null) {
            paramOrParseParamOrOperator = new ArrayList<Object>();
        }
        return this.paramOrParseParamOrOperator;
    }

    /**
     * Gets the value of the form property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getForm() {
        return form;
    }

    /**
     * Sets the value of the form property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setForm(String value) {
        this.form = value;
    }

}
