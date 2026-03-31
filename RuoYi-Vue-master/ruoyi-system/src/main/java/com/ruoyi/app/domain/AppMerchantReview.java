package com.ruoyi.app.domain;

import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 商家评价对象 app_merchant_review。
 *
 * @author ruoyi
 */
public class AppMerchantReview extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long reviewId;

    private Long merchantId;

    private Long accessoryOrderId;

    private Long appUserId;

    private Integer rating;

    private String reviewContent;

    private String userName;

    private String avatar;

    private String accessoryName;

    public Long getReviewId()
    {
        return reviewId;
    }

    public void setReviewId(Long reviewId)
    {
        this.reviewId = reviewId;
    }

    public Long getMerchantId()
    {
        return merchantId;
    }

    public void setMerchantId(Long merchantId)
    {
        this.merchantId = merchantId;
    }

    public Long getAccessoryOrderId()
    {
        return accessoryOrderId;
    }

    public void setAccessoryOrderId(Long accessoryOrderId)
    {
        this.accessoryOrderId = accessoryOrderId;
    }

    public Long getAppUserId()
    {
        return appUserId;
    }

    public void setAppUserId(Long appUserId)
    {
        this.appUserId = appUserId;
    }

    public Integer getRating()
    {
        return rating;
    }

    public void setRating(Integer rating)
    {
        this.rating = rating;
    }

    public String getReviewContent()
    {
        return reviewContent;
    }

    public void setReviewContent(String reviewContent)
    {
        this.reviewContent = reviewContent;
    }

    public String getUserName()
    {
        return userName;
    }

    public void setUserName(String userName)
    {
        this.userName = userName;
    }

    public String getAvatar()
    {
        return avatar;
    }

    public void setAvatar(String avatar)
    {
        this.avatar = avatar;
    }

    public String getAccessoryName()
    {
        return accessoryName;
    }

    public void setAccessoryName(String accessoryName)
    {
        this.accessoryName = accessoryName;
    }

    @Override
    public String toString()
    {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
            .append("reviewId", getReviewId())
            .append("merchantId", getMerchantId())
            .append("accessoryOrderId", getAccessoryOrderId())
            .append("appUserId", getAppUserId())
            .append("rating", getRating())
            .append("reviewContent", getReviewContent())
            .append("userName", getUserName())
            .append("avatar", getAvatar())
            .append("accessoryName", getAccessoryName())
            .append("createBy", getCreateBy())
            .append("createTime", getCreateTime())
            .append("updateBy", getUpdateBy())
            .append("updateTime", getUpdateTime())
            .append("remark", getRemark())
            .toString();
    }
}
