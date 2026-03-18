package com.ruoyi.app.service;

import java.util.List;
import com.ruoyi.app.domain.AppAfterSalesOrder;
import com.ruoyi.app.domain.bo.AppOrderActionBody;

/**
 * 售后订单服务接口。
 *
 * @author ruoyi
 */
public interface IAppAfterSalesOrderService
{
    public AppAfterSalesOrder selectAfterSalesOrderById(Long orderId);

    public List<AppAfterSalesOrder> selectAfterSalesOrderList(AppAfterSalesOrder order);

    public int insertAfterSalesOrder(AppAfterSalesOrder order);

    public int updateAfterSalesOrder(AppAfterSalesOrder order);

    public int takeOrder(Long orderId);

    public int updateOrderStatus(AppOrderActionBody actionBody);

    public int cancelOrder(Long orderId);
}
