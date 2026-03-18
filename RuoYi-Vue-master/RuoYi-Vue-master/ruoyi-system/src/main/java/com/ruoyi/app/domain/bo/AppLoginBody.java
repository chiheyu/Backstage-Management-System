package com.ruoyi.app.domain.bo;

/**
 * App 登录请求体。
 *
 * @author ruoyi
 */
public class AppLoginBody
{
    /** 手机号。 */
    private String phone;

    /** 登录密码。 */
    private String password;

    public String getPhone()
    {
        return phone;
    }

    public void setPhone(String phone)
    {
        this.phone = phone;
    }

    public String getPassword()
    {
        return password;
    }

    public void setPassword(String password)
    {
        this.password = password;
    }
}
