
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
 *         &lt;element ref="{urn:/velocity/objects}vse-index-option" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-tags" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-url-equivs" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}vse-index-streams" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}binning-sets" minOccurs="0"/>
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
    "vseIndexOption",
    "vseTags",
    "vseUrlEquivs",
    "vseIndexStreams",
    "binningSets"
})
@XmlRootElement(name = "vse-index")
public class VseIndex {

    @XmlElement(name = "vse-index-option")
    protected List<VseIndexOption> vseIndexOption;
    @XmlElement(name = "vse-tags")
    protected VseTags vseTags;
    @XmlElement(name = "vse-url-equivs")
    protected VseUrlEquivs vseUrlEquivs;
    @XmlElement(name = "vse-index-streams")
    protected VseIndexStreams vseIndexStreams;
    @XmlElement(name = "binning-sets")
    protected BinningSets binningSets;

    /**
     * Gets the value of the vseIndexOption property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseIndexOption property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseIndexOption().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link VseIndexOption }
     * 
     * 
     */
    public List<VseIndexOption> getVseIndexOption() {
        if (vseIndexOption == null) {
            vseIndexOption = new ArrayList<VseIndexOption>();
        }
        return this.vseIndexOption;
    }

    /**
     * Gets the value of the vseTags property.
     * 
     * @return
     *     possible object is
     *     {@link VseTags }
     *     
     */
    public VseTags getVseTags() {
        return vseTags;
    }

    /**
     * Sets the value of the vseTags property.
     * 
     * @param value
     *     allowed object is
     *     {@link VseTags }
     *     
     */
    public void setVseTags(VseTags value) {
        this.vseTags = value;
    }

    /**
     * Gets the value of the vseUrlEquivs property.
     * 
     * @return
     *     possible object is
     *     {@link VseUrlEquivs }
     *     
     */
    public VseUrlEquivs getVseUrlEquivs() {
        return vseUrlEquivs;
    }

    /**
     * Sets the value of the vseUrlEquivs property.
     * 
     * @param value
     *     allowed object is
     *     {@link VseUrlEquivs }
     *     
     */
    public void setVseUrlEquivs(VseUrlEquivs value) {
        this.vseUrlEquivs = value;
    }

    /**
     * Gets the value of the vseIndexStreams property.
     * 
     * @return
     *     possible object is
     *     {@link VseIndexStreams }
     *     
     */
    public VseIndexStreams getVseIndexStreams() {
        return vseIndexStreams;
    }

    /**
     * Sets the value of the vseIndexStreams property.
     * 
     * @param value
     *     allowed object is
     *     {@link VseIndexStreams }
     *     
     */
    public void setVseIndexStreams(VseIndexStreams value) {
        this.vseIndexStreams = value;
    }

    /**
     * Gets the value of the binningSets property.
     * 
     * @return
     *     possible object is
     *     {@link BinningSets }
     *     
     */
    public BinningSets getBinningSets() {
        return binningSets;
    }

    /**
     * Sets the value of the binningSets property.
     * 
     * @param value
     *     allowed object is
     *     {@link BinningSets }
     *     
     */
    public void setBinningSets(BinningSets value) {
        this.binningSets = value;
    }

}
