package com.ruoyi.app.service.impl;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;
import java.util.concurrent.TimeUnit;
import javax.annotation.Resource;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.support.TransactionTemplate;
import com.ruoyi.app.domain.AppConstants;
import com.ruoyi.app.domain.AppMerchant;
import com.ruoyi.app.domain.AppUser;
import com.ruoyi.app.domain.bo.AppLoginBody;
import com.ruoyi.app.domain.bo.AppRegisterBody;
import com.ruoyi.app.domain.vo.AppLoginVo;
import com.ruoyi.app.mapper.AppMerchantMapper;
import com.ruoyi.app.mapper.AppUserMapper;
import com.ruoyi.app.service.IAppAuthService;
import com.ruoyi.common.constant.Constants;
import com.ruoyi.common.core.domain.entity.SysRole;
import com.ruoyi.common.core.domain.entity.SysUser;
import com.ruoyi.common.core.domain.model.LoginUser;
import com.ruoyi.common.core.redis.RedisCache;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.DateUtils;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.framework.manager.AsyncManager;
import com.ruoyi.framework.manager.factory.AsyncFactory;
import com.ruoyi.framework.security.context.AuthenticationContextHolder;
import com.ruoyi.framework.web.service.TokenService;
import com.ruoyi.system.mapper.SysRoleMapper;
import com.ruoyi.system.mapper.SysUserMapper;
import com.ruoyi.system.service.ISysUserService;

/**
 * App 认证服务实现。
 *
 * <p>该实现严格复用若依的 sys_user / sys_role / JWT 体系，
 * 避免重复维护一套账号认证逻辑。</p>
 *
 * @author ruoyi
 */
@Service
public class AppAuthServiceImpl implements IAppAuthService
{
    private static final Logger log = LoggerFactory.getLogger(AppAuthServiceImpl.class);

    private static final DateTimeFormatter SMS_CODE_TIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @Autowired
    private RedisCache redisCache;

    @Autowired
    private AppUserMapper appUserMapper;

    @Autowired
    private AppMerchantMapper merchantMapper;

    @Autowired
    private SysUserMapper sysUserMapper;

    @Autowired
    private SysRoleMapper sysRoleMapper;

    @Autowired
    private ISysUserService userService;

    @Autowired
    private TokenService tokenService;

    @Resource
    private AuthenticationManager authenticationManager;

    @Autowired
    private TransactionTemplate transactionTemplate;

    @Value("${app.debug.smsCodeFile:}")
    private String smsCodeDebugFile;

    /**
     * 发送模拟验证码。
     *
     * <p>当前阶段直接返回验证码，后续接短信平台时只需替换这里的发送实现。</p>
     */
    @Override
    public String sendRegisterCode(String phone)
    {
        if (StringUtils.isEmpty(phone))
        {
            throw new ServiceException("手机号不能为空");
        }
        String code = StringUtils.leftPad(String.valueOf(new Random().nextInt(1000000)), 6, "0");
        redisCache.setCacheObject(AppConstants.SMS_CODE_CACHE_PREFIX + phone, code, 5, TimeUnit.MINUTES);
        persistDebugSmsCode(phone, code);
        return code;
    }

