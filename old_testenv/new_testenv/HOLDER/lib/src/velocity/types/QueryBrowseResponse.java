
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import velocity.objects.QueryResults;


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
 *         &lt;element ref="{urn:/velocity/objects}query-results"/>
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
    "queryResults"
})
@XmlRootElement(name = "QueryBrowseResponse")
public class QueryBrowseResponse {

    @XmlElement(name = "query-results", namespace = "urn:/velocity/objects", required = true)
    protected QueryResults queryResults;

    /**
     * Gets the value of the queryResults property.
     * 
     * @return
     *     possible object is
     *     {@link QueryResults }
     *     
     */
    public QueryResults getQueryResults() {
        return queryResults;
    }

    /**
     * Sets the value of the queryResults property.
     * 
     * @param value
     *     allowed object is
     *     {@link QueryResults }
     *     
     */
    public void setQueryResults(QueryResults value) {
        this.queryResults = value;
    }

}
