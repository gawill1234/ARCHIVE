SHELL   = /bin/bash
#
CC      =       gcc
#
CFLAGS =  -c
#
#

.c.o:
	$(CC) $(CFLAGS) $<

GRONK_SRC := \
	addToPidList.c findnode.c main.c \
	alter_file.c freenodelist.c c_restore.c \
	build_collection_path.c fs_free.c \
	buildtag.c gatattrib.c my_vse_status.c \
	collection_match.c getatag.c newnode.c \
	curcrawl.c GetCmdLine.c ops_done.c \
	data.c get_data.c ops_out.c get_collection_list.c \
	delete_data.c get_data_setup.c pid_list.c \
	do_crawl_dir.c get_free_space.c remove_directory.c \
	do_crawler_status.c get_install_dir.c replacebuffer.c \
	do_index_status.c GetProcessData.c replacestring.c \
	do_install_dir.c GetProcessesDirect.c rm_collection.c \
	do_query_status.c get_query.c send_data.c \
	doread.c get_query_pid.c setup_status.c \
	do_vse_status.c GetServicePidList.c url_decode.c \
	execute_command.c kill_crindex.c utils.c \
	findatag.c kill_it.c find_core.c test_import.c md5c.c \
	md5_name.c base64.c restore_default.c mem_usage_by_pid.c 

SRC := $(GRONK_SRC) genmd5.c

OBJ =	addToPidList.o findnode.o main.o \
	alter_file.o freenodelist.o c_restore.o \
	build_collection_path.o fs_free.o \
	buildtag.o gatattrib.o my_vse_status.o \
	collection_match.o getatag.o newnode.o \
	curcrawl.o GetCmdLine.o ops_done.o \
	data.o get_data.o ops_out.o get_collection_list.o \
	delete_data.o get_data_setup.o pid_list.o \
	do_crawl_dir.o get_free_space.o remove_directory.o \
	do_crawler_status.o get_install_dir.o replacebuffer.o \
	do_index_status.o GetProcessData.o replacestring.o \
	do_install_dir.o GetProcessesDirect.o rm_collection.o \
	do_query_status.o get_query.o send_data.o \
	doread.o get_query_pid.o setup_status.o \
	do_vse_status.o GetServicePidList.o url_decode.o \
	execute_command.o kill_crindex.o utils.o \
	findatag.o kill_it.o find_core.o test_import.o md5c.o \
	md5_name.o base64.o restore_default.o mem_usage_by_pid.o

GM5 =	genmd5.o md5c.o base64.o

linux:
	for item in $(SRC); do \
		$(CC) -D__LINUX__ -c $${item}; \
	done; \
	$(CC) -o gronk $(OBJ) -L. -lmxml -lpthread
	$(CC) -o gm5dir $(GM5)

sun:
	for item in $(SRC); do \
		$(CC) -D__SUNOS__ -c $${item}; \
	done; \
	$(CC) -o gronk $(OBJ) -L. -lmxml
	$(CC) -o gm5dir $(GM5)

windows: gronk.exe gm5dir.exe

GRONK_WIN_OBJ:= $(patsubst %.c,%.obj,$(GRONK_SRC))
GM5_WIN_OBJ := $(patsubst %.o,%.obj,$(GM5))

gronk.exe: $(GRONK_WIN_OBJ)
	$(CC) -mno-cygwin -mwindows -o $@ $^ -L/usr/lib/w32api -lpsapi -L. -lmxml

gm5dir.exe: $(GM5_WIN_OBJ)
	$(CC) -mno-cygwin -o $@ $^ -L/usr/lib/w32api -lpsapi

%.obj: %.c
	$(CC) -DPLATFORM_WINDOWS -mno-cygwin -mwindows -I/usr/include/w32api -c $< -o $@

clean:
	rm -f gronk gronk.exe
	rm -f gm5dir gm5dir.exe
	rm *.o *.obj


addToPidList.o:		addToPidList.c
alter_file.o:		alter_file.c
build_collection_path.o:	build_collection_path.c
buildtag.o:		buildtag.c
collection_match.o:	collection_match.c
curcrawl.o:		curcrawl.c
data.o:			data.c
delete_data.o:		delete_data.c
do_crawl_dir.o:		do_crawl_dir.c
do_crawler_status.o:	do_crawler_status.c
do_index_status.o:	do_index_status.c
do_install_dir.o:	do_install_dir.c
do_query_status.o:	do_query_status.c
doread.o:		doread.c
do_vse_status.o:	do_vse_status.c
execute_command.o:	execute_command.c
get_collection_list.o:	get_collection_list.c
findatag.o:		findatag.c
findnode.o:		findnode.c
c_restore.o:		c_restore.c
freenodelist.o:		freenodelist.c
fs_free.o:		fs_free.c
getattrib.o:		getattrib.c
getatag.o:		getatag.c
GetCmdLine.o:		GetCmdLine.c
get_data.o:		get_data.c
get_data_setup.o:	get_data_setup.c
get_free_space.o:	get_free_space.c
get_install_dir.o:	get_install_dir.c
GetProcessData.o:	GetProcessData.c
GetProcessesDirect.o:	GetProcessesDirect.c
get_query.o:		get_query.c
get_query_pid.o:	get_query_pid.c
GetServicePidList.o:	GetServicePidList.c
kill_crindex.o:		kill_crindex.c
mem_usage_by_pid.o:	mem_usage_by_pid.c
kill_it.o:		kill_it.c
main.o:			main.c
my_vse_status.o:	my_vse_status.c
newnode.o:		newnode.c
ops_done.o:		ops_done.c
ops_out.o:		ops_out.c
pid_list.o:		pid_list.c
remove_directory.o:	remove_directory.c
replacebuffer.o:	replacebuffer.c
replacestring.o:	replacestring.c
rm_collection.o:	rm_collection.c
send_data.o:		send_data.c
setup_status.o:		setup_status.c
url_decode.o:		url_decode.c
utils.o:		utils.c
genmd5.o:		genmd5.c

