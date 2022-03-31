#!/bin/bash

function help() {
    echo "--------------------------------------------------------------------------"
    echo "                             Usage information                            "
    echo "--------------------------------------------------------------------------"
    echo "                                                                          "
    echo "  bash check-list_5.0.sh [Options]                                       "
    echo "                                                                          "
    echo "  Options:                                                                "
    echo "  check_before_3402_install                                               "
	echo "  check_before_THP_install                                                "
    echo "                                                                          "
	echo "  check_before_upgrade                                                    "
	echo "                                                                          "
	echo "  check_after_3402_upgrade_chinese                                        "
	echo "  check_after_3402_upgrade_english                                        "
	echo "  check_after_3402_install_chinese                                        "
	echo "  check_after_3402_install_english                                        "
	echo "  check_after_THP_install_chinese                                         "
	echo "  check_after_THP_install_english                                         "
	echo "          			                                                    "
    echo "  Example:                                                                "
    echo "  bash check-list_5.0.sh check_before_3402_install                       "
    echo "--------------------------------------------------------------------------"
    exit 1
}

#清理多余的配置文件
function check_redundant_configuration_files(){
	echo "##------------------------- check redundant configuration files -------------------------------- ----##"
	if [ -f "/etc/my.cnf" ];then
		echo -e "\033[31m please mv /etc/my.cnf /etc/my.cnf_titanbak \033[0m"|tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	elif [ -d "/etc/my.cnf" ];then
		echo -e "\033[31m please mv /etc/my.cnf /etc/my.cnf_titanbak \033[0m"|tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt	
	else
		echo -e "\033[32m redundant configuration files check is ok! \033[0m"
	fi
}

#升级前检查JAVA版本及环境变量_5-7新增
function check_jdk_before_upgrade(){
	echo "##------------------------- CHECK JDK -------------------------------- ----##"
	#检查JDK版本
	jdk_version=`rpm -qa |grep jdk|grep -v qingteng`
	if [[ $jdk_version == "" ]];then
		echo -e "\033[31m JDK is error , please make sure there are only one JDK which version is '1.8.0_144' \033[0m"|tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	else
		for line in $jdk_version; do
			version=`echo $line |grep '1.8.0_144-'`
			if [[ $version == "" ]];then
				echo -e "\033[31m JDK is error , there are one bad jdk : $line \033[0m"|tee -a check-list-log.txt
				echo -e "\033[31m Please remove it and make sure there are only one JDK which version is '1.8.0_144'  \033[0m"|tee -a check-list-log.txt
				echo "" |tee -a check-list-log.txt
			fi
		done
	fi
	echo -e "\033[32m jdk version check end \033[0m"
	#检查JAVA_HOME
	java_home=`echo $JAVA_HOME`
	if [[ $java_home == "/usr/java/default" ]];then
		echo -e "\033[32m java home check is ok! \033[0m"
	else
		echo -e "\033[31m JAVA_HOME is error , JAVA_HOME should be /usr/java/default. now JAVA_HOME is $java_home \033[0m"|tee -a check-list-log.txt
		echo -e "\033[31m Please add 'export JAVA_HOME=/usr/java/default' in /etc/profile and execute command 'source /etc/profile' \033[0m"|tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	fi
	#检查PATH中是配置了java所在路径
	status_path=`echo $PATH|grep '/usr/java/default/bin'`
	if [[ $status_path != "" ]];then
		echo -e "\033[32m java start path check is ok! \033[0m" 
	else
		echo -e "\033[31m PATH is error , java start path should in PATH . Now PATH do not have '/usr/java/default/bin' \033[0m"|tee -a check-list-log.txt
		echo -e "\033[31m Please add 'export PATH=/usr/java/default/bin:$""PATH' in /etc/profile and execute command 'source /etc/profile' \033[0m"|tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	fi
}

#部署前检查系统变量_5-7新增
function check_PATH(){
	echo "##------------------------- CHECK PATH -------------------------------- ----##"
	LANG=`echo $LANG`
	status_LANG=`echo $LANG |grep "en_US.UTF-8"`
	status_PATH=`echo $PATH |grep "/usr/local/bin" `
	openssl=`openssl version`
	status_openssl=`openssl version|grep "1.0.2k-fips"`
	status_yum_conf=`cat /etc/yum.conf |grep "reposdir"`
	#检测LANG是否为en_US.UTF-8
	if [[ $status_LANG == "" ]];then
		echo -e "\033[31m LANG is error : $LANG \033[0m"|tee -a check-list-log.txt
		echo -e "\033[31m Please set LANG to 'en_US.UTF-8' \033[0m"|tee -a check-list-log.txt
		echo -e "\033[31m It is recommended to add by command: 'echo 'export LANG=en_US.UTF-8' >> /etc/profile;source /etc/profile' \033[0m"|tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	else
		echo -e "\033[32m LANG is right \033[0m"
	fi
	#检测PATH中是否包含/usr/local/bin
	if [[ $status_PATH == "" ]];then
		echo -e "\033[31m PATH is error : '/usr/local/bin' need in PATH  \033[0m"|tee -a check-list-log.txt
		echo -e "\033[31m Please add '/usr/local/bin' in PATH \033[0m"|tee -a check-list-log.txt
		echo -e "\033[31m It is recommended to add by command: 'echo 'export PATH=/usr/local/bin:$""PATH' >> /etc/profile;source /etc/profile' \033[0m"|tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	else
		echo -e "\033[32m PATH is right \033[0m"
	fi
	#检测openssl版本是否为1.0.2k-fips
	if [[ $status_openssl == "" ]];then
		echo -e "\033[31m openssl version is error : $openssl \033[0m"|tee -a check-list-log.txt
		echo -e "\033[31m please replace openssl version to 1.0.2k-fips \033[0m"|tee -a check-list-log.txt
		echo -e "\033[31m there are OpenSSL 1.0.1e-fips rpm installation package in </data/install/>titan-base/base/qingteng/php/ \033[0m"|tee -a check-list-log.txt
		echo -e "\033[31m (Assume that the bash installation package is decompressed under /data/install) \033[0m"|tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	else
		echo -e "\033[32m openssl version check is OK  \033[0m"
	fi
	#检测yum源是否被修改过
	if [[ $status_yum_conf != "" ]];then
		echo -e "\033[31m /etc/yum.conf has been customized  \033[0m"|tee -a check-list-log.txt
		echo -e "\033[31m please remove all raw like reposdir=* in /etc/yum.conf , and execute command 'yum clean all'\033[0m"|tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	else
		echo -e "\033[32m yum check is OK \033[0m"
	fi
}

