package com.ruoyi.app.mapper;

import java.util.List;
import com.ruoyi.app.domain.AppMerchantReview;

/**
 * 商家评价 Mapper。
 *
 * @author ruoyi
 */
public interface AppMerchantReviewMapper
{
    public AppMerchantReview selectReviewByAccessoryOrderId(Long accessoryOrderId);

    public List<AppMerchantReview> selectMerchantReviewList(AppMerchantReview review);

    public int insertMerchantReview(AppMerchantReview review);
}
