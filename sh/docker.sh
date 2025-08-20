#!/bin/bash
# Docker 安装与管理脚本
install_docker() {
    echo "===== 安装 Docker ====="

    echo "移除旧版本的 Docker（如果存在）..."
    sudo yum remove -y docker \
                   docker-common \
                   docker-selinux \
                   docker-engine

    echo "安装必要的依赖包..."
    sudo yum install -y yum-utils device-mapper-persistent-data lvm2

    echo "添加 Docker 仓库..."
    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    echo "更新 yum 缓存..."
    sudo yum makecache fast

    echo "安装 Docker CE、Docker CLI 和 containerd.io..."
    sudo yum install -y docker-ce docker-ce-cli containerd.io

    echo "启动 Docker 服务..."
    sudo systemctl start docker

    echo "设置 Docker 开机自启..."
    sudo systemctl enable docker

    echo "验证 Docker 安装..."
    docker version

    if [ $? -eq 0 ]; then
        echo "Docker 安装并启动成功。"
    else
        echo "Docker 安装失败。请检查上方日志以获取详细信息。"
    fi

    echo "=========================="
}

# 通用函数：列出容器并允许操作
list_and_manage_containers() {
    local filter=$1  # "running" 或 "all"

    if [ "$filter" == "running" ]; then
        echo "===== 运行中的 Docker 容器 ====="
        containers=($(docker ps --format "{{.ID}} {{.Names}} {{.Image}}"))
    elif [ "$filter" == "all" ]; then
        echo "===== 所有 Docker 容器（包括已停止的） ====="
        containers=($(docker ps -a --format "{{.ID}} {{.Names}} {{.Image}}"))
    else
        echo "无效的过滤选项。"
        return
    fi

    if [ ${#containers[@]} -eq 0 ]; then
        echo "当前没有符合条件的容器。"
        echo "=============================="
        return
    fi

    # 显示带序号的容器列表
    echo -e "序号\t容器ID\t\t名称\t\t镜像"
    echo "--------------------------------------------------------------"
    index=1
    declare -A container_map
    for ((i=0; i<${#containers[@]}; i+=3)); do
        cid=${containers[i]}
        cname=${containers[i+1]}
        cimage=${containers[i+2]}
        printf "%-4s\t%-12s\t%-12s\t%-12s\n" "$index" "$cid" "$cname" "$cimage"
        container_map[$index]="$cid"
        ((index++))
    done
    echo "--------------------------------------------------------------"

    # 提示用户选择操作
    while true; do
        read -p "请输入要操作的容器序号（或按回车返回主菜单）： " selected
        if [ -z "$selected" ]; then
            echo "返回主菜单。"
            break
        elif [[ ! "$selected" =~ ^[0-9]+$ ]] || [ "$selected" -lt 1 ] || [ "$selected" -ge "$index" ]; then
            echo "无效的序号。请重新输入。"
        else
            selected_cid=${container_map[$selected]}
            echo "选择的容器ID: $selected_cid"
            echo "请选择操作："
            echo "1. 停止容器"
            echo "2. 删除容器"
            echo "3. 返回上一级"
            read -p "请输入您的选择 [1-3]: " action
            case $action in
                1)
                    stop_container_by_id "$selected_cid"
                    ;;
                2)
                    remove_container_by_id "$selected_cid"
                    ;;
                3)
                    echo "返回上一级。"
                    ;;
                *)
                    echo "无效的选择。"
                    ;;
            esac
        fi
    done
    echo "=============================="
}

# 函数：停止容器通过容器ID
stop_container_by_id() {
    local cid=$1
    echo "正在停止容器 '$cid'..."
    sudo docker stop "$cid"
    if [ $? -eq 0 ]; then
        echo "容器 '$cid' 已成功停止。"
    else
        echo "无法停止容器 '$cid'。"
    fi
    echo "==========================="
}

# 函数：删除容器通过容器ID
remove_container_by_id() {
    local cid=$1
    echo "正在删除容器 '$cid'..."
    sudo docker rm "$cid"
    if [ $? -eq 0 ]; then
        echo "容器 '$cid' 已成功删除。"
    else
        echo "无法删除容器 '$cid'。该容器可能正在运行。"
    fi
    echo "==========================="
}

# 函数：显示菜单
show_menu() {
    echo "========================================="
    echo "          Docker 管理菜单"
    echo "========================================="
    echo "1. 安装 Docker"
    echo "2. 查看运行中的容器"
    echo "3. 列出所有容器（包括已停止的）"
    echo "4. 退出"
    echo "========================================="
}

# 主循环：显示菜单并处理用户输入
while true; do
    show_menu
    read -p "请输入您的选择 [1-4]： " choice
    echo ""

    case $choice in
        1)
            install_docker
            ;;
        2)
            list_and_manage_containers "running"
            ;;
        3)
            list_and_manage_containers "all"
            ;;
        4)
            echo "正在退出 Docker 管理脚本。再见！"
            exit 0
            ;;
        *)
            echo "无效的选择。请输入 1 到 4 之间的数字。"
            ;;
    esac

    echo ""
    read -p "按回车键继续..."
    clear
done
