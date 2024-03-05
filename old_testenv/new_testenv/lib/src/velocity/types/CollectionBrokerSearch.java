
package velocity.types;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAnyElement;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.adapters.CollapsedStringAdapter;
import javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter;
import org.w3c.dom.Element;
import velocity.objects.BinningSet;
import velocity.objects.FieldMap;
import velocity.objects.Operator;
import velocity.objects.Sort;
import velocity.objects.SpellingCorrectorConfiguration;
import velocity.soap.Authentication;


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
 *         &lt;element ref="{urn:/velocity/soap}authentication" minOccurs="0"/>
 *         &lt;element name="collection" type="{http://www.w3.org/2001/XMLSchema}NMTOKEN"/>
 *         &lt;element name="query" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="query-object" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element ref="{urn:/velocity/objects}operator"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="query-condition-object" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element ref="{urn:/velocity/objects}operator"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="query-condition-xpath" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="query-modification-macros" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="start" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="syntax-operators" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="syntax-repository-node" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="syntax-field-mappings" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence maxOccurs="unbounded">
 *                   &lt;element ref="{urn:/velocity/objects}field-map"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="sort-by" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="sort-xpaths" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence maxOccurs="unbounded">
 *                   &lt;element ref="{urn:/velocity/objects}sort"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="sort-score-xpath" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="sort-num-passages" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="rank-decay" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="num" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="num-over-request" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="num-per-source" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="num-max" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="browse" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="browse-num" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="browse-start" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="browse-clusters-num" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="term-expand-max-expansions" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="term-expand-error-when-exceeds-limit" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="spelling-enabled" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="spelling-configuration" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;element ref="{urn:/velocity/objects}spelling-corrector-configuration"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="dict-expand-dictionary" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="dict-expand-max-expansions" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="dict-expand-stem-enabled" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="dict-expand-stem-stemmers" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="dict-expand-wildcard-enabled" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="dict-expand-wildcard-min-length" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="dict-expand-wildcard-segmenter" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="dict-expand-wildcard-delanguage" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="dict-expand-regex-enabled" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="arena" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="output-contents-mode" minOccurs="0">
 *           &lt;simpleType>
 *             &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *               &lt;enumeration value="defaults"/>
 *               &lt;enumeration value="list"/>
 *               &lt;enumeration value="except"/>
 *             &lt;/restriction>
 *           &lt;/simpleType>
 *         &lt;/element>
 *         &lt;element name="output-contents" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="output-summary" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="output-score" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="output-shingles" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="output-duplicates" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="output-key" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="output-cache-references" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="output-cache-data" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="output-sort-keys" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="output-axl" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;any processContents='lax'/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="output-bold-contents" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="output-bold-contents-except" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="output-bold-class-root" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="output-query-node" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="output-display-mode" minOccurs="0">
 *           &lt;simpleType>
 *             &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *               &lt;enumeration value="default"/>
 *               &lt;enumeration value="limited"/>
 *             &lt;/restriction>
 *           &lt;/simpleType>
 *         &lt;/element>
 *         &lt;element name="authorization-rights" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="authorization-username" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="authorization-password" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="collapse-xpath" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="collapse-num" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="collapse-binning" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="collapse-sort-xpaths" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence maxOccurs="unbounded">
 *                   &lt;element ref="{urn:/velocity/objects}sort"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="binning-state" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="binning-mode" minOccurs="0">
 *           &lt;simpleType>
 *             &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *               &lt;enumeration value="defaults"/>
 *               &lt;enumeration value="off"/>
 *               &lt;enumeration value="normal"/>
 *               &lt;enumeration value="double"/>
 *             &lt;/restriction>
 *           &lt;/simpleType>
 *         &lt;/element>
 *         &lt;element name="binning-configuration" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence maxOccurs="unbounded">
 *                   &lt;element ref="{urn:/velocity/objects}binning-set"/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
 *         &lt;element name="force-binning" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="fetch" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="fetch-timeout" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="aggregate" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="aggregate-max-passes" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="cluster" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="cluster-near-duplicates" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="cluster-kbs" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="cluster-stemmers" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="cluster-segmenter" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="efficient-paging" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="efficient-paging-n-top-docs-to-cluster" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="debug" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="profile" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="extra-xml" minOccurs="0">
 *           &lt;complexType>
 *             &lt;complexContent>
 *               &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *                 &lt;sequence>
 *                   &lt;any processContents='lax'/>
 *                 &lt;/sequence>
 *               &lt;/restriction>
 *             &lt;/complexContent>
 *           &lt;/complexType>
 *         &lt;/element>
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
    "authentication",
    "collection",
    "query",
    "queryObject",
    "queryConditionObject",
    "queryConditionXpath",
    "queryModificationMacros",
    "start",
    "syntaxOperators",
    "syntaxRepositoryNode",
    "syntaxFieldMappings",
    "sortBy",
    "sortXpaths",
    "sortScoreXpath",
    "sortNumPassages",
    "rankDecay",
    "num",
    "numOverRequest",
    "numPerSource",
    "numMax",
    "browse",
    "browseNum",
    "browseStart",
    "browseClustersNum",
    "termExpandMaxExpansions",
    "termExpandErrorWhenExceedsLimit",
    "spellingEnabled",
    "spellingConfiguration",
    "dictExpandDictionary",
    "dictExpandMaxExpansions",
    "dictExpandStemEnabled",
    "dictExpandStemStemmers",
    "dictExpandWildcardEnabled",
    "dictExpandWildcardMinLength",
    "dictExpandWildcardSegmenter",
    "dictExpandWildcardDelanguage",
    "dictExpandRegexEnabled",
    "arena",
    "outputContentsMode",
    "outputContents",
    "outputSummary",
    "outputScore",
    "outputShingles",
    "outputDuplicates",
    "outputKey",
    "outputCacheReferences",
    "outputCacheData",
    "outputSortKeys",
    "outputAxl",
    "outputBoldContents",
    "outputBoldContentsExcept",
    "outputBoldClassRoot",
    "outputQueryNode",
    "outputDisplayMode",
    "authorizationRights",
    "authorizationUsername",
    "authorizationPassword",
    "collapseXpath",
    "collapseNum",
    "collapseBinning",
    "collapseSortXpaths",
    "binningState",
    "binningMode",
    "binningConfiguration",
    "forceBinning",
    "fetch",
    "fetchTimeout",
    "aggregate",
    "aggregateMaxPasses",
    "cluster",
    "clusterNearDuplicates",
    "clusterKbs",
    "clusterStemmers",
    "clusterSegmenter",
    "efficientPaging",
    "efficientPagingNTopDocsToCluster",
    "debug",
    "profile",
    "extraXml"
})
@XmlRootElement(name = "CollectionBrokerSearch")
public class CollectionBrokerSearch {

