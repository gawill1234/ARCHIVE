
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
 *         &lt;element name="activity-feed" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="add-cgi-string" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="atomic-vse-key-delete-mode" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="audit-log" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="audit-log-detail" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="audit-log-when" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="authority-rows" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="auto-vacuum" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="cache-size" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="cache-types" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="crawl-strategy" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="crawled-rows" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="delete-reusable" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="deletes-rows" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="disable-duplicates" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="disable-exact-duplicates" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="disable-indexes" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="disable-resume" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="disable-stats" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="disable-url-normalization" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="dns-cache-size" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="dns-keep-ms" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="duplicates-hash-size" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="enable-link-analysis" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="enqueue-high-water" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="enqueue-low-water" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="enqueue-offline-queue" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="events-rows" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="exact-duplicates-hash-size" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="fast-resume" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="fast-stop" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="fast-vertex-reuse" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="fetch-cache-dir" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="final-period" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="full-merge" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="gen-deletes" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="graph-rows" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="host-rows" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="idle-running-time" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="inputs-rows" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="java-parser-initial-heap" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="java-parser-max-heap" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="light-crawler-delete-mode" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="link-analysis-period" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="link-extractor-queue-size" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="max-input-urls" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="max-running-time" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="max-urls" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="n-delay-queue" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="n-dns-queue" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="n-dns-workers" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="n-exec-worker" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="n-fetch-queue" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="n-fetch-threads" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="n-indexer-output-queue" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="n-input-queue" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="n-link-extractor" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="n-output-queue" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="n-per-delay-queue" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="offline-batch-size" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="offline-buffered-resume" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="output-dir" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="page-size" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="pipeline-sample" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="pipeline-statistics" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="profile-dump" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="read-only-running-time" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="recrawl-errors" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="refresh" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="remote-clients" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="remote-debug-file" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="remote-debug-level" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="remote-exclusive" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="remote-force-rebase" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="remote-ignore-seeds" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="remote-listener-port" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="remote-name" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="remote-priorities" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="remote-range" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="remote-rebase-server" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="remote-reconnect-sleep" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="remote-requested" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="remote-serve-self" type="{http://www.w3.org/2001/XMLSchema}boolean" minOccurs="0"/>
 *         &lt;element name="remote-served" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="remote-servers" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="remote-timeout" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="remove-cgi-parameters" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="resume" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="rich-cache-types" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="seedless" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="startup-timeout" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="state-rows" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="status-final" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="status-period" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="status-rows" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="synchronous" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="test-it-mode" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="thread-debug-file" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="throttle-kbs-in" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="throttle-kbs-out" type="{http://www.w3.org/2001/XMLSchema}double" minOccurs="0"/>
 *         &lt;element name="transaction-memory" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="transaction-size" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="uncrawled-expires" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
 *         &lt;element name="url-list" type="{http://www.w3.org/2001/XMLSchema}string" minOccurs="0"/>
 *         &lt;element name="urls-rows" type="{http://www.w3.org/2001/XMLSchema}int" minOccurs="0"/>
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
    "activityFeed",
    "addCgiString",
    "atomicVseKeyDeleteMode",
    "auditLog",
    "auditLogDetail",
    "auditLogWhen",
    "authorityRows",
    "autoVacuum",
    "cacheSize",
    "cacheTypes",
    "crawlStrategy",
    "crawledRows",
    "deleteReusable",
    "deletesRows",
    "disableDuplicates",
    "disableExactDuplicates",
    "disableIndexes",
    "disableResume",
    "disableStats",
    "disableUrlNormalization",
    "dnsCacheSize",
    "dnsKeepMs",
    "duplicatesHashSize",
    "enableLinkAnalysis",
    "enqueueHighWater",
    "enqueueLowWater",
    "enqueueOfflineQueue",
    "eventsRows",
    "exactDuplicatesHashSize",
    "fastResume",
    "fastStop",
    "fastVertexReuse",
    "fetchCacheDir",
    "finalPeriod",
    "fullMerge",
    "genDeletes",
    "graphRows",
    "hostRows",
    "idleRunningTime",
    "inputsRows",
    "javaParserInitialHeap",
    "javaParserMaxHeap",
    "lightCrawlerDeleteMode",
    "linkAnalysisPeriod",
    "linkExtractorQueueSize",
    "maxInputUrls",
    "maxRunningTime",
    "maxUrls",
    "nDelayQueue",
    "nDnsQueue",
    "nDnsWorkers",
    "nExecWorker",
    "nFetchQueue",
    "nFetchThreads",
    "nIndexerOutputQueue",
    "nInputQueue",
    "nLinkExtractor",
    "nOutputQueue",
    "nPerDelayQueue",
    "offlineBatchSize",
    "offlineBufferedResume",
    "outputDir",
    "pageSize",
    "pipelineSample",
    "pipelineStatistics",
    "profileDump",
    "readOnlyRunningTime",
    "recrawlErrors",
    "refresh",
    "remoteClients",
    "remoteDebugFile",
    "remoteDebugLevel",
    "remoteExclusive",
    "remoteForceRebase",
    "remoteIgnoreSeeds",
    "remoteListenerPort",
    "remoteName",
    "remotePriorities",
    "remoteRange",
    "remoteRebaseServer",
    "remoteReconnectSleep",
    "remoteRequested",
    "remoteServeSelf",
    "remoteServed",
    "remoteServers",
    "remoteTimeout",
    "removeCgiParameters",
    "resume",
    "richCacheTypes",
    "seedless",
    "startupTimeout",
    "stateRows",
    "statusFinal",
    "statusPeriod",
    "statusRows",
    "synchronous",
    "testItMode",
    "threadDebugFile",
    "throttleKbsIn",
    "throttleKbsOut",
    "transactionMemory",
    "transactionSize",
    "uncrawledExpires",
    "urlList",
    "urlsRows"
})
@XmlRootElement(name = "crawl-option")
public class CrawlOption {

