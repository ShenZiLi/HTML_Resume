package com.htmlresume.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@TableName("module_type_config")
public class ModuleTypeConfig {

    @TableId(type = IdType.AUTO)
    private Long id;

    @TableField("config_group")
    private String configGroup;

    @TableField("module_type")
    private String moduleType;

    @TableField("field_key")
    private String fieldKey;

    @TableField("field_name")
    private String fieldName;

    @TableField("field_type")
    private String fieldType;

    @TableField("layout_type")
    private String layoutType;

    @TableField("html_tag")
    private String htmlTag;

    @TableField("css_class")
    private String cssClass;

    @TableField("css_style")
    private String cssStyle;

    @TableField("placeholder")
    private String placeholder;

    @TableField("options")
    private String options;

    @TableField("default_value")
    private String defaultValue;

    @TableField("validation")
    private String validation;

    @TableField("is_required")
    private Boolean isRequired;

    @TableField("is_visible")
    private Boolean isVisible;

    @TableField("is_editable")
    private Boolean isEditable;

    @TableField("sort_order")
    private Integer sortOrder;

    @TableField("created_at")
    private LocalDateTime createdAt;

    @TableField("updated_at")
    private LocalDateTime updatedAt;
}
