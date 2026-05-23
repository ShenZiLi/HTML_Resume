-- Insert project module type config if not exists
DELETE FROM `module_type_config` WHERE `module_type` = 'project';

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
