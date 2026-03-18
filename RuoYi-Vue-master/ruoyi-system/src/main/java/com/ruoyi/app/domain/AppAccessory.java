package com.ruoyi.app.domain;

import java.math.BigDecimal;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 配件对象 app_accessory。
 *
 * @author ruoyi
 */
public class AppAccessory extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    /** 主键。 */
    private Long accessoryId;

    /** 分类。 */
    @Excel(name = "分类")
    private String categoryName;

    /** 配件名称。 */
    @Excel(name = "配件名称")
    private String accessoryName;

    /** 配件描述。 */
    private String accessoryDesc;

    /** 配件封面图。 */
    private String coverImage;

    /** 单价。 */
    @Excel(name = "价格")
    private BigDecimal price;

    /** 库存。 */
    @Excel(name = "库存")
    private Long stock;

    /** 销量。 */
    @Excel(name = "销量")
    private Long salesCount;

    /** 状态。 */
    @Excel(name = "状态")
    private String status;

    /** 当前用户是否已收藏。 */
    private Boolean collected;

    public Long getAccessoryId()
    {
        return accessoryId;
    }

    public void setAccessoryId(Long accessoryId)
    {
        this.accessoryId = accessoryId;
    }

    public String getCategoryName()
    {
        return categoryName;
    }

    public void setCategoryName(String categoryName)
    {
        this.categoryName = categoryName;
    }

    public String getAccessoryName()
    {
        return accessoryName;
    }

    public void setAccessoryName(String accessoryName)
    {
        this.accessoryName = accessoryName;
    }

    public String getAccessoryDesc()
    {
        return accessoryDesc;
    }

    public void setAccessoryDesc(String accessoryDesc)
    {
        this.accessoryDesc = accessoryDesc;
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

    public Long getStock()
    {
        return stock;
    }

    public void setStock(Long stock)
    {
        this.stock = stock;
    }

    public Long getSalesCount()
    {
        return salesCount;
    }

    public void setSalesCount(Long salesCount)
    {
        this.salesCount = salesCount;
    }

    public String getStatus()
    {
        return status;
    }

    public void setStatus(String status)
    {
        this.status = status;
    }

    public Boolean getCollected()
    {
        return collected;
    }

    public void setCollected(Boolean collected)
    {
        this.collected = collected;
    }

    @Override
    public String toString()
    {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
            .append("accessoryId", getAccessoryId())
            .append("categoryName", getCategoryName())
            .append("accessoryName", getAccessoryName())
            .append("accessoryDesc", getAccessoryDesc())
            .append("coverImage", getCoverImage())
            .append("price", getPrice())
            .append("stock", getStock())
            .append("salesCount", getSalesCount())
            .append("status", getStatus())
            .append("collected", getCollected())
            .append("createBy", getCreateBy())
            .append("createTime", getCreateTime())
            .append("updateBy", getUpdateBy())
            .append("updateTime", getUpdateTime())
            .append("remark", getRemark())
            .toString();
    }
}
