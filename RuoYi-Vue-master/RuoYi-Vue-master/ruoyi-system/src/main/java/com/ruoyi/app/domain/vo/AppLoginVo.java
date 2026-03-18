package com.ruoyi.app.domain.vo;

import com.ruoyi.app.domain.AppMerchant;
import com.ruoyi.app.domain.AppUser;

/**
 * App 登录响应对象。
 *
 * @author ruoyi
 */
public class AppLoginVo
{
    /** JWT Token。 */
    private String token;

    /** 业务角色。 */
    private String roleType;

    /** 用户扩展信息。 */
    private AppUser appUser;

    /** 商家信息。 */
    private AppMerchant merchant;

    public String getToken()
    {
        return token;
    }

    public void setToken(String token)
    {
        this.token = token;
    }

    public String getRoleType()
    {
        return roleType;
    }

    public void setRoleType(String roleType)
    {
        this.roleType = roleType;
    }

    public AppUser getAppUser()
    {
        return appUser;
    }

    public void setAppUser(AppUser appUser)
    {
        this.appUser = appUser;
    }

    public AppMerchant getMerchant()
    {
        return merchant;
    }

    public void setMerchant(AppMerchant merchant)
    {
        this.merchant = merchant;
    }
}
