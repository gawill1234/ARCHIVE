
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.XmlValue;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType>
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;choice maxOccurs="unbounded">
 *         &lt;element name="when-var" maxOccurs="unbounded">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;attGroup ref="{urn:/velocity/objects}if-var"/>
 *                 &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="when" maxOccurs="unbounded">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *                 &lt;attribute name="test" type="{http://www.w3.org/2001/XMLSchema}string" />
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="otherwise" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *       &lt;/choice>
 *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "whenVarOrWhenOrOtherwise"
})
@XmlRootElement(name = "choose")
public class Choose {

    @XmlElements({
        @XmlElement(name = "otherwise", type = Choose.Otherwise.class),
        @XmlElement(name = "when", type = Choose.When.class),
        @XmlElement(name = "when-var", type = Choose.WhenVar.class)
    })
    protected List<Object> whenVarOrWhenOrOtherwise;
    @XmlAttribute
    protected java.lang.Boolean async;
    @XmlAttribute(name = "elt-id")
    protected Integer eltId;
    @XmlAttribute(name = "max-elt-id")
    protected Integer maxEltId;
    @XmlAttribute(name = "execute-acl")
    protected String executeAcl;
    @XmlAttribute
    protected String process;

    /**
     * Gets the value of the whenVarOrWhenOrOtherwise property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the whenVarOrWhenOrOtherwise property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getWhenVarOrWhenOrOtherwise().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Choose.Otherwise }
     * {@link Choose.When }
     * {@link Choose.WhenVar }
     * 
     * 
     */
    public List<Object> getWhenVarOrWhenOrOtherwise() {
        if (whenVarOrWhenOrOtherwise == null) {
            whenVarOrWhenOrOtherwise = new ArrayList<Object>();
        }
        return this.whenVarOrWhenOrOtherwise;
    }

    /**
     * Gets the value of the async property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public boolean isAsync() {
        if (async == null) {
            return true;
        } else {
            return async;
        }
    }

    /**
     * Sets the value of the async property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setAsync(java.lang.Boolean value) {
        this.async = value;
    }

    /**
     * Gets the value of the eltId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getEltId() {
        return eltId;
    }

    /**
     * Sets the value of the eltId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setEltId(Integer value) {
        this.eltId = value;
    }

    /**
     * Gets the value of the maxEltId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaxEltId() {
        return maxEltId;
    }

    /**
     * Sets the value of the maxEltId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxEltId(Integer value) {
        this.maxEltId = value;
    }

    /**
     * Gets the value of the executeAcl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getExecuteAcl() {
        return executeAcl;
    }

    /**
     * Sets the value of the executeAcl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setExecuteAcl(String value) {
        this.executeAcl = value;
    }

    /**
     * Gets the value of the process property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getProcess() {
        return process;
    }

    /**
     * Sets the value of the process property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setProcess(String value) {
        this.process = value;
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
     *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "content"
    })
    public static class Otherwise {

        @XmlValue
        protected String content;
        @XmlAttribute
        protected java.lang.Boolean async;
        @XmlAttribute(name = "elt-id")
        protected Integer eltId;
        @XmlAttribute(name = "max-elt-id")
        protected Integer maxEltId;
        @XmlAttribute(name = "execute-acl")
        protected String executeAcl;
        @XmlAttribute
        protected String process;

        /**
         * Gets the value of the content property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getContent() {
            return content;
        }

        /**
         * Sets the value of the content property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setContent(String value) {
            this.content = value;
        }

        /**
         * Gets the value of the async property.
         * 
         * @return
         *     possible object is
         *     {@link java.lang.Boolean }
         *     
         */
        public boolean isAsync() {
            if (async == null) {
                return true;
            } else {
                return async;
            }
        }

        /**
         * Sets the value of the async property.
         * 
         * @param value
         *     allowed object is
         *     {@link java.lang.Boolean }
         *     
         */
        public void setAsync(java.lang.Boolean value) {
            this.async = value;
        }

        /**
         * Gets the value of the eltId property.
         * 
         * @return
         *     possible object is
         *     {@link Integer }
         *     
         */
        public Integer getEltId() {
            return eltId;
        }

