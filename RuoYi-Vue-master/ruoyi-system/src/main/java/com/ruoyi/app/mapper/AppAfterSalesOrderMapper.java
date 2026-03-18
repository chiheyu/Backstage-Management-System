package com.ruoyi.app.mapper;

import java.util.List;
import com.ruoyi.app.domain.AppAfterSalesOrder;

/**
 * 售后订单 Mapper。
 *
 * @author ruoyi
 */
public interface AppAfterSalesOrderMapper
{
    public AppAfterSalesOrder selectAfterSalesOrderById(Long orderId);

    public List<AppAfterSalesOrder> selectAfterSalesOrderList(AppAfterSalesOrder order);

    public int insertAfterSalesOrder(AppAfterSalesOrder order);

    public int updateAfterSalesOrder(AppAfterSalesOrder order);

    public int deleteAfterSalesOrderById(Long orderId);
}
