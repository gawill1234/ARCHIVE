
package velocity.objects;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlAnyAttribute;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlSchemaType;
import javax.xml.bind.annotation.XmlType;
import javax.xml.datatype.XMLGregorianCalendar;
import javax.xml.namespace.QName;


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
 *         &lt;element ref="{urn:/velocity/objects}crawl-pipeline"/>
 *         &lt;element ref="{urn:/velocity/objects}curl-options"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-header"/>
 *         &lt;element ref="{urn:/velocity/objects}old-crawl"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-links"/>
 *         &lt;element ref="{urn:/velocity/objects}completed-crawl"/>
 *         &lt;element ref="{urn:/velocity/objects}indexed-crawl"/>
 *         &lt;element ref="{urn:/velocity/objects}log"/>
 *         &lt;element ref="{urn:/velocity/objects}crawl-data" maxOccurs="unbounded"/>
 *       &lt;/sequence>
 *       &lt;attGroup ref="{urn:/velocity/objects}crawl-url-internal"/>
 *       &lt;attribute name="url" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="redir-from" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="redir-to" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="state">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="pending"/>
 *             &lt;enumeration value="success"/>
 *             &lt;enumeration value="warning"/>
 *             &lt;enumeration value="error"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="status" default="none">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="starting"/>
 *             &lt;enumeration value="applying changes"/>
 *             &lt;enumeration value="stopping"/>
 *             &lt;enumeration value="refreshing"/>
 *             &lt;enumeration value="resuming"/>
 *             &lt;enumeration value="input"/>
 *             &lt;enumeration value="complete"/>
 *             &lt;enumeration value="redir"/>
 *             &lt;enumeration value="disallowed by robots.txt"/>
 *             &lt;enumeration value="filtered"/>
 *             &lt;enumeration value="error"/>
 *             &lt;enumeration value="duplicate"/>
 *             &lt;enumeration value="killed"/>
 *             &lt;enumeration value="none"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="output-destination">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="cache"/>
 *             &lt;enumeration value="indexer"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="http-status" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="input-at" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="recorded-at" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="at-datetime" type="{http://www.w3.org/2001/XMLSchema}dateTime" />
 *       &lt;attribute name="at" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="filetime" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="batch-id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="change-id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="input-purged" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="content-type" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="size" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="n-sub" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="conversion-time" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="converted-size" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="speed" type="{http://www.w3.org/2001/XMLSchema}double" />
 *       &lt;attribute name="error" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="warning" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="hops" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="vertex" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="exact" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="error-msg" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="exact-duplicate">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="exact-duplicate"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="verbose">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="verbose"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="uncrawled">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="unexpired"/>
 *             &lt;enumeration value="unchanged"/>
 *             &lt;enumeration value="error"/>
 *             &lt;enumeration value="unknown"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="uncrawled-why" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="crawled-locally">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="crawled-locally"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="priority" type="{http://www.w3.org/2001/XMLSchema}int" default="0" />
 *       &lt;attribute name="input-priority" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="default-acl" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="ip" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="i-ip" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="forced-vse-key" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="forced-vse-key-normalized">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="forced-vse-key-normalized"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="synchronization" default="enqueued">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="none"/>
 *             &lt;enumeration value="enqueued"/>
 *             &lt;enumeration value="to-be-indexed"/>
 *             &lt;enumeration value="indexed"/>
 *             &lt;enumeration value="indexed-no-sync"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="force-indexed-sync" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="enqueue-id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="originator" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="arena" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="parent-url" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="parent-url-normalized">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="parent-url-normalized"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="remote-time" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="remote-dependent">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="delete"/>
 *             &lt;enumeration value="uncrawled"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="remote-previous-collection" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="remote-previous-counter" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="remote-depend-collection" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="remote-depend-counter" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="remote-collection-id" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="siphoned">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="duplicate"/>
 *             &lt;enumeration value="killed"/>
 *             &lt;enumeration value="filtered"/>
 *             &lt;enumeration value="terminated"/>
 *             &lt;enumeration value="unexpired"/>
 *             &lt;enumeration value="uncrawled"/>
 *             &lt;enumeration value="unchanged"/>
 *             &lt;enumeration value="error"/>
 *             &lt;enumeration value="unretrievable"/>
 *             &lt;enumeration value="rebasing"/>
 *             &lt;enumeration value="replaced"/>
 *             &lt;enumeration value="input-full"/>
 *             &lt;enumeration value="needed-gatekeeper"/>
 *             &lt;enumeration value="aborted"/>
 *             &lt;enumeration value="nonexistent"/>
 *             &lt;enumeration value="invalid"/>
 *             &lt;enumeration value="lc-too-long"/>
 *             &lt;enumeration value="unknown"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="enqueued-offline">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="enqueued-offline"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="orphaned-atomic">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="orphaned-atomic"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="enqueue-type" default="none">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="none"/>
 *             &lt;enumeration value="forced"/>
 *             &lt;enumeration value="reenqueued"/>
 *             &lt;enumeration value="export"/>
 *             &lt;enumeration value="status"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="deleted" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="ignore-expires" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="enqueued" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="referrer-vertex" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="remote-collection" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="remote-counter" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="remote-packet-id" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="referree-url" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="request-queue-redir">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="output"/>
 *             &lt;enumeration value="indexer-output"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="prodder">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="abort"/>
 *             &lt;enumeration value="index"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="gatekeeper-action">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="reject"/>
 *             &lt;enumeration value="replace"/>
 *             &lt;enumeration value="add-to-queue"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="index-atomically" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="gatekeeper-list" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="gatekeeper-id" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="offline-id" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="offline-initialize" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="input-on-resume" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *       &lt;attribute name="switched-status" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *       &lt;attribute name="from-input" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="input-stub" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="re-events" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="remembered" type="{http://www.w3.org/2001/XMLSchema}boolean" />
 *       &lt;attribute name="notify-id" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="reply-id" type="{http://www.w3.org/2001/XMLSchema}int" />
 *       &lt;attribute name="obey-no-follow" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="normalized" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="url-normalized" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="wait-on-enqueued" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;attribute name="graph-id-high-water" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="last-at" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="indexed-n-docs" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="indexed-n-contents" type="{http://www.w3.org/2001/XMLSchema}unsignedInt" />
 *       &lt;attribute name="indexed-n-bytes" type="{http://www.w3.org/2001/XMLSchema}long" />
 *       &lt;attribute name="light-crawler">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="light-crawler"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="remove-xml-data">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="always"/>
 *             &lt;enumeration value="on-success"/>
 *             &lt;enumeration value="input"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="disguised-delete">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="disguised-delete"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="remote-counter-increased">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="remote-counter-increased"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="delete-enqueue-id" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="delete-originator" type="{http://www.w3.org/2001/XMLSchema}string" />
 *       &lt;attribute name="delete-index-atomically">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="delete-index-atomically"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="purge-pending">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="purge-pending"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="only-input" type="{http://www.w3.org/2001/XMLSchema}anySimpleType" />
 *       &lt;anyAttribute processContents='lax'/>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "", propOrder = {
    "crawlPipeline",
    "curlOptions",
    "crawlHeader",
    "oldCrawl",
    "crawlLinks",
    "completedCrawl",
    "indexedCrawl",
    "log",
    "crawlData"
})
@XmlRootElement(name = "crawl-url")
public class CrawlUrl {

