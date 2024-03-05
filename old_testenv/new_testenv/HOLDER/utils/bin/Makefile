SHELL   = /bin/bash
#
#
MY_PROGS =	get_bin run_query query_service_status stop_query_service \
		start_query_service get_status get_collection \
		delete_data delete_collection create_collection \
		collection_exists build_index stop_crindex \
		stop_indexing stop_crawler refresh_crawl resume_crawl \
		start_crawl put_file get_file delete_file check_bin \
		testtest vivisimo_dir where_is_vivisimo wait_for_idle \
		get_repository get_raw_collection dump_index get_status \
		crawler_status get_vce get_bin_attribute \
		check_bin_attribute get_raw_source get_raw_function \
		get_raw_dictionary get_collection_admin remove_collection \
		get_crawl_dir query_db get_staging get_staging_indexer \
		indexing_test_status kill_service_children get_admin_xml \
		push_to_live merge_index get_index_path get_indexer_pid \
		get_crawler_pid crawl_dups crawl_errors crawl_outputs \
		crawl_inputs index_docs index_contents valid_indexes \
		index_urls put_dir kill_all_services crawl_pending \
		crawl_idx_reply crawl_idx_input crawl_idx_output_state \
		hang_check url_count count_urls get_query_url \
		get_query_urls sort_query_urls count_bin_urls \
		query_urls_by_content get_url_matches get_match_counts \
		content_titles get_url_errors kill_admin get_service_pid \
		get_service_pid_count get_service_pid_list \
		find_collection_core find_core find_cgi_core \
		crawl_elapsed index_size index_time get_index_file_count \
		crawled_bytes run_velocity backup_repository \
		restore_repository new_repository file_exists get_url_by_id \
		repository_import gcse delete_repository repository_delete \
		repository_update get_index_size url_count_qe restore_collection

FILE_PROGS =	xmlresultfile xmlcomparefile uricomparefile \
		uriresultfile uridifffile xmldifffile \
		binsresultfile binscomparefile binsdifffile gfn
ACC_PROGS =	getversionfiles
XML_PROGS =	url_existence_check url_by_la_score url_countP count_urlsP
CC      =       gcc
#
CFLAGS =        -I "$(TEST_ROOT)/include"
LDFLAGS =	-L "$(TEST_ROOT)/lib" -ltst
ORALIB = 	-lora
#
AR      =       ar
RM      =       rm
#
#

%:%.c
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)
%.o:%.c
	$(CC) $(CFLAGS) -c $< -o $@

all:
ifdef TEST_ROOT
	for FILE in $(MY_PROGS); do \
	   rm -f "$(TEST_ROOT)/utils/bin/$${FILE}"; \
	   ln "$(TEST_ROOT)/lib/crt" "$(TEST_ROOT)/utils/bin/$${FILE}"; \
	done
	for FILE in $(FILE_PROGS); do \
	   rm -f "$(TEST_ROOT)/utils/bin/$${FILE}"; \
	   ln "$(TEST_ROOT)/lib/gfn" "$(TEST_ROOT)/utils/bin/$${FILE}"; \
	done
	for FILE in $(ACC_PROGS); do \
	   rm -f "$(TEST_ROOT)/utils/bin/$${FILE}"; \
	   ln "$(TEST_ROOT)/lib/filecommands.py" "$(TEST_ROOT)/utils/bin/$${FILE}"; \
	done
	for FILE in $(XML_PROGS); do \
	   rm -f "$(TEST_ROOT)/utils/bin/$${FILE}"; \
	   ln "$(TEST_ROOT)/lib/pxc" "$(TEST_ROOT)/utils/bin/$${FILE}"; \
	done
	ln "$(TEST_ROOT)/lib/connector_installer.py" "$(TEST_ROOT)/utils/bin/connector_installer.py"; \
	chmod 755 $(TEST_ROOT)/utils/bin/*
else
	echo 'TEST_ROOT not set.'
endif

clean:
ifdef TEST_ROOT
	for FILE in $(MY_PROGS); do \
	   rm -f "$(TEST_ROOT)/utils/bin/$${FILE}"; \
	done
	for FILE in $(FILE_PROGS); do \
	   rm -f "$(TEST_ROOT)/utils/bin/$${FILE}"; \
	done
	for FILE in $(ODBC_PROGS); do \
	   rm -f "$(TEST_ROOT)/utils/bin/$${FILE}"; \
	done
else
	echo 'TEST_ROOT not set.'
endif

