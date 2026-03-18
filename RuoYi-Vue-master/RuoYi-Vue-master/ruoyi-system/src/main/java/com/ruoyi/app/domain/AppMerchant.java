package com.ruoyi.app.domain;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 商家信息对象 app_merchant。
 *
 * @author ruoyi
 */
public class AppMerchant extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 商家主键。 */
    private Long merchantId;

    /** 关联 App 用户。 */
    private Long appUserId;

    /** 关联若依用户。 */
    private Long sysUserId;

    /** 商家名称。 */
    @Excel(name = "商家名称")
    private String merchantName;

    /** 联系人。 */
    @Excel(name = "联系人")
    private String contactName;

    /** 联系电话。 */
    @Excel(name = "联系电话")
    private String contactPhone;

    /** 地址。 */
    @Excel(name = "地址")
    private String address;

    /** 服务范围。 */
    @Excel(name = "服务范围")
    private String serviceScope;

    /** 商家简介。 */
    private String merchantDesc;

    /** 所在城市。 */
    @Excel(name = "城市")
    private String cityName;

    /** 审核状态：0 待审核，1 正常，2 禁用。 */
    @Excel(name = "审核状态")
    private String auditStatus;

    /** 登录账号。 */
    @Excel(name = "登录账号")
    private String userName;

    public Long getMerchantId()
    {
        return merchantId;
    }

    public void setMerchantId(Long merchantId)
    {
        this.merchantId = merchantId;
    }

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

    public String getContactPhone()
    {
        return contactPhone;
    }

    public void setContactPhone(String contactPhone)
    {
        this.contactPhone = contactPhone;
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

    public String getMerchantDesc()
    {
        return merchantDesc;
    }

    public void setMerchantDesc(String merchantDesc)
    {
        this.merchantDesc = merchantDesc;
    }

    public String getCityName()
    {
        return cityName;
    }

    public void setCityName(String cityName)
    {
        this.cityName = cityName;
    }

    public String getAuditStatus()
    {
        return auditStatus;
    }

    public void setAuditStatus(String auditStatus)
    {
        this.auditStatus = auditStatus;
    }

    public String getUserName()
    {
        return userName;
    }

    public void setUserName(String userName)
    {
        this.userName = userName;
    }

    @Override
    public String toString()
    {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
            .append("merchantId", getMerchantId())
            .append("appUserId", getAppUserId())
            .append("sysUserId", getSysUserId())
            .append("merchantName", getMerchantName())
            .append("contactName", getContactName())
            .append("contactPhone", getContactPhone())
            .append("address", getAddress())
            .append("serviceScope", getServiceScope())
            .append("merchantDesc", getMerchantDesc())
            .append("cityName", getCityName())
            .append("auditStatus", getAuditStatus())
            .append("userName", getUserName())
            .append("createBy", getCreateBy())
            .append("createTime", getCreateTime())
            .append("updateBy", getUpdateBy())
            .append("updateTime", getUpdateTime())
            .append("remark", getRemark())
            .toString();
    }
}
