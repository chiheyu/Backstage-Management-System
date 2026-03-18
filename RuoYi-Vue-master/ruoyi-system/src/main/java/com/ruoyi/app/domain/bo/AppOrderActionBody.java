package com.ruoyi.app.domain.bo;

/**
 * 售后订单状态更新请求体。
 *
 * @author ruoyi
 */
public class AppOrderActionBody
{
    /** 售后订单 ID。 */
    private Long orderId;

    /** 目标状态。 */
    private String status;

    /** 处理备注。 */
    private String serviceRemark;

    public Long getOrderId()
    {
        return orderId;
    }

    public void setOrderId(Long orderId)
    {
        this.orderId = orderId;
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
}
