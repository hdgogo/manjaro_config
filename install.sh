#!/bin/bash
WORKDIR=$(readlink -f $(dirname $0))


# 获取当前时间
function get_datetime(){
	time=$(date "+%Y%m%d%H%M%S")
	echo $time
}

# 判断文件是否存在
function is_exist_file(){
	filename=$1
	if [ -f $filename ]; then
		echo 1
	else
		echo 0
	fi
}


# 判断文件是否为软链接，如果为软链接，返回软链接指向的原始文件地址，如果不为软链接，返回空串
function get_link(){
	filename=$1
	if [ -L $filename ]; then
		echo $(readlink -f $filename)
	else
		echo ''
	fi
}

# 判断目录是否存在
function is_exist_dir(){
	dirname=$1
	if [ -d $dirname ]; then
		echo 1
	else
		echo 0
	fi
}


# 备份原有的.ssh/config文件
function backup_sshconfig_file(){
	old_ssh_config="$HOME/.ssh/config"
	is_exist=$(is_exist_file $old_ssh_config)
	if [ $is_exist == 1 ];then
		time=$(get_datetime)
		backup_ssh_config=$old_ssh_config"_bak_"$time
		read -p "Find "$old_ssh_config" already exists,backup "$old_ssh_config" to "$backup_sshconfig_file"? [Y/N] " ch
		if [[ $ch == "Y" ]] || [[ $ch == "y" ]]; then
			cp $old_ssh_config $backup_ssh_config
		fi
        rm -rf $old_ssh_config
	fi
}

# 备份原有的.m2/setting.xml文件
function backup_m2_setting_file(){
	old_setting="$HOME/.m2/settings.xml"
	is_exist=$(is_exist_file $old_setting)
	if [ $is_exist == 1 ];then
		time=$(get_datetime)
		backup_setting=$old_setting"_bak_"$time
		read -p "Find "$old_setting" already exists,backup "$old_setting" to "$backup_setting"? [Y/N] " ch
		if [[ $ch == "Y" ]] || [[ $ch == "y" ]];then
			cp $old_setting $backup_setting
		fi
        rm -rf $old_setting
	fi
}

# 备份原有的.vim 目录
function backup_vim_dir(){
	old_vim="$HOME/.vim"
	is_exist=$(is_exist_dir $old_vim)
	if [ $is_exist == 1 ];then
		time=$(get_datetime)
		backup_vim=$old_vim"_bak_"$time
		read -p "Find "$old_vim" already exists,backup "$old_vim" to "$backup_vim"? [Y/N] " ch
		if [[ $ch == "Y" ]] || [[ $ch == "y" ]];then
			cp -R $old_vim $backup_vim
		fi
	fi
}

# 备份原有的.vimrc文件
function backup_vimrc_file(){
	old_vimrc="$HOME/.vimrc"
	is_exist=$(is_exist_file $old_vimrc)
	if [ $is_exist == 1 ];then
		time=$(get_datetime)
		backup_vimrc=$old_vimrc"_bak_"$time
		read -p "Find "$old_vimrc" already exists,backup "$old_vimrc" to "$backup_vimrc"? [Y/N] " ch
		if [[ $ch == "Y" ]] || [[ $ch == "y" ]];then
			cp $old_vimrc $backup_vimrc
		fi
	fi
}


# 备份原有的.vimrc和.vim
function backup_vimrc_and_vim(){
	backup_vimrc_file
	backup_vim_dir
}


function pre_vim_init(){
	rm -rf ~/.vim
	rm -rf ~/.vimrc
	mkdir -p ~/.vim
	ln -s $WORKDIR/vimrc ~/.vimrc
        ln -s $WORKDIR/autoload ~/.vim
	ln -s $WORKDIR/ftplugin ~/.vim
	ln -s $WORKDIR/colors   ~/.vim
}

function pre_maven_init(){
    mkdir -p ~/.m2
    rm -rf ~/.m2/settings.xml
    ln -s $WORKDIR/maven/settings.xml ~/.m2/settings.xml
}

function pre_ssh_init(){
    ssh_dir="$HOME/.ssh"
    is_exist=$(is_exist_dir $ssh_dir)
	if [ $is_exist == 0 ];then
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh
    fi
    ln -s $WORKDIR/ssh/config ~/.ssh/config
}

function is_have_plugins_config(){
    zsh_config=$1
    flag=$(grep '# plugins=' $zsh_config)
    if [ -z $flag ];then
        echo 0
    else
        echo 1
    fi
}


function init_maven_config(){
    backup_m2_setting_file
    pre_maven_init
}

function init_vim_config(){
	backup_vimrc_and_vim
    pre_vim_init
}

function init_ssh_config(){
    backup_sshconfig_file
    pre_ssh_init
}

function gen_ssh_agent_identify(){
    prefix="zstyle :omz:plugins:ssh-agent identities"
    for i in $(file ~/.ssh/* | grep 'OpenSSH private' | cut -d':' -f1);do
        prefix=$prefix" "$(basename $i)
    done
    echo "$prefix"
}

function adjust_zsh_config(){
    zsh_config=$HOME/.zshrc
    is_exist=$(is_exist_file $zsh_config)
    if [ $is_exist == 1 ];then
        # 删除之前的plugins 和 ssh-agent 配置
        sed -i'' -e '/^plugins=/d' -e '/^zstyle :omz:plugins:ssh-agent/d' $zsh_config
        add_plugins=$(gen_ssh_agent_identify)
        sed -i'' -e '/source $ZSH/iplugins=(git ssh-agent)\n'"$add_plugins"'' $zsh_config

        # 删除之前写入的 zsh_profile 的内容， 重新写入
        sed -i'' -e '/^# MYCONFIG_ZSH_PROFILE/,$d' $zsh_config
        sed -i'' -e '$r'$WORKDIR'/zsh_profile' $zsh_config
    fi
}


function main(){
    read -p "Whether to initialize VIM configuration ? [Y/N]" ch
    if [[ $ch == "Y" ]] || [[ $ch == "y" ]];then
        init_vim_config
    else
        echo "Skip initialize VIM configuration"
    fi

    read -p "Whether to initialize maven configuration ? [Y/N]" ch
    if [[ $ch == "Y" ]] || [[ $ch == "y" ]];then
        init_maven_config
    else
        echo "Skip initialize maven configuration"
    fi

    read -p "Whether to initialize ssh configuration ? [Y/N]" ch
    if [[ $ch == "Y" ]] || [[ $ch == "y" ]];then
        init_ssh_config
    else
        echo "Skip initialize ssh configuration"
    fi

    read -p "Whether to initializw zsh configuration ? [Y/N]" ch
    if [[ $ch == "Y" ]] || [[ $ch == "y" ]];then
        adjust_zsh_config
    else
        echo "Skip initialize zsh configuration"
    fi
}

main
