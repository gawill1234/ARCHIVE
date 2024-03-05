
package velocity.objects;

import javax.xml.bind.annotation.XmlEnum;
import javax.xml.bind.annotation.XmlEnumValue;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for match-type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * <p>
 * <pre>
 * &lt;simpleType name="match-type">
 *   &lt;restriction base="{http://www.w3.org/2001/XMLSchema}NMTOKEN">
 *     &lt;enumeration value="wc"/>
 *     &lt;enumeration value="wc-set"/>
 *     &lt;enumeration value="regex"/>
 *     &lt;enumeration value="cregex"/>
 *     &lt;enumeration value="case-insensitive-regex"/>
 *     &lt;enumeration value="perl-regex"/>
 *     &lt;enumeration value="case-insensitive-perl-regex"/>
 *   &lt;/restriction>
 * &lt;/simpleType>
 * </pre>
 * 
 */
@XmlType(name = "match-type")
@XmlEnum
public enum MatchType {


    /**
     * 
     * 	    Wildcard: '?' specifies any character, '*' specifies any
     * 	    sequence of characters.
     * 	  
     * 
     */
    @XmlEnumValue("wc")
    WC("wc"),

    /**
     * 
     * 	    Wildcard set, i.e., wildcard augmented with the '|' symbol
     * 	    for logical OR.
     * 	  
     * 
     */
    @XmlEnumValue("wc-set")
    WC_SET("wc-set"),

    /**
     * 
     * 	    Posix regular expression (identical to the ones used
     * 	    in the regex parsers).
     * 	  
     * 
     */
    @XmlEnumValue("regex")
    REGEX("regex"),

    /**
     * 
     * 	    Case insensitive Posix regular expression.
     * 	  
     * 
     */
    @XmlEnumValue("cregex")
    CREGEX("cregex"),

    /**
     * 
     * 	    Case insensitive Posix regular expression.
     * 	  
     * 
     */
    @XmlEnumValue("case-insensitive-regex")
    CASE_INSENSITIVE_REGEX("case-insensitive-regex"),

    /**
     * 
     * 	    Perl-style regular expression.
     * 	  
     * 
     */
    @XmlEnumValue("perl-regex")
    PERL_REGEX("perl-regex"),

    /**
     * 
     * 	    Case insensitive Perl-style regular expression.
     * 	  
     * 
     */
    @XmlEnumValue("case-insensitive-perl-regex")
    CASE_INSENSITIVE_PERL_REGEX("case-insensitive-perl-regex");
    private final String value;

    MatchType(String v) {
        value = v;
    }

    public String value() {
        return value;
    }

    public static MatchType fromValue(String v) {
        for (MatchType c: MatchType.values()) {
            if (c.value.equals(v)) {
                return c;
            }
        }
        throw new IllegalArgumentException(v);
    }

}
