
package velocity.objects;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for disable-stats.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="disable-stats">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *     &lt;enumeration value="all"/>
 *     &lt;enumeration value="path"/>
 *     &lt;enumeration value="none"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "disable-stats")
@XmlEnum
public enum DisableStats {

    @XmlEnumValue("all")
    ALL("all"),
    @XmlEnumValue("path")
    PATH("path"),
    @XmlEnumValue("none")
    NONE("none");
    private final String value;

    DisableStats(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static DisableStats fromValue(String v) {
        for (DisableStats c: DisableStats.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}
