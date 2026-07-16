# HTML Resume Editor — System Design Document

## 1. System Overview

### 1.1 Background

An AI-powered low-code HTML resume editor with visual editing, real-time preview, multiple style templates, and drag-and-drop module reordering. Users can create professional resumes without writing code, while also supporting HTML/CSS source editing for advanced customization.

### 1.2 Tech Stack

| Layer | Technology | Version | Description |
|-------|-----------|---------|-------------|
| Frontend | Vue 3 | ^3.4 | Composition API + `<script setup>` |
| Build Tool | Vite | ^5.0 | Dev server on port 3000, API proxy to 8080 |
| UI Library | Element Plus | ^2.5 | Forms, buttons, dropdowns, messages |
| State Mgmt | Pinia | ^2.1 | resume / style store modules |
| Router | Vue Router | ^4.3 | History mode, SPA routing |
| HTTP Client | Axios | ^1.6 | Unified request/response interceptors |
| Drag & Drop | vuedraggable | ^4.1 | Based on SortableJS |
| Backend | Spring Boot | 3.4.0 | Java 21 |
| ORM | MyBatis-Plus | 3.5.9 | BaseMapper + LambdaQueryWrapper |
| Database | MySQL | 8.0 | utf8mb4 charset, InnoDB engine |
| Build | Maven | 3.9+ | spring-boot-starter-parent |

### 1.3 Goals

- WYSIWYG resume editing experience
- Multiple CSS style templates with one-click switching
- Drag-and-drop module reordering with add/delete management
- Export to HTML and Markdown formats
- Real-time CSS source editing
- Auto-save to prevent data loss

## 2. Architecture

### 2.1 Overall Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    Frontend (Vue 3 + Vite + Element Plus)                │
├──────────────┬──────────────────┬──────────────┬───────────────────────┤
│  TopBar      │  LeftPanel       │  EditPanel    │  PreviewPanel         │
│  Resume Mgmt │  Module List     │  Dynamic Form │  HTML Preview         │
│  New/Delete   │  Drag & Sort     │  Auto-save    │  HTML Source View     │
│  Export      │  Add/Delete      │  Validation   │  CSS Live Edit        │
│  Style Switch│  Selection       │  Image Upload │  Style Preview        │
├──────────────┴──────────────────┴──────────────┴───────────────────────┤
│  Pinia Store                                                           │
│  ├─ resumeStore: currentResume / modules / selectedModuleId            │
│  └─ styleStore:  styles / currentStyle / customConfig                  │
├────────────────────────────────────────────────────────────────────────┤
│  API Layer (Axios)                                                     │
│  ├─ request.js: Interceptors (X-User-Id / unwrap / error handling)     │
│  ├─ resume.js:  CRUD + Export + Save context                          │
│  ├─ module.js:  CRUD + Sort + Config query                            │
│  └─ style.js:   List + Switch + Content update                        │
└────────────────────────────────┬───────────────────────────────────────┘
                                 │  REST API (JSON)
                                 │  Vite Proxy: /api → localhost:8080
┌────────────────────────────────┴───────────────────────────────────────┐
│                     Backend (Spring Boot 3.4 + Java 21)                 │
├──────────────┬──────────────────┬──────────────┬───────────────────────┤
│  Controller  │  Service         │  Mapper      │  Config               │
│  ├ Resume    │  ├ ResumeService │  ├ Resume    │  ├ CorsConfig         │
│  ├ Module    │  ├ ModuleService │  ├ Module    │  ├ JacksonConfig      │
│  ├ Style     │  ├ StyleService  │  ├ Style     │  └ MybatisPlus       │
│  ├ Export    │  ├ ExportService │  ├ Config    │     Config            │
│  ├ User      │  └ UserService  │  └ User      │                       │
│  └ Module    │                  │              │                       │
│    Config    │                  │              │                       │
├──────────────┴──────────────────┴──────────────┴───────────────────────┤
│  DTO: ResumeWithModulesDTO / BatchSortRequest / ModuleSortItem         │
│  Common: Result<T> (unified response: code/message/data)               │
└──────────────────────────────┬─────────────────────────────────────────┘
                               │
                    ┌──────────┴──────────┐
                    │    MySQL 8.0        │
                    │  html_resume DB     │
                    └─────────────────────┘
