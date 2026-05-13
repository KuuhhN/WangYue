# Web记账应用开发计划

## 项目概述
**项目名称:** ExpensePWA - 个人记账Web应用
**启动时间:** 2026-03-26
**目标周期:** 5个工作日 (2026-03-26 至 2026-03-30)
**技术栈:** HTML5 + CSS3 + JavaScript + PWA + LocalStorage
**目标设备:** iPhone 14 Pro Max (iOS 17+)
**开发环境:** Windows笔记本 (机械革命极光pro) + VS Code

## 开发目标

### 核心功能需求
1. **支出记录** - 添加、查看、编辑、删除支出记录
2. **分类管理** - 自定义标签系统 (支持添加/编辑/删除)
3. **可视化统计** - 色块大小表示支出金额 (气泡图)
4. **月度统计** - 基础图表展示月度支出趋势
5. **离线使用** - 纯本地存储，无需网络连接
6. **PWA支持** - 可添加到iPhone主屏幕，类似原生应用体验

### 用户体验目标
- 响应式设计，完美适配iPhone 14 Pro Max
- 流畅的触摸交互体验
- 简洁直观的界面设计
- 快速的数据操作响应
- 可靠的数据持久化

## 详细开发计划

### Day 1: 基础框架搭建 (2026-03-26)

#### 上午: 开发环境配置
- [ ] 安装VS Code及必要扩展
  - Live Server (本地服务器)
  - Prettier (代码格式化)
  - ESLint (代码检查)
- [ ] 创建项目文件夹结构
- [ ] 设置Git版本控制 (可选)

#### 下午: 基础页面开发
- [ ] 创建基础HTML结构 (`index.html`)
- [ ] 设计响应式CSS布局 (`style.css`)
- [ ] 实现iPhone 14 Pro Max适配
- [ ] 创建基础JavaScript框架 (`app.js`)

#### 技术要点:
- Flexbox/Grid布局系统
- CSS变量与主题系统
- 移动端视口配置
- 基础JavaScript模块化

### Day 2: 核心功能实现 (2026-03-27)

#### 上午: 数据模型与存储
- [ ] 设计交易数据模型
- [ ] 实现LocalStorage数据持久化
- [ ] 创建数据管理类 (ExpenseManager)
- [ ] 实现CRUD操作接口

#### 下午: 用户界面开发
- [ ] 添加交易表单实现
- [ ] 交易列表展示组件
- [ ] 分类选择器组件
- [ ] 余额计算与显示

#### 技术要点:
- JavaScript类与模块设计
- LocalStorage API使用
- 表单验证与错误处理
- 事件驱动编程

### Day 3: 可视化统计开发 (2026-03-28)

#### 上午: 色块可视化实现
- [ ] 气泡图算法设计 (大小映射金额)
- [ ] Canvas/SVG基础图形绘制
- [ ] 颜色映射系统 (按分类)
- [ ] 交互效果实现 (悬停、点击)

#### 下午: 统计图表开发
- [ ] 月度支出趋势图
- [ ] 分类支出饼图/条形图
- [ ] 数据过滤与聚合
- [ ] 统计面板组件

#### 技术要点:
- Canvas绘图API
- 数据可视化算法
- 图表交互设计
- 性能优化考虑

### Day 4: PWA优化与离线功能 (2026-03-29)

#### 上午: PWA配置
- [ ] 创建manifest.json配置文件
- [ ] 设计应用图标 (多种尺寸)
- [ ] 配置Service Worker
- [ ] 实现离线缓存策略

#### 下午: 高级功能开发
- [ ] 数据导入/导出功能
- [ ] 分类管理界面
- [ ] 设置页面开发
- [ ] 错误处理与恢复

#### 技术要点:
- PWA标准与配置
- Service Worker生命周期
- 离线数据同步
- 数据备份策略

### Day 5: 测试与优化 (2026-03-30)

#### 上午: 真机测试
- [ ] iPhone 14 Pro Max Safari测试
- [ ] 添加到主屏幕测试
- [ ] 离线功能验证
- [ ] 性能测试与优化

#### 下午: 代码优化与文档
- [ ] 代码重构与优化
- [ ] 错误处理完善
- [ ] 用户文档编写
- [ ] 项目总结与回顾

#### 技术要点:
- 移动端调试技巧
- 性能分析工具使用
- 代码质量检查
- 用户体验测试

## 技术架构

### 文件结构
```
expense-pwa/
├── index.html          # 主入口文件
├── style.css          # 样式文件
├── app.js             # 主应用程序逻辑
├── modules/           # JavaScript模块
│   ├── storage.js     # 数据存储模块
│   ├── ui.js          # 用户界面模块
│   ├── chart.js       # 图表可视化模块
│   └── pwa.js         # PWA功能模块
├── manifest.json      # PWA配置文件
├── service-worker.js  # Service Worker文件
└── icons/             # 应用图标
    ├── icon-72.png
    ├── icon-96.png
    ├── icon-128.png
    ├── icon-144.png
    ├── icon-152.png
    ├── icon-192.png
    ├── icon-384.png
    └── icon-512.png
```

### 数据模型设计
```javascript
// 交易数据模型
class Transaction {
    constructor(id, amount, type, category, date, note) {
        this.id = id;           // UUID
        this.amount = amount;   // 金额
        this.type = type;       // 'expense' 或 'income'
        this.category = category; // 分类名称
        this.date = date;       // 日期 (YYYY-MM-DD)
        this.note = note;       // 备注
    }
}

// 分类数据模型
class Category {
    constructor(id, name, color, icon, budget) {
        this.id = id;           // UUID
        this.name = name;       // 分类名称
        this.color = color;     // 16进制颜色
        this.icon = icon;       // 图标表情
        this.budget = budget;   // 月度预算 (可选)
    }
}
```

