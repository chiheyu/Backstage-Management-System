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
import com.ruoyi.app.domain.AppAfterSalesOrder;
import com.ruoyi.app.domain.AppAccessoryCollection;
import com.ruoyi.app.domain.AppAccessoryOrder;
import com.ruoyi.app.domain.bo.AppAccessoryOrderSubmitBody;
import com.ruoyi.app.domain.bo.AppMerchantReviewSubmitBody;
import com.ruoyi.app.service.IAppAccessoryCollectionService;
import com.ruoyi.app.service.IAppAccessoryOrderService;
import com.ruoyi.app.service.IAppAfterSalesOrderService;
import com.ruoyi.app.service.IAppAuthService;
import com.ruoyi.app.service.IAppMerchantReviewService;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;

/**
 * App 用户侧控制器。
 *
 * @author ruoyi
 */
@RestController
@RequestMapping("/app/user")
public class AppUserController extends BaseController
{
    @Autowired
    private IAppAuthService appAuthService;

    @Autowired
    private IAppAfterSalesOrderService afterSalesOrderService;

    @Autowired
    private IAppAccessoryCollectionService collectionService;

    @Autowired
    private IAppAccessoryOrderService accessoryOrderService;

    @Autowired
    private IAppMerchantReviewService merchantReviewService;

    /**
     * 提交售后申请。
     */
    @PreAuthorize("@ss.hasRole('user')")
    @PostMapping("/afterSalesOrder")
    public AjaxResult createAfterSalesOrder(@RequestBody AppAfterSalesOrder order)
    {
        afterSalesOrderService.insertAfterSalesOrder(order);
        return AjaxResult.success("提交成功");
    }

    /**
     * 我的售后订单。
     */
    @PreAuthorize("@ss.hasRole('user')")
    @GetMapping("/afterSalesOrder/list")
    public TableDataInfo userAfterSalesOrderList(AppAfterSalesOrder order)
    {
        startPage();
        order.setAppUserId(appAuthService.getCurrentAppUser().getAppUserId());
        List<AppAfterSalesOrder> list = afterSalesOrderService.selectAfterSalesOrderList(order);
        return getDataTable(list);
    }

    /**
     * 售后订单详情。
     */
    @PreAuthorize("@ss.hasRole('user')")
    @GetMapping("/afterSalesOrder/{orderId}")
    public AjaxResult afterSalesOrderDetail(@PathVariable Long orderId)
    {
        return AjaxResult.success(afterSalesOrderService.selectAfterSalesOrderById(orderId));
    }

    /**
     * 用户取消售后单。
     */
    @PreAuthorize("@ss.hasRole('user')")
    @PutMapping("/afterSalesOrder/cancel/{orderId}")
    public AjaxResult cancelAfterSalesOrder(@PathVariable Long orderId)
    {
        return toAjax(afterSalesOrderService.cancelOrder(orderId));
    }

    /**
     * 我的收藏。
     */
    @PreAuthorize("@ss.hasRole('user')")
    @GetMapping("/accessoryCollection/list")
    public TableDataInfo collectionList(AppAccessoryCollection collection)
    {
        startPage();
        List<AppAccessoryCollection> list = collectionService.selectCollectionList(collection);
        return getDataTable(list);
    }

    /**
     * 收藏配件。
     */
    @PreAuthorize("@ss.hasRole('user')")
    @PostMapping("/accessoryCollection/{accessoryId}")
    public AjaxResult collectAccessory(@PathVariable Long accessoryId)
    {
        return toAjax(collectionService.collectAccessory(accessoryId));
    }

    /**
     * 取消收藏。
     */
    @PreAuthorize("@ss.hasRole('user')")
    @DeleteMapping("/accessoryCollection/{accessoryId}")
    public AjaxResult cancelCollection(@PathVariable Long accessoryId)
    {
        return toAjax(collectionService.cancelCollection(accessoryId));
    }

    /**
     * 配件下单。
     */
    @PreAuthorize("@ss.hasRole('user')")
    @PostMapping("/accessoryOrder")
    public AjaxResult createAccessoryOrder(@RequestBody AppAccessoryOrderSubmitBody submitBody)
    {
        return AjaxResult.success(accessoryOrderService.createOrder(submitBody));
    }

    /**
     * 我的配件订单。
     */
    @PreAuthorize("@ss.hasRole('user')")
    @GetMapping("/accessoryOrder/list")
    public TableDataInfo accessoryOrderList(AppAccessoryOrder order)
    {
        startPage();
        order.setAppUserId(appAuthService.getCurrentAppUser().getAppUserId());
        List<AppAccessoryOrder> list = accessoryOrderService.selectAccessoryOrderList(order);
        return getDataTable(list);
    }

    /**
     * 配件订单详情。
     */
    @PreAuthorize("@ss.hasRole('user')")
    @GetMapping("/accessoryOrder/{accessoryOrderId}")
    public AjaxResult accessoryOrderDetail(@PathVariable Long accessoryOrderId)
    {
        return AjaxResult.success(accessoryOrderService.selectAccessoryOrderById(accessoryOrderId));
    }

    /**
     * 提交商家评价。
     */
    @PreAuthorize("@ss.hasRole('user')")
    @PostMapping("/merchantReview")
    public AjaxResult createMerchantReview(@RequestBody AppMerchantReviewSubmitBody submitBody)
    {
        return AjaxResult.success(merchantReviewService.createReview(submitBody));
    }
}
