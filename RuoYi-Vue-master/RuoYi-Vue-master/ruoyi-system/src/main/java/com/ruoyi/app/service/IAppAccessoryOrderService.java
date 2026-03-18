package com.ruoyi.app.service;

import java.util.List;
import com.ruoyi.app.domain.AppAccessoryOrder;
import com.ruoyi.app.domain.bo.AppAccessoryOrderSubmitBody;

/**
 * 配件订单服务接口。
 *
 * @author ruoyi
 */
public interface IAppAccessoryOrderService
{
    public AppAccessoryOrder selectAccessoryOrderById(Long accessoryOrderId);

    public List<AppAccessoryOrder> selectAccessoryOrderList(AppAccessoryOrder order);

    public AppAccessoryOrder createOrder(AppAccessoryOrderSubmitBody submitBody);

    public int updateAccessoryOrder(AppAccessoryOrder order);
}
