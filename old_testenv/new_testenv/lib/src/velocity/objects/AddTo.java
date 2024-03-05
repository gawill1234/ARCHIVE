
package velocity.objects;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for add-to.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="add-to">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *     &lt;enumeration value="document"/>
 *     &lt;enumeration value="scope"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "add-to")
@XmlEnum
public enum AddTo {


    /**
     * 
     *                  The element will be added to the last
     *                  added document if any.
     *                 
     * 
     */
    @XmlEnumValue("document")
    DOCUMENT("document"),

    /**
     * 
     *                  The element will be added to the current scope.
     *                 
     * 
     */
    @XmlEnumValue("scope")
    SCOPE("scope");
    private final String value;

    AddTo(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static AddTo fromValue(String v) {
        for (AddTo c: AddTo.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}