    @XmlElement(namespace = "urn:/velocity/soap")
    protected Authentication authentication;
    @XmlElement(required = true)
    @XmlJavaTypeAdapter(CollapsedStringAdapter.class)
    @XmlSchemaType(name = "NMTOKEN")
    protected String collection;
    protected String query;
    @XmlElement(name = "query-object")
    protected CollectionBrokerSearch.QueryObject queryObject;
    @XmlElement(name = "query-condition-object")
    protected CollectionBrokerSearch.QueryConditionObject queryConditionObject;
    @XmlElement(name = "query-condition-xpath")
    protected String queryConditionXpath;
    @XmlElement(name = "query-modification-macros")
    protected String queryModificationMacros;
    @XmlElement(defaultValue = "0")
    protected Integer start;
    @XmlElement(name = "syntax-operators", defaultValue = "AND and () CONTAINING CONTENT %field%: + NEAR - NOT NOTCONTAINING NOTWITHIN OR0 quotes regex stem THRU BEFORE FOLLOWEDBY weight wildcard wildchar WITHIN WORDS site less-than less-than-or-equal greater-than greater-than-or-equal equal range")
    protected String syntaxOperators;
    @XmlElement(name = "syntax-repository-node", defaultValue = "custom")
    protected String syntaxRepositoryNode;
    @XmlElement(name = "syntax-field-mappings")
    protected CollectionBrokerSearch.SyntaxFieldMappings syntaxFieldMappings;
    @XmlElement(name = "sort-by")
    protected String sortBy;
    @XmlElement(name = "sort-xpaths")
    protected CollectionBrokerSearch.SortXpaths sortXpaths;
    @XmlElement(name = "sort-score-xpath")
    protected String sortScoreXpath;
    @XmlElement(name = "sort-num-passages")
    protected Integer sortNumPassages;
    @XmlElement(name = "rank-decay")
    protected Double rankDecay;
    @XmlElement(defaultValue = "10")
    protected Integer num;
    @XmlElement(name = "num-over-request", defaultValue = "1.3")
    protected Double numOverRequest;
    @XmlElement(name = "num-per-source")
    protected Integer numPerSource;
    @XmlElement(name = "num-max")
    protected Integer numMax;
    @XmlElement(defaultValue = "false")
    protected Boolean browse;
    @XmlElement(name = "browse-num", defaultValue = "10")
    protected Integer browseNum;
    @XmlElement(name = "browse-start", defaultValue = "0")
    protected Integer browseStart;
    @XmlElement(name = "browse-clusters-num", defaultValue = "10")
    protected Integer browseClustersNum;
    @XmlElement(name = "term-expand-max-expansions")
    protected Integer termExpandMaxExpansions;
    @XmlElement(name = "term-expand-error-when-exceeds-limit")
    protected Boolean termExpandErrorWhenExceedsLimit;
    @XmlElement(name = "spelling-enabled", defaultValue = "false")
    protected Boolean spellingEnabled;
    @XmlElement(name = "spelling-configuration")
    protected CollectionBrokerSearch.SpellingConfiguration spellingConfiguration;
    @XmlElement(name = "dict-expand-dictionary")
    protected String dictExpandDictionary;
    @XmlElement(name = "dict-expand-max-expansions")
    protected Integer dictExpandMaxExpansions;
    @XmlElement(name = "dict-expand-stem-enabled")
    protected Boolean dictExpandStemEnabled;
    @XmlElement(name = "dict-expand-stem-stemmers")
    protected String dictExpandStemStemmers;
    @XmlElement(name = "dict-expand-wildcard-enabled")
    protected Boolean dictExpandWildcardEnabled;
    @XmlElement(name = "dict-expand-wildcard-min-length")
    protected Integer dictExpandWildcardMinLength;
    @XmlElement(name = "dict-expand-wildcard-segmenter")
    protected String dictExpandWildcardSegmenter;
    @XmlElement(name = "dict-expand-wildcard-delanguage")
    protected Boolean dictExpandWildcardDelanguage;
    @XmlElement(name = "dict-expand-regex-enabled")
    protected Boolean dictExpandRegexEnabled;
    protected String arena;
    @XmlElement(name = "output-contents-mode", defaultValue = "defaults")
    protected String outputContentsMode;
    @XmlElement(name = "output-contents")
    protected String outputContents;
    @XmlElement(name = "output-summary")
    protected Boolean outputSummary;
    @XmlElement(name = "output-score")
    protected Boolean outputScore;
    @XmlElement(name = "output-shingles")
    protected Boolean outputShingles;
    @XmlElement(name = "output-duplicates")
    protected Boolean outputDuplicates;
    @XmlElement(name = "output-key")
    protected Boolean outputKey;
    @XmlElement(name = "output-cache-references")
    protected Boolean outputCacheReferences;
    @XmlElement(name = "output-cache-data")
    protected Boolean outputCacheData;
    @XmlElement(name = "output-sort-keys")
    protected Boolean outputSortKeys;
    @XmlElement(name = "output-axl")
    protected CollectionBrokerSearch.OutputAxl outputAxl;
    @XmlElement(name = "output-bold-contents")
    protected String outputBoldContents;
    @XmlElement(name = "output-bold-contents-except", defaultValue = "false")
    protected Boolean outputBoldContentsExcept;
    @XmlElement(name = "output-bold-class-root")
    protected String outputBoldClassRoot;
    @XmlElement(name = "output-query-node", defaultValue = "true")
    protected Boolean outputQueryNode;
    @XmlElement(name = "output-display-mode", defaultValue = "default")
    protected String outputDisplayMode;
    @XmlElement(name = "authorization-rights")
    protected String authorizationRights;
    @XmlElement(name = "authorization-username")
    protected String authorizationUsername;
    @XmlElement(name = "authorization-password")
    protected String authorizationPassword;
    @XmlElement(name = "collapse-xpath")
    protected String collapseXpath;
    @XmlElement(name = "collapse-num")
    protected Integer collapseNum;
    @XmlElement(name = "collapse-binning")
    protected Boolean collapseBinning;
    @XmlElement(name = "collapse-sort-xpaths")
    protected CollectionBrokerSearch.CollapseSortXpaths collapseSortXpaths;
    @XmlElement(name = "binning-state")
    protected String binningState;
    @XmlElement(name = "binning-mode", defaultValue = "defaults")
    protected String binningMode;
    @XmlElement(name = "binning-configuration")
    protected CollectionBrokerSearch.BinningConfiguration binningConfiguration;
    @XmlElement(name = "force-binning", defaultValue = "false")
    protected Boolean forceBinning;
    @XmlElement(defaultValue = "true")
    protected Boolean fetch;
    @XmlElement(name = "fetch-timeout", defaultValue = "60000")
    protected Integer fetchTimeout;
    @XmlElement(defaultValue = "false")
    protected Boolean aggregate;
    @XmlElement(name = "aggregate-max-passes", defaultValue = "3")
    protected Integer aggregateMaxPasses;
    @XmlElement(defaultValue = "false")
    protected Boolean cluster;
    @XmlElement(name = "cluster-near-duplicates", defaultValue = "-1")
    protected Double clusterNearDuplicates;
    @XmlElement(name = "cluster-kbs", defaultValue = "core web english custom")
    protected String clusterKbs;
    @XmlElement(name = "cluster-stemmers", defaultValue = "delanguage english depluralize")
    protected String clusterStemmers;
    @XmlElement(name = "cluster-segmenter", defaultValue = "none")
    protected String clusterSegmenter;
    @XmlElement(name = "efficient-paging", defaultValue = "false")
    protected Boolean efficientPaging;
    @XmlElement(name = "efficient-paging-n-top-docs-to-cluster", defaultValue = "200")
    protected Integer efficientPagingNTopDocsToCluster;
    @XmlElement(defaultValue = "false")
    protected Boolean debug;
    @XmlElement(defaultValue = "false")
    protected Boolean profile;
    @XmlElement(name = "extra-xml")
    protected CollectionBrokerSearch.ExtraXml extraXml;

