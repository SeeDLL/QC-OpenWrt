#/bin/bash

function addFeeds()
{
    echo "添加 Feeds 包到 OpenWrt……"
    local file=addfeeds.txt
    local bak=$IFS
    if [ ! -f $file ];then
       echo "addfeeds.txt 文件不存在，无法添加 feeds 包"
       return
    fi 
    IFS=$'\n'
    showCustomizeFeeds $file
    read -r -p "是否添加以上 Feeds 包到 OpenWrt？[Y/n] " input
    case $input in
        [yY][eE][sS]|[yY])
    		echo "即将添加以上 Feeds 到 OpenWrt" ;;
        [nN][oO]|[nN])
    		echo "没有添加以上 Feeds 到 OpenWrt"
    		return ;;
        *)
    		echo "输入错误，退出 添加  Feeds 包到 OpenWrt"
    		return ;;
    esac
    
    for i in `cat $file`
    do
       echo $i >> ./lede/feeds.conf.default
    done
    IFS=$bak 
	echo "添加 Feeds 完成"
}

function updateFeeds()
{
    echo "准备更新 Feeds 包"
	./lede/scripts/feeds update -a
	echo "Feeds 包更新完成"
}

function clearFeeds()
{
	echo "准备清除 Feeds 包"
	rm -rf ./lede/feeds
	echo "Feeds 包清除完成"
}

function restartUpdate()
{
	echo "准备开始清除并重新更新 Feeds 包"
	clearFeeds
	updateFeeds
	echo "已清除并更新完成"
}

function installFeeds()
{
	echo "准备安装 Feeds 包"
	./lede/scripts/feeds install -a
	echo "安装 Feeds 包完成"
}

function rmRedundantFeedPackage()
{
    echo "准备删除指定 Feeds 包"
	
	local file=rmfeeds.txt
    local bak=$IFS
    if [ ! -f $file ];then
       echo "rmfeeds.txt 文件不存在，无法删除指定 feeds 包"
       return
    fi 
    IFS=$'\n'
    showCustomizeFeeds $file
    read -r -p "是否从 OpenWrt 中删除以上指定的 feeds 包？[Y/n] " input
    case $input in
        [yY][eE][sS]|[yY])
    		echo "即将从 OpenWrt 中删除以上指定的 feeds 包" ;;
        [nN][oO]|[nN])
    		echo "没有删除以上指定的 feeds 包"
    		return ;;
        *)
    		echo "输入错误，退出  删除指定 Feeds 包"
    		return ;;
    esac
    
    for i in `cat $file`
    do
       rm -rf "./lede"/$i
    done
    IFS=$bak 
	
	echo "删除指定 Feeds 包完成"
}

function initEnvironment()
{
	echo "准备安装编译环境"
	sudo apt-get update \
	&& sudo apt -y install build-essential asciidoc binutils bzip2 gawk gettext git \
    libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 \
    subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo \
    libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint \
    device-tree-compiler g++-multilib antlr3 gperf wget curl swig rsync
	echo "环境安装完成"
}

function cloneSourceCode()
{
    echo "准备 Git clone 代码"
	git clone https://github.com/coolsnowwolf/lede 
	echo "GIt clone 完成"
}

function showCustomizeFeeds()
{
    echo "------------------------ feeds 开始 ------------------------"
    for i in `cat $1`
    do
       echo $i
    done
    echo "------------------------ feeds 结束 ------------------------"
}

function makedefault()
{
    cd lede
	make defconfig
	cd ..
}

function makeMenuConfig()
{
    cd lede
	make menuconfig
	cd ..
}

function makeDownloadPackage()
{
    echo "准备开始下载 dl 库，请尽量确保全局科学上网"
    cd lede
	make -j8 download
	cd ..
	echo "dl 库下载完成"
}

function compileJSFirmware()
{
    echo "准备编译 OpenWrt"
    cd lede
	make -j$(($(nproc) + 1)) V=s
	cd ..
	echo "编译完成"
}

function compileJ1Firmware()
{
    echo "准备编译 OpenWrt"
    cd lede
	make -j1 V=s
	cd ..
	echo "编译完成"
}


while  true
do
	echo "=============================  OpenWrt 编译菜单  ============================="
	echo "【1】安装 OpenWrt 编译环境               【2】Git克隆 Lede 代码到当前目录"
	echo "【3】批量添加 Feeds 包                   【4】更新 Feeds 包"
	echo "【5】删除 Feeds 包                       【6】删除旧 Feeds 包并获取更新 Feeds 包"
	echo "【7】安装 Feeds 包到 OpenWrt             【8】删除指定的 Feeds 包"
	echo "【9】make OpenWrt 默认设置               【a】设置编译项目"
	echo "【b】下载dl库（国内请全局科学上网）      【c】多核编译 OpenWrt"
	echo -e "【d】单核编译 OpenWrt\n"
	echo "【q】推出菜单"
	echo "===================================  End  ==================================="
	read -p "我需要：" selectNum

	case $selectNum in
		1 ) initEnvironment
	   		;;
	   	2 ) cloneSourceCode
	   		;;
	   	3 ) addFeeds
	   		;;
	   	4 ) updateFeeds
	   		;;
	   	5 ) clearFeeds
	   		;;
	   	6 ) restartUpdate
	   		;;
	   	7 ) installFeeds
	   		;;
	   	8 ) rmRedundantFeedPackage
	   		;;
	    9 ) makedefault
	   		;;
	   	a ) makeMenuConfig
	   		;;
	   	b ) makeDownloadPackage
	   		;;
	   	c ) compileJSFirmware
	   		;;
	   	d ) compileJ1Firmware
			;;
		e ) readAddFeedsFile
		    ;;
		q ) exit 0
			;;
		* ) echo "输入错误，请重写输入"
			break
			;;
	   esac 
done
