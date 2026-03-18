package com.ruoyi.app.service.impl;

import com.ruoyi.common.core.domain.entity.SysUser;

/**
 * 用户辅助工具。
 *
 * @author ruoyi
 */
public final class SysUserHelper
{
    private SysUserHelper()
    {
    }

    public static boolean isAdmin(Long userId)
    {
        return SysUser.isAdmin(userId);
    }
}
