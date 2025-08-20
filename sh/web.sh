#!/bin/bash

# 定义目录路径
BASE_DIR="/data/web/sites/puck.host/www/"
REPO_DIR="$BASE_DIR/chatpuck.github.io"

# 安装 git
yum install -y git

# 克隆仓库到指定目录
git clone https://github.com/ChatPuck/chatpuck.github.io.git $REPO_DIR

# 进入仓库目录
cd $REPO_DIR

# 移动 docs 目录下的所有文件到与 chatpuck.github.io 同级目录
if [ -d "$REPO_DIR/docs" ]; then
    mv $REPO_DIR/docs/* $BASE_DIR/
    echo "已将 docs 目录下的所有文件移动到与 chatpuck.github.io 同级目录"
else
    echo "docs 目录不存在"
fi

# 移动 docs/post 目录下的所有文件到与 chatpuck.github.io 同级的 post 目录
if [ -d "$REPO_DIR/docs/post" ]; then
    shopt -s nullglob
    files=($REPO_DIR/docs/post/*)
    if [ ${#files[@]} -gt 0 ]; then
        mv $REPO_DIR/docs/post/* $BASE_DIR/post/
        echo "已将 docs/post/ 中的所有文件移动到 post 目录"
    else
        echo "docs/post/ 目录为空，无需移动"
    fi
    shopt -u nullglob
else
    echo "docs/post 目录不存在"
fi

# 将 backup/backup 文件夹移动到与 chatpuck.github.io 同级目录
if [ -d "$REPO_DIR/backup" ]; then
    mv $REPO_DIR/backup $BASE_DIR/
    echo "已将 backup/backup 文件夹移动到与 chatpuck.github.io 同级目录"
else
    echo "backup/backup 文件夹不存在"
fi

# 删除 chatpuck.github.io 文件夹
cd $BASE_DIR
rm -rf $REPO_DIR

# 删除 index.html 文件（如果存在）
if [ -f "$BASE_DIR/index.html" ]; then
    rm $BASE_DIR/index.html
    echo "删除 index.html 文件"
else
    echo "index.html 文件不存在"
fi

# 将 pc.html 重命名为 index.html（如果存在）
if [ -f "$BASE_DIR/pc.html" ]; then
    mv $BASE_DIR/pc.html $BASE_DIR/index.html
    echo "将 pc.html 重命名为 index.html"
else
    echo "pc.html 文件不存在"
fi
# 完成
echo "操作完成，chatpuck.github.io 文件夹已删除！"