#升级前检查系统变量_5-7新增
function check_PATH_before_upgrade(){
	echo "##------------------------- CHECK PATH BEFORE UPGRADE-------------------------------- ----##"
	LANG=`echo $LANG`
	status_LANG=`echo $LANG |grep "en_US.UTF-8"`
	status_PATH=`echo $PATH |grep "/usr/local/bin"`
	status_qingteng_repo1=`cat /etc/yum.repos.d/qingteng.repo 2>>/dev/null |grep "enabled=1" `
	status_qingteng_repo2=`cat /etc/yum.repos.d/qingteng.repo 2>>/dev/null |grep "gpgcheck=0" `	
	#检测LANG是否为en_US.UTF-8
	if [[ $status_LANG == "" ]];then
		echo -e "\033[31m LANG is error : $LANG \033[0m"|tee -a check-list-log.txt
		echo -e "\033[31m Please set LANG to 'en_US.UTF-8' \033[0m"|tee -a check-list-log.txt
		echo -e "\033[31m It is recommended to add by command: 'echo 'export LANG=en_US.UTF-8' >> /etc/profile;source /etc/profile' \033[0m"|tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	else
		echo -e "\033[32m LANG is right \033[0m"
	fi
	#检测PATH中是否包含/usr/local/bin
	if [[ $status_PATH == "" ]];then
		echo -e "\033[31m PATH is error : '/usr/local/bin' need in PATH  \033[0m"|tee -a check-list-log.txt
		echo -e "\033[31m Please add '/usr/local/bin' in PATH \033[0m"|tee -a check-list-log.txt
		echo -e "\033[31m It is recommended to add by command: 'echo 'export PATH=/usr/local/bin:$""PATH' >> /etc/profile;source /etc/profile' \033[0m"|tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	else
		echo -e "\033[32m PATH is right \033[0m"
	fi
	#检测qingteng.repo中的配置是否正确(或者不存在)
	if [ ! -f "/etc/yum.repos.d/qingteng.repo" ];then
		echo -e "\033[32m qingteng.repo is right \033[0m"
	else
		if [[ $status_qingteng_repo1 == "" ]];then
			echo -e "\033[31m qingteng.repo is error ; enabled in /etc/yum.repos.d/qingteng.repo should be '1' ;gpgcheck in /etc/yum.repos.d/qingteng.repo should be '0' \033[0m"|tee -a check-list-log.txt
			echo "" |tee -a check-list-log.txt
		elif [[ $status_qingteng_repo2 == "" ]];then
			echo -e "\033[31m qingteng.repo is error ; gpgcheck in /etc/yum.repos.d/qingteng.repo should be '0' \033[0m"|tee -a check-list-log.txt
			echo "" |tee -a check-list-log.txt
		else
			echo -e "\033[32m qingteng.repo is right \033[0m"
		fi
	fi
}

#检查JDK状态
function check_jdk(){
	echo "##------------------------- CHECK JDK -------------------------------- ----##"
	status_JDk=`echo $JAVA_HOME`
	if [[ $status_JDk == "" ]];then
		echo -e "\033[32m JDK is right \033[0m"
	else
		echo -e "\033[31m Please check jdk status. Please use 'rpm -aq |grep JDK'  to show JDK and use 'rpm -i' to delete them. \033[0m" |tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	fi
    echo "Check end."
}

#检查umask
function check_umask(){
	echo "###-------------------------- CHECK UMASK ---------------------------------------##"
	Umask=`umask`
	user=`whoami`
	if [[ $Umask == "0022" ]];then
		echo -e "\033[32mUMASK is right : $Umask \033[0m"
	else
		echo -e "\033[31mUMASK is error : $Umask \033[0m" |tee -a check-list-log.txt
		echo -e "\033[31mplease use command : 'echo 'umask 0022' >> /etc/profile ;echo 'umask 0022' >> /etc/bashrc ;echo 'umask 0022' >> /root/.bashrc ;source /root/.bashrc ;source /etc/bashrc ;source /etc/profile' to change it." |tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	fi
    echo "Check end."
}

#用于检查操作系统版本 
#该步骤需要人工确认
function check_OS(){
    echo "## -------------------------- CHECK OS -------------------------------- ##"
	osv=`cat /etc/redhat-release`
    #kerv=`cat /proc/version  | awk -F ' ' '{print $3}'`
	echo -e "\033[32m 当前操作系统版本 OS-Version:  \033[0m" $osv |tee -a check-list-log.txt
    #echo -e "\033[32m Kernel-Version:  \033[0m" $kerv
	echo  "该步骤需要人工确认，This step requires manual confirmation." |tee -a check-list-log.txt
    echo  "请检查当前使用的安装包是否适用于当前版本操作系统，Please check whether the current installation package can be used in the current operating system." |tee -a check-list-log.txt
	read -p  Enter
	echo "Check end."
	echo "" |tee -a check-list-log.txt
}

#用于检查ip信息，涉及授权绑定 #弃用
# function check_network_info(){
    # echo "## ------------------------- CHECK NETWORK------------------------------ ##"
    # netdevs=`ip a |awk -F ': ' '{print $2}' | egrep '^(eth|bond|en|em)'`
    # for netdev in $netdevs;do
        # HWADDR=`ip a sh $netdev|grep "link/ether"|awk '{print $2}'`
        # IPADDR=`ip a sh $netdev|grep -w "inet"|awk '{print $2}'`
        # echo -e "\033[32m IPNAME: \033[0m" $netdev
        # echo -e "\033[32m HWADDR: \033[0m" $HWADDR
        # echo -e "\033[32m IPADDR: \033[0m" $IPADDR
    # done
	# echo ""
	# echo "Check end."
