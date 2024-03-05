
package velocity.types;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
import velocity.objects.Document;
import velocity.objects.Operator;
import velocity.soap.Authentication;


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
 *         &lt;element ref="{urn:/velocity/soap}authentication" minOccurs="0"/>
 *         &lt;element name="query-object" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element ref="{urn:/velocity/objects}operator"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="documents" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence maxOccurs="unbounded">
 *                   &lt;element ref="{urn:/velocity/objects}document"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="stemmers" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="kbs" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="segmenter" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="depth" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
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
    "authentication",
    "queryObject",
    "documents",
    "stemmers",
    "kbs",
    "segmenter",
    "depth"
})
@XmlRootElement(name = "QueryCluster")
public class QueryCluster {

    @XmlElement(namespace = "urn:/velocity/soap")
    protected Authentication authentication;
    @XmlElement(name = "query-object")
    protected QueryCluster.QueryObject queryObject;
    protected QueryCluster.Documents documents;
    @XmlElement(defaultValue = "delanguage english depluralize")
    protected String stemmers;
    @XmlElement(defaultValue = "core web english custom")
    protected String kbs;
    @XmlElement(defaultValue = "none")
    protected String segmenter;
    @XmlElement(defaultValue = "1")
    protected Integer depth;

    /**
     * Gets the value of the authentication property.
     * 
     * @return
     *     possible object is
     *     {@link Authentication }
     *     
     */
    public Authentication getAuthentication() {
        return authentication;
    }

    /**
     * Sets the value of the authentication property.
     * 
     * @param value
     *     allowed object is
     *     {@link Authentication }
     *     
     */
    public void setAuthentication(Authentication value) {
        this.authentication = value;
    }

    /**
     * Gets the value of the queryObject property.
     * 
     * @return
     *     possible object is
     *     {@link QueryCluster.QueryObject }
     *     
     */
    public QueryCluster.QueryObject getQueryObject() {
        return queryObject;
    }

    /**
     * Sets the value of the queryObject property.
     * 
     * @param value
     *     allowed object is
     *     {@link QueryCluster.QueryObject }
     *     
     */
    public void setQueryObject(QueryCluster.QueryObject value) {
        this.queryObject = value;
    }

    /**
     * Gets the value of the documents property.
     * 
     * @return
     *     possible object is
     *     {@link QueryCluster.Documents }
     *     
     */
    public QueryCluster.Documents getDocuments() {
        return documents;
    }

    /**
     * Sets the value of the documents property.
     * 
     * @param value
     *     allowed object is
     *     {@link QueryCluster.Documents }
     *     
     */
    public void setDocuments(QueryCluster.Documents value) {
        this.documents = value;
    }

    /**
     * Gets the value of the stemmers property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStemmers() {
        return stemmers;
    }

    /**
     * Sets the value of the stemmers property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStemmers(String value) {
        this.stemmers = value;
    }

    /**
     * Gets the value of the kbs property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getKbs() {
        return kbs;
    }

    /**
     * Sets the value of the kbs property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setKbs(String value) {
        this.kbs = value;
    }

    /**
     * Gets the value of the segmenter property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSegmenter() {
        return segmenter;
    }

    /**
     * Sets the value of the segmenter property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSegmenter(String value) {
        this.segmenter = value;
    }

    /**
     * Gets the value of the depth property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getDepth() {
        return depth;
    }

    /**
     * Sets the value of the depth property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setDepth(Integer value) {
        this.depth = value;
    }


    /**
     * <p>Java class for anonymous complex type.
     * 
     * <p>The following schema fragment specifies the expected content contained within this class.
     * 
     * <pre>
     * &lt;complexType>
     *   &lt;complexContent>
     *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *       &lt;sequence maxOccurs="unbounded">
     *         &lt;element ref="{urn:/velocity/objects}document"/>
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
        "document"
    })
    public static class Documents {

        @XmlElement(namespace = "urn:/velocity/objects", required = true)
        protected List<Document> document;

        /**
         * Gets the value of the document property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the document property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getDocument().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link Document }
         * 
         * 
         */
        public List<Document> getDocument() {
            if (document == null) {
                document = new ArrayList<Document>();
            }
            return this.document;
        }

    }


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
     *         &lt;element ref="{urn:/velocity/objects}operator"/>
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
        "operator"
    })
    public static class QueryObject {

        @XmlElement(namespace = "urn:/velocity/objects", required = true)
        protected Operator operator;

        /**
         * Gets the value of the operator property.
         * 
         * @return
         *     possible object is
         *     {@link Operator }
         *     
         */
        public Operator getOperator() {
            return operator;
        }

        /**
         * Sets the value of the operator property.
         * 
         * @param value
         *     allowed object is
         *     {@link Operator }
         *     
         */
        public void setOperator(Operator value) {
            this.operator = value;
        }

    }

}
