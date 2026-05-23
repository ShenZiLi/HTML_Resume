package com.htmlresume.controller;

import com.htmlresume.common.Result;
import com.htmlresume.dto.ResumeWithModulesDTO;
import com.htmlresume.entity.Resume;
import com.htmlresume.service.ResumeService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

// 暂未实现用户注册登录功能，当前通过 X-User-Id 请求头传递用户ID
@RestController
@RequestMapping("/api/v1/resumes")
public class ResumeController {

    @Autowired
    private ResumeService resumeService;

    @PostMapping
    public Result<Resume> createResume(
            @RequestHeader("X-User-Id") Long userId,
            @RequestBody Map<String, String> body) {
        String title = body.getOrDefault("title", "我的简历");
        Resume resume = resumeService.createResume(userId, title);
        return Result.success(resume);
    }

    @GetMapping
    public Result<List<Resume>> listResumes(@RequestHeader("X-User-Id") Long userId) {
        List<Resume> resumes = resumeService.listByUserId(userId);
        return Result.success(resumes);
    }

    @GetMapping("/{id}")
    public Result<ResumeWithModulesDTO> getResume(@PathVariable Long id) {
        ResumeWithModulesDTO resume = resumeService.getResumeWithModules(id);
        return Result.success(resume);
    }

    @PutMapping("/{id}/title")
    public Result<Void> updateTitle(
            @PathVariable Long id,
            @RequestBody Map<String, String> body) {
        String title = body.get("title");
        Resume resume = resumeService.getById(id);
        if (resume != null) {
            resume.setTitle(title);
            resumeService.updateById(resume);
        }
        return Result.success();
    }

    @DeleteMapping("/{id}")
    public Result<Void> deleteResume(@PathVariable Long id) {
        resumeService.removeById(id);
        return Result.success();
    }

    @PutMapping("/{id}/style/{styleId}")
    public Result<Resume> switchStyle(@PathVariable Long id, @PathVariable Long styleId) {
        Resume resume = resumeService.switchStyle(id, styleId);
        return Result.success(resume);
    }

    @PutMapping("/{id}/style-config")
    public Result<Void> updateStyleConfig(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body) {
        Resume resume = resumeService.getById(id);
        if (resume != null) {
            try {
                ObjectMapper mapper = new ObjectMapper();
                resume.setStyleConfig(mapper.writeValueAsString(body));
            } catch (Exception e) {
                resume.setStyleConfig("{}");
            }
            resumeService.updateById(resume);
        }
        return Result.success();
    }

    @PutMapping("/{id}/context")
    public Result<Void> updateContext(
            @PathVariable Long id,
            @RequestBody Map<String, String> body) {
        Resume resume = resumeService.getById(id);
        if (resume != null) {
            resume.setContext(body.get("context"));
            resumeService.updateById(resume);
        }
        return Result.success();
    }
}