# }

#用来检查服务器是否可以通外网#弃用
# function check_external_network(){
    # echo "## ------------------------ CHECK External NetWork----------------------- ##"
	# ping -c 2 114.114.114.114 &>/dev/null
	# if [[ $? -eq 0 ]];then
		# echo -e "\033[32mAccess Internet\e[0m"
		# echo -e "\033[32mYou can config online update rules!\e[0m"
	# else
		# echo -e "\033[31mFailed to access Internet\e[0m"
	# fi
	# echo "Check end."
	# echo ""
# }

#用来检查硬件信息，主要是磁盘空间_3402
function check_hdinfo_3402(){
	echo "## -------------------------- CHECK HDWAREINFO----------------------------- ##"
    CPU=`sudo cat /proc/cpuinfo |grep "processor"|sort -u|wc -l`
    Mem=`sudo free -g | grep Mem | awk   '{print $2}'`
	Mem_num=`sudo free | grep Mem | awk   '{print $2}'`
	SpaceNum=`sudo df  /data | awk 'NR>1' |awk '{print $2}'`
	Space_DirData=`sudo df -hT /data | awk 'NR>1' |awk '{print $3}'`
    if [[ $CPU -lt 8 ]];then
        echo -e "\033[31m CPU_NUM: $CPU, less than 8C, Please check Resource requirements !\033[0m"|tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
    else
        echo -e "\033[32m CPU_NUM: $CPU C, OK!\033[0m" 
    fi


	if [ $Mem_num -lt 25000000 ];then
		echo -e "\033[31m Mem: $Mem, less than 32G, Please check Resource requirements !\033[0m"|tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	else
		echo -e "\033[32m Mem: \033[0m" $Mem
	fi
    if [ -d "/data/" ];then
        #Space_DirData=`sudo du -sh /data| awk '{print $1}'`
		#SpaceNum=`sudo du -sk /data | awk '{print $1}'`
		if [ $SpaceNum -ge 450000000 ];then
        	echo -e "\033[32m Space_DirData: \033[0m" $Space_DirData
		else
			echo -e "\033[31m /data Space: $Space_DirData, less than 500G, Please check Resource requirements ! \033[0m"|tee -a check-list-log.txt
			echo "" |tee -a check-list-log.txt
    	fi
	else
        echo -e "\033[31m Don't find  /data, Please check Disk mount \033[0m"|tee -a check-list-log.txt	
		echo "" |tee -a check-list-log.txt
    fi
    echo "Check end."
	echo ""
	
}


#用来检查硬件信息，主要是磁盘空间_thp
function check_hdinfo_THP(){
	echo "## -------------------------- CHECK HDWAREINFO----------------------------- ##"
    CPU=`sudo cat /proc/cpuinfo |grep "processor"|sort -u|wc -l`
    Mem=`sudo free -g | grep Mem | awk   '{print $2}'`
	Mem_num=`sudo free | grep Mem | awk   '{print $2}'`
	SpaceNum=`sudo df  /data | awk 'NR>1' |awk '{print $2}'`
	usrNum=`sudo df  /usr | awk 'NR>1' |awk '{print $2}'`
	varNum=`sudo df  /var | awk 'NR>1' |awk '{print $2}'`
	Space_DirData=`sudo df -hT /data | awk 'NR>1' |awk '{print $3}'`
    if [[ $CPU -lt 8 ]];then
        echo -e "\033[31m CPU_NUM: $CPU, less than 8C, Please check Resource requirements !\033[0m"|tee -a check-list-log.txt	
		echo "" |tee -a check-list-log.txt
    else
        echo -e "\033[32m CPU_NUM: $CPU C, OK!\033[0m" 
    fi


	if [ $Mem_num -lt 25000000 ];then
		echo -e "\033[31m Mem: $Mem G, less than 32G, Please check Resource requirements !\033[0m"|tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	else
		echo -e "\033[32m Mem: \033[0m" $Mem
	fi

	if [ $usrNum -lt 8000000 ];then
		echo -e "\033[31m /usr Space: $usrNum , less than 8G, Please add Space! \033[0m"|tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	fi
	
	if [ $varNum -lt 5000000 ];then
		echo -e "\033[31m /var Space: $varNum , less than 5G, Please add Space! \033[0m"|tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	fi
	
    if [ -d "/data/" ];then
        #Space_DirData=`sudo du -sh /data| awk '{print $1}'`
		#SpaceNum=`sudo du -sk /data | awk '{print $1}'`
		if [ $SpaceNum -ge 450000000 ];then
        	echo -e "\033[32m Space_DirData: \033[0m" $Space_DirData
		else
			echo -e "\033[31m /data Space: $Space_DirData, less than 500G, Please check Resource requirements ! \033[0m"|tee -a check-list-log.txt
			echo "" |tee -a check-list-log.txt
    	fi
	else
        echo -e "\033[31m Don't find  /data, Please check Disk mount \033[0m"|tee -a check-list-log.txt	
		echo "" |tee -a check-list-log.txt
    fi
    echo "Check end."
	echo ""
	
}

#用来检查Selinux服务状态
function check_StatusSeLinux(){
    echo "## -------------------------- CHECK SELINUX------------------------------------- ##"
    Status_SeLinux=`getenforce`
    if [ $Status_SeLinux == "Disabled" ];then
        echo -e "\033[32mThe SeLinux is Disabled, OK!  \033[0m"
	elif [ $Status_SeLinux == "Permissive" ];then
		echo -e "\033[33mThe SeLinux is Permissive, OK! \033[0m" 
    else
		echo ""
        echo -e "\033[31mThe SeLinux is Enabled \033[0m" |tee -a check-list-log.txt
		echo -e "\033[31mPlease use vi to open /etc/selinux/config and set SELINUX=disabled , and please use command 'sudo setenforce 0' to Disable it now. \033[0m" |tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
    fi
    echo "Check end."
}

