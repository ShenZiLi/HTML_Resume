package com.htmlresume.dto;

import lombok.Data;

import java.util.List;

@Data
public class BatchSortRequest {
    private Long resumeId;
    private List<ModuleSortItem> modules;
}