    @XmlElement(name = "crawl-pipeline", required = true)
    protected CrawlPipeline crawlPipeline;
    @XmlElement(name = "curl-options", required = true)
    protected CurlOptions curlOptions;
    @XmlElement(name = "crawl-header", required = true)
    protected String crawlHeader;
    @XmlElement(name = "old-crawl", required = true)
    protected OldCrawl oldCrawl;
    @XmlElement(name = "crawl-links", required = true)
    protected CrawlLinks crawlLinks;
    @XmlElement(name = "completed-crawl", required = true)
    protected CompletedCrawl completedCrawl;
    @XmlElement(name = "indexed-crawl", required = true)
    protected IndexedCrawl indexedCrawl;
    @XmlElement(required = true)
    protected Log log;
    @XmlElement(name = "crawl-data", required = true)
    protected List<CrawlData> crawlData;
    @XmlAttribute
    protected String url;
    @XmlAttribute(name = "redir-from")
    protected String redirFrom;
    @XmlAttribute(name = "redir-to")
    protected String redirTo;
    @XmlAttribute
    protected String state;
    @XmlAttribute
    protected String status;
    @XmlAttribute(name = "output-destination")
    protected String outputDestination;
    @XmlAttribute(name = "http-status")
    protected Long httpStatus;
    @XmlAttribute(name = "input-at")
    protected Long inputAt;
    @XmlAttribute(name = "recorded-at")
    protected Long recordedAt;
    @XmlAttribute(name = "at-datetime")
    @XmlSchemaType(name = "dateTime")
    protected XMLGregorianCalendar atDatetime;
    @XmlAttribute
    protected Long at;
    @XmlAttribute
    protected Long filetime;
    @XmlAttribute(name = "batch-id")
    protected String batchId;
    @XmlAttribute(name = "change-id")
    protected String changeId;
    @XmlAttribute(name = "input-purged")
    @XmlSchemaType(name = "anySimpleType")
    protected String inputPurged;
    @XmlAttribute(name = "content-type")
    protected String contentType;
    @XmlAttribute
    protected Long size;
    @XmlAttribute(name = "n-sub")
    protected Integer nSub;
    @XmlAttribute(name = "conversion-time")
    protected Integer conversionTime;
    @XmlAttribute(name = "converted-size")
    protected Double convertedSize;
    @XmlAttribute
    protected Double speed;
    @XmlAttribute
    protected String error;
    @XmlAttribute
    protected String warning;
    @XmlAttribute
    protected Integer hops;
    @XmlAttribute
    @XmlSchemaType(name = "unsignedInt")
    protected Long vertex;
    @XmlAttribute
    protected String exact;
    @XmlAttribute(name = "error-msg")
    protected String errorMsg;
    @XmlAttribute(name = "exact-duplicate")
    protected String exactDuplicate;
    @XmlAttribute
    protected String verbose;
    @XmlAttribute
    protected String uncrawled;
    @XmlAttribute(name = "uncrawled-why")
    protected String uncrawledWhy;
    @XmlAttribute(name = "crawled-locally")
    protected String crawledLocally;
    @XmlAttribute
    protected Integer priority;
    @XmlAttribute(name = "input-priority")
    protected Integer inputPriority;
    @XmlAttribute(name = "default-acl")
    protected String defaultAcl;
    @XmlAttribute
    protected String ip;
    @XmlAttribute(name = "i-ip")
    protected Integer iIp;
    @XmlAttribute(name = "forced-vse-key")
    protected String forcedVseKey;
    @XmlAttribute(name = "forced-vse-key-normalized")
    protected String forcedVseKeyNormalized;
    @XmlAttribute
    protected String synchronization;
    @XmlAttribute(name = "force-indexed-sync")
    @XmlSchemaType(name = "anySimpleType")
    protected String forceIndexedSync;
    @XmlAttribute(name = "enqueue-id")
    protected String enqueueId;
    @XmlAttribute
    protected String originator;
    @XmlAttribute
    protected String arena;
    @XmlAttribute(name = "parent-url")
    protected String parentUrl;
    @XmlAttribute(name = "parent-url-normalized")
    protected String parentUrlNormalized;
    @XmlAttribute(name = "remote-time")
    protected Long remoteTime;
    @XmlAttribute(name = "remote-dependent")
    protected String remoteDependent;
    @XmlAttribute(name = "remote-previous-collection")
    protected String remotePreviousCollection;
    @XmlAttribute(name = "remote-previous-counter")
    protected Integer remotePreviousCounter;
    @XmlAttribute(name = "remote-depend-collection")
    protected String remoteDependCollection;
    @XmlAttribute(name = "remote-depend-counter")
    protected Integer remoteDependCounter;
    @XmlAttribute(name = "remote-collection-id")
    protected Integer remoteCollectionId;
    @XmlAttribute
    protected String siphoned;
    @XmlAttribute(name = "enqueued-offline")
    protected String enqueuedOffline;
    @XmlAttribute(name = "orphaned-atomic")
    protected String orphanedAtomic;
    @XmlAttribute(name = "enqueue-type")
    protected String enqueueType;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String deleted;
    @XmlAttribute(name = "ignore-expires")
    @XmlSchemaType(name = "anySimpleType")
    protected String ignoreExpires;
    @XmlAttribute
    protected String enqueued;
    @XmlAttribute(name = "referrer-vertex")
    protected Integer referrerVertex;
    @XmlAttribute(name = "remote-collection")
    protected String remoteCollection;
    @XmlAttribute(name = "remote-counter")
    protected Integer remoteCounter;
    @XmlAttribute(name = "remote-packet-id")
    protected Integer remotePacketId;
    @XmlAttribute(name = "referree-url")
    protected String referreeUrl;
    @XmlAttribute(name = "request-queue-redir")
    protected String requestQueueRedir;
    @XmlAttribute
    protected String prodder;
    @XmlAttribute(name = "gatekeeper-action")
    protected String gatekeeperAction;
    @XmlAttribute(name = "index-atomically")
    @XmlSchemaType(name = "anySimpleType")
    protected String indexAtomically;
    @XmlAttribute(name = "gatekeeper-list")
    @XmlSchemaType(name = "anySimpleType")
    protected String gatekeeperList;
    @XmlAttribute(name = "gatekeeper-id")
    @XmlSchemaType(name = "unsignedInt")
    protected Long gatekeeperId;
    @XmlAttribute(name = "offline-id")
    @XmlSchemaType(name = "unsignedInt")
    protected Long offlineId;
    @XmlAttribute(name = "offline-initialize")
    @XmlSchemaType(name = "anySimpleType")
    protected String offlineInitialize;
    @XmlAttribute(name = "input-on-resume")
    protected java.lang.Boolean inputOnResume;
    @XmlAttribute(name = "switched-status")
    protected java.lang.Boolean switchedStatus;
    @XmlAttribute(name = "from-input")
    @XmlSchemaType(name = "anySimpleType")
    protected String fromInput;
    @XmlAttribute(name = "input-stub")
    @XmlSchemaType(name = "anySimpleType")
    protected String inputStub;
    @XmlAttribute(name = "re-events")
    protected Integer reEvents;
    @XmlAttribute
    protected java.lang.Boolean remembered;
    @XmlAttribute(name = "notify-id")
    protected Integer notifyId;
    @XmlAttribute(name = "reply-id")
    protected Integer replyId;
    @XmlAttribute(name = "obey-no-follow")
    @XmlSchemaType(name = "anySimpleType")
    protected String obeyNoFollow;
    @XmlAttribute
    @XmlSchemaType(name = "anySimpleType")
    protected String normalized;
    @XmlAttribute(name = "url-normalized")
    @XmlSchemaType(name = "anySimpleType")
    protected String urlNormalized;
    @XmlAttribute(name = "wait-on-enqueued")
    @XmlSchemaType(name = "anySimpleType")
    protected String waitOnEnqueued;
    @XmlAttribute(name = "graph-id-high-water")
    @XmlSchemaType(name = "unsignedInt")
    protected Long graphIdHighWater;
    @XmlAttribute(name = "last-at")
    protected Long lastAt;
    @XmlAttribute(name = "indexed-n-docs")
    @XmlSchemaType(name = "unsignedInt")
    protected Long indexedNDocs;
    @XmlAttribute(name = "indexed-n-contents")
    @XmlSchemaType(name = "unsignedInt")
    protected Long indexedNContents;
    @XmlAttribute(name = "indexed-n-bytes")
    protected Long indexedNBytes;
    @XmlAttribute(name = "light-crawler")
    protected String lightCrawler;
    @XmlAttribute(name = "remove-xml-data")
    protected String removeXmlData;
    @XmlAttribute(name = "disguised-delete")
    protected String disguisedDelete;
    @XmlAttribute(name = "remote-counter-increased")
    protected String remoteCounterIncreased;
    @XmlAttribute(name = "delete-enqueue-id")
    protected String deleteEnqueueId;
    @XmlAttribute(name = "delete-originator")
    protected String deleteOriginator;
    @XmlAttribute(name = "delete-index-atomically")
    protected String deleteIndexAtomically;
    @XmlAttribute(name = "purge-pending")
    protected String purgePending;
    @XmlAttribute(name = "only-input")
    @XmlSchemaType(name = "anySimpleType")
    protected String onlyInput;
    @XmlAttribute(name = "__internal__")
    protected String internal;
    @XmlAttribute(name = "n-redirs")
    protected Integer nRedirs;
    @XmlAttribute(name = "orig-url")
    protected String origUrl;
    @XmlAnyAttribute
    private Map<QName, String> otherAttributes = new HashMap<QName, String>();

