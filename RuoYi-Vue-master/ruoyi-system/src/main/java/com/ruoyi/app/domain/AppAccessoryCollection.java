package com.ruoyi.app.domain;

import java.math.BigDecimal;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 配件收藏对象 app_accessory_collection。
 *
 * @author ruoyi
 */
public class AppAccessoryCollection extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 主键。 */
    private Long collectionId;

    /** App 用户 ID。 */
    private Long appUserId;

    /** 配件 ID。 */
    private Long accessoryId;

    /** 用户昵称。 */
    @Excel(name = "收藏用户")
    private String userName;

    /** 配件名称。 */
    @Excel(name = "配件名称")
    private String accessoryName;

    /** 配件封面。 */
    private String coverImage;

    /** 当前价格。 */
    @Excel(name = "当前价格")
    private BigDecimal price;

    public Long getCollectionId()
    {
        return collectionId;
    }

    public void setCollectionId(Long collectionId)
    {
        this.collectionId = collectionId;
    }

    public Long getAppUserId()
    {
        return appUserId;
    }

    public void setAppUserId(Long appUserId)
    {
        this.appUserId = appUserId;
    }

    public Long getAccessoryId()
    {
        return accessoryId;
    }

    public void setAccessoryId(Long accessoryId)
    {
        this.accessoryId = accessoryId;
    }

    public String getUserName()
    {
        return userName;
    }

    public void setUserName(String userName)
    {
        this.userName = userName;
    }

    public String getAccessoryName()
    {
        return accessoryName;
    }

    public void setAccessoryName(String accessoryName)
    {
        this.accessoryName = accessoryName;
    }

    public String getCoverImage()
    {
        return coverImage;
    }

    public void setCoverImage(String coverImage)
    {
        this.coverImage = coverImage;
    }

    public BigDecimal getPrice()
    {
        return price;
    }

    public void setPrice(BigDecimal price)
    {
        this.price = price;
    }

    @Override
    public String toString()
    {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
            .append("collectionId", getCollectionId())
            .append("appUserId", getAppUserId())
            .append("accessoryId", getAccessoryId())
            .append("userName", getUserName())
            .append("accessoryName", getAccessoryName())
            .append("coverImage", getCoverImage())
            .append("price", getPrice())
            .append("createBy", getCreateBy())
            .append("createTime", getCreateTime())
            .append("updateBy", getUpdateBy())
            .append("updateTime", getUpdateTime())
            .append("remark", getRemark())
            .toString();
    }
}
