package com.ruoyi.web.controller.app;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;
import java.util.Map;
import java.util.LinkedHashMap;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.app.domain.AppAfterSalesOrder;
import com.ruoyi.app.domain.AppAccessory;
import com.ruoyi.app.domain.AppAccessoryOrder;
import com.ruoyi.app.domain.AppConstants;
import com.ruoyi.app.domain.AppMerchant;
import com.ruoyi.app.domain.bo.AppOrderActionBody;
import com.ruoyi.app.service.IAppAccessoryOrderService;
import com.ruoyi.app.service.IAppAccessoryService;
import com.ruoyi.app.service.IAppAfterSalesOrderService;
import com.ruoyi.app.service.IAppMerchantService;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * 商家侧控制器。
 *
 * @author ruoyi
 */
@RestController
@RequestMapping("/app/merchant")
public class AppMerchantController extends BaseController
{
    @Autowired
    private IAppMerchantService merchantService;

    @Autowired
    private IAppAfterSalesOrderService afterSalesOrderService;

    @Autowired
    private IAppAccessoryService accessoryService;

    @Autowired
    private IAppAccessoryOrderService accessoryOrderService;

    /**
     * 当前商家信息。
     */
    @PreAuthorize("@ss.hasRole('merchant')")
    @GetMapping("/info")
    public AjaxResult currentMerchant()
    {
        return AjaxResult.success(merchantService.selectCurrentMerchant());
    }

    /**
     * 商家数据统计。
     */
    @PreAuthorize("@ss.hasRole('merchant')")
    @GetMapping("/stats")
    public AjaxResult stats()
    {
        Long merchantId = merchantService.selectCurrentMerchant().getMerchantId();

        AppAccessoryOrder accessoryOrderQuery = new AppAccessoryOrder();
        accessoryOrderQuery.setMerchantId(merchantId);
        List<AppAccessoryOrder> accessoryOrders = accessoryOrderService.selectAccessoryOrderList(accessoryOrderQuery);

        List<AppAfterSalesOrder> merchantVisibleAfterSalesOrders = selectMerchantVisibleAfterSalesOrders(merchantId);

        LocalDate today = LocalDate.now();
        LocalDate monthStart = today.withDayOfMonth(1);

        long todayPendingShipment = accessoryOrders.stream()
            .filter(order -> AppConstants.ACCESSORY_ORDER_PENDING.equals(order.getStatus()))
            .filter(order -> isWithinDay(getEffectiveTime(order.getCreateTime(), order.getUpdateTime()), today))
            .count();

        long todayShipped = accessoryOrders.stream()
            .filter(order -> AppConstants.ACCESSORY_ORDER_SHIPPED.equals(order.getStatus())
                || AppConstants.ACCESSORY_ORDER_COMPLETED.equals(order.getStatus()))
            .filter(order -> isWithinDay(getEffectiveTime(order.getUpdateTime(), order.getCreateTime()), today))
            .count();

        long todayPendingAfterSale = merchantVisibleAfterSalesOrders.stream()
            .filter(this::isAfterSalesUnfinished)
            .filter(order -> isWithinDay(getEffectiveTime(order.getCreateTime(), order.getUpdateTime()), today))
            .count();

        long todayCompletedAfterSale = merchantVisibleAfterSalesOrders.stream()
            .filter(this::isAfterSalesFinished)
            .filter(order -> isWithinDay(getEffectiveTime(order.getFinishTime(), order.getUpdateTime(), order.getCreateTime()), today))
            .count();

        long monthlyShipmentCount = accessoryOrders.stream()
            .filter(order -> AppConstants.ACCESSORY_ORDER_SHIPPED.equals(order.getStatus())
                || AppConstants.ACCESSORY_ORDER_COMPLETED.equals(order.getStatus()))
            .filter(order -> isWithinMonth(getEffectiveTime(order.getUpdateTime(), order.getCreateTime()), monthStart))
            .count();

        long monthlyAfterSalesCount = merchantVisibleAfterSalesOrders.stream()
            .filter(order -> isWithinMonth(getEffectiveTime(order.getFinishTime(), order.getUpdateTime(), order.getCreateTime()), monthStart))
            .count();

        Map<String, Long> typeCountMap = new LinkedHashMap<>();
        typeCountMap.put("退货", 0L);
        typeCountMap.put("换货", 0L);

        merchantVisibleAfterSalesOrders.forEach(order -> {
            String typeName = parseAfterSalesType(order.getProductType());
            if (typeCountMap.containsKey(typeName))
            {
                typeCountMap.put(typeName, typeCountMap.get(typeName) + 1L);
            }
        });

        long typeTotal = typeCountMap.values().stream().mapToLong(Long::longValue).sum();
        List<Map<String, Object>> typeRatio = typeCountMap.entrySet().stream()
            .map(entry -> buildTypeRatioItem(entry.getKey(), entry.getValue(), typeTotal))
            .collect(Collectors.toList());

        List<Map<String, Object>> weekTrend = buildWeekTrend(accessoryOrders, merchantVisibleAfterSalesOrders, today);

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("todayPendingShipment", todayPendingShipment);
        data.put("todayShipped", todayShipped);
        data.put("todayPendingAfterSale", todayPendingAfterSale);
        data.put("todayCompletedAfterSale", todayCompletedAfterSale);
        data.put("monthTotal", monthlyShipmentCount + monthlyAfterSalesCount);
        data.put("typeRatio", typeRatio);
        data.put("weekTrend", weekTrend);
        return AjaxResult.success(data);
    }

