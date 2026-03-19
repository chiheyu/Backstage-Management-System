package com.ruoyi.app.service;

import java.util.List;
import com.ruoyi.app.domain.AppAccessory;

/**
 * 配件服务接口。
 *
 * @author ruoyi
 */
public interface IAppAccessoryService
{
    public AppAccessory selectAccessoryById(Long accessoryId);

    public List<AppAccessory> selectAccessoryList(AppAccessory accessory);

    public int insertAccessory(AppAccessory accessory);

    public int updateAccessory(AppAccessory accessory);

    public int deleteAccessoryById(Long accessoryId);
}