    /**
     * Gets the value of the crawlPipeline property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlPipeline }
     *     
     */
    public CrawlPipeline getCrawlPipeline() {
        return crawlPipeline;
    }

    /**
     * Sets the value of the crawlPipeline property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlPipeline }
     *     
     */
    public void setCrawlPipeline(CrawlPipeline value) {
        this.crawlPipeline = value;
    }

    /**
     * Gets the value of the curlOptions property.
     * 
     * @return
     *     possible object is
     *     {@link CurlOptions }
     *     
     */
    public CurlOptions getCurlOptions() {
        return curlOptions;
    }

    /**
     * Sets the value of the curlOptions property.
     * 
     * @param value
     *     allowed object is
     *     {@link CurlOptions }
     *     
     */
    public void setCurlOptions(CurlOptions value) {
        this.curlOptions = value;
    }

    /**
     * Gets the value of the crawlHeader property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCrawlHeader() {
        return crawlHeader;
    }

    /**
     * Sets the value of the crawlHeader property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCrawlHeader(String value) {
        this.crawlHeader = value;
    }

    /**
     * Gets the value of the oldCrawl property.
     * 
     * @return
     *     possible object is
     *     {@link OldCrawl }
     *     
     */
    public OldCrawl getOldCrawl() {
        return oldCrawl;
    }

