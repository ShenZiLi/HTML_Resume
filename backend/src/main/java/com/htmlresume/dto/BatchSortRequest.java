package com.htmlresume.dto;

import lombok.Data;

import java.util.List;

@Data
public class BatchSortRequest {
    private Long resume_id;
    private List<ModuleSortItem> modules;
}
