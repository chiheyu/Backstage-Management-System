package com.ruoyi.app.service;

import java.util.List;
import com.ruoyi.app.domain.AppMerchant;
import com.ruoyi.app.domain.bo.AppMerchantAuditBody;

/**
 * 商家服务接口。
 *
 * @author ruoyi
 */
public interface IAppMerchantService
{
    public AppMerchant selectMerchantById(Long merchantId);

    public AppMerchant selectCurrentMerchant();

    public List<AppMerchant> selectMerchantList(AppMerchant merchant);

    public int insertMerchant(AppMerchant merchant);

    public int updateMerchant(AppMerchant merchant);

    public int auditMerchant(AppMerchantAuditBody auditBody);
}
