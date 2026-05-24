package com.htmlresume.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.htmlresume.entity.ResumeModule;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface ResumeModuleMapper extends BaseMapper<ResumeModule> {

    /**
     * Query modules by resume_id with config info
     */
    List<Map<String, Object>> selectModulesWithConfig(@Param("resumeId") Long resumeId);

    /**
     * Batch update sort_order
     */
    int batchUpdateSortOrder(@Param("list") List<Map<String, Object>> updates);
}
