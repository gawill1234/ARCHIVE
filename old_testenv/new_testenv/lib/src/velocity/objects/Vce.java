
package velocity.objects;

import java.util.ArrayList;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
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
 *         &lt;choice maxOccurs="unbounded" minOccurs="0">
 *           &lt;element ref="{urn:/velocity/objects}set-var"/>
 *           &lt;element ref="{urn:/velocity/objects}declare"/>
 *           &lt;element ref="{urn:/velocity/objects}if-var"/>
 *           &lt;element ref="{urn:/velocity/objects}if"/>
 *           &lt;element ref="{urn:/velocity/objects}while"/>
 *           &lt;element ref="{urn:/velocity/objects}for-each"/>
 *           &lt;element ref="{urn:/velocity/objects}choose"/>
 *           &lt;element ref="{urn:/velocity/objects}scope"/>
 *           &lt;element ref="{urn:/velocity/objects}function"/>
 *           &lt;group ref="{urn:/velocity/objects}config"/>
 *           &lt;element ref="{urn:/velocity/objects}form"/>
 *           &lt;element ref="{urn:/velocity/objects}submit"/>
 *           &lt;element ref="{urn:/velocity/objects}query"/>
 *           &lt;element ref="{urn:/velocity/objects}param"/>
 *           &lt;element ref="{urn:/velocity/objects}field"/>
 *           &lt;element ref="{urn:/velocity/objects}operator"/>
 *           &lt;element ref="{urn:/velocity/objects}syntax"/>
 *           &lt;element ref="{urn:/velocity/objects}parser"/>
 *           &lt;element ref="{urn:/velocity/objects}parse"/>
 *           &lt;element ref="{urn:/velocity/objects}process-xsl"/>
 *           &lt;element ref="{urn:/velocity/objects}source"/>
 *           &lt;element ref="{urn:/velocity/objects}add-sources"/>
 *           &lt;element ref="{urn:/velocity/objects}kb"/>
 *           &lt;element ref="{urn:/velocity/objects}options"/>
 *           &lt;element ref="{urn:/velocity/objects}prototype"/>
 *           &lt;element ref="{urn:/velocity/objects}log"/>
 *           &lt;element ref="{urn:/velocity/objects}document"/>
 *           &lt;element ref="{urn:/velocity/objects}binning-full"/>
 *           &lt;element ref="{urn:/velocity/objects}added-source"/>
 *           &lt;element ref="{urn:/velocity/objects}boost"/>
 *           &lt;group ref="{urn:/velocity/objects}user"/>
 *         &lt;/choice>
 *         &lt;choice maxOccurs="2" minOccurs="0">
 *           &lt;element ref="{urn:/velocity/objects}documents"/>
 *           &lt;element ref="{urn:/velocity/objects}tree"/>
 *           &lt;element ref="{urn:/velocity/objects}list"/>
 *         &lt;/choice>
 *       &lt;/sequence>
 *       &lt;attribute name="id" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="input-ids" type="{http://www.w3.org/2001/XMLSchema}NMTOKENS" />
 *       &lt;attribute name="projects" type="{http://www.w3.org/2001/XMLSchema}NMTOKENS" />
 *       &lt;attribute name="merge-count" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="authenticated-user" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN" />
 *       &lt;attribute name="execute-acls" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="version" type="{http://www.w3.org/2001/XMLSchema}string" default="7.x" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "setVarOrDeclareOrIfVar",
    "documentsOrTreeOrList"
})
@XmlRootElement(name = "vce")
public class Vce {

    @XmlElements({
        @XmlElement(name = "user-admin-history", type = UserAdminHistory.class),
        @XmlElement(name = "choose", type = Choose.class),
        @XmlElement(name = "redisplay", type = Redisplay.class),
        @XmlElement(name = "if-var", type = IfVar.class),
        @XmlElement(name = "user-source-variables", type = UserSourceVariables.class),
        @XmlElement(name = "user-create", type = UserCreate.class),
        @XmlElement(name = "evoke", type = Evoke.class),
        @XmlElement(name = "options", type = Options.class),
        @XmlElement(name = "user-permissions", type = UserPermissions.class),
        @XmlElement(name = "load-user", type = LoadUser.class),
        @XmlElement(name = "if", type = If.class),
        @XmlElement(name = "submit", type = Submit.class),
        @XmlElement(name = "field", type = Field.class),
        @XmlElement(name = "declare", type = Declare.class),
        @XmlElement(name = "user-options", type = UserOptions.class),
        @XmlElement(name = "user-authenticate", type = UserAuthenticate.class),
        @XmlElement(name = "user", type = User.class),
        @XmlElement(name = "query", type = Query.class),
        @XmlElement(name = "binning-full", type = BinningFull.class),
        @XmlElement(name = "user-globals", type = UserGlobals.class),
        @XmlElement(name = "syntax", type = Syntax.class),
        @XmlElement(name = "document", type = Document.class),
        @XmlElement(name = "boost", type = Boost.class),
        @XmlElement(name = "operator", type = Operator.class),
        @XmlElement(name = "user-admin-options", type = UserAdminOptions.class),
        @XmlElement(name = "option", type = Option.class),
        @XmlElement(name = "scope", type = Scope.class),
        @XmlElement(name = "user-identity", type = UserIdentity.class),
        @XmlElement(name = "tag", type = Tag.class),
        @XmlElement(name = "set-var", type = SetVar.class),
        @XmlElement(name = "rephrase", type = Rephrase.class),
        @XmlElement(name = "stem", type = Stem.class),
        @XmlElement(name = "for-each", type = ForEach.class),
        @XmlElement(name = "function", type = Function.class),
        @XmlElement(name = "source", type = Source.class),
        @XmlElement(name = "param", type = Param.class),
        @XmlElement(name = "kb", type = Kb.class),
        @XmlElement(name = "user-modify", type = UserModify.class),
        @XmlElement(name = "log", type = Log.class),
        @XmlElement(name = "form", type = Form.class),
        @XmlElement(name = "meta", type = Meta.class),
        @XmlElement(name = "while", type = While.class),
        @XmlElement(name = "parse", type = Parse.class),
        @XmlElement(name = "stopword", type = Stopword.class),
        @XmlElement(name = "user-query-history", type = UserQueryHistory.class),
        @XmlElement(name = "prototype", type = Prototype.class),
        @XmlElement(name = "parser", type = Parser.class),
        @XmlElement(name = "add-sources", type = AddSources.class),
        @XmlElement(name = "process-xsl", type = ProcessXsl.class),
        @XmlElement(name = "added-source", type = AddedSource.class)
    })
    protected java.util.List<Object> setVarOrDeclareOrIfVar;
    @XmlElements({
        @XmlElement(name = "documents", type = Documents.class),
        @XmlElement(name = "tree", type = Tree.class),
        @XmlElement(name = "list", type = velocity.objects.List.class)
    })
    protected java.util.List<Object> documentsOrTreeOrList;
    @XmlAttribute
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String id;
    @XmlAttribute(name = "input-ids")
    @XmlSchemaType(name = "NMTOKENS")
    protected java.util.List<String> inputIds;
    @XmlAttribute
    @XmlSchemaType(name = "NMTOKENS")
    protected java.util.List<String> projects;
    @XmlAttribute(name = "merge-count")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String mergeCount;
    @XmlAttribute(name = "authenticated-user")
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String authenticatedUser;
    @XmlAttribute(name = "execute-acls")
    protected String executeAcls;
    @XmlAttribute
    protected String version;

