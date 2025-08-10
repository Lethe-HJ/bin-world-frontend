# Rust 编译速度优化

本项目已经配置了多项 Rust 编译优化，显著减少重复编译时间。

## 已配置的优化

### 1. sccache 编译缓存
- **功能**：缓存编译结果，避免重复编译相同的代码
- **配置**：自动在 `scripts/dev.sh` 中启用
- **缓存目录**：`~/.cache/sccache`
- **缓存大小**：10GB

### 2. 增量编译
- **功能**：只重新编译修改过的部分
- **配置**：在 `Cargo.toml` 中启用 `incremental = true`

### 3. 并行编译
- **功能**：利用多核 CPU 并行编译
- **配置**：
  - 开发模式：`codegen-units = 256`
  - 编译作业数：4 个并行任务

### 4. 依赖项优化
- **功能**：对依赖项使用最高优化级别
- **原理**：依赖项不经常变化，可以预编译并缓存
- **配置**：`[profile.dev.package."*"] opt-level = 3`

### 5. 智能链接优化
- **功能**：使用更快的链接器
- **配置**：在 `.cargo/config.toml` 中启用 `lld` 链接器

## 使用方法

### 自动使用（推荐）
直接运行开发命令，优化会自动生效：
```bash
yarn dev
```

### 手动设置缓存
如果需要单独设置 sccache：
```bash
./scripts/setup-rust-cache.sh
```

### 查看缓存统计
```bash
sccache --show-stats
```

## 预期效果

- **首次编译**：与原来相同（需要编译所有依赖）
- **后续编译**：
  - 无修改：几乎瞬时完成
  - 小幅修改：仅编译修改的部分
  - 新增依赖：只编译新依赖，已有依赖使用缓存

## 缓存管理

### 清理缓存
如果缓存出现问题，可以清理：
```bash
# 清理 sccache
sccache --stop-server
rm -rf ~/.cache/sccache
sccache --start-server

# 清理 Cargo 缓存
cargo clean
```

### 查看缓存大小
```bash
du -sh ~/.cache/sccache
du -sh ~/.cargo/registry
```

## 故障排除

### sccache 未生效
1. 检查是否安装：`which sccache`
2. 检查环境变量：`echo $RUSTC_WRAPPER`
3. 重新安装：`cargo install sccache`

### 编译仍然很慢
1. 确认使用了开发模式：`cargo build`（不要用 `--release`）
2. 检查并行编译：`echo $CARGO_BUILD_JOBS`
3. 验证增量编译：查看 `target/debug/incremental/` 目录

## 技术细节

### 配置文件
- `src-tauri/Cargo.toml`：编译配置文件
- `src-tauri/.cargo/config.toml`：Cargo 配置
- `scripts/dev.sh`：自动设置环境变量

### 环境变量
- `RUSTC_WRAPPER=sccache`：启用编译缓存
- `SCCACHE_DIR`：缓存目录
- `SCCACHE_CACHE_SIZE`：缓存大小限制

通过这些优化，您的 Rust 编译速度应该会有显著提升！🚀
