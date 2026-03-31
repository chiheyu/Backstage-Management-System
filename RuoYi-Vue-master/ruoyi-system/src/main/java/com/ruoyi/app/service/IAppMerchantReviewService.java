package com.ruoyi.app.service;

import java.util.List;
import com.ruoyi.app.domain.AppMerchantReview;
import com.ruoyi.app.domain.bo.AppMerchantReviewSubmitBody;

/**
 * 商家评价服务接口。
 *
 * @author ruoyi
 */
public interface IAppMerchantReviewService
{
    public List<AppMerchantReview> selectMerchantReviewList(AppMerchantReview review);

    public AppMerchantReview createReview(AppMerchantReviewSubmitBody submitBody);
}