    /**
     * Gets the value of the setVarOrDeclareOrIfVar property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the setVarOrDeclareOrIfVar property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getSetVarOrDeclareOrIfVar().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link UserAdminHistory }
     * {@link Choose }
     * {@link Redisplay }
     * {@link IfVar }
     * {@link UserSourceVariables }
     * {@link UserCreate }
     * {@link Evoke }
     * {@link Options }
     * {@link UserPermissions }
     * {@link LoadUser }
     * {@link If }
     * {@link Submit }
     * {@link Field }
     * {@link Declare }
     * {@link UserOptions }
     * {@link UserAuthenticate }
     * {@link User }
     * {@link Query }
     * {@link BinningFull }
     * {@link UserGlobals }
     * {@link Syntax }
     * {@link Document }
     * {@link Boost }
     * {@link Operator }
     * {@link UserAdminOptions }
     * {@link Option }
     * {@link Scope }
     * {@link UserIdentity }
     * {@link Tag }
     * {@link SetVar }
     * {@link Rephrase }
     * {@link Stem }
     * {@link ForEach }
     * {@link Function }
     * {@link Source }
     * {@link Param }
     * {@link Kb }
     * {@link UserModify }
     * {@link Log }
     * {@link Form }
     * {@link Meta }
     * {@link While }
     * {@link Parse }
     * {@link Stopword }
     * {@link UserQueryHistory }
     * {@link Prototype }
     * {@link Parser }
     * {@link AddSources }
     * {@link ProcessXsl }
     * {@link AddedSource }
     * 
     * 
     */
    public java.util.List<Object> getSetVarOrDeclareOrIfVar() {
        if (setVarOrDeclareOrIfVar == null) {
            setVarOrDeclareOrIfVar = new ArrayList<Object>();
        }
        return this.setVarOrDeclareOrIfVar;
    }

    /**
     * Gets the value of the documentsOrTreeOrList property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the documentsOrTreeOrList property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getDocumentsOrTreeOrList().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link Documents }
     * {@link Tree }
     * {@link velocity.objects.List }
     * 
     * 
     */
    public java.util.List<Object> getDocumentsOrTreeOrList() {
        if (documentsOrTreeOrList == null) {
            documentsOrTreeOrList = new ArrayList<Object>();
        }
        return this.documentsOrTreeOrList;
    }

    /**
     * Gets the value of the id property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getId() {
        return id;
    }

    /**
     * Sets the value of the id property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setId(String value) {
        this.id = value;
    }

    /**
     * Gets the value of the inputIds property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the inputIds property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getInputIds().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link String }
     * 
     * 
     */
    public java.util.List<String> getInputIds() {
        if (inputIds == null) {
            inputIds = new ArrayList<String>();
        }
        return this.inputIds;
    }

    /**
     * Gets the value of the projects property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the projects property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getProjects().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link String }
     * 
     * 
     */
    public java.util.List<String> getProjects() {
        if (projects == null) {
            projects = new ArrayList<String>();
        }
        return this.projects;
    }

    /**
     * Gets the value of the mergeCount property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMergeCount() {
        return mergeCount;
    }

    /**
     * Sets the value of the mergeCount property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMergeCount(String value) {
        this.mergeCount = value;
    }

    /**
     * Gets the value of the authenticatedUser property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAuthenticatedUser() {
        return authenticatedUser;
    }

    /**
     * Sets the value of the authenticatedUser property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAuthenticatedUser(String value) {
        this.authenticatedUser = value;
    }

    /**
     * Gets the value of the executeAcls property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getExecuteAcls() {
        return executeAcls;
    }

    /**
     * Sets the value of the executeAcls property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setExecuteAcls(String value) {
        this.executeAcls = value;
    }

    /**
     * Gets the value of the version property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVersion() {
        if (version == null) {
            return "7.x";
        } else {
            return version;
        }
    }

    /**
     * Sets the value of the version property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVersion(String value) {
        this.version = value;
    }

}
