package com.htmlresume;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.htmlresume.mapper")
public class HtmlResumeApplication {
    public static void main(String[] args) {
        SpringApplication.run(HtmlResumeApplication.class, args);
    }
}