    @XmlElement(name = "activity-feed", defaultValue = "disabled")
    protected String activityFeed;
    @XmlElement(name = "add-cgi-string")
    protected String addCgiString;
    @XmlElement(name = "atomic-vse-key-delete-mode", defaultValue = "true")
    protected java.lang.Boolean atomicVseKeyDeleteMode;
    @XmlElement(name = "audit-log", defaultValue = "none")
    protected String auditLog;
    @XmlElement(name = "audit-log-detail", defaultValue = "full")
    protected String auditLogDetail;
    @XmlElement(name = "audit-log-when", defaultValue = "finished")
    protected String auditLogWhen;
    @XmlElement(name = "authority-rows", defaultValue = "1024")
    protected Integer authorityRows;
    @XmlElement(name = "auto-vacuum", defaultValue = "OFF")
    protected String autoVacuum;
    @XmlElement(name = "cache-size", defaultValue = "32")
    protected Integer cacheSize;
    @XmlElement(name = "cache-types", defaultValue = "text/html text/plain text/xml application/vxml-unnormalized application/vxml")
    protected String cacheTypes;
    @XmlElement(name = "crawl-strategy", defaultValue = "BFS")
    protected String crawlStrategy;
    @XmlElement(name = "crawled-rows", defaultValue = "1024")
    protected Integer crawledRows;
    @XmlElement(name = "delete-reusable", defaultValue = "false")
    protected java.lang.Boolean deleteReusable;
    @XmlElement(name = "deletes-rows", defaultValue = "1024")
    protected Integer deletesRows;
    @XmlElement(name = "disable-duplicates", defaultValue = "false")
    protected java.lang.Boolean disableDuplicates;
    @XmlElement(name = "disable-exact-duplicates", defaultValue = "false")
    protected java.lang.Boolean disableExactDuplicates;
    @XmlElement(name = "disable-indexes", defaultValue = "disable-index-sorting disable-url-index disable-error-state-index disable-crawl-time-index")
    protected String disableIndexes;
    @XmlElement(name = "disable-resume", defaultValue = "false")
    protected java.lang.Boolean disableResume;
    @XmlElement(name = "disable-stats", defaultValue = "none")
    protected String disableStats;
    @XmlElement(name = "disable-url-normalization", defaultValue = "false")
    protected java.lang.Boolean disableUrlNormalization;
    @XmlElement(name = "dns-cache-size", defaultValue = "100000")
    protected Integer dnsCacheSize;
    @XmlElement(name = "dns-keep-ms", defaultValue = "43200000")
    protected Integer dnsKeepMs;
    @XmlElement(name = "duplicates-hash-size", defaultValue = "2097023")
    protected Integer duplicatesHashSize;
    @XmlElement(name = "enable-link-analysis", defaultValue = "false")
    protected java.lang.Boolean enableLinkAnalysis;
    @XmlElement(name = "enqueue-high-water", defaultValue = "20000")
    protected Integer enqueueHighWater;
    @XmlElement(name = "enqueue-low-water", defaultValue = "10000")
    protected Integer enqueueLowWater;
    @XmlElement(name = "enqueue-offline-queue", defaultValue = "false")
    protected java.lang.Boolean enqueueOfflineQueue;
    @XmlElement(name = "events-rows", defaultValue = "128")
    protected Integer eventsRows;
    @XmlElement(name = "exact-duplicates-hash-size", defaultValue = "2097023")
    protected Integer exactDuplicatesHashSize;
    @XmlElement(name = "fast-resume", defaultValue = "ON")
    protected String fastResume;
    @XmlElement(name = "fast-stop", defaultValue = "ON")
    protected String fastStop;
    @XmlElement(name = "fast-vertex-reuse", defaultValue = "false")
    protected java.lang.Boolean fastVertexReuse;
    @XmlElement(name = "fetch-cache-dir")
    protected String fetchCacheDir;
    @XmlElement(name = "final-period", defaultValue = "30")
    protected Integer finalPeriod;
    @XmlElement(name = "full-merge", defaultValue = "false")
    protected java.lang.Boolean fullMerge;
    @XmlElement(name = "gen-deletes", defaultValue = "true")
    protected java.lang.Boolean genDeletes;
    @XmlElement(name = "graph-rows", defaultValue = "8192")
    protected Integer graphRows;
    @XmlElement(name = "host-rows", defaultValue = "1024")
    protected Integer hostRows;
    @XmlElement(name = "idle-running-time", defaultValue = "0")
    protected Integer idleRunningTime;
    @XmlElement(name = "inputs-rows", defaultValue = "1024")
    protected Integer inputsRows;
    @XmlElement(name = "java-parser-initial-heap", defaultValue = "0")
    protected Integer javaParserInitialHeap;
    @XmlElement(name = "java-parser-max-heap", defaultValue = "0")
    protected Integer javaParserMaxHeap;
    @XmlElement(name = "light-crawler-delete-mode", defaultValue = "false")
    protected java.lang.Boolean lightCrawlerDeleteMode;
    @XmlElement(name = "link-analysis-period", defaultValue = "3600")
    protected Integer linkAnalysisPeriod;
    @XmlElement(name = "link-extractor-queue-size", defaultValue = "10")
    protected Integer linkExtractorQueueSize;
    @XmlElement(name = "max-input-urls", defaultValue = "-1")
    protected Integer maxInputUrls;
    @XmlElement(name = "max-running-time", defaultValue = "-1")
    protected Integer maxRunningTime;
    @XmlElement(name = "max-urls", defaultValue = "-1")
    protected Integer maxUrls;
    @XmlElement(name = "n-delay-queue", defaultValue = "10")
    protected Integer nDelayQueue;
    @XmlElement(name = "n-dns-queue", defaultValue = "10")
    protected Integer nDnsQueue;
    @XmlElement(name = "n-dns-workers", defaultValue = "5")
    protected Integer nDnsWorkers;
    @XmlElement(name = "n-exec-worker", defaultValue = "1")
    protected Integer nExecWorker;
    @XmlElement(name = "n-fetch-queue", defaultValue = "10")
    protected Integer nFetchQueue;
    @XmlElement(name = "n-fetch-threads", defaultValue = "50")
    protected Integer nFetchThreads;
    @XmlElement(name = "n-indexer-output-queue", defaultValue = "2")
    protected Integer nIndexerOutputQueue;
    @XmlElement(name = "n-input-queue", defaultValue = "10000")
    protected Integer nInputQueue;
    @XmlElement(name = "n-link-extractor", defaultValue = "2 1")
    protected String nLinkExtractor;
    @XmlElement(name = "n-output-queue", defaultValue = "2")
    protected Integer nOutputQueue;
    @XmlElement(name = "n-per-delay-queue", defaultValue = "10")
    protected Integer nPerDelayQueue;
    @XmlElement(name = "offline-batch-size", defaultValue = "1000")
    protected Integer offlineBatchSize;
    @XmlElement(name = "offline-buffered-resume", defaultValue = "false")
    protected java.lang.Boolean offlineBufferedResume;
    @XmlElement(name = "output-dir")
    protected String outputDir;
    @XmlElement(name = "page-size", defaultValue = "4096")
    protected Integer pageSize;
    @XmlElement(name = "pipeline-sample", defaultValue = "0")
    protected Integer pipelineSample;
    @XmlElement(name = "pipeline-statistics", defaultValue = "false")
    protected java.lang.Boolean pipelineStatistics;
    @XmlElement(name = "profile-dump", defaultValue = "0")
    protected Integer profileDump;
    @XmlElement(name = "read-only-running-time", defaultValue = "0")
    protected Integer readOnlyRunningTime;
    @XmlElement(name = "recrawl-errors", defaultValue = "false")
    protected java.lang.Boolean recrawlErrors;
    @XmlElement(defaultValue = "-1")
    protected Integer refresh;
    @XmlElement(name = "remote-clients")
    protected String remoteClients;
    @XmlElement(name = "remote-debug-file", defaultValue = "null-default")
    protected String remoteDebugFile;
    @XmlElement(name = "remote-debug-level", defaultValue = "0")
    protected Integer remoteDebugLevel;
    @XmlElement(name = "remote-exclusive", defaultValue = "true")
    protected java.lang.Boolean remoteExclusive;
    @XmlElement(name = "remote-force-rebase", defaultValue = "false")
    protected java.lang.Boolean remoteForceRebase;
    @XmlElement(name = "remote-ignore-seeds", defaultValue = "false")
    protected java.lang.Boolean remoteIgnoreSeeds;
    @XmlElement(name = "remote-listener-port", defaultValue = "-1")
    protected Integer remoteListenerPort;
    @XmlElement(name = "remote-name")
    protected String remoteName;
    @XmlElement(name = "remote-priorities")
    protected String remotePriorities;
    @XmlElement(name = "remote-range", defaultValue = "1")
    protected Integer remoteRange;
    @XmlElement(name = "remote-rebase-server")
    protected String remoteRebaseServer;
    @XmlElement(name = "remote-reconnect-sleep", defaultValue = "5")
    protected Integer remoteReconnectSleep;
    @XmlElement(name = "remote-requested")
    protected String remoteRequested;
    @XmlElement(name = "remote-serve-self", defaultValue = "false")
    protected java.lang.Boolean remoteServeSelf;
    @XmlElement(name = "remote-served")
    protected String remoteServed;
    @XmlElement(name = "remote-servers")
    protected String remoteServers;
    @XmlElement(name = "remote-timeout", defaultValue = "120")
    protected Integer remoteTimeout;
    @XmlElement(name = "remove-cgi-parameters")
    protected String removeCgiParameters;
    @XmlElement(defaultValue = "-1")
    protected Integer resume;
    @XmlElement(name = "rich-cache-types", defaultValue = "")
    protected String richCacheTypes;
    protected String seedless;
    @XmlElement(name = "startup-timeout", defaultValue = "30")
    protected Integer startupTimeout;
    @XmlElement(name = "state-rows", defaultValue = "4096")
    protected Integer stateRows;
    @XmlElement(name = "status-final")
    protected String statusFinal;
    @XmlElement(name = "status-period", defaultValue = "0")
    protected Integer statusPeriod;
    @XmlElement(name = "status-rows", defaultValue = "512")
    protected Integer statusRows;
    @XmlElement(defaultValue = "NORMAL")
    protected String synchronous;
    @XmlElement(name = "test-it-mode", defaultValue = "0")
    protected Integer testItMode;
    @XmlElement(name = "thread-debug-file")
    protected String threadDebugFile;
    @XmlElement(name = "throttle-kbs-in", defaultValue = "0")
    protected Double throttleKbsIn;
    @XmlElement(name = "throttle-kbs-out", defaultValue = "0")
    protected Double throttleKbsOut;
    @XmlElement(name = "transaction-memory", defaultValue = "64")
    protected Integer transactionMemory;
    @XmlElement(name = "transaction-size", defaultValue = "1024")
    protected Integer transactionSize;
    @XmlElement(name = "uncrawled-expires", defaultValue = "0")
    protected Integer uncrawledExpires;
    @XmlElement(name = "url-list")
    protected String urlList;
    @XmlElement(name = "urls-rows", defaultValue = "1024")
    protected Integer urlsRows;

