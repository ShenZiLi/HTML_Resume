# HTML 简历编辑器 - 系统详细设计文档

## 1. 系统概述

### 1.1 项目背景

基于 AI+HTML 的动态低代码简历编辑器，支持可视化编辑简历内容、实时预览、多套样式切换、模块拖拽排序等功能。用户无需编写代码即可创建专业简历，同时支持 HTML/CSS 源码编辑满足高级定制需求。

### 1.2 技术栈

| 层级 | 技术 | 版本 | 说明 |
|------|------|------|------|
| 前端框架 | Vue 3 | ^3.4 | Composition API + `<script setup>` |
| 构建工具 | Vite | ^5.0 | 开发服务器端口 3000，API 代理至 8080 |
| UI 组件库 | Element Plus | ^2.5 | 表单、按钮、下拉框、消息提示等 |
| 状态管理 | Pinia | ^2.1 | resume / style 两个 store 模块 |
| 路由 | Vue Router | ^4.3 | History 模式，单页面路由 |
| HTTP 客户端 | Axios | ^1.6 | 统一封装请求/响应拦截器 |
| 拖拽排序 | vuedraggable | ^4.1 | 基于 SortableJS，左侧模块拖拽排序 |
| 后端框架 | Spring Boot | 3.4.0 | Java 21 |
| ORM | MyBatis-Plus | 3.5.9 | BaseMapper + LambdaQueryWrapper |
| 数据库 | MySQL | 8.0 | utf8mb4 字符集，InnoDB 引擎 |
| 构建工具 | Maven | 3.9+ | spring-boot-starter-parent |

### 1.3 系统目标

- 提供所见即所得的简历编辑体验
- 支持多套 CSS 样式模板一键切换
- 支持模块拖拽排序和增删管理
- 支持 HTML/Markdown 双格式导出
- 支持实时 CSS 源码编辑
- 自动保存编辑内容，防止数据丢失

---

## 2. 系统架构设计

### 2.1 整体架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                     前端 (Vue 3 + Vite + Element Plus)               │
├──────────────┬──────────────────┬──────────────┬───────────────────┤
│  TopBar      │  LeftPanel       │  EditPanel   │  PreviewPanel     │
│  简历选择    │  模块列表         │  动态表单     │  HTML 预览        │
│  新建/删除   │  拖拽排序         │  自动保存     │  HTML 源码查看    │
│  导出HTML/MD │  添加/删除模块    │  字段校验     │  CSS 实时编辑     │
│  样式切换    │  模块选中高亮     │  图片上传压缩  │  样式切换         │
├──────────────┴──────────────────┴──────────────┴───────────────────┤
│  Pinia Store                                                        │
│  ├─ resumeStore: currentResume / modules / selectedModuleId         │
│  └─ styleStore:  styles / currentStyle / customConfig               │
├─────────────────────────────────────────────────────────────────────┤
│  API Layer (Axios)                                                  │
│  ├─ request.js: 统一拦截器 (X-User-Id / 响应解包 / 错误处理)        │
│  ├─ resume.js:  简历 CRUD + 导出 + 保存 context                    │
│  ├─ module.js:  模块 CRUD + 排序 + 配置查询                        │
│  └─ style.js:   样式列表 + 切换 + 内容更新                         │
└──────────────────────────────┬──────────────────────────────────────┘
                               │  REST API (JSON)
                               │  Vite Proxy: /api → localhost:8080
┌──────────────────────────────┴──────────────────────────────────────┐
│                    后端 (Spring Boot 3.4 + Java 21)                  │
├──────────────┬──────────────────┬──────────────┬───────────────────┤
│  Controller  │  Service         │  Mapper      │  Config           │
│  ├ Resume    │  ├ ResumeService │  ├ Resume    │  ├ CorsConfig     │
│  ├ Module    │  ├ ModuleService │  ├ Module    │  ├ JacksonConfig  │
│  ├ Style     │  ├ StyleService  │  ├ Style     │  └ MybatisPlus   │
│  ├ Export    │  ├ ExportService │  ├ Config    │     Config        │
│  ├ User      │  └ UserService  │  └ User      │                   │
│  └ Module    │                  │              │                   │
│    Config    │                  │              │                   │
├──────────────┴──────────────────┴──────────────┴───────────────────┤
│  DTO: ResumeWithModulesDTO / BatchSortRequest / ModuleSortItem      │
│  Common: Result<T> (统一响应封装 code/message/data)                  │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                    ┌──────────┴──────────┐
                    │    MySQL 8.0        │
                    │  html_resume 数据库  │
                    └─────────────────────┘
```

### 2.2 分层架构

```
┌───────────────────────────────────────────────────────┐
│                   Controller 层                        │
│  职责: 请求接收、参数提取、权限检查、统一响应封装        │
│  注解: @RestController @RequestMapping                │
│  认证: @RequestHeader("X-User-Id") Long userId        │
├───────────────────────────────────────────────────────┤
│                   Service 层                           │
│  职责: 业务逻辑处理、事务管理、数据组装                  │
│  接口: 继承 IService<T> (MyBatis-Plus)                │
│  实现: 继承 ServiceImpl<Mapper, Entity>               │
│  事务: @Transactional(rollbackFor = Exception.class)  │
├───────────────────────────────────────────────────────┤
│                   Mapper 层                            │
│  职责: 数据库 CRUD 操作、SQL 映射                       │
│  接口: 继承 BaseMapper<T> (MyBatis-Plus)              │
│  XML: 自定义 SQL (selectModulesWithConfig 等)          │
├───────────────────────────────────────────────────────┤
│                   Entity 层                            │
│  职责: 数据库表映射                                     │
│  注解: @TableName @TableId(type=AUTO) @TableField     │
│  工具: Lombok @Data @Builder @NoArgsConstructor       │
└───────────────────────────────────────────────────────┘
```

### 2.3 前端数据流

```
用户操作 → Vue Component → Pinia Action → API Call → 后端 Controller
                                                              │
                                                         Service → Mapper → MySQL
                                                              │
前端更新 ← Pinia State ← API Response ← Result<T> ← ─────────┘

自动保存流程:
用户编辑 → DynamicForm @change → EditPanel debouncedSave (1s) → PUT /modules/{id}/content
```

---

## 3. 数据库设计

### 3.1 ER 关系图

```
┌─────────┐       ┌─────────────┐       ┌─────────────────┐
│  user   │──1:N──│   resume    │──1:N──│ resume_module   │
│         │       │             │       │                 │
│ id (PK) │       │ id (PK)     │       │ id (PK)         │
│device_id│       │ user_id(FK) │       │ resume_id (FK)  │
│         │       │ style_id(FK)│       │ module_type     │
│         │       │ title       │       │ config_id (FK)  │
│         │       │ style_config│       │ content (JSON)  │
│         │       │ context     │       │ sort_order      │
└─────────┘       └──────┬──────┘       └────────┬────────┘
                         │                       │
                         │                       │ config_id
                         │                       ▼
               style_id  │          ┌───────────────────────┐
                         │          │ module_type_config     │
                         ▼          │ (模块字段元数据配置)    │
               ┌─────────────────┐  │                        │
               │    css_style     │  │ config_group + field_key│
               │ (CSS样式模板)     │  │ = 联合唯一键            │
               └─────────────────┘  └───────────────────────┘