#用来检查服务器时区
# function check_time(){
    # echo "## -------------------------- CHECK TIME----------------------------- ##"
        # date=`date +"%Y-%m-%d %H:%M:%S"`
		# echo -e "system time is $date"
		# echo ""
		# read -p "Is the time correct?[Y/N]" choose
        # if [ $choose = Y ]||[ $choose = y ]||[ $choose = YES ]||[ $choose = yes ] ;then
			# echo -e "\033[32mTime is right! \033[0m"
        # else
			# echo -e "\033[31mTime is wrong , Please use 'date -s 年-月-日 时:分:秒' Set the time manually . \033[0m" |tee -a check-list-log.txt
        # fi
        # echo "Check end."
		# echo "" |tee -a check-list-log.txt

# }

#用来检查是否存在端口冲突#弃用
#function check_conflicting_Ports(){
#	echo "## -------------------------- CHECK X-windows ------------------------------ ##"
#	xserver=`systemctl status gdm | grep Active | awk '{print $2}'`
#	if [ "$xserver" == "active" ];then
#		echo -e "\033[31mGnome server will occupy 6000 port, Disabled it please!\033[0m"
#	else 
#		echo -e "\033[32mNo Gnome!\033[0m"
#	fi
#			
#		
#
#   echo "## -------------------------- CHECK PORTs---------------------------------------------- ##"
#	echo -e "\033[32mNETSTAT: \033[0m" 
#	netstat -antlp | grep -E "LISTEN|PID"
#	read -p "Please choose the process which you want to kill(Input pid, Multiple processes are separated by space):" processes	
#
#	if [[ $processes != "" ]];then
#		echo -e "\033[33mReady to kill $processes\033[0m"
#		for process in $processes;do
#			echo "kill $process ..." && kill -9 $process
#			kp=`netstat -lntp | grep $process`
#			if [[ $kp == "" ]];then
#				echo "Kill $process SUCCESS"
#			else
#				echo "Kill $process Failed"
#			fi
#		done
#	else
#		echo "No need to kill process."
#	fi 
#	echo "" |tee -a check-list-log.txt
#}	

#用来检查是否存在端口冲突2 2021_3_19 通过正则匹配方式检查
function check_conflicting_Ports(){
	echo "##------------------------- CHECK Ports -------------------------------- ----##"
	status_Port=`sudo netstat -lntp | egrep ":80\s|:81\s|:6110\s|:2128\s|:3306\s|:5672\s|:6000\s|:6100\s|:6120\s|:6130\s|:6140\s|:6150\s|:6170\s|:6171\s|:6172\s|:6173\s|:6201\s|:6210\s|:6220\s|:6379\s|:6380\s|:6677\s|:7788\s|:7789\s|:8000\s|:8001\s|:8002\s|:8443\s|:9001\s|:9092\s|:27017\s"`
	if [[ $status_Port	== "" ]];then
		echo -e "\033[32m Port is OK \033[0m"
	else
		echo -e "\033[32m Conflict port:  \033[0m" |tee -a check-list-log.txt
		netstat -lntp | egrep ":80\s|:81\s|:6110\s|:2128\s|:3306\s|:5672\s|:6000\s|:6100\s|:6120\s|:6130\s|:6140\s|:6150\s|:6170\s|:6171\s|:6172\s|:6173\s|:6201\s|:6210\s|:6220\s|:6379\s|:6380\s|:6677\s|:7788\s|:7789\s|:8000\s|:8001\s|:8002\s|:8443\s|:9001\s|:9092\s|:27017\s"|tee -a check-list-log.txt
		echo -e "\033[31m Please  use 'kill -9' to kill the following PID \033[0m" |tee -a check-list-log.txt
		sudo netstat -lntp | egrep ":80\s|:81\s|:6110\s|:2128\s|:3306\s|:5672\s|:6000\s|:6100\s|:6120\s|:6130\s|:6140\s|:6150\s|:6170\s|:6171\s|:6172\s|:6173\s|:6201\s|:6210\s|:6220\s|:6379\s|:6380\s|:6677\s|:7788\s|:7789\s|:8000\s|:8001\s|:8002\s|:8443\s|:9001\s|:9092\s|:27017\s"| awk -F ' ' '{print $7}'| awk -F '/' '{print $1}'|tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	fi
    echo "Check end."
	echo "" |tee -a check-list-log.txt
}

#用来检查是否存在组件冲突_3402		
function check_conflicting_RPMs(){ 
	echo "##------------------------- CHECK RPMs -------------------------------- ----##"
	rpms=`rpm -qa |egrep -i 'nginx|mysql|mongodb|jdk|kafka|zookeeper|wisteria|php|redis|mariadb-libs'`
	echo ""
	if [ "$rpms" == "" ];then
		echo -e "\033[32m Clean \033[0m"
	else
		echo -e "\033[32mConflicting RPMS: \033[0m" |tee -a check-list-log.txt
		rpm -qa |egrep -i 'nginx|mysql|mongodb|jdk|kafka|zookeeper|wisteria|php|redis|mariadb-libs'|tee -a check-list-log.txt
		echo "请选择，客户是否同意我们在这台主机上删除以上软件？" 
		read -p "Please confirm with the customer : Can we remove the above software? :[Y/N]" choose
		if [ $choose = Y ]||[ $choose = y ]||[ $choose = YES ]||[ $choose = yes ] ;then
			echo -e "\033[33mPlease execute the following command:\033[0m" |tee -a check-list-log.txt
		else
			echo -e "\033[31m ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! The environment cannot support deployment! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! \033[0m"|tee -a check-list-log.txt
			echo "End CHECK"
			echo "" |tee -a check-list-log.txt
			exit 1
		fi
		for rpm in $rpms;do
			#echo $rpm
			echo -e "\033[33msudo rpm -e $rpm  --nodeps \033[0m"|tee -a check-list-log.txt
		done
		echo "" |tee -a check-list-log.txt
	fi
    echo "Check end."
}

