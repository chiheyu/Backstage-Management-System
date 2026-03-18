package com.ruoyi.app.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.app.domain.AppAccessory;
import com.ruoyi.app.domain.AppAccessoryCollection;
import com.ruoyi.app.domain.AppConstants;
import com.ruoyi.app.domain.AppUser;
import com.ruoyi.app.mapper.AppAccessoryCollectionMapper;
import com.ruoyi.app.mapper.AppAccessoryMapper;
import com.ruoyi.app.service.IAppAccessoryCollectionService;
import com.ruoyi.app.service.IAppAuthService;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;

/**
 * 配件收藏服务实现。
 *
 * @author ruoyi
 */
@Service
public class AppAccessoryCollectionServiceImpl implements IAppAccessoryCollectionService
{
    @Autowired
    private AppAccessoryCollectionMapper collectionMapper;

    @Autowired
    private AppAccessoryMapper accessoryMapper;

    @Autowired
    private IAppAuthService appAuthService;

    @Override
    public List<AppAccessoryCollection> selectCollectionList(AppAccessoryCollection collection)
    {
        AppUser currentUser = appAuthService.getCurrentAppUser();
        collection.setAppUserId(currentUser.getAppUserId());
        return collectionMapper.selectCollectionList(collection);
    }

    /**
     * 新增收藏。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int collectAccessory(Long accessoryId)
    {
        AppUser currentUser = appAuthService.getCurrentAppUser();
        AppAccessory accessory = accessoryMapper.selectAccessoryById(accessoryId);
        if (StringUtils.isNull(accessory))
        {
            throw new ServiceException("配件不存在");
        }
        if (!AppConstants.ACCESSORY_ON_SHELF.equals(accessory.getStatus()))
        {
            throw new ServiceException("仅允许收藏已上架配件");
        }
        AppAccessoryCollection dbCollection =
            collectionMapper.selectCollectionByUserAndAccessory(currentUser.getAppUserId(), accessoryId);
        if (StringUtils.isNotNull(dbCollection))
        {
            return 1;
        }

        AppAccessoryCollection collection = new AppAccessoryCollection();
        collection.setAppUserId(currentUser.getAppUserId());
        collection.setAccessoryId(accessoryId);
        collection.setCreateBy(SecurityUtils.getUsername());
        return collectionMapper.insertCollection(collection);
    }

    /**
     * 取消收藏。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public int cancelCollection(Long accessoryId)
    {
        AppUser currentUser = appAuthService.getCurrentAppUser();
        return collectionMapper.deleteCollectionByUserAndAccessory(currentUser.getAppUserId(), accessoryId);
    }
}
