#!/bin/bash
IFS=$'\n'
demoFun1() {
        data1=`cat $1`
        ips1=`echo "$data1" | grep -E -o "assets_value\"\:\"[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}" | grep -E -o "[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}"`
        ports1=`echo "$data1" | grep -E -o "port\"\:\"[0-9]*" | grep -E -o "[0-9]*"`
        http1=`echo "$data1" | grep -E -o "service_name\"\:\"[a-zA-Z0-9\-]*" | grep -E -o "\:\".*" | awk -F"\"" '{print $2}'`

        echo "$ips1" > 1_ips.txt
        echo "$ports1" > 1_ports.txt
        echo "$http1" > 1_http.txt

        new=`paste 1_ips.txt 1_ports.txt 1_http.txt`
        echo "$new" > /tmp/news_test.txt
        for each1 in `echo "$new" | awk -F"\t" '{print $3":"}'`
        do
            if [[ $each1 = ":" ]]
            then
                echo "unknow" >> /tmp/1tmp_test.txt
            else
                echo "$each1" | sed 's/://g' >> /tmp/1tmp_test.txt
            fi
        done
        Res1=`paste /tmp/news_test.txt /tmp/1tmp_test.txt  | awk -F"\t" '{print $1"\t"$2"\t"$4}' | sort -k 1`
        echo "$Res1" | sort -k 1 > /root/ShareFile/results/News_test.txt
        rm 1_ips.txt 1_ports.txt 1_http.txt 
        rm  /tmp/1tmp_test.txt /tmp/news_test.txt
}

demoFun2() {
        data2=`cat $1`
        ips2=`echo "$data2" | grep -E -o "assets_value\"\:\"[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}" | grep -E -o "[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}"`
        ports2=`echo "$data2" | grep -E -o "port\"\:\"[0-9]*" | grep -E -o "[0-9]*"`
        http2=`echo "$data2" | grep -E -o "service_name\"\:\"[a-zA-Z0-9\-]*" | grep -E -o "\:\".*" | awk -F"\"" '{print $2}'`

        echo "$ips2" > 2_ips.txt
        echo "$ports2" > 2_ports.txt
        echo "$http2" > 2_http.txt

        old=`paste 2_ips.txt 2_ports.txt 2_http.txt`
        echo "$old" > /tmp/old_test.txt
        for each2 in `echo "$old" | awk -F"\t" '{print $3":"}'`
        do
            if [[ $each2 = ":" ]]
            then
                echo "unknow" >> /tmp/2tmp_test.txt
            else
                echo "$each2" | sed 's/://g' >> /tmp/2tmp_test.txt
            fi
        done
        Res2=`paste /tmp/old_test.txt /tmp/2tmp_test.txt  | awk -F"\t" '{print $1"\t"$2"\t"$4}' | sort -k 1`
        echo "$Res2" > /tmp/Olds_test.txt
        rm 2_ips.txt 2_ports.txt 2_http.txt 
        rm /tmp/2tmp_test.txt /tmp/old_test.txt
}

if [[ $1 != '' ]] && [[ $2 != '' ]]
then
    demoFun1 $1
    demoFun2 $2
    paste /root/ShareFile/results/News_test.txt /tmp/Olds_test.txt
    echo "Out data has -------------------------------------------------"
    for each3 in `cat /tmp/Olds_test.txt`
    do
        R=`cat /root/ShareFile/results/News_test.txt | grep -o "$each3" | head -n 1 | wc -l`
        if [[ $R != 1 ]]
        then
            echo "$each3"  >> /root/ShareFile/results/ott_data.txt
        fi
    done

    echo "New data add has ---------------------------------------------"
    for each4 in `cat /root/ShareFile/results/News_test.txt`
    do
        O=`cat /tmp/Olds_test.txt | grep -o "$each4" | head -n 1 | wc -l`
        if [[ $O != 1 ]]
        then
            echo "$each4"  >> /root/ShareFile/results/add_data.txt
        fi
    done

    rm  /tmp/Olds_test.txt
else
    echo -e "\033[36m 1.need new_data and old_data to process \033[0m";
    echo -e "\033[36m 2.first args must be new data \033[0m";
    echo -e "\033[36m 3.sec args must be old data   \033[0m";
    echo -e "\033[36m 4.need /root/ShareFile/results directory to saveing results \033[0m";
fi
