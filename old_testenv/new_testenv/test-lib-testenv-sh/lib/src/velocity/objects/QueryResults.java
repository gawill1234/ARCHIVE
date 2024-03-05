
package velocity.objects;

import java.util.ArrayList;
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
 *         &lt;element ref="{urn:/velocity/objects}binning" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}binning-full" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}query" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}spelling-correction" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}added-source" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}boost" maxOccurs="unbounded" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}list" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}navigation" minOccurs="0"/>
 *         &lt;element ref="{urn:/velocity/objects}tree" minOccurs="0"/>
 *       &lt;/sequence>
 *       &lt;attribute name="file" type="{http://www.w3.org/2001/XMLSchema}string" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "binning",
    "binningFull",
    "query",
    "spellingCorrection",
    "addedSource",
    "boost",
    "list",
    "navigation",
    "tree"
})
@XmlRootElement(name = "query-results")
public class QueryResults {

    protected Binning binning;
    @XmlElement(name = "binning-full")
    protected BinningFull binningFull;
    protected java.util.List<Query> query;
    @XmlElement(name = "spelling-correction")
    protected SpellingCorrection spellingCorrection;
    @XmlElement(name = "added-source")
    protected java.util.List<AddedSource> addedSource;
    protected java.util.List<Boost> boost;
    protected velocity.objects.List list;
    protected Navigation navigation;
    protected Tree tree;
    @XmlAttribute
    protected String file;

    /**
     * Gets the value of the binning property.
     * 
     * @return
     *     possible object is
     *     {@link Binning }
     *     
     */
    public Binning getBinning() {
        return binning;
    }

    /**
     * Sets the value of the binning property.
     * 
     * @param value
     *     allowed object is
     *     {@link Binning }
     *     
     */
    public void setBinning(Binning value) {
        this.binning = value;
    }

    /**
     * Gets the value of the binningFull property.
     * 
     * @return
     *     possible object is
     *     {@link BinningFull }
     *     
     */
    public BinningFull getBinningFull() {
        return binningFull;
    }

    /**
     * Sets the value of the binningFull property.
     * 
     * @param value
     *     allowed object is
     *     {@link BinningFull }
     *     
     */
    public void setBinningFull(BinningFull value) {
        this.binningFull = value;
    }

    /**
     * Gets the value of the query property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the query property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getQuery().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Query }
     * 
     * 
     */
    public java.util.List<Query> getQuery() {
        if (query == null) {
            query = new ArrayList<Query>();
        }
        return this.query;
    }

    /**
     * Gets the value of the spellingCorrection property.
     * 
     * @return
     *     possible object is
     *     {@link SpellingCorrection }
     *     
     */
    public SpellingCorrection getSpellingCorrection() {
        return spellingCorrection;
    }

    /**
     * Sets the value of the spellingCorrection property.
     * 
     * @param value
     *     allowed object is
     *     {@link SpellingCorrection }
     *     
     */
    public void setSpellingCorrection(SpellingCorrection value) {
        this.spellingCorrection = value;
    }

    /**
     * Gets the value of the addedSource property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the addedSource property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getAddedSource().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link AddedSource }
     * 
     * 
     */
    public java.util.List<AddedSource> getAddedSource() {
        if (addedSource == null) {
            addedSource = new ArrayList<AddedSource>();
        }
        return this.addedSource;
    }

    /**
     * Gets the value of the boost property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the boost property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getBoost().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Boost }
     * 
     * 
     */
    public java.util.List<Boost> getBoost() {
        if (boost == null) {
            boost = new ArrayList<Boost>();
        }
        return this.boost;
    }

    /**
     * Gets the value of the list property.
     * 
     * @return
     *     possible object is
     *     {@link velocity.objects.List }
     *     
     */
    public velocity.objects.List getList() {
        return list;
    }

    /**
     * Sets the value of the list property.
     * 
     * @param value
     *     allowed object is
     *     {@link velocity.objects.List }
     *     
     */
    public void setList(velocity.objects.List value) {
        this.list = value;
    }

    /**
     * Gets the value of the navigation property.
     * 
     * @return
     *     possible object is
     *     {@link Navigation }
     *     
     */
    public Navigation getNavigation() {
        return navigation;
    }

    /**
     * Sets the value of the navigation property.
     * 
     * @param value
     *     allowed object is
     *     {@link Navigation }
     *     
     */
    public void setNavigation(Navigation value) {
        this.navigation = value;
    }

    /**
     * Gets the value of the tree property.
     * 
     * @return
     *     possible object is
     *     {@link Tree }
     *     
     */
    public Tree getTree() {
        return tree;
    }

    /**
     * Sets the value of the tree property.
     * 
     * @param value
     *     allowed object is
     *     {@link Tree }
     *     
     */
    public void setTree(Tree value) {
        this.tree = value;
    }

    /**
     * Gets the value of the file property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFile() {
        return file;
    }

    /**
     * Sets the value of the file property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFile(String value) {
        this.file = value;
    }

}