```

### 2.2 Frontend Data Flow

```
User Action → Vue Component → Pinia Action → API Call → Backend Controller
                                                              │
                                                         Service → Mapper → MySQL
                                                              │
Frontend Update ← Pinia State ← API Response ← Result<T> ← ─────────┘

Auto-Save Flow:
User Edit → DynamicForm @change → EditPanel debouncedSave (1s) → PUT /modules/{id}/content
```

## 3. Database Design

### 3.1 ER Diagram

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
                         │              config_id │
               style_id  │                       ▼
                         │          ┌───────────────────────┐
                         │          │ module_type_config     │
                         ▼          │ (field metadata)       │
               ┌─────────────────┐  │ config_group+field_key│
               │    css_style     │  │ = unique key          │
               │ (CSS templates)  │  └───────────────────────┘
               └─────────────────┘
```

### 3.2 Tables

#### user

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | BIGINT | PK, AUTO_INCREMENT | Primary key |
| device_id | VARCHAR(64) | NOT NULL, UNIQUE, INDEX | Device ID |
| created_at | DATETIME | NOT NULL | Creation time |
| updated_at | DATETIME | NOT NULL | Update time |

#### css_style

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | BIGINT | PK, AUTO_INCREMENT | Primary key |
| name | VARCHAR(64) | NOT NULL | Style name |
| description | VARCHAR(256) | NULL | Description |
| thumbnail | VARCHAR(512) | NULL | Thumbnail URL |
| css_content | MEDIUMTEXT | NOT NULL | CSS content |
| is_builtin | TINYINT(1) | DEFAULT 0 | Built-in style flag |
| is_active | TINYINT(1) | DEFAULT 1 | Active flag |

**Initial data**: 3 built-in styles
- id=1: Classic Business (blue, Inter font, rounded cards)
- id=2: Creative Colorful (purple gradient, Noto Sans SC, gradient badges)
- id=3: Academic Paper (black & white, Times New Roman, A4 size)

#### resume

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | BIGINT | PK, AUTO_INCREMENT | Primary key |
| user_id | BIGINT | NOT NULL, INDEX | User ID |
| title | VARCHAR(100) | NOT NULL | Resume title |
| style_id | BIGINT | NULL, INDEX | Style ID |
| style_config | JSON | NULL | Custom style overrides |
| context | MEDIUMTEXT | NULL | Cached HTML preview content |
| created_at | DATETIME | NOT NULL | Creation time |
| updated_at | DATETIME | NOT NULL | Update time |

#### module_type_config

Core table defining form fields for each module type. Fields include:
field_key, field_name, field_type (text/textarea/date/select/switch/image), 
layout_type (inline/block/badge/icon/timeline/split/list), html_tag, css_class, etc.

**Initial config groups**: basic_info_default (17 fields), education_default (10), work_experience_default (8), project_default (8), award_default (1)

#### resume_module

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | BIGINT | PK, AUTO_INCREMENT | Primary key |
| resume_id | BIGINT | NOT NULL, INDEX | Resume ID |
| module_type | VARCHAR(32) | NOT NULL | Module type |
| config_id | BIGINT | NULL, INDEX | Config ID |
| content | JSON | NOT NULL | Module content (JSON) |
| sort_order | INT | NOT NULL, DEFAULT 0 | Sort order |
| created_at | DATETIME | NOT NULL | Creation time |
| updated_at | DATETIME | NOT NULL | Update time |

## 4. API Endpoints

### 4.1 Specifications

- **Prefix**: `/api/v1`
- **Format**: `application/json`
- **Response**: `Result<T>` wrapper
  ```json
  {
    "code": 200,
    "message": "success",
    "data": { ... }
  }
  ```
- **Auth**: `X-User-Id` header (currently hardcoded to 1)

### 4.2 Key Endpoints

#### User

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/users/me` | Get current user info |

#### Resume Management

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/v1/resumes` | Create resume (auto-initializes 5 default modules) |
| GET | `/api/v1/resumes` | List user's resumes (sorted by update time desc) |
| GET | `/api/v1/resumes/{id}` | Get resume detail + modules + style info |
| PUT | `/api/v1/resumes/{id}/title` | Update resume title |
| DELETE | `/api/v1/resumes/{id}` | Delete resume |
| PUT | `/api/v1/resumes/{id}/style/{styleId}` | Switch CSS style template |
| PUT | `/api/v1/resumes/{id}/style-config` | Save custom style config |
| PUT | `/api/v1/resumes/{id}/context` | Save preview HTML to context |

