
package velocity.objects;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for default-allow.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="default-allow">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *     &lt;enumeration value="allow"/>
 *     &lt;enumeration value="disallow"/>
 *     &lt;enumeration value="log-disallow"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "default-allow")
@XmlEnum
public enum DefaultAllow {

    @XmlEnumValue("allow")
    ALLOW("allow"),
    @XmlEnumValue("disallow")
    DISALLOW("disallow"),
    @XmlEnumValue("log-disallow")
    LOG_DISALLOW("log-disallow");
    private final String value;

    DefaultAllow(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static DefaultAllow fromValue(String v) {
        for (DefaultAllow c: DefaultAllow.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}
