
package velocity.objects;

import java.math.BigInteger;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
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
 *       &lt;choice maxOccurs="0" minOccurs="0">
 *         &lt;element name="directory">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;attribute name="new-path" type="{http://www.w3.org/2001/XMLSchema}string" />
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="file">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;attribute name="old-path" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                 &lt;attribute name="new-path" type="{http://www.w3.org/2001/XMLSchema}string" />
 *                 &lt;attribute name="size" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" />
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *       &lt;/choice>
 *       &lt;attribute name="total-files" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="copied-files" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="total-size" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" />
 *       &lt;attribute name="copied-size" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" />
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "directory",
    "file"
})
@XmlRootElement(name = "search-collection-duplicate-file-list")
public class SearchCollectionDuplicateFileList {

    protected SearchCollectionDuplicateFileList.Directory directory;
    protected SearchCollectionDuplicateFileList.File file;
    @XmlAttribute(name = "total-files")
    @XmlSchemaType(name = "unsignedInt")
    protected Long totalFiles;
    @XmlAttribute(name = "copied-files")
    @XmlSchemaType(name = "unsignedInt")
    protected Long copiedFiles;
    @XmlAttribute(name = "total-size")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger totalSize;
    @XmlAttribute(name = "copied-size")
    @XmlSchemaType(name = "unsignedLong")
    protected BigInteger copiedSize;

    /**
     * Gets the value of the directory property.
     * 
     * @return
     *     possible object is
     *     {@link SearchCollectionDuplicateFileList.Directory }
     *     
     */
    public SearchCollectionDuplicateFileList.Directory getDirectory() {
        return directory;
    }

    /**
     * Sets the value of the directory property.
     * 
     * @param value
     *     allowed object is
     *     {@link SearchCollectionDuplicateFileList.Directory }
     *     
     */
    public void setDirectory(SearchCollectionDuplicateFileList.Directory value) {
        this.directory = value;
    }

    /**
     * Gets the value of the file property.
     * 
     * @return
     *     possible object is
     *     {@link SearchCollectionDuplicateFileList.File }
     *     
     */
    public SearchCollectionDuplicateFileList.File getFile() {
        return file;
    }

    /**
     * Sets the value of the file property.
     * 
     * @param value
     *     allowed object is
     *     {@link SearchCollectionDuplicateFileList.File }
     *     
     */
    public void setFile(SearchCollectionDuplicateFileList.File value) {
        this.file = value;
    }

    /**
     * Gets the value of the totalFiles property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getTotalFiles() {
        return totalFiles;
    }

    /**
     * Sets the value of the totalFiles property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setTotalFiles(Long value) {
        this.totalFiles = value;
    }

    /**
     * Gets the value of the copiedFiles property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getCopiedFiles() {
        return copiedFiles;
    }

    /**
     * Sets the value of the copiedFiles property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setCopiedFiles(Long value) {
        this.copiedFiles = value;
    }

    /**
     * Gets the value of the totalSize property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getTotalSize() {
        return totalSize;
    }

    /**
     * Sets the value of the totalSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setTotalSize(BigInteger value) {
        this.totalSize = value;
    }

    /**
     * Gets the value of the copiedSize property.
     * 
     * @return
     *     possible object is
     *     {@link BigInteger }
     *     
     */
    public BigInteger getCopiedSize() {
        return copiedSize;
    }

    /**
     * Sets the value of the copiedSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link BigInteger }
     *     
     */
    public void setCopiedSize(BigInteger value) {
        this.copiedSize = value;
    }


    /**
     * <p>Java class for anonymous complex type.
     * 
     * <p>The following schema fragment specifies the expected content contained within this class.
     * 
     * <pre>
     * &lt;complexType>
     *   &lt;complexContent>
     *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *       &lt;attribute name="new-path" type="{http://www.w3.org/2001/XMLSchema}string" />
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "")
    public static class Directory {

        @XmlAttribute(name = "new-path")
        protected String newPath;

        /**
         * Gets the value of the newPath property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getNewPath() {
            return newPath;
        }

        /**
         * Sets the value of the newPath property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setNewPath(String value) {
            this.newPath = value;
        }

    }


    /**
     * <p>Java class for anonymous complex type.
     * 
     * <p>The following schema fragment specifies the expected content contained within this class.
     * 
     * <pre>
     * &lt;complexType>
     *   &lt;complexContent>
     *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
     *       &lt;attribute name="old-path" type="{http://www.w3.org/2001/XMLSchema}string" />
     *       &lt;attribute name="new-path" type="{http://www.w3.org/2001/XMLSchema}string" />
     *       &lt;attribute name="size" type="{http://www.w3.org/2001/XMLSchema}unsignedLong" />
     *     &lt;/restriction>
     *   &lt;/complexContent>
     * &lt;/complexType>
     * </pre>
     * 
     * 
     */
    @XmlAccessorType(XmlAccessType.FIELD)
    @XmlType(name = "")
    public static class File {

        @XmlAttribute(name = "old-path")
        protected String oldPath;
        @XmlAttribute(name = "new-path")
        protected String newPath;
        @XmlAttribute
        @XmlSchemaType(name = "unsignedLong")
        protected BigInteger size;

        /**
         * Gets the value of the oldPath property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getOldPath() {
            return oldPath;
        }

        /**
         * Sets the value of the oldPath property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setOldPath(String value) {
            this.oldPath = value;
        }

        /**
         * Gets the value of the newPath property.
         * 
         * @return
         *     possible object is
         *     {@link String }
         *     
         */
        public String getNewPath() {
            return newPath;
        }

        /**
         * Sets the value of the newPath property.
         * 
         * @param value
         *     allowed object is
         *     {@link String }
         *     
         */
        public void setNewPath(String value) {
            this.newPath = value;
        }

        /**
         * Gets the value of the size property.
         * 
         * @return
         *     possible object is
         *     {@link BigInteger }
         *     
         */
        public BigInteger getSize() {
            return size;
        }

        /**
         * Sets the value of the size property.
         * 
         * @param value
         *     allowed object is
         *     {@link BigInteger }
         *     
         */
        public void setSize(BigInteger value) {
            this.size = value;
        }

    }

}
