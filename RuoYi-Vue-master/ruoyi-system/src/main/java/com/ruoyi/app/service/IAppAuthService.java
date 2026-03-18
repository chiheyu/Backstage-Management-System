package com.ruoyi.app.service;

import com.ruoyi.app.domain.AppUser;
import com.ruoyi.app.domain.bo.AppLoginBody;
import com.ruoyi.app.domain.bo.AppRegisterBody;
import com.ruoyi.app.domain.vo.AppLoginVo;

/**
 * App 认证服务接口。
 *
 * @author ruoyi
 */
public interface IAppAuthService
{
    public String sendRegisterCode(String phone);

    public AppLoginVo register(AppRegisterBody registerBody);

    public AppLoginVo login(AppLoginBody loginBody);

    public AppUser getCurrentAppUser();
}
