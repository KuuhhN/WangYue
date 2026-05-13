# iOS记账应用 - 基础版功能规格

## 项目概述
**目标**: 开发一款基础的iOS记账手机端应用，专注于个人日常收支记录与管理。

**技术栈**:
- SwiftUI 2025 (iOS 17+)
- SwiftData (数据持久化)
- MVVM架构模式
- 本地存储 (无云同步 - 基础版)

## 核心功能模块

### 1. 交易记录 (Transaction)
**功能点**:
- 添加支出/收入记录
- 金额输入 (支持小数)
- 分类选择
- 日期选择 (默认当天)
- 备注信息 (可选)
- 附件拍照 (可选 - 高级功能)

**数据模型**:
```swift
struct Transaction {
    let id: UUID
    let type: TransactionType // .expense 或 .income
    let amount: Double
    let category: Category
    let date: Date
    let note: String?
    let attachmentURL: URL? // 收据照片
}
```

### 2. 分类管理 (Category)
**选项A: 固定分类系统** (简单)
- 预定义分类: 餐饮、交通、购物、娱乐、医疗、教育、其他
- 支出/收入分别有固定分类
- 不可添加自定义分类

**选项B: 自定义分类系统** (灵活)
- 用户可以添加/编辑/删除分类
- 分类图标选择
- 分类颜色标记
- 支出/收入分类分开管理

### 3. 主页与概览 (Home/Dashboard)
**功能点**:
- 当前余额显示
- 本月支出/收入总计
- 近期交易列表 (最近10条)
- 分类支出饼图 (简单版)
- 月度趋势概览

### 4. 统计报表 (Statistics)
**基础版功能**:
- 月度支出/收入对比
- 分类支出占比 (饼图/条形图)
- 支出趋势折线图 (可选)
- 导出报表为CSV (可选)

### 5. 预算管理 (Budget) - 可选
**基础预算功能**:
- 月度总预算设置
- 分类预算设置
- 预算进度条显示
- 超支提醒

## 技术实现细节

### 数据持久化 (SwiftData)
```swift
@Model
class Transaction {
    @Attribute(.unique) var id: UUID
    var type: String // "expense" or "income"
    var amount: Double
    var category: Category
    var date: Date
    var note: String?
    
    // 关系
    @Relationship(deleteRule: .nullify) var category: Category?
}

@Model
class Category {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String // SF Symbol名称
    var colorHex: String
    var type: String // "expense" or "income"
}
```

### 视图结构规划
1. **TabView主框架**:
   - 主页 (HomeView)
   - 添加记录 (AddTransactionView)
   - 分类管理 (CategoryView)
   - 统计报表 (StatisticsView)
   - 设置 (SettingsView)

2. **核心视图组件**:
   - TransactionListView
   - CategoryPickerView
   - AmountInputView
   - DatePickerView
   - ChartView (简单版)

### 开发环境要求
- **Xcode**: 15.0+ (推荐17.0+)
- **macOS**: Sonoma 14.0+
- **iOS部署目标**: 17.0+
- **测试设备**: iPhone (iOS 17+)

## 开发时间线预估

### 阶段1: 需求与设计 (1天)
- [ ] 功能规格最终确认
- [ ] UI/UX设计草图
- [ ] 数据模型设计确认
- [ ] 开发环境配置检查

### 阶段2: 基础框架 (1天)
- [ ] Xcode项目创建
- [ ] SwiftData模型实现
- [ ] 基础TabView框架
- [ ] 核心ViewModel实现

### 阶段3: 核心功能 (3天)
- [ ] 交易记录CRUD功能
- [ ] 分类管理功能
- [ ] 主页概览视图
- [ ] 基本统计功能

### 阶段4: 界面优化 (1天)
- [ ] UI美化与动画
- [ ] 交互优化
- [ ] 错误处理与提示
- [ ] 性能优化

### 阶段5: 测试与发布 (1天)
- [ ] 单元测试编写
- [ ] 真机测试
- [ ] App Store准备 (可选)
- [ ] 文档编写

**总计**: 7个工作日

## 资源需求

### 学习资源 (已获取)
1. SwiftUI 2025初学者指南
2. AppCoda个人财务应用教程
3. 预算跟踪应用完整项目
4. SwiftData官方文档

### 开发资源
1. SF Symbols图标库
2. Swift Charts框架 (基础图表)
3. 本地化支持 (中英文)

## 风险评估

### 技术风险
1. **SwiftData学习曲线** - 新框架，可能需要额外学习时间
2. **图表实现复杂度** - Swift Charts可能需要调试
3. **数据迁移** - 未来功能升级时的数据兼容性

### 项目风险
1. **功能蔓延** - 坚持基础版范围，避免过度开发
2. **时间预估** - 预留20%缓冲时间
3. **测试覆盖** - 确保核心功能稳定

## 下一步行动

### 立即需要用户确认:
1. **分类系统选择** - 固定分类 vs 自定义分类
2. **预算功能需求** - 是否需要基础预算管理
3. **图表复杂度** - 简单图表 vs 详细报表
4. **开发环境状态** - macOS/Xcode/真机可用性

### 开发准备:
1. 检查Xcode安装与版本
2. 创建GitHub仓库 (可选)
3. 准备开发文档模板
4. 收集UI设计灵感参考

---
*文档版本: 1.0 | 创建时间: 2026-03-25 18:05*
*待用户确认后开始开发*