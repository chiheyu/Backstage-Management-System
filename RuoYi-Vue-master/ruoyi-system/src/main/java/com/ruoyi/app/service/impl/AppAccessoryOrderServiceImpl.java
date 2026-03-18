package com.ruoyi.app.service.impl;

import java.math.BigDecimal;
import java.util.List;
import java.util.Random;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.app.domain.AppAccessory;
import com.ruoyi.app.domain.AppAccessoryOrder;
import com.ruoyi.app.domain.AppConstants;
import com.ruoyi.app.domain.AppUser;
import com.ruoyi.app.domain.bo.AppAccessoryOrderSubmitBody;
import com.ruoyi.app.mapper.AppAccessoryMapper;
import com.ruoyi.app.mapper.AppAccessoryOrderMapper;
import com.ruoyi.app.service.IAppAccessoryOrderService;
import com.ruoyi.app.service.IAppAuthService;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;

/**
 * 配件订单服务实现。
 *
 * <p>库存扣减与订单落库放在一个事务中，避免库存与订单不一致。</p>
 *
 * @author ruoyi
 */
@Service
public class AppAccessoryOrderServiceImpl implements IAppAccessoryOrderService
{
    @Autowired
    private AppAccessoryOrderMapper accessoryOrderMapper;

    @Autowired
    private AppAccessoryMapper accessoryMapper;

    @Autowired
    private IAppAuthService appAuthService;

    @Override
    public AppAccessoryOrder selectAccessoryOrderById(Long accessoryOrderId)
    {
        return accessoryOrderMapper.selectAccessoryOrderById(accessoryOrderId);
    }

    @Override
    public List<AppAccessoryOrder> selectAccessoryOrderList(AppAccessoryOrder order)
    {
        return accessoryOrderMapper.selectAccessoryOrderList(order);
    }

    /**
     * 创建配件订单。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public AppAccessoryOrder createOrder(AppAccessoryOrderSubmitBody submitBody)
    {
        if (StringUtils.isNull(submitBody) || StringUtils.isNull(submitBody.getAccessoryId()) || StringUtils.isNull(submitBody.getQuantity()))
        {
            throw new ServiceException("下单参数不完整");
        }
        if (submitBody.getQuantity() <= 0)
        {
            throw new ServiceException("购买数量必须大于 0");
        }

        AppAccessory accessory = accessoryMapper.selectAccessoryById(submitBody.getAccessoryId());
        if (StringUtils.isNull(accessory))
        {
            throw new ServiceException("配件不存在");
        }
        if (!AppConstants.ACCESSORY_ON_SHELF.equals(accessory.getStatus()))
        {
            throw new ServiceException("当前配件未上架");
        }
        if (StringUtils.isNull(accessory.getStock()) || accessory.getStock() < submitBody.getQuantity())
        {
            throw new ServiceException("配件库存不足");
        }

        AppUser currentUser = appAuthService.getCurrentAppUser();
        AppAccessoryOrder order = new AppAccessoryOrder();
        order.setOrderNo(generateOrderNo());
        order.setAccessoryId(accessory.getAccessoryId());
        order.setAppUserId(currentUser.getAppUserId());
        order.setQuantity(submitBody.getQuantity());
        order.setPrice(accessory.getPrice());
        order.setTotalAmount(accessory.getPrice().multiply(BigDecimal.valueOf(submitBody.getQuantity())));
        order.setStatus(AppConstants.ACCESSORY_ORDER_PENDING);
        order.setReceiverName(submitBody.getReceiverName());
        order.setReceiverPhone(submitBody.getReceiverPhone());
        order.setReceiverAddress(submitBody.getReceiverAddress());
        order.setOrderRemark(submitBody.getOrderRemark());
        order.setCreateBy(SecurityUtils.getUsername());
        accessoryOrderMapper.insertAccessoryOrder(order);

        accessory.setStock(accessory.getStock() - submitBody.getQuantity());
        accessory.setSalesCount((StringUtils.isNull(accessory.getSalesCount()) ? 0L : accessory.getSalesCount()) + submitBody.getQuantity());
        accessory.setUpdateBy(SecurityUtils.getUsername());
        accessoryMapper.updateAccessory(accessory);
        return accessoryOrderMapper.selectAccessoryOrderById(order.getAccessoryOrderId());
    }

    @Override
    public int updateAccessoryOrder(AppAccessoryOrder order)
    {
        order.setUpdateBy(SecurityUtils.getUsername());
        return accessoryOrderMapper.updateAccessoryOrder(order);
    }

    /**
     * 生成配件订单号。
     */
    private String generateOrderNo()
    {
        return "AO" + DateUtils.dateTimeNow("yyyyMMddHHmmss") + StringUtils.leftPad(String.valueOf(new Random().nextInt(10000)), 4, "0");
    }
}