```

### 3.2 表结构详细设计

#### 3.2.1 user（用户表）

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| device_id | VARCHAR(64) | NOT NULL, UNIQUE, INDEX | 设备ID（唯一索引） |
| created_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP ON UPDATE | 更新时间 |

**索引**: `idx_device_id (device_id)`

**说明**: 当前采用设备ID识别用户，暂未实现注册登录。`device_id` 为唯一索引，支持快速查找。

#### 3.2.2 css_style（CSS样式模板表）

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| name | VARCHAR(64) | NOT NULL | 样式名称 |
| description | VARCHAR(256) | NULL | 样式描述 |
| thumbnail | VARCHAR(512) | NULL | 缩略图URL |
| css_content | MEDIUMTEXT | NOT NULL | CSS样式内容 |
| is_builtin | TINYINT(1) | DEFAULT 0 | 是否内置样式(0:否 1:是) |
| is_active | TINYINT(1) | DEFAULT 1 | 是否启用(0:禁用 1:启用) |
| created_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP ON UPDATE | 更新时间 |

**索引**: `idx_is_builtin (is_builtin)`

**初始数据**: 3 套内置样式
- id=1: 简约商务（蓝色主色调，Inter 字体，圆角卡片）
- id=2: 创意彩色（紫色渐变，Noto Sans SC 字体，渐变标签）
- id=3: 学术论文（黑白简洁，Times New Roman 字体，A4 纸张尺寸）

#### 3.2.3 resume（简历主表）

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| user_id | BIGINT | NOT NULL, INDEX | 用户ID |
| title | VARCHAR(100) | NOT NULL, DEFAULT '我的简历' | 简历标题 |
| style_id | BIGINT | NULL, INDEX | 样式ID |
| style_config | JSON | NULL | 自定义样式覆盖配置 |
| context | MEDIUMTEXT | NULL | 预览生成的HTML内容（缓存） |
| created_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP ON UPDATE | 更新时间 |

**索引**: `idx_user_id (user_id)`, `idx_style_id (style_id)`

**说明**: `context` 字段缓存前端生成的 HTML 内容，供后端导出使用。`style_config` 为 JSON 类型，存储样式覆盖配置。

#### 3.2.4 module_type_config（模块类型配置表）

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| config_group | VARCHAR(32) | NOT NULL, INDEX | 配置组标识 |
| module_type | VARCHAR(32) | NOT NULL, INDEX | 模块类型 |
| field_key | VARCHAR(64) | NOT NULL | 字段标识 |
| field_name | VARCHAR(64) | NOT NULL | 字段名称 |
| field_type | VARCHAR(32) | NOT NULL, DEFAULT 'text' | 字段类型 |
| layout_type | VARCHAR(32) | NOT NULL, DEFAULT 'block' | HTML布局类型 |
| html_tag | VARCHAR(32) | DEFAULT 'span' | HTML标签 |
| css_class | VARCHAR(128) | NULL | CSS类名 |
| css_style | VARCHAR(512) | NULL | 内联样式 |
| placeholder | VARCHAR(256) | NULL | 占位提示 |
| options | JSON | NULL | 可选项(JSON数组) |
| default_value | VARCHAR(256) | NULL | 默认值 |
| validation | VARCHAR(256) | NULL | 校验规则 |
| is_required | TINYINT(1) | DEFAULT 0 | 是否必填 |
| is_visible | TINYINT(1) | DEFAULT 1 | 是否显示 |
| is_editable | TINYINT(1) | DEFAULT 1 | 是否可编辑 |
| sort_order | INT | DEFAULT 0 | 字段排序 |
| created_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP ON UPDATE | 更新时间 |

**唯一索引**: `uk_config_field (config_group, field_key)`
**索引**: `idx_module_type (module_type)`, `idx_config_group (config_group)`

**field_type 枚举值**:

| 值 | 说明 | 对应前端组件 |
|------|------|------|
| text | 单行文本 | el-input |
| textarea | 多行文本 | el-input type="textarea" |
| date | 日期 | el-date-picker type="month" |
| select | 下拉选择 | el-select + el-option |
| switch | 开关 | el-switch |
| image | 图片上传 | el-input + el-upload |

**layout_type 枚举值**:

| 值 | 说明 | HTML 渲染方式 |
|------|------|------|
| inline | 行内布局 | 同一行内排列 |
| block | 块级布局 | 独占一行 |
| badge | 标签布局 | 圆角标签样式 |
| icon | 图标布局 | 带图标的链接 |
| timeline | 时间线布局 | 时间线头部 |
| split | 分离布局 | 分区显示 |
| list | 列表布局 | 可增删的列表项 |

**初始配置数据**:

| config_group | module_type | 字段数 | 字段列表 |
|------|------|------|------|
| basic_info_default | basic_info | 17 | name, jobIntention, phone, email, wechat, github, blog, leetcode, workYears, targetCity, hometown, summary, salaryRange, expectedEntryDate, isPartyMember, photo, photoBorder |
| education_default | education | 10 | school, department, major, degree, startDate, endDate, is211, is985, isDoubleFirst, schoolLogo |
| work_experience_default | work_experience | 8 | company, position, startDate, endDate, techStack, projectName, projectDescription, responsibilities |
| project_default | project | 8 | projectName, role, startDate, endDate, techStack, description, responsibilities, achievements |
| award_default | award | 1 | categories |

#### 3.2.5 resume_module（简历模块表）

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PK, AUTO_INCREMENT | 主键 |
| resume_id | BIGINT | NOT NULL, INDEX | 简历ID |
| module_type | VARCHAR(32) | NOT NULL | 模块类型 |
| config_id | BIGINT | NULL, INDEX | 模块配置ID |
| content | JSON | NOT NULL | 模块内容(JSON) |
| sort_order | INT | NOT NULL, DEFAULT 0 | 排序序号 |
| created_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL, DEFAULT CURRENT_TIMESTAMP ON UPDATE | 更新时间 |

**索引**: `idx_resume_type (resume_id, module_type)`, `idx_resume_sort (resume_id, sort_order)`, `idx_config_id (config_id)`

**说明**: `content` 字段为 JSON 类型，存储模块的实际内容数据。不同模块类型的 content 结构不同（详见 7.1 节）。`sort_order` 控制模块在简历中的显示顺序。

---

## 4. API 接口设计

### 4.1 接口规范

- **统一前缀**: `/api/v1`
- **请求格式**: `application/json`
- **响应格式**: `Result<T>` 统一封装
  ```json
  {
    "code": 200,
    "message": "success",
    "data": { ... }
  }
  ```
- **认证方式**: 请求头 `X-User-Id` 传递用户ID（当前写死为 1）
- **错误码**: 200=成功, 500=失败

### 4.2 接口详细列表

#### 4.2.1 用户相关

| 接口 | 方法 | 路径 | 请求头 | 说明 |
|------|------|------|------|------|
| 获取当前用户 | GET | `/api/v1/users/me` | X-User-Id | 根据 userId 获取用户信息 |

**请求/响应示例**:

```
GET /api/v1/users/me
Header: X-User-Id: 1

