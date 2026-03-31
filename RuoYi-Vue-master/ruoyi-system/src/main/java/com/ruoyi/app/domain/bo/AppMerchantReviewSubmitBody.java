package com.ruoyi.app.domain.bo;

/**
 * 商家评价提交参数。
 *
 * @author ruoyi
 */
public class AppMerchantReviewSubmitBody
{
    private Long accessoryOrderId;

    private Integer rating;

    private String reviewContent;

    public Long getAccessoryOrderId()
    {
        return accessoryOrderId;
    }

    public void setAccessoryOrderId(Long accessoryOrderId)
    {
        this.accessoryOrderId = accessoryOrderId;
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
}