#用来检查是否存在组件冲突_THP	
function check_conflicting_RPMs_THP(){ 
	echo "##------------------------- CHECK RPMs -------------------------------- ----##"
	rpms=`rpm -qa |egrep -i 'nginx|mysql|php|redis'`
	echo ""
	if [ "$rpms" == "" ];then
		echo -e "\033[32m Clean \033[0m"
	else
		echo -e "\033[32mConflicting RPMS: \033[0m" |tee -a check-list-log.txt
		rpm -qa |egrep -i 'nginx|mysql|mongodb|php|redis'|tee -a check-list-log.txt
		echo "请选择，客户是否同意我们在这台主机上删除以上软件？" 
		read -p "Please confirm with the customer : Can we remove the above software? [Y/N]" choose
		if [ $choose = Y ]||[ $choose = y ]||[ $choose = YES ]||[ $choose = yes ] ;then
			echo -e "\033[33mPlease execute the following command:\033[0m" |tee -a check-list-log.txt
		else
			echo -e "\033[31m ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! The environment cannot support deployment! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! \033[0m"|tee -a check-list-log.txt
			echo "End CHECK"
			echo "" |tee -a check-list-log.txt
			exit 1
		fi
		for rpm in $rpms;do
			#echo $rpm
			echo -e "\033[33msudo rpm -e $rpm\033[0m"|tee -a check-list-log.txt
		done
		echo "" |tee -a check-list-log.txt
	fi
    echo "Check end."
	# echo -e "\033[31m`env | grep -E "JAVA|java"` \033[0m"
}

#用来检查目前所处角色以及是否具有sudo权限
function check_user_permission(){
    echo "## -------------------------- CHECK USER Permission -------------------------------- ##" 
	user=`whoami`
	status_su=`cat /etc/pam.d/su |grep auth |grep required |grep -v "#"`
	sudo ls > /dev/null
	if [ $? -eq 0  ];then
		echo  "	请选择，系统是否提示您输入密码以进行sudo操作？"
		read -p "Please choose , Did the system ask you to enter the sudo password? [Y/N]" choose
		if [ $choose = N ]||[ $choose = n ]||[ $choose = NO ]||[ $choose = no ] ;then
			echo -e "\033[32m User is $user , You have no passwd sudoer permission! \033[0m"	
		else
			echo -e "\033[31m User is $user , You do not have  no passwd sudoer permission, \033[0m"|tee -a check-list-log.txt
			echo -e "\033[31m Please check file /etc/sudoers , Comment out 'Defaults requiretty' AND make sure there are one line like : '$user  ALL=(ALL) 	ALL=(ALL)       NOPASSWD: ALL'!\033[0m"|tee -a check-list-log.txt
			echo "End CHECK"
			echo "" |tee -a check-list-log.txt
			exit 1
		fi
	else
		echo -e "\033[31m User is $user , You do not have no passwd sudoer permission, \033[0m"|tee -a check-list-log.txt
		echo -e "\033[31m Please check file /etc/sudoers , Comment out 'Defaults requiretty' AND make sure there are one line like : '$user  ALL=(ALL)   NOPASSWD:ALL' at the end of the file !\033[0m"|tee -a check-list-log.txt
		echo "End CHECK"
		echo "" |tee -a check-list-log.txt
		exit 1
	fi
	#检查/etc/pam.d/su中su认证是否关闭
	if [[ $status_su == "" ]];then
		echo -e "\033[32m /etc/pam.d/su is OK! \033[0m"
	else
		echo -e "\033[31m  there are bad	configuration in /etc/pam.d/su ,please use '#' to comment all lines like 'auth	required * ' \033[0m" |tee -a check-list-log.txt 
		echo "" |tee -a check-list-log.txt
		exit 1
	fi
	
    echo "Check end."
}

#用来检查本地防火墙配置
function check_firewall(){
    echo "## -------------------------- CHECK FIREWALLD|IPTABLE----------------------------- ##"
	status_firewall=`service firewalld status | grep Active |awk '{print $2}'`
    status_iptables=`service iptables status | grep Active |awk '{print $2}'`

	if [ "$status_firewall" == "active" ];then
		echo -e "\033[31m Firewall is active, please use 'systemctl stop firewalld ;systemctl disable firewalld' to stop it\033[0m"|tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	else
        echo -e "\033[32mFirewall is closed.  \033[0m"
	fi


    if [ "$status_iptables" == "active" ];then
        echo -e "\033[33miptables is active , please use 'service iptables stop；chkconfig iptables off' to stop it\033[0m"|tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
    else
        echo -e "\033[32miptables is closed.  \033[0m"
    fi
    echo "Check end."

}

#用来检查SSH配置文件_废弃
# function check_openssh(){
	# echo "##----------------------------check openssh config -----------------------------##"
	# echo "#######################################################"
	# sshc=`sudo cat /etc/ssh/sshd_config | egrep  -v '^(#|$)' | egrep  -w 'Port|PermitRootLogin|PubkeyAuthentication|RSAAuthentication|UsePAM'`
	# if [[ $sshc == "" ]];then
		# echo -e "\033[32mSSH configfile is ok!\e[0m"
	# else
	    # #echo -e "\033[31mSSH configfile is not ok!\e[0m"
		# echo -e "$sshc\n"
	# fi		
	# echo "#######################################################"
	# echo "Check end."
	# echo ""
# }

