package com.ruoyi.app.domain;

import java.math.BigDecimal;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 配件订单对象 app_accessory_order。
 *
 * @author ruoyi
 */
public class AppAccessoryOrder extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 主键。 */
    private Long accessoryOrderId;

    /** 订单号。 */
    @Excel(name = "订单编号")
    private String orderNo;

    /** 配件 ID。 */
    private Long accessoryId;

    /** 下单用户。 */
    private Long appUserId;

    /** 归属商家 ID。 */
    private Long merchantId;

    /** 数量。 */
    @Excel(name = "数量")
    private Long quantity;

    /** 单价。 */
    @Excel(name = "单价")
    private BigDecimal price;

    /** 总金额。 */
    @Excel(name = "总金额")
    private BigDecimal totalAmount;

    /** 状态。 */
    @Excel(name = "状态")
    private String status;

    /** 收货人。 */
    @Excel(name = "收货人")
    private String receiverName;

    /** 收货电话。 */
    @Excel(name = "联系电话")
    private String receiverPhone;

    /** 收货地址。 */
    @Excel(name = "收货地址")
    private String receiverAddress;

    /** 订单备注。 */
    private String orderRemark;

    /** 配件名称。 */
    @Excel(name = "配件名称")
    private String accessoryName;

    /** 配件图片。 */
    private String coverImage;

    /** 用户名称。 */
    @Excel(name = "下单用户")
    private String userName;

    /** 商家名称。 */
    private String merchantName;

    /** 是否已评价。 */
    private Boolean reviewed;

    public Long getAccessoryOrderId()
    {
        return accessoryOrderId;
    }

    public void setAccessoryOrderId(Long accessoryOrderId)
    {
        this.accessoryOrderId = accessoryOrderId;
    }

    public String getOrderNo()
    {
        return orderNo;
    }

    public void setOrderNo(String orderNo)
    {
        this.orderNo = orderNo;
    }

    public Long getAccessoryId()
    {
        return accessoryId;
    }

    public void setAccessoryId(Long accessoryId)
    {
        this.accessoryId = accessoryId;
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

    public Long getQuantity()
    {
        return quantity;
    }

    public void setQuantity(Long quantity)
    {
        this.quantity = quantity;
    }

    public BigDecimal getPrice()
    {
        return price;
    }

    public void setPrice(BigDecimal price)
    {
        this.price = price;
    }

    public BigDecimal getTotalAmount()
    {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount)
    {
        this.totalAmount = totalAmount;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public String getReceiverName()
    {
        return receiverName;
    }

    public void setReceiverName(String receiverName)
    {
        this.receiverName = receiverName;
    }

    public String getReceiverPhone()
    {
        return receiverPhone;
    }

    public void setReceiverPhone(String receiverPhone)
    {
        this.receiverPhone = receiverPhone;
    }

    public String getReceiverAddress()
    {
        return receiverAddress;
    }

    public void setReceiverAddress(String receiverAddress)
    {
        this.receiverAddress = receiverAddress;
    }

    public String getOrderRemark()
    {
        return orderRemark;
    }

    public void setOrderRemark(String orderRemark)
    {
        this.orderRemark = orderRemark;
    }

    public String getAccessoryName()
    {
        return accessoryName;
    }

    public void setAccessoryName(String accessoryName)
    {
        this.accessoryName = accessoryName;
    }

    public String getCoverImage()
    {
        return coverImage;
    }

    public void setCoverImage(String coverImage)
    {
        this.coverImage = coverImage;
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

    public Boolean getReviewed()
    {
        return reviewed;
    }

    public void setReviewed(Boolean reviewed)
    {
        this.reviewed = reviewed;
    }

    @Override
    public String toString()
    {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
            .append("accessoryOrderId", getAccessoryOrderId())
            .append("orderNo", getOrderNo())
            .append("accessoryId", getAccessoryId())
            .append("appUserId", getAppUserId())
            .append("merchantId", getMerchantId())
            .append("quantity", getQuantity())
            .append("price", getPrice())
            .append("totalAmount", getTotalAmount())
            .append("status", getStatus())
            .append("receiverName", getReceiverName())
            .append("receiverPhone", getReceiverPhone())
            .append("receiverAddress", getReceiverAddress())
            .append("orderRemark", getOrderRemark())
            .append("accessoryName", getAccessoryName())
            .append("coverImage", getCoverImage())
            .append("userName", getUserName())
            .append("merchantName", getMerchantName())
            .append("reviewed", getReviewed())
            .append("createBy", getCreateBy())
            .append("createTime", getCreateTime())
            .append("updateBy", getUpdateBy())
            .append("updateTime", getUpdateTime())
            .append("remark", getRemark())
            .toString();
    }
}
