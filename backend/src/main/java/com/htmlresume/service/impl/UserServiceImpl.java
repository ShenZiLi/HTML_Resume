package com.htmlresume.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.htmlresume.entity.User;
import com.htmlresume.mapper.UserMapper;
import com.htmlresume.service.UserService;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    @Override
    public User initOrCreateUser(String deviceId) {
        User existingUser = getByDeviceId(deviceId);
        if (existingUser != null) {
            return existingUser;
        }

        User newUser = User.builder()
                .deviceId(deviceId)
                .createdAt(LocalDateTime.now())
                .updatedAt(LocalDateTime.now())
                .build();
        save(newUser);
        return newUser;
    }

    @Override
    public User getByDeviceId(String deviceId) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getDeviceId, deviceId);
        wrapper.last("LIMIT 1");
        return getOne(wrapper);
    }
}
