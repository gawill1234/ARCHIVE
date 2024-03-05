
package velocity.objects;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for method.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="method">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *     &lt;enumeration value="GET"/>
 *     &lt;enumeration value="POST"/>
 *     &lt;enumeration value="HEAD"/>
 *     &lt;enumeration value="GET-POST"/>
 *     &lt;enumeration value="POST-XML"/>
 *     &lt;enumeration value="POST-SOAP"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "method")
@XmlEnum
public enum Method {

    GET("GET"),
    POST("POST"),
    HEAD("HEAD"),
    @XmlEnumValue("GET-POST")
    GET_POST("GET-POST"),
    @XmlEnumValue("POST-XML")
    POST_XML("POST-XML"),
    @XmlEnumValue("POST-SOAP")
    POST_SOAP("POST-SOAP");
    private final String value;

    Method(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static Method fromValue(String v) {
        for (Method c: Method.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}
