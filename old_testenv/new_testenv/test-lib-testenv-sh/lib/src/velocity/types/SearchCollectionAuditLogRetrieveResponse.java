
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import velocity.objects.AuditLogRetrieveResponse;


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
 *         &lt;element ref="{urn:/velocity/objects}audit-log-retrieve-response"/>
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
    "auditLogRetrieveResponse"
})
@XmlRootElement(name = "SearchCollectionAuditLogRetrieveResponse")
public class SearchCollectionAuditLogRetrieveResponse {

    @XmlElement(name = "audit-log-retrieve-response", namespace = "urn:/velocity/objects", required = true)
    protected AuditLogRetrieveResponse auditLogRetrieveResponse;

    /**
     * Gets the value of the auditLogRetrieveResponse property.
     * 
     * @return
     *     possible object is
     *     {@link AuditLogRetrieveResponse }
     *     
     */
    public AuditLogRetrieveResponse getAuditLogRetrieveResponse() {
        return auditLogRetrieveResponse;
    }

    /**
     * Sets the value of the auditLogRetrieveResponse property.
     * 
     * @param value
     *     allowed object is
     *     {@link AuditLogRetrieveResponse }
     *     
     */
    public void setAuditLogRetrieveResponse(AuditLogRetrieveResponse value) {
        this.auditLogRetrieveResponse = value;
    }

}
