package com.ruoyi.app.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import com.ruoyi.app.domain.AppAccessory;
import com.ruoyi.app.domain.AppConstants;
import com.ruoyi.app.mapper.AppAccessoryMapper;
import com.ruoyi.app.service.IAppAccessoryService;
import com.ruoyi.common.core.domain.model.LoginUser;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;

/**
 * 配件服务实现。
 *
 * @author ruoyi
 */
@Service
public class AppAccessoryServiceImpl implements IAppAccessoryService
{
    @Autowired
    private AppAccessoryMapper accessoryMapper;

    @Override
    public AppAccessory selectAccessoryById(Long accessoryId)
    {
        AppAccessory accessory = accessoryMapper.selectAccessoryById(accessoryId);
        if (StringUtils.isNull(accessory))
        {
            return null;
        }
        if (!isAdminRequest() && !AppConstants.ACCESSORY_ON_SHELF.equals(accessory.getStatus()))
        {
            throw new ServiceException("配件不存在或已下架");
        }
        return accessory;
    }

    @Override
    public List<AppAccessory> selectAccessoryList(AppAccessory accessory)
    {
        AppAccessory query = StringUtils.isNull(accessory) ? new AppAccessory() : accessory;
        if (!isAdminRequest() && StringUtils.isEmpty(query.getStatus()))
        {
            query.setStatus(AppConstants.ACCESSORY_ON_SHELF);
        }
        return accessoryMapper.selectAccessoryList(query);
    }

    @Override
    public int insertAccessory(AppAccessory accessory)
    {
        accessory.setCreateBy(SecurityUtils.getUsername());
        if (StringUtils.isNull(accessory.getSalesCount()))
        {
            accessory.setSalesCount(0L);
        }
        if (StringUtils.isEmpty(accessory.getStatus()))
        {
            accessory.setStatus(AppConstants.ACCESSORY_ON_SHELF);
        }
        return accessoryMapper.insertAccessory(accessory);
    }

    @Override
    public int updateAccessory(AppAccessory accessory)
    {
        accessory.setUpdateBy(SecurityUtils.getUsername());
        return accessoryMapper.updateAccessory(accessory);
    }

    @Override
    public int deleteAccessoryById(Long accessoryId)
    {
        return accessoryMapper.deleteAccessoryById(accessoryId);
    }

    /**
     * 判断当前请求是否来自后台管理员。
     *
     * <p>公开接口允许匿名访问，因此这里不能直接调用
     * {@link SecurityUtils#getUserId()}，否则会抛出未登录异常。</p>
     */
    private boolean isAdminRequest()
    {
        Authentication authentication = SecurityUtils.getAuthentication();
        if (StringUtils.isNull(authentication) || !(authentication.getPrincipal() instanceof LoginUser))
        {
            return false;
        }
        LoginUser loginUser = (LoginUser) authentication.getPrincipal();
        return SysUserHelper.isAdmin(loginUser.getUserId());
    }
}
