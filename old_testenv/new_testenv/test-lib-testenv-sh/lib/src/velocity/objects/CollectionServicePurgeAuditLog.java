
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
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
 *         &lt;element ref="{urn:/velocity/objects}audit-log-purge"/>
 *       &lt;/sequence>
 *       &lt;attribute name="subcollection">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="live"/>
 *             &lt;enumeration value="staging"/>
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
    "auditLogPurge"
})
@XmlRootElement(name = "collection-service-purge-audit-log")
public class CollectionServicePurgeAuditLog {

    @XmlElement(name = "audit-log-purge", required = true)
    protected AuditLogPurge auditLogPurge;
    @XmlAttribute
    protected String subcollection;

    /**
     * Gets the value of the auditLogPurge property.
     * 
     * @return
     *     possible object is
     *     {@link AuditLogPurge }
     *     
     */
    public AuditLogPurge getAuditLogPurge() {
        return auditLogPurge;
    }

    /**
     * Sets the value of the auditLogPurge property.
     * 
     * @param value
     *     allowed object is
     *     {@link AuditLogPurge }
     *     
     */
    public void setAuditLogPurge(AuditLogPurge value) {
        this.auditLogPurge = value;
    }

    /**
     * Gets the value of the subcollection property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSubcollection() {
        return subcollection;
    }

    /**
     * Sets the value of the subcollection property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSubcollection(String value) {
        this.subcollection = value;
    }

}
