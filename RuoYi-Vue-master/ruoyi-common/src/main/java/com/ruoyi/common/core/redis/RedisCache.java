package com.ruoyi.common.core.redis;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.BoundSetOperations;
import org.springframework.data.redis.core.HashOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.stereotype.Component;

/**
 * spring redis 宸ュ叿绫?
 *
 * standalone 妯″紡涓嬩細鑷姩鍥為€€鍒版湰鍦扮紦瀛橈紝閬垮厤渚濊禆澶栭儴 Redis 鏈嶅姟銆?
 *
 * @author ruoyi
 **/
@SuppressWarnings(value = { "unchecked", "rawtypes" })
@Component
public class RedisCache
{
    private static final long NO_EXPIRE = -1L;

    private final Map<String, LocalCacheValue> localCache = new ConcurrentHashMap<>();

    @Autowired(required = false)
    public RedisTemplate redisTemplate;

    @Value("${app.standalone.local-cache.enabled:false}")
    private boolean localCacheEnabled;

    private boolean useLocalCache()
    {
        return localCacheEnabled || redisTemplate == null;
    }

    private void evictIfExpired(String key)
    {
        if (!useLocalCache())
        {
            return;
        }
        LocalCacheValue value = localCache.get(key);
        if (value != null && value.isExpired())
        {
            localCache.remove(key);
        }
    }

    private LocalCacheValue getLocalValue(String key)
    {
        evictIfExpired(key);
        return localCache.get(key);
    }

    private void putLocalValue(String key, Object value)
    {
        putLocalValue(key, value, NO_EXPIRE);
    }

    private void putLocalValue(String key, Object value, long expireAt)
    {
        localCache.put(key, new LocalCacheValue(value, expireAt));
    }

    private long resolveExpireAt(long timeout, TimeUnit timeUnit)
    {
        if (timeout <= 0)
        {
            return NO_EXPIRE;
        }
        return System.currentTimeMillis() + timeUnit.toMillis(timeout);
    }

    /**
     * 缂撳瓨鍩烘湰鐨勫璞★紝Integer銆丼tring銆佸疄浣撶被绛?
     *
     * @param key 缂撳瓨鐨勯敭鍊?
     * @param value 缂撳瓨鐨勫€?
     */
    public <T> void setCacheObject(final String key, final T value)
    {
        if (useLocalCache())
        {
            putLocalValue(key, value);
            return;
        }
        redisTemplate.opsForValue().set(key, value);
    }

    /**
     * 缂撳瓨鍩烘湰鐨勫璞★紝Integer銆丼tring銆佸疄浣撶被绛?
     *
     * @param key 缂撳瓨鐨勯敭鍊?
     * @param value 缂撳瓨鐨勫€?
     * @param timeout 鏃堕棿
     * @param timeUnit 鏃堕棿棰楃矑搴?
     */
    public <T> void setCacheObject(final String key, final T value, final Integer timeout, final TimeUnit timeUnit)
    {
        if (useLocalCache())
        {
            putLocalValue(key, value, resolveExpireAt(timeout, timeUnit));
            return;
        }
        redisTemplate.opsForValue().set(key, value, timeout, timeUnit);
    }

    /**
     * 璁剧疆鏈夋晥鏃堕棿
     *
     * @param key Redis閿?
     * @param timeout 瓒呮椂鏃堕棿
     * @return true=璁剧疆鎴愬姛锛沠alse=璁剧疆澶辫触
     */
    public boolean expire(final String key, final long timeout)
    {
        return expire(key, timeout, TimeUnit.SECONDS);
    }

    /**
     * 璁剧疆鏈夋晥鏃堕棿
     *
     * @param key Redis閿?
     * @param timeout 瓒呮椂鏃堕棿
     * @param unit 鏃堕棿鍗曚綅
     * @return true=璁剧疆鎴愬姛锛沠alse=璁剧疆澶辫触
     */
    public boolean expire(final String key, final long timeout, final TimeUnit unit)
    {
        if (useLocalCache())
        {
            LocalCacheValue value = getLocalValue(key);
            if (value == null)
            {
                return false;
            }
            value.setExpireAt(resolveExpireAt(timeout, unit));
            return true;
        }
        return redisTemplate.expire(key, timeout, unit);
    }

    /**
     * 鑾峰彇鏈夋晥鏃堕棿
     *
     * @param key Redis閿?
     * @return 鏈夋晥鏃堕棿
     */
    public long getExpire(final String key)
    {
        if (useLocalCache())
        {
            LocalCacheValue value = getLocalValue(key);
            if (value == null)
            {
                return -2L;
            }
            if (!value.hasExpire())
            {
                return -1L;
            }
            long millis = value.getExpireAt() - System.currentTimeMillis();
            return millis <= 0 ? -2L : TimeUnit.MILLISECONDS.toSeconds(millis);
        }
        return redisTemplate.getExpire(key);
    }