    /**
     * Sets the value of the oldCrawl property.
     * 
     * @param value
     *     allowed object is
     *     {@link OldCrawl }
     *     
     */
    public void setOldCrawl(OldCrawl value) {
        this.oldCrawl = value;
    }

    /**
     * Gets the value of the crawlLinks property.
     * 
     * @return
     *     possible object is
     *     {@link CrawlLinks }
     *     
     */
    public CrawlLinks getCrawlLinks() {
        return crawlLinks;
    }

    /**
     * Sets the value of the crawlLinks property.
     * 
     * @param value
     *     allowed object is
     *     {@link CrawlLinks }
     *     
     */
    public void setCrawlLinks(CrawlLinks value) {
        this.crawlLinks = value;
    }

    /**
     * Gets the value of the completedCrawl property.
     * 
     * @return
     *     possible object is
     *     {@link CompletedCrawl }
     *     
     */
    public CompletedCrawl getCompletedCrawl() {
        return completedCrawl;
    }

    /**
     * Sets the value of the completedCrawl property.
     * 
     * @param value
     *     allowed object is
     *     {@link CompletedCrawl }
     *     
     */
    public void setCompletedCrawl(CompletedCrawl value) {
        this.completedCrawl = value;
    }

    /**
     * Gets the value of the indexedCrawl property.
     * 
     * @return
     *     possible object is
     *     {@link IndexedCrawl }
     *     
     */
    public IndexedCrawl getIndexedCrawl() {
        return indexedCrawl;
    }

    /**
     * Sets the value of the indexedCrawl property.
     * 
     * @param value
     *     allowed object is
     *     {@link IndexedCrawl }
     *     
     */
    public void setIndexedCrawl(IndexedCrawl value) {
        this.indexedCrawl = value;
    }

    /**
     * Gets the value of the log property.
     * 
     * @return
     *     possible object is
     *     {@link Log }
     *     
     */
    public Log getLog() {
        return log;
    }

    /**
     * Sets the value of the log property.
     * 
     * @param value
     *     allowed object is
     *     {@link Log }
     *     
     */
    public void setLog(Log value) {
        this.log = value;
    }

    /**
     * Gets the value of the crawlData property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the crawlData property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getCrawlData().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link CrawlData }
     * 
     * 
     */
    public List<CrawlData> getCrawlData() {
        if (crawlData == null) {
            crawlData = new ArrayList<CrawlData>();
        }
        return this.crawlData;
    }

    /**
     * Gets the value of the url property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUrl() {
        return url;
    }

    /**
     * Sets the value of the url property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUrl(String value) {
        this.url = value;
    }

    /**
     * Gets the value of the redirFrom property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRedirFrom() {
        return redirFrom;
    }

    /**
     * Sets the value of the redirFrom property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRedirFrom(String value) {
        this.redirFrom = value;
    }

    /**
     * Gets the value of the redirTo property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRedirTo() {
        return redirTo;
    }

    /**
     * Sets the value of the redirTo property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRedirTo(String value) {
        this.redirTo = value;
    }

    /**
     * Gets the value of the state property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getState() {
        return state;
    }

    /**
     * Sets the value of the state property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setState(String value) {
        this.state = value;
    }

    /**
     * Gets the value of the status property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStatus() {
        if (status == null) {
            return "none";
        } else {
            return status;
        }
    }

    /**
     * Sets the value of the status property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStatus(String value) {
        this.status = value;
    }

    /**
     * Gets the value of the outputDestination property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOutputDestination() {
        return outputDestination;
    }

    /**
     * Sets the value of the outputDestination property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOutputDestination(String value) {
        this.outputDestination = value;
    }

    /**
     * Gets the value of the httpStatus property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getHttpStatus() {
        return httpStatus;
    }

    /**
     * Sets the value of the httpStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setHttpStatus(Long value) {
        this.httpStatus = value;
    }

    /**
     * Gets the value of the inputAt property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getInputAt() {
        return inputAt;
    }

    /**
     * Sets the value of the inputAt property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setInputAt(Long value) {
        this.inputAt = value;
    }

    /**
     * Gets the value of the recordedAt property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getRecordedAt() {
        return recordedAt;
    }

    /**
     * Sets the value of the recordedAt property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setRecordedAt(Long value) {
        this.recordedAt = value;
    }

    /**
     * Gets the value of the atDatetime property.
     * 
     * @return
     *     possible object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public XMLGregorianCalendar getAtDatetime() {
        return atDatetime;
    }

    /**
     * Sets the value of the atDatetime property.
     * 
     * @param value
     *     allowed object is
     *     {@link XMLGregorianCalendar }
     *     
     */
    public void setAtDatetime(XMLGregorianCalendar value) {
        this.atDatetime = value;
    }