Response:
{
  "code": 200,
  "message": "success",
  "data": {
    "id": 1,
    "deviceId": "xxx",
    "createdAt": "2026-01-01 00:00:00",
    "updatedAt": "2026-01-01 00:00:00"
  }
}
```

#### 4.2.2 简历管理

| 接口 | 方法 | 路径 | 请求头 | 请求体 | 说明 |
|------|------|------|------|------|------|
| 创建简历 | POST | `/api/v1/resumes` | X-User-Id | `{"title": "我的简历"}` | 创建新简历并初始化5个默认模块 |
| 查询简历列表 | GET | `/api/v1/resumes` | X-User-Id | - | 获取用户所有简历，按更新时间倒序 |
| 查询简历详情 | GET | `/api/v1/resumes/{id}` | - | - | 获取简历详情+模块列表+样式信息 |
| 更新简历标题 | PUT | `/api/v1/resumes/{id}/title` | - | `{"title": "新标题"}` | 更新简历标题 |
| 删除简历 | DELETE | `/api/v1/resumes/{id}` | - | - | 删除简历（级联删除模块需手动处理） |
| 切换简历样式 | PUT | `/api/v1/resumes/{id}/style/{styleId}` | - | - | 切换简历的CSS样式模板 |
| 保存自定义样式 | PUT | `/api/v1/resumes/{id}/style-config` | - | `{"styleConfig": {...}}` | 保存自定义样式覆盖配置 |
| 保存预览内容 | PUT | `/api/v1/resumes/{id}/context` | - | `{"context": "<html>..."}` | 保存前端生成的HTML到context字段 |

**创建简历特殊逻辑**:
- 自动设置默认样式（第一个内置样式）
- 自动创建 5 个默认模块: basic_info, education, work_experience, project, award
- 每个模块的 sort_order 为 1~5
- 模块创建失败时静默忽略（不影响简历创建）

**简历详情响应结构**:
```json
{
  "code": 200,
  "data": {
    "resume": { "id": 1, "userId": 1, "title": "我的简历", "styleId": 1, ... },
    "modules": [
      { "id": 1, "resumeId": 1, "moduleType": "basic_info", "content": "{...}", "sortOrder": 1, ... },
      ...
    ],
    "style": { "id": 1, "name": "简约商务", "cssContent": "...", ... }
  }
}
```

#### 4.2.3 模块管理

| 接口 | 方法 | 路径 | 请求体 | 说明 |
|------|------|------|------|------|
| 获取模块配置 | GET | `/api/v1/module-config/{moduleType}` | - | 获取指定模块类型的字段配置列表 |
| 添加模块 | POST | `/api/v1/modules` | `{"resume_id": 1, "module_type": "education", "content": {}, "sort_order": 3}` | 添加简历模块 |
| 更新模块内容 | PUT | `/api/v1/modules/{id}/content` | `{"content": {"school": "郑州大学", ...}}` | 更新模块内容JSON |
| 删除模块 | DELETE | `/api/v1/modules/{id}` | - | 删除指定模块 |
| 批量调整排序 | PUT | `/api/v1/modules/sort` | `{"resume_id": 1, "modules": [{"id": 1, "sortOrder": 1}, ...]}` | 批量更新模块排序 |

**添加模块特殊逻辑**:
- 自动查找 module_type_config 获取 configId
- sort_order 未指定时，自动取当前最大值 +1
- content 序列化为 JSON 字符串存储

**批量排序请求结构**:
```json
{
  "resume_id": 1,
  "modules": [
    { "id": 1, "sortOrder": 1 },
    { "id": 2, "sortOrder": 2 },
    { "id": 3, "sortOrder": 3 }
  ]
}
```

**模块配置查询**: 使用 `likeRight` 模糊匹配 moduleType，按 sort_order 升序排列。

#### 4.2.4 样式管理

| 接口 | 方法 | 路径 | 请求体 | 说明 |
|------|------|------|------|------|
| 查询样式列表 | GET | `/api/v1/styles` | - | 获取所有启用样式，按创建时间倒序 |
| 查询样式详情 | GET | `/api/v1/styles/{id}` | - | 获取样式详细内容 |
| 更新样式内容 | PUT | `/api/v1/styles/{id}/content` | `{"cssContent": "..."}` | 更新CSS样式内容 |

#### 4.2.5 导出

| 接口 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 导出HTML | GET | `/api/v1/resumes/{id}/export/html` | 导出完整HTML文件，Content-Disposition: attachment |

**导出逻辑**:
1. 查询 resume 记录
2. 若 context 字段有值，直接返回缓存的 HTML
3. 若 context 为空，返回默认占位 HTML
4. 响应头设置 `Content-Disposition: attachment; filename=resume.html`

---

## 5. 前端组件设计

### 5.1 组件结构

```
src/
├── main.js                          # 应用入口，注册 Pinia/Router/ElementPlus
├── App.vue                          # 根组件，仅包含 <router-view />
├── router/
│   └── index.js                     # 路由配置，/ → /editor (懒加载)
├── api/
│   ├── request.js                   # Axios 封装，统一拦截器
│   ├── resume.js                    # 简历 API: CRUD + 导出 + 保存context
│   ├── module.js                    # 模块 API: CRUD + 排序 + 配置查询
│   └── style.js                     # 样式 API: 列表 + 切换 + 内容更新
├── store/
│   ├── index.js                     # Pinia 实例创建
│   └── modules/
│       ├── resume.js                # 简历状态管理
│       └── style.js                 # 样式状态管理
├── views/
│   └── Editor.vue                   # 编辑器主页面（三栏布局 + 可拖拽分隔条）
├── components/
│   └── editor/
│       ├── TopBar.vue               # 顶部工具栏
│       ├── LeftPanel.vue            # 左侧模块面板
│       ├── EditPanel.vue            # 中间编辑面板
│       ├── DynamicForm.vue          # 动态表单渲染
│       └── PreviewPanel.vue         # 右侧预览面板
├── utils/
│   ├── deviceId.js                  # 设备ID/用户ID生成（当前写死为1）
│   ├── htmlGenerator.js             # HTML 生成器（各模块模板函数）
│   └── markdownGenerator.js         # Markdown 生成器
└── styles/
    └── main.css                     # 全局样式（CSS 变量 + Element Plus 覆盖）