    /**
     * Gets the value of the authentication property.
     * 
     * @return
     *     possible object is
     *     {@link Authentication }
     *     
     */
    public Authentication getAuthentication() {
        return authentication;
    }

    /**
     * Sets the value of the authentication property.
     * 
     * @param value
     *     allowed object is
     *     {@link Authentication }
     *     
     */
    public void setAuthentication(Authentication value) {
        this.authentication = value;
    }

    /**
     * Gets the value of the collection property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCollection() {
        return collection;
    }

    /**
     * Sets the value of the collection property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCollection(String value) {
        this.collection = value;
    }

    /**
     * Gets the value of the query property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getQuery() {
        return query;
    }

    /**
     * Sets the value of the query property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setQuery(String value) {
        this.query = value;
    }

    /**
     * Gets the value of the queryObject property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerSearch.QueryObject }
     *     
     */
    public CollectionBrokerSearch.QueryObject getQueryObject() {
        return queryObject;
    }

    /**
     * Sets the value of the queryObject property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerSearch.QueryObject }
     *     
     */
    public void setQueryObject(CollectionBrokerSearch.QueryObject value) {
        this.queryObject = value;
    }

    /**
     * Gets the value of the queryConditionObject property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerSearch.QueryConditionObject }
     *     
     */
    public CollectionBrokerSearch.QueryConditionObject getQueryConditionObject() {
        return queryConditionObject;
    }

    /**
     * Sets the value of the queryConditionObject property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerSearch.QueryConditionObject }
     *     
     */
    public void setQueryConditionObject(CollectionBrokerSearch.QueryConditionObject value) {
        this.queryConditionObject = value;
    }