    /**
     * Gets the value of the activityFeed property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getActivityFeed() {
        return activityFeed;
    }

    /**
     * Sets the value of the activityFeed property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setActivityFeed(String value) {
        this.activityFeed = value;
    }

    /**
     * Gets the value of the addCgiString property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAddCgiString() {
        return addCgiString;
    }

    /**
     * Sets the value of the addCgiString property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAddCgiString(String value) {
        this.addCgiString = value;
    }

    /**
     * Gets the value of the atomicVseKeyDeleteMode property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isAtomicVseKeyDeleteMode() {
        return atomicVseKeyDeleteMode;
    }

    /**
     * Sets the value of the atomicVseKeyDeleteMode property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setAtomicVseKeyDeleteMode(java.lang.Boolean value) {
        this.atomicVseKeyDeleteMode = value;
    }

    /**
     * Gets the value of the auditLog property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAuditLog() {
        return auditLog;
    }

    /**
     * Sets the value of the auditLog property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAuditLog(String value) {
        this.auditLog = value;
    }

    /**
     * Gets the value of the auditLogDetail property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAuditLogDetail() {
        return auditLogDetail;
    }

    /**
     * Sets the value of the auditLogDetail property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAuditLogDetail(String value) {
        this.auditLogDetail = value;
    }

    /**
     * Gets the value of the auditLogWhen property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAuditLogWhen() {
        return auditLogWhen;
    }

    /**
     * Sets the value of the auditLogWhen property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAuditLogWhen(String value) {
        this.auditLogWhen = value;
    }

    /**
     * Gets the value of the authorityRows property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getAuthorityRows() {
        return authorityRows;
    }

    /**
     * Sets the value of the authorityRows property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setAuthorityRows(Integer value) {
        this.authorityRows = value;
    }

    /**
     * Gets the value of the autoVacuum property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getAutoVacuum() {
        return autoVacuum;
    }

    /**
     * Sets the value of the autoVacuum property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setAutoVacuum(String value) {
        this.autoVacuum = value;
    }

    /**
     * Gets the value of the cacheSize property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getCacheSize() {
        return cacheSize;
    }

    /**
     * Sets the value of the cacheSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setCacheSize(Integer value) {
        this.cacheSize = value;
    }

    /**
     * Gets the value of the cacheTypes property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCacheTypes() {
        return cacheTypes;
    }

    /**
     * Sets the value of the cacheTypes property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCacheTypes(String value) {
        this.cacheTypes = value;
    }

    /**
     * Gets the value of the crawlStrategy property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCrawlStrategy() {
        return crawlStrategy;
    }

    /**
     * Sets the value of the crawlStrategy property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCrawlStrategy(String value) {
        this.crawlStrategy = value;
    }

    /**
     * Gets the value of the crawledRows property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getCrawledRows() {
        return crawledRows;
    }

    /**
     * Sets the value of the crawledRows property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setCrawledRows(Integer value) {
        this.crawledRows = value;
    }

    /**
     * Gets the value of the deleteReusable property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isDeleteReusable() {
        return deleteReusable;
    }

    /**
     * Sets the value of the deleteReusable property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setDeleteReusable(java.lang.Boolean value) {
        this.deleteReusable = value;
    }

    /**
     * Gets the value of the deletesRows property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getDeletesRows() {
        return deletesRows;
    }

    /**
     * Sets the value of the deletesRows property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setDeletesRows(Integer value) {
        this.deletesRows = value;
    }

    /**
     * Gets the value of the disableDuplicates property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isDisableDuplicates() {
        return disableDuplicates;
    }

    /**
     * Sets the value of the disableDuplicates property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setDisableDuplicates(java.lang.Boolean value) {
        this.disableDuplicates = value;
    }

    /**
     * Gets the value of the disableExactDuplicates property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isDisableExactDuplicates() {
        return disableExactDuplicates;
    }

    /**
     * Sets the value of the disableExactDuplicates property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setDisableExactDuplicates(java.lang.Boolean value) {
        this.disableExactDuplicates = value;
    }

    /**
     * Gets the value of the disableIndexes property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDisableIndexes() {
        return disableIndexes;
    }

    /**
     * Sets the value of the disableIndexes property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDisableIndexes(String value) {
        this.disableIndexes = value;
    }

    /**
     * Gets the value of the disableResume property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isDisableResume() {
        return disableResume;
    }

    /**
     * Sets the value of the disableResume property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setDisableResume(java.lang.Boolean value) {
        this.disableResume = value;
    }

    /**
     * Gets the value of the disableStats property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDisableStats() {
        return disableStats;
    }

    /**
     * Sets the value of the disableStats property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDisableStats(String value) {
        this.disableStats = value;
    }

    /**
     * Gets the value of the disableUrlNormalization property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isDisableUrlNormalization() {
        return disableUrlNormalization;
    }

    /**
     * Sets the value of the disableUrlNormalization property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setDisableUrlNormalization(java.lang.Boolean value) {
        this.disableUrlNormalization = value;
    }

    /**
     * Gets the value of the dnsCacheSize property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getDnsCacheSize() {
        return dnsCacheSize;
    }

    /**
     * Sets the value of the dnsCacheSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setDnsCacheSize(Integer value) {
        this.dnsCacheSize = value;
    }

    /**
     * Gets the value of the dnsKeepMs property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getDnsKeepMs() {
        return dnsKeepMs;
    }

    /**
     * Sets the value of the dnsKeepMs property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setDnsKeepMs(Integer value) {
        this.dnsKeepMs = value;
    }

    /**
     * Gets the value of the duplicatesHashSize property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getDuplicatesHashSize() {
        return duplicatesHashSize;
    }

    /**
     * Sets the value of the duplicatesHashSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setDuplicatesHashSize(Integer value) {
        this.duplicatesHashSize = value;
    }

    /**
     * Gets the value of the enableLinkAnalysis property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isEnableLinkAnalysis() {
        return enableLinkAnalysis;
    }

    /**
     * Sets the value of the enableLinkAnalysis property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setEnableLinkAnalysis(java.lang.Boolean value) {
        this.enableLinkAnalysis = value;
    }

    /**
     * Gets the value of the enqueueHighWater property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getEnqueueHighWater() {
        return enqueueHighWater;
    }

    /**
     * Sets the value of the enqueueHighWater property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setEnqueueHighWater(Integer value) {
        this.enqueueHighWater = value;
    }

    /**
     * Gets the value of the enqueueLowWater property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getEnqueueLowWater() {
        return enqueueLowWater;
    }

    /**
     * Sets the value of the enqueueLowWater property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setEnqueueLowWater(Integer value) {
        this.enqueueLowWater = value;
    }

    /**
     * Gets the value of the enqueueOfflineQueue property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isEnqueueOfflineQueue() {
        return enqueueOfflineQueue;
    }

    /**
     * Sets the value of the enqueueOfflineQueue property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setEnqueueOfflineQueue(java.lang.Boolean value) {
        this.enqueueOfflineQueue = value;
    }

    /**
     * Gets the value of the eventsRows property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getEventsRows() {
        return eventsRows;
    }

    /**
     * Sets the value of the eventsRows property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setEventsRows(Integer value) {
        this.eventsRows = value;
    }

    /**
     * Gets the value of the exactDuplicatesHashSize property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getExactDuplicatesHashSize() {
        return exactDuplicatesHashSize;
    }

    /**
     * Sets the value of the exactDuplicatesHashSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setExactDuplicatesHashSize(Integer value) {
        this.exactDuplicatesHashSize = value;
    }

    /**
     * Gets the value of the fastResume property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFastResume() {
        return fastResume;
    }

    /**
     * Sets the value of the fastResume property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFastResume(String value) {
        this.fastResume = value;
    }

    /**
     * Gets the value of the fastStop property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFastStop() {
        return fastStop;
    }

    /**
     * Sets the value of the fastStop property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFastStop(String value) {
        this.fastStop = value;
    }

    /**
     * Gets the value of the fastVertexReuse property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isFastVertexReuse() {
        return fastVertexReuse;
    }

    /**
     * Sets the value of the fastVertexReuse property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setFastVertexReuse(java.lang.Boolean value) {
        this.fastVertexReuse = value;
    }

    /**
     * Gets the value of the fetchCacheDir property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getFetchCacheDir() {
        return fetchCacheDir;
    }

    /**
     * Sets the value of the fetchCacheDir property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setFetchCacheDir(String value) {
        this.fetchCacheDir = value;
    }

    /**
     * Gets the value of the finalPeriod property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getFinalPeriod() {
        return finalPeriod;
    }

    /**
     * Sets the value of the finalPeriod property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setFinalPeriod(Integer value) {
        this.finalPeriod = value;
    }

    /**
     * Gets the value of the fullMerge property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isFullMerge() {
        return fullMerge;
    }

    /**
     * Sets the value of the fullMerge property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setFullMerge(java.lang.Boolean value) {
        this.fullMerge = value;
    }

    /**
     * Gets the value of the genDeletes property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isGenDeletes() {
        return genDeletes;
    }

    /**
     * Sets the value of the genDeletes property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setGenDeletes(java.lang.Boolean value) {
        this.genDeletes = value;
    }

    /**
     * Gets the value of the graphRows property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getGraphRows() {
        return graphRows;
    }

    /**
     * Sets the value of the graphRows property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setGraphRows(Integer value) {
        this.graphRows = value;
    }

    /**
     * Gets the value of the hostRows property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getHostRows() {
        return hostRows;
    }

    /**
     * Sets the value of the hostRows property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setHostRows(Integer value) {
        this.hostRows = value;
    }

    /**
     * Gets the value of the idleRunningTime property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getIdleRunningTime() {
        return idleRunningTime;
    }

    /**
     * Sets the value of the idleRunningTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setIdleRunningTime(Integer value) {
        this.idleRunningTime = value;
    }

    /**
     * Gets the value of the inputsRows property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getInputsRows() {
        return inputsRows;
    }

    /**
     * Sets the value of the inputsRows property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setInputsRows(Integer value) {
        this.inputsRows = value;
    }

    /**
     * Gets the value of the javaParserInitialHeap property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getJavaParserInitialHeap() {
        return javaParserInitialHeap;
    }

    /**
     * Sets the value of the javaParserInitialHeap property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setJavaParserInitialHeap(Integer value) {
        this.javaParserInitialHeap = value;
    }

    /**
     * Gets the value of the javaParserMaxHeap property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getJavaParserMaxHeap() {
        return javaParserMaxHeap;
    }

    /**
     * Sets the value of the javaParserMaxHeap property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setJavaParserMaxHeap(Integer value) {
        this.javaParserMaxHeap = value;
    }

    /**
     * Gets the value of the lightCrawlerDeleteMode property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isLightCrawlerDeleteMode() {
        return lightCrawlerDeleteMode;
    }

    /**
     * Sets the value of the lightCrawlerDeleteMode property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setLightCrawlerDeleteMode(java.lang.Boolean value) {
        this.lightCrawlerDeleteMode = value;
    }

    /**
     * Gets the value of the linkAnalysisPeriod property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getLinkAnalysisPeriod() {
        return linkAnalysisPeriod;
    }

    /**
     * Sets the value of the linkAnalysisPeriod property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setLinkAnalysisPeriod(Integer value) {
        this.linkAnalysisPeriod = value;
    }

    /**
     * Gets the value of the linkExtractorQueueSize property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getLinkExtractorQueueSize() {
        return linkExtractorQueueSize;
    }

    /**
     * Sets the value of the linkExtractorQueueSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setLinkExtractorQueueSize(Integer value) {
        this.linkExtractorQueueSize = value;
    }

    /**
     * Gets the value of the maxInputUrls property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaxInputUrls() {
        return maxInputUrls;
    }

    /**
     * Sets the value of the maxInputUrls property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxInputUrls(Integer value) {
        this.maxInputUrls = value;
    }

    /**
     * Gets the value of the maxRunningTime property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaxRunningTime() {
        return maxRunningTime;
    }

    /**
     * Sets the value of the maxRunningTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxRunningTime(Integer value) {
        this.maxRunningTime = value;
    }

    /**
     * Gets the value of the maxUrls property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getMaxUrls() {
        return maxUrls;
    }

    /**
     * Sets the value of the maxUrls property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setMaxUrls(Integer value) {
        this.maxUrls = value;
    }

    /**
     * Gets the value of the nDelayQueue property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNDelayQueue() {
        return nDelayQueue;
    }

    /**
     * Sets the value of the nDelayQueue property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNDelayQueue(Integer value) {
        this.nDelayQueue = value;
    }

    /**
     * Gets the value of the nDnsQueue property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNDnsQueue() {
        return nDnsQueue;
    }

    /**
     * Sets the value of the nDnsQueue property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNDnsQueue(Integer value) {
        this.nDnsQueue = value;
    }

    /**
     * Gets the value of the nDnsWorkers property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNDnsWorkers() {
        return nDnsWorkers;
    }

    /**
     * Sets the value of the nDnsWorkers property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNDnsWorkers(Integer value) {
        this.nDnsWorkers = value;
    }

    /**
     * Gets the value of the nExecWorker property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNExecWorker() {
        return nExecWorker;
    }

    /**
     * Sets the value of the nExecWorker property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNExecWorker(Integer value) {
        this.nExecWorker = value;
    }

    /**
     * Gets the value of the nFetchQueue property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNFetchQueue() {
        return nFetchQueue;
    }

    /**
     * Sets the value of the nFetchQueue property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNFetchQueue(Integer value) {
        this.nFetchQueue = value;
    }

    /**
     * Gets the value of the nFetchThreads property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNFetchThreads() {
        return nFetchThreads;
    }

    /**
     * Sets the value of the nFetchThreads property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNFetchThreads(Integer value) {
        this.nFetchThreads = value;
    }

    /**
     * Gets the value of the nIndexerOutputQueue property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNIndexerOutputQueue() {
        return nIndexerOutputQueue;
    }

    /**
     * Sets the value of the nIndexerOutputQueue property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNIndexerOutputQueue(Integer value) {
        this.nIndexerOutputQueue = value;
    }

    /**
     * Gets the value of the nInputQueue property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNInputQueue() {
        return nInputQueue;
    }

    /**
     * Sets the value of the nInputQueue property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNInputQueue(Integer value) {
        this.nInputQueue = value;
    }

    /**
     * Gets the value of the nLinkExtractor property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getNLinkExtractor() {
        return nLinkExtractor;
    }

    /**
     * Sets the value of the nLinkExtractor property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setNLinkExtractor(String value) {
        this.nLinkExtractor = value;
    }

    /**
     * Gets the value of the nOutputQueue property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNOutputQueue() {
        return nOutputQueue;
    }

    /**
     * Sets the value of the nOutputQueue property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNOutputQueue(Integer value) {
        this.nOutputQueue = value;
    }

    /**
     * Gets the value of the nPerDelayQueue property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getNPerDelayQueue() {
        return nPerDelayQueue;
    }

    /**
     * Sets the value of the nPerDelayQueue property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setNPerDelayQueue(Integer value) {
        this.nPerDelayQueue = value;
    }

    /**
     * Gets the value of the offlineBatchSize property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getOfflineBatchSize() {
        return offlineBatchSize;
    }

    /**
     * Sets the value of the offlineBatchSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setOfflineBatchSize(Integer value) {
        this.offlineBatchSize = value;
    }

    /**
     * Gets the value of the offlineBufferedResume property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isOfflineBufferedResume() {
        return offlineBufferedResume;
    }

    /**
     * Sets the value of the offlineBufferedResume property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setOfflineBufferedResume(java.lang.Boolean value) {
        this.offlineBufferedResume = value;
    }

    /**
     * Gets the value of the outputDir property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOutputDir() {
        return outputDir;
    }

    /**
     * Sets the value of the outputDir property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOutputDir(String value) {
        this.outputDir = value;
    }

    /**
     * Gets the value of the pageSize property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getPageSize() {
        return pageSize;
    }

    /**
     * Sets the value of the pageSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setPageSize(Integer value) {
        this.pageSize = value;
    }

    /**
     * Gets the value of the pipelineSample property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getPipelineSample() {
        return pipelineSample;
    }

    /**
     * Sets the value of the pipelineSample property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setPipelineSample(Integer value) {
        this.pipelineSample = value;
    }

    /**
     * Gets the value of the pipelineStatistics property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isPipelineStatistics() {
        return pipelineStatistics;
    }

    /**
     * Sets the value of the pipelineStatistics property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setPipelineStatistics(java.lang.Boolean value) {
        this.pipelineStatistics = value;
    }

    /**
     * Gets the value of the profileDump property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getProfileDump() {
        return profileDump;
    }

    /**
     * Sets the value of the profileDump property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setProfileDump(Integer value) {
        this.profileDump = value;
    }

    /**
     * Gets the value of the readOnlyRunningTime property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getReadOnlyRunningTime() {
        return readOnlyRunningTime;
    }

    /**
     * Sets the value of the readOnlyRunningTime property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setReadOnlyRunningTime(Integer value) {
        this.readOnlyRunningTime = value;
    }

    /**
     * Gets the value of the recrawlErrors property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isRecrawlErrors() {
        return recrawlErrors;
    }

    /**
     * Sets the value of the recrawlErrors property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setRecrawlErrors(java.lang.Boolean value) {
        this.recrawlErrors = value;
    }

    /**
     * Gets the value of the refresh property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRefresh() {
        return refresh;
    }

    /**
     * Sets the value of the refresh property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRefresh(Integer value) {
        this.refresh = value;
    }

    /**
     * Gets the value of the remoteClients property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemoteClients() {
        return remoteClients;
    }

    /**
     * Sets the value of the remoteClients property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemoteClients(String value) {
        this.remoteClients = value;
    }

    /**
     * Gets the value of the remoteDebugFile property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemoteDebugFile() {
        return remoteDebugFile;
    }

    /**
     * Sets the value of the remoteDebugFile property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemoteDebugFile(String value) {
        this.remoteDebugFile = value;
    }

    /**
     * Gets the value of the remoteDebugLevel property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRemoteDebugLevel() {
        return remoteDebugLevel;
    }

    /**
     * Sets the value of the remoteDebugLevel property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRemoteDebugLevel(Integer value) {
        this.remoteDebugLevel = value;
    }

    /**
     * Gets the value of the remoteExclusive property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isRemoteExclusive() {
        return remoteExclusive;
    }

    /**
     * Sets the value of the remoteExclusive property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setRemoteExclusive(java.lang.Boolean value) {
        this.remoteExclusive = value;
    }

    /**
     * Gets the value of the remoteForceRebase property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isRemoteForceRebase() {
        return remoteForceRebase;
    }

    /**
     * Sets the value of the remoteForceRebase property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setRemoteForceRebase(java.lang.Boolean value) {
        this.remoteForceRebase = value;
    }

    /**
     * Gets the value of the remoteIgnoreSeeds property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isRemoteIgnoreSeeds() {
        return remoteIgnoreSeeds;
    }

    /**
     * Sets the value of the remoteIgnoreSeeds property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setRemoteIgnoreSeeds(java.lang.Boolean value) {
        this.remoteIgnoreSeeds = value;
    }

    /**
     * Gets the value of the remoteListenerPort property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRemoteListenerPort() {
        return remoteListenerPort;
    }

    /**
     * Sets the value of the remoteListenerPort property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRemoteListenerPort(Integer value) {
        this.remoteListenerPort = value;
    }

    /**
     * Gets the value of the remoteName property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemoteName() {
        return remoteName;
    }

    /**
     * Sets the value of the remoteName property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemoteName(String value) {
        this.remoteName = value;
    }

    /**
     * Gets the value of the remotePriorities property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemotePriorities() {
        return remotePriorities;
    }

    /**
     * Sets the value of the remotePriorities property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemotePriorities(String value) {
        this.remotePriorities = value;
    }

    /**
     * Gets the value of the remoteRange property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRemoteRange() {
        return remoteRange;
    }

    /**
     * Sets the value of the remoteRange property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRemoteRange(Integer value) {
        this.remoteRange = value;
    }

    /**
     * Gets the value of the remoteRebaseServer property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemoteRebaseServer() {
        return remoteRebaseServer;
    }

    /**
     * Sets the value of the remoteRebaseServer property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemoteRebaseServer(String value) {
        this.remoteRebaseServer = value;
    }

    /**
     * Gets the value of the remoteReconnectSleep property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRemoteReconnectSleep() {
        return remoteReconnectSleep;
    }

    /**
     * Sets the value of the remoteReconnectSleep property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRemoteReconnectSleep(Integer value) {
        this.remoteReconnectSleep = value;
    }

    /**
     * Gets the value of the remoteRequested property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemoteRequested() {
        return remoteRequested;
    }

    /**
     * Sets the value of the remoteRequested property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemoteRequested(String value) {
        this.remoteRequested = value;
    }

    /**
     * Gets the value of the remoteServeSelf property.
     * 
     * @return
     *     possible object is
     *     {@link java.lang.Boolean }
     *     
     */
    public java.lang.Boolean isRemoteServeSelf() {
        return remoteServeSelf;
    }