    /**
     * 鍒ゆ柇 key鏄惁瀛樺湪
     *
     * @param key 閿?
     * @return true 瀛樺湪 false涓嶅瓨鍦?
     */
    public Boolean hasKey(String key)
    {
        if (useLocalCache())
        {
            return getLocalValue(key) != null;
        }
        return redisTemplate.hasKey(key);
    }

    /**
     * 鑾峰緱缂撳瓨鐨勫熀鏈璞°
     *
     * @param key 缂撳瓨閿€?
     * @return 缂撳瓨閿€煎搴旂殑鏁版嵁
     */
    public <T> T getCacheObject(final String key)
    {
        if (useLocalCache())
        {
            LocalCacheValue value = getLocalValue(key);
            return value == null ? null : (T) value.getValue();
        }
        ValueOperations<String, T> operation = redisTemplate.opsForValue();
        return operation.get(key);
    }

    /**
     * 鍒犻櫎鍗曚釜瀵硅薄
     *
     * @param key key
     */
    public boolean deleteObject(final String key)
    {
        if (useLocalCache())
        {
            return localCache.remove(key) != null;
        }
        return redisTemplate.delete(key);
    }

    /**
     * 鍒犻櫎闆嗗悎瀵硅薄
     *
     * @param collection 澶氫釜瀵硅薄
     * @return result
     */
    public boolean deleteObject(final Collection collection)
    {
        if (useLocalCache())
        {
            boolean removed = false;
            if (collection != null)
            {
                for (Object key : collection)
                {
                    removed = localCache.remove(String.valueOf(key)) != null || removed;
                }
            }
            return removed;
        }
        return redisTemplate.delete(collection) > 0;
    }

    /**
     * 缂撳瓨List鏁版嵁
     *
     * @param key 缂撳瓨鐨勯敭鍊?
     * @param dataList 寰呯紦瀛樼殑List鏁版嵁
     * @return 缂撳瓨鐨勫璞?
     */
    public <T> long setCacheList(final String key, final List<T> dataList)
    {
        if (useLocalCache())
        {
            List<T> list = dataList == null ? Collections.emptyList() : new ArrayList<>(dataList);
            putLocalValue(key, list);
            return list.size();
        }
        Long count = redisTemplate.opsForList().rightPushAll(key, dataList);
        return count == null ? 0 : count;
    }

    /**
     * 鑾峰緱缂撳瓨鐨刲ist瀵硅薄
     *
     * @param key 缂撳瓨鐨勯敭鍊?
     * @return 缂撳瓨閿€煎搴旂殑鏁版嵁
     */
    public <T> List<T> getCacheList(final String key)
    {
        if (useLocalCache())
        {
            LocalCacheValue value = getLocalValue(key);
            if (value == null)
            {
                return Collections.emptyList();
            }
            Object cacheValue = value.getValue();
            if (cacheValue instanceof List)
            {
                return new ArrayList<>((List<T>) cacheValue);
            }
            return Collections.emptyList();
        }
        return redisTemplate.opsForList().range(key, 0, -1);
    }

    /**
     * 缂撳瓨Set
     *
     * @param key 缂撳瓨閿€?
     * @param dataSet 缂撳瓨鐨勬暟鎹?
     * @return 缂撳瓨鏁版嵁鐨勫璞?
     */
    public <T> BoundSetOperations<String, T> setCacheSet(final String key, final Set<T> dataSet)
    {
        if (useLocalCache())
        {
            Set<T> set = dataSet == null ? Collections.emptySet() : new LinkedHashSet<>(dataSet);
            putLocalValue(key, set);
            return null;
        }
        BoundSetOperations<String, T> setOperation = redisTemplate.boundSetOps(key);
        Iterator<T> it = dataSet.iterator();
        while (it.hasNext())
        {
            setOperation.add(it.next());
        }
        return setOperation;
    }

    /**
     * 鑾峰緱缂撳瓨鐨剆et
     *
     * @param key key
     * @return result
     */
    public <T> Set<T> getCacheSet(final String key)
    {
        if (useLocalCache())
        {
            LocalCacheValue value = getLocalValue(key);
            if (value == null)
            {
                return Collections.emptySet();
            }
            Object cacheValue = value.getValue();
            if (cacheValue instanceof Set)
            {
                return new LinkedHashSet<>((Set<T>) cacheValue);
            }
            return Collections.emptySet();
        }
        return redisTemplate.opsForSet().members(key);
    }