#### Module Management

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/module-config/{moduleType}` | Get module field configs |
| POST | `/api/v1/modules` | Add module to resume |
| PUT | `/api/v1/modules/{id}/content` | Update module content JSON |
| DELETE | `/api/v1/modules/{id}` | Delete module |
| PUT | `/api/v1/modules/sort` | Batch update module sort order |

#### Style Management

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/styles` | List all active styles |
| GET | `/api/v1/styles/{id}` | Get style detail |
| PUT | `/api/v1/styles/{id}/content` | Update CSS content |

#### Export

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/resumes/{id}/export/html` | Export full HTML (Content-Disposition: attachment) |

## 5. Frontend Component Design

### 5.1 Component Tree

```
src/
├── main.js                          # App entry, register Pinia/Router/ElementPlus
├── App.vue                          # Root component
├── router/index.js                  # Route config, / → /editor (lazy loaded)
├── api/
│   ├── request.js                   # Axios wrapper
│   ├── resume.js                    # Resume API
│   ├── module.js                    # Module API
│   └── style.js                     # Style API
├── store/modules/
│   ├── resume.js                    # Resume state management
│   └── style.js                     # Style state management
├── views/Editor.vue                 # Editor main page (3-column + draggable dividers)
├── components/editor/
│   ├── TopBar.vue                   # Top toolbar
│   ├── LeftPanel.vue                # Left module panel
│   ├── EditPanel.vue                # Center edit panel
│   ├── DynamicForm.vue              # Dynamic form renderer
│   └── PreviewPanel.vue             # Right preview panel
├── utils/
│   ├── deviceId.js                  # Device ID generator
│   ├── htmlGenerator.js             # HTML generator
│   └── markdownGenerator.js         # Markdown generator
└── styles/main.css                  # Global styles
```

### 5.2 Key Components

#### Editor.vue — Main Editor

Layout: Top toolbar + 3-column content area with draggable dividers.
- Left panel (16%), Edit panel (flex:1), Preview panel (35%)
- Draggable dividers (range 10%~80%)
- Collapsible left/right panels
- Drag mask for iframe event capture prevention

#### TopBar.vue — Toolbar

| Area | Feature | Implementation |
|------|---------|---------------|
| Left | Resume selector | el-select with delete button |
| Left | Title editor | el-input, save on blur/enter |
| Left | New resume | el-button → createResume API |
| Left | Export dropdown | el-dropdown → HTML/Markdown |
| Right | Style switcher | el-select → switchStyle API |

#### LeftPanel.vue — Module Panel

- Module list with vuedraggable drag-and-drop reorder
- Module selection highlight
- Add module via el-dropdown
- Delete module with confirmation

Module types: basic_info, education, work_experience, project, award

#### EditPanel.vue — Edit Panel

- Shows form for selected module
- Auto-save with 1s debounce
- Save status display

#### DynamicForm.vue — Dynamic Form

Renders fields based on module_type_config:

| field_type | Component |
|------------|-----------|
| text | el-input |
| textarea | el-input type="textarea" |
| date | el-date-picker type="month" |
| select | el-select + el-option |
| switch | el-switch |
| image | el-input + el-upload (Canvas compress, max 2MB, Base64 storage) |

#### PreviewPanel.vue — Preview Panel

3 tabs: HTML Preview (iframe), HTML Source (view/copy), CSS Editor (live edit)

### 5.3 Pinia Stores

**resumeStore**: currentResume, modules, moduleConfigs, selectedModuleId, resumeList
**styleStore**: styles, currentStyle, customConfig

## 6. Core Business Flows

### 6.1 Initialization Flow

```
Page Load → Editor.vue onMounted
    ├── resumeStore.initOrRestore()
    │   ├── loadResumeList() → GET /resumes
    │   ├── Check localStorage for resume_id
    │   │   ├── Found → loadResume(id) → GET /resumes/{id}
    │   │   └── Not found → createResume() → POST /resumes
    │   └── autoSelectFirstModule()
    └── styleStore.loadStyles() → GET /styles
