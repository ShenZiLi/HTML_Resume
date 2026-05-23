package com.htmlresume.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.htmlresume.dto.ResumeWithModulesDTO;
import com.htmlresume.entity.Resume;

import java.util.List;

public interface ResumeService extends IService<Resume> {

    Resume createResume(Long userId, String title);

    ResumeWithModulesDTO getResumeWithModules(Long resumeId);

    List<Resume> listByUserId(Long userId);

    Resume switchStyle(Long resumeId, Long newStyleId);
}
