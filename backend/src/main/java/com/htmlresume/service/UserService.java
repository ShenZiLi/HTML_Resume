package com.htmlresume.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.htmlresume.entity.User;

public interface UserService extends IService<User> {

    User initOrCreateUser(String deviceId);

    User getByDeviceId(String deviceId);
}