    /**
     * Sets the value of the remoteServeSelf property.
     * 
     * @param value
     *     allowed object is
     *     {@link java.lang.Boolean }
     *     
     */
    public void setRemoteServeSelf(java.lang.Boolean value) {
        this.remoteServeSelf = value;
    }

    /**
     * Gets the value of the remoteServed property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemoteServed() {
        return remoteServed;
    }

    /**
     * Sets the value of the remoteServed property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemoteServed(String value) {
        this.remoteServed = value;
    }

    /**
     * Gets the value of the remoteServers property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemoteServers() {
        return remoteServers;
    }

    /**
     * Sets the value of the remoteServers property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemoteServers(String value) {
        this.remoteServers = value;
    }

    /**
     * Gets the value of the remoteTimeout property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getRemoteTimeout() {
        return remoteTimeout;
    }

    /**
     * Sets the value of the remoteTimeout property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setRemoteTimeout(Integer value) {
        this.remoteTimeout = value;
    }

    /**
     * Gets the value of the removeCgiParameters property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRemoveCgiParameters() {
        return removeCgiParameters;
    }

    /**
     * Sets the value of the removeCgiParameters property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRemoveCgiParameters(String value) {
        this.removeCgiParameters = value;
    }

    /**
     * Gets the value of the resume property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getResume() {
        return resume;
    }

    /**
     * Sets the value of the resume property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setResume(Integer value) {
        this.resume = value;
    }

    /**
     * Gets the value of the richCacheTypes property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getRichCacheTypes() {
        return richCacheTypes;
    }

    /**
     * Sets the value of the richCacheTypes property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setRichCacheTypes(String value) {
        this.richCacheTypes = value;
    }

    /**
     * Gets the value of the seedless property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSeedless() {
        return seedless;
    }

    /**
     * Sets the value of the seedless property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSeedless(String value) {
        this.seedless = value;
    }

    /**
     * Gets the value of the startupTimeout property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getStartupTimeout() {
        return startupTimeout;
    }

    /**
     * Sets the value of the startupTimeout property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setStartupTimeout(Integer value) {
        this.startupTimeout = value;
    }

    /**
     * Gets the value of the stateRows property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getStateRows() {
        return stateRows;
    }

    /**
     * Sets the value of the stateRows property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setStateRows(Integer value) {
        this.stateRows = value;
    }

    /**
     * Gets the value of the statusFinal property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getStatusFinal() {
        return statusFinal;
    }

    /**
     * Sets the value of the statusFinal property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setStatusFinal(String value) {
        this.statusFinal = value;
    }

    /**
     * Gets the value of the statusPeriod property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getStatusPeriod() {
        return statusPeriod;
    }

    /**
     * Sets the value of the statusPeriod property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setStatusPeriod(Integer value) {
        this.statusPeriod = value;
    }

    /**
     * Gets the value of the statusRows property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getStatusRows() {
        return statusRows;
    }

    /**
     * Sets the value of the statusRows property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setStatusRows(Integer value) {
        this.statusRows = value;
    }

    /**
     * Gets the value of the synchronous property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSynchronous() {
        return synchronous;
    }

    /**
     * Sets the value of the synchronous property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSynchronous(String value) {
        this.synchronous = value;
    }

    /**
     * Gets the value of the testItMode property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getTestItMode() {
        return testItMode;
    }

    /**
     * Sets the value of the testItMode property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setTestItMode(Integer value) {
        this.testItMode = value;
    }

    /**
     * Gets the value of the threadDebugFile property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getThreadDebugFile() {
        return threadDebugFile;
    }

    /**
     * Sets the value of the threadDebugFile property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setThreadDebugFile(String value) {
        this.threadDebugFile = value;
    }

    /**
     * Gets the value of the throttleKbsIn property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getThrottleKbsIn() {
        return throttleKbsIn;
    }

    /**
     * Sets the value of the throttleKbsIn property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setThrottleKbsIn(Double value) {
        this.throttleKbsIn = value;
    }

    /**
     * Gets the value of the throttleKbsOut property.
     * 
     * @return
     *     possible object is
     *     {@link Double }
     *     
     */
    public Double getThrottleKbsOut() {
        return throttleKbsOut;
    }

