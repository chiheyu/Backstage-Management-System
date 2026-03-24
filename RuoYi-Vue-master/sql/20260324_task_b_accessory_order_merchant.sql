-- 任务 B：配件订单补充商家归属
-- 执行前请先备份数据库。
--
-- 注意：
-- 1. 本脚本依赖任务 A 已完成，即 app_accessory.merchant_id 已存在并已尽量完成历史商品归属回填。
-- 2. 本脚本不再重复修改 app_accessory，避免在按 A -> B 顺序执行时出现重复列/重复索引错误。

ALTER TABLE app_accessory_order
  ADD COLUMN merchant_id bigint(20) DEFAULT NULL COMMENT '归属商家 ID' AFTER app_user_id;

ALTER TABLE app_accessory_order
  ADD KEY idx_app_accessory_order_merchant_id (merchant_id);

-- 如果历史配件已经绑定商家，可按实际业务规则回填后再执行下面的历史订单回填。
UPDATE app_accessory_order aao
LEFT JOIN app_accessory aa ON aa.accessory_id = aao.accessory_id
SET aao.merchant_id = aa.merchant_id
WHERE aao.merchant_id IS NULL;

-- 建议执行完后检查：
-- SELECT accessory_order_id, accessory_id, merchant_id FROM app_accessory_order ORDER BY accessory_order_id DESC;
-- SELECT COUNT(*) AS unresolved_accessory_order_count FROM app_accessory_order WHERE merchant_id IS NULL;
