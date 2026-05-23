package com.htmlresume.dto;

import com.htmlresume.entity.CssStyle;
import com.htmlresume.entity.Resume;
import com.htmlresume.entity.ResumeModule;
import lombok.Data;

import java.util.List;

@Data
public class ResumeWithModulesDTO {
    private Resume resume;
    private List<ResumeModule> modules;
    private CssStyle style;
}
