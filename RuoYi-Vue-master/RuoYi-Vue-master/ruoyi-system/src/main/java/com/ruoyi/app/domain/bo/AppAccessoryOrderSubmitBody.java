package com.ruoyi.app.domain.bo;

/**
 * 配件下单请求体。
 *
 * @author ruoyi
 */
public class AppAccessoryOrderSubmitBody
{
    /** 配件 ID。 */
    private Long accessoryId;

    /** 购买数量。 */
    private Long quantity;

    /** 收货人。 */
    private String receiverName;

    /** 联系电话。 */
    private String receiverPhone;

    /** 收货地址。 */
    private String receiverAddress;

    /** 订单备注。 */
    private String orderRemark;

    public Long getAccessoryId()
    {
        return accessoryId;
    }

    public void setAccessoryId(Long accessoryId)
    {
        this.accessoryId = accessoryId;
    }

    public Long getQuantity()
    {
        return quantity;
    }

    public void setQuantity(Long quantity)
    {
        this.quantity = quantity;
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
}