    /**
     * 更新当前商家资料。
     */
    @PreAuthorize("@ss.hasRole('merchant')")
    @PutMapping("/info")
    public AjaxResult updateMerchantInfo(@RequestBody AppMerchant merchant)
    {
        AppMerchant currentMerchant = merchantService.selectCurrentMerchant();
        merchant.setMerchantId(currentMerchant.getMerchantId());
        merchant.setAuditStatus(currentMerchant.getAuditStatus());
        return toAjax(merchantService.updateMerchant(merchant));
    }

    /**
     * 待接单订单。
     */
    @PreAuthorize("@ss.hasRole('merchant')")
    @GetMapping("/order/pendingList")
    public TableDataInfo pendingOrderList(AppAfterSalesOrder order)
    {
        Long merchantId = merchantService.selectCurrentMerchant().getMerchantId();
        List<AppAfterSalesOrder> list = selectMerchantVisibleAfterSalesOrders(merchantId).stream()
            .filter(this::isAfterSalesUnfinished)
            .collect(Collectors.toList());
        return getDataTable(list);
    }

    /**
     * 接单。
     */
    @PreAuthorize("@ss.hasRole('merchant')")
    @PutMapping("/order/take/{orderId}")
    public AjaxResult takeOrder(@PathVariable Long orderId)
    {
        return toAjax(afterSalesOrderService.takeOrder(orderId));
    }

    /**
     * 商家订单列表。
     */
    @PreAuthorize("@ss.hasRole('merchant')")
    @GetMapping("/order/list")
    public TableDataInfo myOrderList(AppAfterSalesOrder order)
    {
        Long merchantId = merchantService.selectCurrentMerchant().getMerchantId();
        List<AppAfterSalesOrder> list = selectMerchantVisibleAfterSalesOrders(merchantId);
        return getDataTable(list);
    }

    /**
     * 商家待处理配件订单。
     */
    @PreAuthorize("@ss.hasRole('merchant')")
    @GetMapping("/accessoryOrder/pendingList")
    public TableDataInfo pendingAccessoryOrderList(AppAccessoryOrder order)
    {
        startPage();
        order.setMerchantId(merchantService.selectCurrentMerchant().getMerchantId());
        order.setStatus(AppConstants.ACCESSORY_ORDER_PENDING);
        List<AppAccessoryOrder> list = accessoryOrderService.selectAccessoryOrderList(order);
        return getDataTable(list);
    }

