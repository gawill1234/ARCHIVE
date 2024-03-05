
package velocity.objects;

import java.math.BigInteger;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
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
 *       &lt;attribute name="n-offline-queue" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" default="0" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "crawler-offline-status")
public class CrawlerOfflineStatus {

    @XmlAttribute(name = "n-offline-queue")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger nOfflineQueue;

    /**
     * Gets the value of the nOfflineQueue property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getNOfflineQueue() {
        if (nOfflineQueue == null) {
            return new BigInteger("0");
        } else {
            return nOfflineQueue;
        }
    }

    /**
     * Sets the value of the nOfflineQueue property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setNOfflineQueue(BigInteger value) {
        this.nOfflineQueue = value;
    }

}
