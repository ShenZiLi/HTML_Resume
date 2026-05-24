package com.htmlresume.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.htmlresume.common.Result;
import com.htmlresume.entity.ModuleTypeConfig;
import com.htmlresume.mapper.ModuleTypeConfigMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/module-config")
public class ModuleConfigController {

    @Autowired
    private ModuleTypeConfigMapper moduleTypeConfigMapper;

    @GetMapping("/{moduleType}")
    public Result<List<ModuleTypeConfig>> getConfig(@PathVariable String moduleType) {
        LambdaQueryWrapper<ModuleTypeConfig> query = new LambdaQueryWrapper<>();
        query.likeRight(ModuleTypeConfig::getModuleType, moduleType)
             .orderByAsc(ModuleTypeConfig::getSortOrder);
        List<ModuleTypeConfig> configs = moduleTypeConfigMapper.selectList(query);
        return Result.success(configs);
    }
}