    /**
     * 商家配件订单列表。
     */
    @PreAuthorize("@ss.hasRole('merchant')")
    @GetMapping("/accessoryOrder/list")
    public TableDataInfo accessoryOrderList(AppAccessoryOrder order)
    {
        startPage();
        order.setMerchantId(merchantService.selectCurrentMerchant().getMerchantId());
        List<AppAccessoryOrder> list = accessoryOrderService.selectAccessoryOrderList(order);
        return getDataTable(list);
    }

    /**
     * 商家发货配件订单。
     */
    @PreAuthorize("@ss.hasRole('merchant')")
    @PutMapping("/accessoryOrder/ship/{accessoryOrderId}")
    public AjaxResult shipAccessoryOrder(@PathVariable Long accessoryOrderId)
    {
        return toAjax(accessoryOrderService.shipOrder(accessoryOrderId));
    }

    /**
     * 商家完成配件订单。
     */
    @PreAuthorize("@ss.hasRole('merchant')")
    @PutMapping("/accessoryOrder/complete/{accessoryOrderId}")
    public AjaxResult completeAccessoryOrder(@PathVariable Long accessoryOrderId)
    {
        return toAjax(accessoryOrderService.completeOrder(accessoryOrderId));
    }

    /**
     * 商家取消配件订单。
     */
    @PreAuthorize("@ss.hasRole('merchant')")
    @PutMapping("/accessoryOrder/cancel/{accessoryOrderId}")
    public AjaxResult cancelAccessoryOrder(@PathVariable Long accessoryOrderId)
    {
        return toAjax(accessoryOrderService.cancelOrder(accessoryOrderId));
    }

    /**
     * 商家更新订单状态。
     */
    @PreAuthorize("@ss.hasRole('merchant')")
    @PutMapping("/order/status")
    public AjaxResult updateOrderStatus(@RequestBody AppOrderActionBody actionBody)
    {
        return toAjax(afterSalesOrderService.updateOrderStatus(actionBody));
    }

    /**
     * 商家新增商品。
     */
    @PreAuthorize("@ss.hasRole('merchant')")
    @PostMapping("/accessory")
    public AjaxResult addAccessory(@RequestBody AppAccessory accessory)
    {
        return toAjax(accessoryService.insertAccessory(accessory));
    }

    /**
     * 商家商品列表。
     */
    @PreAuthorize("@ss.hasRole('merchant')")
    @GetMapping("/accessory/list")
    public TableDataInfo accessoryList(AppAccessory accessory)
    {
        startPage();
        List<AppAccessory> list = accessoryService.selectAccessoryList(accessory);
        return getDataTable(list);
    }

    /**
     * 商家商品详情。
     */
    @PreAuthorize("@ss.hasRole('merchant')")
    @GetMapping("/accessory/{accessoryId}")
    public AjaxResult accessoryDetail(@PathVariable Long accessoryId)
    {
        return AjaxResult.success(accessoryService.selectAccessoryById(accessoryId));
    }

    /**
     * 商家修改商品。
     */
    @PreAuthorize("@ss.hasRole('merchant')")
    @PutMapping("/accessory")
    public AjaxResult updateAccessory(@RequestBody AppAccessory accessory)
    {
        return toAjax(accessoryService.updateAccessory(accessory));
    }

    /**
     * 商家删除商品。
     */
    @PreAuthorize("@ss.hasRole('merchant')")
    @DeleteMapping("/accessory/{accessoryId}")
    public AjaxResult removeAccessory(@PathVariable Long accessoryId)
    {
        return toAjax(accessoryService.deleteAccessoryById(accessoryId));
    }