        /**
         * Sets the value of the eltId property.
         * 
         * @param value
         *     allowed object is
         *     {@link Integer }
         *     
         */
        public void setEltId(Integer value) {
            this.eltId = value;
        }

        /**
         * Gets the value of the maxEltId property.
         * 
         * @return
         *     possible object is
         *     {@link Integer }
         *     
         */
        public Integer getMaxEltId() {
            return maxEltId;
        }

        /**
         * Sets the value of the maxEltId property.
         * 
         * @param value
         *     allowed object is
         *     {@link Integer }
         *     
         */
        public void setMaxEltId(Integer value) {
            this.maxEltId = value;
        }

        /**
         * Gets the value of the executeAcl property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getExecuteAcl() {
            return executeAcl;
        }

        /**
         * Sets the value of the executeAcl property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setExecuteAcl(String value) {
            this.executeAcl = value;
        }

        /**
         * Gets the value of the process property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getProcess() {
            return process;
        }

        /**
         * Sets the value of the process property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setProcess(String value) {
            this.process = value;
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
     *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
     *       &lt;attribute name="test" type="{http://www.w3.org/2001/XMLSchema}string" />
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "content"
    })
    public static class When {

        @XmlValue
        protected String content;
        @XmlAttribute
        protected String test;
        @XmlAttribute
        protected java.lang.Boolean async;
        @XmlAttribute(name = "elt-id")
        protected Integer eltId;
        @XmlAttribute(name = "max-elt-id")
        protected Integer maxEltId;
        @XmlAttribute(name = "execute-acl")
        protected String executeAcl;
        @XmlAttribute
        protected String process;

        /**
         * Gets the value of the content property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getContent() {
            return content;
        }

        /**
         * Sets the value of the content property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setContent(String value) {
            this.content = value;
        }

        /**
         * Gets the value of the test property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getTest() {
            return test;
        }

        /**
         * Sets the value of the test property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setTest(String value) {
            this.test = value;
        }

        /**
         * Gets the value of the async property.
         * 
         * @return
         *     possible object is
         *     {@link java.lang.Boolean }
         *     
         */
        public boolean isAsync() {
            if (async == null) {
                return true;
            } else {
                return async;
            }
        }

        /**
         * Sets the value of the async property.
         * 
         * @param value
         *     allowed object is
         *     {@link java.lang.Boolean }
         *     
         */
        public void setAsync(java.lang.Boolean value) {
            this.async = value;
        }

        /**
         * Gets the value of the eltId property.
         * 
         * @return
         *     possible object is
         *     {@link Integer }
         *     
         */
        public Integer getEltId() {
            return eltId;
        }

        /**
         * Sets the value of the eltId property.
         * 
         * @param value
         *     allowed object is
         *     {@link Integer }
         *     
         */
        public void setEltId(Integer value) {
            this.eltId = value;
        }

        /**
         * Gets the value of the maxEltId property.
         * 
         * @return
         *     possible object is
         *     {@link Integer }
         *     
         */
        public Integer getMaxEltId() {
            return maxEltId;
        }

        /**
         * Sets the value of the maxEltId property.
         * 
         * @param value
         *     allowed object is
         *     {@link Integer }
         *     
         */
        public void setMaxEltId(Integer value) {
            this.maxEltId = value;
        }