    /**
     * Gets the value of the queryConditionXpath property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getQueryConditionXpath() {
        return queryConditionXpath;
    }

    /**
     * Sets the value of the queryConditionXpath property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setQueryConditionXpath(String value) {
        this.queryConditionXpath = value;
    }

    /**
     * Gets the value of the queryModificationMacros property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getQueryModificationMacros() {
        return queryModificationMacros;
    }

    /**
     * Sets the value of the queryModificationMacros property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setQueryModificationMacros(String value) {
        this.queryModificationMacros = value;
    }

    /**
     * Gets the value of the start property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getStart() {
        return start;
    }

    /**
     * Sets the value of the start property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setStart(Integer value) {
        this.start = value;
    }

    /**
     * Gets the value of the syntaxOperators property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSyntaxOperators() {
        return syntaxOperators;
    }

    /**
     * Sets the value of the syntaxOperators property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSyntaxOperators(String value) {
        this.syntaxOperators = value;
    }

    /**
     * Gets the value of the syntaxRepositoryNode property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSyntaxRepositoryNode() {
        return syntaxRepositoryNode;
    }

    /**
     * Sets the value of the syntaxRepositoryNode property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSyntaxRepositoryNode(String value) {
        this.syntaxRepositoryNode = value;
    }

    /**
     * Gets the value of the syntaxFieldMappings property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerSearch.SyntaxFieldMappings }
     *     
     */
    public CollectionBrokerSearch.SyntaxFieldMappings getSyntaxFieldMappings() {
        return syntaxFieldMappings;
    }

    /**
     * Sets the value of the syntaxFieldMappings property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerSearch.SyntaxFieldMappings }
     *     
     */
    public void setSyntaxFieldMappings(CollectionBrokerSearch.SyntaxFieldMappings value) {
        this.syntaxFieldMappings = value;
    }

    /**
     * Gets the value of the sortBy property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSortBy() {
        return sortBy;
    }

    /**
     * Sets the value of the sortBy property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSortBy(String value) {
        this.sortBy = value;
    }

    /**
     * Gets the value of the sortXpaths property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerSearch.SortXpaths }
     *     
     */
    public CollectionBrokerSearch.SortXpaths getSortXpaths() {
        return sortXpaths;
    }

    /**
     * Sets the value of the sortXpaths property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerSearch.SortXpaths }
     *     
     */
    public void setSortXpaths(CollectionBrokerSearch.SortXpaths value) {
        this.sortXpaths = value;
    }

    /**
     * Gets the value of the sortScoreXpath property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSortScoreXpath() {
        return sortScoreXpath;
    }

    /**
     * Sets the value of the sortScoreXpath property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSortScoreXpath(String value) {
        this.sortScoreXpath = value;
    }

    /**
     * Gets the value of the sortNumPassages property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getSortNumPassages() {
        return sortNumPassages;
    }

    /**
     * Sets the value of the sortNumPassages property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setSortNumPassages(Integer value) {
        this.sortNumPassages = value;
    }

    /**
     * Gets the value of the rankDecay property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getRankDecay() {
        return rankDecay;
    }

    /**
     * Sets the value of the rankDecay property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setRankDecay(Double value) {
        this.rankDecay = value;
    }

    /**
     * Gets the value of the num property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNum() {
        return num;
    }

    /**
     * Sets the value of the num property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNum(Integer value) {
        this.num = value;
    }

    /**
     * Gets the value of the numOverRequest property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getNumOverRequest() {
        return numOverRequest;
    }

    /**
     * Sets the value of the numOverRequest property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setNumOverRequest(Double value) {
        this.numOverRequest = value;
    }

    /**
     * Gets the value of the numPerSource property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNumPerSource() {
        return numPerSource;
    }

    /**
     * Sets the value of the numPerSource property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNumPerSource(Integer value) {
        this.numPerSource = value;
    }

    /**
     * Gets the value of the numMax property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNumMax() {
        return numMax;
    }

    /**
     * Sets the value of the numMax property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNumMax(Integer value) {
        this.numMax = value;
    }

    /**
     * Gets the value of the browse property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isBrowse() {
        return browse;
    }

    /**
     * Sets the value of the browse property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setBrowse(Boolean value) {
        this.browse = value;
    }

    /**
     * Gets the value of the browseNum property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getBrowseNum() {
        return browseNum;
    }

    /**
     * Sets the value of the browseNum property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setBrowseNum(Integer value) {
        this.browseNum = value;
    }

    /**
     * Gets the value of the browseStart property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getBrowseStart() {
        return browseStart;
    }

    /**
     * Sets the value of the browseStart property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setBrowseStart(Integer value) {
        this.browseStart = value;
    }

    /**
     * Gets the value of the browseClustersNum property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getBrowseClustersNum() {
        return browseClustersNum;
    }

    /**
     * Sets the value of the browseClustersNum property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setBrowseClustersNum(Integer value) {
        this.browseClustersNum = value;
    }

    /**
     * Gets the value of the termExpandMaxExpansions property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getTermExpandMaxExpansions() {
        return termExpandMaxExpansions;
    }

    /**
     * Sets the value of the termExpandMaxExpansions property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setTermExpandMaxExpansions(Integer value) {
        this.termExpandMaxExpansions = value;
    }

    /**
     * Gets the value of the termExpandErrorWhenExceedsLimit property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isTermExpandErrorWhenExceedsLimit() {
        return termExpandErrorWhenExceedsLimit;
    }

    /**
     * Sets the value of the termExpandErrorWhenExceedsLimit property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setTermExpandErrorWhenExceedsLimit(Boolean value) {
        this.termExpandErrorWhenExceedsLimit = value;
    }

    /**
     * Gets the value of the spellingEnabled property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isSpellingEnabled() {
        return spellingEnabled;
    }

    /**
     * Sets the value of the spellingEnabled property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setSpellingEnabled(Boolean value) {
        this.spellingEnabled = value;
    }

    /**
     * Gets the value of the spellingConfiguration property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerSearch.SpellingConfiguration }
     *     
     */
    public CollectionBrokerSearch.SpellingConfiguration getSpellingConfiguration() {
        return spellingConfiguration;
    }