    /**
     * App 注册。
     */
    @Override
    public AppLoginVo register(AppRegisterBody registerBody)
    {
        validateRegisterBody(registerBody);
        validateSmsCode(registerBody.getPhone(), registerBody.getCode());

        SysUser existPhone = sysUserMapper.checkPhoneUnique(registerBody.getPhone());
        if (StringUtils.isNotNull(existPhone))
        {
            throw new ServiceException("该手机号已注册");
        }
        AppUser existAppUser = appUserMapper.selectAppUserByPhone(registerBody.getPhone());
        if (StringUtils.isNotNull(existAppUser))
        {
            throw new ServiceException("该手机号已注册");
        }

        String username;
        try
        {
            username = transactionTemplate.execute((status) -> {
            ensurePhoneAvailable(registerBody.getPhone());
            String loginUsername = registerBody.getPhone();
            SysUser sysUser = new SysUser();
            sysUser.setUserName(loginUsername);
            sysUser.setNickName(StringUtils.defaultIfEmpty(registerBody.getNickName(), registerBody.getPhone()));
            sysUser.setPhonenumber(registerBody.getPhone());
            sysUser.setStatus(AppConstants.STATUS_NORMAL);
            sysUser.setPwdUpdateDate(DateUtils.getNowDate());
            sysUser.setPassword(SecurityUtils.encryptPassword(registerBody.getPassword()));
            userService.registerUser(sysUser);

            SysUser savedUser = sysUserMapper.checkPhoneUnique(registerBody.getPhone());
            if (StringUtils.isNull(savedUser))
            {
                throw new ServiceException("注册失败，请稍后重试");
            }

            String roleType = AppConstants.ROLE_MERCHANT.equals(registerBody.getRoleType())
                ? AppConstants.ROLE_MERCHANT : AppConstants.ROLE_USER;

            AppUser appUser = new AppUser();
            appUser.setSysUserId(savedUser.getUserId());
            appUser.setPhone(registerBody.getPhone());
            appUser.setNickName(StringUtils.defaultIfEmpty(registerBody.getNickName(), registerBody.getPhone()));
            appUser.setRoleType(roleType);
            appUser.setStatus(AppConstants.STATUS_NORMAL);
            appUser.setCreateBy(loginUsername);
            appUserMapper.insertAppUser(appUser);

            if (AppConstants.ROLE_MERCHANT.equals(roleType))
            {
                AppMerchant merchant = new AppMerchant();
                merchant.setAppUserId(appUser.getAppUserId());
                merchant.setSysUserId(savedUser.getUserId());
                merchant.setMerchantName(StringUtils.defaultIfEmpty(registerBody.getMerchantName(), registerBody.getNickName()));
                merchant.setContactName(StringUtils.defaultIfEmpty(registerBody.getContactName(), registerBody.getNickName()));
                merchant.setContactPhone(registerBody.getPhone());
                merchant.setAddress(registerBody.getAddress());
                merchant.setServiceScope(registerBody.getServiceScope());
                merchant.setCityName("汉中市");
                merchant.setAuditStatus(AppConstants.MERCHANT_AUDIT_APPROVED);
                merchant.setCreateBy(loginUsername);
                merchantMapper.insertMerchant(merchant);

                appUser.setMerchantId(merchant.getMerchantId());
                appUser.setUpdateBy(loginUsername);
                appUserMapper.updateAppUser(appUser);
            }

            String roleKey = AppConstants.ROLE_MERCHANT.equals(roleType) ? "merchant" : "user";
            userService.insertUserAuth(savedUser.getUserId(), new Long[] { getRoleIdByKey(roleKey) });
            return loginUsername;
            });
        }
        catch (DuplicateKeyException exception)
        {
            log.warn("App register duplicate phone, phone={}", registerBody.getPhone(), exception);
            throw new ServiceException("该手机号已注册，请直接登录");
        }

        if (StringUtils.isEmpty(username))
        {
            throw new ServiceException("注册失败，请稍后重试");
        }
        try
        {
            return loginByUsername(username, registerBody.getPassword());
        }
        catch (Exception exception)
        {
            log.warn("App 注册成功，但自动登录失败，username={}", username, exception);
            return null;
        }
    }

    /**
     * App 登录。
     */
    private void ensurePhoneAvailable(String phone)
    {
        if (StringUtils.isNotNull(sysUserMapper.checkPhoneUnique(phone))
            || StringUtils.isNotNull(appUserMapper.selectAppUserByPhone(phone)))
        {
            throw new ServiceException("该手机号已注册，请直接登录");
        }
    }