```

### 5.2 核心组件详细设计

#### 5.2.1 Editor.vue（编辑器主页面）

**布局结构**: 顶部工具栏 + 三栏主内容区（左/中/右），栏间有可拖拽分隔条。

**核心功能**:
- 三栏布局: 左面板(16%) + 编辑面板(flex:1) + 预览面板(35%)
- 可拖拽分隔条: 鼠标拖拽调整左右面板宽度，范围 10%~80%
- 折叠按钮: 左右面板可独立折叠/展开
- 拖拽遮罩: 拖拽时显示全屏透明遮罩，防止 iframe 捕获事件

**状态管理**:
```javascript
leftPct = 16          // 左面板宽度百分比
rightPct = 35         // 右面板宽度百分比
leftCollapsed = false // 左面板折叠状态
rightCollapsed = false// 右面板折叠状态
isDragging = false    // 是否正在拖拽
```

**生命周期**:
- `onMounted`: 初始化简历数据 + 加载样式列表
- `onUnmounted`: 清理鼠标事件监听器

#### 5.2.2 TopBar.vue（顶部工具栏）

**功能模块**:

| 区域 | 功能 | 实现方式 |
|------|------|------|
| 左侧 | 简历选择器 | el-select，支持删除按钮 |
| 左侧 | 简历标题编辑 | el-input，blur/enter 保存 |
| 左侧 | 新建简历 | el-button → createResume API |
| 左侧 | 导出下拉菜单 | el-dropdown → HTML/Markdown |
| 右侧 | 样式切换 | el-select → switchStyle API |

**导出功能**:
- HTML 导出: 调用后端 `/export/html`，创建 Blob 下载
- Markdown 导出: 前端 `markdownGenerator.js` 生成，创建 Blob 下载

**删除简历逻辑**:
1. ElMessageBox 二次确认
2. 调用删除 API
3. 若删除的是当前简历，自动切换到列表第一个或新建

#### 5.2.3 LeftPanel.vue（左侧模块面板）

**功能**:
- 模块列表展示（vuedraggable 拖拽排序）
- 模块选中高亮
- 模块添加（el-dropdown 下拉选择模块类型）
- 模块删除（二次确认）
- 模块显示名称: 基本信息显示类型名，其他模块显示"类型 - 关键字段值"

**模块类型映射**:
```javascript
moduleTypes = [
  { value: 'basic_info', label: '基本信息' },
  { value: 'education', label: '教育经历' },
  { value: 'work_experience', label: '工作经历' },
  { value: 'project', label: '项目经历' },
  { value: 'award', label: '荣誉证书' }
]
```

**显示名称映射**:
```javascript
displayFieldMap = {
  education: 'school',
  work_experience: 'company',
  project: 'projectName'
}
// 示例: "教育经历 - 郑州大学", "工作经历 - 蚂蚁集团"
```

**拖拽排序流程**:
1. vuedraggable `@end` 事件触发
2. 遍历模块列表生成 `[{id, sortOrder}]` 数组
3. 调用 `batchUpdateSort` API
4. 更新本地 sortOrder 值

#### 5.2.4 EditPanel.vue（中间编辑面板）

**功能**:
- 显示当前选中模块的编辑表单
- 自动保存（debounce 1秒）
- 保存状态显示（"保存中..." / "已保存 HH:MM:SS"）
- 空状态提示

**数据流**:
1. 监听 `selectedModule` 变化
2. 解析模块 content JSON → formData
3. 调用 `getModuleConfig` API 获取字段配置 → fieldConfigs
4. 将 fieldConfigs 传递给 DynamicForm 渲染
5. DynamicForm `@update` 事件触发 → debounce 1s → `updateModuleContent` API
6. 更新 resumeStore 中的模块数据

#### 5.2.5 DynamicForm.vue（动态表单渲染）

**功能**: 根据 `module_type_config` 配置动态渲染表单字段。

**字段类型渲染映射**:

| field_type | 渲染组件 | 特殊处理 |
|------|------|------|
| text | el-input | 单行文本输入 |
| textarea | el-input type="textarea" | 多行文本，4行高度 |
| date | el-date-picker type="month" | value-format="YYYY-MM" |
| select | el-select + el-option | options 从配置解析 |
| switch | el-switch | 布尔值切换 |
| image | el-input + el-upload | 图片URL输入 + 文件上传 |

**列表字段（layoutType === 'list'）**:
- 渲染为可增删的 textarea 列表
- 每项有"删除"按钮
- 底部有"添加"按钮

**图片上传处理**:
- 最大文件大小: 2MB
- 压缩阈值: 500KB
- 压缩参数: 最大宽度 800px，最大高度 1000px，质量 0.8
- 超过阈值的图片使用 Canvas 压缩
- 图片转为 Base64 存储

#### 5.2.6 PreviewPanel.vue（右侧预览面板）

**三个标签页**:

| 标签 | 功能 | 实现 |
|------|------|------|
| HTML预览 | 实时预览简历 | iframe + doc.write() |
| HTML源码 | 查看/复制 HTML 源码 | computed + navigator.clipboard |
| CSS编辑 | 实时编辑 CSS 样式 | el-input textarea + debounce 保存 |

**预览更新机制**:
- 监听 `htmlPreview` computed 变化 → 更新 iframe 内容
- 监听 `activeTab` 变化 → 切换到预览标签时更新

**HTML 缓存保存**:
- 监听 htmlPreview 变化 → debounce 2s → 调用 `saveContext` API
- 将前端生成的 HTML 保存到 resume.context 字段

**CSS 编辑保存**:
- 监听 cssContent 变化 → debounce 1s
- 更新 styleStore.currentStyle.cssContent
- 更新 iframe 预览
- 调用 `updateStyleContent` API 保存到数据库

### 5.3 Pinia Store 设计

#### 5.3.1 resumeStore

**State**:
```javascript
{
  currentResume: null,     // 当前简历对象
  modules: [],             // 当前简历的模块列表
  moduleConfigs: [],       // 模块配置列表
  selectedModuleId: null,  // 当前选中模块ID
  resumeList: []           // 用户简历列表
}
```

**Actions**:

| Action | 说明 |
|------|------|
| initOrRestore | 初始化: 加载简历列表 → 恢复上次简历或新建 |
| loadResume(id) | 加载简历详情+模块+样式 |
| loadResumeList | 加载简历列表 |
| switchResume(id) | 切换简历 |
| autoSelectFirstModule | 自动选中第一个模块 |
| addModule(module) | 添加模块到列表 |
| updateModule(id, updates) | 更新模块数据 |
| deleteModule(id) | 删除模块 |
| reorderModules({oldIndex, newIndex}) | 重排模块顺序 |

**Getters**:

| Getter | 说明 |
|------|------|
| selectedModule | 根据 selectedModuleId 查找当前选中模块 |

**持久化**: `localStorage.setItem('resume_id', id)` 保存当前简历ID。

#### 5.3.2 styleStore

**State**:
```javascript
{
  styles: [],          // 所有可用样式列表
  currentStyle: null,  // 当前使用的样式
  customConfig: {}     // 自定义样式配置
}
```

**Actions**:

| Action | 说明 |
|------|------|
| loadStyles | 加载样式列表，自动匹配当前简历的 styleId |
| switchStyle(resumeId, styleId) | 切换简历样式 |

### 5.4 API 封装设计

#### 5.4.1 request.js（Axios 封装）

**配置**:
- baseURL: `/api/v1`
- timeout: 10000ms

**请求拦截器**:
- 注入 `X-User-Id` 请求头（当前写死为 1）

**响应拦截器**:
- responseType 为 text/blob 时直接返回 data
- 正常响应: 解包 `result.data`（提取 Result<T> 中的 data 字段）
- 错误响应: 按 HTTP 状态码分类处理（400/401/403/404/500）

#### 5.4.2 API 函数列表

**resume.js**:

| 函数 | 方法 | 路径 | 说明 |
|------|------|------|------|
| createResume(data) | POST | /resumes | 创建简历 |
| listResumes() | GET | /resumes | 简历列表 |
| getResume(id) | GET | /resumes/{id} | 简历详情 |
| updateResumeTitle(id, title) | PUT | /resumes/{id}/title | 更新标题 |
| deleteResume(id) | DELETE | /resumes/{id} | 删除简历 |
| exportHtml(id) | GET | /resumes/{id}/export/html | 导出HTML |
| exportJson(id) | GET | /resumes/{id} | 导出JSON |
| saveContext(id, context) | PUT | /resumes/{id}/context | 保存预览HTML |

**module.js**:

| 函数 | 方法 | 路径 | 说明 |
|------|------|------|------|
| addModule(data) | POST | /modules | 添加模块 |
| updateModuleContent(id, content) | PUT | /modules/{id}/content | 更新模块内容 |
| deleteModule(id) | DELETE | /modules/{id} | 删除模块 |
| batchUpdateSort(resumeId, modules) | PUT | /modules/sort | 批量排序 |
| getModuleConfig(moduleType) | GET | /module-config/{moduleType} | 获取模块配置 |

**style.js**:

| 函数 | 方法 | 路径 | 说明 |
|------|------|------|------|
| listStyles() | GET | /styles | 样式列表 |
| getStyle(id) | GET | /styles/{id} | 样式详情 |
| switchStyle(resumeId, styleId) | PUT | /resumes/{resumeId}/style/{styleId} | 切换样式 |
| saveStyleConfig(id, config) | PUT | /resumes/{id}/style-config | 保存样式配置 |
| updateStyleContent(id, cssContent) | PUT | /styles/{id}/content | 更新CSS内容 |

---

## 6. 后端详细设计

### 6.1 项目结构

```
backend/
├── pom.xml
└── src/main/
    ├── java/com/htmlresume/
    │   ├── HtmlResumeApplication.java      # 启动类，@MapperScan("com.htmlresume.mapper")
    │   ├── common/
    │   │   └── Result.java                 # 统一响应封装
    │   ├── config/
    │   │   ├── CorsConfig.java             # CORS 跨域配置
    │   │   ├── JacksonConfig.java          # Jackson 序列化配置
    │   │   └── MybatisPlusConfig.java      # MyBatis-Plus 配置（待完善）
    │   ├── controller/
    │   │   ├── UserController.java         # 用户接口
    │   │   ├── ResumeController.java       # 简历接口
    │   │   ├── ModuleController.java       # 模块接口
    │   │   ├── ModuleConfigController.java # 模块配置接口
    │   │   ├── StyleController.java        # 样式接口
    │   │   └── ExportController.java       # 导出接口
    │   ├── dto/
    │   │   ├── ResumeWithModulesDTO.java   # 简历详情DTO
    │   │   ├── BatchSortRequest.java       # 批量排序请求DTO
    │   │   └── ModuleSortItem.java         # 排序项DTO
    │   ├── entity/
    │   │   ├── User.java                   # 用户实体
    │   │   ├── Resume.java                 # 简历实体
    │   │   ├── ResumeModule.java           # 简历模块实体
    │   │   ├── CssStyle.java               # CSS样式实体
    │   │   └── ModuleTypeConfig.java       # 模块类型配置实体
    │   ├── mapper/
    │   │   ├── UserMapper.java             # 用户Mapper
    │   │   ├── ResumeMapper.java           # 简历Mapper
    │   │   ├── ResumeModuleMapper.java     # 模块Mapper（含自定义SQL）
    │   │   ├── CssStyleMapper.java         # 样式Mapper
    │   │   └── ModuleTypeConfigMapper.java # 配置Mapper
    │   └── service/
    │       ├── UserService.java            # 用户服务接口
    │       ├── ResumeService.java          # 简历服务接口
    │       ├── ModuleService.java          # 模块服务接口
    │       ├── StyleService.java           # 样式服务接口
    │       ├── ExportService.java          # 导出服务接口
    │       └── impl/
    │           ├── UserServiceImpl.java    # 用户服务实现
    │           ├── ResumeServiceImpl.java  # 简历服务实现
    │           ├── ModuleServiceImpl.java  # 模块服务实现
    │           ├── StyleServiceImpl.java   # 样式服务实现
    │           └── ExportServiceImpl.java  # 导出服务实现
    └── resources/
        ├── application.yml                 # 应用配置
        └── mapper/
            ├── ResumeMapper.xml            # 简历SQL映射（空）
            └── ResumeModuleMapper.xml      # 模块SQL映射（含自定义查询）