    /**
     * Sets the value of the spellingConfiguration property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerSearch.SpellingConfiguration }
     *     
     */
    public void setSpellingConfiguration(CollectionBrokerSearch.SpellingConfiguration value) {
        this.spellingConfiguration = value;
    }

    /**
     * Gets the value of the dictExpandDictionary property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDictExpandDictionary() {
        return dictExpandDictionary;
    }

    /**
     * Sets the value of the dictExpandDictionary property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDictExpandDictionary(String value) {
        this.dictExpandDictionary = value;
    }

    /**
     * Gets the value of the dictExpandMaxExpansions property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getDictExpandMaxExpansions() {
        return dictExpandMaxExpansions;
    }

    /**
     * Sets the value of the dictExpandMaxExpansions property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setDictExpandMaxExpansions(Integer value) {
        this.dictExpandMaxExpansions = value;
    }

    /**
     * Gets the value of the dictExpandStemEnabled property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isDictExpandStemEnabled() {
        return dictExpandStemEnabled;
    }

    /**
     * Sets the value of the dictExpandStemEnabled property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setDictExpandStemEnabled(Boolean value) {
        this.dictExpandStemEnabled = value;
    }

    /**
     * Gets the value of the dictExpandStemStemmers property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDictExpandStemStemmers() {
        return dictExpandStemStemmers;
    }

    /**
     * Sets the value of the dictExpandStemStemmers property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDictExpandStemStemmers(String value) {
        this.dictExpandStemStemmers = value;
    }

    /**
     * Gets the value of the dictExpandWildcardEnabled property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isDictExpandWildcardEnabled() {
        return dictExpandWildcardEnabled;
    }

    /**
     * Sets the value of the dictExpandWildcardEnabled property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setDictExpandWildcardEnabled(Boolean value) {
        this.dictExpandWildcardEnabled = value;
    }

    /**
     * Gets the value of the dictExpandWildcardMinLength property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getDictExpandWildcardMinLength() {
        return dictExpandWildcardMinLength;
    }

    /**
     * Sets the value of the dictExpandWildcardMinLength property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setDictExpandWildcardMinLength(Integer value) {
        this.dictExpandWildcardMinLength = value;
    }

    /**
     * Gets the value of the dictExpandWildcardSegmenter property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDictExpandWildcardSegmenter() {
        return dictExpandWildcardSegmenter;
    }

    /**
     * Sets the value of the dictExpandWildcardSegmenter property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDictExpandWildcardSegmenter(String value) {
        this.dictExpandWildcardSegmenter = value;
    }

    /**
     * Gets the value of the dictExpandWildcardDelanguage property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isDictExpandWildcardDelanguage() {
        return dictExpandWildcardDelanguage;
    }

    /**
     * Sets the value of the dictExpandWildcardDelanguage property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setDictExpandWildcardDelanguage(Boolean value) {
        this.dictExpandWildcardDelanguage = value;
    }

    /**
     * Gets the value of the dictExpandRegexEnabled property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isDictExpandRegexEnabled() {
        return dictExpandRegexEnabled;
    }

    /**
     * Sets the value of the dictExpandRegexEnabled property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setDictExpandRegexEnabled(Boolean value) {
        this.dictExpandRegexEnabled = value;
    }

    /**
     * Gets the value of the arena property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getArena() {
        return arena;
    }

    /**
     * Sets the value of the arena property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setArena(String value) {
        this.arena = value;
    }

    /**
     * Gets the value of the outputContentsMode property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOutputContentsMode() {
        return outputContentsMode;
    }

    /**
     * Sets the value of the outputContentsMode property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOutputContentsMode(String value) {
        this.outputContentsMode = value;
    }

    /**
     * Gets the value of the outputContents property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOutputContents() {
        return outputContents;
    }

    /**
     * Sets the value of the outputContents property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOutputContents(String value) {
        this.outputContents = value;
    }

    /**
     * Gets the value of the outputSummary property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isOutputSummary() {
        return outputSummary;
    }

    /**
     * Sets the value of the outputSummary property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setOutputSummary(Boolean value) {
        this.outputSummary = value;
    }

    /**
     * Gets the value of the outputScore property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isOutputScore() {
        return outputScore;
    }

    /**
     * Sets the value of the outputScore property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setOutputScore(Boolean value) {
        this.outputScore = value;
    }

    /**
     * Gets the value of the outputShingles property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isOutputShingles() {
        return outputShingles;
    }

    /**
     * Sets the value of the outputShingles property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setOutputShingles(Boolean value) {
        this.outputShingles = value;
    }

    /**
     * Gets the value of the outputDuplicates property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isOutputDuplicates() {
        return outputDuplicates;
    }

    /**
     * Sets the value of the outputDuplicates property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setOutputDuplicates(Boolean value) {
        this.outputDuplicates = value;
    }

    /**
     * Gets the value of the outputKey property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isOutputKey() {
        return outputKey;
    }

    /**
     * Sets the value of the outputKey property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setOutputKey(Boolean value) {
        this.outputKey = value;
    }

    /**
     * Gets the value of the outputCacheReferences property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isOutputCacheReferences() {
        return outputCacheReferences;
    }

    /**
     * Sets the value of the outputCacheReferences property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setOutputCacheReferences(Boolean value) {
        this.outputCacheReferences = value;
    }

    /**
     * Gets the value of the outputCacheData property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isOutputCacheData() {
        return outputCacheData;
    }

    /**
     * Sets the value of the outputCacheData property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setOutputCacheData(Boolean value) {
        this.outputCacheData = value;
    }

    /**
     * Gets the value of the outputSortKeys property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isOutputSortKeys() {
        return outputSortKeys;
    }

    /**
     * Sets the value of the outputSortKeys property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setOutputSortKeys(Boolean value) {
        this.outputSortKeys = value;
    }

    /**
     * Gets the value of the outputAxl property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerSearch.OutputAxl }
     *     
     */
    public CollectionBrokerSearch.OutputAxl getOutputAxl() {
        return outputAxl;
    }

