
package velocity.objects;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for anonymous complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType>
 *   &lt;simpleContent>
 *     &lt;restriction base="&lt;urn:/velocity/objects>generic-option">
 *       &lt;attribute name="name">
 *         &lt;simpleType>
 *           &lt;restriction base="{http://www.w3.org/2001/XMLSchema}string">
 *             &lt;enumeration value="profile-dump"/>
 *             &lt;enumeration value="debug"/>
 *             &lt;enumeration value="trace-keys"/>
 *             &lt;enumeration value="duplicate-elimination"/>
 *             &lt;enumeration value="shingle-contents"/>
 *             &lt;enumeration value="shingle-words"/>
 *             &lt;enumeration value="shingle-hashes"/>
 *             &lt;enumeration value="stem"/>
 *             &lt;enumeration value="stem2"/>
 *             &lt;enumeration value="stoplist"/>
 *             &lt;enumeration value="segmenter"/>
 *             &lt;enumeration value="segmenter2"/>
 *             &lt;enumeration value="tokenizer"/>
 *             &lt;enumeration value="tokenizer-word"/>
 *             &lt;enumeration value="tokenizer-punct"/>
 *             &lt;enumeration value="url-weight"/>
 *             &lt;enumeration value="host-weight"/>
 *             &lt;enumeration value="contents-with-dedicated-streams"/>
 *             &lt;enumeration value="link-analysis-reps"/>
 *             &lt;enumeration value="block-size"/>
 *             &lt;enumeration value="prealloc-blocks"/>
 *             &lt;enumeration value="stripe-size"/>
 *             &lt;enumeration value="direct-io"/>
 *             &lt;enumeration value="temp-block-size"/>
 *             &lt;enumeration value="vocab-words"/>
 *             &lt;enumeration value="search-vocab-words"/>
 *             &lt;enumeration value="max-stem-seq-generators"/>
 *             &lt;enumeration value="max-merge"/>
 *             &lt;enumeration value="max-unmerged"/>
 *             &lt;enumeration value="merger-sizes"/>
 *             &lt;enumeration value="merger-max-rate"/>
 *             &lt;enumeration value="max-build-memory-words"/>
 *             &lt;enumeration value="build-flush"/>
 *             &lt;enumeration value="build-flush-idle"/>
 *             &lt;enumeration value="n-build-threads"/>
 *             &lt;enumeration value="n-reconstruct-threads"/>
 *             &lt;enumeration value="idle-exit"/>
 *             &lt;enumeration value="search-idle-exit"/>
 *             &lt;enumeration value="startup-timeout"/>
 *             &lt;enumeration value="index-dir"/>
 *             &lt;enumeration value="compat-index-dir"/>
 *             &lt;enumeration value="result-cache-dir"/>
 *             &lt;enumeration value="max-indices"/>
 *             &lt;enumeration value="keep-acls"/>
 *             &lt;enumeration value="output-acls"/>
 *             &lt;enumeration value="indexer-profiling"/>
 *             &lt;enumeration value="cache-cleaner-period"/>
 *             &lt;enumeration value="cache-cleaner-mb"/>
 *             &lt;enumeration value="check-authorization-url"/>
 *             &lt;enumeration value="wc-blacklist"/>
 *             &lt;enumeration value="re-blacklist"/>
 *             &lt;enumeration value="mlock-bytes"/>
 *             &lt;enumeration value="cache-mb"/>
 *             &lt;enumeration value="mlock-cache"/>
 *             &lt;enumeration value="default-contents"/>
 *             &lt;enumeration value="output-contents"/>
 *             &lt;enumeration value="max-output-contents"/>
 *             &lt;enumeration value="summarize-contents"/>
 *             &lt;enumeration value="summarize-name"/>
 *             &lt;enumeration value="summarize-action"/>
 *             &lt;enumeration value="summarize-output-action"/>
 *             &lt;enumeration value="summarize-weight"/>
 *             &lt;enumeration value="ranking-proximity"/>
 *             &lt;enumeration value="heap-or-min"/>
 *             &lt;enumeration value="ranking-prune-at-block"/>
 *             &lt;enumeration value="summary-context-words"/>
 *             &lt;enumeration value="summary-bytes"/>
 *             &lt;enumeration value="multi-read"/>
 *             &lt;enumeration value="preloader-multi"/>
 *             &lt;enumeration value="preloader-sleep-ms"/>
 *             &lt;enumeration value="n-doc-readers"/>
 *             &lt;enumeration value="check-contents"/>
 *             &lt;enumeration value="max-content-size"/>
 *             &lt;enumeration value="max-build-merge-size"/>
 *             &lt;enumeration value="phrase-logic"/>
 *             &lt;enumeration value="ranking-n-best"/>
 *             &lt;enumeration value="ranking-max-best"/>
 *             &lt;enumeration value="output-ranking-info"/>
 *             &lt;enumeration value="default-parser"/>
 *             &lt;enumeration value="allow-null-search"/>
 *             &lt;enumeration value="require-rights"/>
 *             &lt;enumeration value="use-default-tags"/>
 *             &lt;enumeration value="vector-space"/>
 *             &lt;enumeration value="fast-index"/>
 *             &lt;enumeration value="indexed-fast-index"/>
 *             &lt;enumeration value="tag-compression"/>
 *             &lt;enumeration value="max-uncompressed-size"/>
 *             &lt;enumeration value="term-expand-dicts"/>
 *             &lt;enumeration value="term-expand-dicts-dir"/>
 *             &lt;enumeration value="term-expand-stemmer"/>
 *             &lt;enumeration value="term-expand-delanguage"/>
 *             &lt;enumeration value="term-expand-max-expand"/>
 *             &lt;enumeration value="term-expand-max-expand-error"/>
 *             &lt;enumeration value="extents-limit"/>
 *             &lt;enumeration value="extents-term-limit"/>
 *             &lt;enumeration value="heap-or-min"/>
 *             &lt;enumeration value="rank-decay"/>
 *             &lt;enumeration value="indexed-fast-index-ratio"/>
 *             &lt;enumeration value="group-ors"/>
 *             &lt;enumeration value="simplify-or-phrases"/>
 *             &lt;enumeration value="arenas"/>
 *             &lt;enumeration value="word-order-factor"/>
 *             &lt;enumeration value="allow-ips"/>
 *             &lt;enumeration value="min-idle-threads"/>
 *             &lt;enumeration value="max-idle-threads"/>
 *             &lt;enumeration value="concurrent-queries"/>
 *             &lt;enumeration value="threads-per-query"/>
 *             &lt;enumeration value="min-docs-per-thread"/>
 *             &lt;enumeration value="fast-docs-load"/>
 *             &lt;enumeration value="fast-reconstructor-startup"/>
 *             &lt;enumeration value="preload-database"/>
 *             &lt;enumeration value="query-logging"/>
 *             &lt;enumeration value="query-log-file"/>
 *             &lt;enumeration value="search-port"/>
 *             &lt;enumeration value="binning-id"/>
 *             &lt;enumeration value="binning-config"/>
 *             &lt;enumeration value="binning-limit"/>
 *             &lt;enumeration value="database-synchronous"/>
 *           &lt;/restriction>
 *         &lt;/simpleType>
 *       &lt;/attribute>
 *       &lt;attribute name="value" type="{http://www.w3.org/2001/XMLSchema}string" />
 *     &lt;/restriction>
 *   &lt;/simpleContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "")
@XmlRootElement(name = "vse-index-option")
public class VseIndexOption
    extends GenericOption
{


}
