package com.ruoyi.app.mapper;

import java.util.List;
import com.ruoyi.app.domain.AppMerchant;

/**
 * 商家 Mapper。
 *
 * @author ruoyi
 */
public interface AppMerchantMapper
{
    public AppMerchant selectMerchantById(Long merchantId);

    public AppMerchant selectMerchantByAppUserId(Long appUserId);

    public AppMerchant selectMerchantBySysUserId(Long sysUserId);

    public List<AppMerchant> selectMerchantList(AppMerchant merchant);

    public int insertMerchant(AppMerchant merchant);

    public int updateMerchant(AppMerchant merchant);

    public int deleteMerchantById(Long merchantId);
}
