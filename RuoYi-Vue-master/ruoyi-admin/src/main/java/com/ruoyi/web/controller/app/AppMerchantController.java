package com.ruoyi.web.controller.app;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.app.domain.AppAfterSalesOrder;
import com.ruoyi.app.domain.AppConstants;
import com.ruoyi.app.domain.AppMerchant;
import com.ruoyi.app.domain.bo.AppOrderActionBody;
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
     * 商家更新订单状态。
     */
    @PreAuthorize("@ss.hasRole('merchant')")
    @PutMapping("/order/status")
    public AjaxResult updateOrderStatus(@RequestBody AppOrderActionBody actionBody)
    {
        return toAjax(afterSalesOrderService.updateOrderStatus(actionBody));
    }
}
