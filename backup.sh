#!/bin/bash

while getopts "d:s:v:" opt; do
  case ${opt} in
    d ) # 拷贝的路径
      dest_path=$OPTARG
      ;;
    s ) # 快照的路径
      snapshot_path=$OPTARG
      ;;
    \? ) echo "Usage: $0 [-d destination_path] [-s snapshot_path]"
         exit 1
      ;;
  esac
done

# 默认拷贝路径为 /backup
dest_path=${dest_path:-/backup}

# 默认快照路径为 /snapshot
snapshot_path=${snapshot_path:-/snapshot}

# 检查目标路径是否存在，如果不存在则创建
if [ ! -d $dest_path ]; then
  mkdir -p $dest_path
  # 创建子卷
  btrfs subvolume create $dest_path 
fi

# 拷贝快照到目标路径
sudo rsync -avxHAX --numeric-ids --delete / $dest_path/

# 创建快照
sudo btrfs subvolume snapshot -r $dest_path $snapshot_path/snapshot-$(date +'%Y-%m-%d')-$(uuidgen | cut -d'-' -f4)
