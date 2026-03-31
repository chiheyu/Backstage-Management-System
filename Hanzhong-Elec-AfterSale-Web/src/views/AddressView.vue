<script setup>
import { computed, reactive, ref } from 'vue'
import { loadAddressList, markAddressAsDefault, removeAddress, upsertAddress } from '@/lib/localData'
import { pushNotice } from '@/lib/notice'

const addressList = ref(loadAddressList())
const editingId = ref('')

const form = reactive({
  name: '',
  phone: '',
  region: '',
  detail: '',
  isDefault: false
})

const isEditing = computed(() => !!editingId.value)

function refreshAddressList() {
  addressList.value = loadAddressList()
}

function resetForm() {
  editingId.value = ''
  form.name = ''
  form.phone = ''
  form.region = ''
  form.detail = ''
  form.isDefault = addressList.value.length === 0
}

function editAddress(address) {
  editingId.value = address.id
  form.name = address.name
  form.phone = address.phone
  form.region = address.region
  form.detail = address.detail
  form.isDefault = Boolean(address.isDefault)
}

function validateForm() {
  if (!form.name.trim()) {
    pushNotice('请输入收货人姓名', 'danger')
    return false
  }
  if (!/^1\d{10}$/.test(form.phone.trim())) {
    pushNotice('请输入正确的 11 位手机号', 'danger')
    return false
  }
  if (!form.region.trim()) {
    pushNotice('请输入所在地区', 'danger')
    return false
  }
  if (!form.detail.trim()) {
    pushNotice('请输入详细地址', 'danger')
    return false
  }
  return true
}

function submitAddress() {
  if (!validateForm()) {
    return
  }

  upsertAddress({
    id: editingId.value || undefined,
    name: form.name,
    phone: form.phone,
    region: form.region,
    detail: form.detail,
    isDefault: form.isDefault
  })
  refreshAddressList()
  pushNotice(isEditing.value ? '地址已更新' : '地址已新增', 'success')
  resetForm()
}

function handleRemove(id) {
  removeAddress(id)
  refreshAddressList()
  pushNotice('地址已删除', 'success')
  if (editingId.value === id) {
    resetForm()
  }
}

function handleSetDefault(id) {
  markAddressAsDefault(id)
  refreshAddressList()
  pushNotice('已切换默认地址', 'success')
  if (editingId.value === id) {
    form.isDefault = true
  }
}

resetForm()
</script>

<template>
  <section class="page-shell address-page">
    <section class="glass-card address-hero">
      <div>
        <span class="eyebrow">地址簿</span>
        <h1>管理收货地址</h1>
      </div>
      <div class="surface-card address-hero__side">
        <span class="eyebrow">当前已添加：</span>
        <strong>{{ addressList.length }} 条地址</strong>
      </div>
    </section>

    <section class="address-grid">
      <section class="surface-card section-card">
        <div class="section-head">
          <div>
            <span class="eyebrow">地址列表</span>
            <h2>已保存地址</h2>
            <p>点击编辑可直接修改已有地址，也可以切换默认地址。</p>
          </div>
        </div>

        <div v-if="addressList.length" class="address-list">
          <article v-for="item in addressList" :key="item.id" class="address-card">
            <div class="between-row address-card__head">
              <div>
                <strong>{{ item.name }}</strong>
                <span>{{ item.phone }}</span>
              </div>
              <span v-if="item.isDefault" class="status-badge status-badge--brand">默认地址</span>
            </div>
            <p>{{ item.region }} {{ item.detail }}</p>
            <div class="action-row">
              <button class="btn btn--ghost btn--small" @click="editAddress(item)">编辑</button>
              <button v-if="!item.isDefault" class="btn btn--ghost btn--small" @click="handleSetDefault(item.id)">设为默认</button>
              <button class="btn btn--ghost btn--small" @click="handleRemove(item.id)">删除</button>
            </div>
          </article>
        </div>
        <div v-else class="empty-state">
          <h3>还没有地址</h3>
          <p>先添加一个默认地址，后续结算和售后会更省事。</p>
        </div>
      </section>

      <section class="surface-card section-card">
        <div class="section-head">
          <div>
            <span class="eyebrow">地址表单</span>
            <h2>{{ isEditing ? '编辑地址' : '新增地址' }}</h2>
          </div>
        </div>

        <form class="address-form" @submit.prevent="submitAddress">
          <div class="field-row">
            <label>
              <span>收货人</span>
              <input v-model.trim="form.name" class="field" placeholder="请输入姓名" />
            </label>
            <label>
              <span>手机号</span>
              <input v-model.trim="form.phone" class="field" placeholder="11 位手机号" />
            </label>
          </div>

          <label>
            <span>所在地区</span>
            <input v-model.trim="form.region" class="field" placeholder="例如 陕西省 汉中市 汉台区" />
          </label>

          <label>
            <span>详细地址</span>
            <input v-model.trim="form.detail" class="field" placeholder="例如 中山街 88 号 3 单元 502" />
          </label>

          <label class="address-form__check">
            <input v-model="form.isDefault" type="checkbox" />
            <span>设为默认地址</span>
          </label>

          <div class="action-row">
            <button class="btn btn--primary">{{ isEditing ? '保存修改' : '新增地址' }}</button>
            <button type="button" class="btn btn--ghost" @click="resetForm">重置表单</button>
          </div>
        </form>
      </section>
    </section>
  </section>
</template>

<style scoped>
.address-page {
  display: grid;
  gap: 22px;
}

.address-hero {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 320px;
  gap: 22px;
  padding: 28px;
}

.address-hero h1 {
  margin: 14px 0 8px;
  font-size: clamp(32px, 4vw, 48px);
  line-height: 1.08;
}

.address-hero__side {
  display: grid;
  gap: 12px;
  align-content: start;
  padding: 22px;
}

.address-hero__side strong {
  font-size: 28px;
  color: var(--primary-deep);
}

.address-grid {
  display: grid;
  grid-template-columns: minmax(0, 1.08fr) minmax(320px, 0.92fr);
  gap: 24px;
}

.address-list,
.address-form {
  display: grid;
  gap: 16px;
}

.address-card {
  padding: 18px;
  border-radius: 22px;
  background: linear-gradient(180deg, rgba(255, 255, 255, 0.94), rgba(248, 244, 236, 0.94));
  border: 1px solid rgba(17, 61, 77, 0.08);
}

.address-card__head strong,
.address-form span {
  display: block;
}

.address-card__head span {
  color: var(--muted);
}

.address-form label {
  display: grid;
  gap: 8px;
}

.address-form span {
  font-size: 14px;
  font-weight: 700;
  color: var(--primary-deep);
}

.address-form__check {
  display: flex;
  align-items: center;
  gap: 12px;
}

.address-form__check span {
  margin: 0;
}

@media (max-width: 980px) {
  .address-hero,
  .address-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 720px) {
  .address-hero,
  .field-row {
    display: grid;
  }

  .address-hero {
    padding: 18px;
  }
}
</style>
