#!/bin/bash
time_out_clean_up()
{
    trap - ALRM
    echo KILL ${a[@]}
    kill -ALRM ${a[@]} 2>/dev/null
    echo P ${p[@]}
    kill $! 2>/dev/null &&
      return 124
}

time_out_watcher()
{
    trap "time_out_clean_up" ALRM
    sleep $1& wait
    kill -ALRM $$
}

time_out ()
{
    time_out_watcher $1& a+=( $! )
    shift
    trap "time_out_clean_up" ALRM INT
    "$@"& p+=( $! ) ; wait $!; RET=$?
    kill -ALRM $a 2>/dev/null 
    wait $a
    return $RET
}

func ()
{
    i=0
    while [ $i -le $1 ]
    do
        if [[ $(( $i % 100000 )) -eq 0 ]]; then
            echo i : $i
        fi
        i=$(( $i + 1 ))
    done

    echo Finished at $i
    return 0
}

set -x

time_out 1 func 200
echo RET $?
time_out 10 func 200
echo RET $?
time_out 0.0001 func 20000
echo RET $?
