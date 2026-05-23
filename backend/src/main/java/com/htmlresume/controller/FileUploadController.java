package com.htmlresume.controller;

import com.htmlresume.common.Result;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/upload")
public class FileUploadController {

    @Value("${file.upload.path:src/main/resources/static/images/}")
    private String uploadDir;

    @PostMapping("/image")
    public Result<String> uploadImage(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return Result.error("文件不能为空");
        }

        String originalFilename = file.getOriginalFilename();
        String extension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        }

        String newFilename = UUID.randomUUID().toString() + extension;

        try {
            Path uploadPath = Paths.get(uploadDir).toAbsolutePath().normalize();
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            Path targetPath = uploadPath.resolve(newFilename);
            file.transferTo(targetPath);

            String imageUrl = "/images/" + newFilename;
            return Result.success(imageUrl);
        } catch (IOException e) {
            return Result.error("文件上传失败: " + e.getMessage());
        }
    }
}
