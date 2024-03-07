#!/bin/bash
#
# Copyright (C) 2017, 2018, 2024 Roman Tsykaliak
#
# This document is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
########################################################################
#
# Encode video files specified producing videos and images.
#
# For the program to start execution, you should specify either in
# configuration file or on a command line: the video's source name,
# and optionally time references for producing images from the source
# video, and optionally starting position as time, and optionally
# duration as time. Without the video file, no other options make
# sense, and the program cancels execution.
# 
# You can specify multiple source files, each per separate option, but
# all subsequent options (like for images, position, and duration)
# shall be referenced to the most recent (previous, or most left one)
# video source specified.
#
# The result file name will be generated automatically from the source
# name plus sequential number to make a file name for a file that
# not yet exists in the current directory.
# 
# Before even specifying the source video file name, you may provide
# the source directory, destination directory, and base result name. 
# Each final file will be named as the base name plus the source file
# name, and sequential number. The final file name will be checked
# for the case if a file already exists in the destination
# directory. If so, the new sequential number shall be chosen for the
# file name to make a name for a file that not yet exists in the
# destination directory.
#
# Finally, all of the afore mentioned options can be written out to the
# configuration file, and supplied to the program for parsing. This
# option works the same way as if you had specified the options on the
# command line. Only one caveat, new line symbols are allowed in the
# config file, while are prohibited on a command line. The config file
# and a command line options should NOT be combined.
#
# All of the provided options and/or config file will be checked
# by the program before execution!
#
# Usage:
#   convert.bash {-c | --config} <path-to-file>
# 
#   convert.bash [--source-dir <source-directory>]
#                [--output-dir <output-directory>]
#                [--base-name <common-output-name-prefix>]
#                { {-v | --video} <source-file>
#                [ {-i | --image | -oi | --only-image}
#                                    <time-reference>... ] 
#                [-ss <position>] [-t <duration>] }...
#           
# Available OPTIONS:
#   -c <path-to-file>, --config <path-to-file>
#     read in the options from a config file. It ought to be a readable
#     plain text file. New lines are allowed as separators between 
#     options. Only one configuration file should be supplied!
#     If no config option is set or the file is not provided,
#     then this option is ignored.
#   --source-dir <source-directory>
#     SOURCE-DIRECTORY is the common readable directory to source
#     video files from. SOURCE-DIRECTORY is used as a prefix, and will
#     be concatenated with the corresponding SOURCE-FILE. Only one
#     source directory can be provided! The final source name looks
#     like this:
#     SOURCE-DIRECTORY/SOURCE-FILE
#     If source-dir option is not set, the current directory is used.
#   --output-dir <output-directory>
#     OUTPUT-DIRECTORY is the common writable directory to write
#     video files to. Only output directory is allowed! The files
#     will be written out as one of:
#     OUTPUT-DIRECTORY/SOURCE-FILE ####
#     OUTPUT-DIRECTORY/SOURCE-FILE ####.EXT
#     OUTPUT-DIRECTORY/COMMON-OUTPUT-NAME-PREFIX SOURCE-FILE ####
#     OUTPUT-DIRECTORY/COMMON-OUTPUT-NAME-PREFIX SOURCE-FILE ####.EXT
#     EXT means extension of a source file, if any. For example,
#     in VIDEO0001.mp4, mp4 is EXT
#     #### means a four digit number, like 1234
#     If output-dir option is not set, the current directory is used.
#   --base-name <common-output-name-prefix>
#     Only one common output name prefix is allowed! If specified,
#     the final file name will be:
#     COMMON-OUTPUT-NAME-PREFIX SOURCE-FILE ####
#     COMMON-OUTPUT-NAME-PREFIX SOURCE-FILE ####.EXT
#     If base-name options is not set, the file name will be:
#     SOURCE-FILE ####
#     SOURCE-FILE ####.EXT
#     EXT is an extension of a source file, if any. For example,
#     in VIDEO0002.mp4, mp4 is EXT
#     #### is a four digit number, like 5678
#   -v <source-file>, --video <source-file>
#     SOURCE-FILE is readable video file, with extension or not. This
#     file will be checked if it is of a video file format supported
#     by the currently installed FFmpeg program. If check succeeds,
#     that file will be encoded according to internal parameters set to
#     FFmpeg program. Only one source file per option can be set. Also,
#     from that file will be produced images, if requested. Be wary of
#     the only-image option. When the only-image option is set, there
#     will be no video encoded. That is, only images will be produced.
#     If video options is not set, and if no configuration file is
#     supplied, then program cancels execution.
#   -i  <time-reference>, --image      <time-reference>
#   -oi <time-reference>, --only-image <time-reference>
#     Use TIME-REFERENCE to produce images from a SOURCE-FILE.
#     The valid format for TIME-REFERENCE is set by FFmpeg program,
#     and is as follows:
#     00:00:00.00
#     00:00:00.0
#     00:00:00
#     Multiple TIME-REFERENCE can be supplied for one image option.
#     Each TIME-REFERENCE will be checked for the correct syntax, but
#     not for the duration of a video. Such kind of an error will
#     cause the FFmpeg to produce an error message, and specified image
#     will not be created. Nevertheless, all other images will
#     be created, as well as the program shall continue execution.
#     The only-image option causes only the production of images. That
#     is, no video file will be encoded from a source file. The name
#     for a produced image will be either of:
#     OUTPUT-DIRECTORY/SOURCE-FILE #### TIME-REFERENCE
#     OUTPUT-DIRECTORY/SOURCE-FILE #### TIME-REFERENCE.EXT
#     OUTPUT-DIRECTORY/COMMON-OUTPUT-NAME-PREFIX SOURCE-FILE #### TIME-REFERENCE
#     OUTPUT-DIRECTORY/COMMON-OUTPUT-NAME-PREFIX SOURCE-FILE #### TIME-REFERENCE.EXT
#     COMMON-OUTPUT-NAME-PREFIX SOURCE-FILE #### TIME-REFERENCE
#     COMMON-OUTPUT-NAME-PREFIX SOURCE-FILE #### TIME-REFERENCE.EXT
#     SOURCE-FILE #### TIME-REFERENCE
#     SOURCE-FILE #### TIME-REFERENCE.EXT
#     If no image option is set, no images will be made.
#   -ss <position>
#     This option is sent directly to FFmpeg program, and is described
#     in its documentation. It sets the starting position of an output
#     video file in the input video file. From the documentation of
#     FFmpeg: "When used as an input option (before "-i"), seeks in
#     this input file to position." Only one POSITION is allowed per
#     option. The format of POSITION is the same as for a time
#     reference in the image option. That is:
#     00:00:00.00
#     00:00:00.0
#     00:00:00
#     If ss option is not set, the starting position of an encoded
#     video will be the same as in the source video file.
#   -t <duration>
#     This option is sent directly to FFmpeg program, and is described
#     in its documentation. It sets the duration of the output video
#     file with respect to the input video file. That is to say, the
#     output file will be that much time long. From the documentation
#     of FFmpeg: "When used as an input option (before "-i"), limit the
#     duration of data read from the input file." Only one DURATION
#     per option! The format of DURATION is the same as for a time
#     reference in the image option. That is:
#     00:00:00.00
#     00:00:00.0
#     00:00:00
#     If t option is not set, the duration of the output video file
#     will be the same as that of an input video file.
#
# Option that requires a separate invocation of a program:
#   -c <path-to-file>, --config <path-to-file>
#
# Options that can be specified only once:
#   --source-dir <source-directory>
#   --output-dir <output-directory>
#   --base-name <common-output-name-prefix>
#
# Option that can be repeated multiple times, no limit:
#   -v <source-file>, --video <source-file>
#
# Options that make no sense, and cannot be specified, without the
# -v or --video option:
#   -i  <time-reference>, --image      <time-reference>
#   -oi <time-reference>, --only-image <time-reference>
#   -ss <position>
#   -t  <duration>
#
# Invoke like below:
#   ./convert.bash -c file
#   
#   ./convert.bash -v VIDEO0001.mp4
#   
#   ./convert.bash -v VIDEO0407.mp4 -oi 00:00:04 00:01:22.1 \
#   00:03:24.23 -ss 00:00:10.1 -t 00:04:12
#   
#   ./convert.bash --source-dir /home/roman/Downloads/100MEDIA/ \
#   --output-dir /home/roman/Downloads/RS338276184CN/ \
#   --base-name HTC\ One\ M8 \
#   --video VIDEO0401.mp4 --image 00:00:08 00:00:17 00:02:25 \
#   -ss 00:00:02 -t 00:04:10
#
# Return: 2 if an error occurs
########################################################################
# Specify encoding parameters to FFmpeg
param_v='-f mp4 -c:v libx264 -s 1280x720 -b:v 463k -r ntsc -aspect 16:9 -map_metadata -1 -map 0:0 -threads 5 -y'
# Specify encoding parameters for producing images of video to FFmpeg
param_i='-frames:v 1 -q:v 2 -y'
########################################################################
# DO NOT MODIFY STARTING FROM HERE!!!
# FUNCTION DEFINITIONS
# function to get the input arguments
function load_args () {
    #if [[ $# -lt 2 ]]; then
    #    echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]}"\
    #         "<times-called>"\
    #         "{<array-per-call> | <array-element>...}" 1>&2
    #    return 1
    #elif [[ $# -eq 2 ]] && [[ -v $2 ]] &&
    #         [[ "$(declare -p $2)" =~ "declare -a" ]]; then
    #    # second argument passed is an array from readarray
    #    local -a a=( $2 )
    #else
    #    # all arguments passed are elementes of an array
    #    shift
    #    local -a a=( ${@} )
    #fi
    if [[ $# -lt 2 ]] && ! [[ -v $2 ]]; then
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]}"\
             "<number> {<array-of-elements> | <element>}" 1>&2
        return 1
    fi
        #echo "$0: ${FUNCNAME[0]}: input args: $@" 1>&2
    local -a a=( $2 );
    local input_args_size=${#input_args[*]};
    #echo "$0: input_args_size: $input_args_size" 1>&2;
    #declare -p a;
    #echo "$0: input_args size: ${#input_args[@]}" 1>&2;
    #echo "$0: input_args+a: $((${#input_args[@]} + ${#a[@]}))" 1>&2;
    #return 1;
    for (( c = 0; c < ${#a[@]}; c++ ));
    do {
        input_args[$(($input_args_size+$c))]=${a[$c]};
        #echo "$0: input_args[$(($input_args_size+$c))]:" \
        #     "${input_args[$(($input_args_size+$c))]}" 1>&2;
        #exit 2;
        #declare -p input_args;
    }
    done
}
# check if the configuration file is of a correct format
check_config_file() {
    local file="ASCII text"
    if ! (( $# )); then
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]}"\
             "<file-to-check>" 1>&2
        return 1
    fi
    [[ -f "$1" ]] && eval local permissions=$(stat -Lc "%A" "$1") &&
        [[ "${permissions:1:1}" == "r" ]] || {
            echo "$0: ${FUNCNAME[0]}: can't read a file: \"$1\"" 1>&2;
            return 1; }
    #{ echo -n "$0: ${FUNCNAME[0]}: read: " &&
    #  file "$1" | grep -i "ASCII text"; } || {
    #    echo "$0: ${FUNCNAME[0]}: not an ASCII text: \"$1\"" 1>&2;
    #    return 1; }
    { file "$1" | grep -iq "$file" && echo "$0: ${FUNCNAME[0]}: read:"\
                                         "\"$1\"" 1>&2; } || {
        echo "$0: ${FUNCNAME[0]}: not an \"$file\": \"$1\"" 1>&2;
        return 1; }
}
# read in the arguments for a command line or a configuration file
function read_in_args {
    if ! (( $# )); then
        echo "$0: ${FUNCNAME[0]}: there are no arguments to read" 1>&2
        return 1
        #else
        #echo "$0: ${FUNCNAME[0]}: number of input arguments: $#" 1>&2
        #echo "$0: ${FUNCNAME[0]}: input argumets: $@" 1>&2
        #local -a args=( $@ )
        #declare -p args
        #load_args 1 "${args[*]}"
        #declare -p input_args
        # get all arguments from a command line
        #load_args 1 $@
    fi
    #declare -a input_args
    # currently set option
    local opt=NA
    local p_opt=$opt
    # first option run
    local c=0
    # all know options except for -c and --config
    #all="--source-dir|--output-dir|--base-name|\
    #-v|--video|-i|--image|-oi|--only-image|-ss|-t"
    while (( $# )); do {
        #echo "$0: ${FUNCNAME[0]}: next argument is $1" 1>&2
        case $1 in
            -c|--config)
                #if ! [[ "$flag" ]]; then
                #    { [[ "$2" ]] && check_config_file $2 &&
                #          unset -v input_args &&
                #          readarray -C load_args -c 1 < $2 &&
                #          local flag=config; } || {
                #        echo "$0: ${FUNCNAME[0]}: \"$2\" not a valid"\
                #             "configuration file" 1>&2;
                #        return 1; }
                #else
                #    echo "$0: ${FUNCNAME[0]}: only one"\
                #         "configuration file is allowed:"\
                #         "ignoring: \"$1\" \"$2\"" 1>&2
                #fi
                #local ignore_config=yes

                # option set
                local opt=config;
                # clear up the path
                unset -v cfg
                # set previous opt if for the first time
                [[ $c -eq 0 ]] && eval local p_opt=$opt &&
                    # p_opt is set here only for the first time
                    eval local c=1
                ;;
            --source-dir|--output-dir|--base-name|\
                -v|--video|-i|--image|-oi|--only-image|-ss|-t)
                # if any other options known of, set opt
                local opt=all
                # clear up the path
                #unset -v path_all
                # set previous opt if for the first time
                [[ $c -eq 0 ]] && eval local p_opt=$opt &&
                    # p_opt is set here only for the first time
                    eval local c=1
                # add known option to the list
                load_args 1 $1
                ;;
            *)
                case $opt in
                    config)
                        # if config file set, concatenate
                        [[ -n "$cfg" ]] &&
                            eval local cfg+="\ $1" ||
                                # otherwie, assign a new file
                                eval local cfg="$1"
                        ;;
                    all)
                        ##echo "${FUNCNAME[0]}: $1: invalid option" 1>&2
                        ## if the previous argument was config, and a
                        ## configuration was read or attempted to be
                        ## read,then ignore the argument. Otherwise,
                        ## add argument to the list of arguments
                        #[[ -n $flag || -n $ignore_config ]] ||
                        #    #echo "$0: ${FUNCNAME[0]}: flag" 1>&2
                        #    load_args 1 $1
                        ##load_args 1 $1 || load_args 1 $2
                        #unset -v ignore_config

                        # the option that is known about was found,
                        # work on it later on

                        # if path_all set, concatenate
                        #[[ -n "$path_all" ]] &&
                        #    eval local path_all+="\ $1" ||
                        #        # otherwie, assign a new file
                        #        eval local path_all="$1"

                        # a known option was set, add to the list
                        load_args 1 $1
                        ;;
                    *)
                        echo "$0: ${FUNCNAME[0]}: unknown option:"\
                             "\"${opt}\": ignoring argument:"\
                             "\"$1\"" 1>&2
                        local opt=NA
                        ;;
                esac
                ;;
        esac
        # evaluate the options
        if ! [[ ${p_opt} =~ ${opt} ]] ||
                ! [[ -n "$2" ]]; then
            case $p_opt in
                config)
                    # remove spurious slashes
                    local temp=$(echo -n ${cfg} | tr -s '\/')
                    local cfg=$temp
                    # check, and if OK, add to a list of input args
                    if check_config_file "${cfg}"; then
                            echo "$0: ${FUNCNAME[0]}:"\
                                 "configuration file that will be"\
                                 "added after all other command line"\
                                 "options: \"${cfg}\"" 1>&2;
                    else
                        echo "$0: ${FUNCNAME[0]}: ignoring"\
                             "configuraiton file: \"${cfg}\"" 1>&2;
                    fi
                    ;;
                all)
                    # load a known argument
                    #load_args 1 $1

                    # the argument was already added
                    :
                    ;;
                *)
                    echo "$0: ${FUNCNAME[0]}: TERRIBLE internal ERROR:"\
                         "ignoring argument: \"$1\":"\
                         "ignoring option: \"${opt}\"" 1>&2
                    exit 2;
                    ;;
            esac
        fi
        # remember the proviously set option
        local p_opt=$opt
        # next argument
        shift;
    }
    done

    if [[ -n $cfg ]]
    then
        # make a temporary file to hold configurations set in
        local tmp=$(mktemp)
        # allow black lines, comments in a configuration file
        # tabs are handled by readarray shell builtin command
        sed -e 's/#.*//' -e '/^$/ d' < "$cfg" > "$tmp" || {
            echo "$0: ${FUNCNAME[0]}: TERRIBLE internal ERROR:"\
                 "could NOT prune the file: \"$cfg\"" 1>&2;
            return 1; }
        # if configuration file is set, read in the args from a file
        #[[ -n $cfg ]] && readarray -C load_args -c 1 < "${cfg}" || {
        #    echo "$0: ${FUNCNAME[0]}: NOT a valid"\
        #         "configuration file: \"${cfg}\"" 1>&2; }
        # if file is not empty, read in the arguments from a file
        [[ -s "$tmp" ]] && readarray -C load_args -c 1 < "$tmp" || {
                echo "$0: ${FUNCNAME[0]}: NOT a valid configuration"\
                     "file: \"$cfg\"" 1>&2; }
        rm -f "$tmp"
    fi
}
check_if_dir() {
    if [[ $# -eq 2 ]] && [[ -d "$1" ]] &&
           eval local perm=$2 && [[ ${#perm} -eq 1 ]]; then
        #echo "$0: ${FUNCNAME[0]}: number of args: \"$#\"" 1>&2
        #echo "$0: ${FUNCNAME[0]}: input argumets: \"$@\"" 1>&2
        [[ -d $1 ]] && eval local permissions=$(stat -Lc "%A" "$1") &&
            [[ ( ${permissions:0:4} =~ $2 ) ]] && return 0 || {
                echo "$0: ${FUNCNAME[0]}: NOT \"${perm}\" directory:"\
                     "\"$1\"" 1>&2; return 1; }
    else
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]} <directory>"\
             "<permission>" 1>&2
        return 1
    fi
}
add_trailing_slash() {
    if [[ $# -eq 1 ]] && [[ -d $1 ]]; then
        local dir=$1
        if [[ ( "${dir:(-1)}" =~ "/" ) ]]; then
            local dir=${dir%/}
            add_trailing_slash $dir
        else
            dir+="/"
            echo "$dir"
            return 0
        fi
    else
        return 1
    fi
}
check_video() {
    if [[ $# -ne 1 ]] && [[ ! -r $1 ]]; then
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]}"\
             "<source-video>" 1>&2;
        return 1
    fi
    # check video if parameters to FFmpeg are set
    [[ -n $param_v ]] || {
        echo "$0: ${FUNCNAME[0]}: internal parameters to FFmpeg"\
             "are NOT set" 1>&2; return 1; }
    # check if video can be encoded with the set parameters
    ffmpeg -t 00:00:01 -i "$1" $param_v /dev/null > /dev/null 2>&1 &&
        return 0 || { echo "$0: ${FUNCNAME[0]}: video will NOT be"\
                           "encoded: \"$1\"" 1>&2;
                      return 1; }
}
output_video() {
    if [[ $# -ne 2 ]] && ! [[ -f $1 ]] && ! [[ $2 =~ ^[0-9]+$ ]]; then
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]}"\
             "<source-video> <video-number>" 1>&2
        return 1
    else
        local vd=$1 VN=$2
        #echo "$0: ${FUNCNAME[0]}: source-video: \"$vd\":"\
        #     "video-number: \"$VN\"" 1>&2
    fi
    # example of the source video file name:
    # /home/roman/VIDEO0001.mp4
    # example of the output video file name:
    # /home/roman/new camera VIDEO0001 0000.mp4
    #
    # get filename: 'VIDEO0001.mp4'
    #local temp_name=$(
    #    echo $vd | awk -F'/' '{ print $NF }')
    # get filename: 'new camera VIDEO0001.mp4'
    #local temp=${matrix[name,$VN,0]}
    #local temp+="\ ${temp_name}"
    # get (last) extension, if any: 'mp4'
    #local ext=$(
    #    echo $vd | awk -F'[.]' '{ print $NF }')
    # catch a bug when a path to a video is ./<video> without extension
    local ext=$(
        echo $vd | awk -F'[.]' '/.+[.][^./]*$/ { print $NF }')
    # get basename-extended: 'VIDEO0001'
    local basename_extended=$(
        echo $vd | awk '{ gsub(/.*[/]|[.]{1}[^.]+$/, "", $0) } 1')
    # catch a bug when the extension is not set
    [[ -z $basename_extended ]] &&
        local basename_extended=$(
            echo $vd | awk '{ gsub(/.*[/]/, "", $0) } 1')
    # get path: '/home/roman/'
    #local path=$(
    #    echo $vd | awk '{ match($0, /.*[/]/, a); print a[0] }')
    # construct output for the current video
    if ! [[ -n ${matrix[output,$VN,0]} ]]; then
    local c=$(($VN-1));
    while [[ $c -ge 0 ]]; do {
        if [[ -n ${matrix[output,$c,0]} ]]; then {
            matrix[output,$VN,0]=${matrix[output,$c,0]};
            break;
        }; else {
            local temp=$(($c-1));
            local c=$temp;
            # echo "$0: ${FUNCNAME[0]}: counter: $c";
        }; fi;
    }; done;
    fi
    # get output directory if any
    local path=${matrix[output,$VN,0]}
    # construct base-name for the current video
    if ! [[ -n ${matrix[name,$VN,0]} ]]; then
    local c=$(($VN-1));
    while [[ $c -ge 0 ]]; do {
        if [[ -n ${matrix[name,$c,0]} ]]; then {
            matrix[name,$VN,0]=${matrix[name,$c,0]};
            break;
        }; else {
            local temp=$(($c-1));
            local c=$temp;
            # echo "$0: ${FUNCNAME[0]}: counter: $c";
        }; fi;
    }; done;
    fi
    # get filename with prefix: '/home/roman/new camera VIDEO0001'
    #local name=${path}
    #[[ -n "${matrix[name,$VN,0]}" ]] &&
    #    eval local name+="${matrix[name,$VN,0]}\ "
    #local name+=${basename_extended}
    [[ -n "${matrix[name,$VN,0]}" ]] &&
        printf -v name "%s%s %s" "${path}" "${matrix[name,$VN,0]}"\
               "${basename_extended}" ||
            printf -v name "%s%s" "${path}" "${basename_extended}"
    # for later use, if the name alredy exists
    local test_name=$name
    # output video numbers should be remember between invocations
    # get the first sequential video number
    local test_vn=$(printf "%0*d" 4 "$unique_video_number")
    # construct the output file name:
    # /home/roman/new camera VIDEO0001 0000.mp4
    #local name+="\ ${test_vn}"
    #[[ -n $ext ]] && eval local name+=".${ext}"
    [[ -n $ext ]] &&
        printf -v name "%s %s.%s" "$test_name" "$test_vn" "$ext" ||
            printf -v name "%s %s" "$test_name" "$test_vn"
    # done
    #echo "$0: ${FUNCNAME[0]}: first output video"\
    #     "name: \"$name\"" 1>&2
    # check if file exists, change number
    while [[ -e $name ]]; do
        echo "$0: ${FUNCNAME[0]}: output video file name exists:"\
             "\"$name\"" 1>&2;
        # test for counter overflow
        [[ $(( 10#${test_vn} )) -ge 9999 ]] && {
            echo "$0: ${FUNCNAME[0]}: failed to construct an output"\
                 "file name for source video: \"$vd\"" 1>&2;
            echo "$0: ${FUNCNAME[0]}: last output name tried:"\
                 "\"$name\"" 1>&2;
            return 1; }
        # increase the counter by 1
        local temp=10#${test_vn}
        local test_vn=$(printf "%0*d" 4 $(($temp+1)))
        # try the name with an increased counter
        # construct the output file name, like:
        # /home/roman/new camera VIDEO0001 0001.mp4
        #local name=$test_name
        #local name+="\ ${test_vn}"
        #[[ -n $ext ]] && eval local name+=".${ext}"
        [[ -n $ext ]] &&
            printf -v name "%s %s.%s" "$test_name" "$test_vn" "$ext" ||
                printf -v name "%s %s" "$test_name" "$test_vn"
        # done, test again
    done
    # file with the set name should not exist

    # do the final redundant test
    # attempt to read one character from a file name $name,
    # if that fails, then create the file, and write one character
    # to the created file. If that succeeds, remove the file,
    # return 0. Otherwise, return 1, ERROR
    #local file='1';
    #read -N 1 file < "${name}" > /dev/null 2>&1 ||
    #    { echo ${test_file} > "${name}" 2> /dev/null &&
    #            rm -f "${name}" &&
    #             echo "File \"${name}\" does not exist,"\
    #                  "and can be created"; }
    # if file does not exist, write a string to file specified,
    # if that has NOT succeeded, return ERROR
    if [[ ! -e $name ]] && echo "test" > "${name}" 2> /dev/null &&
           rm -f "${name}"; then
        # save the constructed name
        matrix[video,$VN,1]=$name
        # save the sequential number for a later use
        #unique_video_number=$test_vn
        # catch a bug when a unique_video_number is considered to be
        # an octal number while it is a decimal number
        unique_video_number=$(( 10#${test_vn} ))
        # OK
        return 0
    else
        # ERROR, keep name and number unchanged
        return 1
    fi
}
check_reference() {
    if [[ $# -ne 1 ]]; then
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]}"\
             "<time-reference>" 1>&2
        return 1
    else
        local tref=$1
        #echo "$0: ${FUNCNAME[0]}: time reference: \"$tref\"" 1>&2
    fi
    # valid format for TIME-REFERENCE is set by FFmpeg program,
    # and is as either of:
    # 00:00:00.00
    # 00:00:00.0
    # 00:00:00
    # gawk script to check the format of a TIME-REFERENCE
#    echo "$tref" | awk -F'[:]' '{
#if (NF == 3) {
#for (i=1; i <= NF-1; i++) {
#if ($i ~ /^[0-9]{2}$/) { printf "field: %d: 00 = %s\n", i, $i }
#else { print $0;
#printf "NOT a valid field: %d: 00 = %s\n", i, $i;
#exit 1 }
#}
#if ($NF ~ /^[0-9]{2}$|^[0-9]{2}[.][0-9]{1}$|^[0-9]{2}[.][0-9]{2}$/) {
#printf "field: %d: 00.0 or 00.00 = %s\n", NF, $NF }
#else { print $0;
#printf "NOT a valid field: %d: 00.0 or 00.00 = %s\n", NF, $NF;
#exit 1 }
#}
#else { print $0;
#printf "number of fields is incorrect: %d\n", NF;
#exit 1 }
    #}' && echo yes || echo no

    # check tref, return error if of NOT valid format
    echo "$tref" | awk -F'[:]' '{
if (NF == 3) {
for (i=1; i <= NF-1; i++) {
if ($i ~ /^[0-9]{2}$/) { }
else { print $0;
printf "NOT a valid field: %d: 00 = %s\n", i, $i;
exit 1 }
}
if ($NF ~ /^[0-9]{2}$|^[0-9]{2}[.][0-9]{1}$|^[0-9]{2}[.][0-9]{2}$/) { }
else { print $0;
printf "NOT a valid field: %d: 00.0 or 00.00 = %s\n", NF, $NF;
exit 1 }
}
else { print $0;
printf "number of fields is incorrect: %d\n", NF;
exit 1 }
}' && return 0 || return 1
}
output_image() {
    if [[ $# -eq 4 ]] && [[ -f $1 ]] && check_reference "$2" &&
       [[ $3 =~ ^[0-9]+$ ]] && [[ $4 =~ ^[0-9]+$ ]]; then
        local vd=$1 tref=$2 VN=$3 unique_image_number=$4
        #echo "$0: ${FUNCNAME[0]}: source video: \"$vd\":"\
        #     "time reference: \"$tref\": video-number: \"$VN\":"\
        #     "unique-image-number: \"$unique_image_number\"" 1>&2
    else
        #[[ $# -eq 3 ]] &&
        #    echo "$0: ${FUNCNAME[0]}: 3 input args" 1>&2
        #[[ -f $1 ]] &&
        #    echo "$0: ${FUNCNAME[0]}: 1st arg is a file: \"$1\"" 1>&2
        #check_reference "$2" &&
        #    echo "$0: ${FUNCNAME[0]}: 2nd arg has a correct time"\
        #         "reference: \"$2\"" 1>&2
        #[[ $3 =~ ^[0-9]+$ ]] &&
        #    echo "$0: ${FUNCNAME[0]}: 3rd arg has a valid video"\
        #         "number: \"$3\"" 1>&2
        #[[ $4 =~ ^[0-9]+$ ]] &&
        #    echo "$0: ${FUNCNAME[0]}: 4th arg is a unique image"\
        #         "number: \"$4\"" 1>&2
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]}"\
             "<source-video> <time-reference> <video-number>"\
             "<unique-image-number>" 1>&2
        return 1
    fi
    # example of the source video file name:
    # /home/roman/VIDEO0001.mp4
    # exampble of the output image file name:
    # /home/roman/Downloads/new camera VIDEO0001 0000 00.00.00.mp4
    #
    # get path for an output file: '/home/roman/Downloads'
    local path=${matrix[output,$VN,0]}
    # get base-name for an output file: 'new camera'
    local b_name=${matrix[name,$VN,0]}
    # get basename-extended: 'VIDEO0001'
    local b_ext=$(
        echo $vd | awk '{ gsub(/.*[/]|[.]{1}[^.]+$/, "", $0) } 1' )
    # get sequential image number: '0000'
    local n_name=$( printf "%0*d" 4 "$unique_video_number" )
    # get time reference: '00.00.00'
    local n_tref=$( echo -n ${tref} | tr '[:]' '[.]' )
    # get (last) extension, if any: 'mp4'
    #local ext=$( echo $vd | awk -F'[.]' '{ print $NF }' )
    # set an extension to: 'jpg'
    local ext='jpg'
    # check if the base-name is set, construct an intermediate name:
    # /home/roman/Downloads/new camera VIDEO0001
    #local int_name=''
    #if [[ "$b_name" ]]; then
    #    printf -v int_name "%s%s %s" "$path" "$b_name" "$b_ext"
    #else
    #    printf -v int_name "%s%s"    "$path"           "$b_ext"
    #fi
    # check if base-name is set, construct the final name:
    # /home/roman/Downloads/new camera VIDEO0001 0000 00.00.00.mp4
    local name=''
    if [[ "$b_name" ]]; then
        printf -v name "%s%s %s %s %s.%s"\
               "$path" "$b_name" "$b_ext" "$n_name" "$n_tref" "$ext"
    else
        printf -v name "%s%s %s %s.%s"\
               "$path"           "$b_ext" "$n_name" "$n_tref" "$ext"
    fi
    # do final checks
    if [[ ! -e $name ]] && echo "test" > "$name" 2> /dev/null &&
           rm -f "$name"; then
        # save the constructed name
        matrix[image,$VN,$unique_image_number]=$name
        # save time reference for later use
        matrix[iseek,$VN,$unique_image_number]=$tref
        # increment unique image number
        #let unique_image_number++
        # OK
        return 0
    elif [[ -e $name ]]; then
        # generate random file name
        local NEW_FILE=''
        local file=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' |\
                            fold -w 32 | head -n 1)
        printf -v NEW_FILE "%s%s" "$path" "$file"
        # test if NEW_FILE can be written out
        if echo "test" > "$NEW_FILE" 2> /dev/null &&
                rm -f "$NEW_FILE"; then
            echo "$0: ${FUNCNAME[0]}: will OVERWRITE: \"$name\"" 1>&2
            # save file name till later
            matrix[image,$VN,$unique_image_number]=$name
            # save time reference for later use
            matrix[iseek,$VN,$unique_image_number]=$tref
            return 0
        else
            echo "$0: ${FUNCNAME[0]}: file exists but cannot"\
                 "overwrite: ignoring: \"$name\"" 1>&2;
            return 1;
        fi
    else
        echo "$0: ${FUNCNAME[0]}: NO output image for: \"$name\"" 1>&2
        return 1
    fi
}
add_mkdir() {
    if [[ $# -eq 2 ]] && [[ -d $1 ]] && [[ $2 =~ ^[0-9]+$ ]]
    then
        local dir=$1 VN=$2
    else
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]}"\
             "<directory> <video-number>" 1>&2
        return 1
    fi
    # build a reversed stack of created directories
    #
    # do not touch the 0's slot since it is used to construct
    # the path to a video file
    local c=1
    # find a not occupied slot to place the path to directory in
    while [[ ${matrix[output,$VN,$c]:+_} ]]
    do
        let c++
    done
    # assign the directory
    matrix[output,$VN,$c]=$dir
}
parse_args() {
    if [[ $# -ne 1 ]]; then
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]}"\
             "<array[@]>" 1>&2
        return 1
    fi
    # copy of all the arguments to work with
    local -a arg_ary=("${!1}")
    #echo "$0: ${FUNCNAME[0]}: \"${arg_ary[@]}\"" 1>&2
    #echo "$0: ${FUNCNAME[0]}: number of args $#" 1>&2
    # associative array to put the verified args to
    #declare -A matrix
    # currently set option, and previously set option
    local opt=NA
    local p_opt=$opt
    # each video option should be regarded as a separate option
    # currently set video option, and previous option
    local v_opt=new
    local v_p_opt=$v_opt
    # video options counter
    local vcn=0
    local p_vcn=$vcn
    # temporary substitution for video counter
    local VN=0
    for (( c=0; c < ${#arg_ary[@]}; c++ )); do
        case ${arg_ary[$c]} in
            -c|--config)
                # clear up the path
                unset -v cfg
                # mark an option set, and previously set option
                local opt=config
                [[ $c -eq 0 ]] && eval local p_opt=$opt
                ;;
            --source-dir)
                # clear up the path
                unset -v sd
                # mark an option set, and previously set option
                local opt=source-dir
                [[ $c -eq 0 ]] && eval local p_opt=$opt
                ;;
            --output-dir)
                # clear up the path
                unset -v od
                # mark an option set, and previously set option
                local opt=output-dir
                [[ $c -eq 0 ]] && eval local p_opt=$opt
                ;;
            --base-name)
                # can be set only once per video specified
                unset -v bn
                # mark an option set, and if it's the first one,
                # set the previous option
                local opt=base-name
                [[ $c -eq 0 ]] && eval local p_opt=$opt
                ;;
            -i|--image)
                # can be set only once per video option
                unset -v img icn only_image
                # mark an option set
                # if it was a first option, set the previous option
                local opt=image
                [[ $c -eq 0 ]] && eval local p_opt=$opt
                # images and video will be made
                unset -v only_image
                ;;
            -oi|--only-image)
                # can be set only once for each video option provided
                unset -v img icn
                # mark image option set, and set previous if necessary
                local opt=image
                [[ $c -eq 0 ]] && eval local p_opt=$opt
                # set special only image flag for producing only images
                local only_image='YES'
                ;;
            -ss)
                # can be set only once for every video option set
                unset -v pos
                # mark option set, if the first, set previous option
                local opt=position
                [[ $c -eq 0 ]] && eval local p_opt=$opt
                ;;
            -t)
                # only once per video option
                unset -v dur
                # mark option set, set previous option if first call
                local opt=duration
                [[ $c -eq 0 ]] && eval local p_opt=$opt
                ;;
            -v|--video)
                # next video option should be recognized
                # set an old video to process
                local vd=$vf
                #
                # only one name per video option
                unset -v vf
                #unset -v vd
                # mark an option set
                local opt=video
                # if it's the first option set, set the previous option
                [[ $c -eq 0 ]] && eval local p_opt=$opt
                #
                # set recognition for a separate video option
                #if [[ $c -ne 0 ]]; then
                #local vn_opt=$(($vc_opt+1))
                #if [[ ${arg_ary[$(($c+1))]} == '-v' ]] ||
                #       [[ ${arg_ary[$(($c+1))]} == '--video' ]]; then
                #    # next time change state for video options
                #    #local v_temp=$v_opt
                #    local vc_opt=0
                #    local vn_opt=0
                #    if [[ $vn_opt -eq 2 ]]; then
                #    # if v_opt is new, then set it to old
                #    [[ ${v_opt} == "new" ]] &&
                #        eval local v_opt="old" ||
                #            # otherwise, set v_opt to new
                #            eval local v_opt="new"
                #    # reset video option counter
                #    local vn_opt=0
                #fi
                #else
                #    # keep the state as it is now
                #    :
                #fi                   
                #elif [[ $c -eq 0 ]]; then
                    # if called the first time, set the previous option
                    #local v_opt="new"
                    #local v_p_opt=$v_opt
                #fi
                
                if [[ $vcn -gt $p_vcn ]]; then
                    if [[ ${v_opt} == "new" ]]; then
                        local v_opt="old"
                    elif [[ ${v_opt} == "old" ]]; then
                        local v_opt="new"
                    else
                        echo "$0: ${FUNCNAME[0]}: $p_opt: TERRIBLE"\
                             "internal ERROR: currently set video"\
                             "option: \"${v_opt}\": previously set"\
                             "video option: \"${p_v_opt}\"" 1>&2
                        exit 2
                    fi
                elif [[ $vcn -eq $p_vcn ]]; then
                    # if video is set for the first time,
                    # ignore it here
                    :
                else
                    # current counter is less than the previous
                    # counter, that should NOT have happend
                    echo "$0: ${FUNCNAMR[0]}: $p_opt: TERRIBLE"\
                         "internal ERROR: video options counter:"\
                         "\"$vcn\": is NOT greater or equal to"\
                         "the previous video options counter:"\
                         "\"$p_vcn\"" 1>&2
                    echo "$0: ${FUNCNAME[0]}: $p_opt: TERRIBLE"\
                         "internal ERROR: currently set video option:"\
                         "\"${v_opt}\": previously set video"\
                         "option: \"${p_v_opt}\"" 1>&2
                    exit 2

                fi
                # save for a check later on
                local p_vcn=$vcn
                # count video options set
                let vcn++
                ;;
            *)
                case $opt in
                    config)
                        #echo "$0: ${FUNCNAME[0]}: argument was"\
                        #     "passed to \"${arg_ary[$(($c-1))]}\":"\
                        #     "ignoring: \"${arg_ary[$c]}\"" 1>&2
                        ##unset -v opt
                        #local opt=NA

                        # if set config file, concatenate
                        [[ -n "$cfg" ]] &&
                            eval local cfg+="\ ${arg_ary[$c]}" ||
                        # otherwise, assign a new file
                                eval local cfg="${arg_ary[$c]}";
                        ;;
                    source-dir)
                        # if source directory set, concatenate
                        [[ -n "$sd" ]] &&
                            eval local sd+="\ ${arg_ary[$c]}" ||
                                # otherwise, assign a new dir
                                eval local sd="${arg_ary[$c]}";
                        # multiple args concatenated
                        #local opt=NA
                        ;;
                    output-dir)
                        # if destination directory set, concatenate
                        [[ -n "$od" ]] &&
                            eval local od+="\ ${arg_ary[$c]}" ||
                                # otherwise, assign a new out dir
                                eval local od="${arg_ary[$c]}";
                        ;;
                    base-name)
                        # if name is set, concatenate
                        [[ -n "$bn" ]] &&
                            eval local bn+="\ ${arg_ary[$c]}" ||
                                # otherwise, set a new name
                                eval local bn="${arg_ary[$c]}"
                        ;;
                    image)
                        # setup a local indexed array to keep args in
                        #declare -a img
                        # set the counter if not yet set
                        if [[ -n $icn ]] && [[ -n "${img[0]}" ]]; then
                            # increment counter
                            let icn++
                        else
                            # set the first counter
                            local icn=0
                        fi
                        # concatenate arguments to the option
                        # set the time reference into an array
                        local img[$icn]="${arg_ary[$c]}"
                        ;;
                    position)
                        # NO concatenation is allowed here
                        # only one argument per option, and the last
                        # one is used
                        local pos="${arg_ary[$c]}"
                        ;;
                    duration)
                        # NO concatenation of arguments, only ONE
                        # the last one passed will be used
                        local dur="${arg_ary[$c]}"
                        ;;
                    video)
                        # if name is already set, concatenate
                        [[ -n "$vf" ]] &&
                            eval local vf+="\ ${arg_ary[$c]}" ||
                                # otherwise, set a new name
                                eval local vf="${arg_ary[$c]}"
                        ;;
                    *)
                        echo "$0: ${FUNCNAME[0]}: $p_opt: unknown"\
                             "option: \"${opt}\": ignoring argument:"\
                             "\"${arg_ary[$c]}\"" 1>&2
                        local opt=NA
                        ;;
                esac
                #unset -v opt
                # reset the opt for a previous option
                #local opt=NA
                ;;
        esac
        
        #--video
        #echo "$0: ${FUNCNAME[0]}: current option: \"${opt}\":"\
        #     "previous option: \"${p_opt}\"" 1>&2
        #echo "$0: ${FUNCNAME[0]}: current video option: \"${v_opt}\":"\
        #     "previous video option: \"${v_p_opt}\"" 1>&2
        #echo "$0: ${FUNCNAME[0]}: current path: \"${vf}\"" 1>&2
        #echo "$0: ${FUNCNAME[0]}: previous path: \"${vd}\"" 1>&2
        
        # check if the option has changed, or last: finalise arg
        if ! [[ ${p_opt} =~ ${opt} ]] ||
                ! [[ ${v_p_opt} =~ ${v_opt} ]] ||
                       ! [[ -n ${arg_ary[$(($c+1))]} ]]; then
            case $p_opt in
                config)
                    echo "$0: ${FUNCNAME[0]}: $p_opt: ignoring:"\
                         "\"${cfg}\": do NOT reference config from"\
                         "the configuration file" 1>&2
                    ;;
                source-dir)
                    # remove spurious slashes
                    local temp=$(echo -n ${sd} | tr -s '\/')
                    local sd=$temp
                    # check, and if OK, add to a list of args
                    if check_if_dir "${sd}" "r"; then
                        #echo "$0: ${FUNCNAME[0]}: source directory:"\
                        #     "\"${sd}\"" 1>&2
                        # assing path with a trailing slash
                        matrix[source,$VN,0]=$(echo -n ${sd} |\
                                                      sed 's/\/*$/\//')
                        #echo "$0: ${FUNCNAME[0]}: parsed arguments"\
                        #     "are:" 1>&2
                        #declare -p matrix;
                    else
                        echo "$0: ${FUNCNAME[0]}: $p_opt: ignoring:"\
                             "source directory: \"${sd}\"" 1>&2;
                    fi
                    ;;
                output-dir)
                    #echo "$0: ${FUNCNAME[0]}: output directory:"\
                    #     "\"${od}\"" 1>&2;
                    # remove spurious slashes
                    local temp=$(echo -n ${od} | tr -s '\/')
                    local od=$temp
                    # directory in question, add traling slash
                    local dir=$(echo -n ${od} | sed 's/\/*$/\//')
                    #local dir=$od
                    # do multiple checks
                    if check_if_dir "$dir" "w"; then
                        # skip to an end for assigment
                        :
                    elif [[ -d $dir ]]; then
                        chmod u+w "$dir"
                        echo "$0: ${FUNCNAME[0]}: $p_opt:"\
                             "made writable: \"${dir}\"" 1>&2;
                    elif ! [[ -n $dir ]]; then
                        echo "$0: ${FUNCNAME[0]}: $p_opt: output"\
                             "directory is NOT set: \"${dir}\"" 1>&2
                    elif [[ -f $(echo -n $dir | sed 's/\/*$//') ]]; then
                        echo "$0: ${FUNCNAME[0]}: $p_opt:"\
                             "that is a file: \"${dir}\"" 1>&2
                    else
                        # catch a bug of passing options to mkdir
                        # and chmod, like -v or --verbose
                        local temp=$dir
                        local dir=$(echo -n ${temp} |\
                                           sed 's/^[^[:alnum:]\/]*//')
                        # make dir, change permission to writable,
                        # and inform about the job done
                        { mkdir "$dir" &&
                                chmod u+w "$dir" &&
                                add_mkdir "$dir" "$VN" &&
                                echo "$0: ${FUNCNAME[0]}: $p_opt:"\
                                     "created directory:"\
                                     "\"${dir}\"" 1>&2; } || {
                            echo "$0: ${FUNCNAME[0]}: $p_opt:"\
                                 "TERRIBLE internal ERROR: directory"\
                                 "was NOT created: \"${dir}\"" 1>&2; 
                            exit 2; }
                    fi
                    # if directory is valid, add it
                    if check_if_dir "${dir}" "w"; then
                        # assing path with a slash
                        matrix[output,$VN,0]=$(echo -n ${dir} |\
                                                      sed 's/\/*$/\//')
                        #echo "$0: ${FUNCNAME[0]}: parsed arguments"\
                        #     "are:" 1>&2
                        #declare -p matrix;
                    else
                        echo "$0: ${FUNCNAME[0]}: $p_opt: ignoring:"\
                             "destination directory: \"${dir}\"" 1>&2
                    fi
                    ;;
                base-name)
                    # only alphanumeric characters allowed
                    local temp=$(echo -n ${bn} | tr -d '[[:punct:]]')
                    local bn=$temp
                    # add to the file's name
                    matrix[name,$VN,0]=$bn
                    ;;
                image)
                    # check if the source video is present
                    # this option make no sense without a video file
                    if [[ $VN -eq 0 ]]; then
                        echo "$0: ${FUNCNAME[0]}: $p_opt: video"\
                             "option was NOT set: NO source video:"\
                             "\"${matrix[video,$VN,0]}\"" 1>&2
                        # prevent the execution of the rest of case
                        unset -v img
                    elif [[ $VN -gt 0 ]]; then
                        # reference prevoius video set
                        local ivn=$(($VN-1))
                        # if only-image option set, produce no video
                        if [[ "$only_image" ]]; then
                            matrix[video,$ivn,2]='NO'
                            unset -v only_image
                            echo "$0: ${FUNCNAME[0]}: $p_opt:"\
                                 "NO output video file:"\
                                 "\"${matrix[video,$ivn,1]}\"" 1>&2
                        else
                            #echo "$0: ${FUNCNAME[0]}: $p_opt: make"\
                            #     "images and output video file:"\
                            #     "\"${matrix[video,$ivn,1]}\"" 1>&2
                            :
                        fi
                    else
                        echo "$0: ${FUNCNAME[0]}: $p_opt: TERRIBLE"\
                             "internal ERROR: video counter is:"\
                             "\"$VN\"" 1>&2
                        exit 2
                    fi
                    #echo "$0: ${FUNCNAME[0]}: $p_opt: image set:" 1>&2
                    #declare -p img
                    # images for the current video file were set
                    # unique image number:
                    local uin=0
                    # set up valid argument
                    for (( icn=0; icn < ${#img[@]}; icn++ )); do
                        # get the current time reference
                        local time=${img[$icn]}
                        # check each time reference
                        if check_reference "${time}"; then
                            # source video name should be set
                            local v_time=${matrix[video,$ivn,0]}
                            #echo "$0: ${FUNCNAME[0]}: $p_opt:"\
                            #     "source video: \"$v_time\"" 1>&2
                            # output video name should be set
                            if [[ -n "${v_time}" ]]; then
                                if output_image "${v_time}" "${time}"\
                                                "$ivn" "$uin"; then
                                    let uin++
                                else 
                                    echo "$0: ${FUNCNAME[0]}: $p_opt:"\
                                         "NO output image for time"\
                                         "referece: \"$time\"" 1>&2
                                fi
                            else
                                echo "$0: ${FUNCNAME[0]}: $p_opt:"\
                                     "NO source video: ignoring:"\
                                     "time reference: \"$time\"" 1>&2
                            fi  
                        else
                            echo "$0: ${FUNCNAME[0]}: $p_opt:"\
                                 "ignoring: time reference:"\
                                 "\"$time\"" 1>&2
                        fi
                    done
                    # precaution
                    unset -v ivn only_image uin icn time v_time
                    ;;
                position)
                    # source video should be set for this option
                    if [[ $VN -eq 0 ]]; then
                        echo "$0: ${FUNCNAME[0]}: $p_opt: video"\
                             "option was NOT set: NO source video:"\
                             "\"${matrix[video,$VN,0]}\"" 1>&2
                    elif [[ $VN -gt 0 ]]; then
                        # take the previous source video file
                        local ivn=$(($VN-1))
                        # check the time reference
                        if check_reference "$pos"; then
                            # correct time reference, add it
                            matrix[video,$ivn,3]=$pos
                        else
                            echo "$0: ${FUNCNAME[0]}: $p_opt:"\
                                 "ignoring: time reference:"\
                                 "\"$pos\"" 1>&2
                        fi
                    else
                        echo "$0: ${FUNCNAME[0]}: $p_opt: TERRIBLE"\
                             "internal ERROR: video counter is:"\
                             "\"$VN\"" 1>&2
                        exit 2
                    fi
                    # precaution
                    unset -v pos ivn
                    ;;
                duration)
                    # source video should be set!
                    if [[ $VN -eq 0 ]]; then
                        echo "$0: ${FUNCNAME[0]}: $p_opt: video"\
                             "option was NOT set: NO source video:"\
                             "\"${matrix[video,$VN,0]}\"" 1>&2
                    elif [[ $VN -gt 0 ]]; then
                        # reference a previous video source set
                        local ivn=$(($VN-1))
                        # check the time reference
                        if check_reference "$dur"; then
                            # correct, add
                            matrix[video,$ivn,4]=$dur
                        else
                            echo "$0: ${FUNCNAME[0]}: $p_opt:"\
                                 "ignoring: time reference:"\
                                 "\"$dur\"" 1>&2
                        fi
                    else
                        echo "$0: ${FUNCNAME[0]}: $p_opt: TERRIBLE"\
                             "internal ERROR: video counter is:"\
                             "\"$VN\"" 1>&2
                        exit 2
                    fi
                    # precaution
                    unset -v dur ivn
                    ;;
                video)
                    # if old video is not set, set it to a new one
                    # catches the bug for a last video option set
                    #! [[ -n $vd ]] && eval local vd=$vf
                    # catch a bug with the last video option set
                    #! [[ -n ${arg_ary[$(($c+1))]} ]] && local vd="$vf"
                    [[ -n ${vf} ]] && local vd=$vf
                    # remove spurious slashes
                    local temp=$(echo -n ${vd} | tr -s '\/')
                    local vd=$temp
                    # remove traling slash if any, we are talking
                    # about a file here, not a directory
                    local temp=$(echo -n ${vd} | sed 's/\/*$//')
                    local vd=$temp
                    # construct source for the current video
                    if ! [[ -n ${matrix[source,$VN,0]} ]]; then
                    local t=$(($VN-1));
                    while [[ $t -ge 0 ]]; do {
                        if [[ -n ${matrix[source,$t,0]} ]]; then {
                            matrix[source,$VN,0]=${matrix[source,$t,0]};
                            break;
                        }; else {
                            local temp=$(($t-1));
                            local t=$temp;
                            # echo "$0: ${FUNCNAME[0]}: counter: $t";
                        }; fi;
                    }; done;
                    fi
                    # construct the final path to the video file
                    #local temp=${matrix[source,$VN,0]}
                    #local temp+=$vd
                    #local vd=$temp
                    local temp=$vd
                    printf -v vd "%s%s" "${matrix[source,$VN,0]}"\
                           "$temp"
                    # do multiple checks
                    if ! [[ -r $vd ]]; then
                        echo "$0: ${FUNCNAME[0]}: $p_opt: NOT readable"\
                             "video source: ignoring: \"$vd\"" 1>&2
                    elif ! [[ -s $vd ]]; then
                        echo "$0: ${FUNCNAME[0]}: $p_opt: size is NOT"\
                             "greater than zero: ignoring:"\
                             "\"$vd\"" 1>&2
                    elif check_video "${vd}"; then
                        # file is of supported format, add to a list
                        matrix[video,$VN,0]=$vd
                        #echo "$0: ${FUNCNAME[0]}: $p_opt: source"\
                        #     "video: \"$vd\"" 1>&2
                        # increment unique video counter
                        let unique_video_number++
                        # construct an output name for a video file
                        output_video "${vd}" $VN || {
                            echo "$0: ${FUNCNAME[0]}: $p_opt:"\
                                 "NO output video for: \"$vd\"" 1>&2;
                            matrix[video,$VN,2]='NO'; }
                        # options source-dir, output-dir, and base-name
                        # refer to the next video file specified
                        local temp=$VN
                        local VN=$(($temp+1))
                    else
                        echo "$0: ${FUNCNAME[0]}: $p_opt: ignoring:"\
                             "video file: \"$vd\"" 1>&2
                    fi
                    # work with the next video
                    unset -v vd
                    ;;
                *)
                    echo "$0: ${FUNCNAME[0]}: $p_opt: TERRIBLE"\
                         "internal ERROR: ignoring argument:"\
                         "\"${arg_ary[$c]}\": ignoring option:"\
                         "\"${opt}\"" 1>&2
                    exit 2;
                    ;;
            esac
        fi
        # remember the proviously set option
        local p_opt=$opt
        # remember a separate video option
        local v_p_opt=$v_opt
    done
}
print_header() {
    if [[ $# -ne 2 ]]; then
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]} <header>"\
             "<padding-char>" 1>&2
        return 1
    fi
    
    # headed for a section
    #local header=$1
    # the header should not have more characters than COLUMNS
    local header=$(echo -n "$1" | fold -sw $(($COLUMNS - 2)) | head -n 1)
    # use character as a padding
    local padding_char=$2
    [[ ${#padding_char} -eq 1 ]] || {
        echo "$0: ${FUNCNAME[0]}: <padding-char> should be one"\
             "character long, but is: \"$padding_char\"" 1>&2;
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]} <header>"\
             "<padding-char>" 1>&2;
        return 1; }

    # get the size of paddings for a termenal window
    local padding=$(( ($COLUMNS - ${#header} - 2) / 2 ))
    # catch a bug of misplaced header
    local remainder=$(( ($COLUMNS-${#header}-2) % 2 ))
    # set up the format string for printf
    #local format="#%-*s${header}%-*s#"
    # get the line with a space as a padding
    #local line
    #printf -v line "$format" $padding " " $padding " "
    # print the line with a padding_char as a padding
    #printf "%s\n" ${line// /$padding_char}
    # setup the format string
    local format="#%s${header}%s#"
    # construct padding using a padding_char as a padding
    local pdc2=$(printf "%*s" $padding | tr ' ' "$padding_char")
    # catch a bug of misplaced header
    local pdc1=$(printf "%*s" $(($remainder + $padding)) |\
                        tr ' ' "$padding_char")
    # print the line
    printf "$format\n" "$pdc1" "$pdc2"
}
print_path() {
    if [[ $# -ne 1 ]]; then
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]}"\
             "<path>" 1>&2
        return 1
    elif [[ -z "$1" ]]; then
        echo "$0: ${FUNCNAME[0]}: path should NOT be of zero"\
             "length, but is: \"$1\"" 1>&2
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]}"\
             "<path>" 1>&2
        return 1
    fi
    # by now the path should be a valid string of characters
    # not longer that the width of a terminal window plus "#  #"
    local -a path
    readarray -t path <<< $(
        printf "%s\n" "$(echo "$1" | fold -sw $(($COLUMNS - 4)))" )
    # construct the path for printing
    local p
    for p in "${!path[@]}"
    do
        # get the padding if necessary, minus "#  #"
        local pdc=$(($COLUMNS - ${#path[$p]} - 4))
        # construct padding string of spaces
        local padding=$(printf "%*s" $pdc)
        # get the current output string
        local out_path
        printf -v out_path "# %s%s #\n" "${path[$p]}" "$padding"
        # build the final output string, concatenate
        local final_path old_path
        printf -v final_path "%s%s" "$old_path" "$out_path"
        local old_path=$final_path
    done
    # print the line or lines
    printf "%s" "$final_path"
}
print_output() {
    if [[ $# -ne 3 ]]; then
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]} <string>"\
             "<string> <padding-char>" 1>&2
        return 1
    fi
    local padding_char=$3
    [[ ${#padding_char} -eq 1 ]] || {
        echo "$0: ${FUNCNAME[0]}: <padding-char> should be one"\
             "character long, but is: \"$padding_char\"" 1>&2;
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]} <string>"\
             "<string> <padding-char>" 1>&2;
        return 1; }

    # setup the strings for a header
    local -a st0=([0]="POSITION" [1]="OUTPUT" [2]="DURATION")
    # set up the local varibles for later use
    #local st1=$1                      st2=$2

    # construct the header strings
    local c
    for c in "${!st0[@]}"
    do
    # cut header strings if necessary, don't forget about "#--#"
        local hd0[$c]=$(
            echo -n "${st0[$c]}" |\
                fold -sw $(( ($COLUMNS - 4) / ${#st0[@]} )) |\
                head -n 1)
    done
    # add padding if necessary
    local last_element=$((${#hd0[@]}-1))
    for c in "${!hd0[@]}"
    do
        # minus 4 is for "#--#"
        local pdc[$c]=$(( ( ($COLUMNS-4)/${#hd0[@]} )-${#hd0[$c]} ))
        # construct padding string
        case $c in
            0|$last_element)
                local add=$((${pdc[$c]} +
                             ( ( ($COLUMNS - 4) % ${#hd0[@]} ) /
                               ( ${#hd0[@]} - 1) ) ));
                local padding[$c]=$(printf "%*s" ${add} |\
                                           tr ' ' "$padding_char")
                ;;
            *)
                local padding[$c]=$(printf "%*s" ${pdc[$c]} |\
                                           tr ' ' "$padding_char")
                ;;
        esac
    done
    # construct the header line
    for c in "${!hd0[@]}"
    do
        local final_line old_line new_line
        if [[ $c -eq 0 ]]; then
            # first line
            printf -v new_line "%s%s" "${hd0[$c]}" "${padding[$c]}"
            printf -v final_line "%s%s" "$old_line" "$new_line"
            local old_line=$final_line
        elif (( $c == ${#hd0[@]} - 1)); then
            # last line
            printf -v new_line "%s%s" "${padding[$c]}" "${hd0[$c]}"
            printf -v final_line "%s%s" "$old_line" "$new_line"
            local old_line=$final_line
        else
            # middle line
            #local point=$((${#padding[$c]} / 2))
            # bug when a center point is a bit shifted to the left
            local point=$(( (${#padding[$c]}/2)+(${#padding[$c]}%2) ))
            printf -v new_line "%s%s%s" "${padding[$c]:0:$point}"\
                   "${hd0[$c]}" "${padding[$c]:$point:$point}"
            printf -v final_line "%s%s" "$old_line" "$new_line"
            local old_line=$final_line
        fi
    done
    # align the line with the terminal window. Probably caused by
    # numerous devision. This is a stupid hack to make an output
    # look nice
    local add=$(($COLUMNS - 4 - ${#final_line}))
    local p_add=$(printf "%*s" $add | tr ' ' "$padding_char")
    # print the header line
    #printf "#%s%s%s#\n" "$padding_char" "$final_line" "$padding_char"
    printf "#%s%s%s%s#\n" "$padding_char" "$final_line"\
           "$padding_char" "$p_add"

    # print two passed strings
    # truncate the strings if necessary
    local st1=$(echo -n "$1" | fold -sw $(( ($COLUMNS - 4) / 2 )) |\
                       head -n 1)
    local st2=$(echo -n "$2" | fold -sw $(( ($COLUMNS - 4) / 2 )) |\
                       head -n 1)
    # get the length of the combined strings
    #local cstr
    #printf -v cstr "%s%s" "$st1" "$st2"
    #local ln=${#cstr}
    # padding string's length
    #local ln=$(($COLUMNS - 4 - ${#cstr}))
    local ln=$(($COLUMNS - 4 - ${#st1} - ${#st2}))
    # make a padding string
    local padding=$(printf "%*s" $ln)
    # construct the line
    local final_line
    printf -v final_line "%s%s%-s" "$st1" "$padding" "$st2"
    # align the line with the width of a window
    local add=$(($COLUMNS - 4 - ${#final_line}))
    local p_add=$(printf "%*s" $add)
    # print the line with two strings
    printf "# %s%s #\n" "$final_line" "$p_add"
}
review_args() {
    if ! [[ $# -eq 1 ]]; then
        echo "$0: ${FUNCNAME[0]}: there are no arguments to make"\
             "a review for" 1>&2
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]}"\
             "\"\$(declare -p <associative-array>)\"" 1>&2
        return 1
    fi
    # make a local associative array to hold args in
    #declare -A ary=( "${!1}" )
    eval "declare -A ary="${1#*=}
    #echo "$0: ${FUNCNAME[0]}: arguments to review:" 1>&2
    #declare -p ary

    # catch a bug when COLUMNS global variable seems to be NOT set
    #echo "$0: ${FUNCNAME[0]}: COLUMNS: \"$COLUMNS\"" 1>&2
    [[ $COLUMNS =~ ^[0-9]+$ ]] || COLUMNS=72
    
    #==========================SOURCE==================================#
    # /home/roman/Downloads/100MEDIA/VIDEO0405.mp4                     #
    #-POSITION-----------------OUTPUT-------------------------DURATION-#
    # 00:00:00.00                                          00:00:00.00 #
    # /home/roman/Downloads/OUT/iPhone 5g LCD digitizer                #
    #  defective.mp4                                                   #
    #--------------------------IMAGES----------------------------------#
    # /home/roman/Downloads/OUT/iphone 5g 0002 00.00.30.33.jpg         #
    # /home/roman/Downloads/OUT/iphone 5g 0004 00.00.01.01.jpg         #

    # open a new line
    echo "$0: ${FUNCNAME[0]}: review:" 1>&2
    # loop through key and values in an associative array
    local VN v=video i=image
    #for VN in "${!ary[$v,@,0]}"
    local type=video
    local total=$(for key in "${!ary[@]}"; do echo $key; done |\
                      sed -n '/'"$type"'/p' | sort -r | head -n 1 |\
                      awk -F'[,]' '{ print $2 }' | tr -d '\n')
    [[ ${total:+_} ]] || {
        echo "$0: ${FUNCNAME[0]}: TERRBLE internal ERROR: NO video:"\
             "quitting" 1>&2
        return 1; }
    for (( VN=0; VN <= $total; VN++ ))
    do
        # if set print source header, and path to a source file
        #echo "$0: ${FUNCNAME[0]}: source: \"${ary[$v,$VN,0]}\"" 1>&2
        #echo "$0: ${FUNCNAME[0]}: video number: \"$VN\"" 1>&2
        [[ ${ary[$v,$VN,0]+_} ]] && print_header "SOURCE" "=" &&
            print_path "${ary[$v,$VN,0]}" || {
                echo "$0: ${FUNCNAME[0]}: FAILED to print source" 1>&2;
                return 1; }
        # if out set, and only-image option is NOT set print output
        if ! [[ ${ary[$v,$VN,2]+_} ]]; then
            # print output video header and path
            [[ ${ary[$v,$VN,1]+_} ]] &&
                print_output "${ary[$v,$VN,3]:-MIN}"\
                             "${ary[$v,$VN,4]:-MAX}" "-" &&
                print_path "${ary[$v,$VN,1]}" || {
                    echo "$0: ${FUNCNAME[0]}: FAILED to print"\
                         "output" 1>&2;
                    return 1; }
        else
            # do not print output header and path
            :
        fi
        # if set print images
        if [[ ${ary[$i,$VN,0]+_} ]]; then
            print_header "IMAGES" "-"
            local uin=0
            #for uin in "${!ary[$i,$VN,@]}"
            while [[ ${ary[$i,$VN,$uin]:+_} ]]
            do
                print_path "${ary[$i,$VN,$uin]}" || {
                    echo "$0: ${FUNCNAME[0]}: FAILED to print"\
                         "image" 1>&2;
                    return 1; }
                let uin++
            done    
        fi
    done
    # open a new line
    echo 1>&2
}
delete_dir() {
    if ! (( $# ))
    then
        echo "$0: ${FUNCNAME[0]}: usage ${FUNCNAME[0]}"\
             "<empty-directory>" 1>&2
        return 1
    fi
    # use find to do all the job
    #if [[ $(find "$1" -maxdepth 0 -type d -empty -perm -u=w) ]]
    #then
    #    rm -rf "$1" &&
    #        echo "$0: ${FUNCNAME[0]}: REMOVED: \"$1\"" 1>&2 ||
    #        { echo "$0: ${FUNCNAME[0]}: FAILED to"\
    #               "delete empty writable directory: \"$1\"" 1>&2;
    #          return 1; }
    #else
    #    echo "$0: ${FUNCNAME[0]}: NOT empty or not a directory:"\
    #         "\"$1\"" 1>&2
    #    return 0
    #fi
    find "$1" -maxdepth 0 -type d -empty -perm -u=w -exec rm -rf "{}" \;
}
remove_dir() {
    if ! [[ $# -eq 1 ]]
    then
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]}"\
             "\"\$(declare -p <associative-array>)\"" 1>&2
        return 1
    fi
    # create a local associative array to hold parsed arguments in
    eval "declare -A ary="${1#*=}
    # announcement
    echo "$0: ${FUNCNAME[0]}: clean-up:" 1>&2
    # get the biggest index of output directory, if any
    local type=output
    #local total=$(for key in "${!ary[@]}"; do echo "$key"; done |\
    #                  sed -n '/'"$type"'/p' | sort -r | head -n 1 |\
    #                  awk -F'[,]' '{ print $2 }' | tr -d '\n')
    #[[ ${total:+_} ]] || {
    #    echo "$0: ${FUNCNAME[0]}: TERRIBLE internal ERROR:"\
    #         "NO output: quitting" 1>&2;
    #    return 1; }
    # loop through indexes, if any
    #local VN
    #for (( VN=0; VN <= $total; VN++ ))
    #do
    #    [[ ${ary[$type,$VN,0]:+_} ]] &&
    #        delete_dir "${ary[$type,$VN,0]}" || {
    #            echo "$0: ${FUNCNAME[0]}: FAILED to delete"\
    #                 "directory: \"${ary[$type,$VN,0]}\"" 1>&2;
    #            return 1; }
    #done
    # get an array of unique output directories
    declare -a dir_list
    readarray -t dir_list <<< $(\
        for key in "${!ary[@]}"; do echo "${key}${ary["${key}"]}";\
        done | sed -n '/'"$type"'/p' | awk -F'[]' '{ print $2 }' |\
            sort | uniq)
    # test and if it is empty writable directory, delete it
    for key in "${!dir_list[@]}"
    do
        # produce messages for convenience
        if [[ -z "$(ls -A "${dir_list["${key}"]}" 2>&1)" ]]
        then
            echo "$0: ${FUNCNAME[0]}: empty directory: REMOVED:"\
                 "\"${dir_list["${key}"]}\"" 1>&2
        else
            echo "$0: ${FUNCNAME[0]}: not empty or NOT a directory:"\
                 "\"${dir_list["${key}"]}\"" 1>&2
        fi
        # do the work
        # catch a bug when a directory was not set, use PWD instead
        delete_dir "${dir_list["${key}"]:-$(pwd)}"  || {
            echo "$0: ${FUNCNAME[0]}: FAILED to delete"\
                 "directory: \"${dir_list["${key}"]}\"" 1>&2;
            return 1; }
    done
    # insert a newline
    echo 1>&2
}
encode_image() {
    if [[ $# -eq 4 ]] && [[ -r $1 ]] && check_reference "$3" &&
           [[ -w $4 ]]
    then
        local src=$1 out=$2 ref="-ss $3" err=$4
    else
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]}"\
             "<source-video> <output-image-name> <time-reference>"\
             "<error-file>" 1>&2
        return 1
    fi
    # parameters to FFmpeg should be set in a global variable
    [[ ${param_i:+_} ]] || {
        echo "$0: ${FUNCNAME[0]}: NO parameters are set to pass to"\
             "FFmpeg as an options: quitting" 1>&2;
        return 1; }
    # no overwriting is allowed, prune every -y
    #local par=$(echo -n $param_i | sed 's/-y//g')
    # create an image
    ffmpeg $ref -i "$src" $param_i "$out" || {
        echo "$0: ${FUNCNAME[0]}: ERROR:" >> "$err";
        echo "$0: ${FUNCNAME[0]}: source video: \"$src\"" >> "$err";
        echo "$0: ${FUNCNAME[0]}: output image name:"\
             "\"$out\"" >> "$err";
        echo "$0: ${FUNCNAME[0]}: time reference: \"$3\"" >> "$err"; }
    # even if FFmpeg fails, the program should continue execution
    return 0
}
encode_video() {
    if [[ $# -eq 5 ]] && [[ -r $1 ]] && [[ -w $5 ]]
    then
        # source and output
        local src=$1 out=$2
        # check starting point
        if [[ $3 =~ ^MIN$ ]]
        then
            #unset -v ss
            local ss=''
        else
            check_reference "$3" && local ss="-ss $3" || {
                    echo "$0: ${FUNCNAME[0]}: FAILED check for"\
                         "time reference: \"$3\"" 1>&2;
                    return 1; }
        fi
        # check finishing point
        if [[ $4 =~ ^MAX$ ]]
        then
            #unset -v t
            local t=''
        else
            check_reference "$4" && local t="-t $4" || {
                    echo "$0: ${FUNCNAME[0]}: FAILED check for"\
                         "time reference: \"$4\"" 1>&2;
                    return 1; }
        fi
        # errro log
        local err=$5
    else
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]}"\
             "<source-video> <output-video> {<position> | MIN}"\
             "{<duration> | MAX} <error-file>" 1>&2
        return 1
    fi
    # global parameter to pass to FFmpeg should be set
    [[ ${param_v:+_} ]] || {
        echo "$0: ${FUNCNAME[0]}: NO parameters are set to pass to"\
             "FFmpeg as an options: quitting" 1>&2;
        return 1; }
    # make a unique prefix for two-pass log file name
    #local log=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 |\
    #                   head -n 1)
    # catch a bug of changed directories, construct a full path
    #local dir=$(pwd)
    #local srcf outf
    #printf -v srcf "%s/%s" "$dir" "$src"
    #printf -v outf "%s/%s" "$dir" "$out"
    # catch a bug of a trailing slash
    local dir=$(pwd | sed 's/\/*$/\//')
    local srcf outf
    # set up a temporary directory for an encoding
    local tmp=$(mktemp -d)
    pushd "$tmp" > /dev/null
    # catch a bug of already set full path
    if [[ -r $src ]]
    then
        local srcf=$src
    else
        printf -v srcf "%s%s" "$dir" "$src"
    fi
    if ! [[ -e $out ]] && echo "test" > "$out" 2> /dev/null &&
            rm -f "$out"
    then
        local outf=$out
    else
        printf -v outf "%s%s" "$dir" "$out"
    fi
    # create a video
    ffmpeg $ss $t -i "$srcf" $param_v -pass 1 /dev/null &&
        ffmpeg $ss $t -i "$srcf" $param_v -pass 2 "$outf" || {
            echo "$0: ${FUNCNAME[0]}: ERROR:" >> "$err";
            echo "$0: ${FUNCNAME[0]}: source video:"\
                 "\"$srcf\"" >> "$err";
            echo "$0: ${FUNCNAME[0]}: output video:"\
             "\"$outf\"" >> "$err";
            echo "$0: ${FUNCNAME[0]}: position: \"$3\"" >> "$err";
            echo "$0: ${FUNCNAME[0]}: duration: \"$4\"" >> "$err"; }
    # return to the previous directory, remove temporary directory
    popd > /dev/null
    rm -rf "$tmp"
    # should not fail
    return 0
}
encode_all() {
    if [[ $# -eq 2 ]] && [[ -f $2 ]]
    then
        # create a local associative array to hold parsed args
        eval "declare -A ary="${1#*=}
        # file to pass errors to
        local err=$2
    else
        echo "$0: ${FUNCNAME[0]}: usage: ${FUNCNAME[0]}"\
             "\"\$(declare -p <associative-array>)\" <error-file>" 1>&2
        return 1
    fi
    # get the biggest index of video file set, should be at lease some
    local type=video
    local total=$(for key in "${!ary[@]}"; do echo "$key"; done |\
                      sed -n '/'"$type"'/p' | sort -r | head -n 1 |\
                      awk -F'[,]' '{ print $2 }' | tr -d '\n')
    [[ ${total:+_} ]] || {
        echo "$0: ${FUNCNAME[0]}: TERRIBLE internal ERROR:"\
             "NO video to encode: quitting" 1>&2;
        return 1; }
    # do the job
    local VN=0 v=video i=image s=iseek
    for (( VN=$total; VN >= 0; VN-- ))
    do
        # do image
        if [[ ${ary[$i,$VN,0]:+_} ]]
        then
            local uin=0
            while [[ ${ary[$i,$VN,$uin]:+_} ]]
            do
                encode_image "${ary[$v,$VN,0]}"\
                             "${ary[$i,$VN,$uin]}"\
                             "${ary[$s,$VN,$uin]}"\
                             "$err" || {
                    echo "$0: ${FUNCNAME[0]}: FAILED to encode image"\
                         "for: \"${ary[$v,$VN,0]}\"" 1>&2;
                    return 1; }
                let uin++
            done
        else
            echo "$0: ${FUNCNAME[0]}: NO output image for:"\
                 "\"${ary[$v,$VN,0]}\"" 1>&2
        fi
        # do video
        if [[ ${ary[$v,$VN,2]} =~ ^NO$ ]]
        then
            echo "$0: ${FUNCNAME[0]}: NO output video for:"\
                 "\"${ary[$v,$VN,0]}\"" 1>&2
        else
            encode_video "${ary[$v,$VN,0]}"\
                         "${ary[$v,$VN,1]}"\
                         "${ary[$v,$VN,3]:-MIN}"\
                         "${ary[$v,$VN,4]:-MAX}"\
                         "$err" || {
                echo "$0: ${FUNCNAME[0]}: FAILED to encode video for:"\
                     "\"${ary[$v,$VN,0]}\"" 1>&2;
                return 1; }
        fi
    done
}
########################################################################
# DO NOT MODIFY STARTING FROM HERE!!!

# an indexed array to hold the input arguments
declare -a input_args;
#echo $2;
#readarray -C load_args -c 1 < $2;
# check the read-in options
#declare -p input_args;
# read command line arguments
#echo "$0: input arguments: $@" 1>&2;
#args=( $@ );
# get input options
# if no input arguments, terminate with error
read_in_args $@ || {
    echo "$0: TERRIBLE internal ERROR: quitting" 1>&2; exit 2; }
#echo "$0: input arguments are:" 1>&2;
#declare -p input_args;

# produce unique output video file names
unique_video_number=0;
# get a sequential set of images to produce in matrix[image,0,@]
#unique_image_number=0;
# an associative array to hold the parsed values
declare -A matrix;
# parse input options
parse_args input_args[@] || {
    echo "$0: TERRIBLE internal ERROR: quitting" 1>&2; exit 2; }
#echo "$0: parsed arguments are:" 1>&2;
#declare -p matrix;

# check if there is at least one option of type set
type=video
check=$(for key in "${!matrix[@]}"; do echo "$key"; done |\
            sed -n '/'"$type"'/p' | sort | head -n 1 |\
            awk -F'[,]' '{ print $1 }' | tr -d '\n')
if [[ $check =~ ^${type}$ ]]
then
    # out parsed arguments for a review
    #review_args matrix[@] || {
    #    echo "$0: TERRIBLE internal ERROR: quitting" 1>&2; exit 2; }
    # get the width of a terminal window
    COLUMNS=$(tput cols)
    # do the review
    review_args "$(declare -p matrix)" || {
        echo "$0: TERRIBLE internal ERROR: quitting" 1>&2; exit 2; }

    # get the user input, process
    while true
    do
        read -p "Do you want to continue? [Y/n/?] " answer
        case ${answer:0:1} in
            Y)
                # set up a temporary file for errors aggregate
                error=$(mktemp)
                echo "$0: processing..." 1>&2
                encode_all "$(declare -p matrix)" "$error" || {
                    echo "$0: TERRIBLE internal ERROR: quitting" 1>&2;
                    cat "$error"; rm -f "$error"; exit 2; }
                # concatenate errors if any
                [[ -s "$error" ]] && {
                    echo 1>&2;
                    echo "$0: ERROR listing:" 1>&2;
                    cat "$error"; } || {
                    echo 1>&2;
                    echo "$0: NO errors during processing:"\
                         "that is weird" 1>&2; }
                # no longer needed
                rm -f "$error"
                break
                ;;
            n|N)
                echo 1>&2
                echo "$0: canceling..." 1>&2
                # for the very least one output directory should
                # have been set by now
                #echo "$0: clean-up:" 1>&2
                #remove_dir "$(declare -p matrix)" || {
                #    echo "$0: TERRIBLE internal ERROR: quitting" 1>&2;
                #    exit 2; }
                break
                ;;
            \?)
                echo "$0: Y: proceed to conversion" 1>&2
                echo "$0: n, N, no, No, NO: cancel and remove"\
                     "created folders" 1>&2
        esac
    done
    #echo "$0: clean-up:" 1>&2
    remove_dir "$(declare -p matrix)" || {
        echo "$0: TERRIBLE internal ERROR: quitting" 1>&2;
        exit 2; }
else
    # no option of type found, cancel, clean-up
    echo "$0: has NOT found option of type: \"$type\"" 1>&2
    # check if at the leaset one output directory is set
    # this test is necassary since the output-dir option might have
    # created a directory
    if [[ ${matrix[output,0,0]+_} ]]
    then
        #echo "$0: clean-up:" 1>&2
        remove_dir "$(declare -p matrix)" || {
            echo "$0: TERRIBLE internal ERROR: quitting" 1>&2;
            exit 2; }
    else
        echo "$0: NO clean-up is necessary: quitting" 1>&2
        echo 1>&2
    fi
fi

# global clean up
unset -v param_v param_i input_args unique_video_number;
unset -v unique_image_number COLUMNS matrix answer;
unset -v type check error;
echo "$0: DONE!" 1>&2
########################################################################
