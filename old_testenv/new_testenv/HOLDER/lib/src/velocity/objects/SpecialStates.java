
package velocity.objects;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for special-states.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="special-states">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *     &lt;enumeration value="#parent"/>
 *     &lt;enumeration value="#end"/>
 *     &lt;enumeration value="#initial"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "special-states")
@XmlEnum
public enum SpecialStates {


    /**
     * 
     *           The parent state, i.e., the previous state in which
     *           the parser was before entering into the current state.
     *           
     * 
     */
    @XmlEnumValue("#parent")
    PARENT("#parent"),

    /**
     * 
     *           End state, i.e., terminate the parsing process.
     *           
     * 
     */
    @XmlEnumValue("#end")
    END("#end"),

    /**
     * 
     *           The initial state (where the parser started)
     *           
     * 
     */
    @XmlEnumValue("#initial")
    INITIAL("#initial");
    private final String value;

    SpecialStates(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static SpecialStates fromValue(String v) {
        for (SpecialStates c: SpecialStates.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}
