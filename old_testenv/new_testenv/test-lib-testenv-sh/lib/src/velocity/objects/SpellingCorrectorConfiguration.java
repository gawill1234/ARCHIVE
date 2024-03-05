
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
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
 *       &lt;sequence>
 *         &lt;element ref="{urn:/velocity/objects}spelling-corrector-field" maxOccurs="unbounded" minOccurs="0"/>
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
    "spellingCorrectorField"
})
@XmlRootElement(name = "spelling-corrector-configuration")
public class SpellingCorrectorConfiguration {

    @XmlElement(name = "spelling-corrector-field")
    protected List<SpellingCorrectorField> spellingCorrectorField;

    /**
     * Gets the value of the spellingCorrectorField property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the spellingCorrectorField property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getSpellingCorrectorField().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link SpellingCorrectorField }
     * 
     * 
     */
    public List<SpellingCorrectorField> getSpellingCorrectorField() {
        if (spellingCorrectorField == null) {
            spellingCorrectorField = new ArrayList<SpellingCorrectorField>();
        }
        return this.spellingCorrectorField;
    }

}