    /**
     * Gets the value of the at property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getAt() {
        return at;
    }

    /**
     * Sets the value of the at property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setAt(Long value) {
        this.at = value;
    }

    /**
     * Gets the value of the filetime property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getFiletime() {
        return filetime;
    }

    /**
     * Sets the value of the filetime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setFiletime(Long value) {
        this.filetime = value;
    }

    /**
     * Gets the value of the batchId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getBatchId() {
        return batchId;
    }

    /**
     * Sets the value of the batchId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setBatchId(String value) {
        this.batchId = value;
    }

    /**
     * Gets the value of the changeId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getChangeId() {
        return changeId;
    }

    /**
     * Sets the value of the changeId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setChangeId(String value) {
        this.changeId = value;
    }

    /**
     * Gets the value of the inputPurged property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getInputPurged() {
        return inputPurged;
    }

    /**
     * Sets the value of the inputPurged property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setInputPurged(String value) {
        this.inputPurged = value;
    }

    /**
     * Gets the value of the contentType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getContentType() {
        return contentType;
    }

    /**
     * Sets the value of the contentType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setContentType(String value) {
        this.contentType = value;
    }

    /**
     * Gets the value of the size property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getSize() {
        return size;
    }

    /**
     * Sets the value of the size property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setSize(Long value) {
        this.size = value;
    }

    /**
     * Gets the value of the nSub property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNSub() {
        return nSub;
    }

    /**
     * Sets the value of the nSub property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNSub(Integer value) {
        this.nSub = value;
    }

    /**
     * Gets the value of the conversionTime property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getConversionTime() {
        return conversionTime;
    }

    /**
     * Sets the value of the conversionTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setConversionTime(Integer value) {
        this.conversionTime = value;
    }

    /**
     * Gets the value of the convertedSize property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getConvertedSize() {
        return convertedSize;
    }

    /**
     * Sets the value of the convertedSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setConvertedSize(Double value) {
        this.convertedSize = value;
    }

    /**
     * Gets the value of the speed property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getSpeed() {
        return speed;
    }

    /**
     * Sets the value of the speed property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setSpeed(Double value) {
        this.speed = value;
    }

    /**
     * Gets the value of the error property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getError() {
        return error;
    }

    /**
     * Sets the value of the error property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setError(String value) {
        this.error = value;
    }

    /**
     * Gets the value of the warning property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getWarning() {
        return warning;
    }

    /**
     * Sets the value of the warning property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setWarning(String value) {
        this.warning = value;
    }

    /**
     * Gets the value of the hops property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getHops() {
        if (hops == null) {
            return  0;
        } else {
            return hops;
        }
    }

    /**
     * Sets the value of the hops property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setHops(Integer value) {
        this.hops = value;
    }

    /**
     * Gets the value of the vertex property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getVertex() {
        return vertex;
    }

    /**
     * Sets the value of the vertex property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setVertex(Long value) {
        this.vertex = value;
    }

    /**
     * Gets the value of the exact property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getExact() {
        return exact;
    }

    /**
     * Sets the value of the exact property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setExact(String value) {
        this.exact = value;
    }

    /**
     * Gets the value of the errorMsg property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getErrorMsg() {
        return errorMsg;
    }

    /**
     * Sets the value of the errorMsg property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setErrorMsg(String value) {
        this.errorMsg = value;
    }

    /**
     * Gets the value of the exactDuplicate property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getExactDuplicate() {
        return exactDuplicate;
    }

    /**
     * Sets the value of the exactDuplicate property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setExactDuplicate(String value) {
        this.exactDuplicate = value;
    }

    /**
     * Gets the value of the verbose property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getVerbose() {
        return verbose;
    }

    /**
     * Sets the value of the verbose property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setVerbose(String value) {
        this.verbose = value;
    }

    /**
     * Gets the value of the uncrawled property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUncrawled() {
        return uncrawled;
    }

    /**
     * Sets the value of the uncrawled property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUncrawled(String value) {
        this.uncrawled = value;
    }

    /**
     * Gets the value of the uncrawledWhy property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUncrawledWhy() {
        return uncrawledWhy;
    }

    /**
     * Sets the value of the uncrawledWhy property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUncrawledWhy(String value) {
        this.uncrawledWhy = value;
    }

    /**
     * Gets the value of the crawledLocally property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCrawledLocally() {
        return crawledLocally;
    }

    /**
     * Sets the value of the crawledLocally property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCrawledLocally(String value) {
        this.crawledLocally = value;
    }

    /**
     * Gets the value of the priority property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getPriority() {
        if (priority == null) {
            return  0;
        } else {
            return priority;
        }
    }

    /**
     * Sets the value of the priority property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setPriority(Integer value) {
        this.priority = value;
    }

    /**
     * Gets the value of the inputPriority property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getInputPriority() {
        return inputPriority;
    }

    /**
     * Sets the value of the inputPriority property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setInputPriority(Integer value) {
        this.inputPriority = value;
    }

    /**
     * Gets the value of the defaultAcl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDefaultAcl() {
        return defaultAcl;
    }

    /**
     * Sets the value of the defaultAcl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDefaultAcl(String value) {
        this.defaultAcl = value;
    }

    /**
     * Gets the value of the ip property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getIp() {
        return ip;
    }

    /**
     * Sets the value of the ip property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setIp(String value) {
        this.ip = value;
    }

    /**
     * Gets the value of the iIp property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getIIp() {
        return iIp;
    }

    /**
     * Sets the value of the iIp property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setIIp(Integer value) {
        this.iIp = value;
    }

    /**
     * Gets the value of the forcedVseKey property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getForcedVseKey() {
        return forcedVseKey;
    }

    /**
     * Sets the value of the forcedVseKey property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setForcedVseKey(String value) {
        this.forcedVseKey = value;
    }

    /**
     * Gets the value of the forcedVseKeyNormalized property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getForcedVseKeyNormalized() {
        return forcedVseKeyNormalized;
    }

    /**
     * Sets the value of the forcedVseKeyNormalized property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setForcedVseKeyNormalized(String value) {
        this.forcedVseKeyNormalized = value;
    }

    /**
     * Gets the value of the synchronization property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSynchronization() {
        if (synchronization == null) {
            return "enqueued";
        } else {
            return synchronization;
        }
    }

    /**
     * Sets the value of the synchronization property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSynchronization(String value) {
        this.synchronization = value;
    }

    /**
     * Gets the value of the forceIndexedSync property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getForceIndexedSync() {
        return forceIndexedSync;
    }

    /**
     * Sets the value of the forceIndexedSync property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setForceIndexedSync(String value) {
        this.forceIndexedSync = value;
    }

    /**
     * Gets the value of the enqueueId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEnqueueId() {
        return enqueueId;
    }

    /**
     * Sets the value of the enqueueId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEnqueueId(String value) {
        this.enqueueId = value;
    }

    /**
     * Gets the value of the originator property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOriginator() {
        return originator;
    }

    /**
     * Sets the value of the originator property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOriginator(String value) {
        this.originator = value;
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
     * Gets the value of the parentUrl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getParentUrl() {
        return parentUrl;
    }

    /**
     * Sets the value of the parentUrl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setParentUrl(String value) {
        this.parentUrl = value;
    }

    /**
     * Gets the value of the parentUrlNormalized property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getParentUrlNormalized() {
        return parentUrlNormalized;
    }

    /**
     * Sets the value of the parentUrlNormalized property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setParentUrlNormalized(String value) {
        this.parentUrlNormalized = value;
    }

    /**
     * Gets the value of the remoteTime property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getRemoteTime() {
        return remoteTime;
    }

    /**
     * Sets the value of the remoteTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setRemoteTime(Long value) {
        this.remoteTime = value;
    }

    /**
     * Gets the value of the remoteDependent property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemoteDependent() {
        return remoteDependent;
    }

    /**
     * Sets the value of the remoteDependent property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemoteDependent(String value) {
        this.remoteDependent = value;
    }

    /**
     * Gets the value of the remotePreviousCollection property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemotePreviousCollection() {
        return remotePreviousCollection;
    }

    /**
     * Sets the value of the remotePreviousCollection property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemotePreviousCollection(String value) {
        this.remotePreviousCollection = value;
    }

    /**
     * Gets the value of the remotePreviousCounter property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRemotePreviousCounter() {
        return remotePreviousCounter;
    }

    /**
     * Sets the value of the remotePreviousCounter property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRemotePreviousCounter(Integer value) {
        this.remotePreviousCounter = value;
    }

    /**
     * Gets the value of the remoteDependCollection property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemoteDependCollection() {
        return remoteDependCollection;
    }

    /**
     * Sets the value of the remoteDependCollection property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemoteDependCollection(String value) {
        this.remoteDependCollection = value;
    }

    /**
     * Gets the value of the remoteDependCounter property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRemoteDependCounter() {
        return remoteDependCounter;
    }

    /**
     * Sets the value of the remoteDependCounter property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRemoteDependCounter(Integer value) {
        this.remoteDependCounter = value;
    }

    /**
     * Gets the value of the remoteCollectionId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRemoteCollectionId() {
        return remoteCollectionId;
    }

    /**
     * Sets the value of the remoteCollectionId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRemoteCollectionId(Integer value) {
        this.remoteCollectionId = value;
    }

    /**
     * Gets the value of the siphoned property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSiphoned() {
        return siphoned;
    }

    /**
     * Sets the value of the siphoned property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSiphoned(String value) {
        this.siphoned = value;
    }

    /**
     * Gets the value of the enqueuedOffline property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEnqueuedOffline() {
        return enqueuedOffline;
    }

    /**
     * Sets the value of the enqueuedOffline property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEnqueuedOffline(String value) {
        this.enqueuedOffline = value;
    }

    /**
     * Gets the value of the orphanedAtomic property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOrphanedAtomic() {
        return orphanedAtomic;
    }

    /**
     * Sets the value of the orphanedAtomic property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOrphanedAtomic(String value) {
        this.orphanedAtomic = value;
    }

    /**
     * Gets the value of the enqueueType property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEnqueueType() {
        if (enqueueType == null) {
            return "none";
        } else {
            return enqueueType;
        }
    }

    /**
     * Sets the value of the enqueueType property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEnqueueType(String value) {
        this.enqueueType = value;
    }

    /**
     * Gets the value of the deleted property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDeleted() {
        return deleted;
    }

    /**
     * Sets the value of the deleted property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDeleted(String value) {
        this.deleted = value;
    }

    /**
     * Gets the value of the ignoreExpires property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getIgnoreExpires() {
        return ignoreExpires;
    }

    /**
     * Sets the value of the ignoreExpires property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setIgnoreExpires(String value) {
        this.ignoreExpires = value;
    }

    /**
     * Gets the value of the enqueued property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getEnqueued() {
        return enqueued;
    }

    /**
     * Sets the value of the enqueued property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setEnqueued(String value) {
        this.enqueued = value;
    }

    /**
     * Gets the value of the referrerVertex property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getReferrerVertex() {
        return referrerVertex;
    }

    /**
     * Sets the value of the referrerVertex property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setReferrerVertex(Integer value) {
        this.referrerVertex = value;
    }

    /**
     * Gets the value of the remoteCollection property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemoteCollection() {
        return remoteCollection;
    }

    /**
     * Sets the value of the remoteCollection property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemoteCollection(String value) {
        this.remoteCollection = value;
    }

    /**
     * Gets the value of the remoteCounter property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRemoteCounter() {
        return remoteCounter;
    }

    /**
     * Sets the value of the remoteCounter property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRemoteCounter(Integer value) {
        this.remoteCounter = value;
    }

    /**
     * Gets the value of the remotePacketId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRemotePacketId() {
        return remotePacketId;
    }

    /**
     * Sets the value of the remotePacketId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRemotePacketId(Integer value) {
        this.remotePacketId = value;
    }

    /**
     * Gets the value of the referreeUrl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getReferreeUrl() {
        return referreeUrl;
    }

    /**
     * Sets the value of the referreeUrl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setReferreeUrl(String value) {
        this.referreeUrl = value;
    }

    /**
     * Gets the value of the requestQueueRedir property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRequestQueueRedir() {
        return requestQueueRedir;
    }

    /**
     * Sets the value of the requestQueueRedir property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRequestQueueRedir(String value) {
        this.requestQueueRedir = value;
    }

    /**
     * Gets the value of the prodder property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getProdder() {
        return prodder;
    }

    /**
     * Sets the value of the prodder property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setProdder(String value) {
        this.prodder = value;
    }

    /**
     * Gets the value of the gatekeeperAction property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getGatekeeperAction() {
        return gatekeeperAction;
    }

    /**
     * Sets the value of the gatekeeperAction property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setGatekeeperAction(String value) {
        this.gatekeeperAction = value;
    }

    /**
     * Gets the value of the indexAtomically property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getIndexAtomically() {
        return indexAtomically;
    }

    /**
     * Sets the value of the indexAtomically property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setIndexAtomically(String value) {
        this.indexAtomically = value;
    }

    /**
     * Gets the value of the gatekeeperList property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getGatekeeperList() {
        return gatekeeperList;
    }

    /**
     * Sets the value of the gatekeeperList property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setGatekeeperList(String value) {
        this.gatekeeperList = value;
    }

    /**
     * Gets the value of the gatekeeperId property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getGatekeeperId() {
        return gatekeeperId;
    }

    /**
     * Sets the value of the gatekeeperId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setGatekeeperId(Long value) {
        this.gatekeeperId = value;
    }

    /**
     * Gets the value of the offlineId property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getOfflineId() {
        return offlineId;
    }

    /**
     * Sets the value of the offlineId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setOfflineId(Long value) {
        this.offlineId = value;
    }

    /**
     * Gets the value of the offlineInitialize property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOfflineInitialize() {
        return offlineInitialize;
    }

    /**
     * Sets the value of the offlineInitialize property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOfflineInitialize(String value) {
        this.offlineInitialize = value;
    }

    /**
     * Gets the value of the inputOnResume property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isInputOnResume() {
        return inputOnResume;
    }

    /**
     * Sets the value of the inputOnResume property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setInputOnResume(java.lang.Boolean value) {
        this.inputOnResume = value;
    }

    /**
     * Gets the value of the switchedStatus property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isSwitchedStatus() {
        return switchedStatus;
    }

    /**
     * Sets the value of the switchedStatus property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setSwitchedStatus(java.lang.Boolean value) {
        this.switchedStatus = value;
    }

    /**
     * Gets the value of the fromInput property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFromInput() {
        return fromInput;
    }

    /**
     * Sets the value of the fromInput property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFromInput(String value) {
        this.fromInput = value;
    }

    /**
     * Gets the value of the inputStub property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getInputStub() {
        return inputStub;
    }

    /**
     * Sets the value of the inputStub property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setInputStub(String value) {
        this.inputStub = value;
    }

    /**
     * Gets the value of the reEvents property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getReEvents() {
        return reEvents;
    }

    /**
     * Sets the value of the reEvents property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setReEvents(Integer value) {
        this.reEvents = value;
    }

    /**
     * Gets the value of the remembered property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isRemembered() {
        return remembered;
    }

    /**
     * Sets the value of the remembered property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setRemembered(java.lang.Boolean value) {
        this.remembered = value;
    }

    /**
     * Gets the value of the notifyId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNotifyId() {
        return notifyId;
    }

    /**
     * Sets the value of the notifyId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNotifyId(Integer value) {
        this.notifyId = value;
    }

    /**
     * Gets the value of the replyId property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getReplyId() {
        return replyId;
    }

    /**
     * Sets the value of the replyId property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setReplyId(Integer value) {
        this.replyId = value;
    }

    /**
     * Gets the value of the obeyNoFollow property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getObeyNoFollow() {
        return obeyNoFollow;
    }

    /**
     * Sets the value of the obeyNoFollow property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setObeyNoFollow(String value) {
        this.obeyNoFollow = value;
    }

    /**
     * Gets the value of the normalized property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNormalized() {
        return normalized;
    }

    /**
     * Sets the value of the normalized property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNormalized(String value) {
        this.normalized = value;
    }

    /**
     * Gets the value of the urlNormalized property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUrlNormalized() {
        return urlNormalized;
    }

    /**
     * Sets the value of the urlNormalized property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUrlNormalized(String value) {
        this.urlNormalized = value;
    }

    /**
     * Gets the value of the waitOnEnqueued property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getWaitOnEnqueued() {
        return waitOnEnqueued;
    }

    /**
     * Sets the value of the waitOnEnqueued property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setWaitOnEnqueued(String value) {
        this.waitOnEnqueued = value;
    }

    /**
     * Gets the value of the graphIdHighWater property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getGraphIdHighWater() {
        return graphIdHighWater;
    }

    /**
     * Sets the value of the graphIdHighWater property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setGraphIdHighWater(Long value) {
        this.graphIdHighWater = value;
    }

    /**
     * Gets the value of the lastAt property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getLastAt() {
        return lastAt;
    }

    /**
     * Sets the value of the lastAt property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setLastAt(Long value) {
        this.lastAt = value;
    }

    /**
     * Gets the value of the indexedNDocs property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getIndexedNDocs() {
        return indexedNDocs;
    }

    /**
     * Sets the value of the indexedNDocs property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setIndexedNDocs(Long value) {
        this.indexedNDocs = value;
    }

    /**
     * Gets the value of the indexedNContents property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getIndexedNContents() {
        return indexedNContents;
    }

    /**
     * Sets the value of the indexedNContents property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setIndexedNContents(Long value) {
        this.indexedNContents = value;
    }

    /**
     * Gets the value of the indexedNBytes property.
     * 
     * @return
     *     possible object is
     *     {@link Long }
     *     
     */
    public Long getIndexedNBytes() {
        return indexedNBytes;
    }