        /**
         * Gets the value of the executeAcl property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getExecuteAcl() {
            return executeAcl;
        }

        /**
         * Sets the value of the executeAcl property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setExecuteAcl(String value) {
            this.executeAcl = value;
        }

        /**
         * Gets the value of the process property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getProcess() {
            return process;
        }

        /**
         * Sets the value of the process property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setProcess(String value) {
            this.process = value;
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
     *       &lt;attGroup ref="{urn:/velocity/objects}if-var"/>
     *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "", propOrder = {
        "content"
    })
    public static class WhenVar {

        @XmlValue
        protected String content;
        @XmlAttribute(name = "match-type")
        protected MatchType matchType;
        @XmlAttribute
        protected String match;
        @XmlAttribute(name = "not-match")
        protected String notMatch;
        @XmlAttribute
        @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
        @XmlSchemaType(name = "NMTOKEN")
        protected String name;
        @XmlAttribute
        protected String realm;
        @XmlAttribute(name = "multi-sep")
        protected String multiSep;
        @XmlAttribute
        protected String encoding;
        @XmlAttribute
        protected java.lang.Boolean async;
        @XmlAttribute(name = "elt-id")
        protected Integer eltId;
        @XmlAttribute(name = "max-elt-id")
        protected Integer maxEltId;
        @XmlAttribute(name = "execute-acl")
        protected String executeAcl;
        @XmlAttribute
        protected String process;

        /**
         * Gets the value of the content property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getContent() {
            return content;
        }

        /**
         * Sets the value of the content property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setContent(String value) {
            this.content = value;
        }

        /**
         * Gets the value of the matchType property.
         * 
         * @return
         *     possible object is
         *     {@link MatchType }
         *     
         */
        public MatchType getMatchType() {
            if (matchType == null) {
                return MatchType.WC_SET;
            } else {
                return matchType;
            }
        }

        /**
         * Sets the value of the matchType property.
         * 
         * @param value
         *     allowed object is
         *     {@link MatchType }
         *     
         */
        public void setMatchType(MatchType value) {
            this.matchType = value;
        }

        /**
         * Gets the value of the match property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getMatch() {
            if (match == null) {
                return "?*";
            } else {
                return match;
            }
        }

        /**
         * Sets the value of the match property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setMatch(String value) {
            this.match = value;
        }

        /**
         * Gets the value of the notMatch property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getNotMatch() {
            return notMatch;
        }

        /**
         * Sets the value of the notMatch property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setNotMatch(String value) {
            this.notMatch = value;
        }

        /**
         * Gets the value of the name property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getName() {
            return name;
        }

        /**
         * Sets the value of the name property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setName(String value) {
            this.name = value;
        }

        /**
         * Gets the value of the realm property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getRealm() {
            if (realm == null) {
                return "var";
            } else {
                return realm;
            }
        }

        /**
         * Sets the value of the realm property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setRealm(String value) {
            this.realm = value;
        }

        /**
         * Gets the value of the multiSep property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getMultiSep() {
            return multiSep;
        }

        /**
         * Sets the value of the multiSep property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setMultiSep(String value) {
            this.multiSep = value;
        }

        /**
         * Gets the value of the encoding property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getEncoding() {
            return encoding;
        }

        /**
         * Sets the value of the encoding property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setEncoding(String value) {
            this.encoding = value;
        }

        /**
         * Gets the value of the async property.
         * 
         * @return
         *     possible object is
         *     {@link java.lang.Boolean }
         *     
         */
        public boolean isAsync() {
            if (async == null) {
                return true;
            } else {
                return async;
            }
        }

        /**
         * Sets the value of the async property.
         * 
         * @param value
         *     allowed object is
         *     {@link java.lang.Boolean }
         *     
         */
        public void setAsync(java.lang.Boolean value) {
            this.async = value;
        }

        /**
         * Gets the value of the eltId property.
         * 
         * @return
         *     possible object is
         *     {@link Integer }
         *     
         */
        public Integer getEltId() {
            return eltId;
        }

        /**
         * Sets the value of the eltId property.
         * 
         * @param value
         *     allowed object is
         *     {@link Integer }
         *     
         */
        public void setEltId(Integer value) {
            this.eltId = value;
        }

        /**
         * Gets the value of the maxEltId property.
         * 
         * @return
         *     possible object is
         *     {@link Integer }
         *     
         */
        public Integer getMaxEltId() {
            return maxEltId;
        }

        /**
         * Sets the value of the maxEltId property.
         * 
         * @param value
         *     allowed object is
         *     {@link Integer }
         *     
         */
        public void setMaxEltId(Integer value) {
            this.maxEltId = value;
        }

        /**
         * Gets the value of the executeAcl property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getExecuteAcl() {
            return executeAcl;
        }

        /**
         * Sets the value of the executeAcl property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setExecuteAcl(String value) {
            this.executeAcl = value;
        }

        /**
         * Gets the value of the process property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getProcess() {
            return process;
        }

        /**
         * Sets the value of the process property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setProcess(String value) {
            this.process = value;
        }

    }

}
