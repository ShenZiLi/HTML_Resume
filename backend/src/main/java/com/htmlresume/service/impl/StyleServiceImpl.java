package com.htmlresume.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.htmlresume.entity.CssStyle;
import com.htmlresume.mapper.CssStyleMapper;
import com.htmlresume.mapper.ResumeMapper;
import com.htmlresume.service.StyleService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class StyleServiceImpl extends ServiceImpl<CssStyleMapper, CssStyle> implements StyleService {

    private final ResumeMapper resumeMapper;

    public StyleServiceImpl(ResumeMapper resumeMapper) {
        this.resumeMapper = resumeMapper;
    }

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

    @Override
    @Transactional(rollbackFor = Exception.class)
    public CssStyle createStyle(String name, String cssContent) {
        CssStyle style = CssStyle.builder()
                .name(name)
                .cssContent(cssContent)
                .isBuiltin(false)
                .isActive(true)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        save(style);
        return style;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteStyle(Long id) {
        CssStyle style = getById(id);
        if (style == null) {
            throw new RuntimeException("Style not found");
        }

        if (style.getIsBuiltin()) {
            throw new RuntimeException("Cannot delete built-in styles");
        }

        removeById(id);
    }
}
