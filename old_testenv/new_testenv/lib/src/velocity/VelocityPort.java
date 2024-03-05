
package velocity;

import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebResult;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.xml.bind.annotation.XmlSeeAlso;
import velocity.types.AlertListXml;
import velocity.types.AlertListXmlResponse;
import velocity.types.AlertRun;
import velocity.types.AlertServiceStart;
import velocity.types.AlertServiceStatusXml;
import velocity.types.AlertServiceStatusXmlResponse;
import velocity.types.AlertServiceStop;
import velocity.types.AnnotationAdd;
import velocity.types.AnnotationDelete;
import velocity.types.AnnotationExpressAddDocList;
import velocity.types.AnnotationExpressAddQuery;
import velocity.types.AnnotationExpressDeleteDocList;
import velocity.types.AnnotationExpressDeleteQuery;
import velocity.types.AnnotationExpressGlobalSetDocList;
import velocity.types.AnnotationExpressGlobalSetQuery;
import velocity.types.AnnotationExpressUpdateDocList;
import velocity.types.AnnotationExpressUpdateDocListResponse;
import velocity.types.AnnotationExpressUpdateQuery;
import velocity.types.AnnotationExpressUserSetDocList;
import velocity.types.AnnotationExpressUserSetQuery;
import velocity.types.AnnotationGlobalSet;
import velocity.types.AnnotationPermissions;
import velocity.types.AnnotationUpdate;
import velocity.types.AnnotationUserSet;
import velocity.types.AutoClassifyRefreshTags;
import velocity.types.AutocompleteSuggest;
import velocity.types.AutocompleteSuggestResponse;
import velocity.types.AxlServiceStatus;
import velocity.types.AxlServiceStatusResponse;
import velocity.types.CollectionBrokerAbortTransactions;
import velocity.types.CollectionBrokerCrawlerOfflineStatus;
import velocity.types.CollectionBrokerCrawlerOfflineStatusResponse;
import velocity.types.CollectionBrokerEnqueueXml;
import velocity.types.CollectionBrokerEnqueueXmlResponse;
import velocity.types.CollectionBrokerExportData;
import velocity.types.CollectionBrokerExportDataResponse;
import velocity.types.CollectionBrokerGet;
import velocity.types.CollectionBrokerGetResponse;
import velocity.types.CollectionBrokerIgnoreCollection;
import velocity.types.CollectionBrokerSearch;
import velocity.types.CollectionBrokerSearchResponse;
import velocity.types.CollectionBrokerSet;
import velocity.types.CollectionBrokerStart;
import velocity.types.CollectionBrokerStartCollection;
import velocity.types.CollectionBrokerStatus;
import velocity.types.CollectionBrokerStatusResponse;
import velocity.types.CollectionBrokerStop;
import velocity.types.CrawlerRuntimeOptions;
import velocity.types.DictionaryBuild;
import velocity.types.DictionaryCreate;
import velocity.types.DictionaryDelete;
import velocity.types.DictionaryListXml;
import velocity.types.DictionaryListXmlResponse;
import velocity.types.DictionaryReadFromCollection;
import velocity.types.DictionaryReadFromCollectionResponse;
import velocity.types.DictionaryStatusXml;
import velocity.types.DictionaryStatusXmlResponse;
import velocity.types.DictionaryStop;
import velocity.types.IndexerRuntimeOptions;
import velocity.types.Ping;
import velocity.types.PingResponse;
import velocity.types.QueryBrowse;
import velocity.types.QueryBrowseResponse;
import velocity.types.QueryCluster;
import velocity.types.QueryClusterResponse;
import velocity.types.QueryParse;
import velocity.types.QueryParseResponse;
import velocity.types.QuerySearch;
import velocity.types.QuerySearchResponse;
import velocity.types.QuerySimilarDocuments;
import velocity.types.QuerySimilarDocumentsResponse;
import velocity.types.ReportingCleanNow;
import velocity.types.ReportsEnqueue;
import velocity.types.ReportsResultsXml;
import velocity.types.ReportsResultsXmlResponse;
import velocity.types.ReportsRunNowXml;
import velocity.types.ReportsRunNowXmlResponse;
import velocity.types.ReportsStatusXml;
import velocity.types.ReportsStatusXmlResponse;
import velocity.types.ReportsStop;
import velocity.types.ReportsSystemReporting;
import velocity.types.ReportsSystemReportingResponse;
import velocity.types.RepositoryAdd;
import velocity.types.RepositoryDelete;
import velocity.types.RepositoryGet;
import velocity.types.RepositoryGetMd5;
import velocity.types.RepositoryGetMd5Response;
import velocity.types.RepositoryGetResponse;
import velocity.types.RepositoryListXml;
import velocity.types.RepositoryListXmlResponse;
import velocity.types.RepositoryUpdate;
import velocity.types.SchedulerJobs;
import velocity.types.SchedulerJobsResponse;
import velocity.types.SchedulerServiceStart;
import velocity.types.SchedulerServiceStatusXml;
import velocity.types.SchedulerServiceStatusXmlResponse;
import velocity.types.SchedulerServiceStop;
import velocity.types.SearchCollectionAbortTransactions;
import velocity.types.SearchCollectionAuditLogPurge;
import velocity.types.SearchCollectionAuditLogRetrieve;
import velocity.types.SearchCollectionAuditLogRetrieveResponse;
import velocity.types.SearchCollectionClean;
import velocity.types.SearchCollectionCrawlerRestart;
import velocity.types.SearchCollectionCrawlerStart;
import velocity.types.SearchCollectionCrawlerStop;
import velocity.types.SearchCollectionCreate;
import velocity.types.SearchCollectionDelete;
import velocity.types.SearchCollectionEnqueue;
import velocity.types.SearchCollectionEnqueueDeletes;
import velocity.types.SearchCollectionEnqueueDeletesResponse;
import velocity.types.SearchCollectionEnqueueResponse;
import velocity.types.SearchCollectionEnqueueUrl;
import velocity.types.SearchCollectionEnqueueUrlResponse;
import velocity.types.SearchCollectionEnqueueXml;
import velocity.types.SearchCollectionEnqueueXmlResponse;
import velocity.types.SearchCollectionIndexerFullMerge;
import velocity.types.SearchCollectionIndexerRestart;
import velocity.types.SearchCollectionIndexerStart;
import velocity.types.SearchCollectionIndexerStop;
import velocity.types.SearchCollectionListStatusXml;
import velocity.types.SearchCollectionListStatusXmlResponse;
import velocity.types.SearchCollectionListXml;
import velocity.types.SearchCollectionListXmlResponse;
import velocity.types.SearchCollectionPushStaging;
import velocity.types.SearchCollectionReadOnly;
import velocity.types.SearchCollectionReadOnlyAll;
import velocity.types.SearchCollectionReadOnlyAllResponse;
import velocity.types.SearchCollectionReadOnlyResponse;
import velocity.types.SearchCollectionSetXml;
import velocity.types.SearchCollectionStatus;
import velocity.types.SearchCollectionStatusResponse;
import velocity.types.SearchCollectionUpdateConfiguration;
import velocity.types.SearchCollectionUrlStatusQuery;
import velocity.types.SearchCollectionUrlStatusQueryResponse;
import velocity.types.SearchCollectionWorkingCopyAccept;
import velocity.types.SearchCollectionWorkingCopyCreate;
import velocity.types.SearchCollectionWorkingCopyDelete;
import velocity.types.SearchCollectionXml;
import velocity.types.SearchCollectionXmlResponse;
import velocity.types.SearchServiceGet;
import velocity.types.SearchServiceGetResponse;
import velocity.types.SearchServiceRestart;
import velocity.types.SearchServiceSet;
import velocity.types.SearchServiceStart;
import velocity.types.SearchServiceStatusXml;
import velocity.types.SearchServiceStatusXmlResponse;
import velocity.types.SearchServiceStop;
import velocity.types.SourceTestEnqueuedIdsXml;
import velocity.types.SourceTestEnqueuedIdsXmlResponse;
import velocity.types.SourceTestServiceStatusXml;
import velocity.types.SourceTestServiceStatusXmlResponse;
import velocity.types.SourceTestStart;
import velocity.types.SourceTestStop;
import velocity.types.VelocityDateTime;
import velocity.types.VelocityDateTimeResponse;
import velocity.types.WriteEnvironmentList;
import velocity.types.WriteEnvironmentListResponse;


