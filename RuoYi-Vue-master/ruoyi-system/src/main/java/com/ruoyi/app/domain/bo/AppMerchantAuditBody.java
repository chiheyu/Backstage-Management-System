package com.ruoyi.app.domain.bo;

/**
 * 商家审核请求体。
 *
 * @author ruoyi
 */
public class AppMerchantAuditBody
{
    /** 商家 ID。 */
    private Long merchantId;

    /** 审核状态。 */
    private String auditStatus;

    /** 审核备注。 */
    private String auditRemark;

    public Long getMerchantId()
    {
        return merchantId;
    }

    public void setMerchantId(Long merchantId)
    {
        this.merchantId = merchantId;
    }

    public String getAuditStatus()
    {
        return auditStatus;
    }

    public void setAuditStatus(String auditStatus)
    {
        this.auditStatus = auditStatus;
    }

    public String getAuditRemark()
    {
        return auditRemark;
    }

    public void setAuditRemark(String auditRemark)
    {
        this.auditRemark = auditRemark;
    }
}
