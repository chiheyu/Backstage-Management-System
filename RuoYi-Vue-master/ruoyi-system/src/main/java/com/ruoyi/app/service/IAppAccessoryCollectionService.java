package com.ruoyi.app.service;

import java.util.List;
import com.ruoyi.app.domain.AppAccessoryCollection;

/**
 * 配件收藏服务接口。
 *
 * @author ruoyi
 */
public interface IAppAccessoryCollectionService
{
    public List<AppAccessoryCollection> selectCollectionList(AppAccessoryCollection collection);

    public int collectAccessory(Long accessoryId);

    public int cancelCollection(Long accessoryId);
}