```

### 6.2 配置类详细设计

#### 6.2.1 CorsConfig

```java
// 允许所有来源、所有方法、所有请求头
config.addAllowedOriginPattern("*");
config.setAllowCredentials(true);
config.addAllowedMethod("*");
config.addAllowedHeader("*");
config.setMaxAge(3600L);
// 注册到所有路径 /**
```

#### 6.2.2 JacksonConfig

```java
// 注册 JSR310 时间模块
objectMapper.registerModule(new JavaTimeModule());
// 禁用时间戳序列化（使用 ISO-8601 格式）
objectMapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
```

#### 6.2.3 MybatisPlusConfig

当前为空配置，待添加分页拦截器（PaginationInnerInterceptor 在 3.5.9 版本暂不可用）。

### 6.3 Service 层详细设计

#### 6.3.1 ResumeServiceImpl

| 方法 | 事务 | 说明 |
|------|------|------|
| createResume(userId, title) | @Transactional | 创建简历+初始化5个默认模块 |
| getResumeWithModules(resumeId) | 无 | 查询简历+模块列表+样式信息 |
| listByUserId(userId) | 无 | 按更新时间倒序查询用户简历 |
| switchStyle(resumeId, newStyleId) | @Transactional | 切换简历样式，校验样式存在性 |

**createResume 核心逻辑**:
1. 获取默认样式（第一个内置样式）
2. 创建 Resume 记录（styleConfig 初始化为 "{}"）
3. 循环创建 5 个默认模块（sort_order 1~5）
4. 模块创建失败时静默忽略

#### 6.3.2 ModuleServiceImpl

| 方法 | 事务 | 说明 |
|------|------|------|
| addModule(resumeId, moduleType, content, sortOrder) | @Transactional | 添加模块，自动查找configId和sortOrder |
| updateModuleContent(moduleId, content) | @Transactional | 更新模块content JSON |
| deleteModule(moduleId) | @Transactional | 删除模块 |
| batchUpdateSort(resumeId, modules) | @Transactional | 批量更新排序（逐条更新） |
| getModulesWithConfig(resumeId) | 无 | 联表查询模块+配置信息 |

**addModule 核心逻辑**:
1. 根据 moduleType 查找 ModuleTypeConfig 获取 configId
2. 序列化 content 为 JSON 字符串
3. sortOrder 未指定时，查询当前最大 sortOrder + 1
4. 构建 ResumeModule 并保存

#### 6.3.3 StyleServiceImpl

| 方法 | 说明 |
|------|------|
| listActiveStyles() | 查询所有启用样式，按创建时间倒序 |
| listBuiltinStyles() | 查询所有内置+启用样式 |
| getStyleById(styleId) | 根据ID获取样式 |
| getDefaultStyle() | 获取第一个内置+启用样式 |
| updateStyleContent(id, cssContent) | 更新CSS内容 |

#### 6.3.4 ExportServiceImpl

**exportHtml 核心逻辑**:
1. 查询 Resume 记录
2. 若 context 字段有值，直接返回
3. 若 context 为空，返回占位 HTML
4. HTML 标题进行 XSS 转义

#### 6.3.5 UserServiceImpl

| 方法 | 说明 |
|------|------|
| initOrCreateUser(deviceId) | 根据 deviceId 查找用户，不存在则创建 |
| getByDeviceId(deviceId) | 根据 deviceId 查找用户 |

### 6.4 Mapper XML 详细设计

#### 6.4.1 ResumeModuleMapper.xml

**selectModulesWithConfig**: 联表查询模块+配置信息

```sql
SELECT rm.*, mtc.config_group, mtc.field_key, mtc.field_name,
       mtc.field_type, mtc.layout_type, mtc.html_tag, mtc.css_class,
       mtc.css_style, mtc.placeholder, mtc.options, mtc.default_value,
       mtc.validation, mtc.is_required, mtc.is_visible, mtc.is_editable
FROM resume_module rm
LEFT JOIN module_type_config mtc ON rm.config_id = mtc.id
WHERE rm.resume_id = #{resumeId}
ORDER BY rm.sort_order ASC
```

**batchUpdateSortOrder**: 批量更新排序

```sql
UPDATE resume_module SET sort_order = #{item.sortOrder}, updated_at = NOW()
WHERE id = #{item.id}
-- 使用 foreach 循环执行多条 UPDATE
```

---

## 7. 核心业务流程

### 7.1 初始化流程

```
用户打开页面
    │
    ▼
