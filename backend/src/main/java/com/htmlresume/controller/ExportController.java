package com.htmlresume.controller;

import com.htmlresume.service.ExportService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/resumes")
public class ExportController {

    @Autowired
    private ExportService exportService;

    @GetMapping("/{id}/export/html")
    public ResponseEntity<String> exportHtml(@PathVariable Long id) {
        String html = exportService.exportHtml(id);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=resume.html")
                .contentType(MediaType.TEXT_HTML)
                .body(html);
    }
}