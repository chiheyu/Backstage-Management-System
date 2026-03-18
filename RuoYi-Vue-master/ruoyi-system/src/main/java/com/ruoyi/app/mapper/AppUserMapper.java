package com.ruoyi.app.mapper;

import java.util.List;
import com.ruoyi.app.domain.AppUser;

/**
 * App 用户 Mapper。
 *
 * @author ruoyi
 */
public interface AppUserMapper
{
    public AppUser selectAppUserById(Long appUserId);

    public AppUser selectAppUserBySysUserId(Long sysUserId);

    public AppUser selectAppUserByPhone(String phone);

    public List<AppUser> selectAppUserList(AppUser appUser);

    public int insertAppUser(AppUser appUser);

    public int updateAppUser(AppUser appUser);

    public int deleteAppUserById(Long appUserId);
}
