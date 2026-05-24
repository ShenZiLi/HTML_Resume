package com.htmlresume.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.htmlresume.entity.CssStyle;

import java.util.List;

public interface StyleService extends IService<CssStyle> {

    List<CssStyle> listActiveStyles();

    List<CssStyle> listBuiltinStyles();

    CssStyle getStyleById(Long styleId);

    CssStyle getDefaultStyle();

    CssStyle updateStyleContent(Long id, String cssContent);

    CssStyle createStyle(String name, String cssContent);

    void deleteStyle(Long id);
}
