
package velocity.objects;

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
 *       &lt;attribute name="what" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="flags" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="occr-reads" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="block-reads" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="n-blocks" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="seeks" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="n-tau" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="n-rho" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="n-uat" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="n-ohr" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="cache-hits" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="cache-misses" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "query-performance")
public class QueryPerformance {

    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String what;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String flags;
    @XmlAttribute(name = "occr-reads")
    @XmlSchemaType(name = "anySimpleType")
    protected String occrReads;
    @XmlAttribute(name = "block-reads")
    @XmlSchemaType(name = "anySimpleType")
    protected String blockReads;
    @XmlAttribute(name = "n-blocks")
    @XmlSchemaType(name = "anySimpleType")
    protected String nBlocks;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String seeks;
    @XmlAttribute(name = "n-tau")
    @XmlSchemaType(name = "anySimpleType")
    protected String nTau;
    @XmlAttribute(name = "n-rho")
    @XmlSchemaType(name = "anySimpleType")
    protected String nRho;
    @XmlAttribute(name = "n-uat")
    @XmlSchemaType(name = "anySimpleType")
    protected String nUat;
    @XmlAttribute(name = "n-ohr")
    @XmlSchemaType(name = "anySimpleType")
    protected String nOhr;
    @XmlAttribute(name = "cache-hits")
    @XmlSchemaType(name = "anySimpleType")
    protected String cacheHits;
    @XmlAttribute(name = "cache-misses")
    @XmlSchemaType(name = "anySimpleType")
    protected String cacheMisses;

    /**
     * Gets the value of the what property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getWhat() {
        return what;
    }

    /**
     * Sets the value of the what property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setWhat(String value) {
        this.what = value;
    }

    /**
     * Gets the value of the flags property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFlags() {
        return flags;
    }

    /**
     * Sets the value of the flags property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFlags(String value) {
        this.flags = value;
    }

    /**
     * Gets the value of the occrReads property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOccrReads() {
        return occrReads;
    }

    /**
     * Sets the value of the occrReads property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOccrReads(String value) {
        this.occrReads = value;
    }

    /**
     * Gets the value of the blockReads property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBlockReads() {
        return blockReads;
    }

    /**
     * Sets the value of the blockReads property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBlockReads(String value) {
        this.blockReads = value;
    }

    /**
     * Gets the value of the nBlocks property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNBlocks() {
        return nBlocks;
    }

    /**
     * Sets the value of the nBlocks property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNBlocks(String value) {
        this.nBlocks = value;
    }

    /**
     * Gets the value of the seeks property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSeeks() {
        return seeks;
    }

    /**
     * Sets the value of the seeks property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSeeks(String value) {
        this.seeks = value;
    }

    /**
     * Gets the value of the nTau property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNTau() {
        return nTau;
    }

    /**
     * Sets the value of the nTau property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNTau(String value) {
        this.nTau = value;
    }

    /**
     * Gets the value of the nRho property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNRho() {
        return nRho;
    }

    /**
     * Sets the value of the nRho property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNRho(String value) {
        this.nRho = value;
    }

    /**
     * Gets the value of the nUat property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNUat() {
        return nUat;
    }

    /**
     * Sets the value of the nUat property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNUat(String value) {
        this.nUat = value;
    }

    /**
     * Gets the value of the nOhr property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNOhr() {
        return nOhr;
    }

    /**
     * Sets the value of the nOhr property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNOhr(String value) {
        this.nOhr = value;
    }

    /**
     * Gets the value of the cacheHits property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCacheHits() {
        return cacheHits;
    }

    /**
     * Sets the value of the cacheHits property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCacheHits(String value) {
        this.cacheHits = value;
    }

    /**
     * Gets the value of the cacheMisses property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCacheMisses() {
        return cacheMisses;
    }

    /**
     * Sets the value of the cacheMisses property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCacheMisses(String value) {
        this.cacheMisses = value;
    }

}
