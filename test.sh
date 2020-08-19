#!/bin/bash
time_out_clean_up()
{
    trap - ALRM               #reset handler to default
    kill -ALRM $a 2>/dev/null #stop timer subshell if running
    kill $! 2>/dev/null &&    #kill last job
      return 124                #exit with 124 if it was running
}

time_out_watcher()
{
    trap "time_out_clean_up" ALRM
    sleep $1& wait
    kill -ALRM $$
}

time_out ()
{
    time_out_watcher $1& a=$!
    shift
    trap "time_out_clean_up" ALRM INT
    "$@"& wait $!; RET=$?
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

for (( x = 0 ; x < 10 ; x++ ))
do

    time_out 1 func 200
done