package com.htmlresume.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.htmlresume.dto.ModuleSortItem;
import com.htmlresume.entity.ModuleTypeConfig;
import com.htmlresume.entity.ResumeModule;
import com.htmlresume.mapper.ModuleTypeConfigMapper;
import com.htmlresume.mapper.ResumeModuleMapper;
import com.htmlresume.service.ModuleService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ModuleServiceImpl extends ServiceImpl<ResumeModuleMapper, ResumeModule> implements ModuleService {

    private final ModuleTypeConfigMapper moduleTypeConfigMapper;
    private final ObjectMapper objectMapper;

    public ModuleServiceImpl(ModuleTypeConfigMapper moduleTypeConfigMapper, ObjectMapper objectMapper) {
        this.moduleTypeConfigMapper = moduleTypeConfigMapper;
        this.objectMapper = objectMapper;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ResumeModule addModule(Long resumeId, String moduleType, Map<String, Object> content, Integer sortOrder) {
        LambdaQueryWrapper<ModuleTypeConfig> configWrapper = new LambdaQueryWrapper<>();
        configWrapper.eq(ModuleTypeConfig::getModuleType, moduleType);
        configWrapper.last("LIMIT 1");
        ModuleTypeConfig config = moduleTypeConfigMapper.selectOne(configWrapper);

        String contentJson;
        try {
            contentJson = objectMapper.writeValueAsString(content);
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to serialize content", e);
        }

        int finalSortOrder;
        if (sortOrder != null) {
            finalSortOrder = sortOrder;
        } else {
            LambdaQueryWrapper<ResumeModule> maxSortWrapper = new LambdaQueryWrapper<>();
            maxSortWrapper.eq(ResumeModule::getResumeId, resumeId);
            maxSortWrapper.orderByDesc(ResumeModule::getSortOrder);
            maxSortWrapper.last("LIMIT 1");
            ResumeModule maxSortModule = getOne(maxSortWrapper);

            finalSortOrder = (maxSortModule != null && maxSortModule.getSortOrder() != null)
                    ? maxSortModule.getSortOrder() + 1
                    : 1;
        }

        ResumeModule module = ResumeModule.builder()
                .resumeId(resumeId)
                .moduleType(moduleType)
                .configId(config != null ? config.getId() : null)
                .content(contentJson)
                .sortOrder(finalSortOrder)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        save(module);
        return module;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ResumeModule updateModuleContent(Long moduleId, Map<String, Object> content) {
        ResumeModule module = getById(moduleId);
        if (module == null) {
            throw new RuntimeException("Module not found: " + moduleId);
        }

        try {
            module.setContent(objectMapper.writeValueAsString(content));
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to serialize content", e);
        }
        module.setUpdatedAt(LocalDateTime.now());
        updateById(module);
        return module;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteModule(Long moduleId) {
        removeById(moduleId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void batchUpdateSort(Long resumeId, List<ModuleSortItem> modules) {
        for (ModuleSortItem item : modules) {
            ResumeModule module = getById(item.getId());
            if (module != null && module.getResumeId().equals(resumeId)) {
                module.setSortOrder(item.getSortOrder());
                module.setUpdatedAt(LocalDateTime.now());
                updateById(module);
            }
        }
    }

    @Override
    public List<Map<String, Object>> getModulesWithConfig(Long resumeId) {
        return getBaseMapper().selectModulesWithConfig(resumeId);
    }
}
