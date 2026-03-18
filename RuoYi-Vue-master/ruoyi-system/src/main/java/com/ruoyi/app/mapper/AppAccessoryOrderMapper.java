package com.ruoyi.app.mapper;

import java.util.List;
import com.ruoyi.app.domain.AppAccessoryOrder;

/**
 * 配件订单 Mapper。
 *
 * @author ruoyi
 */
public interface AppAccessoryOrderMapper
{
    public AppAccessoryOrder selectAccessoryOrderById(Long accessoryOrderId);

    public List<AppAccessoryOrder> selectAccessoryOrderList(AppAccessoryOrder order);

    public int insertAccessoryOrder(AppAccessoryOrder order);

    public int updateAccessoryOrder(AppAccessoryOrder order);
}