#new_用来检查SSH配置文件_5-7新增6~9检查项
function check_openssh(){
	echo "##----------------------------check openssh config -----------------------------##"
	check_is_all_ok=0
	echo "#######################################################"
#	sshc=`sudo cat /etc/ssh/sshd_config | egrep  -v '^(#|$)' | egrep  -w 'Port|PermitRootLogin|PubkeyAuthentication|RSAAuthentication|UsePAM'`
#1、检查SSH Port
	ssh_port=`sudo cat /etc/ssh/sshd_config | egrep  -v '^(#|$)' | egrep  -w 'Port'|grep -v -w 22`
	if [[ $ssh_port == "" ]];then
		echo -e "\033[32mSSH Port configfile is ok!\e[0m"
	else
		ssh_port=`sudo cat /etc/ssh/sshd_config | egrep  -v '^(#|$)' | egrep  -w 'Port'|grep -v -w 22|awk '{print $2}'`
		read -p "SSH Port is not 22! Did you change the 'titan-base/titan-base.sh' , 'titan-app/utils.sh' , 'titan-app/ip-config.py' ?[Y/N]" choose
		if [ $choose = N ]||[ $choose = n ]||[ $choose = NO ]||[ $choose = no ] ;then
			echo -e "\033[31m please change the 'DEFAULT_PORT'=$ssh_port in 'titan-base/titan-base.sh' & 'titan-app/utils.sh' ！ please change the 'DEFAULT_SSH_PORT'=$ssh_port in 'titan-app/ip-config.py'! \033[0m"|tee -a check-list-log.txt	
			check_is_all_ok=1
		else
			echo -e "\033[32mSSH Port configfile is ok! \033[0m"
		fi
	fi
#2、检查SSH是否允许root登录
	ssh_RootLogin=`sudo cat /etc/ssh/sshd_config | egrep  -v '^(#|$)' | egrep  -w 'PermitRootLogin'|awk '{print $2}'`
	if [[ $ssh_RootLogin == "yes" ]];then
		echo -e "\033[32mSSH RootLogin configfile is ok!\e[0m"
	else
		echo -e "\033[31m please set 'PermitRootLogin yes' in /etc/ssh/sshd_config \033[0m"|tee -a check-list-log.txt	
		check_is_all_ok=1
	fi
#3、检查SSH是否允许密码登录
	ssh_PassLogin=`sudo cat /etc/ssh/sshd_config | egrep  -v '^(#|$)' | egrep  -w 'PasswordAuthentication'|awk '{print $2}'`
	if [[ $ssh_PassLogin == "yes" ]];then
		echo -e "\033[32mSSH Password Login configfile is ok!\e[0m"
	else
		echo -e "\033[31m please set 'PasswordAuthentication yes' in /etc/ssh/sshd_config \033[0m"|tee -a check-list-log.txt	
		check_is_all_ok=1
	fi
#4、检查SSH是否允许key登录
	#如果使用1代sshd:
	ssh_protocol=`sudo cat /etc/ssh/sshd_config | egrep  -v '^(#|$)' | egrep  -w 'Protocol'|awk '{print $2}'`
	if [[ $ssh_protocol -eq 1 ]];then
		ssh_RSAAuthentication=`sudo cat /etc/ssh/sshd_config | egrep  -v '^(#|$)' | egrep  -w 'RSAAuthentication'|awk '{print $2}'`
		if [[ $ssh_RSAAuthentication == "yes" ]];then
			echo -e "\033[32mSSH  key authentication configfile is ok!\e[0m"
		else
			echo -e "\033[31m please set 'RSAAuthentication yes' in /etc/ssh/sshd_config \033[0m"|tee -a check-list-log.txt	
			check_is_all_ok=1
		fi
	#如果使用2代sshd:
	else  
		ssh_PubkeyAuthentication=`sudo cat /etc/ssh/sshd_config | egrep  -v '^(#|$)' | egrep  -w 'PubkeyAuthentication'|awk '{print $2}'`
		if [[ $ssh_PubkeyAuthentication == "yes" ]];then
			echo -e "\033[32mSSH key authentication configfile is ok!\e[0m"
		else
			echo -e "\033[31m please set 'PubkeyAuthentication yes' in /etc/ssh/sshd_config \033[0m"|tee -a check-list-log.txt	
			check_is_all_ok=1
		fi
	fi
#5、检查SSH是否开启PAM认证模块
	ssh_UsePAM=`sudo cat /etc/ssh/sshd_config | egrep  -v '^(#|$)' | egrep  -w 'UsePAM'|awk '{print $2}'`
	if [[ $ssh_UsePAM == "yes" ]];then
		echo -e "\033[32mSSH UsePAM configfile is ok!\e[0m"
	else
		echo -e "\033[31m please set 'UsePAM yes' in /etc/ssh/sshd_config \033[0m"|tee -a check-list-log.txt	
		check_is_all_ok=1
	fi
#6、检查SSH是否进行家目录权限检查
	ssh_StrictModes=`cat /etc/ssh/sshd_config |grep StrictModes |grep yes |grep -v '#'`
	if [[ $ssh_StrictModes == "" ]];then
		echo -e "\033[32mSSH StrictModes configfile is ok!\e[0m"
	else
		echo -e "\033[31m please # 'StrictModes yes' in /etc/ssh/sshd_config \033[0m"|tee -a check-list-log.txt	
		check_is_all_ok=1
	fi
#7、检查SSH是否允许取消了显示公钥摘要
	ssh_StrictHostKeyChecking=`cat /etc/ssh/ssh_config |grep StrictHostKeyChecking |grep no |grep -v '#'`
	if [[ $ssh_StrictHostKeyChecking != "" ]];then
		echo -e "\033[32mSSH StrictHostKeyChecking configfile is ok!\e[0m"
	else
		echo -e "\033[31m please execute command 'echo 'StrictHostKeyChecking no' >> /etc/ssh/ssh_config' to add 'StrictHostKeyChecking no' in /etc/ssh/ssh_config \033[0m"|tee -a check-list-log.txt
	fi
#8、检查SSH是否取消公钥交互确认
	ssh_UserKnownHostsFile=`cat /etc/ssh/ssh_config |grep UserKnownHostsFile |grep '/dev/null' |grep -v '#'`
	if [[ $ssh_StrictHostKeyChecking != "" ]];then
		echo -e "\033[32mSSH UserKnownHostsFile configfile is ok!\e[0m"
	else
		echo -e "\033[31m please execute command 'echo 'UserKnownHostsFile /dev/null' >> /etc/ssh/ssh_config' to add 'UserKnownHostsFile /dev/null' in /etc/ssh/ssh_config \033[0m"|tee -a check-list-log.txt
	fi
#9、如果sshd配置文件存在问题,提醒修改后重启sshd
	if [ $check_is_all_ok -eq 1 ];then
		echo -e "\033[34m Tip: sshd configuration modification will take effect only after restarting the sshd service, please use 'service sshd restart' to restart it.\033[0m" |tee -a check-list-log.txt	
	fi
	echo "#######################################################"
	echo "Check end."
	echo "" |tee -a check-list-log.txt
}