Editor.vue onMounted
    │
    ├── resumeStore.initOrRestore()
    │       │
    │       ├── loadResumeList() → GET /resumes
    │       │
    │       ├── localStorage 有 resume_id?
    │       │   ├── 是 → loadResume(id) → GET /resumes/{id}
    │       │   │         成功 → autoSelectFirstModule()
    │       │   │         失败 → 清除 localStorage，创建新简历
    │       │   │
    │       │   └── 否 → createResume() → POST /resumes
    │       │             → loadResume(id) → autoSelectFirstModule()
    │
    └── styleStore.loadStyles() → GET /styles
            → 匹配 currentResume.styleId 或取第一个
```

### 7.2 模块编辑自动保存流程

```
用户在 DynamicForm 修改字段
    │
    ▼
@change 事件 → emitUpdate()
    │
    ▼
EditPanel.handleFormUpdate(newData)
    │
    ▼
debouncedSave() → setTimeout(1000ms)
    │
    ▼ (1秒后无新操作)
saveData()
    │
    ├── PUT /modules/{id}/content { content: {...} }
    │
    ├── 成功 → resumeStore.updateModule() → 更新 lastSaved 时间
    │
    └── 失败 → ElMessage.error('保存失败')
```

### 7.3 模块拖拽排序流程

```
用户在 LeftPanel 拖拽模块
    │
    ▼
vuedraggable @end 事件
    │
    ▼
生成 sortedModules = [{id, sortOrder}, ...]
    │
    ▼
PUT /modules/sort { resume_id, modules: [...] }
    │
    ▼
ModuleServiceImpl.batchUpdateSort()
    │
    ├── 遍历 modules 列表
    │   ├── 查找 Module 记录
    │   ├── 校验 resumeId 匹配
    │   └── 更新 sortOrder + updatedAt
    │
    ▼
前端更新本地 sortOrder → ElMessage.success('排序已保存')
```

### 7.4 HTML 生成与预览流程

```
resumeStore.modules / styleStore.currentStyle 变化
    │
    ▼
htmlPreview computed 重新计算
    │
    ▼
htmlGenerator.generateHtml(resume, modules, style)
    │
    ├── 遍历 modules，按 moduleType 分发:
    │   ├── basic_info → generateBasicInfo() → <header>
    │   ├── education → generateEducation() → <div class="section">
    │   ├── work_experience → generateWorkExperience() → <div class="section">
    │   ├── project → generateProject() → <div class="section">
    │   └── award → generateAward() → <div class="section">
    │
    ├── 拼接完整 HTML:
    │   <!DOCTYPE html>
    │   <html><head><style>{cssContent}</style></head>
    │   <body><div class="resume">{header}{sections}</div></body></html>
    │
    ▼
PreviewPanel 监听 htmlPreview 变化
    │
    ├── activeTab === 'preview' → iframe.doc.write(html)
    │
    └── saveContextDebounced() → setTimeout(2000ms)
        → PUT /resumes/{id}/context { context: html }
```

### 7.5 样式切换流程

```
用户在 TopBar 选择新样式
    │
    ▼
handleStyleChange(styleId)
    │
    ▼
styleStore.switchStyle(resumeId, styleId)
    │
    ├── PUT /resumes/{resumeId}/style/{styleId}
    │
    ├── ResumeServiceImpl.switchStyle()
    │   ├── 校验 Resume 存在
    │   ├── 校验 Style 存在
    │   └── 更新 resume.styleId
    │
    └── 更新 styleStore.currentStyle → 触发 htmlPreview 重算 → iframe 更新
```

### 7.6 CSS 实时编辑流程

```
用户在 PreviewPanel CSS编辑标签页修改 CSS
    │
    ▼
onCssChange() → debounce 1s
    │
    ▼ (1秒后无新操作)
    ├── 更新 styleStore.currentStyle.cssContent
    ├── updatePreview() → iframe 刷新
    └── saveCssToDb()
        → PUT /styles/{id}/content { cssContent: "..." }
        → 成功: cssSaveStatus = '已保存'
        → 失败: cssSaveStatus = '保存失败'
```

### 7.7 导出流程

**HTML 导出**:
```
TopBar → handleExportHtml()
    │
    ├── GET /resumes/{id}/export/html (responseType: 'text')
    │
    ├── ExportServiceImpl.exportHtml()
    │   ├── resume.context 有值 → 直接返回
    │   └── resume.context 为空 → 返回占位 HTML
    │
    └── 前端创建 Blob → URL.createObjectURL → <a>.click() 下载
```

**Markdown 导出**:
```
TopBar → handleExportMarkdown()
    │
    ├── markdownGenerator.generateMarkdown(resume, modules)
    │   ├── basic_info → 姓名 + 联系方式 + 个人总结
    │   ├── education → 学校 + 专业 + 学历 + 日期 + 标签
    │   ├── work_experience → 公司 + 职位 + 技术栈 + 职责列表
    │   ├── project → 项目名 + 角色 + 技术栈 + 描述 + 成果
    │   └── award → 证书标签列表
    │
    └── 前端创建 Blob → URL.createObjectURL → <a>.click() 下载
