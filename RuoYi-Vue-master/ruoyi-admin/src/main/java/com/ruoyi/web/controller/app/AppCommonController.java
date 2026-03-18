package com.ruoyi.web.controller.app;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.app.domain.AppAccessory;
import com.ruoyi.app.domain.AppConstants;
import com.ruoyi.app.domain.AppMerchant;
import com.ruoyi.app.service.IAppAccessoryService;
import com.ruoyi.app.service.IAppMerchantService;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.StringUtils;

/**
 * App 通用查询控制器。
 *
 * <p>这里提供登录后无角色限制的查询能力，用户和商家都能访问。</p>
 *
 * @author ruoyi
 */
@RestController
@RequestMapping("/app/common")
public class AppCommonController extends BaseController
{
    @Autowired
    private IAppMerchantService merchantService;

    @Autowired
    private IAppAccessoryService accessoryService;

    /**
     * 商家列表。
     */
    @GetMapping("/merchant/list")
    public TableDataInfo merchantList(AppMerchant merchant)
    {
        startPage();
        AppMerchant query = StringUtils.isNull(merchant) ? new AppMerchant() : merchant;
        if (StringUtils.isEmpty(query.getCityName()))
        {
            query.setCityName("汉中市");
        }
        if (StringUtils.isEmpty(query.getAuditStatus()))
        {
            query.setAuditStatus(AppConstants.MERCHANT_AUDIT_APPROVED);
        }
        List<AppMerchant> list = merchantService.selectMerchantList(query);
        return getDataTable(list);
    }

    /**
     * 商家详情。
     */
    @GetMapping("/merchant/{merchantId}")
    public AjaxResult merchantDetail(@PathVariable Long merchantId)
    {
        AppMerchant merchant = merchantService.selectMerchantById(merchantId);
        if (StringUtils.isNull(merchant) || !AppConstants.MERCHANT_AUDIT_APPROVED.equals(merchant.getAuditStatus()))
        {
            throw new ServiceException("商家不存在或未审核通过");
        }
        return AjaxResult.success(merchant);
    }

    /**
     * 配件列表。
     */
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
    @GetMapping("/accessory/{accessoryId}")
    public AjaxResult accessoryDetail(@PathVariable Long accessoryId)
    {
        return AjaxResult.success(accessoryService.selectAccessoryById(accessoryId));
    }
}
