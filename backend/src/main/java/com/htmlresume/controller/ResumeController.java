package com.htmlresume.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.htmlresume.common.Result;
import com.htmlresume.dto.ResumeWithModulesDTO;
import com.htmlresume.entity.Resume;
import com.htmlresume.entity.User;
import com.htmlresume.service.ResumeService;
import com.htmlresume.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/resumes")
public class ResumeController {

    @Autowired
    private ResumeService resumeService;

    @Autowired
    private UserService userService;

    @Autowired
    private ObjectMapper objectMapper;

    @PostMapping
    public Result<Resume> createResume(
            @RequestHeader("X-Device-Id") String deviceId,
            @RequestBody Map<String, String> body) {
        User user = userService.getByDeviceId(deviceId);
        if (user == null) {
            return Result.error("User not found");
        }
        String title = body.getOrDefault("title", "我的简历");
        Resume resume = resumeService.createResume(user.getId(), title);
        return Result.success(resume);
    }

    @GetMapping
    public Result<List<Resume>> listResumes(@RequestHeader("X-Device-Id") String deviceId) {
        User user = userService.getByDeviceId(deviceId);
        if (user == null) {
            return Result.error("User not found");
        }
        List<Resume> resumes = resumeService.listByUserId(user.getId());
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
            Object config = body.get("styleConfig");
            try {
                resume.setStyleConfig(objectMapper.writeValueAsString(config));
            } catch (com.fasterxml.jackson.core.JsonProcessingException e) {
                return Result.error("Invalid style config");
            }
            resumeService.updateById(resume);
        }
        return Result.success();
    }
}