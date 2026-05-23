package com.htmlresume.controller;

import com.htmlresume.common.Result;
import com.htmlresume.entity.User;
import com.htmlresume.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
public class UserController {

    @Autowired
    private UserService userService;

    @PostMapping("/init")
    public Result<User> initUser(@RequestHeader("X-Device-Id") String deviceId) {
        User user = userService.initOrCreateUser(deviceId);
        return Result.success(user);
    }

    @GetMapping("/me")
    public Result<User> getCurrentUser(@RequestHeader("X-Device-Id") String deviceId) {
        User user = userService.getByDeviceId(deviceId);
        return user != null ? Result.success(user) : Result.error("User not found");
    }
}