    /**
     * 缂撳瓨Map
     *
     * @param key key
     * @param dataMap data map
     */
    public <T> void setCacheMap(final String key, final Map<String, T> dataMap)
    {
        if (useLocalCache())
        {
            putLocalValue(key, dataMap == null ? Collections.emptyMap() : new LinkedHashMap<>(dataMap));
            return;
        }
        if (dataMap != null)
        {
            redisTemplate.opsForHash().putAll(key, dataMap);
        }
    }

    /**
     * 鑾峰緱缂撳瓨鐨凪ap
     *
     * @param key key
     * @return result
     */
    public <T> Map<String, T> getCacheMap(final String key)
    {
        if (useLocalCache())
        {
            LocalCacheValue value = getLocalValue(key);
            if (value == null)
            {
                return Collections.emptyMap();
            }
            Object cacheValue = value.getValue();
            if (cacheValue instanceof Map)
            {
                return new LinkedHashMap<>((Map<String, T>) cacheValue);
            }
            return Collections.emptyMap();
        }
        return redisTemplate.opsForHash().entries(key);
    }

    /**
     * 寰€Hash涓瓨鍏ユ暟鎹?
     *
     * @param key Redis閿?
     * @param hKey Hash閿?
     * @param value 鍊?
     */
    public <T> void setCacheMapValue(final String key, final String hKey, final T value)
    {
        if (useLocalCache())
        {
            Map<String, Object> cacheMap = new LinkedHashMap<>(getCacheMap(key));
            cacheMap.put(hKey, value);
            putLocalValue(key, cacheMap);
            return;
        }
        redisTemplate.opsForHash().put(key, hKey, value);
    }

    /**
     * 鑾峰彇Hash涓殑鏁版嵁
     *
     * @param key Redis閿?
     * @param hKey Hash閿?
     * @return Hash涓殑瀵硅薄
     */
    public <T> T getCacheMapValue(final String key, final String hKey)
    {
        if (useLocalCache())
        {
            Map<String, T> cacheMap = getCacheMap(key);
            return cacheMap.get(hKey);
        }
        HashOperations<String, String, T> opsForHash = redisTemplate.opsForHash();
        return opsForHash.get(key, hKey);
    }

    /**
     * 鑾峰彇澶氫釜Hash涓殑鏁版嵁
     *
     * @param key Redis閿?
     * @param hKeys Hash閿泦鍚?
     * @return Hash瀵硅薄闆嗗悎
     */
    public <T> List<T> getMultiCacheMapValue(final String key, final Collection<Object> hKeys)
    {
        if (useLocalCache())
        {
            Map<String, T> cacheMap = getCacheMap(key);
            if (hKeys == null)
            {
                return Collections.emptyList();
            }
            List<T> result = new ArrayList<>();
            for (Object hKey : hKeys)
            {
                result.add(cacheMap.get(String.valueOf(hKey)));
            }
            return result;
        }
        return redisTemplate.opsForHash().multiGet(key, hKeys);
    }

    /**
     * 鍒犻櫎Hash涓殑鏌愭潯鏁版嵁
     *
     * @param key Redis閿?
     * @param hKey Hash閿?
     * @return 鏄惁鎴愬姛
     */
    public boolean deleteCacheMapValue(final String key, final String hKey)
    {
        if (useLocalCache())
        {
            Map<String, Object> cacheMap = new LinkedHashMap<>(getCacheMap(key));
            boolean removed = cacheMap.remove(hKey) != null;
            putLocalValue(key, cacheMap);
            return removed;
        }
        return redisTemplate.opsForHash().delete(key, hKey) > 0;
    }

    /**
     * 鑾峰緱缂撳瓨鐨勫熀鏈璞″垪琛?
     *
     * @param pattern 瀛楃涓插墠缂€
     * @return 瀵硅薄鍒楄〃
     */
    public Collection<String> keys(final String pattern)
    {
        if (useLocalCache())
        {
            String regex = pattern.replace(".", "\\.").replace("*", ".*");
            Pattern compiled = Pattern.compile(regex);
            return localCache.keySet()
                    .stream()
                    .filter(key -> {
                        evictIfExpired(key);
                        return localCache.containsKey(key) && compiled.matcher(key).matches();
                    })
                    .collect(Collectors.toList());
        }
        return redisTemplate.keys(pattern);
    }

    private static final class LocalCacheValue
    {
        private final Object value;

        private volatile long expireAt;

        private LocalCacheValue(Object value, long expireAt)
        {
            this.value = value;
            this.expireAt = expireAt;
        }

        private Object getValue()
        {
            return value;
        }

        private long getExpireAt()
        {
            return expireAt;
        }

        private void setExpireAt(long expireAt)
        {
            this.expireAt = expireAt;
        }

        private boolean hasExpire()
        {
            return expireAt > 0;
        }

        private boolean isExpired()
        {
            return hasExpire() && System.currentTimeMillis() >= expireAt;
        }
    }
}
