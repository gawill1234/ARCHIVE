
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
 *         &lt;element ref="{urn:/velocity/objects}system-reporting-database" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}system-report-item" maxOccurs="unbounded" minOccurs="0"/>
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
    "systemReportingDatabase",
    "systemReportItem"
})
@XmlRootElement(name = "system-report")
public class SystemReport {

    @XmlElement(name = "system-reporting-database")
    protected List<SystemReportingDatabase> systemReportingDatabase;
    @XmlElement(name = "system-report-item")
    protected List<SystemReportItem> systemReportItem;

    /**
     * Gets the value of the systemReportingDatabase property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the systemReportingDatabase property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getSystemReportingDatabase().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link SystemReportingDatabase }
     * 
     * 
     */
    public List<SystemReportingDatabase> getSystemReportingDatabase() {
        if (systemReportingDatabase == null) {
            systemReportingDatabase = new ArrayList<SystemReportingDatabase>();
        }
        return this.systemReportingDatabase;
    }

    /**
     * Gets the value of the systemReportItem property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the systemReportItem property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getSystemReportItem().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link SystemReportItem }
     * 
     * 
     */
    public List<SystemReportItem> getSystemReportItem() {
        if (systemReportItem == null) {
            systemReportItem = new ArrayList<SystemReportItem>();
        }
        return this.systemReportItem;
    }

}