```

---

## 8. 关键数据结构

### 8.1 简历完整数据模型

```json
{
  "resume": {
    "id": 1,
    "userId": 1,
    "title": "我的简历",
    "styleId": 1,
    "styleConfig": "{}",
    "context": "<!DOCTYPE html>...",
    "createdAt": "2026-01-01 00:00:00",
    "updatedAt": "2026-05-24 10:00:00"
  },
  "modules": [
    {
      "id": 1,
      "resumeId": 1,
      "moduleType": "basic_info",
      "configId": null,
      "content": "{\"name\":\"张三\",\"jobIntention\":\"Java开发\",\"phone\":\"13800138000\",\"email\":\"zhangsan@example.com\",\"wechat\":\"zhangsan_wx\",\"github\":\"https://github.com/zhangsan\",\"blog\":\"\",\"leetcode\":\"\",\"workYears\":\"5年\",\"targetCity\":\"上海\",\"hometown\":\"\",\"summary\":\"5年Java开发经验\",\"salaryRange\":\"15-25K\",\"expectedEntryDate\":\"\",\"isPartyMember\":false,\"photo\":\"\",\"photoBorder\":false}",
      "sortOrder": 1,
      "createdAt": "...",
      "updatedAt": "..."
    },
    {
      "id": 2,
      "resumeId": 1,
      "moduleType": "education",
      "configId": null,
      "content": "{\"school\":\"郑州大学\",\"department\":\"计算机\",\"major\":\"计算机科学与技术\",\"degree\":\"硕士\",\"startDate\":\"2024-09\",\"endDate\":\"2027-06\",\"is211\":true,\"is985\":false,\"isDoubleFirst\":false,\"schoolLogo\":\"\"}",
      "sortOrder": 2,
      "createdAt": "...",
      "updatedAt": "..."
    },
    {
      "id": 3,
      "resumeId": 1,
      "moduleType": "work_experience",
      "configId": null,
      "content": "{\"company\":\"蚂蚁集团\",\"position\":\"后端开发\",\"startDate\":\"2024-03\",\"endDate\":\"\",\"techStack\":\"Spring Cloud, Redis\",\"projectName\":\"PmHub\",\"projectDescription\":\"智能项目管理系统\",\"responsibilities\":[\"职责1\",\"职责2\"]}",
      "sortOrder": 3,
      "createdAt": "...",
      "updatedAt": "..."
    },
    {
      "id": 4,
      "resumeId": 1,
      "moduleType": "project",
      "configId": null,
      "content": "{\"projectName\":\"派聪明 RAG 知识库\",\"role\":\"AI应用开发\",\"startDate\":\"2026-01\",\"endDate\":\"2026-02\",\"techStack\":\"SpringBoot, MySQL, Redis\",\"description\":\"企业级智能对话平台\",\"responsibilities\":[\"工作内容1\"],\"achievements\":[\"成果1\"]}",
      "sortOrder": 4,
      "createdAt": "...",
      "updatedAt": "..."
    },
    {
      "id": 5,
      "resumeId": 1,
      "moduleType": "award",
      "configId": null,
      "content": "{\"categories\":[\"英语六级\",\"FLMI寿险管理师\"]}",
      "sortOrder": 5,
      "createdAt": "...",
      "updatedAt": "..."
    }
  ],
  "style": {
    "id": 1,
    "name": "简约商务",
    "description": "蓝色主色调，适合正式场合",
    "thumbnail": "/styles/business.png",
    "cssContent": ":root { --primary: #255deb; ... }",
    "isBuiltin": true,
    "isActive": true
  }
}
```

### 8.2 模块 content JSON 结构

#### basic_info（基本信息）

```json
{
  "name": "姓名",
  "jobIntention": "求职意向",
  "phone": "电话",
  "email": "邮箱",
  "wechat": "微信号",
  "github": "GitHub链接",
  "blog": "博客链接",
  "leetcode": "LeetCode主页",
  "workYears": "工作年限",
  "targetCity": "期望城市",
  "hometown": "籍贯",
  "summary": "个人总结",
  "salaryRange": "期望薪资",
  "expectedEntryDate": "到岗时间(YYYY-MM)",
  "isPartyMember": false,
  "photo": "base64或URL",
  "photoBorder": false
}
```

#### education（教育经历）

```json
{
  "school": "学校名称",
  "department": "院系",
  "major": "专业",
  "degree": "博士/硕士/本科/大专",
  "startDate": "YYYY-MM",
  "endDate": "YYYY-MM",
  "is211": true,
  "is985": false,
  "isDoubleFirst": false,
  "schoolLogo": "base64或URL"
}
```

#### work_experience（工作经历）

```json
{
  "company": "公司名称",
  "position": "职位",
  "startDate": "YYYY-MM",
  "endDate": "YYYY-MM（空=至今）",
  "techStack": "技术栈描述",
  "projectName": "项目名称",
  "projectDescription": "项目描述",
  "responsibilities": ["职责1", "职责2"]
}
```

#### project（项目经历）

```json
{
  "projectName": "项目名称",
  "role": "担任角色",
  "startDate": "YYYY-MM",
  "endDate": "YYYY-MM",
  "techStack": "技术栈描述",
  "description": "项目描述",
  "responsibilities": ["工作内容1"],
  "achievements": ["项目成果1"]
}
```

#### award（荣誉证书）

```json
{
  "categories": ["证书1", "证书2"]
}
```

### 8.3 Result 统一响应结构

```java
public class Result<T> {
    private Integer code;     // 200=成功, 500=失败
    private String message;   // "success" 或错误信息
    private T data;           // 业务数据

    public static <T> Result<T> success(T data);
    public static <T> Result<T> success();
    public static <T> Result<T> error(String message);
}
```

### 8.4 DTO 结构

#### ResumeWithModulesDTO

```java
public class ResumeWithModulesDTO {
    private Resume resume;           // 简历主数据
    private List<ResumeModule> modules; // 模块列表（按sortOrder排序）
    private CssStyle style;          // 当前样式
}
```

#### BatchSortRequest

```java
public class BatchSortRequest {
    private Long resume_id;                  // 简历ID
    private List<ModuleSortItem> modules;    // 排序项列表
}
```

#### ModuleSortItem

```java
public class ModuleSortItem {
    private Long id;           // 模块ID
    private Integer sortOrder; // 排序序号
}
```

---

## 9. HTML 生成器详细设计

### 9.1 整体结构

```
generateHtml(resumeData, modules, cssStyle)
    │
    ├── 提取 cssContent
    ├── 遍历 modules，按 moduleType 分发:
    │   ├── basic_info → generateBasicInfo() → <header>
    │   ├── education → generateEducation() → <div class="section">
    │   ├── work_experience → generateWorkExperience() → <div class="section">
    │   ├── project → generateProject() → <div class="section">
    │   └── award → generateAward() → <div class="section">
    │
    └── 拼接完整 HTML 文档
```

### 9.2 各模块 HTML 模板

#### basic_info → `<header>`

```html
<header>
  <img class="avatar" src="{photo}" alt="照片" />
  <div class="header-content">
    <h1 class="name">{name}</h1>
    <p class="job-intention">{jobIntention}</p>
    <div class="contact-info">
      <span>📱 {phone}</span>
      <span>✉️ {email}</span>
      <span>💬 {wechat}</span>
      <span>💼 {workYears}</span>
      <span>📍 {targetCity}</span>
      <span>🌐 {github}</span>
    </div>
    <p class="summary">{summary}</p>
  </div>
</header>
```

#### education → `<div class="section">`

```html
<div class="section">
  <h2 class="section-title">教育经历</h2>
  <div class="timeline-item">
    <img class="school-logo" src="{schoolLogo}" />
    <div class="timeline-header">
      <span class="school">{school}</span>
      <span class="date">{startDate} ~ {endDate}</span>
    </div>
    <div>
      <span class="department">{department}</span>
      <span class="major">{major}</span>
      · <span class="degree">{degree}</span>
    </div>
    <div style="margin-top:0.5rem;">
      <span class="certificate-tag">211</span>
      <span class="certificate-tag">985</span>
      <span class="certificate-tag">双一流</span>
    </div>
  </div>
</div>
```

#### work_experience → `<div class="section">`

```html
<div class="section">
  <h2 class="section-title">工作经历</h2>
  <div class="timeline-item">
    <div class="timeline-header">
      <span class="company">{company}</span>
      <span class="date">{startDate} ~ {endDate|至今}</span>
    </div>
    <span class="position">{position}</span>
    <p>技术栈：{techStack}</p>
    <ul class="description">
      <li>{responsibility}</li>
    </ul>
    <div class="project">
      <div class="project-title">{projectName}</div>
      <p class="description">{projectDescription}</p>
    </div>
  </div>
</div>
```

#### project → `<div class="section">`

```html
<div class="section">
  <h2 class="section-title">项目经历</h2>
  <div class="project">
    <div class="timeline-header">
      <span class="project-title">{projectName}</span>
      <span class="date">{startDate} ~ {endDate|至今}</span>
    </div>
    <div class="company">{role}</div>
    <p>技术栈：{techStack}</p>
    <div class="description">
      <p><strong>项目描述</strong>：{description}</p>
    </div>
    <div class="description">
      <p><strong>工作内容</strong></p>
      <ul><li>{responsibility}</li></ul>
    </div>
    <div class="description">
      <p><strong>项目成果</strong></p>
      <ul><li>{achievement}</li></ul>
    </div>
  </div>
</div>
```

#### award → `<div class="section">`

```html
<div class="section">
  <h2 class="section-title">荣誉证书</h2>
  <div class="certificates">
    <span class="certificate-tag">{item}</span>
  </div>
