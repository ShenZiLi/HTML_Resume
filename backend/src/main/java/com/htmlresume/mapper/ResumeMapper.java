package com.htmlresume.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.htmlresume.entity.Resume;
import com.htmlresume.entity.ResumeModule;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

public interface ResumeMapper extends BaseMapper<Resume> {

    /**
     * Query resume with modules ordered by sort_order
     */
    Map<String, Object> selectResumeWithModules(@Param("resumeId") Long resumeId);

    /**
     * Query resume with style info
     */
    Map<String, Object> selectResumeWithStyle(@Param("resumeId") Long resumeId);

    /**
     * Query modules for a resume ordered by sort_order
     */
    List<ResumeModule> selectModulesByResumeId(@Param("resumeId") Long resumeId);
}
