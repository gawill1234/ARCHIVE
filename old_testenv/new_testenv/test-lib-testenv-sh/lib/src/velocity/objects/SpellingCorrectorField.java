
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
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
 *       &lt;attribute name="field" type="{http://www.w3.org/2001/XMLSchema}string" default="query" />
 *       &lt;attribute name="dictionary" type="{http://www.w3.org/2001/XMLSchema}string" default="default" />
 *       &lt;attribute name="stemmer" type="{http://www.w3.org/2001/XMLSchema}string" default="delanguage+depluralize" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "spelling-corrector-field")
public class SpellingCorrectorField {

    @XmlAttribute
    protected String field;
    @XmlAttribute
    protected String dictionary;
    @XmlAttribute
    protected String stemmer;

    /**
     * Gets the value of the field property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getField() {
        if (field == null) {
            return "query";
        } else {
            return field;
        }
    }

    /**
     * Sets the value of the field property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setField(String value) {
        this.field = value;
    }

    /**
     * Gets the value of the dictionary property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDictionary() {
        if (dictionary == null) {
            return "default";
        } else {
            return dictionary;
        }
    }

    /**
     * Sets the value of the dictionary property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDictionary(String value) {
        this.dictionary = value;
    }

    /**
     * Gets the value of the stemmer property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStemmer() {
        if (stemmer == null) {
            return "delanguage+depluralize";
        } else {
            return stemmer;
        }
    }

    /**
     * Sets the value of the stemmer property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStemmer(String value) {
        this.stemmer = value;
    }

}