### 可视化方案

#### 气泡图算法
```javascript
/**
 * 计算气泡大小
 * @param {number} amount - 支出金额
 * @param {number} minAmount - 最小金额
 * @param {number} maxAmount - 最大金额
 * @returns {number} 气泡直径(px)
 */
function calculateBubbleSize(amount, minAmount, maxAmount) {
    const minSize = 30;  // 最小气泡尺寸
    const maxSize = 120; // 最大气泡尺寸
    
    if (maxAmount === minAmount) return (minSize + maxSize) / 2;
    
    // 使用对数缩放，避免超大金额导致气泡过大
    const logAmount = Math.log10(amount + 1);
    const logMin = Math.log10(minAmount + 1);
    const logMax = Math.log10(maxAmount + 1);
    
    const normalized = (logAmount - logMin) / (logMax - logMin);
    return minSize + normalized * (maxSize - minSize);
}
```

#### 颜色映射策略
```javascript
// 预设分类颜色
const CATEGORY_COLORS = {
    '餐饮': '#FF6B6B',    // 红色
    '交通': '#4ECDC4',    // 青色
    '购物': '#45B7D1',    // 蓝色
    '娱乐': '#96CEB4',    // 绿色
    '医疗': '#FFEAA7',    // 黄色
    '教育': '#DDA0DD',    // 紫色
    '其他': '#778899'     // 灰色
};

// 动态颜色生成 (用于自定义分类)
function generateColor(categoryName) {
    // 基于分类名称生成确定性颜色
    let hash = 0;
    for (let i = 0; i < categoryName.length; i++) {
        hash = categoryName.charCodeAt(i) + ((hash << 5) - hash);
    }
    
    const hue = hash % 360;
    return `hsl(${hue}, 70%, 60%)`;
}
```

## 开发资源

### 学习资源
1. **HTML5/CSS3基础**
   - MDN Web Docs: https://developer.mozilla.org/
   - W3Schools: https://www.w3schools.com/

2. **JavaScript教程**
   - JavaScript.info: https://javascript.info/
   - Eloquent JavaScript: https://eloquentjavascript.net/

3. **PWA开发指南**
   - Google PWA文档: https://web.dev/progressive-web-apps/
   - MDN Service Worker: https://developer.mozilla.org/Service_Worker_API

### 开发工具
1. **代码编辑器:** VS Code
2. **本地服务器:** Live Server扩展
3. **调试工具:** Chrome DevTools
4. **版本控制:** Git (可选)
5. **图标生成:** Favicon.io

### 测试工具
1. **浏览器测试:** Chrome, Safari, Firefox
2. **真机测试:** iPhone 14 Pro Max Safari
3. **性能测试:** Lighthouse
4. **PWA测试:** PWA Builder

## 风险评估与应对

### 技术风险
| 风险 | 概率 | 影响 | 应对措施 |
|------|------|------|----------|
| LocalStorage容量限制 | 中 | 中 | 实现数据清理机制，考虑IndexedDB迁移 |
| iOS Safari兼容性问题 | 低 | 高 | 提前进行真机测试，使用Polyfill |
| PWA离线功能不稳定 | 中 | 中 | 完善的错误处理，备用存储方案 |
| 性能问题 (大量数据) | 低 | 低 | 数据分页加载，虚拟滚动优化 |

### 项目风险
| 风险 | 概率 | 影响 | 应对措施 |
|------|------|------|----------|
| 开发时间不足 | 中 | 中 | 优先实现核心功能，简化非必要特性 |
| 功能范围蔓延 | 高 | 高 | 严格遵循需求清单，记录新需求待后续迭代 |
| 学习曲线较陡 | 高 | 中 | 提供详细指导，分步学习，及时解答问题 |

## 质量保证

### 代码质量
- 使用ESLint进行代码规范检查
- 使用Prettier进行代码格式化
- 模块化设计，保持单一职责原则
- 详细的代码注释和文档

### 测试策略
1. **单元测试:** 核心算法和工具函数
2. **集成测试:** 模块间交互测试
3. **功能测试:** 核心业务流程测试
4. **兼容性测试:** 不同浏览器和设备测试
5. **用户体验测试:** 真机操作流程测试

### 性能指标
- 首次加载时间 < 3秒
- 交互响应时间 < 100ms
- 内存使用 < 50MB
- 本地存储容量 < 10MB

## 交付成果

### 主要交付物
1. **完整源代码** - 所有开发文件
2. **PWA配置文件** - manifest.json和Service Worker
3. **应用图标集** - 多尺寸PNG图标
4. **用户手册** - 使用说明文档
5. **开发文档** - 技术架构说明

### 成功标准
- [ ] 核心记账功能完整可用
- [ ] 色块可视化统计正常工作
- [ ] iPhone真机测试通过
- [ ] PWA离线功能验证
- [ ] 用户体验流畅自然

## 后续迭代规划

### V1.1版本 (功能增强)
- 预算设置与提醒
- 数据图表导出
- 多主题切换
- 数据同步功能

### V1.2版本 (体验优化)
- 手势操作支持
- 动画过渡效果
- 语音输入支持
- 智能分类建议

### V2.0版本 (平台扩展)
- 多设备数据同步
- 数据云备份
- 多用户支持
- 高级分析报告

---
*本计划创建于: 2026-03-25 18:40*
*开发启动时间: 2026-03-26 09:00*
*项目经理: Apex (Tech & Academic Butler)*