```

### 6.2 Module Edit Auto-Save

```
User edits field → @change → emitUpdate()
    → EditPanel debouncedSave (1000ms)
    → PUT /modules/{id}/content { content: {...} }
    → resumeStore.updateModule() → update lastSaved time
```

### 6.3 Module Drag Reorder

```
User drags module in LeftPanel → vuedraggable @end
    → Generate sortedModules [{id, sortOrder}]
    → PUT /modules/sort { resume_id, modules }
    → Backend batch update
    → Frontend update local sortOrder
```

### 6.4 HTML Generation & Preview

```
modules / currentStyle changes → htmlPreview recomputed
    → htmlGenerator.generateHtml(resume, modules, style)
    → Traverse modules by moduleType → generateSection()
    → PreviewPanel updates iframe or saves context (debounce 2s)
```

### 6.5 Style Switch Flow

```
User selects new style in TopBar → styleStore.switchStyle()
    → PUT /resumes/{resumeId}/style/{styleId}
    → Update resume.styleId
    → trigger htmlPreview recompute → iframe update
```

## 7. Key Data Structures

### 7.1 Resume Module Content JSON

**basic_info**: name, jobIntention, phone, email, wechat, github, blog, leetcode, workYears, targetCity, hometown, summary, salaryRange, expectedEntryDate, isPartyMember, photo, photoBorder

**education**: school, department, major, degree, startDate, endDate, is211, is985, isDoubleFirst, schoolLogo

**work_experience**: company, position, startDate, endDate, techStack, projectName, projectDescription, responsibilities[]

**project**: projectName, role, startDate, endDate, techStack, description, responsibilities[], achievements[]

**award**: categories[]

### 7.2 Unified Response Structure

```java
public class Result<T> {
    private Integer code;     // 200=success, 500=error
    private String message;
    private T data;
}
```

## 8. Built-in CSS Styles

| Feature | Classic Business (id=1) | Creative Colorful (id=2) | Academic Paper (id=3) |
|---------|------------------------|--------------------------|-----------------------|
| Primary Color | #255deb (blue) | #7c3aed→#ec4899 (gradient) | #000000 (black) |
| Font | Inter | Noto Sans SC | Times New Roman + Noto Serif SC |
| Background | #fafafa | Gradient | #ffffff |
| Border Radius | 12px | 20px | None |
| Header | Blue gradient | Purple-pink gradient | Centered + bottom border |
| Responsive | 768px breakpoint | None | 768px breakpoint |
| Paper Size | max-width: 960px | max-width: 960px | max-width: 210mm (A4) |

## 9. Deployment

### 9.1 Development

```
Frontend: localhost:3000 (Vite dev server)
Backend:  localhost:8080 (Spring Boot)
Database: localhost:3306 (MySQL)
API proxy: Vite proxy /api → localhost:8080
```

### 9.2 Production

```
Nginx (static assets + API reverse proxy)
    ↓
Spring Boot (backend API, port 8080)
    ↓
MySQL 8.0 (database, port 3306)
```

### 9.3 Build

```bash
# Backend
cd backend
mvn clean package -DskipTests
java -jar target/backend-1.0.0-SNAPSHOT.jar

# Frontend
cd frontend
npm install
npm run build   # output in dist/
```

## 10. Known Issues

| # | Issue | Priority |
|---|-------|----------|
| 1 | User auth not implemented (X-User-Id hardcoded to 1) | High |
| 2 | Resume delete doesn't cascade delete modules | High |
| 3 | Batch sort uses individual updates (low perf) | Medium |
| 4 | No foreign key constraints (app-level consistency) | Low |
| 5 | CSS editor has no syntax highlighting | Low |
| 6 | Images stored as Base64 (large JSON fields) | Medium |

## 11. Future Directions

- **User registration/login**: JWT auth to replace device_id
- **PDF export**: Using HTML template + Puppeteer/wkhtmltopdf
- **Template marketplace**: User-shareable CSS style templates
- **AI-assisted optimization**: LLM integration for resume content
- **Multi-language support**: i18n internationalization
- **Share links**: Public/private resume sharing
- **Real-time collaboration**: WebSocket multi-user editing
- **Version history**: Edit history with rollback

## 12. License

```
MIT License

Copyright (c) 2026
```
