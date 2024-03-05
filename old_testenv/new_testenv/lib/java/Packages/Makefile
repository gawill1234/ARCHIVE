#
#   Not a damn clue what I'm doing here.  Just made the stupid Makefile
#   build my package correctly.  For the moment, that's all I care about.
#
# define compiler and compiler flag variables
#

CLASSPATH=$(TEST_ROOT)/lib/java/Packages:$(TEST_ROOT)/lib:$(TEST_ROOT)/lib/velocity.jar:.:/testenv/JARFILES/activation-1.1.jar:/testenv/JARFILES/aopalliance-1.0.jar:/testenv/JARFILES/asm-2.2.3.jar:/testenv/JARFILES/axis-1.4.jar:/testenv/JARFILES/axis-jaxrpc-1.4.jar:/testenv/JARFILES/bcprov-jdk15-1.43.jar:/testenv/JARFILES/build-meta-tools-1.0.0-SNAPSHOT.jar:/testenv/JARFILES/commons-beanutils-1.8.0.jar:/testenv/JARFILES/commons-codec-1.2.jar:/testenv/JARFILES/commons-collections-3.2.1.jar:/testenv/JARFILES/commons-discovery-0.2.jar:/testenv/JARFILES/commons-httpclient-3.1.jar:/testenv/JARFILES/commons-io-1.4.jar:/testenv/JARFILES/commons-lang-2.5.jar:/testenv/JARFILES/commons-logging-1.1.1.jar

JFLAGS = -nowarn -classpath $(CLASSPATH) -d .
JC = javac

PACKAGE_DIR = Vivisimo/tAPI


#
# Clear any default targets for building .class files from .java files; we 
# will provide our own target entry to do this in this makefile.
# make has a set of default targets for different suffixes (like .c.o) 
# Currently, clearing the default for .java.class is not necessary since 
# make does not have a definition for this target, but later versions of 
# make may, so it doesn't hurt to make sure that we clear any default 
# definitions for these
#

.SUFFIXES: .java .class


#
# Here is our target entry for creating .class files from .java files 
# This is a target entry that uses the suffix rule syntax:
#	DSTS:
#		rule
#  'TS' is the suffix of the target file, 'DS' is the suffix of the dependency 
#  file, and 'rule'  is the rule for building a target	
# '$*' is a built-in macro that gets the basename of the current target 
# Remember that there must be a < tab > before the command line ('rule') 
#

.java.class:
	$(JC) $(JFLAGS) $*.java


#
# CLASSES is a macro consisting of 4 words (one for each java source file)
#

CLASSES = \
	$(PACKAGE_DIR)/tXML/GoGetXML.java \
	$(PACKAGE_DIR)/tXML/GoGet.java \
	$(PACKAGE_DIR)/tXML/testXML.java \
	$(PACKAGE_DIR)/tXML/queryXML.java \
	$(PACKAGE_DIR)/tTestEnv/ENVIRONMENT.java \
	$(PACKAGE_DIR)/tTestEnv/GRONK.java \
	$(PACKAGE_DIR)/tVelocity/vDictionary.java \
	$(PACKAGE_DIR)/tVelocity/vRepository.java \
	$(PACKAGE_DIR)/tVelocity/vServices.java \
	$(PACKAGE_DIR)/tVelocity/vSourceCollection.java \
	$(PACKAGE_DIR)/tVelocity/vQuery.java \
	$(PACKAGE_DIR)/tTestEnv/tInputData.java \
	$(PACKAGE_DIR)/tTestEnv/tCommonCases.java


#
# the default make target entry
#

default: classes


#
# This target entry uses Suffix Replacement within a macro: 
# $(name:string1=string2)
# 	In the words in the macro named 'name' replace 'string1' with 'string2'
# Below we are replacing the suffix .java of all words in the macro CLASSES 
# with the .class suffix
#

classes: $(CLASSES:.java=.class)


#
# RM is a predefined macro in make (RM = rm -f)
#

clean:
	$(RM) $(PACKAGE_DIR)/*.class

