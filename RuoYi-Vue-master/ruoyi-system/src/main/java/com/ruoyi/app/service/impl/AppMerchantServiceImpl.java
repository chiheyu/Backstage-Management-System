package com.ruoyi.app.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.app.domain.AppConstants;
import com.ruoyi.app.domain.AppMerchant;
import com.ruoyi.app.domain.AppUser;
import com.ruoyi.app.domain.bo.AppMerchantAuditBody;
import com.ruoyi.app.mapper.AppMerchantMapper;
import com.ruoyi.app.mapper.AppUserMapper;
import com.ruoyi.app.service.IAppAuthService;
import com.ruoyi.app.service.IAppMerchantService;
import com.ruoyi.common.core.domain.entity.SysRole;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.mapper.SysRoleMapper;
import com.ruoyi.system.service.ISysUserService;

/**
 * 商家服务实现。
 *
 * @author ruoyi
 */
@Service
public class AppMerchantServiceImpl implements IAppMerchantService
{
    @Autowired
    private AppMerchantMapper merchantMapper;

    @Autowired
    private AppUserMapper appUserMapper;

    @Autowired
    private IAppAuthService appAuthService;

    @Autowired
    private ISysUserService userService;

    @Autowired
    private SysRoleMapper sysRoleMapper;

    @Override
    public AppMerchant selectMerchantById(Long merchantId)
    {
        return merchantMapper.selectMerchantById(merchantId);
    }

    @Override
    public AppMerchant selectCurrentMerchant()
    {
        AppUser currentUser = appAuthService.getCurrentAppUser();
        AppMerchant merchant = merchantMapper.selectMerchantByAppUserId(currentUser.getAppUserId());
        if (StringUtils.isNull(merchant))
        {
            throw new ServiceException("当前账号未绑定商家信息");
        }
        return merchant;
    }

    @Override
    public List<AppMerchant> selectMerchantList(AppMerchant merchant)
    {
        return merchantMapper.selectMerchantList(merchant);
    }

    @Override
    public int insertMerchant(AppMerchant merchant)
    {
        merchant.setCreateBy(SecurityUtils.getUsername());
        if (StringUtils.isEmpty(merchant.getCityName()))
        {
            merchant.setCityName("汉中市");
        }
        if (StringUtils.isEmpty(merchant.getAuditStatus()))
        {
            merchant.setAuditStatus(AppConstants.MERCHANT_AUDIT_PENDING);
        }
        return merchantMapper.insertMerchant(merchant);
    }

    @Override
    public int updateMerchant(AppMerchant merchant)
    {
        AppMerchant dbMerchant = merchantMapper.selectMerchantById(merchant.getMerchantId());
        if (StringUtils.isNull(dbMerchant))
        {
            throw new ServiceException("商家不存在");
        }
        merchant.setUpdateBy(SecurityUtils.getUsername());
        return merchantMapper.updateMerchant(merchant);
    }

    /**
     * 商家审核。
     *
     * <p>审核通过后，商家账号自动切换为 merchant 角色；
     * 禁用时同步停用 sys_user 和 app_user。</p>
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int auditMerchant(AppMerchantAuditBody auditBody)
    {
        AppMerchant merchant = merchantMapper.selectMerchantById(auditBody.getMerchantId());
        if (StringUtils.isNull(merchant))
        {
            throw new ServiceException("商家不存在");
        }

        merchant.setAuditStatus(auditBody.getAuditStatus());
        merchant.setRemark(auditBody.getAuditRemark());
        merchant.setUpdateBy(SecurityUtils.getUsername());
        int rows = merchantMapper.updateMerchant(merchant);

        AppUser appUser = appUserMapper.selectAppUserBySysUserId(merchant.getSysUserId());
        if (StringUtils.isNull(appUser))
        {
            throw new ServiceException("商家未绑定 App 用户");
        }

        SysUser sysUser = userService.selectUserById(merchant.getSysUserId());
        if (StringUtils.isNull(sysUser))
        {
            throw new ServiceException("商家未绑定系统用户");
        }

        if (AppConstants.MERCHANT_AUDIT_APPROVED.equals(auditBody.getAuditStatus()))
        {
            appUser.setRoleType(AppConstants.ROLE_MERCHANT);
            appUser.setStatus(AppConstants.STATUS_NORMAL);
            appUser.setMerchantId(merchant.getMerchantId());
            appUser.setUpdateBy(SecurityUtils.getUsername());
            appUserMapper.updateAppUser(appUser);

            SysRole merchantRole = sysRoleMapper.checkRoleKeyUnique("merchant");
            if (StringUtils.isNull(merchantRole))
            {
                throw new ServiceException("请先初始化 merchant 角色");
            }
            userService.insertUserAuth(sysUser.getUserId(), new Long[] { merchantRole.getRoleId() });

            sysUser.setStatus(AppConstants.STATUS_NORMAL);
            userService.updateUserStatus(sysUser);
        }
        else if (AppConstants.MERCHANT_AUDIT_DISABLED.equals(auditBody.getAuditStatus()))
        {
            appUser.setRoleType(AppConstants.ROLE_MERCHANT);
            appUser.setStatus(AppConstants.STATUS_DISABLED);
            appUser.setUpdateBy(SecurityUtils.getUsername());
            appUserMapper.updateAppUser(appUser);

            sysUser.setStatus(AppConstants.STATUS_DISABLED);
            userService.updateUserStatus(sysUser);
        }
        else
        {
            appUser.setRoleType(AppConstants.ROLE_PENDING_MERCHANT);
            appUser.setStatus(AppConstants.STATUS_NORMAL);
            appUser.setUpdateBy(SecurityUtils.getUsername());
            appUserMapper.updateAppUser(appUser);
        }
        return rows;
    }
}
