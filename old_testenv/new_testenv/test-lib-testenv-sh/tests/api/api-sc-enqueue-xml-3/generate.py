#!/usr/bin/python

"""Generate text documents from a dictionary of words.

Basic input:
  1. word list -- must not be changed!

Optional:
  1. random seed

Tuning points:
  1. Number of documents desired
  2. Average number of bytes per document
  3. Optionally: standard deviation (defaults to one tenth the doc size)

"""

import random
import time

class Collection:

    def __init__(self,
                 word_list,
                 doc_count,
                 average_doc_size, 
                 stddev=None,
                 random_seed=None):
        """A word list is required. A seed is optional."""
        self.__random = random.Random() # Our own, private, generator.
        self.__word_list = word_list
        self.__word_count = len(word_list)
        self.__last_word = len(word_list)-1
        self.doc_count = doc_count
        self.__average_doc_size = average_doc_size
        # Find the average word length, so we can adjust the target doc size.
        # Note that we add one for the space we put between words.
        self.__average_word_length = 1 + (sum([len(word) 
                                               for word in self.__word_list])
                                          / float(len(self.__word_list)))
        if stddev:
            self.__stddev = stddev
        else:
            self.__stddev = average_doc_size/10.0
        if not random_seed:
            random_seed = time.time()
        self.__my_seed = random_seed

    def word_lists(self):
        # Reseed, so that we'll do the same each time.
        self.__random.seed(self.__my_seed)
        for i in range(self.doc_count):
            yield [self.__word_list[self.__random.randrange(self.__word_count)]
                   for i in xrange(
                    int(0.5 + self.__random.normalvariate(
                            self.__average_doc_size,
                            self.__stddev)
                        /self.__average_word_length))]

    def docs(self):
        for word_list in self.word_lists():
            yield ' '.join(word_list)


def self_test(doc_count, doc_length):
    f = open('/usr/share/dict/words')
    words = [word.strip() for word in f.readlines()]
    f.close()
    c1 = Collection(words, doc_count, doc_length)
    d1 = [doc for doc in c1.docs()]
    print 'got', len(d1), 'docs, with an average length of', \
        sum([len(doc) for doc in d1])/float(len(d1)), 'bytes.'
    # Make sure regenerating gets us the same results.
    assert d1 == [doc for doc in c1.docs()], 'Yikes! Not repeatable! (1)'
    assert d1 == [doc for doc in c1.docs()], 'Yikes! Not repeatable! (2)'


################################################################
if __name__ == "__main__":
    import sys
    # Defaults
    doc_count = 10000
    doc_length = 10000

    if len(sys.argv) > 1:
        doc_count = int(sys.argv[1])
    if len(sys.argv) > 2:
        doc_length = int(sys.argv[2])

    try:
        import cProfile
        cProfile.run('self_test(doc_count, doc_length)')
    except ImportError:
        # If we can't get the profiler, run without.
        self_test(doc_count, doc_length)
