
package velocity.objects;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElements;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType>
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;choice maxOccurs="unbounded" minOccurs="0">
 *         &lt;element ref="{urn:/velocity/objects}setting"/>
 *         &lt;element ref="{urn:/velocity/objects}declare-setting"/>
 *       &lt;/choice>
 *       &lt;attribute name="keep-declares" type="{http://www.w3.org/2001/XMLSchema}string" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "settingOrDeclareSetting"
})
@XmlRootElement(name = "settings")
public class Settings {

    @XmlElements({
        @XmlElement(name = "declare-setting", type = DeclareSetting.class),
        @XmlElement(name = "setting", type = Setting.class)
    })
    protected List<Object> settingOrDeclareSetting;
    @XmlAttribute(name = "keep-declares")
    protected String keepDeclares;

    /**
     * Gets the value of the settingOrDeclareSetting property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the settingOrDeclareSetting property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getSettingOrDeclareSetting().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link DeclareSetting }
     * {@link Setting }
     * 
     * 
     */
    public List<Object> getSettingOrDeclareSetting() {
        if (settingOrDeclareSetting == null) {
            settingOrDeclareSetting = new ArrayList<Object>();
        }
        return this.settingOrDeclareSetting;
    }

    /**
     * Gets the value of the keepDeclares property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getKeepDeclares() {
        return keepDeclares;
    }

    /**
     * Sets the value of the keepDeclares property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setKeepDeclares(String value) {
        this.keepDeclares = value;
    }

}
