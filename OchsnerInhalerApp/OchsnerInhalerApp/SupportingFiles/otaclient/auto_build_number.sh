#!/bin/bash
# 自动build号生成器
# Copyright (c) 2018 realtek. All rights reserved.


## 约束
# 支持两种格式：1.BRANCH.VERSION 的格式字符串， BRANCH长度在3~20之间，必须以字母或下划线开始，VERSION为10进制整数，长度不超过6位；
# 2.只有10进制整数。

# 处理流程：
# 1.读取当前项目的Bundle Version;
# 2.对Bundle Version格式进行检查，是否为格式[{branch}.]version，是否是本脚本可以进行处理的；
# 3.取出Bundle Version中的分支名称和版本号；
# 4.用git status得到当前项目所在的分支；
# 5.使用git得到的分支更新原来版本号中的分支部分，如果没有得到则仍用版本号中的分支；
# 6.对版本号加1处理；
# 7.重新组合成规范的版本号字符串，设置到plist文件中；

build=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${PROJECT_DIR}/${INFOPLIST_FILE}")
echo "Current build number: $build"

# 解析info.plist中的build
if echo $build | grep "^[A-Za-z_]\w\{0,20\}\.\d\{1,6\}$" > /dev/null
then
branch=${build%%.*}
edition=${build##*.}
elif echo $build | grep "^\d\{1,6\}$"  > /dev/null
then
edition=$build
else
echo "Not a valid build number."
exit 1
fi

# git branch查询当前所处的branch
branchLine=$(git branch | grep '^* ')
currentBranch=${branchLine#"* "}

if [ $currentBranch ] && [ $currentBranch != '0' ] ; then
echo "Current branch: $currentBranch"
branch=$currentBranch
fi

# 修订号增加1
edition=$((edition+1))

if [ $branch ]
then
echo "New build: $branch.$edition"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $branch.$edition" "${PROJECT_DIR}/${INFOPLIST_FILE}"
else
echo "New build: $edition"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $edition" "${PROJECT_DIR}/${INFOPLIST_FILE}"
fi

exit 0
