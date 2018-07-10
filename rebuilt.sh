#!/bin/bash
Item1="httpd|nginx|tomcat"
function DEL {
    read -p "do you want remove saveing file?[Y|N]:" YES
   if [ $YES = "Y" ] 
   then
       echo "removeing files ..."
       rm -fr /root/DeSK_T_L
       rm -fr /root/rebuilt.sh
   else
       echo "nothing to do...."
   fi
}
function LOGS {
    user=`cat /etc/passwd | grep 0:0`
    echo "--------- found user -------------------" >> LOGS.TXT
    echo "$user" >> LOGS.TXT
    if test -f LOGS.TXT
    then
        cat LOGS.TXT | sed 's/^[ ]*//g'
    else
        echo "LOGS.TXT IS NO FOUDN"
    fi
}
function loop {
    a=0
    for each in $path
    do
        save[$a]=$each
        echo "$a $each"
        let "a++"
    done
}
function MAKE {
    mkdir /root/DeSK_T_L
    cd /root/DeSK_T_L
    hmv=`uname -a | grep -o 64 | tail -n 1`
    if [[ $hmv -eq "64" ]]
    then
        echo "64 hm"
        `wget http://192.168.31.199/hm64`
        `chmod +x hm64`
        hm=hm64
    else
        echo "38 hm"
        `wget http://192.168.31.199/hm38`
        `chmod +x hm38`
        hm=hm38
    fi
Dtect

if test -f result.csv
then
    echo "------------ found webshell --------------"
    num=`cat result.csv | grep -E "^[0-9]" | grep -E -o "\/.*" | wc -l`
    path=`cat result.csv | grep -E "^[0-9]" | grep -E -o "\/.*"`
    nums=`expr $num - 1`
    loop
    while (( $num>0  ))
    do
        read -p  "which one do you want to check?:" -a array
        for each in ${array[@]}
        do
            case $each in
                "q")
                    echo "quit...."
                    num=-1
                    break
                    ;;
                *)
                    ite=`cat ${save[$each]}`
                    echo "$ite"
                    loop
                    ;;
            esac
        done
    done
else
    echo "RESULT.CSV IS NO FOUND" 
    echo "--------- NOT FOUND  WEBSHELS! -----------"
fi
LOGS
DEL
}
function scan {
    if test -d $1
    then
        echo "...scaning"
        ./$hm scan $1
    fi
}
function conf {
    case $1 in
        httpd)
            Hsave=`cat /etc/httpd/conf/httpd.conf | grep -E "CustomLog|LogFormat|DocumentRoot"`
            log1=`echo "$Hsave" | grep -E "CustomLog|LogFormat"`
            echo "httpd.conf logs is : $log1"
            echo "-------------- httpd logs ---------------" >> LOGS.TXT
            echo "$log1" >> LOGS.TXT
            dir1=`echo "$Hsave" | grep -E "DocumentRoot.*\/.*" | cut -f 2 -d "\""`
            scan $dir1
            ;;
        nginx)
            Nsave=`cat /etc/nginx/nginx.conf | grep -E "access_log|server|root.*\/"`
            log2=`echo "$Nsave" | grep access_log`
            echo "nginx.conf logs is : $log2"
            echo "-------------- nginx logs ---------------" >> LOGS.TXT
            echo "$log2" >> LOGS.TXT
            dir2=`echo "$Nsave" | grep root | grep -E -o "\/.*[^;]"`
            scan $dir2
            ;;
        tomcat)
            Tsave=`find /etc/tomcat* -name server.xml | xargs cat`
            log3=`echo "$Tsave" | tail -n 10 | head -n 5`
            echo "server.xml logs is : $log3"
            echo "-------------- tomcat logs --------------" >> LOGS.TXT
            echo "$log3" >> LOGS.TXT
            dir3=`echo "$Tsave" | grep -E -o "appBase.*" | cut -f 2 -d \"`
            Find=`find / -name $dir3 | grep tomcat | tail -n 1`
            scan $Find
            ;;
        *)echo "nothing in here !"
            ;;
    esac
}
function Dtect {
    for each in `echo $Item1 | awk -F"|" '{print $1,$2,$3}'`
    do
        type $each 2> /dev/null | sed '/.*/d'
        case $? in
            0)
                echo "$each have been installed"
                conf $each
                ;;
        esac
    done
}
MAKE
