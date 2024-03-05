
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import velocity.objects.SystemReport;


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
 *         &lt;element ref="{urn:/velocity/objects}system-report"/>
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
    "systemReport"
})
@XmlRootElement(name = "ReportsSystemReportingResponse")
public class ReportsSystemReportingResponse {

    @XmlElement(name = "system-report", namespace = "urn:/velocity/objects", required = true)
    protected SystemReport systemReport;

    /**
     * Gets the value of the systemReport property.
     * 
     * @return
     *     possible object is
     *     {@link SystemReport }
     *     
     */
    public SystemReport getSystemReport() {
        return systemReport;
    }

    /**
     * Sets the value of the systemReport property.
     * 
     * @param value
     *     allowed object is
     *     {@link SystemReport }
     *     
     */
    public void setSystemReport(SystemReport value) {
        this.systemReport = value;
    }

}
