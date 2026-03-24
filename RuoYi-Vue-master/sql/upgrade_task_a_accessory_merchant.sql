-- 任务 A：配件与商家归属关系升级脚本
-- 作用：
-- 1. 给 app_accessory 增加 merchant_id
-- 2. 为历史数据回填可推断的 merchant_id
-- 3. 为后续“商家只能看到自己的商品”提供数据基础
--
-- 注意：
-- 1. 当前代码中的配件订单查询已经依赖 app_accessory.merchant_id。
-- 2. 如果没有先执行本脚本，普通用户查看“我的 -> 待处理/已完成”里的配件订单时，就可能出现
--    Unknown column 'aa.merchant_id' in 'field list'。
-- 3. 本脚本应先于任务 B 脚本执行。

SET NAMES utf8mb4;

ALTER TABLE app_accessory
    ADD COLUMN merchant_id bigint(20) DEFAULT NULL COMMENT '归属商家 ID' AFTER accessory_id;

ALTER TABLE app_accessory
    ADD KEY idx_app_accessory_merchant_id (merchant_id);

-- 优先按 create_by 对应的 sys_user -> app_merchant 关系回填
UPDATE app_accessory aa
LEFT JOIN sys_user su ON su.user_name = aa.create_by
LEFT JOIN app_merchant am ON am.sys_user_id = su.user_id
SET aa.merchant_id = am.merchant_id
WHERE aa.merchant_id IS NULL
  AND am.merchant_id IS NOT NULL;

-- 如果当前环境只有 1 个商家，则自动将剩余未归属的历史商品回填给该商家
UPDATE app_accessory aa
JOIN (
    SELECT merchant_id
    FROM app_merchant
    LIMIT 1
) only_merchant
SET aa.merchant_id = only_merchant.merchant_id
WHERE aa.merchant_id IS NULL
  AND (SELECT COUNT(*) FROM app_merchant) = 1;

-- 如果执行完后仍有 merchant_id 为空的历史商品，说明当前环境存在多商家且无法自动判定归属
-- 这部分需要人工确认后再回填
-- 示例：
-- UPDATE app_accessory SET merchant_id = 3 WHERE accessory_id IN (1,2,3);

-- 建议在执行完回填后再检查：
-- SELECT accessory_id, accessory_name, merchant_id FROM app_accessory;
-- SELECT COUNT(*) AS unresolved_accessory_count FROM app_accessory WHERE merchant_id IS NULL;
