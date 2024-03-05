
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
 *       &lt;choice>
 *         &lt;group ref="{urn:/velocity/objects}user-section"/>
 *       &lt;/choice>
 *       &lt;attribute name="name" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="permissions" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
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
@XmlRootElement(name = "user")
public class User {

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
    protected String permissions;

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
     * Gets the value of the permissions property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPermissions() {
        return permissions;
    }

    /**
     * Sets the value of the permissions property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPermissions(String value) {
        this.permissions = value;
    }

}
