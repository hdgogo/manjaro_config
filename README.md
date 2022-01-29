# manjaro_config

## 目的
用于系统切换为`manjaro`后，个人相关配置文件的同步。


## 操作步骤

### 准备工作
1. 安装Manjaro系统
2. 切换国内源
    ```shell
    $sudo pacman-mirrors -i -c China -m rank
    ```
3. 配置archlinuxcn源
    ```
    $sudo vi /etc/pacman.con
    > 在文档末尾添加
    [archlinuxcn]
    SigLevel = Optional TrustedOnly
    Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch

    [arch4edu]
    SigLevel = TrustAll
    Server = https://mirrors.tuna.tsinghua.edu.cn/arch4edu/$arch
    ```
4. 更新源列表
    ```
    $sudo pacman-mirrors -g
    ```

5. 更新pacman数据库并全面更新系统
    ```
    $sudo pacman -Syyu
    ```

6. 安装必备的软件（vim、maven、oh-my-zsh)
    ```
    $sudo pacman -S vim maven
    $sh -c "$(curl -fssl https://raw.fastgit.org/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    ```

### 安装
1. 克隆仓库到`~/.myconfig`
    ```shell
    $git clone https://github.com/hdgogo/manjaro_config.git ~/.myconfig
    ```

2. 运行install.sh脚本，初始化配置
    ```shell
    $cd ~/.myconfig
    $bash install.sh
    ```
