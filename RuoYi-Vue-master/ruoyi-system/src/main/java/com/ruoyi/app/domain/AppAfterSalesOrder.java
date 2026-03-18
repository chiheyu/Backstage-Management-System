package com.ruoyi.app.domain;

import java.util.Date;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 售后订单对象 app_after_sales_order。
 *
 * @author ruoyi
 */
public class AppAfterSalesOrder extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 主键。 */
    private Long orderId;

    /** 业务单号。 */
    @Excel(name = "订单编号")
    private String orderNo;

    /** 提交订单的 App 用户。 */
    private Long appUserId;

    /** 接单商家。 */
    private Long merchantId;

    /** 产品类型。 */
    @Excel(name = "产品类型")
    private String productType;

    /** 故障描述。 */
    private String faultDesc;

    /** 图片列表，使用逗号分隔。 */
    private String faultImages;

    /** 状态。 */
    @Excel(name = "状态")
    private String status;

    /** 处理备注。 */
    private String serviceRemark;

    /** 联系人。 */
    @Excel(name = "联系人")
    private String contactName;

    /** 联系方式。 */
    @Excel(name = "联系电话")
    private String contactPhone;

    /** 服务地址。 */
    @Excel(name = "服务地址")
    private String address;

    /** 接单时间。 */
    private Date acceptTime;

    /** 完成时间。 */
    private Date finishTime;

    /** 用户昵称。 */
    @Excel(name = "用户")
    private String userName;

    /** 商家名称。 */
    @Excel(name = "商家")
    private String merchantName;

    public Long getOrderId()
    {
        return orderId;
    }

    public void setOrderId(Long orderId)
    {
        this.orderId = orderId;
    }

    public String getOrderNo()
    {
        return orderNo;
    }

    public void setOrderNo(String orderNo)
    {
        this.orderNo = orderNo;
    }

    public Long getAppUserId()
    {
        return appUserId;
    }

    public void setAppUserId(Long appUserId)
    {
        this.appUserId = appUserId;
    }

    public Long getMerchantId()
    {
        return merchantId;
    }

    public void setMerchantId(Long merchantId)
    {
        this.merchantId = merchantId;
    }

    public String getProductType()
    {
        return productType;
    }

    public void setProductType(String productType)
    {
        this.productType = productType;
    }

    public String getFaultDesc()
    {
        return faultDesc;
    }

    public void setFaultDesc(String faultDesc)
    {
        this.faultDesc = faultDesc;
    }

    public String getFaultImages()
    {
        return faultImages;
    }

    public void setFaultImages(String faultImages)
    {
        this.faultImages = faultImages;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getServiceRemark()
    {
        return serviceRemark;
    }

    public void setServiceRemark(String serviceRemark)
    {
        this.serviceRemark = serviceRemark;
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

    public Date getAcceptTime()
    {
        return acceptTime;
    }

    public void setAcceptTime(Date acceptTime)
    {
        this.acceptTime = acceptTime;
    }

    public Date getFinishTime()
    {
        return finishTime;
    }

    public void setFinishTime(Date finishTime)
    {
        this.finishTime = finishTime;
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
            .append("orderId", getOrderId())
            .append("orderNo", getOrderNo())
            .append("appUserId", getAppUserId())
            .append("merchantId", getMerchantId())
            .append("productType", getProductType())
            .append("faultDesc", getFaultDesc())
            .append("faultImages", getFaultImages())
            .append("status", getStatus())
            .append("serviceRemark", getServiceRemark())
            .append("contactName", getContactName())
            .append("contactPhone", getContactPhone())
            .append("address", getAddress())
            .append("acceptTime", getAcceptTime())
            .append("finishTime", getFinishTime())
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
