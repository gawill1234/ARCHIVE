
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
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
 *       &lt;sequence>
 *         &lt;group ref="{urn:/velocity/objects}user-section"/>
 *       &lt;/sequence>
 *       &lt;attGroup ref="{urn:/velocity/objects}default"/>
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="base" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" default="default" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "userIdentity",
    "userPermissions",
    "userOptions",
    "userAdminOptions",
    "userGlobals",
    "userAdminHistory",
    "userSourceVariables",
    "userQueryHistory"
})
@XmlRootElement(name = "user-create")
public class UserCreate {

    @XmlElement(name = "user-identity")
    protected UserIdentity userIdentity;
    @XmlElement(name = "user-permissions")
    protected UserPermissions userPermissions;
    @XmlElement(name = "user-options")
    protected UserOptions userOptions;
    @XmlElement(name = "user-admin-options")
    protected UserAdminOptions userAdminOptions;
    @XmlElement(name = "user-globals")
    protected UserGlobals userGlobals;
    @XmlElement(name = "user-admin-history")
    protected UserAdminHistory userAdminHistory;
    @XmlElement(name = "user-source-variables")
    protected UserSourceVariables userSourceVariables;
    @XmlElement(name = "user-query-history")
    protected UserQueryHistory userQueryHistory;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String name;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String base;
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
     * Gets the value of the userIdentity property.
     * 
     * @return
     *     possible object is
     *     {@link UserIdentity }
     *     
     */
    public UserIdentity getUserIdentity() {
        return userIdentity;
    }

    /**
     * Sets the value of the userIdentity property.
     * 
     * @param value
     *     allowed object is
     *     {@link UserIdentity }
     *     
     */
    public void setUserIdentity(UserIdentity value) {
        this.userIdentity = value;
    }

    /**
     * Gets the value of the userPermissions property.
     * 
     * @return
     *     possible object is
     *     {@link UserPermissions }
     *     
     */
    public UserPermissions getUserPermissions() {
        return userPermissions;
    }

    /**
     * Sets the value of the userPermissions property.
     * 
     * @param value
     *     allowed object is
     *     {@link UserPermissions }
     *     
     */
    public void setUserPermissions(UserPermissions value) {
        this.userPermissions = value;
    }

    /**
     * Gets the value of the userOptions property.
     * 
     * @return
     *     possible object is
     *     {@link UserOptions }
     *     
     */
    public UserOptions getUserOptions() {
        return userOptions;
    }

    /**
     * Sets the value of the userOptions property.
     * 
     * @param value
     *     allowed object is
     *     {@link UserOptions }
     *     
     */
    public void setUserOptions(UserOptions value) {
        this.userOptions = value;
    }

    /**
     * Gets the value of the userAdminOptions property.
     * 
     * @return
     *     possible object is
     *     {@link UserAdminOptions }
     *     
     */
    public UserAdminOptions getUserAdminOptions() {
        return userAdminOptions;
    }

    /**
     * Sets the value of the userAdminOptions property.
     * 
     * @param value
     *     allowed object is
     *     {@link UserAdminOptions }
     *     
     */
    public void setUserAdminOptions(UserAdminOptions value) {
        this.userAdminOptions = value;
    }

    /**
     * Gets the value of the userGlobals property.
     * 
     * @return
     *     possible object is
     *     {@link UserGlobals }
     *     
     */
    public UserGlobals getUserGlobals() {
        return userGlobals;
    }

    /**
     * Sets the value of the userGlobals property.
     * 
     * @param value
     *     allowed object is
     *     {@link UserGlobals }
     *     
     */
    public void setUserGlobals(UserGlobals value) {
        this.userGlobals = value;
    }

    /**
     * Gets the value of the userAdminHistory property.
     * 
     * @return
     *     possible object is
     *     {@link UserAdminHistory }
     *     
     */
    public UserAdminHistory getUserAdminHistory() {
        return userAdminHistory;
    }

    /**
     * Sets the value of the userAdminHistory property.
     * 
     * @param value
     *     allowed object is
     *     {@link UserAdminHistory }
     *     
     */
    public void setUserAdminHistory(UserAdminHistory value) {
        this.userAdminHistory = value;
    }

    /**
     * Gets the value of the userSourceVariables property.
     * 
     * @return
     *     possible object is
     *     {@link UserSourceVariables }
     *     
     */
    public UserSourceVariables getUserSourceVariables() {
        return userSourceVariables;
    }

    /**
     * Sets the value of the userSourceVariables property.
     * 
     * @param value
     *     allowed object is
     *     {@link UserSourceVariables }
     *     
     */
    public void setUserSourceVariables(UserSourceVariables value) {
        this.userSourceVariables = value;
    }

    /**
     * Gets the value of the userQueryHistory property.
     * 
     * @return
     *     possible object is
     *     {@link UserQueryHistory }
     *     
     */
    public UserQueryHistory getUserQueryHistory() {
        return userQueryHistory;
    }

    /**
     * Sets the value of the userQueryHistory property.
     * 
     * @param value
     *     allowed object is
     *     {@link UserQueryHistory }
     *     
     */
    public void setUserQueryHistory(UserQueryHistory value) {
        this.userQueryHistory = value;
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
     * Gets the value of the base property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBase() {
        if (base == null) {
            return "default";
        } else {
            return base;
        }
    }

    /**
     * Sets the value of the base property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBase(String value) {
        this.base = value;
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
