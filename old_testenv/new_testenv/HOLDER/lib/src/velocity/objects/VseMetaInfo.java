
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
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
 *       &lt;sequence>
 *         &lt;element name="cache-dir" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="desc" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="enable-remote" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="index-dir" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="live-crawl-dir" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="live-index-file" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="live-log-dir" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="maintainers" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="refresh" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="staging-crawl-dir" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="staging-index-file" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="staging-log-dir" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "cacheDir",
    "desc",
    "enableRemote",
    "indexDir",
    "liveCrawlDir",
    "liveIndexFile",
    "liveLogDir",
    "maintainers",
    "refresh",
    "stagingCrawlDir",
    "stagingIndexFile",
    "stagingLogDir"
})
@XmlRootElement(name = "vse-meta-info")
public class VseMetaInfo {

    @XmlElement(name = "cache-dir")
    protected String cacheDir;
    protected String desc;
    @XmlElement(name = "enable-remote")
    protected String enableRemote;
    @XmlElement(name = "index-dir")
    protected String indexDir;
    @XmlElement(name = "live-crawl-dir")
    protected String liveCrawlDir;
    @XmlElement(name = "live-index-file")
    protected String liveIndexFile;
    @XmlElement(name = "live-log-dir")
    protected String liveLogDir;
    protected String maintainers;
    protected String refresh;
    @XmlElement(name = "staging-crawl-dir")
    protected String stagingCrawlDir;
    @XmlElement(name = "staging-index-file")
    protected String stagingIndexFile;
    @XmlElement(name = "staging-log-dir")
    protected String stagingLogDir;

    /**
     * Gets the value of the cacheDir property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCacheDir() {
        return cacheDir;
    }

    /**
     * Sets the value of the cacheDir property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCacheDir(String value) {
        this.cacheDir = value;
    }

    /**
     * Gets the value of the desc property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDesc() {
        return desc;
    }

    /**
     * Sets the value of the desc property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDesc(String value) {
        this.desc = value;
    }

    /**
     * Gets the value of the enableRemote property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEnableRemote() {
        return enableRemote;
    }

    /**
     * Sets the value of the enableRemote property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEnableRemote(String value) {
        this.enableRemote = value;
    }

    /**
     * Gets the value of the indexDir property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getIndexDir() {
        return indexDir;
    }

    /**
     * Sets the value of the indexDir property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setIndexDir(String value) {
        this.indexDir = value;
    }

    /**
     * Gets the value of the liveCrawlDir property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLiveCrawlDir() {
        return liveCrawlDir;
    }

    /**
     * Sets the value of the liveCrawlDir property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLiveCrawlDir(String value) {
        this.liveCrawlDir = value;
    }

    /**
     * Gets the value of the liveIndexFile property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLiveIndexFile() {
        return liveIndexFile;
    }

    /**
     * Sets the value of the liveIndexFile property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLiveIndexFile(String value) {
        this.liveIndexFile = value;
    }

    /**
     * Gets the value of the liveLogDir property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLiveLogDir() {
        return liveLogDir;
    }

    /**
     * Sets the value of the liveLogDir property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLiveLogDir(String value) {
        this.liveLogDir = value;
    }

    /**
     * Gets the value of the maintainers property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getMaintainers() {
        return maintainers;
    }

    /**
     * Sets the value of the maintainers property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setMaintainers(String value) {
        this.maintainers = value;
    }

    /**
     * Gets the value of the refresh property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRefresh() {
        return refresh;
    }

    /**
     * Sets the value of the refresh property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRefresh(String value) {
        this.refresh = value;
    }

    /**
     * Gets the value of the stagingCrawlDir property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStagingCrawlDir() {
        return stagingCrawlDir;
    }

    /**
     * Sets the value of the stagingCrawlDir property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStagingCrawlDir(String value) {
        this.stagingCrawlDir = value;
    }

    /**
     * Gets the value of the stagingIndexFile property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStagingIndexFile() {
        return stagingIndexFile;
    }

    /**
     * Sets the value of the stagingIndexFile property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStagingIndexFile(String value) {
        this.stagingIndexFile = value;
    }

    /**
     * Gets the value of the stagingLogDir property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStagingLogDir() {
        return stagingLogDir;
    }

    /**
     * Sets the value of the stagingLogDir property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStagingLogDir(String value) {
        this.stagingLogDir = value;
    }

}
