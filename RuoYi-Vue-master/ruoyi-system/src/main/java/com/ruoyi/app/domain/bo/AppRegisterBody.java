package com.ruoyi.app.domain.bo;

/**
 * App 注册请求体。
 *
 * @author ruoyi
 */
public class AppRegisterBody
{
    /** 手机号。 */
    private String phone;

    /** 登录密码。 */
    private String password;

    /** 确认密码。 */
    private String confirmPassword;

    /** 昵称。 */
    private String nickName;

    /** 模拟验证码。 */
    private String code;

    /** 注册角色：1 用户，2 商家。 */
    private String roleType;

    /** 商家名称。 */
    private String merchantName;

    /** 联系人。 */
    private String contactName;

    /** 联系地址。 */
    private String address;

    /** 服务范围。 */
    private String serviceScope;

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

    public String getConfirmPassword()
    {
        return confirmPassword;
    }

    public void setConfirmPassword(String confirmPassword)
    {
        this.confirmPassword = confirmPassword;
    }

    public String getNickName()
    {
        return nickName;
    }

    public void setNickName(String nickName)
    {
        this.nickName = nickName;
    }

    public String getCode()
    {
        return code;
    }

    public void setCode(String code)
    {
        this.code = code;
    }

    public String getRoleType()
    {
        return roleType;
    }

    public void setRoleType(String roleType)
    {
        this.roleType = roleType;
    }

    public String getMerchantName()
    {
        return merchantName;
    }

    public void setMerchantName(String merchantName)
    {
        this.merchantName = merchantName;
    }

    public String getContactName()
    {
        return contactName;
    }

    public void setContactName(String contactName)
    {
        this.contactName = contactName;
    }

    public String getAddress()
    {
        return address;
    }

    public void setAddress(String address)
    {
        this.address = address;
    }

    public String getServiceScope()
    {
        return serviceScope;
    }

    public void setServiceScope(String serviceScope)
    {
        this.serviceScope = serviceScope;
    }
}
