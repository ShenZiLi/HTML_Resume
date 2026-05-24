DELETE FROM `module_type_config` WHERE `module_type` = 'award';

INSERT INTO `module_type_config` (`config_group`, `module_type`, `field_key`, `field_name`, `field_type`, `layout_type`,
                                  `html_tag`, `css_class`, `placeholder`, `is_required`, `sort_order`)
VALUES ('award_default', 'award', 'categories', '荣誉证书', 'textarea', 'list', 'div', 'certificates',
        '每行一条证书', 0, 1);