#用来检查sudoers配置文件
function check_sudoer_config(){
	echo "##----------------------------check /etc/sudoers config -----------------------------##"

	echo "#######################################################"
	sudocnf=`cat /etc/sudoers | egrep  -v '^(#|$)' | grep  -w 'Defaults' |grep -w 'requiretty'`
	if [[ $sudocnf == "" ]];then
		echo -e "\033[32mSudoers configfile is ok!\e[0m"
	else
	    echo -e "\033[31mSudoers configfile is not ok, please # 'Defaults requiretty' !  \e[0m" |tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	fi		
	echo "#######################################################"
	echo "Check end."
}

#用来检查passwd以及group文件的隐藏权限
function check_directory_permissions(){
	echo "##------------------------- CHECK Directory Permissions ---------------------------##"
	echo "Start to check if /etc/passwd /etc/group has i Permisson."
	checkdp=`lsattr /etc/passwd /etc/group /etc/shadow| grep i`
	if [[ $checkdp == "" ]];then
		echo -e "\033[32m /etc/passwd /etc/group do not has i permission, Permission OK!\e[0m"
	else
		echo -e "\033[31m The /etc/passwd or /etc/group has i permission , please use 'chattr -i /etc/passwd /etc/group' to delete it \033[0m" |tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	fi
	echo "Check end."
}

#用来检查主机名是否符合要求
function check_hostname(){
	echo "--------------------------- CHECK Hostname -------------------------------"
	hostname=`hostname`
	number_check=`hostname|awk '{if($0 ~ /^[0-9]+$/) print $0;}'`
	point_check=`hostname|grep "^[.].*"`
	if [[ $number_check != "" ]];then
		echo -e "\033[31m hostname is '$hostname' , hostname cannot be all numbers! please use 'hostname <new hostname>' to change it and execute 'source /etc/profile' to refresh.\033[0m" |tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	elif [[ $point_check != "" ]];then
		echo -e "\033[31m hostname is '$hostname' , hostname cannot start with '.'! please use 'hostname <new hostname>' to change it and execute 'source /etc/profile' to refresh.\033[0m" |tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	else
		echo -e "\033[32m hostname check OK!\e[0m"
	fi
	echo "Check end."
}

#用来检查/etc/passwd中第一个root权限账户名字是不是叫root
function check_root(){
	echo "--------------------------- CHECK Hostname -------------------------------"
	root_name=`sudo cat /etc/passwd |grep ":x:0:" |awk -F  ':'  '{print $1}'|sed -n '1p'`
	if [[ $root_name != "root" ]];then
		echo -e "\033[31m If you ssh the root of this host, you will be logged in as the $root_name user \033[0m" |tee -a check-list-log.txt
		echo -e "\033[31m This may cause some errors , please change /etc/passwd and put the user named root on the first line of the file . \033[0m" |tee -a check-list-log.txt
		echo "" |tee -a check-list-log.txt
	else
		echo -e "\033[32m root name check OK!\e[0m"
	fi
	echo "Check end."
}

#用来检查安装的用户及端口#弃用
# function check_install_user_port(){
	# echo "## -------------------------- CHECK Defalut User&Port------------------------------- ##"
	# utils=`find / -name utils.sh`
	# find / -name "utils.sh"
	# echo ""
	# if [ "$utils" == "" ];then
		# echo -e "\033[32m This is not PHP server. \033[0m"
	# else
		# for utils in $utils;do
			# cat $utils | egrep -i "^DEFAULT_PORT|^DEFAULT_USER"
		# done
	# fi
	# echo "" |tee -a check-list-log.txt
	# echo "Check end."
# }

check_before_3402_install(){
	cat check-list-log.txt >> check-list-log.txt_bak
	echo "" >  check-list-log.txt
	echo "##------------------------- CHECK START -------------------------------- ----##" >>  check-list-log.txt
	check_user_permission
	check_OS
	check_hdinfo_3402
	check_hostname
	check_umask
	check_directory_permissions
	check_jdk
	check_openssh
	check_sudoer_config
	check_StatusSeLinux
	check_firewall
	check_conflicting_Ports
	check_conflicting_RPMs
	check_root
	check_PATH
	check_redundant_configuration_files
	read -p "Check end, please see check-list-log.txt. If the file is empty, all inspection items have passed. The system is ready to be installed. "
	echo "##------------------------- CHECK End -------------------------------- ----##" >>  check-list-log.txt

}

check_before_THP_install(){
	cat check-list-log.txt >> check-list-log.txt_bak
	echo "" >  check-list-log.txt
	echo "##------------------------- CHECK START -------------------------------- ----##" >>  check-list-log.txt
	check_user_permission
	check_OS
	check_hdinfo_THP
	check_hostname
	check_umask
	check_directory_permissions
	check_jdk
	check_openssh
	check_sudoer_config
	check_StatusSeLinux
	check_firewall
	check_conflicting_Ports
	check_conflicting_RPMs_THP
	check_root
	read -p "Check end, please see check-list-log.txt. If the file is empty, all inspection items have passed. The system is ready to be installed. "
	echo "##------------------------- CHECK End -------------------------------- ----##" >>  check-list-log.txt

}



check_before_upgrade(){
	cat check-list-log.txt >> check-list-log.txt_bak
	echo "" >  check-list-log.txt
	echo "##------------------------- CHECK START -------------------------------- ----##" >>  check-list-log.txt
	check_user_permission
	check_umask
	check_directory_permissions
	check_openssh
	check_sudoer_config
	check_StatusSeLinux
	check_firewall	
	check_root
	check_PATH_before_upgrade
	check_jdk_before_upgrade 	
	read -p "Check end, please see check-list-log.txt. If the file is empty, all inspection items have passed. The system is ready to be upgrade. "
	echo "##------------------------- CHECK END -------------------------------- ----##" >>  check-list-log.txt

}

