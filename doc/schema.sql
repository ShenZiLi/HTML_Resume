/*
 Navicat Premium Dump SQL

 Source Server         : mysql
 Source Server Type    : MySQL
 Source Server Version : 80046 (8.0.46)
 Source Host           : localhost:3306
 Source Schema         : html_resume

 Target Server Type    : MySQL
 Target Server Version : 80046 (8.0.46)
 File Encoding         : 65001

 Date: 24/05/2026 16:50:05
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for css_style
-- ----------------------------
DROP TABLE IF EXISTS `css_style`;
CREATE TABLE `css_style`  (
                              `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
                              `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '样式名称',
                              `description` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '样式描述',
                              `thumbnail` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '样式缩略图URL',
                              `css_content` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'CSS样式内容',
                              `is_builtin` tinyint(1) NULL DEFAULT 0 COMMENT '是否内置样式(0:否 1:是)',
                              `is_active` tinyint(1) NULL DEFAULT 1 COMMENT '是否启用(0:禁用 1:启用)',
                              `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                              `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                              PRIMARY KEY (`id`) USING BTREE,
                              INDEX `idx_is_builtin`(`is_builtin` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = 'CSS样式模板表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of css_style
-- ----------------------------
INSERT INTO `css_style` VALUES (1, '简约商务', '蓝色主色调，适合正式场合', '/styles/business.png', ':root {\n    --primary: #955deb;\n    --primary-light: #dbeafe;\n    --dark: #1e293b;\n    --gray: #64748b;\n    --light-gray: #f1f5f9;\n    --white: #ffffff;\n    --border: #e2e8f0;\n}\n\n* { margin: 0; padding: 0; box-sizing: border-box; }\n\nbody {\n    font-family: \'Inter\', sans-serif;\n    background-color: #fafafa;\n    color: var(--dark);\n    line-height: 1.6;\n    padding: 2rem;\n}\n\n.resume {\n    max-width: 960px;\n    margin: 0 auto;\n    background: var(--white);\n    border-radius: 12px;\n    box-shadow: 0 10px 30px rgba(0,0,0,0.08);\n    overflow: hidden;\n}\n\nheader {\n    background: linear-gradient(135deg, var(--primary), #1d4ed8);\n    color: var(--white);\n    padding: 2.5rem 2rem;\n    display: flex;\n    justify-content: space-between;\n    align-items: flex-start;\n    gap: 1.5rem;\n    position: relative;\n}\n\n.header-content {\n    flex: 1;\n    display: flex;\n    flex-direction: column;\n    gap: 0.5rem;\n}\n\n.avatar {\n    width: 100px;\n    height: 130px;\n    object-fit: cover;\n    border-radius: 8px;\n    box-shadow: 0 4px 12px rgba(0,0,0,0.15);\n    flex-shrink: 0;\n}\n\n.job-intention {\n    font-size: 1.1rem;\n    font-weight: 500;\n    opacity: 0.9;\n}\n\n.contact-info {\n    font-size: 0.9rem;\n    opacity: 0.85;\n    display: flex;\n    flex-wrap: wrap;\n    gap: 0.5rem;\n}\n\n\n\n\n.contact-info a { color: var(--white); text-decoration: underline; }\n\n.summary {\n    font-size: 0.95rem;\n    opacity: 0.8;\n    line-height: 1.5;\n}\n\n@media (max-width: 768px) {\n    header { flex-direction: column-reverse; align-items: center; }\n    .avatar { width: 80px; height: 100px; }\n    .contact-info { flex-direction: column; gap: 0.5rem; }\n}\n\n.section {\n  padding: 2rem 2rem 0rem 2rem;\n}\n.section:last-child { border-bottom: none; }\n\n.section-title {\n    font-size: 1.375rem;\n    font-weight: 600;\n    color: var(--primary);\n    margin-bottom: 1.25rem;\n    padding-bottom: 0.5rem;\n    border-bottom: 2px solid var(--primary-light);\n\n}\n\n.timeline-item { margin-bottom: 1.75rem; }\n.timeline-header { display: flex; justify-content: space-between; margin-bottom: 0.5rem; flex-wrap: wrap; gap: 0.5rem;align-items: center; }\n.company, .school { font-weight: 600; font-size: 1.125rem; }\n.position, .major { font-weight: 500; color: var(--gray); }\n.degree { font-weight: 500; color: var(--gray); }\n.date {\n    background: var(--primary-light);\n    color: var(--primary);\n    padding: 0.25rem 0.5rem;\n    border-radius: 20px;\n    font-size: 0.875rem;\n    font-weight: 500;\n    white-space: nowrap;\n}\n\n.description { margin-top: 0.75rem; padding-left: 1rem; border-left: 3px solid var(--primary-light); }\n.description li { margin-bottom: 0.5rem; position: relative; padding-left: 1.25rem; list-style-type: none; }\n    .description li:before {\n      content: \"•\";\n      color: var(--primary);\n      font-weight: bold;\n      position: absolute;\n      left: 0;\n      top: 0;\n    }\n.certificate-tag {\n    background: var(--primary-light);\n    color: var(--primary);\n    padding: 0.375rem 0.75rem;\n    border-radius: 20px;\n    font-size: 0.9rem;\n    font-weight: 500;\n    display: inline-block;\n    margin: 0.25rem;\n}\n\n.project {\n    background: var(--light-gray);\n    border-radius: 8px;\n    padding: 1.25rem;\n    margin-bottom: 1.5rem;\n}\n\n.project-title { font-weight: 600; font-size: 1.125rem; margin-bottom: 0rem; }\n.project .company { font-size: 1rem; color: var(--gray); font-weight: 500; }\n\n@media (max-width: 768px) {\n    body { padding: 1rem; }\n    .contact-info { flex-direction: column; gap: 0.75rem; }\n}', 1, 1, '2026-05-23 18:38:46', '2026-05-24 00:41:23');
INSERT INTO `css_style` VALUES (2, '创意彩色', '渐变色彩，适合互联网岗位', '/styles/creative.png', ':root {\n    --primary: #7c3aed;\n    --primary-light: #ede9fe;\n    --secondary: #ec4899;\n    --dark: #1f2937;\n    --gray: #6b7280;\n    --light-gray: #f9fafb;\n    --white: #ffffff;\n    --border: #e5e7eb;\n}\n\n* { margin: 0; padding: 0; box-sizing: border-box; }\n\nbody {\n    font-family: \'Noto Sans SC\', sans-serif;\n    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);\n    padding: 2rem;\n}\n\n.resume {\n    max-width: 960px;\n    margin: 0 auto;\n    background: var(--white);\n    border-radius: 20px;\n    box-shadow: 0 20px 40px rgba(0,0,0,0.15);\n}\n\nheader {\n    background: linear-gradient(135deg, var(--primary), var(--secondary));\n    color: var(--white);\n    padding: 3rem 2rem;\n    border-radius: 20px 20px 0 0;\n    display: flex;\n    justify-content: space-between;\n    align-items: flex-start;\n    gap: 1.5rem;\n    position: relative;\n}\n\n.header-content {\n    flex: 1;\n    display: flex;\n    flex-direction: column;\n    gap: 0.5rem;\n}\n\n.avatar {\n    width: 100px;\n    height: 130px;\n    object-fit: cover;\n    border-radius: 12px;\n    box-shadow: 0 8px 20px rgba(0,0,0,0.2);\n    flex-shrink: 0;\n}\n\n.job-intention {\n    font-size: 1.1rem;\n    font-weight: 500;\n    opacity: 0.9;\n}\n\n.contact-info {\n    font-size: 0.9rem;\n    opacity: 0.85;\n    display: flex;\n    flex-wrap: wrap;\n    gap: 0.5rem;\n}\n\n.contact-info a { color: var(--white); text-decoration: underline; }\n\n.summary {\n    font-size: 0.95rem;\n    opacity: 0.8;\n    line-height: 1.5;\n}\n\n.timeline-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem; flex-wrap: wrap; gap: 0.5rem; }\n.section { padding: 2.5rem 2rem; border-bottom: 1px dashed var(--border); }\n\n.section-title {\n    font-size: 1.5rem;\n    font-weight: 700;\n    background: linear-gradient(135deg, var(--primary), var(--secondary));\n    -webkit-background-clip: text;\n    -webkit-text-fill-color: transparent;\n    margin-bottom: 1.5rem;\n}\n\n.timeline-item { padding: 1.5rem; border-left: 4px solid var(--primary); margin-bottom: 1.5rem; background: var(--light-gray); border-radius: 0 12px 12px 0; }\n.timeline-item .description li { list-style-type: none; }\n\n.date {\n    background: linear-gradient(135deg, var(--primary), var(--secondary));\n    color: var(--white);\n    padding: 0.5rem 1rem;\n    border-radius: 25px;\n    font-size: 0.8rem;\n}\n\n.certificate-tag {\n    background: linear-gradient(135deg, var(--primary), var(--secondary));\n    color: var(--white);\n    padding: 0.5rem 1rem;\n    border-radius: 25px;\n    font-size: 0.85rem;\n    margin: 0.25rem;\n    display: inline-block;\n}', 1, 1, '2026-05-23 18:38:46', '2026-05-24 00:28:23');
INSERT INTO `css_style` VALUES (3, '学术论文', '黑白简洁，适合校招', '/styles/academic.png', ':root {\n    --primary: #000000;\n    --dark: #111827;\n    --gray: #4b5563;\n    --light-gray: #f3f4f6;\n    --white: #ffffff;\n    --border: #d1d5db;\n}\n\n* { margin: 0; padding: 0; box-sizing: border-box; }\n\nbody {\n    font-family: \'Times New Roman\', \'Noto Serif SC\', serif;\n    background-color: var(--white);\n    padding: 0;\n    color: var(--dark);\n}\n\n.resume {\n    max-width: 210mm;\n    margin: 0 auto;\n    padding: 2rem 3rem;\n}\n\nheader {\n    text-align: center;\n    padding: 2rem 0;\n    border-bottom: 2px solid var(--primary);\n    margin-bottom: 1.5rem;\n    position: relative;\n}\n\n.header-content {\n    display: flex;\n    flex-direction: column;\n    align-items: center;\n    gap: 0.5rem;\n    padding-right: 120px;\n}\n\n.avatar {\n    position: absolute;\n    top: 0;\n    right: 0;\n    width: 100px;\n    height: 130px;\n    object-fit: cover;\n    border-radius: 4px;\n    box-shadow: 0 2px 8px rgba(0,0,0,0.1);\n}\n\n.name { font-size: 2rem; font-weight: bold; letter-spacing: 0.1em; }\n\n.job-intention { font-size: 1.1rem; font-weight: 500; color: var(--gray); }\n\n.contact-info {\n    display: flex;\n    justify-content: center;\n    gap: 2rem;\n    margin-top: 1rem;\n    font-size: 0.9rem;\n}\n\n.summary {\n    font-size: 0.95rem;\n    color: var(--gray);\n    line-height: 1.5;\n    margin-top: 0.5rem;\n}\n\n@media (max-width: 768px) {\n    .header-content { padding-right: 0; }\n    .avatar { position: static; margin: 1rem auto; }\n}\n\n.section { padding: 1.5rem 0; }\n\n.section-title {\n    font-size: 1.25rem;\n    font-weight: bold;\n    text-transform: uppercase;\n    border-bottom: 1px solid var(--primary);\n    padding-bottom: 0.25rem;\n    margin-bottom: 1rem;\n}\n\n.timeline-item { margin-bottom: 1rem; }\n.timeline-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.25rem; }\n\n.date { font-size: 0.85rem; color: var(--gray); }\n\n.certificate-tag {\n    background: var(--light-gray);\n    padding: 0.25rem 0.5rem;\n    border: 1px solid var(--border);\n    font-size: 0.85rem;\n    display: inline-block;\n    margin: 0.25rem;\n}\n\n.project { margin-bottom: 1rem; }\n.project-title { font-weight: bold; margin-bottom: 0.25rem; }\n\n.description { margin-top: 0.5rem; }\n.description li { margin-bottom: 0.25rem; list-style-type: none; }', 1, 1, '2026-05-23 18:38:46', '2026-05-24 00:27:42');

-- ----------------------------
-- Table structure for module_type_config
-- ----------------------------
DROP TABLE IF EXISTS `module_type_config`;
CREATE TABLE `module_type_config`  (
                                       `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
                                       `config_group` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置组标识',
                                       `module_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '模块类型',
                                       `field_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '字段标识',
                                       `field_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '字段名称',
                                       `field_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'text' COMMENT '字段类型: text/textarea/date/select/switch/image',
                                       `layout_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'block' COMMENT 'HTML布局类型: inline/block/badge/icon/timeline/split',
                                       `html_tag` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT 'span' COMMENT 'HTML标签: h1/h2/h3/p/span/div/li/a/img',
                                       `css_class` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'CSS类名',
                                       `css_style` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '内联样式',
                                       `placeholder` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '占位提示',
                                       `options` json NULL COMMENT '可选项(JSON数组)',
                                       `default_value` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '默认值',
                                       `validation` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '校验规则',
                                       `is_required` tinyint(1) NULL DEFAULT 0 COMMENT '是否必填(0:否 1:是)',
                                       `is_visible` tinyint(1) NULL DEFAULT 1 COMMENT '是否显示(0:隐藏 1:显示)',
                                       `is_editable` tinyint(1) NULL DEFAULT 1 COMMENT '是否可编辑(0:只读 1:可编辑)',
                                       `sort_order` int NULL DEFAULT 0 COMMENT '字段排序',
                                       `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                       `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                       PRIMARY KEY (`id`) USING BTREE,
                                       UNIQUE INDEX `uk_config_field`(`config_group` ASC, `field_key` ASC) USING BTREE,
                                       INDEX `idx_module_type`(`module_type` ASC) USING BTREE,
                                       INDEX `idx_config_group`(`config_group` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 54 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '模块类型配置表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of module_type_config
-- ----------------------------
INSERT INTO `module_type_config` VALUES (1, 'basic_info_default', 'basic_info', 'name', '姓名', 'text', 'inline', 'h1', 'name', NULL, '请输入姓名', NULL, NULL, NULL, 1, 1, 1, 1, '2026-05-23 18:38:46', '2026-05-23 18:38:46');
INSERT INTO `module_type_config` VALUES (2, 'basic_info_default', 'basic_info', 'jobIntention', '求职意向', 'text', 'inline', 'div', 'job-intention', NULL, '请输入求职意向', NULL, NULL, NULL, 0, 1, 1, 2, '2026-05-23 18:38:46', '2026-05-23 18:38:46');
INSERT INTO `module_type_config` VALUES (3, 'basic_info_default', 'basic_info', 'phone', '电话', 'text', 'badge', 'span', 'contact-item', NULL, '请输入电话', NULL, NULL, NULL, 1, 1, 1, 3, '2026-05-23 18:38:46', '2026-05-23 18:38:46');
INSERT INTO `module_type_config` VALUES (4, 'basic_info_default', 'basic_info', 'email', '邮箱', 'text', 'badge', 'span', 'contact-item', NULL, '请输入邮箱', NULL, NULL, NULL, 0, 1, 1, 4, '2026-05-23 18:38:46', '2026-05-23 18:38:46');
INSERT INTO `module_type_config` VALUES (6, 'basic_info_default', 'basic_info', 'github', 'GitHub', 'text', 'icon', 'span', 'contact-item', NULL, '请输入GitHub链接', NULL, NULL, NULL, 0, 1, 1, 7, '2026-05-23 18:38:46', '2026-05-23 22:57:03');
INSERT INTO `module_type_config` VALUES (9, 'basic_info_default', 'basic_info', 'workYears', '工作年限', 'text', 'badge', 'span', 'contact-item', NULL, '如: 3年', NULL, NULL, NULL, 0, 1, 1, 5, '2026-05-23 18:38:46', '2026-05-23 22:42:58');
INSERT INTO `module_type_config` VALUES (10, 'basic_info_default', 'basic_info', 'targetCity', '期望城市', 'text', 'badge', 'span', 'contact-item', NULL, '如: 上海', NULL, NULL, NULL, 0, 1, 1, 6, '2026-05-23 18:38:46', '2026-05-23 23:18:44');
INSERT INTO `module_type_config` VALUES (16, 'basic_info_default', 'basic_info', 'photo', '照片', 'image', 'split', 'img', 'avatar', NULL, '', NULL, NULL, NULL, 0, 1, 1, 8, '2026-05-23 18:38:46', '2026-05-23 22:43:05');
INSERT INTO `module_type_config` VALUES (17, 'education_default', 'education', 'school', '学校', 'text', 'timeline', 'div', 'school', NULL, '请输入学校', NULL, NULL, NULL, 1, 1, 1, 1, '2026-05-23 18:45:46', '2026-05-23 18:45:46');
INSERT INTO `module_type_config` VALUES (19, 'education_default', 'education', 'major', '专业', 'text', 'inline', 'div', 'major', NULL, '请输入专业', NULL, NULL, NULL, 1, 1, 1, 3, '2026-05-23 18:45:46', '2026-05-23 18:45:46');
INSERT INTO `module_type_config` VALUES (20, 'education_default', 'education', 'degree', '学历', 'select', 'badge', 'span', 'degree', NULL, '', '[{\"label\": \"博士\", \"value\": \"博士\"}, {\"label\": \"硕士\", \"value\": \"硕士\"}, {\"label\": \"本科\", \"value\": \"本科\"}, {\"label\": \"大专\", \"value\": \"大专\"}]', NULL, NULL, 1, 1, 1, 4, '2026-05-23 18:45:46', '2026-05-23 18:45:46');
INSERT INTO `module_type_config` VALUES (21, 'education_default', 'education', 'startDate', '开始时间', 'date', 'split', 'span', 'date', NULL, '', NULL, NULL, NULL, 1, 1, 1, 5, '2026-05-23 18:45:46', '2026-05-23 18:45:46');
INSERT INTO `module_type_config` VALUES (22, 'education_default', 'education', 'endDate', '结束时间', 'date', 'split', 'span', 'date', NULL, '', NULL, NULL, NULL, 1, 1, 1, 6, '2026-05-23 18:45:46', '2026-05-23 18:45:46');
INSERT INTO `module_type_config` VALUES (27, 'work_experience_default', 'work_experience', 'company', '公司名称', 'text', 'timeline', 'div', 'company', NULL, '请输入公司名称', NULL, NULL, NULL, 1, 1, 1, 1, '2026-05-23 18:45:46', '2026-05-23 18:45:46');
INSERT INTO `module_type_config` VALUES (28, 'work_experience_default', 'work_experience', 'position', '职位', 'text', 'inline', 'div', 'position', NULL, '请输入职位', NULL, NULL, NULL, 1, 1, 1, 2, '2026-05-23 18:45:46', '2026-05-23 18:45:46');
INSERT INTO `module_type_config` VALUES (29, 'work_experience_default', 'work_experience', 'startDate', '开始时间', 'date', 'split', 'span', 'date', NULL, '', NULL, NULL, NULL, 1, 1, 1, 3, '2026-05-23 18:45:46', '2026-05-23 18:45:46');
INSERT INTO `module_type_config` VALUES (30, 'work_experience_default', 'work_experience', 'endDate', '结束时间', 'date', 'split', 'span', 'date', NULL, '至今留空', NULL, NULL, NULL, 0, 1, 1, 4, '2026-05-23 18:45:46', '2026-05-23 18:45:46');
INSERT INTO `module_type_config` VALUES (34, 'work_experience_default', 'work_experience', 'responsibilities', '工作职责', 'textarea', 'list', 'ul', 'description', NULL, '每行一条职责', NULL, NULL, NULL, 1, 1, 1, 7, '2026-05-23 18:45:46', '2026-05-23 21:57:00');
INSERT INTO `module_type_config` VALUES (43, 'project_default', 'project', 'projectName', '项目名称', 'text', 'timeline', 'div', 'project-title', NULL, '请输入项目名称', NULL, NULL, NULL, 1, 1, 1, 1, '2026-05-23 23:54:00', '2026-05-23 23:54:00');
INSERT INTO `module_type_config` VALUES (44, 'project_default', 'project', 'role', '担任角色', 'text', 'inline', 'span', 'role', NULL, '如: 核心开发', NULL, NULL, NULL, 1, 1, 1, 2, '2026-05-23 23:54:00', '2026-05-23 23:54:00');
INSERT INTO `module_type_config` VALUES (45, 'project_default', 'project', 'startDate', '开始时间', 'date', 'split', 'span', 'date', NULL, '', NULL, NULL, NULL, 1, 1, 1, 3, '2026-05-23 23:54:00', '2026-05-23 23:54:00');
INSERT INTO `module_type_config` VALUES (46, 'project_default', 'project', 'endDate', '结束时间', 'date', 'split', 'span', 'date', NULL, '', NULL, NULL, NULL, 1, 1, 1, 4, '2026-05-23 23:54:00', '2026-05-23 23:54:00');
INSERT INTO `module_type_config` VALUES (47, 'project_default', 'project', 'techStack', '技术栈', 'text', 'block', 'div', 'tech-stack', NULL, '如: SpringBoot, MySQL, Redis', NULL, NULL, NULL, 1, 1, 1, 5, '2026-05-23 23:54:00', '2026-05-23 23:54:00');
INSERT INTO `module_type_config` VALUES (48, 'project_default', 'project', 'description', '项目描述', 'textarea', 'block', 'p', 'description', NULL, '请输入项目描述', NULL, NULL, NULL, 1, 1, 1, 6, '2026-05-23 23:54:00', '2026-05-23 23:54:00');
INSERT INTO `module_type_config` VALUES (49, 'project_default', 'project', 'responsibilities', '工作内容', 'textarea', 'list', 'ul', 'responsibilities', NULL, '每行一条工作内容', NULL, NULL, NULL, 0, 1, 1, 7, '2026-05-23 23:54:00', '2026-05-23 23:54:00');
INSERT INTO `module_type_config` VALUES (50, 'project_default', 'project', 'achievements', '项目成果', 'textarea', 'list', 'ul', 'achievements', NULL, '每行一条成果', NULL, NULL, NULL, 0, 1, 1, 8, '2026-05-23 23:54:00', '2026-05-23 23:54:00');
INSERT INTO `module_type_config` VALUES (53, 'award_default', 'award', 'categories', '荣誉证书', 'textarea', 'list', 'div', 'certificates', NULL, '每行一条证书', NULL, NULL, NULL, 0, 1, 1, 1, '2026-05-24 11:31:48', '2026-05-24 11:31:48');

-- ----------------------------
-- Table structure for resume
-- ----------------------------
DROP TABLE IF EXISTS `resume`;
CREATE TABLE `resume`  (
                           `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
                           `user_id` bigint NOT NULL COMMENT '用户ID',
                           `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '我的简历' COMMENT '简历标题',
                           `style_id` bigint NULL DEFAULT NULL COMMENT '样式ID',
                           `style_config` json NULL COMMENT '自定义样式覆盖配置',
                           `context` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '预览生成的HTML内容',
                           `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                           `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                           PRIMARY KEY (`id`) USING BTREE,
                           INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
                           INDEX `idx_style_id`(`style_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '简历主表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for resume_module
-- ----------------------------
DROP TABLE IF EXISTS `resume_module`;
CREATE TABLE `resume_module`  (
                                  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
                                  `resume_id` bigint NOT NULL COMMENT '简历ID',
                                  `module_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '模块类型',
                                  `config_id` bigint NULL DEFAULT NULL COMMENT '模块配置ID',
                                  `content` json NOT NULL COMMENT '模块内容(JSON)',
                                  `sort_order` int NOT NULL DEFAULT 0 COMMENT '排序序号',
                                  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                                  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                                  PRIMARY KEY (`id`) USING BTREE,
                                  INDEX `idx_resume_type`(`resume_id` ASC, `module_type` ASC) USING BTREE,
                                  INDEX `idx_resume_sort`(`resume_id` ASC, `sort_order` ASC) USING BTREE,
                                  INDEX `idx_config_id`(`config_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 62 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '简历模块表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
                         `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
                         `device_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '设备ID',
                         `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
                         `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
                         PRIMARY KEY (`id`) USING BTREE,
                         UNIQUE INDEX `device_id`(`device_id` ASC) USING BTREE,
                         INDEX `idx_device_id`(`device_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'e54ceaa3-d25e-4b72-93d7-b8034135ef4b', '2026-05-23 19:28:20', '2026-05-23 19:28:20');