</div>
```

### 9.3 特殊处理

- **Markdown 粗体**: `**text**` → `<b>text</b>`（boldMarkdown 函数）
- **XSS 转义**: escapeHtml 函数转义 `& < > " '` 字符
- **重复模块标题**: 同类型多模块时，仅第一个显示 section-title
- **空值过滤**: 所有字段为空时不渲染对应 HTML 元素
- **日期格式**: endDate 为空时显示"至今"

---

## 10. CSS 样式模板设计

### 10.1 三套内置样式对比

| 特性 | 简约商务 (id=1) | 创意彩色 (id=2) | 学术论文 (id=3) |
|------|------|------|------|
| 主色调 | #255deb (蓝) | #7c3aed→#ec4899 (紫→粉渐变) | #000000 (黑) |
| 字体 | Inter | Noto Sans SC | Times New Roman + Noto Serif SC |
| 背景 | #fafafa 纯色 | 渐变背景 | #ffffff 纯白 |
| 卡片圆角 | 12px | 20px | 无 |
| 头部样式 | 蓝色渐变背景 | 紫粉渐变背景 | 居中文字 + 底部边框 |
| 日期标签 | 蓝色圆角标签 | 渐变圆角标签 | 灰色文字 |
| 证书标签 | 蓝色圆角标签 | 渐变圆角标签 | 灰色边框标签 |
| 响应式 | 768px 断点 | 无 | 768px 断点 |
| 纸张尺寸 | max-width: 960px | max-width: 960px | max-width: 210mm (A4) |

### 10.2 CSS 变量体系

每套样式都定义了 CSS 变量，方便统一修改:

```css
:root {
    --primary: 主色;
    --primary-light: 主色浅色;
    --dark: 深色文字;
    --gray: 灰色文字;
    --light-gray: 浅灰背景;
    --white: 白色;
    --border: 边框色;
}
```

### 10.3 通用 CSS 类名

| 类名 | 用途 |
|------|------|
| .resume | 简历容器 |
| .header-content | 头部内容区 |
| .avatar | 头像 (100x130px) |
| .name | 姓名 |
| .job-intention | 求职意向 |
| .contact-info | 联系方式容器 |
| .summary | 个人总结 |
| .section | 内容区块 |
| .section-title | 区块标题 |
| .timeline-item | 时间线项目 |
| .timeline-header | 时间线头部 |
| .date | 日期标签 |
| .company / .school | 公司/学校名 |
| .position / .major | 职位/专业 |
| .project | 项目区块 |
| .project-title | 项目标题 |
| .description | 描述列表 |
| .certificate-tag | 证书标签 |

---

## 11. 安全与性能

### 11.1 安全措施

| 措施 | 实现方式 | 说明 |
|------|------|------|
| CORS 配置 | CorsConfig.java | 允许所有来源（开发阶段） |
| SQL 注入防护 | MyBatis-Plus 参数化查询 | LambdaQueryWrapper 自动参数化 |
| XSS 防护 | escapeHtml 函数 | HTML 导出时转义特殊字符 |
| 设备认证 | X-User-Id 请求头 | 当前写死为1，待实现真实认证 |

### 11.2 性能优化

| 优化项 | 实现方式 | 说明 |
|------|------|------|
| 自动保存防抖 | 前端 debounce 1s | 避免频繁 API 调用 |
| CSS 编辑防抖 | 前端 debounce 1s | 避免频繁 API 调用 |
| HTML 缓存防抖 | 前端 debounce 2s | context 保存到数据库 |
| 路由懒加载 | `() => import('../views/Editor.vue')` | 减少首屏加载时间 |
| HTML 导出缓存 | resume.context 字段 | 避免重复生成 HTML |
| 图片压缩 | Canvas 压缩 + Base64 | 超过 500KB 自动压缩 |
| Vite 代理 | 开发环境 API 代理 | 避免跨域请求开销 |
| iframe 沙箱 | sandbox="allow-same-origin" | 隔离预览样式 |

### 11.3 数据库索引优化

| 表 | 索引 | 用途 |
|------|------|------|
| user | idx_device_id | 设备ID快速查找 |
| resume | idx_user_id | 按用户查询简历 |
| resume | idx_style_id | 按样式查询简历 |
| resume_module | idx_resume_type | 按简历+类型查询模块 |
| resume_module | idx_resume_sort | 按简历+排序查询模块 |
| resume_module | idx_config_id | 关联配置查询 |
| module_type_config | uk_config_field | 配置组+字段唯一约束 |
| module_type_config | idx_module_type | 按模块类型查询配置 |
| module_type_config | idx_config_group | 按配置组查询 |
| css_style | idx_is_builtin | 查询内置样式 |

---

## 12. 部署方案

### 12.1 开发环境

```
前端: localhost:3000 (Vite dev server)
后端: localhost:8080 (Spring Boot)
数据库: localhost:3306 (MySQL)
API代理: Vite proxy /api → localhost:8080
```

### 12.2 生产环境

```
Nginx (前端静态资源 + API 反向代理)
    ↓
Spring Boot (后端 API, 端口 8080)
    ↓
MySQL 8.0 (数据库, 端口 3306)
```

### 12.3 构建命令

```bash
# 后端构建
cd backend
mvn clean package -DskipTests
java -jar target/backend-1.0.0-SNAPSHOT.jar

# 前端构建
cd frontend
npm install
npm run build
# 产物在 dist/ 目录
```

### 12.4 应用配置

```yaml
server:
  port: 8080

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/html_resume?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai
    username: root
    password: 123456
    driver-class-name: com.mysql.cj.jdbc.Driver
  jackson:
    date-format: yyyy-MM-dd HH:mm:ss
    time-zone: Asia/Shanghai
    serialization:
      write-dates-as-timestamps: false

mybatis-plus:
  mapper-locations: classpath:mapper/*.xml
  type-aliases-package: com.htmlresume.entity
  global-config:
    db-config:
      id-type: auto
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
```

---

## 13. 已知问题与待完善项

| 编号 | 问题 | 优先级 | 说明 |
|------|------|------|------|
| 1 | 用户认证未实现 | 高 | 当前 X-User-Id 写死为1，deviceId.js 返回固定值 |
| 2 | MybatisPlusConfig 为空 | 中 | 分页拦截器未配置，3.5.9 版本暂不支持 |
| 3 | 删除简历未级联删除模块 | 高 | 删除简历后模块数据残留 |
| 4 | 批量排序逐条更新 | 中 | batchUpdateSort 循环单条更新，性能较差 |
| 5 | 外键约束已删除 | 低 | drop_foreign_keys.sql 已移除外键，数据一致性靠应用层保证 |
| 6 | 模块配置查询使用 likeRight | 低 | ModuleConfigController 使用模糊匹配，可能返回意外结果 |
| 7 | CSS 编辑无语法高亮 | 低 | 使用 el-input textarea，无代码编辑器功能 |
| 8 | 图片存储为 Base64 | 中 | 大图片会导致 JSON 字段过大，应考虑文件存储 |

---

## 14. 后续扩展方向

- **用户注册登录**: JWT 认证体系，替换当前 device_id 方案
- **PDF 导出**: 基于 HTML 模板 + Puppeteer/wkhtmltopdf 生成 PDF
- **模板市场**: 用户可分享/下载 CSS 样式模板
- **AI 辅助优化**: 集成大语言模型优化简历内容
- **多语言支持**: i18n 国际化
- **简历分享链接**: 生成公开/私有分享链接
- **实时协作**: WebSocket 多人协同编辑
- **版本历史**: 简历编辑历史记录与回滚
