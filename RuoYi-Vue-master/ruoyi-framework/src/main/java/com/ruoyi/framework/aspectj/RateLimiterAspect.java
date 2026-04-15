package com.ruoyi.framework.aspectj;

import java.lang.reflect.Method;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.reflect.MethodSignature;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.script.RedisScript;
import org.springframework.stereotype.Component;
import com.ruoyi.common.annotation.RateLimiter;
import com.ruoyi.common.enums.LimitType;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.common.utils.ip.IpUtils;

/**
 * 闄愭祦澶勭悊
 *
 * standalone 妯″紡涓嬩娇鐢ㄨ繘绋嬪唴闄愭祦璁℃暟锛岄伩鍏嶅閮?Redis 渚濊禆銆?
 *
 * @author ruoyi
 */
@Aspect
@Component
public class RateLimiterAspect
{
    private static final Logger log = LoggerFactory.getLogger(RateLimiterAspect.class);

    private final Map<String, LocalRateLimitState> localRateLimits = new ConcurrentHashMap<>();

    @Value("${app.standalone.local-cache.enabled:false}")
    private boolean localCacheEnabled;

    private RedisTemplate<Object, Object> redisTemplate;

    private RedisScript<Long> limitScript;

    @Autowired(required = false)
    public void setRedisTemplate(RedisTemplate<Object, Object> redisTemplate)
    {
        this.redisTemplate = redisTemplate;
    }

    @Autowired(required = false)
    public void setLimitScript(RedisScript<Long> limitScript)
    {
        this.limitScript = limitScript;
    }

    @Before("@annotation(rateLimiter)")
    public void doBefore(JoinPoint point, RateLimiter rateLimiter) throws Throwable
    {
        int time = rateLimiter.time();
        int count = rateLimiter.count();

        String combineKey = getCombineKey(rateLimiter, point);
        try
        {
            long current;
            if (useLocalLimiter())
            {
                current = incrementLocalCounter(combineKey, time);
            }
            else
            {
                List<Object> keys = Collections.singletonList(combineKey);
                Long number = redisTemplate.execute(limitScript, keys, count, time);
                current = number == null ? 0L : number.longValue();
            }

            if (current <= 0 || current > count)
            {
                throw new ServiceException("璁块棶杩囦簬棰戠箒锛岃绋嶅€欏啀璇?");
            }
            log.info("闄愬埗璇锋眰'{}',褰撳墠璇锋眰'{}',缂撳瓨key'{}'", count, current, combineKey);
        }
        catch (ServiceException e)
        {
            throw e;
        }
        catch (Exception e)
        {
            throw new RuntimeException("鏈嶅姟鍣ㄩ檺娴佸紓甯革紝璇风◢鍊欏啀璇?");
        }
    }

    public String getCombineKey(RateLimiter rateLimiter, JoinPoint point)
    {
        StringBuffer stringBuffer = new StringBuffer(rateLimiter.key());
        if (rateLimiter.limitType() == LimitType.IP)
        {
            stringBuffer.append(IpUtils.getIpAddr()).append("-");
        }
        MethodSignature signature = (MethodSignature) point.getSignature();
        Method method = signature.getMethod();
        Class<?> targetClass = method.getDeclaringClass();
        stringBuffer.append(targetClass.getName()).append("-").append(method.getName());
        return stringBuffer.toString();
    }

    private boolean useLocalLimiter()
    {
        return localCacheEnabled || redisTemplate == null || limitScript == null;
    }

    private long incrementLocalCounter(String key, int timeWindowSeconds)
    {
        long now = System.currentTimeMillis();
        long expireAt = now + timeWindowSeconds * 1000L;
        LocalRateLimitState state = localRateLimits.compute(key, (cacheKey, currentState) -> {
            if (currentState == null || currentState.isExpired(now))
            {
                return new LocalRateLimitState(1L, expireAt);
            }
            currentState.increment();
            return currentState;
        });
        localRateLimits.entrySet().removeIf(entry -> entry.getValue().isExpired(now));
        return state.getCount();
    }

    private static final class LocalRateLimitState
    {
        private long count;

        private long expireAt;

        private LocalRateLimitState(long count, long expireAt)
        {
            this.count = count;
            this.expireAt = expireAt;
        }

        private long getCount()
        {
            return count;
        }

        private void increment()
        {
            this.count++;
        }

        private boolean isExpired(long now)
        {
            return expireAt <= now;
        }
    }
}
