#!/bin/bash

# 获取当前时间戳，格式如：20260623_1126
TIMESTAMP=$(date +"%Y%m%d_%H%M")
# 获取当前日期用于 commit message
DATE_STR=$(date +"%Y-%m-%d %H:%M:%S")

# 从 index.html 提取当前的主版本号 (X.Y.Z)
CURRENT_VERSION=$(grep -oE '<span class="version" id="version-badge">v([0-9]+\.[0-9]+\.[0-9]+)' index.html | sed -E 's/.*v([0-9]+\.[0-9]+\.[0-9]+).*/\1/')

if [ -z "$CURRENT_VERSION" ]; then
    echo "无法提取当前版本号，使用默认 1.0.0"
    CURRENT_VERSION="1.0.0"
fi

# 拆分大版本、次版本、修订号
IFS='.' read -r v1 v2 v3 <<< "$CURRENT_VERSION"
# 修订号加 1
v3=$((v3 + 1))
NEW_VERSION="${v1}.${v2}.${v3}"

echo "==> 正在更新版本号：v${CURRENT_VERSION} -> v${NEW_VERSION}_$TIMESTAMP ..."

# 替换 index.html 里面的版本和时间戳
sed -i '' -E 's/<span class="version" id="version-badge">v[0-9]+\.[0-9]+\.[0-9]+(_[0-9_]+)?<\/span>/<span class="version" id="version-badge">v'"$NEW_VERSION"'_'"$TIMESTAMP"'<\/span>/g' index.html

echo "==> 正在提交代码并推送到远程仓库..."

git add index.html deploy.sh
git commit -m "deploy: auto bump version to v${NEW_VERSION}_$TIMESTAMP"
git push

echo "==> 部署完成！GitHub Pages 即将自动更新。"
