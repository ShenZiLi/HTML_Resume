# 简历编辑器初始界面设计

## 目标

打开页面即恢复上次编辑状态，三栏同时可见，自动选中第一个模块，无需额外操作即可开始编辑。

## 初始化流程

```
页面加载
  → localStorage 有 resumeId？
    → 有：调用 GET /resumes/{id} 加载简历
      → 成功：填充三栏数据，自动选中第一个模块
      → 失败（简历已删除等）：清除 localStorage，走首次流程
    → 没有：首次访问
      → 自动调用 POST /resumes 创建默认简历
      → 保存 resumeId 到 localStorage
      → 填充三栏数据，自动选中第一个模块
```

## 数据流

1. **Editor.vue `onMounted`**：触发初始化
2. **resumeStore.initOrRestore()**：新 action，封装上述逻辑
3. **三栏联动**：
   - 左栏：显示 modules 列表，selectedModuleId 默认为第一个模块的 id
   - 中栏：根据 selectedModuleId 加载 DynamicForm
   - 右栏：根据 currentResume + modules + currentStyle 生成预览
4. **styleStore.loadStyles()**：初始化时同步加载样式列表

## 涉及修改的文件

| 文件 | 修改内容 |
|------|---------|
| `store/modules/resume.js` | 新增 `initOrRestore()` action，增加 `selectedModuleId` state |
| `views/Editor.vue` | `onMounted` 调用 `initOrRestore()`，管理 selectedModuleId，传递给子组件 |
| `components/editor/LeftPanel.vue` | 接收 selectedModuleId prop，emit select 事件 |
| `components/editor/EditPanel.vue` | 接收 selectedModule prop（已有），根据选中模块渲染表单 |

## 不修改的部分

- 三栏布局结构（保持三栏同时可见）
- TopBar、PreviewPanel 组件逻辑
- API 层（已修复完毕）

## selectedModuleId 管理方式

- 存储在 resumeStore 的 state 中
- Editor.vue 作为唯一管理者，将 selectedModuleId 传给 LeftPanel，将 selectedModule 对象传给 EditPanel
- LeftPanel 点击模块时 emit select 事件，Editor.vue 更新 selectedModuleId
- 加载简历后自动设置为 modules[0].id
