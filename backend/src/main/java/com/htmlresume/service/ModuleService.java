package com.htmlresume.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.htmlresume.dto.ModuleSortItem;
import com.htmlresume.entity.ResumeModule;

import java.util.List;
import java.util.Map;

public interface ModuleService extends IService<ResumeModule> {

    ResumeModule addModule(Long resumeId, String moduleType, Map<String, Object> content, Integer sortOrder);

    ResumeModule updateModuleContent(Long moduleId, Map<String, Object> content);

    void deleteModule(Long moduleId);

    void batchUpdateSort(Long resumeId, List<ModuleSortItem> modules);

    List<Map<String, Object>> getModulesWithConfig(Long resumeId);
}