    private List<AppAfterSalesOrder> selectMerchantVisibleAfterSalesOrders(Long merchantId)
    {
        AppAfterSalesOrder query = new AppAfterSalesOrder();
        List<AppAfterSalesOrder> allOrders = afterSalesOrderService.selectAfterSalesOrderList(query);
        return allOrders.stream()
            .filter(order -> {
                if (isAfterSalesFinished(order))
                {
                    return order.getMerchantId() != null && merchantId.equals(order.getMerchantId());
                }
                return order.getMerchantId() == null || merchantId.equals(order.getMerchantId());
            })
            .collect(Collectors.toList());
    }

    private boolean isAfterSalesUnfinished(AppAfterSalesOrder order)
    {
        String status = order == null ? "" : order.getStatus();
        return AppConstants.AFTER_SALES_WAIT_ACCEPT.equals(status)
            || AppConstants.AFTER_SALES_ACCEPTED.equals(status)
            || AppConstants.AFTER_SALES_REPAIRING.equals(status);
    }

    private boolean isAfterSalesFinished(AppAfterSalesOrder order)
    {
        String status = order == null ? "" : order.getStatus();
        return AppConstants.AFTER_SALES_COMPLETED.equals(status)
            || AppConstants.AFTER_SALES_CANCELED.equals(status);
    }

    private java.util.Date getEffectiveTime(java.util.Date... candidates)
    {
        for (java.util.Date candidate : candidates)
        {
            if (candidate != null)
            {
                return candidate;
            }
        }
        return null;
    }

    private boolean isWithinDay(java.util.Date date, LocalDate targetDay)
    {
        if (date == null)
        {
            return false;
        }
        LocalDate localDate = date.toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
        return targetDay.equals(localDate);
    }

    private boolean isWithinMonth(java.util.Date date, LocalDate monthStart)
    {
        if (date == null)
        {
            return false;
        }
        LocalDate localDate = date.toInstant().atZone(ZoneId.systemDefault()).toLocalDate();
        return !localDate.isBefore(monthStart);
    }

    private String parseAfterSalesType(String productType)
    {
        if (productType == null)
        {
            return "";
        }
        if (productType.startsWith("退货"))
        {
            return "退货";
        }
        if (productType.startsWith("换货"))
        {
            return "换货";
        }
        return "";
    }

    private Map<String, Object> buildTypeRatioItem(String name, Long count, long total)
    {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("name", name);
        item.put("count", count);
        item.put("ratio", total <= 0 ? "0%" : Math.round((count * 100.0D) / total) + "%");
        item.put("color", "退货".equals(name) ? "#2f54eb" : "#fa8c16");
        return item;
    }

    private List<Map<String, Object>> buildWeekTrend(List<AppAccessoryOrder> accessoryOrders, List<AppAfterSalesOrder> afterSalesOrders, LocalDate today)
    {
        List<Map<String, Object>> trend = new java.util.ArrayList<>();
        for (int offset = 6; offset >= 0; offset--)
        {
            LocalDate targetDay = today.minusDays(offset);
            long shipmentCount = accessoryOrders.stream()
                .filter(order -> AppConstants.ACCESSORY_ORDER_SHIPPED.equals(order.getStatus())
                    || AppConstants.ACCESSORY_ORDER_COMPLETED.equals(order.getStatus()))
                .filter(order -> isWithinDay(getEffectiveTime(order.getUpdateTime(), order.getCreateTime()), targetDay))
                .count();
            long afterSalesCount = afterSalesOrders.stream()
                .filter(this::isAfterSalesFinished)
                .filter(order -> isWithinDay(getEffectiveTime(order.getFinishTime(), order.getUpdateTime(), order.getCreateTime()), targetDay))
                .count();

            Map<String, Object> item = new LinkedHashMap<>();
            item.put("date", targetDay.getMonthValue() + "/" + targetDay.getDayOfMonth());
            item.put("value", shipmentCount + afterSalesCount);
            trend.add(item);
        }
        return trend;
    }
}
