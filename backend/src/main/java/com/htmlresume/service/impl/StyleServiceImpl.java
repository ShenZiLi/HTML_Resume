package com.htmlresume.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.htmlresume.entity.CssStyle;
import com.htmlresume.mapper.CssStyleMapper;
import com.htmlresume.service.StyleService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class StyleServiceImpl extends ServiceImpl<CssStyleMapper, CssStyle> implements StyleService {

    @Override
    public List<CssStyle> listActiveStyles() {
        LambdaQueryWrapper<CssStyle> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CssStyle::getIsActive, true);
        wrapper.orderByDesc(CssStyle::getCreatedAt);
        return list(wrapper);
    }

    @Override
    public List<CssStyle> listBuiltinStyles() {
        LambdaQueryWrapper<CssStyle> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CssStyle::getIsBuiltin, true);
        wrapper.eq(CssStyle::getIsActive, true);
        wrapper.orderByDesc(CssStyle::getCreatedAt);
        return list(wrapper);
    }

    @Override
    public CssStyle getStyleById(Long styleId) {
        return getById(styleId);
    }

    @Override
    public CssStyle getDefaultStyle() {
        LambdaQueryWrapper<CssStyle> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(CssStyle::getIsBuiltin, true);
        wrapper.eq(CssStyle::getIsActive, true);
        wrapper.last("LIMIT 1");
        return getOne(wrapper);
    }

    @Override
    public CssStyle updateStyleContent(Long id, String cssContent) {
        CssStyle style = new CssStyle();
        style.setId(id);
        style.setCssContent(cssContent);
        updateById(style);
        return style;
    }
}