    /**
     * Sets the value of the outputAxl property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerSearch.OutputAxl }
     *     
     */
    public void setOutputAxl(CollectionBrokerSearch.OutputAxl value) {
        this.outputAxl = value;
    }

    /**
     * Gets the value of the outputBoldContents property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOutputBoldContents() {
        return outputBoldContents;
    }

    /**
     * Sets the value of the outputBoldContents property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOutputBoldContents(String value) {
        this.outputBoldContents = value;
    }

    /**
     * Gets the value of the outputBoldContentsExcept property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isOutputBoldContentsExcept() {
        return outputBoldContentsExcept;
    }

    /**
     * Sets the value of the outputBoldContentsExcept property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setOutputBoldContentsExcept(Boolean value) {
        this.outputBoldContentsExcept = value;
    }

    /**
     * Gets the value of the outputBoldClassRoot property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOutputBoldClassRoot() {
        return outputBoldClassRoot;
    }

    /**
     * Sets the value of the outputBoldClassRoot property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOutputBoldClassRoot(String value) {
        this.outputBoldClassRoot = value;
    }

    /**
     * Gets the value of the outputQueryNode property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isOutputQueryNode() {
        return outputQueryNode;
    }

    /**
     * Sets the value of the outputQueryNode property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setOutputQueryNode(Boolean value) {
        this.outputQueryNode = value;
    }

    /**
     * Gets the value of the outputDisplayMode property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOutputDisplayMode() {
        return outputDisplayMode;
    }

    /**
     * Sets the value of the outputDisplayMode property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOutputDisplayMode(String value) {
        this.outputDisplayMode = value;
    }

    /**
     * Gets the value of the authorizationRights property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAuthorizationRights() {
        return authorizationRights;
    }

    /**
     * Sets the value of the authorizationRights property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAuthorizationRights(String value) {
        this.authorizationRights = value;
    }

    /**
     * Gets the value of the authorizationUsername property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAuthorizationUsername() {
        return authorizationUsername;
    }

    /**
     * Sets the value of the authorizationUsername property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAuthorizationUsername(String value) {
        this.authorizationUsername = value;
    }

    /**
     * Gets the value of the authorizationPassword property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAuthorizationPassword() {
        return authorizationPassword;
    }

    /**
     * Sets the value of the authorizationPassword property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAuthorizationPassword(String value) {
        this.authorizationPassword = value;
    }

    /**
     * Gets the value of the collapseXpath property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCollapseXpath() {
        return collapseXpath;
    }

    /**
     * Sets the value of the collapseXpath property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCollapseXpath(String value) {
        this.collapseXpath = value;
    }

    /**
     * Gets the value of the collapseNum property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getCollapseNum() {
        return collapseNum;
    }

    /**
     * Sets the value of the collapseNum property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setCollapseNum(Integer value) {
        this.collapseNum = value;
    }

    /**
     * Gets the value of the collapseBinning property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isCollapseBinning() {
        return collapseBinning;
    }

    /**
     * Sets the value of the collapseBinning property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setCollapseBinning(Boolean value) {
        this.collapseBinning = value;
    }

    /**
     * Gets the value of the collapseSortXpaths property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerSearch.CollapseSortXpaths }
     *     
     */
    public CollectionBrokerSearch.CollapseSortXpaths getCollapseSortXpaths() {
        return collapseSortXpaths;
    }

    /**
     * Sets the value of the collapseSortXpaths property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerSearch.CollapseSortXpaths }
     *     
     */
    public void setCollapseSortXpaths(CollectionBrokerSearch.CollapseSortXpaths value) {
        this.collapseSortXpaths = value;
    }

    /**
     * Gets the value of the binningState property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBinningState() {
        return binningState;
    }

    /**
     * Sets the value of the binningState property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBinningState(String value) {
        this.binningState = value;
    }

    /**
     * Gets the value of the binningMode property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBinningMode() {
        return binningMode;
    }

    /**
     * Sets the value of the binningMode property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBinningMode(String value) {
        this.binningMode = value;
    }

    /**
     * Gets the value of the binningConfiguration property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerSearch.BinningConfiguration }
     *     
     */
    public CollectionBrokerSearch.BinningConfiguration getBinningConfiguration() {
        return binningConfiguration;
    }

