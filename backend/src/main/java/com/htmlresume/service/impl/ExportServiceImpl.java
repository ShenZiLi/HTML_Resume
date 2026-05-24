package com.htmlresume.service.impl;

import com.htmlresume.entity.Resume;
import com.htmlresume.service.ExportService;
import com.htmlresume.service.ResumeService;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Base64;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class ExportServiceImpl implements ExportService {

    private static final Pattern IMG_SRC_PATTERN = Pattern.compile("src=\"(/images/[^\"]+)\"");
    private static final String IMAGE_DIR = "src/main/resources/static/images/";

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
            return embedImages(resume.getContext());
        }

        return "<!DOCTYPE html><html lang=\"zh-CN\"><head><meta charset=\"UTF-8\"><title>"
                + escapeHtml(resume.getTitle())
                + "</title></head><body><p>暂无预览内容，请先在编辑器中编辑简历</p></body></html>";
    }

    private String embedImages(String html) {
        Matcher matcher = IMG_SRC_PATTERN.matcher(html);
        StringBuffer result = new StringBuffer();

        while (matcher.find()) {
            String imgPath = matcher.group(1);
            String base64 = imageToBase64(imgPath);
            if (base64 != null) {
                matcher.appendReplacement(result, "src=\"" + base64 + "\"");
            } else {
                matcher.appendReplacement(result, Matcher.quoteReplacement(matcher.group(0)));
            }
        }
        matcher.appendTail(result);

        return result.toString();
    }

    private String imageToBase64(String imgPath) {
        try {
            String filename = imgPath.substring(imgPath.lastIndexOf('/') + 1);
            Path filePath = Paths.get(IMAGE_DIR, filename).toAbsolutePath().normalize();

            if (!Files.exists(filePath)) {
                return null;
            }

            String contentType = Files.probeContentType(filePath);
            if (contentType == null) {
                String name = filePath.getFileName().toString().toLowerCase();
                if (name.endsWith(".jpg") || name.endsWith(".jpeg")) contentType = "image/jpeg";
                else if (name.endsWith(".png")) contentType = "image/png";
                else if (name.endsWith(".gif")) contentType = "image/gif";
                else if (name.endsWith(".webp")) contentType = "image/webp";
                else if (name.endsWith(".bmp")) contentType = "image/bmp";
                else contentType = "application/octet-stream";
            }

            byte[] bytes = Files.readAllBytes(filePath);
            return "data:" + contentType + ";base64," + Base64.getEncoder().encodeToString(bytes);
        } catch (IOException e) {
            return null;
        }
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
