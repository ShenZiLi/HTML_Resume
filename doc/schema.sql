-- =============================================
-- HTML Resume Editor - Database Schema
-- =============================================

-- 1. 用户表
CREATE TABLE `user`
(
    `id`         BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
    `device_id`  VARCHAR(64) NOT NULL UNIQUE COMMENT '设备ID',
    `created_at` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    INDEX `idx_device_id` (`device_id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci COMMENT ='用户表';

-- 2. CSS样式模板表
CREATE TABLE `css_style`
(
    `id`          BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
    `name`        VARCHAR(64) NOT NULL COMMENT '样式名称',
    `description` VARCHAR(256) COMMENT '样式描述',
    `thumbnail`   VARCHAR(512) COMMENT '样式缩略图URL',
    `css_content` MEDIUMTEXT  NOT NULL COMMENT 'CSS样式内容',
    `is_builtin`  TINYINT(1)           DEFAULT 0 COMMENT '是否内置样式(0:否 1:是)',
    `is_active`   TINYINT(1)           DEFAULT 1 COMMENT '是否启用(0:禁用 1:启用)',
    `created_at`  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    INDEX `idx_is_builtin` (`is_builtin`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci COMMENT ='CSS样式模板表';

-- 3. 简历主表
CREATE TABLE `resume`
(
    `id`           BIGINT       NOT NULL AUTO_INCREMENT COMMENT '主键',
    `user_id`      BIGINT       NOT NULL COMMENT '用户ID',
    `title`        VARCHAR(100) NOT NULL DEFAULT '我的简历' COMMENT '简历标题',
    `style_id`     BIGINT COMMENT '样式ID',
    `style_config` JSON COMMENT '自定义样式覆盖配置',
    `context`      MEDIUMTEXT COMMENT '预览生成的HTML内容',
    `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_style_id` (`style_id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
    FOREIGN KEY (`style_id`) REFERENCES `css_style` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci COMMENT ='简历主表';

-- 4. 模块类型配置表
CREATE TABLE `module_type_config`
(
    `id`            BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
    `config_group`  VARCHAR(32) NOT NULL COMMENT '配置组标识',
    `module_type`   VARCHAR(32) NOT NULL COMMENT '模块类型',
    `field_key`     VARCHAR(64) NOT NULL COMMENT '字段标识',
    `field_name`    VARCHAR(64) NOT NULL COMMENT '字段名称',
    `field_type`    VARCHAR(32) NOT NULL DEFAULT 'text' COMMENT '字段类型: text/textarea/date/select/switch/image',
    `layout_type`   VARCHAR(32) NOT NULL DEFAULT 'block' COMMENT 'HTML布局类型: inline/block/badge/icon/timeline/split',
    `html_tag`      VARCHAR(32)          DEFAULT 'span' COMMENT 'HTML标签: h1/h2/h3/p/span/div/li/a/img',
    `css_class`     VARCHAR(128) COMMENT 'CSS类名',
    `css_style`     VARCHAR(512) COMMENT '内联样式',
    `placeholder`   VARCHAR(256) COMMENT '占位提示',
    `options`       JSON COMMENT '可选项(JSON数组)',
    `default_value` VARCHAR(256) COMMENT '默认值',
    `validation`    VARCHAR(256) COMMENT '校验规则',
    `is_required`   TINYINT(1)           DEFAULT 0 COMMENT '是否必填(0:否 1:是)',
    `is_visible`    TINYINT(1)           DEFAULT 1 COMMENT '是否显示(0:隐藏 1:显示)',
    `is_editable`   TINYINT(1)           DEFAULT 1 COMMENT '是否可编辑(0:只读 1:可编辑)',
    `sort_order`    INT                  DEFAULT 0 COMMENT '字段排序',
    `created_at`    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`    DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_config_field` (`config_group`, `field_key`),
    INDEX `idx_module_type` (`module_type`),
    INDEX `idx_config_group` (`config_group`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci COMMENT ='模块类型配置表';

-- 5. 简历模块表
CREATE TABLE `resume_module`
(
    `id`          BIGINT      NOT NULL AUTO_INCREMENT COMMENT '主键',
    `resume_id`   BIGINT      NOT NULL COMMENT '简历ID',
    `module_type` VARCHAR(32) NOT NULL COMMENT '模块类型',
    `config_id`   BIGINT COMMENT '模块配置ID',
    `content`     JSON        NOT NULL COMMENT '模块内容(JSON)',
    `sort_order`  INT         NOT NULL DEFAULT 0 COMMENT '排序序号',
    `created_at`  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at`  DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    INDEX `idx_resume_type` (`resume_id`, `module_type`),
    INDEX `idx_resume_sort` (`resume_id`, `sort_order`),
    INDEX `idx_config_id` (`config_id`),
    FOREIGN KEY (`resume_id`) REFERENCES `resume` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`config_id`) REFERENCES `module_type_config` (`id`)
) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci COMMENT ='简历模块表';

-- =============================================
-- 初始化数据
-- =============================================

-- 初始化内置样式
INSERT INTO `css_style` (`id`, `name`, `description`, `thumbnail`, `css_content`, `is_builtin`, `is_active`)
VALUES (1, '简约商务', '蓝色主色调，适合正式场合', '/styles/business.png', ':root {
    --primary: #255deb;
    --primary-light: #dbeafe;
    --dark: #1e293b;
    --gray: #64748b;
    --light-gray: #f1f5f9;
    --white: #ffffff;
    --border: #e2e8f0;
}

* { margin: 0; padding: 0; box-sizing: border-box; }

body {
    font-family: ''Inter'', sans-serif;
    background-color: #fafafa;
    color: var(--dark);
    line-height: 1.6;
    padding: 2rem;
}

.resume {
    max-width: 960px;
    margin: 0 auto;
    background: var(--white);
    border-radius: 12px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.08);
    overflow: hidden;
}

header {
    background: linear-gradient(135deg, var(--primary), #1d4ed8);
    color: var(--white);
    padding: 2.5rem 2rem;
}

.section { padding: 2rem; border-bottom: 1px solid var(--border); }
.section:last-child { border-bottom: none; }

.section-title {
    font-size: 1.375rem;
    font-weight: 600;
    color: var(--primary);
    margin-bottom: 1.25rem;
    padding-bottom: 0.5rem;
    border-bottom: 2px solid var(--primary-light);
}

.timeline-item { margin-bottom: 1.75rem; }
.timeline-header { display: flex; justify-content: space-between; margin-bottom: 0.5rem; flex-wrap: wrap; gap: 0.5rem; }
.company, .school { font-weight: 600; font-size: 1.125rem; }
.position, .major { font-weight: 500; color: var(--gray); }

.date {
    background: var(--primary-light);
    color: var(--primary);
    padding: 0.25rem 0.5rem;
    border-radius: 20px;
    font-size: 0.875rem;
    font-weight: 500;
    white-space: nowrap;
}

.description { margin-top: 0.75rem; padding-left: 1rem; border-left: 3px solid var(--primary-light); }
.description li { margin-bottom: 0.5rem; position: relative; padding-left: 1.25rem; }
.description li:before { content: ""; color: var(--primary); font-weight: bold; position: absolute; left: 0; top: 0; }

.certificate-tag {
    background: var(--primary-light);
    color: var(--primary);
    padding: 0.375rem 0.75rem;
    border-radius: 20px;
    font-size: 0.9rem;
    font-weight: 500;
    display: inline-block;
    margin: 0.25rem;
}

.project {
    background: var(--light-gray);
    border-radius: 8px;
    padding: 1.25rem;
    margin-bottom: 1.5rem;
}

.project-title { font-weight: 600; font-size: 1.125rem; margin-bottom: 0.5rem; }

@media (max-width: 768px) {
    body { padding: 1rem; }
    .contact-info { flex-direction: column; gap: 0.75rem; }
}', 1, 1),

       (2, '创意彩色', '渐变色彩，适合互联网岗位', '/styles/creative.png', ':root {
    --primary: #7c3aed;
    --primary-light: #ede9fe;
    --secondary: #ec4899;
    --dark: #1f2937;
    --gray: #6b7280;
    --light-gray: #f9fafb;
    --white: #ffffff;
    --border: #e5e7eb;
}

* { margin: 0; padding: 0; box-sizing: border-box; }

body {
    font-family: ''Noto Sans SC'', sans-serif;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    padding: 2rem;
}

.resume {
    max-width: 960px;
    margin: 0 auto;
    background: var(--white);
    border-radius: 20px;
    box-shadow: 0 20px 40px rgba(0,0,0,0.15);
}

header {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: var(--white);
    padding: 3rem 2rem;
    border-radius: 20px 20px 0 0;
}

.section { padding: 2.5rem 2rem; border-bottom: 1px dashed var(--border); }

.section-title {
    font-size: 1.5rem;
    font-weight: 700;
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    margin-bottom: 1.5rem;
}

.timeline-item { padding: 1.5rem; border-left: 4px solid var(--primary); margin-bottom: 1.5rem; background: var(--light-gray); border-radius: 0 12px 12px 0; }

.date {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: var(--white);
    padding: 0.5rem 1rem;
    border-radius: 25px;
    font-size: 0.8rem;
}

.certificate-tag {
    background: linear-gradient(135deg, var(--primary), var(--secondary));
    color: var(--white);
    padding: 0.5rem 1rem;
    border-radius: 25px;
    font-size: 0.85rem;
    margin: 0.25rem;
    display: inline-block;
}', 1, 1),

       (3, '学术论文', '黑白简洁，适合校招', '/styles/academic.png', ':root {
    --primary: #000000;
    --dark: #111827;
    --gray: #4b5563;
    --light-gray: #f3f4f6;
    --white: #ffffff;
    --border: #d1d5db;
}

* { margin: 0; padding: 0; box-sizing: border-box; }

body {
    font-family: ''Times New Roman'', ''Noto Serif SC'', serif;
    background-color: var(--white);
    padding: 0;
    color: var(--dark);
}

.resume {
    max-width: 210mm;
    margin: 0 auto;
    padding: 2rem 3rem;
}

header {
    text-align: center;
    padding: 2rem 0;
    border-bottom: 2px solid var(--primary);
    margin-bottom: 1.5rem;
}

.name { font-size: 2rem; font-weight: bold; letter-spacing: 0.1em; }

.contact-info {
    display: flex;
    justify-content: center;
    gap: 2rem;
    margin-top: 1rem;
    font-size: 0.9rem;
}

.section { padding: 1.5rem 0; }

.section-title {
    font-size: 1.25rem;
    font-weight: bold;
    border-bottom: 1px solid var(--primary);
    padding-bottom: 0.5rem;
    margin-bottom: 1rem;
    text-transform: uppercase;
}

.timeline-item { margin-bottom: 1rem; }
.timeline-header { display: flex; justify-content: space-between; margin-bottom: 0.25rem; }

.date { font-size: 0.85rem; color: var(--gray); }
.description { padding-left: 1rem; }
.description li { margin-bottom: 0.25rem; list-style-type: disc; }

.certificate-tag {
    border: 1px solid var(--primary);
    padding: 0.25rem 0.75rem;
    font-size: 0.85rem;
    margin: 0.25rem;
    display: inline-block;
}', 1, 1);

-- 初始化模块类型配置 - basic_info
INSERT INTO `module_type_config` (`config_group`, `module_type`, `field_key`, `field_name`, `field_type`, `layout_type`,
                                  `html_tag`, `css_class`, `placeholder`, `is_required`, `sort_order`)
VALUES ('basic_info_default', 'basic_info', 'name', '姓名', 'text', 'inline', 'h1', 'name', '请输入姓名', 1, 1),
       ('basic_info_default', 'basic_info', 'jobIntention', '求职意向', 'text', 'inline', 'div', 'job-intention',
        '请输入求职意向', 0, 2),
       ('basic_info_default', 'basic_info', 'phone', '电话', 'text', 'badge', 'span', 'contact-item', '请输入电话', 1,
        3),
       ('basic_info_default', 'basic_info', 'email', '邮箱', 'text', 'badge', 'span', 'contact-item', '请输入邮箱', 0,
        4),
       ('basic_info_default', 'basic_info', 'wechat', '微信', 'text', 'badge', 'span', 'contact-item', '请输入微信号',
        0, 5),
       ('basic_info_default', 'basic_info', 'github', 'GitHub', 'text', 'icon', 'a', 'contact-item', '请输入GitHub链接',
        0, 6),
       ('basic_info_default', 'basic_info', 'blog', '博客', 'text', 'icon', 'a', 'contact-item', '请输入博客链接', 0,
        7),
       ('basic_info_default', 'basic_info', 'leetcode', 'LeetCode', 'text', 'badge', 'span', 'contact-item',
        '请输入LeetCode主页', 0, 8),
       ('basic_info_default', 'basic_info', 'workYears', '工作年限', 'text', 'badge', 'span', 'contact-item', '如: 3年',
        0, 9),
       ('basic_info_default', 'basic_info', 'targetCity', '期望城市', 'text', 'badge', 'span', 'contact-item',
        '如: 上海', 0, 10),
       ('basic_info_default', 'basic_info', 'hometown', '籍贯', 'text', 'inline', 'span', 'contact-item', '如: 上海', 0,
        11),
       ('basic_info_default', 'basic_info', 'summary', '个人总结', 'textarea', 'block', 'p', 'summary',
        '请输入个人总结', 0, 12),
       ('basic_info_default', 'basic_info', 'salaryRange', '期望薪资', 'text', 'badge', 'span', 'contact-item',
        '如: 15-25K', 0, 13),
       ('basic_info_default', 'basic_info', 'expectedEntryDate', '到岗时间', 'date', 'badge', 'span', 'contact-item',
        '', 0, 14),
       ('basic_info_default', 'basic_info', 'isPartyMember', '党员', 'switch', 'inline', 'span', 'contact-item', '', 0,
        15),
       ('basic_info_default', 'basic_info', 'photo', '照片', 'image', 'split', 'img', 'avatar', '', 0, 16),
       ('basic_info_default', 'basic_info', 'photoBorder', '照片边框', 'switch', 'inline', 'span', 'photo-border', '', 0, 17);

-- 初始化模块类型配置 - education
INSERT INTO `module_type_config` (`config_group`, `module_type`, `field_key`, `field_name`, `field_type`, `layout_type`,
                                  `html_tag`, `css_class`, `placeholder`, `is_required`, `sort_order`, `options`)
VALUES ('education_default', 'education', 'school', '学校', 'text', 'timeline', 'div', 'school', '请输入学校', 1, 1, NULL),
       ('education_default', 'education', 'department', '院系', 'text', 'inline', 'span', 'department', '请输入院系', 0,
        2, NULL),
       ('education_default', 'education', 'major', '专业', 'text', 'inline', 'div', 'major', '请输入专业', 1, 3, NULL),
       ('education_default', 'education', 'degree', '学历', 'select', 'badge', 'span', 'degree', '', 1, 4,
        '[{"label": "博士", "value": "博士"}, {"label": "硕士", "value": "硕士"}, {"label": "本科", "value": "本科"}, {"label": "大专", "value": "大专"}]'),
       ('education_default', 'education', 'startDate', '开始时间', 'date', 'split', 'span', 'date', '', 1, 5, NULL),
       ('education_default', 'education', 'endDate', '结束时间', 'date', 'split', 'span', 'date', '', 1, 6, NULL),
       ('education_default', 'education', 'is211', '211', 'switch', 'badge', 'span', 'tag', '', 0, 7, NULL),
       ('education_default', 'education', 'is985', '985', 'switch', 'badge', 'span', 'tag', '', 0, 8, NULL),
       ('education_default', 'education', 'isDoubleFirst', '双一流', 'switch', 'badge', 'span', 'tag', '', 0, 9, NULL),
       ('education_default', 'education', 'schoolLogo', '学校Logo', 'image', 'split', 'img', 'school-logo', '', 0, 10, NULL);

-- 初始化模块类型配置 - work_experience
INSERT INTO `module_type_config` (`config_group`, `module_type`, `field_key`, `field_name`, `field_type`, `layout_type`,
                                  `html_tag`, `css_class`, `placeholder`, `is_required`, `sort_order`)
VALUES ('work_experience_default', 'work_experience', 'company', '公司名称', 'text', 'timeline', 'div', 'company',
        '请输入公司名称', 1, 1),
       ('work_experience_default', 'work_experience', 'position', '职位', 'text', 'inline', 'div', 'position',
        '请输入职位', 1, 2),
       ('work_experience_default', 'work_experience', 'startDate', '开始时间', 'date', 'split', 'span', 'date', '', 1,
        3),
       ('work_experience_default', 'work_experience', 'endDate', '结束时间', 'date', 'split', 'span', 'date',
        '至今留空', 0, 4),
       ('work_experience_default', 'work_experience', 'techStack', '技术栈', 'text', 'block', 'div', 'tech-stack',
        '如: Spring Cloud, Redis, MySQL', 0, 5),
       ('work_experience_default', 'work_experience', 'projectName', '项目名称', 'text', 'inline', 'div',
        'project-name', '请输入项目名称', 0, 6),
       ('work_experience_default', 'work_experience', 'projectDescription', '项目描述', 'textarea', 'block', 'p',
        'description', '请输入项目描述', 0, 7),
       ('work_experience_default', 'work_experience', 'responsibilities', '工作职责', 'textarea', 'list', 'ul',
        'description', '每行一条职责', 1, 8);

-- 初始化模块类型配置 - project
INSERT INTO `module_type_config` (`config_group`, `module_type`, `field_key`, `field_name`, `field_type`, `layout_type`,
                                  `html_tag`, `css_class`, `placeholder`, `is_required`, `sort_order`)
VALUES ('project_default', 'project', 'projectName', '项目名称', 'text', 'timeline', 'div', 'project-title',
        '请输入项目名称', 1, 1),
       ('project_default', 'project', 'role', '担任角色', 'text', 'inline', 'span', 'role', '如: 核心开发', 1, 2),
       ('project_default', 'project', 'startDate', '开始时间', 'date', 'split', 'span', 'date', '', 1, 3),
       ('project_default', 'project', 'endDate', '结束时间', 'date', 'split', 'span', 'date', '', 1, 4),
       ('project_default', 'project', 'techStack', '技术栈', 'text', 'block', 'div', 'tech-stack',
        '如: SpringBoot, MySQL, Redis', 1, 5),
       ('project_default', 'project', 'description', '项目描述', 'textarea', 'block', 'p', 'description',
        '请输入项目描述', 1, 6),
       ('project_default', 'project', 'responsibilities', '工作内容', 'textarea', 'list', 'ul', 'responsibilities',
        '每行一条工作内容', 0, 7),
       ('project_default', 'project', 'achievements', '项目成果', 'textarea', 'list', 'ul', 'achievements',
        '每行一条成果', 0, 8);

-- 初始化模块类型配置 - award
INSERT INTO `module_type_config` (`config_group`, `module_type`, `field_key`, `field_name`, `field_type`, `layout_type`,
                                  `html_tag`, `css_class`, `placeholder`, `is_required`, `sort_order`)
VALUES ('award_default', 'award', 'categories', '证书分类', 'textarea', 'badge-group', 'div', 'certificates',
        'JSON格式: [{"name":"语言","items":["英语六级"]}]', 0, 1);
