
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
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
 *         &lt;element ref="{urn:/velocity/objects}r"/>
 *       &lt;/sequence>
 *       &lt;attribute name="doc" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="score" type="{http://www.w3.org/2001/XMLSchema}float" />
 *       &lt;attribute name="base-score" type="{http://www.w3.org/2001/XMLSchema}float" />
 *       &lt;attribute name="la-score" type="{http://www.w3.org/2001/XMLSchema}float" />
 *       &lt;attribute name="n-collapsed" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="total-collapsed" type="{http://www.w3.org/2001/XMLSchema}int" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "r"
})
@XmlRootElement(name = "ranking-info")
public class RankingInfo {

    protected List<R> r;
    @XmlAttribute
    protected Integer doc;
    @XmlAttribute
    protected Float score;
    @XmlAttribute(name = "base-score")
    protected Float baseScore;
    @XmlAttribute(name = "la-score")
    protected Float laScore;
    @XmlAttribute(name = "n-collapsed")
    protected Integer nCollapsed;
    @XmlAttribute(name = "total-collapsed")
    protected Integer totalCollapsed;

    /**
     * Gets the value of the r property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the r property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getR().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link R }
     * 
     * 
     */
    public List<R> getR() {
        if (r == null) {
            r = new ArrayList<R>();
        }
        return this.r;
    }

    /**
     * Gets the value of the doc property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getDoc() {
        return doc;
    }

    /**
     * Sets the value of the doc property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setDoc(Integer value) {
        this.doc = value;
    }

    /**
     * Gets the value of the score property.
     * 
     * @return
     *     possible object is
     *     {@link Float }
     *     
     */
    public Float getScore() {
        return score;
    }

    /**
     * Sets the value of the score property.
     * 
     * @param value
     *     allowed object is
     *     {@link Float }
     *     
     */
    public void setScore(Float value) {
        this.score = value;
    }

    /**
     * Gets the value of the baseScore property.
     * 
     * @return
     *     possible object is
     *     {@link Float }
     *     
     */
    public Float getBaseScore() {
        return baseScore;
    }

    /**
     * Sets the value of the baseScore property.
     * 
     * @param value
     *     allowed object is
     *     {@link Float }
     *     
     */
    public void setBaseScore(Float value) {
        this.baseScore = value;
    }

    /**
     * Gets the value of the laScore property.
     * 
     * @return
     *     possible object is
     *     {@link Float }
     *     
     */
    public Float getLaScore() {
        return laScore;
    }

    /**
     * Sets the value of the laScore property.
     * 
     * @param value
     *     allowed object is
     *     {@link Float }
     *     
     */
    public void setLaScore(Float value) {
        this.laScore = value;
    }

    /**
     * Gets the value of the nCollapsed property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNCollapsed() {
        return nCollapsed;
    }

    /**
     * Sets the value of the nCollapsed property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNCollapsed(Integer value) {
        this.nCollapsed = value;
    }

    /**
     * Gets the value of the totalCollapsed property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getTotalCollapsed() {
        return totalCollapsed;
    }

    /**
     * Sets the value of the totalCollapsed property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setTotalCollapsed(Integer value) {
        this.totalCollapsed = value;
    }

}
