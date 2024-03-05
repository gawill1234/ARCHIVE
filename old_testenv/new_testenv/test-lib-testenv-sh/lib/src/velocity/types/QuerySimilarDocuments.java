
package velocity.types;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;
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
 *         &lt;element name="document">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element ref="{urn:/velocity/objects}document"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="stemmers" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="knowledge-bases" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="top-terms" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="num-terms" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="max-phrase-length" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
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
    "document",
    "stemmers",
    "knowledgeBases",
    "topTerms",
    "numTerms",
    "maxPhraseLength"
})
@XmlRootElement(name = "QuerySimilarDocuments")
public class QuerySimilarDocuments {

    @XmlElement(namespace = "urn:/velocity/soap")
    protected Authentication authentication;
    @XmlElement(required = true)
    protected QuerySimilarDocuments.Document document;
    @XmlElement(defaultValue = "case")
    protected String stemmers;
    @XmlElement(name = "knowledge-bases", defaultValue = "english-multi")
    protected String knowledgeBases;
    @XmlElement(name = "top-terms", defaultValue = "10")
    protected Integer topTerms;
    @XmlElement(name = "num-terms", defaultValue = "5")
    protected Integer numTerms;
    @XmlElement(name = "max-phrase-length", defaultValue = "3")
    protected Integer maxPhraseLength;

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
     * Gets the value of the document property.
     * 
     * @return
     *     possible object is
     *     {@link QuerySimilarDocuments.Document }
     *     
     */
    public QuerySimilarDocuments.Document getDocument() {
        return document;
    }

    /**
     * Sets the value of the document property.
     * 
     * @param value
     *     allowed object is
     *     {@link QuerySimilarDocuments.Document }
     *     
     */
    public void setDocument(QuerySimilarDocuments.Document value) {
        this.document = value;
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
     * Gets the value of the knowledgeBases property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getKnowledgeBases() {
        return knowledgeBases;
    }

    /**
     * Sets the value of the knowledgeBases property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setKnowledgeBases(String value) {
        this.knowledgeBases = value;
    }

    /**
     * Gets the value of the topTerms property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getTopTerms() {
        return topTerms;
    }

    /**
     * Sets the value of the topTerms property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setTopTerms(Integer value) {
        this.topTerms = value;
    }

    /**
     * Gets the value of the numTerms property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNumTerms() {
        return numTerms;
    }

    /**
     * Sets the value of the numTerms property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNumTerms(Integer value) {
        this.numTerms = value;
    }

    /**
     * Gets the value of the maxPhraseLength property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaxPhraseLength() {
        return maxPhraseLength;
    }

    /**
     * Sets the value of the maxPhraseLength property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxPhraseLength(Integer value) {
        this.maxPhraseLength = value;
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
    public static class Document {

        @XmlElement(namespace = "urn:/velocity/objects", required = true)
        protected velocity.objects.Document document;

        /**
         * Gets the value of the document property.
         * 
         * @return
         *     possible object is
         *     {@link velocity.objects.Document }
         *     
         */
        public velocity.objects.Document getDocument() {
            return document;
        }

        /**
         * Sets the value of the document property.
         * 
         * @param value
         *     allowed object is
         *     {@link velocity.objects.Document }
         *     
         */
        public void setDocument(velocity.objects.Document value) {
            this.document = value;
        }

    }

}
