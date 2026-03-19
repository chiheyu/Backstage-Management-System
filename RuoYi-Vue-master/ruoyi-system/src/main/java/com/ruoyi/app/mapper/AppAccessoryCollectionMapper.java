package com.ruoyi.app.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.app.domain.AppAccessoryCollection;

/**
 * 配件收藏 Mapper。
 *
 * @author ruoyi
 */
public interface AppAccessoryCollectionMapper
{
    public AppAccessoryCollection selectCollectionById(Long collectionId);

    public AppAccessoryCollection selectCollectionByUserAndAccessory(@Param("appUserId") Long appUserId, @Param("accessoryId") Long accessoryId);

    public List<AppAccessoryCollection> selectCollectionList(AppAccessoryCollection collection);

    public int insertCollection(AppAccessoryCollection collection);

    public int deleteCollectionById(Long collectionId);

    public int deleteCollectionByUserAndAccessory(@Param("appUserId") Long appUserId, @Param("accessoryId") Long accessoryId);
}
