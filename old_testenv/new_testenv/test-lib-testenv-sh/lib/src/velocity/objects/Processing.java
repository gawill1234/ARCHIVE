
package velocity.objects;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for processing.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="processing">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *     &lt;enumeration value="strict"/>
 *     &lt;enumeration value="optional"/>
 *     &lt;enumeration value="special"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "processing")
@XmlEnum
public enum Processing {


    /**
     * 
     *             If an output 
     * <pre>
     * &lt;?xml version="1.0" encoding="UTF-8"?&gt;&lt;vdoc:a xmlns:vdoc="http://vivisimo.com/documentation" xmlns="urn:/velocity/objects" xmlns:axl="http://vivisimo.com/axl" xmlns:sectypes="urn:/velocity/soap" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/" xmlns:tns="urn:/velocity" xmlns:types="urn:/velocity/types" xmlns:vs="http://vivisimo.com/schema-extension" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:xs="http://www.w3.org/2001/XMLSchema" ref="schema.x.element.form"&gt;form&lt;/vdoc:a&gt;
     * </pre>
     *  does
     *             not support this field, the conversion will not be done.
     *           
     * 
     */
    @XmlEnumValue("strict")
    STRICT("strict"),

    /**
     * 
     *             It is not required that output
     *             
     * <pre>
     * &lt;?xml version="1.0" encoding="UTF-8"?&gt;&lt;vdoc:a xmlns:vdoc="http://vivisimo.com/documentation" xmlns="urn:/velocity/objects" xmlns:axl="http://vivisimo.com/axl" xmlns:sectypes="urn:/velocity/soap" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/" xmlns:tns="urn:/velocity" xmlns:types="urn:/velocity/types" xmlns:vs="http://vivisimo.com/schema-extension" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:xs="http://www.w3.org/2001/XMLSchema" ref="schema.x.element.form"&gt;form&lt;/vdoc:a&gt;
     * </pre>
     *  support this field
     *             for a conversion to be done.
     * 
     */
    @XmlEnumValue("optional")
    OPTIONAL("optional"),
    @XmlEnumValue("special")
    SPECIAL("special");
    private final String value;

    Processing(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static Processing fromValue(String v) {
        for (Processing c: Processing.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}
