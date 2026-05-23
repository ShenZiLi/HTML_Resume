package com.htmlresume.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MybatisPlusConfig {
    // TODO: Add MyBatis-Plus interceptor configuration once PaginationInnerInterceptor is available
    // The class is not included in MyBatis-Plus 3.5.9 extension jar
    // This is a known issue with the version - may need to upgrade or use a different pagination approach
}
