package com.ruoyi.app.domain;

import java.util.Date;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * App 端用户扩展信息对象 app_user。
 *
 * <p>认证仍复用若依 sys_user / sys_role / sys_user_role，
 * 本表只负责记录移动端用户与商家的业务扩展信息。</p>
 *
 * @author ruoyi
 */
public class AppUser extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 主键。 */
    private Long appUserId;

    /** 关联的若依用户 ID。 */
    private Long sysUserId;

    /** 手机号。 */
    @Excel(name = "手机号")
    private String phone;

    /** 昵称。 */
    @Excel(name = "昵称")
    private String nickName;

    /** 业务角色：1 用户、2 商家；0 仅兼容历史待审核数据。 */
    @Excel(name = "业务角色")
    private String roleType;

    /** 关联商家 ID。 */
    private Long merchantId;

    /** 状态：0 正常，1 停用。 */
    @Excel(name = "状态")
    private String status;

    /** 最近一次模拟验证码。 */
    private String lastSmsCode;

    /** 模拟验证码过期时间。 */
    private Date lastSmsExpireTime;

    /** 若依用户名。 */
    @Excel(name = "登录账号")
    private String userName;

    /** 关联商家名称。 */
    @Excel(name = "关联商家")
    private String merchantName;

    public Long getAppUserId()
    {
        return appUserId;
    }

    public void setAppUserId(Long appUserId)
    {
        this.appUserId = appUserId;
    }

    public Long getSysUserId()
    {
        return sysUserId;
    }

    public void setSysUserId(Long sysUserId)
    {
        this.sysUserId = sysUserId;
    }

    public String getPhone()
    {
        return phone;
    }

    public void setPhone(String phone)
    {
        this.phone = phone;
    }

    public String getNickName()
    {
        return nickName;
    }

    public void setNickName(String nickName)
    {
        this.nickName = nickName;
    }

    public String getRoleType()
    {
        return roleType;
    }

    public void setRoleType(String roleType)
    {
        this.roleType = roleType;
    }

    public Long getMerchantId()
    {
        return merchantId;
    }

    public void setMerchantId(Long merchantId)
    {
        this.merchantId = merchantId;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getLastSmsCode()
    {
        return lastSmsCode;
    }

    public void setLastSmsCode(String lastSmsCode)
    {
        this.lastSmsCode = lastSmsCode;
    }

    public Date getLastSmsExpireTime()
    {
        return lastSmsExpireTime;
    }

    public void setLastSmsExpireTime(Date lastSmsExpireTime)
    {
        this.lastSmsExpireTime = lastSmsExpireTime;
    }

    public String getUserName()
    {
        return userName;
    }

    public void setUserName(String userName)
    {
        this.userName = userName;
    }

    public String getMerchantName()
    {
        return merchantName;
    }

    public void setMerchantName(String merchantName)
    {
        this.merchantName = merchantName;
    }

    @Override
    public String toString()
    {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
            .append("appUserId", getAppUserId())
            .append("sysUserId", getSysUserId())
            .append("phone", getPhone())
            .append("nickName", getNickName())
            .append("roleType", getRoleType())
            .append("merchantId", getMerchantId())
            .append("status", getStatus())
            .append("lastSmsCode", getLastSmsCode())
            .append("lastSmsExpireTime", getLastSmsExpireTime())
            .append("userName", getUserName())
            .append("merchantName", getMerchantName())
            .append("createBy", getCreateBy())
            .append("createTime", getCreateTime())
            .append("updateBy", getUpdateBy())
            .append("updateTime", getUpdateTime())
            .append("remark", getRemark())
            .toString();
    }
}