    /**
     * Sets the value of the binningConfiguration property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerSearch.BinningConfiguration }
     *     
     */
    public void setBinningConfiguration(CollectionBrokerSearch.BinningConfiguration value) {
        this.binningConfiguration = value;
    }

    /**
     * Gets the value of the forceBinning property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isForceBinning() {
        return forceBinning;
    }

    /**
     * Sets the value of the forceBinning property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setForceBinning(Boolean value) {
        this.forceBinning = value;
    }

    /**
     * Gets the value of the fetch property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isFetch() {
        return fetch;
    }

    /**
     * Sets the value of the fetch property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setFetch(Boolean value) {
        this.fetch = value;
    }

    /**
     * Gets the value of the fetchTimeout property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getFetchTimeout() {
        return fetchTimeout;
    }

    /**
     * Sets the value of the fetchTimeout property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setFetchTimeout(Integer value) {
        this.fetchTimeout = value;
    }

    /**
     * Gets the value of the aggregate property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isAggregate() {
        return aggregate;
    }

    /**
     * Sets the value of the aggregate property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setAggregate(Boolean value) {
        this.aggregate = value;
    }

    /**
     * Gets the value of the aggregateMaxPasses property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getAggregateMaxPasses() {
        return aggregateMaxPasses;
    }

    /**
     * Sets the value of the aggregateMaxPasses property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setAggregateMaxPasses(Integer value) {
        this.aggregateMaxPasses = value;
    }

    /**
     * Gets the value of the cluster property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isCluster() {
        return cluster;
    }

    /**
     * Sets the value of the cluster property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setCluster(Boolean value) {
        this.cluster = value;
    }

    /**
     * Gets the value of the clusterNearDuplicates property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getClusterNearDuplicates() {
        return clusterNearDuplicates;
    }

    /**
     * Sets the value of the clusterNearDuplicates property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setClusterNearDuplicates(Double value) {
        this.clusterNearDuplicates = value;
    }

    /**
     * Gets the value of the clusterKbs property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getClusterKbs() {
        return clusterKbs;
    }

    /**
     * Sets the value of the clusterKbs property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setClusterKbs(String value) {
        this.clusterKbs = value;
    }

    /**
     * Gets the value of the clusterStemmers property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getClusterStemmers() {
        return clusterStemmers;
    }

    /**
     * Sets the value of the clusterStemmers property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setClusterStemmers(String value) {
        this.clusterStemmers = value;
    }

    /**
     * Gets the value of the clusterSegmenter property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getClusterSegmenter() {
        return clusterSegmenter;
    }

    /**
     * Sets the value of the clusterSegmenter property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setClusterSegmenter(String value) {
        this.clusterSegmenter = value;
    }

    /**
     * Gets the value of the efficientPaging property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isEfficientPaging() {
        return efficientPaging;
    }

    /**
     * Sets the value of the efficientPaging property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setEfficientPaging(Boolean value) {
        this.efficientPaging = value;
    }

    /**
     * Gets the value of the efficientPagingNTopDocsToCluster property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getEfficientPagingNTopDocsToCluster() {
        return efficientPagingNTopDocsToCluster;
    }

    /**
     * Sets the value of the efficientPagingNTopDocsToCluster property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setEfficientPagingNTopDocsToCluster(Integer value) {
        this.efficientPagingNTopDocsToCluster = value;
    }

    /**
     * Gets the value of the debug property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isDebug() {
        return debug;
    }

    /**
     * Sets the value of the debug property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setDebug(Boolean value) {
        this.debug = value;
    }

    /**
     * Gets the value of the profile property.
     * 
     * @return
     *     possible object is
     *     {@link Boolean }
     *     
     */
    public Boolean isProfile() {
        return profile;
    }

    /**
     * Sets the value of the profile property.
     * 
     * @param value
     *     allowed object is
     *     {@link Boolean }
     *     
     */
    public void setProfile(Boolean value) {
        this.profile = value;
    }

    /**
     * Gets the value of the extraXml property.
     * 
     * @return
     *     possible object is
     *     {@link CollectionBrokerSearch.ExtraXml }
     *     
     */
    public CollectionBrokerSearch.ExtraXml getExtraXml() {
        return extraXml;
    }

