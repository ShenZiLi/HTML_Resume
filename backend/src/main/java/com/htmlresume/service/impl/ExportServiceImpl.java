package com.htmlresume.service.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.htmlresume.entity.CssStyle;
import com.htmlresume.entity.ModuleTypeConfig;
import com.htmlresume.entity.Resume;
import com.htmlresume.entity.ResumeModule;
import com.htmlresume.mapper.ModuleTypeConfigMapper;
import com.htmlresume.service.ExportService;
import com.htmlresume.service.ModuleService;
import com.htmlresume.service.ResumeService;
import com.htmlresume.service.StyleService;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class ExportServiceImpl implements ExportService {

    private final ResumeService resumeService;
    private final StyleService styleService;
    private final ModuleService moduleService;
    private final ModuleTypeConfigMapper moduleTypeConfigMapper;
    private final ObjectMapper objectMapper;

    public ExportServiceImpl(ResumeService resumeService,
                             StyleService styleService,
                             ModuleService moduleService,
                             ModuleTypeConfigMapper moduleTypeConfigMapper,
                             ObjectMapper objectMapper) {
        this.resumeService = resumeService;
        this.styleService = styleService;
        this.moduleService = moduleService;
        this.moduleTypeConfigMapper = moduleTypeConfigMapper;
        this.objectMapper = objectMapper;
    }

    @Override
    public String exportHtml(Long resumeId) {
        Resume resume = resumeService.getById(resumeId);
        if (resume == null) {
            throw new RuntimeException("Resume not found: " + resumeId);
        }

        CssStyle style = null;
        if (resume.getStyleId() != null) {
            style = styleService.getStyleById(resume.getStyleId());
        }

        List<ResumeModule> modules = resumeService.getBaseMapper().selectModulesByResumeId(resumeId);
        if (modules == null) {
            modules = Collections.emptyList();
        }

        return generateHtml(resume, modules, style);
    }

    private String generateHtml(Resume resume, List<ResumeModule> modules, CssStyle style) {
        StringBuilder html = new StringBuilder();

        html.append("<!DOCTYPE html>\n");
        html.append("<html lang=\"zh-CN\">\n");
        html.append("<head>\n");
        html.append("    <meta charset=\"UTF-8\">\n");
        html.append("    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n");
        html.append("    <title>").append(escapeHtml(resume.getTitle())).append("</title>\n");

        if (style != null && style.getCssContent() != null) {
            html.append("    <style>\n");
            html.append(style.getCssContent());
            html.append("\n    </style>\n");
        }

        html.append("</head>\n");
        html.append("<body>\n");

        html.append("<div class=\"resume-container\">\n");

        html.append("    <header class=\"resume-header\">\n");
        html.append("        <h1>").append(escapeHtml(resume.getTitle())).append("</h1>\n");
        html.append("    </header>\n\n");

        html.append("    <main class=\"resume-content\">\n");

        for (ResumeModule module : modules) {
            String moduleHtml = generateModuleHtml(module);
            if (moduleHtml != null && !moduleHtml.isEmpty()) {
                html.append(moduleHtml);
            }
        }

        html.append("    </main>\n");

        html.append("</div>\n");
        html.append("</body>\n");
        html.append("</html>");

        return html.toString();
    }

    private String generateModuleHtml(ResumeModule module) {
        if (module.getContent() == null || module.getContent().isEmpty()) {
            return null;
        }

        Map<String, Object> content;
        try {
            content = objectMapper.readValue(module.getContent(), new TypeReference<>() {});
        } catch (JsonProcessingException e) {
            return "";
        }

        if (content == null || content.isEmpty()) {
            return null;
        }

        ModuleTypeConfig config = null;
        if (module.getConfigId() != null) {
            config = moduleTypeConfigMapper.selectById(module.getConfigId());
        }

        StringBuilder moduleHtml = new StringBuilder();

        String moduleSectionClass = config != null && config.getCssClass() != null
                ? config.getCssClass()
                : "module-section " + module.getModuleType();

        moduleHtml.append("        <section class=\"").append(moduleSectionClass).append("\">\n");

        if (config != null) {
            String layoutType = config.getLayoutType();
            if (layoutType != null) {
                switch (layoutType.toLowerCase()) {
                    case "key_value":
                        moduleHtml.append(generateKeyValueHtml(content, config));
                        break;
                    case "list":
                        moduleHtml.append(generateListHtml(content, config));
                        break;
                    case "table":
                        moduleHtml.append(generateTableHtml(content, config));
                        break;
                    case "text_block":
                        moduleHtml.append(generateTextBlockHtml(content, config));
                        break;
                    default:
                        moduleHtml.append(generateDefaultHtml(content, config));
                        break;
                }
            } else {
                moduleHtml.append(generateDefaultHtml(content, config));
            }
        } else {
            moduleHtml.append(generateDefaultHtml(content, null));
        }

        moduleHtml.append("        </section>\n\n");

        return moduleHtml.toString();
    }

    private String generateKeyValueHtml(Map<String, Object> content, ModuleTypeConfig config) {
        StringBuilder html = new StringBuilder();
        html.append("            <dl class=\"key-value-list\">\n");

        for (Map.Entry<String, Object> entry : content.entrySet()) {
            String key = entry.getKey();
            Object value = entry.getValue();

            if (value == null || value.toString().isEmpty()) {
                continue;
            }

            String fieldName = config != null && config.getFieldName() != null
                    ? config.getFieldName()
                    : key;

            html.append("                <div class=\"key-value-item\">\n");
            html.append("                    <dt class=\"key-label\">").append(escapeHtml(fieldName)).append("</dt>\n");
            html.append("                    <dd class=\"key-value\">").append(escapeHtml(value.toString())).append("</dd>\n");
            html.append("                </div>\n");
        }

        html.append("            </dl>\n");
        return html.toString();
    }

    private String generateListHtml(Map<String, Object> content, ModuleTypeConfig config) {
        StringBuilder html = new StringBuilder();

        Object itemsObj = content.get("items");
        if (itemsObj instanceof List<?> items) {
            html.append("            <ul class=\"module-list\">\n");

            for (Object item : items) {
                html.append("                <li class=\"list-item\">\n");

                if (item instanceof Map<?, ?> itemMap) {
                    for (Map.Entry<?, ?> entry : itemMap.entrySet()) {
                        if (entry.getValue() != null && !entry.getValue().toString().isEmpty()) {
                            String tag = config != null && config.getHtmlTag() != null
                                    ? config.getHtmlTag()
                                    : "span";
                            String cssClass = config != null && config.getCssClass() != null
                                    ? config.getCssClass()
                                    : "item-field";

                            html.append("                    <")
                                    .append(tag)
                                    .append(" class=\"")
                                    .append(cssClass)
                                    .append("\">")
                                    .append(escapeHtml(entry.getValue().toString()))
                                    .append("</")
                                    .append(tag)
                                    .append(">\n");
                        }
                    }
                } else {
                    html.append("                    <span>").append(escapeHtml(item.toString())).append("</span>\n");
                }

                html.append("                </li>\n");
            }

            html.append("            </ul>\n");
        } else {
            for (Map.Entry<String, Object> entry : content.entrySet()) {
                if (entry.getValue() != null && !entry.getValue().toString().isEmpty()) {
                    String tag = config != null && config.getHtmlTag() != null
                            ? config.getHtmlTag()
                            : "p";
                    html.append("            <")
                            .append(tag)
                            .append(">")
                            .append(escapeHtml(entry.getKey()))
                            .append(": ")
                            .append(escapeHtml(entry.getValue().toString()))
                            .append("</")
                            .append(tag)
                            .append(">\n");
                }
            }
        }

        return html.toString();
    }

    private String generateTableHtml(Map<String, Object> content, ModuleTypeConfig config) {
        StringBuilder html = new StringBuilder();
        html.append("            <table class=\"module-table\">\n");
        html.append("                <thead>\n");
        html.append("                    <tr>\n");

        for (String key : content.keySet()) {
            html.append("                        <th>").append(escapeHtml(key)).append("</th>\n");
        }

        html.append("                    </tr>\n");
        html.append("                </thead>\n");
        html.append("                <tbody>\n");
        html.append("                    <tr>\n");

        for (Object value : content.values()) {
            html.append("                        <td>").append(escapeHtml(value != null ? value.toString() : "")).append("</td>\n");
        }

        html.append("                    </tr>\n");
        html.append("                </tbody>\n");
        html.append("            </table>\n");

        return html.toString();
    }

    private String generateTextBlockHtml(Map<String, Object> content, ModuleTypeConfig config) {
        StringBuilder html = new StringBuilder();
        String tag = config != null && config.getHtmlTag() != null
                ? config.getHtmlTag()
                : "p";

        for (Map.Entry<String, Object> entry : content.entrySet()) {
            if (entry.getValue() != null && !entry.getValue().toString().isEmpty()) {
                html.append("            <")
                        .append(tag)
                        .append(">")
                        .append(escapeHtml(entry.getValue().toString()))
                        .append("</")
                        .append(tag)
                        .append(">\n");
            }
        }

        return html.toString();
    }

    private String generateDefaultHtml(Map<String, Object> content, ModuleTypeConfig config) {
        StringBuilder html = new StringBuilder();

        Object itemsObj = content.get("items");
        if (itemsObj instanceof List<?> items && !items.isEmpty()) {
            for (Object item : items) {
                html.append("            <div class=\"item-block\">\n");

                if (item instanceof Map<?, ?> itemMap) {
                    for (Map.Entry<?, ?> entry : itemMap.entrySet()) {
                        if (entry.getValue() != null && !entry.getValue().toString().isEmpty()) {
                            html.append("                <p class=\"field\">");
                            html.append("<strong>").append(escapeHtml(entry.getKey().toString())).append(":</strong> ");
                            html.append(escapeHtml(entry.getValue().toString()));
                            html.append("</p>\n");
                        }
                    }
                }

                html.append("            </div>\n");
            }
        } else {
            html.append("            <div class=\"content-block\">\n");
            for (Map.Entry<String, Object> entry : content.entrySet()) {
                if (entry.getValue() != null && !entry.getValue().toString().isEmpty()) {
                    html.append("                <p class=\"field\">");
                    html.append("<strong>").append(escapeHtml(entry.getKey())).append(":</strong> ");
                    html.append(escapeHtml(entry.getValue().toString()));
                    html.append("</p>\n");
                }
            }
            html.append("            </div>\n");
        }

        return html.toString();
    }

    private String escapeHtml(String text) {
        if (text == null) {
            return "";
        }
        return text.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }
}