/**
 * This class was generated by the JAX-WS RI.
 * JAX-WS RI 2.1.7-b01-
 * Generated source version: 2.1
 * 
 */
@WebService(name = "VelocityPort", targetNamespace = "urn:/velocity")
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
@XmlSeeAlso({
    velocity.soap.ObjectFactory.class,
    velocity.types.ObjectFactory.class,
    velocity.objects.ObjectFactory.class
})
public interface VelocityPort {


    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.AlertListXmlResponse
     */
    @WebMethod(operationName = "AlertListXml", action = "alert-list-xml")
    @WebResult(name = "AlertListXmlResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public AlertListXmlResponse alertListXml(
        @WebParam(name = "AlertListXml", targetNamespace = "urn:/velocity/types", partName = "object")
        AlertListXml object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "AlertRun", action = "alert-run")
    public void alertRun(
        @WebParam(name = "AlertRun", targetNamespace = "urn:/velocity/types", partName = "object")
        AlertRun object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "AlertServiceStart", action = "alert-service-start")
    public void alertServiceStart(
        @WebParam(name = "AlertServiceStart", targetNamespace = "urn:/velocity/types", partName = "object")
        AlertServiceStart object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.AlertServiceStatusXmlResponse
     */
    @WebMethod(operationName = "AlertServiceStatusXml", action = "alert-service-status-xml")
    @WebResult(name = "AlertServiceStatusXmlResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public AlertServiceStatusXmlResponse alertServiceStatusXml(
        @WebParam(name = "AlertServiceStatusXml", targetNamespace = "urn:/velocity/types", partName = "object")
        AlertServiceStatusXml object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "AlertServiceStop", action = "alert-service-stop")
    public void alertServiceStop(
        @WebParam(name = "AlertServiceStop", targetNamespace = "urn:/velocity/types", partName = "object")
        AlertServiceStop object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "AnnotationAdd", action = "annotation-add")
    public void annotationAdd(
        @WebParam(name = "AnnotationAdd", targetNamespace = "urn:/velocity/types", partName = "object")
        AnnotationAdd object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "AnnotationDelete", action = "annotation-delete")
    public void annotationDelete(
        @WebParam(name = "AnnotationDelete", targetNamespace = "urn:/velocity/types", partName = "object")
        AnnotationDelete object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "AnnotationExpressAddDocList", action = "annotation-express-add-doc-list")
    public void annotationExpressAddDocList(
        @WebParam(name = "AnnotationExpressAddDocList", targetNamespace = "urn:/velocity/types", partName = "object")
        AnnotationExpressAddDocList object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "AnnotationExpressAddQuery", action = "annotation-express-add-query")
    public void annotationExpressAddQuery(
        @WebParam(name = "AnnotationExpressAddQuery", targetNamespace = "urn:/velocity/types", partName = "object")
        AnnotationExpressAddQuery object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "AnnotationExpressDeleteDocList", action = "annotation-express-delete-doc-list")
    public void annotationExpressDeleteDocList(
        @WebParam(name = "AnnotationExpressDeleteDocList", targetNamespace = "urn:/velocity/types", partName = "object")
        AnnotationExpressDeleteDocList object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "AnnotationExpressDeleteQuery", action = "annotation-express-delete-query")
    public void annotationExpressDeleteQuery(
        @WebParam(name = "AnnotationExpressDeleteQuery", targetNamespace = "urn:/velocity/types", partName = "object")
        AnnotationExpressDeleteQuery object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "AnnotationExpressGlobalSetDocList", action = "annotation-express-global-set-doc-list")
    public void annotationExpressGlobalSetDocList(
        @WebParam(name = "AnnotationExpressGlobalSetDocList", targetNamespace = "urn:/velocity/types", partName = "object")
        AnnotationExpressGlobalSetDocList object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "AnnotationExpressGlobalSetQuery", action = "annotation-express-global-set-query")
    public void annotationExpressGlobalSetQuery(
        @WebParam(name = "AnnotationExpressGlobalSetQuery", targetNamespace = "urn:/velocity/types", partName = "object")
        AnnotationExpressGlobalSetQuery object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.AnnotationExpressUpdateDocListResponse
     */
    @WebMethod(operationName = "AnnotationExpressUpdateDocList", action = "annotation-express-update-doc-list")
    @WebResult(name = "AnnotationExpressUpdateDocListResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public AnnotationExpressUpdateDocListResponse annotationExpressUpdateDocList(
        @WebParam(name = "AnnotationExpressUpdateDocList", targetNamespace = "urn:/velocity/types", partName = "object")
        AnnotationExpressUpdateDocList object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "AnnotationExpressUpdateQuery", action = "annotation-express-update-query")
    public void annotationExpressUpdateQuery(
        @WebParam(name = "AnnotationExpressUpdateQuery", targetNamespace = "urn:/velocity/types", partName = "object")
        AnnotationExpressUpdateQuery object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "AnnotationExpressUserSetDocList", action = "annotation-express-user-set-doc-list")
    public void annotationExpressUserSetDocList(
        @WebParam(name = "AnnotationExpressUserSetDocList", targetNamespace = "urn:/velocity/types", partName = "object")
        AnnotationExpressUserSetDocList object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "AnnotationExpressUserSetQuery", action = "annotation-express-user-set-query")
    public void annotationExpressUserSetQuery(
        @WebParam(name = "AnnotationExpressUserSetQuery", targetNamespace = "urn:/velocity/types", partName = "object")
        AnnotationExpressUserSetQuery object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "AnnotationGlobalSet", action = "annotation-global-set")
    public void annotationGlobalSet(
        @WebParam(name = "AnnotationGlobalSet", targetNamespace = "urn:/velocity/types", partName = "object")
        AnnotationGlobalSet object);

    /**
     * 
     * @param object
     * @return
     *     returns java.lang.String
     */
    @WebMethod(operationName = "AnnotationPermissions", action = "annotation-permissions")
    @WebResult(name = "AnnotationPermissionsResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public String annotationPermissions(
        @WebParam(name = "AnnotationPermissions", targetNamespace = "urn:/velocity/types", partName = "object")
        AnnotationPermissions object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "AnnotationUpdate", action = "annotation-update")
    public void annotationUpdate(
        @WebParam(name = "AnnotationUpdate", targetNamespace = "urn:/velocity/types", partName = "object")
        AnnotationUpdate object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "AnnotationUserSet", action = "annotation-user-set")
    public void annotationUserSet(
        @WebParam(name = "AnnotationUserSet", targetNamespace = "urn:/velocity/types", partName = "object")
        AnnotationUserSet object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "AutoClassifyRefreshTags", action = "auto-classify-refresh-tags")
    public void autoClassifyRefreshTags(
        @WebParam(name = "AutoClassifyRefreshTags", targetNamespace = "urn:/velocity/types", partName = "object")
        AutoClassifyRefreshTags object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.AutocompleteSuggestResponse
     */
    @WebMethod(operationName = "AutocompleteSuggest", action = "autocomplete-suggest")
    @WebResult(name = "AutocompleteSuggestResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public AutocompleteSuggestResponse autocompleteSuggest(
        @WebParam(name = "AutocompleteSuggest", targetNamespace = "urn:/velocity/types", partName = "object")
        AutocompleteSuggest object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.AxlServiceStatusResponse
     */
    @WebMethod(operationName = "AxlServiceStatus", action = "axl-service-status")
    @WebResult(name = "AxlServiceStatusResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public AxlServiceStatusResponse axlServiceStatus(
        @WebParam(name = "AxlServiceStatus", targetNamespace = "urn:/velocity/types", partName = "object")
        AxlServiceStatus object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "CollectionBrokerAbortTransactions", action = "collection-broker-abort-transactions")
    public void collectionBrokerAbortTransactions(
        @WebParam(name = "CollectionBrokerAbortTransactions", targetNamespace = "urn:/velocity/types", partName = "object")
        CollectionBrokerAbortTransactions object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.CollectionBrokerCrawlerOfflineStatusResponse
     */
    @WebMethod(operationName = "CollectionBrokerCrawlerOfflineStatus", action = "collection-broker-crawler-offline-status")
    @WebResult(name = "CollectionBrokerCrawlerOfflineStatusResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public CollectionBrokerCrawlerOfflineStatusResponse collectionBrokerCrawlerOfflineStatus(
        @WebParam(name = "CollectionBrokerCrawlerOfflineStatus", targetNamespace = "urn:/velocity/types", partName = "object")
        CollectionBrokerCrawlerOfflineStatus object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.CollectionBrokerEnqueueXmlResponse
     */
    @WebMethod(operationName = "CollectionBrokerEnqueueXml", action = "collection-broker-enqueue-xml")
    @WebResult(name = "CollectionBrokerEnqueueXmlResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public CollectionBrokerEnqueueXmlResponse collectionBrokerEnqueueXml(
        @WebParam(name = "CollectionBrokerEnqueueXml", targetNamespace = "urn:/velocity/types", partName = "object")
        CollectionBrokerEnqueueXml object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.CollectionBrokerExportDataResponse
     */
    @WebMethod(operationName = "CollectionBrokerExportData", action = "collection-broker-export-data")
    @WebResult(name = "CollectionBrokerExportDataResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public CollectionBrokerExportDataResponse collectionBrokerExportData(
        @WebParam(name = "CollectionBrokerExportData", targetNamespace = "urn:/velocity/types", partName = "object")
        CollectionBrokerExportData object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.CollectionBrokerGetResponse
     */
    @WebMethod(operationName = "CollectionBrokerGet", action = "collection-broker-get")
    @WebResult(name = "CollectionBrokerGetResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public CollectionBrokerGetResponse collectionBrokerGet(
        @WebParam(name = "CollectionBrokerGet", targetNamespace = "urn:/velocity/types", partName = "object")
        CollectionBrokerGet object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "CollectionBrokerIgnoreCollection", action = "collection-broker-ignore-collection")
    public void collectionBrokerIgnoreCollection(
        @WebParam(name = "CollectionBrokerIgnoreCollection", targetNamespace = "urn:/velocity/types", partName = "object")
        CollectionBrokerIgnoreCollection object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.CollectionBrokerSearchResponse
     */
    @WebMethod(operationName = "CollectionBrokerSearch", action = "collection-broker-search")
    @WebResult(name = "CollectionBrokerSearchResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public CollectionBrokerSearchResponse collectionBrokerSearch(
        @WebParam(name = "CollectionBrokerSearch", targetNamespace = "urn:/velocity/types", partName = "object")
        CollectionBrokerSearch object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "CollectionBrokerSet", action = "collection-broker-set")
    public void collectionBrokerSet(
        @WebParam(name = "CollectionBrokerSet", targetNamespace = "urn:/velocity/types", partName = "object")
        CollectionBrokerSet object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "CollectionBrokerStart", action = "collection-broker-start")
    public void collectionBrokerStart(
        @WebParam(name = "CollectionBrokerStart", targetNamespace = "urn:/velocity/types", partName = "object")
        CollectionBrokerStart object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "CollectionBrokerStartCollection", action = "collection-broker-start-collection")
    public void collectionBrokerStartCollection(
        @WebParam(name = "CollectionBrokerStartCollection", targetNamespace = "urn:/velocity/types", partName = "object")
        CollectionBrokerStartCollection object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.CollectionBrokerStatusResponse
     */
    @WebMethod(operationName = "CollectionBrokerStatus", action = "collection-broker-status")
    @WebResult(name = "CollectionBrokerStatusResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public CollectionBrokerStatusResponse collectionBrokerStatus(
        @WebParam(name = "CollectionBrokerStatus", targetNamespace = "urn:/velocity/types", partName = "object")
        CollectionBrokerStatus object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "CollectionBrokerStop", action = "collection-broker-stop")
    public void collectionBrokerStop(
        @WebParam(name = "CollectionBrokerStop", targetNamespace = "urn:/velocity/types", partName = "object")
        CollectionBrokerStop object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "CrawlerRuntimeOptions", action = "crawler-runtime-options")
    public void crawlerRuntimeOptions(
        @WebParam(name = "CrawlerRuntimeOptions", targetNamespace = "urn:/velocity/types", partName = "object")
        CrawlerRuntimeOptions object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "DictionaryBuild", action = "dictionary-build")
    public void dictionaryBuild(
        @WebParam(name = "DictionaryBuild", targetNamespace = "urn:/velocity/types", partName = "object")
        DictionaryBuild object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "DictionaryCreate", action = "dictionary-create")
    public void dictionaryCreate(
        @WebParam(name = "DictionaryCreate", targetNamespace = "urn:/velocity/types", partName = "object")
        DictionaryCreate object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "DictionaryDelete", action = "dictionary-delete")
    public void dictionaryDelete(
        @WebParam(name = "DictionaryDelete", targetNamespace = "urn:/velocity/types", partName = "object")
        DictionaryDelete object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.DictionaryListXmlResponse
     */
    @WebMethod(operationName = "DictionaryListXml", action = "dictionary-list-xml")
    @WebResult(name = "DictionaryListXmlResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public DictionaryListXmlResponse dictionaryListXml(
        @WebParam(name = "DictionaryListXml", targetNamespace = "urn:/velocity/types", partName = "object")
        DictionaryListXml object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.DictionaryReadFromCollectionResponse
     */
    @WebMethod(operationName = "DictionaryReadFromCollection", action = "dictionary-read-from-collection")
    @WebResult(name = "DictionaryReadFromCollectionResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public DictionaryReadFromCollectionResponse dictionaryReadFromCollection(
        @WebParam(name = "DictionaryReadFromCollection", targetNamespace = "urn:/velocity/types", partName = "object")
        DictionaryReadFromCollection object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.DictionaryStatusXmlResponse
     */
    @WebMethod(operationName = "DictionaryStatusXml", action = "dictionary-status-xml")
    @WebResult(name = "DictionaryStatusXmlResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public DictionaryStatusXmlResponse dictionaryStatusXml(
        @WebParam(name = "DictionaryStatusXml", targetNamespace = "urn:/velocity/types", partName = "object")
        DictionaryStatusXml object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "DictionaryStop", action = "dictionary-stop")
    public void dictionaryStop(
        @WebParam(name = "DictionaryStop", targetNamespace = "urn:/velocity/types", partName = "object")
        DictionaryStop object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "IndexerRuntimeOptions", action = "indexer-runtime-options")
    public void indexerRuntimeOptions(
        @WebParam(name = "IndexerRuntimeOptions", targetNamespace = "urn:/velocity/types", partName = "object")
        IndexerRuntimeOptions object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.PingResponse
     */
    @WebMethod(operationName = "Ping", action = "ping")
    @WebResult(name = "PingResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public PingResponse ping(
        @WebParam(name = "Ping", targetNamespace = "urn:/velocity/types", partName = "object")
        Ping object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.QueryBrowseResponse
     */
    @WebMethod(operationName = "QueryBrowse", action = "query-browse")
    @WebResult(name = "QueryBrowseResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public QueryBrowseResponse queryBrowse(
        @WebParam(name = "QueryBrowse", targetNamespace = "urn:/velocity/types", partName = "object")
        QueryBrowse object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.QueryClusterResponse
     */
    @WebMethod(operationName = "QueryCluster", action = "query-cluster")
    @WebResult(name = "QueryClusterResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public QueryClusterResponse queryCluster(
        @WebParam(name = "QueryCluster", targetNamespace = "urn:/velocity/types", partName = "object")
        QueryCluster object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.QueryParseResponse
     */
    @WebMethod(operationName = "QueryParse", action = "query-parse")
    @WebResult(name = "QueryParseResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public QueryParseResponse queryParse(
        @WebParam(name = "QueryParse", targetNamespace = "urn:/velocity/types", partName = "object")
        QueryParse object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.QuerySearchResponse
     */
    @WebMethod(operationName = "QuerySearch", action = "query-search")
    @WebResult(name = "QuerySearchResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public QuerySearchResponse querySearch(
        @WebParam(name = "QuerySearch", targetNamespace = "urn:/velocity/types", partName = "object")
        QuerySearch object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.QuerySimilarDocumentsResponse
     */
    @WebMethod(operationName = "QuerySimilarDocuments", action = "query-similar-documents")
    @WebResult(name = "QuerySimilarDocumentsResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public QuerySimilarDocumentsResponse querySimilarDocuments(
        @WebParam(name = "QuerySimilarDocuments", targetNamespace = "urn:/velocity/types", partName = "object")
        QuerySimilarDocuments object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "ReportingCleanNow", action = "reporting-clean-now")
    public void reportingCleanNow(
        @WebParam(name = "ReportingCleanNow", targetNamespace = "urn:/velocity/types", partName = "object")
        ReportingCleanNow object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "ReportsEnqueue", action = "reports-enqueue")
    public void reportsEnqueue(
        @WebParam(name = "ReportsEnqueue", targetNamespace = "urn:/velocity/types", partName = "object")
        ReportsEnqueue object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.ReportsResultsXmlResponse
     */
    @WebMethod(operationName = "ReportsResultsXml", action = "reports-results-xml")
    @WebResult(name = "ReportsResultsXmlResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public ReportsResultsXmlResponse reportsResultsXml(
        @WebParam(name = "ReportsResultsXml", targetNamespace = "urn:/velocity/types", partName = "object")
        ReportsResultsXml object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.ReportsRunNowXmlResponse
     */
    @WebMethod(operationName = "ReportsRunNowXml", action = "reports-run-now-xml")
    @WebResult(name = "ReportsRunNowXmlResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public ReportsRunNowXmlResponse reportsRunNowXml(
        @WebParam(name = "ReportsRunNowXml", targetNamespace = "urn:/velocity/types", partName = "object")
        ReportsRunNowXml object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.ReportsStatusXmlResponse
     */
    @WebMethod(operationName = "ReportsStatusXml", action = "reports-status-xml")
    @WebResult(name = "ReportsStatusXmlResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public ReportsStatusXmlResponse reportsStatusXml(
        @WebParam(name = "ReportsStatusXml", targetNamespace = "urn:/velocity/types", partName = "object")
        ReportsStatusXml object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "ReportsStop", action = "reports-stop")
    public void reportsStop(
        @WebParam(name = "ReportsStop", targetNamespace = "urn:/velocity/types", partName = "object")
        ReportsStop object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.ReportsSystemReportingResponse
     */
    @WebMethod(operationName = "ReportsSystemReporting", action = "reports-system-reporting")
    @WebResult(name = "ReportsSystemReportingResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public ReportsSystemReportingResponse reportsSystemReporting(
        @WebParam(name = "ReportsSystemReporting", targetNamespace = "urn:/velocity/types", partName = "object")
        ReportsSystemReporting object);

    /**
     * 
     * @param object
     * @return
     *     returns java.lang.String
     */
    @WebMethod(operationName = "RepositoryAdd", action = "repository-add")
    @WebResult(name = "RepositoryAddResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public String repositoryAdd(
        @WebParam(name = "RepositoryAdd", targetNamespace = "urn:/velocity/types", partName = "object")
        RepositoryAdd object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "RepositoryDelete", action = "repository-delete")
    public void repositoryDelete(
        @WebParam(name = "RepositoryDelete", targetNamespace = "urn:/velocity/types", partName = "object")
        RepositoryDelete object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.RepositoryGetResponse
     */
    @WebMethod(operationName = "RepositoryGet", action = "repository-get")
    @WebResult(name = "RepositoryGetResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public RepositoryGetResponse repositoryGet(
        @WebParam(name = "RepositoryGet", targetNamespace = "urn:/velocity/types", partName = "object")
        RepositoryGet object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.RepositoryGetMd5Response
     */
    @WebMethod(operationName = "RepositoryGetMd5", action = "repository-get-md5")
    @WebResult(name = "RepositoryGetMd5Response", targetNamespace = "urn:/velocity/types", partName = "object")
    public RepositoryGetMd5Response repositoryGetMd5(
        @WebParam(name = "RepositoryGetMd5", targetNamespace = "urn:/velocity/types", partName = "object")
        RepositoryGetMd5 object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.RepositoryListXmlResponse
     */
    @WebMethod(operationName = "RepositoryListXml", action = "repository-list-xml")
    @WebResult(name = "RepositoryListXmlResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public RepositoryListXmlResponse repositoryListXml(
        @WebParam(name = "RepositoryListXml", targetNamespace = "urn:/velocity/types", partName = "object")
        RepositoryListXml object);

    /**
     * 
     * @param object
     * @return
     *     returns java.lang.String
     */
    @WebMethod(operationName = "RepositoryUpdate", action = "repository-update")
    @WebResult(name = "RepositoryUpdateResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public String repositoryUpdate(
        @WebParam(name = "RepositoryUpdate", targetNamespace = "urn:/velocity/types", partName = "object")
        RepositoryUpdate object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.SchedulerJobsResponse
     */
    @WebMethod(operationName = "SchedulerJobs", action = "scheduler-jobs")
    @WebResult(name = "SchedulerJobsResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public SchedulerJobsResponse schedulerJobs(
        @WebParam(name = "SchedulerJobs", targetNamespace = "urn:/velocity/types", partName = "object")
        SchedulerJobs object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SchedulerServiceStart", action = "scheduler-service-start")
    public void schedulerServiceStart(
        @WebParam(name = "SchedulerServiceStart", targetNamespace = "urn:/velocity/types", partName = "object")
        SchedulerServiceStart object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.SchedulerServiceStatusXmlResponse
     */
    @WebMethod(operationName = "SchedulerServiceStatusXml", action = "scheduler-service-status-xml")
    @WebResult(name = "SchedulerServiceStatusXmlResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public SchedulerServiceStatusXmlResponse schedulerServiceStatusXml(
        @WebParam(name = "SchedulerServiceStatusXml", targetNamespace = "urn:/velocity/types", partName = "object")
        SchedulerServiceStatusXml object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SchedulerServiceStop", action = "scheduler-service-stop")
    public void schedulerServiceStop(
        @WebParam(name = "SchedulerServiceStop", targetNamespace = "urn:/velocity/types", partName = "object")
        SchedulerServiceStop object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchCollectionAbortTransactions", action = "search-collection-abort-transactions")
    public void searchCollectionAbortTransactions(
        @WebParam(name = "SearchCollectionAbortTransactions", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionAbortTransactions object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchCollectionAuditLogPurge", action = "search-collection-audit-log-purge")
    public void searchCollectionAuditLogPurge(
        @WebParam(name = "SearchCollectionAuditLogPurge", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionAuditLogPurge object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.SearchCollectionAuditLogRetrieveResponse
     */
    @WebMethod(operationName = "SearchCollectionAuditLogRetrieve", action = "search-collection-audit-log-retrieve")
    @WebResult(name = "SearchCollectionAuditLogRetrieveResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public SearchCollectionAuditLogRetrieveResponse searchCollectionAuditLogRetrieve(
        @WebParam(name = "SearchCollectionAuditLogRetrieve", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionAuditLogRetrieve object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchCollectionClean", action = "search-collection-clean")
    public void searchCollectionClean(
        @WebParam(name = "SearchCollectionClean", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionClean object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchCollectionCrawlerRestart", action = "search-collection-crawler-restart")
    public void searchCollectionCrawlerRestart(
        @WebParam(name = "SearchCollectionCrawlerRestart", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionCrawlerRestart object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchCollectionCrawlerStart", action = "search-collection-crawler-start")
    public void searchCollectionCrawlerStart(
        @WebParam(name = "SearchCollectionCrawlerStart", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionCrawlerStart object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchCollectionCrawlerStop", action = "search-collection-crawler-stop")
    public void searchCollectionCrawlerStop(
        @WebParam(name = "SearchCollectionCrawlerStop", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionCrawlerStop object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchCollectionCreate", action = "search-collection-create")
    public void searchCollectionCreate(
        @WebParam(name = "SearchCollectionCreate", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionCreate object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchCollectionDelete", action = "search-collection-delete")
    public void searchCollectionDelete(
        @WebParam(name = "SearchCollectionDelete", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionDelete object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.SearchCollectionEnqueueResponse
     */
    @WebMethod(operationName = "SearchCollectionEnqueue", action = "search-collection-enqueue")
    @WebResult(name = "SearchCollectionEnqueueResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public SearchCollectionEnqueueResponse searchCollectionEnqueue(
        @WebParam(name = "SearchCollectionEnqueue", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionEnqueue object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.SearchCollectionEnqueueDeletesResponse
     */
    @WebMethod(operationName = "SearchCollectionEnqueueDeletes", action = "search-collection-enqueue-deletes")
    @WebResult(name = "SearchCollectionEnqueueDeletesResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public SearchCollectionEnqueueDeletesResponse searchCollectionEnqueueDeletes(
        @WebParam(name = "SearchCollectionEnqueueDeletes", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionEnqueueDeletes object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.SearchCollectionEnqueueUrlResponse
     */
    @WebMethod(operationName = "SearchCollectionEnqueueUrl", action = "search-collection-enqueue-url")
    @WebResult(name = "SearchCollectionEnqueueUrlResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public SearchCollectionEnqueueUrlResponse searchCollectionEnqueueUrl(
        @WebParam(name = "SearchCollectionEnqueueUrl", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionEnqueueUrl object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.SearchCollectionEnqueueXmlResponse
     */
    @WebMethod(operationName = "SearchCollectionEnqueueXml", action = "search-collection-enqueue-xml")
    @WebResult(name = "SearchCollectionEnqueueXmlResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public SearchCollectionEnqueueXmlResponse searchCollectionEnqueueXml(
        @WebParam(name = "SearchCollectionEnqueueXml", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionEnqueueXml object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchCollectionIndexerFullMerge", action = "search-collection-indexer-full-merge")
    public void searchCollectionIndexerFullMerge(
        @WebParam(name = "SearchCollectionIndexerFullMerge", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionIndexerFullMerge object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchCollectionIndexerRestart", action = "search-collection-indexer-restart")
    public void searchCollectionIndexerRestart(
        @WebParam(name = "SearchCollectionIndexerRestart", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionIndexerRestart object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchCollectionIndexerStart", action = "search-collection-indexer-start")
    public void searchCollectionIndexerStart(
        @WebParam(name = "SearchCollectionIndexerStart", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionIndexerStart object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchCollectionIndexerStop", action = "search-collection-indexer-stop")
    public void searchCollectionIndexerStop(
        @WebParam(name = "SearchCollectionIndexerStop", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionIndexerStop object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.SearchCollectionListStatusXmlResponse
     */
    @WebMethod(operationName = "SearchCollectionListStatusXml", action = "search-collection-list-status-xml")
    @WebResult(name = "SearchCollectionListStatusXmlResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public SearchCollectionListStatusXmlResponse searchCollectionListStatusXml(
        @WebParam(name = "SearchCollectionListStatusXml", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionListStatusXml object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.SearchCollectionListXmlResponse
     */
    @WebMethod(operationName = "SearchCollectionListXml", action = "search-collection-list-xml")
    @WebResult(name = "SearchCollectionListXmlResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public SearchCollectionListXmlResponse searchCollectionListXml(
        @WebParam(name = "SearchCollectionListXml", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionListXml object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchCollectionPushStaging", action = "search-collection-push-staging")
    public void searchCollectionPushStaging(
        @WebParam(name = "SearchCollectionPushStaging", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionPushStaging object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.SearchCollectionReadOnlyResponse
     */
    @WebMethod(operationName = "SearchCollectionReadOnly", action = "search-collection-read-only")
    @WebResult(name = "SearchCollectionReadOnlyResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public SearchCollectionReadOnlyResponse searchCollectionReadOnly(
        @WebParam(name = "SearchCollectionReadOnly", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionReadOnly object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.SearchCollectionReadOnlyAllResponse
     */
    @WebMethod(operationName = "SearchCollectionReadOnlyAll", action = "search-collection-read-only-all")
    @WebResult(name = "SearchCollectionReadOnlyAllResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public SearchCollectionReadOnlyAllResponse searchCollectionReadOnlyAll(
        @WebParam(name = "SearchCollectionReadOnlyAll", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionReadOnlyAll object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchCollectionSetXml", action = "search-collection-set-xml")
    public void searchCollectionSetXml(
        @WebParam(name = "SearchCollectionSetXml", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionSetXml object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.SearchCollectionStatusResponse
     */
    @WebMethod(operationName = "SearchCollectionStatus", action = "search-collection-status")
    @WebResult(name = "SearchCollectionStatusResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public SearchCollectionStatusResponse searchCollectionStatus(
        @WebParam(name = "SearchCollectionStatus", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionStatus object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchCollectionUpdateConfiguration", action = "search-collection-update-configuration")
    public void searchCollectionUpdateConfiguration(
        @WebParam(name = "SearchCollectionUpdateConfiguration", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionUpdateConfiguration object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.SearchCollectionUrlStatusQueryResponse
     */
    @WebMethod(operationName = "SearchCollectionUrlStatusQuery", action = "search-collection-url-status-query")
    @WebResult(name = "SearchCollectionUrlStatusQueryResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public SearchCollectionUrlStatusQueryResponse searchCollectionUrlStatusQuery(
        @WebParam(name = "SearchCollectionUrlStatusQuery", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionUrlStatusQuery object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchCollectionWorkingCopyAccept", action = "search-collection-working-copy-accept")
    public void searchCollectionWorkingCopyAccept(
        @WebParam(name = "SearchCollectionWorkingCopyAccept", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionWorkingCopyAccept object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchCollectionWorkingCopyCreate", action = "search-collection-working-copy-create")
    public void searchCollectionWorkingCopyCreate(
        @WebParam(name = "SearchCollectionWorkingCopyCreate", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionWorkingCopyCreate object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchCollectionWorkingCopyDelete", action = "search-collection-working-copy-delete")
    public void searchCollectionWorkingCopyDelete(
        @WebParam(name = "SearchCollectionWorkingCopyDelete", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionWorkingCopyDelete object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.SearchCollectionXmlResponse
     */
    @WebMethod(operationName = "SearchCollectionXml", action = "search-collection-xml")
    @WebResult(name = "SearchCollectionXmlResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public SearchCollectionXmlResponse searchCollectionXml(
        @WebParam(name = "SearchCollectionXml", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchCollectionXml object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.SearchServiceGetResponse
     */
    @WebMethod(operationName = "SearchServiceGet", action = "search-service-get")
    @WebResult(name = "SearchServiceGetResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public SearchServiceGetResponse searchServiceGet(
        @WebParam(name = "SearchServiceGet", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchServiceGet object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchServiceRestart", action = "search-service-restart")
    public void searchServiceRestart(
        @WebParam(name = "SearchServiceRestart", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchServiceRestart object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchServiceSet", action = "search-service-set")
    public void searchServiceSet(
        @WebParam(name = "SearchServiceSet", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchServiceSet object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchServiceStart", action = "search-service-start")
    public void searchServiceStart(
        @WebParam(name = "SearchServiceStart", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchServiceStart object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.SearchServiceStatusXmlResponse
     */
    @WebMethod(operationName = "SearchServiceStatusXml", action = "search-service-status-xml")
    @WebResult(name = "SearchServiceStatusXmlResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public SearchServiceStatusXmlResponse searchServiceStatusXml(
        @WebParam(name = "SearchServiceStatusXml", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchServiceStatusXml object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SearchServiceStop", action = "search-service-stop")
    public void searchServiceStop(
        @WebParam(name = "SearchServiceStop", targetNamespace = "urn:/velocity/types", partName = "object")
        SearchServiceStop object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.SourceTestEnqueuedIdsXmlResponse
     */
    @WebMethod(operationName = "SourceTestEnqueuedIdsXml", action = "source-test-enqueued-ids-xml")
    @WebResult(name = "SourceTestEnqueuedIdsXmlResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public SourceTestEnqueuedIdsXmlResponse sourceTestEnqueuedIdsXml(
        @WebParam(name = "SourceTestEnqueuedIdsXml", targetNamespace = "urn:/velocity/types", partName = "object")
        SourceTestEnqueuedIdsXml object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.SourceTestServiceStatusXmlResponse
     */
    @WebMethod(operationName = "SourceTestServiceStatusXml", action = "source-test-service-status-xml")
    @WebResult(name = "SourceTestServiceStatusXmlResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public SourceTestServiceStatusXmlResponse sourceTestServiceStatusXml(
        @WebParam(name = "SourceTestServiceStatusXml", targetNamespace = "urn:/velocity/types", partName = "object")
        SourceTestServiceStatusXml object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SourceTestStart", action = "source-test-start")
    public void sourceTestStart(
        @WebParam(name = "SourceTestStart", targetNamespace = "urn:/velocity/types", partName = "object")
        SourceTestStart object);

    /**
     * 
     * @param object
     */
    @WebMethod(operationName = "SourceTestStop", action = "source-test-stop")
    public void sourceTestStop(
        @WebParam(name = "SourceTestStop", targetNamespace = "urn:/velocity/types", partName = "object")
        SourceTestStop object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.VelocityDateTimeResponse
     */
    @WebMethod(operationName = "VelocityDateTime", action = "velocity-date-time")
    @WebResult(name = "VelocityDateTimeResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public VelocityDateTimeResponse velocityDateTime(
        @WebParam(name = "VelocityDateTime", targetNamespace = "urn:/velocity/types", partName = "object")
        VelocityDateTime object);

    /**
     * 
     * @param object
     * @return
     *     returns velocity.types.WriteEnvironmentListResponse
     */
    @WebMethod(operationName = "WriteEnvironmentList", action = "write-environment-list")
    @WebResult(name = "WriteEnvironmentListResponse", targetNamespace = "urn:/velocity/types", partName = "object")
    public WriteEnvironmentListResponse writeEnvironmentList(
        @WebParam(name = "WriteEnvironmentList", targetNamespace = "urn:/velocity/types", partName = "object")
        WriteEnvironmentList object);

}