    /**
     * Sets the value of the extraXml property.
     * 
     * @param value
     *     allowed object is
     *     {@link CollectionBrokerSearch.ExtraXml }
     *     
     */
    public void setExtraXml(CollectionBrokerSearch.ExtraXml value) {
        this.extraXml = value;
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
     *       &lt;sequence maxOccurs="unbounded">
     *         &lt;element ref="{urn:/velocity/objects}binning-set"/>
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
        "binningSet"
    })
    public static class BinningConfiguration {

        @XmlElement(name = "binning-set", namespace = "urn:/velocity/objects", required = true)
        protected List<BinningSet> binningSet;

        /**
         * Gets the value of the binningSet property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the binningSet property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getBinningSet().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link BinningSet }
         * 
         * 
         */
        public List<BinningSet> getBinningSet() {
            if (binningSet == null) {
                binningSet = new ArrayList<BinningSet>();
            }
            return this.binningSet;
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
     *       &lt;sequence maxOccurs="unbounded">
     *         &lt;element ref="{urn:/velocity/objects}sort"/>
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
        "sort"
    })
    public static class CollapseSortXpaths {

        @XmlElement(namespace = "urn:/velocity/objects", required = true)
        protected List<Sort> sort;

        /**
         * Gets the value of the sort property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the sort property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getSort().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link Sort }
         * 
         * 
         */
        public List<Sort> getSort() {
            if (sort == null) {
                sort = new ArrayList<Sort>();
            }
            return this.sort;
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
     *       &lt;sequence>
     *         &lt;any processContents='lax'/>
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
        "any"
    })
    public static class ExtraXml {

        @XmlAnyElement(lax = true)
        protected Object any;

        /**
         * Gets the value of the any property.
         * 
         * @return
         *     possible object is
         *     {@link Element }
         *     {@link Object }
         *     
         */
        public Object getAny() {
            return any;
        }

        /**
         * Sets the value of the any property.
         * 
         * @param value
         *     allowed object is
         *     {@link Element }
         *     {@link Object }
         *     
         */
        public void setAny(Object value) {
            this.any = value;
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
     *       &lt;sequence>
     *         &lt;any processContents='lax'/>
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
        "any"
    })
    public static class OutputAxl {

        @XmlAnyElement(lax = true)
        protected Object any;

        /**
         * Gets the value of the any property.
         * 
         * @return
         *     possible object is
         *     {@link Element }
         *     {@link Object }
         *     
         */
        public Object getAny() {
            return any;
        }

        /**
         * Sets the value of the any property.
         * 
         * @param value
         *     allowed object is
         *     {@link Element }
         *     {@link Object }
         *     
         */
        public void setAny(Object value) {
            this.any = value;
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
     *       &lt;sequence>
     *         &lt;element ref="{urn:/velocity/objects}operator"/>
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
        "operator"
    })
    public static class QueryConditionObject {

        @XmlElement(namespace = "urn:/velocity/objects", required = true)
        protected Operator operator;

        /**
         * Gets the value of the operator property.
         * 
         * @return
         *     possible object is
         *     {@link Operator }
         *     
         */
        public Operator getOperator() {
            return operator;
        }

        /**
         * Sets the value of the operator property.
         * 
         * @param value
         *     allowed object is
         *     {@link Operator }
         *     
         */
        public void setOperator(Operator value) {
            this.operator = value;
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
     *       &lt;sequence>
     *         &lt;element ref="{urn:/velocity/objects}operator"/>
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
        "operator"
    })
    public static class QueryObject {

        @XmlElement(namespace = "urn:/velocity/objects", required = true)
        protected Operator operator;

        /**
         * Gets the value of the operator property.
         * 
         * @return
         *     possible object is
         *     {@link Operator }
         *     
         */
        public Operator getOperator() {
            return operator;
        }

        /**
         * Sets the value of the operator property.
         * 
         * @param value
         *     allowed object is
         *     {@link Operator }
         *     
         */
        public void setOperator(Operator value) {
            this.operator = value;
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
     *       &lt;sequence maxOccurs="unbounded">
     *         &lt;element ref="{urn:/velocity/objects}sort"/>
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
        "sort"
    })
    public static class SortXpaths {

        @XmlElement(namespace = "urn:/velocity/objects", required = true)
        protected List<Sort> sort;

        /**
         * Gets the value of the sort property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the sort property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getSort().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link Sort }
         * 
         * 
         */
        public List<Sort> getSort() {
            if (sort == null) {
                sort = new ArrayList<Sort>();
            }
            return this.sort;
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
     *       &lt;sequence>
     *         &lt;element ref="{urn:/velocity/objects}spelling-corrector-configuration"/>
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
        "spellingCorrectorConfiguration"
    })
    public static class SpellingConfiguration {

        @XmlElement(name = "spelling-corrector-configuration", namespace = "urn:/velocity/objects", required = true)
        protected SpellingCorrectorConfiguration spellingCorrectorConfiguration;

        /**
         * Gets the value of the spellingCorrectorConfiguration property.
         * 
         * @return
         *     possible object is
         *     {@link SpellingCorrectorConfiguration }
         *     
         */
        public SpellingCorrectorConfiguration getSpellingCorrectorConfiguration() {
            return spellingCorrectorConfiguration;
        }

        /**
         * Sets the value of the spellingCorrectorConfiguration property.
         * 
         * @param value
         *     allowed object is
         *     {@link SpellingCorrectorConfiguration }
         *     
         */
        public void setSpellingCorrectorConfiguration(SpellingCorrectorConfiguration value) {
            this.spellingCorrectorConfiguration = value;
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
     *       &lt;sequence maxOccurs="unbounded">
     *         &lt;element ref="{urn:/velocity/objects}field-map"/>
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
        "fieldMap"
    })
    public static class SyntaxFieldMappings {

        @XmlElement(name = "field-map", namespace = "urn:/velocity/objects", required = true)
        protected List<FieldMap> fieldMap;

        /**
         * Gets the value of the fieldMap property.
         * 
         * <p>
         * This accessor method returns a reference to the live list,
         * not a snapshot. Therefore any modification you make to the
         * returned list will be present inside the JAXB object.
         * This is why there is not a <CODE>set</CODE> method for the fieldMap property.
         * 
         * <p>
         * For example, to add a new item, do as follows:
         * <pre>
         *    getFieldMap().add(newItem);
         * </pre>
         * 
         * 
         * <p>
         * Objects of the following type(s) are allowed in the list
         * {@link FieldMap }
         * 
         * 
         */
        public List<FieldMap> getFieldMap() {
            if (fieldMap == null) {
                fieldMap = new ArrayList<FieldMap>();
            }
            return this.fieldMap;
        }

    }

}
