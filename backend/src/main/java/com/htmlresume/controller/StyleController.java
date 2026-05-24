package com.htmlresume.controller;

import com.htmlresume.common.Result;
import com.htmlresume.entity.CssStyle;
import com.htmlresume.service.StyleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/styles")
public class StyleController {

    @Autowired
    private StyleService styleService;

    @GetMapping
    public Result<List<CssStyle>> listStyles() {
        List<CssStyle> styles = styleService.listActiveStyles();
        return Result.success(styles);
    }

    @GetMapping("/{id}")
    public Result<CssStyle> getStyle(@PathVariable Long id) {
        CssStyle style = styleService.getStyleById(id);
        if (style == null) {
            return Result.error("Style not found");
        }
        return Result.success(style);
    }

    @PutMapping("/{id}/content")
    public Result<CssStyle> updateStyleContent(
            @PathVariable Long id,
            @RequestBody Map<String, String> body) {
        String cssContent = body.get("cssContent");
        CssStyle style = styleService.updateStyleContent(id, cssContent);
        if (style == null) {
            return Result.error("Style not found");
        }
        return Result.success(style);
    }
}