
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
 *         &lt;element ref="{urn:/velocity/objects}read-only-state" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="n-enabled" use="required" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="n-pending" use="required" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="n-disabled" use="required" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "readOnlyState"
})
@XmlRootElement(name = "read-only-state-all")
public class ReadOnlyStateAll {

    @XmlElement(name = "read-only-state")
    protected List<ReadOnlyState> readOnlyState;
    @XmlAttribute(name = "n-enabled", required = true)
    @XmlSchemaType(name = "unsignedInt")
    protected long nEnabled;
    @XmlAttribute(name = "n-pending", required = true)
    @XmlSchemaType(name = "unsignedInt")
    protected long nPending;
    @XmlAttribute(name = "n-disabled", required = true)
    @XmlSchemaType(name = "unsignedInt")
    protected long nDisabled;

    /**
     * Gets the value of the readOnlyState property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the readOnlyState property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getReadOnlyState().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link ReadOnlyState }
     * 
     * 
     */
    public List<ReadOnlyState> getReadOnlyState() {
        if (readOnlyState == null) {
            readOnlyState = new ArrayList<ReadOnlyState>();
        }
        return this.readOnlyState;
    }

    /**
     * Gets the value of the nEnabled property.
     * 
     */
    public long getNEnabled() {
        return nEnabled;
    }

    /**
     * Sets the value of the nEnabled property.
     * 
     */
    public void setNEnabled(long value) {
        this.nEnabled = value;
    }

    /**
     * Gets the value of the nPending property.
     * 
     */
    public long getNPending() {
        return nPending;
    }

    /**
     * Sets the value of the nPending property.
     * 
     */
    public void setNPending(long value) {
        this.nPending = value;
    }

    /**
     * Gets the value of the nDisabled property.
     * 
     */
    public long getNDisabled() {
        return nDisabled;
    }

    /**
     * Sets the value of the nDisabled property.
     * 
     */
    public void setNDisabled(long value) {
        this.nDisabled = value;
    }

}
