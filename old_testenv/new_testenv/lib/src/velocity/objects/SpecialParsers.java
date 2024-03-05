
package velocity.objects;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for special-parsers.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="special-parsers">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *     &lt;enumeration value="#vxml#"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "special-parsers")
@XmlEnum
public enum SpecialParsers {


    /**
     * 
     *           Do not perform any parsing, input the string directly into the
     *           Vivisimo object. The string must therefore conform to the
     * 	      Data Explorer XML format.
     *           
     * 
     */
    @XmlEnumValue("#vxml#")
    VXML("#vxml#");
    private final String value;

    SpecialParsers(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static SpecialParsers fromValue(String v) {
        for (SpecialParsers c: SpecialParsers.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}
