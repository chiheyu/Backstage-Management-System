package com.ruoyi.web.controller.app;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
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
        startPage();
        order.setStatus(AppConstants.AFTER_SALES_WAIT_ACCEPT);
        List<AppAfterSalesOrder> list = afterSalesOrderService.selectAfterSalesOrderList(order);
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
        startPage();
        order.setMerchantId(merchantService.selectCurrentMerchant().getMerchantId());
        List<AppAfterSalesOrder> list = afterSalesOrderService.selectAfterSalesOrderList(order);
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
}
