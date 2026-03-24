package com.ruoyi.app.service.impl;

import java.util.Date;
import java.util.List;
import java.util.Random;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.app.domain.AppAfterSalesOrder;
import com.ruoyi.app.domain.AppConstants;
import com.ruoyi.app.domain.AppMerchant;
import com.ruoyi.app.domain.AppUser;
import com.ruoyi.app.domain.bo.AppOrderActionBody;
import com.ruoyi.app.mapper.AppAfterSalesOrderMapper;
import com.ruoyi.app.service.IAppAfterSalesOrderService;
import com.ruoyi.app.service.IAppAuthService;
import com.ruoyi.app.service.IAppMerchantService;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;

/**
 * 售后订单服务实现。
 *
 * @author ruoyi
 */
@Service
public class AppAfterSalesOrderServiceImpl implements IAppAfterSalesOrderService
{
    @Autowired
    private AppAfterSalesOrderMapper afterSalesOrderMapper;

    @Autowired
    private IAppAuthService appAuthService;

    @Autowired
    private IAppMerchantService merchantService;

    @Override
    public AppAfterSalesOrder selectAfterSalesOrderById(Long orderId)
    {
        return afterSalesOrderMapper.selectAfterSalesOrderById(orderId);
    }

    @Override
    public List<AppAfterSalesOrder> selectAfterSalesOrderList(AppAfterSalesOrder order)
    {
        return afterSalesOrderMapper.selectAfterSalesOrderList(order);
    }

    /**
     * 用户提交售后单时，状态固定为待接单。
     */
    @Override
    public int insertAfterSalesOrder(AppAfterSalesOrder order)
    {
        AppUser currentUser = appAuthService.getCurrentAppUser();
        order.setAppUserId(currentUser.getAppUserId());
        order.setStatus(AppConstants.AFTER_SALES_WAIT_ACCEPT);
        order.setOrderNo(generateOrderNo("AS"));
        order.setCreateBy(SecurityUtils.getUsername());
        return afterSalesOrderMapper.insertAfterSalesOrder(order);
    }

    @Override
    public int updateAfterSalesOrder(AppAfterSalesOrder order)
    {
        order.setUpdateBy(SecurityUtils.getUsername());
        return afterSalesOrderMapper.updateAfterSalesOrder(order);
    }

    /**
     * 商家接单。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int takeOrder(Long orderId)
    {
        AppAfterSalesOrder order = selectAfterSalesOrderById(orderId);
        if (StringUtils.isNull(order))
        {
            throw new ServiceException("售后订单不存在");
        }
        if (!AppConstants.AFTER_SALES_WAIT_ACCEPT.equals(order.getStatus()))
        {
            throw new ServiceException("当前订单状态不允许接单");
        }

        AppMerchant merchant = merchantService.selectCurrentMerchant();
        order.setMerchantId(merchant.getMerchantId());
        order.setStatus(AppConstants.AFTER_SALES_ACCEPTED);
        order.setAcceptTime(DateUtils.getNowDate());
        order.setUpdateBy(SecurityUtils.getUsername());
        return afterSalesOrderMapper.updateAfterSalesOrder(order);
    }

    /**
     * 更新售后单状态。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int updateOrderStatus(AppOrderActionBody actionBody)
    {
        AppAfterSalesOrder order = selectAfterSalesOrderById(actionBody.getOrderId());
        if (StringUtils.isNull(order))
        {
            throw new ServiceException("售后订单不存在");
        }
        validateOrderOperator(order);
        validateStatusTransition(order.getStatus(), actionBody.getStatus());
        validateServiceRemark(actionBody);

        order.setStatus(actionBody.getStatus());
        order.setServiceRemark(actionBody.getServiceRemark());
        order.setUpdateBy(SecurityUtils.getUsername());
        if (AppConstants.AFTER_SALES_COMPLETED.equals(actionBody.getStatus()))
        {
            order.setFinishTime(new Date());
        }
        return afterSalesOrderMapper.updateAfterSalesOrder(order);
    }

    /**
     * 用户或商家取消订单。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int cancelOrder(Long orderId)
    {
        AppAfterSalesOrder order = selectAfterSalesOrderById(orderId);
        if (StringUtils.isNull(order))
        {
            throw new ServiceException("售后订单不存在");
        }
        validateOrderOperator(order);
        if (AppConstants.AFTER_SALES_COMPLETED.equals(order.getStatus())
            || AppConstants.AFTER_SALES_CANCELED.equals(order.getStatus()))
        {
            throw new ServiceException("当前订单不能取消");
        }
        order.setStatus(AppConstants.AFTER_SALES_CANCELED);
        order.setUpdateBy(SecurityUtils.getUsername());
        return afterSalesOrderMapper.updateAfterSalesOrder(order);
    }

    /**
     * 生成售后业务单号。
     */
    private String generateOrderNo(String prefix)
    {
        return prefix + DateUtils.dateTimeNow("yyyyMMddHHmmss") + StringUtils.leftPad(String.valueOf(new Random().nextInt(10000)), 4, "0");
    }

    /**
     * 校验当前用户是否有权限操作该订单。
     */
    private void validateOrderOperator(AppAfterSalesOrder order)
    {
        Long sysUserId = SecurityUtils.getUserId();
        if (SysUserHelper.isAdmin(sysUserId))
        {
            return;
        }

        AppUser currentUser = appAuthService.getCurrentAppUser();
        if (StringUtils.equals(currentUser.getRoleType(), AppConstants.ROLE_USER))
        {
            if (!currentUser.getAppUserId().equals(order.getAppUserId()))
            {
                throw new ServiceException("无权操作他人的售后订单");
            }
            return;
        }

        AppMerchant merchant = merchantService.selectCurrentMerchant();
        if (StringUtils.isNull(order.getMerchantId()) || !merchant.getMerchantId().equals(order.getMerchantId()))
        {
            throw new ServiceException("当前商家无权操作该订单");
        }
    }

    /**
     * 校验订单状态流转。
     */
    private void validateStatusTransition(String oldStatus, String newStatus)
    {
        if (AppConstants.AFTER_SALES_WAIT_ACCEPT.equals(oldStatus)
            && !AppConstants.AFTER_SALES_ACCEPTED.equals(newStatus)
            && !AppConstants.AFTER_SALES_CANCELED.equals(newStatus))
        {
            throw new ServiceException("待接单状态只能变更为已接单或已取消");
        }
        if (AppConstants.AFTER_SALES_ACCEPTED.equals(oldStatus)
            && !AppConstants.AFTER_SALES_REPAIRING.equals(newStatus)
            && !AppConstants.AFTER_SALES_CANCELED.equals(newStatus))
        {
            throw new ServiceException("已接单状态只能变更为维修中或已取消");
        }
        if (AppConstants.AFTER_SALES_REPAIRING.equals(oldStatus)
            && !AppConstants.AFTER_SALES_COMPLETED.equals(newStatus)
            && !AppConstants.AFTER_SALES_CANCELED.equals(newStatus))
        {
            throw new ServiceException("维修中状态只能变更为已完成或已取消");
        }
    }

    /**
     * 完成订单前必须填写回执说明。
     */
    private void validateServiceRemark(AppOrderActionBody actionBody)
    {
        if (AppConstants.AFTER_SALES_COMPLETED.equals(actionBody.getStatus())
            && StringUtils.isEmpty(StringUtils.trim(actionBody.getServiceRemark())))
        {
            throw new ServiceException("请先填写售后回执说明后再完成订单");
        }
    }
}
