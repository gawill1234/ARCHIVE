#!/bin/bash
#
#
#This script is used to find the differneces between the
#corresponding wordlists of old converters and new converters
#
#
#
#
#############################################################
#                                                           #
#   Functions used by this script                           #
#                                                           #
#############################################################

usage()
{
    # Such as "./compare_corresponding_wordlists.sh old/ new/ words result"
    echo "Usage: `basename $0` <old_converter_wordlist_dir> <new_converter_wordlist_dir> <wordlist_file_extension> <file name of the compare result>"
    exit
}

ensure_comparasion_result_not_exists()
{
    if [ -f $COMPARASION_RESULT ]
    then
        echo "$COMPARASION_RESULT exists, please delete it first"
        exit
    fi
}

ensure_given_input_is_directory()
{
    local args=$1
    if [ ! -d $args ]
    then
    echo "$args is not a directory."
    exit
    fi
}

# Convert arguments into readable format
make_arguments_readable()
{
    OLD_CONVERTER_WORDLIST_DIR=$1
    NEW_CONVERTER_WORDLIST_DIR=$2
    WORDLIST_FILES_EXTENSION=$3
    COMPARASION_RESULT=$4
}

# Get the file name of the wordlist file
finding_file_name()
{
    if [ $# -ne 1 ]
    then
        echo "Usage: `basename $0` <Path_to_File>"
        exit
    fi
    # Convert arguments into readable format
    local PATH_TO_FILE=$1

    IFS="/"
    words=($PATH_TO_FILE)
    echo ${words[${#words[@]}-1]}
}

# Get the path to corresponding new converter wordlist file
finding_path_to_new_converter_wordlist()
{
    if [ $# -ne 3 ]
    then
        echo "Usage: `basename $0` <path_to_new_converter_dir> <path_to_old_converter_dir> <path_to_old_converter_wordlist>"
        exit
    fi

    # Convert arguments into readable format
    local NEW_CONVERTER_DIR=$1
    local OLD_CONVERTER_DIR=$2
    local PATH_TO_OLD_CONVERTER_WORDLIST=$3

    tmp=$(echo $PATH_TO_OLD_CONVERTER_WORDLIST)

    # Get the path to new converter wordlist by replaceing
    # the old_converter_dir with the new_converter_dir
    path_to_new_converter=${tmp//$OLD_CONVERTER_DIR/$NEW_CONVERTER_DIR}
    echo $path_to_new_converter
}

# Finding all wordlist files in old converter directories
finding_all_wordlist_files_in_directory()
{
    # Extend the file extension to complete file name
    WORDLIST_FILES="*.$WORDLIST_FILES_EXTENSION"
    # Get all the wordlist files in given old_converter_wordlist_directory.
    IFS=$'\n'
    files_in_old_converter=( $(find $OLD_CONVERTER_WORDLIST_DIR -name $WORDLIST_FILES) )
}

# Compare the wordlists files for every new converter wordlist file
# with the corresponding old converter wordlist file.
compare_corresponding_wordlists_between_old_and_new_converters()
{
    for path_to_old_converter_wordlist in ${files_in_old_converter[@]}
    do
        # Get the file name of the wordlist file
        file_name=$(finding_file_name $path_to_old_converter_wordlist)

        # Get the path to the corresponding old converter wordlist file
        path_to_new_converter_wordlist=$(finding_path_to_new_converter_wordlist $NEW_CONVERTER_WORDLIST_DIR $OLD_CONVERTER_WORDLIST_DIR $path_to_old_converter_wordlist)

        # Find the differences between the new converter wordlist and old converter wordlist
        $(finding_differences_between_two_files $path_to_old_converter_wordlist $path_to_new_converter_wordlist $file_name $COMPARASION_RESULT)
    done
}

# Find the differences between the new converter wordlist file and
# the corresponding old converter wordlist file
finding_differences_between_two_files()
{
    if [ $# -ne 4 ]
    then
        echo "Usage: `basename $0` <path_to_old_converter_wordlist> <path_to_new_converter_wordlist> <file name> <result report>"
        exit
    fi
    # Convert arguments into readable format
    local PATH_TO_OLD_WORDLIST=$1
    local PATH_TO_NEW_WORDLIST=$2
    local WORDLIST_FILE_NAME=$3
    local COMPARISON_RESULT_REPORT=$4

    # Wordlist for new converter hasn't been generated
    if [ ! -f "$PATH_TO_NEW_WORDLIST" ]
    then
        echo "$WORDLIST_FILE_NAME -------The Differences between new converter and old converter" >> $COMPARISON_RESULT_REPORT
        echo "The wordlist of new converter hasn't been generated" >> $COMPARISON_RESULT_REPORT
        exit
    fi

    tmp_extra_words_in_new_converter=$(awk  'NR==FNR{a[$0]}NR>FNR{ if(!($1 in a)) print $0}' $PATH_TO_OLD_WORDLIST $PATH_TO_NEW_WORDLIST)
    tmp_missed_words_in_new_converter=$(awk  'NR==FNR{a[$0]}NR>FNR{ if(!($1 in a)) print $0}' $PATH_TO_NEW_WORDLIST $PATH_TO_OLD_WORDLIST)

    # Don't show result report if the wordlists of new and old
    # converter wordlists are the same
    if [ -z "$tmp_extra_words_in_new_converter" ] && [ -z "$tmp_missed_words_in_new_converter" ]
    then
        exit
    fi

    # Only show the differences in result report if there are differences
    # between new and old converter wordlists
    echo "$WORDLIST_FILE_NAME -------The Differences between new converter and old converter" >> $COMPARISON_RESULT_REPORT
    if [ -n "$tmp_extra_words_in_new_converter" ]
    then
        echo "the words in new converter wordlist but doesn't in old converter wordlist:" >> $COMPARISON_RESULT_REPORT
        echo "$tmp_extra_words_in_new_converter" >> $COMPARISON_RESULT_REPORT
    fi

    if [ -n "$tmp_missed_words_in_new_converter" ]
    then
        echo "the words in old converter wordlist but doesn't in new converter wordlist:" >> $COMPARISON_RESULT_REPORT
        echo "$tmp_missed_words_in_new_converter" >> $COMPARISON_RESULT_REPORT
        echo "---------------------------Delimeter--------------------------------------------" >> $COMPARISON_RESULT_REPORT
    fi
}


###############################################################
#                                                             #
#         Main Script                                         #
#                                                             #
###############################################################

if [ $# -ne 4 ]
then
    usage
fi

make_arguments_readable $1 $2 $3 $4
ensure_comparasion_result_not_exists
ensure_given_input_is_directory $OLD_CONVERTER_WORDLIST_DIR
ensure_given_input_is_directory $NEW_CONVERTER_WORDLIST_DIR

finding_all_wordlist_files_in_directory
compare_corresponding_wordlists_between_old_and_new_converters
