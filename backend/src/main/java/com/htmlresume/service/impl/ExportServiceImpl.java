package com.htmlresume.service.impl;

import com.htmlresume.entity.Resume;
import com.htmlresume.service.ExportService;
import com.htmlresume.service.ResumeService;
import org.springframework.stereotype.Service;

@Service
public class ExportServiceImpl implements ExportService {

    private final ResumeService resumeService;

    public ExportServiceImpl(ResumeService resumeService) {
        this.resumeService = resumeService;
    }

    @Override
    public String exportHtml(Long resumeId) {
        Resume resume = resumeService.getById(resumeId);
        if (resume == null) {
            throw new RuntimeException("Resume not found: " + resumeId);
        }

        if (resume.getContext() != null && !resume.getContext().isEmpty()) {
            return resume.getContext();
        }

        return "<!DOCTYPE html><html lang=\"zh-CN\"><head><meta charset=\"UTF-8\"><title>"
                + escapeHtml(resume.getTitle())
                + "</title></head><body><p>暂无预览内容，请先在编辑器中编辑简历</p></body></html>";
    }

    private String escapeHtml(String text) {
        if (text == null) return "";
        return text.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }
}