    @Override
    public AppLoginVo login(AppLoginBody loginBody)
    {
        if (StringUtils.isEmpty(loginBody.getPhone()) || StringUtils.isEmpty(loginBody.getPassword()))
        {
            throw new ServiceException("手机号和密码不能为空");
        }
        SysUser simpleUser = sysUserMapper.checkPhoneUnique(loginBody.getPhone());
        if (StringUtils.isNull(simpleUser))
        {
            throw new ServiceException("手机号未注册");
        }
        SysUser savedUser = userService.selectUserById(simpleUser.getUserId());
        if (StringUtils.isNull(savedUser))
        {
            throw new ServiceException("用户不存在");
        }
        return loginByUsername(savedUser.getUserName(), loginBody.getPassword());
    }

    /**
     * 获取当前 App 用户扩展信息。
     */
    @Override
    public AppUser getCurrentAppUser()
    {
        Long sysUserId = SecurityUtils.getUserId();
        AppUser appUser = appUserMapper.selectAppUserBySysUserId(sysUserId);
        if (StringUtils.isNull(appUser))
        {
            throw new ServiceException("当前账号未绑定 App 用户信息");
        }
        return appUser;
    }

    /**
     * 统一登录并组装返回结果。
     */
    private AppLoginVo loginByUsername(String username, String password)
    {
        Authentication authentication;
        try
        {
            UsernamePasswordAuthenticationToken authenticationToken =
                new UsernamePasswordAuthenticationToken(username, password);
            AuthenticationContextHolder.setContext(authenticationToken);
            authentication = authenticationManager.authenticate(authenticationToken);
        }
        catch (Exception exception)
        {
            if (exception instanceof BadCredentialsException)
            {
                AsyncManager.me().execute(AsyncFactory.recordLogininfor(username, Constants.LOGIN_FAIL, "手机号或密码错误"));
            }
            throw new ServiceException("手机号或密码错误");
        }
        finally
        {
            AuthenticationContextHolder.clearContext();
        }

        LoginUser loginUser = (LoginUser) authentication.getPrincipal();
        String token = tokenService.createToken(loginUser);
        AsyncManager.me().execute(AsyncFactory.recordLogininfor(username, Constants.LOGIN_SUCCESS, "App 登录成功"));

        AppUser appUser = appUserMapper.selectAppUserBySysUserId(loginUser.getUserId());
        AppMerchant merchant = StringUtils.isNotNull(appUser) && StringUtils.isNotNull(appUser.getMerchantId())
            ? merchantMapper.selectMerchantById(appUser.getMerchantId()) : null;
        if (StringUtils.isNotNull(appUser) && AppConstants.ROLE_PENDING_MERCHANT.equals(appUser.getRoleType()))
        {
            merchant = normalizeLegacyPendingMerchant(loginUser, appUser, merchant, username);
            appUser = appUserMapper.selectAppUserBySysUserId(loginUser.getUserId());
        }

        AppLoginVo loginVo = new AppLoginVo();
        loginVo.setToken(token);
        loginVo.setAppUser(appUser);
        loginVo.setMerchant(merchant);
        loginVo.setRoleType(StringUtils.isNotNull(appUser) ? appUser.getRoleType() : AppConstants.ROLE_USER);
        return loginVo;
    }

    /**
     * 校验注册参数。
     */
    private void validateRegisterBody(AppRegisterBody registerBody)
    {
        if (StringUtils.isNull(registerBody))
        {
            throw new ServiceException("注册参数不能为空");
        }
        if (StringUtils.isEmpty(registerBody.getPhone()))
        {
            throw new ServiceException("手机号不能为空");
        }
        if (StringUtils.isEmpty(registerBody.getPassword()))
        {
            throw new ServiceException("密码不能为空");
        }
        if (!StringUtils.equals(registerBody.getPassword(), registerBody.getConfirmPassword()))
        {
            throw new ServiceException("两次输入的密码不一致");
        }
        if (AppConstants.ROLE_MERCHANT.equals(registerBody.getRoleType())
            && StringUtils.isEmpty(registerBody.getMerchantName()))
        {
            throw new ServiceException("商家注册时必须填写商家名称");
        }
    }

