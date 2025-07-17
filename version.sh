#!/bin/bash

# version.sh - 版本管理脚本
# 使用方法: 
#   ./version.sh patch   # 增加 patch 版本 (1.0.0 -> 1.0.1)
#   ./version.sh minor   # 增加 minor 版本 (1.0.0 -> 1.1.0)
#   ./version.sh major   # 增加 major 版本 (1.0.0 -> 2.0.0)
#   ./version.sh x.y.z   # 设置指定版本

set -e

# 获取当前版本
CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
echo "当前版本: $CURRENT_VERSION"

# 解析当前版本号
if [[ $CURRENT_VERSION =~ v([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
    MAJOR=${BASH_REMATCH[1]}
    MINOR=${BASH_REMATCH[2]}
    PATCH=${BASH_REMATCH[3]}
else
    MAJOR=1
    MINOR=0
    PATCH=0
fi

echo "解析的版本: $MAJOR.$MINOR.$PATCH"

# 处理版本增加
case "$1" in
    "patch")
        PATCH=$((PATCH + 1))
        ;;
    "minor")
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    "major")
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    [0-9]*.[0-9]*.[0-9]*)
        if [[ $1 =~ ([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
            MAJOR=${BASH_REMATCH[1]}
            MINOR=${BASH_REMATCH[2]}
            PATCH=${BASH_REMATCH[3]}
        else
            echo "错误: 版本格式不正确。应该是 x.y.z 格式"
            exit 1
        fi
        ;;
    "")
        echo "用法: $0 {patch|minor|major|x.y.z}"
        echo "示例:"
        echo "  $0 patch   # $MAJOR.$MINOR.$PATCH -> $MAJOR.$MINOR.$((PATCH + 1))"
        echo "  $0 minor   # $MAJOR.$MINOR.$PATCH -> $MAJOR.$((MINOR + 1)).0"
        echo "  $0 major   # $MAJOR.$MINOR.$PATCH -> $((MAJOR + 1)).0.0"
        echo "  $0 2.1.0   # 设置为指定版本"
        exit 1
        ;;
    *)
        echo "错误: 无效的版本类型 '$1'"
        echo "支持的类型: patch, minor, major, 或具体版本号 (如 1.2.3)"
        exit 1
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
NEW_TAG="v$NEW_VERSION"

echo "新版本: $NEW_VERSION"
echo "新标签: $NEW_TAG"

# 检查是否有未提交的更改
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "警告: 工作目录有未提交的更改"
    echo "建议先提交所有更改，然后再创建新版本"
    read -p "是否继续? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# 更新版本号在相关文件中
echo "更新版本号..."

# 更新 build.sh
if [ -f "build.sh" ]; then
    # 使用 sed 替换版本号
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/applevision-ocr-[0-9]\+\.[0-9]\+\.[0-9]\+\.jar/applevision-ocr-$NEW_VERSION.jar/g" build.sh
    else
        # Linux
        sed -i "s/applevision-ocr-[0-9]\+\.[0-9]\+\.[0-9]\+\.jar/applevision-ocr-$NEW_VERSION.jar/g" build.sh
    fi
    echo "已更新 build.sh"
fi

# 更新 deploy.sh
if [ -f "deploy.sh" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/applevision-ocr-[0-9]\+\.[0-9]\+\.[0-9]\+\.jar/applevision-ocr-$NEW_VERSION.jar/g" deploy.sh
        sed -i '' "s/applevision-ocr-[0-9]\+\.[0-9]\+\.[0-9]\+-complete\.jar/applevision-ocr-$NEW_VERSION-complete.jar/g" deploy.sh
    else
        # Linux
        sed -i "s/applevision-ocr-[0-9]\+\.[0-9]\+\.[0-9]\+\.jar/applevision-ocr-$NEW_VERSION.jar/g" deploy.sh
        sed -i "s/applevision-ocr-[0-9]\+\.[0-9]\+\.[0-9]\+-complete\.jar/applevision-ocr-$NEW_VERSION-complete.jar/g" deploy.sh
    fi
    echo "已更新 deploy.sh"
fi

# 更新 README.md 中的示例
if [ -f "README.md" ]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/applevision-ocr-[0-9]\+\.[0-9]\+\.[0-9]\+/applevision-ocr-$NEW_VERSION/g" README.md
        sed -i '' "s/applevision-ocr-[0-9]\+\.[0-9]\+\.[0-9]\+-complete/applevision-ocr-$NEW_VERSION-complete/g" README.md
    else
        # Linux
        sed -i "s/applevision-ocr-[0-9]\+\.[0-9]\+\.[0-9]\+/applevision-ocr-$NEW_VERSION/g" README.md
        sed -i "s/applevision-ocr-[0-9]\+\.[0-9]\+\.[0-9]\+-complete/applevision-ocr-$NEW_VERSION-complete/g" README.md
    fi
    echo "已更新 README.md"
fi

# 提交更改并创建标签
echo "提交更改..."
git add -A
git commit -m "bump version to $NEW_VERSION" || echo "没有需要提交的更改"

echo "创建标签..."
git tag -a "$NEW_TAG" -m "Release $NEW_TAG"

echo ""
echo "✅ 版本更新完成!"
echo "当前版本: $NEW_TAG"
echo ""
echo "接下来的步骤:"
echo "1. 推送更改到远程仓库:"
echo "   git push origin master"
echo "   git push origin $NEW_TAG"
echo ""
echo "2. 或者推送所有标签:"
echo "   git push origin master --tags"
echo ""
echo "3. GitHub Actions 将自动构建并发布到 Releases"
