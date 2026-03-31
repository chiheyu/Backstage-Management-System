package com.ruoyi.app.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.app.domain.AppAccessoryOrder;
import com.ruoyi.app.domain.AppConstants;
import com.ruoyi.app.domain.AppMerchantReview;
import com.ruoyi.app.domain.AppUser;
import com.ruoyi.app.domain.bo.AppMerchantReviewSubmitBody;
import com.ruoyi.app.mapper.AppMerchantReviewMapper;
import com.ruoyi.app.service.IAppAccessoryOrderService;
import com.ruoyi.app.service.IAppAuthService;
import com.ruoyi.app.service.IAppMerchantReviewService;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;

/**
 * 商家评价服务实现。
 *
 * @author ruoyi
 */
@Service
public class AppMerchantReviewServiceImpl implements IAppMerchantReviewService
{
    @Autowired
    private AppMerchantReviewMapper merchantReviewMapper;

    @Autowired
    private IAppAccessoryOrderService accessoryOrderService;

    @Autowired
    private IAppAuthService appAuthService;

    @Override
    public List<AppMerchantReview> selectMerchantReviewList(AppMerchantReview review)
    {
        return merchantReviewMapper.selectMerchantReviewList(review);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public AppMerchantReview createReview(AppMerchantReviewSubmitBody submitBody)
    {
        validateSubmitBody(submitBody);

        AppUser currentUser = appAuthService.getCurrentAppUser();
        AppAccessoryOrder order = accessoryOrderService.selectAccessoryOrderById(submitBody.getAccessoryOrderId());
        if (StringUtils.isNull(order))
        {
            throw new ServiceException("配件订单不存在");
        }
        if (!currentUser.getAppUserId().equals(order.getAppUserId()))
        {
            throw new ServiceException("无权评价他人的订单");
        }
        if (!AppConstants.ACCESSORY_ORDER_COMPLETED.equals(order.getStatus()))
        {
            throw new ServiceException("只有已完成订单才可评价");
        }
        if (StringUtils.isNull(order.getMerchantId()))
        {
            throw new ServiceException("当前订单未绑定商家，无法评价");
        }
        if (StringUtils.isNotNull(merchantReviewMapper.selectReviewByAccessoryOrderId(order.getAccessoryOrderId())))
        {
            throw new ServiceException("该订单已评价，不能重复提交");
        }

        AppMerchantReview review = new AppMerchantReview();
        review.setMerchantId(order.getMerchantId());
        review.setAccessoryOrderId(order.getAccessoryOrderId());
        review.setAppUserId(currentUser.getAppUserId());
        review.setRating(normalizeRating(submitBody.getRating()));
        review.setReviewContent(StringUtils.trim(submitBody.getReviewContent()));
        review.setCreateBy(SecurityUtils.getUsername());
        merchantReviewMapper.insertMerchantReview(review);
        return merchantReviewMapper.selectReviewByAccessoryOrderId(order.getAccessoryOrderId());
    }

    private void validateSubmitBody(AppMerchantReviewSubmitBody submitBody)
    {
        if (StringUtils.isNull(submitBody) || StringUtils.isNull(submitBody.getAccessoryOrderId()))
        {
            throw new ServiceException("评价参数不完整");
        }
        if (StringUtils.isEmpty(StringUtils.trim(submitBody.getReviewContent())))
        {
            throw new ServiceException("请先填写评价内容");
        }
    }

    private Integer normalizeRating(Integer rating)
    {
        if (rating == null || rating <= 0)
        {
            return 5;
        }
        return Math.min(rating, 5);
    }
}