    /**
     * Sets the value of the throttleKbsOut property.
     * 
     * @param value
     *     allowed object is
     *     {@link Double }
     *     
     */
    public void setThrottleKbsOut(Double value) {
        this.throttleKbsOut = value;
    }

    /**
     * Gets the value of the transactionMemory property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getTransactionMemory() {
        return transactionMemory;
    }

    /**
     * Sets the value of the transactionMemory property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setTransactionMemory(Integer value) {
        this.transactionMemory = value;
    }

    /**
     * Gets the value of the transactionSize property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getTransactionSize() {
        return transactionSize;
    }

    /**
     * Sets the value of the transactionSize property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setTransactionSize(Integer value) {
        this.transactionSize = value;
    }

    /**
     * Gets the value of the uncrawledExpires property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getUncrawledExpires() {
        return uncrawledExpires;
    }

    /**
     * Sets the value of the uncrawledExpires property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setUncrawledExpires(Integer value) {
        this.uncrawledExpires = value;
    }

    /**
     * Gets the value of the urlList property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getUrlList() {
        return urlList;
    }

    /**
     * Sets the value of the urlList property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setUrlList(String value) {
        this.urlList = value;
    }

    /**
     * Gets the value of the urlsRows property.
     * 
     * @return
     *     possible object is
     *     {@link Integer }
     *     
     */
    public Integer getUrlsRows() {
        return urlsRows;
    }

    /**
     * Sets the value of the urlsRows property.
     * 
     * @param value
     *     allowed object is
     *     {@link Integer }
     *     
     */
    public void setUrlsRows(Integer value) {
        this.urlsRows = value;
    }

}
