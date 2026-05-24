package com.htmlresume.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.htmlresume.dto.ResumeWithModulesDTO;
import com.htmlresume.entity.CssStyle;
import com.htmlresume.entity.Resume;
import com.htmlresume.entity.ResumeModule;
import com.htmlresume.mapper.ResumeMapper;
import com.htmlresume.service.ModuleService;
import com.htmlresume.service.ResumeService;
import com.htmlresume.service.StyleService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ResumeServiceImpl extends ServiceImpl<ResumeMapper, Resume> implements ResumeService {

    private static final List<String> DEFAULT_MODULE_TYPES = List.of(
            "basic_info",
            "education",
            "work_experience",
            "project",
            "award"
    );

    private final StyleService styleService;
    private final ModuleService moduleService;
    private final ObjectMapper objectMapper;

    public ResumeServiceImpl(StyleService styleService, ModuleService moduleService, ObjectMapper objectMapper) {
        this.styleService = styleService;
        this.moduleService = moduleService;
        this.objectMapper = objectMapper;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Resume createResume(Long userId, String title) {
        CssStyle defaultStyle = styleService.getDefaultStyle();

        Resume resume = Resume.builder()
                .userId(userId)
                .title(title)
                .styleId(defaultStyle != null ? defaultStyle.getId() : null)
                .styleConfig("{}")
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        save(resume);

        for (int i = 0; i < DEFAULT_MODULE_TYPES.size(); i++) {
            String moduleType = DEFAULT_MODULE_TYPES.get(i);
            Map<String, Object> defaultContent = new HashMap<>();
            defaultContent.put("moduleType", moduleType);
            defaultContent.put("items", List.of());

            try {
                moduleService.addModule(resume.getId(), moduleType, defaultContent, i + 1);
            } catch (Exception e) {
            }
        }

        return resume;
    }

    @Override
    public ResumeWithModulesDTO getResumeWithModules(Long resumeId) {
        Resume resume = getById(resumeId);
        if (resume == null) {
            return null;
        }

        List<ResumeModule> modules = moduleService.list(
                new LambdaQueryWrapper<ResumeModule>()
                        .eq(ResumeModule::getResumeId, resumeId)
                        .orderByAsc(ResumeModule::getSortOrder)
        );

        CssStyle style = null;
        if (resume.getStyleId() != null) {
            style = styleService.getStyleById(resume.getStyleId());
        }

        ResumeWithModulesDTO dto = new ResumeWithModulesDTO();
        dto.setResume(resume);
        dto.setModules(modules);
        dto.setStyle(style);
        return dto;
    }

    @Override
    public List<Resume> listByUserId(Long userId) {
        LambdaQueryWrapper<Resume> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Resume::getUserId, userId);
        wrapper.orderByDesc(Resume::getUpdatedAt);
        return list(wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Resume switchStyle(Long resumeId, Long newStyleId) {
        Resume resume = getById(resumeId);
        if (resume == null) {
            throw new RuntimeException("Resume not found: " + resumeId);
        }

        CssStyle style = styleService.getStyleById(newStyleId);
        if (style == null) {
            throw new RuntimeException("Style not found: " + newStyleId);
        }

        resume.setStyleId(newStyleId);
        resume.setUpdatedAt(LocalDateTime.now());
        updateById(resume);
        return resume;
    }
}
