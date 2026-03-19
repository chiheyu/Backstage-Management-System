package com.ruoyi.app.domain;

/**
 * 汉中市电子产品售后服务系统常量。
 *
 * <p>这里集中维护角色、审核状态、订单状态等业务枚举值，
 * 便于后端、Web 管理端和 uni-app 端保持一致。</p>
 *
 * @author ruoyi
 */
public final class AppConstants
{
    private AppConstants()
    {
    }

    /** 普通用户。 */
    public static final String ROLE_USER = "1";

    /** 商家待审核。 */
    public static final String ROLE_PENDING_MERCHANT = "0";

    /** 审核通过的商家。 */
    public static final String ROLE_MERCHANT = "2";

    /** 正常状态。 */
    public static final String STATUS_NORMAL = "0";

    /** 停用状态。 */
    public static final String STATUS_DISABLED = "1";

    /** 商家待审核。 */
    public static final String MERCHANT_AUDIT_PENDING = "0";

    /** 商家审核通过。 */
    public static final String MERCHANT_AUDIT_APPROVED = "1";

    /** 商家禁用。 */
    public static final String MERCHANT_AUDIT_DISABLED = "2";

    /** 售后单待接单。 */
    public static final String AFTER_SALES_WAIT_ACCEPT = "0";

    /** 售后单已接单。 */
    public static final String AFTER_SALES_ACCEPTED = "1";

    /** 售后单维修中。 */
    public static final String AFTER_SALES_REPAIRING = "2";

    /** 售后单已完成。 */
    public static final String AFTER_SALES_COMPLETED = "3";

    /** 售后单已取消。 */
    public static final String AFTER_SALES_CANCELED = "4";

    /** 配件上架。 */
    public static final String ACCESSORY_ON_SHELF = "0";

    /** 配件下架。 */
    public static final String ACCESSORY_OFF_SHELF = "1";

    /** 配件订单待处理。 */
    public static final String ACCESSORY_ORDER_PENDING = "0";

    /** 配件订单已发货。 */
    public static final String ACCESSORY_ORDER_SHIPPED = "1";

    /** 配件订单已完成。 */
    public static final String ACCESSORY_ORDER_COMPLETED = "2";

    /** 配件订单已取消。 */
    public static final String ACCESSORY_ORDER_CANCELED = "3";

    /** 模拟验证码缓存前缀。 */
    public static final String SMS_CODE_CACHE_PREFIX = "app:sms:code:";
}
