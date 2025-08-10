#!/bin/bash

# Rust 编译优化脚本

echo "🚀 设置 Rust 编译缓存优化..."

# 检查是否安装了 sccache
if ! command -v sccache &> /dev/null; then
    echo "📦 安装 sccache 编译缓存工具..."
    cargo install sccache
fi

# 设置环境变量
export RUSTC_WRAPPER=sccache
export SCCACHE_DIR=$HOME/.cache/sccache
export SCCACHE_CACHE_SIZE="10G"

# 创建缓存目录
mkdir -p $SCCACHE_DIR

# 显示 sccache 统计信息
echo "📊 sccache 统计信息："
sccache --show-stats

# 将环境变量添加到 shell 配置文件
SHELL_RC=""
if [[ $SHELL == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ $SHELL == *"bash"* ]]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [[ -n $SHELL_RC ]]; then
    echo "🔧 添加 Rust 缓存配置到 $SHELL_RC..."
    
    # 检查是否已经配置
    if ! grep -q "RUSTC_WRAPPER=sccache" "$SHELL_RC"; then
        echo "" >> "$SHELL_RC"
        echo "# Rust 编译缓存配置" >> "$SHELL_RC"
        echo "export RUSTC_WRAPPER=sccache" >> "$SHELL_RC"
        echo "export SCCACHE_DIR=\$HOME/.cache/sccache" >> "$SHELL_RC"
        echo "export SCCACHE_CACHE_SIZE=\"10G\"" >> "$SHELL_RC"
        echo "✅ 配置已添加到 $SHELL_RC"
    else
        echo "✅ 配置已存在于 $SHELL_RC"
    fi
fi

echo "🎉 Rust 编译缓存优化设置完成！"
echo ""
echo "💡 提示："
echo "  - 第一次编译依然会比较慢，之后会显著加速"
echo "  - 可以运行 'sccache --show-stats' 查看缓存命中率"
echo "  - 重启终端或运行 'source $SHELL_RC' 使配置生效"
