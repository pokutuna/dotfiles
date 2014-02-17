#!/bin/bash
function fd () {
    if [ $# -eq 0 ]; then
        echo "Usage: $ $(basename $0) [PATH FRAGMENT]..."
        return 1;
    fi

    arg=($@)

    # search from
    search_from=''
    if [ `echo ${arg[1]} | grep -E '^\.'` ]; then
        echo 'has_search_from'
        search_from=${arg[1]}
        arg=($arg[2,$(echo ${#arg[@]})])
    fi

    name=${arg[${#arg[@]}]}
    path_fragments=($arg[1,$(echo ${#arg[@]}-1)])

    path_pattern=''
    if [ -n ${#path_fragments[0]} ]; then
        for fragment in $path_fragments; do
        # if [ `echo ${fragment} | grep ',$'` ]; then
        #     sep='/'
        #     fragment=`echo ${fragment} | sed 's/,$//'`
        # else
        #     sep='*'
        # fi
            path_pattern="${path_pattern}*${fragment}"
        done
    fi

    if [ -z $path_pattern ]; then
        command="find ${search_from:-.} -type d -iname '${name}*'"
    else
        command="find ${search_from:-.} -type d -ipath '${path_pattern}*' -iname '${name}*'"
    fi
    echo $command
    result=$(eval $command)

    if [ $(echo $result | wc -l) -eq 1 ] && [ -n "${result}" ]; then
        echo $result
        cd $result
        return 0
    else
        echo $result
        return 1
    fi
}