check_after_3402_upgrade_chinese(){
	echo "请检查以下操作是否已经完成:"
	echo ""
	echo "是否base、app均已升级？"
	echo ""
	echo "巡检脚本是否显示各功能正常？"
	echo ""
	echo "6110端口是否可以从浏览器访问？"
	echo ""
	echo "是否全量发布新agent？"
	echo ""
	echo "是否记录了部署服务器的ip？（巡检报告用）"
	echo ""
	echo "如果新增加了小机功能，请记得在81配置发布小机agent。"
	echo ""
	echo "如果升级前关闭了客户的防火墙，请记得在配置允许其他主机访问PHP的6110端口后，重新启动各台主机的防火墙。"
	echo ""
	read -p "本次升级的亮点：内存马检测功能需要手动开启，建议部署完成后全量开启（开启前务必得到客户同意）。" Enter
	echo ""
	echo "如果以上操作均已完成，恭喜您，3402升级完成！"
}

check_after_3402_upgrade_english(){
	echo "Please check if the following operations have been completed:"
	echo ""
	echo "Is the base and app upgraded?"
	echo ""
	echo "Did you execute the script to upgrade the JAVA database?"
	echo ""
	echo "Does the inspection script show that the all functions are OK?"
	echo ""
	echo "Can port 6110 be accessed from the browser?"
	echo ""
	echo "Did you release the new agent in full?"
	echo ""
	echo "Did you record the ip of server? (for inspection report)"
	echo ""
	echo "If the XiaoJi function is newly added, please remember to release the XiaoJi agent in the 81 configuration."
	echo ""
	echo "If the customer's firewall is turned off before the upgrade, please remember to restart the firewall of each host after configuring the external access to PHP port 6110."
	echo ""
	read -p "The highlight of this upgrade: The memory detection function needs to be turned on manually. It is recommended that you should turn it on after the deployment is complete (you must obtain the customer's consent before turning it on)." Enter
	echo ""
	echo "If the above operations have been completed, congratulations, 3402 upgrade is complete!" 
}

check_after_3402_install_chinese(){
	echo "请检查以下操作是否已经完成"
	echo ""
	echo "巡检脚本是否显示各功能正常？"
	echo ""
	echo "是否记录了部署服务器的ip？（用来输出巡检报告）"
	echo ""
	echo "如果功能包括小机，请记得在81配置发布小机agent。"
	echo ""
	echo "是否已将80、81、6110密码提供给客户？。"
	echo ""
	read -p "请确认客户使用的浏览器版本在万象支持范围内（Chrome >64 , FireFox >58)" Enter
	echo ""
	echo "如果以上操作均已完成，恭喜您，3402部署完成！"
}

check_after_3402_install_english(){
	echo "Please check whether the following operations have been completed"
	echo ""
	echo "Does the inspection script show that all functions are normal?"
	echo ""
	echo "Did you record the ip of the deployment server? (for inspection report)"
	echo ""
	echo "If the XiaoJi function is newly added, please remember to release the XiaoJi agent in the 81 configuration."
	echo ""
	echo "Have you provided the 80, 81, and 6110 passwords to the customer?."
	echo ""
	read -p "Please confirm that the browser version used by the customer is within the range of Vientiane's support (Chrome >64, FireFox >58)" Enter
	echo ""
	echo "If the above operations have been completed, congratulations, 3402 install is complete!" 
}

check_after_THP_install_chinese(){
	echo "请检查以下操作是否已经完成"
	echo ""
	echo "万象巡检脚本是否显示各功能正常？"
	echo ""
	echo "是否记录了部署服务器的ip？（用来输出巡检报告）"
	echo ""
	echo "万象是否已开启事件采集？"
	echo ""
	read -p "万象agent是否已经全量安装bash插件？（安装bash插件前务必得到客户同意）" Enter
	echo ""
	echo "如果以上操作均已完成，恭喜您，THP安装完成！"
}

check_after_THP_install_english(){
	echo "Please check whether the following operations have been completed"
	echo ""
	echo "Does the wanxiang inspection script show that all functions are normal?"
	echo ""
	echo "Did you record the ip of the deployment server? (for inspection report)"
	echo ""
	echo "Has wanxiang enabled event collection?"
	echo ""
	read -p "Has the wanxiang agent fully installed the bash plug-in? (Before installing the bash plug-in, you must get the customer's consent)" Enter
	echo ""
	echo "If the above operations have been completed, congratulations, THP install is complete!" 
}

test1(){
	echo "No test task"
}

echo -e "\033[31m Attention：目前脚本只支持Centos/Redhat系统的检查 \033[0m"
echo -e "\033[31m Attention：脚本仅提供环境检查功能并提供修复建议，不会修改任何配置\033[0m"
#echo -e "\033[31m Attention：此脚本适用于部署前的纯净环境检查！！！ \033[0m"
	
	
case $1 in
	help)
		help
		exit 0
		;;
	test1)
		test1
		exit 0
		;;
	check_before_3402_install)
		check_before_3402_install
		exit 0
		;;
	check_before_THP_install)
		check_before_THP_install
		exit 0
		;;
	check_before_upgrade)
		check_before_upgrade
		exit 0
		;;
	check_after_3402_upgrade_chinese)
		check_after_3402_upgrade_chinese
		exit 0
		;;
	check_after_3402_upgrade_english)
		check_after_3402_upgrade_english
		exit 0
		;;
	check_after_3402_install_chinese)
		check_after_3402_install_chinese
		exit 0
		;;
	check_after_3402_install_english)
		check_after_3402_install_english
		exit 0
		;;
	check_after_THP_install_chinese)
		check_after_THP_install_chinese
		exit 0
		;;
	check_after_THP_install_english)
		check_after_THP_install_english
		exit 0
		;;
	*)
		help
		exit 0
		;;
esac

exit 0