    /**
     * 校验模拟验证码。
     */
    private void validateSmsCode(String phone, String code)
    {
        String cacheCode = redisCache.getCacheObject(AppConstants.SMS_CODE_CACHE_PREFIX + phone);
        if (StringUtils.isEmpty(cacheCode))
        {
            throw new ServiceException("验证码已过期，请重新获取");
        }
        if (!StringUtils.equals(cacheCode, code))
        {
            throw new ServiceException("验证码错误");
        }
        redisCache.deleteObject(AppConstants.SMS_CODE_CACHE_PREFIX + phone);
    }

    /**
     * 按角色标识查询角色 ID。
     */
    private Long getRoleIdByKey(String roleKey)
    {
        SysRole role = sysRoleMapper.checkRoleKeyUnique(roleKey);
        if (StringUtils.isNull(role) || StringUtils.isNull(role.getRoleId()))
        {
            throw new ServiceException("请先在系统中初始化角色：" + roleKey);
        }
        return role.getRoleId();
    }

    private AppMerchant normalizeLegacyPendingMerchant(LoginUser loginUser, AppUser appUser, AppMerchant merchant, String username)
    {
        if (StringUtils.isNull(merchant))
        {
            return null;
        }

        boolean merchantChanged = false;
        if (!AppConstants.MERCHANT_AUDIT_APPROVED.equals(merchant.getAuditStatus()))
        {
            merchant.setAuditStatus(AppConstants.MERCHANT_AUDIT_APPROVED);
            merchant.setUpdateBy(username);
            merchantMapper.updateMerchant(merchant);
            merchantChanged = true;
        }

        appUser.setRoleType(AppConstants.ROLE_MERCHANT);
        appUser.setStatus(AppConstants.STATUS_NORMAL);
        appUser.setMerchantId(merchant.getMerchantId());
        appUser.setUpdateBy(username);
        appUserMapper.updateAppUser(appUser);

        userService.insertUserAuth(loginUser.getUserId(), new Long[] { getRoleIdByKey("merchant") });

        SysUser sysUser = userService.selectUserById(loginUser.getUserId());
        if (StringUtils.isNotNull(sysUser) && !AppConstants.STATUS_NORMAL.equals(sysUser.getStatus()))
        {
            sysUser.setStatus(AppConstants.STATUS_NORMAL);
            userService.updateUserStatus(sysUser);
        }

        return merchantChanged ? merchantMapper.selectMerchantById(merchant.getMerchantId()) : merchant;
    }

    /**
     * 测试环境下把验证码落盘，便于联调注册流程。
     */
    private void persistDebugSmsCode(String phone, String code)
    {
        if (StringUtils.isEmpty(smsCodeDebugFile))
        {
            return;
        }

        Path smsCodeFilePath = Paths.get(smsCodeDebugFile);
        Path parentPath = smsCodeFilePath.getParent();
        LocalDateTime now = LocalDateTime.now();
        String fileContent = new StringBuilder()
            .append("phone=").append(phone).append(System.lineSeparator())
            .append("code=").append(code).append(System.lineSeparator())
            .append("generatedAt=").append(now.format(SMS_CODE_TIME_FORMATTER)).append(System.lineSeparator())
            .append("expireAt=").append(now.plusMinutes(5).format(SMS_CODE_TIME_FORMATTER)).append(System.lineSeparator())
            .toString();

        try
        {
            if (parentPath != null)
            {
                Files.createDirectories(parentPath);
            }
            Files.write(
                smsCodeFilePath,
                fileContent.getBytes(StandardCharsets.UTF_8),
                StandardOpenOption.CREATE,
                StandardOpenOption.TRUNCATE_EXISTING,
                StandardOpenOption.WRITE
            );
        }
        catch (IOException exception)
        {
            throw new ServiceException("验证码写入测试文件失败：" + exception.getMessage());
        }
    }
}
