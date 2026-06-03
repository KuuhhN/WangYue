# 2026-06-03 开发日志：搜打撤生存游戏 MVP 阶段一

## 本轮成果

### Godot MVP 完整可运行（Claude 辅助迭代）

完成了 Zmbie Shelter 的 MVP 垂直切片（阶段一目标）：

- **搜打撤状态机** SEARCH → STRIKE → WITHDRAW → SETTLE 全流程
- **俯视角角色控制** 蹲伏(60)/行走(120)/奔跑(200) 三种移速 + 体力系统
- **僵尸 AI 6 状态** IDLE/PATROL/ALERTED/CHASING/ATTACKING/STUNNED/DEAD + 听觉+视觉感知
- **声音传播系统** 声波扩散（行走100px/奔跑250px/攻击150px）
- **近战攻击** 扇形40px检测 + 背后2x暴击 + 命中反馈（震动/卡肉/粒子）
- **超市固定地图** 10个区域（停车场→仓库）
- **避难所经营面板** 资源管理 + 出征/结束回合 + 随机事件
- **游戏主菜单→避难所→扫荡→结算 完整循环**

### 修复问题
1. `theme_override_styles` 引用空 Resource → 删除
2. ColorRect 子节点盖住按钮 → 全部加 `mouse_filter = 2`
3. 背景层 ColorRect 拦截鼠标事件 → 加 `mouse_filter = 2`
4. `inferred_type_variant` 警告被当成错误 → 加配置禁用

### 技术栈变更
- 项目结构经 Claude 重构优化
- 已导出可执行文件（build/ dir）
- 安装 LibreSprite 准备像素美术

## 下线状态

- 代码层：MVP 可玩，彩色方块占位
- 美术层：尚未开始，LibreSprite 就绪
- 下一阶段：学像素画，逐步替换占位图形

## 技术教训
1. ColorRect 是 Control 节点，默认 MOUSE_FILTER_STOP，铺满全屏会吃掉所有鼠标事件
2. Godot 4.x 的 `inferred_type_variant` 警告在严格模式下会阻断运行
3. LibreSprite 的 gen.exe 不是主程序，主程序是 libresprite.exe
