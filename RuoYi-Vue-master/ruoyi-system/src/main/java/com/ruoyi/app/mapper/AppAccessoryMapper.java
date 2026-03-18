package com.ruoyi.app.mapper;

import java.util.List;
import com.ruoyi.app.domain.AppAccessory;

/**
 * 配件 Mapper。
 *
 * @author ruoyi
 */
public interface AppAccessoryMapper
{
    public AppAccessory selectAccessoryById(Long accessoryId);

    public List<AppAccessory> selectAccessoryList(AppAccessory accessory);

    public int insertAccessory(AppAccessory accessory);

    public int updateAccessory(AppAccessory accessory);

    public int deleteAccessoryById(Long accessoryId);
}
