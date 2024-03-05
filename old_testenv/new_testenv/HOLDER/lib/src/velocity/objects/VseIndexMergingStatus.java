
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
 *       &lt;sequence maxOccurs="unbounded" minOccurs="0">
 *         &lt;element ref="{urn:/velocity/objects}vse-index-merger-status"/>
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
    "vseIndexMergerStatus"
})
@XmlRootElement(name = "vse-index-merging-status")
public class VseIndexMergingStatus {

    @XmlElement(name = "vse-index-merger-status")
    protected List<VseIndexMergerStatus> vseIndexMergerStatus;

    /**
     * Gets the value of the vseIndexMergerStatus property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the vseIndexMergerStatus property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getVseIndexMergerStatus().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link VseIndexMergerStatus }
     * 
     * 
     */
    public List<VseIndexMergerStatus> getVseIndexMergerStatus() {
        if (vseIndexMergerStatus == null) {
            vseIndexMergerStatus = new ArrayList<VseIndexMergerStatus>();
        }
        return this.vseIndexMergerStatus;
    }

}
