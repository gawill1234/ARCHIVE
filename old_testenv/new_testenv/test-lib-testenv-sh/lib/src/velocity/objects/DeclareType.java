
package velocity.objects;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for declare-type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="declare-type">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *     &lt;enumeration value="int"/>
 *     &lt;enumeration value="boolean"/>
 *     &lt;enumeration value="number"/>
 *     &lt;enumeration value="password"/>
 *     &lt;enumeration value="string"/>
 *     &lt;enumeration value="nodeset"/>
 *     &lt;enumeration value="enum"/>
 *     &lt;enumeration value="flag"/>
 *     &lt;enumeration value="positive-int"/>
 *     &lt;enumeration value="separated-set"/>
 *     &lt;enumeration value="string-area"/>
 *     &lt;enumeration value="url"/>
 *     &lt;enumeration value="xml-escaped"/>
 *     &lt;enumeration value="xpath"/>
 *     &lt;enumeration value="date"/>
 *     &lt;enumeration value="email"/>
 *     &lt;enumeration value="image"/>
 *     &lt;enumeration value="nmtoken"/>
 *     &lt;enumeration value="separated-enum-set"/>
 *     &lt;enumeration value="user-set"/>
 *     &lt;enumeration value="re"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "declare-type")
@XmlEnum
public enum DeclareType {

    @XmlEnumValue("int")
    INT("int"),

    /**
     * 
     * 	    'true' or 'false'
     * 	  
     * 
     */
    @XmlEnumValue("boolean")
    BOOLEAN("boolean"),
    @XmlEnumValue("number")
    NUMBER("number"),
    @XmlEnumValue("password")
    PASSWORD("password"),
    @XmlEnumValue("string")
    STRING("string"),

    /**
     * 
     * 	    XML nodeset. The value can be passed as "sub-node".
     * 	  
     * 
     */
    @XmlEnumValue("nodeset")
    NODESET("nodeset"),
    @XmlEnumValue("enum")
    ENUM("enum"),
    @XmlEnumValue("flag")
    FLAG("flag"),
    @XmlEnumValue("positive-int")
    POSITIVE_INT("positive-int"),
    @XmlEnumValue("separated-set")
    SEPARATED_SET("separated-set"),
    @XmlEnumValue("string-area")
    STRING_AREA("string-area"),
    @XmlEnumValue("url")
    URL("url"),
    @XmlEnumValue("xml-escaped")
    XML_ESCAPED("xml-escaped"),
    @XmlEnumValue("xpath")
    XPATH("xpath"),
    @XmlEnumValue("date")
    DATE("date"),
    @XmlEnumValue("email")
    EMAIL("email"),
    @XmlEnumValue("image")
    IMAGE("image"),
    @XmlEnumValue("nmtoken")
    NMTOKEN("nmtoken"),
    @XmlEnumValue("separated-enum-set")
    SEPARATED_ENUM_SET("separated-enum-set"),
    @XmlEnumValue("user-set")
    USER_SET("user-set"),
    @XmlEnumValue("re")
    RE("re");
    private final String value;

    DeclareType(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static DeclareType fromValue(String v) {
        for (DeclareType c: DeclareType.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}
