
package velocity.objects;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for fast-index-type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="fast-index-type">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *     &lt;enumeration value="number"/>
 *     &lt;enumeration value="double"/>
 *     &lt;enumeration value="float"/>
 *     &lt;enumeration value="int"/>
 *     &lt;enumeration value="date"/>
 *     &lt;enumeration value="set"/>
 *     &lt;enumeration value="checked-number"/>
 *     &lt;enumeration value="checked-double"/>
 *     &lt;enumeration value="checked-float"/>
 *     &lt;enumeration value="checked-int"/>
 *     &lt;enumeration value="checked-date"/>
 *     &lt;enumeration value="checked-set"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "fast-index-type")
@XmlEnum
public enum FastIndexType {

    @XmlEnumValue("number")
    NUMBER("number"),
    @XmlEnumValue("double")
    DOUBLE("double"),
    @XmlEnumValue("float")
    FLOAT("float"),
    @XmlEnumValue("int")
    INT("int"),
    @XmlEnumValue("date")
    DATE("date"),
    @XmlEnumValue("set")
    SET("set"),
    @XmlEnumValue("checked-number")
    CHECKED_NUMBER("checked-number"),
    @XmlEnumValue("checked-double")
    CHECKED_DOUBLE("checked-double"),
    @XmlEnumValue("checked-float")
    CHECKED_FLOAT("checked-float"),
    @XmlEnumValue("checked-int")
    CHECKED_INT("checked-int"),
    @XmlEnumValue("checked-date")
    CHECKED_DATE("checked-date"),
    @XmlEnumValue("checked-set")
    CHECKED_SET("checked-set");
    private final String value;

    FastIndexType(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static FastIndexType fromValue(String v) {
        for (FastIndexType c: FastIndexType.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}
