package com.htmlresume.controller;

import com.htmlresume.common.Result;
import com.htmlresume.dto.ModuleSortItem;
import com.htmlresume.entity.ResumeModule;
import com.htmlresume.service.ModuleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/modules")
public class ModuleController {

    @Autowired
    private ModuleService moduleService;

    @PostMapping
    public Result<ResumeModule> addModule(@RequestBody Map<String, Object> body) {
        Long resumeId = Long.valueOf(body.get("resume_id").toString());
        String moduleType = body.get("module_type").toString();
        @SuppressWarnings("unchecked")
        Map<String, Object> content = (Map<String, Object>) body.get("content");
        Integer sortOrder = body.get("sort_order") != null ? Integer.valueOf(body.get("sort_order").toString()) : 0;
        ResumeModule module = moduleService.addModule(resumeId, moduleType, content, sortOrder);
        return Result.success(module);
    }

    @PutMapping("/{id}/content")
    public Result<ResumeModule> updateModuleContent(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body) {
        @SuppressWarnings("unchecked")
        Map<String, Object> content = (Map<String, Object>) body.get("content");
        ResumeModule module = moduleService.updateModuleContent(id, content);
        return Result.success(module);
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteModule(@PathVariable Long id) {
        moduleService.deleteModule(id);
        return Result.success();
    }

    @PutMapping("/sort")
    public Result<Void> batchUpdateSort(@RequestBody Map<String, Object> body) {
        Long resumeId = Long.valueOf(body.get("resume_id").toString());
        @SuppressWarnings("unchecked")
        List<ModuleSortItem> modules = (List<ModuleSortItem>) body.get("modules");
        moduleService.batchUpdateSort(resumeId, modules);
        return Result.success();
    }
}