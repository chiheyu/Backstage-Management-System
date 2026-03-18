package com.ruoyi.web.controller.app;

import java.util.List;
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
import com.ruoyi.app.domain.AppAccessory;
import com.ruoyi.app.domain.AppAccessoryOrder;
import com.ruoyi.app.domain.AppAfterSalesOrder;
import com.ruoyi.app.domain.AppMerchant;
import com.ruoyi.app.domain.bo.AppMerchantAuditBody;
import com.ruoyi.app.domain.bo.AppOrderActionBody;
import com.ruoyi.app.service.IAppAccessoryOrderService;
import com.ruoyi.app.service.IAppAccessoryService;
import com.ruoyi.app.service.IAppAfterSalesOrderService;
import com.ruoyi.app.service.IAppMerchantService;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;

/**
 * 管理端业务控制器。
 *
 * @author ruoyi
 */
@RestController
@RequestMapping("/app/admin")
public class AppAdminController extends BaseController
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
     * 商家列表。
     */
    @PreAuthorize("@ss.hasPermi('app:merchant:list')")
    @GetMapping("/merchant/list")
    public TableDataInfo merchantList(AppMerchant merchant)
    {
        startPage();
        List<AppMerchant> list = merchantService.selectMerchantList(merchant);
        return getDataTable(list);
    }

    /**
     * 商家详情。
     */
    @PreAuthorize("@ss.hasPermi('app:merchant:query')")
    @GetMapping("/merchant/{merchantId}")
    public AjaxResult merchantDetail(@PathVariable Long merchantId)
    {
        return AjaxResult.success(merchantService.selectMerchantById(merchantId));
    }

    /**
     * 审核商家。
     */
    @PreAuthorize("@ss.hasPermi('app:merchant:audit')")
    @Log(title = "商家管理", businessType = BusinessType.UPDATE)
    @PutMapping("/merchant/audit")
    public AjaxResult auditMerchant(@RequestBody AppMerchantAuditBody auditBody)
    {
        return toAjax(merchantService.auditMerchant(auditBody));
    }

    /**
     * 编辑商家资料。
     */
    @PreAuthorize("@ss.hasPermi('app:merchant:edit')")
    @Log(title = "商家管理", businessType = BusinessType.UPDATE)
    @PutMapping("/merchant")
    public AjaxResult updateMerchant(@RequestBody AppMerchant merchant)
    {
        return toAjax(merchantService.updateMerchant(merchant));
    }

    /**
     * 售后订单列表。
     */
    @PreAuthorize("@ss.hasPermi('app:afterSalesOrder:list')")
    @GetMapping("/afterSalesOrder/list")
    public TableDataInfo afterSalesOrderList(AppAfterSalesOrder order)
    {
        startPage();
        List<AppAfterSalesOrder> list = afterSalesOrderService.selectAfterSalesOrderList(order);
        return getDataTable(list);
    }

    /**
     * 售后订单详情。
     */
    @PreAuthorize("@ss.hasPermi('app:afterSalesOrder:query')")
    @GetMapping("/afterSalesOrder/{orderId}")
    public AjaxResult afterSalesOrderDetail(@PathVariable Long orderId)
    {
        return AjaxResult.success(afterSalesOrderService.selectAfterSalesOrderById(orderId));
    }

    /**
     * 管理员修改售后订单状态。
     */
    @PreAuthorize("@ss.hasPermi('app:afterSalesOrder:edit')")
    @Log(title = "售后订单管理", businessType = BusinessType.UPDATE)
    @PutMapping("/afterSalesOrder/status")
    public AjaxResult updateAfterSalesOrderStatus(@RequestBody AppOrderActionBody actionBody)
    {
        return toAjax(afterSalesOrderService.updateOrderStatus(actionBody));
    }

    /**
     * 配件列表。
     */
    @PreAuthorize("@ss.hasPermi('app:accessory:list')")
    @GetMapping("/accessory/list")
    public TableDataInfo accessoryList(AppAccessory accessory)
    {
        startPage();
        List<AppAccessory> list = accessoryService.selectAccessoryList(accessory);
        return getDataTable(list);
    }

    /**
     * 配件详情。
     */
    @PreAuthorize("@ss.hasPermi('app:accessory:query')")
    @GetMapping("/accessory/{accessoryId}")
    public AjaxResult accessoryDetail(@PathVariable Long accessoryId)
    {
        return AjaxResult.success(accessoryService.selectAccessoryById(accessoryId));
    }

    /**
     * 新增配件。
     */
    @PreAuthorize("@ss.hasPermi('app:accessory:add')")
    @Log(title = "配件管理", businessType = BusinessType.INSERT)
    @PostMapping("/accessory")
    public AjaxResult addAccessory(@RequestBody AppAccessory accessory)
    {
        return toAjax(accessoryService.insertAccessory(accessory));
    }

    /**
     * 更新配件。
     */
    @PreAuthorize("@ss.hasPermi('app:accessory:edit')")
    @Log(title = "配件管理", businessType = BusinessType.UPDATE)
    @PutMapping("/accessory")
    public AjaxResult updateAccessory(@RequestBody AppAccessory accessory)
    {
        return toAjax(accessoryService.updateAccessory(accessory));
    }

    /**
     * 删除配件。
     */
    @PreAuthorize("@ss.hasPermi('app:accessory:remove')")
    @Log(title = "配件管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/accessory/{accessoryId}")
    public AjaxResult removeAccessory(@PathVariable Long accessoryId)
    {
        return toAjax(accessoryService.deleteAccessoryById(accessoryId));
    }

    /**
     * 配件订单列表。
     */
    @PreAuthorize("@ss.hasPermi('app:accessoryOrder:list')")
    @GetMapping("/accessoryOrder/list")
    public TableDataInfo accessoryOrderList(AppAccessoryOrder order)
    {
        startPage();
        List<AppAccessoryOrder> list = accessoryOrderService.selectAccessoryOrderList(order);
        return getDataTable(list);
    }

    /**
     * 配件订单详情。
     */
    @PreAuthorize("@ss.hasPermi('app:accessoryOrder:query')")
    @GetMapping("/accessoryOrder/{accessoryOrderId}")
    public AjaxResult accessoryOrderDetail(@PathVariable Long accessoryOrderId)
    {
        return AjaxResult.success(accessoryOrderService.selectAccessoryOrderById(accessoryOrderId));
    }
}
