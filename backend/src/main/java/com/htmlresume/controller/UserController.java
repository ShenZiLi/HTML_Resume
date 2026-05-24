package com.htmlresume.controller;

import com.htmlresume.common.Result;
import com.htmlresume.entity.User;
import com.htmlresume.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

// 暂未实现用户注册登录功能
@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    @Autowired
    private UserService userService;

    @GetMapping("/me")
    public Result<User> getCurrentUser(@RequestHeader("X-User-Id") Long userId) {
        User user = userService.getById(userId);
        return user != null ? Result.success(user) : Result.error("User not found");
    }
}