    /**
     * Sets the value of the indexedNBytes property.
     * 
     * @param value
     *     allowed object is
     *     {@link Long }
     *     
     */
    public void setIndexedNBytes(Long value) {
        this.indexedNBytes = value;
    }

    /**
     * Gets the value of the lightCrawler property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLightCrawler() {
        return lightCrawler;
    }

    /**
     * Sets the value of the lightCrawler property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLightCrawler(String value) {
        this.lightCrawler = value;
    }

    /**
     * Gets the value of the removeXmlData property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemoveXmlData() {
        return removeXmlData;
    }

    /**
     * Sets the value of the removeXmlData property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemoveXmlData(String value) {
        this.removeXmlData = value;
    }

    /**
     * Gets the value of the disguisedDelete property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDisguisedDelete() {
        return disguisedDelete;
    }

    /**
     * Sets the value of the disguisedDelete property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDisguisedDelete(String value) {
        this.disguisedDelete = value;
    }

    /**
     * Gets the value of the remoteCounterIncreased property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemoteCounterIncreased() {
        return remoteCounterIncreased;
    }

    /**
     * Sets the value of the remoteCounterIncreased property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemoteCounterIncreased(String value) {
        this.remoteCounterIncreased = value;
    }

    /**
     * Gets the value of the deleteEnqueueId property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDeleteEnqueueId() {
        return deleteEnqueueId;
    }

    /**
     * Sets the value of the deleteEnqueueId property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDeleteEnqueueId(String value) {
        this.deleteEnqueueId = value;
    }

    /**
     * Gets the value of the deleteOriginator property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDeleteOriginator() {
        return deleteOriginator;
    }

    /**
     * Sets the value of the deleteOriginator property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDeleteOriginator(String value) {
        this.deleteOriginator = value;
    }

    /**
     * Gets the value of the deleteIndexAtomically property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDeleteIndexAtomically() {
        return deleteIndexAtomically;
    }

    /**
     * Sets the value of the deleteIndexAtomically property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDeleteIndexAtomically(String value) {
        this.deleteIndexAtomically = value;
    }

    /**
     * Gets the value of the purgePending property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getPurgePending() {
        return purgePending;
    }

    /**
     * Sets the value of the purgePending property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setPurgePending(String value) {
        this.purgePending = value;
    }

    /**
     * Gets the value of the onlyInput property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOnlyInput() {
        return onlyInput;
    }

    /**
     * Sets the value of the onlyInput property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOnlyInput(String value) {
        this.onlyInput = value;
    }

    /**
     * Gets the value of the internal property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getInternal() {
        return internal;
    }

    /**
     * Sets the value of the internal property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setInternal(String value) {
        this.internal = value;
    }

    /**
     * Gets the value of the nRedirs property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public int getNRedirs() {
        if (nRedirs == null) {
            return  0;
        } else {
            return nRedirs;
        }
    }

    /**
     * Sets the value of the nRedirs property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNRedirs(Integer value) {
        this.nRedirs = value;
    }

    /**
     * Gets the value of the origUrl property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOrigUrl() {
        return origUrl;
    }

    /**
     * Sets the value of the origUrl property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOrigUrl(String value) {
        this.origUrl = value;
    }

    /**
     * Gets a map that contains attributes that aren't bound to any typed property on this class.
     * 
     * <p>
     * the map is keyed by the name of the attribute and 
     * the value is the string value of the attribute.
     * 
     * the map returned by this method is live, and you can add new attribute
     * by updating the map directly. Because of this design, there's no setter.
     * 
     * 
     * @return
     *     always non-null
     */
    public Map<QName, String> getOtherAttributes() {
        return otherAttributes;
    }

}
