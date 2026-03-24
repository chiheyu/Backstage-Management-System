package com.ruoyi.web.controller.app;

import javax.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.app.domain.bo.AppLoginBody;
import com.ruoyi.app.domain.bo.AppRegisterBody;
import com.ruoyi.app.service.IAppAuthService;
import com.ruoyi.common.constant.Constants;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.domain.model.LoginUser;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.framework.manager.AsyncManager;
import com.ruoyi.framework.manager.factory.AsyncFactory;
import com.ruoyi.framework.web.service.TokenService;

/**
 * App 认证控制器。
 *
 * @author ruoyi
 */
@RestController
@RequestMapping("/app/auth")
public class AppAuthController
{
    @Autowired
    private IAppAuthService appAuthService;

    @Autowired
    private TokenService tokenService;

    /**
     * 发送模拟短信验证码。
     */
    @GetMapping("/sendCode")
    public AjaxResult sendCode(String phone)
    {
        AjaxResult ajaxResult = AjaxResult.success("验证码发送成功");
        ajaxResult.put("smsCode", appAuthService.sendRegisterCode(phone));
        return ajaxResult;
    }

    /**
     * 用户/商家注册。
     */
    @PostMapping("/register")
    public AjaxResult register(@RequestBody AppRegisterBody registerBody)
    {
        return AjaxResult.success(appAuthService.register(registerBody));
    }

    /**
     * App 登录。
     */
    @PostMapping("/login")
    public AjaxResult login(@RequestBody AppLoginBody loginBody)
    {
        return AjaxResult.success(appAuthService.login(loginBody));
    }

    /**
     * App 退出登录。
     */
    @PostMapping("/logout")
    public AjaxResult logout(HttpServletRequest request)
    {
        LoginUser loginUser = tokenService.getLoginUser(request);
        if (StringUtils.isNotNull(loginUser))
        {
            tokenService.delLoginUser(loginUser.getToken());
            AsyncManager.me().execute(AsyncFactory.recordLogininfor(loginUser.getUsername(), Constants.LOGOUT, "App 退出成功"));
        }
        return AjaxResult.success("退出成功");
    }

    /**
     * 当前 App 用户信息。
     */
    @GetMapping("/profile")
    public AjaxResult profile()
    {
        return AjaxResult.success(appAuthService.getCurrentAppUser());
    }
}
