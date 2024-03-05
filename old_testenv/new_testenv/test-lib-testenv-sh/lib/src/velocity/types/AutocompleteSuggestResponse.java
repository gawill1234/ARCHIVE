
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import velocity.objects.Suggestions;


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
 *         &lt;element ref="{urn:/velocity/objects}suggestions"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "suggestions"
})
@XmlRootElement(name = "AutocompleteSuggestResponse")
public class AutocompleteSuggestResponse {

    @XmlElement(namespace = "urn:/velocity/objects", required = true)
    protected Suggestions suggestions;

    /**
     * Gets the value of the suggestions property.
     * 
     * @return
     *     possible object is
     *     {@link Suggestions }
     *     
     */
    public Suggestions getSuggestions() {
        return suggestions;
    }

    /**
     * Sets the value of the suggestions property.
     * 
     * @param value
     *     allowed object is
     *     {@link Suggestions }
     *     
     */
    public void setSuggestions(Suggestions value) {
        this.suggestions = value;
    }

}
